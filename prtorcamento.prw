#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTORCAMENTO
Serviço REST de orcamento de venda para o portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTORCAMENTO DESCRIPTION "Serviço REST de orcamento de venda para o portal de vendas"

WSMETHOD GET    DESCRIPTION "Retorna informações do orcamento de venda para o portal de vendas" WSSYNTAX "/PRTORCAMENTO/{codigo_orcamento} "
WSMETHOD POST   DESCRIPTION "Inclusão do orçamento de venda vindo do portal de vendas"          WSSYNTAX "/PRTORCAMENTO "
WSMETHOD PUT    DESCRIPTION "Alteração do orçamento de venda vindo do portal de vendas"         WSSYNTAX "/PRTORCAMENTO "
WSMETHOD DELETE DESCRIPTION "Exclusão do orçamento de venda vindo do portal de vendas"          WSSYNTAX "/PRTORCAMENTO/{codigo_orcamento} "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSSERVICE PRTORCAMENTO
Local cJson      := ''
Local oObjResp   := PrtOrcamento():New() // --> Objeto que será serializado
Local cNumOrc    := ''
Local aBoxStat   := RetSx3Box( Posicione('SX3', 2, 'CJ_STATUS', 'X3CBox()' ),,, Len(SCJ->CJ_STATUS) )
Local cStatus    := ''
Local aBoxtTpFr  := RetSx3Box( Posicione('SX3', 2, 'CJ_TPFRETE', 'X3CBox()' ),,, Len(SCJ->CJ_TPFRETE) )
Local cTpFrete   := ''
Local cAliasQry  := GetNextAlias()
Local lRet       := .T.

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[1])
	cNumOrc := PadR(AllTrim(::aUrlParms[1]),TamSX3('CJ_NUM')[1]) // Recebe o numero do orcamento
Else
	SetRestFault(400, "Codigo do orcamento nao informado nos parametros")
	lRet := .F.
EndIf

If lRet
	SCJ->(DbSetOrder(1)) // CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
	If SCJ->(MsSeek(xFilial('SCJ')+cNumOrc))
		SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
		SA1->(MsSeek(xFilial('SA1')+SCJ->(CJ_CLIENTE+CJ_LOJA)))
	
		cStatus  := SCJ->CJ_STATUS +"-"+AllTrim(  aBoxStat[ Ascan( aBoxStat,  { |x| x[ 2 ] == SCJ->CJ_STATUS}  ), 3 ])
		cTpFrete := SCJ->CJ_TPFRETE+"-"+AllTrim( aBoxtTpFr[ Ascan( aBoxtTpFr, { |x| x[ 2 ] == SCJ->CJ_TPFRETE} ), 3 ])

		// Objeto que será serializado
		oObjResp:AddCab( PrtCabOrcamento():New(SCJ->CJ_NUM,;
		                             SCJ->CJ_EMISSAO,;
		                             SCJ->CJ_CLIENTE,;
		                             SCJ->CJ_LOJA,;
		                             SA1->A1_NOME,;
		                             SA1->A1_CGC,;
		                             cStatus,;
		                             SCJ->CJ_CONDPAG,;
		                             SCJ->CJ_TABELA,;
		                             SCJ->CJ_VEND1,;
		                             cTpFrete,;
		                             SCJ->CJ_TRANSP) )

		// Seleciona Itens
		BeginSql Alias cAliasQry
			COLUMN CK_ENTREG AS DATE
			
			SELECT CK_ITEM, CK_PRODUTO, CK_DESCRI, CK_UM, B1_SEGUM, CK_QTDVEN, CK_UNSVEN, CK_PRCVEN, CK_VALOR, CK_ENTPROG, CK_ENTREG, CK_OBS
			  FROM %Table:SCK% SCK
			 INNER
			  JOIN %Table:SB1% SB1
			    ON SB1.B1_FILIAL = %xFilial:SB1%
			   AND SB1.B1_COD    = SCK.CK_PRODUTO
			   AND SB1.%notDel%
			 WHERE SCK.CK_FILIAL = %xFilial:SCK%
			   AND SCK.CK_NUM    = %Exp:SCJ->CJ_NUM%
			   AND SCK.%notDel%
			 ORDER
			    BY CK_ITEM
		EndSql
		
		If (cAliasQry)->(! Eof())
			//Cria um objeto da classe produtos para fazer a serialização na função FWJSONSerialize
			(cAliasQry)->(DbEval({||;
			oObjResp:AddItem(PrtItensOrcamento():New( CK_ITEM,;
			                                          CK_PRODUTO,;
			                                          CK_DESCRI,;
			                                          CK_UM,;
			                                          B1_SEGUM,;
			                                          CK_QTDVEN,;
			                                          CK_UNSVEN,;
			                                          CK_PRCVEN,;
			                                          CK_VALOR,;
			                                          CK_ENTPROG,;
			                                          CK_ENTREG,;
			                                          CK_OBS) );
			}))

		Else
			SetRestFault(400, "Orcamento nao possui itens")
			lRet := .F.			
		EndIf
		
		(cAliasQry)->(DbCloseArea())
		
	Else
		SetRestFault(400, "Orcamento nao localizado")
		lRet := .F.
	EndIf
EndIf

// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Serviço REST de Inclusão do Orçamento de Venda

@author Felipe Toledo
@since 12/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE PRTORCAMENTO
Local cJSonReq 	 := Self:GetContent() // Pega a string do JSON de requisicao
Local oParseJSON := Nil 
Local cJson      := ''
Local cNumOrc    := ''
Local aCabec     := {}
Local aLinha     := {}
Local aItens     := {}
Local lRet       := .T.

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

// necessário declarar. O WebService não esta iniciando a variavel publica __LOCALDRIVE
__LOCALDRIVE := "DBFCDX"

// --> Deserializa a string JSON
FWJsonDeserialize(cJSonReq, @oParseJSON)

cNumOrc := GetNewCod() // Numero do Orcamento

AAdd(aCabec ,{"CJ_NUM"      ,cNumOrc                                    ,Nil})
AAdd(aCabec ,{"CJ_CLIENTE"  ,oParseJSON:CABECALHO:cCodigoCliente        ,Nil})
AAdd(aCabec ,{"CJ_LOJA"     ,oParseJSON:CABECALHO:cLojaCliente          ,Nil})
AAdd(aCabec ,{"CJ_EMISSAO"  ,dDataBase                                  ,Nil})
AAdd(aCabec ,{"CJ_CONDPAG"  ,oParseJSON:CABECALHO:cCondPag              ,Nil})
AAdd(aCabec ,{"CJ_VEND1"    ,oParseJSON:CABECALHO:cVendedor             ,Nil})
AAdd(aCabec ,{"CJ_TABELA"   ,oParseJSON:CABECALHO:cTabelaPreco          ,Nil})
AAdd(aCabec ,{"CJ_TPFRETE"  ,oParseJSON:CABECALHO:cTipoFrete            ,Nil})
AAdd(aCabec ,{"CJ_TRANSP"   ,oParseJSON:CABECALHO:cTransportadora       ,Nil})
AAdd(aCabec ,{"CJ_PORTAL"   ,'S'                                        ,Nil})

For nCntFor := 1 To Len(oParseJSON:ITENS)
	aLinha := {}
	AAdd(aLinha ,{"CK_ITEM"   ,oParseJSON:ITENS[nCntFor]:cItem                ,Nil})
	AAdd(aLinha ,{"CK_PRODUTO",oParseJSON:ITENS[nCntFor]:cProduto             ,Nil})
	AAdd(aLinha ,{"CK_QTDVEN" ,oParseJSON:ITENS[nCntFor]:nQtdVen              ,Nil})
	AAdd(aLinha ,{"CK_UNSVEN" ,oParseJSON:ITENS[nCntFor]:nQtdVen2             ,Nil})
	AAdd(aLinha ,{"CK_PRCVEN" ,oParseJSON:ITENS[nCntFor]:nPrcUnitario         ,Nil})
	AAdd(aLinha ,{"CK_VALOR"  ,oParseJSON:ITENS[nCntFor]:nValor               ,Nil})
	AAdd(aLinha ,{"CK_OPER"   ,'01'                                           ,Nil})
	AAdd(aLinha ,{"CK_ENTPROG",oParseJSON:ITENS[nCntFor]:cEntregaProg         ,Nil})
	AAdd(aLinha ,{"CK_ENTREG" ,CtoD(oParseJSON:ITENS[nCntFor]:dDtPrevEntrega) ,Nil})
	AAdd(aLinha ,{"CK_OBS"    ,oParseJSON:ITENS[nCntFor]:cObservacao          ,Nil})
	AAdd(aLinha ,{"CK_PRCUNIT",oParseJSON:ITENS[nCntFor]:nPrcUnitario         ,Nil})
	
	Aadd(aItens, aLinha)
Next nCntFor

SA3->(DbSetOrder(1)) // Set ordem para evitar erro na validação do campo CJ_VEND1

MSExecAuto({ |X, Y, Z| MATA415(X, Y, Z) }, aCabec, aItens, 3)

If lMsErroAuto
	RollBackSX8()
	aErro := GetAutoGRLog()

	cErro := ""
	For nX := 1 To Len(aErro)
		cErro += aErro[nX] + Chr(13)+Chr(10)
	Next nX

	cErro := EncodeUtf8(cErro)

	SetRestFault(400, cErro)
	lRet := .F.
Else
	//ConfirmSX8()
	// Retorno
	cJson := "{ORCAMENTO: '"+cNumOrc+"'}"
EndIf

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT
Serviço REST de Alteração do Orçamento de Venda

@author Felipe Toledo
@since 12/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE PRTORCAMENTO
Local cJSonReq 	 := Self:GetContent() // Pega a string do JSON de requisicao
Local oParseJSON := Nil 
Local cJson      := ''
Local cNumOrc    := ''
Local aCabec     := {}
Local aLinha     := {}
Local aItens     := {}
Local cStrIn     := ''
Local cAliasQry  := GetNextAlias()
Local aBoxStat   := RetSx3Box( Posicione('SX3', 2, 'CJ_STATUS', 'X3CBox()' ),,, Len(SCJ->CJ_STATUS) )
Local cStatus    := ''
Local lRet       := .T.

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

// necessário declarar. O WebService não esta iniciando a variavel publica __LOCALDRIVE
__LOCALDRIVE := "DBFCDX"

// --> Deserializa a string JSON
FWJsonDeserialize(cJSonReq, @oParseJSON)

cNumOrc := PadR(AllTrim(oParseJSON:CABECALHO:cCodigo),TamSX3('CJ_NUM')[1]) // Recebe o numero do orcamento

SCJ->(DbSetOrder(1)) // CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
If SCJ->(MsSeek(xFilial('SCJ')+cNumOrc))
	If SCJ->CJ_STATUS <> 'A'
		cStatus  := SCJ->CJ_STATUS +"-"+AllTrim(  aBoxStat[ Ascan( aBoxStat,  { |x| x[ 2 ] == SCJ->CJ_STATUS}  ), 3 ])
		SetRestFault(400, "Orcamento no status: "+cStatus+" nao pode ser alterado")
		lRet := .F.
	EndIf
Else
	SetRestFault(400, "Orcamento nao localizado")
	lRet := .F.
EndIf

If lRet
	AAdd(aCabec ,{"CJ_NUM"      ,cNumOrc                                    ,Nil})
	AAdd(aCabec ,{"CJ_CLIENTE"  ,oParseJSON:CABECALHO:cCodigoCliente        ,Nil})
	AAdd(aCabec ,{"CJ_LOJA"     ,oParseJSON:CABECALHO:cLojaCliente          ,Nil})
	AAdd(aCabec ,{"CJ_EMISSAO"  ,dDataBase                                  ,Nil})
	AAdd(aCabec ,{"CJ_CONDPAG"  ,oParseJSON:CABECALHO:cCondPag              ,Nil})
	AAdd(aCabec ,{"CJ_VEND1"    ,oParseJSON:CABECALHO:cVendedor             ,Nil})
	AAdd(aCabec ,{"CJ_TABELA"   ,oParseJSON:CABECALHO:cTabelaPreco          ,Nil})
	AAdd(aCabec ,{"CJ_TPFRETE"  ,oParseJSON:CABECALHO:cTipoFrete            ,Nil})
	AAdd(aCabec ,{"CJ_TRANSP"   ,oParseJSON:CABECALHO:cTransportadora       ,Nil})
	AAdd(aCabec ,{"CJ_PORTAL"   ,'S'                                        ,Nil})
	
	SCK->(DbSetOrder(1)) // CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
	For nCntFor := 1 To Len(oParseJSON:ITENS)
		cItem := PadR(AllTrim(oParseJSON:ITENS[nCntFor]:cItem),TamSX3('CK_ITEM')[1]) // Item do Orçamento
		
		cStrIn += "'"+cItem+"',"

		aLinha := {}
		If SCK->(MsSeek(xFilial('SCK')+cNumOrc+cItem))
			Aadd(aLinha,{"LINPOS", "CK_ITEM" ,cItem})
		EndIf
		AAdd(aLinha ,{"CK_ITEM"   ,oParseJSON:ITENS[nCntFor]:cItem                ,Nil})
		AAdd(aLinha ,{"CK_PRODUTO",oParseJSON:ITENS[nCntFor]:cProduto             ,Nil})
		AAdd(aLinha ,{"CK_QTDVEN" ,oParseJSON:ITENS[nCntFor]:nQtdVen              ,Nil})
		AAdd(aLinha ,{"CK_UNSVEN" ,oParseJSON:ITENS[nCntFor]:nQtdVen2             ,Nil})
		AAdd(aLinha ,{"CK_PRCVEN" ,oParseJSON:ITENS[nCntFor]:nPrcUnitario         ,Nil})
		AAdd(aLinha ,{"CK_VALOR"  ,oParseJSON:ITENS[nCntFor]:nValor               ,Nil})
		AAdd(aLinha ,{"CK_OPER"   ,'01'                                           ,Nil})
		AAdd(aLinha ,{"CK_ENTPROG",oParseJSON:ITENS[nCntFor]:cEntregaProg         ,Nil})
		AAdd(aLinha ,{"CK_ENTREG" ,CtoD(oParseJSON:ITENS[nCntFor]:dDtPrevEntrega) ,Nil})
		AAdd(aLinha ,{"CK_OBS"    ,oParseJSON:ITENS[nCntFor]:cObservacao          ,Nil})
		AAdd(aLinha ,{"CK_PRCUNIT",oParseJSON:ITENS[nCntFor]:nPrcUnitario         ,Nil})
		Aadd(aLinha,{"AUTDELETA"  ,"N"                                            ,Nil})
		
		Aadd(aItens, aLinha)
	Next nCntFor
	
	// Retira a ultima virgula
	cStrIn := Left(cStrIn,Len(cStrIn)-1)
	cStrIn := '%'+cStrIn+'%'
	
	// Valida se algum item foi excluido
	BeginSql Alias cAliasQry
		SELECT CK_ITEM
		 FROM %Table:SCK% SCK
		WHERE SCK.CK_FILIAL = %xFilial:SCK%
		  AND SCK.CK_NUM    = %Exp:cNumOrc%
		  AND SCK.CK_ITEM   NOT IN (%Exp:cStrIn%)
		  AND SCK.%notDel%
	EndSql
	
	// Adiciona no vetor de itens a linhas que seram deletadas
	Do While (cAliasQry)->(! Eof())
		aLinha := {}
		Aadd(aLinha,{"LINPOS"    ,"CK_ITEM" ,(cAliasQry)->CK_ITEM})
		Aadd(aLinha,{"AUTDELETA" ,"S"       ,Nil })
		Aadd(aItens, aLinha)
	
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())
	
	SA3->(DbSetOrder(1)) // Set ordem para evitar erro na validação do campo CJ_VEND1
	
	MSExecAuto({ |X, Y, Z| MATA415(X, Y, Z) }, aCabec, aItens, 4)
	
	If lMsErroAuto
		aErro := GetAutoGRLog()
	
		cErro := ""
		For nX := 1 To Len(aErro)
			cErro += aErro[nX] + Chr(13)+Chr(10)
		Next nX
	
		cErro := EncodeUtf8(cErro)
		
		SetRestFault(400, cErro)
		lRet := .F.
	Else
		// Retorno
		cJson := "{ORCAMENTO: '"+cNumOrc+"', ALTERACAO: 'OK'}"
	EndIf
EndIf

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE
Exclusao do Orçamento de Venda

@author Felipe Toledo
@since 15/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE WSSERVICE PRTORCAMENTO
Local cJson      := ''
Local cNumOrc    := ''
Local aBoxStat   := RetSx3Box( Posicione('SX3', 2, 'CJ_STATUS', 'X3CBox()' ),,, Len(SCJ->CJ_STATUS) )
Local cStatus    := ''
Local aCabec     := {}
Local aItens     := {}
Local lRet       := .T.

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

// necessário declarar. O WebService não esta iniciando a variavel publica __LOCALDRIVE
__LOCALDRIVE := "DBFCDX"

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[1])
	cNumOrc := PadR(AllTrim(::aUrlParms[1]),TamSX3('CJ_NUM')[1]) // Recebe o numero do orcamento
Else
	SetRestFault(400, "Codigo do orcamento nao informado nos parametros")
	lRet := .F.
EndIf

If lRet
	SCJ->(DbSetOrder(1)) // CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
	If SCJ->(MsSeek(xFilial('SCJ')+cNumOrc))
		
		If SCJ->CJ_STATUS <> 'A'
			cStatus  := SCJ->CJ_STATUS +"-"+AllTrim(  aBoxStat[ Ascan( aBoxStat,  { |x| x[ 2 ] == SCJ->CJ_STATUS}  ), 3 ])
			SetRestFault(400, "Orcamento no status: "+cStatus+" nao pode ser excluido")
			lRet := .F.
		EndIf
		
		If lRet 
			AAdd(aCabec ,{"CJ_NUM" ,cNumOrc, Nil})
			
			MSExecAuto({ |X, Y, Z| MATA415(X, Y, Z) }, aCabec, aItens, 5)

			If lMsErroAuto
				aErro := GetAutoGRLog()
			
				cErro := ""
				For nX := 1 To Len(aErro)
					cErro += aErro[nX] + Chr(13)+Chr(10)
				Next nX
				
				cErro := EncodeUtf8(cErro)
			
				SetRestFault(400, cErro)
				lRet := .F.
			Else
				cJson := "{ORCAMENTO: '"+cNumOrc+"', EXCLUSAO: 'OK'}"
			EndIf
		EndIf
	Else
		SetRestFault(400, "Orcamento nao localizado")
		lRet := .F.
	EndIf
EndIf

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)

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