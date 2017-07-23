#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTVALIDAQUANT
Serviço REST valida a quantidade digitada no orçamento de venda

@author Felipe Toledo
@since 11/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTVALIDAQUANT DESCRIPTION "Serviço REST de validação da quantidade digitada no orçamento de venda para o portal de vendas"

WSDATA CCODPRO      As String // Codigo do produto
WSDATA NQUANT1UM    As Float  // Quantidade vendida na primeira unidade de medida

WSMETHOD POST DESCRIPTION "Valida a quantidade digitada do preço de venda e retorna a quantidade convertida na segunda unidade de medida" WSSYNTAX "/PRTVALIDAQUANT "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Processa as informações e retorna o json
@author Felipe Toledo
@since 11/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSRECEIVE CCODPRO, NQUANT1UM WSSERVICE PRTVALIDAQUANT
Local oObjResp   := Nil
Local cJson      := ''
Local oObjResp   := Nil
Local cCodPro    := PadR(AllTrim(Self:CCODPRO),TamSX3('B1_COD')[1])
Local nQtde1UM   := If(Empty(Self:NQUANT1UM),0,Self:NQUANT1UM)
Local nQtde2UM   := 0
Local lRet       := .T.

// Valida produto
If lRet
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	If Empty(cCodPro) .Or. !SB1->(MsSeek(xFilial('SB1')+cCodPro))
		SetRestFault(400, "produto invalido")
		lRet := .F.
	EndIf
EndIf

If lRet
	// Quantidade minima para venda
	If nQtde1UM < SB1->B1_LOTVEN
		SetRestFault(400, "quantidade inferior ao lote minima de venda: Lote Minimo: " + Alltrim(STR(SB1->B1_LOTVEN,20,6)))
		lRet := .F.
	EndIf
EndIf

If lRet
	// Converte para a segunda unidade de medida
	nQtde2UM := ConvUm( cCodPro, nQtde1UM, 0, 2 )

	If nQtde2UM > Int(nQtde2UM)
		SetRestFault(400, "quantidade nao e multipla na 2a.UN do produto: " + Alltrim(STR(nQtde2UM,20,6)))
		lRet := .F.
	EndIf
	
	// Objeto que será serializado
	oObjResp := PrtValidaQuant():New(nQtde2UM, SB1->B1_SEGUM)
EndIf

// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)