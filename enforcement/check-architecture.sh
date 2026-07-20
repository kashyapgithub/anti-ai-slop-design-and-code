#!/usr/bin/env bash
# check-architecture.sh
#
# Fails if this diff introduces a brand-new top-level directory without also
# touching one of the project's architecture docs in the same change.
# This is the mechanical backstop for the "Read This First" rule in
# anti-ai-slop-code.md: architecture is a decision, not a side effect.
#
# Usage:
#   check-architecture.sh <base-ref> <head-ref>
#
# In CI (GitHub Actions), base-ref/head-ref are normally the PR's base and
# head SHAs. For local testing, any two valid git refs work, e.g.:
#   enforcement/check-architecture.sh main HEAD
#
# Requires: git, run from inside the repo, with enough history fetched to
# diff base against head (`fetch-depth: 0` in actions/checkout, or a local
# clone that already has both refs).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "::error::enforcement/config.env not found next to this script." >&2
  exit 2
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

BASE_REF="${1:-}"
HEAD_REF="${2:-}"

if [[ -z "$BASE_REF" || -z "$HEAD_REF" ]]; then
  echo "Usage: $0 <base-ref> <head-ref>" >&2
  exit 2
fi

# All files added or modified in this diff (paths only).
mapfile -t CHANGED_FILES < <(git diff --name-only "${BASE_REF}...${HEAD_REF}")

# Files that ADDED for the first time in this diff (new files only) — this
# is what we check for "new top-level directory", not modified files.
mapfile -t ADDED_FILES < <(git diff --name-only --diff-filter=A "${BASE_REF}...${HEAD_REF}")

if [[ "${#CHANGED_FILES[@]}" -eq 0 ]]; then
  echo "No changed files between ${BASE_REF} and ${HEAD_REF} — nothing to check."
  exit 0
fi

is_exempt_prefix() {
  local path="$1"
  for exempt in $ARCHITECTURE_EXEMPT_PATHS; do
    if [[ "$path" == "$exempt"* ]]; then
      return 0
    fi
  done
  return 1
}

# Top-level directories that already existed in the base ref.
mapfile -t BASE_TOP_LEVEL < <(git ls-tree -d --name-only "$BASE_REF" 2>/dev/null || true)

new_top_level_dirs=()
for f in "${ADDED_FILES[@]}"; do
  [[ "$f" == */* ]] || continue   # skip files with no directory component
  top="${f%%/*}"
  is_exempt_prefix "$f" && continue

  already_existed=0
  for existing in "${BASE_TOP_LEVEL[@]}"; do
    if [[ "$existing" == "$top" ]]; then
      already_existed=1
      break
    fi
  done

  if [[ "$already_existed" -eq 0 ]]; then
    # de-dupe
    already_flagged=0
    for flagged in "${new_top_level_dirs[@]:-}"; do
      [[ "$flagged" == "$top" ]] && already_flagged=1
    done
    [[ "$already_flagged" -eq 0 ]] && new_top_level_dirs+=("$top")
  fi
done

if [[ "${#new_top_level_dirs[@]}" -eq 0 ]]; then
  echo "✅ No new top-level directories introduced. Architecture gate passes."
  exit 0
fi

arch_doc_touched=0
for doc in $ARCHITECTURE_DOCS; do
  for f in "${CHANGED_FILES[@]}"; do
    if [[ "$f" == "$doc" ]]; then
      arch_doc_touched=1
      break 2
    fi
  done
done

if [[ "$arch_doc_touched" -eq 1 ]]; then
  echo "✅ New top-level director$([ "${#new_top_level_dirs[@]}" -eq 1 ] && echo y || echo ies) (${new_top_level_dirs[*]}) introduced, and an architecture doc was updated in the same change. Gate passes."
  exit 0
fi

echo "::error::New top-level director$([ "${#new_top_level_dirs[@]}" -eq 1 ] && echo y || echo ies) introduced without an architecture doc update: ${new_top_level_dirs[*]}"
cat >&2 <<EOF

This PR introduces a new top-level directory:
  ${new_top_level_dirs[*]}

...but none of the following were updated in the same change:
  ${ARCHITECTURE_DOCS}

Per anti-ai-slop-code.md's "Read This First" rule: architecture is a
decision that gets named and written down BEFORE it's built, not
discovered afterward. If this new directory is intentional, update your
architecture doc in this same PR to say what it's for and why it lives at
the top level instead of inside an existing feature. If it's not
intentional, move the new code into the existing structure instead.
EOF
exit 1
