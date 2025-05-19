@echo off
echo ============================================================
echo  RuslanAI - Fix Vector Store Imports
echo ============================================================
echo.
echo This script will fix import issues between memory_system.py
echo and vector_store.py to ensure proper integration.
echo.

:: Set UTF-8 for console
chcp 65001

:: Set environment variables
set PYTHONIOENCODING=utf-8

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