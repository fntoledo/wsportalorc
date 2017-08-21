#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTCLIENTE
Serviço REST de cliente para o portal de vendas

@author Felipe Toledo
@since 23/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTCLIENTE DESCRIPTION "Serviço REST de cliente para o portal de vendas"

WSMETHOD GET DESCRIPTION "Retorna informações do cliente para o portal de vendas" WSSYNTAX "/PRTCLIENTE/{codigo_cliente+loja_cliente} "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 23/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSSERVICE PRTCLIENTE
Local oObjResp   := Nil
Local cJson      := ''
Local oObjResp   := Nil
Local cCliente   := ''
Local lRet       := .T.

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[1])
	cCliente := PadR(AllTrim(::aUrlParms[1]),TamSX3('A1_COD')[1]+TamSX3('A1_LOJA')[1]) // Recebe o codigo e loja do cliente
Else
	SetRestFault(400, "Codigo/loja do cliente nao informado nos parametros")
	lRet := .F.
EndIf

If lRet
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(MsSeek(xFilial('SA1')+cCliente))
		// Objeto que será serializado
		oObjResp := PrtCliente():New(SA1->A1_COD,;
		                             SA1->A1_LOJA,;
		                             SA1->A1_NOME,;
		                             SA1->A1_CGC,;
		                             SA1->A1_INSCR,;
		                             SA1->A1_VEND,;
		                             SA1->A1_END,;
		                             SA1->A1_BAIRRO,;
		                             SA1->A1_MUN,;
		                             SA1->A1_EST,;
		                             SA1->A1_CEP,;
		                             '('+SA1->A1_DDD+') '+SA1->A1_TEL,;
		                             SA1->A1_CONTATO,;
		                             SA1->A1_LC,;
		                             SA1->A1_PRICOM,;
		                             SA1->A1_SALDUP,;
		                             SA1->A1_ULTCOM,;
		                             SA1->A1_LCFIN,;
		                             SA1->A1_MATR,;
		                             SA1->A1_SALFIN,;
		                             SA1->A1_METR,;
		                             SA1->A1_MCOMPRA,;
		                             SA1->A1_RISCO,;
		                             SA1->A1_MSALDO)
	Else
		SetRestFault(400, "Cliente/Loja nao localizado no cadastro")
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