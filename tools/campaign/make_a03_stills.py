#!/usr/bin/env python3
"""STAND-IN stills for Act 1's "The Lost Plateau" (campaign/stills/a03_01.jpg .. a03_05.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_a03_build.md "Stills"). Drawn simply, as the Brood prologue's
(tools/campaign/make_b01_stills.py, whose small helpers are copied here):
  a03_01 the mountain = a canoe at a sand beach under a sheer flat-topped mountain wrapped in cloud, a waterfall
  a03_02 the climb    = men in a file on a rock stair beside a waterfall, in grey mist
  a03_03 the nest     = from a rim looking down into a misty hollow: a great rooted mother in a green swamp, sleeping
                        shapes round her, a smaller frilled one among them
  a03_04 the map      = the mapmaker drawing on a rock at dusk above the cloud, his men watching the hollow
  a03_05 the flight   = down a narrow cleft in the rock at dusk, musketeers looking back, a huge shape at the top
The King's pages reuse b01_01 (the King with the mapmaker's letter).
Rebuild: python3 tools/campaign/make_a03_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
PURPLE = (92, 50, 120)
YELLOW = (190, 160, 70)        # the party's touch of the station's yellow
GREEN = (88, 200, 70)          # the Brood's venom green
SCALE = (92, 82, 52)           # olive-brown scales
ROCK = (150, 112, 86)          # the tepui's sandstone


def grad(top, bottom, h=H):
    im = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(im)
    for y in range(H):
        t = min(1.0, y / max(1, h - 1))
        d.line([(0, y), (W, y)], fill=tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return im


def glow(im, x, y, r, col, a=0.55):
    lay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    for i in range(12, 0, -1):
        rr = r * i / 12
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=col + (int(255 * a / 12),))
    im.paste(Image.alpha_composite(im.convert("RGBA"), lay).convert("RGB"))


def mist(im, n=40, seed=5, a=60, y0=0, y1=H):
    rnd = random.Random(seed)
    lay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    for _ in range(n):
        x, y = rnd.uniform(-100, W + 100), rnd.uniform(y0, y1)
        r = rnd.uniform(120, 300)
        d.ellipse([x - r, y - r * 0.35, x + r, y + r * 0.35], fill=(225, 228, 232, a))
    lay = lay.filter(ImageFilter.GaussianBlur(30))
    im.paste(Image.alpha_composite(im.convert("RGBA"), lay).convert("RGB"))


def paint(im, seed=1):
    """A little brushwork: soften, then speckle."""
    im = im.filter(ImageFilter.GaussianBlur(1.6))
    rnd = random.Random(seed)
    px = im.load()
    for _ in range(26000):
        x, y = rnd.randrange(W), rnd.randrange(H)
        c = px[x, y]
        k = rnd.uniform(0.9, 1.1)
        px[x, y] = tuple(max(0, min(255, int(v * k))) for v in c)
    return im.filter(ImageFilter.GaussianBlur(0.6))


def trees(d, y0, seed, col=(36, 66, 40), n=40, hmin=120, hmax=300):
    rnd = random.Random(seed)
    for _ in range(n):
        x = rnd.uniform(-40, W + 40)
        h = rnd.uniform(hmin, hmax)
        d.rectangle([x - 5, y0 - h, x + 5, y0], fill=tuple(max(0, c - 8) for c in col))
        for k in range(4):
            r = rnd.uniform(36, 70)
            cx, cy = x + rnd.uniform(-40, 40), y0 - h + rnd.uniform(-30, 20)
            d.ellipse([cx - r, cy - r * 0.7, cx + r, cy + r * 0.7], fill=tuple(min(255, c + rnd.randint(-6, 10)) for c in col))


def person(d, x, y, h, coat, head=(214, 176, 140), hat=None):
    d.polygon([(x - h * 0.16, y), (x - h * 0.12, y - h * 0.62), (x + h * 0.12, y - h * 0.62), (x + h * 0.16, y)], fill=coat)
    d.ellipse([x - h * 0.08, y - h * 0.8, x + h * 0.08, y - h * 0.63], fill=head)
    if hat:
        d.ellipse([x - h * 0.16, y - h * 0.8, x + h * 0.16, y - h * 0.74], fill=hat)


def creature(d, x, y, s, frill=True, col=SCALE):
    d.ellipse([x - 80 * s, y - 34 * s, x + 60 * s, y + 14 * s], fill=col)
    d.polygon([(x - 70 * s, y - 10 * s), (x - 190 * s, y + 10 * s), (x - 70 * s, y + 6 * s)], fill=col)
    d.polygon([(x + 40 * s, y - 24 * s), (x + 90 * s, y - 80 * s), (x + 110 * s, y - 70 * s), (x + 70 * s, y - 10 * s)], fill=col)
    d.ellipse([x + 80 * s, y - 100 * s, x + 140 * s, y - 64 * s], fill=col)
    if frill:
        for i in range(7):
            a = math.radians(150 + i * 22)
            px, py = x + 92 * s, y - 80 * s
            d.polygon([(px, py), (px + math.cos(a) * 46 * s, py + math.sin(a) * 46 * s),
                       (px + math.cos(a + 0.2) * 22 * s, py + math.sin(a + 0.2) * 22 * s)], fill=GREEN)


def tepui(d, x0, x1, top, base, col=ROCK):
    """A flat-topped mountain with sheer sides."""
    d.polygon([(x0, base), (x0 + 40, top + 20), (x0 + 70, top), (x1 - 70, top), (x1 - 40, top + 20), (x1, base)], fill=col)
    for i in range(14):
        x = x0 + 60 + i * (x1 - x0 - 120) / 14
        d.line([(x, top + 10), (x - 8, base)], fill=tuple(c - 22 for c in col), width=3)


def a01():
    im = grad((196, 204, 210), (110, 130, 110), 520)
    d = ImageDraw.Draw(im)
    tepui(d, 240, 1040, 130, 560)
    d.line([(560, 140), (552, 560)], fill=(240, 244, 250), width=14)                        # the falls
    trees(d, 640, 11, n=36, hmin=100, hmax=260)
    d.rectangle([0, 700, W, H], fill=(36, 40, 34))                                          # the river
    d.polygon([(420, 700), (860, 700), (900, 760), (380, 760)], fill=(196, 176, 130))       # the beach
    d.polygon([(560, 770), (780, 755), (800, 785), (580, 800)], fill=(90, 66, 40))          # the canoe
    person(d, 600, 740, 150, (70, 80, 60), hat=(60, 50, 30))
    for x in (680, 720, 760):
        person(d, x, 735, 130, PURPLE, hat=(30, 30, 30))
    mist(im, 30, 1, 120, 60, 260)
    return paint(im, 31)


def a02():
    im = grad((170, 176, 182), (96, 104, 100))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 0), (520, 0), (600, H), (0, H)], fill=(132, 100, 80))                   # the cliff face
    d.line([(700, 0), (690, H)], fill=(236, 240, 246), width=40)                             # the falls
    for i in range(9):                                                                       # the stair
        y = 820 - i * 85
        d.polygon([(500 - i * 20, y), (640 - i * 18, y), (630 - i * 18, y - 30), (490 - i * 20, y - 30)], fill=(110, 86, 70))
    for i, (x, y) in enumerate([(560, 760), (530, 680), (510, 590), (470, 500), (450, 420)]):
        person(d, x, y, 120 - i * 10, PURPLE if i % 2 else (80, 70, 50), hat=(30, 30, 30))
    mist(im, 60, 2, 130)
    return paint(im, 32)


def a03():
    im = grad((150, 160, 160), (60, 80, 60))
    d = ImageDraw.Draw(im)
    d.ellipse([60, 260, 1220, 900], fill=(46, 70, 44))                                      # the hollow
    d.ellipse([260, 380, 1020, 820], fill=(56, 92, 50))                                     # its swamp
    d.ellipse([500, 450, 820, 640], fill=SCALE)                                             # the Mother, rooted
    d.ellipse([760, 470, 860, 540], fill=SCALE)
    rnd = random.Random(3)
    for _ in range(9):                                                                       # sleepers round her
        creature(d, rnd.uniform(240, 1000), rnd.uniform(560, 780), 0.4, frill=True)
    creature(d, 960, 520, 0.7, frill=True)                                                   # Linnea, grown
    d.polygon([(0, 853), (0, 700), (300, 760), (520, 853)], fill=(120, 96, 80))             # the rim, seen from it
    person(d, 120, 840, 260, (70, 80, 60), hat=(60, 50, 30))
    mist(im, 40, 3, 90, 200, 600)
    return paint(im, 33)


def a04():
    im = grad((90, 70, 110), (220, 150, 110), 560)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 560, W, H], fill=(130, 100, 84))                                         # the top
    mist(im, 50, 4, 140, 470, 620)
    d = ImageDraw.Draw(im)
    d.polygon([(380, 640), (760, 620), (780, 700), (400, 720)], fill=(150, 120, 96))         # the drawing rock
    d.polygon([(470, 640), (680, 630), (690, 680), (480, 690)], fill=(232, 222, 196))        # the map
    person(d, 760, 760, 260, (70, 80, 60), hat=(60, 50, 30))
    for x in (980, 1060, 1140):
        person(d, x, 780, 200, PURPLE, hat=(30, 30, 30))
    glow(im, 600, 660, 120, (255, 210, 140), 0.35)
    return paint(im, 34)


def a05():
    im = grad((100, 80, 110), (60, 60, 60))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 0), (520, 0), (560, H), (0, H)], fill=(118, 88, 72))                     # the cleft's walls
    d.polygon([(760, 0), (W, 0), (W, H), (720, H)], fill=(112, 84, 70))
    d.polygon([(560, H), (520, 0), (760, 0), (720, H)], fill=(84, 70, 64))                  # the cleft
    d.ellipse([560, 40, 720, 160], fill=SCALE)                                               # the Sire at the top
    d.polygon([(600, 120), (520, 220), (680, 150)], fill=SCALE)
    for i, (x, y) in enumerate([(640, 820), (600, 720), (680, 640), (620, 560)]):
        person(d, x, y, 170 - i * 18, PURPLE if i else (70, 80, 60), hat=(30, 30, 30))
    mist(im, 30, 5, 80, 0, 300)
    return paint(im, 35)


os.makedirs(OUT, exist_ok=True)
for i, fn in enumerate([a01, a02, a03, a04, a05], 1):
    p = os.path.join(OUT, "a03_%02d.jpg" % i)
    fn().save(p, quality=88)
    print("wrote", os.path.normpath(p))
