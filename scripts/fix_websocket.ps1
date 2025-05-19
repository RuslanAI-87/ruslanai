# Fix WebSocket Script
# This script updates the WebSocket service to add ping/pong and reconnection logic

Write-Host "Fix WebSocket Script" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green
Write-Host "This script will add ping/pong and reconnection logic to the WebSocket service."
Write-Host ""

# Check for Python
try {
    $pythonVersion = python --version
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python not found. Please install Python and try again." -ForegroundColor Red
    exit 1
}

# Run the Python fix script
Write-Host ""
Write-Host "Running WebSocket fix script..." -ForegroundColor Yellow
Write-Host ""

try {
    # Change to the scripts directory
    cd "C:\RuslanAI\scripts"
    
    # Run the Python script
    python simple_websocket_fix.py
    
    # Check if the script ran successfully
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "WebSocket fix script completed successfully!" -ForegroundColor Green
        Write-Host "The WebSocket service now has ping/pong and reconnection logic." -ForegroundColor Green
        Write-Host ""
        Write-Host "To start the web UI, run:" -ForegroundColor Cyan
        Write-Host "cd C:\RuslanAI\web_ui" -ForegroundColor Cyan
        Write-Host "npm run dev" -ForegroundColor Cyan
    } else {
        Write-Host "WebSocket fix script failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error running WebSocket fix script: $_" -ForegroundColor Red
    exit 1
}