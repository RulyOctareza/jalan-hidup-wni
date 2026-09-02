# Jalan Hidup WNI — Narrative Framework

Dokumen ini mendefinisikan **jalan cerita** simulasi kehidupan: dari tahun lahir,
presiden saat itu, konteks sejarah, fase hidup emosional, titik kritis, sampai
kematian dan legacy.

---

## 1. Filosofi Cerita

Setiap karakter WNI hidup **di dalam sejarah Indonesia yang nyata** (direpresentasi
game, bukan dokumenter). Tahun lahir menentukan:

- Siapa presiden saat lahir
- Era politik & ekonomi yang membentuk childhood
- Teknologi yang tersedia saat remaja
- Krisis nasional yang kamu alami di usia berapa
- Peluang karir yang realistis untuk generasi itu

**Prinsip:** Player tidak "memilih plot" — player **navigasi chaos** lewat pilihan.
Fase hidup berubah dinamis berdasarkan stats, kejadian sejarah, dan keputusan.

---

## 2. Timeline Sejarah → Game Era

| Era ID | Tahun | Presiden | Nuansa Game |
|--------|-------|----------|-------------|
| `orde_lama` | 1945–1965 | Sukarno | Revolusi, idealisme, instabilitas |
| `transisi_65` | 1965–1967 | Sukarno → Suharto | Ketakutan, perubahan drastis |
| `orde_baru_awal` | 1967–1980 | Suharto | Stabilitas, pembangunan, otoriter |
| `orde_baru_puncak` | 1981–1996 | Suharto | Prosperity, korupsi sistemik |
| `krismon` | 1997–1999 | Suharto → Habibie | Collapse, demo mahasiswa, reformasi |
| `reformasi` | 1999–2004 | Gus Dur → Megawati | Demokrasi coba-coba, recovery |
| `sby` | 2004–2014 | SBY | Stabilitas, media sosial awal |
| `jokowi` | 2014–2024 | Jokowi | Infrastruktur, UMKM boom, polarisasi |
| `prabowo` | 2024–2030+ | Prabowo | Era baru (fictionalized future events) |

File data: `assets/content/history/eras.json`, `presidents.json`, `national_events.json`

---

## 3. Birth Year → Opening Story (POV)

Saat character creation, player pilih (atau random) **tahun lahir 1960–2015**.

### Contoh 5 Arc Pembuka

#### A. Lahir 1965 — "Anak Orde Baru"
```
Tahun 1965. Indonesia bergolak. Presiden Sukarno masih di istana,
tapi angin sudah berubah arah. Keluargamu di [provinsi]: [background].
Ayahmu [pekerjaan]. Ibu [peran]. Kamu lahir tanpa tahu bahwa
negara akan berubah selamanya sebelum kamu masuk SD.
```
**Childhood hooks:** pelajaran P4, ekonomi terkendali, TV baru masuk rumah (1980an)

#### B. Lahir 1980 — "Generasi Pembangunan"
```
Tahun 1980. Suharto memimpin Indonesia ke fase pembangunan.
Presiden yang sama sudah 13 tahun berkuasa. Di [kota], hidup terasa
[stabil/miskin]. Orang tuamu berharap kamu jadi PNS atau dokter.
```
**Teen hooks:** Krisis 1997 saat SMA/kuliah — titik kritis generasi ini

#### C. Lahir 1995 — "Anak Reformasi"
```
Tahun 1995. Orde Baru masih kuat, tapi retak sudah terlihat.
Saat kamu berusia 3 tahun, Indonesia dilanda krisis moneter.
Ayah [PHK/tetap kerja]. Keluarga [jadi miskin/tahan banting].
```
**Teen hooks:** internet warnet, musik band lokal, demo & reformasi di TV

#### D. Lahir 2000 — "Millennial Indonesia"
```
Tahun 2000. Gus Dur baru saja lengser. Megawati naik.
Indonesia mencoba demokrasi sungguhan. Kamu tumbuh dengan
TV sinetron dan mulai sekolah saat era SBY — relatif tenang.
```
**Teen hooks:** Facebook, BlackBerry, UTBK, first startup wave

#### E. Lahir 2010 — "Gen Digital Native"
```
Tahun 2010. SBY memimpin. Smartphone mulai masuk Indonesia.
Saat kamu SMP, Jokowi sudah presiden. Saat kamu SMA, COVID-19
mengubah sekolah jadi online. Generasimu hidup di layar.
```
**Teen hooks:** TikTok, ojek online, kuliah online, gig economy

---

## 4. Sistem Fase Hidup (Life Arc Phases)

Fase **bukan linear** — karakter bisa bolak-balik antar fase. Engine
men-track `currentPhase` + `phaseHistory[]`.

### 4.1 Daftar Fase

| Phase ID | Nama | Trigger Masuk | Nuansa UI | Contoh Event |
|----------|------|---------------|-----------|--------------|
| `innocence` | Polos | Usia 0–6 | Warm, soft | Main layangan, jajan es |
| `suffering` | Menderita | happiness<25 OR wealth crisis OR national disaster | Desaturated, rain overlay | PHK massal, sakit parah, ditinggal orang tua |
| `struggling` | Berjuang | stats 25–45, active goals | Orange accent | Kerja 2 job, utang, kuliah sambil kerja |
| `surviving` | Bertahan | stats 35–55, stagnan 3+ tahun | Neutral grey | Gaji pas-pasan, hidup hari demi hari |
| `rising` | Menuju Sukses | upward trend 2+ tahun | Gold gradient | Promosi, bisnis mulai jalan |
| `success` | Sukses | wealth top 20% OR fame OR high status | Bright, confetti | Beli rumah, viral, jadi pejabat |
| `decline` | Turun | fall from success OR scandal OR addiction | Dark red | Bangkrut, cerai, skandal, narkoba |
| `recovery` | Bangkit (Naik) | rising from decline | Sunrise palette | Restart bisnis, rehab, comeback |
| `near_death` | Mau Mati | health<15 OR age>75 OR terminal illness | Fade, slow pulse | ICU, wasiat, minta maaf keluarga |
| `critical` | Titik Kritis | one-time junction events | Full-screen modal | Krismon 98, COVID, putus sekolah, nikah/mundur |

### 4.2 Transisi Fase (State Machine)

```
                    ┌─────────────┐
         ┌─────────►│  SUFFERING  │◄────────┐
         │          └──────┬──────┘         │
         │                 │                │
    national          player choice     health crash
    disaster               │                │
         │          ┌──────▼──────┐         │
         │          │  STRUGGLING │─────────┤
         │          └──────┬──────┘         │
         │                 │                │
         │          ┌──────▼──────┐   ┌─────▼─────┐
         │          │  SURVIVING  │   │  DECLINE  │
         │          └──────┬──────┘   └─────┬─────┘
         │                 │                │
         │          ┌──────▼──────┐   ┌─────▼─────┐
         └──────────│   RISING    │   │ RECOVERY  │
                    └──────┬──────┘   └─────┬─────┘
                           │                │
                    ┌──────▼──────┐         │
                    │   SUCCESS   │─────────┘
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ NEAR_DEATH  │──► DEATH
                    └─────────────┘

         CRITICAL junctions = forced branches anywhere on graph
```

### 4.3 Phase Multipliers (Gameplay)

Saat di fase tertentu, event pool & stat delta berubah:

| Phase | Event Weight | Choice Impact | Random Bad Luck |
|-------|-------------|---------------|-----------------|
| suffering | 70% negative | ×1.5 | ×2.0 |
| struggling | 50% mixed | ×1.2 | ×1.3 |
| surviving | 40% neutral | ×1.0 | ×1.0 |
| rising | 60% positive | ×1.1 | ×0.8 |
| success | 50% positive + risk | ×0.9 | ×1.5 (hubris) |
| decline | 65% negative | ×1.3 | ×1.8 |
| recovery | 55% positive | ×1.4 | ×1.0 |
| near_death | reflective | ×2.0 (legacy) | ×0.5 |

---

## 5. Titik Kritis (Critical Junctions)

Titik kritis = **momentum story** — sekali lewat, tidak bisa undo.
Disimpan di `life.criticalDecisions[]`.

### 5.1 Kategori

1. **Historical** — player usia X saat event nasional
2. **Personal** — nikah, putus sekolah, jual rumah, pindah LN
3. **Moral** — korupsi, crime, selamatkan orang
4. **Financial** — investasi all-in, PHK vs tetap
5. **Health** — operasi risiko, obat mahal vs biaya hidup

### 5.2 Critical Events by Birth Cohort

| Event | Tahun | Usia jika lahir 1980 | Usia jika lahir 1995 | Usia jika lahir 2000 |
|-------|-------|----------------------|----------------------|----------------------|
| Krismon 1998 | 1998 | 18 (SMA/kuliah) | 3 (trauma keluarga) | belum lahir |
| Tsunami Aceh | 2004 | 24 | 9 | 4 |
| Facebook boom | 2008–2012 | 28–32 | 13–17 | 8–12 |
| Jokowi presiden | 2014 | 34 | 19 | 14 |
| COVID-19 | 2020 | 40 | 25 | 20 |
| AI disruption | 2025+ | 45+ | 30+ | 25+ |

Engine: `criticalAge = eventYear - birthYear` → inject event saat player age up.

### 5.3 Contoh Critical Choice — Krismon '98 (usia 17–22)

```
🔴 TITIK KRITIS: Krisis Moneter 1998

Rupiah anjlok. Ayah di-PHK. Tabungan keluarga habis dalam hitungan bulan.
Demonstrasi mahasiswa di jalan. Presiden Suharto mundur.

[A] Drop out kuliah, bantu keluarga jualan
    → wealth stabil, smarts -15, phase: struggling
[B] Tetap kuliah, beasiswa + kerja part-time
    → smarts +10, happiness -20, phase: struggling
[C] Ikut demo (risiko)
    → reputation +20 OR arrest (10%), phase: critical
[D] Migrasi cari kerja (risiko tinggi)
    → random outcome Malaysia/Saudi, phase: rising OR suffering
```

---

## 6. Macro Story Arc — Full Life Template

Setiap hidup idealnya punya **narrative beat** meski RNG berbeda:

```
ACT 1 — ORIGIN (0–12)
  Beat: lahir → keluarga → sekolah dasar → event era childhood
  Phase dominan: innocence → (suffering jika miskin ekstrem)

ACT 2 — FORMATION (13–22)
  Beat: SMP/SMA → identitas → pacar pertama → ujian/lulus
  Phase dominan: struggling / surviving
  Critical: putus sekolah, pilih jurusan, Krismon/COVID generational

ACT 3 — STRUGGLE (23–35)
  Beat: kuliah/kerja → pacaran serius → nikah? → karir awal
  Phase dominan: struggling → rising OR decline
  Critical: CPNS, startup, PHK, nikah, utang

ACT 4 — BUILD (36–50)
  Beat: keluarga → anak → naik jabatan / bisnis / UMKM
  Phase dominan: rising → success OR surviving
  Critical: selingkuh, bangkrut, promosi besar, haji

ACT 5 — PEAK or FALL (51–65)
  Beat: puncak karir ATAU collapse
  Phase dominan: success / decline / recovery
  Critical: pensiun, cerai, skandal, warisan

ACT 6 — TWILIGHT (66–80+)
  Beat: kesehatan → cucu → refleksi → kematian
  Phase dominan: near_death → legacy
  Critical: wasiat, operasi, rekonsiliasi keluarga
```

---

## 7. Presiden sebagai Narrator Frame

Setiap **dekade usia**, game menampilkan "Berita Nasional" singkat:

```
📰 Tahun 2004 — Usiamu 24
Presiden: Susilo Bambang Yudhoyono (baru terpilih)
"Indonesia memasuki era demokrasi stabil. Pilpres pertama langsung.
Di [kota], ekonomi mulai pulih pasca reformasi."
```

Ini memberi **POV sejarah** tanpa player perlu hafal timeline.

Presiden saat **lahir** ditampilkan di opening + achievement "Generasi [Era]".

---

## 8. Ending & Legacy Narrative

Saat mati, game generate **Ringkasan Hidup** berbasis fase yang pernah dialami:

```
═══════════════════════════════════════
        JALAN HIDUP: BUDI SANTOSO
        1980 – 2073 (93 tahun)
═══════════════════════════════════════
Generasi   : Orde Baru → Reformasi → Digital
Presiden saat lahir : Suharto
Fase terpanjang     : Berjuang (23 tahun)
Puncak              : Sukses (owner UMKM, 2019–2035)
Kejatuhan           : Bangkrut saat COVID (2020), bangkit 2023
Titik kritis        : 7 keputusan permanen
Legacy Score        : 847 / 1000
Ribbon              : 🏅 "Pengusaha Tahan Banting"
═══════════════════════════════════════
"Kamu hidup melewati 3 presiden, 1 krisis nasional, dan 2
kebangkrutan. Keluargamu tetap bangga — meski jalanmu never easy."
```

---

## 9. Content Production Checklist

### MVP (50 event + 10 critical)
- [ ] 5 birth year cohorts dengan opening text
- [ ] 10 national events (Krismon, Tsunami, COVID, dll.)
- [ ] 8 life phases dengan UI state
- [ ] 10 critical junction templates
- [ ] President/era lookup table 1960–2024

### v1 (150 event + 30 critical)
- [ ] All 33 provinsi flavor text
- [ ] Generational tech events (warnet, BBM, ojek, TikTok)
- [ ] Full act structure 6 acts
- [ ] Legacy ribbon 25+

---

## 10. Engine Implementation Notes

```
LifeSimulator.ageUp():
  1. currentYear = birthYear + age
  2. resolve president + era for currentYear
  3. check national_events where year == currentYear
  4. check critical_junctions where age == player.age
  5. roll random events filtered by currentPhase
  6. recalculate phase from stats + trends
  7. emit narrative beat if act transition
```

File terkait:
- `assets/content/history/*.json`
- `assets/content/game/life_phases.json`
- `assets/content/game/critical_junctions.json`
- `lib/game_engine/phase_resolver.dart` (TODO)
- `lib/game_engine/history_context.dart` (TODO)
