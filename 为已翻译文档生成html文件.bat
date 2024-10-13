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
echo ��ѡ��Ҫ���ɵ��ļ������س���ִ�С�
echo C�����ɸ�����־��html�ļ���
echo u�������û�ָ�ϵ�html�ļ���
echo K�������ȼ����ٲο���html�ļ���
echo DOC�����������ĵ���html�ļ���
echo STC�����ɿ�ֱ���ϴ���Crowdin��changes�ĵ�����Ҫ��ԭʼxliff�ļ�����洢���Crowdin\OldXLIFF�ļ����£���δ��⵽���ļ���ϵͳ��Ӵ洢���Ĭ�Ϸ�֧��ȡ��
echo STU�����ɿ�ֱ���ϴ���Crowdin��userGuide�ĵ�����Ҫ��ԭʼxliff�ļ�����洢���Crowdin\OldXLIFF�ļ����£���δ��⵽���ļ���ϵͳ��Ӵ洢���Ĭ�Ϸ�֧��ȡ��
echo ��������˳������ߡ�
echo ����ѡ���ͨ��������ֱ�Ӵ��롣

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
