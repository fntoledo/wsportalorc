#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTPRODUTO
Serviço REST de produto para o portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTPRODUTO DESCRIPTION "Serviço REST de produto para o portal de vendas"

WSMETHOD GET DESCRIPTION "Retorna informações do produto para o portal de vendas" WSSYNTAX "/PRTPRODUTO/{codigo_produto} "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSSERVICE PRTPRODUTO
Local oObjResp   := Nil
Local cJson      := ''
Local oObjResp   := Nil
Local cCodPro    := ''
Local aBoxConv   := RetSx3Box( Posicione('SX3', 2, 'B1_TIPCONV', 'X3CBox()' ),,, Len(SB1->B1_TIPCONV) )
Local cTpConv    := ''
Local lRet       := .T.

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[1])
	cCodPro := PadR(AllTrim(::aUrlParms[1]),TamSX3('B1_COD')[1]) // Recebe o codigo do representante por parametro
Else
	SetRestFault(400, "Codigo do produto nao informado nos parametros")
	lRet := .F.
EndIf

If lRet
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
	If SB1->(MsSeek(xFilial('SB1')+cCodPro))
		cTpConv := SB1->B1_TIPCONV+"-"+AllTrim( aBoxConv[ Ascan( aBoxConv, { |x| x[ 2 ] == SB1->B1_TIPCONV} ), 3 ])
		// Objeto que será serializado
		oObjResp := PrtProduto():New(SB1->B1_COD,;
		                             SB1->B1_DESC,;
		                             SB1->B1_UM,;
		                             SB1->B1_SEGUM,;
		                             SB1->B1_CONV,;
		                             cTpConv,;
		                             SB1->B1_LOTVEN)
	Else
		SetRestFault(400, "Produto nao localizado no cadastro")
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