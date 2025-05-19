@echo off
echo Starting API server with debug output...
cd C:\RuslanAI
python -m central_agent.backend.encoding_fixed_api
echo.
echo Press any key to exit...
pause > nul