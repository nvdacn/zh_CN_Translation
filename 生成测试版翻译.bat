@echo off

chcp 65001

Rem 生成所需环境变量
for /f "delims=" %%o in ('git branch --show-current') do set Branch=%%o
if "%1" == "GITHUB_ACTIONS" (
  @echo on
  set DateTime=%date:~-10,2%%date:~-7,2%%time:~0,2%%time:~3,2%
) else (
  set DateTime=%date:~8,2%%date:~11,2%%time:~0,2%%time:~3,2%
)
If "%DateTime:~4,1%" == " " (
  set VersionInfo=%DateTime:~0,4%0%DateTime:~5,3%
) Else (
  set VersionInfo=%DateTime%
)

Rem 清理可能存在的临时文件
IF EXIST "%~dp0Preview\Output" (rd /s /q "%~dp0Preview\Output")
IF EXIST "%~dp0Preview\Archive" (rd /s /q "%~dp0Preview\Archive")

Rem 生成界面翻译测试文件
MKDir "%~dp0Preview\Output\locale\zh_CN\LC_MESSAGES"
"%~dp0Tools\msgfmt.exe" -o "%~dp0Preview\Output\locale\zh_CN\LC_MESSAGES\nvda.mo" "%~dp0Translation\LC_MESSAGES\nvda.po"

Rem 生成文档翻译测试文件
Rem 由于nvdaL10nUtil暂未上传到存储库，故此部分暂时无效
::Start /Wait /D "%~dp0" 为已翻译文档生成html文件.bat
MKDir "%~dp0Preview\Output\documentation\zh_CN"
MKLINK /H "%~dp0Preview\Output\documentation\zh_CN\numberedHeadings.css" "%~dp0Preview\numberedHeadings.css"
MKLINK /H "%~dp0Preview\Output\documentation\zh_CN\styles.css" "%~dp0Preview\styles.css"
::MKLINK /H "%~dp0Preview\Output\documentation\zh_CN\changes.html" "%~dp0Preview\changes.html"
::MKLINK /H "%~dp0Preview\Output\documentation\zh_CN\keyCommands.html" "%~dp0Preview\keyCommands.html"
::MKLINK /H "%~dp0Preview\Output\documentation\zh_CN\userGuide.html" "%~dp0Preview\userGuide.html"

Rem 创建压缩包
"%~dp0Tools\7Zip\7z.exe" a -sccUTF-8 -y -tzip "%~dp0Preview\Archive\NVDA_%Branch%_翻译测试（解压到NVDA程序文件夹）_%VersionInfo%.zip" "%~dp0Preview\Output\documentation" "%~dp0Preview\Output\locale"

Exit
