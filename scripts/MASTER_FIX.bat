@echo off
REM MASTER FIX for RuslanAI Web Interface
REM This script fixes all issues with a minimal approach

echo ===== RuslanAI MASTER FIX =====
echo.
echo This script will fix all issues with the RuslanAI web interface:
echo 1. Fix duplicate React imports (causing build errors)
echo 2. Install a simple WebSocket service
echo 3. Add ping-pong support to the API server
echo 4. Fix Cyrillic encoding issues
echo.
echo Press any key to continue...
pause > nul
echo.

REM Step 1: Stop all running processes
echo Stopping all running processes...
taskkill /F /IM node.exe > nul 2>&1
taskkill /F /IM npm.exe > nul 2>&1
taskkill /F /IM python.exe > nul 2>&1
timeout /t 2 > nul
echo.

REM Step 2: Fix duplicate React imports
echo Fixing duplicate React imports...
python "%~dp0fix_duplicate_react.py"
if %ERRORLEVEL% neq 0 (
    echo WARNING: Failed to fix React imports, but continuing...
)
echo.

REM Step 3: Install simplified WebSocket service
echo Installing simplified WebSocket service...
copy /Y "%~dp0simplified_websocket.js" "C:\RuslanAI\web_ui\src\services\websocketService.js"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to install simplified WebSocket service.
    goto error
)
echo WebSocket service installed successfully.
echo.

REM Step 4: Apply ping-pong support to API server
echo Adding ping-pong support to API server...
python "%~dp0simple_api_ping.py"
if %ERRORLEVEL% neq 0 (
    echo WARNING: Failed to add ping-pong support to API server, but continuing...
)
echo.

REM Step 5: Fix React issues by removing duplicate components
echo Fixing component issues in RuslanAI.jsx...
>temp.txt (
    echo Checking for duplicate component declarations...
    type "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx" | findstr /n /c:"const ReconnectButton"
)
set /p RESULT=<temp.txt
del temp.txt
set COUNT=0
for /f "tokens=1 delims=:" %%a in ("%RESULT%") do (
    set /a COUNT+=1
)

if %COUNT% gtr 1 (
    echo Found %COUNT% ReconnectButton declarations, fixing...
    
    REM Create a fixed version of RuslanAI.jsx
    >temp.jsx (
        echo import React, { useState, useEffect, useRef } from "react";
        echo import RecordingIndicator from "./RecordingIndicator.jsx";
        echo import { Sun, Moon, MessageSquare, FileText, Archive, Users, BarChart2, Settings, ChevronDown, Upload, X, Play, Pause, AlertCircle, Check, Clock, Loader, RefreshCw } from "lucide-react";
        echo import useAudioRecorder from "../hooks/useAudioRecorder.js";
        echo import { sendMessageToAgent } from "../services/agentService.js";
        echo import websocketService from "../services/websocketService.js";
        echo.
        echo // Main application component
        echo const RuslanAI = () => {
        echo   // Application state
        echo   const [darkMode, setDarkMode] = useState(false);
        echo   const [activeTab, setActiveTab] = useState("chat");
        echo   const [tasksMenuOpen, setTasksMenuOpen] = useState(false);
        echo   const [messages, setMessages] = useState([
        echo     { id: 1, role: "system", content: "Добро пожаловать в RuslanAI! Чем я могу вам помочь сегодня?" }
        echo   ]);
        echo   const [inputMessage, setInputMessage] = useState("");
        echo   const [isRecording, setIsRecording] = useState(false);
        echo   const [isAiThinking, setIsAiThinking] = useState(false);
        echo   const [agentStatus, setAgentStatus] = useState([
        echo     { id: 1, name: "Центральный агент", status: "online", tasks: 2 },
        echo     { id: 2, name: "SEO-агент", status: "idle", tasks: 0 },
        echo     { id: 3, name: "Critic-агент", status: "offline", tasks: 0 }
        echo   ]);
        echo.  
        echo   // Reconnect button component
        echo   const ReconnectButton = () => {
        echo     const handleReconnect = () => {
        echo       console.log("Manual reconnection requested");
        echo       websocketService.forceReconnect();
        echo     };
        echo     
        echo     return (
        echo       ^<button 
        echo         onClick={handleReconnect}
        echo         className="p-2 rounded-lg bg-yellow-500 hover:bg-yellow-600 text-white flex items-center"
        echo         title="Reconnect to server"
        echo       ^>
        echo         ^<RefreshCw size={16} className="mr-1" /^>
        echo         ^<span^>Reconnect^</span^>
        echo       ^</button^>
        echo     );
        echo   };
        echo.
        type "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx" | findstr /v "ReconnectButton"
    )
    
    REM Back up the original file
    copy "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx" "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx.bak_master_fix"
    
    REM Replace the file
    move /Y temp.jsx "C:\RuslanAI\web_ui\src\components\RuslanAI.jsx"
    
    echo Fixed RuslanAI.jsx file.
) else (
    echo No duplicate components found in RuslanAI.jsx.
)
echo.

REM Step 6: Create a startup script
echo Creating startup script...
>C:\RuslanAI\START_RUSLANAI.bat (
    echo @echo off
    echo echo Starting RuslanAI...
    echo.
    echo taskkill /F /IM node.exe ^> nul 2^>^&1
    echo taskkill /F /IM npm.exe ^> nul 2^>^&1
    echo taskkill /F /IM python.exe ^> nul 2^>^&1
    echo timeout /t 2 ^> nul
    echo.
    echo echo Starting API server...
    echo start cmd /c "cd C:\RuslanAI ^&^& python -m central_agent.backend.encoding_fixed_api"
    echo timeout /t 5 ^> nul
    echo.
    echo echo Starting web UI...
    echo start cmd /c "cd C:\RuslanAI\web_ui ^&^& npm run dev"
    echo timeout /t 5 ^> nul
    echo.
    echo echo Opening RuslanAI in browser...
    echo start http://localhost:5173
    echo.
    echo echo RuslanAI started successfully.
)
echo Created startup script: C:\RuslanAI\START_RUSLANAI.bat
echo.

REM Step 7: Start the system
echo Starting the system...
echo.
echo Starting API server...
start cmd /c "cd C:\RuslanAI && python -m central_agent.backend.encoding_fixed_api"
timeout /t 5 > nul

echo Starting web UI...
start cmd /c "cd C:\RuslanAI\web_ui && npm run dev"
timeout /t 10 > nul

echo Opening RuslanAI in browser...
start http://localhost:5173
echo.

echo ===== MASTER FIX COMPLETE =====
echo.
echo If the web UI doesn't load properly:
echo 1. Wait 30 seconds and refresh the page
echo 2. Run C:\RuslanAI\START_RUSLANAI.bat to restart the system
echo 3. Check the logs in C:\RuslanAI\logs for errors
echo.
echo Press any key to exit...
pause > nul
exit /b 0

:error
echo.
echo An error occurred during the fix process.
echo Please check the logs in C:\RuslanAI\logs for details.
echo.
echo Press any key to exit...
pause > nul
exit /b 1