-- Add replay analysis JSON column to all score tables

ALTER TABLE scores
    ADD COLUMN replay_analysis JSON DEFAULT NULL,
    ADD COLUMN replay_analysis_at DATETIME DEFAULT NULL;

ALTER TABLE scores_relax
    ADD COLUMN replay_analysis JSON DEFAULT NULL,
    ADD COLUMN replay_analysis_at DATETIME DEFAULT NULL;

ALTER TABLE scores_ap
    ADD COLUMN replay_analysis JSON DEFAULT NULL,
    ADD COLUMN replay_analysis_at DATETIME DEFAULT NULL;

-- Index for finding unanalyzed scores and querying by analysis time
CREATE INDEX idx_scores_replay_analysis_at ON scores (replay_analysis_at);
CREATE INDEX idx_scores_relax_replay_analysis_at ON scores_relax (replay_analysis_at);
CREATE INDEX idx_scores_ap_replay_analysis_at ON scores_ap (replay_analysis_at);
