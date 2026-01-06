-- Add composite indexes to support "recent top plays" queries on the admin dashboard
-- These queries filter by completed=3 and time range, then sort by pp DESC
-- Without these indexes, the queries do full table scans on millions of rows

-- Pattern: WHERE completed = 3 AND time > X ORDER BY pp DESC LIMIT 100
-- Index covers: filter on completed, range scan on time, sort by pp
alter table scores add index idx_completed_time_pp (completed, time, pp);
alter table scores_relax add index idx_completed_time_pp (completed, time, pp);
alter table scores_ap add index idx_completed_time_pp (completed, time, pp);
