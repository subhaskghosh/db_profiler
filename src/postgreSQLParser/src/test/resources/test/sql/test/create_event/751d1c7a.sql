-- file:event_trigger.sql ln:34 expect:true
create event trigger regress_event_trigger2 on ddl_command_start
   when food in ('sandwich')
   execute procedure test_event_trigger()
