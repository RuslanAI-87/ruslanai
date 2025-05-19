@echo off
echo ========================================
echo RuslanAI Startup Script
echo ========================================

:: Set console code page to UTF-8
chcp 65001

:: Set environment variables for proper encoding
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

:: Ensure all necessary directories exist
echo Creating necessary directories...
mkdir C:\RuslanAI\logs 2>nul
mkdir C:\RuslanAI\data\vector_store 2>nul

:: Install required dependencies if not present
echo Checking for required dependencies...
python -m pip install --quiet sentence-transformers chromadb torch fastapi uvicorn pydantic

:: First run a quick test to verify memory system is working
echo Testing memory system...
python C:\RuslanAI\test_memory.py

:: Prompt user to continue if test was successful
echo.
set /p continue=Do you want to start the API server? (Y/N): 

if /i "%continue%"=="Y" (
    echo.
    echo Starting RuslanAI Direct API server
    cd C:\RuslanAI\central_agent\backend
    start cmd /k "title RuslanAI API Server && python direct_api.py"
    
    echo.
    echo RuslanAI started successfully\!
    echo API server is running at http://localhost:8001
    echo.
    echo Documentation available at:
    echo - C:\RuslanAI\MEMORY_SYSTEM.md
    echo - C:\RuslanAI\MEMORY_SYSTEM_REPORT.md
) else (
    echo.
    echo Startup canceled.
)

pause
