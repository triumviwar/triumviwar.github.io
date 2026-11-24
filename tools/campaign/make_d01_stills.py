#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The Gold of Vila Rica" (campaign/stills/d01_01.jpg .. d01_04.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_d01_build.md "Stills", from docs/campaign_act2_plan.md). Drawn
simply, as the earlier missions' (the small helpers are d04's, tools/campaign/make_d04_stills.py, copied here):
  d01_01 Vila Rica      = a mining town over steep green hills, white houses with red roofs, a twin-towered church on
                          every height, a stone square with a crowd in the middle, mountains behind
  d01_02 the derrama    = an official reads a decree from steps before soldiers in purple; an angry crowd of miners;
                          a young priest in black among them
  d01_03 the stairs     = night on steep stone stairs between white houses; soldiers in purple charge up with fixed
                          bayonets against men with muskets behind a cart
  d01_04 the gold road  = a mule train of carts with iron-bound chests down a rocky gorge, horsemen in purple; men
                          firing from the rocks above
The King's pages reuse p01_01 (the King in Rome).
Rebuild: python3 tools/campaign/make_d01_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
PURPLE, ORANGE, BLACK = (96, 50, 130), (196, 110, 40), (28, 26, 30)
WHITE, ROOF = (232, 226, 210), (168, 70, 50)


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


def house(d, x, y, w=60, h=40, wall=WHITE):
    d.rectangle([x, y, x + w, y + h], fill=wall)
    d.polygon([(x - 6, y), (x + w / 2, y - 22), (x + w + 6, y)], fill=ROOF)
    d.rectangle([x + w / 2 - 6, y + h - 18, x + w / 2 + 6, y + h], fill=(90, 70, 50))


def church(d, x, y, s=1.0):
    """A baroque church: a white front between two towers with domed caps."""
    d.rectangle([x, y - 80 * s, x + 90 * s, y], fill=WHITE)
    d.polygon([(x, y - 80 * s), (x + 45 * s, y - 110 * s), (x + 90 * s, y - 80 * s)], fill=WHITE)
    for tx in (x - 26 * s, x + 90 * s):
        d.rectangle([tx, y - 130 * s, tx + 26 * s, y], fill=(236, 230, 214))
        d.ellipse([tx - 2 * s, y - 150 * s, tx + 28 * s, y - 118 * s], fill=(120, 110, 96))
    d.rectangle([x + 35 * s, y - 34 * s, x + 55 * s, y], fill=(90, 70, 50))


def musket_man(d, x, y, coat, aim=1):
    figure(d, x, y, coat, 80)
    d.line([(x + 15, y + 20), (x + 15 + 60 * aim, y - 10)], fill=(70, 50, 30), width=5)


def d01():
    """Vila Rica: steep green hills, white houses with red roofs, churches on the heights, a square with a crowd."""
    im = grad((150, 180, 210), (230, 224, 200))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 360), (260, 250), (520, 330), (800, 230), (1100, 300), (W, 260), (W, 420), (0, 440)], fill=(110, 130, 120))   # mountains
    d.chord([-200, 360, 700, 1100], 180, 360, fill=(96, 136, 76))       # the west hill
    d.chord([600, 340, 1500, 1100], 180, 360, fill=(88, 128, 70))       # the east hill
    rnd = random.Random(7)
    for _ in range(46):
        x = rnd.randrange(30, W - 80)
        y = rnd.randrange(460, 760)
        house(d, x, y, rnd.randrange(40, 70), rnd.randrange(28, 40))
    church(d, 200, 470, 1.0)
    church(d, 1000, 450, 1.0)
    d.rectangle([520, 700, 780, 780], fill=(170, 160, 140))            # the square
    for i in range(14):
        figure(d, 530 + i * 17, 720 + (i % 3) * 8, (100, 80, 60), 34)
    return paint(im, 11)


def d02():
    """The derrama: an official reads from steps before soldiers in purple; an angry crowd; a young priest among them."""
    im = grad((190, 200, 210), (210, 196, 170))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 560, W, H], fill=(160, 150, 130))                  # the square's stones
    d.rectangle([360, 200, 920, 520], fill=WHITE)                      # the Foundry House
    for i in range(5):
        d.rectangle([400 + i * 100, 260, 440 + i * 100, 330], fill=(90, 80, 70))
    for i in range(4):
        d.rectangle([520 - i * 30, 520 + i * 14, 760 + i * 30, 534 + i * 14], fill=(190, 184, 170))   # the steps
    figure(d, 620, 410, BLACK, 100)                                    # the official
    d.rectangle([660, 420, 700, 450], fill=(240, 236, 220))           # the decree
    for i in range(6):
        musket_man(d, 420 + i * 70, 470, PURPLE, 0)                    # soldiers in purple
    for i in range(16):
        figure(d, 60 + i * 72, 640 + (i % 3) * 20, (110, 90, 66), 100)    # the crowd
    figure(d, 820, 630, BLACK, 120)                                    # Tomasz among them
    d.line([(835, 650), (835, 610)], fill=(220, 200, 120), width=3)   # (his cross)
    return paint(im, 12)


def d03():
    """The stairs: night on steep stone stairs between white houses; soldiers in purple charge up with bayonets."""
    im = grad((20, 22, 44), (60, 56, 70))
    d = ImageDraw.Draw(im)
    for i in range(14):                                                 # the stairs climbing to the right
        d.rectangle([200 + i * 60, 760 - i * 40, W, 800 - i * 40], fill=(120 - i * 3, 116 - i * 3, 110 - i * 3))
    house(d, 40, 300, 160, 360, (150, 150, 160))
    house(d, 1080, 120, 200, 300, (150, 150, 160))
    d.rectangle([820, 300, 980, 360], fill=(90, 66, 40))               # the cart barricade
    for i in range(4):
        musket_man(d, 860 + i * 40, 260 - i * 6, ORANGE, -1)
        glow(im, 850 + i * 40, 250, 22, (255, 210, 120), 0.6)          # their muzzles' flash
        d = ImageDraw.Draw(im)
    for i in range(7):
        x = 240 + i * 70
        y = 640 - i * 44
        figure(d, x, y, PURPLE, 90)
        d.line([(x + 15, y + 30), (x + 95, y - 20)], fill=(200, 200, 210), width=4)   # bayonets fixed
    glow(im, 120, 200, 90, (255, 170, 80), 0.4)                        # a fire behind
    return paint(im, 13)


def d04():
    """The gold road: carts with iron-bound chests down a rocky gorge, horsemen in purple; men firing from the rocks."""
    im = grad((214, 190, 150), (180, 150, 120))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 0), (420, 0), (360, 420), (0, 520)], fill=(120, 96, 80))       # the gorge's west wall
    d.polygon([(W, 0), (860, 0), (920, 420), (W, 520)], fill=(110, 88, 72))       # the east wall
    d.polygon([(0, 520), (360, 420), (920, 420), (W, 520), (W, H), (0, H)], fill=(160, 120, 90))   # the road
    for i in range(4):
        x = 260 + i * 200
        y = 600 - i * 40
        d.rectangle([x, y, x + 120, y + 60], fill=(110, 80, 50))      # a cart
        d.rectangle([x + 20, y - 30, x + 100, y], fill=(70, 60, 50))  # the iron-bound chest
        d.rectangle([x + 20, y - 18, x + 100, y - 12], fill=(160, 150, 120))
        d.ellipse([x + 10, y + 50, x + 40, y + 80], fill=(50, 40, 30))
        d.ellipse([x + 80, y + 50, x + 110, y + 80], fill=(50, 40, 30))
    for i in range(3):
        x = 180 + i * 360
        d.ellipse([x, 680, x + 110, 740], fill=(90, 66, 50))          # horses
        figure(d, x + 40, 620, PURPLE, 60)
    for (x, y) in [(120, 300), (260, 240), (980, 260), (1120, 330)]:
        musket_man(d, x, y, ORANGE, 1 if x < 640 else -1)
        glow(im, x + (75 if x < 640 else -45), y - 10, 20, (255, 220, 140), 0.6)
        d = ImageDraw.Draw(im)
    return paint(im, 14)


for i, fn in enumerate([d01, d02, d03, d04], 1):
    p = os.path.join(OUT, "d01_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
