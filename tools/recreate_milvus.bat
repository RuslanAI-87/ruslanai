@echo off
echo =====================================================
echo Recreating Milvus container with specific version
echo =====================================================

echo Stopping and removing existing container...
docker stop milvus_standalone >nul 2>&1
docker rm milvus_standalone >nul 2>&1

echo Pulling Milvus image (v2.0.2)...
docker pull milvusdb/milvus:v2.0.2

echo Creating new Milvus container...
docker run -d --name milvus_standalone -p 19530:19530 -p 9091:9091 milvusdb/milvus:v2.0.2
if %errorlevel% neq 0 (
    echo.
    echo Failed to create Milvus container.
    pause
    exit /b 1
)

echo.
echo Container created. Waiting 60 seconds for initialization...
timeout /t 60 /nobreak

echo.
echo =====================================================
echo Checking container status
echo =====================================================
docker ps | findstr milvus

echo.
echo.
echo If the container is running, try connecting to it with:
echo.
echo python -c "from pymilvus import connections; connections.connect('default', uri='http://localhost:19530'); print('Connected successfully!')"
echo.

pause