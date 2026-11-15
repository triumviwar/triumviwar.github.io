"""The Clockwork army's wind-up keys (wind-keys, the owner 2026-11-15 20:15).

Source: art/redraws/wind_key/wind_key_chatgpt.png (1536 x 1024, flat magenta, 5 rows x 8 frames: behind, 3/4 back,
side, 3/4 front, front). ChatGPT did not really turn the key between frames, so ONE still is taken (row 1, frame 1:
the figure-eight bow face-on with its stem under it; the side view's horizontal stem from row 3, frame 1) and the
turning is made here, once, at import:

  the model   a toy key: the bow is a flat plate in a plane that holds the shaft, turning about the shaft.
  n (behind)  the shaft points at the viewer: the bow face-on, turned in the picture's plane about its middle (the
              owner's rule: readable at a glance), a short foreshortened stem behind it up into the back.
  s (front)   the same seen from the other side, behind the body (only the bow above the shoulders shows), a touch
              darker (its far face, in the body's shadow).
  e (side)    the shaft points out of the back (left of a unit facing E); the bow's span is projected: its loops shrink
              toward the shaft with |cos(angle)| (face-on -> edge-on -> its other face, mirrored: the shading flips
              between the halves).
  se, ne      the same 3D turn seen from three-quarters (the shaft into the picture or out of it), a mix of the two.
  camera      orthographic from above, sin(elevation) 0.45 (the game's ground squash).

Each frame is drawn big (the sheet's own pixels, bilinear), then shrunk with premultiplied alpha and a hard edge (the
make_packs helpers), the rim darkened toward the sheet's outline, and every colour the team shader would swap nudged
out of its reach. Magenta is keyed out with a despill so no pink fringe is left.

Output:
  assets/units/_shared/wind_key_<w>.png    one row per view (s, se, e, ne, n), FRAMES columns: one full turn (360
                                           degrees; the n and s rows repeat after half a turn: the bow is symmetric);
                                           the attachment point (where the shaft goes into the back) is the cell's
                                           middle. <w> = the bow's width in game px (one sheet per size used).
  scripts/wind_key_data.gd                 WindKeyData: per unit its key size and, for every animation strip, per
                                           frame [view row, in front of the body, x, y] (game px from the feet,
                                           unflipped art) of the attachment point: followed from frame to frame like
                                           the battery packs (tools/make_packs.py's tracker).

Usage (repo root): python3 tools/clockwork/import_wind_key.py [--preview DIR] [--art-only]
Needs Pillow, NumPy, SciPy.
"""
import math
import os
import re
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
sys.path.insert(0, os.path.join(ROOT, "tools"))
from make_packs import shrink, outline, unkey, track, strip_frames, unit_art, PAD  # noqa: E402

SHEET = "art/redraws/wind_key/wind_key_chatgpt.png"
VIEWS = ["s", "se", "e", "ne", "n", "u"]      # u: a key standing up out of a flyer's back (any direction)
FRAMES = 16
SIN_E = 0.45
COS_E = math.sqrt(1 - SIN_E * SIN_E)
BOW_BOX = (40, 64, 158, 122)        # row 1 frame 1: the bow (x0, y0, x1, y1), the stem's top cut off
STEM_BOX = (80, 118, 118, 156)      # its stem (under the bow)
BOW_MID = (100.0, 94.0)             # the bow's middle (the turning point in the n / s views)
STEM_W = 30.0                       # the stem's width, sheet px
STEM_L = 34.0                       # the stem's length out of the back to the bow's waist, sheet px
INK = (40, 22, 10)
OUTER = (34, 20, 10)                    # the outside line (the sprites' own outline brown-black)
LIFT = np.array([1.28, 1.34, 1.45])     # brass tones toward the Winder's key
EDGE_MIN = 0.16                         # the bow seen edge-on keeps its plate's thickness


# ---------------------------------------------------------------- the source

def keyed():
    """The sheet with the magenta keyed out (despilled), RGBA float."""
    px = np.array(Image.open(os.path.join(ROOT, SHEET)).convert("RGB")).astype(float)
    r, g, b = px[..., 0], px[..., 1], px[..., 2]
    spill = np.minimum(r, b) - g               # magenta: red and blue both far above green
    bg = (spill > 110) & (np.abs(r - b) < 90)
    # the anti-aliased rim: part magenta. Alpha from how much spill is left, the colour despilled (red and blue
    # pulled down to what the brass beside it would be)
    rim = ~bg & (spill > 25) & ndimage.binary_dilation(bg, iterations=2)
    a = np.where(bg, 0.0, 1.0)
    a = np.where(rim, np.clip(1.0 - (spill - 25) / 120.0, 0.0, 1.0), a)
    out = np.dstack([px, a * 255.0])
    fix = rim | (~bg & (spill > 0))
    out[..., 0] = np.where(fix, np.minimum(r, g * 1.9 + 10), r)
    out[..., 2] = np.where(fix, np.minimum(b, g * 0.6), b)
    out[bg] = 0
    return out


def crop(img, box):
    x0, y0, x1, y1 = box
    return img[y0:y1, x0:x1].copy()


# ---------------------------------------------------------------- drawing big

def premul(img):
    a = img[..., 3:4] / 255.0
    return np.concatenate([img[..., :3] * a, img[..., 3:4]], -1)


def warp(dst, src, M, t):
    """Draw src (premultiplied RGBA float) onto dst through the affine map screen = M @ src_xy + t (bilinear),
    `over` compositing."""
    H, W = dst.shape[:2]
    Mi = np.linalg.inv(M)
    ys, xs = np.mgrid[0:H, 0:W].astype(float)
    sx = Mi[0, 0] * (xs + 0.5 - t[0]) + Mi[0, 1] * (ys + 0.5 - t[1]) - 0.5
    sy = Mi[1, 0] * (xs + 0.5 - t[0]) + Mi[1, 1] * (ys + 0.5 - t[1]) - 0.5
    lay = np.zeros_like(dst)
    for c in range(4):
        lay[..., c] = ndimage.map_coordinates(src[..., c], [sy, sx], order=1, mode="constant", cval=0.0)
    a = lay[..., 3:4] / 255.0
    dst[...] = lay + dst * (1.0 - a)


def norm(v):
    v = np.asarray(v, float)
    return v / np.linalg.norm(v)


def proj(v):
    """3D (x right, y up, z toward the viewer) -> screen (x, y down), looking down at sin(e)."""
    return np.array([v[0], -v[1] * COS_E + v[2] * SIN_E])


SHAFT = {"e": (-1.0, 0.0, 0.0), "se": (-0.72, 0.0, -0.69), "ne": (-0.72, 0.0, 0.69),
         "n": (0.0, 0.0, 1.0), "s": (0.0, 0.0, -1.0), "u": (0.0, 1.0, 0.0)}


def frame_big(src, view, ang, SC):
    """One frame, big (sheet px x SC), the attachment point at the canvas middle. Returns premultiplied float."""
    bow = premul(crop(src, BOW_BOX))
    stem = premul(crop(src, STEM_BOX))
    bw, bh = BOW_BOX[2] - BOW_BOX[0], BOW_BOX[3] - BOW_BOX[1]
    C = int(2 * (STEM_L + bw * 0.62) * SC) + 8
    cv = np.zeros((C, C, 4))
    mid = np.array([C / 2.0, C / 2.0])
    S = norm(SHAFT[view])
    s2 = proj(S)                                   # the shaft's screen direction (per sheet px of length)
    tip = mid + s2 * STEM_L * SC                   # the bow's waist on screen
    # the stem: a cylinder that keeps its width: its length along s2, its width across it
    sl = np.linalg.norm(s2)
    def draw_stem():
        if sl < 1e-3:
            return
        d = s2 / sl
        nrm = np.array([-d[1], d[0]])
        # stem picture: x = across (STEM_W), y = along (from the bow's waist (top) to the end in the back (bottom))
        sh, sw = stem.shape[:2]
        M = np.column_stack([nrm * SC * STEM_W / sw, -d * SC * STEM_L * sl / sh])
        # the stem picture's (sw/2, 0) -> tip, (sw/2, sh) -> mid
        t = tip - M @ np.array([sw / 2.0, 0.0])
        warp(cv, stem, M, t)
    if view in ("n", "s"):
        # the owner's rule: the bow face-on, turned in the picture's plane about its middle
        rot = ang if view == "n" else -ang
        c, s = math.cos(rot), math.sin(rot)
        R = np.array([[c, -s], [s, c]]) * SC
        b = bow.copy()
        if view == "s":
            b = b[:, ::-1].copy()                  # its far face
            b[..., :3] *= 0.82
        bm = np.array([BOW_MID[0] - BOW_BOX[0], BOW_MID[1] - BOW_BOX[1]])
        if view == "s":
            bm[0] = bw - bm[0]
        t = tip - R @ bm
        if view == "n":
            draw_stem()
            warp(cv, b, R, t)
        else:
            warp(cv, b, R, t)
            draw_stem()
        return cv
    # a real turn about the shaft: the bow's plane holds S; its span turns with U(ang)
    up = np.array([0.0, 1.0, 0.0])
    E1 = norm(np.cross(S, np.cross(up, S))) if abs(up @ S) < 0.99 else np.array([1.0, 0.0, 0.0])
    E2 = np.cross(S, E1)
    U = math.cos(ang) * E1 + math.sin(ang) * E2
    # bow picture axes: x = span (loop to loop), y down = toward the stem (the shaft, back into the body)
    u2 = proj(U)
    # seen edge-on (on screen, which with the camera's tilt is not at 90 degrees) the plate keeps its thickness
    if np.linalg.norm(u2) < EDGE_MIN:
        d = u2 if np.linalg.norm(u2) > 1e-6 else proj(E1)
        u2 = d / np.linalg.norm(d) * EDGE_MIN
    M = np.column_stack([u2 * SC, -s2 * SC])      # picture x -> along U, picture y (down) -> back along the shaft
    bm = np.array([BOW_MID[0] - BOW_BOX[0], BOW_BOX[3] - BOW_BOX[1]])   # the waist (bow's bottom middle) -> tip
    t = tip - M @ bm
    # its other face is a touch darker (the brass turning out of the light)
    b = bow.copy()
    U3 = U
    facing = np.cross(U3, S)[2]                    # the plate's normal toward the viewer?
    if facing < 0:
        b[..., :3] *= 0.88
    if S[2] > 0:          # the bow nearer than the back: the stem first, the bow over it
        draw_stem()
        warp(cv, b, M, t)
    else:
        warp(cv, b, M, t)
        draw_stem()
    return cv


def frame_small(big, SC):
    """Shrink a big frame to game px (premultiplied -> straight RGBA uint8, hard alpha, outlined, unkeyed)."""
    C = big.shape[0]
    n = int(round(C / SC))
    n += n % 2                                     # even: the attachment point on a pixel corner -> the middle
    a = big[..., 3:4] / 255.0
    straight = np.concatenate([np.where(a > 1e-4, big[..., :3] / np.maximum(a, 1e-4), 0), big[..., 3:4]], -1)
    out = shrink(straight.clip(0, 255).astype(np.uint8), n, n)
    # (the sheet's brass shrinks darker than the Winder's painted key: lifted to its tones, Winder median ~(151, 94, 32))
    m = out[..., 3] > 0
    out[..., :3] = np.where(m[..., None], (out[..., :3].astype(float) * LIFT).clip(0, 255), 0).astype(np.uint8)
    out = outline(out, INK, 0.25)
    # a dark line round the outside (4-neighbours): brass on a brass back (the Clock Soldier) still reads
    a = out[..., 3] > 0
    ring = ndimage.binary_dilation(a, structure=np.array([[0, 1, 0], [1, 1, 1], [0, 1, 0]])) & ~a
    out[ring] = (*OUTER, 255)
    return unkey(out)


def build_sheet(w):
    """The 5 x FRAMES sheet for a bow w game px wide."""
    src = keyed()
    SC = w / float(BOW_BOX[2] - BOW_BOX[0]) * 1.0   # game px per sheet px...
    # draw big at 6 big px per game px: SC_big = 6 * SC
    BIG = 6.0
    rows = []
    for v in VIEWS:
        row = []
        for i in range(FRAMES):
            ang = 2 * math.pi * i / FRAMES
            big = frame_big(src, v, ang, SC * BIG)
            row.append(frame_small(big, BIG))
        rows.append(row)
    n = max(f.shape[0] for r in rows for f in r)
    sheet = np.zeros((n * len(VIEWS), n * FRAMES, 4), np.uint8)
    for j, r in enumerate(rows):
        for i, f in enumerate(r):
            o = (n - f.shape[0]) // 2
            sheet[j * n + o:j * n + o + f.shape[0], i * n + o:i * n + o + f.shape[1]] = f
    return sheet, n


# ---------------------------------------------------------------- where the keys sit

# Per unit: the bow's width (game px, the Winder's key to its body), and per drawn direction (the east views; own west
# strips: Clock Soldier) the key's view, whether it is in front of the body, a reference frame, the attachment point
# on it (game px from the feet, unflipped art) and the torso patch (x0, y0, x1, y1) followed through the other frames.
def _dirs(size, pts, patch=7, reach=14, ref="idle", extra=None):
    """pts: dir -> (view, front, x, y); the patch followed is the box +-patch round the point."""
    out = {}
    for d, (v, f, x, y) in pts.items():
        px, py = (patch, patch) if isinstance(patch, int) else patch
        out[d] = dict(view=v, front=f, ref=(ref + "_" + d, 0), at=(x, y), patch=(x - px, y - py, x + px, y + py),
                      reach=reach)
    return out


UNITS = {
    "clock_soldier": {"size": 13, "dirs": _dirs(13, {
        "s": ("s", False, 0, -34), "se": ("se", False, -7, -30), "e": ("e", False, -5, -29),
        "ne": ("ne", True, -4, -28), "n": ("n", True, 0, -29),
        # its own west strips (drawn unflipped): the east views mirrored at run time
        "sw": ("se", False, 7, -30), "w": ("e", False, 3, -29), "nw": ("ne", True, 4, -28)})},
    "springer": {"size": 14, "dirs": _dirs(14, {
        "s": ("s", False, 0, -50), "se": ("se", False, -8, -40), "e": ("e", False, -10, -38),
        "ne": ("ne", True, -5, -38), "n": ("n", True, 0, -37)}, patch=8, reach=30)},
    "netter": {"size": 12, "dirs": _dirs(12, {
        "s": ("s", False, 0, -35), "se": ("se", False, -19, -24), "e": ("e", False, -22, -22),
        "ne": ("ne", True, -17, -22), "n": ("n", True, 0, -21)})},
    "pendulum": {"size": 16, "dirs": _dirs(16, {
        "s": ("s", False, 0, -74), "se": ("se", False, -6, -62), "e": ("e", False, -6, -62),
        "ne": ("ne", True, -4, -60), "n": ("n", True, 0, -60)}, patch=(6, 9), reach=24)},
    "cuckoo": {"size": 9, "dirs": _dirs(9, {
        "s": ("u", False, 0, -24), "se": ("u", False, -3, -24), "e": ("u", True, -6, -22),
        "ne": ("u", True, -3, -21), "n": ("u", True, 0, -22)}, patch=5, reach=16)},
    "ticking_owl": {"size": 11, "dirs": _dirs(11, {
        "s": ("u", False, 0, -42), "se": ("u", False, -4, -41), "e": ("u", True, -6, -38),
        "ne": ("u", True, -4, -37), "n": ("u", True, 0, -38)}, patch=6, reach=20)},
}
HAND = {}
SKIP = ("death",)


def placements(src):
    out = {}
    for kind, cfg in UNITS.items():
        cell, anchor, frames = unit_art(src, kind)
        refs, keys = {}, {}
        for key, n in sorted(frames.items()):
            anim, d = key.rsplit("_", 1)
            if anim in SKIP or anim in cfg.get("skip", ()) or d not in cfg["dirs"]:
                continue
            dc = cfg["dirs"][d]
            rk, ri = dc["ref"]
            if rk not in refs:
                refs[rk] = strip_frames(kind, rk, cell, anchor, frames[rk])
            ref = refs[rk][ri]
            fr = strip_frames(kind, key, cell, anchor, n)
            pts = []
            for i, f in enumerate(fr):
                h = HAND.get(kind, {}).get((key, i))
                if h is not None and h[0] == "+":
                    dx, dy = track(ref, dc["patch"], f, anchor, dc.get("reach", 14))
                    h = (dc["at"][0] + dx + h[1], dc["at"][1] + dy + h[2]) + tuple(h[3:])
                if h is not None:
                    h = tuple(h) + (None, None)[len(h) - 2:]
                    pts.append((h[2] or dc["view"], dc["front"] if h[3] is None else h[3], h[0], h[1]))
                    continue
                dx, dy = track(ref, dc["patch"], f, anchor, dc.get("reach", 14))
                pts.append((dc["view"], dc["front"], dc["at"][0] + dx, dc["at"][1] + dy))
            keys[key] = pts
        out[kind] = keys
    return out


def write_table(place, cells):
    L = ["class_name WindKeyData", "extends RefCounted",
         "## The Clockwork army's wind-up keys (tools/clockwork/import_wind_key.py writes this file: edit there).",
         "## kind -> its key size (the bow's width in game px: assets/units/_shared/wind_key_<size>.png, cell px square)",
         "## and per animation strip one entry per frame: [view row (s, se, e, ne, n), in front of the body, x, y]",
         "## (the attachment point, game px from the feet, unflipped art). No entry: no key on that strip.",
         "## The sheets: one row per view (s, se, e, ne, n, u = standing up out of a flyer's back), FRAMES columns = one turn.",
         "", f"const FRAMES := {FRAMES}", f"const ROWS := {len(VIEWS)}", "const CELL := {%s}" % ", ".join(f"{w}: {n}" for w, n in sorted(cells.items())), "",
         "const KEYS := {"]
    for kind in UNITS:
        L.append(f'\t"{kind}": {{"size": {UNITS[kind]["size"]}, "keys": {{')
        for key, pts in sorted(place[kind].items()):
            ps = ", ".join(f'[{VIEWS.index(v)}, {"true" if f else "false"}, {x}, {y}]' for v, f, x, y in pts)
            L.append(f'\t\t"{key}": [{ps}],')
        L.append("\t}},")
    L.append("}")
    open(os.path.join(ROOT, "scripts/wind_key_data.gd"), "w").write("\n".join(L) + "\n")


def preview(place, sheets, out, ang_i=2, scale=5, anims=None):
    src = open(os.path.join(ROOT, "scripts/art_data.gd")).read() + open(os.path.join(ROOT, "scripts/cw_art.gd")).read()
    os.makedirs(out, exist_ok=True)
    for kind, keys in place.items():
        cell, anchor, frames = art_of(kind)
        sheet, n = sheets[UNITS[kind]["size"]]
        rows = []
        for key, pts in sorted(keys.items()):
            if anims and key.rsplit("_", 1)[0] not in anims:
                continue
            fr = strip_frames(kind, key, cell, anchor, frames[key])
            west = key.rsplit("_", 1)[1] in ("sw", "w", "nw")
            row = []
            for i, (f, (view, front, x, y)) in enumerate(zip(fr, pts)):
                r = VIEWS.index(view)
                k = (ang_i + i) % FRAMES
                pk = sheet[r * n:(r + 1) * n, k * n:(k + 1) * n]
                if west:
                    pk = pk[:, ::-1]
                bg = np.zeros_like(f)
                bg[..., :3] = (88, 112, 78)
                bg[..., 3] = 255
                px0 = int(round(anchor[0] + PAD + x - n / 2))
                py0 = int(round(anchor[1] + PAD + y - n / 2))
                lay = np.zeros_like(f)
                lay[py0:py0 + n, px0:px0 + n] = pk
                img = Image.fromarray(bg)
                for l in ((f, lay) if front else (lay, f)):
                    img.alpha_composite(Image.fromarray(l))
                row.append(img)
            rows.append((key, row))
        ys, xs = [], []
        for _, r in rows:
            for im in r:
                a = np.array(im)
                m = np.any(a[..., :3] != (88, 112, 78), -1)
                yy, xx = np.nonzero(m)
                if len(yy):
                    ys += [yy.min(), yy.max()]
                    xs += [xx.min(), xx.max()]
        box = (min(xs) - 2, min(ys) - 2, max(xs) + 3, max(ys) + 3)
        rows = [(k, [im.crop(box) for im in r]) for k, r in rows]
        cw, ch = rows[0][1][0].size
        W = max(len(r) for _, r in rows) * (cw + 2)
        sh = Image.new("RGBA", (W, len(rows) * (ch + 2)), (20, 20, 20, 255))
        for j, (_, r) in enumerate(rows):
            for i, im in enumerate(r):
                sh.paste(im, (i * (cw + 2), j * (ch + 2)))
        sh.resize((sh.width * scale // 2, sh.height * scale // 2), Image.NEAREST).save(f"{out}/{kind}.png")


_SRC = None


def art_of(kind):
    """(cell, anchor, {strip: frames}) from CwArt.SHEETS and the files on disk (the game's own rule)."""
    global _SRC
    if _SRC is None:
        _SRC = open(os.path.join(ROOT, "scripts/cw_art.gd")).read()
    m = re.search(r'"%s": \[(\d+), (\d+), (\d+), (\d+)\]' % kind, _SRC)
    cw, ch, ax, ay = (int(v) for v in m.groups())
    frames = {}
    d = os.path.join(ROOT, "assets/units", kind)
    for f in sorted(os.listdir(d)):
        if f.endswith(".png"):
            w = Image.open(os.path.join(d, f)).size[0]
            frames[f[:-4]] = max(1, w // cw)
    return (cw, ch), (ax, ay), frames


def main():
    os.chdir(ROOT)
    import make_packs
    make_packs.unit_art = lambda _src, kind: art_of(kind)
    globals()["unit_art"] = lambda _src, kind: art_of(kind)
    sizes = sorted({u["size"] for u in UNITS.values()}) or [12]
    if "--sizes" in sys.argv:
        sizes = [int(s) for s in sys.argv[sys.argv.index("--sizes") + 1].split(",")]
    sheets = {w: build_sheet(w) for w in sizes}
    if "--art-only" in sys.argv:
        out = sys.argv[sys.argv.index("--art-only") + 1]
        os.makedirs(out, exist_ok=True)
        for w, (s, n) in sheets.items():
            Image.fromarray(s).save(f"{out}/wind_key_{w}.png")
            Image.fromarray(s).resize((s.shape[1] * 6, s.shape[0] * 6), Image.NEAREST).save(f"{out}/wind_key_{w}_x6.png")
        return
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1].split(",")
        for k in list(UNITS):
            if k not in only:
                del UNITS[k]
    place = placements("")
    if "--preview" in sys.argv:
        an = sys.argv[sys.argv.index("--anims") + 1].split(",") if "--anims" in sys.argv else None
        preview(place, sheets, sys.argv[sys.argv.index("--preview") + 1], anims=an)
        if "--no-write" in sys.argv:
            return
    os.makedirs("assets/units/_shared", exist_ok=True)
    for w, (s, n) in sheets.items():
        Image.fromarray(s).save(f"assets/units/_shared/wind_key_{w}.png")
    write_table(place, {w: n for w, (s, n) in sheets.items()})
    print("wind keys: " + ", ".join(f"{k} {len(v)} strips" for k, v in place.items()))


if __name__ == "__main__":
    main()
