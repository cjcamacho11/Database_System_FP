Use MusicMedia
GO


-- 1 - most recently released album
SELECT TOP 1 title, release_date FROM Albums ORDER BY release_date DESC;
-- 2 - every 90s song
SELECT title, release_date FROM Songs WHERE YEAR(release_date) < 2000 AND YEAR(release_date) > 1990;
-- 3 - every playlist that is not publics
SELECT name FROM Playlists WHERE is_public = 'FALSE';
-- 4 - agregate 1 - total Number of Artists
SELECT COUNT(artist_id) FROM Artists;
-- 5 - agregate 2 - shortest Song
SELECT title, duration AS Shortest_Song_Length FROM Songs 
WHERE duration = (SELECT MIN(duration) FROM Songs);
-- 6 - agregate 3 for fun - average length of a song
SELECT AVG(duration) AS Average_Song_Length FROM Songs;
-- 7 - sub query 1 - selects the genre of every song within the song table
SELECT Genres.name
FROM Genres
WHERE Genres.genre_id IN (
    SELECT Songs.genre_id
    FROM Songs
    WHERE Songs.genre_id IS NOT NULL
);
-- 8 - sub query 2 - selects every artist with a song greater than 400 seconds
SELECT Artists.name
FROM Artists
WHERE Artists.artist_id IN (
    SELECT Songs.artist_id
    FROM Songs
    WHERE Songs.duration > 400
);
-- 9 - join 1 - selects every user who liked something
SELECT Users.username, Notifications.type
FROM Notifications
JOIN Users ON Notifications.user_id = Users.user_id
WHERE Notifications.type = 'Like';
-- 10 - join 2 - selects every user with more than 2 followers
SELECT Users.username, COUNT(Follows.follower_id) AS Follower_Count
FROM Users
JOIN Follows ON Users.user_id = Follows.followed_id
GROUP BY Users.username
HAVING COUNT(Follows.follower_id) > 2;
