# Anti-AI-Slop: Design and Code

## Copy-paste this into any project folder — your agent does the rest

One command, run from the root of whatever project you're in (no install, no config, no account — it fetches everything from [github.com/kashyapgithub/anti-ai-slop-design-and-code](https://github.com/kashyapgithub/anti-ai-slop-design-and-code)):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/setup.sh) --all
```

That's the entire integration. The moment it finishes:

- **Your agent auto-loads the rules.** `AGENTS.md` + `CLAUDE.md` land in the project root — Claude Code, opencode, Cursor, Copilot, Windsurf, Kilo, Antigravity and anything else on the `AGENTS.md` standard read them on every session, with no prompt engineering. `opencode.json` / `kilo.jsonc` point those tools at the *live* guide, so the rules re-pull each session instead of going stale.
- **Gates enforce what the agent reads.** A `pre-commit` hook scans every commit for destructive ops (`DROP`/`TRUNCATE`/unscoped `DELETE`/`rm -rf`/force-push/`reset --hard`) and refuses it without an explicit `CONFIRMED-DESTRUCTIVE:` marker; the architecture and integration-test gates are wired the same way. Git itself refuses the commit — an agent choosing not to comply doesn't matter.
- **Claude Code gets hooks that fire *before* the damage** — a `PreToolUse` hook blocks a destructive Bash command pre-execution (fails closed, not open), a `Stop` hook runs the audit each turn, a `PostToolUse` hook auto-formats edited files.
- **The full guides come along** in `docs/anti-ai-slop/` (the reasoning behind every condensed rule), plus `UI-DETAIL.md`/`.html` for the UI registry.

It never overwrites an existing file — safe to re-run with different flags. Want the minimal version instead? Drop `--all` and plain-pipe it; that installs just the `AGENTS.md` + `CLAUDE.md` base. Full flag list under [Using this with an agent](#using-this-with-an-agent).

### What that looks like in practice — a real run, not a demo

The command above was pointed at an empty folder (`education.ai`, `git init`, zero files, no stack chosen) and produced this, in order:

| Step | Result |
|---|---|
| 1. Ran the one-liner | 17 files: base rules (`AGENTS.md`, `CLAUDE.md`), live-sync configs, both full guides under `docs/anti-ai-slop/`, 4 enforcement scripts + `config.env`, the pre-commit hook, `.claude/settings.json` hooks, `UI-DETAIL.md`/`.html`, `PROMPT-LOG.md`/`.html` |
| 2. First `git commit` | **The pre-commit gate refused it.** `.claude/settings.json` embeds the detector's own destructive-op regex (it's the hook that blocks `rm -rf`), so the scan flagged the hook file itself — the gate firing on real input, not a staged demo |
| 3. One-line fix | Added `^\.claude/settings\.json$` to `DESTRUCTIVE_OP_EXEMPT_REGEX` in `enforcement/config.env` — the only edit needed |
| 4. Re-ran the commit | Destructive-ops scan passed, all configured audit layers ran, commit landed |

End state of one command plus one commit: every future commit is scanned no matter who (or what) makes it, every agent that opens the folder is briefed before its first tool call, and destructive Bash is blocked before it executes — so the human starts on the actual product (the PRD, in that case) instead of on project setup. The installer itself doesn't write a PRD or pick a stack; it deliberately leaves `AUDIT_*` empty until the project has a toolchain, and says so.

---

## Why this repo produces genuinely better code and design

- **The rules are written to the agent, priority-ordered, not summarized for a human reader.** "Read This First" settles conflicts explicitly: never destroy data outranks everything; architecture is decided before code is written, not discovered by writing it.
- **A task cannot be declared done on unit tests alone.** A three-question completion gate blocks the "tests pass, therefore shipped" reflex — anything touching a network call, database write, or queue needs an integration test exercising the real boundary, not a mocked one.
- **The top rules are mechanical, not advisory.** The destructive-op scanner, the architecture gate, and the integration-test gate run at the git boundary and in CI, so compliance never depends on the agent choosing to comply — git itself refuses the commit.
- **The 10-Layer Audit chains the mechanical checks in order** — format, type-check, lint, dependency audit, SAST, unit tests, integration tests, architecture, comprehension, runtime smoke — stopping at the first failure so the layers after it aren't producing noise instead of signal.
- **25 named slop tells for code and 32 for design**, each a specific recognizable pattern with a fix, including a 2026 agentic-era addendum for the tells that only appeared once agents started writing most of the code.
- **The design diagnostics come from data, not taste.** They're grounded in a large-scale study ranking which visual tells people actually cite, where plain gradient defaults and unmodified shadcn/Tailwind styling outrank bento grids and glassmorphism — so the guide attacks the tells that real users notice, not the ones designers argue about.
- **The design guide has its own hard top rule:** no emoji anywhere in a UI, with the icon-vs-emoji distinction spelled out (a real icon set is fine, an emoji standing in for one is the violation) — so "just one, sparingly" can't creep in.
- **Every screen, panel, and button gets a permanent stable ID** (`a3`, `b5.b`) in a two-way-linked registry: the `UI-ID:` comment in the source and the `UI-DETAIL` entry point at each other, and the self-contained viewer regenerates its table, map, and data-flow views from one data source — "go to `b5.b` and change it" is unambiguous, and nothing drifts out of sync as the product grows.
- **Commit messages and comments are graded, not vibes.** Every message must answer what, why, and where; every comment is checked against the code beside it before shipping — never stale, because a stale comment is trusted by default and is worse than none.
- **Debugging has a fixed order:** last 5 commits first when something breaks, last 3 before any nontrivial change — regression triage instead of a broad re-read and a round of guesses.
- **Two failed attempts at the same issue forces real research before a third** — exact error text, current docs, the issue tracker — because training-data memory isn't evidence about the version actually in use.
- **Agreement tracks evidence, not social pressure.** A proposed diagnosis is verified against history, logs, or an actual reproduction before a fix is implemented, even when it's stated confidently — a claim repeated more forcefully is still not new evidence.
- **The rules can't quietly go stale.** The guides carry a self-sync mechanism, the opencode/Kilo configs re-pull the live copy every session, and the CHANGELOG groups every change by milestone so catching up costs one read.
- **One base file covers ~10 tools.** `AGENTS.md`/`CLAUDE.md` is read by Claude Code, opencode, Cursor, Copilot, Windsurf, Kilo, Antigravity and the rest of the standard — the same rules, no per-tool rewrites.
- **The gates are proven, not assumed.** Every enforcement script was tested against real pass/fail scenarios — a deliberately broken commit that git actually refused, then the same commit succeeding once fixed (the run above is one of those, caught on the installer's own files).

---

Two field guides — plus the tooling to actually enforce them — for producing work, and reviewing AI-generated work, that a competent person *chose*, rather than accepted because it was plausible-looking and technically present.

This isn't just documentation. It's a working system: guides an agent reads automatically, rules backed by CI gates and git hooks that don't depend on the agent choosing to comply, and a couple of small tools (a UI registry, an audit runner) that make the rules practical to actually follow.

> ### Featured: `UI-DETAIL.md` / `UI-DETAIL.html` — a stable-ID registry, a visual map, and a data-flow trace for every screen, panel, and button
> Every screen, panel, or modal gets a short, permanent ID — `a3`, `b5`, `n6` — where the letter maps directly onto the project's feature-folder structure and the number never gets reassigned. **It goes one level deeper too**: a panel with more than one actionable element gets sub-IDs (`b5.a`, `b5.b`, `b5.c`) for each button, input, or conditional banner inside it — each recording the actual prop/state/style-token names that control it, plus a matching `UI-ID:` comment in the source so the registry and the code link both ways. "Go to b5.b and change this" is now enough detail to make the change without reopening the component first. For web apps, `UI-DETAIL.html` is a self-contained, dependency-free viewer with **three views** on the same data: a searchable table, a **Map view** — color-coded nodes for every panel and element, connected by lines wherever entries reference each other — and a **Data Flow view** tracing which panels read or write each piece of shared data across the whole product, grouped by data entity rather than by feature. All three regenerate automatically from one data source — nothing to draw or keep in sync separately as the product grows. Click-to-copy on every ID, a `/` shortcut to search, quick-jump navigation, live result announcements for screen readers, and colors verified against WCAG AA rather than eyeballed. Auto-opens (as a new tab, never replacing what's already open) whenever an agent's turn touches the registry. See `anti-ai-slop-design.md` §12.3 and [`templates/UI-DETAIL.md`](./templates/UI-DETAIL.md) / [`templates/UI-DETAIL.html`](./templates/UI-DETAIL.html).

---

## What's in this repo

| Path | What it is |
|---|---|
| [`anti-ai-slop-code.md`](./anti-ai-slop-code.md) | The code guide — 21 sections, agent-directed priority rules, a full Redis case study |
| [`anti-ai-slop-design.md`](./anti-ai-slop-design.md) | The design guide — 14 sections, 2026-era AI-design-tell diagnostics, a UI registry system |
| [`enforcement/`](./enforcement) | Scripts that turn the guides' top rules into CI gates and git hooks |
| [`templates/`](./templates) | Drop-in files so any agent auto-loads the rules, across ~10 different tools |
| [`CHANGELOG.md`](./CHANGELOG.md) | What's changed, grouped by milestone — cheaper to check than diffing the guides |
| [`LICENSE`](./LICENSE) | MIT — copy, fork, adapt freely |

---

## The code guide (`anti-ai-slop-code.md`)

Opens with **"Read This First,"** written directly to AI agents, in priority order:

1. **Never destroy data** — the highest-priority rule in the whole repo. Verify the real target before any command that could drop/delete/overwrite something; ask rather than guess on ambiguous scope; get explicit confirmation for that exact operation, every time.
2. **Architecture is decided before code is written**, not discovered by writing it — including a bootstrapping flow for brand-new projects (write `ARCHITECTURE.md` before the first feature).
3. **A task isn't done on unit tests alone** — integration tests exercising the real boundary are non-negotiable.
4. Commit messages answer **what, why, and where**, technically and specifically.
5. Comments get checked against the code next to them before they ship — never stale, never ambiguous.
6. Logging is centralized and generous — entry/exit/branch traces at `debug` level, correlated by ID, enough to reconstruct any flow from logs alone.
7. **Regression triage**: check the last 5 commits before anything else when something breaks; check the last 3 before every nontrivial change, even without a complaint.
8. After two failed attempts at the same issue, **stop guessing from memory and actually research it** — exact error text, current docs, the issue tracker.
9. Ask how the person wants **git pushes** handled (auto/confirm/batch) — don't assume a workflow.
10. **Agreement tracks evidence, not social pressure** — verify a proposed diagnosis before implementing a fix for it; push back with specifics when the evidence disagrees.

Then a **completion gate** (three questions an agent must answer before calling a task done) and a **self-sync mechanism** so a local copy doesn't quietly go stale.

The numbered guide itself covers: 25 named "slop tells" (the original 20 plus a 2026 agentic-era addendum), naming, functions, control flow, error handling, types, comments, dependencies, security (including **slopsquatting** — AI-hallucinated package names attackers register in advance), concurrency, performance, testing, git/commit craft, using AI without producing slop, architecture & project structure, a **10-Layer Audit** (format → type-check → lint → deps → SAST → unit → integration → architecture → comprehension → runtime smoke check), a full review checklist, a **Redis case study** (why its codebase is held up as an example — the manifesto, the single-maintainer era, antirez's comment discipline), and further reading.

## The design guide (`anti-ai-slop-design.md`)

Same structure, its own top rule: **never use emoji in any UI** — not as icons, not "just one, sparingly," not in generated copy — with an explicit icon-vs-emoji distinction (icons from a coherent set are fine and often necessary; emoji standing in for them is the actual violation).

Covers: 32 diagnostic "slop tells" (the original 20 plus two later rounds grounded in real data — a large-scale study ranking which visual tells people actually cite, where plain gradient defaults and unmodified shadcn/Tailwind styling rank above bento grids and glassmorphism), typography, color, layout, components and interaction states, content/microcopy, motion, accessibility (including why **overlay widgets** are the accessibility version of slop), design tokens, internationalization, process (constraining a model before prompting it, committing design changes with real rationale), and a full review checklist.

**The `UI-DETAIL.md` / `UI-DETAIL.html` registry system** (see the callout at the top of this README) also lives here — every panel gets a stable, permanent ID mapped onto the feature-folder structure.

---

## `enforcement/` — rules backed by gates, not just prose

A markdown file can't force compliance. These scripts can:

- **`check-destructive-ops.sh`** — scans a diff (or, with `--staged`, what's about to be committed) for `DROP`/`TRUNCATE`/unscoped `DELETE`/`rm -rf`/force-push/`git reset --hard`, and fails unless an explicit `CONFIRMED-DESTRUCTIVE: ...` marker is present. The mechanical backstop for the guide's #1 rule.
- **`check-architecture.sh`** — fails a build that adds a new top-level directory without an architecture-doc update in the same change.
- **`check-integration-tests.sh`** — fails a build that touches a network/DB/queue boundary without a matching integration test.
- **`run-audit.sh`** — chains the mechanical layers of the 10-Layer Audit (format, type-check, lint, unit + integration tests) into one script, fully configurable via `config.env`.

All four are wired into `.github/workflows/anti-slop-gates.yml` for CI and `templates/pre-commit` for local use — every gate has been tested against real pass/fail scenarios (a deliberately broken commit that git actually refuses, then the same commit succeeding once fixed), not just written and assumed correct.

## `templates/` — so the rules load automatically, not by copy-paste

| File | What it does |
|---|---|
| `AGENTS.md` / `CLAUDE.md` | Condensed, auto-loaded standing rules — covers Claude Code, opencode, Kilo Code, Antigravity IDE, Cursor, Copilot, Windsurf, and the rest of the tools converging on the `AGENTS.md` standard |
| `opencode.json` / `kilo.jsonc` | Point those two tools' remote-URL instruction support directly at this repo's raw files — they pull the *live* guide every session, no manual sync |
| `claude-code-settings.json` | A `PreToolUse` hook that **blocks a destructive Bash command before it executes** (fails closed if config can't be loaded, not open); a `Stop` hook that runs the audit every turn and can force another turn on failure; a `PostToolUse` hook that auto-formats edited files; auto-opens `UI-DETAIL.html` as a new tab (never replacing what's open) whenever a turn touches the UI registry |
| `pre-commit` | Tool-agnostic git hook fallback — works no matter which agent (or human) is committing |
| `UI-DETAIL.md` / `UI-DETAIL.html` | Starter files for the UI registry system — the `.html` is self-contained, dependency-free, and works via plain `file://` with no server |
| `PROMPT-LOG.md` / `PROMPT-LOG.html` | Optional — a chronological log of the meaningful requests that shaped a project, adopted once there's real history worth tracking, not bootstrapped by default. Same self-contained, sorted-by-date viewer pattern as `UI-DETAIL.html` |

---

## Using this with an agent

**Fastest path — one command, run from your project root:**

```bash
curl -fsSL https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/setup.sh | bash
```

That installs `AGENTS.md` + `CLAUDE.md` — the universal, cross-tool base every agent in the coverage table above reads automatically. Everything else is opt-in via flags (run with `--help`, or use process substitution instead of a plain pipe if you want flags: `bash <(curl -fsSL .../setup.sh) --all`):

```
--opencode       opencode.json (live-syncs the guide every session)
--kilo           kilo.jsonc (same, for Kilo Code)
--full-guides    the full reasoning behind AGENTS.md's rules
--enforcement    CI-style gate scripts + a git pre-commit hook
--claude-hooks   Claude Code Stop/PreToolUse/PostToolUse hooks
--ui-detail      UI-DETAIL.md/.html starter (if this project has a UI)
--prompt-log     PROMPT-LOG.md/.html starter (optional, adopt when earned)
--all            everything above
```

Never overwrites a file that already exists — safe to re-run anytime with different flags.

**Or, without running anything:** point an agent straight at the raw guide files and it finds its own instructions for staying current:

```
https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/anti-ai-slop-code.md
https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/anti-ai-slop-design.md
```

## Status

Actively maintained and expanded — not a finished, static reference. See [`CHANGELOG.md`](./CHANGELOG.md) for what's changed and when.

## License

MIT — see [`LICENSE`](./LICENSE). Copy, fork, and adapt freely, including into your own project's `docs/` or `enforcement/`.
