@echo off
echo === Starting Simple RuslanAI System ===
echo.

:: Kill any existing Python processes
taskkill /f /im python.exe > nul 2>&1
timeout /t 2 > nul

:: Start the simple API server
echo Starting API server...
start cmd /k "title RuslanAI API && cd C:\RuslanAI\central_agent\backend && python simple_api.py"

:: Wait for API server to start
echo Waiting for API server to start...
timeout /t 5 > nul

:: Launch browser to the web interface
echo Opening web interface...
start "" "http://localhost:3000"

echo.
echo System started:
echo - API Server should be running on port 8001
echo - Web Interface should open at http://localhost:3000
echo.
echo If you see connection errors in the web interface, the API server may not be running correctly.
echo Check the API server console window for error messages.
