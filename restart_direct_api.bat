@echo off
echo ===================================================
echo Перезапуск прямого API-сервера RuslanAI
echo ===================================================
echo.

:: Переходим в директорию проекта
cd /d %~dp0

:: Проверяем, запущен ли уже сервер
tasklist /fi "IMAGENAME eq python.exe" | find /i "python.exe" > nul
if %ERRORLEVEL% EQU 0 (
    echo Обнаружены запущенные процессы Python. Завершаем их...
    taskkill /f /im python.exe
    timeout /t 2 /nobreak > nul
)

:: Запускаем API-сервер
echo Запуск прямого API-сервера...
start "RuslanAI Direct API" cmd /k "python central_agent\backend\direct_api.py"

echo.
echo ===================================================
echo API-сервер запущен!
echo.
echo Теперь система должна корректно сохранять контекст диалога
echo и работать с векторным хранилищем памяти.
echo ===================================================
echo.