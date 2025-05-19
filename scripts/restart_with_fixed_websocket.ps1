# Restart RuslanAI with the fixed WebSocket connection handling
# This script applies WebSocket stability fixes and restarts the system

# Set UTF-8 encoding to avoid issues with Cyrillic characters
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Define paths
$ROOT_DIR = "C:\RuslanAI"
$SCRIPTS_DIR = "$ROOT_DIR\scripts"
$LOGS_DIR = "$ROOT_DIR\logs"

# Ensure logs directory exists
if (-not (Test-Path $LOGS_DIR)) {
    New-Item -ItemType Directory -Path $LOGS_DIR -Force | Out-Null
}

# Initialize log file
$LOG_FILE = "$LOGS_DIR\restart_fixed_system.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Set-Content -Path $LOG_FILE -Value "[$timestamp] Starting RuslanAI with WebSocket stability fix" -Encoding UTF8

# Function to log messages with timestamps
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

# Function to stop processes by name
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
}

# Apply WebSocket stability fix
Log-Message "Applying WebSocket stability fix..."
try {
    # Run the fix script
    & "$SCRIPTS_DIR\update_websocket_stability.ps1"
    Log-Message "WebSocket stability fix applied successfully"
} catch {
    Log-Message "Error applying WebSocket stability fix: $_"
    Log-Message "Continuing with restart..."
}

# Stop existing processes
Stop-ProcessesByName "node"
Stop-ProcessesByName "python"
Stop-ProcessesByName "cmd"

# Wait a moment for processes to fully terminate
Start-Sleep -Seconds 2

# Start the API server
Log-Message "Starting API server..."
$apiServerProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $ROOT_DIR && python -m central_agent.backend.encoding_fixed_api" -WindowStyle Normal -PassThru
Log-Message "API server started with PID: $($apiServerProcess.Id)"

# Wait for API server to initialize
Log-Message "Waiting for API server to initialize..."
Start-Sleep -Seconds 5

# Start the web UI
Log-Message "Starting web UI..."
$webUIProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd $ROOT_DIR\web_ui && npm run dev" -WindowStyle Normal -PassThru
Log-Message "Web UI started with PID: $($webUIProcess.Id)"

# Wait for web UI to start
Start-Sleep -Seconds 3

# Open the web UI in the default browser
Log-Message "Opening RuslanAI in default browser..."
Start-Process "http://localhost:5173"

# Display success message
Log-Message "RuslanAI system successfully started with WebSocket stability fix"
Log-Message "Web UI: http://localhost:5173"
Log-Message "API Server: http://localhost:8001"
Log-Message ""
Log-Message "To test WebSocket stability:"
Log-Message "1. Open browser developer tools (F12)"
Log-Message "2. Go to the Network tab and filter for WS (WebSocket)"
Log-Message "3. Enter a message in the chat and check for proper message handling"
Log-Message "4. Observe ping messages being sent every 30 seconds"
Log-Message ""
Log-Message "WebSocket stability fix documentation: $ROOT_DIR\WEBSOCKET_CONNECTION_FIX.md"