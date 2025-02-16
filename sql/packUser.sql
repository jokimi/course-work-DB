CREATE OR REPLACE PACKAGE UserPackage AS
    PROCEDURE RegisterUser(
        pUserLogin IN USERS_T.user_login%TYPE,
        pUserPassword IN USERS_T.user_password%TYPE
    );
    PROCEDURE CheckRole(
        pUserLogin IN USERS_T.user_login%TYPE,
        oUserRole OUT ROLES_T.role_name%TYPE
    );
    PROCEDURE LogInUser(
        pUserLogin IN USERS_T.user_login%TYPE,
        pUserPassword IN USERS_T.user_password%TYPE,
        oUserId OUT USERS_T.user_id%TYPE,
        oUserLogin OUT USERS_T.user_login%TYPE,
        oUserRole OUT ROLES_T.role_name%TYPE
    );
    PROCEDURE UpdateUserLogin(
        pUserLogin IN USERS_T.user_login%TYPE,
        pNewUserLogin IN USERS_T.user_login%TYPE
    );
    PROCEDURE UpdateUserPassword(
        pUserLogin IN USERS_T.user_login%TYPE,
        pNewUserPassword IN USERS_T.user_password%TYPE
    );
    PROCEDURE SavePodcast(
        pUserId IN SAVED_T.saved_user%TYPE,
        pPodcastId IN SAVED_T.saved_podcast%TYPE
    );
    PROCEDURE RemovePodcast(
        pUserId IN SAVED_T.saved_user%TYPE,
        pPodcastId IN SAVED_T.saved_podcast%TYPE
    );
    PROCEDURE DeleteUser(
        pUserLogin IN USERS_T.user_login%TYPE
    );
    PROCEDURE SearchPodcastByNarrator(
        pNarratorName IN VARCHAR2,
        oCursor OUT SYS_REFCURSOR
    );
    PROCEDURE SearchPodcastByTopic(
        pTopicName IN VARCHAR2,
        oCursor OUT SYS_REFCURSOR
    );
    PROCEDURE SearchPodcastByName(
        pPodcastName IN VARCHAR2,
        oCursor OUT SYS_REFCURSOR
    );
END UserPackage;
CREATE OR REPLACE PACKAGE BODY UserPackage AS

    -- 1. Регистрация пользователя

    PROCEDURE RegisterUser
        (pUserLogin IN USERS_T.user_login%TYPE, pUserPassword IN USERS_T.user_password%TYPE)
    IS
        cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO cnt FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
        IF (cnt = 0) THEN
            INSERT INTO users_t (user_login, user_password, user_role)
                VALUES(UPPER(pUserLogin), EncryptionPassword(UPPER(pUserPassword)), 1);
            COMMIT;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'This login is already taken!');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'An error occurred during registration: ' || SQLERRM);
    END RegisterUser;
    
    -- 2. Проверка роли
    
    PROCEDURE CheckRole
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
    
    -- 3. Авторизация пользователя
    
    PROCEDURE LogInUser
        (pUserLogin IN USERS_T.user_login%TYPE, pUserPassword IN USERS_T.user_password%TYPE,
            oUserId OUT USERS_T.user_id%TYPE, oUserLogin OUT USERS_T.user_login%TYPE, oUserRole OUT ROLES_T.role_name%TYPE)
    IS
        CURSOR user_cursor IS 
            SELECT user_id, user_login FROM users_t 
                WHERE UPPER(user_login) = UPPER(pUserLogin) AND user_password = EncryptionPassword(UPPER(pUserPassword));
    BEGIN
        DBMS_OUTPUT.PUT_LINE('LogInUser: Checking user ' || pUserLogin);
        OPEN user_cursor;
        FETCH user_cursor INTO oUserId, oUserLogin; 
        IF user_cursor%NOTFOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Incorrect login or password!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('User found: ' || oUserLogin);
        END IF;
        CLOSE user_cursor;
        DBMS_OUTPUT.PUT_LINE('Checking user ' || oUserLogin || '`s role');
        CheckRole(oUserLogin, oUserRole);
        DBMS_OUTPUT.PUT_LINE('User role: ' || oUserRole);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20003, 'Ошибка в процедуре LogInUser: ' || SQLERRM);
    END LogInUser;
    
    -- 4. Изменение логина пользователя
    
    PROCEDURE UpdateUserLogin
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
    
    -- 5. Изменение пароля пользователя
    
    PROCEDURE UpdateUserPassword
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
    
    -- 6. Сохранение подкаста в избранное
    
    PROCEDURE SavePodcast
        (pUserId IN SAVED_T.saved_user%TYPE, pPodcastId IN SAVED_T.saved_podcast%TYPE)
    IS
        cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO cnt FROM saved_t WHERE saved_user = pUserId AND saved_podcast = pPodcastId;
        IF (cnt = 0) THEN
            INSERT INTO saved_t (saved_user, saved_podcast) VALUES(pUserId, pPodcastId);
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
    
    -- 7. Удаление подкаста из избранного
    
    PROCEDURE RemovePodcast
        (pUserId IN SAVED_T.saved_user%TYPE, pPodcastId IN SAVED_T.saved_podcast%TYPE)
    IS
        cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO cnt FROM saved_t WHERE saved_user = pUserId AND saved_podcast = pPodcastId;
        IF (cnt != 0) THEN
            DELETE FROM saved_t WHERE saved_user = pUserId AND saved_podcast = pPodcastId;
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
    
    -- 8. Удаление аккаунта пользователем
    
    PROCEDURE DeleteUser
        (pUserLogin IN USERS_T.user_login%TYPE)
    IS
        cnt NUMBER;
        userId USERS_T.user_id%TYPE;
    BEGIN
        SELECT COUNT(*) INTO cnt FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
        IF (cnt != 0) THEN
            SELECT user_id INTO userId FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
            DELETE FROM users_t WHERE UPPER(user_login) = UPPER(pUserLogin);
            COMMIT;
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'User is not found!');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20004, 'User data could not be found during deletion!');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'An unexpected error occurred: ' || SQLERRM);
    END DeleteUser;
    
    -- 9. 
    
    PROCEDURE SearchNarratorPodcast(pNarratorName IN VARCHAR2, oCursor OUT SYS_REFCURSOR) IS
BEGIN
    OPEN o_cursor FOR
        SELECT *
        FROM SYS.narrator_topic_podcast_view
        WHERE UPPER(narrator_name) LIKE '%' || UPPER(p_search) || '%'
        ORDER BY podcast_name ASC;

EXCEPTION
    WHEN OTHERS THEN
        -- Обработка всех остальных ошибок
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred while searching: ' || SQLERRM);
END SearchNarratorPodcast;
    
END UserPackage;