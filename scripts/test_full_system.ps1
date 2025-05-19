# Full system test for RuslanAI WebSocket integration
Write-Host "=== RuslanAI WebSocket Integration Test ===" -ForegroundColor Green
Write-Host "This script will test the full WebSocket integration system." -ForegroundColor Cyan
Write-Host ""

# Step 1: Start the fixed API server
Write-Host "Step 1: Starting fixed API server..." -ForegroundColor Yellow
$serverProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\RuslanAI\scripts\run_fixed_api.ps1" -PassThru

# Wait for the server to start
Write-Host "Waiting for the server to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Step 2: Test the WebSocket connection
Write-Host "`nStep 2: Testing WebSocket connection..." -ForegroundColor Yellow
Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\RuslanAI\scripts\run_websocket_test.ps1" -Wait

# Step 3: Apply the fixes to the web UI
Write-Host "`nStep 3: Applying fixes to the web UI..." -ForegroundColor Yellow

# Create a temp file without BOM
Write-Host "Creating clean WebSocket service file..." -ForegroundColor Cyan
$content = Get-Content -Path "C:\RuslanAI\scripts\fixed_websocket_service.js" -Raw 
if ($content.StartsWith([char]0xEF + [char]0xBB + [char]0xBF)) {
    $content = $content.Substring(3)
}
$tempFile = "C:\RuslanAI\scripts\clean_websocket_service.js"
Set-Content -Path $tempFile -Value $content -NoNewline -Encoding utf8

# Copy the clean file to the web_ui services directory
Write-Host "Copying WebSocket service..." -ForegroundColor Cyan
try {
    Copy-Item -Path $tempFile -Destination "C:\RuslanAI\web_ui\src\services\websocketService.js" -Force -ErrorAction Stop
} catch {
    Write-Host "Could not copy file, it may be in use. Please close any processes using it." -ForegroundColor Yellow
    Write-Host "After fixing the connection errors, manually copy the file from:" -ForegroundColor Yellow
    Write-Host $tempFile -ForegroundColor Cyan
    Write-Host "To:" -ForegroundColor Yellow
    Write-Host "C:\RuslanAI\web_ui\src\services\websocketService.js" -ForegroundColor Cyan
    Write-Host "Then restart the web UI." -ForegroundColor Yellow
}

# Step 4: Start the web UI
Write-Host "`nStep 4: Starting web UI..." -ForegroundColor Yellow
Write-Host "Starting web UI in a new window..." -ForegroundColor Cyan
Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\RuslanAI\scripts\start_web_ui.ps1"

# Display instructions
Write-Host @"

=== Test Instructions ===
1. The test WebSocket server is running on http://localhost:8001
2. The web UI should be starting on http://localhost:3000
3. Use the chat interface to send a message to the test server
4. The test server will simulate task processing with progress updates
5. Watch the connection status indicator in the UI header
6. When you're done testing, close all PowerShell windows

"@ -ForegroundColor Green

# Wait for user input before cleaning up
Read-Host "Press Enter to stop the test server and exit"

# Clean up
Stop-Process -Id $serverProcess.Id -Force
Write-Host "Test server stopped. Test complete." -ForegroundColor Green