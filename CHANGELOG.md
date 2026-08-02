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

## 2026-07-27 (map view) — A visual map of the whole UI, auto-generated from the same data

- Added a **Map view** to `UI-DETAIL.html`: a Table/Map toggle showing
  every panel and sub-element as color-coded nodes, grouped by feature
  letter, with curved connector lines drawn between related IDs
  (hover a node to highlight just its connectors). Generated entirely
  from the same `DATA` object the table already uses — no second data
  entry, no separate maintenance burden as more panels get added.
- Found and fixed a real bug during implementation: the view-switch
  handler called `requestAnimationFrame` unguarded, which threw in any
  environment where it isn't defined and silently skipped drawing the
  connectors. Added a `setTimeout` fallback and verified the fix with
  an error-tracking test, not just a visual check.
- Verified with 25 jsdom assertions across three rounds, including a
  direct test of the connection-deduplication logic (a relationship
  declared from either side, e.g. `a1↔a2`, collapses to exactly one
  connector) and confirmation that zero-size bounding rects (the
  unavoidable case in a test environment with no real layout engine)
  are skipped gracefully rather than drawing garbage lines at (0,0).
- Note: this round's work was lost once to a sandbox reset before it
  was committed, and had to be rebuilt from scratch on a fresh clone.
  Everything through the previous entry was safe on GitHub throughout;
  only the uncommitted map-view work needed redoing.

## 2026-07-27 (loop) — Tie the 3-commit check and the 10-layer audit together explicitly

- The completion gate now states the two as one loop, not two rules a
  reader might apply separately: `git log -3` for the touched area
  *before* starting (§15.4) → make the change → the full 10-layer audit
  *after* (§18) → the completion gate's questions. Added this as an
  explicit 4th completion-gate question ("did you check history before
  and does this fit the audit after?") so the connection is stated
  where it's most likely to actually be read, not left implicit across
  two separately-discoverable sections. Mirrored into
  `templates/AGENTS.md`.

## 2026-07-27 (yet again) — Navigation, descriptions, and real accessibility fixes

- Added **quick-jump navigation**: a row of pills, one per feature
  letter group, at the top of the viewer, so moving between groups no
  longer requires scrolling and hunting.
- Added an optional **panel description** field — a one-line summary of
  what a panel actually *is/does*, rendered under its name — since
  "appears when" is a condition, not a description, and nothing
  previously answered "what is this, in plain language."
- **Actually verified WCAG contrast** rather than assuming the color
  system passed: computed real contrast ratios for every color pair in
  the viewer. Found one genuine failure — the teal used for `link`-type
  badges was 3.36:1 against its background, below the 4.5:1 this
  repo's own design guide requires for text — and darkened it to a
  value that measures 4.91:1, still clearly the same hue.
- Added real accessibility fixes, not just color: a skip-to-content
  link, `scope="col"` on every table header, an `aria-live="polite"`
  status region that announces search result counts for screen reader
  users, `aria-labelledby` linking each feature-group section to its
  heading, and `prefers-reduced-motion` support disabling all
  transitions for anyone who's set that preference.
- Caught and fixed a real markup bug introduced while adding the skip
  link: an element ended up with two `id` attributes on it, which is
  invalid HTML and would have silently broken the skip link's target.
  Fixed by separating the skip-link landmark from the JS-injectable
  content container.
- Verified all of it with jsdom: 16 new assertions (quick-nav pill
  count and targets, table header scope, description rendering
  present/absent correctly, live-region role/aria-live attributes, and
  the actual announced text after searching, clearing, and a no-match
  search) plus a full 10-assertion regression pass confirming nothing
  from the previous rounds broke.

## 2026-07-27 (still more) — Modify-from-the-registry detail, and a real HTML upgrade

- Extended each sub-element entry with **"Key props / style"**: the
  actual prop names, state variables, and design tokens/classes that
  control it (`isSubmitting`, `variant="danger"`, `--color-danger`),
  not a description — the point being that a change can be made
  straight from the registry without reopening the component first.
- Added the **source-anchor convention**: a one-line `// UI-ID: b5.b`
  comment on the element it describes, so the link works in both
  directions — the registry names the file, and grepping the codebase
  for the ID finds the exact element.
- Rebuilt `UI-DETAIL.html`'s visual design around the design guide's own
  color principles rather than decoration: a deliberate, semantic
  per-type color system (button/input/link/toggle/banner each a
  distinct, muted, purposeful hue — not a random rainbow), a
  click-to-copy button on every ID (with a Clipboard-API-unavailable
  fallback), a `/` keyboard shortcut to jump to search, a proper
  no-results state, and hover/transition polish throughout.
- Caught and fixed a real self-consistency slip while building the copy
  button: the first draft used a 📋 clipboard emoji for the icon,
  directly contradicting this repo's own top design rule. Replaced with
  a real inline SVG icon before it shipped.
- Fixed a second real bug this round: moving the `id` attribute onto a
  nested span (to make room for the copy button) silently broke the
  existing search handler's `.id-cell` lookup and needed a follow-up
  fix — caught immediately by re-running the test suite, not by luck.
- Verified all of it with jsdom rather than trusting it by inspection:
  18 total test assertions across two rounds — rendering counts, props
  chips, color-coded badges, the cross-reference regex fix (still
  holding), hash-jump highlighting, copy-to-clipboard (both the modern
  API and the `execCommand` fallback path), the `/` shortcut (including
  that it correctly does *not* fire while already typing in search),
  and the no-results state appearing and clearing correctly.

## 2026-07-27 (one more) — Sub-element hierarchy: b5.a, b5.b, b5.c

- Extended the `UI-DETAIL.md`/`.html` registry one level deeper: a panel
  with 2+ actionable elements now gets sub-IDs (`b5.a`, `b5.b`, `b5.c`)
  for each button, input, or conditional banner inside it, using the
  same dot-notation extension of the existing scheme rather than a
  reversed or competing one. "Make b5.b show a spinner" is now
  unambiguous down to the exact element. Gated by the same Rule of
  Three restraint as elsewhere in the guide — a single-button panel
  doesn't need sub-IDs, since the panel ID alone is already specific.
- Updated `templates/UI-DETAIL.md` and `templates/UI-DETAIL.html` to
  match, with a worked example (`b5` with its cancel/confirm/warning
  elements).
- While extending the HTML viewer, found and fixed a real, separate bug
  in the *existing* cross-reference linking: the `linkify()` regex
  built ID patterns without escaping regex metacharacters, so a dotted
  ID like `b5.c` would have matched any string differing only in that
  one character (`.` is a regex wildcard). Fixed with a proper
  `escapeRegex()` step. Verified with a targeted test that deliberately
  injects a near-miss string (`b5X5c`) to confirm it's *not* incorrectly
  linkified — not just that the intended case still works.
- Extended search to handle parent/child visibility: a panel shows if
  it or any of its sub-elements match; a sub-element shows if it
  matches individually, or if its parent panel's own text matched (in
  which case all its children show for context). Tested 11 scenarios
  with a real DOM (jsdom): rendering count, dotted-ID lookup, the
  regex fix (both the intended match and the proven near-miss
  rejection), type badges, three search-visibility combinations,
  clearing search, and a no-match search hiding everything.

## 2026-07-27 (final for now) — UI-DETAIL.html viewer, and auto-opening it after UI work

- Added `templates/UI-DETAIL.html`: a self-contained, dependency-free
  viewer for web-app projects — the same rows as `UI-DETAIL.md`,
  embedded inline so it works via plain `file://` with no server, no
  build step, no fetch/CORS. Searchable, with clickable cross-reference
  links between IDs (e.g. "child of a1" jumps to a1). Tested with a real
  DOM (jsdom): rendering, search-filtering, hash-based jump/highlight,
  the empty state, and deprecated-row styling all verified. Found and
  fixed one real bug in the process — an unguarded `scrollIntoView` call
  threw and silently skipped the highlight logic; reordered so the
  highlight always applies and the scroll is best-effort.
- Extended the `Stop` hook in `templates/claude-code-settings.json` to
  auto-open `UI-DETAIL.html` (as a new tab, never replacing what's
  open) whenever a turn leaves `UI-DETAIL.md` with uncommitted changes
  — reuses the existing "update the registry when you touch UI"
  discipline as the detection signal instead of guessing at file
  extensions. Tested end-to-end with mocked `open`/`xdg-open` across
  three scenarios (no UI work, UI work this turn, hook-loop-guard).
  Documented honestly that no shell command can guarantee zero visual
  disruption — the real guarantee is "additional tab, never a
  replacement," not "silent."
- Ran the same header/cross-reference validation immediately after this
  edit, as after the previous two changes — clean this time, no repeat
  of the header-deletion mistake from the last two additions.

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
