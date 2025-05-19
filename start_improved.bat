@echo off
echo === Starting Improved RuslanAI System ===
echo.

:: Kill any existing Python processes
taskkill /f /im python.exe > nul 2>&1
timeout /t 2 > nul

:: Start the improved API server
echo Starting improved API server...
start cmd /k "title RuslanAI Improved API && cd C:\RuslanAI\central_agent\backend && python improved_api.py"

:: Wait for API server to start
echo Waiting for API server to start...
timeout /t 5 > nul

:: Launch browser to the web interface
echo Opening web interface...
start "" "http://localhost:3000"

echo.
echo System started:
echo - Improved API Server should be running on port 8001
echo - Web Interface should open at http://localhost:3000
echo.
echo Check the API server console window for logs and errors.
