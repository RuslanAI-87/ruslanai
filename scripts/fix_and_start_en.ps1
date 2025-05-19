# RuslanAI Fix and Start Script
# This script runs the Python fix script and sets up the environment

Write-Host "RuslanAI Fix and Start Script" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host "This script will fix React import issues and WebSocket connection problems,"
Write-Host "then start the API server and web UI."
Write-Host ""

# Create logs directory if it doesn't exist
if (-Not (Test-Path "C:\RuslanAI\logs")) {
    Write-Host "Creating logs directory..." -ForegroundColor Yellow
    New-Item -Path "C:\RuslanAI\logs" -ItemType Directory -Force | Out-Null
}

# Check for Python
try {
    $pythonVersion = python --version
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python not found. Please install Python and try again." -ForegroundColor Red
    exit 1
}

# Check for Node.js and npm
try {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "Found Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "Found npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "Node.js or npm not found. Please install Node.js and try again." -ForegroundColor Red
    exit 1
}

# Run the Python fix script
Write-Host ""
Write-Host "Running fix and start script..." -ForegroundColor Yellow
Write-Host ""

try {
    # Change to the scripts directory
    cd "C:\RuslanAI\scripts"
    
    # Run the Python script (using the English version)
    python fix_and_start_ruslanai_en.py
    
    # Check if the script ran successfully
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "RuslanAI fix and start script completed successfully!" -ForegroundColor Green
        Write-Host "The API server and web UI should now be running." -ForegroundColor Green
        Write-Host ""
        Write-Host "WebUI URL: http://localhost:5173" -ForegroundColor Cyan
        Write-Host "API URL: http://localhost:8001" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Press Ctrl+C to stop the servers when you're done." -ForegroundColor Yellow
    } else {
        Write-Host "Fix and start script failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error running fix and start script: $_" -ForegroundColor Red
    exit 1
}

# Keep the script running until user presses Ctrl+C
try {
    Write-Host "Press Ctrl+C to stop the servers..." -ForegroundColor Yellow
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Clean up when the user presses Ctrl+C
    Write-Host ""
    Write-Host "Stopping servers..." -ForegroundColor Yellow
    
    # Find and stop the Python API server process
    $apiProcess = Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*encoding_fixed_api.py*"}
    if ($apiProcess) {
        $apiProcess | Stop-Process -Force
        Write-Host "API server stopped." -ForegroundColor Green
    }
    
    # Find and stop the npm process
    $npmProcess = Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*vite*"}
    if ($npmProcess) {
        $npmProcess | Stop-Process -Force
        Write-Host "Web UI stopped." -ForegroundColor Green
    }
    
    Write-Host "Cleanup complete." -ForegroundColor Green
}