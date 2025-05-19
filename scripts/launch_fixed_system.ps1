# Launch fixed RuslanAI system
# This is a simplified script to launch only the working components

Write-Host "Launching fixed RuslanAI system" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

# Stop any existing processes on ports 8001 and 3000+
Write-Host "Stopping existing processes..." -ForegroundColor Yellow
$processes = Get-Process | Where-Object { $_.ProcessName -eq "node" -or $_.ProcessName -eq "python" }
foreach ($process in $processes) {
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

# Start WebSocket server
Write-Host "Starting WebSocket server..." -ForegroundColor Cyan
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command `"cd C:\RuslanAI\scripts; node simple_websocket_server.js`"" -WindowStyle Normal

# Wait for server to start
Write-Host "Waiting for WebSocket server to start..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Start web UI
Write-Host "Starting web UI..." -ForegroundColor Cyan
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command `"cd C:\RuslanAI\web_ui; npm run dev`"" -WindowStyle Normal

# Wait for web UI to start
Write-Host "Waiting for web UI to start..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Open browser
Write-Host "Opening browser..." -ForegroundColor Cyan
Start-Process "http://localhost:3000"

Write-Host @"

RuslanAI is now running!

- WebSocket server: ws://localhost:8001/ws
- Web UI: http://localhost:3000 (or another port if 3000 is busy)

"@ -ForegroundColor Green