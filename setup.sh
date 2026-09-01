#!/usr/bin/env bash
# setup.sh — one-command adopter for the anti-ai-slop guides.
#
# Run from your project root:
#
#   curl -fsSL https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/setup.sh | bash
#
# With flags, use process substitution instead of a plain pipe (a plain
# pipe leaves no stdin for anything interactive, and this script doesn't
# need any — but the redirect form is the convention worth knowing):
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/setup.sh) --all
#
# By default (no flags) this installs only the universal, cross-tool
# base: AGENTS.md + CLAUDE.md. Everything else is opt-in via flags,
# printed after every run and via --help.
#
# Never overwrites a file that already exists — always skips and says
# so, so this is safe to re-run.

set -euo pipefail

RAW="${ANTI_SLOP_RAW_URL:-https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main}"

fetch() {
  local dest="$1" url="$2"
  if [ -f "$dest" ]; then
    echo "  skip (already exists): $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if curl -fsSL "$url" -o "$dest"; then
    echo "  wrote: $dest"
  else
    echo "  FAILED to fetch: $url" >&2
    rm -f "$dest"
    return 1
  fi
}

# Parse flags (including --help) BEFORE fetching anything, so --help
# exits immediately instead of doing the base install first.
OPENCODE=0; KILO=0; FULL=0; ENFORCE=0; HOOKS=0; UI=0; LOG=0; ALL=0
for arg in "$@"; do
  case "$arg" in
    --opencode) OPENCODE=1 ;;
    --kilo) KILO=1 ;;
    --full-guides) FULL=1 ;;
    --enforcement) ENFORCE=1 ;;
    --claude-hooks) HOOKS=1 ;;
    --ui-detail) UI=1 ;;
    --prompt-log) LOG=1 ;;
    --all) ALL=1 ;;
    -h|--help)
      # Hardcoded, not read from "$0" — "$0" isn't a readable file when
      # this script runs via `curl | bash`, so self-reading would break
      # under the exact invocation method this is meant to support.
      cat <<'USAGE'
setup.sh — one-command adopter for the anti-ai-slop guides.

Usage:
  curl -fsSL <raw-url>/setup.sh | bash
  bash <(curl -fsSL <raw-url>/setup.sh) --all

Flags:
  --opencode       opencode.json (live-syncs the guide every session)
  --kilo           kilo.jsonc (same, for Kilo Code)
  --full-guides    the full reasoning behind AGENTS.md's rules
  --enforcement    CI-style gate scripts + a git pre-commit hook
  --claude-hooks   Claude Code Stop/PreToolUse/PostToolUse hooks
  --ui-detail      UI-DETAIL.md/.html starter (if this project has a UI)
  --prompt-log     PROMPT-LOG.md/.html starter (optional, adopt when earned)
  --all            everything above

No flags: installs only AGENTS.md + CLAUDE.md, the universal base.
Existing files are never overwritten — safe to re-run with new flags.
USAGE
      exit 0
      ;;
    *) echo "Unknown flag: $arg (ignored — see --help)" >&2 ;;
  esac
done

echo "Setting up anti-ai-slop guides in $(pwd)"
echo

echo "Base (always):"
fetch "AGENTS.md" "$RAW/templates/AGENTS.md"
fetch "CLAUDE.md" "$RAW/templates/CLAUDE.md"
echo

if [ "$OPENCODE" = "1" ] || [ "$ALL" = "1" ]; then
  echo "opencode:"
  fetch "opencode.json" "$RAW/templates/opencode.json"
  echo "  (points opencode at this repo's live raw files — re-pulls the"
  echo "   current guide automatically every session, no manual sync)"
  echo
fi

if [ "$KILO" = "1" ] || [ "$ALL" = "1" ]; then
  echo "Kilo Code:"
  fetch "kilo.jsonc" "$RAW/templates/kilo.jsonc"
  echo
fi

if [ "$FULL" = "1" ] || [ "$ALL" = "1" ]; then
  echo "Full guides (the reasoning behind AGENTS.md's condensed rules):"
  fetch "docs/anti-ai-slop/anti-ai-slop-code.md" "$RAW/anti-ai-slop-code.md"
  fetch "docs/anti-ai-slop/anti-ai-slop-design.md" "$RAW/anti-ai-slop-design.md"
  echo
fi

if [ "$ENFORCE" = "1" ] || [ "$ALL" = "1" ]; then
  echo "Enforcement scripts:"
  fetch "enforcement/config.env" "$RAW/enforcement/config.env"
  fetch "enforcement/check-architecture.sh" "$RAW/enforcement/check-architecture.sh"
  fetch "enforcement/check-integration-tests.sh" "$RAW/enforcement/check-integration-tests.sh"
  fetch "enforcement/check-destructive-ops.sh" "$RAW/enforcement/check-destructive-ops.sh"
  fetch "enforcement/run-audit.sh" "$RAW/enforcement/run-audit.sh"
  chmod +x enforcement/*.sh 2>/dev/null || true
  if [ -d ".git" ]; then
    if [ -f ".git/hooks/pre-commit" ]; then
      echo "  skip (already exists): .git/hooks/pre-commit"
      echo "  -> fetch templates/pre-commit from the repo and merge it in by hand"
    else
      fetch ".git/hooks/pre-commit" "$RAW/templates/pre-commit"
      chmod +x .git/hooks/pre-commit 2>/dev/null || true
    fi
  else
    echo "  no .git/ found here — skipped the pre-commit hook (run 'git init' first if you want it)"
  fi
  echo "  fill in the AUDIT_* commands in enforcement/config.env for your"
  echo "  project's actual toolchain — the defaults are unset on purpose"
  echo
fi

if [ "$HOOKS" = "1" ] || [ "$ALL" = "1" ]; then
  echo "Claude Code hooks:"
  if [ -f ".claude/settings.json" ]; then
    echo "  skip (already exists): .claude/settings.json"
    echo "  -> fetch templates/claude-code-settings.json from the repo and merge the hooks in by hand"
  else
    fetch ".claude/settings.json" "$RAW/templates/claude-code-settings.json"
  fi
  echo
fi

if [ "$UI" = "1" ] || [ "$ALL" = "1" ]; then
  echo "UI registry:"
  fetch "UI-DETAIL.md" "$RAW/templates/UI-DETAIL.md"
  fetch "UI-DETAIL.html" "$RAW/templates/UI-DETAIL.html"
  echo "  delete UI-DETAIL.html's example DATA entries before using it for"
  echo "  real (marked clearly in a comment above the object)"
  echo
fi

if [ "$LOG" = "1" ] || [ "$ALL" = "1" ]; then
  echo "Prompt log (optional — only worth it once there's real history):"
  fetch "PROMPT-LOG.md" "$RAW/templates/PROMPT-LOG.md"
  fetch "PROMPT-LOG.html" "$RAW/templates/PROMPT-LOG.html"
  echo
fi

echo "Done."
echo
echo "Available flags for more (safe to re-run with different flags —"
echo "existing files are never overwritten):"
echo "  --opencode       opencode.json (live-syncs the guide every session)"
echo "  --kilo           kilo.jsonc (same, for Kilo Code)"
echo "  --full-guides    the full reasoning behind AGENTS.md's rules"
echo "  --enforcement    CI-style gate scripts + a git pre-commit hook"
echo "  --claude-hooks   Claude Code Stop/PreToolUse/PostToolUse hooks"
echo "  --ui-detail      UI-DETAIL.md/.html starter (if this project has a UI)"
echo "  --prompt-log     PROMPT-LOG.md/.html starter (optional, adopt when earned)"
echo "  --all            everything above"
