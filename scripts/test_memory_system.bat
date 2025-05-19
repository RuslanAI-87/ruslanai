@echo off
echo ================================================================
echo  RuslanAI - Memory System Test Suite
echo ================================================================
echo.

:: Set UTF-8 for console
chcp 65001

echo This script will guide you through the complete memory system testing process.
echo.
echo The process includes:
echo 1. Checking and installing dependencies
echo 2. Setting up the test environment
echo 3. Generating test data
echo 4. Running benchmarks
echo 5. Viewing results
echo.
echo Press Ctrl+C at any time to abort the process.
echo.
pause

:: Step 1: Check dependencies
echo.
echo ================================================================
echo STEP 1: Checking dependencies
echo ================================================================
echo.
call scripts\check_python_deps.bat
if %ERRORLEVEL% NEQ 0 (
    echo Failed to verify dependencies. Aborting test process.
    pause
    exit /b 1
)

:: Step 2: Setup test environment
echo.
echo ================================================================
echo STEP 2: Setting up test environment
echo ================================================================
echo.
call scripts\setup_test_environment.bat
if %ERRORLEVEL% NEQ 0 (
    echo Failed to set up test environment. Aborting test process.
    pause
    exit /b 1
)

:: Step 3: Generate test data
echo.
echo ================================================================
echo STEP 3: Generating test data
echo ================================================================
echo.
echo Select test data size:
echo 1. Small dataset (quick testing, recommended)
echo 2. Medium dataset (more thorough testing)
echo 3. Large dataset (comprehensive testing, time-consuming)
echo.
set /p data_size=Enter choice (1-3): 

set size_param=small
if "%data_size%"=="2" set size_param=medium
if "%data_size%"=="3" set size_param=large

echo.
echo Generating %size_param% test dataset...
python "C:\RuslanAI\memory_test_environment.py" --generate %size_param%
if %ERRORLEVEL% NEQ 0 (
    echo Failed to generate test data. Aborting test process.
    pause
    exit /b 1
)

:: Step 4: Run benchmarks
echo.
echo ================================================================
echo STEP 4: Running benchmarks
echo ================================================================
echo.
echo Select benchmark type:
echo 1. Performance benchmark only
echo 2. Relevance benchmark only
echo 3. Context restoration benchmark only
echo 4. All benchmarks (recommended)
echo.
set /p benchmark_type=Enter choice (1-4): 

set scenario_param=performance
if "%benchmark_type%"=="2" set scenario_param=relevance
if "%benchmark_type%"=="3" set scenario_param=context_restoration
if "%benchmark_type%"=="4" set scenario_param=all

echo.
echo Running %scenario_param% benchmark(s)...
echo This may take some time. Please wait...
python "C:\RuslanAI\memory_test_environment.py" --run --scenarios %scenario_param%
if %ERRORLEVEL% NEQ 0 (
    echo Failed to run benchmarks. Test process incomplete.
    pause
    exit /b 1
)

:: Step 5: View results
echo.
echo ================================================================
echo STEP 5: View results
echo ================================================================
echo.
echo Benchmark results are stored in: C:\RuslanAI\test_environment\benchmarks\results

echo Would you like to open the results directory now?
echo 1. Yes
echo 2. No
echo.
set /p view_results=Enter choice (1-2): 

if "%view_results%"=="1" (
    start "" "C:\RuslanAI\test_environment\benchmarks\results"
)

echo.
echo ================================================================
echo Memory system testing process completed successfully!
echo ================================================================
echo.
echo Summary:
echo - Dependencies installed and verified
echo - Test environment set up at C:\RuslanAI\test_environment
echo - Generated %size_param% test dataset
echo - Ran %scenario_param% benchmark(s)
echo - Results stored in C:\RuslanAI\test_environment\benchmarks\results
echo.
echo You can run additional benchmarks or generate different test data
echo using the run_memory_benchmarks.bat script.
echo.
pause
exit /b 0