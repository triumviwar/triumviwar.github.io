#!/usr/bin/env python3
"""THE WAR MAP'S CATHOLIC PAINTINGS (owner 2026-11-20 23:09 / 2026-11-21 21:52): fit each painted sheet to lon/lat.

Each view's painting (art/campaign/warmap_<view>_chatgpt.png) follows the real coasts only roughly, so a place is put
on it by LANDMARKS: [lon, lat, x, y] (pixels on the 1536 x 1024 sheet), fitted by least squares (a quadratic in lon/lat,
an affine one for a sheet with few landmarks); the world sheet's two hemispheres are fitted apart (split at -25 lon).
Places the story needs exactly ("at": pins and marks by id) are placed by hand on top of the fit.
Writes campaign/warmap_art/painted_<view>.jpg and the "paintings" block of campaign/warmap.json.
    python3 tools/campaign/fit_warmap_paintings.py [--check outdir]
"""
import json, sys
import numpy as np
from PIL import Image, ImageDraw

ROOT = __file__.rsplit("/tools/", 1)[0]
SHEETS = {
    "world": {
        "hemi": -25.0,
        "west": [[-80.4, 25.1, 476, 426], [-87, 21.5, 444, 468], [-79.5, 9, 490, 509], [-35.2, -5.4, 711, 574],
                 [-50, 0, 623, 528], [-67.3, -55.9, 508, 781], [-57, -35, 596, 703], [-81.3, -4.7, 490, 555],
                 [-70, 42, 513, 371], [-53, 47.5, 559, 343], [-109.9, 22.9, 366, 454], [-168, 65.6, 250, 260],
                 [-82, 51.5, 467, 334]],
        "east": [[-5.6, 36, 875, 403], [-17.5, 14.7, 806, 454], [18.5, -34.4, 976, 693], [51.3, 11.8, 1078, 500],
                 [32.5, 30, 1027, 426], [77.5, 8, 1170, 505], [103.5, 1.3, 1262, 560], [-4.5, 48.4, 898, 348],
                 [15.6, 38, 981, 380], [10.6, 57.7, 967, 307], [29, 41, 1041, 380], [56, 26.5, 1101, 440],
                 [45, -25.6, 1055, 647]],
        "cart": [768, 883, 268],
    },
    "europe": {
        "fit": [[-5.7, 50.06, 402, 290], [-4.5, 48.4, 297, 388], [1.6, 50.9, 612, 295], [4.75, 52.95, 766, 172],
                [2.35, 48.86, 680, 370], [4.84, 45.76, 752, 500], [4.8, 43.4, 768, 670], [8.9, 44.4, 992, 597],
                [9.4, 43.0, 981, 659], [12.3, 45.4, 1199, 541], [12.48, 41.9, 1110, 715], [11.08, 49.45, 1125, 315],
                [-1.5, 43.4, 416, 613], [10.6, 57.7, 1009, 40]],
        "cart": [765, 896, 237],
    },
    "virginia": {
        "affine": True,
        "fit": [[-70.1, 41.9, 1318, 105], [-71.9, 41.07, 1153, 173], [-74.0, 40.47, 1020, 212],
                [-74.95, 38.93, 975, 360], [-75.97, 37.12, 901, 509], [-75.53, 35.25, 931, 632],
                [-76.1, 39.54, 921, 291], [-77.3, 37.45, 837, 474]],
        "cart": [771, 870, 288],
    },
    "amazon": {
        "affine": True,
        "fit": [[-60.0, -3.1, 1061, 726], [-65.0, -0.4, 615, 482], [-63.5, -0.85, 838, 517],
                [-64.5, -0.55, 698, 486], [-67.0, 1.2, 496, 216]],
        # the plateau stands on the painted hills (the sheet's only high ground), north-east of the station
        "at": {"a03_plateau": [770, 160], "a05_specimens": [735, 228], "plateau_question": [815, 128]},
        "cart": [767, 864, 288],
    },
}

# BRAZIL (act2-warmap, docs/war_map_act2.md): no painting yet. When art/campaign/warmap_brazil_chatgpt.png comes, add
# "brazil": {"affine": False, "fit": [[lon, lat, x, y], ...], "cart": [x, y, w]} to SHEETS with these places' pixels
# read off the painting (the mouths and bends of the rivers are the surest; at least 8):
#   the Amazon's mouth at Belem [-48.5, -1.45]; Obidos [-55.52, -1.9]; the Negro meets the Amazon (the Barra) [-60.0, -3.1];
#   the Tapajos meets the Amazon (Santarem) [-54.7, -2.44]; Salvador [-38.9, -12.9]; Cape Sao Roque [-35.2, -5.4];
#   Rio de Janeiro's bay [-43.2, -22.9]; Vila Rica [-43.5, -20.39]; the Sao Francisco's mouth [-36.4, -10.5];
#   Santa Catarina island [-48.5, -27.6]; the Rio de la Plata's mouth [-57.0, -35.0]; the Uruguay at the highlands [-52.0, -27.2].
# The view's rect (campaign/warmap.json "views" brazil) is [-74, -34, -33, 6]: the painting should cover it.

def feats(lon, lat, affine):
    return [1, lon, lat] if affine else [1, lon, lat, lon * lon, lon * lat, lat * lat]


def fit(pts, affine):
    A = np.array([feats(p[0], p[1], affine) for p in pts], float)
    X = np.linalg.lstsq(A, np.array([p[2] for p in pts], float), rcond=None)[0]
    Y = np.linalg.lstsq(A, np.array([p[3] for p in pts], float), rcond=None)[0]
    err = max(np.hypot(A @ X - [p[2] for p in pts], A @ Y - [p[3] for p in pts]))
    c = [list(map(float, X)), list(map(float, Y))]
    # what the fit misses at each landmark, spread back by inverse distance: the sheet's own landmarks land exactly
    res = [[p[0], p[1], p[2] - apply(c, p[0], p[1])[0], p[3] - apply(c, p[0], p[1])[1]] for p in pts]
    return c + [res], err


def apply(c, lon, lat):
    f = feats(lon, lat, len(c[0]) == 3)
    x, y = sum(a * b for a, b in zip(c[0], f)), sum(a * b for a, b in zip(c[1], f))
    if len(c) > 2 and c[2]:
        ws = sx = sy = 0.0
        for r in c[2]:
            dd = (lon - r[0]) ** 2 + (lat - r[1]) ** 2
            if dd < 1e-9:
                return x + r[2], y + r[3]
            w = 1.0 / dd
            ws += w; sx += w * r[2]; sy += w * r[3]
        x += sx / ws; y += sy / ws
    return x, y


def main():
    path = ROOT + "/campaign/warmap.json"
    d = json.load(open(path))
    out = {}
    for view, sh in SHEETS.items():
        src = ROOT + "/art/campaign/warmap_%s_chatgpt.png" % view
        im = Image.open(src).convert("RGB")
        im.save(ROOT + "/campaign/warmap_art/painted_%s.jpg" % view, quality=90)
        e = {"file": "res://campaign/warmap_art/painted_%s.jpg" % view, "size": list(im.size), "cart": sh["cart"]}
        if "hemi" in sh:
            e["hemi"] = sh["hemi"]
            e["west"], ew = fit(sh["west"], False)
            e["east"], ee = fit(sh["east"], False)
            print(view, "fit error west %.1f east %.1f px" % (ew, ee))
        else:
            e["fit"], er = fit(sh["fit"], bool(sh.get("affine")))
            print(view, "fit error %.1f px" % er)
        if sh.get("at"):
            e["at"] = sh["at"]
        out[view] = e
    d["paintings"] = out
    json.dump(d, open(path, "w"), indent="\t", ensure_ascii=False)
    open(path, "a").write("\n")
    if len(sys.argv) > 2 and sys.argv[1] == "--check":
        check(d, sys.argv[2])


TEST = [["London", -0.1, 51.5], ["Madrid", -3.7, 40.4], ["Cairo", 31.2, 30.0], ["New York", -74, 40.7],
        ["Rio", -43.2, -22.9], ["Lima", -77, -12], ["Moscow", 37.6, 55.8], ["Lisbon", -9.1, 38.7]]


def check(d, outdir):
    for view, e in d["paintings"].items():
        im = Image.open(ROOT + "/" + e["file"][6:]).convert("RGB")
        dr = ImageDraw.Draw(im)
        def pos(lon, lat):
            if "hemi" in e:
                return apply(e["west"] if lon < e["hemi"] else e["east"], lon, lat)
            return apply(e["fit"], lon, lat)
        for pn in d["pins"] + d["marks"]:
            key = pn.get("mission", pn.get("id"))
            x, y = e.get("at", {}).get(key) or pos(*pn["point"])
            dr.ellipse([x - 7, y - 7, x + 7, y + 7], outline=(255, 0, 0), width=3)
            dr.text((x + 9, y - 6), key, fill=(255, 0, 0))
        for n, lon, lat in TEST:
            x, y = pos(lon, lat)
            dr.rectangle([x - 4, y - 4, x + 4, y + 4], outline=(0, 0, 255), width=2)
            dr.text((x + 6, y), n, fill=(0, 0, 255))
        im.save("%s/check_%s.png" % (outdir, view))


if __name__ == "__main__":
    main()
