@echo off
chcp 65001 > nul
echo === Starting Complete RuslanAI System ===
echo.

:: Stop existing processes
echo Stopping existing processes...
taskkill /f /im python.exe > nul 2>&1
taskkill /f /im node.exe > nul 2>&1
timeout /t 2 > nul

:: Start API server with encoding fix
echo 1. Starting API server...
start cmd /k "chcp 65001 && title RuslanAI API && cd C:\RuslanAI\central_agent\backend && python encoding_fixed_api.py"

:: Wait for API server to start
echo Waiting for API server...
timeout /t 5 > nul

:: Start web interface
echo 2. Starting web interface...
start cmd /k "chcp 65001 && title RuslanAI Web UI && cd C:\RuslanAI\web_ui && npm run dev"

:: Wait for web interface to start
echo Waiting for web UI...
timeout /t 10 > nul

:: Open browser
echo 3. Opening browser...
start "" "http://localhost:3000"

echo.
echo System started successfully:
echo - API Server: http://localhost:8001
echo - Web Interface: http://localhost:3000
echo.
echo Check both console windows for errors.
