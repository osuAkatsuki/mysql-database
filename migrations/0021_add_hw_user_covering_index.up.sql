-- Add composite index with covering index to avoid table lookups
-- Covering index includes userid for index-only scans in GROUP BY queries

alter table hw_user add index idx_hardware_combination_covering (mac, unique_id, disk_id, userid);
