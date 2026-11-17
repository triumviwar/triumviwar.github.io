#!/usr/bin/env python3
"""Writes campaign/maps/rio_negro_station.json, the Brood prologue's map ("Specimen One", docs/campaign_brood_prologue.md;
what was built: docs/campaign_b01_build.md), in the MAP EDITOR's own format (scripts/mapgen.gd: one letter per cell,
. low, h high, r ramp, w water, f ford, t tree, k rock; props [name, x, y, flip]). Rebuild:
  python3 tools/campaign/make_rio_negro_map.py

The rapids of São Gabriel at high water, June 2767, 128 x 88 cells, the jungle biome (the mission darkens its floor so
the green pack reads on it):
  - SOUTH: the RIO NEGRO across the whole bottom, black and impassable, white RAPIDS at the east end (ford art out in
    the stream, out of reach). Three landings on the bank: the station's JETTY (the canoes: Part 3's exit), the village's
    BEACH (west) and the FORT'S STEPS (east).
  - SOUTH-CENTRE, on a low rise: the ACADEMY'S STATION (the mission places the house, the specimen house, the garden and
    Linnea's pen); ramps to the jetty (south), the causeway (west and east) and the forest (north).
  - WEST: the mission village of NOSSA SENHORA DE NAZARÉ (chapel, houses, the bonfire square).
  - EAST, on a rocky point above the rapids: the FORT (the mission places its Barracks and stakes).
  - Between them the IGAPÓ, the flooded forest: water and trees standing in it; one CAUSEWAY along the bank links the
    village, the station and the fort.
  - The CREEK (igarapé) comes down from the north to the river just east of the station: two fords (the tracks' ford in
    the forest edge, the causeway's at the bank); its mouth, east of the station, is where the Mound Turtle roots.
  - NORTH: deep forest (trees), three TRAILS to TRAIL HEADS at the top (north-west, the creek, north-east): the pack's
    way in, and the way the Sire leads Linnea out. At the very top a rock wall and the creek's waterfall: the first step
    of the mountains.
"""
import json
import os
import random

W, H = 128, 88
cells = [["."] * W for _ in range(H)]
props = []
rnd = random.Random(2767)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def rect(x0, y0, x1, y1, ch):
    for y in range(y0, y1):
        for x in range(x0, x1):
            put(x, y, ch)


def get(x, y):
    return cells[y][x] if 0 <= x < W and 0 <= y < H else "k"


# ---------------------------------------------------------------- the deep forest (north) and its trails
for y in range(0, 46):
    for x in range(W):
        dens = 0.86 if y < 34 else 0.86 - (y - 34) * 0.07      # thinning out toward the forest edge
        if rnd.random() < dens:
            put(x, y, "t")
# the rock wall at the top: the first step of the mountains
for x in range(W):
    for y in range(0, 2 + (x * 7 % 3 == 0)):
        put(x, y, "k")


def trail(points, width=4):
    """A corridor through the trees along a polyline of cells."""
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(n + 1):
            x = round(x0 + (x1 - x0) * i / n)
            y = round(y0 + (y1 - y0) * i / n)
            for dx in range(-(width // 2), width - width // 2):
                for dy in range(-1, 2):
                    if get(x + dx, y + dy) in ("t", "k"):
                        put(x + dx, y + dy, ".")


TRAIL_NW = [(22, 1), (24, 12), (20, 24), (28, 36), (30, 46)]
TRAIL_CREEK = [(77, 1), (76, 14), (78, 28), (77, 40), (76, 47)]
TRAIL_NE = [(110, 1), (112, 14), (106, 26), (102, 38), (100, 47)]
for tr in (TRAIL_NW, TRAIL_CREEK, TRAIL_NE):
    trail(tr, 5)
# clearings at the forest edge (where the lure jars are set) and a few gaps between the trails
for cx, cy, r in [(30, 44, 4), (75, 43, 4), (100, 44, 4), (52, 46, 3), (60, 44, 3), (90, 46, 3), (14, 46, 3), (118, 46, 3)]:
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r - 1, cx + r + 2):
            if (x - cx) ** 2 / (r + 1) ** 2 + (y - cy) ** 2 / r ** 2 <= 1.0 and get(x, y) == "t":
                put(x, y, ".")

# ---------------------------------------------------------------- the river, the rapids, the creek
RIVER_Y = 76
rect(0, RIVER_Y, W, H, "w")
for x in range(W):                          # a ragged bank
    if rnd.random() < 0.35:
        put(x, RIVER_Y - 1, "w")
rect(58, RIVER_Y - 1, 68, RIVER_Y, ".")      # the jetty's bank, the beach, the fort's steps kept even
rect(6, RIVER_Y - 1, 24, RIVER_Y, ".")
rect(106, RIVER_Y - 1, 120, RIVER_Y, ".")
rect(112, 79, 127, 85, "f")                  # the rapids (white water, out in the stream: nobody walks there)
rect(98, 81, 112, 84, "f")
for y in range(0, RIVER_Y):                  # the creek, from the waterfall down to the river
    wob = 1 if (y // 9) % 2 else 0
    for x in range(80 + wob, 83 + wob):
        put(x, y, "w")
rect(79, 45, 85, 49, "f")                    # the tracks' ford, at the forest edge
rect(79, 68, 85, 73, "f")                    # the causeway's ford, by the bank

# ---------------------------------------------------------------- the igapó: the flooded forest either side of the station
for (x0, x1) in [(31, 47), (86, 101)]:
    for y in range(49, 67):
        for x in range(x0, x1):
            v = rnd.random()
            if v < 0.40:
                put(x, y, "w")
            elif v < 0.66:
                put(x, y, "t")
# a few pools along the causeway's edge, never across it
for (x0, x1) in [(33, 45), (88, 99)]:
    for x in range(x0, x1, 3):
        put(x, 66, "w")

# ---------------------------------------------------------------- the station's rise
rect(48, 52, 78, 69, "h")
rect(60, 69, 65, 70, "r")                    # south: down to the jetty
rect(47, 59, 48, 64, "r")                    # west: the causeway to the village
rect(78, 59, 79, 64, "r")                    # east: the causeway to the fort
rect(60, 51, 65, 52, "r")                    # north: the forest edge
for x, y in [(48, 52), (49, 52), (77, 52), (48, 68), (77, 68)]:
    put(x, y, "k")

# ---------------------------------------------------------------- the fort's rocky point (east)
for x, y in [(103, 55), (104, 55), (104, 56), (123, 55), (124, 56), (125, 57), (126, 58), (103, 72), (124, 72)]:
    put(x, y, "k")

# ---------------------------------------------------------------- props
# the village of Nossa Senhora de Nazaré: the chapel, houses on stilts (cottages), the bonfire square, manioc fields
props += [["chapel", 9, 57, False], ["chapel_tower", 13, 56, False], ["cross_wood", 18, 60, False]]
for i, (x, y) in enumerate([(4, 63), (8, 66), (24, 58), (26, 63), (4, 69), (27, 69)]):
    props.append(["cottage", x, y, i % 2 == 1])
props += [["campfire", 15, 66, False], ["campfire", 20, 69, False], ["spit_roast", 17, 70, False], ["bench", 13, 68, False],
          ["drying_rack", 22, 66, False], ["basket_grain", 11, 71, False], ["boat", 9, 74, False], ["boat", 17, 74, True],
          ["planter", 6, 60, False], ["sheaf", 22, 55, False]]
# the station: the jetty's canoes and crates, the goat pen's fence, the lamp-oil barrels, the specimen jars
props += [["boat", 59, 74, False], ["boat", 63, 74, True], ["boat", 66, 73, False], ["anchor", 57, 73, False],
          ["crate_long", 58, 71, False], ["crates_pair", 67, 71, False],
          ["fence", 50, 66, False], ["fence_b", 53, 66, False], ["trough", 51, 64, False],
          ["barrel_a", 73, 54, False], ["barrel_b", 74, 55, False], ["jar", 72, 66, False], ["jar_b", 74, 66, False],
          ["table", 57, 66, False], ["tripod", 75, 62, False]]
# the fort: stakes, a flag, powder
props += [["flag", 114, 57, False], ["cannonballs", 118, 66, False], ["barrel_d", 120, 64, False], ["watch_frame", 107, 58, False]]
# the forest's own: the trail heads, nests, roots
props += [["dead_trunk", 26, 30, False], ["log_moss", 79, 33, False], ["nest", 74, 20, False], ["stump_moss", 104, 31, False],
          ["boulder_moss", 18, 40, False], ["rocks_moss", 112, 40, False]]

starts = [[52, 55], [112, 60], [68, 63], [76, 6]]   # the station, the fort, the pen, the pack (the mission places its own)
teams = [0, 0, 0, 1]

data = {
    "name": "rio_negro_station", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "jungle",
    "starts": starts, "teams": teams, "mode": "2v2", "halls": [],
    "props": props, "checked": True,
}
out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "rio_negro_station.json")
with open(out, "w") as f:
    json.dump(data, f)
print("wrote", os.path.normpath(out), len(props), "props")
