#!/usr/bin/env python3
"""Writes campaign/missions/a07_council.json: Act 1's "The Council of Rome" (Lent 2770, the first crossing of the three
lines; the plan: docs/campaign_act1_plan.md "a07_council" and its OWNER ANSWERS; what was built:
docs/campaign_a07_build.md).
  python3 tools/campaign/make_a07_mission.py
The map is THE CITY GENERATOR's Rome (tools/campaign/make_rome_map.py, imported here for its areas and lots: run that
first when the town changes). EVERY LINE IS A PLACEHOLDER for the owner to rewrite. After changing a text: add its
Portuguese and Spanish to tools/i18n/campaign/a07_council.txt and run python3 tools/i18n_build.py
(tools/test_campaign_a07.gd checks every text has both).

The Church sits in council on the new machines and the new creatures; the young King tells it (the old King frames
it). Ferrer and Valadares testify; Hollweg and Lindqvist are heard and DEFY the verdict (no machine may govern itself;
the specimens are to be destroyed). That night the Assembly's last cell fires the city, the specimens break loose from
their stables and Hollweg's demonstration automata (by a04's `broken`) go wrong: the King holds Rome against fire,
creatures and machines at once, and the creatures and the machines fight each other where they meet. FOUR SIDES: the
Crown, the creatures, the automata, the Assembly's cell. THE ROSTER LADDER's C4: the CHURCH and the MISSIONARY.
  PART 1, THE VERDICT: a MID-MATCH SHOW in the council's hall, then Hollweg and Lindqvist walk out.
  PART 2, THE NIGHT OF FIRE: the first fire in the Campo Marzio, the Assembly's torch-bearers (more by a06's `varenne`
    executed), a SPREADING FIRE among the quarters' houses (men by a burning house put it out), the creatures loose in
    the north-east (their number by a05's `cages`), the automata out of the exhibition hall in the south-east (a04's
    `broken` kept: Hollweg's demonstration; melted: two pieces that fail anyway; `lost_to_machine`: the Machine's own
    among them). The people wait in their squares: Father Tomasz (or any Missionary) calls them and they make for
    Saint Peter's over their bridge; the machines' coming sends them running, and in Parione the Romans turn on them.
  PART 3, HOLD THE BRIDGES till dawn: nothing of the creatures or the machines may reach Saint Peter's Square.
NO CHOICE. FLAGS SET: `rome` few / some / all (the quarters that stood; `rome_n`), `people` few / some / many (saved;
  `people_n`), `hollweg` defied, `lindqvist` defied (always).
MODES: SOLO as the Crown; CO-OP (the friend has the garrison of the east bank); VERSUS (the friend picks the creatures
  or the automata: "versus_pick"; the other is scripted): the creatures or the automata win by crossing.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
sys.path.insert(0, HERE)
import make_rome_map   # noqa: E402

CITY = make_rome_map.build()
STILL = "res://campaign/stills/%s.jpg"
MID = "a07_council"


def past(key, value):
    return {"past": {key: value}}


# ---- the flags read (a missing flag reads as the canon)
PEOPLE_GATE = past("c01_thirteenth.gate", "people")
PATTERN = {"not": PEOPLE_GATE}                                   # (canon: the pattern)
RUNG = past("c01_thirteenth.bells", "rung")
QUIET = {"not": RUNG}                                            # (canon: kept quiet)
WITHHELD = past("a03_plateau.map", "withheld")
DRAWN = {"not": WITHHELD}                                        # (canon: drawn)
BURNED = past("b01_specimen.clutch", "burned")
SAVED_EGGS = {"not": BURNED}                                     # (canon: saved)
TOLD = past("b01_specimen.teles", "told")
TELES_QUIET = {"not": TOLD}                                      # (canon: quiet)
EGGS_TAKEN = past("a05_specimens.eggs", "taken")
MELTED = past("a04_visit.broken", "melted")
KEPT = {"not": MELTED}                                           # (canon: kept)
MACHINE_OWN = {"any": [past("a04_visit.lost_to_machine", n) for n in range(2, 13)]}
EXECUTED = past("a06_barricades.varenne", "executed")
SPARED = {"not": EXECUTED}                                       # (canon: spared)
FEW_CAGES = {"any": [past("a05_specimens.cages", "few"), past("a05_specimens.cages", "none")]}
ALL_CAGES = past("a05_specimens.cages", "all")
SOME_CAGES = {"not": {"any": [FEW_CAGES, ALL_CAGES]}}            # (canon: some)

CROWN = {"playing": "crown"}
CREATURES_P = {"playing": "creatures"}
AUTOMATA_P = {"playing": "automata"}
LIVE = {"not": {"fired": "the_end"}}
P2 = {"fired": "part2"}
P3 = {"fired": "part3"}

BRIDGES = ["ponte_ripetta", "ponte_sant_angelo", "ponte_sisto"]
QUARTERS = make_rome_map.QUARTERS
EAST = ["campo_marzio", "parione", "regola"]
SQUARE = {q[0]: q[2] for q in QUARTERS}
# the people of each east quarter: their square, how many, and the way to Saint Peter's over their bridge
PEOPLE = {
    "campo_marzio": (6, ["popolo_square", "ponte_ripetta_e", "ponte_ripetta_w", "piazza_in", "steps"]),
    "parione": (6, ["navona", "ponte_sant_angelo_e", "ponte_sant_angelo_w", "borgo_street", "steps"]),
    "regola": (6, ["campo_fiori", "ponte_sisto_e", "ponte_sisto_w", "via_lungara", "piazza_in", "steps"]),
}
PEOPLE_TOTAL = sum(v[0] for v in PEOPLE.values())
# the creatures' and the automata's ways to the piazza (attack-moving: they fight whatever they meet, each other too)
CRE_ROUTES = {
    "a": ["popolo_square", "ponte_ripetta_e", "ponte_ripetta_w", "prati", "piazza_in"],
    "b": ["corso_n", "navona", "ponte_sant_angelo_e", "ponte_sant_angelo_w", "borgo_street", "piazza_in"],
}
AUT_ROUTES = {
    "a": ["campo_fiori", "ponte_sisto_e", "ponte_sisto_w", "via_lungara", "piazza_in"],
    "b": ["corso_s", "navona", "ponte_sant_angelo_e", "ponte_sant_angelo_w", "borgo_street", "piazza_in"],
}
# the Assembly's torch-bearers: (seconds after Part 2, the quarter they make for, only with `varenne` executed)
TORCHES = [(30, "parione", False), (70, "regola", False), (110, "campo_marzio", True), (150, "parione", True)]
DAWN = 540                         # seconds from Part 3 to dawn (NORMAL; the clock scales: EASY shorter, HARD longer)
WAVE_EVERY = 80                    # seconds between the creatures' waves in Part 3 (the two ways in turn)
MACHINE_EVERY = 100                # between the automata's (kept only)
FIRE = {"secs": 90, "spread": {"tag": "houses", "within": 7, "every": 18}, "douse_side": "crown",
        "douse_teams": ["guard", "garrison"], "douse_secs": 14}


def area_list():
    a = dict(CITY.areas)
    a.update(make_rome_map.areas_extra(CITY))
    a["church_lot"] = [24, 20, 12, 6]
    a["tents"] = [30, 8, 16, 10]
    return a


def houses():
    out = []
    for nm, r, sq, sr, n in QUARTERS:
        for i in range(n):
            lot = "%s_h%d" % (nm, i + 1)
            out.append({"team": "town", "kind": "cottage", "at": CITY.lots[lot]["at"], "tag": "q_" + nm, "tags": ["houses", lot],
                        "name": "Houses"})
    return out


def creature_units():
    """The specimens in their stables (caged until they break loose): by a05's `cages` (few / some / all)."""
    pen = "stables_pen"
    base = {"team": "creatures", "at": pen, "tag": "specimens", "tags": ["creatures_all"]}
    return [
        dict(base, kind="raptor", count=3, **{"if": FEW_CAGES}),
        dict(base, kind="spitter", count=1, **{"if": FEW_CAGES}),
        dict(base, kind="raptor", count=4, **{"if": SOME_CAGES}),
        dict(base, kind="spitter", count=2, **{"if": SOME_CAGES}),
        dict(base, kind="raptor", count=5, **{"if": ALL_CAGES}),
        dict(base, kind="spitter", count=2, **{"if": ALL_CAGES}),
        dict(base, kind="tyrant_challenger", count=1, **{"if": ALL_CAGES}),
        dict(base, kind="tyrannosaur", count=1, fixed=True, **{"as": "young_sire", "name": "The young Sire", "if": ALL_CAGES}),
        # a05's eggs taken: the plateau's clutch hatched in the stables
        dict(base, kind="raptor", count=2, **{"if": EGGS_TAKEN}),
    ]


def automata_units():
    """Hollweg's demonstration in the exhibition hall: by a04's `broken` (kept: the broken ones he brought to show mended;
    melted: two pieces he brought to show the stop-work) and `lost_to_machine` (two of the Machine's own among them)."""
    base = {"team": "automata", "at": "exhibition_floor", "tag": "demo", "tags": ["automata_all"]}
    return [
        dict(base, kind="clock_soldier", count=5, **{"if": KEPT}),
        dict(base, kind="springer", count=2, **{"if": KEPT}),
        dict(base, kind="pendulum", count=1, fixed=True, **{"if": KEPT}),
        dict(base, kind="winder", count=2, **{"if": KEPT}),
        dict(base, kind="clock_soldier", count=2, fixed=True, **{"if": MELTED}),
        dict(base, kind="springer", count=2, **{"if": MACHINE_OWN, "tags": ["automata_all", "machine_own"]}),
    ]


def people():
    out = []
    for q, (n, route) in PEOPLE.items():
        out.append({"team": "town", "kind": "labourer", "as": "roman", "count": n, "at": SQUARE[q], "tag": "people_" + q,
                    "tags": ["people"], "order": "hold", "fixed": True})
    return out


def people_triggers():
    tr = []
    for q, (n, route) in PEOPLE.items():
        go = [{"order": {"tag": "people_" + q, "do": "route", "route": route[1:], "only_team": "town", "name": "people_" + q}}]
        tr.append({"id": "call_" + q, "when": {"all": [P2, LIVE, {"not": {"fired": "flee_" + q}},
                                                        {"near": {"tag": "people_" + q, "to": "leaders", "within": 4}}]},
                   "do": go + [{"say": ["t_call"]}]})
        tr.append({"id": "flee_" + q, "when": {"all": [P2, LIVE, {"not": {"fired": "call_" + q}}, {"any": [
            {"near": {"tag": "people_" + q, "to_side": "automata", "within": 6}},
            {"near": {"tag": "people_" + q, "to_side": "creatures", "within": 6}}]}]},
                   "do": go + [{"say": ["n_flee"]}, {"ping": {"area": SQUARE[q]}}]})
    # the people of a burning quarter don't wait to be called for ever: once their square's houses burn, they run
    for q in PEOPLE:
        tr.append({"id": "smoke_" + q, "when": {"all": [P2, LIVE, {"not": {"fired": "call_" + q}}, {"not": {"fired": "flee_" + q}},
                                                         {"burning": {"tag": "q_" + q, "at_least": 3}}]},
                   "delay": 25, "do": [{"order": {"tag": "people_" + q, "do": "route", "route": PEOPLE[q][1][1:], "only_team": "town"}},
                                       {"say": ["n_smoke"]}]})
    return tr


def torch_triggers():
    tr = []
    for i, (t, q, only_exec) in enumerate(TORCHES):
        k = i + 1
        cond = [P2, LIVE] + ([EXECUTED] if only_exec else [])
        tr.append({"id": "torch_%d" % k, "when": {"all": cond}, "delay": t, "do": [
            {"spawn": {"team": "assembly", "kind": "labourer", "as": "torch", "count": 2, "at": "porta_gate", "tag": "torch_%d" % k, "tags": ["torches"]}},
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 2, "at": "porta_gate", "tag": "cell"}},
            {"order": {"tag": "torch_%d" % k, "do": "move", "to": SQUARE[q]}},
            {"order": {"tag": "cell", "do": "attack", "to": SQUARE[q], "idle": True}},
            {"ping": {"area": "porta"}}] + ([{"say": ["n_torch"]}] if k == 1 else [])})
    return tr


def wave_triggers():
    tr = []
    # the creatures' waves from the stables' cellars (the stock's young), by `cages`: two ways in turn (Ripetta, then
    # Sant'Angelo through Parione, where they meet the machines)
    for size, cond in ((4, FEW_CAGES), (6, SOME_CAGES), (8, ALL_CAGES)):
        for way, delay in (("a", 20), ("b", 20 + WAVE_EVERY)):
            tg = "cre_wave_" + way
            tr.append({"id": "cre_wave_%d%s" % (size, way), "when": {"all": [P3, LIVE, cond]}, "delay": delay, "every": 2 * WAVE_EVERY, "times": 4, "do": [
                {"spawn": {"team": "creatures", "kind": "raptor", "count": size - 2, "at": "stables_pen", "tag": tg, "tags": ["creatures_all"]}},
                {"spawn": {"team": "creatures", "kind": "spitter", "count": 2, "at": "stables_pen", "tag": tg, "tags": ["creatures_all"]}},
                {"order": {"tag": tg, "do": "route", "route": CRE_ROUTES[way], "attack": True, "idle": True}},
                {"ping": {"area": "stables"}}]})
    tr.append({"id": "cre_big", "when": {"all": [P3, LIVE, ALL_CAGES]}, "delay": 200, "do": [
        {"spawn": {"team": "creatures", "kind": "tyrant_challenger", "count": 2, "at": "stables_pen", "tag": "cre_big", "tags": ["creatures_all"]}},
        {"order": {"tag": "cre_big", "do": "route", "route": CRE_ROUTES["b"], "attack": True}}]})
    # the automata's: the crates in the exhibition hall unpacked (kept only: melted, Hollweg brought two pieces)
    for way, delay in (("b", 50), ("a", 50 + MACHINE_EVERY)):
        tg = "aut_wave_" + way
        tr.append({"id": "aut_wave_" + way, "when": {"all": [P3, LIVE, KEPT]}, "delay": delay, "every": 2 * MACHINE_EVERY, "times": 3, "do": [
            {"spawn": {"team": "automata", "kind": "clock_soldier", "count": 3, "at": "exhibition_floor", "tag": tg, "tags": ["automata_all"]}},
            {"spawn": {"team": "automata", "kind": "springer", "count": 1, "at": "exhibition_floor", "tag": tg, "tags": ["automata_all"]}},
            {"wind": {"tag": "automata_all", "share": 1.0}},
            {"order": {"tag": tg, "do": "route", "route": AUT_ROUTES[way], "attack": True, "idle": True}},
            {"ping": {"area": "exhibition"}}]})
    return tr


M = {
    "id": MID,
    "title": "The Council of Rome",
    "summary": "Rome, Lent 2770. The Church sits in council on the new machines and the new creatures. That night the city burns, the specimens break loose and the automata go wrong: the King holds the bridges until dawn.",
    "map": "campaign:rome_council",
    "voice": "a07",
    "light": "dusk",
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["a04_visit", "a05_specimens", "a06_barricades"],
    "difficulty": {"easy": {"spawns": 0.7, "clocks": 0.8}, "hard": {"spawns": 1.3, "clocks": 1.2}},
    "modes": ["solo", "coop", "versus"],
    "versus_pick": ["creatures", "automata"],
    "factions": {"free_assembly": {"name": "The Free Assembly", "stand_in": "crown", "campaign_only": True}},
    "sides": [
        {"id": "crown", "name": "The Crown", "about": "The young King, his guard and Father Tomasz, Rome's garrison on the east bank, the Swiss at Saint Peter's."},
        {"id": "creatures", "name": "The Creatures", "about": "The Academy's specimens, loose from their stables by the Porta del Popolo."},
        {"id": "automata", "name": "The Automata", "about": "Meister Hollweg's demonstration pieces, out of the exhibition hall and winding each other."},
        {"id": "assembly", "name": "The Assembly's Last Cell", "about": "The Free Assembly's last torch-bearers in Rome."},
    ],
    "teams": [
        {"id": "guard", "side": "crown", "faction": "crown", "colour": 4, "start": "none", "camera": "castel",
         "gold": 400, "powder": 250, "control": {"solo": "p1", "coop": "p1", "versus": "p1"}},
        {"id": "garrison", "side": "crown", "faction": "crown", "colour": 0, "start": "none", "camera": "ponte_sant_angelo_e",
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "town", "side": "crown", "faction": "crown", "colour": 3, "start": "none", "camera": "piazza",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "creatures", "side": "creatures", "faction": "brood", "colour": 2, "start": "none", "camera": "stables",
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
        {"id": "automata", "side": "automata", "faction": "clockwork", "colour": 1, "start": "none", "camera": "exhibition",
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
        {"id": "assembly", "side": "assembly", "faction": "free_assembly", "colour": 5, "start": "none", "camera": "porta",
         "roster": {"deny": ["town_hall", "cottage", "farm", "barracks", "musketeer", "labourer"]},
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
    ],
    "areas": area_list(),
    "counters": {"saved": {"start": 0, "of": PEOPLE_TOTAL}, "people_total": {"start": PEOPLE_TOTAL},
                 "stood": {"start": 0, "of": len(QUARTERS)}, "quarters": {"start": len(QUARTERS)}},
    "exits": [{"area": "steps", "tag": "people", "counter": "saved"}],
    "auto_tags": [{"team": "guard", "kind": "missionary", "tag": "leaders"}, {"team": "garrison", "kind": "missionary", "tag": "leaders"}],
    "torch_fire": dict(FIRE, tag="houses"),
    "units": [
        # ---- the King's guard (the player): the King, Father Tomasz, the guard's muskets, riders and guns
        {"team": "guard", "kind": "dismounted", "as": "king_young", "count": 1, "at": "castel_yard", "tag": "king"},
        {"team": "guard", "kind": "missionary", "as": "tomasz", "count": 1, "at": "castel_yard", "tag": "tomasz", "tags": ["leaders"]},
        {"team": "guard", "kind": "musketeer", "count": 14, "at": "castel_yard", "tag": "guard_men"},
        {"team": "guard", "kind": "cuirassier", "count": 4, "at": "castel_yard", "tag": "riders"},
        {"team": "guard", "kind": "cannon", "count": 2, "at": "castel_yard", "tag": "guns"},
        {"team": "guard", "kind": "powder_wagon", "count": 1, "at": "castel_yard", "tag": "wagon"},
        {"team": "guard", "kind": "pikeman", "as": "swiss", "count": 6, "at": "piazza_in", "tag": "swiss", "order": "hold"},
        # ---- the garrison of the east bank (the friend's in co-op): the bridges' east feet
    ] + [u for b in BRIDGES for u in (
        {"team": "garrison", "kind": "musketeer", "count": 4, "at": b + "_e", "tag": "garrison_" + b, "tags": ["garrison"], "order": "hold"},)] + [
        {"team": "garrison", "kind": "dismounted", "as": "captain_rome", "count": 1, "at": "ponte_sant_angelo_e", "tag": "captain", "tags": ["garrison"], "order": "hold"},
        # ---- the council (Part 1): standing before the palace, then gone
        {"team": "town", "kind": "missionary", "as": "ferrer", "count": 1, "at": "hall_floor", "tag": "ferrer", "tags": ["council"], "order": "hold"},
        {"team": "town", "kind": "dismounted", "as": "valadares", "count": 1, "at": "hall_floor", "tag": "valadares", "tags": ["council"], "order": "hold"},
        {"team": "town", "kind": "missionary", "as": "hollweg", "count": 1, "at": "hall_floor", "tag": "hollweg", "tags": ["council"], "order": "hold"},
        {"team": "town", "kind": "musketeer", "as": "lindqvist", "count": 1, "at": "hall_floor", "tag": "lindqvist", "tags": ["council"], "order": "hold"},
    ] + people() + creature_units() + automata_units(),
    "buildings": [
        {"team": "guard", "kind": "barracks", "at": "castel", "tag": "barracks", "name": "The Castel Sant'Angelo"},
        {"team": "guard", "kind": "powder_mill", "at": "castel", "tag": "mill"},
        {"team": "guard", "kind": "church", "at": "church_lot", "tag": "santo_spirito", "name": "Santo Spirito"},
    ] + [{"team": "guard", "kind": "cottage", "at": "tents", "tag": "tents"} for _ in range(4)] + [
        {"team": "town", "kind": "church", "at": CITY.lots["basilica"]["at"], "tag": "basilica", "name": "Saint Peter's"},
        {"team": "town", "kind": "town_hall", "at": CITY.lots["palace"]["at"], "tag": "palace", "name": "The Apostolic Palace"},
        {"team": "town", "kind": "horse_breeder", "at": "stables", "tag": "stables_bld", "name": "The Academy's stables"},
        {"team": "town", "kind": "armoury", "at": "exhibition", "tag": "exhibition_bld", "name": "The exhibition hall"},
    ] + houses(),
    "objectives": [
        # ---- the Crown
        {"id": "king", "side": "crown", "primary": True, "kind": "protect", "tag": "king", "text": "The King must live."},
        {"id": "tomasz", "side": "crown", "primary": True, "kind": "protect", "tag": "tomasz", "text": "Father Tomasz must live."},
        {"id": "bridges", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
         "text": "Hold the three bridges: nothing of the creatures or the machines may reach Saint Peter's Square."},
        {"id": "dawn", "side": "crown", "primary": False, "kind": "countdown", "clock": "dawn", "hidden": True,
         "text": "Dawn in {clock:dawn}."},
        {"id": "people", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
         "text": "The people: Father Tomasz (or a Missionary) calls each quarter to Saint Peter's. Saved: {saved} of {saved.of}."},
        {"id": "fires", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
         "text": "Put out the fires: men standing by a burning house put it out. A fire left alone spreads."},
        # ---- the creatures and the automata (scripted, or the versus friend's)
        {"id": "c_cross", "side": "creatures", "primary": True, "kind": "reach", "area": "piazza_in", "count": 3, "side_units": "creatures",
         "text": "Cross the river: bring three of your creatures into Saint Peter's Square before dawn."},
        {"id": "m_cross", "side": "automata", "primary": True, "kind": "reach", "area": "piazza_in", "count": 3, "side_units": "automata",
         "text": "Cross the river: bring three of your machines into Saint Peter's Square before dawn."},
    ],
    "triggers": [
        # ================================================================ THE START
        {"id": "setup", "when": {"time": 0.5}, "do": [
            {"spare": {"tag": "houses", "on": True}}, {"spare": {"tag": "basilica", "on": True}}, {"spare": {"tag": "palace", "on": True}},
            {"spare": {"tag": "stables_bld", "on": True}}, {"spare": {"tag": "exhibition_bld", "on": True}},
            {"spare": {"tag": "council", "on": True}}, {"spare": {"tag": "people", "on": True}},
            {"cage": {"tag": "specimens", "on": True}}, {"spare": {"tag": "specimens", "on": True}},
            {"cage": {"tag": "demo", "on": True}}, {"spare": {"tag": "demo", "on": True}},
            {"wind": {"tag": "demo", "share": 1.0}}]},
        # ================================================================ PART 1: THE VERDICT
        {"id": "verdict", "when": {"time": 2}, "do": [
            {"show": {"pages": [
                {"still": "verdict", "lines": ["c_verdict1", "c_verdict2"]},
                {"still": "defiance", "lines": ["h_defy", "l_defy", "k_letgo"]}]}}]},
        {"id": "walk_out", "when": {"fired": "verdict"}, "delay": 3, "do": [
            {"say": ["n_walkout"]},
            {"spare": {"tag": "hollweg", "on": True}}, {"spare": {"tag": "lindqvist", "on": True}},
            {"order": {"tag": "hollweg", "do": "route", "route": ["borgo_street", "ponte_sant_angelo_w", "ponte_sant_angelo_e", "via_papalis", "exhibition"], "name": "hollweg_out"}},
            {"order": {"tag": "lindqvist", "do": "route", "route": ["borgo_street", "ponte_sant_angelo_w", "ponte_sant_angelo_e", "via_ripetta", "stables"], "name": "lindqvist_out"}},
            {"order": {"tag": "ferrer", "do": "move", "to": "steps"}}, {"order": {"tag": "valadares", "do": "move", "to": "steps"}},
            {"flag": {"hollweg": "defied", "lindqvist": "defied"}}]},
        {"id": "tips", "when": {"all": [{"fired": "walk_out"}, CROWN]}, "delay": 6, "do": [
            {"say": ["k_1", "t_1", "k_tip_bridges"]}, {"ping": {"area": "ponte_ripetta"}}, {"ping": {"area": "ponte_sant_angelo"}}, {"ping": {"area": "ponte_sisto"}}]},
        {"id": "intro_cre", "when": {"all": [{"time": 4}, CREATURES_P]}, "do": [{"say": ["cr_1"]}]},
        {"id": "intro_aut", "when": {"all": [{"time": 4}, AUTOMATA_P]}, "do": [{"say": ["au_1"]}]},
        {"id": "council_gone", "when": {"any": [{"route_done": "hollweg_out"}, {"fired": "part2"}]}, "delay": 1, "do": [{"remove": {"tag": "hollweg"}}]},
        {"id": "council_gone2", "when": {"any": [{"route_done": "lindqvist_out"}, {"fired": "part2"}]}, "delay": 1, "do": [{"remove": {"tag": "lindqvist"}}]},
        {"id": "council_in", "when": {"fired": "walk_out"}, "delay": 25, "do": [{"remove": {"tag": "ferrer"}}, {"remove": {"tag": "valadares"}}]},
        # the King's treasury pays the guard
        {"id": "pay", "when": {"all": [{"time": 60}, LIVE]}, "every": 60, "do": [{"give": {"team": "guard", "gold": 80, "powder": 30}}]},
        # ================================================================ PART 2: THE NIGHT OF FIRE
        {"id": "part2", "when": {"time": 50}, "do": [
            {"light": {"to": "fire_night", "secs": 20}},
            {"burn": dict(FIRE, tag="q_campo_marzio", first=True)},
            {"spare": {"tag": "people", "on": False}},
            {"say": ["n_fire1", "k_2"]},
            {"objective": {"id": "people", "set": "active"}}, {"objective": {"id": "fires", "set": "active"}},
            {"ping": {"area": "popolo_square"}}, {"reveal": {"area": "campo_marzio", "side": "crown", "secs": 30}}]},
        {"id": "cell_spared", "when": {"all": [P2, SPARED, CROWN]}, "delay": 12, "do": [{"say": ["n_cell_spared"]}]},
        {"id": "cell_exec", "when": {"all": [P2, EXECUTED, CROWN]}, "delay": 12, "do": [{"say": ["n_cell_exec"]}]},
        {"id": "cell_bridges", "when": {"all": [P2, EXECUTED, LIVE]}, "delay": 90, "do": [
            {"spawn": {"team": "assembly", "kind": "musketeer", "as": "militia", "count": 3, "at": "porta_gate", "tag": "bridge_cell"}},
            {"order": {"tag": "bridge_cell", "do": "attack", "to": "ponte_sant_angelo_e"}}]},
        {"id": "tip_people", "when": {"all": [P2, CROWN]}, "delay": 20, "do": [{"say": ["t_people", "tip_church"]}, {"point": {"kind": "church"}}]},
        {"id": "tip_fire", "when": {"all": [P2, CROWN, {"burning": {"tag": "houses", "at_least": 2}}]}, "do": [{"say": ["tip_fire"]}]},
        # the specimens break loose (the fire reaches their stables; the Assembly's men open the pens)
        {"id": "loose", "when": {"all": [P2, LIVE]}, "delay": 70, "do": [
            {"cage": {"tag": "specimens", "on": False}}, {"spare": {"tag": "specimens", "on": False}},
            {"say": ["n_loose", "l_loose"]}, {"ping": {"area": "stables"}}, {"reveal": {"area": "stables", "side": "crown", "secs": 20}},
            {"order": {"tag": "specimens", "do": "route", "route": CRE_ROUTES["a"], "attack": True, "kind": ["raptor", "tyrannosaur"]}},
            {"order": {"tag": "specimens", "do": "route", "route": CRE_ROUTES["b"], "attack": True, "kind": ["spitter", "tyrant_challenger"]}}]},
        # Hollweg's demonstration goes wrong (kept) / the two pieces fail anyway (melted)
        {"id": "demo_wrong", "when": {"all": [P2, LIVE, KEPT]}, "delay": 110, "do": [
            {"cage": {"tag": "demo", "on": False}}, {"spare": {"tag": "demo", "on": False}}, {"wind": {"tag": "automata_all", "share": 1.0}},
            {"say": ["n_demo", "h_demo"]}, {"ping": {"area": "exhibition"}}, {"reveal": {"area": "exhibition", "side": "crown", "secs": 20}},
            {"order": {"tag": "demo", "do": "route", "route": AUT_ROUTES["a"], "attack": True, "kind": ["clock_soldier", "winder"]}},
            {"order": {"tag": "demo", "do": "route", "route": AUT_ROUTES["b"], "attack": True, "kind": ["springer", "pendulum"]}}]},
        {"id": "demo_fail", "when": {"all": [P2, LIVE, MELTED]}, "delay": 110, "do": [
            {"cage": {"tag": "demo", "on": False}}, {"spare": {"tag": "demo", "on": False}}, {"wind": {"tag": "automata_all", "share": 1.0}},
            {"say": ["n_demo_melted", "h_demo_melted"]}, {"ping": {"area": "exhibition"}},
            {"order": {"tag": "demo", "do": "route", "route": AUT_ROUTES["b"], "attack": True}}]},
        {"id": "machine_own", "when": {"all": [{"fired": "demo_wrong"}, MACHINE_OWN, CROWN]}, "delay": 10, "do": [{"say": ["k_machine_own"]}]},
        # the automata wind each other (the broken ones took their own stop-works out): kept wound while they last
        {"id": "self_wind", "when": {"all": [P2, LIVE]}, "every": 15, "do": [{"wind": {"tag": "automata_all", "share": 1.0}}]},
        # THE ROMANS FEAR THE MACHINES: in Parione they turn on them
        {"id": "mob", "when": {"all": [P2, LIVE, {"near": {"tag": "people_parione", "to_side": "automata", "within": 9}}]}, "do": [
            {"spawn": {"team": "town", "kind": "pikeman", "as": "roman_mob", "count": 4, "at": "navona", "tag": "mob"}},
            {"order": {"tag": "mob", "do": "hunt", "prey": "automata_all", "within": 30}},
            {"say": ["n_mob"]}]},
        {"id": "meet", "when": {"all": [P2, LIVE, {"near": {"side": "creatures", "to_side": "automata", "within": 5}}, CROWN]}, "do": [{"say": ["n_meet", "k_meet"]}]},
        # ================================================================ PART 3: HOLD THE BRIDGES
        {"id": "part3", "when": {"all": [{"fired": "loose"}, {"any": [{"fired": "demo_wrong"}, {"fired": "demo_fail"}]}, LIVE]}, "delay": 60, "do": [
            {"clock": {"name": "dawn", "secs": DAWN}},
            {"objective": {"id": "bridges", "set": "active"}}, {"objective": {"id": "dawn", "set": "active"}},
            {"say": ["k_3", "t_3"]}, {"ping": {"area": "piazza"}}]},
        {"id": "dawn_near", "when": {"all": [P3, {"clock_left": {"name": "dawn", "below": 90}}, LIVE]}, "do": [
            {"light": {"to": "grey_dawn", "secs": 80}}, {"weather": "rain"}, {"say": ["n_rain"]}]},
        {"id": "crossed", "when": {"all": [LIVE, {"any": [{"done": "c_cross"}, {"done": "m_cross"}]}]}, "do": [
            {"say": ["n_crossed"]}, {"objective": {"id": "bridges", "set": "failed"}}]},
        {"id": "dawn_out", "when": {"all": [P3, {"clock_out": "dawn"}, LIVE]}, "do": [
            {"objective": {"id": "bridges", "set": "done"}}, {"objective": {"id": "dawn", "set": "hidden"}}]},
    ] + [
        {"id": "stood_" + q[0], "when": {"all": [{"fired": "dawn_out"}, {"count": {"tag": "q_" + q[0], "buildings": True, "at_least": (q[4] + 1) // 2}}]},
         "do": [{"counter": {"name": "stood", "add": 1}}]}
        for q in QUARTERS
    ] + [
        {"id": "dawn_won", "when": {"fired": "dawn_out"}, "delay": 1, "do": [
            {"tally": {"flag": "rome", "counter": "stood", "of": "quarters", "bands": [[0, "few"], [0.5, "some"], [1, "all"]]}},
            {"tally": {"flag": "people", "counter": "saved", "of": "people_total", "bands": [[0, "few"], [0.4, "some"], [0.75, "many"]]}},
            {"say": ["k_dawn", "t_dawn"]}, {"light": {"to": "dawn", "secs": 10}}]},
        {"id": "the_end", "when": {"fired": "dawn_won"}, "delay": 6, "do": [{"win": "crown"}]},
        # ================================================================ THE CREATURES' / THE AUTOMATA'S WIN
        {"id": "cre_won", "when": {"done": "c_cross"}, "delay": 1, "do": [{"flag": {"rome": "few", "rome_n": 0}}]},
        {"id": "aut_won", "when": {"done": "m_cross"}, "delay": 1, "do": [{"flag": {"rome": "few", "rome_n": 0}}]},
        {"id": "king_hurt", "when": {"all": [{"hurt": "king"}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["t_king"]}]},
        {"id": "tomasz_hurt", "when": {"all": [{"hurt": "tomasz"}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["k_priest"]}]},
        {"id": "first_saved", "when": {"all": [{"counter": {"name": "saved", "at_least": 1}}, CROWN]}, "do": [{"say": ["n_saved"]}]},
    ] + people_triggers() + torch_triggers() + wave_triggers(),
    "speakers": {
        "king": {"name": "The King", "side": "crown", "portrait": "res://campaign/hub/rome_king_face.png"},
        "cardinal": {"name": "The Cardinal Dean", "side": "crown"},
        "tomasz": {"name": "Father Tomasz", "side": "crown"},
        "ferrer": {"name": "Father Ferrer", "side": "crown"},
        "valadares": {"name": "Valadares", "side": "crown"},
        "hollweg": {"name": "Meister Hollweg", "side": "automata"},
        "lindqvist": {"name": "Dr. Lindqvist", "side": "creatures"},
        "captain": {"name": "Captain of the Garrison", "side": "crown"},
        "narrator": {"name": "Rome", "side": "crown"},
        "creatures": {"name": "The Creatures", "side": "creatures"},
        "automata": {"name": "The Automata", "side": "automata"},
    },
    "lines": {
        # ---- the opening: the old King, then the council
        "k_open1": {"who": "king", "text": "Rome, Lent 2770. I was young, three years crowned. This one I tell myself: it was my city."},
        "k_open2": {"who": "king", "text": "The Church sat in council on the new machines and the new creatures. I sat with the cardinals and listened."},
        "f_pattern": {"who": "ferrer", "text": "Meister Hollweg's own drawings, Eminences. The machine at Nuremberg was drawn to build its own successor."},
        "f_people": {"who": "ferrer", "text": "My report from Nuremberg, Eminences. Drawings or no drawings, the machine went on building itself."},
        "f_quarrel": {"who": "ferrer", "text": "I told him the night before the gift. The ghost in the machine destroyed the apostasy once. It was the enemy then. It is the enemy now."},
        "v_drawn": {"who": "valadares", "text": "I drew the way up the plateau for the Crown. I saw her there, the creature from the station, grown, among her own."},
        "v_withheld": {"who": "valadares", "text": "I gave my map to the Church alone, sealed. But I saw her there, the creature from the station, grown, among her own."},
        "k_hollweg_rung": {"who": "king", "text": "Meister Hollweg came as a witness. Nuremberg's bells had rung on his word, and he had saved what he could."},
        "k_hollweg_quiet": {"who": "king", "text": "Meister Hollweg came as one accused. He had kept the bells of Nuremberg quiet."},
        "h_brass": {"who": "hollweg", "text": "My machines are not the ghost of the old age, Eminences. They are brass and springs. They could learn."},
        "k_eggs_told": {"who": "king", "text": "The eggs were no secret. Lieutenant Teles had written to the Crown about the station."},
        "k_eggs_found": {"who": "king", "text": "Under questioning it came out: Dr. Lindqvist had saved the eggs from the fire, and told no one."},
        "k_eggs_ashes": {"who": "king", "text": "Dr. Lindqvist said the eggs were ashes. It was true."},
        "l_oldest": {"who": "lindqvist", "text": "They are not monsters, Eminences. They are the oldest things alive. Study them, and you read a page of creation no one has read."},
        "k_varenne_spared": {"who": "king", "text": "A letter from Varenne in exile was read out. He condemned any fire set in his name."},
        "k_varenne_exec": {"who": "king", "text": "Varenne was dead a year. His last friends in Rome had not forgotten."},
        # ---- part 1: the verdict (the mid-match show)
        "c_verdict1": {"who": "cardinal", "text": "No machine may govern itself. Every machine that winds or mends itself shall be stopped and broken."},
        "c_verdict2": {"who": "cardinal", "text": "The specimens are to be destroyed, and their eggs with them."},
        "h_defy": {"who": "hollweg", "text": "Then you have judged what you will not understand. I will not break my life's work."},
        "l_defy": {"who": "lindqvist", "text": "Burn them, and you burn a page of God's own book. I will not."},
        "k_letgo": {"who": "king", "text": "They both walked out of the hall. I let them go. My mercy, or my mistake: I still don't know."},
        "n_walkout": {"who": "narrator", "text": "Meister Hollweg goes to his exhibition hall; Dr. Lindqvist to his stables."},
        "k_1": {"who": "king", "to": "crown", "text": "I sent my guard to the bridges that evening. I did not know why. I only knew the city was angry."},
        "t_1": {"who": "tomasz", "to": "crown", "text": "Majesty, the Romans were at the doors all day. They hate a clever machine more than they hate the devil."},
        "k_tip_bridges": {"who": "king", "to": "crown", "text": "Three bridges: Ripetta in the north, Sant'Angelo under the castle, Sisto in the south. The garrison holds their east ends."},
        # ---- part 2: the night of fire
        "n_fire1": {"who": "narrator", "text": "Fire in the Campo Marzio. The Assembly's last cell has come to Rome."},
        "k_2": {"who": "king", "to": "crown", "text": "The bells rang all over the city. Then the second fire, and the third."},
        "n_cell_spared": {"who": "narrator", "to": "crown", "text": "Only a few torch-bearers: half the cell walked away after Varenne's letter."},
        "n_cell_exec": {"who": "narrator", "to": "crown", "text": "They burn Rome for Varenne: more torches, and their muskets at the bridges."},
        "n_torch": {"who": "narrator", "to": "crown", "text": "Torch-bearers in by the Porta Pia."},
        "t_people": {"who": "tomasz", "to": "crown", "text": "The people are in the squares, Majesty, waiting for someone to tell them where to go. Let me go to them."},
        "tip_church": {"who": "king", "to": "crown", "text": "Santo Spirito trains Missionaries. Any priest can call a quarter to Saint Peter's, not only Tomasz."},
        "tip_fire": {"who": "king", "to": "crown", "text": "A fire left alone takes the next house. Men standing by a burning house put it out."},
        "t_call": {"who": "tomasz", "to": "crown", "text": "Come! To Saint Peter's, all of you, over the bridge. Stay together."},
        "n_flee": {"who": "narrator", "to": "crown", "text": "The people run from the machines and the beasts, for the bridges, with no one to lead them."},
        "n_smoke": {"who": "narrator", "to": "crown", "text": "Their houses are burning: the people of a quarter make for the river by themselves."},
        "n_saved": {"who": "narrator", "to": "crown", "text": "The first of the people reach the steps of Saint Peter's."},
        "n_loose": {"who": "narrator", "text": "The stables by the Porta del Popolo are open. The specimens are loose in the streets."},
        "l_loose": {"who": "lindqvist", "text": "Not like this! They are frightened. Let them be!"},
        "n_demo": {"who": "narrator", "text": "In the exhibition hall Hollweg's demonstration has woken. The pieces wind each other and walk out."},
        "h_demo": {"who": "hollweg", "text": "Stop! I mended them! I put the stop-works back with my own hands!"},
        "n_demo_melted": {"who": "narrator", "text": "Hollweg had brought only two pieces, to show the stop-work. In the smoke they start, and do not stop."},
        "h_demo_melted": {"who": "hollweg", "text": "The stop-work holds! It must hold. Why does it not hold?"},
        "k_machine_own": {"who": "king", "to": "crown", "text": "Two of his pieces were not his at all. They were the Machine's, from the Fürth meadows."},
        "n_mob": {"who": "narrator", "text": "In the Piazza Navona the Romans turn on the machines with pikes and stones."},
        "n_meet": {"who": "narrator", "to": "crown", "text": "Beasts and machines meet in the streets of Parione, and fall on each other."},
        "k_meet": {"who": "king", "to": "crown", "text": "Let them. Every one they kill is one fewer at my bridges."},
        # ---- part 3: the bridges
        "k_3": {"who": "king", "to": "crown", "text": "Hold the bridges until dawn. Nothing crosses to Saint Peter's."},
        "t_3": {"who": "tomasz", "to": "crown", "text": "The basilica's doors are open, Majesty. Everyone who reaches them is safe."},
        "n_rain": {"who": "narrator", "text": "Rain before dawn. The fires that are left begin to die."},
        "n_crossed": {"who": "narrator", "text": "They are in Saint Peter's Square."},
        "k_dawn": {"who": "king", "to": "crown", "text": "Dawn. The bridges held. Rome was black with smoke, and it was still Rome."},
        "t_dawn": {"who": "tomasz", "to": "crown", "text": "They are singing Lauds in the basilica, Majesty. With the doors open."},
        "t_king": {"who": "tomasz", "to": "crown", "text": "The King is hit! Guard, to the King!"},
        "k_priest": {"who": "king", "to": "crown", "text": "Keep the Father behind the line. Rome needs its priests tonight."},
        # ---- the creatures' and the automata's side (versus: no voice of their own)
        "cr_1": {"who": "creatures", "to": "creatures", "text": "The pens will open when the fire comes. Cross the river to the great square before the light."},
        "au_1": {"who": "automata", "to": "automata", "text": "The hall's doors will open when the fire comes. Wind each other. Cross the river to the great square before the light."},
        # ---- the endings
        "k_end1": {"who": "king", "text": "The verdict stood. The machines in the Papal States were stopped, and the specimens we found were destroyed."},
        "k_end_rome_all": {"who": "king", "text": "Every quarter of Rome stood. I was prouder of that than of anything I did that year."},
        "k_end_rome_some": {"who": "king", "text": "Some of Rome burned. We rebuilt it that summer, street by street."},
        "k_end_rome_few": {"who": "king", "text": "Most of the east bank burned. Rome rebuilt it, and has not forgotten."},
        "t_end_people": {"who": "tomasz", "text": "We counted them on the steps in the morning: {saved} souls from the east bank."},
        "k_end_defiance": {"who": "king", "text": "Hollweg and Lindqvist were gone by morning: Hollweg after his crates, south; Lindqvist to breed what was left, in secret."},
        "k_end2": {"who": "king", "text": "That was the first time I met them both. It was not the last."},
        "k_end_lost1": {"who": "king", "text": "That is not how it went. They never reached the square."},
        "k_end_lost2": {"who": "king", "text": "But if they had, there would have been no council, and no Church to hold one."},
    },
    "stills": {
        "rome": {"image": STILL % "p01_01", "caption": "Rome, the present. The King."},
        "council": {"image": STILL % "a07_01", "caption": "Rome, Lent 2770. The council in session."},
        "ferrer": {"image": STILL % "a07_02", "caption": "Father Ferrer testifies."},
        "valadares": {"image": STILL % "a07_03", "caption": "Valadares and his map."},
        "accused": {"image": STILL % "a07_04", "caption": "Meister Hollweg and Dr. Lindqvist before the council."},
        "verdict": {"image": STILL % "a07_05", "caption": "The verdict."},
        "defiance": {"image": STILL % "a07_04", "caption": "Hollweg and Lindqvist refuse."},
        "fire": {"image": STILL % "a07_06", "caption": "Rome burning."},
        "bridges": {"image": STILL % "a07_07", "caption": "The bridges at dawn."},
    },
    "opening": {
        "crown": [
            {"still": "rome", "lines": ["k_open1"]},
            {"still": "council", "lines": ["k_open2", {"id": "k_varenne_spared", "if": SPARED}, {"id": "k_varenne_exec", "if": EXECUTED}]},
            {"still": "ferrer", "lines": [{"id": "f_pattern", "if": PATTERN}, {"id": "f_people", "if": PEOPLE_GATE}, "f_quarrel"]},
            {"still": "valadares", "lines": [{"id": "v_drawn", "if": DRAWN}, {"id": "v_withheld", "if": WITHHELD}]},
            {"still": "accused", "lines": [{"id": "k_hollweg_rung", "if": RUNG}, {"id": "k_hollweg_quiet", "if": QUIET}, "h_brass",
                                           {"id": "k_eggs_told", "if": {"all": [SAVED_EGGS, TOLD]}},
                                           {"id": "k_eggs_found", "if": {"all": [SAVED_EGGS, TELES_QUIET]}},
                                           {"id": "k_eggs_ashes", "if": BURNED}, "l_oldest"]},
        ],
        "creatures": [
            {"still": "rome", "lines": ["k_open1"]},
            {"still": "accused", "lines": ["l_oldest"]},
            {"still": "fire", "lines": ["cr_1"]},
        ],
        "automata": [
            {"still": "rome", "lines": ["k_open1"]},
            {"still": "accused", "lines": ["h_brass"]},
            {"still": "fire", "lines": ["au_1"]},
        ],
    },
    "ending": {
        "crown": [
            {"still": "bridges", "lines": ["k_end1",
                                          {"id": "k_end_rome_all", "if": {"flag": {"rome": "all"}}},
                                          {"id": "k_end_rome_some", "if": {"flag": {"rome": "some"}}},
                                          {"id": "k_end_rome_few", "if": {"flag": {"rome": "few"}}},
                                          "t_end_people"]},
            {"still": "rome", "lines": ["k_end_defiance", "k_end2"]},
        ],
        "creatures": [{"still": "fire", "lines": ["k_end_lost1"]}, {"still": "rome", "lines": ["k_end_lost2"]}],
        "automata": [{"still": "fire", "lines": ["k_end_lost1"]}, {"still": "rome", "lines": ["k_end_lost2"]}],
    },
    "briefing": {
        "crown": {"still": "council", "text": [
            "Rome, Lent 2770. The council gives its verdict on the machines and the creatures, and that night the city burns.",
            "Hold the three bridges until dawn: nothing of the loose creatures or the runaway machines may reach Saint Peter's Square. They fight each other too.",
            "Send Father Tomasz (and the Missionaries of Santo Spirito, new) to call the people of the east bank to the basilica, and put out the fires.",
            "The King and Father Tomasz must live."]},
        "creatures": {"still": "fire", "text": [
            "Rome, Lent 2770. You are the Academy's specimens, penned in the stables by the Porta del Popolo.",
            "When the fire comes the pens open. Bring three of your creatures into Saint Peter's Square before dawn. The machines are loose too."]},
        "automata": {"still": "fire", "text": [
            "Rome, Lent 2770. You are Meister Hollweg's demonstration pieces in the exhibition hall.",
            "When the fire comes the doors open. Keep wound, and bring three of your machines into Saint Peter's Square before dawn. The beasts are loose too."]},
    },
    "debrief": {
        "crown": {"still": "bridges", "title": "Rome holds",
                  "text": "The bridges held until dawn. Saved on the steps of Saint Peter's: {saved}.",
                  "text_if": [
                      {"if": {"flag": {"rome": "all"}}, "text": "Every quarter of Rome stood."},
                      {"if": {"flag": {"rome": "some"}}, "text": "Some of Rome's quarters burned."},
                      {"if": {"flag": {"rome": "few"}}, "text": "Most of the east bank burned."}]},
        "creatures": {"still": "fire", "title": "The creatures cross the Tiber", "text": "The beasts are in Saint Peter's Square."},
        "automata": {"still": "fire", "title": "The machines cross the Tiber", "text": "The automata are in Saint Peter's Square."},
    },
    "next": {"crown": "", "creatures": "", "automata": ""},
}

if __name__ == "__main__":
    out = os.path.join(ROOT, "campaign", "missions", MID + ".json")
    # THE ROSTER LADDER (docs/campaign_roster_ladder.md): C4, the Church and the Missionary, for the King's guard. The
    # story's deny on top: no hall or farms in a city at night (the King's treasury pays).
    import roster_ladder
    roster_ladder.apply(M, MID, story_deny={"guard": ["town_hall", "farm"], "garrison": ["town_hall", "farm"]})
    with open(out, "w") as f:
        json.dump(M, f, indent="\t", ensure_ascii=False)
    print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines")
