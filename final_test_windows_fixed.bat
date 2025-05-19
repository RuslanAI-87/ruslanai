@echo off
echo Running Final Test for RuslanAI Cognitive Memory System (Fixed Version)
echo ================================================================
echo.

echo Checking Python installation...
python --version
if %ERRORLEVEL% NEQ 0 (
    echo Python not found! Please install Python.
    exit /b 1
)

echo.
echo Installing required packages...
python -m pip install sentence-transformers pymilvus numpy

echo.
echo Starting Milvus database...
cd C:\RuslanAI
docker-compose up -d

echo.
echo Waiting for Milvus to start...
timeout /t 10 /nobreak

echo.
echo Creating necessary directories...
mkdir C:\RuslanAI\data\vector_store\dialogs 2>NUL
mkdir C:\RuslanAI\central_agent\modules\memory\__pycache__ 2>NUL

echo.
echo Testing if memory_system module imports correctly...
python -c "from central_agent.modules.memory.memory_system import memory_system, HierarchicalMemory; print('✓ Import test successful!')"

echo.
echo Testing dialog methods...
python -c "import asyncio; from central_agent.modules.memory.memory_system import HierarchicalMemory; async def test(): memory = HierarchicalMemory(storage_path='C:/RuslanAI/data/vector_store'); await memory.save_dialog('test_dialog', '{\"test\": true}'); content = await memory.restore_dialog('test_dialog'); print(f'✓ Dialog test successful! Content: {content}'); asyncio.run(test())"

echo.
echo Running memory system test...
python C:\RuslanAI\test_cognitive_memory.py

echo.
echo Test completed! Press any key to stop Milvus and clean up.
pause

echo.
echo Stopping Milvus...
docker-compose down

echo.
echo All done! Press any key to exit.
pause