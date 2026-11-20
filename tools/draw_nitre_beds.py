#!/usr/bin/env python3
"""NITRE BEDS stand-in art, drawn in code (crown-powder-study, docs/crown_powder_study.md; option C `-- powder:nitre`).
Listed in docs/art_style_inconsistency.md for a ChatGPT redraw if the owner keeps the building.
    python3 tools/draw_nitre_beds.py
Writes assets/buildings/nitre_beds_{built,damaged,construction,destroyed}.png (104 x 84, the 3 x 2 footprint seen from the
front like the other Crown buildings) and the card icons assets/icons/nitre_beds.png, assets/icons/ab_buy_powder.png."""
import os, random
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W, H = 104, 84
OUT = (34, 24, 16, 255)
EARTH = (112, 82, 52, 255)
EARTH_D = (84, 60, 38, 255)
BED = (74, 54, 36, 255)
BED_L = (98, 72, 48, 255)
CRUST = (232, 228, 214, 255)
WOOD = (120, 84, 48, 255)
WOOD_D = (82, 56, 32, 255)
STRAW = (196, 164, 84, 255)
STRAW_D = (150, 120, 58, 255)


def beds(d, rnd, state):
    # the yard: a low earth bank round three long beds, white saltpetre crust on their tops
    d.rounded_rectangle([4, 30, W - 5, H - 4], 8, fill=EARTH, outline=OUT)
    d.rounded_rectangle([7, 33, W - 8, H - 7], 7, fill=EARTH_D)
    for i in range(3):
        y = 38 + i * 13
        d.rounded_rectangle([12, y, W - 14, y + 9], 4, fill=BED, outline=OUT)
        d.line([14, y + 2, W - 16, y + 2], fill=BED_L, width=2)
        if state in ("built", "damaged"):
            for _ in range(26):
                x = rnd.randint(16, W - 18)
                yy = y + rnd.randint(1, 4)
                d.point((x, yy), fill=CRUST)
                if rnd.random() < 0.4:
                    d.point((x + 1, yy), fill=CRUST)


def shed(d, state):
    # an open lean-to on four posts over the back of the beds (straw roof)
    if state == "destroyed":
        d.line([20, 34, 46, 22], fill=WOOD_D, width=3)
        d.line([60, 30, 84, 24], fill=WOOD_D, width=3)
        d.polygon([(28, 28), (52, 24), (58, 30), (34, 34)], fill=(60, 50, 40, 255), outline=OUT)
        return
    posts = [(14, 40), (W - 16, 40)]
    for x, y in posts:
        d.rectangle([x - 2, y - 26, x + 1, y], fill=WOOD, outline=OUT)
    if state == "construction":
        d.line([12, 15, W - 12, 15], fill=WOOD, width=3)
        d.line([12, 15, W - 12, 15], fill=OUT, width=1)
        return
    roof = [(6, 18), (W - 6, 18), (W - 2, 30), (2, 30)]
    d.polygon(roof, fill=STRAW, outline=OUT)
    for x in range(8, W - 6, 5):
        d.line([x, 19, x - 2, 29], fill=STRAW_D, width=1)
    d.line([4, 30, W - 4, 30], fill=OUT, width=1)
    if state == "damaged":
        d.polygon([(60, 18), (78, 18), (72, 30), (56, 30)], fill=(40, 30, 22, 255), outline=OUT)


def props(d, state):
    if state in ("construction", "destroyed"):
        return
    # a barrel of lye water and a heap of dung by the beds
    d.rounded_rectangle([W - 22, H - 26, W - 10, H - 10], 3, fill=WOOD, outline=OUT)
    d.line([W - 22, H - 21, W - 10, H - 21], fill=WOOD_D)
    d.line([W - 22, H - 15, W - 10, H - 15], fill=WOOD_D)
    d.ellipse([6, H - 22, 22, H - 10], fill=(70, 52, 30, 255), outline=OUT)
    # a little powder keg sign: the Crown's purple
    d.rectangle([46, 6, 58, 15], fill=(98, 52, 128, 255), outline=OUT)
    d.line([52, 15, 52, 20], fill=WOOD_D, width=2)


def building(state):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    rnd = random.Random(7)
    beds(d, rnd, state)
    shed(d, state)
    props(d, state)
    if state == "construction":
        for x in range(10, W - 10, 9):
            d.line([x, 32, x + 6, 32], fill=WOOD, width=2)
    if state == "destroyed":
        for _ in range(40):
            x, y = rnd.randint(10, W - 10), rnd.randint(32, H - 8)
            d.point((x, y), fill=(40, 34, 30, 255))
    return im


def icon_beds():
    im = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    b = building("built").resize((60, 48), Image.NEAREST)
    im.alpha_composite(b, (2, 10))
    return im


def icon_buy():
    # a keg of powder and a gold coin
    im = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([10, 14, 38, 52], 7, fill=WOOD, outline=OUT, width=2)
    for y in (22, 33, 44):
        d.line([11, y, 37, y], fill=WOOD_D, width=2)
    d.ellipse([16, 9, 32, 19], fill=(40, 40, 40, 255), outline=OUT)
    d.ellipse([34, 30, 58, 54], fill=(222, 178, 52, 255), outline=OUT, width=2)
    d.ellipse([39, 35, 53, 49], outline=(150, 112, 26, 255), width=2)
    return im


if __name__ == "__main__":
    for st in ("built", "damaged", "construction", "destroyed"):
        building(st).save(os.path.join(ROOT, "assets/buildings/nitre_beds_%s.png" % st))
    icon_beds().save(os.path.join(ROOT, "assets/icons/nitre_beds.png"))
    icon_buy().save(os.path.join(ROOT, "assets/icons/ab_buy_powder.png"))
    print("ok")
