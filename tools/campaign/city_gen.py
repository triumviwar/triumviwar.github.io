#!/usr/bin/env python3
"""THE CITY GENERATOR (docs/city_generator.md): a town for a campaign map, in the MAP EDITOR's own format (scripts/mapgen.gd:
one letter per cell, . low, h high, r ramp, w water, f ford, t tree, k rock; props [name, x, y, flip]). Written for
Act 1's Lyon (a01_presses, tools/campaign/make_lyon_map.py) and meant for Paris (a06), Rome (a07) and later towns.

Everything comes from a SEED and a few calls, so the same calls give the same town every time (random.Random(seed),
nothing else is random). A map script builds a town in this order:

    city = City("lyon_presses", 128, 96, seed=1768, biome="grass")
    city.frame()                                     # trees round the edge (or walls, or nothing)
    city.river("saone", [(34, 0), ...], 4)           # rivers: water along a polyline
    city.hill("croix_rousse", [x0, y0, x1, y1])      # high ground ...
    city.ramp("stair_1", [x0, y0, x1, y1])           # ... and the ramps (stairs) up it
    city.district("presqu_ile", [x0, y0, x1, y1], block=(6, 10), street=2)   # a grid of streets and house blocks
    city.square("bellecour", [x, y, w, h])           # open squares (houses cleared, an area kept)
    city.bridge("pont_1", "saone", y=46)             # a ford across a river at a row (or column), streets to it
    city.courtyard("press_yard", block_rect, inner)  # a block with a hidden yard reached only by ...
    city.traboule("tr_1", [x, y], "n")               # ... covered passages (1 cell) through the houses
    city.lot("cand_1", "presqu_ile")                 # a free spot (2 x 2 + its ring) for a mission's building
    city.wall([(x, y), ...], gates=[...])            # a town wall of rock with towers, gates left open
    city.houses()                                    # LAST: every block cell not kept free gets a house's foot
    city.save()                                      # campaign/maps/<name>.json (and check() first)

The houses are decorations (props) whose feet block the cell, two cells wide, so a block is solid and the streets are
the only ways through, except where a traboule or a lot was kept free. A mission script imports the map script and
reads the town's `areas` (squares, bridges, stairs, quarters, traboules, yards) and `lots` from the same calls: no file
next to the map.
"""
import json
import math
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
WALK = {".", "h", "r", "f"}              # cells a unit may stand on (before props)
HOUSES = ("cottage", "shed", "cottage", "cottage", "shed")    # the house props, in the rng's turn (2 cells wide feet)


class City:
    def __init__(self, name, w, h, seed, biome="grass"):
        self.name = name
        self.w, self.h = w, h
        self.seed = seed
        self.biome = biome
        self.rng = random.Random(seed)
        self.cells = [["."] * w for _ in range(h)]
        self.props = []
        self.foot = set()                # cells a prop's foot takes
        self.keep = set()                # cells no house may take (streets are simply never in a block)
        self.blocks = []                 # {"rect": [x0, y0, x1, y1] (x1, y1 not in it), "district": name}
        self.areas = {}                  # name -> [x, y, w, h] (the mission's areas)
        self.lots = {}                   # name -> {"at": [x, y], "size": [w, h], "district": name}
        self.rivers = {}                 # name -> {"pts", "width"}
        self.bridges = {}                # name -> {"river", "cells", "dir"}
        self.squares = {}
        self.traboules = {}
        self.doors = {}                  # a traboule's name -> its middle cell (a mission may shut it there)
        self.starts = [[w // 4, h // 2], [3 * w // 4, h // 2]]
        self.reserved = []               # [x0, y0, x1, y1]: no district block comes within a street of these

    # ------------------------------------------------------------------ cells
    def ok(self, x, y):
        return 0 <= x < self.w and 0 <= y < self.h

    def get(self, x, y):
        return self.cells[y][x] if self.ok(x, y) else "#"

    def put(self, x, y, ch):
        if self.ok(x, y):
            self.cells[y][x] = ch

    def fill(self, r, ch, only=None):
        x0, y0, x1, y1 = r
        for y in range(y0, y1):
            for x in range(x0, x1):
                if only is None or self.get(x, y) in only:
                    self.put(x, y, ch)

    def keep_rect(self, r):
        x0, y0, x1, y1 = r
        for y in range(y0, y1):
            for x in range(x0, x1):
                self.keep.add((x, y))

    def area(self, name, r):
        """An area for the mission, from [x0, y0, x1, y1] (stored as the engine's [x, y, w, h])."""
        x0, y0, x1, y1 = r
        self.areas[name] = [x0, y0, x1 - x0, y1 - y0]

    # ------------------------------------------------------------------ land and water
    def frame(self, depth=2, ch="t"):
        """A ragged border of trees (or rock) round the map."""
        for x in range(self.w):
            for y in range(self.h):
                d = min(x, y, self.w - 1 - x, self.h - 1 - y)
                if d < depth - 1 or (d == depth - 1 and self.rng.random() < 0.5):
                    self.put(x, y, ch)

    def river(self, name, pts, width, ch="w"):
        """Water along a polyline, `width` cells across (a disc stamped every half cell)."""
        self.rivers[name] = {"pts": pts, "width": width}
        r = width / 2.0
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
            for i in range(n + 1):
                cx = x0 + (x1 - x0) * i / n
                cy = y0 + (y1 - y0) * i / n
                for y in range(int(cy - r) - 1, int(cy + r) + 2):
                    for x in range(int(cx - r) - 1, int(cx + r) + 2):
                        if (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 <= r * r:
                            self.put(x, y, ch)

    def river_x(self, name, y):
        """Where a river's line crosses row y (a river running north-south), or None."""
        pts = self.rivers[name]["pts"]
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            if min(ay, by) <= y <= max(ay, by) and ay != by:
                return ax + (bx - ax) * (y - ay) / (by - ay)
        return None

    def river_y(self, name, x):
        pts = self.rivers[name]["pts"]
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            if min(ax, bx) <= x <= max(ax, bx) and ax != bx:
                return ay + (by - ay) * (x - ax) / (bx - ax)
        return None

    def hill(self, name, r, ch="h"):
        """High ground over a rectangle (water and trees left as they are). Its edges are cliffs: add ramps."""
        self.fill(r, ch, only={"."})
        self.area(name, r)

    # ------------------------------------------------------------------ hills (Act 2's d01_minas: a hill town)
    def hill_blob(self, name, cx, cy, rx, ry, wob=0.1):
        """High ground over a rounded hill (an ellipse with a gentle wobble, the same from the same numbers: no rng), so
        a hill town's edges are not ruler-straight. Water and trees are left as they are; the edges are cliffs."""
        for y in range(int(cy - ry - 2), int(cy + ry + 3)):
            for x in range(int(cx - rx - 2), int(cx + rx + 3)):
                a = math.atan2(y - cy, x - cx)
                k = 1 + wob * math.sin(3 * a + cx * 0.7) * math.cos(2 * a + cy * 0.3)
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= k * k and self.get(x, y) == ".":
                    self.put(x, y, "h")
        self.area(name, [int(cx - rx), int(cy - ry), int(cx + rx) + 1, int(cy + ry) + 1])

    def stairs(self, name, at, way, width=3):
        """A town's STAIRS down a hill's edge: from `at` (a cell on the high ground) going `way` (n, s, e, w) to the
        edge, `width` cells across. Where the edge is ragged the high ground is squared off first, so the stairs (one
        row of ramp on the low side) meet a straight edge. Returns the ramp's rect; the area is the ramp's with a cell
        round it, as ramp()."""
        dx, dy = {"n": (0, -1), "s": (0, 1), "e": (1, 0), "w": (-1, 0)}[way]
        x, y = at
        lanes = [(x + i * abs(dy), y + i * abs(dx)) for i in range(width)]     # (across the way)
        ends = []
        for (lx, ly) in lanes:
            px, py = lx, ly
            while self.get(px + dx, py + dy) == "h":
                px += dx
                py += dy
            ends.append((px, py))
        far = max(ends, key=lambda c: c[0] * dx + c[1] * dy)
        reach = far[0] * dx + far[1] * dy
        cells = []
        for (lx, ly), (ex, ey) in zip(lanes, ends):
            while ex * dx + ey * dy < reach:          # (square the edge off with high ground)
                ex += dx
                ey += dy
                self.put(ex, ey, "h")
            cells.append((ex + dx, ey + dy))
        xs = [c[0] for c in cells]
        ys = [c[1] for c in cells]
        r = [min(xs), min(ys), max(xs) + 1, max(ys) + 1]
        self.ramp(name, r)
        return r

    def ramp(self, name, r):
        """A ramp (a town's stairs) on [x0, y0, x1, y1]: the low cells next to the high ground's edge."""
        self.fill(r, "r")
        x0, y0, x1, y1 = r
        self.keep_rect([x0 - 1, y0 - 1, x1 + 1, y1 + 1])
        self.area(name, [x0 - 1, y0 - 2, x1 + 1, y1 + 2])

    # ------------------------------------------------------------------ streets and blocks
    def district(self, name, r, block=(6, 10), street=2, main_every=3, jitter=1):
        """A grid of house blocks inside r, streets between (`street` cells wide, every `main_every`-th one a cell
        wider). `block` = (least, most) cells a block runs either way. Cells of water, rock, trees or ramps are never
        in a block; a block keeps to one height where it can (a block across a hill's edge is cut at the edge)."""
        x0, y0, x1, y1 = r
        xs = self._cuts(x0, x1, block, street, main_every, jitter)
        ys = self._cuts(y0, y1, block, street, main_every, jitter)
        n = 0
        for (bx0, bx1) in xs:
            for (by0, by1) in ys:
                for piece in self._split_by_height([bx0, by0, bx1, by1]):
                    if any(_meets(piece, rr, street) for rr in self.reserved):
                        continue           # (a block of its own stands there: block() / reserve())
                    if (piece[2] - piece[0]) >= 2 and (piece[3] - piece[1]) >= 2:
                        self.blocks.append({"rect": piece, "district": name})
                        n += 1
        self.area(name, r)
        return n

    def reserve(self, r):
        """Keep the districts' blocks off r (and a street round it): for a block() of its own, or open ground."""
        self.reserved.append(list(r))

    def block(self, name, r, district=""):
        """A block of houses exactly on r (reserved from the districts: call it before them), e.g. one with a hidden
        yard (courtyard) and traboules into it."""
        self.reserve(r)
        self.blocks.append({"rect": list(r), "district": district or name})
        self.area(name, r)

    def traboules_in(self, district, n, prefix="traboule"):
        """n covered passages straight across blocks of a district (each through the middle of the block's short way),
        so the streets have shortcuts. Returns their names."""
        bs = [b for b in self.blocks if b["district"] == district and min(b["rect"][2] - b["rect"][0], b["rect"][3] - b["rect"][1]) >= 4]
        self.rng.shuffle(bs)
        out = []
        for i, b in enumerate(bs[:n]):
            x0, y0, x1, y1 = b["rect"]
            nm = "%s_%d" % (prefix, i + 1)
            if x1 - x0 >= y1 - y0:
                self.traboule(nm, [(x0 + x1) // 2, y0], "s", length=y1 - y0)
            else:
                self.traboule(nm, [x0, (y0 + y1) // 2], "e", length=x1 - x0)
            out.append(nm)
        return out

    def _cuts(self, a, b, block, street, main_every, jitter):
        out = []
        p = a
        i = 0
        while p < b:
            size = self.rng.randint(block[0], block[1])
            q = min(b, p + size)
            if b - q < block[0]:
                q = b
            out.append((p, q))
            i += 1
            p = q + street + (1 if main_every and i % main_every == 0 else 0) + (self.rng.randint(0, jitter) if jitter else 0)
        return out

    def _split_by_height(self, r):
        """A block cut where it crosses from low to high ground (one row of street left at the cut)."""
        x0, y0, x1, y1 = r
        rows = []
        for y in range(y0, y1):
            hs = [self.get(x, y) for x in range(x0, x1)]
            rows.append("h" if hs.count("h") > len(hs) // 2 else ".")
        pieces = []
        start = y0
        for i in range(1, len(rows) + 1):
            if i == len(rows) or rows[i] != rows[i - 1]:
                end = y0 + i
                if i < len(rows):
                    end -= 1           # (a row of street between the two)
                if end - start >= 2:
                    pieces.append([x0, start, x1, end])
                start = y0 + i
        return pieces

    def square(self, name, r, props=()):
        """An open square: no houses on it (they are cleared), an area of its name, a few props [name, x, y]."""
        self.keep_rect(r)
        self.area(name, r)
        self.squares[name] = r
        for p in props:
            self.prop(p[0], p[1], p[2], p[3] if len(p) > 3 else False)

    def street(self, name, r):
        """A street cut through whatever blocks are there (kept free)."""
        self.keep_rect(r)
        if name:
            self.area(name, r)

    def bridge(self, name, river, y=None, x=None, width=3, approach=4):
        """A crossing (ford cells) over a river at row y (a river running north-south) or column x; the banks at both
        ends kept free `approach` cells so a street reaches it. Its area covers the crossing and a cell beyond."""
        cells = []
        if y is not None:
            cx = self.river_x(river, y)
            for yy in range(y - width // 2, y - width // 2 + width):
                xx = int(cx)
                while self.get(xx, yy) in ("w", "f"):
                    xx -= 1
                left = xx + 1
                xx = int(cx)
                while self.get(xx, yy) in ("w", "f"):
                    xx += 1
                right = xx
                for c in range(left, right):
                    self.put(c, yy, "f")
                    cells.append((c, yy))
            xs = [c[0] for c in cells]
            r = [min(xs) - approach, y - width // 2, max(xs) + 1 + approach, y - width // 2 + width]
        else:
            cy = self.river_y(river, x)
            for xx in range(x - width // 2, x - width // 2 + width):
                yy = int(cy)
                while self.get(xx, yy) in ("w", "f"):
                    yy -= 1
                top = yy + 1
                yy = int(cy)
                while self.get(xx, yy) in ("w", "f"):
                    yy += 1
                for c in range(top, yy):
                    self.put(xx, c, "f")
                    cells.append((xx, c))
            ys = [c[1] for c in cells]
            r = [x - width // 2, min(ys) - approach, x - width // 2 + width, max(ys) + 1 + approach]
        self.keep_rect(r)
        self.area(name, [r[0], r[1] - 1, r[2], r[3] + 1] if y is not None else [r[0] - 1, r[1], r[2] + 1, r[3]])
        self.bridges[name] = {"river": river, "cells": cells, "dir": "ew" if y is not None else "ns"}

    def courtyard(self, name, inner):
        """A hidden yard: the cells of `inner` kept free inside whatever block holds them (the houses round it wall
        it in). Reach it with traboules."""
        self.keep_rect(inner)
        self.area(name, inner)

    def traboule(self, name, at, way, length=None):
        """A covered passage (one cell wide) from a street into a block: from `at` going `way` (n, s, e, w) until it
        meets free ground again (a yard, the next street), or `length` cells. Its area covers it."""
        dx, dy = {"n": (0, -1), "s": (0, 1), "e": (1, 0), "w": (-1, 0)}[way]
        x, y = at
        cells = []
        blocks = [b["rect"] for b in self.blocks]
        inb = lambda cx, cy: any(b[0] <= cx < b[2] and b[1] <= cy < b[3] for b in blocks)
        steps = 0
        while self.ok(x, y):
            if length is not None and steps >= length:
                break
            if length is None and steps > 0 and (not inb(x, y) or (x, y) in self.keep) and cells:
                break
            cells.append((x, y))
            self.keep.add((x, y))
            x += dx
            y += dy
            steps += 1
        xs = [c[0] for c in cells]
        ys = [c[1] for c in cells]
        self.traboules[name] = cells
        self.doors[name] = list(cells[len(cells) // 2])
        self.area(name, [min(xs), min(ys), max(xs) + 1, max(ys) + 1])
        return cells

    def lot(self, name, district=None, size=(2, 2), near=None, at=None):
        """A free spot for a mission's building: a footprint of `size` at a corner of a block (in `district`, or the
        block nearest `near` [x, y]) with the free ring round it the engine wants (MissionRun._footprint_ok), on one
        height. Returns its top-left cell; the mission places a building with "at": that cell."""
        if at is not None:
            # (a lot exactly here: in a yard, on a square)
            cx, cy = at
            self.keep_rect([cx - 1, cy - 1, cx + size[0] + 1, cy + size[1] + 1])
            self.lots[name] = {"at": [cx, cy], "size": list(size), "district": district or ""}
            self.area(name, [cx - 1, cy - 1, cx + size[0] + 1, cy + size[1] + 1])
            return [cx, cy]
        cand = []
        for b in self.blocks:
            if district and b["district"] != district:
                continue
            x0, y0, x1, y1 = b["rect"]
            if x1 - x0 < size[0] + 2 or y1 - y0 < size[1] + 2:
                continue
            for (cx, cy) in [(x0, y0), (x1 - size[0], y0), (x0, y1 - size[1]), (x1 - size[0], y1 - size[1])]:
                ring = [(x, y) for y in range(cy - 1, cy + size[1] + 1) for x in range(cx - 1, cx + size[0] + 1)]
                hs = {self.get(x, y) for (x, y) in ring}
                if not (hs <= {"."} or hs <= {"h"}):
                    continue
                if any((x, y) in self.keep for (x, y) in ring if b["rect"][0] <= x < b["rect"][2] and b["rect"][1] <= y < b["rect"][3]):
                    continue
                d = 0 if near is None else (cx - near[0]) ** 2 + (cy - near[1]) ** 2
                cand.append((d, self.rng.random(), cx, cy))
        if not cand:
            raise ValueError("no lot for %s in %s" % (name, district))
        cand.sort()
        pick = cand[0] if near is not None else cand[int(self.rng.random() * len(cand))]
        cx, cy = pick[2], pick[3]
        self.keep_rect([cx - 1, cy - 1, cx + size[0] + 1, cy + size[1] + 1])
        self.lots[name] = {"at": [cx, cy], "size": list(size), "district": district or ""}
        self.area(name, [cx - 1, cy - 1, cx + size[0] + 1, cy + size[1] + 1])
        return [cx, cy]

    def wall(self, pts, gates=(), towers_every=6):
        """A town wall of rock along a polyline, open where a gate is ([x, y] cells: a 3-cell gap round each), towers
        (ruin props) along it."""
        gate_cells = set()
        for gx, gy in gates:
            for d in range(-1, 2):
                gate_cells.add((gx + d, gy))
                gate_cells.add((gx, gy + d))
        i = 0
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = max(abs(x1 - x0), abs(y1 - y0))
            for s in range(n + 1):
                x = round(x0 + (x1 - x0) * s / max(n, 1))
                y = round(y0 + (y1 - y0) * s / max(n, 1))
                if (x, y) in gate_cells or self.get(x, y) in ("w", "f"):
                    continue
                self.put(x, y, "k")
                self.keep.add((x, y))
                i += 1
        for gx, gy in gates:
            for d in range(-1, 2):
                for c in [(gx + d, gy), (gx, gy + d)]:
                    if self.get(*c) == "k":
                        self.put(c[0], c[1], ".")

    # ------------------------------------------------------------------ props
    def prop(self, name, x, y, flip=False, width=None):
        """A decoration at its foot cell (refused on water, rock, ramps or another foot, as the map loader does)."""
        w = width if width is not None else PROP_W.get(name, 0)
        lo, hi = -((w - 1) // 2), w - (w - 1) // 2          # (as MapGen.prop_foot: GDScript's division)
        feet = [(x + dx, y) for dx in range(lo, hi)] if w > 0 else []
        if w >= 3:
            feet += [(x + dx, y - 1) for dx in range(lo, hi)]
        if not self.ok(x, y) or self.get(x, y) in ("w", "f"):
            return False
        for (fx, fy) in feet:
            if not self.ok(fx, fy) or self.get(fx, fy) not in WALK or self.get(fx, fy) in ("r", "f") or (fx, fy) in self.foot:
                return False
        self.props.append([name, x, y, bool(flip)])
        for f in feet:
            self.foot.add(f)
        return True

    def houses(self, kinds=HOUSES, gap=0.0):
        """Every block cell not kept free gets a house's foot (two cells wide, rows staggered), so blocks are solid.
        `gap`: the chance a pair of cells is left as a garden instead (it must not open the block: only inner rows)."""
        n = 0
        for b in self.blocks:
            x0, y0, x1, y1 = b["rect"]
            for y in range(y0, y1):
                x = x0 if (y - y0) % 2 == 0 else x0 + (1 if x1 - x0 > 2 else 0)
                if x > x0 and self._house_cell(x0, y):
                    # (a staggered row starts with one cell: a shed's foot is two wide, so a lone cell gets a well)
                    self.prop("well", x0, y, width=1)
                while x < x1:
                    if x + 1 < x1 and self._house_cell(x, y) and self._house_cell(x + 1, y):
                        inner = y0 < y < y1 - 1 and x0 < x < x1 - 2
                        if inner and gap and self.rng.random() < gap:
                            x += 2
                            continue
                        k = kinds[int(self.rng.random() * len(kinds))]
                        if self.prop(k, x, y, self.rng.random() < 0.5, width=2):
                            n += 1
                        x += 2
                    else:
                        if self._house_cell(x, y):
                            self.prop("well", x, y, width=1)      # (a single cell left: a well's foot fills it)
                        x += 1
        return n

    def _house_cell(self, x, y):
        return self.get(x, y) in (".", "h") and (x, y) not in self.keep and (x, y) not in self.foot

    # ------------------------------------------------------------------ checks and output
    def walkable(self, x, y):
        return self.get(x, y) in WALK and (x, y) not in self.foot

    def reach(self, start):
        """The cells a unit can walk to from `start` (four ways; low and high ground meet only on a ramp)."""
        lv = lambda c: 1 if c == "h" else (2 if c == "r" else 0)
        seen = {tuple(start)}
        todo = [tuple(start)]
        while todo:
            x, y = todo.pop()
            a = lv(self.get(x, y))
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if (nx, ny) in seen or not self.walkable(nx, ny):
                    continue
                b = lv(self.get(nx, ny))
                if a != b and a != 2 and b != 2:
                    continue
                seen.add((nx, ny))
                todo.append((nx, ny))
        return seen

    def check(self, start, must=()):
        """Problems ([] none): every area in `must` (names; all the squares, bridges and lots when empty) has a cell
        a unit can walk to from `start`."""
        got = self.reach(start)
        names = list(must) or (list(self.squares) + list(self.bridges) + list(self.lots))
        out = []
        for nm in names:
            x, y, w, h = self.areas[nm]
            if not any((xx, yy) in got for yy in range(y, y + h) for xx in range(x, x + w)):
                out.append("area %s can't be reached" % nm)
        return out

    def data(self):
        return {"name": self.name, "size": [self.w, self.h], "cells": "".join("".join(r) for r in self.cells),
                "mirror": "off", "mix": "diag", "biome": self.biome, "starts": self.starts, "teams": [0, 1],
                "mode": "1v1", "halls": [], "props": self.props, "checked": True}

    def save(self, out=None):
        out = out or os.path.join(ROOT, "campaign", "maps", self.name + ".json")
        with open(out, "w") as f:
            json.dump(self.data(), f)
        return out

    def ascii(self):
        """A text picture (houses #, kept free cells as they are): for a look while writing a map script."""
        rows = []
        for y in range(self.h):
            row = []
            for x in range(self.w):
                c = self.get(x, y)
                if (x, y) in self.foot:
                    c = "#"
                row.append(c)
            rows.append("".join(row))
        return "\n".join(rows)


def _meets(a, b, pad=0):
    return a[0] < b[2] + pad and b[0] - pad < a[2] and a[1] < b[3] + pad and b[1] - pad < a[3]


# the props' foot widths (scripts/prop_data.gd, the third number): only the ones a town uses need to be here
PROP_W = {"cottage": 2, "shed": 2, "chapel": 2, "chapel_tower": 1, "well": 1, "stall": 2, "windmill": 1, "oven": 1,
          "ruin_wall": 2, "ruin_tower": 2, "ruin_keep": 3, "arch": 2, "arch_big": 2, "column": 1, "ruin_pillar": 1,
          "tent_white": 2, "tent_red": 2, "tent_blue": 2, "tent_round": 2, "haystack": 1, "wagon": 2}


def _read_prop_widths():
    """The real widths from scripts/prop_data.gd (PROP_W is only the fallback)."""
    import re
    p = os.path.join(ROOT, "scripts", "prop_data.gd")
    try:
        s = open(p).read()
    except OSError:
        return
    for m in re.finditer(r'"(\w+)": \[(\d+), (\d+), (\d+)\]', s):
        PROP_W[m.group(1)] = int(m.group(4))


_read_prop_widths()


def demo(seed):
    """A small town using every call (the test's: tools/test_city_gen.gd; also a starting point for a new town): a river
    running north-south with two bridges, a canal running east-west with one, a hill with stairs, a walled quarter
    with two gates, two districts, squares, a hidden yard with traboules, lots."""
    c = City("city_demo", 72, 56, seed, biome="grass")
    c.frame(2, "t")
    c.river("river", [(36, 0), (34, 20), (37, 40), (35, 56)], 4)
    c.river("canal", [(0, 30), (20, 31), (33, 30)], 3)
    c.hill("hill", [44, 3, 70, 16])
    c.ramp("stair_1", [50, 16, 54, 17])
    c.ramp("stair_2", [62, 16, 66, 17])
    c.block("yard_block", [8, 8, 20, 18], "yard")
    c.district("west", [3, 3, 32, 52], block=(5, 8))
    c.district("east", [41, 18, 70, 53], block=(5, 8))
    c.district("hilltop", [45, 4, 69, 15], block=(4, 6))
    c.square("market", [16, 38, 26, 46], props=[["well", 20, 42]])
    c.square("east_square", [50, 30, 60, 38])
    c.bridge("bridge_n", "river", y=12)
    c.bridge("bridge_s", "river", y=44)
    c.bridge("canal_bridge", "canal", x=12)
    c.courtyard("yard", [11, 11, 17, 15])
    c.traboule("trab_1", [14, 17], "n")
    c.traboule("trab_2", [19, 12], "w")
    c.traboules_in("west", 3)
    c.wall([(42, 20), (42, 52)], gates=[(42, 34)])
    for i in range(4):
        c.lot("lot_%d" % (i + 1), "east" if i % 2 else "west")
    c.lot("hill_lot", "hilltop")
    c.houses()
    c.starts = [[55, 34], [20, 42]]
    return c


if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    seed = int(args[args.index("--demo") + 1]) if "--demo" in args else 1
    city = demo(seed)
    out = args[args.index("--out") + 1] if "--out" in args else None
    probs = city.check((55, 34))
    if probs:
        print("PROBLEMS:", probs)
        sys.exit(1)
    if out:
        city.save(out)
        print("wrote", out, len(city.props), "props")
    if "--ascii" in args:
        print(city.ascii())
