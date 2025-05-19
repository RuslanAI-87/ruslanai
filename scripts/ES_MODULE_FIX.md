# Исправление проблем с ES модулями в RuslanAI

## Обзор проблемы

В проекте RuslanAI возникла проблема с импортом ES модулей, что привело к ошибкам:

```
Module not found: Error: Can't resolve './websocketService' in 'C:\RuslanAI\web_ui\src\services'
Did you mean 'websocketService.js'?
BREAKING CHANGE: The request './websocketService' failed to resolve only because it was resolved as fully specified
```

Эта ошибка связана с тем, что в package.json установлен `"type": "module"`, что указывает на использование строгих ES модулей. В этом режиме при импорте файлов необходимо явно указывать расширение файлов (.js, .jsx).

## Выполненные исправления

1. **Обновление импортов с расширениями файлов:**
   - В agentService.js: `import websocketService from "./websocketService.js";`
   - В RuslanAI.jsx:
     ```javascript
     import RecordingIndicator from "./RecordingIndicator.jsx";
     import useAudioRecorder from "../hooks/useAudioRecorder.js";
     import { sendMessageToAgent } from "../services/agentService.js";
     import websocketService from "../services/websocketService.js";
     ```
   - В App.jsx: `import RuslanAI from "./components/RuslanAI.jsx";`
   - В index.jsx: `import App from "./App.jsx";`

2. **Обновление WebWorker в useAudioRecorder.js:**
   - Добавлен тип модуля для WebWorker:
   ```javascript
   const worker = new Worker('/workers/audioWorker.js', { type: 'module' });
   ```

3. **Поддержка расширений файлов в vite.config.js:**
   - Добавлена поддержка различных расширений:
   ```javascript
   resolve: {
     alias: {
       '@': resolve(__dirname, 'src'),
       'services': resolve(__dirname, 'src/services')
     },
     extensions: ['.mjs', '.js', '.jsx', '.ts', '.tsx', '.json']
   }
   ```

## Как запустить обновленную версию

1. Запустите скрипт restart_frontend.ps1 для очистки кэша и перезапуска веб-интерфейса:
   ```powershell
   cd C:\RuslanAI\scripts
   .\restart_frontend.ps1
   ```

2. Убедитесь, что сервер WebSocket и API-сервер запущены:
   - WebSocket сервер должен работать на порту 8005
   - API сервер должен работать на порту 8001

3. Откройте браузер и перейдите по адресу:
   ```
   http://localhost:3000
   ```

## Возможные проблемы и их решение

1. **Ошибки с импортом модулей:**
   - Убедитесь, что все импорты в файлах содержат расширения (.js, .jsx)
   - Проверьте соответствие расширения файла его содержимому (.js для JavaScript, .jsx для React-компонентов)

2. **Проблемы с запуском:**
   - Очистите кэш npm: `npm cache clean --force`
   - Удалите node_modules и установите зависимости заново: `rm -r node_modules && npm install`
   - Перезапустите сервер: `npm run dev`

3. **Проблемы с WebSocket:**
   - Убедитесь, что сервер WebSocket запущен на порту 8005
   - Проверьте, что URL в websocketService.js указывает на правильный адрес: `ws://localhost:8005`

## Технические детали

В ES модулях (когда в package.json установлено `"type": "module"`) требуется явно указывать расширения файлов при импорте. Это особенность спецификации ECMAScript, которая делает импорты более предсказуемыми и позволяет более четко определить зависимости.

При использовании инструментов сборки, таких как Vite, необходимо настроить их для правильной обработки ES модулей. В конфигурации vite.config.js мы настроили разрешение модулей с разными расширениями, что помогает избежать проблем с импортами.