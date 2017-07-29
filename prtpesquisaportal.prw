#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PRTPESQUISAPORTAL
Serviço REST de pesquisa Clientes, Orçamentos, Produtos, 
Transportadoras e Vendedores em um único request

@author Felipe Toledo
@since 28/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTPESQUISAPORTAL DESCRIPTION "Serviço REST para pesquida nas entidades: Clientes, Orçamentos, Produtos, Vendedores e Transportadoras"

WSDATA CPESQUISA  As String  OPTIONAL // String para filtro nas entidades
WSDATA NPAGE      As Integer OPTIONAL // Numero da pagina
WSDATA NLIMPAG    As Integer OPTIONAL // Numero Maximo de registros por pagina

WSMETHOD GET DESCRIPTION "Retorna resulta de pesquisa nas entidades: Clientes, Orçamentos, Produtos, Vendedores e Transportadoras" WSSYNTAX "/PRTPESQUISAPORTAL "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CPESQUISA, NPAGE, NLIMPAG WSSERVICE PRTPESQUISAPORTAL
Local cJson      := ''
Local cAliasQry  := GetNextAlias()
Local cAliasTot  := ''
Local oObjResp   := PrtPrtPesquisaPortal():New() // --> Objeto que será serializado
Local oClientes  := PrtListaClientes():New()
Local oOrcamentos:= PrtListaOrcamentos():New()
Local oProdutos  := PrtListaProdutos():New()
Local oVendedores:= PrtListaVendedores():New()
Local oTransp    := PrtListaTransportadoras():New()


Local cCodVen    := U_PrtCodVen() // Codigo do Vendedor
Local cWhere     := ''
Local cWhere2    := ''
Local cPesquisa  := Self:CPESQUISA
Local nPage      := Self:NPAGE
Local nRegPag    := Self:NLIMPAG // Registros por pagina
Local cPagDe     := ''
Local cPagAte    := ''
Local nTotReg    := 0 // Total de Registros
Local aBoxStat   := RetSx3Box( Posicione('SX3', 2, 'CJ_STATUS', 'X3CBox()' ),,, Len(SCJ->CJ_STATUS) )
Local cStatus    := ''
Local aBoxTipo   := RetSx3Box( Posicione('SX3', 2, 'A3_TIPO', 'X3CBox()' ),,, Len(SA3->A3_TIPO) )
Local cTipo      := ''
Local lRet       := .T.

//-------------------------------------
// CLIENTES
//-------------------------------------
cWhere :="%"
If ! Empty(cCodVen)
	// Filtra vendedor
	cWhere += " AND SA1.A1_VEND   = '" + cCodVen + "' "
EndIf

If ! Empty(cPesquisa)
	// Filtro SQL 
	cWhere += " AND SA1.A1_NOME LIKE '%" + cPesquisa + "%' "
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
	oClientes:Add( PrtItListaClientes():New( A1_COD, A1_LOJA, A1_NOME, A1_CGC, A1_VEND ) );
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
	
	oClientes:SetTotReg(nTotReg)
EndIf

// Adiciona o Resultado de Clientes
oObjResp:AddClientes(oClientes)

//-------------------------------------
// Orçamentos
//-------------------------------------
nTotReg := 0
//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
cWhere :="%"
If ! Empty(cCodVen)
	// Filtra o Representante
	cWhere += " AND SCJ.CJ_VEND1   = '" + cCodVen + "' "
EndIf

If ! Empty(cPesquisa)
	// Filtro SQL 
	cWhere += " AND SA1.A1_NOME LIKE '%" + cPesquisa + "%' "
EndIf
cWhere +="%"

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
	cStatus := CJ_STATUS+"-"+AllTrim( aBoxStat[ Ascan( aBoxStat, { |x| x[ 2 ] == CJ_STATUS} ), 3 ]),;
	oOrcamentos:Add( PrtItListaOrcamentos():New( CJ_NUM, CJ_EMISSAO, CJ_CLIENTE, CJ_LOJA, A1_NOME, A1_CGC, cStatus ) );
	}))
	
EndIf

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
	
	oOrcamentos:SetTotReg(nTotReg)
EndIf

oObjResp:AddOrcamentos(oOrcamentos)

//-------------------------------------
// Produtos
//-------------------------------------
nTotReg := 0

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
cWhere :="%"
If ! Empty(cPesquisa)
	// Filtro SQL 
	cWhere += " AND SB1.B1_DESC LIKE '%" + cPesquisa + "%' "
EndIf
cWhere +="%"

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
	oProdutos:Add( PrtItListaProdutos():New( B1_COD, B1_DESC ) );
	}))
EndIf

(cAliasQry)->(DbCloseArea())

If lRet .And. (Empty(nPage) .Or. nPage <= 1)
	cAliasTot := GetNextAlias()
	// Query para listar os dados
	BeginSql Alias cAliasTot
		SELECT COUNT(*) TOTALREG
		  FROM %Table:SB1% SB1
		 WHERE SB1.B1_FILIAL = %xFilial:SB1%
		   %Exp:cWhere%
		   AND SB1.B1_TIPO   = 'PA'
		   AND SB1.B1_MSBLQL <> '1'
		   AND SB1.%notDel% 
	EndSql
	If (cAliasTot)->( ! Eof() )
		nTotReg := (cAliasTot)->TOTALREG
	EndIf
	
	(cAliasTot)->(DbCloseArea())
	
	oProdutos:SetTotReg(nTotReg)
EndIf

oObjResp:AddProdutos(oProdutos)

//-------------------------------------
// Vendedores
//-------------------------------------
nTotReg := 0

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
cWhere :="%"
If ! Empty(cCodVen)
	// Filtra vendedor
	cWhere += " AND SA3.A3_COD   = '" + cCodVen + "' "
EndIf
If ! Empty(cPesquisa)
	// Filtro SQL 
	cWhere += " AND SA3.A3_NOME LIKE '%" + cPesquisa + "%' "
EndIf
cWhere +="%"

// Query para listar os dados
BeginSql Alias cAliasQry
	SELECT A3_COD, A3_NOME, A3_CGC, A3_TIPO, A3_TABELA, A3_TABELAF, A3_COMIS
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
	nTotReg++,;
	cTipo := A3_TIPO+"-"+AllTrim( aBoxTipo[ Ascan( aBoxTipo, { |x| x[ 2 ] == A3_TIPO} ), 3 ]),;
	oVendedores:Add( PrtItListaVendedores():New( A3_COD, A3_NOME, A3_CGC, cTipo, A3_TABELA, A3_TABELAF, A3_COMIS ) );
	}))
	
	oVendedores:SetTotReg(nTotReg)
EndIf

(cAliasQry)->(DbCloseArea())

oObjResp:AddVendedores(oVendedores)

//-------------------------------------
// Transportadoras
//-------------------------------------
nTotReg := 0

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
cWhere :="%"
If ! Empty(cPesquisa)
	// Filtro SQL 
	cWhere += " AND SA4.A4_NOME LIKE '%" + cPesquisa + "%' "
EndIf
cWhere +="%"

// Query para listar os dados
BeginSql Alias cAliasQry
    SELECT A4_COD, A4_NOME, A4_CGC
      FROM (
	SELECT ROW_NUMBER() OVER (ORDER BY A4_COD, A4_COD) AS LINHA, A4_COD, A4_NOME, A4_CGC
	  FROM %Table:SA4% SA4
	 WHERE SA4.A4_FILIAL = %xFilial:SA4%
	   %Exp:cWhere%
	   AND SA4.%notDel%) TRB
	   %Exp:cWhere2%
	 ORDER
	    BY A4_COD
EndSql

If (cAliasQry)->( ! Eof() )
	//Cria um objeto da classe para fazer a serialização na função FWJSONSerialize
	(cAliasQry)->(DbEval({||;
	oTransp:Add( PrtItListaTransportadoras():New( A4_COD, A4_NOME, A4_CGC ) );
	}))
EndIf

(cAliasQry)->(DbCloseArea())

If lRet .And. (Empty(nPage) .Or. nPage <= 1)
	cAliasTot := GetNextAlias()
	// Query para listar os dados
	BeginSql Alias cAliasTot
		SELECT COUNT(*) TOTALREG
		  FROM %Table:SA4% SA4
		 WHERE SA4.A4_FILIAL = %xFilial:SA4%
		   %Exp:cWhere%
		   AND SA4.%notDel% 
	EndSql
	If (cAliasTot)->( ! Eof() )
		nTotReg := (cAliasTot)->TOTALREG
	EndIf
	
	(cAliasTot)->(DbCloseArea())
	
	oTransp:SetTotReg(nTotReg)
EndIf

oObjResp:AddTransportadoras(oTransp)

// --> Transforma o objeto de clientes em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)