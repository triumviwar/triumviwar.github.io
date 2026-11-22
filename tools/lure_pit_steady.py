"""Sprite audit findings 17 and 18: in the Sire lures' arrival (12 frames, south-east) the dug pit under the Sire is
there in some of the last six frames and missing in others, so it blinks and he floats. The pit of a frame that has it
(its earth pixels: brown and dark, not the creature's greens, reds or pale claws) is laid BEHIND every frame from the
pit's first frame on, so the ground stays under him. Run once.

    python3 tools/lure_pit_steady.py
"""
import numpy as np
from PIL import Image

# unit: (frames, the frame whose pit is copied, first frame that should stand on the pit)
LURES = {"lure_tyrannosaur": (12, 11, 6), "lure_dilophosaurus": (12, 11, 6)}


def earth(f):
    a = np.array(f).astype(int)
    r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
    mx = np.maximum(np.maximum(r, g), b)
    mn = np.minimum(np.minimum(r, g), b)
    sat = (mx - mn) / np.maximum(mx, 1)
    brown = (r >= g - 4) & (r > b) & (mx < 210) & ~((r > 170) & (g < 90))
    dark = mx < 45
    m = (al > 0) & (brown | dark)
    h = a.shape[0]
    m[: int(h * 0.62)] = False  # only the ground band at the feet
    out = np.zeros_like(a)
    out[m] = a[m]
    return Image.fromarray(out.astype(np.uint8))


for u, (n, src, first) in LURES.items():
    p = "assets/units/%s/arrive_se.png" % u
    im = Image.open(p).convert("RGBA")
    w = im.width // n
    pit = earth(im.crop((src * w, 0, (src + 1) * w, im.height)))
    for i in range(first, n):
        f = im.crop((i * w, 0, (i + 1) * w, im.height))
        g = pit.copy()
        g.alpha_composite(f)
        im.paste(g, (i * w, 0))
    im.save(p)
    print(p)
