#Include 'Totvs.ch'
#Include 'FWPrintSetup.ch'
#Include 'RPTDEF.ch'
#Include 'COLORS.ch'

// Fontes
Static oFont12       := TFont():New("Arial",,10,,.F.,,,,.F.,.F.) //12
Static oFont12N      := TFont():New("Arial",,10,,.T.,,,,.F.,.F.) //12 negrito
Static oFont10       := TFont():New("Arial",,8,,.F.,,,,.F.,.F.) //10
Static oFont10N      := TFont():New("Arial",,8,,.T.,,,,.F.,.F.) //10 negrito

//-------------------------------------------------------------------
/*/{Protheus.doc} CDT020
Impressão do Orçamento de venda

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function CDT020()
Local cPerg  := 'CDT020'

AjustaSX1(cPerg)
If Pergunte(cPerg,.T.)
	// Impressao do Relatorio
	MsAguarde({||sfMontaRel()},"Aguarde...","Gerando relatório...")
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} sfMontaRel
Monta a Impressão do relatorio

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
Static Function sfMontaRel(cFilePrint,lJob)
// Parametros FwMsPrinter
Local cDirPDF       := SuperGetMV('ES_DIRBPDF',.F.,'\PDF\')
Local cPathInServer := cDirPDF
Local lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
// Auxiliares
Local aBoxtTpFr     := RetSx3Box( Posicione('SX3', 2, 'CJ_TPFRETE', 'X3CBox()' ),,, Len(SCJ->CJ_TPFRETE) )
Local cTpFrete      := SCJ->CJ_TPFRETE+"-"+AllTrim( aBoxtTpFr[ Ascan( aBoxtTpFr, { |x| x[ 2 ] == SCJ->CJ_TPFRETE} ), 3 ])
Local cSimbMoed     := SuperGetMV('MV_SIMB' + Alltrim(Str(SCJ->CJ_MOEDA)), .F., 'R$')
Local cDescMoed     := SuperGetMv('MV_MOEDA'+ Alltrim(Str(SCJ->CJ_MOEDA)), .F., 'REAL')

Default cFilePrint  := "ORC_"+Dtos(MSDate())+StrTran(Time(),":","")
Default lJob        := .F.

// Controle de Impressao
Private oPrinter    := Nil
Private nLin        := 0
Private nPag        := 1

// Objeto de Impressao
oPrinter := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, If(lJob,cPathInServer,Nil), .T.,.F.,,"PDF",.T.,.F.,.F.,.F.,)

// Seta parametros de impressao
oPrinter:SetResolution(78)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4)
oPrinter:SetMargin(60,60,60,60)
oPrinter:nDevice  := IMP_PDF
If lJob
	oPrinter:lServer  := 1 // Gera arquivo no server 
	oPrinter:cPathPDF := SuperGetMV('ES_DIRBPDF',.F.,'\PDF\')
Else
	oPrinter:lViewPDF := .T.
	oPrinter:cPathPDF := GetTempPath()
EndIf

// Apaga arquivo caso exista no diretorio
fErase(oPrinter:cPathPDF+cFilePrint+'.pdf')

SCJ->(DbSetOrder(1)) // CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
SCJ->(MsSeek(xFilial('SCJ')+MV_PAR01, .T. ))

Do While SCJ->(! Eof()) .And. (SCJ->CJ_FILIAL+SCJ->CJ_NUM >= xFilial('SCJ')+MV_PAR01) .And. (SCJ->CJ_FILIAL+SCJ->CJ_NUM <= xFilial('SCJ')+MV_PAR02) 
	
	// Posiciona no Cliente
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
	
	// Posiciona no Vendedor
	SA3->(DbSetOrder(1))
	SA3->(MsSeek(xFilial('SA3')+SCJ->CJ_VEND1))
	
	//Posiciona na Transportadora
	SA4->(DbSetOrder(1))
	SA4->(MsSeek(xFilial('SA4')+SCJ->CJ_TRANSP))
	
	//Posiciona na Condição de Pagamento
	SE4->(DbSetOrder(1))
	SE4->(MsSeek(xFilial('SE4')+SCJ->CJ_CONDPAG))
	
	cTpFrete      := SCJ->CJ_TPFRETE+"-"+AllTrim( aBoxtTpFr[ Ascan( aBoxtTpFr, { |x| x[ 2 ] == SCJ->CJ_TPFRETE} ), 3 ])
	cSimbMoed     := SuperGetMV('MV_SIMB' + Alltrim(Str(SCJ->CJ_MOEDA)), .F., 'R$')
	cDescMoed     := SuperGetMv('MV_MOEDA'+ Alltrim(Str(SCJ->CJ_MOEDA)), .F., 'REAL')

	// Imprime Cabeçalho
	sfPrtCab()
	
	// Dados do cliente
	oPrinter:Box( 100, 000, 145, 603)
	oPrinter:Say( 110, 005, 'Cliente: ' , oFont12N)
	oPrinter:Say( 110, 050, SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + AllTrim(SA1->A1_NOME) , oFont12)
	oPrinter:Say( 125, 005, 'Endereço: ', oFont12N)
	oPrinter:Say( 125, 050, AllTrim(IF( !Empty(SA1->A1_ENDENT) ,SA1->A1_ENDENT , SA1->A1_END )) + " - " +;
	                        AllTrim(IF( !Empty(SA1->A1_BAIRROE),SA1->A1_BAIRROE, SA1->A1_BAIRRO )) + " - " +;
	                        AllTrim(IF( !Empty(SA1->A1_MUNE), SA1->A1_MUNE, SA1->A1_MUN ))+ "/"+;
	                        AllTrim(IF( !Empty(SA1->A1_ESTE), SA1->A1_ESTE, SA1->A1_EST )), oFont12)
	
	oPrinter:Say( 140, 005, 'CEP: ' , oFont12N)
	oPrinter:Say( 140, 050, Transform(AllTrim(IF( !Empty(SA1->A1_CEPE), SA1->A1_CEPE, SA1->A1_CEP )),PesqPict("SA1","A1_CEP")), oFont12)
	oPrinter:Say( 140, 200, 'CNPJ/CPF: ', oFont12N)
	oPrinter:Say( 140, 250, Subs(transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))),1,at("%",transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))))-1), oFont12)
	oPrinter:Say( 140, 380, "IE: ", oFont12N)
	oPrinter:Say( 140, 400, SA1->A1_INSCR, oFont12)
	
	// Dados Orçamento
	oPrinter:Box( 145, 000, 205, 603)
	oPrinter:Say( 155, 005, 'Tipo Frete: '     , oFont12N)
	oPrinter:Say( 155, 053, cTpFrete           , oFont12)
	oPrinter:Say( 155, 200, 'Transportadora: ' , oFont12N)
	oPrinter:Say( 155, 268, Alltrim(SCJ->CJ_TRANSP)+' - '+AllTrim(SA4->A4_NOME)   , oFont12)
	oPrinter:Say( 165, 005, 'Cond.Pgto: '      , oFont12N)
	oPrinter:Say( 165, 053, AllTrim(SCJ->CJ_CONDPAG)+' - '+AllTrim(SE4->E4_DESCRI), oFont12)
	
	oPrinter:Say( 175, 005, 'Moeda: '      , oFont12N)
	oPrinter:Say( 175, 053, cSimbMoed+' ('+cDescMoed+')', oFont12)
	
	oPrinter:Say( 190, 005, "O PRAZO MEDIO DE ENTREGA:  " + Alltrim(Posicione("SX5",1,xFilial("SX5")+"12"+SA1->A1_EST,"X5_DESCSPA")) + " APÓS FATURAMENTO", oFont12)
	oPrinter:Say( 200, 005, "O PRAZO DE FATURAMENTO SERÁ ATÉ 7 DIAS ÚTEIS APÓS APROVAÇÃO DO ORÇAMENTO" , oFont12)
	
	nLin := 205
	
	// Impressao dos Itens
	sfPrtItens()
	
	// Finaliza pagina
	oPrinter:EndPage()
	
	SCJ->(DbSkip())
EndDo

oPrinter:Preview()

// Limpa Objeto de impressao
oPrinter := FreeObj(oPrinter)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} sfPrtCab
Impressao do Cabeçalho do Orçamento de Venda

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
Static Function sfPrtCab()
// Imagem Logo
Local cLogo         := FisxLogo("1")

// Inicia Pagina
oPrinter:StartPage()

// Dados da empresa
oPrinter:Box( 000,000,100,450)
oPrinter:SayBitmap(010,005,cLogo,080,080)
oPrinter:Say( 015, 110, FWFilRazSocial(), oFont12N)
oPrinter:Say( 030, 110, AllTrim(SM0->M0_ENDCOB) + " - " + AllTrim(SM0->M0_BAIRCOB) + " - " + AllTrim(SM0->M0_CIDCOB)+ " - " + AllTrim(SM0->M0_ESTCOB), oFont12)
oPrinter:Say( 045, 110, "CNPJ: " + Transform(SM0->M0_CGC,PesqPict("SA1","A1_CGC"))+ " - CEP: " + Transform(AllTrim(SM0->M0_CEPCOB),PesqPict("SA1","A1_CEP")), oFont12)
oPrinter:Say( 060, 110, "www.conducopper.com", oFont12)
oPrinter:Say( 075, 110, "sac@conducopper.com", oFont12)

// Numero Orçamento
oPrinter:Box( 000, 450, 100, 603)
oPrinter:Say( 015, 460, 'Orçamento Nro: '     , oFont12N)
oPrinter:Say( 015, 540, SCJ->CJ_NUM           , oFont12)

oPrinter:Say( 035, 460, 'Data de Emissão: '   , oFont12N)
oPrinter:Say( 035, 540, DtoC(SCJ->CJ_EMISSAO) , oFont12)
oPrinter:Say( 055, 460, 'Vendedor: ', oFont12N)
oPrinter:Say( 055, 505, Capital(Left(SA3->A3_NOME,20)), oFont12)

nLin := 100

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} sfPrtCabIt
Impressao do Cabeçalho dos Itens do Orçamento de Venda

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
Static Function sfPrtCabIt()
// Realiza a Impressão do cabeçalho dos itens
oPrinter:Box( nLin, 000, nLin+15, 603)

nLin += 10
oPrinter:Say( nLin, 005, 'It'                 , oFont10N)
oPrinter:Say( nLin, 020, 'Codigo'             , oFont10N)
oPrinter:Say( nLin, 090, 'Descrição Material' , oFont10N)
oPrinter:Say( nLin, 285, 'UM'                 , oFont10N)
oPrinter:Say( nLin, 340, 'Quant'              , oFont10N)
oPrinter:Say( nLin, 398, 'Vl.Unit'            , oFont10N)
oPrinter:Say( nLin, 439, 'IPI'                , oFont10N)
oPrinter:Say( nLin, 460, 'ICMS'               , oFont10N)
oPrinter:Say( nLin, 508, 'Vl.Tot.C/IPI'       , oFont10N)
oPrinter:Say( nLin, 560, 'Prev.Fat'           , oFont10N)

nLin += 5

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} sfPrtItens
Impressao dos Itens do Orçamento de Venda

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
Static Function sfPrtItens()
// Auxiliares
Local aDescri       := {}
Local nCntFor1      := 0
Local nCntFor2      := 0
Local aRelImp       := MaFisRelImp("MT100",{"SF2","SD2"})
Local nItem         := 0
Local aLinha        := {}
Local aItens        := {}
Local nValMerc      := 0
Local nPrcLista     := 0
Local nAcresFin     := 0
Local nDesconto     := 0
// Totalizadores
Local nTotQtd       := 0
Local nTotVal       := 0
Local nPesLiq       := 0
Local nPesBru       := 0

//
// Calculo do Impostos
//
MaFisSave()
MaFisEnd()
MaFisIni(SCJ->CJ_CLIENTE,;// 1-Codigo Cliente/Fornecedor
	SCJ->CJ_LOJA,; // 2-Loja do Cliente/Fornecedor
	"C",; // 3-C:Cliente , F:Fornecedor
	"N",; // 4-Tipo da NF
	SA1->A1_TIPO,;// 5-Tipo do Cliente/Fornecedor
	aRelImp,; // 6-Relacao de Impostos que suportados no arquivo
	Nil,;
	Nil,;
	"SB1",;
	"MATA461",;
	Nil,;
	Nil,;
	"")

// Seta Ordem de pesquisa das tabelas
SB1->(DbSetOrder(1))
SF4->(DbSetOrder(1))

// Laço nos itens do orçamento para calculo dos impostos
SCK->(DbSetOrder(1))
SCK->(MsSeek(xFilial('SCK')+SCJ->CJ_NUM))
Do While SCK->(! Eof()) .And. SCK->(CK_FILIAL+CK_NUM) == xFilial('SCK')+SCJ->CJ_NUM
	nItem++
	
	// Posiciona no Produto
	SB1->(MsSeek(xFilial('SB1')+SCK->CK_PRODUTO))
	
	// Posiciona na TES
	SF4->(MsSeek(xFilial('SF4')+SCK->CK_TES))
	
	//-----------------------------------------------
	// Calcula o preco de lista
	//-----------------------------------------------
	nValMerc  := SCK->CK_VALOR
	nPrcLista := SCK->CK_PRUNIT
	If ( nPrcLista == 0 )
		nPrcLista := NoRound(nValMerc/SCK->CK_QTDVEN,TamSX3("CK_PRCVEN")[2])
	EndIf
	nAcresFin := A410Arred(SCK->CK_PRCVEN*0/100,"D2_PRCVEN")
	nValMerc  += A410Arred(SCK->CK_QTDVEN*nAcresFin,"D2_TOTAL")		
	nDesconto := a410Arred(nPrcLista*SCK->CK_QTDVEN,"D2_DESCON")-nValMerc
	nDesconto := IIf(nDesconto==0,SCK->CK_VALDESC,nDesconto)
	nDesconto := Max(0,nDesconto)
	nPrcLista += nAcresFin
	nValMerc  += nDesconto
	
	//-----------------------------------------------
	// Agrega os itens para a funcao fiscal
	//-----------------------------------------------
	MaFisAdd(SCK->CK_PRODUTO,;   	// 1-Codigo do Produto ( Obrigatorio )
		SCK->CK_TES,;	   	// 2-Codigo do TES ( Opcional )
		SCK->CK_QTDVEN,;  	// 3-Quantidade ( Obrigatorio )
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
	// Calculo do ISS
	//-----------------------------------------------
	If SA1->A1_INCISS == "N" 
		If ( SF4->F4_ISS=="S" )
			nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
			nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
			MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
			MaFisAlt("IT_VALMERC",nValMerc,nItem)
		EndIf
	EndIf
	
	// Vetor com os itens para impressao
	aLinha := {}
	Aadd(aLinha, SCK->CK_ITEM)    // 1. Item  
	Aadd(aLinha, SCK->CK_PRODUTO) // 2. Produto
	Aadd(aLinha, SCK->CK_UM)      // 3. Unidade de Medida
	Aadd(aLinha, SCK->CK_QTDVEN)  // 4. Quantidade
	Aadd(aLinha, SCK->CK_PRCVEN)  // 5. Preço de venda
	Aadd(aLinha, SCK->CK_VALOR)   // 6. Valor
	Aadd(aLinha, SCK->CK_ENTREG)  // 7. Data Faturamento
	Aadd(aLinha, SCK->CK_DESCRI)  // 8. Data Faturamento
	Aadd(aLinha, SB1->B1_PESO)    // 9. Peso Liquido
	Aadd(aLinha, SB1->B1_PESBRU)  // 10. Pedo bruto
	Aadd(aItens, aLinha)
	
	SCK->(DbSkip())
EndDo

MaFisAlt("NF_FRETE"   ,SCJ->CJ_FRETE)
MaFisAlt("NF_SEGURO"  ,SCJ->CJ_SEGURO)
MaFisAlt("NF_AUTONOMO",SCJ->CJ_FRETAUT)
MaFisAlt("NF_DESPESA" ,SCJ->CJ_DESPESA)

If SCJ->CJ_DESCONT > 0
	MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,SCJ->CJ_DESCONT+MaFisRet(,"NF_DESCONTO")))
EndIf
If SCJ->CJ_PDESCAB > 0
	MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*CJ->CJ_PDESCAB/100,"CK_VALOR")+MaFisRet(,"NF_DESCONTO"))
EndIf
MaFisWrite()

// Imprime Cabeçalho dos itens
sfPrtCabIt()

// Realiza a Impressão dos itens
For nCntFor1 := 1 To Len(aItens)
	
	If nLin > 660
		oPrinter:EndPage() //Finaliza Pagina Atual
		// Inicia nova Pagina
		nPag ++
		sfPrtCab() // Impreme cabeçalho
		
		sfPrtCabIt() // Imprime Cabeçalho dos Itens
	EndIf
	
	nLin += 10
	
	nValImp	:=	MaFisRet(nCntFor1,"IT_VALIPI")

	oPrinter:Say( nLin, 005, aItens[nCntFor1][1]                                                      , oFont10)
	oPrinter:Say( nLin, 020, AllTrim(aItens[nCntFor1][2])                                             , oFont10)
	
	oPrinter:Say( nLin, 285, aItens[nCntFor1][3]                                                      , oFont10)
	oPrinter:SayAlign( nLin-8, 305, Transform(aItens[nCntFor1][4],PesqPictQt("CK_QTDVEN"))            , oFont10,60,10,,1) // Alinha a direita
    oPrinter:SayAlign( nLin-8, 375, Transform(aItens[nCntFor1][5],PesqPict("SCK","CK_PRCVEN"))        , oFont10,50,10,,1) // Alinha a direita
	oPrinter:SayAlign( nLin-8, 430, Transform(MaFisRet(nCntFor1,"IT_ALIQIPI"),"@E 99.99")             , oFont10,20,10,,1) // Alinha a direita
	oPrinter:SayAlign( nLin-8, 460, Transform(MaFisRet(nItem,"IT_ALIQICM"),"@E 99.99")                , oFont10,20,10,,1) // Alinha a direita
    oPrinter:SayAlign( nLin-8, 490, Transform(aItens[nCntFor1][6]+nValImp,PesqPict("SCK","CK_VALOR")) , oFont10,60,10,,1) // Alinha a direita
	
	oPrinter:Say( nLin, 560, DtoC(aItens[nCntFor1][7])                                                , oFont10)
	
	// Imprime a descrição com quebra de linha
	aDescri := sfQuebLin(aItens[nCntFor1][8], 43)
	For nCntFor2 := 1 To Len(aDescri)
		oPrinter:Say( nLin, 090, AllTrim(aDescri[nCntFor2])                                           , oFont10)
		If nCntFor2 < Len(aDescri)
			nLin += 10
		EndIf
	Next nCntFor2
	
	// Acumula Totalizadores
	nTotQtd += aItens[nCntFor1][4]
	nTotVal += aItens[nCntFor1][6]+nValImp
	nPesLiq	+= aItens[nCntFor1][9]  * aItens[nCntFor1][4]
	nPesBru += aItens[nCntFor1][10] * aItens[nCntFor1][4]

Next nCntFor1

// Realiza a Impressão do cabeçalho dos itens
nLin += 10
oPrinter:Box( nLin, 000, nLin+15, 603)
nLin += 10
oPrinter:Say( nLin, 005, 'TOTAIS'                                             , oFont10N)
oPrinter:SayAlign( nLin-8, 305, Transform(nTotQtd,PesqPictQt("CK_QTDVEN"))    , oFont10N,60,10,,1) // Alinha a direita
oPrinter:SayAlign( nLin-8, 490, Transform(nTotVal,PesqPict("SCK","CK_VALOR")) , oFont10N,60,10,,1) // Alinha a direita

nLin += 5

//
// Totais dos Impostos / Peso
//

nLin += 20

oPrinter:Say(nLin, 350, 'Impostos'    , oFont10N)
nLin += 10
oPrinter:Say(nLin, 005, 'Peso bruto:'   , oFont10N)
oPrinter:SayAlign( nLin-8, 050, Transform(nPesBru,'@E 99,999,999.99'), oFont10,60,10,,1) // Alinha a direita

oPrinter:Say(nLin, 350, 'Base Icms:'   , oFont10)
oPrinter:SayAlign( nLin-8, 390, Transform(MaFisRet(,"NF_BASEICM"),PesqPict("SF2","F2_BASEICM")), oFont10,60,10,,1) // Alinha a direita
oPrinter:Say(nLin, 480, 'Valor Icms:'  , oFont10)
oPrinter:SayAlign( nLin-8, 530, Transform(MaFisRet(,"NF_VALICM") ,PesqPict("SF2","F2_VALICM") ), oFont10,60,10,,1) // Alinha a direita

nLin += 10
oPrinter:Say(nLin, 005, 'Peso liquido:' , oFont10N)
oPrinter:SayAlign( nLin-8, 050, Transform(nPesLiq,'@E 99,999,999.99'), oFont10,60,10,,1) // Alinha a direita

oPrinter:Say(nLin, 350, 'Base Ipi:'    , oFont10)
oPrinter:SayAlign( nLin-8, 390, Transform(MaFisRet(,"NF_BASEIPI"),PesqPict("SF2","F2_BASEIPI")), oFont10,60,10,,1) // Alinha a direita
oPrinter:Say(nLin, 480, 'Valor Ipi:'   , oFont10)
oPrinter:SayAlign( nLin-8, 530, Transform(MaFisRet(,"NF_VALIPI") ,PesqPict("SF2","F2_VALIPI") ), oFont10,60,10,,1) // Alinha a direita

nLin += 10
oPrinter:Say(nLin, 350, 'Base Retido:' , oFont10)
oPrinter:SayAlign( nLin-8, 390, Transform(MaFisRet(,"NF_BASESOL"),PesqPict("SF2","F2_ICMSRET")), oFont10,60,10,,1) // Alinha a direita
oPrinter:Say(nLin, 480, 'Valor Retido:', oFont10)
oPrinter:SayAlign( nLin-8, 530, Transform(MaFisRet(,"NF_VALSOL") ,PesqPict("SF2","F2_VALBRUT")), oFont10,60,10,,1) // Alinha a direita

nLin += 10
oPrinter:Say(nLin, 480, 'Valor Total:', oFont10N)
oPrinter:SayAlign( nLin-8, 530, Transform(MaFisRet(,"NF_TOTAL")  ,PesqPict("SF2","F2_VALBRUT")), oFont10N,60,10,,1) // Alinha a direita

// Imprime Rodape
sfPrtRoda()

MaFisEnd()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} sfPrtRoda
Impressao do Rodape

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
Static Function sfPrtRoda()

nLin := 800

oPrinter:Say(nLin,005,'Nome/Assinatura:____________________________________________',oFont12N)
oPrinter:Say(nLin,310,'Nome/Assinatura:____________________________________________',oFont12N)

nLin += 10
oPrinter:Say(nLin,145,'(Cliente)' ,oFont10)
oPrinter:Say(nLin,450,'(Vendedor)',oFont10)

nLin += 20
oPrinter:Say(nLin,361,'Qualquer dúvida favor contactar-nos através do fone: 11 2066.9090',oFont10)
nLin += 20
oPrinter:Say(nLin,470,'Impresso em: '+AllTrim(DtoC(Date()))+" - "+ Time(),oFont10)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} sfQuebLin
Quebra a string em mais de uma linha, conforme o tamanho limite
definido nos parametros

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
Static Function sfQuebLin(cAux, nMaxCol)
Local aRet := {}

Do While !Empty(cAux)
	aadd(aRet,SubStr(cAux,1,IIf(sfEspacoAt(cAux, nMaxCol) > 1, sfEspacoAt(cAux, nMaxCol) - 1, nMaxCol)))
	cAux := SubStr(cAux,IIf(sfEspacoAt(cAux, nMaxCol) > 1, sfEspacoAt(cAux, nMaxCol), nMaxCol) + 1)
EndDo

Return(aRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} sfEspacoAt
Pega uma posição (nTam) na string cString, e retorna o caractere 
de espaço anterior.

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
Static Function sfEspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

/**
* Caso a posição (nTam) for maior que o tamanho da string, ou for um valor
* inválido, retorna 0.
*/
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

/**
* Procura pelo caractere de espaço anterior a posição e retorna a posição
* dele.
*/
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

/**
* Caso não encontre nenhum caractere de espaço, é retornado 0.
*/
nRetorno := 0

Return nRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} CDT020JOB
Impressão do Orçamento de venda via Job

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function CDT020JOB(cNumOrc)
Local cFilePrint    := 'Orcamento_'+FwFilial()+'_'+cNumOrc
Local cPerg         := 'CDT020'

Pergunte(cPerg,.F.)
MV_PAR01 := cNumOrc
MV_PAR02 := cNumOrc

// Impressao do Relatorio
sfMontaRel(cFilePrint,.T.)

Return(cFilePrint)

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria pergunta para o grupo

@author Felipe Toledo
@since 22/07/17
@type Function
/*/
//-------------------------------------------------------------------
Static Function AjustaSX1(cPerg)
Local aAreaAnt := GetArea()

//---------------------------------------MV_PAR01--------------------------------------------------
PutSX1( cPerg,"01","Do Orçamento ?","","","mv_ch1","C",Tamsx3("CJ_NUM")[1],0,0,"G","","","","",;
		"mv_par01","","","","","","","","","","","","","","","","")

//---------------------------------------MV_PAR02--------------------------------------------------
PutSX1( cPerg,"02","Ate o Orçamento ?","","","mv_ch2","C",Tamsx3("CJ_NUM")[1],0,0,"G","","","","",;
		"mv_par02","","","","","","","","","","","","","","","","")


RestArea(aAreaAnt)
Return Nil