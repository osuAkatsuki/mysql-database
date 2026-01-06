-- Create shared_devices table to track approved shared hardware combinations
-- This allows administrators to mark specific hardware as "shared devices" (e.g., family computers)
-- to prevent false-positive multi-account detection

create table shared_devices (
    id int not null auto_increment primary key,
    mac varchar(32) not null,
    unique_id varchar(32) not null,
    disk_id varchar(32) not null,
    approved_by_admin_id int not null,
    approved_at datetime not null default CURRENT_TIMESTAMP,
    approval_reason text null,
    unique key (mac, unique_id, disk_id)
);
alter table shared_devices add index (mac);
alter table shared_devices add index (unique_id);
alter table shared_devices add index (disk_id);
