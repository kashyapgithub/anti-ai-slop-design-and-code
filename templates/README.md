# Auto-loading these guides into an agent's context

Everything in `anti-ai-slop-code.md` and `anti-ai-slop-design.md`'s "Read
This First" sections only works if an agent actually reads it — and no
markdown file can force that. What *can* be forced, mechanically, is
whether the agent sees it automatically, every session, without anyone
pasting it into chat: every major coding agent now auto-loads a specific
file (or set of files) from the repo root at startup.

## Coverage

| Tool | What it auto-loads | Notes |
|---|---|---|
| **Claude Code** | `CLAUDE.md` | Native, auto-loaded; supports `@path` imports |
| **opencode** | `AGENTS.md` (falls back to `CLAUDE.md` if no `AGENTS.md`) | Also honors an `instructions` array in `opencode.json`, including **remote URLs** |
| **Kilo Code** | `AGENTS.md` (on by default) | Also honors an `instructions` array in `kilo.jsonc`, including **remote URLs**; per-directory `AGENTS.md` files load dynamically as the agent reads that subtree |
| **Google Antigravity IDE** | `AGENTS.md` as the cross-tool foundation, plus `~/.gemini/GEMINI.md` for Antigravity-only overrides and `.agents/rules/` for workspace supplements | Rule files are capped at 12,000 characters each — this repo's condensed `AGENTS.md` is well under that |
| **Cursor, Codex CLI, Copilot, Windsurf, Amp, Devin, Aider, Zed, JetBrains Junie** | `AGENTS.md` | Converging cross-tool standard — 28+ tools, 60,000+ repos as of mid-2026 |
| **GitHub Copilot** (additionally) | `.github/copilot-instructions.md` | |
| **Gemini CLI** | `GEMINI.md` | Separate from Antigravity's `GEMINI.md` path — see the note below if you run both on one machine |

In short: **`AGENTS.md` alone now covers the large majority of tools.** Claude Code is the one significant tool that needs a nudge (the `@AGENTS.md` import in `CLAUDE.md` below) to read the same file instead of expecting its own.

## Making the audit actually run, not just get read

`AGENTS.md` and `CLAUDE.md` are read at session start — an agent can still choose not to act on them. `claude-code-settings.json` in this folder is a different kind of mechanism: it wires `../enforcement/run-audit.sh` into a Claude Code `Stop` hook, which runs deterministically every time Claude finishes responding and can force another turn (exit code 2) if the audit fails — this doesn't depend on the model choosing to comply. Copy it to `.claude/settings.json` in your project.

Other tools' equivalents, as of mid-2026 — check before assuming, this moves fast:
- **opencode** has a plugin system with blocking `tool.before.*` hooks (not a first-party settings file like Claude Code's, but real and scriptable — see the `opencode-hooks` community plugin).
- **Kilo Code** does not yet have first-class session lifecycle hooks; it's an open feature request. Until it ships, `AGENTS.md`'s prose plus an external git pre-commit/pre-push hook running `run-audit.sh` is the closest deterministic equivalent for Kilo.
- For any tool without native hooks, a plain **git hook** (`.git/hooks/pre-commit` calling `run-audit.sh`) works regardless of which agent is driving, since it gates at the commit boundary instead of inside the agent.

## Adopting this in your own project

1. Copy `AGENTS.md` from this folder into your project's root. Fill in
   the "Project-specific context" section at the bottom — package
   manager, test command, naming conventions — the parts an agent
   genuinely can't know without being told.
2. Copy `CLAUDE.md` into your project's root too (or symlink it —
   `ln -s AGENTS.md CLAUDE.md` — so the two files can't drift apart).
   Claude Code will load it and follow the `@AGENTS.md` import.
3. **If you use opencode or Kilo Code**, copy `opencode.json` and/or
   `kilo.jsonc` into your project root (merge the `instructions` array
   into an existing config if you already have one). Both files point
   directly at this repo's raw GitHub URLs, so those two tools pull the
   full, current guides at the start of every session automatically —
   no manual sync step needed for them specifically.
4. For everything else (Antigravity, Cursor, Copilot, Windsurf, Claude
   Code, and any tool without remote-URL support), pull the full guides
   into `docs/anti-ai-slop/` per the sync instructions inside each guide,
   so an agent that does read further finds the full reasoning, not just
   the condensed rules in `AGENTS.md`.
5. **If you run both Antigravity IDE and Gemini CLI on the same machine**,
   note they currently share the same global config path
   (`~/.gemini/GEMINI.md`), which can leak rules between the two tools.
   Put shared rules in `~/.gemini/AGENTS.md` instead (Gemini CLI ignores
   it, Antigravity reads it) and keep `GEMINI.md` for Antigravity-only
   overrides.
6. If you're on Cursor specifically, you can additionally set the
   equivalent rule file to "always apply" (rather than glob- or
   agent-requested-scoped) so it's injected on every single turn, not
   just read once at session start — stronger than a file the agent
   merely *can* read.
7. For a tool-agnostic fallback that works no matter which agent (or
   human) is committing, copy `pre-commit` into `.git/hooks/pre-commit`
   and `chmod +x` it — git itself will refuse a commit that fails the
   audit, regardless of what wrote the change.

## What this does and doesn't do

This makes the rules present by default instead of something you have to
remember to paste. It does not make them unskippable — an agent can
still ignore an auto-loaded file the same way it could ignore a pasted
one, especially deep into a long session. For rules that actually cannot
be skipped, pair this with the CI gates in `../enforcement/` — those fail
the build regardless of what any agent did or didn't read.
