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
17. [The Anti-Slop Review Checklist](#17-the-anti-slop-review-checklist)
18. [Further Study](#18-further-study)

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

---

## 17. The Anti-Slop Review Checklist

**Fit & simplicity**
- [ ] Matches the project's conventions, formatter, and linter (all green).
- [ ] Simplest correct version — no premature abstraction, no dead ceremony.
- [ ] Every line justifies itself; no commented-out code or leftover `console.log`.

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

**Tests & docs**
- [ ] Tests exist and could genuinely fail; edges + a regression test for fixed bugs.
- [ ] Comments explain *why* and are true; public APIs documented (with units).

**The gut check**
- [ ] Could a generic prompt have produced this without knowing the real requirements?
- [ ] Would I defend every line of this in review — and debug it at 3 a.m.?

---

## 18. Further Study

- Robert C. Martin — *Clean Code* (read critically) & *The Clean Coder*
- Andrew Hunt & David Thomas — *The Pragmatic Programmer*
- Steve McConnell — *Code Complete*
- Martin Fowler — *Refactoring* (refactoring.com)
- Titus Winters et al. — *Software Engineering at Google*
- Michael Nygard — *Release It!* (timeouts, circuit breakers, resilience)
- OWASP — *Top 10* and the Cheat Sheet Series (owasp.org)
- Google — *Engineering Practices / Code Review Developer Guide*
- The Zen of Python (`import this`) and language-specific style guides (PEP 8, Effective Go, Airbnb JS, Rust API Guidelines)

---

## The One-Line Test

> **Slop is code that was accepted. Craft is code that was decided.**

If you can't defend a line — with a reason, not a vibe — don't ship it.
