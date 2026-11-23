"""The owner's ChatGPT pictures for Act 2's Brazilian ground looks (docs/act2_terrain_art.md),
in place of the stand-ins drawn by tools/make_act2_terrain.py.

Put each picture in art/redraws/act2_terrain/ under the name the doc's prompt gives it:
  <set>.png         a seamless ground picture (varzea, varzea_mud, varzea_water, highland,
                    highland_earth, highland_rock, sertao, sertao_dust, sertao_rock): shrunk
                    to 128 x 128 and cut into the set's variants (64 x 64, laid over 2 x 2 cells;
                    the picture wraps, so cuts across its edges are still seamless)
  <biome>_face.png  a cliff face strip (varzea, highland, sertao): shrunk to 64 x 32, two faces
  <biome>_top.png   (optional) the plateau's top; without it the ground picture's top is used
  <prop>.png        a decoration on a transparent or plain background: the background is taken
                    out, the picture trimmed and shrunk to its stand-in's height (the game's scale)
Pictures not there keep their stand-in.

   python3 tools/import_act2_terrain.py            (import what is there, rewrite the data file)
   python3 tools/import_act2_terrain.py --check    (only say what is there and what isn't)
   python3 tools/import_act2_terrain.py --sheet out.png   (also a contact sheet)"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_act2_terrain as act2  # noqa: E402

SRC = os.path.join(act2.ROOT, "art", "redraws", "act2_terrain")

# the cuts of a 128 x 128 picture for each variant (x, y): the four quarters, then offsets
CUTS = [(0, 0), (64, 0), (0, 64), (64, 64), (32, 32), (96, 32), (32, 96), (96, 96)]


def load(name):
    for ext in (".png", ".jpg", ".jpeg", ".webp"):
        p = os.path.join(SRC, name + ext)
        if os.path.exists(p):
            return Image.open(p)
    return None


def even_light(a):
    """Takes out a slow light gradient across the picture (ChatGPT often lights one corner),
    so the variants cut from it come out alike."""
    from PIL import ImageFilter
    im = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8))
    blur = np.asarray(im.filter(ImageFilter.GaussianBlur(24)), dtype=float)
    mean = a.reshape(-1, 3).mean(0)
    return a - blur + mean


def ground(set_name, n):
    im = load(set_name)
    if im is None:
        return False
    im = im.convert("RGB")
    side = min(im.size)
    im = im.crop(((im.width - side) // 2, (im.height - side) // 2,
                  (im.width - side) // 2 + side, (im.height - side) // 2 + side))
    a = np.asarray(im.resize((128, 128), Image.LANCZOS), dtype=float)
    a = even_light(a)
    for k in range(n):
        x, y = CUTS[k % len(CUTS)]
        t = np.roll(np.roll(a, -y, 0), -x, 1)[:64, :64]
        act2.save_tile(t, "%s_%d" % (set_name, k))
    return True


def strip(name, out_name, h=32):
    im = load(name)
    if im is None:
        return False
    a = np.asarray(im.convert("RGB").resize((64, h), Image.LANCZOS), dtype=float)
    for k in range(2):
        act2.save_tile(a[:, k * 32:(k + 1) * 32], "%s_%d" % (out_name, k))
    return True


def key_out(im):
    """Transparent background: kept if the picture has one, else the border's colour is
    flooded out (a plain backdrop)."""
    im = im.convert("RGBA")
    a = np.asarray(im).copy()
    if (a[:, :, 3] < 250).mean() > 0.05:
        return Image.fromarray(a, "RGBA")
    border = np.concatenate([a[0], a[-1], a[:, 0], a[:, -1]])[:, :3].astype(float)
    bg = np.median(border, 0)
    dist = np.sqrt(((a[:, :, :3].astype(float) - bg) ** 2).sum(-1))
    from scipy import ndimage
    near = dist < 38
    lab, _ = ndimage.label(near)
    edge_labels = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    mask = np.isin(lab, list(edge_labels))
    a[mask, 3] = 0
    return Image.fromarray(a, "RGBA")


def prop(name):
    im = load(name)
    if im is None:
        return False
    im = key_out(im)
    box = im.getbbox()
    if box:
        im = im.crop(box)
    stand_in = os.path.join(act2.PROPS_DIR, name + ".png")
    th = Image.open(stand_in).size[1] if os.path.exists(stand_in) else 48
    tw = max(4, round(im.width * th / im.height))
    im = im.resize((tw, th), Image.LANCZOS)
    a = np.asarray(im).copy()
    a[:, :, 3] = np.where(a[:, :, 3] > 110, 255, 0)      # crisp edges like the painted props
    if name == "mist_wisp":
        a = np.asarray(im).copy()                          # (the mist stays see-through)
    Image.fromarray(a, "RGBA").save(stand_in)
    return True


def main():
    os.makedirs(SRC, exist_ok=True)
    wanted = list(act2.GROUND) + [e + "_face" for e in act2.EDGES] + [e + "_top" for e in act2.EDGES] + list(act2.PROPS)
    if "--check" in sys.argv:
        for w in wanted:
            print(("HAVE   " if load(w) is not None else "absent ") + w)
        return
    done = []
    for s, n in act2.GROUND.items():
        if ground(s, n):
            done.append(s)
    for e in act2.EDGES:
        if strip(e + "_face", e + "_face"):
            done.append(e + "_face")
        if strip(e + "_top", e + "_top"):
            done.append(e + "_top")
        elif e in done or (e == "highland" and "highland" in done):
            # the top from the ground picture (brighter, like the stand-ins')
            for k in range(2):
                t = np.asarray(Image.open(os.path.join(act2.TER, "%s_%d.png" % (e, k))).convert("RGB"),
                               dtype=float)
                act2.save_tile(np.asarray(Image.fromarray(t.astype(np.uint8)).resize((32, 32), Image.LANCZOS),
                                          dtype=float) * 1.06, "%s_top_%d" % (e, k))
    for p in act2.PROPS:
        if prop(p):
            done.append(p)
    act2.write_data()
    if "--sheet" in sys.argv:
        act2.contact_sheet(sys.argv[sys.argv.index("--sheet") + 1])
    print("imported %d of %d pictures: %s" % (len(done), len(wanted), ", ".join(done) or "none"))
    print("(then run the game's import: godot --headless --import)")


if __name__ == "__main__":
    main()
