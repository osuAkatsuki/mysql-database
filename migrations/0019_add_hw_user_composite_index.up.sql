-- Add composite index on hw_user for efficient grouping by hardware combination
-- This significantly improves performance for multi-account detection queries
-- that need to GROUP BY (mac, unique_id, disk_id)

alter table hw_user add index idx_hardware_combination (mac, unique_id, disk_id);
