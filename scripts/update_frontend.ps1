# update_frontend.ps1 - Обновление фронтенд-компонентов для работы с мостом

Write-Host "=== Обновление фронтенд-компонентов для работы с мостом ===" -ForegroundColor Cyan

# Путь к файлу websocketService.js
$websocketServicePath = "C:/RuslanAI/web_ui/src/services/websocketService.js"

# Проверка наличия файла
if (-not (Test-Path $websocketServicePath)) {
    Write-Host "Файл не найден: $websocketServicePath" -ForegroundColor Red
    
    # Попробуем поискать альтернативные пути
    $possiblePaths = @(
        "C:/RuslanAI/web/src/services/websocketService.js",
        "C:/RuslanAI/frontend/src/services/websocketService.js",
        "C:/RuslanAI/ui/src/services/websocketService.js"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Write-Host "Найден альтернативный путь: $path" -ForegroundColor Green
            $websocketServicePath = $path
            break
        }
    }
    
    # Если файл все равно не найден, просим пользователя указать путь
    if (-not (Test-Path $websocketServicePath)) {
        Write-Host "Пожалуйста, укажите полный путь к файлу websocketService.js:" -ForegroundColor Yellow
        $userPath = Read-Host
        if (Test-Path $userPath) {
            $websocketServicePath = $userPath
        } else {
            Write-Host "Файл не найден: $userPath" -ForegroundColor Red
            Write-Host "Невозможно продолжить обновление" -ForegroundColor Red
            exit 1
        }
    }
}

# Создание резервной копии
$backupPath = "$websocketServicePath.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
Copy-Item $websocketServicePath -Destination $backupPath
Write-Host "Создана резервная копия: $backupPath" -ForegroundColor Green

# Чтение содержимого файла
$content = Get-Content -Path $websocketServicePath -Raw

# Регулярные выражения для поиска различных вариантов URL
$urlPatterns = @(
    'ws://localhost:8001/ws',
    'wss://localhost:8001/ws',
    'ws://127.0.0.1:8001/ws',
    'wss://127.0.0.1:8001/ws',
    'ws://.+?:8001/ws',
    'wss://.+?:8001/ws'
)

$newUrl = 'ws://localhost:8005'
$originalContent = $content

foreach ($pattern in $urlPatterns) {
    if ($content -match $pattern) {
        Write-Host "Найден URL: $pattern" -ForegroundColor Green
        $content = $content -replace $pattern, $newUrl
        Write-Host "URL изменен на: $newUrl" -ForegroundColor Green
    }
}

# Проверяем, был ли изменен URL
if ($content -eq $originalContent) {
    Write-Host "ВНИМАНИЕ: URL не был изменен. Не найдено ни одного из искомых шаблонов." -ForegroundColor Yellow
    
    # Пытаемся найти другие варианты URL
    if ($content -match "(ws://[^'`"]+)") {
        $foundUrl = $Matches[1]
        Write-Host "Найден другой URL: $foundUrl" -ForegroundColor Yellow
        
        # Спрашиваем пользователя о замене
        Write-Host "Заменить $foundUrl на $newUrl? (y/n)" -ForegroundColor Yellow
        $answer = Read-Host
        
        if ($answer -eq "y") {
            $content = $content -replace [regex]::Escape($foundUrl), $newUrl
            Write-Host "URL изменен на: $newUrl" -ForegroundColor Green
        } else {
            Write-Host "URL не изменен" -ForegroundColor Yellow
        }
    } else {
        Write-Host "В файле не найдено никаких WebSocket URL" -ForegroundColor Red
    }
}

# Сохраняем изменения
Set-Content -Path $websocketServicePath -Value $content

# Проверка необходимости обновления формата сообщений
if ($content -notmatch "task-completed") {
    Write-Host "ВНИМАНИЕ: В файле не найдена обработка сообщений task-completed" -ForegroundColor Yellow
    Write-Host "Возможно, потребуется дополнительная настройка обработчиков сообщений" -ForegroundColor Yellow
}

Write-Host "=== Обновление фронтенд-компонентов завершено ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Для просмотра изменений сравните файлы:" -ForegroundColor Yellow
Write-Host "- Оригинал: $backupPath" -ForegroundColor Yellow
Write-Host "- Обновленный: $websocketServicePath" -ForegroundColor Yellow
