#!/bin/bash
set -e

echo "============================================================"
echo "🩺  health-check.sh — Environment health check"
echo "============================================================"

PASS=0
WARN=0
FAIL=0

check_cli() {
    local cmd="$1"
    local display="${2:-$cmd}"
    local bin="${cmd%% *}"
    if command -v "$bin" &>/dev/null; then
        local output
        output=$($cmd 2>&1 | head -1)
        echo "  ✅  $display → $output"
        PASS=$((PASS + 1))
    else
        echo "  ❌  $display (not found)"
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
# Python packages — all imports in a single Python process (fast)
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐍  Python package imports"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

IMPORT_OUTPUT=$(python3 - <<'PYEOF'
checks = [
    ("numpy",       "numpy"),
    ("pandas",      "pandas"),
    ("scipy",       "scipy"),
    ("sklearn",     "scikit-learn"),
    ("torch",       "torch"),
    ("tensorflow",  "tensorflow"),
    ("cv2",         "opencv (cv2)"),
    ("pytesseract", "pytesseract"),
    ("easyocr",     "easyocr"),
    ("anthropic",   "anthropic"),
    ("openai",      "openai"),
    ("pyodbc",      "pyodbc"),
    ("sqlalchemy",  "sqlalchemy"),
    ("psycopg2",    "psycopg2"),
    ("pymongo",     "pymongo"),
    ("redis",       "redis"),
    ("requests",    "requests"),
    ("httpx",       "httpx"),
    ("bs4",         "beautifulsoup4 (bs4)"),
    ("selenium",    "selenium"),
    ("playwright",  "playwright"),
    ("fastapi",     "fastapi"),
    ("uvicorn",     "uvicorn"),
    ("polars",      "polars"),
    ("pyarrow",     "pyarrow"),
    ("matplotlib",  "matplotlib"),
    ("plotly",      "plotly"),
    ("seaborn",     "seaborn"),
    ("jupyter",     "jupyter"),
    ("ipykernel",   "ipykernel"),
]

passed = failed = 0
for module, display in checks:
    try:
        __import__(module)
        print(f"  \u2705  {display}")
        passed += 1
    except ImportError:
        print(f"  \u274c  {display} (import failed)")
        failed += 1

print(f"__COUNTS__ {passed} {failed}")
PYEOF
)

echo "$IMPORT_OUTPUT" | grep -v "^__COUNTS__"
COUNTS=$(echo "$IMPORT_OUTPUT" | grep "^__COUNTS__")
PY_PASS=$(echo "$COUNTS" | awk '{print $2}')
PY_FAIL=$(echo "$COUNTS" | awk '{print $3}')
PASS=$((PASS + PY_PASS))
FAIL=$((FAIL + PY_FAIL))

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

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
    check_cli "pyenv --version" "pyenv"
else
    echo "  ⚠️   pyenv (not found — run: source ~/.bashrc)"
    WARN=$((WARN + 1))
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
    echo "  ⚠️  Some checks failed. Run: bash .devcontainer/scripts/install-python.sh"
    echo "============================================================"
    exit 1
else
    echo "  🎉 All required checks passed!"
    echo "============================================================"
fi
