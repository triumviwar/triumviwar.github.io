"""The Raptor's standing frames toward the viewer (S), the lower right (SE) and away (N), from ChatGPT's answer to the
sprite audit's request R1 (docs/sprite_hallucination_audit.md, 2026-11-21): art/redraws/raptor_idle_sa_chatgpt.png,
one row of 3 figures on navy (0, 22, 48). They replace the old, bulkier idle design (finding 1) with the slim walk's.

Cut like tools/import_raptor_walk_sn.py (the shared redraw cutter, the 58 x 30 cell, soles on the anchor row), scaled
so the figure stands as tall as the S walk's median frame in the game (the answer's pixel scale is ChatGPT's own).

Usage (repo root): python3 tools/import_raptor_idle_sa.py
"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from redraw_lib import col_boxes, cut, load_sheet, save_strip, to_cell, write_counts  # noqa: E402

CELL = (58, 30)
ANCHOR = (29, 28)
VIEWS = ("s", "se", "n")


def game_height(path, frames):
    a = np.array(Image.open(path))[..., 3] > 0
    w = a.shape[1] // frames
    hs = []
    for i in range(frames):
        rows = np.nonzero(a[:, i * w:(i + 1) * w].any(1))[0]
        hs.append(rows.max() - rows.min() + 1)
    return float(np.median(hs))


def main():
    px, fg = load_sheet("raptor_idle_sa_chatgpt")
    H, W = fg.shape
    figs = [cut(px, fg, (x0, 0, x1, H)) for x0, x1 in col_boxes(fg, 0, H, (0, W), 3)]
    tall = []
    for f in figs:
        rows = np.nonzero((f[..., 3] > 0).any(1))[0]
        tall.append(rows.max() - rows.min() + 1)
    want = game_height("assets/units/raptor/walk_s.png", 6)
    scale = want / float(tall[0])
    ground = float(np.median([np.nonzero((f[..., 3] > 0).any(1))[0].max() for f in figs]))
    counts = {}
    for d, f in zip(VIEWS, figs):
        a = f[..., 3] > 0
        col = a.sum(0).cumsum()
        cx = float(np.searchsorted(col, col[-1] / 2.0))
        c = to_cell(f, scale, CELL, ANCHOR, cx=cx, ground=ground)
        bot = int(np.nonzero((c[..., 3] > 0).any(1))[0].max())
        dy = min(ANCHOR[1] - bot, CELL[1] - 1 - bot)
        if dy > 0:
            c = np.concatenate([np.zeros((dy, CELL[0], 4), np.uint8), c[:-dy]], 0)
        save_strip("raptor", "idle", d, [c])
        counts["idle_%s" % d] = 1
        print("raptor idle_%s: scale %.4f" % (d, scale))
    write_counts("raptor", counts)


if __name__ == "__main__":
    main()
