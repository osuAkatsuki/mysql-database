# Sprint 6 Quick Start Guide

## Prerequisites

1. **Python 3.11+** installed
2. **pymysql** library installed: `pip install pymysql`
3. **MySQL credentials** with read/write access to `akatsuki` database
4. **2-6 hours** of runtime (recommended: run during off-peak hours)

## Step-by-Step Execution

### Step 1: Navigate to Directory

```bash
cd /Users/cmyui/programming/claude-working/akatsuki/mysql-database
```

### Step 2: Install Dependencies

```bash
pip install pymysql
```

### Step 3: Create Backup (CRITICAL!)

```sql
-- Connect to MySQL
mysql -h <host> -u <user> -p<password> akatsuki

-- Create backup table
CREATE TABLE users_achievements_sprint6_backup AS
SELECT * FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24);

-- Verify backup
SELECT COUNT(*) FROM users_achievements_sprint6_backup;
```

### Step 4: Test with Single Achievement (Dry Run)

```bash
# Test HD achievement (common mod, will be slower)
python3 backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password YOUR_PASSWORD \
    --mysql-database akatsuki \
    --achievement-id 91 \
    --dry-run \
    --verbose
```

**Expected output:**
```
Connecting to MySQL at localhost:3306...

Processing 1 achievement(s) (DRY RUN)
================================================================================

[1/1] all-intro-hidden (ID 91)
    Querying scores... 2847 grants in 12.3s
    Querying scores_relax... 1523 grants in 8.7s
    Querying scores_ap... 234 grants in 4.1s
  ✓ Would grant to 4604 user-mode combination(s)

================================================================================
Total: 4604 potential grants across 1 achievement(s)
```

### Step 5: Run Full Backfill (Production)

```bash
# Remove --dry-run to execute
python3 backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password YOUR_PASSWORD \
    --mysql-database akatsuki \
    --verbose
```

**Alternative: Split into Two Runs (Safer)**

```bash
# Run 1: Mod achievements only (~2-4 hours)
python3 backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password YOUR_PASSWORD \
    --mysql-database akatsuki \
    --achievement-type mod \
    --verbose

# Run 2: Combo achievements only (~1-2 hours)
python3 backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password YOUR_PASSWORD \
    --mysql-database akatsuki \
    --achievement-type combo \
    --verbose
```

### Step 6: Monitor Progress

The script will output progress for each achievement:

```
[1/15] all-intro-suddendeath (ID 86)
    Querying scores... 1234 grants in 8.2s
    Querying scores_relax... 567 grants in 5.1s
    Querying scores_ap... 89 grants in 2.3s
  ✓ Granted to 1890 user-mode combination(s)

[2/15] all-intro-perfect (ID 87)
...
```

**Progress tracking:**
- Each achievement commits immediately after completion
- If script crashes, re-run the same command (idempotent)
- Already-granted achievements will be skipped (INSERT IGNORE)

### Step 7: Verify Results

```sql
-- Check total grants per achievement
SELECT
    achievement_id,
    COUNT(*) as total_grants,
    COUNT(DISTINCT user_id) as unique_users
FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
GROUP BY achievement_id
ORDER BY achievement_id;
```

**Expected ranges:**
- HD (91): 8,000-12,000 grants
- FL (92): 400-800 grants
- 500 combo (21): 6,000-8,000 grants
- 2000 combo (24): 700-1,000 grants

```sql
-- Verify historical timestamps (should NOT all be current date)
SELECT
    achievement_id,
    MIN(FROM_UNIXTIME(created_at)) as earliest_grant,
    MAX(FROM_UNIXTIME(created_at)) as latest_grant
FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
GROUP BY achievement_id;
```

**Expected:**
- `earliest_grant`: 2016-2018 (old scores)
- `latest_grant`: Recent dates (recent scores)

```sql
-- Check for duplicates (should be 0 rows)
SELECT user_id, achievement_id, mode, COUNT(*) as cnt
FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
GROUP BY user_id, achievement_id, mode
HAVING cnt > 1;
```

### Step 8: Cleanup (If Successful)

```sql
-- Drop backup table
DROP TABLE users_achievements_sprint6_backup;
```

## Troubleshooting

### Script Interrupted/Crashed

**Solution:** Just re-run the same command. The script is idempotent:

```bash
python3 backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password YOUR_PASSWORD \
    --mysql-database akatsuki \
    --verbose
```

- Already-processed achievements will be skipped (fast)
- Remaining achievements will be processed normally

### Unexpected Grant Counts

**Debug individual achievement:**

```bash
python3 backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password YOUR_PASSWORD \
    --mysql-database akatsuki \
    --achievement-id 91 \
    --dry-run \
    --verbose
```

Look at per-table counts to identify issues.

### Database Connection Issues

**Test connection:**

```bash
mysql -h <host> -P <port> -u <user> -p<password> <database> -e "SELECT 1;"
```

### Performance Issues

If queries are too slow:

1. **Verify indexes exist:**
   ```sql
   SHOW INDEX FROM scores WHERE Key_name IN ('mods', 'idx_completed_time_pp');
   ```

2. **Check database load:**
   ```sql
   SHOW PROCESSLIST;
   ```

3. **Run during off-peak hours** (recommended)

## Rollback Procedure

If results are incorrect:

```sql
-- Delete Sprint 6 grants (adjust timestamp to your backfill start time)
DELETE FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
  AND created_at >= UNIX_TIMESTAMP('2026-01-19 00:00:00');

-- Verify deletion
SELECT achievement_id, COUNT(*) FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
GROUP BY achievement_id;

-- Restore from backup if needed
INSERT INTO users_achievements SELECT * FROM users_achievements_sprint6_backup;
```

## Expected Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| Setup | 5 minutes | Install dependencies, create backup |
| Dry run test | 2-3 minutes | Test single achievement |
| Mod achievements | 2-4 hours | Process 11 mod achievements |
| Combo achievements | 1-2 hours | Process 4 combo achievements |
| Verification | 5 minutes | Run SQL verification queries |
| **Total** | **3-6 hours** | Including setup and verification |

## Success Checklist

- ✅ Backup created
- ✅ Dry run test successful
- ✅ All 15 achievements processed
- ✅ No duplicate grants
- ✅ Historical timestamps preserved (earliest from 2016-2018)
- ✅ Combo achievements only granted to std modes (0, 4, 8)
- ✅ Grant counts within expected ranges
- ✅ Verification queries all pass
- ✅ Backup table dropped (if keeping results)

## Need Help?

See full documentation:
- **SPRINT6_MOD_COMBO_BACKFILL.md** - Complete reference guide
- **SPRINT_COMPARISON.md** - Sprint 5 vs Sprint 6 differences
- **backfill_mod_combo_achievements.py** - Script source code with comments
