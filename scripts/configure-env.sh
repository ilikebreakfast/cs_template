#!/bin/bash
set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")"

echo "============================================================"
echo "⚙️   configure-env.sh — Environment configuration"
echo "============================================================"

# ---------------------------------------------------------------------------
# 1. Copy .env.example → .env if not present
# ---------------------------------------------------------------------------
echo ""
echo "📄  Checking for .env file..."
if [ -f "$REPO_ROOT/.env" ]; then
    echo "ℹ️   .env already exists — skipping copy."
else
    if [ -f "$REPO_ROOT/.env.example" ]; then
        cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
        echo "✅  Copied .env.example → .env"
        echo "    Edit $REPO_ROOT/.env to fill in your credentials."
    else
        echo "⚠️  .env.example not found — cannot create .env"
    fi
fi

# ---------------------------------------------------------------------------
# 2. Git hooks
# ---------------------------------------------------------------------------
echo ""
echo "🪝  Checking for .githooks/ directory..."
if [ -d "$REPO_ROOT/.githooks" ]; then
    git config --global core.hooksPath "$REPO_ROOT/.githooks"
    find "$REPO_ROOT/.githooks" -type f -name "*.sh" -exec chmod +x {} \;
    echo "✅  Git hooks configured from .githooks/"
else
    echo "ℹ️   No .githooks/ directory — skipping."
fi

# ---------------------------------------------------------------------------
# 3. Standard project folders
# ---------------------------------------------------------------------------
echo ""
echo "📁  Creating project folder structure..."
FOLDERS=(
    "data/raw"
    "data/processed"
    "models"
    "notebooks"
    "src"
    "tests"
    "logs"
)

for folder in "${FOLDERS[@]}"; do
    if [ -d "$REPO_ROOT/$folder" ]; then
        echo "    ✓ $folder (already exists)"
    else
        mkdir -p "$REPO_ROOT/$folder"
        echo "    ✅  Created $folder"
    fi
    GITKEEP="$REPO_ROOT/$folder/.gitkeep"
    [ -f "$GITKEEP" ] || touch "$GITKEEP"
done

echo ""
echo "============================================================"
echo "✅  configure-env.sh complete."
echo "============================================================"
