# Changelog

## 2026-10-24

- Centralized. This bundle is now the single canonical copy at `~/conventions` (own git repo), installed user-level; the per-workspace `conventions/` copies, copied hooks, copied audit skills, and per-project hook wiring were removed from the seven workspaces that had them. New `GUIDE.md` rule 16; "Applying this to another project" became "Starting a new workspace", and "Keeping several projects in sync" became "How this is installed".
- Added `install.sh` (hooks into `~/.claude/settings.json`, audit skill symlink, pointer block in `~/.claude/CLAUDE.md`; `--copy`, `--uninstall`). Removed `templates/settings.json.template`, which it replaces.
- Hooks: all four now exit silently unless the root `CLAUDE.md` has `# Project Map` or `# Last Updated` (they run user-level, so they must ignore unrelated projects). The move log moved from `<project>/.claude/hooks/.pending-moves.jsonl` to `~/.claude/state/conventions/<sha1 of root, 12 chars>.jsonl`. `check-pending-moves.py` picked up two fixes that existed only in Fragrance-Media's copy: the `mv` regex stops at a newline, and a same-basename move (pure directory move or case-only rename) is not treated as a rename.
- `claude-md-reminder.sh` now ignores files outside the project root (scratchpad, plan, and temp files); at user level they would otherwise trigger the reminder.
- `conventions-audit` skill: paths now point at `~/conventions`; check 6 reads the new log location; check 7 verifies the user-level wiring and flags leftover local copies or duplicate registrations.
- Root `CLAUDE.md` template gets a `# Conventions` section that imports `~/conventions/GUIDE.md` (`@~/conventions/GUIDE.md`, so it loads every session) and says conventions are changed there, not in the workspace; added to the six opted-in workspaces' root files. `GUIDE.md` rule 16 and "Starting a new workspace", and audit check 7, mention it.
- `templates/dot-claude-CLAUDE.md.template`: lists only a workspace's own skills/hooks/settings.
- Added `README.md` and an MIT `LICENSE`. The master repo, https://github.com/hquinde/conventions, is now named in each workspace root's `# Conventions` section, the root template, `GUIDE.md` (rule 16, a new-machine step, and the edit-commit-push flow), this folder's `CLAUDE.md`, and the pointer block `install.sh` writes into `~/.claude/CLAUDE.md`.

## 2026-10-09

- Added rules 11–15 to `GUIDE.md`: split `CLAUDE.md` (index) from `CONTEXT.md` (process), snapshot-free descriptions for every file, don't restate a skill's rules, `# Last Updated` is one bullet, and an optional root `# Folder Map`. Added a "Keeping several projects in sync" section.
- Added `templates/CONTEXT.md.template` (Inputs / Process / Checkpoints / Audit / Outputs).
- Root template: added `# Folder Map` and fixed the Project Map format line, which contradicted the guide. Subdirectory template: added an optional `# Context` section.
- `conventions-audit` skill: added checks 8–10 (snapshot-free descriptions, index/process split, Folder Map vs. Project Map).

## 2026-07-10

- Added rule 9 to `GUIDE.md`: a directory's `# Purpose` must be self-contained, not justified against other directories by name (stale-reference risk with no hook to catch it).
- Added rule 10 to `GUIDE.md`: bullet descriptions for growing/living files (running logs, idea trackers) describe the role/pattern, not a snapshot of current contents.

## 2026-07-09

- Initial bundle: `GUIDE.md`, four hooks (`claude-md-reminder.sh`, `mv-reminder.sh`, `check-pending-moves.py`, `stamp-claude-md-date.sh`), three templates (root `CLAUDE.md`, `.claude/CLAUDE.md`, generic subdirectory `CLAUDE.md`), and the `conventions-audit` skill. Extracted from this workspace's own `CLAUDE.md` tree after it was brought in line with these conventions.
