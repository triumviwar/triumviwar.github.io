"""Import the Pendulum's HIGH SWING (pendulum-high-swing, docs/pendulum_air.md): the blow it plays when its target is a
FLYER, the blade raised high over its head on the hit frame (the low sweep, attack_r / attack_l, stays for the ground).

Source: the owner's ChatGPT sheets art/redraws/pendulum_high_swing_<view>_chatgpt.png (S, SE, NE, N; 1536 x 1024, flat
magenta, 2 rows of 6 (E: pendulum_high_swing_e_v2_chatgpt.png, one row, see SHEET): the TOP row is the arm of attack_r of that view, the BOTTOM row attack_l; the 4th frame (index 3) is
THE HIT, the blade at its highest; the W views are the E ones mirrored by the game, as for the low sweep).
Output: assets/units/pendulum/attack_hi_r_<view>.png and attack_hi_l_<view>.png, 6 frames each, CELL_W x CELL_H: the same
130-px width as every Pendulum strip (the game counts frames by the kind's cell width) but TALLER (the raised blade goes
far above the 91-px cell); the feet stay the same distance from the strip's BOTTOM as in the 91-px strips, and the game
already keeps a taller strip's feet in place (Unit._set_anim: offset -anchor - (texture height - cell height), the way
the Springer's attack_up does), so nothing else in the code moves the sprite.
Also writes the preview art/redraws/pendulum_high_swing.png / .gif (per view: the old low sweep beside the new high
swing, x3).

Per sheet:
  1. KEY: magenta-ness m = min(R, B) - G (the background ~240, the brass, red, blue, steel and outlines of the figure
     <= ~20); a pixel is the figure when m < KEY (holes in the figure filled back where m < HOLE: a pink speck inside the
     case stays, the magenta between the rod and the body stays out). DESPILL: within EDGE px of the background a pixel's
     R and B both lose their excess over G (min(R, B) - G), so a red rim stays red and a steel rim grey, never pink.
  2. CUT: the two rows are the two content bands; in each the 6 biggest pieces are the figures (left to right) and every
     other piece of SPECK px or more goes to the figure it is nearest (a blade drawn apart from its rod).
  3. ALIGN: every frame on the BODY, not the arm: the red case and legs (the team-red mask) of each frame are matched to
     its row's first frame (frame 1 is the idle pose) by the best shift, so the body stands still and the arm alone moves.
  4. SCALE: each row so its first frame's body (finial to feet) is as tall as the in-game low sweep's first frame of that
     view and arm, its feet on the same line and its red case over the same x (within 1 px, checked and printed).
  5. PALETTE: tools/cw_palette.py (team reds, blue joints to player colour, steel greyed), the box shrink and hard alpha
     of tools/import_tier3.py, the team reds snapped to the shader's keys.
ROWS below says which sheet row (and frames) each strip takes; see the notes there for the frames ChatGPT drew on the
wrong arm.
  python3 tools/pendulum_guide/import_high_swing.py"""
import os
import sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
import cw_palette                     # noqa: E402
import import_tier3 as t3             # noqa: E402  (shrink, bbox, case_x, red_mask)

SRC = 'art/redraws/pendulum_high_swing_%s_chatgpt.png'
# view -> (sheet, rows) where the owner replaced a sheet: E v2 is ONE row of 6 in side profile (the first E sheet's figures
# were hallucinated); the far arm is hidden behind the body, so the one row serves both arms.
SHEET = {'e': ('art/redraws/pendulum_high_swing_e_v2_chatgpt.png', 1)}
DST = 'assets/units/pendulum/'
VIEWS = ['s', 'se', 'e', 'ne', 'n']
KEY = 60             # magenta-ness under this: the figure (ChatGPT's pink motion smears, ~60-160, stay out)
HOLE = 160           # a hole inside the figure is filled back when its magenta-ness is under this
EDGE = 4             # px (sheet) from the background where the despill works
SEAM_HUE = 24         # degrees: an orange-red seam in the team red (team_seams); the brass is ~28-40
SEAM_NB = 4           # ... with this many of its 8 neighbours on a key red
CRUMB = 8            # game px: a smaller piece apart from the figure is dropped (drop_specks)
SPECK = 20           # px: smaller pieces are dropped (noise)
CELL_W = 130         # the Pendulum's cell (scripts/cw_art.gd SHEETS "pendulum": [130, 91, 65, 84])
OLD_H = 91
FEET = 84            # the feet line in the 91-px cell (the anchor's y; every in-game frame's bottom)
LEGS = 0.5           # the share of the red's height (from the feet up) the body is aligned on
SEARCH = 24          # px (sheet): the most a frame's body is shifted to match its row's first frame

# strip -> [(sheet row, frame, mirror)] x 6. Default: attack_hi_r = the top row, attack_hi_l = the bottom row.
# Checked against the in-game low sweep of each view (which arm attack_r swings: the viewer's LEFT arm in S, SE; the
# viewer's RIGHT in NE and N; the near arm in E).
TOP = [(0, i, False) for i in range(6)]
BOT = [(1, i, False) for i in range(6)]
ROWS = {v: {'r': TOP, 'l': BOT} for v in VIEWS}
# S (front, symmetric): the bottom row's 2nd frame swings the viewer's LEFT arm (attack_r's): it takes the top row's 2nd
# frame mirrored instead.
ROWS['s']['l'] = [(1, 0, False), (0, 1, True), (1, 2, False), (1, 3, False), (1, 4, False), (1, 5, False)]
# SE: the bottom row's 3rd frame reaches out with the viewer's LEFT arm (wrong one; SE is not symmetric, so no mirror):
# its 2nd frame (the telegraph) is held one frame longer instead.
ROWS['se']['l'] = [(1, 0, False), (1, 1, False), (1, 1, False), (1, 3, False), (1, 4, False), (1, 5, False)]
# NE: both rows swing the viewer's RIGHT arm (attack_r's). Mirroring would turn the body into the NW view for the length of
# the blow, so the bottom row is kept as drawn: in NE both high swings are on the same arm (a choice, docs/pendulum_air.md).
# N (back, symmetric): the top row swings the viewer's LEFT arm (attack_l's in N) and the bottom row mixes both arms: the
# top row is attack_hi_l as drawn and attack_hi_r is the same row mirrored.
ROWS['e'] = {'r': TOP, 'l': TOP}
ROWS['n'] = {'r': [(0, i, True) for i in range(6)], 'l': [(0, i, False) for i in range(6)]}


def magenta(rgb):
    return np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]


def key_sheet(rgb):
    m = magenta(rgb)
    fig = m < KEY
    fig = ndi.binary_fill_holes(fig) & (m < HOLE) | fig
    # despill the rim: R and B lose their shared excess over G
    near = ndi.binary_dilation(~fig, iterations=EDGE) & fig
    ex = np.clip(np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1], 0, None)
    out = rgb.copy()
    out[..., 0] -= np.where(near, ex, 0)
    out[..., 2] -= np.where(near, ex, 0)
    return out.clip(0, 255), fig


def bands(fig, rows=2):
    line = fig.sum(1) > 2
    H = len(line)
    # the emptiest line between the rows' middles
    mid = H // 2
    lo, hi = int(H * 0.35), int(H * 0.65)
    cut = lo + int(np.argmin(fig[lo:hi].sum(1)))
    return [(0, cut), (cut, H)] if rows == 2 else [(0, H)]


def figures(rgb, fig, y0, y1, n=6):
    """The n figures of one band, left to right: (rgba crop, (x0, y0) of the crop in the sheet)."""
    m = fig[y0:y1]
    lab, k = ndi.label(m)
    sizes = ndi.sum(m, lab, range(1, k + 1))
    order = np.argsort(sizes)[::-1]
    seeds = [int(i) + 1 for i in order[:n]]
    cx = [np.nonzero(lab == s)[1].mean() for s in seeds]
    seeds = [s for _, s in sorted(zip(cx, seeds))]
    dist = np.stack([ndi.distance_transform_edt(lab != s) for s in seeds])
    owner = np.zeros(k + 1, int) - 1
    for i in range(k):
        if sizes[i] < SPECK:
            continue
        if i + 1 in seeds:
            owner[i + 1] = seeds.index(i + 1)
        else:
            owner[i + 1] = int(np.argmin(dist[:, lab == i + 1].min(1)))
    out = []
    for j in range(n):
        mm = owner[lab] == j
        ys, xs = np.nonzero(mm)
        a, b, c, d = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
        o = np.zeros((b - a, d - c, 4), np.uint8)
        o[..., :3] = rgb[y0 + a:y0 + b, c:d]
        o[..., 3] = mm[a:b, c:d] * 255
        o[o[..., 3] == 0] = 0
        out.append((o, (c, y0 + a)))
    return out


def red_body(o):
    """The team-red mask (the case and the legs: the body that must stand still)."""
    return t3.red_mask(o) & (o[..., 3] > 0)


def body_x(o):
    """The red case across (the red in the band just under the frame's top of the BODY: found from the feet up, so a
    blade raised over the head does not move it)."""
    red = red_body(o)
    ys = np.nonzero(red.any(1))[0]
    top, bot = ys.min(), ys.max()
    band = red.copy()
    band[int(top + (bot - top) * 0.45):] = False
    return float(np.nonzero(band)[1].mean()) + 0.5


def legs(o, h):
    """The red of the lower part of the body, LEGS x h (the reference frame's height) up from the lowest red: the legs and
    the case's bottom; the raised arm never reaches there."""
    red = red_body(o)
    bot = np.nonzero(red.any(1))[0].max()
    red[:max(0, int(bot - h * LEGS))] = False
    return red


def body_shift(ref, ref_xy, o, o_xy):
    """(dx, dy) in sheet px that moves frame o's body onto the reference frame's: first the middles and bottoms of their
    legs' red put together, then the best overlap of their red within SEARCH px of that."""
    _, y0r, _, y1r = t3.bbox(ref)
    a = legs(ref, y1r - y0r).astype(np.float32)
    b = legs(o, y1r - y0r).astype(np.float32)
    mx = lambda m: float(np.nonzero(m)[1].mean())
    gx = int(round(ref_xy[0] + mx(a) - o_xy[0] - mx(b)))
    gy = int((ref_xy[1] + np.nonzero(a.any(1))[0].max()) - (o_xy[1] + np.nonzero(b.any(1))[0].max()))
    ox, oy = o_xy[0] + gx, o_xy[1] + gy          # o's crop where the guess puts it (sheet coordinates)
    x0 = min(ref_xy[0], ox) - SEARCH
    y0 = min(ref_xy[1], oy) - SEARCH
    x1 = max(ref_xy[0] + a.shape[1], ox + b.shape[1]) + SEARCH
    y1 = max(ref_xy[1] + a.shape[0], oy + b.shape[0]) + SEARCH
    A = np.zeros((y1 - y0, x1 - x0), np.float32)
    A[ref_xy[1] - y0:ref_xy[1] - y0 + a.shape[0], ref_xy[0] - x0:ref_xy[0] - x0 + a.shape[1]] = a
    best, bd = -1.0, (0, 0)
    for dy in range(-SEARCH, SEARCH + 1):
        for dx in range(-SEARCH, SEARCH + 1):
            yy, xx = oy - y0 + dy, ox - x0 + dx
            sc = float((A[yy:yy + b.shape[0], xx:xx + b.shape[1]] * b).sum())
            if sc > best:
                best, bd = sc, (dx, dy)
    return gx + bd[0], gy + bd[1]


def game_ref(view, arm):
    """The in-game low sweep's first frame of this view and arm: (body height, case x, feet line)."""
    im = np.array(Image.open(DST + 'attack_%s_%s.png' % (arm, view)).convert('RGBA'))
    f = im[:, :CELL_W]
    x0, y0, x1, y1 = t3.bbox(f)
    return float(FEET - y0), t3.case_x(f), float(y1)


def build_row(frames, view, arm):
    """frames: [(rgba, (x0, y0) in the sheet, mirror)] x 6 -> list of (rgba, ax, ay, scale): ax, ay = where the unit's
    point (the case over the feet) is in each frame's own crop."""
    hg, cxg, _ = game_ref(view, arm)
    frames = [((o[:, ::-1].copy() if mir else o), xy, mir) for o, xy, mir in frames]
    o0, xy0, _ = frames[0]
    _, top0, _, bot0 = t3.bbox(o0)
    s = hg / float(bot0 - top0)
    cx0 = t3.case_x(o0)
    out = []
    for i, (o, xy, mir) in enumerate(frames):
        dx, dy = (0, 0) if i == 0 else body_shift(o0, xy0, o, xy)
        # the reference's point (cx0, bot0) in this frame's crop: reference crop -> sheet -> this crop, minus the shift
        ax = cx0 + xy0[0] - xy[0] - dx
        ay = bot0 + xy0[1] - xy[1] - dy
        out.append((o, ax, ay, s))
    return out, s, cxg


def team_seams(sm):
    """At game size, after snap_team: the orange-red seams ChatGPT painted into the red case and legs (hue under SEAM_HUE
    degrees, saturated) that stay off the key reds would show as orange specks on another team's colour: one with
    SEAM_NB or more of its 8 neighbours on a key red goes to the key of its brightness (twice, for 2-px seams). The brass
    is yellower and keeps its colour."""
    sm = sm.copy()
    for _ in range(2):
        rgb = sm[..., :3].astype(np.float32) / 255.0
        mx, mn = rgb.max(-1), rgb.min(-1)
        sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
        r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
        hue = np.degrees(np.arctan2(np.sqrt(3) * (g - b), 2 * r - g - b)) % 360
        key = (sm[..., 3] > 0) & (sm[..., 1] == 0) & (sm[..., 2] == 0) & ((sm[..., 0] == 255) | (sm[..., 0] == 150))
        nb = ndi.convolve(key.astype(int), np.ones((3, 3), int), mode='constant') - key
        seam = (sm[..., 3] > 0) & ~key & (sat >= 0.7) & ((hue <= SEAM_HUE) | (hue >= 345)) & (nb >= SEAM_NB) & (r > g)
        light = seam & (mx >= 0.62)
        sm[light, :3] = cw_palette.TEAM_LIGHT
        sm[seam & ~light, :3] = cw_palette.TEAM_DARK
    return sm


def drop_specks(sm):
    """At game size: pieces of fewer than CRUMB px standing apart from the figure (the tail of a pink motion smear
    ChatGPT drew round a swinging blade) go."""
    al = sm[..., 3] > 0
    lab, n = ndi.label(al, structure=np.ones((3, 3)))
    if n > 1:
        sz = ndi.sum(al, lab, range(1, n + 1))
        bad = np.isin(lab, [i + 1 for i in range(n) if sz[i] < CRUMB])
        sm = sm.copy()
        sm[bad] = 0
    return sm


def render(row, s, cxg, ch):
    """One strip (ch tall, CELL_W a frame): each frame's point at (cxg, ch - (OLD_H - FEET))."""
    feet = ch - (OLD_H - FEET)
    strip = np.zeros((ch, CELL_W * len(row), 4), np.uint8)
    for i, (o, ax, ay, _) in enumerate(row):
        o = cw_palette.recolour(o, 'pendulum')
        BW, BH = int(round(CELL_W / s)), int(round(ch / s))
        big = Image.new('RGBA', (BW, BH), (0, 0, 0, 0))
        big.paste(Image.fromarray(o, 'RGBA'), (int(round(cxg / s - ax)), int(round(feet / s - ay))))
        sm = t3.shrink(np.array(big), CELL_W / BW)[:ch, :CELL_W]
        sm = cw_palette.snap_team(sm)
        sm = team_seams(sm)
        sm = drop_specks(sm)
        strip[:sm.shape[0], i * CELL_W:i * CELL_W + sm.shape[1]] = sm
    return strip


def top_needed(row, s, cxg):
    """How far (game px) above the feet the highest pixel of the row goes."""
    up = 0.0
    for o, ax, ay, _ in row:
        _, y0, _, _ = t3.bbox(o)
        up = max(up, (ay - y0) * s)
    return up


def main():
    rows = {}
    for v in VIEWS:
        path, nrows = SHEET.get(v, (SRC % v, 2))
        rgb = np.array(Image.open(path).convert('RGB')).astype(int)
        rgb, fig = key_sheet(rgb)
        figs = [figures(rgb, fig, a, b) for a, b in bands(fig, nrows)]
        for arm in ('r', 'l'):
            frames = [(figs[r][c][0], figs[r][c][1], mir) for r, c, mir in ROWS[v][arm]]
            rows[(v, arm)] = build_row(frames, v, arm)
    up = max(top_needed(r, s, c) for r, s, c in rows.values())
    ch = int(np.ceil(up + 2)) + (OLD_H - FEET)
    print('cell %d x %d (the feet %d px over the bottom, as in the %d-px strips)' % (CELL_W, ch, OLD_H - FEET, OLD_H))
    strips = {}
    for (v, arm), (row, s, cxg) in rows.items():
        st = render(row, s, cxg, ch)
        strips[(v, arm)] = st
        Image.fromarray(st, 'RGBA').save(DST + 'attack_hi_%s_%s.png' % (arm, v))
        # check: the first frame against the low sweep's (body height, case x, feet)
        f = st[:, :CELL_W]
        x0, y0, x1, y1 = t3.bbox(f)
        hg, cxg_, fg = game_ref(v, arm)
        feet = ch - (OLD_H - FEET)
        still = [legs_off(st[:, 0:CELL_W], st[:, i * CELL_W:(i + 1) * CELL_W]) for i in range(6)]
        print('%-2s %s: scale %.4f  body %d px (low sweep %d)  case x %.1f (%.1f)  feet %d (%d)  legs moved by frame %s'
              % (v, arm, s, feet - y0, hg, body_x(f), cxg_, y1, feet, still))
    preview(strips, ch)


def legs_off(f0, f):
    """Check (game size): the shift that best lays frame f's legs (the red of the lowest 40 px) on frame 0's."""
    def m(o):
        r = (t3.red_mask(o) & (o[..., 3] > 0)).astype(float)
        bot = int(np.nonzero(r.any(1))[0].max())
        r[:bot - 40] = 0
        return r
    a, b = m(f0), m(f)
    best = max(((np.roll(np.roll(b, dy, 0), dx, 1) * a).sum(), (dx, dy)) for dy in range(-6, 7) for dx in range(-30, 31))
    return best[1]


def preview(strips, ch, k=3):
    """Old low sweep beside the new high swing, per view and arm, on grass, x k; and a GIF of both playing."""
    bg = (62, 92, 62, 255)
    rows = []
    for v in VIEWS:
        for arm in ('r', 'l'):
            old = Image.open(DST + 'attack_%s_%s.png' % (arm, v)).convert('RGBA')
            new = Image.fromarray(strips[(v, arm)], 'RGBA')
            rows.append((v, arm, old, new))
    W = CELL_W * 12 + 40
    H = ch * len(rows)
    sheet = Image.new('RGBA', (W, H), bg)
    for i, (v, arm, old, new) in enumerate(rows):
        sheet.alpha_composite(old, (0, i * ch + ch - OLD_H))
        sheet.alpha_composite(new, (CELL_W * 6 + 40, i * ch))
    d = ImageDraw.Draw(sheet)
    for i, (v, arm, _, _) in enumerate(rows):
        d.text((CELL_W * 6 + 4, i * ch + 4), '%s %s' % (v.upper(), arm), fill=(255, 255, 255, 255))
    sheet = sheet.resize((W * k, H * k), Image.NEAREST)
    sheet.save('art/redraws/pendulum_high_swing.png')
    # GIF: every view's right arm then left arm, old and new side by side
    gif = []
    for f in range(12):
        arm = 'r' if f < 6 else 'l'
        i = f % 6
        fr = Image.new('RGBA', (CELL_W * 2 * len(VIEWS), ch), bg)
        for j, v in enumerate(VIEWS):
            old = Image.open(DST + 'attack_%s_%s.png' % (arm, v)).convert('RGBA').crop((i * CELL_W, 0, (i + 1) * CELL_W, OLD_H))
            new = Image.fromarray(strips[(v, arm)][:, i * CELL_W:(i + 1) * CELL_W], 'RGBA')
            fr.alpha_composite(old, (j * 2 * CELL_W, ch - OLD_H))
            fr.alpha_composite(new, (j * 2 * CELL_W + CELL_W, 0))
        gif.append(fr.resize((fr.width * k, fr.height * k), Image.NEAREST).convert('RGB'))
    gif[0].save('art/redraws/pendulum_high_swing.gif', save_all=True, append_images=gif[1:], duration=111, loop=0)


if __name__ == '__main__':
    main()
