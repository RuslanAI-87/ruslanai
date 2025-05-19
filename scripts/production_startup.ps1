# production_startup.ps1 - RuslanAI production startup script
Write-Host "=== Starting RuslanAI Production Environment ===" -ForegroundColor Cyan

# Stop previous processes
$ports = @(8001, 8005)
foreach ($port in $ports) {
    $processId = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess
    if ($processId) {
        Write-Host "Stopping process on port $port (PID: $processId)" -ForegroundColor Yellow
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

# Start production bridge
Write-Host "Starting production WebSocket-Memory bridge..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "python C:/RuslanAI/scripts/production_bridge.py"

Write-Host "Components started successfully" -ForegroundColor Green
Write-Host "WebSocket bridge: http://localhost:8005" -ForegroundColor Cyan

# Usage instructions
Write-Host @"

=== Production Environment Ready ===
The web interface is already configured to connect to port 8005
You can now use the RuslanAI system with reliable memory integration

Monitor logs:
- Bridge logs: C:/RuslanAI/logs/production_bridge.log
- Memory access logs: C:/RuslanAI/logs/direct_memory.log

"@ -ForegroundColor Yellow
