# Achievement Backfill: Sprint 5 vs Sprint 6 Comparison

## Quick Reference

| Aspect | Sprint 5 | Sprint 6 |
|--------|----------|----------|
| **Script** | `backfill_stat_achievements.py` | `backfill_mod_combo_achievements.py` |
| **Achievements** | 37 (21 stat + 16 rank) | 15 (11 mod + 4 combo) |
| **Data Source** | `user_stats` table (current) | `scores` tables (historical) |
| **Tables Queried** | 1 (`user_stats`) | 3 (`scores`, `scores_relax`, `scores_ap`) |
| **Rows Processed** | ~50,000 users | ~6.3M scores |
| **Runtime** | <1 minute | 2-6 hours |
| **Timestamps** | Current time | Historical (from scores) |
| **Users Affected** | ~9,600 | ~10,000-15,000 |
| **Total Grants** | ~37,000 | ~40,000-60,000 |
| **Redis Needed** | Yes (leaderboards) | No |

## Architecture Differences

### Sprint 5: Stat-Based Achievements

**Query Pattern:**
```sql
SELECT user_id, mode_vn
FROM user_stats
WHERE playcount >= 5000
  AND mode_vn = 0
```

**Characteristics:**
- ✅ Fast (one row per user-mode)
- ✅ Simple aggregation
- ✅ Current state only
- ❌ No historical timestamps

**Timestamp Handling:**
```python
timestamp = int(time.time())  # Current time
```

### Sprint 6: Score-Based Achievements

**Query Pattern:**
```sql
SELECT userid, mode, MIN(time) as created_at
FROM scores
WHERE mods & 8 != 0  -- HD flag
  AND completed = 3
  AND NOT EXISTS (user already has achievement)
GROUP BY userid, mode
```

**Characteristics:**
- ✅ Historical timestamps
- ✅ Per-mode isolation
- ❌ Slow (millions of rows)
- ❌ Complex aggregation

**Timestamp Handling:**
```python
MIN(s.time) AS created_at  # Earliest qualifying score
```

## Mode Handling

### Sprint 5: Mode Variants

Maps vanilla mode to all variants:
- Mode 0 (std) → Grant to modes 0, 4, 8
- Mode 1 (taiko) → Grant to modes 1, 5
- Mode 2 (catch) → Grant to modes 2, 6
- Mode 3 (mania) → Grant to mode 3

**Rationale:** Stats are shared across variants

### Sprint 6: Mode Isolation

Grants only to the mode where score occurred:
- Score in `scores` with `play_mode=0` → Mode 0 only
- Score in `scores_relax` with `play_mode=0` → Mode 4 only
- Score in `scores_ap` with `play_mode=0` → Mode 8 only

**Rationale:** Achievements require actual scores in that mode

**Exception:** Combo achievements only check standard mode (`play_mode=0`), but still grant per-variant.

## Performance Optimization

### Sprint 5: Stats Table
- **Indexes Used:** PRIMARY KEY on (user_id, mode_vn)
- **Scan Type:** Index scan
- **Rows Examined:** ~50,000
- **Execution Time:** <1 second per achievement

### Sprint 6: Scores Tables
- **Indexes Used:**
  - `mods` (mod achievements)
  - `idx_completed_time_pp` (completed + time aggregation)
- **Scan Type:** Index range scan + aggregation
- **Rows Examined:** ~6.3M (filtered by mods/combo)
- **Execution Time:** 5-30 minutes per achievement

## SQL Query Comparison

### Sprint 5: Simple SELECT

```sql
-- Playcount achievement
SELECT user_id, mode_vn
FROM user_stats
WHERE playcount >= 5000
  AND mode_vn = 0;
```

### Sprint 6: Aggregate with JOIN

```sql
-- HD achievement
SELECT
    s.userid AS user_id,
    CASE
        WHEN 'scores' = 'scores' THEN s.play_mode
        WHEN 'scores' = 'scores_relax' THEN s.play_mode + 4
        WHEN 'scores' = 'scores_ap' THEN 8
    END AS mode,
    MIN(s.time) AS created_at
FROM scores s
LEFT JOIN users_achievements ua
    ON ua.user_id = s.userid
    AND ua.achievement_id = 91
    AND ua.mode = s.play_mode
WHERE s.mods & 8 != 0
  AND s.completed = 3
  AND ua.id IS NULL
GROUP BY s.userid, mode;
```

## Testing Strategies

### Sprint 5: Quick Validation

```bash
# Dry run completes in seconds
python backfill_stat_achievements.py \
    --achievement-id 73 \
    --dry-run \
    --verbose
```

### Sprint 6: Staged Testing

```bash
# 1. Test one rare achievement (fast)
python backfill_mod_combo_achievements.py \
    --achievement-id 92 \
    --dry-run \
    --verbose  # FL (rare mod)

# 2. Test one common achievement (slow)
python backfill_mod_combo_achievements.py \
    --achievement-id 91 \
    --dry-run \
    --verbose  # HD (common mod)

# 3. Test combo type (medium)
python backfill_mod_combo_achievements.py \
    --achievement-type combo \
    --dry-run \
    --verbose
```

## Rollback Complexity

### Sprint 5: Simple Time-Based Rollback

```sql
-- Delete all grants from Sprint 5 run
DELETE FROM users_achievements
WHERE achievement_id IN (73, 74, 75, ..., 115)
  AND created_at >= UNIX_TIMESTAMP('2026-01-18 10:30:00');
```

**Challenge:** All timestamps are the same (current time)

### Sprint 6: Backup-Based Rollback

```sql
-- 1. Create backup before run
CREATE TABLE users_achievements_sprint6_backup AS ...

-- 2. Rollback by deleting and restoring
DELETE FROM users_achievements WHERE achievement_id IN (86, ..., 96, 21, ..., 24);
INSERT INTO users_achievements SELECT * FROM users_achievements_sprint6_backup;
```

**Challenge:** Historical timestamps make time-based rollback impossible

## Dependencies

### Sprint 5 Required
- MySQL connection
- Redis connection (for rank achievements)
- `pymysql` library
- `redis` library

### Sprint 6 Required
- MySQL connection only
- `pymysql` library

Sprint 6 is simpler in dependencies!

## Error Recovery

### Sprint 5
- Fast enough to re-run entire script (<1 minute)
- Idempotent (INSERT IGNORE)
- Low risk of interruption

### Sprint 6
- Too slow to re-run entire script (hours)
- Idempotent (INSERT IGNORE)
- **Must resume from interruption point**
- Commits after each achievement for incremental progress

## Verification Queries

Both sprints use similar verification:

```sql
-- Total grants
SELECT achievement_id, COUNT(*) FROM users_achievements
WHERE achievement_id IN (...)
GROUP BY achievement_id;

-- Duplicates check
SELECT user_id, achievement_id, mode, COUNT(*)
FROM users_achievements
WHERE achievement_id IN (...)
GROUP BY user_id, achievement_id, mode
HAVING COUNT(*) > 1;
```

**Sprint 6 Additional Check:**

```sql
-- Verify historical timestamps
SELECT achievement_id,
    MIN(FROM_UNIXTIME(created_at)) as earliest,
    MAX(FROM_UNIXTIME(created_at)) as latest
FROM users_achievements
WHERE achievement_id IN (86, ..., 96, 21, ..., 24)
GROUP BY achievement_id;
```

Expected: `earliest` should be 2016-2018, not current date.

## Future Sprints

### Potential Sprint 7: Score-Based Complex Achievements
- Star rating achievements (FC by SR brackets)
- Accuracy achievements (95%/98%/99%/100%)
- Similar to Sprint 6 (score table queries)
- Use same architecture patterns

### Potential Sprint 8: Time-Based Achievements
- Account age milestones
- Supporter anniversary
- Query `users` table (fast like Sprint 5)

## Lessons Learned

### From Sprint 5
- ✅ Dry-run mode essential for testing
- ✅ Verbose mode helps debug issues
- ✅ Single-achievement testing saves time
- ✅ Incremental commits enable recovery

### Applied to Sprint 6
- ✅ Same CLI interface as Sprint 5
- ✅ Added `--achievement-type` for split testing
- ✅ Removed Redis dependency (not needed)
- ✅ Preserved historical timestamps
- ✅ Per-achievement commits for long runs

## Recommended Execution Order

1. **Sprint 5 First** (if not done):
   - Fast execution
   - Proves infrastructure works
   - Low risk

2. **Sprint 6 After**:
   - Test on single achievement first
   - Run mod achievements during off-peak hours
   - Monitor database load
   - Can split into mod + combo runs if needed

3. **Verify Both**:
   - Check for duplicates
   - Validate timestamp distribution
   - Compare grant counts with expectations
