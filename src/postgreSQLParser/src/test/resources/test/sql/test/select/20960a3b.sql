-- file:json.sql ln:311 expect:true
select json_extract_path_text('{"f2":{"f3":1},"f4":{"f5":99,"f6":"stringy"}}','f2')
