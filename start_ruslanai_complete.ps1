# start_ruslanai_complete.ps1 - Запуск всех компонентов системы RuslanAI

Write-Host "=== Запуск системы RuslanAI с поддержкой WebSocket-уведомлений ===" -ForegroundColor Cyan

# 1. Запуск WebSocket-сервера
Write-Host "1. Запуск WebSocket-сервера..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/scripts; python simple_ws_server.py"
Start-Sleep -Seconds 3

# 2. Запуск центрального оркестратора
Write-Host "2. Запуск центрального оркестратора..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/central_agent/orchestrator; python central_orchestrator.py"
Start-Sleep -Seconds 3

# 3. Запуск API сервера
Write-Host "3. Запуск API сервера..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/central_agent/backend; python encoding_fixed_api.py"
Start-Sleep -Seconds 3

# 4. Запуск веб-интерфейса
Write-Host "4. Запуск веб-интерфейса..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/scripts; python frontend_runner_fixed.py"

Write-Host "`n=== Система RuslanAI запущена ===`n" -ForegroundColor Green
Write-Host "Компоненты системы:" -ForegroundColor Green
Write-Host "1. WebSocket-сервер - ws://localhost:8005" -ForegroundColor Green
Write-Host "2. Центральный оркестратор - обрабатывает запросы и координирует агентов" -ForegroundColor Green
Write-Host "3. API сервер - обрабатывает HTTP-запросы" -ForegroundColor Green
Write-Host "4. Веб-интерфейс - http://localhost:5173" -ForegroundColor Green
