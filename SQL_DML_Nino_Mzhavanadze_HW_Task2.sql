-- Q3
-- a) Execute time - 12s
-- b) Table size is unchanged - 575 MB
-- c) "public.table_to_delete": found 0 removable, 6666667 nonremovable row versions in 73536 pages
---d) Table size becomes - 383 MB
-- e) 

DROP TABLE IF EXISTS table_to_delete;
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;

-- Q4
-- a) 1.060s
-- b) TRUNCATE is extremaly fast
-- c) Space consumption is 8192 bytes, the table size is practically empty after a TRUNCATE