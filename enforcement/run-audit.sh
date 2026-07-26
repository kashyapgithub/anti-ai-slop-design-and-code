#!/usr/bin/env bash
# run-audit.sh
#
# Runs the mechanical, always-runnable layers of the 10-layer audit
# (anti-ai-slop-code.md's "The 10-Layer Audit" section — §18 as of this
# writing, but section numbers shift as the guide grows; search by
# heading text if this is stale: format, type-check, lint, unit tests,
# integration tests) as configured in config.env, in order, stopping at
# the first failure. Designed to be called from a Claude Code Stop hook
# (or any other tool's equivalent, or a pre-commit/pre-push hook) so the
# audit runs whether or not an agent chose to run it itself.
#
# Exit code 0: every configured layer passed (or was skipped — see
#              output for which).
# Exit code 1: a configured layer failed. Output says which one.
#
# This intentionally does NOT run layers 4/5 (dependency audit,
# secrets/SAST) or layer 8 (architecture gates) — those need git refs or
# registry calls that don't reduce to one reusable command per project.
# Run those explicitly with the commands in "The 10-Layer Audit" section, or wire
# check-architecture.sh / check-integration-tests.sh into this script
# yourself once you've decided what base ref makes sense for your
# workflow. Layers 9 (comprehension) and 10 (runtime smoke check) are
# not mechanical by design — no script does those for you.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "enforcement/config.env not found next to this script." >&2
  exit 2
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

run_layer() {
  local name="$1"
  local cmd="$2"
  if [[ -z "$cmd" ]]; then
    echo "⏭️  Layer skipped (not configured in config.env): ${name}"
    return 0
  fi
  echo "▶️  Layer: ${name}  (${cmd})"
  if eval "$cmd"; then
    echo "✅  ${name} passed."
    return 0
  else
    echo "❌  ${name} FAILED: ${cmd}"
    return 1
  fi
}

failed=0

run_layer "1. Format"            "${AUDIT_FORMAT_CMD:-}"             || failed=1
[[ "$failed" -eq 0 ]] && { run_layer "2. Type-check" "${AUDIT_TYPECHECK_CMD:-}" || failed=1; }
[[ "$failed" -eq 0 ]] && { run_layer "3. Lint"        "${AUDIT_LINT_CMD:-}"      || failed=1; }
[[ "$failed" -eq 0 ]] && { run_layer "6. Unit tests"  "${AUDIT_TEST_CMD:-}"      || failed=1; }
[[ "$failed" -eq 0 ]] && { run_layer "7. Integration tests" "${AUDIT_INTEGRATION_TEST_CMD:-}" || failed=1; }

if [[ "$failed" -eq 1 ]]; then
  echo
  echo "Audit stopped at the first failing layer. Fix it before continuing —"
  echo "layers after this one weren't run. A change that fails an early layer"
  echo "produces noise, not signal, at the later ones."
  exit 1
fi

echo
echo "All configured mechanical layers passed. Remember: layers 4/5, 8, 9,"
echo "and 10 from the 10-Layer Audit section still need to happen — this"
echo "reduces to a single reusable command."
exit 0
