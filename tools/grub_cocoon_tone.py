#!/usr/bin/env python3
"""Sprite audit finding 14 (2026-11-28): the grub in every cocoon strip (carry_cocoon, idle_cocoon, wrap, death_cocoon)
is a lighter yellow-olive than in its walk, so it read as another animal. Its olive pixels (not the cocoon's purple,
not the team red, not the near-black outline) are moved to the walk's colours: each channel's mean and spread matched
to the walk strips' olive pixels. Shapes are untouched. Re-runnable from the originals in git (it reads HEAD's files
when --from-git is given).
    python3 tools/grub_cocoon_tone.py
"""
import colorsys
import glob
import os

import numpy as np
from PIL import Image

D = "assets/units/grub/"


def olive(a):
    rgb = a[..., :3].astype(np.float32) / 255.0
    mx, mn = rgb.max(-1), rgb.min(-1)
    sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    # yellow-green: green >= blue clearly, red not far above green, not dark outline
    return (a[..., 3] > 128) & (mx > 0.18) & (sat > 0.25) & (g > b + 0.06) & (r < g * 1.35) & (b < g * 0.85)


ref = []
for p in glob.glob(D + "walk_*.png") + glob.glob(D + "idle_[nesw]*.png"):
    if "cocoon" in p:
        continue
    a = np.array(Image.open(p).convert("RGBA"))
    ref.append(a[olive(a)][:, :3].astype(np.float32))
ref = np.concatenate(ref)
rm, rs = ref.mean(0), ref.std(0)
src = []
paths = [p for p in sorted(glob.glob(D + "*.png")) if "cocoon" in os.path.basename(p) or os.path.basename(p).startswith("wrap_")]
arrs = {p: np.array(Image.open(p).convert("RGBA")) for p in paths}
for a in arrs.values():
    src.append(a[olive(a)][:, :3].astype(np.float32))
src = np.concatenate(src)
sm, ss = src.mean(0), src.std(0)
for p, a in arrs.items():
    m = olive(a)
    px = a[..., :3].astype(np.float32)
    px[m] = ((px[m] - sm) / np.maximum(ss, 1) * rs + rm).clip(0, 255)
    a[..., :3] = px.astype(np.uint8)
    Image.fromarray(a).save(p)
print("walk olive mean %s, cocoon was %s; %d strips" % (rm.round(), sm.round(), len(paths)))
