# start_all.ps1 - Скрипт для запуска всех компонентов RuslanAI
Write-Host "=== Запуск всех компонентов RuslanAI ===" -ForegroundColor Cyan

# Функция для проверки, запущен ли процесс на порту
function Test-PortInUse {
    param(
        [int]$Port
    )
    
    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return ($connections -ne $null)
}

# 1. Запуск WebSocket сервера (если не запущен)
if (-not (Test-PortInUse -Port 8005)) {
    Write-Host "1. Запуск WebSocket сервера..." -ForegroundColor Green
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/scripts; python simple_ws_server.py"
    Start-Sleep -Seconds 2
} else {
    Write-Host "1. WebSocket сервер уже запущен на порту 8005" -ForegroundColor Green
}

# 2. Запуск Backend (API сервера)
Write-Host "2. Запуск Backend (API сервера)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/central_agent/backend; python encoding_fixed_api.py"
Start-Sleep -Seconds 3

# 3. Запуск Frontend (веб-интерфейса)
Write-Host "3. Запуск Frontend (веб-интерфейса)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/web_ui; npm start"

Write-Host @"

=== Все компоненты RuslanAI запущены ===

Компоненты:
1. WebSocket сервер - обеспечивает обратную связь от агента
2. Backend (API) - обрабатывает запросы к оркестратору
3. Frontend - веб-интерфейс для взаимодействия

Веб-интерфейс должен автоматически открыться в браузере.
Если этого не произошло, откройте: http://localhost:3000

"@ -ForegroundColor Yellow
