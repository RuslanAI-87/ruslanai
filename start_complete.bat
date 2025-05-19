@echo off
echo === Starting Complete RuslanAI System ===
echo.

:: Kill any existing processes
taskkill /f /im python.exe > nul 2>&1
taskkill /f /im node.exe > nul 2>&1
timeout /t 2 > nul

:: Start the API server
echo 1. Starting API server...
start cmd /k "title RuslanAI API && cd C:\RuslanAI\central_agent\backend && python improved_api.py"

:: Wait for API server to start
echo Waiting for API server to start...
timeout /t 5 > nul

:: Start the web interface
echo 2. Starting web interface...
start cmd /k "title RuslanAI Web UI && cd C:\RuslanAI\web_ui && npm run dev"

:: Wait for web interface to start
echo Waiting for web interface to start...
timeout /t 10 > nul

:: Open browser
echo 3. Opening browser...
start "" "http://localhost:3000"

echo.
echo System should now be fully running:
echo - API Server: http://localhost:8001
echo - Web Interface: http://localhost:3000
echo.
echo Check both console windows for any error messages.
