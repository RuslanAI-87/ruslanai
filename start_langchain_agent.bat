@echo off
chcp 65001
echo ===== Starting LangChain Agent Backend =====
echo Start time: %TIME%
echo Python path: %PATH%
SET PATH=%PATH%;C:\RuslanAI\tools\ffmpeg\bin
REM Check if virtual environment exists
if exist "C:\RuslanAI\venv\Scripts\activate.bat" (
    echo Activating virtual environment...
    call C:\RuslanAI\venv\Scripts\activate.bat
)
cd C:\RuslanAI\central_agent\backend
echo Current directory: %CD%
echo Starting Python server...
python -V > C:\RuslanAI\python_version.txt
python main.py
