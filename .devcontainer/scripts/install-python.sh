#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "============================================================"
echo "🐍  install-python.sh — Python environment setup"
echo "============================================================"

# ---------------------------------------------------------------------------
# 0. Remove stale Yarn apt repo baked into the base image (expired GPG key)
# ---------------------------------------------------------------------------
sudo rm -f /etc/apt/sources.list.d/yarn.list
sudo rm -f /etc/apt/sources.list.d/yarn.list.save

# ---------------------------------------------------------------------------
# 1. System packages (skips already-installed packages)
# ---------------------------------------------------------------------------
echo ""
echo "📦  [1/9] Checking system packages..."

APT_PACKAGES=(
    tesseract-ocr
    tesseract-ocr-eng
    libtesseract-dev
    poppler-utils
    ghostscript
    libgl1-mesa-glx
    libglib2.0-0
    unixodbc
    unixodbc-dev
    odbcinst
    chromium-driver
    firefox-esr
    build-essential
    cmake
    git-lfs
    curl
    wget
    ffmpeg
    libpq-dev
    default-libmysqlclient-dev
)

MISSING=()
for pkg in "${APT_PACKAGES[@]}"; do
    dpkg -s "$pkg" &>/dev/null || MISSING+=("$pkg")
done

if [ "${#MISSING[@]}" -gt 0 ]; then
    echo "  Installing missing packages: ${MISSING[*]}"
    sudo apt-get update -y || {
        echo "❌  apt-get update failed."
        echo "    Try: sudo rm -f /etc/apt/sources.list.d/yarn.list && sudo apt-get update"
        exit 1
    }
    sudo apt-get install -y "${MISSING[@]}"
    echo "✅  System packages installed."
else
    echo "ℹ️   All system packages already installed — skipping apt."
fi

# ---------------------------------------------------------------------------
# 2. pyenv + Python 3.13 (secondary version only)
# ---------------------------------------------------------------------------
echo ""
echo "🔧  [2/9] Checking pyenv..."

if [ -d "$HOME/.pyenv" ]; then
    echo "ℹ️   pyenv already installed — skipping."
else
    echo "  Installing pyenv..."
    curl https://pyenv.run | bash
    echo "✅  pyenv installed."
fi

if ! grep -q 'PYENV_ROOT' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'BASHRC'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
BASHRC
fi

if [ -f "$HOME/.zshrc" ] && ! grep -q 'PYENV_ROOT' "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" <<'ZSHRC'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
ZSHRC
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null || true

if pyenv versions --bare 2>/dev/null | grep -q '^3\.13\.0$'; then
    echo "ℹ️   Python 3.13.0 already in pyenv — skipping."
else
    echo "🔧  Installing Python 3.13.0 via pyenv..."
    pyenv install 3.13.0
    echo "✅  Python 3.13.0 installed (NOT set as default)."
fi

echo ""
echo "ℹ️   Switch Python versions with: make switch-313 / make switch-311"
echo "    ⚠️  torch, tensorflow, paddleocr, cx-Oracle may not work on 3.13."

# ---------------------------------------------------------------------------
# 3. Upgrade pip
# ---------------------------------------------------------------------------
echo ""
echo "⬆️   [3/9] Upgrading pip..."
python -m pip install --upgrade pip
echo "✅  pip upgraded."

# ---------------------------------------------------------------------------
# 4. Install PyTorch (CPU) — guarded
# ---------------------------------------------------------------------------
echo ""
echo "🔥  [4/9] Checking PyTorch..."
if python -c "import torch" 2>/dev/null; then
    echo "ℹ️   torch already installed — skipping."
else
    echo "  Installing PyTorch CPU wheel..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    echo "✅  PyTorch installed."
fi

# ---------------------------------------------------------------------------
# 5. Optional packages with known compatibility issues (soft failures)
# ---------------------------------------------------------------------------
echo ""
echo "⚙️   [5/9] Installing optional packages (failures are non-fatal)..."

echo "  → tensorflow..."
pip install tensorflow || echo "⚠️  tensorflow install failed — continuing."

echo "  → paddleocr..."
pip install paddleocr || echo "⚠️  paddleocr install failed — continuing."

echo "  → surya-ocr..."
pip install surya-ocr || echo "⚠️  surya-ocr install failed — continuing."

echo "  → cx-Oracle..."
pip install cx-Oracle || echo "⚠️  cx-Oracle install failed — continuing."

echo "✅  Optional installs attempted."

# ---------------------------------------------------------------------------
# 6. Install tiered requirements
# ---------------------------------------------------------------------------
echo ""
echo "📦  [6/9] Installing Python packages (tiered)..."

# Override with: INSTALL_TIERS=core make setup
TIERS="${INSTALL_TIERS:-core,ml,extras}"

for tier in ${TIERS//,/ }; do
    TIER_FILE="$REPO_ROOT/requirements/${tier}.txt"
    if [ -f "$TIER_FILE" ]; then
        echo "  → Installing $tier tier..."
        pip install -r "$TIER_FILE"
        echo "  ✅  $tier done."
    else
        echo "  ⚠️  $TIER_FILE not found — skipping $tier tier."
    fi
done

echo "✅  Package installation complete."

# ---------------------------------------------------------------------------
# 7. Playwright browsers — guarded
# ---------------------------------------------------------------------------
echo ""
echo "🌐  [7/9] Checking Playwright browsers..."
if python -c "from playwright.sync_api import sync_playwright" 2>/dev/null && \
   [ -d "$HOME/.cache/ms-playwright" ] && [ "$(ls -A "$HOME/.cache/ms-playwright" 2>/dev/null)" ]; then
    echo "ℹ️   Playwright browsers already installed — skipping."
else
    echo "  Installing Playwright browsers (chromium + firefox)..."
    playwright install chromium firefox
    echo "✅  Playwright browsers installed."
fi

# ---------------------------------------------------------------------------
# 8. spaCy model — guarded
# ---------------------------------------------------------------------------
echo ""
echo "🔤  [8/9] Checking spaCy model..."
if python -c "import spacy; spacy.load('en_core_web_sm')" 2>/dev/null; then
    echo "ℹ️   en_core_web_sm already installed — skipping."
else
    echo "  Downloading spaCy en_core_web_sm..."
    python -m spacy download en_core_web_sm
    echo "✅  spaCy model downloaded."
fi

# ---------------------------------------------------------------------------
# 9. Jupyter kernel
# ---------------------------------------------------------------------------
echo ""
echo "📓  [9/9] Registering Jupyter kernel..."
python -m ipykernel install --user --name=python3 --display-name="Python 3.11 (Codespace)"
echo "✅  Jupyter kernel registered."

echo ""
echo "============================================================"
echo "✅  install-python.sh complete."
echo "============================================================"
