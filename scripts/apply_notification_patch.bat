@echo off
echo Applying notification patch to central_orchestrator.py...
cd /d C:\RuslanAI\central_agent\orchestrator
python notification_patch.py
echo.
echo To restore backup (if needed), run:
echo python notification_patch.py restore
echo.
pause