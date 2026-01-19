-- Update achievement file names to match osu! medal slugs
-- This allows medals to load correctly from https://assets.ppy.sh/medals/client/
--
-- Background: Akatsuki's achievement filenames don't match osu!'s actual medal image slugs.
-- For example, 'catch-rank-10000' doesn't exist on osu!'s CDN, but 'all-skill-highranker-2' does.
--
-- Note: osu! uses generic rank medals (all-skill-highranker-1 through 4) that are re-earnable
-- per gamemode, so all mode-specific rank achievements map to the same medal images.

-- Rank milestone achievements → generic highranker medals
UPDATE less_achievements SET file = 'all-skill-highranker-1' WHERE file IN ('std-rank-50000', 'taiko-rank-50000', 'catch-rank-50000', 'mania-rank-50000');
UPDATE less_achievements SET file = 'all-skill-highranker-2' WHERE file IN ('std-rank-10000', 'taiko-rank-10000', 'catch-rank-10000', 'mania-rank-10000');
UPDATE less_achievements SET file = 'all-skill-highranker-3' WHERE file IN ('std-rank-5000', 'taiko-rank-5000', 'catch-rank-5000', 'mania-rank-5000');
UPDATE less_achievements SET file = 'all-skill-highranker-4' WHERE file IN ('std-rank-1000', 'taiko-rank-1000', 'catch-rank-1000', 'mania-rank-1000');

-- Hit count achievements → osu! uses "fruits" not "catch"
UPDATE less_achievements SET file = 'fruits-hits-20000000' WHERE file = 'catch-hits-20000000';

-- Secret achievements → minor naming differences
UPDATE less_achievements SET file = 'all-secret-rank-s' WHERE file = 'all-secret-s-ranker';
UPDATE less_achievements SET file = 'all-secret-dancer' WHERE file = 'std-secret-dancer';
UPDATE less_achievements SET file = 'all-secret-consolation_prize' WHERE file = 'all-secret-consolation';
UPDATE less_achievements SET file = 'all-secret-challenge_accepted' WHERE file = 'all-secret-challenge';
UPDATE less_achievements SET file = 'all-secret-quick_draw' WHERE file = 'all-secret-quick-draw';
UPDATE less_achievements SET file = 'all-secret-jack' WHERE file = 'all-secret-jack-trades';
UPDATE less_achievements SET file = 'mania-secret-meganekko' WHERE file = 'mania-secret-twin';
