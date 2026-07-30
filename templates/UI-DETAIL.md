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
-->
