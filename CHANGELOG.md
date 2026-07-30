# Changelog

This repo is updated on an ongoing basis (see each guide's "Keep your
local copy synced" section). This file exists so a sync — human or
agent — can tell what's new since last time without diffing two ~800-line
files. Grouped by milestone, not by individual commit; newest first.

**Fact-check status:** the guide states specific, checkable claims (the
curl bug-bounty cancellation, Jazzband's shutdown, DORA report figures,
etc.) as fact, not as timeless truths — they were true when added, and
nothing re-verifies them automatically. Last spot-checked 2026-07-26
(curl and Jazzband claims re-confirmed accurate, both with more detail
available than when originally added). If you're an agent making heavy
use of one of these specific claims for something consequential, verify
it's still current rather than trusting the date above blindly.

## 2026-07-27 (later) — Trace-level debug logging, and fixing a source-of-truth gap

- Added §7.3: instrument every significant function/step with entry,
  exit, and branch-taken traces at `debug` level, correlated by ID, so
  any flow can be reconstructed from logs alone after the fact — with
  the same redaction and hot-loop-summarization limits as §7.2, and
  toggleable on demand rather than always-on in production.
- Fixed a real inconsistency this repo had drifted into: master logging
  had been added to `templates/AGENTS.md` in an earlier pass without
  ever becoming an actual standing rule in the source "Read This First"
  — the condensed file had content the full guide didn't. Added it
  properly as the sixth standing rule and re-synced `templates/AGENTS.md`
  against it.

## 2026-07-27 (yet even later) — UI-DETAIL.md: a stable-ID registry for every panel

- Added §12.3 to the design guide: maintain a `UI-DETAIL.md` registry
  giving every screen/panel/modal a stable ID (`a3`, `b5`, `n6`) so "go
  to b5 and change this" is directly actionable instead of a description
  that has to be re-located in the codebase. The ID scheme isn't
  arbitrary — the letter matches the feature-folder structure from the
  code guide's §17.1 directly, so the registry is a map onto a decision
  that already exists, not a second taxonomy to maintain by hand.
- Documents, for every entry, the exact "appears when" condition (a
  precise, checkable boolean, not vague prose) — the why behind each
  panel showing up, not just what it is.
- Added `templates/UI-DETAIL.md` as a ready-to-copy starter file, wired
  into the bootstrapping instructions in "Read This First" (create it
  alongside `DESIGN.md`, before the first panel exists) and into
  `templates/README.md`'s adoption steps.
- Caught and fixed the same header-deletion mistake as the previous
  entry, a second time, in a different file — an earlier edit in this
  same change deleted "## 13. The Anti-Slop Review Checklist" entirely.
  Found immediately by the same header-count validation, before commit.

## 2026-07-27 (yet later) — Push back on unverified theories instead of caving to pressure

- Added §16.1: agreement should track evidence, not social pressure. A
  user's confidence in a diagnosis isn't evidence for it — verify a
  proposed theory against git history, logs, or an actual reproduction
  before implementing a fix for it, and say so directly (with specifics)
  when the evidence doesn't support it, rather than quietly complying.
  A claim repeated more forcefully isn't new evidence. Explicitly doesn't
  override the destructive-operation or architecture rules — "the user
  sounded sure" is never sufficient justification for either on its own.
- Added as the eighth standing rule in "Read This First," with a matching
  checklist item, mirrored into `templates/AGENTS.md`.
- Caught and fixed a real editing mistake while making this change: an
  earlier str_replace accidentally deleted the "## 17. Architecture &
  Project Structure" header entirely — found immediately by re-running
  the standard header-count validation this repo now always runs before
  a commit, not by chance.

## 2026-07-27 (even later) — Ask about push workflow; commit messages must answer what/why/where

- Added §15.6: establish how the person wants pushes handled (auto-push,
  hold for confirmation, or batch-and-confirm) early in a session, by
  asking rather than guessing, and honor it for the rest of the session.
  Explicitly separated this from the never-destroy-data rule — a push
  preference is set once; destructive-operation confirmation is required
  every single time regardless of any push preference already agreed on.
- Strengthened §15.1: every commit message must now answer three
  questions explicitly and technically — what changed (named precisely),
  why (the actual problem, not "fixed bug"), and where it applies (the
  scope, and what it deliberately doesn't touch). Updated the structure
  template and checklist to match.
- Both added as new standing rules (now seven total) in "Read This
  First," mirrored into `templates/AGENTS.md`.

## 2026-07-27 (later still) — Icon vs. emoji: clarifying what's actually banned

- Refined the no-emoji-in-UI rule to make clear it's not a rule against
  icons — only against emoji standing in for them. Added the actual
  distinction (§7.4): an icon is a purpose-built, restylable graphic
  from a coherent system; an emoji is a fixed, full-color pictograph
  built for messaging, not UI, which is why it always looks pasted on.
  Icons remain fully fine, even necessary, when drawn from the project's
  existing coherent set at a consistent stroke weight — the violation is
  specifically reaching for a cringe emoji substitute instead. Mirrored
  into `templates/AGENTS.md` and the checklist.

## 2026-07-27 (later) — Strict no-emoji-in-UI rule

- Added a new top-priority rule at the very start of the design guide's
  "Read This First," ranked directly below the visual-system rule:
  never place an emoji anywhere a real person will see it rendered as
  UI — not as an icon, not in generated copy, not "just one, sparingly."
  Explicit exceptions only for content that's itself about emoji (a
  picker, a real user's own message) or an explicit, specific request.
  Broadened the matching checklist item and mirrored a condensed version
  into `templates/AGENTS.md` for any project with a UI, not just ones
  using the design guide directly.

## 2026-07-27 (later) — Never destroy data: the highest-priority rule and its mechanical backstops

- Added a new top-priority rule at the very start of "Read This First" —
  ranked above even the architecture rule — that any tool call must be
  checked against before running: never delete/drop/truncate/overwrite
  a database, table, file, volume, branch, or secret without explicit
  human confirmation for that exact operation, every time, no matter how
  confident or how many similar commands already ran safely this session.
- Added `enforcement/check-destructive-ops.sh`: scans a diff (or, with
  `--staged`, what's about to be committed) for DROP/TRUNCATE/unscoped
  DELETE/`rm -rf`/force-push/`git reset --hard`/`git clean -fd`, and
  fails unless the line carries an explicit `CONFIRMED-DESTRUCTIVE: ...`
  marker. Wired into `templates/pre-commit`, running first,
  unconditionally, ahead of the rest of the audit.
- Added a `PreToolUse` hook to `templates/claude-code-settings.json` that
  intercepts every `Bash` tool call and blocks a matching destructive
  command *before it executes* — the piece `check-destructive-ops.sh`
  alone can't cover, since a command run directly against a live
  database (not committed to a file) never shows up in a git diff.
- Found and fixed three real bugs during testing, not just written and
  assumed correct: the destructive-ops scanner was flagging its own
  documentation/comments as violations; `git push -f` shorthand wasn't
  originally caught; and the `PreToolUse` hook **failed open** (silently
  allowed a destructive command through) if `enforcement/config.env`
  couldn't be found — fixed to fail closed with a hardcoded fallback
  pattern instead. All caught by deliberately testing the missing-config
  and self-referential-documentation cases, not by inspection.

## 2026-07-27 — Escalate to real research after repeated failures

- Added §15.5: after two failed attempts at the same reported issue,
  stop guessing from memory and search — the exact error text, current
  docs/changelog for the version in use, the issue tracker — before a
  third try. Training data has a cutoff and is frequently insufficient,
  especially for library behavior that's changed since. Added as a fifth
  standing rule in "Read This First," mirrored into `templates/AGENTS.md`.

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
