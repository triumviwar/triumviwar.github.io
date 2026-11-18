#!/usr/bin/env python3
"""Writes campaign/maps/furth_line.json, the map of Act 1's "The Fürth Line" (a02_furth; the plan:
docs/campaign_act1_plan.md "a02_furth"; what was built: docs/campaign_a02_build.md), in the MAP EDITOR's own format (see
scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford, t tree, k rock; props [name, x, y, flip]).
To edit by hand: copy it to <user folder>/maps/, open it in the MAP EDITOR, save, copy it back. Rebuild:
  python3 tools/campaign/make_furth_map.py

Fürth and the road to Nuremberg, March 2768, 128 x 80 cells, the snow melting (the snow biome):
  - THE RIVERS: the PEGNITZ comes out of Nuremberg (east) and runs west to Fürth, where the REDNITZ comes in from the
    south-east and the two make the REGNITZ, flowing north past Fürth's west side. Fords: Fürth's own bridge over the
    Pegnitz, and the old bridge by Nuremberg's walls (where the machine crosses from one bank to the other).
  - FÜRTH (west, in the angle of the rivers): the town's houses and church on the north bank, the guild's yard in the
    middle (the Honest One, the guild's new Clocktower, is the mission's), the refugees' corner by the river.
  - THE LINE: the Crown's earthworks run north-south a little east of the town, on both banks (the mission lays the
    palisades and their gates; this map keeps their cells free): the ROAD GATE on the north bank, the MEADOW GATE on
    the south bank.
  - THE WATER MEADOWS: the south bank, between the Pegnitz and the Rednitz, wet and open; THE REDNITZ MILL half way
    to Nuremberg on the meadows' south edge (a windmill prop: the Part 3 seed is the mission's).
  - NUREMBERG (east edge): the city walls, red towers on the skyline, unwalkable; the machine's seeds stand by its two
    gates (the mission places them).
"""
import json
import os

W, H = 128, 80
cells = [["."] * W for _ in range(H)]
props = []


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def rect(x0, y0, x1, y1, ch):
    for y in range(y0, y1):
        for x in range(x0, x1):
            put(x, y, ch)


def river(points, width, ch="w"):
    """Water along a polyline, `width` cells across (a disc stamped every half cell)."""
    r = width / 2.0
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for i in range(n + 1):
            cx = x0 + (x1 - x0) * i / n
            cy = y0 + (y1 - y0) * i / n
            for y in range(int(cy - r) - 1, int(cy + r) + 2):
                for x in range(int(cx - r) - 1, int(cx + r) + 2):
                    if (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 <= r * r:
                        put(x, y, ch)


# ---------------------------------------------------------------- woods round the edges (the map's frame)
for x in range(W):
    for y in range(0, 1 + (x * 7 % 2)):
        put(x, y, "t")
    for y in range(H - 1 - (x * 5 % 2), H):
        put(x, y, "t")
for y in range(H):
    for x in range(0, 2 + (y * 3 % 2)):
        put(x, y, "t")

# ---------------------------------------------------------------- the rivers
CONF = (30, 40)                                                    # where the Rednitz meets the Pegnitz
PEGNITZ = [(30, 40), (46, 38), (62, 37), (80, 35), (98, 34), (114, 33), (128, 33)]
REDNITZ = [(30, 41), (42, 50), (56, 58), (70, 66), (80, 73), (86, 80)]
REGNITZ = [(30, 40), (29, 28), (27, 14), (26, 0)]
river(PEGNITZ, 3.6)
river(REDNITZ, 3.2)
river(REGNITZ, 4.2)
# the fords: Fürth's bridge over the Pegnitz, and the old bridge by Nuremberg's walls
FORDS = {"furth_bridge": (40, 44), "old_bridge": (98, 102)}
for x0, x1 in FORDS.values():
    for x in range(x0, x1):
        for y in range(28, 46):
            if cells[y][x] == "w":
                put(x, y, "f")

# ---------------------------------------------------------------- the woods west of the Regnitz (beyond the town)
for y in range(1, H - 1):
    for x in range(2, 24):
        if cells[y][x] == "." and (x * 7 + y * 13) % 5 < 2:
            put(x, y, "t")
# and south of the Rednitz (wet woods, a few clearings)
for y in range(46, H - 1):
    for x in range(2, W):
        # below the Rednitz's line
        on_south = False
        for (ax, ay), (bx, by) in zip(REDNITZ, REDNITZ[1:]):
            if min(ax, bx) <= x <= max(ax, bx) and bx != ax:
                ry = ay + (by - ay) * (x - ax) / (bx - ax)
                on_south = y > ry + 3
        if on_south and cells[y][x] == "." and (x * 5 + y * 11) % 7 < 3:
            put(x, y, "t")

# ---------------------------------------------------------------- Nuremberg's walls and the city behind them (east)
WALL_X = 114
GATES = {"north_gate": range(15, 22), "south_gate": range(45, 52)}
for y in range(H):
    if any(y in g for g in GATES.values()) or cells[y][WALL_X] in ("w", "f"):
        continue
    put(WALL_X, y, "k")
    put(WALL_X + 1, y, "k")
for y in range(H):
    for x in range(WALL_X + 2, W):
        if cells[y][x] not in ("w", "f"):
            put(x, y, "k")
# the gate yards inside the gates are the city's: open only to their gate
for g in GATES.values():
    for y in g:
        for x in range(WALL_X, WALL_X + 4):
            put(x, y, ".")
for y in range(1, H - 1, 4):
    if cells[y][WALL_X] == "k":
        props.append(["ruin_wall", WALL_X - 1, y, False])
for x, y in [(WALL_X - 2, 12), (WALL_X - 2, 24), (WALL_X - 2, 42), (WALL_X - 2, 54), (WALL_X - 2, 4), (WALL_X - 2, 70)]:
    props.append(["ruin_tower", x, y, False])
for x, y in [(119, 8), (121, 26), (118, 40), (122, 58), (120, 70)]:     # the skyline: towers and the castle on its rock
    props.append(["ruin_tower", x, y, False])
props += [["ruin_keep", 120, 14, False], ["chapel_tower", 118, 48, False], ["flag", 121, 12, False]]

# ---------------------------------------------------------------- Fürth: houses, the church, the guild's yard
def houses(x0, y0, x1, y1, every=4, kinds=("cottage", "shed", "cottage")):
    i = 0
    for y in range(y0, y1, 4):
        for x in range(x0, x1, every):
            if all(cells[yy][xx] == "." for yy in range(y, min(y + 2, H)) for xx in range(x, min(x + 2, W))):
                props.append([kinds[i % len(kinds)], x, y, (i % 2) == 1])
            i += 1


houses(32, 3, 52, 9, 5)                # the old town, north
houses(32, 30, 39, 35, 4)              # by the Pegnitz, west of the bridge
props += [["chapel", 47, 30, False], ["chapel_tower", 51, 29, False], ["well", 44, 27, False]]
# the guild's barn and yard furniture (the yard itself, x 32-54 y 11-27, is the mission's ground)
props += [["forge", 33, 24, False], ["crate_long", 34, 12, False], ["crates_pair", 52, 12, False], ["barrel_b", 53, 24, False],
          ["wagon", 33, 27, True], ["signpost", 56, 21, False], ["haystack", 35, 26, False]]
# the refugees' corner, south bank west of the line (tents in the angle of the two rivers)
props += [["tent_white", 44, 42, False], ["tent_round", 47, 41, False], ["campfire", 46, 44, False], ["cart_b", 50, 44, False],
          ["tent_blue", 44, 46, False], ["cauldron", 48, 47, False]]
# the Crown's camp behind the line (north bank)
props += [["tent_red", 50, 4, False], ["tent_red", 54, 5, False], ["banner_pole", 53, 8, False], ["cannonballs", 55, 26, False],
          ["flag", 49, 8, False]]

# ---------------------------------------------------------------- the meadows and the road: the mill, hedges, a farm
props += [["windmill", 72, 58, False], ["shed", 76, 59, False], ["sacks_pile", 70, 61, False], ["cart_c", 75, 62, True]]
props += [["fence", 66, 46, False], ["fence", 70, 46, False], ["fence_b", 84, 48, False], ["haybales", 88, 44, False],
          ["scarecrow", 80, 52, False], ["dead_trunk", 92, 56, False], ["stump", 64, 52, False], ["log", 96, 60, False]]
props += [["cottage", 76, 10, False], ["shed", 81, 10, True], ["haystack_b", 78, 15, False], ["fence", 74, 15, False],
          ["cross_wood", 92, 24, False], ["signpost", 66, 20, False], ["cart_a", 100, 26, False], ["stump_moss", 88, 6, False]]
for x, y in [(62, 3), (70, 4), (96, 3), (104, 6), (86, 28), (68, 30)]:
    props.append(["pine", x, y, False])

starts = [[38, 15], [106, 46]]
data = {
    "name": "furth_line", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "snow",
    "starts": starts, "teams": [0, 1], "mode": "1v1", "halls": [],
    "props": props, "checked": True,
}
out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "furth_line.json")
with open(out, "w") as f:
    json.dump(data, f)
print("wrote", os.path.normpath(out), len(props), "props")
