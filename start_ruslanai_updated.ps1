# start_ruslanai_updated.ps1 - Launch all RuslanAI components with improved frontend detection
Write-Host "=== Starting RuslanAI System with improved frontend detection ===" -ForegroundColor Cyan

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

# Fix backend logger issue first
$backend_file = "C:/RuslanAI/central_agent/backend/encoding_fixed_api.py"
if (Test-Path $backend_file) {
    $content = Get-Content -Path $backend_file -Raw
    
    # If logger is not defined, add it
    if ($content -match "from central_orchestrator import" -and $content -notmatch "import logging") {
        $fixed_content = "import logging`nlogger = logging.getLogger(__name__)`n`n" + $content
        $fixed_content | Set-Content -Path $backend_file -Encoding UTF8
        Write-Host "Fixed backend logger issue" -ForegroundColor Green
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

# 3. Analyze and start Frontend
Write-Host "3. Starting Frontend..." -ForegroundColor Green

# First, run the analysis script if the frontend command doesn't exist
if (-not (Test-Path "C:/RuslanAI/web_ui/start_frontend_fixed.cmd")) {
    Write-Host "   Analyzing frontend structure..." -ForegroundColor Yellow
    & "C:/RuslanAI/fix_frontend.ps1"
}

# Start the frontend using the generated command file
if (Test-Path "C:/RuslanAI/web_ui/start_frontend_fixed.cmd") {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:/RuslanAI/web_ui; ./start_frontend_fixed.cmd"
} else {
    # Fallback options if command file wasn't created
    Write-Host "   Trying fallback startup methods..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", @"
    cd C:/RuslanAI/web_ui
    # Try various common frontend start commands
    if (Test-Path 'package.json') {
        Write-Host 'Trying npm start...' -ForegroundColor Yellow
        npm start
    } elseif (Test-Path 'yarn.lock') {
        Write-Host 'Trying yarn start...' -ForegroundColor Yellow
        yarn start
    } elseif (Test-Path 'vite.config.js') {
        Write-Host 'Trying vite...' -ForegroundColor Yellow
        npx vite
    } else {
        Write-Host 'Trying serve...' -ForegroundColor Yellow
        npx serve -s .
    }
"@
}

Write-Host @"

=== RuslanAI System Launch Complete ===

All components have been started:
1. WebSocket server - provides notification channel from agent
2. Backend (API) - processes requests to orchestrator
3. Frontend - web interface for interaction

The web interface should open automatically in your browser.
If not, navigate to: http://localhost:3000

"@ -ForegroundColor Green

