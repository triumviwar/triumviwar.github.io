"""One strip from a sprite-audit redraw (docs/sprite_hallucination_audit.md): a ChatGPT answer of one row of figures on
navy (art/redraws/<sheet>.png) cut with the shared redraw cutter onto the game's cell, scaled so the figures stand as
tall (median bounding-box height) as the reference strip's chosen frames, their feet where that strip's feet are.

Usage (repo root):
  python3 tools/import_sa_strip.py <sheet> <unit> <anim> <dir> <frames> <ref_strip> <ref_frames> [ref_pick,...] [sheet_pick,...]
e.g. python3 tools/import_sa_strip.py rebel_pikeman_walk_s_chatgpt rebel_pikeman walk s 3 walk_s 3 0,1
"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from redraw_lib import BG, col_boxes, cut, defringe, load_sheet, save_strip, to_cell  # noqa: E402
from scipy import ndimage  # noqa: E402


def frames_of(path, n):
    a = np.array(Image.open(path))
    w = a.shape[1] // n
    return [a[:, i * w:(i + 1) * w] for i in range(n)]


def box(m):
    ys, xs = np.nonzero(m)
    return xs.min(), ys.min(), xs.max(), ys.max()


def by_parts(px, fg, n):
    """The n biggest joined shapes of the sheet, left to right (when the figures' columns overlap, e.g. a long pike
    reaching over the next figure's column)."""
    m = ndimage.binary_closing(fg, iterations=1) | fg
    lab, k = ndimage.label(m, structure=np.ones((3, 3)))
    sizes = ndimage.sum(m, lab, range(1, k + 1))
    big = sorted(np.argsort(sizes)[::-1][:n] + 1, key=lambda i: np.nonzero(lab == i)[1].mean())
    out = []
    for i in big:
        img = np.zeros(fg.shape + (4,), np.uint8)
        img[..., :3] = px
        img[..., 3] = np.where(lab == i, 255, 0)
        out.append(defringe(img, BG.astype(float)))
    return out


def main():
    sheet, unit, anim, d, n, ref, rn = sys.argv[1:8]
    n, rn = int(n), int(rn)
    pick = [int(x) for x in sys.argv[8].split(",")] if len(sys.argv) > 8 else list(range(rn))
    # the answer's frames whose height is measured (default all; leave out frames with a raised weapon)
    spick = [int(x) for x in sys.argv[9].split(",")] if len(sys.argv) > 9 else None
    refs = frames_of("assets/units/%s/%s.png" % (unit, ref), rn)
    cell = (refs[0].shape[1], refs[0].shape[0])
    rb = [box(refs[i][..., 3] > 0) for i in pick]
    want_h = float(np.median([b[3] - b[1] + 1 for b in rb]))
    feet_y = int(np.median([b[3] for b in rb])) + 1
    feet_x = int(round(np.median([np.nonzero(refs[i][..., 3] > 0)[1].mean() for i in pick])))
    px, fg = load_sheet(sheet)
    H, W = fg.shape
    figs = [cut(px, fg, (x0, 0, x1, H)) for x0, x1 in col_boxes(fg, 0, H, (0, W), n)]
    if any(not (f[..., 3] > 0).any() for f in figs):
        figs = by_parts(px, fg, n)
    hs = [box(f[..., 3] > 0) for f in figs]
    hp = hs if spick is None else [hs[i] for i in spick]
    scale = want_h / float(np.median([b[3] - b[1] + 1 for b in hp]))
    ground = float(np.median([b[3] for b in hs]))
    cells = []
    for f in figs:
        cx = float(np.nonzero(f[..., 3] > 0)[1].mean())
        cells.append(to_cell(f, scale, cell, (feet_x, feet_y), cx=cx, ground=ground))
    save_strip(unit, anim, d, cells)
    print("%s %s_%s: %d frames, cell %s, scale %.4f, feet (%d, %d)" % (unit, anim, d, n, cell, scale, feet_x, feet_y))


if __name__ == "__main__":
    main()
