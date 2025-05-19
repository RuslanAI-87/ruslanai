# create_fixed_shortcut.ps1 - Создание ярлыка на рабочем столе для запуска исправленной системы
Write-Host "=== Создание ярлыка для запуска исправленной системы RuslanAI ===" -ForegroundColor Cyan

# Получаем путь к рабочему столу
$desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"))

# Путь к скрипту запуска
$startupScript = "C:\RuslanAI\scripts\run_fixed_system.ps1"

# Проверяем существование скрипта запуска
if (-not (Test-Path $startupScript)) {
    Write-Host "ОШИБКА: Скрипт запуска не найден: $startupScript" -ForegroundColor Red
    exit 1
}

# Создаем PowerShell скрипт для создания ярлыка
$createShortcutScript = @"
`$WshShell = New-Object -ComObject WScript.Shell
`$Shortcut = `$WshShell.CreateShortcut("$desktopPath\RuslanAI Fixed.lnk")
`$Shortcut.TargetPath = "powershell.exe"
`$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$startupScript`""
`$Shortcut.WorkingDirectory = "C:\RuslanAI\scripts"
`$Shortcut.IconLocation = "C:\Windows\System32\SHELL32.dll,43"
`$Shortcut.Description = "Запуск исправленной RuslanAI системы"
`$Shortcut.Save()
"@

# Сохраняем временный скрипт
$tempScriptPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "create_shortcut_$(Get-Random).ps1")
$createShortcutScript | Out-File -FilePath $tempScriptPath -Encoding utf8

# Запускаем скрипт для создания ярлыка
try {
    & powershell.exe -ExecutionPolicy Bypass -File $tempScriptPath
    Write-Host "Ярлык успешно создан на рабочем столе: RuslanAI Fixed.lnk" -ForegroundColor Green
    Write-Host "Для запуска системы щелкните по ярлыку или выполните: $startupScript" -ForegroundColor Cyan
} catch {
    Write-Host "Ошибка при создании ярлыка: $_" -ForegroundColor Red
} finally {
    # Удаляем временный скрипт
    if (Test-Path $tempScriptPath) {
        Remove-Item $tempScriptPath -Force
    }
}

# Отображаем информацию о запуске
Write-Host @"

=== Использование ярлыка ===
1. Дважды щелкните по ярлыку "RuslanAI Fixed" на рабочем столе
2. Это запустит все компоненты системы (WebSocket мост, API сервер, веб-интерфейс)
3. Браузер автоматически откроется с адресом: http://localhost:3000

Для ручного запуска вы можете выполнить:
powershell.exe -ExecutionPolicy Bypass -File "$startupScript"

"@ -ForegroundColor Yellow