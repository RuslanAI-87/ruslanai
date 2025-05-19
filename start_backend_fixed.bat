@echo off
chcp 65001
echo ===== Starting Backend Server =====
echo Start time: %TIME%
echo Python path: %PATH%
SET PATH=%PATH%;C:\RuslanAI\tools\ffmpeg\bin
cd C:\RuslanAI\central_agent\backend
echo Current directory: %CD%
echo Starting Python server...
python -V > C:\RuslanAI\python_version.txt
python main.py > C:\RuslanAI\backend_log.txt 2>&1
