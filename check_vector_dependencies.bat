@echo off
echo ============================================================
echo  RuslanAI - Vector Store Dependency Check
echo ============================================================
echo.

:: Set UTF-8 for console
chcp 65001

:: Set environment variables
set PYTHONIOENCODING=utf-8

:: Run check script
python check_vector_dependencies.py > logs\vector_dependency_check.log

:: Display the results
type logs\vector_dependency_check.log

echo.
echo Results saved to logs\vector_dependency_check.log
echo.
pause