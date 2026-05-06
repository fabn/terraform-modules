#!/usr/bin/env bash
# SessionStart hook — runs after Claude Code launches on every session
# (startup + resume). Skips on local machines.

[ "${CLAUDE_CODE_REMOTE:-}" != "true" ] && exit 0

# --- Persist PATH so every Bash tool call sees ~/.local/bin -----------------
# Claude Code's Bash tool uses non-interactive shells that skip .bashrc,
# so we must inject the local-bin PATH via CLAUDE_ENV_FILE.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  export PATH="$HOME/.local/bin:$PATH"
  echo "PATH=$PATH" >> "$CLAUDE_ENV_FILE"
fi

# --- Quick health check -----------------------------------------------------
ISSUES=()
command -v terraform >/dev/null 2>&1 || ISSUES+=("terraform missing")
command -v actionlint >/dev/null 2>&1 || ISSUES+=("actionlint missing")
command -v sops >/dev/null 2>&1 || ISSUES+=("sops missing")
command -v kind >/dev/null 2>&1 || ISSUES+=("kind missing")
command -v kubectl >/dev/null 2>&1 || ISSUES+=("kubectl missing")

if [ ${#ISSUES[@]} -gt 0 ]; then
  echo "SETUP INCOMPLETE: ${ISSUES[*]}. See /tmp/claude-user-setup.log"
else
  echo "Session ready"
fi
