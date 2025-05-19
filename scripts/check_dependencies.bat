@echo off
echo Checking Node.js dependencies...
cd /d "%~dp0..\scripts"
echo Installing required packages if missing...
npm install ws uuid
echo.
echo Checking if WebSocket server can be loaded...
node -e "try { require('./simple_websocket_server.js'); console.log('Script loaded successfully!'); } catch(e) { console.error('Error loading script:', e.message); }"
echo.
pause