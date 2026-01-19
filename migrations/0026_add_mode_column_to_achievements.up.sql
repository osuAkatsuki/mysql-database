-- Add mode column to less_achievements for mode-specific filtering
-- Allows the API to filter achievements by game mode instead of returning all achievements.
--
-- Mode values:
--   0 = osu!standard
--   1 = osu!taiko
--   2 = osu!catch
--   3 = osu!mania
--   NULL = Universal (shown for all modes)

ALTER TABLE less_achievements
  ADD COLUMN mode TINYINT DEFAULT NULL
  COMMENT 'Game mode (0=std, 1=taiko, 2=catch, 3=mania, NULL=all modes)';

-- osu!standard achievements
UPDATE less_achievements SET mode = 0 WHERE id BETWEEN 1 AND 24;    -- Pass, FC, Combo
UPDATE less_achievements SET mode = 0 WHERE id BETWEEN 73 AND 76;   -- Play count
UPDATE less_achievements SET mode = 0 WHERE id BETWEEN 100 AND 103; -- Rank

-- osu!taiko achievements
UPDATE less_achievements SET mode = 1 WHERE id BETWEEN 25 AND 40;   -- Pass, FC
UPDATE less_achievements SET mode = 1 WHERE id BETWEEN 77 AND 79;   -- Hit count (3 tiers)
UPDATE less_achievements SET mode = 1 WHERE id = 97;                -- Hit count (30M - 4th tier)
UPDATE less_achievements SET mode = 1 WHERE id BETWEEN 104 AND 107; -- Rank

-- osu!catch achievements
UPDATE less_achievements SET mode = 2 WHERE id BETWEEN 41 AND 56;   -- Pass, FC
UPDATE less_achievements SET mode = 2 WHERE id BETWEEN 80 AND 82;   -- Catch count (3 tiers)
UPDATE less_achievements SET mode = 2 WHERE id = 98;                -- Catch count (20M - 4th tier)
UPDATE less_achievements SET mode = 2 WHERE id BETWEEN 108 AND 111; -- Rank

-- osu!mania achievements
UPDATE less_achievements SET mode = 3 WHERE id BETWEEN 57 AND 72;   -- Pass, FC
UPDATE less_achievements SET mode = 3 WHERE id BETWEEN 83 AND 85;   -- Key press count (3 tiers)
UPDATE less_achievements SET mode = 3 WHERE id = 99;                -- Key press count (40M - 4th tier)
UPDATE less_achievements SET mode = 3 WHERE id BETWEEN 112 AND 115; -- Rank

-- Universal achievements (mode = NULL)
-- IDs 86-96: Mod introductions
-- IDs 116-128: Hush-hush secrets
-- These remain NULL (default) and are shown for all modes
