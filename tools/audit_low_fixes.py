"""Small LOW findings of the sprite audit (docs/sprite_hallucination_audit.md), fixed without a redraw.

    python3 tools/audit_low_fixes.py

COPY: a frame that broke the loop is replaced by a good frame of the same strip.
BITS: loose specks (pieces smaller than FRAC of the frame's biggest piece) are removed.
PINK: pink/magenta keying leftovers (red and blue well over green) are removed.
Running it twice does nothing more (the copies and removals are already made).
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
# (file, frame width or 0 for one picture, frames, FRAC)
BITS = [
    (U + "dismounted_armoured/death_s.png", 90, [2, 3, 4], 0.05),   # 156: specks under the body
    (U + "musketeer_armoured/fireup_s.png", 90, [0, 1], 0.05),      # 169: stray grey pixels by the knee
    ("assets/icons/tension.png", 0, [0], 0.05),                     # 200: specks in the corners
    ("assets/props/boulder_moss.png", 0, [0], 0.2),                 # 201: a loose brown piece below-right
    ("assets/props/snow_rocks_c.png", 0, [0], 0.02),                # 207: loose specks round the heap
    ("assets/props/snow_rocks_d.png", 0, [0], 0.02),
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
for p, a in done.items():
    Image.fromarray(a).save(p)
    print(p)
