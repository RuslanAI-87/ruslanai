@echo off
echo ================================================================
echo  RuslanAI - Alternative Memory System Test
echo ================================================================
echo.

echo This script will run a simplified memory test that doesn't rely on
echo complex dependencies or Python package installations.
echo.
echo This is a good fallback option when the main test script encounters errors.
echo.
pause

:: Run the Python script directly
python "%~dp0\alternative_test.py"

if %ERRORLEVEL% NEQ 0 (
    echo Error running alternative test script. 
    echo Please check that Python is installed and in your PATH.
    pause
    exit /b 1
)

pause
exit /b 0