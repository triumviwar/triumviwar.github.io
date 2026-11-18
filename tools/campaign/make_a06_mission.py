#!/usr/bin/env python3
"""Writes campaign/missions/a06_barricades.json: Act 1's "The Barricades of Paris" (the Crown line after a01_presses,
Paris, July 2769; the plan: docs/campaign_act1_plan.md "a06_barricades" and its OWNER ANSWERS; what was built:
docs/campaign_a06_build.md).
  python3 tools/campaign/make_a06_mission.py
The map is THE CITY GENERATOR's Paris (tools/campaign/make_paris_map.py, imported here for its areas and lots: run that
first when the town changes). EVERY LINE IS A PLACEHOLDER for the owner to rewrite. After changing a text: add its
Portuguese and Spanish to tools/i18n/campaign/a06_barricades.txt and run python3 tools/i18n_build.py
(tools/test_campaign_a06.gd checks every text has both).

The Assembly's great rising: Paris behind barricades, Varenne in the Hôtel de Ville. Field Marshal Fairleigh tells how
the Crown took the city street by street; Father Tomasz, the King's chaplain to the army, is at his side. The King
frames it. THE ROSTER LADDER's C3 (docs/campaign_roster_ladder.md): the FOUNDRY and the MORTAR.
  PART 1, THE FAUBOURG: three BARRICADES across the rue du Faubourg Saint-Antoine (palisades the Assembly holds, its men
    behind them, no way round them). Take them with guns, not by walking in: the Mortar lobs its
    shell over a barricade, a Field Cannon's round shot breaks it, and when a barricade is breached the Assembly's men
    rush out down the street at the guns: CANISTER.
  PART 2, THE BRIDGES: the Assembly holds the Pont Notre-Dame and the Pont au Change (the Lyon men there by a01's
    `lyon`); torch-bearers cross the Petit Pont from the Place Maubert for NOTRE-DAME, which must not burn.
  PART 3, THE HALL: the Hôtel de Ville's square ringed with palisades: open it with the guns and take VARENNE ALIVE (a
    CAPTURE). Once his ring is breached he runs for the boats at the Port Saint-Nicolas (30 s at the quay and he is gone).
  THE CHOICE, VARENNE (the act's): Tomasz asks for mercy, Fairleigh leaves the order to the player: SPARE him (exile:
    the canon) or EXECUTE him. Flags `varenne` spared / executed, `paris` stood.
THE FLAGS READ: p01_leaf `families` (save: the Virginia volunteers, six Musketeers named over their bars, and their
  lines); a01_presses `lyon` (calm: no Lyon men; sullen: two at each bridge; risen: four, and two more at the third
  barricade) and `printer` (taken: Fairleigh's word on Rouvière naming Paris).
VERSUS ONLY (the Assembly is not a faction): the friend is the Free Assembly: the barricades, the bridges, the torches,
  the hall; he wins if Notre-Dame burns, the Field Marshal falls or Varenne gets away by the river.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
sys.path.insert(0, HERE)
import make_paris_map   # noqa: E402

CITY = make_paris_map.build()
STILL = "res://campaign/stills/%s.jpg"
MID = "a06_barricades"


def past(key, value):
    return {"past": {key: value}}


SAVED = past("p01_leaf.families", "save")
LEFT = {"not": SAVED}
SULLEN = past("a01_presses.lyon", "sullen")
RISEN = past("a01_presses.lyon", "risen")
LYON_MEN = {"any": [SULLEN, RISEN]}
CALM = {"not": LYON_MEN}                          # (calm, or a01 not known: no Lyon men)
PRINTER = past("a01_presses.printer", "taken")
CROWN = {"playing": "crown"}
ASSEMBLY = {"playing": "assembly"}
NO_ASSEMBLY = {"not": {"playing": "assembly"}}    # the Assembly scripted (solo, co-op)
LIVE = {"not": {"fired": "the_end"}}
NOT_OVER = {"not": {"fired": "verdict_given"}}

BARS = ["bar_1", "bar_2", "bar_3"]
# the barricades' men (NORMAL): militia, pikemen, guns (none: a captured gun cut a column down in a street, the sim)
BAR_MEN = {"bar_1": (3, 1, 0), "bar_2": (4, 1, 0), "bar_3": (5, 2, 0)}
# the rush out of a breached barricade down the street at the guns: (pikemen, militia, where they come from)
RUSH = {"bar_1": (2, 1, "bar_2_front"), "bar_2": (3, 1, "bar_3_front"), "bar_3": (3, 2, "bastille")}
FLIGHT_DELAY = {"easy": 25, "normal": 12, "hard": 6}     # seconds after the ring is breached before Varenne runs
BOAT_SECS = {"easy": 45, "normal": 30, "hard": 20}       # seconds at the Port Saint-Nicolas and the boat pushes off
TORCH_WAVES = [60, 100, 140]                              # seconds after Part 2 (the torch-bearers on the Petit Pont)
NAMES = ["Will Hollins", "Tom Hollins", "Jacob Hollins", "Ned Hollins", "Sam Hollins", "Eli Hollins"]
RING = make_paris_map.ring_cells(CITY)
RING_GATE = min(RING, key=lambda c: (abs(c[1] - 42) if c[0] == make_paris_map.RING[0] else 99))   # the west side's middle


def area_list():
    a = dict(CITY.areas)
    a.update(make_paris_map.areas_extra(CITY))
    return a


def barricade_buildings():
    out = []
    for nm in BARS:
        for c in make_paris_map.barricade_cells(nm):
            out.append({"team": "assembly", "kind": "wall", "at": c, "tag": nm + "_wall", "tags": ["barricades"], "name": "Barricade"})
    return out


def barricade_units():
    out = []
    for nm in BARS:
        mil, pike, gun = BAR_MEN[nm]
        out.append({"team": "assembly", "kind": "musketeer", "as": "militia", "count": mil, "at": nm + "_behind", "tag": nm + "_men", "order": "hold"})
        out.append({"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": pike, "at": nm + "_behind", "tag": nm + "_men", "order": "hold"})
        if gun:
            out.append({"team": "assembly", "kind": "cannon", "count": 1, "at": nm + "_behind", "tag": nm + "_men", "tags": ["captured_guns"],
                        "order": "hold", "name": "Captured gun"})
    # risen Lyon (a01 won by the Assembly): two more at the third barricade
    out.append({"team": "assembly", "kind": "musketeer", "as": "lyon_man", "count": 2, "at": "bar_3_behind", "tag": "bar_3_men",
                "tags": ["lyon_men"], "order": "hold", "if": RISEN})
    return out


def barricade_triggers():
    tr = []
    for i, nm in enumerate(BARS):
        n = len(make_paris_map.barricade_cells(nm))
        pike, mil, frm = RUSH[nm]
        tr.append({"id": "taken_" + nm, "when": {"dead": nm + "_men"}, "do": [
            {"counter": {"name": "taken", "add": 1}}, {"say": ["f_" + nm]}]})
        tr.append({"id": "breach_" + nm, "when": {"all": [{"count": {"tag": nm + "_wall", "below": n, "buildings": True}}, LIVE]}, "do": [
            {"spawn": {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": pike, "at": frm, "tag": "rush_" + nm, "tags": ["rush"]}},
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": mil, "at": frm, "tag": "rush_" + nm, "tags": ["rush"]}},
            {"order": {"tag": "rush_" + nm, "do": "attack", "to": "faubourg"}}]})
    tr.append({"id": "first_rush", "when": {"any": [{"fired": "breach_" + nm} for nm in BARS]}, "delay": 1, "do": [
        {"say": ["r_rush", "tip_canister"]}, {"point": {"ui": "card", "icon": "ab_canister"}}]})
    return tr


def torch_triggers():
    tr = []
    for i, t in enumerate(TORCH_WAVES):
        k = i + 1
        tr.append({"id": "torch_%d" % k, "when": {"all": [{"fired": "part2"}, LIVE]}, "delay": t, "do": [
            {"spawn": {"team": "assembly", "kind": "labourer", "as": "torch", "count": 2, "at": "maubert", "tag": "torches", "tags": ["torch_%d" % k]}},
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 2, "at": "maubert", "tag": "torch_escort"}},
            {"order": {"tag": "torch_%d" % k, "do": "move", "to": "parvis", "only_team": "assembly"}},
            {"order": {"tag": "torch_escort", "do": "attack", "to": "parvis", "idle": True}},
            {"ping": {"area": "petit_pont"}}] + ([{"say": ["n_torch"]}] if k == 1 else [])})
    return tr


GUN_TEAM = {"solo": "army", "versus": "army", "coop": "guns"}

M = {
    "id": MID,
    "title": "The Barricades of Paris",
    "summary": "Paris, July 2769. The Free Assembly holds the city behind its barricades and Varenne sits in the Hôtel de Ville. Field Marshal Fairleigh takes it back street by street.",
    "map": "campaign:paris_barricades",
    "voice": "a06",
    "light": "dawn",
    "expansion_spots": False,
    "manual_end": True,
    "difficulty": {"easy": {"spawns": 0.7}, "hard": {"spawns": 1.3}},
    "modes": ["solo", "coop", "versus"],
    "factions": {"free_assembly": {"name": "The Free Assembly", "stand_in": "crown", "campaign_only": True}},
    "sides": [
        {"id": "crown", "name": "The Crown", "about": "Field Marshal Fairleigh's army, Colonel Ruggieri's guns and the King's chaplain, Father Tomasz."},
        {"id": "assembly", "name": "The Free Assembly", "about": "Varenne's Paris: the barricades of the faubourg, the bridges, the torches and the hall. Green and black."},
    ],
    "teams": [
        {"id": "army", "side": "crown", "faction": "crown", "colour": 4, "start": "none", "camera": "camp_yard",
         "gold": 450, "powder": 300,
         "control": {"solo": "p1", "coop": "p1", "versus": "p1"}},
        {"id": "guns", "side": "crown", "faction": "crown", "colour": 0, "start": "none", "camera": "camp_yard",
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "town", "side": "crown", "faction": "crown", "colour": 3, "start": "none", "camera": "parvis",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "assembly", "side": "assembly", "faction": "free_assembly", "colour": 2, "start": "none", "camera": "greve", "gold": 0,
         "roster": {"deny": ["town_hall", "cottage", "farm", "foundry", "horse_breeder", "armoury", "church", "powder_mill",
                             "barracks", "wall", "gate", "musketeer", "labourer", "cuirassier", "cannon", "missionary"]},
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": area_list(),
    "counters": {"taken": {"start": 0, "of": 3}, "bridges": {"start": 0, "of": 2}},
    "units": [
        # ---- the army (the player): the field marshal, the chaplain, the colonel of the guns, 14 Musketeers, 4 Horsemen
        {"team": "army", "kind": "dismounted", "as": "fairleigh", "count": 1, "at": "camp_yard", "tag": "fairleigh"},
        {"team": "army", "kind": "missionary", "as": "tomasz", "count": 1, "at": "camp_yard", "tag": "tomasz"},
        {"team": "army", "kind": "musketeer", "count": 14, "at": "camp_yard", "tag": "army_men"},
        {"team": "army", "kind": "cuirassier", "count": 4, "at": "camp_yard", "tag": "riders"},
        {"team": "army", "kind": "powder_wagon", "count": 1, "at": "camp_yard", "tag": "wagon"},
        # Ruggieri's guns: the army's in solo and versus, the friend's in co-op (as p01)
    ] + [u for m in ("solo", "versus", "coop") for u in (
        {"team": GUN_TEAM[m], "kind": "dismounted", "as": "ruggieri", "count": 1, "at": "camp_yard", "tag": "ruggieri", "modes": [m]},
        {"team": GUN_TEAM[m], "kind": "cannon", "count": 2, "at": "camp_yard", "tag": "cannons", "tags": ["guns_all"], "modes": [m]},
        {"team": GUN_TEAM[m], "kind": "mortar", "count": 1, "at": "camp_yard", "tag": "mortars", "tags": ["guns_all"], "modes": [m]})
    ] + [
        # ---- p01 `families` save: the Virginia volunteers, the Hollins boys, named
        {"team": "army", "kind": "musketeer", "as": "volunteer", "count": 1, "at": "camp_yard", "tag": "volunteers", "name": nm, "if": SAVED, "fixed": True}
        for nm in NAMES
    ] + [
        # ---- the horses at the Breeder (the guns' teams: the Foundry's next gun takes one)
        {"team": "army", "kind": "horse", "count": 3, "at": [118, 23], "tag": "spare_horses", "fixed": True},
        # ---- the town: citizens on the parvis
        {"team": "town", "kind": "labourer", "as": "citizen", "count": 3, "at": "parvis", "tag": "townsfolk", "order": "hold", "fixed": True},
    ] + barricade_units() + [
        # ---- the bridges to the Cité (the Lyon men by a01's `lyon`)
        {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 3, "at": "pont_nd_north", "tag": "bridge_nd_men", "order": "hold"},
        {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": 1, "at": "pont_nd_north", "tag": "bridge_nd_men", "order": "hold"},
        {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 3, "at": "pont_ch_north", "tag": "bridge_ch_men", "order": "hold"},
        {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": 1, "at": "pont_ch_north", "tag": "bridge_ch_men", "order": "hold"},
        {"team": "assembly", "kind": "musketeer", "as": "lyon_man", "count": 2, "at": "pont_nd_north", "tag": "bridge_nd_men", "tags": ["lyon_men"], "order": "hold", "if": SULLEN},
        {"team": "assembly", "kind": "musketeer", "as": "lyon_man", "count": 2, "at": "pont_ch_north", "tag": "bridge_ch_men", "tags": ["lyon_men"], "order": "hold", "if": SULLEN},
        {"team": "assembly", "kind": "musketeer", "as": "lyon_man", "count": 4, "at": "pont_nd_north", "tag": "bridge_nd_men", "tags": ["lyon_men"], "order": "hold", "if": RISEN},
        {"team": "assembly", "kind": "musketeer", "as": "lyon_man", "count": 4, "at": "pont_ch_north", "tag": "bridge_ch_men", "tags": ["lyon_men"], "order": "hold", "if": RISEN},
        {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 3, "at": "petit_pont_south", "tag": "petit_men", "order": "hold"},
        # ---- the hall: Varenne, his guard, the hall's men inside the ring
        {"team": "assembly", "kind": "dismounted", "as": "varenne_hall", "count": 1, "at": "greve", "tag": "varenne", "order": "hold", "fixed": True},
        {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 3, "at": "greve", "tag": "guard", "tags": ["hall_men"], "order": "hold"},
        {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 5, "at": "greve", "tag": "hall_men", "order": "hold"},
        {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": 3, "at": "greve", "tag": "hall_men", "order": "hold"},
    ],
    "buildings": [
        # the army's camp outside the Porte Saint-Antoine (the roster ladder's C3: the FOUNDRY, with the Breeder by it)
        {"team": "army", "kind": "barracks", "at": [109, 13], "tag": "barracks"},
        {"team": "army", "kind": "foundry", "at": [115, 13], "tag": "foundry"},
        {"team": "army", "kind": "horse_breeder", "at": [120, 18], "tag": "breeder"},
        {"team": "army", "kind": "powder_mill", "at": [109, 45], "tag": "mill"},
    ] + [{"team": "army", "kind": "cottage", "at": c, "tag": "tents"} for c in
         ([113, 41], [117, 41], [121, 41], [113, 45], [117, 45], [121, 45], [121, 37])]
    + barricade_buildings()
    + [{"team": "town", "kind": "church", "at": CITY.lots["notre_dame"]["at"], "tag": "notre_dame", "name": "Notre-Dame"},
       {"team": "assembly", "kind": "town_hall", "at": CITY.lots["hall"]["at"], "tag": "hall", "name": "The Hôtel de Ville"}]
    + [{"team": "assembly", "kind": "gate" if c == RING_GATE else "wall", "at": c, "tag": "ring", "name": "The hall's palisade"} for c in RING],
    "objectives": [
        # ---- the Crown: part 1
        {"id": "barricades", "side": "crown", "primary": True, "kind": "manual",
         "text": "Take the three barricades of the faubourg: {taken} of 3. Break them with the guns: the Mortar lobs over, the cannon's canister sweeps the street."},
        {"id": "fairleigh", "side": "crown", "primary": True, "kind": "protect", "tag": "fairleigh", "text": "Field Marshal Fairleigh must live."},
        {"id": "tomasz", "side": "crown", "primary": True, "kind": "protect", "tag": "tomasz", "text": "Father Tomasz must live."},
        # ---- part 2
        {"id": "bridges", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
         "text": "Take the bridges to the Cité, the Pont Notre-Dame and the Pont au Change: {bridges} of 2."},
        {"id": "notre_dame", "side": "crown", "primary": True, "kind": "protect", "tag": "notre_dame", "hidden": True,
         "text": "Notre-Dame must not burn: stop the torch-bearers coming over the Petit Pont."},
        # ---- part 3
        {"id": "varenne", "side": "crown", "primary": True, "kind": "capture", "tag": "varenne", "hidden": True,
         "text": "Take Varenne ALIVE: open the hall's palisade, wear him down, then a man of yours beside him. Don't let him reach the boats."},
        # ---- the Assembly (versus)
        {"id": "a_hold", "side": "assembly", "primary": True, "kind": "manual",
         "text": "Hold Paris: burn Notre-Dame, bring down the Field Marshal, or get Varenne out by the river."},
    ],
    "triggers": [
        # ================================================================ THE START
        {"id": "setup", "when": {"time": 0.5}, "do": [
            {"spare": {"tag": "townsfolk", "on": True}}, {"spare": {"tag": "notre_dame", "on": True}},
            {"spare": {"tag": "ring", "on": True}}, {"spare": {"tag": "hall", "on": True}},
            {"spare": {"tag": "hall_men", "on": True}}, {"spare": {"tag": "varenne", "on": True}}]},
        {"id": "intro", "when": {"all": [{"time": 1.5}, CROWN]}, "do": [
            {"say": ["f_1", "r_1", "t_1", "f_t1"]}, {"ping": {"area": "bar_1"}}]},
        {"id": "intro_saved", "when": {"all": [{"fired": "intro"}, SAVED]}, "delay": 20, "do": [{"say": ["v_saved", "t_saved"]}]},
        {"id": "tip_foundry", "when": {"all": [{"fired": "intro"}, CROWN]}, "delay": 40, "do": [{"say": ["tip_foundry"]}]},
        {"id": "tip_powder", "when": {"all": [{"fired": "intro"}, CROWN]}, "delay": 90, "do": [{"say": ["tip_powder"]}]},
        {"id": "intro_a", "when": {"all": [{"time": 1.5}, ASSEMBLY]}, "do": [{"say": ["a_1", "a_tip"]}]},
        # the King's treasury pays the army
        {"id": "pay", "when": {"all": [{"time": 60}, LIVE]}, "every": 60, "do": [{"give": {"team": "army", "gold": 100, "powder": 40}}]},
        # ================================================================ PART 1: THE FAUBOURG
        {"id": "part2", "when": {"all": [{"counter": {"name": "taken", "at_least": 3}}, LIVE]}, "delay": 6, "do": [
            {"objective": {"id": "barricades", "set": "done"}},
            {"say": ["f_2", "t_2", "f_2b"]},
            {"spare": {"tag": "notre_dame", "on": False}},
            {"objective": {"id": "bridges", "set": "active"}}, {"objective": {"id": "notre_dame", "set": "active"}},
            {"reveal": {"area": "north_bank_bridges", "side": "crown", "secs": 40}}, {"reveal": {"area": "parvis", "side": "crown", "secs": 60}},
            {"ping": {"area": "pont_notre_dame"}}, {"ping": {"area": "pont_au_change"}}, {"ping": {"tag": "notre_dame"}},
            {"build": {"team": "army", "kind": "powder_mill", "at": [70, 25], "tag": "magazine", "name": "The Bastille's magazine"}},
            {"light": {"to": "day", "secs": 60}}]},
        {"id": "magazine_line", "when": {"all": [{"fired": "part2"}, CROWN]}, "delay": 20, "do": [{"say": ["f_magazine"]}, {"ping": {"tag": "magazine"}}]},
        {"id": "objs_after_bars", "when": {"fired": "part2"}, "delay": 10, "do": [{"objective": {"id": "barricades", "set": "hidden"}}]},
        # ================================================================ PART 2: THE BRIDGES
        {"id": "lyon_sullen", "when": {"all": [{"fired": "part2"}, SULLEN, CROWN]}, "delay": 12, "do": [{"say": ["n_lyon_sullen", "t_lyon"]}]},
        {"id": "lyon_risen", "when": {"all": [{"fired": "part2"}, RISEN, CROWN]}, "delay": 12, "do": [{"say": ["n_lyon_risen", "t_lyon"]}]},
        {"id": "bridge_nd", "when": {"dead": "bridge_nd_men"}, "do": [{"counter": {"name": "bridges", "add": 1}}]},
        {"id": "bridge_ch", "when": {"dead": "bridge_ch_men"}, "do": [{"counter": {"name": "bridges", "add": 1}}]},
        {"id": "nd_hurt", "when": {"all": [{"fired": "part2"}, {"hurt": "notre_dame"}, CROWN]}, "every": 45, "times": 3, "do": [{"say": ["t_nd"]}]},
        {"id": "bridges_done", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "bridges", "at_least": 2}}]}, "do": [
            {"objective": {"id": "bridges", "set": "done"}}, {"say": ["f_bridges"]}]},
        {"id": "part3", "when": {"all": [{"fired": "bridges_done"}, {"fired": "torch_3"}, {"count": {"tag": "torches", "below": 1}}, LIVE]},
         "delay": 5, "do": [
            {"objective": {"id": "bridges", "set": "hidden"}},
            {"say": ["f_3", "r_3", "tip_3"]},
            {"spare": {"tag": "ring", "on": False}}, {"spare": {"tag": "hall_men", "on": False}}, {"spare": {"tag": "varenne", "on": False}},
            {"objective": {"id": "varenne", "set": "active"}},
            {"reveal": {"area": "ring", "side": "crown", "secs": 60}}, {"ping": {"area": "greve"}}, {"ping": {"area": "port"}},
            {"light": {"to": "dusk", "secs": 90}}]},
        # ================================================================ PART 3: THE HALL
        # once the ring is breached (or a Crown man is in the square) Varenne runs for the boats with his guard
        {"id": "breached", "when": {"all": [{"fired": "part3"}, {"any": [
            {"count": {"tag": "ring", "below": len(RING), "buildings": True}},
            {"count": {"side": "crown", "area": "hall_square", "at_least": 1}}]}]}, "do": [{"say": ["f_breach"]}]},
    ] + [
        {"id": "flight_" + d, "when": {"all": [{"fired": "breached"}, {"difficulty": d}, NO_ASSEMBLY, {"not": {"captured": "varenne"}}, LIVE]},
         "delay": s, "do": [
            {"order": {"tag": "varenne", "do": "move", "to": "port"}},
            {"order": {"tag": "guard", "do": "follow", "leader": "varenne", "within": 2}},
            {"say": ["n_flight", "f_flight"]}, {"ping": {"area": "port"}}, {"reveal": {"area": "port", "side": "crown", "secs": 40}}]}
        for d, s in FLIGHT_DELAY.items()
    ] + [
        {"id": "escaped_" + d, "when": {"all": [{"fired": "part3"}, {"difficulty": d}, {"not": {"captured": "varenne"}}, LIVE,
                                                 {"stay": {"tag": "varenne", "area": "port", "secs": s}}]}, "do": [
            {"say": ["n_escaped"]}, {"objective": {"id": "varenne", "set": "failed"}}, {"objective": {"id": "a_hold", "set": "done"}},
            {"flag": {"varenne": "escaped"}}]}
        for d, s in BOAT_SECS.items()
    ] + [
        {"id": "at_quay", "when": {"all": [{"fired": "part3"}, {"count": {"tag": "varenne", "area": "port", "at_least": 1}}, {"not": {"captured": "varenne"}}, CROWN]},
         "do": [{"say": ["n_quay"]}]},
        # ---- taken: the choice
        {"id": "taken", "when": {"captured": "varenne"}, "do": [
            {"say": ["va_taken", "f_taken"]}, {"light": {"to": "night", "secs": 30}}]},
        {"id": "verdict", "when": {"fired": "taken"}, "delay": 8, "do": [
            {"say": ["t_mercy", "f_order"]},
            {"choice": {"id": "varenne", "side": "crown", "title": "VARENNE", "line": "f_order", "default": "spared", "time": 120,
                        "options": [
                            {"id": "spared", "label": "SPARE HIM: EXILE", "about": "Father Tomasz asks for his life. A ship, and never French ground again.",
                             "do": [{"say": ["f_spared", "va_spared", "t_spared"]}]},
                            {"id": "executed", "label": "EXECUTE HIM", "about": "The King's law for the man who burned Virginia and raised Paris. At dawn, on the Grève.",
                             "do": [{"say": ["f_exec", "va_exec", "t_exec"]}]}]}}]},
        {"id": "verdict_given", "when": {"all": [{"fired": "verdict"}, {"any": [{"flag": {"varenne": "spared"}}, {"flag": {"varenne": "executed"}}]}]},
         "delay": 1, "do": [{"flag": {"paris": "stood"}}]},
        {"id": "won", "when": {"fired": "verdict_given"}, "delay": 7, "do": [{"say": ["f_won"]}, {"light": {"to": "dawn", "secs": 15}}]},
        {"id": "the_end", "when": {"fired": "won"}, "delay": 5, "do": [{"win": "crown"}]},
        # ================================================================ THE DEFEATS / THE ASSEMBLY'S WIN
        {"id": "nd_burnt", "when": {"all": [{"dead": "notre_dame"}, LIVE]}, "do": [
            {"say": ["n_nd_burnt"]}, {"objective": {"id": "a_hold", "set": "done"}}]},
        {"id": "marshal_down", "when": {"all": [{"dead": "fairleigh"}, LIVE]}, "do": [{"objective": {"id": "a_hold", "set": "done"}}]},
        {"id": "fairleigh_hurt", "when": {"all": [{"hurt": "fairleigh"}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["r_marshal"]}]},
        {"id": "tomasz_hurt", "when": {"all": [{"hurt": "tomasz"}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["f_priest"]}]},
    ] + barricade_triggers() + torch_triggers(),
    "speakers": {
        "king": {"name": "The King", "side": "crown", "portrait": "res://campaign/hub/rome_king_face.png"},
        "fairleigh": {"name": "Field Marshal Fairleigh", "side": "crown"},
        "tomasz": {"name": "Father Tomasz", "side": "crown"},
        "ruggieri": {"name": "Colonel Ruggieri", "side": "crown"},
        "volunteer": {"name": "Will Hollins", "side": "crown"},
        "varenne": {"name": "Etienne Varenne", "side": "assembly"},
        "narrator": {"name": "Paris", "side": "crown"},
        "assembly": {"name": "The Free Assembly", "side": "assembly"},
    },
    "lines": {
        # the opening: the King in Rome, then Fairleigh
        "k_open1": {"who": "king", "text": "Paris rose in the summer of 2769. Not a riot: a city behind its own walls, with a government in its hall."},
        "k_open2": {"who": "king", "text": "Fairleigh took it back. He was a field marshal by then. Let him tell it; he tells it shorter than I do."},
        "f_open1": {"who": "fairleigh", "text": "We camped outside the Porte Saint-Antoine. Beyond the gate the faubourg was one long street, and they had cut it three times."},
        "f_open_printer": {"who": "fairleigh", "text": "The printer the young Father took at Lyon had named Paris. He was right about that, if about nothing else."},
        "f_open_noprinter": {"who": "fairleigh", "text": "We had no word from inside the city. We learnt its streets the hard way."},
        "f_open_saved": {"who": "fairleigh", "text": "The Hollins boys came over with the Virginia volunteers. They had asked to."},
        "f_open2": {"who": "fairleigh", "text": "Ruggieri had his guns, and the King had sent us something new from the foundries: a mortar, to throw a shell over a wall."},
        "k_open_a": {"who": "king", "text": "The Assembly wrote a great deal that summer. Here is what it meant to do."},
        # part 1
        "f_1": {"who": "fairleigh", "to": "crown", "text": "Three barricades between us and the Bastille. Don't walk lines into them, gentlemen. Break them with the guns first."},
        "r_1": {"who": "ruggieri", "to": "crown", "text": "The mortar throws over a barricade, Marshal. Set it up out of their muskets' reach, five to eleven tiles off."},
        "t_1": {"who": "tomasz", "to": "crown", "text": "There are families behind those shutters, Marshal. They did not all choose this."},
        "f_t1": {"who": "fairleigh", "to": "crown", "text": "Then we end it quickly. That is the mercy I can give them."},
        "v_saved": {"who": "volunteer", "to": "crown", "text": "Sir. The Hollins boys, all six of us. We are here for the Father, and for you."},
        "t_saved": {"who": "tomasz", "to": "crown", "text": "I baptised your sister's boy, Will. Keep your head down for him."},
        "tip_foundry": {"who": "ruggieri", "to": "crown", "text": "The Foundry casts more guns and mortars, each with a horse from the Breeder. The treasury pays us every minute."},
        "tip_powder": {"who": "ruggieri", "to": "crown", "text": "Ten shots a musket, Marshal, then the bayonet. Keep the powder wagon close behind the line: it fills them again."},
        "r_rush": {"who": "ruggieri", "to": "crown", "text": "They are coming out over the barricade! Canister, load canister!"},
        "tip_canister": {"who": "ruggieri", "to": "crown", "text": "CANISTER on the gun's card: a cone of balls down the street. Keep the line in front of the guns."},
        "f_bar_1": {"who": "fairleigh", "to": "crown", "text": "The first barricade is ours. Bring the guns up."},
        "f_bar_2": {"who": "fairleigh", "to": "crown", "text": "Two. The third is the strongest: the Bastille is behind it."},
        "f_bar_3": {"who": "fairleigh", "to": "crown", "text": "Three. The Bastille is open."},
        # part 2
        "f_2": {"who": "fairleigh", "to": "crown", "text": "Now the river. They hold the bridges to the Cité."},
        "t_2": {"who": "tomasz", "to": "crown", "text": "Marshal, look at the far bank. They are carrying torches towards Notre-Dame."},
        "f_2b": {"who": "fairleigh", "to": "crown", "text": "Then we take the bridges at the run. Notre-Dame does not burn while I command here."},
        "f_magazine": {"who": "fairleigh", "to": "crown", "text": "The Bastille's powder magazine is ours. The wagon and the muskets fill up there now, not back at the camp."},
        "n_lyon_sullen": {"who": "narrator", "to": "crown", "text": "Lyon men are on the bridges: weavers who walked from the Croix-Rousse to fight."},
        "n_lyon_risen": {"who": "narrator", "to": "crown", "text": "Half of Lyon's Assembly is on the bridges and at the Bastille, under its own flags."},
        "t_lyon": {"who": "tomasz", "to": "crown", "text": "I know some of those faces. From the weavers' square."},
        "n_torch": {"who": "narrator", "to": "crown", "text": "Torch-bearers on the Petit Pont, for the cathedral."},
        "t_nd": {"who": "tomasz", "to": "crown", "text": "The doors are burning! Men onto the parvis!"},
        "f_bridges": {"who": "fairleigh", "to": "crown", "text": "Both bridges. The Cité is ours."},
        # part 3
        "f_3": {"who": "fairleigh", "to": "crown", "text": "Now the Hôtel de Ville. Varenne is in there. I want him alive: the King will judge him, not a musket ball."},
        "r_3": {"who": "ruggieri", "to": "crown", "text": "They have palisaded the whole square. The guns will open it."},
        "tip_3": {"who": "fairleigh", "to": "crown", "text": "Take him alive: wear him down, then a man of ours beside him. If he reaches the river, he is gone."},
        "f_breach": {"who": "fairleigh", "to": "crown", "text": "The palisade is open. Watch the west gate: he will run."},
        "n_flight": {"who": "narrator", "to": "crown", "text": "Varenne is out by the west gate, running for the boats at the Port Saint-Nicolas."},
        "f_flight": {"who": "fairleigh", "to": "crown", "text": "Riders! After him!"},
        "n_quay": {"who": "narrator", "to": "crown", "text": "A boat is waiting at the quay. Its oarsmen are already at the oars."},
        "va_taken": {"who": "varenne", "text": "You have taken a man, Marshal. You have not taken an idea."},
        "f_taken": {"who": "fairleigh", "text": "I have taken the man who burned Virginia. That will do for today."},
        "t_mercy": {"who": "tomasz", "text": "Marshal. I ask for his life. Send him away, but let him live. I prayed for his men in Virginia; I pray for him now."},
        "f_order": {"who": "fairleigh", "text": "The King gave me the right to judge him here. The Father asks for mercy. The order is yours."},
        "f_spared": {"who": "fairleigh", "text": "Exile, then. A ship, and never French ground again."},
        "va_spared": {"who": "varenne", "text": "You will regret your mercy, Marshal. Or I will make you glad of it. We shall see."},
        "t_spared": {"who": "tomasz", "text": "Thank God."},
        "f_exec": {"who": "fairleigh", "text": "The law, then. At dawn, on the Grève."},
        "va_exec": {"who": "varenne", "text": "Do it in daylight. Let them all see what the Crown is."},
        "t_exec": {"who": "tomasz", "text": "I will stay with him tonight, Marshal. Someone should."},
        "f_won": {"who": "fairleigh", "to": "crown", "text": "Paris was the King's again by morning. The bells of Notre-Dame rang for Lauds."},
        "r_marshal": {"who": "ruggieri", "to": "crown", "text": "The Marshal is hit! Keep him behind the line!"},
        "f_priest": {"who": "fairleigh", "to": "crown", "text": "The Father is hurt! Men round the priest!"},
        # the defeats
        "n_nd_burnt": {"who": "narrator", "text": "Notre-Dame is burning. The whole city can see it."},
        "n_escaped": {"who": "narrator", "text": "A boat pushes off from the Port Saint-Nicolas. Varenne is gone down the river."},
        # the Assembly (versus)
        "a_1": {"who": "assembly", "to": "assembly", "text": "Hold the barricades. Burn Notre-Dame, bring down the Field Marshal, or get Varenne out by the river: any of them wins Paris."},
        "a_tip": {"who": "assembly", "to": "assembly", "text": "Your men behind a barricade are safe from the Crown's line. Not from its guns: when a barricade breaks, rush the guns."},
        # the ending: the Crown's
        "f_end1": {"who": "fairleigh", "text": "Paris was quiet by the feast of the Assumption. The barricades went back to being carts and paving stones."},
        "f_end_spared": {"who": "fairleigh", "text": "Varenne sailed from Le Havre in September. I did not go to see him off."},
        "f_end_exec": {"who": "fairleigh", "text": "Varenne died on the Grève at dawn. The crowd was very quiet."},
        "f_end_saved": {"who": "fairleigh", "text": "The Hollins boys went home to Virginia that winter. All six of them."},
        "t_end_spared": {"who": "tomasz", "text": "I said a Mass of thanksgiving in Notre-Dame. The doors were still black with smoke."},
        "t_end_exec": {"who": "tomasz", "text": "I said a Mass for his soul. Some of his men came, and I did not send them away."},
        "k_end_spared": {"who": "king", "text": "Mercy from the victor is still victory. I have never regretted that order."},
        "k_end_exec": {"who": "king", "text": "It was the law. I have read the order a hundred times since. It is still the law."},
        "k_end2": {"who": "king", "text": "That was the end of the Assembly's cities. The next fires were not theirs."},
        # the ending: the Assembly's (versus)
        "k_end_a1": {"who": "king", "text": "That is not how it went. Paris did not hold."},
        "k_end_a2": {"who": "king", "text": "But if it had, the Crown would have had two capitals, and one of them against it."},
    },
    "stills": {
        "rome": {"image": STILL % "p01_01", "caption": "Rome, the present. The King."},
        "barricade": {"image": STILL % "a06_01", "caption": "Paris, July 2769. The barricades of the faubourg."},
        "battery": {"image": STILL % "a06_02", "caption": "Colonel Ruggieri's guns."},
        "notre_dame": {"image": STILL % "a06_03", "caption": "Torches on the bridges of the Cité."},
        "hall": {"image": STILL % "a06_04", "caption": "The Hôtel de Ville."},
        "prisoner": {"image": STILL % "a06_05", "caption": "Varenne before the Field Marshal."},
    },
    "opening": {
        "crown": [
            {"still": "rome", "lines": ["k_open1", "k_open2"]},
            {"still": "barricade", "lines": ["f_open1", {"id": "f_open_printer", "if": PRINTER}, {"id": "f_open_noprinter", "if": {"not": PRINTER}},
                                            {"id": "f_open_saved", "if": SAVED}]},
            {"still": "battery", "lines": ["f_open2"]},
        ],
        "assembly": [
            {"still": "rome", "lines": ["k_open1", "k_open_a"]},
            {"still": "barricade", "lines": ["a_1"]},
        ],
    },
    "ending": {
        "crown": [
            {"still": "prisoner", "lines": ["f_end1",
                                           {"id": "f_end_spared", "if": {"flag": {"varenne": "spared"}}},
                                           {"id": "f_end_exec", "if": {"flag": {"varenne": "executed"}}},
                                           {"id": "f_end_saved", "if": SAVED}]},
            {"still": "notre_dame", "lines": [{"id": "t_end_spared", "if": {"flag": {"varenne": "spared"}}},
                                             {"id": "t_end_exec", "if": {"flag": {"varenne": "executed"}}}]},
            {"still": "rome", "lines": [{"id": "k_end_spared", "if": {"flag": {"varenne": "spared"}}},
                                       {"id": "k_end_exec", "if": {"flag": {"varenne": "executed"}}}, "k_end2"]},
        ],
        "assembly": [
            {"still": "hall", "lines": ["k_end_a1"]},
            {"still": "rome", "lines": ["k_end_a2"]},
        ],
    },
    "briefing": {
        "crown": {"still": "barricade", "text": [
            "Paris, July 2769. The Free Assembly holds the city: three barricades across the faubourg, the bridges of the Cité, Varenne in the Hôtel de Ville.",
            "Break the barricades with your guns (the Mortar is new: it lobs over walls), save Notre-Dame from the torches and take Varenne alive.",
            "Field Marshal Fairleigh and Father Tomasz must live."]},
        "assembly": {"still": "barricade", "text": [
            "Paris, July 2769. You are the Free Assembly, and the city is yours behind its barricades.",
            "Burn Notre-Dame, bring down the Field Marshal, or get Varenne out by the river."]},
    },
    "debrief": {
        "crown": {"still": "prisoner", "title": "Paris is the King's",
                  "text": "The barricades are down, Notre-Dame stands and Varenne is taken.",
                  "text_if": [
                      {"if": {"flag": {"varenne": "spared"}}, "text": "Varenne is spared: exile, by your order."},
                      {"if": {"flag": {"varenne": "executed"}}, "text": "Varenne is executed, by your order."}]},
        "assembly": {"still": "hall", "title": "Paris holds",
                     "text": "The Assembly's flags still fly over the Hôtel de Ville."},
    },
    "next": {"crown": "", "assembly": ""},
}

if __name__ == "__main__":
    out = os.path.join(ROOT, "campaign", "missions", MID + ".json")
    # THE ROSTER LADDER (docs/campaign_roster_ladder.md): C3, the Foundry and the Mortar, for the army and Ruggieri's
    # guns. The story's deny on top: no hall or farms in a siege camp (the King's treasury pays).
    import roster_ladder
    roster_ladder.apply(M, MID, story_deny={"army": ["town_hall", "farm"], "guns": ["town_hall", "farm"]})
    with open(out, "w") as f:
        json.dump(M, f, indent="\t", ensure_ascii=False)
    print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines;", len(RING), "ring pieces, the gate at", RING_GATE)
