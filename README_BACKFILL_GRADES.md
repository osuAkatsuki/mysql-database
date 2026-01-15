# Grade Counts Backfill Script

This script recalculates grade counts (SS, S, A, B, C, D) in the `user_stats` table by analyzing existing scores.

## When to Use

- After migrating or restoring score data
- When grade counts are missing or incorrect in `user_stats`
- One-time backfill for historical data

## Requirements

```bash
pip install pymysql
```

## Usage

### Test on a specific user (dry run)

```bash
python backfill_grade_counts.py \
  --host localhost \
  --user root \
  --password your_password \
  --database akatsuki \
  --user-id 1001 \
  --dry-run \
  --verbose
```

### Backfill a specific user

```bash
python backfill_grade_counts.py \
  --host localhost \
  --user root \
  --password your_password \
  --database akatsuki \
  --user-id 1001
```

### Backfill all users

```bash
python backfill_grade_counts.py \
  --host localhost \
  --user root \
  --password your_password \
  --database akatsuki \
  --verbose
```

## How It Works

1. **Filters users with scores**: Only processes users who have at least one completed score
2. **Uses window functions**: Efficiently finds the best score per beatmap/mods combination
3. **Calculates grades**: Uses the same logic as score-service to determine grade (XH, X, SH, S, A, B, C, D)
4. **Updates user_stats**: Writes the recalculated counts back to the database

## Performance

- Processes ~2,500-3,000 user/mode combinations per minute
- Skips ~83% of user/mode combinations that have no scores
- Expected runtime for full backfill: 1-2 hours (vs. 8+ hours for naive approach)

## Options

- `--host` - MySQL host (default: localhost)
- `--port` - MySQL port (default: 3306)
- `--user` - MySQL user (default: root)
- `--password` - MySQL password
- `--database` - MySQL database (default: akatsuki)
- `--user-id` - Backfill specific user only
- `--mode` - Backfill specific mode only (0-8)
- `--dry-run` - Preview changes without writing to database
- `--verbose` - Print detailed progress

## Notes

- Grades are counted per unique beatmap/mods combination (only best score counts)
- Silver grades (XH, SH) are awarded when certain mods are used (HD, FL, FI)
- The script commits after each user/mode combination for incremental progress
- Safe to interrupt and restart - already processed users will be recalculated
