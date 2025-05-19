# Start RuslanAI with WebSocket Connection Fix
# This script starts all components with enhanced WebSocket stability

# Set UTF-8 encoding
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Stop existing processes
Get-Process | Where-Object { $_.ProcessName -like "*python*" -or $_.ProcessName -like "*node*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Start API server
$apiProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd C:\RuslanAI && python -m central_agent.backend.encoding_fixed_api" -WindowStyle Normal -PassThru
Write-Host "Started API server with PID: $($apiProcess.Id)"

# Wait for API server to initialize
Start-Sleep -Seconds 5

# Start web UI
$webUIProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd C:\RuslanAI\web_ui && npm run dev" -WindowStyle Normal -PassThru
Write-Host "Started web UI with PID: $($webUIProcess.Id)"

# Wait for web UI to initialize
Start-Sleep -Seconds 3

# Open web UI in browser
Start-Process "http://localhost:5173"
Write-Host "Opened RuslanAI in browser"
Write-Host "WebSocket connection fix is active"
