"""Sprite audit finding 22: the Storm Challenger's north view was drawn beak down (flying toward the camera, like the
south view), while the north swoop's middle frames were flipped to point the beak away. The fly loop (walk_n = idle_n)
and the swoop's other frames (0, 4, 5) are flipped top to bottom here, each frame about its own feet line, so every
north frame points the beak up the screen, away from the camera. Run once.

    python3 tools/flip_storm_n.py
"""
from PIL import Image

U = "assets/units/storm_challenger/"


def flip_frames(path, n, which):
    im = Image.open(path).convert("RGBA")
    w = im.width // n
    for i in which:
        f = im.crop((i * w, 0, (i + 1) * w, im.height))
        bb = f.getbbox()
        g = Image.new("RGBA", f.size)
        part = f.crop(bb).transpose(Image.FLIP_TOP_BOTTOM)
        g.paste(part, (bb[0], bb[1]))  # the same box, flipped inside it: feet and anchor stay put
        im.paste(g, (i * w, 0))
    im.save(path)


flip_frames(U + "walk_n.png", 6, range(6))
flip_frames(U + "idle_n.png", 6, range(6))
flip_frames(U + "attack_n.png", 6, [0, 4, 5])
