-- file:window.sql ln:598 expect:true
SELECT STDDEV_SAMP(n::int) OVER (ORDER BY i ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
  FROM (VALUES(1,NULL),(2,600),(3,470),(4,170),(5,430),(6,300)) r(i,n)