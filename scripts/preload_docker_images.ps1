# Скрипт для загрузки необходимых Docker-образов

Write-Host "=== Загрузка необходимых Docker-образов ===" -ForegroundColor Cyan

$images = @(
    "pytorch/pytorch:latest",
    "node:16-alpine",
    "bash:5.1",
    "python:3.9-slim"
)

foreach ($image in $images) {
    Write-Host "Загрузка образа: $image" -ForegroundColor Green
    docker pull $image
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Образ $image успешно загружен" -ForegroundColor Green
    } else {
        Write-Host "Ошибка загрузки образа $image" -ForegroundColor Red
    }
}

Write-Host "=== Загрузка образов завершена ===" -ForegroundColor Cyan
