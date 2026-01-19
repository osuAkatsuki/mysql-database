#!/usr/bin/env python3
"""
Consolidate mode 7 autopilot achievements to mode 8.

Background:
In April 2024, autopilot mode was refactored from mode 7 to mode 8. The code was updated
but 28,472 existing achievement unlocks for 4,134 users were never migrated.

This script migrates orphaned mode 7 achievements to mode 8 while preserving timestamps.

Safety:
- Creates backup table before any changes
- Only migrates achievements that don't already exist in mode 8 (prevents duplicates)
- Preserves original timestamps
- Supports dry-run mode for validation

Usage:
    python consolidate_mode7_achievements.py \\
        --host localhost \\
        --port 3306 \\
        --user root \\
        --password <password> \\
        --database akatsuki \\
        [--dry-run] \\
        [--verbose]
"""
import argparse
import sys
import time
from typing import Any

import pymysql


def create_backup_table(conn: Any, dry_run: bool = False) -> None:
    """Create backup table of mode 7 achievements."""
    if dry_run:
        print("DRY RUN: Would create backup table users_achievements_mode7_backup")
        return

    with conn.cursor() as cursor:
        # Drop existing backup if it exists
        cursor.execute("DROP TABLE IF EXISTS users_achievements_mode7_backup")

        # Create backup
        cursor.execute("""
            CREATE TABLE users_achievements_mode7_backup AS
            SELECT * FROM users_achievements WHERE mode = 7
        """)

        # Count backed up records
        cursor.execute("SELECT COUNT(*) as count FROM users_achievements_mode7_backup")
        result = cursor.fetchone()
        backup_count = result["count"]

        conn.commit()
        print(f"✓ Created backup table with {backup_count} records")


def find_achievements_to_migrate(conn: Any) -> list[dict[str, Any]]:
    """Find mode 7 achievements that don't exist in mode 8."""
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT user_id, achievement_id, created_at
            FROM users_achievements
            WHERE mode = 7
              AND NOT EXISTS (
                SELECT 1 FROM users_achievements ua2
                WHERE ua2.user_id = users_achievements.user_id
                  AND ua2.achievement_id = users_achievements.achievement_id
                  AND ua2.mode = 8
              )
            ORDER BY user_id, achievement_id
        """)
        return cursor.fetchall()


def migrate_achievements(
    conn: Any,
    achievements: list[dict[str, Any]],
    dry_run: bool = False,
    verbose: bool = False,
) -> int:
    """Migrate achievements from mode 7 to mode 8."""
    if not achievements:
        print("No achievements to migrate (all mode 7 achievements already exist in mode 8)")
        return 0

    if dry_run:
        print(f"DRY RUN: Would migrate {len(achievements)} achievements from mode 7 to mode 8")
        if verbose:
            for ach in achievements[:10]:  # Show first 10 in verbose mode
                print(f"  User {ach['user_id']}, Achievement {ach['achievement_id']}")
            if len(achievements) > 10:
                print(f"  ... and {len(achievements) - 10} more")
        return len(achievements)

    # Batch insert achievements to mode 8
    values = [
        (ach["user_id"], ach["achievement_id"], 8, ach["created_at"])
        for ach in achievements
    ]

    with conn.cursor() as cursor:
        cursor.executemany(
            """
            INSERT INTO users_achievements (user_id, achievement_id, mode, created_at)
            VALUES (%s, %s, %s, %s)
            """,
            values,
        )
        conn.commit()

    print(f"✓ Migrated {len(achievements)} achievements to mode 8")

    if verbose:
        # Count unique users affected
        unique_users = len(set(ach["user_id"] for ach in achievements))
        print(f"  Affected {unique_users} unique users")

    return len(achievements)


def delete_mode7_achievements(conn: Any, dry_run: bool = False) -> int:
    """Delete all mode 7 achievements after successful migration."""
    with conn.cursor() as cursor:
        cursor.execute("SELECT COUNT(*) as count FROM users_achievements WHERE mode = 7")
        result = cursor.fetchone()
        count = result["count"]

        if count == 0:
            print("No mode 7 achievements to delete")
            return 0

        if dry_run:
            print(f"DRY RUN: Would delete {count} mode 7 achievements")
            return count

        cursor.execute("DELETE FROM users_achievements WHERE mode = 7")
        conn.commit()

        print(f"✓ Deleted {count} mode 7 achievements")
        return count


def verify_migration(conn: Any) -> None:
    """Verify the migration was successful."""
    with conn.cursor() as cursor:
        # Check mode 7 count (should be 0)
        cursor.execute("SELECT COUNT(*) as count FROM users_achievements WHERE mode = 7")
        mode7_count = cursor.fetchone()["count"]

        # Check mode 8 count
        cursor.execute("SELECT COUNT(*) as count FROM users_achievements WHERE mode = 8")
        mode8_count = cursor.fetchone()["count"]

        # Check backup exists
        cursor.execute("SELECT COUNT(*) as count FROM users_achievements_mode7_backup")
        backup_count = cursor.fetchone()["count"]

        print("\nVerification:")
        print(f"  Mode 7 achievements remaining: {mode7_count} (should be 0)")
        print(f"  Mode 8 achievements: {mode8_count}")
        print(f"  Backup table records: {backup_count}")

        if mode7_count == 0 and backup_count > 0:
            print("  ✓ Migration successful!")
        elif mode7_count > 0:
            print("  ⚠ Warning: Mode 7 achievements still exist")
        else:
            print("  ✓ Looks good!")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Consolidate mode 7 autopilot achievements to mode 8"
    )
    parser.add_argument("--host", default="localhost", help="MySQL host")
    parser.add_argument("--port", type=int, default=3306, help="MySQL port")
    parser.add_argument("--user", default="root", help="MySQL user")
    parser.add_argument("--password", default="", help="MySQL password")
    parser.add_argument("--database", default="akatsuki", help="MySQL database")
    parser.add_argument("--dry-run", action="store_true", help="Don't write to database")
    parser.add_argument("--verbose", action="store_true", help="Print detailed progress")

    args = parser.parse_args()

    # Connect to MySQL
    print(f"Connecting to {args.host}:{args.port}/{args.database}...")
    conn = pymysql.connect(
        host=args.host,
        port=args.port,
        user=args.user,
        password=args.password,
        database=args.database,
        cursorclass=pymysql.cursors.DictCursor,
    )

    try:
        start_time = time.time()

        if args.dry_run:
            print("\n=== DRY RUN MODE - No changes will be made ===\n")
        else:
            print("\n=== MODE 7→8 CONSOLIDATION ===\n")

        # Step 1: Create backup
        print("Step 1: Creating backup table...")
        create_backup_table(conn, dry_run=args.dry_run)

        # Step 2: Find achievements to migrate
        print("\nStep 2: Finding achievements to migrate...")
        achievements_to_migrate = find_achievements_to_migrate(conn)

        if args.verbose:
            unique_users = len(set(ach["user_id"] for ach in achievements_to_migrate))
            print(f"  Found {len(achievements_to_migrate)} achievements from {unique_users} users")

        # Step 3: Migrate to mode 8
        print("\nStep 3: Migrating achievements to mode 8...")
        migrated_count = migrate_achievements(
            conn,
            achievements_to_migrate,
            dry_run=args.dry_run,
            verbose=args.verbose,
        )

        # Step 4: Delete mode 7 achievements
        print("\nStep 4: Deleting original mode 7 achievements...")
        delete_mode7_achievements(conn, dry_run=args.dry_run)

        # Step 5: Verify migration
        if not args.dry_run:
            verify_migration(conn)

        elapsed = time.time() - start_time
        print(f"\nCompleted in {elapsed:.2f} seconds")

        if args.dry_run:
            print("\n=== DRY RUN COMPLETE - No changes were made ===")
            print("Run without --dry-run to apply changes")

        return 0

    except Exception as e:
        print(f"\nError: {e}", file=sys.stderr)
        return 1

    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
