# isolated_env_setup.ps1
# Скрипт для создания изолированной среды разработки системы кодировок RuslanAI

# Создание основных директорий
Write-Host "Создание основных директорий..."
New-Item -Path "C:\RuslanAI_Encoding_Test" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\central_agent" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\web_ui" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\scripts" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\logs" -ItemType Directory -Force

# Создание дополнительных директорий для системы кодировок
Write-Host "Создание дополнительных директорий..."
New-Item -Path "C:\RuslanAI_Encoding_Test\encoding_system" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\tests" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\backup" -ItemType Directory -Force

# Копирование структуры проекта
Write-Host "Копирование структуры проекта..."
if (Test-Path "C:\RuslanAI\central_agent") {
    robocopy "C:\RuslanAI\central_agent" "C:\RuslanAI_Encoding_Test\central_agent" /E /XJ
    Write-Host "Директория central_agent скопирована"
} else {
    Write-Host "Директория C:\RuslanAI\central_agent не существует"
}

if (Test-Path "C:\RuslanAI\web_ui") {
    robocopy "C:\RuslanAI\web_ui" "C:\RuslanAI_Encoding_Test\web_ui" /E /XJ
    Write-Host "Директория web_ui скопирована"
} else {
    Write-Host "Директория C:\RuslanAI\web_ui не существует"
}

if (Test-Path "C:\RuslanAI\scripts") {
    robocopy "C:\RuslanAI\scripts" "C:\RuslanAI_Encoding_Test\scripts" /E /XJ
    Write-Host "Директория scripts скопирована"
} else {
    Write-Host "Директория C:\RuslanAI\scripts не существует"
}

# Создание лог-файла
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Изолированная среда создана" | Out-File -FilePath "C:\RuslanAI_Encoding_Test\logs\setup_log.txt" -Encoding utf8

Write-Host "Изолированная среда успешно создана в C:\RuslanAI_Encoding_Test"