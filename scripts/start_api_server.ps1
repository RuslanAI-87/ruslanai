# RuslanAI API Server Startup Script
# This script starts the API server for RuslanAI

Write-Host "RuslanAI API Server Startup Script" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "This script will start the API server for RuslanAI."
Write-Host ""

# Check if the API server file exists
if (-Not (Test-Path "C:\RuslanAI\central_agent\backend\encoding_fixed_api.py")) {
    Write-Host "Error: API server file not found." -ForegroundColor Red
    Write-Host "Please check the path and make sure the file exists." -ForegroundColor Yellow
    exit 1
}

# Change to the API server directory
try {
    cd "C:\RuslanAI\central_agent\backend"
    
    # Start the API server
    Write-Host "Starting API server..." -ForegroundColor Cyan
    python encoding_fixed_api.py
} catch {
    Write-Host "Error starting API server: $_" -ForegroundColor Red
    exit 1
}