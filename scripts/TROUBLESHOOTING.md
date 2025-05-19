# Руководство по устранению проблем RuslanAI

Этот документ содержит инструкции по диагностике и устранению распространенных проблем с запуском и работой системы RuslanAI, особенно связанных с веб-интерфейсом и проблемами кодировок.

## Содержание

1. [Первые шаги при возникновении проблем](#первые-шаги-при-возникновении-проблем)
2. [Проблемы с запуском веб-интерфейса](#проблемы-с-запуском-веб-интерфейса)
3. [Проблемы с WebSocket соединением](#проблемы-с-websocket-соединением)
4. [Проблемы с API сервером](#проблемы-с-api-сервером)
5. [Проблемы с кодировками](#проблемы-с-кодировками)
6. [Проблемы с системой памяти](#проблемы-с-системой-памяти)
7. [Автоматическая диагностика и исправление](#автоматическая-диагностика-и-исправление)
8. [Запуск отдельных компонентов](#запуск-отдельных-компонентов)
9. [Обновление системы](#обновление-системы)

## Первые шаги при возникновении проблем

При возникновении любых проблем с запуском или работой RuslanAI, рекомендуем выполнить следующие шаги:

1. **Запустите скрипт автоматической диагностики:**
   ```powershell
   python C:\RuslanAI\scripts\diagnose_and_fix.py
   ```
   Этот скрипт проверит основные компоненты системы, исправит типичные проблемы и создаст подробный лог-файл.

2. **Проверьте лог-файлы** в директории `C:\RuslanAI\logs`:
   - `fixed_bridge.log` - логи WebSocket моста
   - `api_server.log` - логи API сервера
   - `diagnostics_*.log` - логи диагностики

3. **Перезапустите систему через ярлык** на рабочем столе или выполните:
   ```powershell
   powershell -ExecutionPolicy Bypass -File C:\RuslanAI\scripts\complete_startup.ps1
   ```

## Проблемы с запуском веб-интерфейса

### Веб-интерфейс не запускается

**Симптомы**: При запуске системы браузер не открывается, или открывается с сообщением об ошибке "Эта страница не работает" / "Cannot connect to localhost".

**Решения**:

1. **Проверьте, установлен ли Node.js и npm:**
   ```powershell
   node --version
   npm --version
   ```
   Если команды не найдены, установите Node.js с сайта https://nodejs.org/

2. **Проверьте наличие ошибок при запуске:**
   ```powershell
   cd C:\RuslanAI\web_ui
   npm start
   ```
   Обратите внимание на любые ошибки в выводе.

3. **Восстановите зависимости:**
   ```powershell
   cd C:\RuslanAI\web_ui
   npm ci
   ```

4. **Проверьте порты:**
   Убедитесь, что порты 3000 и 5173 свободны:
   ```powershell
   Get-NetTCPConnection -LocalPort 3000,5173 -ErrorAction SilentlyContinue
   ```

### Проблемы с отображением кириллицы в интерфейсе

**Симптомы**: Кириллические символы отображаются как "квадратики", "знаки вопроса" или другие непонятные символы.

**Решения**:

1. **Исправьте кодировку файлов:**
   ```powershell
   python C:\RuslanAI\scripts\diagnose_and_fix.py
   ```

2. **Проверьте конфигурацию языка браузера:**
   Убедитесь, что в браузере установлена поддержка кодировки UTF-8 по умолчанию.

3. **Обновите файлы шрифтов** в директории `C:\RuslanAI\web_ui\public\fonts`, если она существует.

## Проблемы с WebSocket соединением

### Не удается подключиться к WebSocket серверу

**Симптомы**: В интерфейсе появляется сообщение "Ошибка подключения" или "WebSocket connection failed".

**Решения**:

1. **Проверьте, запущен ли WebSocket мост:**
   ```powershell
   Get-NetTCPConnection -LocalPort 8005 -ErrorAction SilentlyContinue
   ```

2. **Запустите мост вручную:**
   ```powershell
   cd C:\RuslanAI\scripts
   python fixed_direct_bridge.py
   ```

3. **Проверьте файл конфигурации WebSocket** в веб-интерфейсе:
   ```powershell
   notepad C:\RuslanAI\web_ui\src\services\websocketService.js
   ```
   Убедитесь, что URL настроен на `ws://localhost:8005`.

4. **Проверьте блокировку портов** брандмауэром Windows. Временно отключите брандмауэр для тестирования.

### Сообщения WebSocket не доходят до сервера или обратно

**Симптомы**: Сообщения отправляются, но ответы не приходят или возникают ошибки.

**Решения**:

1. **Проверьте логи моста:**
   ```powershell
   Get-Content -Path C:\RuslanAI\logs\fixed_bridge.log -Tail 50
   ```

2. **Используйте тестовый WebSocket клиент** для отправки и приема сообщений:
   ```powershell
   cd C:\RuslanAI\scripts
   python -c "
   import asyncio
   import websockets
   import json
   
   async def test_ws():
       async with websockets.connect('ws://localhost:8005') as websocket:
           await websocket.send(json.dumps({
               'content': 'Тестовое сообщение',
               'chat_id': 'test_chat_id'
           }))
           print('Сообщение отправлено')
           
           response = await websocket.recv()
           print(f'Получен ответ: {response}')
   
   asyncio.run(test_ws())
   "
   ```

## Проблемы с API сервером

### API сервер не запускается

**Симптомы**: Порт 8001 не используется, в логах появляются ошибки.

**Решения**:

1. **Проверьте, запущен ли API сервер:**
   ```powershell
   Get-NetTCPConnection -LocalPort 8001 -ErrorAction SilentlyContinue
   ```

2. **Запустите API сервер вручную:**
   ```powershell
   cd C:\RuslanAI\scripts
   python fixed_api_server.py
   ```

3. **Проверьте зависимости:**
   Убедитесь, что установлены необходимые библиотеки:
   ```powershell
   pip install fastapi uvicorn websockets
   ```

### Ошибки при вызове API

**Симптомы**: В веб-интерфейсе появляются ошибки при отправке запросов, или запросы не обрабатываются.

**Решения**:

1. **Проверьте логи API сервера:**
   ```powershell
   Get-Content -Path C:\RuslanAI\logs\api_server.log -Tail 50
   ```

2. **Проверьте работоспособность API вручную:**
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:8001/api/health" -Method GET
   ```

3. **Перезапустите API сервер** с более подробным логированием:
   ```powershell
   cd C:\RuslanAI\scripts
   $env:LOGLEVEL = "DEBUG"
   python fixed_api_server.py
   ```

## Проблемы с кодировками

### Искажение кириллических символов

**Симптомы**: Кириллические символы отображаются некорректно в логах, интерфейсе или ответах.

**Решения**:

1. **Запустите скрипт исправления кодировок:**
   ```powershell
   python C:\RuslanAI\scripts\diagnose_and_fix.py
   ```

2. **Проверьте кодировку конкретного файла:**
   ```powershell
   python -c "
   import sys
   
   def detect_encoding(file_path):
       with open(file_path, 'rb') as f:
           content = f.read()
       
       if content.startswith(b'\xef\xbb\xbf'):
           return 'UTF-8 with BOM'
       try:
           content.decode('utf-8')
           return 'UTF-8'
       except UnicodeDecodeError:
           pass
       
       try:
           content.decode('windows-1251')
           return 'Windows-1251'
       except UnicodeDecodeError:
           pass
       
       return 'Unknown'
   
   print(f'Encoding: {detect_encoding(sys.argv[1])}')
   " 'C:\path\to\your\file.py'
   ```

3. **Исправьте кодировку файла вручную:**
   ```powershell
   $content = Get-Content -Path 'C:\path\to\your\file.py' -Encoding UTF8 -Raw
   $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
   [System.IO.File]::WriteAllText('C:\path\to\your\file.py', $content, $utf8NoBomEncoding)
   ```

### Проблемы с JSON файлами

**Симптомы**: Ошибки при чтении или записи JSON файлов, особенно файлов памяти.

**Решения**:

1. **Исправьте кодировку JSON файлов:**
   ```powershell
   python -c "
   import os
   import json
   import sys
   
   def fix_json_file(file_path):
       try:
           with open(file_path, 'rb') as f:
               content = f.read()
           
           # Убираем BOM-маркер если есть
           if content.startswith(b'\xef\xbb\xbf'):
               content = content[3:]
           
           # Декодируем как UTF-8
           text = content.decode('utf-8', errors='replace')
           
           # Проверяем, валидный ли JSON
           try:
               data = json.loads(text)
               print(f'JSON валиден')
           except json.JSONDecodeError as e:
               print(f'Ошибка JSON: {e}')
               return
           
           # Перезаписываем в UTF-8 без BOM
           with open(file_path, 'w', encoding='utf-8') as f:
               json.dump(data, f, ensure_ascii=False, indent=2)
           
           print(f'Файл успешно исправлен')
       except Exception as e:
           print(f'Ошибка: {e}')
   
   fix_json_file(sys.argv[1])
   " 'C:\path\to\your\file.json'
   ```

## Проблемы с системой памяти

### Ошибки при сохранении или чтении памяти

**Симптомы**: Ошибки в логах, связанные с памятью, сообщения не сохраняются или не считываются.

**Решения**:

1. **Проверьте структуру директории памяти:**
   ```powershell
   Get-ChildItem -Path C:\RuslanAI\data\memory -Recurse | Select-Object FullName
   ```
   Должны существовать поддиректории: detail, context, summary.

2. **Создайте тестовую запись в памяти:**
   ```powershell
   python -c "
   import os
   import json
   import uuid
   from datetime import datetime
   
   memory_dir = r'C:\RuslanAI\data\memory\detail'
   os.makedirs(memory_dir, exist_ok=True)
   
   test_id = f'test_{uuid.uuid4().hex[:8]}'
   test_data = {
       'id': test_id,
       'content': 'Тестовая запись памяти',
       'tags': ['test', 'diagnostics'],
       'timestamp': datetime.now().isoformat(),
       'level': 'detail',
       'importance': 3,
       'source': 'diagnostics'
   }
   
   file_path = os.path.join(memory_dir, f'{test_id}.json')
   with open(file_path, 'w', encoding='utf-8') as f:
       json.dump(test_data, f, ensure_ascii=False, indent=2)
   
   print(f'Создана тестовая запись: {file_path}')
   "
   ```

3. **Найдите и исправьте невалидные файлы памяти:**
   ```powershell
   python -c "
   import os
   import json
   
   memory_dir = r'C:\RuslanAI\data\memory'
   invalid_files = []
   
   for root, dirs, files in os.walk(memory_dir):
       for file in files:
           if file.endswith('.json'):
               file_path = os.path.join(root, file)
               try:
                   with open(file_path, 'r', encoding='utf-8') as f:
                       json.load(f)
               except Exception as e:
                   invalid_files.append((file_path, str(e)))
   
   print(f'Найдено {len(invalid_files)} невалидных файлов памяти:')
   for file_path, error in invalid_files:
       print(f'- {file_path}: {error}')
   "
   ```

## Автоматическая диагностика и исправление

Система RuslanAI включает скрипт автоматической диагностики и исправления проблем:

```powershell
python C:\RuslanAI\scripts\diagnose_and_fix.py
```

Этот скрипт выполняет следующие действия:

1. Проверяет наличие и создает необходимые директории
2. Проверяет наличие ключевых файлов системы
3. Исправляет проблемы с кодировками в Python и JSON файлах
4. Проверяет и исправляет конфигурацию WebSocket в веб-интерфейсе
5. Проверяет порты и процессы
6. Создает ярлык на рабочем столе для удобного запуска системы

После выполнения скрипт выводит отчет о найденных и исправленных проблемах.

## Запуск отдельных компонентов

Для ручного запуска отдельных компонентов системы используйте следующие команды:

### WebSocket мост

```powershell
cd C:\RuslanAI\scripts
python fixed_direct_bridge.py
```

### API сервер

```powershell
cd C:\RuslanAI\scripts
python fixed_api_server.py
```

### Веб-интерфейс

```powershell
cd C:\RuslanAI\scripts
python frontend_runner_fixed.py
```

Или напрямую через npm:

```powershell
cd C:\RuslanAI\web_ui
npm start
```

## Обновление системы

Если требуется обновление системы RuslanAI, выполните следующие шаги:

1. **Создайте резервную копию** важных данных:
   ```powershell
   $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
   $backupDir = "C:\RuslanAI_backup_$timestamp"
   
   New-Item -ItemType Directory -Path $backupDir -Force
   Copy-Item -Path "C:\RuslanAI\data" -Destination "$backupDir\data" -Recurse -Force
   Copy-Item -Path "C:\RuslanAI\logs" -Destination "$backupDir\logs" -Recurse -Force
   ```

2. **Остановите все компоненты системы:**
   ```powershell
   $ports = @(3000, 5173, 8001, 8005)
   foreach ($port in $ports) {
       $processId = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess
       if ($processId) {
           Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
       }
   }
   ```

3. **Обновите файлы системы** из нового релиза или репозитория.

4. **Запустите диагностику и исправление:**
   ```powershell
   python C:\RuslanAI\scripts\diagnose_and_fix.py
   ```

5. **Перезапустите систему:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File C:\RuslanAI\scripts\complete_startup.ps1
   ```

---

Если у вас возникли проблемы, которые не удалось решить с помощью данного руководства, пожалуйста, обратитесь к системному администратору или разработчикам RuslanAI.