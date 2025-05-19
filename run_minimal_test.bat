@echo off
echo This is a minimal WebSocket test
cd /d "%~dp0scripts"

echo Current directory: %CD%
echo.

REM Try to ensure Node.js is properly detected
echo Checking Node.js...
where node

REM Attempt to install required packages
echo.
echo Installing ws package...
call npm install ws

echo.
echo Starting minimal WebSocket server...
REM Redirect output to a log file to capture errors
node minimal_websocket.js > "%~dp0websocket_log.txt" 2>&1
echo.

echo Server process exited with code %ERRORLEVEL%
echo Check websocket_log.txt for details
echo.
pause