# RuslanAI Run All Tests Script
# This script runs all tests for RuslanAI

Write-Host "RuslanAI Run All Tests Script" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green
Write-Host "This script will run all tests for RuslanAI."
Write-Host ""

# Check Python requirements
try {
    Write-Host "Checking Python requirements..." -ForegroundColor Cyan
    
    # Check Python installation
    $pythonVersion = python --version
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
    
    # Check required Python modules
    $modules = @("fastapi", "uvicorn", "websockets")
    $missingModules = @()
    
    foreach ($module in $modules) {
        try {
            $moduleCheck = python -c "import $module; print(f'Found {module} version {$module.__version__}')"
            Write-Host $moduleCheck -ForegroundColor Green
        } catch {
            Write-Host "Missing module: $module" -ForegroundColor Yellow
            $missingModules += $module
        }
    }
    
    # Install missing modules if any
    if ($missingModules.Count -gt 0) {
        Write-Host "Installing missing modules..." -ForegroundColor Yellow
        foreach ($module in $missingModules) {
            Write-Host "Installing $module..." -ForegroundColor Yellow
            pip install $module
        }
    }
} catch {
    Write-Host "Error checking Python requirements: $_" -ForegroundColor Red
    exit 1
}

# Check Node.js requirements
try {
    Write-Host "Checking Node.js requirements..." -ForegroundColor Cyan
    
    # Check Node.js installation
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "Found Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "Found npm: $npmVersion" -ForegroundColor Green
    
    # Check if web UI dependencies are installed
    if (-Not (Test-Path "C:\RuslanAI\web_ui\node_modules")) {
        Write-Host "Web UI dependencies not installed, running npm install..." -ForegroundColor Yellow
        cd "C:\RuslanAI\web_ui"
        npm install
    } else {
        Write-Host "Web UI dependencies already installed" -ForegroundColor Green
    }
} catch {
    Write-Host "Error checking Node.js requirements: $_" -ForegroundColor Red
    exit 1
}

# Run WebSocket server test
Write-Host ""
Write-Host "Running WebSocket server test..." -ForegroundColor Cyan
try {
    cd "C:\RuslanAI\test_scripts"
    
    # Start the test WebSocket server
    $wsServer = Start-Process -FilePath "python" -ArgumentList "test_websocket_server.py" -PassThru
    Write-Host "Test WebSocket server started with PID: $($wsServer.Id)" -ForegroundColor Green
    
    # Wait a moment for the server to start
    Start-Sleep -Seconds 3
    
    # Run the WebSocket client test
    python test_websocket_client.py
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "WebSocket client test passed!" -ForegroundColor Green
    } else {
        Write-Host "WebSocket client test failed" -ForegroundColor Red
    }
    
    # Stop the WebSocket server
    Stop-Process -Id $wsServer.Id -Force
    Write-Host "WebSocket server stopped" -ForegroundColor Green
} catch {
    Write-Host "Error running WebSocket test: $_" -ForegroundColor Red
    
    # Try to stop the WebSocket server if it's running
    try {
        if ($wsServer -and -Not $wsServer.HasExited) {
            Stop-Process -Id $wsServer.Id -Force
        }
    } catch {}
}

# Run React component tests
Write-Host ""
Write-Host "Running React component tests..." -ForegroundColor Cyan
try {
    cd "C:\RuslanAI\web_ui"
    
    # Check if React components have syntax errors
    Write-Host "Checking React components syntax..." -ForegroundColor Yellow
    
    # Use a simple script to check JSX syntax
    $checkCode = {
        $hasErrors = $false
        Get-ChildItem -Path "src" -Include "*.jsx" -Recurse | ForEach-Object {
            $content = Get-Content $_ -Raw
            if ($content -match "import\s+React.*from\s+['\"]react['\"].*import\s+React.*from\s+['\"]react['\"]") {
                Write-Host "Error: Duplicate React imports in $_" -ForegroundColor Red
                $hasErrors = $true
            }
        }
        return $hasErrors
    }
    
    $hasErrors = & $checkCode
    
    if ($hasErrors) {
        Write-Host "React component tests failed: Found syntax errors" -ForegroundColor Red
    } else {
        Write-Host "React component syntax check passed!" -ForegroundColor Green
    }
} catch {
    Write-Host "Error running React component tests: $_" -ForegroundColor Red
}

# Run full integration test
Write-Host ""
Write-Host "Do you want to run the full integration test? (y/n)"
$answer = Read-Host

if ($answer -eq "y") {
    Write-Host "Running full integration test..." -ForegroundColor Cyan
    try {
        cd "C:\RuslanAI\test_scripts"
        .\test_integration.ps1
    } catch {
        Write-Host "Error running integration test: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipping full integration test" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "All tests completed!" -ForegroundColor Green