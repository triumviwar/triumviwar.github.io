#!/usr/bin/env python3
"""The Gun Crewman's death from the ChatGPT strips (2026-11-20).

art/redraws/gun_crew_death_<dir>_chatgpt.png: three frames (hit, falling, lying with the helmet beside him), each in its
own third of the sheet, on a flat navy ground. Each third is cut out whole (the flying helmet with it), scaled with one
factor for the strip (the first frame, the staggering man, stands about as tall as his walk: TALL px), set centred on
x 21 with its lowest pixel at y 33 of a 42 x 35 cell; a frame still wider than the cell is shrunk to fit. The coat's
reds become the team-colour mask, as in import_gun_crew.py. Writes assets/units/gun_crew/death_<dir>.png.

    python3 tools/import_gun_crew_death.py se s e ne n
"""
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_gun_crew import ROOT, CELL_W, CELL_H, FOOT_X, FOOT_Y, is_bg, mask  # noqa: E402

TALL = 31


def frames(src):
    w, h = src.size
    bg = src.getpixel((4, 4))
    out = []
    for i in range(3):
        part = src.crop((i * w // 3, 0, (i + 1) * w // 3, h)).convert("RGBA")
        px = part.load()
        for y in range(part.height):
            for x in range(part.width):
                if is_bg(px[x, y], bg):
                    px[x, y] = (0, 0, 0, 0)
        out.append(part.crop(part.getbbox()))
    return out


def main(d):
    src = Image.open(os.path.join(ROOT, "art/redraws/gun_crew_death_%s_chatgpt.png" % d)).convert("RGB")
    figs = frames(src)
    k = TALL / figs[0].height
    strip = Image.new("RGBA", (CELL_W * 3, CELL_H))
    for i, fig in enumerate(figs):
        kk = min(k, (CELL_W - 2) / fig.width)
        w, h = max(1, round(fig.width * kk)), max(1, round(fig.height * kk))
        small = fig.resize((w, h), Image.NEAREST)
        sp = small.load()
        for y in range(h):
            for x in range(w):
                if sp[x, y][3] < 128:
                    sp[x, y] = (0, 0, 0, 0)
                else:
                    sp[x, y] = mask(sp[x, y][:3] + (255,))
        strip.alpha_composite(small, (i * CELL_W + FOOT_X - w // 2, FOOT_Y + 1 - h))
    strip.save(os.path.join(ROOT, "assets/units/gun_crew/death_%s.png" % d))
    print("wrote death", d, "scale", round(k, 3))


if __name__ == "__main__":
    for d in sys.argv[1:] or ["se"]:
        main(d)
