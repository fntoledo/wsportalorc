#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTTABELAPRECO
Serviço REST de tabela de preço para o portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTTABELAPRECO DESCRIPTION "Serviço REST de tabela de preço para o portal de vendas"

WSDATA CVENDEDOR  As String
WSDATA CFRETE     As String

WSMETHOD GET DESCRIPTION "Retorna informações da tabela de preço de venda para o portal de vendas" WSSYNTAX "/PRTTABELAPRECO "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CVENDEDOR, CFRETE WSSERVICE PRTTABELAPRECO
Local oObjResp   := Nil
Local cJson      := ''
Local oObjResp   := Nil
Local cVendedor  := PadR(AllTrim(Self:CVENDEDOR),TamSX3('A3_COD')[1])
Local cFrete     := Upper(Left(Alltrim(If(Empty(Self:CFRETE),'',Self:CFRETE)),1))
Local lRet       := .T.

// Valida vendedor
SA3->(DbSetOrder(1)) //A3_FILIAL+A3_COD
If Empty(cVendedor) .Or. !SA3->(MsSeek(xFilial('SA3')+cVendedor))
	SetRestFault(400, "vendedor invalida")
	lRet := .F.
EndIf

// Valida tipo do frete
If lRet
	If !(AllTrim(cFrete) $ 'C#F') // C-CIF;F-FOB
		SetRestFault(400, "tipo de frete invalido")
		lRet := .F.
	EndIf
EndIf

If lRet
	If cFrete == 'C' // CIF
		cCodTab := SA3->A3_TABELA
	ElseIf cFrete == 'F' // FOB
		cCodTab := SA3->A3_TABELAF
	EndIf
EndIf

If lRet .And. Empty(cCodTab)
	SetRestFault(400, "tabela de preco nao informada no cadastro do vendedor")
	lRet := .F.
EndIf

If lRet	
	// Objeto que será serializado
	oObjResp := PrtTabelaPreco():New(cCodTab)
EndIf

// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)