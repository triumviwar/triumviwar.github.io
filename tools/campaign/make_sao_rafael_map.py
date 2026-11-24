#!/usr/bin/env python3
"""Writes campaign/maps/sao_rafael.json, the map of Act 2's "The Mission of São Rafael" (d05_aldeia; the plan:
docs/campaign_act2_plan.md "d05_aldeia"; what was built: docs/campaign_d05_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford = shallow water you wade, t tree, k rock;
props [name, x, y, flip]). Rebuild:
  python3 tools/campaign/make_sao_rafael_map.py [--ascii]

Tomasz's mission village on the Tapajós (proposed), the wet season of 2776, 104 x 128 cells, the VÁRZEA biome (the
painted flooded-forest ground of the act2-terrain job):
  - THE VÁRZEA everywhere off the dry ground: shallow brown flood water (ford cells) among the drowned trees. The
    mission's `wade` rule (docs/campaign_engine.md, d05): men and horses wade it at half pace, the creatures go through it
    at their full pace, nothing can be built on it. So the dry TRAILS are the men's roads, the flood the swarm's.
  - THE BLUFF (high ground, north-centre): the village of São Rafael: the church, the granary, the houses, the Barracks.
    Three ramps: west (the causeway to the hamlet), east (the landing) and south (the trail to the fort).
  - THE FIELDS below the bluff, dry clearings in the flood: the WEST field, the NORTH field and the RIVER field (east).
  - THE LANDING on the Tapajós (east): a strip of beach, canoes drawn up.
  - THE HAMLET of Santa Luzia (proposed), west, at the end of a dry CAUSEWAY.
  - THE TRAIL to the river fort, south, winding through the flood (the people's road in Part 3).
  - THE RIVER FORT at the south end on its dry rise: the fort's Barracks and Horse Breeder inside a palisade.
  - THE MUD BANK in the north flood where the swarm's forward Mother roots.
"""
import json
import math
import os
import random
import sys

W, H = 104, 128
cells = [["f"] * W for _ in range(H)]
props = []
rnd = random.Random(2776)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def get(x, y):
    return cells[y][x] if 0 <= x < W and 0 <= y < H else "w"


def ellipse(cx, cy, rx, ry, ch, only=None, wob=0.0):
    for y in range(int(cy - ry - 2), int(cy + ry + 3)):
        for x in range(int(cx - rx - 2), int(cx + rx + 3)):
            a = math.atan2(y - cy, x - cx)
            r = 1.0 + wob * math.sin(3 * a + cx * 0.7) * math.cos(2 * a + cy * 0.3)
            if (x - cx) ** 2 / max(rx, 0.5) ** 2 + (y - cy) ** 2 / max(ry, 0.5) ** 2 <= r * r:
                if only is None or get(x, y) in only:
                    put(x, y, ch)


def path(points, width=3, ch=".", only=("f", "t", ".")):
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for i in range(n + 1):
            x = x0 + (x1 - x0) * i / n
            y = y0 + (y1 - y0) * i / n
            for dy in range(-width, width + 1):
                for dx in range(-width, width + 1):
                    if dx * dx + dy * dy <= width * width * 0.6:
                        xx, yy = int(round(x + dx)), int(round(y + dy))
                        if only is None or get(xx, yy) in only:
                            put(xx, yy, ch)


# ---------------------------------------------------------------- the river (east) and its landing
for y in range(H):
    edge = 93 + int(2.5 * math.sin(y / 9.0)) + (1 if y % 7 == 0 else 0)
    for x in range(edge, W):
        put(x, y, "w")

# ---------------------------------------------------------------- the várzea: drowned trees in the flood
for y in range(H):
    for x in range(W):
        if get(x, y) == "f" and rnd.random() < 0.26:
            put(x, y, "t")

# ---------------------------------------------------------------- the dry ground: the bluff, the fields, the trails
BLUFF = (58, 30)
ellipse(58, 30, 21, 14, ".", wob=0.08)                 # (the dry foot of the bluff)
ellipse(58, 30, 15, 10, "h", wob=0.05)                 # THE BLUFF (the village)
RAMPS = []          # (laid last, over the paths: the edge cells of the bluff become slopes)
# the fields below the bluff (dry clearings in the flood)
FIELDS = {"field_w": (31, 31, 7, 5), "field_n": (58, 12, 9, 4), "field_r": (83, 44, 6, 5)}
for nm, (cx, cy, rx, ry) in FIELDS.items():
    ellipse(cx, cy, rx, ry, ".", wob=0.1)
path([(42, 30), (36, 31)], 2)                         # the west field to the west ramp
path([(58, 19), (58, 16)], 2)                         # the north field under the bluff
path([(74, 31), (82, 33), (86, 32)], 2)               # the east ramp to the landing
path([(80, 36), (83, 41)], 2)                         # ... and down to the river field
# the landing: a strip of beach on the Tapajós
for y in range(26, 38):
    for x in range(84, 95):
        if get(x, y) in ("w", "f", "t"):
            put(x, y, "." if x < 92 else "f")
# THE CAUSEWAY west to the hamlet of Santa Luzia
path([(42, 31), (34, 36), (26, 42), (18, 49), (14, 54)], 2)
ellipse(13, 56, 8, 7, ".", wob=0.1)                    # THE HAMLET's clearing
# THE TRAIL south to the river fort (it winds: the people's long road)
TRAIL = [(58, 41), (58, 47), (50, 56), (42, 66), (40, 76), (48, 86), (62, 94), (68, 102), (62, 110)]
path(TRAIL, 2)
# THE RIVER FORT on its dry rise at the south end
for y in range(106, 126):
    for x in range(46, 78):
        if (x - 62) ** 2 / 16.0 ** 2 + (y - 116) ** 2 / 10.0 ** 2 <= 1.0:
            put(x, y, ".")
# THE MUD BANK in the north flood (the forward Mother roots there in Part 3)
ellipse(34, 9, 7, 4, ".", wob=0.1)
# its three ramps: the bluff's edge cells become the slope (west to the causeway, east to the landing, south to the trail)
for y in range(28, 33):
    row = [x for x in range(W) if get(x, y) == "h"]
    for x in (row[0], row[0] + 1, row[-1], row[-1] - 1):
        put(x, y, "r")
for x in range(56, 61):
    col = [y for y in range(H) if get(x, y) == "h"]
    for y in (col[-1], col[-1] - 1):
        put(x, y, "r")
# a few dry islands in the flood (hummocks with palms: they read as ground, not as roads)
for (cx, cy, rx, ry) in [(16, 22, 3, 2), (78, 16, 3, 2), (22, 92, 4, 3), (84, 74, 3, 3), (30, 112, 4, 2), (88, 104, 3, 2)]:
    ellipse(cx, cy, rx, ry, ".")

# the spawn grounds stay open flood (no drowned tree right where the swarm comes out)
for (x0, y0, x1, y1) in [(2, 22, 9, 32), (50, 1, 66, 5), (10, 3, 22, 9), (84, 56, 92, 64), (3, 80, 12, 90), (80, 82, 90, 90),
                         (3, 58, 7, 66), (24, 4, 44, 14)]:
    for y in range(y0, y1):
        for x in range(x0, x1):
            if get(x, y) == "t":
                put(x, y, "f")
# the map's border: flood, never a tree against the edge
for y in range(H):
    for x in range(W):
        if (x < 1 or y < 1 or y > H - 2) and get(x, y) == "t":
            put(x, y, "f")

# ---------------------------------------------------------------- props
props += [
    # the landing: canoes drawn up, a drying rack, a wooden cross
    ["boat", 89, 29, False], ["boat", 90, 34, True], ["drying_rack", 86, 27, False], ["cross_wood", 87, 36, False],
    # the fields: sheaves, a scarecrow, a fence
    ["sheaf", 28, 30, False], ["sheaf", 34, 32, True], ["scarecrow", 31, 28, False], ["fence_b", 26, 33, False],
    ["sheaf", 55, 12, False], ["sheaf", 61, 13, True], ["fence", 64, 11, False],
    ["sheaf", 81, 45, False], ["haystack_b", 85, 43, False],
    # the village: a well, a bell frame by the church (the church itself is the mission's building), the oven
    ["well", 55, 34, False], ["oven", 64, 26, False], ["table", 52, 28, False],
    # the hamlet
    ["drying_rack", 10, 53, False], ["campfire", 14, 58, False], ["boat", 6, 57, True],
    # the trail: a wayside cross, a signpost to the fort
    ["cross_wood", 44, 66, False], ["signpost", 47, 85, False],
    # the fort: a flag, a cart
    ["flag", 62, 108, False], ["cart_b", 56, 120, False],
    # the flood: aninga, floating grass, snags, buriti on the hummocks
    ["buriti", 16, 22, False], ["buriti", 78, 16, False], ["buriti", 22, 92, True], ["buriti", 84, 74, False],
    ["varzea_snag", 30, 8, False], ["varzea_snag", 70, 60, True], ["varzea_snag", 20, 100, False], ["varzea_snag", 80, 96, True],
]
for _ in range(60):
    x, y = rnd.randrange(2, 92), rnd.randrange(2, 126)
    if get(x, y) == "f":
        props.append([rnd.choice(["aninga", "floating_grass", "floating_grass", "varzea_snag"]), x, y, rnd.random() < 0.5])

starts = [[58, 30], [34, 9]]
teams = [0, 1]

data = {
    "name": "sao_rafael", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "varzea",
    # (the flooded forest's shallow water drawn as dark standing water with lilies (the "swamp" ground set), not as reeds: MapGen.apply_custom reads it)
    "ford": "swamp",
    "starts": starts, "teams": teams, "mode": "1v1", "halls": [],
    "props": props, "checked": True,
}
if __name__ == "__main__":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "campaign", "maps", "sao_rafael.json")
    with open(out, "w") as f:
        json.dump(data, f)
    print("wrote", os.path.normpath(out), len(props), "props", "".join("".join(r) for r in cells).count("f"), "flood cells")
    if "--ascii" in sys.argv:
        for i, r in enumerate(cells):
            print("%3d %s" % (i, "".join(r)))
