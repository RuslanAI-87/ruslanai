@echo off
echo ================================================================
echo  RuslanAI - Memory System Test (Administrator Mode)
echo ================================================================
echo.

echo This script will run the memory test with administrator privileges
echo to avoid permission issues with Python package installation.
echo.
echo Please click "Yes" when the UAC prompt appears.
echo.
pause

:: Self-elevate the script if not already running as administrator
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto GotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:GotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:: Run the Python script directly (more reliable than the batch wrapper)
python "%~dp0\memory_test_setup.py"

if %ERRORLEVEL% NEQ 0 (
    echo Error running memory test setup script. 
    echo Please check that Python is installed and in your PATH.
    pause
    exit /b 1
)

pause
exit /b 0