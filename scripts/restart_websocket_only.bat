@echo off
echo Restarting WebSocket server with improved JSON parsing...

REM Kill existing node processes running the WebSocket server
FOR /F "tokens=1,2" %%A IN ('tasklist /fi "imagename eq node.exe" /fo csv /nh') DO (
  wmic process where "name='node.exe' and processid=%%~B" get commandline | findstr "simple_websocket_server.js" >nul
  IF NOT ERRORLEVEL 1 (
    echo Stopping WebSocket server process (PID: %%~B)...
    taskkill /F /PID %%~B /T
  )
)

REM Start the WebSocket server
echo Starting WebSocket server with improved integration...
cd /d "%~dp0..\scripts"
start /b node simple_websocket_server.js

echo WebSocket server restarted!
echo Server is running at http://localhost:8001
echo WebSocket endpoint is available at ws://localhost:8001/ws