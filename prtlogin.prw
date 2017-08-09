#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

User Function PrtLogin()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTLOGIN
Metodo para validar e retornar os dados do usuário informado.

Utilizar a autenticação HTTP Basic no consumo de classes REST.
Envie no HEADER da requisição HTTP o campo Authorization conforme 
o modelo abaixo:

GET /PRTLOGIN
Host: localhost:8080
Accept: application/json
Authorization: BASIC YWRtaW46MTIzNDU2

usuário:senha no formato base64

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTLOGIN DESCRIPTION "Serviço REST para autenticar e retornar os dados do usuário do portal de vendas"

WSDATA CLOGIN     As String // Usuário
WSDATA CPASS      As String // Senha
WSDATA CNEWPASS   As String OPTIONAL // Nova Senha
WSDATA CEMAIL     As String OPTIONAL // E-Mail para recuperacao de senha

WSMETHOD GET  DESCRIPTION "Retorna os dados do usuário do portal de venda"   WSSYNTAX "/PRTLOGIN "
WSMETHOD POST DESCRIPTION "Recupera a senha do usuário do portal de venda"   WSSYNTAX "/PRTLOGIN "
WSMETHOD PUT  DESCRIPTION "Altera a senha do usuário do portal de venda"     WSSYNTAX "/PRTLOGIN "
 
END WSRESTFUL
//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CLOGIN, CPASS WSSERVICE PRTLOGIN
Local oObjResp  := Nil
Local cJson     := ''
Local cUsrPrt   := Self:CLOGIN
Local cPassPrt  := Self:CPASS
Local lRet      := .T.

// Valida usuário
If lRet .And. !U_PrtAuth(cUsrPrt, cPassPrt)
	SetRestFault(400, "Usuario nao autorizado")
	lRet := .F.
EndIf

If lRet
	//Cria um objeto da classe produtos para fazer a serialização na função FWJSONSerialize
	oObjResp := PrtLogin():New(AllTrim(AI3->AI3_LOGIN),; // 1. Nome do usuário
	                              AI3->AI3_CODUSU,; // 2. Codigo do usuário
	                              AllTrim(AI3->AI3_NOME),; // 3. Nome completo
	                              AllTrim(AI3->AI3_EMAIL),; // 4. e-mail
	                              AllTrim(AI3->AI3_ZCODVE),;  // 5. Codigo representante
	                              AI3->AI3_ZDTULT,; // 6. Data do ultimo acesso
	                              AI3->AI3_ZHRULT) // 7. Hora do ultimo acesso
	
	//-- Grava Log indicando acesso usuário
	U_PrtLogAc(AI3->AI3_LOGIN)

	// --> Transforma o objeto de produtos em uma string json
	cJson := FWJsonSerialize(oObjResp,.F.)
EndIf

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} POST

Recupera a senha do usuário (envia por e-mail)

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSRECEIVE CLOGIN, CEMAIL WSSERVICE PRTLOGIN
Local oObjResp  := Nil
Local cJson     := ''
Local cUsrPrt   := Self:CLOGIN
Local cEmail    := Self:CEMAIL
Local lRet      := .T.

If Empty(cUsrPrt)
	SetRestFault(400, "Senha nao informado")
	lRet := .F.
	Return(lRet)
EndIf

If Empty(cEmail)
	SetRestFault(400, "E-mail nao informado")
	lRet := .F.
	Return(lRet)
EndIf

cUsrPrt  := Decode64(cUsrPrt)

// verifica se o usuário esta cadastrado como representante
AI3->(DbSetOrder(2)) // AI3_FILIAL+AI3_LOGIN
If AI3->(MsSeek(xFilial('AI3')+cUsrPrt))
	AI3->(RecLock('AI3',.F.))
	If Upper(AllTrim(cEmail)) == Upper(Alltrim(AI3->AI3_EMAIL)) 
		// Envia senha
		StartJob('U_PrtEnvPas',GetEnvServer(),.F.,FWGrpCompany(),FWCodFil(),cEmail,AI3->AI3_LOGIN,AI3->AI3_PSW)
	Else
		SetRestFault(400, "E-mail invalido")
		lRet := .F.
		Return(lRet)
	EndIf
	AI3->AI3_ZHRULT := Time()
	AI3->(MsUnLock())
Else
	SetRestFault(400, "Usuario invalido")
	lRet := .F.
	Return(lRet)
EndIf

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse("{ENVIO: 'OK'}")

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT

Altera a senha do usuario do portal

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSRECEIVE CLOGIN, CPASS, CNEWPASS WSSERVICE PRTLOGIN
Local oObjResp  := Nil
Local cJson     := ''
Local cUsrPrt   := Self:CLOGIN
Local cPassPrt  := Self:CPASS
Local cNewPass  := Self:CNEWPASS
Local lRet      := .T.

// Valida usuário
If !U_PrtAuth(cUsrPrt, cPassPrt)
	SetRestFault(400, "Usuario/senha invalido")
	lRet := .F.
	Return(lRet)
EndIf

If Empty(cNewPass)
	SetRestFault(400, "Nova senha nao informado")
	lRet := .F.
	Return(lRet)
EndIf

If lRet
	cUsrPrt  := Decode64(cUsrPrt)
	cNewPass := Decode64(cNewPass)

	If Len(cNewPass) > Len(AI3->AI3_PSW)
		SetRestFault(400, "Tamanho da nova senha nao pode ser maior que: " + cValToChar(Len(AI3->AI3_PSW)))
		lRet := .F.
		Return(lRet)
	EndIf
	
	If lRet
		U_PrtAltPas(cUsrPrt, cNewPass)
	EndIf

EndIf

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse("{STATUS: 'OK'}")

Return(lRet)