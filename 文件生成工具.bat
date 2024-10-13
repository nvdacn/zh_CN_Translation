@echo off

IF not EXIST "%~dp0Tools\nvdaL10nUtil.exe" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('�ļ� nvdaL10nUtil.exe �����ڣ������ظó��򲢽��临�Ƶ� Tools �ļ��к����ԡ�',5,'�ļ�������');window.close();"
Exit
)

if not "%1"=="" (
set CLI=%1
goto goto
)

cls
echo ��ӭʹ���ļ����ɹ��ߣ���ѡ��Ҫ���ɵ��ļ������س���ִ�С�
echo C�����ɸ�����־��html�ļ���
echo u�������û�ָ�ϵ�html�ļ���
echo K�������ȼ����ٲο���html�ļ���
echo D�����������ĵ���html�ļ���
echo L�����ɽ��淭���mo�ļ�
echo T�����ɷ�������ļ�����ѹ����
echo Z�����ɷ�������ļ���ѹ����
echo STC�����ɿ�ֱ���ϴ���Crowdin��changes�ĵ�����Ҫ��ԭʼxliff�ļ�����洢���Crowdin\OldXLIFF�ļ����£���δ��⵽���ļ���ϵͳ��Ӵ洢���main��֧��ȡ��
echo STU�����ɿ�ֱ���ϴ���Crowdin��userGuide�ĵ�����Ҫ��ԭʼxliff�ļ�����洢���Crowdin\OldXLIFF�ļ����£���δ��⵽���ļ���ϵͳ��Ӵ洢���main��֧��ȡ��
echo CLE�����������������ɵ������ļ���
echo ��������˳������ߡ�
echo ����ѡ���ͨ��������ֱ�Ӵ��롣

set /p CLI=

:goto
goto %CLI%

:C
:D
:T
:Z
IF EXIST "%~dp0Preview\changes.html" (del /f /q "%~dp0Preview\changes.html")
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t changes "%~dp0Translation\user_docs\changes.xliff" "%~dp0Preview\changes.html"
if /I "%CLI%"=="C" (Exit)

:U
IF EXIST "%~dp0Preview\userGuide.html" (del /f /q "%~dp0Preview\userGuide.html")
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t userGuide "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\userGuide.html"
if /I "%CLI%"=="U" (Exit)

:K
IF EXIST "%~dp0Preview\keyCommands.html" (del /f /q "%~dp0Preview\keyCommands.html")
"%~dp0Tools\nvdaL10nUtil.exe" xliff2html -t keyCommands "%~dp0Translation\user_docs\userGuide.xliff" "%~dp0Preview\keyCommands.html"
if /I "%CLI%"=="K" (Exit)
if /I "%CLI%"=="D" (Exit)

:L
IF EXIST "%~dp0Preview\nvda.mo" (del /f /q "%~dp0Preview\nvda.mo")
"%~dp0Tools\msgfmt.exe" -o "%~dp0Preview\nvda.mo" "%~dp0Translation\LC_MESSAGES\nvda.po"
if /I "%CLI%"=="L" (Exit)

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

for /f "delims=" %%o in ('git branch --show-current') do set Branch=%%o

set DateTime=%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%

If "%DateTime:~4,1%" == " " (
  set VersionInfo=%DateTime:~0,4%0%DateTime:~5,3%
) Else (
  set VersionInfo=%DateTime%
)

IF EXIST "%~dp0Preview\Archive" (rd /s /q "%~dp0Preview\Archive")
"%~dp0Tools\7Zip\7z.exe" a -sccUTF-8 -y -tzip "%~dp0Preview\Archive\NVDA_%Branch%_������ԣ���ѹ��NVDA�����ļ��У�_%VersionInfo%.zip" "%~dp0Preview\Test\documentation" "%~dp0Preview\Test\locale"
if /I "%CLI%"=="Z" (Exit)

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

:ST
IF EXIST "%~dp0Crowdin\OldXLIFF\Temp" (
rd /s /q "%~dp0Crowdin\OldXLIFF\Temp"
)

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

:CLE
rd /s /q "%~dp0Crowdin"
rd /s /q "%~dp0Preview"
Git restore Crowdin/* Preview/*

Exit
