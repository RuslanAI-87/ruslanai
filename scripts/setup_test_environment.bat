@echo off
echo ================================================================
echo  RuslanAI - Setup Test Environment for Memory System
echo ================================================================
echo.

:: Set UTF-8 for console
chcp 65001

:: Check for dependencies first
call scripts\check_python_deps.bat
if %ERRORLEVEL% NEQ 0 (
    echo Failed to verify dependencies. Please run check_python_deps.bat first.
    pause
    exit /b 1
)

echo Creating test environment and setting up benchmarks...
echo.

:: Create directories for test environment
if not exist "C:\RuslanAI\test_environment" (
    echo Creating directory structure...
    mkdir "C:\RuslanAI\test_environment\data\memory\summary" 2>nul
    mkdir "C:\RuslanAI\test_environment\data\memory\context" 2>nul
    mkdir "C:\RuslanAI\test_environment\data\memory\detail" 2>nul
    mkdir "C:\RuslanAI\test_environment\data\vector_store" 2>nul
    mkdir "C:\RuslanAI\test_environment\data\test_data" 2>nul
    mkdir "C:\RuslanAI\test_environment\logs" 2>nul
    mkdir "C:\RuslanAI\test_environment\benchmarks\scenarios" 2>nul
    mkdir "C:\RuslanAI\test_environment\benchmarks\results" 2>nul
    mkdir "C:\RuslanAI\test_environment\memory_system" 2>nul
    echo Directories created.
) else (
    echo Test environment directory already exists.
)
echo.

:: Copy memory files if they exist
if exist "C:\RuslanAI\data\memory" (
    echo Copying memory files...
    xcopy "C:\RuslanAI\data\memory" "C:\RuslanAI\test_environment\data\memory" /E /I /Y >nul
    echo Memory files copied.
) else (
    echo Warning: Original memory files not found at C:\RuslanAI\data\memory
)
echo.

:: Copy vector store if it exists
if exist "C:\RuslanAI\data\vector_store" (
    echo Copying vector store...
    xcopy "C:\RuslanAI\data\vector_store" "C:\RuslanAI\test_environment\data\vector_store" /E /I /Y >nul
    echo Vector store copied.
) else (
    echo Warning: Vector store not found at C:\RuslanAI\data\vector_store
)
echo.

:: Copy memory system source code
echo Copying memory system source code...
if exist "C:\RuslanAI\central_agent\modules\memory\memory_system.py" (
    copy "C:\RuslanAI\central_agent\modules\memory\memory_system.py" "C:\RuslanAI\test_environment\memory_system\memory_system.py" >nul
) else (
    echo Error: memory_system.py not found!
    pause
    exit /b 1
)

if exist "C:\RuslanAI\central_agent\modules\memory\vector_store.py" (
    copy "C:\RuslanAI\central_agent\modules\memory\vector_store.py" "C:\RuslanAI\test_environment\memory_system\vector_store.py" >nul
) else (
    echo Error: vector_store.py not found!
    pause
    exit /b 1
)

:: Create __init__.py for package import
echo # Memory system package > "C:\RuslanAI\test_environment\memory_system\__init__.py"

echo Source code successfully copied.
echo.

:: Run Python script to create test environment
echo Running Python script to create test environment...
echo.

python "C:\RuslanAI\memory_test_environment.py" --create
if %ERRORLEVEL% NEQ 0 (
    echo Error running memory_test_environment.py
    pause
    exit /b 1
)

echo.
echo Test environment created successfully!
echo.
echo Next steps:
echo 1. Generate test data: python memory_test_environment.py --generate small
echo 2. Run benchmarks: python memory_test_environment.py --run
echo.
echo For help on available parameters: python memory_test_environment.py --help
echo.
pause
exit /b 0