-- instala o pacote doc_br no schema conectado
-- uso: sqlplus usuario/senha@banco @install.sql   (ou @install.sql no sqlcl / sql developer)
set define off
set feedback on

@@src/doc_br.pks
@@src/doc_br.pkb

show errors package doc_br
show errors package body doc_br
