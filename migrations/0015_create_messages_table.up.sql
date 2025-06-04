create table messages (
    id int unsigned not null auto_increment primary key,
    sender_id int not null,
    recipient_id int null,
    recipient_channel varchar(255) null,
    content varchar(2048) not null,
    read_at datetime null,
    created_at datetime not null default CURRENT_TIMESTAMP,
    deleted_at datetime null
);
alter table messages add index (sender_id);
alter table messages add index (recipient_id);
alter table messages add index (recipient_channel);
alter table messages add index (read_at);
alter table messages add index (created_at);
alter table messages add index (deleted_at);
