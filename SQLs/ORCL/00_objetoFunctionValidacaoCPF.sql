-------------------------------------------------------------
--Versão:	000
--Interno:	000
-------------------------------------------------------------
--Assunto...: Validação de CPF
--Banco.....: Oracle
--Analista..: Ricardo Aguirra
--Data......: 
--Finalidade: Criação de Objeto para fazer a validação do CPF no BD Oracle 
-------------------------------------------------------------
--CREATE
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION HR.VALIDACPF (VCPF VARCHAR)--INFORMAR CPF SEM PONTOS
RETURN VARCHAR
IS
  v_cpf varchar2(11);
  v_digitos_iguais boolean := true;
  v_compare char(1);
  v_digito number;
  v_soma number := 0;
  v_numero number;
  vVerfiricador number;
BEGIN
  v_cpf := VCPF;

  --------- TESTANDO A QUANTIDADE DE CARACTRES ----------------
  if length(v_cpf) <> 11
  then
    RETURN 'O CPF ESTA EM DESACORDO...FAVOR VERIFICAR!!!!';
  end if;
  ---------- TESTANDO DIITOS IGUAIS --------------------------
  for i in 2..11
  loop
    if i = 2 
    then
     v_compare := substr(v_cpf,1,1);
    end if;
    
    if substr(v_cpf,i,1) <> v_compare
    then
      v_digitos_iguais := FALSE;
    end if;
  end loop;
  
  if v_digitos_iguais 
  then
    RETURN 'CPF INVALIDO! OS DIGITOS NAO PODEM SER IQUAIS !!!';
  end if;
  --------------------- FIM DE TESTE DE DIGITOS IGUAIS --------------------------
  --------------- TESTAR O PRIMEIRO DIGITO VERIFICADOR --------------------------
  v_numero := 10;
  for i in 1..9
  loop
    v_digito := to_number(substr(v_cpf,i,1));
    v_soma := v_soma + (v_numero * v_digito);
    v_numero := v_numero -1;
  end loop;
  
  vVerfiricador:= mod(v_soma*10,11);
    
  if to_number(substr(vVerfiricador, length(vVerfiricador),1)) <> to_number(substr(v_cpf,10,1)) then
    RETURN 'CPF INVALIDO!!! ...ERRO AO VERIFICAR O PRIMEIRO DIGITO VERIFICADOR!!!';
  end if;
  ---------------- FIM DE TESTE DO PRIMEIRO DIGITO VERIFICADOR ------------------
  ---------------- INICIO DE TESTE DO SEGUNDO DIGITO VERIFICADOR -----------------
  v_numero := 11;
  v_soma := 0;
  
  for i in 1..10
  loop
    v_digito := to_number(substr(v_cpf,i,1));
    v_soma := v_soma + (v_numero * v_digito);
    v_numero := v_numero -1;
  end loop;
  
  vVerfiricador:= mod(v_soma*10,11);
  
   if (to_number(substr(vVerfiricador, length(vVerfiricador),1)) <> to_number(substr(v_cpf,11,1)) )
  then
    return 'CPF INVALIDO!!! ...ERRO AO VERIFICAR O SEGUNDO DIGITO VERIFICADOR!!!';
  end if;
  ---------------- FIM DE TESTE DO SEGUNDO DIGITO VERIFICADOR ------------------
  RETURN 'CPF DE NUMERO '||v_cpf ||' VALIDO!!!';
end;
/