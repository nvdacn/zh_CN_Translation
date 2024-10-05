@echo off

IF EXIST "%~dp0OldXLIFF\userGuide.xliff" (
  IF EXIST "%~dp0OldXLIFF\Temp" (rd /s /q "%~dp0OldXLIFF\Temp")
  IF EXIST "%~dp0userGuide.xliff" (del /f /q "%~dp0userGuide.xliff")

  MKDir "%~dp0OldXLIFF\Temp"
  MKLINK /H "%~dp0OldXLIFF\Temp\userGuide_Old.xliff" "%~dp0OldXLIFF\userGuide.xliff"
  MKLINK /H "%~dp0OldXLIFF\Temp\userGuide_Translated.xliff" "%~dp0..\Translation\user_docs\userGuide.xliff"

  "%~dp0..\Tools\nvdaL10nUtil.exe" stripXliff -o "%~dp0OldXLIFF\Temp\userGuide_Old.xliff" "%~dp0OldXLIFF\Temp\userGuide_Translated.xliff" "%~dp0userGuide.xliff"
) Else (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('文件 userGuide.xliff 不存在，请复制原始 userGuide.xliff 到 OldXLIFF 文件夹后重试。',5,'文件不存在');window.close();"
)

Exit
