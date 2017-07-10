#include 'totvs.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} PrtClasses
Classes para o portal de venda da ConduCopper

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
	
	Method New() Constructor
	Method Add() 
	
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

	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodProd, cDesProd) Class PrtItListaProdutos
	::cCodigo                := AllTrim(cCodProd)
	::cDescricao             := EncodeUtf8(AllTrim(cDesProd))
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
	
	Method New() Constructor
	Method Add() 
	
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

	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodCli, cLojCli, cNomCli, cCGCCli) Class PrtItListaClientes
	::cCodigo                := AllTrim(cCodCli)
	::cLoja                  := AllTrim(cLojCli)
	::cNome                  := EncodeUtf8(AllTrim(cNomCli))
	::cCNPJ_CPF              := AllTrim(cCGCCli)
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
	::cDescricao             := EncodeUtf8(AllTrim(cDescCond))
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
	
	Method New() Constructor
	Method Add() 
	
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
	::cNomeCliente           := EncodeUtf8(AllTrim(cNomCli))
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
	
	Method New() Constructor
	Method Add() 
	
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
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodVend, cNomVend, cCGCVend, cTipVend) Class PrtItListaVendedores
	::cCodigo                := AllTrim(cCodVend)
	::cNome                  := EncodeUtf8(AllTrim(cNomVend))
	::cCNPJ_CPF              := AllTrim(cCGCVend)
	::cTipo                  := AllTrim(cTipVend)
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
	::cDescricao            := EncodeUtf8(AllTrim(cDesPro))
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
	Data cTabelaPreco       As String
	Data cVendedor          As String
	Data cTipoFrete         As String
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cCodOrc, dEmissao, cCodCli, cLojCli, cNomCli, cCPFCli, cStatus, cCondPag, cTabPrc, cCodVend, cTpFrete) Class PrtCabOrcamento
	::cCodigo                := AllTrim(cCodOrc)
	::dEmissao               := DtoC(dEmissao)
	::cCodigoCliente         := AllTrim(cCodCli)
	::cLojaCliente           := AllTrim(cLojCli)
	::cNomeCliente           := EncodeUtf8(AllTrim(cNomCli))
	::cCNPJ_CPFCliente       := AllTrim(cCPFCli)
	::cStatus                := AllTrim(cStatus)
	::cCondPag               := AllTrim(cCondPag)
	::cTabelaPreco           := AllTrim(cTabPrc)
	::cVendedor              := AllTrim(cCodVend)
	::cTipoFrete             := AllTrim(cTpFrete)
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
	
	Method New() Constructor 
EndClass

//
// Metodo Contrutor
//
Method New(cItem, cCodPro, cDesPro, cUM, cUM2, nQtdVen, nQtdVen2, nPrcVen, nVlrItem, cEntrPrg, dDtPrev) Class PrtItensOrcamento
	::cItem              := AllTrim(cItem)
	::cProduto           := AllTrim(cCodPro)
	::cDescriProd        := EncodeUtf8(AllTrim(cDesPro))
	::cUn_Medida1        := AllTrim(cUM)
	::cUn_Medida2        := AllTrim(cUM2)
	::nQtdVen            := nQtdVen
	::nQtdVen2           := nQtdVen2
	::nPrcUnitario       := nPrcVen
	::nValor             := nVlrItem
	::cEntregaProg       := AllTrim(cEntrPrg)
	::dDtPrevEntrega     := DtoC(dDtPrev)
Return(Self)