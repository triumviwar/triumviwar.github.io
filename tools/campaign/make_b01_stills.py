#!/usr/bin/env python3
"""STAND-IN stills for the Brood prologue (campaign/stills/b01_01.jpg .. b01_08.jpg, 1280 x 853), until the owner's
ChatGPT paintings come (the prompts: docs/campaign_b01_build.md "Stills"). Drawn simply, in the house's colours (warm
lamp and firelight against deep river blues and greens):
  b01 the letter   = the King's study (the Crown Prologue's p01_01, darkened) with a water-stained letter on the desk
  b02 the station  = a timber station on a low rise over a black river at golden afternoon, the flooded forest, the
                     flat-topped mountain in cloud far north
  b03 specimen one = the specimen house by lamplight: the naturalist (the hub's figure), a small frilled reptile, a scale
  b04 eyes         = the flooded forest's edge at a rainy dusk: eyes low between the trunks, a broken goat pen, a lantern
  b05 the tyrant   = a colossal reptile lying down by a small pen at night, a thatched roof alight, rain
  b06 the station burns = from a canoe on the black river at the grey before dawn: the station burning on its rise
  b07 north        = a canoe going up a narrow creek in the morning, big tracks in the mud, the tepui and its waterfall
  b08 the teller   = the King's study, the naturalist in chains between two guards before the King (owner, 2026-11-17)
Rebuild: python3 tools/campaign/make_b01_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it
in; the mission names the files, nothing else changes).
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
OUT = os.path.join(ROOT, "campaign", "stills")
W, H = 1280, 853
PURPLE = (92, 50, 120)
GREEN = (88, 200, 70)          # the Brood's venom green
SCALE = (92, 82, 52)           # olive-brown scales


def grad(top, bottom, h=H):
    im = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(im)
    for y in range(H):
        t = min(1.0, y / max(1, h - 1))
        d.line([(0, y), (W, y)], fill=tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return im


def glow(im, x, y, r, col, a=0.55):
    lay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    for i in range(12, 0, -1):
        rr = r * i / 12
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=col + (int(255 * a / 12),))
    im.paste(Image.alpha_composite(im.convert("RGBA"), lay).convert("RGB"))


def rain(im, n=1400, seed=3, a=70):
    rnd = random.Random(seed)
    lay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    for _ in range(n):
        x, y = rnd.uniform(0, W), rnd.uniform(0, H)
        d.line([(x, y), (x + 4, y + 26)], fill=(190, 205, 230, a), width=1)
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


def trees(d, y0, seed, col=(24, 46, 34), n=40, hmin=120, hmax=300, water=None):
    """The flooded forest: trunks standing in the water, crowns as dark blobs."""
    rnd = random.Random(seed)
    for _ in range(n):
        x = rnd.uniform(-40, W + 40)
        h = rnd.uniform(hmin, hmax)
        d.rectangle([x - 5, y0 - h, x + 5, y0], fill=tuple(max(0, c - 8) for c in col))
        for k in range(4):
            r = rnd.uniform(36, 70)
            cx, cy = x + rnd.uniform(-40, 40), y0 - h + rnd.uniform(-30, 20)
            d.ellipse([cx - r, cy - r * 0.7, cx + r, cy + r * 0.7], fill=tuple(min(255, c + rnd.randint(-6, 10)) for c in col))
        if water:
            d.line([(x - 5, y0 + 4), (x + 5, y0 + 4)], fill=water, width=2)


def station(d, cx, base, burning=False, scale=1.0):
    """The station on its rise: a long thatched house, the specimen house, the palisade, the jetty."""
    s = scale
    d.polygon([(cx - 330 * s, base), (cx - 250 * s, base - 50 * s), (cx + 250 * s, base - 50 * s), (cx + 330 * s, base)], fill=(70, 62, 40))
    roof = (150, 70, 40) if burning else (150, 128, 70)
    d.rectangle([cx - 200 * s, base - 130 * s, cx + 40 * s, base - 50 * s], fill=(120, 92, 60))
    d.polygon([(cx - 220 * s, base - 128 * s), (cx - 80 * s, base - 200 * s), (cx + 60 * s, base - 128 * s)], fill=roof)
    d.rectangle([cx + 80 * s, base - 110 * s, cx + 170 * s, base - 50 * s], fill=(110, 86, 56))
    d.polygon([(cx + 70 * s, base - 108 * s), (cx + 125 * s, base - 150 * s), (cx + 180 * s, base - 108 * s)], fill=roof)
    for i in range(16):
        x = cx - 240 * s + i * 30 * s
        d.rectangle([x, base - 80 * s, x + 7 * s, base - 50 * s], fill=(80, 60, 36))
    d.rectangle([cx - 30 * s, base, cx + 30 * s, base + 50 * s], fill=(90, 70, 46))           # the jetty
    for wx in (cx - 150 * s, cx - 90 * s, cx + 110 * s):
        d.rectangle([wx, base - 110 * s, wx + 18 * s, base - 90 * s], fill=(250, 200, 120))


def person(d, x, y, h, coat, head=(214, 176, 140), hat=None):
    d.polygon([(x - h * 0.16, y), (x - h * 0.12, y - h * 0.62), (x + h * 0.12, y - h * 0.62), (x + h * 0.16, y)], fill=coat)
    d.ellipse([x - h * 0.08, y - h * 0.8, x + h * 0.08, y - h * 0.63], fill=head)
    if hat:
        d.ellipse([x - h * 0.16, y - h * 0.8, x + h * 0.16, y - h * 0.74], fill=hat)


def creature(d, x, y, s, frill=True):
    """A small frilled reptile (Linnea): a monitor-like body, a raised head, a frill of green spikes."""
    d.ellipse([x - 80 * s, y - 34 * s, x + 60 * s, y + 14 * s], fill=SCALE)
    d.polygon([(x - 70 * s, y - 10 * s), (x - 190 * s, y + 10 * s), (x - 70 * s, y + 6 * s)], fill=SCALE)       # the tail
    d.polygon([(x + 40 * s, y - 24 * s), (x + 90 * s, y - 80 * s), (x + 110 * s, y - 70 * s), (x + 70 * s, y - 10 * s)], fill=SCALE)
    d.ellipse([x + 80 * s, y - 100 * s, x + 140 * s, y - 64 * s], fill=SCALE)                                   # the head
    d.ellipse([x + 118 * s, y - 92 * s, x + 126 * s, y - 84 * s], fill=(240, 200, 60))                          # a golden eye
    if frill:
        for i in range(7):
            a = math.radians(150 + i * 22)
            px, py = x + 92 * s, y - 80 * s
            d.polygon([(px, py), (px + math.cos(a) * 46 * s, py + math.sin(a) * 46 * s),
                       (px + math.cos(a + 0.2) * 22 * s, py + math.sin(a + 0.2) * 22 * s)], fill=GREEN)
    for lx in (-40, 20):
        d.rectangle([x + lx * s, y, x + (lx + 12) * s, y + 30 * s], fill=SCALE)


def b01():
    im = Image.open(os.path.join(ROOT, "campaign", "stills", "p01_01.jpg")).convert("RGB").resize((W, H))
    im = Image.blend(im, Image.new("RGB", (W, H), (10, 18, 22)), 0.3)
    d = ImageDraw.Draw(im)
    d.polygon([(470, 690), (690, 660), (720, 760), (500, 795)], fill=(214, 196, 150))       # the letter, water-stained
    d.ellipse([560, 690, 640, 740], fill=(178, 160, 118))
    d.ellipse([600, 720, 630, 750], fill=(140, 40, 40))                                     # its broken seal
    d.polygon([(720, 735), (760, 720), (790, 745), (750, 760)], fill=(60, 100, 50))          # a dried jungle leaf
    return paint(im, 1)


def b02():
    im = grad((236, 190, 120), (120, 96, 70), 470)
    d = ImageDraw.Draw(im)
    d.polygon([(860, 300), (900, 200), (1100, 196), (1140, 300)], fill=(140, 120, 120))     # the tepui in the far north
    d.ellipse([820, 170, 1180, 240], fill=(232, 214, 196))                                  # its cloud
    d.rectangle([0, 470, W, H], fill=(18, 20, 22))                                          # the black river
    trees(d, 480, 2, col=(44, 70, 40), n=26, hmin=140, hmax=260, water=(70, 60, 40))
    station(d, 560, 520)
    for i in range(30):                                                                      # golden light on the water
        y = 560 + i * 9
        d.line([(480 - i * 6, y), (640 + i * 6, y)], fill=(160, 120, 70) if i % 2 else (40, 36, 30), width=2)
    d.line([(1080, 600), (1260, 640)], fill=(230, 230, 230), width=6)                       # the rapids
    d.line([(1040, 640), (1270, 690)], fill=(210, 220, 220), width=5)
    d.rectangle([700, 400, 704, 470], fill=(70, 50, 30))
    d.polygon([(704, 402), (744, 410), (704, 420)], fill=PURPLE)                            # a small purple flag
    glow(im, 300, 120, 220, (255, 220, 150), 0.3)
    return paint(im, 2)


def b03():
    room = Image.open(os.path.join(ROOT, "campaign", "hub", "station_room.jpg")).convert("RGB")
    lq = Image.open(os.path.join(ROOT, "campaign", "hub", "station_lindqvist.png")).convert("RGBA")
    room.paste(lq, (1345, 276), lq)
    cw, ch = 1260, 840
    box = (room.width - cw, (room.height - ch) // 2, room.width, (room.height - ch) // 2 + ch)
    im = room.crop(box).resize((W, H))
    im = Image.blend(im, Image.new("RGB", (W, H), (30, 20, 10)), 0.25)
    d = ImageDraw.Draw(im)
    d.rectangle([360, 700, 700, 760], fill=(110, 80, 40))                                   # the straw crate
    d.rectangle([380, 640, 520, 660], fill=(170, 140, 60))                                  # the brass scale
    d.line([(450, 640), (450, 560)], fill=(170, 140, 60), width=6)
    creature(d, 560, 700, 1.0)
    glow(im, 450, 520, 200, (255, 190, 100), 0.35)
    return paint(im, 3)


def b04():
    im = grad((70, 50, 70), (24, 30, 34), 500)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 520, W, H], fill=(20, 26, 26))
    trees(d, 600, 4, col=(22, 36, 30), n=34, hmin=300, hmax=520, water=(40, 50, 50))
    rnd = random.Random(5)
    for _ in range(22):                                                                      # eyes, low between the trunks
        x, y = rnd.uniform(80, 1200), rnd.uniform(520, 610)
        for dx in (0, 14):
            d.ellipse([x + dx, y, x + dx + 7, y + 5], fill=(250, 220, 90))
    for i in range(8):                                                                       # the broken goat pen
        x = 120 + i * 50
        d.line([(x, 760), (x + rnd.uniform(-20, 20), 680)], fill=(90, 70, 40), width=8)
    person(d, 900, 800, 260, (60, 70, 60), hat=(50, 40, 30))                                 # Valadares, pistol raised
    d.line([(940, 640), (1010, 600)], fill=(40, 40, 40), width=8)
    person(d, 1080, 800, 240, (40, 90, 50))                                                  # the naturalist with a lamp
    glow(im, 1120, 640, 90, (255, 200, 110), 0.6)
    rain(im, 1600, 4)
    return paint(im, 4)


def b05():
    im = grad((26, 22, 40), (40, 28, 26), 600)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 600, W, H], fill=(36, 30, 24))
    d.rectangle([880, 330, 1240, 600], fill=(80, 60, 40))                                    # the house, its roof alight
    d.polygon([(860, 330), (1060, 210), (1260, 330)], fill=(150, 60, 30))
    glow(im, 1060, 280, 260, (255, 120, 40), 0.55)
    d = ImageDraw.Draw(im)
    for i in range(10):                                                                      # the pen
        x = 520 + i * 26
        d.rectangle([x, 560, x + 10, 640], fill=(90, 66, 40))
    creature(d, 600, 650, 0.6)
    d.ellipse([560, 680, 590, 700], fill=(220, 214, 190))                                    # eggs in the straw
    d.ellipse([600, 686, 630, 706], fill=(220, 214, 190))
    # the Tyrant lying down beside the pen, his head lowered toward her
    d.ellipse([60, 420, 560, 700], fill=(70, 62, 44))
    d.polygon([(520, 520), (700, 470), (740, 520), (560, 600)], fill=(70, 62, 44))
    d.ellipse([640, 440, 820, 540], fill=(74, 66, 46))
    d.ellipse([770, 470, 786, 482], fill=(250, 200, 80))
    for i in range(9):
        x = 120 + i * 50
        d.polygon([(x, 440 - (i % 3) * 6), (x + 18, 380 - (i % 2) * 20), (x + 36, 440)], fill=GREEN)
    for x in (40, 1180):                                                                     # soldiers in purple, torches
        person(d, x, 820, 200, PURPLE)
    glow(im, 60, 620, 50, (255, 170, 80), 0.6)
    rain(im, 1400, 5)
    return paint(im, 5)


def b06():
    im = grad((90, 96, 110), (60, 60, 70), 420)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 420, W, H], fill=(16, 18, 22))
    trees(d, 430, 6, col=(30, 40, 40), n=30, hmin=100, hmax=200)
    station(d, 700, 440, burning=True, scale=0.7)
    glow(im, 640, 340, 240, (255, 120, 40), 0.6)
    d = ImageDraw.Draw(im)
    for i in range(16):                                                                      # flames doubled in the water
        d.line([(560 + i * 8, 470 + i * 6), (720 - i * 8, 470 + i * 6)], fill=(200, 90, 30), width=3)
    d.polygon([(0, 780), (900, 720), (960, 760), (0, 853)], fill=(60, 44, 30))              # the canoe, close
    person(d, 260, 790, 240, (40, 90, 50))                                                   # the naturalist, soot-black
    d.rectangle([200, 640, 300, 700], fill=(70, 56, 40))                                     # the small crate
    for x in (420, 520, 620):
        person(d, x, 770, 180, (70, 60, 50))
    person(d, 820, 740, 200, (80, 60, 40), hat=(60, 50, 30))                                 # Benedito at the bow
    return paint(im, 6)


def b07():
    im = grad((200, 210, 200), (120, 140, 110), 460)
    d = ImageDraw.Draw(im)
    d.polygon([(520, 330), (560, 120), (820, 110), (860, 330)], fill=(120, 110, 110))       # the tepui
    d.line([(700, 120), (700, 330)], fill=(240, 240, 250), width=10)                         # its waterfall
    d.ellipse([480, 70, 900, 150], fill=(236, 236, 236))
    trees(d, 520, 7, col=(46, 80, 46), n=30, hmin=180, hmax=360)
    d.polygon([(420, 853), (560, 520), (720, 520), (900, 853)], fill=(40, 46, 40))           # the creek
    for i in range(6):                                                                       # tracks in the mud: big, and small beside them
        y = 840 - i * 50
        d.ellipse([340 - i * 6, y, 380 - i * 6, y + 20], fill=(60, 46, 30))
        d.ellipse([300 - i * 5, y + 10, 314 - i * 5, y + 18], fill=(60, 46, 30))
    d.polygon([(560, 760), (760, 740), (780, 770), (580, 790)], fill=(90, 66, 40))           # the canoe
    person(d, 740, 760, 150, (70, 80, 60), hat=(60, 50, 30))
    person(d, 600, 770, 130, (80, 60, 40))
    return paint(im, 7)


def b08():
    im = Image.open(os.path.join(ROOT, "campaign", "stills", "p01_01.jpg")).convert("RGB").resize((W, H))
    im = Image.blend(im, Image.new("RGB", (W, H), (12, 10, 20)), 0.45)
    d = ImageDraw.Draw(im)
    person(d, 330, 800, 360, (60, 90, 60), head=(220, 210, 200))                             # the naturalist, white-haired
    d.ellipse([300, 500, 360, 540], fill=(232, 232, 228))
    for y in range(640, 700, 12):                                                            # his chains
        d.ellipse([290, y, 312, y + 14], outline=(150, 150, 150), width=3)
        d.ellipse([348, y, 370, y + 14], outline=(150, 150, 150), width=3)
    for x in (150, 510):                                                                      # two guards in purple, halberds
        person(d, x, 820, 380, PURPLE, hat=(30, 30, 30))
        d.line([(x + 50, 820), (x + 50, 380)], fill=(110, 90, 60), width=6)
        d.polygon([(x + 50, 380), (x + 80, 420), (x + 50, 440)], fill=(190, 190, 200))
    glow(im, 900, 420, 160, (255, 200, 120), 0.3)
    return paint(im, 8)


os.makedirs(OUT, exist_ok=True)
for i, fn in enumerate([b01, b02, b03, b04, b05, b06, b07, b08], 1):
    p = os.path.join(OUT, "b01_%02d.jpg" % i)
    fn().save(p, quality=88)
    print("wrote", os.path.normpath(p))
