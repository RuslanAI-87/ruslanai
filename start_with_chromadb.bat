@echo off
echo RuslanAI Cognitive Memory System with ChromaDB
echo =============================================
echo.

REM Set up Python environment
set PYTHONPATH=%CD%;%CD%\central_agent;%CD%\central_agent\modules;%CD%\central_agent\modules\memory;%CD%\central_agent\orchestrator

REM Create log directory if it doesn't exist
if not exist logs mkdir logs

echo 1. Verifying required Python packages...
pip show chromadb sentence-transformers torch >nul 2>&1
if errorlevel 1 (
    echo Installing required packages...
    pip install chromadb sentence-transformers torch
) else (
    echo Required packages are already installed.
)
echo.

echo 2. Checking if GPU is available for acceleration...
python -c "import torch; print(f'GPU available: {torch.cuda.is_available()}')"
echo.

echo 3. Starting Cognitive Memory System with ChromaDB...
echo This will initialize the memory system with ChromaDB as the vector store.
echo.

REM Start the cognitive memory test
python test_cognitive_memory.py

echo.
echo Memory system test completed.
echo The system is now using ChromaDB for vector storage.
echo.
echo To continue using the system within your application:
echo 1. Import the memory adapter: from central_agent.modules.memory.integration_adapter import MemoryAdapter
echo 2. Create an instance: memory_adapter = MemoryAdapter(use_cognitive=True)
echo 3. Use the adapter methods for memory operations

echo.
echo For more information, see CHROMADB_INTEGRATION.md