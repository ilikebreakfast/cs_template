#!/bin/bash
set -e

echo "============================================================"
echo "🤖  configure-claude.sh — Claude Code CLI setup"
echo "============================================================"

# ---------------------------------------------------------------------------
# Pre-flight: ensure npm is available
# ---------------------------------------------------------------------------
if ! command -v npm &>/dev/null; then
    echo "❌  npm not found. The Node.js feature may not have installed correctly."
    echo "    Ensure 'ghcr.io/devcontainers/features/node:1' is in devcontainer.json"
    exit 1
fi

# ---------------------------------------------------------------------------
# 1. Install Claude Code CLI if not present
# ---------------------------------------------------------------------------
if command -v claude &>/dev/null; then
    echo "ℹ️   claude CLI already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
    echo "    Skipping install."
else
    echo ""
    echo "📦  Installing Claude Code CLI via npm..."
    npm install -g @anthropic-ai/claude-code
    echo "✅  Claude Code CLI installed."
fi

# ---------------------------------------------------------------------------
# 2. Verify installation
# ---------------------------------------------------------------------------
echo ""
CLAUDE_VERSION="$(claude --version 2>/dev/null || echo 'unknown')"
if [ "$CLAUDE_VERSION" = "unknown" ]; then
    echo "⚠️  claude installed but version check failed — may be a PATH issue."
else
    echo "✅  claude version: $CLAUDE_VERSION"
fi

# ---------------------------------------------------------------------------
# 3. Check ANTHROPIC_API_KEY
# ---------------------------------------------------------------------------
echo ""
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    echo "✅  ANTHROPIC_API_KEY is set."
else
    echo "⚠️  WARNING: ANTHROPIC_API_KEY is not set."
    echo ""
    echo "    To add it as a GitHub Codespace secret:"
    echo "    1. Go to github.com → Avatar → Settings"
    echo "    2. Left sidebar → Codespaces"
    echo "    3. New secret → Name: ANTHROPIC_API_KEY"
    echo "    4. Select which repos can access it → Add secret"
    echo "    5. Rebuild this Codespace to pick up the secret"
    echo ""
    echo "    Get your API key at: https://console.anthropic.com/"
fi

echo ""
echo "============================================================"
echo "✅  configure-claude.sh complete."
echo "============================================================"
