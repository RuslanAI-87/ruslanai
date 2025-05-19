# Fix React Imports Script
# This script runs the Python fix script to fix duplicate React imports

Write-Host "Fix React Imports Script" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green
Write-Host "This script will fix React import issues in the web UI."
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
Write-Host "Running React import fix script..." -ForegroundColor Yellow
Write-Host ""

try {
    # Change to the scripts directory
    cd "C:\RuslanAI\scripts"
    
    # Run the Python script
    python fix_react_imports_only.py
    
    # Check if the script ran successfully
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "React import fix script completed successfully!" -ForegroundColor Green
        Write-Host "You can now try running the web UI again." -ForegroundColor Green
        Write-Host ""
        Write-Host "To start the web UI, run:" -ForegroundColor Cyan
        Write-Host "cd C:\RuslanAI\web_ui" -ForegroundColor Cyan
        Write-Host "npm run dev" -ForegroundColor Cyan
    } else {
        Write-Host "React import fix script failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error running React import fix script: $_" -ForegroundColor Red
    exit 1
}