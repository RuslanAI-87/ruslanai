@echo off
echo Restarting WebSocket server with improved response parsing...

REM Find and stop existing node process running the WebSocket server
FOR /F "tokens=1,2" %%A IN ('tasklist /fi "imagename eq node.exe" /fo csv /nh') DO (
  wmic process where "name='node.exe' and processid=%%~B" get commandline 2>nul | findstr "websocket_server.js" >nul
  IF NOT ERRORLEVEL 1 (
    echo Stopping WebSocket server process (PID: %%~B)...
    taskkill /F /PID %%~B /T
  )
)

REM Start the WebSocket server
start cmd /k "cd /d C:\RuslanAI\scripts && node simple_websocket_server.js"

echo WebSocket server restarted! A new command window should be open with the server running.
echo.