#!/usr/bin/env python3
"""Writes campaign/maps/obidos_flood.json, the map of Act 2's "The Queen" (d06_queen; the plan:
docs/campaign_act2_plan.md "d06_queen"; what was built: docs/campaign_d06_build.md): d03's island below Óbidos
(tools/campaign/make_obidos_island_map.py, campaign:obidos_island) three years on, in the wet season's flood. Rebuild:
  python3 tools/campaign/make_obidos_flood_map.py [--ascii]

What the flood changes (the map editor's letters: . low, h high, r ramp, w water, f ford = shallow water you wade, t tree):
  - THE RIVER IS HIGH: the sandbanks are gone, the island's rim is under water all round.
  - THE CREEK is twice as wide; its three fords are still the only ways over, and wider.
  - THE SUGAR FIELDS (west and east of the big house), the mill and THE OLD PENS stand in shallow water (wading).
  - THE LOW PENS by the creek, pen 5 (west) and pen 4 (east), are flooded: the stock in them stands in the water.
  - THE BIG PEN (d03's nest clearing, pen 6, in the middle of the deep forest) is the island's highest, driest clearing.
  - THE NORTH-WEST SHORE: a new mud bank where the flood drives the wild Mother onto the island.
  - THE BIG HOUSE on its rise stays dry (the mission rings it with a palisade); THE LANDING keeps a strip of beach for
    the canoes.
"""
import json
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import make_obidos_island_map as base   # noqa: E402  (builds d03's island in memory; writes nothing on import)

W, H = base.W, base.H
cells = [row[:] for row in base.cells]
props = [p[:] for p in base.props]
rnd = random.Random(2775)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def get(x, y):
    return cells[y][x] if 0 <= x < W and 0 <= y < H else "w"


def flood(x0, y0, x1, y1, keep=("h", "r", "k")):
    """Shallow water over the ground (trees drown too: the cane is under water), the rise and its ramps kept."""
    for y in range(y0, y1):
        for x in range(x0, x1):
            if get(x, y) not in keep and get(x, y) != "w":
                put(x, y, "f")


# ---------------------------------------------------------------- the river high: no sandbanks, the rim drowned
for y in range(H):
    for x in range(W):
        dx = (x - base.CX) / 55.0
        dy = (y - base.CY) / 36.0
        if get(x, y) == "f" and dx * dx + dy * dy > 0.95:
            put(x, y, "w")              # (the dry season's sandbanks: under the flood)
        elif dx * dx + dy * dy > 0.88 and get(x, y) in (".", "t"):
            put(x, y, "w")
# (the landing keeps a strip of beach for the canoes)
for y in range(64, 74):
    for x in range(51, 70):
        if get(x, y) == "w" and y < 73:
            put(x, y, ".")

# ---------------------------------------------------------------- the creek: twice as wide, the fords wider
for x in range(0, W):
    y = base.CREEK[x]
    for yy in (y - 1, y + 2):
        if get(x, yy) in (".", "t") and 4 < x < 116:
            put(x, yy, "w")
for nm, fx in base.FORDS.items():
    y = base.CREEK[fx]
    for yy in range(y - 1, y + 3):
        for xx in range(fx - 3, fx + 4):
            put(xx, yy, "f")
    for xx in range(fx - 3, fx + 4):
        for yy in (y - 4, y - 3, y - 2, y + 3, y + 4, y + 5):
            if get(xx, yy) == "t":
                put(xx, yy, ".")

# ---------------------------------------------------------------- the south under water: fields, mill, old pens
flood(18, 48, 50, 68)          # the west cane and the old pens
flood(70, 50, 96, 68)          # the east cane
# (the near pens 7 and 8 drown with the fields; the big house's rise and the landing beach stay dry)

# ---------------------------------------------------------------- the low pens by the creek: flooded clearings
for nm in ("pen_5", "pen_4"):
    cx, cy, rx, ry = base.PENS[nm]
    for y in range(cy - ry - 1, cy + ry + 2):
        for x in range(cx - rx - 1, cx + rx + 2):
            if (x - cx) ** 2 / rx ** 2 + (y - cy) ** 2 / ry ** 2 <= 1.0 and get(x, y) == ".":
                put(x, y, "f")

# ---------------------------------------------------------------- the big pen: a wider, dry clearing for the Mothers
cx, cy = 66, 28
for y in range(cy - 8, cy + 9):
    for x in range(cx - 11, cx + 12):
        if (x - cx) ** 2 / 11.0 ** 2 + (y - cy) ** 2 / 8.0 ** 2 <= 1.0 and get(x, y) in ("t", "f"):
            put(x, y, ".")

# ---------------------------------------------------------------- the north-west shore: where the wild Mother lands
for y in range(16, 27):
    for x in range(12, 26):
        if (x - 19) ** 2 / 7.0 ** 2 + (y - 21) ** 2 / 5.0 ** 2 <= 1.0 and get(x, y) in ("t", "w"):
            put(x, y, ".")


def path(points, width=3):
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(n + 1):
            x = round(x0 + (x1 - x0) * i / n)
            y = round(y0 + (y1 - y0) * i / n)
            for dx in range(-(width // 2), width - width // 2):
                for dy in range(-(width // 2), width - width // 2):
                    if get(x + dx, y + dy) == "t":
                        put(x + dx, y + dy, ".")


path([(19, 21), (22, 17), (24, 14)])          # the shore to pen 1
path([(19, 21), (28, 26), (36, 30)])          # ... and down to the flooded pen 5
path([(92, 26), (84, 28), (77, 28)], 4)       # the flooded east pen 4 to the big pen
path([(36, 30), (48, 30), (58, 29)], 4)       # the flooded west pen 5 to the big pen (d03's path, wider)

# ---------------------------------------------------------------- props: drowned things in the water
props = [p for p in props if not (18 <= p[1] < 50 and 48 <= p[2] < 68) and not (70 <= p[1] < 96 and 50 <= p[2] < 68)
         or p[0] in ("windmill",)]
props += [["log_moss", 30, 58, False], ["dead_trunk", 40, 62, True], ["reeds", 26, 54, False], ["reeds", 34, 64, True],
          ["reeds", 76, 58, False], ["reeds", 84, 62, True], ["log_moss", 88, 56, False], ["sacks_pile", 44, 56, False],
          ["fence_b", 40, 53, False], ["trough", 43, 57, False], ["shed", 44, 55, False],
          # the north-west shore: the flood's wrack
          ["dead_trunk", 15, 19, False], ["log_moss", 21, 24, True], ["reeds", 13, 23, False], ["stump_moss", 23, 18, False],
          # the big pen: straw, troughs, a rough fence on its rim (the keepers' work), kept off its middle
          ["haystack_b", 57, 22, False], ["trough", 75, 33, False], ["fence_b", 56, 30, False], ["fence", 76, 22, True]]

starts = [[66, 28], [58, 56], [80, 12], [19, 21]]
teams = [0, 1, 2, 3]

data = {
    "name": "obidos_flood", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "jungle",
    "starts": starts, "teams": teams, "mode": "1v1", "halls": [],
    "props": props, "checked": True,
}
if __name__ == "__main__":
    out = os.path.join(HERE, "..", "..", "campaign", "maps", "obidos_flood.json")
    with open(out, "w") as f:
        json.dump(data, f)
    print("wrote", os.path.normpath(out), len(props), "props")
    if "--ascii" in sys.argv:
        for i, r in enumerate(cells):
            print("%2d %s" % (i, "".join(r)))
