# Achievement Backfill Guide - Sprint 5

This guide explains how to use the two scripts for backfilling stat-based achievements.

## Overview

**Problem:** 38,607 users (40%) have zero achievements despite having passed scores.

**Solution:** Two-step backfill process:
1. **Script 1:** Migrate orphaned mode 7 autopilot achievements to mode 8 (4,134 users)
2. **Script 2:** Grant 37 stat/rank-based achievements to eligible users (15,000-25,000 expected)

## Prerequisites

### Install Dependencies

```bash
pip install pymysql redis
```

### Database Backup

**CRITICAL:** Create a backup before running these scripts.

```bash
# Example backup command
mysqldump -h localhost -u root -p akatsuki users_achievements > users_achievements_backup_20260119.sql
```

## Script 1: Mode 7→8 Consolidation

### Purpose

Migrate historical autopilot achievements from mode 7 to mode 8. In April 2024, autopilot mode was refactored but existing achievements were never migrated.

### Expected Impact

- **Users affected:** 4,134
- **Achievements migrated:** 28,472
- **Runtime:** ~1-5 minutes

### Usage

#### Dry Run (Recommended First)

```bash
python consolidate_mode7_achievements.py \
  --host localhost \
  --port 3306 \
  --user root \
  --password YOUR_PASSWORD \
  --database akatsuki \
  --dry-run \
  --verbose
```

#### Production Run

```bash
python consolidate_mode7_achievements.py \
  --host localhost \
  --port 3306 \
  --user root \
  --password YOUR_PASSWORD \
  --database akatsuki \
  --verbose
```

### Verification Queries

```sql
-- Before consolidation
SELECT COUNT(*) as mode7_count
FROM users_achievements
WHERE mode = 7;
-- Expected: ~28,472

-- After consolidation
SELECT COUNT(*) as mode7_count
FROM users_achievements
WHERE mode = 7;
-- Expected: 0

SELECT COUNT(*) as mode8_count
FROM users_achievements
WHERE mode = 8;
-- Should increase by ~28,472

-- Verify backup exists
SELECT COUNT(*) as backup_count
FROM users_achievements_mode7_backup;
-- Expected: ~28,472
```

## Script 2: Stat-Based Achievement Backfill

### Purpose

Grant 37 achievements based on user statistics and Redis leaderboard ranks.

### Achievement Breakdown

**Playcount (4 achievements - osu!std only):**
- ID 73: 5,000 plays
- ID 74: 15,000 plays
- ID 75: 25,000 plays
- ID 76: 50,000 plays

**Hit Count (12 achievements):**
- Taiko (IDs 77-79, 97): 30k/300k/3M/30M hits
- Catch (IDs 80-82, 98): 20k/200k/2M/20M fruits
- Mania (IDs 83-85, 99): 40k/400k/4M/40M keys

**Rank Milestones (16 achievements):**
- All 4 modes (IDs 100-115): 50k/10k/5k/1k ranks

### Expected Impact

- **Users affected:** 15,000-25,000
- **Achievements granted:** Variable (many users will get multiple achievements)
- **Runtime:** ~5-10 minutes

### Usage

#### Test Single Achievement (Dry Run)

```bash
python backfill_stat_achievements.py \
  --mysql-host localhost \
  --mysql-port 3306 \
  --mysql-user root \
  --mysql-password YOUR_PASSWORD \
  --mysql-database akatsuki \
  --redis-host localhost \
  --redis-port 6379 \
  --achievement-id 73 \
  --dry-run \
  --verbose
```

#### Dry Run All Achievements

```bash
python backfill_stat_achievements.py \
  --mysql-host localhost \
  --mysql-port 3306 \
  --mysql-user root \
  --mysql-password YOUR_PASSWORD \
  --mysql-database akatsuki \
  --redis-host localhost \
  --redis-port 6379 \
  --dry-run \
  --verbose
```

#### Production Run

```bash
python backfill_stat_achievements.py \
  --mysql-host localhost \
  --mysql-port 3306 \
  --mysql-user root \
  --mysql-password YOUR_PASSWORD \
  --mysql-database akatsuki \
  --redis-host localhost \
  --redis-port 6379 \
  --verbose
```

### Verification Queries

```sql
-- Count users with 0 achievements (BEFORE backfill)
SELECT COUNT(DISTINCT u.id) as zero_achievement_users
FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM users_achievements ua WHERE ua.user_id = u.id
);
-- Expected BEFORE: ~38,607

-- Count users with 0 achievements (AFTER backfill)
SELECT COUNT(DISTINCT u.id) as zero_achievement_users
FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM users_achievements ua WHERE ua.user_id = u.id
);
-- Expected AFTER: <15,000 (60%+ improvement)

-- Count new achievements granted per type
SELECT
  CASE
    WHEN achievement_id BETWEEN 73 AND 76 THEN 'Playcount'
    WHEN achievement_id IN (77,78,79,97,80,81,82,98,83,84,85,99) THEN 'Hit Count'
    WHEN achievement_id BETWEEN 100 AND 115 THEN 'Rank'
  END as category,
  COUNT(*) as grants
FROM users_achievements
WHERE achievement_id IN (
  73, 74, 75, 76,  -- Playcount
  77, 78, 79, 97,  -- Taiko hits
  80, 81, 82, 98,  -- Catch hits
  83, 84, 85, 99,  -- Mania hits
  100, 101, 102, 103,  -- Std ranks
  104, 105, 106, 107,  -- Taiko ranks
  108, 109, 110, 111,  -- Catch ranks
  112, 113, 114, 115   -- Mania ranks
)
AND created_at >= UNIX_TIMESTAMP('2026-01-19')  -- Adjust date
GROUP BY category;

-- Verify no duplicates exist
SELECT user_id, achievement_id, mode, COUNT(*) as cnt
FROM users_achievements
GROUP BY user_id, achievement_id, mode
HAVING cnt > 1;
-- Expected: 0 rows (UNIQUE constraint prevents duplicates)

-- Count grants per achievement
SELECT
  achievement_id,
  COUNT(*) as grants,
  COUNT(DISTINCT user_id) as unique_users
FROM users_achievements
WHERE achievement_id IN (73,74,75,76,77,78,79,97,80,81,82,98,83,84,85,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115)
GROUP BY achievement_id
ORDER BY achievement_id;
```

## Execution Order

**IMPORTANT:** Run scripts in this order:

1. **Script 1 (Mode 7→8 Consolidation)** - MUST run first
   - Cleans up orphaned mode 7 data
   - Prevents conflicts with mode 8 achievements in Script 2

2. **Script 2 (Stat-Based Backfill)** - Run second
   - Grants achievements based on current stats
   - Will properly backfill mode 8 achievements after consolidation

## Rollback Procedure

### Complete Rollback

```sql
-- Backup first (if not already done)
CREATE TABLE users_achievements_backfill_backup_20260119 AS
SELECT * FROM users_achievements;

-- Rollback Script 2 (stat-based achievements)
DELETE FROM users_achievements
WHERE achievement_id IN (
  73, 74, 75, 76,  -- Playcount
  77, 78, 79, 97,  -- Taiko hits
  80, 81, 82, 98,  -- Catch hits
  83, 84, 85, 99,  -- Mania hits
  100, 101, 102, 103,  -- Std ranks
  104, 105, 106, 107,  -- Taiko ranks
  108, 109, 110, 111,  -- Catch ranks
  112, 113, 114, 115   -- Mania ranks
)
AND created_at >= UNIX_TIMESTAMP('2026-01-19');  -- Adjust to backfill start time

-- Rollback Script 1 (mode 7→8 consolidation)
DELETE FROM users_achievements
WHERE mode = 8
AND created_at >= UNIX_TIMESTAMP('2026-01-19');  -- Adjust to consolidation start time

-- Restore mode 7 achievements from backup
INSERT INTO users_achievements
SELECT * FROM users_achievements_mode7_backup;
```

### Partial Rollback (Specific Achievement)

```sql
-- Rollback specific achievement
DELETE FROM users_achievements
WHERE achievement_id = 73  -- Replace with specific ID
AND created_at >= UNIX_TIMESTAMP('2026-01-19');  -- Adjust date
```

## Safety Features

Both scripts include:

1. **Idempotent Operations:** Safe to re-run (INSERT IGNORE prevents duplicates)
2. **Dry-Run Mode:** Test queries and see counts before inserting
3. **Per-Achievement Commits:** Progress saved incrementally (Script 2)
4. **Backup Tables:** Automatic backup creation (Script 1)
5. **Verbose Logging:** Detailed progress information

## Performance Notes

- **Script 1:** ~1-5 minutes
- **Script 2:** ~5-10 minutes
- **Database Impact:** Minimal read load, moderate write load
- **Safe to run during business hours:** Yes (uses INSERT IGNORE for atomicity)

## Troubleshooting

### "Module not found" errors

```bash
pip install pymysql redis
```

### Connection refused

- Verify MySQL/Redis are running
- Check host/port settings
- Verify credentials

### Script hangs on rank achievements

- Check Redis connection
- Verify leaderboards exist in Redis:
  ```bash
  redis-cli
  ZCARD ripple:leaderboard:std
  ```

### Duplicate key errors

Should not occur due to UNIQUE constraint and INSERT IGNORE, but if they do:
- Check for corrupt data
- Run verification query to find duplicates
- Remove duplicates manually before re-running

## Success Criteria

- ✅ Mode 7 achievements migrated to mode 8 (28,472 records)
- ✅ Zero mode 7 achievements remaining
- ✅ Stat-based achievements granted (15,000-25,000 users)
- ✅ Zero-achievement users reduced from 38,607 to <15,000 (60%+ improvement)
- ✅ No duplicate achievements (UNIQUE constraint enforced)
- ✅ Scripts complete in <15 minutes total

## Questions?

- Review the plan document for architectural details
- Check script comments for implementation notes
- Verify with dry-run mode before production execution
