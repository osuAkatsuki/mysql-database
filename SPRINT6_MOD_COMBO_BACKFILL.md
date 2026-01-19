# Sprint 6: Mod & Combo Achievement Backfill

## Overview

Backfill 15 achievements by querying **6.3M+ historical scores** across 3 tables:
- **11 mod-based achievements** (pass with specific mods: Hidden, HardRock, DoubleTime, etc.)
- **4 combo achievements** (achieve combo thresholds: 500, 750, 1000, 2000)

**Key Difference from Sprint 5:**
- Sprint 5: Query current user stats (fast, <1 minute)
- Sprint 6: Process millions of historical scores (2-6 hours)

**Expected Impact:**
- **10,000-15,000 additional users** gain achievements
- **40,000-60,000 total achievement grants**
- Historical timestamps preserved (earliest scores from 2016-2018)

## Achievement Definitions

### Mod Achievements (11 total - IDs 86-96)

All require: `(score.mods & MOD_FLAG != 0) AND score.completed = 3`

| ID | File | Mod | Bit Value | Name |
|----|------|-----|-----------|------|
| 86 | all-intro-suddendeath | SD | 32 | Finality |
| 87 | all-intro-perfect | PF | 16384 | Perfectionist |
| 88 | all-intro-hardrock | HR | 16 | Rock Around The Clock |
| 89 | all-intro-doubletime | DT | 64 | Time And A Half |
| 90 | all-intro-nightcore | NC | 512 | Sweet Rave Party |
| 91 | all-intro-hidden | HD | 8 | Blindsight |
| 92 | all-intro-flashlight | FL | 1024 | Are You Afraid Of The Dark? |
| 93 | all-intro-easy | EZ | 2 | Dial It Right Back |
| 94 | all-intro-nofail | NF | 1 | Risk Averse |
| 95 | all-intro-halftime | HT | 256 | Slowboat |
| 96 | all-intro-spunout | SO | 4096 | Burned Out |

### Combo Achievements (4 total - IDs 21-24)

All require: `max_combo >= threshold AND play_mode = 0 AND completed = 3`

| ID | File | Threshold | Name |
|----|------|-----------|------|
| 21 | osu-combo-500 | 500 | 500 Combo |
| 22 | osu-combo-750 | 750 | 750 Combo |
| 23 | osu-combo-1000 | 1000 | 1000 Combo |
| 24 | osu-combo-2000 | 2000 | 2000 Combo |

**Mode Restriction:** Combo achievements are **STANDARD MODE ONLY** (modes 0, 4, 8)

## Mode Mapping

| Table | play_mode | Full Mode | Description |
|-------|-----------|-----------|-------------|
| scores | 0 | 0 | std vanilla |
| scores | 1 | 1 | taiko vanilla |
| scores | 2 | 2 | catch vanilla |
| scores | 3 | 3 | mania vanilla |
| scores_relax | 0 | 4 | std relax |
| scores_relax | 1 | 5 | taiko relax |
| scores_relax | 2 | 6 | catch relax |
| scores_ap | 0 | 8 | std autopilot |

**Important:** Achievements are granted **only to the mode where the score occurred**, not to all mode variants.

## Pre-Flight Checklist

### 1. Verify Database Access

```bash
# Test MySQL connection
mysql -h <host> -P <port> -u <user> -p<password> <database> -e "SELECT COUNT(*) FROM scores;"
```

### 2. Check Existing Achievement Grants

```sql
-- Count existing grants for these achievements
SELECT achievement_id, COUNT(*) as existing_grants
FROM users_achievements
WHERE achievement_id IN (
    86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96,  -- Mods
    21, 22, 23, 24  -- Combos
)
GROUP BY achievement_id
ORDER BY achievement_id;
```

Expected: Low counts (only recent players)

### 3. Verify Indexes Exist

```sql
-- Check for required indexes
SHOW INDEX FROM scores WHERE Key_name IN ('mods', 'idx_completed_time_pp');
SHOW INDEX FROM scores_relax WHERE Key_name IN ('mods', 'idx_completed_time_pp');
SHOW INDEX FROM scores_ap WHERE Key_name IN ('mods', 'idx_completed_time_pp');
```

Expected: Both indexes present on all 3 tables

### 4. Create Backup

```sql
-- Backup existing achievement grants (for rollback)
CREATE TABLE users_achievements_sprint6_backup AS
SELECT * FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24);
```

## Usage

### Basic Usage (All Achievements)

```bash
python backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password <password> \
    --mysql-database akatsuki
```

**Runtime:** 2-6 hours

### Dry Run (No Database Changes)

```bash
python backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password <password> \
    --mysql-database akatsuki \
    --dry-run \
    --verbose
```

**Purpose:** Test queries and see estimated grant counts without inserting data

### Test Single Achievement

```bash
# Test HD achievement (ID 91) only
python backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password <password> \
    --mysql-database akatsuki \
    --achievement-id 91 \
    --dry-run \
    --verbose
```

### Process Only Mod or Combo Achievements

```bash
# Mods only (11 achievements, ~2-4 hours)
python backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password <password> \
    --mysql-database akatsuki \
    --achievement-type mod

# Combos only (4 achievements, ~1-2 hours)
python backfill_mod_combo_achievements.py \
    --mysql-host localhost \
    --mysql-port 3306 \
    --mysql-user root \
    --mysql-password <password> \
    --mysql-database akatsuki \
    --achievement-type combo
```

## Expected Performance

### Per-Achievement Estimates

- **HD, HR, DT** (common mods): ~15 minutes each
- **FL, SO, EZ** (rare mods): ~5 minutes each
- **500 combo** (most common): ~30 minutes
- **2000 combo** (rare): ~15 minutes

### Total Runtime

- **Mod achievements:** 11 × 12 min avg = ~2.2 hours
- **Combo achievements:** 4 × 22 min avg = ~1.5 hours
- **Total:** ~3.5-4 hours

## Safety Features

### 1. Idempotency

- Uses `INSERT IGNORE` to prevent duplicate grants
- Safe to re-run if interrupted
- UNIQUE constraint `(user_id, achievement_id, mode)` enforces uniqueness

### 2. Incremental Commits

- Commits after **each achievement** (not at the end)
- Progress saved even if script crashes
- Can resume from next achievement

### 3. Historical Timestamp Preservation

- Uses `MIN(s.time)` from scores table
- Grants have **actual achievement date**, not current time
- Example: User earned HD in 2016 → `created_at` will be 2016 timestamp

### 4. Mode Isolation

- Each mode granted independently
- No cross-mode contamination
- Combo achievements only grant to std modes (0, 4, 8)

## Post-Backfill Verification

### 1. Total Grants Per Achievement

```sql
SELECT
    achievement_id,
    COUNT(*) as total_grants,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT mode) as modes_granted
FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
GROUP BY achievement_id
ORDER BY achievement_id;
```

### 2. Verify Historical Timestamps

```sql
SELECT
    achievement_id,
    MIN(FROM_UNIXTIME(created_at)) as earliest_grant,
    MAX(FROM_UNIXTIME(created_at)) as latest_grant,
    COUNT(*) as total_grants
FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
GROUP BY achievement_id
ORDER BY achievement_id;
```

**Expected:**
- `earliest_grant`: 2016-2018 (historical scores)
- `latest_grant`: Recent dates (NOT all current date)

### 3. Check for Duplicates (Should Be Zero)

```sql
SELECT user_id, achievement_id, mode, COUNT(*) as cnt
FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
GROUP BY user_id, achievement_id, mode
HAVING cnt > 1;
```

**Expected:** 0 rows

### 4. Verify Mode Distribution (Combo Achievements)

```sql
SELECT mode, COUNT(*) as grants
FROM users_achievements
WHERE achievement_id IN (21, 22, 23, 24)
GROUP BY mode
ORDER BY mode;
```

**Expected:** Only modes 0, 4, 8 (std vanilla, relax, autopilot)

### 5. Sanity Check: Compare Against Raw Scores

```sql
-- Example: Verify HD achievement grants match actual HD scores
SELECT COUNT(DISTINCT userid) as users_with_hd_scores
FROM (
    SELECT userid FROM scores WHERE mods & 8 != 0 AND completed = 3
    UNION
    SELECT userid FROM scores_relax WHERE mods & 8 != 0 AND completed = 3
    UNION
    SELECT userid FROM scores_ap WHERE mods & 8 != 0 AND completed = 3
) t;
```

Compare with:

```sql
SELECT COUNT(DISTINCT user_id) as users_with_hd_achievement
FROM users_achievements
WHERE achievement_id = 91;
```

Numbers should be close (within 5-10% due to mode filtering)

## Rollback Procedure

If something goes wrong:

```sql
-- Step 1: Delete Sprint 6 grants
DELETE FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
  AND created_at >= UNIX_TIMESTAMP('2026-01-19 00:00:00');  -- Adjust to backfill start time

-- Step 2: Verify deletion
SELECT achievement_id, COUNT(*) as remaining_grants
FROM users_achievements
WHERE achievement_id IN (86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 21, 22, 23, 24)
GROUP BY achievement_id;

-- Step 3 (if needed): Restore from backup
INSERT INTO users_achievements
SELECT * FROM users_achievements_sprint6_backup;

-- Step 4: Drop backup table
DROP TABLE users_achievements_sprint6_backup;
```

## Troubleshooting

### Query Timeout

If queries timeout (unlikely with current indexes):

```bash
# Process achievements one at a time
for id in 86 87 88 89 90 91 92 93 94 95 96 21 22 23 24; do
    python backfill_mod_combo_achievements.py \
        --mysql-host localhost \
        --mysql-port 3306 \
        --mysql-user root \
        --mysql-password <password> \
        --mysql-database akatsuki \
        --achievement-id $id \
        --verbose
done
```

### Script Crashes Mid-Execution

**Solution:** Re-run the same command. The script is idempotent and will:
1. Skip achievements already processed (INSERT IGNORE)
2. Continue from where it left off
3. Only grant missing achievements

### Unexpected Grant Counts

**Debug with verbose mode:**

```bash
python backfill_mod_combo_achievements.py \
    --achievement-id 91 \
    --dry-run \
    --verbose \
    <other args>
```

This shows per-table grant counts to identify issues.

## Success Criteria

- ✅ All 15 achievements backfilled (11 mod + 4 combo)
- ✅ 40,000-60,000 total grants across 10,000-15,000 users
- ✅ Historical timestamps preserved (earliest from 2016-2018)
- ✅ No duplicate achievements (UNIQUE constraint enforced)
- ✅ Script completed in 2-6 hours
- ✅ All verification queries pass
- ✅ Combo achievements only granted to standard modes (0, 4, 8)

## Next Steps After Completion

1. **Drop backup table** (if verification passes):
   ```sql
   DROP TABLE users_achievements_sprint6_backup;
   ```

2. **Update achievement system documentation**

3. **Monitor for issues** in first 24 hours:
   - Check error logs
   - Watch for user reports of missing/duplicate achievements

4. **Plan Sprint 7** (if needed for additional achievement types)
