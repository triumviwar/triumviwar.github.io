#!/usr/bin/env python3
"""STAND-IN stills for Act 1's "The Barricades of Paris" (campaign/stills/a06_01.jpg .. a06_05.jpg, 1280 x 853), until
the owner's ChatGPT paintings come (the prompts: docs/campaign_a06_build.md "Stills"). Drawn simply, as the other Act 1
stand-ins (tools/campaign/make_a01_stills.py, whose helpers it borrows):
  a06_01 the barricade = dawn in the faubourg: a barricade of carts and paving stones across a street, green flags
  a06_02 the battery   = the Crown's mortar and field guns in a street, smoke, purple coats
  a06_03 Notre-Dame    = the cathedral's towers over the river at dusk, torches on a bridge
  a06_04 the hall      = the Hôtel de Ville stormed: a palisade broken, purple coats pouring in, smoke
  a06_05 the prisoner  = Varenne in chains before the field marshal, the young priest beside him
The King's pages reuse p01_01 (the King lighting his pipe in Rome).
Rebuild: python3 tools/campaign/make_a06_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
"""
import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_a01_stills import W, H, PURPLE, GREEN, BLACK, grad, glow, paint, houses, person   # noqa: E402

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
GREY = (150, 146, 140)


def s1():
    im = grad((230, 190, 160), (170, 160, 160))
    d = ImageDraw.Draw(im)
    houses(d, 460, 31, wall=(200, 190, 170), roof=(90, 90, 100), hmax=320)
    d.rectangle([0, 460, W, H], fill=(140, 130, 120))
    for i in range(14):                                                     # the barricade: carts, stones, beams
        x = 160 + i * 70
        d.polygon([(x, 600), (x + 90, 590), (x + 80, 520 - (i % 3) * 20), (x + 10, 530)], fill=(96 - i % 2 * 20, 80, 64))
    d.line([(300, 610), (380, 470)], fill=(110, 84, 56), width=18)          # a cart's shaft up in the air
    for x in (420, 760, 980):                                                # the Assembly's flags
        d.line([(x, 520), (x, 360)], fill=BLACK, width=6)
        d.polygon([(x, 362), (x + 80, 380), (x, 410)], fill=GREEN)
    for x in (300, 520, 700, 900):
        person(d, x, 560, (50, 70, 50), 110)
    im.save(os.path.join(OUT, "a06_01.jpg"), quality=88)


def s2():
    im = grad((200, 180, 170), (120, 110, 110))
    d = ImageDraw.Draw(im)
    houses(d, 420, 37, wall=(190, 180, 160), roof=(80, 80, 90), hmax=300)
    d.rectangle([0, 420, W, H], fill=(120, 112, 104))
    glow(im, 820, 360, 240, (240, 220, 200), 0.5)                           # smoke
    d = ImageDraw.Draw(im)
    d.ellipse([360, 620, 520, 720], fill=(60, 60, 64))                       # the mortar's squat barrel on its bed
    d.rectangle([340, 690, 540, 740], fill=(90, 70, 50))
    d.line([(700, 690), (860, 640)], fill=(50, 50, 54), width=26)            # a field gun
    d.ellipse([660, 680, 740, 760], outline=(90, 70, 50), width=10)
    for x in (260, 600, 960, 1080):
        person(d, x, 760, PURPLE, 200)
    im.save(os.path.join(OUT, "a06_02.jpg"), quality=88)


def s3():
    im = grad((90, 70, 110), (200, 120, 90))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 560, W, H], fill=(60, 70, 90))                           # the river
    d.rectangle([420, 180, 560, 520], fill=(120, 110, 100))                  # the towers
    d.rectangle([720, 180, 860, 520], fill=(120, 110, 100))
    d.rectangle([420, 320, 860, 560], fill=(110, 100, 92))
    d.ellipse([580, 330, 700, 450], fill=(80, 70, 90))                       # the rose window
    d.polygon([(0, 640), (W, 600), (W, 640), (0, 680)], fill=(110, 96, 84))  # a bridge
    for x in (300, 420, 560):
        person(d, x, 630, (50, 70, 50), 90)
        glow(im, x + 14, 540, 30, (255, 170, 80), 0.8)
        d = ImageDraw.Draw(im)
    im.save(os.path.join(OUT, "a06_03.jpg"), quality=88)


def s4():
    im = grad((170, 150, 150), (100, 96, 100))
    d = ImageDraw.Draw(im)
    d.rectangle([260, 160, 1020, 520], fill=(180, 170, 150))                 # the hall's front
    for i in range(9):
        d.rectangle([300 + i * 80, 230, 340 + i * 80, 300], fill=(60, 60, 70))
    d.rectangle([600, 400, 680, 520], fill=(50, 40, 36))                     # its door
    d.rectangle([0, 520, W, H], fill=(120, 112, 104))
    for i in range(20):                                                      # the palisade, broken in the middle
        x = i * 64
        if 520 < x < 760:
            continue
        d.rectangle([x, 560, x + 50, 680], fill=(110, 84, 56))
    glow(im, 640, 520, 200, (240, 220, 200), 0.45)
    d = ImageDraw.Draw(im)
    for x in (540, 640, 740, 840):
        person(d, x, 790, PURPLE, 210)
    im.save(os.path.join(OUT, "a06_04.jpg"), quality=88)


def s5():
    im = grad((60, 50, 60), (120, 100, 90))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 540, W, H], fill=(90, 80, 74))
    glow(im, 640, 380, 360, (255, 200, 140), 0.45)
    d = ImageDraw.Draw(im)
    person(d, 640, 760, (40, 60, 44), 230, hat=False)                         # Varenne, in chains
    d.line([(600, 640), (680, 640)], fill=GREY, width=8)
    person(d, 380, 760, PURPLE, 250)                                          # the field marshal
    person(d, 900, 760, BLACK, 230, hat=False)                                # the young priest
    im.save(os.path.join(OUT, "a06_05.jpg"), quality=88)


if __name__ == "__main__":
    for i, f in enumerate([s1, s2, s3, s4, s5]):
        f()
        p = os.path.join(OUT, "a06_%02d.jpg" % (i + 1))
        paint(Image.open(p), i + 11).save(p, quality=88)
        print("wrote", os.path.normpath(p))
