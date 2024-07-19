alter table beatmap_mirror_requests add column resource varchar(255) not null default "osz2_file";
alter table beatmap_mirror_requests add column response_status_code int null default null;
