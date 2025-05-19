# Run API server with console output
Write-Host "Starting API server..." -ForegroundColor Green
cd C:\RuslanAI
python -m central_agent.backend.encoding_fixed_api

# Keep window open
Write-Host "Press any key to exit..."
[void][System.Console]::ReadKey($true)