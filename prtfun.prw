#Include 'totvs.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} PRTFUN
Biblioteca de funções do portal de vendas

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PRTFUN()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtVldUsr
Valida CODIGO do usuário do Portal

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtVldUsr(cUsrPrt)
Local lRet     := .F.

// Valida Usuário
If Empty(cUsrPrt)
	// Codigo do usuario nao informado
	lRet := .F.
Else
	// verifica se o usuário esta cadastrado como representante
	AI3->(DbSetOrder(1)) // AI3_FILIAL+AI3_CODUSU
	If AI3->(MsSeek(xFilial('AI3')+cUsrPrt))
		lRet := .T.
	Else
		// Codigo usuário invalido
		lRet := .F.
	EndIf
EndIf

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PrtAuth
Autentica o Usuário do Portal

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtAuth(cUsrPrt,cPassPrt)
Local lRet      := .F.

// Valida usuário
If !Empty(cUsrPrt) .And. !Empty(cPassPrt)
	cUsrPrt   := Decode64(cUsrPrt)
	cPassPrt  := Decode64(cPassPrt)

	AI3->(DbSetOrder(2)) // AI3_FILIAL+AI3_LOGIN
	If AI3->(MsSeek(xFilial('AI3')+cUsrPrt))

		If Alltrim(cPassPrt) == AllTrim(AI3->AI3_PSW)
			lRet := .T.
		EndIf
		
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtCodVen
Codigo de vendedor do usuário logado

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtCodVen(cUsrPrt)
Local cRet       := "" 

// verifica se o usuário esta cadastrado como representante
AI3->(DbSetOrder(1)) // AI3_FILIAL+AI3_CODUSU
If AI3->(MsSeek(xFilial('AI3')+cUsrPrt))
	cRet := AI3->AI3_ZCODVE
EndIf

Return(cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PrtLogAc
Grava log ultimo acesso do usuário

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtLogAc(cUsrPrt)

// verifica se o usuário esta cadastrado como representante
AI3->(DbSetOrder(2)) // AI3_FILIAL+AI3_LOGIN
If AI3->(MsSeek(xFilial('AI3')+cUsrPrt))
	AI3->(RecLock('AI3',.F.))
	AI3->AI3_ZDTULT := Date()
	AI3->AI3_ZHRULT := Time()
	AI3->(MsUnLock())
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtAltPas
Altera a senha do usuário

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtAltPas(cUsrPrt, cNewPas)

// verifica se o usuário esta cadastrado como representante
AI3->(DbSetOrder(2)) // AI3_FILIAL+AI3_LOGIN
If AI3->(MsSeek(xFilial('AI3')+cUsrPrt))
	AI3->(RecLock('AI3',.F.))
	AI3->AI3_PSW   := cNewPas
	AI3->(MsUnLock())
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtImpos
Calcula a previsão dos impostos do orçamento de venda

@author Felipe Toledo
@since 10/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtImpos(cCodCli, cLojCli, cCondPag, aItensOrc)
Local nPrcLista := 0
Local nValMerc  := 0
Local nDesconto := 0
Local nAcresFin := 0
Local cTes      := ''
Local aVetImp   := {}
Local nValTot   := 0
Local aRet      := {}

//-----------------------------------------------
// Itens do Orçamento
//
// aItensOrc
//   [1] Codigo Produto
//   [2] Quantidade vendida 1a. un
//   [3] Preço unitário da venda
//   [4] Preço de Lista
//   [5] TES para calculo
//-----------------------------------------------

//-----------------------------------------------
// Posiciona Registros
//-----------------------------------------------
SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
SA1->(MsSeek(xFilial("SA1")+cCodCli+cLojCli))

SE4->(DbSetOrder(1)) // E4_FILIAL+E4_CODIGO
SE4->(MsSeek(xFilial("SE4")+cCondPag))

MaFisSave()
MaFisEnd()
MaFisIni(cCodCli,;// 1-Codigo Cliente/Fornecedor
	cLojCli,;     // 2-Loja do Cliente/Fornecedor
	"C",;         // 3-C:Cliente , F:Fornecedor
	"N",;         // 4-Tipo da NF
	SA1->A1_TIPO,;// 5-Tipo do Cliente/Fornecedor
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	"MATA461",;
	Nil,;
	Nil,;
	"")

// Percorre itens
For nCntFor := 1 To Len(aItensOrc)

	//-----------------------------------------------
	//³Posiciona Registros
	//-----------------------------------------------
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
	SB1->(MsSeek(xFilial("SB1")+aItensOrc[nCntFor][1]))

	// Verifica TES Inteligente, caso a TES não for informada
	If !Empty(aItensOrc[nCntFor][5])
		cTes := aItensOrc[nCntFor][5]
	Else
		cTes := MaTesInt(2,'01', cCodCli, cLojCli,"C", aItensOrc[nCntFor][1], NIL)
	EndIf
	
	SF4->(dbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4")+cTes))

	//-----------------------------------------------
	// Calcula o preco de lista
	//-----------------------------------------------
	nValMerc  := A410Arred(aItensOrc[nCntFor][2] * aItensOrc[nCntFor][3],"CK_VALOR")
	nPrcLista := aItensOrc[nCntFor][4]
	
	If ( nPrcLista == 0 )
		nPrcLista := A410Arred(nValMerc/aItensOrc[nCntFor][2],"CK_PRCVEN")
	EndIf
	nAcresFin := A410Arred(aItensOrc[nCntFor][3]*SE4->E4_ACRSFIN/100,"D2_PRCVEN")
	nValMerc  += A410Arred(nAcresFin*aItensOrc[nCntFor][2],"D2_TOTAL")
	nDesconto := A410Arred(nPrcLista*aItensOrc[nCntFor][2],"D2_DESCON")-nValMerc
	nPrcLista += nAcresFin
	
	nValMerc  += nDesconto

	//-----------------------------------------------
	// Agrega os itens para a funcao fiscal
	//-----------------------------------------------
	MaFisAdd(aItensOrc[nCntFor][1],;   	// 1-Codigo do Produto ( Obrigatorio )
		cTes,;	   	// 2-Codigo do TES ( Opcional )
		aItensOrc[nCntFor][2],;  	// 3-Quantidade ( Obrigatorio )
		nPrcLista,;		  	// 4-Preco Unitario ( Obrigatorio )
		nDesconto,; 	// 5-Valor do Desconto ( Opcional )
		"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
		"",;				// 7-Serie da NF Original ( Devolucao/Benef )
		0,;					// 8-RecNo da NF Original no arq SD1/SD2
		0,;					// 9-Valor do Frete do Item ( Opcional )
		0,;					// 10-Valor da Despesa do item ( Opcional )
		0,;					// 11-Valor do Seguro do item ( Opcional )
		0,;					// 12-Valor do Frete Autonomo ( Opcional )
		nValMerc,;			// 13-Valor da Mercadoria ( Obrigatorio )
		0,;					// 14-Valor da Embalagem ( Opiconal )
		, , , , , , , , , , , , ,;
		AllTrim(SB1->B1_ORIGEM) + Alltrim(SF4->F4_SITTRIB)) // 28-Classificacao fiscal)

	//-----------------------------------------------
	//³Calculo do ISS
	//-----------------------------------------------
	If SA1->A1_INCISS == "N" 
		If ( SF4->F4_ISS=="S" )
			nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nCntFor)/100)),"D2_PRCVEN")
			nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nCntFor)/100)),"D2_PRCVEN")
			MaFisAlt("IT_PRCUNI",nPrcLista,nCntFor)
			MaFisAlt("IT_VALMERC",nValMerc,nCntFor)
		EndIf
	EndIf
	
Next nCntFor

//-----------------------------------------------
// Indica os valores do cabecalho
//-----------------------------------------------
MaFisAlt("NF_FRETE",0)
MaFisAlt("NF_SEGURO",0)
MaFisAlt("NF_AUTONOMO",0)
MaFisAlt("NF_DESPESA",0)
MaFisAlt("NF_DESCONTO",0)
MaFisWrite(1)

//----------------------------
// 1-Imposto
// 2-Descricao
// 3-Base
// 4-Aliquota
// 5-Valor
// 6-Tipo imposto
//----------------------------
aVetImp := MaFisRet(,"NF_IMPOSTOS")

// Valor Total
nValTot := MaFisRet(,"NF_TOTAL") // Valor da Nota

MaFisEnd()
MaFisRestore()

If Len(aVetImp) > 0 .And. nValTot > 0
	aRet := {nValtot,aVetImp}
EndIf

/*
// Exemplo de chamado da rotina
aItensOrc := {}
Aadd(aItensOrc, {'7899658703028  ',3050,0.43,0.43,Nil})
Aadd(aItensOrc, {'7899658703035  ',5185,0.43,0.43,Nil})
Aadd(aItensOrc, {'7899658703233  ',1800,0.48,0.48,Nil})
Aadd(aItensOrc, {'7899658703295  ',2000,0.46,0.46,Nil})
Aadd(aItensOrc, {'7899658704605  ',4000,0.41,0.41,Nil})

U_PrtImpos("021", "01", "021", aItensOrc)
*/

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtEnvOrc
Envia Orçamento de Venda por E-mail

@author Felipe Toledo
@since 23/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtEnvOrc(cEmp, cFil, cNumOrc, cEmail, cUsrPrt)
Local cDirPDF       := ''
Local cFilePrint    := ''
Local cFileAttac    := ''
Local oProcWF       := Nil
Local cUrlLogo      := ''
Local lRet          := .F.

// Setar ambiente para não consumir licença.
RpcSetType(3)
RpcSetEnv(cEmp,cFil,,,'FAT')

cDirPDF   := SuperGetMV('ES_DIRBPDF',.F.,'\PDF\')
cUrlLogo  := SuperGetMV('ES_URLLOGO',.F.,'http://www.condutti.com.br/img/logo_condutti.png')

// Gera PDF do Orçamento de venda
cFilePrint := U_CDT020JOB(cNumOrc, cUsrPrt)

cFileAttac := cDirPDF+cFilePrint+'.pdf'

If File(cFileAttac)
	oProcWF := TWFProcess():New("ORCVENDA","ENVIO DE ORCAMENTO DE VENDA")
	oProcWF:NewTask("ORCVENDA","\workflow\orcvenda.html")
	oProcWF:cSubject := '[ONLINE] - Orçamento de venda: ' + cNumOrc
	oProcWF:cTo      := cEmail // 'felipenunestoledo@gmail.com'
	
	oProcWF:oHTML:ValByName("cUrlLogo",AllTrim(cUrlLogo))
	oProcWF:oHTML:ValByName("cNumOrc",cNumOrc)
	oProcWF:oHTML:ValByName("cEmpresa",AllTrim(FWFilRazSocial()))
	
	// Envia Orçamento por e-mail
	oProcWF:AttachFile(cFileAttac)
	
	oProcWF:Start()
	WFSendMail()
	oProcWF:Finish()
	oProcWF := FreeObj(oProcWF)
	
	lRet := .T.
EndIf

Return(lRet)

/*
User Function PrtTstEnv()
//U_PrtEnvOrc('99','01','000496', 'felipenunestoledo@gmail.com')
StartJob('U_PrtEnvOrc','VBIEED',.F.,'02','0201','000496', 'felipenunestoledo@gmail.com')
Return
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtEnvOrc
Envia Orçamento de Venda por E-mail

@author Felipe Toledo
@since 23/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtEnvPas(cEmp, cFil, cEmail, cNomeUsr, cNewPass)
Local cDirPDF       := ''
Local cFilePrint    := ''
Local cFileAttac    := ''
Local oProcWF       := Nil
Local cUrlLogo      := ''
Local lRet          := .T.

// Setar ambiente para não consumir licença.
RpcSetType(3)
RpcSetEnv(cEmp,cFil,,,'FAT')

cUrlLogo  := SuperGetMV('ES_URLLOGO',.F.,'http://www.condutti.com.br/img/logo_condutti.png')

oProcWF := TWFProcess():New("ORCVENDA","RECUPERACAO SE SENHA")
oProcWF:NewTask("ORCVENDA","\workflow\recpass.html")
oProcWF:cSubject := '[ONLINE] - Recupeção de senha '
oProcWF:cTo      := cEmail // 'felipenunestoledo@gmail.com'

oProcWF:oHTML:ValByName("cUrlLogo",AllTrim(cUrlLogo))
oProcWF:oHTML:ValByName("cNomeUsr",AllTrim(cNomeUsr))
oProcWF:oHTML:ValByName("cNewPass",AllTrim(cNewPass))
oProcWF:oHTML:ValByName("cEmpresa",AllTrim(FWFilRazSocial()))

oProcWF:Start()
WFSendMail()
oProcWF:Finish()
oProcWF := FreeObj(oProcWF)

Return(lRet)