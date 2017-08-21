#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTVALIDAPRECO
Serviço REST de validação do preço unitário digitada no orçamento de
venda

@author Felipe Toledo
@since 11/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTVALIDAPRECO DESCRIPTION "Serviço REST de validação do preço unitário digitada no orçamento de venda para o portal de vendas"

WSDATA CCODPRO      As String // Codigo do produto
WSDATA CCODTAB      As String // Código da tabela de preço
WSDATA NPRCVEN      As Float  // Preço unitário da venda
WSDATA NQUANT       As Float  Optional // Quantidade vendida na primeira unidade de medida

WSMETHOD POST DESCRIPTION "Valida o preço unitário digitado no orçamento de venda e retorna o valor total, caso informado a quantidade" WSSYNTAX "/PRTVALIDAPRECO "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Processa as informações e retorna o json
@author Felipe Toledo
@since 11/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSRECEIVE CCODPRO, CCODTAB, NPRCVEN, NQUANT WSSERVICE PRTVALIDAPRECO
Local oObjResp   := Nil
Local cJson      := ''
Local oObjResp   := Nil
Local cCodPro    := PadR(AllTrim(Self:CCODPRO),TamSX3('B1_COD')[1])
Local cCodTab    := PadR(AllTrim(Self:CCODTAB),TamSX3('DA0_CODTAB')[1])
Local nPrcVen    := If(Empty(Self:NPRCVEN),0,Self:NPRCVEN)
Local nQtde      := If(Empty(Self:NQUANT) ,0,Self:NQUANT)
Local nValorTot  := 0
Local lRet       := .T.
Local nQtde2UM   := 0

// Valida produto
SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
If Empty(cCodPro) .Or. !SB1->(MsSeek(xFilial('SB1')+cCodPro))
	SetRestFault(400, "produto invalido")
	lRet := .F.
EndIf

If lRet
	// Quantidade minima para venda
	If nQtde < SB1->B1_LOTVEN
		SetRestFault(400, "quantidade inferior ao lote minima de venda: Lote Minimo: " + Alltrim(STR(SB1->B1_LOTVEN,20,6)))
		lRet := .F.
	EndIf
EndIf

If lRet
	// Converte para a segunda unidade de medida
	nQtde2UM := ConvUm( cCodPro, nQtde, 0, 2 )

	If nQtde2UM > Int(nQtde2UM)
		SetRestFault(400, "quantidade nao e multipla na 2a.UN do produto: " + Alltrim(STR(nQtde2UM,20,6)))
		lRet := .F.
	EndIf

EndIf

// Valida tabela de preco
If lRet
	DA1->(DbSetOrder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
	If Empty(cCodTab) .Or. !DA1->(MsSeek(xFilial('DA0')+cCodTab+cCodPro))
		SetRestFault(400, "tabela de preco invalida")
		lRet := .F.
	EndIf
EndIf

If lRet
	// preço minimo para venda
	If nPrcVen < DA1->DA1_PREMIN
		SetRestFault(400, "Preço de venda menor que o preço minimo. Entre em contato com a equipe Administrativa Comercial para liberacao")
		lRet := .F.
	EndIf
EndIf

If lRet
	// Retorna o valor total
	nValorTot:= A410Arred(nQtde * nPrcVen,"CK_VALOR")
	// Objeto que será serializado
	oObjResp := PrtValidaPreco():New(nValorTot, nQtde2UM, SB1->B1_SEGUM)
EndIf

// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)