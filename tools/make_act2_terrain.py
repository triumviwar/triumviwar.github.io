"""Act 2's three Brazilian ground looks, STAND-IN art drawn in code (docs/act2_terrain_art.md):
VÁRZEA (the flooded forest by the rivers), HIGHLANDS (the southern highlands: araucaria,
cold grass, grey rock) and SERTÃO (the dry backlands: cracked red-brown earth, thorn scrub,
cactus, pale dust).

   python3 tools/make_act2_terrain.py            (every set and prop, then the data file)
   python3 tools/make_act2_terrain.py --sheet out.png   (also a contact sheet)
   python3 tools/make_act2_terrain.py --data      (only scripts/terrain_act2.gd, from the
                                                   pictures already in assets/)

-> assets/terrain/<set>_<n>.png: ground sets 64 x 64 (laid over 2 x 2 cells, like the second
   atlas), cliff faces and tops 32 x 32; assets/props/<name>.png; scripts/terrain_act2.gd
   (counts, the variants that tile best, average colours, the props' sizes and kinds).
The owner's ChatGPT pictures replace these by tools/import_act2_terrain.py, which writes the
same files (and the same data file through write_data below)."""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
TER = os.path.join(ROOT, "assets", "terrain")
PROPS_DIR = os.path.join(ROOT, "assets", "props")
DATA = os.path.join(ROOT, "scripts", "terrain_act2.gd")

# set name -> number of variants. Ground sets are 64 x 64, faces and tops 32 x 32.
GROUND = {
    "varzea": 6, "varzea_mud": 6, "varzea_water": 6,
    "highland": 6, "highland_earth": 6, "highland_rock": 6,
    "sertao": 6, "sertao_dust": 6, "sertao_rock": 6,
}
EDGES = ["varzea", "highland", "sertao"]      # each gets <name>_face_0/1 and <name>_top_0/1

# prop name -> [solid cells, kind for the map editor's palette]
PROPS = {
    "varzea_tree": [1, "trees"], "buriti": [1, "trees"], "aninga": [0, "plants"],
    "floating_grass": [0, "plants"], "varzea_snag": [0, "trees"],
    "araucaria": [1, "trees"], "araucaria_young": [1, "trees"], "highland_boulder": [1, "rocks"],
    "cold_tussock": [0, "plants"], "mist_wisp": [0, "plants"],
    "mandacaru": [1, "trees"], "caatinga_tree": [1, "trees"], "caatinga_bush": [0, "plants"],
    "xique_xique": [0, "plants"], "ox_skull": [0, "plants"], "sertao_stones": [0, "rocks"],
}


# ------------------------------------------------------------------ noise and paint

def tile_noise(rng, size, cells):
    """Smooth value noise that wraps at the picture's edges (a tile that repeats seamlessly)."""
    g = rng.random((cells, cells))
    t = np.arange(size) * cells / size
    i0 = np.floor(t).astype(int)
    f = t - i0
    f = f * f * (3 - 2 * f)
    i1 = (i0 + 1) % cells
    a = g[i0][:, i0]
    b = g[i0][:, i1]
    c = g[i1][:, i0]
    d = g[i1][:, i1]
    fx = f[None, :]
    fy = f[:, None]
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


def fbm(rng, size, octaves=((4, 0.55), (8, 0.3), (16, 0.15))):
    out = np.zeros((size, size))
    for cells, w in octaves:
        out += tile_noise(rng, size, cells) * w
    lo, hi = out.min(), out.max()
    return (out - lo) / max(hi - lo, 1e-6)


def ramp(field, palette):
    """A field 0..1 painted in a few flat tones (the art's posterised, painted look)."""
    pal = np.array(palette, dtype=float)
    idx = np.clip((field * len(pal)).astype(int), 0, len(pal) - 1)
    return pal[idx]


def voronoi_edges(rng, size, n):
    """Distance to the nearest crack between wrapped cells (cracked earth)."""
    pts = []
    while len(pts) < n:                      # points kept apart (no sliver plates)
        q = rng.random(2) * size
        ok = True
        for o in pts:
            dx = abs(q[0] - o[0])
            dy = abs(q[1] - o[1])
            if math.hypot(min(dx, size - dx), min(dy, size - dy)) < size / math.sqrt(n) * 0.6:
                ok = False
                break
        if ok:
            pts.append(q)
    yy, xx = np.mgrid[0:size, 0:size]
    best = np.full((size, size), 1e9)
    second = np.full((size, size), 1e9)
    for px, py in pts:
        dx = np.abs(xx - px)
        dx = np.minimum(dx, size - dx)
        dy = np.abs(yy - py)
        dy = np.minimum(dy, size - dy)
        d = np.sqrt(dx * dx + dy * dy)
        nb = np.minimum(best, d)
        second = np.where(d < best, best, np.minimum(second, d))
        best = nb
    return second - best


def strokes(img, rng, n, colours, length=(2, 4), slant=(-0.4, 0.4), size=None):
    """Short grass blades (wrapping at the edges)."""
    size = size or img.shape[0]
    for _ in range(n):
        x = rng.integers(0, size)
        y = rng.integers(0, size)
        L = rng.integers(length[0], length[1] + 1)
        s = rng.uniform(*slant)
        c = colours[rng.integers(0, len(colours))]
        for k in range(L):
            img[(y - k) % size, int(round(x + s * k)) % size] = c


def dots(img, rng, n, colours, r=(0, 1), shade=None):
    size = img.shape[0]
    for _ in range(n):
        x = rng.integers(0, size)
        y = rng.integers(0, size)
        rr = rng.integers(r[0], r[1] + 1)
        c = np.array(colours[rng.integers(0, len(colours))], dtype=float)
        for dy in range(-rr, rr + 1):
            for dx in range(-rr, rr + 1):
                if dx * dx + dy * dy <= rr * rr + 0.5:
                    img[(y + dy) % size, (x + dx) % size] = c
        if shade is not None:
            img[(y + rr + 1) % size, x % size] = shade


def save_tile(arr, name):
    Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB").save(os.path.join(TER, name + ".png"))


# ------------------------------------------------------------------ the ground sets

def g_varzea(rng, S=64):
    """Wet green ground of the flooded forest: grass and leaf litter with brown puddles and
    small mats of floating grass in them."""
    f = fbm(rng, S)
    img = ramp(f, [(58, 74, 34), (70, 88, 38), (82, 98, 42), (96, 108, 48)])
    strokes(img, rng, 120, [(110, 128, 54), (52, 66, 30), (122, 134, 62)])
    wet = fbm(rng, S, ((4, 0.7), (8, 0.3)))
    pool = wet > 0.72
    rim = (wet > 0.66) & ~pool
    img[rim] = img[rim] * 0.55 + np.array([84, 66, 40]) * 0.45
    img[pool] = ramp((wet[pool] - 0.72) / 0.28, [(96, 76, 48), (88, 70, 44), (106, 86, 56)])
    shine = pool & (tile_noise(rng, S, 16) > 0.82)
    img[shine] = img[shine] * 0.6 + np.array([170, 160, 130]) * 0.4
    mats = pool & (tile_noise(rng, S, 8) > 0.66)
    img[mats] = np.array([92, 122, 50])
    dots(img, rng, 10, [(132, 92, 50), (100, 70, 40)], (0, 0))      # fallen leaves
    return img


def g_varzea_mud(rng, S=64):
    """A mud bank: dark wet brown, footprints of water, roots and a little green."""
    f = fbm(rng, S)
    img = ramp(f, [(56, 40, 28), (66, 48, 32), (76, 56, 36), (86, 64, 42)])
    wet = fbm(rng, S, ((8, 0.6), (16, 0.4)))
    shine = wet > 0.78
    img[shine] = img[shine] * 0.55 + np.array([150, 136, 110]) * 0.45
    strokes(img, rng, 22, [(54, 40, 26), (110, 88, 58)], (3, 6), (-1.5, 1.5))   # roots
    strokes(img, rng, 40, [(86, 104, 44), (70, 90, 40)], (1, 3))                  # sprouts
    return img


def g_varzea_water(rng, S=64):
    """Brown shallow flood water (the river's colour), ripples and floating grass mats."""
    f = fbm(rng, S, ((4, 0.5), (8, 0.35), (16, 0.15)))
    img = ramp(f, [(132, 104, 64), (144, 114, 70), (154, 124, 78), (164, 134, 88)])
    rip = tile_noise(rng, S, 16)
    for y in range(S):
        for x in range(S):
            if rip[y, x] > 0.66 and (y % 4 == 0):                   # ripples catching the sky
                img[y, x] = img[y, x] * 0.45 + np.array([206, 200, 178]) * 0.55
            elif rip[y, x] < 0.25 and (y % 4 == 2):
                img[y, x] = img[y, x] * 0.8
    mats = fbm(rng, S, ((4, 0.6), (8, 0.4))) > 0.74
    img[mats] = ramp(tile_noise(rng, S, 16)[mats], [(70, 104, 40), (88, 124, 46), (104, 138, 54)])
    edge = np.zeros_like(mats)
    for dy, dx in ((1, 0), (0, 1), (-1, 0), (0, -1)):
        edge |= np.roll(np.roll(mats, dy, 0), dx, 1) & ~mats
    img[edge] = img[edge] * 0.6 + np.array([40, 34, 22]) * 0.4
    return img


def g_highland(rng, S=64):
    """Cold highland grass: muted green-gold, bleached tufts, a few grey stones."""
    f = fbm(rng, S)
    img = ramp(f, [(92, 104, 62), (106, 116, 68), (120, 126, 74), (132, 132, 82)])
    strokes(img, rng, 220, [(150, 146, 92), (80, 92, 56), (164, 156, 104), (100, 112, 64)], (2, 5))
    dots(img, rng, 5, [(128, 128, 124), (110, 110, 108)], (0, 1), (62, 64, 60))
    red = fbm(rng, S, ((4, 0.7), (8, 0.3))) > 0.88                 # bare red earth
    img[red] = img[red] * 0.35 + np.array([130, 72, 48]) * 0.65
    return img


def g_highland_earth(rng, S=64):
    """Terra roxa: the dark red highland earth, trodden, with tufts of cold grass."""
    f = fbm(rng, S)
    img = ramp(f, [(98, 56, 40), (110, 64, 46), (122, 74, 52), (132, 84, 60)])
    dots(img, rng, 18, [(156, 100, 72), (90, 44, 30)], (0, 0))
    strokes(img, rng, 50, [(110, 120, 66), (130, 130, 78)], (2, 4))
    return img


def g_highland_rock(rng, S=64):
    """Grey highland rock in flat slabs with lichen."""
    e = voronoi_edges(rng, S, 7)
    f = fbm(rng, S)
    img = ramp(f, [(104, 106, 104), (118, 120, 116), (132, 132, 128), (146, 146, 140)])
    img[e < 1.6] = np.array([70, 72, 72])
    img[(e >= 1.6) & (e < 2.6)] = img[(e >= 1.6) & (e < 2.6)] * 0.85
    lich = tile_noise(rng, S, 16) > 0.8
    img[lich] = img[lich] * 0.5 + np.array([150, 150, 92]) * 0.5
    return img


def g_sertao(rng, S=64):
    """Cracked red-brown earth of the dry backlands."""
    e = voronoi_edges(rng, S, 6)
    f = fbm(rng, S)
    img = ramp(f, [(140, 86, 54), (150, 94, 59), (160, 103, 65), (170, 113, 72)])
    patch = fbm(rng, S, ((4, 0.7), (8, 0.3))) > 0.4                # cracked in patches, smooth between
    lift = (e >= 1.0) & (e < 2.2) & patch                          # the plates' lit lip
    img[lift] = img[lift] * 0.85 + np.array([196, 150, 106]) * 0.15
    crack = (e < 1.0) & patch
    img[crack] = img[crack] * 0.55 + np.array([90, 54, 36]) * 0.45
    dots(img, rng, 6, [(186, 160, 124), (120, 96, 70)], (0, 0))
    return img


def g_sertao_dust(rng, S=64):
    """Pale dust and sand of the sertão roads, pebbles and dry twigs."""
    f = fbm(rng, S)
    img = ramp(f, [(176, 146, 108), (186, 156, 116), (196, 166, 124), (204, 176, 134)])
    dots(img, rng, 14, [(140, 112, 84), (160, 132, 98), (214, 194, 160)], (0, 1), (130, 104, 78))
    strokes(img, rng, 14, [(120, 96, 70), (100, 80, 60)], (3, 5), (-2, 2))
    return img


def g_sertao_rock(rng, S=64):
    """Layered red sandstone of the sertão's hills."""
    f = fbm(rng, S)
    yy = np.arange(S)[:, None] * np.ones((1, S))
    band = (np.sin(yy * 2 * math.pi * 4 / S + f * 5) + 1) / 2
    img = ramp(band * 0.6 + f * 0.4, [(128, 70, 44), (146, 82, 50), (164, 98, 60), (180, 116, 74)])
    dots(img, rng, 8, [(98, 54, 36)], (0, 1))
    return img


def face(rng, kind, S=32):
    """A cliff face: vertical rock or a muddy bank, darker toward its foot."""
    yy = np.arange(S)[:, None] * np.ones((1, S))
    cols = tile_noise(rng, S, 8)
    f = fbm(rng, S, ((4, 0.5), (8, 0.5)))
    if kind == "varzea":
        img = ramp(f, [(60, 44, 30), (74, 56, 36), (86, 66, 42), (98, 76, 50)])
        strokes(img, rng, 26, [(46, 34, 22), (110, 88, 58)], (5, 10), (-0.3, 0.3))
        img[:4] = ramp(tile_noise(rng, S, 8)[:4], [(62, 84, 34), (82, 100, 42)])
    elif kind == "highland":
        img = ramp(cols * 0.7 + f * 0.3, [(78, 80, 82), (96, 98, 98), (112, 114, 112), (128, 128, 124)])
        for x in range(0, S, 5):
            img[:, (x + rng.integers(0, 2)) % S] *= 0.7               # basalt columns
        img[:3] = ramp(tile_noise(rng, S, 8)[:3], [(100, 110, 64), (122, 126, 74)])
    else:
        band = (np.sin(yy * 2 * math.pi * 3 / S + f * 3) + 1) / 2
        img = ramp(band * 0.7 + cols * 0.3, [(110, 58, 38), (132, 72, 46), (152, 88, 56), (168, 104, 66)])
    shade = np.linspace(1.08, 0.72, S)[:, None, None]
    return img * shade


def top(rng, kind, S=32):
    gen = {"varzea": g_varzea, "highland": g_highland, "sertao": g_sertao}[kind]
    return gen(rng, S) * 1.06


GEN = {"varzea": g_varzea, "varzea_mud": g_varzea_mud, "varzea_water": g_varzea_water,
       "highland": g_highland, "highland_earth": g_highland_earth, "highland_rock": g_highland_rock,
       "sertao": g_sertao, "sertao_dust": g_sertao_dust, "sertao_rock": g_sertao_rock}


# ------------------------------------------------------------------ the props

def finish(im, outline=(28, 22, 16, 255)):
    """A one-pixel dark outline round the shape (the painted props all have one)."""
    a = np.array(im)
    alpha = a[:, :, 3] > 40
    ring = np.zeros_like(alpha)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        ring |= np.roll(np.roll(alpha, dy, 0), dx, 1)
    ring &= ~alpha
    a[ring] = outline
    return Image.fromarray(a, "RGBA")


def blob(d, cx, cy, rx, ry, col, rng, n=10, jitter=0.35):
    pts = []
    for k in range(n):
        t = 2 * math.pi * k / n
        r = 1 + rng.uniform(-jitter, jitter)
        pts.append((cx + math.cos(t) * rx * r, cy + math.sin(t) * ry * r))
    d.polygon(pts, fill=col)


def shaded_blob(d, cx, cy, rx, ry, base, rng, n=10):
    """A leafy or rocky lump lit from the upper left (dark, mid, light)."""
    dk = tuple(int(c * 0.65) for c in base) + (255,)
    lt = tuple(min(255, int(c * 1.3)) for c in base) + (255,)
    blob(d, cx + 1, cy + 1, rx, ry, dk, rng, n)
    blob(d, cx, cy, rx * 0.88, ry * 0.85, tuple(base) + (255,), rng, n)
    blob(d, cx - rx * 0.3, cy - ry * 0.3, rx * 0.45, ry * 0.4, lt, rng, n)


def p_araucaria(rng, h=88):
    """The Paraná pine: a straight trunk and upturned branches ending in tufts, a flat
    candelabra crown."""
    w = 56
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    cx = w // 2
    d.rectangle([cx - 2, 18, cx + 2, h - 2], fill=(92, 62, 44, 255))
    d.line([cx - 1, 20, cx - 1, h - 3], fill=(124, 90, 64, 255))
    tiers = [(32, 23), (24, 19), (16, 14)]
    for i, (y0, span) in enumerate(tiers):
        for side in (-1, 1):
            ex = cx + side * span
            ey = y0 - 6
            d.line([cx, y0 + 6, ex, ey + 4], fill=(84, 58, 40, 255), width=2)
            shaded_blob(d, cx + side * span * 0.55, ey - 1, 6, 3, (42, 78, 48), rng, 8)
            shaded_blob(d, ex, ey, 8 - i, 5, (46, 86, 52), rng, 8)
    shaded_blob(d, cx, 9, 12, 6, (50, 92, 56), rng, 10)
    return finish(im)


def p_araucaria_young(rng):
    im = Image.new("RGBA", (34, 52), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rectangle([16, 14, 18, 50], fill=(92, 62, 44, 255))
    for y0, span in ((30, 12), (20, 9)):
        for side in (-1, 1):
            d.line([17, y0 + 4, 17 + side * span, y0 - 2], fill=(84, 58, 40, 255), width=2)
            shaded_blob(d, 17 + side * span, y0 - 4, 5, 3, (52, 92, 58), rng, 8)
    shaded_blob(d, 17, 9, 6, 4, (56, 96, 60), rng, 8)
    return finish(im)


def p_rock(rng, w, h, base, lichen=None):
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    shaded_blob(d, w / 2, h * 0.58, w * 0.42, h * 0.38, base, rng, 9)
    if lichen:
        for _ in range(5):
            x = rng.integers(w // 4, 3 * w // 4)
            y = rng.integers(h // 3, 2 * h // 3)
            d.point((x, y), fill=lichen + (255,))
            d.point((x + 1, y), fill=lichen + (255,))
    return finish(im)


def p_tussock(rng, w, h, cols):
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for _ in range(26):
        x0 = w / 2 + rng.uniform(-w * 0.2, w * 0.2)
        x1 = x0 + rng.uniform(-w * 0.45, w * 0.45)
        y1 = rng.uniform(1, h * 0.5)
        d.line([x0, h - 1, x1, y1], fill=tuple(cols[rng.integers(0, len(cols))]) + (255,))
    return finish(im, (40, 36, 24, 255))


def p_mist(rng):
    """A low bank of mist: see-through, no outline."""
    w, h = 64, 18
    a = np.zeros((h, w, 4), dtype=np.uint8)
    yy, xx = np.mgrid[0:h, 0:w]
    v = np.exp(-(((xx - w / 2) / (w * 0.42)) ** 2) - (((yy - h * 0.55) / (h * 0.36)) ** 2))
    n = tile_noise(rng, 64, 8)[:h, :w]
    v = v * (0.6 + 0.4 * n)
    a[:, :, 0:3] = (226, 230, 232)
    a[:, :, 3] = np.clip(v * 120, 0, 255).astype(np.uint8)
    return Image.fromarray(a, "RGBA")


def p_mandacaru(rng):
    """The mandacaru: a tall column cactus with arms that turn up like a candelabra."""
    w, h = 34, 64
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    g, gd, gl = (74, 118, 82, 255), (48, 82, 58, 255), (112, 156, 112, 255)

    def column(x0, y0, x1, y1, r):
        d.rounded_rectangle([x0 - r, y0, x0 + r, y1], radius=r, fill=g)
        d.line([x0 + r - 1, y0 + r, x0 + r - 1, y1], fill=gd)
        d.line([x0 - r + 2, y0 + r, x0 - r + 2, y1], fill=gl)
        d.line([x0, y0 + r, x0, y1], fill=gd)

    column(17, 4, 17, h - 1, 5)
    d.rounded_rectangle([5, 30, 17, 35], radius=2, fill=g)
    column(7, 14, 7, 34, 3)
    d.rounded_rectangle([17, 38, 29, 43], radius=2, fill=g)
    column(27, 22, 27, 42, 3)
    for y in range(8, h - 4, 5):                                     # spines
        d.point((11, y), fill=(230, 220, 180, 255))
        d.point((23, y + 2), fill=(230, 220, 180, 255))
    d.ellipse([14, 2, 20, 6], fill=(214, 200, 170, 255))            # a pale flower bud
    return finish(im, (30, 40, 28, 255))


def p_xique(rng):
    """Xique-xique: a low, sprawling cactus."""
    w, h = 28, 18
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for x0, x1, y1 in ((14, 4, 4), (14, 24, 6), (14, 13, 1), (12, 7, 10), (16, 22, 11)):
        d.line([x0, h - 1, x1, y1], fill=(80, 122, 84, 255), width=3)
        d.line([x0 - 1, h - 1, x1 - 1, y1], fill=(110, 150, 108, 255))
    return finish(im, (30, 40, 28, 255))


def p_caatinga_bush(rng):
    """Thorn scrub: grey-white bare twigs, a few small olive leaves."""
    w, h = 36, 28
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for _ in range(16):
        x0 = w / 2 + rng.uniform(-3, 3)
        ang = rng.uniform(-2.6, -0.5)
        L = rng.uniform(9, 15)
        x1, y1 = x0 + math.cos(ang) * L, h - 2 + math.sin(ang) * L
        d.line([x0, h - 2, x1, y1], fill=(150, 140, 126, 255))
        d.line([x1, y1, x1 + rng.uniform(-4, 4), y1 - rng.uniform(2, 5)], fill=(176, 168, 152, 255))
        if rng.random() < 0.5:
            d.point((int(x1), int(y1)), fill=(118, 122, 70, 255))
            d.point((int(x1) + 1, int(y1)), fill=(118, 122, 70, 255))
    return finish(im, (56, 48, 40, 255))


def p_caatinga_tree(rng):
    """A twisted dry-forest tree, pale bark, a thin crown of small leaves."""
    w, h = 52, 70
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    bark, bark_l = (150, 136, 118, 255), (188, 178, 160, 255)
    d.line([26, h - 1, 24, 40, 28, 28], fill=bark, width=4, joint="curve")
    d.line([25, h - 2, 23, 42], fill=bark_l)
    for ex, ey in ((10, 18), (42, 16), (26, 8), (16, 30), (38, 30)):
        d.line([26, 36, ex, ey], fill=bark, width=2)
    for cx, cy in ((12, 16), (40, 14), (26, 9), (18, 26), (34, 26)):
        shaded_blob(d, cx, cy, 7, 4, (112, 116, 66), rng, 8)
    return finish(im, (50, 42, 34, 255))


def p_skull(rng):
    w, h = 18, 11
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.ellipse([6, 3, 12, 10], fill=(226, 216, 192, 255))
    d.line([6, 4, 1, 1], fill=(210, 198, 170, 255), width=2)          # horns
    d.line([12, 4, 17, 1], fill=(210, 198, 170, 255), width=2)
    d.point((8, 6), fill=(60, 50, 40, 255))
    d.point((10, 6), fill=(60, 50, 40, 255))
    return finish(im, (70, 58, 44, 255))


def p_varzea_tree(rng):
    """A flooded-forest tree on spreading buttress roots, a broad dark-green crown."""
    w, h = 60, 82
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    bark, bark_d = (98, 80, 60, 255), (66, 52, 40, 255)
    d.polygon([(26, 40), (34, 40), (36, 70), (46, h - 2), (38, h - 2), (32, 74), (28, 74),
               (22, h - 2), (14, h - 2), (24, 70)], fill=bark)
    d.line([30, 42, 30, 74], fill=bark_d)
    d.line([27, 72, 18, h - 3], fill=bark_d)
    d.line([33, 72, 42, h - 3], fill=bark_d)
    d.line([12, h - 2, 48, h - 2], fill=(150, 130, 96, 255))         # the waterline
    for cx, cy, rx, ry in ((30, 22, 24, 15), (16, 30, 12, 9), (44, 30, 12, 9), (30, 12, 14, 9)):
        shaded_blob(d, cx, cy, rx, ry, (52, 96, 48), rng, 11)
    return finish(im)


def p_buriti(rng):
    """The buriti palm of the wet ground: a tall grey trunk and a round fan crown."""
    w, h = 50, 86
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rectangle([23, 22, 27, h - 2], fill=(128, 118, 100, 255))
    for y in range(26, h - 2, 4):
        d.line([23, y, 27, y], fill=(96, 88, 74, 255))
    for k in range(13):
        t = math.pi * (1.05 + k / 12 * 0.9)
        L = rng.uniform(16, 22)
        x1, y1 = 25 + math.cos(t) * L, 20 + math.sin(t) * L * 0.8
        d.line([25, 20, x1, y1], fill=(70, 120, 58, 255), width=3)
        d.line([25, 20, x1, y1 + 1], fill=(48, 88, 44, 255))
    for k in range(5):
        t = math.pi * (0.15 + k / 4 * 0.7)
        d.line([25, 20, 25 + math.cos(t) * 14, 20 + math.sin(t) * 10], fill=(110, 112, 60, 255), width=2)
    d.ellipse([20, 16, 30, 24], fill=(84, 130, 64, 255))
    return finish(im)


def p_aninga(rng):
    """Aninga: tall arrow-leaved stalks standing in shallow water."""
    w, h = 22, 28
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for x0 in (6, 11, 15):
        top_y = rng.integers(4, 10)
        d.line([x0, h - 1, x0 + rng.integers(-1, 2), top_y + 4], fill=(96, 120, 60, 255))
        lx = x0 + rng.integers(-2, 3)
        d.polygon([(lx, top_y), (lx - 4, top_y + 6), (lx + 4, top_y + 6)], fill=(82, 132, 60, 255))
        d.line([lx, top_y, lx, top_y + 5], fill=(60, 100, 46, 255))
    return finish(im, (30, 40, 24, 255))


def p_floating_grass(rng):
    w, h = 30, 12
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    shaded_blob(d, w / 2, h * 0.6, w * 0.45, h * 0.35, (90, 128, 52), rng, 12)
    for _ in range(4):
        x = rng.integers(6, w - 6)
        d.point((x, 4), fill=(186, 166, 220, 255))                    # water hyacinth flowers
    return finish(im, (40, 50, 26, 255))


def p_snag(rng):
    """A drowned log sticking out of the flood."""
    w, h = 32, 16
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.line([3, 12, 26, 6], fill=(104, 88, 70, 255), width=4)
    d.line([20, 7, 27, 1], fill=(104, 88, 70, 255), width=2)
    d.line([4, 11, 25, 5], fill=(140, 124, 102, 255))
    d.line([1, 14, 30, 14], fill=(150, 130, 96, 255))
    return finish(im)


def make_props(rng):
    out = {
        "araucaria": p_araucaria(rng), "araucaria_young": p_araucaria_young(rng),
        "highland_boulder": p_rock(rng, 38, 30, (120, 122, 118), (150, 150, 96)),
        "cold_tussock": p_tussock(rng, 22, 18, [(160, 152, 96), (126, 130, 80), (178, 168, 112)]),
        "mist_wisp": p_mist(rng),
        "mandacaru": p_mandacaru(rng), "caatinga_tree": p_caatinga_tree(rng),
        "caatinga_bush": p_caatinga_bush(rng), "xique_xique": p_xique(rng), "ox_skull": p_skull(rng),
        "sertao_stones": p_rock(rng, 22, 14, (150, 96, 64)),
        "varzea_tree": p_varzea_tree(rng), "buriti": p_buriti(rng), "aninga": p_aninga(rng),
        "floating_grass": p_floating_grass(rng), "varzea_snag": p_snag(rng),
    }
    for name, im in out.items():
        im.save(os.path.join(PROPS_DIR, name + ".png"))


# ------------------------------------------------------------------ the data file

def seam_score(path):
    """How well a picture tiles with itself: the jump across its edges (lower is better)."""
    a = np.asarray(Image.open(path).convert("RGB"), dtype=float)
    return float(np.abs(a[0] - a[-1]).mean() + np.abs(a[:, 0] - a[:, -1]).mean())


def write_data():
    """scripts/terrain_act2.gd from the pictures in assets/ (both the stand-ins and the
    owner's imports)."""
    sets = {}
    for s, n in GROUND.items():
        sets[s] = n
    for e in EDGES:
        sets[e + "_face"] = 2
        sets[e + "_top"] = 2
    counts, good, cols = {}, {}, {}
    for s in sets:
        have = []
        k = 0
        while os.path.exists(os.path.join(TER, "%s_%d.png" % (s, k))):
            have.append(k)
            k += 1
        counts[s] = len(have)
        if s.endswith("_face") or s.endswith("_top"):
            good[s] = have
        else:
            good[s] = sorted(have, key=lambda v: seam_score(os.path.join(TER, "%s_%d.png" % (s, v))))
            arr = np.concatenate([np.asarray(Image.open(os.path.join(TER, "%s_%d.png" % (s, v))).convert("RGB"),
                                             dtype=float).reshape(-1, 3) for v in have])
            m = arr.mean(0) / 255.0
            cols[s] = m
    props = {}
    for name, (solid, kind) in PROPS.items():
        p = os.path.join(PROPS_DIR, name + ".png")
        if os.path.exists(p):
            w, h = Image.open(p).size
            props[name] = (w, h, solid, kind)
    with open(DATA, "w") as f:
        f.write("class_name TerrainAct2\n")
        f.write("## Act 2's Brazilian ground looks (VÁRZEA, HIGHLANDS, SERTÃO): written by\n")
        f.write("## tools/make_act2_terrain.py (stand-ins) and tools/import_act2_terrain.py (the owner's\n")
        f.write("## pictures). Read beside TerrainData / TerrainData2 / PropData (docs/act2_terrain_art.md).\n\n")
        f.write("## Ground sets and how many variants each has (the plain grounds are 64 x 64, laid\n## over 2 x 2 cells; faces and tops 32 x 32).\nconst COUNTS := {\n")
        for s, n in counts.items():
            f.write('\t"%s": %d,\n' % (s, n))
        f.write("}\n\n## The variants that tile best, best first.\nconst GOOD := {\n")
        for s, g in good.items():
            f.write('\t"%s": [%s],\n' % (s, ", ".join(str(v) for v in g)))
        f.write("}\n\n## Average colour of each ground set (minimap, lobby preview).\nconst COLOURS := {\n")
        for s, c in cols.items():
            f.write('\t"%s": Color(%.3f, %.3f, %.3f),\n' % (s, c[0], c[1], c[2]))
        f.write("}\n\n## The decorations: [width px, height px, cells their foot blocks (0 = walked through)].\nconst PROPS := {\n")
        for name, (w, h, solid, kind) in props.items():
            f.write('\t"%s": [%d, %d, %d],\n' % (name, w, h, solid))
        f.write("}\n\n## The map editor's palette group of each decoration.\nconst KIND := {\n")
        for name, (w, h, solid, kind) in props.items():
            f.write('\t"%s": "%s",\n' % (name, kind))
        f.write("}\n\n\n## A ground set of this file is laid over 2 x 2 cells (its plain grounds, not faces or tops).\n")
        f.write("static func is_macro(set_name: String) -> bool:\n")
        f.write('\treturn COUNTS.has(set_name) and not set_name.ends_with("_face") and not set_name.ends_with("_top")\n')


def contact_sheet(path):
    tiles = []
    for s, n in GROUND.items():
        tiles.append([os.path.join(TER, "%s_%d.png" % (s, k)) for k in range(n)])
    for e in EDGES:
        tiles.append([os.path.join(TER, "%s_%s_%d.png" % (e, part, k)) for part in ("face", "top") for k in range(2)])
    cell = 96
    rows = len(tiles) + 4
    sheet = Image.new("RGB", (cell * 6 + 10, cell * rows), (24, 24, 30))
    for r, row in enumerate(tiles):
        for c, p in enumerate(row):
            im = Image.open(p).convert("RGB").resize((cell - 4, cell - 4), Image.NEAREST)
            sheet.paste(im, (c * cell, r * cell))
    x, y = 4, len(tiles) * cell + 4
    for name in PROPS:
        im = Image.open(os.path.join(PROPS_DIR, name + ".png")).convert("RGBA")
        if x + im.width * 2 > sheet.width:
            x, y = 4, y + 2 * 92
        im = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
        bg = Image.new("RGBA", im.size, (90, 96, 80, 255))
        bg.alpha_composite(im)
        sheet.paste(bg, (x, y))
        x += im.width + 6
    sheet.save(path)


def main():
    if "--data" in sys.argv:
        write_data()
        return
    rng = np.random.default_rng(2771)
    for s, n in GROUND.items():
        for k in range(n):
            save_tile(GEN[s](rng), "%s_%d" % (s, k))
    for e in EDGES:
        for k in range(2):
            save_tile(face(rng, e), "%s_face_%d" % (e, k))
            save_tile(top(rng, e), "%s_top_%d" % (e, k))
    make_props(rng)
    write_data()
    if "--sheet" in sys.argv:
        contact_sheet(sys.argv[sys.argv.index("--sheet") + 1])
    print("act2 terrain: %d ground sets, %d props" % (len(GROUND) + 2 * len(EDGES), len(PROPS)))


if __name__ == "__main__":
    main()
