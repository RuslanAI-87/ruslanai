@echo off
echo ============================================================
echo  RuslanAI - Test API with Memory System
echo ============================================================
echo.
echo This script will test the API server with memory integration
echo by sending a series of related messages and checking if the
echo system remembers previous information.
echo.
echo IMPORTANT: Make sure the API server is running before this test!
echo.

:: Set UTF-8 for console
chcp 65001

:: Set environment variables
set PYTHONIOENCODING=utf-8

:: Create logs directory if it doesn't exist
mkdir logs 2>nul

:: Run the test script
python test_api_with_memory.py

echo.
echo Test complete! Check logs/api_memory_test.log for detailed results.
echo.
pause