@echo off
echo === Testing Direct API without WebSocket ===
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js not found. Please install Node.js to run this test.
    exit /b 1
)

REM Install required dependencies if not already installed
echo Checking for required Node.js dependencies...
cd /d "%~dp0.."

if not exist node_modules\node-fetch (
    echo Installing node-fetch...
    npm install --no-save node-fetch@2 form-data
) else (
    echo Dependencies already installed.
)

echo.
echo Running API test...
echo.

node scripts/test_direct_api.js

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Test failed with errors.
    exit /b 1
) else (
    echo.
    echo All tests completed successfully!
)

echo.
echo Direct API is working correctly without WebSocket!
echo.
pause