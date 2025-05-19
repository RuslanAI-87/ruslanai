# Script to start the entire RuslanAI system with central orchestrator integration

# Define colors for console output
function Write-ColorOutput($message, $color) {
    $originalColor = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $color
    Write-Output $message
    $host.UI.RawUI.ForegroundColor = $originalColor
}

function Start-Component($name, $command, $workingDir) {
    Write-ColorOutput "Starting $name..." "Cyan"
    Start-Process -FilePath "powershell" -ArgumentList "-Command $command" -WorkingDirectory $workingDir -NoNewWindow
    Write-ColorOutput "$name started successfully!" "Green"
}

# Create required directories
$logsDir = "C:\RuslanAI\logs"
$centralAgentDir = "C:\RuslanAI\central_agent"
$orchestratorDir = "C:\RuslanAI\central_agent\orchestrator"
$webUiDir = "C:\RuslanAI\web_ui"
$scriptsDir = "C:\RuslanAI\scripts"

if (-not (Test-Path $logsDir)) { New-Item -Path $logsDir -ItemType Directory -Force }

# Kill existing processes
Write-ColorOutput "Stopping any existing RuslanAI processes..." "Yellow"

# Stop Node.js processes running the WebSocket server
Get-Process | Where-Object { $_.ProcessName -eq "node" } | ForEach-Object { 
    try {
        $commandLine = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
        if ($commandLine -match "simple_websocket_server.js") {
            Write-ColorOutput "Stopping WebSocket server process (PID: $($_.Id))..." "Yellow"
            $_ | Stop-Process -Force
        }
    } catch {
        # Ignore errors when checking processes
    }
}

# Stop Python processes for central orchestrator
Get-Process | Where-Object { $_.ProcessName -eq "python" } | ForEach-Object { 
    try {
        $commandLine = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
        if ($commandLine -match "central_orchestrator.py" -or $commandLine -match "encoding_fixed_api.py") {
            Write-ColorOutput "Stopping Python process (PID: $($_.Id))..." "Yellow"
            $_ | Stop-Process -Force
        }
    } catch {
        # Ignore errors when checking processes
    }
}

# Stop React app processes
Get-Process | Where-Object { $_.ProcessName -eq "node" } | ForEach-Object { 
    try {
        $commandLine = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
        if ($commandLine -match "react" -or $commandLine -match "web_ui") {
            Write-ColorOutput "Stopping React app process (PID: $($_.Id))..." "Yellow"
            $_ | Stop-Process -Force
        }
    } catch {
        # Ignore errors when checking processes
    }
}

# Wait for processes to stop
Start-Sleep -Seconds 2

# Start WebSocket server with orchestrator integration
Write-ColorOutput "Starting WebSocket server with central orchestrator integration..." "Cyan"
Start-Process -FilePath "node" -ArgumentList "$scriptsDir\simple_websocket_server.js" -WorkingDirectory $scriptsDir -NoNewWindow

# Start React web UI
Write-ColorOutput "Starting React web UI..." "Cyan"
$reactStartCommand = "cd $webUiDir && npm start"
Start-Process -FilePath "powershell" -ArgumentList "-Command $reactStartCommand" -WorkingDirectory $webUiDir -NoNewWindow

Write-ColorOutput "`nRuslanAI System started successfully with all components!" "Green"
Write-ColorOutput "- WebSocket server: http://localhost:8001" "White"
Write-ColorOutput "- React web UI: http://localhost:3000" "White"
Write-ColorOutput "`nUse your web browser to access the React web UI at http://localhost:3000" "Cyan"
Write-ColorOutput "The WebSocket server is now connected to the central orchestrator for AI processing." "Cyan"
Write-ColorOutput "`nTo test the system, run the test_orchestrator_connection.js script:" "Yellow"
Write-ColorOutput "node $scriptsDir\test_orchestrator_connection.js" "White"