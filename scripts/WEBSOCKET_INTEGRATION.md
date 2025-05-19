# RuslanAI WebSocket Integration

This document explains how to test and implement the WebSocket integration for RuslanAI.

## Overview

The integration includes:

1. Enhanced WebSocket service with:
   - Reconnection with exponential backoff
   - Ping/pong keep-alive mechanism
   - Message queuing for offline periods
   - Connection state tracking
   - Task tracking and notifications

2. Agent Service for API calls:
   - API call retries with exponential backoff
   - WebSocket connection monitoring
   - Task status tracking

3. UI Integration:
   - Real-time task progress updates
   - Connection status indicator
   - Auto-scrolling message list

## Test Scripts

The following scripts are available for testing:

### `test_full_system.ps1`

The main test script that orchestrates the entire testing process:

1. Starts the fixed API server (with WebSocket support)
2. Tests the WebSocket connection
3. Applies the fixes to the web UI
4. Starts the web UI

Run this script to test the complete system:

```powershell
# Run as Administrator in PowerShell
.\test_full_system.ps1
```

### `run_fixed_api.ps1`

Starts the fixed API server with proper WebSocket support:

```powershell
.\run_fixed_api.ps1
```

The fixed API server implements:
- WebSocket endpoint at `ws://localhost:8001/ws`
- Task creation endpoint at `http://localhost:8001/orchestrator/central`
- Health check endpoint at `http://localhost:8001/api/health`

### `run_test_server.ps1` / `run_test_server.sh`

Alternative test server scripts if you don't want to use the fixed API server:

```powershell
# Windows
.\run_test_server.ps1

# Linux/macOS
./run_test_server.sh
```

### `run_websocket_test.ps1`

Tests the WebSocket connection using a simple Node.js client:

```powershell
.\run_websocket_test.ps1
```

### `apply_web_ui_fixes.ps1`

Applies the WebSocket fixes to the web UI and starts it:

```powershell
.\apply_web_ui_fixes.ps1
```

## Implementation Details

### WebSocket Service (`websocketService.js`)

- Singleton instance to maintain a single WebSocket connection
- Automatic reconnection with exponential backoff
- Ping/pong mechanism to keep the connection alive
- Message queue for offline periods
- Connection state tracking and notification
- Task tracking for long-running operations

### Agent Service (`agentService.js`)

- API call handling with retry logic
- WebSocket connection monitoring
- Task status tracking

### UI Integration (`RuslanAI.jsx`)

- Real-time task progress updates in the UI
- Connection status indicator
- Disables input when not connected
- Auto-scrolls to the latest message

## Testing the Integration

1. Run the test server
2. Open the web UI
3. Check the connection status indicator
4. Send a message to the test server
5. Observe the task progress updates
6. Test reconnection by stopping and restarting the server

## Troubleshooting

- Check browser console for WebSocket connection logs
- Verify the WebSocket server is running on port 8001
- Ensure there are no BOM markers in the JavaScript files
- Check for CORS issues if connecting to a different domain