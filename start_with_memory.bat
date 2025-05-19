@echo off
echo ============================================================
echo  RuslanAI - Start API Server with Vector Memory Activated
echo ============================================================
echo.
echo This script will start the API server with vector memory enabled
echo.

:: Set UTF-8 for console
chcp 65001

:: Set environment variables
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

:: First test if memory system works correctly
echo Testing memory system integration...
python test_memory_integration.py > logs\memory_test_result.log
if %ERRORLEVEL% NEQ 0 (
    echo Error testing memory system! Check logs\memory_test_result.log for details.
    pause
    exit /b 1
)

echo Memory system test passed! Starting API server...
echo.

:: Start the API server directly with proper environment variables
cd C:\RuslanAI\central_agent\backend
python direct_api.py

pause