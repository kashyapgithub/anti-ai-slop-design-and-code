# Anti-AI-Slop Design Guide

> A practical field guide for designing interfaces that look *intentional*, not *auto-generated*. If your design could have come from any generic prompt, it's slop. This document is about avoiding that.

---

## What "AI Slop" Looks Like in Design

AI slop design is the visual equivalent of a shrug. It's technically "fine" but emotionally dead, generic, and forgettable. Recognize the tells:

- **The purple gradient hero.** A `#6366f1 → #a855f7` gradient, centered white text, and a rounded button. Seen it 10,000 times.
- **Everything is a card.** Uniform rounded rectangles with the same drop shadow, floating on a light-gray background.
- **Emoji as iconography.** 🚀 for "fast", 🔒 for "secure", ✨ for "magic". Placeholder thinking.
- **Lorem-ipsum energy in real copy.** "Empower your workflow", "Unlock seamless experiences", "Take your X to the next level."
- **The default everything.** Default border radius, default shadow, default `Inter`/`system-ui`, default `#f9fafb` background, default 3-column feature grid.
- **No hierarchy, just spacing.** Everything is `gap-4` and `text-center`. Nothing is emphasized because everything is.
- **Symmetry worship.** Perfectly balanced, perfectly boring. No focal point.

---

## Core Principles

### 1. Have a Point of View
Great design makes a *choice*. Before touching a pixel, answer:
- What single feeling should a user walk away with?
- What is the ONE thing this screen must communicate?
- What would this look like if it were the opposite of expected?

If you can't articulate the intent in a sentence, the design will read as slop.

### 2. Steal from the Physical World, Not from Templates
Draw references from print design, editorial layouts, packaging, signage, architecture, and film — not from the last dashboard you saw. Slop happens when the only reference is other software.

### 3. Constraints Create Character
- Pick a **real** typographic system (a display face + a workhorse text face), not just one variable font at three weights.
- Choose a palette with a **reason** (brand, mood, domain), not a random Tailwind slice.
- Commit to a **grid** and then break it deliberately for emphasis.

### 4. Hierarchy Is the Job
Design is deciding what the eye sees first, second, third. If everything is the same size, weight, and color, you haven't designed — you've arranged.

---

## Typography

**Slop:** `Inter` everywhere, `font-medium`, `text-gray-600`, center-aligned.

**Better:**
- Use a **type scale** with real contrast (e.g., 12 / 14 / 16 / 20 / 32 / 56), not four sizes clustered together.
- Pair a **distinctive display typeface** for headlines with a neutral body face. Contrast in personality creates interest.
- Set **measure** (line length) to 45–75 characters. Full-width paragraphs are a slop tell.
- Use **real weight jumps** (e.g., 400 body vs 700+ headline) instead of timid `500/600`.
- Left-align body text. Reserve centering for short, deliberate moments.
- Tune `letter-spacing` on large display text (tighten it) and on all-caps labels (loosen it).

---

## Color

**Slop:** Indigo→purple gradient, gray-50 background, one accent color used everywhere.

**Better:**
- Build a palette around a **dominant** color, a **neutral** range, and **one** sharp accent used sparingly for action.
- Use **off-neutrals** — a warm paper `#f6f3ee` or a cold slate `#0e1116` reads as intentional; `#ffffff`/`#f9fafb` reads as default.
- Give shadows the palette's hue, not pure black. `rgba(30, 20, 60, 0.12)` beats `rgba(0,0,0,0.1)`.
- If you use gradients, make them **subtle and unexpected** — tonal shifts, duotones, grain overlays — not the rainbow ramp.
- Ensure contrast passes **WCAG AA** minimum. Beautiful and inaccessible is still failing.

---

## Layout & Space

**Slop:** Centered column, three feature cards, everything `max-w-7xl mx-auto`.

**Better:**
- Introduce **asymmetry** and a clear focal point. Off-center compositions feel authored.
- Vary **rhythm**: dense areas next to open ones. Uniform spacing reads as generated.
- Use **negative space** as a feature, not leftover room.
- Let elements **overlap**, **bleed off-edge**, or break the grid for emphasis — sparingly and on purpose.
- Establish **spacing tokens** (4 / 8 / 12 / 16 / 24 / 40 / 64) and stick to them for consistency without monotony.

---

## Components & Detail

- **Buttons:** One primary style with real presence. Secondary/tertiary should be clearly subordinate. Avoid three buttons of equal weight.
- **Cards:** If you must use cards, differentiate them — vary size, don't shadow-stack everything, consider borders over shadows.
- **Icons:** Use a **consistent, real icon set** (Lucide, Phosphor, a custom set) at a consistent stroke weight. Never emoji as UI.
- **Imagery:** Prefer authored illustration or genuine photography over generic stock and obviously-AI images (mangled hands, uncanny faces, warped text).
- **Empty states, errors, loading:** These are where care shows. Slop ignores them; craft addresses them.

---

## Motion

- Motion should **explain**, not decorate. Animate to show cause/effect and spatial relationships.
- Respect `prefers-reduced-motion`.
- Use **eased**, physically plausible timing (150–300ms for UI, custom cubic-beziers), not linear or default.
- Avoid the slop trifecta: everything fades up on scroll, hovers scale to `1.05`, and nothing has a reason.

---

## The Anti-Slop Checklist

Before shipping, ask:

- [ ] Could this exact screen have come from a generic prompt? If yes, push further.
- [ ] Is there a clear first/second/third in the visual hierarchy?
- [ ] Does the type have real contrast in size and weight?
- [ ] Is the color palette *reasoned*, or randomly chosen?
- [ ] Have I removed every emoji used as an icon?
- [ ] Is there at least one deliberate, memorable moment?
- [ ] Are empty/error/loading states designed?
- [ ] Does it pass accessibility contrast and reduced-motion checks?
- [ ] Would a designer I respect think this was *decided*, not *defaulted*?

---

## The One-Line Test

> **Slop is the average of everything. Design is a decision.**

If you can't point to the decisions, you haven't finished designing.
