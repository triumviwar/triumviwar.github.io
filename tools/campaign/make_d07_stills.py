#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The Council of Gears" (campaign/stills/d07_01.jpg .. d07_05.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_d07_build.md "Stills", the first three from
docs/campaign_act2_plan.md). Drawn simply, as the earlier missions' (the small helpers are d04's, copied here):
  d07_01 the council of gears = a timber and brass hall, craftsmen on benches each with a small automaton at his shoulder
  d07_02 the streets turn     = night in a town of brass, lamps going red down a street, a young craftsman with a lantern
  d07_03 the great spring     = a huge coiled spring in a tower, an old clockmaker's hands on a great brake lever
  d07_04 the coast road       = (the spring stopped) families and carts on a road by the sea, a dead brass city behind
  d07_05 the red dawn         = (the spring running, or the machine's win) the city at dawn, every lamp red
The King's pages reuse c01_01 (the King in Rome).
Rebuild: python3 tools/campaign/make_d07_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
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
    """The council of gears: a council hall of timber and brass; craftsmen in blue on benches, each with a small brass
    automaton standing at his shoulder; an old clockmaker presides; a lean man in black speaks. Lamplight."""
    im = grad((40, 30, 22), (90, 66, 44))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 600, W, H], fill=(84, 60, 40))                                        # the floor
    for x in range(60, W, 180):
        d.rectangle([x, 120, x + 24, 600], fill=(70, 48, 30))                             # the timber posts
    glow(im, 640, 200, 260, (255, 200, 120), 0.45)                                         # the lamps
    d = ImageDraw.Draw(im)
    gear(d, 640, 170, 90, (176, 136, 66))                                                 # the council's gear over the chair
    figure(d, 625, 380, (110, 60, 40), 150)                                               # Hollweg presiding
    for i in range(6):
        x = 90 + i * 90 if i < 3 else 850 + (i - 3) * 110
        figure(d, x, 520, BLUE, 90)                                                       # the masters on the benches
        machine(d, x + 36, 500, (150, 40, 36), 1.4)                                       # an automaton at each shoulder
    figure(d, 380, 470, BLACK, 140)                                                       # the lean man speaking
    d.line([(395, 500), (440, 440)], fill=BLACK, width=10)
    return paint(im, 71)


def d02():
    """The streets turn: night in a town of brass; a street's lamps go red one after another; clockwork figures wind each
    other in a doorway; a young craftsman with a lantern watches from a corner."""
    im = grad((12, 14, 30), (40, 34, 46))
    d = ImageDraw.Draw(im)
    d.polygon([(0, H), (520, 520), (760, 520), (W, H)], fill=(60, 52, 44))                # the street
    for i in range(6):
        x = 40 + i * 70
        d.rectangle([x, 260 - i * 10, x + 60, 640 - i * 20], fill=(96, 74, 50))         # the houses, left
        d.rectangle([W - x - 60, 260 - i * 10, W - x, 640 - i * 20], fill=(96, 74, 50))   # and right
    for i in range(5):
        col = (255, 60, 40) if i < 3 else (255, 200, 120)                                 # the lamps going red
        glow(im, 200 + i * 60, 380 + i * 18, 34, col, 0.8)
        glow(im, W - 200 - i * 60, 380 + i * 18, 34, col, 0.8)
    d = ImageDraw.Draw(im)
    machine(d, 600, 520, RED, 2.2)                                                        # two machines winding each other
    machine(d, 660, 520, RED, 2.2)
    d.line([(624, 560), (660, 560)], fill=(196, 156, 80), width=6)
    figure(d, 1050, 600, BLUE, 110)                                                       # the young craftsman
    glow(im, 1090, 640, 50, (255, 210, 130), 0.7)                                          # his lantern
    return paint(im, 72)


def d03():
    """The great spring: inside a tall tower a huge coiled brass spring fills the space; an old clockmaker with both
    hands on a great iron brake lever; craftsmen in blue behind him shouting."""
    im = grad((36, 28, 20), (80, 60, 40))
    d = ImageDraw.Draw(im)
    cx, cy = 760, 360
    for k in range(14, 0, -1):                                                            # the coil
        r = 24 * k
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(196 - k * 4, 156 - k * 3, 80), width=12)
    glow(im, cx, cy, 200, (255, 190, 110), 0.25)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 680, W, H], fill=(70, 56, 42))
    d.line([(300, 700), (420, 430)], fill=(60, 60, 66), width=26)                         # the brake lever
    d.ellipse([400, 410, 444, 454], fill=(90, 90, 96))
    figure(d, 260, 560, (110, 60, 40), 140)                                               # Hollweg at the brake
    d.line([(280, 590), (410, 450)], fill=(110, 60, 40), width=12)
    for i in range(3):
        figure(d, 60 + i * 60, 590, BLUE, 100)                                            # the masters behind him
    return paint(im, 73)


def d04():
    """The coast road: families in blue and two carts of tools on a road by a grey sea; behind them, on the highlands, a
    silent city of brass with a tower, no lamp lit."""
    im = grad((150, 166, 182), (206, 206, 196))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 470, W, 600], fill=(96, 116, 130))                                    # the sea
    d.polygon([(700, 470), (W, 380), (W, 470)], fill=(110, 110, 90))                     # the highlands behind
    for i in range(6):
        d.rectangle([900 + i * 50, 380 - (i % 3) * 20, 940 + i * 50, 470], fill=(140, 120, 80))   # the dead city
    tower(d, 1080, 470, 0.5, 1.0)
    d.polygon([(0, H), (0, 640), (W, 600), (W, H)], fill=(126, 112, 86))                  # the road
    for i in range(5):
        figure(d, 120 + i * 120, 640, BLUE, 90)                                           # the families
    for x in (760, 960):
        d.rectangle([x, 660, x + 140, 720], fill=(110, 80, 50))                           # the carts of tools
        d.ellipse([x + 10, 710, x + 50, 750], fill=(60, 44, 30))
        d.ellipse([x + 90, 710, x + 130, 750], fill=(60, 44, 30))
    return paint(im, 74)


def d05():
    """The red dawn: the city of brass on its hill at a grey dawn, every lamp red, the great spring's tower over the mine;
    no person in the streets."""
    im = grad((90, 80, 96), (180, 150, 130))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 560), (500, 420), (W, 400), (W, H), (0, H)], fill=(96, 90, 70))
    for i in range(10):
        x = 120 + i * 105
        d.rectangle([x, 470 - (i % 4) * 25, x + 70, 600], fill=(130, 100, 64))
        glow(im, x + 35, 500 - (i % 4) * 25, 22, (255, 50, 40), 0.8)                      # every lamp red
        d = ImageDraw.Draw(im)
    tower(d, 900, 430, 1.0, 1.0)
    gear(d, 935, 300, 40, (190, 60, 40))
    return paint(im, 75)


for i, fn in enumerate([d01, d02, d03, d04, d05], 1):
    p = os.path.join(OUT, "d07_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
