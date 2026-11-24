#!/usr/bin/env python3
"""Writes campaign/maps/sao_francisco.json, the map of Act 2's SECOND CROSSING, "Between Two Fires" (d09_crossroads; the
plan: docs/campaign_act2_plan.md "d09_crossroads"; what was built: docs/campaign_d09_build.md), in the MAP EDITOR's own
format (scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford, t tree, k rock; props [name, x, y,
flip]). Rebuild:
  python3 tools/campaign/make_sao_francisco_map.py [--ascii]

The sertão in the dry season of 2780, 136 x 96 cells, the SERTÃO biome (the painted dry backlands of the act2-terrain job:
cracked red-brown earth, pale dust, thorn scrub, mandacaru cactus, red sandstone mesas):
  - THE ROAD from Salvador's way (the east edge) west through two villages of the sertão, RIACHO SECO (proposed) and
    LAGOA BRANCA (proposed), to FORT CONSTANTINE (proposed) on the river's east bank (west-centre).
  - THE SÃO FRANCISCO, the great brown river, along the west, north to south, with THREE FORDS: the north ford (the
    creatures' way over), the fort's ford right under its west wall (where the creatures and the machines meet), the
    south ford (the machines' way over).
  - Beyond the river: the NORTH-WEST TRAIL (the jungle's way, where the swarm comes from) and the SOUTH-WEST TRAIL (the
    highlands' way, where the city's machines come from).
  - Red sandstone MESAS in the scrub (high ground with a ramp each), away from the road: the raids come round them.
  - The fort itself is cleared ground: its palisade, gates and buildings are the mission's (make_d09_mission.py).
"""
import json
import math
import os
import random
import sys

W, H = 160, 96
cells = [["."] * W for _ in range(H)]
props = []
rnd = random.Random(2780)


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


CLEAR = set()       # cells kept free of trees and rocks (the road, the villages, the fort, where the raids come out)


def clear_rect(x0, y0, x1, y1):
    for y in range(y0, y1):
        for x in range(x0, x1):
            CLEAR.add((x, y))


def path(points, width=2):
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for i in range(n + 1):
            x = x0 + (x1 - x0) * i / n
            y = y0 + (y1 - y0) * i / n
            for dy in range(-width, width + 1):
                for dx in range(-width, width + 1):
                    if dx * dx + dy * dy <= width * width:
                        CLEAR.add((int(round(x + dx)), int(round(y + dy))))


# ---------------------------------------------------------------- the São Francisco (west) and its three fords
def river_x(y):
    return 17 + int(round(2.5 * math.sin(y / 11.0)))


FORDS = [(11, 17), (44, 52), (79, 85)]       # the north ford, the fort's ford, the south ford (rows)
for y in range(H):
    rx = river_x(y)
    for x in range(rx - 3, rx + 4):
        ford = any(a <= y < b for (a, b) in FORDS)
        put(x, y, "f" if ford else "w")
    for x in range(rx - 4, rx + 5):
        CLEAR.add((x, y))

# ---------------------------------------------------------------- the road, the villages, the fort
E = 24          # (everything east of the fort's ground is drawn 24 cells farther east: the long dry stretch before the fort)


def ex(x):
    return x + E if x >= 50 else x


ROAD = [(159, 48), (146, 47), (136, 45), (128, 43), (120, 46), (112, 51), (104, 55), (96, 57), (88, 53), (76, 50), (62, 49), (48, 48)]
path(ROAD, 2)
VILLAGES = {"riacho": (128, 39, 7, 5), "lagoa": (96, 61, 7, 5)}
for nm, (cx, cy, rx, ry) in VILLAGES.items():
    clear_rect(cx - rx - 2, cy - ry - 2, cx + rx + 3, cy + ry + 3)
FORT = (26, 37, 50, 60)          # (x0, y0, x1, y1): the palisade's ring and a cleared margin round it
clear_rect(FORT[0] - 2, FORT[1] - 4, FORT[2] + 4, FORT[3] + 4)
# the trails beyond the river: north-west to the jungle, south-west to the highlands (dry tracks, the raids' roads)
path([(river_x(14) - 4, 14), (8, 10), (2, 3)], 2)
path([(river_x(82) - 4, 82), (8, 86), (2, 93)], 2)
path([(river_x(48) - 4, 48), (6, 48)], 1)
# from the fords over the scrub on the east bank toward the fort's north and south gates
path([(river_x(14) + 4, 14), (30, 24), (37, 34)], 1)
path([(river_x(82) + 4, 82), (30, 72), (37, 63)], 1)

# ---------------------------------------------------------------- red sandstone mesas (high ground, a ramp each)
MESAS = [(90, 24, 8, 5, "s"), (56, 22, 6, 4, "s"), (60, 80, 9, 5, "n"), (118, 76, 7, 5, "w"), (120, 20, 6, 4, "s"),
         (96, 74, 5, 4, "n"), (8, 30, 4, 6, "e"), (8, 64, 4, 6, "e")]
MESAS = [(ex(cx), cy, rx, ry, ramp) for (cx, cy, rx, ry, ramp) in MESAS]
for (cx, cy, rx, ry, ramp) in MESAS:
    ellipse(cx, cy, rx, ry, "h", wob=0.12)
    if ramp == "s":
        col = [y for y in range(H) if get(cx, y) == "h"]
        for x in range(cx - 1, cx + 2):
            for y in (col[-1], col[-1] - 1):
                put(x, y, "r")
    elif ramp == "n":
        col = [y for y in range(H) if get(cx, y) == "h"]
        for x in range(cx - 1, cx + 2):
            for y in (col[0], col[0] + 1):
                put(x, y, "r")
    elif ramp == "w":
        row = [x for x in range(W) if get(x, cy) == "h"]
        for y in range(cy - 1, cy + 2):
            for x in (row[0], row[0] + 1):
                put(x, y, "r")
    elif ramp == "e":
        row = [x for x in range(W) if get(x, cy) == "h"]
        for y in range(cy - 1, cy + 2):
            for x in (row[-1], row[-1] - 1):
                put(x, y, "r")

# where the raids come out and gather (kept open)
for (x0, y0, x1, y1) in [(88, 8, 102, 18), (62, 74, 78, 86), (2, 2, 14, 14), (2, 82, 14, 94), (66, 1, 82, 8), (78, 88, 94, 95),
                         (104, 34, 116, 50), (78, 44, 92, 54), (54, 42, 64, 54), (28, 24, 46, 36), (28, 61, 46, 72)]:
    clear_rect(ex(x0), y0, ex(x0) + (x1 - x0), y1)

# ---------------------------------------------------------------- the caatinga: thorn trees and cactus, a few rock piles
for y in range(H):
    for x in range(W):
        if get(x, y) != "." or (x, y) in CLEAR:
            continue
        r = rnd.random()
        if r < 0.075:
            put(x, y, "t")
        elif r < 0.088:
            put(x, y, "k")
# a few thicker thorn brakes (the raids' cover) off the road
for (cx, cy, rx, ry) in [(82, 34, 5, 3), (116, 60, 5, 3), (48, 70, 4, 3), (46, 28, 4, 3), (126, 32, 4, 3), (100, 58, 3, 2), (62, 36, 4, 3), (66, 62, 4, 3)]:
    cx = ex(cx)
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if get(x, y) == "." and (x, y) not in CLEAR and rnd.random() < 0.42:
                put(x, y, "t")
# the map's border: never a tree or a rock against the edge
for y in range(H):
    for x in range(W):
        if (x < 1 or y < 1 or x > W - 2 or y > H - 2) and get(x, y) in ("t", "k"):
            put(x, y, ".")

# ---------------------------------------------------------------- props
props += [
    # Riacho Seco: a well, a cross, a drying rack, an oven, goats' trough, a cart
    ["well", 104, 39, False], ["cross_wood", 99, 36, False], ["drying_rack", 108, 42, False], ["oven", 100, 42, True],
    ["trough", 110, 38, False], ["cart_b", 97, 40, False], ["ox_skull", 112, 44, False],
    # Lagoa Branca: the dried pond's well, a chapel cross, baskets, a cart
    ["well", 72, 61, False], ["cross_wood", 67, 58, False], ["baskets", 76, 64, False], ["cart_c", 78, 59, True],
    ["haybales", 66, 64, False], ["fence", 70, 66, False],
    # the road: a signpost at the start, a wayside cross, a broken cart
    ["signpost", 128, 45, False], ["cross_wood", 88, 47, False], ["cart_a", 60, 46, True], ["ox_skull", 118, 50, True],
    # the fort: flags, cannonballs, barrels by the magazine (the buildings are the mission's)
    ["flag", 49, 44, False], ["flag", 49, 52, False], ["cannonballs", 35, 51, False], ["barrel_tall", 41, 51, False],
    ["tent_white", 30, 51, False], ["campfire", 34, 44, False],
    # the ford's post (a letter is nailed to it with a06 `varenne` executed)
    ["signpost", 24, 51, True],
    # the trails beyond the river
    ["cross_stone", 7, 10, False], ["ox_skull", 6, 87, False], ["branches", 9, 47, False],
]
props = [[nm, ex(x), y, fl] for (nm, x, y, fl) in props]
for _ in range(130):
    x, y = rnd.randrange(2, W - 2), rnd.randrange(2, H - 2)
    if get(x, y) == "." and (x, y) not in CLEAR:
        props.append([rnd.choice(["caatinga_bush", "xique_xique", "xique_xique", "sertao_stones", "mandacaru", "branches", "ox_skull"]),
                      x, y, rnd.random() < 0.5])

starts = [[154, 48], [38, 48]]
teams = [0, 1]

data = {
    "name": "sao_francisco", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "sertao",
    "starts": starts, "teams": teams, "mode": "1v1", "halls": [],
    "props": props, "checked": True,
    "about": "Act 2's second crossing (d09_crossroads): the road through the sertão to the fort at the São Francisco.",
}
if __name__ == "__main__":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "campaign", "maps", "sao_francisco.json")
    with open(out, "w") as f:
        json.dump(data, f)
    flat = "".join("".join(r) for r in cells)
    print("wrote", os.path.normpath(out), len(props), "props;", flat.count("t"), "trees,", flat.count("h"), "high,", flat.count("f"), "ford cells")
    if "--ascii" in sys.argv:
        for i, r in enumerate(cells):
            print("%3d %s" % (i, "".join(r)))
