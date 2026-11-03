---
name: conventions-audit
description: Audit a workspace's CLAUDE.md tree against the conventions defined in ~/Conventions/GUIDE.md. Use whenever asked to "check conventions", "verify CLAUDE.md consistency", "audit the docs", or after creating a new workspace's CLAUDE.md tree to confirm it follows the conventions.
---

# Conventions Audit

Checks a workspace's `CLAUDE.md` tree against the conventions documented in `~/Conventions/GUIDE.md` (templates are in `~/Conventions/templates/`). Read the guide first if this is the first time auditing a given workspace — it explains the *why* behind each check below.

## 1. Discover the tree

Find every `CLAUDE.md` in the project (excluding `.git`, `node_modules`). Read the root one first.

## 2. Project Map completeness

For every directory that has its own `CLAUDE.md`, confirm its parent's `CLAUDE.md` lists it — in the exact format `- [xxx/](xxx/) — <one-line description>` (no bold, link to the folder itself not its `CLAUDE.md` file, no "see" before the link, and a trailing one-line, high-level description). The prose format line above the root's list must state that same format; flag one that contradicts the entries below it (for example, showing the entry in bold). Flag: missing entries, wrong relative path, format drift, a missing/empty description, or a description that names specific files inside the subdirectory (that belongs in the subdirectory's own `CLAUDE.md`, not the parent's).

## 3. Every bullet links to a real file

For each bullet across every `CLAUDE.md`, if it names a file or directory in this project, it should be a markdown link (`[name](path)`), and the path must resolve to a file that actually exists. Flag: bare `**bold**` filenames with no link, and links that 404.

Check the other direction too: list the files and folders actually in each directory and flag any that no `CLAUDE.md` for that directory mentions. Skip `.DS_Store`, build caches (`__pycache__`, `*.pyc`) and `.git`. A gitignored file is still flagged unless it is documented as machine state or run state (for example a lock file, a log, or a browser-profile folder); undocumented files are how stray artifacts end up committed.

## 4. Sections are typed, not flat

Each `CLAUDE.md` should group its bullets under named `#` sections (e.g. `# Scripts`, `# State`, `# Source Files`) rather than one undifferentiated list under the title. A `# Purpose` section should be first. Flag: flat bullet lists with no section headers, and a single catch-all section (usually `# Files`) that mixes unlike kinds of entries (source data, research notes, third-party documents, a live backlog, a log).

## 5. Last Updated is present and plausible

Every `CLAUDE.md` should have a `# Last Updated` section with a `- YYYY-MM-DD` bullet. Flag: missing section, or a date that's stale relative to the file's actual last-edit time. Compare against the file's modification time (`stat`) as well as `git log`: edits not yet committed, or made outside the Edit/Write tools, never show up in git history and slip past the date-stamp hook.

## 6. No stale references

Grep the whole tree for filenames that no longer exist at the path implied by their surrounding text (this catches moves that were never reflected in docs). Cross-check against this project's pending-move log if present (`~/.claude/state/conventions/<first 12 hex chars of sha1(project root)>.jsonl`).

## 7. Hooks and skill wired once, user-level

Confirm `~/.claude/settings.json` registers the four scripts from `~/Conventions/hooks/` — `claude-md-reminder.sh` on `PostToolUse`/`Write`, `mv-reminder.sh` on `PostToolUse`/`Bash`, `stamp-claude-md-date.sh` on `PostToolUse`/`Edit|Write`, `check-pending-moves.py` on `Stop` — and that `~/.claude/skills/conventions-audit` resolves. In the workspace being audited, flag (rule 16): a `conventions/` folder, copies of those four scripts under `.claude/hooks/`, a `.claude/skills/conventions-audit/` copy, or project `settings.json` entries that register them (they would fire twice). Also flag any of those copies that are deleted on disk but still tracked, or whose deletion is uncommitted (`git status`): a checkout or `git checkout .` restores them and the hooks fire twice. Flag entries in the project's `.claude/settings.local.json` that point at hook or script paths that no longer exist. A project's own hooks are fine, but each must be documented with a working link in `.claude/CLAUDE.md`. Flag a root `CLAUDE.md` with no `# Conventions` section, or one that lacks the `@~/Conventions/GUIDE.md` import line. If the root `CLAUDE.md` has neither `# Project Map` nor `# Last Updated`, note that the hooks skip this workspace.

## 8. Descriptions are snapshot-free and accurate

For each bullet, flag descriptions that carry due dates, problem/file counts, "in progress"/"currently" status, or build history (GUIDE rules 10 and 12). Spot-check a few descriptions against the file they describe (headings, section titles) and flag any that drifted. Flag a `# Last Updated` with more than one bullet (rule 14). Flag a bullet that restates a skill's rules instead of linking to the skill (rule 13). Flag a `# Purpose` that justifies the directory against another by name or step number ("Exists because `../x/CONTEXT.md` step 3…", "distinct from `y/`…"): it must be self-contained (rule 9).

## 9. Index / process split

For every `CLAUDE.md` that carries a `# Context` section, confirm the linked `CONTEXT.md` exists and has the stages from `~/Conventions/templates/CONTEXT.md.template` (Inputs, Process, Checkpoints, Audit, Outputs), and that every file it links resolves. Flag a `CLAUDE.md` that holds standing process rules inline and has no `CONTEXT.md` (rule 11). Flag a `CLAUDE.md` that links its `CONTEXT.md` anywhere other than a `# Context` section (for example only inside `# Purpose`), and a `CONTEXT.md` whose stages exist only as loosely named sections instead of `## Inputs`, `## Process`, `## Checkpoints`, `## Audit`, `## Outputs`.

## 10. Folder Map agrees with Project Map

If the root `CLAUDE.md` has a `# Project Map` but no `# Folder Map`, flag it: the map is expected (rule 15) and must not be skipped silently. Otherwise confirm the Folder Map lists exactly the folders in its `# Project Map` (plus any without their own `CLAUDE.md`), shows folders only (no filenames), and that `(you are here)` appears only on the root line of the root file (rule 15).

## 11. Report

Start with the highest-impact findings (broken links, contradictions between files, privacy risks such as unignored personal files), then list the rest grouped by file, each as `path:line — issue`. Don't silently fix anything unless asked — this skill is a checker, not an auto-fixer.
