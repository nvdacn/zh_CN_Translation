@echo off

"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t changes "%~dp0Translation\user_docs\changes.xliff" "%~dp0Preview\changes.html"
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t keyCommands "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\keyCommands.html"
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t userGuide "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\userGuide.html"

Exit
