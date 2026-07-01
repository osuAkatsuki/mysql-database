alter table users
  add column official_osu_user_id int unsigned null default null,
  add column official_osu_username varchar(32) null default null,
  add unique key users_official_osu_user_id_unique (official_osu_user_id),
  add key users_official_osu_username_idx (official_osu_username);
