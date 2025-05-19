@echo off
echo ------------------------------------------------------
echo RuslanAI WebSocket Server - Fixed Version
echo ------------------------------------------------------
echo.

echo Checking Node.js installation...
where node
if %ERRORLEVEL% NEQ 0 (
  echo Node.js not found in PATH! Please install Node.js.
  goto :error
)

echo.
echo Node.js version:
node --version
if %ERRORLEVEL% NEQ 0 (
  echo Error running Node.js! Please check your installation.
  goto :error
)

echo.
echo Current directory: %CD%
echo Changing to scripts directory...
cd /d "%~dp0scripts"
echo New directory: %CD%

echo.
echo Installing required packages...
call npm install ws uuid
if %ERRORLEVEL% NEQ 0 (
  echo Error installing npm packages!
  goto :error
)

echo.
echo Checking for running WebSocket processes...
FOR /F "tokens=1,2" %%A IN ('tasklist /fi "imagename eq node.exe" /fo csv /nh') DO (
  wmic process where "name='node.exe' and processid=%%~B" get commandline 2>nul | findstr "websocket_server.js" >nul
  IF NOT ERRORLEVEL 1 (
    echo Found WebSocket server running (PID: %%~B) - stopping it...
    taskkill /F /PID %%~B /T
  )
)

echo.
echo Starting WebSocket server with auto port selection...
echo The server will find an available port automatically.
echo.
echo IMPORTANT: This window must remain open for the server to work.
echo DO NOT CLOSE THIS WINDOW while using the RuslanAI system.
echo.
echo Starting server...

node robust_websocket_server.js
if %ERRORLEVEL% NEQ 0 (
  echo WebSocket server exited with error code %ERRORLEVEL%
  goto :error
)

goto :end

:error
echo.
echo ------------------------------------------------------
echo ERROR! WebSocket server failed to start properly.
echo ------------------------------------------------------
echo.
echo Please check for these common issues:
echo  1. Is Node.js properly installed? (should show version above)
echo  2. Is another service using the same ports?
echo  3. Do you have admin rights to start servers?
echo.
echo Check the error messages above for more details.

:end
echo.
pause