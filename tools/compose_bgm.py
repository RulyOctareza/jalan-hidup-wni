#!/usr/bin/env python3
"""
Jalan Hidup WNI — Procedural BGM Composer

Design intent (NOT generic AI slop):
- Pelog barang pentatonic as melodic foundation (subtle Nusantara identity)
- Lo-fi life-sim warmth like BitLife/Stardew but distinctly Indonesian dusk
- Sparse metallophone texture (gamelan hint, not caricature)
- Kendang-inspired soft pulse at low mix
- Phase-specific emotional arcs tied to life_phases.json musicMood

Output: assets/audio/bgm/*.mp3, assets/audio/sfx/*.mp3
Requires: numpy, scipy, ffmpeg
"""

from __future__ import annotations

import math
import subprocess
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from scipy.io import wavfile
from scipy.signal import butter, lfilter

SR = 44100
ROOT = Path(__file__).resolve().parents[1]
BGM_DIR = ROOT / "assets" / "audio" / "bgm"
SFX_DIR = ROOT / "audio" / "sfx" if False else ROOT / "assets" / "audio" / "sfx"

# Pelog barang approx (C4 base) — authentic enough, not cartoon
PELOG = {
    "C": 261.63,
    "D": 293.66,
    "E": 329.63,
    "G": 392.00,
    "A": 440.00,
}

PELOG_MOTIF_MENU = ["C", "E", "G", "A", "G", "E", "D", "C"]
PELOG_MOTIF_LIFE = ["E", "G", "A", "G", "E", "D", "C", "D"]
PELOG_MOTIF_STRUGGLE = ["D", "E", "G", "E", "D", "C"]
PELOG_MOTIF_SORROW = ["A", "G", "E", "D", "C"]
PELOG_MOTIF_HOPE = ["C", "D", "E", "G", "A", "G", "E"]
PELOG_MOTIF_LEGACY = ["E", "D", "C", "G", "E", "D", "C"]


@dataclass
class TrackSpec:
    name: str
    bpm: float
    bars: int
    motif: list[str]
    mood: str  # menu | warm | struggle | sorrow | hope | legacy


def _t(length: int) -> np.ndarray:
    return np.arange(length) / SR


def adsr(
    n: int,
    attack: float = 0.02,
    decay: float = 0.1,
    sustain: float = 0.6,
    release: float = 0.3,
) -> np.ndarray:
    a = int(attack * SR)
    d = int(decay * SR)
    r = int(release * SR)
    s = max(0, n - a - d - r)
    env = np.concatenate(
        [
            np.linspace(0, 1, max(1, a)),
            np.linspace(1, sustain, max(1, d)),
            np.full(max(0, s), sustain),
            np.linspace(sustain, 0, max(1, r)),
        ]
    )
    if len(env) < n:
        env = np.pad(env, (0, n - len(env)))
    return env[:n]


def sine(freq: float, dur: float, amp: float = 1.0) -> np.ndarray:
    n = int(dur * SR)
    return amp * np.sin(2 * math.pi * freq * _t(n))


def pluck(freq: float, dur: float, amp: float = 0.35) -> np.ndarray:
    """Karplus-Strong inspired soft pluck — guitar/kacapi feel."""
    n = int(dur * SR)
    if n < 2:
        return np.zeros(1)
    buf = np.random.uniform(-1, 1, n) * 0.5
    delay = max(2, int(SR / freq))
    out = np.zeros(n)
    for i in range(n):
        out[i] = buf[i]
        if i >= delay:
            out[i] += 0.96 * out[i - delay]
    env = adsr(n, 0.005, 0.15, 0.2, dur * 0.7)
    return (out * env * amp)[:n]


def metallophone(freq: float, dur: float, amp: float = 0.12) -> np.ndarray:
    """Sparse gamelan bell — inharmonic partials, short decay."""
    n = int(dur * SR)
    t = _t(n)
    partials = [1.0, 2.1, 3.05, 4.2]
    amps = [1.0, 0.35, 0.2, 0.08]
    wave = sum(a * np.sin(2 * math.pi * freq * p * t) for p, a in zip(partials, amps))
    env = adsr(n, 0.001, 0.4, 0.05, 1.2)
    return wave * env * amp


def soft_pad(freq: float, dur: float, amp: float = 0.08) -> np.ndarray:
    n = int(dur * SR)
    t = _t(n)
    detune = [0.995, 1.0, 1.005]
    wave = sum(np.sin(2 * math.pi * freq * d * t) for d in detune) / 3
    env = adsr(n, 0.8, 0.5, 0.7, 1.5)
    return wave * env * amp


def kendang_pulse(bpm: float, total_sec: float, intensity: float = 0.06) -> np.ndarray:
    """Soft low drum pulse — not aggressive."""
    n = int(total_sec * SR)
    out = np.zeros(n)
    beat = 60.0 / bpm
    for i in range(int(total_sec / beat) + 1):
        pos = int(i * beat * SR)
        if pos >= n:
            break
        # Alternate low/high (gendang pattern simplified)
        freq = 90 if i % 2 == 0 else 130
        hit_len = int(0.08 * SR)
        if pos + hit_len > n:
            continue
        t = _t(hit_len)
        hit = np.sin(2 * math.pi * freq * t) * np.exp(-t * 35)
        accent = 1.0 if i % 4 == 0 else 0.55
        out[pos : pos + hit_len] += hit * intensity * accent
    return out


def lowpass(signal: np.ndarray, cutoff: float = 4000) -> np.ndarray:
    nyq = SR / 2
    b, a = butter(2, cutoff / nyq, btype="low")
    return lfilter(b, a, signal)


def simple_reverb(signal: np.ndarray, mix: float = 0.15) -> np.ndarray:
  delays = [int(SR * d) for d in (0.029, 0.037, 0.053, 0.067)]
  wet = np.zeros_like(signal)
  for d in delays:
    if d < len(signal):
      wet[d:] += signal[:-d] * 0.25
  return signal * (1 - mix) + wet * mix


def normalize(signal: np.ndarray, peak: float = 0.92) -> np.ndarray:
    m = np.max(np.abs(signal))
    if m < 1e-9:
        return signal
    return signal / m * peak


def compose_track(spec: TrackSpec) -> np.ndarray:
    beat = 60.0 / spec.bpm
    bar_dur = beat * 4
    total_sec = spec.bars * bar_dur
    n = int(total_sec * SR)
    mix = np.zeros(n)

    mood = spec.mood

    # --- Pad layer (root movement every 2 bars) ---
    roots = spec.motif[::2] if len(spec.motif) > 2 else spec.motif
    for bar in range(spec.bars):
        root_note = roots[bar % len(roots)]
        freq = PELOG[root_note]
        start = int(bar * bar_dur * SR)
        seg_len = int(bar_dur * 2 * SR) if bar % 2 == 0 else int(bar_dur * SR)
        seg_len = min(seg_len, n - start)
        if seg_len <= 0:
            continue
        pad_amp = {
            "menu": 0.07,
            "warm": 0.06,
            "struggle": 0.05,
            "sorrow": 0.04,
            "hope": 0.07,
            "legacy": 0.05,
        }.get(mood, 0.06)
        pad = soft_pad(freq, seg_len / SR, pad_amp)
        mix[start : start + len(pad)] += pad

    # --- Melody plucks ---
    note_dur = beat * 1.5 if mood != "legacy" else beat * 2.5
    melody_amp = {
        "menu": 0.28,
        "warm": 0.22,
        "struggle": 0.25,
        "sorrow": 0.18,
        "hope": 0.26,
        "legacy": 0.15,
    }[mood]

  # Place melody notes across bars
    step = 0
    for bar in range(spec.bars):
        for beat_i in range(2 if mood in ("sorrow", "legacy") else 4):
            if step >= len(spec.motif) * 3:
                step = 0
            note = spec.motif[step % len(spec.motif)]
            step += 1
            t0 = bar * bar_dur + beat_i * beat
            if mood == "struggle" and beat_i % 2 == 1:
                continue  # sparser, determined
            pos = int(t0 * SR)
            pl = pluck(PELOG[note], note_dur, melody_amp)
            end = min(pos + len(pl), n)
            mix[pos:end] += pl[: end - pos]

    # --- Sparse metallophone (gamelan accent) ---
    if mood in ("menu", "warm", "hope"):
        bell_interval = bar_dur * 2
        for i in range(int(total_sec / bell_interval)):
            t0 = i * bell_interval + beat
            note = spec.motif[i % len(spec.motif)]
            pos = int(t0 * SR)
            bell = metallophone(PELOG[note] * 2, 1.8, 0.1)
            end = min(pos + len(bell), n)
            mix[pos:end] += bell[: end - pos]

    # --- Bass root ---
    bass_amp = 0.12 if mood == "struggle" else 0.08
    for bar in range(spec.bars):
        note = spec.motif[bar % len(spec.motif)]
        freq = PELOG[note] / 2
        start = int(bar * bar_dur * SR)
        blen = int(bar_dur * SR)
        t = _t(blen)
        bass = np.sin(2 * math.pi * freq * t) * adsr(blen, 0.05, 0.2, 0.5, 0.2)
        mix[start : start + blen] += bass * bass_amp

    # --- Rhythm ---
    pulse_intensity = {
        "menu": 0.04,
        "warm": 0.035,
        "struggle": 0.07,
        "sorrow": 0.02,
        "hope": 0.05,
        "legacy": 0.025,
    }[mood]
    if mood != "legacy":
        mix += kendang_pulse(spec.bpm, total_sec, pulse_intensity)

    # --- Mood processing ---
    mix = lowpass(mix, 4500 if mood != "sorrow" else 2800)
    mix = simple_reverb(mix, 0.18 if mood in ("menu", "legacy", "sorrow") else 0.12)

    if mood == "sorrow":
        # Bit of room tone / rain bed
        noise = np.random.randn(n) * 0.008
        mix += lowpass(noise, 800)

    if mood == "legacy":
        mix *= np.linspace(1.0, 0.85, n)  # gentle fade feel within loop

    # Seamless loop: crossfade last 0.5s with first 0.5s
    xf = int(0.5 * SR)
    if xf > 0 and n > xf * 2:
        fade_out = np.linspace(1, 0, xf)
        fade_in = np.linspace(0, 1, xf)
        mix[-xf:] *= fade_out
        mix[:xf] *= fade_in
        mix[:xf] += mix[-xf:] * fade_in

    return normalize(mix)


def compose_sfx_click() -> np.ndarray:
    n = int(0.08 * SR)
    t = _t(n)
    return normalize(np.sin(2 * math.pi * 800 * t) * np.exp(-t * 40) * 0.4)


def compose_sfx_age_up() -> np.ndarray:
    notes = [PELOG["C"], PELOG["E"], PELOG["G"], PELOG["A"]]
    mix = np.zeros(int(0.6 * SR))
    offset = 0
    for f in notes:
        pl = pluck(f, 0.15, 0.35)
        end = offset + len(pl)
        if end > len(mix):
            mix = np.pad(mix, (0, end - len(mix)))
        mix[offset:end] += pl
        offset += int(0.1 * SR)
    return normalize(mix)


def compose_sfx_positive() -> np.ndarray:
    a = metallophone(PELOG["A"] * 2, 0.8, 0.35)
    b = pluck(PELOG["E"], 0.2, 0.2)
    n = max(len(a), len(b))
    a = np.pad(a, (0, n - len(a)))
    b = np.pad(b, (0, n - len(b)))
    return normalize(a + b)


def compose_sfx_negative() -> np.ndarray:
    n = int(0.35 * SR)
    t = _t(n)
    return normalize(np.sin(2 * math.pi * 110 * t) * np.exp(-t * 8) * 0.5)


def compose_sfx_event() -> np.ndarray:
    a = pluck(PELOG["G"], 0.12, 0.25)
    b = metallophone(PELOG["D"] * 2, 0.5, 0.2)
    n = max(len(a), len(b))
    a = np.pad(a, (0, n - len(a)))
    b = np.pad(b, (0, n - len(b)))
    return normalize(a + b)


def wav_to_mp3(wav_path: Path, mp3_path: Path) -> None:
    subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-i",
            str(wav_path),
            "-codec:a",
            "libmp3lame",
            "-b:a",
            "192k",
            str(mp3_path),
        ],
        check=True,
        capture_output=True,
    )
    wav_path.unlink(missing_ok=True)


def save_track(signal: np.ndarray, out_mp3: Path) -> None:
    wav_tmp = out_mp3.with_suffix(".wav")
    wavfile.write(wav_tmp, SR, (signal * 32767).astype(np.int16))
    wav_to_mp3(wav_tmp, out_mp3)
    print(f"  ✓ {out_mp3.name} ({out_mp3.stat().st_size // 1024} KB)")


def main() -> None:
    BGM_DIR.mkdir(parents=True, exist_ok=True)
    SFX_DIR.mkdir(parents=True, exist_ok=True)

    tracks = [
        TrackSpec("bgm_menu", 62, 8, PELOG_MOTIF_MENU, "menu"),
        TrackSpec("bgm_life_warm", 72, 8, PELOG_MOTIF_LIFE, "warm"),
        TrackSpec("bgm_life_struggle", 84, 8, PELOG_MOTIF_STRUGGLE, "struggle"),
        TrackSpec("bgm_life_sorrow", 54, 8, PELOG_MOTIF_SORROW, "sorrow"),
        TrackSpec("bgm_life_hope", 76, 8, PELOG_MOTIF_HOPE, "hope"),
        TrackSpec("bgm_life_legacy", 50, 8, PELOG_MOTIF_LEGACY, "legacy"),
    ]

    print("Composing BGM — Jalan Hidup WNI")
    print("Style: Pelog · lo-fi life-sim · Nusantara dusk\n")

    for spec in tracks:
        audio = compose_track(spec)
        save_track(audio, BGM_DIR / f"{spec.name}.mp3")

    print("\nComposing SFX...")
    sfx = {
        "sfx_tap": compose_sfx_click(),
        "sfx_age_up": compose_sfx_age_up(),
        "sfx_positive": compose_sfx_positive(),
        "sfx_negative": compose_sfx_negative(),
        "sfx_event": compose_sfx_event(),
    }
    for name, audio in sfx.items():
        save_track(audio, SFX_DIR / f"{name}.mp3")

    print(f"\nDone → {BGM_DIR} & {SFX_DIR}")


if __name__ == "__main__":
    main()
