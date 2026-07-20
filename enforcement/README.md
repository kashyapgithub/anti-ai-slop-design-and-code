# Enforcement gates

Everything in `anti-ai-slop-code.md`'s "Read This First" section is written
as an instruction to an AI agent — and an instruction in a markdown file is
context, not code. An agent can still skip it, especially deep into a long
session. These two scripts are the mechanical backstop for the two rules
that section calls top priority:

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
4. Push a PR and confirm both jobs run and pass on a normal change, then
   confirm they correctly fail on a change that should trip them (add a new
   top-level folder with no doc update; touch a boundary path with no test)
   before relying on them.

## Running locally

Both scripts take a base ref and a head ref and work outside CI too:

```bash
enforcement/check-architecture.sh main HEAD
enforcement/check-integration-tests.sh main HEAD
```

Useful for checking a branch before opening a PR, or for an agent to
self-check before reporting a task as finished — this is the literal,
scriptable version of the "completion gate" self-check in
`anti-ai-slop-code.md`.

## What this doesn't do

These gates catch structural signals — a new folder, a touched boundary
path — not judgment. A PR can still add a new folder that's a bad
architectural decision correctly documented, or add a technically-present
but useless integration test (an integration test that mocks out the real
boundary is exactly the failure §14.1 warns about, and no regex can catch
that). The gates raise the cost of skipping the process; they don't
replace a human — or a careful agent — actually reading the diff.
