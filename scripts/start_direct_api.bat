@echo off
echo Starting RuslanAI Direct API Server...
cd /d C:\RuslanAI\central_agent\backend
start cmd /k "python direct_api.py"
echo Direct API Server started on port 8001.
echo.
echo To access the API:
echo  - Health check: http://localhost:8001/api/health
echo  - Chat endpoint: http://localhost:8001/api/chat
echo  - Orchestrator endpoint: http://localhost:8001/orchestrator/central
echo.
pause