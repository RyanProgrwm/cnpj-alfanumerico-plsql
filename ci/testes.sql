-- usado pelo ci: roda a suíte do utplsql e imprime o relatório
whenever sqlerror exit failure
set serveroutput on size unlimited
set linesize 400
set pagesize 0
set heading off
set feedback off
set trimout on

select * from table(ut.run('ut_doc_br'));

exit
