@echo off
echo Starting RuslanAI Cognitive Memory System on Windows
echo ===================================================

echo Checking for Python...
python --version 2>NUL
if %ERRORLEVEL% NEQ 0 (
    echo Python not found! Please install Python from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b 1
)

echo.
echo Checking for Docker...
docker --version 2>NUL
if %ERRORLEVEL% NEQ 0 (
    echo Docker not found! Please install Docker Desktop from https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo.
echo Docker is installed. Starting Milvus...
cd C:\RuslanAI
docker-compose up -d

echo.
echo Waiting for Milvus to start...
timeout /t 10 /nobreak

echo.
echo Installing required Python packages...
pip install pymilvus sentence-transformers numpy

echo.
echo Running performance test...
python C:\RuslanAI\test_milvus.py

echo.
echo Running memory system test...
python C:\RuslanAI\test_cognitive_memory.py

echo.
echo Setup complete! Press any key to exit.
pause