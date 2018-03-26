#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PRTDASHBOARD
Serviço REST de DashBoard do Portal de Orcamentos

@author Felipe Toledo
@since 03/01/18
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTDASHBOARD DESCRIPTION "Serviço REST de DashBoard do portal de vendas"

WSDATA CCODUSR    As String // Usuário Portal

WSMETHOD GET DESCRIPTION "Retorna os valores para o DashBoard para o portal de vendas" WSSYNTAX "/PRTDASHBOARD "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 03/01/18
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE CCODUSR WSSERVICE PRTDASHBOARD
Local cUsrPrt    := Self:CCODUSR
Local cJson      := ''
Local oObjResp   := PrtDashBoard():New() // --> Objeto que será serializado
Local oOrcamentos:= PrtDashView():New('ORCAMENTO') // View de Orcamento
Local oPedidos   := PrtDashView():New('PEDIDO')    // View de Pedidos Colocados
Local oFaturados := PrtDashView():New('FATURADO')  // View de Notas Faturadas
Local cCodVen    := '' // Codigo do Vendedor
Local cAliasQry  := GetNextAlias()
Local cCJWhere   := '%%'
Local cC5Where   := '%%'
Local cF2Where   := '%%'
Local lRet       := .T.
Local nTotOrc    := 0
Local nTotPed    := 0
Local nTotFat    := 0

// Valida CODIGO usuario portal
lRet := U_PrtVldUsr(cUsrPrt)
If !lRet
	SetRestFault(400, "Codigo usuario invalido")
	lRet := .F.
	Return(lRet)
EndIf

cCodVen := U_PrtCodVen(cUsrPrt) // Codigo do Vendedor

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Empty(cCodVen) .And. Len(::aUrlParms) > 0
	cCodVen := ::aUrlParms[1] // Recebe o codigo do representante por parametro
EndIf


If ! Empty(cCodVen)
	// Filtra vendedor
	cCJWhere := "% AND SCJ.CJ_VEND1   = '" + cCodVen + "' %"
	cC5Where := "% AND SC5.C5_VEND1   = '" + cCodVen + "' %"
	cF2Where := "% AND SF2.F2_VEND1   = '" + cCodVen + "' %"
EndIf


// Query para listar os dados
BeginSql Alias cAliasQry
	COLUMN EMISSAO AS DATE
	
BeginSql Alias cAliasQry
	SELECT CJ_NUM,
	       CJ_EMISSAO,
	       CJ_CLIENTE,
	       CJ_LOJA,
	       A1_NOME,
	       SUM(CK_QTDVEN) CK_QTDVEN,
	       SUM(CK_VALOR)  CK_VALOR
	  FROM %table:SCJ% SCJ
	 INNER
	  JOIN %table:SA1% SA1
	    ON SA1.A1_FILIAL  = %xFilial:SA1%
	   AND SA1.A1_COD     = SCJ.CJ_CLIENTE
	   AND SA1.A1_LOJA    = SCJ.CJ_LOJA
	   AND SA1.%NotDel%
	 INNER
	  JOIN %table:SCK% SCK
	    ON SCK.CK_FILIAL  = %xFilial:SCK%
	   AND SCK.CK_NUM     = SCJ.CJ_NUM
	   AND SCK.%NotDel%
	 WHERE SCJ.CJ_FILIAL  = %xFilial:SCJ%
	   AND SCJ.CJ_NUM     = %Exp:mv_par01%
	   AND SCJ.%NotDel%
	 GROUP 
	    BY CJ_NUM, CJ_EMISSAO, CJ_CLIENTE, CJ_LOJA, A1_NOME
EndSql


//Percorre Query e cria os Objetos
(cAliasQry)->(DbEval({||;
oOrcamentos:Add( PrtItemDash():New((cAliasQry)->EMISSAO, (cAliasQry)->VLR_ORC) ),;
oPedidos:Add(    PrtItemDash():New((cAliasQry)->EMISSAO, (cAliasQry)->VLR_PED) ),;
oFaturados:Add(  PrtItemDash():New((cAliasQry)->EMISSAO, (cAliasQry)->VLR_FAT) ),;
nTotOrc += (cAliasQry)->VLR_ORC,;
nTotPed += (cAliasQry)->VLR_PED,;
nTotFat += (cAliasQry)->VLR_FAT;
}))

// Seta os Totais
oOrcamentos:SetTotal(nTotOrc)
oPedidos:SetTotal(nTotPed)
oFaturados:SetTotal(nTotFat)

// Cria Objeto que sera serializado
oObjResp:Add(oOrcamentos)
oObjResp:Add(oPedidos)
oObjResp:Add(oFaturados)

// --> Transforma o objeto em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

(cAliasQry)->(DbCloseArea())

Return(lRet)