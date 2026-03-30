#!/usr/bin/env bash
# Install puml2svg as a global command (macOS / Linux)
# Usage: bash install-puml2svg.sh

set -e

# ── 1. Install PlantUML ──────────────────────────────────────────────────────

if ! command -v plantuml &>/dev/null; then
  OS="$(uname -s)"
  if [[ "$OS" == "Darwin" ]]; then
    echo "Installing plantuml via Homebrew..."
    brew install plantuml
  elif [[ "$OS" == "Linux" ]]; then
    if command -v apt-get &>/dev/null; then
      sudo apt-get install -y plantuml
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y plantuml
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm plantuml
    else
      echo "ERROR: Unsupported package manager. Install plantuml manually." >&2
      exit 1
    fi
  else
    echo "ERROR: Unsupported OS: $OS" >&2
    exit 1
  fi
else
  echo "plantuml already installed: $(which plantuml)"
fi

# ── 2. Choose install path ───────────────────────────────────────────────────

if [[ -w /opt/homebrew/bin ]]; then
  INSTALL_PATH="/opt/homebrew/bin/puml2svg"       # macOS Apple Silicon (no sudo)
elif [[ -w /usr/local/bin ]]; then
  INSTALL_PATH="/usr/local/bin/puml2svg"           # macOS Intel / Linux
else
  INSTALL_PATH="$HOME/.local/bin/puml2svg"         # fallback (no sudo)
  mkdir -p "$HOME/.local/bin"
  # Warn if not in PATH
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "WARNING: $HOME/.local/bin is not in PATH. Add it to your shell profile:"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
  fi
fi

# ── 3. Write script ──────────────────────────────────────────────────────────

cat > "$INSTALL_PATH" << 'EOF'
#!/usr/bin/env bash
# Convert .puml files to .svg
# Usage: puml2svg [file.puml ...]  OR  puml2svg (converts all .puml in current dir)
if [[ $# -eq 0 ]]; then
  files=(*.puml)
  [[ ! -e "${files[0]}" ]] && { echo "No .puml files found in current directory." >&2; exit 1; }
else
  files=("$@")
fi
for f in "${files[@]}"; do
  echo "Converting: $f"
  plantuml -tsvg "$f"
done
EOF

chmod +x "$INSTALL_PATH"
echo "Installed: $INSTALL_PATH"

# ── 4. Verify ────────────────────────────────────────────────────────────────

echo "@startuml
A -> B: Hello
@enduml" > /tmp/_puml2svg_test.puml
puml2svg /tmp/_puml2svg_test.puml
rm -f /tmp/_puml2svg_test.puml /tmp/_puml2svg_test.svg

echo ""
echo "puml2svg is ready. Usage:"
echo "  puml2svg                      # convert all .puml in current directory"
echo "  puml2svg diagram.puml         # convert a single file"
echo "  puml2svg ~/any/path/file.puml # absolute path works from anywhere"
