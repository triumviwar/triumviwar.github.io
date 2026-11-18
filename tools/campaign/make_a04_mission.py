#!/usr/bin/env python3
"""Writes campaign/missions/a04_visit.json: Act 1's "Father Ferrer's Visit" (the Clockmaker line after a02_furth, Fürth,
autumn 2769; the plan: docs/campaign_act1_plan.md "a04_visit" and its OWNER ANSWERS; what was built:
docs/campaign_a04_build.md).
  python3 tools/campaign/make_a04_mission.py
The map is a02's grown (tools/campaign/make_furth_works_map.py). EVERY LINE IS A PLACEHOLDER for the owner to rewrite.
After changing a text: add its Portuguese and Spanish to tools/i18n/campaign/a04_visit.txt and run
python3 tools/i18n_build.py (tools/test_campaign_a04.gd checks every text has both).

Eighteen months after the line held, the Roman College sends Father Ferrer to inspect the guild's works at Fürth. He
tells it truthfully (a Crown-side narrator); the King frames it.
  FERRER'S PARTY (PURPLE, p1): Ferrer, two lay brothers, an escort of Musketeers from the Franconian army (a02's
    `furth`: strong 8, thin 5) and the line's gate men. THE GUILD (BLUE, allied; co-op p2, else scripted): Hollweg,
    Jakob (if alive), the works, the Heavy Works and a Pendulum (THE ROSTER LADDER's K3). THE WORKS (BLUE, scripted
    always): the automata that work by themselves (the night Winder, the ones at the river). THE MACHINE (RED, across
    the meadows; VERSUS p2, else scripted).
  PART 1, THE INSPECTION: six workshops, Ferrer STAYS a few seconds in each; four show nothing, two show the signs (a
    Winder winding another; Assembly pamphlets, on the Lyon type if a01 was played). Jakob alive brings Ferrer the
    stop-works he found in a bin (when Hollweg is called away); Jakob lost: Ferrer reads his old log in the barn. Before
    dusk (a raced countdown).
  PART 2, THE NIGHT SHIFT: night; FOLLOW the night Winder to the river, keeping it within 8 tiles and never closer than
    3 (it turns back if it sees you); before dawn. At the bank the guild's automata MESH with gear ground nobody laid
    (c01's `gate`: pattern = the Perpetual's pattern, the flaw in the drawings; people = salvaged red parts).
  PART 3, THE RIOT: they CONVERT (red, the c01 stutter) and march for the machine's ground across the meadows; the
    machine sends a sortie to meet them. Stop them before they reach it (those that do are counted: lost_to_machine).
    The guild's Pendulum sweeps the crowd at the bridge.
  THE CHOICE, THE BROKEN ONES: the stopped automata lie in the yard: Ferrer MELT them / Hollweg KEEP them (default and
    canon KEPT). Flags `broken` melted / kept, `lost_to_machine` (the count), `jakob` alive / lost.
THE FLAGS READ (missing = the defaults): a02_furth `furth` (strong / thin: the escort), `jakob` (and c01's `jakob`:
  lost in either = no Jakob), c01 `gate` (pattern / people: the reveal, two more rioters with the people's salvaged
  parts), a01_presses `printer` / `lyon` (played: Ferrer knows the pamphlets' type from Tomasz's report).
VERSUS ONLY (no solo mirror: the Machine's side is short here): the friend is the Machine: kill Father Ferrer, or bring
  6 of the broken automata to its ground.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "a04_visit"


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


THIN = past("a02_furth.furth", "thin")
STRONG = {"not": THIN}                                   # (strong, or a02 not known: the canon)
JAKOB = {"all": [notpast("a02_furth.jakob", "lost"), notpast("c01_thirteenth.jakob", "lost")]}
NO_JAKOB = {"not": JAKOB}
PATTERN = notpast("c01_thirteenth.gate", "people")       # (the pattern, or c01 not known: the canon)
PEOPLE = past("c01_thirteenth.gate", "people")
LYON_KNOWN = {"any": [past("a01_presses.printer", "taken")] + [past("a01_presses.lyon", v) for v in ("calm", "sullen", "risen")]}
LYON_UNKNOWN = {"not": LYON_KNOWN}
VISIT = {"playing": "visit"}
MACHINE = {"playing": "machine"}
NO_MACHINE = {"not": MACHINE}                             # the machine scripted (solo, co-op)
LIVE = {"not": {"fired": "the_end"}}
PARTY = {"team": "party"}

# ---------------------------------------------------------------- the works: six workshops (guild buildings) and their doors
# (kind, top-left cell, the area Ferrer stands in, what it shows: "" nothing, "wind" a Winder winding another, "print")
SHOPS = [
    ("movement_works", [35, 11], [33, 10, 8, 6], ""),
    ("escapement", [51, 11], [49, 10, 7, 6], "wind"),
    ("cog_press", [35, 19], [33, 18, 7, 6], ""),
    ("mainspring", [51, 22], [49, 21, 7, 6], ""),
    ("cog_press", [40, 24], [38, 23, 6, 5], "print"),
    ("heavy_works", [45, 24], [44, 23, 6, 5], ""),
]
INSPECT_SECS = 6
DUSK = 600                  # seconds for the inspection (NORMAL: the raced clock; EASY x1.25, HARD x0.85)
DAWN = 420                  # seconds for the night shift
# the riot (the works' automata at the bank), by the difficulty: Clock Soldiers, Springers, Winders
RIOT = {"easy": (4, 1, 2), "normal": (6, 2, 2), "hard": (8, 3, 2)}
PEOPLE_MORE = 2             # c01 `gate` people: two more Clock Soldiers (the salvaged red parts)
LOST_WIN = 6                # versus: the machine wins with this many brought home


def shop_units():
    out = []
    for i, (k, at, ar, sign) in enumerate(SHOPS):
        if sign == "wind":
            # the sign: a Winder winding another (the works' own, on hold), and a Clock Soldier they wound
            out.append({"team": "works", "kind": "winder", "count": 2, "at": "ws_%d" % (i + 1), "tag": "pair", "order": "hold", "fixed": True})
            out.append({"team": "works", "kind": "clock_soldier", "count": 1, "at": "ws_%d" % (i + 1), "tag": "pair", "order": "hold", "fixed": True})
    return out


def shop_triggers():
    tr = []
    for i, (k, at, ar, sign) in enumerate(SHOPS):
        n = i + 1
        say = {"": ["f_ws%d" % n], "wind": ["f_wind", "h_wind", "f_wind2"], "print": ["f_print", "h_print"]}[sign]
        tr.append({"id": "ws_%d" % n, "when": {"all": [{"stay": {"tag": "ferrer", "area": "ws_%d" % n, "secs": INSPECT_SECS}}, LIVE]}, "do": [
            {"counter": {"name": "inspected", "add": 1}}, {"say": say}]})
    tr.append({"id": "print_type", "when": {"all": [{"fired": "ws_5"}, LYON_KNOWN]}, "delay": 8, "do": [{"say": ["f_type"]}]})
    tr.append({"id": "print_plain", "when": {"all": [{"fired": "ws_5"}, LYON_UNKNOWN]}, "delay": 8, "do": [{"say": ["f_type_no"]}]})
    return tr


def riot_units():
    out = []
    for d, (cs, sp, wd) in RIOT.items():
        for kind, n in (("clock_soldier", cs), ("springer", sp), ("winder", wd)):
            out.append({"spawn": {"team": "works", "kind": kind, "count": n, "at": "bank", "tag": "broken", "order": "hold", "fixed": True,
                                  "if": {"difficulty": d}}})
    out.append({"spawn": {"team": "works", "kind": "clock_soldier", "count": PEOPLE_MORE, "at": "bank", "tag": "broken", "tags": ["salvaged"],
                          "order": "hold", "fixed": True, "if": PEOPLE}})
    return out


# the earthworks: a02's line, all of it dug now; the road gate kept, the meadow gate an open gap for the carts
mp = json.load(open(os.path.join(ROOT, "campaign", "maps", "furth_works.json")))
MW, MH = mp["size"]
CELLS = mp["cells"]
LINE_X = 58
ROAD_GATE = (18, 19)
MEADOW_GAP = (47, 48, 49, 50)


def free(x, y):
    return CELLS[y * MW + x] == "."


EARTH = [[LINE_X, y] for y in list(range(1, 37)) + list(range(39, 60)) if free(LINE_X, y) and y not in MEADOW_GAP]
GATES = [c for c in EARTH if c[1] in ROAD_GATE]
WALLS = [c for c in EARTH if c[1] not in ROAD_GATE]

M = {
    "id": MID,
    "title": "Father Ferrer's Visit",
    "summary": "Fürth, autumn 2769. The Roman College sends Father Ferrer to inspect the guild's works before the Church decides what to do about Nuremberg. He finds more than he was told.",
    "map": "campaign:furth_works",
    "voice": "a04",
    "light": "day",
    "expansion_spots": False,
    "manual_end": True,
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {"clocks": 0.85, "spawns": 1.25}},
    "modes": ["solo", "coop", "versus"],
    "sides": [
        {"id": "visit", "name": "Father Ferrer's Visit", "about": "The Roman College's inspector, his lay brothers and a Franconian escort, with Meister Hollweg's guild."},
        {"id": "machine", "name": "The Machine", "about": "Nuremberg's masters, across the water meadows. Its gear ground has crept closer."},
    ],
    "teams": [
        {"id": "party", "side": "visit", "faction": "crown", "colour": 4, "start": "none", "camera": "town", "gold": 0, "powder": 300,
         "control": {"solo": "p1", "coop": "p1", "versus": "p1"}},
        {"id": "guild", "side": "visit", "faction": "clockwork", "colour": 0, "start": "standard", "hall": [44, 16], "hall_tag": "honest",
         "camera": "yard", "gold": 300, "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "works", "side": "visit", "faction": "clockwork", "colour": 6, "start": "none", "camera": "yard",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "machine", "side": "machine", "faction": "clockwork", "colour": 1, "start": "none", "camera": "meadow", "gold": 0,
         "roster": {"deny": ["cog_press", "mainspring", "cuckoo_house", "cuckoo", "great_winder", "brass_serpent", "serpent_gear_s",
                             "serpent_gear_b", "ballista"]},
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": dict(
        {"ws_%d" % (i + 1): s[2] for i, s in enumerate(SHOPS)},
        town=[36, 2, 14, 6], yard=[32, 11, 23, 17], barn=[31, 14, 4, 9], honest_ring=[40, 13, 14, 10],
        # the night Winder's way: out of the yard, round by the town and the line's back, down to the river
        w_start=[42, 12, 3, 2], w_town=[40, 8, 4, 2], w_camp=[52, 8, 3, 2], w_line=[54, 24, 3, 3], bank=[50, 31, 6, 4],
        bank_watch=[44, 26, 14, 10], mesh_at=[52, 32, 2, 2],
        # the riot's way to the machine: the bridge, the south bank, the open gap, the machine's ground
        bridge=[39, 34, 6, 8], bridge_s=[40, 41, 6, 4], gap=[55, 45, 6, 7], meadow_ground=[67, 39, 22, 15], meadow=[74, 41, 12, 9],
        road_gate=[55, 15, 7, 8], inside_n=[50, 15, 6, 8], inside_s=[48, 44, 7, 7], behind_line=[30, 1, 28, 58],
        link_n=[84, 19, 6, 6], link_s=[86, 52, 6, 6], north_gate=[102, 14, 11, 9], south_gate=[102, 44, 11, 9],
    ),
    "counters": {"inspected": {"start": 0, "of": 6}, "riot": {"start": 0}, "lost_to_machine": {"start": 0}, "dark": {"start": 0},
                 "turning": {"start": 0}, "spotted": {"start": 0}},
    "exits": [{"area": "meadow_ground", "tag": "rioters", "counter": "lost_to_machine", "after": "riot"}],
    "units": [
        # ---- Ferrer's party (the player)
        {"team": "party", "kind": "missionary", "as": "ferrer_visit", "count": 1, "at": "town", "tag": "ferrer"},
        {"team": "party", "kind": "missionary", "as": "lay_brother", "count": 2, "at": "town", "tag": "brothers", "fixed": True},
        {"team": "party", "kind": "musketeer", "count": 8, "at": "town", "tag": "escort", "if": STRONG, "fixed": True},
        {"team": "party", "kind": "musketeer", "count": 5, "at": "town", "tag": "escort", "if": THIN, "fixed": True},
        # the line's gate men (the Franconians lend them to the Father)
        {"team": "party", "kind": "musketeer", "count": 4, "at": "inside_s", "tag": "gap_men", "order": "hold", "fixed": True},
        {"team": "party", "kind": "musketeer", "count": 3, "at": "road_gate", "tag": "gate_men", "order": "hold", "fixed": True},
        # ---- the guild (its Clocktower, presses and Winders are the standard start: the Honest One)
        {"team": "guild", "kind": "missionary", "as": "hollweg", "count": 1, "at": [42, 8], "tag": "hollweg"},
        {"team": "guild", "kind": "labourer", "as": "jakob", "count": 1, "at": [50, 25], "tag": "jakob", "if": JAKOB},
        {"team": "guild", "kind": "clock_soldier", "count": 6, "at": "yard", "tag": "g_guard"},
        {"team": "guild", "kind": "springer", "count": 2, "at": "yard", "tag": "g_guard"},
        {"team": "guild", "kind": "pendulum", "count": 1, "at": [47, 28], "tag": "g_pendulum"},
        # ---- the works' own automata (the sign in the Escapement)
    ] + shop_units() + [
        # ---- the machine: a garrison on its meadow ground (a person's army in versus)
        {"team": "machine", "kind": "clock_soldier", "count": 4, "at": "meadow", "tag": "m_guard", "order": "hold", "if": NO_MACHINE},
        {"team": "machine", "kind": "clock_soldier", "count": 6, "at": "meadow", "tag": "m_start", "if": MACHINE},
        {"team": "machine", "kind": "springer", "count": 2, "at": "meadow", "tag": "m_start", "if": MACHINE},
        {"team": "machine", "kind": "winder", "count": 3, "at": "meadow", "tag": "m_start", "if": MACHINE},
    ],
    "buildings": [
        # the machine's ground: its seeds by Nuremberg's gates and, crept west, one on the meadows with its links
        {"team": "machine", "kind": "clocktower", "at": "north_gate", "tag": "seed_n"},
        {"team": "machine", "kind": "clocktower", "at": "south_gate", "tag": "seed_s"},
        {"team": "machine", "kind": "clocktower", "at": [78, 43], "tag": "seed_meadow"},
        {"team": "machine", "kind": "regulator", "at": "link_n", "tag": "links"},
        {"team": "machine", "kind": "regulator", "at": "link_s", "tag": "links"},
        {"team": "machine", "kind": "regulator", "at": [70, 46], "tag": "links"},
        {"team": "machine", "kind": "movement_works", "at": [82, 48], "tag": "m_works", "if": MACHINE},
    ]
    + [{"team": "guild", "kind": s[0], "at": s[1], "tag": "shop_%d" % (i + 1), "tags": ["shops"]} for i, s in enumerate(SHOPS)]
    + [{"team": "party", "kind": "wall", "at": c, "tag": "earthworks"} for c in WALLS]
    + [{"team": "party", "kind": "gate", "at": c, "tag": "earthworks"} for c in GATES],
    "objectives": [
        # ---- the visit: part 1
        {"id": "inspect", "side": "visit", "primary": True, "kind": "manual",
         "text": "Inspect the guild's six workshops: {inspected} of 6. Bring Father Ferrer into each and keep him there a few seconds."},
        {"id": "dusk", "side": "visit", "primary": False, "kind": "countdown", "clock": "dusk",
         "text": "The works shut at dusk: {clock:dusk}."},
        {"id": "jakob_bin", "side": "visit", "primary": True, "kind": "manual", "hidden": True,
         "text": "Jakob wants a word with the Father, away from his master."},
        {"id": "log", "side": "visit", "primary": True, "kind": "reach", "area": "barn", "tag": "ferrer", "secs": 6, "hidden": True,
         "text": "Read Jakob's old log in Hollweg's barn."},
        {"id": "ferrer", "side": "visit", "primary": True, "kind": "protect", "tag": "ferrer", "text": "Father Ferrer must live."},
        {"id": "hollweg", "side": "visit", "primary": True, "kind": "protect", "tag": "hollweg", "text": "Meister Hollweg must live."},
        {"id": "jakob", "side": "visit", "primary": False, "kind": "protect", "tag": "jakob", "hidden": True, "text": "Jakob must live."},
        # ---- part 2
        {"id": "follow", "side": "visit", "primary": True, "kind": "manual", "hidden": True,
         "text": "Follow the night Winder. Keep it within 8 tiles, and never closer than 3, or it turns back."},
        {"id": "dawn", "side": "visit", "primary": False, "kind": "countdown", "clock": "dawn", "hidden": True,
         "text": "Dawn in {clock:dawn}."},
        {"id": "watch", "side": "visit", "primary": True, "kind": "manual", "hidden": True,
         "text": "Watch from the bank: bring the Father near the river where the Winder stopped."},
        # ---- part 3
        {"id": "riot", "side": "visit", "primary": True, "kind": "manual", "hidden": True,
         "text": "Stop the broken automata before they reach the machine's ground across the meadows. Lost to the machine: {lost_to_machine}."},
        # ---- the machine (versus)
        {"id": "m_take", "side": "machine", "primary": True, "kind": "manual",
         "text": "Kill Father Ferrer, or bring 6 of the guild's broken automata to your ground: {lost_to_machine} of 6. They wake at night."},
    ],
    "triggers": [
        # ================================================================ THE START
        {"id": "setup", "when": {"time": 0.5}, "do": [
            {"spare": {"tag": "seed_n", "on": True}}, {"spare": {"tag": "seed_s", "on": True}},
            {"spare": {"tag": "pair", "on": True}}, {"spare": {"tag": "shops", "on": True}}]},
        {"id": "spare_meadow", "when": {"all": [{"time": 0.5}, NO_MACHINE]}, "do": [{"spare": {"tag": "seed_meadow", "on": True}}, {"spare": {"tag": "links", "on": True}}]},
        {"id": "intro", "when": {"all": [{"time": 1.5}, VISIT]}, "do": [
            {"say": ["f_1", "h_1", "b_tip1"]}, {"ping": {"area": "ws_1"}}, {"ping": {"area": "ws_6"}},
            {"order": {"tag": "hollweg", "do": "follow", "leader": "ferrer", "within": 3}}]},
        {"id": "intro_thin", "when": {"all": [{"fired": "intro"}, THIN]}, "delay": 14, "do": [{"say": ["f_thin"]}]},
        {"id": "intro_m", "when": {"all": [{"time": 1.5}, MACHINE]}, "do": [
            {"say": ["m_intro", "m_tip"]}, {"give": {"team": "machine", "gold": 400, "tension": 150}}, {"ping": {"area": "town"}}]},
        {"id": "dusk_clock", "when": {"time": 1}, "do": [{"clock": {"name": "dusk", "secs": DUSK}}]},
        {"id": "tip_pend", "when": {"all": [{"fired": "intro"}]}, "delay": 30, "do": [{"say": ["h_heavy"]}, {"ping": {"tag": "g_pendulum"}}]},
        # ================================================================ PART 1: THE INSPECTION
    ] + shop_triggers() + [
        # at the third workshop Hollweg is called away to the presses: Jakob comes to the Father (he tells him, not Hollweg)
        {"id": "called_away", "when": {"all": [{"counter": {"name": "inspected", "at_least": 3}}, LIVE]}, "do": [
            {"say": ["j_call"]}, {"order": {"tag": "hollweg", "do": "move", "to": "barn"}}]},
        {"id": "jakob_comes", "when": {"all": [{"fired": "called_away"}, JAKOB, {"not": {"dead": "jakob"}}]}, "delay": 4, "do": [
            {"objective": {"id": "jakob_bin", "set": "active"}}, {"say": ["j_word"]},
            {"order": {"tag": "jakob", "do": "follow", "leader": "ferrer", "within": 1}}, {"ping": {"tag": "jakob"}}]},
        {"id": "jakob_obj", "when": {"all": [{"time": 0.5}, JAKOB, VISIT]}, "do": [{"objective": {"id": "jakob", "set": "active"}}]},
        {"id": "jakob_told", "when": {"all": [{"fired": "jakob_comes"}, {"near": {"tag": "jakob", "to": "ferrer", "within": 2}}]}, "do": [
            {"say": ["j_bin", "f_bin", "j_bin2"]}, {"objective": {"id": "jakob_bin", "set": "done"}}, {"flag": {"stopworks": "found"}},
            {"order": {"tag": "jakob", "do": "move", "to": "barn"}}]},
        # (Jakob died before he could speak: the log is in the barn after all)
        {"id": "jakob_gone_p1", "when": {"all": [{"fired": "called_away"}, JAKOB, {"dead": "jakob"}, {"not": {"fired": "jakob_told"}}]}, "do": [
            {"objective": {"id": "jakob_bin", "set": "hidden"}}]},
        # Jakob lost (c01 or a02): Ferrer reads his old log, two years old, in the barn
        {"id": "log_obj", "when": {"all": [{"counter": {"name": "inspected", "at_least": 6}},
                                           {"any": [NO_JAKOB, {"fired": "jakob_gone_p1"}]}, LIVE]}, "do": [
            {"objective": {"id": "log", "set": "active"}}, {"say": ["f_log0"]}, {"ping": {"area": "barn"}}]},
        {"id": "log_read", "when": {"done": "log"}, "do": [{"say": ["f_log", "f_log2", "h_log"]}, {"flag": {"stopworks": "logged"}}]},
        {"id": "inspected_all", "when": {"counter": {"name": "inspected", "at_least": 6}}, "do": [{"objective": {"id": "inspect", "set": "done"}}]},
        # the dusk: the works shut with the inspection unfinished (a loss)
        {"id": "dusk_out", "when": {"all": [{"clock_out": "dusk"}, {"not": {"fired": "part2"}}, LIVE]}, "do": [
            {"say": ["n_dusk"]}, {"objective": {"id": "inspect", "set": "failed"}}, {"objective": {"id": "m_take", "set": "done"}}]},
        {"id": "dusk_warn", "when": {"all": [{"clock_left": {"name": "dusk", "below": 90}}, {"not": {"fired": "part2"}}, VISIT]}, "do": [{"say": ["h_dusk"]}]},
        # ================================================================ PART 2: THE NIGHT SHIFT
        {"id": "part2", "when": {"all": [{"fired": "inspected_all"}, {"any": [{"fired": "jakob_told"}, {"fired": "log_read"}]}, LIVE]}, "delay": 6, "do": [
            {"clock": {"name": "dusk", "stop": True}},
            {"objective": {"id": "inspect", "set": "hidden"}}, {"objective": {"id": "dusk", "set": "hidden"}},
            {"objective": {"id": "jakob_bin", "set": "hidden"}}, {"objective": {"id": "log", "set": "hidden"}},
            {"light": {"to": "dusk", "secs": 20}},
            {"order": {"tag": "hollweg", "do": "move", "to": "barn"}}, {"order": {"tag": "jakob", "do": "move", "to": "barn"}},
            {"say": ["h_night", "f_night"]}]},
        {"id": "night", "when": {"fired": "part2"}, "delay": 20, "do": [
            {"light": {"to": "night", "secs": 20}},
            {"build": {"team": "machine", "kind": "regulator", "at": "mesh_at", "tag": "mesh", "name": "Gear ground",
                       "disguise": {"as": "guild", "within": 0, "secs": 99999}}}]
            + riot_units() + [
            {"spawn": {"team": "works", "kind": "winder", "count": 1, "at": "w_start", "tag": "night_winder", "name": "The night Winder"}},
            {"objective": {"id": "follow", "set": "active"}}, {"objective": {"id": "dawn", "set": "active"}},
            {"clock": {"name": "dawn", "secs": DAWN}},
            {"say": ["b_night", "f_follow", "b_tip2"]}, {"ping": {"tag": "night_winder"}}]},
        {"id": "leg1", "when": {"fired": "night"}, "delay": 8, "do": [
            {"order": {"tag": "night_winder", "do": "route", "route": ["w_town", "w_camp"], "name": "leg1"}}]},
        {"id": "leg2", "when": {"all": [{"route_done": "leg1"}, {"counter": {"name": "turning", "below": 1}}]}, "delay": 6, "do": [
            {"order": {"tag": "night_winder", "do": "route", "route": ["w_line"], "name": "leg2"}}]},
        {"id": "leg3", "when": {"all": [{"route_done": "leg2"}, {"counter": {"name": "turning", "below": 1}}]}, "delay": 6, "do": [
            {"order": {"tag": "night_winder", "do": "route", "route": ["bank"], "name": "leg3"}}]},
        # too close: it stops, turns and goes back the way it came; a while later it sets out again
        {"id": "spotted", "when": {"all": [{"fired": "leg1"}, {"not": {"route_done": "leg3"}}, {"counter": {"name": "turning", "below": 1}},
                                          {"near": {"team": "party", "to": "night_winder", "within": 3}}, LIVE]}, "every": 1, "do": [
            {"counter": {"name": "turning", "set": 1}}, {"counter": {"name": "spotted", "add": 1}},
            {"order": {"tag": "night_winder", "do": "move", "to": "w_start"}}, {"say": ["n_spotted"]}, {"clock": {"name": "resume", "secs": 18}}]},
        {"id": "resume", "when": {"all": [{"counter": {"name": "turning", "at_least": 1}}, {"clock_out": "resume"}, LIVE]}, "every": 1, "do": [
            {"counter": {"name": "turning", "set": 0}}, {"say": ["n_resume"]},
            {"order": {"tag": "night_winder", "do": "route", "route": ["w_town", "w_camp", "w_line", "bank"], "name": "leg3"}}]},
        # too far: a brother says where it went (it doesn't wait)
        {"id": "dark", "when": {"all": [{"fired": "leg1"}, {"not": {"route_done": "leg3"}},
                                        {"not": {"near": {"team": "party", "to": "night_winder", "within": 8}}}, LIVE]}, "every": 1, "do": [
            {"counter": {"name": "dark", "add": 1}}]},
        {"id": "lit", "when": {"all": [{"fired": "leg1"}, {"near": {"team": "party", "to": "night_winder", "within": 8}}, LIVE]}, "every": 1, "do": [
            {"counter": {"name": "dark", "set": 0}}]},
        {"id": "lost_it", "when": {"all": [{"counter": {"name": "dark", "at_least": 10}}, LIVE]}, "every": 20, "do": [
            {"say": ["b_lost"]}, {"ping": {"tag": "night_winder"}}]},
        {"id": "at_bank", "when": {"route_done": "leg3"}, "do": [
            {"objective": {"id": "follow", "set": "done"}}, {"objective": {"id": "watch", "set": "active"}}, {"say": ["b_bank"]},
            {"ping": {"area": "bank"}}]},
        {"id": "reveal", "when": {"all": [{"fired": "at_bank"}, {"any": [{"stay": {"tag": "ferrer", "area": "bank_watch", "secs": 3}},
                                                                          {"near": {"team": "party", "to": "mesh", "within": 4}}]}, LIVE]}, "do": [
            {"unmask": {"tag": "mesh"}}, {"spare": {"tag": "mesh", "on": True}}, {"objective": {"id": "watch", "set": "done"}}, {"clock": {"name": "dawn", "stop": True}},
            {"objective": {"id": "dawn", "set": "hidden"}}, {"reveal": {"area": "bank", "side": "visit", "secs": 30}},
            {"say": ["n_mesh", "f_mesh"]}]},
        {"id": "reveal_pattern", "when": {"all": [{"fired": "reveal"}, PATTERN]}, "delay": 1, "do": [{"say": ["f_pattern", "b_pattern"]}]},
        {"id": "reveal_people", "when": {"all": [{"fired": "reveal"}, PEOPLE]}, "delay": 1, "do": [{"say": ["f_people", "b_people"]}]},
        {"id": "dawn_out", "when": {"all": [{"clock_out": "dawn"}, {"not": {"fired": "reveal"}}, LIVE]}, "do": [
            {"say": ["n_dawn"]}, {"objective": {"id": "follow", "set": "failed"}}, {"objective": {"id": "m_take", "set": "done"}}]},
        # ================================================================ PART 3: THE RIOT
        {"id": "riot", "when": {"fired": "reveal"}, "delay": 12, "do": [
            {"objective": {"id": "follow", "set": "hidden"}}, {"objective": {"id": "watch", "set": "hidden"}},
            {"counter": {"name": "riot", "count": {"tag": "broken"}}},
            {"convert": {"tag": "broken", "to": "machine", "warn": 4, "as": "rioters", "sound": "campaign/off_beat"}},
            {"cage": {"tag": "pair", "on": True}}, {"spare": {"tag": "pair", "on": True}},
            {"objective": {"id": "riot", "set": "active"}}, {"say": ["n_riot", "f_riot"]}, {"ping": {"area": "gap"}}]},
        {"id": "riot_march", "when": {"fired": "riot"}, "delay": 5, "do": [
            {"order": {"tag": "rioters", "do": "move", "to": "meadow_ground"}}, {"ping": {"area": "bridge"}}]},
        # (stragglers stopped by nothing walk on every 10 s; the ones in a fight keep fighting)
        {"id": "riot_on", "when": {"all": [{"fired": "riot_march"}, LIVE]}, "every": 10, "do": [
            {"order": {"tag": "rioters", "do": "move", "to": "meadow_ground", "idle": True}}]},
        {"id": "riot_key", "when": {"fired": "riot"}, "delay": 3, "do": [{"say": ["h_key", "h_pend"]}]},
        # the machine meets them: a sortie out of its meadow ground at the gap
        {"id": "m_sortie", "when": {"all": [{"fired": "riot"}, NO_MACHINE]}, "delay": 15, "do": [
            {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 5, "at": "meadow", "tag": "sortie"}},
            {"spawn": {"team": "machine", "kind": "springer", "count": 1, "at": "meadow", "tag": "sortie"}},
            {"order": {"tag": "sortie", "do": "attack", "to": "gap"}}, {"say": ["b_sortie"]}, {"ping": {"area": "gap"}}]},
        {"id": "m_guard_out", "when": {"all": [{"fired": "riot"}, NO_MACHINE]}, "delay": 25, "do": [
            {"order": {"tag": "m_guard", "do": "attack", "to": "gap"}}]},
        # through the line the machine's sortie goes for the man who came to judge it
        {"id": "for_ferrer", "when": {"all": [{"fired": "m_sortie"}, NO_MACHINE, LIVE, {"not": {"fired": "riot_over"}}]}, "every": 8, "do": [
            {"order": {"tag": "sortie", "do": "hunt", "prey": "ferrer", "within": 10}}]},
        {"id": "riot_over", "when": {"all": [{"fired": "riot_march"}, {"dead": "rioters"}, LIVE]}, "delay": 3, "do": [
            {"objective": {"id": "riot", "set": "done"}}, {"light": {"to": "dawn", "secs": 30}},
            {"order": {"team": "machine", "do": "move", "to": "meadow"}},
            {"tally": {"flag": "lost_to_machine", "counter": "lost_to_machine", "bands": [[i, i] for i in range(0, 31)]}},
            {"say": ["n_over"]}]},
        {"id": "over_none", "when": {"all": [{"fired": "riot_over"}, {"counter": {"name": "lost_to_machine", "below": 1}}]}, "do": [{"say": ["f_none"]}]},
        {"id": "over_some", "when": {"all": [{"fired": "riot_over"}, {"counter": {"name": "lost_to_machine", "at_least": 1}}]}, "do": [{"say": ["f_some"]}]},
        # ---- THE CHOICE, THE BROKEN ONES
        {"id": "broken_choice", "when": {"fired": "riot_over"}, "delay": 6, "do": [
            {"say": ["f_melt", "h_keep"]},
            {"choice": {"id": "broken", "side": "visit", "title": "THE BROKEN ONES", "line": "h_keep", "default": "kept", "time": 120,
                        "options": [
                            {"id": "melted", "label": "MELT THEM", "about": "Father Ferrer: into the furnace, every wheel. Nothing that took out its own stop-work goes on ticking.",
                             "do": [{"say": ["f_melted", "h_melted"]}]},
                            {"id": "kept", "label": "KEEP THEM", "about": "Meister Hollweg: keep them for study. He must learn what went wrong, or it goes wrong again.",
                             "do": [{"say": ["h_kept", "f_kept"]}]}]}}]},
        {"id": "verdict", "when": {"all": [{"fired": "broken_choice"}, {"any": [{"flag": {"broken": "melted"}}, {"flag": {"broken": "kept"}}]}]},
         "delay": 1, "do": [{"flag": {"jakob": "alive"}}]},
        {"id": "jakob_lost", "when": {"all": [{"fired": "verdict"}, {"any": [NO_JAKOB, {"dead": "jakob"}]}]}, "do": [{"flag": {"jakob": "lost"}}]},
        {"id": "won", "when": {"fired": "verdict"}, "delay": 6, "do": [{"say": ["f_won"]}, {"light": {"to": "day", "secs": 10}}]},
        {"id": "the_end", "when": {"fired": "won"}, "delay": 5, "do": [{"win": "visit"}]},
        # ================================================================ DEFEATS, HURTS
        {"id": "ferrer_hurt", "when": {"all": [{"hurt": "ferrer"}, VISIT]}, "every": 60, "times": 2, "do": [{"say": ["b_hurt"]}]},
        {"id": "hollweg_hurt", "when": {"all": [{"hurt": "hollweg"}, VISIT]}, "every": 60, "times": 2, "do": [{"say": ["f_hhurt"]}, {"ping": {"tag": "hollweg"}}]},
        {"id": "jakob_dies", "when": {"all": [{"time": 2}, JAKOB, {"dead": "jakob"}]}, "do": [{"say": ["h_jakob"]}]},
        # ================================================================ THE MACHINE (a person leads it: versus)
        {"id": "m_income", "when": {"all": [{"time": 30}, MACHINE, {"not": {"dead": "seed_meadow"}}]}, "every": 30, "do": [
            {"give": {"team": "machine", "gold": 150, "tension": 15}}]},
        {"id": "m_night", "when": {"all": [{"fired": "night"}, MACHINE]}, "do": [{"say": ["m_night"]}]},
        {"id": "m_riot", "when": {"all": [{"fired": "riot"}, MACHINE]}, "delay": 5, "do": [{"say": ["m_riot"]}]},
        {"id": "m_won", "when": {"all": [MACHINE, {"counter": {"name": "lost_to_machine", "at_least": LOST_WIN}}, LIVE]}, "do": [
            {"objective": {"id": "m_take", "set": "done"}}, {"objective": {"id": "riot", "set": "failed"}}]},
    ],
    "speakers": {
        "king": {"name": "The King", "side": "visit", "portrait": "res://campaign/hub/rome_king_face.png"},
        "ferrer": {"name": "Father Ferrer", "side": "visit"},
        "hollweg": {"name": "Meister Hollweg", "side": "visit", "portrait": "res://campaign/hub/nuremberg_hollweg_face.png"},
        "jakob": {"name": "Jakob", "side": "visit"},
        "brother": {"name": "Brother Anselm", "side": "visit"},
        "narrator": {"name": "Fürth", "side": "visit"},
        "machine": {"name": "The Machine", "side": "machine"},
    },
    "lines": {
        # the opening: the King in Rome, then Ferrer
        "k_open1": {"who": "king", "text": "In the autumn of 2769 the Roman College asked me for leave to inspect the guild at Fürth."},
        "k_open2": {"who": "king", "text": "I sent Father Ferrer. He had warned Hollweg once. I wanted him to see whether he had been wrong."},
        "f_open1": {"who": "ferrer", "text": "Fürth had grown. Eighteen months of work, and the barn was a town of gears."},
        "f_open2": {"who": "ferrer", "text": "Hollweg met me at the gate. He was proud of it. He had a right to be, I thought then."},
        "k_open_m": {"who": "king", "text": "The machine had no voice. It waited across the meadows, and its ground crept west."},
        # part 1
        "f_1": {"who": "ferrer", "to": "visit", "text": "Six workshops, Meister. I will see every one."},
        "h_1": {"who": "hollweg", "to": "visit", "text": "See what you like, Father. There is nothing here to hide."},
        "b_tip1": {"who": "brother", "to": "visit", "text": "Walk the Father into each workshop and keep him there a moment. The guild shuts its doors at dusk."},
        "f_thin": {"who": "ferrer", "to": "visit", "text": "The colonel could spare me only five men. He has not forgotten the Rednitz."},
        "h_heavy": {"who": "hollweg", "to": "visit", "text": "That is our Pendulum, from the Heavy Works. One swing clears a street."},
        "f_ws1": {"who": "ferrer", "to": "visit", "text": "The Light Works. Clean benches, good men. Nothing here."},
        "f_ws3": {"who": "ferrer", "to": "visit", "text": "A cog press. Every tooth stamped with the guild's mark. Nothing here."},
        "f_ws4": {"who": "ferrer", "to": "visit", "text": "The Mainspring. Wound tight, and the stop-work on it. Nothing here."},
        "f_ws6": {"who": "ferrer", "to": "visit", "text": "The Heavy Works. Big machines, built slowly. Nothing here."},
        "f_wind": {"who": "ferrer", "to": "visit", "text": "That Winder is winding another Winder. Who told it to?"},
        "h_wind": {"who": "hollweg", "to": "visit", "text": "They help each other. It saves the journeymen's backs."},
        "f_wind2": {"who": "ferrer", "to": "visit", "text": "I will write that down, Meister."},
        "f_print": {"who": "ferrer", "to": "visit", "text": "Pamphlets in the journeymen's lockers. The Free Assembly's."},
        "h_print": {"who": "hollweg", "to": "visit", "text": "Young men read. I cannot stop them reading."},
        "f_type": {"who": "ferrer", "to": "visit", "text": "I know this type. Father Tomasz sent a page of it from Lyon. The same broken letter E."},
        "f_type_no": {"who": "ferrer", "to": "visit", "text": "Good paper, a good press. Someone pays for this."},
        "j_call": {"who": "jakob", "to": "visit", "text": "Meister, the presses need you. The big one is off its beat."},
        "j_word": {"who": "jakob", "to": "visit", "text": "Father. A word, please. Not in front of the Meister."},
        "j_bin": {"who": "jakob", "to": "visit", "text": "I found these in a bin behind the Escapement. Stop-works. Twelve of them."},
        "f_bin": {"who": "ferrer", "to": "visit", "text": "Taken out clean. Not broken. Taken out."},
        "j_bin2": {"who": "jakob", "to": "visit", "text": "Nobody here took them out, Father. I asked every man."},
        "f_log0": {"who": "ferrer", "to": "visit", "text": "Jakob kept a log in Nuremberg. Hollweg keeps it now. I want to read it."},
        "f_log": {"who": "ferrer", "to": "visit", "text": "Two years old. Winders winding each other. Machines at work with no one at the bench."},
        "f_log2": {"who": "ferrer", "to": "visit", "text": "The same signs, Meister. Written down before Nuremberg fell."},
        "h_log": {"who": "hollweg", "to": "visit", "text": "That was the Perpetual. These have stop-works."},
        "h_dusk": {"who": "hollweg", "to": "visit", "text": "We shut at dusk, Father. You have a little time left."},
        "n_dusk": {"who": "narrator", "text": "The guild shut its doors. Father Ferrer's report stayed unwritten."},
        # part 2
        "h_night": {"who": "hollweg", "to": "visit", "text": "That is all of it, Father. Sleep well. The works rest at night."},
        "f_night": {"who": "ferrer", "to": "visit", "text": "Then I will not sleep. Brothers, we stay up."},
        "b_night": {"who": "brother", "to": "visit", "text": "Father, a Winder. Alone, out of the yard. Nobody sent it."},
        "f_follow": {"who": "ferrer", "to": "visit", "text": "Follow it. Quietly."},
        "b_tip2": {"who": "brother", "to": "visit", "text": "Keep it within eight tiles. Closer than three and it will see us."},
        "n_spotted": {"who": "narrator", "to": "visit", "text": "The Winder stops. Its head turns. It goes back the way it came."},
        "n_resume": {"who": "narrator", "to": "visit", "text": "The Winder sets out again."},
        "b_lost": {"who": "brother", "to": "visit", "text": "We have lost sight of it, Father. It went that way."},
        "b_bank": {"who": "brother", "to": "visit", "text": "It stopped by the river, below the chapel. There are others there."},
        "n_mesh": {"who": "narrator", "to": "visit", "text": "On the bank the guild's automata stand in a ring on gear ground nobody laid. They are meshing."},
        "f_mesh": {"who": "ferrer", "to": "visit", "text": "Nobody built this. They built it."},
        "f_pattern": {"who": "ferrer", "to": "visit", "text": "Look at them. The Perpetual's pattern, every wheel, with a stop-work bolted on. They took it off themselves."},
        "b_pattern": {"who": "brother", "to": "visit", "text": "Then the flaw is in the drawings, Father."},
        "f_people": {"who": "ferrer", "to": "visit", "text": "Red brass in every one. Parts salvaged from the line, fitted to save time."},
        "b_people": {"who": "brother", "to": "visit", "text": "Then the flaw is in the machine, Father, whatever the drawings say."},
        "n_dawn": {"who": "narrator", "text": "Dawn came. Whatever the Winder went to do, it was done, and nobody saw it."},
        # part 3
        "n_riot": {"who": "narrator", "to": "visit", "text": "They turn red, one by one, off the beat. Then they walk for the meadows."},
        "f_riot": {"who": "ferrer", "to": "visit", "text": "They are going to the machine. Stop them before they reach its ground!"},
        "h_key": {"who": "hollweg", "to": "visit", "text": "These two in the yard still had their stop-works. I stopped them with my key. Not those."},
        "h_pend": {"who": "hollweg", "to": "visit", "text": "The Pendulum to the bridge! Let it swing through them."},
        "b_sortie": {"who": "brother", "to": "visit", "text": "The machine is coming out to meet them, at the open gap in the line!"},
        "n_over": {"who": "narrator", "to": "visit", "text": "The last of them is down or gone. Dawn over the meadows."},
        "f_none": {"who": "ferrer", "to": "visit", "text": "Not one reached it. Thank God."},
        "f_some": {"who": "ferrer", "to": "visit", "text": "Some of them reached it. It will use them."},
        # the choice
        "f_melt": {"who": "ferrer", "to": "visit", "text": "Melt them, Meister. Every wheel."},
        "h_keep": {"who": "hollweg", "to": "visit", "text": "No. Let me keep them. I must learn what went wrong."},
        "f_melted": {"who": "ferrer", "to": "visit", "text": "Into the furnace. I watched it done."},
        "h_melted": {"who": "hollweg", "to": "visit", "text": "You have burned the only witnesses, Father."},
        "h_kept": {"who": "hollweg", "to": "visit", "text": "I will find the fault. I will mend them, and show Rome they are mended."},
        "f_kept": {"who": "ferrer", "to": "visit", "text": "I wrote that down too."},
        "f_won": {"who": "ferrer", "to": "visit", "text": "I rode for Rome that morning with my report."},
        # hurts
        "b_hurt": {"who": "brother", "to": "visit", "text": "The Father is hurt! Keep the muskets round him!"},
        "f_hhurt": {"who": "ferrer", "to": "visit", "text": "Meister Hollweg is hurt. Get men to him."},
        "h_jakob": {"who": "hollweg", "to": "visit", "text": "Jakob. Not him too."},
        # the machine (no voice)
        "m_intro": {"who": "machine", "to": "machine", "text": "Tick. Tock. A priest walks in the guild's yard. Kill him."},
        "m_tip": {"who": "machine", "to": "machine", "text": "Your seed on the meadows pays cogs and Tension while it stands. At night, some of theirs will come to you."},
        "m_night": {"who": "machine", "to": "machine", "text": "Night. By the river, the guild's machines are meshing. Soon they are yours."},
        "m_riot": {"who": "machine", "to": "machine", "text": "They are walking to you. Bring them home: 6 is enough."},
        # the ending
        "f_end1": {"who": "ferrer", "text": "I wrote my report on the road. I did not soften it."},
        "f_end_melted": {"who": "ferrer", "text": "The broken ones were melted. Hollweg did not speak to me again until Rome."},
        "f_end_kept": {"who": "ferrer", "text": "The broken ones were kept. Hollweg swore he would mend them."},
        "f_end_lost": {"who": "ferrer", "text": "And some of them reached the machine. I counted them in my report."},
        "f_end_jakob": {"who": "ferrer", "text": "Jakob found the stop-works and told me. He did not tell his master. I put that in too."},
        "k_end1": {"who": "king", "text": "Ferrer's report was on my table before the snow. I read it twice."},
        "k_end_kept": {"who": "king", "text": "Hollweg brought his mended machines to Rome. I let him. That was my mistake, not his."},
        "k_end_melted": {"who": "king", "text": "Hollweg came to Rome with nothing but his drawings, and his anger."},
    },
    "stills": {
        "arrival": {"image": STILL % "a04_01", "caption": "Fürth, autumn 2769. Father Ferrer comes to inspect the guild's works."},
        "inspection": {"image": STILL % "a04_02", "caption": "The inspection: a Winder winding another."},
        "night": {"image": STILL % "a04_03", "caption": "The night shift, by the river."},
        "riot": {"image": STILL % "a04_04", "caption": "The riot across the water meadows."},
        "broken": {"image": STILL % "a04_05", "caption": "The broken ones in the yard."},
        "rome": {"image": STILL % "c01_01", "caption": "Rome, the present. The King listens; the Jesuit tells it."},
    },
    "opening": {
        "visit": [
            {"still": "rome", "lines": ["k_open1", "k_open2"]},
            {"still": "arrival", "lines": ["f_open1", "f_open2"]},
        ],
        "machine": [
            {"still": "rome", "lines": ["k_open_m"]},
        ],
    },
    "ending": {
        "visit": [
            {"still": "broken", "lines": ["f_end1",
                                         {"id": "f_end_melted", "if": {"flag": {"broken": "melted"}}},
                                         {"id": "f_end_kept", "if": {"flag": {"broken": "kept"}}},
                                         {"id": "f_end_lost", "if": {"counter": {"name": "lost_to_machine", "at_least": 1}}},
                                         {"id": "f_end_jakob", "if": {"flag": {"stopworks": "found"}}}]},
            {"still": "rome", "lines": ["k_end1",
                                       {"id": "k_end_kept", "if": {"flag": {"broken": "kept"}}},
                                       {"id": "k_end_melted", "if": {"flag": {"broken": "melted"}}}]},
        ],
        "machine": [
            {"still": "riot", "lines": ["k_open_m"]},
        ],
    },
    "briefing": {
        "visit": {"still": "arrival", "text": [
            "Fürth, autumn 2769. Father Ferrer, of the Roman College, inspects the guild's works with two lay brothers and an escort.",
            "See all six workshops before dusk. Keep the Father alive, and Meister Hollweg.",
            "The guild says the works rest at night."]},
        "machine": {"still": "riot", "text": [
            "Fürth, autumn 2769. You are the Machine, across the water meadows. A priest has come to judge the guild.",
            "Kill Father Ferrer, or take the guild's broken automata when they walk to you at night."]},
    },
    "debrief": {
        "visit": {"still": "broken", "title": "The report",
                  "text": "Father Ferrer rode for Rome with his report. Stopped: {riot} broken automata; lost to the machine: {lost_to_machine}.",
                  "text_if": [
                      {"if": {"flag": {"broken": "melted"}}, "text": "The broken ones were melted."},
                      {"if": {"flag": {"broken": "kept"}}, "text": "The broken ones were kept for study."},
                      {"if": {"flag": {"jakob": "lost"}}, "text": "Jakob is not with the guild."}]},
        "machine": {"still": "riot", "title": "The machine's",
                    "text": "Father Ferrer's report was never written. The guild's broken ones are the Machine's."},
    },
    "next": {"visit": "", "machine": ""},
}

# the scripted guild's answer to the riot (solo and versus: in co-op the friend leads the guild): the Pendulum and the
# guards to the bridge, at the crowd
M["triggers"] += [
    {"id": "g_bridge", "modes": ["solo", "versus"], "when": {"fired": "riot_march"}, "do": [
        {"order": {"tag": "g_pendulum", "do": "attack", "to": "bridge"}},
        {"order": {"tag": "g_guard", "do": "attack", "to": "bridge"}}]},
    {"id": "g_answer", "modes": ["solo", "versus"], "when": {"all": [{"fired": "riot_march"}, LIVE, {"not": {"fired": "riot_over"}}]}, "every": 4, "do": [
        {"order": {"team": "guild", "do": "hunt", "prey_team": "machine", "within": 12}}]},
]

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the guild (co-op p2) is bound to K3, the Heavy Works and the Pendulum
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID)

out = os.path.join(ROOT, "campaign", "missions", MID + ".json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(WALLS), "palisades,", len(GATES), "gates")
