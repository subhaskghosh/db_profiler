-- file:select_implicit.sql ln:44 expect:true
SELECT count(*) FROM test_missing_target GROUP BY b ORDER BY b desc
