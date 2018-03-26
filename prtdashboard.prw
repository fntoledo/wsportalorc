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
	
	SELECT EMISSAO, SUM(VLR_ORC) VLR_ORC, SUM(VLR_PED) VLR_PED, SUM(VLR_FAT) VLR_FAT
	  FROM (
			SELECT CJ_EMISSAO     EMISSAO,
			       SUM(CK_VALOR)  VLR_ORC,
				   0              VLR_PED,
				   0              VLR_FAT
			  FROM %table:SCJ% SCJ
			 INNER
			  JOIN %table:SCK% SCK
			    ON SCK.CK_FILIAL  = %xFilial:SCK%
			   AND SCK.CK_NUM     = SCJ.CJ_NUM
			   AND SCK.%NotDel%
			 WHERE SCJ.CJ_FILIAL  = %xFilial:SCJ%
			   AND SCJ.CJ_EMISSAO >= %Exp:DtoS(Date()-30)%
			   AND SCJ.%NotDel%
			   %Exp:cCJWhere%
			 GROUP 
			    BY CJ_EMISSAO
		
		     UNION 
		       ALL
		   
		    SELECT C5_EMISSAO EMISSAO, 0 VLR_ORC, SUM(C6_VALOR) VLR_PED,0 VLR_FAT 
		      FROM %table:SC5% SC5
		     INNER 
		      JOIN %table:SC6% SC6
		        ON SC6.C6_FILIAL   = %xFilial:SC6%
		       AND SC6.C6_NUM      = SC5.C5_NUM 
		       AND SC6.%NotDel%
		     INNER 
		      JOIN %table:SF4% SF4
		        ON SF4.F4_FILIAL   = %xFilial:SF4%
		       AND SF4.F4_CODIGO   = SC6.C6_TES
		       AND SF4.F4_DUPLIC   = 'S'
		       AND SF4.%NotDel%
		     WHERE SC5.C5_FILIAL = %xFilial:SC5%
		       AND SC5.C5_TIPO     = 'N'
		       AND SC5.C5_EMISSAO >= %Exp:DtoS(Date()-30)%
		       AND SC5.%NotDel%
		       %Exp:cC5Where%
		     GROUP 
		        BY C5_EMISSAO
		        
		     UNION 
		       ALL
		   
		    SELECT F2_EMISSAO EMISSAO, 0 VLR_ORC, 0 VLR_PED, SUM(D2_TOTAL) VLR_FAT
		      FROM %table:SF2% SF2
		     INNER 
		      JOIN %table:SD2% SD2
		        ON SD2.D2_FILIAL  = %xFilial:SD2%
		       AND SD2.D2_DOC     = SF2.F2_DOC
		       AND SD2.D2_SERIE   = SF2.F2_SERIE 
		       AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
		       AND SD2.D2_LOJA    = SF2.F2_LOJA
		       AND SD2.D2_ORIGLAN <> 'LF'
		       AND SD2.%NotDel%
		     INNER 
		      JOIN %table:SF4% SF4
		        ON SF4.F4_FILIAL   = %xFilial:SF4%
		       AND SF4.F4_CODIGO   = SD2.D2_TES
		       AND SF4.F4_DUPLIC   = 'S'
		       AND SF4.%NotDel%
		     WHERE SF2.F2_FILIAL   = %xFilial:SF2%
		       AND SF2.F2_TIPO     = 'N'
		       AND SF2.F2_EMISSAO >= %Exp:DtoS(Date()-30)%
		       AND SF2.%NotDel%
		       %Exp:cF2Where%
		     GROUP 
		        BY F2_EMISSAO
	     ) TRB
	 GROUP
	    BY EMISSAO
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