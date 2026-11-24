#!/usr/bin/env python3
"""Writes campaign/maps/obidos_front.json, the map of Act 2's "The Jungle Front" (d10_jungle; the plan:
docs/campaign_act2_plan.md "d10_jungle"; what was built: docs/campaign_d10_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford = shallow water you wade, t tree,
k rock; props [name, x, y, flip]). Rebuild:
  python3 tools/campaign/make_obidos_front_map.py [--ascii]

The lower Amazon at Óbidos, 2780, 144 x 96 cells (north up), the VÁRZEA biome (the flooded forest's painted ground, as
d05; the mission's `wade` rule: men wade the shallow flood at half pace, the creatures go through it at their own):
  - THE MAIN CHANNEL of the Amazon across the south (deep water), with THE ISLAND in its middle (d03's island: the
    fazenda's RUINS at its heart, the swarm's oldest ground). Two SHALLOWS cross the north arm to the island (the west
    ford and the east ford). Below the channel, the south bank: a strip of drowned forest (scenery).
  - ÓBIDOS (east): the town and its fort on a BLUFF over THE NARROWS (the channel at its tightest under the guns).
    A west ramp to the levee, a south ramp down to THE LANDING where the column came ashore.
  - THE LEVEE: a dry trail along the north bank from Óbidos to the map's west edge (the men's road); the UPRIVER
    BATTERY on a little rise west of Óbidos (the outwork of a RECLAIM PART when the Barra was lost in d08).
  - THE VÁRZEA north of the levee: flooded forest with two CREEKS running north (the creeks to the Barra's river), dry
    trails up their banks, and five clearings where the swarm's forward Mothers root (the creek mouth, the north bank
    by Óbidos, the north creek, the west creek, the upriver bank).
The mission places the buildings and everyone; this script lays the ground and the props.
"""
import json
import os
import random
import sys

W, H = 144, 96
cells = [["f"] * W for _ in range(H)]
props = []
rnd = random.Random(2780)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def rect(x0, y0, x1, y1, ch):
    for y in range(y0, y1):
        for x in range(x0, x1):
            put(x, y, ch)


def get(x, y):
    return cells[y][x] if 0 <= x < W and 0 <= y < H else "w"


def blob(cx, cy, rx, ry, ch):
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if (x - cx) ** 2 / (rx + 0.5) ** 2 + (y - cy) ** 2 / (ry + 0.5) ** 2 <= 1.0:
                put(x, y, ch)


# ---------------------------------------------------------------- THE VÁRZEA everywhere north of the river
for y in range(0, 58):
    for x in range(W):
        v = rnd.random()
        put(x, y, "t" if v < 0.34 else ("w" if v < 0.42 else ("." if v < 0.52 else "f")))

# ---------------------------------------------------------------- THE MAIN CHANNEL, the island, the south bank
def ch_top(x):
    return 58 if x < 106 else 59                          # the north shore (under the landing at Óbidos)


def ch_bot(x):
    return 85 if x < 104 else max(71, 85 - (x - 104) // 2)   # the south shore (the narrows: the channel tightens east)


for x in range(W):
    for y in range(ch_top(x), max(ch_top(x) + 8, ch_bot(x))):
        put(x, y, "w")
    for y in range(max(ch_top(x) + 8, ch_bot(x)), H):
        put(x, y, "t" if rnd.random() < 0.4 else "f")
# THE ISLAND (d03's): a long low island in the channel's middle
for y in range(62, 80):
    for x in range(42, 96):
        if ((x - 69) / 27.5) ** 2 + ((y - 70.5) / 9.0) ** 2 <= 1.0:
            v = rnd.random()
            put(x, y, "t" if v < 0.22 else ("f" if v < 0.42 else "."))
blob(68, 70, 9, 5, ".")                  # the fazenda's ruins, the swarm's oldest ground
blob(50, 70, 4, 3, ".")                  # the west landing
blob(87, 70, 4, 3, ".")                  # the east landing
rect(50, 66, 88, 68, ".")                # the old cart track along the island
# THE SHALLOWS: the north arm crossed at two places (wade)
for (x0, x1) in ((50, 56), (82, 88)):
    rect(x0, 56, x1, 66, "f")

# ---------------------------------------------------------------- THE LEVEE: the dry trail along the north bank
for x in range(0, 112):
    y0 = 50 + (1 if (x // 9) % 2 else 0)
    rect(x, y0, x + 1, y0 + 4, ".")
for x in range(0, 112):
    if get(x, 57) in ("t", "."):
        put(x, 57, "f")
# THE CREEKS north (deep water, three wide) with a ford where the levee crosses them
CREEKS = {"east": 66, "west": 30}
for name, cx in CREEKS.items():
    for y in range(0, 58):
        x = cx + int(round(2.5 * ((y % 22) / 11.0 - 1.0)))
        for dx in range(0, 3):
            put(x + dx, y, "w" if not (49 <= y <= 54) else "f")
# the dry trails up the creeks' east banks to the north
for name, cx in CREEKS.items():
    for y in range(4, 50):
        x = cx + int(round(2.5 * ((y % 22) / 11.0 - 1.0))) + 4
        rect(x, y, x + 3, y + 1, ".")
# THE CLEARINGS where the forward Mothers root (dry mud islands in the flood)
SITES = {"m1": (80, 40), "m2": (58, 40), "m3": (57, 10), "m4": (20, 28), "m5": (9, 44)}
for (cx, cy) in SITES.values():
    blob(cx, cy, 6, 5, ".")
    rect(cx - 5, cy - 6, cx + 6, cy + 2, ".")    # (room for a grown Mother to root: her foot is ten cells by five)
# little paths from the levee into each clearing
for (cx, cy) in SITES.values():
    if cy > 30:
        for y in range(cy, 51):
            rect(cx - 1, y, cx + 2, y + 1, ".")
path_ns = [(20, 28, 34), (57, 10, 70)]           # m4 and m3 to their creek trails (west to east)
for (cx, cy, tx) in path_ns:
    for x in range(min(cx, tx), max(cx, tx) + 1):
        rect(x, cy - 1, x + 1, cy + 2, ".")
# the swarm's staging grounds out west (the last wave comes down the levee from there)
blob(12, 52, 7, 3, ".")

# ---------------------------------------------------------------- ÓBIDOS: the bluff, the fort, the landing
BLUFF = (110, 26, 141, 56)
rect(*BLUFF, "h")
for (x, y) in [(110, 26), (140, 26), (110, 55), (140, 55), (139, 55)]:
    put(x, y, "k")
rect(108, 50, 110, 54, "r")              # the west ramp (to the levee)
rect(122, 56, 128, 57, "r")              # the south ramp (down to the landing)
rect(112, 57, 140, 59, ".")             # THE LANDING under the bluff
for x in range(112, 140):
    put(x, 59, "w")
rect(100, 49, 110, 56, ".")             # the killing ground before the west gate
rect(100, 40, 110, 49, ".")
# THE UPRIVER BATTERY: a little rise west of Óbidos on the north bank
rect(92, 43, 99, 48, "h")
rect(95, 48, 97, 49, "r")
# a road north out of Óbidos into the forest (the hunters' track)
rect(118, 0, 121, 26, ".")

# ---------------------------------------------------------------- props
for (cx, cy) in SITES.values():
    props.append(["nest", cx + 3, cy - 3, rnd.random() < 0.5])
    props.append(["varzea_snag", cx - 5, cy + 3, rnd.random() < 0.5])
# the island: the fazenda's ruins (d03), the old pens, burnt sheds
props += [["ruin_wall", 64, 67, False], ["ruin_pillar", 70, 66, False], ["ruin_tower", 73, 69, True], ["ruin_wall", 66, 72, True],
          ["fence_b", 60, 69, False], ["fence_b", 60, 71, False], ["trough", 61, 73, False], ["dead_trunk", 75, 72, False],
          ["cross_stone", 56, 68, False], ["windmill", 78, 66, True], ["shed", 58, 74, False]]
# Óbidos: the landing's boats, the fort's flag and shot
props += [["boat", 114, 58, False], ["boat", 118, 58, True], ["boat", 130, 58, False], ["boat", 136, 58, True], ["anchor", 125, 58, False],
          ["crate_long", 120, 57, False], ["sacks_pile", 133, 57, False], ["flag", 128, 50, False], ["cannonballs", 121, 52, False],
          ["cannonballs", 135, 52, True], ["well", 124, 36, False], ["bench", 118, 40, False], ["barrel_d", 131, 46, False]]
props += [["cannonballs", 94, 44, False], ["flag", 96, 44, True], ["signpost", 104, 52, False]]
# the flood and its trees, mist over the water
for _ in range(70):
    x, y = rnd.randrange(W), rnd.randrange(0, 58)
    if get(x, y) == "f":
        props.append([rnd.choice(["varzea_snag", "floating_grass", "aninga", "buriti", "varzea_tree"]), x, y, rnd.random() < 0.5])
for _ in range(14):
    x, y = rnd.randrange(W), rnd.randrange(60, 85)
    if get(x, y) == "w":
        props.append(["mist_wisp", x, y, rnd.random() < 0.5])

# the column (Óbidos), the swarm (the creek mouth)
starts = [[124, 44], [58, 40]]
teams = [0, 1]

data = {
    "name": "obidos_front", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "varzea", "ford": "swamp",
    "starts": starts, "teams": teams, "mode": "1v1", "halls": [],
    "props": props, "checked": True,
}

if __name__ == "__main__":
    out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "obidos_front.json")
    with open(out, "w") as f:
        json.dump(data, f)
    print("wrote", os.path.normpath(out), len(props), "props")
    if "--ascii" in sys.argv:
        for r in cells:
            print("".join(r))
