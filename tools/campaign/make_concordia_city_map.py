#!/usr/bin/env python3
"""Writes campaign/maps/concordia_city.json, the map of Act 2's "The Council of Gears" (d07_spring; the plan:
docs/campaign_act2_plan.md "d07_spring"; what was built: docs/campaign_d07_build.md), with THE CITY GENERATOR
(tools/campaign/city_gen.py, hills and stairs as Vila Rica's). Rebuild:
  python3 tools/campaign/make_concordia_city_map.py            (add --ascii for a text picture)
The mission script (make_d07_mission.py) imports build() for the areas and the lots: change the town here, run both.

Concórdia four years after its founding (d04_concordia), 2777, 120 x 88 cells (north up), seed 2777, THE HIGHLANDS
biome. The city has spilled down off the mine's hill into the valley head below it:
  - THE MINE HILL (north-east, high ground): the UPPER TOWN, the first workshops over the old mine, and on its crown
    THE GREAT SPRING in its tower over the shaft, in a walled yard (THE SPRING YARD). Two STAIRS go down: the WEST
    STAIR (to the north road) and the SOUTH STAIR (to the forge quarter). Its edges are cliffs: a Springer with HIGH
    LEAP jumps up them where somebody sees the top.
  - THE NUREMBERG QUARTER (north-west, low, open ground): the honest masters' own works round their tower, and the
    Nuremberg families' houses along its west side. Kept free of the generator's houses (the mission places it all).
  - THE COUNCIL SQUARE (the middle): the COUNCIL HALL on its north side.
  - THE FORGE QUARTER (east, under the hill), THE MILL QUARTER (south-east, by the stream), THE MARKET (south and
    south-west), THE NORTH ROAD (north, between the quarter and the hill): house blocks with a workshop or two each,
    the city's meshed works (the mission's buildings on the lots below).
  - THE STREAM along the south, two fords; the road to the valley leaves by the west ford.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from city_gen import City   # noqa: E402

W, H = 120, 88
SEED = 2777

STREAM = [(0, 81), (30, 80), (62, 83), (90, 80), (120, 82)]
NUREMBERG = [5, 5, 50, 37]                 # the honest masters' quarter (open ground: their works and houses)
SQUARE = [52, 37, 71, 51]                  # the council square
HALL = [59, 38]                            # the Council Hall (a Town Hall's 5 x 4) on its north side
YARD = [86, 6, 108, 24]                    # the spring yard on the hill's crown (open ground)
SPRING = [95, 10]                          # THE GREAT SPRING's tower (a Clocktower's 5 x 4)
# the honest masters' works: the d04 layout round their tower (every ring meshes with the tower's or its neighbour's:
# the same offsets as Concórdia's first tower in d04_concordia), moved to the quarter
TOWER = [30, 18]
_D = (TOWER[0] - 80, TOWER[1] - 18)


def _m(p):
    return [p[0] + _D[0], p[1] + _D[1]]


ESCAPEMENT, LIGHT_WORKS, HEAVY_WORKS = _m([88, 17]), _m([73, 18]), _m([77, 25])
MAINSPRING, AVIARY, PRESS = _m([90, 21]), _m([95, 23]), _m([81, 12])
REGULATORS = [_m([71, 15]), _m([71, 22])]
HOUSES = [[9, 9], [9, 14], [9, 19], [9, 24], [9, 29]]          # the Nuremberg families' houses (3 / 4 / 5 by c01 `saved`)
BROKEN_AT = [14, 32]                       # (a04 `broken` kept: the broken ones under their sheets, in the quarter's yard)
# the city's meshed works (the lots: the building one cell in from the lot's corner, so its gear ring keeps clear of the
# houses round it): name -> (district, kind, size, near)
WORKS = {
    "u_works": ("upper", "movement_works", (4, 3), (82, 24)),
    "u_press": ("upper", "cog_press", (3, 3), (104, 25)),
    "n_press": ("north", "cog_press", (3, 3), (64, 14)),
    "f_works": ("forge", "movement_works", (4, 3), (84, 46)),
    "f_esc": ("forge", "escapement", (3, 3), (106, 50)),
    "m_press": ("mill", "cog_press", (3, 3), (84, 70)),
    "m_reg": ("mill", "regulator", (2, 2), (106, 70)),
    "k_press": ("market", "cog_press", (3, 3), (40, 64)),
    "k_reg": ("market", "regulator", (2, 2), (16, 66)),
}


def build():
    c = City("concordia_city", W, H, SEED, biome="highlands")
    c.frame(2, "t")
    c.river("arroio", STREAM, 3)
    # ---- THE MINE HILL (the upper town) and its two stairs
    c.hill_blob("mine_hill", 97, 18, 21, 15)
    c.stairs("stair_w", [80, 14], "w", 3)
    c.stairs("stair_s", [94, 30], "s", 3)
    # ---- open ground the districts keep off
    for r in (NUREMBERG, SQUARE, YARD):
        c.reserve(r)
    # ---- the quarters (house blocks)
    c.district("north", [52, 4, 76, 34], block=(4, 7), street=2)
    c.district("upper", [76, 3, 117, 34], block=(4, 7), street=2)
    c.district("forge", [73, 37, 117, 60], block=(4, 7), street=2)
    c.district("mill", [72, 62, 117, 78], block=(4, 6), street=2)
    c.district("market", [4, 41, 70, 78], block=(4, 7), street=2)
    # ---- the streets: the quarter to the square and the square to every quarter, the ways to the stairs
    c.street("quarter_road", [48, 40, 54, 45])
    c.street("square_e", [69, 41, 78, 45])
    c.street("square_s", [58, 49, 64, 58])
    c.street("square_n", [58, 30, 64, 38])
    c.street("north_road", [50, 13, 79, 17])
    c.street("under_stair_s", [91, 33, 99, 40])
    c.street("forge_road", [76, 41, 117, 44])
    c.street("mill_road", [64, 60, 117, 63])
    c.street("market_road", [4, 52, 70, 55])
    c.street("west_road", [4, 38, 8, 82])
    c.street("yard_way", [92, 22, 99, 34])
    # ---- the squares: the quarter (its own buildings come from the mission), the council square, the spring yard
    c.square("nuremberg", NUREMBERG, props=[["banner_pole", 26, 34], ["forge", 46, 8], ["firewood", 44, 9], ["cart_a", 44, 33],
                                             ["crates_pair", 47, 30], ["barrel_a", 15, 7], ["bench", 18, 7], ["well", 6, 35]])
    c.square("council_sq", SQUARE, props=[["column", 61, 46], ["bench", 55, 48], ["bench", 67, 48], ["stall", 54, 44],
                                          ["stall", 68, 44], ["banner_pole", 57, 43], ["banner_pole", 65, 43]])
    c.square("spring_yard", YARD, props=[["crate_long", 88, 8], ["crate_open", 90, 8], ["stones", 104, 20], ["barrel_tall", 106, 9],
                                         ["cart_c", 88, 21], ["sacks_pile", 105, 14]])
    # ---- the fords over the stream
    c.bridge("ford_w", "arroio", x=12)
    c.bridge("ford_e", "arroio", x=96)
    # ---- the lots: the hall, the great spring, the meshed works (each lot one cell wider than its building all round)
    c.lot("hall", at=HALL, size=(5, 4))
    c.lot("spring", at=SPRING, size=(5, 4))
    for nm, (d, k, sz, near) in WORKS.items():
        c.lot(nm, d, size=(sz[0] + 2, sz[1] + 2), at=near)
    # (a cottage of each meshed quarter, the master's house, by its works)
    for nm, d, at in [("m_house_f", "forge", (96, 52)), ("m_house_m", "mill", (96, 72)), ("m_house_k", "market", (28, 70))]:
        c.lot(nm, d, at=at)
    # ---- the mine's spoil and old headframe on the hill, rocks over the cliffs (a leap needs a clear landing)
    for p in [["ruin_tower", 112, 10], ["highland_boulder", 110, 18], ["stones", 84, 10], ["wheelbarrow", 102, 21],
              ["araucaria", 113, 30], ["araucaria_young", 79, 26], ["araucaria", 60, 8], ["araucaria_young", 72, 30]]:
        c.prop(p[0], p[1], p[2])
    c.houses()
    c.starts = [[28, 30], [100, 20]]
    return c


def areas_extra(c):
    """Areas the mission wants beyond the town's own (named here so the mission and the map agree)."""
    return {
        "camp": [22, 26, 12, 6], "quarter_in": [12, 8, 34, 26], "families": [6, 8, 7, 24], "quarter_gate": [46, 38, 8, 8],
        "hall_door": [57, 42, 9, 5], "hall_yard": [53, 42, 17, 8],
        "brake": [94, 15, 7, 3], "spring_top": [88, 8, 18, 15],
        "below_stair_w": [70, 12, 6, 6], "below_stair_s": [92, 34, 6, 5], "upper_w": [75, 13, 4, 7], "upper_s": [92, 27, 7, 6],
        # where each meshed quarter's men gather and come from
        "q_upper": [80, 20, 30, 12], "q_north": [56, 8, 18, 22], "q_forge": [76, 44, 40, 16], "q_mill": [74, 64, 42, 14],
        "q_market": [8, 56, 60, 20],
        "forge_st": [78, 41, 10, 4], "mill_st": [66, 60, 10, 4], "market_st": [40, 52, 12, 4], "north_st": [52, 13, 8, 4],
        "valley_road": [3, 82, 14, 5],
    }


if __name__ == "__main__":
    city = build()
    must = list(city.squares) + list(city.bridges) + list(city.lots) + ["stair_w", "stair_s"]
    probs = city.check((28, 30), must=must)
    ex = areas_extra(city)
    got = city.reach((28, 30))
    for nm, (x, y, w, h) in ex.items():
        if not any((xx, yy) in got for yy in range(y, y + h) for xx in range(x, x + w)):
            probs.append("extra area %s can't be reached" % nm)
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
