#!/usr/bin/env python3
"""The war map's painted seals and compass rose (ChatGPT, 2026-11-20), keyed off their magenta ground.

art/campaign/warmap_seals_chatgpt.png: a 4 x 2 grid on magenta, top row whole, bottom row cracked, in the order crown
(purple, a crown), clockmaker (amber, a gear), naturalist (green, a leaf: replaced by the eye sheet below), all (gold, a star). Each seal is found as the
largest blob in its grid cell, cropped square round it and written 128 x 128 to campaign/warmap_art/seal_<line>.png and
seal_<line>_broken.png. art/campaign/warmap_rose_chatgpt.png -> campaign/warmap_art/rose.png (256 x 256).
WarMap draws them when they exist (else its own drawn seals and rose).

    python3 tools/campaign/import_warmap_art.py
"""
import os

from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
LINES = ["crown", "clockmaker", "naturalist", "all"]


def key(im):
    """Magenta to clear: by distance to pure magenta (the purple wax is far enough from it to keep its colour)."""
    im = im.convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, _ = px[x, y]
            d = ((255 - r) ** 2 + g ** 2 + (255 - b) ** 2) ** 0.5
            if d < 90:
                px[x, y] = (0, 0, 0, 0)
            elif d < 150:
                px[x, y] = (r, g, b, int(255 * (d - 90) / 60))
    return im


def square(im, size):
    bb = im.getbbox()
    c = im.crop(bb)
    s = max(c.size) + 4
    out = Image.new("RGBA", (s, s))
    out.alpha_composite(c, ((s - c.width) // 2, (s - c.height) // 2))
    return out.resize((size, size), Image.LANCZOS)


def main():
    out = os.path.join(ROOT, "campaign/warmap_art")
    os.makedirs(out, exist_ok=True)
    # the brighter set (owner 2026-11-20: "brighter to match [the eye], more like the Triumviwar logo"): 3 x 2, crown
    # (purple, gold crown), clockmaker (crimson, gold gear), all (gold, a star); whole on top, cracked below. (The first
    # sheet, warmap_seals_chatgpt.png, darker, is kept in art/ but no longer used.)
    sheet = key(Image.open(os.path.join(ROOT, "art/campaign/warmap_seals_bright_chatgpt.png")))
    w, h = sheet.size
    for row in range(2):
        for i, line in enumerate(["crown", "clockmaker", "all"]):
            cell = sheet.crop((i * w // 3, row * h // 2, (i + 1) * w // 3, (row + 1) * h // 2))
            name = "seal_%s%s.png" % (line, "_broken" if row else "")
            square(cell, 128).save(os.path.join(out, name))
            print("wrote", name)
    # the Naturalist's seal is the green REPTILE EYE of the game's emblem (owner 2026-11-20: "an eye like the
    # triumviwar", not a leaf): its own sheet, whole left, cracked right
    eye = key(Image.open(os.path.join(ROOT, "art/campaign/warmap_seal_eye_chatgpt.png")))
    w, h = eye.size
    for i, name in enumerate(["seal_naturalist.png", "seal_naturalist_broken.png"]):
        square(eye.crop((i * w // 2, 0, (i + 1) * w // 2, h)), 128).save(os.path.join(out, name))
        print("wrote", name, "(the eye)")
    # the ornaments (2026-11-20, the old-map look): 2 x 2: a three-master, a two-master, a sea serpent, an empty
    # cartouche
    orn = key(Image.open(os.path.join(ROOT, "art/campaign/warmap_ornaments_chatgpt.png")))
    # each ornament is the group of pieces round one of the four biggest blobs (the pieces closed up by a dilation, so a
    # ship's rigging and its waves stay with it and a neighbour's bowsprit does not), in reading order
    import numpy as np
    from scipy import ndimage
    rgba = np.asarray(orn).copy()
    a = rgba[..., 3] > 40
    lab, n = ndimage.label(ndimage.binary_dilation(a, iterations=6))
    sizes = ndimage.sum(a, lab, range(1, n + 1))
    big = sorted(range(1, n + 1), key=lambda k: -sizes[k - 1])[:4]
    objs = ndimage.find_objects(lab)
    big.sort(key=lambda k: (round(objs[k - 1][0].start / (orn.height / 2)), objs[k - 1][1].start))
    for name, k in zip(["ship_big", "ship_small", "serpent", "cartouche"], big):
        ys, xs = objs[k - 1]
        part = rgba[ys, xs].copy()
        part[lab[ys, xs] != k, 3] = 0
        cell = Image.fromarray(part)
        cell.thumbnail((512, 512), Image.LANCZOS)
        cell.save(os.path.join(out, name + ".png"))
        print("wrote", name)
    # the mountains: 4 x 2 inked peaks
    mt = os.path.join(ROOT, "art/campaign/warmap_mountains_chatgpt.png")
    if os.path.exists(mt):
        m = key(Image.open(mt))
        w, h = m.size
        for i in range(8):
            cell = m.crop(((i % 4) * w // 4, (i // 4) * h // 2, (i % 4 + 1) * w // 4, (i // 4 + 1) * h // 2))
            cell = cell.crop(cell.getbbox())
            cell.thumbnail((128, 128), Image.LANCZOS)
            cell.save(os.path.join(out, "mountain_%d.png" % i))
        print("wrote mountain_0..7")
    # the parchment: ChatGPT's sheet, toned down (lighter, less orange) so the ink reads on it
    pa = os.path.join(ROOT, "art/campaign/warmap_parchment_chatgpt.png")
    if os.path.exists(pa):
        from PIL import ImageEnhance
        im = Image.open(pa).convert("RGB")
        im = im.crop((0, 0, im.width, im.height - 3))
        im = ImageEnhance.Color(im).enhance(0.62)
        im = ImageEnhance.Brightness(im).enhance(1.10)
        im = ImageEnhance.Contrast(im).enhance(0.80)
        im.resize((2048, int(2048 * im.height / im.width)), Image.LANCZOS).save(os.path.join(out, "parchment.jpg"), quality=90)
        print("wrote parchment.jpg (from ChatGPT's sheet)")
    rose = key(Image.open(os.path.join(ROOT, "art/campaign/warmap_rose_chatgpt.png")))
    square(rose, 256).save(os.path.join(out, "rose.png"))
    print("wrote rose.png")


if __name__ == "__main__":
    main()
