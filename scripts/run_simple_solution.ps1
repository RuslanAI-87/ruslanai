# RuslanAI WebSocket Simplified Solution
Write-Host "=== RuslanAI WebSocket Simplified Solution ===" -ForegroundColor Green
Write-Host "This script will set up a simplified WebSocket solution." -ForegroundColor Cyan
Write-Host ""

# Step 1: Start the simple WebSocket server in a new window
Write-Host "Step 1: Starting simple WebSocket server..." -ForegroundColor Yellow
Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\RuslanAI\scripts\run_simple_ws_server.ps1" -WindowStyle Normal

# Wait for the server to start
Write-Host "Waiting for the server to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Step 2: Test the WebSocket connection
Write-Host "`nStep 2: Testing WebSocket connection..." -ForegroundColor Yellow
Write-Host "Running a quick test to verify the server is working..." -ForegroundColor Cyan

# Test connection in this window
Write-Host "Installing required packages..." -ForegroundColor Cyan
cd "C:\RuslanAI\scripts"
npm install ws --no-save

$TestCode = @"
const WebSocket = require('ws');
const ws = new WebSocket('ws://localhost:8001/ws?userId=test_from_script');
ws.on('open', () => {
  console.log('Connection successful!');
  ws.send(JSON.stringify({type: 'ping', timestamp: Date.now()}));
});
ws.on('message', (data) => {
  console.log('Received:', JSON.parse(data));
  process.exit(0);
});
ws.on('error', (error) => {
  console.error('Error:', error.message);
  process.exit(1);
});
setTimeout(() => {
  console.log('Test timed out');
  process.exit(1);
}, 5000);
"@

Write-Host "Testing WebSocket connection..." -ForegroundColor Cyan
$TestCode | node

if ($LASTEXITCODE -ne 0) {
    Write-Host "WebSocket connection test failed. Please check if the server is running." -ForegroundColor Red
    Write-Host "Try running the server manually: .\run_simple_ws_server.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "WebSocket connection test successful!" -ForegroundColor Green

# Step 3: Copy the simplified WebSocket service to the web_ui
Write-Host "`nStep 3: Copying simplified WebSocket service to web_ui..." -ForegroundColor Yellow

# Create a temp file without BOM
Write-Host "Creating clean WebSocket service file..." -ForegroundColor Cyan
$content = Get-Content -Path "C:\RuslanAI\scripts\simple_websocket_service.js" -Raw 
if ($content.StartsWith([char]0xEF + [char]0xBB + [char]0xBF)) {
    $content = $content.Substring(3)
}
$tempFile = "C:\RuslanAI\scripts\clean_websocket_service.js"
Set-Content -Path $tempFile -Value $content -NoNewline -Encoding utf8

# Copy the clean file to the web_ui services directory
Write-Host "Copying WebSocket service..." -ForegroundColor Cyan
try {
    Copy-Item -Path $tempFile -Destination "C:\RuslanAI\web_ui\src\services\websocketService.js" -Force -ErrorAction Stop
    Write-Host "WebSocket service copied successfully!" -ForegroundColor Green
} catch {
    Write-Host "Could not copy file, it may be in use. Manual copy required:" -ForegroundColor Yellow
    Write-Host "1. Close any processes using the files" -ForegroundColor Yellow
    Write-Host "2. Copy this file:" -ForegroundColor Cyan
    Write-Host "   $tempFile" -ForegroundColor Cyan
    Write-Host "3. To this location:" -ForegroundColor Yellow
    Write-Host "   C:\RuslanAI\web_ui\src\services\websocketService.js" -ForegroundColor Cyan
}

# Step 4: Start the web UI
Write-Host "`nStep 4: Starting web UI..." -ForegroundColor Yellow
Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\RuslanAI\scripts\start_web_ui.ps1" -WindowStyle Normal

# Display instructions
Write-Host @"

=== Instructions ===
1. The simple WebSocket server is running on http://localhost:8001
2. The WebSocket endpoint is available at ws://localhost:8001/ws
3. The web UI should be starting on http://localhost:3000 or http://localhost:3001
4. Use the chat interface to send a message
5. Watch the connection status indicator in the UI header

If the web UI cannot connect to the WebSocket server:
1. Make sure the server is running (check the PowerShell window)
2. Try restarting the server with: .\run_simple_ws_server.ps1
3. Refresh the web UI page

To test the WebSocket server directly:
.\run_test_client.ps1

"@ -ForegroundColor Green

# Keep this window open
Write-Host "Press Enter to exit this script (the server will keep running in its own window)" -ForegroundColor Yellow
Read-Host