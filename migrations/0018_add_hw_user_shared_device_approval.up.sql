-- Add shared device approval fields to hw_user table
-- This allows administrators to mark specific hardware combinations as "shared devices"
-- to prevent false-positive multi-account detection for families sharing computers

ALTER TABLE hw_user
  ADD COLUMN is_shared_device TINYINT(1) NOT NULL DEFAULT 0 AFTER activated,
  ADD COLUMN approved_by_admin_id INT NULL AFTER is_shared_device,
  ADD COLUMN approved_at DATETIME NULL AFTER approved_by_admin_id,
  ADD COLUMN approval_reason TEXT NULL AFTER approved_at,
  ADD INDEX idx_is_shared_device (is_shared_device);
