---
name: puml2svg
description: Install and configure the global `puml2svg` command that converts PlantUML (.puml) files to SVG from any directory. Run when user wants to set up puml2svg globally or when puml2svg is not found.
disable-model-invocation: true
allowed-tools: Bash, Write
---

Install `puml2svg` as a globally available command. Supports macOS, Linux, and Windows.

## Step 1 — Detect OS

Run:
```
uname -s 2>/dev/null || echo "Windows"
```

- Output starts with `Darwin` → macOS
- Output starts with `Linux` → Linux
- Command not found or `Windows` → Windows

## Step 2 — Install PlantUML

### macOS
Check if already installed: `which plantuml`

If not installed:
```bash
brew install plantuml
```

### Linux
Check if already installed: `which plantuml`

If not installed, try in order:
1. `sudo apt-get install -y plantuml` (Debian/Ubuntu)
2. `sudo dnf install -y plantuml` (Fedora/RHEL)
3. `sudo pacman -S --noconfirm plantuml` (Arch)
4. Fallback — download the JAR manually:
   ```bash
   curl -L -o /usr/local/bin/plantuml.jar https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar
   # Then create a wrapper (see Step 3 fallback below)
   ```

### Windows
Check if already installed: `where plantuml`

If not installed, try in order:
1. `winget install --id plantuml.plantuml -e`
2. `choco install plantuml -y` (if choco available)
3. `scoop install plantuml` (if scoop available)

## Step 3 — Create the global script

### macOS / Linux

Target path (in order of preference):
- `/opt/homebrew/bin/puml2svg` (macOS Apple Silicon — writable without sudo)
- `/usr/local/bin/puml2svg` (macOS Intel / Linux — may need sudo)
- `$HOME/.local/bin/puml2svg` (Linux fallback — ensure `~/.local/bin` is in PATH)

Script content:
```bash
#!/usr/bin/env bash
# Convert .puml files to .svg globally
# Usage: puml2svg [file.puml ...]  OR  puml2svg (converts all .puml in current dir)

if [[ $# -eq 0 ]]; then
  files=(*.puml)
  if [[ ! -e "${files[0]}" ]]; then
    echo "No .puml files found in current directory." >&2
    exit 1
  fi
else
  files=("$@")
fi

for f in "${files[@]}"; do
  echo "Converting: $f"
  plantuml -tsvg "$f"
done
```

After writing the file, make it executable:
```bash
chmod +x <target_path>
```

If the JAR fallback was used in Step 2, replace `plantuml -tsvg "$f"` with:
```bash
java -jar /usr/local/bin/plantuml.jar -tsvg "$f"
```

### Windows

Target directory: `%USERPROFILE%\.local\bin\`

1. Create directory if missing:
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.local\bin"
   ```

2. Write `puml2svg.bat` to that directory:
   ```batch
   @echo off
   if "%~1"=="" (
       for %%f in (*.puml) do (
           echo Converting: %%f
           plantuml -tsvg "%%f"
       )
   ) else (
       for %%f in (%*) do (
           echo Converting: %%f
           plantuml -tsvg "%%f"
       )
   )
   ```

3. Add the directory to PATH permanently (if not already there):
   ```powershell
   $path = [System.Environment]::GetEnvironmentVariable("PATH", "User")
   $newDir = "$env:USERPROFILE\.local\bin"
   if ($path -notlike "*$newDir*") {
       [System.Environment]::SetEnvironmentVariable("PATH", "$path;$newDir", "User")
       Write-Host "Added $newDir to PATH. Restart your terminal to apply."
   }
   ```

## Step 4 — Verify

Run:
```bash
which puml2svg   # Unix
where puml2svg   # Windows
```

Then confirm it works by creating a minimal test file and converting it:
```bash
echo '@startuml
A -> B: Hello
@enduml' > /tmp/test.puml
puml2svg /tmp/test.puml
ls /tmp/test.svg
```

If successful, report the install path and show the usage examples:
```
puml2svg                     # convert all .puml in current directory
puml2svg diagram.puml        # convert a single file
puml2svg a.puml b.puml       # convert multiple files
puml2svg ~/path/to/any.puml  # absolute path works from anywhere
```
