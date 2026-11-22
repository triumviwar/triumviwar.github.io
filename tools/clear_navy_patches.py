"""Sprite audit findings 20 and 23: ChatGPT's navy background trapped between the far wing's root and the neck of the
Pterodactyl and the Storm Challenger (fly loop = idle, south-east). Joined navy patches of 8+ pixels become see-through.

    python3 tools/clear_navy_patches.py
"""
import numpy as np
from PIL import Image
from scipy import ndimage

FILES = ["assets/units/pterodactyl/walk_se.png", "assets/units/pterodactyl/idle_se.png",
         "assets/units/storm_challenger/walk_se.png", "assets/units/storm_challenger/idle_se.png"]

for f in FILES:
    a = np.array(Image.open(f).convert("RGBA"))
    r, g, b, al = [a[..., i].astype(int) for i in range(4)]
    m = (al > 0) & (abs(r - 16) < 14) & (abs(g - 32) < 14) & (abs(b - 48) < 16) & (b > r)
    lab, k = ndimage.label(m)
    sz = ndimage.sum(m, lab, range(1, k + 1))
    big = np.isin(lab, [i + 1 for i, s in enumerate(sz) if s >= 8])
    a[big] = 0
    Image.fromarray(a).save(f)
    print(f, int(big.sum()), "px cleared")
