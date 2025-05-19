# WebSocket Connection Stability Fix for RuslanAI
# This script updates the WebSocket handling to prevent premature disconnections
# and properly handle reconnection scenarios.

# Set UTF-8 encoding to avoid issues with Cyrillic characters
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Define paths
$ROOT_DIR = "C:\RuslanAI"
$SCRIPTS_DIR = "$ROOT_DIR\scripts"
$WEB_UI_DIR = "$ROOT_DIR\web_ui"
$WEB_UI_SERVICES_DIR = "$WEB_UI_DIR\src\services"
$WEB_UI_COMPONENTS_DIR = "$WEB_UI_DIR\src\components"
$LOGS_DIR = "$ROOT_DIR\logs"

# Create backup directory for today
$DATE_SUFFIX = Get-Date -Format "yyyyMMdd_HHmmss"
$BACKUP_DIR = "$ROOT_DIR\backup\websocket_fix_$DATE_SUFFIX"
New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null

# Function to log messages with timestamps
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$LogFile = "$LOGS_DIR\websocket_fix.log"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogFile -Value $logMessage -Encoding UTF8
}

# Function to back up a file before modifying it
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

# Create log directory if it doesn't exist
if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}

# Start logging
Log-Message "=== Starting WebSocket Connection Stability Fix ==="
Log-Message "Creating backup directory: $BACKUP_DIR"

# Back up critical files
$filesToBackup = @(
    "$WEB_UI_SERVICES_DIR\websocketService.js",
    "$WEB_UI_SERVICES_DIR\agentService.js",
    "$WEB_UI_COMPONENTS_DIR\RuslanAI.jsx"
)

foreach ($file in $filesToBackup) {
    Backup-File -FilePath $file
}

# Copy fixed files to their destinations
Log-Message "Copying fixed websocketService.js to web_ui services directory"
Copy-Item -Path "$SCRIPTS_DIR\fixed_websocket_service.js" -Destination "$WEB_UI_SERVICES_DIR\websocketService.js" -Force

Log-Message "Copying fixed agentService.js to web_ui services directory"
Copy-Item -Path "$SCRIPTS_DIR\fixed_agent_service.js" -Destination "$WEB_UI_SERVICES_DIR\agentService.js" -Force

# Update RuslanAI.jsx with the fix code
Log-Message "Updating RuslanAI.jsx component with WebSocket connection state handling"

# Read the RuslanAI.jsx file
$ruslanAIPath = "$WEB_UI_COMPONENTS_DIR\RuslanAI.jsx"
if (Test-Path $ruslanAIPath) {
    $ruslanAIContent = Get-Content -Path $ruslanAIPath -Raw -Encoding UTF8
    
    # Read the fix instructions
    $fixInstructionsPath = "$SCRIPTS_DIR\fixed_ruslanai_jsx.js"
    $fixInstructions = Get-Content -Path $fixInstructionsPath -Raw -Encoding UTF8
    
    # Apply changes to RuslanAI.jsx
    
    # 1. Add RefreshCw to icon imports
    $ruslanAIContent = $ruslanAIContent -replace 
        'import \{ Sun, Moon, MessageSquare, FileText, Archive, Users, BarChart2, Settings, ChevronDown, Upload, X, Play, Pause, AlertCircle, Check, Clock, Loader \} from "lucide-react";', 
        'import { Sun, Moon, MessageSquare, FileText, Archive, Users, BarChart2, Settings, ChevronDown, Upload, X, Play, Pause, AlertCircle, Check, Clock, Loader, RefreshCw } from "lucide-react";'
    
    # 2. Extract sections from the fix instructions
    $connectionStateEffectMatch = if ($fixInstructions -match '(?s)const connectionStateEffect = `(.+?)`;') { $matches[1] } else { "" }
    $improvedSendMessageHandlerMatch = if ($fixInstructions -match '(?s)const improvedSendMessageHandler = `(.+?)`;') { $matches[1] } else { "" }
    $reconnectButtonComponentMatch = if ($fixInstructions -match '(?s)const reconnectButtonComponent = `(.+?)`;') { $matches[1] } else { "" }
    $updatedMessageRenderMatch = if ($fixInstructions -match '(?s)const updatedMessageRender = `(.+?)`;') { $matches[1] } else { "" }
    
    # 3. Insert connection state effect after initial WebSocket effect
    if ($connectionStateEffectMatch -ne "") {
        $ruslanAIContent = $ruslanAIContent -replace 
            '(?s)(useEffect\(\) => \{.*?websocketService\.disconnect\(\);.*?\}\);)', 
            "`$1`n`n  $connectionStateEffectMatch"
    }
    
    # 4. Replace handleSendMessage function
    if ($improvedSendMessageHandlerMatch -ne "") {
        $ruslanAIContent = $ruslanAIContent -replace 
            '(?s)const handleSendMessage = async \(e\) => \{.*?(?=\n  \/\/ Handle Enter key in input field|\n  const handleKeyDown|\n  return \()', 
            "$improvedSendMessageHandlerMatch`n`n  "
    }
    
    # 5. Insert reconnect button component before return statement
    if ($reconnectButtonComponentMatch -ne "") {
        $ruslanAIContent = $ruslanAIContent -replace 
            '(?s)(return \()', 
            "$reconnectButtonComponentMatch`n`n  `$1"
    }
    
    # 6. Update message rendering for reconnection state
    if ($updatedMessageRenderMatch -ne "") {
        $ruslanAIContent = $ruslanAIContent -replace 
            '(?s)\{message\.isThinking \? \(.*?<span>\{message\.content\}</span>\n.*?\) : \(.*?<span>\{message\.content\}</span>\n.*?\)\}', 
            $updatedMessageRenderMatch
    }
    
    # 7. Add reconnect button to header
    $ruslanAIContent = $ruslanAIContent -replace 
        '<header className="flex justify-between items-center p-4 border-b">\s*<div className="flex items-center">\s*<h1 className="text-xl font-bold mr-4">RuslanAI</h1>\s*</div>\s*</header>', 
        '<header className="flex justify-between items-center p-4 border-b">
          <div className="flex items-center">
            <h1 className="text-xl font-bold mr-4">RuslanAI</h1>
          </div>
          <div className="flex items-center">
            {!websocketService.isConnected() && <ReconnectButton />}
          </div>
        </header>'
    
    # Save the updated file
    Set-Content -Path $ruslanAIPath -Value $ruslanAIContent -Encoding UTF8
    Log-Message "Updated RuslanAI.jsx with connection state handling and reconnection logic"
} else {
    Log-Message "ERROR: Could not find RuslanAI.jsx at $ruslanAIPath"
}

# Create a comprehensive summary of the changes made
$summaryPath = "$ROOT_DIR\WEBSOCKET_CONNECTION_FIX.md"
$summaryContent = @"
# WebSocket Connection Stability Fix

## Problem

WebSocket connections between the RuslanAI web interface and the API server were being closed prematurely, 
resulting in notifications not being delivered to the client. The specific error was:

```
Unexpected ASGI message 'websocket.send', after sending 'websocket.close' or response already completed.
```

This occurred when the server tried to send task notifications to a client that had disconnected.

## Solution

The following improvements were made to enhance WebSocket connection stability:

1. **Enhanced WebSocket Service**:
   - Added message queuing for offline/disconnected periods
   - Implemented keep-alive mechanism with ping/pong messages
   - Added exponential backoff for reconnection attempts
   - Added connection state monitoring and notification system
   - Improved error handling and reconnection logic
   - Added tracking of in-progress tasks

2. **Updated RuslanAI Component**:
   - Added connection state monitoring
   - Improved message sending with connection awareness
   - Added reconnection UI elements for better user experience
   - Enhanced error handling for network issues
   - Added visual indicators for reconnection attempts

3. **Enhanced Agent Service**:
   - Added retry logic for API calls
   - Added timeout handling for requests
   - Improved error handling with specific error types
   - Added WebSocket connection verification before sending messages

## Files Modified

- `/web_ui/src/services/websocketService.js`
- `/web_ui/src/services/agentService.js`
- `/web_ui/src/components/RuslanAI.jsx`

## Backup Location

Backups of the original files are stored in:
$BACKUP_DIR

## Technical Details

### New WebSocket Features

1. **Message Queuing**:
   - Messages sent while disconnected are stored in a queue
   - Queue is processed when connection is restored
   - Queue has size limit to prevent memory issues
   - Old messages are dropped after a configurable time period

2. **Connection State Management**:
   - New connection states: 'connecting', 'connected', 'disconnected', 'error', 'offline'
   - Connection state changes trigger UI updates
   - Connection health check runs periodically

3. **Keep-Alive Mechanism**:
   - Sends ping messages every 30 seconds
   - Server responds with pong messages
   - Detects and handles silent disconnects

4. **Task Tracking**:
   - Tracks task IDs that are awaiting completion
   - Ensures notifications are properly displayed even after reconnection

## Testing

After applying these changes, the WebSocket connections should remain stable,
and notifications should be delivered properly even after periods of disconnection.

If you encounter any issues, check the logs at:
$LOGS_DIR\websocket_fix.log
$LOGS_DIR\api_server.log
"@

Set-Content -Path $summaryPath -Value $summaryContent -Encoding UTF8
Log-Message "Created summary file at $summaryPath"

# Create a shortcut to run the system with the fixed WebSocket handling
$WshShell = New-Object -ComObject WScript.Shell
$shortcutPath = "$ROOT_DIR\Run_RuslanAI_Stable.lnk"
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$ROOT_DIR\start_ruslanai_updated.ps1`""
$shortcut.WorkingDirectory = $ROOT_DIR
$shortcut.IconLocation = "shell32.dll,22"
$shortcut.Description = "Run RuslanAI with Enhanced WebSocket Stability"
$shortcut.Save()
Log-Message "Created desktop shortcut at $shortcutPath"

# Complete
Log-Message "WebSocket Connection Stability Fix completed successfully!"
Log-Message "Please restart the web UI and API server to apply the changes."
Log-Message "================================="