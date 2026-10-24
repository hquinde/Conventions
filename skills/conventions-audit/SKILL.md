---
name: conventions-audit
description: Audit a workspace's CLAUDE.md tree against the conventions defined in ~/conventions/GUIDE.md. Use whenever asked to "check conventions", "verify CLAUDE.md consistency", "audit the docs", or after creating a new workspace's CLAUDE.md tree to confirm it follows the conventions.
---

# Conventions Audit

Checks a workspace's `CLAUDE.md` tree against the conventions documented in `~/conventions/GUIDE.md` (templates are in `~/conventions/templates/`). Read the guide first if this is the first time auditing a given workspace — it explains the *why* behind each check below.

## 1. Discover the tree

Find every `CLAUDE.md` in the project (excluding `.git`, `node_modules`). Read the root one first.

## 2. Project Map completeness

For every directory that has its own `CLAUDE.md`, confirm its parent's `CLAUDE.md` lists it — in the exact format `- [xxx/](xxx/) — <one-line description>` (no bold, link to the folder itself not its `CLAUDE.md` file, no "see" before the link, and a trailing one-line, high-level description). Flag: missing entries, wrong relative path, format drift, a missing/empty description, or a description that names specific files inside the subdirectory (that belongs in the subdirectory's own `CLAUDE.md`, not the parent's).

## 3. Every bullet links to a real file

For each bullet across every `CLAUDE.md`, if it names a file or directory in this project, it should be a markdown link (`[name](path)`), and the path must resolve to a file that actually exists. Flag: bare `**bold**` filenames with no link, and links that 404.

## 4. Sections are typed, not flat

Each `CLAUDE.md` should group its bullets under named `#` sections (e.g. `# Scripts`, `# State`, `# Source Files`) rather than one undifferentiated list under the title. A `# Purpose` section should be first. Flag: flat bullet lists with no section headers.

## 5. Last Updated is present and plausible

Every `CLAUDE.md` should have a `# Last Updated` section with a `- YYYY-MM-DD` bullet. Flag: missing section, or a date that's stale relative to the file's actual last-edit time if that's knowable (e.g. via git log).

## 6. No stale references

Grep the whole tree for filenames that no longer exist at the path implied by their surrounding text (this catches moves that were never reflected in docs). Cross-check against this project's pending-move log if present (`~/.claude/state/conventions/<first 12 hex chars of sha1(project root)>.jsonl`).

## 7. Hooks and skill wired once, user-level

Confirm `~/.claude/settings.json` registers the four scripts from `~/conventions/hooks/` — `claude-md-reminder.sh` on `PostToolUse`/`Write`, `mv-reminder.sh` on `PostToolUse`/`Bash`, `stamp-claude-md-date.sh` on `PostToolUse`/`Edit|Write`, `check-pending-moves.py` on `Stop` — and that `~/.claude/skills/conventions-audit` resolves. In the workspace being audited, flag (rule 16): a `conventions/` folder, copies of those four scripts under `.claude/hooks/`, a `.claude/skills/conventions-audit/` copy, or project `settings.json` entries that register them (they would fire twice). A project's own hooks are fine, but each must be documented with a working link in `.claude/CLAUDE.md`. Flag a root `CLAUDE.md` with no `# Conventions` section pointing at `~/conventions/GUIDE.md`. If the root `CLAUDE.md` has neither `# Project Map` nor `# Last Updated`, note that the hooks skip this workspace.

## 8. Descriptions are snapshot-free and accurate

For each bullet, flag descriptions that carry due dates, problem/file counts, "in progress"/"currently" status, or build history (GUIDE rules 10 and 12). Spot-check a few descriptions against the file they describe (headings, section titles) and flag any that drifted. Flag a `# Last Updated` with more than one bullet (rule 14). Flag a bullet that restates a skill's rules instead of linking to the skill (rule 13).

## 9. Index / process split

For every `CLAUDE.md` that carries a `# Context` section, confirm the linked `CONTEXT.md` exists and has the stages from `~/conventions/templates/CONTEXT.md.template` (Inputs, Process, Checkpoints, Audit, Outputs), and that every file it links resolves. Flag a `CLAUDE.md` that holds standing process rules inline and has no `CONTEXT.md` (rule 11).

## 10. Folder Map agrees with Project Map

If the root `CLAUDE.md` has a `# Folder Map`, confirm it lists exactly the folders in its `# Project Map` (plus any without their own `CLAUDE.md`), shows folders only (no filenames), and that `(you are here)` appears only on the root line of the root file (rule 15).

## 11. Report

List findings grouped by file, each as `path:line — issue`. Don't silently fix anything unless asked — this skill is a checker, not an auto-fixer.
