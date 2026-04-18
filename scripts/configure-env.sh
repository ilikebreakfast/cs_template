#!/bin/bash
set -e

echo "============================================================"
echo "⚙️   configure-env.sh — Environment configuration"
echo "============================================================"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")"

# ---------------------------------------------------------------------------
# 1. Copy .env.example → .env if .env does not already exist
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
        echo "⚠️  WARNING: .env.example not found — cannot create .env"
    fi
fi

# ---------------------------------------------------------------------------
# 2. Set up git hooks from .githooks/ if the folder exists
# ---------------------------------------------------------------------------
echo ""
echo "🪝  Checking for .githooks/ directory..."
if [ -d "$REPO_ROOT/.githooks" ]; then
    git config --global core.hooksPath "$REPO_ROOT/.githooks"
    chmod +x "$REPO_ROOT/.githooks/"* 2>/dev/null || true
    echo "✅  Git hooks configured from .githooks/"
else
    echo "ℹ️   No .githooks/ directory found — skipping git hook setup."
fi

# ---------------------------------------------------------------------------
# 3. Create standard project folders if they do not exist
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
done

# Add .gitkeep files so empty dirs are tracked by git
for folder in "${FOLDERS[@]}"; do
    GITKEEP="$REPO_ROOT/$folder/.gitkeep"
    if [ ! -f "$GITKEEP" ]; then
        touch "$GITKEEP"
    fi
done

echo ""
echo "============================================================"
echo "✅  configure-env.sh complete."
echo "============================================================"
