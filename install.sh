#!/usr/bin/env bash
# Install (or refresh) the conventions bundle at user level. Idempotent.
#
#   ./install.sh              register hooks, link the audit skill, write the CLAUDE.md pointer
#   ./install.sh --copy       copy the audit skill instead of symlinking it
#   ./install.sh --uninstall  remove all three (leaves this repo untouched)
#
# Touches only: ~/.claude/settings.json (convention hook entries), ~/.claude/skills/conventions-audit,
# and the marked block in ~/.claude/CLAUDE.md. Everything else in those files is preserved.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
SKILL_LINK="$CLAUDE_DIR/skills/conventions-audit"
POINTER="$CLAUDE_DIR/CLAUDE.md"
BEGIN='<!-- conventions:begin (managed by ~/conventions/install.sh) -->'
END='<!-- conventions:end -->'

MODE=install; COPY=0
for a in "$@"; do
  case "$a" in
    --uninstall) MODE=uninstall ;;
    --copy) COPY=1 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
mkdir -p "$CLAUDE_DIR/backups" "$CLAUDE_DIR/skills"

# Repo path as written into settings.json: use a literal $HOME when under it.
case "$REPO" in
  "$HOME"/*) REPO_CMD="\$HOME/${REPO#"$HOME"/}" ;;
  *) REPO_CMD="$REPO" ;;
esac

backup_settings() {
  [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
  cp "$SETTINGS" "$CLAUDE_DIR/backups/settings.json.$(date +%Y%m%d-%H%M%S).bak"
}

# Drop every hook entry whose command points into a conventions/hooks dir.
strip_hooks() {
  jq '
    if .hooks then
      .hooks |= with_entries(
        .value |= map(select(all(.hooks[]?; (.command // "") | contains("/conventions/hooks/") | not)))
      )
      | .hooks |= with_entries(select(.value | length > 0))
      | if (.hooks | length) == 0 then del(.hooks) else . end
    else . end' "$SETTINGS"
}

# A guarded command: a moved/deleted repo makes the hook a no-op instead of an error
# (an erroring Stop hook would block the turn).
cmd() { # $1 interpreter, $2 script
  printf '[ -f "%s/hooks/%s" ] && %s "%s/hooks/%s" || true' "$REPO_CMD" "$2" "$1" "$REPO_CMD" "$2"
}

add_hooks() {
  local new
  new=$(jq -n \
    --arg reminder "$(cmd bash claude-md-reminder.sh)" \
    --arg mv "$(cmd bash mv-reminder.sh)" \
    --arg stamp "$(cmd bash stamp-claude-md-date.sh)" \
    --arg check "$(cmd python3 check-pending-moves.py)" '
    {
      PostToolUse: [
        {matcher: "Write",      hooks: [{type: "command", command: $reminder}]},
        {matcher: "Bash",       hooks: [{type: "command", command: $mv}]},
        {matcher: "Edit|Write", hooks: [{type: "command", command: $stamp}]}
      ],
      Stop: [ {hooks: [{type: "command", command: $check}]} ]
    }')
  jq --argjson new "$new" '
    .hooks = ((.hooks // {}) as $h
      | reduce ($new | keys[]) as $ev ($h; .[$ev] = ((.[$ev] // []) + $new[$ev])))' <(strip_hooks)
}

write_settings() { # reads new JSON on stdin
  local tmp; tmp="$(mktemp)"; cat > "$tmp"
  jq -e . "$tmp" >/dev/null || { echo "refusing to write invalid JSON" >&2; rm -f "$tmp"; exit 1; }
  mv "$tmp" "$SETTINGS"
}

remove_pointer() {
  [ -f "$POINTER" ] || return 0
  python3 - "$POINTER" "$BEGIN" "$END" <<'PY'
import re, sys
path, begin, end = sys.argv[1:4]
text = open(path).read()
text = re.sub(re.escape(begin) + r".*?" + re.escape(end) + r"\n?", "", text, flags=re.S)
text = text.rstrip("\n")
if text.strip():
    open(path, "w").write(text + "\n")
else:
    import os; os.remove(path)
PY
}

write_pointer() {
  remove_pointer
  { [ -f "$POINTER" ] && { cat "$POINTER"; echo; }; cat <<EOF
$BEGIN
# Workspace conventions

- Workspaces whose root \`CLAUDE.md\` has a \`# Project Map\` follow \`~/conventions/GUIDE.md\`. Read it before creating or restructuring any \`CLAUDE.md\` or \`CONTEXT.md\`; skeletons are in \`~/conventions/templates/\`.
- Run \`/conventions-audit\` to check a workspace against it. The new-file, move-tracking and \`# Last Updated\` hooks are already registered user-level — don't copy them into a project.
- Edit conventions only in \`~/conventions\` (and log the change in its \`CHANGELOG.md\`); never keep a copy inside a workspace.
$END
EOF
  } > "$POINTER.new"
  mv "$POINTER.new" "$POINTER"
}

link_skill() {
  if [ -e "$SKILL_LINK" ] && [ ! -L "$SKILL_LINK" ] && [ "$COPY" -eq 0 ]; then
    # A previous --copy install is a real dir; replace it.
    rm -rf "$SKILL_LINK"
  elif [ -L "$SKILL_LINK" ]; then
    rm "$SKILL_LINK"
  fi
  if [ "$COPY" -eq 1 ]; then
    rm -rf "$SKILL_LINK"; cp -R "$REPO/skills/conventions-audit" "$SKILL_LINK"
  else
    ln -s "$REPO/skills/conventions-audit" "$SKILL_LINK"
  fi
}

if [ "$MODE" = install ]; then
  backup_settings
  add_hooks | write_settings
  link_skill
  write_pointer
  echo "installed from $REPO"
  echo "  hooks  : $(jq '[.hooks[][] | .hooks[]?.command | select(contains("/conventions/hooks/"))] | length' "$SETTINGS") registered in $SETTINGS"
  echo "  skill  : $SKILL_LINK$([ -L "$SKILL_LINK" ] && echo " -> $(readlink "$SKILL_LINK")" || echo " (copy)")"
  echo "  pointer: $POINTER"
  echo "Start a new Claude Code session (or open /hooks) for hook changes to take effect."
else
  backup_settings
  strip_hooks | write_settings
  if [ -L "$SKILL_LINK" ] || [ -d "$SKILL_LINK" ]; then rm -rf "$SKILL_LINK"; fi
  remove_pointer
  echo "uninstalled (repo at $REPO left untouched)"
fi
