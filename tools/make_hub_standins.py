#!/usr/bin/env python3
"""STAND-INS for the hubs that grow (job hubs-grow, docs/hubs_grow.md) until the owner's ChatGPT paintings come.

Writes, from campaign/hubs_grow.json:
  campaign/hub/rooms/<room>.jpg  a plain room picture (1672 x 941, the hubs' size): walls, floor, a few shapes for what
                                 the room holds, its hotspots' things roughly where their rects are, "STAND-IN" small
  campaign/hub/rooms/<room>.json its HubScene data (room, size, no layers, lamps/candles, focus)
  campaign/hub/people/<id>.png   a person's silhouette at its size in the json, the face from campaign/portraits/<id>.png
                                 (or <portrait>.png) in a circle for the head, the side's colour on the coat, the name
                                 on a small plate at the feet. Transparent background, like the keyed-out paintings.
A painting from the owner replaces the .jpg / .png of the same name (and a room's json may be rewritten by its importer).
Usage: python3 tools/make_hub_standins.py
"""
import json, os, random
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
W, H = 1672, 941
SERIF = "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"
CINZEL = os.path.join(ROOT, "assets", "fonts", "Cinzel.ttf")

# each room's light and colours (wall top, wall bottom, floor near, floor far, the light's colour, where its lamps are)
ROOMS = {
    "armoury": {"wall": (54, 36, 26), "wall2": (30, 20, 15), "floor": (70, 48, 30), "floor2": (36, 24, 16), "light": (255, 180, 100),
                "lamps": [[300, 190, 160], [1360, 190, 160]], "kind": "rome"},
    "chapel": {"wall": (60, 46, 40), "wall2": (28, 22, 20), "floor": (74, 62, 52), "floor2": (34, 28, 24), "light": (255, 200, 120),
               "candles": [[640, 330], [1030, 330], [1260, 470], [1300, 455], [1340, 470]], "kind": "rome"},
    "gallery": {"wall": (62, 30, 30), "wall2": (30, 16, 16), "floor": (76, 54, 34), "floor2": (38, 26, 18), "light": (255, 185, 110),
                "lamps": [[420, 130, 140], [1250, 130, 140]], "kind": "rome"},
    "yard": {"wall": (70, 64, 60), "wall2": (40, 36, 34), "floor": (82, 76, 68), "floor2": (46, 42, 38), "light": (210, 220, 240),
             "lamps": [[1500, 260, 120]], "kind": "furth"},
    "store": {"wall": (42, 40, 30), "wall2": (22, 22, 16), "floor": (60, 48, 32), "floor2": (30, 24, 16), "light": (255, 200, 130),
              "lamps": [[820, 170, 150]], "kind": "barra"},
    "chart": {"wall": (50, 42, 30), "wall2": (26, 22, 16), "floor": (66, 50, 34), "floor2": (32, 24, 16), "light": (255, 205, 140),
              "lamps": [[760, 380, 150]], "kind": "barra"},
}

SIDE_COAT = {"prologue": (70, 34, 92), "clockmaker": (110, 40, 34), "naturalist": (92, 82, 52)}
# a few people dress for who they are, not their line (the Crown's colonel at Furth, the Church's men)
OWN_COAT = {"rauch": (70, 34, 92), "ferrer": (24, 22, 26), "anselm": (78, 62, 44), "swiss": (150, 120, 30), "jakob": (86, 70, 50),
            "ulrich": (96, 52, 30), "pieter": (120, 110, 90), "benedito": (110, 86, 60)}


def font(sz, path=SERIF):
    try:
        return ImageFont.truetype(path if os.path.exists(path) else SERIF, sz)
    except OSError:
        return ImageFont.load_default()


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def room_picture(rid, cfg, room):
    rnd = random.Random(rid)
    im = Image.new("RGB", (W, H))
    px = im.load()
    horizon = 620
    for y in range(H):
        if y < horizon:
            c = lerp(cfg["wall2"], cfg["wall"], y / horizon)
        else:
            c = lerp(cfg["floor2"], cfg["floor"], (y - horizon) / (H - horizon))
        for x in range(W):
            px[x, y] = c
    d = ImageDraw.Draw(im, "RGBA")
    # panels on the wall, boards on the floor
    for x in range(0, W, 210):
        d.rectangle([x + 18, 220, x + 192, horizon - 30], outline=(0, 0, 0, 60), width=4)
    for y in range(horizon + 20, H, 46):
        d.line([0, y, W, y], fill=(0, 0, 0, 40), width=2)
    d.line([0, horizon, W, horizon], fill=(0, 0, 0, 120), width=6)
    k = cfg["kind"]
    if k == "rome":
        # tall windows with Rome's night in them
        for x in (110, 1450):
            d.rectangle([x, 60, x + 130, 380], fill=(22, 30, 56, 255), outline=(20, 12, 8, 255), width=10)
            d.line([x + 65, 60, x + 65, 380], fill=(20, 12, 8, 255), width=6)
    if k == "furth":
        # a barn: planks, the door open on a grey sky
        for x in range(0, W, 38):
            d.line([x, 0, x, horizon], fill=(0, 0, 0, 50), width=3)
        d.rectangle([1380, 120, 1640, horizon], fill=(150, 158, 170, 255), outline=(30, 26, 22, 255), width=12)
        d.polygon([(1380, horizon), (1640, horizon), (1660, H), (1360, H)], fill=(120, 116, 104, 120))
    if k == "barra":
        d.rectangle([60, 70, 330, 360], fill=(24, 40, 30, 255), outline=(30, 20, 12, 255), width=12)
        for i in range(40):
            x = 60 + rnd.randint(0, 270)
            y = 70 + rnd.randint(0, 290)
            d.line([x, y, x - 5, y + 20], fill=(160, 190, 180, 90), width=2)
    # what the room holds, where its hotspots are
    for hs in room.get("hotspots", []):
        r = hs.get("rect", [0, 0, 0.1, 0.1])
        x0, y0, x1, y1 = r[0] * W, r[1] * H, (r[0] + r[2]) * W, (r[1] + r[3]) * H
        draw_thing(d, rid, hs["id"], x0, y0, x1, y1, rnd)
    # light: halos over it all, then a soft brush
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for lp in cfg.get("lamps", []):
        for i in range(12, 0, -1):
            rr = lp[2] * i / 6.0
            gd.ellipse([lp[0] - rr, lp[1] - rr * 0.8, lp[0] + rr, lp[1] + rr * 0.8], fill=cfg["light"] + (9,))
        gd.ellipse([lp[0] - 14, lp[1] - 20, lp[0] + 14, lp[1] + 10], fill=(255, 230, 170, 255))
    for cp in cfg.get("candles", []):
        for i in range(8, 0, -1):
            rr = 18 * i
            gd.ellipse([cp[0] - rr, cp[1] - rr, cp[0] + rr, cp[1] + rr], fill=cfg["light"] + (8,))
        gd.rectangle([cp[0] - 5, cp[1] + 6, cp[0] + 5, cp[1] + 60], fill=(230, 220, 190, 255))
        gd.ellipse([cp[0] - 5, cp[1] - 10, cp[0] + 5, cp[1] + 6], fill=(255, 220, 140, 255))
    im = Image.alpha_composite(im.convert("RGBA"), glow).convert("RGB")
    # a painterly grain
    noise = Image.effect_noise((W, H), 22).convert("RGB")
    im = Image.blend(im, noise, 0.05).filter(ImageFilter.GaussianBlur(1.4))
    # the vignette
    vig = Image.new("L", (W, H), 0)
    vd = ImageDraw.Draw(vig)
    vd.ellipse([-W * 0.25, -H * 0.3, W * 1.25, H * 1.3], fill=255)
    vig = vig.filter(ImageFilter.GaussianBlur(160))
    im = Image.composite(im, Image.new("RGB", (W, H), (8, 6, 4)), vig)
    im = im.point(lambda v: min(255, int(v * 1.2 + 4)))      # (a little lighter: the people must read against it)
    d = ImageDraw.Draw(im)
    d.text((24, 16), "STAND-IN: " + room["title"] + " (the painting comes later)", font=font(22), fill=(210, 190, 150))
    return im


def draw_thing(d, rid, hid, x0, y0, x1, y1, rnd):
    wood, dark, brass = (92, 60, 34, 255), (30, 20, 14, 255), (190, 150, 70, 255)
    if hid == "racks":
        d.rectangle([x0, y0, x1, y1], fill=(46, 30, 20, 255), outline=dark, width=8)
        for i in range(14):
            x = x0 + 20 + i * (x1 - x0 - 40) / 13
            d.line([x, y0 + 30, x + 6, y1 - 20], fill=(120, 100, 80, 255), width=6)
            d.line([x + 6, y1 - 60, x + 6, y1 - 20], fill=wood, width=12)
        d.rectangle([x0 + 40, y1 + 40, x0 + 300, y1 + 120], fill=(40, 40, 44, 255))      # a gun barrel on its carriage
        d.ellipse([x0 + 60, y1 + 90, x0 + 140, y1 + 170], outline=wood, width=12)
    elif hid in ("guard_book", "muster", "kit", "crates"):
        d.rectangle([x0, y0 + (y1 - y0) * 0.4, x1, y1 + 60], fill=wood, outline=dark, width=6)
        d.rectangle([x0 + 20, y0 + (y1 - y0) * 0.2, x1 - 20, y0 + (y1 - y0) * 0.45], fill=(220, 205, 170, 255), outline=dark, width=3)
    elif hid == "altar":
        d.rectangle([x0, y0 + (y1 - y0) * 0.55, x1, y1], fill=(210, 200, 185, 255), outline=dark, width=6)
        d.rectangle([x0 + 20, y0 + (y1 - y0) * 0.6, x1 - 20, y1 - 10], fill=(120, 30, 40, 255))
        cx = (x0 + x1) / 2
        d.line([cx, y0, cx, y0 + (y1 - y0) * 0.5], fill=brass, width=14)
        d.line([cx - 60, y0 + 70, cx + 60, y0 + 70], fill=brass, width=14)
        d.polygon([(x0 - 40, y0 - 60), (x1 + 40, y0 - 60), ((x0 + x1) / 2, y0 - 200)], outline=brass)
    elif hid == "votive":
        d.rectangle([x0, y1 - 40, x1, y1 + 30], fill=wood)
    elif hid in ("assembly_flag", "council_decree"):
        col = (40, 90, 50, 255) if hid == "assembly_flag" else (225, 215, 185, 255)
        d.line([x0, y0, x0, y1 + 80], fill=dark, width=8)
        d.rectangle([x0 + 6, y0, x1, y1], fill=col, outline=dark, width=4)
        if hid == "assembly_flag":
            d.rectangle([x0 + 6, y0 + (y1 - y0) / 2, x1, y1], fill=(16, 16, 16, 255))
    elif hid in ("type_case", "varenne_letter", "sentence", "bastille_key", "notre_dame"):
        d.rectangle([x0, y0, x1, y1], fill=(60, 40, 26, 255), outline=brass, width=5)
        d.rectangle([x0 + 14, y0 + 14, x1 - 14, y1 - 14], fill=(200, 185, 150, 255))
    elif hid == "bench":
        d.rectangle([x0, y0, x1, y0 + 40], fill=wood, outline=dark, width=6)
        d.line([x0 + 30, y0 + 40, x0 + 30, y1 + 60], fill=dark, width=14)
        d.line([x1 - 30, y0 + 40, x1 - 30, y1 + 60], fill=dark, width=14)
        for i in range(5):
            cx, cy, rr = x0 + 70 + i * (x1 - x0 - 140) / 4, y0 - 26, 18 + 6 * (i % 2)
            d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], outline=brass, width=6)
    elif hid == "drawings":
        d.polygon([(x0, y1), (x1, y1), (x1 - 20, y0), (x0 + 20, y0)], fill=(215, 200, 160, 255), outline=dark)
        for i in range(5):
            d.line([x0 + 30, y0 + 20 + i * 18, x1 - 30, y0 + 20 + i * 18], fill=(60, 50, 40, 200), width=2)
    elif hid in ("honest_one", "broken_kept", "broken_melted"):
        if hid == "broken_melted":
            d.rectangle([x0, y0 + 20, x1, y1], fill=brass, outline=dark, width=4)
        else:
            n = 1 if hid == "honest_one" else 3
            for i in range(n):
                cx = x0 + (x1 - x0) * (i + 0.5) / n
                d.ellipse([cx - 22, y0, cx + 22, y0 + 44], fill=brass)
                d.rectangle([cx - 30, y0 + 44, cx + 30, y1 - 30], fill=(150, 110, 50, 255) if hid == "honest_one" else (80, 80, 74, 255))
    elif hid in ("cages", "jars"):
        d.rectangle([x0, y0, x1, y1], outline=dark, width=10)
        if hid == "cages":
            for i in range(16):
                x = x0 + i * (x1 - x0) / 15
                d.line([x, y0, x, y1], fill=(70, 70, 66, 255), width=6)
            d.rectangle([x0, y1 - 40, x1, y1], fill=(170, 150, 80, 255))
        else:
            for row in range(3):
                for i in range(7):
                    cx, cy = x0 + 40 + i * (x1 - x0 - 80) / 6, y0 + 50 + row * (y1 - y0 - 60) / 2.5
                    d.rounded_rectangle([cx - 20, cy - 30, cx + 20, cy + 30], 8, fill=(70, 120, 60, 200), outline=(180, 210, 170, 200), width=2)
    elif hid == "plateau_map":
        d.polygon([(x0, y1), (x1, y1), (x1 - 40, y0), (x0 + 40, y0)], fill=(205, 185, 140, 255), outline=dark)
        d.ellipse([(x0 + x1) / 2 - 90, y0 + 20, (x0 + x1) / 2 + 90, y1 - 20], fill=(110, 130, 80, 255))
        d.rectangle([x0 + 20, y1, x1 - 20, y1 + 120], fill=wood)
        for i in range(3):
            d.rectangle([200 + i * 420, 120, 520 + i * 420, 380], fill=(200, 180, 140, 255), outline=dark, width=6)
    else:
        d.rectangle([x0, y0, x1, y1], outline=brass, width=4)


def person(pid, pe, line):
    w, h = int(pe["size"][0]), int(pe["size"][1])
    S = 3                                   # drawn big, then shrunk: soft edges
    im = Image.new("RGBA", (w * S, h * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    coat = OWN_COAT.get(pid, SIDE_COAT.get(line, (60, 60, 60)))
    W2, H2 = w * S, h * S
    head = int(min(W2 * 0.46, H2 * 0.13))
    cx = W2 // 2
    top = int(H2 * 0.02)
    sh = top + head * 0.98                  # the shoulders' line
    dark = tuple(max(0, c - 22) for c in coat) + (255,)
    # legs, the neck, the coat, the arms down the sides
    d.rectangle([cx - W2 * 0.15, H2 * 0.62, cx - W2 * 0.03, H2 * 0.97], fill=(28, 24, 22, 255))
    d.rectangle([cx + W2 * 0.03, H2 * 0.62, cx + W2 * 0.15, H2 * 0.97], fill=(28, 24, 22, 255))
    d.ellipse([cx - W2 * 0.16, H2 * 0.95, cx - W2 * 0.01, H2 * 0.995], fill=(18, 14, 12, 255))
    d.ellipse([cx + W2 * 0.01, H2 * 0.95, cx + W2 * 0.16, H2 * 0.995], fill=(18, 14, 12, 255))
    d.rectangle([cx - head * 0.18, top + head * 0.8, cx + head * 0.18, sh + 10], fill=(150, 120, 96, 255))
    d.polygon([(cx - W2 * 0.30, sh), (cx + W2 * 0.30, sh), (cx + W2 * 0.33, H2 * 0.76), (cx - W2 * 0.33, H2 * 0.76)], fill=coat + (255,))
    d.ellipse([cx - W2 * 0.38, sh - 6, cx - W2 * 0.22, H2 * 0.56], fill=dark)
    d.ellipse([cx + W2 * 0.22, sh - 6, cx + W2 * 0.38, H2 * 0.56], fill=dark)
    d.line([cx, sh + 8, cx, H2 * 0.74], fill=(210, 180, 100, 160), width=max(2, S * 2))
    # the face: the mission's portrait in a circle, else a plain head
    por = os.path.join(ROOT, "campaign", "portraits", pe.get("portrait", pid) + ".png")
    hx0, hy0 = cx - head // 2, top
    if os.path.exists(por):
        face = Image.open(por).convert("RGBA").resize((head, head), Image.LANCZOS)
        mask = Image.new("L", (head, head), 0)
        ImageDraw.Draw(mask).ellipse([0, 0, head - 1, head - 1], fill=255)
        im.paste(face, (hx0, hy0), mask)
    else:
        d.ellipse([hx0, hy0, hx0 + head, hy0 + head], fill=(196, 160, 130, 255))
    d.ellipse([hx0, hy0, hx0 + head, hy0 + head], outline=(20, 16, 12, 255), width=S * 2)
    # the name plate at the knees
    name = pe.get("name", pid)
    f = font(max(10, int(W2 * 0.075)))
    tw = d.textlength(name, font=f)
    while tw > W2 * 0.95 and f.size > 8:
        f = font(f.size - 2)
        tw = d.textlength(name, font=f)
    py = int(H2 * 0.82)
    d.rectangle([cx - tw / 2 - 8, py - 4, cx + tw / 2 + 8, py + f.size + 10], fill=(12, 10, 8, 210))
    d.text((cx - tw / 2, py), name, font=f, fill=(240, 220, 170, 255))
    return im.resize((w, h), Image.LANCZOS)


def main():
    data = json.load(open(os.path.join(ROOT, "campaign", "hubs_grow.json")))
    rdir = os.path.join(ROOT, "campaign", "hub", "rooms")
    pdir = os.path.join(ROOT, "campaign", "hub", "people")
    os.makedirs(rdir, exist_ok=True)
    os.makedirs(pdir, exist_ok=True)
    for room in data["rooms"]:
        rid = room["id"]
        cfg = ROOMS[rid]
        jp = os.path.join(rdir, rid + ".jpg")
        if not os.path.exists(jp) or "--force" in os.sys.argv:
            room_picture(rid, cfg, room).save(jp, quality=88)
        fx = {"flicker": 0.03}
        if cfg.get("lamps"):
            fx["lamps"] = [[lp[0], lp[1], lp[2], [c / 255.0 for c in cfg["light"]]] for lp in cfg["lamps"]]
        if cfg.get("candles"):
            fx["candles"] = cfg["candles"]
        js = {"room": "res://campaign/hub/rooms/%s.jpg" % rid, "size": [W, H], "layers": [], "fx": fx, "focus": [0.5, 0.8],
              "stand_in": True}
        with open(os.path.join(rdir, rid + ".json"), "w") as f:
            json.dump(js, f, indent=1)
    for pe in data["people"]:
        pp = os.path.join(pdir, pe["id"] + ".png")
        if not os.path.exists(pp) or "--force" in os.sys.argv:
            person(pe["id"], pe, pe["line"]).save(pp)
    print("stand-ins written:", len(data["rooms"]), "rooms,", len(data["people"]), "people")


if __name__ == "__main__":
    main()
