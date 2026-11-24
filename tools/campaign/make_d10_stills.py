#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The Jungle Front" (campaign/stills/d10_01.jpg .. d10_04.jpg, 1280 x 853) and Father
Inácio's dialogue portrait (campaign/portraits/inacio.png, 256 x 256), until the owner's ChatGPT paintings come (the
prompts: docs/campaign_d10_build.md "Stills"). Drawn simply, with d08's helpers (copied here). THE BROOD IS NOT A PERSON:
animals, drawn as animals.
  d10_01 the balloon     = a purple observation balloon on a rope over the Amazon's canopy at dawn, a priest in the
                            basket with a telescope; mist below, and the rings of rooted creatures in the swamp
  d10_02 the nests burn  = soldiers in purple with torches and muskets in a flooded forest; a rooted creature's swamp
                            burns; green fog rolls in
  d10_03 Óbidos          = a small river fort on a bluff over the narrows of a very wide river, fog on the water at morning
  d10_04 Mass on the island = a priest says Mass at a burnt ruin on a river island; soldiers kneel; a balloon tethered
The King's pages reuse b01_01 (the King with the mapmaker's report).
Rebuild: python3 tools/campaign/make_d10_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
PURPLE, BLACK, GREEN = (96, 50, 130), (28, 26, 30), (64, 120, 56)
RIVER = (150, 118, 80)
FOREST = (34, 62, 36)


def grad(top, bottom):
    im = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(im)
    for y in range(H):
        t = y / (H - 1)
        d.line([(0, y), (W, y)], fill=tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return im


def glow(im, x, y, r, col, a=0.55):
    lay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    for i in range(12, 0, -1):
        rr = r * i / 12
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=col + (int(255 * a / 12),))
    im.paste(Image.alpha_composite(im.convert("RGBA"), lay).convert("RGB"))


def paint(im, seed=1):
    im = im.filter(ImageFilter.GaussianBlur(1.6))
    rnd = random.Random(seed)
    px = im.load()
    for _ in range(26000):
        x, y = rnd.randrange(W), rnd.randrange(H)
        c = px[x, y]
        k = rnd.uniform(0.9, 1.1)
        px[x, y] = tuple(max(0, min(255, int(v * k))) for v in c)
    return im.filter(ImageFilter.GaussianBlur(0.6))


def figure(d, x, y, coat, h=110, face=(220, 190, 160)):
    d.rectangle([x, y, x + 30, y + h], fill=coat)
    d.ellipse([x, y - 32, x + 30, y - 2], fill=face)


def trees(d, y0, y1, n, seed, col=FOREST, x0=0, x1=W):
    rnd = random.Random(seed)
    for _ in range(n):
        x, y, r = rnd.uniform(x0, x1), rnd.uniform(y0, y1), rnd.uniform(26, 60)
        c = tuple(max(0, min(255, int(v * rnd.uniform(0.8, 1.2)))) for v in col)
        d.ellipse([x - r, y - r * 0.8, x + r, y + r * 0.8], fill=c)


def creature(d, x, y, s=1.0, col=GREEN):
    """A young green reptile lying down: a body, a neck and head, a tail, a spined back."""
    d.ellipse([x, y, x + 90 * s, y + 34 * s], fill=col)
    d.polygon([(x + 80 * s, y + 10 * s), (x + 120 * s, y - 8 * s), (x + 132 * s, y + 4 * s), (x + 92 * s, y + 22 * s)], fill=col)
    d.polygon([(x + 4 * s, y + 18 * s), (x - 60 * s, y + 30 * s), (x + 6 * s, y + 28 * s)], fill=col)
    for i in range(5):
        sx = x + 16 * s + i * 14 * s
        d.polygon([(sx, y + 2 * s), (sx + 6 * s, y - 10 * s), (sx + 12 * s, y + 2 * s)], fill=tuple(int(v * 0.7) for v in col))


def canoe(d, x, y, s=1.0):
    d.chord([x, y - 18 * s, x + 200 * s, y + 18 * s], 0, 180, fill=(90, 60, 36))


def wing(d, cx, cy, span, col):
    d.polygon([(cx, cy), (cx - span, cy - span * 0.35), (cx - span * 0.6, cy + span * 0.05)], fill=col)
    d.polygon([(cx, cy), (cx + span, cy - span * 0.35), (cx + span * 0.6, cy + span * 0.05)], fill=col)




def rain(im, seed, n=900, col=(200, 210, 220)):
    d = ImageDraw.Draw(im)
    rnd = random.Random(seed)
    for _ in range(n):
        x, y = rnd.uniform(0, W), rnd.uniform(0, H)
        d.line([(x, y), (x - 6, y + 22)], fill=col, width=1)


def mother(d, x, y, s=1.0, col=(58, 112, 52)):
    """A big Brood Mother: a heavy body, a crested head, a spined back (an animal, nothing more)."""
    d.ellipse([min(x, x + 260 * s), y, max(x, x + 260 * s), y + 110 * abs(s)], fill=col)
    d.polygon([(x + 230 * s, y + 30 * s), (x + 320 * s, y - 30 * s), (x + 350 * s, y), (x + 260 * s, y + 70 * s)], fill=col)
    d.polygon([(x + 300 * s, y - 26 * s), (x + 320 * s, y - 70 * s), (x + 334 * s, y - 22 * s)], fill=tuple(int(v * 0.6) for v in col))
    d.polygon([(x + 10 * s, y + 60 * s), (x - 140 * s, y + 90 * s), (x + 20 * s, y + 90 * s)], fill=col)
    for i in range(9):
        sx = x + 30 * s + i * 24 * s
        d.polygon([(sx, y + 6 * s), (sx + 10 * s, y - 26 * s), (sx + 20 * s, y + 6 * s)], fill=tuple(int(v * 0.65) for v in col))


BLACKWATER = (34, 30, 28)
WHITE = (226, 220, 206)


def town(d, x0, y0, s=1.0):
    """A colonial river town on a bluff: the bluff, a small fort's wall, a white church with a tower, roofs."""
    d.polygon([(x0, y0 + 160 * s), (x0 + 40 * s, y0), (x0 + 520 * s, y0), (x0 + 560 * s, y0 + 160 * s)], fill=(120, 96, 66))
    d.rectangle([x0 + 40 * s, y0 - 40 * s, x0 + 200 * s, y0], fill=(150, 140, 120))           # the fort
    for i in range(6):
        d.rectangle([x0 + (44 + i * 26) * s, y0 - 52 * s, x0 + (56 + i * 26) * s, y0 - 40 * s], fill=(150, 140, 120))
    d.rectangle([x0 + 260 * s, y0 - 90 * s, x0 + 360 * s, y0], fill=WHITE)                    # the church
    d.rectangle([x0 + 340 * s, y0 - 150 * s, x0 + 380 * s, y0], fill=WHITE)
    d.polygon([(x0 + 336 * s, y0 - 150 * s), (x0 + 360 * s, y0 - 186 * s), (x0 + 384 * s, y0 - 150 * s)], fill=(150, 80, 60))
    d.line([(x0 + 360 * s, y0 - 186 * s), (x0 + 360 * s, y0 - 210 * s)], fill=(60, 50, 40), width=4)
    d.line([(x0 + 350 * s, y0 - 200 * s), (x0 + 370 * s, y0 - 200 * s)], fill=(60, 50, 40), width=4)
    for i in range(4):
        d.polygon([(x0 + (390 + i * 40) * s, y0), (x0 + (410 + i * 40) * s, y0 - 30 * s), (x0 + (430 + i * 40) * s, y0)], fill=(170, 90, 60))
    d.line([(x0 + 120 * s, y0 - 52 * s), (x0 + 120 * s, y0 - 110 * s)], fill=(60, 50, 40), width=3)
    d.rectangle([x0 + 122 * s, y0 - 110 * s, x0 + 160 * s, y0 - 88 * s], fill=PURPLE)




def balloon(d, cx, cy, r=110, col=PURPLE):
    """An observation balloon: the envelope, the ropes, the basket."""
    d.ellipse([cx - r, cy - r * 1.15, cx + r, cy + r * 0.9], fill=col)
    for i in range(-2, 3):
        d.line([(cx + i * r * 0.35, cy - r * 1.1), (cx + i * r * 0.32, cy + r * 0.85)], fill=tuple(int(v * 0.75) for v in col), width=3)
    for dx in (-r * 0.5, -r * 0.2, r * 0.2, r * 0.5):
        d.line([(cx + dx, cy + r * 0.7), (cx + dx * 0.4, cy + r * 1.5)], fill=(60, 50, 40), width=2)
    d.rectangle([cx - r * 0.28, cy + r * 1.45, cx + r * 0.28, cy + r * 1.75], fill=(120, 86, 48))


def d01():
    """The balloon over the canopy at dawn; the priest in the basket; mist and the rings of rooted creatures below."""
    im = grad((236, 190, 150), (120, 140, 120))
    d = ImageDraw.Draw(im)
    trees(d, 560, H, 160, 101, (40, 70, 44))
    for i in range(6):
        glow(im, 120 + i * 220, 600, 160, (230, 230, 226), 0.35)                              # the mist
    d = ImageDraw.Draw(im)
    for (x, y) in [(300, 720), (900, 760)]:
        d.ellipse([x - 120, y - 40, x + 120, y + 40], fill=(70, 80, 50))                      # a swamp ring
        mother(d, x - 90, y - 50, 0.4, (58, 104, 52))
    d.line([(640, 420), (720, H)], fill=(80, 64, 44), width=3)                                # the rope down
    balloon(d, 620, 170, 120)
    figure(d, 606, 300, (24, 22, 26), 40)                                                     # the priest in the basket
    d.line([(632, 300), (690, 284)], fill=(140, 120, 70), width=5)                            # his telescope
    return paint(im, 101)


def d02():
    """The nests burn: soldiers with torches and muskets in a flooded forest; a rooted creature's swamp burns; green fog."""
    im = grad((70, 80, 70), (50, 60, 44))
    d = ImageDraw.Draw(im)
    trees(d, 60, 460, 90, 102, (30, 52, 32))
    d.rectangle([0, 560, W, H], fill=(56, 60, 40))                                            # the flood
    mother(d, 640, 430, 0.9, (60, 106, 50))
    for i in range(7):
        glow(im, 600 + i * 60, 520 - (i % 3) * 30, 90, (255, 140, 50), 0.45)                   # the fire
    for i in range(4):
        glow(im, 1000 + i * 70, 560, 130, (120, 200, 110), 0.3)                               # the green fog
    d = ImageDraw.Draw(im)
    for k, x in enumerate([90, 170, 250, 330, 410]):
        figure(d, x, 520 + (k % 2) * 20, PURPLE, 110)
        d.line([(x + 30, 540), (x + 70, 470)], fill=(50, 40, 30), width=5)
        if k % 2 == 0:
            glow(im, x + 72, 466, 26, (255, 190, 90), 0.7)                                    # a torch
            d = ImageDraw.Draw(im)
    return paint(im, 102)


def d03():
    """Óbidos: a small river fort on a bluff over the narrows of a very wide river; fog on the water at morning."""
    im = grad((190, 196, 200), (170, 160, 140))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 500, W, H], fill=RIVER)
    trees(d, 430, 500, 40, 103, (54, 80, 58), 0, 520)                                         # the far bank, low
    town(d, 620, 360, 1.05)
    for i in range(7):
        glow(im, 80 + i * 180, 560, 150, (236, 236, 232), 0.42)                               # the fog on the water
    d = ImageDraw.Draw(im)
    canoe(d, 200, 700, 1.2)
    return paint(im, 103)


def d04():
    """Mass on the island at the burnt ruin; soldiers kneel; a balloon tethered beyond."""
    im = grad((210, 196, 170), (120, 110, 90))
    d = ImageDraw.Draw(im)
    trees(d, 300, 470, 40, 104, (50, 70, 50))
    d.rectangle([0, 520, W, H], fill=(90, 84, 70))
    for x in (500, 640, 760):                                                                 # the burnt ruin
        d.rectangle([x, 330, x + 40, 520], fill=(60, 54, 50))
    d.rectangle([500, 330, 800, 350], fill=(60, 54, 50))
    d.rectangle([600, 470, 700, 520], fill=WHITE)                                             # the altar cloth
    d.line([(650, 400), (650, 470)], fill=(60, 50, 40), width=5)
    d.line([(632, 420), (668, 420)], fill=(60, 50, 40), width=5)
    figure(d, 700, 410, (24, 22, 26), 110)                                                    # the priest
    for k, x in enumerate([180, 260, 340, 900, 980, 1060]):
        d.rectangle([x, 600, x + 34, 660], fill=PURPLE)                                       # kneeling soldiers
        d.ellipse([x + 2, 570, x + 32, 600], fill=(220, 190, 160))
    balloon(d, 1120, 160, 70)
    d.line([(1120, 290), (1100, 520)], fill=(80, 64, 44), width=2)
    return paint(im, 104)


def portrait():
    """Father Inácio (stand-in): a cheerful priest in a black cassock and a flyer's leather cap, a purple balloon behind."""
    s = 256
    im = Image.new("RGB", (s, s), (176, 150, 120))
    d = ImageDraw.Draw(im)
    for y in range(s):
        t = y / (s - 1)
        d.line([(0, y), (s, y)], fill=(int(200 - 60 * t), int(170 - 50 * t), int(140 - 40 * t)))
    d.ellipse([150, 10, 250, 120], fill=PURPLE)                                               # the balloon behind
    d.rectangle([60, 170, 196, s], fill=(24, 22, 26))                                         # the cassock
    d.rectangle([112, 170, 144, 186], fill=WHITE)                                             # the collar
    d.ellipse([78, 62, 178, 176], fill=(196, 150, 112))                                       # the face (a Brazilian man of about 35)
    d.chord([74, 50, 182, 120], 180, 360, fill=(90, 60, 36))                                  # the leather cap
    d.rectangle([84, 96, 172, 110], fill=(70, 50, 30))
    d.ellipse([96, 98, 124, 122], outline=(160, 150, 120), width=4)                           # goggles up on the cap
    d.ellipse([132, 98, 160, 122], outline=(160, 150, 120), width=4)
    d.ellipse([104, 120, 114, 130], fill=(40, 30, 24))                                        # eyes
    d.ellipse([142, 120, 152, 130], fill=(40, 30, 24))
    d.arc([108, 132, 148, 160], 20, 160, fill=(110, 60, 50), width=4)                         # the smile
    return paint_small(im)


def paint_small(im):
    im = im.filter(ImageFilter.GaussianBlur(1.0))
    rnd = random.Random(105)
    px = im.load()
    for _ in range(3000):
        x, y = rnd.randrange(im.size[0]), rnd.randrange(im.size[1])
        px[x, y] = tuple(max(0, min(255, int(v * rnd.uniform(0.92, 1.08)))) for v in px[x, y])
    return im


for i, fn in enumerate([d01, d02, d03, d04], 1):
    p = os.path.join(OUT, "d10_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
p = os.path.join(ROOT, "campaign", "portraits", "inacio.png")
portrait().save(p)
print("wrote", os.path.normpath(p))
