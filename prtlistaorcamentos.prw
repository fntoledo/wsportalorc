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

WSDATA CCODUSR    As String // Usuário Portal
WSDATA CFILTROSQL As String OPTIONAL //String com filtro SQL
WSDATA NPAGE      As Integer OPTIONAL // Numero da pagina
WSDATA NLIMPAG    As Integer OPTIONAL // Numero Maximo de registros por pagina

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
WSMETHOD GET WSRECEIVE CCODUSR, CFILTROSQL, NPAGE, NLIMPAG WSSERVICE PRTLISTAORCAMENTOS
Local cUsrPrt    := Self:CCODUSR
Local oObjResp   := Nil
Local cJson      := ''
Local cAliasQry  := GetNextAlias()
Local cAliasTot  := ''
Local oObjResp   := PrtListaOrcamentos():New() // --> Objeto que será serializado
Local cCodVen    := '' // Codigo do Vendedor
Local cFiltroSql := Self:CFILTROSQL
Local cWhere     := ''
Local cWhere2    := ''
Local aBoxStat   := RetSx3Box( Posicione('SX3', 2, 'CJ_STATUS', 'X3CBox()' ),,, Len(SCJ->CJ_STATUS) )
Local cStatus    := ''
Local nPage      := Self:NPAGE
Local nRegPag    := Self:NLIMPAG // Registros por pagina
Local cPagDe     := ''
Local cPagAte    := ''
Local nTotReg    := 0 // Total de Registros na consulta
Local nTotPag    := 0 // Total de Registros na Pagina
Local lRet       := .T.

// Valida CODIGO usuario portal
lRet := U_PrtVldUsr(cUsrPrt)
If !lRet
	SetRestFault(400, "Codigo usuario invalido")
	lRet := .F.
	Return(lRet)
EndIf

// Converte string base64 para formato original
If !Empty(cFiltroSql)
	cFiltroSql := Decode64(cFiltroSql)
EndIf

cCodVen := U_PrtCodVen(cUsrPrt) // Codigo do Vendedor

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
cWhere :="%"
If ! Empty(cCodVen)
	// Filtra o Representante
	cWhere += " AND SCJ.CJ_VEND1   = '" + cCodVen + "' "
EndIf

If ! Empty(cFiltroSql) 
	cWhere += " AND (" + cFiltroSql + ")"
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

// Query para listar dados
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
	//Cria um objeto para fazer a serialização na função FWJSONSerialize
	(cAliasQry)->(DbEval({||;
	nTotPag++,;
	cStatus := CJ_STATUS+"-"+AllTrim( aBoxStat[ Ascan( aBoxStat, { |x| x[ 2 ] == CJ_STATUS} ), 3 ]),;
	oObjResp:Add( PrtItListaOrcamentos():New( CJ_NUM, CJ_EMISSAO, CJ_CLIENTE, CJ_LOJA, A1_NOME, A1_CGC, cStatus ) );
	}))
EndIf

// Total de registros da pagina
oObjResp:SetRegPag(nTotPag)

(cAliasQry)->(DbCloseArea())

If lRet .And. (Empty(nPage) .Or. nPage <= 1)
	cAliasTot := GetNextAlias()
	// Query para listar os dados
	BeginSql Alias cAliasTot
		SELECT COUNT(*) TOTALREG
		  FROM %Table:SCJ% SCJ
		 INNER
		  JOIN %Table:SA1% SA1
		    ON SA1.A1_FILIAL = %xFilial:SA1%
		   AND SA1.A1_COD    = SCJ.CJ_CLIENTE
		   AND SA1.A1_LOJA   = SCJ.CJ_LOJA
		   AND SA1.%notDel%
		 WHERE SCJ.CJ_FILIAL = %xFilial:SCJ%
		   %Exp:cWhere%
	       AND SCJ.%notDel%
	EndSql
	If (cAliasTot)->( ! Eof() )
		nTotReg := (cAliasTot)->TOTALREG
	EndIf
	
	(cAliasTot)->(DbCloseArea())
	
	oObjResp:SetTotReg(nTotReg)
EndIf

// --> Transforma o objeto em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)