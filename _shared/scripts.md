# Automation Script Conventions

## General Rules

All commands that need to be executed repeatedly (build, test, start, deploy, etc.) **must be generated as script files under `scripts/`**, providing both `.bat` (Windows) and `.sh` (Unix) versions.

Each script must include comments explaining its purpose and prerequisites.

## .bat File Conventions (Windows)

**Must include the following at the top** to fix UTF-8 encoding issues on Windows:

```bat
@echo off
chcp 65001 >nul
```

- Files must be saved in **UTF-8 encoding**
- Without `chcp 65001`, Chinese paths and output will cause garbled text or build errors (Windows defaults to GBK)

## .sh File Conventions (Unix)

**Must include the following at the top**:

```bash
#!/bin/bash
set -e
```

- `set -e` ensures immediate exit on any command failure, preventing silent errors
- After creation, set executable permission: `chmod +x scripts/*.sh`

## Standard Script Inventory

| Filename | Purpose |
|:---|:---|
| `build.bat` + `build.sh` | Build/compile |
| `run.bat` + `run.sh` | Start/run |
| `test.bat` + `test.sh` | Run all tests (unit + integration) |
| `test-e2e.bat` + `test-e2e.sh` | Run end-to-end tests (web projects) |
| Additional as needed | |

## Examples

**build.bat:**
```bat
@echo off
chcp 65001 >nul
REM Build the project
REM Prerequisite: Python 3.10+

python -m py_compile backend/src/main.py
echo Build completed.
```

**build.sh:**
```bash
#!/bin/bash
set -e
# Build the project
# Prerequisite: Python 3.10+

python -m py_compile backend/src/main.py
echo "Build completed."
```
