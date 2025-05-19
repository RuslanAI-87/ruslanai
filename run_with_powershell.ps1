# PowerShell script to run WebSocket server with error capture
$ErrorActionPreference = "Continue"

# Log file paths
$logPath = Join-Path $PSScriptRoot "websocket_ps_log.txt"
$errorLogPath = Join-Path $PSScriptRoot "websocket_error.txt"

# Redirect output to log file
Start-Transcript -Path $logPath -Force

try {
    Write-Host "Starting diagnostic process..."
    Write-Host "Current directory: $PWD"
    
    # Check Node.js
    Write-Host "Checking Node.js..."
    try {
        $nodeVersion = & node --version
        Write-Host "Node.js version: $nodeVersion"
    } catch {
        Write-Host "Error checking Node.js: $_" -ForegroundColor Red
        # Try to locate node.js
        try {
            $nodePath = & where.exe node
            Write-Host "Node.js path: $nodePath"
        } catch {
            Write-Host "Cannot find Node.js in PATH" -ForegroundColor Red
        }
    }
    
    # Navigate to scripts directory
    $scriptsDir = Join-Path $PSScriptRoot "scripts"
    Set-Location $scriptsDir
    Write-Host "Changed directory to: $PWD"
    
    # Install dependencies
    Write-Host "Installing dependencies..."
    & npm install ws uuid
    
    # Start the server
    Write-Host "Starting WebSocket server..."
    & node minimal_websocket.js
    
    Write-Host "Server execution completed with exit code $LASTEXITCODE"
} catch {
    Write-Host "Unhandled exception: $_" -ForegroundColor Red
    $_ | Out-File $errorLogPath -Append
}

Stop-Transcript

Write-Host "Script completed. Check the log files for details:"
Write-Host "Log: $logPath"
Write-Host "Error log: $errorLogPath"

# Keep window open
Read-Host "Press Enter to exit"