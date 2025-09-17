@echo off
setlocal enabledelayedexpansion
chcp 65001>Nul
Title L10n Util Tools

Rem 为避免出现编码错误，请在行末是中文字符的行尾添加两个空格  
Rem 判断是否从命令行传入参数  
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
if /I "%CLIPart1%"=="BD" (set "CLIPart1=GE")
set "replacements=TEST:T nvda:L changes:C userGuide:U"
for %%R in (%replacements%) do (
  for /f "tokens=1,2 delims=:" %%A in ("%%R") do (
    if /I "%CLIPart2%"=="%%A" (set "CLIPart2=%%B")
  )
)
set "CLI=%CLIPart1%%CLIPart2%"
echo %%CLI%% is set to %CLI%, start executing the command.
goto goto

Rem 打印可用命令  
:Echo
cls
echo 欢迎使用 L10nUtilTools，请输入要执行的操作，按回车键确认。  
echo GEC：生成更新日志的 html 文件；  
echo GEU：生成用户指南的 html 文件；  
echo GEK：生成热键快速参考的 html 文件；  
echo GEL：生成界面翻译的 mo 文件；  
echo GET：生成翻译测试文件（不压缩）；  
echo GEZ：生成翻译测试文件的压缩包；  
echo GMC：生成更新日志的 Markdown 文件；  
echo GMU：生成用户指南的 Markdown 文件；  
echo MHC：从先前创建的 Markdown 文档生成更新日志的 html 文件；  
echo MHU：从先前创建的 Markdown 文档生成用户指南的 html 文件；  
echo MXC：从先前创建的 Markdown 文档生成更新日志的 xliff 文件；  
echo MXU：从先前创建的 Markdown 文档生成用户指南的 xliff 文件；  
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

Rem 等待用户输入  
set /p CLI=

Rem 初始化变量，跳转到用户输入的命令或退出  
:goto
set ExitCode=0
set Parameter=%CLI:~0,2%
cls
goto %CLI% >Nul
exit

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
set ExitCode=%errorlevel%
goto Quit

Rem 设置 nvdaL10nUtil 程序路径  
:GEC
:GEU
:GEK
:GEL
:GET
:GEZ
:GMC
:GMU
:MHC
:MHU
:MXC
:MXU
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
    goto ProcessingNVDATags
  )
)

Rem 检查 %L10nUtil% 是否存在  
if not defined L10nUtil (
  echo l10nUtil program not found.
  mshta "javascript:new ActiveXObject('wscript.shell').popup('未找到 l10nUtil 程序，请安装 NVDA 2025.1.0.35381或以上版本后重试。',5,'错误');window.close();"
  exit /b 1
)

Rem 处理针对 NVDA 翻译的标签，初始化变量  
:ProcessingNVDATags
if /I "%CLI:~0,2%"=="GE" (set Action=GenerateFiles)
if /I "%CLI:~0,2%"=="GM" (set Action=GenerateMarkdown)
if /I "%CLI:~0,2%"=="MH" (set Action=GenerateHTML)
if /I "%CLI:~0,2%"=="MX" (set Action=GenerateXLIFF)
if /I "%CLI:~0,2%"=="DL" (set Action=DownloadFiles)
if /I "%CLI:~0,2%"=="DC" (
  cd /d "%~dp0"
  set Action=DownloadAndCommit
)
if /I "%CLI:~0,2%"=="UP" (set Action=UploadFiles)
if /I "%CLI:~2,1%"=="T" (
  set Type=Test
  set CallForEachParameter=L C U K
  goto CallForEach
)
if /I "%CLI:~2,1%"=="Z" (
  set Type=Archive
  set CallForEachParameter=L C U K
  goto CallForEach
)
if /I "%CLI:~2,1%"=="A" (
  set Type=All
  set CallForEachParameter=L C U
  if /I "%Action%"=="DownloadAndCommit" (
    set Parameter=DL
  )
  goto CallForEach
)
if /I "%CLI:~2,1%"=="L" (
  set Type=LC_MESSAGES
  set GitAddPath=Translation/LC_MESSAGES
  set TranslationPath=%~dp0Translation\LC_MESSAGES
  set FileName=nvda.po
  set ShortName=nvda
)
if /I "%CLI:~2,1%"=="C" (
  set Type=Docs
  set FileName=changes.xliff
  set ShortName=changes
)
if /I "%CLI:~2,1%"=="U" (
  set Type=Docs
  set FileName=userGuide.xliff
  set ShortName=userGuide
)
if /I "%CLI:~2,1%"=="K" (
  set Type=Docs
  set FileName=userGuide.xliff
  set ShortName=keyCommands
)
if /I "%Type%"=="Docs" (
  set GitAddPath=Translation/user_docs
  set TranslationPath=%~dp0Translation\user_docs
)
set CrowdinFilePath=%FileName%
goto %Action%

Rem 生成翻译预览系列命令  
:GenerateFiles
if /I "%Type%" == "LC_MESSAGES" (
  IF EXIST "%~dp0Preview\%ShortName%.mo" (del /f /q "%~dp0Preview\%ShortName%.mo")
  IF EXIST "%TranslationPath%\%ShortName%.mo" (del /f /q "%TranslationPath%\%ShortName%.mo")
  "%~dp0Tools\msgfmt.exe" -o "%~dp0Preview\%ShortName%.mo" "%TranslationPath%\%FileName%"
  set ExitCode=!errorlevel!
  MKLINK /H "%TranslationPath%\%ShortName%.mo" "%~dp0Preview\%ShortName%.mo"
)
if /I "%Type%" == "Docs" (
  IF EXIST "%~dp0Preview\%ShortName%.html" (del /f /q "%~dp0Preview\%ShortName%.html")
  %L10nUtil% xliff2html -t %ShortName% "%TranslationPath%\%FileName%" "%~dp0Preview\%ShortName%.html"
  set ExitCode=!errorlevel!
)
goto Quit

Rem 生成 NVDA 翻译目录结构  
:TranslationTest
IF EXIST "%~dp0Preview\Test" (rd /s /q "%~dp0Preview\Test")
MKDir "%~dp0Preview\Test\locale\zh_CN\LC_MESSAGES"
MKLINK /H "%~dp0Preview\Test\locale\zh_CN\LC_MESSAGES\nvda.mo" "%~dp0Preview\nvda.mo"
for %%f in (
  characterDescriptions.dic
  gestures.ini
  symbols.dic
) do (
  MKLINK /H "%~dp0Preview\Test\locale\zh_CN\%%f" "%~dp0Translation\miscDeps\%%f"
)
MKDir "%~dp0Preview\Test\documentation\zh_CN"
for %%f in (
  favicon.ico
  numberedHeadings.css
  styles.css
  changes.html
  keyCommands.html
  userGuide.html
) do (
MKLINK /H "%~dp0Preview\Test\documentation\zh_CN\%%f" "%~dp0Preview\%%f"
)
if /I "%Type%" == "Test" (
  set ExitCode=%errorlevel%
  goto Quit
)

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
set ExitCode=%errorlevel%
goto Quit

Rem GET 和 GEZ 命令的文件生成阶段以及 A 系列命令：通过循环调用另一个L10nUtilTools.bat来分别处理  
:CallForEach
for %%i in (%CallForEachParameter%) do (
  cmd /C "%~dp0L10nUtilTools" %Parameter%%%i
  if !errorlevel! neq 0 (
    echo Error: Command %Parameter%%%i failed with exit code !errorlevel!.
    exit /b !errorlevel!
  )
)
if /I "%Action%" == "GenerateFiles" (goto TranslationTest)
if /I "%Action%" == "DownloadAndCommit" (goto Commit)
exit /b %errorlevel%

Rem 生成文档的 Markdown 版本
:GenerateMarkdown
IF NOT EXIST "%~dp0Preview\Markdown" (MKDir "%~dp0Preview\Markdown")
IF EXIST "%~dp0Preview\Markdown\%ShortName%.md" (del /f /q "%~dp0Preview\Markdown\%ShortName%.md")
%L10nUtil% xliff2md "%TranslationPath%\%FileName%" "%~dp0Preview\Markdown\%ShortName%.md"
set ExitCode=!errorlevel!
goto Quit

Rem 从 Markdown 文件生成 HTML 文件  
:GenerateHTML
IF NOT EXIST "%~dp0Preview\Markdown\%ShortName%.md" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('未找到 %ShortName%.md，请先生成该文件后重试。',5,'错误');window.close();"
  exit /b 1
)
IF EXIST "%~dp0Preview\%ShortName%.html" (del /f /q "%~dp0Preview\%ShortName%.html")
%L10nUtil% md2html -l zh_CN -t %ShortName% "%~dp0Preview\Markdown\%ShortName%.md" "%~dp0Preview\%ShortName%.html"
set ExitCode=!errorlevel!
goto Quit

Rem 从 Markdown 文档生成 xliff
:GenerateXLIFF
set NVDASourceCodePath=%~dp0Tools\NVDA
IF NOT EXIST "%NVDASourceCodePath%" (
  set PromptInformation=请输入您的本地 NVDA 源代码存储库路径（无需引号），按回车键确认。  
  set TargetPath=%NVDASourceCodePath%
  set VerifyFile=source\markdownTranslate.py
  set PathSetSuccessfully=NVDASourceCodePathSetSuccessfully
  goto SetPersonalSourcePath
)
:NVDASourceCodePathSetSuccessfully
powershell -ExecutionPolicy Bypass -NoProfile -File "%NVDASourceCodePath%\ensureuv.ps1" --directory "%NVDASourceCodePath%" sync
if %errorlevel% neq 0 (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('NVDA 代码仓库的 Python 环境配置失败，有关详细信息，请查看命令窗口。',5,'错误');window.close();"
  echo 请按任意键退出...
  Pause>Nul
  exit /b 1
)
IF NOT EXIST "%~dp0Preview\Markdown\%ShortName%.md" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('未找到 %ShortName%.md，请先创建该文件后重试。',5,'错误');window.close();"
  exit /b 1
)
move /Y "%TranslationPath%\%FileName%" "%~dp0PotXliff\%FileName%"
uv --directory "%NVDASourceCodePath%" run "%NVDASourceCodePath%\source\markdownTranslate.py" translateXliff -x "%NVDASourceCodePath%\user_docs\en\%FileName%" -l zh-CN -p "%~dp0Preview\Markdown\%ShortName%.md" -o "%TranslationPath%\%FileName%"
set ExitCode=%errorlevel%
goto Quit

Rem 从 Crowdin 下载已翻译的文件  
:DownloadFiles
:DownloadAndCommit
set DownloadFilename=%TranslationPath%\%FileName%
IF EXIST "%DownloadFilename%" (del /f /q "%DownloadFilename%")
%L10nUtil% downloadTranslationFile zh-CN "%CrowdinFilePath%" "%DownloadFilename%"
if %errorlevel% neq 0 (
  echo Error: %FileName% download failed with exit code %errorlevel%.
  set ExitCode=%errorlevel%
  Git restore "%GitAddPath%/%FileName%"
  goto Quit
)
if /I "%Type%"=="LC_MESSAGES" (
powershell -ExecutionPolicy Bypass -File "%~dp0Tools\CheckPo.ps1" "%DownloadFilename%"
)
if /I "%Action%"=="DownloadAndCommit" (goto Commit)
exit /b 0

Rem 将下载的翻译文件提交到存储库  
:Commit
if /I "%Type%"=="All" (
  set AddFileList="Translation/LC_MESSAGES/*.po" "Translation/user_docs/*.xliff"
  set CommitMSG=更新翻译（从 Crowdin）
) else (
  set AddFileList="%GitAddPath%/%FileName%"
  set CommitMSG=更新 %FileName%（从 Crowdin）
)
git add %AddFileList%
git diff --cached --quiet
if %errorlevel% neq 0 (
  git commit -m "%CommitMSG%"
) else (
  echo No changes to commit, skipping commit.
)
exit /b 0

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
if /I "%Type%"=="Docs" (
  goto ReadyUpload
) else (
  set Parameter= 
)
:Upload
%L10nUtil% uploadTranslationFile zh-CN "%CrowdinFilePath%" "%TranslationPath%\%FileName%" %Parameter%
set ExitCode=%errorlevel%
goto Quit

Rem 处理针对插件翻译的标签，初始化变量  
:GMX
:MXX
:UAP
:UAX
:DAP
:DAX
set AddonName=%2
if not defined AddonName (
  cls
  echo 请输入插件 ID，按回车键确认。  
  set /p AddonName=
)
set CrowdinRegistrationSourcePath=%~dp0Tools\CrowdinRegistration
IF NOT EXIST "%CrowdinRegistrationSourcePath%" (
  set PromptInformation=请输入您的本地 CrowdinRegistration 存储库路径（无需引号），按回车键确认。  
  set TargetPath=%CrowdinRegistrationSourcePath%
  set VerifyFile=utils\l10nUtil.py
  set PathSetSuccessfully=CrowdinRegistrationPathSetSuccessfully
  goto SetPersonalSourcePath
)
:CrowdinRegistrationPathSetSuccessfully
set L10nUtil=uv --directory "%CrowdinRegistrationSourcePath%" run "%CrowdinRegistrationSourcePath%\utils\l10nUtil.py"
if NOT "%GITHUB_ACTIONS%" == "true" (
  uv --directory "%CrowdinRegistrationSourcePath%" sync
  if !errorlevel! neq 0 (
    mshta "javascript:new ActiveXObject('wscript.shell').popup('CrowdinRegistration 存储库的 Python 环境配置失败，有关详细信息，请查看命令窗口。',5,'错误');window.close();"
    echo 请按任意键退出...
    Pause>Nul
    exit /b 1
  )
  cls
)
if /I "%CLI:~0,2%"=="GM" (set Action=GenerateMarkdown)
if /I "%CLI%"=="MXX" (set Action=GenerateAddonXLIFF)
if /I "%CLI:~0,2%"=="DA" (set Action=DownloadFiles)
if /I "%CLI:~0,2%"=="UA" (set Action=UploadFiles)
if /I "%CLI:~2,1%"=="P" (
  set Type=LC_MESSAGES
  set CrowdinFilePath=%AddonName%.pot
  set FileName=nvda.po
)
if /I "%CLI:~2,1%"=="X" (
  set CrowdinFilePath=%AddonName%.xliff
  set FileName=readme.xliff
  set ShortName=readme
)
set TranslationPath=%~dp0Translation\Addons\%AddonName%
IF NOT EXIST "%TranslationPath%" (MKDir "%TranslationPath%")
goto %Action%

Rem 从插件的 Markdown 文档生成 xliff
:GenerateAddonXLIFF
Python "%CrowdinRegistrationSourcePath%\utils\markdownTranslate.py" translateXliff -x "%CrowdinRegistrationSourcePath%\%AddonName%\%AddonName%.xliff" -l zh-CN -p "%~dp0Preview\Markdown\readme.md" -o "%~dp0PotXliff\%AddonName%.xliff"
set ExitCode=%errorlevel%
if %ExitCode% neq 0 (goto Quit)
move /Y "%~dp0PotXliff\%AddonName%.xliff" "%TranslationPath%\%FileName%"
exit /b 0

Rem 设置本地存储库路径  
:SetPersonalSourcePath
cls
echo %PromptInformation%
set /p PersonalSourcePath=
IF NOT EXIST "%PersonalSourcePath%\%VerifyFile%" (
  set PromptInformation=存储库路径输入错误，请重新输入。  
  goto SetPersonalSourcePath
)
MKLINK /J "%TargetPath%" "%PersonalSourcePath%"
goto %PathSetSuccessfully%

Rem 清理本工具生成的所有文件  
:CLE
git clean -fX "%~dp0PotXliff"
git clean -fX "%~dp0Preview"
git clean -fX "%~dp0Translation\Addons"
set ExitCode=%errorlevel%
goto Quit

Rem 处理退出代码  
:Quit
if /I "%GITHUB_ACTIONS%" == "true" (exit /b %ExitCode%)
if %ExitCode% neq 0 (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('某些操作未能成功完成，有关详细信息，请查看命令窗口。',5,'错误');window.close();"
  echo 请按任意键退出...
  Pause>Nul
  exit /b %ExitCode%
)
exit /b 0
