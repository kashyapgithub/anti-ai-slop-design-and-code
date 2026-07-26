# Changelog

This repo is updated on an ongoing basis (see each guide's "Keep your
local copy synced" section). This file exists so a sync — human or
agent — can tell what's new since last time without diffing two ~800-line
files. Grouped by milestone, not by individual commit; newest first.

## 2026-07-26 — Debugging discipline and enforcement that doesn't depend on compliance

- Added `enforcement/run-audit.sh`, chaining the mechanical layers of the
  guide's 10-Layer Audit (format, type-check, lint, unit + integration
  tests) into one script, configurable via `enforcement/config.env`.
- Added `templates/claude-code-settings.json` — a Claude Code `Stop` hook
  that runs the audit deterministically at the end of every turn and can
  force another turn on failure, independent of what the model decided.
- Added `templates/pre-commit` — a tool-agnostic git hook fallback for
  everything without native agent hooks (including Kilo Code, which
  doesn't have first-class lifecycle hooks yet as of early 2026).
- Added the code guide's "10-Layer Audit" section: a sequential,
  command-by-command verification procedure from format/lint through a
  runtime smoke check.
- Added §15.2: when a user reports "something broke," check the last 5
  commits (`git log -5`, `git diff HEAD~5 HEAD --stat`) before a broad
  re-read of the codebase — the full escalation sequence through
  `git bisect` and non-git causes.
- Added §15.4: the proactive counterpart — check the last 3 commits
  *before* every nontrivial change, not just after a complaint, for
  duplication, contradiction, and stale assumptions.
- Added §7.2: one centralized logger, structured log lines, correlation
  IDs threading one operation's logs across every boundary it crosses,
  logging at boundaries (not just failures) — a "master log" as what
  actually makes a system debuggable.
- "Read This First" now carries four standing rules (commit messages,
  comment accuracy, reactive triage, proactive triage), all mirrored into
  `templates/AGENTS.md`.
- Fixed a class of latent bug in this repo itself: several files under
  `enforcement/` referenced the guide by bare section number (`§18`,
  `§14.1`), which silently goes stale every time the guide gets
  renumbered. References now pair the number with the section title.
- Deduplicated a fully-repeated explanation of the Stop-hook mechanism
  between `enforcement/README.md` and `templates/README.md`.

## 2026-07-25 — Wider agent coverage, commit-message and comment craft

- Extended the auto-load coverage beyond Claude Code to opencode, Kilo
  Code, and Google Antigravity IDE — including `templates/opencode.json`
  / `templates/kilo.jsonc`, which point those two tools' remote-URL
  instruction support directly at this repo's raw files, so they pull
  the live guide every session without a manual sync step.
- Added `templates/AGENTS.md` / `templates/CLAUDE.md` — a condensed,
  auto-loaded version of the top-priority rules for projects that adopt
  this guide.
- Elevated commit-message discipline and comment-clarity into "Read This
  First"; added a dedicated comment-clarity section with concrete
  confusing-vs-clear examples.
- Filled real gaps: observability/logging and database migration safety
  in the code guide; internationalization in the design guide.
- Added root `README.md` and MIT `LICENSE`.

## 2026-07-20 — Mechanical CI gates and the completion gate

- Added `enforcement/check-architecture.sh` and
  `check-integration-tests.sh` — CI gates that fail a build for an
  undocumented new top-level directory, or a boundary-crossing change
  with no integration test, backed by a `.github/workflows` template.
- Added the "completion gate" self-check to "Read This First": three
  questions an agent must answer explicitly before reporting a task
  done.
- Elevated integration testing to a top-priority, non-negotiable rule
  (unit tests alone no longer count as "done").
- Added self-sync instructions so an agent can pull both guides from
  this repo and re-check periodically instead of working from a copy
  that quietly goes stale.

## 2026-07-18 — Initial guides and early depth passes

- Published the initial `anti-ai-slop-code.md` and
  `anti-ai-slop-design.md`.
- Added the "Read This First" agent-directed architecture section, the
  Architecture & Project Structure section, and the Redis case study.
- Deepened both guides with 2026-era research: slopsquatting/phantom
  dependencies, agentic-era code tells, the AI design-tell backlash
  (gradient defaults, glassmorphism, bento grids), and a tragedy-of-the-
  commons framing for the agentic-PR flood maintainers are dealing with.
