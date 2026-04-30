# Python 3.11 Codespace Template

A production-ready GitHub Codespace template for data science, machine learning, OCR, web scraping, and API development. Python 3.11 base, tiered packages, Jupyter Lab, PostgreSQL, Redis, Claude Code, and a full VS Code extension suite.

---

## What's Included

### Python Packages — Tiered Installation

Packages are split into three tiers so you only install what you need:

| Tier | File | Contents |
|---|---|---|
| **core** | `requirements/core.txt` | numpy, pandas, scipy, scikit-learn, requests, fastapi, anthropic, openai, jupyter, pytest, pydantic, and ~15 more always-needed packages |
| **ml** | `requirements/ml.txt` | torch (CPU), transformers, sentence-transformers, xgboost, lightgbm, optuna, mlflow, opencv, shap, and more |
| **extras** | `requirements/extras.txt` | pytesseract, easyocr, selenium, playwright, pyodbc, pymongo, polars, pyarrow, bokeh, spacy, prefect, and more |

By default all three tiers are installed. To install selectively:

```bash
INSTALL_TIERS=core make setup          # core only
INSTALL_TIERS=core,ml make setup       # core + ML, no extras
make install-core                      # add core to existing env
make install-extras                    # add extras to existing env
```

### VS Code Extensions

- Python, Pylance, Black Formatter, Pylint, Debugpy
- Jupyter, Jupyter Keymap, Jupyter Renderers, Data Wrangler
- GitHub Copilot, GitHub Copilot Chat
- Claude Code (Anthropic)
- Docker, Remote Containers, Makefile Tools
- GitHistory, GitLens
- SQLTools (PostgreSQL driver)
- Rainbow CSV, PDF viewer, YAML, AutoDocstring, Code Spell Checker

### Docker Services

| Service | Image | Port |
|---|---|---|
| PostgreSQL | postgres:15 | 5432 |
| Redis | redis:7-alpine | 6379 |

### System Tools

- tesseract-ocr, poppler-utils, ghostscript
- chromium-driver, firefox-esr
- unixodbc, ffmpeg, cmake, git-lfs
- Node.js 18, pyenv

---

## Quick Start: GitHub Codespace

1. Open this repository on GitHub.com
2. Click the green **Code** button near the top right
3. Select the **Codespaces** tab
4. Click **Create codespace on main**
5. GitHub builds the container (~5 min first time); `setup.sh` runs automatically
6. Run `make health` to verify everything is working

**Tip:** Pre-build via *Repository Settings → Codespaces → Set up prebuild* for instant startup.

---

## Quick Start: Local — VS Code + Docker

Requirements: VS Code, Docker Desktop, Dev Containers extension.

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
code .
```

When VS Code opens: **Reopen in Container** notification → click it.  
Or: `Ctrl+Shift+P` → **Dev Containers: Reopen in Container**.

---

## Quick Start: Local — Without Docker

Requirements: Python 3.11, Node.js 18.

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

python3.11 -m venv .venv
source .venv/bin/activate

pip install --upgrade pip
bash .devcontainer/scripts/install-python.sh
bash scripts/configure-env.sh
```

On Ubuntu/Debian, install system deps first:
```bash
sudo apt-get install tesseract-ocr unixodbc-dev chromium-driver
```

---

## Setting ANTHROPIC_API_KEY as a Codespace Secret

1. Go to **github.com** → your avatar → **Settings**
2. Left sidebar → **Codespaces**
3. Under *Codespaces secrets* → **New secret**
4. **Name:** `ANTHROPIC_API_KEY`, **Value:** your key
5. Select which repos can access it → **Add secret**
6. Rebuild: `Ctrl+Shift+P` → **Codespaces: Rebuild Container**

---

## Python Version Management

### Default: Python 3.11

The base image is `mcr.microsoft.com/devcontainers/python:3.11-bullseye`. Python 3.11 is the system default and is recommended for all ML workloads.

### Secondary: Python 3.13 (via pyenv)

Python 3.13.0 is installed as a secondary version. It is **not** set as default.

```bash
make switch-313     # switch this project to 3.13
make switch-311     # switch back to 3.11
make python-version # list all installed versions
```

### Compatibility Warnings for Python 3.13

| Package | Status |
|---|---|
| `torch` / torchvision / torchaudio | May fail — wheels lag behind new CPython releases |
| `tensorflow` | Often unsupported on latest CPython |
| `paddleocr` | Known C-extension issues on 3.13 |
| `cx-Oracle` | Oracle driver; 3.13 support may be absent |

Use Python 3.11 for any project that depends on the above.

---

## Package Version Management

The `requirements/*.in` files are the human-editable source of truth (unpinned). The `requirements/*.txt` files are what get installed.

**To lock exact versions** (recommended before sharing or deploying):

```bash
make pin-deps
git add requirements/*.txt
git commit -m "chore: pin dependencies"
```

This runs `pip-compile` on each `.in` file and writes locked `.txt` files. Re-run whenever you add or change packages in a `.in` file.

**To add a new package:**

```bash
# 1. Add it to the appropriate .in file
echo "httpx" >> requirements/core.in

# 2. Regenerate the lock
make pin-deps

# 3. Install it
make install-core
```

---

## Available Make Commands

| Command | Description |
|---|---|
| `make setup` | Full setup (all tiers, Claude CLI, env, health check) |
| `make install-core` | Install core packages only |
| `make install-ml` | Install ML/DL packages |
| `make install-extras` | Install OCR/scraping/DB packages |
| `make pin-deps` | Lock versions with pip-compile |
| `make jupyter` | Start Jupyter Lab at `http://localhost:8888` |
| `make test` | Run pytest with coverage |
| `make lint` | Format with black + lint with pylint |
| `make format` | Format with black only |
| `make clean` | Remove `__pycache__`, `.pyc`, `.ipynb_checkpoints`, `*.log` |
| `make docker-up` | Start PostgreSQL and Redis |
| `make docker-down` | Stop containers (data preserved) |
| `make docker-reset` | Wipe volumes and restart |
| `make health` | Run environment health check |
| `make python-version` | List pyenv Python versions |
| `make switch-313` | Switch project to Python 3.13.0 |
| `make switch-311` | Switch project back to Python 3.11 |

---

## Docker Services

### PostgreSQL

| Setting | Value |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| User | `devuser` (override via `POSTGRES_USER`) |
| Password | `password` (override via `POSTGRES_PASSWORD`) |
| Database | `devdb` (override via `POSTGRES_DB`) |
| Connection string | `postgresql://devuser:password@localhost:5432/devdb` |

### Redis

| Setting | Value |
|---|---|
| Host | `localhost` |
| Port | `6379` |
| URL | `redis://localhost:6379/0` |

Start both with `make docker-up`.

---

## Folder Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json
│   └── scripts/
│       ├── common.sh              # Shared REPO_ROOT utility (sourced by other scripts)
│       ├── setup.sh               # Main orchestrator (postCreateCommand)
│       ├── install-python.sh      # System deps, pyenv, pip tiers
│       └── configure-claude.sh    # Claude Code CLI
├── requirements/
│   ├── core.in                    # Edit this to add core packages
│   ├── core.txt                   # Installed version (run make pin-deps to lock)
│   ├── ml.in                      # Edit this for ML/DL packages
│   ├── ml.txt
│   ├── extras.in                  # Edit this for OCR/scraping/DB packages
│   └── extras.txt
├── requirements.txt               # Convenience: installs all three tiers
├── scripts/
│   ├── configure-env.sh
│   ├── health-check.sh
│   ├── install-deps.sh            # Reserved for project-specific deps
│   └── seed-db.sh
├── data/raw/                      # gitignored
├── data/processed/                # gitignored
├── models/                        # gitignored
├── notebooks/
├── src/
├── tests/
├── logs/                          # gitignored
├── docker-compose.yml
├── Makefile
├── .env.example
├── .gitignore
└── README.md
```

---

## Troubleshooting

### OpenCV `libgl` error

```
ImportError: libGL.so.1: cannot open shared object file
```

Use `opencv-python-headless` instead of `opencv-python`:
```bash
pip uninstall opencv-python && pip install opencv-python-headless
```

### pyodbc — unixodbc missing

```bash
sudo apt-get install -y unixodbc unixodbc-dev odbcinst
pip install pyodbc
```

### Tesseract not found

```bash
which tesseract && tesseract --version
# If missing: sudo apt-get install tesseract-ocr tesseract-ocr-eng
```

### Playwright browsers not installed

```bash
playwright install chromium firefox
```

### ANTHROPIC_API_KEY not set

Add to `.env` and load it:
```python
from dotenv import load_dotenv
load_dotenv()
```
Or set it as a Codespace secret (see above).

### torch install failing on Python 3.13

Wheels lag behind new CPython releases. Switch back: `make switch-311`.

### apt-get update fails (Yarn GPG error)

```bash
sudo rm -f /etc/apt/sources.list.d/yarn.list
sudo apt-get update
```
This is handled automatically by `install-python.sh`.

---

## Contributing

1. Fork → feature branch → `make lint` + `make test` → PR against `main`
2. Keep scripts idempotent
3. Use `|| echo "warning"` for optional installs
4. Update `requirements/*.in` (not `.txt`) for new packages, then run `make pin-deps`
5. Update this README for new tools or env vars
