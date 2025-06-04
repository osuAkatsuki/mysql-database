create table messages (
    id int unsigned not null auto_increment primary key,
    sender_id int not null,
    recipient_id int null,
    recipient_channel varchar(255) null,
    content varchar(2048) not null,
    unread boolean not null default 0,
    created_at datetime not null default CURRENT_TIMESTAMP,
    status varchar(255) not null default 'active'
);
alter table messages add index (sender_id);
alter table messages add index (recipient_id);
alter table messages add index (recipient_channel);
alter table messages add index (unread);
alter table messages add index (created_at);
alter table messages add index (status);
