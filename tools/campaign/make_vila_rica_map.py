#!/usr/bin/env python3
"""Writes campaign/maps/vila_rica.json, the map of Act 2's "The Gold of Vila Rica" (d01_minas; the plan:
docs/campaign_act2_plan.md "d01_minas"; what was built: docs/campaign_d01_build.md), with THE CITY GENERATOR in HILLS
(tools/campaign/city_gen.py: hill_blob and stairs, docs/city_generator.md). Rebuild:
  python3 tools/campaign/make_vila_rica_map.py            (add --ascii for a text picture)
The mission script (make_d01_mission.py) imports build() for the areas and the lots: change the town here, run both.

Vila Rica in the gold country of Minas Gerais, 2772, 128 x 96 cells (north up), seed 1772, THE HIGHLANDS biome (cold
grass and red earth: the terra roxa of the mines):
  - THE TWO HILLS: the PILAR (west) and ANTÔNIO DIAS with the CARMO (east), high ground, each crowned by its church
    with a churchyard (the adro) before it, house blocks down their slopes, STAIRS down every side.
  - THE RIDGE between them: one street on the high ground, widening in the middle into THE SQUARE with the ROYAL
    FOUNDRY HOUSE on its north side (where the gold is cast and the fifth taken). The RUA DIREITA comes down from the
    square's south side to the lower town by a broad stair; a narrow stair goes down its north side to the diggings.
  - THE DIGGINGS (north, low): the miners' shacks and pits between the hills, SANTA EFIGÊNIA's church at the top.
  - THE LOWER TOWN (south, low): the garrison's quarter under the square (the barracks, the Armoury, the Horse Breeder),
    the ROSÁRIO (south-west, the miners' brotherhood's church and their houses), the houses south-east of the road.
  - THE ROAD TO THE COAST runs east along the hills' foot and through THE GORGE: two rock ledges (high ground) over the
    road, a stair up each, before the road leaves the map in the east.
  - THE RIBEIRÃO (the stream) along the south, two fords; beyond the east ford a hollow in the scrub where the
    conspirators would take a cart.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from city_gen import City   # noqa: E402

W, H = 128, 96
SEED = 1772

STREAM = [(0, 85), (30, 84), (60, 86), (84, 83), (97, 86), (103, 96)]
SQUARE = [56, 28, 72, 46]                  # the square on the ridge (x0, y0, x1, y1): high ground
FOUNDRY = [61, 29]                         # the Royal Foundry House (a Town Hall, 5 x 4) on the square's north side
CHURCHES = {"pilar": [23, 22], "carmo": [101, 20], "rosario": [20, 67], "efigenia": [62, 7]}    # a Church each (3 x 3)
ADROS = {"pilar": [19, 20, 30, 29], "carmo": [97, 18, 108, 27], "rosario": [16, 65, 28, 74], "efigenia": [58, 5, 70, 14]}
GARRISON = [50, 47, 80, 60]                # the garrison's quarter (open ground under the square, low)
GORGE_N = [104, 54, 125, 61]               # the gorge's two ledges (high ground over the road)
GORGE_S = [104, 68, 125, 76]
ROAD = [40, 61, 128, 68]                   # the road to the coast (rows 61-67)


def build():
    c = City("vila_rica", W, H, SEED, biome="highlands")
    c.frame(2, "t")
    c.river("funil", STREAM, 3)
    c.fill(ROAD, ".", only={"t"})                    # (the road leaves the map through the frame's trees)
    # ---- the two hills, the ridge and the square (high ground)
    c.hill_blob("pilar_hill", 28, 37, 22, 20)
    c.hill_blob("carmo_hill", 100, 35, 22, 20)
    c.hill("ridge", [46, 33, 82, 41])
    c.hill("praca", SQUARE)
    c.hill("gorge_n", GORGE_N)
    c.hill("gorge_s", GORGE_S)
    # ---- the stairs (ramps): the square's two, the hills' (found at their ragged edges), the gorge's
    c.ramp("sq_s", [62, 46, 66, 47])                 # the Rua Direita: the square down to the lower town
    c.ramp("sq_n", [62, 27, 66, 28])                 # the narrow stair down to the diggings
    c.stairs("pilar_s1", [12, 42], "s", 3)
    c.stairs("pilar_s2", [36, 44], "s", 3)
    c.stairs("pilar_n", [27, 32], "n", 3)
    c.stairs("carmo_s", [88, 44], "s", 3)
    c.stairs("carmo_n", [100, 30], "n", 3)
    c.stairs("gorge_up", [108, 57], "s", 3)          # (up the north ledge from the road)
    c.stairs("gorge_s_up", [116, 72], "s", 3)        # (up the south ledge from the scrub behind it)
    # ---- open ground the districts keep off
    c.reserve(SQUARE)
    c.reserve(GARRISON)
    for r in ADROS.values():
        c.reserve(r)
    c.reserve(GORGE_N)
    c.reserve(GORGE_S)
    # ---- the quarters
    c.district("pilar", [6, 17, 50, 58], block=(4, 7), street=2)
    c.district("carmo", [79, 15, 122, 54], block=(4, 7), street=2)
    c.district("efigenia", [44, 3, 84, 26], block=(4, 6), street=2)
    c.district("rosario", [3, 60, 46, 82], block=(4, 7), street=2)
    c.district("lower", [80, 69, 103, 82], block=(4, 6), street=2)
    # ---- the streets: the road, the ridge street, ways to the stairs and the churchyards
    c.street("road", ROAD)
    c.street("road_w", [3, 59, 52, 62])
    c.street("ridge_street", [46, 35, 82, 39])
    c.street("rua_direita", [61, 47, 67, 62])
    c.street("to_sq_n", [61, 22, 67, 28])
    c.street("pilar_up", [25, 27, 30, 38])
    c.street("carmo_up", [99, 25, 104, 36])
    c.street("pilar_down", [11, 40, 17, 60])
    c.street("pilar_down2", [35, 40, 41, 60])
    c.street("carmo_down", [87, 40, 93, 61])
    c.street("diggings_way", [44, 14, 84, 17])
    # ---- the squares: the square on the ridge, the garrison's ground, the churchyards
    c.square("praca", SQUARE, props=[["column", 64, 42], ["bench", 58, 44], ["bench", 70, 44], ["stall", 58, 37], ["stall", 70, 37]])
    c.square("garrison", GARRISON, props=[["tent_red", 74, 49], ["tent_red", 77, 52], ["banner_pole", 72, 48], ["flag", 51, 48],
                                          ["cannonballs", 77, 57], ["cart_b", 72, 58]])
    for q, r in ADROS.items():
        c.square("adro_" + q, r, props=[["cross_stone", (r[0] + r[2]) // 2, r[3] - 2]])
    # ---- the fords over the stream, the hollow beyond the east one
    c.bridge("ford_w", "funil", x=30)
    c.bridge("ford_e", "funil", x=80)
    c.square("hollow", [72, 89, 90, 94], props=[["boulder_moss", 74, 90], ["stones", 86, 92]])
    # ---- the lots: the Foundry House on the square, the churches in their yards, the candidate houses (two in each
    # quarter: the mission hides the conspiracy's two armouries in two of them), the town's own houses
    c.lot("foundry", at=FOUNDRY, size=(5, 4))
    for q, at in CHURCHES.items():
        c.lot("church_" + q, at=at, size=(3, 3))
    cands = [("cand_1", "pilar", (14, 46)), ("cand_2", "pilar", (40, 28)),
             ("cand_3", "carmo", (86, 46)), ("cand_4", "carmo", (114, 30)),
             ("cand_5", "rosario", (8, 76)), ("cand_6", "rosario", (40, 74)),
             ("cand_7", "efigenia", (50, 8)), ("cand_8", "efigenia", (78, 20))]
    for nm, d, near in cands:
        c.lot(nm, d, near=near)
    homes = [("pilar", (20, 50)), ("pilar", (44, 40)), ("pilar", (10, 28)), ("carmo", (94, 50)), ("carmo", (116, 44)),
             ("carmo", (84, 24)), ("rosario", (30, 78)), ("rosario", (6, 66)), ("efigenia", (70, 22)), ("efigenia", (48, 20)),
             ("lower", (90, 76)), ("lower", (98, 72))]
    for i, (d, near) in enumerate(homes):
        c.lot("home_%d" % (i + 1), d, near=near)
    # ---- the gorge: rocks on the ledges (cover for the ambush), the diggings' pits and spoil
    for (x, y) in [(110, 55), (111, 55), (118, 56), (122, 55), (113, 70), (114, 70), (120, 69), (106, 74), (122, 73)]:
        c.put(x, y, "k")
    for p in [["boulder_moss", 115, 58], ["boulder_moss", 121, 59], ["stones", 107, 59], ["boulder_moss", 110, 70],
              ["stones", 118, 71], ["boulder_moss", 123, 70]]:
        c.prop(p[0], p[1], p[2])
    for (x, y) in [(47, 5), (48, 5), (79, 9), (80, 9), (54, 24), (75, 25)]:
        c.put(x, y, "k")
    for p in [["wheelbarrow", 52, 12], ["sacks", 76, 12], ["log", 56, 24], ["stones", 73, 23], ["firewood", 46, 12]]:
        c.prop(p[0], p[1], p[2])
    c.houses()
    c.starts = [[64, 53], [10, 72]]
    return c


def areas_extra(c):
    """Areas the mission wants beyond the town's own (named here so the mission and the map agree)."""
    return {
        "quarter_pilar": [6, 17, 44, 41], "quarter_carmo": [79, 15, 43, 39], "quarter_efigenia": [44, 3, 40, 23],
        "quarter_rosario": [3, 60, 43, 22], "foundry_door": [60, 33, 7, 4], "camp": [52, 50, 20, 8],
        # the road's stretches for the gold carts (and the escort), the gorge, the coast
        "road_sq": [61, 50, 6, 6], "road_turn": [64, 62, 6, 5], "road_mid": [84, 62, 8, 5], "gorge_w": [96, 61, 8, 7],
        "gorge_mid": [106, 61, 10, 7], "gorge_e": [116, 61, 8, 7], "coast": [125, 61, 3, 7],
        "ledge_n": [109, 55, 14, 5], "ledge_s": [107, 69, 16, 5],
        # where the rising comes from at night, and the way up
        "rise_rosario": [8, 68, 12, 8], "rise_efigenia": [52, 8, 12, 8], "rise_pilar": [10, 30, 10, 8],
        "below_sq_n": [60, 22, 8, 4], "below_sq_s": [60, 48, 8, 4], "ridge_w": [46, 34, 8, 6],
        "home_town": [3, 86, 20, 8],
    }


if __name__ == "__main__":
    city = build()
    must = list(city.squares) + list(city.bridges) + list(city.lots) + ["sq_s", "sq_n", "pilar_s1", "pilar_s2", "pilar_n",
                                                                        "carmo_s", "carmo_n", "gorge_up", "gorge_s_up"]
    probs = city.check((64, 53), must=must)
    ex = areas_extra(city)
    got = city.reach((64, 53))
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
