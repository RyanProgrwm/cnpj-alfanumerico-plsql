# CNPJ alfanumérico em PL/SQL

[![ci](https://github.com/RyanProgrwm/cnpj-alfanumerico-plsql/actions/workflows/ci.yml/badge.svg)](https://github.com/RyanProgrwm/cnpj-alfanumerico-plsql/actions/workflows/ci.yml)
![Oracle](https://img.shields.io/badge/Oracle-19c%2B-F80000)
![utPLSQL](https://img.shields.io/badge/testes-utPLSQL-2E7D32)
![license](https://img.shields.io/badge/license-MIT-blue)

Pacote PL/SQL para **validar, calcular e formatar o CNPJ alfanumérico** (e o CPF), com testes automatizados rodando num Oracle de verdade a cada commit, e **scripts que acham no seu banco o que vai quebrar** com a mudança.

> *English summary: a PL/SQL package that validates, computes check digits and formats Brazil's new alphanumeric company ID (CNPJ), plus dictionary scripts that find NUMBER columns and code that will break. Tested with utPLSQL on Oracle Free in GitHub Actions.*

## O que mudou

Desde **julho de 2026** a Receita Federal pode atribuir CNPJs com **letras** (IN RFB nº 2.119/2022, alterada pela IN RFB nº 2.229/2024):

| Posição | Antes | Agora |
| --- | --- | --- |
| 1 a 12 (raiz + ordem) | só números | números **e letras A–Z** |
| 13 e 14 (dígitos verificadores) | números | continuam números |

- Os CNPJs numéricos que já existem **continuam válidos**, e a Receita ainda pode emitir CNPJs numéricos novos.
- O formato novo vale também para **filiais novas de empresas antigas**, então até um cliente antigo pode aparecer com letra.
- No cálculo do dígito, cada caractere passa a valer o **código ASCII − 48**: `0`–`9` continuam valendo 0 a 9, `A` vale 17 e `Z` vale 42. O resto (módulo 11 e pesos) não muda.

Exemplo oficial da Receita: **12.ABC.345/01DE-35**.

## Uso

```sql
-- instalar no seu schema
@install.sql

select doc_br.cnpj_valido('12.ABC.345/01DE-35') from dual;   -- 1
select doc_br.cnpj_formatado('12abc34501de35')  from dual;   -- 12.ABC.345/01DE-35
select doc_br.cnpj_dv('12ABC34501DE')           from dual;   -- 35
select doc_br.cnpj_alfanumerico('11222333000181') from dual; -- 0
select doc_br.cnpj_gerar(1)                     from dual;   -- cnpj alfanumérico aleatório e válido, para teste
```

| Função | Retorno |
| --- | --- |
| `cnpj_valido(cnpj)` | `1` válido / `0` inválido. Aceita com ou sem máscara, maiúsculas ou minúsculas |
| `cnpj_dv(base12)` | os 2 dígitos verificadores; erro `-20001` se a base for inválida |
| `cnpj_formatado(cnpj)` | `99.XXX.XXX/XXXX-99`; erro `-20002` se o CNPJ for inválido |
| `cnpj_alfanumerico(cnpj)` | `1` se tem letra (formato novo) |
| `cnpj_gerar(alfanumerico)` | CNPJ válido aleatório para massa de teste |
| `cpf_valido`, `cpf_dv`, `cpf_formatado` | o mesmo para CPF |
| `limpa(documento)` | tira `.` `/` `-` e espaços e passa para maiúsculas |

As funções devolvem `1`/`0` em vez de `boolean` para poderem ser usadas em `select`, `where` e índices de função no **Oracle 19c** (boolean em SQL só existe a partir do 23ai).

## Achar o que vai quebrar no seu sistema

Validar o CNPJ é a parte fácil. O trabalho de verdade num ERP é achar tudo o que assume que CNPJ é número. Dois scripts só de leitura ajudam:

**[`scripts/colunas_cnpj.sql`](scripts/colunas_cnpj.sql)**: colunas com `CNPJ` ou `CGC` (nome antigo, comum em sistema legado) no nome que são **numéricas** ou **texto com menos de 14 posições**.

```
OWNER  TABLE_NAME       COLUMN_NAME   TIPO           PROBLEMA
APP    CLIENTE_LEGADO   CGC_ANTIGO    VARCHAR2(11)   texto curto: precisa de 14 posições sem máscara
APP    CLIENTE_LEGADO   CNPJ          NUMBER(14)     numérico: não aceita letras
```

**[`scripts/codigo_cnpj_numerico.sql`](scripts/codigo_cnpj_numerico.sql)**: linhas de PL/SQL que falam de CNPJ e usam `to_number`, `to_char`, `lpad` com zero, máscara `99.999.999` e parecidos.

### Armadilhas comuns em sistemas legados

Aprendi estas mantendo um ERP Oracle em produção:

- **Coluna `NUMBER`**: além de não aceitar letra, já come o zero à esquerda. CNPJ `01.234.567/0001-89` vira `1234567000189`, e todo lugar compensa com `lpad(..., 14, '0')`.
- **`%type` de coluna numérica**: variáveis declaradas como `tabela.cnpj%type` herdam o `NUMBER` e quebram junto quando o valor tem letra.
- **Máscara de tela e de relatório**: `99.999.999/9999-99` em Oracle Forms, Reports ou APEX só aceita dígito.
- **Joins e índices**: comparar coluna `NUMBER` com `VARCHAR2` faz o Oracle converter implicitamente, e o primeiro CNPJ com letra estoura `ORA-01722` no meio de uma consulta que sempre funcionou.
- **Arquivos e integrações**: leiautes posicionais (CNAB, SPED, EDI) com campo do tipo "N" para CNPJ precisam ser revistos com o layout novo de cada órgão ou banco.
- **Validação duplicada**: a regra do dígito costuma existir em vários lugares (trigger, tela, package). Centralizar numa função como `doc_br.cnpj_valido` evita corrigir em um lugar e esquecer outro.

## Testes

16 testes com **[utPLSQL](https://www.utplsql.org/)** cobrindo o exemplo oficial da Receita, CNPJ numérico antigo, máscara, minúsculas, dígito errado, tamanho errado, caractere fora de A–Z, letra no dígito verificador, sequências repetidas, geração aleatória (200 CNPJs por execução), uso dentro de `select` e CPF.

A cada push, o **GitHub Actions**:
1. sobe um **Oracle Database Free** num contêiner ([gvenzl/oracle-free](https://hub.docker.com/r/gvenzl/oracle-free));
2. instala o utPLSQL;
3. compila o pacote e falha se houver qualquer erro de compilação;
4. roda os testes e os exemplos;
5. cria um "sistema legado" de exemplo e confere se os scripts de diagnóstico encontram cada problema.

Os valores esperados dos dígitos foram conferidos com uma implementação independente, fora do banco.

O CI roda no Oracle Free (23ai), mas o código usa só recursos disponíveis no **19c**.

## Estrutura

```
src/        pacote doc_br (spec e body)
test/       testes utPLSQL
scripts/    exemplos e diagnóstico (colunas e código que tratam cnpj como número)
ci/         scripts usados pelo GitHub Actions
install.sql instalação
```

## Autor

**Ryan Rodrigues Saldanha Faria**: desenvolvedor Oracle PL/SQL em ERP de produção.

[LinkedIn](https://www.linkedin.com/in/ryansaldanha1302) · [GitHub](https://github.com/RyanProgrwm)

Referência: [Perguntas e respostas sobre o CNPJ alfanumérico, Receita Federal](https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/publicacoes/perguntas-e-respostas/cnpj/cnpj-alfanumerico.pdf).
