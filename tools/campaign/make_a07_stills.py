#!/usr/bin/env python3
"""STAND-IN stills for Act 1's "The Council of Rome" (campaign/stills/a07_01.jpg .. a07_07.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_a07_build.md "Stills"). Drawn simply, as the other Act 1
stand-ins (tools/campaign/make_a01_stills.py, whose helpers it borrows):
  a07_01 the council   = a long hall under a coffered ceiling, cardinals in red on benches, the young King on a chair
  a07_02 Ferrer        = the Jesuit standing before the benches with a roll of drawings, a lamp
  a07_03 Valadares     = the mapmaker with his map unrolled on a table, a sketch of a creature pinned beside it
  a07_04 the accused   = Hollweg (brass gear in hand) and Lindqvist (a specimen jar) standing apart, defiant
  a07_05 the verdict   = the Cardinal Dean reading from a parchment, the hall's candles
  a07_06 Rome burning  = the city's roofs on the east bank at night, three fires, the dome dark on the far bank
  a07_07 the bridges   = a stone bridge at grey dawn, purple coats in a line on it, smoke behind
The King's pages reuse p01_01 (the King lighting his pipe in Rome).
Rebuild: python3 tools/campaign/make_a07_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_a01_stills import W, H, PURPLE, BLACK, grad, glow, paint, houses, person   # noqa: E402

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
RED = (150, 30, 36)
BRASS = (190, 150, 70)
STONE = (170, 160, 146)


def hall(top=(90, 70, 56), bottom=(150, 120, 96)):
    im = grad(top, bottom)
    d = ImageDraw.Draw(im)
    for i in range(8):                                                   # the coffered ceiling
        d.rectangle([i * 170, 0, i * 170 + 150, 90], outline=(70, 52, 40), width=6)
    for x in (120, 1160):                                                # columns
        d.rectangle([x - 30, 90, x + 30, H], fill=(160, 140, 116))
    d.rectangle([0, 600, W, H], fill=(110, 84, 66))                      # the floor
    return im, d


def s1():
    im, d = hall()
    for i in range(7):                                                   # the cardinals on their benches
        person(d, 220 + i * 70, 560, RED, 120, hat=False)
        person(d, 760 + i * 70, 560, RED, 120, hat=False)
    d.rectangle([600, 420, 680, 600], fill=(120, 30, 40))                # the King's chair
    person(d, 640, 600, PURPLE, 170)
    glow(im, 640, 300, 260, (255, 210, 150), 0.35)
    im.save(os.path.join(OUT, "a07_01.jpg"), quality=88)


def s2():
    im, d = hall()
    glow(im, 820, 420, 140, (255, 210, 140), 0.6)
    d = ImageDraw.Draw(im)
    person(d, 560, 760, BLACK, 250, hat=False)                           # Ferrer
    d.rectangle([620, 560, 780, 600], fill=(230, 220, 190))              # the drawings unrolled
    for i in range(4):
        d.line([(630 + i * 40, 565), (650 + i * 40, 595)], fill=(80, 70, 60), width=3)
    for i in range(5):
        person(d, 120 + i * 60, 600, RED, 110, hat=False)
    im.save(os.path.join(OUT, "a07_02.jpg"), quality=88)


def s3():
    im, d = hall((80, 70, 60), (140, 120, 100))
    d.rectangle([380, 520, 980, 600], fill=(100, 70, 46))                # the table
    d.rectangle([420, 470, 900, 540], fill=(226, 212, 170))              # the map
    d.line([(460, 520), (560, 490), (660, 510), (760, 480), (860, 500)], fill=(90, 60, 40), width=4)
    d.rectangle([920, 330, 1040, 450], fill=(220, 210, 180))             # the sketch of her, pinned
    d.ellipse([950, 360, 1010, 420], outline=(60, 80, 50), width=5)
    person(d, 330, 760, (110, 90, 60), 250)                              # Valadares
    im.save(os.path.join(OUT, "a07_03.jpg"), quality=88)


def s4():
    im, d = hall((70, 56, 50), (120, 100, 88))
    person(d, 420, 780, (70, 60, 50), 260, hat=False)                    # Hollweg
    d.ellipse([470, 560, 540, 630], outline=BRASS, width=10)             # a brass gear in his hand
    person(d, 860, 780, (60, 70, 60), 260)                               # Lindqvist
    d.rectangle([900, 560, 950, 640], outline=(180, 200, 190), width=5)  # a specimen jar
    glow(im, 925, 600, 40, (120, 200, 120), 0.4)
    im.save(os.path.join(OUT, "a07_04.jpg"), quality=88)


def s5():
    im, d = hall((60, 46, 40), (110, 86, 70))
    for x in (300, 420, 860, 980):                                       # candles
        d.rectangle([x - 6, 380, x + 6, 470], fill=(236, 226, 200))
        glow(im, x, 370, 40, (255, 200, 120), 0.8)
    d = ImageDraw.Draw(im)
    person(d, 640, 760, RED, 280, hat=False)                             # the Cardinal Dean
    d.rectangle([600, 520, 700, 600], fill=(230, 218, 180))              # the verdict on parchment
    im.save(os.path.join(OUT, "a07_05.jpg"), quality=88)


def s6():
    im = grad((30, 24, 40), (80, 50, 50))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 520, W, H], fill=(30, 36, 50))                       # the Tiber
    d.ellipse([90, 220, 330, 460], fill=(40, 36, 46))                    # the dome on the far bank, dark
    d.rectangle([90, 340, 330, 520], fill=(40, 36, 46))
    houses(d, 520, 77, wall=(90, 70, 60), roof=(50, 40, 40), win=(255, 170, 80), hmax=200)
    for x in (560, 820, 1080):                                           # three fires
        glow(im, x, 340, 160, (255, 130, 50), 0.75)
    im.save(os.path.join(OUT, "a07_06.jpg"), quality=88)


def s7():
    im = grad((150, 150, 160), (110, 104, 100))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 600, W, H], fill=(70, 80, 90))                       # the river
    d.polygon([(0, 560), (W, 520), (W, 600), (0, 640)], fill=STONE)     # the bridge
    for i in range(5):
        d.arc([i * 260 - 40, 560, i * 260 + 200, 760], 180, 360, fill=(120, 110, 100), width=10)
    glow(im, 1000, 300, 260, (200, 190, 180), 0.5)                       # smoke over the east bank
    d = ImageDraw.Draw(im)
    for i in range(8):
        person(d, 260 + i * 90, 600 - i * 5, PURPLE, 140)
    im.save(os.path.join(OUT, "a07_07.jpg"), quality=88)


if __name__ == "__main__":
    for i, f in enumerate([s1, s2, s3, s4, s5, s6, s7]):
        f()
        p = os.path.join(OUT, "a07_%02d.jpg" % (i + 1))
        paint(Image.open(p), i + 21).save(p, quality=88)
        print("wrote", os.path.normpath(p))
