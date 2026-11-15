"""The wind-up keys' films (tools/shot_wind_keys.gd's film/<kind>_NN.png) as one gif per unit, the eight facings side by
side (S SE E NE fully wound, N NW W SW run down to 35%), cropped to the units.

Usage (repo root): python3 tools/wind_keys_gif.py <shot dir> <out dir>
"""
import glob
import os
import sys

import numpy as np
from PIL import Image


def main():
    src, out = sys.argv[1], sys.argv[2]
    os.makedirs(out, exist_ok=True)
    kinds = sorted({os.path.basename(f).rsplit("_", 1)[0] for f in glob.glob(f"{src}/film/*.png")})
    for k in kinds:
        files = sorted(glob.glob(f"{src}/film/{k}_*.png"))
        ims = [np.array(Image.open(f).convert("RGB")) for f in files]
        # the units: where the frames differ from one another, or differ from the ground's median colour
        st = np.stack(ims).astype(int)
        moving = (st.max(0) - st.min(0)).max(-1) > 40
        ys, xs = np.nonzero(moving)
        if len(ys) == 0:
            continue
        pad = 40
        box = (max(xs.min() - pad, 0), max(ys.min() - pad, 0), min(xs.max() + pad, ims[0].shape[1]),
               min(ys.max() + pad, ims[0].shape[0]))
        frames = [Image.fromarray(i).crop(box) for i in ims]
        frames = [f.convert("P", palette=Image.ADAPTIVE, colors=255) for f in frames]
        frames[0].save(f"{out}/{k}.gif", save_all=True, append_images=frames[1:], duration=70, loop=0, optimize=True)
        print(k, box, len(frames))


if __name__ == "__main__":
    main()
