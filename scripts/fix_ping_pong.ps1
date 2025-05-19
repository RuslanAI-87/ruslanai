# Fix Ping/Pong Script
# This script adds ping/pong handling to the API server

Write-Host "Fix Ping/Pong Script" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green
Write-Host "This script will add ping/pong handling to the API server WebSocket endpoint."
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
Write-Host "Running ping/pong fix script..." -ForegroundColor Yellow
Write-Host ""

try {
    # Change to the scripts directory
    cd "C:\RuslanAI\scripts"
    
    # Run the Python script
    python add_ping_pong.py
    
    # Check if the script ran successfully
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Ping/pong fix script completed successfully!" -ForegroundColor Green
        Write-Host "The API server now has ping/pong handling." -ForegroundColor Green
        Write-Host ""
        Write-Host "To start the API server, run:" -ForegroundColor Cyan
        Write-Host "cd C:\RuslanAI\central_agent\backend" -ForegroundColor Cyan
        Write-Host "python encoding_fixed_api.py" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "If the direct modification failed, a standalone ping/pong server" -ForegroundColor Yellow
        Write-Host "was created. You can run it using:" -ForegroundColor Yellow
        Write-Host "C:\RuslanAI\scripts\run_ping_pong_server.bat" -ForegroundColor Cyan
    } else {
        Write-Host "Ping/pong fix script failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error running ping/pong fix script: $_" -ForegroundColor Red
    exit 1
}