whenever sqlerror exit sql.sqlcode
set define off
set serveroutput on

prompt Installing tables...
@@01_tables.sql
prompt Installing sample data...
@@02_sample_data.sql
prompt Installing package...
@@03_pkg_homework.sql
prompt Installation complete.
