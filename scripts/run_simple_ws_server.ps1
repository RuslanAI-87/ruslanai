# Run the simple standalone WebSocket server
Write-Host "Starting simple WebSocket server..." -ForegroundColor Green

# Change to the scripts directory
cd "C:\RuslanAI\scripts"

# Install required npm packages if needed
Write-Host "Installing required packages..." -ForegroundColor Cyan
npm install ws uuid --no-save

# Run the WebSocket server
Write-Host "Running WebSocket server on http://localhost:8001" -ForegroundColor Cyan
Write-Host "WebSocket endpoint available at ws://localhost:8001/ws" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
node simple_websocket_server.js