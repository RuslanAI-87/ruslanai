@echo off
echo Starting RuslanAI API with proper encoding settings

:: Set UTF-8 for console
chcp 65001

:: Start the API server directly with proper environment variables
cd C:\RuslanAI\central_agent\backend
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8
python direct_api.py

pause
