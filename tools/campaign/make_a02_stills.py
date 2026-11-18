#!/usr/bin/env python3
"""STAND-IN stills for Act 1's "The Fürth Line" (campaign/stills/a02_01.jpg .. a02_05.jpg, 1280 x 853), until the owner's
ChatGPT paintings come (the prompts: docs/campaign_a02_build.md "Stills"). Drawn simply, as the Clockwork prologue's
(tools/campaign/make_c01_stills.py, whose small helpers are copied here):
  a01 the barn     = the guild in exile: a barn workshop at Fürth, the brass map, Nuremberg's red towers through the door
  a02 the Honest One = a new brass tower with blue plates, Hollweg on a ladder fitting the stop-work, a commissary watching
  a03 the sortie   = red machines out of Nuremberg's gate across the meadows toward a purple line on the earthworks
  a04 the mill     = the Rednitz mill grown over with red gears, catching fire; blue soldiers and purple musketeers
  a05 the line holds = dawn over the earthworks, Hollweg from behind looking east at the red towers
The opening and the King's pages reuse c01_01 (the King in Rome).
Rebuild: python3 tools/campaign/make_a02_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853


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


def snow(im, n=900, seed=3, a=150):
    rnd = random.Random(seed)
    lay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    for _ in range(n):
        x, y, r = rnd.uniform(0, W), rnd.uniform(0, H), rnd.uniform(1, 3.2)
        d.ellipse([x - r, y - r, x + r, y + r], fill=(255, 255, 255, a))
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


def houses(d, y0, seed, light=(255, 196, 110), dark=(30, 34, 52), n=11, hmax=180):
    rnd = random.Random(seed)
    x = -20
    while x < W:
        w = rnd.randint(70, 130)
        h = rnd.randint(90, hmax)
        d.rectangle([x, y0 - h, x + w, y0], fill=dark)
        d.polygon([(x - 6, y0 - h), (x + w / 2, y0 - h - w * 0.8), (x + w + 6, y0 - h)], fill=(120, 52, 40))
        d.polygon([(x - 6, y0 - h), (x + w / 2, y0 - h - w * 0.8), (x + w / 2, y0 - h - w * 0.8 + 14), (x + 4, y0 - h + 6)],
                  fill=(232, 238, 250))         # the snow on the roof
        for wy in range(y0 - h + 20, y0 - 20, 38):
            for wx in range(x + 12, x + w - 16, 30):
                if rnd.random() < 0.6:
                    d.rectangle([wx, wy, wx + 12, wy + 16], fill=light)
        x += w + rnd.randint(4, 18)




def figure(d, x, y, coat, h=110, face=(220, 190, 160)):
    """A small standing person: a coat and a head."""
    d.rectangle([x, y, x + 30, y + h], fill=coat)
    d.ellipse([x, y - 32, x + 30, y - 2], fill=face)


def machine(d, x, y, plate, s=1.0):
    """A small brass construct with its enamel plate (blue: the guild's; red: the Machine's)."""
    d.rectangle([x, y, x + 24 * s, y + 38 * s], fill=(182, 142, 70))
    d.rectangle([x + 5 * s, y + 7 * s, x + 19 * s, y + 18 * s], fill=plate)


BLUE, RED, PURPLE = (60, 96, 180), (180, 40, 36), (96, 50, 130)


def red_towers(d, y0, x0=780, n=6, seed=9, col=(120, 46, 40)):
    """Nuremberg on the skyline: red towers and the castle."""
    rnd = random.Random(seed)
    for i in range(n):
        x = x0 + i * 80 + rnd.randint(-10, 10)
        h = rnd.randint(70, 170)
        d.rectangle([x, y0 - h, x + 36, y0], fill=col)
        d.polygon([(x - 6, y0 - h), (x + 18, y0 - h - 44), (x + 42, y0 - h)], fill=(90, 32, 30))


def a01():
    """The guild in exile: a barn workshop at Fürth, the brass map on a trestle, Nuremberg's red towers through the door."""
    im = grad((40, 30, 24), (70, 52, 36))
    d = ImageDraw.Draw(im)
    for x in range(0, W, 90):                                                             # the barn's planks
        d.line([(x, 0), (x, H)], fill=(52, 38, 28), width=6)
    d.polygon([(0, 0), (W // 2, -60), (W, 0), (W, 90), (W // 2, 30), (0, 90)], fill=(36, 26, 20))  # the roof beams
    d.rectangle([760, 170, 1180, 640], fill=(150, 168, 200))                              # the open door: a cold sky
    d.rectangle([760, 520, 1180, 640], fill=(210, 220, 236))                              # snow outside
    red_towers(d, 520, 790, 5)
    d.rectangle([760, 170, 780, 640], fill=(46, 34, 26))
    d.rectangle([1160, 170, 1180, 640], fill=(46, 34, 26))
    d.rectangle([0, 640, W, H], fill=(60, 46, 32))                                       # the floor, straw
    d.rectangle([140, 470, 620, 500], fill=(110, 80, 50))                                 # the trestle and the brass map
    d.line([(180, 500), (160, 650)], fill=(90, 66, 40), width=12)
    d.line([(580, 500), (600, 650)], fill=(90, 66, 40), width=12)
    gear(d, 380, 430, 120, (200, 160, 80), 16, (150, 116, 60))
    gear(d, 250, 450, 50, (190, 150, 74), 9, BLUE)
    glow(im, 380, 380, 220, (255, 196, 110), 0.35)
    d = ImageDraw.Draw(im)
    figure(d, 660, 520, (110, 60, 40), 120)                                              # Hollweg by the door
    figure(d, 610, 540, (70, 60, 50), 100)                                               # Jakob
    machine(d, 470, 600, BLUE, 1.2)
    return paint(im, 21)


def a02():
    """The Honest One: a new brass tower with blue plates; Hollweg on a ladder fitting the stop-work; a purple officer."""
    im = grad((150, 170, 200), (226, 232, 244))
    d = ImageDraw.Draw(im)
    houses(d, 540, 23, light=(120, 110, 90), dark=(84, 88, 104), hmax=200)
    d.rectangle([0, 540, W, H], fill=(214, 220, 228))
    d.rectangle([0, 700, W, H], fill=(120, 104, 80))                                     # mud where the snow melts
    d.rectangle([520, 110, 740, 640], fill=(186, 146, 72))                                # the Honest One
    for y in range(150, 600, 70):
        d.rectangle([540, y, 720, y + 40], fill=BLUE)
    d.polygon([(500, 110), (630, 30), (760, 110)], fill=(150, 112, 56))
    d.ellipse([594, 54, 666, 104], fill=(240, 226, 170))
    gear(d, 470, 610, 80, (196, 150, 72), 12, BLUE)
    gear(d, 790, 616, 64, (196, 150, 72), 10, BLUE)
    d.line([(760, 640), (800, 300)], fill=(90, 66, 40), width=8)                         # the ladder
    d.line([(800, 640), (840, 300)], fill=(90, 66, 40), width=8)
    for y in range(320, 640, 40):
        d.line([(762 + (640 - y) * 0.12, y), (802 + (640 - y) * 0.12, y)], fill=(90, 66, 40), width=5)
    figure(d, 800, 330, (110, 60, 40), 90)                                               # Hollweg on it
    glow(im, 760, 360, 40, (255, 230, 160), 0.6)                                         # the stop-work, shining
    d = ImageDraw.Draw(im)
    figure(d, 980, 560, PURPLE, 120)                                                     # the commissary watching
    return paint(im, 22)


def a03():
    """The sortie: red machines pour out of a red city's gate across wet meadows toward a purple line on earthworks."""
    im = grad((90, 100, 130), (170, 170, 180))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 430, W, H], fill=(110, 120, 96))                                     # the meadows
    d.rectangle([0, 600, W, 640], fill=(140, 160, 190))                                  # the river
    red_towers(d, 430, 900, 5, 31)
    d.rectangle([880, 330, 1280, 430], fill=(120, 46, 40))                               # the walls and the gate
    d.rectangle([1040, 360, 1100, 430], fill=(30, 20, 20))
    glow(im, 1070, 400, 70, (220, 60, 40), 0.4)
    d = ImageDraw.Draw(im)
    rnd = random.Random(33)
    for i in range(26):                                                                   # the red tide
        x = 1040 - i * 26 + rnd.randint(-20, 20)
        y = 450 + rnd.randint(0, 120)
        machine(d, x, y, RED, 0.9)
    d.polygon([(0, 560), (220, 520), (240, 600), (0, 640)], fill=(96, 80, 56))           # the earthworks
    for i in range(7):                                                                    # the purple line
        figure(d, 30 + i * 30, 470 + i * 6, PURPLE, 60)
    d.line([(60, 700), (200, 520)], fill=(240, 240, 240), width=2)
    return paint(im, 23)


def a04():
    """The Rednitz mill at dusk, a red seed tower grown into it; blue soldiers and purple musketeers come to burn it."""
    im = grad((40, 34, 60), (140, 90, 80))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 560, W, H], fill=(60, 66, 60))
    d.rectangle([0, 700, W, H], fill=(70, 90, 120))                                      # the Rednitz
    d.polygon([(520, 560), (560, 260), (700, 260), (740, 560)], fill=(80, 70, 66))       # the mill
    for a in range(0, 360, 90):                                                           # its sails
        r = math.radians(a + 20)
        d.line([(630, 260), (630 + math.cos(r) * 230, 260 + math.sin(r) * 230)], fill=(70, 56, 44), width=12)
    rnd = random.Random(44)
    for i in range(12):                                                                   # the red gears over it
        x, y, r = rnd.randint(470, 800), rnd.randint(320, 600), rnd.randint(24, 64)
        gear(d, x, y, r, (170, 120, 60), rnd.randint(8, 12), RED)
        glow(im, x, y, r * 1.4, (230, 70, 40), 0.15)
        d = ImageDraw.Draw(im)
    glow(im, 640, 520, 200, (255, 120, 40), 0.35)                                        # it is catching fire
    d = ImageDraw.Draw(im)
    for i in range(5):
        machine(d, 80 + i * 60, 600 + (i % 2) * 20, BLUE, 1.1)
    for i in range(4):
        figure(d, 1000 + i * 50, 590, PURPLE, 80)
    return paint(im, 24)


def a05():
    """The line holds: dawn over the earthworks; Hollweg from behind, looking east at the red towers."""
    im = grad((180, 150, 140), (230, 210, 190))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 500, W, H], fill=(160, 150, 130))
    red_towers(d, 500, 760, 7, 55, (150, 70, 60))
    d.polygon([(0, 640), (W, 580), (W, 660), (0, 720)], fill=(100, 84, 60))              # the earthworks
    for x in range(40, W, 46):                                                            # the palisade
        top = 600 - (x * 60) // W
        d.rectangle([x, top, x + 14, top + 50], fill=(80, 60, 40))
    d.rectangle([440, 540, 490, 720], fill=(110, 60, 40))                                 # Hollweg, from behind
    d.ellipse([446, 500, 484, 540], fill=(150, 150, 150))
    for i in range(3):
        figure(d, 700 + i * 40, 600, PURPLE, 70)
    machine(d, 560, 660, BLUE, 1.1)
    return paint(im, 25)


for i, fn in enumerate([a01, a02, a03, a04, a05], 1):
    p = os.path.join(OUT, "a02_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
