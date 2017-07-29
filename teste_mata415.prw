#Include 'totvs.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.ch'

//User Function teste_mata415()
User Function teste_orc()
Local cCodOrc    := ''
Local aCabec     := {}
Local aLinha     := {}
Local aItens     := {}

Private lMsErroAuto    := .F.

cCodOrc := GetNewCod() // Numero do Orcamento

AAdd(aCabec ,{"CJ_NUM"      ,cCodOrc                                    ,Nil})
AAdd(aCabec ,{"CJ_CLIENTE"  ,'001296'       ,Nil})
AAdd(aCabec ,{"CJ_LOJA"     ,'06'          ,Nil})
AAdd(aCabec ,{"CJ_EMISSAO"  ,dDataBase                                  ,Nil})
AAdd(aCabec ,{"CJ_CONDPAG"  ,'024'              ,Nil})
AAdd(aCabec ,{"CJ_VEND1"    ,'000002'             ,Nil})
AAdd(aCabec ,{"CJ_TABELA"   ,'003'         ,Nil})
AAdd(aCabec ,{"CJ_TPFRETE"  ,'C'            ,Nil})
AAdd(aCabec ,{"CJ_TRANSP"   ,''       ,Nil})

aLinha := {}
AAdd(aLinha ,{"CK_ITEM"   ,'01'               ,Nil})
AAdd(aLinha ,{"CK_PRODUTO",'7899658705190'             ,Nil})
AAdd(aLinha ,{"CK_QTDVEN" ,45750              ,Nil})
AAdd(aLinha ,{"CK_UNSVEN" ,150             ,Nil})
AAdd(aLinha ,{"CK_PRCVEN" ,0.50        ,Nil})
AAdd(aLinha ,{"CK_VALOR"  ,22875              ,Nil})
AAdd(aLinha ,{"CK_OPER"   ,'01'                                           ,Nil})
AAdd(aLinha ,{"CK_ENTPROG",'N'        ,Nil})
AAdd(aLinha ,{"CK_ENTREG" ,CtoD('06/10/2017') ,Nil})
AAdd(aLinha ,{"CK_OBS"    ,''         ,Nil})
AAdd(aLinha ,{"CK_PRCUNIT",0.50         ,Nil})

Aadd(aItens, aLinha)

aLinha := {}
AAdd(aLinha ,{"CK_ITEM"   ,'02'               ,Nil})
AAdd(aLinha ,{"CK_PRODUTO",'7899658705213'             ,Nil})
AAdd(aLinha ,{"CK_QTDVEN" ,30000              ,Nil})
AAdd(aLinha ,{"CK_UNSVEN" ,30            ,Nil})
AAdd(aLinha ,{"CK_PRCVEN" ,0.50        ,Nil})
AAdd(aLinha ,{"CK_VALOR"  ,15000              ,Nil})
AAdd(aLinha ,{"CK_OPER"   ,'01'                                           ,Nil})
AAdd(aLinha ,{"CK_ENTPROG",'N'        ,Nil})
AAdd(aLinha ,{"CK_ENTREG" ,CtoD('06/10/2017') ,Nil})
AAdd(aLinha ,{"CK_OBS"    ,''         ,Nil})
AAdd(aLinha ,{"CK_PRCUNIT",0.50         ,Nil})

Aadd(aItens, aLinha)


MSExecAuto({ |X, Y, Z| MATA415(X, Y, Z) }, aCabec, aItens, 3)

If lMsErroAuto
	RollBackSX8()
	MostraErro()
Else
	ConfirmSX8()
	MsgInfo('Gerado com sucesso ' + cCodOrc)
EndIf

Return Nil

//-------------------------------------------------------------
/*/{Protheus.doc} GetNewCod
Retorna o próximo código livre do SCJ

@author Felipe Toledo
@since 12/07/2017
@type function
/*/
//-------------------------------------------------------------
Static Function GetNewCod()

Local cCod  := GetSX8Num("SCJ", "CJ_NUM")
Local aArea := GetArea()

SCJ->( DbSetOrder(1) ) // CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA

While SCJ->( DbSeek( xFilial("SCJ") + cCod ) )
	cCod := GetSX8Num("SCJ", "CJ_NUM")
EndDo

RestArea(aArea)

Return(cCod)

//-------------------------------------------------------------------
User Function AJUSTADB()
    RpcClearEnv()
    RpcSetType(3)
    RpcSetEnv("99","01")
    DbSelectArea("SM0")
    SM0->(DbSeek("9901"))

    DbSelectArea("SX2")
    SX2->(DbGoTop())
    While !SX2->(EoF())
        cTabela := AllTrim(SX2->X2_ARQUIVO)
        cAlias  := AllTrim(SX2->X2_CHAVE)
        If TcCanOpen(cTabela)
            TcRefresh(cTabela)
            DbSelectArea(cAlias)
            If (cAlias)->(EoF()) .AND. (cAlias)->(BoF())
                If !Empty(Select("QRY"))
                    DbSelectArea("QRY")
                    DbCloseArea("QRY")
                EndIf
                sql :=  "SELECT COUNT(*) NREGS FROM " + cTabela
                TCQuery sql NEW ALIAS "QRY"
                DbSelectArea("QRY")
                If QRY->NREGS = 0
                    If !Empty(Select(cAlias))
                        DbSelectArea(cAlias)
                        DbCloseArea(cAlias)
                    EndIf
                    If !Empty(Select("QRY"))
                        DbSelectArea("QRY")
                        DbCloseArea("QRY")
                    EndIf
                    ConOut("Apagar tabela "+cTabela)
                    lOk := TcDelFile(cTabela)
                    If !lOk
                        ConOut("Falha ao apagar "+cTabela+" : "+ TcSqlError())
                    EndIf
                Else
                	cPrefixo := If(Left(cTabela,1)=='S',Right(cTabela,2),cTabela)
                	
                	cFieldFil := cPrefixo+'_FILIAL'
                	
                	If (cTabela)->(FieldPos(cFieldFil)) > 0
                		
                		sqlExec :=  "DELETE FROM " + cTabela + " WHERE "+cFieldFil+" = '0101'"
	                	TCSQLExec(sqlExec)
	                	
	                	sqlUpd :=  "UPDATE " + cTabela + " SET "+cFieldFil+" = '01' WHERE "+cFieldFil+" = '0201'"
	                	TCSQLExec(sqlUpd)
	                EndIf
	                
	                cFieldFil := cPrefixo+'_FILORIG'
	                If (cTabela)->(FieldPos(cFieldFil)) > 0
	                	sqlUpd :=  "UPDATE " + cTabela + " SET "+cFieldFil+" = '01' WHERE "+cFieldFil+" = '0201'"
	                	TCSQLExec(sqlUpd)
	                EndIf
	                
	                cFieldFil := cPrefixo+'_FILORI'
	                If (cTabela)->(FieldPos(cFieldFil)) > 0
	                	sqlUpd :=  "UPDATE " + cTabela + " SET "+cFieldFil+" = '01' WHERE "+cFieldFil+" = '0201'"
	                	TCSQLExec(sqlUpd)
	                EndIf
	                
	                cFieldFil := cPrefixo+'MSFIL'
	                If (cTabela)->(FieldPos(cFieldFil)) > 0
	                	sqlUpd :=  "UPDATE " + cTabela + " SET "+cFieldFil+" = '01' WHERE "+cFieldFil+" = '0201'"
	                	TCSQLExec(sqlUpd)
	                EndIf

                EndIf
            EndIf
            If !Empty(Select(cAlias))
                DbSelectArea(cAlias)
                DbCloseArea(cAlias)
            EndIf
        EndIf
        SX2->(DbSkip())
    EndDo
    
    ConOut("Termino da Rotina")
Return