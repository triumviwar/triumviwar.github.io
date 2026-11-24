#!/usr/bin/env python3
"""STAND-IN stills for Act 2's second crossing, "Between Two Fires" (campaign/stills/d09_01.jpg .. d09_03.jpg, 1280 x 853),
until the owner's ChatGPT paintings come (the prompts: docs/campaign_d09_build.md "Stills"). Drawn simply, with d05's
helpers (tools/campaign/make_d05_stills.py, copied here). THE BROOD IS NOT A PERSON: animals, drawn as animals.
  d09_01 the army of Brazil = a long column in purple coats, cuirassiers in breastplates and powder wagons through dry
                              thorny scrub and cactus under a white sky; a general on a grey horse; a priest by the guns
  d09_02 two skies          = over a dry red plain brass birds from the left and green winged reptiles from the right
                              fighting in the sky; soldiers below look up
  d09_03 the council of war = a whitewashed fort's room lit by lamps: a grey-haired general of artillery over a map, a
                              priest beside him, two messengers in the doorway (one dusty, one lean in black, a white flag)
The King's pages reuse p01_01 (the King lighting his pipe).
Rebuild: python3 tools/campaign/make_d09_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
PURPLE, BLACK, GREEN = (96, 50, 130), (28, 26, 30), (64, 120, 56)
BRASS = (196, 152, 70)
EARTH = (168, 92, 52)
SCRUB = (96, 92, 60)


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


def figure(d, x, y, coat, h=110, face=(220, 190, 160), plate=False):
    d.rectangle([x, y, x + 30, y + h], fill=coat)
    if plate:
        d.rectangle([x + 2, y + 6, x + 28, y + h * 0.45], fill=(170, 172, 178))      # a breastplate
    d.ellipse([x, y - 32, x + 30, y - 2], fill=face)


def scrub(d, y0, y1, n, seed):
    """Caatinga: thorny grey-green bushes and mandacaru cactus on red earth."""
    rnd = random.Random(seed)
    for _ in range(n):
        x, y = rnd.uniform(0, W), rnd.uniform(y0, y1)
        if rnd.random() < 0.3:
            h = rnd.uniform(40, 90)
            c = (70, 110, 96)
            d.rectangle([x, y - h, x + 10, y], fill=c)                                      # the cactus' column
            d.rectangle([x - 14, y - h * 0.6, x - 8, y - h * 0.3], fill=c)
            d.rectangle([x + 16, y - h * 0.7, x + 22, y - h * 0.4], fill=c)
        else:
            r = rnd.uniform(14, 34)
            c = tuple(max(0, min(255, int(v * rnd.uniform(0.8, 1.15)))) for v in SCRUB)
            d.ellipse([x - r, y - r * 0.7, x + r, y + r * 0.4], fill=c)


def horse(d, x, y, col=(150, 150, 150), s=1.0):
    d.ellipse([x, y, x + 120 * s, y + 50 * s], fill=col)
    d.polygon([(x + 100 * s, y + 10 * s), (x + 150 * s, y - 20 * s), (x + 156 * s, y + 4 * s), (x + 116 * s, y + 30 * s)], fill=col)
    for lx in (14, 40, 80, 104):
        d.line([(x + lx * s, y + 40 * s), (x + lx * s, y + 84 * s)], fill=tuple(int(v * 0.7) for v in col), width=max(3, int(6 * s)))


def cannon(d, x, y, s=1.0):
    d.rectangle([x, y, x + 90 * s, y + 16 * s], fill=(40, 40, 44))
    d.ellipse([x + 10 * s, y + 6 * s, x + 46 * s, y + 42 * s], fill=(90, 60, 36))


def wagon(d, x, y, s=1.0):
    d.rectangle([x, y, x + 110 * s, y + 50 * s], fill=(120, 90, 56))
    d.chord([x - 4 * s, y - 36 * s, x + 114 * s, y + 20 * s], 180, 360, fill=(220, 214, 196))    # the canvas
    for wx in (16, 84):
        d.ellipse([x + (wx - 14) * s, y + 36 * s, x + (wx + 14) * s, y + 64 * s], fill=(70, 50, 30))


def brass_bird(d, x, y, s=1.0):
    d.ellipse([x, y, x + 40 * s, y + 16 * s], fill=BRASS)
    d.polygon([(x + 12 * s, y + 6 * s), (x - 20 * s, y - 24 * s), (x + 22 * s, y + 2 * s)], fill=(170, 130, 60))
    d.polygon([(x + 28 * s, y + 6 * s), (x + 60 * s, y - 24 * s), (x + 26 * s, y + 2 * s)], fill=(170, 130, 60))
    d.ellipse([x + 14 * s, y + 3 * s, x + 24 * s, y + 13 * s], outline=(110, 80, 30), width=2)   # a cog on its breast


def green_flyer(d, x, y, s=1.0):
    d.ellipse([x, y, x + 46 * s, y + 14 * s], fill=GREEN)
    d.polygon([(x + 14 * s, y + 6 * s), (x - 30 * s, y - 30 * s), (x + 4 * s, y - 6 * s), (x + 26 * s, y + 4 * s)], fill=(54, 100, 50))
    d.polygon([(x + 30 * s, y + 6 * s), (x + 76 * s, y - 30 * s), (x + 44 * s, y - 6 * s), (x + 22 * s, y + 4 * s)], fill=(54, 100, 50))
    d.polygon([(x + 44 * s, y + 4 * s), (x + 62 * s, y - 2 * s), (x + 50 * s, y + 10 * s)], fill=GREEN)    # a beaked head


def d01():
    """The army of Brazil on the march through the sertão."""
    im = grad((238, 236, 226), (206, 150, 104))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 430), (300, 400), (700, 420), (1280, 390), (W, H), (0, H)], fill=EARTH)     # the red earth
    d.polygon([(860, 400), (960, 330), (1120, 330), (1200, 395)], fill=(178, 84, 52))        # a mesa far off
    scrub(d, 420, 560, 60, 91)
    d.polygon([(0, 640), (W, 560), (W, 640), (0, 720)], fill=(214, 172, 120))                 # the dusty road
    x = 1220
    for i in range(16):                                                                        # the column, westward
        y = 610 - i * 4
        if i in (4, 9):
            cannon(d, x - 60, y + 30, 0.9)
            x -= 120
        elif i == 12:
            wagon(d, x - 90, y + 10, 0.9)
            x -= 130
        else:
            figure(d, x, y, PURPLE, 90, plate=(i % 3 == 0))
            x -= 52
    horse(d, 260, 520, (160, 160, 164), 1.1)                                                   # the general on a grey horse
    figure(d, 320, 452, PURPLE, 70, face=(214, 196, 180))
    d.ellipse([318, 418, 352, 434], fill=(200, 200, 204))                                     # grey hair
    figure(d, 540, 600, BLACK, 100)                                                            # the priest by the guns
    scrub(d, 700, 840, 30, 92)
    return paint(im, 91)


def d02():
    """Two skies: brass birds from the left, green winged reptiles from the right, fighting over a red plain."""
    im = grad((236, 232, 220), (220, 190, 150))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 560), (W, 540), (W, H), (0, H)], fill=EARTH)
    scrub(d, 560, 700, 40, 93)
    rnd = random.Random(94)
    for _ in range(9):
        brass_bird(d, rnd.uniform(80, 640), rnd.uniform(90, 360), rnd.uniform(0.9, 1.4))
    for _ in range(9):
        green_flyer(d, rnd.uniform(620, 1180), rnd.uniform(80, 360), rnd.uniform(0.9, 1.4))
    for (x, y) in [(600, 230), (660, 180), (560, 300)]:
        glow(im, x, y, 26, (255, 230, 170), 0.6)                                               # where they meet
    d = ImageDraw.Draw(im)
    for i in range(7):                                                                         # soldiers below look up
        figure(d, 380 + i * 70, 640 + (i % 2) * 14, PURPLE, 90)
    return paint(im, 94)


def d03():
    """The council of war in the fort's room, by lamplight."""
    im = grad((70, 56, 44), (40, 32, 28))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, W, 560], fill=(196, 186, 164))                                          # whitewashed walls
    d.rectangle([0, 560, W, H], fill=(96, 70, 48))                                             # the floor
    d.rectangle([980, 200, 1160, 560], fill=(40, 34, 30))                                      # the doorway, dusk outside
    d.rectangle([990, 210, 1150, 400], fill=(190, 120, 80))
    d.rectangle([300, 470, 860, 520], fill=(110, 76, 44))                                      # the table
    d.polygon([(340, 470), (820, 470), (800, 440), (360, 440)], fill=(214, 196, 150))         # the map of Brazil
    d.polygon([(520, 446), (600, 444), (640, 462), (560, 468)], fill=(150, 170, 110))
    figure(d, 420, 330, PURPLE, 140, face=(214, 196, 180))                                     # the general
    d.ellipse([418, 296, 452, 312], fill=(210, 210, 214))
    figure(d, 640, 340, BLACK, 130)                                                            # the priest
    figure(d, 1010, 330, (150, 120, 90), 150)                                                  # the dusty rider from the jungle
    figure(d, 1090, 320, BLACK, 160, face=(206, 186, 170))                                     # the lean man in black
    d.line([(1124, 300), (1124, 180)], fill=(120, 100, 70), width=4)
    d.rectangle([1126, 180, 1180, 214], fill=(240, 240, 236))                                  # the white flag
    for (x, y) in [(330, 380), (840, 380)]:
        glow(im, x, y, 90, (255, 190, 110), 0.55)                                              # the lamps
    return paint(im, 95)


for i, fn in enumerate([d01, d02, d03], 1):
    p = os.path.join(OUT, "d09_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
