-- usado pelo ci: confirma que o utplsql está instalado e acessível pelo usuário da aplicação
whenever sqlerror exit failure
set heading off
set feedback off
set pagesize 0

select 'UTPLSQL=' || ut.version() from dual;

exit
