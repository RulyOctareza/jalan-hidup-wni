#!/usr/bin/env bash
# Sync AI-generated assets from Cursor workspace to Jalan Hidup WNI project
set -euo pipefail

SRC="${1:-$HOME/.cursor/projects/empty-window/assets}"
DST="${2:-/Volumes/DevSSD/DevProjects/jalan-hidup-wni/assets/images}"

mkdir -p "$DST"/{brand,icons/{stats,activities,jobs,phases,achievements,history},avatars,backgrounds,events}

cp "$SRC"/app_icon.png "$SRC"/splash_bg.png "$SRC"/ui_news_banner.png "$DST/brand/" 2>/dev/null || true
cp "$SRC"/stat_*.png "$DST/icons/stats/" 2>/dev/null || true
cp "$SRC"/activity_*.png "$DST/icons/activities/" 2>/dev/null || true
cp "$SRC"/job_*.png "$DST/icons/jobs/" 2>/dev/null || true
cp "$SRC"/phase_*.png "$DST/icons/phases/" 2>/dev/null || true
cp "$SRC"/achievement_*.png "$DST/icons/achievements/" 2>/dev/null || true
cp "$SRC"/history_*.png "$DST/icons/history/" 2>/dev/null || true
cp "$SRC"/avatar_*.png "$DST/avatars/" 2>/dev/null || true
cp "$SRC"/bg_*.png "$DST/backgrounds/" 2>/dev/null || true
cp "$SRC"/event_*.png "$DST/events/" 2>/dev/null || true

echo "Synced $(find "$DST" -name '*.png' | wc -l | tr -d ' ') PNG files to $DST"
