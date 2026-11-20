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
    sheet = key(Image.open(os.path.join(ROOT, "art/campaign/warmap_seals_chatgpt.png")))
    w, h = sheet.size
    for row in range(2):
        for i, line in enumerate(LINES):
            cell = sheet.crop((i * w // 4, row * h // 2, (i + 1) * w // 4, (row + 1) * h // 2))
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
    rose = key(Image.open(os.path.join(ROOT, "art/campaign/warmap_rose_chatgpt.png")))
    square(rose, 256).save(os.path.join(out, "rose.png"))
    print("wrote rose.png")


if __name__ == "__main__":
    main()
