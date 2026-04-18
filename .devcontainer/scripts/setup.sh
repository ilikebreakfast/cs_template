#!/bin/bash
set -e

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          🚀  Codespace Setup — Starting                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ---------------------------------------------------------------------------
# Resolve repository root
# ---------------------------------------------------------------------------
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo /workspaces/$(basename "$PWD"))"
export REPO_ROOT
echo "📁  Repository root: $REPO_ROOT"
echo ""

# ---------------------------------------------------------------------------
# Step 1: Python environment
# ---------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐍  Step 1/4: Python environment setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$REPO_ROOT/.devcontainer/scripts/install-python.sh"

# ---------------------------------------------------------------------------
# Step 2: Claude Code CLI
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖  Step 2/4: Claude Code CLI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$REPO_ROOT/.devcontainer/scripts/configure-claude.sh"

# ---------------------------------------------------------------------------
# Step 3: Environment configuration
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️   Step 3/4: Environment configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$REPO_ROOT/scripts/configure-env.sh"

# ---------------------------------------------------------------------------
# Step 4: Health check
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🩺  Step 4/4: Health check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$REPO_ROOT/scripts/health-check.sh"

# ---------------------------------------------------------------------------
# Completion banner
# ---------------------------------------------------------------------------
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          ✅  Codespace Setup — Complete!                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Available commands:"
echo ""
echo "    make jupyter        → Start Jupyter Lab on port 8888"
echo "    make test           → Run pytest with coverage"
echo "    make lint           → Run black + pylint"
echo "    make docker-up      → Start Postgres + Redis containers"
echo "    claude              → Open Claude Code AI assistant"
echo ""
echo "  Python info:"
echo "    python --version    → $(python --version 2>&1)"
echo "    pyenv versions      → List all installed Python versions"
echo ""
echo "  Switch Python version:"
echo "    make switch-313     → Switch project to Python 3.13.0"
echo "    make switch-311     → Switch project back to Python 3.11"
echo ""
echo "  ⚠️  NOTE: Python 3.11 is the default. torch, tensorflow,"
echo "  paddleocr, and cx-Oracle may not work on Python 3.13."
echo ""
