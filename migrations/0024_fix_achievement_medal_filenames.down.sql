-- Revert achievement file names back to original Akatsuki naming convention

-- Revert rank milestone achievements
UPDATE less_achievements SET file = 'std-rank-50000' WHERE file = 'all-skill-highranker-1' AND name = 'Top 50,000: osu!std';
UPDATE less_achievements SET file = 'taiko-rank-50000' WHERE file = 'all-skill-highranker-1' AND name = 'Top 50,000: osu!taiko';
UPDATE less_achievements SET file = 'catch-rank-50000' WHERE file = 'all-skill-highranker-1' AND name = 'Top 50,000: osu!catch';
UPDATE less_achievements SET file = 'mania-rank-50000' WHERE file = 'all-skill-highranker-1' AND name = 'Top 50,000: osu!mania';

UPDATE less_achievements SET file = 'std-rank-10000' WHERE file = 'all-skill-highranker-2' AND name = 'Top 10,000: osu!std';
UPDATE less_achievements SET file = 'taiko-rank-10000' WHERE file = 'all-skill-highranker-2' AND name = 'Top 10,000: osu!taiko';
UPDATE less_achievements SET file = 'catch-rank-10000' WHERE file = 'all-skill-highranker-2' AND name = 'Top 10,000: osu!catch';
UPDATE less_achievements SET file = 'mania-rank-10000' WHERE file = 'all-skill-highranker-2' AND name = 'Top 10,000: osu!mania';

UPDATE less_achievements SET file = 'std-rank-5000' WHERE file = 'all-skill-highranker-3' AND name = 'Top 5,000: osu!std';
UPDATE less_achievements SET file = 'taiko-rank-5000' WHERE file = 'all-skill-highranker-3' AND name = 'Top 5,000: osu!taiko';
UPDATE less_achievements SET file = 'catch-rank-5000' WHERE file = 'all-skill-highranker-3' AND name = 'Top 5,000: osu!catch';
UPDATE less_achievements SET file = 'mania-rank-5000' WHERE file = 'all-skill-highranker-3' AND name = 'Top 5,000: osu!mania';

UPDATE less_achievements SET file = 'std-rank-1000' WHERE file = 'all-skill-highranker-4' AND name = 'Top 1,000: osu!std';
UPDATE less_achievements SET file = 'taiko-rank-1000' WHERE file = 'all-skill-highranker-4' AND name = 'Top 1,000: osu!taiko';
UPDATE less_achievements SET file = 'catch-rank-1000' WHERE file = 'all-skill-highranker-4' AND name = 'Top 1,000: osu!catch';
UPDATE less_achievements SET file = 'mania-rank-1000' WHERE file = 'all-skill-highranker-4' AND name = 'Top 1,000: osu!mania';

-- Revert hit count achievements
UPDATE less_achievements SET file = 'catch-hits-20000000' WHERE file = 'fruits-hits-20000000';

-- Revert secret achievements
UPDATE less_achievements SET file = 'all-secret-s-ranker' WHERE file = 'all-secret-rank-s';
UPDATE less_achievements SET file = 'std-secret-dancer' WHERE file = 'all-secret-dancer' AND name = 'Non-stop Dancer';
UPDATE less_achievements SET file = 'all-secret-consolation' WHERE file = 'all-secret-consolation_prize';
UPDATE less_achievements SET file = 'all-secret-challenge' WHERE file = 'all-secret-challenge_accepted';
UPDATE less_achievements SET file = 'all-secret-quick-draw' WHERE file = 'all-secret-quick_draw';
UPDATE less_achievements SET file = 'all-secret-jack-trades' WHERE file = 'all-secret-jack' AND name = 'Jack of All Trades';
UPDATE less_achievements SET file = 'mania-secret-twin' WHERE file = 'mania-secret-meganekko';
