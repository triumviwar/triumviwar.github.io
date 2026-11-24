#!/usr/bin/env python3
"""STAND-IN stills for Act 2's "The Siege of Concórdia" (campaign/stills/d11_01.jpg .. d11_03.jpg, 1280 x 853), until the
owner's ChatGPT paintings come (the prompts: docs/campaign_d11_build.md "Stills"). Drawn simply, in the manner of d09's
stand-ins (tools/campaign/make_d09_stills.py: its helpers copied here, as d09 copied d05's).
  d11_01 the siege lines      = earthwork batteries on a grassy plateau with araucaria pines; guns in purple-coated crews
                                fire at the brass walls and clocktower of a town; an old priest with a telescope and a
                                journeyman clockmaker listening, head cocked
  d11_02 the sortie           = at dawn brass clockwork soldiers and a spring-crossbow engine pour from a town gate onto
                                the siege lines; soldiers in purple meet them
  d11_03 Hollweg on the walls = on brass city walls at sunset an old clockmaker looks down at the siege lines; behind him,
                                very still, rows of clockwork figures
The King's pages reuse p01_01 (the King lighting his pipe).
Rebuild: python3 tools/campaign/make_d11_stills.py (replace a file by the owner's painting cut to 1280 x 853 to swap it in).
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


def wall(d, y0, y1, x0=0, x1=W, top=None):
    d.rectangle([x0, y0, x1, y1], fill=(150, 112, 60))
    for x in range(int(x0), int(x1), 40):
        d.line([(x, y0), (x, y1)], fill=(120, 88, 48), width=2)
    d.rectangle([x0, y0 - 14, x1, y0], fill=top or BRASS)
    for x in range(int(x0), int(x1), 60):
        d.rectangle([x, y0 - 30, x + 30, y0 - 14], fill=top or BRASS)


def d01():
    """The siege lines on the plateau before the brass walls."""
    im = grad((214, 222, 226), (196, 204, 190))
    d = ImageDraw.Draw(im)
    wall(d, 330, 420, 620, W)                                                                     # the town wall, far right
    d.rectangle([980, 170, 1050, 320], fill=(170, 130, 64))                                        # the clocktower
    d.ellipse([985, 180, 1045, 240], fill=(236, 220, 170), outline=(110, 80, 30), width=4)
    d.polygon([(0, 440), (W, 410), (W, H), (0, H)], fill=GRASS)                                    # the plateau
    for x in (60, 230, 470):
        araucaria(d, x, 470, 0.9)
    for i, x in enumerate((300, 520, 740)):                                                       # the batteries' earthworks
        d.polygon([(x, 600), (x + 160, 586), (x + 180, 620), (x - 10, 636)], fill=EARTH)
        cannon(d, x + 10, 560, 0.9, smoke=True, im=im)
        d = ImageDraw.Draw(im)
        figure(d, x - 30, 520, PURPLE, 80)
    figure(d, 120, 600, BLACK, 140, face=(214, 200, 186))                                          # the old priest
    d.ellipse([118, 560, 152, 576], fill=(222, 222, 226))                                          # white hair
    d.line([(150, 618), (230, 590)], fill=(60, 50, 40), width=6)                                    # the telescope
    figure(d, 200, 640, (90, 80, 70), 110)                                                         # the journeyman, listening
    return paint(im, 111)


def d02():
    """The sortie at dawn: brass soldiers and a spring engine out of a gate onto the lines."""
    im = grad((232, 196, 160), (190, 176, 150))
    d = ImageDraw.Draw(im)
    wall(d, 220, 380, 760, W)
    d.rectangle([900, 250, 1020, 380], fill=(50, 40, 34))                                          # the open gate
    d.polygon([(0, 380), (W, 380), (W, H), (0, H)], fill=GRASS)
    rnd = random.Random(112)
    for i in range(10):
        clockwork(d, 980 - i * 62 + rnd.uniform(-10, 10), 420 + (i % 3) * 40, 1.0)
    d.rectangle([700, 560, 860, 600], fill=(150, 112, 60))                                         # the spring engine
    d.line([(700, 560), (640, 520)], fill=(90, 70, 30), width=8)
    d.ellipse([720, 590, 760, 630], fill=(80, 60, 30))
    d.ellipse([800, 590, 840, 630], fill=(80, 60, 30))
    d.polygon([(0, 640), (520, 610), (540, 660), (0, 700)], fill=EARTH)                           # the earthworks
    for i in range(7):
        figure(d, 60 + i * 64, 560 + (i % 2) * 12, PURPLE, 90, plate=(i % 3 == 0))
    glow(im, 520, 560, 60, (240, 236, 226), 0.6)
    return paint(im, 112)


def d03():
    """Hollweg on his wall at sunset, the clockwork figures still behind him."""
    im = grad((226, 150, 96), (90, 60, 70))
    d = ImageDraw.Draw(im)
    d.polygon([(0, 640), (W, 600), (W, H), (0, H)], fill=(70, 80, 56))                           # the plateau below, far
    for i in range(9):
        d.rectangle([80 + i * 130, 630 - i * 3, 140 + i * 130, 640 - i * 3], fill=EARTH)         # the lines, small
    wall(d, 470, H, 0, W, top=(170, 130, 64))
    for i in range(8):                                                                             # the still figures
        clockwork(d, 560 + i * 86, 330, 1.2, col=(160, 120, 60))
    figure(d, 300, 300, (40, 44, 70), 170, face=(214, 196, 180))                                   # the old clockmaker
    d.ellipse([296, 262, 334, 282], fill=(220, 220, 224))
    glow(im, 160, 160, 140, (255, 210, 150), 0.5)                                                  # the low sun
    return paint(im, 113)


if __name__ == "__main__":
    for i, fn in enumerate([d01, d02, d03], 1):
        p = os.path.join(OUT, "d11_%02d.jpg" % i)
        fn().convert("RGB").save(p, quality=86)
        print("wrote", os.path.normpath(p))
