#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PRTLISTACLIENTES
Serviço REST de lista de clientes portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTLISTACLIENTES DESCRIPTION "Serviço REST de clientes portal de vendas"

WSDATA CFILTROSQL As String OPTIONAL // String com filtro SQL
WSDATA NPAGE      As Integer OPTIONAL // Numero da pagina
WSDATA NLIMPAG    As Integer OPTIONAL // Numero Maximo de registros por pagina

WSMETHOD GET DESCRIPTION "Retorna todos os clientes disponiveis para o portal de vendas" WSSYNTAX "/PRTLISTACLIENTES "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CFILTROSQL, NPAGE, NLIMPAG WSSERVICE PRTLISTACLIENTES
Local oObjResp   := Nil
Local cJson      := ''
Local cAliasQry  := GetNextAlias()
Local cAliasTot  := ''
Local oObjResp   := PrtListaClientes():New() // --> Objeto que será serializado
Local cCodVen    := U_PrtCodVen() // Codigo do Vendedor
Local cWhere     := ''
Local cWhere2    := ''
Local cFiltroSql := Self:CFILTROSQL
Local nPage      := Self:NPAGE
Local nRegPag    := Self:NLIMPAG // Registros por pagina
Local cPagDe     := ''
Local cPagAte    := ''
Local nTotReg    := 0 // Total de Registros
Local lRet       := .T.

// Converte string base64 para formato original
If !Empty(cFiltroSql)
	cFiltroSql := Decode64(cFiltroSql)
EndIf

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Empty(cCodVen) .And. Len(::aUrlParms) > 0
	cCodVen := ::aUrlParms[1] // Recebe o codigo do representante por parametro
EndIf

cWhere :="%"
If ! Empty(cCodVen)
	// Filtra vendedor
	cWhere += " AND SA1.A1_VEND   = '" + cCodVen + "' "
EndIf

If ! Empty(cFiltroSql)
	// Filtro SQL 
	cWhere += " AND " + cFiltroSql
EndIf

cWhere +="%"

// Controle de paginação
cWhere2 := "%"
If !Empty(nPage) .And. nPage > 0 .And. !Empty(nRegPag) .And. nRegPag > 0
	cPagDe  := AllTrim(Str((nPage * nRegPag) - (nRegPag-1)))
	cPagAte := Alltrim(Str(nPage * nRegPag))
	
	cWhere2 += " WHERE LINHA BETWEEN " + cPagDe + " AND " + cPagAte + " "
EndIf
cWhere2 += "%"

// Query para listar os dados
BeginSql Alias cAliasQry
    SELECT A1_COD, A1_LOJA, A1_NOME, A1_CGC, A1_VEND
      FROM (
	SELECT ROW_NUMBER() OVER (ORDER BY A1_COD, A1_LOJA) AS LINHA, A1_COD, A1_LOJA, A1_NOME, A1_CGC, A1_VEND
	  FROM %Table:SA1% SA1
	 WHERE SA1.A1_FILIAL = %xFilial:SA1%
	   %Exp:cWhere%
	   AND SA1.%notDel%) TRB
	   %Exp:cWhere2%
	 ORDER
	    BY A1_COD, A1_LOJA
EndSql

If (cAliasQry)->( ! Eof() )
	//Cria um objeto da classe para fazer a serialização na função FWJSONSerialize
	(cAliasQry)->(DbEval({||;
	oObjResp:Add( PrtItListaClientes():New( A1_COD, A1_LOJA, A1_NOME, A1_CGC, A1_VEND ) );
	}))
EndIf

(cAliasQry)->(DbCloseArea())

If lRet .And. (Empty(nPage) .Or. nPage <= 1)
	cAliasTot := GetNextAlias()
	// Query para listar os dados
	BeginSql Alias cAliasTot
		SELECT COUNT(*) TOTALREG
		  FROM %Table:SA1% SA1
		 WHERE SA1.A1_FILIAL = %xFilial:SA1%
		   %Exp:cWhere%
		   AND SA1.%notDel%
	EndSql
	If (cAliasTot)->( ! Eof() )
		nTotReg := (cAliasTot)->TOTALREG
	EndIf
	
	(cAliasTot)->(DbCloseArea())
	
	oObjResp:SetTotReg(nTotReg)
EndIf

// --> Transforma o objeto de clientes em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)