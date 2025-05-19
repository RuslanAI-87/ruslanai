$content = @'
@echo off
echo === Запуск RuslanAI с улучшенным исполнителем задач ===
echo.

:: Пути к Python и Node.js
set PYTHON=python
set NODE=node

:: Остановка существующих процессов
taskkill /f /im node.exe > nul 2>&1
taskkill /f /im python.exe > nul 2>&1
timeout /t 2 > nul

:: Запуск исполнителя задач (в отдельном окне)
echo 1. Запуск исполнителя задач...
start cmd /k "cd C:\RuslanAI\central_agent\executor && %PYTHON% task_executor.py"

:: Ожидание запуска исполнителя
timeout /t 3 > nul

:: Запуск бэкенда API
echo 2. Запуск API-сервера...
start cmd /k "cd C:\RuslanAI\central_agent\backend && %PYTHON% main.py.new"

:: Ожидание запуска бэкенда
timeout /t 5 > nul

:: Запуск фронтенда
echo 3. Запуск веб-интерфейса...
start cmd /k "cd C:\RuslanAI\web_ui && npm run dev"

echo.
echo === Система запущена ===
echo Исполнитель задач запущен
echo API-сервер: http://localhost:8001
echo Веб-интерфейс: http://localhost:3001
echo.
echo Для остановки всех компонентов закройте все окна терминалов
'@

Set-Content -Path "C:\RuslanAI\start_ruslanai_new.bat" -Value $content
Write-Host "Создан файл запуска C:\RuslanAI\start_ruslanai_new.bat" -ForegroundColor Green