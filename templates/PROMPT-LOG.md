# PROMPT-LOG.md

A chronological record of the meaningful requests and decisions made
during this project — so anyone, human or agent, can see the narrative
of what was actually asked and when, without digging back through chat
history or a long commit log to reconstruct it.

**Log a real request or decision point, not every message.** Skip pure
filler — "yes," "continue," "ok," "thanks," a single clarifying answer
with no new direction in it. Log the moments that actually shaped the
project: a new feature requested, a direction changed, a decision made.
If in doubt, the test is the same one §15.1 uses for a commit message:
would someone reconstructing this project's history in six months want
to know this happened?

Update this file (and `PROMPT-LOG.html`, if the project uses it) in the
same turn the prompt is received — not batched at the end of a session,
where half of them get forgotten.

## Format

```
## YYYY-MM-DD
- **Prompt:** "the request, close to verbatim — don't paraphrase away
  the specifics that made it a real decision"
  **Result:** what was actually done in response, one line — link a
  commit or PR if one exists.
```

Group multiple entries under one date heading as the day accumulates
them; add a new date heading when the date changes. Newest date at the
bottom as you log through a session — `PROMPT-LOG.html` sorts and
displays them however's most useful (default newest-first) without
requiring this file to be maintained in reverse order by hand.

---

<!--
## 2026-07-27
- **Prompt:** "add a UI-detail.md registry with stable IDs (a3, b5, n6)
  so we can give very specific instructions"
  **Result:** Added §12.3 to the design guide, `templates/UI-DETAIL.md`,
  `templates/UI-DETAIL.html`.
-->
