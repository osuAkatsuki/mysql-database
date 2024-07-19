create table beatmap_mirror_requests (
    id int not null auto_increment primary key,
    request_url varchar(255) not null,
    api_key_id varchar(255) null,
    mirror_name varchar(255) not null,
    success boolean not null,
    started_at datetime not null,
    ended_at datetime not null,
    response_size int null,
    response_error varchar(255) null
);
alter table beatmap_mirror_requests add index (started_at);
alter table beatmap_mirror_requests add index (mirror_name);
alter table beatmap_mirror_requests add index (success);
