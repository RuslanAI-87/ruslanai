# RuslanAI Web UI Startup Script
# This script starts the web UI for RuslanAI

Write-Host "RuslanAI Web UI Startup Script" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host "This script will start the web UI for RuslanAI."
Write-Host ""

# Change to the web UI directory
try {
    cd "C:\RuslanAI\web_ui"
    
    # Check if the necessary files exist
    if (-Not (Test-Path ".\src\App.jsx")) {
        Write-Host "Error: Required files not found in web_ui directory." -ForegroundColor Red
        Write-Host "Make sure you have run the fix script first." -ForegroundColor Yellow
        exit 1
    }
    
    # Start the web UI
    Write-Host "Starting web UI..." -ForegroundColor Cyan
    npm run dev
} catch {
    Write-Host "Error starting web UI: $_" -ForegroundColor Red
    exit 1
}