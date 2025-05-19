# venv_setup.ps1
# Скрипт для создания виртуального окружения Python и установки зависимостей

# Проверка установки Python
Write-Host "Проверка установки Python..."
try {
    $pythonVersion = python --version
    Write-Host "Установлен $pythonVersion"
} catch {
    Write-Host "ОШИБКА: Python не установлен или не доступен в PATH"
    exit 1
}

# Переход в директорию проекта
Write-Host "Переход в директорию проекта..."
Set-Location -Path "C:\RuslanAI_Encoding_Test"

# Создание виртуального окружения
Write-Host "Создание виртуального окружения..."
python -m venv venv

# Активация виртуального окружения
Write-Host "Активация виртуального окружения..."
& .\venv\Scripts\Activate.ps1

# Установка основных зависимостей
Write-Host "Установка основных зависимостей..."
pip install chardet
pip install fastapi
pip install uvicorn
pip install websockets

# Установка зависимостей для тестирования
Write-Host "Установка зависимостей для тестирования..."
pip install pytest
pip install pytest-asyncio
pip install httpx

# Сохранение списка установленных зависимостей
Write-Host "Сохранение списка зависимостей..."
pip freeze > requirements.txt

# Запись в лог
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Виртуальное окружение создано. Зависимости установлены." | Out-File -Append -FilePath "C:\RuslanAI_Encoding_Test\logs\setup_log.txt" -Encoding utf8

Write-Host "Виртуальное окружение успешно создано и настроено"
Write-Host "Для активации используйте: .\venv\Scripts\Activate.ps1"