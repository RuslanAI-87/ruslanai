@echo off
echo DEBUG MODE - WINDOW WILL STAY OPEN
echo.

REM Save current directory
set ORIG_DIR=%CD%

REM Create debug log file
echo Starting debug log > "%~dp0debug_start.log"
echo Current directory: %CD% >> "%~dp0debug_start.log"
echo Time: %TIME% >> "%~dp0debug_start.log"
echo Date: %DATE% >> "%~dp0debug_start.log"

REM Echo commands to debug log
echo Checking Node.js... >> "%~dp0debug_start.log"
where node >> "%~dp0debug_start.log" 2>&1

REM Echo detailed error information
echo ERRORLEVEL after where: %ERRORLEVEL% >> "%~dp0debug_start.log"

REM Check Node.js version
echo Checking Node.js version... >> "%~dp0debug_start.log"
node --version >> "%~dp0debug_start.log" 2>&1
echo ERRORLEVEL after version: %ERRORLEVEL% >> "%~dp0debug_start.log"

REM Try to change directory
echo Trying to change directory to scripts... >> "%~dp0debug_start.log"
cd /d "%~dp0scripts" >> "%~dp0debug_start.log" 2>&1
echo ERRORLEVEL after cd: %ERRORLEVEL% >> "%~dp0debug_start.log"
echo New directory: %CD% >> "%~dp0debug_start.log"

REM Try to list files
echo Listing files in scripts directory... >> "%~dp0debug_start.log"
dir >> "%~dp0debug_start.log" 2>&1

REM Check if robust_websocket_server.js exists
echo Checking if robust_websocket_server.js exists... >> "%~dp0debug_start.log"
if exist "robust_websocket_server.js" (
  echo File exists >> "%~dp0debug_start.log"
) else (
  echo File does not exist >> "%~dp0debug_start.log"
)

REM Create a simple JavaScript test file
echo console.log('Simple test script running'); > simple_test.js
echo console.log('Node.js is working correctly'); >> simple_test.js
echo setTimeout(function() { console.log('Test complete'); }, 1000); >> simple_test.js

REM Run the simple test
echo Running simple JavaScript test... >> "%~dp0debug_start.log"
node simple_test.js >> "%~dp0debug_start.log" 2>&1
echo ERRORLEVEL after test: %ERRORLEVEL% >> "%~dp0debug_start.log"

REM Try to install packages
echo Installing packages... >> "%~dp0debug_start.log"
call npm install ws uuid >> "%~dp0debug_start.log" 2>&1
echo ERRORLEVEL after npm install: %ERRORLEVEL% >> "%~dp0debug_start.log"

REM Check if we can require modules
echo Creating module test script... >> "%~dp0debug_start.log"
echo try { > module_test.js
echo   const http = require('http'); >> module_test.js
echo   const WebSocket = require('ws'); >> module_test.js
echo   console.log('Modules loaded successfully'); >> module_test.js
echo } catch(e) { >> module_test.js
echo   console.error('Error loading modules:', e.message); >> module_test.js
echo } >> module_test.js

REM Run module test
echo Running module test... >> "%~dp0debug_start.log"
node module_test.js >> "%~dp0debug_start.log" 2>&1
echo ERRORLEVEL after module test: %ERRORLEVEL% >> "%~dp0debug_start.log"

REM Display log content to user
echo.
echo Debug log has been created. Here's what it contains:
echo.
type "%~dp0debug_start.log"
echo.

REM Now attempt to run the server
echo Attempting to run the server...
echo This will be logged to debug_server.log

REM Redirect server output to a file
node robust_websocket_server.js > "%~dp0debug_server.log" 2>&1

REM Check if server exited
echo Server process has exited with code %ERRORLEVEL%
echo Server log:
echo.
type "%~dp0debug_server.log"

REM Return to original directory
cd /d "%ORIG_DIR%"

echo.
echo Debug complete. Check the log files for more information.
echo Press any key to exit...
pause