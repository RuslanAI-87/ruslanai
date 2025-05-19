@echo off
echo =====================================================
echo Checking Milvus container logs
echo =====================================================

docker logs milvus_standalone
if %errorlevel% neq 0 (
    echo.
    echo Failed to get logs. Make sure Docker is running.
    pause
    exit /b 1
)

echo.
echo.
echo =====================================================
echo Checking Milvus container status
echo =====================================================
docker ps -a | findstr milvus

echo.
echo =====================================================
echo Troubleshooting recommendations:
echo =====================================================
echo 1. Try removing the existing container and creating a new one:
echo    docker rm -f milvus_standalone
echo    docker run -d --name milvus_standalone -p 19530:19530 -p 9091:9091 milvusdb/milvus:v2.2.11
echo.
echo 2. Check if there are port conflicts:
echo    - Make sure nothing else is using ports 19530 and 9091
echo.
echo 3. Check if Docker has enough resources:
echo    - Milvus needs at least 2GB of memory
echo    - Increase Docker's memory limit in Docker Desktop settings
echo.
echo 4. Try pulling a specific version of Milvus:
echo    docker pull milvusdb/milvus:v2.0.2
echo    docker run -d --name milvus_standalone -p 19530:19530 -p 9091:9091 milvusdb/milvus:v2.0.2
echo.
echo.
pause