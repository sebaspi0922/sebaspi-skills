# Rendering notes

## Manim Community

```bash
manim --version                       # check it is installed
manim -ql scenes.py Intuition         # draft, 480p15, fast
manim -qh scenes.py Intuition         # final, 1080p60
manim -qh --resolution 1080,1920 scenes.py Intuition   # vertical
```

Minimal scene pattern (one learning step per `self.play`, `wait` = narration time):

```python
from manim import *

ACCENT = YELLOW   # "look here"
ERROR = RED       # misconceptions

class Intuition(Scene):
    def construct(self):
        title = Text("Why the area is base × height / 2", font_size=40).to_edge(UP)
        tri = Polygon([-2, -1, 0], [2, -1, 0], [-2, 1.5, 0])
        rect = Rectangle(width=4, height=2.5).move_to(tri.get_center_of_mass()).align_to(tri, DL)
        self.play(Write(title))
        self.play(Create(tri)); self.wait(1.5)
        self.play(Create(rect.set_stroke(ACCENT))); self.wait(2)
        prompt = Text("Pause: what fraction of the rectangle is the triangle?", font_size=30).to_edge(DOWN)
        self.play(FadeIn(prompt)); self.wait(4)      # retrieval pause
        self.play(FadeOut(prompt), tri.animate.set_fill(ACCENT, 0.5)); self.wait(2)
```

Tips: `MathTex` needs a LaTeX install; if missing, use `Text` or install a minimal TeX. Use
`TransformMatchingTex` to show what changed in an equation. Code: `Code(code_file=..., language=...)`
(argument names vary by version; check `help(Code)`).

## HTML → video

Good for code walkthroughs, diagrams and text. Build each scene as a page with a deterministic
timeline (CSS/JS animations driven by a time variable), then render with a frame-accurate tool
(HyperFrames, Remotion, or Playwright capturing frames at fixed time steps + ffmpeg). Never rely
on real-time screen recording of the browser for final output; frames drop.

## Slides → video

```bash
# slides/01.png ... with durations in list.txt:
#   file 'slides/01.png'
#   duration 6
#   ... (repeat the last file once without duration)
ffmpeg -f concat -safe 0 -i list.txt -i voice.wav -vf "fps=30,format=yuv420p" \
  -c:v libx264 -crf 18 -c:a aac -b:a 160k -shortest -movflags +faststart lesson.mp4
```

## Assembling scenes

```bash
# scenes/*.mp4 already have their audio
printf "file '%s'\n" scenes/*.mp4 > concat.txt
ffmpeg -f concat -safe 0 -i concat.txt -c:v libx264 -crf 18 -pix_fmt yuv420p \
  -c:a aac -b:a 160k -movflags +faststart out/lesson.mp4

# burn captions (optional; otherwise ship the .srt next to the mp4)
ffmpeg -i out/lesson.mp4 -vf "subtitles=lesson.srt:force_style='FontSize=22'" -c:a copy out/lesson_cc.mp4
```

## Narration timing

```bash
for f in voice/*.wav; do printf "%s %s\n" "$f" "$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")"; done
```
Scene duration = clip duration + planned pause. Add silence with `-af apad=pad_dur=4`.
