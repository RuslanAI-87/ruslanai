@echo off
echo RuslanAI Cognitive Memory System Test Script
echo =========================================
echo.

REM Set up Python environment
set PYTHONPATH=%CD%;%CD%\central_agent;%CD%\central_agent\modules;%CD%\central_agent\modules\memory;%CD%\central_agent\orchestrator

echo 1. Running Windows-compatible verification script...
python verify_fixes_windows.py
echo.

echo 2. Fixing asynchronous initialization issues...
python fix_async_initialization.py
if errorlevel 1 (
    echo WARNING: Could not fix asynchronous initialization issues.
    echo Tests may encounter async-related errors.
) else (
    echo Async initialization fixed. Continuing with tests...
)
echo.

echo 3. Starting Milvus if needed...
python start_milvus.py
if errorlevel 1 (
    echo WARNING: Could not start Milvus automatically. Vector store will fall back to ChromaDB.
    echo Tests will continue, but Milvus features won't be tested.
    echo.
) else (
    echo Milvus is running. Continuing with tests...
    echo.
)

echo 4. Testing Milvus connection with proper URI format...
python test_milvus_connection.py
echo.

echo 5. Testing memory system initialization...
python -c "from central_agent.modules.memory.memory_system import memory_system, VECTOR_STORE_AVAILABLE; m = memory_system(); print(f'Memory system created successfully! Vector store available: {VECTOR_STORE_AVAILABLE}')"
echo.

echo 6. Testing EnhancedHierarchicalMemory...
python -c "from central_agent.modules.memory.enhanced_memory_system import EnhancedHierarchicalMemory; m = EnhancedHierarchicalMemory(vector_store=None); print('EnhancedHierarchicalMemory initialized successfully!')"
echo.

echo 7. Testing MemoryAdapter...
python -c "from central_agent.modules.memory.integration_adapter import MemoryAdapter; m = MemoryAdapter(use_cognitive=True); print('MemoryAdapter initialized successfully!')"
echo.

REM Only run the full test if explicitly requested
if "%1"=="--full" (
    echo 6. Running full cognitive memory test...
    python test_cognitive_memory.py
) else (
    echo To run the full test, use: test_memory_system.bat --full
)

echo.
echo Tests completed!