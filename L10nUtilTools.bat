@echo off
setlocal enabledelayedexpansion
chcp 65001>Nul
Title L10n Util Tools

Rem 为避免出现编码错误，请在行末是中文字符的行尾添加两个空格  
Rem 设置 nvdaL10nUtil 程序路径  
set "L10nUtil="
for %%F in (
  "%ProgramFiles%\NVDA\l10nUtil.exe"
  "%ProgramFiles(x86)%\NVDA\l10nUtil.exe"
  "%~dp0Tools\NVDA\source\l10nUtil.py"
) do (
  if exist %%F (
    if "%%~F"=="%~dp0Tools\NVDA\source\l10nUtil.py" (
      set "L10nUtil=uv --directory "%~dp0Tools\NVDA" run %%F"
    ) else (
      set "L10nUtil=%%F"
    )
  )
  if defined L10nUtil (
    echo %%l10nUtil%% is set to !l10nUtil!.
    goto CheckCLI
  )
)

Rem 检查 %L10nUtil% 是否存在  
if not defined L10nUtil (
  echo l10nUtil program not found.
  mshta "javascript:new ActiveXObject('wscript.shell').popup('未找到 l10nUtil 程序，请安装 NVDA 2025.1.0.35381或以上版本后重试。',5,'错误');window.close();"
  exit /b 1
)

Rem 判断是否从命令行传入参数  
:CheckCLI
if not "%1"=="" (
  set ProcessCLI=%1
  if not "!ProcessCLI:_=!"=="!ProcessCLI!" (goto ProcessCLI)
  set CLI=%1
  goto goto
) else (
goto echo
)

Rem 处理 CLI
:ProcessCLI
for /f "tokens=1,2 delims=_" %%A in ("%ProcessCLI%") do (
  set "CLIPart1=%%A"
  set "CLIPart2=%%B"
)
if /I "%CLIPart1%"=="BD" (set "CLIPart1=")
set "replacements=TEST:T nvda:L changes:C userGuide:U"
for %%R in (%replacements%) do (
  for /f "tokens=1,2 delims=:" %%A in ("%%R") do (
    if /I "%CLIPart2%"=="%%A" (set "CLIPart2=%%B")
  )
)
set "CLI=%CLIPart1%%CLIPart2%"
echo %%CLI%% is set to %CLI%, start executing the command.
goto %CLI%

Rem 打印可用命令  
:Echo
cls
echo 欢迎使用 L10nUtilTools，请输入要执行的操作，按回车键确认。  
echo C：生成更新日志的 html 文件；  
echo U：生成用户指南的 html 文件；  
echo K：生成热键快速参考的 html 文件；  
echo D：生成所有文档的 html 文件；  
echo L：生成界面翻译的 mo 文件；  
echo T：生成翻译测试文件（不压缩）；  
echo Z：生成翻译测试文件的压缩包；  
echo UDL：从给定的 nvda.pot 更新 nvda.po 的翻译字符串；  
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
MKLINK /H "%~dp0Preview\Test\locale\zh_CN\characterDescriptions.dic" "%~dp0Translation\miscDeps\characterDescriptions.dic"
MKLINK /H "%~dp0Preview\Test\locale\zh_CN\gestures.ini" "%~dp0Translation\miscDeps\gestures.ini"
MKLINK /H "%~dp0Preview\Test\locale\zh_CN\symbols.dic" "%~dp0Translation\miscDeps\symbols.dic"
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

Rem 从给定的 nvda.pot 更新界面翻译字符串  
:UDL
Rem 设置 GettextTools 程序路径  
for %%F in (
  "%ProgramFiles(x86)%\Poedit\GettextTools\bin"
  "%ProgramFiles%\Poedit\GettextTools\bin"
) do (
  if exist %%F (
    set "Gettext=%%F"
  )
)
if defined Gettext (
  echo %%Gettext%% is set to !Gettext!.
) Else (
  echo Poedit program not found.
  mshta "javascript:new ActiveXObject('wscript.shell').popup('请安装 Poedit 后重试。',5,'错误');window.close();"
  exit /b 1
)
IF NOT EXIST "%~dp0PotXliff\nvda.pot" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('请将要合并的 nvda.pot 文件复制到 PotXliff 文件夹后重试。',5,'未找到文件');window.close();"
  exit /b 1
)
CD /D %Gettext% 
msgmerge.exe --update --backup=none --previous "%~dp0Translation\LC_MESSAGES\nvda.po" "%~dp0PotXliff\nvda.pot"
Exit

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
set TempFolder=%~dp0PotXliff\Temp
set OldFile=%TempFolder%\%FileName%.old
set Parameter=--old "%OldFile%"
IF EXIST "%TempFolder%" (rd /s /q "%TempFolder%")
MKDir "%TempFolder%"
IF Not EXIST "%~dp0PotXliff\%FileName%" (
  git archive --output "./PotXliff/Temp/%FileName%.zip" main %GitAddPath%/%FileName%
  "%~dp0Tools\7Zip\7z.exe" e "%TempFolder%\%FileName%.zip" "Translation\user_docs\%FileName%" -aoa -o"%~dp0PotXliff"
)
MKLINK /H "%OldFile%" "%~dp0PotXliff\%FileName%"
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
rd /s /q "%~dp0PotXliff"
rd /s /q "%~dp0Preview"
Git restore PotXliff/* Preview/*
Exit
