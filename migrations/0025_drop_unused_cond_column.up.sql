-- Drop unused cond column from less_achievements table
-- The cond (condition) column was never used in the codebase and serves no purpose.
-- Achievement unlock conditions are handled programmatically in score-service and bancho-service-rs.

ALTER TABLE less_achievements DROP COLUMN cond;
