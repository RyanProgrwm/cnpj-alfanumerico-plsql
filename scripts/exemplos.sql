-- exemplos de uso do pacote doc_br
set linesize 200
set pagesize 100
column cnpj format a22
column formatado format a22

-- validar e formatar
select doc_br.cnpj_valido('12.ABC.345/01DE-35') as valido,
       doc_br.cnpj_formatado('12abc34501de35')  as formatado
  from dual;

-- calcular os dígitos verificadores de uma base de 12 posições
select doc_br.cnpj_dv('12ABC34501DE') as dv from dual;

-- gerar cnpjs de teste
select doc_br.cnpj_gerar(1) as alfanumerico, doc_br.cnpj_gerar(0) as numerico from dual;

-- usar numa consulta: classificar uma lista de cnpjs
select column_value as cnpj,
       doc_br.cnpj_valido(column_value)       as valido,
       doc_br.cnpj_alfanumerico(column_value) as alfanumerico
  from table(sys.odcivarchar2list('12.ABC.345/01DE-35', '11.222.333/0001-81', '12.ABC.345/01DE-36'));
