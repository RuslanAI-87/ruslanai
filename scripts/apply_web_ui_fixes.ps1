# Apply WebSocket fixes and start the web UI
Write-Host "Applying WebSocket fixes and starting the web UI..." -ForegroundColor Green

# Copy websocketService.js to the web_ui services directory
Write-Host "Copying WebSocket service..." -ForegroundColor Cyan
Copy-Item -Path "C:\RuslanAI\scripts\fixed_websocket_service.js" -Destination "C:\RuslanAI\web_ui\src\services\websocketService.js" -Force

# Make sure there's no BOM in the files
Write-Host "Removing BOM markers from files..." -ForegroundColor Cyan
Get-Content -Path "C:\RuslanAI\web_ui\src\services\websocketService.js" -Raw | ForEach-Object { $_ -replace "^\xEF\xBB\xBF", "" } | Set-Content -Path "C:\RuslanAI\web_ui\src\services\websocketService.js" -NoNewline -Encoding utf8

# Start the web UI
Write-Host "Starting web UI..." -ForegroundColor Cyan
cd "C:\RuslanAI\web_ui"
npm run dev