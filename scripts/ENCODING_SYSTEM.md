# Система управления кодировками RuslanAI

## Обзор

Система управления кодировками RuslanAI предназначена для решения проблем с кодировками в многоагентной системе, особенно при работе с кириллическими символами. Система состоит из нескольких взаимодополняющих компонентов, которые обеспечивают единообразную обработку текста с учетом кириллицы на всех уровнях приложения.

## Основные компоненты

1. **EncodingManager** - центральный класс для работы с кодировками
2. **EncodingStandardizer** - инструмент для стандартизации кодировок файлов проекта
3. **WebSocketEncodingAdapter** - адаптер для WebSocket коммуникаций
4. **APIEncodingAdapter** - адаптер для HTTP API
5. **MemoryEncodingAdapter** - адаптер для системы памяти
6. **OrchestratorEncodingAdapter** - адаптер для центрального оркестратора

## Установка и зависимости

Для работы системы необходимы следующие зависимости:

```bash
pip install chardet fastapi uvicorn websockets
```

Все компоненты системы должны находиться в одной директории или быть доступны через sys.path.

## Использование

### 1. EncodingManager

```python
from EncodingManager import EncodingManager

# Определение кодировки
content = open('file.txt', 'rb').read()
encoding = EncodingManager.detect_encoding(content)
print(f"Кодировка файла: {encoding}")

# Чтение файла с автоопределением кодировки
text = EncodingManager.read_file('file.txt')

# Запись файла с указанной кодировкой
EncodingManager.write_file('file.txt', 'Текст с кириллицей', encoding='utf-8')

# Работа с JSON с поддержкой кириллицы
data = {'message': 'Сообщение с кириллицей'}
json_str = EncodingManager.json_dumps(data, ensure_ascii=False)
parsed_data = EncodingManager.json_loads(json_str)

# Стандартизация кодировки файла
EncodingManager.standardize_file_encoding('file.txt', target_encoding='utf-8', remove_bom=True)

# Создание HTTP-ответа с корректными UTF-8 заголовками
response = EncodingManager.create_utf8_response({'message': 'Ответ с кириллицей'})

# Подготовка данных для WebSocket
ws_data = EncodingManager.prepare_for_websocket({'message': 'Сообщение для WebSocket'})

# Декодирование сообщения из WebSocket
message = EncodingManager.safely_decode_websocket_message(websocket_message)

# Проверка текста на проблемы с кодировкой
is_valid, issue = EncodingManager.check_text("Текст с кириллицей")
if not is_valid:
    print(f"Проблема с кодировкой: {issue}")
```

### 2. Стандартизация файлов проекта

```bash
# Стандартизация всех файлов проекта в кодировку UTF-8
python encoding_standardizer.py

# Только проверка без исправления
python encoding_standardizer.py --check-only

# Указание целевой кодировки
python encoding_standardizer.py --encoding=utf-8

# Сохранение BOM-маркера
python encoding_standardizer.py --keep-bom

# Обработка конкретной директории
python encoding_standardizer.py --directory=C:/RuslanAI/web_ui

# Указание расширений файлов для обработки
python encoding_standardizer.py --extensions=.py,.js,.jsx
```

### 3. Интеграция с FastAPI

```python
from fastapi import FastAPI
from api_encoding_adapter import add_encoding_middleware, APIEncodingAdapter

app = FastAPI()

# Добавляем middleware для обработки кодировок
encoding_adapter = add_encoding_middleware(app)

@app.post("/api/echo")
async def echo(request: Request):
    # Обрабатываем тело запроса с поддержкой кодировок
    data = await encoding_adapter.process_request_body(request)
    
    # Создаем ответ с корректными заголовками кодировки
    return encoding_adapter.create_json_response(data)
```

### 4. Интеграция с WebSocket

```python
import asyncio
import websockets
from websocket_encoding_adapter import WebSocketEncodingMiddleware, with_encoding

# Вариант 1: Обертка для существующего обработчика
@with_encoding
async def handler(websocket, path):
    async for message in websocket:
        # message уже декодирован с учетом кодировки
        await websocket.send(f"Эхо: {message}")

# Вариант 2: Использование middleware
async def handler_with_middleware(websocket, path):
    middleware = WebSocketEncodingMiddleware(websocket)
    
    while True:
        # Получаем сообщение с обработкой кодировки
        data = await middleware.receive_json()
        
        # Отправляем ответ с обработкой кодировки
        await middleware.send_json({"response": f"Эхо: {data}"})

# Запускаем сервер
start_server = websockets.serve(handler, "localhost", 8765)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
```

### 5. Интеграция с системой памяти

```python
from memory_encoding_adapter import MemorySystemAdapter

# Импортируем реальный модуль памяти
from central_agent.modules.memory import memory_system

# Создаем адаптер для системы памяти
memory_adapter = MemorySystemAdapter(memory_system)

# Добавляем память с поддержкой кодировок
memory_id = memory_adapter.add_memory(
    content="Текст с кириллицей для сохранения",
    tags=["example", "cyrillic"],
    source="documentation"
)

# Извлекаем память с обработкой кодировок
results = memory_adapter.retrieve_by_tags(tags=["cyrillic"])
for result in results:
    print(result["content"])  # Содержимое с корректной кодировкой
```

### 6. Интеграция с центральным оркестратором

```python
from orchestrator_encoding_adapter import OrchestratorWrapper

# Импортируем реальный модуль оркестратора
from central_agent.orchestrator import central_orchestrator

# Создаем обертку для оркестратора
orchestrator = OrchestratorWrapper(central_orchestrator)

# Обрабатываем запрос с поддержкой кодировок
response = orchestrator.handle_request(
    action="start",
    message="Сообщение с кириллицей",
    chat_id="chat_123",
    source="api"
)

# Получаем статистику по кодировкам
stats = orchestrator.get_encoding_statistics()
print(stats)
```

### 7. Полная интеграция всех компонентов

```bash
# Полная интеграция с запуском всех серверов
python integrate_encoding_system.py --full-integration

# Стандартизация файлов и запуск API-сервера
python integrate_encoding_system.py --standardize --api-server

# Запуск только WebSocket-сервера
python integrate_encoding_system.py --websocket-server

# Стандартизация файлов без исправления
python integrate_encoding_system.py --standardize --check-only
```

## Диагностика проблем с кодировками

Система предоставляет различные способы диагностики и решения проблем с кодировками:

1. **Логи** - все компоненты ведут подробные логи в директории `C:/RuslanAI/logs/`
2. **Статистика** - все адаптеры собирают статистику по проблемам с кодировками:
   ```python
   stats = orchestrator.get_encoding_statistics()
   print(f"Обработано сообщений: {stats['total_messages']}")
   print(f"Проблем с кодировкой: {stats['encoding_issues']}")
   print(f"Процент проблем: {stats['issues_percent']}%")
   ```
3. **API-эндпоинты** - при интеграции с FastAPI создаются эндпоинты для мониторинга:
   - `GET /api/encoding-stats` - получение статистики по кодировкам
   - `POST /api/encoding-stats/reset` - сброс статистики

## Лучшие практики

1. **Стандартизация кодировок** - периодически запускайте `encoding_standardizer.py` для приведения всех файлов к единой кодировке
2. **Использование UTF-8** - используйте UTF-8 без BOM в качестве стандартной кодировки для всех файлов
3. **Проверка заголовков** - всегда включайте заголовок `charset=utf-8` в HTTP-ответы
4. **WebSocket с JSON** - передавайте данные через WebSocket в формате JSON (не в виде простых строк)
5. **Логирование проблем** - настройте логирование для отслеживания проблем с кодировками в реальном времени

## Решение распространенных проблем

### Символы-заменители (�) в тексте

Проблема: текст содержит символы-заменители, что указывает на несоответствие кодировок при чтении/записи.

Решение:
```python
# Определите правильную кодировку исходного текста
encoding = EncodingManager.detect_encoding(original_content)
print(f"Определена кодировка: {encoding}")

# Прочитайте файл с правильной кодировкой
text = EncodingManager.read_file(file_path, encoding=encoding)

# Стандартизируйте файл
EncodingManager.standardize_file_encoding(file_path, target_encoding='utf-8')
```

### Неверное отображение кириллицы в WebSocket сообщениях

Проблема: кириллические символы искажаются при передаче через WebSocket.

Решение:
```python
# Используйте WebSocketEncodingMiddleware
middleware = WebSocketEncodingMiddleware(websocket)

# Для отправки
await middleware.send_json({"message": "Сообщение с кириллицей"})

# Для приема
data = await middleware.receive_json()
```

### Некорректная кодировка в ответах API

Проблема: API возвращает ответы с неверной кодировкой или без указания кодировки.

Решение:
```python
# Используйте APIEncodingAdapter
from api_encoding_adapter import APIEncodingAdapter

adapter = APIEncodingAdapter()

# Создавайте ответы через адаптер
return adapter.create_json_response({"message": "Сообщение с кириллицей"})
```

### Проблемы с сохранением кириллицы в систему памяти

Проблема: кириллические символы искажаются при сохранении в систему памяти.

Решение:
```python
# Используйте MemoryEncodingAdapter
from memory_encoding_adapter import MemoryEncodingAdapter

adapter = MemoryEncodingAdapter()

# Подготовьте данные перед сохранением
prepared_content = adapter.prepare_for_storage(content)

# Сохраните подготовленные данные
memory_id = memory_system.add_memory(content=prepared_content, ...)
```

## Контакты и поддержка

При возникновении проблем с системой кодировок обращайтесь к разработчикам или создавайте issue в репозитории проекта. При обращении указывайте:

1. Компонент, в котором возникла проблема
2. Исходный текст, вызвавший проблему
3. Логи с ошибками или предупреждениями
4. Статистику по кодировкам (если доступна)

## Версионирование и обновления

Текущая версия системы кодировок: 1.0.0

Обновления:
- Стандартизация всех компонентов на использование UTF-8
- Поддержка кириллицы во всех компонентах системы
- Диагностика и мониторинг проблем с кодировками
- Автоматическая коррекция кодировок в файлах проекта