#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "Down the Rivers" (campaign/stills/d08_01.jpg .. d08_04.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_d08_build.md "Stills"). Drawn simply, with d06's helpers
(copied here). THE BROOD IS NOT A PERSON: animals, drawn as animals.
  d08_01 the meeting of the waters = a black river meets a brown one; a river town on a bluff with a small fort and a
                                     white church; flooded forest on the far bank; heavy clouds
  d08_02 Nazaré                    = villagers carry bundles into long canoes; an explorer with a musket holds the bank;
                                     green shapes in the trees
  d08_03 the lure book             = night by a campfire on a riverbank: a weathered explorer with an old leather book of
                                     drawings, an old boatman beside him, the explorer's other hand near the fire
  d08_04 the dawn                  = grey dawn over the bluff: smoke from the lower town, the fort's flag still up, the
                                     flooded forest across the water quiet
The King's pages reuse b01_01 (the King with the mapmaker's report).
Rebuild: python3 tools/campaign/make_d08_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
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


def d01():
    """The meeting of the waters: the black river and the brown one, the Barra on its bluff, the flooded far bank."""
    im = grad((96, 100, 110), (150, 140, 120))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 470), (W, 430), (W, H), (0, H)], fill=RIVER)                               # the brown river
    d.polygon([(0, 470), (560, 452), (700, H), (0, H)], fill=BLACKWATER)                     # the black river
    trees(d, 330, 470, 70, 81, (34, 56, 38), 0, 520)                                          # the flooded far bank
    for x in range(30, 500, 60):
        d.rectangle([x, 440, x + 10, 500], fill=(50, 44, 36))
    town(d, 660, 330, 1.0)
    im = paint(im, 81)
    return im


def d02():
    """Nazaré: villagers carry bundles into canoes; an explorer holds the bank; green shapes in the trees."""
    im = grad((130, 140, 120), (110, 120, 90))
    d = ImageDraw.Draw(im)
    trees(d, 80, 420, 90, 82, (34, 62, 36))
    d.rectangle([0, 600, W, H], fill=BLACKWATER)                                              # the river
    d.polygon([(0, 600), (W, 560), (W, 610), (0, 640)], fill=(150, 130, 96))                 # the beach
    for k, x in enumerate([120, 420, 760]):
        canoe(d, x, 690 + k * 16, 1.3)
    for k, x in enumerate([200, 270, 480, 560, 820, 900]):
        figure(d, x, 520 + (k % 2) * 16, (200 - k * 10, 180, 150), 80)
        d.ellipse([x - 8, 540, x + 30, 570], fill=(150, 120, 80))                            # a bundle
    figure(d, 1060, 470, (60, 60, 70), 120)                                                   # the explorer
    d.line([(1090, 500), (1160, 420)], fill=(40, 30, 20), width=6)                            # his musket
    for (x, y) in [(980, 360), (1120, 330), (300, 340)]:
        creature(d, x, y, 0.6, (50, 96, 46))
    return paint(im, 82)


def d03():
    """The lure book: night by a campfire on the bank: the explorer with an old book of drawings, an old boatman."""
    im = grad((14, 16, 24), (30, 28, 30))
    d = ImageDraw.Draw(im)
    trees(d, 120, 420, 60, 83, (16, 28, 20))
    d.rectangle([0, 520, W, H], fill=(36, 30, 24))
    glow(im, 640, 600, 260, (255, 150, 60), 0.6)                                              # the fire
    d = ImageDraw.Draw(im)
    d.polygon([(600, 640), (640, 540), (680, 640)], fill=(255, 190, 90))
    figure(d, 470, 470, (70, 64, 60), 150)                                                    # Valadares
    d.rectangle([500, 560, 600, 620], fill=(110, 70, 40))                                     # the book
    d.line([(550, 560), (550, 620)], fill=(60, 40, 20), width=3)
    for i in range(3):
        d.ellipse([510 + i * 28, 570, 530 + i * 28, 590], outline=(40, 30, 20))              # drawings of creatures
    figure(d, 760, 500, (150, 130, 100), 120)                                                 # Benedito
    return paint(im, 83)


def d04():
    """The dawn: grey light over the bluff, smoke from the lower town, the flag still up, the far bank quiet."""
    im = grad((150, 150, 156), (176, 160, 136))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 520, W, H], fill=BLACKWATER)
    trees(d, 400, 520, 50, 84, (52, 70, 56), 0, 480)
    town(d, 600, 380, 1.1)
    for i in range(5):                                                                        # smoke from the lower town
        glow(im, 620 + i * 30, 360 - i * 50, 60 + i * 10, (120, 118, 116), 0.35)
    return paint(im, 84)


for i, fn in enumerate([d01, d02, d03, d04], 1):
    p = os.path.join(OUT, "d08_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
