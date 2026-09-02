#!/usr/bin/env python3
"""Enrich historical_articles.json with national event data and fallbacks."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARTICLES = ROOT / "assets/content/history/historical_articles.json"
EVENTS = ROOT / "assets/content/history/national_events.json"

FALLBACK_IMAGES = {
    "krismon_1998": "assets/images/events/event_krismon.png",
    "reformasi_1998": "assets/images/events/event_reformasi.png",
    "covid_2020": "assets/images/events/event_covid.png",
    "bbm_subsidy_cut": "assets/images/events/event_bbm.png",
}

EXTRA = {
    "utbk_reform": {
        "year": 2019,
        "title": "Reformasi UTBK/SBMPTN",
        "category": "pendidikan",
        "summary": (
            "UTBK (Ujian Tulis Berbasis Komputer) menggantikan SNMPTN/SBMPTN "
            "sebagai pintu masuk utama ke perguruan tinggi negeri. Sistem makin "
            "kompetitif dan menekan siswa SMA."
        ),
        "body": (
            "Sejak 2019, calon mahasiswa harus menjalani UTBK untuk melamar "
            "PTN favorit. Skor UTBK, rapor, dan prestasi non-akademik "
            "menentukan kelulusan. Bagi generasi muda, persiapan UTBK "
            "menjadi fase paling menegangkan sebelum dewasa — bimbel, try out, "
            "dan tekanan orang tua memenuhi kehidupan siswa kelas 12."
        ),
    },
    "ai_disruption": {
        "year": 2025,
        "title": "Revolusi AI",
        "category": "teknologi",
        "summary": (
            "Kecerdasan buatan (AI) mulai mengubah dunia kerja. Pekerjaan "
            "entry-level di kantor, desain, dan customer service terancam "
            "otomatisasi."
        ),
        "body": (
            "Generasi muda Indonesia di tahun 2025 hidup di tengah ledakan "
            "alat AI seperti ChatGPT, Copilot, dan otomatisasi industri. "
            "Perusahaan mulai mengurangi rekrutmen junior. Di sisi lain, "
            "peluang baru muncul bagi yang mahir prompt engineering, data, "
            "dan kreativitas berbasis AI. Adaptasi jadi kunci bertahan."
        ),
    },
}


def era(year: int) -> str:
    if year < 1950:
        return "Indonesia baru merdeka"
    if year < 1967:
        return "Era Orde Lama / Sukarno"
    if year < 1980:
        return "Awal Orde Baru"
    if year < 1998:
        return "Orde Baru puncak"
    if year < 2004:
        return "Reformasi & transisi demokrasi"
    if year < 2014:
        return "Era demokrasi stabil"
    if year < 2024:
        return "Era digital & infrastruktur"
    return "Indonesia masa depan"


def main() -> None:
    articles = json.loads(ARTICLES.read_text(encoding="utf-8"))
    events = {e["id"]: e for e in json.loads(EVENTS.read_text(encoding="utf-8"))}
    by_id = {a["id"]: a for a in articles}

    for eid, event in events.items():
        if eid not in by_id:
            extra = EXTRA.get(eid, {})
            by_id[eid] = {
                "id": eid,
                "year": event["year"],
                "title": event["title"],
                "category": extra.get("category", "politik"),
                "context": (
                    f"Tahun {event['year']}. {era(event['year'])}. "
                    f"Peristiwa ini membentuk kehidupan jutaan WNI."
                ),
                "summary": extra.get("summary", event["description"]),
                "body": extra.get("body", event["description"]),
                "imageAsset": event.get("fallbackImage")
                or FALLBACK_IMAGES.get(eid),
                "wikiUrl": None,
                "source": "Jalan Hidup WNI",
                "license": "Konten edukatif",
            }
            continue

        art = by_id[eid]
        placeholder = art.get("body", "").startswith("Artikel sedang dimuat")
        if placeholder:
            art["summary"] = event["description"]
            art["body"] = (
                f"{event['description']}\n\n"
                f"Sebagai WNI di tahun {event['year']}, peristiwa "
                f"{event['title']} terasa lewat berita, harga barang, "
                f"sekolah, dan lingkungan sekitar — bukan hanya di ibu kota."
            )
        if not art.get("imageAsset"):
            art["imageAsset"] = event.get("fallbackImage") or FALLBACK_IMAGES.get(
                eid
            )

    merged = sorted(by_id.values(), key=lambda a: a["year"])
    ARTICLES.write_text(
        json.dumps(merged, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"✓ Enriched {len(merged)} articles → {ARTICLES}")


if __name__ == "__main__":
    main()
