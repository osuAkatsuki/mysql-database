alter table hw_user add column created_at datetime not null default current_timestamp;
alter table hw_user alter occurencies set default 1;
update hw_user set occurencies = 1 where occurencies = 0;
