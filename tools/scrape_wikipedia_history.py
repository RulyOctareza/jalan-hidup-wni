#!/usr/bin/env python3
"""
Scrape Indonesian history articles from Wikipedia (id) for Jalan Hidup WNI.
Fetches title, summary, full extract, thumbnail URL, and downloads images locally.

Usage: python3 tools/scrape_wikipedia_history.py
"""

from __future__ import annotations

import json
import re
import ssl
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_JSON = ROOT / "assets" / "content" / "history" / "historical_articles.json"
IMG_DIR = ROOT / "assets" / "images" / "history" / "events"

# event_id -> Wikipedia page title (Bahasa Indonesia)
PAGES: dict[str, dict] = {
    "proklamasi_1945": {
        "year": 1945,
        "wiki": "Proklamasi_Kemerdekaan_Indonesia",
        "category": "kemerdekaan",
        "title": "Proklamasi Kemerdekaan Indonesia",
    },
    "konferensi_meja_bundar": {
        "year": 1949,
        "wiki": "Konferensi_Meja_Bundar",
        "category": "politik",
        "title": "Konferensi Meja Bundar",
    },
    "konfrontasi_malaysia": {
        "year": 1963,
        "wiki": "Konfrontasi_Indonesia–Malaysia",
        "category": "politik",
        "title": "Konfrontasi Indonesia–Malaysia",
    },
    "g30s_1965": {
        "year": 1965,
        "wiki": "Gerakan_30_September",
        "category": "politik",
        "title": "Peristiwa 30 September 1965",
    },
    "orde_baru": {
        "year": 1967,
        "wiki": "Orde_Baru",
        "category": "politik",
        "title": "Era Orde Baru",
    },
    "invasi_timtim": {
        "year": 1975,
        "wiki": "Operasi_Seroja",
        "category": "militer",
        "title": "Integrasi Timor Timur",
    },
    "krismon_1998": {
        "year": 1998,
        "wiki": "Krisis_Keuangan_Asia_1997",
        "category": "ekonomi",
        "title": "Krisis Moneter 1998",
    },
    "reformasi_1998": {
        "year": 1998,
        "wiki": "Reformasi_1998",
        "category": "politik",
        "title": "Reformasi 1998",
    },
    "fall_suharto": {
        "year": 1998,
        "wiki": "Lengsernya_Soeharto",
        "category": "politik",
        "title": "Lengsernya Soeharto",
    },
    "bom_bali_2002": {
        "year": 2002,
        "wiki": "Pengeboman_Bali_2002",
        "category": "bencana",
        "title": "Pengeboman Bali 2002",
    },
    "tsunami_2004": {
        "year": 2004,
        "wiki": "Tsunami_Samudra_Hindia_2004",
        "category": "bencana",
        "title": "Tsunami Aceh 2004",
    },
    "sby_elected": {
        "year": 2004,
        "wiki": "Pemilihan_umum_Presiden_Indonesia_2004",
        "category": "politik",
        "title": "Pemilu Presiden 2004 (SBY)",
    },
    "facebook_boom": {
        "year": 2008,
        "wiki": "Facebook",
        "category": "teknologi",
        "title": "Era Media Sosial di Indonesia",
    },
    "jokowi_elected": {
        "year": 2014,
        "wiki": "Pemilihan_umum_Presiden_Indonesia_2014",
        "category": "politik",
        "title": "Jokowi Terpilih Presiden 2014",
    },
    "ojek_online_boom": {
        "year": 2015,
        "wiki": "Gojek",
        "category": "ekonomi",
        "title": "Revolusi Ojek Online",
    },
    "covid_2020": {
        "year": 2020,
        "wiki": "Pandemi_COVID-19_di_Indonesia",
        "category": "bencana",
        "title": "Pandemi COVID-19 di Indonesia",
    },
    "bbm_subsidy_cut": {
        "year": 2022,
        "wiki": "Subsidi_bahan_bakar_minyak_Indonesia",
        "category": "ekonomi",
        "title": "Kenaikan Harga BBM 2022",
    },
    "merdeka_belajar": {
        "year": 2020,
        "wiki": "Merdeka_Belajar",
        "category": "pendidikan",
        "title": "Merdeka Belajar & Pendidikan Digital",
    },
    "pemilu_2024": {
        "year": 2024,
        "wiki": "Pemilihan_umum_Indonesia_2024",
        "category": "politik",
        "title": "Pemilu 2024",
    },
}

CTX = ssl.create_default_context()
UA = "JalanHidupWNI/1.0 (educational game; contact: local)"


def fetch_json(url: str, retries: int = 4) -> dict:
    last_err: Exception | None = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, context=CTX, timeout=30) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except Exception as e:
            last_err = e
            if "429" in str(e) and attempt < retries - 1:
                wait = 5 * (attempt + 1)
                print(f"  ⏳ rate limited, wait {wait}s...")
                time.sleep(wait)
                continue
            raise
    raise last_err  # type: ignore[misc]


def fetch_bytes(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, context=CTX, timeout=60) as resp:
        return resp.read()


def clean_html(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def fetch_article(page_title: str) -> dict:
    encoded = urllib.parse.quote(page_title, safe="")
    summary_url = (
        f"https://id.wikipedia.org/api/rest_v1/page/summary/{encoded}"
    )
    summary = fetch_json(summary_url)

    extract_url = (
        "https://id.wikipedia.org/w/api.php?"
        f"action=query&prop=extracts&explaintext=1&exsectionformat=plain"
        f"&titles={encoded}&format=json"
    )
    extract_data = fetch_json(extract_url)
    pages = extract_data.get("query", {}).get("pages", {})
    extract = ""
    for page in pages.values():
        extract = page.get("extract", "")
        break

    # Limit extract length for mobile
    if len(extract) > 2800:
        extract = extract[:2800].rsplit(".", 1)[0] + "."

    thumb = summary.get("thumbnail", {})
    image_url = thumb.get("source")
    image_width = thumb.get("width")
    image_height = thumb.get("height")

    return {
        "summary": summary.get("extract", ""),
        "extract": extract,
        "imageUrl": image_url,
        "imageWidth": image_width,
        "imageHeight": image_height,
        "wikiUrl": summary.get("content_urls", {})
        .get("desktop", {})
        .get("page", f"https://id.wikipedia.org/wiki/{encoded}"),
        "license": "Wikipedia / Wikimedia Commons — lihat halaman sumber",
    }


def download_image(event_id: str, url: str | None) -> str | None:
    if not url:
        return None
    IMG_DIR.mkdir(parents=True, exist_ok=True)
    ext = ".jpg"
    if ".png" in url.lower():
        ext = ".png"
    local_name = f"{event_id}{ext}"
    local_path = IMG_DIR / local_name
    try:
        data = fetch_bytes(url)
        local_path.write_bytes(data)
        return f"assets/images/history/events/{local_name}"
    except Exception as e:
        print(f"  ⚠ image download failed {event_id}: {e}")
        return None


def build_context_block(year: int, category: str) -> str:
    era = (
        "Indonesia baru merdeka"
        if year < 1950
        else "Era Orde Lama / Sukarno"
        if year < 1967
        else "Awal Orde Baru"
        if year < 1980
        else "Orde Baru puncak"
        if year < 1998
        else "Reformasi & transisi demokrasi"
        if year < 2004
        else "Era demokrasi stabil"
        if year < 2014
        else "Era digital & infrastruktur"
        if year < 2024
        else "Indonesia masa depan"
    )
    return (
        f"Tahun {year}. {era}. "
        f"Peristiwa kategori {category} ini membentuk kehidupan jutaan WNI."
    )


def main() -> None:
    articles = []
    print(f"Scraping {len(PAGES)} Wikipedia articles...\n")

    for event_id, meta in PAGES.items():
        print(f"→ {event_id}: {meta['wiki']}")
        time.sleep(2.5)  # respect Wikipedia rate limits
        try:
            data = fetch_article(meta["wiki"])
            local_image = download_image(event_id, data.pop("imageUrl", None))
            article = {
                "id": event_id,
                "year": meta["year"],
                "title": meta["title"],
                "category": meta["category"],
                "context": build_context_block(meta["year"], meta["category"]),
                "summary": data["summary"],
                "body": data["extract"] or data["summary"],
                "imageAsset": local_image,
                "imageUrl": None if local_image else None,
                "wikiUrl": data["wikiUrl"],
                "source": "Wikipedia Bahasa Indonesia",
                "license": data["license"],
            }
            articles.append(article)
            img_status = local_image or "no image"
            print(f"  ✓ {len(article['body'])} chars | {img_status}")
        except Exception as e:
            print(f"  ✗ FAILED: {e}")
            articles.append(
                {
                    "id": event_id,
                    "year": meta["year"],
                    "title": meta["title"],
                    "category": meta["category"],
                    "context": build_context_block(
                        meta["year"], meta["category"]
                    ),
                    "summary": meta["title"],
                    "body": f"Artikel sedang dimuat. Baca di Wikipedia: {meta['wiki']}",
                    "imageAsset": None,
                    "wikiUrl": f"https://id.wikipedia.org/wiki/{meta['wiki']}",
                    "source": "Wikipedia Bahasa Indonesia",
                    "license": "Wikipedia",
                }
            )

    articles.sort(key=lambda a: a["year"])
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(
        json.dumps(articles, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"\n✓ Wrote {len(articles)} articles → {OUT_JSON}")
    print(f"✓ Images → {IMG_DIR}")


if __name__ == "__main__":
    main()
