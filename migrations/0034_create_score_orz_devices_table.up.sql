-- Each converted score's replay as osu-orz coded it, with the input device model its
-- cursor positions are coded on. A player's latest devices are hints for their next.

CREATE TABLE score_orz_devices (
  score_id bigint NOT NULL,
  user_id int NOT NULL,
  mode tinyint NOT NULL,
  orz_coding enum('VERBATIM', 'TAIKO_CATCH_MANIA', 'TEXT', 'DEVICE', 'AUTOPILOT') NOT NULL,
  device blob NULL,
  final_x_model enum('rational', 'mouse', 'absolute', 'text') NULL,
  final_y_model enum('rational', 'mouse', 'absolute', 'text') NULL,
  used_hint_index tinyint unsigned NULL,
  orz_format_version tinyint unsigned NOT NULL,
  osu_orz_version varchar(16) NOT NULL,
  PRIMARY KEY (score_id),
  KEY score_orz_devices_user_mode_score (user_id, mode, score_id)
);
