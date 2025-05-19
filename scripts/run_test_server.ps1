# Run the test WebSocket server
Write-Host "Starting test WebSocket server..." -ForegroundColor Green

# Change to the scripts directory
cd "C:\RuslanAI\scripts"

# Activate virtual environment if it exists
if (Test-Path "C:\RuslanAI\venv\Scripts\Activate.ps1") {
    Write-Host "Activating virtual environment..." -ForegroundColor Cyan
    & "C:\RuslanAI\venv\Scripts\Activate.ps1"
}

# Install required packages
Write-Host "Installing required packages..." -ForegroundColor Cyan
pip install fastapi uvicorn websockets python-multipart

# Run the test server
Write-Host "Running test WebSocket server on http://localhost:8001" -ForegroundColor Cyan
python test_websocket_server.py