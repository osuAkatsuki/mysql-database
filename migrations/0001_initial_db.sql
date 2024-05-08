-- MySQL dump 10.13  Distrib 8.0.33, for Linux (x86_64)
--
-- Host: localhost    Database: akatsuki
-- ------------------------------------------------------
-- Server version	8.0.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `__EFMigrationsHistory`
--

DROP TABLE IF EXISTS `__EFMigrationsHistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `__EFMigrationsHistory` (
  `migration_id` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `product_version` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`migration_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_sqlx_migrations`
--

DROP TABLE IF EXISTS `_sqlx_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_sqlx_migrations` (
  `version` bigint NOT NULL,
  `description` text NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `success` tinyint(1) NOT NULL,
  `checksum` blob NOT NULL,
  `execution_time` bigint NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `achievements`
--

DROP TABLE IF EXISTS `achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievements` (
  `id` int NOT NULL,
  `name` varchar(32) NOT NULL,
  `description` varchar(128) NOT NULL,
  `icon` varchar(32) NOT NULL,
  `version` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aika_akatsuki`
--

DROP TABLE IF EXISTS `aika_akatsuki`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aika_akatsuki` (
  `discordid` bigint NOT NULL,
  `osu_id` int DEFAULT NULL,
  PRIMARY KEY (`discordid`),
  CONSTRAINT `aika_akatsuki_aika_users_discordid_fk` FOREIGN KEY (`discordid`) REFERENCES `aika_users` (`discordid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aika_faq`
--

DROP TABLE IF EXISTS `aika_faq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aika_faq` (
  `id` int NOT NULL AUTO_INCREMENT,
  `topic` varchar(32) NOT NULL,
  `title` varchar(55) NOT NULL,
  `content` mediumtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aika_faq_id_uindex` (`id`),
  UNIQUE KEY `aika_faq_title_uindex` (`title`),
  UNIQUE KEY `aika_faq_topic_uindex` (`topic`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aika_guilds`
--

DROP TABLE IF EXISTS `aika_guilds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aika_guilds` (
  `guildid` bigint NOT NULL,
  `cmd_prefix` varchar(8) NOT NULL DEFAULT '!',
  `max_strikes` smallint NOT NULL DEFAULT '3',
  `moderation` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`guildid`),
  UNIQUE KEY `aika_guilds_guildid_uindex` (`guildid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aika_settings`
--

DROP TABLE IF EXISTS `aika_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aika_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `value_int` float DEFAULT NULL,
  `value_string` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aika_settings_key_uindex` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aika_strikes`
--

DROP TABLE IF EXISTS `aika_strikes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aika_strikes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `discordid` bigint NOT NULL,
  `guildid` bigint NOT NULL,
  `time` datetime NOT NULL,
  `reason` varchar(256) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aika_users`
--

DROP TABLE IF EXISTS `aika_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aika_users` (
  `discordid` bigint NOT NULL,
  `guildid` bigint NOT NULL,
  `xp` int NOT NULL DEFAULT '0',
  `last_xp` int NOT NULL DEFAULT '0',
  `muted_until` int DEFAULT '0',
  `notes` varchar(2048) DEFAULT NULL COMMENT 'Probably enough space?',
  PRIMARY KEY (`discordid`,`guildid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aika_users_old`
--

DROP TABLE IF EXISTS `aika_users_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aika_users_old` (
  `id` bigint NOT NULL,
  `xp_cooldown` int NOT NULL DEFAULT '0',
  `osu_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `aika_users_id_uindex` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_analyzes`
--

DROP TABLE IF EXISTS `anticheat_analyzes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_analyzes` (
  `score_id` bigint unsigned NOT NULL,
  `frametime` float(6,2) NOT NULL COMMENT 'not being calculated yet',
  `unstable_rate` float(6,2) NOT NULL COMMENT 'not being calculated yet',
  `cheats_found` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `relax` tinyint NOT NULL,
  `token` mediumtext,
  PRIMARY KEY (`score_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_detections`
--

DROP TABLE IF EXISTS `anticheat_detections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_detections` (
  `row_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `cheat_category` int NOT NULL,
  `detection_method` int NOT NULL,
  `detection` mediumtext NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`row_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1122 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_function_checksums`
--

DROP TABLE IF EXISTS `anticheat_function_checksums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_function_checksums` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type_name` varchar(256) NOT NULL,
  `method_name` varchar(256) NOT NULL,
  `checksum` char(32) NOT NULL,
  `cheat` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type_name` (`type_name`,`method_name`,`checksum`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_hardware`
--

DROP TABLE IF EXISTS `anticheat_hardware`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_hardware` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `uninstall_id` varchar(255) NOT NULL,
  `occurrences` int NOT NULL DEFAULT '1',
  `disk_serial` char(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`uninstall_id`,`disk_serial`)
) ENGINE=InnoDB AUTO_INCREMENT=4308862 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_instruction_patterns`
--

DROP TABLE IF EXISTS `anticheat_instruction_patterns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_instruction_patterns` (
  `cheat_name` varchar(191) NOT NULL,
  `instructions` mediumtext NOT NULL,
  `function_name` varchar(256) NOT NULL,
  PRIMARY KEY (`cheat_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_queue`
--

DROP TABLE IF EXISTS `anticheat_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_queue` (
  `user_id` int NOT NULL,
  `earliest_relevant_flag` datetime NOT NULL,
  `ban_time` datetime NOT NULL,
  `related_flags` json DEFAULT NULL,
  `fulfilled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`ban_time`),
  KEY `fulfilled` (`fulfilled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_reports`
--

DROP TABLE IF EXISTS `anticheat_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_reports` (
  `report_id` bigint unsigned NOT NULL,
  `raw_token` mediumtext NOT NULL,
  `user_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_results`
--

DROP TABLE IF EXISTS `anticheat_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_results` (
  `score_id` bigint unsigned NOT NULL,
  `relax` tinyint NOT NULL,
  `frametime` float(6,2) NOT NULL,
  `unstable_rate` float(6,2) NOT NULL,
  `osu_version` text NOT NULL,
  `score_iv_b64` text NOT NULL,
  `score_data_b64` text NOT NULL,
  `client_hash_b64` text NOT NULL,
  `token` mediumtext,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `disk_id_md5` char(32) DEFAULT NULL,
  `uninstall_id_md5` char(32) DEFAULT NULL,
  PRIMARY KEY (`score_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anticheat_urls`
--

DROP TABLE IF EXISTS `anticheat_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `anticheat_urls` (
  `file` varchar(191) NOT NULL,
  `url` varchar(191) NOT NULL,
  PRIMARY KEY (`file`),
  UNIQUE KEY `file` (`file`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `badges`
--

DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `badges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `icon` varchar(64) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `colour` varchar(24) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bancho_channels`
--

DROP TABLE IF EXISTS `bancho_channels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bancho_channels` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `description` varchar(127) NOT NULL,
  `public_read` tinyint NOT NULL,
  `public_write` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  `temp` tinyint(1) NOT NULL DEFAULT '0',
  `hidden` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bancho_settings`
--

DROP TABLE IF EXISTS `bancho_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bancho_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `value_int` int NOT NULL DEFAULT '0',
  `value_string` varchar(512) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `beatmap_difficulties`
--

DROP TABLE IF EXISTS `beatmap_difficulties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `beatmap_difficulties` (
  `beatmap_md5` varchar(32) NOT NULL,
  `mode` int NOT NULL,
  `mods` int NOT NULL,
  `diff` float NOT NULL,
  PRIMARY KEY (`beatmap_md5`,`mode`,`mods`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `beatmaps`
--

DROP TABLE IF EXISTS `beatmaps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `beatmaps` (
  `beatmap_id` int NOT NULL,
  `beatmapset_id` int NOT NULL,
  `beatmap_md5` char(32) NOT NULL,
  `song_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `file_name` varchar(260) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ar` float NOT NULL,
  `od` float NOT NULL,
  `mode` int NOT NULL,
  `max_combo` int NOT NULL,
  `hit_length` int NOT NULL,
  `bpm` int NOT NULL,
  `ranked` tinyint NOT NULL,
  `latest_update` int NOT NULL,
  `ranked_status_freezed` tinyint(1) NOT NULL,
  `playcount` int NOT NULL,
  `passcount` int NOT NULL,
  `rankedby` mediumint DEFAULT NULL,
  `rating` float(15,12) NOT NULL,
  PRIMARY KEY (`beatmap_id`),
  UNIQUE KEY `beatmap_md5` (`beatmap_md5`) USING BTREE,
  KEY `beatmapset_id` (`beatmapset_id`),
  KEY `ranked` (`ranked`),
  KEY `mode` (`mode`),
  KEY `rating` (`rating`),
  KEY `song_name` (`song_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `beatmaps_playcounts`
--

DROP TABLE IF EXISTS `beatmaps_playcounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `beatmaps_playcounts` (
  `user` int NOT NULL,
  `beatmap` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `mode` tinyint NOT NULL,
  `relax` tinyint NOT NULL,
  `count` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`mode`,`user`,`beatmap`,`relax`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `beatmaps_rating`
--

DROP TABLE IF EXISTS `beatmaps_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `beatmaps_rating` (
  `id` int NOT NULL AUTO_INCREMENT,
  `beatmap_md5` varchar(256) NOT NULL,
  `user_id` int NOT NULL,
  `rating` float NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `beatmap_md5` (`beatmap_md5`),
  KEY `rating` (`rating`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28786 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blacklisted_ips`
--

DROP TABLE IF EXISTS `blacklisted_ips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blacklisted_ips` (
  `ip` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cakes`
--

DROP TABLE IF EXISTS `cakes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cakes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL,
  `score_id` int NOT NULL,
  `processes` blob NOT NULL,
  `detected` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `flags` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `userid` (`userid`),
  KEY `score_id` (`score_id`)
) ENGINE=InnoDB AUTO_INCREMENT=72673 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clan_requests`
--

DROP TABLE IF EXISTS `clan_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clan_requests` (
  `clan` int NOT NULL,
  `user` int NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`clan`,`user`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clans`
--

DROP TABLE IF EXISTS `clans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tag` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `description` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT ' ',
  `icon` varchar(1024) DEFAULT ' ',
  `background` varchar(1024) NOT NULL DEFAULT ' ',
  `owner` int DEFAULT NULL,
  `invite` varchar(8) DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '2',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `tag` (`tag`),
  UNIQUE KEY `clans_invit_uindex` (`invite`),
  UNIQUE KEY `owner` (`owner`) USING BTREE,
  KEY `status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=7122 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `comment` varchar(128) NOT NULL,
  `time` bigint NOT NULL,
  `who` enum('normal','player','admin','donor') NOT NULL,
  `special_format` varchar(64) DEFAULT NULL,
  `beatmapset_id` int DEFAULT '0',
  `beatmap_id` int NOT NULL DEFAULT '0',
  `score_id` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `beatmapset_id` (`beatmapset_id`),
  KEY `beatmap_id` (`beatmap_id`),
  KEY `score_id` (`score_id`),
  KEY `time` (`time`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1062 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `db_versions`
--

DROP TABLE IF EXISTS `db_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `db_versions` (
  `version` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `eggs`
--

DROP TABLE IF EXISTS `eggs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eggs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` enum('hash','path','file','title') NOT NULL DEFAULT 'hash',
  `value` varchar(128) NOT NULL,
  `tag` varchar(128) NOT NULL,
  `ban` tinyint(1) NOT NULL DEFAULT '0',
  `is_regex` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `faq`
--

DROP TABLE IF EXISTS `faq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faq` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(32) DEFAULT NULL,
  `callback` varchar(2048) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name_2` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `help_logs`
--

DROP TABLE IF EXISTS `help_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `help_logs` (
  `id` mediumint NOT NULL AUTO_INCREMENT,
  `user` bigint DEFAULT NULL,
  `content` varchar(2000) DEFAULT NULL,
  `datetime` int NOT NULL,
  `quality` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  KEY `datetime` (`datetime`),
  KEY `content` (`content`(767)),
  KEY `user_2` (`user`,`quality`),
  KEY `quality` (`quality`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=22661 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hw_comparison`
--

DROP TABLE IF EXISTS `hw_comparison`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hw_comparison` (
  `id` int NOT NULL,
  `mac` varchar(32) NOT NULL,
  `unique` varchar(32) NOT NULL,
  `disk` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `table_name_disk_uindex` (`disk`),
  UNIQUE KEY `table_name_id_uindex` (`id`),
  UNIQUE KEY `table_name_mac_uindex` (`mac`),
  UNIQUE KEY `table_name_unique_uindex` (`unique`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hw_user`
--

DROP TABLE IF EXISTS `hw_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hw_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL,
  `mac` varchar(32) NOT NULL,
  `unique_id` varchar(32) NOT NULL,
  `disk_id` varchar(32) NOT NULL,
  `occurencies` int NOT NULL DEFAULT '0',
  `activated` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `mac` (`mac`),
  KEY `unique_id` (`unique_id`),
  KEY `disk_id` (`disk_id`),
  KEY `userid` (`userid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5544666 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `identity_tokens`
--

DROP TABLE IF EXISTS `identity_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_tokens` (
  `userid` int NOT NULL,
  `token` varchar(64) NOT NULL,
  PRIMARY KEY (`userid`),
  KEY `token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ip_user`
--

DROP TABLE IF EXISTS `ip_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ip_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL,
  `ip` varchar(39) NOT NULL,
  `occurencies` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userid_2` (`userid`,`ip`),
  KEY `userid` (`userid`),
  KEY `occurencies` (`occurencies`)
) ENGINE=InnoDB AUTO_INCREMENT=56463301 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `irc_tokens`
--

DROP TABLE IF EXISTS `irc_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `irc_tokens` (
  `userid` int NOT NULL,
  `token` varchar(32) NOT NULL,
  PRIMARY KEY (`userid`),
  UNIQUE KEY `token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `known_cheat_checksums`
--

DROP TABLE IF EXISTS `known_cheat_checksums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `known_cheat_checksums` (
  `id` int NOT NULL AUTO_INCREMENT,
  `checksum` char(32) NOT NULL,
  `cheat_name` varchar(256) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lastfm_flags`
--

DROP TABLE IF EXISTS `lastfm_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lastfm_flags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `timestamp` int NOT NULL,
  `flag_enum` int NOT NULL,
  `flag_text` varchar(512) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40579 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `less_achievements`
--

DROP TABLE IF EXISTS `less_achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `less_achievements` (
  `id` int NOT NULL DEFAULT '0',
  `file` varchar(128) NOT NULL,
  `name` varchar(128) NOT NULL,
  `desc` varchar(128) NOT NULL,
  `cond` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loader_versions`
--

DROP TABLE IF EXISTS `loader_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loader_versions` (
  `id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `version` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `hash` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `created_by` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `main_menu_icons`
--

DROP TABLE IF EXISTS `main_menu_icons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `main_menu_icons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `file_id` varchar(128) NOT NULL,
  `url` varchar(512) NOT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `is_current` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `match_events`
--

DROP TABLE IF EXISTS `match_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `match_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `match_id` int NOT NULL,
  `game_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `event_type` varchar(255) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `match_lookup` (`match_id`,`game_id`,`user_id`,`timestamp`)
) ENGINE=InnoDB AUTO_INCREMENT=123785 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `match_game_scores`
--

DROP TABLE IF EXISTS `match_game_scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `match_game_scores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `match_id` int NOT NULL,
  `game_id` int NOT NULL,
  `user_id` int NOT NULL,
  `mode` tinyint(1) NOT NULL,
  `count_300` smallint NOT NULL,
  `count_100` smallint NOT NULL,
  `count_50` smallint NOT NULL,
  `count_miss` smallint NOT NULL,
  `count_geki` smallint NOT NULL,
  `count_katu` smallint NOT NULL,
  `score` int NOT NULL,
  `accuracy` float(6,3) NOT NULL,
  `max_combo` int NOT NULL,
  `mods` int NOT NULL,
  `passed` tinyint(1) NOT NULL,
  `team` tinyint(1) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `match_lookup` (`match_id`,`game_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=88527 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `match_games`
--

DROP TABLE IF EXISTS `match_games`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `match_games` (
  `id` int NOT NULL AUTO_INCREMENT,
  `match_id` int NOT NULL,
  `beatmap_id` int NOT NULL,
  `mode` tinyint(1) NOT NULL,
  `mods` int DEFAULT NULL,
  `scoring_type` tinyint(1) NOT NULL,
  `team_type` tinyint(1) NOT NULL,
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `match_lookup` (`id`,`match_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43948 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `match_redirects`
--

DROP TABLE IF EXISTS `match_redirects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `match_redirects` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `canonic_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `matches`
--

DROP TABLE IF EXISTS `matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `matches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `private` tinyint(1) NOT NULL,
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `match_lookup` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5792 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `notification` json NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `osu_session`
--

DROP TABLE IF EXISTS `osu_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `osu_session` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user` int NOT NULL,
  `ip` varchar(32) NOT NULL,
  `operating_system` varchar(128) DEFAULT NULL,
  `fullscreen` tinyint(1) DEFAULT NULL,
  `framesync` varchar(16) DEFAULT NULL,
  `compatability_mode` tinyint(1) DEFAULT NULL,
  `spike_frame_count` int DEFAULT NULL,
  `aim_framerate` varchar(16) DEFAULT NULL,
  `completion` int DEFAULT NULL,
  `start_time` int DEFAULT NULL,
  `end_time` int DEFAULT NULL,
  `time` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `osu_session_id_uindex` (`id`),
  KEY `user` (`user`),
  KEY `spike_frame_count` (`spike_frame_count`),
  KEY `start_time` (`start_time`),
  KEY `end_time` (`end_time`)
) ENGINE=InnoDB AUTO_INCREMENT=5311527 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password_recovery`
--

DROP TABLE IF EXISTS `password_recovery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_recovery` (
  `id` int NOT NULL AUTO_INCREMENT,
  `k` varchar(80) NOT NULL,
  `u` varchar(30) NOT NULL,
  `t` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21140 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patcher_branch_versions`
--

DROP TABLE IF EXISTS `patcher_branch_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patcher_branch_versions` (
  `id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `branch` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `version` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `hash` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `created_by` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patcher_detections`
--

DROP TABLE IF EXISTS `patcher_detections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patcher_detections` (
  `id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `method_name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `method_assembly_hash` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `method_assembly_instructions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `patcher_token_log_id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_patcher_detections_patcher_token_log_id` (`patcher_token_log_id`),
  CONSTRAINT `fk_patcher_detections_patcher_token_logs_patcher_token_log_id` FOREIGN KEY (`patcher_token_log_id`) REFERENCES `patcher_token_logs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patcher_token_logs`
--

DROP TABLE IF EXISTS `patcher_token_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patcher_token_logs` (
  `id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `score_id` bigint NOT NULL,
  `client_hash` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `commentary` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `token_generated_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_limits`
--

DROP TABLE IF EXISTS `pp_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_limits` (
  `gamemode` tinyint(1) NOT NULL AUTO_INCREMENT,
  `pp` smallint NOT NULL,
  `relax_pp` smallint NOT NULL,
  `flashlight_pp` smallint NOT NULL,
  `relax_flashlight_pp` smallint NOT NULL,
  `autopilot_pp` int NOT NULL,
  `autopilot_flashlight_pp` int NOT NULL,
  PRIMARY KEY (`gamemode`),
  KEY `gamemode` (`gamemode`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `privileges_groups`
--

DROP TABLE IF EXISTS `privileges_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `privileges_groups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `privileges` int NOT NULL,
  `color` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `privileges` (`privileges`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `profile_backgrounds`
--

DROP TABLE IF EXISTS `profile_backgrounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profile_backgrounds` (
  `uid` int NOT NULL,
  `time` int NOT NULL,
  `type` int NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rank_requests`
--

DROP TABLE IF EXISTS `rank_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rank_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL,
  `bid` int NOT NULL,
  `type` varchar(8) NOT NULL,
  `time` int NOT NULL,
  `blacklisted` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid` (`bid`),
  KEY `type` (`type`),
  KEY `blacklisted` (`blacklisted`),
  KEY `time` (`time`)
) ENGINE=InnoDB AUTO_INCREMENT=2251 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rap_logs`
--

DROP TABLE IF EXISTS `rap_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rap_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL,
  `text` longtext NOT NULL,
  `datetime` int NOT NULL,
  `through` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `userid` (`userid`)
) ENGINE=InnoDB AUTO_INCREMENT=70111 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `remember`
--

DROP TABLE IF EXISTS `remember`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `remember` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL,
  `series_identifier` int DEFAULT NULL,
  `token_sha` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userid` (`userid`)
) ENGINE=InnoDB AUTO_INCREMENT=951 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reason` varchar(1024) NOT NULL,
  `time` varchar(18) NOT NULL,
  `from_uid` int NOT NULL,
  `to_uid` int NOT NULL,
  `chatlog` mediumtext,
  `response` varchar(1024) DEFAULT NULL,
  `assigned` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `assigned` (`assigned`),
  KEY `time` (`time`),
  KEY `from_uid` (`from_uid`),
  KEY `to_uid` (`to_uid`),
  KEY `from_uid_2` (`from_uid`,`to_uid`)
) ENGINE=InnoDB AUTO_INCREMENT=538 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rework_queue`
--

DROP TABLE IF EXISTS `rework_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rework_queue` (
  `user_id` int NOT NULL,
  `rework_id` int NOT NULL,
  `processed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`,`rework_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rework_scores`
--

DROP TABLE IF EXISTS `rework_scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rework_scores` (
  `score_id` bigint NOT NULL,
  `beatmap_id` int NOT NULL,
  `user_id` int NOT NULL,
  `rework_id` int NOT NULL,
  `max_combo` int NOT NULL,
  `mods` int NOT NULL,
  `accuracy` float NOT NULL,
  `score` bigint NOT NULL,
  `num_300s` int NOT NULL,
  `num_100s` int NOT NULL,
  `num_50s` int NOT NULL,
  `num_gekis` int NOT NULL,
  `num_katus` int NOT NULL,
  `num_misses` int NOT NULL,
  `old_pp` float NOT NULL,
  `new_pp` float NOT NULL,
  `beatmapset_id` int NOT NULL,
  PRIMARY KEY (`score_id`,`rework_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rework_stats`
--

DROP TABLE IF EXISTS `rework_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rework_stats` (
  `user_id` int NOT NULL,
  `rework_id` int NOT NULL,
  `old_pp` int NOT NULL,
  `new_pp` int NOT NULL,
  PRIMARY KEY (`user_id`,`rework_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reworks`
--

DROP TABLE IF EXISTS `reworks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reworks` (
  `rework_id` int NOT NULL AUTO_INCREMENT,
  `rework_name` varchar(256) NOT NULL,
  `mode` int NOT NULL,
  `rx` int NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rework_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scheduled_bans`
--

DROP TABLE IF EXISTS `scheduled_bans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scheduled_bans` (
  `id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `user_id` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `scheduled_for` datetime(6) NOT NULL,
  `completed_at` datetime(6) DEFAULT NULL,
  `cancelled_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `version` bigint NOT NULL,
  `dirty` tinyint(1) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_seeds`
--

DROP TABLE IF EXISTS `schema_seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_seeds` (
  `version` bigint NOT NULL,
  `dirty` tinyint(1) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `score_submission_logs`
--

DROP TABLE IF EXISTS `score_submission_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `score_submission_logs` (
  `id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `score_id` bigint NOT NULL,
  `uninstall_id_hash` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `disk_signature_hash` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `client_version` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `client_hash` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `score_time_elapsed` time(6) NOT NULL,
  `osu_auth_token` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scores`
--

DROP TABLE IF EXISTS `scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `beatmap_md5` char(32) NOT NULL DEFAULT '',
  `userid` int NOT NULL,
  `score` int NOT NULL DEFAULT '0',
  `max_combo` int NOT NULL DEFAULT '0',
  `full_combo` tinyint(1) NOT NULL DEFAULT '0',
  `mods` int NOT NULL DEFAULT '0',
  `300_count` smallint NOT NULL DEFAULT '0',
  `100_count` smallint NOT NULL DEFAULT '0',
  `50_count` smallint NOT NULL DEFAULT '0',
  `katus_count` smallint NOT NULL DEFAULT '0',
  `gekis_count` smallint NOT NULL DEFAULT '0',
  `misses_count` smallint NOT NULL DEFAULT '0',
  `time` int NOT NULL DEFAULT '0',
  `play_mode` tinyint(1) NOT NULL DEFAULT '0',
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `accuracy` float(6,3) NOT NULL DEFAULT '0.000',
  `pp` float NOT NULL DEFAULT '0',
  `checksum` char(32) DEFAULT NULL,
  `patcher` tinyint DEFAULT '0',
  `pinned` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `checksum` (`checksum`),
  KEY `userid` (`userid`),
  KEY `time` (`time`),
  KEY `mods` (`mods`),
  KEY `score` (`score`),
  KEY `beatmap_md5` (`beatmap_md5`),
  KEY `play_mode` (`play_mode`),
  KEY `completed` (`completed`),
  KEY `pp` (`pp`),
  KEY `modestatus` (`play_mode`,`completed`),
  KEY `scores_idx_beatmap_play_mo_complet_userid` (`beatmap_md5`,`play_mode`,`completed`,`userid`),
  KEY `scores_idx_beatmap_md_play_mode_completed` (`beatmap_md5`,`play_mode`,`completed`),
  KEY `scores_idx_userid_pinned_play_mode` (`userid`,`pinned`,`play_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=536142448 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT COMMENT='regular scores b';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scores_ap`
--

DROP TABLE IF EXISTS `scores_ap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scores_ap` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `beatmap_md5` varchar(32) NOT NULL DEFAULT '',
  `userid` int NOT NULL,
  `score` int NOT NULL DEFAULT '0',
  `max_combo` int NOT NULL DEFAULT '0',
  `full_combo` tinyint(1) NOT NULL DEFAULT '0',
  `mods` int NOT NULL DEFAULT '0',
  `300_count` smallint NOT NULL DEFAULT '0',
  `100_count` smallint NOT NULL DEFAULT '0',
  `50_count` smallint NOT NULL DEFAULT '0',
  `katus_count` smallint NOT NULL DEFAULT '0',
  `gekis_count` smallint NOT NULL DEFAULT '0',
  `misses_count` smallint NOT NULL DEFAULT '0',
  `time` int NOT NULL DEFAULT '0',
  `play_mode` tinyint(1) NOT NULL DEFAULT '0',
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `accuracy` float(6,3) NOT NULL DEFAULT '0.000',
  `pp` float NOT NULL DEFAULT '0',
  `checksum` char(32) DEFAULT NULL,
  `patcher` tinyint DEFAULT '0',
  `pinned` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `checksum` (`checksum`),
  KEY `userid` (`userid`),
  KEY `mods` (`mods`),
  KEY `score` (`score`),
  KEY `time` (`time`),
  KEY `beatmap_md5` (`beatmap_md5`),
  KEY `completed` (`completed`),
  KEY `play_mode` (`play_mode`),
  KEY `pp` (`pp`),
  KEY `modestatus` (`play_mode`,`completed`),
  KEY `scores_idx_beatmap_play_mo_complet_userid` (`beatmap_md5`,`play_mode`,`completed`,`userid`),
  KEY `scores_idx_beatmap_md_play_mode_completed` (`beatmap_md5`,`play_mode`,`completed`),
  KEY `scores_ap_idx_userid_pinned_play_mode` (`userid`,`pinned`,`play_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=6148914691237152585 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scores_first`
--

DROP TABLE IF EXISTS `scores_first`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scores_first` (
  `beatmap_md5` char(32) NOT NULL,
  `mode` tinyint(1) NOT NULL,
  `rx` tinyint(1) NOT NULL,
  `scoreid` bigint NOT NULL,
  `userid` int NOT NULL,
  PRIMARY KEY (`beatmap_md5`,`mode`,`rx`),
  UNIQUE KEY `scores_first_scoreid_uindex` (`scoreid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scores_relax`
--

DROP TABLE IF EXISTS `scores_relax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scores_relax` (
  `id` int NOT NULL AUTO_INCREMENT,
  `beatmap_md5` varchar(32) NOT NULL DEFAULT '',
  `userid` int NOT NULL,
  `score` int NOT NULL DEFAULT '0',
  `max_combo` int NOT NULL DEFAULT '0',
  `full_combo` tinyint(1) NOT NULL DEFAULT '0',
  `mods` int NOT NULL DEFAULT '0',
  `300_count` smallint NOT NULL DEFAULT '0',
  `100_count` smallint NOT NULL DEFAULT '0',
  `50_count` smallint NOT NULL DEFAULT '0',
  `katus_count` smallint NOT NULL DEFAULT '0',
  `gekis_count` smallint NOT NULL DEFAULT '0',
  `misses_count` smallint NOT NULL DEFAULT '0',
  `time` int NOT NULL DEFAULT '0',
  `play_mode` tinyint(1) NOT NULL DEFAULT '0',
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `accuracy` float(6,3) NOT NULL DEFAULT '0.000',
  `pp` float NOT NULL DEFAULT '0',
  `checksum` char(32) DEFAULT NULL,
  `patcher` tinyint DEFAULT '0',
  `pinned` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `checksum` (`checksum`),
  KEY `userid` (`userid`),
  KEY `mods` (`mods`),
  KEY `score` (`score`),
  KEY `time` (`time`),
  KEY `beatmap_md5` (`beatmap_md5`),
  KEY `completed` (`completed`),
  KEY `play_mode` (`play_mode`),
  KEY `pp` (`pp`),
  KEY `modestatus` (`play_mode`,`completed`),
  KEY `scores_relax_idx_beatmap_play_mo_complet_userid` (`beatmap_md5`,`play_mode`,`completed`,`userid`),
  KEY `scores_relax_idx_beatmap_md_play_mode_completed` (`beatmap_md5`,`play_mode`,`completed`),
  KEY `scores_relax_idx_userid_pinned_play_mode` (`userid`,`pinned`,`play_mode`),
  KEY `scores_relax_idx_userid_play_mode` (`userid`,`play_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=65656405 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scores_removed`
--

DROP TABLE IF EXISTS `scores_removed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scores_removed` (
  `id` int NOT NULL,
  `beatmap_md5` varchar(32) NOT NULL DEFAULT '',
  `userid` int NOT NULL,
  `score` int NOT NULL DEFAULT '0',
  `max_combo` int NOT NULL DEFAULT '0',
  `full_combo` tinyint(1) NOT NULL DEFAULT '0',
  `mods` int NOT NULL DEFAULT '0',
  `300_count` int NOT NULL DEFAULT '0',
  `100_count` int NOT NULL DEFAULT '0',
  `50_count` int NOT NULL DEFAULT '0',
  `katus_count` int NOT NULL DEFAULT '0',
  `gekis_count` int NOT NULL DEFAULT '0',
  `misses_count` int NOT NULL DEFAULT '0',
  `time` varchar(18) NOT NULL DEFAULT '',
  `play_mode` tinyint NOT NULL DEFAULT '0',
  `completed` tinyint NOT NULL DEFAULT '0',
  `accuracy` float(15,12) DEFAULT NULL,
  `pp` float NOT NULL DEFAULT '0',
  `anticheat_status` tinyint(1) NOT NULL DEFAULT '0',
  `disable_pp` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scores_removed_relax`
--

DROP TABLE IF EXISTS `scores_removed_relax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scores_removed_relax` (
  `id` int NOT NULL AUTO_INCREMENT,
  `beatmap_md5` varchar(32) NOT NULL DEFAULT '',
  `userid` int NOT NULL,
  `score` int NOT NULL DEFAULT '0',
  `max_combo` int NOT NULL DEFAULT '0',
  `full_combo` tinyint(1) NOT NULL DEFAULT '0',
  `mods` int NOT NULL DEFAULT '0',
  `300_count` smallint NOT NULL DEFAULT '0',
  `100_count` smallint NOT NULL DEFAULT '0',
  `50_count` smallint NOT NULL DEFAULT '0',
  `katus_count` smallint NOT NULL DEFAULT '0',
  `gekis_count` smallint NOT NULL DEFAULT '0',
  `misses_count` smallint NOT NULL DEFAULT '0',
  `time` int NOT NULL DEFAULT '0',
  `play_mode` tinyint(1) NOT NULL DEFAULT '0',
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `accuracy` float(15,12) DEFAULT '0.000000000000',
  `pp` float NOT NULL DEFAULT '0',
  `anticheat_status` tinyint(1) NOT NULL DEFAULT '0',
  `disable_pp` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `completed` (`completed`),
  KEY `pp` (`pp`),
  KEY `beatmap_md5` (`beatmap_md5`),
  KEY `userid` (`userid`),
  KEY `anticheat_status` (`anticheat_status`),
  KEY `play_mode` (`play_mode`),
  KEY `mods` (`mods`),
  KEY `score` (`score`),
  KEY `beatmap_md5_2` (`beatmap_md5`,`completed`),
  KEY `beatmap_md5_3` (`beatmap_md5`,`userid`,`play_mode`,`completed`)
) ENGINE=InnoDB AUTO_INCREMENT=22533383 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `seasonal_bg`
--

DROP TABLE IF EXISTS `seasonal_bg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seasonal_bg` (
  `id` int NOT NULL AUTO_INCREMENT,
  `enabled` tinyint(1) NOT NULL,
  `url` varchar(256) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `value_int` int NOT NULL DEFAULT '0',
  `value_string` varchar(2048) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tokens`
--

DROP TABLE IF EXISTS `tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user` mediumint NOT NULL,
  `privileges` tinyint(1) NOT NULL,
  `description` varchar(39) NOT NULL,
  `token` varchar(32) NOT NULL,
  `private` tinyint(1) NOT NULL,
  `last_updated` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `user` (`user`)
) ENGINE=InnoDB AUTO_INCREMENT=322803 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tourmnt_badges`
--

DROP TABLE IF EXISTS `tourmnt_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tourmnt_badges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(256) NOT NULL,
  `icon` varchar(256) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_badges`
--

DROP TABLE IF EXISTS `user_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_badges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user` int NOT NULL,
  `badge` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`)
) ENGINE=InnoDB AUTO_INCREMENT=5934 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_beatmaps`
--

DROP TABLE IF EXISTS `user_beatmaps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_beatmaps` (
  `userid` int NOT NULL,
  `map` char(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `rx` int NOT NULL,
  `mode` int NOT NULL,
  `count` int NOT NULL,
  PRIMARY KEY (`userid`,`map`,`rx`,`mode`) USING BTREE,
  KEY `count` (`count`),
  KEY `optimisemode` (`userid`,`rx`,`mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_clans`
--

DROP TABLE IF EXISTS `user_clans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_clans` (
  `user` mediumint NOT NULL DEFAULT '0',
  `clan` smallint NOT NULL DEFAULT '0',
  `perms` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user`),
  KEY `clan` (`clan`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_favourites`
--

DROP TABLE IF EXISTS `user_favourites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_favourites` (
  `user_id` int NOT NULL,
  `beatmapset_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`beatmapset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_profile_history`
--

DROP TABLE IF EXISTS `user_profile_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_profile_history` (
  `user_id` int NOT NULL,
  `mode` int NOT NULL,
  `captured_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `rank` int NOT NULL,
  `pp` int NOT NULL,
  `country_rank` int DEFAULT NULL,
  PRIMARY KEY (`user_id`,`mode`,`captured_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_stats`
--

DROP TABLE IF EXISTS `user_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_stats` (
  `user_id` int NOT NULL,
  `mode` smallint NOT NULL,
  `ranked_score` bigint unsigned NOT NULL DEFAULT '0',
  `total_score` bigint unsigned NOT NULL DEFAULT '0',
  `playcount` int unsigned NOT NULL DEFAULT '0',
  `replays_watched` int unsigned NOT NULL DEFAULT '0',
  `total_hits` int unsigned NOT NULL DEFAULT '0',
  `level` int unsigned NOT NULL DEFAULT '1',
  `avg_accuracy` double(15,12) NOT NULL DEFAULT '0.000000000000',
  `pp` int unsigned NOT NULL DEFAULT '0',
  `playtime` int unsigned NOT NULL DEFAULT '0',
  `xh_count` int unsigned NOT NULL DEFAULT '0',
  `x_count` int unsigned NOT NULL DEFAULT '0',
  `sh_count` int unsigned NOT NULL DEFAULT '0',
  `s_count` int unsigned NOT NULL DEFAULT '0',
  `a_count` int unsigned NOT NULL DEFAULT '0',
  `b_count` int unsigned NOT NULL DEFAULT '0',
  `c_count` int unsigned NOT NULL DEFAULT '0',
  `d_count` int unsigned NOT NULL DEFAULT '0',
  `max_combo` int unsigned NOT NULL DEFAULT '0',
  `latest_pp_awarded` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`mode`),
  KEY `user_id` (`user_id`),
  KEY `mode` (`mode`),
  KEY `pp` (`pp`),
  KEY `ranked_score` (`ranked_score`),
  KEY `total_score` (`total_score`),
  KEY `avg_accuracy` (`avg_accuracy`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_tokens`
--

DROP TABLE IF EXISTS `user_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_tokens` (
  `id` char(36) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_tourmnt_badges`
--

DROP TABLE IF EXISTS `user_tourmnt_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_tourmnt_badges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user` int NOT NULL,
  `badge` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(19) NOT NULL,
  `username_safe` varchar(19) NOT NULL,
  `password_md5` varchar(64) NOT NULL,
  `email` varchar(254) NOT NULL,
  `register_datetime` int NOT NULL,
  `latest_activity` int NOT NULL DEFAULT '0',
  `silence_end` int NOT NULL DEFAULT '0',
  `silence_reason` varchar(512) NOT NULL DEFAULT '',
  `privileges` int NOT NULL,
  `donor_expire` int NOT NULL DEFAULT '0',
  `frozen` int NOT NULL DEFAULT '0',
  `notes` longtext CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `ban_datetime` int NOT NULL DEFAULT '0',
  `switch_notifs` tinyint(1) NOT NULL DEFAULT '0',
  `previous_overwrite` int NOT NULL DEFAULT '0',
  `whitelist` tinyint(1) NOT NULL DEFAULT '0',
  `clan_id` int NOT NULL DEFAULT '0',
  `clan_privileges` int NOT NULL DEFAULT '0',
  `userpage_content` blob,
  `userpage_allowed` tinyint(1) NOT NULL DEFAULT '1',
  `freeze_reason` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `country` char(2) NOT NULL DEFAULT 'XX',
  `username_aka` varchar(19) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `can_custom_badge` tinyint(1) NOT NULL DEFAULT '0',
  `show_custom_badge` tinyint(1) NOT NULL DEFAULT '0',
  `custom_badge_icon` varchar(256) NOT NULL DEFAULT '',
  `custom_badge_name` varchar(128) NOT NULL DEFAULT '',
  `favourite_mode` smallint NOT NULL DEFAULT '0',
  `play_style` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_safe` (`username_safe`),
  UNIQUE KEY `email` (`email`) USING BTREE,
  KEY `donor_expire` (`donor_expire`),
  KEY `privileges` (`privileges`),
  KEY `username` (`username`),
  KEY `clan_id` (`clan_id`),
  KEY `whitelist` (`whitelist`),
  KEY `country` (`country`)
) ENGINE=InnoDB AUTO_INCREMENT=129057 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_achievements`
--

DROP TABLE IF EXISTS `users_achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_achievements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `achievement_id` int NOT NULL,
  `mode` int NOT NULL COMMENT 'TODO: this should have key',
  `created_at` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `achievement_id` (`achievement_id`),
  KEY `time` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=491002 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_achievements_old`
--

DROP TABLE IF EXISTS `users_achievements_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_achievements_old` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `achievement_id` int NOT NULL,
  `time` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `achievement_id` (`achievement_id`),
  KEY `time` (`time`)
) ENGINE=InnoDB AUTO_INCREMENT=202206 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_relationships`
--

DROP TABLE IF EXISTS `users_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_relationships` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user1` int NOT NULL,
  `user2` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user1` (`user1`),
  KEY `user2` (`user2`)
) ENGINE=InnoDB AUTO_INCREMENT=253545 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-05-08 16:53:44
