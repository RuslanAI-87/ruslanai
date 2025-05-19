@echo off
setlocal

set ACTION=%1

if "%ACTION%"=="" (
    echo Usage: milvus_control.bat [start^|stop^|status^|test]
    exit /b 1
)

if "%ACTION%"=="start" (
    call :start_milvus
) else if "%ACTION%"=="stop" (
    call :stop_milvus
) else if "%ACTION%"=="status" (
    call :check_status
) else if "%ACTION%"=="test" (
    call :run_test
) else (
    echo Unknown action: %ACTION%
    echo Usage: milvus_control.bat [start^|stop^|status^|test]
    exit /b 1
)

exit /b 0

:start_milvus
    echo Starting Milvus...
    cd C:\RuslanAI
    docker-compose up -d
    
    echo Waiting for services to start...
    timeout /t 10 /nobreak
    
    echo Checking if Milvus is running...
    docker ps | findstr milvus-standalone
    if %ERRORLEVEL% EQU 0 (
        echo Milvus is running!
        echo Access endpoints:
        echo   - Milvus: localhost:19530
        echo   - Minio Console: http://localhost:9001
        
        echo Testing connection...
        python C:\RuslanAI\milvus_config.py
    ) else (
        echo Failed to start Milvus. Check Docker logs.
    )
    exit /b 0

:stop_milvus
    echo Stopping Milvus...
    cd C:\RuslanAI
    docker-compose down
    echo Milvus stopped.
    exit /b 0

:check_status
    echo Checking Milvus status...
    docker ps | findstr milvus-standalone
    if %ERRORLEVEL% EQU 0 (
        echo Milvus is running.
    ) else (
        echo Milvus is not running.
    )
    exit /b 0

:run_test
    echo Running Milvus performance test...
    python C:\RuslanAI\test_milvus.py
    exit /b 0