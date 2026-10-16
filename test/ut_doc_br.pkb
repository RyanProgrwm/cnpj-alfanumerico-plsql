create or replace package body ut_doc_br is

  -- cnpj

  procedure cnpj_exemplo_oficial is
  begin
    ut.expect(doc_br.cnpj_valido('12.ABC.345/01DE-35')).to_equal(1);
  end;

  procedure cnpj_numerico is
  begin
    ut.expect(doc_br.cnpj_valido('11.222.333/0001-81')).to_equal(1);
    ut.expect(doc_br.cnpj_valido('11222333000181')).to_equal(1);
  end;

  procedure cnpj_mascara_e_minusculas is
  begin
    ut.expect(doc_br.cnpj_valido('12ABC34501DE35')).to_equal(1);
    ut.expect(doc_br.cnpj_valido('12.abc.345/01de-35')).to_equal(1);
    ut.expect(doc_br.cnpj_valido(' 12 ABC 345 01DE 35 ')).to_equal(1);
  end;

  procedure cnpj_calcula_dv is
  begin
    -- valores conferidos com uma implementação independente
    ut.expect(doc_br.cnpj_dv('12ABC34501DE')).to_equal('35');
    ut.expect(doc_br.cnpj_dv('112223330001')).to_equal('81');
    ut.expect(doc_br.cnpj_dv('AB12CD34EF56')).to_equal('02');
    ut.expect(doc_br.cnpj_dv('Z9Y8X7W6V5U4')).to_equal('29');
  end;

  procedure cnpj_dv_errado is
  begin
    ut.expect(doc_br.cnpj_valido('12.ABC.345/01DE-36')).to_equal(0);
    ut.expect(doc_br.cnpj_valido('11.222.333/0001-82')).to_equal(0);
  end;

  procedure cnpj_formato_invalido is
  begin
    ut.expect(doc_br.cnpj_valido(null)).to_equal(0);
    ut.expect(doc_br.cnpj_valido('12ABC34501DE3')).to_equal(0);      -- 13 posições
    ut.expect(doc_br.cnpj_valido('12ABC34501DE355')).to_equal(0);    -- 15 posições
    ut.expect(doc_br.cnpj_valido('12ABÇ34501DE35')).to_equal(0);     -- caractere fora de A-Z
    ut.expect(doc_br.cnpj_valido('12ABC34501DE3A')).to_equal(0);     -- letra no dígito verificador
    ut.expect(doc_br.cnpj_valido('12ABC34501DE#5')).to_equal(0);
  end;

  procedure cnpj_repetido is
  begin
    ut.expect(doc_br.cnpj_valido('00000000000000')).to_equal(0);
    ut.expect(doc_br.cnpj_valido('11111111111111')).to_equal(0);
  end;

  procedure cnpj_identifica_alfanumerico is
  begin
    ut.expect(doc_br.cnpj_alfanumerico('12.ABC.345/01DE-35')).to_equal(1);
    ut.expect(doc_br.cnpj_alfanumerico('11.222.333/0001-81')).to_equal(0);
    ut.expect(doc_br.cnpj_alfanumerico(null)).to_equal(0);
  end;

  procedure cnpj_formatacao is
  begin
    ut.expect(doc_br.cnpj_formatado('12abc34501de35')).to_equal('12.ABC.345/01DE-35');
    ut.expect(doc_br.cnpj_formatado('11222333000181')).to_equal('11.222.333/0001-81');
    ut.expect(doc_br.cnpj_formatado(null)).to_be_null();
  end;

  procedure cnpj_formatar_invalido is
    v_cnpj varchar2(20);
  begin
    v_cnpj := doc_br.cnpj_formatado('12ABC34501DE36');
  end;

  procedure cnpj_dv_base_invalida is
    v_dv varchar2(2);
  begin
    v_dv := doc_br.cnpj_dv('12ABC');
  end;

  procedure cnpj_gerado_valido is
    v_cnpj varchar2(14);
  begin
    for i in 1 .. 200 loop
      v_cnpj := doc_br.cnpj_gerar(1);
      ut.expect(doc_br.cnpj_valido(v_cnpj), 'alfanumérico ' || v_cnpj).to_equal(1);
      ut.expect(doc_br.cnpj_alfanumerico(v_cnpj), 'tem letra ' || v_cnpj).to_equal(1);

      v_cnpj := doc_br.cnpj_gerar(0);
      ut.expect(doc_br.cnpj_valido(v_cnpj), 'numérico ' || v_cnpj).to_equal(1);
      ut.expect(doc_br.cnpj_alfanumerico(v_cnpj), 'sem letra ' || v_cnpj).to_equal(0);
    end loop;
  end;

  procedure cnpj_em_select is
    v_validos number;
  begin
    select sum(doc_br.cnpj_valido(column_value))
      into v_validos
      from table(sys.odcivarchar2list('12ABC34501DE35', '11222333000181', '12ABC34501DE36', null));

    ut.expect(v_validos).to_equal(2);
  end;

  -- cpf

  procedure cpf_valido is
  begin
    ut.expect(doc_br.cpf_valido('529.982.247-25')).to_equal(1);
    ut.expect(doc_br.cpf_valido('52998224725')).to_equal(1);
    ut.expect(doc_br.cpf_valido('111.444.777-35')).to_equal(1);
  end;

  procedure cpf_invalido is
  begin
    ut.expect(doc_br.cpf_valido('529.982.247-26')).to_equal(0);
    ut.expect(doc_br.cpf_valido('111.111.111-11')).to_equal(0);
    ut.expect(doc_br.cpf_valido('52998224A25')).to_equal(0);
    ut.expect(doc_br.cpf_valido('5299822472')).to_equal(0);
    ut.expect(doc_br.cpf_valido(null)).to_equal(0);
  end;

  procedure cpf_dv_e_formatacao is
  begin
    ut.expect(doc_br.cpf_dv('529982247')).to_equal('25');
    ut.expect(doc_br.cpf_formatado('52998224725')).to_equal('529.982.247-25');
  end;

end ut_doc_br;
/
