# AGENTS.md

This project follows the Anti-AI-Slop guides for code and design:
https://github.com/kashyapgithub/anti-ai-slop-design-and-code

If your tool supports fetching URLs or you have the files locally, read
`docs/anti-ai-slop/anti-ai-slop-code.md` and `anti-ai-slop-design.md` in
full before nontrivial work — see "Keep your local copy synced" inside
each for the exact pull commands. What follows is the condensed,
non-negotiable subset so it's in context even before you've fetched them.

## Non-negotiable, every task

**Architecture is decided before code is written, not discovered by
writing it.** Before creating any new file:
- Check for an existing structural convention (this file, or the shape
  of the most recently touched similar feature) and match it exactly.
- Never create a new top-level directory, abstraction layer, or parallel
  "helper" location as a side effect of an unrelated task. If the
  existing structure genuinely doesn't fit, surface that as an explicit
  decision — don't route around it silently.
- On a brand-new project with no existing convention, write one down
  (this file, or `ARCHITECTURE.md`) before generating the first feature.

**A task is not finished on unit tests alone.** If the change touches a
network call, a database write, a queue, or another module, it needs an
integration test exercising the real boundary — not just unit tests
against a mocked version of it. Mocking everything is exactly how a
green test suite hides a broken connection between two pieces of code.

**Every commit message explains why, not just what.** `git diff` already
shows what changed. "fix stuff" / "update files" / an unexplained
restatement of the diff are not acceptable. If you generated the change,
you're the one guaranteed to know why it was needed right now — write
that down before it's lost.

**Every comment is checked against the code next to it before it ships.**
A stale or ambiguous comment is worse than none, because the next reader
trusts it by default.

**When a user reports "something broke," check the last 5 commits
before anything else.** `git log -5 --oneline` and
`git diff HEAD~5 HEAD --stat` first — not a broad re-read of the
codebase, not a round of clarifying questions.

**Before every nontrivial change, not just after a complaint, check the
last 3 commits for the area you're touching.** `git log -3 --oneline`
and `git diff HEAD~3 HEAD --stat` — check for duplication, contradiction
with a recent decision, and stale assumptions before you start, and
again after you finish.

**Log through one centralized logger, not scattered `console.log`/
`print`.** Structured log lines, a correlation ID threaded through every
downstream call for one operation, and boundary calls logged on the way
in and out — not just when something throws.

## Before you report a task as done

Answer these explicitly in your output, not just in your own reasoning:
1. Where does this live, and why — in terms of this project's actual
   structure, not "it seemed to fit here"?
2. What integration test proves the pieces you touched actually work
   together? If the honest answer is "only unit tests," it isn't done.
3. Did you introduce a new folder, pattern, or dependency this project
   didn't already have? If so, was that surfaced as a decision, or did
   it slip in as a side effect?

If you can't answer all three without hedging, the task isn't finished —
go close the gap before handing the work back.

## Project-specific context

<!-- Fill in for your actual project: package manager, test command,
     framework version, naming conventions that differ from language
     defaults, anything a new contributor would otherwise have to ask
     about twice. Keep this section — and the whole file — updated as
     the project's real conventions solidify; a stale AGENTS.md actively
     misleads the next agent that reads it. -->
