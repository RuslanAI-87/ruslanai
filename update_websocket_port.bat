@echo off
echo Updating WebSocket port in the web UI configuration...
echo.

cd /d "%~dp0scripts"
node update_websocket_port.js

echo.
echo Done. Press any key to continue...
pause