#!/usr/bin/env bash
# check-destructive-ops.sh
#
# Mechanical backstop for the guide's highest-priority rule: never
# destroy data, not even by accident. Scans only ADDED lines in the diff
# (not the whole file — a dangerous line that already existed before
# this PR isn't this PR's problem) for patterns matching
# DESTRUCTIVE_OP_REGEX. A match fails the build unless the same line or
# the line directly above it contains DESTRUCTIVE_OP_CONFIRM_MARKER.
#
# This does not forbid destructive operations — sometimes a DROP TABLE
# or a force-push genuinely is the right call. It forbids doing it
# silently: the marker has to be typed deliberately, by a human, on
# purpose, for this exact change.
#
# Usage:
#   check-destructive-ops.sh <base-ref> <head-ref>   # for CI / a PR range
#   check-destructive-ops.sh --staged                # for a pre-commit hook,
#                                                      # checks staged changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "::error::enforcement/config.env not found next to this script." >&2
  exit 2
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

STAGED_MODE=0
if [[ "${1:-}" == "--staged" ]]; then
  STAGED_MODE=1
else
  BASE_REF="${1:-}"
  HEAD_REF="${2:-}"
  if [[ -z "$BASE_REF" || -z "$HEAD_REF" ]]; then
    echo "Usage: $0 <base-ref> <head-ref>   OR   $0 --staged" >&2
    exit 2
  fi
fi

if [[ "$STAGED_MODE" -eq 1 ]]; then
  mapfile -t CHANGED_FILES < <(git diff --cached --name-only --diff-filter=ACM)
else
  mapfile -t CHANGED_FILES < <(git diff --name-only --diff-filter=ACM "${BASE_REF}...${HEAD_REF}")
fi

if [[ "${#CHANGED_FILES[@]}" -eq 0 ]]; then
  echo "No added/modified files to check — nothing to do."
  exit 0
fi

violations=0

for f in "${CHANGED_FILES[@]}"; do
  if [[ -n "${DESTRUCTIVE_OP_EXEMPT_REGEX:-}" ]] && echo "$f" | grep -Eq "$DESTRUCTIVE_OP_EXEMPT_REGEX"; then
    continue
  fi
  [[ -f "$f" ]] || continue  # skip deleted files

  # Get this file's diff hunk, keep only added lines (prefixed with a
  # single '+'), strip the prefix, keep line numbers via --unified=0.
  if [[ "$STAGED_MODE" -eq 1 ]]; then
    diff_cmd=(git diff --cached --unified=0 -- "$f")
  else
    diff_cmd=(git diff --unified=0 "${BASE_REF}...${HEAD_REF}" -- "$f")
  fi

  while IFS= read -r line; do
    # line format from grep -n on the extracted added-lines file: N:content
    lineno="${line%%:*}"
    content="${line#*:}"

    # A line that's purely a comment (in shell, Python, SQL, or JS/TS)
    # doesn't execute, so text merely *mentioning* a dangerous command in
    # documentation or a code comment isn't itself dangerous. Only check
    # lines that aren't pure comments.
    trimmed="${content#"${content%%[![:space:]]*}"}"
    if [[ "$trimmed" =~ ^(#|//|--|\*) ]]; then
      continue
    fi

    if echo "$content" | grep -Eq "$DESTRUCTIVE_OP_REGEX"; then
      if echo "$content" | grep -Fq "$DESTRUCTIVE_OP_CONFIRM_MARKER"; then
        continue
      fi
      # Check the line immediately above the matched added line, in the
      # final file, for the marker too (a comment on its own line above).
      prev_line=$(sed -n "$((lineno - 1))p" "$f" 2>/dev/null || true)
      if echo "$prev_line" | grep -Fq "$DESTRUCTIVE_OP_CONFIRM_MARKER"; then
        continue
      fi
      violations=$((violations + 1))
      echo "::error::Unconfirmed destructive operation in ${f}:${lineno}"
      echo "  ${content}"
    fi
  done < <("${diff_cmd[@]}" \
            | grep -E '^\+[0-9]*[^+]|^@@' \
            | awk '
                /^@@/ { match($0, /\+[0-9]+/); n = substr($0, RSTART+1, RLENGTH-1); next }
                /^\+/ { print n":"substr($0,2); n++ }
              ')
done

if [[ "$violations" -gt 0 ]]; then
  echo
  echo "Found ${violations} unconfirmed destructive operation(s) in this diff."
  cat >&2 <<EOF

Per anti-ai-slop-code.md's top-priority rule ("never destroy data"):
any DROP/TRUNCATE/unscoped DELETE/rm -rf/force-push/git reset --hard/
git clean -fd needs an explicit, deliberate marker before it can ship —
add this on the line itself or the line directly above it:

  ${DESTRUCTIVE_OP_CONFIRM_MARKER}

This is not a style nitpick: it exists specifically so a destructive
operation can never reach main by accident, only on purpose.
EOF
  exit 1
fi

echo "✅ No unconfirmed destructive operations found. Gate passes."
exit 0
