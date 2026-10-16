create or replace package ut_doc_br is

  --%suite(doc_br: cpf e cnpj, incluindo o cnpj alfanumérico)

  --%context(cnpj)

  --%test(aceita o exemplo oficial da receita: 12.ABC.345/01DE-35)
  procedure cnpj_exemplo_oficial;

  --%test(continua aceitando cnpj numérico)
  procedure cnpj_numerico;

  --%test(aceita com ou sem máscara e com letras minúsculas)
  procedure cnpj_mascara_e_minusculas;

  --%test(calcula os dígitos verificadores)
  procedure cnpj_calcula_dv;

  --%test(recusa dígito verificador errado)
  procedure cnpj_dv_errado;

  --%test(recusa tamanho errado, caractere inválido, letra no dígito e nulo)
  procedure cnpj_formato_invalido;

  --%test(recusa todos os caracteres iguais)
  procedure cnpj_repetido;

  --%test(identifica cnpj alfanumérico)
  procedure cnpj_identifica_alfanumerico;

  --%test(formata no padrão da receita)
  procedure cnpj_formatacao;

  --%test(formatar cnpj inválido gera erro -20002)
  --%throws(-20002)
  procedure cnpj_formatar_invalido;

  --%test(calcular dígito de base inválida gera erro -20001)
  --%throws(-20001)
  procedure cnpj_dv_base_invalida;

  --%test(gera cnpj válido, numérico e alfanumérico)
  procedure cnpj_gerado_valido;

  --%test(funciona dentro de select)
  procedure cnpj_em_select;

  --%endcontext

  --%context(cpf)

  --%test(aceita cpf válido, com e sem máscara)
  procedure cpf_valido;

  --%test(recusa dígito errado, repetidos, letras e tamanho errado)
  procedure cpf_invalido;

  --%test(calcula os dígitos e formata)
  procedure cpf_dv_e_formatacao;

  --%endcontext

end ut_doc_br;
/
