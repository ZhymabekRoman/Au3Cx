#include-once
; #FUNCTION# ====================================================================================================================================
; Name...........: _ParsePath
; Description ...: Разбор пути файла
; Syntax.........: _ParsePath($sFile, $sStr [, $iFlag = 2])
; Parameters ....: $sFile - путь к файлу
;                  $sStr - шаблон, %d - диск, %p - путь, %n - имя, %x - расширение включая точку, %y - расширение без точки, %- удаляет последний символ, например "\" из пути.
;                  $iFlag - 1 - преобразует путь в полный, 2 - разворачивает переменные %var% , 4 - разворачивает переменные $var , 8 - искать в %Path%
; Author ........: Nikzzzz
; Examples ......: ConsoleWrite(_ParsePath("%SystemRoot%\system32\notepad.exe", "** %d%p%n%x  **" & @crlf,7))
; ===============================================================================================================================================
Func _ParsePath($sFile, $sStr, $iFlag = 2, $sCD = EnvGet('__CD__'))
	Local $i, $sRet = '', $sDrive = '', $sPath = '', $sName = '', $vTemp
	If $sFile = '' Then Return ''
	$sCD = _StringStripRight($sCD, '\')
	If BitAND($iFlag, 2) Then
		$vTemp = Opt('ExpandEnvStrings', 1)
		$sFile = $sFile
		Opt('ExpandEnvStrings', $vTemp)
	EndIf
	If BitAND($iFlag, 4) Then
		$vTemp = Opt('ExpandVarStrings', 1)
		$sFile = $sFile
		Opt('ExpandVarStrings', $vTemp)
	EndIf
	If $sFile = 'con:' Or $sFile = 'con' Then Return $sFile
	If StringInStr($sFile, '\') = 0 Then
		While 1
			If FileExists($sCD & '\' & $sFile) Then
				$sFile = $sCD & '\' & $sFile
				ExitLoop
			EndIf
			If BitAND($iFlag, 8) Then
				$vTemp = StringSplit(EnvGet('path'), ';', 2)
				For $i = 0 To UBound($vTemp) - 1
					If FileExists(_StringStripRight($vTemp[$i], '\') & '\' & $sFile) Then
						$sFile = _StringStripRight($vTemp[$i], '\') & '\' & $sFile
						ExitLoop 2
					EndIf
				Next
			EndIf
			ExitLoop
		WEnd
	EndIf
	If BitAND($iFlag, 1) Then
		$vTemp = DllCall('kernel32.dll', 'dword', 'GetFullPathNameW', 'wstr', $sFile, 'dword', 4096, 'wstr', '', 'ptr', 0)
		If Not (@error Or Not $vTemp[0]) Then $sFile = $vTemp[3]
	EndIf
	$sFile = _PathB($sFile)
	If StringInStr($sFile, ':') Then
		$sDrive = _StringLeftStr($sFile, ':') & ':\'
		$sFile = _StringRightStr($sFile, ':')
	EndIf
	Local $sExt = '.' & _StringRightStr($sFile, '.', -1)
	If $sExt = '.' Then $sExt = ''
	If StringInStr($sExt, '\') Then $sExt = ""
	$sFile = StringTrimRight($sFile, StringLen($sExt))
	$sFile = _StringStripLeft($sFile, '\')
	If StringInStr($sFile, '\') Then
		$sPath = _StringLeftStr($sFile, '\', -1) & '\'
		$sName = _StringRightStr($sFile, '\', -1)
	Else
		$sName = $sFile
	EndIf
	While StringLen($sStr)
		If StringLeft($sStr, 1) = '%' Then
			$sStr = StringTrimLeft($sStr, 1)
			Switch StringLeft($sStr, 1)
				Case 'd'
					$sRet &= $sDrive
				Case 'p'
					$sRet &= $sPath
				Case 'n'
					$sRet &= $sName
				Case 'x'
					$sRet &= $sExt
				Case 't'
					$sRet = _StringStripRight($sRet, '\')
				Case 'y'
					$sRet &= StringTrimLeft($sExt, 1)
				Case '-'
					$sRet = StringTrimRight($sRet, 1)
				Case Else
					$sRet &= StringLeft($sStr, 1)
			EndSwitch
		Else
			$sRet &= StringLeft($sStr, 1)
		EndIf
		$sStr = StringTrimLeft($sStr, 1)
	WEnd
	Return SetError(0, 0, $sRet)
EndFunc   ;==>_ParsePath
; #FUNCTION# ====================================================================================================================================
; Name...........: _StringLeftStr
; Description ...: Возвращает левую часть строки $Str относительно $sStr, $iFlag - номер вхождения подстроки $sStr, если он отрицательный, ищется с конца строки.
; Syntax.........: _StringLeftStr($Str, $sStr [, $iFlag = 1])
; Author ........: Nikzzzz
; Examples ......: ConsoleWrite(_StringLeftStr("C:\Windows\system32\notepad.exe","\",-1) & @crlf)
; ===============================================================================================================================================
Func _StringLeftStr($Str, $sStr, $iFlag = 1)
	If StringInStr($Str, $sStr, 0, $iFlag) Then
		Return StringLeft($Str, StringInStr($Str, $sStr, 0, $iFlag) - 1)
	EndIf
	Return $Str
EndFunc   ;==>_StringLeftStr
; #FUNCTION# ====================================================================================================================================
; Name...........: _StringRightStr
; Description ...: Возвращает правую часть строки $Str относительно $sStr, $iFlag - номер вхождения подстроки $sStr, если он отрицательный, ищется с конца строки.
; Syntax.........: _StringRightStr($Str, $sStr [, $iFlag = 1])
; Author ........: Nikzzzz
; Examples ......: ConsoleWrite(_StringRightStr("C:\Windows\system32\notepad.exe","\",-1) & @crlf)
; ===============================================================================================================================================
Func _StringRightStr($Str, $sStr, $iFlag = 1)
	If StringInStr($Str, $sStr, 0, $iFlag) Then
		Return StringMid($Str, StringInStr($Str, $sStr, 0, $iFlag) + StringLen($sStr))
	EndIf
	Return ''
EndFunc   ;==>_StringRightStr
; #FUNCTION# ====================================================================================================================================
; Name...........: _EmptyName
; Description ...: Генерирует не занятое имя файлана на основе шаблона
; Syntax.........: _EmptyName($sFile)
; Author ........: Nikzzzz
; Examples ......: ConsoleWrite(_EmptyName("C:\Windows\system32\notepad.exe") & @crlf)
; ===============================================================================================================================================
Func _EmptyName($sFile, $sSym = '[', $sSym1 = ']')
	If FileExists($sFile) = 0 Then Return $sFile
	Local $i = 1, $sFile1
	While 1
		$sFile1 = _ParsePath($sFile, '%d%p%n' & $sSym & $i & $sSym1 & '%x')
		If FileExists($sFile1) = 0 Then Return $sFile1
		$i += 1
	WEnd
EndFunc   ;==>_EmptyName
; #FUNCTION# ====================================================================================================================================
; Name...........: _EscChar
; Description ...: Преобразует строку в формат регулярных выражений
; Syntax.........: _EscChar($sStr)
; Author ........: Nikzzzz
; Examples ......: ConsoleWrite(_EscChar("C:\Windows\system32\notepad.exe") & @crlf)
; ===============================================================================================================================================
Func _EscChar($sStr)
	Return StringRegExpReplace($sStr, '[][{}()*+?.\\^$|]', '\\\0')
EndFunc   ;==>_EscChar
Func _EscChar2($sStr)
	Local $sRes = '', $sSym
	While StringLen($sStr)
		$sSym = StringLeft($sStr, 1)
		$sStr = StringTrimLeft($sStr, 1)
		Switch $sSym
			Case '|'
			Case '^'
				$sSym = '\' & StringLeft($sStr, 1)
				$sStr = StringTrimLeft($sStr, 1)
			Case '?'
				$sSym = '.'
			Case '*'
				$sSym = '.*'
			Case Else
				$sSym = _EscChar($sSym)
		EndSwitch
		$sRes &=$sSym
	WEnd
	Return $sRes
EndFunc   ;==>_EscChar2
; #FUNCTION# ====================================================================================================================================
; Name...........: _FileRead
; Description ...: Чтение файла
; Syntax.........: _FileRead($sFile, $iMode = 0)
; Author ........: Nikzzzz
; ===============================================================================================================================================
Func _FileRead($sFile, $iMode = 0)
	Local $vData
	If $sFile = 'con:' Or $sFile = 'con' Then
		$vData = ConsoleRead()
	Else
		Local $hF = FileOpen($sFile, $iMode)
		Local $vData = FileRead($hF)
		FileClose($hF)
	EndIf
	Return $vData
EndFunc   ;==>_FileRead
; #FUNCTION# ====================================================================================================================================
; Name...........: _FileWrite
; Description ...: Запись в файл
; Syntax.........: _FileWrite($sFile, $iMode = 0)
; Author ........: Nikzzzz
; ===============================================================================================================================================
Func _FileWrite($sFile, $vData, $iMode = 2)
	If $sFile = 'con:' Or $sFile = 'con' Then
		ConsoleWrite($vData)
	Else
		Local $hF = FileOpen($sFile, $iMode)
		FileWrite($hF, $vData)
		FileClose($hF)
	EndIf
EndFunc   ;==>_FileWrite
; #FUNCTION# ====================================================================================================================================
; Name...........: _StringRegExp5
; Description ...: Возвращает первое вхождение регулярного выражения
; Syntax.........: _StringRegExp5($sStr, $sStr1, $iOffset = 1)
; Author ........: Nikzzzz
; ===============================================================================================================================================
Func _StringRegExp5($sStr, $sStr1, $iOffset = 1)
	Local $asStr = StringRegExp($sStr, '(?im-s)' & $sStr1, 1, $iOffset)
	If @error Then Return SetError(1, 0, '')
	Return SetError(0, @extended, $asStr[UBound($asStr) - 1])
EndFunc   ;==>_StringRegExp5
; #FUNCTION# ====================================================================================================================================
; Name...........: _StringRegExpCompare
; Description ...: Возвращает <>0 значение, если строки совпали
; Syntax.........: _StringRegExp5($sStr, $sStr1)
; Author ........: Nikzzzz
; ===============================================================================================================================================
Func _StringRegExpCompare($sStr, $sStr1)
	If $sStr = '' Then Return SetError(1, 0, 0)
	$sStr1 = '(?i)\A(?:' & $sStr1 & ')\z'
	If StringRegExp($sStr, $sStr1) Then
		Return SetError(0, 0, 1)
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc   ;==>_StringRegExpCompare
; #FUNCTION# ====================================================================================================================================
; Name...........: _StringRegExpReplaceEx
; Description ...: Расширенный вариант StringRegExpReplace, в качестве строки замену может использоваться функция
; Syntax.........: _StringRegExpReplaceEx($sStr, $sPattern, $sFunc, $sReplace [, $iCount = 0])
; Author ........: Nikzzzz
; Examples ......:
;ConsoleWrite(_StringRegExpReplaceEx("a=2,b=3,c=4", ".*=(\d+).*=(\d+).*=(\d+)", "_Mult", "\1,\2,\3") & @CRLF)
;Func _Mult($sStr)
;	Local $aStr = StringSplit($sStr, ",", 2)
;	Return $aStr[0] & '*' & $aStr[1] & '*' & $aStr[2] & '=' & $aStr[0] * $aStr[1] * $aStr[2]
;EndFunc   ;==>Mult
; ===============================================================================================================================================
Func _StringRegExpReplaceEx($sStr, $sPattern, $sFunc, $sReplace, $iCount = 0)
	If $iCount = 0 Then $iCount = -1
	Local $vTmp, $sRes = '', $iOffset, $iCountR = 0, $iErr = 1
	While $sStr
		$vTmp = StringRegExp($sStr, $sPattern, 2)
		If @error Then ExitLoop
		$iOffset = @extended
		$sRes &= StringLeft($sStr, $iOffset - StringLen($vTmp[0]) - 1)
		$sStr = StringMid($sStr, $iOffset)
		$sRes &= Call($sFunc, StringRegExpReplace($vTmp[0], $sPattern, $sReplace))
		$iCount -= 1
		$iCountR += 1
		$iErr = 0
		If $iCount = 0 Then ExitLoop
	WEnd
	$sRes &= $sStr
	Return SetError($iErr, $iCountR, $sRes)
EndFunc   ;==>_StringRegExpReplaceEx
Func _StringStripRight($sStr, $sStr1 = ' ')
	While StringRight($sStr, 1) = $sStr1
		$sStr = StringTrimRight($sStr, 1)
	WEnd
	Return $sStr
EndFunc   ;==>_StringStripRight
Func _StringStripLeft($sStr, $sStr1 = ' ')
	While StringLeft($sStr, 1) = $sStr1
		$sStr = StringTrimLeft($sStr, 1)
	WEnd
	Return $sStr
EndFunc   ;==>_StringStripLeft
Func _PathB($sPath)
	While 1
		$sPath = StringRegExpReplace($sPath, '\\[^\\]+(?<!\\\.\.)\\.\.\\', '\\')
		If @extended = 0 Then ExitLoop
	WEnd
	Return $sPath
EndFunc   ;==>_PathB
