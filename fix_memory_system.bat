@echo off
echo ===================================================
echo Direct Memory System Fix
echo ===================================================

cd /d %~dp0

echo Fixing memory system modules...

:: Create directory for Python script
mkdir fix_scripts 2>nul

:: Create the Python script to fix memory modules
echo import os > fix_scripts\fix_memory.py
echo import sys >> fix_scripts\fix_memory.py
echo import shutil >> fix_scripts\fix_memory.py
echo. >> fix_scripts\fix_memory.py
echo def fix_vector_store(): >> fix_scripts\fix_memory.py
echo     print("Fixing vector_store.py...") >> fix_scripts\fix_memory.py
echo     vector_path = "central_agent/modules/memory/vector_store.py" >> fix_scripts\fix_memory.py
echo     if not os.path.exists(vector_path): >> fix_scripts\fix_memory.py
echo         print(f"Error: {vector_path} not found") >> fix_scripts\fix_memory.py
echo         return False >> fix_scripts\fix_memory.py
echo     backup_path = vector_path + ".bak" >> fix_scripts\fix_memory.py
echo     shutil.copy2(vector_path, backup_path) >> fix_scripts\fix_memory.py
echo     print(f"Created backup: {backup_path}") >> fix_scripts\fix_memory.py
echo     encoding_fix = """# -*- coding: utf-8 -*-\nimport sys\nimport io\nimport os\n\n# Fix for Windows encoding issues\nif os.name == 'nt':\n    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')\n    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')\n""" >> fix_scripts\fix_memory.py
echo     with open(vector_path, "r", encoding="utf-8") as f: >> fix_scripts\fix_memory.py
echo         content = f.read() >> fix_scripts\fix_memory.py
echo     with open(vector_path, "w", encoding="utf-8") as f: >> fix_scripts\fix_memory.py
echo         f.write(encoding_fix + content) >> fix_scripts\fix_memory.py
echo     print("Vector store fix applied") >> fix_scripts\fix_memory.py
echo     return True >> fix_scripts\fix_memory.py
echo. >> fix_scripts\fix_memory.py
echo def fix_memory_system(): >> fix_scripts\fix_memory.py
echo     print("Fixing memory_system.py...") >> fix_scripts\fix_memory.py
echo     memory_path = "central_agent/modules/memory/memory_system.py" >> fix_scripts\fix_memory.py
echo     if not os.path.exists(memory_path): >> fix_scripts\fix_memory.py
echo         print(f"Error: {memory_path} not found") >> fix_scripts\fix_memory.py
echo         return False >> fix_scripts\fix_memory.py
echo     backup_path = memory_path + ".bak" >> fix_scripts\fix_memory.py
echo     shutil.copy2(memory_path, backup_path) >> fix_scripts\fix_memory.py
echo     print(f"Created backup: {backup_path}") >> fix_scripts\fix_memory.py
echo     encoding_fix = """# -*- coding: utf-8 -*-\nimport sys\nimport io\nimport os\n\n# Fix for Windows encoding issues\nif os.name == 'nt':\n    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')\n    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')\n""" >> fix_scripts\fix_memory.py
echo     with open(memory_path, "r", encoding="utf-8") as f: >> fix_scripts\fix_memory.py
echo         content = f.read() >> fix_scripts\fix_memory.py
echo     with open(memory_path, "w", encoding="utf-8") as f: >> fix_scripts\fix_memory.py
echo         f.write(encoding_fix + content) >> fix_scripts\fix_memory.py
echo     print("Memory system fix applied") >> fix_scripts\fix_memory.py
echo     return True >> fix_scripts\fix_memory.py
echo. >> fix_scripts\fix_memory.py
echo def create_init_module(): >> fix_scripts\fix_memory.py
echo     print("Creating __init__.py if needed...") >> fix_scripts\fix_memory.py
echo     init_path = "central_agent/modules/memory/__init__.py" >> fix_scripts\fix_memory.py
echo     if not os.path.exists(init_path): >> fix_scripts\fix_memory.py
echo         with open(init_path, "w", encoding="utf-8") as f: >> fix_scripts\fix_memory.py
echo             f.write("# Memory system initialization\n") >> fix_scripts\fix_memory.py
echo         print("Created __init__.py") >> fix_scripts\fix_memory.py
echo     return True >> fix_scripts\fix_memory.py
echo. >> fix_scripts\fix_memory.py
echo def test_imports(): >> fix_scripts\fix_memory.py
echo     print("Testing imports...") >> fix_scripts\fix_memory.py
echo     try: >> fix_scripts\fix_memory.py
echo         sys.path.append('.') >> fix_scripts\fix_memory.py
echo         from central_agent.modules.memory.vector_store import vector_store, ADVANCED_FEATURES_AVAILABLE, GPU_AVAILABLE >> fix_scripts\fix_memory.py
echo         print(f"Vector store imported successfully") >> fix_scripts\fix_memory.py
echo         print(f"Advanced features available: {ADVANCED_FEATURES_AVAILABLE}") >> fix_scripts\fix_memory.py
echo         print(f"GPU available: {GPU_AVAILABLE}") >> fix_scripts\fix_memory.py
echo         return True >> fix_scripts\fix_memory.py
echo     except Exception as e: >> fix_scripts\fix_memory.py
echo         print(f"Import test failed: {e}") >> fix_scripts\fix_memory.py
echo         return False >> fix_scripts\fix_memory.py
echo. >> fix_scripts\fix_memory.py
echo if __name__ == "__main__": >> fix_scripts\fix_memory.py
echo     success = True >> fix_scripts\fix_memory.py
echo     success = fix_vector_store() and success >> fix_scripts\fix_memory.py
echo     success = fix_memory_system() and success >> fix_scripts\fix_memory.py
echo     success = create_init_module() and success >> fix_scripts\fix_memory.py
echo     success = test_imports() and success >> fix_scripts\fix_memory.py
echo     print(f"Memory system fix {'succeeded' if success else 'failed'}") >> fix_scripts\fix_memory.py
echo     sys.exit(0 if success else 1) >> fix_scripts\fix_memory.py

:: Run the Python script
echo Running memory system fix...
python fix_scripts\fix_memory.py

echo.
echo ===================================================
echo Stopping previous API server...
taskkill /f /im python.exe 2>nul
timeout /t 2 /nobreak > nul

echo Creating startup script with proper encoding...
echo @echo off > start_api_fixed.bat
echo set PYTHONIOENCODING=utf-8 >> start_api_fixed.bat
echo set PYTHONLEGACYWINDOWSSTDIO=utf-8 >> start_api_fixed.bat 
echo python central_agent\backend\direct_api.py >> start_api_fixed.bat

echo Starting API server with fixed memory system...
start "RuslanAI API with Vector Store" cmd /k "start_api_fixed.bat"

echo.
echo ===================================================
echo Fix complete! The API server has been restarted with memory system fixes.
echo You should now have working vector storage for maintaining conversation context.
echo ===================================================
pause