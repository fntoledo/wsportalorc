#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTVALIDACONDPAG
Serviço REST de validação da condição de pagamento informada no 
no portal de vendas

@author Felipe Toledo
@since 11/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTVALIDACONDPAG DESCRIPTION "Serviço REST de validação da condição de pagamento para o portal de vendas"

WSDATA CCODCLI  As String // Codigo do cliente 
WSDATA CLOJCLI  As String // Loja do cliente
WSDATA CCONDPAG As String // Condição de Pagamento

WSMETHOD POST DESCRIPTION "Valida a condição de pagamento informando no orçamento" WSSYNTAX "/PRTVALIDACONDPAG "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Processa as informações e retorna o json
@author Felipe Toledo
@since 10/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE PRTVALIDACONDPAG
Local cJSonReq 	 := Self:GetContent() // Pega a string do JSON de requisicao
Local oParseJSON := Nil 
Local cCodCli    := PadR(AllTrim(Self:CCODCLI),TamSX3('A1_COD')[1])
Local cLojCli    := PadR(AllTrim(Self:CLOJCLI),TamSX3('A1_LOJA')[1])
Local cCondPag   := PadR(AllTrim(Self:CCONDPAG),TamSX3('E4_CODIGO')[1])
Local cCodPro    := ''
Local aVetImp    := {}
Local aRetImp    := {}
Local nCntFor    := 0
Local lRet       := .T.

// Valida cliente
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
If Empty(cCodCli) .Or. !SA1->(MsSeek(xFilial('SA1')+cCodCli+cLojCli))
	SetRestFault(400, "cliente invalido")
	lRet := .F.
EndIf

// Valida Condicao de Pagamentp
If lRet
	SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO
	If Empty(cCondPag) .Or. !SE4->(MsSeek(xFilial('SE4')+cCondPag))
		SetRestFault(400, "condicao de pagamento invalido")
		lRet := .F.
	EndIf
EndIf

If lRet .And. !Empty(cJSonReq)
	// --> Deserializa a string JSON
	FWJsonDeserialize(cJSonReq, @oParseJSON)
	
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	For nCntFor := 1 To Len(oParseJSON:Itens)
		cCodPro := PadR(AllTrim(oParseJSON:Itens[nCntFor]:cProduto),TamSX3('B1_COD')[1])
		
		// Valida produto
		If Empty(cCodPro) .Or. !SB1->(MsSeek(xFilial('SB1')+cCodPro))
			SetRestFault(400, "produto invalido: "+ AllTrim(cCodPro))
			lRet := .F.
			Exit
		EndIf

		Aadd(aVetImp, {cCodPro,;
			           oParseJSON:Itens[nCntFor]:nQuant,;
			           oParseJSON:Itens[nCntFor]:nPrcVen,;
			           oParseJSON:Itens[nCntFor]:nPrcVen,;
			           Nil})
	Next nCntFor
	
	// Calcula os impostos
	If lRet
		aRetImp := U_PrtImpos(cCodCli,cLojCli,cCondPag, aVetImp)
		
		If Len(aRetImp) > 0
		
			nPosVet := AsCan(aRetImp[2], {|x| Upper(AllTrim(x[6])) == 'SOL'})
				
			If nPosVet > 0 .And. aRetImp[2][nPosVet][5] > 0 .And. AllTrim(SE4->E4_SOLID) <> 'S'
				SetRestFault(400, "orcamento possui ST. Utilize uma condicao que gere ST")
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse("{CCONDICAO: 'OK'}")

Return(lRet)