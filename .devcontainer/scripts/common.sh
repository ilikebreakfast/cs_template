#!/bin/bash
# Shared utility — source this file to get REPO_ROOT in any script.
# Usage: source "$(dirname "$0")/common.sh"   (from .devcontainer/scripts/)
#        source "$(cd "$(dirname "$0")/.." && pwd)/.devcontainer/scripts/common.sh"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "/workspaces/$(basename "$(pwd)")")"
export REPO_ROOT
