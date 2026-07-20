#!/usr/bin/env bash
# check-integration-tests.sh
#
# Fails if this diff touches a "boundary" path (API routes, DB/repository
# code, queues, external service clients — configurable in config.env)
# without also adding or modifying a file that looks like an integration
# test. This is the mechanical backstop for anti-ai-slop-code.md §14.1:
# unit tests are not a substitute for integration tests.
#
# Usage:
#   check-integration-tests.sh <base-ref> <head-ref>
#
# Requires: git, run from inside the repo, with enough history fetched to
# diff base against head (`fetch-depth: 0` in actions/checkout).

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

mapfile -t CHANGED_FILES < <(git diff --name-only "${BASE_REF}...${HEAD_REF}")

if [[ "${#CHANGED_FILES[@]}" -eq 0 ]]; then
  echo "No changed files between ${BASE_REF} and ${HEAD_REF} — nothing to check."
  exit 0
fi

boundary_files=()
for f in "${CHANGED_FILES[@]}"; do
  if [[ -n "${BOUNDARY_EXEMPT_REGEX:-}" ]] && echo "$f" | grep -Eq "$BOUNDARY_EXEMPT_REGEX"; then
    continue
  fi
  if echo "$f" | grep -Eq "$BOUNDARY_PATH_REGEX"; then
    boundary_files+=("$f")
  fi
done

if [[ "${#boundary_files[@]}" -eq 0 ]]; then
  echo "✅ No boundary-crossing paths touched in this diff. Integration-test gate passes."
  exit 0
fi

integration_test_touched=0
for f in "${CHANGED_FILES[@]}"; do
  if echo "$f" | grep -Eiq "$INTEGRATION_TEST_REGEX"; then
    integration_test_touched=1
    break
  fi
done

if [[ "$integration_test_touched" -eq 1 ]]; then
  echo "✅ Boundary path(s) touched (${boundary_files[*]}) and an integration test was also touched in this diff. Gate passes."
  exit 0
fi

echo "::error::Boundary path(s) touched without a matching integration test: ${boundary_files[*]}"
cat >&2 <<EOF

This PR changes code that crosses a real boundary:
  ${boundary_files[*]}

...but no file matching the integration-test pattern was added or
modified in the same change:
  ${INTEGRATION_TEST_REGEX}

Per anti-ai-slop-code.md §14.1: unit tests that mock the database, the
queue, or the downstream service are not proof that the real connection
works. Add an integration test that exercises the actual boundary — a
real (test) database, a real HTTP call, real serialization — or, if this
change genuinely doesn't need one, adjust BOUNDARY_PATH_REGEX or
BOUNDARY_EXEMPT_REGEX in enforcement/config.env to reflect that
deliberately, rather than silently skipping the gate.
EOF
exit 1
