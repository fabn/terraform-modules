#!/usr/bin/env bash
# SessionStart hook — runs after Claude Code launches on every session
# (startup + resume). Skips on local machines.

[ "${CLAUDE_CODE_REMOTE:-}" != "true" ] && exit 0

# --- Persist mise-managed PATH so every Bash tool call inherits it ---
# Claude Code's Bash tool uses non-interactive shells that skip .bashrc,
# so we must inject the mise-shimmed PATH via CLAUDE_ENV_FILE.
if [ -n "${CLAUDE_ENV_FILE:-}" ] && command -v mise >/dev/null 2>&1; then
  mise trust "$CLAUDE_PROJECT_DIR/mise.toml" 2>/dev/null || true
  eval "$(mise activate bash 2>/dev/null)" || true
  echo "PATH=$PATH" >> "$CLAUDE_ENV_FILE"
fi

# --- Quick health check -----------------------------------------------------
ISSUES=()
command -v terraform >/dev/null 2>&1 || ISSUES+=("terraform missing")
command -v actionlint >/dev/null 2>&1 || ISSUES+=("actionlint missing")

if [ ${#ISSUES[@]} -gt 0 ]; then
  echo "SETUP INCOMPLETE: ${ISSUES[*]}. See /tmp/claude-user-setup.log"
else
  echo "Session ready"
fi
