@echo off

chcp 65001>Nul

Rem 为避免出现编码错误，请在行末是中文字符的行尾添加两个空格  
Rem 设置 nvdaL10nUtil 程序路径  
set "L10nUtil="
for %%F in (
  "%~dp0Tools\NVDA\source\l10nUtil.py"
  "%~dp0Tools\nvdaL10nUtil.exe"
) do (
  if exist %%F (
    if "%%F"=="%~dp0Tools\NVDA\source\l10nUtil.py" (
      set "L10nUtil=python "%%F""
    ) else (
      set "L10nUtil=%%F"
    )
  )
)

Rem GitHub Actions 流程  
set ProcessCLI=%1
if not "%ProcessCLI:~2,1%"=="_" (goto Crowdin)
if "%ProcessCLI%" == "Build_Translation" (
  set CLI=T
  goto T
)
for /f "tokens=1,2 delims=_" %%A in ("%ProcessCLI%") do (
  set "CLIPart1=%%A"
  set "CLIPart2=%%B"
)
set "CLIPart2=%CLIPart2:~0,1%"
if /I "%CLIPart2%"=="n" set "CLIPart2=L"
set "CLI=%CLIPart1%%CLIPart2%"
goto %CLI%

:Crowdin
Rem 判断 是否存在 Crowdin 令牌  
IF not EXIST "%Userprofile%\.nvda_crowdin" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('文件 "%%Userprofile%%＼.nvda_crowdin" 不存在，请生成 Crowdin 令牌并创建 .nvda_crowdin 文件后重试。',5,'文件不存在');window.close();"
  Exit
)

Rem 判断是否从命令行传入参数  
if not "%1"=="" (
  set CLI=%1
  goto goto
)

Rem 打印可用命令  
cls
echo 欢迎使用 L10nUtilTools，请输入要执行的操作，按回车键确认。  
echo C：生成更新日志的 html 文件；  
echo U：生成用户指南的 html 文件；  
echo K：生成热键快速参考的 html 文件；  
echo D：生成所有文档的 html 文件；  
echo L：生成界面翻译的 mo 文件；  
echo T：生成翻译测试文件（不压缩）；  
echo Z：生成翻译测试文件的压缩包；  
echo UPC：上传已翻译的 changes.xliff 文件到 Crowdin；  
echo UPU：上传已翻译的 userGuide.xliff 文件到 Crowdin；  
echo UPL：上传已翻译的 nvda.po 文件到 Crowdin；  
echo UPA：上传所有已翻译的文件到 Crowdin；  
echo DLC：从 Crowdin 下载已翻译的 changes.xliff 文件；  
echo DLU：从 Crowdin 下载已翻译的 userGuide.xliff 文件；  
echo DLL：从 Crowdin 下载已翻译的 nvda.po 文件；  
echo DLA：从 Crowdin 下载所有已翻译的文件；  
echo DCC：从 Crowdin 下载已翻译的 changes.xliff 文件并将其提交到存储库；  
echo DCU：从 Crowdin 下载已翻译的 userGuide.xliff 文件并将其提交到存储库；  
echo DCL：从 Crowdin 下载已翻译的 nvda.po 文件并将其提交到存储库；  
echo DCA：从 Crowdin 下载所有已翻译的文件并将其提交到存储库；  
echo CLE：清理上述命令生成的所有文件；  
echo 其他命令：退出本工具。  
echo 上述选项还可通过命令行直接传入。  

Rem 等待用户输入并跳转到用户输入的命令  
set /p CLI=
:goto
cls
goto %CLI%

Rem 生成文档的流程，此部分命令会连续执行，直到符合输入的命令后退出  
Rem 生成更新日志  
:C
:D
:T
:Z
IF EXIST "%~dp0Preview\changes.html" (del /f /q "%~dp0Preview\changes.html")
%L10nUtil% xliff2html -t changes "%~dp0Translation\user_docs\changes.xliff" "%~dp0Preview\changes.html"
if /I "%CLI%"=="C" (Exit)

Rem 生成用户指南  
:U
IF EXIST "%~dp0Preview\userGuide.html" (del /f /q "%~dp0Preview\userGuide.html")
%L10nUtil% xliff2html -t userGuide "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\userGuide.html"
if /I "%CLI%"=="U" (Exit)

Rem 生成热键快速参考  
:K
IF EXIST "%~dp0Preview\keyCommands.html" (del /f /q "%~dp0Preview\keyCommands.html")
%L10nUtil% xliff2html -t keyCommands "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\keyCommands.html"
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
set DateTime=%date:~8,2%%date:~11,2%%time:~0,2%%time:~3,2%
If "%DateTime:~4,1%" == " " (
  set VersionInfo=%DateTime:~0,4%0%DateTime:~5,3%
) Else (
  set VersionInfo=%DateTime%
)

Rem 生成翻译测试压缩包  
IF EXIST "%~dp0Preview\Archive" (rd /s /q "%~dp0Preview\Archive")
"%~dp0Tools\7Zip\7z.exe" a -sccUTF-8 -y -tzip "%~dp0Preview\Archive\NVDA_%Branch%_翻译测试（解压到NVDA程序文件夹）_%VersionInfo%.zip" "%~dp0Preview\Test\documentation" "%~dp0Preview\Test\locale"
if /I "%CLI%"=="Z" (Exit)

Rem 处理标签  
:DLL
:DLC
:DLU
:DLA
:DCL
:DCC
:DCU
:DCA
:UPL
:UPC
:UPU
:UPA
if /I  %CLI:~0,2%==DL (set Action=DownloadFiles)
if /I  %CLI:~0,2%==DC (
  cd /d "%~dp0"
  set Action=DownloadAndCommit
)
if /I  %CLI:~0,2%==UP (set Action=UploadFiles)
if /I %CLI:~2,1%==A (
  set Type=All
  if /I %Action%==DownloadAndCommit (
    set Parameter=DL
  ) else (
    set Parameter=%CLI:~0,2%
  )
  goto All
)
if /I %CLI:~2,1%==L (
  set Type=LC_MESSAGES
  set GitAddPath=Translation/LC_MESSAGES
  set TranslationPath=%~dp0Translation\LC_MESSAGES
  set FileName=nvda.po
)
if /I %CLI:~2,1%==C (
  set Type=Docs
  set FileName=changes.xliff
)
if /I %CLI:~2,1%==U (
  set Type=Docs
  set FileName=userGuide.xliff
)
if /I %Type%==Docs (
  set GitAddPath=Translation/user_docs
  set TranslationPath=%~dp0Translation\user_docs
)
goto %Action%

Rem **A 系列命令：通过循环调用另一个L10nUtilTools.bat来分别处理  
:All
for %%i in (L C U) do (
  Start /Wait /D "%~dp0" L10nUtilTools %Parameter%%%i
)
if /I %Action%==DownloadAndCommit (goto Commit)
exit

Rem 从 Crowdin 下载已翻译的文件  
:DownloadFiles
:DownloadAndCommit
set DownloadFilename=%TranslationPath%\%FileName%
IF EXIST "%DownloadFilename%" (del /f /q "%DownloadFilename%")
%L10nUtil% downloadTranslationFile zh-CN "%FileName%" "%DownloadFilename%"
if /I %Action%==DownloadAndCommit (goto Commit)
Exit

Rem 将下载的翻译文件提交到存储库  
:Commit
if /I %Type%==All (
  set AddFileList="Translation/LC_MESSAGES/*.po" "Translation/user_docs/*.xliff"
  set CommitMSG=更新翻译（从 Crowdin）
) else (
  set AddFileList="%GitAddPath%/%FileName%"
  set CommitMSG=更新 %FileName%（从 Crowdin）
)
git add %AddFileList%
git commit -m "%CommitMSG%"
exit

Rem 提取之前翻译的 xliff 文件用于上传时比较差异  
:ReadyUpload
set TempFolder=%~dp0Crowdin\Temp
set OldFile=%TempFolder%\%FileName%.old
set Parameter=--old "%OldFile%"
IF EXIST "%TempFolder%" (rd /s /q "%TempFolder%")
MKDir "%TempFolder%"
IF Not EXIST "%~dp0Crowdin\OldXLIFF\%FileName%" (
  git archive --output "./Crowdin/Temp/%FileName%.zip" main %GitAddPath%/%FileName%
  "%~dp0Tools\7Zip\7z.exe" e "%TempFolder%\%FileName%.zip" "Translation\user_docs\%FileName%" -aoa -o"%~dp0Crowdin\OldXLIFF"
)
MKLINK /H "%OldFile%" "%~dp0Crowdin\OldXLIFF\%FileName%"
goto Upload

Rem 上传已翻译的文件到 Crowdin
:UploadFiles
if /I %Type%==Docs (
  goto ReadyUpload
) else (
  set Parameter= 
)
:Upload
%L10nUtil% uploadTranslationFile zh-CN "%FileName%" "%TranslationPath%\%FileName%" %Parameter%
Exit

Rem 清理本工具生成的所有文件  
:CLE
rd /s /q "%~dp0Crowdin"
rd /s /q "%~dp0Preview"
Git restore Crowdin/* Preview/*
Exit
