USE stats;

SELECT * FROM Questions;
SELECT COUNT(*) FROM Questions;	

SELECT * FROM Answers;

SELECT * FROM comments;

SELECT * FROM post_history;
SELECT COUNT(*) FROM post_history;

SELECT * FROM post_links;
SELECT COUNT(*) FROM post_links WHERE LinkTypeId = 3; -- Duplicate posts

SELECT * FROM post_types;

SELECT * FROM posts;

SELECT COUNT(*) FROM posts;  -- 372,715
SELECT COUNT(*) FROM posts WHERE PostTypeId IN (1,2);   -- 369,855 Questions and Answers
SELECT COUNT(*) FROM Questions;	  -- 187,996 Questions
SELECT COUNT(*) FROM Answers;    -- 181,859 Answers

SELECT * FROM tags
ORDER BY Count DESC;
SELECT COUNT(*) FROM tags;   -- a total of 1575 unique tags

SELECT * FROM users;

SELECT * FROM votes;
SELECT VoteTypeId, COUNT(VoteTypeId) AS CountOf
FROM votes
GROUP BY VoteTypeId
ORDER BY 2 DESC;

/* Find questions which have an accepted answer. There's a total of 187,996 questions. */
SELECT * FROM posts
WHERE PostTypeId = 1
AND AcceptedAnswerId IS NOT NULL;
/* A total of 62,379 questions have an accepted answer */

/* Now find questions which have an accepted answer and are on regression */
SELECT * FROM posts
WHERE PostTypeId = 1
AND AcceptedAnswerId IS NOT NULL
AND Tags LIKE '%regression%';
/* We are down to 10,204 questions */

/* Now find questions which have an accepted answer, are on regression, and the accepted answer has
a score greater than 10 */
SELECT * FROM posts
WHERE PostTypeId = 1
AND Tags LIKE '%regression%'
AND AcceptedAnswerId IN (SELECT Id FROM posts WHERE PostTypeId = 2 AND Score > 10);
/* We are down to 964 such questions. */

/* Find questions about time series */
SELECT * FROM posts
WHERE PostTypeId = 1
AND Tags LIKE '%time-series%';
/* There are a total of 12,808 questions */

/* Find all the answers of the time series questions */
SELECT * FROM posts
WHERE PostTypeId = 2
AND ParentId IN (SELECT Id FROM posts WHERE PostTypeId = 1 AND Tags LIKE '%time-series%');
/* There are 11,248 answers to time series questions */

/* Now only keep answers which have been answered by users who have more than 10 upvotes */
SELECT * 
FROM posts p
JOIN users u
ON p.OwnerUserId = u.Id
WHERE p.PostTypeId = 2
AND p.ParentId IN (SELECT Id FROM posts WHERE PostTypeId = 1 AND Tags LIKE '%time-series%')
AND u.UpVotes > 10;
/* This brings us down to 8826 answers */

/* Find which tag questions get the maximum views. Sort it in decreasing order */
SET GLOBAL sort_buffer_size = 256000000;

SELECT * FROM posts
WHERE PostTypeId = 1
ORDER BY ViewCount DESC;

/* Find all questions and its respective answers on probability */
SELECT * FROM posts
WHERE PostTypeId = 1 
AND Tags LIKE '%probability%'
UNION
SELECT * FROM posts
WHERE Id IN (SELECT AcceptedAnswerId FROM posts WHERE PostTypeId = 1 AND Tags LIKE '%probability%');

/* Please note that the above queries are written to demonstrate different SQL operators, and may not be the most efficient way to 
write queries. */ 

SHOW INDEX FROM posts;
