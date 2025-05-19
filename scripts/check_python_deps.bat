@echo off
echo ================================================================
echo  RuslanAI - Check Python Dependencies for Memory Benchmarks
echo ================================================================
echo.

:: Set UTF-8 for console
chcp 65001

echo Running dependency checker...
cd /d %~dp0..
python scripts\check_dependencies.py

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to install required dependencies.
    echo Please install the following packages manually:
    echo numpy pandas matplotlib sentence-transformers chromadb scikit-learn tqdm psutil torch pytest
    echo.
    pause
    exit /b 1
)

echo.
echo All dependencies are installed correctly!
echo You can now run scripts\setup_test_environment.bat to prepare the test environment.
echo.
pause
exit /b 0