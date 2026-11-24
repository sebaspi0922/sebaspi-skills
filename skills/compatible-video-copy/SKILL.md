---
name: compatible-video-copy
description: Use to produce a technical H.264/AAC MP4 copy that plays almost everywhere (phones, messaging apps, social networks, browsers, editors) without touching the original, stripping timecode/data tracks, handling multiple audio tracks correctly and verifying with ffprobe.
license: MIT
---

# Compatible video copy (H.264/AAC)

Make an MP4 copy that opens anywhere from a video that may not (H.265, ProRes, MOV with a timecode track, several
audio tracks). Requires `ffmpeg` and `ffprobe`.

## Rules
- **Never touch the original:** don't move, rename or overwrite it. Same for an already approved export.
- The copy is a new file with a technical name (`<name>_H264_AAC.mp4`). If the project has a transcodes folder
  (e.g. `01_Transcodes/FFmpeg/`), put it there; otherwise ask where.
- Always `-n`: ffmpeg must not overwrite anything that exists.
- If it's unclear which file is the original, where the copy goes, or whether something else must be preserved, ask before encoding.
- Don't transcode a valid master "just in case": only when the compatible copy is requested.

## Steps

### 1. Inspect once
```bash
ffprobe -v error -show_streams -show_format -of json "input.mov"
```
Note: video track, **all** audio tracks, data or `tmcd` tracks, rotation, resolution, fps and duration.

**Multiple audio tracks are not redundant by default.** Compare them (channels, title, content: listen or measure
with `volumedetect`). If two mono tracks are really left and right, join them into stereo; don't silently drop one.

### 2. Encode with explicit mapping
Normal case (one video, one audio):
```bash
ffmpeg -n -i "input.mov" \
  -map 0:v:0 -map 0:a:0 \
  -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 18 -preset slow -tag:v avc1 \
  -c:a aac -b:a 192k -ar 48000 -ac 2 \
  -map_metadata -1 -map_chapters -1 -dn -write_tmcd 0 \
  -movflags +faststart \
  "output_H264_AAC.mp4"
```
Two mono tracks that are left and right:
```bash
ffmpeg -n -i "input.mov" \
  -filter_complex "[0:a:0][0:a:1]join=inputs=2:channel_layout=stereo[a]" \
  -map 0:v:0 -map "[a]" \
  -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 18 -preset slow -tag:v avc1 \
  -c:a aac -b:a 192k -ar 48000 \
  -map_metadata -1 -map_chapters -1 -dn -write_tmcd 0 -movflags +faststart \
  "output_H264_AAC.mp4"
```
- Keep geometry and fps: no `scale` or `-r` unless asked. If the source is variable frame rate (phones) and the
  target is an editor that needs constant, propose `-fps_mode cfr -r <fps>` and ask.
- High + AAC-LC is the default. Constrained Baseline only if the target is an old device that requires it.
- No audio in the source: drop `-map 0:a:0` and the audio options.

### 3. Verify no timecode or data survived
```bash
ffprobe -v error -show_entries stream=index,codec_type,codec_name,codec_tag_string,profile,pix_fmt -of csv=p=0 "output_H264_AAC.mp4"
```
Exactly one video line (`h264`, `High`, `avc1`, `yuv420p`) and one audio line (`aac`, `LC`, `mp4a`). No `data` or `tmcd` line.

If timecode survived, remux without re-encoding into a new file:
```bash
ffmpeg -n -i "output_H264_AAC.mp4" -map 0:v:0 -map 0:a:0 -c copy -map_metadata -1 -map_chapters -1 -dn -write_tmcd 0 -movflags +faststart "output_H264_AAC_clean.mp4"
```

### 4. Decode it fully
```bash
ffmpeg -v error -i "output_H264_AAC.mp4" -map 0:v? -map 0:a? -f null -
```
It must print nothing. Any line is an error to investigate.

## Delivery checklist
- [ ] The original still exists, unchanged (same size and date).
- [ ] The copy is in the agreed folder, with a new name.
- [ ] `ffprobe` shows only H.264 (High, yuv420p) and AAC, no `data` or `tmcd`.
- [ ] Orientation, resolution, fps and duration match the source (duration within one frame).
- [ ] Full decode gives no errors.
- [ ] Report the copy's path, its specs (resolution, fps, duration, size) and whether you joined or dropped any audio track and why.
