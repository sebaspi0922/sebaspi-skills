---
name: no-ai-look-ui
description: Use whenever you create or polish a web page, UI, landing, dashboard, form or visual component (HTML/CSS, React, Tailwind) so it does not look AI-generated. Gives principles, a table of "AI tells" with what to do instead, concrete defaults, a review mode for existing UI, and a final checklist.
license: MIT
---

# UI without the AI look

A model with no direction produces the average of what it has seen: Inter, a violet gradient, rounded card with a
shadow, an icon in a colored square, an UPPERCASE eyebrow label, pills, an indigo button. That is what people
recognize as "made by AI". The fix is not another trendy trick; it is **deciding on purpose** and removing
everything that has no reason to be there.

New UI: sections 1, 2, 4 and 5, then the checklist. Existing UI: review mode (section 3).

## 1. Before writing CSS (2 minutes, in writing)
1. **For whom and for what**: one sentence. What must the person do on this screen? One priority.
2. **The hero element**: the most specific thing in this case (the command, the number, the photo, the text).
   It leads; everything else is subordinate. Color and detail go there. Nav, backgrounds, borders and labels stay quiet.
3. **Character and signature**: two or three concrete words taken from the product (calm, exact, a bit warm).
   "Clean, modern, sleek, minimal, premium" don't count: they describe any template. One detail only this product
   would have, repeated consistently. If there is a real brand (logo, color, chosen type), build around it.
   Gradients, glow or sparkles are not a brand.
4. **Minimal token plan**: 4-6 colors with a role, 1-2 type families, a size scale, a spacing scale, 1-2 radii.
   If there is a `DESIGN.md` or existing styles, use them and don't invent.
5. Check the plan against the tells (section 4). If it hits one, change it before building.

## 2. Principles
- **Remove before adding.** Every box, border, icon, label and color must earn its place. If deleting it loses no
  information, it goes. Don't swap one ornament for another (glass, grain, neon, bento).
- **Hierarchy through size, weight, color and space, not containers.** Group by proximity (close = related, more
  air between groups). Emphasize by lowering what competes, not by shouting louder.
- **One accent voice.** Neutrals plus one accent used with meaning (primary action, selection, the number that
  matters). Status colors (ok/error) only for a real state, and always with text, never color alone.
- **Quiet chrome, one rich moment.** Color spread over backgrounds, buttons and labels is the template.
  Richness goes into one or two pieces of real content (a clear chart, the real object, the key number).
- **Typography with intent.** Type is the personality. Clear scale, comfortable leading, 45-75 character measure.
  Mix weights and sizes before adding families.
- **Real content, not filler.** Headlines, numbers, empty states and the hero come from this product: what it does,
  for whom, with its data. "Welcome back", "AI insights", "$123,456", "[X]", "10,000+ teams" or "10x faster" are
  not content. If the data isn't there, remove it. Never invent features, claims or names, never rename the product.
  If swapping the product name would make the screen fit another product, the copy is not ready.
- **Concrete, human copy.** Verbs that say what happens ("Run", "Save token"), errors that explain how to fix them,
  zero brochure enthusiasm. Short labels ("Search", not "Search for anything…"). A change says against what
  ("+12% vs last month").
- **Craft in the details.** Focus, loading, error and empty states; 44 px touch targets; a designed dark mode (not
  inverted); tabular numbers; a real `…`; no layout shift on load.
- **Function first.** Validation, errors next to the field, accessibility. A pretty UI that breaks is slop.

## 3. Review mode (existing UI)
Judge what is visible, not only the code. If you can open the app or file, take a screenshot before editing. One fast pass.

1. **Detect.** Walk section 4. One line per tell, with where it is.
2. **Prioritize.**
   - Many tells across color, type, icons and copy: full pass, in the order below.
   - Few, and there is a real brand: fix only what you detected. Don't change that brand's palette, type or layout.
   - None: say so and stop. Don't touch a good screen just to make it look different.
3. **Fix** the whole screen before the next step: spacing → color → icons → copy and real content → typography →
   layout → details → motion. Rhythm first, because everything reads differently once it lines up. Copy before
   type, because headline length decides its size.
4. **Verify.** New screenshot. Compare with the step-1 list. Whatever remains gets fixed. Short report: direction,
   before/after, and what changed in each step.

Keep features, real content and section order.

## 4. AI tells → what to do instead
| Tell | Instead |
|---|---|
| Hue-to-hue gradient (especially violet/indigo) on buttons, backgrounds, text or logo | Solid color. The product accent, or ink. Exception: one step within the same neutral (active row) |
| `indigo-500/600` as the primary button | Button in text ink or the product's own accent |
| Five nearly identical grays or lavenders; everything highlighted | Three text roles (primary, secondary, muted) from one ramp. One accent, used once or twice |
| Everything inside a shadowed card; cards inside cards | Flat page; group with space and, if needed, a thin line |
| Thin border plus wide shadow, neon border, colored shadow | Only one: a thin line (text at 8%) or a different background. Almost never a shadow |
| `rounded-2xl` (12-24 px) on everything, or everything a pill | Small, proportional radius (4-8 px); the same on all controls |
| Icon in a colored square, or icons of mixed sizes, colors or columns | No icon, or one from a single set, 16-18 px, 1.5 stroke, text color, same column |
| Generic logo: gradient square, glowing orb, sparkle | The name as text, or a flat single-color glyph |
| Tiny UPPERCASE tracked label ("eyebrow", `NAVIGATION`) | No label if self-explanatory; otherwise sentence case |
| Weights 700-900, or italics for emphasis | Size and color. Weight 400-600 |
| Negative tracking on text under 16 px | 0. Tight tracking only on large headings |
| Mixed number formats (`$48,210` next to `$124,860.40`) | One format, tabular figures |
| Pills and badges ("sudo · root", "New", "Beta", "✨ Introducing X", `PRO`) | Say it in the sentence or the heading. If truly needed, quiet text |
| Decorative green/pulsing status dot | Only for a real live state, and with text |
| Colored stripe on the side of every card | Remove it; only for real alerts |
| "A · B · C" chains, → arrows on every link | A normal sentence ("Requested 2 min ago; expires in 58") |
| Loose values (`mt-[13px]`, `h-[31px]`), rows of different heights, big gap on top and cramped below | Multiples of 4. Same things, same height and same gap |
| Centered hero + 3 icon cards + CTA, or three buttons | The hero element, left-aligned. One primary action and at most one secondary |
| Hero, headline or visual that would fit any product; blobs, robots, brains, holograms | What this one does and for whom. The visual is the product, not decoration |
| Inter/Roboto/system-ui "just because", everything in one weight | Choose a family on purpose; if it must be the system font, work the scale and weights |
| Glassmorphism, glow, halos, noise, text or buttons baked into an image | Flat surface. Text lives in the page, not inside the image |
| Animation everywhere: fade-up, bounce, `transition-all`, `hover:scale`, animating width/height/top/left | Only in response to an action: color, background, border, opacity or transform, 150-200 ms, no bounce |
| Emojis as icons or inside labels (✨ 🚀 on every heading) | Text, or icons from one set and stroke |
| Generic copy: "Unlock", "Supercharge", "Welcome back", "AI insights", "Done! 🎉" | What happens, with this product's data ("Finished without errors at 21:40") |
| Invented data or claims: "$123,456", "[X]", "10,000+ teams", "10x" | The real number, or nothing |
| Long placeholder or a change with no reference ("Search for anything…", "+12%!!") | Short label. "+12% vs last month" |
| Rainbow chart, glowing bars, a sparkline on every stat, identical cards in a row | One main chart; the rest is number, label and change. Different widths |
| Lots of em dashes and "It's not X. It's Y." sentences | Normal periods and commas; direct sentences |
| Second wave: cream + serif + terracotta, black + acid green, newspaper look | Don't use them by default; only when the case asks for it |

## 5. Defaults (when nobody says otherwise)
Dark mode with one warm accent (for example amber `#F9AE24`). If there is a real brand, the brand wins.

- **Layout.** Page, form or text: one left-aligned column, `max-width` ~32-40rem; 20 px side margin on mobile;
  `padding-top` 8-12vh on large screens. No wrapping card. App or dashboard: the shell fills the viewport (sidebar
  240-280, padding 24-32, content up to ~1440-1600); don't shrink it to 40rem. Top bar 56-64. Nav rows 32-36, gap
  2-4; a section label sits closer to its items (8) than to the previous block (24). Landing hero left-aligned, with
  a real product visual (at least half the width) or the text over that visual. Nav to headline: 96-128 desktop, 48-64 mobile.
- **Typography.** Body 16-17 px, `line-height` 1.5. Page title 22-28 px, weight 600, `line-height` 1.2,
  `letter-spacing` -0.01em, `text-wrap: balance`. Landing hero: 36-44 mobile, 56-72 desktop, weight 500-600.
  Secondary 14-15 px, never < 13 px. Few sizes: 13 / 15 / 17 / 24. Three roles, not ten grays. 400 for body, 500-600
  for headings, never 700-900. No italic emphasis. Tracking 0 under 16 px. Mono only for code, meta and figures.
  Inputs ≥ 16 px (otherwise iOS zooms).
- **Numbers.** `tabular-nums` and one format across the screen.
- **Color.** Dark: background #111-#161616 (not pure black), text #ececec, gray #9a9a9a, line #2a2a2a. Light: white
  or near-white background, text #1a1a1a, gray with AA contrast (≥ 4.5:1), line #e5e5e5. Accent on little surface.
  Check accent contrast: amber passes AA on dark (~10:1) as text or fill, but fails as text on white (~1.9:1), so an
  amber button carries #1a1a1a text. Green and red only for real state, with text, desaturated. In dark mode, depth
  comes from surface steps, not shadows.
- **Spacing.** Scale of 4: 4, 8, 12, 16, 24, 32, 48. 2 px only to center or adjust inside a small control. Inside a
  control 4-12; between related items 2-8; between groups 12-24; between sections 32-64 (landings 80-128). More air
  between groups than within. A heading sits closer to its content than to the previous block. Icons in one column,
  labels on one line, numbers right-aligned.
- **Radii.** 6 px on buttons, fields and code; 0 on the page. Never 16+ px without a reason. Nested: inner = outer − padding, never under 4.
- **Shadows.** None by default. If something floats (menu, dialog), one small neutral shadow. No colored shadows.
- **Buttons.** 44-48 px tall (32-36 in nav). Primary solid: accent with dark text, or ink. Secondary: text or thin
  border. Label = concrete verb, no trailing period. Visible hover and focus (`:focus-visible`, 2 px outline).
- **Icons.** Prefer none. If needed: the set the project already has; otherwise one stroke set. 16 or 18 px, 1.5
  stroke, text color, 8-10 gap, same box so labels align. No color of their own.
- **Copy.** Plain and direct. Short sentences. No exclamations or emojis. Sentence case, buttons included. Labels,
  buttons and headings without trailing periods. Real product data.
- **Dark mode.** Variables in `:root` + `prefers-color-scheme`; `color-scheme: light dark`; `meta theme-color` equal to the background.
- **Motion.** One curve: `cubic-bezier(0.22, 1, 0.36, 1)`. Hover and press 120-180 ms; menus 160-220 ms. Only color,
  background, border, opacity and transform. No `transition-all`. Respect `prefers-reduced-motion`.

## 6. Final checklist (real screenshot, mobile and desktop, light and dark)
In a review, compare the after screenshot with the before one and with the step-1 list.
- [ ] Is it clear in 3 seconds what matters and what I must do?
- [ ] Any hue-to-hue gradient, glow, big shadow, wrapping card or nested card left?
- [ ] Icons in squares, badges, pills, status dots or UPPERCASE labels?
- [ ] Radii ≤ 8 px, consistent, nesting correct? One accent, with contrast?
- [ ] Does hierarchy come from size/weight/space? In grayscale, does it read the same?
- [ ] Is the copy about this product? Buttons with verbs? Errors that say how to fix? Zero invented data?
- [ ] "·" chains, decorative arrows, exclamations, emojis, "Welcome back" or "AI insights"? Remove.
- [ ] Spacing on the 4 scale, equal things equal, icons and figures aligned?
- [ ] Visible focus, targets ≥ 44 px, inputs ≥ 16 px, AA contrast in both modes. Three text roles.
- [ ] States covered: loading, error, empty, success, expired.
- [ ] No layout shift, no horizontal overflow at 360 px. No animating width, height, top or left.
- [ ] If you swap the product name for another, does the screen still work? If yes, the copy or visual lacks a signature.
- [ ] Final question: "Would a careful designer sign this?" If something is there "just because", remove it.

## References
- Anthropic, *Improving frontend design through Skills* (distributional convergence, avoiding Inter and violet): https://claude.com/blog/improving-frontend-design-through-skills
- Official `frontend-design` skill (anthropics/skills): https://github.com/anthropics/skills/tree/main/skills/frontend-design
- Impeccable, catalog of slop patterns with fixes: https://impeccable.style/slop
- *How to Fix AI Slop in Web Design, Tell by Tell*: https://capitalandcompute.net/blog/fix-ai-slop-design/
- *Why Your AI Keeps Building the Same Purple Gradient Website*: https://prg.sh/ramblings/Why-Your-AI-Keeps-Building-the-Same-Purple-Gradient-Website
- The Fountain Institute, *7 Tells that a UI is AI-Generated*: https://pages.thefountaininstitute.com/posts/7-tells-that-a-ui-is-ai-generated
- *How to fix the AI-generated look in your frontend*: https://dev.to/alanwest/how-to-fix-the-ai-generated-look-in-your-frontend-1ahh
- Vercel, *Web Interface Guidelines*: https://vercel.com/design/guidelines
- Wathan and Schoger, *Refactoring UI*: https://www.refactoringui.com/

Includes ideas adapted from unslop (github.com/heydamir/unslop), CC BY 4.0, © heydamir; with changes.
