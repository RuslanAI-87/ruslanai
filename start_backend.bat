@echo off
chcp 65001
echo ===== Запуск системы RuslanAI =====
echo Время запуска: %TIME%

REM Активация виртуального окружения
call C:\RuslanAI\venv\Scripts\activate.bat

REM Добавление ffmpeg в PATH (если используется)
SET PATH=%PATH%;C:\RuslanAI\tools\ffmpeg\bin

cd C:\RuslanAI\central_agent\backend
echo Текущий каталог: %CD%
echo Запуск Python сервера...
python main.py
