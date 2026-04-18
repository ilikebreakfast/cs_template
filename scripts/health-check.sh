#!/bin/bash
set -e

echo "============================================================"
echo "🩺  health-check.sh — Environment health check"
echo "============================================================"

PASS=0
WARN=0
FAIL=0

# Helper functions
check_python_import() {
    local pkg="$1"
    local display="${2:-$1}"
    if python -c "import $pkg" 2>/dev/null; then
        echo "  ✅  $display"
        PASS=$((PASS + 1))
    else
        echo "  ❌  $display (import failed)"
        FAIL=$((FAIL + 1))
    fi
}

check_cli() {
    local cmd="$1"
    local display="${2:-$cmd}"
    if output=$($cmd 2>&1 | head -1); then
        echo "  ✅  $display → $output"
        PASS=$((PASS + 1))
    else
        echo "  ❌  $display (not found or errored)"
        FAIL=$((FAIL + 1))
    fi
}

check_env_var() {
    local var="$1"
    local value="${!var:-}"
    if [ -n "$value" ]; then
        echo "  ✅  $var is set"
        PASS=$((PASS + 1))
    else
        echo "  ⚠️   $var is NOT set (optional but recommended)"
        WARN=$((WARN + 1))
    fi
}

# ---------------------------------------------------------------------------
# Python packages
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐍  Python package imports"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Core data science
check_python_import "numpy"
check_python_import "pandas"
check_python_import "scipy"
check_python_import "sklearn" "scikit-learn"

# Deep learning
check_python_import "torch"
check_python_import "tensorflow"

# Computer vision
check_python_import "cv2" "opencv (cv2)"

# OCR
check_python_import "pytesseract"
check_python_import "easyocr"

# AI APIs
check_python_import "anthropic"
check_python_import "openai"

# Databases
check_python_import "pyodbc"
check_python_import "sqlalchemy"
check_python_import "psycopg2"
check_python_import "pymongo"
check_python_import "redis"

# Web / HTTP
check_python_import "requests"
check_python_import "httpx"
check_python_import "bs4" "beautifulsoup4 (bs4)"

# Scraping / browser automation
check_python_import "selenium"
check_python_import "playwright"

# Web framework
check_python_import "fastapi"
check_python_import "uvicorn"

# Data formats
check_python_import "polars"
check_python_import "pyarrow"

# Visualisation
check_python_import "matplotlib"
check_python_import "plotly"
check_python_import "seaborn"

# Jupyter
check_python_import "jupyter"
check_python_import "ipykernel"

# ---------------------------------------------------------------------------
# CLI tools
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️   CLI tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_cli "claude --version" "claude"
check_cli "docker --version" "docker"
check_cli "jupyter --version" "jupyter"
check_cli "python --version" "python"
check_cli "node --version" "node"
check_cli "npm --version" "npm"
check_cli "tesseract --version" "tesseract"

# pyenv may not be on PATH in all shells; attempt gracefully
if command -v pyenv &>/dev/null; then
    check_cli "pyenv --version" "pyenv"
else
    # Try loading pyenv from common location
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv &>/dev/null; then
        check_cli "pyenv --version" "pyenv"
    else
        echo "  ⚠️   pyenv (not found on PATH — may need shell reload)"
        WARN=$((WARN + 1))
    fi
fi

# ---------------------------------------------------------------------------
# Environment variables
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑  Environment variables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_env_var "ANTHROPIC_API_KEY"
check_env_var "OPENAI_API_KEY"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
TOTAL=$((PASS + WARN + FAIL))
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊  Health check summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Total checks : $TOTAL"
echo "  ✅  Passed   : $PASS"
echo "  ⚠️   Warnings : $WARN"
echo "  ❌  Failed   : $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo "  ⚠️  Some checks failed. Review the output above."
    echo "     Run 'bash .devcontainer/scripts/install-python.sh' to reinstall."
else
    echo "  🎉 All required checks passed!"
fi
echo "============================================================"
