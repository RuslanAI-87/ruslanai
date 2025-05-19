@echo off
echo Updating RuslanAI to Direct API mode (without WebSocket)...
echo.

echo Creating backups of current files...
cd /d C:\RuslanAI\web_ui\src\components
copy RuslanAI.jsx RuslanAI.jsx.bak_websocket
cd /d C:\RuslanAI\web_ui\src\services
copy agentService.js agentService.js.bak_websocket
copy websocketService.js websocketService.js.bak_websocket
cd /d C:\RuslanAI\central_agent\backend
if exist encoding_fixed_api.py (
  copy encoding_fixed_api.py encoding_fixed_api.py.bak_websocket
)
echo Backups created.
echo.

echo Applying new files...
cd /d C:\RuslanAI\web_ui\src\components
copy RuslanAI.jsx.new RuslanAI.jsx
cd /d C:\RuslanAI\web_ui\src\services
copy agentService.js.new agentService.js
echo New files applied.
echo.

echo Update completed!
echo.
echo To start the Direct API server:
echo  - Run scripts\start_direct_api.bat
echo.
echo To start the UI:
echo  - Run the regular UI start script
echo.
pause