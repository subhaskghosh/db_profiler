-- file:jsonb.sql ln:1043 expect:true
select jsonb_insert('{"a": [0,1,2]}', '{a, 2}', '"new_value"', true)
