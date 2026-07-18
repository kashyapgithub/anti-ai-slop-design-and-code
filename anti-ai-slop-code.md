# Anti-AI-Slop Code Guide

> A practical field guide for writing code that a competent engineer *chose* to write — not code that was generated to satisfy a prompt and forgotten. If it compiles but nobody would defend it in review, it's slop.

---

## What "AI Slop" Looks Like in Code

AI slop code is plausible-looking, superficially complete, and quietly wrong or lazy. Recognize the tells:

- **Comment narration.** `// increment i by 1` above `i++`. Comments that restate code instead of explaining *why*.
- **Try/catch that swallows.** `catch (e) { console.log(e) }` and then carries on as if nothing happened.
- **Reinvented utilities.** A hand-rolled `deepClone` / `debounce` / date parser when the stdlib or an existing dep does it correctly.
- **Ceremony without substance.** Five layers of abstraction (`Factory` → `Manager` → `Service` → `Helper` → `Util`) wrapping ten lines of logic.
- **Copy-paste symmetry.** The same block repeated with one value changed, instead of a loop or parameter.
- **Fake robustness.** Defensive checks for impossible states while ignoring the input that actually breaks.
- **Type theater.** `any` everywhere in TypeScript, or `# type: ignore` sprinkled to silence the checker.
- **The happy path only.** No handling for empty inputs, network failure, timeouts, or partial data.
- **Placeholder pretending to be done.** `// TODO: implement`, hardcoded returns, `return true // for now`.
- **Inconsistent everything.** Mixed naming, mixed quote styles, mixed patterns within one file.

---

## Core Principles

### 1. Understand Before You Write
Read the surrounding code. Match its conventions, its error strategy, its abstractions. Slop appears when code is written *at* a codebase rather than *within* it.

### 2. Solve the Actual Problem
Don't generate a generic solution and hope it fits. Handle the real inputs, the real edge cases, and the real failure modes for *this* use case.

### 3. Prefer Boring, Obvious Code
Clever is a liability. The best code is the code the next person understands in one pass. Simplicity is a decision, not an accident.

### 4. Every Line Should Justify Itself
If you can't explain why a line exists, delete it. Slop is accumulation; craft is subtraction.

---

## Naming

**Slop:** `data`, `data2`, `handleData`, `processData`, `temp`, `result`, `flag`, `obj`, `arr`.

**Better:**
- Name by **intent and domain**: `pendingOrders`, `retryAfterMs`, `isEmailVerified`.
- Booleans read as questions: `isActive`, `hasAccess`, `shouldRetry`.
- Functions are **verbs**; values are **nouns**. Keep tense and casing consistent.
- Avoid abbreviations unless they're universal in the domain.
- Don't encode types into names (`strName`, `arrItems`) — the type system does that.

---

## Functions & Structure

- Keep functions **doing one thing** at one level of abstraction.
- Prefer **early returns** over deep nesting.
- Limit parameters; pass an options object when there are many, and destructure it.
- Don't abstract until there's a **real** second use case. Premature `BaseAbstractHandlerFactory` is slop.
- Don't inline everything either — extract when a block has a nameable purpose.
- Pure functions where possible; isolate side effects.

---

## Error Handling

**Slop:**
```js
try {
  doStuff();
} catch (e) {
  console.log(e);
}
```

**Better:**
- Catch **specific** errors you can act on; let the rest propagate.
- Fail **loudly and early** on programmer errors; handle expected operational errors gracefully.
- Never swallow. If you catch, either recover meaningfully, add context, or rethrow.
- Include actionable context in messages: what operation, what input, what to do.
- Clean up resources in `finally` / `defer` / context managers.
- Handle the **real** failure modes: network timeouts, empty results, malformed input, rate limits, partial writes.

---

## Comments & Documentation

- Comment the **why**, never the **what**. Code says what; comments explain rationale, tradeoffs, and gotchas.
- Delete comments that restate the line below them.
- Document public APIs: contract, params, return, thrown errors, side effects.
- Keep comments **true** — a stale comment is worse than none.
- No commented-out code left behind. Version control remembers.

---

## Types & Contracts

- In typed languages, **use the types**. `any` / `unknown`-everywhere is slop.
- Model states so invalid ones are **unrepresentable** (discriminated unions, enums, non-nullable by default).
- Validate at boundaries (API inputs, config, env), then trust internally.
- Don't silence the type checker to move on — fix the underlying mismatch.

---

## Dependencies & Reuse

- Use the **standard library** and existing project dependencies before writing your own.
- Don't reinvent `debounce`, `uuid`, date math, deep clone, or crypto. Especially not crypto.
- Don't add a heavy dependency for a three-line need, either. Judgment both ways.
- Pin/lock versions; know what you're pulling in.

---

## Security & Correctness

- Never hardcode secrets, tokens, or API keys in source. Use env/secret managers.
- Sanitize and parameterize all external input (SQL, shell, HTML, paths).
- Don't roll your own auth or crypto — use vetted libraries.
- Validate assumptions with assertions where cheap.
- Consider concurrency: races, shared mutable state, ordering.

---

## Testing

- Test **behavior and edge cases**, not just the happy path.
- A test that can't fail is slop. Assert on real outcomes.
- Cover: empty input, boundary values, error paths, and the specific bug you just fixed.
- Keep tests readable — they're documentation of intent.
- Don't mock so heavily that you test the mocks instead of the code.

---

## The Anti-Slop Checklist

Before opening a PR, ask:

- [ ] Did I read and match the surrounding code's conventions?
- [ ] Does every function/variable name state its intent?
- [ ] Are edge cases and failure modes actually handled?
- [ ] Did I remove `console.log`, dead code, and commented-out blocks?
- [ ] Do comments explain *why*, and are they still true?
- [ ] Did I reuse existing utilities instead of reinventing them?
- [ ] Are there tests that could genuinely fail?
- [ ] No hardcoded secrets, no silenced type errors, no `TODO: implement`?
- [ ] Is this the *simplest* correct version, or just the first that worked?
- [ ] Would I defend every line of this in review?

---

## The One-Line Test

> **Slop is code that was accepted. Craft is code that was decided.**

If you can't defend a line, don't ship it.
