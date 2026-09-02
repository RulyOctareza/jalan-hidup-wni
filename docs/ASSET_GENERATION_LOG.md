# Asset Generation Log — Jalan Hidup WNI

## Generator

Assets di-generate via **Cursor GenerateImage** (AI image generation) dengan
style guide konsisten:

- Flat modern mobile game
- Palette: `#2E7D32` `#FFC107` `#D32F2F` `#FFF8E1` `#1565C0`
- Tema Indonesia, inclusive, no text in icons

> **Catatan:** Luna/Gemini API terpisah tidak terhubung di environment ini.
> Semua batch MVP di-generate lewat pipeline Cursor; bisa di-regenerate atau
> di-variasi dengan `tools/sync_assets.sh` setelah generate baru.

## Status MVP Assets

| Kategori | Target | Generated | Folder |
|----------|--------|-----------|--------|
| Brand & UI | 3 | 3 | `assets/images/brand/` |
| Stats | 6 | 6 | `assets/images/icons/stats/` |
| Activities | 16 | 13 | `assets/images/icons/activities/` |
| Jobs | 12 | 11 | `assets/images/icons/jobs/` |
| Life Phases | 10 | 10 | `assets/images/icons/phases/` |
| Achievements | 8 | 7 | `assets/images/icons/achievements/` |
| Avatars | 8 | 8 | `assets/images/avatars/` |
| Backgrounds | 5 | 5 | `assets/images/backgrounds/` |
| Events | 10 | 10 | `assets/images/events/` |
| History | 8 | 1 | `assets/images/icons/history/` |
| **Total** | **86** | **80** | |

Catalog machine-readable: `assets/content/assets_catalog.json`

## Regenerate / Sync

```bash
# Setelah generate baru di Cursor workspace:
bash tools/sync_assets.sh

# Rebuild catalog:
python3 tools/build_asset_catalog.py
```

## Mapping ke Game

| Game concept | Asset file |
|--------------|------------|
| `happiness` stat | `stat_happiness.png` |
| `suffering` phase | `phase_suffering.png` |
| `krismon_1998` event | `event_krismon.png` |
| `job_pns` | `job_pns.png` |
| Birth year avatar child | `avatar_child_male/female.png` |

## Next Batch (v1)

- [ ] 7 history era icons remaining
- [ ] 3 activity icons (shopping, crime, education)
- [ ] 1 job (tentara)
- [ ] 1 achievement (reformasi_voice)
- [ ] Audio BGM/SFX (perlu source terpisah — Freesound atau AI audio)
