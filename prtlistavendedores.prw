#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PRTLISTAVENDEDORES
Serviço REST de lista de vendedores portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTLISTAVENDEDORES DESCRIPTION "Serviço REST de lista de vendedores disponíveis para o portal de vendas"

WSDATA CFILTROSQL As String OPTIONAL //String com filtro SQL

WSMETHOD GET DESCRIPTION "Retorna todos os vendedores disponiveis para o portal de vendas" WSSYNTAX "/PRTLISTAVENDEDORES "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CFILTROSQL WSSERVICE PRTLISTAVENDEDORES
Local oObjResp   := Nil
Local cJson      := ''
Local cAliasQry  := GetNextAlias()
Local oObjResp   := PrtListaVendedores():New() // --> Objeto que será serializado
Local cCodVen    := U_PrtCodVen() // Codigo do Vendedor
Local cWhere     := ''
Local cFiltroSql := Self:CFILTROSQL
Local aBoxTipo   := RetSx3Box( Posicione('SX3', 2, 'A3_TIPO', 'X3CBox()' ),,, Len(SA3->A3_TIPO) )
Local cTipo      := ''
Local lRet       := .T.

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Empty(cCodVen) .And. Len(::aUrlParms) > 0
	cCodVen := ::aUrlParms[1] // Recebe o codigo do representante por parametro
EndIf

cWhere :="%"
If ! Empty(cCodVen)
	// Filtra vendedor
	cWhere += " AND SA3.A3_COD   = '" + cCodVen + "' "
EndIf

If ! Empty(cFiltroSql)
	// Filtro SQL 
	cWhere += " AND " + cFiltroSql
EndIf

cWhere +="%"

// Query para listar os dados
BeginSql Alias cAliasQry
	SELECT A3_COD, A3_NOME, A3_CGC, A3_TIPO
	  FROM %Table:SA3% SA3
	 WHERE SA3.A3_FILIAL = %xFilial:SA3%
	   %Exp:cWhere%
	   AND SA3.%notDel%
	 ORDER
	    BY A3_COD
EndSql

If (cAliasQry)->( ! Eof() )
	//Cria um objeto da classe para fazer a serialização na função FWJSONSerialize
	(cAliasQry)->(DbEval({||;
	cTipo := A3_TIPO+"-"+AllTrim( aBoxTipo[ Ascan( aBoxTipo, { |x| x[ 2 ] == A3_TIPO} ), 3 ]),;
	oObjResp:Add( PrtItListaVendedores():New( A3_COD, A3_NOME, A3_CGC, cTipo ) );
	}))
Else
	SetRestFault(400, "Lista de vendedores vazia")
	lRet := .F.
EndIf

// --> Transforma o objeto em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

(cAliasQry)->(DbCloseArea())

Return(lRet)