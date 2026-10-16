-- usado pelo ci: cria um "sistema legado" de exemplo com os problemas típicos,
-- para provar que os scripts de diagnóstico encontram cada um
whenever sqlerror exit failure
set feedback off

create table cliente_legado (
  id         number primary key,
  cnpj       number(14),     -- problema: numérico
  cgc_antigo varchar2(11),   -- problema: texto curto (e com o nome antigo do cnpj)
  cnpj_novo  varchar2(14)    -- certo: não deve aparecer no diagnóstico
);

create or replace procedure grava_cliente_legado(p_id in number, p_cnpj in varchar2) is
begin
  insert into cliente_legado (id, cnpj) values (p_id, to_number(p_cnpj));
end;
/

exit
