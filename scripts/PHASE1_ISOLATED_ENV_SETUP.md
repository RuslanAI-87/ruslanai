# Фаза 1: Создание изолированной среды для внедрения системы управления кодировками

## Цель
Создать изолированную тестовую среду для безопасной разработки и внедрения системы управления кодировками проекта RuslanAI, обеспечив полное копирование структуры проекта и настройку необходимого окружения.

## Задачи
1. Создать копию проекта в изолированной директории
2. Настроить окружение для работы с кодировками
3. Подготовить базовые компоненты системы кодировок для изолированной среды
4. Документировать все внесенные изменения

## Пошаговые инструкции

### 1. Создание изолированной директории и копирование проекта

#### 1.1 Создание директории для тестовой среды

```powershell
# Создаем основную директорию для изолированной среды
New-Item -Path "C:\RuslanAI_Encoding_Test" -ItemType Directory -Force

# Создаем поддиректории по аналогии с основным проектом
New-Item -Path "C:\RuslanAI_Encoding_Test\central_agent" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\web_ui" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\scripts" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\logs" -ItemType Directory -Force

# Создаем дополнительные директории для системы управления кодировками
New-Item -Path "C:\RuslanAI_Encoding_Test\encoding_system" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\tests" -ItemType Directory -Force
New-Item -Path "C:\RuslanAI_Encoding_Test\backup" -ItemType Directory -Force
```

#### 1.2 Копирование структуры проекта

```powershell
# Копируем файлы из основного проекта в изолированную среду
robocopy "C:\RuslanAI\central_agent" "C:\RuslanAI_Encoding_Test\central_agent" /E /XJ
robocopy "C:\RuslanAI\web_ui" "C:\RuslanAI_Encoding_Test\web_ui" /E /XJ
robocopy "C:\RuslanAI\scripts" "C:\RuslanAI_Encoding_Test\scripts" /E /XJ

# Создаем директорию для логов, если её еще нет
if (-not (Test-Path "C:\RuslanAI_Encoding_Test\logs")) {
    New-Item -Path "C:\RuslanAI_Encoding_Test\logs" -ItemType Directory -Force
}

# Копируем лог-файлы, если они существуют (для анализа)
if (Test-Path "C:\RuslanAI\logs") {
    robocopy "C:\RuslanAI\logs" "C:\RuslanAI_Encoding_Test\logs" *.log
}

# Записываем информацию о копировании в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Копирование структуры проекта завершено" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

### 2. Настройка виртуального окружения Python

#### 2.1 Создание виртуального окружения

```powershell
# Переходим в директорию проекта
cd "C:\RuslanAI_Encoding_Test"

# Создаем виртуальное окружение
python -m venv venv

# Активируем виртуальное окружение
.\venv\Scripts\Activate.ps1

# Проверяем версию Python
python --version

# Записываем информацию о создании виртуального окружения в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Виртуальное окружение Python создано" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

#### 2.2 Установка зависимостей

```powershell
# Устанавливаем основные зависимости
pip install chardet==5.2.0
pip install fastapi==0.103.1
pip install uvicorn==0.23.2
pip install websockets==11.0.3

# Устанавливаем зависимости для тестирования
pip install pytest==7.4.2
pip install pytest-asyncio==0.21.1
pip install httpx==0.25.0

# Сохраняем список установленных пакетов
pip freeze > "C:\RuslanAI_Encoding_Test\requirements.txt"

# Записываем информацию об установке зависимостей в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Зависимости установлены. Список сохранен в requirements.txt" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

### 3. Подготовка компонентов системы кодировок

#### 3.1 Копирование базовых компонентов системы кодировок

```powershell
# Копируем файлы системы кодировок в изолированную среду
Copy-Item "C:\RuslanAI\scripts\EncodingManager.py" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force
Copy-Item "C:\RuslanAI\scripts\encoding_standardizer.py" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force
Copy-Item "C:\RuslanAI\scripts\encoding_diagnostics.py" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force
Copy-Item "C:\RuslanAI\scripts\api_encoding_adapter.py" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force
Copy-Item "C:\RuslanAI\scripts\websocket_encoding_adapter.py" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force
Copy-Item "C:\RuslanAI\scripts\memory_encoding_adapter.py" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force
Copy-Item "C:\RuslanAI\scripts\orchestrator_encoding_adapter.py" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force
Copy-Item "C:\RuslanAI\scripts\integrate_encoding_system.py" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force

# Копируем документацию
Copy-Item "C:\RuslanAI\scripts\ENCODING_SYSTEM.md" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force
Copy-Item "C:\RuslanAI\scripts\ENCODING_IMPLEMENTATION_PLAN.md" "C:\RuslanAI_Encoding_Test\encoding_system\" -Force

# Записываем информацию о копировании компонентов в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Базовые компоненты системы кодировок скопированы" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

#### 3.2 Адаптация путей в компонентах для изолированной среды

```powershell
# Создаем скрипт для адаптации путей
$scriptContent = @"
# path_adapter.py - Утилита для адаптации путей в компонентах системы кодировок
import os
import sys
import re
from pathlib import Path

# Пути по умолчанию в исходных файлах
DEFAULT_BASE_PATH = "C:/RuslanAI"

# Новый базовый путь
NEW_BASE_PATH = "C:/RuslanAI_Encoding_Test"

def update_paths_in_file(file_path):
    """Обновляет пути в указанном файле"""
    print(f"Обновление путей в файле: {file_path}")
    
    # Чтение содержимого файла
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Замена путей
    updated_content = content.replace(DEFAULT_BASE_PATH, NEW_BASE_PATH)
    
    # Запись обновленного содержимого
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)
    
    print(f"Обновление путей в файле {file_path} завершено")

def update_all_files(directory):
    """Обновляет пути во всех Python-файлах в указанной директории"""
    print(f"Обработка директории: {directory}")
    
    # Обход всех файлов в директории
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.py'):
                file_path = os.path.join(root, file)
                update_paths_in_file(file_path)

if __name__ == "__main__":
    # Директория с компонентами системы кодировок
    encoding_dir = "C:/RuslanAI_Encoding_Test/encoding_system"
    
    # Обновляем пути в файлах
    update_all_files(encoding_dir)
    
    print("Адаптация путей завершена")
"@

# Создаем файл скрипта
$scriptContent | Out-File -FilePath "C:\RuslanAI_Encoding_Test\encoding_system\path_adapter.py" -Encoding utf8

# Запускаем скрипт для адаптации путей
cd "C:\RuslanAI_Encoding_Test"
python ".\encoding_system\path_adapter.py"

# Записываем информацию об адаптации путей в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Пути в компонентах системы адаптированы для изолированной среды" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

### 4. Создание конфигурационного файла

#### 4.1 Создание файла конфигурации для изолированной среды

```powershell
# Создаем JSON-файл конфигурации
$configContent = @"
{
  "paths": {
    "project_root": "C:/RuslanAI_Encoding_Test",
    "backend_dir": "C:/RuslanAI_Encoding_Test/central_agent",
    "frontend_dir": "C:/RuslanAI_Encoding_Test/web_ui",
    "scripts_dir": "C:/RuslanAI_Encoding_Test/scripts",
    "logs_dir": "C:/RuslanAI_Encoding_Test/logs",
    "encoding_system_dir": "C:/RuslanAI_Encoding_Test/encoding_system",
    "tests_dir": "C:/RuslanAI_Encoding_Test/tests",
    "backup_dir": "C:/RuslanAI_Encoding_Test/backup"
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

# Записываем конфигурацию в файл
$configContent | Out-File -FilePath "C:\RuslanAI_Encoding_Test\encoding_system\config.json" -Encoding utf8

# Записываем информацию о создании конфигурации в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Файл конфигурации создан" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

### 5. Создание скрипта для проверки настройки среды

#### 5.1 Создание тестового скрипта

```powershell
# Создаем скрипт для проверки окружения
$testScript = @"
# test_environment.py - Проверка настройки изолированной среды
import os
import sys
import json
import platform
import locale
import logging
import importlib.util

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('C:/RuslanAI_Encoding_Test/logs/environment_test.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("EnvironmentTest")

def check_path(path, description):
    """Проверяет существование пути"""
    exists = os.path.exists(path)
    logger.info(f"{description}: {path} - {'НАЙДЕН' if exists else 'НЕ НАЙДЕН'}")
    return exists

def check_module(module_name):
    """Проверяет наличие установленного модуля"""
    spec = importlib.util.find_spec(module_name)
    installed = spec is not None
    logger.info(f"Модуль {module_name} - {'УСТАНОВЛЕН' if installed else 'НЕ УСТАНОВЛЕН'}")
    return installed

def check_encoding():
    """Проверяет настройки кодировок в системе"""
    logger.info(f"Кодировка файловой системы: {sys.getfilesystemencoding()}")
    logger.info(f"Кодировка stdout: {sys.stdout.encoding}")
    logger.info(f"Текущая локаль: {locale.getlocale()}")
    logger.info(f"Предпочтительная локаль: {locale.getpreferredencoding()}")
    return True

def load_config():
    """Загружает конфигурационный файл"""
    config_path = "C:/RuslanAI_Encoding_Test/encoding_system/config.json"
    if os.path.exists(config_path):
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
            logger.info(f"Конфигурация загружена: {config_path}")
            return config
        except Exception as e:
            logger.error(f"Ошибка загрузки конфигурации: {e}")
            return None
    else:
        logger.error(f"Файл конфигурации не найден: {config_path}")
        return None

def test_cyrillic():
    """Проверяет поддержку кириллицы"""
    test_string = "Тестовая строка с кириллицей"
    test_file = "C:/RuslanAI_Encoding_Test/logs/cyrillic_test.txt"
    
    try:
        # Записываем строку в файл
        with open(test_file, 'w', encoding='utf-8') as f:
            f.write(test_string)
        logger.info(f"Строка записана в файл: {test_file}")
        
        # Читаем строку из файла
        with open(test_file, 'r', encoding='utf-8') as f:
            content = f.read()
        logger.info(f"Строка прочитана из файла: {content}")
        
        # Проверяем соответствие
        if content == test_string:
            logger.info("Тест кириллицы ПРОЙДЕН")
            return True
        else:
            logger.error("Тест кириллицы НЕ ПРОЙДЕН - строки не совпадают")
            return False
    except Exception as e:
        logger.error(f"Ошибка при тестировании кириллицы: {e}")
        return False

def main():
    """Основная функция проверки среды"""
    logger.info("=== Начало проверки изолированной среды ===")
    
    # Проверяем директории
    check_path("C:/RuslanAI_Encoding_Test", "Корневая директория")
    check_path("C:/RuslanAI_Encoding_Test/central_agent", "Директория бэкенда")
    check_path("C:/RuslanAI_Encoding_Test/web_ui", "Директория фронтенда")
    check_path("C:/RuslanAI_Encoding_Test/scripts", "Директория скриптов")
    check_path("C:/RuslanAI_Encoding_Test/logs", "Директория логов")
    check_path("C:/RuslanAI_Encoding_Test/encoding_system", "Директория системы кодировок")
    
    # Проверяем наличие основных файлов системы кодировок
    check_path("C:/RuslanAI_Encoding_Test/encoding_system/EncodingManager.py", "EncodingManager")
    check_path("C:/RuslanAI_Encoding_Test/encoding_system/encoding_standardizer.py", "Стандартизатор кодировок")
    check_path("C:/RuslanAI_Encoding_Test/encoding_system/encoding_diagnostics.py", "Диагностика кодировок")
    
    # Проверяем модули
    check_module("chardet")
    check_module("fastapi")
    check_module("uvicorn")
    check_module("websockets")
    check_module("pytest")
    
    # Проверяем настройки кодировок
    check_encoding()
    
    # Тестируем кириллицу
    test_cyrillic()
    
    # Загружаем конфигурацию
    config = load_config()
    if config:
        logger.info(f"Версия среды: {config['environment']['version']}")
        logger.info(f"Название среды: {config['environment']['name']}")
        logger.info(f"Дата создания: {config['environment']['created_at']}")
    
    logger.info("=== Проверка изолированной среды завершена ===")

if __name__ == "__main__":
    main()
"@

# Записываем тестовый скрипт в файл
$testScript | Out-File -FilePath "C:\RuslanAI_Encoding_Test\tests\test_environment.py" -Encoding utf8

# Запускаем тестовый скрипт
cd "C:\RuslanAI_Encoding_Test"
python ".\tests\test_environment.py"

# Записываем информацию о запуске тестового скрипта в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Тестовый скрипт создан и запущен" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

### 6. Создание документации для изолированной среды

#### 6.1 Создание README-файла

```powershell
# Создаем README-файл для изолированной среды
$readmeContent = @"
# Изолированная среда для системы управления кодировками RuslanAI

## Обзор

Данная изолированная среда создана для безопасной разработки и тестирования системы управления кодировками проекта RuslanAI. Среда включает полную копию проекта с настроенной инфраструктурой для работы с кодировками.

## Структура директорий

- `central_agent/` - Бэкенд-часть проекта
- `web_ui/` - Фронтенд-часть проекта
- `scripts/` - Оригинальные скрипты проекта
- `encoding_system/` - Компоненты системы управления кодировками
- `tests/` - Тесты для проверки работы системы
- `logs/` - Логи работы системы
- `backup/` - Резервные копии файлов
- `venv/` - Виртуальное окружение Python

## Подготовка к работе

1. Активировать виртуальное окружение:
   ```
   .\venv\Scripts\Activate.ps1
   ```

2. Проверить настройку среды:
   ```
   python .\tests\test_environment.py
   ```

3. Запустить диагностику кодировок:
   ```
   python .\encoding_system\encoding_diagnostics.py --full --output=.\logs\encoding_initial.json
   ```

## Компоненты системы кодировок

- **EncodingManager.py** - Центральный компонент для работы с кодировками
- **encoding_standardizer.py** - Стандартизация кодировок файлов
- **encoding_diagnostics.py** - Диагностика проблем с кодировками
- **api_encoding_adapter.py** - Адаптер для API-сервера
- **websocket_encoding_adapter.py** - Адаптер для WebSocket-сервера
- **memory_encoding_adapter.py** - Адаптер для системы памяти
- **orchestrator_encoding_adapter.py** - Адаптер для оркестратора
- **integrate_encoding_system.py** - Полная интеграция системы

## Документация

Подробная документация по системе управления кодировками доступна в следующих файлах:
- `encoding_system/ENCODING_SYSTEM.md` - Общая документация
- `encoding_system/ENCODING_IMPLEMENTATION_PLAN.md` - План внедрения

## Журнал изменений

Все изменения в изолированной среде документируются в файле `logs/setup_log.txt`.

## Дата создания

$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

# Записываем README в файл
$readmeContent | Out-File -FilePath "C:\RuslanAI_Encoding_Test\README.md" -Encoding utf8

# Записываем информацию о создании README в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] README-файл создан" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

#### 6.2 Создание журнала изменений

```powershell
# Создаем файл для журнала изменений
$changelogContent = @"
# Журнал изменений изолированной среды

## $(Get-Date -Format "yyyy-MM-dd")

### Создание изолированной среды
- Создана базовая структура директорий
- Скопированы файлы проекта из основной директории
- Настроено виртуальное окружение Python
- Установлены необходимые зависимости
- Скопированы и адаптированы компоненты системы кодировок
- Создан конфигурационный файл
- Создан тестовый скрипт для проверки среды
- Создана базовая документация

### Следующие шаги
- Внедрение компонентов системы кодировок в изолированной среде
- Тестирование работы системы с кириллическими символами
- Разработка скриптов миграции для основной системы
"@

# Записываем журнал изменений в файл
$changelogContent | Out-File -FilePath "C:\RuslanAI_Encoding_Test\CHANGELOG.md" -Encoding utf8

# Записываем информацию о создании журнала изменений в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Журнал изменений создан" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

### 7. Создание скрипта для сравнения с основной системой

```powershell
# Создаем скрипт для сравнения с основной системой
$compareScript = @"
# compare_systems.py - Сравнение изолированной среды с основной системой
import os
import sys
import hashlib
import logging
import json
from datetime import datetime

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('C:/RuslanAI_Encoding_Test/logs/comparison.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("SystemComparison")

def calculate_file_hash(file_path):
    """Вычисляет хеш файла"""
    if not os.path.exists(file_path):
        return None
    
    hasher = hashlib.md5()
    with open(file_path, 'rb') as f:
        buf = f.read()
        hasher.update(buf)
    return hasher.hexdigest()

def compare_directories(dir1, dir2, ignore_dirs=None):
    """Сравнивает две директории"""
    if ignore_dirs is None:
        ignore_dirs = []
    
    result = {
        "only_in_dir1": [],
        "only_in_dir2": [],
        "different_files": [],
        "identical_files": []
    }
    
    for root, dirs, files in os.walk(dir1):
        # Пропускаем игнорируемые директории
        if any(ignore_dir in root for ignore_dir in ignore_dirs):
            continue
        
        # Получаем относительный путь
        rel_path = os.path.relpath(root, dir1)
        if rel_path == '.':
            rel_path = ''
        
        # Проверяем наличие соответствующей директории во второй директории
        dir2_path = os.path.join(dir2, rel_path)
        if not os.path.exists(dir2_path):
            result["only_in_dir1"].append(os.path.join(rel_path))
            continue
        
        # Сравниваем файлы
        for file in files:
            file1_path = os.path.join(root, file)
            file2_path = os.path.join(dir2_path, file)
            
            # Проверяем наличие файла во второй директории
            if not os.path.exists(file2_path):
                result["only_in_dir1"].append(os.path.join(rel_path, file))
                continue
            
            # Сравниваем хеши файлов
            hash1 = calculate_file_hash(file1_path)
            hash2 = calculate_file_hash(file2_path)
            
            if hash1 != hash2:
                result["different_files"].append(os.path.join(rel_path, file))
            else:
                result["identical_files"].append(os.path.join(rel_path, file))
    
    # Проверяем файлы, которые есть только во второй директории
    for root, dirs, files in os.walk(dir2):
        # Пропускаем игнорируемые директории
        if any(ignore_dir in root for ignore_dir in ignore_dirs):
            continue
        
        # Получаем относительный путь
        rel_path = os.path.relpath(root, dir2)
        if rel_path == '.':
            rel_path = ''
        
        # Проверяем наличие соответствующей директории в первой директории
        dir1_path = os.path.join(dir1, rel_path)
        if not os.path.exists(dir1_path):
            result["only_in_dir2"].append(os.path.join(rel_path))
            continue
        
        # Проверяем файлы, которые есть только во второй директории
        for file in files:
            file2_path = os.path.join(root, file)
            file1_path = os.path.join(dir1_path, file)
            
            if not os.path.exists(file1_path):
                result["only_in_dir2"].append(os.path.join(rel_path, file))
    
    return result

def main():
    """Основная функция сравнения"""
    logger.info("=== Начало сравнения изолированной среды с основной системой ===")
    
    # Определяем директории для сравнения
    main_system = "C:/RuslanAI"
    isolated_system = "C:/RuslanAI_Encoding_Test"
    
    # Директории для игнорирования
    ignore_dirs = [
        "venv",
        "__pycache__",
        "logs",
        "encoding_system",
        "tests",
        "backup"
    ]
    
    # Сравниваем директории
    result = compare_directories(main_system, isolated_system, ignore_dirs)
    
    # Выводим результаты
    logger.info(f"Файлы, которые есть только в основной системе: {len(result['only_in_dir1'])}")
    for file in result["only_in_dir1"][:10]:  # Выводим только первые 10 файлов
        logger.info(f"  - {file}")
    if len(result["only_in_dir1"]) > 10:
        logger.info(f"  ...и еще {len(result['only_in_dir1']) - 10} файлов")
    
    logger.info(f"Файлы, которые есть только в изолированной среде: {len(result['only_in_dir2'])}")
    for file in result["only_in_dir2"][:10]:
        logger.info(f"  - {file}")
    if len(result["only_in_dir2"]) > 10:
        logger.info(f"  ...и еще {len(result['only_in_dir2']) - 10} файлов")
    
    logger.info(f"Файлы, которые отличаются в двух системах: {len(result['different_files'])}")
    for file in result["different_files"][:10]:
        logger.info(f"  - {file}")
    if len(result["different_files"]) > 10:
        logger.info(f"  ...и еще {len(result['different_files']) - 10} файлов")
    
    logger.info(f"Идентичные файлы: {len(result['identical_files'])}")
    
    # Сохраняем результаты в JSON-файл
    output_file = f"C:/RuslanAI_Encoding_Test/logs/comparison_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    logger.info(f"Результаты сравнения сохранены в файл: {output_file}")
    logger.info("=== Сравнение завершено ===")

if __name__ == "__main__":
    main()
"@

# Записываем скрипт сравнения в файл
$compareScript | Out-File -FilePath "C:\RuslanAI_Encoding_Test\tests\compare_systems.py" -Encoding utf8

# Запускаем скрипт сравнения
cd "C:\RuslanAI_Encoding_Test"
python ".\tests\compare_systems.py"

# Записываем информацию о запуске скрипта сравнения в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Скрипт сравнения систем создан и запущен" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

### 8. Запуск базовой диагностики кодировок

```powershell
# Запускаем диагностику кодировок
cd "C:\RuslanAI_Encoding_Test"
python ".\encoding_system\encoding_diagnostics.py" --full --output="C:\RuslanAI_Encoding_Test\logs\encoding_initial.json"

# Записываем информацию о запуске диагностики в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Выполнена базовая диагностика кодировок" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

### 9. Финальная проверка и завершение

```powershell
# Создаем скрипт для финальной проверки
$finalCheckScript = @"
# final_check.py - Финальная проверка настройки изолированной среды
import os
import sys
import json
import logging
from datetime import datetime

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('C:/RuslanAI_Encoding_Test/logs/final_check.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("FinalCheck")

def check_path_exists(path):
    """Проверяет существование пути"""
    exists = os.path.exists(path)
    return exists

def main():
    """Основная функция финальной проверки"""
    logger.info("=== Финальная проверка настройки изолированной среды ===")
    
    # Список ожидаемых директорий и файлов
    expected_paths = [
        "C:/RuslanAI_Encoding_Test",
        "C:/RuslanAI_Encoding_Test/central_agent",
        "C:/RuslanAI_Encoding_Test/web_ui",
        "C:/RuslanAI_Encoding_Test/scripts",
        "C:/RuslanAI_Encoding_Test/logs",
        "C:/RuslanAI_Encoding_Test/encoding_system",
        "C:/RuslanAI_Encoding_Test/tests",
        "C:/RuslanAI_Encoding_Test/backup",
        "C:/RuslanAI_Encoding_Test/venv",
        "C:/RuslanAI_Encoding_Test/encoding_system/EncodingManager.py",
        "C:/RuslanAI_Encoding_Test/encoding_system/encoding_standardizer.py",
        "C:/RuslanAI_Encoding_Test/encoding_system/encoding_diagnostics.py",
        "C:/RuslanAI_Encoding_Test/encoding_system/api_encoding_adapter.py",
        "C:/RuslanAI_Encoding_Test/encoding_system/websocket_encoding_adapter.py",
        "C:/RuslanAI_Encoding_Test/encoding_system/memory_encoding_adapter.py",
        "C:/RuslanAI_Encoding_Test/encoding_system/orchestrator_encoding_adapter.py",
        "C:/RuslanAI_Encoding_Test/encoding_system/integrate_encoding_system.py",
        "C:/RuslanAI_Encoding_Test/encoding_system/config.json",
        "C:/RuslanAI_Encoding_Test/encoding_system/path_adapter.py",
        "C:/RuslanAI_Encoding_Test/tests/test_environment.py",
        "C:/RuslanAI_Encoding_Test/tests/compare_systems.py",
        "C:/RuslanAI_Encoding_Test/README.md",
        "C:/RuslanAI_Encoding_Test/CHANGELOG.md",
        "C:/RuslanAI_Encoding_Test/requirements.txt",
        "C:/RuslanAI_Encoding_Test/logs/setup_log.txt",
        "C:/RuslanAI_Encoding_Test/logs/environment_test.log",
        "C:/RuslanAI_Encoding_Test/logs/comparison.log",
        "C:/RuslanAI_Encoding_Test/logs/encoding_initial.json"
    ]
    
    # Проверяем наличие всех ожидаемых путей
    missing_paths = []
    for path in expected_paths:
        if not check_path_exists(path):
            missing_paths.append(path)
    
    if missing_paths:
        logger.error("=== ПРОВЕРКА НЕ ПРОЙДЕНА ===")
        logger.error("Отсутствуют следующие пути:")
        for path in missing_paths:
            logger.error(f"  - {path}")
    else:
        logger.info("=== ПРОВЕРКА УСПЕШНО ПРОЙДЕНА ===")
        logger.info("Все ожидаемые пути существуют")
    
    # Создаем отчет о готовности
    report = {
        "timestamp": datetime.now().isoformat(),
        "status": "success" if not missing_paths else "failed",
        "missing_paths": missing_paths,
        "message": "Изолированная среда успешно настроена" if not missing_paths else "Настройка изолированной среды не завершена"
    }
    
    # Сохраняем отчет в файл
    report_file = "C:/RuslanAI_Encoding_Test/logs/readiness_report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    
    logger.info(f"Отчет о готовности сохранен в файл: {report_file}")
    logger.info("=== Финальная проверка завершена ===")
    
    return 0 if not missing_paths else 1

if __name__ == "__main__":
    sys.exit(main())
"@

# Записываем скрипт финальной проверки в файл
$finalCheckScript | Out-File -FilePath "C:\RuslanAI_Encoding_Test\tests\final_check.py" -Encoding utf8

# Запускаем скрипт финальной проверки
cd "C:\RuslanAI_Encoding_Test"
python ".\tests\final_check.py"

# Записываем информацию о завершении настройки в журнал
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Настройка изолированной среды завершена" | Out-File -Append "C:\RuslanAI_Encoding_Test\logs\setup_log.txt"
```

## Проверка результатов

После выполнения всех инструкций должна быть создана полноценная изолированная среда для разработки и тестирования системы управления кодировками.

### Ожидаемая структура директорий

```
C:\RuslanAI_Encoding_Test\
├── backup\                    # Директория для резервных копий
├── central_agent\             # Копия бэкенда
├── encoding_system\           # Компоненты системы кодировок
│   ├── EncodingManager.py
│   ├── api_encoding_adapter.py
│   ├── config.json
│   ├── encoding_diagnostics.py
│   ├── encoding_standardizer.py
│   ├── integrate_encoding_system.py
│   ├── memory_encoding_adapter.py
│   ├── orchestrator_encoding_adapter.py
│   ├── path_adapter.py
│   ├── ENCODING_IMPLEMENTATION_PLAN.md
│   └── ENCODING_SYSTEM.md
├── logs\                      # Логи
│   ├── comparison.log
│   ├── comparison_YYYYMMDD_HHMMSS.json
│   ├── encoding_initial.json
│   ├── environment_test.log
│   ├── final_check.log
│   ├── readiness_report.json
│   └── setup_log.txt
├── scripts\                   # Копия скриптов
├── tests\                     # Тесты
│   ├── compare_systems.py
│   ├── final_check.py
│   └── test_environment.py
├── venv\                      # Виртуальное окружение
├── web_ui\                    # Копия фронтенда
├── CHANGELOG.md               # Журнал изменений
├── README.md                  # Документация
└── requirements.txt           # Список зависимостей
```

## Заключение

Изолированная среда успешно настроена и готова к использованию для разработки и тестирования системы управления кодировками. Следующим шагом будет интеграция компонентов системы с копиями файлов проекта в изолированной среде и проведение комплексного тестирования.

## Следующие шаги

1. Интеграция EncodingManager с основными компонентами
2. Настройка стандартизатора кодировок для проекта
3. Тестирование системы на реальных данных
4. Разработка скриптов миграции для основной системы