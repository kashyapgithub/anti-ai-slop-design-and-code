# Anti-AI-Slop: Design and Code

Two field guides for producing work — and reviewing AI-generated work — that a competent person actually *chose*, rather than accepted because it was plausible-looking and technically present.

- **[`anti-ai-slop-code.md`](./anti-ai-slop-code.md)** — writing and reviewing code. Covers naming, error handling, testing (including why integration tests aren't optional), security, architecture, git/commit discipline, and a full case study of the Redis codebase.
- **[`anti-ai-slop-design.md`](./anti-ai-slop-design.md)** — visual and product design. Covers typography, color, layout, motion, accessibility, and the specific, data-grounded tells that mark 2026-era AI-generated UI.

Both guides open with a section addressed directly to AI coding agents ("Read This First") — if you're pointing an agent at this repo for context, that section is the load-bearing one: it sets architecture/visual-system decisions and integration testing as non-negotiable, before-you-write-code priorities, not general advice to skim.

## Using this with an agent

Point your agent at the raw files and it will find its own instructions for staying current:

```
https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/anti-ai-slop-code.md
https://raw.githubusercontent.com/kashyapgithub/anti-ai-slop-design-and-code/main/anti-ai-slop-design.md
```

Both files contain a "Keep your local copy synced with the source repo" section with exact commands for pulling both files into a project and re-checking periodically — this repo is updated on an ongoing basis, and a copy pasted in once will drift.

## `enforcement/`

Scripts that back the guide's rules with an actual gate instead of just prose: `check-architecture.sh` fails a build that adds a new top-level directory without an architecture-doc update; `check-integration-tests.sh` fails a build that touches a network/DB/queue boundary without a matching integration test; `run-audit.sh` chains the mechanical layers of the guide's 10-layer audit (format, type-check, lint, unit + integration tests) into one script, configurable via `config.env`. See [`enforcement/README.md`](./enforcement/README.md) for how to adopt them, including wiring `run-audit.sh` into a Claude Code `Stop` hook or a plain git `pre-commit` hook so it runs whether or not an agent chooses to run it itself.

## `templates/`

Drop-in `AGENTS.md` / `CLAUDE.md` (plus `opencode.json` / `kilo.jsonc` / `UI-DETAIL.md` + `UI-DETAIL.html`) that make an agent load the guide's non-negotiable rules automatically at session start, instead of relying on someone pasting them into chat. Covers Claude Code, opencode, Kilo Code, Google Antigravity IDE, Cursor, Copilot, Windsurf, and the rest of the tools converging on the `AGENTS.md` standard. See [`templates/README.md`](./templates/README.md).

## Status

Actively maintained and expanded — not a finished, static reference. See [`CHANGELOG.md`](./CHANGELOG.md) for what's changed and when; it's much cheaper to check than diffing the full guides on every sync.

## License

MIT — see [`LICENSE`](./LICENSE). Copy, fork, and adapt freely, including into your own project's `docs/` or `enforcement/`.
