#!/usr/bin/env python3
"""Writes the two maps of Act 3's first mission, "Brazil After the Fires" (e01_brazil; the plan:
docs/campaign_act3_plan.md "e01_brazil"; what was built: docs/campaign_e01_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd: . low, h high, r ramp, w water, f ford = shallow water, t tree, k rock; props [name, x, y, flip]).
Both are MADE FROM ACT 2's MAPS, as a04's map was made from a02's (run their scripts first if they change):
  python3 tools/campaign/make_brazil_retreat_map.py [--ascii river|south]

  campaign:brazil_river (THE RIVER ROAD, d09 `first` clockwork: the swarm was fought second): d10's Óbidos
    (campaign/maps/obidos_front.json, 144 x 96) with 48 cells more to the east: the levee goes on past Óbidos to the
    river's mouth, where the port (Belém, the ships) stands on a neck of land between the bay and the river: THE LAST
    BLUFF across the neck, the quay behind it. The swarm comes down the levee from upriver (west).
  campaign:brazil_south (THE SOUTHERN ROAD, d09 `first` brood: the city was fought second): d11's siege of Concórdia
    (campaign/maps/concordia_siege.json, 176 x 96) cut at its 112th column (the camp, the wall and the city's west quarter kept), with 80 cells
    more to the west: the road from the old siege camp down to the sea (Santos), the bluff across the neck, the quay.
    A stream is cut north to south through the old camp: THE FORD the line holds in Part 1. The machines come out of
    the city (east).

Both maps are 192 x 96 and keep their key places in AREAS (the mission script imports them: one area name, two maps).
The mission places the buildings and everyone; this script lays the ground and the props.
"""
import json
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
MAPS = os.path.join(ROOT, "campaign", "maps")
W, H = 192, 96

# ================================================================== the areas (x, y, w, h in cells), one map each
AREAS = {
    "river": dict(
        edge=[0, 49, 4, 6], edge_n=[18, 2, 8, 6],                 # the swarm comes down the levee and the west creek
        op=[16, 25, 8, 7], op2=[6, 49, 7, 5],                     # the outposts that fall back (the creek post, the upriver landing)
        op_way=[19, 48, 4, 6],
        ford=[28, 49, 6, 6], ford_far=[22, 49, 5, 6], ford_hold=[35, 49, 7, 6], muster=[44, 50, 6, 4],
        col_start=[36, 48, 7, 7],
        hamlet=[72, 49, 8, 5], town=[118, 38, 10, 6],
        pass_at=[106, 56, 12, 3], pass_wait=[96, 49, 8, 6],
        r1=[86, 50, 6, 5], r2=[100, 50, 6, 6], r3=[104, 56, 6, 3], r4=[134, 56, 6, 3], r5=[150, 52, 6, 5], r6=[160, 51, 4, 5],
        flank_a=[146, 18, 8, 8], flank_b=[80, 22, 8, 8], flank_c=[56, 28, 6, 6],
        bluff=[164, 44, 17, 17], bluff_front=[164, 49, 4, 7], bluff_mid=[170, 49, 6, 6], guns_1=[168, 47, 2, 2], guns_2=[168, 56, 2, 2],
        fort_at=[173, 46, 5, 4], barracks_at=[174, 55, 4, 3],
        quay=[182, 46, 6, 14], quay_in=[183, 50, 4, 6], port=[158, 40, 34, 26], sea=[189, 40, 3, 26],
    ),
    "south": dict(
        edge=[164, 42, 8, 10], edge_n=[150, 74, 8, 6],            # the machines come out of the city (east) and along the stream
        op=[126, 16, 7, 7], op2=[126, 68, 7, 7],                  # the siege lines' two batteries that fall back
        op_way=[124, 42, 4, 6],
        ford=[118, 42, 6, 8], ford_far=[124, 42, 4, 8], ford_hold=[110, 42, 7, 8], muster=[102, 44, 6, 5],
        col_start=[108, 41, 7, 9],
        hamlet=[84, 18, 8, 7], town=[88, 58, 10, 7],
        pass_at=[54, 43, 8, 7], pass_wait=[74, 43, 7, 7],
        r1=[94, 44, 6, 5], r2=[76, 44, 6, 5], r3=[60, 44, 6, 5], r4=[44, 44, 6, 5], r5=[30, 44, 4, 5], r6=[24, 45, 3, 4],
        flank_a=[50, 10, 8, 8], flank_b=[66, 78, 8, 8], flank_c=[40, 72, 6, 6],
        bluff=[9, 38, 13, 19], bluff_front=[18, 44, 4, 7], bluff_mid=[12, 44, 6, 6], guns_1=[18, 41, 2, 2], guns_2=[18, 53, 2, 2],
        fort_at=[10, 39, 5, 4], barracks_at=[10, 52, 4, 3],
        quay=[2, 40, 5, 16], quay_in=[3, 44, 3, 8], port=[0, 34, 30, 28], sea=[0, 34, 2, 28],
    ),
}
# the road's waypoints, danger side to the ships (both maps); the pass between r2 and r3 (the river road: the landing under
# Óbidos' bluff, two cells wide; the southern road: the Serra's defile)
ROAD = ["r1", "r2", "r3", "r4", "r5", "r6", "bluff_mid", "quay_in"]


class Grid:
    def __init__(self, w, h, fill="."):
        self.w, self.h = w, h
        self.c = [[fill] * w for _ in range(h)]

    def put(self, x, y, ch):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.c[y][x] = ch

    def get(self, x, y):
        return self.c[y][x] if 0 <= x < self.w and 0 <= y < self.h else "w"

    def rect(self, x0, y0, x1, y1, ch):
        for y in range(y0, y1):
            for x in range(x0, x1):
                self.put(x, y, ch)

    def text(self):
        return "".join("".join(r) for r in self.c)


def load(name):
    return json.load(open(os.path.join(MAPS, name + ".json"), encoding="utf-8"))


def clear_props(props, rects):
    def inside(p):
        return any(x0 <= p[1] < x0 + w and y0 <= p[2] < y0 + h for (x0, y0, w, h) in rects)
    return [p for p in props if not inside(p)]


def carve(g, a, ch="."):
    x, y, w, h = a
    g.rect(x, y, x + w, y + h, ch)


def free_props(g, props, items):
    """Adds decorations [name, x, y, flip] that stand on open ground."""
    for (n, x, y, *fl) in items:
        if g.get(x, y) in ".h":
            props.append([n, x, y, bool(fl[0]) if fl else False])


# ================================================================== THE RIVER ROAD (from d10's Óbidos)
def build_river():
    src = load("obidos_front")
    sw, sh = src["size"]
    g = Grid(W, H, "f")
    for y in range(sh):
        for x in range(sw):
            g.c[y][x] = src["cells"][y * sw + x]
    rnd = random.Random(2781)
    # the lower river east of Óbidos: the várzea north, the levee, the channel, the south bank
    for y in range(H):
        for x in range(sw, W):
            if y < 50:
                v = rnd.random()
                g.put(x, y, "t" if v < 0.34 else ("w" if v < 0.42 else ("." if v < 0.52 else "f")))
            elif y < 59:
                g.put(x, y, "." if rnd.random() > 0.04 or y in (52, 53, 54, 55, 56) else "t")
            elif y < 80:
                g.put(x, y, "w")
            else:
                g.put(x, y, "t" if rnd.random() < 0.45 else "f")
    # the road past Óbidos on the low ground: the levee's end, down along the bluff's foot to the landing and on east
    g.rect(96, 50, 112, 56, ".")
    g.rect(100, 55, 112, 59, ".")
    g.rect(112, 57, 144, 59, ".")
    g.rect(140, 52, 160, 59, ".")
    # the levee's two creek crossings stay fords (the mission's FORD is the west one); the east one a little wider
    g.rect(64, 50, 69, 54, "f")
    # THE PORT: a neck of land between the bay (north) and the river's mouth (south), the bluff across it, the quay
    g.rect(158, 0, W, 44, "w")
    g.rect(158, 61, W, H, "w")
    g.rect(160, 44, 164, 61, ".")
    g.rect(164, 44, 181, 61, "h")
    g.rect(164, 49, 165, 56, "r")       # the west ramp (the road up)
    g.rect(180, 49, 181, 56, "r")       # the east ramp (down to the quay)
    g.rect(181, 44, 189, 61, ".")       # THE QUAY
    g.rect(189, 40, W, 66, "w")         # the deep water where the ships lie
    g.rect(160, 43, 164, 44, "w")
    # the outposts' ground: the creek post's clearing (d10's west creek Mother site) and the upriver landing
    for a in ("op", "op2", "hamlet", "muster", "ford_hold", "col_start"):
        carve(g, AREAS["river"][a])
    g.rect(19, 32, 23, 50, ".")          # the creek post's trail down to the levee
    props = clear_props(src["props"], [(96, 48, 50, 12), (0, 46, 50, 10), (14, 22, 14, 12), (68, 46, 16, 10)])
    props = [p for p in props if p[0] not in ("nest",)]
    free_props(g, props, [
        ["boat", 186, 47], ["boat", 186, 53], ["boat", 185, 58], ["anchor", 183, 45], ["crate_long", 182, 52],
        ["sacks_pile", 184, 56], ["barrel_d", 182, 49], ["crates_pair", 183, 59], ["flag", 172, 45], ["cannonballs", 169, 59],
        ["shed", 76, 47], ["well", 74, 51], ["fence_b", 78, 52], ["signpost", 40, 49], ["sacks_pile", 46, 53],
        ["signpost", 150, 52], ["crate_long", 136, 58], ["trough", 18, 27], ["flag", 9, 49], ["boat", 10, 56],
    ])
    for (x, y) in [(147, 51), (153, 50), (157, 51), (144, 50)]:
        if g.get(x, y) == ".":
            props.append(["varzea_tree", x, y, False])
    data = dict(src)
    data.update({"name": "brazil_river", "size": [W, H], "cells": g.text(), "props": props, "starts": [[38, 51], [8, 51]]})
    return data, g


# ================================================================== THE SOUTHERN ROAD (from d11's siege of Concórdia)
SHIFT = 80          # the source's columns 0..111 land at 80..191


def build_south():
    src = load("concordia_siege")
    sw, sh = src["size"]
    g = Grid(W, H, ".")
    for y in range(sh):
        for x in range(0, W - SHIFT):
            g.c[y][x + SHIFT] = src["cells"][y * sw + x]
    rnd = random.Random(2781)
    # the coast: the woods of the Serra on the way down, open in the road's band
    for y in range(H):
        for x in range(0, SHIFT):
            v = rnd.random()
            far = abs(y - 46) > 8
            g.put(x, y, "t" if (far and v < 0.28) or (not far and v < 0.03) else ".")
    g.rect(0, 0, SHIFT + 2, 1, "t")
    g.rect(0, H - 1, SHIFT + 2, H, "t")
    # THE PORT: a neck of land between two arms of the sea, the bluff across it, the quay on the west
    g.rect(0, 0, 24, 38, "w")
    g.rect(0, 57, 24, H, "w")
    g.rect(22, 38, 26, 57, ".")
    g.rect(9, 38, 22, 57, "h")
    g.rect(21, 44, 22, 51, "r")        # the east ramp (the road up)
    g.rect(8, 44, 9, 51, "r")          # the west ramp (down to the quay)
    g.rect(2, 38, 8, 57, ".")          # THE QUAY
    g.rect(0, 34, 2, 62, "w")          # the deep water where the ships lie
    g.rect(2, 38, 9, 39, "w")
    g.rect(2, 56, 9, 57, "w")
    # THE STREAM through the old camp, north to south, its one ford on the road (the line holds its west bank)
    for y in range(1, H - 1):
        for x in range(119, 123):
            g.put(x, y, "w")
    g.rect(118, 42, 124, 50, "f")
    g.rect(114, 42, 118, 50, ".")
    g.rect(124, 42, 128, 50, ".")
    # the road's band west of the ford, and the hamlets' ground; THE PASS where the road goes down through the Serra
    g.rect(24, 44, 118, 49, ".")
    for y in list(range(28, 43)) + list(range(50, 66)):
        for x in range(50, 67):
            if rnd.random() < 0.8:
                g.put(x, y, "k" if (x + y) % 3 else "t")
    for a in ("op", "op2", "hamlet", "town", "muster", "ford_hold", "col_start", "ford_far", "pass_at", "pass_wait"):
        carve(g, AREAS["south"][a])
    # (the shifted city: its north-west corner keeps its trees; the old wall's footings stay)
    props = []
    for p in src["props"]:
        if p[1] < W - SHIFT:
            props.append([p[0], p[1] + SHIFT, p[2], p[3] if len(p) > 3 else False])
    props = [p for p in props if g.get(p[1], p[2]) not in "wf"]
    props = clear_props(props, [(114, 40, 16, 12), (122, 14, 14, 12), (122, 66, 14, 12), (82, 16, 12, 12), (86, 56, 14, 11),
                                (24, 42, 96, 9), (160, 40, 14, 14)])
    free_props(g, props, [
        ["boat", 1, 41], ["boat", 1, 47], ["boat", 1, 53], ["anchor", 4, 39], ["crate_long", 3, 49], ["sacks_pile", 5, 45],
        ["barrel_d", 4, 54], ["crates_pair", 6, 42], ["flag", 14, 40], ["cannonballs", 19, 55],
        ["signpost", 104, 43], ["sacks_pile", 100, 49], ["haybales", 87, 20], ["wagon", 92, 60], ["signpost", 40, 43],
    ])
    data = dict(src)
    data.update({"name": "brazil_south", "size": [W, H], "cells": g.text(), "props": props, "starts": [[111, 45], [168, 46]]})
    return data, g


def write(data):
    out = os.path.join(MAPS, data["name"] + ".json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False)
    return out


def ascii_of(g, step=2):
    rows = []
    for y in range(0, g.h, step):
        rows.append("".join(g.c[y][x] for x in range(0, g.w, step)))
    return "\n".join(rows)


if __name__ == "__main__":
    built = {"river": build_river(), "south": build_south()}
    for k, (d, g) in built.items():
        print("wrote", os.path.normpath(write(d)), len(d["props"]), "props")
    if "--ascii" in sys.argv:
        which = sys.argv[sys.argv.index("--ascii") + 1] if len(sys.argv) > sys.argv.index("--ascii") + 1 else "river"
        g = built[which][1]
        marks = {}
        for name, (x, y, w, h) in AREAS[which].items():
            marks[(x, y)] = name[0].upper()
        for y in range(g.h):
            print("%2d " % y + "".join(marks.get((x, y), g.c[y][x]) for x in range(g.w)))
