@echo off

chcp 65001

for /f "delims=" %%o in ('git branch --show-current') do set Branch=%%o

if "%1" == "GITHUB_ACTIONS" (
  set DateTime=%date:~-10,2%%date:~-7,2%%time:~0,2%%time:~3,2%
) else (
  set DateTime=%date:~8,2%%date:~11,2%%time:~0,2%%time:~3,2%
)

If "%DateTime:~4,1%" == " " (
  set VersionInfo=%DateTime:~0,4%0%DateTime:~5,3%
) Else (
  set VersionInfo=%DateTime%
)

IF EXIST "%~dp0Preview\Output" (rd /s /q "%~dp0Preview\Output")
IF EXIST "%~dp0Preview\Archive" (rd /s /q "%~dp0Preview\Archive")

MKDir "%~dp0Preview\Output\locale\zh_CN\LC_MESSAGES"
"%~dp0Tools\msgfmt.exe" -o "%~dp0Preview\Output\locale\zh_CN\LC_MESSAGES\nvda.mo" "%~dp0Translation\LC_MESSAGES\nvda.po"

MKDir "%~dp0Preview\Output\documentation\zh_CN"
MKLINK /H "%~dp0Preview\Output\documentation\zh_CN\numberedHeadings.css" "%~dp0Preview\numberedHeadings.css"
MKLINK /H "%~dp0Preview\Output\documentation\zh_CN\styles.css" "%~dp0Preview\styles.css"
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t changes "%~dp0Translation\user_docs\changes.xliff" "%~dp0Preview\Output\documentation\zh_CN\changes.html"
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t keyCommands "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\Output\documentation\zh_CN\keyCommands.html"
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t userGuide "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\Output\documentation\zh_CN\userGuide.html"

"%~dp0Tools\7Zip\7z.exe" a -sccUTF-8 -y -tzip "%~dp0Preview\Archive\NVDA_%Branch%_翻译测试（解压到NVDA程序文件夹）_%VersionInfo%.zip" "%~dp0Preview\Output\documentation" "%~dp0Preview\Output\locale"

Exit
