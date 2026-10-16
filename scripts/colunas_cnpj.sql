-- lista colunas que provavelmente guardam cnpj e não aceitam o formato alfanumérico:
-- tipo numérico (não aceita letra) ou texto com menos de 14 posições.
-- procura também por "cgc", nome antigo do cnpj que ainda aparece em sistemas legados.
-- inclui views. só lê o dicionário; não altera nada.
set linesize 260
set pagesize 200
column owner format a20
column table_name format a30
column column_name format a30
column tipo format a20
column problema format a50

select c.owner,
       c.table_name,
       c.column_name,
       c.data_type
       || case
            when c.data_type = 'NUMBER' and c.data_precision is not null
              then '(' || c.data_precision || nvl2(nullif(c.data_scale, 0), ',' || c.data_scale, null) || ')'
            when c.data_type in ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR')
              then '(' || c.char_length || ')'
          end as tipo,
       case
         when c.data_type in ('NUMBER', 'FLOAT', 'INTEGER', 'BINARY_DOUBLE')
           then 'numérico: não aceita letras'
         else 'texto curto: precisa de 14 posições sem máscara'
       end as problema
  from all_tab_columns c
 where regexp_like(c.column_name, 'CNPJ|CGC', 'i')
   and c.owner not in ('SYS', 'SYSTEM', 'XDB', 'MDSYS', 'CTXSYS', 'ORDSYS', 'WMSYS', 'UT3')
   and (   c.data_type in ('NUMBER', 'FLOAT', 'INTEGER', 'BINARY_DOUBLE')
        or (c.data_type in ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR') and c.char_length < 14))
 order by c.owner, c.table_name, c.column_name;
