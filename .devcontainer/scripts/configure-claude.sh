#!/bin/bash
set -e

echo "============================================================"
echo "🤖  configure-claude.sh — Claude Code CLI setup"
echo "============================================================"

# ---------------------------------------------------------------------------
# 1. Check if claude CLI is already installed
# ---------------------------------------------------------------------------
if command -v claude &>/dev/null; then
    echo "ℹ️   claude CLI is already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
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
echo "🔍  Verifying claude CLI..."
CLAUDE_VERSION="$(claude --version 2>/dev/null || echo 'unknown')"
echo "    claude version: $CLAUDE_VERSION"

# ---------------------------------------------------------------------------
# 3. Check ANTHROPIC_API_KEY
# ---------------------------------------------------------------------------
echo ""
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    echo "✅  ANTHROPIC_API_KEY is set."
else
    echo "⚠️  WARNING: ANTHROPIC_API_KEY is not set."
    echo ""
    echo "    To add your API key as a GitHub Codespace secret:"
    echo ""
    echo "    1. Go to https://github.com"
    echo "    2. Click your avatar in the top-right corner"
    echo "    3. Select 'Settings' from the dropdown menu"
    echo "    4. In the left sidebar, click 'Codespaces'"
    echo "    5. Under 'Codespaces secrets', click 'New secret'"
    echo "    6. Set Name to: ANTHROPIC_API_KEY"
    echo "    7. Paste your Anthropic API key as the Value"
    echo "    8. Under 'Repository access', select the repositories"
    echo "       that should have access to this secret"
    echo "    9. Click 'Add secret'"
    echo "   10. Rebuild or restart your Codespace for the secret"
    echo "       to become available."
    echo ""
    echo "    Get your API key at: https://console.anthropic.com/"
fi

echo ""
echo "============================================================"
echo "✅  configure-claude.sh complete."
echo "============================================================"
