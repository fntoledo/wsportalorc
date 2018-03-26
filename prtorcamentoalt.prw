#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTORCAMENTOALT
Serviço REST de orcamento de venda para o portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTORCAMENTOALT DESCRIPTION "Serviço REST de orcamento de venda para o portal de vendas"

WSDATA CCODUSR    As String // Usuário Portal

WSMETHOD PUT    DESCRIPTION "Alteração do orçamento de venda vindo do portal de vendas"         WSSYNTAX "/PRTORCAMENTOALT "

 END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT
Serviço REST de Alteração do Orçamento de Venda

@author Felipe Toledo
@since 12/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE PRTORCAMENTOALT
Local cJSonReq 	 := Self:GetContent() // Pega a string do JSON de requisicao
Local oParseJSON := Nil 
Local cJson      := ''
Local cNumOrc    := ''
Local aCabec     := {}
Local aLinha     := {}
Local aItens     := {}
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
	
	SCK->(DbSetOrder(1)) //CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
	SCK->(MsSeek(xFilial('SCK')+cNumOrc))
	Do While SCK->(!Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == xFilial('SCK')+cNumOrc
		aLinha := {}
		AAdd(aLinha ,{"CK_ITEM"   ,SCK->CK_ITEM                                   ,Nil})
		AAdd(aLinha ,{"CK_PRODUTO",SCK->CK_PRODUTO                                ,Nil})
		AAdd(aLinha ,{"CK_QTDVEN" ,SCK->CK_QTDVEN                                 ,Nil})
		AAdd(aLinha ,{"CK_UNSVEN" ,SCK->CK_UNSVEN                                 ,Nil})
		AAdd(aLinha ,{"CK_PRCVEN" ,SCK->CK_PRCVEN                                 ,Nil})
		AAdd(aLinha ,{"CK_VALOR"  ,SCK->CK_VALOR                                  ,Nil})
		AAdd(aLinha ,{"CK_OPER"   ,'01'                                           ,Nil})
		AAdd(aLinha ,{"CK_ENTPROG",SCK->CK_ENTPROG                                ,Nil})
		AAdd(aLinha ,{"CK_ENTREG" ,SCK->CK_ENTREG                                 ,Nil})
		AAdd(aLinha ,{"CK_OBS"    ,SCK->CK_OBS                                    ,Nil})
		//AAdd(aLinha ,{"CK_PRCUNIT",SCK->CK_PRCUNIT                                ,Nil})
		Aadd(aLinha,{"AUTDELETA"  ,"N"                                            ,Nil})
		Aadd(aItens, aLinha)
		SCK->(DbSkip())
	EndDo
	
	SCK->(DbSetOrder(1)) // CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
	For nCntFor := 1 To Len(oParseJSON:ITENS)
		cItem := PadR(AllTrim(oParseJSON:ITENS[nCntFor]:cItem),TamSX3('CK_ITEM')[1]) // Item do Orçamento

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
		cJson := '{"ORCAMENTO": "'+cNumOrc+'", "ALTERACAO": "OK"}'	
	EndIf
EndIf

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)