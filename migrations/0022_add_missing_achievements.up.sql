-- Migration: Add 32 missing achievements and improve schema
-- Date: 2026-01-16
-- Purpose: Add tier 4 hit count medals (3), rank milestone medals (16), and hush-hush medals (13)

-- Step 1: Clean up duplicate achievement entries (keep earliest timestamp)
DELETE ua1 FROM users_achievements ua1
INNER JOIN users_achievements ua2
WHERE ua1.user_id = ua2.user_id
  AND ua1.achievement_id = ua2.achievement_id
  AND ua1.mode = ua2.mode
  AND ua1.id > ua2.id;

-- Step 2: Add hidden column to less_achievements for hush-hush medals
ALTER TABLE less_achievements
ADD COLUMN hidden BOOLEAN NOT NULL DEFAULT FALSE
COMMENT 'True for hush-hush (secret) medals not visible until unlocked';

-- Step 3: Insert 32 new achievement definitions

-- Category 1: 4th Tier Hit Count Medals (3 medals)
INSERT INTO less_achievements (id, file, name, `desc`, cond, hidden) VALUES
(97, 'taiko-hits-30000000', '30,000,000 Drum Hits', '30 million drum hits in osu!taiko', '30000000 <= stats.total_hits and mode_vn == 1', FALSE),
(98, 'catch-hits-20000000', '20,000,000 Fruits Caught', '20 million fruits caught in osu!catch', '20000000 <= stats.total_hits and mode_vn == 2', FALSE),
(99, 'mania-hits-40000000', '40,000,000 Keys Pressed', '40 million keys pressed in osu!mania', '40000000 <= stats.total_hits and mode_vn == 3', FALSE);

-- Category 2: Rank Milestone Medals - Per Mode (16 medals)
-- osu!std rank milestones
INSERT INTO less_achievements (id, file, name, `desc`, cond, hidden) VALUES
(100, 'std-rank-50000', 'Top 50,000: osu!std', 'Achieve a global rank of #50,000 or better in osu!std', 'stats.rank > 0 and stats.rank <= 50000 and mode_vn == 0', FALSE),
(101, 'std-rank-10000', 'Top 10,000: osu!std', 'Achieve a global rank of #10,000 or better in osu!std', 'stats.rank > 0 and stats.rank <= 10000 and mode_vn == 0', FALSE),
(102, 'std-rank-5000', 'Top 5,000: osu!std', 'Achieve a global rank of #5,000 or better in osu!std', 'stats.rank > 0 and stats.rank <= 5000 and mode_vn == 0', FALSE),
(103, 'std-rank-1000', 'Top 1,000: osu!std', 'Achieve a global rank of #1,000 or better in osu!std', 'stats.rank > 0 and stats.rank <= 1000 and mode_vn == 0', FALSE);

-- osu!taiko rank milestones
INSERT INTO less_achievements (id, file, name, `desc`, cond, hidden) VALUES
(104, 'taiko-rank-50000', 'Top 50,000: osu!taiko', 'Achieve a global rank of #50,000 or better in osu!taiko', 'stats.rank > 0 and stats.rank <= 50000 and mode_vn == 1', FALSE),
(105, 'taiko-rank-10000', 'Top 10,000: osu!taiko', 'Achieve a global rank of #10,000 or better in osu!taiko', 'stats.rank > 0 and stats.rank <= 10000 and mode_vn == 1', FALSE),
(106, 'taiko-rank-5000', 'Top 5,000: osu!taiko', 'Achieve a global rank of #5,000 or better in osu!taiko', 'stats.rank > 0 and stats.rank <= 5000 and mode_vn == 1', FALSE),
(107, 'taiko-rank-1000', 'Top 1,000: osu!taiko', 'Achieve a global rank of #1,000 or better in osu!taiko', 'stats.rank > 0 and stats.rank <= 1000 and mode_vn == 1', FALSE);

-- osu!catch rank milestones
INSERT INTO less_achievements (id, file, name, `desc`, cond, hidden) VALUES
(108, 'catch-rank-50000', 'Top 50,000: osu!catch', 'Achieve a global rank of #50,000 or better in osu!catch', 'stats.rank > 0 and stats.rank <= 50000 and mode_vn == 2', FALSE),
(109, 'catch-rank-10000', 'Top 10,000: osu!catch', 'Achieve a global rank of #10,000 or better in osu!catch', 'stats.rank > 0 and stats.rank <= 10000 and mode_vn == 2', FALSE),
(110, 'catch-rank-5000', 'Top 5,000: osu!catch', 'Achieve a global rank of #5,000 or better in osu!catch', 'stats.rank > 0 and stats.rank <= 5000 and mode_vn == 2', FALSE),
(111, 'catch-rank-1000', 'Top 1,000: osu!catch', 'Achieve a global rank of #1,000 or better in osu!catch', 'stats.rank > 0 and stats.rank <= 1000 and mode_vn == 2', FALSE);

-- osu!mania rank milestones
INSERT INTO less_achievements (id, file, name, `desc`, cond, hidden) VALUES
(112, 'mania-rank-50000', 'Top 50,000: osu!mania', 'Achieve a global rank of #50,000 or better in osu!mania', 'stats.rank > 0 and stats.rank <= 50000 and mode_vn == 3', FALSE),
(113, 'mania-rank-10000', 'Top 10,000: osu!mania', 'Achieve a global rank of #10,000 or better in osu!mania', 'stats.rank > 0 and stats.rank <= 10000 and mode_vn == 3', FALSE),
(114, 'mania-rank-5000', 'Top 5,000: osu!mania', 'Achieve a global rank of #5,000 or better in osu!mania', 'stats.rank > 0 and stats.rank <= 5000 and mode_vn == 3', FALSE),
(115, 'mania-rank-1000', 'Top 1,000: osu!mania', 'Achieve a global rank of #1,000 or better in osu!mania', 'stats.rank > 0 and stats.rank <= 1000 and mode_vn == 3', FALSE);

-- Category 3: Hush-Hush Secret Medals (13 medals)
-- Note: Many require complex logic beyond current achievement system (time-based, multi-score, etc.)
-- Placeholder False conditions will be replaced in decorator-based system (Sprint 2/3)
INSERT INTO less_achievements (id, file, name, `desc`, cond, hidden) VALUES
(116, 'all-secret-bunny', 'Don''t let the bunny distract you!', 'Complete any difficulty of Chatmonchy - Make Up! Make Up! with a full combo', 'False', TRUE),
(117, 'all-secret-s-ranker', 'S-Ranker', 'Achieve five S (or SS) ranks on different maps within 24 hours', 'False', TRUE),
(118, 'all-secret-improved', 'Most Improved', 'Get a D rank, then achieve an A+ on the same map within 24 hours', 'False', TRUE),
(119, 'std-secret-dancer', 'Non-stop Dancer', 'Pass Yoko Ishida - paraparaMAX I with over 3,000,000 score', 'False', TRUE),
(120, 'all-secret-consolation', 'Consolation Prize', 'Get a D rank on any map with a score above 100,000', 'False', TRUE),
(121, 'all-secret-challenge', 'Challenge Accepted', 'Pass any approved map with an A rank or higher', 'False', TRUE),
(122, 'all-secret-stumbler', 'Stumbler', 'Complete any map with a full combo and less than 85% accuracy', 'score.full_combo and score.acc < 85.0', TRUE),
(123, 'all-secret-jackpot', 'Jackpot', 'Pass a map where every digit of the score is identical', 'score.passed and len(set(str(score.score))) == 1', TRUE),
(124, 'all-secret-quick-draw', 'Quick Draw', 'Be the first to submit a score on any ranked or qualified map', 'False', TRUE),
(125, 'all-secret-obsessed', 'Obsessed', 'Retry a map 100+ times and pass within 24 hours', 'False', TRUE),
(126, 'all-secret-nonstop', 'Nonstop', 'Complete any map with a full combo and drain time of 8:41 or longer', 'False', TRUE),
(127, 'all-secret-jack-trades', 'Jack of All Trades', 'Reach 5,000+ playcount in all four game modes', 'False', TRUE),
(128, 'mania-secret-twin', 'Twin Perspectives', 'Pass any ranked mania map with 100 combo or more', 'score.passed and score.max_combo >= 100 and mode_vn == 3', TRUE);

-- Step 4: Add index on mode column for better query performance
ALTER TABLE users_achievements
ADD INDEX idx_mode (mode);

-- Step 5: Add UNIQUE constraint to prevent duplicate achievements
ALTER TABLE users_achievements
ADD UNIQUE KEY unique_user_achievement_mode (user_id, achievement_id, mode);
