#!/usr/bin/env python3
"""An outline reference of a region for ChatGPT to trace (the war map's regional paintings, 2026-11-20): Natural Earth's
coasts, lakes and rivers (campaign/warmap_land.json) in black ink on white, in the war map's projection (x = lon,
y = -lat * 1.3), with a 5-degree grid in grey. ChatGPT is asked to keep these coasts; the game then fits its painting
to the real map by landmarks (tools/campaign/fit_painting.py).

    python3 tools/campaign/render_region_ref.py <lon0> <lat0> <lon1> <lat1> <out.png> [width]
"""
import json
import os
import sys

from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
lon0, lat0, lon1, lat1 = (float(v) for v in sys.argv[1:5])
out = sys.argv[5]
W = int(sys.argv[6]) if len(sys.argv) > 6 else 1536
YS = 1.3
H = int(W * (lat1 - lat0) * YS / (lon1 - lon0))
k = W / (lon1 - lon0)


def px(lon, lat):
    return ((lon - lon0) * k, (lat1 - lat) * YS * k)


land = json.load(open(os.path.join(ROOT, "campaign/warmap_land.json")))
im = Image.new("RGB", (W, H), "white")
d = ImageDraw.Draw(im)
for g in range(int(lon0 // 5 * 5), int(lon1) + 6, 5):
    d.line([px(g, lat0), px(g, lat1)], fill=(190, 190, 190), width=1)
for g in range(int(lat0 // 5 * 5), int(lat1) + 6, 5):
    d.line([px(lon0, g), px(lon1, g)], fill=(190, 190, 190), width=1)
for key, fill in [("land", (235, 228, 210)), ("lakes", (255, 255, 255))]:
    for flat in land[key]:
        pts = [px(flat[i], flat[i + 1]) for i in range(0, len(flat), 2)]
        if len(pts) > 2:
            d.polygon(pts, fill=fill, outline=(0, 0, 0))
for flat in land["rivers"]:
    pts = [px(flat[i], flat[i + 1]) for i in range(0, len(flat), 2)]
    d.line(pts, fill=(40, 70, 160), width=2)
im.save(out)
print(out, W, H)
