# Generated PowerShell script
Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 5 Name,WorkingSet,CPU