-- file:line.sql ln:50 expect:true
SELECT point '(1,1)' <@ line '[(0,0),(2,2)]'
