DROP TABLE IF EXISTS password_recovery;

CREATE TABLE password_recovery (
  id int NOT NULL AUTO_INCREMENT,
  user_id int NOT NULL,
  token char(50) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  used_at timestamp NULL DEFAULT NULL,
  status enum('unused', 'used', 'revoked') CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL DEFAULT 'unused',
  PRIMARY KEY (id),
  UNIQUE KEY password_recovery_token (token),
  KEY password_recovery_user_status_created (user_id, status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
