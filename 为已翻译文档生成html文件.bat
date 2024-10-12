@echo off

IF not EXIST "%~dp0Tools\nvdaL10nUtil.exe" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('文件 nvdaL10nUtil.exe 不存在，请下载该程序并将其复制到 Tools 文件夹后重试。',5,'文件不存在');window.close();"
)

if not "%1"=="" (
set CLI=%1
goto goto
)

cls
echo 请选择要生成的文件，按回车键执行。
echo C：生成更新日志的html文件；
echo u：生成用户指南的html文件；
echo K：生成热键快速参考的html文件；
echo A：生成所有文档的html文件；
echo 其他命令：退出本工具。
echo 上述选项还可通过命令行直接传入。

set /p CLI=

:goto
for /r "%~dp0Preview" %%i in (*.html) do (
  del /f /q "%%i"
)
goto %CLI%

:A
:C
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t changes "%~dp0Translation\user_docs\changes.xliff" "%~dp0Preview\changes.html"
if /I "%CLI%"=="C" (Exit)

:U
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t userGuide "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\userGuide.html"
if /I "%CLI%"=="U" (Exit)

:K
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t keyCommands "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\keyCommands.html"

Exit
