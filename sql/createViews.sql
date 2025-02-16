ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
select * from user_views;

CREATE VIEW user_role_view AS
    SELECT USERS_T.user_login, USERS_T.user_password, ROLES_T.role_name
    FROM USERS_T
    LEFT JOIN ROLES_T ON USERS_T.user_role = ROLES_T.role_id;
SELECT * FROM user_role_view;

CREATE VIEW user_role_full_view AS
    SELECT USERS_T.user_id, USERS_T.user_login, DecryptionPassword(USERS_T.user_password) as decr, ROLES_T.role_name
    FROM users_t LEFT JOIN roles_t ON USERS_T.user_role = ROLES_T.role_id;
SELECT * FROM user_role_full_view;

CREATE VIEW narrator_topic_view AS
    SELECT TOPICS_T.topic_id, NARRATORS_T.narrator_name, TOPICS_T.topic_name, TOPICS_T.topic_released, TOPICS_T.topic_blob
    FROM narrators_t JOIN topics_t ON NARRATORS_T.narrator_id = TOPICS_T.topic_narrator;
SELECT * FROM narrator_topic_view;

CREATE VIEW narrator_topic_podcast_view AS
    SELECT PODCASTS_T.podcast_id, NARRATORS_T.narrator_name, TOPICS_T.topic_name, PODCASTS_T.podcast_name,
        TOPICS_T.topic_released, TOPICS_T.topic_blob, PODCASTS_T.podcast_blob
    FROM narrators_t
    JOIN topics_t ON NARRATORS_T.narrator_id = TOPICS_T.topic_narrator
    JOIN podcasts_t on PODCASTS_T.podcast_topic = TOPICS_T.topic_id;
SELECT * FROM narrator_topic_podcast_view ORDER BY podcast_name ASC;
COMMIT;

CREATE VIEW narrator_topic_podcast_user_view AS
    SELECT USERS_T.user_id, PODCASTS_T.podcast_id, NARRATORS_T.narrator_name, 
        TOPICS_T.topic_name, PODCASTS_T.podcast_name, TOPICS_T.topic_released, 
        TOPICS_T.topic_blob, PODCASTS_T.podcast_blob
FROM narrators_t JOIN topics_t ON NARRATORS_T.narrator_id = TOPICS_T.topic_narrator
    JOIN podcasts_t on PODCASTS_T.podcast_topic = TOPICS_T.topic_id JOIN saved_t on PODCASTS_T.podcast_id = SAVED_T.saved_podcast
    JOIN users_t on SAVED_T.saved_user = USERS_T.user_id;
SELECT * FROM narrator_topic_podcast_user_view;
