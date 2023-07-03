* ======================================================================== *
* Class DBEngine
* ======================================================================== *
Define Class DBEngine As Custom

	cDriver = ""
	cServer = ""
	cUser = ""
	cPassword = ""
	cDatabase = ""
	nPort = 0
	cVersion = "0.0.1"
	bUseCA = .T.

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
							If Upper(laInsFields[j]) == "TID"
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

		lcScript = 'set datasession to ' + Alltrim(Str(Set("Datasession"))) + Chr(13) + Chr(10)
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
			lcScript = lcScript + "select " + loView.Alias + Chr(13) + Chr(10)
			lcScript = lcScript + "=TableRevert(.T.) " + Chr(13) + Chr(10)
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
			lcMarkAct, lcCenturyAct, loEnv, lcScript, lbMigrateDBC


		lcPathAct = Set("Default")

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
			If !InList(Upper(JustExt(tcTableOrPath)), "DBC", "DBF")
				MessageBox("Solo se permiten migraciones de ficheros DBF o DBC", 16)
				Return .f.
			EndIf
			
			If Upper(JustExt(tcTableOrPath)) == "DBC"
				Open Database (tcTableOrPath) Shared
				=ADBObjects(laTables, "TABLE")
				lbMigrateDBC = .T.
			Else
				laTables[1]  = tcTableOrPath
			EndIf
		Endif

		lcOpenChar = This.getOpenNameSymbol()
		lcCloseChar = This.getCloseNameSymbol()
		
		loEnv = this.setEnvironment()

		For i = 1 To Alen(laTables,1)
			lcTablePath = laTables[i]
			lcTableName = Juststem(lcTablePath)
			If !Used(lcTableName)
				lbCloseTable = .T.
				Use (lcTablePath) In 0
			Endif
			Try
				=Afields(laFields, lcTableName)
				laDateFields = this.getDateTimeFields(@laFields)
				If This.tableExists(lcTableName)
					lcScript = "DROP TABLE " + lcOpenChar + lcTableName + lcCloseChar
					This.SQLExec(lcScript)
				Endif
				This.createTable(lcTableName, @laFields)

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
				Endscan
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
		Local lnResult
		lnResult = 0
		Try
			lnResult = SQLExec(This.nHandle, tcSQLCommand, tcCursorName)
		Catch To loEx
			This.printException(loEx)
		Endtry

		If lnResult <= 0
			=Aerror(laSqlError)
			Messagebox("SQL ERROR: " + laSqlError[2] + Chr(13) + Chr(10) + "QUERY: " + tcSQLCommand, 16, "Error de comunicación")
		Endif
		Return lnResult > 0
	Endfunc

	Procedure createTable(tcTableName, taFields)
		Local i, lcScript, lcType, lcName, lcSize, lcDecimal, lbAllowNull, lcLongName, ;
			lcComment, lnNextValue, lnStepValue, lcDefault, lcOpenChar, lcCloseChar, loFields

		lcOpenChar = This.getOpenNameSymbol()
		lcCloseChar = This.getCloseNameSymbol()

		lcScript  = "CREATE TABLE " + lcOpenChar + tcTableName + lcCloseChar
		lcScript  = lcScript + " ("
		lcScript  = lcScript + lcOpenChar + "TID" + lcCloseChar + Space(1) + This.getGUIDDescription()
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
		=AddProperty(loFields, "addDefault", .T.)

		For i = 1 To Alen(taFields, 1)
			loFields.Name = taFields[i, 1]
			loFields.Type = taFields[i, 2]
			loFields.Size = Alltrim(Str(taFields[i, 3]))
			loFields.Decimal = Alltrim(Str(taFields[i, 4]))
			loFields.allowNull = taFields[i, 5]
			loFields.longName = taFields[i, 12]
			loFields.Comment = taFields[i, 16]
			loFields.Nextvalue = taFields[i, 17]
			loFields.stepValue = taFields[i, 18]
			loFields.addDefault = .T.
			loFields.Default = "''"

			lcScript = lcScript + ", "

			lcScript = lcScript + lcOpenChar + loFields.Name + lcCloseChar + Space(1)
			lcMacro = "this.visit" + loFields.Type + "Type(loFields)"
			lcValue = &lcMacro
			lcScript = lcScript + lcValue

			If !loFields.allowNull
				lcScript = lcScript + " NOT NULL "
				If loFields.addDefault
					lcScript = lcScript + " DEFAULT " + loFields.Default
				Endif
			Endif
		Endfor
		lcScript = lcScript + ") " + This.createTableOptions()
		Return This.SQLExec(lcScript)
	Endproc

	Procedure sqlError
		Local Array laError[2]
		Aerror(laError)
		Messagebox("ERROR: " + Alltrim(Str(laError[1])) + Chr(13) + Chr(10) + "MESSAGE:" + Transform(laError[2]), 16, "ERROR")
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
		If !this.fieldExists(tcTable, "TID")
			Return this.getPrimaryKey(tcTable)
		EndIf
		Return "TID"
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
		lcMsg = lcMsg + Chr(13) + Padr("LineNo:", 20, Space(1)) + Alltrim(Str(toError.Lineno))
		lcMsg = lcMsg + Chr(13) + Padr("Message:", 20, Space(1)) + Alltrim(toError.Message)
		lcMsg = lcMsg + Chr(13) + Padr("Procedure:", 20, Space(1)) + Alltrim(toError.Procedure)
		lcMsg = lcMsg + Chr(13) + Padr("Details:", 20, Space(1)) + Alltrim(toError.Details)
		lcMsg = lcMsg + Chr(13) + Padr("StackLevel:", 20, Space(1)) + Alltrim(Str(toError.StackLevel))
		lcMsg = lcMsg + Chr(13) + Padr("LineContents:", 20, Space(1)) + Alltrim(toError.LineContents)
		lcMsg = lcMsg + Chr(13) + Padr("UserValue:", 20, Space(1)) + Alltrim(toError.UserValue)

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
		Return "["
	Endfunc

	Function getCloseNameSymbol
		Return "]"
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
		Return "CREATE DATABASE [" + tcDatabase + "];"
	EndFunc
	
	Function getDataBaseExistsScript(tcDatabase)
		Return "select NAME AS dbName from sys.databases where name = '" + tcDatabase + "'"
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
		Return "VARCHAR(" + toFields.Size + ") COLLATE Latin1_General_CI_AI"
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
		Return '`'
	Endfunc

	Function getCloseNameSymbol
		Return '`'
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
		Return "int(20) unsigned zerofill primary key NOT NULL auto_increment"
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
		Return "ENGINE = MyISAM AUTO_INCREMENT = 0 DEFAULT CHARSET = latin1"
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
		Return "CREATE DATABASE `" + tcDatabase + "` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
	EndFunc
	
	Function getDataBaseExistsScript(tcDatabase)
		Return "SELECT CATALOG_NAME AS dbName FROM information_schema.schemata WHERE schema_name = '" + tcDatabase + "'"
	EndFunc

	* C = Character
	Function visitCType(toFields)
		* Return "VARCHAR(" + toFields.Size + ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
		Return "VARCHAR(" + toFields.Size + ")"
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
Enddefine
