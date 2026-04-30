# CLAUDE.md
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
make setup              # Full setup: installs all tiers, Claude CLI, env, runs health check
make health             # Run environment health check (fast — ~5 sec)

make install-core       # pip install requirements/core.txt only
make install-ml         # pip install requirements/ml.txt only
make install-extras     # pip install requirements/extras.txt only

INSTALL_TIERS=core make setup           # selective: core only
INSTALL_TIERS=core,ml make setup        # selective: core + ML, no extras

make pin-deps           # Lock versions: runs pip-compile on all .in files → .txt
make jupyter            # Start Jupyter Lab at http://localhost:8888
make test               # pytest tests/ -v --cov=src
make lint               # black + pylint
make docker-up          # Start PostgreSQL (5432) and Redis (6379)
make docker-down        # Stop containers (data preserved)

make switch-313         # Switch project to Python 3.13.0 via pyenv
make switch-311         # Switch back to Python 3.11
```

Run a single test:
```bash
pytest tests/test_foo.py::test_bar -v
```

## Architecture

### Script orchestration chain

`postCreateCommand` calls `setup.sh`, which runs four scripts in order:

```
setup.sh
  ├── sources common.sh          → sets REPO_ROOT
  ├── install-python.sh          → system deps, pyenv 3.13, pip tiers, soft-fail packages
  ├── configure-claude.sh        → npm install -g @anthropic-ai/claude-code (skips if present)
  ├── configure-env.sh           → copies .env.example → .env, creates project folders
  └── scripts/health-check.sh   → verifies installs (failure is non-fatal via || true)
```

All scripts source `common.sh` to get `REPO_ROOT` (uses `git rev-parse` with fallback).

### Requirements tiers

| Tier | Source file | Installed file | Purpose |
|---|---|---|---|
| core | `requirements/core.in` | `requirements/core.txt` | Always-needed: numpy, pandas, fastapi, anthropic, etc. |
| ml | `requirements/ml.in` | `requirements/ml.txt` | ML/DL: transformers, xgboost, mlflow, opencv, etc. |
| extras | `requirements/extras.in` | `requirements/extras.txt` | OCR, scraping, extra DBs: tesseract, selenium, polars, etc. |

`.in` files are human-editable (unpinned). `.txt` files are what pip installs. Run `make pin-deps` to regenerate `.txt` from `.in` using pip-compile.

## Non-obvious patterns

**Soft-fail packages** — installed with `|| echo "warning: ..."` so failure is expected and non-fatal. Do not add error handling around them:
- `tensorflow`, `paddleocr`, `surya-ocr`, `cx-Oracle`

**PyTorch** is installed from the CPU wheel URL separately, not listed in any requirements file:
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

**Idempotency guards** — `make setup` can be re-run safely (~2 min vs 20+ min first time):
- apt packages: `dpkg -s <pkg>` check before calling apt-get
- PyTorch: `python -c "import torch"` skip if already installed
- Playwright: checks both module presence and `~/.cache/ms-playwright`
- spaCy model: `spacy.load('en_core_web_sm')` skip if loadable

**health-check.sh exits 1 on failures** but `setup.sh` calls it with `|| true` — this is intentional so a missing optional package doesn't abort the whole setup.

**All 30 Python imports are batched in a single Python process** in `health-check.sh`. The script parses `__COUNTS__ passed failed` from stdout to aggregate results.

**ANTHROPIC_API_KEY** should be set as a GitHub Codespace secret (Settings → Codespaces → Secrets), not in `.env`. For manual auth in an existing container: `claude config set apiKey YOUR_KEY`.

**Stale Yarn APT repo** in the `python:3.11-bullseye` base image causes `apt-get update` to exit 100. `install-python.sh` removes `/etc/apt/sources.list.d/yarn.list` at the top to work around this.
