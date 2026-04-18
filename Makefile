.PHONY: setup jupyter test lint format clean docker-up docker-down docker-reset health python-version switch-313 switch-311

# ============================================================================
# Setup
# ============================================================================

setup:
	bash .devcontainer/scripts/setup.sh

# ============================================================================
# Development
# ============================================================================

jupyter:
	jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root

# ============================================================================
# Quality
# ============================================================================

test:
	pytest tests/ -v --cov=src --cov-report=term-missing

lint:
	black . && pylint src/

format:
	black .

# ============================================================================
# Cleanup
# ============================================================================

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	find . -name ".ipynb_checkpoints" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.log" -delete 2>/dev/null || true

# ============================================================================
# Docker
# ============================================================================

docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-reset:
	docker compose down -v && docker compose up -d

# ============================================================================
# Health
# ============================================================================

health:
	bash scripts/health-check.sh

# ============================================================================
# Python version management
# ============================================================================

python-version:
	pyenv versions

switch-313:
	pyenv local 3.13.0 && echo "Switched to Python 3.13.0"

switch-311:
	pyenv local 3.11 && echo "Switched to Python 3.11"
