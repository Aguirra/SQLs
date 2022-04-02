-------------------------------------------------------------
--Versão:	0001
--Interno:	0008
-------------------------------------------------------------
--Assunto...: Procedure evento DATASUS
--Banco.....: Oracle
--Analista..: Ricardo Aguirra
--Data......: 02/2022
--Finalidade: Criação do objeto para realizar a limpeza de dados apos a carga de CEP realizada
-------------------------------------------------------------
--CREATE PROCEDURE
-------------------------------------------------------------

Set sqlblanklines On;
SET SERVEROUTPUT ON;

ALTER SESSION SET CURRENT_SCHEMA = TASY
/

CREATE OR REPLACE PROCEDURE TASY."SPDM_LIMPA_CARACTER_SUS_CEP"
IS
    CURSOR C1 
        IS (SELECT ROWID, nr_seq_loc, CD_CEP, nr_sequencia, nm_logradouro, INSTR(nm_logradouro, ' até') posicao
              FROM tasy.CEP_LOG
             WHERE INSTR(UPPER(nm_logradouro), UPPER(' até')) > 1);
  
  posicaoPalavra        NUMBER:=0;
  caracter              VARCHAR2(10):=' ';
  vSql                  VARCHAR2(255):= '';
  vnr_seq_loc           CEP_LOG.nr_seq_loc%type;
  vCD_CEP               CEP_LOG.CD_CEP%type;
  vnr_sequencia         CEP_LOG.nr_sequencia%type;
  vnm_logradouro        CEP_LOG.nm_logradouro%type;
  
  /*HASH-416775697272613130303232303232*/
BEGIN
  FOR r1 IN c1
    LOOP
    posicaoPalavra:= r1.posicao -2;
    WHILE (SUBSTR(SUBSTR(r1.nm_logradouro,posicaoPalavra),1,1) <> ' ')
      LOOP
        posicaoPalavra:= posicaoPalavra - 1;
      END LOOP;
    posicaoPalavra:= posicaoPalavra - 1;
    
    vnr_seq_loc:= r1.nr_seq_loc;
    vCD_CEP:= r1.CD_CEP;
    vnr_sequencia:= r1.nr_sequencia;
    vnm_logradouro:= r1.nm_logradouro;
    
    vSql:=SUBSTR(r1.nm_logradouro,1,posicaoPalavra);

    UPDATE tasy.CEP_LOG SET nm_logradouro = vSql 
    WHERE nr_seq_loc = r1.nr_seq_loc AND CD_CEP = r1.CD_CEP AND nr_sequencia = r1.nr_sequencia;
    COMMIT;
   END LOOP;
      EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20001, SQLERRM 
								|| ' VerReg: (' 
								|| 'nr_seq_loc: ' 	 || vnr_seq_loc 
								|| ' CD_CEP: ' 	  	 || vCD_CEP 
								|| ' nr_sequencia: ' || vnr_sequencia ||')');
END;
/

CREATE OR REPLACE PUBLIC SYNONYM SPDM_LIMPA_CARACTER_SUS_CEP FOR TASY.SPDM_LIMPA_CARACTER_SUS_CEP 
/

GRANT EXECUTE ON TASY.SPDM_LIMPA_CARACTER_SUS_CEP to "USRTASY_LEITURA"
/
