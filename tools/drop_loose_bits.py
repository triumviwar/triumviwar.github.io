"""Sprite audit findings (Musketeer and Guardsman death E, frame 2): a small red-and-brown chunk lay apart to the right
of the body. In the named frames every joined piece smaller than the frame's biggest by FRAC is removed.

    python3 tools/drop_loose_bits.py
"""
import re

import numpy as np
from PIL import Image
from scipy import ndimage

JOBS = [("musketeer", "death_e", [2], 0.4), ("musketeer_armoured", "death_e", [2], 0.4)]
# the Barracks drills' mounting riders (findings 27, 28, 110, 111): rein scraps and a stray hoof left of the cut-out horse
DRILL = [("drill_cuirassier", 7), ("drill_horseman", 7), ("drill_dragoon", 6), ("drill_dragoon_armoured", 6)]
SRC = open("scripts/art_data.gd").read()

def cells():
    for u, strip, frames, frac in JOBS:
        cw = int(re.search(r'\t"%s": \{"cell": Vector2i\((\d+), ' % u, SRC).group(1))
        yield "assets/units/%s/%s.png" % (u, strip), cw, frames, frac
    for u, n in DRILL:
        p = "assets/buildings/%s/mount_e.png" % u
        w = Image.open(p).width // n
        yield p, w, range(n), 0.15


for p, cw, frames, FRAC in cells():
    a = np.array(Image.open(p).convert("RGBA"))
    for i in frames:
        f = a[:, i * cw:(i + 1) * cw]
        lab, k = ndimage.label(f[..., 3] > 0, structure=np.ones((3, 3)))
        sz = ndimage.sum(f[..., 3] > 0, lab, range(1, k + 1))
        keep = sz.max() * FRAC
        for j, s in enumerate(sz):
            if s < keep:
                f[lab == j + 1] = 0
    Image.fromarray(a).save(p)
    print(p)
