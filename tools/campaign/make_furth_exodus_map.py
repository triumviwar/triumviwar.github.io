#!/usr/bin/env python3
"""Writes campaign/maps/furth_exodus.json, the map of Act 2's "The Exodus" (d02_exodus; the plan:
docs/campaign_act2_plan.md "d02_exodus"; what was built: docs/campaign_d02_build.md), in the MAP EDITOR's own format
(scripts/mapgen.gd). It is a04's Fürth (campaign/maps/furth_works.json, tools/campaign/make_furth_works_map.py) a year
and a half on, in the snow of February 2771, so it STARTS FROM THAT FILE (run make_furth_works_map.py first if it
changes):
  python3 tools/campaign/make_furth_exodus_map.py

What changes from a04's map (the east half, the works, the town and Nuremberg stay as they were):
  - WINTER: the snow biome (a02's Fürth was snow too).
  - THE REDNITZ BRIDGE: a timber bridge over the Rednitz west of Hollweg's barn (the only way west).
  - THE VALLEY ROAD: the forest west of the Rednitz is cut by a valley: the road runs west from the bridge, then south
    down the valley between the woods to the brook; THE WÜRZBURG TRACK comes down into the valley from the north edge
    (the commissary's riders' way round).
  - THE BROOK AND THE LAST BRIDGE: a frozen brook crosses the valley's foot from the Main to the woods; one bridge.
  - THE LANDING on the Main (the west edge, south): the barges' jetty, crates and boats. Woods close it round: past the
    brook bridge there is no other way in.
  - The east of the valley (the land south of the Rednitz's bend) is woods now, so the road is the only way to the Main.
"""
import json
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
SRC = os.path.join(ROOT, "campaign", "maps", "furth_works.json")

m = json.load(open(SRC))
W, H = m["size"]
cells = [list(m["cells"][y * W:(y + 1) * W]) for y in range(H)]
rng = random.Random(2771)


def fill(x0, y0, w, h, ch, keep_water=False):
    for y in range(max(0, y0), min(H, y0 + h)):
        for x in range(max(0, x0), min(W, x0 + w)):
            if keep_water and cells[y][x] == "w":
                continue
            cells[y][x] = ch


# ---------------------------------------------------------------- the woods west of the Rednitz: solid, then cut
fill(0, 0, 24, H, "t")
# the woods south of the Rednitz's bend down to the Main (the valley's east side): no way round the road
fill(22, 41, 12, H - 41, "t", keep_water=True)
fill(22, 24, 2, 18, "t")
# THE VALLEY ROAD: west from the bridge, then the valley south to the brook (a few clumps of trees for cover)
fill(8, 15, 16, 9, ".")            # the road west of the bridge
fill(7, 15, 15, 40, ".")           # the valley
# THE DRIFTS: snow-laden thickets across the valley, open at one end and then the other, so the road winds down in
# switchbacks (the carts' road is long, and the riders on the slopes see it all)
for (x, y, w, h) in [(7, 26, 11, 2), (11, 32, 11, 2), (7, 38, 11, 2), (11, 44, 11, 2), (7, 49, 10, 2)]:
    fill(x, y, w, h, "t")
# THE WÜRZBURG TRACK: from the north edge down into the valley
fill(13, 0, 4, 16, ".")
# THE REDNITZ BRIDGE (west of Hollweg's barn)
fill(24, 18, 7, 3, "f")
for y in range(18, 21):
    for x in range(22, 24):
        cells[y][x] = "."
# THE BROOK and THE LAST BRIDGE (frozen: water all the same), then THE LANDING and THE MAIN
fill(0, 54, 22, 2, "w")
fill(12, 54, 4, 2, "f")
fill(3, 56, 18, 18, ".")           # the landing ground
fill(0, 40, 3, H - 40, "w")        # the Main along the west edge
fill(3, 56, 1, 18, ".")
fill(0, 60, 3, 9, "w")
# the landing's jetty: a ford-like plank way into the river for the barges
fill(1, 62, 2, 4, "f")

# ---------------------------------------------------------------- props: a04's east half kept; the west made new
# (the mission's barns: tools/campaign/make_d02_mission.py BARNS; one cell more round each kept clear of props)
BARNS = [(30, 13, 6, 8), (34, 7, 6, 5), (44, 7, 6, 5), (54, 11, 5, 6), (43, 40, 6, 5), (49, 43, 6, 5), (47, 29, 6, 6)]
CLEAR = [(0, 0, 34, H)] + BARNS


def in_clear(x, y):
    return any(x0 <= x < x0 + w and y0 <= y < y0 + h for (x0, y0, w, h) in CLEAR)


props = [p for p in m["props"] if not in_clear(p[1], p[2])]


def free(x, y, n=1):
    return all(0 <= xx < W and 0 <= yy < H and cells[yy][xx] == "." for yy in range(y, y + n) for xx in range(x, x + n))


def add(name, x, y, flip=False):
    if free(x, y) and not any(p[1] == x and p[2] == y for p in props):
        props.append([name, x, y, flip])


# the road and the valley: snowed-in pines at the woods' edge, a waymark, a broken cart
for (n, x, y) in [("signpost", 21, 21), ("pine", 9, 17), ("pine", 20, 24), ("dead_tree", 10, 36), ("log", 16, 28), ("pine", 20, 47),
                  ("stump_moss", 11, 44), ("cart_a", 9, 31), ("signpost", 17, 52), ("dead_trunk", 18, 39)]:
    add(n, x, y)
# the Würzburg track: a cross by the way
add("cross_wood", 16, 5)
# the landing: the jetty's crates and barrels, the boats moored, a fire, the bargemen's sheds
for (n, x, y) in [("crates_pair", 5, 58), ("crate_long", 6, 66), ("barrel_b", 4, 60), ("barrel_tall", 4, 67), ("boat", 3, 63),
                  ("boat", 3, 69), ("shed", 12, 70), ("shed", 17, 69), ("sacks_pile", 9, 71), ("crate_open", 14, 58)]:
    add(n, x, y)

data = dict(m)
data.update({"name": "furth_exodus", "cells": "".join("".join(r) for r in cells), "biome": "snow", "props": props})
out = os.path.join(ROOT, "campaign", "maps", "furth_exodus.json")
with open(out, "w") as f:
    json.dump(data, f)
print("wrote", os.path.normpath(out), len(props), "props")
if __name__ == "__main__" and os.environ.get("ASCII"):
    for y in range(H):
        print("%2d %s" % (y, "".join(cells[y])))
