@echo off
REM Complete Fix for RuslanAI Web Interface
REM This batch file fixes duplicate React imports and WebSocket connection issues

echo ==== RuslanAI Web Interface Fix ====
echo.
echo This script will fix:
echo 1. Duplicate React imports that cause build errors
echo 2. WebSocket connection stability issues
echo 3. Cyrillic text encoding issues
echo.
echo Please wait while we apply the fixes...
echo.

REM Step 1: Stop running processes
echo Stopping running processes...
taskkill /F /IM node.exe > nul 2>&1
taskkill /F /IM npm.exe > nul 2>&1
taskkill /F /IM python.exe > nul 2>&1
timeout /t 2 > nul

REM Step 2: Fix duplicate React imports
echo Fixing duplicate React imports...
python "%~dp0fix_duplicate_react.py"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to fix React imports.
    goto error
)
echo React imports fixed successfully.
echo.

REM Step 3: Add ping-pong support to API server
echo Adding WebSocket ping-pong support to API server...
python "%~dp0simple_api_ping.py"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to add ping-pong support to API server.
    goto error
)
echo WebSocket ping-pong support added successfully.
echo.

REM Step 4: Fix Cyrillic text encoding in RuslanAI.jsx
echo Fixing Cyrillic text encoding in RuslanAI.jsx...
python "%~dp0fix_ruslanai_encoding.py"
if %ERRORLEVEL% neq 0 (
    echo WARNING: Failed to fix Cyrillic encoding, but continuing...
)
echo.

REM Step 5: Start the services
echo Starting API server...
start cmd /c "cd C:\RuslanAI && python -m central_agent.backend.encoding_fixed_api"
timeout /t 5 > nul

echo Starting web UI...
start cmd /c "cd C:\RuslanAI\web_ui && npm run dev"
timeout /t 5 > nul

REM Step 6: Create startup script
echo @echo off > "%~dp0..\start_fixed_system.bat"
echo echo Starting RuslanAI system... >> "%~dp0..\start_fixed_system.bat"
echo taskkill /F /IM node.exe ^> nul 2^>^&1 >> "%~dp0..\start_fixed_system.bat"
echo taskkill /F /IM npm.exe ^> nul 2^>^&1 >> "%~dp0..\start_fixed_system.bat"
echo taskkill /F /IM python.exe ^> nul 2^>^&1 >> "%~dp0..\start_fixed_system.bat"
echo timeout /t 2 ^> nul >> "%~dp0..\start_fixed_system.bat"
echo start cmd /c "cd C:\RuslanAI ^&^& python -m central_agent.backend.encoding_fixed_api" >> "%~dp0..\start_fixed_system.bat"
echo timeout /t 5 ^> nul >> "%~dp0..\start_fixed_system.bat"
echo start cmd /c "cd C:\RuslanAI\web_ui ^&^& npm run dev" >> "%~dp0..\start_fixed_system.bat"
echo timeout /t 5 ^> nul >> "%~dp0..\start_fixed_system.bat"
echo start http://localhost:5173 >> "%~dp0..\start_fixed_system.bat"
echo echo RuslanAI system started successfully. >> "%~dp0..\start_fixed_system.bat"
echo echo Web interface at: http://localhost:5173 >> "%~dp0..\start_fixed_system.bat"

echo Created startup script: C:\RuslanAI\start_fixed_system.bat
echo.

REM Step 7: Open the web UI
echo Opening web UI in browser...
timeout /t 2 > nul
start http://localhost:5173

echo.
echo ==== Fix Complete ====
echo.
echo If the web UI doesn't load properly:
echo 1. Wait 30 seconds and refresh the page
echo 2. If still not working, run C:\RuslanAI\start_fixed_system.bat
echo 3. Check the logs in C:\RuslanAI\logs for errors
echo.
echo Press any key to exit...
pause > nul
exit /b 0

:error
echo.
echo An error occurred during the fix process.
echo Please check the logs in C:\RuslanAI\logs for details.
echo.
echo Press any key to exit...
pause > nul
exit /b 1