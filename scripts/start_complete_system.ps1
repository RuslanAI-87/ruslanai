# Start Complete RuslanAI System
# This script starts the entire RuslanAI system with WebSocket integration

Write-Host "RuslanAI Complete System Startup" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

# Step 1: Stop any running processes
Write-Host "Step 1: Stopping any running processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*python*" -or $_.ProcessName -like "*node*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Start the API server with central orchestrator
Write-Host "Step 2: Starting API server with central orchestrator..." -ForegroundColor Yellow
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command `"cd C:\RuslanAI && python -m central_agent.backend.encoding_fixed_api`"" -WindowStyle Normal

# Wait for API server to initialize
Write-Host "Waiting for API server to initialize..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Step 3: Start the WebSocket server
Write-Host "Step 3: Starting WebSocket server with orchestrator integration..." -ForegroundColor Yellow
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command `"cd C:\RuslanAI\scripts && node simple_websocket_server.js`"" -WindowStyle Normal

# Wait for WebSocket server to initialize
Write-Host "Waiting for WebSocket server to initialize..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

# Step 4: Start the web UI
Write-Host "Step 4: Starting web UI..." -ForegroundColor Yellow
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command `"cd C:\RuslanAI\web_ui && npm run dev`"" -WindowStyle Normal

# Final instructions
Write-Host @"

=== RuslanAI System Is Starting ===

The following components should now be running:

1. API Server with Central Orchestrator (Python)
   - Endpoint: http://localhost:8001/orchestrator/central
   - This handles the core AI functionality

2. WebSocket Server (Node.js)
   - Endpoint: ws://localhost:8001/ws
   - This handles real-time notifications

3. Web UI (React)
   - URL: http://localhost:3000 (or another port if 3000 is busy)
   - This is the user interface

To use the system:
1. Open the web UI in your browser
2. Wait for the "Connected" status to appear
3. Send messages in the chat interface

If the central orchestrator is properly connected, you should receive real responses from the AI system.
If not, you'll get a simulated response indicating that the orchestrator isn't available.

Troubleshooting:
- If the WebSocket status shows as disconnected, try refreshing the page
- Check the browser console (F12) for any error messages
- Make sure all components are running in their PowerShell windows

"@ -ForegroundColor Cyan