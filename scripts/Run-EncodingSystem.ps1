# Run-EncodingSystem.ps1 - PowerShell script for running the RuslanAI encoding system examples and tests

# Force UTF-8 encoding for PowerShell output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Color definitions
$Blue = [System.ConsoleColor]::Blue
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Red = [System.ConsoleColor]::Red

function Write-ColoredLine($Color, $Message) {
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

Write-ColoredLine $Blue "===================================="
Write-ColoredLine $Blue "  RuslanAI Encoding System Runner  "
Write-ColoredLine $Blue "===================================="
Write-Output ""

# Function to check if a Python module is installed
function Test-PythonModule($ModuleName) {
    $result = python -c "import $ModuleName" 2>$null
    return $LASTEXITCODE -eq 0
}

# Check requirements
Write-ColoredLine $Yellow "Checking requirements..."
$MissingModules = $false

# Required modules
$Modules = @("websockets", "fastapi", "uvicorn", "requests")

foreach ($module in $Modules) {
    Write-Host "  Checking for $module: " -NoNewline
    if (Test-PythonModule $module) {
        Write-ColoredLine $Green "Found"
    } else {
        Write-ColoredLine $Red "Not found"
        $MissingModules = $true
    }
}

if ($MissingModules) {
    Write-Output ""
    Write-ColoredLine $Red "Missing dependencies detected. Install them with:"
    Write-ColoredLine $Yellow "pip install websockets fastapi uvicorn requests"
    Write-Output ""
    Write-ColoredLine $Yellow "Continue anyway? [y/N]"
    $answer = Read-Host
    if (-not ($answer -match "^[Yy]")) {
        Write-ColoredLine $Red "Exiting."
        exit 1
    }
}

Write-Output ""
Write-ColoredLine $Green "All requirements checked."
Write-ColoredLine $Yellow "Select an option:"
Write-Output "  1. Run encoding system tests"
Write-Output "  2. Run WebSocket encoding example"
Write-Output "  3. Run client encoding example"
Write-Output "  4. View documentation"
Write-Output "  5. Exit"
Write-Host "Enter your choice [1-5]: " -NoNewline
$choice = Read-Host

switch ($choice) {
    "1" {
        Write-Output ""
        Write-ColoredLine $Blue "Running encoding system tests..."
        python test_encoding_system.py
    }
    "2" {
        Write-Output ""
        Write-ColoredLine $Blue "Running WebSocket encoding example..."
        python websocket_encoding_example.py
    }
    "3" {
        Write-Output ""
        Write-ColoredLine $Blue "Running client encoding example..."
        python client_encoding_example.py
    }
    "4" {
        Write-Output ""
        Write-ColoredLine $Blue "Viewing documentation..."
        if (Get-Command "notepad" -ErrorAction SilentlyContinue) {
            notepad.exe ENCODING_SYSTEM_DOCUMENTATION.md
        } else {
            Write-ColoredLine $Red "Notepad not available. Please open ENCODING_SYSTEM_DOCUMENTATION.md manually."
        }
    }
    default {
        Write-Output ""
        Write-ColoredLine $Blue "Exiting."
        exit 0
    }
}

Write-Output ""
Write-ColoredLine $Green "Operation completed."