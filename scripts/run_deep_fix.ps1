# Run Deep Fix of React Imports
# This script runs the deep fix for React imports

Write-Host "Deep Fix React Imports" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host "This script will deeply examine all React files and fix any duplicate imports."
Write-Host ""

# Check for Python
try {
    $pythonVersion = python --version
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python not found. Please install Python and try again." -ForegroundColor Red
    exit 1
}

# Run the Python fix script
Write-Host ""
Write-Host "Running deep React import fix..." -ForegroundColor Yellow
Write-Host ""

try {
    # Change to the scripts directory
    cd "C:\RuslanAI\scripts"
    
    # Run the Python script
    python deep_fix_react_imports.py
    
    # Check if the script ran successfully
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Deep React fix completed successfully!" -ForegroundColor Green
        Write-Host "You can now try running the web UI again." -ForegroundColor Green
        Write-Host ""
        Write-Host "To start the web UI, run:" -ForegroundColor Cyan
        Write-Host "cd C:\RuslanAI\web_ui" -ForegroundColor Cyan
        Write-Host "npm run dev" -ForegroundColor Cyan
    } else {
        Write-Host "Deep React fix failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error running deep React fix: $_" -ForegroundColor Red
    exit 1
}