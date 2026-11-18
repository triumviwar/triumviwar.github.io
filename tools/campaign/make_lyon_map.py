#!/usr/bin/env python3
"""Writes campaign/maps/lyon_presses.json, the map of Act 1's "The Printing Houses" (a01_presses; the plan:
docs/campaign_act1_plan.md "a01_presses"; what was built: docs/campaign_a01_build.md), with THE CITY GENERATOR
(tools/campaign/city_gen.py, docs/city_generator.md). Rebuild:
  python3 tools/campaign/make_lyon_map.py            (add --ascii for a text picture)
The mission script (make_a01_mission.py) imports build() for the areas and the lots: change the town here, run both.

Lyon in the spring of 2768, 128 x 96 cells (north up), seed 1768:
  - THE TWO RIVERS: the SAÔNE (west, narrow) and the RHÔNE (east, wide) meet at the south edge.
  - THE CROIX-ROUSSE (north, between the rivers): the silk-weavers' hill, high ground, climbed by THREE STAIRS on its
    south face (west, middle, east); THE WEAVERS' HALL on the square at the top. Quays along both rivers pass below.
  - LES PENTES (the slopes' foot): crowded blocks with TRABOULES (covered passages) through them; in one block a HIDDEN
    YARD reached only by two traboules (the Assembly's great press in Part 3).
  - THE PRESQU'ÎLE (between the rivers, south of the hill): streets and squares: the TERREAUX under the hill, the
    JACOBINS and the CORDELIERS in the middle, BELLECOUR (the great square) in the south.
  - VIEUX LYON (west bank): the old town by the river, the cathedral by the SAINT-JEAN square; FOURVIÈRE (high ground
    behind it, two ramps up).
  - LA GUILLOTIÈRE (east bank): the GARRISON's open ground (the mission places the barracks and the powder mill), quarters
    north and south of it.
  - BRIDGES: three over the Saône and three over the Rhône (fords).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from city_gen import City   # noqa: E402

W, H = 128, 96
SEED = 1768

SAONE = [(30, 0), (31, 12), (34, 26), (33, 40), (35, 54), (40, 68), (48, 82), (57, 96)]
RHONE = [(105, 0), (101, 16), (96, 32), (92, 48), (87, 62), (79, 76), (67, 88), (59, 96)]
HILL = [39, 2, 92, 20]                   # the Croix-Rousse (x0, y0, x1, y1): high ground
STAIRS = {"stair_w": 47, "stair_c": 63, "stair_e": 79}     # x of each stair (4 cells wide) on the hill's south face
YARD_BLOCK = [40, 24, 54, 35]            # the block with the hidden yard (les Pentes, west)
YARD = [44, 27, 51, 32]                  # the yard inside it
GREAT_PRESS = [45, 28]                   # the great press's footprint (a Barracks, 4 x 3) in the yard


def build():
    c = City("lyon_presses", W, H, SEED, biome="grass")
    c.frame(2, "t")
    c.river("saone", SAONE, 4)
    c.river("rhone", RHONE, 6)
    # ---- high ground: the Croix-Rousse and Fourvière, their stairs and ramps
    c.hill("croix_rousse", HILL)
    for nm, x in STAIRS.items():
        c.ramp(nm, [x, HILL[3], x + 4, HILL[3] + 1])
    c.hill("fourviere", [3, 10, 15, 86])
    c.ramp("fourviere_n", [15, 28, 16, 32])
    c.ramp("fourviere_s", [15, 62, 16, 66])
    # ---- the block with the hidden yard (before the districts, so they keep off it)
    c.block("yard_block", YARD_BLOCK, "yard")
    # ---- the districts
    c.district("hilltop", [40, 3, 91, 19], block=(5, 8), street=2)
    c.district("pentes", [38, 22, 92, 36], block=(5, 9), street=2)
    c.district("presqu_ile", [38, 38, 92, 92], block=(6, 10), street=2)
    c.district("vieux_lyon", [17, 6, 31, 90], block=(5, 8), street=2)
    c.district("fourviere_top", [4, 12, 14, 84], block=(4, 7), street=2)
    c.district("guillotiere_n", [104, 3, 125, 36], block=(5, 9), street=2)
    c.district("guillotiere_s", [98, 62, 125, 93], block=(5, 9), street=2)
    # ---- the garrison's ground (east bank, open)
    c.square("garrison", [104, 38, 124, 60])
    # ---- the main streets (cut through the blocks): to the bridges, down the middle, along the hill's foot
    c.street("rue_pentes", [36, 21, 94, 23])
    c.street("rue_centrale", [64, 23, 67, 90])
    c.street("rue_ponts", [36, 49, 96, 52])
    c.street("rue_sud", [38, 72, 88, 75])
    c.street("rue_vieux", [26, 6, 29, 90])
    c.street("rue_garrison", [94, 48, 106, 52])
    c.street("quai_croix_w", [34, 3, 39, 22])
    c.street("quai_croix_e", [92, 3, 98, 32])
    # ---- the squares
    c.square("hall_square", [56, 4, 74, 15], props=[["well", 58, 13], ["bench", 70, 13]])
    c.square("terreaux", [56, 24, 68, 30], props=[["well", 62, 28]])
    c.square("jacobins", [54, 44, 63, 49], props=[["well", 58, 46]])
    c.square("cordeliers", [72, 39, 81, 46], props=[["stall", 74, 41], ["stall", 78, 41]])
    c.square("bellecour", [52, 58, 72, 70], props=[["column", 62, 63], ["bench", 56, 66], ["bench", 68, 66]])
    c.square("saint_jean", [19, 45, 26, 52], props=[["well", 21, 48]])
    c.square("fourviere_square", [5, 40, 13, 48], props=[["chapel", 8, 42], ["chapel_tower", 11, 41]])
    # ---- the bridges
    c.bridge("pont_saone_n", "saone", y=24)
    c.bridge("pont_saone_c", "saone", y=50)
    c.bridge("pont_saone_s", "saone", y=73)
    c.bridge("pont_rhone_n", "rhone", y=30)
    c.bridge("pont_rhone_c", "rhone", y=50)
    c.bridge("pont_rhone_s", "rhone", y=72)
    # ---- the hidden yard and its two traboules (from the street to the south and the street to the east)
    c.courtyard("yard", YARD)
    c.traboule("trab_yard_s", [47, YARD_BLOCK[3] - 1], "n")
    c.traboule("trab_yard_e", [YARD_BLOCK[2] - 1, 29], "w")
    c.lot("great_press", at=GREAT_PRESS, size=(4, 3))
    # ---- more traboules through the slopes' blocks (the Assembly's shortcuts)
    c.traboules_in("pentes", 6, "traboule")
    # ---- the weavers' hall at the top (a Town Hall, 5 x 4) and the candidate houses for the presses
    c.lot("weavers_hall", at=[62, 5], size=(5, 4))
    cands = [("cand_1", "hilltop", (46, 9)), ("cand_2", "hilltop", (84, 12)),
             ("cand_3", "pentes", (60, 33)), ("cand_4", "pentes", (84, 30)),
             ("cand_5", "presqu_ile", (46, 42)), ("cand_6", "presqu_ile", (84, 52)),
             ("cand_7", "presqu_ile", (46, 80)), ("cand_8", "presqu_ile", (76, 66)),
             ("cand_9", "vieux_lyon", (22, 30)), ("cand_10", "vieux_lyon", (22, 66)),
             ("cand_11", "guillotiere_n", (114, 20)), ("cand_12", "guillotiere_s", (110, 78))]
    for nm, d, near in cands:
        c.lot(nm, d, near=near)
    # ---- the townsfolk's own houses on lots (yellow buildings: the presses hide among them)
    homes = [("hilltop", (54, 17)), ("hilltop", (76, 6)), ("pentes", (72, 26)), ("pentes", (44, 34)),
             ("presqu_ile", (56, 40)), ("presqu_ile", (80, 44)), ("presqu_ile", (60, 56)), ("presqu_ile", (74, 84)),
             ("presqu_ile", (50, 64)), ("vieux_lyon", (22, 14)), ("vieux_lyon", (22, 44)), ("vieux_lyon", (22, 80)),
             ("guillotiere_n", (110, 10)), ("guillotiere_s", (118, 68)), ("presqu_ile", (70, 56)), ("pentes", (52, 26))]
    for i, (d, near) in enumerate(homes):
        c.lot("home_%d" % (i + 1), d, near=near)
    # ---- the garrison's camp props, the cathedral by Saint-Jean, the riverside
    for p in [["tent_red", 120, 40], ["tent_red", 122, 44], ["banner_pole", 116, 39], ["flag", 112, 39],
              ["cannonballs", 121, 52], ["cart_b", 106, 58], ["campfire", 118, 55], ["barrel_b", 123, 50]]:
        c.prop(p[0], p[1], p[2])
    c.prop("chapel", 22, 54)
    c.prop("chapel_tower", 25, 54)
    c.houses()
    c.starts = [[112, 46], [47, 29]]
    return c


def areas_extra(c):
    """Areas the mission wants beyond the town's own (named here so the mission and the map agree)."""
    return {
        "home_w": [40, 3, 6, 5], "home_e": [85, 3, 6, 5],          # where the weavers go home (the hilltop's corners)
        "hilltop_all": [39, 2, 53, 19],                            # the whole hilltop (Part 2: the Assembly up there)
        "below_stairs": [44, 21, 40, 5],                           # the street at the stairs' foot
        "garrison_yard": [108, 42, 12, 14],
        "east_bank": [98, 3, 28, 90],
    }


if __name__ == "__main__":
    city = build()
    probs = city.check((112, 46))
    # the hidden yard is reached only by its traboules
    for t in ("trab_yard_s", "trab_yard_e"):
        for cc in city.traboules[t]:
            city.foot.add(cc)
    got = city.reach((112, 46))
    if any((x, y) in got for y in range(YARD[1], YARD[3]) for x in range(YARD[0], YARD[2])):
        probs.append("the yard is open without its traboules")
    for t in ("trab_yard_s", "trab_yard_e"):
        for cc in city.traboules[t]:
            city.foot.discard(cc)
    if probs:
        print("PROBLEMS:", probs)
        sys.exit(1)
    out = city.save()
    print("wrote", os.path.relpath(out), len(city.props), "props,", len(city.blocks), "blocks,", len(city.lots), "lots,",
          len(city.areas), "areas")
    if "--ascii" in sys.argv:
        print(city.ascii())
