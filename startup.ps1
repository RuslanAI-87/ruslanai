# Скрипт автозапуска компонентов RuslanAI

Write-Host "=== Запуск компонентов RuslanAI ===" -ForegroundColor Cyan

# Остановка процессов на занятых портах
$processId8001 = (Get-NetTCPConnection -LocalPort 8001 -ErrorAction SilentlyContinue).OwningProcess
if ($processId8001) {
    Write-Host "Остановка процесса на порту 8001..." -ForegroundColor Yellow
    Stop-Process -Id $processId8001 -Force -ErrorAction SilentlyContinue
}

$processId8005 = (Get-NetTCPConnection -LocalPort 8005 -ErrorAction SilentlyContinue).OwningProcess
if ($processId8005) {
    Write-Host "Остановка процесса на порту 8005..." -ForegroundColor Yellow
    Stop-Process -Id $processId8005 -Force -ErrorAction SilentlyContinue
}

# Запуск API-сервера
Write-Host "Запуск API-сервера..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python C:/RuslanAI/central_agent/backend/encoding_fixed_api.py"

# Ожидание запуска API-сервера
Start-Sleep -Seconds 5

# Запуск моста WebSocket-память
Write-Host "Запуск моста WebSocket-память..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python C:/RuslanAI/scripts/websocket_memory_bridge.py"

Write-Host "Компоненты запущены. Система готова к работе!" -ForegroundColor Cyan
