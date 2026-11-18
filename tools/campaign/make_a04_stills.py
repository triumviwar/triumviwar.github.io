#!/usr/bin/env python3
"""STAND-IN stills for Act 1's "Father Ferrer's Visit" (campaign/stills/a04_01.jpg .. a04_05.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_a04_build.md "Stills"). Drawn simply, as a02's
(tools/campaign/make_a02_stills.py, whose small helpers are copied here: that script draws its own stills when run):
  a01 the arrival     = autumn at Fürth: a town of gears round a brass tower; a Jesuit in black with two lay brothers and
                        purple musketeers at the gate, Hollweg come to meet them
  a02 the inspection  = a workshop: a small brass Winder winding another; Ferrer writing in his notebook, Hollweg beside
  a03 the night shift = night by a river: blue-plated automata in a ring on a patch of gears nobody laid; Ferrer and the
                        brothers watching from behind crates with a shaded lantern
  a04 the riot        = dawn over water meadows: automata, their plates turning red, walking east; purple musketeers firing;
                        a tall Pendulum swinging through them at a bridge
  a05 the broken ones = the yard: stopped automata laid in rows; Ferrer and Hollweg face to face over them
The King's pages reuse c01_01 (the King in Rome).
Rebuild: python3 tools/campaign/make_a04_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
BLUE, RED, PURPLE, BLACK = (60, 96, 180), (180, 40, 36), (96, 50, 130), (28, 26, 30)


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


def leaves(im, n=500, seed=4):
    rnd = random.Random(seed)
    d = ImageDraw.Draw(im)
    for _ in range(n):
        x, y, r = rnd.uniform(0, W), rnd.uniform(H * 0.55, H), rnd.uniform(2, 5)
        d.ellipse([x - r, y - r * 0.6, x + r, y + r * 0.6], fill=rnd.choice([(196, 110, 40), (220, 150, 50), (160, 70, 30)]))


def a01():
    """The arrival: autumn at Fürth, a town of gears round a brass tower; Ferrer's party at the gate, Hollweg meeting them."""
    im = grad((170, 150, 130), (220, 196, 160))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 520, W, H], fill=(130, 110, 70))
    d.rectangle([540, 120, 720, 520], fill=(186, 146, 72))                               # the Honest One
    for y in range(160, 500, 70):
        d.rectangle([558, y, 702, y + 40], fill=BLUE)
    d.polygon([(520, 120), (630, 40), (740, 120)], fill=(150, 112, 56))
    rnd = random.Random(41)
    for i in range(9):                                                                    # the town of gears
        x, y, r = rnd.randint(80, 1200), rnd.randint(380, 500), rnd.randint(30, 70)
        gear(d, x, y, r, (190, 150, 74), rnd.randint(8, 12), BLUE)
    leaves(im, 600, 41)
    d = ImageDraw.Draw(im)
    figure(d, 300, 560, BLACK, 140)                                                       # Ferrer in black
    figure(d, 250, 580, (90, 70, 50), 120)                                                # the lay brothers
    figure(d, 350, 580, (90, 70, 50), 120)
    for i in range(5):
        figure(d, 60 + i * 34, 600, PURPLE, 100)                                          # the escort
    figure(d, 820, 570, (110, 60, 40), 130)                                               # Hollweg meeting them
    return paint(im, 41)


def a02():
    """The inspection: a Winder winding another; Ferrer writes in his notebook, Hollweg beside him."""
    im = grad((60, 46, 36), (110, 84, 60))
    d = ImageDraw.Draw(im)
    for x in range(0, W, 100):
        d.line([(x, 0), (x, H)], fill=(70, 52, 38), width=6)
    d.rectangle([0, 620, W, H], fill=(80, 62, 44))
    gear(d, 900, 260, 160, (190, 150, 74), 18, (140, 110, 60))
    machine(d, 520, 470, BLUE, 3.4)                                                       # the Winder winding...
    machine(d, 720, 500, BLUE, 3.0)                                                       # ...another
    d.line([(600, 560), (720, 560)], fill=(220, 190, 110), width=10)                      # its key in the other's back
    glow(im, 680, 560, 60, (255, 220, 140), 0.5)
    d = ImageDraw.Draw(im)
    figure(d, 200, 460, BLACK, 170)                                                       # Ferrer, the notebook
    d.rectangle([228, 530, 262, 556], fill=(236, 230, 210))
    figure(d, 1030, 470, (110, 60, 40), 160)                                              # Hollweg
    return paint(im, 42)


def a03():
    """The night shift: blue-plated automata in a ring on gears nobody laid, by a river; watchers behind crates."""
    im = grad((14, 18, 36), (34, 40, 70))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 560, W, H], fill=(28, 34, 46))
    d.rectangle([0, 700, W, H], fill=(40, 56, 90))                                        # the river
    for (x, y, r) in [(640, 600, 120), (520, 640, 60), (760, 640, 70), (640, 690, 50)]:  # the gears nobody laid
        gear(d, x, y, r, (120, 96, 54), 12, (70, 56, 40))
    for i in range(8):                                                                    # the ring of automata
        a = math.radians(i * 45)
        machine(d, 630 + math.cos(a) * 200, 560 + math.sin(a) * 70, BLUE, 1.8)
    glow(im, 640, 600, 220, (120, 150, 255), 0.18)
    d = ImageDraw.Draw(im)
    d.rectangle([60, 600, 300, 700], fill=(70, 54, 36))                                    # the crates
    figure(d, 120, 520, BLACK, 90)
    figure(d, 180, 530, (60, 50, 40), 80)
    glow(im, 240, 560, 40, (255, 190, 90), 0.6)                                           # the shaded lantern
    return paint(im, 43)


def a04():
    """The riot: automata turning red, walking east across the meadows; purple muskets firing; a Pendulum at the bridge."""
    im = grad((170, 120, 110), (226, 190, 160))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 480, W, H], fill=(120, 116, 80))
    d.rectangle([0, 600, 520, 650], fill=(110, 140, 170))                                 # the river and the bridge
    d.rectangle([300, 580, 420, 610], fill=(120, 96, 70))
    rnd = random.Random(44)
    for i in range(16):
        x = 380 + i * 50 + rnd.randint(-14, 14)
        machine(d, x, 520 + rnd.randint(0, 90), RED if i % 3 else BLUE, 1.1)
    d.rectangle([330, 300, 380, 580], fill=(180, 140, 70))                               # the Pendulum
    d.line([(355, 320), (230, 470)], fill=(160, 120, 60), width=12)
    d.polygon([(200, 450), (260, 470), (210, 500)], fill=(220, 220, 230))
    for i in range(6):
        figure(d, 40 + i * 34, 560, PURPLE, 70)
    glow(im, 260, 540, 60, (255, 240, 200), 0.4)
    return paint(im, 44)


def a05():
    """The broken ones in the yard: stopped automata in rows; Ferrer and Hollweg face to face over them."""
    im = grad((190, 180, 170), (230, 220, 200))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 500, W, H], fill=(140, 120, 90))
    for r in range(3):
        for i in range(8):
            x, y = 260 + i * 100 + r * 20, 600 + r * 70
            d.rectangle([x, y, x + 70, y + 26], fill=(170, 130, 64))                     # lying down
            d.rectangle([x + 20, y + 6, x + 40, y + 20], fill=RED if (i + r) % 2 else BLUE)
    figure(d, 160, 420, BLACK, 180)                                                       # Ferrer
    figure(d, 1080, 420, (110, 60, 40), 180)                                              # Hollweg
    glow(im, 640, 300, 300, (255, 120, 40), 0.2)                                          # the furnace's light behind
    return paint(im, 45)


for i, fn in enumerate([a01, a02, a03, a04, a05], 1):
    p = os.path.join(OUT, "a04_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
