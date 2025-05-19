# Direct Replace React Files Script
# This script directly replaces problematic React files with fixed versions

Write-Host "Direct Replace React Files" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green
Write-Host "This script will replace problematic React files with fixed versions."
Write-Host ""

# Check for Python
try {
    $pythonVersion = python --version
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python not found. Please install Python and try again." -ForegroundColor Red
    exit 1
}

# Run the Python script
Write-Host ""
Write-Host "Running direct replacement script..." -ForegroundColor Yellow
Write-Host ""

try {
    # Change to the scripts directory
    cd "C:\RuslanAI\scripts"
    
    # Run the Python script
    python direct_replace_react.py
    
    # Check if the script ran successfully
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "React file replacement completed successfully!" -ForegroundColor Green
        Write-Host "You can now try running the web UI again." -ForegroundColor Green
        Write-Host ""
        Write-Host "To start the web UI, run:" -ForegroundColor Cyan
        Write-Host "cd C:\RuslanAI\web_ui" -ForegroundColor Cyan
        Write-Host "npm run dev" -ForegroundColor Cyan
    } else {
        Write-Host "React file replacement failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host "Error running React file replacement: $_" -ForegroundColor Red
    exit 1
}