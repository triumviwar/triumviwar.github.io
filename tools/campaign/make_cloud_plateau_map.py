#!/usr/bin/env python3
"""Writes campaign/maps/cloud_plateau.json, the map of Act 1's "The Lost Plateau" (a03_plateau; the plan:
docs/campaign_act1_plan.md "a03_plateau"; what was built: docs/campaign_a03_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford, t tree, k rock, K high rock; props
[name, x, y, flip]). Rebuild:
  python3 tools/campaign/make_cloud_plateau_map.py

The cloud mountain north of the Rio Negro (a tepui), September 2767, 128 x 112 cells, the jungle biome:
  - SOUTH: a tributary of the Rio Negro across the bottom (impassable) and BENEDITO'S LANDING, a sand beach where his
    canoe waits (the party's way home: Part 3's exit). The FOREST AT THE FOOT above it: deep trees, trails cleared from
    the landing to the two ways up.
  - THE CLIFF: the plateau is the high ground, its edge a cliff all round, climbed by TWO WAYS: THE WATERFALL STAIR in
    the south-west (a ramp beside the falls of the river's source) and THE SPLIT IN THE ROCK in the south-east (a ramp
    at the end of a narrow cleft between two sandstone walls).
  - THE TOP (in the mission's mist): sandstone towers (high rock), black pools, low scrub; the RIVER'S SOURCE, a black
    pool in the north-west whose stream runs south and falls over the cliff beside the stair.
  - THE NEST: a HOLLOW in the north-middle of the plateau (low ground inside the high), two ramps down into it from the
    south (west and east); the mission roots the Brood's Mother there (her swamp spreads over the hollow's floor).
  - FOUR SURVEY MARKS (the mission's areas): the CAIRN above the stair, the RIVER'S SOURCE, the NEST'S RIM (the high
    ground south of the hollow, looking down into it) and the LOOKOUT on the east edge.
"""
import json
import math
import os
import random

W, H = 128, 112
cells = [["."] * W for _ in range(H)]
props = []
rnd = random.Random(2767 * 9)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def get(x, y):
    return cells[y][x] if 0 <= x < W and 0 <= y < H else "#"


def rect(x0, y0, x1, y1, ch):
    for y in range(y0, y1):
        for x in range(x0, x1):
            put(x, y, ch)


def blob(cx, cy, r, ch, only=None):
    for y in range(int(cy - r) - 1, int(cy + r) + 2):
        for x in range(int(cx - r) - 1, int(cx + r) + 2):
            if (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 <= r * r and (only is None or get(x, y) in only):
                put(x, y, ch)


def line(points, width, ch, only=None):
    r = width / 2.0
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for i in range(n + 1):
            blob(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n, r, ch, only)


# ---------------------------------------------------------------- the plateau (high ground), its edge noisy
PLATEAU_TOP, PLATEAU_BOTTOM = 6, 66
STAIR_X = (24, 29)          # the waterfall stair's ramp (5 wide), at the plateau's south edge
SPLIT_X = (96, 101)         # the split in the rock's ramp (5 wide)


def bottom_edge(x):
    if STAIR_X[0] - 3 <= x < STAIR_X[1] + 3 or SPLIT_X[0] - 4 <= x < SPLIT_X[1] + 4:
        return PLATEAU_BOTTOM
    return PLATEAU_BOTTOM - 2 + int(3 * math.sin(x * 0.21) + 2 * math.sin(x * 0.07 + 1.3))


def left_edge(y):
    return 9 + int(2 * math.sin(y * 0.19) + 1.5 * math.sin(y * 0.05))


def right_edge(y):
    return W - 10 - int(2 * math.sin(y * 0.17 + 0.6) + 1.5 * math.sin(y * 0.06))


for y in range(H):
    for x in range(W):
        if PLATEAU_TOP + int(1.5 * math.sin(x * 0.13)) <= y < bottom_edge(x) and left_edge(y) <= x < right_edge(y):
            put(x, y, "h")

# ---------------------------------------------------------------- THE NEST'S HOLLOW (low ground inside the plateau)
HOLLOW = (40, 12, 88, 36)       # x0, y0, x1, y1 (exclusive): the floor; the corners rounded
for y in range(HOLLOW[1], HOLLOW[3]):
    for x in range(HOLLOW[0], HOLLOW[2]):
        dx = min(x - HOLLOW[0], HOLLOW[2] - 1 - x)
        dy = min(y - HOLLOW[1], HOLLOW[3] - 1 - y)
        if dx + dy >= 3:
            put(x, y, ".")
# its two ramps up to the plateau, on the south side (the low cells just inside its south edge)
HOLLOW_RAMPS = {"hollow_w": (46, 51), "hollow_e": (77, 82)}
for x0, x1 in HOLLOW_RAMPS.values():
    rect(x0, HOLLOW[3] - 1, x1, HOLLOW[3], "r")
    # (the cells beside the ramp's ends kept low, so the ramp is a clean step)

# ---------------------------------------------------------------- the two ways up
rect(STAIR_X[0], PLATEAU_BOTTOM, STAIR_X[1], PLATEAU_BOTTOM + 1, "r")    # the waterfall stair
rect(SPLIT_X[0], PLATEAU_BOTTOM, SPLIT_X[1], PLATEAU_BOTTOM + 1, "r")    # the split in the rock
# the split: two sandstone walls (high rock) either side of a narrow cleft on the top, 10 cells long
for y in range(PLATEAU_BOTTOM - 11, PLATEAU_BOTTOM):
    for x in range(SPLIT_X[0] - 3, SPLIT_X[0]):
        put(x, y, "K")
    for x in range(SPLIT_X[1], SPLIT_X[1] + 3):
        put(x, y, "K")

# ---------------------------------------------------------------- the river's source and its falls
SOURCE = (22, 20)
blob(SOURCE[0], SOURCE[1], 3.2, "w", "h")
# its stream runs south over the top and falls over the cliff west of the stair, then to a pool in the forest
line([(22, 22), (21, 34), (19, 46), (20, 58), (20, 66)], 2.2, "w")
line([(20, 66), (19, 72), (16, 76)], 2.4, "w")
blob(14, 78, 3.4, "w")
# a ford where the stream crosses the high ground near the cairn (the stair's way west is not needed: none)

# ---------------------------------------------------------------- black pools on the top
for cx, cy, r in [(38, 50, 2.6), (70, 52, 2.2), (108, 22, 2.4), (30, 32, 1.8), (62, 44, 1.6)]:
    blob(cx, cy, r, "w", "h")

# ---------------------------------------------------------------- sandstone towers on the top (kept off the paths)
KEEP_OFF = [(26, 58, 6), (28, 50, 4), (SOURCE[0], SOURCE[1], 6), (64, 41, 6), (112, 34, 5), (98, 52, 6),
            (48, 38, 4), (80, 38, 4), (64, 58, 12), (40, 58, 8), (88, 58, 8), (50, 46, 8), (78, 46, 8)]
TOWERS = [(16, 30, 1.6), (34, 24, 2.0), (30, 42, 1.4), (14, 50, 1.8), (36, 60, 1.5), (52, 56, 1.4),
          (92, 18, 2.0), (104, 40, 1.6), (114, 52, 1.8), (90, 44, 1.5), (110, 12, 1.5), (26, 12, 1.6),
          (100, 28, 1.3), (74, 60, 1.3), (60, 62, 1.2)]
for cx, cy, r in TOWERS:
    if all((cx - kx) ** 2 + (cy - ky) ** 2 > kr * kr for kx, ky, kr in KEEP_OFF):
        blob(cx, cy, r, "K", "h")

# ---------------------------------------------------------------- the river and the landing (south)
for x in range(W):
    for y in range(H - 6 + int(1.2 * math.sin(x * 0.11)), H):
        put(x, y, "w")
LANDING = (58, 70)              # the beach's x range
for x in range(LANDING[0], LANDING[1]):
    for y in range(H - 8, H - 4):
        put(x, y, ".")

# ---------------------------------------------------------------- the forest at the foot (and round the edges)
TRAILS = [
    [(64, H - 9), (60, 96), (48, 88), (36, 80), (27, PLATEAU_BOTTOM + 2)],        # the landing to the stair
    [(64, H - 9), (72, 96), (86, 86), (95, 76), (98, PLATEAU_BOTTOM + 2)],        # the landing to the split
    [(36, 80), (52, 82), (70, 84), (86, 86)],                                     # along the foot
]
trail_cells = set()
for tr in TRAILS:
    r = 1.6
    for (x0, y0), (x1, y1) in zip(tr, tr[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for i in range(n + 1):
            cx, cy = x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n
            for yy in range(int(cy - r) - 1, int(cy + r) + 2):
                for xx in range(int(cx - r) - 1, int(cx + r) + 2):
                    if (xx + 0.5 - cx) ** 2 + (yy + 0.5 - cy) ** 2 <= r * r:
                        trail_cells.add((xx, yy))
CAMP = (56, 88, 16, 10)          # the party's camp at the foot, by the landing (kept clear)
for y in range(H):
    for x in range(W):
        if cells[y][x] != ".":
            continue
        if (x, y) in trail_cells or (CAMP[0] <= x < CAMP[0] + CAMP[2] and CAMP[1] <= y < CAMP[1] + CAMP[3]):
            continue
        if y >= PLATEAU_BOTTOM + 1 or x < 6 or x >= W - 6 or y < 4:
            # the forest: dense, with small clearings; by the cliff foot a little thinner
            near_cliff = y < PLATEAU_BOTTOM + 4
            p = 0.38 if near_cliff else 0.62
            if rnd.random() < p:
                put(x, y, "t")
# the plateau's foot: a band of fallen rock along the cliff (not in front of the ramps)
for x in range(W):
    y = bottom_edge(x)
    if get(x, y - 1) == "h" and get(x, y) in (".", "t") and not (STAIR_X[0] - 1 <= x < STAIR_X[1] + 1 or SPLIT_X[0] - 1 <= x < SPLIT_X[1] + 1):
        if rnd.random() < 0.45:
            put(x, y, "k")

# low scrub on the top (sparse trees on the high ground: "T"), off the paths and the marks
for y in range(PLATEAU_TOP, PLATEAU_BOTTOM):
    for x in range(W):
        if cells[y][x] == "h" and rnd.random() < 0.05 and all((x - kx) ** 2 + (y - ky) ** 2 > kr * kr for kx, ky, kr in KEEP_OFF):
            put(x, y, "T")

# ---------------------------------------------------------------- props
props += [["boat", 63, H - 4, False], ["boat", 67, H - 4, True], ["campfire", 62, 92, False], ["tent_white", 58, 90, False],
          ["crates_pair", 66, 90, False], ["barrel_b", 68, 92, False], ["sacks_pile", 60, 94, False], ["anchor", 70, 95, False]]
props += [["cross_stone", 28, 50, False], ["stones", 30, 51, False]]                       # the cairn
props += [["reeds", 19, 17, False], ["reeds", 25, 23, True], ["rocks_moss", 18, 23, False]]  # the source
props += [["watch_frame", 113, 31, False], ["stone_block", 111, 33, False]]                  # the lookout
props += [["boulder_moss", 60, 39, False], ["stones", 68, 40, False]]                        # the rim
for x, y in [(44, 16), (82, 15), (46, 30), (84, 30), (64, 13)]:
    props.append(["nest", x, y, False])
for x, y, k in [(34, 46, "ruin_pillar"), (46, 54, "column"), (84, 50, "ruin_pillar"), (104, 46, "stone_block"),
                (20, 40, "boulder_moss"), (58, 60, "rocks_moss"), (76, 56, "boulder_moss"), (110, 18, "dead_tree"),
                (32, 16, "dead_tree"), (94, 24, "stones")]:
    props.append([k, x, y, False])
for x, y in [(40, 76), (80, 78), (20, 86), (104, 88), (50, 72), (90, 70)]:
    props.append(["log_moss", x, y, False])
props = [p for p in props if get(p[1], p[2]) in (".", "h")]

# the starts the mission places its teams on (one per team: party, cache, nest, kin, patrol, rival)
starts = [[60, 90], [62, 92], [62, 20], [70, 24], [40, 48], [90, 82]]
data = {
    "name": "cloud_plateau", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "jungle",
    "starts": starts, "teams": list(range(len(starts))), "mode": "1v1", "halls": [],
    "props": props, "checked": True,
}
out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "cloud_plateau.json")
with open(out, "w") as f:
    json.dump(data, f)
print("wrote", os.path.normpath(out), len(props), "props")
if __name__ == "__main__" and os.environ.get("SHOW"):
    for row in cells:
        print("".join(row))
