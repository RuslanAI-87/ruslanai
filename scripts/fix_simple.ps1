# Simple React Fix Script
# This script fixes React import issues by recreating files from scratch

Write-Host "Simple React Fix Script" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host "This script will recreate React files to fix import issues."
Write-Host ""

# Create App.jsx
$AppContent = @'
function App() {
  return <RuslanAI />;
}

import RuslanAI from "./components/RuslanAI";
export default App;
'@

# Create main.jsx
$MainContent = @'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
'@

# Create RecordingIndicator.jsx
$RecordingIndicatorContent = @'
import React from 'react';
import { AlertCircle, Clock, Mic, CheckCircle, RotateCw } from 'lucide-react';

// Audio recording status indicator component
const RecordingIndicator = ({ status, error }) => {
  // Determine icon and color based on status
  const getStatusDisplay = () => {
    switch (status) {
      case 'idle':
        return {
          icon: <CheckCircle size={16} />,
          color: 'text-gray-500',
          text: 'Ready'
        };
      case 'preparing':
        return {
          icon: <RotateCw className="animate-spin" size={16} />,
          color: 'text-blue-500',
          text: 'Preparing...'
        };
      case 'recording':
        return {
          icon: <Mic className="animate-pulse" size={16} />,
          color: 'text-red-500',
          text: 'Recording...'
        };
      case 'processing':
        return {
          icon: <RotateCw className="animate-spin" size={16} />,
          color: 'text-yellow-500',
          text: 'Processing audio...'
        };
      case 'transcribing':
        return {
          icon: <RotateCw className="animate-spin" size={16} />,
          color: 'text-purple-500',
          text: 'Transcribing speech...'
        };
      case 'error':
        return {
          icon: <AlertCircle size={16} />,
          color: 'text-red-500',
          text: error || 'Error'
        };
      default:
        return {
          icon: <Clock size={16} />,
          color: 'text-gray-500',
          text: 'Waiting'
        };
    }
  };

  const { icon, color, text } = getStatusDisplay();

  return (
    <div className={"flex items-center " + color + " text-xs py-1 px-2 rounded-md bg-opacity-10 dark:bg-opacity-20"}>
      {icon}
      <span className="ml-1">{text}</span>
    </div>
  );
};

export default RecordingIndicator;
'@

# Create RuslanAI.jsx
$RuslanAIContent = @'
import React, { useState } from 'react';
import { MessageSquare, Send, RefreshCw } from 'lucide-react';

const RuslanAI = () => {
  const [messages, setMessages] = useState([
    { id: 1, role: "system", content: "Welcome to RuslanAI! How can I help you today?", timestamp: new Date().toISOString() }
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
      content: "Processing your request...",
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
                content: `This is a demo response to your message: "${inputMessage}"`,
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
                placeholder="Type your message..."
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

# Create index.html
$IndexHtmlContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RuslanAI</title>
</head>
<body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
</body>
</html>
'@

# Create vite.config.js
$ViteConfigContent = @'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000
  }
})
'@

# Create tailwind.config.js
$TailwindConfigContent = @'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
'@

# Create postcss.config.js
$PostcssConfigContent = @'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@

# Create or overwrite files
try {
    # Create backup directory
    $BackupDir = "C:\RuslanAI\web_ui_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "Creating backup directory: $BackupDir" -ForegroundColor Yellow
    New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
    
    # Backup important files
    if (Test-Path "C:\RuslanAI\web_ui\src\App.jsx") {
        Copy-Item "C:\RuslanAI\web_ui\src\App.jsx" -Destination "$BackupDir\App.jsx.bak" -Force
    }
    if (Test-Path "C:\RuslanAI\web_ui\src\main.jsx") {
        Copy-Item "C:\RuslanAI\web_ui\src\main.jsx" -Destination "$BackupDir\main.jsx.bak" -Force
    }
    if (Test-Path "C:\RuslanAI\web_ui\src\components\RecordingIndicator.jsx") {
        Copy-Item "C:\RuslanAI\web_ui\src\components\RecordingIndicator.jsx" -Destination "$BackupDir\RecordingIndicator.jsx.bak" -Force
    }
    if (Test-Path "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx") {
        Copy-Item "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx" -Destination "$BackupDir\RuslanAI.jsx.bak" -Force
    }
    
    Write-Host "Files backed up to $BackupDir" -ForegroundColor Green
    
    # Create directories if they don't exist
    if (-Not (Test-Path "C:\RuslanAI\web_ui\src\components")) {
        New-Item -Path "C:\RuslanAI\web_ui\src\components" -ItemType Directory -Force | Out-Null
    }
    
    # Write files
    Set-Content -Path "C:\RuslanAI\web_ui\src\App.jsx" -Value $AppContent -Encoding UTF8
    Set-Content -Path "C:\RuslanAI\web_ui\src\main.jsx" -Value $MainContent -Encoding UTF8
    Set-Content -Path "C:\RuslanAI\web_ui\src\components\RecordingIndicator.jsx" -Value $RecordingIndicatorContent -Encoding UTF8
    Set-Content -Path "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx" -Value $RuslanAIContent -Encoding UTF8
    Set-Content -Path "C:\RuslanAI\web_ui\index.html" -Value $IndexHtmlContent -Encoding UTF8
    Set-Content -Path "C:\RuslanAI\web_ui\vite.config.js" -Value $ViteConfigContent -Encoding UTF8
    Set-Content -Path "C:\RuslanAI\web_ui\tailwind.config.js" -Value $TailwindConfigContent -Encoding UTF8
    Set-Content -Path "C:\RuslanAI\web_ui\postcss.config.js" -Value $PostcssConfigContent -Encoding UTF8
    
    Write-Host "All files created successfully!" -ForegroundColor Green
    
    # Install dependencies if needed
    cd "C:\RuslanAI\web_ui"
    
    Write-Host "Installing required dependencies..." -ForegroundColor Yellow
    
    # Try to install dependencies
    try {
        npm install -s react react-dom
        npm install -D -s vite @vitejs/plugin-react
        npm install -s lucide-react
        npm install -D -s tailwindcss postcss autoprefixer
    } catch {
        Write-Host "Warning: Some dependencies installation failed. You may need to run npm install manually." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Fix completed. You can now start the web UI with:" -ForegroundColor Green
    Write-Host "cd C:\RuslanAI\web_ui" -ForegroundColor Cyan
    Write-Host "npm run dev" -ForegroundColor Cyan
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}