#!/bin/bash
set -e

echo "============================================================"
echo "🐍  install-python.sh — Python environment setup"
echo "============================================================"

# ---------------------------------------------------------------------------
# 0. Remove stale Yarn apt repo baked into the base image (expired GPG key)
# ---------------------------------------------------------------------------
sudo rm -f /etc/apt/sources.list.d/yarn.list
sudo rm -f /etc/apt/sources.list.d/yarn.list.save

# ---------------------------------------------------------------------------
# 1. System packages
# ---------------------------------------------------------------------------
echo ""
echo "📦  [1/9] Updating apt package list..."
sudo apt-get update -y
echo "✅  apt-get update complete."

echo ""
echo "📦  [2/9] Installing system dependencies..."
sudo apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-eng \
    libtesseract-dev \
    poppler-utils \
    ghostscript \
    libgl1-mesa-glx \
    libglib2.0-0 \
    unixodbc \
    unixodbc-dev \
    odbcinst \
    chromium-driver \
    firefox-esr \
    build-essential \
    cmake \
    git-lfs \
    curl \
    wget \
    ffmpeg \
    libpq-dev \
    default-libmysqlclient-dev
echo "✅  System dependencies installed."

# ---------------------------------------------------------------------------
# 2. pyenv + Python 3.13 (secondary version only)
# ---------------------------------------------------------------------------
echo ""
echo "🔧  [3/9] Installing pyenv for secondary Python 3.13 support..."

if [ -d "$HOME/.pyenv" ]; then
    echo "ℹ️   pyenv already installed at $HOME/.pyenv — skipping install."
else
    curl https://pyenv.run | bash
    echo "✅  pyenv installed."
fi

# Add pyenv to .bashrc
if ! grep -q 'pyenv' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'BASHRC'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
BASHRC
    echo "✅  pyenv added to ~/.bashrc"
fi

# Add pyenv to .zshrc if zsh is present
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q 'pyenv' "$HOME/.zshrc" 2>/dev/null; then
        cat >> "$HOME/.zshrc" <<'ZSHRC'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
ZSHRC
        echo "✅  pyenv added to ~/.zshrc"
    fi
fi

# Load pyenv for the rest of this script
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null || true

# Install Python 3.13.0 as secondary (do NOT set as global)
if pyenv versions --bare 2>/dev/null | grep -q '^3\.13\.0$'; then
    echo "ℹ️   Python 3.13.0 already installed in pyenv — skipping."
else
    echo "🔧  Installing Python 3.13.0 via pyenv (this may take a few minutes)..."
    pyenv install 3.13.0
    echo "✅  Python 3.13.0 installed (NOT set as default)."
fi

echo ""
echo "ℹ️   To switch to Python 3.13 in this project run:"
echo "       pyenv local 3.13.0   (project-level only)"
echo "       make switch-313"
echo "    ⚠️  WARNING: torch, tensorflow, paddleocr, and cx-Oracle may not"
echo "    work correctly under Python 3.13. See README.md for details."

# ---------------------------------------------------------------------------
# 3. Upgrade pip
# ---------------------------------------------------------------------------
echo ""
echo "⬆️   [4/9] Upgrading pip..."
python -m pip install --upgrade pip
echo "✅  pip upgraded."

# ---------------------------------------------------------------------------
# 4. Install PyTorch separately (CPU wheel)
# ---------------------------------------------------------------------------
echo ""
echo "🔥  [5/9] Installing PyTorch (CPU)..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
echo "✅  PyTorch installed."

# ---------------------------------------------------------------------------
# 5. Install packages with known compatibility issues (soft failures)
# ---------------------------------------------------------------------------
echo ""
echo "⚙️   [6/9] Installing optional packages (failures are non-fatal)..."

echo "  → Installing tensorflow..."
pip install tensorflow || echo "⚠️  WARNING: tensorflow install failed — continuing."

echo "  → Installing paddleocr..."
pip install paddleocr || echo "⚠️  WARNING: paddleocr install failed — continuing."

echo "  → Installing surya-ocr..."
pip install surya-ocr || echo "⚠️  WARNING: surya-ocr install failed — continuing."

echo "  → Installing cx-Oracle..."
pip install cx-Oracle || echo "⚠️  WARNING: cx-Oracle install failed — continuing."

echo "✅  Optional package installs attempted."

# ---------------------------------------------------------------------------
# 6. Install main requirements.txt
# ---------------------------------------------------------------------------
echo ""
echo "📦  [7/9] Installing packages from requirements.txt..."
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo /workspaces/$(basename "$PWD"))"
pip install -r "$REPO_ROOT/requirements.txt"
echo "✅  requirements.txt packages installed."

# ---------------------------------------------------------------------------
# 7. Playwright browsers
# ---------------------------------------------------------------------------
echo ""
echo "🌐  [8/9] Installing Playwright browsers (chromium + firefox)..."
playwright install chromium firefox
echo "✅  Playwright browsers installed."

# ---------------------------------------------------------------------------
# 8. spaCy model
# ---------------------------------------------------------------------------
echo ""
echo "🔤  Downloading spaCy English model..."
python -m spacy download en_core_web_sm
echo "✅  spaCy en_core_web_sm downloaded."

# ---------------------------------------------------------------------------
# 9. Jupyter kernel
# ---------------------------------------------------------------------------
echo ""
echo "📓  [9/9] Registering Jupyter kernel..."
python -m ipykernel install --user --name=python3 --display-name="Python 3.11 (Codespace)"
echo "✅  Jupyter kernel registered as 'Python 3.11 (Codespace)'."

echo ""
echo "============================================================"
echo "✅  install-python.sh complete."
echo "============================================================"
