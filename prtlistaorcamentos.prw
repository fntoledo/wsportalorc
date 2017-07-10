#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTLISTAORCAMENTOS
Serviço REST de lista de orcamentos de venda para oportal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTLISTAORCAMENTOS DESCRIPTION "Serviço REST de lista de orçamentos de vendas para o portal de vendas"

WSDATA CFILTROSQL As String OPTIONAL //String com filtro SQL
WSDATA NPAGE      As Integer OPTIONAL // Numero da pagina

WSMETHOD GET DESCRIPTION "Retorna todos os orçamentos disponiveis para o portal de vendas" WSSYNTAX "/PRTLISTAORCAMENTOS "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CFILTROSQL, NPAGE WSSERVICE PRTLISTAORCAMENTOS
Local oObjResp   := Nil
Local cJson      := ''
Local cAliasQry  := GetNextAlias()
Local oObjResp   := PrtListaOrcamentos():New() // --> Objeto que será serializado
Local cCodVen    := U_PrtCodVen() // Codigo do Vendedor
Local cFiltroSql := Self:CFILTROSQL
Local cWhere     := ''
Local cWhere2    := ''
Local aBoxStat   := RetSx3Box( Posicione('SX3', 2, 'CJ_STATUS', 'X3CBox()' ),,, Len(SCJ->CJ_STATUS) )
Local cStatus    := ''
Local nPage      := Self:NPAGE
Local nRegPag    := 500 // Registros por pagina
Local cPagDe     := ''
Local cPagAte    := ''

Local lRet       := .T.

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
cWhere :="%"
If ! Empty(cCodVen)
	// Filtra o Representante
	cWhere += " AND SCJ.CJ_VEND1   = '" + cCodVen + "' "
EndIf

If ! Empty(cFiltroSql) 
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
	COLUMN CJ_EMISSAO AS DATE
	SELECT CJ_NUM, CJ_EMISSAO, CJ_CLIENTE, CJ_LOJA, A1_NOME, A1_CGC, CJ_STATUS
	  FROM (
	SELECT ROW_NUMBER() OVER (ORDER BY CJ_NUM DESC) AS LINHA, CJ_NUM, CJ_EMISSAO, CJ_CLIENTE, CJ_LOJA, A1_NOME, A1_CGC, CJ_STATUS
	  FROM %Table:SCJ% SCJ
	 INNER
	  JOIN %Table:SA1% SA1
	    ON SA1.A1_FILIAL = %xFilial:SA1%
	   AND SA1.A1_COD    = SCJ.CJ_CLIENTE
	   AND SA1.A1_LOJA   = SCJ.CJ_LOJA
	   AND SA1.%notDel%
	 WHERE SCJ.CJ_FILIAL = %xFilial:SCJ%
	   %Exp:cWhere%
	   AND SCJ.%notDel%) TRB
	   %Exp:cWhere2%
	 ORDER
	    BY CJ_NUM DESC
EndSql

If (cAliasQry)->( ! Eof() )
	//Cria um objeto da classe produtos para fazer a serialização na função FWJSONSerialize
	(cAliasQry)->(DbEval({||;
	cStatus := CJ_STATUS+"-"+AllTrim( aBoxStat[ Ascan( aBoxStat, { |x| x[ 2 ] == CJ_STATUS} ), 3 ]),;
	oObjResp:Add( PrtItListaOrcamentos():New( CJ_NUM, CJ_EMISSAO, CJ_CLIENTE, CJ_LOJA, A1_NOME, A1_CGC, cStatus ) );
	}))
Else
	SetRestFault(400, "Lista de orcamentos vazio")
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