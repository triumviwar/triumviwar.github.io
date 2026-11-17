#!/usr/bin/env python3
"""STAND-IN stills for the Clockwork prologue (campaign/stills/c01_01.jpg .. c01_07.jpg, 1280 x 853), until the owner's
ChatGPT paintings come (the prompts: docs/campaign_c01_build.md "Stills"). Drawn simply here, in the house's colours (warm
lantern light against deep blues), so the opening, the dialogue box and the ending have a picture to show:
  c01 the letter      = the King's study (the Crown Prologue's p01_01, darkened: the King in Rome)
  c02 Nuremberg       = roofs in the snow at dusk, the castle on its rock, the church spire, lit windows, the frozen river
  c03 the heart       = Hollweg's workshop (the hub painting) with Hollweg in it
  c04 the Perpetual   = a brass tower with blue plates in a snowy courtyard, small machines climbing out at its foot
  c05 the mill island = a stone bridge at night, a waterwheel overgrown with red-plated gears, a lantern
  c06 thirteen        = the church clock at midnight, red machines on the roofs, fires, a figure at the gate
  c07 the crates      = a grey port at dawn, a ship, crates, a red glow through a split plank
Rebuild: python3 tools/campaign/make_c01_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in;
the mission names the files, nothing else changes).
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


def c01():
    im = Image.open(os.path.join(ROOT, "campaign", "stills", "p01_01.jpg")).convert("RGB").resize((W, H))
    dark = Image.new("RGB", (W, H), (10, 12, 30))
    return Image.blend(im, dark, 0.28)


def c02():
    im = grad((22, 30, 70), (70, 80, 120))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 330), (120, 250), (330, 240), (420, 330)], fill=(48, 50, 70))     # the castle rock
    d.rectangle([150, 150, 230, 260], fill=(56, 54, 70))
    d.rectangle([250, 180, 300, 260], fill=(56, 54, 70))
    d.polygon([(140, 150), (190, 95), (240, 150)], fill=(90, 46, 40))
    d.rectangle([760, 160, 820, 520], fill=(60, 52, 60))                                # the Frauenkirche
    d.polygon([(750, 160), (790, 60), (830, 160)], fill=(70, 56, 60))
    d.ellipse([772, 230, 808, 266], fill=(230, 210, 150))                              # its clock
    houses(d, 560, 4)
    d.rectangle([0, 560, W, 640], fill=(222, 230, 245))                                # the square in the snow
    for i in range(14):                                                                 # the market's stalls, lit
        x = 60 + i * 90
        d.rectangle([x, 520, x + 60, 560], fill=(96, 60, 40))
        d.polygon([(x - 8, 520), (x + 30, 495), (x + 68, 520)], fill=(170, 60, 50) if i % 2 else (220, 210, 190))
        glow(im, x + 30, 535, 46, (255, 190, 100), 0.45)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 640, W, H], fill=(170, 186, 210))                                  # the frozen river
    d.ellipse([60, 610, 260, 810], outline=(70, 55, 40), width=14)                     # a waterwheel
    for a in range(0, 360, 30):
        r = math.radians(a)
        d.line([(160, 710), (160 + math.cos(r) * 100, 710 + math.sin(r) * 100)], fill=(70, 55, 40), width=6)
    rnd = random.Random(8)
    for i in range(9):                                                                  # small blue-plated machines
        x, y = 360 + i * 95, 600 + rnd.randint(-6, 10)
        d.rectangle([x, y, x + 22, y + 34], fill=(176, 140, 70))
        d.rectangle([x + 4, y + 6, x + 18, y + 16], fill=(60, 90, 170))
    snow(im, 700, 2)
    return paint(im, 2)


def c03():
    room = Image.open(os.path.join(ROOT, "campaign", "hub", "nuremberg_room.jpg")).convert("RGB")
    hol = Image.open(os.path.join(ROOT, "campaign", "hub", "nuremberg_hollweg.png")).convert("RGBA")
    room.paste(hol, (1469, 382), hol)
    # a 3:2 crop on the right of the room, where Hollweg stands with his lamp
    cw, ch = 1260, 840
    box = (room.width - cw, (room.height - ch) // 2, room.width, (room.height - ch) // 2 + ch)
    im = room.crop(box).resize((W, H))
    glow(im, int((1426 - box[0]) * W / cw), int((404 - box[1]) * H / ch), 120, (255, 190, 100), 0.4)
    return im


def c04():
    im = grad((150, 170, 200), (230, 236, 246))
    d = ImageDraw.Draw(im)
    houses(d, 520, 11, light=(120, 110, 90), dark=(80, 84, 100), hmax=220)
    d.rectangle([0, 520, W, H], fill=(236, 240, 248))
    d.rectangle([540, 120, 740, 640], fill=(180, 140, 70))                             # the Perpetual
    for y in range(160, 600, 70):
        d.rectangle([560, y, 720, y + 40], fill=(60, 96, 180))
    d.polygon([(520, 120), (640, 40), (760, 120)], fill=(150, 112, 56))
    d.ellipse([600, 60, 680, 116], fill=(240, 226, 170))
    gear(d, 500, 600, 90, (196, 150, 72), 12, (60, 96, 180))
    gear(d, 780, 610, 70, (196, 150, 72), 10, (60, 96, 180))
    d.rectangle([610, 560, 670, 640], fill=(30, 26, 22))                               # its hatch
    for i, x in enumerate([600, 690, 760, 840, 420]):                                   # children climbing out
        y = 650 + (i % 2) * 30
        d.rectangle([x, y, x + 26, y + 40], fill=(186, 146, 74))
        d.rectangle([x + 5, y + 8, x + 21, y + 18], fill=(60, 96, 180))
    d.rectangle([250, 560, 290, 690], fill=(110, 60, 40))                              # Hollweg, hands up
    d.line([(255, 570), (225, 520)], fill=(110, 60, 40), width=10)
    d.line([(285, 570), (315, 520)], fill=(110, 60, 40), width=10)
    d.ellipse([254, 530, 286, 562], fill=(220, 190, 160))
    d.rectangle([1040, 560, 1076, 700], fill=(20, 20, 24))                             # the priest apart
    d.ellipse([1042, 528, 1074, 560], fill=(210, 180, 150))
    snow(im, 400, 4, 120)
    return paint(im, 4)


def c05():
    im = grad((8, 12, 30), (24, 30, 56))
    d = ImageDraw.Draw(im)
    d.pieslice([200, 60, 1080, 900], 180, 360, fill=(46, 46, 58))                     # the bridge's arch
    d.pieslice([300, 180, 980, 860], 180, 360, fill=(12, 14, 28))
    d.rectangle([0, 600, W, H], fill=(40, 52, 80))                                     # the dark water, ice
    d.ellipse([360, 330, 720, 690], outline=(80, 60, 44), width=18)                    # the waterwheel
    rnd = random.Random(5)
    for i in range(16):                                                                 # the red network
        x, y, r = rnd.randint(260, 1020), rnd.randint(300, 700), rnd.randint(30, 80)
        gear(d, x, y, r, (170, 120, 60), rnd.randint(8, 12), (170, 40, 36))
        glow(im, x, y, r * 1.3, (220, 60, 40), 0.18)
        d = ImageDraw.Draw(im)
    for x in (300, 820, 940):                                                           # red machines at work
        d.rectangle([x, 560, x + 30, 610], fill=(170, 130, 64))
        d.rectangle([x + 6, 568, x + 24, 582], fill=(180, 40, 36))
    d.rectangle([110, 600, 140, 720], fill=(60, 50, 40))                               # Jakob with his lantern
    d.ellipse([110, 568, 140, 598], fill=(220, 190, 160))
    glow(im, 160, 640, 90, (255, 200, 110), 0.6)
    d = ImageDraw.Draw(im)
    for x in (40, 70):                                                                  # two blue soldiers behind him
        d.rectangle([x, 640, x + 24, 720], fill=(150, 120, 62))
        d.rectangle([x + 4, 650, x + 20, 664], fill=(60, 96, 180))
    return paint(im, 5)


def c06():
    im = grad((6, 8, 24), (30, 20, 34))
    d = ImageDraw.Draw(im)
    d.rectangle([540, 40, 740, 600], fill=(48, 40, 46))                                # the church front
    d.polygon([(520, 40), (640, -40), (760, 40)], fill=(56, 44, 50))
    d.ellipse([570, 110, 710, 250], fill=(220, 196, 130))                              # the great clock
    d.line([(640, 180), (640, 120)], fill=(30, 20, 16), width=8)
    d.line([(640, 180), (650, 122)], fill=(30, 20, 16), width=6)
    houses(d, 600, 21, light=(255, 120, 60), dark=(26, 22, 34))
    rnd = random.Random(6)
    for i in range(18):                                                                 # red machines on the roofs
        x, y = rnd.randint(20, 1260), rnd.randint(300, 560)
        d.rectangle([x, y, x + 22, y + 30], fill=(160, 120, 60))
        d.rectangle([x + 4, y + 6, x + 18, y + 16], fill=(190, 40, 36))
    for x in (180, 470, 900, 1130):                                                     # fires in the streets
        glow(im, x, 620, 120, (255, 110, 40), 0.55)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 600, W, H], fill=(60, 56, 70))
    d.rectangle([0, 520, 160, H], fill=(70, 66, 74))                                   # the gate's arch, left
    d.rectangle([1120, 520, W, H], fill=(70, 66, 74))
    d.polygon([(560, 853), (600, 640), (660, 640), (700, 853)], fill=(30, 24, 26))      # Hollweg from behind, cloaked
    d.ellipse([608, 596, 652, 642], fill=(120, 110, 100))
    for i, x in enumerate([260, 330, 400, 860, 930]):                                   # townsfolk and purple coats
        d.rectangle([x, 690, x + 34, 800], fill=(90, 40, 110) if i % 2 else (90, 70, 50))
        d.ellipse([x + 4, 660, x + 30, 690], fill=(200, 170, 140))
    d.rectangle([980, 700, 1110, 770], fill=(80, 56, 36))                              # the cart
    d.ellipse([990, 750, 1030, 790], fill=(40, 30, 20))
    d.ellipse([1060, 750, 1100, 790], fill=(40, 30, 20))
    snow(im, 500, 7, 130)
    return paint(im, 6)


def c07():
    im = grad((150, 156, 166), (200, 196, 186))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 560, W, H], fill=(110, 116, 126))                                  # the river
    d.polygon([(650, 560), (1230, 560), (1160, 470), (700, 470)], fill=(70, 52, 40))   # the ship
    d.line([(930, 470), (930, 60)], fill=(60, 44, 34), width=12)
    d.line([(820, 470), (820, 140)], fill=(60, 44, 34), width=9)
    d.polygon([(936, 80), (1100, 120), (936, 380)], fill=(220, 214, 200))
    d.rectangle([0, 500, 640, 600], fill=(96, 84, 70))                                 # the quay
    for i, x in enumerate([120, 260, 400]):                                             # the crates
        d.rectangle([x, 380, x + 120, 500], fill=(130, 96, 60))
        d.line([(x, 440), (x + 120, 440)], fill=(90, 64, 40), width=4)
        gear(d, x + 60, 420, 18, (110, 80, 50), 8, (90, 64, 40))                      # a gear seal, no words
    d.line([(400, 470), (520, 460)], fill=(40, 26, 20), width=5)                        # the split plank
    glow(im, 460, 466, 40, (230, 70, 40), 0.7)
    d = ImageDraw.Draw(im)
    for x in (560, 600):                                                                # dockers
        d.rectangle([x, 420, x + 26, 500], fill=(70, 60, 50))
        d.ellipse([x + 2, 392, x + 24, 418], fill=(200, 170, 140))
    for x, y in [(300, 160), (360, 130), (520, 200)]:                                   # gulls
        d.arc([x, y, x + 30, y + 16], 200, 340, fill=(240, 240, 240), width=3)
        d.arc([x + 26, y, x + 56, y + 16], 200, 340, fill=(240, 240, 240), width=3)
    return paint(im, 7)


for i, fn in enumerate([c01, c02, c03, c04, c05, c06, c07], 1):
    p = os.path.join(OUT, "c01_%02d.jpg" % i)
    fn().convert("RGB").save(p, quality=86)
    print("wrote", os.path.normpath(p))
