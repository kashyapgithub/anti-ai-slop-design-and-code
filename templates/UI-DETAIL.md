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
4. **Each sub-ID records the actual prop/state/token names, not a
   description** — `variant="danger"`, `isSubmitting`, `--color-danger` —
   so a change can be made straight from this file without reopening the
   component first. Anchor it into the source too: a one-line
   `// UI-ID: b5.b` comment on the element it describes, so the link
   works in both directions.
5. **If an ID reads or writes a specific piece of shared data** (a store
   value, a global entity, an API-backed field — not purely local UI
   state), note it in that row's Notes as `reads: [...]` / `writes:
   [...]`, naming the data by the same identifier used in code. This is
   optional and only worth doing for data that actually crosses between
   panels — if `UI-DETAIL.html` is in use, the same information there
   powers its Data Flow view (a third tab alongside Table and Map)
   automatically; keep the two in sync the same way as everything else.

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
| Sub-ID | Element | Type | Action | Key props / style | Notes |
|--------|---------|------|--------|--------------------|-------|
| a1.a | "Sign in" button | button | Submits the form; on success redirects to dashboard. | `isSubmitting` (disables + spinner), `.btn-primary` | |
| a1.b | "Forgot password?" link | link | Opens **a2**. | `--color-link` | |

Sub-IDs are letters, sequential within their panel, in the order added
— same permanence rule as the top level. Only interactive or
independently-meaningful elements need one; static text doesn't. Add a
matching `// UI-ID: a1.a` comment in the component near each element
that gets a sub-ID.

If an ID crosses shared data, add it to that row's Notes, e.g.:

| a1.a | "Sign in" button | button | Submits the form. | `isSubmitting`, `.btn-primary` | writes: session.token |
| b5   | Downgrade confirmation | `DowngradeConfirm.tsx` | ... | | reads: session.token, subscription.status |

`UI-DETAIL.html`'s Data Flow tab (if the project uses it) traces these
automatically across the whole product, grouped by data entity rather
than by feature — since data doesn't respect feature boundaries even
when the code is organized by them.
-->
