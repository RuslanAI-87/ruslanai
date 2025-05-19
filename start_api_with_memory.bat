@echo off
echo ============================================================
echo  RuslanAI API Server with Memory System
echo ============================================================
echo.
echo This script starts the API server with memory system integration
echo and proper encoding settings
echo.

:: Set UTF-8 for console
chcp 65001

:: Set environment variables
set PYTHONIOENCODING=utf-8
set PYTHONLEGACYWINDOWSSTDIO=utf-8

:: Ensure required directories exist
mkdir C:\RuslanAI\logs 2>nul
mkdir C:\RuslanAI\data\memory\summary 2>nul
mkdir C:\RuslanAI\data\memory\context 2>nul
mkdir C:\RuslanAI\data\memory\detail 2>nul
mkdir C:\RuslanAI\data\vector_store 2>nul

:: Start API server
cd C:\RuslanAI\central_agent\backend
echo Starting API server with memory system...
python direct_api.py

pause