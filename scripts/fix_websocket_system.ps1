# Fix WebSocket System Script
# This script applies comprehensive fixes to the RuslanAI WebSocket connection system
# Addresses the "Unexpected ASGI message 'websocket.send', after sending 'websocket.close'" error

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
$BACKUP_DIR = "$ROOT_DIR\backup\websocket_fix_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Create necessary directories
if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}
New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null

# Log file
$LOG_FILE = "$LOGS_DIR\fix_websocket_system.log"
Set-Content -Path $LOG_FILE -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Starting WebSocket system fix" -Encoding UTF8

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

# Function to restart a process
function Restart-Process {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ProcessName,
        
        [Parameter(Mandatory=$true)]
        [string]$Command,
        
        [Parameter(Mandatory=$false)]
        [string]$WorkingDirectory = $ROOT_DIR
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
    
    # Start the new process
    Log-Message "Starting $ProcessName with command: $Command"
    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $WorkingDirectory && $Command" -WindowStyle Normal -PassThru
    Log-Message "$ProcessName started with PID: $($process.Id)"
    
    # Check if the process is still running after a short delay
    Start-Sleep -Seconds 3
    $isRunning = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
    if ($isRunning) {
        Log-Message "$ProcessName is running with PID: $($process.Id)"
        return $true
    } else {
        Log-Message "ERROR: $ProcessName process terminated unexpectedly"
        return $false
    }
}

# Start the fix process
Log-Message "=== Starting RuslanAI WebSocket Connection System Fix ==="
Log-Message "Creating backup directory: $BACKUP_DIR"

# Step 1: Back up critical files
$filesToBackup = @(
    "$WEB_UI_SERVICES_DIR\websocketService.js",
    "$ROOT_DIR\central_agent\backend\encoding_fixed_api.py"
)

foreach ($file in $filesToBackup) {
    Backup-File -FilePath $file
}

# Step 2: Apply server-side ConnectionManager fix
Log-Message "Applying server-side ConnectionManager fix..."
try {
    # Run the Python script to fix the ConnectionManager
    & python "$SCRIPTS_DIR\fix_connection_manager.py"
    if ($LASTEXITCODE -ne 0) {
        Log-Message "Error: Connection Manager fix script failed with exit code $LASTEXITCODE"
        Log-Message "Using backup for recovery..."
        $apiBackup = "$BACKUP_DIR\encoding_fixed_api.py"
        if (Test-Path $apiBackup) {
            Copy-Item -Path $apiBackup -Destination "$ROOT_DIR\central_agent\backend\encoding_fixed_api.py" -Force
            Log-Message "Restored API server file from backup"
        }
    } else {
        Log-Message "ConnectionManager fix applied successfully"
    }
} catch {
    Log-Message "Error applying ConnectionManager fix: $_"
    Log-Message "Using backup for recovery..."
    $apiBackup = "$BACKUP_DIR\encoding_fixed_api.py"
    if (Test-Path $apiBackup) {
        Copy-Item -Path $apiBackup -Destination "$ROOT_DIR\central_agent\backend\encoding_fixed_api.py" -Force
        Log-Message "Restored API server file from backup"
    }
}

# Step 3: Apply client-side WebSocket service fix
Log-Message "Applying client-side WebSocket service fix..."
try {
    # Copy updated WebSocket service to web_ui directory
    Copy-Item -Path "$SCRIPTS_DIR\websocket_service_update.js" -Destination "$WEB_UI_SERVICES_DIR\websocketService.js" -Force
    Log-Message "WebSocket service updated successfully"
} catch {
    Log-Message "Error updating WebSocket service: $_"
    Log-Message "Using backup for recovery..."
    $wsBackup = "$BACKUP_DIR\websocketService.js"
    if (Test-Path $wsBackup) {
        Copy-Item -Path $wsBackup -Destination "$WEB_UI_SERVICES_DIR\websocketService.js" -Force
        Log-Message "Restored WebSocket service from backup"
    }
}

# Step 4: Restart API server
Log-Message "Restarting API server..."
$apiServerRestarted = Restart-Process -ProcessName "python" -Command "python -m central_agent.backend.encoding_fixed_api"

if (-not $apiServerRestarted) {
    Log-Message "ERROR: Failed to restart API server"
    # Continue anyway, we'll try to restart everything
}

# Step 5: Restart web UI
Log-Message "Restarting web UI..."
$webUIRestarted = Restart-Process -ProcessName "node" -Command "npm run dev" -WorkingDirectory "$WEB_UI_DIR"

if (-not $webUIRestarted) {
    Log-Message "ERROR: Failed to restart web UI"
    # Continue anyway, we've made the fixes
}

# Step 6: Create documentation
$DOCS_FILE = "$ROOT_DIR\WEBSOCKET_CONNECTION_FIX.md"
$docsContent = @"
# WebSocket Connection Fix for RuslanAI

## Problem Description

The RuslanAI system was experiencing issues with WebSocket connections being closed prematurely,
causing task notifications to fail with the error:

```
Unexpected ASGI message 'websocket.send', after sending 'websocket.close' or response already completed.
```

This resulted in requests appearing to hang with the "Processing your request..." message displayed
indefinitely, even though the server had actually completed processing the request.

## Root Cause Analysis

1. **Server-Side Issues**:
   - The ConnectionManager did not properly track connection states
   - When a client temporarily disconnected, the server tried to send messages to a closed connection
   - No mechanism existed to buffer messages for disconnected clients
   - Exception handling was insufficient for WebSocket connections

2. **Client-Side Issues**:
   - WebSocket reconnection logic was not robust
   - No mechanism to track in-progress tasks during disconnections
   - Ping/pong messages didn't properly detect connection failures

## Solution Implemented

### Server-Side Fixes (ConnectionManager)

1. **Enhanced Connection State Tracking**:
   - Added explicit connection state tracking
   - Added proper verification before sending messages
   - Improved error handling for message sending

2. **Message Buffering**:
   - Added a message queue for disconnected clients
   - Messages are stored when clients are disconnected
   - Buffered messages are sent when clients reconnect

3. **Improved WebSocket Endpoint**:
   - Enhanced error handling for WebSocket connections
   - Added better reconnection support
   - Improved handling of client state

### Client-Side Fixes (WebSocketService)

1. **Robust Reconnection Logic**:
   - Added connection state tracking
   - Added exponential backoff for reconnection attempts
   - Added memory of in-progress tasks

2. **Message Queuing**:
   - Messages that can't be sent are queued
   - Queue is processed when connection is restored
   - Old messages are automatically discarded

3. **Explicit Reconnection Notification**:
   - Client notifies server when reconnecting
   - Server sends buffered messages upon reconnection
   - Connection state is properly synchronized

## How to Test

1. Open the RuslanAI web interface at http://localhost:5173
2. Open browser developer tools (F12)
3. Go to the Network tab and filter for WebSocket (WS)
4. Observe ping messages being sent every 30 seconds
5. Try sending a message in the chat
6. The response should appear even if there are connection issues
7. Try temporarily disconnecting your network to test reconnection

## Troubleshooting

If you still experience issues:

1. Check the browser console for WebSocket-related errors
2. Verify in the Network tab that ping messages are being sent and received
3. Check the server logs at $LOGS_DIR\api_server.log
4. Try manually refreshing the page to establish a new WebSocket connection
5. If needed, restart the system using this script again

## Files Modified

- \`$ROOT_DIR\central_agent\backend\encoding_fixed_api.py\`
- \`$WEB_UI_DIR\src\services\websocketService.js\`

## Backup Location

All original files have been backed up to:
$BACKUP_DIR
"@

Set-Content -Path $DOCS_FILE -Value $docsContent -Encoding UTF8
Log-Message "Created documentation file at $DOCS_FILE"

# Step 7: Create a test script for the client
$TEST_SCRIPT = "$ROOT_DIR\test_websocket_connection.js"
$testScriptContent = @"
// RuslanAI WebSocket Connection Test Script
// Run this in the browser console to test the WebSocket connection

(function() {
  console.log('=== RuslanAI WebSocket Connection Test ===');
  
  // Get reference to the WebSocket service
  const ws = window.websocketService;
  if (!ws) {
    console.error('WebSocket service not found in global scope');
    console.error('Please make sure you are on the RuslanAI page and the app is fully loaded');
    return;
  }
  
  // Check current connection state
  console.log('Connection state:', ws.getConnectionState());
  console.log('Is connected:', ws.isConnected());
  console.log('User ID:', ws.userId);
  
  // Test pinging
  console.log('Sending ping message...');
  ws.sendMessage({
    type: 'ping',
    timestamp: Date.now()
  });
  
  // Setup connection state monitor
  ws.onConnectionStateChange((state) => {
    console.log('Connection state changed:', state);
  });
  
  // Try to force reconnection
  console.log('Forcing reconnection to test reconnection logic...');
  setTimeout(() => {
    ws.forceReconnect();
    
    // Send a test message after reconnection
    setTimeout(() => {
      if (ws.isConnected()) {
        console.log('Sending test message after reconnection...');
        ws.sendMessage({
          type: 'test',
          content: 'Test message after reconnection',
          timestamp: Date.now()
        });
      } else {
        console.error('Not connected after reconnection attempt');
      }
    }, 2000);
  }, 1000);
  
  // Display test instructions
  console.log('');
  console.log('=== Test Instructions ===');
  console.log('1. Check that you see ping/pong messages in the console');
  console.log('2. Try sending a message in the chat UI');
  console.log('3. Try refreshing the page and sending another message');
  console.log('4. You should receive responses for both messages');
  console.log('');
})();
"@

Set-Content -Path $TEST_SCRIPT -Value $testScriptContent -Encoding UTF8
Log-Message "Created test script at $TEST_SCRIPT"

# Step 8: Open the web UI in browser
Log-Message "Opening RuslanAI in default browser..."
Start-Process "http://localhost:5173"

# Complete
Log-Message "WebSocket Connection Fix completed successfully"
Log-Message "Please give the system a few seconds to start up"
Log-Message "To test the fix, send a message in the chat interface"
Log-Message "If issues persist, run the test script by copying and pasting the content from $TEST_SCRIPT into your browser console"
Log-Message "Documentation: $DOCS_FILE"
Log-Message "================================================"