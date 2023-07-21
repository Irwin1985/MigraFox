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
	#ifndef ttDefTable
		#Define ttDefTable 123
	#endif
	#ifndef ttDefName
		#Define ttDefName 124
	#endif
	#ifndef ttComposed
		#Define ttComposed 125
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
	#ifndef ttGuid
		#Define ttGuid 212
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
	nSourceLen = 0
	nTokenAnt = 0
	oTokens = .null.

	Procedure Init(tcSource)
		This.cSource = tcSource
		This.nSourceLen = Len(tcSource)
		* Create keywords
		This.oKeywords = Createobject("Scripting.Dictionary")
		With this.oKeywords
			.Add('table', ttTable)
			.Add('description', ttDescription)
			.Add('fields', ttFields)

			* Fields attributes
			.Add('name', ttName)
			.Add('type', ttType)
			.Add('size', ttSize)
			.Add('primarykey', ttPrimaryKey)
			.Add('allownull', ttAllowNull)
			.Add('default', ttDefault)
			.Add('foreignkey', ttForeignKey)
			.Add('fktable', ttFkTable)
			.Add('fkfield', ttFkField)
			.Add('ondelete', ttOnDelete)
			.Add('onupdate', ttOnUpdate)
			.Add('cascade', ttCascade)
			.Add('restrict', ttRestrict)
			.Add('null', ttNull)
			.Add('index', ttIndex)
			.Add('columns', ttColumns)
			.Add('sort', ttSort)
			.Add('unique', ttUnique)
			.Add('asc', ttAsc)
			.Add('desc', ttDesc)
			.Add('autoincrement', ttAutoIncrement)
			.add('composed', ttComposed)

			* Data Types
			.Add('true', ttTrue)
			.Add('false', ttFalse)
			
			* Table data types
			.Add('char', ttChar)
			.Add('varchar', ttVarchar)
			.Add('decimal', ttDecimal)
			.Add('date', ttDate)
			.Add('datetime', ttDateTime)
			.Add('double', ttDouble)
			.Add('float', ttFloat)
			.Add('int', ttInt)
			.Add('bool', ttBool)
			.Add('text', ttText)
			.Add('varbinary', ttVarBinary)
			.Add('blob', ttBlob)
			.Add('guid', ttGuid)
		EndWith
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

	Hidden procedure getIdentifier
		Local lcLexeme
		Do While At(This.peek(), This.cLetters) > 0
			This.advance()
		Enddo
		lcLexeme = Substr(This.cSource, This.nStart, This.nCurrent-This.nStart)

		Return lcLexeme
	EndProc

	Hidden procedure readIdentifier
		Local lcLexeme, lnCol, lnTokenType
		lnCol = this.nCol-1
		lnTokenType = ttIdent
		lcLexeme = Lower(this.getIdentifier())

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
			Local lcMsg
			Text to lcMsg noshow pretext 7 textmerge
				Error de conversión:
				No se pudo convertir el valor siguiente en un número entero:

				Valor: "<<lcLexeme>>"

				Mensaje: "<<loEx.Message>>"
				
				Ubicación: [<<this.nLine>>:<<lnCol>>]

				Por favor, asegúrate de ingresar un número válido y sin caracteres no numéricos.
			endtext
			MessageBox(lcMsg, 16)
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
		this.oTokens = CreateObject("Collection")

		Do While !This.isAtEnd()
			This.skipWhitespace()
			This.nStart = This.nCurrent
			This.scanToken()
		Enddo
		This.addToken(ttEof)

		Return this.oTokens
	Endfunc

	Hidden Procedure scanToken
		Local ch, cPeek, cIdent
		ch = This.advance()
		cPeek = ''
		cIdent = ''
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
		Case ch == '-'
			this.skipWhitespace()
			cPeek = this.peek()
			If IsDigit(cPeek)
				This.readNumber()
				Return
			EndIf
			This.nStart = this.nCurrent
			this.advance()		
			cIdent = Lower(this.getIdentifier())
			Do case
			Case cIdent == 'table'
				This.addToken(ttDefTable, tkGeneric, 'table')
			Case cIdent == 'name'
				This.addToken(ttDefName, tkGeneric, 'name')
			Case cIdent == 'columns'
				this.addToken(ttColumns, tkGeneric, 'columns')
			Otherwise
				Local lcMsg
				Text to lcMsg noshow pretext 7 textmerge
				    Uso inválido del símbolo [-] con la palabra:

				    Palabra: "<<cIdent>>"

				    Ubicación: [<<this.nLine>>:<<This.nStart>>]

				    Por favor, asegúrate de utilizar el símbolo [-] correctamente con una de las palabras reservadas válidas.
				endtext
				MessageBox(lcMsg, 16)
			endcase			
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
		Local loToken,lnCol
		lnCol = Iif(Empty(tnCol), this.nCol, tnCol)
		loToken = Createobject("Token", tnType, "", tvLiteral, This.nLine, lnCol)
		loToken.nKind = Iif(Empty(tnKind), tkGeneric, tnKind)
		This.oTokens.Add(loToken)
		this.nTokenAnt = tnType
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
	nCurrent, ;
	oTokens, ;
	cMsg1, ;
	cMsg2
	
	nCurrent = 1
	
	Procedure Init(toTokens)
		this.oTokens = toTokens
	EndProc
		
	function parse
		Local loTables, loTable, loAtt
		loTables = CreateObject("Collection")
		
		Do while !this.isAtEnd() and this.match(ttDefTable)		
			this.consume(ttColon, "Se esperaba el símbolo ':' luego del atributo 'table'")
			this.consume(ttNewLine, "Se esperaba un salto de línea")
			lnCol = this.oPeek.nCol
			loTable = CreateObject("Collection")
			Do while this.oPeek.nCol == lnCol
				loAtt = this.parseAttribute()
				If IsNull(loAtt)
					loop
				EndIf
				loTable.Add(loAtt)
			EndDo
			loTables.Add(loTable)
		EndDo

		Return loTables
	EndFunc

	Hidden function parseAttribute
		Local loToken, lvValue
		loToken = this.validateAttribute()
		If IsNull(loToken)
			Return .null.
		EndIf
		this.consume(ttColon, "Se esperaba el símbolo ':' luego del atributo '" + loToken.cLexeme + "'")
		Do case
		case loToken.nType == ttFields
			lvValue = this.parseFields()
		case loToken.nType == ttForeignKey
			lvValue = this.parseForeignKey()
		Case loToken.nType == ttComposed			
			lvValue = this.parseComposed()
		Otherwise
			lvValue = this.primary()
			this.consume(ttNewLine, "Se esperaba un salto de línea")			
		Endcase	

		Return CreateObject("Node", loToken, lvValue)
	EndFunc
	
	Hidden function parseFields
		Local loFieldList, loAttributes, loNode, lvValue, lnCol, loName, loAtt
		this.consume(ttNewLine, "Se esperaba un salto de línea")
		loFieldList = CreateObject("Collection")
		
		Do while !this.isAtEnd() and this.match(ttDefName)
			loName = this.oPrevious
			this.consume(ttColon, "Se esperaba el símbolo ':' luego del atributo 'name'")
			lvValue = this.primary()
			
			this.consume(ttNewLine, "Se esperaba un salto de línea")
			loAttributes = CreateObject("Collection")
			loNode = CreateObject("Node", loName, lvValue)
			loAttributes.Add(loNode)
			
			lnCol = this.oPeek.nCol
			Do while this.oPeek.nCol == lnCol
				loAtt = this.parseAttribute()
				If IsNull(loAtt)
					Loop
				EndIf
				loAttributes.Add(loAtt)
			enddo
			loFieldList.Add(loAttributes)
		EndDo		
		
		Return loFieldList
	EndFunc	

	Hidden function parseComposed
		Local loList, loAttributes, loNode, lvValue, lnCol, loName, loAtt
		this.consume(ttNewLine, "Se esperaba un salto de línea")
		loList = CreateObject("Collection")
		Do while !this.isAtEnd() and this.match(ttColumns)
			loName = this.oPrevious
			this.consume(ttColon, "Se esperaba el símbolo ':' luego del atributo 'columns'")
			lvValue = this.primary()
			
			this.consume(ttNewLine, "Se esperaba un salto de línea")
			loAttributes = CreateObject("Collection")
			loNode = CreateObject("Node", loName, lvValue)
			loAttributes.Add(loNode)
			
			lnCol = this.oPeek.nCol
			Do while this.oPeek.nCol == lnCol
				loAtt = this.parseAttribute()
				If IsNull(loAtt)
					Loop
				EndIf
				loAttributes.Add(loAtt)
			enddo
			loList.Add(loAttributes)
		EndDo		
		
		Return loList
	EndFunc	

	Hidden function parseForeignKey
		Local loForeignKeys, loAtt, lnCol
		this.consume(ttNewLine, "Se esperaba un salto de línea")
		loForeignKeys = CreateObject("Collection")
		
		lnCol = this.oPeek.nCol
		Do while this.oPeek.nCol == lnCol
			loAtt = this.parseAttribute()
			If IsNull(loAtt)
				Loop
			EndIf
			loForeignKeys.Add(loAtt)
		EndDo		
		
		Return loForeignKeys
	EndFunc	

	Hidden function parseIndex
		Local loIndexes, loAtt
		this.consume(ttNewLine, "Se esperaba un salto de línea")
		loIndexes = CreateObject("Collection")
		
		lnCol = this.oPeek.nCol
		Do while this.oPeek.nCol == lnCol
			loAtt = this.parseAttribute()
			If IsNull(loAtt)
				Loop
			EndIf
			loIndexes.Add(loAtt)
		EndDo		
		
		Return loIndexes
	EndFunc	
		
	Hidden function validateAttribute
		Do case
		Case this.match(ttTable)
		Case this.match(ttDescription)
		Case this.match(ttFields)
		Case this.match(ttName)
		Case this.match(ttType)
		Case this.match(ttSize)
		Case this.match(ttPrimaryKey)
		Case this.match(ttAllowNull)
		Case this.match(ttDefault)
		Case this.match(ttForeignKey)
		Case this.match(ttFkTable)
		Case this.match(ttFkField)
		Case this.match(ttOnDelete)
		Case this.match(ttOnUpdate)
		Case this.match(ttIndex)
		Case this.match(ttColumns)
		Case this.match(ttSort)
		Case this.match(ttUnique)
		Case this.match(ttAutoIncrement)
		Case this.match(ttDecimal)
		Case this.match(ttComposed)
		Otherwise
			this.parseError("Se esparaba un atributo pero se obtuvo: " + Transform(this.oPeek.vLiteral))
			Return .null.
		EndCase
		Return this.oPrevious
	EndFunc
	
	Hidden function primary
		Do case
		Case this.match(ttDefault)
		Case this.match(ttCascade)
		Case this.match(ttRestrict)
		Case this.match(ttNull)
		Case this.match(ttAsc)
		Case this.match(ttDesc)
		Case this.match(ttChar)
		Case this.match(ttVarchar)
		Case this.match(ttDate)
		Case this.match(ttDateTime)
		Case this.match(ttDouble)
		Case this.match(ttFloat)
		Case this.match(ttInt)
		Case this.match(ttBool)
		Case this.match(ttText)
		Case this.match(ttVarbinary)
		Case this.match(ttBlob)
		Case this.match(ttGuid)
		Case this.match(ttIdent)
		Case this.match(ttString)
		Case this.match(ttNumber)
		Case this.match(ttTrue)
		Case this.match(ttFalse)
		Case this.match(ttUnique)
		Case this.match(ttLeftBracket)
			Local loValue
			loValue = CreateObject("Collection")
			If !this.match(ttRightBracket)
				If this.oPeek.nKind != tkIdent
					this.parseError("Valor inválido: " + tokenName(this.oPeek.nType))
					Return .null.
				EndIf
				loValue.Add(CreateObject("Node", this.parseArrayValues()))
				Do while this.match(ttComma)
					If this.oPeek.nKind != tkIdent
						this.parseError("Valor inválido: " + tokenName(this.oPeek.nType))
						Return .null.
					EndIf
					loValue.Add(CreateObject("Node", this.parseArrayValues()))
				EndDo
				this.consume(ttRightBracket, "Se esperaba ']' tras el nombre de la columna")
			EndIf
			Return loValue
		Otherwise
			this.parseError("Se esparaba un valor escalar o compuesto pero se obtuvo: " + Transform(this.oPeek.vLiteral))
			Return .null.
		EndCase
		Return this.oPrevious
	EndFunc
	
	Hidden function parseArrayValues
		Local loValues
		loValues = CreateObject("Collection")
		loValues.Add(this.advance())
		Do while this.oPeek.nKind == tkIdent
			loValues.Add(this.advance())
		EndDo
		If loValues.count == 1
			Return loValues(1)
		EndIf
		Return loValues
	endfunc
	
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
		Local lcMsg
		Text to lcMsg noshow pretext 7 textmerge
		    ERROR - Símbolo Inesperado:

		    Se encontró el símbolo inesperado '<<tokenName(this.oPeek.nType)>>' en la línea <<this.oPeek.nLine>> y columna <<this.oPeek.nCol>>.

		    <<tcMessage>>

		    Por favor, verifica la sintaxis del código y asegúrate de que esté correctamente estructurado.
		endtext
		MessageBox(lcMsg, 16)
		this.parseError()
		Return .null.
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
		Return this.oTokens[this.nCurrent]
	EndFunc
	
	Hidden Function oPeekNext_Access
		Local lnNext
		lnNext = this.nCurrent + 1
		If lnNext <= this.oTokens.count
			Return this.oTokens[lnNext]
		EndIf
		Return Createobject("Token", ttProgram, "", 0, 0, 0)
	EndFunc	
	
	Hidden function oPrevious_Access
		Return this.oTokens[this.nCurrent-1]
	EndFunc
	
	Hidden procedure parseError(tcMessage)
		If !Empty(tcMessage)
			Local loToken, lcMsg
			loToken = this.oPeek
			lcMsg = 'Error en [' + Alltrim(Str(loToken.nLine)) + ':' + Alltrim(Str(loToken.nCol)) + ']: ' + tcMessage
			MessageBox(lcMsg, 16)
		EndIf
		
		* Estabilizar el Parser
		Do while !this.isAtEnd() and !this.check(ttNewLine)
			this.advance()
		EndDo
		If this.isAtEnd()
			Return
		EndIf
		If !this.check(ttNewLine)
			MessageBox("ERROR: hubo un error en el analizador sintáctico del cual no se pudo recuperar.", 16)
		EndIf
	endproc
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
EndDefine

* =================================================================================== *
* scanTokens
* =================================================================================== *
Function scanTokens(tcFileName)
	Local loScanner, lcScript, loTokens
	lcScript = Strconv(FileToStr(tcFileName), 11)
	If Right(lcScript, 1) != Chr(10)
		lcScript = lcScript + Chr(13) + Chr(10)
	EndIf
	
	defineConstants()
	loScanner = Createobject("Scanner", lcScript)
	loTokens = loScanner.scanTokens()

	Return loTokens
EndFunc
* =================================================================================== *
* testScanner
* =================================================================================== *
Procedure testScanner(tcFileName, tbPrintTokens)
	Local loTokens
	loTokens = scanTokens(tcFileName)
	
	If tbPrintTokens
		lcFile = "F:\Desarrollo\Mini_ERP\rutinas\tokens.txt"
		If File(lcFile)
			try
				Delete File &lcFile
			Catch
			EndTry
		EndIf
		For Each loToken In loTokens
			lcText = loToken.toString()
			lcText = lcText + CRLF
			=StrToFile(lcText, lcFile, 1)
		EndFor
		Modify File (lcFile)
	EndIf
EndProc
* =================================================================================== *
* testParser
* =================================================================================== *
Procedure testParser(tcFileName)
	Local loTokens, loParser, loTables
	loTokens = scanTokens(tcFileName)
	loParser = CreateObject("Parser", loTokens)
	loTables = loParser.parse()
	MessageBox(loTables.count)
endproc
* =================================================================================== *
* testEvaluator
* =================================================================================== *
Procedure testEvaluator(tcFileName)
	Local loTokens, loParser, loTables
	loTokens = scanTokens(tcFileName)
	loParser = CreateObject("Parser", loTokens)
	loTables = loParser.parse()
	loTMGObject = evalTables(loTables)
	MessageBox(loTMGObject)
EndProc

Function executeTMGFile(tcFileName)
	Local loTokens, loParser, loTables, loNode, lcScript
	lcScript = Strconv(FileToStr(tcFileName), 11)
	If Right(lcScript, 1) != Chr(10)
		lcScript = lcScript + Chr(13) + Chr(10)
	EndIf
	defineConstants()

	loTokens = scanTokens(tcFileName)
	loParser = CreateObject("Parser", loTokens)
	loNode = loParser.parse()
	loTables = evalTables(loNode)
	Return loTables
EndFunc
* =================================================================================== *
* Function evalTables
* =================================================================================== *
Function evalTables(toTables)
	Local loTablesList
	loTablesList = CreateObject("Collection")
			
	For each loTable in toTables
		Local loTableData, loFieldFk
		loTableData = CreateObject("Empty")		
		* Table metadata
		AddProperty(loTableData, "cTableName", "")
		AddProperty(loTableData, "cTableDescription", "")
		AddProperty(loTableData, "aTableFields[1]", .null.)
		AddProperty(loTableData, "oComposedIndexes", CreateObject("Collection"))

		For each loAttribute in loTable
			Do case
			Case loAttribute.oToken.nType == ttName
				loTableData.cTableName = loAttribute.vValue.vLiteral
			Case loAttribute.oToken.nType == ttDescription
				loTableData.cTableDescription = loAttribute.vValue.vLiteral
			Case loAttribute.oToken.nType == ttComposed
				Local loColumnInfo, loMetaData				
				
				For each loNode in loAttribute.vValue && Recorre el número de composiciones
					loComposed = CreateObject("Empty")
					AddProperty(loComposed, "oColumns", CreateObject("Collection"))
					AddProperty(loComposed, "bUnique", .f.)
					AddProperty(loComposed, "cName", "idx_" + loTableData.cTableName + Lower(Sys(2015)))
					AddProperty(loComposed, "cSort", "ASC")
					AddProperty(loComposed, "cTable", loTableData.cTableName)

					For each loColumn in loNode && Recorre los atributos de cada composición (columns, unique, name)
						Do case
						Case loColumn.oToken.nType == ttColumns
							loColumnInfo = CreateObject("Collection")
							For each loItem in loColumn.vValue && Recorre el número de columnas que conforman el índice
								Local loColumnMeta
								loColumnMeta = CreateObject("Empty")
								AddProperty(loColumnMeta, "cName", "")
								AddProperty(loColumnMeta, "cSort", "ASC")
								Do case
								case loItem.vValue.class == "Collection"
									Local loPair
									loPair = loItem.vValue
									loColumnMeta.cName = loPair.Item(1).vLiteral
									loColumnMeta.cSort = loPair.Item(2).vLiteral
								case loItem.vValue.class == "Token"
									loColumnMeta.cName = loItem.vValue.vLiteral
								EndCase
								loColumnInfo.Add(loColumnMeta)								
							EndFor
							loComposed.oColumns.add(loColumnInfo)							
						Case InList(loColumn.oToken.nType, ttName, ttDefName)
							loComposed.cName = loColumn.vValue.vLiteral
						Case loColumn.oToken.nType == ttUnique
							loComposed.bUnique = (loColumn.vValue.vLiteral == "true")
						Case loColumn.oToken.nType == ttSort
							loComposed.cSort = loColumn.vValue.vLiteral
						Otherwise
							Local lcMsg
							Text to lcMsg noshow pretext 7 textmerge
							    Error en la definición de campo:
							    Atributo inválido para la definición de un campo: `<<tokenName(loField.oToken.nType)>>`

							    Ubicación: [<<loField.oToken.nLine>>:<<loField.oToken.nCol>>]

							    Asegúrate de utilizar los atributos correctos para la definición del campo.
							endtext
							MessageBox(lcMsg, 16)
							*MessageBox("Atributo inválido para la definición de un campo: `" + tokenName(loField.oToken.nType) + "`", 16)
						EndCase
					EndFor
					loTableData.oComposedIndexes.add(loComposed)
				EndFor
			Case loAttribute.oToken.nType == ttFields
				Local laFields[loAttribute.vValue.count, 23], i
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
					laFields[i, 23] = .null. && Index metadata

					For each loField in loNode
						Do case
						Case InList(loField.oToken.nType, ttName, ttDefName)
							laFields[i, 1] = loField.vValue.vLiteral
						Case loField.oToken.nType == ttType
							laFields[i, 2] = typeToLetter(loField.vValue.vLiteral)
						Case loField.oToken.nType == ttSize
							laFields[i, 3] = loField.vValue.vLiteral
						Case loField.oToken.nType == ttDecimal
							laFields[i, 4] = loField.vValue.vLiteral
						Case loField.oToken.nType == ttAllowNull
							laFields[i, 5] = (loField.vValue.vLiteral == "true")
						Case loField.oToken.nType == ttDefault
							laFields[i, 19] = loField.vValue.vLiteral
						Case loField.oToken.nType == ttDescription
							laFields[i, 16] = loField.vValue.vLiteral
						Case loField.oToken.nType == ttAutoIncrement
							laFields[i, 22] = (loField.vValue.vLiteral == "true")
						Case loField.oToken.nType == ttPrimaryKey
							laFields[i, 20] = (loField.vValue.vLiteral == "true")
						Case loField.oToken.nType == ttIndex
							Local loIdxMeta
							loIdxMeta = CreateObject("Empty")
							AddProperty(loIdxMeta, "cTable", loTableData.cTableName)
							AddProperty(loIdxMeta, "cField", laFields[i, 1])
							AddProperty(loIdxMeta, "bUnique", .f.)
							AddProperty(loIdxMeta, "cSort", "ASC")
							AddProperty(loIdxMeta, "cName", "idx_" + loIdxMeta.cTable + '_' + loIdxMeta.cField)
							Do case
							case loField.vValue.class == "Collection"
								For each loIdex in loField.vValue
									If InList(loIdex.oToken.nType, ttAsc, ttDesc)
										loIdxMeta.cSort = loIdex.vValue.vLiteral
										Loop
									EndIf
									If loIdex.oToken.nType == ttUnique
										loIdxMeta.bUnique = .t.
										Loop
									EndIf
									Local lcMsg
									Text to lcMsg noshow pretext 7 textmerge
									    Error en la definición de índice:
									    Atributo inválido para la definición de un índice: `<<tokenName(loIndex.oToken.nType)>>`

									    Ubicación: [<<loIndex.oToken.nLine>>:<<loIndex.oToken.nCol>>]

									    Asegúrate de utilizar los atributos correctos para la definición del índice.
									endtext
									MessageBox(lcMsg, 16)
									*MessageBox("Atributo inválido para la definición de un índice: `" + tokenName(loIdex.oToken.nType) + "`", 16)
								EndFor
							Case loField.vValue.class == "Token"
								Local llValidate
								llValidate = .t.
								If InList(loField.vValue.nType, ttAsc, ttDesc)
									loIdxMeta.cSort = loField.vValue.vLiteral
									llValidate = .f.
								EndIf
								If InList(loField.vValue.nType, ttTrue, ttFalse)
									If loField.vValue.vLiteral == "false"
										loIdxMeta = .null.
									EndIf
									llValidate = .f.
								EndIf				
								If loField.vValue.nType == ttUnique
									loIdxMeta.bUnique = .t.
									llValidate = .f.
								EndIf
								If llValidate
									Local lcMsg
									Text to lcMsg noshow pretext 7 textmerge
									    Error en la definición de índice:
									    Valor inválido para la definición de un índice: `<<tokenName(loField.vValue.nType)>>`

									    Ubicación: [<<loField.vValue.nLine>>:<<loField.vValue.nCol>>]

									    Asegúrate de proporcionar un valor válido para la definición del índice.
									endtext
									MessageBox(lcMsg, 16)
									*MessageBox("Valor inválido para la definición de un índice: `" + tokenName(loField.vValue.nType) + "`", 16)
								EndIf
							Otherwise
								Local lcMsg
								Text to lcMsg noshow pretext 7 textmerge
								    Error en la definición de índice:
								    Valor inválido para la definición de un índice: `<<tokenName(loField.vValue.nType)>>`

								    Ubicación: [<<loField.vValue.nLine>>:<<loField.vValue.nCol>>]

								    Asegúrate de proporcionar un valor válido para la definición del índice.
								endtext
								MessageBox(lcMsg, 16)
							endcase
							laFields[i, 23] = loIdxMeta						
						Case loField.oToken.nType == ttForeignKey
							* Field metadata
							loFieldFk = CreateObject("Empty")
							AddProperty(loFieldFk, "cTable", "")
							AddProperty(loFieldFk, "cField", "")
							AddProperty(loFieldFk, "cName", "fk_" + Sys(2015))
							AddProperty(loFieldFk, "cCurrentTable", loTableData.cTableName)
							AddProperty(loFieldFk, "cCurrentField", laFields[i, 1])
							AddProperty(loFieldFk, "cOnDelete", "DEFAULT")
							AddProperty(loFieldFk, "cOnUpdate", "DEFAULT")
							
							For each loField2 in loField.vValue
								If loField2.oToken.nType == ttFkTable
									loFieldFk.cTable = loField2.vValue.vLiteral
									Loop
								EndIf
								
								If loField2.oToken.nType == ttFkField
									loFieldFk.cField = loField2.vValue.vLiteral
									Loop
								EndIf
								
								If loField2.oToken.nType == ttOnDelete
									loFieldFk.cOnDelete = loField2.vValue.vLiteral
									Loop
								EndIf
								
								If loField2.oToken.nType == ttOnUpdate
									loFieldFk.cOnUpdate = loField2.vValue.vLiteral
									Loop
								EndIf
								Local lcMsg
								Text to lcMsg noshow pretext 7 textmerge
								    Error en la definición de clave foránea:
								    Atributo inválido para la definición de una clave foránea: `<<tokenName(loField2.oToken.nType)>>`

								    Ubicación: [<<loField2.oToken.nLine>>:<<loField2.oToken.nCol>>]

								    Asegúrate de utilizar atributos válidos para la definición de la clave foránea.
								endtext
								MessageBox(lcMsg, 16)
								*MessageBox("Atributo inválido para la definición de una clave foránea: `" + tokenName(loField2.oToken.nType) + "`", 16)
							EndFor
							laFields[i, 21] = loFieldFk
						Otherwise
							Local lcMsg
							Text to lcMsg noshow pretext 7 textmerge
							    Error en la definición de una columna:
							    Atributo inválido para la definición de un campo: `<<tokenName(loField.oToken.nType)>>`

							    Ubicación: [<<loField.oToken.nLine>>:<<loField.oToken.nCol>>]

							    Asegúrate de utilizar atributos válidos para la definición de un campo.
							endtext
							MessageBox(lcMsg, 16)
							*MessageBox("Atributo inválido para la definición de un campo: `" + tokenName(loField.oToken.nType) + "`", 16)
						EndCase
					EndFor
				EndFor				
			Otherwise
				Local lcMsg
				Text to lcMsg noshow pretext 7 textmerge
				    Error en la definición de la tabla:
				    Atributo inválido para la definición de una tabla: `<<tokenName(loAttribute.oToken.nType)>>`

				    Ubicación: [<<loAttribute.oToken.nLine>>:<<loAttribute.oToken.nCol>>]

				    Asegúrate de utilizar atributos válidos para la definición de la tabla.
				endtext
				MessageBox(lcMsg, 16)
				*MessageBox("Atributo inválido para la definición de una tabla: `" + tokenName(loAttribute.oToken.nType) + "`", 16)
			EndCase			
		EndFor
		=Acopy(laFields, loTableData.aTableFields)
		loTablesList.Add(loTableData)
	EndFor
	Return loTablesList
EndFunc
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
	Case tnType == 123
		Return "ttDefTable"
	Case tnType == 124
		Return "ttDefName"
	Case tnType == 125
		Return "ttComposed"
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
	Case tnType == 212
		Return "ttGuid"
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
		If Pcount() = 1
			this.vValue = toToken
		Else
			this.vValue = tvValue
		EndIf
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
		Return 'C'
	CASE tcType == "currency"
		Return 'Y'
	CASE tcType == "date"
		Return 'D'
	CASE tcType == "datetime"
		Return 'T'
	CASE tcType == "double"
		Return 'B'
	CASE tcType == "float"
		Return 'F'
	CASE tcType == "int"
		Return 'I'
	CASE tcType == "bool"
		Return 'L'
	CASE tcType == "text"
		Return 'M'
	CASE tcType == "numeric"
		Return 'N'
	CASE tcType == "varbinary"
		Return 'Q'
	CASE InList(tcType, "string", "varchar")
		Return 'V'
	CASE tcType == "blob"
		Return 'W'
	Case tcType == "guid"
		Return 'U'
	OTHERWISE
		Local lcMsg
		Text to lcMsg noshow pretext 7 textmerge
		    Tipo de dato desconocido: '<<tcType>>'

		    El tipo de dato proporcionado no coincide con ninguno de los tipos de datos conocidos. Asegúrate de ingresar una letra válida que represente un tipo de dato válido para el motor de base de datos que estás utilizando.

		    Tipos de datos conocidos:
		    C: Caracter
		    Y: Decimal
		    D: Fecha
		    T: Fecha y hora
		    B: Decimal con precisión exacta
		    F: Decimal con precisión aproximada
		    G: BLOB binario
		    I: Entero
		    L: Lógico (booleano)
		    M: BLOB de texto
		    N: Número
		    Q: BLOB de texto (longitud máxima 2GB)
		    V: Caracter variable (VARCHAR)
		    W: BLOB de texto (longitud máxima 2GB)

		    Por favor, verifica el tipo de dato ingresado y asegúrate de que sea válido.
		endtext
		MessageBox(lcMsg)
		*MessageBox("Tipo de dato desconocido: '" + tcType + "'")
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
	bUseSymbolDelimiter = .F.
	cPKName		= "TID"	
	nMaxLength  = 0 && Every engine should fill this value.
	bCanGenerateGUID = .T.

	Dimension aCustomArray[1]
	Hidden nCounter
	nCounter = 0
	bExecuteIndexScriptSeparately = .f.
	bExecuteFkScriptSeparately = .f.
	cLeft = ''
	cRight = ''

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

	function Connect(tbAddDatabase)
		If This.nHandle > 0
			If This.reconnect()
				Return
			Endif
		Endif

		Local lcConStr
		lcConStr = This.getConnectionString(tbAddDatabase)
		This.nHandle = Sqlstringconnect(lcConStr, .T.)

		If This.nHandle <= 0
			This.sqlError()
			Return .f.
		Endif
		This.applyConnectionSettings()
		
		If tbAddDatabase
			Return && No es necesario crear la base de datos.
		EndIf
		
		this.newDataBase(this.cDatabase)
		this.selectDatabase()
		Return .t.
	EndFunc
	
	Function newDataBase(tcDataBase)
		If InList(Lower(this.Name), "firebird", "sqlite")
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
			this.changeDB(tcDataBase)
			Return .t.
		EndIf
		
		lcScript = this.getCreateDataBaseScript(tcDataBase)
		If !This.SQLExec(lcScript)
			Return .F.
		EndIf
		this.changeDB(tcDataBase)
		
		Return .t.		
	EndFunc

	Function use(tcTable, tcFields, tcCriteria, tcGroup, tbReadOnly, tbNodata)
		Local lcSqlTableName, lcAlias

		this.getTableAndAlias(tcTable, @lcSqlTableName, @lcAlias)
		
		If Used(lcAlias)
			Return .f.
		EndIf

		If !This.tableExists(lcSqlTableName)
			Local lcMsg
			Text to lcMsg noshow pretext 7 textmerge
			    Error - Tabla Inexistente:
			    La tabla con el nombre '<<lcSqlTableName>>' no existe en la base de datos.

			    Por favor, asegúrate de que el nombre de la tabla esté escrito correctamente y que la tabla haya sido creada previamente en la base de datos.
			endtext
			MessageBox(lcMsg, 16)
			*MessageBox("La tabla " + lcSqlTableName + " no existe en la base de datos.", 16)
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

	function changeDB(tcNewDatabase)
		* Abstract
	endfunc

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
			Local nNextRec, lcTypeOpe, lcFldState, lcCommand, lcLeft, lcRight, lcSQLTable, lcScript, laFields[1], laDateFields[1]
			
			lcLeft  = This.cLeft
			lcRight = This.cRight
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
						lcScript = this.updateRowScript(lcLeft, lcRight, lcSQLTable, lcKeyField, lcFldState)
						Scatter memo name loRow
						this.updateFetchedRow(@laDateFields, loRow)
					Case Left(lcFldState, 1) == '2' && DELETE
						lcScript = "DELETE FROM " + lcLeft + lcSQLTable + lcRight + " WHERE " + lcLeft + lcKeyField + lcRight + "=?lvKeyValue"
					EndCase
				Else && INSERT
					If this.rowExists(lcLeft, lcRight, lcSQLTable, lcKeyField, lvKeyValue)
						lcScript = this.updateRowScript(lcLeft, lcRight, lcSQLTable, lcKeyField, lcFldState)
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
							lcFieldsScript = lcFieldsScript + lcLeft + laInsFields[j] + lcRight + ','
							lcValuesScript = lcValuesScript + '?loRow.' + laInsFields[j] + ','
						EndFor
						
						lcFieldsScript = Substr(lcFieldsScript, 1, Len(lcFieldsScript)-1)
						lcValuesScript = Substr(lcValuesScript, 1, Len(lcValuesScript)-1)

						Scatter Memo Name loRow
						this.updateFetchedRow(@laDateFields, loRow)
						lcScript = "INSERT INTO " + lcLeft + lcSQLTable + lcRight + " (" + lcFieldsScript + ")"
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
			lcFieldsScript, lcValuesScript, lcLeft, lcRight, lcDateAct, laDateFields[1], ;
			lcMarkAct, lcCenturyAct, loEnv, lcScript, lbMigrateDBC, loTables, lcTableDescription, ;
			loComposedIndexes

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
				Local lcMsg
				Text to lcMsg noshow pretext 7 textmerge
				    Error - Tipo de Archivo Inválido:
				    Solo se permiten migraciones de ficheros DBF, DBC o TMG.

				    Por favor, asegúrate de que estás intentando migrar un archivo con una extensión válida (DBF, DBC o TMG).
				endtext
				MessageBox(lcMsg, 16)
				*MessageBox("Solo se permiten migraciones de ficheros DBF, DBC o TMG", 16)
				Return .f.
			EndIf

			Do case
			case Upper(JustExt(tcTableOrPath)) == "DBC"
				Open Database (tcTableOrPath) Shared
				=ADBObjects(laTables, "TABLE")
				lbMigrateDBC = .T.
			Case Upper(JustExt(tcTableOrPath)) == "TMG"
				loTables = executeTMGFile(tcTableOrPath)
				Dimension laTables[loTables.count]
				z = 0
				For each loTable in loTables
					z = z + 1
					laTables[z] = loTable.cTableName
				EndFor
			Case Upper(JustExt(tcTableOrPath)) == "DBF"
				laTables[1]  = tcTableOrPath
			EndCase
		Endif

		lcLeft = This.cLeft
		lcRight = This.cRight
		
		loEnv = this.setEnvironment()
		For i = 1 To Alen(laTables,1)
			lcTablePath = laTables[i]
			Try
				If Type('loTables') != 'O'
					lcTableName = Juststem(lcTablePath)
					If !Used(lcTableName)
						lbCloseTable = .T.
						Use (lcTablePath) In 0
					EndIf
					=Afields(laFields, lcTableName)
				Else
					Local laFields[1]
					lcTableName 		= loTables(i).cTableName
					lcTableDescription 	= loTables(i).cTableDescription
					loComposedIndexes 	= loTables(i).oComposedIndexes
					Acopy(loTables(i).aTableFields, laFields)
				EndIf				

				laDateFields = this.getDateTimeFields(@laFields)

				If This.tableExists(lcTableName)
					If !this.sqlExec(this.dropTable(lcTableName))
						Return
					EndIf
				Endif
				This.createTable(lcTableName, lcTableDescription, loComposedIndexes, @laFields)
				
				If Type('loTables') != 'O' && <<TMG SCRIPTS does not insert values>>
					* Iterate fields
					lcFieldsScript = Space(1)
					lcValuesScript = Space(1)

					For j=1 To Alen(laFields, 1)
						lcFieldsScript = lcFieldsScript + lcLeft + laFields[j, 1] + lcRight + ','
						lcValuesScript = lcValuesScript + '?loRow.' + laFields[j, 1] + ','
					EndFor
					
					lcFieldsScript = Substr(lcFieldsScript, 1, Len(lcFieldsScript)-1)
					lcValuesScript = Substr(lcValuesScript, 1, Len(lcValuesScript)-1)

					* Insert values
					Select (lcTableName)
					Scan
						Scatter Memo Name loRow
						this.updateFetchedRow(@laDateFields, loRow)
						lcScript = "INSERT INTO " + lcLeft + lcTableName + lcRight + " (" + lcFieldsScript + ")"
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
			Local lcMsg
			Text to lcMsg noshow pretext 7 textmerge
			    Error de Comunicación - Consulta Fallida:

			    Descripción del Error: '<<laSqlError[2]>>' <<Transform(laSqlError[3])>>

			    Consulta SQL Ejecutada:
			    <<tcSQLCommand>>

			    Por favor, verifica que la conexión con el servidor esté establecida correctamente y que la consulta SQL esté escrita correctamente. Si el problema persiste, asegúrate de que el servidor de base de datos esté en funcionamiento y que no haya problemas de conectividad a la base de datos.
			endtext
			MessageBox(lcMsg, 16, "Error de Comunicación")

			*Messagebox("SQL ERROR: " + laSqlError[2] + Transform(laSqlError[3]) + CRLF + "QUERY: " + tcSQLCommand, 16, "Error de comunicación")
			Return .f.
		Endif

		Return .t.
	Endfunc

	Procedure createTable(tcTableName, tcTableDescription, toComposedIndexes, taFields)
		Local i, lcScript, lcType, lcName, lcSize, lcDecimal, lbAllowNull, lcLongName, ;
			lcComment, lnNextValue, lnStepValue, lcDefault, lcLeft, lcRight, loFields, ;
			lcFieldsScript, lcInternalID, lbInsertInternalID, loIdxScript, loOptions
		
		lcLeft  = This.cLeft
		lcRight = This.cRight

		lcFieldsScript 		= ''
		lcInternalID  		= lcLeft + this.cPKName + lcRight + Space(1) + This.getTidScript()
		lbInsertInternalID 	= .T.
		loIdxScript			= CreateObject("Collection")
		loFkScript 			= CreateObject("Collection")
		
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
		=AddProperty(loFields, "index", .null.)
		=AddProperty(loFields, "tag", "")

		For i = 1 To Alen(taFields, 1)
			If Upper(taFields[i, 2]) == 'U' && UUID
				If i > 1
					lcFieldsScript = lcFieldsScript + ', '
				EndIf
				lcFieldsScript = lcFieldsScript + ' ' + This.getUUIDScript()
				Loop
			EndIf
			loFields.Name 		= taFields[i, 1]
			loFields.Type 		= taFields[i, 2]
			loFields.Size 		= Alltrim(Str(taFields[i, 3]))
			loFields.Decimal 	= Alltrim(Str(taFields[i, 4]))
			loFields.allowNull 	= taFields[i, 5]
			loFields.longName 	= taFields[i, 12]
			loFields.Comment 	= taFields[i, 16]
			loFields.Nextvalue 	= taFields[i, 17]
			loFields.stepValue 	= taFields[i, 18]
			loFields.addDefault = .t.
			
			loFields.Default 		= "''"
			loFields.primaryKey 	= .f.
			loFields.foreignKey 	= .null.
			loFields.autoIncrement 	= .f.
			
			* Validate types with mandatory length
			If InList(Upper(loFields.Type), 'C') and Empty(Val(loFields.Size))
				Local lcMsg
				Text to lcMsg noshow pretext 7 textmerge
				    Error - Tipo de Dato CHAR sin Longitud:

				    El tipo de dato CHAR requiere que se especifique su longitud. Por favor, asegúrate de agregar la longitud después del tipo de dato CHAR en la definición de la columna.

				    Ejemplo Correcto:
				    NOMBRE CHAR(50)

				    Por favor, corrige la definición de la tabla para incluir la longitud del tipo CHAR y vuelve a intentarlo.
				endtext
				MessageBox(lcMsg, 48)
				*MessageBox("El tipo de dato CHAR requiere su longitud.", 48)
				loop
			EndIf
			
			If Type('taFields[i, 19]') != 'U'
				If taFields[i, 19] != "''"
					loFields.Default = "'" + taFields[i, 19] + "'"
				EndIf
				loFields.primaryKey 	= taFields[i, 20]
				loFields.foreignKey 	= taFields[i, 21]
				loFields.autoIncrement 	= taFields[i, 22]
				loFields.index			= taFields[i, 23]
			EndIf
			If i > 1
				lcFieldsScript = lcFieldsScript + ', '
			EndIf

			lcFieldsScript = lcFieldsScript + lcLeft + loFields.Name + lcRight + Space(1)
			lcMacro = "this.visit" + loFields.Type + "Type(loFields)"
			lcValue = &lcMacro
			
			If loFields.autoIncrement
				lcValue = this.changeTypeOnAutoIncrement(lcValue)
				lbInsertInternalID = .F.
			EndIf
			lcFieldsScript = lcFieldsScript + lcValue
			
			lcFieldsScript = lcFieldsScript + this.addFieldOptions(loFields)
			
			If !IsNull(loFields.foreignKey)
				loFkScript.Add(this.addForeignKey(loFields.foreignKey))
			EndIf
			
			If !IsNull(loFields.index)
				loIdxScript.Add(this.addSingleIndex(loFields.index))
			EndIf
		EndFor

		lcScript = "CREATE TABLE " + lcLeft + tcTableName + lcRight + '('
		If lbInsertInternalID
			lcScript = lcScript + lcInternalID + ','
		EndIf
		lcScript = lcScript + lcFieldsScript
*!*			If !Empty(lcFkScript)
*!*				lcScript = lcScript + ',' + lcFkScript
*!*			EndIf
		
		Local loComposedScripts, cValue
		loComposedScripts = CreateObject("Collection")
		If toComposedIndexes.count > 0
			loComposedScripts = this.addComposedIndex(toComposedIndexes)
		EndIf
		
		Local cValue
		cValue = ''
		
		If !this.bExecuteFkScriptSeparately
			* Agregamos las claves foráneas
			If loFkScript.count > 0
				For each cValue in loFkScript
					lcScript = lcScript + ',' + cValue
				EndFor
			EndIf
		EndIf
		
		If !this.bExecuteIndexScriptSeparately
			cValue = ''
			* Agregamos los índices individuales
			If loIdxScript.count > 0
				For each cValue in loIdxScript
					lcScript = lcScript + ',' + cValue
				EndFor
			EndIf

			If loComposedScripts.count > 0
				cValue = ''
				* Si tenemos índices compuestos también los agregamos
				For each cValue in loComposedScripts
					lcScript = lcScript + ',' + cValue
				EndFor
			EndIf
		EndIf

		lcScript = lcScript + ')' + This.createTableOptions()
		
		If !Empty(tcTableDescription)
			lcScript = lcScript + this.addTableComment(tcTableDescription)
		EndIf
		
		lcScript = lcScript + ';'
		* POLICIA
*!*			_cliptext = lcScript
*!*			MessageBox(lcScript)
		* POLICIA
		
		If !This.SQLExec(lcScript)
			Return .f.
		EndIf

		If this.bExecuteFkScriptSeparately
			cValue = ''
			* Agregamos las claves foráneas
			If loFkScript.count > 0
				For each cValue in loFkScript
					* POLICIA
*!*						_cliptext = cValue
*!*						MessageBox(cValue)
					* POLICIA
					This.SQLExec(cValue)
				EndFor
			EndIf
		EndIf
		
		If this.bExecuteIndexScriptSeparately
			cValue = ''
			If loIdxScript.count > 0
				* Ejecutamos los índices individuales
				For each cValue in loIdxScript
					* POLICIA
*!*						_cliptext = cValue
*!*						MessageBox(cValue)
					* POLICIA
					This.SQLExec(cValue)
				EndFor
			EndIf
			
			If loComposedScripts.count > 0
				cValue = ''
				* Ejecutamos los índices compuestos
				For each cValue in loComposedScripts
					* POLICIA
*!*						_cliptext = cValue
*!*						MessageBox(cValue)
					* POLICIA
					This.SQLExec(cValue)
				EndFor
			EndIf
			Return .t.
		EndIf
	Endproc

	Procedure sqlError
		Local Array laError[2]
		Aerror(laError)
		Local lcMsg
		Text to lcMsg noshow pretext 7 textmerge
		    ERROR - Error en la Consulta SQL:

		    Código de Error: <<laError[1]>>

		    Mensaje de Error: <<Transform(laError[2]) + Transform(laError[3])>>

		    Por favor, revisa la consulta SQL y asegúrate de que esté correctamente escrita. Verifica que los nombres de tablas, campos y condiciones sean válidos y vuelve a intentarlo.
		endtext
		MessageBox(lcMsg, 16)
		*Messagebox("ERROR: " + Alltrim(Str(laError[1])) + CRLF + "MESSAGE:" + Transform(laError[2]) + Transform(laError[3]), 16, "ERROR")
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
		Local lcLeft, lcRight, lcCommand
		lcLeft = this.cLeft
		lcRight = this.cRight

		If Empty(tcFields)
			tcFields = "*"
		EndIf

		lcCommand = "SELECT " + tcFields + " FROM " + lcLeft + tcTable + lcRight
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
		Text to lcMsg noshow pretext 7 textmerge
		    ERROR - Excepción Controlada:

		    Código de Error: <<toError.ErrorNo>>
		    Línea No.: <<toError.Lineno>>
		    Mensaje: <<toError.Message>>
		    Procedimiento: <<toError.Procedure>>
		    Detalles: <<toError.Details>>
		    Nivel de Pila: <<toError.StackLevel>>
		    Contenido de la Línea: <<toError.LineContents>>
		    Valor de Usuario: <<toError.UserValue>>

		    Por favor, toma nota de la información proporcionada y contacta al equipo de soporte para obtener asistencia adicional en la resolución de este problema.
		endtext
		Messagebox(lcMsg, 16)
	Endproc

	Procedure disconnect
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

	Function bUseSymbolDelimiter_Assign(tvNewVal)
		If !tvNewVal
			this.cLeft = ''
			this.cRight = ''
		EndIf
		this.bUseSymbolDelimiter = tvNewVal
	EndFunc

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

	Function getTidScript
		* Abstract
	EndFunc
	
	Function getUUIDScript
		* Abstract
	EndFunc
	
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
	
	Function addSingleIndex(toIndex)
		* Abstract
	EndFunc
	
	Function addComposedIndex(toIndex)
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
	EndFunc
	
	Function addFieldOptions(toField)
		* Abstract
	EndFunc

	Function changeTypeOnAutoIncrement(tcType)
		* Abstract
	EndFunc

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
	EndFunc
Enddefine

* ==================================================== *
* MICROSOFT SQL SERVER
* ==================================================== *
Define Class MSSQL As DBEngine

	Procedure init
		DoDefault()
		this.nMaxLength = 128
		this.cLeft = '['
		this.cRight = ']'
		this.bUseSymbolDelimiter = .F.
        this.bExecuteFkScriptSeparately = .f.
        this.bExecuteIndexScriptSeparately = .f.
	endproc

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

	Function getConnectionString(tbAddDatabase)
		Local lcConStr, lcDriver

		lcConStr = "DRIVER=" + This.cDriver + ";SERVER=" + This.cServer + ";UID=" + This.cUser + ";PWD=" + This.cPassword
		If This.nPort > 0
			lcConStr = lcConStr + ";PORT=" + Alltrim(Str(This.nPort))
		Endif
		If tbAddDatabase
			lcConStr = lcConStr + ";DATABASE=" + Alltrim(This.cDatabase)
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
			Local lcMsg
			Text to lcMsg noshow pretext 7 textmerge
			    ERROR - Base de Datos No Especificada:

			    Antes de realizar esta petición, asegúrate de haber seleccionado una base de datos para trabajar.

			    Por favor, selecciona una base de datos válida y vuelve a intentar la operación.
			endtext
			Messagebox(lcMsg, 16, "Error: Base de Datos No Especificada")
			Return
		EndIf
		This.SQLExec("use " + This.cDatabase)
	Endproc

	Function getTidScript
		Return "INT IDENTITY(1,1) PRIMARY KEY"
	Endfunc

	Function getUUIDScript
		Return "UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID()"
	EndFunc
	
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
			        AND OBJECT_NAME(parent_object_id) = '<<this.cLeft + tcTable + this.cRight>>'
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
		Return "CREATE DATABASE " + this.cLeft + tcDatabase + this.cRight + ";"
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
		
		lcLeft = this.cLeft
		lcRight = this.cRight
				
		Text to lcScript noshow pretext 7 textmerge
		FOREIGN KEY (<<lcLeft+toFkData.cCurrentField+lcRight>>) REFERENCES <<lcLeft+toFkData.cTable+lcRight>>(<<lcLeft+toFkData.cField+lcRight>>)
		ON UPDATE <<lcOnUpdate>>
		ON DELETE <<lcOnDelete>>
		endtext
		Return lcScript
	EndFunc

	Function addSingleIndex(toIndex)
		Local lcScript, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		lcLeft = this.cLeft
		lcRight = this.cRight

		Text to lcScript noshow pretext 7 textmerge
			INDEX <<toIndex.cName>> <<Iif(toIndex.bUnique, "UNIQUE", "")>> (<<lcLeft+toIndex.cField+lcRight>> <<toIndex.cSort>>)
		EndText

		Return lcScript
	EndFunc

	Function addComposedIndex(toIndex)
		Local lcScript, lcLeft, lcRight, lcColumns, loResult
		Store "" to lcLeft, lcRight, lcColumns

		lcLeft = this.cLeft
		lcRight = this.cRight
		loResult = CreateObject("Collection")

		For each loComposed in toIndex			
			For each loColumn in loComposed.oColumns
				lcColumns = ''
				For each loField in loColumn
					If !Empty(lcColumns)
						lcColumns = lcColumns + ','
					EndIf
					lcColumns = lcColumns + ' ' + lcLeft + loField.cName + lcRight + ' ' + loField.cSort
				EndFor

				Text to lcScript noshow pretext 7 textmerge
					INDEX <<loComposed.cName>> <<Iif(loComposed.bUnique, "UNIQUE", "")>> (<<lcColumns>>)
				EndText
				loResult.Add(lcScript)
			EndFor
		EndFor
		Return loResult
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
		Return "DROP TABLE IF EXISTS " + this.cLeft + tcTable + this.cRight + ';'
	endfunc

	Function addFieldOptions(toField)
		Local lcScript
		lcScript = ''
		If toField.autoIncrement
			lcScript = lcScript + ' ' + this.addAutoIncrement()
		EndIf
		
		If !toField.allowNull
			If toField.addDefault
				lcScript = lcScript + " DEFAULT " + toField.Default
			EndIf
			lcScript = lcScript + " NOT NULL "				
		EndIf
		
		If toField.primaryKey
			lcScript = lcScript + ' ' + this.addPrimaryKey()
		EndIf

		Return lcScript
	EndFunc

	function changeDB(tcNewDatabase)
		If Empty(tcNewDatabase)
		    Local lcMsg
		    Text to lcMsg noshow pretext 7 textmerge
		        ERROR - Base de Datos No Especificada:

		        No has especificado el nombre de la base de datos que deseas utilizar. Por favor, asegúrate de proporcionar el nombre de la base de datos y vuelve a intentarlo.
		    endtext
		    MessageBox(lcMsg, 16)
		    Return .f.
		Endif
		This.cDatabase = tcNewDatabase
		This.selectDatabase()
		Return .t.
	EndFunc

	Function changeTypeOnAutoIncrement(tcType)
		Return tcType
	EndFunc

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
	EndFunc
Enddefine

* ==================================================== *
* MySQL
* ==================================================== *
Define Class MySQL As DBEngine

	Procedure init
		DoDefault()
		this.nMaxLength = 64
		this.cLeft = '`'
		this.cRight = '`'
		this.bUseSymbolDelimiter = .F.
	endproc

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

	Function getConnectionString(tbAddDatabase)
		Local lcConStr, lcDriver

		lcConStr = "DRIVER={" + This.cDriver + "};SERVER=" + This.cServer + ";USER=" + This.cUser + ";PASSWORD=" + This.cPassword
		If This.nPort > 0
			lcConStr = lcConStr + ";PORT=" + Alltrim(Str(This.nPort))
		Endif
		If tbAddDatabase
			lcConStr = lcConStr + ";DATABASE=" + Alltrim(This.cDatabase)
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

	Function getTidScript
		Return "INT AUTO_INCREMENT PRIMARY KEY"
	Endfunc

	Function getUUIDScript
		Return "VARCHAR(36) PRIMARY KEY NOT NULL"
	EndFunc

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
			WHERE TABLE_NAME = '<<this.cLeft+tcTable+this.cRight>>' AND TABLE_SCHEMA = '<<this.cLeft+this.cDatabase+this.cRight>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Procedure getPrimaryKeyScript(tcTable)
		Local lcScript
		TEXT to lcScript noshow pretext 7 textmerge
			SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			WHERE TABLE_SCHEMA = '<<this.cLeft+this.cDatabase+this.cRight>>'
			  AND TABLE_NAME = '<<this.cLeft+tcTable+this.cRight>>'
			  AND CONSTRAINT_NAME = 'PRIMARY';
		ENDTEXT

		Return lcScript
	Endproc

	Function createTableOptions
		Return " ENGINE = InnoDB AUTO_INCREMENT = 0 DEFAULT CHARSET = latin1"
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
		Return "CREATE DATABASE " + this.cLeft + tcDatabase + this.cRight + " DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
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
		lcOPen = this.cLeft
		lcClose = this.cRight
				
		Text to lcScript noshow pretext 7 textmerge
		FOREIGN KEY (<<lcOPen+toFkData.cCurrentField+lcClose>>) REFERENCES <<lcOPen+toFkData.cTable+lcClose>>(<<lcOPen+toFkData.cField+lcClose>>)
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
		Return "DROP TABLE IF EXISTS " + this.cLeft + tcTable + this.cRight + ';'
	endfunc

	Function addSingleIndex(toIndex)
		Local lcScript, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		lcLeft = this.cLeft
		lcRight = this.cRight
		Text to lcScript noshow pretext 7 textmerge
			<<Iif(toIndex.bUnique, "UNIQUE", "")>> INDEX <<toIndex.cName>> (<<lcLeft+toIndex.cField+lcRight>> <<toIndex.cSort>>)
		EndText

		Return lcScript
	EndFunc

	Function addComposedIndex(toIndex)
		Local lcScript, lcLeft, lcRight, lcColumns, loResult
		Store "" to lcLeft, lcRight, lcColumns

		lcLeft = this.cLeft
		lcRight = this.cRight
		loResult = CreateObject("Collection")

		For each loComposed in toIndex			
			For each loColumn in loComposed.oColumns
				lcColumns = ''
				For each loField in loColumn
					If !Empty(lcColumns)
						lcColumns = lcColumns + ','
					EndIf
					lcColumns = lcColumns + ' ' + lcLeft + loField.cName + lcRight + ' ' + loField.cSort
				EndFor

				Text to lcScript noshow pretext 7 textmerge
					<<Iif(loComposed.bUnique, "UNIQUE", "")>> INDEX <<loComposed.cName>> (<<lcColumns>>)
				EndText
				loResult.Add(lcScript)
			EndFor
		EndFor
		Return loResult
	EndFunc

	Function addFieldOptions(toField)
		Local lcScript
		lcScript = ''
		If toField.autoIncrement
			lcScript = lcScript + ' ' + this.addAutoIncrement()
		EndIf
		
		If !toField.allowNull
			If toField.addDefault
				lcScript = lcScript + " DEFAULT " + toField.Default
			EndIf
			lcScript = lcScript + " NOT NULL "				
		EndIf
		
		If toField.primaryKey
			lcScript = lcScript + ' ' + this.addPrimaryKey()
		EndIf									

		If !Empty(toField.comment)
			lcScript = lcScript + this.addFieldComment(toField.comment)
		EndIf

		Return lcScript
	EndFunc

	Function changeDB(tcNewDatabase)
		If Empty(tcNewDatabase)
		    Local lcMsg
		    Text to lcMsg noshow pretext 7 textmerge
		        ERROR - Base de Datos No Especificada:

		        No has especificado el nombre de la base de datos que deseas utilizar. Por favor, asegúrate de proporcionar el nombre de la base de datos y vuelve a intentarlo.
		    endtext
		    MessageBox(lcMsg, 16)
		    Return .f.
		Endif
		This.cDatabase = tcNewDatabase
		This.selectDatabase()
		Return .t.
	EndFunc
	
	Function changeTypeOnAutoIncrement(tcType)
		Return tcType
	EndFunc

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
	EndFunc
EndDefine

* ==================================================== *
* FireBird
* ==================================================== *
Define Class Firebird As DBEngine

	Procedure init
		DoDefault()	
		this.nMaxLength = 31
		this.cLeft = '"'
		this.cRight = '"'
		this.bUseSymbolDelimiter = .F.
		this.bExecuteFkScriptSeparately = .t.
		this.bExecuteIndexScriptSeparately = .t.
		this.bCanGenerateGUID = .f.
	EndProc

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

    Function getConnectionString(tbAddDatabase)
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

    Function getTableExistsScript(tcTableName)
        Local lcQuery, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		Else
			tcTableName = Upper(tcTableName)
		EndIf
		
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT RDB$RELATION_NAME AS TableName
            FROM RDB$RELATIONS
            WHERE RDB$RELATION_NAME = '<<lcLeft+tcTableName+lcRight>>'
        ENDTEXT

        Return lcQuery
    Endfunc

    Procedure selectDatabase
        * No aplica
    Endproc

    Function getTidScript
        Return "INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY"
    Endfunc

	Function getUUIDScript
		Return "VARCHAR(36) NOT NULL PRIMARY KEY"
	EndFunc

    Function getFieldExistsScript(tcTable, tcField)
        Local lcQuery, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		Else
			tcTable = Upper(tcTable)
			tcField = Upper(tcField)
		EndIf
		
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT RDB$FIELD_NAME AS FieldName
            FROM RDB$RELATION_FIELDS
            WHERE RDB$RELATION_NAME = '<<lcLeft+tcTable+lcRight>>' AND RDB$FIELD_NAME = '<<lcLeft+tcField+lcRight>>';
        ENDTEXT

        Return lcQuery
    Endfunc

    Function getServerDateScript
        Return "SELECT CURRENT_TIMESTAMP AS SERTIME FROM RDB$DATABASE"
    Endfunc

    Function getNewGuidScript
        * Firebird no tiene forma de generar un UUID().
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
		
		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		Else
			tcTable = Upper(tcTable)
		EndIf
		
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT RDB$FIELD_NAME AS FieldName
            FROM RDB$RELATION_FIELDS
            WHERE RDB$RELATION_NAME = '<<lcLeft+tcTable+lcRight>>'
        ENDTEXT

        Return lcQuery
    Endfunc

    Procedure getPrimaryKeyScript(tcTable)
		Local lcScript, lcOPen, lcClose
		Store "" to lcLeft, lcRight
		
		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		Else
			tcTable = Upper(tcTable)
		EndIf

        TEXT to lcScript noshow pretext 7 textmerge
            SELECT SEG.RDB$FIELD_NAME AS FieldName
            FROM RDB$RELATION_CONSTRAINTS CON
            JOIN RDB$INDEX_SEGMENTS SEG ON CON.RDB$INDEX_NAME = SEG.RDB$INDEX_NAME
            WHERE CON.RDB$RELATION_NAME = '<<lcLeft+tcTable+lcRight>>' AND CON.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
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
		loEnv.Add(Set("Mark"), 'mark')				

		Set Date To YMD
		Set Century On
		Set Mark To '-'

		Return loEnv
	EndFunc

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
		
		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		Else
			tcTable = Upper(tcTable)
		EndIf    
        Return "SELECT * FROM " + lcLeft + tcTable + lcRight
    Endfunc

    Function addAutoIncrement()
        Return "GENERATED BY DEFAULT AS IDENTITY"
    Endfunc

    Function addPrimaryKey()
        Return "PRIMARY KEY"
    Endfunc

	function dropTable(tcTable)		
		If !this.bUseSymbolDelimiter
			tcTable = Upper(tcTable)
		EndIf
		
		Text to lcScript noshow pretext 7 textmerge
			DROP TABLE <<this.cLeft+tcTable+this.cRight>>;
		endtext
		Return lcScript
	EndFunc

	Function getCreateDatabaseScript(tcDatabase)
		* Firebird
	EndFunc
	
	Function getDataBaseExistsScript(tcDatabase)
		Local lcScript, lcOPen, lcClose
		Store "" to lcLeft, lcRight
		
		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		Else
			tcDatabase = Upper(tcDatabase)
		EndIf
		Text to lcScript noshow pretext 7 textmerge
			SELECT 1 FROM rdb$database WHERE LOWER(rdb$database_name) = LOWER('<<lcLeft+tcDatabase+lcRight>>')
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
		lcOPen = this.cLeft
		lcClose = this.cRight
		
		If !this.bUseSymbolDelimiter
			toFkData.cCurrentField = Upper(toFkData.cCurrentField)
			toFkData.cField = Upper(toFkData.cField)
			toFkData.cTable = Upper(toFkData.cTable)
		EndIf
		        
        TEXT to lcScript noshow pretext 7 textmerge
        	ALTER TABLE <<lcOPen+toFkData.cCurrentTable+lcClose>> ADD CONSTRAINT <<lcOPen+toFkData.cName+lcClose>> 
            FOREIGN KEY (<<lcOPen+toFkData.cCurrentField+lcClose>>)
            REFERENCES <<lcOPen+toFkData.cTable+lcClose>>(<<lcOPen+toFkData.cField+lcClose>>)
            ON UPDATE <<lcOnUpdate>>
            ON DELETE <<lcOnDelete>>
        endtext

        Return lcScript
    Endfunc

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
    Endfunc

	Function addSingleIndex(toIndex)
		Local lcScript, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		EndIf
		Text to lcScript noshow pretext 7 textmerge
			CREATE <<Iif(toIndex.bUnique, "UNIQUE", "")>> <<toIndex.cSort>> INDEX <<toIndex.cName>> ON <<lcLeft+toIndex.cTable+lcRight>>(<<lcLeft+toIndex.cField+lcRight>>);
		EndText

		Return lcScript
	EndFunc

	Function addComposedIndex(toIndex)
		Local lcScript, lcLeft, lcRight, lcColumns, loResult
		Store "" to lcLeft, lcRight, lcColumns

		lcLeft = this.cLeft
		lcRight = this.cRight
		loResult = CreateObject("Collection")

		For each loComposed in toIndex			
			For each loColumn in loComposed.oColumns
				lcColumns = ''
				For each loField in loColumn
					If !Empty(lcColumns)
						lcColumns = lcColumns + ','
					EndIf
					lcColumns = lcColumns + ' ' + lcLeft + loField.cName + lcRight
				EndFor

				Text to lcScript noshow pretext 7 textmerge
					CREATE <<Iif(loComposed.bUnique, "UNIQUE", "")>> <<loComposed.cSort>> INDEX <<loComposed.cName>> ON <<lcLeft+loComposed.cTable+lcRight>>(<<lcColumns>>)
				EndText
				loResult.Add(lcScript)
			EndFor
		EndFor
		Return loResult
	EndFunc
	
	Function addFieldOptions(toField)
		Local lcScript
		lcScript = ''
		If toField.autoIncrement
			lcScript = lcScript + ' ' + this.addAutoIncrement()
		EndIf
		
		If !toField.allowNull
			If toField.addDefault
				lcScript = lcScript + " DEFAULT " + toField.Default
			EndIf
			lcScript = lcScript + " NOT NULL "				
		EndIf
		
		If toField.primaryKey
			lcScript = lcScript + ' ' + this.addPrimaryKey()
		EndIf

		Return lcScript
	EndFunc

	function changeDB(tcNewDatabase)
		If Empty(tcNewDatabase)
		    Local lcMsg
		    Text to lcMsg noshow pretext 7 textmerge
		        ERROR - Base de Datos No Especificada:

		        No has especificado el nombre de la base de datos que deseas utilizar. Por favor, asegúrate de proporcionar el nombre de la base de datos y vuelve a intentarlo.
		    endtext
		    MessageBox(lcMsg, 16)
		    Return .f.
		Endif

		If !File(tcNewDatabase)
		    Local lcMsg
		    Text to lcMsg noshow pretext 7 textmerge
		        ERROR - Base de Datos Inexistente:

		        La base de datos con el nombre '<<tcNewDatabase>>' no existe o no se puede encontrar en el sistema de archivos local. Por favor, verifica que el nombre de la base de datos sea correcto y que la base de datos haya sido creada previamente.
		    endtext
		    MessageBox(lcMsg, 16)
		    Return
		Endif

		This.cDatabase = tcNewDatabase
		this.disconnect()
		Return this.connect(.t.)
	EndFunc

	Function changeTypeOnAutoIncrement(tcType)
		Return tcType
	EndFunc

	* C = Character
    Function visitCType(toFields)
        Return "CHAR(" + toFields.Size + ")"
    Endfunc

    Function visitYType(toFields)
    	toFields.Default = "0.0"
        Return "DECIMAL(" + toFields.Size + "," + toFields.Decimal + ")"
    Endfunc

    Function visitDType(toFields)
	    toFields.Default = "'1858-11-18'"
        Return "DATE"
    Endfunc

    Function visitTType(toFields)
	    toFields.Default = "'1858-11-18 00:00:00'"
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
	    toFields.Default = "0"
        Return "INTEGER"
    Endfunc

    Function visitLType(toFields)
    	toFields.Default = "FALSE"
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
    EndFunc	    
EndDefine

* ==================================================== *
* SQLite
* ==================================================== *
Define Class SQLite As DBEngine

	Procedure init
		DoDefault()
		this.nMaxLength = 128
		this.cLeft = '"'
		this.cRight = '"'
		this.bUseSymbolDelimiter = .F.
		this.bExecuteIndexScriptSeparately = .t.
	EndProc

	Function getDummyQuery
		Return "SELECT 1"
	Endfunc

	Function getVersion
		Local lcCursor, lcVersion
		lcCursor = Sys(2015)
		This.SQLExec("SELECT sqlite_version() AS 'VER'", lcCursor)
		lcVersion = &lcCursor..VER
		Use In (lcCursor)

		Return lcVersion
	Endfunc

	Function getConnectionString(tbAddDatabase)
		Local lcConStr

		Text to lcConStr noshow pretext 15 textmerge
			DRIVER=<<this.cDriver>>;
			DATABASE=<<This.cDatabase>>;
			UID=<<Iif(Empty(this.cUser),'', this.cUser)>>;
			PWD=<<Iif(Empty(this.cPassword),'', this.cPassword)>>;
			LongNames=0;
			TimeOut=1000;
			NoTXN=0;
			SyncPragma=NORMAL;
			StepAPI=0
		endtext

		Return lcConStr
	Endfunc

	Procedure beginTransaction
		This.SQLExec("BEGIN TRANSACTION;")
	Endproc

	Procedure endTransaction
		This.SQLExec("COMMIT;")
	Endproc

	Procedure cancelTransaction
		This.SQLExec("ROLLBACK;")
	Endproc

	Function getTableExistsScript(tcTableName)
		Local lcQuery, lcLeft, lcRight
		Store "" to lcLeft, lcRight

		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		EndIf

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT name AS TableName
			FROM sqlite_master
			WHERE type='table' AND name = '<<lcLeft+tcTableName+lcRight>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Procedure selectDatabase
		* No aplica para SQLite
	Endproc

	Function getTidScript
		Return "PRIMARY KEY AUTOINCREMENT"
	Endfunc

	Function getUUIDScript
		Return "VARCHAR(36) PRIMARY KEY NOT NULL"
	EndFunc

	Function getFieldExistsScript(tcTable, tcField)
		Local lcQuery, lcLeft, lcRight
		Store "" to lcLeft, lcRight

		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		EndIf

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT name AS FieldName
			FROM pragma_table_info('<<lcLeft+tcTable+lcRight>>')
			WHERE name = '<<lcLeft+tcField+lcRight>>';
		ENDTEXT

		Return lcQuery
	Endfunc

	Function getServerDateScript
		Return "SELECT CURRENT_TIMESTAMP AS SERTIME;"
	Endfunc

	Function getNewGuidScript
		Return "SELECT LOWER(HEX(RANDOMBLOB(16))) AS GUID;"
	Endfunc

	Function getTablesScript
		Local lcQuery

		TEXT TO lcQuery NOSHOW PRETEXT 7 TEXTMERGE
			SELECT name AS TableName
			FROM sqlite_master
			WHERE type='table';
		ENDTEXT

		Return lcQuery
	Endfunc

	Function getTableFieldsScript(tcTable)
		Local lcQuery, lcLeft, lcRight
		Store "" to lcLeft, lcRight

		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		EndIf

		TEXT to lcQuery noshow pretext 7 textmerge
			SELECT name AS FieldName
			FROM pragma_table_info('<<lcLeft+tcTable+lcRight>>');
		ENDTEXT

		Return lcQuery
	Endfunc

	Procedure getPrimaryKeyScript(tcTable)
		Local lcScript, lcLeft, lcRight
		Store "" to lcLeft, lcRight

		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		EndIf

		TEXT to lcScript noshow pretext 7 textmerge
			SELECT sql
			FROM sqlite_master
			WHERE type='table' AND name='<<lcLeft+tcTable+lcRight>>';
		ENDTEXT

		* Extracting the primary key from the table creation script
		Local lnStart, lnEnd
		lnStart = AT('CONSTRAINT', lcScript) + 11
		lnEnd = AT('PRIMARY KEY', lcScript) - 3
		lcScript = SUBSTR(lcScript, lnStart, lnEnd - lnStart)

		Return lcScript
	Endproc

	Function createTableOptions
		Return ""
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

	Procedure restoreEnvironment(toEnv)
		* No aplica para SQLite
	Endproc

	Function formatDateOrDateTime(tdValue)
		If Empty(tdValue)
			If Type('tdValue') == 'D'
				Return CTOD('0001-01-01')
			Endif
			Return CTOT('0001-01-01 00:00:00')
		Endif
		Return tdValue
	Endfunc

	Function getOpenTableScript(tcTable)
		Return "SELECT * FROM " + tcTable
	Endfunc

	Function addAutoIncrement
		Return "AUTOINCREMENT"
	Endfunc

	Function addPrimaryKey
		Return "PRIMARY KEY"
	Endfunc

	Function dropTable(tcTable)
		Return "DROP TABLE IF EXISTS " + this.cLeft + tcTable + this.cRight + ';'
	Endfunc

	Function getCreateDatabaseScript(tcDatabase)
		Return ""
	Endfunc

	Function getDataBaseExistsScript(tcDatabase)
		Return ""
	Endfunc

	Function addFieldComment(tcComment)
		Return ""
	Endfunc

	Function addTableComment(tcComment)
		Return ""
	Endfunc

    Function addForeignKey(toFkData)
        Local lcScript, lcOnUpdate, lcOnDelete, lcOPen, lcClose
        lcOnUpdate = This.getForeignKeyValue(toFkData.cOnUpdate)
        lcOnDelete = This.getForeignKeyValue(toFkData.cOnDelete)
		Store "" to lcOPen, lcClose
		
		lcOPen  = this.cLeft
		lcClose = this.cRight
		        
        TEXT to lcScript noshow pretext 7 textmerge        	
            FOREIGN KEY (<<lcOPen+toFkData.cCurrentField+lcClose>>)
            REFERENCES <<lcOPen+toFkData.cTable+lcClose>>(<<lcOPen+toFkData.cField+lcClose>>)
            ON UPDATE <<lcOnUpdate>>
            ON DELETE <<lcOnDelete>>
        endtext

        Return lcScript
    Endfunc

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
    Endfunc

	Function addSingleIndex(toIndex)
		Local lcScript, lcLeft, lcRight
		Store "" to lcLeft, lcRight
		
		If this.bUseSymbolDelimiter
			lcLeft = this.cLeft
			lcRight = this.cRight
		EndIf
		Text to lcScript noshow pretext 7 textmerge
			CREATE <<Iif(toIndex.bUnique, "UNIQUE", "")>> INDEX <<toIndex.cName>> ON <<lcLeft+toIndex.cTable+lcRight>>(<<lcLeft+toIndex.cField+lcRight>>);
		EndText

		Return lcScript
	EndFunc

	Function addComposedIndex(toIndex)
		Local lcScript, lcLeft, lcRight, lcColumns, loResult
		Store "" to lcLeft, lcRight, lcColumns

		lcLeft = this.cLeft
		lcRight = this.cRight
		loResult = CreateObject("Collection")

		For each loComposed in toIndex			
			For each loColumn in loComposed.oColumns
				lcColumns = ''
				For each loField in loColumn
					If !Empty(lcColumns)
						lcColumns = lcColumns + ','
					EndIf
					lcColumns = lcColumns + ' ' + lcLeft + loField.cName + lcRight
				EndFor

				Text to lcScript noshow pretext 7 textmerge
					CREATE <<Iif(loComposed.bUnique, "UNIQUE", "")>> INDEX <<loComposed.cName>> ON <<lcLeft+loComposed.cTable+lcRight>>(<<lcColumns>>)
				EndText
				loResult.Add(lcScript)
			EndFor
		EndFor
		Return loResult
	EndFunc

	Function addFieldOptions(toField)
		Local lcScript
		lcScript = ''
		
		If toField.primaryKey
			lcScript = lcScript + ' ' + this.addPrimaryKey()
		EndIf									

		If toField.autoIncrement
			lcScript = lcScript + ' ' + this.addAutoIncrement()
		EndIf

		If !toField.allowNull
			If toField.addDefault
				lcScript = lcScript + " DEFAULT " + toField.Default
			EndIf
			lcScript = lcScript + " NOT NULL "				
		EndIf

		Return lcScript
	EndFunc

	function changeDB(tcNewDatabase)
		If Empty(tcNewDatabase)
		    Local lcMsg
		    Text to lcMsg noshow pretext 7 textmerge
		        ERROR - Base de Datos No Especificada:

		        No has especificado el nombre de la base de datos que deseas utilizar. Por favor, asegúrate de proporcionar el nombre de la base de datos y vuelve a intentarlo.
		    endtext
		    MessageBox(lcMsg, 16)
		    Return .f.
		Endif

		If !File(tcNewDatabase)
		    Local lcMsg
		    Text to lcMsg noshow pretext 7 textmerge
		        ERROR - Base de Datos Inexistente:

		        La base de datos con el nombre '<<tcNewDatabase>>' no existe o no se puede encontrar en el sistema de archivos local. Por favor, verifica que el nombre de la base de datos sea correcto y que la base de datos haya sido creada previamente.
		    endtext
		    MessageBox(lcMsg, 16)
		    Return
		Endif

		This.cDatabase = tcNewDatabase
		this.disconnect()
		Return this.connect(.t.)
	EndFunc

	Function changeTypeOnAutoIncrement(tcType)
		Return tcType
	EndFunc

	* C = Character
	Function visitCType(toFields)
		If Val(toFields.Size) > 0
			Return "TEXT(" + toFields.Size + ")"
		EndIf
		Return "TEXT"
	Endfunc

	* Y = Currency
	Function visitYType(toFields)
		If Val(toFields.Decimal) > 0
			toFields.Default = "0.0"
		Else
			toFields.Default = '0'
		Endif
		Return "NUMERIC(" + toFields.Size + "," + toFields.Decimal + ")"
	Endfunc

	* D = Date
	Function visitDType(toFields)
		toFields.Default = "'0001-01-01'"
		Return "DATE"
	Endfunc

	* T = DateTime
	Function visitTType(toFields)
		toFields.Default = "'0001-01-01 00:00:00.000'"
		Return "DATETIME"
	Endfunc

	* B = Double
	Function visitBType(toFields)
		toFields.Default = "0.0"
		Return "DOUBLE"
	Endfunc

	* F = Float
	Function visitFType(toFields)
		toFields.Default = "0.0"
		Return "REAL"
	Endfunc

	* G = General
	Function visitGType(toFields)
		Return "BLOB"
	Endfunc

	* I = Integer
	Function visitIType(toFields)
		Return "INTEGER"
	Endfunc

	* L = Logical
	Function visitLType(toFields)
		Return "BOOLEAN"
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

	* Q = Varbinary
	Function visitQType(toFields)
		Return "BLOB"
	Endfunc

	* V = Varchar and Varchar (Binary)
	Function visitVType(toFields)
		If Val(toFields.Size) > 0
			Return "TEXT(" + toFields.Size + ")"
		EndIf
		Return "TEXT"
	Endfunc

	* W = Blob
	Function visitWType(toFields)
		Return "BLOB"
	EndFunc
EndDefine

* ==================================================== *
* PostgreSQL
* ==================================================== *
Define Class PostgreSQL As DBEngine

    Procedure init
        DoDefault()    
        this.nMaxLength = 63
        this.cLeft = '"'
        this.cRight = '"'
        this.bUseSymbolDelimiter = .f.
        this.bExecuteFkScriptSeparately = .t.
        this.bExecuteIndexScriptSeparately = .T.
    EndProc

    Function getDummyQuery
        Return "SELECT 1"
    Endfunc

    Function getVersion
        Local lcCursor, lcVersion
        lcCursor = Sys(2015)
        This.SQLExec("SELECT version()", lcCursor)
        lcVersion = &lcCursor..version
        Use In (lcCursor)

        Return lcVersion
    Endfunc

    Function getConnectionString(tbAddDatabase)
		Local lcConStr
		Text to lcConStr noshow pretext 15 textmerge
			DRIVER={<<this.cDriver>>};
			SERVER=<<this.cServer>>;
			PORT=<<Iif(Empty(this.nPort), "5432", this.nPort)>>;
			UID=<<Iif(Empty(this.cUser),'', this.cUser)>>;
			PWD=<<Iif(Empty(this.cPassword),'', this.cPassword)>>;
		endtext
		If tbAddDatabase
			lcConStr = lcConStr + "DATABASE=" + Alltrim(This.cDatabase)
		Endif
		Return lcConStr
    Endfunc

    Procedure beginTransaction
        This.selectDatabase()
        This.SQLExec("BEGIN;")
    Endproc

    Procedure endTransaction
        This.selectDatabase()
        This.SQLExec("COMMIT;")
    Endproc

    Procedure cancelTransaction
        This.selectDatabase()
        This.SQLExec("ROLLBACK;")
    Endproc

    Function getTableExistsScript(tcTableName)
        Local lcQuery, lcLeft, lcRight
        Store "" to lcLeft, lcRight
        
        If this.bUseSymbolDelimiter
            lcLeft = this.cLeft
            lcRight = this.cRight
        EndIf
        
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT table_name as TableName
            FROM information_schema.tables
            WHERE table_name = '<<lcLeft+tcTableName+lcRight>>' AND table_schema = 'public'
        ENDTEXT

        Return lcQuery
    Endfunc

	function dropTable(tcTable)			
		Return "DROP TABLE IF EXISTS " + this.cLeft + tcTable + this.cRight + ';'
	endfunc

    Procedure selectDatabase
        Return ""
    Endproc

    Function getTidScript
        Return "SERIAL PRIMARY KEY"
    Endfunc

	Function getUUIDScript
		Return "UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL"
	EndFunc

    Function getFieldExistsScript(tcTable, tcField)
        Local lcQuery, lcLeft, lcRight
        Store "" to lcLeft, lcRight
        
        If this.bUseSymbolDelimiter
            lcLeft = this.cLeft
            lcRight = this.cRight
        Else
            tcTable = Upper(tcTable)
            tcField = Upper(tcField)
        EndIf
        
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = '<<lcLeft+tcTable+lcRight>>' AND column_name = '<<lcLeft+tcField+lcRight>>'
        ENDTEXT

        Return lcQuery
    Endfunc

    Function getServerDateScript
        Return "SELECT CURRENT_TIMESTAMP AS SERTIME"
    Endfunc

    Function getNewGuidScript
    	If this.sqlExec('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
	        Return "SELECT uuid_generate_v4() AS GUID"
	    EndIf
	    messagebox("No se pudo generar el GUID. Hubo un problema con la extensión 'uuid-ossp'. Por favor, asegúrate de que la extensión está instalada y habilitada en tu servidor de base de datos. Si necesitas ayuda, consulta la documentación o contacta al administrador de la base de datos.", 48)
    Endfunc

    Function getTablesScript
        Local lcQuery

        TEXT TO lcQuery NOSHOW PRETEXT 7 TEXTMERGE
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
        ENDTEXT

        Return lcQuery
    Endfunc

    Function getTableFieldsScript(tcTable)
        Local lcQuery, lcLeft, lcRight
        Store "" to lcLeft, lcRight
        
        If this.bUseSymbolDelimiter
            lcLeft = this.cLeft
            lcRight = this.cRight
        Else
            tcTable = Upper(tcTable)
        EndIf
        
        TEXT to lcQuery noshow pretext 7 textmerge
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = '<<lcLeft+tcTable+lcRight>>'
        ENDTEXT

        Return lcQuery
    Endfunc

    Procedure getPrimaryKeyScript(tcTable)
        Local lcScript, lcLeft, lcRight
        Store "" to lcLeft, lcRight
        
        If this.bUseSymbolDelimiter
            lcLeft = this.cLeft
            lcRight = this.cRight
        Else
            tcTable = Upper(tcTable)
        EndIf

        TEXT to lcScript noshow pretext 7 textmerge
            SELECT a.attname as FieldName
            FROM pg_index i
            JOIN pg_attribute a ON a.attrelid = i.indrelid
                AND a.attnum = ANY(i.indkey)
            WHERE i.indrelid = '<<lcLeft+tcTable+lcRight>>'::regclass
                AND i.indisprimary;
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
		loEnv.Add(Set("Mark"), 'mark')				
		
		Set Date To YMD
		Set Century On
		Set Mark To '-'

    	If !this.sqlExec('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
	        messagebox("Hubo un problema con la extensión 'uuid-ossp'. Por favor, asegúrate de que la extensión está instalada y habilitada en tu servidor de base de datos. Si necesitas ayuda, consulta la documentación o contacta al administrador de la base de datos.", 48)
	    EndIf	    

		Return loEnv
	EndFunc

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
        
        If this.bUseSymbolDelimiter
            lcLeft = this.cLeft
            lcRight = this.cRight
        Else
            tcTable = Upper(tcTable)
        EndIf    
        Return "SELECT * FROM " + lcLeft + tcTable + lcRight
    Endfunc

	Function getDataBaseExistsScript(tcDatabase)
		Local lcScript
		Text to lcScript noshow pretext 7 textmerge
			SELECT datname as dbName FROM pg_database WHERE datname = '<<tcDatabase>>';
		EndText
		Return lcScript
	Endfunc

    Function addAutoIncrement()
        Return ""
    Endfunc

    Function addPrimaryKey()
        Return "PRIMARY KEY"
    Endfunc

	Function addFieldComment(tcComment)
		Return ""
	Endfunc

	Function addTableComment(tcComment)
		Return ""
	Endfunc

    Function addForeignKey(toFkData)
        Local lcScript, lcOnUpdate, lcOnDelete, lcLeft, lcRight, lcFkName
        lcOnUpdate = This.getForeignKeyValue(toFkData.cOnUpdate)
        lcOnDelete = This.getForeignKeyValue(toFkData.cOnDelete)
        Store "" to lcLeft, lcRight        
        TEXT to lcScript noshow pretext 7 textmerge
            ALTER TABLE <<lcLeft+toFkData.cCurrentTable+lcRight>> ADD CONSTRAINT <<lcLeft+toFkData.cName+lcRight>>
            FOREIGN KEY (<<lcLeft+toFkData.cCurrentField+lcRight>>)
            REFERENCES <<lcLeft+toFkData.cTable+lcRight>>(<<lcLeft+toFkData.cField+lcRight>>)
            ON UPDATE <<lcOnUpdate>>
            ON DELETE <<lcOnDelete>>
        endtext

        Return lcScript
    Endfunc

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
    Endfunc

	Function getCreateDatabaseScript(tcDatabase)		
		Return "CREATE DATABASE " + this.cLeft + tcDatabase + this.cRight + ";"
	EndFunc

    Function addSingleIndex(toIndex)
        Local lcScript, lcLeft, lcRight
        Store "" to lcLeft, lcRight
        
        If this.bUseSymbolDelimiter
            lcLeft = this.cLeft
            lcRight = this.cRight
        EndIf
        Text to lcScript noshow pretext 7 textmerge
            CREATE <<Iif(toIndex.bUnique, "UNIQUE", "")>> INDEX <<toIndex.cName>> ON <<lcLeft+toIndex.cTable+lcRight>>(<<lcLeft+toIndex.cField+lcRight>> <<toIndex.cSort>>)
        EndText

        Return lcScript
    Endfunc

    Function addComposedIndex(toIndex)
        Local lcScript, lcLeft, lcRight, lcColumns, loResult
        Store "" to lcLeft, lcRight, lcColumns

        lcLeft = this.cLeft
        lcRight = this.cRight
        loResult = CreateObject("Collection")

        For each loComposed in toIndex            
            For each loColumn in loComposed.oColumns
                lcColumns = ''
                For each loField in loColumn
                    If !Empty(lcColumns)
                        lcColumns = lcColumns + ','
                    EndIf
                    lcColumns = lcColumns + ' ' + lcLeft + loField.cName + lcRight + ' ' + loField.cSort
                EndFor

                Text to lcScript noshow pretext 7 textmerge
                    CREATE <<Iif(loComposed.bUnique, "UNIQUE", "")>> INDEX <<loComposed.cName>> ON <<lcLeft+loComposed.cTable+lcRight>>(<<lcColumns>>)
                EndText
                loResult.Add(lcScript)
            EndFor
        EndFor
        Return loResult
    Endfunc

    Function addFieldOptions(toField)
        Local lcScript
        lcScript = ''
        If toField.autoIncrement
            lcScript = lcScript + ' ' + this.addAutoIncrement()
        EndIf
        
        If !toField.allowNull
            If toField.addDefault
                lcScript = lcScript + " DEFAULT " + toField.Default
            EndIf
            lcScript = lcScript + " NOT NULL "                
        EndIf
        
        If toField.primaryKey
            lcScript = lcScript + ' ' + this.addPrimaryKey()
        EndIf

        Return lcScript
    Endfunc

	function changeDB(tcNewDatabase)
		If Empty(tcNewDatabase)
		    Local lcMsg
		    Text to lcMsg noshow pretext 7 textmerge
		        ERROR - Base de Datos No Especificada:

		        No has especificado el nombre de la base de datos que deseas utilizar. Por favor, asegúrate de proporcionar el nombre de la base de datos y vuelve a intentarlo.
		    endtext
		    MessageBox(lcMsg, 16)
		    Return .f.
		Endif

		This.cDatabase = tcNewDatabase
		this.disconnect()
		Return this.connect(.t.)
	EndFunc

	Function changeTypeOnAutoIncrement(tcType)
		Return "SERIAL"
	EndFunc

    * C = Character
    Function visitCType(toFields)
    	If Val(toFields.Size) > 0
    		Return "VARCHAR(" + toFields.Size + ")"
    	EndIf
    	Return "VARCHAR"
    Endfunc

    Function visitYType(toFields)
	    toFields.Default = "0.0"
        Return "NUMERIC(" + toFields.Size + "," + toFields.Decimal + ")"
    Endfunc

    Function visitDType(toFields)
        toFields.Default = "'1858-11-18'"
        Return "DATE"
    Endfunc

    Function visitTType(toFields)
        toFields.Default = "'1858-11-18 00:00:00'"
        Return "TIMESTAMP"
    Endfunc

    Function visitBType(toFields)
        toFields.Default = "0.0"
        Return "NUMERIC(" + toFields.Size + "," + toFields.Decimal + ")"
    Endfunc

    Function visitFType(toFields)
        toFields.Default = "0.0"
        Return "NUMERIC(" + toFields.Size + "," + toFields.Decimal + ")"
    Endfunc

    Function visitGType(toFields)
        Return "BYTEA"
    Endfunc

    Function visitIType(toFields)
        toFields.Default = "0"
        Return "INTEGER"
    Endfunc

    Function visitLType(toFields)
        toFields.Default = "FALSE"
        Return "BOOLEAN"
    Endfunc

    Function visitMType(toFields)
        Return "TEXT"
    Endfunc

    Function visitNType(toFields)
	    toFields.Default = "0"
        If Val(toFields.Decimal) > 0
        	toFields.Default = "0.0"
            Return "NUMERIC(" + toFields.Size + "," + toFields.Decimal + ")"
        Else
            Return "INTEGER"
        Endif
    Endfunc

    Function visitQType(toFields)
        Return "BYTEA"
    Endfunc

    Function visitVType(toFields)
    	If Val(toFields.Size) > 0    	
	        Return "VARCHAR(" + toFields.Size + ")"
       	EndIf
       	Return "VARCHAR"
    Endfunc

    Function visitWType(toFields)
        Return "BYTEA"
    EndFunc
EndDefine
