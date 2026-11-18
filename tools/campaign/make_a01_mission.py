#!/usr/bin/env python3
"""Writes campaign/missions/a01_presses.json: Act 1's "The Printing Houses" (the Crown line after p01_leaf, Lyon, spring
2768; the plan: docs/campaign_act1_plan.md "a01_presses" and its OWNER ANSWERS; what was built: docs/campaign_a01_build.md).
  python3 tools/campaign/make_a01_mission.py
The map is THE CITY GENERATOR's Lyon (tools/campaign/make_lyon_map.py, imported here for its areas and lots: run that
first when the town changes). EVERY LINE IS A PLACEHOLDER for the owner to rewrite. After changing a text: add its
Portuguese and Spanish to tools/i18n/campaign/a01_presses.txt and run python3 tools/i18n_build.py
(tools/test_campaign_a01.gd checks every text has both).

The year after Virginia the Free Assembly's pamphlets are everywhere, and Lyon's presses print them. Father Tomasz,
newly ordained in a Lyon parish, tells how the garrison and the city's clergy found the presses before the city turned;
the King frames it, and old Tomasz (the cardinal) says one line in the frame. A fog hunt in the streets.
  PART 1, THE PAMPHLETS: six of twelve houses are PRESSES (DISGUISED: in the town's yellow, untouchable, until a Crown
    unit comes within 3 tiles). Each sends a RUNNER to the nearest square every 2:00 (EASY 2:30, HARD 1:35); a runner
    that reaches a square raises THE CITY'S TEMPER by 1 (20: the city rises, the mission is lost). Closing a press takes
    2 off; Father Tomasz preaching on a square takes 1 off every 30 s. The Watch sees where runners come from now and
    then (a press given away at 5:00, then every 2:30). Close four.
  PART 2, THE WEAVERS' HILL: the Assembly calls the silk-weavers up the Croix-Rousse to the Weavers' Hall. Tomasz must
    stay on the hall's square 45 s (a STAY) while the garrison holds the three stairs against the Assembly's bands;
    every 15 s he is NOT there (from 0:25) two weavers turn to the mob (the temper +1). When he has spoken, the rest go home.
  PART 3, THE LAST PRESS: a weaver tells Tomasz of the great press in a hidden yard under the hill, reached by two
    traboules. Find it (DISGUISED too), take its master printer, Master Rouvière, ALIVE (a CAPTURE) and close it. He
    names Paris (the a06 hint). The temper at the end sets the flag `lyon` (calm under 6, else sullen).
THE PROLOGUE'S FLAG (p01_leaf `families`: save / leave): Tomasz's opening lines and one of his lines at the end.
VERSUS ONLY (no solo mirror: the Assembly is not a faction): the friend is the Free Assembly: his runners to walk to the
  squares, the presses' men, the bands and the mob; he wins at the temper's top or if Tomasz falls.
Where the presses print: three layouts of six; a choice of the Assembly's side whose default is "random" (the match's
  seed picks: solo, and versus until a guest can answer a choice online).
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
sys.path.insert(0, HERE)
import make_lyon_map   # noqa: E402

CITY = make_lyon_map.build()
STILL = "res://campaign/stills/%s.jpg"
MID = "a01_presses"


def past(flag, value):
    return {"past": {"p01_leaf." + flag: value}}


SAVED = past("families", "save")
LEFT = {"not": past("families", "save")}            # (left, or p01 not known: Tomasz carries it)
CROWN = {"playing": "crown"}
ASSEMBLY = {"playing": "assembly"}
NO_ASSEMBLY = {"not": {"playing": "assembly"}}      # the Assembly scripted (solo, co-op)
LIVE = {"not": {"fired": "the_end"}}

SQUARES = ["terreaux", "jacobins", "cordeliers", "bellecour", "saint_jean"]
CANDS = ["cand_%d" % i for i in range(1, 13)]
LAYOUTS = {                                          # where the six presses print (candidates by number)
    "old_town": [1, 4, 5, 8, 9, 12],
    "river": [2, 3, 6, 7, 10, 11],
    "hill": [1, 3, 6, 7, 9, 11],
}
LAYOUT_IDS = list(LAYOUTS)
LAYOUT_LABEL = {"old_town": "THE WEST HILL AND THE SOUTH", "river": "THE EAST HILL AND THE NORTH", "hill": "THE WEST HILL AND THE NORTH"}
LAYOUT_ABOUT = {"old_town": "The hill's west, the slopes, the Presqu'île, Vieux Lyon's north and Guillotière's south.",
                "river": "The hill's east, the slopes, the Presqu'île, Vieux Lyon's south and Guillotière's north.",
                "hill": "The hill's west, the slopes, the Presqu'île, Vieux Lyon's north and Guillotière's north."}
PERIOD = {"easy": 150, "normal": 120, "hard": 95}    # seconds between a press's runners
TEMPER_TOP = 20
TEMPER_START = 2
CALM_UNDER = 6      # the temper at the end under this: `lyon` calm, else sullen
SEARCH = 3          # seconds a Crown man must stand at a house's door (2 tiles) to see what it is


def centre(name):
    x, y, w, h = CITY.areas[name]
    return (x + w / 2.0, y + h / 2.0)


def nearest_square(cand):
    cx, cy = centre(cand)
    return min(SQUARES, key=lambda s: math.hypot(centre(s)[0] - cx, centre(s)[1] - cy))


SQUARE_OF = {c: nearest_square(c) for c in CANDS}


def layout_cond(lid):
    return {"flag": {"layout": lid}}


def place_presses(lid):
    """The option's actions: six presses (the Assembly's cottages, disguised as the town's) and the town's own houses on
    the other six candidates."""
    out = []
    i = 0
    for k in range(1, 13):
        at = CITY.lots["cand_%d" % k]["at"]
        if k in LAYOUTS[lid]:
            i += 1
            out.append({"build": {"team": "assembly", "kind": "cottage", "at": at, "tag": "presses", "tags": ["press_%d" % i],
                                  "name": "Printing house", "disguise": {"as": "town", "within": 2, "by": "crown", "secs": SEARCH}}})
        else:
            out.append({"build": {"team": "town", "kind": "cottage", "at": at, "tag": "houses"}})
    out.append({"say": ["a_layout_" + lid]})
    return out


def runner_to(i):
    """Where press i's runner goes: the square nearest its house, by the layout."""
    out = []
    for lid in LAYOUT_IDS:
        cand = "cand_%d" % LAYOUTS[lid][i - 1]
        out.append({"if": layout_cond(lid), "to": SQUARE_OF[cand]})
    return out


def runner_triggers():
    tr = []
    for i in range(1, 7):
        for d, per in PERIOD.items():
            tr.append({"id": "run_%d_%s" % (i, d),
                       "when": {"all": [{"fired": "layout"}, {"difficulty": d}, {"time": 40 + (i - 1) * per / 6.0},
                                        {"not": {"dead": "press_%d" % i}}, {"not": {"fired": "part2"}}, LIVE]},
                       "every": per,
                       "do": [{"spawn": {"team": "assembly", "kind": "labourer", "as": "runner", "count": 1, "fixed": True,
                                         "near": "press_%d" % i, "at": "east_bank", "tag": "runner_%d" % i, "tags": ["runner"]}},
                              {"order": {"tag": "runner_%d" % i, "do": "move", "to": "terreaux", "to_if": runner_to(i), "idle": True}}]})
    return tr


def press_triggers():
    tr = []
    for i in range(1, 7):
        tr.append({"id": "found_%d" % i, "when": {"unmasked": "press_%d" % i}, "do": [
            {"hurt": {"tag": "press_%d" % i, "amount": 150}},          # (its door broken in as it is found)
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 2, "near": "press_%d" % i,
                       "at": "east_bank", "tag": "press_men", "order": "hold"}},
            {"spawn": {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": 1, "near": "press_%d" % i,
                       "at": "east_bank", "tag": "press_men", "order": "hold"}}]})
        tr.append({"id": "closed_%d" % i, "when": {"all": [{"fired": "layout"}, {"dead": "press_%d" % i}]}, "do": [
            {"counter": {"name": "closed", "add": 1}}, {"counter": {"name": "temper", "add": -2, "min": 0}},
            {"give": {"team": "garrison", "gold": 60}}]})
        # the Watch saw where a runner came from: the first press still hidden given away at 5:00 and every 2:30 after
        # (EASY 4:30, HARD a minute later)
        for d, t0 in (("easy", 270), ("normal", 300), ("hard", 360)):
            tr.append({"id": "hint_%d_%s" % (i, d),
                       "when": {"all": [{"fired": "layout"}, {"difficulty": d}, {"time": t0 + (i - 1) * 150},
                                        {"disguised": "presses"}, {"not": {"fired": "part2"}}, LIVE]},
                       "do": [{"unmask": {"tag": "presses", "first": True}}, {"say": ["w_hint"]}]})
    return tr


def area_list():
    a = dict(CITY.areas)
    a.update(make_lyon_map.areas_extra(CITY))
    return a


GARRISON_QUARTERS = [[110, 54], [114, 54], [118, 54], [122, 54]]

M = {
    "id": MID,
    "title": "The Printing Houses",
    "summary": "Lyon, spring 2768. The Free Assembly's pamphlets are everywhere, and Lyon's presses print them. The garrison and the city's clergy hunt the presses through the streets before the city turns.",
    "map": "campaign:lyon_presses",
    "voice": "a01",
    "light": "day",
    "expansion_spots": False,
    "manual_end": True,
    "difficulty": {"easy": {"spawns": 0.65}, "hard": {"spawns": 1.3}},
    "modes": ["solo", "coop", "versus"],
    "factions": {"free_assembly": {"name": "The Free Assembly", "stand_in": "crown", "campaign_only": True}},
    "sides": [
        {"id": "crown", "name": "The Crown", "about": "Captain Delorme's garrison, the City Watch and a young priest, Father Tomasz."},
        {"id": "assembly", "name": "The Free Assembly", "about": "Varenne's people in Lyon: the presses, their runners and the silk-weavers they stir up. Green and black."},
    ],
    "teams": [
        {"id": "garrison", "side": "crown", "faction": "crown", "colour": 4, "start": "none", "camera": "garrison_yard",
         "gold": 300, "powder": 300,
         "roster": {"deny": ["town_hall", "cottage", "farm", "foundry", "horse_breeder", "armoury", "church", "powder_mill",
                             "barracks", "wall", "gate", "labourer", "messenger", "dragoon", "pikeman"]},
         "control": {"solo": "p1", "coop": "p1", "versus": "p1"}},
        {"id": "watch", "side": "crown", "faction": "crown", "colour": 7, "start": "none", "camera": "pont_rhone_c",
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "town", "side": "crown", "faction": "crown", "colour": 3, "start": "none", "camera": "bellecour",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "assembly", "side": "assembly", "faction": "free_assembly", "colour": 2, "start": "none", "camera": "pentes", "gold": 0,
         "roster": {"deny": ["town_hall", "cottage", "farm", "foundry", "horse_breeder", "armoury", "church", "powder_mill",
                             "barracks", "wall", "gate", "musketeer", "labourer", "cuirassier", "cannon", "missionary"]},
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": area_list(),
    "counters": {"temper": {"start": TEMPER_START, "of": TEMPER_TOP}, "closed": {"start": 0, "of": 4}, "home": {"start": 0},
                 "weavers": {"start": 0}},
    "exits": [{"area": sq, "tag": "runner", "counter": "temper"} for sq in SQUARES]
             + [{"area": "home_w", "team": "town", "counter": "home", "after": "spoken"},
                {"area": "home_e", "team": "town", "counter": "home", "after": "spoken"}],
    "units": [
        # ---- the garrison (the player): the captain, the priest, 12 Musketeers, 4 Horsemen, a powder wagon
        {"team": "garrison", "kind": "dismounted", "as": "delorme", "count": 1, "at": "garrison_yard", "tag": "delorme"},
        {"team": "garrison", "kind": "missionary", "as": "tomasz", "count": 1, "at": "garrison_yard", "tag": "tomasz"},
        {"team": "garrison", "kind": "musketeer", "count": 12, "at": "garrison_yard", "tag": "garrison_men"},
        {"team": "garrison", "kind": "cuirassier", "count": 4, "at": "garrison_yard", "tag": "riders"},
        {"team": "garrison", "kind": "powder_wagon", "count": 1, "at": "garrison_yard", "tag": "wagon"},
        # ---- the City Watch at the bridges (the co-op friend's)
        {"team": "watch", "kind": "musketeer", "count": 2, "at": "pont_rhone_n", "tag": "watch_men", "order": "hold"},
        {"team": "watch", "kind": "musketeer", "count": 2, "at": "pont_rhone_c", "tag": "watch_men", "order": "hold"},
        {"team": "watch", "kind": "musketeer", "count": 2, "at": "pont_saone_c", "tag": "watch_men", "order": "hold"},
        {"team": "watch", "kind": "musketeer", "count": 2, "at": "pont_saone_s", "tag": "watch_men", "order": "hold"},
        # ---- the townsfolk on the squares
        {"team": "town", "kind": "labourer", "as": "citizen", "count": 2, "at": "bellecour", "tag": "townsfolk", "order": "hold", "fixed": True},
        {"team": "town", "kind": "labourer", "as": "citizen", "count": 2, "at": "jacobins", "tag": "townsfolk", "order": "hold", "fixed": True},
        {"team": "town", "kind": "labourer", "as": "citizen", "count": 2, "at": "cordeliers", "tag": "townsfolk", "order": "hold", "fixed": True},
        {"team": "town", "kind": "labourer", "as": "weaver", "count": 2, "at": "hall_square", "tag": "townsfolk", "order": "hold", "fixed": True},
        # ---- the Assembly: the master printer and his men in the hidden yard
        {"team": "assembly", "kind": "labourer", "as": "printer", "count": 1, "fixed": True, "at": "yard", "tag": "printer", "order": "hold"},
        {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 4, "at": "yard", "tag": "yard_men", "order": "hold"},
        {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": 2, "at": "yard", "tag": "yard_men", "order": "hold"},
    ],
    "buildings": [
        {"team": "garrison", "kind": "barracks", "at": [108, 42], "tag": "barracks"},
        {"team": "garrison", "kind": "powder_mill", "at": [114, 42], "tag": "mill"},
        # the roster ladder's C2 (docs/campaign_roster_ladder.md): a standing Horse Breeder, so Horsemen can be MADE here
        {"team": "garrison", "kind": "horse_breeder", "at": [108, 47], "tag": "breeder"},
    ] + [{"team": "garrison", "kind": "cottage", "at": c, "tag": "quarters"} for c in GARRISON_QUARTERS]
    + [{"team": "town", "kind": "cottage", "at": CITY.lots["home_%d" % i]["at"], "tag": "houses"} for i in range(1, 17)]
    + [{"team": "town", "kind": "town_hall", "at": CITY.lots["weavers_hall"]["at"], "tag": "weavers_hall", "name": "The Weavers' Hall"},
       # the yard's two traboules are shut (a door the Assembly keeps, in the town's colour) until a weaver tells Tomasz
       {"team": "assembly", "kind": "wall", "at": CITY.doors["trab_yard_s"], "tag": "yard_doors", "disguise": {"as": "town", "within": 0, "secs": 99999}},
       {"team": "assembly", "kind": "wall", "at": CITY.doors["trab_yard_e"], "tag": "yard_doors", "disguise": {"as": "town", "within": 0, "secs": 99999}},
       {"team": "assembly", "kind": "barracks", "at": CITY.lots["great_press"]["at"], "tag": "great_press", "name": "The great press",
        "disguise": {"as": "town", "within": 3, "by": "crown", "secs": SEARCH}}],
    "objectives": [
        # ---- the Crown: part 1
        {"id": "presses", "side": "crown", "primary": True, "kind": "manual",
         "text": "Find the Assembly's printing houses and close them: {closed} of 4. They look like any other house until your men come close."},
        {"id": "temper", "side": "crown", "primary": True, "kind": "manual",
         "text": "The city's temper: {temper} of 20. Every runner who reaches a square raises it; at 20 the city rises."},
        {"id": "tomasz", "side": "crown", "primary": True, "kind": "protect", "tag": "tomasz", "text": "Father Tomasz must live."},
        # ---- the Crown: part 2
        {"id": "speech", "side": "crown", "primary": True, "kind": "reach", "area": "hall_square", "tag": "tomasz", "secs": 45, "hidden": True,
         "text": "Father Tomasz speaks to the weavers: he stays on the square by the Weavers' Hall for 45 seconds."},
        {"id": "hall", "side": "crown", "primary": False, "kind": "protect", "tag": "weavers_hall", "hidden": True,
         "text": "The Weavers' Hall must stand."},
        # ---- the Crown: part 3
        {"id": "great", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
         "text": "Find the great press under the hill: the traboules lead into its yard."},
        {"id": "rouviere", "side": "crown", "primary": True, "kind": "capture", "tag": "printer", "hidden": True,
         "text": "Take Master Rouvière, the printer, ALIVE: wear him down, then a man of yours beside him."},
        {"id": "close_great", "side": "crown", "primary": True, "kind": "destroy", "tag": "great_press", "hidden": True,
         "text": "Close the great press."},
        # ---- the Assembly (versus)
        {"id": "a_raise", "side": "assembly", "primary": True, "kind": "manual",
         "text": "Raise the city: walk your runners to the squares. The temper {temper} of 20."},
        {"id": "a_priest", "side": "assembly", "primary": False, "kind": "manual",
         "text": "Or silence the priest: Father Tomasz."},
    ],
    "triggers": [
        # ================================================================ THE START
        {"id": "layout", "when": {"time": 0.5}, "do": [
            {"choice": {"id": "layout", "side": "assembly", "title": "WHERE THE PRESSES PRINT", "default": "random", "time": 30,
                        "options": [{"id": lid, "label": LAYOUT_LABEL[lid], "about": LAYOUT_ABOUT[lid],
                                     "do": place_presses(lid)} for lid in LAYOUT_IDS]}},
            {"spare": {"tag": "townsfolk", "on": True}}]},
        {"id": "intro", "when": {"all": [{"time": 1.5}, CROWN]}, "do": [
            {"say": ["d_1", "t_1", "tip_1"]}, {"ping": {"area": "terreaux"}}, {"ping": {"area": "bellecour"}}]},
        {"id": "intro_saved", "when": {"all": [{"fired": "intro"}, SAVED]}, "delay": 16, "do": [{"say": ["t_saved"]}]},
        {"id": "intro_left", "when": {"all": [{"fired": "intro"}, LEFT]}, "delay": 16, "do": [{"say": ["t_left"]}]},
        {"id": "tip_riders", "when": {"fired": "intro"}, "delay": 30, "do": [{"say": ["tip_2"]}]},
        {"id": "tip_powder", "when": {"all": [{"fired": "intro"}, CROWN]}, "delay": 120, "do": [{"say": ["tip_powder"]}]},
        {"id": "intro_a", "when": {"all": [{"time": 1.5}, ASSEMBLY]}, "do": [{"say": ["a_1", "a_tip"]}]},
        # the city pays its garrison
        {"id": "pay", "when": {"all": [{"time": 60}, LIVE]}, "every": 60, "do": [{"give": {"team": "garrison", "gold": 40}}]},
        # ================================================================ PART 1: THE PAMPHLETS
        {"id": "first_found", "when": {"unmasked": "presses"}, "do": [{"say": ["d_found", "t_found"]}]},
        {"id": "first_runner", "when": {"count": {"tag": "runner", "at_least": 1}}, "delay": 3, "do": [{"say": ["w_runner"]}]},
        {"id": "first_closed", "when": {"counter": {"name": "closed", "at_least": 1}}, "do": [{"say": ["d_closed"]}]},
        {"id": "temper_10", "when": {"counter": {"name": "temper", "at_least": 10}}, "do": [{"say": ["n_temper10"]}]},
        {"id": "temper_15", "when": {"counter": {"name": "temper", "at_least": 15}}, "do": [{"say": ["n_temper15", "d_temper15"]}]},
        # Father Tomasz preaching on a square: the temper down one every 30 s
        {"id": "sermon", "when": {"all": [{"fired": "layout"}, {"counter": {"name": "temper", "at_least": 1}}, LIVE,
                                          {"any": [{"count": {"tag": "tomasz", "area": sq, "at_least": 1}} for sq in SQUARES]}]},
         "delay": 30, "every": 30, "do": [{"counter": {"name": "temper", "add": -1, "min": 0}}]},
        {"id": "sermon_line", "when": {"fired": "sermon"}, "do": [{"say": ["t_sermon"]}]},
        # the end of the hunt for the small presses
        {"id": "part2", "when": {"all": [{"counter": {"name": "closed", "at_least": 4}}, LIVE]}, "delay": 8, "do": [
            {"objective": {"id": "presses", "set": "done"}},
            {"say": ["d_2", "t_2", "tip_3"]},
            {"spawn": {"team": "town", "kind": "labourer", "as": "weaver", "count": 16, "fixed": True, "at": "hall_square", "tag": "weavers", "order": "hold"}},
            {"spare": {"tag": "weavers", "on": True}},
            {"objective": {"id": "speech", "set": "active"}}, {"objective": {"id": "hall", "set": "active"}},
            {"reveal": {"area": "hall_square", "side": "crown", "secs": 90}}, {"ping": {"area": "hall_square"}},
            {"ping": {"area": "stair_w"}}, {"ping": {"area": "stair_c"}}, {"ping": {"area": "stair_e"}},
            {"spawn": {"team": "garrison", "kind": "musketeer", "count": 6, "fixed": True, "at": "below_stairs", "tag": "reinforce"}},
            {"light": {"to": "dusk", "secs": 60}}]},
        {"id": "objs_after_presses", "when": {"fired": "part2"}, "delay": 10, "do": [{"objective": {"id": "presses", "set": "hidden"}}]},
        # ================================================================ PART 2: THE WEAVERS' HILL
        # the Assembly's bands come up the three stairs to the hall
        {"id": "band_1", "when": {"fired": "part2"}, "delay": 40, "do": [
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 3, "at": "terreaux", "tag": "band"}},
            {"spawn": {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": 2, "at": "terreaux", "tag": "band"}},
            {"spawn": {"team": "assembly", "kind": "labourer", "as": "torch", "count": 1, "fixed": True, "at": "terreaux", "tag": "band"}},
            {"order": {"tag": "band", "do": "attack", "to": "hall_square"}}, {"say": ["d_band1"]}, {"ping": {"area": "stair_c"}}]},
        {"id": "band_2", "when": {"fired": "part2"}, "delay": 80, "do": [
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 3, "at": "pont_saone_n", "tag": "band2"}},
            {"spawn": {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": 3, "at": "pont_saone_n", "tag": "band2"}},
            {"order": {"tag": "band2", "do": "attack", "to": "hall_square"}}, {"say": ["d_band2"]}, {"ping": {"area": "stair_w"}}]},
        {"id": "band_3", "when": {"fired": "part2"}, "delay": 120, "do": [
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 4, "at": "pont_rhone_n", "tag": "band3"}},
            {"spawn": {"team": "assembly", "kind": "pikeman", "as": "pikeman", "count": 2, "at": "pont_rhone_n", "tag": "band3"}},
            {"spawn": {"team": "assembly", "kind": "labourer", "as": "torch", "count": 1, "fixed": True, "at": "pont_rhone_n", "tag": "band3"}},
            {"order": {"tag": "band3", "do": "attack", "to": "hall_square"}}, {"say": ["d_band3"]}, {"ping": {"area": "stair_e"}}]},
        # while the priest is NOT on the square, the Assembly's agitators turn two weavers every 12 s
        {"id": "turn", "when": {"all": [{"fired": "part2"}, {"not": {"done": "speech"}}, LIVE,
                                        {"not": {"count": {"tag": "tomasz", "area": "hall_square", "at_least": 1}}},
                                        {"count": {"tag": "weavers", "area": "hall_square", "at_least": 1}}]},
         "delay": 25, "every": 15, "do": [
            {"convert": {"area": "hall_square", "from": "town", "kind": "labourer", "count": 2, "to": "assembly", "warn": 3, "as": "mob"}},
            {"counter": {"name": "temper", "add": 1}}, {"counter": {"name": "weavers", "add": 2}}]},
        {"id": "turn_line", "when": {"fired": "turn"}, "do": [{"say": ["n_turn", "t_turn"]}]},
        {"id": "mob_go", "when": {"all": [{"fired": "turn"}, LIVE]}, "delay": 3.5, "every": 3, "do": [
            {"spare": {"tag": "mob", "on": False}},          # (they were weavers, kept out of the fight: no longer)
            {"order": {"tag": "mob", "do": "hunt", "prey": "weavers_hall", "within": 20, "idle": True}}]},
        {"id": "spoken", "when": {"done": "speech"}, "do": [
            {"say": ["t_spoken", "wv_spoken"]},
            {"order": {"tag": "weavers", "only_team": "town", "do": "move", "to": "home_w"}},
            {"counter": {"name": "temper", "add": -3, "min": 0}}]},
        {"id": "hall_burnt", "when": {"all": [{"fired": "part2"}, {"dead": "weavers_hall"}]}, "do": [
            {"counter": {"name": "temper", "add": 4}}, {"say": ["n_hall"]}]},
        # ================================================================ PART 3: THE LAST PRESS
        {"id": "part3", "when": {"all": [{"done": "speech"}, LIVE,
                                         {"any": [{"count": {"team": "assembly", "area": "hilltop_all", "below": 1}},
                                                  {"clock_out": "part3_late"}]}]},
         "delay": 5, "do": [
            {"objective": {"id": "speech", "set": "hidden"}}, {"objective": {"id": "hall", "set": "hidden"}},
            {"say": ["wv_yard", "t_3", "tip_4"]},
            {"spare": {"tag": "yard_doors", "on": False}}, {"hurt": {"tag": "yard_doors", "amount": 99999}},
            {"objective": {"id": "great", "set": "active"}}, {"objective": {"id": "rouviere", "set": "active"}},
            {"objective": {"id": "close_great", "set": "active"}},
            {"ping": {"area": "trab_yard_s"}}, {"ping": {"area": "trab_yard_e"}},
            {"reveal": {"area": "trab_yard_s", "side": "crown", "secs": 40}}, {"reveal": {"area": "trab_yard_e", "side": "crown", "secs": 40}},
            {"light": {"to": "night", "secs": 60}}]},
        {"id": "late_clock", "when": {"done": "speech"}, "do": [{"clock": {"name": "part3_late", "secs": 90}}]},
        {"id": "great_found", "when": {"all": [{"unmasked": "great_press"}, {"fired": "part3"}]}, "do": [
            {"objective": {"id": "great", "set": "done"}}, {"say": ["d_great", "pr_1"]},
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 3, "near": "great_press", "at": "yard", "tag": "yard_men"}}]},
        {"id": "great_early", "when": {"all": [{"unmasked": "great_press"}, {"not": {"fired": "part3"}}]}, "do": [{"say": ["d_early"]}]},
        # the great press prints on while it stands (Part 3): a runner every 40 s to the Terreaux
        {"id": "great_runs", "when": {"all": [{"fired": "part3"}, {"not": {"dead": "great_press"}}, LIVE]}, "delay": 30, "every": 40, "do": [
            {"spawn": {"team": "assembly", "kind": "labourer", "as": "runner", "count": 1, "fixed": True, "near": "great_press", "at": "yard", "tag": "runner_great", "tags": ["runner"]}},
            {"order": {"tag": "runner_great", "do": "move", "to": "terreaux", "idle": True}}]},
        {"id": "taken", "when": {"captured": "printer"}, "do": [{"say": ["pr_taken", "t_taken"]}, {"flag": {"printer": "taken"}}]},
        {"id": "won", "when": {"all": [{"captured": "printer"}, {"dead": "great_press"}, {"fired": "part3"}, LIVE]}, "delay": 3, "do": [
            {"say": ["d_won", "t_won"]},
            {"tally": {"flag": "lyon", "counter": "temper", "bands": [[0, "calm"], [CALM_UNDER, "sullen"]]}},
            {"light": {"to": "dawn", "secs": 20}}]},
        {"id": "the_end", "when": {"fired": "won"}, "delay": 8, "do": [{"win": "crown"}]},
        # ================================================================ THE DEFEATS / THE ASSEMBLY'S WIN
        {"id": "risen", "when": {"all": [{"counter": {"name": "temper", "at_least": TEMPER_TOP}}, LIVE]}, "do": [
            {"say": ["n_risen"]}, {"objective": {"id": "a_raise", "set": "done"}}, {"flag": {"lyon": "risen"}},
            {"objective": {"id": "temper", "set": "failed"}}]},
        {"id": "priest_down", "when": {"all": [{"dead": "tomasz"}, LIVE]}, "do": [{"objective": {"id": "a_priest", "set": "done"}}]},
        {"id": "tomasz_hurt", "when": {"all": [{"hurt": "tomasz"}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["d_hurt"]}]},
    ] + runner_triggers() + press_triggers(),
    "speakers": {
        "king": {"name": "The King", "side": "crown", "portrait": "res://campaign/hub/rome_king_face.png"},
        "cardinal": {"name": "Cardinal Tomasz", "side": "crown", "portrait": "res://campaign/hub/rome_tomasz_face.png"},
        "tomasz": {"name": "Father Tomasz", "side": "crown"},
        "delorme": {"name": "Captain Delorme", "side": "crown"},
        "watch": {"name": "Sergeant of the Watch", "side": "crown"},
        "weaver": {"name": "Mère Gautier", "side": "crown"},
        "printer": {"name": "Master Rouvière", "side": "assembly"},
        "narrator": {"name": "Lyon", "side": "crown"},
        "assembly": {"name": "The Free Assembly", "side": "assembly"},
    },
    "lines": {
        # the opening: the King in Rome, the cardinal, then young Tomasz
        "k_open1": {"who": "king", "text": "The year after Virginia, the Assembly's pamphlets were in every city of the Crown."},
        "k_open2": {"who": "king", "text": "Most of them were printed in Lyon. The Cardinal was there. He was a young priest then."},
        "c_open": {"who": "cardinal", "text": "I was ordained that spring and sent to a parish on the hill. I thought I would baptise silk-weavers' children."},
        "t_open1": {"who": "tomasz", "text": "The papers were on every church door by morning. Nobody saw who nailed them."},
        "t_open_saved": {"who": "tomasz", "text": "The Hollins boys wrote to me from Virginia. Their families were safe. I kept the letter in my breviary."},
        "t_open_left": {"who": "tomasz", "text": "I still prayed for the families we left on the road in Virginia. Nobody wrote to me about them."},
        "t_open2": {"who": "tomasz", "text": "Captain Delorme came to the presbytery. He said: Father, you know these streets. Help me find the presses."},
        "k_open_a": {"who": "king", "text": "The Assembly kept no record of that spring. Here is what it would have done, if it could."},
        # part 1
        "d_1": {"who": "delorme", "to": "crown", "text": "Six presses at least, Father, hidden in houses like any other. The runners carry the papers to the squares."},
        "t_1": {"who": "tomasz", "text": "Then we watch the squares, and follow the runners home."},
        "tip_1": {"who": "delorme", "to": "crown", "text": "A press looks like a house until our men stand at its door. Every runner who reaches a square stirs the city."},
        "tip_2": {"who": "delorme", "to": "crown", "text": "The riders are quick through the streets. Send them to look. Keep the muskets on the squares."},
        "tip_powder": {"who": "delorme", "to": "crown", "text": "Ten shots a musket, Father, then the bayonet. The powder wagon fills them again: keep it near the men."},
        "t_saved": {"who": "tomasz", "to": "crown", "text": "In Virginia we saved the families. Here, too, it is the people we must save, not only the walls."},
        "t_left": {"who": "tomasz", "to": "crown", "text": "In Virginia we left the families on the road. I will not leave this city to the fire."},
        "w_runner": {"who": "watch", "to": "crown", "text": "A runner, Captain! A boy with a bundle of papers, running for the squares."},
        "w_hint": {"who": "watch", "to": "crown", "text": "We saw where a runner came out, Captain. That house there. The door was still open."},
        "d_found": {"who": "delorme", "to": "crown", "text": "A press! Their men are inside. Break it."},
        "t_found": {"who": "tomasz", "to": "crown", "text": "Spare the boys who carry the papers if you can. They cannot read what they carry."},
        "d_closed": {"who": "delorme", "to": "crown", "text": "One press silent. The type goes into the river."},
        "t_sermon": {"who": "tomasz", "to": "crown", "text": "I spoke on the square until my voice went. Some of them listened. Some went home."},
        "n_temper10": {"who": "narrator", "to": "crown", "text": "Shutters close on the Presqu'île. Men gather at the corners and do not talk when soldiers pass."},
        "n_temper15": {"who": "narrator", "to": "crown", "text": "Stones are thrown at the Watch on the bridges. The city is close to rising."},
        "d_temper15": {"who": "delorme", "to": "crown", "text": "Father, they are close to the edge. Stop the runners or we lose the city."},
        # part 2
        "d_2": {"who": "delorme", "to": "crown", "text": "Four presses closed. Now the Assembly calls the weavers up the hill, to their hall."},
        "t_2": {"who": "tomasz", "text": "Let me speak to them, Captain. They are my parish. Hold the stairs and give me the time."},
        "tip_3": {"who": "delorme", "to": "crown", "text": "Father Tomasz must stand on the hall's square. While he is not there, the agitators turn the weavers."},
        "d_band1": {"who": "delorme", "to": "crown", "text": "A band at the Terreaux, coming up the middle stair!"},
        "d_band2": {"who": "delorme", "to": "crown", "text": "More from the Saône bridge, for the west stair."},
        "d_band3": {"who": "delorme", "to": "crown", "text": "And from the Rhône, with torches, for the east stair."},
        "n_turn": {"who": "narrator", "to": "crown", "text": "Weavers pick up stones. A few of them follow the green cockades."},
        "t_turn": {"who": "tomasz", "to": "crown", "text": "Bring me to them. They will not turn while I am speaking."},
        "t_spoken": {"who": "tomasz", "text": "I told them who I was, and whose son. I told them nobody in that hall had ever printed bread."},
        "wv_spoken": {"who": "weaver", "text": "Go home, all of you. The young Father is right. Go home."},
        "n_hall": {"who": "narrator", "to": "crown", "text": "The Weavers' Hall is burning. The whole hill can see it."},
        # part 3
        "wv_yard": {"who": "weaver", "text": "Father. There is a yard under the hill with no street to it. You go in through the houses."},
        "t_3": {"who": "tomasz", "text": "The traboules. Captain, the great press is there."},
        "tip_4": {"who": "delorme", "to": "crown", "text": "Two passages lead into that yard. Take the printer alive: the King will want to know who pays him."},
        "d_great": {"who": "delorme", "to": "crown", "text": "There it is. A press as big as a church organ."},
        "pr_1": {"who": "printer", "text": "You are too late, Father. Half of France has read us already."},
        "d_early": {"who": "delorme", "to": "crown", "text": "A great press in a yard! We will come back for it with more men."},
        "pr_taken": {"who": "printer", "text": "Take me, then. The paper is made in Paris. So is everything else."},
        "t_taken": {"who": "tomasz", "text": "He said Paris. He said it as if it were a threat."},
        "d_won": {"who": "delorme", "to": "crown", "text": "The great press is broken. Lyon is quiet."},
        "t_won": {"who": "tomasz", "text": "The bells rang for Lauds. I had not slept, and I said Mass anyway."},
        "d_hurt": {"who": "delorme", "to": "crown", "text": "The Father is hurt! Men round the priest!"},
        # the defeat
        "n_risen": {"who": "narrator", "text": "Lyon rises. The Assembly's flags are on the Terreaux."},
        # the Assembly (versus)
        "a_1": {"who": "assembly", "to": "assembly", "text": "Your presses print in houses like any other. Walk the runners to the squares and the city will rise."},
        "a_tip": {"who": "assembly", "to": "assembly", "text": "The Crown cannot touch a press it has not found. Keep its men away from your doors."},
        "a_layout_old_town": {"who": "assembly", "to": "assembly", "text": "Your presses: " + LAYOUT_ABOUT["old_town"][0].lower() + LAYOUT_ABOUT["old_town"][1:]},
        "a_layout_river": {"who": "assembly", "to": "assembly", "text": "Your presses: " + LAYOUT_ABOUT["river"][0].lower() + LAYOUT_ABOUT["river"][1:]},
        "a_layout_hill": {"who": "assembly", "to": "assembly", "text": "Your presses: " + LAYOUT_ABOUT["hill"][0].lower() + LAYOUT_ABOUT["hill"][1:]},
        # the ending: the Crown's
        "t_end1": {"who": "tomasz", "text": "Rouvière went to Rome in chains. He never said who paid him. He said Paris, again and again."},
        "t_end_calm": {"who": "tomasz", "text": "By Pentecost the weavers were back at their looms, and they came to Mass."},
        "t_end_sullen": {"who": "tomasz", "text": "The city stayed quiet. Quiet is not the same as calm. I heard them stop talking when I passed."},
        "t_end_saved": {"who": "tomasz", "text": "I wrote to the Hollins boys that summer. I told them about Lyon. I did not tell them everything."},
        "c_end": {"who": "cardinal", "text": "I was proud of that spring. I am still. I was also lucky."},
        "k_end1": {"who": "king", "text": "He was more than lucky. He made a city go home without a volley."},
        "k_end2": {"who": "king", "text": "Paris was another matter."},
        # the ending: the Assembly's (versus)
        "k_end_a1": {"who": "king", "text": "That is not how it went. Lyon did not rise."},
        "k_end_a2": {"who": "king", "text": "But if it had, Paris would have had a sister. I have thought of that."},
    },
    "stills": {
        "rome": {"image": STILL % "p01_01", "caption": "Rome, the present. The King and the Cardinal."},
        "bridge": {"image": STILL % "a01_01", "caption": "Lyon, spring 2768. Pamphlets on the bridges."},
        "press": {"image": STILL % "a01_02", "caption": "A printing house behind a weaver's shutters."},
        "hill": {"image": STILL % "a01_03", "caption": "The Croix-Rousse: the weavers at their hall."},
        "traboule": {"image": STILL % "a01_04", "caption": "Through the traboules."},
        "taken": {"image": STILL % "a01_05", "caption": "The last press, and its printer."},
    },
    "opening": {
        "crown": [
            {"still": "rome", "lines": ["k_open1", "k_open2", "c_open"]},
            {"still": "bridge", "lines": ["t_open1", {"id": "t_open_saved", "if": SAVED}, {"id": "t_open_left", "if": LEFT}]},
            {"still": "press", "lines": ["t_open2"]},
        ],
        "assembly": [
            {"still": "rome", "lines": ["k_open1", "k_open_a"]},
            {"still": "press", "lines": ["a_1"]},
        ],
    },
    "ending": {
        "crown": [
            {"still": "taken", "lines": ["t_end1",
                                        {"id": "t_end_calm", "if": {"flag": {"lyon": "calm"}}},
                                        {"id": "t_end_sullen", "if": {"flag": {"lyon": "sullen"}}},
                                        {"id": "t_end_saved", "if": SAVED}]},
            {"still": "rome", "lines": ["c_end", "k_end1", "k_end2"]},
        ],
        "assembly": [
            {"still": "hill", "lines": ["k_end_a1"]},
            {"still": "rome", "lines": ["k_end_a2"]},
        ],
    },
    "briefing": {
        "crown": {"still": "bridge", "text": [
            "Lyon, spring 2768. The Free Assembly prints its pamphlets in houses like any other, and its runners carry them to the squares.",
            "Find the printing houses and close them; keep the runners off the squares before the city's temper boils over.",
            "Father Tomasz must live."]},
        "assembly": {"still": "press", "text": [
            "Lyon, spring 2768. You are the Free Assembly. Six of your presses print in the city's houses.",
            "Walk your runners to the squares until the city rises, or silence the young priest."]},
    },
    "debrief": {
        "crown": {"still": "taken", "title": "The presses are silent",
                  "text": "Master Rouvière is taken and the great press broken. Lyon went home.",
                  "text_if": [
                      {"if": {"flag": {"lyon": "calm"}}, "text": "The city is calm: its temper {temper} of 20."},
                      {"if": {"flag": {"lyon": "sullen"}}, "text": "The city is sullen: its temper {temper} of 20."},
                      {"if": {"counter": {"name": "weavers", "at_least": 1}}, "text": "{weavers} weavers followed the Assembly on the hill."}]},
        "assembly": {"still": "hill", "title": "Lyon rises",
                     "text": "The Assembly's flags fly on the Terreaux. The garrison holds only the east bank."},
    },
    "next": {"crown": "a06_barricades", "assembly": ""},
}

for o in M["objectives"]:
    if "kind_of" in o:
        o["kind"], o["unit_kind"] = "reach", o.pop("kind_of")

if __name__ == "__main__":
    out = os.path.join(ROOT, "campaign", "missions", MID + ".json")
    # THE ROSTER LADDER (docs/campaign_roster_ladder.md): C2, the Horse Breeder and the Horseman. The garrison's story
    # deny (no building in a city it does not own) stays on top; its Horse Breeder stands from the start.
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import roster_ladder
    roster_ladder.apply(M, "a01_presses", story_deny={"garrison": list(M["teams"][0]["roster"]["deny"])})
    with open(out, "w") as f:
        json.dump(M, f, indent="\t", ensure_ascii=False)
    print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines;",
          "squares:", {c: SQUARE_OF[c] for c in CANDS})
