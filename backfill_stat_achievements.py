#!/usr/bin/env python3
"""
Backfill stat-based and rank-based achievements for historical users.

This script grants 37 achievements (21 stat-based + 16 rank-based) to users who
earned them through gameplay but never received them because:
1. They played before the achievement system was implemented
2. The achievement system only checks on score submission (no historical backfill)

Achievement Categories:
- Playcount (4): osu!std only, 5k/15k/25k/50k plays
- Hit Count (12): Taiko/Catch/Mania, 4 tiers each
- Rank Milestones (16): All 4 modes, 50k/10k/5k/1k ranks

Key Design Decision:
This script backfills ALL missing achievements, not just users with 0 achievements.
Example: User has rank 5000 achievement but lacks rank 10000/50000 → backfills both.

Usage:
    python backfill_stat_achievements.py \\
        --mysql-host localhost \\
        --mysql-port 3306 \\
        --mysql-user root \\
        --mysql-password <password> \\
        --mysql-database akatsuki \\
        --redis-host localhost \\
        --redis-port 6379 \\
        [--achievement-id ID] \\
        [--dry-run] \\
        [--verbose]
"""
import argparse
import sys
import time
from dataclasses import dataclass
from typing import Any

import pymysql
import redis


@dataclass
class Achievement:
    """Achievement definition."""

    id: int
    name: str
    type: str  # "playcount", "hits", "rank"
    mode_vn: int  # Vanilla mode (0-3)
    threshold: int
    file: str  # Achievement file name


# Achievement definitions
ACHIEVEMENTS = [
    # Playcount achievements (osu!std only) - IDs 73-76
    Achievement(73, "5,000 Plays", "playcount", 0, 5_000, "osu-plays-5000"),
    Achievement(74, "15,000 Plays", "playcount", 0, 15_000, "osu-plays-15000"),
    Achievement(75, "25,000 Plays", "playcount", 0, 25_000, "osu-plays-25000"),
    Achievement(76, "50,000 Plays", "playcount", 0, 50_000, "osu-plays-50000"),
    # Taiko hit count - IDs 77-79, 97
    Achievement(77, "30,000 Drum Hits", "hits", 1, 30_000, "taiko-hits-30000"),
    Achievement(78, "300,000 Drum Hits", "hits", 1, 300_000, "taiko-hits-300000"),
    Achievement(79, "3,000,000 Drum Hits", "hits", 1, 3_000_000, "taiko-hits-3000000"),
    Achievement(97, "30,000,000 Drum Hits", "hits", 1, 30_000_000, "taiko-hits-30000000"),
    # Catch hit count - IDs 80-82, 98
    Achievement(80, "20,000 Fruits", "hits", 2, 20_000, "fruits-hits-20000"),
    Achievement(81, "200,000 Fruits", "hits", 2, 200_000, "fruits-hits-200000"),
    Achievement(82, "2,000,000 Fruits", "hits", 2, 2_000_000, "fruits-hits-2000000"),
    Achievement(98, "20,000,000 Fruits", "hits", 2, 20_000_000, "fruits-hits-20000000"),
    # Mania hit count - IDs 83-85, 99
    Achievement(83, "40,000 Keys", "hits", 3, 40_000, "mania-hits-40000"),
    Achievement(84, "400,000 Keys", "hits", 3, 400_000, "mania-hits-400000"),
    Achievement(85, "4,000,000 Keys", "hits", 3, 4_000_000, "mania-hits-4000000"),
    Achievement(99, "40,000,000 Keys", "hits", 3, 40_000_000, "mania-hits-40000000"),
    # Rank achievements - All modes (IDs 100-115)
    # osu!std
    Achievement(100, "Top 50,000: osu!std", "rank", 0, 50_000, "osu-rank-50000"),
    Achievement(101, "Top 10,000: osu!std", "rank", 0, 10_000, "osu-rank-10000"),
    Achievement(102, "Top 5,000: osu!std", "rank", 0, 5_000, "osu-rank-5000"),
    Achievement(103, "Top 1,000: osu!std", "rank", 0, 1_000, "osu-rank-1000"),
    # osu!taiko
    Achievement(104, "Top 50,000: osu!taiko", "rank", 1, 50_000, "taiko-rank-50000"),
    Achievement(105, "Top 10,000: osu!taiko", "rank", 1, 10_000, "taiko-rank-10000"),
    Achievement(106, "Top 5,000: osu!taiko", "rank", 1, 5_000, "taiko-rank-5000"),
    Achievement(107, "Top 1,000: osu!taiko", "rank", 1, 1_000, "taiko-rank-1000"),
    # osu!catch
    Achievement(108, "Top 50,000: osu!catch", "rank", 2, 50_000, "fruits-rank-50000"),
    Achievement(109, "Top 10,000: osu!catch", "rank", 2, 10_000, "fruits-rank-10000"),
    Achievement(110, "Top 5,000: osu!catch", "rank", 2, 5_000, "fruits-rank-5000"),
    Achievement(111, "Top 1,000: osu!catch", "rank", 2, 1_000, "fruits-rank-1000"),
    # osu!mania
    Achievement(112, "Top 50,000: osu!mania", "rank", 3, 50_000, "mania-rank-50000"),
    Achievement(113, "Top 10,000: osu!mania", "rank", 3, 10_000, "mania-rank-10000"),
    Achievement(114, "Top 5,000: osu!mania", "rank", 3, 5_000, "mania-rank-5000"),
    Achievement(115, "Top 1,000: osu!mania", "rank", 3, 1_000, "mania-rank-1000"),
]


def get_mode_variants(mode_vn: int) -> list[int]:
    """Get all mode variants for a vanilla mode.

    Args:
        mode_vn: Vanilla mode (0-3)

    Returns:
        List of full modes to check (e.g., [0, 4, 8] for std)
    """
    if mode_vn == 0:  # std
        return [0, 4, 8]  # vanilla, relax, autopilot
    elif mode_vn == 1:  # taiko
        return [1, 5]  # vanilla, relax
    elif mode_vn == 2:  # catch
        return [2, 6]  # vanilla, relax
    elif mode_vn == 3:  # mania
        return [3]  # vanilla only
    else:
        raise ValueError(f"Invalid mode_vn: {mode_vn}")


def get_redis_leaderboard_key(mode_vn: int, full_mode: int) -> str:
    """Get Redis leaderboard key for a mode.

    Args:
        mode_vn: Vanilla mode (0-3)
        full_mode: Full mode (0-8)

    Returns:
        Redis key for the leaderboard
    """
    mode_names = ["std", "taiko", "ctb", "mania"]
    mode_name = mode_names[mode_vn]

    if full_mode in (4, 5, 6):  # Relax modes
        return f"ripple:relaxboard:{mode_name}"
    elif full_mode == 8:  # Autopilot
        return f"ripple:autoboard:{mode_name}"
    else:  # Vanilla
        return f"ripple:leaderboard:{mode_name}"


def find_eligible_users_playcount(
    conn: Any,
    achievement: Achievement,
    verbose: bool = False,
) -> list[tuple[int, int]]:
    """Find users eligible for playcount achievement.

    Returns list of (user_id, mode) tuples.
    """
    eligible = []

    mode_variants = get_mode_variants(achievement.mode_vn)

    for full_mode in mode_variants:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT us.user_id, us.mode
                FROM user_stats us
                LEFT JOIN users_achievements ua
                  ON ua.user_id = us.user_id
                  AND ua.achievement_id = %s
                  AND ua.mode = us.mode
                WHERE us.playcount >= %s
                  AND us.mode = %s
                  AND ua.id IS NULL
                """,
                (achievement.id, achievement.threshold, full_mode),
            )
            results = cursor.fetchall()
            eligible.extend([(r["user_id"], r["mode"]) for r in results])

            if verbose and results:
                print(f"    Mode {full_mode}: {len(results)} users")

    return eligible


def find_eligible_users_hits(
    conn: Any,
    achievement: Achievement,
    verbose: bool = False,
) -> list[tuple[int, int]]:
    """Find users eligible for hit count achievement.

    Returns list of (user_id, mode) tuples.
    """
    eligible = []

    mode_variants = get_mode_variants(achievement.mode_vn)

    for full_mode in mode_variants:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT us.user_id, us.mode
                FROM user_stats us
                LEFT JOIN users_achievements ua
                  ON ua.user_id = us.user_id
                  AND ua.achievement_id = %s
                  AND ua.mode = us.mode
                WHERE us.total_hits >= %s
                  AND us.mode = %s
                  AND ua.id IS NULL
                """,
                (achievement.id, achievement.threshold, full_mode),
            )
            results = cursor.fetchall()
            eligible.extend([(r["user_id"], r["mode"]) for r in results])

            if verbose and results:
                print(f"    Mode {full_mode}: {len(results)} users")

    return eligible


def find_eligible_users_rank(
    conn: Any,
    redis_client: redis.Redis,
    achievement: Achievement,
    verbose: bool = False,
) -> list[tuple[int, int]]:
    """Find users eligible for rank achievement.

    Returns list of (user_id, mode) tuples.
    """
    eligible = []

    mode_variants = get_mode_variants(achievement.mode_vn)

    for full_mode in mode_variants:
        # Get all users for this mode with PP > 0
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT user_id
                FROM user_stats
                WHERE mode = %s AND pp > 0
                ORDER BY user_id
                """,
                (full_mode,),
            )
            users = [row["user_id"] for row in cursor.fetchall()]

        if not users:
            continue

        # Get ranks from Redis using pipeline
        leaderboard_key = get_redis_leaderboard_key(achievement.mode_vn, full_mode)
        pipe = redis_client.pipeline()

        for user_id in users:
            pipe.zrevrank(leaderboard_key, str(user_id))

        ranks = pipe.execute()

        # Filter users by rank threshold and check if they already have the achievement
        eligible_user_ids = []
        for user_id, rank_idx in zip(users, ranks):
            if rank_idx is not None:
                rank = int(rank_idx) + 1  # Redis rank is 0-indexed
                if 0 < rank <= achievement.threshold:
                    eligible_user_ids.append(user_id)

        if not eligible_user_ids:
            continue

        # Check which users don't already have this achievement
        with conn.cursor() as cursor:
            # Use chunked queries to avoid exceeding max_allowed_packet
            chunk_size = 1000
            for i in range(0, len(eligible_user_ids), chunk_size):
                chunk = eligible_user_ids[i : i + chunk_size]
                placeholders = ",".join(["%s"] * len(chunk))

                cursor.execute(
                    f"""
                    SELECT user_id
                    FROM user_stats
                    WHERE user_id IN ({placeholders})
                      AND mode = %s
                      AND user_id NOT IN (
                        SELECT user_id
                        FROM users_achievements
                        WHERE achievement_id = %s AND mode = %s
                      )
                    """,
                    (*chunk, full_mode, achievement.id, full_mode),
                )

                results = cursor.fetchall()
                eligible.extend([(r["user_id"], full_mode) for r in results])

        if verbose and eligible:
            mode_eligible = [u for u in eligible if u[1] == full_mode]
            print(f"    Mode {full_mode}: {len(mode_eligible)} users")

    return eligible


def backfill_achievement(
    conn: Any,
    achievement_id: int,
    eligible_users: list[tuple[int, int]],
    dry_run: bool = False,
) -> int:
    """Insert achievements for eligible users.

    Args:
        conn: MySQL connection
        achievement_id: Achievement ID to grant
        eligible_users: List of (user_id, mode) tuples
        dry_run: If True, don't actually insert

    Returns:
        Number of achievements granted
    """
    if not eligible_users:
        return 0

    if dry_run:
        return len(eligible_users)

    timestamp = int(time.time())
    values = [
        (user_id, achievement_id, mode, timestamp) for user_id, mode in eligible_users
    ]

    # Batch insert with INSERT IGNORE for idempotency
    with conn.cursor() as cursor:
        cursor.executemany(
            """
            INSERT IGNORE INTO users_achievements
            (user_id, achievement_id, mode, created_at)
            VALUES (%s, %s, %s, %s)
            """,
            values,
        )
        conn.commit()

    return len(eligible_users)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Backfill stat-based and rank-based achievements"
    )
    # MySQL connection
    parser.add_argument("--mysql-host", default="localhost", help="MySQL host")
    parser.add_argument("--mysql-port", type=int, default=3306, help="MySQL port")
    parser.add_argument("--mysql-user", default="root", help="MySQL user")
    parser.add_argument("--mysql-password", default="", help="MySQL password")
    parser.add_argument("--mysql-database", default="akatsuki", help="MySQL database")

    # Redis connection
    parser.add_argument("--redis-host", default="localhost", help="Redis host")
    parser.add_argument("--redis-port", type=int, default=6379, help="Redis port")

    # Options
    parser.add_argument(
        "--achievement-id",
        type=int,
        help="Backfill specific achievement ID only (for testing)",
    )
    parser.add_argument("--dry-run", action="store_true", help="Don't write to database")
    parser.add_argument("--verbose", action="store_true", help="Print detailed progress")

    args = parser.parse_args()

    # Connect to MySQL
    print(f"Connecting to MySQL {args.mysql_host}:{args.mysql_port}/{args.mysql_database}...")
    mysql_conn = pymysql.connect(
        host=args.mysql_host,
        port=args.mysql_port,
        user=args.mysql_user,
        password=args.mysql_password,
        database=args.mysql_database,
        cursorclass=pymysql.cursors.DictCursor,
    )

    # Connect to Redis
    print(f"Connecting to Redis {args.redis_host}:{args.redis_port}...")
    redis_client = redis.Redis(
        host=args.redis_host,
        port=args.redis_port,
        decode_responses=True,
    )

    try:
        start_time = time.time()

        if args.dry_run:
            print("\n=== DRY RUN MODE - No changes will be made ===\n")
        else:
            print("\n=== STAT-BASED ACHIEVEMENT BACKFILL ===\n")

        # Filter achievements if specific ID requested
        achievements_to_process = ACHIEVEMENTS
        if args.achievement_id:
            achievements_to_process = [
                a for a in ACHIEVEMENTS if a.id == args.achievement_id
            ]
            if not achievements_to_process:
                print(f"Error: Achievement ID {args.achievement_id} not found")
                return 1
            print(f"Processing single achievement: ID {args.achievement_id}\n")

        total_granted = 0
        total_users_affected = set()

        # Process each achievement
        for i, achievement in enumerate(achievements_to_process, 1):
            print(f"[{i}/{len(achievements_to_process)}] Processing: {achievement.name} (ID {achievement.id})")

            # Find eligible users based on achievement type
            if achievement.type == "playcount":
                eligible = find_eligible_users_playcount(
                    mysql_conn, achievement, verbose=args.verbose
                )
            elif achievement.type == "hits":
                eligible = find_eligible_users_hits(
                    mysql_conn, achievement, verbose=args.verbose
                )
            elif achievement.type == "rank":
                eligible = find_eligible_users_rank(
                    mysql_conn, redis_client, achievement, verbose=args.verbose
                )
            else:
                print(f"  ⚠ Unknown achievement type: {achievement.type}")
                continue

            # Backfill achievements
            if eligible:
                granted = backfill_achievement(
                    mysql_conn, achievement.id, eligible, dry_run=args.dry_run
                )
                total_granted += granted
                total_users_affected.update(user_id for user_id, _ in eligible)

                if args.dry_run:
                    print(f"  DRY RUN: Would grant to {granted} users")
                else:
                    print(f"  ✓ Granted to {granted} users")
            else:
                print(f"  No eligible users (all already have this achievement)")

        # Summary
        elapsed = time.time() - start_time
        print(f"\n{'=' * 60}")
        print("Summary:")
        print(f"  Total achievements granted: {total_granted:,}")
        print(f"  Total unique users affected: {len(total_users_affected):,}")
        print(f"  Time elapsed: {elapsed:.2f} seconds")
        print(f"{'=' * 60}")

        if args.dry_run:
            print("\n=== DRY RUN COMPLETE - No changes were made ===")
            print("Run without --dry-run to apply changes")

        return 0

    except Exception as e:
        print(f"\nError: {e}", file=sys.stderr)
        import traceback

        traceback.print_exc()
        return 1

    finally:
        mysql_conn.close()
        redis_client.close()


if __name__ == "__main__":
    sys.exit(main())
