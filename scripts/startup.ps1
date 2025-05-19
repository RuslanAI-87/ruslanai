# startup.ps1 - Скрипт запуска компонентов RuslanAI
Write-Host "=== Запуск компонентов RuslanAI ===" -ForegroundColor Cyan

# Остановка предыдущих процессов на портах
$ports = @(8001, 8005)
foreach ($port in $ports) {
    $processId = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess
    if ($processId) {
        Write-Host "Остановка процесса на порту $port (PID: $processId)" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

# Запуск улучшенного моста
Write-Host "Запуск улучшенного моста WebSocket-Память..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python C:/RuslanAI/scripts/fixed_direct_bridge.py"

Write-Host "Компоненты запущены" -ForegroundColor Green
Write-Host "WebSocket мост: http://localhost:8005" -ForegroundColor Cyan

# Инструкции по тестированию
Write-Host @"

=== Инструкции по тестированию ===
1. Веб-интерфейс уже настроен на подключение к порту 8005
2. Отправьте тестовое сообщение через веб-интерфейс
3. Проверьте логи для анализа результатов:
   - Логи моста: C:/RuslanAI/logs/fixed_bridge.log
   - Логи памяти: C:/RuslanAI/logs/memory_system.log

"@ -ForegroundColor Yellow
