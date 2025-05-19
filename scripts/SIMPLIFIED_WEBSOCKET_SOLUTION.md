# RuslanAI Simplified WebSocket Solution

This document explains the simplified WebSocket solution for the RuslanAI system. This approach uses a dedicated standalone WebSocket server instead of trying to integrate WebSockets into the existing API server.

## Why This Approach

After analyzing the issues with the previous implementation, we found that the main problems were:

1. The FastAPI WebSocket implementation was not correctly configured or missing required dependencies
2. The WebSocket endpoint was not properly registered in the FastAPI application
3. The reconnection logic in the client was not handling all error cases

This new solution addresses these issues by:
1. Using a dedicated standalone WebSocket server using Node.js (much simpler to set up)
2. Implementing correct WebSocket endpoint handling
3. Improving error handling and reconnection logic in the client

## How to Use

### Quick Start (Recommended)

Run the all-in-one solution script:

```powershell
cd C:\RuslanAI\scripts
.\run_simple_solution.ps1
```

This script will:
1. Start the standalone WebSocket server
2. Test the WebSocket connection
3. Install the simplified WebSocket service in the web UI
4. Start the web UI

### Manual Setup

If you prefer to run each component separately:

1. Start the WebSocket server:
   ```powershell
   cd C:\RuslanAI\scripts
   .\run_simple_ws_server.ps1
   ```

2. Copy the simplified WebSocket service to the web UI:
   ```powershell
   Copy-Item -Path "C:\RuslanAI\scripts\simple_websocket_service.js" -Destination "C:\RuslanAI\web_ui\src\services\websocketService.js" -Force
   ```

3. Start the web UI:
   ```powershell
   cd C:\RuslanAI\web_ui
   npm run dev
   ```

### Testing

To test the WebSocket server directly:

```powershell
cd C:\RuslanAI\scripts
.\run_test_client.ps1
```

This will start a simple WebSocket client that can send messages to the server and receive responses.

## How It Works

### The WebSocket Server

The standalone WebSocket server (`simple_websocket_server.js`) provides:
- WebSocket endpoint at `ws://localhost:8001/ws`
- Task creation endpoint at `http://localhost:8001/orchestrator/central`
- Health check endpoint at `http://localhost:8001/api/health`

It handles:
- Client connections with userId tracking
- Ping/pong keep-alive messages
- Task progress notifications
- Task completion notifications

### The WebSocket Client

The simplified WebSocket service (`simple_websocket_service.js`) provides:
- Automatic connection to the WebSocket server
- Reconnection with exponential backoff
- Message queuing for offline periods
- Connection state tracking and notification
- Task tracking

### The Web UI

The web UI uses the WebSocket service to:
- Display connection status
- Send messages to the server
- Receive task progress updates
- Show completed responses

## Troubleshooting

If you encounter issues:

1. **WebSocket server won't start**:
   - Make sure Node.js is installed
   - Make sure the required packages are installed: `npm install ws uuid`
   - Check if port 8001 is already in use

2. **Web UI can't connect to WebSocket server**:
   - Make sure the WebSocket server is running
   - Check the browser console for error messages
   - Try restarting the WebSocket server

3. **No response from the server**:
   - Use the test client to check if the server is responding
   - Check the WebSocket server console for error messages

4. **Web UI doesn't show connection status**:
   - Make sure the simplified WebSocket service is correctly installed
   - Check the browser console for error messages
   - Try clearing the browser cache and refreshing the page

## Files

- `simple_websocket_server.js`: The standalone WebSocket server
- `run_simple_ws_server.ps1`: Script to run the WebSocket server
- `test_simple_ws_client.js`: Test client for the WebSocket server
- `run_test_client.ps1`: Script to run the test client
- `simple_websocket_service.js`: Simplified WebSocket service for the web UI
- `run_simple_solution.ps1`: All-in-one script to run the complete solution