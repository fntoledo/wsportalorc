#Include 'totvs.ch'
#Include 'parmtype.ch'
#Include "RestFul.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTAPROVAORCAMENTO
Serviço REST de aprovação do orcamento de venda para o portal de vendas

@author Felipe Toledo
@since 15/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSRESTFUL PRTAPROVAORCAMENTO DESCRIPTION "Serviço REST de aprovação do orcamento de venda para o portal de vendas"

WSMETHOD POST   DESCRIPTION "Aprovação do orçamento de venda vindo do portal de vendas" WSSYNTAX "/PRTAPROVAORCAMENTO/{codigo_orcamento} "
 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST
Aprovação do Orçamento de Venda

@author Felipe Toledo
@since 15/07/17
@type Method
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE PRTAPROVAORCAMENTO
Local cJson      := ''
Local oObjResp   := Nil
Local cNumOrc    := ''
Local aBoxStat   := RetSx3Box( Posicione('SX3', 2, 'CJ_STATUS', 'X3CBox()' ),,, Len(SCJ->CJ_STATUS) )
Local cStatus    := ''
Local aCabec     := {}
Local aItens     := {}
Local lRet       := .T.

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

// necessário declarar. O WebService não esta iniciando a variavel publica __LOCALDRIVE
__LOCALDRIVE := "DBFCDX"

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
		
		If SCJ->CJ_STATUS <> 'A'
			cStatus  := SCJ->CJ_STATUS +"-"+AllTrim(  aBoxStat[ Ascan( aBoxStat,  { |x| x[ 2 ] == SCJ->CJ_STATUS}  ), 3 ])
			SetRestFault(400, "Orcamento no status: "+cStatus+" nao pode ser aprovado")
			lRet := .F.
		EndIf
		
		If lRet 
			AAdd(aCabec ,{"CJ_NUM" ,cNumOrc, Nil})
			
			MSExecAuto({ |X, Y| MATA416(X, Y) }, aCabec, aItens)

			If lMsErroAuto
				aErro := GetAutoGRLog()
			
				cErro := ""
				For nX := 1 To Len(aErro)
					cErro += aErro[nX] + Chr(13)+Chr(10)
				Next nX
				
				cErro := EncodeUtf8(cErro)
			
				SetRestFault(400, cErro)
				lRet := .F.
			Else
				// Posiciona no primeiro item do Orçamento
				SCK->(DbSetOrder(1)) // CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
				SCK->(MsSeek(xFilial('SCK')+cNumOrc))
				
				cStatus  := SCJ->CJ_STATUS +"-"+AllTrim(  aBoxStat[ Ascan( aBoxStat,  { |x| x[ 2 ] == SCJ->CJ_STATUS}  ), 3 ])
				
				// Objeto que será serializado
				oObjResp := PrtAprovaOrcamento():New(cNumOrc,;
				                             cStatus,;
				                             SCK->CK_NUMPV)
			EndIf
		EndIf
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