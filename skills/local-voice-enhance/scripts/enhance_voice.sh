#!/usr/bin/env bash
# Clean spoken voice locally: DeepFilterNet (noise) + EQ + compression + matched loudness.
# Usage: enhance_voice.sh [--target LUFS] [--suffix _enhanced] [--out DIR] voice1.wav [voice2.wav ...]
# Writes <name><suffix>.wav (16-bit PCM, 48 kHz, stereo) next to the original or in --out.
# Never overwrites the original. Prints, per file, loudness before/after, the factor that
# keeps the mix balance, and the offset of the first word (sync check).
set -euo pipefail

TARGET=-20.5     # integrated LUFS, measured in stereo
SUFFIX=_enhanced
OUT=""
FILES=()
while (($#)); do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --suffix) SUFFIX="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    -h|--help) sed -n 2,6p "$0"; exit 0 ;;
    *) FILES+=("$1"); shift ;;
  esac
done
((${#FILES[@]})) || { echo "Need at least one voice file" >&2; exit 2; }

FF="${FFMPEG:-$(command -v ffmpeg || true)}"
[[ -x "$FF" ]] || { echo "ffmpeg not found (set FFMPEG=/path/to/ffmpeg)" >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/enhance-voice.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# DeepFilterNet: system binary first; otherwise the pinned official release in a temp dir.
DF="$(command -v deep-filter || true)"
if [[ -z "$DF" ]]; then
  [[ "$(uname -sm)" == "Linux x86_64" ]] || { echo "Install deep-filter (DeepFilterNet) for this platform" >&2; exit 2; }
  echo "deep-filter not installed; downloading official v0.5.6 binary to a temp dir" >&2
  mkdir -p "$WORK/dl"
  curl -fsSL -o "$WORK/dl/deep-filter" \
    https://github.com/Rikorose/DeepFilterNet/releases/download/v0.5.6/deep-filter-0.5.6-x86_64-unknown-linux-musl
  chmod +x "$WORK/dl/deep-filter"
  DF="$WORK/dl/deep-filter"
fi

# Finish: no rumble (<80 Hz), less "box" (250 Hz), more intelligibility (3.8 kHz), gentle compression.
CHAIN="highpass=f=80,equalizer=f=250:t=q:w=1.2:g=-2,equalizer=f=3800:t=q:w=1.0:g=2.5,acompressor=threshold=-24dB:ratio=3:attack=8:release=120:makeup=1"
STEREO="pan=stereo|c0=c0|c1=c0"

lufs() { "$FF" -hide_banner -nostats -i "$1" -af "${2:+$2,}ebur128" -f null - 2>&1 | awk '/^ +I:/{v=$2} END{print v}'; }
onset() { "$FF" -hide_banner -nostats -i "$1" -af "highpass=f=200,silencedetect=n=-38dB:d=0.12" -f null - 2>&1 \
  | awk '/silence_end/{print $5; exit}'; }

mkdir -p "$WORK/in" "$WORK/df" "$WORK/pol"
printf '%-40s %9s %9s %8s %10s\n' file "I before" "I new" factor "offset_ms"
for f in "${FILES[@]}"; do
  base="$(basename "${f%.*}")"
  dest="${OUT:-$(dirname "$f")}/${base}${SUFFIX}.wav"
  [[ "$dest" -ef "$f" ]] && { echo "Destination would be the original: $f" >&2; exit 2; }

  "$FF" -hide_banner -loglevel error -y -i "$f" -ac 1 -ar 48000 "$WORK/in/$base.wav"
  "$DF" -D --pf -o "$WORK/df" "$WORK/in/$base.wav" >/dev/null 2>&1
  "$FF" -hide_banner -loglevel error -y -i "$WORK/df/$base.wav" -af "$CHAIN" -c:a pcm_s24le "$WORK/pol/$base.wav"

  i_pol="$(lufs "$WORK/pol/$base.wav" "$STEREO")"
  gain="$(python3 -c "print(round($TARGET - ($i_pol), 2))")"
  mkdir -p "$(dirname "$dest")"
  "$FF" -hide_banner -loglevel error -y -i "$WORK/pol/$base.wav" \
    -af "volume=${gain}dB,alimiter=limit=0.84:level=false,$STEREO" -ar 48000 -c:a pcm_s16le "$dest"

  i_orig="$(lufs "$f")"; i_new="$(lufs "$dest")"
  factor="$(python3 -c "print(round(10**(($i_orig - $i_new)/20), 3))")"
  t0="$(onset "$f")"; t1="$(onset "$dest")"
  offset="$(python3 -c "print(round(((${t1:-0}) - (${t0:-0}))*1000))")"
  printf '%-40s %9s %9s %8s %10s\n' "$(basename "$dest")" "$i_orig" "$i_new" "$factor" "$offset"
done
echo "factor = multiply the original clip's volume in the mix by this to keep the balance." >&2
