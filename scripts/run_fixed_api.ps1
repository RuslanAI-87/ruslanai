# Run the fixed API server
Write-Host "Starting fixed API server..." -ForegroundColor Green

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

# Run the fixed API server
Write-Host "Running fixed API server on http://localhost:8001" -ForegroundColor Cyan
python encoding_fixed_api.py