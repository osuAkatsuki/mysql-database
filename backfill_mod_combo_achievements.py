#!/usr/bin/env python3
"""
Backfill mod-based and combo-based achievements from historical scores.

Sprint 6: Processes 6.3M+ scores across 3 tables to grant 15 achievements.

Usage:
    python backfill_mod_combo_achievements.py \
        --mysql-host localhost \
        --mysql-port 3306 \
        --mysql-user root \
        --mysql-password <password> \
        --mysql-database akatsuki \
        [--achievement-id ID] \
        [--achievement-type mod|combo] \
        [--dry-run] \
        [--verbose]
"""

import argparse
import sys
import time
from dataclasses import dataclass
from typing import Any

import pymysql


# Achievement definitions
MOD_ACHIEVEMENTS = [
    (86, "all-intro-suddendeath", 32),  # SD
    (87, "all-intro-perfect", 16384),  # PF
    (88, "all-intro-hardrock", 16),  # HR
    (89, "all-intro-doubletime", 64),  # DT
    (90, "all-intro-nightcore", 512),  # NC
    (91, "all-intro-hidden", 8),  # HD
    (92, "all-intro-flashlight", 1024),  # FL
    (93, "all-intro-easy", 2),  # EZ
    (94, "all-intro-nofail", 1),  # NF
    (95, "all-intro-halftime", 256),  # HT
    (96, "all-intro-spunout", 4096),  # SO
]

COMBO_ACHIEVEMENTS = [
    (21, "osu-combo-500", 500),
    (22, "osu-combo-750", 750),
    (23, "osu-combo-1000", 1000),
    (24, "osu-combo-2000", 2000),
]

SCORE_TABLES = ["scores", "scores_relax", "scores_ap"]


@dataclass
class AchievementGrant:
    """Represents a single achievement grant."""

    user_id: int
    mode: int
    created_at: int


def query_mod_achievement(
    conn: pymysql.Connection,
    achievement_id: int,
    mod_flag: int,
    table: str,
    verbose: bool,
) -> list[AchievementGrant]:
    """Query earliest qualifying scores for mod achievement."""
    query = f"""
        SELECT
            s.userid AS user_id,
            CASE
                WHEN '{table}' = 'scores' THEN s.play_mode
                WHEN '{table}' = 'scores_relax' THEN s.play_mode + 4
                WHEN '{table}' = 'scores_ap' THEN 8
            END AS mode,
            MIN(s.time) AS created_at
        FROM {table} s
        LEFT JOIN users_achievements ua
            ON ua.user_id = s.userid
            AND ua.achievement_id = %s
            AND ua.mode = CASE
                WHEN '{table}' = 'scores' THEN s.play_mode
                WHEN '{table}' = 'scores_relax' THEN s.play_mode + 4
                WHEN '{table}' = 'scores_ap' THEN 8
            END
        WHERE s.mods & %s != 0
          AND s.completed = 3
          AND ua.id IS NULL
        GROUP BY s.userid, s.play_mode
    """

    if verbose:
        print(f"    Querying {table}...", end="", flush=True)

    start_time = time.time()

    with conn.cursor() as cursor:
        cursor.execute(query, (achievement_id, mod_flag))
        results = cursor.fetchall()

    elapsed = time.time() - start_time

    if verbose:
        print(f" {len(results)} grants in {elapsed:.1f}s")

    return [
        AchievementGrant(user_id=row[0], mode=row[1], created_at=row[2])
        for row in results
    ]


def query_combo_achievement(
    conn: pymysql.Connection,
    achievement_id: int,
    threshold: int,
    table: str,
    verbose: bool,
) -> list[AchievementGrant]:
    """Query earliest qualifying scores for combo achievement (standard mode only)."""
    query = f"""
        SELECT
            s.userid AS user_id,
            CASE
                WHEN '{table}' = 'scores' THEN 0
                WHEN '{table}' = 'scores_relax' THEN 4
                WHEN '{table}' = 'scores_ap' THEN 8
            END AS mode,
            MIN(s.time) AS created_at
        FROM {table} s
        LEFT JOIN users_achievements ua
            ON ua.user_id = s.userid
            AND ua.achievement_id = %s
            AND ua.mode = CASE
                WHEN '{table}' = 'scores' THEN 0
                WHEN '{table}' = 'scores_relax' THEN 4
                WHEN '{table}' = 'scores_ap' THEN 8
            END
        WHERE s.max_combo >= %s
          AND s.play_mode = 0
          AND s.completed = 3
          AND ua.id IS NULL
        GROUP BY s.userid
    """

    if verbose:
        print(f"    Querying {table}...", end="", flush=True)

    start_time = time.time()

    with conn.cursor() as cursor:
        cursor.execute(query, (achievement_id, threshold))
        results = cursor.fetchall()

    elapsed = time.time() - start_time

    if verbose:
        print(f" {len(results)} grants in {elapsed:.1f}s")

    return [
        AchievementGrant(user_id=row[0], mode=row[1], created_at=row[2])
        for row in results
    ]


def backfill_achievement(
    conn: pymysql.Connection,
    achievement_id: int,
    grants: list[AchievementGrant],
    dry_run: bool,
) -> int:
    """Insert achievements with historical timestamps."""
    if not grants:
        return 0

    if dry_run:
        return len(grants)

    with conn.cursor() as cursor:
        cursor.executemany(
            """
            INSERT IGNORE INTO users_achievements
            (user_id, achievement_id, mode, created_at)
            VALUES (%s, %s, %s, %s)
            """,
            [
                (grant.user_id, achievement_id, grant.mode, grant.created_at)
                for grant in grants
            ],
        )
        inserted = cursor.rowcount
        conn.commit()

    return inserted


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Backfill mod and combo achievements from historical scores",
    )
    parser.add_argument("--mysql-host", required=True, help="MySQL host")
    parser.add_argument("--mysql-port", type=int, default=3306, help="MySQL port")
    parser.add_argument("--mysql-user", required=True, help="MySQL user")
    parser.add_argument("--mysql-password", required=True, help="MySQL password")
    parser.add_argument("--mysql-database", required=True, help="MySQL database")
    parser.add_argument(
        "--achievement-id",
        type=int,
        help="Process only this achievement ID (for testing)",
    )
    parser.add_argument(
        "--achievement-type",
        choices=["mod", "combo"],
        help="Process only this achievement type (for testing)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run queries but don't insert achievements",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print detailed progress information",
    )

    args = parser.parse_args()

    # Connect to MySQL
    print(f"Connecting to MySQL at {args.mysql_host}:{args.mysql_port}...")
    conn = pymysql.connect(
        host=args.mysql_host,
        port=args.mysql_port,
        user=args.mysql_user,
        password=args.mysql_password,
        database=args.mysql_database,
        cursorclass=pymysql.cursors.Cursor,
    )

    try:
        # Determine which achievements to process
        achievements_to_process = []

        if args.achievement_id:
            # Find specific achievement
            for ach_id, ach_file, value in MOD_ACHIEVEMENTS + COMBO_ACHIEVEMENTS:
                if ach_id == args.achievement_id:
                    ach_type = "mod" if ach_id >= 86 else "combo"
                    achievements_to_process.append((ach_type, ach_id, ach_file, value))
                    break
            else:
                print(f"ERROR: Achievement ID {args.achievement_id} not found")
                return 1
        else:
            # Process all achievements of specified type(s)
            if not args.achievement_type or args.achievement_type == "mod":
                for ach_id, ach_file, value in MOD_ACHIEVEMENTS:
                    achievements_to_process.append(("mod", ach_id, ach_file, value))

            if not args.achievement_type or args.achievement_type == "combo":
                for ach_id, ach_file, value in COMBO_ACHIEVEMENTS:
                    achievements_to_process.append(("combo", ach_id, ach_file, value))

        total_achievements = len(achievements_to_process)
        total_grants = 0

        print(
            f"\nProcessing {total_achievements} achievement(s) "
            f"{'(DRY RUN)' if args.dry_run else ''}",
        )
        print("=" * 80)

        for i, (ach_type, ach_id, ach_file, value) in enumerate(
            achievements_to_process,
            start=1,
        ):
            print(f"\n[{i}/{total_achievements}] {ach_file} (ID {ach_id})")

            all_grants: list[AchievementGrant] = []

            # Query each score table
            for table in SCORE_TABLES:
                if ach_type == "mod":
                    results = query_mod_achievement(
                        conn,
                        ach_id,
                        value,
                        table,
                        args.verbose,
                    )
                else:
                    # Combo achievements (standard mode only)
                    results = query_combo_achievement(
                        conn,
                        ach_id,
                        value,
                        table,
                        args.verbose,
                    )

                all_grants.extend(results)

            # Backfill achievements
            granted = backfill_achievement(conn, ach_id, all_grants, args.dry_run)
            total_grants += granted

            print(
                f"  ✓ {'Would grant' if args.dry_run else 'Granted'} to "
                f"{granted} user-mode combination(s)",
            )

        print("\n" + "=" * 80)
        print(
            f"Total: {total_grants} {'potential ' if args.dry_run else ''}grants "
            f"across {total_achievements} achievement(s)",
        )

        return 0

    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
