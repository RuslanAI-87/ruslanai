@echo off
echo ===============================================
echo = RuslanAI - Installation of Direct API Mode =
echo ===============================================
echo.

echo Step 1/6: Creating a backup of current files...
cd /d C:\RuslanAI
mkdir backup\direct_mode_install_%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2% 2>nul
set BACKUP_DIR=backup\direct_mode_install_%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%

if exist web_ui\src\components\RuslanAI.jsx (
  copy web_ui\src\components\RuslanAI.jsx %BACKUP_DIR%\RuslanAI.jsx.bak
)
if exist web_ui\src\services\agentService.js (
  copy web_ui\src\services\agentService.js %BACKUP_DIR%\agentService.js.bak
)
if exist web_ui\src\services\websocketService.js (
  copy web_ui\src\services\websocketService.js %BACKUP_DIR%\websocketService.js.bak
)
if exist central_agent\backend\encoding_fixed_api.py (
  copy central_agent\backend\encoding_fixed_api.py %BACKUP_DIR%\encoding_fixed_api.py.bak
)
if exist central_agent\orchestrator\central_orchestrator.py (
  copy central_agent\orchestrator\central_orchestrator.py %BACKUP_DIR%\central_orchestrator.py.bak
)
echo Backup created in %BACKUP_DIR%
echo.

echo Step 2/6: Installing notification module...
if exist central_agent\modules\print_notification.py (
  echo Notification module already exists, skipping...
) else (
  echo Installing notification module...
  python central_agent\orchestrator\notification_patch.py
)
echo.

echo Step 3/6: Patching central orchestrator...
echo Running notification patch script...
cd /d C:\RuslanAI\central_agent\orchestrator
python notification_patch.py
cd /d C:\RuslanAI
echo.

echo Step 4/6: Updating UI components...
echo Updating agentService.js...
copy web_ui\src\services\agentService.js.new web_ui\src\services\agentService.js
echo Updating RuslanAI.jsx...
copy web_ui\src\components\RuslanAI.jsx.new web_ui\src\components\RuslanAI.jsx
echo.

echo Step 5/6: Stopping running servers...
echo Attempting to stop any running WebSocket or API servers...
taskkill /F /IM node.exe /T 2>nul
taskkill /F /FI "WINDOWTITLE eq *WebSocket*" /T 2>nul
taskkill /F /FI "WINDOWTITLE eq *API*" /T 2>nul
ping -n 2 127.0.0.1 >nul
echo.

echo Step 6/6: Starting Direct API server...
echo Starting Direct API server in a new window...
start cmd /k C:\RuslanAI\scripts\start_direct_api.bat
echo.

echo Installation completed successfully!
echo.
echo Documentation: C:\RuslanAI\DIRECT_API_MODE.md
echo.
echo To verify the API server:
echo  - Run: C:\RuslanAI\scripts\verify_direct_api.bat
echo.
echo To restore previous version:
echo  - All backups are saved in %BACKUP_DIR%
echo.
pause