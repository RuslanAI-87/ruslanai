# Restart Fixed Web UI
# This script restarts the web UI with fixed connection state handling

Write-Host "RuslanAI Fixed Web UI Restart" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

# Restart web UI
Write-Host "Stopping any running web UI instances..." -ForegroundColor Yellow
taskkill /f /im node.exe /fi "WINDOWTITLE eq *web_ui*" 2>$null
Start-Sleep -Seconds 2

# Start web UI with fixed connection handling
Write-Host "Starting web UI with fixed connection handling..." -ForegroundColor Green
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command `"cd C:\RuslanAI\web_ui; npm run dev`"" -WindowStyle Normal

Write-Host ""
Write-Host "Web UI should be restarting. Please check your browser at:" -ForegroundColor Cyan
Write-Host "http://localhost:3000 or http://localhost:3001" -ForegroundColor Cyan
Write-Host ""
Write-Host "If connection status still shows as disconnected:" -ForegroundColor Yellow
Write-Host "1. Make sure the WebSocket server is running (should be on port 8001)" -ForegroundColor Yellow
Write-Host "2. Open browser developer tools (F12) and check the console for errors" -ForegroundColor Yellow
Write-Host "3. Try refreshing the page after a few seconds" -ForegroundColor Yellow