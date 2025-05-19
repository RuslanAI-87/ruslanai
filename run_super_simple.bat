@echo off
REM Open a new CMD window with the simplest possible server
start cmd /k "cd /d C:\RuslanAI\scripts && npm install ws && node super_simple_server.js"
echo A command window has been opened with the super simple server.
echo Look for it in your taskbar or minimized windows.