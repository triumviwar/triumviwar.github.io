#!/usr/bin/env python3
"""Writes campaign/maps/concordia.json, the map of Act 2's "The City of Gears" (d04_concordia; the plan:
docs/campaign_act2_plan.md "d04_concordia"; what was built: docs/campaign_d04_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford, t tree, k rock; props [name, x, y,
flip]). Rebuild:
  python3 tools/campaign/make_concordia_map.py [--ascii]

The southern highlands (proposed: the plateau above the Rio Uruguai), 2773, 120 x 96 cells, THE HIGHLANDS biome
(docs/act2_terrain_art.md: cold grass, terra roxa, grey basalt plateaus, araucaria pines, banks of mist):
  - NORTH-EAST: THE PLATEAU (high ground), the city's site. THE OLD MINE in its north-east corner: spoil heaps (rock),
    the mine mouth and, behind a crooked gallery between the heaps, THE DEEPEST GALLERY where the two crates of 2767
    lie. The guild's camp of tents in the middle; the Clocktower's site over the mine's old shaft; the first quarter
    (the families' houses) to the south-west of it.
  - THREE WAYS UP (the approaches the Swifts must map): THE CART ROAD (a ramp on the plateau's west edge, the road
    down to the valley town), THE RANCH TRACK (a ramp on the south edge, the track to the ranches) and THE PINE PATH
    (a ramp on the north-west, out of the araucaria woods along the north edge).
  - SOUTH-WEST: THE VALLEY TOWN with its white church, by the ford of the river.
  - SOUTH-EAST: THE RANCHES (corrals, a drovers' camp, haystacks).
  - THE RIVER from the north-west woods to the south edge, crossed by the road at THE FORD by the town; a second, rocky
    ford downstream (the ranchers' way).
"""
import json
import math
import os
import random
import sys

W, H = 120, 96
cells = [["."] * W for _ in range(H)]
props = []
rnd = random.Random(2773)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def get(x, y):
    return cells[y][x] if 0 <= x < W and 0 <= y < H else "h"


def rect(x0, y0, x1, y1, ch, only=None):
    for y in range(y0, y1):
        for x in range(x0, x1):
            if only is None or get(x, y) in only:
                put(x, y, ch)


def blob(cx, cy, rx, ry, ch, only=None, wob=0.15):
    for y in range(int(cy - ry - 2), int(cy + ry + 3)):
        for x in range(int(cx - rx - 2), int(cx + rx + 3)):
            a = math.atan2(y - cy, x - cx)
            r = 1 + wob * math.sin(3 * a + cx) * math.cos(2 * a + cy)
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= r * r:
                if only is None or get(x, y) in only:
                    put(x, y, ch)


def line(pts, width, ch, only=None):
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for k in range(n + 1):
            t = k / n
            cx, cy = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            for dy in range(-width, width + 1):
                for dx in range(-width, width + 1):
                    if dx * dx + dy * dy <= width * width:
                        x, y = int(round(cx + dx)), int(round(cy + dy))
                        if only is None or get(x, y) in only:
                            put(x, y, ch)


# ---------------------------------------------------------------- THE PLATEAU (north-east), a wobbly edge
def edge_x(y):
    """The plateau's west edge at row y (it is high east of this)."""
    return 50 + int(3 * math.sin(y / 6.0)) + (0 if y < 40 else (y - 40) * 2)


def edge_y(x):
    """The plateau's south edge at column x (it is high north of this)."""
    return 52 + int(2 * math.sin(x / 5.0))


for y in range(H):
    for x in range(W):
        if x >= edge_x(y) and y <= edge_y(x):
            put(x, y, "h")

# ---------------------------------------------------------------- THE THREE WAYS UP (ramps across the edge)
RAMPS = {
    "ramp_road": (None, 32),        # the cart road: the west edge at row 32
    "ramp_path": (None, 9),         # the pine path: the west edge at row 9
    "ramp_track": (92, None),       # the ranch track: the south edge at column 92
}
RAMP_AT = {}
for nm, (rx, ry) in RAMPS.items():
    if ry is not None:
        ex = min(edge_x(y) for y in range(ry, ry + 4))
        rect(ex - 2, ry, ex + 2, ry + 4, "r")
        for y in range(ry, ry + 4):              # (the edge straight across the ramp's rows)
            for x in range(ex + 2, ex + 4):
                put(x, y, "h")
        RAMP_AT[nm] = (ex - 2, ry, 4, 4)
    else:
        ey = max(edge_y(x) for x in range(rx, rx + 4))
        for x in range(rx, rx + 4):
            for y in range(edge_y(x) + 1, ey + 1):
                put(x, y, "h")
        rect(rx, ey - 1, rx + 4, ey + 3, "r")
        RAMP_AT[nm] = (rx, ey - 1, 4, 4)

# ---------------------------------------------------------------- THE OLD MINE (the plateau's north-east corner)
# spoil heaps of grey rock round the mine mouth, a crooked gallery between them to the deepest gallery
for (cx, cy, rx, ry) in [(104, 5, 6, 4), (113, 12, 5, 6), (96, 3, 4, 2), (110, 22, 4, 3), (117, 3, 3, 3)]:
    blob(cx, cy, rx, ry, "k", only=("h",))
rect(103, 8, 108, 13, "h")          # the mine mouth (open ground in the heaps)
line([(105, 10), (108, 7), (111, 4)], 2, "h")      # the crooked gallery (wide enough for a party: three cells)
rect(109, 1, 116, 6, "h")           # the deepest gallery (the crates)
for (x, y) in [(116, 1), (116, 5)]:
    put(x, y, "k")

# ---------------------------------------------------------------- THE RIVER (north-west woods to the south edge)
RIVER = [(0, 44), (10, 46), (20, 52), (28, 60), (34, 68), (40, 76), (46, 84), (52, 95)]
line(RIVER, 2, "w", only=(".",))
FORDS = {"ford_town": (30, 62), "ford_ranch": (47, 86)}
for nm, (fx, fy) in FORDS.items():
    blob(fx, fy, 4, 4, "f", only=("w",), wob=0.0)

# ---------------------------------------------------------------- the araucaria woods: the north-west (the pine path's
# cover), groves on the low ground, a few on the plateau's rim
for y in range(H):
    for x in range(W):
        if get(x, y) != ".":
            continue
        if y < 26 and x < edge_x(y) - 3:
            dens = 0.55 if x > 8 else 0.35
        elif 64 < y and 54 < x < 78:
            dens = 0.10
        else:
            dens = 0.025
        if rnd.random() < dens:
            put(x, y, "t")
# the pine path through the woods: from the north-west corner's open ground to the ramp
line([(6, 22), (16, 16), (28, 12), (40, 11), (RAMP_AT["ramp_path"][0], 11)], 1, ".", only=("t",))
line([(6, 22), (4, 30), (8, 40)], 1, ".", only=("t",))
# the cart road down from the plateau to the town's ford, kept clear
ROAD = [(RAMP_AT["ramp_road"][0], 34), (40, 36), (34, 44), (32, 54), (31, 60)]
line(ROAD, 1, ".", only=("t",))
# the ranch track down from the south ramp to the ranches
TRACK = [(94, 56), (96, 64), (98, 74), (100, 80)]
line(TRACK, 1, ".", only=("t",))
# groves on the plateau's rim (araucaria)
for (cx, cy) in [(62, 6), (60, 46), (56, 14), (118, 40), (78, 4)]:
    for _ in range(5):
        x, y = cx + rnd.randint(-2, 2), cy + rnd.randint(-2, 2)
        if get(x, y) == "h":
            props.append(["araucaria" if rnd.random() < 0.6 else "araucaria_young", x, y, rnd.random() < 0.5])

# ---------------------------------------------------------------- props
# the mine: spoil, carts, the old headframe's ruin, crates by the mouth
props += [["ruin_tower", 106, 8, False], ["cart_a", 101, 12, False], ["crates_pair", 104, 13, False], ["barrel_a", 102, 14, False],
          ["highland_boulder", 98, 9, False], ["highland_boulder", 108, 14, True], ["stones", 100, 6, False], ["stones", 111, 9, True],
          ["crate_long", 114, 2, False], ["crate_open", 115, 3, True], ["cross_wood", 103, 9, False]]
# the guild's camp of tents (the families), the forge, firewood
for i, (x, y) in enumerate([(70, 36), (74, 38), (68, 41), (77, 41), (72, 43), (66, 38)]):
    props.append([["tent_white", "tent_blue", "tent_round"][i % 3], x, y, i % 2 == 1])
props += [["campfire_pot", 72, 40, False], ["forge", 76, 33, False], ["firewood", 74, 34, False], ["wagon", 64, 42, False],
          ["crate_a", 70, 44, False], ["sacks_pile", 78, 44, False], ["banner_pole", 69, 33, False]]
# the plateau's grass, stones and mist
for _ in range(60):
    x, y = rnd.randint(54, 118), rnd.randint(2, 50)
    if get(x, y) == "h" and not (60 <= x <= 96 and 12 <= y <= 42):
        props.append([rnd.choice(["cold_tussock", "cold_tussock", "stones", "highland_boulder"]), x, y, rnd.random() < 0.5])
for (x, y) in [(58, 14), (62, 48), (88, 48), (116, 30), (56, 40)]:
    props.append(["mist_wisp", x, y, False])
# the valley town: the white church, cottages, a windmill, a well, fences, the square
# (the church at [18, 68], the cottages at [8, 66], [10, 76], [22, 84], the Barracks at [24, 72] and the Horse Breeder
# at [100, 82] are the mission's BUILDINGS: tools/campaign/make_d04_mission.py)
props += [["cross_stone", 20, 72, False], ["well", 14, 74, False], ["cottage", 4, 84, True],
          ["windmill", 4, 78, False], ["stall", 16, 80, False], ["bench", 18, 82, False], ["cart_b", 28, 78, False],
          ["haystack", 6, 88, False], ["fence", 4, 70, False], ["fence_b", 8, 70, False], ["signpost", 28, 66, False]]
# the ranches: corrals, haystacks, the drovers' camp
for x in range(92, 112, 4):
    props.append(["fence", x, 76, False])
    if not 98 <= x <= 104:
        props.append(["fence_b", x, 86, False])
props += [["trough", 97, 80, False], ["haystack", 108, 80, False], ["haystack_b", 112, 84, True], ["shed", 106, 89, False],
          ["campfire", 100, 90, False], ["ox_skull", 96, 90, False], ["cart_c", 106, 92, False], ["haybales", 110, 90, False]]
# the low ground: tussocks, boulders, mist on the river
for _ in range(50):
    x, y = rnd.randint(2, 117), rnd.randint(30, 94)
    if get(x, y) == "." and not (2 <= x <= 30 and 62 <= y <= 92) and not (90 <= x <= 116 and 74 <= y <= 94):
        props.append([rnd.choice(["cold_tussock", "cold_tussock", "highland_boulder", "stones", "grass_tall"]), x, y, rnd.random() < 0.5])
for (x, y) in [(12, 48), (24, 58), (40, 80), (36, 70)]:
    props.append(["mist_wisp", x, y, True])

# the guild (the plateau's camp), the valley (the town), the ranches
starts = [[70, 34], [16, 74], [102, 82]]
teams = [0, 1, 1]

data = {
    "name": "concordia", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "highlands",
    "starts": starts, "teams": teams, "mode": "1v1", "halls": [],
    "props": props, "checked": True,
    "about": "The southern highlands, 2773: the old mine where the guild founds Concórdia, and the valley below (d04_concordia).",
}
if __name__ == "__main__":
    out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "concordia.json")
    with open(out, "w") as f:
        json.dump(data, f, ensure_ascii=False)
    print("wrote", os.path.normpath(out), len(props), "props; ramps", RAMP_AT, "fords", FORDS)
    if "--ascii" in sys.argv:
        for r in cells:
            print("".join(r))
