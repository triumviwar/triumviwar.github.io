#!/usr/bin/env python3
"""STAND-IN stills for Act 1's "The Specimens" (campaign/stills/a05_01.jpg .. a05_05.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_a05_build.md "Stills"). Drawn simply, as the plateau's
(tools/campaign/make_a03_stills.py, whose small helpers are copied here):
  a05_01 the camp     = night on the plateau's edge: tents, a fire, cage carts with iron bars, the doctor by a lantern
  a05_02 the taking   = men with a net over a sleeping young creature in the ferns, by lantern light
  a05_03 the trail    = cage carts on a forest trail at dawn, musketeers round them, eyes in the trees
  a05_04 the landing  = canoes at a sand quay, cages being loaded, two crates with a gear stamped on them
  a05_05 the Sire     = a colossal reptile coming out of the forest at the last cart, musket smoke
The King's pages reuse b01_08 (the naturalist in chains before the King).
Rebuild: python3 tools/campaign/make_a05_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
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




def cart(d, x, y, s, beast=True):
    """A cage cart: a wooden bed on two wheels, iron bars, an ox in front (to the left)."""
    d.rectangle([x - 90 * s, y - 20 * s, x + 90 * s, y], fill=(96, 66, 40))
    for wx in (x - 60 * s, x + 60 * s):
        d.ellipse([wx - 26 * s, y - 14 * s, wx + 26 * s, y + 38 * s], outline=(60, 40, 24), width=max(2, int(6 * s)))
    if beast:
        d.ellipse([x - 60 * s, y - 90 * s, x + 50 * s, y - 24 * s], fill=SCALE)
        d.polygon([(x + 30 * s, y - 70 * s), (x + 60 * s, y - 100 * s), (x + 50 * s, y - 60 * s)], fill=GREEN)
    for i in range(9):
        bx = x - 80 * s + i * 20 * s
        d.line([(bx, y - 110 * s), (bx, y - 20 * s)], fill=(50, 50, 54), width=max(2, int(5 * s)))
    d.line([(x - 84 * s, y - 110 * s), (x + 84 * s, y - 110 * s)], fill=(50, 50, 54), width=max(2, int(7 * s)))
    d.ellipse([x - 200 * s, y - 70 * s, x - 100 * s, y - 10 * s], fill=(120, 96, 70))       # the ox
    d.rectangle([x - 190 * s, y - 20 * s, x - 180 * s, y + 20 * s], fill=(100, 80, 60))
    d.rectangle([x - 120 * s, y - 20 * s, x - 110 * s, y + 20 * s], fill=(100, 80, 60))


def gear(d, x, y, r, col):
    for i in range(10):
        a = i * math.pi / 5
        d.line([(x, y), (x + math.cos(a) * r * 1.25, y + math.sin(a) * r * 1.25)], fill=col, width=max(2, int(r * 0.3)))
    d.ellipse([x - r, y - r, x + r, y + r], fill=col)
    d.ellipse([x - r * 0.35, y - r * 0.35, x + r * 0.35, y + r * 0.35], fill=(150, 120, 80))


def s01():
    im = grad((18, 22, 40), (40, 46, 40), 520)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 520, W, H], fill=(58, 60, 48))                                        # the plateau's top
    for x in (180, 980):
        d.polygon([(x, 560), (x + 90, 420), (x + 180, 560)], fill=(196, 190, 170))      # tents
    cart(d, 460, 700, 0.9, beast=False)
    cart(d, 760, 720, 0.9, beast=False)
    d.ellipse([600, 640, 660, 680], fill=(200, 80, 30))                                    # the fire
    glow(im, 630, 650, 200, (255, 170, 80), 0.5)
    d = ImageDraw.Draw(im)
    person(d, 300, 760, 240, (60, 60, 64), hat=(30, 30, 30))                               # the doctor
    glow(im, 340, 610, 60, (255, 220, 140), 0.6)                                           # his lantern
    for x in (880, 1040, 1150):
        person(d, x, 770, 190, YELLOW, hat=(40, 40, 30))
    mist(im, 30, 51, 70, 380, 620)
    return paint(im, 51)


def s02():
    im = grad((14, 20, 26), (30, 44, 30))
    d = ImageDraw.Draw(im)
    rnd = random.Random(52)
    for _ in range(120):                                                                    # ferns
        x, y = rnd.uniform(0, W), rnd.uniform(520, H)
        d.polygon([(x, y), (x - 40, y - 70), (x + 10, y - 20), (x + 40, y - 80), (x + 20, y)], fill=(40, rnd.randint(70, 100), 40))
    creature(d, 640, 690, 0.9)                                                              # the sleeping young
    for i in range(14):                                                                     # the net
        d.line([(420 + i * 32, 520), (500 + i * 26, 760)], fill=(170, 160, 130), width=2)
        d.line([(420, 520 + i * 17), (860, 540 + i * 16)], fill=(170, 160, 130), width=2)
    for x in (360, 920):
        person(d, x, 800, 260, YELLOW, hat=(40, 40, 30))
    person(d, 1080, 810, 280, (60, 60, 64), hat=(30, 30, 30))
    glow(im, 1120, 600, 90, (255, 220, 140), 0.6)
    return paint(im, 52)


def s03():
    im = grad((210, 190, 170), (70, 90, 60), 560)
    d = ImageDraw.Draw(im)
    trees(d, 640, 53, n=40, hmin=200, hmax=480)
    d.polygon([(380, H), (560, 560), (720, 560), (980, H)], fill=(120, 100, 70))          # the trail
    cart(d, 640, 640, 0.6)
    cart(d, 650, 800, 1.0)
    for x, y in ((420, 780), (880, 770), (520, 650), (790, 640)):
        person(d, x, y, 170, YELLOW, hat=(40, 40, 30))
    rnd = random.Random(53)
    for _ in range(8):                                                                      # eyes in the trees
        x, y = rnd.choice([rnd.uniform(60, 320), rnd.uniform(1000, 1240)]), rnd.uniform(420, 620)
        d.ellipse([x, y, x + 10, y + 6], fill=(230, 210, 60))
        d.ellipse([x + 18, y, x + 28, y + 6], fill=(230, 210, 60))
    mist(im, 30, 53, 60, 300, 640)
    return paint(im, 53)


def s04():
    im = grad((230, 190, 140), (150, 150, 120), 520)
    d = ImageDraw.Draw(im)
    trees(d, 520, 54, n=30, hmin=120, hmax=300)
    d.rectangle([0, 600, W, H], fill=(70, 80, 70))                                         # the river
    d.polygon([(0, 520), (W, 520), (W, 640), (0, 660)], fill=(200, 180, 136))             # the quay's sand
    for x in (220, 420, 980):
        d.polygon([(x, 720), (x + 200, 705), (x + 220, 740), (x + 20, 755)], fill=(90, 66, 40))   # canoes
    cart(d, 640, 600, 0.8)
    d.rectangle([980, 520, 1120, 610], fill=(150, 112, 70))                                # the Lisbon crates
    d.rectangle([1130, 540, 1240, 610], fill=(140, 104, 66))
    gear(d, 1050, 565, 22, (70, 50, 30))
    gear(d, 1185, 575, 18, (70, 50, 30))
    person(d, 300, 640, 200, (90, 70, 50), hat=(80, 60, 30))                               # Benedito
    person(d, 860, 640, 220, (60, 60, 64), hat=(30, 30, 30))                               # the doctor
    return paint(im, 54)


def s05():
    im = grad((150, 90, 70), (50, 50, 40), 600)
    d = ImageDraw.Draw(im)
    trees(d, 600, 55, n=30, hmin=260, hmax=520, col=(30, 50, 34))
    d.rectangle([0, 600, W, H], fill=(110, 96, 70))
    # the Sire out of the trees
    d.ellipse([700, 260, 1180, 560], fill=SCALE)
    d.polygon([(1060, 300), (1260, 180), (1280, 260), (1120, 380)], fill=SCALE)
    d.polygon([(1180, 230), (1270, 260), (1180, 280)], fill=(200, 60, 50))                 # the jaw open
    for i in range(6):
        d.polygon([(800 + i * 60, 270), (820 + i * 60, 200), (840 + i * 60, 270)], fill=GREEN)
    cart(d, 420, 760, 1.1)
    for x, y in ((180, 820), (640, 830), (720, 800)):
        person(d, x, y, 220, YELLOW, hat=(40, 40, 30))
    mist(im, 25, 55, 90, 600, 800)
    return paint(im, 55)


os.makedirs(OUT, exist_ok=True)
for i, fn in enumerate([s01, s02, s03, s04, s05], 1):
    p = os.path.join(OUT, "a05_%02d.jpg" % i)
    fn().save(p, quality=88)
    print("wrote", os.path.normpath(p))
