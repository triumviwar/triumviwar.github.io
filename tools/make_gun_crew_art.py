#!/usr/bin/env python3
"""The Gun Crewman's stand-in strips (gun-crew-fetch, 2026-11-20).

He is the Labourer's drawing with the gunners' steel helmet: the brown hat above his shoulders is recoloured a cold
steel grey (the Field Cannon's and Mortar's crew wear grey morions). The red coat stays the team-colour mask, so he
wears the side's colour like the gunners. Writes assets/units/gun_crew/<anim>_<dir>.png for idle, walk and death
(the only strips he plays). A stand-in until the owner's ChatGPT gunner (docs/art_style_inconsistency.md).

    python3 tools/make_gun_crew_art.py
"""
import colorsys
import os

from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SRC = os.path.join(ROOT, "assets/units/labourer")
OUT = os.path.join(ROOT, "assets/units/gun_crew")
ANIMS = ["walk", "death"]
DIRS = ["s", "se", "e", "ne", "n"]
CELL_W = 42


def brown(p):
    r, g, b, a = p
    if a < 40:
        return False
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    return 0.0 <= h <= 0.14 and s >= 0.3 and 0.1 <= v <= 0.68 and not (r > 200 and g > 150)


def steel(p):
    r, g, b, a = p
    lum = 0.3 * r + 0.59 * g + 0.11 * b
    k = min(255.0, lum * 1.35 + 18)
    return (int(k * 0.92), int(k * 0.96), int(min(255, k * 1.06)), a)


def is_mask(p):
    r, g, b, a = p
    return a > 100 and g < 20 and b < 20 and r > 120


def convert(path_in, path_out):
    im = Image.open(path_in).convert("RGBA")
    w, h = im.size
    px = im.load()
    for x0 in range(0, w, CELL_W):
        # the shoulders: the first row of the coat (the team-colour mask) in this frame
        top = h
        for y in range(h):
            if any(is_mask(px[x, y]) for x in range(x0, min(w, x0 + CELL_W))):
                top = y
                break
        for y in range(0, min(h, top + 2)):
            for x in range(x0, min(w, x0 + CELL_W)):
                if brown(px[x, y]):
                    px[x, y] = steel(px[x, y])
    im.save(path_out)


def main():
    os.makedirs(OUT, exist_ok=True)
    for a in ANIMS:
        for d in DIRS:
            src = os.path.join(SRC, "%s_%s.png" % (a, d))
            convert(src, os.path.join(OUT, "%s_%s.png" % (a, d)))
    # his idle: the walk's first frame twice (the Labourer's idle leans on a pick he has none of)
    for d in DIRS:
        walk = Image.open(os.path.join(OUT, "walk_%s.png" % d))
        fr = walk.crop((0, 0, CELL_W, walk.size[1]))
        idle = Image.new("RGBA", (CELL_W * 2, walk.size[1]))
        idle.paste(fr, (0, 0))
        idle.paste(fr, (CELL_W, 0))
        idle.save(os.path.join(OUT, "idle_%s.png" % d))
    print("wrote", OUT)


if __name__ == "__main__":
    main()
