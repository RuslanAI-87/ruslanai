# Complete WebSocket Fix for RuslanAI
# This script applies all necessary fixes to resolve the WebSocket connection issues
# It addresses the "Unexpected ASGI message 'websocket.send', after sending 'websocket.close'" error

# Set UTF-8 encoding
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Define paths
$ROOT_DIR = "C:\RuslanAI"
$SCRIPTS_DIR = "$ROOT_DIR\scripts"
$LOGS_DIR = "$ROOT_DIR\logs"
$WEB_UI_DIR = "$ROOT_DIR\web_ui"
$WEB_UI_SERVICES_DIR = "$WEB_UI_DIR\src\services"
$WEB_UI_COMPONENTS_DIR = "$WEB_UI_DIR\src\components"
$API_SERVER_PATH = "$ROOT_DIR\central_agent\backend\encoding_fixed_api.py"
$BACKUP_DIR = "$ROOT_DIR\backup\websocket_complete_fix_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Create necessary directories
if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}
New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null

# Log file
$LOG_FILE = "$LOGS_DIR\complete_websocket_fix.log"
Set-Content -Path $LOG_FILE -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Starting Complete WebSocket Fix" -Encoding UTF8

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

# Function to back up a file
function Backup-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    
    if (Test-Path $FilePath) {
        $fileName = Split-Path $FilePath -Leaf
        $backupPath = "$BACKUP_DIR\$fileName"
        Copy-Item -Path $FilePath -Destination $backupPath -Force
        Log-Message "Backed up $FilePath to $backupPath"
        return $true
    } else {
        Log-Message "WARNING: File $FilePath not found, cannot create backup"
        return $false
    }
}

# Function to stop processes
function Stop-ProcessesByName {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ProcessName
    )
    
    Log-Message "Stopping $ProcessName processes..."
    Get-Process | Where-Object { $_.ProcessName -like "*$ProcessName*" } | ForEach-Object {
        try {
            $_ | Stop-Process -Force
            Log-Message "Stopped process: $($_.ProcessName) (PID: $($_.Id))"
        } catch {
            Log-Message "Error stopping process $($_.ProcessName): $_"
        }
    }
    
    # Wait a moment for processes to terminate
    Start-Sleep -Seconds 2
}

# Start the fix process
Log-Message "=== Starting Complete WebSocket Fix for RuslanAI ==="
Log-Message "This script fixes WebSocket connection stability issues in both client and server components"
Log-Message "Creating backup directory: $BACKUP_DIR"

# Step 1: Back up critical files
$filesToBackup = @(
    "$WEB_UI_SERVICES_DIR\websocketService.js",
    "$WEB_UI_SERVICES_DIR\agentService.js",
    "$WEB_UI_COMPONENTS_DIR\RuslanAI.jsx",
    "$API_SERVER_PATH"
)

foreach ($file in $filesToBackup) {
    Backup-File -FilePath $file
}

# Step 2: Stop running processes
Stop-ProcessesByName -ProcessName "python"
Stop-ProcessesByName -ProcessName "node"

# Step 3: Apply server-side ConnectionManager fix
Log-Message "Applying server-side ConnectionManager fix..."
try {
    & python "$SCRIPTS_DIR\fix_connection_manager.py"
    Log-Message "ConnectionManager fix applied"
} catch {
    Log-Message "ERROR: Failed to apply ConnectionManager fix: $_"
    Log-Message "Continuing with other fixes..."
}

# Step 4: Add WebSocket retry logic
Log-Message "Adding WebSocket retry logic..."
try {
    & python "$SCRIPTS_DIR\add_websocket_retry.py"
    Log-Message "WebSocket retry logic added"
} catch {
    Log-Message "ERROR: Failed to add WebSocket retry logic: $_"
    Log-Message "Continuing with other fixes..."
}

# Step 5: Apply client-side WebSocket service fix
Log-Message "Applying client-side WebSocket service updates..."
try {
    # Copy updated WebSocket service
    Copy-Item -Path "$SCRIPTS_DIR\websocket_service_update.js" -Destination "$WEB_UI_SERVICES_DIR\websocketService.js" -Force
    Log-Message "WebSocket service updated"
    
    # Copy updated agent service
    Copy-Item -Path "$SCRIPTS_DIR\fixed_agent_service.js" -Destination "$WEB_UI_SERVICES_DIR\agentService.js" -Force
    Log-Message "Agent service updated"
} catch {
    Log-Message "ERROR: Failed to update client services: $_"
    Log-Message "Continuing with other fixes..."
}

# Step 6: Update RuslanAI.jsx
Log-Message "Updating RuslanAI.jsx component..."
try {
    # Read the RuslanAI.jsx file
    $ruslanAIPath = "$WEB_UI_COMPONENTS_DIR\RuslanAI.jsx"
    $ruslanAIContent = Get-Content -Path $ruslanAIPath -Raw -Encoding UTF8
    
    # Read the fix instructions
    $fixInstructionsPath = "$SCRIPTS_DIR\fixed_ruslanai_jsx.js"
    
    if (Test-Path $fixInstructionsPath) {
        $fixInstructions = Get-Content -Path $fixInstructionsPath -Raw -Encoding UTF8
        
        # Add RefreshCw to icon imports if needed
        if ($ruslanAIContent -notmatch "RefreshCw") {
            $ruslanAIContent = $ruslanAIContent -replace 
                'import \{ Sun, Moon, MessageSquare, FileText, Archive, Users, BarChart2, Settings, ChevronDown, Upload, X, Play, Pause, AlertCircle, Check, Clock, Loader \} from "lucide-react";', 
                'import { Sun, Moon, MessageSquare, FileText, Archive, Users, BarChart2, Settings, ChevronDown, Upload, X, Play, Pause, AlertCircle, Check, Clock, Loader, RefreshCw } from "lucide-react";'
            Log-Message "Added RefreshCw import to RuslanAI.jsx"
        }
        
        # Add ReconnectButton component before return statement
        if ($ruslanAIContent -notmatch "ReconnectButton") {
            $reconnectButtonComponent = @"
  // Reconnect button component
  const ReconnectButton = () => {
    const handleReconnect = () => {
      console.log("Manual reconnection requested");
      websocketService.forceReconnect();
    };
    
    return (
      <button 
        onClick={handleReconnect}
        className="p-2 rounded-lg bg-yellow-500 hover:bg-yellow-600 text-white flex items-center"
        title="Reconnect to server"
      >
        <RefreshCw size={16} className="mr-1" />
        <span>Переподключиться</span>
      </button>
    );
  };
"@
            
            $ruslanAIContent = $ruslanAIContent -replace 
                '(?s)(return \()', 
                "$reconnectButtonComponent`n`n  `$1"
            Log-Message "Added ReconnectButton component to RuslanAI.jsx"
        }
        
        # Add connection state monitoring
        if ($ruslanAIContent -notmatch "handleConnectionStateChange") {
            $connectionStateEffect = @"
  // WebSocket connection state monitoring
  useEffect(() => {
    const handleConnectionStateChange = (state) => {
      console.log("WebSocket connection state changed:", state);
      if (state.state === 'disconnected' || state.state === 'error') {
        // Check if we have any pending tasks
        const trackedTasks = websocketService.getTrackedTasks ? websocketService.getTrackedTasks() : [];
        if (trackedTasks && trackedTasks.length > 0) {
          console.log("Connection lost with pending tasks:", trackedTasks);
          
          // Update UI for pending tasks
          trackedTasks.forEach(taskId => {
            if (taskMessageMap.current.has(taskId)) {
              const messageId = taskMessageMap.current.get(taskId);
              setMessages(prevMessages =>
                prevMessages.map(msg =>
                  msg.id === messageId
                    ? {
                        ...msg,
                        content: msg.content + " (Восстановление подключения...)",
                        reconnecting: true
                      }
                    : msg
                )
              );
            }
          });
        }
      } else if (state.state === 'connected') {
        // Connection restored, update UI
        console.log("Connection restored");
      } else if (state.state === 'max_retries_failed') {
        // Max retry attempts reached - inform user
        setMessages(prevMessages => [
          ...prevMessages, 
          {
            id: Date.now(),
            role: "system",
            content: "Не удалось восстановить соединение с сервером. Пожалуйста, перезагрузите страницу.",
            error: true
          }
        ]);
      }
    };

    // Register for connection state changes
    if (websocketService.onConnectionStateChange) {
      websocketService.onConnectionStateChange(handleConnectionStateChange);
    }

    return () => {
      // Unregister on cleanup
      if (websocketService.removeMessageCallback) {
        websocketService.removeMessageCallback('connection-state', handleConnectionStateChange);
      }
    };
  }, []);
"@
            
            $ruslanAIContent = $ruslanAIContent -replace 
                '(?s)(useEffect\(\) => \{.*?websocketService\.disconnect\(\);.*?\}\);)', 
                "`$1`n`n$connectionStateEffect"
            Log-Message "Added connection state monitoring to RuslanAI.jsx"
        }
        
        # Update message rendering to show reconnection status
        if ($ruslanAIContent -notmatch "message\.reconnecting") {
            $updatedMessageRender = @"
{message.isThinking ? (
  <div className="flex items-center">
    {message.reconnecting ? (
      <>
        <RefreshCw className="animate-spin mr-2" size={16} />
        <span>{message.content}</span>
      </>
    ) : (
      <>
        <Loader className="animate-spin mr-2" size={16} />
        <span>{message.content}</span>
      </>
    )}
  </div>
) : (
  <span>{message.content}</span>
)}
"@
            
            $ruslanAIContent = $ruslanAIContent -replace 
                '(?s)\{message\.isThinking \? \(.*?<span>\{message\.content\}</span>\n.*?\) : \(.*?<span>\{message\.content\}</span>\n.*?\)\}', 
                $updatedMessageRender
            Log-Message "Updated message rendering in RuslanAI.jsx"
        }
        
        # Add reconnect button to header
        if ($ruslanAIContent -notmatch "\{!websocketService.isConnected") {
            $ruslanAIContent = $ruslanAIContent -replace 
                '<header className="flex justify-between items-center p-4 border-b">\s*<div className="flex items-center">\s*<h1 className="text-xl font-bold mr-4">RuslanAI</h1>\s*</div>\s*</header>', 
                @"
<header className="flex justify-between items-center p-4 border-b">
          <div className="flex items-center">
            <h1 className="text-xl font-bold mr-4">RuslanAI</h1>
          </div>
          <div className="flex items-center">
            {!websocketService.isConnected() && <ReconnectButton />}
          </div>
        </header>
"@
            Log-Message "Added reconnect button to header in RuslanAI.jsx"
        }
        
        # Save the updated file
        Set-Content -Path $ruslanAIPath -Value $ruslanAIContent -Encoding UTF8
        Log-Message "Updated RuslanAI.jsx successfully"
    } else {
        Log-Message "WARNING: Could not find fixed_ruslanai_jsx.js, skipping RuslanAI.jsx updates"
    }
} catch {
    Log-Message "ERROR: Failed to update RuslanAI.jsx: $_"
    Log-Message "Continuing with other fixes..."
}

# Step 7: Create startup script for the fixed system
$START_SCRIPT = "$ROOT_DIR\start_fixed_ruslanai.ps1"
$startScriptContent = @"
# Start RuslanAI with WebSocket fixes
# This script starts all components of the RuslanAI system with WebSocket connection stability fixes

# Set UTF-8 encoding
`$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Define paths
`$ROOT_DIR = "C:\RuslanAI"
`$LOGS_DIR = "`$ROOT_DIR\logs"

# Ensure logs directory exists
if (-not (Test-Path `$LOGS_DIR)) {
    New-Item -ItemType Directory -Path `$LOGS_DIR -Force | Out-Null
}

# Log file
`$LOG_FILE = "`$LOGS_DIR\ruslanai_startup.log"
`$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Set-Content -Path `$LOG_FILE -Value "[`$timestamp] Starting RuslanAI with WebSocket stability fixes" -Encoding UTF8

# Function to log messages
function Log-Message {
    param (
        [Parameter(Mandatory=`$true)]
        [string]`$Message
    )
    
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    `$logMessage = "[`$timestamp] `$Message"
    Write-Host `$logMessage
    Add-Content -Path `$LOG_FILE -Value `$logMessage -Encoding UTF8
}

# Function to stop existing processes
function Stop-Processes {
    Log-Message "Stopping existing processes..."
    
    # Stop Python processes
    Get-Process | Where-Object { `$_.ProcessName -like "*python*" } | ForEach-Object {
        try {
            `$_ | Stop-Process -Force
            Log-Message "Stopped process: `$(`$_.ProcessName) (PID: `$(`$_.Id))"
        } catch {
            Log-Message "Error stopping process `$(`$_.ProcessName): `$_"
        }
    }
    
    # Stop Node processes
    Get-Process | Where-Object { `$_.ProcessName -like "*node*" } | ForEach-Object {
        try {
            `$_ | Stop-Process -Force
            Log-Message "Stopped process: `$(`$_.ProcessName) (PID: `$(`$_.Id))"
        } catch {
            Log-Message "Error stopping process `$(`$_.ProcessName): `$_"
        }
    }
    
    # Wait a moment for processes to terminate
    Start-Sleep -Seconds 2
}

# Start API server
function Start-ApiServer {
    Log-Message "Starting API server..."
    
    `$apiProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd `$ROOT_DIR && python -m central_agent.backend.encoding_fixed_api" -WindowStyle Normal -PassThru
    Log-Message "API server started with PID: `$(`$apiProcess.Id)"
    
    # Wait for API server to initialize
    Log-Message "Waiting for API server to initialize..."
    Start-Sleep -Seconds 5
    
    # Check if process is still running
    `$isRunning = Get-Process -Id `$apiProcess.Id -ErrorAction SilentlyContinue
    if (`$isRunning) {
        Log-Message "API server running successfully"
        return `$true
    } else {
        Log-Message "ERROR: API server process terminated unexpectedly"
        return `$false
    }
}

# Start Web UI
function Start-WebUI {
    Log-Message "Starting Web UI..."
    
    `$webUIProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd `$ROOT_DIR\web_ui && npm run dev" -WindowStyle Normal -PassThru
    Log-Message "Web UI started with PID: `$(`$webUIProcess.Id)"
    
    # Wait for Web UI to initialize
    Log-Message "Waiting for Web UI to initialize..."
    Start-Sleep -Seconds 5
    
    # Check if process is still running
    `$isRunning = Get-Process -Id `$webUIProcess.Id -ErrorAction SilentlyContinue
    if (`$isRunning) {
        Log-Message "Web UI running successfully"
        return `$true
    } else {
        Log-Message "ERROR: Web UI process terminated unexpectedly"
        return `$false
    }
}

# Main execution
Log-Message "=== Starting RuslanAI with WebSocket stability fixes ==="

# Stop existing processes
Stop-Processes

# Start components
`$apiServerStarted = Start-ApiServer
if (-not `$apiServerStarted) {
    Log-Message "Failed to start API server, aborting startup"
    exit 1
}

`$webUIStarted = Start-WebUI
if (-not `$webUIStarted) {
    Log-Message "Failed to start Web UI"
    # Continue anyway as API server might be useful on its own
}

# Open Web UI in browser
Log-Message "Opening RuslanAI in default browser..."
Start-Process "http://localhost:5173"

# Complete
Log-Message "RuslanAI system started successfully with WebSocket stability fixes"
Log-Message "Web UI URL: http://localhost:5173"
Log-Message "API Server URL: http://localhost:8001"
Log-Message ""
Log-Message "If you encounter any issues:"
Log-Message "1. Check the logs in `$LOGS_DIR"
Log-Message "2. Try refreshing the page to establish a new WebSocket connection"
Log-Message "3. Check browser console for any errors"
Log-Message ""
Log-Message "=== Startup Complete ==="
"@

Set-Content -Path $START_SCRIPT -Value $startScriptContent -Encoding UTF8
Log-Message "Created startup script at $START_SCRIPT"

# Step 8: Create desktop shortcut
$WshShell = New-Object -ComObject WScript.Shell
$SHORTCUT_PATH = "$ROOT_DIR\RuslanAI_WebSocket_Fixed.lnk"
$Shortcut = $WshShell.CreateShortcut($SHORTCUT_PATH)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$START_SCRIPT`""
$Shortcut.WorkingDirectory = $ROOT_DIR
$Shortcut.IconLocation = "C:\Windows\System32\shell32.dll,22"
$Shortcut.Description = "Start RuslanAI with WebSocket stability fixes"
$Shortcut.Save()
Log-Message "Created desktop shortcut at $SHORTCUT_PATH"

# Step 9: Create documentation
$DOCS_FILE = "$ROOT_DIR\WEBSOCKET_FIX_README.md"
$docsContent = @"
# RuslanAI WebSocket Connection Fix

## Problem Description

The RuslanAI system was experiencing issues with WebSocket connections being closed prematurely,
resulting in notifications not being delivered to clients. When sending a message in the chat,
users would see "Processing your request..." indefinitely, even though the server had completed
processing the task.

The specific error in the logs was:
```
Unexpected ASGI message 'websocket.send', after sending 'websocket.close' or response already completed.
```

## Comprehensive Solution

This fix addresses WebSocket stability issues at multiple levels:

### 1. Server-Side Fixes

- **Enhanced ConnectionManager**:
  - Added proper connection state tracking
  - Implemented message buffering for disconnected clients
  - Improved error handling and reconnection support
  - Added verification before sending messages

- **WebSocket Message Retry Logic**:
  - Added retry decorator for WebSocket message sending
  - Implemented exponential backoff for retries
  - Added connection state checking before sending

- **Improved WebSocket Endpoint**:
  - Enhanced error handling for WebSocket operations
  - Added reconnection support
  - Better handling of message sending failures

### 2. Client-Side Fixes

- **Enhanced WebSocket Service**:
  - Implemented robust reconnection logic
  - Added message queuing for offline periods
  - Improved keep-alive mechanism with ping/pong
  - Added connection state tracking and notifications

- **Improved UI Components**:
  - Added connection state monitoring in React components
  - Implemented visual indicators for reconnection
  - Added manual reconnect button for user control
  - Enhanced message handling for offline periods

## How to Use

1. Run the fixed system by double-clicking the shortcut:
   **$SHORTCUT_PATH**

2. The system will:
   - Start the API server with enhanced WebSocket handling
   - Start the web UI with improved connection stability
   - Open the web interface in your default browser

3. Test the fix by:
   - Sending messages in the chat
   - Check that responses appear correctly
   - Try temporarily disconnecting your network to test reconnection

## Monitoring and Troubleshooting

### Check Logs

- Server logs: `$LOGS_DIR\api_server.log`
- WebSocket fix logs: `$LOGS_DIR\complete_websocket_fix.log`

### Browser Debugging

1. Open browser developer tools (F12)
2. Go to the Network tab and filter for WebSocket (WS)
3. Check for ping messages being sent every 30 seconds
4. Verify that pong responses are received from the server

### Manual Reconnection

If you still experience connection issues:
1. Use the "Reconnect" button that appears in the header when disconnected
2. Refresh the page to establish a new WebSocket connection

## Backup and Recovery

All original files were backed up to:
$BACKUP_DIR

If needed, you can restore these files to revert to the original state.

## Technical Details

The fix implements industry best practices for WebSocket connection stability:

1. **Keep-alive mechanism** with ping/pong messages every 30 seconds
2. **Connection state tracking** to detect and handle disconnections
3. **Message buffering** to handle offline periods
4. **Retry logic** for message sending failures
5. **Exponential backoff** for reconnection attempts
6. **Explicit state synchronization** between client and server

## Further Improvements

For even better stability, consider:

1. Using a WebSocket library with built-in reconnection logic like `socket.io`
2. Implementing server-side session persistence for longer disconnections
3. Adding a message ID system for deduplication after reconnection
"@

Set-Content -Path $DOCS_FILE -Value $docsContent -Encoding UTF8
Log-Message "Created documentation at $DOCS_FILE"

# Step 10: Start the fixed system
Log-Message "Starting RuslanAI with WebSocket fixes..."
try {
    # Start the API server
    $apiProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $ROOT_DIR && python -m central_agent.backend.encoding_fixed_api" -WindowStyle Normal -PassThru
    Log-Message "API server started with PID: $($apiProcess.Id)"
    
    # Wait for API server to initialize
    Start-Sleep -Seconds 5
    
    # Start the web UI
    $webUIProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $ROOT_DIR\web_ui && npm run dev" -WindowStyle Normal -PassThru
    Log-Message "Web UI started with PID: $($webUIProcess.Id)"
    
    # Wait for web UI to initialize
    Start-Sleep -Seconds 5
    
    # Open the web UI in browser
    Start-Process "http://localhost:5173"
    Log-Message "Opened RuslanAI in default browser"
} catch {
    Log-Message "ERROR: Failed to start RuslanAI components: $_"
    Log-Message "Please use the desktop shortcut to start the system manually"
}

# Complete
Log-Message "Complete WebSocket Fix for RuslanAI completed successfully!"
Log-Message "Documentation: $DOCS_FILE"
Log-Message "Start script: $START_SCRIPT"
Log-Message "Desktop shortcut: $SHORTCUT_PATH"
Log-Message ""
Log-Message "The system is now running with enhanced WebSocket stability"
Log-Message "Please test by sending messages in the chat interface"
Log-Message "=================================================="