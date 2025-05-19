@echo off
chcp 65001 > nul
echo ===================================================
echo Перезапуск прямого API-сервера RuslanAI (с исправлением кодировки)
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

:: Создаем батник для запуска с правильной кодировкой
echo @echo off > run_api_with_encoding.bat
echo chcp 65001 ^> nul >> run_api_with_encoding.bat
echo set PYTHONIOENCODING=utf-8 >> run_api_with_encoding.bat
echo python central_agent\backend\direct_api.py >> run_api_with_encoding.bat

:: Запускаем API-сервер с исправленной кодировкой
echo Запуск прямого API-сервера с исправленной кодировкой...
start "RuslanAI Direct API" cmd /k "run_api_with_encoding.bat"

echo.
echo ===================================================
echo API-сервер запущен с исправленной кодировкой!
echo.
echo Теперь система должна корректно сохранять контекст диалога
echo и работать с векторным хранилищем памяти.
echo ===================================================
echo.