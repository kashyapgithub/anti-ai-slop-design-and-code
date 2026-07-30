# Enforcement gates

Everything in `anti-ai-slop-code.md`'s "Read This First" section is written
as an instruction to an AI agent — and an instruction in a markdown file is
context, not code. An agent can still skip it, especially deep into a long
session. These scripts are the mechanical backstop for the rules that
section calls top priority — in priority order:

0. **Never destroy data, not even by accident** — `check-destructive-ops.sh`
   fails a build (or, installed as a pre-commit hook, refuses the commit
   outright) if the diff adds a `DROP`/`TRUNCATE`/unscoped `DELETE`,
   `rm -rf`, a force-push, or a `git reset --hard`/`git clean -fd` without
   an explicit `CONFIRMED-DESTRUCTIVE: ...` marker on that line or the one
   above it. This is the highest-priority gate in this folder — it runs
   before the other two, and it's the one wired into
   `templates/pre-commit` unconditionally, regardless of whether the rest
   of `run-audit.sh` is even configured.
1. **Architecture is a decision, not a side effect** — `check-architecture.sh`
   fails a PR that introduces a brand-new top-level directory without also
   touching an architecture doc (`ARCHITECTURE.md` / `AGENTS.md` / etc.) in
   the same change.
2. **Unit tests are not a substitute for integration tests** — `check-integration-tests.sh`
   fails a PR that touches a boundary path (API routes, DB/repository code,
   queues, external clients) without also touching a file that looks like an
   integration test.

Unlike the prose in the guide, these can't be quietly skipped: they run in
CI and fail the build.

## `run-audit.sh` — the same idea, but forced mid-session instead of at PR time

CI catches a bad change eventually, after it's pushed. `run-audit.sh`
chains the mechanical layers of the guide's "10-Layer Audit" section (format,
type-check, lint, unit tests, integration tests) into one script that
stops at the first failure — and it's meant to be wired into an agent's
own hook system, not just run by hand, so the check happens automatically
mid-session, before the agent even reports the task done.

For Claude Code specifically, `templates/claude-code-settings.json` wires
this in for real, with two different hooks doing two different jobs:

- **`PreToolUse` on the `Bash` tool** intercepts every shell command
  *before* it runs and blocks it (exit code 2, command never executes)
  if it matches a destructive pattern without the confirmation marker —
  this is what actually stops an agent from running
  `psql -c "DROP DATABASE prod;"` directly, since `check-destructive-ops.sh`
  alone only catches destructive operations that get committed to a
  file, not ones run ad hoc against a live database. **This hook fails
  closed, not open**: if `enforcement/config.env` can't be found or
  loaded for any reason, it falls back to a hardcoded minimal pattern
  (DROP/TRUNCATE/`rm -rf`/force-push/`git reset --hard`) rather than
  silently allowing everything through — an earlier version of this
  hook failed open on a missing config file, which is exactly backwards
  for a safety gate, and was caught and fixed by testing that specific
  case deliberately.
- **`Stop`** does two things every time Claude finishes responding, before
  Claude is allowed to actually stop. First, if `UI-DETAIL.md` has
  uncommitted changes (the signal that this turn did UI work, since the
  design guide's §12.3 already requires updating it whenever a panel
  changes), it opens `UI-DETAIL.html` via the OS's own opener — a new
  tab, never replacing whatever the person already has open; a shell
  command can't fully guarantee zero visual disruption, since focus
  behavior is the browser/OS's call, not the script's. Second, it runs
  `run-audit.sh`, and if that fails, exits with code 2 — which per
  Claude Code's hook system forces Claude to keep working instead of
  stopping, regardless of what the model itself decided.

Both are a genuinely different guarantee than anything else in this
repo: they don't rely on the agent choosing to comply, because these
hooks run deterministically outside the model's control. Copy the file
to `.claude/settings.json` (or merge it into an existing one) to use it.

Other tools' equivalents, as of mid-2026 — check before assuming, this
moves fast:
- **opencode** has a plugin system with blocking `tool.before.*` hooks
  (not a first-party settings file like Claude Code's, but real and
  scriptable — see the `opencode-hooks` community plugin).
- **Kilo Code** does not yet have first-class session lifecycle hooks;
  it's an open feature request as of early 2026.
- For any tool without native hooks — including Kilo Code until that
  ships — `templates/pre-commit` is the tool-agnostic fallback: copy it
  to `.git/hooks/pre-commit` and git itself will refuse a commit that
  fails the audit, regardless of which agent (or human) produced it.

Configure which commands actually run via the `AUDIT_*` variables at the
bottom of `config.env` — an unset command is skipped with a warning, not
silently treated as passing, so you always know what was and wasn't
actually checked.

## Adopting this in your own project

1. Copy this whole `enforcement/` directory into your repo.
2. Copy `.github/workflows/anti-slop-gates.yml` into your repo's own
   `.github/workflows/`.
3. Edit `enforcement/config.env` — every value in it is a guess about your
   project's layout until you set it deliberately:
   - `ARCHITECTURE_DOCS` — which file(s) count as "the architecture is
     documented here."
   - `ARCHITECTURE_EXEMPT_PATHS` — top-level paths that aren't architectural
     (CI config, editor config) and shouldn't trigger the gate.
   - `BOUNDARY_PATH_REGEX` — which paths count as crossing a real boundary
     in *your* codebase. The default guesses common names (`api/`, `db/`,
     `services/`, `queue/`...); rename it to match reality, don't leave the
     default in place unexamined.
   - `INTEGRATION_TEST_REGEX` — how your project names integration tests.
   - `BOUNDARY_EXEMPT_REGEX` — narrow exceptions (generated code, type-only
     files) that touch a boundary path but genuinely don't need a test.
   - `DESTRUCTIVE_OP_REGEX` / `DESTRUCTIVE_OP_CONFIRM_MARKER` /
     `DESTRUCTIVE_OP_EXEMPT_REGEX` — the patterns that count as destructive,
     the marker required to ship one deliberately, and paths (docs, this
     tooling's own files) that are exempt because they describe these
     patterns rather than execute them.
4. Install `templates/pre-commit` as `.git/hooks/pre-commit` — this is the
   one gate you want running locally, before a commit, not just in CI
   after the fact.
5. Push a PR and confirm all jobs run and pass on a normal change, then
   confirm they correctly fail on a change that should trip them (add a new
   top-level folder with no doc update; touch a boundary path with no test;
   add an unconfirmed `DROP TABLE`) before relying on them.
6. Fill in the `AUDIT_*` commands in `config.env` and, if you're on Claude
   Code, copy `templates/claude-code-settings.json` to `.claude/settings.json`
   so `run-audit.sh` runs automatically at the end of every turn.

## Running locally

All three scripts take a base ref and a head ref and work outside CI too
(`check-destructive-ops.sh` also takes `--staged` for checking what's
about to be committed):

```bash
enforcement/check-destructive-ops.sh --staged
enforcement/check-architecture.sh main HEAD
enforcement/check-integration-tests.sh main HEAD
```

Useful for checking a branch before opening a PR, or for an agent to
self-check before reporting a task as finished — this is the literal,
scriptable version of the "completion gate" self-check in
`anti-ai-slop-code.md`.

## What this doesn't do

These gates catch structural signals — a new folder, a touched boundary
path, a known-dangerous keyword — not judgment. A PR can still add a new
folder that's a bad architectural decision correctly documented, or add a
technically-present but useless integration test (an integration test
that mocks out the real boundary is exactly the failure the guide's
integration-testing section warns about, and no regex can catch that).
`check-destructive-ops.sh` specifically only catches the patterns in
`DESTRUCTIVE_OP_REGEX` — a destructive ORM call (`Model.objects.all().delete()`),
a stored procedure, or an admin panel action that drops data without
matching any of those literal keywords will not be caught. Extend the
regex for your stack's actual danger patterns rather than trusting the
defaults to be exhaustive. The `PreToolUse` hook only intercepts the
`Bash` tool — a destructive action taken through an MCP database tool,
an API call, or any other tool the agent has access to isn't covered by
it, and its fallback pattern (used when `config.env` can't be loaded) is
deliberately narrower than the full configured regex, so a correctly
loaded config still matters. The gates raise the cost of skipping the
process; they don't replace a human — or a careful agent — actually
reading the diff, or actual database-level safeguards (backups, least-
privilege credentials, a read replica for anything exploratory) that
don't depend on this repo's tooling at all.
