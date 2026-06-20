# PowerShell Script to Install Dependencies and Run Tests
# Run this script after installing Python

param(
    [switch]$SkipInstall,
    [switch]$QuickTest,
    [switch]$FullTest,
    [switch]$Coverage
)

$ErrorActionPreference = "Continue"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          Stellar Network SDK - Test Automation              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check if Python is installed
Write-Host "Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python not found!" -ForegroundColor Red
    Write-Host "`nPlease install Python 3.10+ first:" -ForegroundColor Yellow
    Write-Host "  Option 1: winget install Python.Python.3.12" -ForegroundColor Cyan
    Write-Host "  Option 2: Download from https://www.python.org/downloads/`n" -ForegroundColor Cyan
    exit 1
}

# Check Python version
Write-Host "`nVerifying Python version..." -ForegroundColor Yellow
$versionString = python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
$majorVersion = [int]($versionString.Split('.')[0])
$minorVersion = [int]($versionString.Split('.')[1])

if ($majorVersion -lt 3 -or ($majorVersion -eq 3 -and $minorVersion -lt 10)) {
    Write-Host "✗ Python 3.10+ required, found $versionString" -ForegroundColor Red
    Write-Host "Please upgrade Python: https://www.python.org/downloads/`n" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Python $versionString meets requirements (3.10+)" -ForegroundColor Green

if (-not $SkipInstall) {
    # Install/upgrade pip
    Write-Host "`nUpgrading pip..." -ForegroundColor Yellow
    python -m pip install --upgrade pip

    # Check for UV
    Write-Host "`nChecking for UV package manager..." -ForegroundColor Yellow
    $uvInstalled = $false
    try {
        $uvVersion = uv --version 2>&1
        Write-Host "✓ Found UV: $uvVersion" -ForegroundColor Green
        $uvInstalled = $true
    } catch {
        Write-Host "⚠ UV not found, will use pip instead" -ForegroundColor Yellow
        Write-Host "  (UV is faster but optional)" -ForegroundColor Gray
    }

    # Install dependencies
    Write-Host "`nInstalling project dependencies..." -ForegroundColor Yellow
    Write-Host "This may take a few minutes...`n" -ForegroundColor Gray
    
    if ($uvInstalled) {
        Write-Host "Using UV for installation..." -ForegroundColor Cyan
        uv sync --all-extras
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠ UV sync failed, falling back to pip..." -ForegroundColor Yellow
            pip install -e ".[dev,aiohttp,shamir]"
        } else {
            Write-Host "✓ Dependencies installed with UV" -ForegroundColor Green
        }
    } else {
        Write-Host "Using pip for installation..." -ForegroundColor Cyan
        pip install -e ".[dev,aiohttp,shamir]"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Dependencies installed successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ Installation failed!" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "`nSkipping installation (--SkipInstall flag set)" -ForegroundColor Yellow
}

# Run tests
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      Running Tests                           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$testCommand = "pytest -v tests/"

if ($Coverage) {
    Write-Host "Running tests with coverage report..." -ForegroundColor Yellow
    $testCommand = "pytest -v tests/ --cov=stellar_sdk --cov-report=html --cov-report=term"
} elseif ($QuickTest) {
    Write-Host "Running quick test (first 10 test files)..." -ForegroundColor Yellow
    $testCommand = "pytest -v tests/test_account.py tests/test_keypair.py tests/test_asset.py"
} elseif ($FullTest) {
    Write-Host "Running full test suite..." -ForegroundColor Yellow
    $testCommand = "pytest -v tests/ --tb=short"
} else {
    Write-Host "Running standard tests..." -ForegroundColor Yellow
}

# Try with UV first, fall back to direct pytest
$uvInstalled = Get-Command uv -ErrorAction SilentlyContinue
if ($uvInstalled) {
    Write-Host "Executing: uv run $testCommand`n" -ForegroundColor Gray
    Invoke-Expression "uv run $testCommand"
} else {
    Write-Host "Executing: $testCommand`n" -ForegroundColor Gray
    Invoke-Expression $testCommand
}

$testExitCode = $LASTEXITCODE

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
if ($testExitCode -eq 0) {
    Write-Host "║                    ✓ ALL TESTS PASSED                       ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    if ($Coverage) {
        Write-Host "Coverage report generated: htmlcov/index.html" -ForegroundColor Cyan
        Write-Host "Open it with: start htmlcov/index.html`n" -ForegroundColor Gray
    }
    
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Review test results above" -ForegroundColor White
    Write-Host "  2. Fix any warnings if present" -ForegroundColor White
    Write-Host "  3. Commit and push: git add . && git commit -m 'Tests passing' && git push`n" -ForegroundColor White
} else {
    Write-Host "║                    ✗ TESTS FAILED                           ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check error messages above" -ForegroundColor White
    Write-Host "  2. Read INSTALL_AND_TEST.md for common issues" -ForegroundColor White
    Write-Host "  3. Try: pip install -e '.[dev]' --force-reinstall" -ForegroundColor White
    Write-Host "  4. Run specific failing test: pytest -v tests/test_name.py`n" -ForegroundColor White
}

Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

exit $testExitCode
