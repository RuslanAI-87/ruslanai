@echo off
chcp 65001
echo ===== Starting AutoGPT Integration =====
echo Start time: %TIME%

REM Check if virtual environment exists for RuslanAI
if exist "C:\RuslanAI\venv\Scripts\activate.bat" (
    echo Activating RuslanAI virtual environment...
    call C:\RuslanAI\venv\Scripts\activate.bat
)

REM Set the path to Auto-GPT
set AUTO_GPT_PATH=C:\Users\info\Auto-GPT

echo Starting Docker container for Auto-GPT...
cd %AUTO_GPT_PATH%
docker-compose up -d

echo AutoGPT should now be running. Connecting to RuslanAI system...
timeout /t 5

REM Return to RuslanAI directory
cd C:\RuslanAI\central_agent\modules
python update_auto_gpt_status.py

echo Integration complete. Check logs for details.
