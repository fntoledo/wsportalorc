#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTORCAMENTO
Serviço REST de orcamento de venda para o portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTORCAMENTO DESCRIPTION "Serviço REST de orcamento de venda para o portal de vendas"

WSMETHOD GET DESCRIPTION "Retorna informações do orcamento de venda para o portal de vendas" WSSYNTAX "/PRTORCAMENTO/{codigo_orcamento} "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET
Processa as informações e retorna o json
@author Felipe Toledo
@since 07/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSSERVICE PRTORCAMENTO
Local cJson      := ''
Local oObjResp   := PrtOrcamento():New() // --> Objeto que será serializado
Local cNumOrc    := ''
Local aBoxStat   := RetSx3Box( Posicione('SX3', 2, 'CJ_STATUS', 'X3CBox()' ),,, Len(SCJ->CJ_STATUS) )
Local cStatus    := ''
Local aBoxtTpFr  := RetSx3Box( Posicione('SX3', 2, 'CJ_TPFRETE', 'X3CBox()' ),,, Len(SCJ->CJ_TPFRETE) )
Local cTpFrete   := ''
Local cAliasQry  := GetNextAlias()
Local lRet       := .T.

//-------------------------------------------------------------
// Filtro na seleção dos registros
//-------------------------------------------------------------
If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[1])
	cNumOrc := PadR(AllTrim(::aUrlParms[1]),TamSX3('CJ_NUM')[1]) // Recebe o numero do orcamento
Else
	SetRestFault(400, "Codigo do orcamento nao informado nos parametros")
	lRet := .F.
EndIf

If lRet
	SCJ->(DbSetOrder(1)) // CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
	If SCJ->(MsSeek(xFilial('SCJ')+cNumOrc))
		SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
		SA1->(MsSeek(xFilial('SA1')+SCJ->(CJ_CLIENTE+CJ_LOJA)))
	
		cStatus  := SCJ->CJ_STATUS +"-"+AllTrim(  aBoxStat[ Ascan( aBoxStat,  { |x| x[ 2 ] == SCJ->CJ_STATUS}  ), 3 ])
		cTpFrete := SCJ->CJ_TPFRETE+"-"+AllTrim( aBoxtTpFr[ Ascan( aBoxtTpFr, { |x| x[ 2 ] == SCJ->CJ_TPFRETE} ), 3 ])

		// Objeto que será serializado
		oObjResp:AddCab( PrtCabOrcamento():New(SCJ->CJ_NUM,;
		                             SCJ->CJ_EMISSAO,;
		                             SCJ->CJ_CLIENTE,;
		                             SCJ->CJ_LOJA,;
		                             SA1->A1_NOME,;
		                             SA1->A1_CGC,;
		                             cStatus,;
		                             SCJ->CJ_CONDPAG,;
		                             SCJ->CJ_TABELA,;
		                             SCJ->CJ_VEND1,;
		                             cTpFrete) )

		// Seleciona Itens
		BeginSql Alias cAliasQry
			COLUMN CK_ENTREG AS DATE
			
			SELECT CK_ITEM, CK_PRODUTO, CK_DESCRI, CK_UM, B1_SEGUM, CK_QTDVEN, CK_UNSVEN, CK_PRCVEN, CK_VALOR, CK_ENTPROG, CK_ENTREG
			  FROM %Table:SCK% SCK
			 INNER
			  JOIN %Table:SB1% SB1
			    ON SB1.B1_FILIAL = %xFilial:SB1%
			   AND SB1.B1_COD    = SCK.CK_PRODUTO
			   AND SB1.%notDel%
			 WHERE SCK.CK_FILIAL = %xFilial:SCK%
			   AND SCK.CK_NUM    = %Exp:SCJ->CJ_NUM%
			   AND SCK.%notDel%
			 ORDER
			    BY CK_ITEM
		EndSql
		
		If (cAliasQry)->(! Eof())
			//Cria um objeto da classe produtos para fazer a serialização na função FWJSONSerialize
			(cAliasQry)->(DbEval({||;
			oObjResp:AddItem(PrtItensOrcamento():New( CK_ITEM,;
			                                          CK_PRODUTO,;
			                                          CK_DESCRI,;
			                                          CK_UM,;
			                                          B1_SEGUM,;
			                                          CK_QTDVEN,;
			                                          CK_UNSVEN,;
			                                          CK_PRCVEN,;
			                                          CK_VALOR,;
			                                          CK_ENTPROG,;
			                                          CK_ENTREG) );
			}))

		Else
			SetRestFault(400, "Orcamento nao possui itens")
			lRet := .F.			
		EndIf
		
		(cAliasQry)->(DbCloseArea())
		
	Else
		SetRestFault(400, "Orcamento nao localizado")
		lRet := .F.
	EndIf
EndIf

// --> Transforma o objeto de produtos em uma string json
cJson := FWJsonSerialize(oObjResp,.F.)

// define o tipo de retorno do método
::SetContentType("application/json")

// --> Envia o JSON Gerado para a aplicação Client
::SetResponse(cJson)

Return(lRet)