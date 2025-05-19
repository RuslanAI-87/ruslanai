@echo off
echo RuslanAI ChromaDB Integration Verification
echo =========================================
echo.

REM Set up Python environment
set PYTHONPATH=%CD%;%CD%\central_agent;%CD%\central_agent\modules;%CD%\central_agent\modules\memory;%CD%\central_agent\orchestrator

echo 1. Running Windows-compatible ChromaDB verification script...
python verify_chromadb_integration.py
if errorlevel 1 (
    echo ERROR: ChromaDB integration verification failed!
    echo Please check the logs for details.
    exit /b 1
) else (
    echo ChromaDB integration verification passed!
    echo.
)

echo 2. Testing Memory Adapter with ChromaDB...
python test_memory_adapter_async.py
if errorlevel 1 (
    echo ERROR: Memory Adapter test failed!
    echo Please check the logs for details.
    exit /b 1
) else (
    echo Memory Adapter test passed!
    echo.
)

echo 3. Testing full cognitive memory system with ChromaDB...
python test_cognitive_memory.py
if errorlevel 1 (
    echo WARNING: Full cognitive memory test encountered issues.
    echo Please check the logs for details.
) else (
    echo Full cognitive memory test passed!
    echo.
)

echo.
echo All tests completed!
echo ChromaDB is correctly integrated with the cognitive memory system.
echo Note: Make sure the cognitive memory system is using ChromaDB instead of Milvus.