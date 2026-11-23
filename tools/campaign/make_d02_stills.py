#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The Exodus" (campaign/stills/d02_01.jpg .. d02_04.jpg, 1280 x 853), until the owner's
ChatGPT paintings come (the prompts: docs/campaign_d02_build.md "Stills", from docs/campaign_act2_plan.md). Drawn simply,
as Act 1's (the small helpers are a04's, tools/campaign/make_a04_stills.py, copied here):
  d02_01 the night bell = a snowy yard at night: families loading covered carts by lanterns, brass automata carrying
                          chests, a grey-bearded master on a cart's step
  d02_02 Jakob stays    = a works gate at night: a young journeyman walks away from the carts towards purple lanterns;
                          the old master watches, hand half raised
  d02_03 the road       = a frozen valley at dawn: a column of carts and automata going west; purple riders with nets
                          coming down a slope; far east a walled city glowing red
  d02_04 the ships      = a grey harbour: families in blue and crated machines going up the gangways of two tall ships;
                          an old clockmaker at the rail
The King's pages reuse c01_01 (the King in Rome).
Rebuild: python3 tools/campaign/make_d02_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
BLUE, RED, PURPLE, BLACK = (60, 96, 180), (180, 40, 36), (96, 50, 130), (28, 26, 30)
SNOW = (226, 232, 240)


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


def gear(d, cx, cy, r, col, teeth=10, plate=None):
    pts = []
    for i in range(teeth * 2):
        a = math.pi * i / teeth
        rr = r if i % 2 == 0 else r * 0.82
        pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
    d.polygon(pts, fill=col)
    d.ellipse([cx - r * 0.55, cy - r * 0.55, cx + r * 0.55, cy + r * 0.55], fill=plate or tuple(int(c * 0.7) for c in col))
    d.ellipse([cx - r * 0.15, cy - r * 0.15, cx + r * 0.15, cy + r * 0.15], fill=col)


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


def machine(d, x, y, plate, s=1.0):
    d.rectangle([x, y, x + 24 * s, y + 38 * s], fill=(182, 142, 70))
    d.rectangle([x + 5 * s, y + 7 * s, x + 19 * s, y + 18 * s], fill=plate)


def snow(im, n=900, seed=1, top=0):
    rnd = random.Random(seed)
    d = ImageDraw.Draw(im)
    for _ in range(n):
        x, y, r = rnd.uniform(0, W), rnd.uniform(top, H), rnd.uniform(1, 3)
        d.ellipse([x - r, y - r, x + r, y + r], fill=SNOW)


def cart(d, x, y, s=1.0, cover=(200, 190, 170)):
    d.rectangle([x, y + 30 * s, x + 120 * s, y + 70 * s], fill=(92, 64, 40))
    d.chord([x - 6 * s, y - 20 * s, x + 126 * s, y + 70 * s], 180, 360, fill=cover)
    for wx in (x + 18 * s, x + 96 * s):
        d.ellipse([wx - 20 * s, y + 56 * s, wx + 20 * s, y + 96 * s], outline=(60, 40, 26), width=max(2, int(5 * s)))


def d01():
    """The night bell: a snowy yard at night, families loading carts by lanterns, automata carrying chests, Hollweg."""
    im = grad((16, 20, 40), (40, 46, 74))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 560, W, H], fill=(170, 176, 190))                                    # the snowy yard
    d.rectangle([80, 200, 420, 560], fill=(60, 44, 34))                                   # the barn
    d.polygon([(60, 200), (250, 100), (440, 200)], fill=(48, 36, 28))
    d.rectangle([200, 380, 300, 560], fill=(240, 180, 90))                                # its open door, lit
    for i, x in enumerate([480, 700, 920]):
        cart(d, x, 520, 1.4)
        glow(im, x + 60, 500, 50, (255, 200, 110), 0.5)                                   # lanterns
        d = ImageDraw.Draw(im)
        figure(d, x - 30, 600, BLUE, 90)
    for x in (560, 820):
        machine(d, x, 620, BLUE, 2.2)                                                     # automata with chests
        d.rectangle([x - 10, 600, x + 60, 630], fill=(110, 80, 50))
    figure(d, 1120, 470, (110, 60, 40), 150)                                              # Hollweg on a cart's step
    snow(im, 900, 21)
    return paint(im, 21)


def d02():
    """Jakob stays: a works gate at night; a journeyman walks to purple lanterns; the old master watches."""
    im = grad((20, 22, 44), (52, 54, 80))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 600, W, H], fill=(176, 182, 196))
    d.rectangle([560, 200, 600, 600], fill=(70, 60, 50))                                  # the gate's posts
    d.rectangle([760, 200, 800, 600], fill=(70, 60, 50))
    d.rectangle([560, 190, 800, 220], fill=(60, 50, 40))
    for x in range(40, 480, 140):
        cart(d, x, 560, 1.0)
    for x in (1020, 1100, 1180):
        figure(d, x, 560, PURPLE, 90)                                                     # the Crown's men
        glow(im, x + 15, 540, 34, (255, 210, 120), 0.6)
        d = ImageDraw.Draw(im)
    figure(d, 860, 560, (120, 100, 70), 120)                                              # Jakob, apron, walking away
    d.rectangle([862, 600, 888, 660], fill=(170, 140, 100))
    figure(d, 430, 520, (110, 60, 40), 150)                                               # Hollweg, hand half raised
    d.line([(460, 560), (520, 520)], fill=(110, 60, 40), width=12)
    snow(im, 700, 22)
    return paint(im, 22)


def d03():
    """The road: a frozen valley at dawn, carts and automata going west, riders with nets on the slope, red city far east."""
    im = grad((150, 140, 170), (236, 200, 170))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 420), (420, 300), (860, 360), (W, 280), (W, H), (0, H)], fill=(200, 206, 216))   # the valley's snow
    d.polygon([(0, 520), (300, 430), (640, 470), (0, 700)], fill=(120, 130, 140))         # the north slope
    glow(im, 1180, 300, 90, (255, 90, 50), 0.6)                                           # Nuremberg, red, far east
    d = ImageDraw.Draw(im)
    for x in (1140, 1170, 1200):
        d.rectangle([x, 270, x + 20, 320], fill=(110, 40, 30))
    for i in range(6):
        x = 380 + i * 130
        cart(d, x, 600 - i * 6, 0.9)
        machine(d, x - 30, 650 - i * 6, BLUE, 1.2)
    for i in range(4):
        x, y = 140 + i * 70, 470 + i * 24
        d.ellipse([x, y + 20, x + 60, y + 50], fill=(70, 50, 36))                         # the riders' horses
        figure(d, x + 18, y - 20, PURPLE, 40)
        d.line([(x + 40, y - 10), (x + 90, y + 20)], fill=(200, 190, 160), width=3)       # nets
    snow(im, 400, 23)
    return paint(im, 23)


def d04():
    """The ships: a grey harbour, families and crated machines up the gangways of two tall ships, Hollweg at the rail."""
    im = grad((120, 130, 146), (176, 184, 194))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 520, W, H], fill=(80, 96, 110))                                       # the harbour water
    d.rectangle([0, 640, 520, H], fill=(110, 100, 90))                                    # the quay
    for (x, w) in [(480, 380), (880, 340)]:
        d.polygon([(x, 440), (x + w, 440), (x + w - 40, 560), (x + 30, 560)], fill=(70, 50, 36))   # hulls
        for m in range(3):
            mx = x + 60 + m * (w // 3)
            d.rectangle([mx, 120, mx + 10, 440], fill=(60, 44, 30))
            d.rectangle([mx - 60, 170, mx + 70, 260], fill=(214, 210, 196))
    d.line([(420, 640), (520, 470)], fill=(110, 80, 50), width=10)                       # the gangway
    for i in range(4):
        figure(d, 300 + i * 40, 600 - i * 10, BLUE, 60)
    d.rectangle([150, 600, 260, 650], fill=(130, 96, 60))                                # crated machines
    figure(d, 640, 380, (110, 60, 40), 60)                                                # Hollweg at the rail
    rnd = random.Random(24)
    for _ in range(14):                                                                   # gulls
        x, y = rnd.uniform(0, W), rnd.uniform(40, 300)
        d.arc([x, y, x + 20, y + 10], 200, 340, fill=(240, 240, 240), width=2)
    return paint(im, 24)


for i, fn in enumerate([d01, d02, d03, d04], 1):
    p = os.path.join(OUT, "d02_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
