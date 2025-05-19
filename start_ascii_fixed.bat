@echo off
chcp 65001 > nul
echo === Zapusk sistemy RuslanAI s UTF-8 ===

:: Ostanovka suschestvuyuschih processov
taskkill /f /im python.exe > nul 2>&1
taskkill /f /im node.exe > nul 2>&1
timeout /t 2 > nul

:: Zapusk API-servera s ispravlennoy kodirovkoy
echo 1. Zapusk API-servera...
start cmd /k "chcp 65001 && title RuslanAI API (UTF-8) && cd C:\RuslanAI\central_agent\backend && python encoding_fixed_api.py"

:: Ozhidanie zapuska API
echo Ozhidanie zapuska API-servera...
timeout /t 5 > nul

:: Zapusk veb-interfeysa
echo 2. Zapusk veb-interfeysa...
start cmd /k "chcp 65001 && title RuslanAI Web UI && cd C:\RuslanAI\web_ui && npm run dev"

:: Ozhidanie zapuska veb-interfeysa
echo Ozhidanie zapuska veb-interfeysa...
timeout /t 10 > nul

:: Otkrytie brauzera
echo 3. Otkrytie brauzera...
start "" "http://localhost:3000"

echo.
echo Sistema zapuschena:
echo - API-server: http://localhost:8001
echo - Veb-interfeys: http://localhost:3000
echo.
echo Proverte konsoli na nalichie oshibok.
