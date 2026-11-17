#!/usr/bin/env python3
"""Writes campaign/maps/nuremberg_advent.json, the Clockwork prologue's map ("The Thirteenth Hour",
docs/campaign_clockwork_prologue.md; what was built: docs/campaign_c01_build.md), in the MAP EDITOR's own format (see
scripts/mapgen.gd: one letter per cell, . low, h high, r ramp, w water, f ford, t tree, k rock; props [name, x, y, flip]).
To edit by hand: copy it to <user folder>/maps/, open it in the MAP EDITOR, save, copy it back. Rebuild:
  python3 tools/campaign/make_nuremberg_map.py

Nuremberg in Advent, 120 x 88 cells, snow:
  - THE WALLS: a ring of stone (ruined-wall and tower props: solid) with three gaps: the WEST GATE (the Spittlertor, the
    way out to the Crown's camp: the townsfolk's exit), the EAST GATE (where a late seed breaks out), and where the
    river runs through. The south gate by the guild quarter is closed.
  - THE PEGNITZ runs west to east through the middle, frozen at the bridges (fords: three crossings), and widens round
    THE MILL ISLAND (windmill props for the mills: the machine's first, hidden network).
  - NORTH: the CASTLE ROCK (high ground, a ramp on its east side), the old BATH HOUSES by the river, the HAUPTMARKT with
    the Advent market's stalls and the FRAUENKIRCHE (chapel props), the east quarter by the east gate.
  - SOUTH: the GUILD QUARTER, Meister Hollweg's yard (the player's base: open gear ground), houses, and the road west to
    the west gate.
The mission's buildings (the Perpetual, the seeds, the links on the bridges) are placed by the mission, on cells kept
free of props here.
"""
import json
import os

W, H = 120, 88
cells = [["."] * W for _ in range(H)]
props = []
solid_props = set()          # cells a prop takes (kept off the streets and the mission's ground)


def put(x, y, ch):
    if 0 <= x < W and 0 <= y < H:
        cells[y][x] = ch


def rect(x0, y0, x1, y1, ch):
    for y in range(y0, y1):
        for x in range(x0, x1):
            put(x, y, ch)


def blob(cx, cy, rx, ry, ch):
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - rx), int(cx + rx) + 1):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                put(x, y, ch)


# ---------------------------------------------------------------- the land outside the walls: snowy woods
for x in range(W):
    for y in range(0, 2 + (x * 7 % 3)):
        put(x, y, "t")
    for y in range(H - 2 - (x * 5 % 3), H):
        put(x, y, "t")
for y in range(H):
    for x in range(0, 1 + (y * 3 % 2)):
        if not (50 <= y <= 66):
            put(x, y, "t")
    for x in range(W - 1 - (y * 5 % 2), W):
        put(x, y, "t")

# ---------------------------------------------------------------- the river and the mill island
RIVER_Y0, RIVER_Y1 = 40, 44            # the river's rows (y0 <= y < y1)
rect(0, RIVER_Y0, W, RIVER_Y1, "w")
rect(48, 35, 70, 49, "w")              # it widens round the mill island
rect(52, 38, 66, 46, ".")              # the island
BRIDGES = {"bridge_w": (26, 30), "bridge_e": (92, 96), "bridge_mill_s": (57, 60), "bridge_mill_n": (57, 60)}
rect(26, RIVER_Y0, 30, RIVER_Y1, "f")  # the west bridge (frozen ford)
rect(92, RIVER_Y0, 96, RIVER_Y1, "f")  # the east bridge
rect(57, 46, 60, 49, "f")              # island -> south bank
rect(57, 35, 60, 38, "f")              # island -> north bank

# ---------------------------------------------------------------- the castle rock (north-west)
rect(12, 6, 36, 19, "h")
rect(36, 13, 38, 17, "r")              # its ramp, east side, down to the market road
rect(12, 6, 15, 8, "k")                # rocks on its edges
put(34, 7, "k")

# ---------------------------------------------------------------- the walls
WX0, WX1, WY0, WY1 = 6, 113, 4, 83     # the ring (inclusive)
WEST_GATE = range(54, 61)              # the gap on the west wall (y)
EAST_GATE = range(20, 27)              # the gap on the east wall (y)


def wall_piece(x, y):
    """A stretch of wall: a ruined-wall prop (2 cells wide on rows, so one every 2 cells along a row)."""
    props.append(["ruin_wall", x, y, False])


def tower(x, y):
    props.append(["ruin_tower", x, y, False])


for x in range(WX0, WX1 + 1, 2):       # north and south walls
    if cells[WY0][x] == "." and cells[WY0][min(x + 1, W - 1)] == ".":
        wall_piece(x, WY0)
    if cells[WY1][x] == "." and cells[WY1][min(x + 1, W - 1)] == ".":
        wall_piece(x, WY1)
for y in range(WY0, WY1 + 1):          # west and east walls: rocks one cell wide, a wall prop on every other row
    for x, gate in ((WX0, WEST_GATE), (WX1, EAST_GATE)):
        if y in gate or cells[y][x] != ".":
            continue
        put(x, y, "k")
for x, y in [(WX0 + 1, WY0 + 1), (WX1 - 2, WY0 + 1), (WX0 + 1, WY1 - 1), (WX1 - 2, WY1 - 1),
             (WX0 + 2, 52), (WX0 + 2, 63), (WX1 - 3, 18), (WX1 - 3, 29)]:
    tower(x, y)

# ---------------------------------------------------------------- houses (props in blocks, streets between)


def houses(x0, y0, x1, y1, every=5, kinds=("cottage", "shed", "cottage")):
    i = 0
    for y in range(y0, y1, 4):
        for x in range(x0, x1, every):
            props.append([kinds[i % len(kinds)], x, y, (i % 2) == 1])
            i += 1


houses(9, 22, 22, 35, 4)               # north-west, by the bath houses (the baths' own ground is the mission's)
houses(40, 8, 47, 20, 4)               # under the castle, west of the market
houses(76, 8, 92, 33, 5)               # north-east quarter
houses(97, 30, 110, 37, 4)
houses(9, 48, 24, 54, 4)               # south-west, by the west gate road (the road itself kept clear: y 55-60)
houses(9, 63, 30, 80, 5)
houses(84, 48, 110, 80, 5)             # south-east
houses(32, 70, 42, 80, 4)

# ---------------------------------------------------------------- the Hauptmarkt (Advent market) and the Frauenkirche
props += [["chapel", 64, 13, False], ["chapel_tower", 68, 12, False]]
for i, (x, y) in enumerate([(50, 18), (54, 18), (58, 19), (62, 18), (66, 18), (70, 19), (50, 24), (70, 24), (52, 30), (68, 30)]):
    props.append(["stall" if i % 2 == 0 else "stall_small", x, y, i % 3 == 0])
props += [["well", 60, 26, False], ["banner_pole", 56, 26, False], ["cart_a", 47, 27, False], ["barrel_a", 73, 27, False],
          ["crate_apples", 64, 30, False], ["sacks_pile", 46, 31, False], ["flag", 60, 14, False]]

# ---------------------------------------------------------------- the castle: the keep on the rock
props += [["ruin_keep", 22, 12, False], ["ruin_pillar", 30, 9, False], ["flag", 26, 10, False], ["banner_pole", 17, 15, False]]

# ---------------------------------------------------------------- the mill island: the mills (their wheels in the ice)
props += [["windmill", 54, 39, False], ["windmill", 64, 39, False], ["shed", 54, 44, False], ["barrel_tall", 64, 44, False]]

# ---------------------------------------------------------------- the guild quarter (south): yard furniture at its edge
props += [["forge", 42, 60, False], ["crate_long", 44, 76, False], ["wagon", 78, 76, False], ["crates_pair", 80, 60, False],
          ["barrel_b", 41, 66, False], ["signpost", 34, 58, False], ["cart_c", 22, 57, True]]

# ---------------------------------------------------------------- the bath houses' yard and the east quarter's square
props += [["tub", 25, 36, False], ["tub_b", 18, 36, False], ["bucket", 22, 37, False],
          ["cross_stone", 100, 26, False], ["firewood", 106, 13, False]]

# ---------------------------------------------------------------- outside the west gate: the road to Fürth
props += [["signpost", 3, 53, False], ["cart_b", 2, 63, False]]
for x, y in [(1, 48), (2, 70), (1, 74)]:
    props.append(["pine", x, y, False])

starts = [[52, 64], [57, 40], [60, 22], [100, 16]]   # (hall-sized spots; the mission places its own buildings)
teams = [0, 1, 1, 1]

data = {
    "name": "nuremberg_advent", "size": [W, H], "cells": "".join("".join(r) for r in cells),
    "mirror": "off", "mix": "diag", "biome": "snow",
    "starts": starts, "teams": teams, "mode": "2v2", "halls": [],
    "props": props, "checked": True,
}
out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "maps", "nuremberg_advent.json")
with open(out, "w") as f:
    json.dump(data, f)
print("wrote", os.path.normpath(out), len(props), "props")
