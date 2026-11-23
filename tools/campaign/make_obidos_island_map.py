#!/usr/bin/env python3
"""Writes campaign/maps/obidos_island.json, the map of Act 2's "The Island" (d03_fazenda; the plan:
docs/campaign_act2_plan.md "d03_fazenda"; what was built: docs/campaign_d03_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford, t tree, k rock; props [name, x, y,
flip]). Rebuild:
  python3 tools/campaign/make_obidos_island_map.py

Lindqvist's fazenda on a river island below Óbidos (proposed), the dry season 2772, 120 x 84 cells, the jungle biome:
  - THE RIVER all round, low: brown water at the edges, SANDBANKS (ford art, out in the stream) showing.
  - SOUTH: THE LANDING, a sand beach where the commission's canoes come in (the exit at dawn).
  - SOUTH-CENTRE: THE BIG HOUSE on a low rise, the SUGAR FIELDS round it (open ground: nothing hides there), the sugar
    mill and THE OLD PENS (sheds by the mill, where the stock starts: too near the house to hide).
  - THE CREEK cuts the island in two from the west bank to the east, with THREE FORDS (west, middle, east).
  - NORTH of the creek: THE DEEP FOREST with its clearings (the deep pens 1-5), cut by narrow paths.
  - SOUTH-WEST and SOUTH-EAST: lighter forest with two more clearings (the near pens 6-7) and, east, THE BURNT CHAPEL
    of the old Jesuit mission the fazenda took over (proposed).
  - THE WEST POINT and THE CHAPEL: the two decoy spots (a keeper sets a lure post there).
"""
import json
import os
import random

W, H = 120, 84
cells = [["."] * W for _ in range(H)]
props = []
rnd = random.Random(2772)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def get(x, y):
    return cells[y][x] if 0 <= x < W and 0 <= y < H else "w"


def rect(x0, y0, x1, y1, ch):
    for y in range(y0, y1):
        for x in range(x0, x1):
            put(x, y, ch)


def ellipse(cx, cy, rx, ry, ch, only=None):
    for y in range(cy - ry - 1, cy + ry + 2):
        for x in range(cx - rx - 1, cx + rx + 2):
            if (x - cx) ** 2 / max(rx, 0.5) ** 2 + (y - cy) ** 2 / max(ry, 0.5) ** 2 <= 1.0:
                if only is None or get(x, y) in only:
                    put(x, y, ch)


# ---------------------------------------------------------------- the island's shape (an egg in the river)
CX, CY = 60, 40
for y in range(H):
    for x in range(W):
        dx = (x - CX) / 55.0
        dy = (y - CY) / 36.0
        wob = 0.05 * ((x * 7 + y * 3) % 5) / 5.0
        if dx * dx + dy * dy > 1.0 - wob:
            put(x, y, "w")
# sandbanks out in the low river (dry season): ford art nobody can reach from the island (a ring of water between)
for (x0, y0, x1, y1) in [(2, 30, 5, 42), (113, 22, 117, 30), (30, 79, 44, 82), (80, 2, 94, 4), (114, 50, 118, 58)]:
    rect(x0, y0, x1, y1, "f")

# ---------------------------------------------------------------- the forest: dense in the north, lighter in the south
for y in range(H):
    for x in range(W):
        if get(x, y) != ".":
            continue
        if y < 38:
            dens = 0.80
        elif y < 46:
            dens = 0.55
        else:
            dens = 0.42 if (x < 34 or x > 86) else 0.0
        if rnd.random() < dens:
            put(x, y, "t")

# ---------------------------------------------------------------- the creek (igarapé) from the west bank to the east
CREEK = {}
for x in range(0, W):
    y = 41 + round(2.2 * __import__("math").sin(x / 9.0))
    CREEK[x] = y
    for yy in (y, y + 1):
        if get(x, yy) != "w" or (6 < x < 114):
            put(x, yy, "w")
FORDS = {"ford_w": 24, "ford_m": 60, "ford_e": 94}
for nm, fx in FORDS.items():
    y = CREEK[fx]
    rect(fx - 2, y, fx + 3, y + 2, "f")
    rect(fx - 2, y - 3, fx + 3, y, ".")       # the banks kept clear
    rect(fx - 2, y + 2, fx + 3, y + 5, ".")

# ---------------------------------------------------------------- the clearings: the deep pens (north) and the near pens
PENS = {
    "pen_1": (24, 14, 7, 5), "pen_2": (50, 10, 7, 4), "pen_3": (80, 12, 7, 5), "pen_4": (98, 26, 6, 5), "pen_5": (36, 30, 7, 5),
    "pen_6": (66, 28, 8, 6),           # (the nest clearing: the young Mother roots here)
    "pen_7": (16, 54, 5, 4), "pen_8": (100, 50, 5, 4),
}
for nm, (cx, cy, rx, ry) in PENS.items():
    ellipse(cx, cy, rx, ry, ".", only=("t",))


def path(points, width=3):
    """A narrow path through the trees along a polyline of cells."""
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(n + 1):
            x = round(x0 + (x1 - x0) * i / n)
            y = round(y0 + (y1 - y0) * i / n)
            for dx in range(-(width // 2), width - width // 2):
                for dy in range(-(width // 2), width - width // 2):
                    if get(x + dx, y + dy) == "t":
                        put(x + dx, y + dy, ".")


# the forest paths: from each ford up into the clearings, and between them
path([(24, CREEK[24] - 3), (30, 32), (36, 30)])
path([(24, CREEK[24] - 3), (22, 24), (24, 14)])
path([(60, CREEK[60] - 3), (62, 34), (66, 28)])
path([(66, 28), (58, 18), (50, 10)])
path([(66, 28), (74, 20), (80, 12)])
path([(94, CREEK[94] - 3), (96, 32), (98, 26)])
path([(98, 26), (88, 18), (80, 12)])
path([(36, 30), (48, 30), (60, 30), (66, 28)])
path([(24, 14), (38, 12), (50, 10)])
# the south: the near pens' clearings and their paths
path([(16, 54), (24, 50), (24, CREEK[24] + 3)])
path([(100, 50), (96, 48), (94, CREEK[94] + 3)])
path([(16, 54), (30, 58), (40, 58)])
path([(100, 50), (90, 56), (78, 58)])

# ---------------------------------------------------------------- the south: the house's rise, the fields, the landing
rect(52, 52, 68, 60, "h")                   # the big house's low rise
rect(58, 60, 62, 61, "r")                   # down to the landing road
rect(51, 55, 52, 58, "r")                   # west to the mill
rect(68, 55, 69, 58, "r")                   # east to the fields
for x, y in [(52, 52), (67, 52), (52, 59), (67, 59)]:
    put(x, y, "k")
# the landing beach (sand: plain low ground) down to the water
for y in range(66, 76):
    for x in range(50, 70):
        if get(x, y) == "w" and y < 72:
            put(x, y, ".")
rect(53, 71, 67, 73, ".")

# ---------------------------------------------------------------- props
# the big house, the mill and the old pens, the fields
props += [["shed", 44, 55, False], ["shed", 41, 58, True], ["fence", 40, 53, False], ["fence_b", 44, 53, False], ["fence", 38, 56, False],
          ["trough", 43, 57, False], ["haystack", 46, 60, False], ["windmill", 47, 51, False], ["sacks_pile", 49, 58, False],
          ["wheelbarrow", 48, 61, False], ["well", 64, 61, False], ["bench", 57, 61, False], ["table_long", 62, 62, False]]
for i, (x, y) in enumerate([(38, 62), (42, 64), (46, 66), (72, 62), (76, 60), (80, 64), (74, 66), (36, 66), (84, 60)]):
    props.append(["sheaf" if i % 3 else "haybales", x, y, i % 2 == 1])
for x in range(36, 50, 3):
    props.append(["grass_tall", x, 63 + (x % 2), False])
for x in range(72, 88, 3):
    props.append(["grass_tall", x, 57 + (x % 2), True])
# the landing: canoes, crates, the commission's camp ground
props += [["boat", 54, 73, False], ["boat", 58, 74, True], ["boat", 63, 73, False], ["anchor", 66, 72, False],
          ["crate_long", 52, 70, False], ["crates_pair", 67, 70, False], ["barrel_a", 69, 69, False], ["reeds", 50, 71, False],
          ["reeds", 70, 71, True]]
# the burnt chapel (east)
props += [["ruin_wall", 104, 46, False], ["ruin_pillar", 108, 48, False], ["ruin_tower", 106, 51, False],
          ["cross_stone", 102, 52, False], ["dead_tree", 110, 46, False]]
# the west point (the second decoy spot)
props += [["reeds", 9, 50, False], ["log_moss", 11, 47, False], ["stump_moss", 13, 52, False]]
# the pens: rough fences, troughs and straw in the clearings (the keepers' work)
for nm, (cx, cy, rx, ry) in PENS.items():
    # (on the clearing's rim, never in its middle: the young Mother needs room to root)
    props += [["fence_b", cx - rx, cy - ry + 1, False], ["trough", cx + rx - 1, cy + ry - 1, False]]
    if nm in ("pen_1", "pen_3", "pen_6"):
        props.append(["nest", cx - rx + 1, cy + ry - 1, False])
    if nm in ("pen_2", "pen_5"):
        props.append(["haystack_b", cx + rx - 1, cy - ry + 1, False])
# the forest's own
props += [["dead_trunk", 30, 20, False], ["log_moss", 44, 22, False], ["boulder_moss", 72, 36, False], ["stump_moss", 86, 30, False],
          ["rocks_moss", 56, 24, False], ["dead_trunk", 90, 20, True], ["log_moss", 14, 30, False], ["boulder_moss", 106, 34, False]]

# the stock (the old pens), the fazenda (the house), the commission (the landing)
starts = [[44, 56], [60, 56], [60, 70]]
teams = [0, 0, 1]

data = {
    "name": "obidos_island", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "jungle",
    "starts": starts, "teams": teams, "mode": "1v1", "halls": [],
    "props": props, "checked": True,
}
# (the areas the mission uses: printed for tools/campaign/make_d03_mission.py)
if __name__ == "__main__":
    out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "obidos_island.json")
    with open(out, "w") as f:
        json.dump(data, f)
    print("wrote", os.path.normpath(out), len(props), "props", "creek fords", {k: (v, CREEK[v]) for k, v in FORDS.items()})
    if "--ascii" in __import__("sys").argv:
        for r in cells:
            print("".join(r))
