#!/usr/bin/env python3
"""The hubs that grow (docs/hubs_grow.md): the ChatGPT paintings put over the stand-ins.

  art/campaign/hub/grow/<room>_chatgpt.png    a room (armoury, chapel, gallery, yard, store, chart): cropped to the
                                              hubs' 16:9, scaled to 1672 x 941, saved over campaign/hub/rooms/<room>.jpg
                                              and its json's "stand_in" dropped
  art/campaign/hub/grow/<person>_chatgpt.png  a person on flat magenta: keyed out (tools/hub_key.py), scaled to the
                                              height the stand-in had, toned into the room's light, saved over
                                              campaign/hub/people/<id>.png; campaign/hubs_grow.json's "pos" and "size"
                                              fitted (feet and middle where the stand-in's were)
A picture that isn't there is skipped (its stand-in stays).
  python3 tools/import_hubs_grow.py [--preview DIR]   (DIR: each room with its people pasted in, to look at)"""
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import hub_key  # noqa: E402

SRC = "art/campaign/hub/grow/%s_chatgpt.png"
W, H = 1672, 941
JSON = "campaign/hubs_grow.json"
# each room's light on a figure painted in plain light (multipliers on red, green, blue)
TONE = {"armoury": (0.86, 0.76, 0.66), "chapel": (0.88, 0.78, 0.66), "gallery": (0.86, 0.76, 0.66),
        "yard": (0.86, 0.88, 0.92), "store": (0.84, 0.78, 0.66), "chart": (0.86, 0.78, 0.66),
        "study": (0.82, 0.74, 0.66), "workshop": (0.86, 0.8, 0.72), "station": (0.84, 0.78, 0.66)}


def room(rid):
    src = SRC % rid
    if not os.path.exists(src):
        return False
    im = Image.open(src).convert("RGB")
    w, h = im.size
    if w / h > W / H:
        nw = round(h * W / H)
        im = im.crop(((w - nw) // 2, 0, (w - nw) // 2 + nw, h))
    else:
        nh = round(w * H / W)
        im = im.crop((0, (h - nh) // 2, w, (h - nh) // 2 + nh))
    im.resize((W, H), Image.LANCZOS).save("campaign/hub/rooms/%s.jpg" % rid, quality=90)
    jp = "campaign/hub/rooms/%s.json" % rid
    info = json.load(open(jp))
    info.pop("stand_in", None)
    json.dump(info, open(jp, "w"), indent=1)
    return True


def person(p):
    src = SRC % p["id"]
    if not os.path.exists(src):
        return False
    fig, _box = hub_key.key(Image.open(src))
    w0, h0 = p["size"]
    s = h0 / fig.height
    fig = fig.resize((max(1, round(fig.width * s)), h0), Image.LANCZOS)
    a = np.asarray(fig).astype(float)
    a[..., :3] *= np.array(TONE.get(p.get("room", ""), (0.86, 0.8, 0.72)))
    fig = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "RGBA")
    fig.save("campaign/hub/people/%s.png" % p["id"])
    mid = p["pos"][0] + w0 / 2
    p["pos"] = [round(mid - fig.width / 2), p["pos"][1]]
    p["size"] = [fig.width, h0]
    return True


def main():
    data = json.load(open(JSON))
    done = []
    for rid in ("armoury", "chapel", "gallery", "yard", "store", "chart"):
        if room(rid):
            done.append(rid)
    for p in data["people"]:
        if person(p):
            done.append(p["id"])
    text = open(JSON).read()     # the json keeps its own layout: only each changed person's pos and size are rewritten
    for p in data["people"]:
        if p["id"] in done:
            i = text.index('"id": "%s"' % p["id"])
            for k in ("pos", "size"):
                a = text.index('"%s": [' % k, i)
                b = text.index("]", a)
                text = text[:a] + '"%s": [%d, %d' % (k, p[k][0], p[k][1]) + text[b:]
    open(JSON, "w").write(text)
    print("put in:", ", ".join(done) or "nothing")
    if "--preview" in sys.argv:
        out = sys.argv[sys.argv.index("--preview") + 1]
        os.makedirs(out, exist_ok=True)
        for rid in ("armoury", "chapel", "gallery", "yard", "store", "chart"):
            comp = Image.open("campaign/hub/rooms/%s.jpg" % rid).convert("RGBA")
            for p in data["people"]:
                if p.get("room") == rid:
                    fig = Image.open("campaign/hub/people/%s.png" % p["id"]).convert("RGBA")
                    comp.alpha_composite(fig, tuple(max(0, v) for v in p["pos"]))
            comp.convert("RGB").resize((836, 470)).save(os.path.join(out, rid + ".jpg"))


if __name__ == "__main__":
    main()
