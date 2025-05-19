@echo off
echo Starting Robust WebSocket Server with enhanced error handling...

REM Kill existing node processes running the WebSocket server
FOR /F "tokens=1,2" %%A IN ('tasklist /fi "imagename eq node.exe" /fo csv /nh') DO (
  wmic process where "name='node.exe' and processid=%%~B" get commandline 2>nul | findstr "websocket_server.js" >nul
  IF NOT ERRORLEVEL 1 (
    echo Stopping WebSocket server process (PID: %%~B)...
    taskkill /F /PID %%~B /T
  )
)

REM Start the robust WebSocket server
cd /d "%~dp0scripts"
echo Installing dependencies...
call npm install ws uuid

echo Starting robust WebSocket server...
node robust_websocket_server.js

REM If we reach this point, the server has stopped
echo Server stopped with error code %ERRORLEVEL%
echo Press any key to exit...
pause