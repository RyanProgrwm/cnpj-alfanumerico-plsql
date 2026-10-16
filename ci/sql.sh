#!/usr/bin/env bash
# roda um script sql no oracle do contêiner do ci.
# uso: ci/sql.sh <conexão> @script.sql
# se o sqlplus falhar, publica o fim da saída como anotação de erro do github actions
conexao="$1"
shift

saida=$(docker exec -e NLS_LANG=AMERICAN_AMERICA.AL32UTF8 -w /tmp/projeto "$DB" \
  sqlplus -s -l "$conexao" "$@" < /dev/null 2>&1)
status=$?

printf '%s\n' "$saida"

if [ $status -ne 0 ]; then
  # uma anotação só, com várias linhas (%0A é a quebra de linha nas anotações)
  resumo=$(printf '%s\n' "$saida" | grep -v '^[[:space:]]*$' | tail -40 | sed 's/%/%25/g' | sed ':a;N;$!ba;s/\n/%0A/g')
  echo "::error title=sqlplus falhou ($*)::$resumo"
fi

exit $status
