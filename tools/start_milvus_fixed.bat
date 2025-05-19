@echo off
setlocal enabledelayedexpansion

echo =======================================================
echo Milvus Docker Container Management Tool
echo =======================================================

:: Check for Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed or not running.
    echo Please install and start Docker Desktop.
    exit /b 1
)

:: Check if Milvus container exists
set CONTAINER_EXISTS=0
for /f "tokens=*" %%i in ('docker ps -a --filter "name=milvus_standalone" --format "{{.Names}}"') do (
    set CONTAINER_EXISTS=1
)

set CONTAINER_RUNNING=0
for /f "tokens=*" %%i in ('docker ps --filter "name=milvus_standalone" --format "{{.Names}}"') do (
    set CONTAINER_RUNNING=1
)

if %CONTAINER_EXISTS%==1 (
    if %CONTAINER_RUNNING%==1 (
        echo [INFO] Milvus container is already running.
    ) else (
        echo [INFO] Starting existing Milvus container...
        docker start milvus_standalone
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to start Milvus container.
            exit /b 1
        )
        echo [INFO] Milvus container started successfully.
    )
) else (
    echo [INFO] Creating and starting new Milvus container...
    docker run -d --name milvus_standalone -p 19530:19530 -p 9091:9091 milvusdb/milvus:v2.2.11
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create Milvus container.
        exit /b 1
    )
    echo [INFO] Milvus container created and started successfully.
)

echo [INFO] Waiting for Milvus to initialize (30 seconds)...
timeout /t 30 /nobreak > nul

:: Create port check script
(
echo import socket, sys
echo. 
echo def check_port_open(host="localhost", port=19530, timeout=2^):
echo     """Check if a port is open on the specified host."""
echo     sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM^)
echo     sock.settimeout(timeout^)
echo     try:
echo         result = sock.connect_ex((host, port^)^)
echo         sock.close(^)
echo         return result == 0
echo     except Exception as e:
echo         print(f"Error checking port: {e}"^)
echo         return False
echo. 
echo # Check if Milvus port is open
echo if check_port_open(port=19530^):
echo     print("SUCCESS: Milvus port (19530^) is open and accessible."^)
echo     sys.exit(0^)
echo else:
echo     print("ERROR: Milvus port (19530^) is not accessible."^)
echo     sys.exit(1^)
) > "%~dp0check_port.py"

:: Run port check
python "%~dp0check_port.py"
if %errorlevel% neq 0 (
    echo [ERROR] Milvus server port is not accessible after startup.
    echo This could indicate an issue with the Milvus container.
    del "%~dp0check_port.py"
    exit /b 1
)

del "%~dp0check_port.py"
echo.
echo [SUCCESS] Milvus server is running and accessible!
echo =======================================================
echo Server URI: http://localhost:19530
echo You can connect to it with:
echo     connections.connect("default", uri="http://localhost:19530")
echo =======================================================

echo.
echo [INFO] Do you want to test the connection with pymilvus? (y/n)
set /p test_connection="> "

if /i "%test_connection%" == "y" (
    :: Create test script
    (
    echo import sys
    echo try:
    echo     from pymilvus import connections, utility
    echo except ImportError:
    echo     print("pymilvus not installed. Installing..."^)
    echo     import subprocess
    echo     subprocess.check_call([sys.executable, "-m", "pip", "install", "pymilvus"]^)
    echo     from pymilvus import connections, utility
    echo.
    echo print("Testing connection to Milvus..."^)
    echo try:
    echo     uri = "http://localhost:19530"
    echo     print(f"Connecting with URI: {uri}"^)
    echo     connections.connect("default", uri=uri, timeout=10.0^)
    echo     print("Successfully connected to Milvus!"^)
    echo     has_collection = utility.has_collection("test_collection"^)
    echo     print(f"Milvus response: test_collection {'exists' if has_collection else 'does not exist'}"^)
    echo     connections.disconnect("default"^)
    echo     print("Successfully disconnected from Milvus"^)
    echo     print("TEST PASSED"^)
    echo     sys.exit(0^)
    echo except Exception as e:
    echo     print(f"Error connecting to Milvus: {e}"^)
    echo     sys.exit(1^)
    ) > "%~dp0test_connection.py"
    
    :: Run test script
    python "%~dp0test_connection.py"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to connect to Milvus with pymilvus.
        del "%~dp0test_connection.py"
        exit /b 1
    )
    
    del "%~dp0test_connection.py"
    echo [SUCCESS] Milvus connection test passed!
)

endlocal