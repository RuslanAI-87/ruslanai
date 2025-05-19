# start_ruslanai.ps1 - Launch all RuslanAI components
Write-Host "=== Starting RuslanAI System ===" -ForegroundColor Cyan

# Function to check if a port is in use
function Test-PortInUse {
    param([int]$Port)
    try {
        return $null -ne (Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue)
    }
    catch {
        return $false
    }
}

# 1. Start WebSocket server if not already running
if (-not (Test-PortInUse -Port 8005)) {
    Write-Host "1. Starting WebSocket server..." -ForegroundColor Green
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/scripts; python simple_ws_server.py"
    Start-Sleep -Seconds 2
}
else {
    Write-Host "1. WebSocket server already running on port 8005" -ForegroundColor Green
}

# 2. Start Backend
Write-Host "2. Starting Backend API server..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/central_agent/backend; python encoding_fixed_api.py"
Start-Sleep -Seconds 3

# 3. Start Frontend with appropriate command based on available scripts
Write-Host "3. Starting Frontend..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", @"
    cd C:/RuslanAI/web_ui
    Write-Host 'Checking npm scripts...' -ForegroundColor Yellow
    `$availableScripts = npm run --json 2>>`$null | ConvertFrom-Json
    
    if (`$availableScripts -and (`$availableScripts | Get-Member -Name 'start' -MemberType Properties)) {
        Write-Host 'Starting with npm start' -ForegroundColor Green
        npm start
    }
    elseif (`$availableScripts -and (`$availableScripts | Get-Member -Name 'dev' -MemberType Properties)) {
        Write-Host 'Starting with npm run dev' -ForegroundColor Green
        npm run dev
    }
    else {
        Write-Host 'Attempting to start with vite or create-react-app default commands...' -ForegroundColor Yellow
        if (Test-Path 'vite.config.js') {
            npx vite
        }
        else {
            npx react-scripts start
        }
    }
"@

Write-Host @"

=== RuslanAI System Launch Complete ===

All components have been started with fixes applied to:
- Backend: Added logger definition
- Frontend: Fixed npm start script

The system should now be operational. Check individual windows for component status.

"@ -ForegroundColor Green
