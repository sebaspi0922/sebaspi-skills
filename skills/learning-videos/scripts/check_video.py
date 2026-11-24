#!/usr/bin/env python3
"""Check a rendered learning video before delivery.

Usage: check_video.py VIDEO [--frames N] [--script script.md] [--max-silence S]

Prints container/codec/resolution/duration/loudness, flags long silences and black
segments, compares duration with the seconds budget in a script.md table (last column
named "Seconds"), and writes VIDEO_contact.jpg with N evenly spaced frames to inspect.
Exit code 1 if a hard problem is found (missing audio/video, non-yuv420p, odd size).
Needs ffmpeg and ffprobe on PATH.
"""
import argparse, json, re, subprocess, sys
from pathlib import Path


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)


def script_budget(path):
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    header, total = None, 0.0
    for line in lines:
        if not line.strip().startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if header is None:
            if any(c.lower().startswith("second") for c in cells):
                header = [c.lower() for c in cells]
            continue
        if set("".join(cells)) <= set("-: "):
            continue
        idx = next(i for i, c in enumerate(header) if c.startswith("second"))
        m = re.search(r"[\d.]+", cells[idx]) if idx < len(cells) else None
        if m:
            total += float(m.group())
    return total or None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("video")
    ap.add_argument("--frames", type=int, default=12)
    ap.add_argument("--script")
    ap.add_argument("--max-silence", type=float, default=6.0,
                    help="flag silences longer than this (retrieval pauses are usually 3-5 s)")
    a = ap.parse_args()
    v = a.video
    problems, warnings = [], []

    info = json.loads(run(["ffprobe", "-v", "error", "-show_streams", "-show_format",
                           "-of", "json", v]).stdout or "{}")
    streams = info.get("streams", [])
    vs = next((s for s in streams if s["codec_type"] == "video"), None)
    au = next((s for s in streams if s["codec_type"] == "audio"), None)
    dur = float(info.get("format", {}).get("duration", 0))
    if not vs:
        print("no video stream"); sys.exit(1)
    print(f"duration   {dur:.1f} s")
    print(f"video      {vs['codec_name']} {vs['width']}x{vs['height']} {vs.get('pix_fmt')} {vs.get('r_frame_rate')}")
    if vs.get("pix_fmt") != "yuv420p":
        problems.append(f"pix_fmt {vs.get('pix_fmt')} (use yuv420p for compatibility)")
    if vs["width"] % 2 or vs["height"] % 2:
        problems.append("odd frame size")
    if not au:
        problems.append("no audio stream")
    else:
        print(f"audio      {au['codec_name']} {au.get('sample_rate')} Hz {au.get('channels')} ch")
        r = run(["ffmpeg", "-hide_banner", "-nostats", "-i", v, "-af",
                 f"ebur128,silencedetect=n=-45dB:d={a.max_silence}", "-f", "null", "-"]).stderr
        m = re.findall(r"I:\s+(-?[\d.]+) LUFS", r)
        if m:
            lufs = float(m[-1])
            print(f"loudness   {lufs} LUFS integrated")
            if not -24 <= lufs <= -13:
                warnings.append(f"loudness {lufs} LUFS outside -24..-13")
        for s, e in zip(re.findall(r"silence_start: ([\d.]+)", r), re.findall(r"silence_end: ([\d.]+)", r)):
            warnings.append(f"silence {float(s):.1f}-{float(e):.1f} s (> {a.max_silence} s)")

    r = run(["ffmpeg", "-hide_banner", "-nostats", "-i", v, "-vf", "blackdetect=d=1:pix_th=0.05",
             "-an", "-f", "null", "-"]).stderr
    for s, e in re.findall(r"black_start:([\d.]+) black_end:([\d.]+)", r):
        warnings.append(f"black frames {float(s):.1f}-{float(e):.1f} s")

    if a.script:
        b = script_budget(a.script)
        if b:
            print(f"budget     {b:.0f} s in script")
            if abs(dur - b) > max(10, 0.15 * b):
                warnings.append(f"duration {dur:.0f} s vs script budget {b:.0f} s")

    out = str(Path(v).with_name(Path(v).stem + "_contact.jpg"))
    n = max(1, a.frames)
    cols = 4 if n >= 4 else n
    rows = -(-n // cols)
    fps = n / dur if dur else 1
    run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", v, "-vf",
         f"fps={fps:.6f},scale=480:-2,tile={cols}x{rows}", "-frames:v", "1", out])
    print(f"contact    {out}" if Path(out).exists() else "contact    (failed)")

    for w in warnings:
        print("WARN ", w)
    for p in problems:
        print("FAIL ", p)
    print("OK" if not problems else "FAILED")
    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    main()
