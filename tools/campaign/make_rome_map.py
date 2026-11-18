#!/usr/bin/env python3
"""Writes campaign/maps/rome_council.json, the map of Act 1's "The Council of Rome" (a07_council; the plan:
docs/campaign_act1_plan.md "a07_council"; what was built: docs/campaign_a07_build.md), with THE CITY GENERATOR
(tools/campaign/city_gen.py, docs/city_generator.md). Rebuild:
  python3 tools/campaign/make_rome_map.py            (add --ascii for a text picture)
The mission script (make_a07_mission.py) imports build() for the areas and the lots: change the town here, run both.

Rome in Lent 2770, 128 x 96 cells (north up), seed 2770:
  - THE TIBER from north to south down the middle, with THREE BRIDGES and no other way over: the PONTE DI RIPETTA
    (north), the PONTE SANT'ANGELO (the middle, under the castle) and the PONTE SISTO (south).
  - THE WEST BANK: SAINT PETER'S (a Church) with its PIAZZA, the APOSTOLIC PALACE where the council sits (a Town Hall),
    the BORGO between the piazza and the river (its long street to the castle), the CASTEL SANT'ANGELO by the middle
    bridge (the King's guard's yard), TRASTEVERE in the south-west, the open fields of the PRATI in the north-west.
  - THE EAST BANK: the city's quarters where the fires start (CAMPO MARZIO in the north, PARIONE round the PIAZZA
    NAVONA in the middle, REGOLA round the CAMPO DE' FIORI in the south), THE STABLES of the specimens in the north-east
    (by the Porta del Popolo), THE EXHIBITION HALL of the automata in the south-east (on the Capitol's slope), the
    CORSO down the east side between them, and the PORTA PIA in the east where the Assembly's last cell comes in.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from city_gen import City   # noqa: E402

W, H = 128, 96
SEED = 2770

TIBER = [(66, 0), (63, 16), (66, 30), (63, 46), (58, 62), (61, 78), (58, 96)]
BRIDGES = {"ponte_ripetta": 16, "ponte_sant_angelo": 40, "ponte_sisto": 74}    # the row each crosses at
PIAZZA = [16, 34, 32, 52]              # Saint Peter's square (x0, y0, x1, y1)
BASILICA = [9, 41]                     # Saint Peter's (a Church, 3 x 3), west of the piazza
PALACE = [9, 30]                       # the Apostolic Palace (a Town Hall, 5 x 4): the council's hall, north of the basilica
CASTEL = [44, 28, 58, 38]              # the castle's yard by the middle bridge (the King's guard)
STABLES = [104, 6, 124, 22]            # the stables of the specimens (north-east)
EXHIBITION = [104, 64, 124, 84]        # the exhibition hall of the automata (south-east)
PORTA = [108, 38, 124, 54]             # the Porta Pia's square (the Assembly comes in by it)
# the quarters whose houses can burn: (district, rect, its square, how many houses the mission puts in it)
QUARTERS = [
    ("campo_marzio", [70, 4, 100, 30], "popolo_square", [80, 12, 90, 20], 5),
    ("parione", [70, 32, 102, 58], "navona", [80, 40, 90, 50], 5),
    ("regola", [66, 60, 100, 92], "campo_fiori", [76, 68, 86, 76], 5),
    ("borgo", [34, 40, 58, 58], "borgo_square", [40, 48, 48, 54], 2),
    ("trastevere", [18, 60, 56, 92], "santa_maria", [30, 70, 40, 78], 3),
]


def build():
    c = City("rome_council", W, H, SEED, biome="grass")
    c.frame(2, "t")
    c.river("tiber", TIBER, 6)
    # ---- the west bank
    c.square("prati", [4, 4, 58, 26])                   # (the fields north of the Borgo: open ground)
    c.square("piazza", PIAZZA, props=[["column", 24, 43], ["well", 20, 38], ["well", 20, 48]])
    c.lot("basilica", at=BASILICA, size=(3, 3))
    c.lot("palace", at=PALACE, size=(5, 4))
    c.square("vatican", [4, 28, 16, 54])                # (round the basilica and the palace)
    c.square("castel", CASTEL, props=[["banner_pole", 50, 30], ["flag", 54, 30], ["cannonballs", 46, 36]])
    for nm, r, sq, sr, n in QUARTERS:
        c.district(nm, r, block=(5, 9), street=2)
    c.street("borgo_street", [30, 41, 60, 45])          # (the Borgo's street from the piazza to the castle's bridge)
    c.street("lungotevere_w", [52, 20, 58, 60])          # (the west bank's quay, the bridges' feet)
    c.street("trastevere_quay", [50, 60, 58, 92])
    c.street("via_lungara", [28, 52, 34, 62])            # (from the piazza south to Trastevere)
    # ---- the east bank
    c.square("stables", STABLES, props=[["cart_b", 108, 10], ["barrel_b", 112, 18], ["campfire", 120, 18]])
    c.square("exhibition", EXHIBITION, props=[["banner_pole", 108, 66], ["flag", 120, 66], ["stall", 110, 80]])
    c.square("porta", PORTA, props=[["well", 116, 44]])
    c.street("corso", [100, 4, 104, 92])                 # (down the east side, the stables to the Capitol)
    c.street("lungotevere_e", [66, 4, 72, 92])           # (the east bank's quay, the bridges' feet)
    c.street("via_papalis", [70, 44, 110, 47])           # (from the middle bridge east through Parione to the gate)
    c.street("via_giulia", [64, 60, 104, 63])
    c.street("via_ripetta", [66, 14, 104, 18])
    for nm, r, sq, sr, n in QUARTERS:
        c.square(sq, sr, props=[["well", (sr[0] + sr[2]) // 2, (sr[1] + sr[3]) // 2]])
    # ---- the bridges (the only ways over)
    for nm, y in BRIDGES.items():
        c.bridge(nm, "tiber", y=y, width=3, approach=5)
    # ---- the houses that can burn: lots in each quarter (the mission puts the town's houses on them)
    for nm, r, sq, sr, n in QUARTERS:
        mid = [(sr[0] + sr[2]) // 2, (sr[1] + sr[3]) // 2]
        for i in range(n):
            c.lot("%s_h%d" % (nm, i + 1), nm, near=mid)
    for p in [["tent_red", 46, 31], ["tent_red", 52, 35], ["cart_b", 34, 20], ["campfire", 30, 12]]:
        c.prop(p[0], p[1], p[2])
    c.houses()
    c.starts = [[50, 33], [114, 14]]
    return c


def areas_extra(c):
    """Areas the mission wants beyond the town's own (named so the mission and the map agree)."""
    out = {
        "west_bank": [2, 2, 54, 92],
        "east_bank": [72, 2, 54, 92],
        "piazza_in": [PIAZZA[0] + 1, PIAZZA[1] + 1, PIAZZA[2] - PIAZZA[0] - 2, PIAZZA[3] - PIAZZA[1] - 2],
        "steps": [13, 40, 4, 6],                       # the basilica's steps (the people come in here)
        "hall_floor": [9, 35, 6, 4],                   # before the palace's door (the council's people stand here)
        "castel_yard": [46, 30, 10, 7],
        "porta_gate": [120, 42, 4, 8],
        "stables_pen": [108, 8, 12, 10],
        "exhibition_floor": [108, 70, 12, 10],
        "corso_n": [100, 24, 4, 8],
        "corso_s": [100, 54, 4, 8],
    }
    # each bridge: its two ends (the west foot the guard holds, the east foot the garrison holds)
    for nm, y in BRIDGES.items():
        x0, y0, x1, y1 = _rect(c.areas[nm])
        out[nm + "_w"] = [x0, y - 3, 6, 7]
        out[nm + "_e"] = [x1 - 6, y - 3, 6, 7]
    return out


def _rect(a):
    x, y, w, h = a
    return [x, y, x + w, y + h]


def quarter_names():
    return [q[0] for q in QUARTERS]


if __name__ == "__main__":
    city = build()
    probs = city.check((50, 33))
    # the river is the only barrier: with the bridges shut, nothing of the east bank is reached from the west
    shut = []
    for nm in BRIDGES:
        for (x, y) in city.bridges[nm]["cells"]:
            if (x, y) not in city.foot:
                city.foot.add((x, y))
                shut.append((x, y))
    got = city.reach((50, 33))
    for nm in ("stables", "exhibition", "porta", "navona", "campo_fiori", "popolo_square"):
        x, y, w, h = city.areas[nm]
        if any((xx, yy) in got for yy in range(y, y + h) for xx in range(x, x + w)):
            probs.append("%s is reached without a bridge" % nm)
    for xy in shut:
        city.foot.discard(xy)
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
