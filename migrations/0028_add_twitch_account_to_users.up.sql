alter table users
  add column twitch_account_id varchar(32) null default null,
  add column twitch_username varchar(25) null default null,
  add column twitch_display_name varchar(64) null default null,
  add unique key users_twitch_account_id_unique (twitch_account_id),
  add key users_twitch_username_idx (twitch_username);
