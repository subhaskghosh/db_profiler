-- file:updatable_views.sql ln:1264 expect:true
insert into rw_view1 values ('yyy',2.0,1)
  on conflict (aa) do update set bb = excluded.bb
