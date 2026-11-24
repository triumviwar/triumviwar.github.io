#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The Queen" (campaign/stills/d06_01.jpg .. d06_04.jpg, 1280 x 853), until the owner's
ChatGPT paintings come (the prompts: docs/campaign_d06_build.md "Stills"). Drawn simply, with d03's helpers
(tools/campaign/make_d03_stills.py, copied here). THE BROOD IS NOT A PERSON: animals, drawn as animals.
  d06_01 the flood  = the island in flood under grey rain: wooden pens standing in brown water among drowned trees,
                      green reptiles in the pens lifting their heads toward the forest
  d06_02 the fight  = night in a forest pen: two large green reptilian mothers locked together, smaller creatures
                      scattering round them, a broken fence, torchlight far off
  d06_03 the Queen  = a ruined pen at dawn: an enormous green reptile rooted in swamp, its back grown with spines and
                      growths, a ring of smaller creatures low round it
  d06_04 the canoes = an old naturalist and a young assistant push off in a canoe at night from a burning plantation
                      house; green shapes on the bank behind
The King's pages reuse b01_08 (the King and his prisoner, the doctor).
Rebuild: python3 tools/campaign/make_d06_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
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


def d01():
    """The flood: pens standing in brown water, drowned trees, creatures lifting their heads; grey rain."""
    im = grad((120, 128, 132), (150, 140, 116))
    d = ImageDraw.Draw(im)
    trees(d, 120, 380, 80, 61, (36, 56, 40))
    d.rectangle([0, 420, W, H], fill=RIVER)                                               # the flood
    for x in range(40, W, 140):                                                           # drowned trunks
        d.rectangle([x, 360, x + 16, 520], fill=(60, 50, 40))
    for px0 in (160, 560, 920):                                                           # the pens in the water
        for px in range(px0, px0 + 260, 32):
            d.rectangle([px, 520, px + 8, 660], fill=(110, 80, 50))
        d.rectangle([px0, 540, px0 + 260, 548], fill=(110, 80, 50))
        creature(d, px0 + 70, 590, 1.1)
    im = paint(im, 61)
    rain(im, 61)
    return im


def d02():
    """The fight: night, two big Mothers locked together in a pen, smaller creatures scattering, a torch far off."""
    im = grad((20, 26, 30), (54, 58, 44))
    d = ImageDraw.Draw(im)
    trees(d, 0, 420, 90, 62, (18, 34, 24))
    d.ellipse([60, 460, 1220, 960], fill=(70, 66, 44))                                    # the pen's mud
    mother(d, 250, 520, 1.1, (56, 108, 50))
    mother(d, 980, 500, -1.0, (90, 104, 52))                                              # (facing the other way)
    for (x, y) in [(120, 760), (420, 790), (880, 780), (1060, 740)]:
        creature(d, x, y, 0.6)
    for px in range(700, 1000, 34):                                                       # the broken fence
        d.line([(px, 700), (px + 20, 640)], fill=(110, 80, 50), width=6)
    glow(im, 1180, 380, 40, (240, 150, 60), 0.7)                                          # a torch far off
    return paint(im, 62)


def d03():
    """The Queen: a ruined pen at dawn, an enormous rooted reptile with grown spines, a ring of creatures low round it."""
    im = grad((210, 170, 140), (120, 120, 96))
    d = ImageDraw.Draw(im)
    trees(d, 120, 420, 70, 63, (40, 64, 44))
    d.ellipse([40, 520, 1240, 900], fill=(60, 80, 50))                                    # the swamp round her
    mother(d, 360, 430, 1.6, (54, 104, 48))
    for i in range(12):                                                                   # her growths
        x = 420 + i * 36
        d.ellipse([x, 400 - (i % 3) * 14, x + 30, 440 - (i % 3) * 14], fill=(110, 120, 70))
    for k, (x, y) in enumerate([(100, 760), (300, 800), (700, 820), (960, 790), (1120, 720), (180, 660)]):
        creature(d, x, y, 0.55)
    glow(im, 640, 120, 140, (255, 220, 170), 0.4)
    return paint(im, 63)


def d04():
    """The canoes: night, two men in a canoe pushing off from a burning house; green shapes on the bank behind."""
    im = grad((16, 18, 30), (40, 34, 40))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 560, W, H], fill=(60, 48, 40))                                        # the river at night
    d.rectangle([740, 300, 1060, 470], fill=(170, 150, 120))                              # the house
    d.polygon([(720, 302), (900, 230), (1080, 302)], fill=(120, 60, 40))
    glow(im, 900, 330, 240, (255, 140, 50), 0.6)                                          # the fire
    d = ImageDraw.Draw(im)
    for (x, y) in [(620, 520), (760, 540), (1100, 520)]:
        creature(d, x, y, 0.7, (40, 80, 40))
    canoe(d, 140, 700, 1.4)
    figure(d, 210, 600, (214, 206, 180), 100)                                             # Lindqvist
    figure(d, 300, 610, (120, 110, 90), 90)                                               # Pieter with the pole
    d.line([(320, 610), (380, 760)], fill=(90, 60, 36), width=5)
    return paint(im, 64)


for i, fn in enumerate([d01, d02, d03, d04], 1):
    p = os.path.join(OUT, "d06_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
