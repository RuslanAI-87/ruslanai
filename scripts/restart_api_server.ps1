# PowerShell script to apply ConnectionManager fix and restart the API server
# This script fixes the premature WebSocket connection closing issue

# Set UTF-8 encoding
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Define paths
$ROOT_DIR = "C:\RuslanAI"
$SCRIPTS_DIR = "$ROOT_DIR\scripts"
$LOGS_DIR = "$ROOT_DIR\logs"

# Create logs directory if it doesn't exist
if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}

# Log file
$LOG_FILE = "$LOGS_DIR\restart_api_server.log"

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

# Start logging
Log-Message "=== Starting API Server Fix and Restart ==="

# Step 1: Apply Connection Manager Fix
Log-Message "Applying ConnectionManager fix..."
try {
    # Run the Python script to fix the ConnectionManager
    & python "$SCRIPTS_DIR\fix_connection_manager.py"
    if ($LASTEXITCODE -ne 0) {
        Log-Message "Error: Connection Manager fix script failed with exit code $LASTEXITCODE"
        Exit 1
    }
    Log-Message "ConnectionManager fix applied successfully"
} catch {
    Log-Message "Error applying ConnectionManager fix: $_"
    Exit 1
}

# Step 2: Stop existing API server process
Log-Message "Stopping existing API server process..."
try {
    $apiProcesses = Get-Process -Name python -ErrorAction SilentlyContinue | 
                    Where-Object { $_.CommandLine -like "*encoding_fixed_api*" }
    
    if ($apiProcesses) {
        foreach ($process in $apiProcesses) {
            Stop-Process -Id $process.Id -Force
            Log-Message "Stopped API server process with PID: $($process.Id)"
        }
    } else {
        Log-Message "No running API server processes found"
    }
    
    # Wait a moment for processes to terminate
    Start-Sleep -Seconds 2
} catch {
    Log-Message "Error stopping API server processes: $_"
    # Continue anyway as we'll try to start a new instance
}

# Step 3: Start the API server with the fixes
Log-Message "Starting API server with fixed ConnectionManager..."
try {
    $apiProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $ROOT_DIR && python -m central_agent.backend.encoding_fixed_api" -WindowStyle Normal -PassThru
    Log-Message "API server started with PID: $($apiProcess.Id)"
    
    # Wait a moment for the API server to initialize
    Start-Sleep -Seconds 5
    
    # Check if the process is still running
    $isRunning = Get-Process -Id $apiProcess.Id -ErrorAction SilentlyContinue
    if ($isRunning) {
        Log-Message "API server is running with PID: $($apiProcess.Id)"
    } else {
        Log-Message "Error: API server process terminated unexpectedly"
        Exit 1
    }
} catch {
    Log-Message "Error starting API server: $_"
    Exit 1
}

# Create documentation file
$DOCS_FILE = "$ROOT_DIR\API_SERVER_FIX.md"
$docsContent = @"
# API Server WebSocket Fix

## Problem

The WebSocket connections in the RuslanAI system were being closed prematurely, causing notifications to fail with the error:

```
Unexpected ASGI message 'websocket.send', after sending 'websocket.close' or response already completed.
```

This happened when the server tried to send task notifications to clients that had disconnected.

## Solution

The following improvements were made to the API server's connection handling:

1. **Enhanced ConnectionManager**:
   - Added message buffering for disconnected clients
   - Improved connection state tracking
   - Added robust error handling for connection issues
   - Added verification of connection state before sending messages

2. **Improved WebSocket Endpoint**:
   - Added better exception handling
   - Added reconnection support
   - Added ping/pong message handling
   - Enhanced connection state management

3. **Updated Task Processing**:
   - Added notification status tracking
   - Improved error handling for notification failures
   - Added message buffering for offline clients

## Technical Details

### Message Buffering

When a client disconnects, messages intended for that client are now stored in a buffer.
When the client reconnects, these buffered messages are sent automatically.

### Connection State Tracking

The ConnectionManager now tracks the state of all connections and provides methods to check
if a client is connected before attempting to send messages.

### Reconnection Support

The WebSocket endpoint now has explicit handling for client reconnections, allowing clients
to recover from temporary disconnections.

## Testing

To verify the fix:
1. Open the RuslanAI web interface
2. Send a message in the chat
3. The response should appear even if there was a temporary connection issue
4. Check the browser console for WebSocket messages

## Logs

Check the following log files for details:
- $LOGS_DIR\api_server.log
- $LOGS_DIR\connection_manager_fix.log
- $LOGS_DIR\restart_api_server.log

## Troubleshooting

If issues persist:
1. Restart both the API server and web UI
2. Check that the ping messages are being sent every 30 seconds
3. Verify that the API server is responding to ping messages with pong messages
4. Check that the WebSocket connection remains open during the entire request-response cycle
"@

Set-Content -Path $DOCS_FILE -Value $docsContent -Encoding UTF8
Log-Message "Created documentation file at $DOCS_FILE"

# Complete
Log-Message "API Server has been restarted with the ConnectionManager fix"
Log-Message "WebSocket connections should now remain stable"
Log-Message "Please refresh the web UI to establish a new WebSocket connection"
Log-Message "================================="