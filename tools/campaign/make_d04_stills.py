#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The City of Gears" (campaign/stills/d04_01.jpg .. d04_05.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_d04_build.md "Stills", from docs/campaign_act2_plan.md). Drawn
simply, as the earlier missions' (the small helpers are d02's, tools/campaign/make_d02_stills.py, copied here):
  d04_01 the mine on the highlands = a grassy plateau, araucarias, spoil heaps, a clocktower half raised, tents
  d04_02 the valley's fear         = night on the road: colonists with torches, automata with shields, a priest between
  d04_03 the crates                = a mine gallery by lantern light, two opened crates, gear plates creeping
  d04_04 concord                   = the new town at sunset, its clocktower; Hollweg and the exile looking at it
  d04_05 the exile                 = (a06 Varenne spared) a ship at a river landing, a lean man in black comes ashore
The King's pages reuse c01_01 (the King in Rome).
Rebuild: python3 tools/campaign/make_d04_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
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



def araucaria(d, x, y, s=1.0):
    """A Paraná pine: a tall bare trunk and a flat umbrella crown."""
    d.rectangle([x - 4 * s, y - 160 * s, x + 4 * s, y], fill=(96, 62, 44))
    for k in range(3):
        yy = y - 160 * s - k * 14 * s
        w = (90 - k * 22) * s
        d.chord([x - w, yy - 22 * s, x + w, yy + 22 * s], 180, 360, fill=(46, 72, 50))


def tower(d, x, y, s=1.0, done=1.0):
    """A brass clocktower (half raised when done < 1)."""
    h = 300 * s * done
    d.rectangle([x, y - h, x + 70 * s, y], fill=(176, 136, 66))
    if done >= 1.0:
        d.polygon([(x - 10 * s, y - h), (x + 35 * s, y - h - 70 * s), (x + 80 * s, y - h)], fill=(120, 90, 50))
        d.ellipse([x + 12 * s, y - h + 20 * s, x + 58 * s, y - h + 66 * s], fill=(236, 226, 196))
    else:
        for i in range(4):
            d.line([(x - 20 * s + i * 30 * s, y - h), (x - 20 * s + i * 30 * s, y - h - 60 * s)], fill=(120, 96, 60), width=3)


def d01():
    """The mine on the highlands: a grassy plateau, araucarias, red earth, spoil heaps, a clocktower half raised by tall
    machines, families in blue putting up tents."""
    im = grad((140, 176, 214), (226, 232, 236))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 520), (500, 470), (W, 500), (W, H), (0, H)], fill=(150, 160, 96))     # the cold grass
    d.polygon([(700, 560), (1280, 540), (1280, 700), (760, 680)], fill=(120, 60, 54))     # terra roxa by the mine
    for (x, y, r) in [(980, 560, 110), (1160, 540, 90), (880, 590, 70)]:                 # spoil heaps
        d.chord([x - r, y - r * 0.8, x + r, y + r * 0.8], 180, 360, fill=(118, 116, 112))
    for x in (90, 260, 1210):
        araucaria(d, x, 560, 1.2)
    tower(d, 640, 600, 1.0, 0.55)
    for x in (560, 760):
        machine(d, x, 520, BLUE, 3.0)                                                     # tall machines lifting
    for i, x in enumerate([160, 300, 420]):
        d.polygon([(x, 700), (x + 50, 620), (x + 100, 700)], fill=(214, 210, 196))      # tents
        figure(d, x + 110, 650, BLUE, 70)
    return paint(im, 41)


def d02():
    """The valley's fear: night on a cart road up a hill; colonists with torches stop before brass automata with
    shields; a country priest in black between them with raised hands."""
    im = grad((18, 22, 44), (60, 54, 70))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 700), (640, 520), (W, 470), (W, H), (0, H)], fill=(70, 66, 56))      # the road up
    for i in range(7):
        x = 120 + i * 60
        figure(d, x, 620 - i * 6, (110, 96, 70), 90)                                      # the colonists
        glow(im, x + 15, 580 - i * 6, 40, (255, 150, 60), 0.7)                             # their torches
        d = ImageDraw.Draw(im)
        d.line([(x + 15, 600 - i * 6), (x + 15, 570 - i * 6)], fill=(90, 60, 30), width=5)
    for i in range(4):
        x = 860 + i * 90
        machine(d, x, 520, BLUE, 2.4)
        d.rectangle([x - 14, 540, x + 4, 600], fill=(150, 120, 60))                       # shields
    figure(d, 650, 560, BLACK, 120)                                                       # the priest
    d.line([(650, 590), (610, 530)], fill=BLACK, width=10)
    d.line([(680, 590), (720, 530)], fill=BLACK, width=10)
    return paint(im, 42)


def d03():
    """The crates: a dark mine gallery by lantern light, an old clockmaker kneeling by two opened crates stamped with a
    gear; brass parts gleam; a thin line of gear plates has crept across the rock floor."""
    im = grad((20, 18, 16), (52, 44, 36))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 640), (W, 600), (W, H), (0, H)], fill=(70, 62, 54))                  # the rock floor
    glow(im, 520, 380, 220, (255, 200, 110), 0.55)                                         # the lantern
    d = ImageDraw.Draw(im)
    for x in (420, 640):
        d.rectangle([x, 520, x + 180, 660], fill=(110, 80, 50))                           # the crates
        gear(d, x + 90, 590, 34, (90, 64, 40))                                            # the gear seal
        d.rectangle([x + 10, 500, x + 170, 530], fill=(196, 156, 80))                     # brass parts showing
    figure(d, 300, 560, (110, 60, 40), 100)                                               # Hollweg kneeling
    for i in range(9):                                                                    # the plates creeping
        gear(d, 860 + i * 44, 690 + (i % 2) * 10, 18, (170, 132, 64))
    return paint(im, 43)


def d04():
    """Concord: a new town of timber and brass on a highland plateau at sunset, a clocktower over it; an old
    clockmaker and a lean man in sober black stand together looking at it."""
    im = grad((240, 170, 110), (120, 90, 110))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 560), (W, 520), (W, H), (0, H)], fill=(96, 100, 70))
    for i in range(8):
        x = 460 + i * 80
        d.rectangle([x, 470 - (i % 3) * 20, x + 60, 560], fill=(120, 88, 60))           # timber houses
        d.polygon([(x - 6, 470 - (i % 3) * 20), (x + 30, 430 - (i % 3) * 20), (x + 66, 470 - (i % 3) * 20)], fill=(150, 110, 60))
    tower(d, 780, 520, 1.0, 1.0)
    araucaria(d, 1200, 560, 1.0)
    figure(d, 180, 600, (110, 60, 40), 150)                                               # Hollweg
    figure(d, 250, 590, BLACK, 160)                                                       # the exile
    return paint(im, 44)


def d05():
    """The exile: a ship from Lisbon at a river landing below the highlands; a lean man in black with a small bag comes
    down the gangway; a blue-coated guildsman waits on the bank."""
    im = grad((170, 190, 210), (220, 214, 200))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 540, W, H], fill=(90, 110, 120))                                      # the river
    d.rectangle([0, 660, 560, H], fill=(120, 104, 84))                                    # the landing
    d.polygon([(620, 440), (1100, 440), (1060, 560), (650, 560)], fill=(70, 50, 36))      # the hull
    for m in range(2):
        mx = 720 + m * 200
        d.rectangle([mx, 160, mx + 10, 440], fill=(60, 44, 30))
        d.rectangle([mx - 60, 210, mx + 70, 300], fill=(214, 210, 196))
    d.line([(520, 660), (640, 520)], fill=(110, 80, 50), width=10)                       # the gangway
    figure(d, 560, 570, BLACK, 90)                                                        # Varenne coming down
    figure(d, 300, 600, BLUE, 100)                                                        # a guildsman waiting
    araucaria(d, 120, 660, 0.9)
    return paint(im, 45)


for i, fn in enumerate([d01, d02, d03, d04, d05], 1):
    p = os.path.join(OUT, "d04_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
