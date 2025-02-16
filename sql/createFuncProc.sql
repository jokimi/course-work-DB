
-- ФУНКЦИЯ 1. Шифрование пароля - EncryptionPassword

CREATE OR REPLACE FUNCTION EncryptionPassword
    (pUserPassword IN USERS_T.user_password%TYPE)
    RETURN USERS_T.user_password%TYPE
IS
    lKey VARCHAR2(2000) := '0710196810121972';
    lInVal VARCHAR2(2000) := pUserPassword;
    lMod NUMBER := DBMS_CRYPTO.encrypt_aes128 + DBMS_CRYPTO.chain_cbc + DBMS_CRYPTO.pad_pkcs5;
    lEnc RAW(2000);
BEGIN
    lEnc := DBMS_CRYPTO.encrypt(
        utl_i18n.string_to_raw(lInVal, 'AL32UTF8'),
        lMod,
        utl_i18n.string_to_raw(lKey, 'AL32UTF8')
    );
    RETURN RAWTOHEX(lEnc);
EXCEPTION
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20001, 'Convertion error or wrong encryption data!');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No data for encryption!');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Unknown error: ' || SQLERRM);
END EncryptionPassword;

-- ФУНКЦИЯ 2. Дешифрование пароля - DecryptionPassword

CREATE OR REPLACE FUNCTION DecryptionPassword
    (pUserPassword IN USERS_T.user_password%TYPE)
    RETURN USERS_T.user_password%TYPE
IS
    lKey VARCHAR2(2000) := '0710196810121972';
    lInVal RAW(2000) := HEXTORAW(pUserPassword);
    lMod NUMBER := DBMS_CRYPTO.encrypt_aes128 + DBMS_CRYPTO.chain_cbc + DBMS_CRYPTO.pad_pkcs5;
    lDec RAW(2000);
BEGIN
    lDec := DBMS_CRYPTO.decrypt(
        lInVal,
        lMod,
        utl_i18n.string_to_raw(lKey, 'AL32UTF8')
    );
    RETURN utl_i18n.raw_to_char(lDec, 'AL32UTF8');
EXCEPTION
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20001, 'Convertion error or wrong decryption data!');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No data for decryption!');
    WHEN INVALID_NUMBER THEN
        RAISE_APPLICATION_ERROR(-20003, 'Wrong password format!');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Unknown error: ' || SQLERRM);
END DecryptionPassword;

-- ПРОЦЕДУРА 1. Регистрация пользователя - RegisterUser

CREATE OR REPLACE PROCEDURE RegisterUser
    (pUserLogin IN USERS_T.user_login%TYPE, pUserPassword IN USERS_T.user_password%TYPE)
IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
    IF (cnt = 0) THEN
        INSERT INTO users_t (user_login, user_password, user_role)
            VALUES(UPPER(pUserLogin), EncryptionPassword(UPPER(pUserPassword)), 1);
        DBMS_OUTPUT.PUT_LINE('User registered successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'This login is already taken!');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'An error occurred during registration: ' || SQLERRM);
END RegisterUser;

-- ПРОЦЕДУРА 2. Нахождение роли пользователя - CheckRole

CREATE OR REPLACE PROCEDURE CheckRole
    (pUserLogin IN USERS_T.user_login%TYPE, oUserRole OUT ROLES_T.role_name%TYPE)
IS
    CURSOR role_cursor IS 
        SELECT role_name FROM user_role_view WHERE UPPER(user_login) = UPPER(pUserLogin);
BEGIN
    OPEN role_cursor;
    FETCH role_cursor INTO oUserRole;
    CLOSE role_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Role not found!');
    WHEN OTHERS THEN
        IF role_cursor%ISOPEN THEN
            CLOSE role_cursor;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
END CheckRole;

-- ПРОЦЕДУРА 3. Авторизация пользователя - LogInUser

CREATE OR REPLACE PROCEDURE LogInUser
    (pUserLogin IN USERS_T.user_login%TYPE, pUserPassword IN USERS_T.user_password%TYPE,
        oUserId OUT USERS_T.user_id%TYPE, oUserLogin OUT USERS_T.user_login%TYPE, oUserRole OUT ROLES_T.role_name%TYPE)
IS
    CURSOR user_cursor IS 
        SELECT user_id, user_login FROM users_t 
            WHERE UPPER(user_login) = UPPER(pUserLogin) AND user_password = EncryptionPassword(UPPER(pUserPassword));
BEGIN
    OPEN user_cursor;
    FETCH user_cursor INTO oUserId, oUserLogin; 
    IF user_cursor%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Incorrect login or password!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('User found!');
    END IF;
    CLOSE user_cursor;
    CheckRole(oUserLogin, oUserRole);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'An unexpected error occurred: ' || SQLERRM);
END LogInUser;

-- ПРОЦЕДУРА 4. Поиск информации о пользователе - SearchUser

CREATE OR REPLACE PROCEDURE SearchUser
    (pUserLogin IN USERS_T.user_login%TYPE, oUserLogin OUT USERS_T.user_login%TYPE, oUserPassword OUT USERS_T.user_password%TYPE)
IS
    CURSOR user_cursor IS
        SELECT user_login, DecryptionPassword(user_password) FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
BEGIN
    OPEN user_cursor;
    FETCH user_cursor INTO oUserLogin, oUserPassword;
    IF user_cursor%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'User is not found!');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Login: ' || oUserLogin || '; Password: ' || oUserPassword);
    CLOSE user_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'User is not found!');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
END SearchUser;

-- ПРОЦЕДУРА 5. Изменение логина пользователя - UpdateUserLogin

CREATE OR REPLACE PROCEDURE UpdateUserLogin
    (pUserLogin IN USERS_T.user_login%TYPE, pNewUserLogin IN USERS_T.user_login%TYPE)
IS
    cnt NUMBER;
BEGIN
    BEGIN
        SELECT COUNT(*) INTO cnt FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
        IF cnt = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'User is not found!');
        END IF;
        SELECT COUNT(*) INTO cnt FROM users_t WHERE UPPER(user_login) = UPPER(pNewUserLogin);  
        IF cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'This login is already taken!');
        END IF;
        UPDATE users_t SET user_login = UPPER(pNewUserLogin) WHERE UPPER(user_login) = UPPER(pUserLogin);
        DBMS_OUTPUT.PUT_LINE('New login: ' || pNewUserLogin);
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20004, 'User is not found (NO_DATA_FOUND)');
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'This login is already taken (DUP_VAL_ON_INDEX)');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'An error occurred during login update: ' || SQLERRM);
    END;
END UpdateUserLogin;

-- ПРОЦЕДУРА 6. Изменение пароля пользователя - UpdateUserPassword

CREATE OR REPLACE PROCEDURE UpdateUserPassword
    (pUserLogin IN USERS_T.user_login%TYPE, pNewUserPassword IN USERS_T.user_password%TYPE)
IS
    cnt NUMBER;
BEGIN
    BEGIN
        SELECT COUNT(*) INTO cnt FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
        IF cnt = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'User is not found!');
        END IF;
        UPDATE users_t SET user_password = EncryptionPassword(UPPER(pNewUserPassword)) 
            WHERE UPPER(user_login) = UPPER(pUserLogin);
        DBMS_OUTPUT.PUT_LINE('New password: ' || EncryptionPassword(UPPER(pNewUserPassword)));
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20004, 'User is not found (NO_DATA_FOUND)');
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Duplicate value error (DUP_VAL_ON_INDEX)');
        WHEN VALUE_ERROR THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'Value error: Check input data!');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'An unexpected error occurred: ' || SQLERRM);
    END;
END UpdateUserPassword;

-- ПРОЦЕДУРА 7. Удаление аккаунта пользователя - DeleteUser

CREATE OR REPLACE PROCEDURE DeleteUser
    (pUserLogin IN USERS_T.user_login%TYPE)
IS
    cnt NUMBER;
    userRole NUMBER;
BEGIN
    -- Сначала проверим, существует ли пользователь
    SELECT user_role INTO userRole 
    FROM users_t 
    WHERE UPPER(user_login) = UPPER(pUserLogin);

    -- Проверка на роль ADMIN
    IF userRole = 2 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Cannot delete user with ADMIN role!');
    END IF;

    -- Проверка существования пользователя
    SELECT COUNT(*) INTO cnt 
    FROM users_t 
    WHERE UPPER(user_login) = UPPER(pUserLogin);

    -- Если пользователь не найден
    IF cnt = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'User is not found!');
    END IF;

    -- Удаление пользователя
    DELETE FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
    DBMS_OUTPUT.PUT_LINE('User ' || pUserLogin || ' deleted successfully!');
    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'User data could not be found during deletion!');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'An unexpected error occurred: ' || SQLERRM);
END DeleteUser;

-- ПРОЦЕДУРА 8. Добавление нового диктора - AddNarrator

CREATE OR REPLACE PROCEDURE AddNarrator
    (pNarratorName IN NARRATORS_T.narrator_name%TYPE)
IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM narrators_t WHERE UPPER(narrator_name) = UPPER(pNarratorName);
    IF (cnt = 0) THEN
        INSERT INTO narrators_t (narrator_name) VALUES (UPPER(pNarratorName));
        DBMS_OUTPUT.PUT_LINE('Narrator ' || pNarratorName || ' created successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20005, 'This name is already taken by another narrator!');
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20006, 'Duplicate entry: This narrator name already exists.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20007, 'An unexpected error occurred while adding narrator: ' || SQLERRM);
END AddNarrator;

-- ПРОЦЕДУРА 9. Добавление новой темы - AddTopic

CREATE OR REPLACE PROCEDURE AddTopic
    (pNarratorName IN NARRATORS_T.narrator_name%TYPE, pTopicName IN TOPICS_T.topic_name%TYPE, 
        pTopicReleased IN TOPICS_T.topic_released%TYPE)
IS
    narratorId NARRATORS_T.narrator_id%TYPE;
    cnt NUMBER;
BEGIN
    IF pTopicReleased < 1989 OR pTopicReleased > 2024 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Release year must be between 1989 and 2024.');
    END IF;
    SELECT COUNT(*) INTO cnt FROM narrator_topic_view
        WHERE UPPER(topic_name) = UPPER(pTopicName) AND UPPER(narrator_name) = UPPER(pNarratorName);
    IF (cnt = 0) THEN
        SELECT narrator_id INTO narratorId FROM narrators_t 
            WHERE UPPER(narrator_name) = UPPER(pNarratorName);      
        INSERT INTO topics_t (topic_narrator, topic_name, topic_released) 
            VALUES (narratorId, UPPER(pTopicName), pTopicReleased);
        DBMS_OUTPUT.PUT_LINE('Topic ' || pTopicName || ' created successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20006, 'This narrator already has this topic!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20007, 'Narrator not found!');
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20008, 'Duplicate entry: The topic already exists.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20009, 'An unexpected error occurred while adding the topic: ' || SQLERRM);
END AddTopic;

-- ПРОЦЕДУРА 10. Добавление нового подкаста - AddPodcast

CREATE OR REPLACE PROCEDURE AddPodcast
    (pNarratorName IN NARRATORS_T.narrator_name%TYPE, pTopicName IN TOPICS_T.topic_name%TYPE, pPodcastName IN PODCASTS_T.podcast_name%TYPE)
IS
    narratorId NARRATORS_T.narrator_id%TYPE;
    topicId TOPICS_T.topic_id%TYPE;
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM narrator_topic_podcast_view
        WHERE UPPER(topic_name) = UPPER(pTopicName)
        AND UPPER(narrator_name) = UPPER(pNarratorName)
        AND UPPER(podcast_name) = UPPER(pPodcastName);
    IF (cnt = 0) THEN
        SELECT narrator_id INTO narratorId FROM narrators_t WHERE UPPER(narrator_name) = UPPER(pNarratorName);
        SELECT topic_id INTO topicId FROM topics_t WHERE UPPER(topic_name) = UPPER(pTopicName);
        INSERT INTO podcasts_t (podcast_narrator, podcast_topic, podcast_name) 
            VALUES (narratorId, topicId, UPPER(pPodcastName));
        DBMS_OUTPUT.PUT_LINE('Podcast ' || pTopicName || ' created successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'This podcast + topic + narrator combo already exists!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20008, 'Narrator or topic not found!');
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20009, 'Duplicate entry: The podcast already exists.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'An unexpected error occurred while adding the podcast: ' || SQLERRM);
END AddPodcast;

-- ПРОЦЕДУРА 11. Изменение имени диктора - UpdateNarrator

CREATE OR REPLACE PROCEDURE UpdateNarrator
    (pOldNarrator IN NARRATORS_T.narrator_name%TYPE, pNewNarrator IN NARRATORS_T.narrator_name%TYPE)
IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM narrators_t WHERE UPPER(narrator_name) = UPPER(pOldNarrator);
    IF (cnt != 0) THEN
        SELECT COUNT(*) INTO cnt FROM narrators_t WHERE UPPER(narrator_name) = UPPER(pNewNarrator);
        IF (cnt = 0) THEN
            UPDATE narrators_t SET narrator_name = UPPER(pNewNarrator) WHERE UPPER(narrator_name) = UPPER(pOldNarrator);
            DBMS_OUTPUT.PUT_LINE('Narrator updated successfully!');
            COMMIT;
        ELSE
            RAISE_APPLICATION_ERROR(-20005, 'This narrator already exists!');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20008, 'Narrator is not found!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20009, 'Narrator not found during update process!');
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'Duplicate narrator name error!');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'An unexpected error occurred during narrator update: ' || SQLERRM);
END UpdateNarrator;

-- ПРОЦЕДУРА 12. Изменение названия темы - UpdateTopicName

CREATE OR REPLACE PROCEDURE UpdateTopicName
    (pTopicId IN TOPICS_T.topic_id%TYPE, pNewName IN TOPICS_T.topic_name%TYPE)
IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM topics_t WHERE topic_id = pTopicId;
    IF (cnt != 0) THEN
        UPDATE topics_t SET topic_name = UPPER(pNewName) WHERE topic_id = pTopicId;
        DBMS_OUTPUT.PUT_LINE('Topic updated successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20009, 'Topic is not found!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'No topic found with the given ID during update process.');
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'A topic with this name already exists.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20012, 'An unexpected error occurred during topic name update: ' || SQLERRM);
END UpdateTopicName;

-- ПРОЦЕДУРА 13. Изменение года выпуска темы - UpdateTopicYear

CREATE OR REPLACE PROCEDURE UpdateTopicYear
    (pTopicId IN TOPICS_T.topic_id%TYPE, pNewYear IN TOPICS_T.topic_released%TYPE)
IS
    cnt NUMBER;
BEGIN
    IF pNewYear < 1989 OR pNewYear > 2024 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Release year must be between 1989 and 2024.');
    END IF;
    SELECT COUNT(*) INTO cnt FROM topics_t WHERE topic_id = pTopicId;
    IF (cnt != 0) THEN
        UPDATE topics_t SET topic_released = pNewYear WHERE topic_id = pTopicId;
        DBMS_OUTPUT.PUT_LINE('Topic updated successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20009, 'Topic is not found!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'No topic found with the given ID during year update.');
    WHEN VALUE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Invalid year format. Please enter a valid year.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20012, 'An unexpected error occurred during topic year update: ' || SQLERRM);
END UpdateTopicYear;

-- ПРОЦЕДУРА 14. Изменение названия подкаста - UpdatePodcastName

CREATE OR REPLACE PROCEDURE UpdatePodcastName
    (pPodcastId IN PODCASTS_T.podcast_id%TYPE, pNewName IN PODCASTS_T.podcast_name%TYPE)
IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM podcasts_t WHERE podcast_id = pPodcastId;
    IF (cnt != 0) THEN
        UPDATE podcasts_t SET podcast_name = UPPER(pNewName) WHERE podcast_id = pPodcastId;
        DBMS_OUTPUT.PUT_LINE('Podcast updated successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20010, 'Podcast is not found!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'No podcast found with the given ID.');
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20012, 'A podcast with this name already exists.');
    WHEN VALUE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20013, 'Invalid input value. Please check the data format.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20014, 'An unexpected error occurred during podcast name update: ' || SQLERRM);
END UpdatePodcastName;

-- ПРОЦЕДУРА 15 (вспомогательная). Пакетная вставка - RegisterUsersBatch

CREATE OR REPLACE PROCEDURE RegisterUsersBatch
    (pUsernames IN SYS.ODCIVARCHAR2LIST, pPasswords IN SYS.ODCIVARCHAR2LIST)
IS
BEGIN
    IF pUsernames.COUNT != pPasswords.COUNT THEN
        RAISE_APPLICATION_ERROR(-20020, 'The number of usernames and passwords must be equal.');
    END IF;
    FOR i IN 1 .. pUsernames.COUNT LOOP
        BEGIN
            INSERT INTO users_t (user_login, user_password, user_role)
                VALUES (UPPER(pUsernames(i)), EncryptionPassword(UPPER(pPasswords(i))), 1);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20021, 'Username "' || pUsernames(i) || '" is already taken.');
            WHEN VALUE_ERROR THEN
                RAISE_APPLICATION_ERROR(-20022, 'Invalid data format for user "' || pUsernames(i) || '".');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20023, 'An error occurred during user registration for "' || pUsernames(i) || '": ' || SQLERRM);
        END;
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20024, 'An error occurred during batch user registration: ' || SQLERRM);
END RegisterUsersBatch;

-- ПРОЦЕДУРА 16. Добавление 100000 пользователей - Insert100KUsers

CREATE OR REPLACE PROCEDURE Insert100KUsers IS
    usernames SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST();
    passwords SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST();
    totalInserted NUMBER := 0;
BEGIN
    FOR i IN 1 .. 100000 LOOP
        usernames.EXTEND;
        passwords.EXTEND;
        usernames(usernames.COUNT) := 'user' || i;
        passwords(passwords.COUNT) := 'pass' || i;
        IF MOD(i, 1000) = 0 THEN
            BEGIN
                RegisterUsersBatch(usernames, passwords);
                COMMIT;
                totalInserted := totalInserted + usernames.COUNT;
                usernames.DELETE;
                passwords.DELETE;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    RAISE_APPLICATION_ERROR(-20030, 'An error occurred during batch insertion at iteration ' || i || ': ' || SQLERRM);
            END;
        END IF;
    END LOOP;
    IF usernames.COUNT > 0 THEN
        BEGIN
            RegisterUsersBatch(usernames, passwords);
            COMMIT;
            totalInserted := totalInserted + usernames.COUNT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE_APPLICATION_ERROR(-20031, 'An error occurred during final batch insertion: ' || SQLERRM);
        END;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Total users inserted: ' || totalInserted);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20032, 'An unexpected error occurred during Insert100KUsers: ' || SQLERRM);
END Insert100KUsers;

-- Создание директория CWDIR

CREATE OR REPLACE DIRECTORY cwdir as '/opt/oracle/cw';

-- ПРОЦЕДУРА 17. Экспорт подкастов в XML-файл - PodcastExport

CREATE OR REPLACE PROCEDURE PodcastExport IS
    rc sys_refcursor;
    doc DBMS_XMLDOM.DOMDocument;
BEGIN
    OPEN rc FOR SELECT podcast_id, podcast_name FROM podcasts_t;
    doc := DBMS_XMLDOM.NewDOMDocument(XMLTYPE(rc));
    DBMS_XMLDOM.WRITETOFILE(doc, 'CWDIR/PodcastExport.xml');
    DBMS_XMLDOM.FREEDOCUMENT(doc);
    CLOSE rc;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20050, 'No data found in podcasts_t table.');
    WHEN INVALID_CURSOR THEN
        RAISE_APPLICATION_ERROR(-20051, 'Invalid cursor detected.');
    WHEN OTHERS THEN
        IF DBMS_XMLDOM.ISNULL(doc) = FALSE THEN
            DBMS_XMLDOM.FREEDOCUMENT(doc);
        END IF;
        IF rc%ISOPEN THEN
            CLOSE rc;
        END IF;
        RAISE_APPLICATION_ERROR(-20052, 'An unexpected error occurred during PodcastExport: ' || SQLERRM);
END PodcastExport;

-- ПРОЦЕДУРА 18. Экспорт пользователей в XML-файл - UserExport

CREATE OR REPLACE PROCEDURE UserExport IS
    v_file_handle UTL_FILE.FILE_TYPE;
    CURSOR c_user IS
        SELECT user_id, user_login, decr, role_name FROM user_role_full_view;
    v_user_row c_user%ROWTYPE;
BEGIN
    v_file_handle := UTL_FILE.FOPEN('CWDIR', 'UserExport.xml', 'W');
    UTL_FILE.PUT_LINE(v_file_handle, '<?xml version="1.0" encoding="UTF-8"?>');
    UTL_FILE.PUT_LINE(v_file_handle, '<users>');
    OPEN c_user;
    LOOP
        FETCH c_user INTO v_user_row;
        EXIT WHEN c_user%NOTFOUND;
        UTL_FILE.PUT_LINE(v_file_handle, '  <user>');
        UTL_FILE.PUT_LINE(v_file_handle, '    <user_id>' || v_user_row.user_id || '</user_id>');
        UTL_FILE.PUT_LINE(v_file_handle, '    <user_login>' || v_user_row.user_login || '</user_login>');
        UTL_FILE.PUT_LINE(v_file_handle, '    <decr>' || v_user_row.decr || '</decr>');
        UTL_FILE.PUT_LINE(v_file_handle, '    <role_name>' || v_user_row.role_name || '</role_name>');
        UTL_FILE.PUT_LINE(v_file_handle, '  </user>');
    END LOOP;
    CLOSE c_user;
    UTL_FILE.PUT_LINE(v_file_handle, '</users>');
    UTL_FILE.FCLOSE(v_file_handle);
EXCEPTION
    WHEN UTL_FILE.INVALID_PATH THEN
        IF UTL_FILE.IS_OPEN(v_file_handle) THEN
            UTL_FILE.FCLOSE(v_file_handle);
        END IF;
        RAISE_APPLICATION_ERROR(-20053, 'Invalid file path specified for UserExport.');
    WHEN UTL_FILE.WRITE_ERROR THEN
        IF UTL_FILE.IS_OPEN(v_file_handle) THEN
            UTL_FILE.FCLOSE(v_file_handle);
        END IF;
        RAISE_APPLICATION_ERROR(-20054, 'Write error occurred during UserExport.');
    WHEN UTL_FILE.INVALID_OPERATION THEN
        IF UTL_FILE.IS_OPEN(v_file_handle) THEN
            UTL_FILE.FCLOSE(v_file_handle);
        END IF;
        RAISE_APPLICATION_ERROR(-20055, 'Invalid file operation in UserExport.');
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(v_file_handle) THEN
            UTL_FILE.FCLOSE(v_file_handle);
        END IF;
        RAISE_APPLICATION_ERROR(-20057, 'An unexpected error occurred during UserExport: ' || SQLERRM);
END UserExport;

-- ПРОЦЕДУРА 19. Импорт дикторов из XML-файла - NarratorImport

CREATE OR REPLACE PROCEDURE NarratorImport IS
BEGIN
    INSERT INTO narrators_t (narrator_name)
    SELECT ExtractValue(VALUE(narrator), '//NAME') AS narrator_name
        FROM TABLE(XMLSequence(EXTRACT(
            XMLTYPE(bfilename('CWDIR', 'NarratorImport.xml'), nls_charset_id('UTF-8')), '/ROWSET/ROW'))
        ) narrator;
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20060, 'No data found in NarratorImport.xml.');
    WHEN UTL_FILE.INVALID_PATH THEN
        RAISE_APPLICATION_ERROR(-20061, 'Invalid file path specified for NarratorImport.xml.');
    WHEN UTL_FILE.READ_ERROR THEN
        RAISE_APPLICATION_ERROR(-20062, 'Error reading from NarratorImport.xml.');
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20063, 'Value error occurred during NarratorImport (invalid data format).');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20064, 'An unexpected error occurred during NarratorImport: ' || SQLERRM);
END NarratorImport;

-- ПРОЦЕДУРА 20. Удаление диктора - DeleteNarrator

CREATE OR REPLACE PROCEDURE DeleteNarrator
    (pId IN NARRATORS_T.narrator_id%TYPE)
IS
    cnt NUMBER;
BEGIN
    DELETE FROM SAVED_T WHERE saved_podcast IN (SELECT podcast_id FROM PODCASTS_T WHERE podcast_narrator = pId);
    DELETE FROM PODCASTS_T WHERE podcast_narrator = pId;
    DELETE FROM TOPICS_T WHERE topic_narrator = pId;
    SELECT COUNT(*) INTO cnt FROM narrators_t WHERE narrator_id = pId;
    IF (cnt != 0) THEN
        DELETE FROM narrators_t WHERE narrator_id = pId;
        DBMS_OUTPUT.PUT_LINE('Narrator deleted successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20008, 'Narrator is not found!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
END DeleteNarrator;

-- ПРОЦЕДУРА 21. Удаление темы - DeleteTopic

CREATE OR REPLACE PROCEDURE DeleteTopic
    (pId IN TOPICS_T.topic_id%TYPE)
IS
    cnt NUMBER;
BEGIN
    DELETE FROM SAVED_T WHERE saved_podcast IN (SELECT podcast_id FROM PODCASTS_T WHERE podcast_topic = pId);
    DELETE FROM PODCASTS_T WHERE podcast_topic = pId;
    SELECT COUNT(*) INTO cnt FROM topics_t WHERE topic_id = pId;
    IF (cnt != 0) THEN
        DELETE FROM topics_t WHERE topic_id = pId;
        DBMS_OUTPUT.PUT_LINE('Topic deleted successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20009, 'Topic is not found!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'No data found during delete operation!');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
END DeleteTopic;

-- ПРОЦЕДУРА 22. Удаление подкаста - DeletePodcast

CREATE OR REPLACE PROCEDURE DeletePodcast
    (pId IN PODCASTS_T.podcast_id%TYPE)
IS
    cnt NUMBER;
BEGIN
    DELETE FROM SAVED_T WHERE saved_podcast = pId;
    SELECT COUNT(*) INTO cnt FROM podcasts_t WHERE podcast_id = pId;
    IF (cnt != 0) THEN
        DELETE FROM podcasts_t WHERE podcast_id = pId;
        DBMS_OUTPUT.PUT_LINE('Podcast deleted successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20008, 'Podcast is not found!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20009, 'No data found during delete operation!');
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20010, 'Duplicate value error occurred!');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'An unexpected error occurred: ' || SQLERRM);
END DeletePodcast;

-- ПРОЦЕДУРА 23. Удаление пользователя администратором - DeleteUserAdmin

CREATE OR REPLACE PROCEDURE DeleteUserAdmin
    (pLogin IN USERS_T.user_login%TYPE)
IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM users_t WHERE UPPER(user_login) = UPPER(pLogin);
    IF (cnt != 0) THEN
        DELETE FROM users_t WHERE UPPER(user_login) = UPPER(pLogin);
        DBMS_OUTPUT.PUT_LINE('User ' || pLogin || ' deleted successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'User is not found!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'No data found during delete operation!');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
END DeleteUserAdmin;

-- ПРОЦЕДУРА 24. Сохранение подкаста в плейлист - SavePodcast

CREATE OR REPLACE PROCEDURE SavePodcast
    (pUserId IN SAVED_T.saved_user%TYPE, pPodcastId IN SAVED_T.saved_podcast%TYPE)
IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM saved_t WHERE saved_user = pUserId AND saved_podcast = pPodcastId;
    IF (cnt = 0) THEN
        INSERT INTO saved_t (saved_user, saved_podcast) VALUES(pUserId, pPodcastId);
        DBMS_OUTPUT.PUT_LINE('Podcast saved successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20011, 'This podcast is already in the playlist!');
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20012, 'Duplicate entry error: Podcast is already saved!');
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20013, 'No data found during the save operation.');
    WHEN VALUE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20014, 'Invalid input value provided.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20015, 'An unexpected error occurred: ' || SQLERRM);
END SavePodcast;

-- ПРОЦЕДУРА 25. Удаление подкаста из плейлиста - RemovePodcast

CREATE OR REPLACE PROCEDURE RemovePodcast
    (pUserId IN SAVED_T.saved_user%TYPE, pPodcastId IN SAVED_T.saved_podcast%TYPE)
IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM saved_t WHERE saved_user = pUserId AND saved_podcast = pPodcastId;
    IF (cnt != 0) THEN
        DELETE FROM saved_t WHERE saved_user = pUserId AND saved_podcast = pPodcastId;
        DBMS_OUTPUT.PUT_LINE('Podcast unsaved successfully!');
        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20012, 'This podcast is not on the playlist!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20013, 'No matching data found during removal.');
    WHEN VALUE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20014, 'Invalid input value provided.');
    WHEN INVALID_NUMBER THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20015, 'Invalid number format in input.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20016, 'An unexpected error occurred: ' || SQLERRM);
END RemovePodcast;

-- ПРОЦЕДУРА 26. Поиск подкаста по имени диктора - SearchPodcastByNarrator

CREATE OR REPLACE PROCEDURE SearchPodcastByNarrator(
    pNarratorName IN NARRATORS_T.narrator_name%TYPE,
    oPodcastCursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT podcast_id, podcast_name, topic_name, narrator_name, topic_released
        FROM narrator_topic_podcast_view
        WHERE UPPER(narrator_name) LIKE '%' || UPPER(pNarratorName) || '%' 
        ORDER BY podcast_name ASC;
EXCEPTION
    WHEN OTHERS THEN
        IF oPodcastCursor%ISOPEN THEN
            CLOSE oPodcastCursor;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
END SearchPodcastByNarrator;

-- ПРОЦЕДУРА 27. Поиск подкаста по названию темы - SearchPodcastByTopic

CREATE OR REPLACE PROCEDURE SearchPodcastByTopic(
    pNarratorName IN NARRATORS_T.narrator_name%TYPE,
    pTopicName IN TOPICS_T.topic_name%TYPE,
    oPodcastCursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT podcast_id, podcast_name, topic_name, narrator_name, topic_released
            FROM narrator_topic_podcast_view
            WHERE UPPER(narrator_name) LIKE '%' || UPPER(pNarratorName) || '%' AND
                UPPER(topic_name) LIKE '%' || UPPER(pTopicName) || '%' 
            ORDER BY podcast_name ASC;
EXCEPTION
    WHEN OTHERS THEN
        IF oPodcastCursor%ISOPEN THEN
            CLOSE oPodcastCursor;
        END IF;
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
END SearchPodcastByTopic;

-- 28. Поиск темы - SearchTopic

CREATE OR REPLACE PROCEDURE SearchTopic
    (pTopicName IN VARCHAR2, oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT topic_id, topic_name, narrator_name, topic_released
            FROM SYS.narrator_topic_view
            WHERE UPPER(topic_name) LIKE '%' || UPPER(pTopicName) || '%'
            ORDER BY topic_name ASC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END SearchTopic;

-- 29. Поиск диктора - SearchNarrator

CREATE OR REPLACE PROCEDURE SearchNarrator
    (pNarratorName IN VARCHAR2, oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT narrator_id, narrator_name
            FROM SYS.narrators_t
            WHERE UPPER(narrator_name) LIKE '%' || UPPER(pNarratorName) || '%'
            ORDER BY narrator_name ASC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END SearchNarrator;

-- 30. Поиск подкаста по названию - SearchPodcast

CREATE OR REPLACE PROCEDURE SearchPodcast
    (pPodcastName IN VARCHAR2, oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT podcast_id, podcast_name, topic_name, narrator_name, topic_released
            FROM SYS.narrator_topic_podcast_view
            WHERE UPPER(podcast_name) LIKE '%' || UPPER(pPodcastName) || '%'
            ORDER BY podcast_name ASC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END SearchPodcast;

-- 31. Поиск подкаста в избранном - SearchPodcastByPlaylist

CREATE OR REPLACE PROCEDURE SearchPodcastByPlaylist
    (pPodcastName IN VARCHAR2, pUserId IN NUMBER, oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT podcast_id, podcast_name, topic_name, narrator_name, topic_released
            FROM SYS.narrator_topic_podcast_user_view
            WHERE UPPER(podcast_name) LIKE '%' || UPPER(pPodcastName) || '%' AND
                UPPER(user_id) = pUserId
            ORDER BY podcast_name ASC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END SearchPodcastByPlaylist;

-- 32. Заполнение выпадающего списка с дикторами - FillNarrators

CREATE OR REPLACE PROCEDURE FillNarrators
    (oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT narrator_name FROM SYS.narrators_t ORDER BY narrator_name ASC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END FillNarrators;

-- 33. Заполнение выпадающего списка с темами - FillTopics

CREATE OR REPLACE PROCEDURE FillTopics
    (pNarratorName IN VARCHAR2, oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT topic_name FROM SYS.narrator_topic_view
            WHERE upper(narrator_name) = pNarratorName ORDER BY topic_name ASC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END FillTopics;

-- 34. Удаление 100000 пользователей - Delete100KUsers

CREATE OR REPLACE PROCEDURE Delete100KUsers
IS
    v_deleted_count NUMBER;
BEGIN
    DELETE FROM SYS.users_t WHERE user_login LIKE 'USER%';
    v_deleted_count := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Total users deleted: ' || v_deleted_count);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while deleting users: ' || SQLERRM);
END Delete100KUsers;

-- 35. Получение обложки темы - GetTopicBlob

CREATE OR REPLACE PROCEDURE GetTopicBlob
    (pTopicId IN NUMBER, oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT topic_blob FROM SYS.narrator_topic_view WHERE topic_id = pTopicId;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END GetTopicBlob;

-- 36. Получение обложки подкаста - GetPodcastBlob

CREATE OR REPLACE PROCEDURE GetPodcastBlob
    (pPodcastId IN NUMBER, oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT topic_blob FROM SYS.narrator_topic_podcast_view WHERE podcast_id = pPodcastId;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END GetPodcastBlob;

-- 37. Получение аудиодорожки подкаста - GetPodcastAudio

CREATE OR REPLACE PROCEDURE GetPodcastAudio
    (pPodcastId IN NUMBER, oPodcastCursor OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN oPodcastCursor FOR
        SELECT podcast_blob FROM SYS.podcasts_t WHERE podcast_id = pPodcastId;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END GetPodcastAudio;

-- 38. Добавление обложки к теме

CREATE OR REPLACE PROCEDURE LoadImageToBlob(p_topic_name IN VARCHAR2, p_image_path IN VARCHAR2) IS
    src_lob BFILE := BFILENAME('CWDIR', p_image_path);
    dest_lob BLOB;
BEGIN
    UPDATE topics_t SET topic_blob = EMPTY_BLOB() 
        WHERE topic_name = UPPER(p_topic_name) RETURNING topic_blob INTO dest_lob;
    DBMS_LOB.OPEN(src_lob, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.LoadFromFile(DEST_LOB => dest_lob,
                         SRC_LOB  => src_lob,
                         AMOUNT   => DBMS_LOB.GETLENGTH(src_lob));
    DBMS_LOB.CLOSE(src_lob);
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No records found with topic_name = ' || p_topic_name);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END LoadImageToBlob;
