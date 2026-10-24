# Workspace Conventions Guide

How a workspace's `CLAUDE.md` tree, hooks, and skills fit together, and why. This is the single canonical copy (`~/Conventions`); read it before creating or restructuring a `CLAUDE.md`/`CONTEXT.md`, or changing the hooks or the audit skill.

## Why this exists

Two ideas borrowed from real methodologies, applied to a filesystem instead of a database or an AI pipeline:

- **OKF (Open Knowledge Format)** — mapping raw structure and terminology into an explicit schema so an agent can act on it accurately instead of inferring structure from raw data. Here, each `CLAUDE.md` is the schema.md for its directory: it names what's in the directory, types each entry, and states relationships (never re-derived by scanning files each session).
- **ICM (Interpretable Context Methodology)** — making an agent's understanding of a workspace checkable by a human, filesystem-based, no heavy framework. A `CLAUDE.md` tree is cheap for a human to open and verify against reality, and cheap for an agent to load only the directory it's working in.

## The conventions

1. **One `CLAUDE.md` per directory that needs one.** Not every directory needs one — only ones with enough distinct content to be worth mapping (a directory of dynamically-growing generated files, like tailored output, can just get a "grows over time, pattern documented, not itemized" note — or be itemized, if the owner wants per-item tracking; that's a judgment call, not a hard rule).

2. **Root stays a thin index.** Root `CLAUDE.md` = `# Purpose` (one line) + `# Project Map` (links to every subdirectory's `CLAUDE.md`). Nothing else lives there — Claude-Code-internal concerns (skills, hooks, settings) belong in `.claude/CLAUDE.md`, not root.

3. **Project Map format is exact:** `- [xxx/](xxx/) — <one-line description>`. Link to the folder, not its `CLAUDE.md` file — an agent working in that folder reads its `CLAUDE.md` automatically, so an explicit file link is redundant (this mirrors ICM: the root file gives global identity, routing itself is implicit in the folder structure, not a link map). No "see" before the link. The description is high-level only (what the directory is for) and never names specific files inside it — that's the subdirectory's own `CLAUDE.md`'s job, and repeating it at root creates two places that can drift out of sync. State this rule as a line of prose directly above the list in root `CLAUDE.md` — it's read every session, so it doesn't need a hook to enforce it.

4. **Every bullet links to the real file it describes.** Not just directories — files too. `- [fetch.py](fetch.py) — ...` not `- **fetch.py** — ...`. This includes cross-directory references (`[../tracker/jobs.json](../tracker/jobs.json)`), not just same-directory ones.

5. **Sections are typed.** Group bullets under named `#` headers by category (`# Scripts`, `# State`, `# Output`, `# Source Files`, `# Conventions`) instead of one flat list. The header names the *kind* of entity; each bullet is one instance with its link (key) and description (meaning) — same shape as an OKF schema table.

6. **`# Last Updated` on every file**, a `- YYYY-MM-DD` bullet, kept current by the `stamp-claude-md-date.sh` hook (deterministic, not agent-judgment — it fires on every `Edit`/`Write` to a `CLAUDE.md` that already has the section and rewrites the date).

7. **Moves get caught, not just writes.** `mv-reminder.sh` logs any `mv`/`git mv` Bash command; `check-pending-moves.py` (a `Stop` hook) greps the whole tree for the old basename and blocks the turn once if a stale reference survived the move. New-file creation gets a lighter nudge from `claude-md-reminder.sh` (`PostToolUse`/`Write`) pointing at the nearest `CLAUDE.md`.

8. **Static, session-invariant rules go in the doc, not a hook.** A hook is for things invisible from file content alone (a file moved, a file was created). A formatting rule you want followed every time is cheaper as one line of prose in the file that's already loaded into context every session — see rule 3. Don't build automation for something a sentence already solves.

9. **A directory's `# Purpose` is self-contained.** It states what the directory is, not why it's separate from some other directory (`- distinct from x/ and y/...`). Justifying a new directory against alternatives belongs in the conversation/decision that created it, not baked into the file itself — it's a stale-reference risk (drifts if the other directory's purpose changes, with no hook catching it) and it's not needed to understand the directory on its own terms.

10. **Bullet descriptions for growing/living files describe the pattern, not a snapshot.** A file expected to accumulate content over time (a running log, an ideas tracker, an append-only journal) gets a description of its role — never a reference to what's currently in it (`"starting with X"`, `"currently covers Y"`). That kind of detail is guaranteed to go stale the moment the file's content changes, with no hook to catch it — the same principle as rule 1's "grows over time, pattern documented, not itemized" note, applied at the bullet level instead of the directory level.

11. **Split the index from the process: `CLAUDE.md` + `CONTEXT.md`.** When a directory has standing rules for how its content gets made or updated (a transcription method, a workflow, a budget model), `CLAUDE.md` stays a thin index and those rules move to a sibling `CONTEXT.md`, linked from `CLAUDE.md` under a `# Context` section. `CLAUDE.md` says *what is here*; `CONTEXT.md` says *how to work on it*. `templates/CONTEXT.md.template` gives the shape: **Inputs** (a table of what to read, scope, and why), **Process** (numbered steps), **Checkpoints** (where the agent stops and what the human decides), **Audit** (pass/fail checks run before saving), **Outputs** (artifacts, location, format). A directory with no process rules doesn't need one. Standing facts that don't fit the stages (e.g. a funding model) can sit in their own section alongside them.

12. **Descriptions stay at the level of "what it is", for every file, not only living ones.** Beyond rule 10: don't put due dates, problem/file counts, "in progress" status, or build history in a bullet. They go stale the moment the file or the calendar moves, and no hook catches it. Topics are fine for a fixed file (a lecture transcript's subjects); snapshots are not. When editing a directory's `CLAUDE.md`, check each bullet against the file it describes (section titles, headings) and fix any that drifted.

13. **Don't repeat a skill's rules in `CLAUDE.md`.** If a skill already owns a method (template, formatting, wording registers), `CONTEXT.md` points to it as an input and records only the folder-specific rules. Copying the skill's content into the directory's docs creates two places to update.

14. **`# Last Updated` is one dated bullet, not a changelog.** Rule 6 said a `- YYYY-MM-DD` bullet; keep it to exactly that. Per-edit history belongs in git (or, for this bundle, `CHANGELOG.md`), not in the file's own body.

15. **Root may carry a `# Folder Map`.** A tree of the top-level folders only, one level deep, no filenames and no per-folder comments, placed between `# Purpose` and `# Project Map`. `(you are here)` goes on the root line of the root `CLAUDE.md` only — it's accurate there and wrong if copied into a subdirectory. It's a second list of the folders, so adding a folder means updating both it and the Project Map; the `conventions-audit` skill checks they agree. The linked Project Map still carries the descriptions, since links don't render inside a code block.

16. **One canonical copy, installed user-level; never copied into a workspace.** This bundle lives at `~/Conventions`, a clone of the public repo https://github.com/hquinde/Conventions, which is the master copy. The hooks and the `conventions-audit` skill are registered once in `~/.claude/` by `install.sh`, so every workspace runs the same version and a change is made in exactly one place. A workspace keeps no `conventions/` folder, no copy of the four hooks, and no copy of the audit skill — a copy is a second place to update, and it drifts (seven copies had already spread across three versions). A project's own hooks and skills stay in that project's `.claude/`. Each root `CLAUDE.md` carries a `# Conventions` section that imports `~/Conventions/GUIDE.md` with an `@` line, so the guide is read from the canonical repo at session start and the wiring is visible in the workspace itself; `~/.claude/CLAUDE.md` only carries a prose pointer for folders with no root `CLAUDE.md` yet. The cost is the guide's length in every session's context.

## Starting a new workspace

1. Create the root `CLAUDE.md` from `templates/CLAUDE.md.template`, keeping its `# Conventions` section (it ends with an `@~/Conventions/GUIDE.md` import, which loads this guide into every session from the canonical repo; the path is user-level, so it's written as an import, not a link). Having `# Project Map` (or `# Last Updated`) in it is what opts the workspace in to the hooks.
2. Add per-directory `CLAUDE.md` / `CONTEXT.md` files from `templates/subdir-CLAUDE.md.template` and `templates/CONTEXT.md.template`, and a `.claude/CLAUDE.md` (from `templates/dot-claude-CLAUDE.md.template`) only if the workspace has its own skills, hooks, or settings. Fill in real directory names, files, and descriptions; the templates are skeletons, not content.
3. Run `/conventions-audit` to confirm the Project Map, links, and sections check out. There are no hooks or skills to copy; they are already live.

## How this is installed

- **`install.sh`** (idempotent) registers the four hooks in `~/.claude/settings.json` with commands that point into this repo and are guarded, so a moved repo makes them no-ops rather than errors (an erroring `Stop` hook would block turns). It symlinks `skills/conventions-audit` into `~/.claude/skills/`, and writes a short pointer block into `~/.claude/CLAUDE.md` so an agent in any workspace knows to read this guide. `--copy` copies the skill instead of linking it; `--uninstall` reverses all three. Hook changes take effect in a new session (or after `/hooks`).
- **Opt-in by marker.** The hooks are registered for every project but exit silently unless the root `CLAUDE.md` has `# Project Map` or `# Last Updated`, so unrelated repos are untouched.
- **State.** `mv-reminder.sh` and `check-pending-moves.py` share a per-project move log at `~/.claude/state/conventions/<first 12 hex chars of sha1(project root)>.jsonl`, so no state files land in projects.
- **New machine.** `git clone https://github.com/hquinde/Conventions ~/Conventions && ~/Conventions/install.sh`, then start a new session.
- **Changing a convention.** Edit `~/Conventions` (from any workspace; workspace repos don't contain it), add a `CHANGELOG.md` entry, commit and push from `~/Conventions`, then run `/conventions-audit` in the affected workspaces. Hooks and the skill change everywhere at once. A `CLAUDE.md` already created from an older template changes only when the audit flags it and someone fixes it; that part is not automatic.
