@echo off

IF not EXIST "%~dp0Tools\nvdaL10nUtil.exe" (
  mshta "javascript:new ActiveXObject('wscript.shell').popup('�ļ� nvdaL10nUtil.exe �����ڣ������ظó��򲢽��临�Ƶ� Tools �ļ��к����ԡ�',5,'�ļ�������');window.close();"
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
echo A�����������ĵ���html�ļ���
echo ��������˳������ߡ�
echo ����ѡ���ͨ��������ֱ�Ӵ��롣

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
