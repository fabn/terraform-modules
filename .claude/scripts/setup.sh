#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Repo-level setup script — runs inside Claude Code web cloud sessions only.
#
# Invoked by the user-level setup script (pasted into the web environment
# "Setup script" field) which discovers this file via:
#   find /home/user -maxdepth 4 -path '*/.claude/scripts/setup.sh'
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo "=== Repo setup started at $(date -Iseconds) ==="
echo "  repo: $REPO_ROOT"

export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.local/bin"

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  command -v sudo >/dev/null 2>&1 && SUDO="sudo"
fi

# --- Terraform --------------------------------------------------------------
if ! command -v terraform >/dev/null 2>&1; then
  echo "[repo] installing terraform..."
  TF_VERSION="${TF_VERSION:-1.11.4}"
  TF_ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
  TMP="$(mktemp -d)"
  curl -fsSL -o "$TMP/tf.zip" \
    "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TF_ARCH}.zip"
  unzip -q -o "$TMP/tf.zip" -d "$TMP"
  install -m 0755 "$TMP/terraform" "$HOME/.local/bin/terraform"
  rm -rf "$TMP"
fi
terraform version

# --- actionlint -------------------------------------------------------------
if ! command -v actionlint >/dev/null 2>&1; then
  echo "[repo] installing actionlint..."
  TMP="$(mktemp -d)"
  bash <(curl -fsSL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash) \
    latest "$TMP" >/dev/null
  install -m 0755 "$TMP/actionlint" "$HOME/.local/bin/actionlint"
  rm -rf "$TMP"
fi

# --- sops + age -------------------------------------------------------------
if ! command -v sops >/dev/null 2>&1; then
  echo "[repo] installing sops..."
  SOPS_VERSION="${SOPS_VERSION:-v3.9.4}"
  SOPS_ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
  curl -fsSL -o "$HOME/.local/bin/sops" \
    "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${SOPS_ARCH}"
  chmod 0755 "$HOME/.local/bin/sops"
fi

if ! command -v age >/dev/null 2>&1; then
  echo "[repo] installing age..."
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update -qq
    $SUDO apt-get install -y -qq age
  fi
fi

# --- kind + kubectl ---------------------------------------------------------
if ! command -v kubectl >/dev/null 2>&1; then
  echo "[repo] installing kubectl..."
  KCTL_ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
  KCTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  curl -fsSL -o "$HOME/.local/bin/kubectl" \
    "https://dl.k8s.io/release/${KCTL_VERSION}/bin/linux/${KCTL_ARCH}/kubectl"
  chmod 0755 "$HOME/.local/bin/kubectl"
fi

if ! command -v kind >/dev/null 2>&1; then
  echo "[repo] installing kind..."
  KIND_VERSION="${KIND_VERSION:-v0.24.0}"
  KIND_ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
  curl -fsSL -o "$HOME/.local/bin/kind" \
    "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${KIND_ARCH}"
  chmod 0755 "$HOME/.local/bin/kind"
fi

echo "=== Repo setup complete at $(date -Iseconds) ==="
