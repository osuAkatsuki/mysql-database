-- Create shared_devices table to track approved shared hardware combinations
-- This allows administrators to mark specific hardware as "shared devices" (e.g., family computers)
-- to prevent false-positive multi-account detection

CREATE TABLE shared_devices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mac VARCHAR(32) NOT NULL COMMENT 'MD5 hash of network adapters',
    unique_id VARCHAR(32) NOT NULL COMMENT 'MD5 hash of uninstall ID',
    disk_id VARCHAR(32) NOT NULL COMMENT 'MD5 hash of disk signature',
    approved_by_admin_id INT NOT NULL COMMENT 'Admin user ID who approved this',
    approved_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When it was approved',
    approval_reason TEXT COMMENT 'Optional reason for approval (e.g., family computer, internet cafe)',
    UNIQUE KEY unique_hardware (mac, unique_id, disk_id),
    INDEX idx_mac (mac),
    INDEX idx_unique_id (unique_id),
    INDEX idx_disk_id (disk_id),
    FOREIGN KEY (approved_by_admin_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Approved shared devices that bypass multi-account detection';
