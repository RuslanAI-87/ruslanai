# RuslanAI Test Integration Script
# This script tests the integration between the web UI and test WebSocket server

Write-Host "RuslanAI Test Integration Script" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "This script will test the integration between the web UI and test WebSocket server."
Write-Host ""

# Helper function to start a process
function Start-ProcessAsync {
    param (
        [string]$WorkingDirectory,
        [string]$Command,
        [string]$Arguments = "",
        [string]$WindowTitle
    )
    
    $process = Start-Process -FilePath $Command -ArgumentList $Arguments -WorkingDirectory $WorkingDirectory -PassThru
    return $process
}

# Check if the test WebSocket server exists
if (-Not (Test-Path "C:\RuslanAI\test_scripts\test_websocket_server.py")) {
    Write-Host "Error: Test WebSocket server script not found." -ForegroundColor Red
    exit 1
}

# Check if the web UI directory exists
if (-Not (Test-Path "C:\RuslanAI\web_ui")) {
    Write-Host "Error: Web UI directory not found." -ForegroundColor Red
    exit 1
}

# Create logs directory if it doesn't exist
if (-Not (Test-Path "C:\RuslanAI\logs")) {
    New-Item -Path "C:\RuslanAI\logs" -ItemType Directory -Force | Out-Null
}

# Start the test WebSocket server
Write-Host "Starting test WebSocket server..." -ForegroundColor Cyan
try {
    cd "C:\RuslanAI\test_scripts"
    $wsServer = Start-ProcessAsync -Command "python" -Arguments "test_websocket_server.py" -WorkingDirectory "C:\RuslanAI\test_scripts"
    Write-Host "Test WebSocket server started with PID: $($wsServer.Id)" -ForegroundColor Green
} catch {
    Write-Host "Error starting test WebSocket server: $_" -ForegroundColor Red
    exit 1
}

# Wait a moment for the server to start
Write-Host "Waiting for server to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start the web UI
Write-Host "Starting web UI..." -ForegroundColor Cyan
try {
    cd "C:\RuslanAI\web_ui"
    $webUI = Start-ProcessAsync -Command "npm" -Arguments "run dev" -WorkingDirectory "C:\RuslanAI\web_ui"
    Write-Host "Web UI started with PID: $($webUI.Id)" -ForegroundColor Green
} catch {
    Write-Host "Error starting web UI: $_" -ForegroundColor Red
    # Stop the WebSocket server
    try {
        Stop-Process -Id $wsServer.Id -Force
    } catch {}
    exit 1
}

Write-Host ""
Write-Host "Test environment is running!" -ForegroundColor Green
Write-Host "WebSocket Server URL: http://localhost:8001" -ForegroundColor Cyan
Write-Host "Web UI URL: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test instructions:" -ForegroundColor Yellow
Write-Host "1. Open the Web UI in your browser at http://localhost:3000" -ForegroundColor Yellow
Write-Host "2. Send a message in the chat" -ForegroundColor Yellow
Write-Host "3. Verify that you receive a response" -ForegroundColor Yellow
Write-Host "4. Check that progress updates are displayed" -ForegroundColor Yellow
Write-Host "5. Try uploading a file" -ForegroundColor Yellow
Write-Host "6. Test disconnecting and reconnecting" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop all components when done testing." -ForegroundColor Yellow

# Wait for user to cancel
try {
    while ($true) {
        Start-Sleep -Seconds 1
        
        # Check if processes are still running
        if ($wsServer.HasExited) {
            Write-Host "WebSocket server has stopped unexpectedly." -ForegroundColor Red
            break
        }
        
        if ($webUI.HasExited) {
            Write-Host "Web UI has stopped unexpectedly." -ForegroundColor Red
            break
        }
    }
} finally {
    # Clean up when the user presses Ctrl+C
    Write-Host ""
    Write-Host "Stopping all components..." -ForegroundColor Yellow
    
    # Stop the WebSocket server
    try {
        if (-Not $wsServer.HasExited) {
            Stop-Process -Id $wsServer.Id -Force
            Write-Host "WebSocket server stopped." -ForegroundColor Green
        }
    } catch {
        Write-Host "Error stopping WebSocket server: $_" -ForegroundColor Red
    }
    
    # Stop the web UI
    try {
        if (-Not $webUI.HasExited) {
            Stop-Process -Id $webUI.Id -Force
            Write-Host "Web UI stopped." -ForegroundColor Green
        }
    } catch {
        Write-Host "Error stopping web UI: $_" -ForegroundColor Red
    }
    
    Write-Host "Cleanup complete." -ForegroundColor Green
}