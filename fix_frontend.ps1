# fix_frontend.ps1 - Determine correct way to start the frontend
Write-Host "=== Analyzing frontend application structure ===" -ForegroundColor Cyan

# Navigate to web_ui directory
cd C:/RuslanAI/web_ui

# Check for package.json
if (Test-Path "package.json") {
    Write-Host "Found package.json, analyzing scripts..." -ForegroundColor Green
    $package_json = Get-Content -Path "package.json" -Raw | ConvertFrom-Json
    
    # Check scripts section
    if (Get-Member -InputObject $package_json -Name "scripts" -MemberType Properties) {
        $scripts = $package_json.scripts
        Write-Host "Available scripts:" -ForegroundColor Yellow
        $scripts | Get-Member -MemberType NoteProperty | ForEach-Object {
            Write-Host "  - $($_.Name): $($scripts.$($_.Name))"
        }
        
        # Determine startup script name (common ones: start, dev, serve)
        $startup_script = $null
        if (Get-Member -InputObject $scripts -Name "start" -MemberType Properties) {
            $startup_script = "start"
        } elseif (Get-Member -InputObject $scripts -Name "dev" -MemberType Properties) {
            $startup_script = "dev"
        } elseif (Get-Member -InputObject $scripts -Name "serve" -MemberType Properties) {
            $startup_script = "serve"
        }
        
        if ($startup_script) {
            Write-Host "Found startup script: $startup_script" -ForegroundColor Green
            # Create start script
            $startup_cmd = "npm run $startup_script"
            "$startup_cmd" | Set-Content -Path "C:/RuslanAI/web_ui/start_frontend.cmd" -Encoding ASCII
            Write-Host "Created startup command file: C:/RuslanAI/web_ui/start_frontend.cmd" -ForegroundColor Green
        } else {
            Write-Host "No standard startup script found" -ForegroundColor Yellow
            # Look for main package
            if (Get-Member -InputObject $package_json -Name "name" -MemberType Properties) {
                $package_name = $package_json.name
                Write-Host "Package name: $package_name" -ForegroundColor Yellow
                # Create generic start script
                $startup_cmd = "npm start"
                "$startup_cmd" | Set-Content -Path "C:/RuslanAI/web_ui/start_frontend.cmd" -Encoding ASCII
                Write-Host "Created generic startup command file: C:/RuslanAI/web_ui/start_frontend.cmd" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "No scripts section found in package.json" -ForegroundColor Red
    }
} else {
    Write-Host "package.json not found" -ForegroundColor Red
}

# Check for specific frameworks
if (Test-Path "vite.config.js") {
    Write-Host "Detected Vite framework" -ForegroundColor Green
    "npx vite" | Set-Content -Path "C:/RuslanAI/web_ui/start_frontend.cmd" -Encoding ASCII
    Write-Host "Created Vite startup command file: C:/RuslanAI/web_ui/start_frontend.cmd" -ForegroundColor Green
} elseif (Test-Path "next.config.js") {
    Write-Host "Detected Next.js framework" -ForegroundColor Green
    "npx next dev" | Set-Content -Path "C:/RuslanAI/web_ui/start_frontend.cmd" -Encoding ASCII
    Write-Host "Created Next.js startup command file: C:/RuslanAI/web_ui/start_frontend.cmd" -ForegroundColor Green
} elseif ((Test-Path "src") -and (Test-Path "public")) {
    Write-Host "Detected typical React structure" -ForegroundColor Green
    "npx react-scripts start" | Set-Content -Path "C:/RuslanAI/web_ui/start_frontend.cmd" -Encoding ASCII
    Write-Host "Created React startup command file: C:/RuslanAI/web_ui/start_frontend.cmd" -ForegroundColor Green
}

Write-Host "Frontend analysis complete. Use 'start_frontend.cmd' to start your application." -ForegroundColor Cyan
