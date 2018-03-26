#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTPRECO
Serviço REST de preco de venda para o portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTPRECO DESCRIPTION "Serviço REST de preço de venda para o portal de vendas"

WSDATA CCODTAB    As String
WSDATA CCODPRO    As String
WSDATA NQUANT     As Float
WSDATA CCODCLI    As String
WSDATA CLOJCLI    As String

WSMETHOD GET DESCRIPTION "Retorna informações do preço de venda para o portal de vendas" WSSYNTAX "/PRTPRECO "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CCODTAB, CCODPRO, NQUANT, CCODCLI, CLOJCLI WSSERVICE PRTPRECO
Local oObjResp   := Nil
Local cJson      := ''
Local oObjResp   := Nil
// Parametros para tabela de preco
Local cTabPrec   := PadR(AllTrim(Self:CCODTAB),TamSX3('DA0_CODTAB')[1])
Local cCodPro    := PadR(AllTrim(Self:CCODPRO),TamSX3('B1_COD')[1])
Local nQtde      := If(Empty(Self:NQUANT),0,Self:NQUANT)
Local cCliente   := PadR(AllTrim(Self:CCODCLI),TamSX3('A1_COD')[1])
Local cLoja      := PadR(AllTrim(Self:CLOJCLI),TamSX3('A1_LOJA')[1])
Local nMoeda     := 1
Local dDtEmis    := Date()
Local nPrcVen    := 0
Local nPrcMin    := 0
Local lRet       := .T.
Local aPreco     := {}

// Valida tabela de preco
DA0->(DbSetOrder(1)) //DA0_FILIAL+DA0_CODTAB
If Empty(cTabPrec) .Or. !DA0->(MsSeek(xFilial('DA0')+cTabPrec))
	SetRestFault(400, "tabela de preco invalida")
	lRet := .F.
EndIf

// Valida produto
If lRet
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	If Empty(cCodPro) .Or. !SB1->(MsSeek(xFilial('SB1')+cCodPro))
		SetRestFault(400, "produto invalido")
		lRet := .F.
	EndIf
EndIf

// Valida cliente
If lRet
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If Empty(cCliente) .Or. !SA1->(MsSeek(xFilial('SA1')+cCliente+cLoja))
		SetRestFault(400, "cliente invalido")
		lRet := .F.
	EndIf
EndIf

If lRet
	// Retorna o Preco de Venda
	//nPrcVen := MaTabPrVen(cTabPrec,cCodPro,nQtde,cCliente,cLoja,nMoeda,dDtEmis)
	
	// Retorna o Preço Minimo
	//nPrcMin	:= Posicione("DA1", 1, xFilial("DA1") + cTabPrec + cCodPro, 'DA1_PREMIN')
	
	aPreco  := sfPrcVen(cTabPrec,cCodPro,nQtde,dDtEmis)
	nPrcVen := aPreco[1]
	nPrcMin := aPreco[2]
	
	// Objeto que será serializado
	oObjResp := PrtPreco():New(nPrcVen,nPrcMin)
EndIf

// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} sfPrcVen
Retorna a o preco de venda e o preco minimo da tabela
@author Felipe Toledo
@since 26/01/18
@type Method
/*/
//-------------------------------------------------------------------
Static Function sfPrcVen(cTabPrec,cCodPro,nQtde,dDtEmis)
Local aRet      := {0,0} //[1] DA1_PRCVEN, [2] DA1_PREMIN
Local cAliasQry := GetNextAlias()

BeginSql Alias cAliasQry
	SELECT DA1_PRCVEN, DA1_PREMIN
	  FROM %Table:DA1% DA1
	 WHERE DA1.DA1_FILIAL  = %xFilial:DA1%
	   AND DA1.DA1_CODTAB  = %Exp:cTabPrec%
	   AND DA1.DA1_CODPRO  = %Exp:cCodPro%
	   AND DA1.DA1_QTDLOT >= %Exp:Str(nQtde,18,8)%
	   AND DA1.DA1_ATIVO   = '1'
	   AND (DA1.DA1_DATVIG <= %Exp:DtoS(dDtEmis)% OR DA1.DA1_DATVIG = ' ' )
	   AND DA1.%NotDel%
	 ORDER
	    BY DA1_QTDLOT
EndSql

If (cAliasQry)->(!Eof())
	aRet[1] := (cAliasQry)->DA1_PRCVEN
	aRet[2] := (cAliasQry)->DA1_PREMIN
Endif

(cAliasQry)->(DbCloseArea())

Return(aRet)