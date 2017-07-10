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

WSMETHOD GET DESCRIPTION "Retorna os dados do usuário do portal de venda" WSSYNTAX "/PRTLOGIN "
 
END WSRESTFUL
//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSSERVICE PRTLOGIN
Local oObjResp  := Nil
Local cJson     := ''
Local cCodUsr   := RetCodUsr() // Codigo do Usuário
Local cCodVen   := U_PrtCodVen() // Codigo do Vendedor
Local dDtAcesso := U_PrtDtUAc() // Data do último Acesso
Local cHrAcesso := U_PrtHrAc(dDtAcesso) // Hora do último acesso

//Cria um objeto da classe produtos para fazer a serialização na função FWJSONSerialize
oObjResp := PrtLogin():New(cUserName,; // 1. Nome do usuário
                              cCodUsr,; // 2. Codigo do usuário
                              UsrFullName(cCodUsr),; // 3. Nome completo
                              UsrRetMail(cCodUsr),; // 4. e-mail
                              cCodVen,;  // 5. Codigo representante
                              dDtAcesso,; // 6. Data do ultimo acesso
                              cHrAcesso) // 7. Hora do ultimo acesso

//-- Grava Log indicando acesso usuário
ProcLogAtu('MENSAGEM','Acesso portal',Nil,'PRTLOGIN')

// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(.T.)