@echo off
echo ===================================================
echo Setup Vector Storage - Simple Fix
echo ===================================================

cd /d %~dp0

echo Installing Python dependencies...
python -m pip install sentence-transformers chromadb torch numpy scipy
echo Dependencies installed!

echo Applying encoding fixes...
echo import sys > fix_encoding.py
echo import io >> fix_encoding.py
echo sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace') >> fix_encoding.py
echo sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace') >> fix_encoding.py
echo from sentence_transformers import SentenceTransformer >> fix_encoding.py
echo import chromadb >> fix_encoding.py
echo import torch >> fix_encoding.py
echo print("All libraries installed successfully!") >> fix_encoding.py

python fix_encoding.py
echo Encoding fix test complete!

echo Restarting API server...
taskkill /f /im python.exe 2>nul
timeout /t 2 /nobreak > nul

echo set PYTHONIOENCODING=utf-8 > run_api.bat
echo python central_agent\backend\direct_api.py >> run_api.bat
start "RuslanAI API" cmd /k "run_api.bat"

echo ===================================================
echo Setup complete! API server restarted.
echo ===================================================
pause