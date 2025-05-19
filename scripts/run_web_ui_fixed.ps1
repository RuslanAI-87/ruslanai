# Run Web UI with console output
Write-Host "Starting Web UI..." -ForegroundColor Green
cd C:\RuslanAI\web_ui
npm run dev

# Keep window open
Write-Host "Press any key to exit..."
[void][System.Console]::ReadKey($true)