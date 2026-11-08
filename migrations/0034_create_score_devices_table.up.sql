-- One row per score whose replay was converted to an .orz file (osu-orz). device is
-- the device model the replay's cursor positions are coded on: the encoder takes a
-- player's recent devices as hints, which lets it skip its device search.

CREATE TABLE score_devices (
  score_id bigint NOT NULL,
  user_id int NOT NULL,
  mode tinyint NOT NULL COMMENT 'Akatsuki mode: 0-3 vanilla, 4-6 relax, 8 autopilot',
  coding enum('VERBATIM', 'TAIKO_CATCH_MANIA', 'TEXT', 'DEVICE', 'AUTOPILOT') NOT NULL COMMENT 'osu_orz.Coding',
  hint_used tinyint unsigned NULL COMMENT 'Index of the hint the encoder took, NULL when it searched',
  device blob NULL COMMENT 'osu_orz.Device.data, NULL when no axis is on a device model',
  x_model enum('rational', 'mouse', 'absolute', 'text') NULL COMMENT 'Model of the x axis last segment',
  y_model enum('rational', 'mouse', 'absolute', 'text') NULL COMMENT 'Model of the y axis last segment',
  format_version tinyint unsigned NOT NULL COMMENT 'osu_orz.FORMAT_VERSION, which device data is tied to',
  osu_orz varchar(16) NOT NULL COMMENT 'osu-orz version that coded the replay',
  PRIMARY KEY (score_id),
  KEY score_devices_user_mode_score (user_id, mode, score_id)
);
