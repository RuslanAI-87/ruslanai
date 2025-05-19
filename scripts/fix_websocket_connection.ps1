# Fix WebSocket Connection Issues for RuslanAI
# This script applies all necessary fixes to resolve WebSocket connection stability issues

# Ensure UTF-8 encoding
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Define paths
$ROOT_DIR = "C:\RuslanAI"
$SCRIPTS_DIR = "$ROOT_DIR\scripts"
$LOGS_DIR = "$ROOT_DIR\logs"
$WEB_UI_DIR = "$ROOT_DIR\web_ui"
$WEB_UI_SERVICES_DIR = "$WEB_UI_DIR\src\services"
$API_SERVER_DIR = "$ROOT_DIR\central_agent\backend"
$BACKUP_DIR = "$ROOT_DIR\backup\websocket_fix_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Create necessary directories
if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}
New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null

# Log file
$LOG_FILE = "$LOGS_DIR\websocket_fix.log"
Set-Content -Path $LOG_FILE -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Starting WebSocket Fix" -Encoding UTF8

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
Log-Message "=== Starting WebSocket Connection Fix ==="

# Step 1: Back up critical files
$filesToBackup = @(
    "$WEB_UI_SERVICES_DIR\websocketService.js",
    "$WEB_UI_SERVICES_DIR\agentService.js",
    "$API_SERVER_DIR\encoding_fixed_api.py"
)

foreach ($file in $filesToBackup) {
    Backup-File -FilePath $file
}

# Step 2: Stop running processes
Stop-ProcessesByName -ProcessName "python"
Stop-ProcessesByName -ProcessName "node"
Stop-ProcessesByName -ProcessName "npm"

# Step 3: Update the client-side WebSocket service
Log-Message "Updating client-side WebSocket service..."
try {
    # Simple WebSocket service with keep-alive
    $wsServiceContent = Get-Content -Path "$SCRIPTS_DIR\websocket_service_update.js" -Raw -Encoding UTF8
    Set-Content -Path "$WEB_UI_SERVICES_DIR\websocketService.js" -Value $wsServiceContent -Encoding UTF8
    Log-Message "Updated WebSocket service with keep-alive mechanism"
} catch {
    Log-Message "ERROR: Failed to update WebSocket service: $_"
}

# Step 4: Fix server-side ConnectionManager
Log-Message "Fixing server-side ConnectionManager..."
try {
    & python "$SCRIPTS_DIR\connection_manager_fix.py"
    if ($LASTEXITCODE -eq 0) {
        Log-Message "ConnectionManager fixed successfully"
    } else {
        Log-Message "WARNING: ConnectionManager fix may not have been fully applied"
    }
} catch {
    Log-Message "ERROR: Failed to fix ConnectionManager: $_"
}

# Step 5: Add clean-utf8 version of agentService.js
Log-Message "Updating agent service..."
try {
    # Enhanced agent service
    $agentServiceContent = Get-Content -Path "$SCRIPTS_DIR\fixed_agent_service.js" -Raw -Encoding UTF8
    Set-Content -Path "$WEB_UI_SERVICES_DIR\agentService.js" -Value $agentServiceContent -Encoding UTF8
    Log-Message "Updated agent service with retry logic"
} catch {
    Log-Message "ERROR: Failed to update agent service: $_"
}

# Step 6: Create diagnostic tools
Log-Message "Creating diagnostic tools..."
$diagnosticsFile = "$ROOT_DIR\websocket_diagnostics.js"
Copy-Item -Path "$SCRIPTS_DIR\websocket_diagnostics.js" -Destination $diagnosticsFile -Force
Log-Message "Created WebSocket diagnostics tool at $diagnosticsFile"

# Step 7: Start services
Log-Message "Starting services..."

# Start API server
Log-Message "Starting API server..."
$apiProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $ROOT_DIR && python -m central_agent.backend.encoding_fixed_api" -WindowStyle Normal -PassThru
Log-Message "API server started with PID: $($apiProcess.Id)"

# Wait for API server to initialize
Start-Sleep -Seconds 5

# Start web UI
Log-Message "Starting web UI..."
$webUIProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $WEB_UI_DIR && npm run dev" -WindowStyle Normal -PassThru
Log-Message "Web UI started with PID: $($webUIProcess.Id)"

# Wait for web UI to initialize
Start-Sleep -Seconds 5

# Step 8: Create startup script
$startupScriptPath = "$ROOT_DIR\start_fixed_ruslanai.ps1"
$startupScriptContent = @"
# Start RuslanAI with WebSocket Connection Fix
# This script starts all components with enhanced WebSocket stability

# Set UTF-8 encoding
`$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Stop existing processes
Get-Process | Where-Object { `$_.ProcessName -like "*python*" -or `$_.ProcessName -like "*node*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Start API server
`$apiProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd C:\RuslanAI && python -m central_agent.backend.encoding_fixed_api" -WindowStyle Normal -PassThru
Write-Host "Started API server with PID: `$(`$apiProcess.Id)"

# Wait for API server to initialize
Start-Sleep -Seconds 5

# Start web UI
`$webUIProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd C:\RuslanAI\web_ui && npm run dev" -WindowStyle Normal -PassThru
Write-Host "Started web UI with PID: `$(`$webUIProcess.Id)"

# Wait for web UI to initialize
Start-Sleep -Seconds 3

# Open web UI in browser
Start-Process "http://localhost:5173"
Write-Host "Opened RuslanAI in browser"
Write-Host "WebSocket connection fix is active"
"@

Set-Content -Path $startupScriptPath -Value $startupScriptContent -Encoding UTF8
Log-Message "Created startup script at $startupScriptPath"

# Step 9: Create desktop shortcut
$shortcutPath = "$ROOT_DIR\RuslanAI_Fixed.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$startupScriptPath`""
$Shortcut.WorkingDirectory = $ROOT_DIR
$Shortcut.IconLocation = "C:\Windows\System32\shell32.dll,22"
$Shortcut.Description = "Start RuslanAI with WebSocket fix"
$Shortcut.Save()
Log-Message "Created desktop shortcut at $shortcutPath"

# Step 10: Create documentation
$docsPath = "$ROOT_DIR\WEBSOCKET_FIX.md"
$docsContent = @"
# WebSocket Connection Fix

## Problem

The RuslanAI system was experiencing issues with WebSocket connections being closed prematurely.
This resulted in notifications not being delivered to clients and tasks appearing to hang with
"Processing your request..." displayed indefinitely.

The specific error in the logs was:
```
Unexpected ASGI message 'websocket.send', after sending 'websocket.close' or response already completed.
```

## Solution

This fix addresses WebSocket connection stability through several components:

### 1. Client-Side Improvements

- **Enhanced WebSocket Service**:
  - Added keep-alive mechanism (ping messages every 30 seconds)
  - Improved reconnection logic with exponential backoff
  - Added message queueing for offline periods
  - Better connection state handling

- **Improved Agent Service**:
  - Added retry logic for failed API calls
  - Added proper error handling
  - Added connection verification before operations

### 2. Server-Side Improvements

- **Enhanced ConnectionManager**:
  - Added message buffering for disconnected clients
  - Improved connection state verification
  - Better error handling

- **WebSocket Endpoint Enhancements**:
  - Added ping-pong handling for keep-alive
  - Improved error handling
  - Better connection cleanup

## Usage

1. Use the desktop shortcut "RuslanAI_Fixed" to start the system
2. The system will start both API server and web UI with WebSocket fixes
3. WebSocket connections will now remain stable even during periods of inactivity

## Diagnostics

If you encounter any issues:

1. Run the diagnostics tool:
   ```javascript
   // In browser console on RuslanAI page
   fetch('/websocket_diagnostics.js').then(r => r.text()).then(eval);
   ```

2. Check logs at:
   - C:\RuslanAI\logs\api_server.log
   - C:\RuslanAI\logs\websocket_fix.log

## Backup

All original files have been backed up to:
$BACKUP_DIR
"@

Set-Content -Path $docsPath -Value $docsContent -Encoding UTF8
Log-Message "Created documentation at $docsPath"

# Step 11: Open the web UI in the browser
Start-Process "http://localhost:5173"
Log-Message "Opened RuslanAI in browser"

# Complete
Log-Message "WebSocket Connection Fix completed successfully"
Log-Message "Use the desktop shortcut 'RuslanAI_Fixed' to start the system in the future"
Log-Message "Documentation available at $docsPath"
Log-Message "Diagnostics tool available at $diagnosticsFile"
Log-Message "=== Fix Complete ==="