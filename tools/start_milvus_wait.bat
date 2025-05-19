@echo off
echo =====================================================
echo Starting Milvus and waiting until it's ready to use
echo =====================================================

python "%~dp0wait_for_milvus.py"
if %errorlevel% neq 0 (
    echo.
    echo Failed to start or verify Milvus. See messages above.
    pause
    exit /b 1
)

echo.
echo Milvus is ready! You can now run your tests.
echo.

echo Do you want to run the cognitive memory test? (y/n)
set /p run_test="> "

if /i "%run_test%" == "y" (
    cd /d "%~dp0.."
    echo Running test_cognitive_memory.py...
    python test_cognitive_memory.py
)

pause