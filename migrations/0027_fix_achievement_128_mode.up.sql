-- Fix mode for achievement ID 128 (Twin Perspectives)
-- This is a mania-specific secret achievement (mania-secret-meganekko)
-- but was incorrectly left as NULL in migration 0026

UPDATE less_achievements SET mode = 3 WHERE id = 128;
