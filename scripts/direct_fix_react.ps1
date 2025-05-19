# Direct Fix React Script
# This script directly fixes the specific React files mentioned in the error

Write-Host "Direct Fix React Script" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host "This script will directly fix the React import issues in the specific files."
Write-Host ""

# Run the Python fix script
Write-Host "Running direct React fix script..." -ForegroundColor Yellow
Write-Host ""

# Change to the scripts directory
cd "C:\RuslanAI\scripts"

# Run the Python script
python direct_fix_react.py

# Check if the script ran successfully
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "React fix script completed successfully!" -ForegroundColor Green
    Write-Host "You can now try running the web UI again." -ForegroundColor Green
    Write-Host ""
    Write-Host "To start the web UI, run:" -ForegroundColor Cyan
    Write-Host "cd C:\RuslanAI\web_ui" -ForegroundColor Cyan
    Write-Host "npm run dev" -ForegroundColor Cyan
} else {
    Write-Host "React fix script failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}