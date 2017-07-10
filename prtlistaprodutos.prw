#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTLISTAPRODUTOS
Serviço REST de lista de produtos para oportal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTLISTAPRODUTOS DESCRIPTION "Serviço REST de lista de produtos portal de vendas"

WSDATA CFILTROSQL As String OPTIONAL // String com filtro SQL
WSDATA NPAGE      As Integer OPTIONAL // Numero da pagina

WSMETHOD GET DESCRIPTION "Retorna todos os produtos disponiveis para o portal de vendas" WSSYNTAX "/PRTLISTAPRODUTOS "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CFILTROSQL, NPAGE WSSERVICE PRTLISTAPRODUTOS
Local oObjResp   := Nil
Local cJson      := ''
Local cAliasQry  := GetNextAlias()
Local oObjResp   := PrtListaProdutos():New() // --> Objeto que será serializado
Local cFiltroSql := Self:CFILTROSQL
Local nPage      := Self:NPAGE
Local nRegPag    := 500 // Registros por pagina
Local cPagDe     := ''
Local cPagAte    := ''
Local cWhere     := ''
Local cWhere2    := ''
Local lRet       := .T.

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
cWhere :="%"
If ! Empty(cFiltroSql)
	// Filtro SQL 
	cWhere += " AND " + cFiltroSql
EndIf
cWhere +="%"

// Controle de paginação
cWhere2 := "%"
If !Empty(nPage) .And. nPage > 0
	cPagDe  := AllTrim(Str((nPage * nRegPag) - (nRegPag-1)))
	cPagAte := Alltrim(Str(nPage * nRegPag))
	
	cWhere2 += " WHERE LINHA BETWEEN " + cPagDe + " AND " + cPagAte + " "
EndIf
cWhere2 += "%"

// Query para listar os produtos disponiveis para orçamento
BeginSql Alias cAliasQry
    SELECT B1_COD, B1_DESC
      FROM (
	SELECT ROW_NUMBER() OVER (ORDER BY B1_COD) AS LINHA, B1_COD, B1_DESC
	  FROM %Table:SB1% SB1
	 WHERE SB1.B1_FILIAL = %xFilial:SB1%
	   %Exp:cWhere%
	   AND SB1.B1_TIPO   = 'PA'
	   AND SB1.B1_MSBLQL <> '1'
	   AND SB1.%notDel% ) TRB
	   %Exp:cWhere2%
	 ORDER
	    BY B1_COD
EndSql

If (cAliasQry)->( ! Eof() )
	//Cria um objeto da classe produtos para fazer a serialização na função FWJSONSerialize
	(cAliasQry)->(DbEval({||;
	oObjResp:Add( PrtItListaProdutos():New( B1_COD, B1_DESC ) );
	}))
Else
	SetRestFault(400, "Lista de produtos vazio")
	lRet := .F.
EndIf

// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

(cAliasQry)->(DbCloseArea())

Return(lRet)