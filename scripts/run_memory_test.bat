@echo off
echo ================================================================
echo  RuslanAI - Memory System Test Suite
echo ================================================================
echo.

:: Set UTF-8 for console
chcp 65001

:: Run the Python-based test setup script
python "%~dp0\memory_test_setup.py"

if %ERRORLEVEL% NEQ 0 (
    echo Error running memory test setup script. 
    echo Please check that Python is installed and in your PATH.
    pause
    exit /b 1
)

pause
exit /b 0