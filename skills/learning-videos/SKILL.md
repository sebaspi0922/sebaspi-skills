---
name: learning-videos
description: Use when someone wants a short video to learn, understand or review any topic (a concept, a formula, an algorithm, a chapter, a historical process, a codebase, exam material). Plans the lesson from learning goals, writes a narrated script with retrieval pauses, builds the visuals (Manim, HTML-to-video or slides), adds voice and captions, renders and verifies the result frame by frame before delivery.
license: MIT
---

# Learning videos

Goal: a video the viewer can *learn from or review with*, not a pretty animation. Every scene must
serve one learning goal, and the viewer must be asked to recall or predict something before the
answer appears. Works for any subject; programming is just one case.

## 0. Pick the mode

| Mode | Viewer state | Length | Shape |
|---|---|---|---|
| **Learn** | first contact | 3–8 min | hook question → intuition → formal version → worked example → recap |
| **Review** | has seen it before | 1–4 min | recall prompt → pause → answer → next prompt (repeat), ends with a one-screen summary |
| **Explain one thing** | stuck on a detail | 30–90 s | the confusing point → one picture that fixes it → one check question |

If the request does not say, ask one question: "first time learning this, or reviewing?"

## 1. Ground the content before animating

1. Collect the source the viewer actually studies from (notes, slides, chapter, docs, repo). The
   video follows *their* notation and terms, not a generic textbook's.
2. Write 2–5 learning goals as verbs the viewer could be tested on ("compute…", "explain why…",
   "predict the output of…"). Anything that serves no goal is cut.
3. List the 1–3 misconceptions that typically trip people up on this topic. Each becomes a scene.
4. Verify every fact, number, formula, date and code output that will appear on screen. Run code
   and paste real output; check formulas with a worked example; cite volatile facts. A wrong
   frame in a study video teaches the error.

Detail and templates: `references/lesson-design.md`.

## 2. Write the script (narration + screen plan)

Write `script.md` as a table, one row per scene:

| # | Goal | Narration (spoken) | On screen | Pause / prompt | Seconds |

Rules:
- One idea per scene. ~140–160 spoken words per minute; budget scenes from that.
- Concrete before abstract: example first, then the general rule, then the symbol.
- Narration and screen are complementary: never put the narration verbatim on screen. On-screen
  text is keywords, labels and the formula, ≤ 12 words at once.
- Insert a **retrieval prompt** at least every ~60 s (Learn) or every scene (Review): "Pause and
  predict…", followed by 3–5 s of silence with a visible countdown or "pause" cue, then the answer.
- Code topics: show the code, ask for the output, then run it. Highlight only the changed line.
- End with a recap of the goals in the same words as step 1, plus 1–3 self-test questions.

Show the script to the requester before building visuals; changes are cheap here and expensive later.

## 3. Choose the renderer

| Need | Use |
|---|---|
| Math, geometry, graphs, step-by-step transforms, algorithms on data structures | **Manim Community** (`manim -qm scene.py Name`) |
| Text-heavy explainers, diagrams, code walkthroughs, UI, kinetic type | **HTML/CSS/JS rendered to video** (HyperFrames, Remotion, or Playwright frame capture) |
| Quick review deck | **Slides → video**: one PNG per slide + ffmpeg concat with per-slide durations |
| Real software demo | Screen recording, then cut and annotate |

Use whatever is installed; check first (`manim --version`, `ffmpeg -version`, `node -v`). Do not
install heavy toolchains without the requester's OK.

Renderer notes and a minimal Manim scene pattern: `references/rendering.md`.

## 4. Build the visuals

- Style: one background, one text color, one accent for "the thing to look at now", one color
  for errors/misconceptions. Same color = same concept for the whole video.
- Readable on a phone: body text ≥ 4 % of frame height, code ≥ 28 px at 1080p, ≤ 12 lines of code.
- Motion only to show change or to direct attention: transform A into B, draw the arrow, highlight
  the term being spoken. No decorative motion.
- Build one scene per file/class so each can be re-rendered alone. Render drafts at low quality,
  final at 1080p (16:9) or 1080×1920 (vertical, for phone review).

## 5. Voice, timing and captions

1. Voice: the requester's own recording, or TTS if they agree (local first; a paid/cloud service
   only with their OK). Clean recorded voice with a local enhancer if needed.
2. Time scenes to the audio, not the other way around: measure each narration clip
   (`ffprobe -show_entries format=duration`) and set scene duration = clip + pause.
3. Retrieval pauses are real silence, at least 3 s; keep the prompt on screen during the pause.
4. Captions: generate SRT from the script (or transcribe with Whisper) and burn in or ship as
   sidecar. Captions use the same terms as the on-screen labels.
5. Mix: voice around −16 LUFS (−20 if there is music), music ≥ 18 dB under the voice, no music
   under formulas being explained.

## 6. Assemble, render, verify

Assemble with ffmpeg (concat of scene clips + audio), H.264 yuv420p + AAC, `+faststart`.
Then run the checker and look at the contact sheet yourself:

```bash
python3 scripts/check_video.py out/lesson.mp4 --frames 12 --script script.md
```

It prints duration/codec/resolution/loudness, flags long silences and black frames, compares
duration with the script budget, and writes `out/lesson_contact.jpg`. Inspect the sheet for: cut-off
text, overlapping labels, unreadable code, a wrong formula, a frame showing the answer before its
prompt. Fix and re-render only the affected scene.

## 7. Deliver

- The MP4, the SRT, `script.md` and a **one-page summary** (goals, key formula/code, the self-test
  questions with answers) so the video can be reviewed later without replaying it.
- For Review mode, offer the self-test questions as flashcards (front = prompt, back = answer).
- Say plainly what was verified (checker output, frames inspected) and what was not (you did not
  listen to the audio, unless you did).

## Pitfalls

- Answer visible before the prompt (e.g. the result already in the code panel): blank it until after the pause.
- Too much per scene: if narration for one scene exceeds ~40 s, split it.
- Generic notation that differs from the viewer's course: re-letter to match their source.
- Fancy 3D for a 2D idea: costs render time, adds nothing.
- Unverified numbers in charts or code outputs: run them.
- Rendering everything at final quality on each iteration: draft at low quality, final once.

## Checklist

- [ ] Mode chosen; 2–5 testable goals; misconceptions listed.
- [ ] Every fact, formula and code output on screen verified.
- [ ] Script approved; a retrieval prompt every ≤ 60 s with a real pause.
- [ ] One idea per scene; on-screen text ≤ 12 words; phone-readable sizes.
- [ ] Scenes timed to the measured narration; captions match labels.
- [ ] `check_video.py` passes; contact sheet inspected.
- [ ] Delivered MP4 + SRT + script + one-page summary with self-test answers.
