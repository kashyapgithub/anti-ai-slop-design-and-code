# Anti-AI-Slop: Design and Code

Two field guides — plus the tooling to actually enforce them — for producing work, and reviewing AI-generated work, that a competent person *chose*, rather than accepted because it was plausible-looking and technically present.

This isn't just documentation. It's a working system: guides an agent reads automatically, rules backed by CI gates and git hooks that don't depend on the agent choosing to comply, and a couple of small tools (a UI registry, an audit runner) that make the rules practical to actually follow.

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

**The `UI-DETAIL.md` / `UI-DETAIL.html` registry system** — every screen, panel, or modal gets a stable ID (`a3`, `b5`, `n6`), where the letter maps directly onto the code guide's feature-folder structure and the number is permanent once assigned. Each entry records the *exact* condition under which it appears — not "shows up sometimes," but a real, checkable boolean. "Go to b5 and change this" becomes a directly actionable instruction instead of a description that has to be re-located in the codebase.

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

---

## Using this with an agent

Point it at the raw files and it finds its own instructions for staying current:

```
https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/anti-ai-slop-code.md
https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/anti-ai-slop-design.md
```

Or, better: drop `templates/AGENTS.md` (or the tool-specific config next to it) into a project so this happens automatically, every session, without anyone pasting a link into chat.

## Status

Actively maintained and expanded — not a finished, static reference. See [`CHANGELOG.md`](./CHANGELOG.md) for what's changed and when.

## License

MIT — see [`LICENSE`](./LICENSE). Copy, fork, and adapt freely, including into your own project's `docs/` or `enforcement/`.
