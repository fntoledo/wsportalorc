#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTENVORCAMENTO
Serviço REST de envio do orcamento de venda em PDF

@author Felipe Toledo
@since 23/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTENVORCAMENTO DESCRIPTION "Serviço REST de envio do orcamento de venda em PDF por e-mail"

WSDATA CCODUSR    As String // Usuário Portal
WSDATA CEMAIL     As String //E-Mail para envio do Orçamento

WSMETHOD POST DESCRIPTION "Envio do orçamento de venda em PDF por e-mail" WSSYNTAX "/PRTORCAMENTO/{codigo_orcamento}"
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSRECEIVE CCODUSR, CEMAIL WSSERVICE PRTENVORCAMENTO
Local cJson      := ''
Local cUsrPrt    := Self:CCODUSR
Local cEmail     := Self:CEMAIL
Local lRet       := .T.

// Valida CODIGO usuario portal
lRet := U_PrtVldUsr(cUsrPrt)
If !lRet
	SetRestFault(400, "Codigo usuario invalido")
	lRet := .F.
	Return(lRet)
EndIf

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[1])
	cNumOrc := PadR(AllTrim(::aUrlParms[1]),TamSX3('CJ_NUM')[1]) // Recebe o numero do orcamento
Else
	SetRestFault(400, "Codigo do orcamento nao informado nos parametros")
	lRet := .F.
EndIf

If lRet .And. Empty(cEmail)
	SetRestFault(400, "E-Mail nao informado para envio")
	lRet := .F.
EndIf

If lRet
	SCJ->(DbSetOrder(1)) // CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
	If SCJ->(MsSeek(xFilial('SCJ')+cNumOrc))
		// Processa o envio do e-mail
		StartJob('U_PrtEnvOrc',GetEnvServer(),.F.,FWGrpCompany(),FWCodFil(),cNumOrc,cEmail,cUsrPrt)
		cJson := "{ENVIO: 'OK'}"
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