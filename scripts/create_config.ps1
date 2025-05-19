# create_config.ps1
# Скрипт для создания конфигурационного файла системы кодировок

# Создание директории для конфигурации
Write-Host "Создание директории для конфигурации..."
New-Item -Path "C:\RuslanAI_Encoding_Test\encoding_system" -ItemType Directory -Force

# JSON-конфигурация
$configJson = @"
{
  "paths": {
    "project_root": "C:/RuslanAI_Encoding_Test",
    "backend_dir": "C:/RuslanAI_Encoding_Test/central_agent",
    "frontend_dir": "C:/RuslanAI_Encoding_Test/web_ui",
    "scripts_dir": "C:/RuslanAI_Encoding_Test/scripts",
    "logs_dir": "C:/RuslanAI_Encoding_Test/logs",
    "encoding_system_dir": "C:/RuslanAI_Encoding_Test/encoding_system",
    "tests_dir": "C:/RuslanAI_Encoding_Test/tests"
  },
  "encoding": {
    "default": "utf-8",
    "remove_bom": true,
    "detect_limit_kb": 64
  },
  "logging": {
    "level": "INFO",
    "file_size_limit_mb": 10,
    "backup_count": 5
  },
  "environment": {
    "name": "isolated_test",
    "version": "1.0.0",
    "created_at": "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
  }
}
"@

# Запись конфигурации в файл
Write-Host "Запись конфигурации в файл..."
$configJson | Out-File -FilePath "C:\RuslanAI_Encoding_Test\encoding_system\config.json" -Encoding utf8

# Создание лог-директории, если она не существует
if (-not (Test-Path "C:\RuslanAI_Encoding_Test\logs")) {
    New-Item -Path "C:\RuslanAI_Encoding_Test\logs" -ItemType Directory -Force
}

# Запись в лог
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Конфигурационный файл создан" | Out-File -Append -FilePath "C:\RuslanAI_Encoding_Test\logs\setup_log.txt" -Encoding utf8

Write-Host "Конфигурационный файл успешно создан в C:\RuslanAI_Encoding_Test\encoding_system\config.json"