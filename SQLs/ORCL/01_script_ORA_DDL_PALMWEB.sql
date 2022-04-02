-------------------------------------------------------------
--Versão:	0002
--Interno:	0004
-------------------------------------------------------------
--Assunto...: PALM WEB
--Banco.....: Oracle
--Analista..: Ricardo Aguirra
--Data......: 27/10/2021
--Finalidade: Criação de Objeto para otimizar o vínculo dos usuários no PalmWeb
-------------------------------------------------------------
--CREATE
-------------------------------------------------------------
Set sqlblanklines On;

ALTER SESSION SET CURRENT_SCHEMA = TASY
/

CREATE OR REPLACE PROCEDURE SPDM_USER_PALMWEB_UNI(
       P_UNI TASY.ESTABELECIMENTO.CD_ESTABELECIMENTO%TYPE
    ,P_RETURN OUT VARCHAR2
       )
-----------------------------------------------------------------------------------
--
-- Observacao.: Esta procedure visa vincular os usu?rios com vinculos aos grupos
-- (ENFERMAGEM / TECENFERMAGEM / AUXILIAREFERMAGEM) para ter acesso ao Beira Leito
-- habilitando a fun??o de PALM WEB.
--
-----------------------------------------------------------------------------------
AS

  /*
    CONSULTA USUARIO ATIVO NA UNIDADE UTILIZANDO OS TIPOS DE EVOLU??O 3, 13 E 20
    3   - ENFERMEIRO
    13  - TECENFERMAGEM
    20  - TECENFERMAGEM/AUXILIAREFERMAGEM
  */
  CURSOR C_USER (P_UNIDADE NUMBER)
    IS (SELECT *
          FROM TASY.USUARIO
         WHERE IE_TIPO_EVOLUCAO IN ('3', '13', '20')
           AND CD_ESTABELECIMENTO = P_UNIDADE
           AND IE_SITUACAO = 'A'
    );

  /*
    CONSULTA PARAMETRO X USUARIO
    VERIFICA USUARIO EXISTE PARA USO DO PALM WEB POR UNIDADE
    FUN??O -> 88
    SEQUENCIA -> 1
  */
  CURSOR C_FUNC (P_USER VARCHAR2)
      IS (SELECT COUNT(*) CONTA
            FROM TASY.FUNCAO_PARAM_USUARIO
           WHERE CD_FUNCAO = 88
             AND NR_SEQUENCIA = 1
             AND NM_USUARIO_PARAM = P_USER
      );

--VARIAVEIS DE CONTROLE
  regIns number;
  regAtu number:=0;

BEGIN
  FOR R0 IN C_USER(P_UNI)
    LOOP
      FOR R1 IN C_FUNC(R0.NM_USUARIO)--, R0.CD_ESTABELECIMENTO)
       LOOP
        IF (R1.CONTA = 0) THEN
          IF (R0.IE_TIPO_EVOLUCAO = 3) THEN
            /*INCLUS?O DE PROFISSIONAL
        ? ENFERMAGEM

        PERFIL -> (SELECT CD_PERFIL CD,DS_PERFIL DS FROM TASY.PERFIL WHERE IE_SITUACAO = 'A' ORDER BY DS_PERFIL)
        2703  SPDM - ENFERMARIA - ENFERMEIRO_HTML
      */
              INSERT INTO TASY.FUNCAO_PARAM_USUARIO ( CD_FUNCAO
                          , NR_SEQUENCIA
                          , NM_USUARIO_PARAM
                          , DT_ATUALIZACAO
                          , NM_USUARIO
                          , VL_PARAMETRO
                          , DS_OBSERVACAO
                          , CD_ESTABELECIMENTO)
        VALUES ( '88'
               , '1'
           , R0.NM_USUARIO
           , SYSDATE
           , 'ADMTASY'
           , '2703'
           , 'INSERIDO VIA SCRIPT'
           , R0.CD_ESTABELECIMENTO);

      regIns:=sql%rowcount;
      regAtu:= regAtu + regIns;

      COMMIT;

          ELSIF (R0.IE_TIPO_EVOLUCAO = 13 OR R0.IE_TIPO_EVOLUCAO = 20 ) THEN
            /*INCLUS?O DE PROFISSIONAL
        ? TECNICO ENFERMAGEM
        ? TECNICO FERMAGEM/AUXILIAR EFERMAGEM

        PERFIL -> (SELECT CD_PERFIL CD,DS_PERFIL DS FROM TASY.PERFIL WHERE IE_SITUACAO = 'A' ORDER BY DS_PERFIL)
        2724  SPDM - ENFERMARIA - TECNICO_HTML
      */
        INSERT INTO TASY.FUNCAO_PARAM_USUARIO ( CD_FUNCAO
                          , NR_SEQUENCIA
                          , NM_USUARIO_PARAM
                          , DT_ATUALIZACAO
                          , NM_USUARIO
                          , VL_PARAMETRO
                          , DS_OBSERVACAO
                          , CD_ESTABELECIMENTO)
        VALUES ( '88'
           , '1'
           , R0.NM_USUARIO
           , SYSDATE
           , 'ADMTASY'
           , '2724'
           , 'INSERIDO VIA SCRIPT'
           , R0.CD_ESTABELECIMENTO);

      regIns:=sql%rowcount;
      regAtu:= regAtu + regIns;

      COMMIT;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  P_RETURN:= regAtu || ' REGISTRSO INSERIDOS.';
END;
/