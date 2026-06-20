# Test Troubleshooting Guide

## Common Test Failures and Solutions

### 1. Import Errors

#### Symptom:
```
ModuleNotFoundError: No module named 'stellar_sdk'
```

#### Cause:
Package not installed in development mode

#### Solution:
```powershell
pip install -e .
```

---

### 2. Missing Test Dependencies

#### Symptom:
```
ModuleNotFoundError: No module named 'pytest'
ModuleNotFoundError: No module named 'pytest_asyncio'
```

#### Cause:
Development dependencies not installed

#### Solution:
```powershell
pip install -e ".[dev]"
```

---

### 3. Async Test Failures

#### Symptom:
```
RuntimeError: Event loop is closed
RuntimeError: no running event loop
```

#### Cause:
Async event loop issues with pytest

#### Solution:
Ensure pytest-asyncio is installed and configured:
```powershell
pip install pytest-asyncio
```

Check `pytest.ini` or `pyproject.toml` has:
```ini
[tool.pytest.ini_options]
asyncio_mode = "auto"
```

---

### 4. HTTP/Network Test Failures

#### Symptom:
```
ConnectionError: Failed to establish connection
requests.exceptions.ConnectionError
```

#### Cause:
Missing pytest-httpserver or network issues

#### Solution:
```powershell
pip install pytest-httpserver requests-mock aioresponses
```

For integration tests, ensure Docker is running:
```powershell
docker ps
```

---

### 5. XDR Type Errors

#### Symptom:
```
TypeError: XDR type mismatch
AttributeError: 'NoneType' object has no attribute 'to_xdr'
```

#### Cause:
XDR schema version mismatch or improper serialization

#### Solution:
Regenerate XDR files:
```powershell
make xdr-update
```

Or verify XDR imports:
```python
from stellar_sdk import xdr
```

---

### 6. Cryptography Errors

#### Symptom:
```
ModuleNotFoundError: No module named 'nacl'
ImportError: cannot import name 'PrivateKey' from 'nacl.signing'
```

#### Cause:
PyNaCl not installed or version mismatch

#### Solution:
```powershell
pip install pynacl>=1.4.0
```

On Windows, you may need Visual C++ Build Tools.

---

### 7. Pydantic Validation Errors

#### Symptom:
```
pydantic.ValidationError: validation error
TypeError: BaseModel.dict() got an unexpected keyword argument
```

#### Cause:
Pydantic v2 changes

#### Solution:
Ensure Pydantic v2 is installed:
```powershell
pip install "pydantic>=2.0.0"
```

Update code using old Pydantic v1 syntax:
- Change `.dict()` to `.model_dump()`
- Change `.json()` to `.model_dump_json()`

---

### 8. Type Checking Failures

#### Symptom:
```
error: Incompatible types in assignment
error: Argument 1 has incompatible type
```

#### Cause:
Type hints not matching actual types

#### Solution:
Run type checker separately:
```powershell
uv run pyright
uv run mypy -p stellar_sdk
```

Fix type annotations in source code.

---

### 9. Deprecation Warnings

#### Symptom:
```
DeprecationWarning: datetime.datetime.utcnow() is deprecated
```

#### Cause:
Using deprecated Python stdlib functions

#### Solution:
Replace deprecated functions:
```python
# Old
datetime.utcnow()

# New
datetime.now(timezone.utc)
```

---

### 10. Test Timeout

#### Symptom:
```
FAILED tests/test_soroban_server.py::test_name - Timeout
```

#### Cause:
Test taking too long or hanging

#### Solution:
Increase timeout in pytest.ini:
```ini
[tool.pytest.ini_options]
timeout = 300
```

Or skip slow tests:
```powershell
pytest -v tests/ -m "not slow"
```

---

## Debugging Steps

### 1. Run Tests with Verbose Output
```powershell
pytest -vv tests/ --tb=long
```

### 2. Run Single Test File
```powershell
pytest -v tests/test_keypair.py
```

### 3. Run Single Test Function
```powershell
pytest -v tests/test_keypair.py::test_can_create_random_keypair
```

### 4. Show Print Statements
```powershell
pytest -v tests/ -s
```

### 5. Stop at First Failure
```powershell
pytest -v tests/ -x
```

### 6. Run Last Failed Tests Only
```powershell
pytest -v tests/ --lf
```

### 7. Check Test Coverage
```powershell
pytest -v tests/ --cov=stellar_sdk --cov-report=html
start htmlcov/index.html
```

---

## Environment-Specific Issues

### Windows-Specific

#### Long Path Issues
Enable long paths in Windows:
```powershell
# Run as Administrator
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

#### Line Ending Issues
Configure git to handle line endings:
```powershell
git config --global core.autocrlf true
```

### Python Version Issues

Check Python version:
```powershell
python --version
```

If version is < 3.10, upgrade:
```powershell
winget install Python.Python.3.12
```

---

## Performance Optimization

### Parallel Test Execution
```powershell
pip install pytest-xdist
pytest -v tests/ -n auto
```

### Skip Slow Tests
```powershell
pytest -v tests/ -m "not slow and not integration"
```

### Cache Test Results
pytest caches by default. Clear cache if needed:
```powershell
pytest --cache-clear tests/
```

---

## Getting Help

### 1. Check GitHub Issues
Visit: https://github.com/frankosakwe/Lunar-forge/issues

### 2. Check Original Project Issues
Visit: https://github.com/StellarCN/py-stellar-base/issues

### 3. Stellar Documentation
Visit: https://developers.stellar.org/

### 4. Enable Debug Logging
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

---

## Test Checklist

Before running tests, ensure:

- [ ] Python 3.10+ installed
- [ ] pip updated: `python -m pip install --upgrade pip`
- [ ] Dependencies installed: `pip install -e ".[dev]"`
- [ ] Virtual environment activated (if using one)
- [ ] Current directory is project root
- [ ] No syntax errors: `python -m py_compile stellar_sdk/__init__.py`

---

## Quick Fix Commands

```powershell
# Complete reinstall
pip uninstall stellar-sdk -y
pip install -e ".[dev,aiohttp,shamir]"

# Clear caches
pytest --cache-clear
pip cache purge

# Verify installation
python -c "import stellar_sdk; print(stellar_sdk.__version__)"

# Run minimal test
pytest -v tests/test_keypair.py::test_can_create_random_keypair
```

---

## Expected Test Output

Successful test run should look like:
```
============================= test session starts =============================
platform win32 -- Python 3.12.x, pytest-8.x.x, pluggy-1.x.x
collected 450 items

tests/test_account.py ........                                          [  2%]
tests/test_address.py ..........                                        [  4%]
tests/test_asset.py ...........                                         [  7%]
...
============================== 450 passed in 45.23s ============================
```

---

**Still having issues?** Create a GitHub issue with:
1. Error message
2. Python version (`python --version`)
3. Installed packages (`pip list`)
4. Command that failed
5. Full error traceback
