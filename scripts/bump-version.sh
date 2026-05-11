#!/usr/bin/env bash
#
# Bump version in flutter/pubspec.yaml and create a git tag.
#
# Usage:
#   ./scripts/bump-version.sh patch        # 1.0.2+4 → 1.0.3+5
#   ./scripts/bump-version.sh minor        # 1.0.2+4 → 1.1.0+5
#   ./scripts/bump-version.sh major        # 1.0.2+4 → 2.0.0+5
#   ./scripts/bump-version.sh build        # 1.0.2+4 → 1.0.2+5
#   ./scripts/bump-version.sh 1.2.3        # explicit name, build auto-increments
#   ./scripts/bump-version.sh 1.2.3+10     # fully explicit
#
# Adds:
#   - amended pubspec.yaml
#   - git commit  "chore(release): vX.Y.Z+N"
#   - git tag     "vX.Y.Z"        (re-trigger CI release workflow)

set -euo pipefail

mode="${1:-}"
if [[ -z "$mode" ]]; then
    echo "Usage: $0 {patch|minor|major|build|X.Y.Z|X.Y.Z+N}" >&2
    exit 2
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
pubspec="$root/flutter/pubspec.yaml"

current_line="$(grep -E '^version:' "$pubspec")"
current="${current_line#version: }"
name="${current%%+*}"
build="${current##*+}"
IFS=. read -r major minor patch <<< "$name"

case "$mode" in
    patch) patch=$((patch + 1)); build=$((build + 1)) ;;
    minor) minor=$((minor + 1)); patch=0; build=$((build + 1)) ;;
    major) major=$((major + 1)); minor=0; patch=0; build=$((build + 1)) ;;
    build) build=$((build + 1)) ;;
    *+*)   name="${mode%%+*}"; build="${mode##*+}"
           IFS=. read -r major minor patch <<< "$name" ;;
    *.*.*) name="$mode"; build=$((build + 1))
           IFS=. read -r major minor patch <<< "$name" ;;
    *)     echo "Unknown mode: $mode" >&2; exit 2 ;;
esac

new_name="$major.$minor.$patch"
new="$new_name+$build"

echo "$current  →  $new"

# Portable sed for both macOS BSD sed and GNU sed
if sed --version >/dev/null 2>&1; then
    sed -i "s/^version: .*/version: $new/" "$pubspec"
else
    sed -i '' "s/^version: .*/version: $new/" "$pubspec"
fi

cd "$root"
if git rev-parse --git-dir >/dev/null 2>&1; then
    git add flutter/pubspec.yaml
    git commit -m "chore(release): v$new" >/dev/null
    git tag "v$new_name"
    echo "✅ Committed and tagged v$new_name"
    echo "   Push with:  git push && git push --tags"
else
    echo "⚠️  Not a git repo — only pubspec was updated."
fi
