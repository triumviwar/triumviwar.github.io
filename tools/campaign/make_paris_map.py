#!/usr/bin/env python3
"""Writes campaign/maps/paris_barricades.json, the map of Act 1's "The Barricades of Paris" (a06_barricades; the plan:
docs/campaign_act1_plan.md "a06_barricades"; what was built: docs/campaign_a06_build.md), with THE CITY GENERATOR
(tools/campaign/city_gen.py, docs/city_generator.md). Rebuild:
  python3 tools/campaign/make_paris_map.py            (add --ascii for a text picture)
The mission script (make_a06_mission.py) imports build() for the areas and the lots: change the town here, run both.

Paris in July 2769, 128 x 96 cells (north up), seed 1769:
  - THE ARMY'S CAMP (east, outside the toll wall): open ground for the Barracks, the Foundry, the Horse Breeder.
  - THE TOLL WALL (x 106) with ONE gate, the Porte Saint-Antoine: the only way into the city.
  - THE FAUBOURG SAINT-ANTOINE: one long street (the rue du Faubourg) between solid house blocks, from the gate west to
    the PLACE DE LA BASTILLE; THREE BARRICADES across it (the mission builds them).
  - THE MARAIS (the right bank, north of the river): a grid of streets west of the Bastille; the PLACE DE GRÈVE on the
    quay with the HÔTEL DE VILLE (the Assembly's hall: the mission rings its square with palisades); the QUAY along the
    river to the PORT SAINT-NICOLAS in the west (the boat Varenne would run for).
  - THE SEINE (west to east) and the ÎLE DE LA CITÉ between its two arms; NOTRE-DAME on the island's east end with the
    PARVIS before it; bridges: the PONT NOTRE-DAME and the PONT AU CHANGE (the north arm), the PETIT PONT (the south
    arm), the PONT NEUF (west, the whole river).
  - THE LEFT BANK (south): the Latin quarter, the PLACE MAUBERT by the Petit Pont (where the torch-bearers gather).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from city_gen import City   # noqa: E402

W, H = 128, 96
SEED = 1769

SEINE = [(0, 57), (24, 56), (46, 57), (82, 58), (104, 59), (128, 58)]
ARM_N = [(44, 56), (52, 50), (78, 50), (86, 57)]       # the north arm round the island
ARM_S = [(44, 58), (52, 64), (78, 64), (86, 59)]       # the south arm
ISLAND = [52, 52, 79, 63]                              # land put back between the arms (x0, y0, x1, y1)
WALL_X = 106                                           # the toll wall
STREET = [66, 29, WALL_X, 34]                          # the rue du Faubourg Saint-Antoine (y 29..33)
BARRICADES = {"bar_1": 99, "bar_2": 91, "bar_3": 83}   # x of each barricade across the street (east to west)
GREVE = [34, 40, 50, 47]                               # the Place de Grève (the hall's square)
HALL = [39, 36]                                        # the Hôtel de Ville's footprint (a Town Hall, 5 x 4) at the square's north
RING = [33, 34, 51, 48]                                # the palisade ring round the hall and its square (x0, y0, x1, y1)
NOTRE_DAME = [70, 55]                                  # the cathedral (a Church, 3 x 3) on the island's east end


def build():
    c = City("paris_barricades", W, H, SEED, biome="grass")
    c.frame(2, "t")
    c.river("seine", SEINE, 6)
    c.river("arm_n", ARM_N, 3)
    c.river("arm_s", ARM_S, 3)
    c.fill(ISLAND, ".", only={"w"})
    c.area("island", ISLAND)
    # ---- east of the wall: the camp (north of the river); south of the river nothing (wood)
    c.fill([WALL_X + 1, 61, W, H], "t")
    c.fill([80, 53, WALL_X + 1, 61], "t", only={"."})        # (the strip of shore below the faubourg: wood)
    c.square("camp", [WALL_X + 2, 12, 125, 50])
    c.wall([(WALL_X, 2), (WALL_X, 52)], gates=[(WALL_X, 31)])
    c.wall([(WALL_X, 62), (WALL_X, 93)])
    # ---- the faubourg: one street between solid blocks (the barricades can't be gone round)
    c.block("faubourg_n", [80, 3, WALL_X, STREET[1]])
    c.block("faubourg_s", [80, STREET[3], WALL_X, 53])
    c.block("bastille_n", [66, 3, 80, 23])
    c.street("rue_faubourg", STREET)
    c.street("porte", [WALL_X - 1, 29, WALL_X + 3, 34])
    c.square("bastille", [66, 23, 80, 41], props=[["column", 73, 32]])
    c.block("bastille_s", [66, 41, 80, 48])
    # ---- the right bank: the Marais, the Grève, the quay
    c.district("marais", [6, 3, 64, 47], block=(5, 9), street=2)
    # (no house inside the hall's ring, and a street round it: the blocks that meet it are cut back)
    keep = []
    for b in c.blocks:
        x0, y0, x1, y1 = b["rect"]
        r0, s0, r1, s1 = RING[0] - 2, RING[1] - 2, RING[2] + 2, RING[3] + 2
        if x0 < r1 and r0 < x1 and y0 < s1 and s0 < y1:
            # keep the parts outside the ring's margin (up to four strips)
            for piece in ([x0, y0, x1, s0], [x0, s1, x1, y1], [x0, max(y0, s0), r0, min(y1, s1)], [r1, max(y0, s0), x1, min(y1, s1)]):
                if piece[2] - piece[0] >= 2 and piece[3] - piece[1] >= 2:
                    keep.append({"rect": piece, "district": b["district"]})
        else:
            keep.append(b)
    c.blocks = keep
    c.street("quai", [4, 47, 80, 50])
    c.street("rue_saint_antoine", [48, 29, 66, 33])     # (the faubourg's street goes on into the Marais)
    c.square("greve", GREVE, props=[["well", 36, 45], ["banner_pole", 48, 41]])
    c.lot("hall", at=HALL, size=(5, 4))
    c.area("ring", RING)
    c.area("hall_square", [RING[0] + 1, RING[1] + 1, RING[2] - 1, RING[3] - 1])
    c.square("port", [4, 50, 14, 54])                   # the Port Saint-Nicolas (the boat at the quay's west end)
    # ---- the island: the parvis and the cathedral
    c.square("parvis", [56, 53, 69, 62], props=[["well", 60, 60]])
    c.lot("notre_dame", at=NOTRE_DAME, size=(3, 3))
    # ---- the left bank
    c.district("latin", [6, 66, 104, 93], block=(5, 9), street=2)
    c.street("quai_sud", [4, 62, 104, 66])
    c.square("maubert", [58, 70, 70, 78], props=[["well", 62, 74]])
    c.street("rue_maubert", [62, 65, 66, 70])
    # ---- the bridges
    c.bridge("pont_notre_dame", "arm_n", x=58)
    c.bridge("pont_au_change", "arm_n", x=72)
    c.bridge("petit_pont", "arm_s", x=64)
    c.bridge("pont_neuf", "seine", x=30)
    # ---- the camp's props, the city's
    for p in [["tent_red", 118, 16], ["tent_red", 122, 18], ["tent_red", 120, 46], ["banner_pole", 114, 14], ["flag", 112, 14],
              ["cannonballs", 122, 30], ["cart_b", 124, 40], ["campfire", 118, 40], ["barrel_b", 123, 26]]:
        c.prop(p[0], p[1], p[2])
    c.prop("stall", 21, 86)
    c.houses()
    c.starts = [[116, 31], [42, 43]]
    return c


def areas_extra(c):
    """Areas the mission wants beyond the town's own (named so the mission and the map agree)."""
    out = {
        "camp_yard": [110, 24, 12, 14],
        "before_gate": [100, 28, 5, 7],
        "faubourg": [80, 29, 26, 5],
        "right_bank": [4, 3, 76, 47],
        "north_bank_bridges": [52, 45, 26, 6],
        "left_bank": [4, 62, 100, 32],
        "greve_west": [24, 40, 9, 8],
    }
    # each barricade: the cells across the street (x), its front (east) and the street behind it (west)
    for nm, x in BARRICADES.items():
        out[nm] = [x - 1, STREET[1] - 1, 3, STREET[3] - STREET[1] + 2]
        out[nm + "_behind"] = [x - 5, STREET[1], 4, STREET[3] - STREET[1]]
        out[nm + "_front"] = [x + 2, STREET[1], 4, STREET[3] - STREET[1]]
    return out


def barricade_cells(nm):
    """The cells a barricade takes: across the street at its x."""
    x = BARRICADES[nm]
    return [[x, y] for y in range(STREET[1], STREET[3])]


def ring_cells(c):
    """The palisade ring round the hall's square: the walkable cells on RING's edge."""
    x0, y0, x1, y1 = RING
    out = []
    for x in range(x0, x1):
        for y in (y0, y1 - 1):
            if c.walkable(x, y):
                out.append([x, y])
    for y in range(y0 + 1, y1 - 1):
        for x in (x0, x1 - 1):
            if c.walkable(x, y):
                out.append([x, y])
    return out


if __name__ == "__main__":
    city = build()
    probs = city.check((116, 31))
    # the barricades shut the street: with them in, nothing west of them is reached from the camp
    for nm in BARRICADES:
        for x, y in barricade_cells(nm):
            city.foot.add((x, y))
    got = city.reach((116, 31))
    for nm in ("bastille", "greve", "parvis", "maubert", "port"):
        x, y, w, h = city.areas[nm]
        if any((xx, yy) in got for yy in range(y, y + h) for xx in range(x, x + w)):
            probs.append("%s is reached round the barricades" % nm)
    for nm in BARRICADES:
        for x, y in barricade_cells(nm):
            city.foot.discard((x, y))
    # the ring shuts the hall's square: from the quay, nothing inside it with the ring in
    ring = ring_cells(city)
    for x, y in ring:
        city.foot.add((x, y))
    got = city.reach((20, 48))
    hx, hy, hw, hh = city.areas["hall_square"]
    if any((xx, yy) in got for yy in range(hy, hy + hh) for xx in range(hx, hx + hw)):
        probs.append("the hall's square is open with its ring in")
    for x, y in ring:
        city.foot.discard((x, y))
    if probs:
        print("PROBLEMS:", probs)
        if "--ascii" in sys.argv:
            print(city.ascii())
        sys.exit(1)
    out = city.save()
    print("wrote", os.path.relpath(out), len(city.props), "props,", len(city.blocks), "blocks,", len(city.lots), "lots,",
          len(city.areas), "areas,", len(ring), "ring cells")
    if "--ascii" in sys.argv:
        print(city.ascii())
