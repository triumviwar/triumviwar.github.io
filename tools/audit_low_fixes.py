"""Small LOW findings of the sprite audit (docs/sprite_hallucination_audit.md), fixed without a redraw.

    python3 tools/audit_low_fixes.py

COPY: a frame that broke the loop is replaced by a good frame of the same strip.
BITS: loose specks (pieces smaller than FRAC of the frame's biggest piece) are removed.
PINK: pink/magenta keying leftovers (red and blue well over green) are removed.
Run it once: the copies, removals and reorders are then in the files (a second run would reorder again).
"""
import numpy as np
from PIL import Image
from scipy import ndimage

U = "assets/units/"
# (file, frame width, [(dst, src), ...])
COPY = [
    (U + "musketeer/idle_n.png", 90, [(2, 0)]),            # 168: frame 2 a narrower, different coat
    (U + "musketeer_armoured/idle_n.png", 90, [(2, 0)]),   # 168: the same in the Guardsman
    (U + "horseman/attack_s.png", 98, [(2, 1)]),           # 181: frame 2 the horse twists to three-quarters
    (U + "labourer/idle_keg_s.png", 42, [(0, 1)]),         # 161: the keg jumps from the chest to his side
    (U + "cuckoo/walk_ne.png", 74, [(0, 2)]),              # 141: frame 0 turned east, the rest from behind
]
# (file, frame width, new order): frames played in the wrong order
ORDER = [
    ("assets/buildings/armoury_anim_bayonet.png", 60, [0, 1, 2, 4, 3, 5]),  # 105: the pumpkin burst, then whole again
]
# (file, frame width or 0 for one picture, frames, FRAC)
BITS = [
    (U + "dismounted_armoured/death_s.png", 90, [2, 3, 4], 0.05),   # 156: specks under the body
    (U + "musketeer_armoured/fireup_s.png", 90, [0, 1], 0.05),      # 169: stray grey pixels by the knee
    ("assets/icons/tension.png", 0, [0], 0.05),                     # 200: specks in the corners
    ("assets/props/boulder_moss.png", 0, [0], 0.2),                 # 201: a loose brown piece below-right
    ("assets/props/snow_rocks_c.png", 0, [0], 0.02),                # 207: loose specks round the heap
    ("assets/props/snow_rocks_d.png", 0, [0], 0.02),
]
# (file, x below, y below or 0 = top share, also dark) : bluish backdrop left round a picture (blue well over red)
HALO = [
    ("assets/props/campfire.png", 999, 0.45, True),     # 202: the dark navy triangle behind the flames
    ("assets/props/ruin_tower.png", 20, 54, False),     # 205: the bluish ghost pixels left of the tower
]
# pictures with small loose pieces cut flat by the image edge: those pieces removed
EDGE = [
    "assets/buildings/cuckoo_house_damaged.png",           # 108: a debris piece cut at the right edge
]
PINK = [
    (U + "pendulum/attack_hi_l_n.png", 130, [4]),           # 145: pink pixels at the blade
]


def frames(a, w, idx):
    for i in idx:
        yield a[:, i * w:(i + 1) * w] if w else a


done = {}
def get(p):
    if p not in done:
        done[p] = np.array(Image.open(p).convert("RGBA"))
    return done[p]


for p, w, pairs in COPY:
    a = get(p)
    for d, s in pairs:
        a[:, d * w:(d + 1) * w] = a[:, s * w:(s + 1) * w]
for p, w, order in ORDER:
    a = get(p)
    a[:] = np.concatenate([a[:, i * w:(i + 1) * w].copy() for i in order], axis=1)
for p, w, idx, frac in BITS:
    a = get(p)
    for f in frames(a, w, idx):
        lab, k = ndimage.label(f[..., 3] > 0, structure=np.ones((3, 3)))
        if k < 2:
            continue
        sz = ndimage.sum(f[..., 3] > 0, lab, range(1, k + 1))
        for j, s in enumerate(sz):
            if s < sz.max() * frac:
                f[lab == j + 1] = 0
for p, w, idx in PINK:
    a = get(p)
    for f in frames(a, w, idx):
        r, g, b = (f[..., c].astype(int) for c in range(3))
        f[(f[..., 3] > 0) & (r > g + 60) & (b > g + 60)] = 0
for p, xmax, ymax, dark in HALO:
    a = get(p)
    b = a.astype(int)
    h, w = a.shape[:2]
    ylim = ymax * h if ymax < 1 else ymax
    yy, xx = np.mgrid[0:h, 0:w]
    m = (b[..., 2] > b[..., 0] + 15)
    if dark:
        m |= b[..., :3].max(-1) < 75
    a[(b[..., 3] > 0) & m & (xx < xmax) & (yy < ylim)] = 0
for p in EDGE:
    a = get(p)
    lab, k = ndimage.label(a[..., 3] > 0, structure=np.ones((3, 3)))
    sz = ndimage.sum(a[..., 3] > 0, lab, range(1, k + 1))
    edge = set(lab[:, 0]) | set(lab[:, -1]) | set(lab[0, :]) | set(lab[-1, :])
    for j in edge - {0}:
        if sz[j - 1] < sz.max() * 0.05:
            a[lab == j] = 0
for p, a in done.items():
    Image.fromarray(a).save(p)
    print(p)
