#!/usr/bin/env python3
"""The Brass Serpent's art: the owner's ChatGPT pictures (art/redraws/brass_serpent/, its README.md) cut out, scaled to the
game's size, their reds turned into the team keys, and written to assets/units/brass_serpent/; the sizes and anchors go
to scripts/serpent_art.gd (class SerpentArt, read by scripts/brass_serpent.gd). Also the four card icons.
    python3 tools/serpent/import_art.py [--sheet DIR]   (--sheet: a contact sheet of everything at 4x, for a look)

Pieces (each PNG is a horizontal strip of equal frames; one frame unless said):
  head_<s|se|e|ne|n>      the head, idle (W/SW/NW: the game mirrors E/SE/NE)
  bite_<s|se|e|ne|n>      the bite, 4 frames (closed, opening, wide open, snapped shut), on one box so the head stays put;
                          frame 0 is fitted onto the idle head (same size and centre), so no jump when a bite starts
  small_<h|v|d>, big_<h|v|d>   a body section lying across (h), up-down (v), and from upper left to lower right (d)
  tail_<h|v|d>            the tail: its tip to the right (h), down (v), up-left (d)
  joint_<se|e|s>          the Hydra joint, its necks to the front
  wreck_<head|small|big>  the broken pieces
SerpentArt.P[name] = [frame w, frame h, anchor x, anchor y, frames, axis angle (deg, sections and tail: of the piece's
long axis, the tail's toward its tip; 0 for the rest)].
"""
import math
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.normpath(os.path.dirname(os.path.abspath(__file__)) + "/../..") + "/"
SRC = ROOT + "art/redraws/brass_serpent/"
OUT = ROOT + "assets/units/brass_serpent/"
GD = ROOT + "scripts/serpent_art.gd"

# the size in game px of each kind of piece: the square root of its cut-out's area (so a long and a short view of the same
# piece come out alike; the area is its pixels, not its box, so a diagonal view isn't shrunk); tuned against the Clock Soldier and the Pendulum (docs/shots/brass_serpent/art/)
SIZE = {"head": 27.0, "small": 20.0, "big": 27.0, "tail": 14.0, "joint": 33.0, "wreck_head": 25.0, "wreck_small": 18.0,
        "wreck_big": 24.0}
KEY1 = (255, 0, 0)        # the team keys (shaders/team.gdshader): light and dark
KEY2 = (150, 0, 0)


# ------------------------------------------------------------------ cutting out

def load(name):
    return np.array(Image.open(SRC + name).convert("RGBA")).astype(np.int32)


def cut_grey(a):
    """The plain grey background (and the soft shadows on it) made transparent: a flood from the border over grey pixels
    that change little from one to the next."""
    rgb = a[:, :, :3]
    lum = rgb.mean(axis=2)
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    greyish = (sat <= 14) & (lum > 92)
    h, w = lum.shape
    bg = np.zeros((h, w), bool)
    # seeds: the border's grey pixels; grow 4-way while the neighbour is grey and close in brightness
    from collections import deque
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if greyish[y, x] and not bg[y, x]:
                bg[y, x] = True
                q.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if greyish[y, x] and not bg[y, x]:
                bg[y, x] = True
                q.append((y, x))
    while q:
        y, x = q.popleft()
        l0 = lum[y, x]
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and not bg[ny, nx] and greyish[ny, nx] and abs(lum[ny, nx] - l0) < 7:
                bg[ny, nx] = True
                q.append((ny, nx))
    out = a.copy()
    out[:, :, 3] = np.where(bg, 0, 255)
    return keep_big(out)


def keep_big(a, min_frac=0.0015):
    """Specks left over (stray grey islands, ChatGPT's dust) dropped; holes in a piece filled back."""
    m = a[:, :, 3] > 0
    lab, n = ndimage.label(m)
    if n == 0:
        return a
    sizes = ndimage.sum(m, lab, range(1, n + 1))
    keep = np.zeros(n + 1, bool)
    keep[1:] = sizes >= max(40, m.sum() * min_frac)
    m2 = keep[lab]
    out = a.copy()
    out[:, :, 3] = np.where(m2, 255, 0)
    return out


def bbox(a):
    ys, xs = np.nonzero(a[:, :, 3] > 0)
    return xs.min(), ys.min(), xs.max() + 1, ys.max() + 1


def crop(a, b):
    return a[b[1]:b[3], b[0]:b[2]]


def split_cols(a, n):
    """Cut a picture into its n pieces, left to right, at the widest empty columns between them."""
    occ = (a[:, :, 3] > 0).any(axis=0)
    runs = []
    x = 0
    w = len(occ)
    while x < w:
        if not occ[x]:
            s = x
            while x < w and not occ[x]:
                x += 1
            if s > 0 and x < w:
                runs.append((x - s, s, x))
        else:
            x += 1
    runs.sort(reverse=True)
    cuts = sorted((s + e) // 2 for _, s, e in runs[: n - 1])
    edges = [0] + cuts + [w]
    return [a[:, edges[i]:edges[i + 1]] for i in range(n)]


# ------------------------------------------------------------------ scaling and colours

def to_img(a):
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "RGBA")


def scale(a, k):
    """Down to game size: premultiplied area average, then a hard alpha (the game draws its sprites with nearest
    filtering, no soft edges), then the team keys."""
    im = to_img(a)
    w, h = im.size
    nw, nh = max(1, round(w * k)), max(1, round(h * k))
    pm = np.array(im).astype(np.float32)
    pm[:, :, :3] *= pm[:, :, 3:4] / 255.0
    r = np.array(to_img(pm).resize((nw, nh), Image.BOX)).astype(np.float32)
    al = r[:, :, 3]
    rgb = np.where(al[:, :, None] > 0, r[:, :, :3] * 255.0 / np.maximum(al[:, :, None], 1), 0)
    out = np.zeros((nh, nw, 4), np.int32)
    out[:, :, :3] = np.clip(rgb, 0, 255)
    out[:, :, 3] = np.where(al > 120, 255, 0)
    return team_keys(out)


def team_keys(a):
    """The red enamel in two keys (light, dark) the team shader swaps for the side's colour, as the other Clockwork units'
    art (scripts/cw_art.gd TEAM / TEAM_D); the brass, the glowing eyes and the black outline left as painted."""
    r, g, b = a[:, :, 0].astype(float), a[:, :, 1].astype(float), a[:, :, 2].astype(float)
    red = (r > 95) & (g < r * 0.42) & (b < r * 0.42) & (a[:, :, 3] > 0)
    light = red & (r > 175)
    a[red & light, :3] = KEY1
    a[red & ~light, :3] = KEY2
    return a


def side_k(a, target):
    return target / math.sqrt(float((a[:, :, 3] > 0).sum()))


def axis_deg(a, tip=False):
    """The long axis of the piece's shape (screen degrees, y down); `tip`: pointing at its thinner end."""
    ys, xs = np.nonzero(a[:, :, 3] > 0)
    pts = np.stack([xs - xs.mean(), ys - ys.mean()], 1).astype(float)
    cov = pts.T @ pts / len(pts)
    ev, evec = np.linalg.eigh(cov)
    v = evec[:, 1]
    if tip:
        proj = pts @ v
        # the tip side has less mass far out: compare the spread across the axis at either end
        perp = np.abs(pts @ np.array([-v[1], v[0]]))
        lo, hi = proj < np.percentile(proj, 20), proj > np.percentile(proj, 80)
        if perp[hi].mean() > perp[lo].mean():
            v = -v
    else:
        if v[0] < 0:
            v = -v
    return math.degrees(math.atan2(v[1], v[0]))


# ------------------------------------------------------------------ the pieces

P = {}
SHEET = []


def save(name, frames, anchor, ang=0.0):
    """frames: game-size arrays of one size; anchor: the frame's centre point in px."""
    w, h = frames[0].shape[1], frames[0].shape[0]
    strip = np.zeros((h, w * len(frames), 4), np.int32)
    for i, f in enumerate(frames):
        strip[:, i * w:(i + 1) * w] = f
    to_img(strip).save(OUT + name + ".png")
    P[name] = [int(w), int(h), round(float(anchor[0]), 1), round(float(anchor[1]), 1), len(frames), round(float(ang), 1)]
    SHEET.append((name, strip))


def single(name, a, kind, ang_mode=None, k=None):
    a = crop(a, bbox(a))
    k = k or side_k(a, SIZE[kind])
    ang = 0.0
    if ang_mode:
        ang = axis_deg(a, tip=ang_mode == "tip")
    s = scale(a, k)
    s = crop(s, bbox(s))
    save(name, [s], (s.shape[1] / 2.0, s.shape[0] / 2.0), ang)
    return k


def bite(dir_, cells, head_k_box):
    """cells: the 4 frames, each cut from the same box (so they line up); head_k_box: the idle head's [k, w, h]."""
    boxes = [bbox(c) for c in cells]
    k0, hw, hh = head_k_box
    f0 = crop(cells[0], boxes[0])
    # frame 0 fitted onto the idle head: the same scale
    k = math.sqrt(hw * hh) / math.sqrt(f0.shape[0] * f0.shape[1])   # (box to box: frame 0 and the head are the same view)
    ux0, uy0 = min(b[0] for b in boxes), min(b[1] for b in boxes)
    ux1, uy1 = max(b[2] for b in boxes), max(b[3] for b in boxes)
    frames = [scale(crop(c, (ux0, uy0, ux1, uy1)), k) for c in cells]
    fh = max(f.shape[0] for f in frames)
    fw = max(f.shape[1] for f in frames)
    frames = [np.pad(f, ((0, fh - f.shape[0]), (0, fw - f.shape[1]), (0, 0))) for f in frames]
    # the anchor: frame 0's own centre (where the idle head's centre is)
    b0 = boxes[0]
    ax = ((b0[0] + b0[2]) / 2.0 - ux0) * k
    ay = ((b0[1] + b0[3]) / 2.0 - uy0) * k
    save("bite_" + dir_, frames, (ax, ay))


def quarters(a, n=4):
    w = a.shape[1]
    return [a[:, i * w // n:(i + 1) * w // n] for i in range(n)]


def main():
    os.makedirs(OUT, exist_ok=True)
    heads = {}
    for d in ["s", "se", "e", "ne", "n"]:
        a = keep_big(load("serpent_head_%s.png" % d))
        single("head_" + d, a, "head")
        heads[d] = (P["head_" + d][0], P["head_" + d][1])
    # bites: SE from the cut strip (483 px frames), the rest cut from their grey sheets
    se = load("serpent_bite_se_strip.png")
    fw = se.shape[1] // 4
    bite("se", [keep_big(se[:, i * fw:(i + 1) * fw]) for i in range(4)], (0, *heads["se"]))
    for d, f in [("s", "bite_s_chatgpt.png"), ("e", "bite_e_chatgpt.png"), ("ne", "bite_ne_chatgpt.png"),
                 ("n", "bite_n_v1_chatgpt.png")]:
        cells = [cut_grey(c) for c in quarters(load(f))]
        if d == "n":
            # (v1's wide-open frame shows the mouth toward us, as from the front: the README's fix, frame 2 pushed up)
            c = cells[1]
            up = np.zeros_like(c)
            up[:-10] = c[10:]
            cells[2] = up
        bite(d, cells, (0, *heads[d]))
    # sections and the tail: SE (d) from the cut-outs, across (h) and up-down (v) from the e_s sheets
    for kind, cut, sheet in [("small", "serpent_section_small.png", "section_small_e_s_chatgpt.png"),
                             ("big", "serpent_section_big.png", "section_big_e_s_chatgpt.png"),
                             ("tail", "serpent_tail.png", "tail_e_s_chatgpt.png")]:
        mode = "tip" if kind == "tail" else "axis"
        single(kind + "_d", keep_big(load(cut)), kind, mode)
        h, v = split_cols(cut_grey(load(sheet)), 2)
        single(kind + "_h", h, kind, mode)
        single(kind + "_v", v, kind, mode)
    # the Hydra joint: SE cut out; E and S from their sheet
    single("joint_se", keep_big(load("serpent_hydra_joint_se.png")), "joint")
    e, s = split_cols(cut_grey(load("hydra_joint_e_s_chatgpt.png")), 2)
    single("joint_e", e, "joint")
    single("joint_s", s, "joint")
    # the wrecks: head, small, big
    wh, ws, wb = split_cols(cut_grey(load("wrecks_chatgpt.png")), 3)
    single("wreck_head", wh, "wreck_head")
    single("wreck_small", ws, "wreck_small")
    single("wreck_big", wb, "wreck_big")
    icons()
    write_gd()
    if "--sheet" in sys.argv:
        contact(sys.argv[sys.argv.index("--sheet") + 1])


def icons():
    """The four card icons, a 2x2 grid each in the game's icon frame: Serpent, Hydra / small gear, big gear."""
    im = Image.open(SRC + "icons_chatgpt.png").convert("RGBA")
    w, h = im.size
    names = ["brass_serpent", "brass_hydra", "serpent_gear_s", "serpent_gear_b"]
    for i, n in enumerate(names):
        cx, cy = (i % 2) * w // 2, (i // 2) * h // 2
        tile = im.crop((cx + 12, cy + 12, cx + w // 2 - 12, cy + h // 2 - 12))
        tile.resize((64, 64), Image.LANCZOS).save(ROOT + "assets/icons/" + n + ".png")


def write_gd():
    lines = ["class_name SerpentArt", "## The Brass Serpent's pictures (assets/units/brass_serpent/), written by tools/serpent/import_art.py:",
             "## name -> [frame w, frame h, anchor x, anchor y, frames, axis angle (deg)]. Do not edit by hand.", "",
             "const P := {"]
    for k in sorted(P):
        lines.append('\t"%s": %s,' % (k, P[k]))
    lines.append("}")
    with open(GD, "w") as f:
        f.write("\n".join(lines) + "\n")


def contact(path):
    rows = []
    for name, strip in SHEET:
        rows.append(to_img(strip).resize((strip.shape[1] * 4, strip.shape[0] * 4), Image.NEAREST))
    W = max(r.width for r in rows) + 10
    H = sum(r.height + 6 for r in rows)
    sheet = Image.new("RGBA", (W, H), (70, 96, 64, 255))
    y = 0
    for r in rows:
        sheet.alpha_composite(r, (5, y))
        y += r.height + 6
    sheet.save(path)


if __name__ == "__main__":
    main()
    for k in sorted(P):
        print(k, P[k])
