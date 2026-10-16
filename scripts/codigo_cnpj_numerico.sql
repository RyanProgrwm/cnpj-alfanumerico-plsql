-- procura no código pl/sql trechos que tratam cnpj como número e quebram com letras:
-- to_number, to_char com máscara numérica, lpad com zeros, %type de coluna numérica etc.
-- é uma busca por texto: confira cada linha, nem todo resultado é problema.
set linesize 250
set pagesize 500
column owner format a20
column name format a30
column type format a14
column texto format a120

select s.owner,
       s.name,
       s.type,
       s.line,
       substr(trim(s.text), 1, 120) as texto
  from all_source s
 where s.owner not in ('SYS', 'SYSTEM', 'XDB', 'MDSYS', 'CTXSYS', 'ORDSYS', 'WMSYS', 'UT3')
   and regexp_like(s.text, 'cnpj|cgc', 'i')
   and regexp_like(s.text, 'to_number|to_char\s*\(|lpad\s*\(.*''0''|99\.999\.999|fm0|mod\s*\(|is_number|number\s*\(\s*14', 'i')
 order by s.owner, s.name, s.type, s.line;
