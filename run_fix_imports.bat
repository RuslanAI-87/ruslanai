@echo off
echo ===============================================================
echo  RuslanAI - Fix Vector Store Imports (Correct Path)
echo ===============================================================
echo.

:: Set UTF-8 for console
chcp 65001

:: Change to the correct directory first
cd /d C:\RuslanAI

echo Current directory: %CD%
echo.

:: Set environment variables
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

:: Create logs directory if it doesn't exist
mkdir logs 2>nul

:: Run the fix script
python fix_vector_imports.py > logs\fix_vector_imports.log

:: Display the results
type logs\fix_vector_imports.log

echo.
echo Results saved to logs\fix_vector_imports.log
echo.
echo Now run start_api_with_memory.bat to start the API server.
echo.
pause