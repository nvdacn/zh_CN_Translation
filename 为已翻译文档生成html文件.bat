@echo off

IF not EXIST "%~dp0Tools\nvdaL10nUtil.exe" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('文件 nvdaL10nUtil.exe 不存在，请下载该程序并将其复制到 Tools 文件夹后重试。',5,'文件不存在');window.close();"
Exit
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
echo DOC：生成所有文档的html文件；
echo STC：生成可直接上传到Crowdin的changes文档，需要将原始xliff文件放入存储库的Crowdin\OldXLIFF文件夹下，如未检测到该文件，系统会从存储库的默认分支提取；
echo STU：生成可直接上传到Crowdin的userGuide文档，需要将原始xliff文件放入存储库的Crowdin\OldXLIFF文件夹下，如未检测到该文件，系统会从存储库的默认分支提取；
echo 其他命令：退出本工具。
echo 上述选项还可通过命令行直接传入。

set /p CLI=

:goto
goto %CLI%

:DOC
:C
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t changes "%~dp0Translation\user_docs\changes.xliff" "%~dp0Preview\changes.html"
if /I "%CLI%"=="C" (Exit)

:U
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t userGuide "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\userGuide.html"
if /I "%CLI%"=="U" (Exit)

:K
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t keyCommands "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\keyCommands.html"
if /I "%CLI%"=="K" (Exit)
if /I "%CLI%"=="DOC" (Exit)

:STC
:STU
if /I "%CLI%"=="STC" (
set ST=changes
goto ST
) 
if /I "%CLI%"=="STU" (
set ST=userGuide
goto ST
)
exit

:ST
IF EXIST "%~dp0Crowdin\OldXLIFF\Temp" (
rd /s /q "%~dp0Crowdin\OldXLIFF\Temp"
)

MKDir "%~dp0Crowdin\OldXLIFF\Temp"

IF EXIST "%~dp0%ST%.xliff" (del /f /q "%~dp0%ST%.xliff")

IF Not EXIST "%~dp0Crowdin\OldXLIFF\%ST%.xliff" (
git archive --output "./Crowdin/OldXLIFF/Temp/%ST%.zip" 2025.1 Translation/user_docs/%ST%.xliff
"%~dp0Tools\7Zip\7z.exe" e "%~dp0Crowdin\OldXLIFF\Temp\%ST%.zip" "Translation\user_docs\%ST%.xliff" -aoa -o"%~dp0Crowdin\OldXLIFF"
)

  MKLINK /H "%~dp0Crowdin\OldXLIFF\Temp\%ST%_Old.xliff" "%~dp0Crowdin\OldXLIFF\%ST%.xliff"
MKLINK /H "%~dp0Crowdin\OldXLIFF\Temp\%ST%_Translated.xliff" "%~dp0Translation\user_docs\%ST%.xliff"

"%~dp0Tools\nvdaL10nUtil.exe" stripXliff -o "%~dp0Crowdin\OldXLIFF\Temp\%ST%_Old.xliff" "%~dp0Crowdin\OldXLIFF\Temp\%ST%_Translated.xliff" "%~dp0Crowdin\%ST%.xliff"

Exit
