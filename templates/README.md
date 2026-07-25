# Auto-loading these guides into an agent's context

Everything in `anti-ai-slop-code.md` and `anti-ai-slop-design.md`'s "Read
This First" sections only works if an agent actually reads it — and no
markdown file can force that. What *can* be forced, mechanically, is
whether the agent sees it automatically, every session, without anyone
pasting it into chat: every major coding agent now auto-loads a specific
file from the repo root at startup.

| Tool | Auto-loaded file |
|---|---|
| Claude Code | `CLAUDE.md` |
| Cursor, Codex CLI, Copilot, Windsurf, Amp, Devin, Aider, Zed, JetBrains Junie | `AGENTS.md` (converging cross-tool standard) |
| GitHub Copilot (also) | `.github/copilot-instructions.md` |
| Gemini CLI | `GEMINI.md` |

## Adopting this in your own project

1. Copy `AGENTS.md` from this folder into your project's root. Fill in
   the "Project-specific context" section at the bottom — package
   manager, test command, naming conventions — the parts an agent
   genuinely can't know without being told.
2. Copy `CLAUDE.md` into your project's root too (or symlink it —
   `ln -s AGENTS.md CLAUDE.md` — so the two files can't drift apart).
   Claude Code will load it and follow the `@AGENTS.md` import.
3. Pull the full guides into `docs/anti-ai-slop/` per the sync
   instructions inside each guide, so an agent that does fetch further
   context finds the full reasoning, not just the condensed rules.
4. If you're on Cursor specifically, you can additionally set the
   equivalent rule file to "always apply" (rather than glob- or
   agent-requested-scoped) so it's injected on every single turn, not
   just read once at session start — stronger than a file the agent
   merely *can* read.

## What this does and doesn't do

This makes the rules present by default instead of something you have to
remember to paste. It does not make them unskippable — an agent can
still ignore an auto-loaded file the same way it could ignore a pasted
one, especially deep into a long session. For rules that actually cannot
be skipped, pair this with the CI gates in `../enforcement/` — those fail
the build regardless of what any agent did or didn't read.
