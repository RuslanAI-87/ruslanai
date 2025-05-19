# start_system.ps1 - Скрипт запуска системы RuslanAI с поддержкой уведомлений
Write-Host "=== Запуск системы RuslanAI с поддержкой уведомлений ===" -ForegroundColor Cyan

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

# Запуск исправленного сервера уведомлений
Write-Host "Запуск исправленного сервера уведомлений..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python C:/RuslanAI/central_agent/modules/fixed_notification_manager.py"
Start-Sleep -Seconds 2

Write-Host "Система успешно запущена с исправленным сервером уведомлений" -ForegroundColor Green
Write-Host @"

=== Инструкции по использованию ===
1. Запустите веб-интерфейс RuslanAI
2. Отправьте запрос центральному оркестратору
3. Дождитесь уведомления о результате выполнения задачи

Уведомления будут автоматически отображаться в веб-интерфейсе
при завершении задачи или возникновении ошибки.

"@ -ForegroundColor Yellow
