# Audio Design — Jalan Hidup WNI

## Philosophy (bukan AI slop)

Referensi mood, bukan copy:
- **BitLife** — loop pendek, tidak mengganggu, UI-first
- **Stardew Valley** — warmth & nostalgia tanpa epic orchestra
- **Indonesia** — pelog barang (bukan gamelan kliché), kendang lembut, senja Nusantara

Palette visual → audio:
| Visual | Audio |
|--------|-------|
| Hijau `#2E7D32` | Pad hangat, stabil |
| Emas `#FFC107` | Metallophone sparse, highlight |
| Krem `#FFF8E1` | Lo-fi softness, low harshness |
| Merah `#D32F2F` | Minor phrases, sorrow track |

## Tracks

| File | BPM | Mood | Dipakai di |
|------|-----|------|------------|
| `bgm_menu.mp3` | 62 | Senja, contemplative | Splash, Home |
| `bgm_life_warm.mp3` | 72 | Hangat, nostalgia | innocence, surviving |
| `bgm_life_struggle.mp3` | 84 | Determined | struggling, critical |
| `bgm_life_sorrow.mp3` | 54 | Melancholy | suffering, decline |
| `bgm_life_hope.mp3` | 76 | Hopeful | rising, recovery, success |
| `bgm_life_legacy.mp3` | 50 | Reflective | near_death, death screen |

## SFX

| File | Trigger |
|------|---------|
| `sfx_tap.mp3` | Button tap |
| `sfx_age_up.mp3` | +1 Tahun |
| `sfx_positive.mp3` | Choice positif |
| `sfx_negative.mp3` | Choice negatif |
| `sfx_event.mp3` | Event modal muncul |

## Regenerate

```bash
python3 tools/compose_bgm.py
```

Composer: procedural numpy/scipy — pelog pentatonic, Karplus-Strong pluck,
metallophone partials, kendang pulse, seamless loop crossfade.
