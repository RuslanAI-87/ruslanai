# Simple WebSocket Connection Fix
# This script applies a minimal fix for the WebSocket connection issues

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Define paths
$ROOT_DIR = "C:\RuslanAI"
$LOGS_DIR = "$ROOT_DIR\logs"

# Create logs directory if needed
if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}

# Log file
$LOG_FILE = "$LOGS_DIR\simple_websocket_fix.log"
Set-Content -Path $LOG_FILE -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Starting Simple WebSocket Fix" -Encoding UTF8

# Function to log messages
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $LOG_FILE -Value $logMessage -Encoding UTF8
}

# Fix WebSocket ping-pong timeout (simplest fix)
Log-Message "Applying WebSocket ping-pong timeout fix..."

# 1. Create an improved WebSocket service with keep-alive
$WS_SERVICE_PATH = "$ROOT_DIR\web_ui\src\services\websocketService.js"
$BACKUP_PATH = "$WS_SERVICE_PATH.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Backup the original file
if (Test-Path $WS_SERVICE_PATH) {
    Copy-Item -Path $WS_SERVICE_PATH -Destination $BACKUP_PATH -Force
    Log-Message "Backed up original WebSocket service to $BACKUP_PATH"
}

# Simplified content with ping-pong mechanism
$wsServiceContent = @"
// Improved WebSocket service with keep-alive ping
class WebSocketService {
  constructor() {
    this.socket = null;
    this.userId = localStorage.getItem('userId') || this.generateUserId();
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 10;
    this.reconnectDelay = 1000;
    this.typeSpecificCallbacks = new Map(); // Map for type-specific callbacks
    this.messageCallbacks = []; // For backwards compatibility
    this.isConnected = false;
    this.pingInterval = null;
    
    // Save userId in localStorage
    localStorage.setItem('userId', this.userId);
    
    // Auto-reconnect on page visibility change
    if (typeof document !== 'undefined') {
      document.addEventListener('visibilitychange', () => {
        if (document.visibilityState === 'visible' && !this.isConnected) {
          console.log('Page became visible, reconnecting WebSocket');
          this.connect();
        }
      });
    }
  }

  // Generate unique user ID
  generateUserId() {
    return 'user_' + Math.random().toString(36).substring(2, 15);
  }

  // Connect to WebSocket server
  connect() {
    if (this.socket && (this.socket.readyState === WebSocket.OPEN || this.socket.readyState === WebSocket.CONNECTING)) {
      console.log('WebSocket already connected or connecting');
      return;
    }

    // Use ?userId parameter for API server WebSocket endpoint
    const wsUrl = \`ws://localhost:8001/ws?userId=\${this.userId}\`;
    console.log("Connecting to WebSocket server: " + wsUrl);
    
    try {
      this.socket = new WebSocket(wsUrl);
      
      this.socket.onopen = () => {
        console.log('WebSocket connection established');
        this.isConnected = true;
        this.reconnectAttempts = 0;
        
        // Start the ping interval
        this.startKeepAlive();
      };
      
      this.socket.onmessage = (event) => {
        try {
          console.log('WebSocket message received:', event.data);
          const data = JSON.parse(event.data);
          
          // Skip ping/pong messages for normal handlers
          if (data.type === 'ping' || data.type === 'pong') {
            console.log(\`Received \${data.type} message\`);
            return;
          }
          
          // Extract type and payload
          const { type, payload } = data;
          
          // Call type-specific callbacks if any
          if (type && this.typeSpecificCallbacks.has(type)) {
            const callbacks = this.typeSpecificCallbacks.get(type);
            callbacks.forEach(callback => {
              try {
                callback(payload || data);
              } catch (error) {
                console.error(\`Error in type-specific callback for \${type}:\`, error);
              }
            });
          }
          
          // Call general message callbacks
          this.messageCallbacks.forEach(callback => {
            try {
              callback(data);
            } catch (error) {
              console.error('Error in general message callback:', error);
            }
          });
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
        }
      };
      
      this.socket.onclose = (event) => {
        console.log("WebSocket connection closed: code=" + event.code + ", reason=" + event.reason);
        this.isConnected = false;
        this.stopKeepAlive();
        this.attemptReconnect();
      };
      
      this.socket.onerror = (error) => {
        console.error('WebSocket error:', error);
      };
    } catch (error) {
      console.error('Error creating WebSocket connection:', error);
      this.attemptReconnect();
    }
  }
  
  // Start keep-alive pings
  startKeepAlive() {
    this.stopKeepAlive(); // Clear any existing interval
    
    this.pingInterval = setInterval(() => {
      if (this.socket && this.socket.readyState === WebSocket.OPEN) {
        console.log('Sending ping to keep connection alive');
        this.sendMessage({ type: 'ping', timestamp: Date.now() });
      } else {
        console.warn('Cannot send ping - socket not open');
      }
    }, 15000); // Send ping every 15 seconds
  }
  
  // Stop keep-alive pings
  stopKeepAlive() {
    if (this.pingInterval) {
      clearInterval(this.pingInterval);
      this.pingInterval = null;
    }
  }

  // Attempt reconnection with exponential backoff
  attemptReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error(\`Maximum reconnection attempts reached (\${this.maxReconnectAttempts})\`);
      return;
    }
    
    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(1.5, this.reconnectAttempts - 1);
    console.log(\`Reconnecting in \${delay}ms... (Attempt \${this.reconnectAttempts}/\${this.maxReconnectAttempts})\`);
    
    setTimeout(() => this.connect(), delay);
  }

  // Send message to server
  sendMessage(message) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      console.error('Cannot send message: WebSocket not connected');
      return false;
    }

    try {
      const messageStr = typeof message === 'string' ? message : JSON.stringify(message);
      this.socket.send(messageStr);
      return true;
    } catch (error) {
      console.error('Error sending WebSocket message:', error);
      return false;
    }
  }

  // Add callback for specific message type
  addMessageCallback(type, callback) {
    if (typeof callback === 'function') {
      if (!this.typeSpecificCallbacks.has(type)) {
        this.typeSpecificCallbacks.set(type, []);
      }
      this.typeSpecificCallbacks.get(type).push(callback);
    }
    return this;
  }

  // Remove callback for specific message type
  removeMessageCallback(type, callback) {
    if (this.typeSpecificCallbacks.has(type)) {
      const callbacks = this.typeSpecificCallbacks.get(type);
      const index = callbacks.indexOf(callback);
      if (index !== -1) {
        callbacks.splice(index, 1);
      }
    }
    return this;
  }

  // Subscribe to receive all messages (backward compatibility)
  onMessage(callback) {
    if (typeof callback === 'function' && !this.messageCallbacks.includes(callback)) {
      this.messageCallbacks.push(callback);
    }
    return this;
  }

  // Unsubscribe from receiving messages (backward compatibility)
  offMessage(callback) {
    this.messageCallbacks = this.messageCallbacks.filter(cb => cb !== callback);
    return this;
  }

  // Disconnect from server
  disconnect() {
    this.stopKeepAlive();
    
    if (this.socket) {
      this.socket.close();
      this.socket = null;
      this.isConnected = false;
    }
  }

  // Force reconnection (useful if connection seems stuck)
  forceReconnect() {
    console.log('Forcing WebSocket reconnection');
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
    this.isConnected = false;
    this.reconnectAttempts = 0;
    this.connect();
    return this;
  }
  
  // Check if currently connected
  getIsConnected() {
    return this.socket && this.socket.readyState === WebSocket.OPEN;
  }
}

// Create singleton instance
const websocketService = new WebSocketService();

// Connect automatically when module is imported
websocketService.connect();

export default websocketService;
"@

# Write the improved WebSocket service
Set-Content -Path $WS_SERVICE_PATH -Value $wsServiceContent -Encoding UTF8
Log-Message "Updated WebSocket service with keep-alive ping mechanism"

# 2. Create a minimal API server patch that adds ping-pong handling
$API_PATCH_PATH = "$ROOT_DIR\scripts\api_patch_ping.py"
$API_PATCH_CONTENT = @"
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
import sys

# Setup logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s: %(message)s',
    handlers=[
        logging.FileHandler("C:/RuslanAI/logs/api_ping_patch.log", encoding="utf-8"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("APIPingPatch")

# Path to the API server file
API_FILE = "C:/RuslanAI/central_agent/backend/encoding_fixed_api.py"

def add_ping_pong_handler():
    """Add ping-pong handler to the WebSocket endpoint"""
    logger.info("Adding ping-pong handler to WebSocket endpoint")
    
    # Read current file
    with open(API_FILE, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Backup the original file
    backup_file = f"{API_FILE}.backup_ping"
    with open(backup_file, "w", encoding="utf-8") as f:
        f.write(content)
    logger.info(f"Created backup at {backup_file}")
    
    # Look for the message processing part
    marker = "# Получено сообщение от клиента"
    if marker not in content:
        # Try another marker
        marker = "# Обработка различных типов сообщений"
        if marker not in content:
            # Try a more general marker
            marker = "data = await websocket.receive_json()"
            if marker not in content:
                logger.error("Could not find message processing part in WebSocket endpoint")
                return False
    
    # Add ping-pong handler
    ping_handler = """
                # Handle ping message for keep-alive
                if message_type == "ping" or data.get("type") == "ping":
                    logger.info(f"Received ping from client {client_id}")
                    try:
                        await websocket.send_json({
                            "type": "pong",
                            "payload": {"timestamp": time.time()}
                        })
                        logger.info(f"Sent pong to client {client_id}")
                    except Exception as e:
                        logger.error(f"Error sending pong to client {client_id}: {e}")
                    continue
"""
    
    # Add the ping handler after the marker
    parts = content.split(marker, 1)
    if len(parts) != 2:
        logger.error("Could not split content at marker")
        return False
    
    # Make sure we have the necessary imports
    if "import time" not in content and "from time import time" not in content:
        imports_section = "import asyncio\n"
        if imports_section in content:
            parts[0] = parts[0].replace(imports_section, imports_section + "import time\n")
        else:
            logger.warning("Could not find import section, adding time import might fail")
            parts[0] = "import time\n" + parts[0]
    
    # Combine with the new handler
    new_content = parts[0] + marker + ping_handler + parts[1]
    
    # Write the updated content
    with open(API_FILE, "w", encoding="utf-8") as f:
        f.write(new_content)
    
    logger.info("Added ping-pong handler to WebSocket endpoint")
    return True

if __name__ == "__main__":
    if add_ping_pong_handler():
        print("Successfully added ping-pong handler to API server")
        sys.exit(0)
    else:
        print("Failed to add ping-pong handler to API server")
        sys.exit(1)
"@

# Write the API patch file
Set-Content -Path $API_PATCH_PATH -Value $API_PATCH_CONTENT -Encoding UTF8
Log-Message "Created API server patch for ping-pong handling"

# 3. Create a simple reconnect button for RuslanAI.jsx
$RECONNECT_COMPONENT_PATH = "$ROOT_DIR\scripts\reconnect_component.jsx"
$RECONNECT_COMPONENT_CONTENT = @"
// ReconnectButton component to add to RuslanAI.jsx
import { RefreshCw } from 'lucide-react';

const ReconnectButton = () => {
  const handleReconnect = () => {
    console.log("Manual reconnection requested");
    if (window.websocketService) {
      window.websocketService.forceReconnect();
    }
  };
  
  return (
    <button 
      onClick={handleReconnect}
      className="p-2 rounded-lg bg-yellow-500 hover:bg-yellow-600 text-white flex items-center"
      title="Reconnect to server"
    >
      <RefreshCw size={16} className="mr-1" />
      <span>Reconnect</span>
    </button>
  );
};

// Usage:
// 1. Add this component to RuslanAI.jsx
// 2. Import RefreshCw from lucide-react if not already imported
// 3. Add the button to the header:
//    <div className="flex items-center">
//      {!websocketService.getIsConnected() && <ReconnectButton />}
//    </div>
"@

# Write the reconnect component file
Set-Content -Path $RECONNECT_COMPONENT_PATH -Value $RECONNECT_COMPONENT_CONTENT -Encoding UTF8
Log-Message "Created reconnect button component"

# 4. Stop and restart services
Log-Message "Stopping existing processes..."

# Stop Python processes
Get-Process | Where-Object { $_.ProcessName -like "*python*" } | ForEach-Object {
    try {
        $_ | Stop-Process -Force
        Log-Message "Stopped process: $($_.ProcessName) (PID: $($_.Id))"
    } catch {
        Log-Message "Error stopping process $($_.ProcessName): $_"
    }
}

# Stop Node processes
Get-Process | Where-Object { $_.ProcessName -like "*node*" } | ForEach-Object {
    try {
        $_ | Stop-Process -Force
        Log-Message "Stopped process: $($_.ProcessName) (PID: $($_.Id))"
    } catch {
        Log-Message "Error stopping process $($_.ProcessName): $_"
    }
}

# Wait a moment for processes to terminate
Start-Sleep -Seconds 2

# 5. Apply the API patch
Log-Message "Applying API server patch..."
try {
    & python $API_PATCH_PATH
    if ($LASTEXITCODE -eq 0) {
        Log-Message "API server patch applied successfully"
    } else {
        Log-Message "API server patch failed with code $LASTEXITCODE"
    }
} catch {
    Log-Message "Error applying API server patch: $_"
}

# 6. Start services
Log-Message "Starting API server..."
$apiProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $ROOT_DIR && python -m central_agent.backend.encoding_fixed_api" -WindowStyle Normal -PassThru
Log-Message "API server started with PID: $($apiProcess.Id)"

# Wait for API server to initialize
Start-Sleep -Seconds 5

Log-Message "Starting web UI..."
$webUIProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $ROOT_DIR\web_ui && npm run dev" -WindowStyle Normal -PassThru
Log-Message "Web UI started with PID: $($webUIProcess.Id)"

# Wait for web UI to initialize
Start-Sleep -Seconds 3

# 7. Open web UI in browser
Start-Process "http://localhost:5173"
Log-Message "Opened web UI in browser"

# 8. Create a simple desktop shortcut
$shortcutPath = "$ROOT_DIR\Start_Fixed_RuslanAI.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$ROOT_DIR\scripts\simple_websocket_fix.ps1`""
$Shortcut.WorkingDirectory = $ROOT_DIR
$Shortcut.IconLocation = "C:\Windows\System32\shell32.dll,22"
$Shortcut.Description = "Start RuslanAI with WebSocket fixes"
$Shortcut.Save()
Log-Message "Created desktop shortcut at $shortcutPath"

# Complete
Log-Message "Simple WebSocket Fix completed"
Log-Message "The system has been updated with ping-pong keep-alive mechanism"
Log-Message "If you still experience connection issues, try the following:"
Log-Message "1. Refresh the web page to establish a new WebSocket connection"
Log-Message "2. Check the browser console for WebSocket errors"
Log-Message "3. Check logs at $LOGS_DIR\api_server.log"
"@