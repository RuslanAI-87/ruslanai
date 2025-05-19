@echo off
echo ================================================================
echo  RuslanAI - Run Memory System Benchmarks
echo ================================================================
echo.

:: Set UTF-8 for console
chcp 65001

:: Set environment variables
set PYTHONIOENCODING=utf-8

:: Verify test environment exists
if not exist "C:\RuslanAI\test_environment" (
    echo Error: Test environment not found!
    echo Please run scripts\setup_test_environment.bat first.
    pause
    exit /b 1
)

:: Check for dependencies
call scripts\check_python_deps.bat
if %ERRORLEVEL% NEQ 0 (
    echo Failed to verify dependencies. Please install required packages first.
    pause
    exit /b 1
)

echo Select action:
echo 1. Generate test data (small dataset - recommended for quick testing)
echo 2. Generate test data (medium dataset)
echo 3. Generate test data (large dataset - may take significant time)
echo 4. Run performance benchmark
echo 5. Run relevance benchmark
echo 6. Run context restoration benchmark
echo 7. Run all benchmarks
echo 8. View benchmark results
echo.

set /p choice=Enter action number (1-8): 

echo.
if "%choice%"=="1" (
    echo Generating small test dataset...
    python "C:\RuslanAI\memory_test_environment.py" --generate small
    if %ERRORLEVEL% NEQ 0 (
        echo Error generating test data.
        pause
        exit /b 1
    )
) else if "%choice%"=="2" (
    echo Generating medium test dataset...
    python "C:\RuslanAI\memory_test_environment.py" --generate medium
    if %ERRORLEVEL% NEQ 0 (
        echo Error generating test data.
        pause
        exit /b 1
    )
) else if "%choice%"=="3" (
    echo Generating large test dataset...
    echo This may take significant time. Please wait...
    python "C:\RuslanAI\memory_test_environment.py" --generate large
    if %ERRORLEVEL% NEQ 0 (
        echo Error generating test data.
        pause
        exit /b 1
    )
) else if "%choice%"=="4" (
    echo Running performance benchmark...
    python "C:\RuslanAI\memory_test_environment.py" --run --scenarios performance
    if %ERRORLEVEL% NEQ 0 (
        echo Error running benchmark.
        pause
        exit /b 1
    )
) else if "%choice%"=="5" (
    echo Running relevance benchmark...
    python "C:\RuslanAI\memory_test_environment.py" --run --scenarios relevance
    if %ERRORLEVEL% NEQ 0 (
        echo Error running benchmark.
        pause
        exit /b 1
    )
) else if "%choice%"=="6" (
    echo Running context restoration benchmark...
    python "C:\RuslanAI\memory_test_environment.py" --run --scenarios context_restoration
    if %ERRORLEVEL% NEQ 0 (
        echo Error running benchmark.
        pause
        exit /b 1
    )
) else if "%choice%"=="7" (
    echo Running all benchmarks...
    echo This may take a significant amount of time. Please wait...
    python "C:\RuslanAI\memory_test_environment.py" --run --scenarios all
    if %ERRORLEVEL% NEQ 0 (
        echo Error running benchmarks.
        pause
        exit /b 1
    )
) else if "%choice%"=="8" (
    if exist "C:\RuslanAI\test_environment\benchmarks\results" (
        echo Opening results directory...
        start "" "C:\RuslanAI\test_environment\benchmarks\results"
    ) else (
        echo No results directory found. Please run benchmarks first.
    )
) else (
    echo Invalid choice.
    pause
    exit /b 1
)

echo.
echo Operation completed.
if exist "C:\RuslanAI\test_environment\benchmarks\results" (
    echo Check results in directory: C:\RuslanAI\test_environment\benchmarks\results
)
echo.
pause
exit /b 0