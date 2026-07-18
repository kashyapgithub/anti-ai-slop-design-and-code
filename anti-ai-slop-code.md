# The Anti-AI-Slop Code Guide

> A rigorous field guide for writing code that a competent engineer *chose* and can *defend* — not code that was generated to satisfy a prompt and abandoned. AI slop code is plausible-looking, superficially complete, and quietly wrong, lazy, or unmaintainable. This document is about the difference — with concrete examples, named principles, and testable heuristics.

**Audience:** engineers shipping real software (and anyone using AI to help write it). Every rule states *why it matters* and *how to verify it*. A guideline you can't check is just a preference.

---

## Table of Contents
1. [What AI Slop Code Actually Is](#1-what-ai-slop-code-actually-is)
2. [The Diagnostic: 20 Slop Tells](#2-the-diagnostic-20-slop-tells)
3. [First Principles](#3-first-principles)
4. [Naming](#4-naming)
5. [Functions & Structure](#5-functions--structure)
6. [Control Flow & Complexity](#6-control-flow--complexity)
7. [Error Handling](#7-error-handling)
8. [Types & Contracts](#8-types--contracts)
9. [Comments & Documentation](#9-comments--documentation)
10. [Dependencies & Reuse](#10-dependencies--reuse)
11. [Security](#11-security)
12. [Concurrency & Resource Safety](#12-concurrency--resource-safety)
13. [Performance (measured, not guessed)](#13-performance)
14. [Testing](#14-testing)
15. [Git, Reviews & Collaboration](#15-git-reviews--collaboration)
16. [Using AI Without Producing Slop](#16-using-ai-without-producing-slop)
17. [Architecture & Project Structure](#17-architecture--project-structure)
18. [The Anti-Slop Review Checklist](#18-the-anti-slop-review-checklist)
19. [Case Study: Redis — Craft at the Systems-Programming Level](#19-case-study-redis--craft-at-the-systems-programming-level)
20. [Further Study](#20-further-study)

---

## 1. What AI Slop Code Actually Is

Slop is not "code with bugs." All code has bugs. Slop is **code optimized to look done rather than to be correct**. Three signatures:

1. **Plausibility over correctness.** It resembles a solution to the problem class but doesn't handle *this* problem's real inputs, edge cases, or failure modes.
2. **Ceremony over substance.** Layers of abstraction, defensive checks for impossible states, and narration comments that add characters but not value.
3. **The happy path only.** No empty input, no timeout, no partial failure, no concurrency, no cleanup — because generation is rewarded for the demo, not the incident at 3 a.m.

The counterweights are old and boring on purpose: **KISS**, **YAGNI**, **DRY (in moderation)**, **the Boy Scout Rule** ("leave the code cleaner than you found it" — Robert C. Martin), and the Zen of Python's *"Simple is better than complex; explicit is better than implicit; special cases aren't special enough to break the rules."*

---

## 2. The Diagnostic: 20 Slop Tells

Three or more and you're reading slop.

**Comments & noise**
1. Narration comments: `// increment i by 1` above `i++`.
2. Commented-out code blocks left "just in case."
3. Docstrings that restate the signature and lie about behavior.

**Error handling**
4. `catch (e) { console.log(e) }` then continues as if fine.
5. Bare `except:` / `catch (Throwable)` swallowing everything.
6. Errors turned into `null`/`-1`/`""` sentinels with no documentation.

**Types & correctness**
7. `any` sprinkled through TypeScript; `# type: ignore` to silence, not fix.
8. Nullability ignored — no handling for `undefined`/`None`.
9. `==` vs `===`, loose coercion, floating-point money.

**Structure**
10. Copy-pasted blocks with one value changed instead of a loop/param.
11. Five-layer abstraction (`Factory→Manager→Service→Helper→Util`) over 10 lines.
12. God functions: 200 lines, 8 parameters, 6 responsibilities.
13. Reinvented `debounce`/`uuid`/date math/deep-clone/crypto.

**Completeness**
14. Only the happy path; no empty/timeout/partial-failure handling.
15. `// TODO: implement`, `return true // for now`, hardcoded demo returns.
16. No tests, or tests that can't fail (`expect(true).toBe(true)`).

**Safety**
17. Secrets/API keys hardcoded in source.
18. String-concatenated SQL / shell / HTML (injection).
19. Resources opened, never closed (files, sockets, DB connections).

**Consistency**
20. Mixed naming, quotes, and patterns within one file; ignores project conventions.

### 2.1 The 2026 Addendum: Agentic-Era Tells

As of 2026, generation happens mostly through agentic tools (Claude Code, Copilot Workspace, Cursor agents) that write, run, and commit code with less human review per line than ever. That shifts *where* slop hides:

21. **Phantom dependencies.** A package name that looks plausible (`aws-helper-sdk`, `fastapi-middleware`) but doesn't exist in the registry, or exists but isn't the one the model meant — see [§11.1](#111-slopsquatting-verify-every-ai-suggested-dependency).
22. **Invented flags and APIs.** A CLI flag, config key, or library method that sounds right but was never shipped — the model pattern-matched from a similar tool instead of checking the current docs.
23. **Config-only "fixes."** An agent asked to fix a bug edits a linter rule, a test threshold, or a CI skip list instead of the code, making the symptom disappear without touching the cause.
24. **Unrun code.** Multi-file changes where the agent never actually executed the code path it wrote — no build, no test run, no manual check — because the harness rewards a plausible diff over a verified one.
25. **Silent scope creep.** An agent asked for one function also "helpfully" refactors adjacent files, renames variables, or reformats unrelated code, burying the real change in noise the reviewer has to untangle.

---

## 3. First Principles

### 3.1 Understand before you write
Read the surrounding code. Match its conventions, error strategy, and abstractions. Slop is code written *at* a codebase; craft is code written *within* it. Run the linter/formatter the project already uses.

### 3.2 Solve the actual problem
Enumerate the *real* inputs and failure modes for **this** use case: empty, huge, malformed, concurrent, offline, rate-limited, partial. A generic solution that ignores them is slop even if it compiles.

### 3.3 Prefer boring, obvious code
> *"Debugging is twice as hard as writing the code. So if you write it as cleverly as possible, you are, by definition, not smart enough to debug it."* — Kernighan's Law

Optimize for the next reader (often future-you). Simplicity is a decision.

### 3.4 Every line must justify itself
If you can't explain why a line exists, delete it. Slop accumulates; craft subtracts. YAGNI: build for today's requirements, not imagined ones.

### 3.5 Make the change easy, then make the easy change
(Kent Beck.) If a change is awkward, refactor the surrounding code first — don't bolt on a special case that adds a slop layer.

---

## 4. Naming

Naming is the cheapest, highest-leverage readability lever. *"There are only two hard things in Computer Science: cache invalidation and naming things."* — Phil Karlton.

**Slop:** `data`, `data2`, `tmp`, `res`, `flag`, `obj`, `arr`, `handleData`, `doStuff`, `foo`.

**Better:**
- Name by **intent + domain**: `pendingOrders`, `retryAfterMs`, `isEmailVerified`, `maxRetries`.
- Booleans read as questions: `isActive`, `hasAccess`, `shouldRetry`, `canPublish`.
- Functions are **verbs** (`fetchInvoice`, `normalizeEmail`); values are **nouns**.
- No Hungarian/type-encoding names (`strName`, `arrItems`) — the type system already says that.
- Avoid abbreviations unless universal in the domain (`id`, `url`, `http`).
- Length should scale with scope: a loop index `i` is fine; a module-level export is not.
- Keep tense, casing, and vocabulary consistent (`get*` vs `fetch*` vs `load*` — pick one meaning per prefix).

---

## 5. Functions & Structure

- **One job, one level of abstraction** per function. If you narrate it with "and," split it.
- **Small, but not fragmented.** Extract when a block has a *nameable* purpose; don't shatter logic into 1-line functions for their own sake.
- **Few parameters.** 0–3 ideal. Beyond that, pass an options object and destructure; avoid boolean flag params (`render(true)` — true what?).
- **No hidden side effects.** A function named `getUser` must not also write to a cache and send analytics. Command/Query Separation: it either returns data or changes state, not both silently.
- **Prefer pure functions**; push side effects (I/O, mutation, time, randomness) to the edges. Pure logic is trivially testable.
- **Don't abstract prematurely.** The Rule of Three: extract shared abstraction on the *third* occurrence, not the first. A `BaseAbstractHandlerFactory` wrapping one caller is slop.
- **Return early** to reduce nesting (see §6).

---

## 6. Control Flow & Complexity

### 6.1 Guard clauses over nested pyramids
```js
// slop
function pay(user) {
  if (user) {
    if (user.isActive) {
      if (user.balance > 0) {
        // ...real work buried 3 levels deep
      }
    }
  }
}
// better
function pay(user) {
  if (!user) throw new Error("pay: user is required");
  if (!user.isActive) return { status: "skipped", reason: "inactive" };
  if (user.balance <= 0) return { status: "skipped", reason: "no_balance" };
  // real work at the top level
}
```

### 6.2 Watch cyclomatic complexity
Deeply branchy functions are hard to test and reason about. If a function needs many test cases just to cover its branches, decompose it. Replace long `if/else` chains or `switch`es on type with polymorphism or a lookup table where it clarifies.

### 6.3 No magic numbers/strings
Name them: `const MAX_UPLOAD_BYTES = 5 * 1024 * 1024;` beats a bare `5242880` three files away from its meaning.

### 6.4 Immutability by default
Prefer `const`/`readonly`/frozen data. Mutating shared state across functions is a top source of "impossible" bugs.

---

## 7. Error Handling

**Slop:**
```js
try { doStuff(); } catch (e) { console.log(e); }
```
This hides failures, corrupts state, and makes incidents undebuggable.

**Better principles:**
- **Distinguish error kinds.** *Operational* errors (network down, invalid user input, file missing) are expected — handle them. *Programmer* errors (null deref, bad invariant) should fail loud and fast; don't paper over bugs.
- **Catch narrowly, only what you can act on.** Let unexpected errors propagate to a boundary that logs with context and returns a clean response.
- **Never swallow.** If you catch, do one of: recover meaningfully, **add context and rethrow**, or convert to a typed result. Silence is the worst option.
- **Add context, preserve cause.** Wrap with the operation and inputs; keep the original (`throw new Error("charge failed for order 42", { cause: err })`, Go `fmt.Errorf("...: %w", err)`, Python `raise X from err`).
- **Clean up deterministically.** `finally`, `defer`, `with`/context managers, RAII, `using`/`try-with-resources`.
- **Fail fast on startup.** Validate config/env at boot; don't discover a missing key mid-request.
- **Typed errors / Result types** where the language supports them (Rust `Result`, Go multi-return, `Either`/`Result` in FP) beat exceptions-as-control-flow.
- **Handle the real failure modes:** timeouts (always set them on network calls), retries with backoff + jitter and an idempotency key, partial writes, rate limits, and empty/malformed responses.

Error **messages** are for the human who will read them at 3 a.m.: state the operation, the relevant input, and the likely fix.

---

## 8. Types & Contracts

- **Use the type system.** `any`/`unknown`-everywhere or reflexive `# type: ignore` is slop; it discards the checker's help. Fix the mismatch instead of silencing it.
- **Make illegal states unrepresentable.** Discriminated unions/enums over stringly-typed status; non-nullable by default; parse into a rich type at the boundary so the rest of the code can trust it ("Parse, don't validate").
- **Validate at boundaries** (HTTP bodies, config, env, third-party payloads) with a schema (`zod`, `pydantic`, JSON Schema), then trust internally.
- **Precise domain types** over primitives where it prevents mistakes (`UserId` vs raw `string`; money as integer minor units or a decimal type — never binary floats).
- **Handle null/undefined explicitly.** Optional chaining and nullish coalescing communicate intent; ignoring nullability is a top runtime-crash source.

---

## 9. Comments & Documentation

- **Comment the WHY, never the WHAT.** Code already says what. Explain rationale, tradeoffs, non-obvious constraints, and links to tickets/specs.
```js
// slop:   // loop over users
// better: // Process oldest-first so retries preserve FIFO ordering (see JIRA-1421)
```
- **Delete redundant comments** and all commented-out code — version control remembers.
- **Keep comments true.** A stale comment is worse than none; update or remove it when the code changes.
- **Document public APIs**: contract, parameters, return, thrown errors, side effects, and units (`timeoutMs`, not `timeout`).
- Prefer **self-documenting code** (good names, small functions) so comments are reserved for the genuinely non-obvious.
- **TODO/FIXME** must be actionable and, ideally, ticketed — not a shrug left in `main`.

---

## 10. Dependencies & Reuse

- **Reach for the standard library and existing project deps first.** Reinventing `debounce`, `uuid`, date arithmetic, deep-clone, or (especially) **crypto** is both slop and a bug farm.
- **But don't add a heavyweight dep for a three-line need.** Judgment in both directions — remember `left-pad`. Weigh maintenance, transitive footprint, license, and supply-chain risk.
- **Pin and lock** versions (`package-lock.json`, `poetry.lock`, `go.sum`). Know what you pull in; audit (`npm audit`, `pip-audit`, Dependabot).
- Prefer **well-maintained** libraries (recent releases, open issues addressed) over abandoned ones, regardless of star count.

---

## 11. Security

Treat every external input as hostile. (OWASP Top 10 is the baseline reading.)

- **No hardcoded secrets.** Ever. Use env vars/secret managers; keep secrets out of git history and logs. Scan with tools like `gitleaks`.
- **Parameterize / escape all injection surfaces:** SQL (prepared statements — never string concatenation), shell (avoid `shell=True`/interpolation; pass argument arrays), HTML (context-aware escaping to stop XSS), file paths (prevent traversal).
- **Validate and canonicalize input** at the boundary; enforce size/type/range limits.
- **Don't roll your own crypto or auth.** Use vetted libraries; hash passwords with bcrypt/scrypt/argon2, never MD5/SHA1/plaintext.
- **Least privilege** for tokens, DB users, and services. Fail closed, not open.
- **Don't leak internals** in error responses (stack traces, SQL, versions) to end users.
- Keep dependencies patched; most breaches exploit known, unpatched CVEs.

### 11.1 Slopsquatting: verify every AI-suggested dependency

Code-generating models sometimes recommend packages that don't exist — a **hallucinated dependency**. Studies of production models put the hallucination rate for package names at roughly one in five suggestions across large samples, and the fabricated names are not random: models converge on the same plausible-sounding strings (conflating two real packages, borrowing a name from another language's ecosystem, or inventing a specific-sounding utility). Attackers exploit this convergence directly — a technique security researchers named **slopsquatting** — by registering the exact names models are known to hallucinate and waiting for `pip install` or `npm install` to hand them a foothold. This has already happened in the wild, not just in theory: a hallucinated `huggingface-cli` PyPI package pulled tens of thousands of downloads before anyone flagged it.

Treat every AI-suggested package the same way you'd treat a link from a stranger:
- **Look it up before installing it.** Confirm the package exists on the real registry (PyPI, npm, crates.io), check its maintainer, release history, and download count — a two-week-old package with one maintainer and a name that exactly matches your prompt is a red flag.
- **Never let an agent auto-install and auto-run in the same step** without a human or a lockfile-diff gate in between, especially in CI or any environment with credentials (crypto keys, cloud tokens) in scope.
- **Pin dependencies and diff lockfile changes in review** — a new, unexpected entry in `package-lock.json` or `requirements.txt` is exactly the signal this attack is designed to slip past.
- **Prefer tools with real-time registry validation** (MCP-backed package lookups, IDE plugins that check names against the registry) over raw model output for install commands.
- This is a supply-chain risk category distinct from typosquatting: the attacker isn't betting on your typo, they're betting on the model's confident wrongness.

---

## 12. Concurrency & Resource Safety

- **Set timeouts** on every network/DB call; unbounded waits are outages waiting to happen.
- **Bound resources:** connection pools, worker counts, queue sizes, retries. Add backpressure.
- **Protect shared mutable state** (locks, atomics, actors, or — best — don't share it). Watch for races, deadlocks, and ordering assumptions.
- **Idempotency** for anything retried (payments, webhooks): use idempotency keys so a retry can't double-charge.
- **Always release resources** even on error (files, sockets, DB connections, locks) via `finally`/`defer`/context managers.
- **Retries need backoff + jitter** and a cap; naive tight-loop retries create thundering herds.

---

## 13. Performance

- **Measure before optimizing.** *"Premature optimization is the root of all evil"* (Knuth, in context). Profile; optimize the actual hot path, not a guess.
- **Fix algorithmic complexity first.** An accidental O(n²) (nested loop over the same collection, or N+1 queries in an ORM) dwarfs micro-tweaks. Batch queries; add indexes for real query patterns.
- **Don't sacrifice clarity for imaginary speed.** Most code is not hot; readability wins there.
- **Beware N+1, unbounded memory growth, and chatty I/O.** These are the common real culprits.
- Cache deliberately, with an invalidation story — an unmanaged cache is a future correctness bug.

---

## 14. Testing

- **Test behavior, not implementation.** Tests that assert on internals break on every refactor and protect nothing.
- **A test that can't fail is slop.** Mutate the code mentally: if the test still passes, it's worthless.
- **Cover the edges:** empty input, boundaries (0, 1, max, off-by-one), invalid input, error paths, concurrency where relevant — and add a **regression test for every bug you fix**.
- **Arrange–Act–Assert**, one logical assertion of intent per test, descriptive names (`returns400WhenEmailMissing`).
- **Don't over-mock.** Mock at real seams (network, clock, filesystem); if you mock everything, you test the mocks. Prefer fakes/in-memory doubles for stateful deps.
- **Deterministic tests.** No real network, no `sleep`-based timing, no reliance on wall-clock/timezone/order. Inject the clock and randomness.
- Coverage is a **floor, not a goal** — 100% coverage of assertions-that-never-fail is theater. Aim for meaningful coverage of behavior and risk.

---

## 15. Git, Reviews & Collaboration

- **Small, focused commits** with messages that explain *why* (Conventional Commits is a fine convention). "fix stuff" / "wip" is slop.
- **One concern per PR.** A giant mixed diff can't be meaningfully reviewed.
- **Review for correctness, edge cases, security, and readability** — not just style; automate style with linters/formatters (ESLint/Prettier, Ruff/Black, gofmt) so humans discuss substance.
- Wire up **CI**: build, lint, type-check, tests, and security scan on every PR. Green means green.

### 15.1 Writing a commit message worth reading later

A commit message is documentation for the person debugging this line six months from now — often you. Slop commit messages are the git equivalent of narration comments: present, technically true, and useless.

**Structure (works for Conventional Commits or plain prose):**
```
<type>(<scope>): <imperative summary, ≤50 chars, no trailing period>

<body: why this change, not what — the diff already shows what>
<wrap at ~72 chars, explain the problem this solves, tradeoffs
considered, and anything a reviewer needs to understand the
change without re-deriving it>

<footer: closes #123, refs #456, BREAKING CHANGE: ..., Co-authored-by: ...>
```

- **Summary line is imperative mood**: "Fix race condition in retry queue," not "Fixed," "Fixes," or "Fixing." Test: it should complete the sentence "If applied, this commit will ___."
- **The body explains *why*, never restates the diff.** `git diff` already shows what changed; a message that says "updated `user.ts` to change the validation logic" adds nothing `git log -p` didn't already tell you. Say *why* the old validation was wrong and what broke because of it.
- **One logical change per commit.** A commit that touches unrelated files for unrelated reasons can't be reverted, bisected, or reviewed cleanly. If the message needs "and" to describe it, it's probably two commits.
- **Types worth using** (Conventional Commits): `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `build`, `ci`. Consistency here makes changelogs and `git log --oneline --grep` genuinely useful, not just decorative.
- **Reference the issue, don't replace the message with it.** `Closes #482` is a footer, not a substitute for explaining the change — issue trackers get migrated and deleted; the git history is often what survives.
- **`git bisect` is the real test.** A good commit message (and an atomic commit) means that when `git bisect` lands on it, the message alone tells you whether this is the culprit, without needing to reconstruct context from three other commits.
- **AI-assisted commits need the same scrutiny as AI-assisted code.** A generated message that summarizes *what* the diff touched (file names, line counts) but not *why* is slop with better formatting — see §15.2. If you didn't understand the change well enough to write the *why* yourself, that's a signal to go re-read the diff, not to ship the auto-generated summary.

**Slop vs. craft:**
```
# slop
git commit -m "fixes"
git commit -m "Updated files"
git commit -m "wip, will clean up later"

# craft
git commit -m "fix(auth): reject expired refresh tokens on rotation

Refresh tokens issued before the 2024-01 key rotation were still
accepted because the rotation only updated the signing key, not
the expiry check. Attackers could replay a pre-rotation token
indefinitely. Add an explicit expiry comparison independent of
signature validity.

Closes #482"
```

### 15.2 The agentic-PR flood is a real cost, not a hypothetical

By 2026 this stopped being theoretical: maintainers of major projects have described being overwhelmed by low-effort, AI-generated pull requests — verbose diffs with descriptions the submitter can't explain when asked, "fixes" for issues that don't exist, and drive-by contributions optimized to look mergeable rather than to be correct. The Jazzband Python collective shut down citing the unsustainable volume of AI-generated spam; curl's maintainer canceled its bug-bounty program because it had become a magnet for low-effort AI-assisted submissions. This is the same "plausibility over correctness" signature from §1, now arriving as a volume problem for reviewers, not just a quality problem for one codebase.

Practical implications:
- **A large, sprawling PR with a fluent description is not evidence of quality** — description-to-diff similarity is easy for a model to produce and easy to mistake for rigor. Read the diff; don't grade the prose.
- **Be able to explain your own PR.** If you used an agent, you should be able to answer "why this approach and not X" without re-reading the code for the first time in the review conversation.
- **Maintainers are within their rights to require a human-legible rationale** and to close low-effort AI-generated contributions without extensive engagement — protecting reviewer time is not gatekeeping.
- **Don't let commit-message and PR-description generators substitute for understanding.** They're fine for formatting a message you already understand; they're slop generators when used to describe a diff you haven't read.

---

## 16. Using AI Without Producing Slop

AI is a fast junior pair-programmer, not an oracle. To avoid shipping its slop:

- **You are accountable for every line.** If you can't explain it, don't merge it.
- **Give it real context**: the actual constraints, edge cases, existing conventions, and the interfaces it must fit.
- **Verify claims and APIs** — LLMs hallucinate functions, flags, and library behavior. Run it; read the docs.
- **Reject the tells:** swallowed errors, `any`, narration comments, reinvented utilities, missing edge cases, invented dependencies.
- **Ask it to handle failure modes and write real tests**, then check those tests actually exercise the edges.
- **Never paste secrets** into prompts, and never let generated code hardcode them.
- Treat generated code exactly as you'd treat a stranger's PR: read it critically, test it, and refactor it into the codebase's voice.
- **Verify before you install.** Any package name an agent suggests gets checked against the real registry first — see [§11.1](#111-slopsquatting-verify-every-ai-suggested-dependency).
- **"Vibe coding" (Karpathy's term for prompting toward a result without reading the diff) is fine for throwaway prototypes and dangerous for anything that ships.** The line between the two is whether a human read and understood every line before it merged.
- **Require the agent to run what it wrote.** A diff that was never built, executed, or tested is a guess with good formatting, not a change.
- **Scope agentic changes tightly.** Ask for one function, one file, one concern per turn; a multi-file "helpful" refactor you didn't ask for is scope creep that hides the real change.
- **Watch for the fix-the-symptom pattern**: an agent that makes a failing test pass by loosening the assertion, or a lint error disappear by disabling the rule, has produced slop that looks like a fix.

---

## 17. Architecture & Project Structure

Everything so far in this guide operates *inside* a file. None of it saves you if the folders themselves are slop — and folder structure is one of the places AI agents fail most visibly, because a codebase's architecture is rarely written down anywhere the agent can read it. Left with no explicit convention, an agent (or an under-specified prompt to one) will default to inventing structure on the fly, run after run, which is how projects end up with `utils/`, `utils2/`, `helpers/`, and `common/` all doing the same job, or a `services/` folder next to a `service/` folder from a different session. That's architecture-level slop: plausible-looking, superficially organized, and quietly incoherent.

This isn't a hypothetical cost. Google's 2025 DORA report found that as AI adoption rose across surveyed teams, bug rates, code review time, and average pull request size all climbed alongside it — and unclear architecture is one of the mechanisms that makes agent-assisted changes sprawl wider than they need to. An agent operating against a codebase with no legible structure has no way to keep a change small, because it can't tell what's actually inside the boundary of what it was asked to touch.

### 17.1 Structure by what the app does, not by what framework it uses

The classic failure mode predates AI but AI reproduces it reflexively: **package/folder by technical layer** — `controllers/`, `services/`, `models/`, `repositories/`, `utils/` — with every feature's code smeared across all five. To understand or change one feature ("billing," "onboarding," "search") you have to open five unrelated folders and mentally reassemble it yourself. A directory listing of a layered project tells you what framework it uses; it tells you nothing about what the product *does*.

**Package/folder by feature** (also called a vertical slice) inverts this: each feature owns its own folder containing everything specific to it — its endpoint, its business logic, its data access, its tests — with only genuinely cross-cutting code (auth middleware, a DB client, shared types) pulled into a common layer.
```
# layer-first (scatters one feature across five folders)
src/
  controllers/  billingController.ts  userController.ts  searchController.ts
  services/     billingService.ts     userService.ts      searchService.ts
  repositories/ billingRepo.ts        userRepo.ts          searchRepo.ts

# feature-first (a feature is one folder, deletable and reviewable as a unit)
src/
  features/
    billing/    routes.ts  service.ts  repo.ts  billing.test.ts
    onboarding/ routes.ts  service.ts  repo.ts  onboarding.test.ts
    search/     routes.ts  service.ts  repo.ts  search.test.ts
  shared/       db-client.ts  auth-middleware.ts  types.ts
```
**Why this matters more, not less, with AI agents in the loop:** a feature that owns its own vertical slice fits in one context window and can be understood, changed, and tested without the agent (or a human reviewer) having to reconstruct how five scattered files relate. A layered structure forces exactly the kind of wide, speculative, multi-file "helpful" edit this guide already flags as scope creep (§16) — the agent touches five folders because the architecture made that the only way to finish one feature.

This is the same idea Robert C. Martin named **"screaming architecture"**: your top-level folder structure should scream what the *application* is, not what web framework or ORM it happens to use. If you can't tell a codebase apart from a generic framework tutorial by looking at its folder names, the structure isn't carrying any information.

### 17.2 Don't earn Clean/Hexagonal Architecture before you have the complexity that justifies it

Layered, ports-and-adapters, or fully "Clean Architecture" structures (domain/application/infrastructure boundaries, dependency inversion at every seam) are real, valuable patterns — for a codebase that has outgrown a flat structure. Applying them to a project with three endpoints and one database is the architectural version of the five-layer-abstraction slop tell in §2 (`Factory→Manager→Service→Helper→Util` over 10 lines): ceremony standing in for judgment.

The practical sequence that avoids both failure modes:
1. **Start feature-first, flat, and boring.** One folder per feature; no interfaces or abstraction layers until something concrete needs them (§5's Rule of Three still applies at the architecture level, not just the function level).
2. **Let internal layering emerge inside a feature once it's genuinely complex** — a feature folder can have its own small `domain/`/`adapters/` split without imposing that split project-wide.
3. **Only promote a pattern to project-wide convention once two or three features have independently needed it.** A convention adopted after the third real case is a decision. A convention adopted on day one, before any feature justified it, is a guess wearing architecture's clothes.

### 17.3 Module boundaries are enforced by encapsulation, not by folder names alone

A feature folder is not a boundary unless most of what's inside it is *not* importable from outside. Prefer visibility rules the language actually enforces (`internal` in Go, package-private in Java/Kotlin, an explicit barrel `index.ts` that only re-exports the intentional public surface in TypeScript) over a folder name that's a boundary in name only. If any file in any feature can `import` any file in any other feature directly, the folders are documentation, not architecture — nothing stops the coupling they were meant to prevent.

### 17.4 Give AI agents the convention explicitly — don't make them infer it

An agent without an explicit map of your structure will pattern-match against the most common structure it's seen in training, which regresses to the generic layered default — the same "distributional convergence" this guide's companion design doc names for visual defaults (§2.1 there) shows up here as *structural* convergence. The fix is direct:
- **Write the architecture down** in a file the agent actually reads at the start of a session (a `CLAUDE.md`/`AGENTS.md`/`ARCHITECTURE.md`, whatever your tooling supports) — name the pattern (feature-first, layered, hexagonal), where new code of each kind goes, and what's off-limits to touch casually.
- **Point at one existing feature as the reference example** ("new features follow the shape of `features/billing/`") — agents follow a concrete precedent far more reliably than an abstract rule.
- **Treat a structural inconsistency the same as a code-quality bug in review**: if an agent added a new top-level folder, a new "helper" location, or duplicated an existing pattern under a new name, that's a structural regression to catch before merge, not a style nitpick to wave through.
- **The "comprehension gate" applies to structure too.** Before agent-generated code merges, someone should be able to say *where this lives and why it lives there* in one sentence — not just what the code does. If the answer is "the agent put it there," that's the same failure as not being able to explain a line of logic (§16) — just one level up.

---

## 18. The Anti-Slop Review Checklist

**Fit & simplicity**
- [ ] Matches the project's conventions, formatter, and linter (all green).
- [ ] Simplest correct version — no premature abstraction, no dead ceremony.
- [ ] Every line justifies itself; no commented-out code or leftover `console.log`.

**Architecture**
- [ ] New code lives where the documented convention (or the nearest existing feature) says it should — not a new top-level folder invented for this change.
- [ ] I can say in one sentence where this lives and why, without saying "the agent put it there."
- [ ] No duplicate `utils`/`helpers`/`common` locations doing the same job under a different name.

**Naming & structure**
- [ ] Names state intent (verbs for functions, questions for booleans).
- [ ] Functions do one thing; ≤3 params or an options object; no hidden side effects.
- [ ] Guard clauses over deep nesting; no magic numbers.

**Correctness & errors**
- [ ] Real edge cases handled: empty, huge, malformed, concurrent, offline, partial.
- [ ] No swallowed errors; failures recover, add context, or propagate.
- [ ] Network/DB calls have timeouts; retries use backoff + idempotency.
- [ ] Resources always released (finally/defer/context manager).

**Types & contracts**
- [ ] No reflexive `any`/`# type: ignore`; nullability handled.
- [ ] Inputs validated at boundaries; illegal states hard to represent.

**Security**
- [ ] No hardcoded secrets; injection surfaces parameterized/escaped.
- [ ] No home-grown crypto/auth; least privilege; internals not leaked in errors.
- [ ] AI-suggested dependencies verified against the real registry before install; lockfile diff reviewed.

**Tests & docs**
- [ ] Tests exist and could genuinely fail; edges + a regression test for fixed bugs.
- [ ] Comments explain *why* and are true; public APIs documented (with units).
- [ ] I can explain every line of this PR without re-reading it for the first time in review.
- [ ] Commit messages are imperative, explain *why*, and would make sense to someone bisecting this in a year.

**The gut check**
- [ ] Could a generic prompt have produced this without knowing the real requirements?
- [ ] Would I defend every line of this in review — and debug it at 3 a.m.?

---

## 19. Case Study: Redis — Craft at the Systems-Programming Level

Every principle above is easier to see in a codebase that actually lives by it. Redis (the C core, created by Salvatore Sanfilippo — "antirez" — and maintained since as a widely used, heavily audited piece of infrastructure) is one of the most consistently cited examples of readable systems code in the industry: a database written in plain ANSI C, handling millions of ops/sec in production at companies of every size, that engineers still hold up as something to *read*, not just use. It's worth studying not because it's exotic, but because it's the same rules in this guide, applied without compromise, at a scale most projects never reach.

### 19.0 Why this specific repo, and not some other database

It's worth being precise about *why* Redis is the one people point to, rather than treating the reputation as received wisdom:

- **It shipped with a written aesthetic, and the code visibly follows it.** Redis has long included a manifesto in the repository stating its design values directly — among them: model the API on the fundamental data structures computer science already has names for, rather than inventing bespoke abstractions; keep the distance between the wire protocol and the underlying data structure as short as possible, so complexity is never hidden behind an intermediate layer; treat the codebase as writing with its own aesthetic standard, not merely a means to an end; and explicitly reject complexity as a cost to be justified, not a default to accept. Most infrastructure software has an implicit style. Very little of it writes the style down in the repository and then holds the code to it for over a decade — which is exactly why reviewers can check the code against the stated intent instead of guessing at it.
- **The origin story is a real constraint, not a marketing narrative.** Sanfilippo built the first version in 2009 to solve an actual bottleneck in his own startup (LLOOGG, a real-time site-analytics tool) — the initial design decisions were made under the pressure of a real workload, not as a speculative "let's build a database" exercise. That tends to produce software shaped by what a specific problem needed, rather than by what a feature checklist demanded.
- **One person's taste stayed consistent across the codebase for over a decade.** Sanfilippo was Redis's sole maintainer for roughly its first eleven years. Large infrastructure projects are usually shaped by committee, which tends to average out any single point of view (the same "distributional convergence" problem this guide's companion design doc names in AI-generated interfaces, §2.1 there). A single sustained voice is part of why the codebase reads coherently instead of like a codebase with fourteen conflicting conventions stitched together.
- **The protocol is simple enough that reimplementing it is a standard learning exercise.** RESP (the Redis Serialization Protocol) is deliberately simple to parse, and "build your own Redis" is now a well-known teaching project — platforms built specifically around recreating real infrastructure from scratch use it as a flagship challenge, and standalone guides walk through implementing a Redis clone as a way to learn TCP servers, event loops, and wire protocols. A large fraction of the engineers who talk about Redis's code quality have, at some point, tried to reproduce a piece of it themselves — that hands-on familiarity is a big part of why the opinions about it are so specific and consistent, rather than secondhand.
- **It's cited as a counter-example to a specific, common failure mode.** A lot of infrastructure software earns a reputation for being hard to read specifically *because* it grew multi-threaded, multi-abstraction-layer complexity to chase scale. Redis is discussed disproportionately often in these conversations because it's a rare example of software that reached massive real-world scale while making the opposite trade at almost every decision point — which is the entire reason it appears in this guide rather than as a passing reference.

### 19.1 Architecture is a decision, defended in writing — not a default

Redis's command execution is single-threaded. In 2025-era engineering culture, where "just add more threads" is often the reflex, that reads as a constraint. It's actually the load-bearing decision that makes the rest of the system simple:
- **No locks, because there's nothing to lock.** A single thread executing commands sequentially makes every operation atomic by construction — no mutexes, no lock-ordering bugs, no deadlocks in the command path. An entire category of concurrency bugs (§12) is eliminated architecturally, not managed carefully.
- **The tradeoff is stated, not hidden.** Redis is memory- and network-bound for typical workloads, not CPU-bound, so a second thread would mostly coordinate rather than parallelize real work — until you run a genuinely slow command (`KEYS` on a huge keyspace), which blocks everything, a cost the design accepts explicitly rather than papering over. (Since Redis 6, I/O — reading and writing sockets — was later split onto multiple threads specifically because that part of the workload *does* parallelize well, while command execution stayed single-threaded because atomicity was the point.)
- **This is §3.3 ("prefer boring, obvious code") at the architectural level.** The interesting decision wasn't adding complexity to go faster; it was refusing complexity because the workload didn't need it, and writing down why.

The lesson isn't "always be single-threaded." It's: **name your architecture's actual bottleneck before you design around a bottleneck you assume you'll have.**

### 19.2 Comments earn their place — they don't decorate the code

Sanfilippo has written and spoken at length about a self-imposed discipline for comments that's close to the inverse of slop-comment habits (§9): most comments in the Redis source are what he calls *guide comments* — not restating what a line does, but orienting a reader before they process a non-obvious block, the same job a paragraph break does in prose. Function-level comments are written so the reader can treat the function as a black box afterward — a contract, not a description:
```c
/* Seek the greatest key in the subtree at the current node. Return 0 on
 * out of memory, otherwise 1. This is an helper function for different
 * iteration functions below. */
int raxSeekGreatest(raxIterator *it) { ... }
```
That's a *function comment*: it tells you the contract and return semantics so you don't have to read the body to use it correctly. Compare it to a narration comment (§2, tell #1) — `// seeks the greatest key` — which tells you nothing the name didn't already. The difference is information density: does the comment let the reader stop reading, or does it just keep them company while they read anyway?

New modules in the Redis codebase often open with a short block explaining the chosen algorithm and — just as importantly — **what alternatives were rejected and why**. That's the single highest-leverage comment a systems codebase can have, because it's the one piece of context version control genuinely doesn't preserve well: *why this shape and not the obvious one.*

### 19.3 Small, custom data structures — chosen deliberately, not out of NIH

Section 10 of this guide says "reach for the standard library first." Redis's `sds` (Simple Dynamic Strings), `rax` (radix tree), and its various compact list/hash encodings look, on the surface, like a violation of that rule — hand-rolled containers instead of whatever C's minimal standard library offers. It isn't a violation; it's the exception that rule already carves out: **build custom only when a generic container would hide the exact performance or memory-layout property the system depends on, and document why.**
- `sds` exists because C strings don't carry a length, aren't binary-safe, and reallocate unpredictably — properties a database storing arbitrary binary values genuinely cannot use a `char*` for. That's a stated, technical justification, not a preference.
- The distinction from slop's reinvented-utility tell (§2, tell #13: reinventing `debounce`/`uuid`/date math) is intent and documentation. Reinventing `uuid` because you didn't check for a library is slop. Building a custom string type because the standard one is provably wrong for your access pattern, and writing down why, is engineering.

### 19.4 Small functions, verbs that describe exactly one job

Redis functions are kept short by convention — the moment one grows past roughly 100 lines, the project's own norms treat that as a signal to split it (§5). Names read as precise, active claims about behavior — `clientHasPendingReplies`, `raxSeekGreatest` — not `handleClient` or `processData` (§4's naming slop tells). A function name in this codebase is close to a spec: if you can guess the return type and side effects from the name alone, the naming did its job.

### 19.5 Treat the first version as a draft — rewrite before merging

Sanfilippo has compared writing a new component to drafting a paragraph in a novel: you write it, then you rewrite it once you actually understand the shape of the problem, because the first version is where you were still discovering the design. This is §3.5 ("make the change easy, then make the easy change") applied to greenfield work specifically — plan for the first implementation of anything nontrivial to be thrown away or substantially rewritten once it's proven correct, not shipped because it happened to work.

### 19.6 Even the creator doesn't trust AI-generated systems code unread

In 2026, Sanfilippo published a detailed account of building a new Redis data type with heavy AI assistance (drafting specs, generating stress tests, reviewing algorithms) — and the account is a useful antidote to vibe-coding hype precisely because of who wrote it. His summary: *for high-quality systems programming, you still have to be fully involved.* The project took roughly four months with AI assistance, from the original creator of the software, not a novice — and a large share of that time was reading the generated code line by line, finding design errors that "superficially worked," and rewriting modules by hand once testing revealed they weren't actually solid. That's §16 of this guide, demonstrated by someone with no reason to overstate the caution: **AI can carry you into complexity you'd otherwise skip, but verification and rewriting are still the job, not a step you delegate.**

### 19.7 Minimal, legible build and dependency footprint

Redis builds with a single `make` invocation and has historically kept its runtime dependency footprint close to libc — a deliberate rejection of the "five build tools and a dozen transitive dependencies" default that afflicts a lot of modern software (§10). Every additional build step or dependency is treated as something that has to earn its place and be explained, not something you reach for by default. This is the same principle as §10's "don't add a heavyweight dep for a three-line need" — held to a stricter standard because the thing being built is infrastructure other people's infrastructure depends on.

---

## 20. Further Study

- Robert C. Martin — *Clean Code* (read critically) & *The Clean Coder*
- Andrew Hunt & David Thomas — *The Pragmatic Programmer*
- Steve McConnell — *Code Complete*
- Martin Fowler — *Refactoring* (refactoring.com)
- Titus Winters et al. — *Software Engineering at Google*
- Michael Nygard — *Release It!* (timeouts, circuit breakers, resilience)
- OWASP — *Top 10* and the Cheat Sheet Series (owasp.org)
- Google — *Engineering Practices / Code Review Developer Guide*
- The Zen of Python (`import this`) and language-specific style guides (PEP 8, Effective Go, Airbnb JS, Rust API Guidelines)
- Seth Larson's writing on **slopsquatting** and supply-chain risk from hallucinated packages
- OWASP's guidance on LLM-assisted development risk (part of the broader OWASP Top 10 for LLM Applications work)
- Robert C. Martin — "Screaming Architecture" (on structuring by what an application does, not by its framework)
- Google's DORA (DevOps Research and Assessment) reports — annual data on how AI adoption is actually affecting delivery performance and code quality across real teams
- Simon Willison's writing on agentic coding and "vibe coding" boundaries (simonwillison.net)
- Salvatore Sanfilippo (antirez) — blog posts on code comments and system-programming practice (antirez.com/news), and the Redis source itself (github.com/redis/redis) as a primary reading text, not just a dependency
- The Redis `MANIFESTO` file in the repository itself (github.com/redis/redis/blob/unstable/MANIFESTO) — a rare case of a widely used piece of infrastructure stating its design values in writing
- "Build Your Own Redis" style projects (codecrafters.io, build-your-own.org) — reimplementing the RESP protocol and a minimal event loop is one of the fastest ways to understand why the real thing is designed the way it is

---

## The One-Line Test

> **Slop is code that was accepted. Craft is code that was decided.**

If you can't defend a line — with a reason, not a vibe — don't ship it.
