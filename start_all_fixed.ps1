# start_all_fixed.ps1 - Исправленный скрипт для запуска всех компонентов RuslanAI
Write-Host "=== Запуск всех компонентов RuslanAI с исправлениями ===" -ForegroundColor Cyan

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

# 2. Исправление ошибки в backend и его запуск
Write-Host "2. Исправление ошибки в backend..." -ForegroundColor Yellow

# Путь к файлу backend
$backend_file = "C:/RuslanAI/central_agent/backend/encoding_fixed_api.py"

# Создаем резервную копию
Copy-Item -Path $backend_file -Destination "$backend_file.bak" -Force
Write-Host "   Создана резервная копия: $backend_file.bak" -ForegroundColor Gray

# Читаем содержимое файла
$backend_content = Get-Content -Path $backend_file -Raw

# Исправляем ошибку с logger - добавляем импорт логгера, если его нет
if ($backend_content -notmatch "import\s+logging") {
    $backend_content = "import logging`n$backend_content"
    Write-Host "   Добавлен импорт модуля logging" -ForegroundColor Gray
}

# Проверяем определение logger
if ($backend_content -notmatch "logger\s*=\s*logging\.getLogger\(") {
    # Добавляем определение логгера после импортов
    $import_section_end = $backend_content.IndexOf("import")
    $import_section_end = $backend_content.IndexOf("`n", $import_section_end)
    $backend_content = $backend_content.Insert($import_section_end + 1, "`n# Настройка логирования`nlogger = logging.getLogger(__name__)`n")
    Write-Host "   Добавлено определение logger" -ForegroundColor Gray
}

# Сохраняем исправленный файл
$backend_content | Set-Content -Path $backend_file -Encoding UTF8
Write-Host "   Backend исправлен" -ForegroundColor Green

# Запускаем backend
Write-Host "3. Запуск Backend (API сервера)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/central_agent/backend; python encoding_fixed_api.py"
Start-Sleep -Seconds 3

# 4. Исправление и запуск Frontend
Write-Host "4. Исправление и запуск Frontend..." -ForegroundColor Yellow

# Проверяем package.json на наличие скрипта start
$package_json_path = "C:/RuslanAI/web_ui/package.json"
if (Test-Path $package_json_path) {
    $package_json = Get-Content -Path $package_json_path -Raw | ConvertFrom-Json
    
    # Проверяем есть ли scripts и start
    if (-not ($package_json.scripts -and $package_json.scripts.start)) {
        Write-Host "   В package.json отсутствует скрипт 'start', добавляем..." -ForegroundColor Gray
        
        # Создаем резервную копию
        Copy-Item -Path $package_json_path -Destination "$package_json_path.bak" -Force
        
        # Если scripts не существует, создаем
        if (-not $package_json.scripts) {
            $package_json | Add-Member -Type NoteProperty -Name "scripts" -Value @{}
        }
        
        # Добавляем скрипт start
        $package_json.scripts | Add-Member -Type NoteProperty -Name "start" -Value "react-scripts start" -Force
        
        # Сохраняем изменения
        $package_json | ConvertTo-Json -Depth 10 | Set-Content -Path $package_json_path -Encoding UTF8
        Write-Host "   Скрипт 'start' добавлен в package.json" -ForegroundColor Gray
    }
}

# Запускаем frontend с учетом возможной структуры проекта
Write-Host "5. Запуск Frontend..." -ForegroundColor Green
$command = @"
cd C:/RuslanAI/web_ui
if (Test-Path 'package.json') {
    # Проверяем, есть ли node_modules
    if (-not (Test-Path 'node_modules')) {
        Write-Host 'Установка зависимостей npm...' -ForegroundColor Yellow
        npm install
    }
    # Запускаем через доступные скрипты
    if (npm run) {
        if (npm run | Select-String 'start') {
            npm run start
        } elseif (npm run | Select-String 'dev') {
            npm run dev
        } else {
            Write-Host 'Не найден скрипт запуска. Пробуем запустить напрямую.' -ForegroundColor Yellow
            npx react-scripts start
        }
    } else {
        npx react-scripts start
    }
} else {
    Write-Host 'Не найден package.json. Проверьте структуру проекта.' -ForegroundColor Red
}
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command", $command

Write-Host @"

=== Все компоненты RuslanAI запущены с исправлениями ===

Произведенные исправления:
1. Добавлен модуль logging и определение logger в backend
2. Проверен и при необходимости добавлен скрипт 'start' в package.json
3. Улучшен запуск frontend с проверкой структуры проекта

Веб-интерфейс должен запуститься автоматически в браузере.
Если этого не произошло, проверьте окно PowerShell с запуском frontend.

"@ -ForegroundColor Yellow
