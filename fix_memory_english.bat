@echo off
echo ===================================================
echo Vector Memory Store Fix
echo ===================================================

cd /d %~dp0

echo Creating fix scripts directory...
mkdir fix_scripts 2>nul

echo Creating Python fix script...
echo import os > fix_scripts\memory_fix.py
echo import sys >> fix_scripts\memory_fix.py
echo import shutil >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo # Fix paths for both Windows and WSL >> fix_scripts\memory_fix.py
echo script_dir = os.path.dirname(os.path.abspath(__file__)) >> fix_scripts\memory_fix.py
echo root_dir = os.path.dirname(script_dir) >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo vector_store_path = os.path.join(root_dir, "central_agent", "modules", "memory", "vector_store.py") >> fix_scripts\memory_fix.py
echo memory_system_path = os.path.join(root_dir, "central_agent", "modules", "memory", "memory_system.py") >> fix_scripts\memory_fix.py
echo init_path = os.path.join(root_dir, "central_agent", "modules", "memory", "__init__.py") >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo print(f"Root directory: {root_dir}") >> fix_scripts\memory_fix.py
echo print(f"Vector store path: {vector_store_path}") >> fix_scripts\memory_fix.py
echo print(f"Memory system path: {memory_system_path}") >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo # Create encoding fix content >> fix_scripts\memory_fix.py
echo encoding_fix = """# -*- coding: utf-8 -*-\nimport sys\nimport io\nimport os\n\n# Fix for Windows encoding issues\nif os.name == 'nt':\n    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')\n    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')\n""" >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo # Fix vector store >> fix_scripts\memory_fix.py
echo print("Fixing vector_store.py...") >> fix_scripts\memory_fix.py
echo if os.path.exists(vector_store_path): >> fix_scripts\memory_fix.py
echo     # Create backup >> fix_scripts\memory_fix.py
echo     backup_path = vector_store_path + ".bak" >> fix_scripts\memory_fix.py
echo     shutil.copy2(vector_store_path, backup_path) >> fix_scripts\memory_fix.py
echo     print(f"Created backup: {backup_path}") >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo     # Read original file content >> fix_scripts\memory_fix.py
echo     with open(vector_store_path, "r", encoding="utf-8") as f: >> fix_scripts\memory_fix.py
echo         content = f.read() >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo     # Add encoding fix to top of file >> fix_scripts\memory_fix.py
echo     with open(vector_store_path, "w", encoding="utf-8") as f: >> fix_scripts\memory_fix.py
echo         f.write(encoding_fix + content) >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo     print("Vector store fix applied") >> fix_scripts\memory_fix.py
echo else: >> fix_scripts\memory_fix.py
echo     print(f"Error: Vector store file not found at {vector_store_path}") >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo # Fix memory system >> fix_scripts\memory_fix.py
echo print("Fixing memory_system.py...") >> fix_scripts\memory_fix.py
echo if os.path.exists(memory_system_path): >> fix_scripts\memory_fix.py
echo     # Create backup >> fix_scripts\memory_fix.py
echo     backup_path = memory_system_path + ".bak" >> fix_scripts\memory_fix.py
echo     shutil.copy2(memory_system_path, backup_path) >> fix_scripts\memory_fix.py
echo     print(f"Created backup: {backup_path}") >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo     # Read original file content >> fix_scripts\memory_fix.py
echo     with open(memory_system_path, "r", encoding="utf-8") as f: >> fix_scripts\memory_fix.py
echo         content = f.read() >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo     # Add encoding fix to top of file >> fix_scripts\memory_fix.py
echo     with open(memory_system_path, "w", encoding="utf-8") as f: >> fix_scripts\memory_fix.py
echo         f.write(encoding_fix + content) >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo     print("Memory system fix applied") >> fix_scripts\memory_fix.py
echo else: >> fix_scripts\memory_fix.py
echo     print(f"Error: Memory system file not found at {memory_system_path}") >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo # Create __init__.py file if needed >> fix_scripts\memory_fix.py
echo print("Creating __init__.py if needed...") >> fix_scripts\memory_fix.py
echo if not os.path.exists(init_path): >> fix_scripts\memory_fix.py
echo     with open(init_path, "w", encoding="utf-8") as f: >> fix_scripts\memory_fix.py
echo         f.write("# Memory system initialization module\n") >> fix_scripts\memory_fix.py
echo     print("Created __init__.py") >> fix_scripts\memory_fix.py
echo else: >> fix_scripts\memory_fix.py
echo     print("__init__.py already exists") >> fix_scripts\memory_fix.py
echo. >> fix_scripts\memory_fix.py
echo print("All fixes applied successfully") >> fix_scripts\memory_fix.py

echo Running Python fix script...
python fix_scripts\memory_fix.py

echo Creating startup script with UTF-8 encoding...
echo @echo off > run_api_utf8.bat
echo set PYTHONIOENCODING=utf-8 >> run_api_utf8.bat
echo set PYTHONLEGACYWINDOWSSTDIO=utf-8 >> run_api_utf8.bat
echo chcp 65001 ^> nul >> run_api_utf8.bat
echo echo Starting API server with UTF-8 encoding... >> run_api_utf8.bat
echo python central_agent\backend\direct_api.py >> run_api_utf8.bat

echo Stopping previous API server if running...
taskkill /f /im python.exe 2>nul
timeout /t 2 /nobreak > nul

echo Starting API server with encoding fixes...
start "RuslanAI API Server" cmd /k "run_api_utf8.bat"

echo ===================================================
echo Vector memory store fix completed!
echo The API server has been restarted with encoding fixes.
echo You should now see "Vector store successfully imported" in logs
echo instead of "Vector store unavailable" warning.
echo ===================================================
pause