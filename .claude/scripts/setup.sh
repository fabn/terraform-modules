#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Repo-level setup script — runs inside Claude Code web cloud sessions only.
#
# Invoked by the user-level setup script (pasted into the web environment
# "Setup script" field) which discovers this file via:
#   find /home/user -maxdepth 4 -path '*/.claude/scripts/setup.sh'
#
# Tool versions are pinned in mise.toml + mise.lock; this script just
# delegates to `mise install` so local and cloud environments match.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo "=== Repo setup started at $(date -Iseconds) ==="
echo "  repo: $REPO_ROOT"

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

if ! command -v mise >/dev/null 2>&1; then
  echo "[repo] mise not found — the user-level setup script is expected to install it." >&2
  exit 1
fi

echo "[repo] mise install..."
mise trust "$REPO_ROOT" 2>/dev/null || true
mise install
mise reshim || true

echo "=== Repo setup complete at $(date -Iseconds) ==="
