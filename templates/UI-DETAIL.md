# UI-DETAIL.md

A lookup registry for every meaningful screen, panel, modal, drawer,
toast, or banner in this product. The point: "go to b5 and change this"
should be something anyone — human or agent — can act on directly,
without re-locating the thing in the codebase first.

See `anti-ai-slop-design.md` §12.3 for the full reasoning. Two rules
that matter more than anything else in this file:

1. **The letter groups match the feature folders in the codebase**
   (`features/<name>/`), not an invented parallel taxonomy — see the
   code guide's §17.1. Add a letter here only when you add a feature
   folder there, and vice versa.
2. **IDs are permanent.** Assign the next number sequentially within a
   letter, in the order the element was actually added. Never renumber
   to "keep things tidy." If something is removed, mark its row
   `[deprecated]` — don't delete the row or reuse its number.
3. **A panel with 2+ actionable elements gets sub-IDs, one level deeper**
   (`b5.a`, `b5.b`, `b5.c`) — one per button/input/toggle/link/conditional
   banner, so "make b5.b show a spinner" is unambiguous. Skip this for a
   panel with only one thing to interact with; the panel ID alone is
   already specific enough there. See the example below and the code
   guide's Rule of Three (§17.2) for when the extra level earns its keep.

Update this file in the same commit that adds or changes the UI element
it describes. A stale registry is worse than none.

## Letter map

| Letter | Feature folder |
|---|---|
<!-- | a | features/auth/ | -->

## a — (feature name)

| ID | Name | Component | Appears when | Notes |
|----|------|-----------|--------------|-------|
<!-- | a1 | Login form | `LoginForm.tsx` | Default view at `/login` for any unauthenticated visitor. | | -->

<!--
Add one `## <letter> — <Feature Name>` section per feature folder, each
with its own table. Keep the "Appears when" column a precise, checkable
condition (`isEditing === true AND draft.hasUnsavedChanges`), not vague
prose ("shows up sometimes"). Cross-reference other IDs directly
("child of **a1**", "replaces **b5**") rather than re-describing them.

If a panel has 2+ actionable elements, add a sub-table directly below
its row, e.g.:

### a1 — elements
| Sub-ID | Element | Type | Action | Notes |
|--------|---------|------|--------|-------|
| a1.a | "Sign in" button | button | Submits the form; on success redirects to dashboard. | Disabled while submitting. |
| a1.b | "Forgot password?" link | link | Opens **a2**. | |

Sub-IDs are letters, sequential within their panel, in the order added
— same permanence rule as the top level. Only interactive or
independently-meaningful elements need one; static text doesn't.
-->
