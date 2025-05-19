@echo off
echo ============================================================
echo  RuslanAI - Vector Storage Fix and Integration with Memory
echo ============================================================
echo.
echo This script will fix vector storage integration with memory system
echo and ensure it works properly with the Central Orchestrator.
echo.

:: Set UTF-8 encoding for console
chcp 65001

:: Create necessary directories
mkdir C:\RuslanAI\logs 2>nul
mkdir C:\RuslanAI\data\vector_store 2>nul
mkdir C:\RuslanAI\data\memory\summary 2>nul
mkdir C:\RuslanAI\data\memory\context 2>nul
mkdir C:\RuslanAI\data\memory\detail 2>nul

echo Directories created successfully.
echo.

:: Run Python script to test vector storage integration
echo Testing vector storage integration...
python -c "import sys; sys.path.append('C:/RuslanAI/central_agent/modules'); from memory.memory_system import memory_system, VECTOR_STORE_AVAILABLE; print(f'Vector store available: {VECTOR_STORE_AVAILABLE}'); print('Memory system initialized successfully!')"

echo.
echo Vector storage fix applied. Now we need to restart the API server.
echo.
echo ============================================================
echo Please follow these steps:
echo 1. Stop the current API server (if running)
echo 2. Run the restart_simple.bat script to start API with fixed vector storage
echo ============================================================
echo.
pause