@echo off
echo ===============================================================
echo  RuslanAI - Complete Memory System Test
echo ===============================================================
echo.

:: Set UTF-8 for console
chcp 65001

:: Change to the correct directory first
cd /d C:\RuslanAI

echo Current directory: %CD%
echo.

echo This script will:
echo  1. Check if the API server is running
echo  2. Test the vector store dependencies
echo  3. Run the API memory test
echo.

:: Set environment variables
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

:: Create logs directory if it doesn't exist
mkdir logs 2>nul

echo ---------------------------------------------------------------
echo Step 1: Checking if API server is running...
echo ---------------------------------------------------------------
curl -s http://localhost:8001/api/health > nul
if %ERRORLEVEL% NEQ 0 (
    echo API server is NOT running!
    echo Please start the API server first with start_api_with_memory.bat
    goto :end
) else (
    echo API server is running.
)
echo.

echo ---------------------------------------------------------------
echo Step 2: Checking vector store dependencies...
echo ---------------------------------------------------------------
python check_vector_dependencies.py > logs\check_dependencies.log
type logs\check_dependencies.log
echo.

echo ---------------------------------------------------------------
echo Step 3: Running API memory test...
echo ---------------------------------------------------------------
python test_api_with_memory.py
echo.

echo ===============================================================
echo Test sequence complete!
echo ===============================================================
echo.
echo Check the logs for detailed results.
echo.

:end
pause