#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=IconGroup99.ico
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Au3Cx
#AutoIt3Wrapper_Res_Description=Au3Cx
#AutoIt3Wrapper_Res_Fileversion=2018.8.20.2
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=Au3Cx
#AutoIt3Wrapper_Res_ProductVersion=2018.8.20.1
#AutoIt3Wrapper_Res_LegalCopyright=(c)Nikzzzz
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe  /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
$sVer = '2018.08.20'
#include <WinAPIEx.au3>
Global Const $sQ3 = '/'
#include <WinAPIRes.au3>
Global Const $sQ4 = 'in'
#include 'bin\ExLib.au3'
#include 'bin\x.au3'
Global Const $sQ = Chr(34)
#include <Encoding.au3>
Opt('TrayIconHide', 1)
ConsoleWrite('Au3Cx    (c)Nikzzzz              ' & $sVer & @CRLF)
If $CmdLine[0] = 0 Then
	ConsoleWrite('Syntax:' & @CRLF & _
			'Au3Cx CompiledAu3File.exe' & @CRLF & _
			@CRLF)
	Exit
EndIf
Local $sFile = $CmdLine[1]
$sFile = _ParsePath($sFile, '%d%p%n%x')
If Not FileExists($sFile) Then
	ConsoleWrite('File ' & $sFile & ' not found.' & @CRLF)
EndIf

Local $hInstance = _WinAPI_LoadLibraryEx($sFile, 2)
Local $hResource = _WinAPI_FindResourceEx($hInstance, $RT_RCDATA, 'SCRIPT', 0)
If $hResource = 0 Then
	ConsoleWrite('Error - file ' & $sFile & ' is not compiled Autoit file.' & @CRLF)
	Exit
Else
	FileCopy($sFile, $sFile & '.bak')
EndIf

Local $iSize = _WinAPI_SizeOfResource($hInstance, $hResource)
Global Const $sQ5 = 'out'
Local $hData = _WinAPI_LoadResource($hInstance, $hResource)
Global Const $sQ2 = ' '
Local $pData = _WinAPI_LockResource($hData)
Local $tData = DllStructCreate('byte[' & $iSize & ']', $pData)
Local $bData = DllStructGetData($tData, 1)
_WinAPI_FreeLibrary($hInstance)
Local $sComp = _EmptyName(EnvGet('temp') & '\$.$')
_FileWrite($sComp, x(), 18)
Local $sTmpFile = _EmptyName(EnvGet('temp') & '\$.$')
_FileWrite($sTmpFile, $bData, 18)
Local $sTmpFile1 = _EmptyName(EnvGet('temp') & '\$.a3x')
$sStr = $sQ & $sComp & $sQ & $sQ2 & $sQ3 & $sQ4 & $sQ2 & $sQ & $sTmpFile & $sQ & $sQ2 & $sQ3 & $sQ5 & $sQ2 & $sQ & $sTmpFile1 & $sQ
RunWait($sStr)
FileDelete($sComp)
FileDelete($sTmpFile)
$bData = _FileRead($sTmpFile1, 16)
FileDelete($sTmpFile1)
$iSize = BinaryLen($bData)
$tData = DllStructCreate('byte[' & $iSize & ']')
DllStructSetData($tData, 1, $bData)
$hUpdate = _WinAPI_BeginUpdateResource($sFile)
_WinAPI_UpdateResource($hUpdate, $RT_RCDATA, 'SCRIPT', 0, DllStructGetPtr($tData), $iSize)
_WinAPI_EndUpdateResource($hUpdate)
ConsoleWrite('Cmpleted.' & @CRLF)
