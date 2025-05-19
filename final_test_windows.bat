@echo off
echo Running Final Test for RuslanAI Cognitive Memory System
echo =====================================================
echo.

echo Checking Python installation...
python --version
if %ERRORLEVEL% NEQ 0 (
    echo Python not found! Please install Python.
    exit /b 1
)

echo.
echo Installing required packages...
python -m pip install sentence-transformers pymilvus numpy

echo.
echo Starting Milvus database...
cd C:\RuslanAI
docker-compose up -d

echo.
echo Waiting for Milvus to start...
timeout /t 10 /nobreak

echo.
echo Running memory system test...
python C:\RuslanAI\test_cognitive_memory.py

echo.
echo Test completed! Press any key to stop Milvus and clean up.
pause

echo.
echo Stopping Milvus...
docker-compose down

echo.
echo All done! Press any key to exit.
pause