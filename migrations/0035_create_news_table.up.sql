-- News for players, newest first: announcements staff write, and maps ranked
-- or loved, written as their status changes. A map's item names its set and,
-- for one difficulty, the map; author_id is who wrote it or changed the status.

CREATE TABLE news (
  id int NOT NULL AUTO_INCREMENT,
  kind enum('announcement', 'ranked', 'loved') NOT NULL,
  title varchar(255) NOT NULL,
  body text NULL,
  url varchar(512) NULL,
  author_id int NULL,
  beatmapset_id int NULL,
  beatmap_id int NULL,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY news_created_at (created_at)
);
