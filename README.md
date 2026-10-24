# Conventions

One canonical set of `CLAUDE.md`, hook, and skill conventions for [Claude Code](https://claude.com/claude-code) workspaces, installed once at user level so every workspace on a machine runs the same version.

Each workspace's `CLAUDE.md` tree is a schema for an agent: it names what's in each directory, types each entry, and links to the real files, so the agent doesn't re-derive structure every session. This repo holds the rules for that, the skeletons to start from, and the tooling that keeps it honest.

## What's in it

- [GUIDE.md](GUIDE.md) — the conventions and the reasoning behind them, plus how a new workspace starts and how this is installed. Start here.
- [templates/](templates/) — skeletons for a root `CLAUDE.md`, a `.claude/CLAUDE.md`, a per-directory `CLAUDE.md`, and a `CONTEXT.md`.
- [hooks/](hooks/) — four hooks: a new-file documentation reminder, move tracking, a stale-reference check at the end of a turn, and `# Last Updated` date stamping.
- [skills/conventions-audit/](skills/conventions-audit/SKILL.md) — a skill that audits a workspace's `CLAUDE.md` tree against the guide.
- [install.sh](install.sh) — registers the hooks, links the skill, and adds a pointer to `~/.claude/CLAUDE.md`.
- [CHANGELOG.md](CHANGELOG.md) — what changed and when.

## Quick start

Requires `bash`, `jq`, `python3`, and `shasum` (macOS or Linux).

```sh
git clone https://github.com/hquinde/Conventions ~/Conventions
~/Conventions/install.sh
```

Then start a new Claude Code session; hook changes don't apply to sessions that are already open. `install.sh` is idempotent, so re-run it after pulling changes. `~/Conventions/install.sh --uninstall` removes everything it added (hooks, skill link, pointer block) and leaves the repo alone. `--copy` copies the skill instead of symlinking it.

It edits only the convention hook entries in `~/.claude/settings.json`, `~/.claude/skills/conventions-audit`, and a marked block in `~/.claude/CLAUDE.md`, and backs up `settings.json` first.

## Using it in a workspace

A workspace opts in by having a root `CLAUDE.md` with a `# Project Map` or `# Last Updated` heading. The hooks are registered for every project but exit silently without one, so unrelated repos are untouched.

Start the root file from [templates/CLAUDE.md.template](templates/CLAUDE.md.template). Its `# Conventions` section imports the guide (`@~/Conventions/GUIDE.md`), so the guide is in context every session. Run `/conventions-audit` in a workspace to check it against the guide.

## Changing the conventions

Keep a single copy: edit `~/Conventions`, from any workspace, and never copy it into one. Add a [CHANGELOG.md](CHANGELOG.md) entry, then commit and push from `~/Conventions`. Hooks and the skill change everywhere at once; an existing `CLAUDE.md` changes only when the audit flags it and someone fixes it.

## License

[MIT](LICENSE)
