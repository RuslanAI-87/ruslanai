@echo off
echo ===============================================================
echo  RuslanAI - Correct Path Test Launcher
echo ===============================================================
echo.

:: Set UTF-8 for console
chcp 65001

:: Change to the correct directory first
cd /d C:\RuslanAI

echo Current directory: %CD%
echo.

echo ---------------------------------------------------------------
echo Now running test_api_with_memory.py from the correct directory
echo ---------------------------------------------------------------

:: Set environment variables
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

:: Create logs directory if it doesn't exist
mkdir logs 2>nul

:: Run the test script
python test_api_with_memory.py

echo.
echo Test complete! Check logs/api_memory_test.log for detailed results.
echo.
pause