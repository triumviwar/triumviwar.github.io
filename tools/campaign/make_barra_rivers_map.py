#!/usr/bin/env python3
"""Writes campaign/maps/barra_rivers.json, the map of Act 2's "Down the Rivers" (d08_rivers; the plan:
docs/campaign_act2_plan.md "d08_rivers"; what was built: docs/campaign_d08_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford = shallow water you wade, t tree,
k rock; props [name, x, y, flip]). Rebuild:
  python3 tools/campaign/make_barra_rivers_map.py [--ascii]

The Rio Negro in the floods of 2778, 128 x 88 cells (north up), the jungle biome:
  - THE RIO NEGRO comes down from the north (top, west of the middle) and bends a little east to meet THE BROWN RIVER
    (the Solimões) that runs along the whole bottom: the meeting of the waters, south of the middle.
  - WEST of the Rio Negro: THE FAR BANK, all várzea (flooded forest: trees standing in pools, mud paths). The swarm's
    side: the plateau's road comes in at its north-west corner; THREE FORWARD MOTHER SITES on it (north, opposite
    Nazaré; middle; south, opposite the Barra) and THE FLOODED FOREST in its south-west corner (where a lured wave
    drowns its own road). THE FAR POINT, by the south shallows, is where a lure post would stand.
  - THREE SHALLOWS cross the Rio Negro (fords): THE RAPIDS at the very top (into Nazaré), THE MIDDLE SHALLOWS (to the
    halfway landing on the bank trail) and THE BARRA SHALLOWS (into the Barra's lower town).
  - EAST of the Rio Negro, north: NAZARÉ (b01's mission village): the chapel, houses, the manioc fields, and the BEACH
    where Benedito's canoes wait.
  - EAST, the middle: THE BANK TRAIL down the east bank through the forest, from Nazaré to the Barra's north gate, with
    the HALFWAY LANDING opposite the middle shallows. Deep forest east of it.
  - EAST, south: THE BARRA DO RIO NEGRO: THE BLUFF (high ground, three ramps: north to the trail, west down to the lower
    town, east to the fields) with the church, the Town Hall, the fort's guns on its west edge; THE LOWER TOWN between
    the bluff and the river (the quarters, the landing); THE FIELDS east of the bluff and THE DOWNRIVER LANDING on the
    brown river (where the canoes come up from Manaus' side: reinforcements).
The mission places the buildings (hall, church, barracks, farms, quarters, palisades) and everyone; this script only
lays the ground and the props, and prints the areas it measured with --areas.
"""
import json
import os
import random
import sys

W, H = 128, 88
BIOME = "jungle"
cells = [["."] * W for _ in range(H)]
props = []
rnd = random.Random(2778)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def rect(x0, y0, x1, y1, ch):
    for y in range(y0, y1):
        for x in range(x0, x1):
            put(x, y, ch)


def get(x, y):
    return cells[y][x] if 0 <= x < W and 0 <= y < H else "k"


# ---------------------------------------------------------------- the Rio Negro and the brown river
def rn_centre(y):
    """The Rio Negro's middle at row y (it bends east toward the meeting)."""
    return 30.0 + y * 0.22


RN_HALF = 6          # half its width
BROWN_Y = 79         # the brown river from this row down


def rn_west(y):
    return int(round(rn_centre(y) - RN_HALF))


def rn_east(y):
    return int(round(rn_centre(y) + RN_HALF))


for y in range(H):
    for x in range(rn_west(y), rn_east(y) + 1):
        put(x, y, "w")
rect(0, BROWN_Y, W, H, "w")
for x in range(W):                      # a ragged shore on the brown river
    if rnd.random() < 0.3:
        put(x, BROWN_Y - 1, "w")

# ---------------------------------------------------------------- THE FAR BANK: várzea (trees in pools, mud paths)
for y in range(0, BROWN_Y):
    for x in range(0, rn_west(y)):
        v = rnd.random()
        if v < 0.18:
            put(x, y, "w")
        elif v < 0.52:
            put(x, y, "t")
        elif v < 0.62:
            put(x, y, "f")
# the swarm's mud paths: the plateau's road down the far bank and spurs to each shallows and Mother site
def path(points, width=4, ch="."):
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(n + 1):
            x = round(x0 + (x1 - x0) * i / n)
            y = round(y0 + (y1 - y0) * i / n)
            for dx in range(-(width // 2), width - width // 2):
                for dy in range(-1, 2):
                    if get(x + dx, y + dy) in ("t", "w", "f", "k") and not (rn_west(y + dy) <= x + dx <= rn_east(y + dy)):
                        put(x + dx, y + dy, ch)


ROAD = [(8, 0), (10, 8), (12, 20), (12, 34), (14, 46), (18, 58), (16, 70), (8, 77)]
path(ROAD, 5)
path([(10, 6), (20, 3), (rn_west(3) - 1, 3)], 4)           # to the rapids
path([(12, 40), (22, 42), (rn_west(42) - 1, 42)], 4)       # to the middle shallows
path([(18, 60), (28, 62), (rn_west(63) - 1, 63)], 5)       # to the Barra shallows
# clearings: the forward Mothers' sites, the staging ground of the great wave, the far point, the flooded forest
CLEAR = {"fb_n": (12, 7, 6, 5), "fb_m": (14, 40, 6, 5), "fb_s": (20, 60, 7, 5), "far_stage": (12, 52, 6, 5),
         "far_point": (32, 57, 3, 3)}
for (cx, cy, rx, ry) in CLEAR.values():
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if (x - cx) ** 2 / (rx + 0.5) ** 2 + (y - cy) ** 2 / (ry + 0.5) ** 2 <= 1.0 and x < rn_west(y):
                put(x, y, ".")
# THE FLOODED FOREST (south-west): deep pools and drowned trees round one wet hollow the wave walks into
for y in range(66, BROWN_Y):
    for x in range(0, 14):
        if get(x, y) == ".":
            put(x, y, "f")
for y in range(70, 77):
    for x in range(2, 9):
        put(x, y, "f")

# ---------------------------------------------------------------- THE SHALLOWS across the Rio Negro (fords)
FORDS = {"rapids": (1, 5), "mid": (40, 44), "south": (61, 66)}
for (y0, y1) in FORDS.values():
    for y in range(y0, y1):
        for x in range(rn_west(y) - 1, rn_east(y) + 2):
            put(x, y, "f")

# ---------------------------------------------------------------- the east bank: forest, the bank trail, Nazaré
for y in range(0, 50):
    for x in range(rn_east(y) + 1, W):
        dens = 0.8 if x > rn_east(y) + 10 else 0.5
        if rnd.random() < dens:
            put(x, y, "t")
# NAZARÉ: a clearing from the bank to the fields
for y in range(3, 24):
    for x in range(rn_east(y) + 1, 68):
        if not (x > 62 and y > 18):
            put(x, y, ".")
rect(58, 3, 70, 11, ".")                 # the manioc fields
# THE BANK TRAIL south to the Barra's north gate (four cells wide) and the halfway landing
for y in range(20, 52):
    x0 = rn_east(y) + 1
    rect(x0, y, x0 + 5, y + 1, ".")
for y in range(38, 47):                   # the halfway landing
    x0 = rn_east(y) + 1
    rect(x0, y, x0 + 9, y + 1, ".")
path([(rn_east(49) + 3, 49), (66, 50), (76, 48)], 5)      # the trail's last stretch to the north ramp
# a few glades in the deep forest (room to step aside), and the east road down to the fields
for cx, cy, r in [(84, 14, 5), (100, 24, 5), (76, 32, 4), (112, 40, 5), (92, 42, 4)]:
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r - 1, cx + r + 2):
            if (x - cx) ** 2 / (r + 1) ** 2 + (y - cy) ** 2 / r ** 2 <= 1.0:
                put(x, y, ".")
path([(66, 12), (84, 14), (100, 24), (106, 40), (104, 52)], 3)

# ---------------------------------------------------------------- THE BARRA: the bluff, the lower town, the fields
for y in range(50, BROWN_Y):
    for x in range(rn_east(y) + 1, W):
        if get(x, y) != "w":
            put(x, y, ".")
BLUFF = (62, 50, 95, 77)                  # x0, y0, x1, y1 (exclusive)
rect(*BLUFF, "h")
rect(74, 49, 79, 50, "r")                 # north ramp: the bank trail
rect(61, 63, 62, 68, "r")                 # west ramp: down to the lower town
rect(95, 60, 96, 65, "r")                 # east ramp: the fields
for x, y in [(62, 50), (63, 50), (94, 50), (62, 76), (94, 76), (93, 76)]:
    put(x, y, "k")
# the fields' edge of forest and a few trees by the brown river
for y in range(52, 77):
    for x in range(116, W):
        if rnd.random() < 0.55:
            put(x, y, "t")

# ---------------------------------------------------------------- props
# Nazaré: the chapel, houses, the bonfire square, the manioc fields, the beach and its canoes
props += [["chapel", 47, 7, False], ["chapel_tower", 51, 6, False], ["cross_wood", 46, 12, False]]
for i, (x, y) in enumerate([(54, 14), (58, 17), (49, 18), (55, 20), (62, 15), (45, 20)]):
    props.append(["cottage", x, y, i % 2 == 1])
props += [["campfire", 52, 11, False], ["drying_rack", 56, 10, False], ["basket_grain", 50, 13, False],
          ["bench", 53, 9, False], ["spit_roast", 58, 12, True]]
for i, (x, y) in enumerate([(60, 5), (64, 5), (60, 8), (64, 8), (67, 6)]):
    props.append(["sheaf" if i % 2 else "grass_tall", x, y, i % 2 == 1])
props += [["boat", 41, 14, False], ["boat", 42, 17, True], ["boat", 41, 20, False], ["anchor", 43, 12, False]]
# the bank trail and the halfway landing
props += [["signpost", 49, 30, False], ["boat", 46, 41, True], ["log_moss", 52, 36, False], ["stump_moss", 51, 46, False]]
# the far bank: snags, nests, the flooded forest's dead trees
props += [["dead_trunk", 6, 72, False], ["dead_tree", 10, 74, True], ["dead_tree", 4, 68, False], ["log_moss", 24, 48, False],
          ["nest", 16, 10, False], ["nest", 18, 36, True], ["reeds", 30, 56, False], ["reeds", 33, 60, True],
          ["boulder_moss", 22, 26, False], ["stump_moss", 4, 30, False]]
# the Barra's lower town: the landing, the warehouse (Lindqvist's old one: crates), the quays
props += [["boat", 52, 76, False], ["boat", 56, 77, True], ["anchor", 58, 76, False], ["crate_long", 54, 74, False],
          ["crates_pair", 58, 72, False], ["barrel_a", 60, 70, False], ["barrel_b", 60, 73, False], ["sacks_pile", 59, 76, False]]
# the bluff: the fort's flag and shot, the square's well
props += [["flag", 65, 53, False], ["cannonballs", 66, 60, False], ["cannonballs", 66, 72, True], ["well", 80, 60, False],
          ["barrel_d", 67, 66, False], ["bench", 74, 61, False]]
# the fields east of the bluff and the downriver landing
for i, (x, y) in enumerate([(100, 56), (104, 60), (108, 56), (100, 66), (106, 68), (110, 62)]):
    props.append(["haybales" if i % 3 == 0 else "sheaf", x, y, i % 2 == 1])
props += [["boat", 108, 78, False], ["boat", 112, 77, True], ["crate_long", 110, 75, False], ["signpost", 98, 72, False]]

# the swarm (the far bank's north), the Barra (the bluff), Nazaré
starts = [[12, 8], [76, 62], [52, 12]]
teams = [0, 1, 1]

data = {
    "name": "barra_rivers", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": BIOME,
    "starts": starts, "teams": teams, "mode": "1v1", "halls": [],
    "props": props, "checked": True,
}

if __name__ == "__main__":
    out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "barra_rivers.json")
    with open(out, "w") as f:
        json.dump(data, f)
    print("wrote", os.path.normpath(out), len(props), "props")
    if "--areas" in sys.argv:
        for k, (y0, y1) in FORDS.items():
            print("ford", k, "rows", y0, y1, "x", rn_west(y0) - 1, rn_east(y1) + 1)
        for y in (3, 14, 42, 58, 63, 70):
            print("row", y, "river", rn_west(y), rn_east(y))
    if "--ascii" in sys.argv:
        for r in cells:
            print("".join(r))
