CREATE DATABASE stats DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
-- DROP DATABASE stats;

USE stats;

-- DROP TABLE IF EXISTS badges;
-- DROP TABLE IF EXISTS comments;
-- DROP TABLE IF EXISTS post_history;
-- DROP TABLE IF EXISTS post_links;
-- DROP TABLE IF EXISTS post_types;
-- DROP TABLE IF EXISTS posts;
-- DROP TABLE IF EXISTS tags;
-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS vote_types;
-- DROP TABLE IF EXISTS votes;

-- Badges
CREATE TABLE badges (
	Id INT NOT NULL PRIMARY KEY,
	UserId INT,
	Name VARCHAR(50),
	Date DATETIME
);

-- Comments
CREATE TABLE comments (
	Id INT NOT NULL PRIMARY KEY,
    	PostId INT NOT NULL,
    	Score INT NOT NULL DEFAULT 0,   -- number of upvotes - number of downvotes
    	Text TEXT,
    	CreationDate DATETIME,
    	UserId INT NOT NULL
);

-- Post History
CREATE TABLE post_history (
	Id INT NOT NULL PRIMARY KEY,
    	PostHistoryTypeId SMALLINT NOT NULL,
    	PostId INT NOT NULL,
    	RevisionGUID VARCHAR(36),
    	CreationDate DATETIME,
    	UserId INT NOT NULL,
    	Text TEXT
);

-- Post Links
CREATE TABLE post_links (
	Id INT NOT NULL PRIMARY KEY,
    	CreationDate DATETIME DEFAULT NULL,
    	PostId INT NOT NULL,
    	RelatedPostId INT NOT NULL,
    	LinkTypeId INT DEFAULT NULL
);

-- Post Types
CREATE TABLE post_types (
	Id SMALLINT NOT NULL PRIMARY KEY,
    	Description VARCHAR(32) NOT NULL
);

INSERT INTO post_types (Id, Description) VALUES
  (1, 'Question'),
  (2, 'Answer'),
  (3, 'Wiki'),
  (4, 'Tag Wiki Excerpt'),
  (5, 'Tag Wiki'),
  (6, 'Moderator Nomination'),
  (7, 'Wiki Placeholder'),
  (8, 'Privilege Wiki');

-- Posts
CREATE TABLE posts (
    Id INT NOT NULL PRIMARY KEY,
    PostTypeId SMALLINT,    -- 1 = Question; 2 = Answer
    AcceptedAnswerId INT,   -- only present if PostTypeId = 1
    ParentId INT,           -- only present if PostTypeId = 2
    Score INT NULL,
    ViewCount INT NULL,
    Body text NULL,
    OwnerUserId INT DEFAULT 0,
    OwnerDisplayName varchar(256),
    LastEditorUserId INT,
    LastEditDate DATETIME,
    LastActivityDate DATETIME,
    Title varchar(256) NULL,
    Tags VARCHAR(256),
    AnswerCount INT DEFAULT 0,
    CommentCount INT DEFAULT 0,
    FavoriteCount INT DEFAULT 0,
    CreationDate DATETIME
);

-- Tags
CREATE TABLE tags (
  Id INT NOT NULL PRIMARY KEY,
  TagName VARCHAR(50) CHARACTER SET latin1 DEFAULT NULL,
  Count INT DEFAULT NULL,
  ExcerptPostId INT DEFAULT NULL,
  WikiPostId INT DEFAULT NULL
);

-- Users
CREATE TABLE users (
    Id INT NOT NULL PRIMARY KEY,
    Reputation INT NOT NULL,
    CreationDate DATETIME,
    DisplayName VARCHAR(50) NULL,
    LastAccessDate DATETIME,
    Views INT DEFAULT 0,
    WebsiteUrl VARCHAR(256) NULL,
    Location VARCHAR(256) NULL,
    AboutMe TEXT NULL,
    UpVotes INT,
    DownVotes INT,
    AccountId INT
);

-- Vote Types
CREATE TABLE vote_types (
  	Id SMALLINT NOT NULL PRIMARY KEY,
  	Description VARCHAR(32) NOT NULL
);

INSERT INTO vote_types (Id, Description) VALUES
  (1, 'AcceptedByOriginator'),
  (2, 'UpMod'),
  (3, 'DownMod'),
  (4, 'Offensive'),
  (5, 'Favorite'),
  (6, 'Close'),
  (7, 'Reopen'),
  (8, 'BountyStart'),
  (9, 'BountyClose'),
  (10, 'Deletion'),
  (11, 'Undeletion'),
  (12, 'Spam'),
  (15, 'ModeratorReview'),
  (16, 'ApproveEditSuggestion');

-- Votes
CREATE TABLE votes (
    Id INT NOT NULL PRIMARY KEY,
    PostId INT NOT NULL,
    VoteTypeId SMALLINT,
    CreationDate DATETIME
);

-- SHOW VARIABLES LIKE "local_infile";

-- SET GLOBAL local_infile = 'ON';

-- SHOW VARIABLES LIKE "secure_file_priv";

-- Load Badges data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stats.stackexchange.com/Badges.xml' 
INTO TABLE badges
rows identified by '<row>';

-- SELECT * FROM badges;

-- Load Comments data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stats.stackexchange.com/Comments.xml' 
INTO TABLE comments
rows identified by '<row>';

-- SELECT * FROM comments;
-- SELECT COUNT(*) FROM comments;

-- Load Post History data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stats.stackexchange.com/PostHistory.xml' 
INTO TABLE post_history
rows identified by '<row>';

-- SELECT * FROM post_history;
-- SELECT COUNT(*) FROM post_history;

-- Load Post Links data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stats.stackexchange.com/PostLinks.xml' 
INTO TABLE post_links
rows identified by '<row>';

-- SELECT * FROM post_links;

-- Load Posts data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stats.stackexchange.com/Posts.xml'
INTO TABLE posts
rows identified by '<row>';

-- SELECT * FROM posts;
-- SELECT COUNT(*) FROM posts;

-- Load Tags data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stats.stackexchange.com/Tags.xml' 
INTO TABLE tags
rows identified by '<row>';

-- SELECT * FROM tags;

-- Load Users data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stats.stackexchange.com/Users.xml' 
INTO TABLE users
rows identified by '<row>';

-- SELECT * FROM users;

-- Load Votes data
LOAD XML LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stats.stackexchange.com/Votes.xml' 
INTO TABLE votes
rows identified by '<row>';

-- SELECT * FROM votes;
-- SELECT COUNT(*) FROM votes;

-- -- Add Foreign Keys Next

ALTER TABLE badges
	ADD FOREIGN KEY (UserId) REFERENCES users(Id);
    
ALTER TABLE posts
  	ADD FOREIGN KEY (PostTypeId) REFERENCES post_types(Id),
  	ADD FOREIGN KEY (OwnerUserId) REFERENCES users(Id),
  	ADD FOREIGN KEY (LastEditorUserId) REFERENCES users(Id);

SET SQL_SAFE_UPDATES = 0;
DELETE c FROM comments c LEFT JOIN users u ON c.UserId=u.Id WHERE u.Id IS NULL;
SET SQL_SAFE_UPDATES = 1;

-- Couldn't execute the below query. Error code: 1206 - tried updating "innodb_buffer_pool_size = 999M"
-- in C:\ProgramData\MySQL\MySQL Server 8.0\my.ini - still no good.  
-- ALTER TABLE comments ADD FOREIGN KEY (PostId) REFERENCES posts(Id);

ALTER TABLE comments  ADD FOREIGN KEY (UserId) REFERENCES users(Id);

-- Error Code: 1206
-- SET SQL_SAFE_UPDATES = 0;
-- DELETE v FROM votes AS v LEFT JOIN posts AS p ON v.PostId=p.Id WHERE p.Id IS NULL;
-- SET SQL_SAFE_UPDATES = 1;

-- Error Code: 1452
-- ALTER TABLE votes ADD FOREIGN KEY (PostId) REFERENCES posts(Id);

ALTER TABLE votes ADD FOREIGN KEY (VoteTypeId) REFERENCES vote_types(Id);
  
-- -- Create Views

CREATE OR REPLACE VIEW Questions AS SELECT * FROM posts WHERE PostTypeId = 1;
CREATE OR REPLACE VIEW Answers AS SELECT * FROM posts WHERE PostTypeId = 2;

-- SELECT * FROM Questions;
-- SELECT COUNT(*) FROM Questions;
-- SELECT COUNT(*) FROM Answers;

-- -- Create Indexes

CREATE INDEX comments_idx_1 ON comments(PostId);
CREATE INDEX comments_idx_2 ON comments(UserId);

CREATE INDEX posts_idx_1 ON posts(AcceptedAnswerId);
CREATE INDEX posts_idx_2 ON posts(ParentId);
CREATE INDEX posts_idx_3 ON posts(OwnerUserId);
CREATE INDEX posts_idx_4 ON posts(LastEditorUserId);
CREATE INDEX posts_idx_5 ON posts(Tags);
CREATE INDEX posts_idx_6 ON posts(PostTypeId);

CREATE INDEX votes_idx_1 ON votes(PostId);




-- -- REFERENCES

-- https://meta.stackexchange.com/questions/2677/database-schema-documentation-for-the-public-data-dump-and-sede/2678#2678
