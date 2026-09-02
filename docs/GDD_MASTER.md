# GDD Master — Jalan Hidup WNI

## Ringkasan

| Item | Value |
|------|-------|
| Nama | Jalan Hidup WNI |
| Genre | Life Simulation (text + choices) |
| Platform | Android, iOS |
| Bahasa | Indonesia |
| Referensi | BitLife, BitLife Indonesia mods |
| USP | Sejarah Indonesia nyata + fase emosional hidup |

## Core Stats

- **Kebahagiaan** (happiness) 0–100
- **Kesehatan** (health) 0–100
- **Kecerdasan** (smarts) 0–100
- **Penampilan** (looks) 0–100
- **Reputasi** (reputation) 0–100 — v1
- **Kekayaan** (wealth) Rupiah — terpisah

## Loop Utama

1. Character creation (tahun lahir, provinsi, gender, background)
2. Opening narrative (presiden, era, keluarga)
3. Life screen: stats + usia + fase + berita nasional
4. Age Up (+1 tahun)
5. Event resolver (nasional → kritis → random by phase)
6. Activity menu (sekolah, kerja, relasi, kesehatan)
7. Death → Legacy summary

## MVP Scope

- Tahun lahir: 1975–2010
- 5 birth cohorts
- 10 national events
- 10 critical junctions
- 8 life phases (+ innocence, critical)
- 50 random events
- 10 pekerjaan dasar
- Save 1 slot

## Roadmap

Lihat `NARRATIVE_FRAMEWORK.md` untuk detail fase & cerita.

Phase 1 (MVP): engine + content JSON + placeholder UI  
Phase 2 (v1): kuliah, nikah, generasi, 150 event, assets final  
Phase 3 (v2): kriminal, politik, celebrity, cloud save
