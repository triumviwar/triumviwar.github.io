"""The Tyrant Challenger's death seen from behind (N), from ChatGPT's answer to the sprite audit's request R2
(docs/sprite_hallucination_audit.md, 2026-11-21): art/redraws/tyrant_challenger_death_n_chatgpt.png, one row of 5
figures on navy. It replaces the old N death, whose frames were nearly the same standing pose.

Cut with the shared redraw cutter onto the 88 x 64 cell, scaled so the first frame covers as much as the N walk's first
frame in the game (the same body size rule as tools/import_brood_mature.py), its feet on the N walk's feet.

Usage (repo root): python3 tools/import_tyrant_death_n_sa.py
"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from redraw_lib import col_boxes, cut, load_sheet, save_strip, to_cell  # noqa: E402

CELL = (88, 64)
N = 5


def game_frame(path, frames, i):
    a = np.array(Image.open(path))[..., 3] > 0
    w = a.shape[1] // frames
    return a[:, i * w:(i + 1) * w]


def main():
    px, fg = load_sheet("tyrant_challenger_death_n_chatgpt")
    H, W = fg.shape
    figs = [cut(px, fg, (x0, 0, x1, H)) for x0, x1 in col_boxes(fg, 0, H, (0, W), N)]
    ref = game_frame("assets/units/tyrant_challenger/walk_n.png", 6, 0)
    ys, xs = np.nonzero(ref)
    anchor = (int(round(xs.mean())), int(ys.max()) + 1)
    a0 = figs[0][..., 3] > 0
    scale = (ref.sum() / float(a0.sum())) ** 0.5
    ground = float(np.median([np.nonzero((f[..., 3] > 0).any(1))[0].max() for f in figs]))
    cells = []
    for f in figs:
        a = f[..., 3] > 0
        cx = float(np.nonzero(a)[1].mean())
        cells.append(to_cell(f, scale, CELL, anchor, cx=cx, ground=ground))
    save_strip("tyrant_challenger", "death", "n", cells)
    print("tyrant_challenger death_n: %d frames, scale %.4f, anchor %s" % (len(cells), scale, anchor))


if __name__ == "__main__":
    main()
