# Launch-EnhancedRuslanAI.ps1
Write-Host "=== Launching Enhanced RuslanAI System ===" -ForegroundColor Cyan

# Stop existing processes
Write-Host "Stopping existing processes..." -ForegroundColor Yellow
Get-Process -Name python -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start the enhanced API server
Write-Host "Starting enhanced API server..." -ForegroundColor Green
Start-Process cmd -ArgumentList "/k", "chcp 65001 && title RuslanAI Enhanced API && cd C:\RuslanAI\central_agent\backend && python enhanced_api.py"

# Wait for API server to start
Write-Host "Waiting for API server to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start the web interface
Write-Host "Starting web interface..." -ForegroundColor Green
Start-Process cmd -ArgumentList "/k", "chcp 65001 && title RuslanAI Web UI && cd C:\RuslanAI\web_ui && npm run dev"

# Wait for web interface to start
Write-Host "Waiting for web interface to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Open browser
Write-Host "Opening browser..." -ForegroundColor Green
Start-Process "http://localhost:3000"

Write-Host ""
Write-Host "Enhanced RuslanAI System is now running:" -ForegroundColor Cyan
Write-Host "- Enhanced API: http://localhost:8001" -ForegroundColor White
Write-Host "- Web Interface: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "New capabilities available:" -ForegroundColor Green
Write-Host "1. PowerShell command execution" -ForegroundColor White
Write-Host "2. Text file operations (create/read)" -ForegroundColor White
Write-Host "3. Basic SEO analysis" -ForegroundColor White
Write-Host "4. Enhanced Python script execution" -ForegroundColor White
Write-Host ""
Write-Host "Check console windows for any errors or logs." -ForegroundColor Yellow
