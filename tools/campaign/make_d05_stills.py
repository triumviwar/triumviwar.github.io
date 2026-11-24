#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The Mission of São Rafael" (campaign/stills/d05_01.jpg .. d05_04.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_d05_build.md "Stills"). Drawn simply, with d06's helpers
(tools/campaign/make_d06_stills.py, copied here). THE BROOD IS NOT A PERSON: animals, drawn as animals.
  d05_01 São Rafael  = a mission village on a riverside bluff: a timber church with a whitewashed front and a bell tower,
                       thatched houses, fields; a priest in black at the church door; flooded forest round it; evening
  d05_02 the bell    = night: a priest rings a bell by its rope while villagers run in from the fields; at the edge of the
                       flooded forest pale eyes and green reptile shapes
  d05_03 the dragoons = mounted soldiers in purple coats gallop through a muddy clearing into a pack of green raptors
  d05_04 the fields  = a priest and a cavalry captain by a granary at dusk with a torch between them; a column of
                       villagers going down a trail; the fields green and full
The King's pages reuse p01_01 (the King lighting his pipe).
Rebuild: python3 tools/campaign/make_d05_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
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




def church(d, x, y, s=1.0):
    """A timber church with a whitewashed front, a dark roof and a wooden bell tower beside it."""
    d.rectangle([x, y, x + 200 * s, y + 140 * s], fill=(226, 222, 206))
    d.polygon([(x - 14 * s, y), (x + 100 * s, y - 80 * s), (x + 214 * s, y)], fill=(70, 50, 36))
    d.rectangle([x + 80 * s, y + 70 * s, x + 120 * s, y + 140 * s], fill=(60, 40, 28))         # the door
    d.rectangle([x + 230 * s, y - 70 * s, x + 270 * s, y + 140 * s], fill=(96, 70, 44))        # the tower
    d.polygon([(x + 222 * s, y - 70 * s), (x + 250 * s, y - 110 * s), (x + 278 * s, y - 70 * s)], fill=(70, 50, 36))
    d.ellipse([x + 238 * s, y - 60 * s, x + 262 * s, y - 36 * s], fill=(170, 140, 60))         # the bell
    d.line([(x + 250 * s, y - 36 * s), (x + 250 * s, y + 120 * s)], fill=(150, 130, 90), width=2)


def hut(d, x, y, s=1.0):
    d.rectangle([x, y, x + 90 * s, y + 60 * s], fill=(170, 140, 100))
    d.polygon([(x - 12 * s, y + 4 * s), (x + 45 * s, y - 46 * s), (x + 102 * s, y + 4 * s)], fill=(150, 126, 70))


def field(d, x0, y0, x1, y1, col=(96, 130, 56)):
    d.rectangle([x0, y0, x1, y1], fill=col)
    for yy in range(int(y0) + 6, int(y1), 12):
        d.line([(x0, yy), (x1, yy)], fill=tuple(int(v * 0.8) for v in col), width=2)


def raptor(d, x, y, s=1.0, col=GREEN, flip=False):
    """A running raptor: a lean body, a long tail, a raised head, two legs."""
    k = -1 if flip else 1
    d.ellipse([x, y, x + 60 * s * k if not flip else x, y + 22 * s] if not flip else [x - 60 * s, y, x, y + 22 * s], fill=col)
    d.polygon([(x + 54 * s * k, y + 8 * s), (x + 84 * s * k, y - 14 * s), (x + 92 * s * k, y - 4 * s), (x + 60 * s * k, y + 16 * s)], fill=col)
    d.polygon([(x + 6 * s * k, y + 10 * s), (x - 60 * s * k, y + 2 * s), (x + 4 * s * k, y + 18 * s)], fill=col)
    d.line([(x + 26 * s * k, y + 20 * s), (x + 14 * s * k, y + 44 * s)], fill=col, width=max(2, int(5 * s)))
    d.line([(x + 40 * s * k, y + 20 * s), (x + 50 * s * k, y + 44 * s)], fill=col, width=max(2, int(5 * s)))


def rider(d, x, y, coat=PURPLE, s=1.0):
    """A horseman at the gallop, sabre up."""
    d.ellipse([x, y, x + 120 * s, y + 50 * s], fill=(90, 60, 40))                              # the horse
    d.polygon([(x + 100 * s, y + 10 * s), (x + 150 * s, y - 20 * s), (x + 156 * s, y + 4 * s), (x + 116 * s, y + 30 * s)], fill=(90, 60, 40))
    for lx in (14, 40, 80, 104):
        d.line([(x + lx * s, y + 40 * s), (x + (lx - 14) * s, y + 82 * s)], fill=(70, 46, 30), width=max(3, int(6 * s)))
    d.rectangle([x + 46 * s, y - 50 * s, x + 74 * s, y + 6 * s], fill=coat)                     # the man
    d.ellipse([x + 48 * s, y - 76 * s, x + 72 * s, y - 52 * s], fill=(220, 190, 160))
    d.line([(x + 72 * s, y - 40 * s), (x + 120 * s, y - 90 * s)], fill=(200, 200, 210), width=max(2, int(4 * s)))


def d01():
    """São Rafael at evening: the church on the bluff, huts, fields, the priest at the door, the flooded forest round."""
    im = grad((230, 170, 120), (150, 130, 100))
    d = ImageDraw.Draw(im)
    trees(d, 200, 470, 90, 51, (40, 70, 44))
    d.rectangle([0, 560, W, H], fill=RIVER)                                                   # the flood
    for x in range(30, W, 120):
        d.rectangle([x, 520, x + 14, 640], fill=(60, 50, 40))                                 # drowned trunks
    d.polygon([(220, 600), (380, 430), (920, 430), (1100, 600)], fill=(110, 120, 70))        # the bluff
    field(d, 140, 610, 420, 660)
    field(d, 900, 610, 1180, 660)
    church(d, 520, 300, 1.2)
    for (x, y) in [(400, 380), (860, 380), (980, 400)]:
        hut(d, x, y, 0.9)
    figure(d, 620, 380, BLACK, 90)                                                            # the priest at the door
    for (x, y) in [(700, 400), (740, 410), (450, 420)]:
        figure(d, x, y, (180, 150, 110), 70)
    glow(im, 640, 120, 160, (255, 200, 140), 0.35)
    return paint(im, 51)


def d02():
    """The bell: night, the priest at the rope, people running in from the fields, eyes and shapes at the forest's edge."""
    im = grad((14, 18, 30), (40, 44, 40))
    d = ImageDraw.Draw(im)
    trees(d, 300, 560, 90, 52, (16, 30, 22))
    d.rectangle([0, 620, W, H], fill=(46, 44, 36))
    church(d, 140, 330, 1.3)
    figure(d, 470, 400, BLACK, 110)                                                           # the priest at the rope
    d.line([(486, 400), (466, 260)], fill=(150, 130, 90), width=3)
    for i, (x, y) in enumerate([(640, 520), (720, 540), (800, 530), (880, 560), (960, 540)]):
        figure(d, x, y, (170, 140, 110), 70)                                                  # running in
    for (x, y) in [(1040, 600), (1140, 640), (1210, 590)]:
        raptor(d, x, y, 0.9, (40, 80, 44), flip=True)
    for (x, y) in [(1080, 540), (1170, 520), (1230, 560), (990, 520)]:
        glow(im, x, y, 6, (230, 240, 190), 0.9)                                               # eyes in the dark
    glow(im, 300, 380, 80, (240, 170, 80), 0.4)                                               # a lamp at the door
    im = paint(im, 52)
    rain(im, 52, 700, (120, 130, 140))
    return im


def d03():
    """The dragoons: horsemen in purple gallop through a muddy clearing into a pack of green raptors."""
    im = grad((150, 150, 140), (110, 100, 80))
    d = ImageDraw.Draw(im)
    trees(d, 100, 420, 80, 53, (40, 64, 44))
    d.rectangle([0, 520, W, H], fill=(96, 80, 56))                                            # the mud
    for (x, y) in [(120, 560), (330, 600), (520, 540)]:
        rider(d, x, y, PURPLE, 1.1)
    for (x, y, f) in [(760, 640, True), (880, 600, True), (980, 680, True), (1100, 620, True), (840, 720, False)]:
        raptor(d, x, y, 1.0, GREEN, flip=f)
    return paint(im, 53)


def d04():
    """The fields: a priest and a cavalry captain by a granary at dusk with a torch; the column going down a trail."""
    im = grad((200, 120, 80), (90, 80, 70))
    d = ImageDraw.Draw(im)
    trees(d, 160, 420, 70, 54, (40, 60, 40))
    field(d, 0, 470, 700, 600, (100, 136, 58))                                               # the fields, full
    d.rectangle([760, 360, 960, 520], fill=(150, 120, 80))                                    # the granary
    d.polygon([(740, 364), (860, 290), (980, 364)], fill=(110, 90, 50))
    figure(d, 640, 500, BLACK, 120)                                                           # the priest
    figure(d, 700, 500, PURPLE, 124)                                                          # the captain
    d.line([(690, 540), (676, 450)], fill=(90, 60, 36), width=5)                              # the torch between them
    glow(im, 676, 440, 40, (255, 160, 60), 0.8)
    d = ImageDraw.Draw(im)
    d.polygon([(860, H), (1000, 560), (1060, 560), (1220, H)], fill=(130, 110, 80))           # the trail down
    for i in range(9):
        figure(d, 960 + i * 22, 600 + i * 26, (160, 130, 100), 46 + i * 4)                    # the column
    return paint(im, 54)


for i, fn in enumerate([d01, d02, d03, d04], 1):
    p = os.path.join(OUT, "d05_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
