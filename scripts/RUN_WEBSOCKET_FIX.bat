@echo off
REM Run WebSocket Connection Fix for RuslanAI
REM This batch file runs the PowerShell script to fix WebSocket connection issues

echo Starting WebSocket Connection Fix...
echo.

REM Fix Cyrillic encoding in RuslanAI.jsx first
python "%~dp0fix_ruslanai_encoding.py"

REM Run PowerShell script with bypass execution policy
powershell -ExecutionPolicy Bypass -File "%~dp0fix_websocket_connection.ps1"

echo.
echo Fix completed. Check the logs for details.
echo Documentation is available at C:\RuslanAI\WEBSOCKET_FIX.md
echo.
echo Press any key to exit...
pause > nul