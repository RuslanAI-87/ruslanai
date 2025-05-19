@echo off
cd /d C:\RuslanAI
echo Testing Cognitive Memory System Integration

rem Set Python path to include necessary modules
set PYTHONPATH=C:\RuslanAI;%PYTHONPATH%

rem Make sure modules directory exists
if not exist "C:\RuslanAI\central_agent\modules\memory" (
    echo ERROR: Memory modules directory not found
    echo Expected path: C:\RuslanAI\central_agent\modules\memory
    echo Please ensure the cognitive memory system is properly installed
    pause
    exit /b 1
)

rem Run the test script
python test_cognitive_memory.py

echo.
echo Test completed. See output above for results.
pause