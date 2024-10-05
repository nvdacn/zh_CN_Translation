@echo off

IF EXIST "%~dp0OldXLIFF\userGuide.xliff" (
  IF EXIST "%~dp0OldXLIFF\Temp" (rd /s /q "%~dp0OldXLIFF\Temp")
  IF EXIST "%~dp0userGuide.xliff" (del /f /q "%~dp0userGuide.xliff")

  MKDir "%~dp0OldXLIFF\Temp"
  MKLINK /H "%~dp0OldXLIFF\Temp\userGuide_Old.xliff" "%~dp0OldXLIFF\userGuide.xliff"
  MKLINK /H "%~dp0OldXLIFF\Temp\userGuide_Translated.xliff" "%~dp0..\Translation\user_docs\userGuide.xliff"

  "%~dp0..\Tools\nvdaL10nUtil.exe" stripXliff -o "%~dp0OldXLIFF\Temp\userGuide_Old.xliff" "%~dp0OldXLIFF\Temp\userGuide_Translated.xliff" "%~dp0userGuide.xliff"
) Else (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('�ļ� userGuide.xliff �����ڣ��븴��ԭʼ userGuide.xliff �� OldXLIFF �ļ��к����ԡ�',5,'�ļ�������');window.close();"
)

Exit
