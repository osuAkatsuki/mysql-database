# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains MySQL database schema and migrations for the Akatsuki osu! private server. Migrations are applied automatically on deployment via the Docker container's entrypoint script.

## Migration Guidelines

### Creating New Migrations

1. **Naming Convention**: Migrations are numbered sequentially: `0001_description.up.sql`, `0002_description.up.sql`, etc.
   - Use descriptive names that clearly explain the change
   - Examples: `0024_fix_achievement_medal_filenames.up.sql`, `0023_add_cheat_analysis_column.up.sql`

2. **Up Migrations Only**: Down migrations are NOT needed or used
   - Only create `.up.sql` files
   - Do NOT create `.down.sql` files
   - The deployment system only runs forward migrations

3. **Migration Content**:
   - Include clear comments explaining the purpose of the migration
   - Use safe DDL operations (e.g., `ALTER TABLE ADD COLUMN IF NOT EXISTS`)
   - Test migrations against a local database before committing

4. **Finding the Next Migration Number**:
   ```bash
   ls -1 migrations/ | grep -E '^\d+_' | sort -V | tail -1
   # Example output: 0024_fix_achievement_medal_filenames.up.sql
   # Next migration: 0025_your_description.up.sql
   ```

### Example Migration

```sql
-- Add a new column to store replay analysis results
-- This enables the cheat detection system to store JSON analysis data

ALTER TABLE scores
  ADD COLUMN IF NOT EXISTS replay_analysis JSON DEFAULT NULL
  COMMENT 'JSON analysis results from nachalo-konca cheat detection';

ALTER TABLE scores_relax
  ADD COLUMN IF NOT EXISTS replay_analysis JSON DEFAULT NULL
  COMMENT 'JSON analysis results from nachalo-konca cheat detection';
```

## Database Schema

The database schema is defined in `migrations/0001_initial_db.up.sql` (full MySQL dump). Subsequent migrations modify this schema incrementally.

Key tables:
- `less_achievements` - Achievement definitions (medals)
- `scores`, `scores_relax`, `scores_ap` - Score data per game mode
- `users` - User accounts and privileges
- `users_stats` - Per-mode user statistics
- `beatmaps` - Cached beatmap metadata

## Deployment

Migrations are automatically applied when the mysql-database Docker container starts:
1. Container entrypoint runs `migrate` command
2. Migrations in `migrations/` are applied in numerical order
3. Migration state tracked in `_sqlx_migrations` table

## Testing Locally

```bash
# Build and run the MySQL container locally
make build
make run

# Connect to the local database
docker exec -it mysql-database mysql -uroot -pchangeme akatsuki
```
