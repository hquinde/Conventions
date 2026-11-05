# Changelog

## 2026-11-05

- `README.md`: new "Background reading" section linking the Open Knowledge Format blog post (Google Cloud) and the Interpretable Context Methodology paper (arXiv:2603.16021), the two sources `GUIDE.md` says the conventions borrow from.
- This folder's `CLAUDE.md`: the `README.md` bullet now mentions the background reading.

## 2026-11-02 (workspace-wide audit)

Found by running `conventions-audit` on the new `~/Workspaces` root and its seven workspaces. Resolutions to gaps the audit exposed:

- `GUIDE.md` rule 3 and audit check 2: a folder name with a space or URL-unsafe character keeps its real name as link text and percent-encodes the path (`[Fall 2026/](Fall%202026/)`); link text that differs from the real folder name is drift.
- `GUIDE.md` rule 16 and audit step 1: this bundle's own `CLAUDE.md` is exempt from the root-structure checks (Project Map, Folder Map, `# Conventions` import); the import would be circular and there are no subdirectories to map.
- Audit check 3: `.gitignore` joins the files skipped by the undocumented-file check.
- This folder's `CLAUDE.md`: dropped the "four hooks" counts (rules 10 and 12).
- `GUIDE.md` rule 2 now lists the root sections the template actually carries (Folder Map, Context, Rules, Conventions, Last Updated), matching rules 15 and 16. The rule 16 exemption notes a Project Map becomes required if the bundle gains a subdirectory `CLAUDE.md`; audit step 1 names the three skipped checks by step.
- Dropped the remaining "four hooks"/"four scripts" counts from `README.md`, `GUIDE.md` and the audit skill, and corrected the `CLAUDE.md` description of the root template.
- Left as is: rule 11 already allows extra standing-fact sections beside the five `CONTEXT.md` stages, so `CONTEXT.md` files shaped as design notes or status trackers are restructured in the workspace, not exempted.

## 2026-11-02

- `GUIDE.md` rule 15: a root `# Folder Map` is now expected, not optional ("Root carries a `# Folder Map`"). The `conventions-audit` skill flags a root that has a `# Project Map` but no `# Folder Map`; check 10 used to skip silently.
- `conventions-audit` skill, new checks found while auditing agentic-applier (all inside existing checks, so check numbers are unchanged):
  - Check 2: the root's prose format line must match the required entry format (it had said bold).
  - Check 3: also lists files on disk that no `CLAUDE.md` for that directory mentions, not only links that 404.
  - Check 4: flags a catch-all `# Files` section mixing unlike kinds of entries.
  - Check 5: compares `# Last Updated` against file modification time as well as `git log`.
  - Check 7: flags old convention copies deleted on disk but still tracked or uncommitted, and stale hook paths in `.claude/settings.local.json`.
  - Check 8: flags a `# Purpose` justified against another directory or step number (rule 9 had no check).
  - Check 9: flags a `CONTEXT.md` linked outside a `# Context` section, and stages that are not named `## Inputs`/`## Process`/`## Checkpoints`/`## Audit`/`## Outputs`.
  - Check 11: the report leads with the highest-impact findings.
- Other opted-in workspaces without a Folder Map will now be flagged by the audit until they add one.
- Canonical location moved from `~/Conventions` to `~/Workspaces/Conventions` (all workspaces now live under `~/Workspaces`). `install.sh` derives the path it shows in the `~/.claude/CLAUDE.md` pointer block from where it runs (`REPO_DISPLAY`) instead of hardcoding it; `GUIDE.md`, `README.md`, the audit skill and both root/`.claude` templates name the new path. Workspaces' `@…/GUIDE.md` imports were repointed by hand. Older entries below keep the old path as written. Re-run `install.sh` after any move to repoint the hooks and the skill link.

## 2026-10-24

- Centralized. This bundle is now the single canonical copy at `~/Conventions` (own git repo), installed user-level; the per-workspace `conventions/` copies, copied hooks, copied audit skills, and per-project hook wiring were removed from the seven workspaces that had them. New `GUIDE.md` rule 16; "Applying this to another project" became "Starting a new workspace", and "Keeping several projects in sync" became "How this is installed".
- Added `install.sh` (hooks into `~/.claude/settings.json`, audit skill symlink, pointer block in `~/.claude/CLAUDE.md`; `--copy`, `--uninstall`). Removed `templates/settings.json.template`, which it replaces.
- Hooks: all four now exit silently unless the root `CLAUDE.md` has `# Project Map` or `# Last Updated` (they run user-level, so they must ignore unrelated projects). The move log moved from `<project>/.claude/hooks/.pending-moves.jsonl` to `~/.claude/state/conventions/<sha1 of root, 12 chars>.jsonl`. `check-pending-moves.py` picked up two fixes that existed only in Fragrance-Media's copy: the `mv` regex stops at a newline, and a same-basename move (pure directory move or case-only rename) is not treated as a rename.
- `claude-md-reminder.sh` now ignores files outside the project root (scratchpad, plan, and temp files); at user level they would otherwise trigger the reminder.
- `conventions-audit` skill: paths now point at `~/Conventions`; check 6 reads the new log location; check 7 verifies the user-level wiring and flags leftover local copies or duplicate registrations.
- Root `CLAUDE.md` template gets a `# Conventions` section that imports `~/Conventions/GUIDE.md` (`@~/Conventions/GUIDE.md`, so it loads every session) and says conventions are changed there, not in the workspace; added to the six opted-in workspaces' root files. `GUIDE.md` rule 16 and "Starting a new workspace", and audit check 7, mention it.
- `templates/dot-claude-CLAUDE.md.template`: lists only a workspace's own skills/hooks/settings.
- Added `README.md` and an MIT `LICENSE`. The master repo, https://github.com/hquinde/Conventions, is now named in each workspace root's `# Conventions` section, the root template, `GUIDE.md` (rule 16, a new-machine step, and the edit-commit-push flow), this folder's `CLAUDE.md`, and the pointer block `install.sh` writes into `~/.claude/CLAUDE.md`.
- Renamed the folder and repo to `Conventions` (`~/Conventions`, https://github.com/hquinde/Conventions; GitHub redirects the old URL). The skill stays `conventions-audit` and the state directory stays `~/.claude/state/conventions`. `install.sh` now matches its own hook entries and pointer block case-insensitively so re-running it after the rename replaces the old lowercase ones instead of duplicating them.

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
