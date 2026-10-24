#!/usr/bin/env bash
# PostToolUse hook (matcher: Bash). Reminds the agent to check/update the
# relevant CLAUDE.md files when a command moves or renames files, and logs
# the move so the Stop hook (check-pending-moves.py) can verify it later.
# Registered user-level; silent unless the project follows the conventions
# (root CLAUDE.md has "# Project Map" or "# Last Updated").
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
grep -qE '^# (Project Map|Last Updated)' "$ROOT/CLAUDE.md" 2>/dev/null || exit 0

# Per-project log kept outside the project. check-pending-moves.py derives the
# same name (sha1 of ROOT, first 12 hex chars).
STATE_DIR="$HOME/.claude/state/conventions"
LOG="$STATE_DIR/$(printf '%s' "$ROOT" | shasum | cut -c1-12).jsonl"

INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"

[ -z "$CMD" ] && exit 0

# Match `mv ...` or `git mv ...` as a standalone command (start of string,
# or after a shell separator like ; && ||), not as a substring of another
# word (e.g. "mvn", "expensive").
if printf '%s' "$CMD" | grep -qE '(^|[;&|]\s*)(git[[:space:]]+)?mv[[:space:]]'; then
  mkdir -p "$STATE_DIR"
  jq -nc --arg cmd "$CMD" '{command: $cmd, checked: 0}' >> "$LOG"

  MSG="This command appears to move/rename files: \`$CMD\`. If it relocates anything documented in a CLAUDE.md, update the old location's entry (remove/adjust it) and add an entry at the new location's nearest CLAUDE.md before finishing this task. This will also be auto-verified before the turn ends."
  jq -n --arg msg "$MSG" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
fi
