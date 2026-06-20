# Installation and Testing Guide

## Step 1: Install Python 3.10+

### Option A: Using Microsoft Store (Recommended for Windows)
1. Open PowerShell and run:
```powershell
winget install Python.Python.3.12
```

### Option B: Download from Python.org
1. Visit: https://www.python.org/downloads/
2. Download Python 3.12 (or 3.10, 3.11, 3.13, 3.14)
3. Run installer
4. ✅ **IMPORTANT**: Check "Add Python to PATH"
5. Click "Install Now"

### Option C: Using Chocolatey
```powershell
choco install python312
```

### Verify Installation
After installing, close and reopen PowerShell, then run:
```powershell
python --version
# Should show: Python 3.12.x (or your version)
```

## Step 2: Install UV (Fast Python Package Manager)

```powershell
# Install UV
pip install uv

# Or using PowerShell (official method)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

## Step 3: Install Project Dependencies

```powershell
cd "C:\Users\USER\OneDrive\Music\stellar\stellar-network-project"

# Install the project with all dependencies
uv sync --all-extras
```

Or if UV isn't working:
```powershell
pip install -e ".[dev,aiohttp,shamir]"
```

## Step 4: Run Tests

### Run All Unit Tests
```powershell
# Using Makefile (recommended)
make unit-test

# Or directly with pytest
uv run pytest -v tests/

# Without UV
pytest -v tests/
```

### Run Specific Test File
```powershell
uv run pytest -v tests/test_keypair.py
```

### Run Tests with Coverage
```powershell
uv run pytest -v tests/ --cov=stellar_sdk --cov-report=html
```

### Run Integration Tests (requires Docker)
```powershell
make integration-test
```

## Step 5: Fix Common Test Failures

### Issue 1: Import Errors
**Error**: `ModuleNotFoundError: No module named 'stellar_sdk'`

**Fix**:
```powershell
pip install -e .
```

### Issue 2: Missing Dependencies
**Error**: `ModuleNotFoundError: No module named 'pytest'`

**Fix**:
```powershell
pip install -e ".[dev]"
```

### Issue 3: Async Test Failures
**Error**: `RuntimeError: Event loop is closed`

**Fix**: Already configured in conftest.py, but if issues persist:
```powershell
pip install pytest-asyncio
```

### Issue 4: HTTP Server Test Failures
**Error**: Issues with pytest-httpserver

**Fix**:
```powershell
pip install pytest-httpserver
```

## Step 6: Run Code Quality Checks

### Run Pre-commit Hooks
```powershell
uv run pre-commit run --all-files
```

### Run Type Checking
```powershell
make type-check
```

## Step 7: View Test Results

### View Coverage Report
After running tests with coverage:
```powershell
# Open HTML coverage report
start htmlcov/index.html
```

## Troubleshooting

### Python Not Found After Installation
1. Close all PowerShell windows
2. Reopen PowerShell
3. Try again

### UV Installation Issues
Use pip instead:
```powershell
pip install -e ".[dev]"
pytest -v tests/
```

### Permission Errors
Run PowerShell as Administrator

### Path Issues
Add Python to PATH manually:
1. Search "Environment Variables" in Windows
2. Edit "Path" in System Variables
3. Add Python installation directory (e.g., `C:\Python312`)
4. Add Scripts directory (e.g., `C:\Python312\Scripts`)

## Expected Test Results

If everything is configured correctly, you should see:
```
============================= test session starts =============================
...
collected XXX items

tests/test_account.py ........                                          [  X%]
tests/test_address.py ........                                          [  X%]
...

============================== XXX passed in X.XXs =============================
```

## Quick Test Command

```powershell
# One-liner to run all tests
cd "C:\Users\USER\OneDrive\Music\stellar\stellar-network-project" && uv run pytest -v tests/
```

## Next Steps After Tests Pass

1. Commit any fixes:
```powershell
git add .
git commit -m "Fix test issues and ensure all tests pass"
git push origin main
```

2. Enable GitHub Actions to run tests automatically

3. Check test coverage and aim for >80%

---

**Need Help?** Check the pytest documentation: https://docs.pytest.org/
