@echo off 
set PYTHONIOENCODING=utf-8 
set PYTHONLEGACYWINDOWSSTDIO=utf-8 
chcp 65001 > nul 
echo Starting API server with UTF-8 encoding... 
python central_agent\backend\direct_api.py 
