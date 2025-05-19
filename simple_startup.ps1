# simple_startup.ps1 - Запуск простого WebSocket сервера
Write-Host "=== Запуск простого сервера WebSocket ===" -ForegroundColor Cyan

# Остановка предыдущих процессов на порту 8005
$processId = (Get-NetTCPConnection -LocalPort 8005 -ErrorAction SilentlyContinue).OwningProcess
if ($processId) {
    Write-Host "Остановка процесса на порту 8005 (PID: $processId)" -ForegroundColor Yellow
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# Запуск простого WebSocket сервера
Write-Host "Запуск простого WebSocket сервера..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python C:/RuslanAI/scripts/simple_ws_server.py"
Start-Sleep -Seconds 2

Write-Host "Сервер успешно запущен!" -ForegroundColor Green
Write-Host @"

=== Запуск клиента для тестирования ===
Выполните следующую команду в отдельном окне PowerShell:
python C:/RuslanAI/scripts/simple_ws_client.py

"@ -ForegroundColor Yellow
