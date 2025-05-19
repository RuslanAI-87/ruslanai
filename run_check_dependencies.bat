@echo off
echo ===============================================================
echo  RuslanAI - Check Vector Dependencies (Correct Path)
echo ===============================================================
echo.

:: Set UTF-8 for console
chcp 65001

:: Change to the correct directory first
cd /d C:\RuslanAI

echo Current directory: %CD%
echo.

:: Set environment variables
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

:: Create logs directory if it doesn't exist
mkdir logs 2>nul

:: Run the check script
python check_vector_dependencies.py > logs\vector_dependency_check.log

:: Display the results
type logs\vector_dependency_check.log

echo.
echo Results saved to logs\vector_dependency_check.log
echo.
pause