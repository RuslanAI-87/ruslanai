# RuslanAI Full System Startup Script
# This script starts both the API server and Web UI for RuslanAI

Write-Host "RuslanAI Full System Startup Script" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "This script will start both the API server and Web UI for RuslanAI."
Write-Host ""

# Helper function to start a process
function Start-ProcessAsync {
    param (
        [string]$WorkingDirectory,
        [string]$ScriptPath,
        [string]$WindowTitle
    )
    
    $PowerShellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $Arguments = "-NoExit -File `"$ScriptPath`""
    
    Start-Process -FilePath $PowerShellPath -ArgumentList $Arguments -WorkingDirectory $WorkingDirectory
}

# Check if the scripts exist
if (-Not (Test-Path "C:\RuslanAI\scripts\start_api_server.ps1")) {
    Write-Host "Error: API server startup script not found." -ForegroundColor Red
    exit 1
}

if (-Not (Test-Path "C:\RuslanAI\scripts\start_web_ui.ps1")) {
    Write-Host "Error: Web UI startup script not found." -ForegroundColor Red
    exit 1
}

# Start the API server in a new window
Write-Host "Starting API server in a new window..." -ForegroundColor Cyan
Start-ProcessAsync -WorkingDirectory "C:\RuslanAI\scripts" -ScriptPath "C:\RuslanAI\scripts\start_api_server.ps1" -WindowTitle "RuslanAI API Server"

# Wait a moment for the API server to start
Write-Host "Waiting for API server to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start the Web UI in a new window
Write-Host "Starting Web UI in a new window..." -ForegroundColor Cyan
Start-ProcessAsync -WorkingDirectory "C:\RuslanAI\scripts" -ScriptPath "C:\RuslanAI\scripts\start_web_ui.ps1" -WindowTitle "RuslanAI Web UI"

Write-Host ""
Write-Host "Both components have been started!" -ForegroundColor Green
Write-Host "API Server URL: http://localhost:8001" -ForegroundColor Cyan
Write-Host "Web UI URL: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Close this window when you want to stop all components." -ForegroundColor Yellow