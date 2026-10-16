create or replace package body doc_br is

  type t_pesos is table of pls_integer;

  c_digitos constant varchar2(10) := '0123456789';
  c_letras  constant varchar2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  c_alfanum constant varchar2(36) := c_digitos || c_letras;

  c_pesos_cnpj_dv1 constant t_pesos := t_pesos(5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2);
  c_pesos_cnpj_dv2 constant t_pesos := t_pesos(6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2);
  c_pesos_cpf_dv1  constant t_pesos := t_pesos(10, 9, 8, 7, 6, 5, 4, 3, 2);
  c_pesos_cpf_dv2  constant t_pesos := t_pesos(11, 10, 9, 8, 7, 6, 5, 4, 3, 2);

  -- verdadeiro se todos os caracteres de p_texto estão em p_permitidos.
  -- usa translate em vez de regexp [A-Z] para não depender do nls_sort (que pode aceitar acentos)
  function so_contem(p_texto in varchar2, p_permitidos in varchar2) return boolean is
  begin
    return p_texto is not null and translate(p_texto, '#' || p_permitidos, '#') is null;
  end so_contem;

  -- verdadeiro se o texto é um único caractere repetido (ex.: 00000000000000), que a regra trata como inválido
  function repetido(p_texto in varchar2) return boolean is
  begin
    return p_texto = rpad(substr(p_texto, 1, 1), length(p_texto), substr(p_texto, 1, 1));
  end repetido;

  -- módulo 11: valor de cada caractere = código ascii - 48 ('0'..'9' = 0..9, 'A' = 17 ... 'Z' = 42).
  -- para dígitos numéricos o resultado é o mesmo do cálculo antigo, então cnpj numérico continua válido
  function digito(p_texto in varchar2, p_pesos in t_pesos) return varchar2 is
    v_soma  pls_integer := 0;
    v_resto pls_integer;
  begin
    for i in 1 .. p_pesos.count loop
      v_soma := v_soma + (ascii(substr(p_texto, i, 1)) - 48) * p_pesos(i);
    end loop;

    v_resto := mod(v_soma, 11);
    return to_char(case when v_resto < 2 then 0 else 11 - v_resto end);
  end digito;

  function limpa(p_documento in varchar2) return varchar2 deterministic is
  begin
    return upper(translate(p_documento, 'x./- ', 'x'));
  end limpa;

  -- cnpj

  function cnpj_dv(p_base in varchar2) return varchar2 deterministic is
    v_base varchar2(4000) := limpa(p_base);
    v_dv1  varchar2(1);
  begin
    if length(v_base) <> 12 or not so_contem(v_base, c_alfanum) or v_base is null then
      raise_application_error(-20001, 'a base do cnpj precisa ter 12 caracteres entre 0-9 e A-Z: ' || p_base);
    end if;

    v_dv1 := digito(v_base, c_pesos_cnpj_dv1);
    return v_dv1 || digito(v_base || v_dv1, c_pesos_cnpj_dv2);
  end cnpj_dv;

  function cnpj_valido(p_cnpj in varchar2) return number deterministic is
    v_cnpj varchar2(4000) := limpa(p_cnpj);
  begin
    if v_cnpj is null
       or length(v_cnpj) <> 14
       or not so_contem(substr(v_cnpj, 1, 12), c_alfanum)
       or not so_contem(substr(v_cnpj, 13, 2), c_digitos)
       or repetido(v_cnpj)
    then
      return 0;
    end if;

    return case when substr(v_cnpj, 13, 2) = cnpj_dv(substr(v_cnpj, 1, 12)) then 1 else 0 end;
  end cnpj_valido;

  function cnpj_alfanumerico(p_cnpj in varchar2) return number deterministic is
    v_cnpj varchar2(4000) := limpa(p_cnpj);
  begin
    -- tem letra se, ao remover as letras, o texto encolhe
    return case
             when nvl(length(translate(v_cnpj, '#' || c_letras, '#')), 0) < length(v_cnpj) then 1
             else 0
           end;
  end cnpj_alfanumerico;

  function cnpj_formatado(p_cnpj in varchar2) return varchar2 deterministic is
    v_cnpj varchar2(4000) := limpa(p_cnpj);
  begin
    if v_cnpj is null then
      return null;
    end if;
    if cnpj_valido(v_cnpj) = 0 then
      raise_application_error(-20002, 'cnpj inválido: ' || p_cnpj);
    end if;

    return substr(v_cnpj, 1, 2) || '.' || substr(v_cnpj, 3, 3) || '.' || substr(v_cnpj, 6, 3)
        || '/' || substr(v_cnpj, 9, 4) || '-' || substr(v_cnpj, 13, 2);
  end cnpj_formatado;

  function cnpj_gerar(p_alfanumerico in number default 1) return varchar2 is
    v_limite pls_integer := case when p_alfanumerico = 1 then length(c_alfanum) else length(c_digitos) end;
    v_raiz   varchar2(8);
  begin
    -- raiz aleatória de 8 posições + ordem 0001 (matriz)
    loop
      v_raiz := null;
      for i in 1 .. 8 loop
        v_raiz := v_raiz || substr(c_alfanum, trunc(dbms_random.value(1, v_limite + 1)), 1);
      end loop;
      exit when (p_alfanumerico = 0 or not so_contem(v_raiz, c_digitos)) and not repetido(v_raiz);
    end loop;

    return v_raiz || '0001' || cnpj_dv(v_raiz || '0001');
  end cnpj_gerar;

  -- cpf

  function cpf_dv(p_base in varchar2) return varchar2 deterministic is
    v_base varchar2(4000) := limpa(p_base);
    v_dv1  varchar2(1);
  begin
    if length(v_base) <> 9 or not so_contem(v_base, c_digitos) or v_base is null then
      raise_application_error(-20001, 'a base do cpf precisa ter 9 dígitos: ' || p_base);
    end if;

    v_dv1 := digito(v_base, c_pesos_cpf_dv1);
    return v_dv1 || digito(v_base || v_dv1, c_pesos_cpf_dv2);
  end cpf_dv;

  function cpf_valido(p_cpf in varchar2) return number deterministic is
    v_cpf varchar2(4000) := limpa(p_cpf);
  begin
    if v_cpf is null or length(v_cpf) <> 11 or not so_contem(v_cpf, c_digitos) or repetido(v_cpf) then
      return 0;
    end if;

    return case when substr(v_cpf, 10, 2) = cpf_dv(substr(v_cpf, 1, 9)) then 1 else 0 end;
  end cpf_valido;

  function cpf_formatado(p_cpf in varchar2) return varchar2 deterministic is
    v_cpf varchar2(4000) := limpa(p_cpf);
  begin
    if v_cpf is null then
      return null;
    end if;
    if cpf_valido(v_cpf) = 0 then
      raise_application_error(-20002, 'cpf inválido: ' || p_cpf);
    end if;

    return substr(v_cpf, 1, 3) || '.' || substr(v_cpf, 4, 3) || '.' || substr(v_cpf, 7, 3) || '-' || substr(v_cpf, 10, 2);
  end cpf_formatado;

end doc_br;
/
