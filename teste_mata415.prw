#Include 'totvs.ch'

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