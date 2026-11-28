#!/usr/bin/env python3
"""Sprite audit finding 12 (2026-11-28): the Brood Mother's stage-2 south walk and idle were a south-east view. Stage 2
and stage 3 are the same design (stage 3 a little bigger), so stage 3's front-on walk_s is scaled to stage 2's size
(the ratio of the two east walks' figure heights) and laid in stage 2's cell with the feet on its anchor.
    python3 tools/bm2_front_from_bm3.py
"""
import numpy as np
from PIL import Image

U = "assets/units/"
C2, A2 = (504, 369), (252, 333)
C3 = (464, 354)


def frames(path, cw):
    im = Image.open(path).convert("RGBA")
    return [im.crop((i * cw, 0, (i + 1) * cw, im.size[1])) for i in range(im.size[0] // cw)]


def bbox(fr):
    a = np.array(fr)[:, :, 3] > 20
    ys, xs = np.nonzero(a)
    return xs.min(), ys.min(), xs.max(), ys.max()


def med_h(path, cw):
    return float(np.median([bbox(f)[3] - bbox(f)[1] for f in frames(path, cw)]))


k = med_h(U + "brood_mother_2/walk_e.png", C2[0]) / med_h(U + "brood_mother_3/walk_e.png", C3[0])
src = frames(U + "brood_mother_3/walk_s.png", C3[0])
feet = max(bbox(f)[3] for f in src)
cx = np.median([(bbox(f)[0] + bbox(f)[2]) / 2 for f in src])
out = []
for f in src:
    g = f.resize((round(f.size[0] * k), round(f.size[1] * k)), Image.NEAREST)
    cell = Image.new("RGBA", C2, (0, 0, 0, 0))
    cell.alpha_composite(g, (int(round(A2[0] - cx * k)), int(round(A2[1] - feet * k))))
    out.append(cell)
strip = Image.new("RGBA", (C2[0] * len(out), C2[1]))
for i, c in enumerate(out):
    strip.alpha_composite(c, (i * C2[0], 0))
strip.save(U + "brood_mother_2/walk_s.png")
n_idle = Image.open(U + "brood_mother_2/idle_s.png").size[0] // C2[0]
idle = Image.new("RGBA", (C2[0] * n_idle, C2[1]))
for i in range(n_idle):
    idle.alpha_composite(out[0], (i * C2[0], 0))
idle.save(U + "brood_mother_2/idle_s.png")
print("scale %.3f, %d walk frames, %d idle" % (k, len(out), n_idle))
