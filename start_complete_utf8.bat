@echo off
chcp 65001 > nul
echo === Запуск полной системы RuslanAI с исправленной кодировкой ===
echo.

:: Остановка существующих процессов
echo Остановка существующих процессов...
taskkill /f /im python.exe > nul 2>&1
taskkill /f /im node.exe > nul 2>&1
timeout /t 2 > nul

:: Запуск API-сервера с исправленной кодировкой
echo 1. Запуск API-сервера с поддержкой UTF-8...
start cmd /k "chcp 65001 && title RuslanAI API (UTF-8) && cd C:\RuslanAI\central_agent\backend && python encoding_fixed_api.py"

:: Ожидание запуска API-сервера
echo Ожидание запуска API-сервера...
timeout /t 5 > nul

:: Запуск веб-интерфейса
echo 2. Запуск веб-интерфейса...
start cmd /k "chcp 65001 && title RuslanAI Web UI && cd C:\RuslanAI\web_ui && npm run dev"

:: Ожидание запуска веб-интерфейса
echo Ожидание запуска веб-интерфейса...
timeout /t 10 > nul

:: Открытие браузера
echo 3. Открытие браузера...
start "" "http://localhost:3000"

echo.
echo Система запущена полностью:
echo - API-сервер: http://localhost:8001
echo - Веб-интерфейс: http://localhost:3000
echo.
echo Проверьте оба консольных окна на наличие ошибок.
