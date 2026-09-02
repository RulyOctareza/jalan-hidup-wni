#!/usr/bin/env python3
"""Rebuild assets/content/assets_catalog.json from assets/images/."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMAGES = ROOT / "assets" / "images"

MAPPING = {
    "brand": "brand",
    "icons/stats": "stats",
    "icons/activities": "activities",
    "icons/jobs": "jobs",
    "icons/phases": "life_phases",
    "icons/achievements": "achievements",
    "icons/history": "history",
    "avatars": "avatars",
    "backgrounds": "backgrounds",
    "events": "events",
}


def main() -> None:
    catalog = {
        "version": 1,
        "style": "flat_modern_indonesia",
        "categories": {},
    }
    for folder, cat in MAPPING.items():
        p = IMAGES / folder
        if not p.exists():
            continue
        catalog["categories"][cat] = [
            {
                "id": f.stem,
                "path": str(f.relative_to(ROOT)).replace("\\", "/"),
                "filename": f.name,
            }
            for f in sorted(p.glob("*.png"))
        ]
    catalog["totalAssets"] = sum(
        len(v) for v in catalog["categories"].values()
    )
    out = ROOT / "assets" / "content" / "assets_catalog.json"
    out.write_text(
        json.dumps(catalog, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"Catalog: {catalog['totalAssets']} assets -> {out}")


if __name__ == "__main__":
    main()
