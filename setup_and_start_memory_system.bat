@echo off
echo ===============================================================
echo  RuslanAI - Complete Memory System Setup and Startup
echo ===============================================================
echo.
echo This script will:
echo  1. Fix vector store import issues
echo  2. Install required dependencies
echo  3. Create required directories
echo  4. Test vector store functionality
echo  5. Start the API server with memory integration
echo.

:: Set UTF-8 for console
chcp 65001

:: Set environment variables
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

echo ---------------------------------------------------------------
echo Step 1: Creating directories
echo ---------------------------------------------------------------
mkdir C:\RuslanAI\logs 2>nul
mkdir C:\RuslanAI\data 2>nul
mkdir C:\RuslanAI\data\vector_store 2>nul
mkdir C:\RuslanAI\data\memory 2>nul
mkdir C:\RuslanAI\data\memory\summary 2>nul
mkdir C:\RuslanAI\data\memory\context 2>nul
mkdir C:\RuslanAI\data\memory\detail 2>nul
echo Directories created.
echo.

echo ---------------------------------------------------------------
echo Step 2: Fixing vector store imports
echo ---------------------------------------------------------------
python fix_vector_imports.py
if %ERRORLEVEL% NEQ 0 (
    echo Error fixing vector store imports!
    goto :error
)
echo.

echo ---------------------------------------------------------------
echo Step 3: Installing required dependencies
echo ---------------------------------------------------------------
python -m pip install sentence-transformers chromadb torch numpy scipy
if %ERRORLEVEL% NEQ 0 (
    echo Error installing dependencies!
    goto :error
)
echo.

echo ---------------------------------------------------------------
echo Step 4: Verifying dependencies
echo ---------------------------------------------------------------
python check_vector_dependencies.py
if %ERRORLEVEL% NEQ 0 (
    echo Error checking dependencies!
    goto :error
)
echo.

echo ---------------------------------------------------------------
echo Step 5: Testing memory system integration
echo ---------------------------------------------------------------
python test_memory_integration.py
if %ERRORLEVEL% NEQ 0 (
    echo Error testing memory system!
    goto :error
)
echo.

echo ===============================================================
echo Setup complete! The memory system is ready.
echo.
echo Do you want to start the API server now? (Y/N)
set /p START_API=
if /i "%START_API%"=="Y" (
    echo.
    echo Starting API server...
    cd C:\RuslanAI\central_agent\backend
    start cmd /k "title RuslanAI API Server & python direct_api.py"
    
    echo.
    echo The API server is starting in a new window.
    echo Wait a few seconds, then press any key to launch the test client.
    pause >nul
    
    cd C:\RuslanAI
    start cmd /k "title RuslanAI Test Client & python test_api_with_memory.py"
    
    echo.
    echo Test client started in a new window.
)

echo.
echo Setup and startup process complete!
echo ===============================================================
goto :end

:error
echo.
echo ===============================================================
echo An error occurred during the setup process.
echo Please check the output above for details.
echo ===============================================================
echo.

:end
pause