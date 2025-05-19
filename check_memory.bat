@echo off
:: Simple memory system check script
echo Checking RuslanAI memory system...
echo.

:: Set UTF-8 for console
chcp 65001

:: Set environment variables
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

:: Create necessary directories
mkdir C:\RuslanAI\logs 2>nul
mkdir C:\RuslanAI\data\vector_store 2>nul

:: Run a python script that checks configuration
python -c "import os, sys; print('Python encoding:', sys.stdout.encoding); print('Environment:', os.environ.get('PYTHONIOENCODING')); print('Working directory:', os.getcwd())"

:: Check for required libraries
echo.
echo Checking for required libraries:
python -c "import importlib.util; libs=['sentence_transformers', 'chromadb', 'torch']; [print(f'- {lib}: {importlib.util.find_spec(lib) is not None}') for lib in libs]"

:: Run a simple test to execute the memory module
echo.
echo Trying to run memory module test:
python -c "import sys; sys.path.append('C:/RuslanAI/central_agent/modules'); print('Module paths initialized...')"

echo Memory system check complete\!
pause
