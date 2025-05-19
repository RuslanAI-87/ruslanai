# Run the WebSocket test client
Write-Host "Starting WebSocket test client..." -ForegroundColor Green

# Check if nodejs is installed
try {
    $nodeVersion = node -v
    Write-Host "Using Node.js version: $nodeVersion" -ForegroundColor Cyan
} catch {
    Write-Host "Error: Node.js is not installed or not in the PATH." -ForegroundColor Red
    exit 1
}

# Change to the scripts directory
cd "C:\RuslanAI\scripts"

# Install the websocket package if needed
Write-Host "Installing required packages if needed..." -ForegroundColor Cyan
npm install websocket --no-save

# Run the test client
Write-Host "Running WebSocket test client..." -ForegroundColor Cyan
node test_websocket_connection.js