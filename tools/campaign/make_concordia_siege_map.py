#!/usr/bin/env python3
"""Writes campaign/maps/concordia_siege.json, the map of Act 2's "The Siege of Concórdia" (d11_siege; the plan:
docs/campaign_act2_plan.md "d11_siege"; what was built: docs/campaign_d11_build.md), with THE CITY GENERATOR
(tools/campaign/city_gen.py). Rebuild:
  python3 tools/campaign/make_concordia_siege_map.py            (add --ascii for a text picture)
The mission script (make_d11_mission.py) imports build() and the names below: change the town here, run both.

Concórdia in 2780, seven years after its founding: d07's city (tools/campaign/make_concordia_city_map.py: the same
quarters, the mine hill, the great spring, the council square, the stream) moved east by DX cells, with a TOWN WALL
(of timber on rock footings: the map's rock) along its west side facing the plateau, and the PLATEAU'S EDGE west of it
where the Crown's southern column camps. 176 x 96 cells (north up), seed 2780, THE HIGHLANDS biome.
  - THE CAMP (west): the column's depot (the mission's buildings), the OLD MINE'S MOUTH in the north of the camp (an
    adit of the dead mine: its galleries run east under the wall to the great spring's tower), spoil heaps, pines.
  - THE SIEGE LINES (between the camp and the wall): three battery sites facing the three gates (north, west and south),
    open ground for the earthworks (the mission's palisade sites).
  - THE WALL (x = WALL_X) with three GATES (3-cell gaps: the mission's gate pieces), two UNFINISHED STRETCHES (gaps: the
    mission's scaffolding, or finished wall when the city has grown) and a POSTERN by the old Nuremberg quarter.
  - THE CITY (east): d07's town. The old Nuremberg quarter (north-west inside the wall) is the city's arsenal now (the
    mission's works on d07's meshed layout); the council square; the mine hill with the GREAT SPRING in its yard.
  - THE STREAM along the south, out of the city and on under the camp's south edge: its two fords are inside the wall.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from city_gen import City   # noqa: E402
import make_concordia_city_map as d07   # noqa: E402  (the city of 2777: its layout, moved)

W, H = 176, 96
SEED = 2780
DX, DY = 52, 4                              # d07's city moved this far (east, south)
WALL_X = 53                                 # the town wall's column
GATES = {"north_gate": 24, "west_gate": 57, "south_gate": 76}      # gate rows (3-cell gaps round them)
BREACHES = {"breach_n": 12, "breach_s": 67}                         # the wall's unfinished stretches (FRESH: scaffolding)
POSTERN = 40                                                         # the postern by the old quarter
MINE = [24, 12]                             # the old mine's mouth (an adit at the plateau's edge, in the camp's north)


def sh(p):
    """A d07 cell moved into this map."""
    return [p[0] + DX, p[1] + DY]


def shr(r):
    """A d07 rect [x0, y0, x1, y1] moved."""
    return [r[0] + DX, r[1] + DY, r[2] + DX, r[3] + DY]


SPRING = sh(d07.SPRING)                     # THE GREAT SPRING's tower (a Clocktower's 5 x 4) on the mine hill
HALL = sh(d07.HALL)                         # the council hall
TOWER = sh(d07.TOWER)                       # the arsenal's tower (the old Nuremberg quarter, d07's meshed layout)
ESCAPEMENT, LIGHT_WORKS, HEAVY_WORKS = sh(d07.ESCAPEMENT), sh(d07.LIGHT_WORKS), sh(d07.HEAVY_WORKS)
MAINSPRING, AVIARY, PRESS = sh(d07.MAINSPRING), sh(d07.AVIARY), sh(d07.PRESS)
REGULATORS = [sh(p) for p in d07.REGULATORS]
WORKS = {k: (d, kind, size, tuple(sh(near))) for k, (d, kind, size, near) in d07.WORKS.items()}


def wall_cells():
    """The wall's open cells (gates, breaches, the postern): {name: [[x, y], ...]} (3 cells each, down the column)."""
    out = {}
    for nm, y in list(GATES.items()) + list(BREACHES.items()) + [("postern", POSTERN)]:
        out[nm] = [[WALL_X, y + d] for d in (-1, 0, 1)]
    return out


def build():
    c = City("concordia_siege", W, H, SEED, biome="highlands")
    c.frame(2, "t")
    # ---- the stream: out of the city and on under the camp (no ford west of the wall: the camp's south is the water)
    c.river("arroio", [(0, 90), (26, 89), (WALL_X - 1, 86)] + [(x + DX, y + DY) for (x, y) in d07.STREAM], 3)
    # ---- THE MINE HILL and its stairs (d07's)
    c.hill_blob("mine_hill", 97 + DX, 18 + DY, 21, 15)
    c.stairs("stair_w", sh([80, 14]), "w", 3)
    c.stairs("stair_s", sh([94, 30]), "s", 3)
    # ---- THE WALL facing the plateau, its gates, unfinished stretches and postern
    gates = [[WALL_X, y] for y in list(GATES.values()) + list(BREACHES.values()) + [POSTERN]]
    c.wall([(WALL_X, 2), (WALL_X, H - 2)], gates=gates)
    # ---- the city keeps its own ground off the districts
    for r in (d07.NUREMBERG, d07.SQUARE, d07.YARD):
        c.reserve(shr(r))
    c.reserve([0, 0, WALL_X + 3, H])            # (the camp and the siege lines: no houses west of the wall)
    # ---- the quarters (d07's), the streets, the squares
    c.district("north", shr([52, 4, 76, 34]), block=(4, 7), street=2)
    c.district("upper", shr([76, 3, 117, 34]), block=(4, 7), street=2)
    c.district("forge", shr([73, 37, 117, 60]), block=(4, 7), street=2)
    c.district("mill", shr([72, 62, 117, 78]), block=(4, 6), street=2)
    c.district("market", [60, 45, 122, 82], block=(4, 7), street=2)
    for nm, r in [("quarter_road", [48, 40, 54, 45]), ("square_e", [69, 41, 78, 45]), ("square_s", [58, 49, 64, 58]),
                  ("square_n", [58, 30, 64, 38]), ("north_road", [50, 13, 79, 17]), ("under_stair_s", [91, 33, 99, 40]),
                  ("forge_road", [76, 41, 117, 44]), ("mill_road", [64, 60, 117, 63]), ("yard_way", [92, 22, 99, 34])]:
        c.street(nm, shr(r))
    c.street("market_road", [WALL_X + 1, 55, 122, 59])        # (to the west gate)
    c.street("south_way", [WALL_X + 1, 74, 70, 78])           # (to the south gate)
    c.street("west_road", [WALL_X + 1, 8, 60, 86])            # (along the inside of the wall)
    c.square("arsenal", shr(d07.NUREMBERG), props=[["banner_pole", 78, 38], ["forge", 98, 12], ["firewood", 96, 13],
                                                    ["crates_pair", 99, 34], ["barrel_a", 67, 11]])
    c.square("council_sq", shr(d07.SQUARE), props=[["column", 113, 50], ["bench", 107, 52], ["bench", 119, 52],
                                                    ["banner_pole", 109, 47], ["banner_pole", 117, 47]])
    c.square("spring_yard", shr(d07.YARD), props=[["crate_long", 140, 12], ["barrel_tall", 158, 13], ["sacks_pile", 157, 18]])
    c.bridge("ford_w", "arroio", x=12 + DX)
    c.bridge("ford_e", "arroio", x=96 + DX)
    # ---- the lots: the hall, the great spring, the meshed works (as d07's)
    c.lot("hall", at=HALL, size=(5, 4))
    c.lot("spring", at=SPRING, size=(5, 4))
    for nm, (d, k, sz, near) in WORKS.items():
        c.lot(nm, d, size=(sz[0] + 2, sz[1] + 2), at=near)
    # ---- the plateau: the camp's ground, the old mine (spoil, a headframe ruin), pines and boulders
    for p in [["ruin_tower", MINE[0] + 3, MINE[1] - 3], ["stones", MINE[0] - 3, MINE[1] + 1], ["wheelbarrow", MINE[0] + 4, MINE[1] + 3],
              ["highland_boulder", 8, 8], ["araucaria", 5, 20], ["araucaria", 4, 33], ["araucaria_young", 9, 82], ["araucaria", 30, 84],
              ["araucaria", 44, 6], ["araucaria_young", 46, 90], ["highland_boulder", 40, 92], ["araucaria", 18, 92],
              ["stones", 47, 44], ["highland_boulder", 46, 70], ["araucaria", 5, 60], ["araucaria_young", 4, 70],
              ["ruin_tower", 150, 12], ["highland_boulder", 162, 20], ["araucaria", 165, 34], ["araucaria_young", 131, 30]]:
        c.prop(p[0], p[1], p[2])
    c.houses()
    c.starts = [[16, 48], [130, 45]]
    return c


def areas_extra(c):
    """Areas the mission wants beyond the town's own (named here so the mission and the map agree)."""
    out = {
        # the camp and the siege lines
        "camp": [6, 34, 26, 28], "camp_mid": [14, 44, 8, 6], "park": [8, 52, 8, 6], "mine_mouth": [MINE[0] - 2, MINE[1] - 2, 5, 5],
        "mine_near": [MINE[0] - 6, MINE[1] - 6, 13, 13],
        "bat_n": [36, 19, 8, 11], "bat_w": [36, 52, 8, 11], "bat_s": [36, 71, 8, 11],
        "lines": [34, 8, 16, 80],
        # outside each gate (where a sortie comes out), inside each gate (where the city gathers it)
        "north_out": [46, 20, 6, 9], "west_out": [46, 53, 6, 9], "south_out": [46, 72, 6, 9],
        "north_in": [56, 20, 6, 9], "west_in": [56, 53, 6, 9], "south_in": [56, 72, 6, 9],
        "postern_out": [47, 37, 5, 7], "postern_in": [56, 37, 5, 7],
        # the city: its arsenal, the hall, the great spring, the stairs
        "arsenal_mid": [TOWER[0] - 6, TOWER[1] - 5, 14, 12], "spring_top": sh([88, 8]) + [18, 15],
        "spring_foot": [SPRING[0] - 2, SPRING[1] + 5, 9, 3], "hall_door": sh([57, 42]) + [9, 5],
        "below_stair_w": sh([70, 12]) + [6, 6], "wall_walk": [WALL_X + 1, 6, 4, 80],
        "hollweg_post": [SPRING[0] - 6, SPRING[1] - 2, 4, 4],
    }
    return out


if __name__ == "__main__":
    city = build()
    must = list(city.squares) + list(city.bridges) + list(city.lots) + ["stair_w", "stair_s"]
    probs = city.check((16, 48), must=must)
    ex = areas_extra(city)
    got = city.reach((16, 48))
    for nm, (x, y, w, h) in ex.items():
        if not any((xx, yy) in got for yy in range(y, y + h) for xx in range(x, x + w)):
            probs.append("extra area %s can't be reached" % nm)
    for nm, cells in wall_cells().items():
        if any(city.get(x, y) != "." for x, y in cells):
            probs.append("the wall's opening %s is not open ground: %s" % (nm, [city.get(x, y) for x, y in cells]))
    if probs:
        print("PROBLEMS:", probs)
        if "--ascii" in sys.argv:
            print(city.ascii())
        sys.exit(1)
    out = city.save()
    print("wrote", os.path.relpath(out), len(city.props), "props,", len(city.blocks), "blocks,", len(city.lots), "lots,",
          len(city.areas), "areas")
    if "--ascii" in sys.argv:
        print(city.ascii())
