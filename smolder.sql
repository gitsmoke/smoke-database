PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE db_version (
  db_version TEXT NOT NULL
);
INSERT INTO "db_version" VALUES('1.51');
CREATE TABLE developer (
    id          INTEGER PRIMARY KEY AUTOINCREMENT, 
    username    TEXT DEFAULT '', 
    fname       TEXT DEFAULT '',
    lname       TEXT DEFAULT '',
    email       TEXT DEFAULT '',
    password    TEXT DEFAULT '',
    admin       INTEGER DEFAULT 0,
    preference  INTEGER NOT NULL, 
    guest       INTEGER DEFAULT 0,
    CONSTRAINT 'fk_developer_preference' FOREIGN KEY ('preference') REFERENCES 'preference' ('id')
);
INSERT INTO "developer" VALUES(1,'avar','AEvar','Arnfjord Bjarmason','avarab+smolder@gmail.com','ZcuV/MNSUiwjE',1,1,0);
INSERT INTO "developer" VALUES(2,'anonymous','','','','',0,2,1);
CREATE TABLE preference (
    id          INTEGER PRIMARY KEY AUTOINCREMENT, 
    email_type  TEXT DEFAULT 'full',
    email_freq  TEXT DEFAULT 'on_new',
    email_limit INT DEFAULT 0,
    email_sent  INT DEFAULT 0,
    email_sent_timestamp INTEGER,
    show_passing INT DEFAULT 1
);
INSERT INTO "preference" VALUES(1,'full','on_new',0,0,NULL,1);
INSERT INTO "preference" VALUES(2,'full','on_new',0,0,NULL,1);
CREATE TABLE project (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT, 
    name                TEXT NOT NULL,
    start_date          INTEGER NOT NULL,
    public              INTEGER DEFAULT 1,
    enable_feed         INTEGER DEFAULT 1,
    default_platform    TEXT DEFAULT '',
    default_arch        TEXT DEFAULT '',
    graph_start         TEXT DEFAULT 'project',
    allow_anon          INTEGER DEFAULT 0,
    max_reports         INTEGER DEFAULT 100,
    extra_css           TEXT DEFAULT ''
);
INSERT INTO "project" VALUES(1,'Git','2010-07-30 00:00:00',1,1,'','','project',0,99999999,'');
CREATE TABLE project_developer (
    project     INTEGER NOT NULL, 
    developer   INTEGER NOT NULL,
    preference  INTEGER,
    admin       INTEGER DEFAULT 0,
    added       INTEGER DEFAULT 0,
    PRIMARY KEY (project, developer),
    CONSTRAINT 'fk_project_developer_project' FOREIGN KEY ('project') REFERENCES 'project' ('id') ON DELETE CASCADE,
    CONSTRAINT 'fk_project_developer_developer' FOREIGN KEY ('developer') REFERENCES 'developer' ('id') ON DELETE CASCADE,
    CONSTRAINT 'fk_project_developer_preference' FOREIGN KEY ('preference') REFERENCES 'preference' ('id')
);
CREATE TABLE smoke_report  (
    id              INTEGER PRIMARY KEY AUTOINCREMENT, 
    project         INTEGER NOT NULL, 
    developer       INTEGER NOT NULL, 
    added           INTEGER NOT NULL,
    architecture    TEXT DEFAULT '',
    platform        TEXT DEFAULT '',
    pass            INTEGER DEFAULT 0,
    fail            INTEGER DEFAULT 0,
    skip            INTEGER DEFAULT 0,
    todo            INTEGER DEFAULT 0,
    todo_pass       INTEGER DEFAULT 0,
    test_files      INTEGER DEFAULT 0,
    total           INTEGER DEFAULT 0,
    comments        BLOB DEFAULT '',
    invalid         INTEGER DEFAULT 0,
    invalid_reason  BLOB DEFAULT '',
    duration        INTEGER DEFAULT 0,
    purged          INTEGER DEFAULT 0,
    failed          INTEGER DEFAULT 0,
    revision        TEXT DEFAULT '',
    CONSTRAINT 'fk_smoke_report_project' FOREIGN KEY ('project') REFERENCES 'project' ('id') ON DELETE CASCADE,
    CONSTRAINT 'fk_smoke_report_developer' FOREIGN KEY ('developer') REFERENCES 'developer' ('id') ON DELETE CASCADE
);
CREATE TABLE smoke_report_tag  (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    smoke_report    INTEGER NOT NULL,
    tag             TEXT DEFAULT '',
    CONSTRAINT 'fk_smoke_report_tag_smoke_report' FOREIGN KEY ('smoke_report') REFERENCES 'smoke_report' ('id') ON DELETE CASCADE
);
CREATE TABLE test_file  (
    id              INTEGER PRIMARY KEY AUTOINCREMENT, 
    project         INTEGER NOT NULL, 
    label           TEXT DEFAULT '',
    mute_until      INTEGER,
    CONSTRAINT 'fk_test_file_project' FOREIGN KEY ('project') REFERENCES 'project' ('id') ON DELETE CASCADE
);
CREATE TABLE test_file_comment  (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    project         INTEGER NOT NULL,
    test_file       INTEGER NOT NULL,
    developer       INTEGER NOT NULL,
    added           INTEGER NOT NULL,
    comment         TEXT DEFAULT '',
    CONSTRAINT 'fk_test_file_comment_project' FOREIGN KEY ('project') REFERENCES 'project' ('id') ON DELETE CASCADE,
    CONSTRAINT 'fk_test_file_comment_test_file' FOREIGN KEY ('test_file') REFERENCES 'test_file' ('id') ON DELETE CASCADE,
    CONSTRAINT 'fk_test_file_comment_developer' FOREIGN KEY ('developer') REFERENCES 'developer' ('id') ON DELETE CASCADE
);
CREATE TABLE test_file_result  (
    id              INTEGER PRIMARY KEY AUTOINCREMENT, 
    project         INTEGER NOT NULL, 
    test_file       INTEGER NOT NULL,
    smoke_report    INTEGER NOT NULL,
    file_index      INTEGER NOT NULL,
    total           INTEGER NOT NULL,
    failed          INTEGER NOT NULL,
    percent         INTEGER NOT NULL,
    added           INTEGER NOT NULL,
    CONSTRAINT 'fk_test_file_result_project' FOREIGN KEY ('project') REFERENCES 'project' ('id') ON DELETE CASCADE,
    CONSTRAINT 'fk_test_file_result_test_file' FOREIGN KEY ('test_file') REFERENCES 'test_file' ('id') ON DELETE CASCADE,
    CONSTRAINT 'fk_test_file_result_smoke_report' FOREIGN KEY ('smoke_report') REFERENCES 'smoke_report' ('id') ON DELETE CASCADE
);
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('developer',2);
INSERT INTO "sqlite_sequence" VALUES('preference',2);
INSERT INTO "sqlite_sequence" VALUES('project',1);
CREATE INDEX i_preference_developer on developer (preference);
CREATE UNIQUE INDEX unique_username_developer on developer (username);
CREATE UNIQUE INDEX i_project_name_project on project (name);
CREATE INDEX i_developer_project_developer on project_developer (developer);
CREATE INDEX i_project_project_developer on project_developer (project);
CREATE INDEX i_preference_project_developer on project_developer (preference);
CREATE INDEX i_project_smoke_report ON smoke_report (project);
CREATE INDEX i_developer_smoke_report ON smoke_report (developer);
CREATE INDEX i_project_smoke_tag_tag ON smoke_report_tag (tag);
CREATE INDEX i_report_smoke_report_tag ON smoke_report_tag (smoke_report, tag);
CREATE INDEX i_test_file_project ON test_file (project);
CREATE INDEX i_test_file_comment_project ON test_file_comment (project);
CREATE INDEX i_test_file_comment_test_file ON test_file_comment (test_file);
CREATE INDEX i_test_file_comment_developer ON test_file_comment (developer);
CREATE INDEX i_test_file_result_project_test_file ON test_file_result (project, test_file);
CREATE INDEX i_test_file_result_test_file_smoke_report ON test_file_result (test_file, smoke_report);
CREATE INDEX i_test_file_result_smoke_report ON test_file_result (smoke_report);
COMMIT;
