# The Anti-AI-Slop Design Guide

> A rigorous field guide for designing interfaces that read as *authored decisions* rather than *statistical averages*. AI slop is what you get when a design optimizes for "looks like a design" instead of solving a specific problem for specific people. This document is about the difference between the two — with concrete numbers, named systems, and testable heuristics.

**Audience:** designers and engineers shipping real product UI. Every rule here is followed by *why it works* and *how to check it*, because a rule you can't verify is just taste cosplaying as principle.

---

## Table of Contents
1. [What AI Slop Actually Is](#1-what-ai-slop-actually-is)
2. [The Diagnostic: 20 Slop Tells](#2-the-diagnostic-20-slop-tells)
3. [First Principles](#3-first-principles)
4. [Typography (the 60% of the craft)](#4-typography)
5. [Color & Contrast](#5-color--contrast)
6. [Layout, Grid & Space](#6-layout-grid--space)
7. [Components & Interaction States](#7-components--interaction-states)
8. [Content & Microcopy](#8-content--microcopy)
9. [Motion](#9-motion)
10. [Accessibility Is Not Optional](#10-accessibility-is-not-optional)
11. [Design Tokens & Systems](#11-design-tokens--systems)
12. [Process: How Non-Slop Gets Made](#12-process)
13. [The Anti-Slop Review Checklist](#13-the-anti-slop-review-checklist)
14. [Further Study](#14-further-study)

---

## 1. What AI Slop Actually Is

"Slop" is not "ugly." Slop is **undifferentiated plausibility** — output that is statistically likely given a prompt, and therefore indistinguishable from ten thousand other outputs. It has three signatures:

1. **No point of view.** It answers "make a landing page" but not "make *this* product's landing page for *these* users at *this* moment."
2. **Defaults all the way down.** Default font, default radius, default shadow, default 3-column grid, default gradient. Every unmade decision defaults to the training-set mean.
3. **Surface without substance.** Empty states, error states, loading states, edge cases, and real content are missing — because generation rewards the demo, not the product.

Dieter Rams' tenth principle — *"Good design is as little design as possible"* — is the antidote. Slop is *maximal* design: everything decorated, nothing decided. (See Rams' *Ten Principles for Good Design*.)

---

## 2. The Diagnostic: 20 Slop Tells

If you can check three or more of these, you're looking at slop.

**Visual**
1. The indigo→purple hero gradient (`#6366f1 → #a855f7`) with centered white text.
2. Everything is a rounded card with the same shadow on a `#f9fafb` background.
3. Emoji used as product iconography (🚀 "fast", 🔒 "secure", ✨ "AI-powered").
4. One font (usually `Inter`) at weights 400/500/600 only — no real contrast.
5. Perfectly symmetrical, center-aligned, no focal point.
6. Border-radius, shadow, and spacing are all framework defaults.
7. Gradients used decoratively with no meaning (rainbow ramps, "glassmorphism" for its own sake).
8. Hover states that just do `scale(1.05)` on everything.

**Structural**
9. The 3-column "features" grid with an icon, a bold word, and two lines of gray text.
10. Stat band: "10k+ Users · 99.9% Uptime · 24/7 Support" with no substance.
11. Testimonials with generic avatars and vague quotes.
12. A pricing table with the middle tier "Most Popular" and no real differentiation.

**Content**
13. "Empower your workflow", "Unlock seamless experiences", "Take X to the next level."
14. CTA says "Get Started" everywhere with no context.
15. Body copy that describes *features* the way a spec sheet would, never outcomes.

**Completeness**
16. No empty state, no loading skeleton, no error message design.
17. Forms with no validation, no inline errors, no success feedback.
18. No dark mode / no responsive thought / fixed pixel widths.
19. Placeholder images that are obviously stock or obviously AI (mangled hands/text).
20. No accessibility: fails contrast, no focus rings, no reduced-motion handling.

### 2.1 The 2026 Addendum: The Post-Generative Tells

By 2026, "AI slop" has a specific, widely recognized visual signature — designers and developers can name the tells on sight, and it has become its own backlash. A few new ones worth naming explicitly:

21. **The Tailwind indigo gradient specifically.** The blue-to-purple hero gradient traces to a single default (`indigo-500`) that got baked into millions of tutorials and templates, which then trained the models that now reproduce it by default. It's not "a gradient is bad" — it's that this *exact, unchosen* gradient signals nobody made a color decision.
22. **The bento grid as a reflex.** A useful layout pattern for genuinely heterogeneous content, now stamped onto every dashboard and pricing page regardless of whether the content has that shape.
23. **"Liquid glass" / glassmorphism as default chrome.** Frosted, translucent panels applied everywhere rather than where depth communicates real z-axis meaning — a trend accelerated by 2025's OS-level glass aesthetics and now in visible backlash.
24. **Icon-set monoculture.** Lucide or Hero Icons on every single project isn't wrong by itself, but combined with the rest of the checklist it's a tell that no one considered a custom or distinctive icon language.
25. **The pill badge above the headline.** A small rounded label ("✨ New", "Now in beta") floating above a centered hero headline — vanishingly rare in hand-designed pages before ~2023, ubiquitous in generated ones since.
26. **Distributional convergence.** The deeper mechanism behind all of the above: a model predicting the statistically average design *is* the model doing its job correctly — the average of millions of landing pages is a centered hero, a blue button, and three cards. "Looks AI-generated" is downstream of "looks like the mean," which is exactly what an uninstructed model will produce every time.

The stakes are not just aesthetic. Sites that read as generic, templated AI output have been observed converting dramatically worse than differentiated ones — genericness is a business cost, not just a taste problem.

---

## 3. First Principles

### 3.1 Design is deciding, not arranging
A layout where everything is `gap-4 text-center` isn't designed — it's arranged. Design is choosing what the eye sees **first, second, third**. If you can't point at the intended reading order, there is no hierarchy.

### 3.2 Start from the job, not the canvas
Borrowing from Clayton Christensen's *Jobs To Be Done*: users "hire" your UI to make progress on a specific job. Every screen should be answerable in one sentence: *"This screen helps [user] [do job] so they can [outcome]."* If you can't fill that in, you're decorating.

### 3.3 Constraints create character
- One display typeface + one workhorse text typeface beats one variable font at three weights.
- A palette chosen for a *reason* (brand, domain, mood) beats a random Tailwind slice.
- A committed grid you break *deliberately* beats no grid.

### 3.4 References from the physical world
Slop happens when the only reference is other software. Pull from editorial/print (Massimo Vignelli, Josef Müller-Brockmann's *Grid Systems*), packaging, signage, wayfinding, and film title design. That's where distinctiveness lives.

### 3.5 Rams, Norman, Tufte — the load-bearing canon
- **Dieter Rams:** less, but better; honest; unobtrusive; thorough to the last detail.
- **Don Norman (*The Design of Everyday Things*):** affordances, signifiers, feedback, and mapping. If users can't tell what's clickable or what happened, the design failed regardless of how it looks.
- **Edward Tufte:** maximize the data-ink ratio; remove non-informative decoration ("chartjunk"). Applies to UI chrome as much as charts.

---

## 4. Typography

> Type is ~90% of most interfaces. Get it right and mediocre layout still reads as competent; get it wrong and nothing saves you.

### 4.1 Build a real type scale
Use a **modular scale** with meaningful jumps, not four clustered sizes. A common musical ratio is the *Perfect Fourth (1.333)* or *Major Third (1.25)*.

Example scale (px), Major Third from a 16px base:
```
Caption   13
Body      16   ← base
Lead      20
H4        25
H3        31
H2        39
H1        49
Display   61 / 76
```
**Why:** distinct steps create instant hierarchy; adjacent-but-different sizes (15/16/17) read as noise.

### 4.2 Contrast in size *and* weight
Timid `500` vs `600` is a slop tell. Pair **400 body** with **700+ headlines**. Weight contrast does more for hierarchy than size alone.

### 4.3 Measure (line length)
Body text should be **45–75 characters per line** (~66 is the classic ideal — see Bringhurst, *The Elements of Typographic Style*). Full-bleed paragraphs across a 1440px viewport are unreadable and unmistakably slop.
```css
p { max-width: 66ch; }
```

### 4.4 Line height (leading)
- Body: **1.4–1.6**.
- Headlines/display: **1.0–1.2** (tighter as size grows).
- Longer measure → slightly more leading.

### 4.5 Tracking (letter-spacing)
- Large display: tighten, e.g. `-0.02em`.
- All-caps labels: loosen, e.g. `+0.05em to +0.1em`.
- Body: leave at 0. Don't track body text.

### 4.6 Alignment
Left-align body (in LTR). Reserve centering for **short** items (a hero headline, a single CTA). Centered paragraphs create ragged left edges the eye can't anchor to.

### 4.7 Typeface pairing that isn't slop
- Pair by **contrast of role**, harmony of proportion: a characterful display face + a neutral, high-legibility text face.
- Legible workhorses beyond `Inter`: *Source Sans*, *IBM Plex Sans*, *Public Sans*, *Geist*, *Söhne*/*Untitled* (licensed).
- For personality: a serif (*Fraunces*, *Newsreader*, *GT Sectra*) or a distinctive grotesque as display.
- Enable OpenType features where relevant: real fractions, tabular figures for tables (`font-variant-numeric: tabular-nums`), true small caps.

---

## 5. Color & Contrast

### 5.1 Structure the palette
- **1 dominant** brand/base hue.
- **A neutral ramp** (9–12 steps) — this is where 80% of the UI lives.
- **1 accent** reserved almost exclusively for primary action.
- **Semantic** colors: success / warning / danger / info — each with a full ramp, not one value.

### 5.2 Off-neutrals read as intentional
Pure `#ffffff` / `#f9fafb` / `#000000` read as defaults. A warm paper (`#F6F3EE`), a cool slate (`#0E1116`), or tinted grays feel authored.

### 5.3 Tint your shadows
Shadows in the real world aren't pure black; they carry ambient hue. Use the palette:
```css
/* slop */   box-shadow: 0 1px 3px rgba(0,0,0,0.1);
/* better */ box-shadow: 0 1px 2px rgba(30,20,60,0.10),
                         0 8px 24px rgba(30,20,60,0.08);
```
Layered shadows (a tight one + a soft one) mimic real light far better than a single blur.

### 5.4 Use a perceptual color space
sRGB interpolation produces muddy midpoints. Prefer **OKLCH/OKLab** for generating ramps and gradients so lightness stays perceptually even. Modern CSS supports it:
```css
color: oklch(0.62 0.19 264);
background: linear-gradient(in oklch, ...);
```

### 5.5 Contrast (hard requirement)
- Body text: **≥ 4.5:1** (WCAG AA). Large text (≥24px, or ≥18.66px bold): **≥ 3:1**.
- Aim for **AAA (7:1)** on primary reading text where feasible.
- UI components and focus indicators: **≥ 3:1** against adjacent colors (WCAG 2.1 SC 1.4.11).
- Note WCAG 2 luminance-contrast has known blind spots; **APCA** (from WCAG 3 drafts) models real readability better — check both when in doubt. *Beautiful and inaccessible is still failing.*

### 5.6 Don't encode meaning in hue alone
~8% of men have some color-vision deficiency. Pair color with icon/shape/text (e.g., error = red *and* an icon *and* a label).

---

## 6. Layout, Grid & Space

### 6.1 Commit to a spacing scale
Use a consistent step system (a 4px or 8px base is standard):
```
4  8  12  16  24  32  48  64  96
```
**Why:** consistent rhythm without monotony. Random one-off margins are a slop tell.

### 6.2 Hierarchy through proximity (Gestalt)
Related items close, unrelated items far. Whitespace *is* grouping. This is the Gestalt principle of proximity doing hierarchy work for free.

### 6.3 Asymmetry and focal points
Perfect symmetry is safe and dull. Off-center compositions, a dominant element, and intentional imbalance read as authored. Every screen should have **one** clear focal point.

### 6.4 Rhythm: dense next to open
Uniform spacing everywhere reads as generated. Alternate compact, information-dense regions with generous breathing room to guide pacing.

### 6.5 Break the grid on purpose
Overlap, full-bleed images, elements that cross columns — used *sparingly* — create memorable moments. Undisciplined, they create chaos. Establish the grid first; then break it.

### 6.6 Responsive is a design act, not an afterthought
- Design mobile, tablet, and desktop *intentionally* — don't just let things reflow.
- Use fluid type/space with `clamp()` so scaling is continuous, not steppy:
```css
h1 { font-size: clamp(2rem, 1.2rem + 3vw, 3.75rem); }
```
- Respect safe areas and thumb reach on mobile.

---

## 7. Components & Interaction States

### 7.1 Every interactive element needs all its states
The #1 completeness tell. Design and implement:
`default · hover · active/pressed · focus (visible) · disabled · loading · error · success · empty · selected`

Focus is non-negotiable:
```css
:focus-visible { outline: 2px solid var(--focus); outline-offset: 2px; }
```
Never `outline: none` without a replacement.

### 7.2 Button hierarchy
Exactly one **primary** with real presence per view. Secondary and tertiary must be visibly subordinate. Three equal-weight buttons = no hierarchy = slop.

### 7.3 Cards, used responsibly
If you must use cards: vary size by importance, prefer **1px borders** over stacking identical shadows, and don't wrap *everything* in a card. A page that is only cards has no hierarchy.

### 7.4 Iconography
Use **one** coherent icon set at a consistent stroke weight and grid — Lucide, Phosphor, Radix Icons, or a custom set. Match icon stroke to your type weight. **Never emoji as UI icons.** Give icons accessible labels (`aria-label`) or hide decorative ones (`aria-hidden="true"`).

### 7.5 Forms (where craft is proven)
- Labels are always visible (placeholder-as-label fails accessibility and usability).
- Inline, specific validation ("Enter a valid email" beats "Invalid input").
- Show progress, disable double-submit, confirm success.
- Sensible input types, autocomplete tokens, and `inputmode` for mobile keyboards.

### 7.6 Empty / error / loading states
These separate craft from slop:
- **Empty:** explain what goes here and offer the first action.
- **Loading:** skeletons that match final layout; avoid layout shift (watch CLS).
- **Error:** say what happened, why, and how to recover — never a bare stack trace or "Something went wrong."

---

## 8. Content & Microcopy

Design is 90% words. Slop copy is the loudest tell.

- **Outcomes over features.** "Ship on Fridays without fear" beats "Automated CI/CD pipelines."
- **Specific over grand.** Replace "empower / seamless / next level / revolutionize" with concrete claims.
- **Contextual CTAs.** "Start my free trial" / "Import 500 contacts" beats a wall of "Get Started."
- **Voice with a spine.** Pick a tone (plain, warm, terse, playful) and hold it. See Mailchimp's Content Style Guide and Nielsen Norman's writing research.
- **Error messages are UX.** Human, blameless, actionable.
- Use **real or realistic content** while designing. Lorem ipsum hides layout failures that real strings expose (long names, empty fields, huge numbers, RTL).

---

## 9. Motion

### 9.1 Motion must mean something
Animate to communicate **cause and effect**, **spatial relationships**, and **state change** — not to decorate. (See Google's Material Motion and Disney's 12 principles adapted for UI.)

### 9.2 Timing and easing
- UI transitions: **150–300ms**. Larger/entering elements slightly longer; exits slightly faster.
- Never linear for UI. Use eased curves; e.g. `cubic-bezier(0.2, 0, 0, 1)` (decelerate) for entrances.
- Prefer transform/opacity (compositor-friendly) over animating layout properties.

### 9.3 Respect user settings
```css
@media (prefers-reduced-motion: reduce) {
  * { animation-duration: 0.01ms !important;
      transition-duration: 0.01ms !important;
      scroll-behavior: auto !important; }
}
```
Vestibular disorders make gratuitous motion physically harmful. This is accessibility, not preference.

### 9.4 Avoid the slop trifecta
Everything fades up on scroll; everything hovers to `scale(1.05)`; nothing has a reason. Motion with no information content is noise.

---

## 10. Accessibility Is Not Optional

Accessible design is *better* design, and inaccessible beauty is failure. Target **WCAG 2.2 AA**.

- **Perceivable:** contrast (§5.5), text alternatives, captions, resizable text to 200% without loss.
- **Operable:** full keyboard operability, visible focus, no keyboard traps, respect reduced motion, targets **≥ 24×24px** (SC 2.5.8; 44×44 recommended for touch).
- **Understandable:** predictable behavior, clear labels, helpful errors.
- **Robust:** valid semantic HTML first; ARIA only to fill gaps ("No ARIA is better than bad ARIA").
- Structure with real landmarks and a logical heading outline (`h1→h2→h3`), not `div`s styled to look like headings.
- Test with a **keyboard only** and a **screen reader** (VoiceOver, NVDA), not just your eyes.

### 10.1 Overlay widgets are the accessibility version of slop

A one-line "AI-powered accessibility widget" bolted onto a site is the accessibility equivalent of a narration comment: it looks like effort was spent without the underlying problem being fixed. These overlays modify the page client-side without touching the source HTML, and by 2026 the evidence against them is concrete rather than anecdotal: hundreds of businesses running overlay widgets have been sued anyway, since the underlying markup a screen reader or an automated scanner sees is unchanged; overlays frequently conflict with users' own assistive technology rather than complementing it; and a major overlay vendor was fined by the FTC for falsely claiming its tool could make any website WCAG-compliant. Plaintiffs' attorneys have started citing overlay usage itself as evidence a company knew about accessibility requirements and chose the cheapest possible response.

The fix is the same principle as everywhere else in this guide: **the source has to actually be correct.** Semantic HTML, real focus management, and genuine keyboard operability aren't optional extras an overlay can paper over after the fact — they're the actual work. If a preference widget (font size, contrast toggle) adds real value on top of a genuinely accessible base, that's fine; sold as *the* compliance mechanism, it isn't.

---

## 11. Design Tokens & Systems

Slop is inconsistent; systems are consistent by construction.

- Define **tokens** for color, type, space, radius, shadow, z-index, motion — and reference them everywhere. No magic numbers in components.
- Structure tokens in tiers (per the **W3C Design Tokens** direction and Salesforce's original concept):
  - **Primitive** (`blue-600`, `space-4`)
  - **Semantic** (`color-action`, `space-inset-md`)
  - **Component** (`button-bg`, `card-radius`)
- Semantic tokens make theming (light/dark, brands) a data change, not a redesign.
- Keep design files and code tokens in sync (Style Dictionary, Tokens Studio).

---

## 12. Process

Non-slop is a process outcome, not luck.

1. **Frame the problem.** Who, what job, what constraints, what success looks like.
2. **Gather real references** (mood board from *outside* software) and articulate a point of view in one sentence.
3. **Wireframe in grayscale** to force hierarchy and content order before color/decoration can hide weak structure.
4. **Use real content and all states** from the first high-fidelity pass.
5. **Critique against principles**, not opinions — cite hierarchy, contrast, Fitts's Law, Gestalt, accessibility.
6. **Test with humans.** Five users surface ~80% of usability issues (Nielsen). Watch, don't ask.
7. **Iterate; subtract.** The last 20% of polish (and the deletions) is what separates authored from generated.

### 12.1 If you're prompting a model, constrain it before you prompt it

A generic instruction ("build a landing page") hands every taste decision to the model at once, and per §2.1 it will fill all of them with the statistical mean. The fix follows directly from §3.3: give the tool the same constraints you'd give a junior designer.

- **Supply the real inputs before generation**: an actual typeface (not "a modern sans"), an actual palette pulled from the brand (not "blue, professional"), a named layout principle, and a tone of voice.
- **Write down the bans explicitly** if a tool keeps reverting to defaults: no centered-hero-as-default, no unearned glassmorphism, no icon set chosen by popularity, no gradient without a stated reason.
- **Treat the first generation as a draft to push past, not a deliverable.** The teams producing distinctive work with these tools are the ones editing the output hardest, not the ones with the best prompt.
- **Persist the constraints as reusable project context** (a style guide, a tokens file, a written "taste" brief) rather than re-typing them per prompt — consistency across a whole product depends on the constraints outliving any single conversation.

### 12.2 Committing design changes: git messages that survive the handoff

Design work that lives in code — tokens, components, CSS, Figma-to-code exports — needs commit messages that carry design *rationale*, not just a file list. "Updated button styles" tells a future editor nothing about whether they're allowed to change it back.

**What a design commit message should carry that a code one doesn't:**
- **The decision, not just the change.** "Increase primary-button contrast to meet AA (was 3.8:1, now 4.6:1)" beats "fix button colors" — it tells the next person *why* the value is what it is, so they don't "fix" it back.
- **What it visually affects**, named precisely: component, token, or breakpoint — not "styles" or "UI."
- **A before/after reference** where the tool allows it (a linked screenshot, a Storybook/Chromatic diff link, a Figma frame) — visual changes are hard to review from a text diff alone.
- **Token renames and removals called out explicitly** in the body, since these are breaking changes for every consumer of the design system, even though the diff looks like a one-line rename.

**Example:**
```
fix(tokens): raise --color-text-muted contrast to meet WCAG AA

--color-text-muted at #9CA3AF on our --color-surface background
measured 3.8:1, failing the 4.5:1 body-text minimum (§5.5). Darkened
to #6B7280 (4.6:1). Affects secondary text across cards, table rows,
and form helper text — spot-checked all three in light and dark mode.

Refs #219 (a11y audit)
```

This is the same imperative-mood, why-not-what structure covered for code in [§15.1](#151-writing-a-commit-message-worth-reading-later) of the code guide — design changes just need one more thing in the body: the visual or perceptual reason the pixels moved.

---

## 13. The Anti-Slop Review Checklist

**Intent & hierarchy**
- [ ] I can state the screen's job in one sentence.
- [ ] There is a clear first / second / third reading order.
- [ ] There is exactly one focal point and one primary action per view.

**Typography**
- [ ] A real modular scale with distinct steps.
- [ ] Weight contrast (400 body vs 700+ headings), not 500/600 only.
- [ ] Body measure is 45–75ch; body is left-aligned.

**Color**
- [ ] Palette is *reasoned* (dominant + neutrals + one accent + semantics).
- [ ] Off-neutrals, tinted/layered shadows.
- [ ] Contrast meets AA (text 4.5:1, UI 3:1); meaning isn't hue-only.

**Layout**
- [ ] Consistent spacing scale; intentional rhythm (dense + open).
- [ ] Deliberate asymmetry; responsive designed, not just reflowed.

**Components & content**
- [ ] Every interactive element has all states, including `:focus-visible`.
- [ ] No emoji as UI icons; one coherent icon set.
- [ ] Empty, loading, and error states are designed.
- [ ] Copy is specific and outcome-oriented; CTAs are contextual.
- [ ] Real content stress-tested (long/empty/huge/RTL).

**Motion & a11y**
- [ ] Motion carries meaning; timing eased 150–300ms; reduced-motion honored.
- [ ] Keyboard-navigable, screen-reader tested, targets ≥24px, semantic HTML.
- [ ] Accessibility is fixed at the source, not bolted on with an overlay widget.

**The gut check**
- [ ] Could a generic prompt have produced this exact screen? If yes, push further.
- [ ] Is there at least one deliberate, memorable moment?
- [ ] Would a designer I respect see *decisions*, not *defaults*?
- [ ] If I generated a first draft with AI, did I give it real constraints — or did I let it default to indigo gradients, bento grids, and stock icons?
- [ ] Commit messages for design/token changes state the visual rationale and call out breaking token renames, not just "updated styles."

---

## 14. Further Study

- Dieter Rams — *Ten Principles for Good Design*
- Don Norman — *The Design of Everyday Things*
- Edward Tufte — *The Visual Display of Quantitative Information*
- Robert Bringhurst — *The Elements of Typographic Style*
- Josef Müller-Brockmann — *Grid Systems in Graphic Design*
- Ellen Lupton — *Thinking with Type*
- Steve Krug — *Don't Make Me Think*
- Nielsen Norman Group — usability research and heuristics (nngroup.com)
- W3C — *WCAG 2.2* and the *Design Tokens* Community Group
- Refactoring UI (Wathan & Schoger) — practical UI heuristics
- Laws of UX (lawsofux.com) — Fitts, Hick, Jakob, Gestalt, etc.
- Material Design & Apple Human Interface Guidelines — as references to understand, not to copy
- Creative Boom and similar design-press coverage of the 2025–2026 "AI slop" backlash (gradients, glassmorphism, bento grids, caricature illustration)
- eMarketer's forecasts on AI-generated web content share — context for why distinctiveness is becoming a competitive requirement, not a nicety

---

## The One-Line Test

> **Slop is the average of everything. Design is a defensible decision.**

If you can't point to the decisions — and defend them with a principle — you haven't finished designing.
