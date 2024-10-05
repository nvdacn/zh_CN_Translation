@echo off

IF EXIST "%~dp0OldXLIFF\changes.xliff" (
  IF EXIST "%~dp0OldXLIFF\Temp" (rd /s /q "%~dp0OldXLIFF\Temp")
  IF EXIST "%~dp0changes.xliff" (del /f /q "%~dp0changes.xliff")

  MKDir "%~dp0OldXLIFF\Temp"
  MKLINK /H "%~dp0OldXLIFF\Temp\changes_Old.xliff" "%~dp0OldXLIFF\changes.xliff"
  MKLINK /H "%~dp0OldXLIFF\Temp\changes_Translated.xliff" "%~dp0..\Translation\user_docs\changes.xliff"

  "%~dp0..\Tools\nvdaL10nUtil.exe" stripXliff -o "%~dp0OldXLIFF\Temp\changes_Old.xliff" "%~dp0OldXLIFF\Temp\changes_Translated.xliff" "%~dp0changes.xliff"
) Else (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('文件 changes.xliff 不存在，请复制原始 changes.xliff 到 OldXLIFF 文件夹后重试。',5,'文件不存在');window.close();"
)

Exit
