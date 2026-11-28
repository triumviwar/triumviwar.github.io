#!/usr/bin/env python3
"""STAND-IN stills for Act 3's "Brazil After the Fires" (campaign/stills/e01_01.jpg .. e01_04.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_e01_build.md "Stills"). Drawn simply, in the manner of d11's
stand-ins (tools/campaign/make_d11_stills.py: its helpers copied here, as d11 copied d09's).
  e01_01 the column to the coast = a long column of colonists, ox carts and purple-coated soldiers down a red-earth road to a
                                   harbour with ships; a drummer boy in front; smoke on the hills behind
  e01_02 the last bluff          = purple soldiers with two cannon on a grassy bluff over a harbour at dusk; boats row people
                                   out to the ships
  e01_03 the ford                = at the ford the line in purple coats holds the near bank while families wade across;
                                   smoke and shapes on the far bank
  e01_04 the ships at the quay   = tall ships off a stone quay crowded with people and bundles; an old general counts them
                                   aboard
The King's pages reuse p01_01 (the King lighting his pipe).
Rebuild: python3 tools/campaign/make_e01_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
PURPLE, BLACK, RED = (96, 50, 130), (28, 26, 30), (150, 46, 40)
BRASS = (196, 152, 70)
GRASS = (104, 124, 70)
EARTH = (122, 88, 56)


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
        d.rectangle([x + 2, y + 6, x + 28, y + h * 0.45], fill=(170, 172, 178))
    d.ellipse([x, y - 32, x + 30, y - 2], fill=face)


def araucaria(d, x, y, s=1.0):
    """The highlands' pine: a tall bare trunk and a flat crown like an upturned umbrella."""
    d.rectangle([x - 4 * s, y - 230 * s, x + 4 * s, y], fill=(70, 52, 40))
    for i in range(3):
        yy = y - (230 - i * 26) * s
        d.chord([x - (90 - i * 18) * s, yy - 40 * s, x + (90 - i * 18) * s, yy + 30 * s], 180, 360, fill=(46, 70, 46))


def cannon(d, x, y, s=1.0, smoke=None, im=None):
    d.rectangle([x, y, x + 90 * s, y + 16 * s], fill=(40, 40, 44))
    d.ellipse([x + 10 * s, y + 6 * s, x + 46 * s, y + 42 * s], fill=(90, 60, 36))
    if smoke and im is not None:
        glow(im, x + 100 * s, y + 4 * s, 50 * s, (236, 232, 224), 0.7)


def clockwork(d, x, y, s=1.0, col=BRASS):
    """A brass clock soldier: a round body, a shield, a key on its back."""
    d.rectangle([x, y, x + 34 * s, y + 70 * s], fill=col)
    d.ellipse([x + 2 * s, y - 28 * s, x + 32 * s, y + 2 * s], fill=tuple(int(v * 0.85) for v in col))
    d.ellipse([x + 9 * s, y + 18 * s, x + 25 * s, y + 34 * s], outline=(110, 80, 30), width=2)      # a cog on its breast
    d.rectangle([x - 14 * s, y + 10 * s, x - 2 * s, y + 52 * s], fill=RED)                          # the shield
    d.line([(x + 34 * s, y + 20 * s), (x + 48 * s, y + 14 * s)], fill=(90, 70, 30), width=3)        # the key


def _unused_wall(d, y0, y1, x0=0, x1=W, top=None):
    d.rectangle([x0, y0, x1, y1], fill=(150, 112, 60))
    for x in range(int(x0), int(x1), 40):
        d.line([(x, y0), (x, y1)], fill=(120, 88, 48), width=2)
    d.rectangle([x0, y0 - 14, x1, y0], fill=top or BRASS)
    for x in range(int(x0), int(x1), 60):
        d.rectangle([x, y0 - 30, x + 30, y0 - 14], fill=top or BRASS)



SEA = (70, 96, 120)
RED_EARTH = (150, 84, 52)
SAIL = (232, 226, 210)


def ship(d, x, y, s=1.0):
    """A tall ship: a dark hull, three masts, square sails."""
    d.polygon([(x, y), (x + 220 * s, y), (x + 196 * s, y + 46 * s), (x + 24 * s, y + 46 * s)], fill=(60, 44, 34))
    for i, mx in enumerate((50, 110, 170)):
        X = x + mx * s
        d.line([(X, y), (X, y - 190 * s)], fill=(50, 40, 30), width=max(2, int(4 * s)))
        for k in range(3):
            yy = y - (40 + k * 52) * s
            d.rectangle([X - (34 - k * 6) * s, yy - 40 * s, X + (34 - k * 6) * s, yy], fill=SAIL)
    d.rectangle([x + 196 * s, y - 120 * s, x + 200 * s, y - 70 * s], fill=PURPLE)            # the flag


def cart(d, x, y, s=1.0):
    d.rectangle([x, y, x + 70 * s, y + 30 * s], fill=(120, 86, 50))
    d.ellipse([x + 6 * s, y + 22 * s, x + 30 * s, y + 46 * s], fill=(70, 50, 30))
    d.ellipse([x + 42 * s, y + 22 * s, x + 66 * s, y + 46 * s], fill=(70, 50, 30))
    d.ellipse([x - 46 * s, y + 4 * s, x - 2 * s, y + 34 * s], fill=(176, 160, 130))           # the ox


def person(d, x, y, col, h=60):
    d.rectangle([x, y, x + 16, y + h], fill=col)
    d.ellipse([x, y - 16, x + 16, y], fill=(206, 170, 136))


def e01():
    """The column to the coast."""
    im = grad((226, 208, 176), (200, 184, 150))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 300, W, 360], fill=SEA)                                                   # the sea far off
    ship(d, 980, 300, 0.4)
    ship(d, 1100, 304, 0.32)
    for x in (80, 260, 420):                                                                   # the smoke on the hills behind
        glow(im, x, 220, 110, (120, 110, 104), 0.5)
    d = ImageDraw.Draw(im)
    d.polygon([(0, 360), (W, 340), (W, H), (0, H)], fill=GRASS)
    d.polygon([(560, 360), (700, 360), (W, H), (200, H)], fill=RED_EARTH)                    # the road
    rnd = random.Random(201)
    for i in range(26):                                                                         # the column
        t = i / 26.0
        x = int(640 + (rnd.uniform(-60, 60) + 200) * t + 120 * (1 - t))
        y = int(380 + 420 * t)
        if i % 5 == 2:
            cart(d, x - 40, y, 0.6 + t * 0.8)
        else:
            person(d, x, y, PURPLE if i % 3 == 0 else (120 + rnd.randrange(40), 100, 80), int(30 + 70 * t))
    figure(d, 600, 410, PURPLE, 52)                                                             # the drummer boy in front
    d.ellipse([588, 432, 616, 452], fill=(200, 60, 50))
    return paint(im, 201)


def e02():
    """The last bluff over the harbour at dusk."""
    im = grad((214, 140, 96), (90, 70, 84))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 420, W, H], fill=SEA)
    for i, x in enumerate((640, 860, 1060)):
        ship(d, x, 470 - i * 6, 0.55 - i * 0.05)
    for i in range(5):                                                                           # the boats rowing out
        d.ellipse([500 + i * 120, 600 + (i % 2) * 30, 560 + i * 120, 620 + (i % 2) * 30], fill=(80, 60, 40))
        person(d, 520 + i * 120, 580 + (i % 2) * 30, (110, 90, 80), 22)
    d.polygon([(0, 360), (420, 400), (520, H), (0, H)], fill=(84, 104, 60))                   # the bluff
    for i in range(6):
        figure(d, 60 + i * 52, 470 + (i % 2) * 10, PURPLE, 90, plate=(i % 2 == 0))
    cannon(d, 250, 560, 1.0, smoke=True, im=im)
    d = ImageDraw.Draw(im)
    cannon(d, 110, 600, 0.9)
    return paint(im, 202)


def e03():
    """The ford: the line on the near bank, families wading across."""
    im = grad((206, 210, 204), (170, 176, 160))
    d = ImageDraw.Draw(im)
    glow(im, 1000, 260, 170, (110, 104, 100), 0.55)                                            # smoke on the far bank
    d = ImageDraw.Draw(im)
    d.polygon([(560, 330), (W, 310), (W, 520), (720, 540)], fill=(110, 120, 80))              # the far bank
    d.polygon([(420, 520), (W, 500), (W, 640), (360, 680)], fill=(110, 130, 140))             # the water
    rnd = random.Random(203)
    for i in range(9):                                                                           # the families wading
        person(d, 560 + i * 60 + rnd.randrange(20), 520 + (i % 3) * 30, (130, 100, 80), 50)
    d.polygon([(0, 560), (440, 640), (420, H), (0, H)], fill=GRASS)                           # the near bank
    for i in range(8):
        figure(d, 40 + i * 48, 600 + (i % 2) * 14, PURPLE, 96, plate=(i % 3 == 0))
    cannon(d, 300, 720, 1.0, smoke=True, im=im)
    return paint(im, 203)


def e04():
    """The ships at the quay; an old general counts them aboard."""
    im = grad((200, 210, 218), (170, 180, 186))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 380, W, H], fill=SEA)
    ship(d, 140, 420, 0.9)
    ship(d, 620, 410, 0.8)
    d.polygon([(700, 560), (W, 520), (W, H), (560, H)], fill=(150, 146, 140))                 # the stone quay
    rnd = random.Random(204)
    for i in range(22):
        person(d, 760 + rnd.randrange(480), 560 + rnd.randrange(220), (100 + rnd.randrange(60), 90, 80), 50)
    figure(d, 1150, 600, PURPLE, 150, face=(214, 196, 180))                                   # the old general
    d.ellipse([1148, 562, 1184, 578], fill=(220, 220, 224))
    d.rectangle([1120, 640, 1150, 670], fill=(236, 230, 210))                                  # his list
    return paint(im, 204)


if __name__ == "__main__":
    for i, fn in enumerate([e01, e02, e03, e04], 1):
        p = os.path.join(OUT, "e01_%02d.jpg" % i)
        fn().convert("RGB").save(p, quality=86)
        print("wrote", os.path.normpath(p))
