# Conventions/

# Purpose

- The single canonical copy of the `CLAUDE.md`/hooks/skill conventions used by every workspace, installed user-level so all of them run the same version. Edit it here only; never copy it into a workspace. Master copy: https://github.com/hquinde/Conventions (this folder is its clone).

# Repository

- [README.md](README.md) — what the repo is, quick start (clone and `install.sh`), how a workspace opts in, and how to change the conventions.
- [LICENSE](LICENSE) — MIT license.

# Guide

- [GUIDE.md](GUIDE.md) — the conventions themselves and the reasoning behind them (OKF/ICM-inspired), plus how a new workspace starts and how this bundle is installed.

# Install

- [install.sh](install.sh) — idempotent user-level installer: registers the four hooks in `~/.claude/settings.json`, symlinks the audit skill into `~/.claude/skills/`, and writes the pointer block in `~/.claude/CLAUDE.md`. `--copy` copies the skill instead of linking; `--uninstall` reverses everything.

# Templates

- [templates/CLAUDE.md.template](templates/CLAUDE.md.template) — root `CLAUDE.md` skeleton (Purpose + Project Map).
- [templates/dot-claude-CLAUDE.md.template](templates/dot-claude-CLAUDE.md.template) — `.claude/CLAUDE.md` skeleton for a workspace's own skills, hooks, and settings.
- [templates/subdir-CLAUDE.md.template](templates/subdir-CLAUDE.md.template) — generic per-directory `CLAUDE.md` skeleton (typed sections + linked bullets).
- [templates/CONTEXT.md.template](templates/CONTEXT.md.template) — per-directory `CONTEXT.md` skeleton for standing process rules (Inputs, Process, Checkpoints, Audit, Outputs).

# Hooks

All four exit silently unless the project's root `CLAUDE.md` has `# Project Map` or `# Last Updated`.

- [hooks/claude-md-reminder.sh](hooks/claude-md-reminder.sh) — `PostToolUse`/`Write` hook that reminds the agent to document a newly created file in the nearest `CLAUDE.md`.
- [hooks/mv-reminder.sh](hooks/mv-reminder.sh) — `PostToolUse`/`Bash` hook that reminds the agent to update `CLAUDE.md` entries after a `mv`/`git mv` and logs the move.
- [hooks/check-pending-moves.py](hooks/check-pending-moves.py) — `Stop` hook that checks logged moves for stale references in `CLAUDE.md` files and blocks the turn once if any remain.
- [hooks/stamp-claude-md-date.sh](hooks/stamp-claude-md-date.sh) — `PostToolUse`/`Edit|Write` hook that rewrites the `# Last Updated` date of an edited `CLAUDE.md`.

# Skills

- [skills/conventions-audit/SKILL.md](skills/conventions-audit/SKILL.md) — audits a workspace's `CLAUDE.md` tree against these conventions (Project Map completeness, linked bullets, typed sections, `# Last Updated`, stale references, user-level hook wiring and leftover copies, snapshot-free descriptions, `CLAUDE.md`/`CONTEXT.md` split, Folder Map).

# Changelog

- [CHANGELOG.md](CHANGELOG.md) — dated log of what's been added/changed in this bundle. Update it whenever this bundle's contents change, since it's expected to keep growing.

# Last Updated

- 2026-10-24 — update this date whenever this file is edited.
