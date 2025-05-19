@echo off
REM This command will open a new CMD window and keep it open
start cmd /k "cd /d C:\RuslanAI\scripts && echo Current directory: %CD% && npm install ws uuid && node robust_websocket_server.js"
echo A command window has been opened. Please look for it in your taskbar.