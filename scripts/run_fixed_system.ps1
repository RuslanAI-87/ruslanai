# run_fixed_system.ps1 - Скрипт запуска исправленной системы RuslanAI
Write-Host "=== Запуск исправленной системы RuslanAI ===" -ForegroundColor Cyan

# Создание директорий для логов и данных, если они не существуют
$logDir = "C:/RuslanAI/logs"
$dataDir = "C:/RuslanAI/data"
$dataMemoryDir = "C:/RuslanAI/data/memory"

if (-not (Test-Path $logDir)) {
    Write-Host "Создание директории для логов: $logDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

if (-not (Test-Path $dataDir)) {
    Write-Host "Создание директории для данных: $dataDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

if (-not (Test-Path $dataMemoryDir)) {
    Write-Host "Создание директории для памяти: $dataMemoryDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $dataMemoryDir -Force | Out-Null
    
    # Создание поддиректорий для разных уровней памяти
    New-Item -ItemType Directory -Path "$dataMemoryDir/detail" -Force | Out-Null
    New-Item -ItemType Directory -Path "$dataMemoryDir/context" -Force | Out-Null
    New-Item -ItemType Directory -Path "$dataMemoryDir/summary" -Force | Out-Null
}

# Функция для проверки, запущен ли процесс на порту
function Test-PortInUse {
    param (
        [int]$Port
    )
    
    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return ($connections -ne $null)
}

# Функция для остановки процесса на порту
function Stop-ProcessOnPort {
    param (
        [int]$Port
    )
    
    $processId = (Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue).OwningProcess
    if ($processId) {
        Write-Host "Остановка процесса на порту $Port (PID: $processId)" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

# Остановка предыдущих процессов на портах
$ports = @(8001, 8005, 3000, 5173)
foreach ($port in $ports) {
    if (Test-PortInUse -Port $port) {
        Stop-ProcessOnPort -Port $port
    }
}

# Проверка наличия и корректности исправленных файлов
$websocketServicePath = "C:/RuslanAI/web_ui/src/services/websocketService.js"
$ruslanaiComponentPath = "C:/RuslanAI/web_ui/src/components/RuslanAI.jsx"

$checkFiles = @(
    @{
        Path = $websocketServicePath
        Description = "WebSocket Service"
        Check = "ws://localhost:8005"
    },
    @{
        Path = $ruslanaiComponentPath
        Description = "RuslanAI Component"
        Check = "addMessageCallback"
    }
)

$allFilesOk = $true
foreach ($file in $checkFiles) {
    if (-not (Test-Path $file.Path)) {
        Write-Host "ОШИБКА: Файл $($file.Description) не найден: $($file.Path)" -ForegroundColor Red
        $allFilesOk = $false
        continue
    }
    
    $content = Get-Content -Path $file.Path -Raw
    if ($content -notmatch $file.Check) {
        Write-Host "ОШИБКА: Файл $($file.Description) не содержит необходимые исправления" -ForegroundColor Red
        $allFilesOk = $false
    } else {
        Write-Host "Файл $($file.Description) проверен и корректен" -ForegroundColor Green
    }
}

if (-not $allFilesOk) {
    Write-Host "Некоторые файлы не прошли проверку. Пожалуйста, убедитесь, что все исправления были применены." -ForegroundColor Red
}

# Очистка кэша npm
Write-Host "Очистка кэша npm..." -ForegroundColor Yellow
try {
    Start-Process -FilePath "npm" -ArgumentList "cache clean --force" -Wait -NoNewWindow
    Write-Host "Кэш npm очищен" -ForegroundColor Green
} catch {
    Write-Host "Ошибка при очистке кэша npm: $_" -ForegroundColor Red
}

# Запуск улучшенного моста WebSocket-Память
Write-Host "Запуск улучшенного моста WebSocket-Память..." -ForegroundColor Green
$bridgeProcess = Start-Process powershell -ArgumentList "-Command", "cd C:/RuslanAI/scripts && python fixed_direct_bridge.py" -WindowStyle Normal -PassThru

# Проверка запуска моста (ждем до 10 секунд)
$bridgeStarted = $false
$attempts = 0
while (-not $bridgeStarted -and $attempts -lt 10) {
    if (Test-PortInUse -Port 8005) {
        $bridgeStarted = $true
        Write-Host "WebSocket мост успешно запущен на порту 8005" -ForegroundColor Green
    } else {
        Start-Sleep -Seconds 1
        $attempts++
    }
}

if (-not $bridgeStarted) {
    Write-Host "Не удалось запустить WebSocket мост на порту 8005" -ForegroundColor Red
    Write-Host "Пробуем альтернативный способ запуска..." -ForegroundColor Yellow
    
    Stop-ProcessOnPort -Port 8005
    Start-Process python -ArgumentList "C:/RuslanAI/scripts/fixed_direct_bridge.py" -WindowStyle Normal
    Start-Sleep -Seconds 3
}

# Запуск API сервера
Write-Host "Запуск API сервера..." -ForegroundColor Green
$apiProcess = Start-Process powershell -ArgumentList "-Command", "cd C:/RuslanAI/scripts && python fixed_api_server.py" -WindowStyle Normal -PassThru

# Проверка запуска API сервера (ждем до 10 секунд)
$apiStarted = $false
$attempts = 0
while (-not $apiStarted -and $attempts -lt 10) {
    if (Test-PortInUse -Port 8001) {
        $apiStarted = $true
        Write-Host "API сервер успешно запущен на порту 8001" -ForegroundColor Green
    } else {
        Start-Sleep -Seconds 1
        $attempts++
    }
}

if (-not $apiStarted) {
    Write-Host "Не удалось запустить API сервер на порту 8001" -ForegroundColor Red
    Write-Host "Пробуем альтернативный способ запуска..." -ForegroundColor Yellow
    
    Stop-ProcessOnPort -Port 8001
    Start-Process python -ArgumentList "C:/RuslanAI/scripts/fixed_api_server.py" -WindowStyle Normal
    Start-Sleep -Seconds 3
}

# Очистка и запуск веб-интерфейса напрямую через npm
Write-Host "Запуск веб-интерфейса..." -ForegroundColor Green

# Запускаем npm start в директории web_ui
$npmStartProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd C:\RuslanAI\web_ui && npm run dev" -WindowStyle Normal -PassThru

# Проверяем запуск веб-интерфейса
Start-Sleep -Seconds 10
if (Test-PortInUse -Port 3000 -or Test-PortInUse -Port 5173) {
    Write-Host "Веб-интерфейс успешно запущен" -ForegroundColor Green
} else {
    Write-Host "Веб-интерфейс не запустился на ожидаемых портах (3000 или 5173)" -ForegroundColor Red
    Write-Host "Пробуем альтернативный способ запуска..." -ForegroundColor Yellow
    
    # Альтернативный запуск веб-интерфейса через npx
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd C:\RuslanAI\web_ui && npx vite" -WindowStyle Normal
    Start-Sleep -Seconds 5
}

# Информация о запущенных компонентах
Write-Host @"

=== Система RuslanAI успешно запущена ===
WebSocket мост: ws://localhost:8005
API сервер: http://localhost:8001
Веб-интерфейс: http://localhost:3000 или http://localhost:5173

Для доступа к веб-интерфейсу откройте в браузере http://localhost:3000

"@ -ForegroundColor Cyan

# Автоматически открываем браузер с веб-интерфейсом
Start-Process "http://localhost:3000"

# Информация о логах
Write-Host @"
Пути к файлам логов:
- Лог WebSocket моста: C:/RuslanAI/logs/fixed_bridge.log
- Лог API сервера: C:/RuslanAI/logs/api_server.log
"@ -ForegroundColor Yellow