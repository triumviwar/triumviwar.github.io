#!/usr/bin/env python3
"""The Brass Serpent's stand-in icons (docs/brass_serpent.md: the real ones are to be drawn by ChatGPT, prompts there;
listed in docs/art_style_inconsistency.md). The frame and the dark field are cut from an existing Clockwork command icon
(assets/icons/clockwork/ab_mend.png); the gears and the head are drawn here at 4x and scaled down.
    python3 tools/serpent/make_icons.py
"""
import math
from PIL import Image, ImageDraw, ImageFilter

ROOT = __import__("os").path.dirname(__file__) + "/../../"
SS = 4
BRASS = (222, 170, 78, 255)
BRASS_HI = (250, 214, 130, 255)
BRASS_DK = (104, 70, 30, 255)
RED = (235, 60, 40, 255)


def frame():
    src = Image.open(ROOT + "assets/icons/clockwork/ab_mend.png").convert("RGBA")
    im = src.copy()
    w, h = im.size
    bg = src.getpixel((12, 12))
    d = ImageDraw.Draw(im)
    for y in range(8, h - 8):
        for x in range(8, w - 8):
            t = (y - 8) / (h - 16)
            c = tuple(int(bg[i] * (1.05 - 0.25 * t)) for i in range(3)) + (255,)
            im.putpixel((x, y), c)
    return im


def gear(d, cx, cy, r, teeth, phase=0.0, col=BRASS):
    pts = []
    for i in range(teeth * 4):
        a = phase + 2 * math.pi * i / (teeth * 4)
        rr = r if (i % 4) in (0, 1) else r * 0.8
        pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
    d.polygon(pts, fill=BRASS_DK)
    d.ellipse([cx - r * 0.78, cy - r * 0.78, cx + r * 0.78, cy + r * 0.78], fill=col)
    d.ellipse([cx - r * 0.62, cy - r * 0.72, cx + r * 0.5, cy + r * 0.1], fill=BRASS_HI)
    d.ellipse([cx - r * 0.66, cy - r * 0.66, cx + r * 0.66, cy + r * 0.66], fill=col)
    d.ellipse([cx - r * 0.3, cy - r * 0.3, cx + r * 0.3, cy + r * 0.3], fill=BRASS_DK)
    d.ellipse([cx - r * 0.12, cy - r * 0.12, cx + r * 0.12, cy + r * 0.12], fill=BRASS_HI)


def head(d, cx, cy, s, ang):
    f = (math.cos(ang), math.sin(ang))
    sd = (-f[1], f[0])
    P = lambda a, b: (cx + f[0] * a * s + sd[0] * b * s, cy + f[1] * a * s + sd[1] * b * s)
    d.polygon([P(-9, 9), P(6, 8), P(16, 3), P(16, -3), P(6, -8), P(-9, -9)], fill=BRASS, outline=BRASS_DK)
    d.polygon([P(-3, 6), P(13, 4), P(16, 0), P(13, -4), P(-3, -6)], fill=BRASS_HI)
    d.polygon([P(-1, 5), P(14, 3), P(14, -3), P(-1, -5)], fill=BRASS)
    for sg in (1, -1):
        e = P(7, 4.5 * sg)
        d.ellipse([e[0] - 2.4 * s, e[1] - 2.4 * s, e[0] + 2.4 * s, e[1] + 2.4 * s], fill=RED)
    for i in range(3):
        a = P(10 + 2.5 * i, 2.5)
        b = P(10 + 2.5 * i, -2.5)
        d.line([a, b], fill=(245, 240, 220, 255), width=int(1.2 * s))


def canvas():
    return Image.new("RGBA", (64 * SS, 64 * SS), (0, 0, 0, 0))


def finish(layer, name):
    small = layer.resize((64, 64), Image.LANCZOS)
    shadow = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    a = small.split()[3].filter(ImageFilter.GaussianBlur(1.2))
    shadow.paste((0, 0, 0, 170), (1, 2), a)
    out = frame()
    out.alpha_composite(shadow)
    out.alpha_composite(small)
    out.save(ROOT + "assets/icons/" + name + ".png")
    print("wrote", name)


def serpent_body(d, k=1.0, n=5, head_on=True):
    pts = []
    for i in range(n):
        t = i / max(n - 1, 1)
        x = 48 - 34 * t
        y = 22 + 18 * math.sin(t * math.pi * 1.2)
        pts.append((x * SS, y * SS))
    for i in range(n - 1, -1, -1):
        r = (7.5 - 2.2 * i / n) * SS * k
        gear(d, pts[i][0], pts[i][1], r, 8, phase=i * 0.4)
    if head_on:
        head(d, pts[0][0] + 6 * SS, pts[0][1] - 5 * SS, SS * 1.05, -0.5)


# the unit's portrait: a curling chain of gears with the head
im = canvas(); d = ImageDraw.Draw(im)
pts = [(16, 46), (25, 50), (34, 47), (40, 39), (40, 30), (34, 23)]
for i in range(len(pts) - 1, -1, -1):
    gear(d, pts[i][0] * SS, pts[i][1] * SS, (5.5 + (3.0 if i in (2, 3) else 0.0)) * SS, 8 if i not in (2, 3) else 10, phase=i * 0.5)
head(d, 37 * SS, 15 * SS, SS * 1.15, -2.3)
# (the portrait and the gear items are the owner's painted icons since 0.38.2: tools/serpent/import_art.py)
# finish(im, "brass_serpent")
# the gear items
im = canvas(); d = ImageDraw.Draw(im); gear(d, 32 * SS, 33 * SS, 13 * SS, 8); pass  # finish(im, "serpent_gear_s")
im = canvas(); d = ImageDraw.Draw(im); gear(d, 32 * SS, 33 * SS, 21 * SS, 10); pass  # finish(im, "serpent_gear_b")
# COLLECT GEARS: two gears falling into an open hopper
im = canvas(); d = ImageDraw.Draw(im)
gear(d, 24 * SS, 20 * SS, 8 * SS, 8); gear(d, 40 * SS, 24 * SS, 6 * SS, 8, 0.4)
d.polygon([(14 * SS, 34 * SS), (50 * SS, 34 * SS), (42 * SS, 52 * SS), (22 * SS, 52 * SS)], fill=(90, 96, 110, 255), outline=(30, 30, 40, 255))
d.polygon([(26 * SS, 38 * SS), (38 * SS, 38 * SS), (32 * SS, 47 * SS)], fill=BRASS_HI)
finish(im, "clockwork/ab_serpent_collect")
# GROW: a gear with a plus
im = canvas(); d = ImageDraw.Draw(im)
gear(d, 28 * SS, 34 * SS, 15 * SS, 10)
d.rectangle([44 * SS, 12 * SS, 50 * SS, 30 * SS], fill=(120, 230, 110, 255), outline=(20, 60, 20, 255))
d.rectangle([38 * SS, 18 * SS, 56 * SS, 24 * SS], fill=(120, 230, 110, 255), outline=(20, 60, 20, 255))
d.rectangle([45 * SS, 13 * SS, 49 * SS, 29 * SS], fill=(120, 230, 110, 255))
finish(im, "clockwork/ab_serpent_grow")
# LINK: two heads on one body (a Hydra)
im = canvas(); d = ImageDraw.Draw(im)
for i, (x, y) in enumerate([(14, 50), (22, 46), (30, 42)]):
    gear(d, x * SS, y * SS, 6 * SS, 8, i * 0.5)
head(d, 38 * SS, 26 * SS, SS * 1.0, -1.2)
head(d, 46 * SS, 38 * SS, SS * 1.0, -0.3)
finish(im, "clockwork/ab_serpent_link")
# UNLINK: two serpents' gears pulled apart (a gap and arrows)
im = canvas(); d = ImageDraw.Draw(im)
gear(d, 18 * SS, 32 * SS, 9 * SS, 8); gear(d, 46 * SS, 32 * SS, 9 * SS, 8, 0.3)
for sx in (1, -1):
    x0 = 32 - sx * 3
    d.polygon([((x0 - sx * 0) * SS, 26 * SS), ((x0 - sx * 7) * SS, 32 * SS), (x0 * SS, 38 * SS)], fill=(240, 90, 70, 255))
finish(im, "clockwork/ab_serpent_unlink")
