#!/usr/bin/env python3
"""Writes campaign/maps/plateau_descent.json, the map of Act 1's "The Specimens" (a05_specimens; the plan:
docs/campaign_act1_plan.md "a05_specimens"; what was built: docs/campaign_a05_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, t tree, k rock, K high rock, T scrub on the
high ground; props [name, x, y, flip]). Rebuild:
  python3 tools/campaign/make_plateau_descent_map.py

The cloud mountain again, two years after Valadares (the dry season 2769), seen from its south side down to the river,
128 x 150 cells, the jungle biome:
  - NORTH, THE TOP: the plateau (high ground) and, in its north-middle, THE NEST'S HOLLOW (low ground inside the high,
    two ramps down into it from the south). The Mother is rooted there; her hunters sleep round her. THE EGG BED lies
    at the hollow's west edge, in the swamp's reeds.
  - THE FERNS: south of the hollow, on the top, the YOUNG sleep apart from the nest (three beds: west, middle, east),
    and THE EXPEDITION'S CAMP stands on the plateau's south edge with the CAGE CARTS.
  - THE TWO WAYS DOWN: the plateau's south edge is a cliff with two ramps. THE SHORT WAY (the commission's path, from
    Valadares' map: a03's `map` drawn) goes down from the camp's middle and straight south to the river. THE LONG WAY
    (Benedito's memory: `map` withheld) goes west along the top to an old ramp at the far west, then winds through the
    forest to the river. Both are cleared trails through a dense forest.
  - SOUTH, THE RIVER LANDING: a sand quay on the river with Benedito's canoes, and on the quay two Lisbon crates "for
    the mines in the south", stamped with a gear (the act's one crate hint).
"""
import json
import math
import os
import random

W, H = 128, 150
cells = [["."] * W for _ in range(H)]
props = []
rnd = random.Random(2769 * 5)


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


def stroke(points, r):
    """The cells within r of a polyline."""
    out = set()
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for i in range(n + 1):
            cx, cy = x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n
            for yy in range(int(cy - r) - 1, int(cy + r) + 2):
                for xx in range(int(cx - r) - 1, int(cx + r) + 2):
                    if (xx + 0.5 - cx) ** 2 + (yy + 0.5 - cy) ** 2 <= r * r:
                        out.add((xx, yy))
    return out


# ---------------------------------------------------------------- the plateau (high ground), its south edge noisy
TOP = 4
EDGE = 52                   # the plateau's south edge (the cliff) by the two ramps
SHORT_X = (61, 67)          # the short way's ramp (6 wide)
LONG_X = (11, 17)           # the long way's ramp, far west (6 wide)


def bottom_edge(x):
    if SHORT_X[0] - 3 <= x < SHORT_X[1] + 3 or LONG_X[0] - 3 <= x < LONG_X[1] + 3:
        return EDGE
    return EDGE - 1 + int(2 * math.sin(x * 0.23) + 1.5 * math.sin(x * 0.08 + 0.7))


def left_edge(y):
    return 6 + int(1.5 * math.sin(y * 0.21))


def right_edge(y):
    return W - 7 - int(1.5 * math.sin(y * 0.17 + 0.4))


for y in range(H):
    for x in range(W):
        if TOP + int(1.2 * math.sin(x * 0.15)) <= y < bottom_edge(x) and left_edge(y) <= x < right_edge(y):
            put(x, y, "h")

# ---------------------------------------------------------------- THE NEST'S HOLLOW
HOLLOW = (44, 8, 86, 31)        # x0, y0, x1, y1 (exclusive)
for y in range(HOLLOW[1], HOLLOW[3]):
    for x in range(HOLLOW[0], HOLLOW[2]):
        dx = min(x - HOLLOW[0], HOLLOW[2] - 1 - x)
        dy = min(y - HOLLOW[1], HOLLOW[3] - 1 - y)
        if dx + dy >= 3:
            put(x, y, ".")
for x0, x1 in [(47, 53), (77, 83)]:
    rect(x0, HOLLOW[3] - 1, x1, HOLLOW[3], "r")

# ---------------------------------------------------------------- the two ramps down
rect(SHORT_X[0], EDGE, SHORT_X[1], EDGE + 1, "r")
rect(LONG_X[0], EDGE, LONG_X[1], EDGE + 1, "r")

# ---------------------------------------------------------------- black pools and sandstone towers on the top
for cx, cy, r in [(28, 18, 2.6), (104, 16, 2.4), (36, 44, 1.6), (96, 46, 1.8)]:
    blob(cx, cy, r, "w", "h")
# (kept off: the camp, the young's beds, the way west along the top, round the hollow's ramps)
KEEP_OFF = [(64, 44, 13), (32, 38, 6), (64, 38, 5), (96, 38, 6), (40, 47, 6), (24, 47, 6), (14, 48, 6), (50, 34, 5),
            (80, 34, 5), (88, 47, 6)]
for cx, cy, r in [(16, 24, 1.8), (22, 34, 1.5), (40, 20, 1.6), (92, 22, 1.8), (112, 30, 1.6), (110, 44, 1.5),
                  (100, 8, 1.3), (20, 10, 1.4), (74, 46, 1.2), (52, 46, 1.2), (118, 14, 1.4), (12, 40, 1.4)]:
    if all((cx - kx) ** 2 + (cy - ky) ** 2 > kr * kr for kx, ky, kr in KEEP_OFF):
        blob(cx, cy, r, "K", "h")

# ---------------------------------------------------------------- the river and the quay (south)
for x in range(W):
    for y in range(H - 6 + int(1.3 * math.sin(x * 0.09)), H):
        put(x, y, "w")
QUAY = (54, 76)
for x in range(QUAY[0], QUAY[1]):
    for y in range(H - 13, H - 5):
        put(x, y, ".")

# ---------------------------------------------------------------- the forest and its two trails
SHORT = [(64, EDGE + 1), (62, 62), (58, 74), (64, 88), (68, 100), (62, 112), (64, 126), (64, H - 12)]
LONG = [(14, EDGE + 1), (13, 62), (11, 76), (22, 90), (30, 100), (20, 112), (32, 122), (46, 130), (58, H - 12)]
CROSS = [(22, 90), (40, 94), (58, 92), (64, 88)]          # (a deer path between the two trails)
trail = stroke(SHORT, 2.2) | stroke(LONG, 2.2) | stroke(CROSS, 1.2)
# (the quay's clearing kept open)
for y in range(H):
    for x in range(W):
        if cells[y][x] != ".":
            continue
        if (x, y) in trail or (QUAY[0] - 2 <= x < QUAY[1] + 2 and y >= H - 15):
            continue
        if y >= EDGE + 1 or x < 4 or x >= W - 4 or y < 3:
            near_cliff = y < EDGE + 4
            # (dense, with small clearings where the pack waits)
            p = 0.34 if near_cliff else 0.6
            if (x // 9 + y // 9) % 7 == 0:
                p = 0.15
            if rnd.random() < p:
                put(x, y, "t")
# fallen rock along the cliff foot (not in front of the ramps)
for x in range(W):
    y = bottom_edge(x)
    if get(x, y - 1) == "h" and get(x, y) in (".", "t") and not (SHORT_X[0] - 1 <= x < SHORT_X[1] + 1 or LONG_X[0] - 1 <= x < LONG_X[1] + 1):
        if rnd.random() < 0.5:
            put(x, y, "k")
# low scrub on the top, off the paths
for y in range(TOP, EDGE):
    for x in range(W):
        if cells[y][x] == "h" and rnd.random() < 0.045 and all((x - kx) ** 2 + (y - ky) ** 2 > kr * kr for kx, ky, kr in KEEP_OFF):
            put(x, y, "T")

# ---------------------------------------------------------------- props
props += [["boat", 60, H - 5, False], ["boat", 64, H - 5, True], ["boat", 68, H - 5, False], ["boat", 56, H - 6, True],
          ["campfire", 58, H - 10, False], ["sacks_pile", 62, H - 11, False], ["anchor", 74, H - 8, False]]
props += [["crates_pair", 70, H - 10, False], ["barrel_b", 72, H - 10, False]]        # the Lisbon crates (the hint)
props += [["tent_white", 56, 43, False], ["tent_white", 72, 43, True], ["campfire", 64, 47, False],
          ["crates_pair", 58, 47, False], ["sacks_pile", 70, 47, False]]               # the expedition's camp
props += [["reeds", 46, 19, False], ["reeds", 48, 23, True], ["reeds", 45, 22, False]]  # the egg bed
for x, y in [(52, 12), (78, 12), (52, 26), (78, 26), (65, 10)]:
    props.append(["nest", x, y, False])
for x, y in [(32, 38), (64, 37), (96, 38)]:
    props.append(["shrub_dark", x, y, False])
for x, y, k in [(26, 42, "boulder_moss"), (100, 42, "rocks_moss"), (40, 30, "dead_tree"), (88, 30, "stones"),
                (20, 46, "ruin_pillar"), (110, 22, "dead_tree")]:
    props.append([k, x, y, False])
for x, y in [(40, 70), (88, 76), (24, 100), (100, 108), (48, 112), (84, 124)]:
    props.append(["log_moss", x, y, False])
props = [p for p in props if get(p[1], p[2]) in (".", "h")]

# the starts the mission places its teams on (one per team: expedition, convoy, creatures, pack)
starts = [[64, 45], [62, 45], [64, 16], [104, 80]]
data = {
    "name": "plateau_descent", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "jungle",
    "starts": starts, "teams": list(range(len(starts))), "mode": "1v1", "halls": [],
    "props": props, "checked": True,
}
out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "plateau_descent.json")
with open(out, "w") as f:
    json.dump(data, f)
print("wrote", os.path.normpath(out), len(props), "props")
if __name__ == "__main__" and os.environ.get("SHOW"):
    for row in cells:
        print("".join(row))
