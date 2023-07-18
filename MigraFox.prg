Local loDB, lcDriver, lcServer, lcDatabase, lcUser, lcPassword, lcEngine

lcEngine = "Firebird"
Do case
Case lcEngine == "MySQL"
	lcDriver = "MySQL ODBC 5.1 Driver"
	lcServer = "localhost"
	lcDatabase = "continentes"
	lcUser = "root"
	lcPassWord = "1234"
Case lcEngine == "MSSQL"
	lcDriver = "SQL Server Native Client 11.0"
	lcServer = "PC-IRWIN\SQLIRWIN"
	lcDatabase = "VIRFIJOS"
	lcUser = "sa"
	lcPassWord = "Subifor2012"
Case lcEngine == "Firebird"
	lcDriver = "Firebird/Interbase(r) driver"
	lcServer = "localhost"
	lcDatabase = "C:\a1\FB_PRUEBA.gdb"
	lcUser = "SYSDBA"
	lcPassWord = "1234"
EndCase

loDB = CreateObject(lcEngine)
loDB.cPKName = "unique_id"
loDB.bUseCA = .F.
loDB.cDriver = lcDriver
loDB.cServer = lcServer
loDB.cDatabase = lcDatabase
loDB.cUser = lcUser
loDB.cPassword = lcPassWord
If !loDB.connect()
	Return
EndIf
loDB.migrate("F:\Desarrollo\Mini_ERP\Sical\clientes.tmg")

Release loDB

* =================================================================================== *
* Implementation
* =================================================================================== *
Procedure defineConstants
	#ifndef tkIdent
		#Define tkIdent 1
	#Endif
	#ifndef tkPrimary
		#Define tkPrimary 2
	#Endif
	#ifndef tkSymbol
		#Define tkSymbol 3
	#Endif
	#ifndef tkGeneric
		#Define tkGeneric 4
	#endif

	#ifndef CRLF
		#define CRLF Chr(13) + Chr(10)
	#endif
	#ifndef ttTable
		#Define ttTable 100
	#Endif
	#ifndef ttDescription
		#Define ttDescription 101
	#Endif
	#ifndef ttFields
		#Define ttFields 102
	#Endif
	#ifndef ttName
		#Define ttName 103
	#Endif
	#ifndef ttType
		#Define ttType 104
	#Endif
	#ifndef ttSize
		#Define ttSize 105
	#Endif
	#ifndef ttPrimaryKey
		#Define ttPrimaryKey 106
	#Endif
	#ifndef ttAllowNull
		#Define ttAllowNull 107
	#Endif	
	#ifndef ttDefault
		#Define ttDefault 108
	#Endif
	#ifndef ttForeignKey
		#Define ttForeignKey 109
	#endif
	#ifndef ttFkTable
		#Define ttFkTable 110
	#endif
	#ifndef ttFkField
		#Define ttFkField 111
	#endif
	#ifndef ttOnDelete
		#Define ttOnDelete 112
	#endif
	#ifndef ttOnUpdate
		#Define ttOnUpdate 113
	#endif
	#ifndef ttCascade
		#Define ttCascade 114
	#endif
	#ifndef ttRestrict
		#Define ttRestrict 115
	#endif
	#ifndef ttNull
		#Define ttNull 116
	#endif
	#ifndef ttIndex
		#Define ttIndex 117
	#endif
	#ifndef ttColumns
		#Define ttColumns 118
	#endif
	#ifndef ttSort
		#Define ttSort 119
	#endif
	#ifndef ttUnique
		#Define ttUnique 120
	#endif
	#ifndef ttAsc
		#Define ttAsc 121
	#endif
	#ifndef ttDesc
		#Define ttDesc 122
	#endif
	* ======================================= *
	* Table data types
	* ======================================= *
	#ifndef ttChar
		#Define ttChar 200
	#Endif
	#ifndef ttVarchar
		#Define ttVarchar 201
	#Endif
	#ifndef ttDecimal
		#Define ttDecimal 202
	#Endif
	#ifndef ttDate
		#Define ttDate 203
	#Endif
	#ifndef ttDateTime
		#Define ttDateTime 204
	#Endif
	#ifndef ttDouble
		#Define ttDouble 205
	#Endif
	#ifndef ttFloat
		#Define ttFloat 206
	#Endif
	#ifndef ttInt
		#Define ttInt 207
	#Endif
	#ifndef ttBool
		#Define ttBool 208
	#Endif
	#ifndef ttText
		#Define ttText 209
	#Endif
	#ifndef ttVarBinary
		#Define ttVarBinary 210
	#Endif
	#ifndef ttBlob
		#Define ttBlob 211
	#Endif	
	
	#ifndef ttIdent
		#Define ttIdent 21
	#Endif
	#ifndef ttNumber
		#Define ttNumber 22
	#Endif
	#ifndef ttString
		#Define ttString 23
	#Endif
	#ifndef ttEof
		#Define ttEof 24
	#Endif
	#ifndef ttColon
		#Define ttColon 25
	#Endif
	#ifndef ttMinus	
		#Define ttMinus 26
	#Endif
	#ifndef ttTrue
		#Define ttTrue 27
	#Endif
	#ifndef ttFalse
		#Define ttFalse 28
	#Endif
	#ifndef ttAutoIncrement
		#Define ttAutoIncrement 29
	#Endif
	#ifndef ttNewLine
		#Define ttNewLine 30
	#Endif
	#ifndef ttProgram
		#Define ttProgram 31
	#Endif
	#ifndef ttComma
		#define ttComma 32
	#endif
	#ifndef ttLeftBracket
		#define ttLeftBracket 33
	#endif
	#ifndef ttRightBracket
		#define ttRightBracket 34
	#endif
Endproc

* =================================================================================== *
* Scanner Class
* =================================================================================== *
Define Class Scanner As Custom
	Hidden ;
		cSource, ;
		nStart, ;
		nCurrent, ;
		nCapacity, ;
		nLength, ;
		nSourceLen, ;
		cLetters, ;
		nLine, ;
		nCol, ;
		oKeywords

	cSource = ''
	nStart = 0
	nCurrent = 1
	cLetters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'
	nLine = 1
	nCol = 0
	nCapacity = 0
	nLength = 1
	nSourceLen = 0
	nTokenAnt = 0

	Dimension aTokens[1]

	Procedure Init(tcSource)
		This.cSource = tcSource
		This.nSourceLen = Len(tcSource)

		* Create keywords
		This.oKeywords = Createobject("Scripting.Dictionary")
		This.oKeywords.Add('table', ttTable)
		This.oKeywords.Add('description', ttDescription)
		This.oKeywords.Add('fields', ttFields)

		* Fields attributes
		This.oKeywords.Add('name', ttName)
		This.oKeywords.Add('type', ttType)
		This.oKeywords.Add('size', ttSize)
		This.oKeywords.Add('primarykey', ttPrimaryKey)
		This.oKeywords.Add('allownull', ttAllowNull)
		This.oKeywords.Add('default', ttDefault)
		This.oKeywords.Add('foreignkey', ttForeignKey)
		This.oKeywords.Add('fktable', ttFkTable)
		This.oKeywords.Add('fkfield', ttFkField)
		This.oKeywords.Add('ondelete', ttOnDelete)
		This.oKeywords.Add('onupdate', ttOnUpdate)
		This.oKeywords.Add('cascade', ttCascade)
		This.oKeywords.Add('restrict', ttRestrict)
		This.oKeywords.Add('null', ttNull)
		This.oKeywords.Add('index', ttIndex)
		This.oKeywords.Add('columns', ttColumns)
		This.oKeywords.Add('sort', ttSort)
		This.oKeywords.Add('unique', ttUnique)
		This.oKeywords.Add('asc', ttAsc)
		This.oKeywords.Add('desc', ttDesc)
		This.oKeywords.Add('autoincrement', ttAutoIncrement)

		* Data Types
		This.oKeywords.Add('true', ttTrue)
		This.oKeywords.Add('false', ttFalse)
		
		* Table data types
		This.oKeywords.Add('char', ttChar)
		This.oKeywords.Add('varchar', ttVarchar)
		This.oKeywords.Add('decimal', ttDecimal)
		This.oKeywords.Add('date', ttDate)
		This.oKeywords.Add('datetime', ttDateTime)
		This.oKeywords.Add('double', ttDouble)
		This.oKeywords.Add('float', ttFloat)
		This.oKeywords.Add('int', ttInt)
		This.oKeywords.Add('bool', ttBool)
		This.oKeywords.Add('text', ttText)
		This.oKeywords.Add('varbinary', ttVarBinary)
		This.oKeywords.Add('blob', ttBlob)
	Endproc

	Hidden Function advance
		this.nCol = this.nCol + 1
		This.nCurrent = This.nCurrent + 1
		Return Substr(This.cSource, This.nCurrent-1, 1)
	Endfunc

	Hidden Function peek
		If This.isAtEnd()
			Return 'ÿ'
		Endif
		Return Substr(This.cSource, This.nCurrent, 1)
	Endfunc

	Hidden Function peekNext
		If (This.nCurrent + 1) > This.nSourceLen
			Return 'ÿ'
		Endif
		Return Substr(This.cSource, This.nCurrent+1, 1)
	Endfunc

	Hidden Procedure skipWhitespace
		Local ch
		Do While Inlist(This.peek(), Chr(9), Chr(32))
			This.advance()
		Enddo
	Endproc

	Hidden procedure readIdentifier
		Local lcLexeme, lnCol, lnTokenType
		lnCol = this.nCol-1
		lnTokenType = ttIdent
		Do While At(This.peek(), This.cLetters) > 0
			This.advance()
		Enddo
		lcLexeme = Lower(Substr(This.cSource, This.nStart, This.nCurrent-This.nStart))
		If This.oKeywords.Exists(lcLexeme)
			lnTokenType = This.oKeywords.Item(lcLexeme)
		Endif
		This.addToken(lnTokenType, tkIdent, lcLexeme, lnCol)
	EndProc

	Hidden procedure readNumber
		Local lcLexeme, llIsNegative, lnCol, lnLiteral
		lcLexeme = ''
		lnLiteral = 0
		llIsNegative = This.peek() == '-'
		lnCol = this.nCol-1
		If llIsNegative
			This.advance()
		Endif

		Do While Isdigit(This.peek())
			This.advance()
		Enddo

		If This.peek() == '.' And Isdigit(This.peekNext())
			This.advance()
			Do While Isdigit(This.peek())
				This.advance()
			Enddo
		Endif

		lcLexeme = Substr(This.cSource, This.nStart, This.nCurrent-This.nStart)
		try
			lnLiteral = Val(lcLexeme)
		Catch to loEx
			MessageBox("No se pudo convertir a número el siguiente valor: " + lcLexeme + CRLF + "Mensaje: " + loEx.Message, 16)
		EndTry

		Return This.addToken(ttNumber, tkPrimary, lnLiteral, lnCol)
	EndProc

	Hidden procedure readString(tcStopChar)
		Local lcLexeme, ch, lnCol
		lnCol = this.nCol-1
		Do While !this.isAtEnd()
			ch = This.peek()
			This.advance()
			If ch == tcStopChar
				Exit
			Endif
		Enddo
		lcLexeme = Substr(This.cSource, This.nStart+1, This.nCurrent-This.nStart-2)

		Return This.addToken(ttString, tkPrimary, lcLexeme, lnCol)
	EndProc
	
	Hidden procedure skipComments
		Do while !this.isAtEnd()		
			If this.peek() == Chr(13)
				Exit
			EndIf
			this.advance()
		EndDo
	endproc

	Function scanTokens
		Dimension This.aTokens[1]

		Do While !This.isAtEnd()
			This.skipWhitespace()
			This.nStart = This.nCurrent
			This.scanToken()
		Enddo
		This.addToken(ttEof)
		This.nCapacity = This.nLength-1

		* Shrink the array
		Dimension This.aTokens[this.nCapacity]

		Return @This.aTokens
	Endfunc

	Hidden Procedure scanToken
		Local ch
		ch = This.advance()
		Do Case
		Case ch == '#'
			this.skipComments()
		Case ch == '['
			this.AddToken(ttLeftBracket, tkSymbol, ch)
		Case ch == ']'
			this.AddToken(ttRightBracket, tkSymbol, ch)
		Case ch == ','
			this.AddToken(ttComma, tkSymbol, ch)
		Case ch == ':'
			This.addToken(ttColon, tkSymbol, ch)			
		Case ch == '-' And !Isdigit(This.peek())
			This.addToken(ttMinus, tkSymbol, ch)
		Case Inlist(ch, '"', "'")
			This.readString(ch)
		Case ch == Chr(13)
			If this.nTokenAnt > 0 and this.nTokenAnt != ttNewLine
				this.addToken(ttNewLine)
			EndIf
			this.advance() && skip chr(10)
			this.nLine = this.nLine + 1
			this.nCol = 1
		Case ch == Chr(10)
			* skip
		Otherwise
			If Isdigit(ch) Or (ch == '-' And Isdigit(This.peek()))
				This.readNumber()
				Return
			Endif
			If At(ch, This.cLetters) > 0
				This.readIdentifier()
				Return
			Endif
			This.showError(This.nLine, "Unknown character ['" + Transform(ch) + "'], ascii: [" + Transform(Asc(ch)) + "]")
		Endcase
	Endproc

	Hidden Procedure addToken(tnType, tnKind, tvLiteral, tnCol)
		This.checkCapacity()
		Local loToken,lnCol
		lnCol = Iif(Empty(tnCol), this.nCol, tnCol)
		loToken = Createobject("Token", tnType, "", tvLiteral, This.nLine, lnCol)
		loToken.nKind = Iif(Empty(tnKind), tkGeneric, tnKind)
		This.aTokens[this.nLength] = loToken
		This.nLength = This.nLength + 1
		this.nTokenAnt = tnType
	Endproc

	Hidden Procedure checkCapacity
		If This.nCapacity < This.nLength + 1
			If Empty(This.nCapacity)
				This.nCapacity = 8
			Else
				This.nCapacity = This.nCapacity * 2
			Endif
			Dimension This.aTokens[this.nCapacity]
		Endif
	Endproc

	Hidden Procedure showError(tnLine, tcMessage)
		Error "SYNTAX ERROR: (" + Transform(tnLine) + ":" + Transform(This.nLine) + ")" + tcMessage
	Endproc

	Hidden Function isAtEnd
		Return This.nCurrent > This.nSourceLen
	Endfunc

Enddefine

* =================================================================================== *
* Parser Class
* =================================================================================== *
Define Class Parser as Custom
	Hidden ;
	oPeek, ;
	oPeekNext, ;
	oPrevious, ;
	nCurrent
	
	Dimension aTokens[1]
	nCurrent = 1

	Procedure Init(taTokens)
		=Acopy(taTokens, this.aTokens)
	EndProc
	
	Function parse
		Local loTables, loNode, loToken
		loToken = Createobject("Token", ttProgram, "", 0, 0, 0)
		loTables = this.parseTables()
		Return CreateObject("Node", loToken, loTables)
	EndFunc
	
	Hidden function parseTables
		Local loTables
		loTables = CreateObject("Collection")
		
		Do while !this.isAtEnd() and this.match(ttMinus)
			this.consume(ttTable, "Se esperaba el atributo 'table'")
			loTables.Add(this.tableDeclaration())
		EndDo

		Return loTables
	EndFunc

	Hidden function declaration
		Local loNode
		loNode = .null.
		Try
			If IsNull(loNode) and this.match(ttDescription)
				loNode = this.parseAttribute('description', ttString)
			EndIf
			If IsNull(loNode) and this.match(ttFields)
				loNode = this.parseCollection('fields', .t.)
			EndIf
			If IsNull(loNode) and this.match(ttName)
				loNode = this.parseAttribute('name', ttIdent, ttString)
			EndIf
			If IsNull(loNode) and this.match(ttType)
				loNode = this.parseType()
			EndIf
			If IsNull(loNode) and this.match(ttSize)
				loNode = this.parseAttribute('size', ttNumber)
			EndIf
			If IsNull(loNode) and this.match(ttDecimal)
				loNode = this.parseAttribute('decimal', ttNumber)
			EndIf			
			If IsNull(loNode) and this.match(ttPrimaryKey)
				loNode = this.parseAttribute('primaryKey', ttTrue, ttFalse)
			EndIf
			If IsNull(loNode) and this.match(ttAutoIncrement)
				loNode = this.parseAttribute('autoIncrement', ttTrue, ttFalse)
			EndIf
			If IsNull(loNode) and this.match(ttAllowNull)
				loNode = this.parseAttribute('allowNull', ttTrue, ttFalse)
			EndIf
			If IsNull(loNode) and this.match(ttDefault)
				loNode = this.parseAttribute('default', ttTrue, ttFalse, ttNumber, ttString)
			EndIf
			If IsNull(loNode) and this.match(ttForeignKey)
				loNode = this.parseCollection('foreignKey', .f.)
			EndIf
			If IsNull(loNode) and this.match(ttOnDelete)
				loNode = this.parseAttribute('onDelete', ttCascade, ttNull, ttDefault, ttRestrict)
			EndIf
			If IsNull(loNode) and this.match(ttOnUpdate)
				loNode = this.parseAttribute('onUpdate', ttCascade, ttNull, ttDefault, ttRestrict)
			EndIf
			If IsNull(loNode) and this.match(ttFkTable)
				loNode = this.parseAttribute('fkTable', ttIdent, ttString)
			EndIf
			If IsNull(loNode) and this.match(ttFkField)
				loNode = this.parseAttribute('fkField', ttIdent, ttString)
			EndIf
			If IsNull(loNode) and this.match(ttIndex)
				loNode = this.parseAttribute('index', ttTrue, ttFalse)
			EndIf
			If IsNull(loNode) and this.match(ttColumns)
				loNode = this.parseColumns()
			EndIf
			If IsNull(loNode) and this.match(ttSort)
				loNode = this.parseAttribute('sort', ttAsc, ttDesc)
			EndIf
			If IsNull(loNode) and this.match(ttUnique)
				loNode = this.parseAttribute('unique', ttTrue, ttFalse)
			EndIf
		Catch to loEx
			* TODO(irwin): sinchronyze
		EndTry
		If IsNull(loNode)
			MessageBox("No se pudo encontrar una función de anális para el token: " + tokenName(this.oPeek.nType), 16)
		EndIf
		Return loNode
	EndFunc
	
	Hidden function tableDeclaration		
		Local loToken, loAttributes, loNode
		loToken = this.oPrevious
		this.consume(ttColon, "Se esperaba el símbolo ':' luego del atributo 'table'")
		this.consume(ttNewLine, "Se esperaba un salto de línea")				
		loAttributes = CreateObject("Collection")

		Do while !this.isAtEnd() and this.oPeek.nKind == tkIdent
			loNode = this.declaration()
			If IsNull(loNode)
				Exit
			EndIf
			loAttributes.Add(loNode)
		EndDo
				
		Return CreateObject("Node", loToken, loAttributes)
	EndFunc
	
	Hidden function parseCollection(tcName, tbCheckMinus)
		Local loToken, loFieldsList, loAttributes, loNode
		loToken = this.oPrevious
		this.consume(ttColon, "Se esperaba el símbolo ':' luego del atributo '" + tcName + "'")
		this.consume(ttNewLine, "Se esperaba un salto de línea")
		loFieldsList = CreateObject("Collection")
		
		Do while !this.isAtEnd()
			If tbCheckMinus
				If this.oPeek.nType == ttMinus and this.oPeekNext.nType == ttName
					this.match(ttMinus)
				Else
					exit
				EndIf
			EndIf
			loAttributes = CreateObject("Collection")
			Do while this.oPeek.nKind == tkIdent
				loNode = this.declaration()
				If IsNull(loNode)
					Exit
				endif
				loAttributes.Add(loNode)
			EndDo
			loFieldsList.Add(loAttributes)
			If !tbCheckMinus
				Exit
			EndIf
		EndDo		
		
		Return CreateObject("Node", loToken, loFieldsList)
	EndFunc

	Hidden function parseAttribute(tcName, tnType1, tnType2, tnType3, tnType4)
		Local loToken, lvValue, i, llMatched
		loToken = this.oPrevious
		this.consume(ttColon, "Se esperaba el símbolo ':' luego del atributo '" + tcName + "'")
		llMatched = .f.
		
		For i = 1 to Pcount()-1
			llMatched = this.match(Evaluate('tnType' + Alltrim(Str(i))))
			If llMatched
				exit
			EndIf
		EndFor
		If !llMatched
			* TODO(irwin): mostrar mensaje
			MessageBox("Valor inválido para el atributo '" + tcName + "'", 16)
			Return .null.
		EndIf

		lvValue = this.oPrevious.vLiteral
		this.consume(ttNewLine, "Se esperaba un salto de línea")

		Return CreateObject("Node", loToken, lvValue)
	EndFunc
	
	Hidden function parseColumns
		Set Step On
		Local loToken, lvValue
		loToken = this.oPrevious
		If this.match(ttLeftBracket)
			lvValue = CreateObject("Collection")
			Do while !this.isAtEnd()
				If !this.match(ttString) and !this.match(ttIdent)
					MessageBox("Se esperaba el nombre de una columna.", 16)
					Return .null.
				EndIf
				lvValue.Add(this.oPrevious)
				If !this.match(ttComma)
					Exit
				EndIf
			EndDo
			this.consume(ttRightBracket, "Se esperaba ']' tras el nombre de la columna", 16)
		Else
			If !this.match(ttString) and !this.match(ttIdent)
				MessageBox("Se esperaba el nombre de una columna.", 16)
				Return .null.
			EndIf
			lvValue = this.oPrevious
		EndIf
		Return CreateObject("Node", loToken, lvValue)
	EndFunc
	
	Hidden function parseType
		Local loToken, loTokenType
		loToken = this.oPrevious
		this.consume(ttColon, "Se esperaba el símbolo ':' luego del atributo 'type'")	
		If !Between(this.oPeek.nType, 200, 299)
			MessageBox("Se esperaba un tipo de dato pero se obtuvo: " + this.oPeek.cLexeme, 16)
			Return .null.
		EndIf
		loTokenType = this.advance()
		
		this.consume(ttNewLine, "Se esperaba un salto de línea")
		Return CreateObject("Node", loToken, loTokenType)
	EndFunc
	
	Hidden function match(t1, t2, t3)
		Local i		
		For i=1 to Pcount()
			If this.check(Evaluate('t' + Alltrim(Str(i))))
				this.advance()
				Return .t.
			endif
		EndFor
		Return .f.
	EndFunc
	
	Hidden function consume(tnType, tcMessage)
		If this.check(tnType)
			Return this.advance()
		EndIf

		Error tcMessage
	EndFunc
	
	Hidden function check(tnType)
		If this.isAtEnd()
			Return .f.
		EndIf
		Return this.oPeek.nType == tnType
	EndFunc
	
	Hidden function advance
		If !this.isAtEnd()
			this.nCurrent = this.nCurrent + 1
		EndIf
		Return this.oPrevious
	EndFunc
	
	Hidden Function isAtEnd
		Return this.oPeek.nType == ttEOF
	EndFunc
	
	Hidden Function oPeek_Access
		Return this.aTokens[this.nCurrent]
	EndFunc
	
	Hidden Function oPeekNext_Access
		Local lnNext
		lnNext = this.nCurrent + 1
		If lnNext <= Alen(this.aTokens)
			Return this.aTokens[lnNext]
		EndIf
		Return Createobject("Token", ttProgram, "", 0, 0, 0)
	EndFunc	
	
	Hidden function oPrevious_Access
		Return this.aTokens[this.nCurrent-1]
	EndFunc
EndDefine

* =================================================================================== *
* Evaluator Class
* =================================================================================== *
Define Class Interpreter as Custom
	Function interpret(toNode)
		Local lnType
		lnType = toNode.oToken.nType
		Do case
		Case lnType = ttProgram
			Return this.evaluateProgram(toNode)
		Otherwise
		EndCase
	EndFunc
	
	Hidden function evaluateProgram(toNode)				
		Return this.evalTable(toNode.vValue)
	EndFunc
	
	Hidden function evalTable(toTable)
		Local loTablesList
		loTablesList = CreateObject("Collection")
				
		For each loTable in toTable
			Local loTableData, loFieldFk
			loTableData = CreateObject("Empty")
			loFieldFk = CreateObject("Empty")
			* Table metadata
			AddProperty(loTableData, "cTableName", "")
			AddProperty(loTableData, "cTableDescription", "")
			AddProperty(loTableData, "aTableFields[1]", .null.)
			* Field metadata
			AddProperty(loFieldFk, "cTable", "")
			AddProperty(loFieldFk, "cField", "")
			AddProperty(loFieldFk, "cCurrentField", "")
			AddProperty(loFieldFk, "cOnDelete", "DEFAULT")
			AddProperty(loFieldFk, "cOnUpdate", "DEFAULT")

			For each loAttribute in loTable.vValue
				Do case
				Case loAttribute.oToken.nType == ttName
					loTableData.cTableName = loAttribute.vValue
				Case loAttribute.oToken.nType == ttDescription
					loTableData.cTableDescription = loAttribute.vValue
				Case loAttribute.oToken.nType == ttFields
					Local laFields[loAttribute.vValue.count, 22], i
					i = 0
					For each loNode in loAttribute.vValue
						i = i + 1
						* The following are not used values.
						laFields[i, 3] = 0		 && Size
						laFields[i, 4] = 0		 && Decimal places (for doble, float)
						laFields[i, 5] = .t.	 && Allow null values
						laFields[i, 6] = .f. 	 && Code page translation not allowed
						laFields[i, 7] = "" 	 && Field validation expression
						laFields[i, 8] = "" 	 && Field validation text
						laFields[i, 9] = "" 	 && Field default value
						laFields[i, 10] = "" 	 && Table validation expression
						laFields[i, 11] = "" 	 && Table validation text
						laFields[i, 12] = "" 	 && Long table name
						laFields[i, 13] = "" 	 && Insert trigger expression
						laFields[i, 14] = "" 	 && Update trigger expression
						laFields[i, 15] = "" 	 && Delete trigger expression
						laFields[i, 16] = ""	 && Description
						laFields[i, 17] = 0 	 && NextValue for autoincrement
						laFields[i, 18] = 0 	 && Step for autoincrement
						laFields[i, 19] = "" 	 && Default value
						laFields[i, 20] = .f.	 && PrimaryKey
						laFields[i, 21] = .null. && ForeignKey metadata
						laFields[i, 22] = .f.	 && AutoIncrement

						For each loField in loNode
							Do case
							Case loField.oToken.nType == ttName
								laFields[i, 1] = loField.vValue
							Case loField.oToken.nType == ttType
								laFields[i, 2] = typeToLetter(loField.vValue.vLiteral)
							Case loField.oToken.nType == ttSize
								laFields[i, 3] = loField.vValue
							Case loField.oToken.nType == ttDecimal
								laFields[i, 4] = loField.vValue
							Case loField.oToken.nType == ttAllowNull
								laFields[i, 5] = (loField.vValue == "true")
							Case loField.oToken.nType == ttDefault
								laFields[i, 19] = loField.vValue
							Case loField.oToken.nType == ttDescription
								laFields[i, 16] = loField.vValue
							Case loField.oToken.nType == ttAutoIncrement
								laFields[i, 22] = (loField.vValue == "true")
							Case loField.oToken.nType == ttPrimaryKey
								laFields[i, 20] = (loField.vValue == "true")
							Case loField.oToken.nType == ttForeignKey
								For each loNode2 in loField.vValue
									loFieldFk.cTable = ""
									loFieldFk.cField = ""
									loFieldFk.cCurrentField = laFields[i, 1]
									loFieldFk.cOnDelete = "DEFAULT"
									loFieldFk.cOnUpdate = "DEFAULT"

									For each loField2 in loNode2 
										Do case
										Case loField2.oToken.nType == ttFkTable
											loFieldFk.cTable = loField2.vValue
										Case loField2.oToken.nType == ttFkField
											loFieldFk.cField = loField2.vValue
										Case loField2.oToken.nType == ttOnDelete
											loFieldFk.cOnDelete = loField2.vValue
										Case loField2.oToken.nType == ttOnUpdate
											loFieldFk.cOnUpdate = loField2.vValue
										Otherwise
											MessageBox("Atributo inválido para la definición de una clave foránea: `" + tokenName(loField2.oToken.nType) + "`", 16)
										EndCase					
									EndFor
								EndFor
								laFields[i, 21] = loFieldFk
							Otherwise
								MessageBox("Atributo inválido para la definición de un campo: `" + tokenName(loField.oToken.nType) + "`", 16)
							EndCase
						EndFor
					EndFor				
				Otherwise
					MessageBox("Atributo inválido para la definición de una tabla: `" + tokenName(loAttribute.oToken.nType) + "`", 16)
				EndCase			
			EndFor
			=Acopy(laFields, loTableData.aTableFields)
			loTablesList.Add(loTableData)
		EndFor

		Return loTablesList
	EndFunc
	
*!*		Hidden function evalTable(toTable)
*!*			Local loTableData, loFieldFk
*!*			loTableData = CreateObject("Empty")
*!*			loFieldFk = CreateObject("Empty")
*!*			* Table metadata
*!*			AddProperty(loTableData, "cTableName", "")
*!*			AddProperty(loTableData, "cTableDescription", "")
*!*			AddProperty(loTableData, "aTableFields[1]", .null.)
*!*			* Field metadata
*!*			AddProperty(loFieldFk, "cTable", "")
*!*			AddProperty(loFieldFk, "cField", "")
*!*			AddProperty(loFieldFk, "cCurrentField", "")
*!*			AddProperty(loFieldFk, "cOnDelete", "DEFAULT")
*!*			AddProperty(loFieldFk, "cOnUpdate", "DEFAULT")
*!*			
*!*			For each loTable in toTable
*!*				*loTable = toTable(1) && Index 1 is the only table.		
*!*				For each loAttribute in loTable.vValue
*!*					Do case
*!*					Case loAttribute.oToken.nType == ttName
*!*						loTableData.cTableName = loAttribute.vValue
*!*					Case loAttribute.oToken.nType == ttDescription
*!*						loTableData.cTableDescription = loAttribute.vValue
*!*					Case loAttribute.oToken.nType == ttFields
*!*						Local laFields[loAttribute.vValue.count, 22], i
*!*						i = 0
*!*						For each loNode in loAttribute.vValue
*!*							i = i + 1
*!*							* The following are not used values.
*!*							laFields[i, 3] = 0		 && Size
*!*							laFields[i, 4] = 0		 && Decimal places (for doble, float)
*!*							laFields[i, 5] = .t.	 && Allow null values
*!*							laFields[i, 6] = .f. 	 && Code page translation not allowed
*!*							laFields[i, 7] = "" 	 && Field validation expression
*!*							laFields[i, 8] = "" 	 && Field validation text
*!*							laFields[i, 9] = "" 	 && Field default value
*!*							laFields[i, 10] = "" 	 && Table validation expression
*!*							laFields[i, 11] = "" 	 && Table validation text
*!*							laFields[i, 12] = "" 	 && Long table name
*!*							laFields[i, 13] = "" 	 && Insert trigger expression
*!*							laFields[i, 14] = "" 	 && Update trigger expression
*!*							laFields[i, 15] = "" 	 && Delete trigger expression
*!*							laFields[i, 16] = ""	 && Description
*!*							laFields[i, 17] = 0 	 && NextValue for autoincrement
*!*							laFields[i, 18] = 0 	 && Step for autoincrement
*!*							laFields[i, 19] = "" 	 && Default value
*!*							laFields[i, 20] = .f.	 && PrimaryKey
*!*							laFields[i, 21] = .null. && ForeignKey metadata
*!*							laFields[i, 22] = .f.	 && AutoIncrement

*!*							For each loField in loNode
*!*								Do case
*!*								Case loField.oToken.nType == ttName
*!*									laFields[i, 1] = loField.vValue
*!*								Case loField.oToken.nType == ttType
*!*									laFields[i, 2] = typeToLetter(loField.vValue.vLiteral)
*!*								Case loField.oToken.nType == ttSize
*!*									laFields[i, 3] = loField.vValue
*!*								Case loField.oToken.nType == ttDecimal
*!*									laFields[i, 4] = loField.vValue
*!*								Case loField.oToken.nType == ttAllowNull
*!*									laFields[i, 5] = (loField.vValue == "true")
*!*								Case loField.oToken.nType == ttDefault
*!*									laFields[i, 19] = loField.vValue
*!*								Case loField.oToken.nType == ttDescription
*!*									laFields[i, 16] = loField.vValue
*!*								Case loField.oToken.nType == ttAutoIncrement
*!*									laFields[i, 22] = (loField.vValue == "true")
*!*								Case loField.oToken.nType == ttPrimaryKey
*!*									laFields[i, 20] = (loField.vValue == "true")
*!*								Case loField.oToken.nType == ttForeignKey
*!*									For each loNode2 in loField.vValue
*!*										loFieldFk.cTable = ""
*!*										loFieldFk.cField = ""
*!*										loFieldFk.cCurrentField = laFields[i, 1]
*!*										loFieldFk.cOnDelete = "DEFAULT"
*!*										loFieldFk.cOnUpdate = "DEFAULT"

*!*										For each loField2 in loNode2 
*!*											Do case
*!*											Case loField2.oToken.nType == ttFkTable
*!*												loFieldFk.cTable = loField2.vValue
*!*											Case loField2.oToken.nType == ttFkField
*!*												loFieldFk.cField = loField2.vValue
*!*											Case loField2.oToken.nType == ttOnDelete
*!*												loFieldFk.cOnDelete = loField2.vValue
*!*											Case loField2.oToken.nType == ttOnUpdate
*!*												loFieldFk.cOnUpdate = loField2.vValue
*!*											Otherwise
*!*												MessageBox("Atributo inválido para la definición de una clave foránea: `" + tokenName(loField2.oToken.nType) + "`", 16)
*!*											EndCase					
*!*										EndFor
*!*									EndFor
*!*									laFields[i, 21] = loFieldFk
*!*								Otherwise
*!*									MessageBox("Atributo inválido para la definición de un campo: `" + tokenName(loField.oToken.nType) + "`", 16)
*!*								EndCase
*!*							EndFor
*!*						EndFor				
*!*					Otherwise
*!*						MessageBox("Atributo inválido para la definición de una tabla: `" + tokenName(loAttribute.oToken.nType) + "`", 16)
*!*					EndCase			
*!*				EndFor
*!*			EndFor
*!*			=Acopy(laFields, loTableData.aTableFields)

*!*			Return loTableData
*!*		EndFunc

EndDefine

* =================================================================================== *
* Token Class
* =================================================================================== *
Define Class Token As Custom
	nType = 0
	nKind = 0
	cLexeme = ''
	vLiteral = .Null.
	nLine = 0
	nCol = 0

	Procedure Init(tnType, tcLexeme, tvLiteral, tnLine, tnCol)
		This.nType = tnType
		This.cLexeme = Iif(Type('tcLexeme') != 'C', '', tcLexeme)
		This.vLiteral = tvLiteral
		This.nLine = Iif(Type('tnLine') != 'N', 0, tnLine)
		this.nCol = Iif(Type('tnCol') != 'N', 0, tnCol)
	Endproc

	Function toString
		Try
			Local lcString
			lcString = "[" + Alltrim(Str(This.nLine)) + ":" + Alltrim(Str(This.nCol)) + "](" + TokenName(This.nType) + ", " + Transform(This.vLiteral) + ")"
		Catch to loEx
			MessageBox(loEx.message)
		EndTry
		Return lcString
	Endfunc
Enddefine

* =================================================================================== *
* TokenName
* =================================================================================== *
Function tokenName(tnType)
	DO CASE
	Case tnType == 100
		Return "ttTable"
	Case tnType == 101
		Return "ttDescription"
	Case tnType == 102
		Return "ttFields"
	Case tnType == 103
		Return "ttName"
	Case tnType == 104
		Return "ttType"
	Case tnType == 105
		Return "ttSize"
	Case tnType == 106
		Return "ttPrimaryKey"
	Case tnType == 107
		Return "ttAllowNull"
	Case tnType == 108
		Return "ttDefault"
	Case tnType == 109
		Return "ttForeignKey"
	Case tnType == 110
		Return "ttFkTable"
	Case tnType == 111
		Return "ttFkField"
	Case tnType == 112
		Return "ttOnDelete"
	Case tnType == 113
		Return "ttOnUpdate"
	Case tnType == 114
		Return "ttCascade"
	Case tnType == 115
		Return "ttUpdate"
	Case tnType == 116
		Return "ttNull"
	Case tnType == 117
		Return "ttIndex"
	Case tnType == 118
		Return "ttColumns"
	Case tnType == 119
		Return "ttSort"
	Case tnType == 120
		Return "ttUnique"
	Case tnType == 121
		Return "ttAsc"
	Case tnType == 122
		Return "ttDesc"
	Case tnType == 200
		Return "ttChar"
	Case tnType == 201
		Return "ttVarchar"
	Case tnType == 202
		Return "ttDecimal"
	Case tnType == 203
		Return "ttDate"
	Case tnType == 204
		Return "ttDateTime"
	Case tnType == 205
		Return "ttDouble"
	Case tnType == 206
		Return "ttFloat"
	Case tnType == 207
		Return "ttInt"
	Case tnType == 208
		Return "ttBool"
	Case tnType == 209
		Return "ttText"
	Case tnType == 210
		Return "ttVarBinary"
	Case tnType == 211
		Return "ttBlob"
	Case tnType == 21
		Return "ttIdent"
	Case tnType == 22
		Return "ttNumber"
	Case tnType == 23
		Return "ttString"
	Case tnType == 24
		Return "ttEof"
	Case tnType == 25
		Return "ttColon"
	Case tnType == 26
		Return "ttMinus"
	Case tnType == 27
		Return "ttTrue"
	Case tnType == 28
		Return "ttFalse"
	Case tnType == 29
		Return "ttAutoIncrement"
	Case tnType == 30
		Return "ttNewLine"
	Case tnType == 31
		Return "ttProgram"
	Case tnType == 32
		Return "ttComma"
	Case tnType == 33
		Return "ttLeftBracket"
	Case tnType == 34
		Return "ttRightBracket"
	Otherwise
	EndCase
EndFunc

* ========================================================================= *
* Node
* ========================================================================= *
Define Class Node as Custom
	oToken = .null.
	vValue = .null.
	
	Procedure init(toToken, tvValue)
		this.oToken = toToken
		this.vValue = tvValue
	endproc
EndDefine

* ======================================================================== *
* Class RemoteCursor
* ======================================================================== *
Define Class RemoteCursor As CursorAdapter
	Database = ""
	Alias = ""
	SelectCmd = ""
	Tables = ""
	KeyFieldList = ""
	SendUpdates = .f.
	Nodata = .f.
EndDefine

* ======================================================================== *
* Function typeToLetter
* ======================================================================== *
Function typeToLetter(tcType)
	tcType = Lower(tcType)
	DO CASE
	CASE tcType == "char"
		Return "C"
	CASE tcType == "currency"
		Return "Y"
	CASE tcType == "date"
		Return "D"
	CASE tcType == "datetime"
		Return "T"
	CASE tcType == "double"
		Return "B"
	CASE tcType == "float"
		Return "F"
	CASE tcType == "int"
		Return "I"
	CASE tcType == "bool"
		Return "L"
	CASE tcType == "text"
		Return "M"
	CASE tcType == "numeric"
		Return "N"
	CASE tcType == "varbinary"
		Return "Q"
	CASE InList(tcType, "string", "varchar")
		Return "V"
	CASE tcType == "blob"
		Return "W"
	OTHERWISE
		MessageBox("Tipo de dato desconocido: '" + tcType + "'")
		Return Space(1)
	ENDCASE
EndFunc

* ======================================================================== *
* Class DBEngine
* ======================================================================== *
Define Class DBEngine As Custom

	cDriver		= ""
	cServer		= ""
	cUser		= ""
	cPassword	= ""
	cDatabase 	= ""
	nPort		= 0
	cVersion	= "0.0.1"
	bUseCA		= .T.
	bUseDelimiter = .F.
	cPKName		= "TID"

	Dimension aCustomArray[1]
	Hidden nCounter
	nCounter = 0

	Hidden oRegEx, oViews, oGroupViews, nHandle

	Procedure Init
		With This
			.oViews = Createobject("Collection")
			.oGroupViews = Createobject("Collection")
			.oRegEx = Createobject("VBScript.RegExp")
			.oRegEx.IgnoreCase = .T.
			.oRegEx.Global = .T.
			.nHandle = 0
		Endwith
	Endproc

	Procedure Connect

		If This.nHandle > 0
			If This.reconnect()
				Return
			Endif
		Endif

		Local lcConStr
		Try
			lcConStr = This.getConnectionString()
			This.nHandle = Sqlstringconnect(lcConStr, .T.)

			If This.nHandle <= 0
				This.sqlError()
			Endif
			This.applyConnectionSettings()
			If !Empty(this.cDatabase)
				this.newDataBase(this.cDatabase)
				this.selectDatabase()
			EndIf			
		Catch To loEx
			This.printException(loEx)
		Endtry
	Endproc
	
	Function newDataBase(tcDataBase)
		If Lower(this.Name) == "firebird"
			Return .t.
		EndIf
		Local lcScript, lcCursor, lcDBName
		lcCursor = Sys(2015)
		lcScript = this.getDataBaseExistsScript(tcDataBase)
		If !This.SQLExec(lcScript, lcCursor)
			Return .F.
		EndIf
		
		Select (lcCursor)
		lcDBName = &lcCursor..dbName
		Use in (lcCursor)
		
		If !Empty(lcDBName)
			Return .t.
		EndIf
		
		lcScript = this.getCreateDataBaseScript(tcDataBase)
		If !This.SQLExec(lcScript)
			Return .F.
		EndIf
		Return .t.		
	EndFunc

	Function use(tcTable, tcFields, tcCriteria, tcGroup, tbReadOnly, tbNodata)
		Local lcSqlTableName, lcAlias

		this.getTableAndAlias(tcTable, @lcSqlTableName, @lcAlias)
		
		If Used(lcAlias)
			Return .f.
		EndIf

		If !This.tableExists(lcSqlTableName)
			MessageBox("La tabla " + lcSqlTableName + " no existe en la base de datos.", 16)
			Return .f.
		Endif

		Local lcPrimaryKey, lcSelectCMD, loView
		
		lcPrimaryKey = this.getKeyField(lcSqlTableName)
		lcSelectCMD = this.getSelectCommand(lcSqlTableName, tcFields, tcCriteria)

		If this.bUseCA
			Local i, lcUpdaTableFieldList, lcUpdateNameList, lcField, laFields[1]
			loView = Createobject('CursorAdapter')
			=AddProperty(loView, "Database", this.cDatabase)
			loView.DataSourceType = 'ODBC'
			loView.Datasource = This.nHandle
			loView.Alias = lcAlias
			loView.SelectCmd = lcSelectCMD
			loView.Tables = lcSqlTableName
			loView.KeyFieldList = lcPrimaryKey
			loView.SendUpdates = !tbReadOnly

			* Traer solo estructura para extraer información de las columnas.
			loView.Nodata = .T.
			If !loView.CursorFill()
				this.sqlError()
				Return .f.
			EndIf
			
			Select (lcAlias)
			Store '' To lcUpdaTableFieldList, lcUpdateNameList
			For i=1 To Afields(laFields)
				lcField = laFields[i,1]
				lcUpdaTableFieldList = lcUpdaTableFieldList + lcField + ','
				lcUpdateNameList = lcUpdateNameList + lcField + Space(1) + lcSqlTableName + '.' + lcField + ','
			EndFor
			
			lcUpdaTableFieldList = Substr(lcUpdaTableFieldList, 1, Len(lcUpdaTableFieldList)-1)
			lcUpdateNameList = Substr(lcUpdateNameList, 1, Len(lcUpdateNameList)-2)
						
			loView.UpdatableFieldList = lcUpdaTableFieldList
			loView.UpdateNameList = lcUpdateNameList
			loView.Nodata = tbNodata

			If !loView.CursorFill()
				this.sqlError()
				Return .f.
			EndIf

			=CursorSetProp("FetchSize", -1, lcAlias)
			* Esperar hasta completar todos los registros para eviar error 'Connection is Busy'
			Do While SQLGetprop(This.nHandle, "ConnectBusy")
				Wait Window "Recuperando información de la tabla actual, espere..."  Nowait				
				=Inkey(0.3, "H")				
				Doevents				
			EndDo			
			Wait Clear
			Go top in (lcAlias)
		Else
			If !This.SQLExec(lcSelectCMD, lcAlias)
				Return .F.
			Endif

			loView = Createobject('RemoteCursor')
			With loView
				.Database = This.cDatabase
				.Alias = lcAlias
				.SelectCmd = lcSelectCMD
				.Tables = lcSqlTableName
				.KeyFieldList = lcPrimaryKey
				.SendUpdates = !tbReadOnly
				.Nodata = tbNodata
			EndWith
		EndIf
		If !tbReadOnly
			=CursorSetProp("Buffering", 5, lcAlias)
		EndIf

		This.oViews.Add(loView, Lower(lcAlias))

		If !Empty(tcGroup)
			This.addViewToGroup(Lower(tcGroup), Lower(lcAlias))
		EndIf
		Select (lcAlias)
		Return .t.
	Endproc

	Procedure changeDB(tcNewDatabase)
		If Empty(tcNewDatabase)
			Return
		Endif
		This.cDatabase = tcNewDatabase
		This.selectDatabase()
	Endproc

	Procedure requery(tcAlias)
		If Empty(tcAlias)
			tcAlias = Alias()
		EndIf

		Select (tcAlias)		
		Local lnIndex, loView, lcCursor
		lnIndex = This.oViews.GetKey(Lower(tcAlias))
		If Empty(lnIndex)
			Return .F.
		Endif			
		loView = This.oViews.Item(lnIndex)		
		If this.bUseCA
			If loView.sendUpdates
				=Requery(tcAlias)
			EndIf
		Else			
			If loView.sendUpdates				
				=TableRevert(.t.)
				Delete from (tcAlias)

				lcCursor = Sys(2015)
				this.sqlExec(loView.SelectCMD, lcCursor)

				Select (tcAlias)
				Append From Dbf(lcCursor)
				Use in (lcCursor)
			EndIf
		EndIf
	EndProc

	Procedure discard(tcAlias)
		If Empty(tcAlias)
			tcAlias = Alias()
		EndIf

		Local lnIndex, loView, lcCursor
		lnIndex = This.oViews.GetKey(Lower(tcAlias))
		If Empty(lnIndex)
			Return .F.
		Endif			
		loView = This.oViews.Item(lnIndex)		
		If loView.sendUpdates
			=TableRevert(.t.)
		EndIf
	endproc

	Function saveAndClose(tcAlias)
		If This.Save(tcAlias)
			This.Close(tcAlias)
		EndIf
	EndFunc

	function Save(tcAlias)

		If Empty(tcAlias)
			tcAlias = Alias()
		Endif

		Local lnOldTransactionSeting, lnIndex, lbOk, loView, loEnv

		lnOldTransactionSeting = SQLGetprop(This.nHandle, "Transactions")
		=SQLSetprop(This.nHandle, "Transactions", 2) && Change to manual transactions

		lnIndex = This.oViews.GetKey(Lower(tcAlias))
		If Empty(lnIndex)
			Return .F.
		Endif
		loEnv = this.setEnvironment()
		loView = This.oViews.Item(lnIndex)
		If !loView.SendUpdates
			Return .F.
		EndIf

		Begin Transaction
		This.beginTransaction()
		Select (tcAlias)
		
		If this.bUseCA
			lbOk = Tableupdate(.T.)
		Else
			lbOk = .T.
			Select (tcAlias)
			Local nNextRec, lcTypeOpe, lcFldState, lcCommand, lcOpenChar, lcCloseChar, lcSQLTable, lcScript, laFields[1], laDateFields[1]
			
			lcOpenChar  = This.getOpenNameSymbol()
			lcCloseChar = This.getCloseNameSymbol()
			lcSQLTable  = loView.Tables
			lcKeyField  = loView.KeyFieldList			
			lcScript	= Space(1)
			nNextRec 	= Getnextmodified(0, tcAlias)
			AFields(laFields)
			laDateFields = this.getDateTimeFields(@laFields)

			Do While nNextRec <> 0
				Go nNextRec in (tcAlias)
				lvKeyValue  = Evaluate(tcAlias + '.' + lcKeyField)
				lcScript	= Space(1)
				lcFldState  = GetFldState(-1)
				
				If nNextRec > 0 && UPDATE			
					Do case
					case Left(lcFldState, 1) == '1' && UPDATE
						lcScript = this.updateRowScript(lcOpenChar, lcCloseChar, lcSQLTable, lcKeyField, lcFldState)
						Scatter memo name loRow
						this.updateFetchedRow(@laDateFields, loRow)
					Case Left(lcFldState, 1) == '2' && DELETE
						lcScript = "DELETE FROM " + lcOpenChar + lcSQLTable + lcCloseChar + " WHERE " + lcOpenChar + lcKeyField + lcCloseChar + "=?lvKeyValue"
					EndCase
				Else && INSERT
					If this.rowExists(lcOpenChar, lcCloseChar, lcSQLTable, lcKeyField, lvKeyValue)
						lcScript = this.updateRowScript(lcOpenChar, lcCloseChar, lcSQLTable, lcKeyField, lcFldState)
						Scatter memo name loRow
						this.updateFetchedRow(@laDateFields, loRow)
					Else
						Local j, laInsFields[1], lcFieldsScript, lcValuesScript
					
						laInsFields = this.getAffectedFields(lcFldState, @laFields)
						* Iterate fields
						lcFieldsScript = Space(1)
						lcValuesScript = Space(1)

						For j=1 To Alen(laInsFields, 1)
							If Upper(laInsFields[j]) == Upper(this.cPKName)
								Loop
							EndIf
							lcFieldsScript = lcFieldsScript + lcOpenChar + laInsFields[j] + lcCloseChar + ','
							lcValuesScript = lcValuesScript + '?loRow.' + laInsFields[j] + ','
						EndFor
						
						lcFieldsScript = Substr(lcFieldsScript, 1, Len(lcFieldsScript)-1)
						lcValuesScript = Substr(lcValuesScript, 1, Len(lcValuesScript)-1)

						Scatter Memo Name loRow
						this.updateFetchedRow(@laDateFields, loRow)
						lcScript = "INSERT INTO " + lcOpenChar + lcSQLTable + lcCloseChar + " (" + lcFieldsScript + ")"
						lcScript = lcScript + " VALUES (" + lcValuesScript + ");"					
					EndIf															
				EndIf

				If !Empty(lcScript)
					If !this.sqlExec(lcScript)
						lbOk = .F.
						Exit
					EndIf
				EndIf
				nNextRec = Getnextmodified(nNextRec, tcAlias)
			Enddo
		EndIf

		If lbOk
			This.endTransaction()
			End Transaction
		Else
			This.cancelTransaction()
			Rollback
		EndIf

		=SQLSetprop(This.nHandle, "Transactions", lnOldTransactionSeting)
		this.restoreEnvironment(loEnv)
		Return lbOk
	endfunc

	function saveGroup(tcGroup)
		If Empty(tcGroup)
			Return .F.
		Endif
		Local lnIndex, loViews, i, lbOk, loView, lcScript, lcAlias, lnOldTransactionSeting
		lnIndex = This.oGroupViews.GetKey(Lower(tcGroup))
		If Empty(lnIndex)
			Return .F.
		Endif

		lcScript = 'set datasession to ' + Alltrim(Str(Set("Datasession"))) + CRLF
		loViews = This.oGroupViews.Item(lnIndex)
		If Empty(loViews.Count)
			Return .F.
		Endif

		lnOldTransactionSeting = SQLGetprop(This.nHandle, "Transactions")
		SQLSetprop(This.nHandle, "Transactions", 2) && Change to manual transactions

		Begin Transaction
		This.beginTransaction()

		For i=1 To loViews.Count
			lcAlias = loViews.Item(i)
			loView = This.oViews.Item(lcAlias)
			If !loView.SendUpdates
				Loop && Ignore cursor
			Endif
			lcScript = lcScript + "select " + loView.Alias + CRLF
			lcScript = lcScript + "=TableRevert(.T.) " + CRLF
			Select (loView.Alias)
			lbOk = Tableupdate(.T.)
			If !lbOk
				Exit
			Endif
		Endfor

		If lbOk
			This.endTransaction()
			End Transaction
		Else
			This.sqlError()
			This.cancelTransaction()
			Rollback
			=Execscript(lcScript)
		Endif
		SQLSetprop(This.nHandle, "Transactions", lnOldTransactionSeting)

		Return lbOk
	EndFunc

	Procedure Close(tcAlias)

		If Empty(tcAlias)
			tcAlias = Alias()
		Endif

		If !Used(tcAlias)
			Return .F.
		Endif

		Local lnIndex, lcAlias, loView

		* Intentamos buscar como Vista
		lnIndex = This.oViews.GetKey(Lower(tcAlias))
		If Empty(lnIndex)
			Return .F.
		Endif
		loView = This.oViews.Item(lnIndex)
		Select (tcAlias)

		If loView.SendUpdates
			=Tablerevert(.T.) && just in case there's pending changes.
		Endif
		Use

		* Release the cursorAdapter allocated in global scope.
		This.oViews.Remove(lnIndex)
		Release loView

		Return .T.
	Endproc

	Procedure closeAll
		Try
			Local i, loView, lcAlias
			lcAlias = Alias()
			For i = 1 To This.oViews.Count
				loView = This.oViews.Item(i)
				If Used(loView.Alias)
					Select (loView.Alias)
					If loView.SendUpdates
						Tablerevert(.T.) && Revert pending changes
					Endif
					Use
				Endif
				Release loView
			Endfor
			If !Empty(lcAlias) And Used(lcAlias)
				Select (lcAlias)
			Endif
			This.oViews = Createobject('Collection')		&& Reset all created views.
			This.oGroupViews = Createobject('Collection')	&& Reset all created groups.
		Catch
		Endtry
	Endproc

	Procedure closeGroup(tcGroup)

		If Empty(tcGroup)
			Return .F.
		Endif
		Local lnIndex, loViews, i, loView, lcAlias
		lnIndex = This.oGroupViews.GetKey(Lower(tcGroup))
		If Empty(lnIndex)
			Return .F.
		Endif

		loViews = This.oGroupViews.Item(lnIndex)
		If Empty(loViews.Count)
			Return .F.
		Endif

		For i=1 To loViews.Count
			lcAlias = loViews.Item(i)
			loView = This.oViews.Item(lcAlias)
			Select (loView.Alias)
			If loView.SendUpdates
				Tablerevert(.T.)
			Endif
			Use
			Release loView
		Endfor

		Return .T.
	Endproc

	Procedure migrate(tcTableOrPath)
		Local lbCloseTable, laTables[1], i, j, k, lcTableName, lcTablePath, lcPathAct, ;
			lcFieldsScript, lcValuesScript, lcOpenChar, lcCloseChar, lcDateAct, laDateFields[1], ;
			lcMarkAct, lcCenturyAct, loEnv, lcScript, lbMigrateDBC, loTMGObject, lcTableDescription

		lcPathAct = Set("Default")
		lcTableDescription = ""
		If Directory(tcTableOrPath)
			Set Default To (Addbs(tcTableOrPath))
			=Adir(laDBFList, "*.dbf")
			j = 0
			For i = 1 to Alen(laDBFList, 1)
				j = j + 1
				Dimension laTables[j]
				laTables[j] = laDBFList[i, 1]
			EndFor
			Store 0 to i, j
			Release laDBFList
		Else
			If !InList(Upper(JustExt(tcTableOrPath)), "DBC", "DBF", "TMG")
				MessageBox("Solo se permiten migraciones de ficheros DBF, DBC o TMG", 16)
				Return .f.
			EndIf

			Do case
			case Upper(JustExt(tcTableOrPath)) == "DBC"
				Open Database (tcTableOrPath) Shared
				=ADBObjects(laTables, "TABLE")
				lbMigrateDBC = .T.
			Case Upper(JustExt(tcTableOrPath)) == "TMG"
				Local lcScript
				lcScript = Strconv(FileToStr(tcTableOrPath), 11)
				If Right(lcScript, 1) != Chr(10)
					lcScript = lcScript + Chr(13) + Chr(10)
				EndIf
				defineConstants()
				Local loScanner, laTokens, llPrintTokens
				loScanner 	  = Createobject("Scanner", lcScript)
				laTokens 	  = loScanner.scanTokens()
				llPrintTokens = .f.	
				If llPrintTokens
					lcFile = "F:\Desarrollo\Mini_ERP\rutinas\tokens.txt"
					If File(lcFile)
						try
							Delete File &lcFile
						Catch
						EndTry
					EndIf
					For Each loToken In laTokens
						lcText = loToken.toString()
						lcText = lcText + CRLF
						=StrToFile(lcText, lcFile, 1)
					EndFor
					Modify File (lcFile)
					return
				EndIf

				Local loParser, loStatements, loEvaluator, z
				loParser 	 = CreateObject("Parser", @laTokens)
				loStatements = loParser.parse()
				loEvaluator  = CreateObject("Interpreter")
				loTMGObject  = loEvaluator.interpret(loStatements)
				Dimension laTables[loTMGObject.count]
				For z=1 to loTMGObject.count
					laTables[z]  = loTMGObject(z).cTableName
				EndFor
			Case Upper(JustExt(tcTableOrPath)) == "DBF"
				laTables[1]  = tcTableOrPath
			EndCase
		Endif

		lcOpenChar = This.getOpenNameSymbol()
		lcCloseChar = This.getCloseNameSymbol()
		
		loEnv = this.setEnvironment()
		For i = 1 To Alen(laTables,1)
			lcTablePath = laTables[i]
			Try
				If Type('loTMGObject') != 'O'
					lcTableName = Juststem(lcTablePath)
					If !Used(lcTableName)
						lbCloseTable = .T.
						Use (lcTablePath) In 0
					EndIf
					=Afields(laFields, lcTableName)
				Else
					Local laFields[1]
					lcTableName 		= loTMGObject(i).cTableName
					lcTableDescription 	= loTMGObject(i).cTableDescription
					Acopy(loTMGObject(i).aTableFields, laFields)
				EndIf				

				laDateFields = this.getDateTimeFields(@laFields)

				If This.tableExists(lcTableName)
					If !this.sqlExec(this.dropTable(lcTableName))
						Return
					EndIf
				Endif
				This.createTable(lcTableName, lcTableDescription, @laFields)
				
				If Type('loTMGObject') != 'O' && <<TMG SCRIPTS does not insert values>>
					* Iterate fields
					lcFieldsScript = Space(1)
					lcValuesScript = Space(1)

					For j=1 To Alen(laFields, 1)
						lcFieldsScript = lcFieldsScript + lcOpenChar + laFields[j, 1] + lcCloseChar + ','
						lcValuesScript = lcValuesScript + '?loRow.' + laFields[j, 1] + ','
					EndFor
					
					lcFieldsScript = Substr(lcFieldsScript, 1, Len(lcFieldsScript)-1)
					lcValuesScript = Substr(lcValuesScript, 1, Len(lcValuesScript)-1)

					* Insert values
					Select (lcTableName)
					Scan
						Scatter Memo Name loRow
						this.updateFetchedRow(@laDateFields, loRow)
						lcScript = "INSERT INTO " + lcOpenChar + lcTableName + lcCloseChar + " (" + lcFieldsScript + ")"
						lcScript = lcScript + " VALUES (" + lcValuesScript + ");"
						This.SQLExec(lcScript)
					EndScan
				EndIf
			Catch To loEx
				This.printException(loEx)
			Endtry

			If lbCloseTable
				Use In (lcTableName)
			Endif
		Endfor
		this.restoreEnvironment(loEnv)
		
		If lbMigrateDBC
			Close Databases ALL
		EndIf
	Endproc

	Function SQLExec(tcSQLCommand, tcCursorName)

		If Empty(tcCursorName)
			tcCursorName = Sys(2015)
		Endif

		If SQLExec(This.nHandle, tcSQLCommand, tcCursorName) <= 0
			=Aerror(laSqlError)
			Messagebox("SQL ERROR: " + laSqlError[2] + Transform(laSqlError[3]) + CRLF + "QUERY: " + tcSQLCommand, 16, "Error de comunicación")
			Return .f.
		Endif

		Return .t.
	Endfunc

	Procedure createTable(tcTableName, tcTableDescription, taFields)
		Local i, lcScript, lcType, lcName, lcSize, lcDecimal, lbAllowNull, lcLongName, ;
			lcComment, lnNextValue, lnStepValue, lcDefault, lcOpenChar, lcCloseChar, loFields, lcFkScript, ;
			lcFieldsScript, lcInternalID, lbInsertInternalID
		
		lcOpenChar  		= This.getOpenNameSymbol()
		lcCloseChar 		= This.getCloseNameSymbol()
		lcFkScript  		= ''
		lcFieldsScript 		= ''
		lcInternalID  		= lcOpenChar + this.cPKName + lcCloseChar + Space(1) + This.getGUIDDescription()
		lbInsertInternalID 	= .T.
		
		lcDefault = Space(1)
		loFields  = Createobject("Empty")
		=AddProperty(loFields, "name", "")
		=AddProperty(loFields, "type", "")
		=AddProperty(loFields, "size", "")
		=AddProperty(loFields, "decimal", "")
		=AddProperty(loFields, "allowNull", .F.)
		=AddProperty(loFields, "longName", "")
		=AddProperty(loFields, "comment", "")
		=AddProperty(loFields, "nextValue", 0)
		=AddProperty(loFields, "stepValue", 0)
		=AddProperty(loFields, "default", "")
		=AddProperty(loFields, "autoIncrement", .F.)
		=AddProperty(loFields, "primaryKey", .F.)
		=AddProperty(loFields, "addDefault", .T.)
		=AddProperty(loFields, "foreignKey", .null.)

		For i = 1 To Alen(taFields, 1)
			loFields.Name 		= taFields[i, 1]
			loFields.Type 		= taFields[i, 2]
			loFields.Size 		= Alltrim(Str(taFields[i, 3]))
			loFields.Decimal 	= Alltrim(Str(taFields[i, 4]))
			loFields.allowNull 	= taFields[i, 5]
			loFields.longName 	= taFields[i, 12]
			loFields.Comment 	= taFields[i, 16]
			loFields.Nextvalue 	= taFields[i, 17]
			loFields.stepValue 	= taFields[i, 18]
			loFields.addDefault = .T.
			
			loFields.Default 		= "''"
			loFields.primaryKey 	= .f.
			loFields.foreignKey 	= .null.
			loFields.autoIncrement 	= .f.
			
			* Validate types with mandatory length
			If InList(Upper(loFields.Type), 'C') and Empty(Val(loFields.Size))
				MessageBox("El tipo de dato CHAR requiere su longitud.", 48)
				loop
			EndIf
			
			If Type('taFields[i, 19]') != 'U'
				If taFields[i, 19] != "''"
					loFields.Default = "'" + taFields[i, 19] + "'"
				EndIf

				loFields.primaryKey 	= taFields[i, 20]
				loFields.foreignKey 	= taFields[i, 21]
				loFields.autoIncrement 	= taFields[i, 22]
			EndIf
			If i > 1
				lcFieldsScript = lcFieldsScript + ', '
			EndIf

			lcFieldsScript = lcFieldsScript + lcOpenChar + loFields.Name + lcCloseChar + Space(1)
			lcMacro = "this.visit" + loFields.Type + "Type(loFields)"
			lcValue = &lcMacro
			lcFieldsScript = lcFieldsScript + lcValue

			If loFields.autoIncrement
				lbInsertInternalID = .F.
				lcFieldsScript = lcFieldsScript + ' ' + this.addAutoIncrement()
			EndIf
			
			If !loFields.allowNull
				If loFields.addDefault
					lcFieldsScript = lcFieldsScript + " DEFAULT " + loFields.Default
				EndIf
				lcFieldsScript = lcFieldsScript + " NOT NULL "				
			EndIf
			
			If loFields.primaryKey
				lcFieldsScript = lcFieldsScript + ' ' + this.addPrimaryKey()
			EndIf									

			If !Empty(loFields.comment)
				lcFieldsScript = lcFieldsScript + this.addFieldComment(loFields.comment)
			EndIf
			
			If !IsNull(loFields.foreignKey)
				If !Empty(lcFkScript)
					lcFkScript = lcFkScript + ','
				EndIf
				lcFkScript = lcFkScript + ' ' + this.addForeignKey(loFields.foreignKey)
			EndIf
		EndFor

		lcScript = "CREATE TABLE " + lcOpenChar + tcTableName + lcCloseChar + '('
		If lbInsertInternalID
			lcScript = lcScript + lcInternalID + ','
		EndIf
		lcScript = lcScript + lcFieldsScript

		If !Empty(lcFkScript)
			lcScript = lcScript + ',' + lcFkScript
		EndIf

		lcScript = lcScript + ') ' + This.createTableOptions()
		
		If !Empty(tcTableDescription)
			lcScript = lcScript + this.addTableComment(tcTableDescription)
		EndIf

		* POLICIA
		_cliptext = lcScript
		MessageBox(lcScript)
		* POLICIA
		
		Return This.SQLExec(lcScript)
	Endproc

	Procedure sqlError
		Local Array laError[2]
		Aerror(laError)
		Messagebox("ERROR: " + Alltrim(Str(laError[1])) + CRLF + "MESSAGE:" + Transform(laError[2]) + Transform(laError[3]), 16, "ERROR")
	Endproc

	Hidden function updateRowScript(tcOpenChar, tcCloseChar, tcSQLTable, tcKeyField, tcFldState)
		Local laFields[1], i, laUpdFields[1], laDateFields[1], lcScript
		=AFields(laFields)
		
		laUpdFields  = this.getAffectedFields(tcFldState, @laFields)
		laDateFields = this.getDateTimeFields(@laFields)						
		
		lcScript = "UPDATE " + tcOpenChar + tcSQLTable + tcCloseChar + " SET "

		* Iterate fields
		For i=1 to Alen(laUpdFields)
			lcScript = lcScript + tcOpenChar + laUpdFields[i] + tcCloseChar + "=?loRow." + laUpdFields[i] + ','
		EndFor
		lcScript = Substr(lcScript, 1, Len(lcScript)-1)
		
		lcScript = lcScript + " WHERE " + tcOpenChar + tcKeyField + tcCloseChar + "=?lvKeyValue"	
		Return lcScript
	EndFunc
	
	Hidden Function rowExists(tcOpenChar, tcCloseChar, tcSQLTable, tcKeyField, tvkeyValue)
		If Empty(tvkeyValue)
			Return .f.
		EndIf
		Local lcCommand, lcCursor, lnTotal, lcAlias
		lcAlias = Alias()
		lcCursor = Sys(2015)
		private lvValue
		lvValue = tvkeyValue
		lcCommand = "SELECT Count(*) as total FROM " + tcOpenChar + tcSQLTable + tcCloseChar + " WHERE " + tcOpenChar + tcKeyField + tcCloseChar + "=?lvValue"
		If !this.SQLExec(lcCommand, lcCursor)
			Release lvValue
			Return .f.
		EndIf
		Release lvValue
		
		lnTotal = &lcCursor..total
		Use in (lcCursor)
		
		If !Empty(lcAlias) and Used(lcAlias)
			Select (lcAlias)
		EndIf
		
		Return lnTotal > 0
	EndFunc

	Hidden Procedure getTableAndAlias(tcTable, tcSqlTableName, tcAlias)
		Local loResult
		This.oRegEx.Pattern = "^(\w+)\s+[asAS]+\s+(\w+)"
		loResult = This.oRegEx.Execute(tcTable)
		If Type('loResult') == 'O' And loResult.Count > 0
			tcSqlTableName = loResult.Item(0).SubMatches(0)
			tcAlias = loResult.Item(0).SubMatches(1)
		Else
			tcSqlTableName = tcTable
			tcAlias = tcTable
		Endif
	EndProc
	
	Hidden function getKeyField(tcTable)
		If !this.fieldExists(tcTable, this.cPKName)
			Return this.getPrimaryKey(tcTable)
		EndIf
		Return this.cPKName
	EndFunc 

	Hidden function getSelectCommand(tcTable, tcFields, tcCriteria)
		Local lcOpenChar, lcCloseChar, lcCommand
		lcOpenChar = this.getOpenNameSymbol()
		lcCloseChar = this.getCloseNameSymbol()

		If Empty(tcFields)
			tcFields = "*"
		EndIf

		lcCommand = "SELECT " + tcFields + " FROM " + lcOpenChar + tcTable + lcCloseChar
		If !Empty(tcCriteria)
			lcCommand = lcCommand + " WHERE " + tcCriteria
		EndIf
		Return lcCommand
	endfunc

	Hidden Procedure addViewToGroup(tcGroup, tcAlias)

		Local lnIndex, loViews As Collection
		lnIndex = This.oGroupViews.GetKey(Lower(tcGroup))
		If Empty(lnIndex)
			loViews = Createobject('Collection')
		Else
			loViews = This.oGroupViews.Item(lnIndex)
			This.oGroupViews.Remove(lnIndex)
		Endif
		Try
			loViews.Add(tcAlias)
			This.oGroupViews.Add(loViews, tcGroup)
		Catch
			* View already saved.
		Endtry
	Endproc

	Hidden Function getDateTimeFields(taFields)
		Local i
		This.resetArray()
		For i = 1 To alen(taFields, 1)
			If Inlist(taFields[i, 2], 'D', 'T')
				this.pushArray(taFields[i, 1])
			Endif
		Endfor
		Return @this.aCustomArray
	EndFunc
	
	Hidden function getAffectedFields(tcFldState, taFields)
		Local i, j
		This.resetArray()
		For i = 2 to Len(tcFldState)
			If InList(Val(Substr(tcFldState, i, 1)), 2, 4)
				this.pushArray(taFields[i-1, 1])
			EndIf
		EndFor
		Return @this.aCustomArray
	EndFunc	
	
	Hidden procedure updateFetchedRow(taDateFields, toRow)
		If Type('taDateFields[1]') == 'C'
			Local i, lcMacro
			For i=1 To Alen(taDateFields, 1)
				lcMacro = "toRow." + taDateFields[i] + " = this.formatDateOrDateTime(toRow." + taDateFields[i] + ")"
				&lcMacro
			Endfor
		EndIf
	EndProc

	Hidden Procedure applyConnectionSettings
		Set Multilocks On
		SQLSetprop(This.nHandle, 'DisconnectRollback', .T.)
		SQLSetprop(This.nHandle, 'DispWarnings', .F.)
		SQLSetprop(This.nHandle, 'Asynchronous', .F.)
		SQLSetprop(This.nHandle, 'BatchMode', .T.)
		SQLSetprop(This.nHandle, 'IdleTimeout', 0)
		SQLSetprop(This.nHandle, 'QueryTimeOut', 0)
		SQLSetprop(This.nHandle, 'WaitTime', 100)
		This.sendConfigurationQuerys()
	Endproc

	Hidden Function reconnect
		Local lcQuery, lcCursor
		lcQuery	= This.getDummyQuery()
		lcCursor = Sys(2015)

		If SQLExec(This.nHandle, lcQuery, lcCursor) <= 0
			This.nHandle = 0
		Endif
	EndFunc

	Hidden Procedure printException(toError)
		Local lcMsg
		lcMsg = Padr("Error:", 20, Space(1)) + Alltrim(Str(toError.ErrorNo))
		lcMsg = lcMsg + CRLF + Padr("LineNo:", 20, Space(1)) + Alltrim(Str(toError.Lineno))
		lcMsg = lcMsg + CRLF + Padr("Message:", 20, Space(1)) + Alltrim(toError.Message)
		lcMsg = lcMsg + CRLF + Padr("Procedure:", 20, Space(1)) + Alltrim(toError.Procedure)
		lcMsg = lcMsg + CRLF + Padr("Details:", 20, Space(1)) + Alltrim(toError.Details)
		lcMsg = lcMsg + CRLF + Padr("StackLevel:", 20, Space(1)) + Alltrim(Str(toError.StackLevel))
		lcMsg = lcMsg + CRLF + Padr("LineContents:", 20, Space(1)) + Alltrim(toError.LineContents)
		lcMsg = lcMsg + CRLF + Padr("UserValue:", 20, Space(1)) + Alltrim(toError.UserValue)

		Messagebox(lcMsg, 16)
	Endproc

	Hidden Procedure disconnect
		Try
			If This.nHandle > 0
				SQLDisconnect(This.nHandle)
				This.nHandle = 0
			Endif
		Catch
		Endtry
	EndProc

	Procedure resetArray
		Dimension This.aCustomArray[1]
		This.aCustomArray[1] = .F.
		This.nCounter = 0
	Endproc

	Procedure pushArray(tvValue)
		This.nCounter = This.nCounter + 1
		Dimension This.aCustomArray[this.nCounter]
		This.aCustomArray[this.nCounter] = tvValue
	Endproc

	Procedure Destroy
		This.disconnect()
	Endproc

	* ================================================================================ *
	* Abstracts methods
	* ================================================================================ *
	Function getDummyQuery
		* Abstract
	Endfunc

	Function getVersion
		* Abstract
	Endfunc

	Procedure getConnectionString
		* Abstract
	Endproc

	Procedure beginTransaction
		* Abstract
	Endproc

	Procedure endTransaction
		* Abstract
	Endproc

	Procedure cancelTransaction
		* Abstract
	Endproc

	Function getOpenNameSymbol
		* Abstract
	Endfunc

	Function getCloseNameSymbol
		* Abstract
	Endfunc

	Function tableExists(tcTableName)
		Local lcQuery, lcSchema, lcCursor
		lcCursor = Sys(2015)
		This.selectDatabase()

		lcQuery = this.getTableExistsScript(tcTableName)

		If !This.SQLExec(lcQuery, lcCursor)
			Return .F.
		Endif

		lcSchema = Alltrim(Strtran(&lcCursor..TableName, Chr(0)))

		Use In (lcCursor)

		Return !Empty(lcSchema)
	Endfunc

	Procedure selectDatabase
		* Abstract
	Endproc

	Function getGUIDDescription
		* Abstract
	Endfunc

	Function fieldExists(tcTable, tcField)
		Local lcQuery, lcCursor, lbResult
		This.selectDatabase()
		lcCursor = Sys(2015)

		lcQuery = this.getFieldExistsScript(tcTable, tcField)
		This.SQLExec(lcQuery, lcCursor)

		lbResult = !Empty(&lcCursor..fieldName)
		Use In (lcCursor)

		Return lbResult
	Endfunc

	Function getServerDate
		Local lcCursor, ldDate
		lcCursor = Sys(2015)
		This.SQLExec(this.getServerDateScript(), lcCursor)

		ldDate = &lcCursor..sertime

		Use In (lcCursor)

		Return ldDate
	Endfunc

	Function getNewGuid
		Local lcCursor, lcGuid
		lcCursor = Sys(2015)
		This.SQLExec(this.getNewGuidScript(), lcCursor)

		lcGuid = &lcCursor..guid
		Use In (lcCursor)

		Return lcGuid
	Endfunc

	Function getTables
		This.resetArray()

		Local lcQuery, lcCursor
		This.selectDatabase()
		lcCursor = Sys(2015)

		Dimension laTables[1]

		lcQuery = this.getTablesScript()
		This.SQLExec(lcQuery, lcCursor)

		Select table_name From (lcCursor) Into Array laTables

		=Acopy(laTables, This.aCustomArray)

		Use In (lcCursor)

		Return @This.aCustomArray
	Endfunc

	Function getTableFields(tcTable)
		This.resetArray()

		Local lcQuery, lcCursor
		This.selectDatabase()
		lcCursor = Sys(2015)

		Dimension laFields[1]

		lcQuery = this.getTableFieldsScript(tcTable)
		This.SQLExec(lcQuery, lcCursor)

		Select column_name From (lcCursor) Into Array laFields

		=Acopy(laFields, This.aCustomArray)

		Use In (lcCursor)

		Return @This.aCustomArray
	Endfunc

	Procedure getPrimaryKey(tcTable)
		Local lcScript, lcCursor, lcField
		lcCursor = Sys(2015)
		lcScript = this.getPrimaryKeyScript(tcTable)

		This.SQLExec(lcScript, lcCursor)
		lcField = Alltrim(&lcCursor..column_name)
		Use In (lcCursor)

		Return lcField
	Endproc

	Function createTableOptions
		* Abstract
	Endfunc

	Procedure sendConfigurationQuerys
		* Abstract
	Endproc

	function setEnvironment
		* Abstract
	EndFunc
	
	Procedure restoreEnvironment(toEnv)
		* Abstract
	endproc

	Function formatDateOrDateTime(tdValue)
		* Abstract
	Endfunc

	Function getLastID
		Local lcScript, lcCursor, lnID
		lcCursor = Sys(2015)
		lcScript = this.getLastIDScript()
		This.SQLExec(lcScript, lcCursor)
		lnID = &lcCursor..last_id
		Use In (lcCursor)

		If IsNull(lnID)
			Return 0
		EndIf
		Return lnID

	EndFunc

	Function getCreateDatabaseScript(tcDatabase)
		* Abstract
	EndFunc

	Function getDataBaseExistsScript(tcDatabase)
		* Abstract
	EndFunc
	
	Function addFieldComment(tcComment)
		* Abstract
	EndFunc
	
	Function addTableComment(tcComment)
		* Abstract
	EndFunc
	
	Function addForeignKey(toFkData)
		* Abstract
	EndFunc
	
	Function getForeignKeyValue(tcValue)
		* Abstract
	EndFunc
	
	Function addAutoIncrement
		* Abstract
	EndFunc
	
	Function addPrimaryKey
		* Abstract
	EndFunc
	
	function dropTable(tcTable)
		* Abstract
	endfunc

	Function visitCType(toFields)
		* Abstract
	Endfunc

	Function visitYType(toFields)
		* Abstract
	Endfunc

	Function visitDType(toFields)
		* Abstract
	Endfunc

	Function visitTType(toFields)
		* Abstract
	Endfunc

	Function visitBType(toFields)
		* Abstract
	Endfunc

	Function visitFType(toFields)
		* Abstract
	Endfunc

	Function visitGType(toFields)
		* Abstract
	Endfunc

	Function visitIType(toFields)
		* Abstract
	Endfunc

	Function visitLType(toFields)
		* Abstract
	Endfunc

	Function visitMType(toFields)
		* Abstract
	Endfunc

	Function visitNType(toFields)
		* Abstract
	Endfunc

	Function visitQType(toFields)
		* Abstract
	Endfunc

	Function visitVType(toFields)
		* Abstract
	Endfunc

	Function visitWType(toFields)
		* Abstract
	Endfunc
Enddefine

* ==================================================== *
* MICROSOFT SQL SERVER
* ==================================================== *
Define Class MSSQL As DBEngine

	Function getDummyQuery
		Return "SELECT @@VERSION"
	Endfunc

	Function getVersion
		Local lcCursor, lcVersion
		lcCursor = Sys(2015)
		This.SQLExec("SELECT @@VERSION AS 'VER'", lcCursor)
		lcVersion = &lcCursor..VER
		Use In (lcCursor)

		Return lcVersion
	Endfunc

	Function getConnectionString
		Local lcConStr, lcDriver

		lcConStr = "DRIVER=" + This.cDriver + ";SERVER=" + This.cServer + ";UID=" + This.cUser + ";PWD=" + This.cPassword
		If This.nPort > 0
			lcConStr = lcConStr + ";PORT=" + Alltrim(Str(This.nPort))
		Endif

		Return lcConStr
	Endfunc

	Procedure beginTransaction
		This.selectDatabase()
		This.SQLExec("BEGIN TRANSACTION")
	Endproc

	Procedure endTransaction
		This.selectDatabase()
		This.SQLExec("IF @@TRANCOUNT > 0 COMMIT")
	Endproc

	Procedure cancelTransaction
		This.selectDatabase()
		This.SQLExec("IF @@TRANCOUNT > 0 ROLLBACK")
	Endproc

	Function getOpenNameSymbol
		If this.bUseDelimiter
			Return "["
		EndIf
		Return ""
	Endfunc

	Function getCloseNameSymbol
		If this.bUseDelimiter
			Return "]"
		EndIf
		Return ""
	Endfunc

	Function getTableExistsScript(tcTableName)
		Local lcQuery

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT TABLE_SCHEMA AS TableName FROM INFORMATION_SCHEMA.TABLES
			 WHERE TABLE_CATALOG = '<<Alltrim(This.cDatabase)>>'
			 AND  TABLE_NAME = '<<tcTableName>>'
		ENDTEXT

		Return lcQuery
	Endfunc

	Procedure selectDatabase
		If Empty(this.cDatabase)
			MessageBox("Debe especificar una base de datos antes de realizar esta petición.", 16)
			Return
		EndIf
		This.SQLExec("use " + This.cDatabase)
	Endproc

	Function getGUIDDescription
		* Return "UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID()"
		Return "INT IDENTITY(1,1) PRIMARY KEY"
	Endfunc

	Function getFieldExistsScript(tcTable, tcField)
		Local lcQuery

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT COLUMN_NAME AS FieldName
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = '<<tcTable>>' AND COLUMN_NAME = '<<tcField>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Function getServerDateScript
		Return "SELECT GETDATE() AS SERTIME;"
	Endfunc

	Function getNewGuidScript
		Return "SELECT NEWID() AS GUID;"
	Endfunc

	Function getTablesScript
		Local lcQuery

		TEXT TO lcQuery NOSHOW PRETEXT 7 TEXTMERGE
			SELECT TABLE_NAME
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '<<this.cDatabase>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Function getTableFieldsScript(tcTable)
		Local lcQuery

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = '<<tcTable>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Procedure getPrimaryKeyScript(tcTable)
		Local lcScript
		TEXT to lcScript noshow pretext 7 textmerge
			SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			WHERE CONSTRAINT_NAME = (
			    SELECT name
			    FROM sys.key_constraints
			    WHERE type = 'PK'
			        AND OBJECT_NAME(parent_object_id) = '<<tcTable>>'
			);
		ENDTEXT

		Return lcScript
	Endproc

	Function createTableOptions
		Return " "
	Endfunc

	Procedure sendConfigurationQuerys
		* Abstract
	Endproc

	function setEnvironment
		Local loEnv
		loEnv = CreateObject("Collection")		
		loEnv.Add(Set("Date"), 'date')
		loEnv.Add(Set("Century"), 'century')
		
		Set Date To Dmy
		Set Century On
		This.SQLExec("SET DATEFORMAT dmy")
		
		Return loEnv
	EndFunc

	procedure restoreEnvironment(toEnv)
		Local lcDate, lcCentury
		lcDate = toEnv.Item(1)
		lcCentury = toEnv.Item(2)

		Set Date (lcDate)
		Set Century &lcCentury
	endproc

	Function formatDateOrDateTime(tdValue)
		If Empty(tdValue)
			If Type('tdValue') == 'D'
				Return Date(1753, 01, 01)
			Endif
			Return Datetime(1753,01,01,00,00,00)
		Endif
		Return tdValue
	Endfunc	

	Function getLastIDScript
		Return "SELECT SCOPE_IDENTITY() AS LAST_ID"
	EndFunc

	Function getCreateDatabaseScript(tcDatabase)
		Local lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		EndIf
			
		Return "CREATE DATABASE " + lcLeft + tcDatabase + lcRight + ";"
	EndFunc
	
	Function getDataBaseExistsScript(tcDatabase)
		Return "select NAME AS dbName from sys.databases where name = '" + tcDatabase + "'"
	EndFunc

	Function addFieldComment(tcComment)
		Return " "
	EndFunc

	Function addTableComment(tcComment)
		Return " "
	EndFunc

	Function addForeignKey(toFkData)
		Local lcScript, lcOnUpdate, lcOnDelete, lcLeft, lcRight
		lcOnUpdate = this.getForeignKeyValue(toFkData.cOnUpdate)
		lcOnDelete = this.getForeignKeyValue(toFkData.cOnDelete)
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		EndIf
				
		Text to lcScript noshow pretext 7 textmerge
		FOREIGN KEY (<<lcLeft>><<toFkData.cCurrentField>><<lcRight>>) REFERENCES <<lcLeft>><<toFkData.cTable>><<lcRight>>(<<lcLeft>><<toFkData.cField>><<lcRight>>)
		ON UPDATE <<lcOnUpdate>>
		ON DELETE <<lcOnDelete>>
		endtext
		Return lcScript
	EndFunc

	Function getForeignKeyValue(tcValue)
		Do case
		Case upper(tcValue) == 'NULL'
			Return 'SET NULL'
		Case upper(tcValue) == 'DEFAULT'
			Return 'SET DEFAULT'
		Case upper(tcValue) == 'RESTRICT'
			Return 'NO ACTION'
		EndCase
		Return tcValue
	EndFunc
	
	Function addAutoIncrement
		Return "IDENTITY(1,1)"
	EndFunc
	
	Function addPrimaryKey
		Return "PRIMARY KEY"
	EndFunc	
	
	function dropTable(tcTable)	
		Local lcOpenChar, lcCloseChar
		Store "" to lcOpenChar, lcCloseChar
		
		If this.bUseDelimiter
			lcOpenChar  = This.getOpenNameSymbol()
			lcCloseChar = This.getCloseNameSymbol()
		EndIf
		
		Return "DROP TABLE " + lcOpenChar + tcTable + lcCloseChar + " IF EXISTS;"
	endfunc

	* C = Character
	Function visitCType(toFields)
		Return "CHAR(" + toFields.Size + ") COLLATE Latin1_General_CI_AI"
	Endfunc

	* Y = Currency
	Function visitYType(toFields)
		toFields.Default = "0"
		Return "MONEY"
	Endfunc

	* D = Date
	Function visitDType(toFields)
		toFields.Default = "'1753-01-01'"
		Return "DATE"
	Endfunc

	* T = DateTime
	Function visitTType(toFields)
		toFields.Default = "'1753-01-01 00:00:00.000'"
		Return "DATETIME"
	Endfunc

	* B = Double
	Function visitBType(toFields)
		toFields.Default = "0.0"
		Return "FLOAT"
	Endfunc

	* F = Float
	Function visitFType(toFields)
		toFields.Default = "0.0"
		Return "FLOAT"
	Endfunc

	* G = General
	Function visitGType(toFields)
		toFields.Default = "0x"
		Return "IMAGE"
	Endfunc

	* I = Integer
	Function visitIType(toFields)
		toFields.Default = "0"
		Return "INT"
	Endfunc

	* L = Logical
	Function visitLType(toFields)
		Return "BIT"
	Endfunc

	* M = Memo
	Function visitMType(toFields)
		Return "TEXT"
	Endfunc

	* N = Numeric
	Function visitNType(toFields)
		If Val(toFields.Decimal) > 0
			toFields.Default = "0.0"
		Else
			toFields.Default = '0'
		Endif
		Return "NUMERIC(" + toFields.Size + "," + toFields.Decimal + ")"
	Endfunc

	* Q = VarBinary
	Function visitQType(toFields)
		toFields.Default = "0x"
		Return "VARBINARY(max)"
	Endfunc

	* V = Varchar
	Function visitVType(toFields)
		Return "VARCHAR(" + Iif(Empty(Val(toFields.Size)), 'max', toFields.Size) + ") COLLATE Latin1_General_CI_AI"
	Endfunc

	* W = Blob
	Function visitWType(toFields)
		toFields.Default = "0x"
		Return "IMAGE"
	Endfunc
Enddefine

* ==================================================== *
* MySQL
* ==================================================== *
Define Class MySQL As DBEngine

	Function getDummyQuery
		Return "SELECT Version()"
	Endfunc

	Function getVersion
		Local lcCursor, lcVersion
		lcCursor = Sys(2015)
		This.SQLExec("SELECT Version() AS 'VER'", lcCursor)
		lcVersion = &lcCursor..VER
		Use In (lcCursor)

		Return lcVersion
	Endfunc

	Function getConnectionString
		Local lcConStr, lcDriver

		lcConStr = "DRIVER={" + This.cDriver + "};SERVER=" + This.cServer + ";USER=" + This.cUser + ";PASSWORD=" + This.cPassword
		If This.nPort > 0
			lcConStr = lcConStr + ";PORT=" + Alltrim(Str(This.nPort))
		Endif

		Return lcConStr
	Endfunc

	Procedure beginTransaction
		This.selectDatabase()
		This.SQLExec("START TRANSACTION;")
	Endproc

	Procedure endTransaction
		This.selectDatabase()
		This.SQLExec("COMMIT;")
	Endproc

	Procedure cancelTransaction
		This.selectDatabase()
		This.SQLExec("ROLLBACK;")
	Endproc

	Function getOpenNameSymbol
		If this.bUseDelimiter
			Return '`'
		EndIf
		Return ""
	Endfunc

	Function getCloseNameSymbol
		If this.bUseDelimiter
			Return '`'
		EndIf
		Return ""
	Endfunc

	Function getTableExistsScript(tcTableName)
		Local lcQuery

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT TABLE_NAME AS TableName FROM INFORMATION_SCHEMA.TABLES
			 WHERE TABLE_SCHEMA = '<<Alltrim(This.cDatabase)>>'
			 AND  TABLE_NAME = '<<tcTableName>>'
		ENDTEXT

		Return lcQuery
	Endfunc

	Procedure selectDatabase
		This.SQLExec("use " + This.cDatabase)
	Endproc

	Function getGUIDDescription
		Return "int unsigned primary key NOT NULL auto_increment"
	Endfunc

	Function getFieldExistsScript(tcTable, tcField)
		Local lcQuery

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT COLUMN_NAME AS FieldName
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = '<<tcTable>>' AND TABLE_SCHEMA = '<<Alltrim(This.cDatabase)>>' AND COLUMN_NAME = '<<tcField>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Function getServerDateScript
		Return "SELECT NOW() AS SERTIME;"
	Endfunc

	Function getNewGuidScript
		Return "SELECT UUID() AS GUID;"
	Endfunc

	Function getTablesScript
		Local lcQuery

		TEXT TO lcQuery noshow pretext 7 textmerge
			SELECT TABLE_NAME
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_SCHEMA = '<<this.cDatabase>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Function getTableFieldsScript(tcTable)

		Local lcQuery

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = '<<tcTable>>' AND TABLE_SCHEMA = '<<this.cDatabase>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Procedure getPrimaryKeyScript(tcTable)
		Local lcScript
		TEXT to lcScript noshow pretext 7 textmerge
			SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			WHERE TABLE_SCHEMA = '<<this.cDatabase>>'
			  AND TABLE_NAME = '<<tcTable>>'
			  AND CONSTRAINT_NAME = 'PRIMARY';
		ENDTEXT

		Return lcScript
	Endproc

	Function createTableOptions
		Return "ENGINE = InnoDB AUTO_INCREMENT = 0 DEFAULT CHARSET = latin1"
	Endfunc

	function setEnvironment
		Local loEnv
		loEnv = CreateObject("Collection")		
		loEnv.Add(Set("Date"), 'date')
		loEnv.Add(Set("Century"), 'century')
		loEnv.Add(Set("Mark"), 'mark')				

		Set Date To YMD
		Set Century On
		Set Mark To '-'

		Return loEnv
	EndFunc

	procedure restoreEnvironment(toEnv)
		Local lcDate, lcCentury, lcMark
		lcDate = toEnv.Item(1)
		lcCentury = toEnv.Item(2)
		lcMark = toEnv.Item(3)

		Set Date (lcDate)
		Set Century &lcCentury
		Set Mark to (lcMark)
	endproc

	Function formatDateOrDateTime(tdValue)
		If Empty(tdValue)
			If Type('tdValue') == 'D'
				Return Date(1000, 01, 01)
			Endif
			Return Datetime(1000,01,01,00,00,00)
		Endif
		Return tdValue
	Endfunc

	Function getLastIDScript
		Return "SELECT LAST_INSERT_ID() AS LAST_ID"
	EndFunc

	Function getCreateDatabaseScript(tcDatabase)
		Local lcOpenChar, lcCloseChar
		Store "" to lcOpenChar, lcCloseChar
		
		If this.bUseDelimiter
			lcOpenChar  = This.getOpenNameSymbol()
			lcCloseChar = This.getCloseNameSymbol()
		EndIf
		
		Return "CREATE DATABASE " + lcOpenChar + tcDatabase + lcCloseChar + " DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
	EndFunc
	
	Function getDataBaseExistsScript(tcDatabase)
		Return "SELECT CATALOG_NAME AS dbName FROM information_schema.schemata WHERE schema_name = '" + tcDatabase + "'"
	EndFunc

	Function addFieldComment(tcComment)
		Return " COMMENT '" + tcComment + "'"
	EndFunc
	
	Function addTableComment(tcComment)
		Return " COMMENT '" + tcComment + "'"
	EndFunc	

	Function addForeignKey(toFkData)
		Local lcScript, lcOnUpdate, lcOnDelete, lcOPen, lcClose
		lcOnUpdate = this.getForeignKeyValue(toFkData.cOnUpdate)
		lcOnDelete = this.getForeignKeyValue(toFkData.cOnDelete)
		Store "" to lcOPen, lcClose
		
		If this.bUseDelimiter
			lcOPen  = This.getOpenNameSymbol()
			lcClose = This.getCloseNameSymbol()
		EndIf
				
		Text to lcScript noshow pretext 7 textmerge
		FOREIGN KEY (<<lcOPen>><<toFkData.cCurrentField>><<lcClose>>) REFERENCES <<lcOPen>><<toFkData.cTable>><<lcClose>>(<<lcOPen>><<toFkData.cField>><<lcClose>>)
		ON UPDATE <<lcOnUpdate>>
		ON DELETE <<lcOnDelete>>
		endtext		
		Return lcScript
	EndFunc

	Function getForeignKeyValue(tcValue)
		Do case
		Case upper(tcValue) == 'NULL'
			Return 'SET NULL'
		Case upper(tcValue) == 'DEFAULT'
			Return 'SET DEFAULT'
		EndCase
		Return tcValue
	EndFunc

	Function addAutoIncrement
		Return "AUTO_INCREMENT"
	EndFunc
	
	Function addPrimaryKey
		Return "PRIMARY KEY"
	EndFunc	

	function dropTable(tcTable)
		Local lcOPen, lcClose
		Store "" to lcOPen, lcClose
		
		If this.bUseDelimiter
			lcOPen  = This.getOpenNameSymbol()
			lcClose = This.getCloseNameSymbol()
		EndIf
		Return "DROP TABLE " + lcOPen + tcTable + lcClose + " IF EXISTS;"
	endfunc
	
	* C = Character
	Function visitCType(toFields)
		Return "CHAR(" + toFields.Size + ")"
	Endfunc

	* Y = Currency
	Function visitYType(toFields)
		toFields.Default = "0.0"
		Return "DECIMAL(" + toFields.Size + "," + toFields.Decimal + ")"
	Endfunc

	* D = Date
	Function visitDType(toFields)
		toFields.Default = "'1000-01-01'"
		Return "DATE"
	Endfunc

	* T = DateTime
	Function visitTType(toFields)
		toFields.Default = "'1000-01-01 00:00:00'"
		Return "DATETIME"
	Endfunc

	* B = Double
	Function visitBType(toFields)
		toFields.Default = "0.0"
		Return "DOUBLE(" + toFields.Size + "," + toFields.Decimal + ")"
	Endfunc

	* F = Float
	Function visitFType(toFields)
		toFields.Default = "0.0"
		Return "FLOAT(" + toFields.Size + "," + toFields.Decimal + ")"
	Endfunc

	* G = General
	Function visitGType(toFields)
		toFields.addDefault = .F.
		Return "BLOB"
	Endfunc

	* I = Integer
	Function visitIType(toFields)
		toFields.Default = "0"
		Return "INT"
	Endfunc

	* L = Logical
	Function visitLType(toFields)
		toFields.Default = "0"
		Return "BOOL"
	Endfunc

	* M = Memo
	Function visitMType(toFields)
		toFields.addDefault = .F.
		Return "TEXT"
	Endfunc

	* N = Numeric
	Function visitNType(toFields)
		If Val(toFields.Decimal) > 0
			toFields.Default = "0.0"
		Else
			toFields.Default = '0'
		Endif
		Return "DECIMAL(" + toFields.Size + "," + toFields.Decimal + ")"
	Endfunc

	* Q = VarBinary
	Function visitQType(toFields)
		toFields.Default = "0x"
		Local lcSize
		lcSize = "255"
		If Val(toFields.Size) > 0
			lcSize = toFields.Size
		Endif
		Return "VARBINARY(" + lcSize + ")"
	Endfunc

	* V = Varchar (usamos NVARCHAR(N) para admitir caracteres especiales)
	Function visitVType(toFields)
		* Return "VARCHAR(" + toFields.Size + ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
		Return "VARCHAR(" + toFields.Size + ")"
	Endfunc

	* W = Blob
	Function visitWType(toFields)
		toFields.addDefault = .F.
		Return "BLOB"
	Endfunc
EndDefine

* ==================================================== *
* FireBird
* ==================================================== *
Define Class Firebird As DBEngine

    Function getDummyQuery
        Return "SELECT 1 FROM RDB$DATABASE"
    Endfunc

    Function getVersion
        Local lcCursor, lcVersion
        lcCursor = Sys(2015)
        This.SQLExec("SELECT RDB$GET_CONTEXT('SYSTEM', 'ENGINE_VERSION') AS 'VER' FROM RDB$DATABASE", lcCursor)
        lcVersion = &lcCursor..VER
        Use In (lcCursor)

        Return lcVersion
    Endfunc

    Function getConnectionString
        Local lcConStr, lcPort
        lcConStr = "DRIVER=" + this.cDriver + ";DBNAME=" + This.cDatabase + ";UID=" + This.cUser + ";PWD=" + This.cPassword + ";"

        Return lcConStr
    Endfunc

    Procedure beginTransaction
        This.selectDatabase()
        This.SQLExec("SET TRANSACTION")
    Endproc

    Procedure endTransaction
        This.selectDatabase()
        This.SQLExec("COMMIT")
    Endproc

    Procedure cancelTransaction
        This.selectDatabase()
        This.SQLExec("ROLLBACK")
    Endproc

    Function getOpenNameSymbol
		If this.bUseDelimiter
			Return '"'
		EndIf
		Return ""
    Endfunc

    Function getCloseNameSymbol
		If this.bUseDelimiter
			Return '"'
		EndIf
		Return ""
    Endfunc

    Function getTableExistsScript(tcTableName)
        Local lcQuery, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		Else
			tcTableName = Upper(tcTableName)
		EndIf
		
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT RDB$RELATION_NAME AS TableName
            FROM RDB$RELATIONS
            WHERE RDB$RELATION_NAME = '<<lcLeft>><<tcTableName>><<lcRight>>'
        ENDTEXT

        Return lcQuery
    Endfunc

    Procedure selectDatabase
        * No aplica
    Endproc

    Function getGUIDDescription
        Return "CHAR(16) CHARACTER SET OCTETS"
    Endfunc

    Function getFieldExistsScript(tcTable, tcField)
        Local lcQuery, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		Else
			tcTable = Upper(tcTable)
			tcField = Upper(tcField)
		EndIf
		
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT RDB$FIELD_NAME AS FieldName
            FROM RDB$RELATION_FIELDS
            WHERE RDB$RELATION_NAME = '<<lcLeft>><<tcTable>><<lcRight>>' AND RDB$FIELD_NAME = '<<lcLeft>><<tcField>><<lcRight>>';
        ENDTEXT

        Return lcQuery
    Endfunc

    Function getServerDateScript
        Return "SELECT CURRENT_TIMESTAMP AS SERTIME FROM RDB$DATABASE"
    Endfunc

    Function getNewGuidScript
        Return "SELECT CAST(GEN_UUID() AS CHAR(16) CHARACTER SET OCTETS) AS GUID FROM RDB$DATABASE"
    Endfunc

    Function getTablesScript
        Local lcQuery

        TEXT TO lcQuery NOSHOW PRETEXT 7 TEXTMERGE
            SELECT RDB$RELATION_NAME AS TableName
            FROM RDB$RELATIONS
            WHERE RDB$VIEW_BLR IS NULL
        ENDTEXT

        Return lcQuery
    Endfunc

    Function getTableFieldsScript(tcTable)
        Local lcQuery, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		Else
			tcTable = Upper(tcTable)
		EndIf
		
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT RDB$FIELD_NAME AS FieldName
            FROM RDB$RELATION_FIELDS
            WHERE RDB$RELATION_NAME = '<<lcLeft>><<tcTable>><<lcRight>>'
        ENDTEXT

        Return lcQuery
    Endfunc

    Procedure getPrimaryKeyScript(tcTable)
		Local lcScript, lcOPen, lcClose
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		Else
			tcTable = Upper(tcTable)
		EndIf

        TEXT to lcScript noshow pretext 7 textmerge
            SELECT SEG.RDB$FIELD_NAME AS FieldName
            FROM RDB$RELATION_CONSTRAINTS CON
            JOIN RDB$INDEX_SEGMENTS SEG ON CON.RDB$INDEX_NAME = SEG.RDB$INDEX_NAME
            WHERE CON.RDB$RELATION_NAME = '<<lcLeft>><<tcTable>><<lcRight>>' AND CON.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
        ENDTEXT

        Return lcScript
    Endproc

    Function createTableOptions
        Return " "
    Endfunc

    Procedure sendConfigurationQuerys
        * Abstract
    Endproc

    Function setEnvironment
        Local loEnv
        loEnv = CreateObject("Collection")        
        loEnv.Add(Set("Date"), 'date')
        loEnv.Add(Set("Century"), 'century')

        Set Date To Dmy
        Set Century On

        Return loEnv
    Endfunc

    Procedure restoreEnvironment(toEnv)
        Local lcDate, lcCentury
        lcDate = toEnv.Item(1)
        lcCentury = toEnv.Item(2)

        Set Date (lcDate)
        Set Century &lcCentury
    Endproc

    Function formatDateOrDateTime(tdValue)
        If Empty(tdValue)
            If Type('tdValue') == 'D'
                Return Date(1753, 01, 01)
            Endif
            Return Datetime(1753,01,01,00,00,00)
        Endif

        Return tdValue
    Endfunc

    Function getOpenTableScript(tcTable)
    	Local lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		Else
			tcTable = Upper(tcTable)
		EndIf    
        Return "SELECT * FROM " + lcLeft + tcTable + lcRight
    Endfunc

    Function getCloseTableScript()
        Return ""
    Endfunc

    Function getCloseCursorScript()
        Return ""
    Endfunc

    Function addAutoIncrement()
        Return "GENERATED BY DEFAULT AS IDENTITY"
    Endfunc

    Function addPrimaryKey()
        Return "CONSTRAINT PK PRIMARY KEY"
    Endfunc

	function dropTable(tcTable)
		Local lcScript, lcOPen, lcClose
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		Else
			tcTable = Upper(tcTable)
		EndIf
		
		Text to lcScript noshow pretext 7 textmerge
			DROP TABLE <<lcLeft>><<tcTable>><<lcRight>>;
		endtext
		Return lcScript
	EndFunc

	Function getCreateDatabaseScript(tcDatabase)
		* Firebird
	EndFunc
	
	Function getDataBaseExistsScript(tcDatabase)
		Local lcScript, lcOPen, lcClose
		Store "" to lcLeft, lcRight
		
		If this.bUseDelimiter
			lcLeft = This.getOpenNameSymbol()
			lcRight = This.getCloseNameSymbol()
		Else
			tcDatabase = Upper(tcDatabase)
		EndIf
		Text to lcScript noshow pretext 7 textmerge
			SELECT 1 FROM rdb$database WHERE LOWER(rdb$database_name) = LOWER('<<lcLeft>><<tcDatabase>><<lcRight>>')
		EndText
		Return lcScript
	EndFunc

	Function addFieldComment(tcComment)
		Return " "
	EndFunc
	
	Function addTableComment(tcComment)
		Return " "
	EndFunc	
	
    Function addForeignKey(toFkData)
        Local lcScript, lcOnUpdate, lcOnDelete, lcOPen, lcClose
        lcOnUpdate = This.getForeignKeyValue(toFkData.cOnUpdate)
        lcOnDelete = This.getForeignKeyValue(toFkData.cOnDelete)
		Store "" to lcOPen, lcClose
		
		If this.bUseDelimiter
			lcOPen  = This.getOpenNameSymbol()
			lcClose = This.getCloseNameSymbol()
		Else
			toFkData.cCurrentField = Upper(toFkData.cCurrentField)
			toFkData.cField = Upper(toFkData.cField)
			toFkData.cTable = Upper(toFkData.cTable)
		EndIf
		        
        TEXT to lcScript noshow pretext 7 textmerge
            CONSTRAINT <<toFkData.cCurrentField>>_FK
            FOREIGN KEY (<<lcOPen>><<toFkData.cCurrentField>><<lcClose>>)
            REFERENCES <<lcOPen>><<toFkData.cTable>><<lcClose>>(<<lcOPen>><<toFkData.cField>><<lcClose>>)
            ON UPDATE <<lcOnUpdate>>
            ON DELETE <<lcOnDelete>>
        endtext

        Return lcScript
    Endfunc

    Function getForeignKeyValue(tcValue)
        If Upper(tcValue) == "NO ACTION"
            Return "NO ACTION"
        Else
            Return "CASCADE"
        Endif
    Endfunc

    Function visitCType(toFields)
        Return "CHAR(" + toFields.Size + ")"
    Endfunc

    Function visitYType(toFields)
        Return "DECIMAL(18,4)"
    Endfunc

    Function visitDType(toFields)
        Return "DATE"
    Endfunc

    Function visitTType(toFields)
        Return "TIMESTAMP"
    Endfunc

    Function visitBType(toFields)
	    toFields.Default = "0.0"
	    Return "DECIMAL(" + toFields.Size + "," + toFields.Decimal + ")"
    Endfunc

    Function visitFType(toFields)
	    toFields.Default = "0.0"
	    Return "DECIMAL(" + toFields.Size + "," + toFields.Decimal + ")"
    Endfunc

    Function visitGType(toFields)
        Return "BLOB SUB_TYPE 0"
    Endfunc

    Function visitIType(toFields)
        Return "INTEGER"
    Endfunc

    Function visitLType(toFields)
        Return "BOOLEAN"
    Endfunc

    Function visitMType(toFields)
        Return "BLOB SUB_TYPE 1"
    Endfunc

    Function visitNType(toFields)
        If Val(toFields.Decimal) > 0
            Return "NUMERIC(" + toFields.Size + "," + toFields.Decimal + ")"
        Else
            Return "INTEGER"
        Endif
    Endfunc

    Function visitQType(toFields)
        Return "BLOB SUB_TYPE 0"
    Endfunc

    Function visitVType(toFields)
        Return "VARCHAR(" + Iif(Empty(Val(toFields.Size)), '8191', toFields.Size) + ")"
    Endfunc

    Function visitWType(toFields)
        Return "BLOB SUB_TYPE 0"
    Endfunc
Enddefine
