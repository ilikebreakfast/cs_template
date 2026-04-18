# Python 3.11 Codespace Template

A production-ready GitHub Codespace template for data science, machine learning, OCR, web scraping, and API development. Batteries included: Python 3.11 base, 80+ packages, Jupyter Lab, PostgreSQL, Redis, Claude Code, and a full VS Code extension suite.

---

## What's Included

### Python Packages (80+)

| Category | Packages |
|---|---|
| ML Core | numpy, pandas, scipy, scikit-learn, xgboost, lightgbm, catboost, optuna, mlflow, shap |
| Deep Learning | torch (CPU), tensorflow, onnx, einops, timm, accelerate |
| HuggingFace | transformers, sentence-transformers, datasets, huggingface-hub |
| Computer Vision | opencv-python-headless, Pillow, imageio, scikit-image |
| OCR / Docs | pytesseract, easyocr, paddleocr, pdf2image, pdfplumber, pymupdf, python-doctr, surya-ocr |
| NLP | nltk, spacy, gensim, textblob |
| Web Scraping | requests, httpx, aiohttp, beautifulsoup4, selenium, playwright, scrapy, cloudscraper |
| Databases | pyodbc, sqlalchemy, psycopg2, pymysql, pymongo, redis, cx-Oracle |
| Data Formats | openpyxl, pyarrow, polars, fastparquet, h5py, orjson, msgpack |
| Validation | pydantic, great-expectations, pandera |
| Visualisation | matplotlib, seaborn, plotly, bokeh, altair, folium |
| API / Web | fastapi, uvicorn, anthropic, openai, python-dotenv |
| Automation | prefect, celery |
| Testing | pytest, pytest-cov, pytest-asyncio |
| Utilities | tqdm, rich, loguru, click, typer, tenacity, faker, hypothesis |

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
4. Click **Create codespace on main** (or your chosen branch)
5. GitHub will build the container — this takes 5–10 minutes on first build
6. When the editor opens, `setup.sh` runs automatically via `postCreateCommand`
7. The terminal shows progress; when complete run `make health` to verify

**Tip:** Pre-build the Codespace via *Repository Settings → Codespaces → Set up prebuild* to make it open in under 30 seconds.

---

## Quick Start: Local — VS Code + Docker

Requirements: VS Code, Docker Desktop, Dev Containers extension.

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
code .
```

When VS Code opens, a notification appears: **Reopen in Container**. Click it.  
If it doesn't appear: `Ctrl+Shift+P` → **Dev Containers: Reopen in Container**.

The container builds and `setup.sh` runs. Everything else is identical to the Codespace experience.

---

## Quick Start: Local — Without Docker

Requirements: Python 3.11, Node.js 18.

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

python3.11 -m venv .venv
source .venv/bin/activate          # Linux / macOS
# .venv\Scripts\activate           # Windows

pip install --upgrade pip
bash .devcontainer/scripts/install-python.sh
bash scripts/configure-env.sh
```

Some system packages (tesseract, unixodbc, chromium-driver) need to be installed manually. On Ubuntu/Debian: `sudo apt-get install tesseract-ocr unixodbc-dev chromium-driver`.

---

## Setting ANTHROPIC_API_KEY as a Codespace Secret

Codespace secrets are injected as environment variables at container startup. They are never stored in the repo.

1. Go to **github.com** and sign in
2. Click your **avatar** (top right corner) → **Settings**
3. In the left sidebar scroll down to **Codespaces**
4. Under *Codespaces secrets*, click **New secret**
5. **Name:** `ANTHROPIC_API_KEY`
6. **Value:** paste your key from the Anthropic console
7. Under *Repository access*, tick the repositories that need this secret
8. Click **Add secret**
9. Rebuild your Codespace: `Ctrl+Shift+P` → **Codespaces: Rebuild Container**

The secret is now available as `$ANTHROPIC_API_KEY` inside the container. Run `claude` to open Claude Code.

---

## Python Version Management

### Default: Python 3.11

The container's base image is `mcr.microsoft.com/devcontainers/python:3.11-bullseye`. Python 3.11 is the system Python and is the recommended version for all ML workloads.

### Secondary: Python 3.13 (via pyenv)

Python 3.13.0 is installed by `install-python.sh` as a secondary version using `pyenv`. It is **not** set as the global or project default.

**Switch to Python 3.13 for a project:**

```bash
make switch-313
# or: pyenv local 3.13.0
```

**Switch back to Python 3.11:**

```bash
make switch-311
# or: pyenv local 3.11
```

**List all available versions:**

```bash
make python-version
# or: pyenv versions
```

### Compatibility Warnings for Python 3.13

| Package | Status on Python 3.13 |
|---|---|
| `torch` / torchvision / torchaudio | May fail — binary wheels often lag behind new CPython releases |
| `tensorflow` | Often unsupported on the latest CPython; use 3.11 |
| `paddleocr` | Has known C-extension issues on 3.13 |
| `cx-Oracle` | Oracle's official driver; 3.13 support may be absent |

**Recommendation:** Use Python 3.11 for any project that depends on the packages above. Switch to 3.13 only for pure-Python or stdlib experiments.

---

## Available Make Commands

| Command | Description |
|---|---|
| `make setup` | Run the full setup script (install packages, configure env, health check) |
| `make jupyter` | Start Jupyter Lab at `http://localhost:8888` |
| `make test` | Run pytest with coverage report |
| `make lint` | Format with black and lint with pylint |
| `make format` | Format with black only |
| `make clean` | Remove `__pycache__`, `.pyc`, `.ipynb_checkpoints`, `*.log` |
| `make docker-up` | Start PostgreSQL and Redis in the background |
| `make docker-down` | Stop containers (data volumes preserved) |
| `make docker-reset` | Stop containers, delete volumes, restart fresh |
| `make health` | Run the health check script |
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
| Connection URL | `redis://localhost:6379/0` |

Start both services with `make docker-up`. Both have healthchecks configured.

---

## Folder Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json          # Codespace / Dev Container config
│   └── scripts/
│       ├── setup.sh               # Main setup orchestrator (postCreateCommand)
│       ├── install-python.sh      # System deps, pyenv, pip packages
│       └── configure-claude.sh    # Claude Code CLI install + key check
├── scripts/
│   ├── configure-env.sh           # .env, git hooks, folder scaffold
│   ├── health-check.sh            # Import + CLI + env var verification
│   ├── install-deps.sh            # Reserved for project-specific deps
│   └── seed-db.sh                 # Reserved for database seeding
├── data/
│   ├── raw/                       # Raw input data (gitignored)
│   └── processed/                 # Cleaned / transformed data (gitignored)
├── models/                        # Trained model artefacts (gitignored)
├── notebooks/                     # Jupyter notebooks
├── src/                           # Application source code
├── tests/                         # pytest test suite
├── logs/                          # Runtime logs (gitignored)
├── docker-compose.yml             # PostgreSQL + Redis services
├── Makefile                       # Developer shortcuts
├── requirements.txt               # Python dependencies
├── .env.example                   # Environment variable template
├── .gitignore
└── README.md
```

---

## Troubleshooting

### OpenCV `libgl` error

```
ImportError: libGL.so.1: cannot open shared object file
```

**Fix:** The template installs `opencv-python-headless` which does not require `libGL`. If you see this error you may have installed `opencv-python` instead. Run:

```bash
pip uninstall opencv-python
pip install opencv-python-headless
```

### pyodbc — unixodbc missing

```
pyodbc.Error: ('01000', "...")
```

**Fix:** `unixodbc-dev` and `odbcinst` are installed by `install-python.sh`. If running locally without Docker, install them manually:

```bash
sudo apt-get install -y unixodbc unixodbc-dev odbcinst
pip install pyodbc
```

### Tesseract not found

```
pytesseract.pytesseract.TesseractNotFoundError
```

**Fix:** `tesseract-ocr` is installed by `install-python.sh`. Verify it is on the PATH:

```bash
which tesseract
tesseract --version
```

If running locally, install: `sudo apt-get install tesseract-ocr tesseract-ocr-eng`.

### Playwright browsers not installed

```
playwright._impl._errors.Error: Executable doesn't exist at ...
```

**Fix:** `install-python.sh` runs `playwright install chromium firefox`. Re-run it manually:

```bash
playwright install chromium firefox
```

### ANTHROPIC_API_KEY not set

```
anthropic.AuthenticationError: No API key provided
```

**Fix:** Follow the **Setting ANTHROPIC_API_KEY as a Codespace Secret** section above. For local development, add the key to your `.env` file and ensure `python-dotenv` is loading it:

```python
from dotenv import load_dotenv
load_dotenv()
```

### torch install failing on Python 3.13

`torch` binary wheels are published per CPython version. When a new Python release is very recent, wheels may not yet exist.

**Fix:** Switch back to Python 3.11 (`make switch-311`) or install torch from source (slow, not recommended). Monitor the PyTorch website for 3.13 wheel availability.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-improvement`
3. Make your changes and run `make lint` and `make test`
4. Commit with a clear message: `git commit -m "feat: add XYZ support"`
5. Push and open a Pull Request against `main`

Please keep scripts idempotent, add `|| echo "warning"` around optional installs, and update this README if you add new tools or environment variables.
