alter table user_stats
    add column stats_profile_id int not null auto_increment unique first;
alter table user_stats
    drop primary key,
    add primary key (stats_profile_id);

alter table scores
    add column stats_profile_id int null after id;
update scores
    set scores.stats_profile_id = (
        select user_stats.stats_profile_id
        from user_stats
        where user_stats.user_id = scores.userid
        and user_stats.mode = scores.play_mode
    )
    where scores.stats_profile_id is null;
alter table scores
    modify column stats_profile_id int not null,
    add index (stats_profile_id);

alter table scores_relax
    add column stats_profile_id int null after id;
update scores_relax
    set scores_relax.stats_profile_id = (
        select user_stats.stats_profile_id
        from user_stats
        where user_stats.user_id = scores_relax.userid
        and user_stats.mode = scores_relax.play_mode + 4
    )
    where scores_relax.stats_profile_id is null;
alter table scores_relax
    modify column stats_profile_id int not null,
    add index (stats_profile_id);

alter table scores_ap
    add column stats_profile_id int null after id;
update scores_ap
    set scores_ap.stats_profile_id = (
        select user_stats.stats_profile_id
        from user_stats
        where user_stats.user_id = scores_ap.userid
        and user_stats.mode = scores_ap.play_mode + 8
    )
    where scores_ap.stats_profile_id is null;
alter table scores_ap
    modify column stats_profile_id int not null,
        add index (stats_profile_id);
