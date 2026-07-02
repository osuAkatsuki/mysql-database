alter table users
  add key users_discord_account_id_idx (discord_account_id),
  drop index users_twitch_account_id_unique,
  add key users_twitch_account_id_idx (twitch_account_id),
  drop index users_official_osu_user_id_unique,
  add key users_official_osu_user_id_idx (official_osu_user_id);
