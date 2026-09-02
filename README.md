# Jalan Hidup WNI

Simulasi kehidupan ala BitLife — **versi Indonesia**. Hidup dari lahir sampai mati,
melewati sejarah nyata: presiden, krisis nasional, fase menderita → sukses → jatuh → bangkit.

## Lokasi Project

```
/Volumes/DevSSD/DevProjects/jalan-hidup-wni
```

## Tech Stack

- Flutter (Android + iOS)
- Flat modern UI
- Content-driven JSON (events, history, phases)

## Dokumentasi Desain

| Dokumen | Isi |
|---------|-----|
| [NARRATIVE_FRAMEWORK.md](docs/NARRATIVE_FRAMEWORK.md) | Jalan cerita, fase hidup, titik kritis, arc 6 act |
| [GDD_MASTER.md](docs/GDD_MASTER.md) | Game design document lengkap |

## Content Assets

```
assets/content/
├── history/
│   ├── presidents.json      # Presiden 1945–2034
│   ├── eras.json            # Orde Lama → Era Baru
│   └── national_events.json # Krismon, COVID, Tsunami, dll.
└── game/
    ├── life_phases.json     # 10 fase emosional
    ├── critical_junctions.json  # Titik kritis permanen
    └── birth_cohorts.json   # Generasi 1960–2015
```

## Run

```bash
cd /Volumes/DevSSD/DevProjects/jalan-hidup-wni
flutter run
```

## Status

- [x] Project scaffold
- [x] Narrative framework & content JSON (MVP)
- [x] **74+ AI-generated visual assets** (icons, avatars, backgrounds, events)
- [x] Asset catalog & sync tools
- [ ] Game engine (phase resolver, history context)
- [ ] Character creation UI
- [ ] Life loop screen
