DROP TABLE IF EXISTS password_recovery;

CREATE TABLE password_recovery (
  user_id int NOT NULL,
  token char(50) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY password_recovery_token (token)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
