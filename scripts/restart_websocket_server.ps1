# Restart the WebSocket server with the updated orchestration
Write-Host "Restarting WebSocket server with central orchestrator integration..." -ForegroundColor Cyan

# Kill any existing node processes running the WebSocket server
$nodeProcesses = Get-Process | Where-Object { $_.ProcessName -eq "node" } | ForEach-Object { 
    try {
        $commandLine = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
        if ($commandLine -match "simple_websocket_server.js") {
            Write-Host "Stopping existing WebSocket server process (PID: $($_.Id))..." -ForegroundColor Yellow
            $_ | Stop-Process -Force
            Write-Host "Process stopped." -ForegroundColor Green
        }
    } catch {
        Write-Host "Error checking process: $_" -ForegroundColor Red
    }
}

# Start the WebSocket server
Write-Host "Starting WebSocket server with orchestrator integration..." -ForegroundColor Cyan
$workingDir = "C:\RuslanAI\scripts"
$serverScript = "simple_websocket_server.js"

Start-Process -FilePath "node" -ArgumentList "$workingDir\$serverScript" -WorkingDirectory $workingDir -NoNewWindow

Write-Host "WebSocket server started with orchestrator integration!" -ForegroundColor Green
Write-Host "Server is running at http://localhost:8001" -ForegroundColor Cyan
Write-Host "WebSocket endpoint is available at ws://localhost:8001/ws" -ForegroundColor Cyan