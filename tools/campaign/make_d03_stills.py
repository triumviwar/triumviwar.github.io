#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The Island" (campaign/stills/d03_01.jpg .. d03_04.jpg, 1280 x 853), until the owner's
ChatGPT paintings come (the prompts: docs/campaign_d03_build.md "Stills", from docs/campaign_act2_plan.md). Drawn simply,
as d02's (the small helpers are d02's, tools/campaign/make_d02_stills.py, copied here):
  d03_01 the island     = a wide brown river at the dry season, sandbanks; a forested island with a white house with a
                          red roof and sugar fields, dark forest behind; late afternoon haze
  d03_02 the pens       = a jungle clearing at dusk: an old naturalist holds up a brass lure like a censer; young green
                          reptiles lie in wooden pens round him; a young assistant writes in a ledger
  d03_03 the commission = canoes on a sandy beach; soldiers in purple coats; a man with a map case and a judge in black
                          step ashore; the house up the slope
  d03_04 the Storm Sire = over the canopy at dawn a great green winged reptile with a crest, small winged hatchlings
                          round it, canoes on the river below, mist in the trees
The King's pages reuse b01_08 (the King and his prisoner, the doctor).
Rebuild: python3 tools/campaign/make_d03_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
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


def d01():
    """The island: a wide brown river, sandbanks; a white house, red roof, sugar fields, the forest behind; haze."""
    im = grad((214, 196, 160), (236, 214, 170))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 470, W, H], fill=RIVER)                                               # the river
    for (x, y, w) in [(60, 700, 300), (820, 760, 260), (1000, 560, 200)]:
        d.ellipse([x, y, x + w, y + 30], fill=(214, 190, 140))                            # sandbanks
    d.polygon([(120, 470), (300, 330), (1000, 320), (1200, 470)], fill=(70, 100, 52))     # the island
    trees(d, 300, 400, 70, 31)                                                           # the forest behind
    d.rectangle([380, 410, 920, 470], fill=(170, 170, 80))                                # sugar fields
    for x in range(390, 920, 24):
        d.line([(x, 412), (x + 8, 468)], fill=(130, 140, 60), width=3)
    d.rectangle([560, 360, 720, 420], fill=(236, 232, 220))                               # the white house
    d.polygon([(546, 362), (640, 318), (734, 362)], fill=(170, 70, 50))
    for x in (580, 620, 660, 700):
        d.rectangle([x, 380, x + 14, 400], fill=(60, 50, 40))
    glow(im, 1020, 180, 120, (255, 230, 170), 0.45)                                       # the afternoon sun in the haze
    return paint(im, 31)


def d02():
    """The pens: a jungle clearing at dusk, an old naturalist with a brass lure, young reptiles in pens, an assistant."""
    im = grad((40, 50, 44), (84, 96, 70))
    d = ImageDraw.Draw(im)
    trees(d, 0, 380, 90, 32, (24, 44, 28))
    d.ellipse([120, 420, 1160, 900], fill=(96, 92, 60))                                   # the clearing
    for x in (220, 520, 820):
        creature(d, x, 640, 1.2)
        for px in range(x - 40, x + 180, 34):                                             # the pens' rails
            d.rectangle([px, 600, px + 8, 720], fill=(110, 80, 50))
        d.rectangle([x - 40, 610, x + 180, 618], fill=(110, 80, 50))
    figure(d, 640, 420, (214, 206, 180), 150)                                             # Lindqvist in linen
    d.line([(668, 450), (740, 380)], fill=(214, 206, 180), width=12)                      # his arm up
    d.line([(740, 380), (744, 420)], fill=(150, 120, 40), width=3)                        # the lure's chain
    glow(im, 744, 430, 30, (240, 200, 90), 0.8)                                           # the brass lure
    d = ImageDraw.Draw(im)
    figure(d, 980, 470, (120, 110, 90), 120)                                              # Pieter with the ledger
    d.rectangle([960, 520, 1010, 550], fill=(220, 210, 180))
    return paint(im, 32)


def d03():
    """The commission: canoes on a sandy beach, purple soldiers, a man with a map case and a judge in black, the house."""
    im = grad((150, 190, 214), (230, 226, 200))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 600, W, H], fill=RIVER)
    d.polygon([(0, 640), (W, 560), (W, 700), (0, 760)], fill=(222, 200, 150))             # the beach
    d.polygon([(0, 560), (500, 300), (W, 360), (W, 560)], fill=(80, 112, 60))             # the slope
    trees(d, 260, 360, 40, 33, (52, 90, 50))
    d.rectangle([840, 300, 980, 360], fill=(236, 232, 220))                               # the house up the slope
    d.polygon([(828, 302), (910, 262), (992, 302)], fill=(170, 70, 50))
    for x in (60, 300, 1000):
        canoe(d, x, 720, 1.2)
    for i in range(6):
        figure(d, 200 + i * 60, 560 - i * 6, PURPLE, 90)                                  # musketeers
        d.line([(214 + i * 60, 540 - i * 6), (214 + i * 60, 470 - i * 6)], fill=(70, 60, 50), width=3)
    figure(d, 620, 520, (120, 100, 70), 120)                                              # Valadares, the map case
    d.rectangle([600, 560, 620, 620], fill=(90, 60, 36))
    figure(d, 700, 520, BLACK, 130)                                                       # the judge in black
    return paint(im, 33)


def d04():
    """The Storm Sire: over the canopy at dawn, a great winged reptile and its hatchlings, canoes on the river below."""
    im = grad((240, 196, 160), (190, 200, 200))
    d = ImageDraw.Draw(im)
    trees(d, 520, 860, 120, 34, (40, 72, 44))                                             # the canopy
    d.rectangle([0, 760, 420, H], fill=RIVER)                                             # the river at the foot
    canoe(d, 60, 800, 0.6)
    canoe(d, 220, 810, 0.6)
    wing(d, 700, 300, 320, (60, 104, 52))                                                 # the Storm Sire
    d.ellipse([640, 270, 770, 340], fill=(60, 104, 52))
    d.polygon([(760, 290), (840, 250), (860, 270), (780, 316)], fill=(60, 104, 52))
    d.polygon([(800, 250), (830, 200), (840, 252)], fill=(160, 60, 40))                   # the crest
    rnd = random.Random(34)
    for _ in range(8):                                                                    # hatchlings
        x, y = rnd.uniform(380, 1080), rnd.uniform(160, 460)
        wing(d, x, y, 34, (84, 130, 70))
    for _ in range(14):                                                                   # mist in the trees
        x, y = rnd.uniform(0, W), rnd.uniform(540, 760)
        d.ellipse([x - 70, y - 10, x + 70, y + 10], fill=(200, 206, 196))
    return paint(im, 34)


for i, fn in enumerate([d01, d02, d03, d04], 1):
    p = os.path.join(OUT, "d03_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
