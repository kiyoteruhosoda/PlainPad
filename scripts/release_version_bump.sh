#!/usr/bin/env bash
# Bumps the version, commits it, tags it and pushes main — the push is what
# makes deck build and publish the release (docs/RELEASE.md, flutterbase ADR-0019).
#
# Usage (CI only; needs a checkout with a token that may push to main):
#   bash scripts/release_version_bump.sh [auto|major|minor|patch]
#
# Called from two places:
#   - quality.yml, job `bump-version`: after every Quality job passed on a
#     push to main (the automatic release).
#   - version_bump.yml: the manual workflow_dispatch.

set -euo pipefail

BUMP_TYPE="${1:-auto}"

cd "$(dirname "$0")/.."

git config user.name "forge-actions[bot]"
git config user.email "forge-actions[bot]@nolumia.com"

OUT="$(mktemp)"
GITHUB_OUTPUT="$OUT" bash scripts/bump_version.sh "$BUMP_TYPE"

NEW_VERSION="$(sed -n 's/^new_version=//p' "$OUT")"
NEW_VERSION_FULL="$(sed -n 's/^new_version_full=//p' "$OUT")"
rm -f "$OUT"

if [ -z "$NEW_VERSION" ]; then
  echo "Nothing to bump; not pushing."
  exit 0
fi

TAG="v$NEW_VERSION"
git add pubspec.yaml
# Keep the skip marker in the subject: the push below is made by a real user
# (actions-push), so unlike GITHUB_TOKEN it starts workflows. A new run on main
# would cancel the run doing this push (measured 2026-09-27).
git commit -m "chore: bump version to ${NEW_VERSION_FULL} [skip ci]"
if git rev-parse "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists, pushing the commit only."
  git push origin HEAD:refs/heads/main
else
  git tag "$TAG"
  git push origin HEAD:refs/heads/main "refs/tags/$TAG"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "new_version=$NEW_VERSION"
    echo "new_version_full=$NEW_VERSION_FULL"
  } >> "$GITHUB_OUTPUT"
fi
echo "Pushed $NEW_VERSION_FULL ($TAG) to main."
