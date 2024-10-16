CREATE DATABASE MusicMedia;
GO
USE MusicMedia;
GO




CREATE TABLE Users (
  user_id INT NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  profile_picture VARCHAR(255),
  bio TEXT,
  permission VARCHAR(5) DEFAULT 'user',
  CONSTRAINT Users_PK PRIMARY KEY (user_id)
);
GO


CREATE TABLE Artists (
  artist_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  bio TEXT,
  image_url VARCHAR(255),
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  CONSTRAINT Artists_PK PRIMARY KEY (artist_id)




);
GO


CREATE TABLE Albums (
  album_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  artist_id INT NOT NULL,
  release_date DATE,
  cover_image_url VARCHAR(255),
  CONSTRAINT Album_PK PRIMARY KEY (album_id),
  CONSTRAINT Album_FK FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)


);
GO


CREATE TABLE Genres (
  genre_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  CONSTRAINT Genre_PK PRIMARY KEY (genre_id)
);
GO


CREATE TABLE Songs (
  song_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  artist_id INT NOT NULL,
  album_id INT,
  genre_id INT,
  release_date DATE CONSTRAINT
  date_chk CHECK (release_date <= GETDATE()), --CHECK can't exist after today's date
  duration INT CONSTRAINT
  duration_chk CHECK (duration >= 0), -- CHECK can't be negative
  CONSTRAINT Song_PK PRIMARY KEY (song_id),
  CONSTRAINT Song_FK1 FOREIGN KEY (artist_id) REFERENCES Artists(artist_id),
  CONSTRAINT Song_FK2 FOREIGN KEY (album_id) REFERENCES Albums(album_id),
  CONSTRAINT Song_FK3 FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);
GO


CREATE TABLE Playlists (
  playlist_id INT NOT NULL,
  user_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  is_public VARCHAR(5) DEFAULT 'TRUE',
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE(),
  CONSTRAINT Playlist_PK PRIMARY KEY (playlist_id),
 CONSTRAINT Playlist_FK FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO


CREATE TABLE Playlist_Songs (
  playlist_song_id INT NOT NULL,
  playlist_id INT NOT NULL,
  song_id INT NOT NULL,
  CONSTRAINT Playlist_Song_PK PRIMARY KEY (playlist_song_id),
  CONSTRAINT Playlist_Song_FK1 FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id),
  CONSTRAINT Playlist_Song_FK2 FOREIGN KEY (song_id) REFERENCES Songs(song_id)
);
GO


CREATE TABLE Follows (
  follow_id INT NOT NULL,
  follower_id INT NOT NULL,
  followed_id INT NOT NULL,
  CONSTRAINT Follow_PK PRIMARY KEY (follow_id),
  CONSTRAINT Follow_FK1 FOREIGN KEY (follower_id) REFERENCES Users(user_id),
  CONSTRAINT Follow_FK2 FOREIGN KEY (followed_id) REFERENCES Users(user_id)
);
GO


CREATE TABLE Likes (
  like_id INT NOT NULL,
  user_id INT NOT NULL,
  item_id INT NOT NULL,
  item_type VARCHAR(10) CONSTRAINT
  item_type_chk CHECK (item_type IN ('Song', 'Playlist')), --CHECK type
  time_liked DATETIME DEFAULT GETDATE(),
  CONSTRAINT Like_PK PRIMARY KEY (like_id),
  CONSTRAINT Like_FK FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO


CREATE TABLE Comments (
  comment_id INT NOT NULL,
  user_id INT NOT NULL,
  item_id INT NOT NULL,
  item_type VARCHAR(10) CHECK (item_type IN ('Song', 'Playlist')), -- CHECK type
  comment_text TEXT NOT NULL,
  time_commented DATETIME DEFAULT GETDATE(),
  time_updated DATETIME DEFAULT GETDATE(),
  CONSTRAINT Comment_PK  PRIMARY KEY (comment_id),
  CONSTRAINT Comment_FK FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO




CREATE TABLE Notifications (
  notification_id INT NOT NULL,
  user_id INT NOT NULL,
  type VARCHAR(10) CONSTRAINT
  type_chk CHECK (type IN ('Follow', 'Like', 'Comment')), -- CHECK
  message TEXT,
  time_sent DATETIME DEFAULT GETDATE(),
  is_read VARCHAR(5) DEFAULT 'FALSE',
  CONSTRAINT Notifications_PK PRIMARY KEY (notification_id),
  CONSTRAINT Notifications_FK FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO


CREATE TABLE Reports (
  report_id INT NOT NULL,
  user_id INT NOT NULL,
  item_id INT NOT NULL,
  item_type VARCHAR(10) CONSTRAINT
  item_chk CHECK (item_type IN ('Song', 'Playlist', 'Comment')),
  reason TEXT NOT NULL,
  status VARCHAR(10) CONSTRAINT
  status_chk CHECK (status IN ('Pending', 'Resolved')) DEFAULT 'Pending',
  time_reported DATETIME DEFAULT GETDATE(),
  CONSTRAINT Reports_PK PRIMARY KEY (report_id),
  CONSTRAINT Reports_FK FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO


CREATE TABLE Activity_Feed (
  activity_id INT NOT NULL,
  user_id INT NOT NULL,
  action VARCHAR(20) CONSTRAINT
  action_chk CHECK (action IN ('created_playlist', 'liked_song', 'commented')), --CHECK
  item_id INT NOT NULL,
  item_type VARCHAR(10) CONSTRAINT
  item_check CHECK (item_type IN ('Playlist', 'Song', 'User')), --CHECK
  activity_time DATETIME DEFAULT GETDATE(),
  CONSTRAINT Activity_Feed_PK PRIMARY KEY (activity_id),
  CONSTRAINT Activity_Feed_FK FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO


CREATE TABLE Contribution_Album_Table (
  album_id INT NOT NULL,
  artist_id INT NOT NULL,
  contribution VARCHAR(255),
  CONSTRAINT Contribution_Album_Table_PK PRIMARY KEY (album_id, artist_id),
  CONSTRAINT Contribution_Album_Table_FK1 FOREIGN KEY (album_id) REFERENCES Albums(album_id),
  CONSTRAINT Contribution_Album_Table_FK2 FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);
GO


CREATE TABLE Contribution_Song_Table (
  song_id INT NOT NULL,
  artist_id INT NOT NULL,
  contribution VARCHAR(255),
  CONSTRAINT Contribution_Song_Table_PK PRIMARY KEY (song_id, artist_id),
  CONSTRAINT Contribution_Song_Table_FK1 FOREIGN KEY (song_id) REFERENCES Songs(song_id),
  CONSTRAINT Contribution_Song_Table_FK2 FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);
GO


INSERT INTO Users (user_id, username, email, password, profile_picture, bio, permission)
VALUES
(1, 'musiclover01', 'musiclover01@example.com', 'hashedpassword1', 'http://example.com/image1.jpg', 'I love all kinds of music!', 'user'),
(2, 'rockfan22', 'rockfan22@example.com', 'hashedpassword2', 'http://example.com/image2.jpg', 'Rock music is my jam!', 'user'),
(3, 'jazzenthusiast', 'jazzenthusiast@example.com', 'hashedpassword3', 'http://example.com/image3.jpg', 'Jazz is the sound of my soul.', 'user'),
(4, 'popfanatic', 'popfanatic@example.com', 'hashedpassword4', 'http://example.com/image4.jpg', 'I live for pop hits!', 'user'),
(5, 'indiefan99', 'indiefan99@example.com', 'hashedpassword5', 'http://example.com/image5.jpg', 'Indie music makes my heart sing.', 'user'),
(6, 'folklover77', 'folklover77@example.com', 'hashedpassword6', 'http://example.com/image6.jpg', 'I enjoy acoustic and folk vibes.', 'user'),
(7, 'bluesbrother', 'bluesbrother@example.com', 'hashedpassword7', 'http://example.com/image7.jpg', 'Blues for life!', 'user'),
(8, 'classicrockstar', 'classicrockstar@example.com', 'hashedpassword8', 'http://example.com/image8.jpg', 'Classic rock is my favorite.', 'user'),
(9, 'musicmaven', 'musicmaven@example.com', 'hashedpassword9', 'http://example.com/image9.jpg', 'Exploring new sounds every day.', 'user'),
(10, 'soulfulsinger', 'soulfulsinger@example.com', 'hashedpassword10', 'http://example.com/image10.jpg', 'I love soulful melodies.', 'user'),
(11, 'dancemaster', 'dancemaster@example.com', 'hashedpassword11', 'http://example.com/image11.jpg', 'Let’s dance to the beat!', 'user'),
(12, 'metalhead84', 'metalhead84@example.com', 'hashedpassword12', 'http://example.com/image12.jpg', 'Metal is my therapy.', 'user'),
(13, 'rhythmking', 'rhythmking@example.com', 'hashedpassword13', 'http://example.com/image13.jpg', 'Rhythm is everything.', 'user'),
(14, 'rapfanatic', 'rapfanatic@example.com', 'hashedpassword14', 'http://example.com/image14.jpg', 'Hip hop is my favorite genre.', 'user'),
(15, 'singer23', 'singer23@example.com', 'hashedpassword15', 'http://example.com/image15.jpg', 'Singing is my passion.', 'user'),
(16, 'oldieslover', 'oldieslover@example.com', 'hashedpassword16', 'http://example.com/image16.jpg', 'Nothing beats the oldies.', 'user'),
(17, 'popculturejunkie', 'popculturejunkie@example.com', 'hashedpassword17', 'http://example.com/image17.jpg', 'All about pop culture!', 'user'),
(18, 'newagefan', 'newagefan@example.com', 'hashedpassword18', 'http://example.com/image18.jpg', 'I love New Age music.', 'user'),
(19, 'soundtrackgeek', 'soundtrackgeek@example.com', 'hashedpassword19', 'http://example.com/image19.jpg', 'Film scores are my favorite.', 'user'),
(20, 'synthwavekid', 'synthwavekid@example.com', 'hashedpassword20', 'http://example.com/image20.jpg', 'Living in the 80s vibe!', 'user'),
(21, 'kpopfan', 'kpopfan@example.com', 'hashedpassword21', 'http://example.com/image21.jpg', 'K-pop is my life!', 'user'),
(22, 'indiepoplover', 'indiepoplover@example.com', 'hashedpassword22', 'http://example.com/image22.jpg', 'Indie pop makes me smile.', 'user'),
(23, 'emoheart', 'emoheart@example.com', 'hashedpassword23', 'http://example.com/image23.jpg', 'Emo music speaks to me.', 'user'),
(24, 'afrofuturist', 'afrofuturist@example.com', 'hashedpassword24', 'http://example.com/image24.jpg', 'Exploring Afrofuturism through music.', 'user'),
(25, 'pianomaster', 'pianomaster@example.com', 'hashedpassword25', 'http://example.com/image25.jpg', 'Piano is my instrument.', 'user'),
(26, 'musicaltheaterfan', 'musicaltheaterfan@example.com', 'hashedpassword26', 'http://example.com/image26.jpg', 'Broadway is the best!', 'user'),
(27, 'vintagevinyl', 'vintagevinyl@example.com', 'hashedpassword27', 'http://example.com/image27.jpg', 'I collect vintage vinyl records.', 'user'),
(28, 'rnblover', 'rnblover@example.com', 'hashedpassword28', 'http://example.com/image28.jpg', 'R&B hits are the best!', 'user'),
(29, 'harmonyseekers', 'harmonyseekers@example.com', 'hashedpassword29', 'http://example.com/image29.jpg', 'Searching for perfect harmony.', 'user'),
(30, 'acapellaperson', 'acapellaperson@example.com', 'hashedpassword30', 'http://example.com/image30.jpg', 'I love singing acapella.', 'user');






INSERT INTO Artists (artist_id, name, bio, image_url, created_at, updated_at)
VALUES
(1, 'Ocean Blue', 'An up-and-coming pop artist.', 'http://example.com/artist1.jpg', GETDATE(), GETDATE()),
(2, 'Starlight Melody', 'A rock band with a vintage sound.', 'http://example.com/artist2.jpg', GETDATE(), GETDATE()),
(3, 'Silent Whisper', 'A smooth jazz artist known for his saxophone skills.', 'http://example.com/artist3.jpg', GETDATE(), GETDATE()),
(4, 'Golden Dawn', 'An electronic artist blending various genres.', 'http://example.com/artist4.jpg', GETDATE(), GETDATE()),
(5, 'Crimson Echo', 'An indie artist with heartfelt lyrics.', 'http://example.com/artist5.jpg', GETDATE(), GETDATE()),
(6, 'Nightfall', 'A folk musician sharing stories through song.', 'http://example.com/artist6.jpg', GETDATE(), GETDATE()),
(7, 'Dreamscape', 'A classical composer with a modern twist.', 'http://example.com/artist7.jpg', GETDATE(), GETDATE()),
(8, 'Firefly', 'A blues musician known for emotional performances.', 'http://example.com/artist8.jpg', GETDATE(), GETDATE()),
(9, 'Wanderlust', 'An alternative artist exploring new sounds.', 'http://example.com/artist9.jpg', GETDATE(), GETDATE()),
(10, 'Soul Strings', 'A reggae artist with a positive vibe.', 'http://example.com/artist10.jpg', GETDATE(), GETDATE()),
(11, 'Echo Chamber', 'An experimental artist pushing the boundaries.', 'http://example.com/artist11.jpg', GETDATE(), GETDATE()),
(12, 'Metal Fury', 'A heavy metal band that rocks hard.', 'http://example.com/artist12.jpg', GETDATE(), GETDATE()),
(13, 'Folk Tales', 'A duo that sings traditional folk songs.', 'http://example.com/artist13.jpg', GETDATE(), GETDATE()),
(14, 'Hip Hop Nation', 'A collective of diverse hip-hop artists.', 'http://example.com/artist14.jpg', GETDATE(), GETDATE()),
(15, 'Soundtrack Magic', 'A composer of film scores and soundtracks.', 'http://example.com/artist15.jpg', GETDATE(), GETDATE()),
(16, 'Vocal Vibes', 'An acapella group that harmonizes beautifully.', 'http://example.com/artist16.jpg', GETDATE(), GETDATE()),
(17, 'Rap Revolution', 'A rapper known for powerful lyrics.', 'http://example.com/artist17.jpg', GETDATE(), GETDATE()),
(18, 'Pop Fusion', 'An artist blending pop with electronic sounds.', 'http://example.com/artist18.jpg', GETDATE(), GETDATE()),
(19, 'Indie Spirit', 'A quirky indie artist with a unique style.', 'http://example.com/artist19.jpg', GETDATE(), GETDATE()),
(20, 'Sonic Harmony', 'An artist known for soothing melodies.', 'http://example.com/artist20.jpg', GETDATE(), GETDATE()),
(21, 'Dance Floor', 'A DJ creating beats for the club.', 'http://example.com/artist21.jpg', GETDATE(), GETDATE()),
(22, 'Reggae Vibes', 'A band bringing the Caribbean sound.', 'http://example.com/artist22.jpg', GETDATE(), GETDATE()),
(23, 'Chill Beats', 'An artist focused on lo-fi hip hop.', 'http://example.com/artist23.jpg', GETDATE(), GETDATE()),
(24, 'Acoustic Sunset', 'An acoustic artist performing relaxing tunes.', 'http://example.com/artist24.jpg', GETDATE(), GETDATE()),
(25, 'Futuristic Sound', 'An artist exploring new audio technology.', 'http://example.com/artist25.jpg', GETDATE(), GETDATE()),
(26, 'Soulful Journey', 'An R&B artist with a deep voice.', 'http://example.com/artist26.jpg', GETDATE(), GETDATE()),
(27, 'World Traveler', 'A world music artist sharing global sounds.', 'http://example.com/artist27.jpg', GETDATE(), GETDATE()),
(28, 'Rock Legends', 'A tribute band to classic rock artists.', 'http://example.com/artist28.jpg', GETDATE(), GETDATE()),
(29, 'Guitar Hero', 'A guitarist known for electrifying solos.', 'http://example.com/artist29.jpg', GETDATE(), GETDATE()),
(30, 'Vibe Collective', 'A group of artists creating chill music.', 'http://example.com/artist30.jpg', GETDATE(), GETDATE());






INSERT INTO Albums (album_id, title, artist_id, release_date, cover_image_url)
VALUES
(1, 'Let It Be', 30, '1970-05-08', 'http://example.com/albums/letitbe.jpg'),
(2, 'DAMN.', 3, '2017-04-14', 'http://example.com/albums/damn.jpg'),
(3, 'When We All Fall Asleep, Where Do We Go?', 2, '2019-03-29', 'http://example.com/albums/wwafawdwg.jpg'),
(4, 'Exile on Main St.', 1, '1972-05-12', 'http://example.com/albums/exile.jpg'),
(5, 'Thriller', 4, '1982-11-30', 'http://example.com/albums/thriller.jpg'),
(6, 'Back in Black', 5, '1980-07-25', 'http://example.com/albums/backinblack.jpg'),
(7, 'Abbey Road', 30, '1969-09-26', 'http://example.com/albums/abbeyroad.jpg'),
(8, 'The Dark Side of the Moon', 6, '1973-03-01', 'http://example.com/albums/darksidemoon.jpg'),
(9, 'Rumours', 7, '1977-02-04', 'http://example.com/albums/rumours.jpg'),
(10, 'Hotel California', 8, '1976-12-08', 'http://example.com/albums/hotelcalifornia.jpg'),
(11, '21', 9, '2011-01-24', 'http://example.com/albums/21.jpg'),
(12, 'Fearless', 10, '2008-11-11', 'http://example.com/albums/fearless.jpg'),
(13, 'Abbey Road', 11, '1969-09-26', 'http://example.com/albums/abbeyroad2.jpg'),
(14, 'Nevermind', 12, '1991-09-24', 'http://example.com/albums/nevermind.jpg'),
(15, 'The Joshua Tree', 13, '1987-03-09', 'http://example.com/albums/joshuatree.jpg'),
(16, 'Achtung Baby', 14, '1991-11-18', 'http://example.com/albums/achtungbaby.jpg'),
(17, 'Thriller', 15, '1982-11-30', 'http://example.com/albums/thriller2.jpg'),
(18, 'Random Access Memories', 16, '2013-05-17', 'http://example.com/albums/randomaccessmemories.jpg'),
(19, 'Bad', 17, '1987-08-31', 'http://example.com/albums/bad.jpg'),
(20, '1989', 18, '2014-10-27', 'http://example.com/albums/1989.jpg'),
(21, 'Divide', 19, '2017-03-03', 'http://example.com/albums/divide.jpg'),
(22, 'Blinding Lights', 20, '2020-11-29', 'http://example.com/albums/blindinglights.jpg'),
(23, 'Reputation', 21, '2017-11-10', 'http://example.com/albums/reputation.jpg'),
(24, 'Lemonade', 22, '2016-04-23', 'http://example.com/albums/lemonade.jpg'),
(25, '25', 23, '2015-11-20', 'http://example.com/albums/25.jpg'),
(26, 'Thriller', 24, '1982-11-30', 'http://example.com/albums/thriller3.jpg'),
(27, 'Born This Way', 25, '2011-05-23', 'http://example.com/albums/bornthisway.jpg'),
(28, '1989', 26, '2014-10-27', 'http://example.com/albums/1989_2.jpg'),
(29, 'Reputation', 27, '2017-11-10', 'http://example.com/albums/reputation2.jpg'),
(30, 'Future Nostalgia', 28, '2020-03-27', 'http://example.com/albums/futurenostalgia.jpg');




INSERT INTO Genres (genre_id, name)
VALUES
(1, 'Rock'),
(2, 'Pop'),
(3, 'Hip-hop'),
(4, 'Jazz'),
(5, 'Classical'),
(6, 'Electronic'),
(7, 'Folk'),
(8, 'Blues'),
(9, 'Reggae'),
(10, 'R&B'),
(11, 'Metal'),
(12, 'Country'),
(13, 'Alternative'),
(14, 'Indie'),
(15, 'Soul'),
(16, 'Funk'),
(17, 'Punk'),
(18, 'Disco'),
(19, 'House'),
(20, 'Trance'),
(21, 'Techno'),
(22, 'Drum and Bass'),
(23, 'Ambient'),
(24, 'Ska'),
(25, 'Gospel'),
(26, 'Latin'),
(27, 'Salsa'),
(28, 'K-pop'),
(29, 'C-pop'),
(30, 'J-pop');






INSERT INTO Songs (song_id, title, artist_id, album_id, genre_id, release_date, duration)
VALUES
(1, 'Come Together', 30, 1, 1, '1969-09-26', 259),
(2, 'HUMBLE.', 3, 2, 3, '2017-04-14', 177),
(3, 'bad guy', 2, 3, 2, '2019-03-29', 194),
(4, 'Paint It Black', 1, 4, 1, '1966-05-31', 200),
(5, 'Billie Jean', 4, 5, 2, '1983-01-02', 294),
(6, 'Back in Black', 5, 6, 1, '1980-07-25', 255),
(7, 'Here Comes the Sun', 30, 7, 1, '1969-09-26', 185),
(8, 'Time', 6, 8, 4, '1973-03-01', 413),
(9, 'Dreams', 7, 9, 1, '1977-02-04', 257),
(10, 'Hotel California', 8, 10, 1, '1976-12-08', 390),
(11, 'Rolling in the Deep', 9, 11, 2, '2010-11-29', 228),
(12, 'Love Story', 10, 12, 2, '2008-09-12', 235),
(13, 'Something', 11, 13, 1, '1969-09-26', 183),
(14, 'Smells Like Teen Spirit', 12, 14, 1, '1991-09-10', 301),
(15, 'With or Without You', 13, 15, 1, '1987-03-09', 276),
(16, 'One', 14, 16, 3, '1991-11-18', 272),
(17, 'Beat It', 15, 17, 2, '1983-02-14', 258),
(18, 'Get Lucky', 16, 18, 6, '2013-05-17', 269),
(19, 'Bad', 17, 19, 3, '1987-08-31', 245),
(20, 'Shake It Off', 18, 20, 2, '2014-08-18', 242),
(21, 'Shape of You', 19, 21, 2, '2017-01-06', 233),
(22, 'Blinding Lights', 20, 22, 2, '2019-11-29', 200),
(23, 'Look What You Made Me Do', 21, 23, 2, '2017-08-24', 211),
(24, 'Formation', 22, 24, 3, '2016-02-06', 242),
(25, 'Hello', 23, 25, 2, '2015-10-23', 295),
(26, 'Billie Jean', 24, 26, 2, '1983-01-02', 294),
(27, 'Born This Way', 25, 27, 3, '2011-05-23', 242),
(28, 'Blank Space', 26, 28, 2, '2014-11-10', 231),
(29, 'Reputation', 27, 29, 2, '2017-11-10', 231),
(30, 'Future Nostalgia', 28, 30, 2, '2020-03-27', 207);




INSERT INTO Playlists (playlist_id, user_id, name, is_public, created_at, updated_at)
VALUES
(1, 1, 'Rock Classics', 'TRUE', GETDATE(), GETDATE()),
(2, 2, 'Chill Vibes', 'TRUE', GETDATE(), GETDATE()),
(3, 3, 'Top Hits', 'FALSE', GETDATE(), GETDATE()),
(4, 4, 'Jazz Essentials', 'TRUE', GETDATE(), GETDATE()),
(5, 5, 'Indie Favorites', 'TRUE', GETDATE(), GETDATE()),
(6, 6, 'Folk Tales', 'FALSE', GETDATE(), GETDATE()),
(7, 7, 'Blues Legends', 'TRUE', GETDATE(), GETDATE()),
(8, 8, 'Reggae Rhythms', 'TRUE', GETDATE(), GETDATE()),
(9, 9, 'Pop Sensations', 'FALSE', GETDATE(), GETDATE()),
(10, 10, 'Electronic Beats', 'TRUE', GETDATE(), GETDATE()),
(11, 11, 'Metal Madness', 'FALSE', GETDATE(), GETDATE()),
(12, 12, 'Country Roads', 'TRUE', GETDATE(), GETDATE()),
(13, 13, 'Alternative Mix', 'FALSE', GETDATE(), GETDATE()),
(14, 14, 'Hip-hop Hits', 'TRUE', GETDATE(), GETDATE()),
(15, 15, 'Soulful Sounds', 'TRUE', GETDATE(), GETDATE()),
(16, 16, 'Funk Fiesta', 'FALSE', GETDATE(), GETDATE()),
(17, 17, 'Punk Power', 'TRUE', GETDATE(), GETDATE()),
(18, 18, 'Disco Fever', 'FALSE', GETDATE(), GETDATE()),
(19, 19, 'House Party', 'TRUE', GETDATE(), GETDATE()),
(20, 20, 'Trance Journey', 'FALSE', GETDATE(), GETDATE()),
(21, 21, 'Techno Titans', 'TRUE', GETDATE(), GETDATE()),
(22, 22, 'Drum and Bass Beats', 'TRUE', GETDATE(), GETDATE()),
(23, 23, 'Ambient Atmosphere', 'FALSE', GETDATE(), GETDATE()),
(24, 24, 'Ska Ska!', 'TRUE', GETDATE(), GETDATE()),
(25, 25, 'Gospel Glory', 'TRUE', GETDATE(), GETDATE()),
(26, 26, 'Latin Lovers', 'FALSE', GETDATE(), GETDATE()),
(27, 27, 'Salsa Sensations', 'TRUE', GETDATE(), GETDATE()),
(28, 28, 'K-pop Kraze', 'TRUE', GETDATE(), GETDATE()),
(29, 29, 'C-pop Classics', 'FALSE', GETDATE(), GETDATE()),
(30, 30, 'J-pop Gems', 'TRUE', GETDATE(), GETDATE());




INSERT INTO Playlist_Songs (playlist_song_id, playlist_id, song_id)
VALUES
(1, 1, 1),
(2, 1, 4),
(3, 1, 7),
(4, 1, 10),
(5, 1, 14),
(6, 1, 17),
(7, 1, 20),
(8, 1, 23),
(9, 1, 26),
(10, 1, 29),
(11, 2, 2),
(12, 2, 5),
(13, 2, 8),
(14, 2, 11),
(15, 2, 14),
(16, 2, 17),
(17, 2, 20),
(18, 2, 23),
(19, 2, 26),
(20, 2, 29),
(21, 3, 3),
(22, 3, 6),
(23, 3, 9),
(24, 3, 12),
(25, 3, 15),
(26, 3, 18),
(27, 3, 21),
(28, 3, 24),
(29, 3, 27),
(30, 3, 30);




INSERT INTO Follows (follow_id, follower_id, followed_id)
VALUES
(1, 1, 2),
(2, 1, 3),
(3, 1, 4),
(4, 1, 5),
(5, 1, 6),
(6, 1, 7),
(7, 1, 8),
(8, 1, 9),
(9, 1, 10),
(10, 1, 11),
(11, 2, 1),
(12, 2, 3),
(13, 2, 4),
(14, 2, 5),
(15, 2, 6),
(16, 2, 7),
(17, 2, 8),
(18, 2, 9),
(19, 2, 10),
(20, 2, 11),
(21, 3, 1),
(22, 3, 2),
(23, 3, 4),
(24, 3, 5),
(25, 3, 6),
(26, 3, 7),
(27, 3, 8),
(28, 3, 9),
(29, 3, 10),
(30, 3, 11);




INSERT INTO Likes (like_id, user_id, item_id, item_type, time_liked)
VALUES
(1, 1, 1, 'Song', GETDATE()),
(2, 1, 2, 'Song', GETDATE()),
(3, 1, 3, 'Song', GETDATE()),
(4, 1, 4, 'Song', GETDATE()),
(5, 1, 5, 'Song', GETDATE()),
(6, 1, 6, 'Song', GETDATE()),
(7, 1, 7, 'Song', GETDATE()),
(8, 1, 8, 'Song', GETDATE()),
(9, 1, 9, 'Song', GETDATE()),
(10, 1, 10, 'Song', GETDATE()),
(11, 2, 11, 'Song', GETDATE()),
(12, 2, 12, 'Song', GETDATE()),
(13, 2, 13, 'Song', GETDATE()),
(14, 2, 14, 'Song', GETDATE()),
(15, 2, 15, 'Song', GETDATE()),
(16, 2, 16, 'Song', GETDATE()),
(17, 2, 17, 'Song', GETDATE()),
(18, 2, 18, 'Song', GETDATE()),
(19, 2, 19, 'Song', GETDATE()),
(20, 2, 20, 'Song', GETDATE()),
(21, 3, 21, 'Song', GETDATE()),
(22, 3, 22, 'Song', GETDATE()),
(23, 3, 23, 'Song', GETDATE()),
(24, 3, 24, 'Song', GETDATE()),
(25, 3, 25, 'Song', GETDATE()),
(26, 3, 26, 'Song', GETDATE()),
(27, 3, 27, 'Song', GETDATE()),
(28, 3, 28, 'Song', GETDATE()),
(29, 3, 29, 'Song', GETDATE()),
(30, 3, 30, 'Song', GETDATE());




INSERT INTO Comments (comment_id, user_id, item_id, item_type, comment_text, time_commented, time_updated)
VALUES
(1, 1, 1, 'Song', 'This song is a classic!', GETDATE(), GETDATE()),
(2, 1, 2, 'Song', 'Great lyrics!', GETDATE(), GETDATE()),
(3, 1, 3, 'Song', 'Love the beat.', GETDATE(), GETDATE()),
(4, 1, 4, 'Song', 'Amazing guitar solos.', GETDATE(), GETDATE()),
(5, 1, 5, 'Song', 'This track is fire!', GETDATE(), GETDATE()),
(6, 1, 6, 'Song', 'Can listen to this all day.', GETDATE(), GETDATE()),
(7, 1, 7, 'Song', 'Such a soothing melody.', GETDATE(), GETDATE()),
(8, 1, 8, 'Song', 'Brings back memories.', GETDATE(), GETDATE()),
(9, 1, 9, 'Song', 'The vocals are incredible.', GETDATE(), GETDATE()),
(10, 1, 10, 'Song', 'A masterpiece!', GETDATE(), GETDATE()),
(11, 2, 11, 'Song', 'My favorite song ever.', GETDATE(), GETDATE()),
(12, 2, 12, 'Song', 'This is so catchy!', GETDATE(), GETDATE()),
(13, 2, 13, 'Song', 'I love the rhythm.', GETDATE(), GETDATE()),
(14, 2, 14, 'Song', 'Absolutely stunning.', GETDATE(), GETDATE()),
(15, 2, 15, 'Song', 'Can’t stop listening to this.', GETDATE(), GETDATE()),
(16, 2, 16, 'Song', 'Incredible energy.', GETDATE(), GETDATE()),
(17, 2, 17, 'Song', 'Such a powerful message.', GETDATE(), GETDATE()),
(18, 2, 18, 'Song', 'The production quality is top-notch.', GETDATE(), GETDATE()),
(19, 2, 19, 'Song', 'This song always lifts my mood.', GETDATE(), GETDATE()),
(20, 2, 20, 'Song', 'A great addition to my playlist.', GETDATE(), GETDATE()),
(21, 3, 21, 'Song', 'Loved every second of it.', GETDATE(), GETDATE()),
(22, 3, 22, 'Song', 'This is so inspiring.', GETDATE(), GETDATE()),
(23, 3, 23, 'Song', 'Amazing performance!', GETDATE(), GETDATE()),
(24, 3, 24, 'Song', 'A beautiful composition.', GETDATE(), GETDATE()),
(25, 3, 25, 'Song', 'Such a heartfelt song.', GETDATE(), GETDATE()),
(26, 3, 26, 'Song', 'The drums are phenomenal.', GETDATE(), GETDATE()),
(27, 3, 27, 'Song', 'This song never gets old.', GETDATE(), GETDATE()),
(28, 3, 28, 'Song', 'The chorus is so catchy.', GETDATE(), GETDATE()),
(29, 3, 29, 'Song', 'Exceptional talent displayed.', GETDATE(), GETDATE()),
(30, 3, 30, 'Song', 'An absolute gem!', GETDATE(), GETDATE());




INSERT INTO Notifications (notification_id, user_id, type, message, time_sent, is_read)
VALUES
(1, 1, 'Follow', 'asmith followed you.', GETDATE(), 'FALSE'),
(2, 1, 'Like', 'kmiller liked your song.', GETDATE(), 'FALSE'),
(3, 1, 'Comment', 'jdoe commented on your song.', GETDATE(), 'TRUE'),
(4, 1, 'Follow', 'kpopfan followed you.', GETDATE(), 'FALSE'),
(5, 1, 'Like', 'indiepoplover liked your song.', GETDATE(), 'TRUE'),
(6, 1, 'Comment', 'emoheart commented on your song.', GETDATE(), 'FALSE'),
(7, 1, 'Follow', 'afrofuturist followed you.', GETDATE(), 'TRUE'),
(8, 1, 'Like', 'pianomaster liked your song.', GETDATE(), 'FALSE'),
(9, 1, 'Comment', 'musicaltheaterfan commented on your song.', GETDATE(), 'TRUE'),
(10, 1, 'Follow', 'vintagevinyl followed you.', GETDATE(), 'FALSE'),
(11, 2, 'Like', 'rnblover liked your song.', GETDATE(), 'FALSE'),
(12, 2, 'Comment', 'harmonyseekers commented on your song.', GETDATE(), 'TRUE'),
(13, 2, 'Follow', 'acapellaperson followed you.', GETDATE(), 'FALSE'),
(14, 2, 'Like', 'musiclover01 liked your song.', GETDATE(), 'TRUE'),
(15, 2, 'Comment', 'rockfan22 commented on your song.', GETDATE(), 'FALSE'),
(16, 2, 'Follow', 'jazzenthusiast followed you.', GETDATE(), 'TRUE'),
(17, 2, 'Like', 'popfanatic liked your song.', GETDATE(), 'FALSE'),
(18, 2, 'Comment', 'indiefan99 commented on your song.', GETDATE(), 'TRUE'),
(19, 2, 'Follow', 'folklover77 followed you.', GETDATE(), 'FALSE'),
(20, 2, 'Like', 'bluesbrother liked your song.', GETDATE(), 'TRUE'),
(21, 3, 'Comment', 'classicrockstar commented on your song.', GETDATE(), 'FALSE'),
(22, 3, 'Follow', 'musicmaven followed you.', GETDATE(), 'TRUE'),
(23, 3, 'Like', 'soulfulsinger liked your song.', GETDATE(), 'FALSE'),
(24, 3, 'Comment', 'dancemaster commented on your song.', GETDATE(), 'TRUE'),
(25, 3, 'Follow', 'metalhead84 followed you.', GETDATE(), 'FALSE'),
(26, 3, 'Like', 'rhythmking liked your song.', GETDATE(), 'TRUE'),
(27, 3, 'Comment', 'rapfanatic commented on your song.', GETDATE(), 'FALSE'),
(28, 3, 'Follow', 'singer23 followed you.', GETDATE(), 'TRUE'),
(29, 3, 'Like', 'oldieslover liked your song.', GETDATE(), 'FALSE'),
(30, 3, 'Comment', 'popculturejunkie commented on your song.', GETDATE(), 'TRUE');




INSERT INTO Reports (report_id, user_id, item_id, item_type, reason, status, time_reported)
VALUES
(1, 1, 1, 'Song', 'Inappropriate lyrics', 'Pending', GETDATE()),
(2, 2, 3, 'Song', 'Copyright issue', 'Resolved', GETDATE()),
(3, 3, 2, 'Song', 'Explicit content', 'Pending', GETDATE()),
(4, 4, 4, 'Song', 'Offensive language', 'Resolved', GETDATE()),
(5, 5, 5, 'Song', 'Spam', 'Pending', GETDATE()),
(6, 6, 6, 'Song', 'Harassment', 'Resolved', GETDATE()),
(7, 7, 7, 'Song', 'Copyright violation', 'Pending', GETDATE()),
(8, 8, 8, 'Song', 'Fake content', 'Resolved', GETDATE()),
(9, 9, 9, 'Song', 'Inappropriate cover art', 'Pending', GETDATE()),
(10, 10, 10, 'Song', 'Plagiarism', 'Resolved', GETDATE()),
(11, 11, 11, 'Song', 'Misinformation', 'Pending', GETDATE()),
(12, 12, 12, 'Song', 'Violence', 'Resolved', GETDATE()),
(13, 13, 13, 'Song', 'Discrimination', 'Pending', GETDATE()),
(14, 14, 14, 'Song', 'Privacy violation', 'Resolved', GETDATE()),
(15, 15, 15, 'Song', 'Inappropriate lyrics', 'Pending', GETDATE()),
(16, 16, 16, 'Song', 'Spam', 'Resolved', GETDATE()),
(17, 17, 17, 'Song', 'Harassment', 'Pending', GETDATE()),
(18, 18, 18, 'Song', 'Fake content', 'Resolved', GETDATE()),
(19, 19, 19, 'Song', 'Inappropriate cover art', 'Pending', GETDATE()),
(20, 20, 20, 'Song', 'Plagiarism', 'Resolved', GETDATE()),
(21, 21, 21, 'Song', 'Misinformation', 'Pending', GETDATE()),
(22, 22, 22, 'Song', 'Violence', 'Resolved', GETDATE()),
(23, 23, 23, 'Song', 'Discrimination', 'Pending', GETDATE()),
(24, 24, 24, 'Song', 'Privacy violation', 'Resolved', GETDATE()),
(25, 25, 25, 'Song', 'Inappropriate lyrics', 'Pending', GETDATE()),
(26, 26, 26, 'Song', 'Spam', 'Resolved', GETDATE()),
(27, 27, 27, 'Song', 'Harassment', 'Pending', GETDATE()),
(28, 28, 28, 'Song', 'Fake content', 'Resolved', GETDATE()),
(29, 29, 29, 'Song', 'Inappropriate cover art', 'Pending', GETDATE()),
(30, 30, 30, 'Song', 'Plagiarism', 'Resolved', GETDATE());




INSERT INTO Activity_Feed (activity_id, user_id, action, item_id, item_type, activity_time)
VALUES
(1, 1, 'created_playlist', 1, 'Playlist', GETDATE()),
(2, 2, 'liked_song', 3, 'Song', GETDATE()),
(3, 3, 'commented', 2, 'Song', GETDATE()),
(4, 4, 'created_playlist', 2, 'Playlist', GETDATE()),
(5, 5, 'liked_song', 5, 'Song', GETDATE()),
(6, 6, 'commented', 6, 'Song', GETDATE()),
(7, 7, 'created_playlist', 3, 'Playlist', GETDATE()),
(8, 8, 'liked_song', 8, 'Song', GETDATE()),
(9, 9, 'commented', 9, 'Song', GETDATE()),
(10, 10, 'created_playlist', 4, 'Playlist', GETDATE()),
(11, 11, 'liked_song', 11, 'Song', GETDATE()),
(12, 12, 'commented', 12, 'Song', GETDATE()),
(13, 13, 'created_playlist', 5, 'Playlist', GETDATE()),
(14, 14, 'liked_song', 14, 'Song', GETDATE()),
(15, 15, 'commented', 15, 'Song', GETDATE()),
(16, 16, 'created_playlist', 6, 'Playlist', GETDATE()),
(17, 17, 'liked_song', 17, 'Song', GETDATE()),
(18, 18, 'commented', 18, 'Song', GETDATE()),
(19, 19, 'created_playlist', 7, 'Playlist', GETDATE()),
(20, 20, 'liked_song', 20, 'Song', GETDATE()),
(21, 21, 'commented', 21, 'Song', GETDATE()),
(22, 22, 'created_playlist', 8, 'Playlist', GETDATE()),
(23, 23, 'liked_song', 23, 'Song', GETDATE()),
(24, 24, 'commented', 24, 'Song', GETDATE()),
(25, 25, 'created_playlist', 9, 'Playlist', GETDATE()),
(26, 26, 'liked_song', 26, 'Song', GETDATE()),
(27, 27, 'commented', 27, 'Song', GETDATE()),
(28, 28, 'created_playlist', 10, 'Playlist', GETDATE()),
(29, 29, 'liked_song', 29, 'Song', GETDATE()),
(30, 30, 'commented', 30, 'Song', GETDATE());






INSERT INTO Contribution_Album_Table (album_id, artist_id, contribution)
VALUES
(1, 30, 'Vocals'),
(2, 3, 'Production'),
(3, 2, 'Vocals'),
(4, 1, 'Guitar'),
(5, 4, 'Vocals'),
(6, 5, 'Guitar'),
(7, 30, 'Vocals'),
(8, 6, 'Saxophone'),
(9, 7, 'Piano'),
(10, 8, 'Vocals'),
(11, 9, 'Drums'),
(12, 10, 'Vocals'),
(13, 11, 'Guitar'),
(14, 12, 'Vocals'),
(15, 13, 'Guitar'),
(16, 14, 'Lyrics'),
(17, 15, 'Vocals'),
(18, 16, 'Vocals'),
(19, 17, 'Lyrics'),
(20, 18, 'Vocals'),
(21, 19, 'Guitar'),
(22, 20, 'Vocals'),
(23, 21, 'Vocals'),
(24, 22, 'Vocals'),
(25, 23, 'Vocals'),
(26, 24, 'Vocals'),
(27, 25, 'Vocals'),
(28, 26, 'Vocals'),
(29, 27, 'Vocals'),
(30, 28, 'Vocals');




INSERT INTO Contribution_Song_Table (song_id, artist_id, contribution)
VALUES
(1, 30, 'Vocals'),
(2, 3, 'Lyrics'),
(3, 2, 'Vocals'),
(4, 1, 'Guitar'),
(5, 4, 'Vocals'),
(6, 5, 'Guitar'),
(7, 30, 'Vocals'),
(8, 6, 'Saxophone'),
(9, 7, 'Piano'),
(10, 8, 'Vocals'),
(11, 9, 'Drums'),
(12, 10, 'Vocals'),
(13, 11, 'Guitar'),
(14, 12, 'Vocals'),
(15, 13, 'Guitar'),
(16, 14, 'Lyrics'),
(17, 15, 'Vocals'),
(18, 16, 'Vocals'),
(19, 17, 'Lyrics'),
(20, 18, 'Vocals'),
(21, 19, 'Guitar'),
(22, 20, 'Vocals'),
(23, 21, 'Vocals'),
(24, 22, 'Vocals'),
(25, 23, 'Vocals'),
(26, 24, 'Vocals'),
(27, 25, 'Vocals'),
(28, 26, 'Vocals'),
(29, 27, 'Vocals'),
(30, 28, 'Vocals');







/*
SELECT * FROM Users;
SELECT * FROM Artists;
SELECT * FROM Albums;
SELECT * FROM Genres;
SELECT * FROM Songs;
SELECT * FROM Playlists;
SELECT * FROM Playlist_Songs;
SELECT * FROM Follows;
SELECT * FROM Likes;
SELECT * FROM Comments;
SELECT * FROM Notifications;
SELECT * FROM Reports;
SELECT * FROM Activity_Feed;
SELECT * FROM Contribution_Album_Table;
SELECT * FROM Contribution_Song_Table;
*/
GO
