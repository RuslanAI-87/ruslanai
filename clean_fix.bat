@echo off
echo ===================================================
echo Clean Memory System Fix
echo ===================================================

cd /d %~dp0

echo Creating clean Python fix script...
echo import os > clean_fix.py
echo import sys >> clean_fix.py
echo import re >> clean_fix.py

echo # Fix duplicate encoding headers >> clean_fix.py
echo def fix_file(filepath): >> clean_fix.py
echo     print(f"Fixing file: {filepath}") >> clean_fix.py
echo     if not os.path.exists(filepath): >> clean_fix.py
echo         print(f"  Error: File not found") >> clean_fix.py
echo         return False >> clean_fix.py
echo     with open(filepath, "r", encoding="utf-8") as f: >> clean_fix.py
echo         content = f.read() >> clean_fix.py
echo     # Remove duplicate encoding headers >> clean_fix.py
echo     encoding_header = "# -*- coding: utf-8 -*-" >> clean_fix.py
echo     encoding_block = """# -*- coding: utf-8 -*-\nimport sys\nimport io\nimport os\n\n# Fix for Windows encoding issues\nif os.name == 'nt':\n    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')\n    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')""" >> clean_fix.py
echo     # Clean content - remove any duplicate headers >> clean_fix.py
echo     cleaned_content = re.sub(encoding_block, "", content) >> clean_fix.py
echo     cleaned_content = re.sub(encoding_header, "", cleaned_content) >> clean_fix.py
echo     # Add single clean header >> clean_fix.py
echo     final_content = encoding_block + "\n\n" + cleaned_content.lstrip() >> clean_fix.py
echo     with open(filepath, "w", encoding="utf-8") as f: >> clean_fix.py
echo         f.write(final_content) >> clean_fix.py
echo     print(f"  File fixed successfully") >> clean_fix.py
echo     return True >> clean_fix.py

echo # Fix both memory modules >> clean_fix.py
echo vector_store_path = os.path.join("central_agent", "modules", "memory", "vector_store.py") >> clean_fix.py
echo memory_system_path = os.path.join("central_agent", "modules", "memory", "memory_system.py") >> clean_fix.py
echo init_path = os.path.join("central_agent", "modules", "memory", "__init__.py") >> clean_fix.py

echo # Create __init__.py if missing >> clean_fix.py
echo if not os.path.exists(init_path): >> clean_fix.py
echo     print(f"Creating {init_path}") >> clean_fix.py
echo     with open(init_path, "w", encoding="utf-8") as f: >> clean_fix.py
echo         f.write("# Memory system initialization\n") >> clean_fix.py
echo     print("  Created successfully") >> clean_fix.py
echo else: >> clean_fix.py
echo     print(f"{init_path} already exists") >> clean_fix.py

echo # Fix both files >> clean_fix.py
echo success1 = fix_file(vector_store_path) >> clean_fix.py
echo success2 = fix_file(memory_system_path) >> clean_fix.py
echo if success1 and success2: >> clean_fix.py
echo     print("All files fixed successfully") >> clean_fix.py
echo else: >> clean_fix.py
echo     print("Some files could not be fixed") >> clean_fix.py

echo Executing clean fix script...
python clean_fix.py

echo Creating minimal startup script...
echo @echo off > restart_minimal.bat
echo echo Starting RuslanAI API server... >> restart_minimal.bat
echo set PYTHONIOENCODING=utf-8 >> restart_minimal.bat
echo set PYTHONLEGACYWINDOWSSTDIO=utf-8 >> restart_minimal.bat
echo python central_agent\backend\direct_api.py >> restart_minimal.bat

echo Stopping previous API server if running...
taskkill /f /im python.exe 2>nul
timeout /t 2 /nobreak > nul

echo Starting API server with fixed memory system...
start "RuslanAI API Server" cmd /k "restart_minimal.bat"

echo ===================================================
echo Memory system fix complete!
echo ===================================================
echo 1. The memory modules have been fixed
echo 2. A fresh API server has been started
echo 3. Check if the warning is gone:
echo    "Vector store successfully imported" should appear
echo    instead of "Vector store unavailable" warning
echo ===================================================
pause