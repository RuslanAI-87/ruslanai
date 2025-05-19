# RuslanAI Central Orchestrator Integration

This document explains how the WebSocket server has been integrated with the central orchestrator to enable AI-powered responses to user queries.

## What's Been Implemented

1. **WebSocket Server with Orchestrator Connection**
   - The WebSocket server (`simple_websocket_server.js`) has been modified to connect to the Python central orchestrator
   - Messages from the web UI are now processed by the AI-powered orchestrator
   - Progress updates are provided while the orchestrator is processing

2. **System Architecture**
   - Web UI -> WebSocket Server -> Central Orchestrator
   - The orchestrator provides access to multiple specialized agents
   - Memory system integration for persistent context

## How to Run the System

### Option 1: Integrated Startup

Simply run the batch file:
```
start_integrated_system.bat
```

This script will:
1. Stop any existing components
2. Start the WebSocket server with orchestrator integration
3. Start the React web UI

### Option 2: Manual Component Startup

If you prefer to start components individually:

1. **Start the WebSocket Server**:
   ```powershell
   # From PowerShell
   cd C:\RuslanAI\scripts
   node simple_websocket_server.js
   ```

2. **Start the React Web UI**:
   ```powershell
   # From PowerShell
   cd C:\RuslanAI\web_ui
   npm start
   ```

## Testing the Integration

You can test the orchestrator integration with the provided test script:

```powershell
# From PowerShell
cd C:\RuslanAI\scripts
node test_orchestrator_connection.js
```

This script will:
1. Connect to the WebSocket server
2. Send a test message to the orchestrator
3. Display the response from the AI system

## Troubleshooting

If you encounter issues:

1. **Check the logs**:
   - WebSocket server logs: Command line output
   - Orchestrator logs: `C:\RuslanAI\logs\central_agent.log`

2. **Restart the system**:
   - Run `start_integrated_system.bat` to restart all components

3. **Verify Python environment**:
   - Make sure Python is in your PATH
   - Verify that all required dependencies are installed

## Available Scripts

- `run_integrated_system.ps1`: PowerShell script to start all components
- `restart_websocket_server.ps1`: Restart only the WebSocket server
- `test_orchestrator_connection.js`: Test the orchestrator connection
- `connect_orchestrator.js`: Update the WebSocket server to use the orchestrator

## Next Steps

- Add more specialized agents
- Improve error handling and recovery
- Enhance the memory system for better context retention
- Implement authentication and user management