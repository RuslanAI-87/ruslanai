@echo off
echo Updating HTTP endpoint port in the agent service...
echo.

cd /d "%~dp0scripts"
node update_agent_service_port.js

echo.
echo Done. Press any key to continue...
pause