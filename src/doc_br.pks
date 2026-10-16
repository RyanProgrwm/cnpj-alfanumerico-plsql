create or replace package doc_br authid definer is
  -- validação, cálculo de dígito e formatação de documentos brasileiros:
  -- cpf e cnpj, incluindo o cnpj alfanumérico (in rfb 2.119/2022, alterada pela in rfb 2.229/2024).
  --
  -- compatível com oracle 19c. as funções usadas em sql devolvem 1/0 em vez de boolean,
  -- porque boolean só passou a existir em sql no 23ai.

  -- tira a máscara (. / - e espaços) e passa para maiúsculas
  function limpa(p_documento in varchar2) return varchar2 deterministic;

  -- cnpj: 12 posições alfanuméricas (0-9, A-Z) + 2 dígitos verificadores numéricos

  -- devolve os 2 dígitos verificadores dos 12 primeiros caracteres; erro -20001 se a base for inválida
  function cnpj_dv(p_base in varchar2) return varchar2 deterministic;

  -- 1 se o cnpj (com ou sem máscara, numérico ou alfanumérico) é válido, 0 se não
  function cnpj_valido(p_cnpj in varchar2) return number deterministic;

  -- 1 se o cnpj tem alguma letra (formato novo), 0 se é só numérico
  function cnpj_alfanumerico(p_cnpj in varchar2) return number deterministic;

  -- formata no padrão 12.ABC.345/01DE-35; erro -20002 se o cnpj for inválido
  function cnpj_formatado(p_cnpj in varchar2) return varchar2 deterministic;

  -- gera um cnpj válido para teste (matriz 0001); p_alfanumerico = 1 garante ao menos uma letra
  function cnpj_gerar(p_alfanumerico in number default 1) return varchar2;

  -- cpf: 11 dígitos numéricos

  -- devolve os 2 dígitos verificadores dos 9 primeiros dígitos; erro -20001 se a base for inválida
  function cpf_dv(p_base in varchar2) return varchar2 deterministic;

  -- 1 se o cpf (com ou sem máscara) é válido, 0 se não
  function cpf_valido(p_cpf in varchar2) return number deterministic;

  -- formata no padrão 529.982.247-25; erro -20002 se o cpf for inválido
  function cpf_formatado(p_cpf in varchar2) return varchar2 deterministic;
end doc_br;
/
