#!/usr/bin/env bash
# PostToolUse hook (matcher: Write). Reminds the agent to document any
# newly created file in the nearest relevant CLAUDE.md.
# Registered user-level; silent unless the project follows the conventions
# (root CLAUDE.md has "# Project Map" or "# Last Updated").
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
grep -qE '^# (Project Map|Last Updated)' "$ROOT/CLAUDE.md" 2>/dev/null || exit 0

INPUT="$(cat)"
FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"

[ -z "$FILE_PATH" ] && exit 0

BASENAME="$(basename "$FILE_PATH")"
[ "$BASENAME" = "CLAUDE.md" ] && exit 0

DIR="$(dirname "$FILE_PATH")"
TARGET=""

while [[ "$DIR" == "$ROOT"* ]]; do
  if [ -f "$DIR/CLAUDE.md" ]; then
    TARGET="$DIR/CLAUDE.md"
    break
  fi
  [ "$DIR" = "$ROOT" ] && break
  DIR="$(dirname "$DIR")"
done

[ -z "$TARGET" ] && TARGET="$ROOT/CLAUDE.md"

MSG="You just created $FILE_PATH. Add a one-line entry documenting it to $TARGET before finishing this task."
jq -n --arg msg "$MSG" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
