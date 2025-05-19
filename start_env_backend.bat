@echo off
chcp 65001
echo ===== Starting Backend Server in Virtual Environment =====
echo Start time: %TIME%
call C:\RuslanAI\ruslan_env\Scripts\activate.bat
SET PATH=%PATH%;C:\RuslanAI\tools\ffmpeg\bin
cd C:\RuslanAI\central_agent\backend
echo Current directory: %CD%
echo Starting Python server...
python -V > C:\RuslanAI\python_version.txt
python main.py
