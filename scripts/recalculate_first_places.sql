-- ============================================================
-- Recalculate First Places Script
--
-- This script fixes historical inaccuracies in the scores_first
-- table by:
-- 1. Deleting entries held by restricted users with no valid replacement
-- 2. Updating entries held by restricted users to the correct holder
-- 3. Inserting missing entries for beatmaps that should have first places
--
-- Safe to run on production:
-- - No table locks (uses row-level locking)
-- - No data loss (only fixes definitely-wrong entries)
-- - Idempotent (safe to run multiple times)
-- ============================================================

DELIMITER //

CREATE PROCEDURE RecalculateAllFirstPlaces()
BEGIN
    DECLARE rx_val INT;
    DECLARE scores_table VARCHAR(20);
    DECLARE sort_column VARCHAR(10);

    -- Loop through rx values: 0 = vanilla, 1 = relax, 2 = autopilot
    SET rx_val = 0;
    WHILE rx_val <= 2 DO
        -- Set table and sort column based on rx
        CASE rx_val
            WHEN 0 THEN
                SET scores_table = 'scores';
                SET sort_column = 'score';
            WHEN 1 THEN
                SET scores_table = 'scores_relax';
                SET sort_column = 'pp';
            WHEN 2 THEN
                SET scores_table = 'scores_ap';
                SET sort_column = 'pp';
        END CASE;

        SELECT CONCAT('Processing rx=', rx_val, ' (', scores_table, ', sorted by ', sort_column, ')') AS status;

        -- STEP 1: Delete entries where holder is restricted AND no valid replacement exists
        SET @sql = CONCAT('
            WITH valid_scores AS (
                SELECT DISTINCT ', scores_table, '.beatmap_md5, ', scores_table, '.play_mode
                FROM ', scores_table, '
                INNER JOIN users ON users.id = ', scores_table, '.userid
                INNER JOIN beatmaps ON beatmaps.beatmap_md5 = ', scores_table, '.beatmap_md5
                WHERE ', scores_table, '.completed = 3
                  AND users.privileges & 1 = 1
                  AND beatmaps.ranked > 1
            )
            DELETE scores_first FROM scores_first
            INNER JOIN users ON users.id = scores_first.userid
            LEFT JOIN valid_scores ON valid_scores.beatmap_md5 = scores_first.beatmap_md5
                                  AND valid_scores.play_mode = scores_first.mode
            WHERE users.privileges & 1 = 0
              AND scores_first.rx = ', rx_val, '
              AND valid_scores.beatmap_md5 IS NULL
        ');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        SELECT CONCAT('  Step 1 (delete orphaned): ', ROW_COUNT(), ' rows deleted') AS status;
        DEALLOCATE PREPARE stmt;

        -- STEP 2: Update entries where holder is restricted AND valid replacement exists
        SET @sql = CONCAT('
            WITH ranked_scores AS (
                SELECT
                    ', scores_table, '.beatmap_md5,
                    ', scores_table, '.play_mode,
                    ', scores_table, '.id,
                    ', scores_table, '.userid,
                    ROW_NUMBER() OVER (
                        PARTITION BY ', scores_table, '.beatmap_md5, ', scores_table, '.play_mode
                        ORDER BY ', scores_table, '.', sort_column, ' DESC, ', scores_table, '.time ASC
                    ) AS rn
                FROM ', scores_table, '
                INNER JOIN users ON users.id = ', scores_table, '.userid
                INNER JOIN beatmaps ON beatmaps.beatmap_md5 = ', scores_table, '.beatmap_md5
                WHERE ', scores_table, '.completed = 3
                  AND users.privileges & 1 = 1
                  AND beatmaps.ranked > 1
            ),
            best_scores AS (
                SELECT ranked_scores.beatmap_md5, ranked_scores.play_mode, ranked_scores.id AS new_scoreid, ranked_scores.userid AS new_userid
                FROM ranked_scores
                WHERE ranked_scores.rn = 1
            )
            UPDATE scores_first
            INNER JOIN users ON users.id = scores_first.userid
            INNER JOIN best_scores ON best_scores.beatmap_md5 = scores_first.beatmap_md5
                                  AND best_scores.play_mode = scores_first.mode
            SET scores_first.scoreid = best_scores.new_scoreid,
                scores_first.userid = best_scores.new_userid
            WHERE users.privileges & 1 = 0
              AND scores_first.rx = ', rx_val
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        SELECT CONCAT('  Step 2 (update restricted): ', ROW_COUNT(), ' rows updated') AS status;
        DEALLOCATE PREPARE stmt;

        -- STEP 3: Insert missing entries
        SET @sql = CONCAT('
            WITH ranked_scores AS (
                SELECT
                    ', scores_table, '.beatmap_md5,
                    ', scores_table, '.play_mode,
                    ', scores_table, '.id,
                    ', scores_table, '.userid,
                    ROW_NUMBER() OVER (
                        PARTITION BY ', scores_table, '.beatmap_md5, ', scores_table, '.play_mode
                        ORDER BY ', scores_table, '.', sort_column, ' DESC, ', scores_table, '.time ASC
                    ) AS rn
                FROM ', scores_table, '
                INNER JOIN users ON users.id = ', scores_table, '.userid
                INNER JOIN beatmaps ON beatmaps.beatmap_md5 = ', scores_table, '.beatmap_md5
                WHERE ', scores_table, '.completed = 3
                  AND users.privileges & 1 = 1
                  AND beatmaps.ranked > 1
            ),
            best_scores AS (
                SELECT ranked_scores.beatmap_md5, ranked_scores.play_mode, ranked_scores.id, ranked_scores.userid
                FROM ranked_scores
                WHERE ranked_scores.rn = 1
            ),
            existing_first_places AS (
                SELECT scores_first.beatmap_md5, scores_first.mode
                FROM scores_first
                WHERE scores_first.rx = ', rx_val, '
            )
            INSERT INTO scores_first (beatmap_md5, mode, rx, scoreid, userid)
            SELECT best_scores.beatmap_md5, best_scores.play_mode, ', rx_val, ', best_scores.id, best_scores.userid
            FROM best_scores
            LEFT JOIN existing_first_places ON existing_first_places.beatmap_md5 = best_scores.beatmap_md5
                                           AND existing_first_places.mode = best_scores.play_mode
            WHERE existing_first_places.beatmap_md5 IS NULL
        ');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        SELECT CONCAT('  Step 3 (insert missing): ', ROW_COUNT(), ' rows inserted') AS status;
        DEALLOCATE PREPARE stmt;

        SET rx_val = rx_val + 1;
    END WHILE;

    SELECT 'First places recalculation complete!' AS status;
END //

DELIMITER ;

-- Run the procedure
CALL RecalculateAllFirstPlaces();

-- Clean up
DROP PROCEDURE RecalculateAllFirstPlaces;
