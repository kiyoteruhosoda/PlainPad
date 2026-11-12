#!/usr/bin/env python3
"""Fail when the `bump-version` job does not wait for every other job.

Usage: check_bump_waits_for_quality.py [WORKFLOW]  (default: .forgejo/workflows/quality.yml)

The release is gated by `needs:` (flutterbase ADR-0019). A job added to quality.yml but
left out of `needs:` would run beside the bump, and a red run of it would still
be released. This check runs on every pull request so that gap shows up before
merging.

Plain text parsing on purpose: the job image has no YAML library, and the
shape it reads (two-space job ids under `jobs:`, a one-line `needs: [...]`) is
the shape this repository writes.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

DEFAULT_WORKFLOW = Path(".forgejo/workflows/quality.yml")
BUMP_JOB = "bump-version"


def main() -> int:
    workflow = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_WORKFLOW
    lines = workflow.read_text(encoding="utf-8").splitlines()
    try:
        start = lines.index("jobs:") + 1
    except ValueError:
        print(f"{workflow}: no top-level 'jobs:' found", file=sys.stderr)
        return 1

    jobs: list[str] = []
    needs: list[str] | None = None
    current = None
    for line in lines[start:]:
        if line and not line.startswith(" ") and not line.startswith("#"):
            break  # next top-level key
        job = re.match(r"^  ([A-Za-z0-9_-]+):\s*$", line)
        if job:
            current = job.group(1)
            jobs.append(current)
            continue
        need = re.match(r"^    needs:\s*\[(.*)\]\s*$", line)
        if need and current == BUMP_JOB:
            needs = [n.strip() for n in need.group(1).split(",") if n.strip()]

    if BUMP_JOB not in jobs:
        print(f"{workflow}: job '{BUMP_JOB}' not found", file=sys.stderr)
        return 1
    if needs is None:
        print(f"{workflow}: '{BUMP_JOB}' has no one-line 'needs: [...]'", file=sys.stderr)
        return 1

    expected = sorted(j for j in jobs if j != BUMP_JOB)
    if sorted(needs) != expected:
        print(
            f"{workflow}: '{BUMP_JOB}' must need every other job.\n"
            f"  jobs:  {expected}\n  needs: {sorted(needs)}",
            file=sys.stderr,
        )
        return 1

    print(f"OK: '{BUMP_JOB}' waits for {expected}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
