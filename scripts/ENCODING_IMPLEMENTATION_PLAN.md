# План внедрения системы управления кодировками RuslanAI

## 1. Соответствие компонентов системы кодировок и файлов проекта

| Компонент системы кодировок | Файлы проекта RuslanAI | Описание интеграции |
|------------------------------|------------------------|---------------------|
| **EncodingManager.py** | Общая утилита для всех компонентов | Базовый компонент, используется всеми остальными адаптерами |
| **api_encoding_adapter.py** | `fixed_api_server.py`, `api_server_patch.py`, `api_server_new_header.py` | Интеграция с API-сервером через middleware |
| **websocket_encoding_adapter.py** | `simple_ws_server.py`, `websocket_memory_bridge.py`, `fixed_websocket_memory_bridge.py` | Обертка для WebSocket соединений |
| **memory_encoding_adapter.py** | `debug_memory_saving.py`, `direct_memory_access.py`, `memory_patch.py` | Адаптер для системы памяти |
| **orchestrator_encoding_adapter.py** | `debug_orchestrator.py`, `patch_orchestrator.py`, `central_orchestrator.py` (в central_agent) | Обертка для центрального оркестратора |
| **encoding_standardizer.py** | Самостоятельная утилита | Используется для стандартизации кодировок всех файлов проекта |
| **encoding_diagnostics.py** | Самостоятельная утилита | Используется для диагностики проблем с кодировками |
| **integrate_encoding_system.py** | Самостоятельная утилита | Используется для полной интеграции всех компонентов |

## 2. Необходимые изменения в импортах существующих файлов

### 2.1. API-сервер (`fixed_api_server.py`)

```python
# Добавить в начало файла, после стандартных импортов
import sys
import os
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(script_dir)

# Импортируем адаптер для API
try:
    from api_encoding_adapter import add_encoding_middleware, APIEncodingAdapter
    encoding_adapter = APIEncodingAdapter()
    logger.info("API адаптер кодировок успешно импортирован")
except ImportError as e:
    logger.error(f"Ошибка импорта API адаптера кодировок: {e}")
    encoding_adapter = None

# Добавить после создания FastAPI приложения (app = FastAPI())
if encoding_adapter:
    add_encoding_middleware(app, encoding_adapter)
    logger.info("Middleware для кодировок добавлен в приложение FastAPI")
```

### 2.2. WebSocket-сервер (`simple_ws_server.py`)

```python
# Добавить в начало файла, после стандартных импортов
import sys
import os
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(script_dir)

# Импортируем адаптер для WebSocket
try:
    from websocket_encoding_adapter import WebSocketEncodingMiddleware, with_encoding
    logger.info("WebSocket адаптер кодировок успешно импортирован")
    use_encoding_adapter = True
except ImportError as e:
    logger.error(f"Ошибка импорта WebSocket адаптера кодировок: {e}")
    use_encoding_adapter = False

# Изменить обработчик handle_client, добавив декоратор
if use_encoding_adapter:
    handle_client = with_encoding(handle_client)
    logger.info("WebSocket обработчик обернут адаптером кодировок")
```

### 2.3. Обработка памяти (`debug_memory_saving.py`, `direct_memory_access.py`)

```python
# Добавить в начало файла, после стандартных импортов
import sys
import os
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(script_dir)

# Импортируем адаптер для системы памяти
try:
    from memory_encoding_adapter import MemoryEncodingAdapter
    memory_encoding = MemoryEncodingAdapter()
    logger.info("Адаптер кодировок для памяти успешно импортирован")
except ImportError as e:
    logger.error(f"Ошибка импорта адаптера кодировок для памяти: {e}")
    memory_encoding = None

# Перед добавлением в память добавить:
if memory_encoding:
    prepared_content = memory_encoding.prepare_for_storage(content)
else:
    prepared_content = content

# Перед чтением из памяти добавить:
if memory_encoding:
    restored_content = memory_encoding.restore_from_storage(raw_content)
else:
    restored_content = raw_content
```

### 2.4. Центральный оркестратор (`central_orchestrator.py`)

```python
# Добавить в начало файла, после стандартных импортов
import sys
import os
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(script_dir)

# Импортируем адаптер для оркестратора
try:
    from orchestrator_encoding_adapter import OrchestratorEncodingAdapter
    orchestrator_encoding = OrchestratorEncodingAdapter()
    logger.info("Адаптер кодировок для оркестратора успешно импортирован")
except ImportError as e:
    logger.error(f"Ошибка импорта адаптера кодировок для оркестратора: {e}")
    orchestrator_encoding = None

# В начале метода handle_request добавить:
if orchestrator_encoding:
    processed_message = orchestrator_encoding.process_incoming_message(message, source)
else:
    processed_message = message

# Перед возвратом результата из handle_request добавить:
if orchestrator_encoding:
    return orchestrator_encoding.process_outgoing_message(response, target=source)
else:
    return response
```

## 3. Необходимые изменения в конфигурации проекта

### 3.1. Пути к директориям

Необходимо обновить пути к директориям в следующих файлах:

1. **encoding_standardizer.py**

```python
# Обновить пути к директориям проекта
PROJECT_ROOT = Path("C:/RuslanAI")  # Изменить на актуальный путь
BACKEND_DIR = PROJECT_ROOT / "central_agent"  # Изменить, если структура отличается
FRONTEND_DIR = PROJECT_ROOT / "web_ui"  # Изменить, если структура отличается
SCRIPTS_DIR = PROJECT_ROOT / "scripts"  # Изменить, если структура отличается
LOGS_DIR = PROJECT_ROOT / "logs"  # Изменить, если структура отличается
```

2. **integrate_encoding_system.py**

```python
# Аналогично обновить пути к директориям проекта
```

### 3.2. Настройка логирования

Создать директорию для логов и убедиться в правах доступа:

```bash
mkdir -p C:/RuslanAI/logs
chmod 755 C:/RuslanAI/logs
```

### 3.3. Файл конфигурации системы кодировок

Создать файл `encoding_config.json` для централизованной конфигурации:

```json
{
  "paths": {
    "project_root": "C:/RuslanAI",
    "backend_dir": "C:/RuslanAI/central_agent",
    "frontend_dir": "C:/RuslanAI/web_ui",
    "scripts_dir": "C:/RuslanAI/scripts",
    "logs_dir": "C:/RuslanAI/logs"
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
  }
}
```

## 4. Зависимости, которые необходимо установить или обновить

### 4.1. Основные зависимости

```bash
pip install chardet==5.2.0     # Библиотека для определения кодировок
pip install fastapi==0.103.1   # Web-фреймворк для API-сервера
pip install uvicorn==0.23.2    # ASGI-сервер для запуска FastAPI
pip install websockets==11.0.3 # Библиотека для работы с WebSocket
```

### 4.2. Дополнительные зависимости для тестирования

```bash
pip install pytest==7.4.2       # Фреймворк для тестирования
pip install pytest-asyncio==0.21.1  # Поддержка асинхронного тестирования
pip install httpx==0.25.0       # HTTP-клиент для тестирования API
```

### 4.3. Зависимости для фронтенда

Если требуется поддержка кодировок и на стороне клиента:

```bash
# В директории web_ui
npm install encoding-japanese   # Библиотека для работы с различными кодировками
npm install text-encoding       # Полифилл для TextEncoder/TextDecoder
```

## 5. Последовательность внедрения компонентов с шагами валидации

### Фаза 1: Подготовка и базовая интеграция

#### Шаг 1: Установка зависимостей
```bash
# Создаем виртуальное окружение (опционально)
python -m venv venv
source venv/bin/activate  # для Linux/Mac
# или
venv\Scripts\activate.bat  # для Windows

# Устанавливаем основные зависимости
pip install chardet==5.2.0 fastapi==0.103.1 uvicorn==0.23.2 websockets==11.0.3

# Устанавливаем зависимости для тестирования
pip install pytest==7.4.2 pytest-asyncio==0.21.1 httpx==0.25.0
```

**Валидация**: 
```bash
# Проверяем установленные пакеты
pip list | grep -E "chardet|fastapi|uvicorn|websockets|pytest"
```

#### Шаг 2: Копирование файлов системы кодировок
```bash
# Копируем базовые файлы системы в директорию проекта
cp EncodingManager.py encoding_standardizer.py encoding_diagnostics.py C:/RuslanAI/scripts/

# Создаем директорию для логов
mkdir -p C:/RuslanAI/logs
```

**Валидация**:
```bash
# Проверяем наличие файлов
ls -la C:/RuslanAI/scripts/EncodingManager.py
ls -la C:/RuslanAI/scripts/encoding_standardizer.py
ls -la C:/RuslanAI/scripts/encoding_diagnostics.py
ls -la C:/RuslanAI/logs
```

#### Шаг 3: Стандартизация кодировок файлов проекта
```bash
# Запускаем диагностику перед стандартизацией
python C:/RuslanAI/scripts/encoding_diagnostics.py --full --output=C:/RuslanAI/logs/encoding_before.json

# Запускаем стандартизацию сначала в режиме проверки
python C:/RuslanAI/scripts/encoding_standardizer.py --check-only

# Если всё в порядке, запускаем стандартизацию с исправлением
python C:/RuslanAI/scripts/encoding_standardizer.py
```

**Валидация**:
```bash
# Запускаем диагностику после стандартизации
python C:/RuslanAI/scripts/encoding_diagnostics.py --full --output=C:/RuslanAI/logs/encoding_after.json

# Сравниваем отчеты до и после
python -c "import json; before = json.load(open('C:/RuslanAI/logs/encoding_before.json')); after = json.load(open('C:/RuslanAI/logs/encoding_after.json')); print(f'До: успешность {before[\"report\"][\"statistics\"][\"success_rate\"]}%, После: успешность {after[\"report\"][\"statistics\"][\"success_rate\"]}%')"
```

### Фаза 2: Интеграция с API-сервером

#### Шаг 4: Копирование и настройка API-адаптера
```bash
# Копируем адаптер для API
cp api_encoding_adapter.py C:/RuslanAI/scripts/

# Создаем резервную копию API-сервера
cp C:/RuslanAI/scripts/fixed_api_server.py C:/RuslanAI/scripts/fixed_api_server.py.bak
```

**Валидация**:
```bash
# Проверяем наличие файлов
ls -la C:/RuslanAI/scripts/api_encoding_adapter.py
ls -la C:/RuslanAI/scripts/fixed_api_server.py.bak
```

#### Шаг 5: Интеграция адаптера с API-сервером
Добавляем импорты и код интеграции в `fixed_api_server.py` согласно инструкциям из раздела 2.1.

**Валидация**:
```bash
# Запускаем API-сервер и проверяем логи на ошибки
python C:/RuslanAI/scripts/fixed_api_server.py &
sleep 5
grep -E "error|exception" C:/RuslanAI/logs/api_server.log

# Проверяем заголовки ответов API
curl -I http://localhost:8001/api/health
```

#### Шаг 6: Тестирование API с кириллицей
```bash
# Отправляем запрос с кириллическими символами
curl -X POST -H "Content-Type: application/json" -d '{"message":"Тестовое сообщение с кириллицей"}' http://localhost:8001/api/chat
```

**Валидация**:
```bash
# Проверяем логи API на предмет проблем с кодировкой
grep -E "кодировк|encoding" C:/RuslanAI/logs/api_server.log
grep -E "error|exception" C:/RuslanAI/logs/api_server.log
```

### Фаза 3: Интеграция с WebSocket-сервером

#### Шаг 7: Копирование и настройка WebSocket-адаптера
```bash
# Копируем адаптер для WebSocket
cp websocket_encoding_adapter.py C:/RuslanAI/scripts/

# Создаем резервную копию WebSocket-сервера
cp C:/RuslanAI/scripts/simple_ws_server.py C:/RuslanAI/scripts/simple_ws_server.py.bak
```

**Валидация**:
```bash
# Проверяем наличие файлов
ls -la C:/RuslanAI/scripts/websocket_encoding_adapter.py
ls -la C:/RuslanAI/scripts/simple_ws_server.py.bak
```

#### Шаг 8: Интеграция адаптера с WebSocket-сервером
Добавляем импорты и код интеграции в `simple_ws_server.py` согласно инструкциям из раздела 2.2.

**Валидация**:
```bash
# Запускаем WebSocket-сервер и проверяем логи на ошибки
python C:/RuslanAI/scripts/simple_ws_server.py &
sleep 5
grep -E "error|exception" C:/RuslanAI/logs/simple_ws.log

# Создаем простой скрипт для тестирования WebSocket
echo 'import websockets, asyncio, json
async def test():
    uri = "ws://localhost:8005"
    async with websockets.connect(uri) as websocket:
        await websocket.send(json.dumps({"message": "Тестовое сообщение с кириллицей"}))
        response = await websocket.recv()
        print(f"Получен ответ: {response}")
asyncio.run(test())' > C:/RuslanAI/scripts/test_ws.py

# Запускаем тест
python C:/RuslanAI/scripts/test_ws.py
```

### Фаза 4: Интеграция с системой памяти

#### Шаг 9: Копирование и настройка адаптера памяти
```bash
# Копируем адаптер для системы памяти
cp memory_encoding_adapter.py C:/RuslanAI/scripts/

# Создаем резервные копии файлов системы памяти
cp C:/RuslanAI/scripts/direct_memory_access.py C:/RuslanAI/scripts/direct_memory_access.py.bak
cp C:/RuslanAI/scripts/debug_memory_saving.py C:/RuslanAI/scripts/debug_memory_saving.py.bak
```

**Валидация**:
```bash
# Проверяем наличие файлов
ls -la C:/RuslanAI/scripts/memory_encoding_adapter.py
ls -la C:/RuslanAI/scripts/direct_memory_access.py.bak
ls -la C:/RuslanAI/scripts/debug_memory_saving.py.bak
```

#### Шаг 10: Интеграция адаптера с системой памяти
Добавляем импорты и код интеграции в файлы системы памяти согласно инструкциям из раздела 2.3.

**Валидация**:
```bash
# Создаем простой тест для проверки работы с памятью
echo 'import sys, os
sys.path.append("C:/RuslanAI/scripts")
from memory_encoding_adapter import MemoryEncodingAdapter
from direct_memory_access import save_memory, retrieve_memory

# Создаем адаптер
adapter = MemoryEncodingAdapter()

# Тестовые данные с кириллицей
test_data = {"content": "Тестовые данные с кириллицей", "tags": ["тест", "кириллица"]}

# Подготавливаем данные для сохранения
prepared_data = adapter.prepare_for_storage(test_data)

# Сохраняем в память
memory_id = save_memory(prepared_data)
print(f"Данные сохранены в память, ID: {memory_id}")

# Извлекаем из памяти
raw_data = retrieve_memory(memory_id)

# Восстанавливаем данные
restored_data = adapter.restore_from_storage(raw_data)
print(f"Восстановленные данные: {restored_data}")

# Проверяем соответствие
if restored_data["content"] == test_data["content"]:
    print("Тест успешен: данные сохранены и восстановлены корректно")
else:
    print("Тест не пройден: данные не совпадают")' > C:/RuslanAI/scripts/test_memory.py

# Запускаем тест
python C:/RuslanAI/scripts/test_memory.py
```

### Фаза 5: Интеграция с центральным оркестратором

#### Шаг 11: Копирование и настройка адаптера оркестратора
```bash
# Копируем адаптер для оркестратора
cp orchestrator_encoding_adapter.py C:/RuslanAI/scripts/

# Создаем резервную копию оркестратора
cp C:/RuslanAI/central_agent/orchestrator/central_orchestrator.py C:/RuslanAI/central_agent/orchestrator/central_orchestrator.py.bak
```

**Валидация**:
```bash
# Проверяем наличие файлов
ls -la C:/RuslanAI/scripts/orchestrator_encoding_adapter.py
ls -la C:/RuslanAI/central_agent/orchestrator/central_orchestrator.py.bak
```

#### Шаг 12: Интеграция адаптера с оркестратором
Добавляем импорты и код интеграции в `central_orchestrator.py` согласно инструкциям из раздела 2.4.

**Валидация**:
```bash
# Создаем простой тест для проверки работы оркестратора
echo 'import sys, os
sys.path.append("C:/RuslanAI/scripts")
sys.path.append("C:/RuslanAI/central_agent/orchestrator")
from orchestrator_encoding_adapter import OrchestratorEncodingAdapter
from central_orchestrator import handle_request

# Создаем адаптер
adapter = OrchestratorEncodingAdapter()

# Тестовые данные с кириллицей
test_message = "Тестовое сообщение с кириллицей для оркестратора"

# Обрабатываем входящее сообщение
processed_message = adapter.process_incoming_message(test_message, "test")
print(f"Обработанное сообщение: {processed_message}")

# Отправляем сообщение оркестратору
response = handle_request("start", processed_message, chat_id="test_chat")
print(f"Ответ оркестратора: {response}")

# Обрабатываем исходящее сообщение
processed_response = adapter.process_outgoing_message(response, "test")
print(f"Обработанный ответ: {processed_response}")' > C:/RuslanAI/scripts/test_orchestrator.py

# Запускаем тест
python C:/RuslanAI/scripts/test_orchestrator.py
```

### Фаза 6: Полная интеграция и тестирование

#### Шаг 13: Копирование скрипта полной интеграции
```bash
# Копируем скрипт полной интеграции
cp integrate_encoding_system.py C:/RuslanAI/scripts/
```

**Валидация**:
```bash
# Проверяем наличие файла
ls -la C:/RuslanAI/scripts/integrate_encoding_system.py
```

#### Шаг 14: Запуск полной интеграции
```bash
# Запускаем полную интеграцию в режиме проверки
python C:/RuslanAI/scripts/integrate_encoding_system.py --check-only

# Если всё в порядке, запускаем полную интеграцию
python C:/RuslanAI/scripts/integrate_encoding_system.py --full-integration
```

**Валидация**:
```bash
# Запускаем комплексное тестирование
python C:/RuslanAI/scripts/test_encoding_system.py

# Запускаем диагностику после интеграции
python C:/RuslanAI/scripts/encoding_diagnostics.py --full --output=C:/RuslanAI/logs/encoding_final.json
```

#### Шаг 15: Финальное тестирование с реальными данными
```bash
# Запускаем API-сервер
python C:/RuslanAI/scripts/fixed_api_server.py &

# Запускаем WebSocket-сервер
python C:/RuslanAI/scripts/simple_ws_server.py &

# Создаем и запускаем скрипт для тестирования с реальными данными
echo 'import requests
import websockets
import asyncio
import json
import sys
import time

# Функция для отправки запроса к API
def test_api():
    url = "http://localhost:8001/api/chat"
    data = {"message": "Тест API с кириллицей: Привет, мир!", "chat_id": "test_chat_1"}
    headers = {"Content-Type": "application/json"}
    
    response = requests.post(url, json=data, headers=headers)
    print(f"API статус код: {response.status_code}")
    print(f"API ответ: {response.text}")
    
    return response.json()

# Функция для тестирования WebSocket
async def test_websocket():
    uri = "ws://localhost:8005"
    async with websockets.connect(uri) as websocket:
        # Ждем приветственное сообщение
        greeting = await websocket.recv()
        print(f"WebSocket приветствие: {greeting}")
        
        # Отправляем сообщение
        message = {"type": "message", "content": "Тест WebSocket с кириллицей: Съешь же ещё этих мягких французских булок да выпей чаю"}
        await websocket.send(json.dumps(message, ensure_ascii=False))
        
        # Получаем ответ
        response = await websocket.recv()
        print(f"WebSocket ответ: {response}")
        
        return response

# Основная функция тестирования
async def main():
    print("=== Начало тестирования с реальными данными ===")
    
    print("\n--- Тестирование API ---")
    api_result = test_api()
    
    print("\n--- Тестирование WebSocket ---")
    ws_result = await test_websocket()
    
    print("\n=== Тестирование завершено ===")

# Запускаем тестирование
if __name__ == "__main__":
    asyncio.run(main())' > C:/RuslanAI/scripts/test_integration.py

# Даем серверам время на запуск
sleep 5

# Запускаем тест интеграции
python C:/RuslanAI/scripts/test_integration.py
```

**Валидация**:
```bash
# Проверяем логи на наличие ошибок
grep -E "error|exception|кодировк|encoding" C:/RuslanAI/logs/api_server.log
grep -E "error|exception|кодировк|encoding" C:/RuslanAI/logs/simple_ws.log
```

## 6. Обратная связь и мониторинг

После внедрения системы кодировок важно настроить постоянный мониторинг для выявления потенциальных проблем:

1. **Регулярная диагностика**:
   ```bash
   # Создаем cron-задачу для ежедневной диагностики
   echo "0 0 * * * python C:/RuslanAI/scripts/encoding_diagnostics.py --full --output=C:/RuslanAI/logs/encoding_$(date +\%Y\%m\%d).json" | crontab -
   ```

2. **Анализ логов**:
   ```bash
   # Скрипт для анализа логов на предмет проблем с кодировками
   echo '#!/bin/bash
   grep -E "кодировк|encoding|error|exception" C:/RuslanAI/logs/*.log > C:/RuslanAI/logs/encoding_errors.log
   if [ -s C:/RuslanAI/logs/encoding_errors.log ]; then
     echo "Обнаружены потенциальные проблемы с кодировками, проверьте файл C:/RuslanAI/logs/encoding_errors.log"
   else
     echo "Проблем с кодировками не обнаружено"
   fi' > C:/RuslanAI/scripts/check_encoding_logs.sh
   chmod +x C:/RuslanAI/scripts/check_encoding_logs.sh
   ```

3. **Автоматическая стандартизация**:
   ```bash
   # Создаем cron-задачу для еженедельной стандартизации файлов
   echo "0 0 * * 0 python C:/RuslanAI/scripts/encoding_standardizer.py" | crontab -
   ```

## 7. Резервный план

В случае проблем с интеграцией системы кодировок:

1. **Восстановление из резервных копий**:
   ```bash
   # Восстановление API-сервера
   cp C:/RuslanAI/scripts/fixed_api_server.py.bak C:/RuslanAI/scripts/fixed_api_server.py
   
   # Восстановление WebSocket-сервера
   cp C:/RuslanAI/scripts/simple_ws_server.py.bak C:/RuslanAI/scripts/simple_ws_server.py
   
   # Восстановление системы памяти
   cp C:/RuslanAI/scripts/direct_memory_access.py.bak C:/RuslanAI/scripts/direct_memory_access.py
   cp C:/RuslanAI/scripts/debug_memory_saving.py.bak C:/RuslanAI/scripts/debug_memory_saving.py
   
   # Восстановление оркестратора
   cp C:/RuslanAI/central_agent/orchestrator/central_orchestrator.py.bak C:/RuslanAI/central_agent/orchestrator/central_orchestrator.py
   ```

2. **Альтернативный подход**:
   Вместо полной интеграции с изменением существующих файлов можно использовать обертки, которые будут вызывать оригинальные функции, обрабатывая входные и выходные данные для корректной поддержки кодировок.

## 8. Заключение

Данный план предоставляет подробную последовательность действий для интеграции системы управления кодировками в проект RuslanAI. План разбит на логические фазы с конкретными шагами и проверками валидации для обеспечения надежного внедрения.

Следование этому плану позволит безопасно внедрить систему кодировок, решить текущие проблемы с кириллическими символами и обеспечить надежную основу для дальнейшего развития проекта RuslanAI с полной поддержкой многоязычности.