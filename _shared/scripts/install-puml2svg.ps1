# Install puml2svg as a global command (Windows)
# Usage: powershell -ExecutionPolicy Bypass -File install-puml2svg.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── 1. Install PlantUML ──────────────────────────────────────────────────────

if (-not (Get-Command plantuml -ErrorAction SilentlyContinue)) {
    Write-Host "Installing plantuml..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id plantuml.plantuml -e
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install plantuml -y
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop install plantuml
    } else {
        Write-Error "No supported package manager found (winget / choco / scoop). Install plantuml manually."
        exit 1
    }
} else {
    Write-Host "plantuml already installed: $((Get-Command plantuml).Source)"
}

# ── 2. Create script directory and add to PATH ───────────────────────────────

$dir = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$dir*") {
    [System.Environment]::SetEnvironmentVariable("PATH", "$userPath;$dir", "User")
    Write-Host "Added $dir to PATH. Restart terminal to apply."
}

# ── 3. Write puml2svg.bat ────────────────────────────────────────────────────

$bat = @'
@echo off
chcp 65001 >nul 2>nul
if "%~1"=="" (
    set FOUND=0
    for %%f in (*.puml) do (
        set FOUND=1
        echo Converting: %%f
        plantuml -tsvg "%%f"
    )
    if "%FOUND%"=="0" (
        echo No .puml files found in current directory. 1>&2
        exit /b 1
    )
) else (
    for %%f in (%*) do (
        echo Converting: %%f
        plantuml -tsvg "%%f"
    )
)
'@

# Write without BOM
$encoding = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$dir\puml2svg.bat", $bat, $encoding)
Write-Host "Installed: $dir\puml2svg.bat"

# ── 4. Verify ────────────────────────────────────────────────────────────────

$testFile = "$env:TEMP\_puml2svg_test.puml"
"@startuml`nA -> B: Hello`n@enduml" | Set-Content $testFile
& plantuml -tsvg $testFile
Remove-Item $testFile, ($testFile -replace '\.puml$', '.svg') -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "puml2svg is ready. Usage:"
Write-Host "  puml2svg                      # convert all .puml in current directory"
Write-Host "  puml2svg diagram.puml         # convert a single file"
Write-Host "  puml2svg C:\any\path\file.puml  # absolute path works from anywhere"
