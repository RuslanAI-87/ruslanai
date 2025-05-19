# restart_frontend.ps1 - Скрипт для очистки кэша и перезапуска веб-интерфейса
Write-Host "=== Перезапуск веб-интерфейса RuslanAI ===" -ForegroundColor Cyan

# Переходим в директорию web_ui
Set-Location "C:\RuslanAI\web_ui"

# Очищаем кэш npm
Write-Host "Очистка кэша npm..." -ForegroundColor Yellow
npm cache clean --force

# Очищаем директорию node_modules, если это необходимо
$clearNodeModules = $false
if ($clearNodeModules) {
    Write-Host "Удаление node_modules..." -ForegroundColor Yellow
    if (Test-Path "node_modules") {
        Remove-Item -Path "node_modules" -Recurse -Force
    }
}

# Устанавливаем зависимости
Write-Host "Установка зависимостей..." -ForegroundColor Green
npm install

# Остановка существующих процессов на порту 3000 или 5173
$ports = @(3000, 5173)
foreach ($port in $ports) {
    $processId = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess
    if ($processId) {
        Write-Host "Остановка процесса на порту $port (PID: $processId)" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

# Запуск веб-интерфейса с npm
Write-Host "Запуск веб-интерфейса..." -ForegroundColor Green
Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run dev" -NoNewWindow

# Открываем браузер
Write-Host "Открытие браузера..." -ForegroundColor Green
Start-Sleep -Seconds 5
Start-Process "http://localhost:3000"

Write-Host @"

=== Веб-интерфейс перезапущен ===
Адрес: http://localhost:3000

"@ -ForegroundColor Cyan