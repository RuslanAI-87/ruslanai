@echo off
echo Starting RuslanAI API with proper encoding settings

:: Set UTF-8 for console
chcp 65001

:: Set environment variables for proper encoding
set PYTHONIOENCODING=utf-8

:: Ensure all necessary directories exist
mkdir C:\RuslanAI\logs 2>nul
mkdir C:\RuslanAI\data\vector_store 2>nul

:: Install required dependencies if not present
echo Checking for required dependencies...
python -m pip install --quiet sentence-transformers chromadb torch

:: Start the API server
echo Starting Direct API server
cd C:\RuslanAI\central_agent\backend
python direct_api.py

echo API server stopped
pause