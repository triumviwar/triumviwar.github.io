#!/usr/bin/env python3
"""The Gun Crewman's walk from the ChatGPT sheet (2026-11-20).

art/redraws/gun_crew_walk_<dir>_chatgpt.png: six walk frames in a row on a flat navy ground. Each figure is cut out,
scaled to the Labourer's size (32 px helmet to soles) with one factor for the whole strip (the bob stays), its feet
put at (21, 33) of a 42 x 35 cell; the coat's reds become the team-colour mask (pure red 255 / 150, as the
Labourer's). Writes assets/units/gun_crew/walk_<dir>.png and idle_<dir>.png (the first frame twice).

    python3 tools/import_gun_crew.py se
"""
import os
import sys

from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CELL_W, CELL_H, FOOT_X, FOOT_Y, TALL = 42, 35, 21, 33, 32


def is_bg(p, bg):
    return sum(abs(p[i] - bg[i]) for i in range(3)) < 60


def figures(im):
    w, h = im.size
    px = im.load()
    bg = px[4, 4]
    cols = [any(not is_bg(px[x, y], bg) for y in range(h)) for x in range(w)]
    runs, x = [], 0
    while x < w:
        if cols[x]:
            s = x
            while x < w and cols[x]:
                x += 1
            if x - s > 20:
                runs.append((s, x))
        x += 1
    out = []
    for s, e in runs:
        top = min(y for y in range(h) for x in range(s, e) if not is_bg(px[x, y], bg))
        bot = max(y for y in range(h) for x in range(s, e) if not is_bg(px[x, y], bg))
        out.append((s, top, e, bot + 1))
    return out, bg


def mask(p):
    r, g, b, a = p
    if a and r > 110 and r > 2.2 * g and r > 2.2 * b:
        return (255, 0, 0, 255) if r >= 200 else (150, 0, 0, 255)
    return p


def main(d):
    src = Image.open(os.path.join(ROOT, "art/redraws/gun_crew_walk_%s_chatgpt.png" % d)).convert("RGB")
    figs, bg = figures(src)
    assert len(figs) == 6, figs
    k = TALL / max(b[3] - b[1] for b in figs)
    strip = Image.new("RGBA", (CELL_W * 6, CELL_H))
    for i, (x0, y0, x1, y1) in enumerate(figs):
        fig = src.crop((x0, y0, x1, y1)).convert("RGBA")
        fp = fig.load()
        for y in range(fig.height):
            for x in range(fig.width):
                if is_bg(fp[x, y], bg):
                    fp[x, y] = (0, 0, 0, 0)
        w, h = max(1, round(fig.width * k)), max(1, round(fig.height * k))
        small = fig.resize((w, h), Image.NEAREST)
        sp = small.load()
        for y in range(h):
            for x in range(w):
                sp[x, y] = mask(sp[x, y])
        strip.alpha_composite(small, (i * CELL_W + FOOT_X - w // 2, FOOT_Y + 1 - h))
    out = os.path.join(ROOT, "assets/units/gun_crew")
    strip.save(os.path.join(out, "walk_%s.png" % d))
    idle = Image.new("RGBA", (CELL_W * 2, CELL_H))
    fr = strip.crop((0, 0, CELL_W, CELL_H))
    idle.paste(fr, (0, 0))
    idle.paste(fr, (CELL_W, 0))
    idle.save(os.path.join(out, "idle_%s.png" % d))
    print("wrote walk/idle", d, "scale", round(k, 3))


if __name__ == "__main__":
    for d in sys.argv[1:] or ["se"]:
        main(d)
