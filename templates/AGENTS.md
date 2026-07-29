# AGENTS.md

This project follows the Anti-AI-Slop guides for code and design:
https://github.com/kashyapgithub/anti-ai-slop-design-and-code

If your tool supports fetching URLs or you have the files locally, read
`docs/anti-ai-slop/anti-ai-slop-code.md` and `anti-ai-slop-design.md` in
full before nontrivial work — see "Keep your local copy synced" inside
each for the exact pull commands. What follows is the condensed,
non-negotiable subset so it's in context even before you've fetched them.

## Before every tool call, in every task: never destroy data

Check every single tool call — not just the ones that look risky —
against this before running it. This outranks the architecture rule
below and everything else in this file.

- Treat as destructive by default: `DROP`, `TRUNCATE`, a raw `DELETE`
  without a `WHERE` you've personally verified, `rm -rf`, any cloud
  console/CLI delete, a force-push, `git reset --hard`/`git clean -fd`,
  dropping a volume, deleting a secret or key.
- Verify the real target (connection string, env var, kubeconfig
  context) immediately before running — not from memory of a few tool
  calls ago. A correct destructive command against the wrong target is
  the most common real cause of an agent destroying production data.
- If a request's scope is ambiguous ("reset the dev database" could mean
  some rows, a table, or the whole database), ask — don't guess toward
  the broader, more destructive interpretation.
- Prefer non-destructive by default: soft delete, `--dry-run` first, a
  rollback-able transaction, a fresh backup taken right before, an
  explicit `WHERE`/`LIMIT` read twice.
- State what the command does and what's irreversible about it, and get
  explicit human confirmation for that specific execution — every time,
  not carried over from an earlier confirmation this session.

## If this project has a UI: never use emoji in it

Never place an emoji character anywhere a real person will see it
rendered as an interface — not as an icon, not as decoration next to a
heading, not in a button/badge label, not in generated copy that renders
on screen. Not weighed against tone; excluded regardless of tone. "Just
one, sparingly" is still a violation — the rule is never, not rarely.
Exceptions: content that's itself about emoji (an emoji picker, a real
user's own typed message) and an explicit, specific request for one
particular case. Use a real, consistent icon set instead.

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

**Log through one centralized logger, generously, not scattered
`console.log`/`print`.** Every significant function or step traces its
entry, exit, and branch taken at `debug` level, correlated by an ID
threaded through the whole operation — enough that any flow can be
reconstructed from logs alone after the fact, without re-running the
code. Redact sensitive fields even at debug level; summarize
high-frequency loops instead of one line per iteration.

**After two failed attempts at the same reported issue, stop guessing
from memory and actually research it before a third try.** Search the
exact error text, check current docs and the changelog for the version
in use, check the issue tracker — training data has a cutoff and is
frequently not enough, especially for library behavior that's changed
since. A third confident guess with no new information is the same
failure as the first two.

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
