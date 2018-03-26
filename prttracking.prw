#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PRTTRACKING
Serviço REST de Tracking do Portal de Orcamentos

@author Felipe Toledo
@since 15/02/18
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTTRACKING DESCRIPTION "Serviço REST de Tracking do portal de vendas"

WSMETHOD GET DESCRIPTION "Retorna os valores para o Tracking do Orçamento para o portal de vendas" WSSYNTAX "/PRTTRACKING "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 03/01/18
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSSERVICE PRTTRACKING
Local cJson      := ''
Local oObjResp   := PrtTracking():New() // --> Objeto que será serializado
Local aOrcamen   := {}
Local aFaturado  := {}
Local aLiberado  := {}
Local aNaoLibe   := {}
Local aTitulos   := {}
Local cNumOrc    := '' // Numero do Orçamento
Local cAliasQry  := ''
Local nTotQtd    := 0
Local nTotVlr    := 0
Local cCodCli    := ''
LoCAL cLojCli    := ''
Local cCliente   := ''
Local dEmisOrc   := CtoD('  /  /  ')
Local aBoxtTpFr  := RetSx3Box( Posicione('SX3', 2, 'CJ_TPFRETE', 'X3CBox()' ),,, Len(SCJ->CJ_TPFRETE) )
Local aBoxtSita  := {}
Local lRet       := .T.

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Empty(cNumOrc) .And. Len(::aUrlParms) > 0
	cNumOrc := ::aUrlParms[1] // Recebe o codigo do representante por parametro
Else
	SetRestFault(400, "Orçamento nao informado")
	lRet := .F.
	Return(lRet)
EndIf

//
// Orçamento
//
cAliasQry  := GetNextAlias()
BeginSql Alias cAliasQry
	COLUMN CJ_EMISSAO AS DATE
	
	SELECT CJ_NUM,
		   CJ_EMISSAO,
		   CJ_CLIENTE,
		   CJ_LOJA,
		   A1_NOME,
	       CK_ITEM,
		   CK_PRODUTO,
		   CK_DESCRI,
		   CK_QTDVEN,
		   CK_UM,
		   CK_PRCVEN,
		   CK_VALOR
	  FROM %table:SCJ% SCJ
	  INNER
	   JOIN %table:SA1% SA1
		 ON SA1.A1_FILIAL  = %xFilial:SA1%
		AND SA1.A1_COD     = SCJ.CJ_CLIENTE
		AND SA1.A1_LOJA    = SCJ.CJ_LOJA
		AND SA1.%NotDel%
	  INNER
	   JOIN %table:SCK% SCK
		 ON SCK.CK_FILIAL  = SCJ.CJ_FILIAL
		AND SCK.CK_NUM     = SCJ.CJ_NUM
		AND SCK.%NotDel%
	  WHERE SCJ.CJ_FILIAL  = %xFilial:SCJ%
		AND SCJ.CJ_NUM     = %Exp:cNumOrc%
		AND SCJ.%NotDel%
	  ORDER 
		 BY CK_ITEM
EndSql

If (cAliasQry)->( ! Eof() )
	cCodCli  := (cAliasQry)->CJ_CLIENTE
	cLojCli  := (cAliasQry)->CJ_LOJA
	cCliente := (cAliasQry)->A1_NOME
	dEmisOrc := (cAliasQry)->CJ_EMISSAO

	//Percorre Query e cria os Objetos
	(cAliasQry)->(DbEval({||;
	Aadd( aOrcamen, PrtTrkOrcamento():New(CK_ITEM, CK_PRODUTO, CK_DESCRI, CK_QTDVEN, CK_UM, CK_PRCVEN, CK_VALOR) ),;
	nTotQtd  += (cAliasQry)->CK_QTDVEN,;
	nTotVlr  += (cAliasQry)->CK_VALOR,;
	}))
	
	oObjResp:Add( 'CAB_ORCAMENTO', PrtTrkCabOrc():New(cNumOrc, dEmisOrc, cCodCli+'/'+cLojCli+' - '+cCliente, nTotQtd, nTotVlr) )
	oObjResp:Add( 'ORCAMENTO'    , aOrcamen )
EndIf

(cAliasQry)->(DbCloseArea())

//
// Pedido Faturado
//
cAliasQry  := GetNextAlias()
BeginSql Alias cAliasQry
	COLUMN D2_EMISSAO AS DATE
	
	SELECT D2_PEDIDO, 
	       D2_DOC, 
	       D2_SERIE, 
	       F2_COND, 
	       E4_DESCRI, 
	       F2_TRANSP, 
	       A4_NOME, 
	       F2_TPFRETE, 
	       D2_ITEM, 
	       D2_COD, 
	       C6_DESCRI, 
	       D2_EMISSAO, 
	       D2_QUANT, 
	       D2_UM, 
	       D2_PRCVEN, 
	       D2_TOTAL
	  FROM %table:SD2% SD2
	 INNER
	  JOIN %table:SF2% SF2
		ON SF2.F2_FILIAL  = SD2.D2_FILIAL
	   AND SF2.F2_DOC     = SD2.D2_DOC
	   AND SF2.F2_SERIE   = SD2.D2_SERIE
	   AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
	   AND SF2.F2_LOJA    = SD2.D2_LOJA
	   AND SF2.%NotDel%
	  LEFT
	  JOIN %table:SA4% SA4
		ON SA4.A4_FILIAL  = %xFilial:SA4%
	   AND SA4.A4_COD     = SF2.F2_TRANSP
	   AND SA4.%NotDel%
	 INNER
	  JOIN %table:SE4% SE4
		ON SE4.E4_FILIAL  = %xFilial:SE4%
	   AND SE4.E4_CODIGO  = SF2.F2_COND
	   AND SE4.%NotDel%
	 INNER
	  JOIN %table:SC6% SC6
	    ON SC6.C6_FILIAL  = SD2.D2_FILIAL
	   AND SC6.C6_NUM     = SD2.D2_PEDIDO
	   AND SC6.C6_ITEM    = SD2.D2_ITEMPV
	   AND SUBSTRING(SC6.C6_NUMORC,1,6) = %Exp:cNumOrc%
	   AND SC6.%NotDel%
	 WHERE SD2.D2_FILIAL  = %xFilial:SD2%
	   AND SD2.%NotDel%
	 ORDER
		BY D2_SERIE, D2_DOC, D2_ITEM
EndSql

//Percorre Query e cria os Objetos
(cAliasQry)->(DbEval({||;
Aadd( aFaturado, PrtTrkFaturado():New(D2_PEDIDO, D2_DOC, D2_SERIE, F2_COND+' - '+E4_DESCRI, F2_TRANSP+' - '+A4_NOME,;
F2_TPFRETE+"-"+AllTrim( aBoxtTpFr[ Ascan( aBoxtTpFr, { |x| x[ 2 ] == F2_TPFRETE} ), 3 ]),;
D2_ITEM, D2_COD, C6_DESCRI, D2_EMISSAO, D2_QUANT, D2_UM, D2_PRCVEN, D2_TOTAL) ),;
}))

oObjResp:Add( 'FATURADO'     , aFaturado )

(cAliasQry)->(DbCloseArea())

//
// Pedido com os Itens Liberados
//
cAliasQry  := GetNextAlias()
BeginSql Alias cAliasQry
	COLUMN C9_DATALIB AS DATE
	
	SELECT C9_PEDIDO, 
	       C5_CONDPAG, 
	       E4_DESCRI, 
	       C5_TRANSP, 
	       A4_NOME, 
	       C5_TPFRETE, 
	       C9_ITEM, 
	       C9_PRODUTO, 
	       C6_DESCRI, 
	       C9_DATALIB, 
	       C9_QTDLIB, 
	       C6_UM, 
	       C6_PRCVEN, 
	       (C9_QTDLIB*C6_PRCVEN) VLRTOTAL
	  FROM %table:SC9% SC9
	 INNER
	  JOIN %table:SC5% SC5
	    ON SC5.C5_FILIAL  = SC9.C9_FILIAL
	   AND SC5.C5_NUM     = SC9.C9_PEDIDO
	   AND SC5.%NotDel%
	  LEFT
	  JOIN %table:SA4% SA4
	    ON SA4.A4_FILIAL  = %xFilial:SA4%
	   AND SA4.A4_COD     = SC5.C5_TRANSP
	   AND SA4.%NotDel%
	 INNER
	  JOIN %table:SE4% SE4
	    ON SE4.E4_FILIAL  = %xFilial:SE4%
	   AND SE4.E4_CODIGO  = SC5.C5_CONDPAG
	   AND SE4.%NotDel%
	 INNER
	  JOIN %table:SC6% SC6
	    ON SC6.C6_FILIAL  = SC9.C9_FILIAL
	   AND SC6.C6_NUM     = SC9.C9_PEDIDO
	   AND SC6.C6_ITEM    = SC9.C9_ITEM
	   AND SUBSTRING(SC6.C6_NUMORC,1,6) = %Exp:cNumOrc%
	   AND SC6.%NotDel%
	 WHERE SC9.C9_FILIAL  = %xFilial:SC9%
	   AND SC9.C9_NFISCAL = ' '
	   AND SC9.%NotDel%
	 ORDER
	    BY C9_PEDIDO, C9_ITEM, C9_SEQUEN
EndSql

//Percorre Query e cria os Objetos
(cAliasQry)->(DbEval({||;
Aadd( aLiberado, PrtTrkPedido():New(C9_PEDIDO, C5_CONDPAG+' - '+E4_DESCRI, C5_TRANSP+' - '+A4_NOME,;
C5_TPFRETE+"-"+AllTrim( aBoxtTpFr[ Ascan( aBoxtTpFr, { |x| x[ 2 ] == C5_TPFRETE} ), 3 ]),;
C9_ITEM, C9_PRODUTO, C6_DESCRI, C9_DATALIB, C9_QTDLIB, C6_UM, C6_PRCVEN, VLRTOTAL) ),;
}))

oObjResp:Add( 'PED_LIBERADO'     , aLiberado )

(cAliasQry)->(DbCloseArea())

//
// Pedido com Itens Aguardando Liberação
//
cAliasQry  := GetNextAlias()
BeginSql Alias cAliasQry
	COLUMN C5_EMISSAO AS DATE
	
	SELECT C6_NUM, 
	       C5_CONDPAG, 
		   E4_DESCRI, 
		   C5_TRANSP, 
		   A4_NOME, 
		   C5_TPFRETE, 
		   C6_ITEM, 
		   C6_PRODUTO, 
		   C6_DESCRI, 
		   C5_EMISSAO, 
		   (C6_QTDVEN - (C6_QTDENT+C6_QTDEMP )) C6_QTDVEN, 
		   C6_UM, 
		   C6_PRCVEN, 
		   ((C6_QTDVEN - (C6_QTDENT+C6_QTDEMP ))*C6_PRCVEN) VLRTOTAL
	  FROM %table:SC6% SC6
	 INNER
	  JOIN %table:SC5% SC5
		ON SC5.C5_FILIAL  = SC6.C6_FILIAL
	   AND SC5.C5_NUM     = SC6.C6_NUM
	   AND SC5.%NotDel%
	  LEFT
	  JOIN %table:SA4% SA4
		ON SA4.A4_FILIAL  = %xFilial:SA4%
	   AND SA4.A4_COD     = SC5.C5_TRANSP
	   AND SA4.%NotDel%
	 INNER
	  JOIN %table:SE4% SE4
		ON SE4.E4_FILIAL  = %xFilial:SE4%
	   AND SE4.E4_CODIGO  = SC5.C5_CONDPAG
	   AND SE4.%NotDel%
	 WHERE SC6.C6_FILIAL  = %xFilial:SC6%
	   AND SUBSTRING(SC6.C6_NUMORC,1,6) = %Exp:cNumOrc%
	   AND (C6_QTDVEN - (C6_QTDENT+C6_QTDEMP )) > 0
	   AND SC6.%NotDel%
	 ORDER
	    BY C6_NUM, C6_ITEM
EndSql

//Percorre Query e cria os Objetos
(cAliasQry)->(DbEval({||;
Aadd( aNaoLibe, PrtTrkPedido():New(C6_NUM, C5_CONDPAG+' - '+E4_DESCRI, C5_TRANSP+' - '+A4_NOME,;
C5_TPFRETE+"-"+AllTrim( aBoxtTpFr[ Ascan( aBoxtTpFr, { |x| x[ 2 ] == C5_TPFRETE} ), 3 ]),;
C6_ITEM, C6_PRODUTO, C6_DESCRI, C5_EMISSAO, C6_QTDVEN, C6_UM, C6_PRCVEN, VLRTOTAL) ),;
}))

oObjResp:Add( 'PED_NAO_LIBERADO'     , aNaoLibe )

(cAliasQry)->(DbCloseArea())

//
// Titulos em abertos
//
cAliasQry  := GetNextAlias()
BeginSql Alias cAliasQry
	COLUMN E1_EMISSAO AS DATE
	COLUMN E1_VENCTO  AS DATE
	COLUMN E1_VENCREA AS DATE
	
	SELECT E1_PREFIXO, 
	       E1_NUM, 
		   E1_PARCELA, 
		   E1_TIPO, 
		   E1_EMISSAO, 
		   E1_VENCTO,
		   E1_VENCREA,
		   E1_VALOR, 
		   E1_SALDO, 
		   E1_NUMBCO,
		   E1_SITUACA
	  FROM %table:SE1% SE1
	 WHERE SE1.E1_FILIAL  = %xFilial:SE1%
	   AND SE1.E1_SALDO   > 0
	   AND SE1.E1_CLIENTE = %Exp:cCodCli%
	   AND SE1.E1_LOJA    = %Exp:cLojCli%
	   AND SE1.%NotDel%
	 ORDER
	    BY E1_VENCTO, E1_PREFIXO, E1_NUM, E1_PARCELA
EndSql

// Situações do titulo
Aadd( aBoxtSita, {Nil, '0', 'Carteira'              })
Aadd( aBoxtSita, {Nil, '1', 'Simples'               })
Aadd( aBoxtSita, {Nil, '2', 'Descontada'            })
Aadd( aBoxtSita, {Nil, '4', 'Vinculada'             })
Aadd( aBoxtSita, {Nil, '5', 'c/Advogado'            })
Aadd( aBoxtSita, {Nil, '6', 'Judicial'              })
Aadd( aBoxtSita, {Nil, '7', 'Caucionada Descontada' })

//Percorre Query e cria os Objetos
(cAliasQry)->(DbEval({||;
Aadd( aTitulos, PrtTrkTitulo():New(E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_VALOR, E1_SALDO, E1_NUMBCO, If(E1_VENCREA>=Date(),0,(Date()-E1_VENCREA)),;
E1_SITUACA+"-"+AllTrim( aBoxtSita[ Ascan( aBoxtSita, { |x| x[ 2 ] == E1_SITUACA} ), 3 ])));
}))

oObjResp:Add( 'TITULOS_RECEBER'     , aTitulos )

(cAliasQry)->(DbCloseArea())

// --> Transforma o objeto em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)