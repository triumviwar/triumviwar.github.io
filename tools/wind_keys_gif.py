"""The wind-up keys' films (tools/shot_wind_keys.gd's film/<kind>_NN.png) as one gif per unit, the eight facings side by
side (S SE E NE fully wound, N NW W SW run down to 35%), cropped to the units.

Usage (repo root): python3 tools/wind_keys_gif.py <shot dir> <out dir>
"""
import glob
import os
import sys

import numpy as np
from PIL import Image


GAP = {"clock_soldier": 50, "springer": 64, "netter": 72, "pendulum": 84, "cuckoo": 60, "ticking_owl": 74}
ROW_UP = {"clock_soldier": 50, "springer": 66, "netter": 50, "pendulum": 88, "cuckoo": 40, "ticking_owl": 72}   # unit heights


def main():
    src, out = sys.argv[1], sys.argv[2]
    os.makedirs(out, exist_ok=True)
    kinds = sorted({os.path.basename(f).rsplit("_", 1)[0] for f in glob.glob(f"{src}/film/*.png")})
    for k in kinds:
        files = sorted(glob.glob(f"{src}/film/{k}_*.png"))[:16]      # (16 frames: a turn and a third at full wind)
        ims = [np.array(Image.open(f).convert("RGB")) for f in files]
        # the row: eight units GAP apart round the middle of the picture (the camera at 2x on it)
        h, w = ims[0].shape[:2]
        half = int(4 * GAP.get(k, 60) * 2 + 30)
        feet = h // 2 + (0 if k == "pendulum" else 40)        # (shot_wind_keys.gd's film camera)
        box = (max(w // 2 - half, 0), max(feet - int(ROW_UP.get(k, 60) * 2) - 14, 0), min(w // 2 + half, w),
               min(feet + 18, h))
        frames = [Image.fromarray(i).crop(box) for i in ims]
        frames = [f.convert("P", palette=Image.ADAPTIVE, colors=128) for f in frames]
        frames[0].save(f"{out}/{k}.gif", save_all=True, append_images=frames[1:], duration=70, loop=0, optimize=True)
        print(k, box, len(frames))


if __name__ == "__main__":
    main()
