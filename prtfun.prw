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
/*/{Protheus.doc} PrtCodVen
Codigo de vendedor do usuário logado

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtCodVen()
Local cRet       := "" 

// verifica se o usuário esta cadastrado como representante
SA3->(DbSetOrder(7)) // A3_FILIAL+A3_CODUSR
If SA3->(MsSeek(xFilial('SA3')+RetCodUsr()))
	cRet := SA3->A3_COD
EndIf

Return(cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PrtDtUAc
Data do último acesso do usuário

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtDtUAc()
Local dRet       := CtoD('  /  /  ')
Local cAliasQry  := GetNextAlias()

BeginSql Alias cAliasQry
	COLUMN CV8_DATA AS DATE
	
	SELECT MAX(CV8_DATA) CV8_DATA
	  FROM %Table:CV8% CV8
	 WHERE CV8.CV8_FILIAL = %xFilial:CV8%
	   AND CV8.CV8_PROC   = 'PRTLOGIN'
	   AND CV8.CV8_USER   = %Exp:cUserName%
	   AND CV8.%notDel%
EndSql

If (cAliasQry)->(! Eof())
	dRet := (cAliasQry)->CV8_DATA
EndIf

(cAliasQry)->(DbCloseArea())

Return(dRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PrtDtUAc
Hora do último acesso do usuário

@author Felipe Toledo
@since 07/07/17
@type Function
/*/
//-------------------------------------------------------------------
User Function PrtHrAc(dDtAcesso)
Local cRet       := ''
Local cAliasQry  := GetNextAlias()

BeginSql Alias cAliasQry
	SELECT MAX(CV8_HORA) CV8_HORA
	  FROM %Table:CV8% CV8
	 WHERE CV8.CV8_FILIAL = %xFilial:CV8%
	   AND CV8.CV8_PROC   = 'PRTLOGIN'
	   AND CV8.CV8_USER   = %Exp:cUserName%
	   AND CV8.CV8_DATA   = %Exp:DtoS(dDtAcesso)%
	   AND CV8.%notDel%
EndSql

If (cAliasQry)->(! Eof())
	cRet := (cAliasQry)->CV8_HORA
EndIf

(cAliasQry)->(DbCloseArea())


Return(cRet)