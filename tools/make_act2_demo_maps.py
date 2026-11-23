"""Three demo maps for Act 2's Brazilian biomes, in the map editor's format
(docs/act2_terrain_art.md): campaign/maps/demo_varzea.json, demo_highlands.json,
demo_sertao.json. Each is a 1v1 of 96 x 96, turned through its middle (the editor's TURN 180),
the mains on high ground with one ramp, two hall spots each, and the biome's own decorations.
The map editor's LOAD lists them under EXAMPLES; a mission can name them "campaign:demo_<biome>".

   python3 tools/make_act2_demo_maps.py"""
import json
import math
import os
import random

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "campaign", "maps")
W = H = 96
HALL = (5, 4)


class Map:
    def __init__(self, seed):
        self.c = [["."] * W for _ in range(H)]
        self.rng = random.Random(seed)
        self.props = []

    def get(self, x, y):
        return self.c[y][x] if 0 <= x < W and 0 <= y < H else "#"

    def set(self, x, y, v):
        if 0 <= x < W and 0 <= y < H:
            self.c[y][x] = v

    def blob(self, cx, cy, rx, ry, v, wobble=0.18, only=None):
        for y in range(int(cy - ry - 2), int(cy + ry + 3)):
            for x in range(int(cx - rx - 2), int(cx + rx + 3)):
                a = math.atan2(y - cy, x - cx)
                r = 1 + wobble * math.sin(3 * a + cx) * math.cos(2 * a + cy)
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= r * r:
                    if only is None or self.get(x, y) in only:
                        self.set(x, y, v)

    def line(self, pts, width, v, only=None):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
            for k in range(n + 1):
                t = k / n
                cx, cy = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
                for dy in range(-width, width + 1):
                    for dx in range(-width, width + 1):
                        if dx * dx + dy * dy <= width * width:
                            x, y = int(round(cx + dx)), int(round(cy + dy))
                            if only is None or self.get(x, y) in only:
                                self.set(x, y, v)

    def rect(self, x0, y0, x1, y1, v):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.set(x, y, v)

    def main(self):
        """Side A's main: a plateau in the top-left corner, one ramp down to the south-east."""
        self.blob(14, 14, 15, 13, "h", 0.08)
        self.rect(1, 1, 22, 20, "h")
        self.rect(19, 25, 21, 28, "r")            # the ramp, 3 wide, across the plateau's south edge
        for y in range(25, 29):                    # (high ground beside the ramp's lower part goes)
            for x in (17, 18, 22, 23):
                if self.get(x, y) == "h":
                    self.set(x, y, ".")

    def trees(self, n, cx, cy, spread, high=False, avoid=()):
        for _ in range(n):
            x = int(cx + self.rng.gauss(0, spread))
            y = int(cy + self.rng.gauss(0, spread))
            if self.get(x, y) == ("h" if high else ".") and not self.near(x, y, avoid, 3):
                self.set(x, y, "T" if high else "t")

    def near(self, x, y, kinds, r):
        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                if self.get(x + dx, y + dy) in kinds:
                    return True
        return False

    def mirror(self):
        """Side B is side A turned through the middle."""
        for y in range(H):
            for x in range(W):
                if y * W + x < (W * H) // 2:
                    self.c[H - 1 - y][W - 1 - x] = self.c[y][x]

    def scatter(self, names, n, spots, keep_out=10, near_kind=None):
        """Decorations on open ground of side A (mirrored later), off ramps and halls' land."""
        tries = 0
        placed = 0
        while placed < n and tries < n * 60:
            tries += 1
            x = self.rng.randrange(2, W - 2)
            y = self.rng.randrange(2, H - 2)
            if y * W + x >= (W * H) // 2 - W * 2:
                continue
            here = self.get(x, y)
            if here not in ".h" or self.near(x, y, "r", 2) or self.near(x, y, "wftTkK", 0):
                continue
            if near_kind and not self.near(x, y, near_kind, 3):
                continue
            if any(math.hypot(x + 0.5 - (s[0] + 2.5), y + 0.5 - (s[1] + 2.0)) < keep_out for s in spots):
                continue
            if any(abs(p[1] - x) < 2 and abs(p[2] - y) < 2 for p in self.props):
                continue
            self.props.append([self.rng.choice(names), x, y, self.rng.random() < 0.5])
            placed += 1

    def data(self, name, biome, starts, halls):
        cells = "".join("".join(r) for r in self.c)
        props = []
        for nm, x, y, flip in self.props:
            props.append([nm, x, y, flip])
            props.append([nm, W - 1 - x, H - 1 - y, not flip])
        tw = lambda s: [W - s[0] - HALL[0], H - s[1] - HALL[1]]
        st = [starts, tw(starts)]
        hl = []
        for h in halls:
            hl += [h, tw(h)]
        return {"name": name, "size": [W, H], "cells": cells, "mirror": "rotate", "mix": "diag",
                "biome": biome, "starts": st, "teams": [0, 1], "mode": "1v1", "halls": hl,
                "props": props, "checked": True,
                "about": "A demo of the %s ground (Act 2's Brazil, docs/act2_terrain_art.md)." % biome}


START = [9, 8]
HALLS = [[6, 40], [40, 12]]
SPOTS_A = [START] + HALLS


def clear_spots(m):
    for sx, sy in SPOTS_A:
        for y in range(sy - 1, sy + HALL[1] + 1):
            for x in range(sx - 1, sx + HALL[0] + 1):
                if m.get(x, y) in "tTkKwf":
                    m.set(x, y, "." if m.get(x, y) in "tkwf" else "h")


def varzea():
    m = Map(51)
    m.main()
    # the river: corner to corner through the middle, wide brown water
    river = [(96, 0), (78, 14), (62, 30), (52, 42), (48, 48)]
    m.line(river, 3, "w", only=".")
    # side channels and flooded pools between the trees
    for cx, cy, rx, ry in ((70, 38, 6, 4), (30, 56, 5, 4), (56, 18, 4, 3), (20, 44, 3, 2)):
        m.blob(cx, cy, rx, ry, "w", 0.25, only=".")
    m.line([(62, 30), (72, 40)], 1, "w", only=".")
    # fords: in the middle and on each side
    m.line([(44, 44), (52, 52)], 3, "f", only="w")
    m.line([(72, 18), (78, 24)], 2, "f", only="w")
    # the flooded forest: trees all along the water
    for cx, cy in ((60, 22), (66, 34), (54, 36), (74, 44), (34, 54), (24, 50), (46, 30), (36, 38), (80, 8)):
        m.trees(40, cx, cy, 4, avoid="r")
    m.trees(10, 6, 24, 3, high=True)
    clear_spots(m)
    m.mirror()
    m.scatter(["aninga", "floating_grass", "aninga", "varzea_snag"], 26, SPOTS_A, near_kind="w")
    m.scatter(["varzea_tree", "buriti", "buriti"], 10, SPOTS_A)
    m.scatter(["grass_reed", "log_moss", "reeds", "aninga"], 16, SPOTS_A)
    m.props += [["boat", 30, 60, False], ["cross_wood", 33, 63, False], ["drying_rack", 35, 61, False]]
    return m.data("demo_varzea", "varzea", START, HALLS)


def highlands():
    m = Map(52)
    m.main()
    # a second plateau of grey rock on each side, two ramps
    m.blob(66, 22, 9, 6, "h", 0.12)
    m.rect(64, 27, 66, 30, "r")
    m.rect(54, 21, 57, 23, "r")
    # a cold stream from the north edge to the middle (and on, turned, to the south edge)
    m.line([(38, 0), (36, 14), (40, 28), (46, 40), (48, 48)], 2, "w", only=".")
    m.line([(32, 10), (40, 12)], 2, "f", only="w")
    m.line([(40, 34), (46, 32)], 2, "f", only="w")
    # araucaria groves and grey outcrops
    for cx, cy in ((28, 40), (60, 40), (14, 30), (80, 36), (80, 8), (54, 6), (28, 24)):
        m.trees(22, cx, cy, 3.5, avoid="rw")
    m.trees(14, 68, 20, 3, high=True, avoid="r")
    for cx, cy in ((24, 34), (52, 32), (8, 30), (76, 26)):
        for _ in range(5):
            x, y = cx + m.rng.randint(-2, 2), cy + m.rng.randint(-2, 2)
            if m.get(x, y) == "." and not m.near(x, y, "r", 2):
                m.set(x, y, "k")
    clear_spots(m)
    m.mirror()
    m.scatter(["cold_tussock", "cold_tussock", "highland_boulder", "stones"], 30, SPOTS_A)
    m.scatter(["mist_wisp"], 12, SPOTS_A, keep_out=8)
    m.scatter(["araucaria", "araucaria_young"], 10, SPOTS_A)
    return m.data("demo_highlands", "highlands", START, HALLS)


def sertao():
    m = Map(53)
    m.main()
    # a mesa in the middle of the map (its own twin), ramps east and west
    m.blob(48, 48, 9, 6, "h", 0.12)
    m.rect(37, 46, 40, 48, "r")
    # a dry river: thin water with wide sandy fords, corner to corner
    m.line([(96, 6), (80, 18), (66, 24), (60, 34), (56, 38)], 1, "w", only=".")
    m.line([(70, 20), (74, 24)], 2, "f", only="w")
    # thin scrub, few trees, rocks
    for cx, cy in ((30, 36), (64, 12), (18, 60), (52, 64), (76, 36)):
        m.trees(9, cx, cy, 4, avoid="r")
    for cx, cy in ((26, 50), (62, 28), (44, 20)):
        for _ in range(6):
            x, y = cx + m.rng.randint(-3, 3), cy + m.rng.randint(-2, 2)
            if m.get(x, y) == "." and not m.near(x, y, "r", 2):
                m.set(x, y, "k")
    clear_spots(m)
    m.mirror()
    m.scatter(["caatinga_bush", "caatinga_bush", "xique_xique", "sertao_stones", "ox_skull", "branches"], 34, SPOTS_A)
    m.scatter(["mandacaru", "mandacaru", "caatinga_tree"], 12, SPOTS_A)
    m.props += [["campfire", 30, 70, False], ["cart_b", 33, 70, False], ["ox_skull", 28, 71, True],
                ["sacks", 31, 68, False], ["fence", 34, 72, False]]
    return m.data("demo_sertao", "sertao", START, HALLS)


def main():
    for d in (varzea(), highlands(), sertao()):
        with open(os.path.join(OUT, d["name"] + ".json"), "w") as f:
            json.dump(d, f)
        print(d["name"], len(d["props"]), "decorations")
        for y in range(0, H, 3):
            print("  " + d["cells"][y * W:(y + 1) * W:2])


if __name__ == "__main__":
    main()
