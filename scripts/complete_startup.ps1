# complete_startup.ps1 - Полный скрипт запуска RuslanAI с отладкой кодировок
Write-Host "=== Запуск системы RuslanAI ===" -ForegroundColor Cyan

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

# Устранение проблем с кодировками в JSON-файлах в директории памяти
Write-Host "Проверка и исправление проблем с кодировками в файлах памяти..." -ForegroundColor Green
$memoryFiles = Get-ChildItem -Path $dataMemoryDir -Recurse -Filter "*.json"

foreach ($file in $memoryFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        # Проверка наличия BOM-маркера
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        
        if ($hasBom) {
            Write-Host "Исправление BOM-маркера в файле: $($file.FullName)" -ForegroundColor Yellow
            $content = [System.IO.File]::ReadAllText($file.FullName)
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
        }
        
        # Проверка валидности JSON
        try {
            $json = ConvertFrom-Json $content -ErrorAction Stop
        } catch {
            Write-Host "Найден невалидный JSON в файле: $($file.FullName)" -ForegroundColor Red
            Write-Host "Будет создана резервная копия и файл будет восстановлен" -ForegroundColor Yellow
            
            # Создание резервной копии
            Copy-Item -Path $file.FullName -Destination "$($file.FullName).bak" -Force
            
            # Создание базового валидного файла
            $defaultJson = @{
                id = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                content = "Восстановленная запись"
                tags = @("restored", "fixed")
                timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
                level = $file.Directory.Name
                importance = 3
                source = "encoding_fix"
            } | ConvertTo-Json -Depth 4
            
            [System.IO.File]::WriteAllText($file.FullName, $defaultJson, [System.Text.UTF8Encoding]::new($false))
        }
    } catch {
        Write-Host "Ошибка при обработке файла $($file.FullName): $_" -ForegroundColor Red
    }
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

# Проверка моста с помощью простого клиента
Write-Host "Проверка работоспособности WebSocket моста..." -ForegroundColor Yellow
$testClientResult = $null
try {
    $testClientResult = & python -c "
import asyncio
import websockets
import json

async def test_ws():
    try:
        async with websockets.connect('ws://localhost:8005') as websocket:
            await websocket.send(json.dumps({
                'content': 'Тестовое сообщение с кириллицей',
                'chat_id': 'test_chat_id'
            }))
            response = await websocket.recv()
            print('Получен ответ от сервера')
            return True
    except Exception as e:
        print(f'Ошибка при подключении к WebSocket мосту: {e}')
        return False

print(asyncio.run(test_ws()))
"
    
    if ($testClientResult -match "True") {
        Write-Host "WebSocket мост успешно ответил на тестовое сообщение" -ForegroundColor Green
    } else {
        Write-Host "WebSocket мост не ответил корректно на тестовое сообщение" -ForegroundColor Red
    }
} catch {
    Write-Host "Ошибка при тестировании WebSocket моста: $_" -ForegroundColor Red
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

# Настройка веб-интерфейса
Write-Host "Настройка и запуск веб-интерфейса..." -ForegroundColor Green

# Проверяем и исправляем конфигурацию WebSocket соединения в веб-интерфейсе
$webSocketServicePath = "C:/RuslanAI/web_ui/src/services/websocketService.js"
if (Test-Path $webSocketServicePath) {
    try {
        $content = Get-Content -Path $webSocketServicePath -Raw -Encoding UTF8
        
        # Проверка наличия правильного URL для WebSocket
        if ($content -notmatch "ws://localhost:8005") {
            Write-Host "Исправление URL WebSocket в $webSocketServicePath" -ForegroundColor Yellow
            
            # Создание резервной копии
            Copy-Item -Path $webSocketServicePath -Destination "$webSocketServicePath.bak" -Force
            
            # Замена URL
            $content = $content -replace "ws://[^'`"]+", "ws://localhost:8005"
            [System.IO.File]::WriteAllText($webSocketServicePath, $content, [System.Text.UTF8Encoding]::new($false))
        } else {
            Write-Host "URL WebSocket настроен правильно" -ForegroundColor Green
        }
    } catch {
        Write-Host "Ошибка при обработке файла $webSocketServicePath: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Файл конфигурации WebSocket не найден: $webSocketServicePath" -ForegroundColor Red
}

# Запуск веб-интерфейса
Write-Host "Запуск веб-интерфейса..." -ForegroundColor Green
$webUIProcess = Start-Process powershell -ArgumentList "-Command", "cd C:/RuslanAI/scripts && python frontend_runner_fixed.py" -WindowStyle Normal -PassThru

# Проверяем запуск веб-интерфейса
Start-Sleep -Seconds 5
if (Test-PortInUse -Port 3000 -or Test-PortInUse -Port 5173) {
    Write-Host "Веб-интерфейс успешно запущен" -ForegroundColor Green
} else {
    Write-Host "Веб-интерфейс не запустился на ожидаемых портах (3000 или 5173)" -ForegroundColor Yellow
    Write-Host "Пробуем альтернативный способ запуска..." -ForegroundColor Yellow
    
    # Альтернативный запуск веб-интерфейса
    $null = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd C:\RuslanAI\web_ui && npm start" -WindowStyle Normal
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