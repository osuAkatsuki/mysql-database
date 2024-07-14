UPDATE users
SET privileges = privileges | (1<<25)
WHERE id IN (24732, 4640, 43810);