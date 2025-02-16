ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
ALTER SESSION SET CONTAINER = PodSproutPDB;
ALTER PLUGGABLE DATABASE PodSproutPDB OPEN;
ALTER SYSTEM FLUSH SHARED_POOL;

-- 1. Регистрация

BEGIN
   RegisterUser('usr0000', '0000');
END;

-- 2. Вход

DECLARE
    vUserId USERS_T.user_id%TYPE;
    vUserLogin USERS_T.user_login%TYPE;
    vUserRole ROLES_T.role_name%TYPE;
BEGIN
    LogInUser('usr0000', '0000', vUserId, vUserLogin, vUserRole);
    DBMS_OUTPUT.PUT_LINE('User ID: ' || vUserId);
    DBMS_OUTPUT.PUT_LINE('User Login: ' || vUserLogin);
    DBMS_OUTPUT.PUT_LINE('User Role: ' || vUserRole);
END;

-- 3. Поиск пользователя

DECLARE
    vUserLogin USERS_T.user_login%TYPE;
    vUserPassword USERS_T.user_password%TYPE;
BEGIN
    SearchUser('usr0000', vUserLogin, vUserPassword);
END;

-- 4. Изменение логина пользователя

DECLARE
    vUserLogin USERS_T.user_login%TYPE;
    vNewUserLogin USERS_T.user_login%TYPE;
BEGIN
    UpdateUserLogin('usr0000', 'usr2024');
END;

-- 5. Изменение пароля пользователя

DECLARE
    vUserLogin USERS_T.user_login%TYPE;
    vNewUserPassword USERS_T.user_password%TYPE;
BEGIN
    UpdateUserPassword('usr2024', '2024');
END;

-- 6. Удаление пользователя

SELECT * FROM users_t;
DECLARE
    vUserLogin USERS_T.user_login%TYPE;
BEGIN
    DeleteUser('WGRFDSBDGH');
END;

-- 7. Добавление нового диктора

SELECT * FROM narrators_t;
DECLARE
    vNarratorName NARRATORS_T.narrator_name%TYPE;
BEGIN
    AddNarrator('new');
END;

-- 8. Добавление новой темы

SELECT * FROM topics_t;
DECLARE
    vNarratorName NARRATORS_T.narrator_name%TYPE;
    vTopicName TOPICS_T.topic_name%TYPE;
    vTopicReleased TOPICS_T.topic_released%TYPE;
BEGIN
    AddTopic('new', 'new topic', 2014);
END;

BEGIN
    LoadImageToBlob('NEW TOPIC', 'image.jpg');
END;

-- 9. Добавление нового подкаста

SELECT * FROM podcasts_t;
DECLARE
    vNarratorName NARRATORS_T.narrator_name%TYPE;
    vTopicName TOPICS_T.topic_name%TYPE;
    vPodcastName PODCASTS_T.podcast_name%TYPE;
BEGIN
    AddPodcast('new', 'new topic', 'podcast');
END;

-- 10. Изменение имени диктора

SELECT * FROM narrators_t;
DECLARE
    vNarratorName NARRATORS_T.narrator_name%TYPE;
    vNewNarratorName NARRATORS_T.narrator_name%TYPE;
BEGIN
    UpdateNarrator('new', 'newer');
END;

-- 11. Изменение названия темы

SELECT * FROM topics_t;
DECLARE
    vTopicId TOPICS_T.topic_id%TYPE;
    vNewName TOPICS_T.topic_name%TYPE;
BEGIN
    UpdateTopicName(161, 'newer topic');
END;

-- 12. Изменение года выпуска темы

SELECT * FROM topics_t;
DECLARE
    vTopicId TOPICS_T.topic_id%TYPE;
    vNewYear TOPICS_T.topic_released%TYPE;
BEGIN
    UpdateTopicYear(161, 2023);
END;

-- 13. Изменение названия подкаста

SELECT * FROM podcasts_t;
DECLARE
    vPodcastId PODCASTS_T.podcast_id%TYPE;
    vNewName PODCASTS_T.podcast_name%TYPE;
BEGIN
    UpdatePodcastName(181, 'new name');
END;

-- 14. Добавление 100000 пользователей

BEGIN
    Insert100KUsers();
END;
COMMIT;
SELECT COUNT(*) FROM users_t;

-- 15. Экспорт подкастов в XML-файл

BEGIN
    PodcastExport();
END;

-- 16. Экспорт пользователей в XML-файл

BEGIN
    UserExport();
END;

-- 17. Импорт дикторов из XML-файла

BEGIN
    NarratorImport();
END;

-- 18. Удаление диктора

SELECT * FROM narrators_t;
DECLARE
    vNarratorId NARRATORS_T.narrator_id%TYPE;
BEGIN
    DeleteNarrator(161);
END;

-- 19. Удаление темы

SELECT * FROM topics_t;
DECLARE
    vTopicId TOPICS_T.topic_id%TYPE;
BEGIN
    DeleteTopic(161);
END;

-- 20. Удаление подкаста

SELECT * FROM podcasts_t;
DECLARE
    vPodcastId PODCASTS_T.podcast_id%TYPE;
BEGIN
    DeletePodcast(181);
END;

-- 21. Сохранение подкаста в плейлист

SELECT * FROM users_t;
SELECT * FROM podcasts_t;
SELECT * FROM saved_t;
DECLARE
    vUserId SAVED_T.saved_user%TYPE;
    vPodcastId SAVED_T.saved_podcast%TYPE;
BEGIN
    SavePodcast(1, 162);
END;

-- 22. Удаление подкаста из плейлиста

SELECT * FROM users_t;
SELECT * FROM podcasts_t;
SELECT * FROM saved_t;
DECLARE
    vUserId SAVED_T.saved_user%TYPE;
    vPodcastId SAVED_T.saved_podcast%TYPE;
BEGIN
    RemovePodcast(129547, 62);
END;

-- 22. Поиск подкаста по имени диктора

DECLARE
    v_cursor SYS_REFCURSOR;
    v_podcast_id PODCASTS_T.podcast_id%TYPE;
    v_podcast_name PODCASTS_T.podcast_name%TYPE;
    v_topic_name TOPICS_T.topic_name%TYPE;
    v_narrator_name NARRATORS_T.narrator_name%TYPE;
    v_topic_released TOPICS_T.topic_released%TYPE;
BEGIN
    SearchPodcastByNarrator('astronaut', v_cursor);
    LOOP
        FETCH v_cursor INTO v_podcast_id, v_podcast_name, v_topic_name, v_narrator_name, v_topic_released;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Podcast ID: ' || v_podcast_id || ', Name: ' || v_podcast_name || 
                             ', Topic: ' || v_topic_name || ', Narrator: ' || v_narrator_name || ', Year: ' || v_topic_released);
    END LOOP;
    CLOSE v_cursor;
END;

-- 24. Поиск подкаста по названию темы

DECLARE
    v_cursor SYS_REFCURSOR;
    v_podcast_id PODCASTS_T.podcast_id%TYPE;
    v_podcast_name PODCASTS_T.podcast_name%TYPE;
    v_topic_name TOPICS_T.topic_name%TYPE;
    v_narrator_name NARRATORS_T.narrator_name%TYPE;
    v_topic_released TOPICS_T.topic_released%TYPE;
BEGIN
    SearchPodcastByTopic('astronaut', 'great scientists', v_cursor);
    LOOP
        FETCH v_cursor INTO v_podcast_id, v_podcast_name, v_topic_name, v_narrator_name, v_topic_released;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Podcast ID: ' || v_podcast_id || ', Name: ' || v_podcast_name || 
                             ', Topic: ' || v_topic_name || ', Narrator: ' || v_narrator_name || ', Year: ' || v_topic_released);
    END LOOP;
    CLOSE v_cursor;
END;

-- 25. Поиск диктора

DECLARE
    oPodcastCursor SYS_REFCURSOR;
    v_narrator_id NUMBER;
    v_narrator_name VARCHAR2(255);
BEGIN
    SearchNarrator('astro', oPodcastCursor);
    LOOP
        FETCH oPodcastCursor INTO v_narrator_id, v_narrator_name;
        EXIT WHEN oPodcastCursor%NOTFOUND;   
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_narrator_id || ', Name: ' || v_narrator_name);
    END LOOP;
    CLOSE oPodcastCursor;
END;

-- 26. Поиск темы

DECLARE
    oPodcastCursor SYS_REFCURSOR;
    v_topic_id NUMBER;
    v_topic_name VARCHAR2(255);
    v_narrator_name VARCHAR2(255);
    v_topic_released NUMBER;
BEGIN
    SearchTopic('great', oPodcastCursor);
    LOOP
        FETCH oPodcastCursor INTO v_topic_id, v_topic_name, v_narrator_name, v_topic_released;
        EXIT WHEN oPodcastCursor%NOTFOUND;    
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_topic_id || ', Name: ' || v_topic_name || 
                             ', Narrator: ' || v_narrator_name || ', Release: ' || v_topic_released);
    END LOOP;
    CLOSE oPodcastCursor;
END;

-- 27. Поиск подкаста по названию

DECLARE
    v_cursor SYS_REFCURSOR;
    v_podcast_id SYS.narrator_topic_podcast_view.podcast_id%TYPE;
    v_podcast_name SYS.narrator_topic_podcast_view.podcast_name%TYPE;
    v_topic_name SYS.narrator_topic_podcast_view.topic_name%TYPE;
    v_narrator_name SYS.narrator_topic_podcast_view.narrator_name%TYPE;
    v_topic_released SYS.narrator_topic_podcast_view.topic_released%TYPE;
BEGIN
    SearchPodcast('', v_cursor);
    LOOP
        FETCH v_cursor INTO v_podcast_id, v_podcast_name, v_topic_name, v_narrator_name, v_topic_released;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Podcast ID: ' || v_podcast_id || ', Name: ' || v_podcast_name || 
                             ', Topic: ' || v_topic_name || ', Narrator: ' || v_narrator_name || ', Year: ' || v_topic_released);
    END LOOP;
    CLOSE v_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END;

-- 28. Поиск подкаста в избранном

DECLARE
    v_cursor SYS_REFCURSOR;
    v_podcast_id SYS.narrator_topic_podcast_view.podcast_id%TYPE;
    v_podcast_name SYS.narrator_topic_podcast_view.podcast_name%TYPE;
    v_topic_name SYS.narrator_topic_podcast_view.topic_name%TYPE;
    v_narrator_name SYS.narrator_topic_podcast_view.narrator_name%TYPE;
    v_topic_released SYS.narrator_topic_podcast_view.topic_released%TYPE;
BEGIN
    SearchPodcastByPlaylist('', 1, v_cursor);
    LOOP
        FETCH v_cursor INTO v_podcast_id, v_podcast_name, v_topic_name, v_narrator_name, v_topic_released;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Podcast ID: ' || v_podcast_id || ', Name: ' || v_podcast_name || 
                             ', Topic: ' || v_topic_name || ', Narrator: ' || v_narrator_name || ', Year: ' || v_topic_released);
    END LOOP;
    CLOSE v_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- 29. Удаление 100000 пользователей

BEGIN
    Delete100KUsers();
END;
