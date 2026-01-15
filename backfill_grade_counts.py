#!/usr/bin/env python3
"""
Optimized backfill grade counts in user_stats table.

Key optimizations:
1. Skip users with no completed scores
2. Use window functions instead of 6 subqueries per row
3. Process in batches for better progress visibility

Usage:
    python backfill_grade_counts_optimized.py --host localhost --user root --password pass --database akatsuki
"""
import argparse
import sys
from collections import Counter
from typing import Any

import pymysql


def calculate_grade(
    *,
    vanilla_mode: int,
    mods: int,
    acc: float,
    n300: int,
    n100: int,
    n50: int,
    nmiss: int,
) -> str:
    """Calculate grade for a score. Logic from score-service."""
    objectCount = n300 + n100 + n50 + nmiss
    if objectCount == 0:
        return "D"

    shouldUseSilverGrades = (mods & 1049608) > 0

    if vanilla_mode == 0:  # osu!
        ratio300 = n300 / objectCount
        ratio50 = n50 / objectCount
        if ratio300 == 1:
            return "XH" if shouldUseSilverGrades else "X"
        if ratio300 > 0.9 and ratio50 <= 0.01 and nmiss == 0:
            return "SH" if shouldUseSilverGrades else "S"
        if ratio300 > 0.8 and nmiss == 0 or ratio300 > 0.9:
            return "A"
        if ratio300 > 0.7 and nmiss == 0 or ratio300 > 0.8:
            return "B"
        if ratio300 > 0.6:
            return "C"
        return "D"
    elif vanilla_mode == 1:  # osu!taiko
        ratio300 = n300 / objectCount
        ratio50 = n50 / objectCount
        if ratio300 == 1:
            return "XH" if shouldUseSilverGrades else "X"
        if ratio300 > 0.9 and ratio50 <= 0.01 and nmiss == 0:
            return "SH" if shouldUseSilverGrades else "S"
        if ratio300 > 0.8 and nmiss == 0 or ratio300 > 0.9:
            return "A"
        if ratio300 > 0.7 and nmiss == 0 or ratio300 > 0.8:
            return "B"
        if ratio300 > 0.6:
            return "C"
        return "D"
    elif vanilla_mode == 2:  # osu!catch
        if acc == 100:
            return "XH" if shouldUseSilverGrades else "X"
        if acc > 98:
            return "SH" if shouldUseSilverGrades else "S"
        if acc > 94:
            return "A"
        if acc > 90:
            return "B"
        if acc > 85:
            return "C"
        return "D"
    elif vanilla_mode == 3:  # osu!mania
        if acc == 100:
            return "XH" if shouldUseSilverGrades else "X"
        if acc > 95:
            return "SH" if shouldUseSilverGrades else "S"
        if acc > 90:
            return "A"
        if acc > 80:
            return "B"
        if acc > 70:
            return "C"
        return "D"
    else:
        return "D"


def get_table_for_mode(mode: int) -> str:
    """Get the scores table name for a given mode."""
    if mode in (0, 1, 2, 3):  # vanilla modes
        return "scores"
    elif mode in (4, 5, 6):  # relax modes
        return "scores_relax"
    elif mode == 8:  # autopilot
        return "scores_ap"
    else:
        raise ValueError(f"Unknown mode: {mode}")


def vanilla_mode_from_mode(mode: int) -> int:
    """Convert mode enum to vanilla mode (0-3)."""
    return mode % 4


def backfill_user_mode(conn: Any, user_id: int, mode: int, dry_run: bool = False) -> dict[str, int]:
    """
    Backfill grade counts for a specific user and mode.

    Returns a dict with the recalculated grade counts.
    """
    table = get_table_for_mode(mode)
    vanilla_mode = vanilla_mode_from_mode(mode)

    with conn.cursor() as cursor:
        # Optimized query: use a derived table with row numbers to get best score per beatmap/mods
        # This is MUCH faster than 6 correlated subqueries
        query = f"""
            SELECT
                s.beatmap_md5,
                s.mods,
                s.accuracy,
                s.300_count as n300,
                s.100_count as n100,
                s.50_count as n50,
                s.misses_count as nmiss
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY beatmap_md5, mods
                        ORDER BY pp DESC
                    ) as rn
                FROM {table}
                WHERE userid = %s
                AND play_mode = %s
                AND completed = 3
            ) s
            WHERE s.rn = 1
        """

        cursor.execute(query, (user_id, vanilla_mode))
        scores = cursor.fetchall()

        # Count grades
        grade_counts = Counter()
        for score in scores:
            grade = calculate_grade(
                vanilla_mode=vanilla_mode,
                mods=score["mods"],
                acc=score["accuracy"],
                n300=score["n300"],
                n100=score["n100"],
                n50=score["n50"],
                nmiss=score["nmiss"],
            )
            grade_counts[grade] += 1

        # Build grade count dict
        result = {
            "xh_count": grade_counts.get("XH", 0),
            "x_count": grade_counts.get("X", 0),
            "sh_count": grade_counts.get("SH", 0),
            "s_count": grade_counts.get("S", 0),
            "a_count": grade_counts.get("A", 0),
            "b_count": grade_counts.get("B", 0),
            "c_count": grade_counts.get("C", 0),
            "d_count": grade_counts.get("D", 0),
        }

        if not dry_run:
            # Update user_stats
            cursor.execute(
                """
                UPDATE user_stats
                SET xh_count = %s, x_count = %s, sh_count = %s, s_count = %s,
                    a_count = %s, b_count = %s, c_count = %s, d_count = %s
                WHERE user_id = %s AND mode = %s
                """,
                (
                    result["xh_count"],
                    result["x_count"],
                    result["sh_count"],
                    result["s_count"],
                    result["a_count"],
                    result["b_count"],
                    result["c_count"],
                    result["d_count"],
                    user_id,
                    mode,
                ),
            )
            conn.commit()

        return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Backfill grade counts in user_stats (optimized)")
    parser.add_argument("--host", default="localhost", help="MySQL host")
    parser.add_argument("--port", type=int, default=3306, help="MySQL port")
    parser.add_argument("--user", default="root", help="MySQL user")
    parser.add_argument("--password", default="", help="MySQL password")
    parser.add_argument("--database", default="akatsuki", help="MySQL database")
    parser.add_argument("--user-id", type=int, help="Backfill specific user ID only")
    parser.add_argument("--mode", type=int, help="Backfill specific mode only (0-8)")
    parser.add_argument("--dry-run", action="store_true", help="Don't write to database")
    parser.add_argument("--verbose", action="store_true", help="Print detailed progress")

    args = parser.parse_args()

    # Connect to MySQL
    conn = pymysql.connect(
        host=args.host,
        port=args.port,
        user=args.user,
        password=args.password,
        database=args.database,
        cursorclass=pymysql.cursors.DictCursor,
    )

    try:
        with conn.cursor() as cursor:
            # OPTIMIZATION: Only get user/mode combinations that have at least one completed score
            if args.user_id and args.mode is not None:
                # Specific user and mode
                cursor.execute(
                    "SELECT user_id, mode FROM user_stats WHERE user_id = %s AND mode = %s",
                    (args.user_id, args.mode),
                )
            elif args.user_id:
                # Specific user, all modes
                cursor.execute(
                    "SELECT user_id, mode FROM user_stats WHERE user_id = %s",
                    (args.user_id,),
                )
            elif args.mode is not None:
                # All users, specific mode - filter by those with scores
                table = get_table_for_mode(args.mode)
                vanilla_mode = vanilla_mode_from_mode(args.mode)
                cursor.execute(
                    f"""
                    SELECT DISTINCT us.user_id, us.mode
                    FROM user_stats us
                    INNER JOIN {table} s ON s.userid = us.user_id
                        AND s.play_mode = %s
                        AND s.completed = 3
                    WHERE us.mode = %s
                    ORDER BY us.user_id
                    """,
                    (vanilla_mode, args.mode),
                )
            else:
                # All users, all modes - filter by those with scores
                cursor.execute(
                    """
                    SELECT DISTINCT us.user_id, us.mode
                    FROM user_stats us
                    WHERE EXISTS (
                        SELECT 1 FROM scores s
                        WHERE s.userid = us.user_id
                        AND s.play_mode = (us.mode % 4)
                        AND s.completed = 3
                        AND us.mode IN (0, 1, 2, 3)
                    )
                    OR EXISTS (
                        SELECT 1 FROM scores_relax s
                        WHERE s.userid = us.user_id
                        AND s.play_mode = (us.mode % 4)
                        AND s.completed = 3
                        AND us.mode IN (4, 5, 6)
                    )
                    OR EXISTS (
                        SELECT 1 FROM scores_ap s
                        WHERE s.userid = us.user_id
                        AND s.play_mode = (us.mode % 4)
                        AND s.completed = 3
                        AND us.mode = 8
                    )
                    ORDER BY us.user_id
                    """
                )

            user_modes = cursor.fetchall()

        print(f"Backfilling {len(user_modes)} user/mode combinations (skipping users with no scores)...")
        if args.dry_run:
            print("DRY RUN - no changes will be written to database")

        for i, row in enumerate(user_modes, 1):
            user_id = row["user_id"]
            mode = row["mode"]

            try:
                grades = backfill_user_mode(conn, user_id, mode, dry_run=args.dry_run)

                if args.verbose or i % 100 == 0:
                    print(
                        f"[{i}/{len(user_modes)}] User {user_id} mode {mode}: "
                        f"XH={grades['xh_count']} X={grades['x_count']} "
                        f"SH={grades['sh_count']} S={grades['s_count']} "
                        f"A={grades['a_count']}"
                    )
            except Exception as e:
                print(f"Error processing user {user_id} mode {mode}: {e}", file=sys.stderr)
                continue

        print("Backfill complete!")
        return 0

    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
