#!/usr/bin/env python3
"""Writes campaign/maps/furth_works.json, the map of Act 1's "Father Ferrer's Visit" (a04_visit; the plan:
docs/campaign_act1_plan.md "a04_visit"; what was built: docs/campaign_a04_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd). It is a02's map (campaign/maps/furth_line.json, tools/campaign/make_furth_map.py) eighteen months
on, so it STARTS FROM THAT FILE (run make_furth_map.py first if a02's map changes):
  python3 tools/campaign/make_furth_works_map.py

Fürth, autumn 2769 (the autumn biome):
  - THE WORKS: the guild's yard has grown into a small town of gears round the Honest One: six workshops (the mission
    places them as buildings), store sheds, crates, carts and forges; the barn is still Hollweg's (west).
  - THE TOWN: more houses, north and on the south bank where the refugees' tents stood (housed now).
  - THE RIVERBANK below the chapel (north bank of the Pegnitz, inside the line): reeds, a boat, crates: where the
    night shift goes (the gear ground nobody laid is the mission's).
  - THE LINE: the same place, dug longer and deeper (the mission's palisades); on the meadow bank its gap stands open
    for the carts.
  - THE MEADOWS: the Rednitz mill burnt (a ruin), the machine's gear ground crept west (the mission's seed and links).
  - NUREMBERG (east edge), unchanged.
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
SRC = os.path.join(ROOT, "campaign", "maps", "furth_line.json")

m = json.load(open(SRC))
W, H = m["size"]
cells = [list(m["cells"][y * W:(y + 1) * W]) for y in range(H)]

# the places the mission builds on (the six workshops, the bank, the gap): no props there
CLEAR = [
    (31, 10, 26, 18),       # the works round the Honest One
    (40, 22, 18, 8),        # the yard's south side, the Heavy Works and the lodge
    (47, 29, 11, 7),        # the riverbank below the chapel
    (43, 40, 14, 9),        # the south bank's old tent ground (cottages now) and the gap's approach
    (64, 38, 26, 16),       # the machine's meadow ground
]


def in_clear(x, y):
    return any(x0 <= x < x0 + w and y0 <= y < y0 + h for (x0, y0, w, h) in CLEAR)


props = [p for p in m["props"] if not in_clear(p[1], p[2]) and p[0] not in ("windmill",)]


def free(x, y, n=2):
    return all(0 <= xx < W and 0 <= yy < H and cells[yy][xx] == "." for yy in range(y, y + n) for xx in range(x, x + n))


def add(name, x, y, flip=False):
    if free(x, y, 1):
        props.append([name, x, y, flip])


# ---------------------------------------------------------------- the works (the yard's edges; its middle is the mission's)
for (n, x, y) in [("forge", 31, 25), ("crate_long", 31, 11), ("crates_pair", 56, 11), ("barrel_b", 56, 26), ("wagon", 31, 27),
                  ("cart_b", 41, 28), ("crate_c", 39, 28), ("sacks_pile", 56, 16), ("barrel_tall", 31, 16), ("wheelbarrow", 40, 10),
                  ("stone_block", 50, 10), ("crate_open", 46, 10), ("table_long", 33, 10), ("tub", 56, 22)]:
    add(n, x, y)
# the town grown north and west (houses on the free ground between the old ones)
for (x, y) in [(34, 5), (39, 5), (44, 5), (49, 2), (36, 1), (55, 2)]:
    if free(x, y):
        props.append(["cottage", x, y, (x % 2) == 1])
# ---------------------------------------------------------------- the riverbank below the chapel: reeds, a boat, crates
for (n, x, y) in [("reeds", 47, 35), ("reeds", 56, 34), ("boat", 50, 35), ("crate_small", 48, 31), ("barrel_open", 57, 31),
                  ("log", 54, 30)]:
    add(n, x, y)
# ---------------------------------------------------------------- the south bank: the refugees housed, the gap's carts
for (x, y) in [(44, 42), (47, 41), (44, 46), (50, 44)]:
    if free(x, y):
        props.append(["cottage", x, y, (x % 3) == 0])
for (n, x, y) in [("cart_c", 55, 51), ("haybales", 53, 52), ("signpost", 56, 44)]:
    add(n, x, y)
# ---------------------------------------------------------------- the meadows: the burnt mill, the machine's ground
for (n, x, y) in [("ruin_wall", 72, 58), ("ruin_pillar", 74, 59), ("dead_tree", 70, 60), ("dead_trunk", 68, 55),
                  ("stone_block", 90, 40), ("rocks_moss", 66, 52), ("dead_tree", 88, 52)]:
    add(n, x, y)

data = dict(m)
data.update({"name": "furth_works", "cells": "".join("".join(r) for r in cells), "biome": "autumn", "props": props})
out = os.path.join(ROOT, "campaign", "maps", "furth_works.json")
with open(out, "w") as f:
    json.dump(data, f)
print("wrote", os.path.normpath(out), len(props), "props")
