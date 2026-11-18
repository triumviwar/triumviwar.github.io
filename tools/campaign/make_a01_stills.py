#!/usr/bin/env python3
"""STAND-IN stills for Act 1's "The Printing Houses" (campaign/stills/a01_01.jpg .. a01_05.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_a01_build.md "Stills"). Drawn simply, as the other Act 1
stand-ins (tools/campaign/make_a02_stills.py):
  a01_01 the bridge   = Lyon in spring: a stone bridge over the Saône, pamphlets on the wind, a young priest in black
  a01_02 the press    = a printing press behind a weaver's shutters, green and black papers drying on lines
  a01_03 the hill     = the Croix-Rousse at dusk: the weavers' crowd round their hall, the young priest on its steps
  a01_04 the traboule = a covered passage through the houses, soldiers in purple with a lantern
  a01_05 the last press = the great press broken in its yard at dawn, the printer held by two soldiers, the priest
The King's pages reuse p01_01 (the King lighting his pipe in Rome).
Rebuild: python3 tools/campaign/make_a01_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
PURPLE = (92, 52, 128)
GREEN = (40, 110, 60)
BLACK = (24, 22, 26)


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


def houses(d, y0, seed, wall=(196, 160, 120), roof=(150, 70, 50), win=(60, 50, 40), hmax=220):
    """A row of tall Lyon houses (ochre and pink walls, red roofs) standing on y0."""
    rnd = random.Random(seed)
    x = -20
    while x < W:
        w = rnd.randint(70, 120)
        h = rnd.randint(hmax // 2, hmax)
        c = tuple(max(0, min(255, v + rnd.randint(-22, 22))) for v in wall)
        d.rectangle([x, y0 - h, x + w, y0], fill=c)
        d.polygon([(x - 4, y0 - h), (x + w + 4, y0 - h), (x + w - 10, y0 - h - 18), (x + 10, y0 - h - 18)], fill=roof)
        for row in range(y0 - h + 16, y0 - 20, 34):
            for col in range(x + 10, x + w - 14, 24):
                d.rectangle([col, row, col + 12, row + 18], fill=win)
        x += w + rnd.randint(0, 6)


def person(d, x, y, coat, h=120, hat=True, face=(222, 188, 160)):
    d.rectangle([x - h * 0.13, y - h * 0.72, x + h * 0.13, y], fill=coat)
    d.ellipse([x - h * 0.1, y - h * 0.94, x + h * 0.1, y - h * 0.74], fill=face)
    if hat:
        d.rectangle([x - h * 0.16, y - h * 0.98, x + h * 0.16, y - h * 0.9], fill=BLACK)


def papers(d, seed, n=26, box=(0, 0, W, H)):
    rnd = random.Random(seed)
    for _ in range(n):
        x, y = rnd.uniform(box[0], box[2]), rnd.uniform(box[1], box[3])
        a = rnd.uniform(14, 26)
        d.polygon([(x, y), (x + a, y + rnd.uniform(-6, 6)), (x + a, y + a * 1.3), (x, y + a * 1.3)], fill=(238, 232, 214))
        d.line([(x + 3, y + 6), (x + a - 3, y + 6)], fill=GREEN, width=2)
        d.line([(x + 3, y + 11), (x + a - 3, y + 11)], fill=BLACK, width=2)


def s1():
    im = grad((150, 186, 214), (226, 214, 186))
    d = ImageDraw.Draw(im)
    houses(d, 420, 5)
    d.rectangle([0, 470, W, H], fill=(70, 96, 104))           # the Saône
    d.rectangle([0, 430, W, 470], fill=(150, 140, 120))       # the bridge's deck
    for x in range(40, W, 160):
        d.ellipse([x, 455, x + 120, 560], fill=(70, 96, 104))
        d.arc([x, 455, x + 120, 560], 180, 360, fill=(120, 112, 96), width=10)
    person(d, 640, 432, BLACK, 150, hat=False)
    papers(d, 2, 40, (300, 200, 1000, 440))
    im.save(os.path.join(OUT, "a01_01.jpg"), quality=88)


def s2():
    im = grad((60, 46, 38), (34, 26, 22))
    d = ImageDraw.Draw(im)
    glow(im, 900, 260, 360, (255, 190, 110), 0.6)
    d = ImageDraw.Draw(im)
    d.rectangle([380, 300, 760, 640], fill=(70, 50, 36))      # the press's frame
    d.rectangle([420, 250, 720, 300], fill=(96, 70, 46))
    d.rectangle([540, 120, 600, 300], fill=(110, 84, 56))     # the screw
    d.line([(460, 200), (680, 200)], fill=(130, 100, 70), width=12)
    for x in range(60, W, 90):
        d.line([(x, 90), (x + 90, 90)], fill=(80, 70, 60), width=2)
        d.polygon([(x + 10, 92), (x + 50, 92), (x + 50, 150), (x + 10, 150)], fill=(232, 226, 206))
        d.line([(x + 16, 110), (x + 44, 110)], fill=GREEN, width=3)
    person(d, 860, 640, (60, 70, 60), 220, face=(200, 168, 140))
    d.rectangle([1040, 180, 1200, 640], fill=(46, 40, 34))    # the shutters
    for y in range(200, 620, 26):
        d.line([(1046, y), (1194, y)], fill=(70, 60, 50), width=4)
    im.save(os.path.join(OUT, "a01_02.jpg"), quality=88)


def s3():
    im = grad((70, 60, 110), (210, 140, 110))
    d = ImageDraw.Draw(im)
    houses(d, 520, 11, wall=(150, 120, 110), roof=(90, 50, 46), win=(250, 200, 120), hmax=260)
    d.rectangle([0, 520, W, H], fill=(96, 86, 80))
    d.rectangle([470, 300, 810, 520], fill=(170, 150, 120))   # the weavers' hall
    d.polygon([(450, 300), (830, 300), (640, 220)], fill=(110, 60, 50))
    rnd = random.Random(4)
    for i in range(80):
        x, y = rnd.uniform(40, W - 40), rnd.uniform(600, 820)
        person(d, x, y, (rnd.randint(60, 110), rnd.randint(50, 80), rnd.randint(40, 70)), rnd.randint(80, 120), hat=rnd.random() < 0.4)
    person(d, 640, 560, BLACK, 140, hat=False)
    im.save(os.path.join(OUT, "a01_03.jpg"), quality=88)


def s4():
    im = grad((26, 22, 20), (50, 40, 34))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 0), (W, 0), (900, 300), (380, 300)], fill=(40, 34, 30))     # the vault
    d.polygon([(380, 300), (900, 300), (900, 700), (380, 700)], fill=(30, 26, 24))
    d.rectangle([560, 360, 720, 640], fill=(190, 170, 130))                     # the yard's light at the end
    glow(im, 520, 470, 200, (255, 200, 120), 0.7)
    d = ImageDraw.Draw(im)
    for x in (430, 520, 610):
        person(d, x, 760, PURPLE, 230)
    d.ellipse([500, 420, 540, 470], fill=(255, 220, 140))                       # the lantern
    im.save(os.path.join(OUT, "a01_04.jpg"), quality=88)


def s5():
    im = grad((220, 180, 170), (150, 140, 150))
    d = ImageDraw.Draw(im)
    houses(d, 420, 23, hmax=300)
    d.rectangle([0, 420, W, H], fill=(120, 110, 100))
    d.polygon([(380, 520), (760, 470), (800, 560), (420, 620)], fill=(70, 50, 36))     # the press, overturned
    d.line([(560, 480), (520, 380)], fill=(110, 84, 56), width=26)
    papers(d, 9, 60, (200, 560, 1100, 800))
    person(d, 900, 720, PURPLE, 210)
    person(d, 1080, 720, PURPLE, 210)
    person(d, 990, 730, (90, 80, 70), 200, hat=False)
    person(d, 300, 720, BLACK, 200, hat=False)
    im.save(os.path.join(OUT, "a01_05.jpg"), quality=88)


if __name__ == "__main__":
    for i, f in enumerate([s1, s2, s3, s4, s5]):
        f()
        p = os.path.join(OUT, "a01_%02d.jpg" % (i + 1))
        paint(Image.open(p), i + 1).save(p, quality=88)
        print("wrote", os.path.normpath(p))
