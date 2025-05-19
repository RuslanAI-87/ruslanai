# Diagnostic script for RuslanAI
Write-Host "Running diagnostics for RuslanAI..." -ForegroundColor Yellow

# Check Python
Write-Host "`nChecking Python installation..." -ForegroundColor Cyan
try {
    $pythonVersion = python --version
    Write-Host "Python is installed: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: Python not found or not in PATH" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Check Node.js
Write-Host "`nChecking Node.js installation..." -ForegroundColor Cyan
try {
    $nodeVersion = node --version
    Write-Host "Node.js is installed: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: Node.js not found or not in PATH" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Check npm
Write-Host "`nChecking npm installation..." -ForegroundColor Cyan
try {
    $npmVersion = npm --version
    Write-Host "npm is installed: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: npm not found or not in PATH" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Check key directories
Write-Host "`nChecking key directories..." -ForegroundColor Cyan
$directories = @(
    "C:\RuslanAI",
    "C:\RuslanAI\central_agent",
    "C:\RuslanAI\central_agent\backend",
    "C:\RuslanAI\central_agent\orchestrator",
    "C:\RuslanAI\web_ui",
    "C:\RuslanAI\scripts"
)

foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Host "Directory exists: $dir" -ForegroundColor Green
    } else {
        Write-Host "Error: Directory does not exist: $dir" -ForegroundColor Red
    }
}

# Check key files
Write-Host "`nChecking key files..." -ForegroundColor Cyan
$files = @(
    "C:\RuslanAI\central_agent\backend\encoding_fixed_api.py",
    "C:\RuslanAI\central_agent\orchestrator\central_orchestrator.py",
    "C:\RuslanAI\scripts\simple_websocket_server.js",
    "C:\RuslanAI\web_ui\package.json",
    "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx",
    "C:\RuslanAI\web_ui\src\services\websocketService.js"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "File exists: $file" -ForegroundColor Green
    } else {
        Write-Host "Error: File does not exist: $file" -ForegroundColor Red
    }
}

# Check ports
Write-Host "`nChecking ports..." -ForegroundColor Cyan
$ports = @(8001, 3000, 3001, 3002, 3003, 3004)

foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "Port $port is in use by process ID: $($connection.OwningProcess)" -ForegroundColor Yellow
        
        try {
            $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "  Process name: $($process.ProcessName)" -ForegroundColor Yellow
            }
        } catch {
            # Do nothing, just continue
        }
    } else {
        Write-Host "Port $port is available" -ForegroundColor Green
    }
}

# Keep window open
Write-Host "`nDiagnostics complete. Press any key to exit..." -ForegroundColor Magenta
[void][System.Console]::ReadKey($true)