@echo off
echo === Starting RuslanAI System with UTF-8 Fix ===
echo.

:: Kill any existing processes
taskkill /f /im python.exe > nul 2>&1
timeout /t 2 > nul

:: Start the API server with encoding fix
echo 1. Starting API server with UTF-8 encoding fix...
start cmd /k "title RuslanAI API (UTF-8 fixed) && cd C:\RuslanAI\central_agent\backend && python encoding_fixed_api.py"

:: Wait for API server to start
echo Waiting for API server to start...
timeout /t 5 > nul

echo.
echo API Server should now be running with UTF-8 encoding:
echo - API Server: http://localhost:8001
echo.
echo Перезагрузите веб-интерфейс по адресу http://localhost:3000
echo.
