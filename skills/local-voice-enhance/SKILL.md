---
name: local-voice-enhance
description: Use when spoken voice recorded on a phone or camera mic needs cleaning (background noise, hiss, muddy tone, takes at different volumes) and the audio must stay on the machine. A local "Adobe Podcast Enhance" chain - DeepFilterNet + EQ + compression + matched loudness - that never overwrites originals, keeps sync and tells you how to keep the mix balance. Not for generating new voice or for music/SFX.
license: MIT
---

# Local voice enhance

Everything runs locally, so private or client audio never leaves the machine.

## When it helps and when it doesn't

- **Helps:** background noise (AC, fridge, street, hiss), muddy/boomy voice, takes that are louder or
  quieter than each other.
- **Doesn't:** strong room echo/reverb (stairwells, bathrooms, empty rooms). DeepFilterNet barely
  reduces it. Cloud tools (Adobe Podcast, ElevenLabs Voice Isolator) do better but require
  **uploading** the audio: offer that option and only use it with the owner's explicit OK for that file.

## Steps

1. **Find the voice tracks that are actually used** in the edit, not every file in the folder. Note
   each one's path, its clip volume in the project and its start offset. If the voice only exists
   inside an MP4, extract it to WAV first (`ffmpeg -i in.mp4 -vn -ac 1 -ar 48000 voice.wav`).
2. **Process all takes in one call** so they come out matched:
   ```bash
   scripts/enhance_voice.sh path/to/voice/*.wav
   ```
   - Writes `<name>_enhanced.wav` next to each original (or into `--out DIR`); never touches originals.
   - Uses the system `deep-filter` if installed; otherwise downloads the official DeepFilterNet
     v0.5.6 binary (x86_64 Linux) to a temp dir and deletes it afterwards. Installing it
     system-wide is better; ask before installing anything.
   - `FFMPEG=/path/to/ffmpeg` if ffmpeg is not on PATH. `--target` sets final loudness
     (default −20.5 LUFS, measured in stereo).
3. **Read the table it prints:**
   - `offset_ms` should be within about ±10 ms. Larger means the voice drifted: don't use it, investigate.
   - `I new` should be the same for every take.
4. **Swap them into the project keeping the mix balance:**
   - New clip volume = old clip volume × `factor` (printed per file).
   - Since all takes now have equal loudness you can give them all the same volume (the mean of the new values).
   - Do not move clip start/offset/duration: DeepFilterNet runs with delay compensation, timing is preserved.
   - Leave a short note next to the voice tracks saying they were processed.
5. **Check** the project still builds/renders (run its linter or a short test render).

Report in plain words: what was done, that originals are untouched, and that you measured the result
but did not listen to it (unless you did). Ask the owner to listen. If a take had echo, say it is still
there and offer the cloud option with their approval.

## What the chain does

| Step | Setting | Why |
|---|---|---|
| DeepFilterNet 3 | `-D --pf` | Removes noise; `-D` compensates delay so sync holds, `--pf` deepens attenuation in pauses |
| High-pass | 80 Hz | Removes rumble, mic bumps, traffic |
| EQ | −2 dB @ 250 Hz | Removes the "boxy" small-room sound |
| EQ | +2.5 dB @ 3.8 kHz | Intelligibility, especially under background music |
| Compressor | 3:1, −24 dB threshold | Evens loud and soft syllables |
| Gain + limiter | to `--target`, peak ≈ −1.5 dBFS | All takes equal, no clipping |

If a voice turns harsh or sibilant, lower the 3.8 kHz boost. If pauses sound "robotic", drop `--pf`.
Both live in `CHAIN` / the `deep-filter` line of the script.
