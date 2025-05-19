@echo off
echo =====================================================
echo Setting up Milvus Standalone with correct parameters
echo =====================================================

echo Stopping and removing existing container...
docker stop milvus_standalone >nul 2>&1
docker rm milvus_standalone >nul 2>&1

echo Pulling Milvus Standalone image...
docker pull milvusdb/milvus:v2.0.2

echo Creating Milvus container with proper parameters...
docker run -d --name milvus_standalone ^
  -p 19530:19530 ^
  -p 9091:9091 ^
  -v "%USERPROFILE%\milvus\data":/var/lib/milvus/data ^
  -v "%USERPROFILE%\milvus\conf":/var/lib/milvus/conf ^
  -v "%USERPROFILE%\milvus\logs":/var/lib/milvus/logs ^
  -e "STANDALONE=true" ^
  milvusdb/milvus:v2.0.2

if %errorlevel% neq 0 (
    echo.
    echo Failed to create Milvus container.
    echo Trying simplified version without volume mounts...
    
    docker run -d --name milvus_standalone ^
      -p 19530:19530 ^
      -p 9091:9091 ^
      -e "STANDALONE=true" ^
      milvusdb/milvus:v2.0.2
    
    if %errorlevel% neq 0 (
        echo.
        echo Failed to create Milvus container even with simplified parameters.
        pause
        exit /b 1
    )
)

echo.
echo Waiting for Milvus to initialize (60 seconds)...
echo This may take some time, please be patient.
timeout /t 10 /nobreak > nul
echo Checking container status after 10 seconds...
docker ps | findstr milvus

echo Continuing to wait...
timeout /t 20 /nobreak > nul
echo Checking container status after 30 seconds...
docker ps | findstr milvus

echo Continuing to wait...
timeout /t 30 /nobreak > nul
echo Checking container status after 60 seconds...
docker ps | findstr milvus

echo.
echo Checking if Milvus API port is responding...
powershell -Command "(New-Object System.Net.Sockets.TcpClient).Connect('localhost', 19530); if($?) {Write-Host 'Port is open' -ForegroundColor Green} else {Write-Host 'Port is closed' -ForegroundColor Red}"

echo.
echo =====================================================
echo Test connection to Milvus
echo =====================================================
echo Attempting to connect to Milvus with Python...
echo.

echo import sys > "%TEMP%\test_milvus_conn.py"
echo try: >> "%TEMP%\test_milvus_conn.py"
echo     from pymilvus import connections >> "%TEMP%\test_milvus_conn.py"
echo     print("Connecting to Milvus...") >> "%TEMP%\test_milvus_conn.py"
echo     connections.connect("default", uri="http://localhost:19530") >> "%TEMP%\test_milvus_conn.py"
echo     print("Successfully connected to Milvus!") >> "%TEMP%\test_milvus_conn.py"
echo     connections.disconnect("default") >> "%TEMP%\test_milvus_conn.py"
echo     print("Test completed successfully!") >> "%TEMP%\test_milvus_conn.py"
echo     sys.exit(0) >> "%TEMP%\test_milvus_conn.py"
echo except ImportError: >> "%TEMP%\test_milvus_conn.py"
echo     print("pymilvus not installed. Install with: pip install pymilvus") >> "%TEMP%\test_milvus_conn.py"
echo     sys.exit(1) >> "%TEMP%\test_milvus_conn.py"
echo except Exception as e: >> "%TEMP%\test_milvus_conn.py"
echo     print(f"Error connecting to Milvus: {e}") >> "%TEMP%\test_milvus_conn.py"
echo     sys.exit(1) >> "%TEMP%\test_milvus_conn.py"

python "%TEMP%\test_milvus_conn.py"
del "%TEMP%\test_milvus_conn.py"

echo.
echo =====================================================
echo Next steps if Milvus is running correctly:
echo =====================================================
echo 1. Run the URI format fix to make sure your code uses correct URI format:
echo    cd C:\RuslanAI\tools
echo    python fix_milvus_uri.py
echo.
echo 2. Run your cognitive memory tests:
echo    cd C:\RuslanAI
echo    python test_cognitive_memory.py
echo.

pause