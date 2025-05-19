@echo off
echo Starting WebSocket server in debug mode...
cd /d "%~dp0..\scripts"
node simple_websocket_server.js
echo Server stopped with error code %ERRORLEVEL%
pause