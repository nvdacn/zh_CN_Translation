@echo off

chcp 65001

Rem 为避免出现编码错误，请在行末是中文字符的行尾添加两个空格  
Rem GitHub Actions 流程  
if "%1" == "GITHUB_ACTIONS" (
  set CLI=T
  goto T
)

Rem 判断 是否存在 nvdaL10nUtil
IF not EXIST "%~dp0Tools\nvdaL10nUtil.exe" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('文件 nvdaL10nUtil.exe 不存在，请下载该程序并将其复制到 Tools 文件夹后重试。',5,'文件不存在');window.close();"
  Exit
)

Rem 判断是否从命令行传入参数  
if not "%1"=="" (
  set CLI=%1
  goto goto
)

Rem 打印可用命令  
cls
echo 欢迎使用文件生成工具，请选择要生成的文件，按回车键执行。  
echo C：生成更新日志的html文件；  
echo u：生成用户指南的html文件；  
echo K：生成热键快速参考的html文件；  
echo D：生成所有文档的html文件；  
echo L：生成界面翻译的mo文件；  
echo T：生成翻译测试文件（不压缩）；  
echo Z：生成翻译测试文件的压缩包；  
echo STC：生成可直接上传到Crowdin的changes文档，需要将原始xliff文件放入存储库的Crowdin\OldXLIFF文件夹下，如未检测到该文件，系统会从存储库的main分支提取；  
echo STU：生成可直接上传到Crowdin的userGuide文档，需要将原始xliff文件放入存储库的Crowdin\OldXLIFF文件夹下，如未检测到该文件，系统会从存储库的main分支提取； 
echo CLE：清理上述命令生成的所有文件；  
echo 其他命令：退出本工具。  
echo 上述选项还可通过命令行直接传入。  

Rem 等待用户输入并跳转到用户输入的命令  
set /p CLI=
:goto
goto %CLI%

Rem 生成文档的流程，此部分命令会连续执行，直到符合输入的命令后退出  
Rem 生成更新日志  
:C
:D
:T
:Z
IF EXIST "%~dp0Preview\changes.html" (del /f /q "%~dp0Preview\changes.html")
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t changes "%~dp0Translation\user_docs\changes.xliff" "%~dp0Preview\changes.html"
if /I "%CLI%"=="C" (Exit)

Rem 生成用户指南  
:U
IF EXIST "%~dp0Preview\userGuide.html" (del /f /q "%~dp0Preview\userGuide.html")
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t userGuide "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\userGuide.html"
if /I "%CLI%"=="U" (Exit)

Rem 生成热键快速参考  
:K
IF EXIST "%~dp0Preview\keyCommands.html" (del /f /q "%~dp0Preview\keyCommands.html")
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t keyCommands "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\keyCommands.html"
if /I "%CLI%"=="K" (Exit)
if /I "%CLI%"=="D" (Exit)

Rem 生成界面翻译  
:L
IF EXIST "%~dp0Preview\nvda.mo" (del /f /q "%~dp0Preview\nvda.mo")
"%~dp0Tools\msgfmt.exe" -o "%~dp0Preview\nvda.mo" "%~dp0Translation\LC_MESSAGES\nvda.po"
if /I "%CLI%"=="L" (Exit)

Rem 生成NVDA翻译目录结构  
IF EXIST "%~dp0Preview\Test" (rd /s /q "%~dp0Preview\Test")
MKDir "%~dp0Preview\Test\locale\zh_CN\LC_MESSAGES"
MKLINK /H "%~dp0Preview\Test\locale\zh_CN\LC_MESSAGES\nvda.mo" "%~dp0Preview\nvda.mo"
MKDir "%~dp0Preview\Test\documentation\zh_CN"
MKLINK /H "%~dp0Preview\Test\documentation\zh_CN\numberedHeadings.css" "%~dp0Preview\numberedHeadings.css"
MKLINK /H "%~dp0Preview\Test\documentation\zh_CN\styles.css" "%~dp0Preview\styles.css"
MKLINK /H "%~dp0Preview\Test\documentation\zh_CN\changes.html" "%~dp0Preview\changes.html"
MKLINK /H "%~dp0Preview\Test\documentation\zh_CN\keyCommands.html" "%~dp0Preview\keyCommands.html"
MKLINK /H "%~dp0Preview\Test\documentation\zh_CN\userGuide.html" "%~dp0Preview\userGuide.html"
if /I "%CLI%"=="T" (Exit)

Rem 获取当前分支名称、系统的日期和时间作为翻译测试压缩包的部分名称  
for /f "delims=" %%o in ('git branch --show-current') do set Branch=%%o
set DateTime=%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%
If "%DateTime:~4,1%" == " " (
  set VersionInfo=%DateTime:~0,4%0%DateTime:~5,3%
) Else (
  set VersionInfo=%DateTime%
)

Rem 生成翻译测试压缩包  
IF EXIST "%~dp0Preview\Archive" (rd /s /q "%~dp0Preview\Archive")
"%~dp0Tools\7Zip\7z.exe" a -sccUTF-8 -y -tzip "%~dp0Preview\Archive\NVDA_%Branch%_翻译测试（解压到NVDA程序文件夹）_%VersionInfo%.zip" "%~dp0Preview\Test\documentation" "%~dp0Preview\Test\locale"
if /I "%CLI%"=="Z" (Exit)

Rem 判断要生成的文件（用于生成可直接上传到Crowdin的xliff文件）  
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

Rem 生成可直接上传到Crowdin的xliff文件  
:ST
IF EXIST "%~dp0Crowdin\OldXLIFF\Temp" (rd /s /q "%~dp0Crowdin\OldXLIFF\Temp")
MKDir "%~dp0Crowdin\OldXLIFF\Temp"
IF EXIST "%~dp0%ST%.xliff" (del /f /q "%~dp0%ST%.xliff")
IF Not EXIST "%~dp0Crowdin\OldXLIFF\%ST%.xliff" (
git archive --output "./Crowdin/OldXLIFF/Temp/%ST%.zip" main Translation/user_docs/%ST%.xliff
"%~dp0Tools\7Zip\7z.exe" e "%~dp0Crowdin\OldXLIFF\Temp\%ST%.zip" "Translation\user_docs\%ST%.xliff" -aoa -o"%~dp0Crowdin\OldXLIFF"
)
MKLINK /H "%~dp0Crowdin\OldXLIFF\Temp\%ST%_Old.xliff" "%~dp0Crowdin\OldXLIFF\%ST%.xliff"
MKLINK /H "%~dp0Crowdin\OldXLIFF\Temp\%ST%_Translated.xliff" "%~dp0Translation\user_docs\%ST%.xliff"
"%~dp0Tools\nvdaL10nUtil.exe" stripXliff -o "%~dp0Crowdin\OldXLIFF\Temp\%ST%_Old.xliff" "%~dp0Crowdin\OldXLIFF\Temp\%ST%_Translated.xliff" "%~dp0Crowdin\%ST%.xliff"
Exit

Rem 清理本工具生成的所有文件  
:CLE
rd /s /q "%~dp0Crowdin"
rd /s /q "%~dp0Preview"
Git restore Crowdin/* Preview/*
Exit
