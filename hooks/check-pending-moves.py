#!/usr/bin/env python3
"""Stop hook. Verifies that file moves logged by mv-reminder.sh this
session no longer have stale references in project CLAUDE.md files.

Blocks the turn from ending once per move if stale references remain
(forcing a fix), then auto-clears on the next check regardless of outcome
so a false positive (e.g. an unrelated prose mention of the old name)
can't create an infinite block loop.

Registered user-level; silent unless the project follows the conventions
(root CLAUDE.md has "# Project Map" or "# Last Updated").
"""
import hashlib
import json
import os
import re
import shlex

ROOT = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
# Per-project log kept outside the project. mv-reminder.sh derives the same
# name (sha1 of ROOT, first 12 hex chars).
LOG = os.path.join(
    os.path.expanduser("~"),
    ".claude",
    "state",
    "conventions",
    hashlib.sha1(ROOT.encode()).hexdigest()[:12] + ".jsonl",
)


def follows_conventions():
    try:
        with open(os.path.join(ROOT, "CLAUDE.md"), encoding="utf-8", errors="ignore") as f:
            return any(re.match(r"# (Project Map|Last Updated)", line) for line in f)
    except OSError:
        return False


def load_entries():
    if not os.path.exists(LOG):
        return []
    entries = []
    with open(LOG) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue  # skip malformed lines rather than crash the hook
    return entries


def save_entries(entries):
    if not entries:
        if os.path.exists(LOG):
            os.remove(LOG)
        return
    with open(LOG, "w") as f:
        for e in entries:
            f.write(json.dumps(e) + "\n")


def extract_old_basenames(command):
    basenames = []
    for match in re.finditer(r"(?:git\s+)?\bmv\b([^;&|\n]*)", command):
        try:
            args = shlex.split(match.group(1))
        except ValueError:
            continue
        args = [a for a in args if not a.startswith("-")]
        if len(args) < 2:
            continue
        dest_basename = os.path.basename(args[-1].rstrip("/"))
        for old in args[:-1]:
            old_basename = os.path.basename(old.rstrip("/"))
            if old_basename == dest_basename:
                continue  # pure directory move / case-only rename — name is still current
            basenames.append(old_basename)
    return basenames


def find_md_hits(basename):
    hits = []
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in (".git", "node_modules")]
        for fn in filenames:
            if not fn.endswith(".md"):
                continue
            path = os.path.join(dirpath, fn)
            try:
                with open(path, encoding="utf-8", errors="ignore") as f:
                    for i, line in enumerate(f, 1):
                        if basename in line:
                            hits.append(f"{os.path.relpath(path, ROOT)}:{i}")
            except OSError:
                continue
    return hits


def main():
    if not follows_conventions():
        return
    entries = load_entries()
    if not entries:
        return

    remaining = []
    block_lines = []
    warn_lines = []

    for entry in entries:
        command = entry["command"]
        checked = entry.get("checked", 0)
        basenames = extract_old_basenames(command)

        stale = {}
        for b in basenames:
            hits = find_md_hits(b)
            if hits:
                stale[b] = hits

        if not stale:
            continue  # resolved, drop entry

        detail = "; ".join(f"`{b}` in {', '.join(h)}" for b, h in stale.items())
        if checked == 0:
            block_lines.append(f"- `{command}` still has stale references: {detail}")
            remaining.append({"command": command, "checked": 1})
        else:
            warn_lines.append(f"- `{command}` still has stale references (not re-checking further): {detail}")
            # exhausted retries, drop entry regardless of outcome

    save_entries(remaining)

    if block_lines:
        reason = "Stale CLAUDE.md references found after a file move:\n" + "\n".join(block_lines)
        print(json.dumps({"decision": "block", "reason": reason}))
    elif warn_lines:
        msg = "Note: earlier file move(s) still have stale CLAUDE.md references (won't re-check):\n" + "\n".join(warn_lines)
        print(json.dumps({"systemMessage": msg}))


if __name__ == "__main__":
    main()
