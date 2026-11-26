#!/usr/bin/env python3
"""Writes campaign/missions/a02_furth.json: Act 1's "The Fürth Line" (the Clockmaker line, March 2768; the plan:
docs/campaign_act1_plan.md "a02_furth" and its OWNER ANSWERS; what was built: docs/campaign_a02_build.md).
  python3 tools/campaign/make_a02_mission.py
EVERY LINE IS A PLACEHOLDER for the owner to rewrite. After changing a text: add its Portuguese and Spanish to
tools/i18n/campaign/a02_furth.txt and run python3 tools/i18n_build.py (tools/test_campaign_a02.gd checks every text has
both).

Three months after Nuremberg fell the machine comes out of the gates. The guild in exile (BLUE) raises its new
Clocktower at Fürth beside the Crown's Franconian army (PURPLE); Hollweg tells it from his exile, the King frames it.
  PART 1, THE HONEST ONE: the guild's new Clocktower stands (the standard start, tagged "honest"); fit the STOP-WORK
    (Hollweg stays by it: a STAY) and build a Light Works; the army digs the earthworks (palisades laid in three stages).
  PART 2, THE SORTIE: three waves out of Nuremberg's gates (along the south bank only if c01's links were cut, both
    banks if not); hold the earthworks. Jakob (if he got out) hears each wave's ticking before it comes.
  PART 3, THE MILL: the machine seeds the Rednitz mill half way to Fürth: burn the seed and the line holds (a WIN).
THE MIRROR (solo side pick, or versus): THE MACHINE (RED) grows out of Nuremberg with the seeds' timetable as income
  (free constructs, cogs and Tension while its seeds stand) and must burn the Honest One or kill Hollweg before the
  line is finished (18:00, the raced countdown). The guild is then scripted. No narrator on the machine side.
THE PROLOGUE'S FLAGS (c01_thirteenth; a flag that is missing reads as c01's default: quiet bells, some saved, Jakob
  alive, links not cut, the pattern taken): bells (rung: a bigger army with two Field Cannons and the Light Works at
  once; quiet: a commissary, fewer men, the Light Works only once the stop-work is fitted), saved (Fürth's size: the
  refugees' cottages and labourers 0 / 4 / 8; many: the loyal quarter's signal shows the first sortie forming), jakob
  (alive: he is there and warns of each wave), cut (yes: the sorties keep to the south bank), gate (pattern: the Heavy
  Works and the Pendulum open in Part 3; people: built from memory, four more of the people's Winders instead).
"""
import json
import os

STILL = "res://campaign/stills/%s.jpg"
HERE = os.path.dirname(__file__)
ROOT = os.path.join(HERE, "..", "..")

GUILD = {"playing": "guild"}
MACHINE = {"playing": "machine"}
NO_GUILD = {"not": {"playing": "guild"}}          # the guild is scripted (the solo player leads the machine)
NO_MACHINE = {"not": {"playing": "machine"}}      # the machine is scripted (the guild's story)


def past(flag, value):
    return {"past": {"c01_thirteenth." + flag: value}}


def notpast(flag, value):
    return {"not": past(flag, value)}


RUNG = past("bells", "rung")
QUIET = notpast("bells", "rung")                  # (quiet, or not known: c01's default)
CUT = past("cut", "yes")
UNCUT = notpast("cut", "yes")
JAKOB = notpast("jakob", "lost")
PATTERN = notpast("gate", "people")
PEOPLE = past("gate", "people")
FEW = past("saved", "few")
MANY = past("saved", "many")
SOME = {"all": [notpast("saved", "few"), notpast("saved", "many")]}

DENY = ["cuckoo_house", "cuckoo", "great_winder", "brass_serpent", "serpent_gear_s", "serpent_gear_b", "ballista",
        "heavy_works", "pendulum"]
DENY_MACHINE = DENY + ["cog_press", "mainspring"]   # (its income is the seeds' timetable)

# ---------------------------------------------------------------- the earthworks: palisades on the map's free cells
mp = json.load(open(os.path.join(ROOT, "campaign", "maps", "furth_line.json")))
MW, MH = mp["size"]
CELLS = mp["cells"]
LINE_X = 58
ROAD_GATE = (18, 19)
MEADOW_GATE = (48, 49)


def free(x, y):
    return CELLS[y * MW + x] == "."


def line_cells(y0, y1, gates):
    walls, gts = [], []
    for y in range(y0, y1):
        if not free(LINE_X, y):
            continue
        (gts if y in gates else walls).append([LINE_X, y])
    return walls, gts


N_WALLS, N_GATES = line_cells(1, 37, ROAD_GATE)
S_WALLS, S_GATES = line_cells(39, 60, MEADOW_GATE)


def palisades(cells, kind="wall", tag="earthworks", cond=None):
    out = []
    for c in cells:
        b = {"build": {"team": "army", "kind": kind, "at": c, "tag": tag}}
        out.append(b)
    return out


# the army digs in three stages: the gates and the stretches next to them at once, the north bank, then the south
def near_gate(c, gates):
    return min(abs(c[1] - g) for g in gates) <= 4


STAGE0 = [c for c in N_WALLS if near_gate(c, ROAD_GATE)] + [c for c in S_WALLS if near_gate(c, MEADOW_GATE)]
STAGE1 = [c for c in N_WALLS if not near_gate(c, ROAD_GATE)]
STAGE2 = [c for c in S_WALLS if not near_gate(c, MEADOW_GATE)]


def wave(n, area, gate, kinds, cond):
    """A sortie: units out of a gate, sent at the line's gate on their bank (then on at the Honest One)."""
    tag = "sortie%d" % n
    do = [{"spawn": {"team": "machine", "kind": k, "count": c, "at": area, "tag": tag}} for k, c in kinds]
    do.append({"order": {"tag": tag, "do": "attack", "to": gate}})
    return do


def seed_grow(tid, seed, area, to, every, after, kinds, cond, cap=30):
    """A seed's growth (as c01): while it stands, every `every` s, constructs round it sent at `to` (never past `cap`)."""
    c = [{"fired": after}, {"not": {"dead": seed}}, {"count": {"team": "machine", "below": cap}}] + cond
    do = [{"spawn": {"team": "machine", "kind": k, "count": n, "at": area, "tag": "mach_" + tid}} for k, n in kinds]
    do.append({"order": {"tag": "mach_" + tid, "do": "attack", "to": to}})
    return {"id": tid, "when": {"all": c}, "every": every, "do": do}


W1_S = [("clock_soldier", 5), ("springer", 1)]
W2 = [("clock_soldier", 6), ("springer", 1), ("netter", 1)]
W3 = [("clock_soldier", 8), ("springer", 2)]
W3_S = [("clock_soldier", 5), ("springer", 1)]           # (both banks: the south half...)
W3_N = 4                                                   # (...and Clock Soldiers on the road, with a Springer)
GAP = 120                                                  # seconds between sorties

M = {
    "id": "a02_furth",
    "title": "The Fürth Line",
    "summary": "Fürth, March 2768. Three months after Nuremberg fell, the machine comes out of its gates. The guild in exile holds the line beside the Crown's army, and swears every machine it builds has a stop-work.",
    "map": "campaign:furth_line",
    "voice": "a02",
    "light": "winter_day",
    "weather": "snow",
    "expansion_spots": False,
    "manual_end": True,
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {"clocks": 0.9, "spawns": 1.2}},
    "modes": ["solo", "coop", "versus"],
    "solo_sides": ["guild", "machine"],
    "sides": [
        {"id": "guild", "name": "The Guild in Exile", "about": "Meister Hollweg's guild, rebuilt at Fürth with what it saved, beside the Crown's Franconian army."},
        {"id": "machine", "name": "The Machine", "about": "Nuremberg's new masters. They tick off the beat and they want Fürth."},
    ],
    "teams": [
        {"id": "guild", "side": "guild", "faction": "clockwork", "colour": 0, "start": "standard", "hall": [44, 16],
         "hall_tag": "honest", "camera": "yard", "gold": 400,
         "control": {"solo": "p1", "coop": "p1", "versus": "p1", "foe": "script"}},
        {"id": "army", "side": "guild", "faction": "crown", "colour": 4, "start": "none", "camera": "yard", "powder": 400,
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "town", "side": "guild", "faction": "crown", "colour": 3, "start": "none", "camera": "refugees",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "machine", "side": "machine", "faction": "clockwork", "colour": 1, "start": "none", "camera": "south_gate",
         "gold": 0, "roster": {"deny": DENY_MACHINE},
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": {
        "yard": [32, 11, 23, 17], "barn": [32, 14, 7, 9], "honest_ring": [40, 13, 14, 10], "town": [32, 3, 22, 8], "camp": [48, 2, 9, 7],
        "refugees": [43, 41, 10, 6], "inside_n": [50, 15, 6, 8], "inside_s": [47, 44, 9, 7],
        "line_n": [55, 2, 6, 33], "line_s": [55, 40, 6, 17], "road_gate": [55, 15, 7, 8], "meadow_gate": [55, 45, 7, 8],
        "road_mid": [76, 16, 14, 9], "meadow_mid": [76, 42, 14, 10], "mill": [65, 54, 12, 8], "mill_road": [62, 46, 10, 7],
        "link_n": [88, 19, 6, 6], "link_s": [88, 40, 6, 6], "old_bridge": [96, 29, 8, 9],
        "behind_line": [30, 1, 27, 58], "north_gate": [102, 14, 11, 9], "south_gate": [102, 44, 11, 9], "nuremberg": [104, 1, 23, 78],
    },
    "counters": {"sorties": {"start": 0}, "army": {"start": 0}},
    "units": [
        # ---- the guild (its Clocktower, presses and Winders are the standard start: the Honest One)
        {"team": "guild", "kind": "missionary", "as": "hollweg", "count": 1, "at": [44, 6], "tag": "hollweg"},
        {"team": "guild", "kind": "labourer", "as": "jakob", "count": 1, "at": [46, 6], "tag": "jakob", "if": JAKOB},
        {"team": "guild", "kind": "clock_soldier", "count": 4, "at": "inside_n", "tag": "guard"},
        {"team": "guild", "kind": "netter", "count": 1, "at": "inside_n", "tag": "guard"},
        # the guild's own defence when nobody leads it (the solo player is the machine)
        {"team": "guild", "kind": "clock_soldier", "count": 6, "at": "inside_s", "tag": "g_def", "order": "hold", "if": NO_GUILD},
        {"team": "guild", "kind": "springer", "count": 3, "at": "inside_n", "tag": "g_def", "order": "hold", "if": NO_GUILD},
        {"team": "guild", "kind": "netter", "count": 2, "at": "honest_ring", "tag": "g_def", "order": "hold", "if": NO_GUILD},
        {"team": "guild", "kind": "clock_soldier", "count": 5, "at": "barn", "tag": "g_def", "order": "hold", "if": NO_GUILD},
        {"team": "guild", "kind": "springer", "count": 2, "at": "barn", "tag": "g_def", "order": "hold", "if": NO_GUILD},
        # (campaign-fixes-1121: THE MIRROR HARDER: led by a person the Machine won in about seven minutes; the guild's own
        # defence is stronger at NORMAL and HARD, and it keeps building, below)
        {"team": "guild", "kind": "clock_soldier", "count": 4, "at": "barn", "tag": "g_def", "order": "hold", "fixed": True, "if": {"all": [NO_GUILD, {"difficulty": ["normal", "hard"]}]}},
        {"team": "guild", "kind": "pendulum", "count": 1, "at": "honest_ring", "tag": "g_def", "order": "hold", "fixed": True, "if": {"all": [NO_GUILD, {"difficulty": ["normal", "hard"]}]}},
        {"team": "guild", "kind": "clock_soldier", "count": 4, "at": "inside_s", "tag": "g_def", "order": "hold", "fixed": True, "if": {"all": [NO_GUILD, {"difficulty": "hard"}]}},
        {"team": "guild", "kind": "springer", "count": 2, "at": "inside_n", "tag": "g_def", "order": "hold", "fixed": True, "if": {"all": [NO_GUILD, {"difficulty": "hard"}]}},
        # ---- the Franconian army at the line
        {"team": "army", "kind": "dismounted", "count": 1, "at": "camp", "tag": "colonel", "name": "Colonel von Rauch", "order": "hold"},
        {"team": "army", "kind": "musketeer", "count": 5, "at": "road_gate", "tag": "line_n_men", "order": "hold"},
        {"team": "army", "kind": "musketeer", "count": 5, "at": "meadow_gate", "tag": "line_s_men", "order": "hold"},
        {"team": "army", "kind": "musketeer", "count": 3, "at": "road_gate", "tag": "line_n_men", "order": "hold", "if": RUNG},
        {"team": "army", "kind": "musketeer", "count": 3, "at": "meadow_gate", "tag": "line_s_men", "order": "hold", "if": RUNG},
        {"team": "army", "kind": "cannon", "count": 1, "at": "inside_n", "tag": "guns", "order": "hold", "if": RUNG},
        {"team": "army", "kind": "cannon", "count": 1, "at": "inside_s", "tag": "guns", "order": "hold", "if": RUNG},
        {"team": "army", "kind": "dismounted", "count": 1, "at": [41, 21], "tag": "commissary", "name": "The Commissary", "order": "hold", "if": QUIET},
        # ---- Fürth's refugees (c01's `saved`): labourers on the earthworks
        {"team": "town", "kind": "labourer", "as": "citizen", "count": 4, "at": "line_n", "tag": "diggers", "order": "hold", "if": SOME, "fixed": True},
        {"team": "town", "kind": "labourer", "as": "citizen", "count": 8, "at": "line_n", "tag": "diggers", "order": "hold", "if": MANY, "fixed": True},
        {"team": "town", "kind": "labourer", "as": "citizen", "count": 2, "at": "refugees", "tag": "refugee", "order": "hold", "fixed": True},
        # ---- the machine at Nuremberg's gates (a garrison; the player's army when he leads it)
        {"team": "machine", "kind": "clock_soldier", "count": 4, "at": "north_gate", "tag": "gate_guard", "order": "hold", "if": NO_MACHINE},
        {"team": "machine", "kind": "clock_soldier", "count": 4, "at": "south_gate", "tag": "gate_guard", "order": "hold", "if": NO_MACHINE},
        {"team": "machine", "kind": "clock_soldier", "count": 6, "at": "south_gate", "tag": "m_start", "if": MACHINE},
        {"team": "machine", "kind": "springer", "count": 1, "at": "south_gate", "tag": "m_start", "if": MACHINE},
        {"team": "machine", "kind": "winder", "count": 3, "at": "south_gate", "tag": "m_start", "if": MACHINE},
        {"team": "machine", "kind": "clock_soldier", "count": 2, "at": "north_gate", "tag": "m_start", "if": MACHINE},
    ],
    "buildings": [
        # the machine's seeds by Nuremberg's gates (the city's own: nothing at Fürth can touch them)
        {"team": "machine", "kind": "clocktower", "at": "north_gate", "tag": "seed_n"},
        {"team": "machine", "kind": "clocktower", "at": "south_gate", "tag": "seed_s"},
        {"team": "machine", "kind": "regulator", "at": "link_n", "tag": "links"},
        {"team": "machine", "kind": "regulator", "at": "link_s", "tag": "links"},
        {"team": "machine", "kind": "movement_works", "at": [104, 54], "tag": "m_works", "if": MACHINE},
        # Fürth's refugee cottages (c01's `saved`)
        {"team": "town", "kind": "cottage", "at": [44, 34], "tag": "cottages", "if": {"any": [SOME, MANY]}},
        {"team": "town", "kind": "cottage", "at": [36, 34], "tag": "cottages", "if": {"any": [SOME, MANY]}},
        {"team": "town", "kind": "cottage", "at": [50, 6], "tag": "cottages", "if": MANY},
        {"team": "town", "kind": "cottage", "at": [33, 8], "tag": "cottages", "if": MANY},
        # the guild's Light Works stands already when nobody leads the guild
        {"team": "guild", "kind": "movement_works", "at": [46, 22], "tag": "g_works", "if": NO_GUILD},
    ]
    # the earthworks next to the gates are dug before the mission starts
    + [{"team": "army", "kind": "wall", "at": c, "tag": "earthworks"} for c in STAGE0]
    + [{"team": "army", "kind": "gate", "at": c, "tag": "earthworks"} for c in N_GATES + S_GATES],
    "objectives": [
        # ---- the guild: part 1
        {"id": "stopwork", "side": "guild", "primary": True, "kind": "reach", "area": "honest_ring", "tag": "hollweg", "secs": 25,
         "text": "Fit the stop-work: Meister Hollweg stays by the Honest One for 25 seconds."},
        {"id": "works", "side": "guild", "primary": True, "kind": "manual",
         "text": "Build a Light Works by the Honest One."},
        {"id": "hollweg", "side": "guild", "primary": True, "kind": "protect", "tag": "hollweg", "text": "Meister Hollweg must live."},
        {"id": "honest", "side": "guild", "primary": True, "kind": "protect", "tag": "honest", "text": "The Honest One must stand."},
        {"id": "jakob", "side": "guild", "primary": False, "kind": "protect", "tag": "jakob", "hidden": True, "text": "Jakob must live."},
        # ---- the guild: part 2
        {"id": "hold", "side": "guild", "primary": True, "kind": "manual", "hidden": True,
         "text": "Hold the earthworks: {sorties} of 3 sorties beaten back."},
        # ---- the guild: part 3
        {"id": "mill", "side": "guild", "primary": True, "kind": "destroy", "hidden": True, "tag": "seed_mill",
         "text": "Burn the machine's seed at the Rednitz mill."},
        # ---- the machine (solo pick or versus)
        {"id": "m_line", "side": "machine", "primary": True, "kind": "countdown", "clock": "line",
         "text": "Fürth's line is finished in {clock:line}."},
        {"id": "m_break", "side": "machine", "primary": True, "kind": "manual",
         "text": "Burn the Honest One or kill Meister Hollweg before the line is finished."},
        {"id": "m_mill", "side": "machine", "primary": False, "kind": "manual", "hidden": True,
         "text": "Keep the seed at the Rednitz mill: your ground half way to Fürth."},
    ],
    "triggers": [
        # ================================================================ THE START (both sides)
        {"id": "seeds", "when": {"time": 0.5}, "do": [{"spare": {"tag": "seed_n", "on": True}}, {"spare": {"tag": "seed_s", "on": True}}]},
        {"id": "rung_purse", "when": {"all": [{"time": 0.5}, RUNG, GUILD]}, "do": [{"give": {"team": "guild", "gold": 200}}]},
        {"id": "jakob_obj", "when": {"all": [{"time": 0.5}, JAKOB, GUILD]}, "do": [{"objective": {"id": "jakob", "set": "active"}}]},
        # quiet bells: a Crown commissary watches the guild; no Light Works until the stop-work is fitted
        {"id": "watched", "when": {"all": [{"time": 0.5}, QUIET]}, "do": [{"deny": {"team": "guild", "kind": "movement_works",
            "why": "The commissary forbids it until the stop-work is fitted."}}]},
        {"id": "intro", "when": {"all": [{"time": 1}, GUILD]}, "do": [{"say": ["h_1", "col_1", "tip_1"]}, {"ping": {"area": "honest_ring"}}]},
        {"id": "intro_quiet", "when": {"all": [{"fired": "intro"}, QUIET]}, "delay": 14, "do": [{"say": ["com_1", "h_com"]}]},
        {"id": "intro_rung", "when": {"all": [{"fired": "intro"}, RUNG]}, "delay": 14, "do": [{"say": ["col_rung"]}]},
        {"id": "intro_jakob", "when": {"all": [{"fired": "intro"}, JAKOB]}, "delay": 24, "do": [{"say": ["j_1"]}]},
        {"id": "intro_m", "when": {"all": [{"time": 1}, MACHINE]}, "do": [
            {"say": ["m_intro", "m_tip"]}, {"clock": {"name": "line", "secs": 1080}},
            {"give": {"team": "machine", "gold": 500, "tension": 200}}, {"ping": {"area": "honest_ring"}}]},
        # ---- the army digs the earthworks (both sides: the machine player races it too)
        {"id": "dig_1", "when": {"time": 50}, "do": palisades(STAGE1)},
        {"id": "dig_2", "when": {"time": 110}, "do": palisades(STAGE2)},
        {"id": "dug", "when": {"all": [{"fired": "dig_2"}, GUILD]}, "delay": 2, "do": [{"say": ["col_dug"]}]},
        # ================================================================ PART 1 (the guild): THE HONEST ONE
        {"id": "works_up", "when": {"count": {"team": "guild", "kind": "movement_works", "buildings": True, "built": True, "at_least": 1}},
         "do": [{"objective": {"id": "works", "set": "done"}}]},
        {"id": "stopwork_done", "when": {"done": "stopwork"}, "do": [
            {"say": ["h_stop", "j_stop"]}, {"sound": {"name": "campaign/bell_toll", "area": "honest_ring"}}, {"flag": {"stopwork": "fitted"}},
            {"unlock": {"team": "guild", "kind": "movement_works"}}]},
        {"id": "stopwork_com", "when": {"all": [{"fired": "stopwork_done"}, QUIET]}, "delay": 6, "do": [{"say": ["com_2"]}]},
        # Part 2 comes when the stop-work is fitted and the Light Works stands (or at 7:00, whatever happened)
        {"id": "part2", "when": {"all": [GUILD, {"any": [{"all": [{"done": "stopwork"}, {"done": "works"}]}, {"time": 420}]}]}, "delay": 15, "do": [
            {"objective": {"id": "stopwork", "set": "hidden"}}, {"objective": {"id": "works", "set": "hidden"}},
            {"objective": {"id": "hold", "set": "active"}},
            {"say": ["col_2", "h_2", "tip_wind"]}, {"ping": {"area": "road_gate"}}, {"ping": {"area": "meadow_gate"}},
            {"clock": {"name": "sortie", "secs": 60}}]},
        # the scripted guild (the machine's player): the stop-work fitted by itself, its own reinforcements
        {"id": "g_stop", "when": {"all": [{"time": 60}, NO_GUILD]}, "do": [{"flag": {"stopwork": "fitted"}}]},
        {"id": "g_grow", "when": {"all": [{"time": 90}, NO_GUILD, {"not": {"dead": "honest"}},
            # (campaign-fixes-1121: NORMAL and HARD, with their bigger defence, grow up to 46)
            {"any": [{"all": [{"difficulty": "easy"}, {"count": {"team": "guild", "below": 30}}]},
                     {"all": [{"not": {"difficulty": "easy"}}, {"count": {"team": "guild", "below": 46}}]}]}]}, "every": 120, "do": [
            {"spawn": {"team": "guild", "kind": "clock_soldier", "count": 2, "at": "honest_ring", "tag": "g_more"}},
            {"order": {"tag": "g_more", "do": "attack", "to": "inside_n"}}]},
        # ...and it answers what comes through: its soldiers and the Franconians go for the machine's within reach
        {"id": "g_answer", "when": {"all": [{"time": 20}, NO_GUILD, {"count": {"team": "machine", "area": "behind_line", "at_least": 1}}]}, "every": 5, "do": [
            {"order": {"team": "guild", "do": "hunt", "prey_team": "machine", "within": 9}},
            {"order": {"team": "army", "do": "hunt", "prey_team": "machine", "within": 7}},
            ]},
        # (the scripted guild keeps its master in the barn behind the tower, Jakob with him)
        {"id": "g_hollweg", "when": {"all": [{"time": 1}, NO_GUILD]}, "do": [{"order": {"tag": "hollweg", "do": "move", "to": "barn"}},
                                                                            {"order": {"tag": "jakob", "do": "move", "to": "barn"}}]},
        # ================================================================ PART 2 (the guild): THE SORTIE
        {"id": "signal", "when": {"all": [{"clock_left": {"name": "sortie", "below": 20}}, MANY]}, "do": [
            {"say": ["n_signal", "h_signal"]}, {"reveal": {"area": "south_gate", "side": "guild", "secs": 40}},
            {"reveal": {"area": "north_gate", "side": "guild", "secs": 40}}, {"ping": {"area": "south_gate"}}]},
        {"id": "tick_1", "when": {"all": [{"clock_left": {"name": "sortie", "below": 12}}, JAKOB]}, "do": [{"say": ["j_tick_s"]}, {"sound": {"name": "campaign/off_beat"}}]},
        {"id": "wave_1", "when": {"clock_out": "sortie"}, "do": wave(1, "south_gate", "meadow_gate", W1_S, None) + [
            {"say": ["col_wave"]}, {"clock": {"name": "sortie2", "secs": GAP}}]},
        {"id": "tick_2", "when": {"all": [{"clock_left": {"name": "sortie2", "below": 12}}, JAKOB]}, "do": [
            {"say": ["j_tick_n"]}, {"sound": {"name": "campaign/off_beat"}}]},
        {"id": "tick_2c", "when": {"all": [{"fired": "tick_2"}, CUT]}, "delay": 5, "do": [{"say": ["j_tick_cut"]}]},
        {"id": "wave_2", "when": {"all": [{"clock_out": "sortie2"}, UNCUT]}, "do": wave(2, "north_gate", "road_gate", W2, None) + [
            {"say": ["col_wave2"]}, {"clock": {"name": "sortie3", "secs": GAP}}]},
        {"id": "wave_2c", "when": {"all": [{"clock_out": "sortie2"}, CUT]}, "do": wave(2, "south_gate", "meadow_gate", W2, None) + [
            {"say": ["col_wave2c"]}, {"clock": {"name": "sortie3", "secs": GAP}}]},
        {"id": "tick_3", "when": {"all": [{"clock_left": {"name": "sortie3", "below": 12}}, JAKOB]}, "do": [{"say": ["j_tick_3"]}, {"sound": {"name": "campaign/off_beat"}}]},
        {"id": "wave_3", "when": {"all": [{"clock_out": "sortie3"}, UNCUT]}, "do":
            wave(3, "south_gate", "meadow_gate", W3_S, None)
            + [{"spawn": {"team": "machine", "kind": "clock_soldier", "count": W3_N, "at": "north_gate", "tag": "sortie3n"}},
               {"spawn": {"team": "machine", "kind": "springer", "count": 1, "at": "north_gate", "tag": "sortie3n"}},
               {"order": {"tag": "sortie3n", "do": "attack", "to": "road_gate"}},
               {"say": ["col_wave3"]}]},
        {"id": "wave_3c", "when": {"all": [{"clock_out": "sortie3"}, CUT]}, "do": wave(3, "south_gate", "meadow_gate", W3, None) + [{"say": ["col_wave3"]}]},
        # the waves that reach the line go on at the Honest One (their seeds keep them coming)
        {"id": "push", "when": {"all": [{"fired": "wave_1"}, NO_MACHINE, {"not": {"fired": "the_end"}}]}, "every": 20, "do": [
            {"order": {"tag": t, "do": "attack", "to": "honest_ring", "idle": True}}
            for t in ["sortie1", "sortie2", "sortie3", "sortie3n", "mach_mill_grow", "mach_gate_grow", "tide"]]},
        # stopped at the palisade they break it: those right by it go for the nearest stake (every 12 s)
        {"id": "breach", "when": {"all": [{"fired": "wave_1"}, NO_MACHINE, {"not": {"fired": "the_end"}}]}, "every": 12, "do": [
            {"order": {"team": "machine", "do": "hunt", "prey": "earthworks", "within": 3}}]},
        # through the line they go for the tower that made them, and for the man who made it
        {"id": "for_honest", "when": {"all": [{"fired": "wave_1"}, NO_MACHINE, {"not": {"fired": "the_end"}}]}, "every": 8, "do": [
            {"order": {"team": "machine", "do": "hunt", "prey": "honest", "within": 11}},
            {"order": {"team": "machine", "do": "hunt", "prey": "hollweg", "within": 11}}]},
        {"id": "beat_1", "when": {"all": [{"fired": "wave_1"}, {"dead": "sortie1"}]}, "do": [{"counter": {"name": "sorties", "add": 1}}, {"say": ["col_beat"]}]},
        {"id": "beat_2", "when": {"all": [{"any": [{"fired": "wave_2"}, {"fired": "wave_2c"}]}, {"dead": "sortie2"}]}, "do": [{"counter": {"name": "sorties", "add": 1}}, {"say": ["h_beat"]}]},
        {"id": "beat_3", "when": {"all": [{"any": [{"fired": "wave_3"}, {"fired": "wave_3c"}]}, {"dead": "sortie3"},
                                          {"any": [{"fired": "wave_3c"}, {"dead": "sortie3n"}]}]}, "do": [{"counter": {"name": "sorties", "add": 1}}]},
        # ================================================================ PART 3 (the guild): THE MILL
        {"id": "part3", "when": {"all": [GUILD, {"any": [{"fired": "beat_3"},
                                                          {"all": [{"any": [{"fired": "wave_3"}, {"fired": "wave_3c"}]}, {"clock_out": "sortie3_late"}]}]}]},
         "delay": 6, "do": [
            {"objective": {"id": "hold", "set": "done"}},
            {"light": {"to": "winter_dusk", "secs": 40}},
            {"build": {"team": "machine", "kind": "clocktower", "at": "mill", "tag": "seed_mill"}},
            {"hurt": {"tag": "seed_mill", "amount": 900}},      # (a seed half grown: about half a Clocktower's health)
            {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 6, "at": "mill", "tag": "mill_guard", "order": "hold"}},
            {"spawn": {"team": "machine", "kind": "springer", "count": 2, "at": "mill", "tag": "mill_guard", "order": "hold"}},
            {"say": ["j_mill", "h_mill", "col_mill"]}, {"reveal": {"area": "mill", "side": "guild", "secs": 30}},
            {"ping": {"area": "mill"}}, {"objective": {"id": "mill", "set": "active"}},
            {"spawn": {"team": "army", "kind": "musketeer", "count": 4, "at": "camp", "tag": "reserve", "order": {"do": "move", "to": "inside_s"}}}]},
        {"id": "late_clock", "when": {"any": [{"fired": "wave_3"}, {"fired": "wave_3c"}]}, "do": [{"clock": {"name": "sortie3_late", "secs": 200}}]},
        {"id": "pattern", "when": {"all": [{"fired": "part3"}, PATTERN]}, "delay": 8, "do": [
            {"unlock": {"team": "guild", "kind": ["heavy_works", "pendulum"]}}, {"say": ["h_pattern", "tip_heavy"]}]},
        {"id": "people", "when": {"all": [{"fired": "part3"}, PEOPLE]}, "delay": 8, "do": [
            {"spawn": {"team": "guild", "kind": "winder", "count": 4, "at": "honest_ring", "tag": "people_hands"}}, {"say": ["h_people"]}]},
        seed_grow("mill_grow", "seed_mill", "mill", "meadow_gate", 40, "part3", [("clock_soldier", 2)], [NO_MACHINE, {"not": {"fired": "the_end"}}]),
        seed_grow("gate_grow", "seed_s", "south_gate", "meadow_gate", 60, "part3", [("clock_soldier", 2)],
                  [NO_MACHINE, {"not": {"fired": "the_end"}}, {"not": {"dead": "seed_mill"}}]),
        # the mill left standing grows: 6:00 into Part 3 (and every 2:30 after) it sends a tide with a Pendulum
        {"id": "tide_clock", "when": {"fired": "part3"}, "do": [{"clock": {"name": "tide", "secs": 360}}]},
        {"id": "tide", "when": {"all": [{"clock_out": "tide"}, {"not": {"dead": "seed_mill"}}, NO_MACHINE, {"not": {"fired": "the_end"}}]},
         "every": 150, "do": [
            {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 10, "at": "mill", "tag": "tide"}},
            {"spawn": {"team": "machine", "kind": "springer", "count": 2, "at": "mill", "tag": "tide"}},
            {"spawn": {"team": "machine", "kind": "pendulum", "count": 1, "at": "mill", "tag": "tide"}},
            {"order": {"tag": "tide", "do": "attack", "to": "meadow_gate"}}, {"say": ["col_tide"]}, {"ping": {"area": "mill"}}]},
        {"id": "mill_burnt", "when": {"all": [{"fired": "part3"}, {"dead": "seed_mill"}, NO_MACHINE]}, "do": [
            {"say": ["col_burnt", "h_safe"]}, {"light": {"to": "winter_night", "secs": 20}},
            {"counter": {"name": "army", "count": {"team": "army"}}},
            {"tally": {"flag": "furth", "counter": "army", "bands": [[0, "thin"], [10, "strong"]]}},
            {"flag": {"jakob": "alive"}}]},
        {"id": "jakob_gone", "when": {"all": [{"fired": "mill_burnt"}, {"any": [{"dead": "jakob"}, past("jakob", "lost")]}]}, "do": [{"flag": {"jakob": "lost"}}]},
        {"id": "the_end", "when": {"fired": "mill_burnt"}, "delay": 10, "do": [{"win": "guild"}]},
        {"id": "hollweg_hurt", "when": {"all": [{"hurt": "hollweg"}, JAKOB, GUILD]}, "every": 60, "times": 2, "do": [{"say": ["j_hurt"]}, {"ping": {"area": "barn"}}]},
        {"id": "hollweg_hurt_c", "when": {"all": [{"hurt": "hollweg"}, {"not": JAKOB}, GUILD]}, "every": 60, "times": 2, "do": [{"say": ["col_hurt"]}, {"ping": {"area": "barn"}}]},
        {"id": "jakob_lost", "when": {"all": [{"time": 2}, {"dead": "jakob"}]}, "do": [{"say": ["h_jakob"]}]},
        # ================================================================ THE MACHINE (a person leads it)
        # the seeds' timetable: cogs and Tension while a seed stands, a construct or two out of each gate
        {"id": "m_income", "when": {"all": [{"time": 30}, MACHINE]}, "every": 30, "do": [{"give": {"team": "machine", "gold": 200, "tension": 20}}]},
        {"id": "m_free", "when": {"all": [{"time": 120}, MACHINE, {"count": {"team": "machine", "below": 60}}]}, "every": 60, "do": [
            {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 1, "at": "south_gate", "tag": "m_free"}},
            {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 1, "at": "north_gate", "tag": "m_free"}}]},
        # at 6:00 the machine seeds the Rednitz mill by itself: a ground half way to Fürth
        {"id": "m_mill", "when": {"all": [{"time": 360}, MACHINE, NO_GUILD]}, "do": [
            {"build": {"team": "machine", "kind": "clocktower", "at": "mill", "tag": "seed_mill"}},
            {"say": ["m_mill"]}, {"ping": {"area": "mill"}}, {"objective": {"id": "m_mill", "set": "active"}}]},
        {"id": "m_mill_income", "when": {"all": [{"fired": "m_mill"}, {"not": {"dead": "seed_mill"}}]}, "every": 30, "do": [{"give": {"team": "machine", "gold": 70}}]},
        # ...and while it stands it grows a Pendulum every 1:30 (three at most): the machine's tool against the tower
        {"id": "m_mill_pend", "when": {"all": [{"fired": "m_mill"}, {"not": {"dead": "seed_mill"}}]}, "delay": 60, "every": 90, "times": 3, "do": [
            {"spawn": {"team": "machine", "kind": "pendulum", "count": 1, "at": "mill", "tag": "m_pend"}}, {"say": ["m_pend"]}]},
        {"id": "m_mill_lost", "when": {"all": [{"fired": "m_mill"}, {"dead": "seed_mill"}]}, "do": [{"objective": {"id": "m_mill", "set": "failed"}}, {"say": ["m_mill_lost"]}]},
        # the scripted guild keeps building: Clock Soldiers out of the barn every 1:30 (NORMAL two, HARD three; EASY none)
        {"id": "g_build", "when": {"all": [{"time": 90}, NO_GUILD, {"difficulty": ["normal", "hard"]}, {"not": {"dead": "honest"}},
                                           {"count": {"team": "guild", "below": 46}}]}, "every": 90, "do": [
            {"spawn": {"team": "guild", "kind": "clock_soldier", "count": 2, "at": "barn", "tag": "g_def", "order": "hold", "fixed": True}}]},
        {"id": "g_build_h", "when": {"all": [{"fired": "g_build"}, {"difficulty": "hard"}, {"not": {"dead": "honest"}}]}, "every": 90, "do": [
            {"spawn": {"team": "guild", "kind": "springer", "count": 1, "at": "barn", "tag": "g_def", "order": "hold", "fixed": True}}]},
        # the scripted guild answers the mill: a strike from the meadow gate at 10:00
        {"id": "g_strike", "when": {"all": [{"time": 600}, NO_GUILD, {"not": {"dead": "seed_mill"}}]}, "do": [
            {"spawn": {"team": "guild", "kind": "clock_soldier", "count": 6, "at": "inside_s", "tag": "g_strike"}},
            {"spawn": {"team": "guild", "kind": "springer", "count": 2, "at": "inside_s", "tag": "g_strike"}},
            {"order": {"tag": "g_strike", "do": "attack", "to": "mill"}}]},
        {"id": "m_warn", "when": {"all": [MACHINE, {"clock_left": {"name": "line", "below": 120}}]}, "do": [{"say": ["m_warn"]}, {"sound": {"name": "campaign/off_beat"}}]},
        # (no delay: the guild's own protect objective fails in the same tick and ends the mission for the machine)
        {"id": "m_broke", "when": {"all": [MACHINE, {"any": [{"dead": "honest"}, {"dead": "hollweg"}]}]}, "do": [
            {"objective": {"id": "m_break", "set": "done"}}, {"flag": {"furth": "fallen"}}, {"win": "machine"}]},
        {"id": "m_lost", "when": {"all": [MACHINE, {"clock_out": "line"}, {"not": {"fired": "m_broke"}}]}, "do": [
            {"objective": {"id": "m_break", "set": "failed"}}]},
    ],
    "speakers": {
        "king": {"name": "The King", "side": "guild"},
        "hollweg": {"name": "Meister Hollweg", "side": "guild", "portrait": "res://campaign/hub/nuremberg_hollweg_face.png"},
        "jakob": {"name": "Jakob", "side": "guild"},
        "colonel": {"name": "Colonel von Rauch", "side": "guild"},
        "commissary": {"name": "The Commissary", "side": "guild"},
        "narrator": {"name": "Fürth", "side": "guild"},
        "machine": {"name": "The Machine", "side": "machine"},
    },
    "lines": {
        # the opening: the King in Rome; Hollweg goes on
        "k_open1": {"who": "king", "text": "The Machine kept Nuremberg through the winter. In March it came out of the gates."},
        "k_open2": {"who": "king", "text": "The guild had gone three miles, to Fürth. The Crown gave it a field and a barn."},
        "h_open1": {"who": "hollweg", "text": "We raised a new tower in the barn's yard. The men called it the Honest One."},
        "h_open2": {"who": "hollweg", "text": "Every wheel in it was cut by a hand I knew, and every machine it made would carry a stop-work. I gave my word on that."},
        "k_open_m": {"who": "king", "text": "The Machine has no voice and kept no account. We know that spring by what it did."},
        "k_open_m2": {"who": "king", "text": "In March it came out of Nuremberg's gates, west along the river, toward the guild that made it."},
        # part 1
        "h_1": {"who": "hollweg", "to": "guild", "text": "Before anything else, the stop-work. Bring me to the tower."},
        "col_1": {"who": "colonel", "to": "guild", "text": "My men are digging, Meister. Your machines stay on your side of the ditch."},
        "tip_1": {"who": "hollweg", "to": "guild", "text": "Keep me by the Honest One until the stop-work is fitted. Then a Light Works for the soldiers."},
        "com_1": {"who": "commissary", "to": "guild", "text": "The Crown has read Father Ferrer's letter, Meister. Nothing is built here until I see that stop-work."},
        "h_com": {"who": "hollweg", "to": "guild", "text": "Then watch closely. You will see it fitted."},
        "col_rung": {"who": "colonel", "to": "guild", "text": "They say you rang the bells, Meister. Half my regiment owes you its family. Build what you need."},
        "j_1": {"who": "jakob", "to": "guild", "text": "I kept the log all winter, Meister. It is quieter in Nuremberg than it should be."},
        "col_dug": {"who": "colonel", "to": "guild", "text": "The line is dug from the woods to the Rednitz. Two gates. Nothing else gets through."},
        "h_stop": {"who": "hollweg", "to": "guild", "text": "There. A stop-work on the Honest One, and on everything it makes. It will stop when we say."},
        "j_stop": {"who": "jakob", "to": "guild", "text": "It keeps the beat, Meister. On the beat, every tooth."},
        "com_2": {"who": "commissary", "to": "guild", "text": "Seen and noted. You may build your works."},
        # part 2
        "col_2": {"who": "colonel", "to": "guild", "text": "Riders from the river. The gates of Nuremberg are open."},
        "h_2": {"who": "hollweg", "to": "guild", "text": "It is coming to us. Man the earthworks."},
        "tip_wind": {"who": "hollweg", "to": "guild", "text": "Off the Honest One's ground our soldiers run down, as theirs do. Send Winders with them to the earthworks."},
        "n_signal": {"who": "narrator", "to": "guild", "text": "A lamp in a window in Nuremberg, three times: the loyal quarter's signal."},
        "h_signal": {"who": "hollweg", "to": "guild", "text": "Our people inside. They are telling us where it gathers."},
        "j_tick_s": {"who": "jakob", "to": "guild", "text": "Listen. Off the beat, south of the river. They are coming by the meadows."},
        "j_tick_n": {"who": "jakob", "to": "guild", "text": "Again. North this time, on the road."},
        "j_tick_cut": {"who": "jakob", "to": "guild", "text": "No, the road is silent. We cut its links last winter. The meadows again."},
        "j_tick_3": {"who": "jakob", "to": "guild", "text": "More of them. Many more."},
        "col_wave": {"who": "colonel", "to": "guild", "text": "On the meadows! Hold the gate!"},
        "col_wave2": {"who": "colonel", "to": "guild", "text": "The road! They are on the road!"},
        "col_wave2c": {"who": "colonel", "to": "guild", "text": "The meadows again. They know only the one way."},
        "col_wave3": {"who": "colonel", "to": "guild", "text": "Everything it has. Hold, Franconians!"},
        "col_beat": {"who": "colonel", "to": "guild", "text": "Beaten back. It will try again."},
        "h_beat": {"who": "hollweg", "to": "guild", "text": "They run down off their ground. The line is far enough."},
        # part 3
        "j_mill": {"who": "jakob", "to": "guild", "text": "The Rednitz mill, Meister. There is a tower turning there."},
        "h_mill": {"who": "hollweg", "to": "guild", "text": "A seed, half way to us. Burn it before it grows."},
        "col_mill": {"who": "colonel", "to": "guild", "text": "My reserve goes with you. Burn it and the line holds."},
        "h_pattern": {"who": "hollweg", "to": "guild", "text": "I have my drawings. Open the Heavy Works: we will build a Pendulum."},
        "tip_heavy": {"who": "jakob", "to": "guild", "text": "The Heavy Works must stand by a Mainspring, Meister."},
        "h_people": {"who": "hollweg", "to": "guild", "text": "No drawings, so no Pendulum. But the families I brought out lend us their hands: four more Winders."},
        "col_tide": {"who": "colonel", "to": "guild", "text": "The mill is sending a second wave. Burn it, Meister, before there is a third."},
        "col_burnt": {"who": "colonel", "to": "guild", "text": "The mill is burning. The line holds."},
        "h_safe": {"who": "hollweg", "to": "guild", "text": "Safe this time."},
        "j_hurt": {"who": "jakob", "to": "guild", "text": "Meister, you are hurt. Stay behind the earthworks."},
        "col_hurt": {"who": "colonel", "to": "guild", "text": "Your master is hurt, guild! Get soldiers round him."},
        "h_jakob": {"who": "hollweg", "to": "guild", "text": "Jakob. Not twice."},
        # the machine (no voice: objectives and its tick)
        "m_intro": {"who": "machine", "to": "machine", "text": "Tick. Tock. West along the river. The tower at Fürth ticks on the beat. Stop it."},
        "m_tip": {"who": "machine", "to": "machine", "text": "Your seeds by the gates send constructs and cogs while they stand. Off your ground your constructs run down."},
        "m_mill": {"who": "machine", "to": "machine", "text": "A seed at the Rednitz mill. New ground, half way to Fürth."},
        "m_pend": {"who": "machine", "to": "machine", "text": "The mill seed has grown a Pendulum. Its blades bite through walls."},
        "m_mill_lost": {"who": "machine", "to": "machine", "text": "The mill seed is burnt."},
        "m_warn": {"who": "machine", "to": "machine", "text": "Two minutes. The line is almost closed."},
        # the ending: the guild's
        "h_end1": {"who": "hollweg", "text": "The machine went back behind its walls. The line held all that spring."},
        "h_end_strong": {"who": "hollweg", "text": "The colonel kept most of his men. He let the guild build inside his line after that."},
        "h_end_thin": {"who": "hollweg", "text": "The colonel buried many of his men by the Rednitz. He did not forgive us that."},
        "h_end_jakob": {"who": "hollweg", "text": "Jakob kept his log of the ticking. He wrote down every beat."},
        "h_end2": {"who": "hollweg", "text": "Every machine we built at Fürth had its stop-work. I would swear to it still, before God."},
        "k_end1": {"who": "king", "text": "He believes it. I have never taken him for a liar."},
        "k_end2": {"who": "king", "text": "A stop-work is a wheel like any other. A wheel can be taken out."},
        # the ending: the machine's (the King tells what did not happen)
        "k_end_m1": {"who": "king", "text": "That is not how it went. The line held at Fürth."},
        "k_end_m2": {"who": "king", "text": "If the line had broken, the Machine would have had the Regnitz by midsummer."},
    },
    "stills": {
        "barn": {"image": STILL % "a02_01", "caption": "Fürth, March 2768. The guild in exile, in a barn."},
        "honest": {"image": STILL % "a02_02", "caption": "The Honest One, and its stop-work."},
        "sortie": {"image": STILL % "a02_03", "caption": "The sortie across the water meadows."},
        "mill": {"image": STILL % "a02_04", "caption": "The Rednitz mill."},
        "held": {"image": STILL % "a02_05", "caption": "The line holds."},
        "rome": {"image": STILL % "c01_01", "caption": "Rome, the present. The King listens; the clockmaker tells it."},
    },
    "opening": {
        "guild": [
            {"still": "rome", "lines": ["k_open1", "k_open2"]},
            {"still": "barn", "lines": ["h_open1"]},
            {"still": "honest", "lines": ["h_open2"]},
        ],
        "machine": [
            {"still": "rome", "lines": ["k_open_m"]},
            {"still": "sortie", "lines": ["k_open_m2"]},
        ],
    },
    "ending": {
        "guild": [
            {"still": "held", "lines": ["h_end1",
                                       {"id": "h_end_strong", "if": {"flag": {"furth": "strong"}}},
                                       {"id": "h_end_thin", "if": {"flag": {"furth": "thin"}}},
                                       {"id": "h_end_jakob", "if": {"flag": {"jakob": "alive"}}}]},
            {"still": "honest", "lines": ["h_end2"]},
            {"still": "rome", "lines": ["k_end1", "k_end2"]},
        ],
        "machine": [
            {"still": "sortie", "lines": ["k_end_m1"]},
            {"still": "rome", "lines": ["k_end_m2"]},
        ],
    },
    "briefing": {
        "guild": {"still": "barn", "text": [
            "Fürth, March 2768. The guild in exile has raised its new Clocktower, the Honest One, beside the Crown's Franconian army.",
            "Fit the stop-work, build your works, hold the earthworks when the machine comes out of Nuremberg.",
            "Meister Hollweg must live. The Honest One must stand."]},
        "machine": {"still": "sortie", "text": [
            "Fürth, March 2768. You are the Machine. Nuremberg is yours; the guild that made you is three miles west.",
            "Burn the Honest One or kill Meister Hollweg before the Crown finishes its line."]},
    },
    "debrief": {
        # (the words say what happened: the guild also wins when the Machine's player runs out of time with the mill seed
        # standing, and the Machine wins by Hollweg dead with the tower up; both screens said otherwise;
        # playtest-campaign-clock)
        "guild": {"still": "held", "title": "The line holds",
                  "text": "The machine went back behind Nuremberg's walls. Fürth stands.",
                  "text_if": [
                      {"if": {"dead": "seed_mill"}, "text": "The Rednitz mill burned."},
                      {"if": {"not": {"dead": "seed_mill"}}, "text": "Fürth's line was finished before the machine broke through."},
                      {"if": {"flag": {"furth": "strong"}}, "text": "The Franconian army kept its strength: {army} men on the line."},
                      {"if": {"flag": {"furth": "thin"}}, "text": "The Franconian army is thin: {army} men on the line."},
                      {"if": {"flag": {"jakob": "lost"}}, "text": "Jakob is not with the guild."}]},
        "machine": {"still": "sortie", "title": "Fürth burns",
                    "text": "The Machine has the Pegnitz from Nuremberg to the Regnitz.",
                    "text_if": [{"if": {"dead": "honest"}, "text": "The guild's tower is down."},
                                {"if": {"dead": "hollweg"}, "text": "Meister Hollweg is dead."}]},
    },
    "next": {"guild": "a04_visit", "machine": ""},
}

for o in M["objectives"]:
    if "kind_of" in o:
        o["kind"], o["unit_kind"] = "reach", o.pop("kind_of")


# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the line's own team may build / train / research only its step's
# pieces; the NEW card says what this mission brings (tools/campaign/roster_ladder.py)
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import roster_ladder
roster_ladder.apply(M, "a02_furth")

out = os.path.join(ROOT, "campaign", "missions", "a02_furth.json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines",
      len(STAGE0), "+", len(STAGE1), "+", len(STAGE2), "palisades,", len(N_GATES + S_GATES), "gates")
