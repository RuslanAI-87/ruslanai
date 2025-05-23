# Исправление проблемы с WebSocket подключением

## Описание проблемы

В системе RuslanAI возникла ошибка связи между веб-интерфейсом и API сервером. Основная проблема заключалась в том, что:

1. Веб-интерфейс подключался к WebSocket на порту 8005 (fixed_direct_bridge.py)
2. API сервер ожидал подключения к своему WebSocket на порту 8001 через путь /ws
3. В результате, хотя сообщения успешно отправлялись через API, уведомления о выполнении задач не доходили до веб-интерфейса

Это приводило к тому, что пользователь видел статус "Processing your request..." бесконечно, даже когда задача уже была выполнена.

## Выполненные исправления

1. **Изменён URL WebSocket-соединения:**
   ```javascript
   // До исправления
   const WS_URL = "ws://localhost:8005";
   
   // После исправления
   const WS_URL = "ws://localhost:8001/ws";
   ```

2. **Обновлена обработка подключения:**
   ```javascript
   // Использование параметра userId в URL
   const wsUrl = `${WS_URL}?userId=${this.userId}`;
   ```

3. **Упрощено сообщение при подключении:**
   ```javascript
   // Регистрация через URL параметр вместо отдельного сообщения
   console.log("Connection established with userId:", this.userId);
   ```

## Как работает система сейчас

1. **API сервер (fixed_api_server.py)**
   - Запускается на порту 8001
   - Обрабатывает HTTP запросы на /orchestrator/central
   - Предоставляет WebSocket эндпоинт на /ws для уведомлений
   - Отслеживает подключения через ConnectionManager

2. **Веб-интерфейс:**
   - Подключается к WebSocket сервера на ws://localhost:8001/ws?userId=...
   - Отправляет сообщения через HTTP POST на /orchestrator/central
   - Получает уведомления о состоянии задач через WebSocket

3. **Поток данных:**
   1. Пользователь вводит сообщение на веб-интерфейсе
   2. Сообщение отправляется на HTTP API сервера
   3. Сервер создаёт задачу и передаёт её в оркестратор
   4. Оркестратор обрабатывает задачу и возвращает результат
   5. API сервер отправляет уведомление о готовности через WebSocket
   6. Веб-интерфейс получает уведомление и обновляет UI

## Как запустить систему

Для запуска всей системы с исправлениями используйте скрипт restart_fixed_system.ps1:

```powershell
cd C:\RuslanAI\scripts
.\restart_fixed_system.ps1
```

Этот скрипт:
1. Останавливает все процессы на используемых портах
2. Очищает кэш npm
3. Запускает API сервер на порту 8001
4. Запускает веб-интерфейс с npm run dev
5. Открывает браузер с веб-интерфейсом

## Устранение возможных проблем

1. **Сообщение "Processing..." не исчезает:**
   - Проверьте, что API сервер запущен (`fixed_api_server.py`)
   - Убедитесь, что веб-интерфейс подключен к WebSocket (проверьте консоль браузера)
   - Проверьте, что userId совпадает в запросе и WebSocket подключении

2. **WebSocket не подключается:**
   - Проверьте, что API сервер запущен и слушает порт 8001
   - Проверьте консоль браузера на наличие ошибок подключения
   - Перезапустите API сервер и обновите страницу

3. **API сервер не отвечает:**
   - Проверьте логи в C:/RuslanAI/logs/api_server.log
   - Убедитесь, что порт 8001 не занят другим приложением
   - Перезапустите API сервер