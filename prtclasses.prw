#include 'totvs.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} PrtClasses
Classes para o serialização de ojetos portal de venda

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
User Function PrtClasses()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtLogin
Classe de login para realizar a serialização do objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtLogin
	
	Data cUsuario           As String
	Data cCodigo            As String
	Data cNome_Completo     As String
	Data cEmail             As String
	Data cCodigo_Vendedor   As String
	Data dData_Ult_Acesso   As Date  
	Data cHora_Ult_Acesso   As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//

Method New(cNomeUsr, cCodUsr, cFullName, cEMail, cCodVen, dDtUltAc, cHrUltAc) Class PrtLogin
	::cUsuario               := cNomeUsr
	::cCodigo                := cCodUsr
	::cNome_completo         := cFullName
	::cEmail                 := cEMail
	::cCodigo_Vendedor       := cCodVen
	::dData_Ult_Acesso       := DtoC(dDtUltAc)
	::cHora_Ult_Acesso       := cHrUltAc
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtListaProdutos
Classe de Lista de Produtos para realizar a serialização do objeto 

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtListaProdutos
	
	Data Produtos
	Data nTotalRegistros   As Integer
	Data nRegistrosPag     As Integer
	
	Method New() Constructor
	Method Add() 
	Method SetTotReg() 
	Method SetRegPag() 
	
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtListaProdutos
	::Produtos := {}
Return(Self)

//
// Adiciona um novo item
//
Method Add(oProduto) Class PrtListaProdutos
	Aadd(::Produtos, oProduto)
Return

//
// Informa Total de Registros
//
Method SetTotReg(nTotReg) Class PrtListaProdutos
	::nTotalRegistros  := nTotReg
Return

//
// Informa quantidade de Registros na Pagina
//
Method SetRegPag(nRegPag) Class PrtListaProdutos
	::nRegistrosPag  := nRegPag
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItListaProdutos
Classe de Lista de Produtos para realizar a serialização do objeto
referente a um item na lista de produtos 
@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItListaProdutos
	
	Data cCodigo            As String
	Data cDescricao         As String
	Data nSldDisp           As Float
	Data nQtdPrevEntrada    As Float

	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodProd, cDesProd, nSldDisp, nQtPrvEnt) Class PrtItListaProdutos
	::cCodigo                := AllTrim(cCodProd)
	::cDescricao             := EncodeUtf8(U_PrtNoAce(AllTrim(cDesProd)))
	::nSldDisp               := nSldDisp
	::nQtdPrevEntrada        := nQtPrvEnt
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtListaClientes
Classe de Lista de clientes para realizar a serialização do objeto
@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtListaClientes
	
	Data Clientes
	Data nTotalRegistros   As Integer
	Data nRegistrosPag     As Integer
	
	Method New() Constructor
	Method Add() 
	Method SetTotReg() 
	Method SetRegPag() 
	
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtListaClientes
	::Clientes := {}
Return(Self)

//
// Adiciona um novo item
//
Method Add(oCliente) Class PrtListaClientes
	Aadd(::Clientes, oCliente)
Return

//
// Informa Total de Registros
//
Method SetTotReg(nTotReg) Class PrtListaClientes
	::nTotalRegistros  := nTotReg
Return

//
// Informa quantidade de Registros na Pagina
//
Method SetRegPag(nRegPag) Class PrtListaClientes
	::nRegistrosPag  := nRegPag
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItListaClientes
Classe de Clientes para realizar a serialização do objeto de cliente
@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItListaClientes
	
	Data cCodigo            As String
	Data cLoja              As String
	Data cNome              As String
	Data cCNPJ_CPF          As String
	Data cVendedor          As String

	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodCli, cLojCli, cNomCli, cCGCCli, cCodVend) Class PrtItListaClientes
	::cCodigo                := AllTrim(cCodCli)
	::cLoja                  := AllTrim(cLojCli)
	::cNome                  := EncodeUtf8(U_PrtNoAce(AllTrim(cNomCli)))
	::cCNPJ_CPF              := AllTrim(cCGCCli)
	::cVendedor              := AllTrim(cCodVend)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtListaCondPag
Classe de Lista de condições de pagamentos para realizar a 
serialização do objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtListaCondPag
	
	Data CondPag
	
	Method New() Constructor
	Method Add() 
	
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtListaCondPag
	::CondPag := {}
Return(Self)

//
// Adiciona um novo item
//
Method Add(oCondPag) Class PrtListaCondPag
	Aadd(::CondPag, oCondPag)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItListaCondPag
Classe de Condição de Pagamento para realizar a serialização do 
objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItListaCondPag
	
	Data cCodigo            As String
	Data cDescricao         As String
	Data cIcmsST            As String

	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodCond, cDescCond, cIcmsST) Class PrtItListaCondPag
	::cCodigo                := AllTrim(cCodCond)
	::cDescricao             := EncodeUtf8(U_PrtNoAce(AllTrim(cDescCond)))
	::cIcmsST                := AllTrim(cIcmsST)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtListaOrcamentos
Classe de Lista de orcamentos para realizar a 
serialização do objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtListaOrcamentos
	
	Data Orcamentos
	Data nTotalRegistros   As Integer
	Data nRegistrosPag     As Integer
	
	Method New() Constructor
	Method Add() 
	Method SetTotReg() 
	Method SetRegPag() 
	
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtListaOrcamentos
	::Orcamentos := {}
Return(Self)

//
// Adiciona um novo item
//
Method Add(oOrcamento) Class PrtListaOrcamentos
	Aadd(::Orcamentos, oOrcamento)
Return

//
// Informa Total de Registros
//
Method SetTotReg(nTotReg) Class PrtListaOrcamentos
	::nTotalRegistros  := nTotReg
Return

//
// Informa quantidade de Registros na Pagina
//
Method SetRegPag(nRegPag) Class PrtListaOrcamentos
	::nRegistrosPag  := nRegPag
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItListaOrcamentos
Classe de Orcamentos para realizar a serialização do 
objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItListaOrcamentos
	
	Data cCodigo            As String
	Data dEmissao           As Date
	Data cCodigoCliente     As String
	Data cLojaCliente       As String
	Data cNomeCliente       As String
	Data cCNPJ_CPFCliente   As String
	Data cStatus            As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodOrc, dEmissao, cCodCli, cLojCli, cNomCli, cCPFCli, cStatus) Class PrtItListaOrcamentos
	::cCodigo                := AllTrim(cCodOrc)
	::dEmissao               := DtoC(dEmissao)
	::cCodigoCliente         := AllTrim(cCodCli)
	::cLojaCliente           := AllTrim(cLojCli)
	::cNomeCliente           := EncodeUtf8(U_PrtNoAce(AllTrim(cNomCli)))
	::cCNPJ_CPFCliente       := AllTrim(cCPFCli)
	::cStatus                := AllTrim(cStatus)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtListaVendedores
Classe de Lista de vendedores para realizar a 
serialização do objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtListaVendedores
	
	Data Vendedores
	Data nTotalRegistros   As Integer
	Data nRegistrosPag     As Integer
	
	Method New() Constructor
	Method Add() 
	Method SetTotReg()
	Method SetRegPag()
	
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtListaVendedores
	::Vendedores := {}
Return(Self)

//
// Adiciona um novo item
//
Method Add(oVendedor) Class PrtListaVendedores
	Aadd(::Vendedores, oVendedor)
Return

//
// Informa Total de Registros
//
Method SetTotReg(nTotReg) Class PrtListaVendedores
	::nTotalRegistros  := nTotReg
Return

//
// Informa quantidade de Registros na Pagina
//
Method SetRegPag(nRegPag) Class PrtListaVendedores
	::nRegistrosPag  := nRegPag
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItListaVendedores
Classe de Vendedores para realizar a serialização do 
objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItListaVendedores
	
	Data cCodigo            As String
	Data cNome              As String
	Data cCNPJ_CPF          As String
	Data cTipo              As String
	Data cTabela_CIF        As String
	Data cTabela_FOB        As String
	Data nPercComis         As Float
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodVend, cNomVend, cCGCVend, cTipVend, cTabCIF, cTabFOB, nPercCom) Class PrtItListaVendedores
	::cCodigo                := AllTrim(cCodVend)
	::cNome                  := EncodeUtf8(U_PrtNoAce(AllTrim(cNomVend)))
	::cCNPJ_CPF              := AllTrim(cCGCVend)
	::cTipo                  := AllTrim(cTipVend)
	::cTabela_CIF            := AllTrim(cTabCIF)
	::cTabela_FOB            := AllTrim(cTabFOB)
	::nPercComis             := nPercCom
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtProduto
Classe de produto para realizar a serialização do objeto
@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtProduto
	
	Data cCodigo            As String
	Data cDescricao         As String
	Data cUn_Medida1        As String
	Data cUn_Medida2        As String
	Data nFator_Conversao   As Float
	Data cTipo_Conversao    As Date  
	Data nQuant_Minima      As Float
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//

Method New(cCodPro, cDesPro, cUM, cUM2, nFator, cTipoCon, nQtdMin) Class PrtProduto
	::cCodigo               := AllTrim(cCodPro)
	::cDescricao            := EncodeUtf8(U_PrtNoAce(AllTrim(cDesPro)))
	::cUn_Medida1           := AllTrim(cUM)
	::cUn_Medida2           := AllTrim(cUM2)
	::nFator_Conversao      := nFator
	::cTipo_Conversao       := AllTrim(cTipoCon)
	::nQuant_Minima         := nQtdMin
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtPreco
Classe de preco de venda para realizar a serialização do objeto
@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtPreco
	
	Data nPreco_Venda       As Float
	Data nPreco_Minimo      As Float
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//

Method New(nPrcVen, nPrcMin) Class PrtPreco
	::nPreco_Venda          := nPrcVen
	::nPreco_Minimo         := nPrcMin
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtOrcamento
Classe de orcamento para realizar a serialização do objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtOrcamento
	
	Data Cabecalho
	Data Itens
	
	Method New() Constructor
	Method AddCab()
	Method AddItem()
	
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtOrcamento
	::Cabecalho   := Nil
	::Itens       := {}
Return(Self)

//
// Adiciona Cabecalho
//
Method AddCab(oCabOrc) Class PrtOrcamento
	::Cabecalho := oCabOrc
Return(Self)

//
// Adiciona Itens
//
Method AddItem(oItensOrc) Class PrtOrcamento
	Aadd(::Itens,oItensOrc)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtCabOrcamento
Classe do cabecalho do orcamento para realizar a serialização do 
objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtCabOrcamento
	
	Data cCodigo            As String
	Data dEmissao           As Date
	Data cCodigoCliente     As String
	Data cLojaCliente       As String
	Data cNomeCliente       As String
	Data cCNPJ_CPFCliente   As String
	Data cStatus            As String
	Data cCondPag           As String
	Data cDescCondPag       As String
	Data cTabelaPreco       As String
	Data cVendedor          As String
	Data cTipoFrete         As String
	Data cTransportadora    As String
	Data cEMailCliente      As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodOrc, dEmissao, cCodCli, cLojCli, cNomCli, cCPFCli, cStatus, cCondPag, cDescPag, cTabPrc, cCodVend, cTpFrete, cTransp, cMailCli) Class PrtCabOrcamento
	::cCodigo                := AllTrim(cCodOrc)
	::dEmissao               := DtoC(dEmissao)
	::cCodigoCliente         := AllTrim(cCodCli)
	::cLojaCliente           := AllTrim(cLojCli)
	::cNomeCliente           := EncodeUtf8(U_PrtNoAce(AllTrim(cNomCli)))
	::cCNPJ_CPFCliente       := AllTrim(cCPFCli)
	::cStatus                := AllTrim(cStatus)
	::cCondPag               := AllTrim(cCondPag)
	::cDescCondPag           := AllTrim(cDescPag)
	::cTabelaPreco           := AllTrim(cTabPrc)
	::cVendedor              := AllTrim(cCodVend)
	::cTipoFrete             := AllTrim(cTpFrete)
	::cTransportadora        := AllTrim(cTransp)
	::cEMailCliente          := AllTrim(cMailCli)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItensOrcamento
Classe do cabecalho do orcamento para realizar a serialização do 
objeto

@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItensOrcamento
	
	Data cItem              As String
	Data cProduto           As String
	Data cDescriProd        As String
	Data cUn_Medida1        As String
	Data cUn_Medida2        As String
	Data nQtdVen            As Float
	Data nQtdVen2           As Float
	Data nPrcUnitario       As Float
	Data nValor             As Float
	Data cEntregaProg       As String
	Data dDtPrevEntrega     As Date
	Data cObservacao        As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cItem, cCodPro, cDesPro, cUM, cUM2, nQtdVen, nQtdVen2, nPrcVen, nVlrItem, cEntrPrg, dDtPrev, cObs) Class PrtItensOrcamento
	::cItem              := AllTrim(cItem)
	::cProduto           := AllTrim(cCodPro)
	::cDescriProd        := EncodeUtf8(U_PrtNoAce(AllTrim(cDesPro)))
	::cUn_Medida1        := AllTrim(cUM)
	::cUn_Medida2        := AllTrim(cUM2)
	::nQtdVen            := nQtdVen
	::nQtdVen2           := nQtdVen2
	::nPrcUnitario       := nPrcVen
	::nValor             := nVlrItem
	::cEntregaProg       := AllTrim(cEntrPrg)
	::dDtPrevEntrega     := DtoC(dDtPrev)
	::cObservacao        := U_PrtNoAce(AllTrim(cObs))
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtImpostos
Classe dos impostos previstos no orçamento de venda para realizar 
a serialização do objeto

@author Felipe Toledo
@since 10/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtImpostos
	
	Data Cabecalho
	Data Itens
	
	Method New() Constructor
	Method AddCab()
	Method AddItem()
	
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtImpostos
	::Cabecalho   := Nil
	::Itens       := {}
Return(Self)

//
// Adiciona Cabecalho
//
Method AddCab(oCabOrc) Class PrtImpostos
	::Cabecalho := oCabOrc
Return(Self)

//
// Adiciona Itens
//
Method AddItem(oItensOrc) Class PrtImpostos
	Aadd(::Itens,oItensOrc)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtCabImpostos
Classe do cabecalho dos impostos para realizar a serialização do 
objeto

@author Felipe Toledo
@since 10/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtCabImpostos
	
	Data nValorTotal        As Float
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(nValTot) Class PrtCabImpostos
	::nValorTotal            := nValTot
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItensImpostos
Classe dos impostos do orcamento para realizar a serialização do 
objeto

@author Felipe Toledo
@since 10/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItensImpostos
	
	Data cImposto           As String
	Data nBase              As Float
	Data nAliquota          As Float
	Data nValor             As Float
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cDescImp, nBase, nAliq, nValImp) Class PrtItensImpostos
	::cImposto           := EncodeUtf8(U_PrtNoAce(AllTrim(cDescImp)))
	::nBase              := nBase
	::nAliquota          := nAliq
	::nValor             := nValImp
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtListaTransportadoras
Classe de Lista das transportadoras disponíveis para realizar a 
serialização do objeto

@author Felipe Toledo
@since 11/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtListaTransportadoras
	
	Data Transportadoras
	Data nTotalRegistros   As Integer
	Data nRegistrosPag     As Integer
	
	Method New() Constructor
	Method Add() 
	Method SetTotReg()
	Method SetRegPag()
	
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtListaTransportadoras
	::Transportadoras := {}
Return(Self)

//
// Adiciona um novo item
//
Method Add(oTransportadora) Class PrtListaTransportadoras
	Aadd(::Transportadoras, oTransportadora)
Return

//
// Informa Total de Registros
//
Method SetTotReg(nTotReg) Class PrtListaTransportadoras
	::nTotalRegistros  := nTotReg
Return

//
// Informa quantidade de Registros na Pagina
//
Method SetRegPag(nRegPag) Class PrtListaTransportadoras
	::nRegistrosPag  := nRegPag
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItListaTransportadoras
Classe de Transportadoras para realizar a serialização do objeto 

@author Felipe Toledo
@since 11/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItListaTransportadoras
	
	Data cCodigo            As String
	Data cNome              As String
	Data cCNPJ_CPF          As String

	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodTra, cNomTra, cCGC) Class PrtItListaTransportadoras
	::cCodigo                := AllTrim(cCodTra)
	::cNome                  := EncodeUtf8(U_PrtNoAce(AllTrim(cNomTra)))
	::cCNPJ_CPF              := AllTrim(cCGC)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtValidaQuant
Classe de retorno da validação da quantidade do orçamento de venda 
para realizar a serialização do objeto

@author Felipe Toledo
@since 11/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtValidaQuant
	
	Data nQuant_2UM         As Float
	Data cSegUM             As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//

Method New(nQtde2UM, cSegUM) Class PrtValidaQuant
	::nQuant_2UM            := nQtde2UM
	::cSegUM                := cSegUM
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtValidaPreco
Classe de retorno da validação do preço unitário do orçamento de venda 
para realizar a serialização do objeto

@author Felipe Toledo
@since 11/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtValidaPreco
	
	Data nValorTot          As Float
	Data nQuant_2UM         As Float
	Data cSegUM             As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//

Method New(nValorTot, nQtde2UM, cSegUM) Class PrtValidaPreco
	::nValorTot            := nValorTot
	::nQuant_2UM           := nQtde2UM
	::cSegUM               := cSegUM
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtTabelaPreco
Classe de retorno da da tabela de preço para realizar a serialização 
do objeto

@author Felipe Toledo
@since 11/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtTabelaPreco
	
	Data cTabelaPrc     As String
	Data cNomeTabela    As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//

Method New(cCodTab,cNomeTab) Class PrtTabelaPreco
	::cTabelaPrc          := cCodTab
	::cNomeTabela         := cNomeTab
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtAprovaOrcamento
Classe de aprovação do orcamento para realizar a serialização do 
objeto

@author Felipe Toledo
@since 18/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtAprovaOrcamento
	
	Data cOrcamento         As String
	Data cStatus            As String
	Data cPedido            As String

	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cNumOrc, cStatus, cPedido) Class PrtAprovaOrcamento
	::cOrcamento             := AllTrim(cNumOrc)
	::cStatus                := AllTrim(cStatus)
	::cPedido                := AllTrim(cPedido)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtNumOrcamento
Classe de retorno do Numero Orcamento gravado do orcamento para realizar 
a serialização do objeto

@author Felipe Toledo
@since 18/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtNumOrcamento
	
	Data cOrcamento         As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cNumOrc) Class PrtNumOrcamento
	::cOrcamento             := AllTrim(cNumOrc)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtCliente
Classe de cliente para realizar a serialização do objeto
@author Felipe Toledo
@since 07/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtCliente
	
	Data cCodigo            As String
	Data cLoja              As String
	Data cNome              As String
	Data cCNPJ              As String
	Data cInscEstadual      As String
	Data cVendedor          As String
	Data cEndereco          As String
	Data cBairro            As String
	Data cMunicipio         As String
	Data cUF                As String
	Data cCEP               As String
	Data cTelefone          As String
	Data cContato           As String
	Data nLimiteCredito     As Float
	Data dPrimeiraCompra    As Date
	Data nSaldoHistorico    As Float
	Data dUltimaCompra      As Date
	Data nLimiteCredSec     As Float
	Data nMaiorAtraso       As Integer
	Data nSaldoLimiteSec    As Float
	Data nMediaAtraso       As Float
	Data nMaiorCompra       As Float
	Data cGrauRisco         As String
	Data nMaiorSaldo        As Float
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//

Method New(cCodCli, cLojCli, cNomCli, cCGC, cInscr, cVend, cEnd, cBairro, cMun, cUF, cCEP, cTel, cContato, nLimCred, dDtPriCom, nSldHist, dDtUltCom, nLimSec, nMaiorAtr, nSldSec, nMediaAtr, nMaiorCom, cRisco, nMaiorSld ) Class PrtCliente
	::cCodigo               := AllTrim(cCodCli)
	::cLoja                 := AllTrim(cLojCli)
	::cNome                 := EncodeUtf8(U_PrtNoAce(AllTrim(cNomCli)))
	::cCNPJ                 := AllTrim(cCGC)
	::cInscEstadual         := AllTrim(cInscr)
	::cVendedor             := AllTrim(cVend)
	::cEndereco             := EncodeUtf8(U_PrtNoAce(AllTrim(cEnd)))
	::cBairro               := EncodeUtf8(U_PrtNoAce(AllTrim(cBairro)))
	::cMunicipio            := EncodeUtf8(U_PrtNoAce(AllTrim(cMun)))
	::cUF                   := AllTrim(cUF)
	::cCEP                  := AllTrim(cCEP)
	::cTelefone             := AllTrim(cTel)
	::cContato              := AllTrim(cContato)
	::nLimiteCredito        := nLimCred
	::dPrimeiraCompra       := DtoC(dDtPriCom)
	::nSaldoHistorico       := nSldHist
	::dUltimaCompra         := DtoC(dDtUltCom)
	::nLimiteCredSec        := nLimSec
	::nMaiorAtraso          := nMaiorAtr
	::nSaldoLimiteSec       := nSldSec
	::nMediaAtraso          := nMediaAtr
	::nMaiorCompra          := nMaiorCom
	::cGrauRisco            := AllTrim(cRisco)
	::nMaiorSaldo           := nMaiorSld
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtPrtPesquisaPortal
Classe de pesquisa para realizar a serialização do objeto

@author Felipe Toledo
@since 29/07/17
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------

Class PrtPrtPesquisaPortal
	
	Data ListaClientes
	Data ListaOrcamentos
	Data ListaProdutos
	Data ListaVendedores
	Data ListaTransportadoras
	
	Method New() Constructor 
	Method AddClientes()
	Method AddOrcamentos()
	Method AddProdutos()
	Method AddVendedores()
	Method AddTransportadoras()
EndClass

//
// Metodo Contrutor
//
Method New() Class PrtPrtPesquisaPortal
	::ListaClientes        := {}
	::ListaOrcamentos      := {}
	::ListaProdutos        := {}
	::ListaVendedores      := {}
	::ListaTransportadoras := {}
Return(Self)

//
// Adiciona Clientes
//
Method AddClientes(oClientes) Class PrtPrtPesquisaPortal
	Aadd(::ListaClientes, oClientes)
Return

//
// Adiciona Orçamentos
//
Method AddOrcamentos(oOrcamentos) Class PrtPrtPesquisaPortal
	Aadd(::ListaOrcamentos, oOrcamentos)
Return

//
// Adiciona Produtos
//
Method AddProdutos(oProdutos) Class PrtPrtPesquisaPortal
	Aadd(::ListaProdutos, oProdutos)
Return

//
// Adiciona Vendedores
//
Method AddVendedores(oVendedores) Class PrtPrtPesquisaPortal
	Aadd(::ListaVendedores, oVendedores)
Return

//
// Adiciona Transportadoras
//
Method AddTransportadoras(oTransp) Class PrtPrtPesquisaPortal
	Aadd(::ListaTransportadoras, oTransp)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtDashBoard
Classe com os dados do DashBoard do Portal de Orçamentos

@author Felipe Toledo
@since 08/01/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtDashBoard

	Data DashBoard
	
	Method New() Constructor
	Method Add()

EndClass

//
// Metodo Contrutor
//
Method New() Class PrtDashBoard
	::DashBoard := {}
Return(Self)

//
// Metodo Contrutor
//
Method Add(oObjDash) Class PrtDashBoard
	Aadd(::DashBoard, oObjDash)
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtDashView
Classe com os dados da View do DashBoard

@author Felipe Toledo
@since 08/01/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtDashView

	Data Itens
	Data ID                 As String
	Data nTotal             As Float
	
	Method New() Constructor
	Method Add()
	Method SetTotal()
EndClass

//
// Metodo Contrutor
//
Method New(cID) Class PrtDashView
	::ID     := cID 
	::Itens  := {}
Return(Self)

//
// Adiciona um novo item
//
Method Add(oItemView) Class PrtDashView
	Aadd(::Itens, oItemView)
Return

//
// Informa o Valor Total Faturado
//
Method SetTotal(nTotal) Class PrtDashView
	::nTotal  := nTotal
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtItemDash
Classe com os dados do DashBoard do Portal de Orçamentos

@author Felipe Toledo
@since 08/01/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtItemDash
	
	Data dDataEmissao       As Date  
	Data nValor             As Float

	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(dDtEmis, nValorIt) Class PrtItemDash
	::dDataEmissao           := DtoC(dDtEmis)
	::nValor                 := nValorIt
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtTracking
Classe com os dados do Tracking do Portal de Orçamentos

@author Felipe Toledo
@since 12/03/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtTracking

	Data Tracking
	
	Method New() Constructor
	Method Add()

EndClass

//
// Metodo Contrutor
//
Method New() Class PrtTracking
	::Tracking := {}
Return(Self)

//
// Metodo Contrutor
//
Method Add(cID, aObjTrack) Class PrtTracking
	Local oObjTrack := PrtTrackingID():New(cID,aObjTrack)
	 
	Aadd(::Tracking, oObjTrack )
Return(Self)

Class PrtTrackingID
	Data ID
	Data Itens
	
	Method New() Constructor
EndClass	

//
// Metodo Contrutor
//
Method New(cID, aObjTrack) Class PrtTrackingID
	::ID     := cID
	::Itens  := aObjTrack
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtTrkCabOrc
Classe com os dados do Tracking do Cabecalho do Orcamento

@author Felipe Toledo
@since 12/03/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtTrkCabOrc

	Data cOrcamento         As String
	Data dEmissao           As Date
	Data cCliente           As String
	Data nQuantidade        As Float
	Data nValor             As Float
	
	Method New() Constructor
EndClass

//
// Metodo Contrutor
//
Method New(cNumOrc, dEmis, cCli, nQuant, nVlr) Class PrtTrkCabOrc
	::cOrcamento    := cNumOrc 
	::dEmissao      := DtoC(dEmis)
	::cCliente      := cCli
	::nQuantidade   := nQuant
	::nValor        := nVlr
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtTrkOrcamento
Classe com os dados do Tracking do Orcamento

@author Felipe Toledo
@since 12/03/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtTrkOrcamento

	Data cItem              As String
	Data cProduto           As String
	Data cDescricao         As String
	Data nQuantidade        As Float
	Data cUn_Medida         As String
	Data nPrcUnitario       As Float
	Data nValorTotal        As Float
	
	Method New() Constructor
EndClass

//
// Metodo Contrutor
//
Method New(cItem, cCodPro, cDescri, nQuant, cUM, nPrcVen, nVlrTot) Class PrtTrkOrcamento
	::cItem         := cItem 
	::cProduto      := AllTrim(cCodPro)
	::cDescricao    := EncodeUtf8(U_PrtNoAce(AllTrim(cDescri)))
	::nQuantidade   := nQuant
	::cUn_Medida    := cUM
	::nPrcUnitario  := nPrcVen 
	::nValorTotal   := nVlrTot
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtTrkFaturado
Classe com os dados do Tracking do Faturados

@author Felipe Toledo
@since 12/03/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtTrkFaturado
	
	Data cPedido            As String
	Data cNota              As String
	Data cSerie             As String
	Data cCondPag           As String
	Data cTransportadora    As String
	Data cTipoFrete         As String
	Data cItem              As String
	Data cProduto           As String
	Data cDescricao         As String
	Data dEmissao           As Date
	Data nQuantidade        As Float
	Data cUn_Medida         As String
	Data nPrcUnitario       As Float
	Data nValorTotal        As Float
	
	Method New() Constructor
EndClass

//
// Metodo Contrutor
//
Method New(cNumPed, cNF, cSerNF, cCondPg, cTransp, cTpFrete, cItem, cCodPro, cDescri, dEmis, nQuant, cUM, nPrcVen, nVlrTot) Class PrtTrkFaturado
	::cPedido        := cNumPed
	::cNota          := Alltrim(cNF)
	::cSerie         := AllTrim(cSerNF)
	::cCondPag       := AllTrim(cCondPg)
	::cTransportadora:= EncodeUtf8(U_PrtNoAce(AllTrim(cTransp)))
	::cTipoFrete     := cTpFrete	
	::cItem          := cItem 
	::cProduto       := AllTrim(cCodPro)
	::cDescricao     := EncodeUtf8(U_PrtNoAce(AllTrim(cDescri)))
	::dEmissao       := DtoC(dEmis)
	::nQuantidade    := nQuant
	::cUn_Medida     := cUM
	::nPrcUnitario   := nPrcVen 
	::nValorTotal    := nVlrTot
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtTrkPedido
Classe com os dados do Tracking do Pedido de Venda

@author Felipe Toledo
@since 12/03/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtTrkPedido
	
	Data cPedido            As String
	Data cCondPag           As String
	Data cTransportadora    As String
	Data cTipoFrete         As String
	Data cItem              As String
	Data cProduto           As String
	Data cDescricao         As String
	Data dEmissao           As Date
	Data nQuantidade        As Float
	Data cUn_Medida         As String
	Data nPrcUnitario       As Float
	Data nValorTotal        As Float
	
	Method New() Constructor
EndClass

//
// Metodo Contrutor
//
Method New(cNumPed, cCondPg, cTransp, cTpFrete, cItem, cCodPro, cDescri, dEmis, nQuant, cUM, nPrcVen, nVlrTot) Class PrtTrkPedido
	::cPedido        := cNumPed
	::cCondPag       := AllTrim(cCondPg)
	::cTransportadora:= EncodeUtf8(U_PrtNoAce(AllTrim(cTransp)))
	::cTipoFrete     := cTpFrete	
	::cItem          := cItem 
	::cProduto       := AllTrim(cCodPro)
	::cDescricao     := EncodeUtf8(U_PrtNoAce(AllTrim(cDescri)))
	::dEmissao       := DtoC(dEmis)
	::nQuantidade    := nQuant
	::cUn_Medida     := cUM
	::nPrcUnitario   := nPrcVen 
	::nValorTotal    := nVlrTot
Return(Self)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtTrkTitulo
Classe com os dados do Tracking do Titulo a Receber

@author Felipe Toledo
@since 12/03/18
@version 1.0
@type Class
/*/
//-------------------------------------------------------------------
Class PrtTrkTitulo
	
	Data cPrefixo           As String
	Data cNumero            As String
	Data cParcela           As String
	Data cTipo              As String
	Data dEmissao           As Date
	Data dVencimento        As Date
	Data dVencimentoRea     As Date
	Data nValor             As Float
	Data nSaldo             As Float
	Data cNumeroBanco       As String
	Data nAtraso            As Integer
	Data cSituacao          As String

	Method New() Constructor
EndClass

//
// Metodo Contrutor
//
Method New(cPref, cNum, cParc, cTipo, dEmis, dVenc, cVencRea, nValor, nSaldo, cNumBco, nAtraso, cSituaca) Class PrtTrkTitulo
	::cPrefixo         := AllTrim(cPref)
	::cNumero          := AllTrim(cNum)
	::cParcela         := AllTrim(cParc)
	::cTipo            := cTipo
	::dEmissao         := DtoC(dEmis)
	::dVencimento      := DtoC(dVenc)
	::dVencimentoRea   := DtoC(cVencRea)
	::nValor           := nValor
	::nSaldo           := nSaldo
	::cNumeroBanco     := AllTrim(cNumBco)
	::nAtraso          := nAtraso
	::cSituacao        := cSituaca
Return(Self)