-- usado pelo ci: compila o pacote e os testes e falha se algum objeto ficar com erro
whenever sqlerror exit failure
set define off
set serveroutput on size unlimited
set feedback off

@src/doc_br.pks
@src/doc_br.pkb
@test/ut_doc_br.pks
@test/ut_doc_br.pkb

-- create or replace com erro de compilação não dispara sqlerror; por isso confere a user_errors
declare
  v_erros pls_integer;
begin
  select count(*) into v_erros from user_errors;
  if v_erros > 0 then
    for e in (select name, type, line, position, text from user_errors order by name, type, sequence) loop
      dbms_output.put_line(e.type || ' ' || e.name || ' linha ' || e.line || ':' || e.position || ' ' || e.text);
    end loop;
    raise_application_error(-20999, v_erros || ' erro(s) de compilação');
  end if;
  dbms_output.put_line('compilado sem erros');
end;
/

exit
