# Lesson design for learning videos

## Learning goals

Write goals as observable actions. Bad: "understand recursion". Good: "trace `fact(3)` call by
call", "say why the base case is required", "spot the missing base case in a snippet".
Each goal must map to at least one scene and one self-test question.

## Principles that matter on video

| Principle | What it means in practice |
|---|---|
| Retrieval practice | Ask before telling. "What happens if…? Pause." Recall beats re-watching. |
| Worked example → faded example | Show a full solution, then a similar one where the viewer does the last step. |
| Dual coding | Picture + narration of the same idea; not narration + the same words as text. |
| Signaling | Highlight exactly the term/line being spoken, at the moment it is spoken. |
| Segmenting | One idea per scene; natural pause points between scenes. |
| Misconception first | Show the tempting wrong answer, why it fails, then the right model. |
| Spacing (Review) | Mix prompts from different subtopics instead of in book order. |

## Scene templates

**Hook**: a question or a surprising result the viewer can't yet explain (≤ 15 s).

**Intuition**: a concrete case with real numbers/objects, animated step by step.

**Formalize**: the general rule or formula, with each symbol tied by color to the concrete case.

**Worked example**: full solution, each step appears as it is narrated.

**Your turn**: a similar problem, prompt + pause + answer.

**Misconception**: "A common mistake is…" in the error color → why it fails → correct version.

**Recap**: the goals, same wording as at the start, one line each.

## Review mode script pattern

```
Prompt 1 (on screen + spoken)  → 4 s pause with countdown → answer + 1-line why
Prompt 2 ...
Summary screen: everything on one frame, designed to be screenshotted.
```
Order prompts from easy to hard and interleave subtopics. 6–12 prompts per video.

## Subject-specific notes

- **Math/physics**: keep the derivation on screen; transform the expression instead of replacing
  it so the viewer sees what changed. Units always visible.
- **Programming**: real, runnable code; show input, ask for output, run, show real output. For
  algorithms, animate the data structure, not just the code. Version-specific APIs: check the
  current docs.
- **History/humanities**: a timeline or map as the persistent anchor; causes → event →
  consequences as a chain; dates verified against the viewer's source.
- **Languages**: the phrase, a pause for the viewer to say it, then the native audio; repeat in
  new context.
- **Biology/chemistry**: one diagram that is built up part by part, labels appearing as named.

## Self-test questions

3–5 at the end (Learn) or the prompts themselves (Review). Mix recall ("what is…"), application
("compute…/predict…") and one transfer question (a new situation). Provide answers in the summary.
