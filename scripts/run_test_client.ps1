# Run the simple WebSocket test client
Write-Host "Starting WebSocket test client..." -ForegroundColor Green

# Change to the scripts directory
cd "C:\RuslanAI\scripts"

# Install required npm packages if needed
Write-Host "Installing required packages..." -ForegroundColor Cyan
npm install ws uuid readline --no-save

# Run the WebSocket client
Write-Host "Connecting to WebSocket server on ws://localhost:8001/ws" -ForegroundColor Cyan
Write-Host "Type a message and press Enter to send it to the server." -ForegroundColor Yellow
Write-Host "Type 'exit' to close the connection." -ForegroundColor Yellow
node test_simple_ws_client.js