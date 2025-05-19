# Run WebSocket server with console output
Write-Host "Starting WebSocket server..." -ForegroundColor Green
cd C:\RuslanAI\scripts
node simple_websocket_server.js

# Keep window open
Write-Host "Press any key to exit..."
[void][System.Console]::ReadKey($true)