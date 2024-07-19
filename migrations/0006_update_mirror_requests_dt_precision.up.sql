alter table beatmap_mirror_requests modify column started_at datetime(4) not null;
alter table beatmap_mirror_requests modify column ended_at datetime(4) not null;
