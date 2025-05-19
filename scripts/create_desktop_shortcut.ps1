# create_desktop_shortcut.ps1 - Создание ярлыка RuslanAI на рабочем столе
Write-Host "=== Создание ярлыка RuslanAI на рабочем столе ===" -ForegroundColor Cyan

# Путь к скрипту запуска
$startupScriptPath = "C:\RuslanAI\scripts\complete_startup.ps1"

# Проверяем, существует ли скрипт запуска
if (-not (Test-Path $startupScriptPath)) {
    Write-Host "Скрипт запуска не найден: $startupScriptPath" -ForegroundColor Red
    
    # Создаем директорию скриптов, если ее нет
    $scriptsDir = "C:\RuslanAI\scripts"
    if (-not (Test-Path $scriptsDir)) {
        Write-Host "Создание директории скриптов: $scriptsDir" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
    }
    
    # Проверяем, был ли скопирован скрипт запуска
    $sourceScriptPath = $PSScriptRoot + "\complete_startup.ps1"
    if (Test-Path $sourceScriptPath) {
        Write-Host "Копирование скрипта запуска из текущей директории" -ForegroundColor Yellow
        Copy-Item -Path $sourceScriptPath -Destination $startupScriptPath -Force
    } else {
        Write-Host "Скрипт запуска не найден и в текущей директории" -ForegroundColor Red
        Write-Host "Пожалуйста, сначала запустите diagnose_and_fix.py для подготовки системы" -ForegroundColor Yellow
        exit 1
    }
}

# Получение пути к рабочему столу
$desktopPath = [Environment]::GetFolderPath("Desktop")
Write-Host "Путь к рабочему столу: $desktopPath" -ForegroundColor DarkGray

# Создание ярлыка
try {
    # Создаем COM-объект для работы с ярлыками
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$desktopPath\RuslanAI.lnk")
    
    # Настраиваем свойства ярлыка
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$startupScriptPath`""
    $Shortcut.WorkingDirectory = "C:\RuslanAI\scripts"
    $Shortcut.IconLocation = "C:\Windows\System32\SHELL32.dll,43"  # 43 - индекс иконки с компьютером
    $Shortcut.Description = "Запуск RuslanAI Web Interface"
    $Shortcut.WindowStyle = 1  # Нормальное окно
    
    # Сохраняем ярлык
    $Shortcut.Save()
    
    Write-Host "Ярлык успешно создан: $desktopPath\RuslanAI.lnk" -ForegroundColor Green
    
    # Проверяем, что ярлык создан
    if (Test-Path "$desktopPath\RuslanAI.lnk") {
        Write-Host @"

=== Инструкции по использованию ===
1. Теперь вы можете запустить RuslanAI, щелкнув на ярлык "RuslanAI" на рабочем столе
2. Система запустит все необходимые компоненты автоматически
3. Веб-интерфейс будет доступен по адресу: http://localhost:3000 или http://localhost:5173

"@ -ForegroundColor Cyan
    } else {
        Write-Host "Ярлык не был создан по неизвестной причине" -ForegroundColor Red
    }
} catch {
    Write-Host "Ошибка при создании ярлыка: $_" -ForegroundColor Red
    
    # Альтернативный способ создания ярлыка через команду CMD
    Write-Host "Попытка создания ярлыка альтернативным способом..." -ForegroundColor Yellow
    
    $shortcutPath = "$desktopPath\RuslanAI.lnk"
    $targetPath = "powershell.exe"
    $arguments = "-ExecutionPolicy Bypass -File `"$startupScriptPath`""
    $workingDir = "C:\RuslanAI\scripts"
    $iconLocation = "C:\Windows\System32\SHELL32.dll,43"
    
    $command = @"
@echo off
echo Creating shortcut...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('$shortcutPath'); $Shortcut.TargetPath = '$targetPath'; $Shortcut.Arguments = '$arguments'; $Shortcut.WorkingDirectory = '$workingDir'; $Shortcut.IconLocation = '$iconLocation'; $Shortcut.Description = 'Запуск RuslanAI Web Interface'; $Shortcut.Save()"
echo Done!
"@
    
    $tempBatch = "$env:TEMP\create_shortcut.bat"
    Set-Content -Path $tempBatch -Value $command -Encoding ASCII
    
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$tempBatch`"" -Wait
    
    Remove-Item -Path $tempBatch -Force
    
    if (Test-Path "$desktopPath\RuslanAI.lnk") {
        Write-Host "Ярлык успешно создан альтернативным способом" -ForegroundColor Green
    } else {
        Write-Host "Не удалось создать ярлык" -ForegroundColor Red
    }
}