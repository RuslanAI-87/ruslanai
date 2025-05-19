@echo off
echo Starting cmd.exe with persistent window...
start cmd.exe /k "cd /d "%~dp0scripts" && echo Current directory: %CD% && echo. && echo Installing ws package... && npm install ws && echo. && echo Starting minimal server... && node minimal_websocket.js"
echo Command window should remain open even if there are errors.
echo.