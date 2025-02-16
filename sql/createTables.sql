
------------------------------------ ROLES ------------------------------------

CREATE TABLE roles_t (
    role_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    role_name VARCHAR2(30) NOT NULL,
    CONSTRAINT role_pk PRIMARY KEY (role_id)
);

INSERT INTO roles_t(role_name) VALUES('USER');
INSERT INTO roles_t(role_name) VALUES('ADMIN');

SELECT * FROM roles_t;

------------------------------------ USERS ------------------------------------

CREATE TABLE users_t (
    user_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    user_login VARCHAR2(30) NOT NULL,
    user_password VARCHAR2(200) NOT NULL,
    user_role NUMBER(10) NOT NULL,
    CONSTRAINT user_pk PRIMARY KEY (user_id),
    CONSTRAINT user_role_fk FOREIGN KEY (user_role) REFERENCES roles_t(role_id)
);

INSERT INTO users_t(user_login, user_password, user_role) values('sprout', 'sprout', 2);

SELECT * FROM users_t;
DELETE FROM users_t;

---------------------------------- NARRATORS ----------------------------------

CREATE TABLE narrators_t (
    narrator_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    narrator_name VARCHAR2(30) NOT NULL,
    CONSTRAINT narrator_pk PRIMARY KEY (narrator_id)
);

INSERT INTO narrators_t(narrator_name) VALUES('Sprouter');

SELECT * FROM narrators_t;

----------------------------------- TOPICS ------------------------------------

CREATE TABLE topics_t (
    topic_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    topic_narrator NUMBER(10) NOT NULL,
    topic_name VARCHAR2(30) NOT NULL,
    topic_released NUMBER(10) NOT NULL,
    topic_blob BLOB DEFAULT EMPTY_BLOB(),
    CONSTRAINT topic_pk PRIMARY KEY (topic_id),
    CONSTRAINT topic_narrator_fk FOREIGN KEY (topic_narrator) REFERENCES narrators_t(narrator_id)
);

SELECT * FROM topics_t;

---------------------------------- PODCASTS -----------------------------------

CREATE TABLE podcasts_t (
    podcast_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    podcast_narrator NUMBER(10) NOT NULL,
    podcast_topic NUMBER(10) NOT NULL,
    podcast_name VARCHAR2(30) NOT NULL,
    podcast_blob BLOB DEFAULT EMPTY_BLOB(),
    CONSTRAINT podcast_pk PRIMARY KEY (podcast_id),
    CONSTRAINT podcast_narrator_fk FOREIGN KEY (podcast_narrator) REFERENCES narrators_t(narrator_id),
    CONSTRAINT podcast_topic_fk FOREIGN KEY (podcast_topic) REFERENCES topics_t(topic_id)
);

SELECT * FROM podcasts_t;

------------------------------------ SAVED ------------------------------------

CREATE TABLE saved_t (
    saved_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    saved_user NUMBER(10) NOT NULL,
    saved_podcast NUMBER(10) NOT NULL,
    CONSTRAINT saved_pk PRIMARY KEY (saved_id),
    CONSTRAINT saved_user_fk FOREIGN KEY (saved_user) REFERENCES users_t(user_id),
    CONSTRAINT saved_podcast_fk FOREIGN KEY (saved_podcast) REFERENCES podcasts_t(podcast_id)
);

SELECT * FROM saved_t;