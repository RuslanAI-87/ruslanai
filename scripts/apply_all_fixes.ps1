# Apply All Fixes Script
# This script applies all fixes for RuslanAI

Write-Host "Apply All Fixes Script" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host "This script will apply all fixes for RuslanAI:"
Write-Host "1. Fix duplicate React imports"
Write-Host "2. Add WebSocket ping/pong and reconnection logic"
Write-Host "3. Add ping/pong handling to the API server"
Write-Host ""

# Check for Python
try {
    $pythonVersion = python --version
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python not found. Please install Python and try again." -ForegroundColor Red
    exit 1
}

# Create logs directory if it doesn't exist
if (-Not (Test-Path "C:\RuslanAI\logs")) {
    Write-Host "Creating logs directory..." -ForegroundColor Yellow
    New-Item -Path "C:\RuslanAI\logs" -ItemType Directory -Force | Out-Null
}

# Change to the scripts directory
cd "C:\RuslanAI\scripts"

# Step 1: Fix React imports
Write-Host ""
Write-Host "Step 1: Fixing React imports..." -ForegroundColor Yellow
try {
    python fix_react_imports_only.py
    if ($LASTEXITCODE -eq 0) {
        Write-Host "React imports fixed successfully!" -ForegroundColor Green
    } else {
        Write-Host "React import fix failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error fixing React imports: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Update WebSocket service
Write-Host ""
Write-Host "Step 2: Updating WebSocket service..." -ForegroundColor Yellow
try {
    python simple_websocket_fix.py
    if ($LASTEXITCODE -eq 0) {
        Write-Host "WebSocket service updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "WebSocket service update failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error updating WebSocket service: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Add ping/pong handling to API server
Write-Host ""
Write-Host "Step 3: Adding ping/pong handling to API server..." -ForegroundColor Yellow
try {
    python add_ping_pong.py
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Ping/pong handling added successfully!" -ForegroundColor Green
    } else {
        Write-Host "Adding ping/pong handling failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error adding ping/pong handling: $_" -ForegroundColor Red
    exit 1
}

# All fixes applied
Write-Host ""
Write-Host "All fixes applied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "To start the API server, run:" -ForegroundColor Cyan
Write-Host "cd C:\RuslanAI\central_agent\backend" -ForegroundColor Cyan
Write-Host "python encoding_fixed_api.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the web UI, run:" -ForegroundColor Cyan
Write-Host "cd C:\RuslanAI\web_ui" -ForegroundColor Cyan
Write-Host "npm run dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "If the API server doesn't handle ping/pong correctly, you can use the standalone ping/pong server:" -ForegroundColor Yellow
Write-Host "C:\RuslanAI\scripts\run_ping_pong_server.bat" -ForegroundColor Cyan