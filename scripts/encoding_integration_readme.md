# Руководство по интеграции системы управления кодировками

## 1. Обзор подхода

Данное руководство описывает поэтапный процесс создания и интеграции системы управления кодировками для проекта RuslanAI в изолированной среде. Процесс разделен на несколько небольших шагов для обеспечения надежности и контроля.

## 2. Структура компонентов

### 2.1 Скрипты настройки изолированной среды

- **isolated_env_setup.ps1** - Создание изолированной директории и копирование структуры проекта
- **venv_setup.ps1** - Настройка виртуального окружения Python и установка зависимостей

### 2.2 Базовые компоненты системы кодировок

- **minimal_encoding_manager.py** - Минимальная версия EncodingManager с базовыми функциями
- **minimal_encoding_test.py** - Тесты для базовой функциональности EncodingManager

## 3. Пошаговые инструкции по настройке

### Шаг 1: Создание изолированной среды

1. Запустите скрипт для создания структуры директорий и копирования файлов:
   ```powershell
   .\isolated_env_setup.ps1
   ```

2. Запустите скрипт для настройки виртуального окружения:
   ```powershell
   .\venv_setup.ps1
   ```

### Шаг 2: Настройка базовых компонентов

1. Скопируйте базовый файл EncodingManager:
   ```powershell
   Copy-Item minimal_encoding_manager.py C:\RuslanAI_Encoding_Test\encoding_system\EncodingManager.py
   ```

2. Запустите тесты для проверки базовой функциональности:
   ```powershell
   cd C:\RuslanAI_Encoding_Test
   .\venv\Scripts\Activate.ps1
   python .\encoding_system\minimal_encoding_test.py
   ```

## 4. Интеграция с компонентами системы

После настройки базовой функциональности, вы можете интегрировать EncodingManager с различными компонентами системы:

### 4.1 Интеграция с файловыми операциями

```python
# Импорт EncodingManager
from EncodingManager import EncodingManager

# Чтение файла с поддержкой кодировок
def safe_read_file(file_path):
    try:
        return EncodingManager.read_file(file_path)
    except Exception as e:
        print(f"Ошибка при чтении файла: {e}")
        return None

# Запись файла с поддержкой кодировок
def safe_write_file(file_path, content):
    try:
        EncodingManager.write_file(file_path, content, encoding='utf-8')
        return True
    except Exception as e:
        print(f"Ошибка при записи файла: {e}")
        return False
```

### 4.2 Интеграция с JSON-операциями

```python
# Импорт EncodingManager
from EncodingManager import EncodingManager

# Загрузка JSON с поддержкой кодировок
def safe_load_json(json_str):
    try:
        return EncodingManager.json_loads(json_str)
    except Exception as e:
        print(f"Ошибка при разборе JSON: {e}")
        return {}

# Сериализация в JSON с поддержкой кодировок
def safe_dump_json(data):
    try:
        return EncodingManager.json_dumps(data, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"Ошибка при сериализации JSON: {e}")
        return "{}"
```

### 4.3 Проверка текста на проблемы с кодировкой

```python
# Импорт EncodingManager
from EncodingManager import EncodingManager

# Функция проверки строки на проблемы с кодировкой
def validate_text(text):
    is_valid, issue = EncodingManager.check_text(text)
    if not is_valid:
        print(f"Предупреждение: {issue}")
    return is_valid
```

## 5. Дальнейшие шаги

После успешной интеграции базовых компонентов и проверки их работоспособности, следует:

1. Расширить функциональность EncodingManager дополнительными методами
2. Разработать адаптеры для конкретных компонентов системы (API, WebSocket, Memory)
3. Создать скрипты для стандартизации кодировок файлов проекта
4. Разработать инструменты диагностики проблем с кодировками

## 6. Рекомендации по разработке

- Всегда добавляйте информативные сообщения об ошибках
- Используйте параметр `ensure_ascii=False` при работе с JSON
- Явно указывайте кодировку `utf-8` при операциях с файлами
- Добавляйте тесты для новой функциональности
- Документируйте все изменения в коде

## 7. Важные замечания

- Все пути к файлам должны быть абсолютными для надежности
- При обработке текста проверяйте на наличие символов-заменителей (�)
- Используйте обработку исключений для операций с файлами и JSON
- Логируйте все важные действия и ошибки