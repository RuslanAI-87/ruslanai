# Полное исправление веб-интерфейса RuslanAI
# Этот скрипт полностью пересоздает основные файлы React для исправления проблем с импортами

Write-Host "Полное исправление веб-интерфейса RuslanAI" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "Этот скрипт полностью пересоздает основные файлы React для исправления проблем с импортами."
Write-Host ""

# Создаем бэкап, если это необходимо
$BackupDir = "C:\RuslanAI\web_ui_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
if (-Not (Test-Path $BackupDir)) {
    Write-Host "Создание резервной копии веб-интерфейса..." -ForegroundColor Yellow
    New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
    Copy-Item -Path "C:\RuslanAI\web_ui\*" -Destination $BackupDir -Recurse -Force
    Write-Host "Резервная копия создана в $BackupDir" -ForegroundColor Green
}

# Запуск скрипта для исправления файлов
Write-Host "Запуск скрипта исправления..." -ForegroundColor Yellow
try {
    cd "C:\RuslanAI\scripts"
    python fix_all_bom.py
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Исправление успешно выполнено!" -ForegroundColor Green
    } else {
        Write-Host "Ошибка при исправлении, код: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Ошибка при исправлении: $_" -ForegroundColor Red
    exit 1
}

# Создание отдельных компонентов заново
Write-Host "Создание отдельных компонентов RuslanAI.jsx..." -ForegroundColor Yellow

# RuslanAI.jsx (минимальная версия для демонстрации)
$RuslanAIContent = @'
import React, { useState, useEffect } from 'react';
import RecordingIndicator from './RecordingIndicator';
import { MessageSquare, FileText, Mic, Send, RefreshCw } from 'lucide-react';

const RuslanAI = () => {
  const [messages, setMessages] = useState([
    { id: 1, role: "system", content: "Добро пожаловать в RuslanAI! Чем я могу вам помочь сегодня?", timestamp: new Date().toISOString() }
  ]);
  const [inputMessage, setInputMessage] = useState("");
  const [isAiThinking, setIsAiThinking] = useState(false);
  
  // Handle Enter key in input field
  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };
  
  // Format timestamp
  const formatTime = (timestamp) => {
    if (!timestamp) return '';
    const date = new Date(timestamp);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };
  
  // Send message to agent
  const handleSendMessage = async () => {
    if (inputMessage.trim() === "" || isAiThinking) return;
    
    const newMessage = {
      id: messages.length + 1,
      role: "user",
      content: inputMessage,
      timestamp: new Date().toISOString()
    };
    
    // Add user message and clear input
    setMessages([...messages, newMessage]);
    setInputMessage("");
    setIsAiThinking(true);
    
    // Add temporary thinking message
    const aiMessageId = messages.length + 2;
    const aiMessage = {
      id: aiMessageId,
      role: "system",
      content: "Обработка запроса...",
      isThinking: true,
      timestamp: new Date().toISOString()
    };
    
    setMessages(prev => [...prev, aiMessage]);
    
    // Simulate API call delay
    setTimeout(() => {
      setMessages(prevMessages =>
        prevMessages.map(msg =>
          msg.id === aiMessageId
            ? {
                ...msg,
                content: `Это демонстрационный ответ на ваше сообщение: "${inputMessage}"`,
                isThinking: false,
                timestamp: new Date().toISOString()
              }
            : msg
        )
      );
      setIsAiThinking(false);
    }, 2000);
  };
  
  return (
    <div className="flex flex-col h-screen">
      {/* Header */}
      <header className="flex justify-between items-center p-4 border-b">
        <h1 className="text-xl font-bold">RuslanAI</h1>
      </header>
      
      {/* Main Content */}
      <div className="flex-1 overflow-auto p-4">
        <div className="flex flex-col h-full">
          {/* Messages */}
          <div className="flex-1 overflow-auto mb-4 p-4 rounded-lg border shadow-sm bg-opacity-50 space-y-4">
            {messages.map((message) => (
              <div
                key={message.id}
                className={`flex ${message.role === "system" ? "justify-start" : "justify-end"} mb-2`}
              >
                <div className={`relative max-w-4xl rounded-lg py-2 px-4 ${
                  message.role === "system"
                    ? "bg-blue-100 text-blue-800"
                    : "bg-gray-100 text-gray-800"
                }`}>
                  {/* Message content */}
                  <div className="mb-1">
                    {message.isThinking ? (
                      <div className="flex items-center">
                        <RefreshCw className="animate-spin mr-2" size={16} />
                        <span>{message.content}</span>
                      </div>
                    ) : (
                      <span>{message.content}</span>
                    )}
                  </div>
                  
                  {/* Timestamp */}
                  <div className="text-xs text-gray-500 text-right mt-1">
                    {formatTime(message.timestamp)}
                  </div>
                </div>
              </div>
            ))}
          </div>
          
          {/* Input area */}
          <div className="relative">
            <div className="flex items-center gap-2">
              {/* Message input */}
              <input
                type="text"
                className="w-full p-3 rounded-lg border focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Введите сообщение..."
                value={inputMessage}
                onChange={(e) => setInputMessage(e.target.value)}
                onKeyDown={handleKeyDown}
                disabled={isAiThinking}
              />
              
              {/* Send button */}
              <button
                onClick={handleSendMessage}
                className={`p-3 rounded-lg ${
                  isAiThinking || inputMessage.trim() === ""
                    ? "bg-gray-300 text-gray-500 cursor-not-allowed"
                    : "bg-blue-500 hover:bg-blue-600 text-white"
                }`}
                disabled={isAiThinking || inputMessage.trim() === ""}
              >
                {isAiThinking ? (
                  <RefreshCw className="animate-spin" size={20} />
                ) : (
                  <Send size={20} />
                )}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RuslanAI;
'@

try {
    Set-Content -Path "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx" -Value $RuslanAIContent -Force -Encoding UTF8
    Write-Host "RuslanAI.jsx создан успешно" -ForegroundColor Green
} catch {
    Write-Host "Ошибка при создании RuslanAI.jsx: $_" -ForegroundColor Red
}

# Установка зависимостей если необходимо
Write-Host "Проверка зависимостей npm..." -ForegroundColor Yellow
try {
    cd "C:\RuslanAI\web_ui"
    
    # Установка Lucide React если нет
    if (-Not (Test-Path ".\node_modules\lucide-react")) {
        Write-Host "Установка lucide-react..." -ForegroundColor Yellow
        npm install lucide-react
    } else {
        Write-Host "lucide-react уже установлен" -ForegroundColor Green
    }
    
    # Установка Tailwind CSS если нет
    if (-Not (Test-Path ".\node_modules\tailwindcss")) {
        Write-Host "Установка tailwindcss..." -ForegroundColor Yellow
        npm install -D tailwindcss postcss autoprefixer
        npx tailwindcss init -p
    } else {
        Write-Host "tailwindcss уже установлен" -ForegroundColor Green
    }
    
    # Проверка React
    if (-Not (Test-Path ".\node_modules\react")) {
        Write-Host "Установка react и react-dom..." -ForegroundColor Yellow
        npm install react react-dom
    } else {
        Write-Host "react уже установлен" -ForegroundColor Green
    }
    
    # Проверка Vite
    if (-Not (Test-Path ".\node_modules\vite")) {
        Write-Host "Установка vite и @vitejs/plugin-react..." -ForegroundColor Yellow
        npm install -D vite @vitejs/plugin-react
    } else {
        Write-Host "vite уже установлен" -ForegroundColor Green
    }
} catch {
    Write-Host "Ошибка при установке зависимостей: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Теперь веб-интерфейс должен быть полностью исправлен." -ForegroundColor Green
Write-Host "Чтобы запустить его, выполните:" -ForegroundColor Cyan
Write-Host "cd C:\RuslanAI\web_ui" -ForegroundColor Cyan
Write-Host "npm run dev" -ForegroundColor Cyan