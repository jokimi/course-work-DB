
-- TABLES

DROP TABLE saved_t;
DROP TABLE podcasts_t;
DROP TABLE topics_t;
DROP TABLE narrators_t;
DROP TABLE users_t;
DROP TABLE roles_t;

-- VIEWS

DROP VIEW user_role_view;
DROP VIEW user_role_full_view;
DROP VIEW narrator_topic_view;
DROP VIEW narrator_topic_podcast_view;
DROP VIEW narrator_topic_podcast_user_view;

-- FUNCTIONS & PROCEDURES

DROP FUNCTION EncryptionPassword;
DROP FUNCTION DecryptionPassword;
DROP PROCEDURE RegisterUser;
DROP PROCEDURE CheckRole;
DROP PROCEDURE LogInUser;
DROP PROCEDURE SearchUser;
DROP PROCEDURE UpdateUserLogin;
DROP PROCEDURE UpdateUserPassword;
DROP PROCEDURE DeleteUser;
DROP PROCEDURE AddNarrator;
DROP PROCEDURE AddTopic;
DROP PROCEDURE AddPodcast;
DROP PROCEDURE UpdateNarrator;
DROP PROCEDURE UpdateTopicName;
DROP PROCEDURE UpdateTopicYear;
DROP PROCEDURE UpdatePodcastName;
DROP PROCEDURE RegisterUsersBatch;
DROP PROCEDURE Insert100KUsers;
DROP PROCEDURE PodcastExport;
DROP PROCEDURE UserExport;
DROP PROCEDURE NarratorImport;
DROP PROCEDURE DeleteNarrator;
DROP PROCEDURE DeleteTopic;
DROP PROCEDURE DeletePodcast;
DROP PROCEDURE SavePodcast;
DROP PROCEDURE RemovePodcast;
DROP PROCEDURE SearchPodcastByNarrator;
DROP PROCEDURE SearchPodcastByTopic;
DROP PROCEDURE SearchNarrator;
DROP PROCEDURE SearchTopic;
DROP PROCEDURE SearchPodcast;
DROP PROCEDURE SearchPodcastByPlaylist;
DROP PROCEDURE FillNarrators;
DROP PROCEDURE FillTopics;
DROP PROCEDURE Delete100KUsers;

-- CWDIR

DROP DIRECTORY cwdir;
