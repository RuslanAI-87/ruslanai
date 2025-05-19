# restart_fixed_system.ps1 - Скрипт полного перезапуска системы RuslanAI
Write-Host "=== Перезапуск всей системы RuslanAI ===" -ForegroundColor Cyan

# Остановка всех процессов на используемых портах
$ports = @(8001, 8005, 3000, 5173)
foreach ($port in $ports) {
    $processId = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess
    if ($processId) {
        Write-Host "Остановка процесса на порту $port (PID: $processId)" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

# Создание директорий для логов и данных
$logDir = "C:/RuslanAI/logs"
if (-not (Test-Path $logDir)) {
    Write-Host "Создание директории для логов: $logDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Очистка кэша npm в директории web_ui
Set-Location "C:\RuslanAI\web_ui"
Write-Host "Очистка кэша npm..." -ForegroundColor Yellow
npm cache clean --force
Write-Host "Кэш npm очищен" -ForegroundColor Green

# Запуск WebSocket сервера с исправлениями
Write-Host "Запуск WebSocket сервера..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command", "cd C:/RuslanAI/scripts && node simple_websocket_server.js" -WindowStyle Normal
Start-Sleep -Seconds 3

Write-Host "Проверка запуска API сервера..." -ForegroundColor Yellow
$apiStarted = $false
$attempts = 0
while (-not $apiStarted -and $attempts -lt 10) {
    try {
        $testConnection = New-Object System.Net.Sockets.TcpClient
        $testConnection.Connect("localhost", 8001)
        $apiStarted = $true
        $testConnection.Close()
        Write-Host "API сервер успешно запущен на порту 8001" -ForegroundColor Green
    } catch {
        $attempts++
        Start-Sleep -Seconds 1
    }
}

if (-not $apiStarted) {
    Write-Host "ОШИБКА: API сервер не запустился на порту 8001" -ForegroundColor Red
    Write-Host "Продолжение без API сервера..." -ForegroundColor Red
}

# Запуск веб-интерфейса
Write-Host "Запуск веб-интерфейса..." -ForegroundColor Green
Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd C:\RuslanAI\web_ui && npm run dev" -NoNewWindow

# Проверка запуска веб-интерфейса
Write-Host "Ожидание запуска веб-интерфейса..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$webUIStarted = $false
foreach ($port in @(3000, 5173)) {
    try {
        $testConnection = New-Object System.Net.Sockets.TcpClient
        $testConnection.Connect("localhost", $port)
        $webUIStarted = $true
        $testConnection.Close()
        Write-Host "Веб-интерфейс успешно запущен на порту $port" -ForegroundColor Green
        break
    } catch {
        # Порт не занят
    }
}

if (-not $webUIStarted) {
    Write-Host "ВНИМАНИЕ: Не удалось подтвердить запуск веб-интерфейса" -ForegroundColor Yellow
}

# Открытие браузера с адресом веб-интерфейса
Start-Sleep -Seconds 3
Write-Host "Открытие браузера с веб-интерфейсом..." -ForegroundColor Green
Start-Process "http://localhost:3000"

# Информация о запущенных компонентах
Write-Host @"

=== Система RuslanAI перезапущена ===
Компоненты:
- API сервер: http://localhost:8001
- WebSocket: ws://localhost:8001/ws
- Веб-интерфейс: http://localhost:3000 или http://localhost:5173

Для доступа к веб-интерфейсу откройте в браузере http://localhost:3000

Логи в: C:/RuslanAI/logs/

"@ -ForegroundColor Cyan