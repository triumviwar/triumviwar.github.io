#!/usr/bin/env python3
"""Writes campaign/missions/a03_plateau.json: Act 1's "The Lost Plateau" (the Naturalist line, September 2767; the plan:
docs/campaign_act1_plan.md "a03_plateau" and its OWNER ANSWERS of 2026-11-17 22:04; what was built:
docs/campaign_a03_build.md).
  python3 tools/campaign/make_a03_mission.py
EVERY LINE IS A PLACEHOLDER for the owner to rewrite. After changing a text: add its Portuguese and Spanish to
tools/i18n/campaign/a03_plateau.txt and run python3 tools/i18n_build.py (tools/test_campaign_a03.gd checks every text has
both).

Three months after the station burned, Valadares (the Crown's mapmaker) climbs the cloud mountain the Sire led Linnea
up. Played by default as VALADARES' CROWN PARTY (YELLOW): no base, no income, the mist; Valadares tells it from his
report to the Crown, the King frames it (he holds that report).
  PART 1, THE CLIMB: from Benedito's landing through the forest at the foot and up the cliff (the waterfall stair or
    the split in the rock) in the mist; the guides from Nazaré light the paths; Raptor patrols on the top.
  PART 2, THE SURVEY: Valadares stays 10 s at each of the four SURVEY MARKS (the cairn, the river's source, the nest's
    rim, the lookout; any order). The nest in its hollow is ASLEEP: come within 6 tiles of a sleeper (or hurt one)
    and it wakes (Part 3 at once, the survey cut short).
  THE CHOICE, THE MAP (the survey done, on the top): draw it for the Crown (canon) or withhold it (a sealed letter to
    the Church): the flag `map` drawn / withheld.
  PART 3, THE NEST WAKES: the Tyrant Sire comes home up the stair behind them, the nest wakes and hunts; down to the
    landing before Benedito's canoe leaves (the raced countdown), everyone counted (an exit): the flag `party`
    (few / some / all of those who went up). Valadares must live.
  A passive party loses at the rains (the survey not done when Benedito will wait no longer).
THE MIRROR (solo side pick, or versus): THE NEST (GREEN), a Brood standard start in the hollow, its hunters ASLEEP
  (and every new one while it sleeps) until the strangers come near or Part 3; the Mother, the grubs and the Rootmaws
  work all along. From Part 3 the Sire is home: kill Valadares, or bring the party under half, before they reach the
  river. The party is then scripted (a ROUTE up, round the marks, and down the split). No creature speaks: objectives,
  sounds, the King's frame.
THE PROLOGUE'S FLAGS (b01_specimen as rebuilt in 0.38.49; a missing flag reads as b01's canon): teles (told: six of
  Teles' Musketeers; always quiet since the flip), saved (few / some / many: 0 / 1 / 2 guides from Nazaré, each lights
  a way up), eggs (taken: four more young Raptors in the nest), turtle (early: a second Mound Turtle and Valadares
  knows it), rival (standing: a red pack prowls the forest at the foot, a third side), pieter (a line). `clutch` is
  a05's, not read here.
"""
import json
import os

STILL = "res://campaign/stills/%s.jpg"
HERE = os.path.dirname(__file__)
ROOT = os.path.join(HERE, "..", "..")

PARTY = {"playing": "party"}
NEST = {"playing": "nest"}
NO_PARTY = {"not": {"playing": "party"}}      # the party is scripted (the solo player leads the nest)
NO_NEST = {"not": {"playing": "nest"}}        # the nest is scripted (the party's story)


def past(flag, value):
    return {"past": {"b01_specimen." + flag: value}}


def notpast(flag, value):
    return {"not": past(flag, value)}


TOLD = past("teles", "told")
GUIDE1 = notpast("saved", "few")               # (some or many, or not known: b01's canon "some")
GUIDE2 = past("saved", "many")
TAKEN = past("eggs", "taken")
EARLY = past("turtle", "early")
RIVAL = notpast("rival", "driven")             # (standing, or not known)
PIETER = past("pieter", "alive")

PEOPLE = ["musketeer", "labourer", "dismounted"]     # the party's people (not the powder wagon)
AWAKE_KINDS = ["brood_mother", "rootmaw", "mound_turtle", "dilophosaurus", "pterodactyl", "tyrannosaur", "grub",
               "brood_egg", "food_pile"]         # (the nest's workers and rooters stay awake while its hunters sleep)
MARKS = ["cairn", "source", "rim", "lookout"]
STAY = 40                                       # seconds Valadares stays at a mark
RAINS = 840                                     # the rains: Benedito waits 14:00 for the survey
CANOE = 270                                     # Part 3: the canoe leaves 4:30 after the nest wakes


def mark(m, line, extra=()):
    """A survey mark: Valadares stays STAY s in its area; a line, the count, its reveal (not after Part 3)."""
    return {"id": "mark_" + m, "when": {"all": [{"stay": {"tag": "valadares", "area": m, "secs": STAY}}]}, "do": [
        {"counter": {"name": "marks", "add": 1}}, {"say": [line]}, {"sound": {"name": "campaign/forest_answer", "area": m, "vol": -14}},
        {"ping": {"area": m}}] + list(extra)}


M = {
    "id": "a03_plateau",
    "title": "The Lost Plateau",
    "summary": "The cloud mountain north of the Rio Negro, September 2767. The Crown's mapmaker climbs the mountain the creatures came down from, to map it, and finds them asleep in their nest.",
    "map": "campaign:cloud_plateau",
    "voice": "a03",
    "light": "jungle_day",
    "floor": [0.7, 0.74, 0.68],
    "mist": {"sight": 0.5},
    "expansion_spots": False,
    "manual_end": True,
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {"clocks": 0.9, "spawns": 1.2}},
    "modes": ["solo", "versus"],
    "solo_sides": ["party", "nest"],
    "sides": [
        {"id": "party", "name": "The Crown's Party", "about": "Valadares, the Crown's mapmaker, with Benedito, the boundary commission's men and the guides from Nazaré."},
        {"id": "nest", "name": "The Nest", "about": "The creatures' home on the cloud mountain: the Mother in her hollow, her hunters asleep, the Sire away."},
        {"id": "rival", "name": "The Red Pack", "about": "The other pack of the Rio Negro, driven up the mountain after the station fell."},
    ],
    "teams": [
        {"id": "party", "side": "party", "faction": "crown", "colour": 3, "start": "none", "camera": "camp", "powder": 200,
         "control": {"solo": "p1", "versus": "p1", "foe": "script"}},
        {"id": "nest", "side": "nest", "faction": "brood", "colour": 2, "start": "standard", "hall": [61, 19], "hall_tag": "nest_mother",
         "camera": "hollow", "gold": 300,
         "control": {"solo": "script", "versus": "p2"}},
        {"id": "kin", "side": "nest", "faction": "brood", "colour": 2, "start": "none", "camera": "hollow",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "patrol", "side": "nest", "faction": "brood", "colour": 2, "start": "none", "camera": "hollow",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "rival", "side": "rival", "faction": "brood", "colour": 1, "start": "none", "camera": "camp",
         "control": {"solo": "script", "versus": "script"}},
    ],
    "areas": {
        # the foot
        "landing": [58, 103, 12, 5], "camp": [57, 88, 14, 9], "cache": [66, 93, 3, 3],
        "trail_w": [34, 78, 6, 5], "trail_e": [84, 83, 7, 6],
        "stair_foot": [22, 67, 9, 5], "stair_top": [22, 60, 8, 5], "split_foot": [94, 67, 9, 5], "split_top": [96, 58, 5, 6],
        "split_in": [94, 48, 8, 6], "falls": [14, 60, 18, 18], "path_w": [16, 54, 18, 24], "path_e": [88, 44, 18, 32],
        # the top
        "top": [12, 38, 104, 20], "cairn": [24, 46, 8, 7], "source": [24, 15, 7, 10], "rim": [56, 37, 15, 5],
        "lookout": [108, 27, 9, 9],
        "pw_a": [28, 36, 6, 5], "pw_b": [36, 54, 6, 5], "pe_a": [98, 18, 7, 6], "pe_b": [102, 42, 6, 6],
        # the nest's hollow
        "hollow": [41, 12, 46, 23], "nest_core": [54, 14, 22, 13], "kin": [70, 18, 5, 4], "hollow_ramps": [44, 33, 40, 4],
        # the forest (the red pack)
        "rf_a": [38, 76, 6, 5], "rf_b": [80, 80, 6, 5],
        # (where the Sire comes home from: the way nearest Valadares; the party crosses the top to the other)
        "west_half": [0, 0, 64, 112], "mid_top": [62, 55, 8, 5], "pn": [98, 7, 6, 4],
    },
    "counters": {"marks": {"start": 0, "of": 4}, "party0": {"start": 0}, "down": {"start": 0}, "left": {"start": 0}},
    "exits": [
        # Part 3: Benedito's canoe takes everyone who reaches the landing (Valadares stays to the end: he goes last)
        {"area": "landing", "team": "party", "except": ["valadares", "cache"], "counter": "down", "after": "part3"},
    ],
    "units": [
        # ---- the party at the foot, by Benedito's landing
        {"team": "party", "kind": "dismounted", "as": "valadares", "count": 1, "at": [62, 90], "tag": "valadares"},
        {"team": "party", "kind": "labourer", "as": "benedito", "count": 1, "at": [64, 91], "tag": "benedito"},
        {"team": "party", "kind": "musketeer", "count": 4, "at": "camp", "tag": "men"},
        {"team": "party", "kind": "labourer", "as": "guide", "count": 1, "at": "camp", "tag": "guides", "if": GUIDE1, "fixed": True},
        {"team": "party", "kind": "labourer", "as": "guide", "count": 1, "at": "camp", "tag": "guides", "if": GUIDE2, "fixed": True},
        {"team": "party", "kind": "musketeer", "count": 6, "at": "camp", "tag": "teles_men", "if": TOLD},
        {"team": "party", "kind": "powder_wagon", "count": 1, "at": "cache", "tag": "cache"},
        # ---- the nest (its Mother, a Rootmaw and grubs are the standard start in the hollow): its hunters, asleep
        {"team": "nest", "kind": "raptor", "count": 6, "at": "nest_core", "tag": "nest_guard"},
        {"team": "nest", "kind": "raptor", "count": 4, "at": "nest_core", "tag": "nest_guard", "name": "Young", "if": TAKEN},
        {"team": "nest", "kind": "spitter", "count": 2, "at": "nest_core", "tag": "nest_guard"},
        {"team": "nest", "kind": "mound_turtle", "count": 1, "at": [52, 26], "tag": "turtles"},
        {"team": "nest", "kind": "mound_turtle", "count": 1, "at": [78, 27], "tag": "turtles", "if": EARLY},
        {"team": "kin", "kind": "brood_mother", "as": "linnea_grown", "count": 1, "at": "kin", "tag": "linnea"},
        # ---- the nest's patrols on the top (scripted, the party's game only)
        {"team": "patrol", "kind": "raptor", "count": 3, "at": "pw_a", "tag": "patrol_w", "if": NO_NEST},
        {"team": "patrol", "kind": "raptor", "count": 3, "at": "pe_a", "tag": "patrol_e", "if": NO_NEST},
        # ---- the red pack in the forest at the foot (b01's rival still standing)
        {"team": "rival", "kind": "raptor", "count": 3, "at": "rf_a", "tag": "red_pack", "if": RIVAL},
    ],
    "buildings": [],
    "objectives": [
        # ---- the party
        {"id": "valadares", "side": "party", "primary": True, "kind": "protect", "tag": "valadares", "text": "Valadares must live."},
        {"id": "rains", "side": "party", "primary": True, "kind": "countdown", "clock": "rains",
         "text": "The rains come in {clock:rains}: Benedito will not wait longer."},
        {"id": "climb", "side": "party", "primary": True, "kind": "manual",
         "text": "THE CLIMB: take Valadares up the cliff (by the waterfall stair or the split in the rock)."},
        {"id": "survey", "side": "party", "primary": True, "kind": "manual", "hidden": True,
         "text": "THE SURVEY: Valadares stays %d seconds at each survey mark ({marks} of 4): the cairn, the river's source, the nest's rim, the lookout." % STAY},
        {"id": "softly", "side": "party", "primary": False, "kind": "manual", "hidden": True,
         "text": "Walk softly: do not go near the sleeping creatures."},
        {"id": "flee", "side": "party", "primary": True, "kind": "manual", "hidden": True,
         "text": "Down to Benedito's landing with Valadares and everyone you can bring ({down} down)."},
        {"id": "canoe", "side": "party", "primary": True, "kind": "countdown", "clock": "canoe", "hidden": True,
         "text": "Benedito's canoe leaves in {clock:canoe}."},
        # ---- the nest (solo side pick or versus)
        {"id": "n_mother", "side": "nest", "primary": True, "kind": "protect", "tag": "nest_mother", "hidden": True, "text": "The Mother must live."},
        {"id": "n_sleep", "side": "nest", "primary": True, "kind": "manual", "hidden": True,
         "text": "THE NEST SLEEPS: strangers are climbing the mountain. Your hunters sleep until they come close; the Mother, the grubs and the Rootmaws work on. Grow the nest."},
        {"id": "n_hunt", "side": "nest", "primary": True, "kind": "manual", "hidden": True,
         "text": "THE HUNT: the Sire is home. Kill the mapmaker, or bring the strangers under half, before they reach the river."},
    ],
    "triggers": [
        # ================================================================ THE START (both sides)
        {"id": "start", "when": {"time": 0}, "do": [
            {"spare": {"tag": "linnea", "on": True}}, {"cage": {"tag": "linnea", "on": True}},
            {"pin": {"tag": "cache", "on": True}}, {"name": {"tag": "cache", "name": "The supply cache"}},
            {"name": {"tag": "nest_mother", "name": "The Mother"}},
            {"counter": {"name": "party0", "count": {"team": "party", "kind": PEOPLE}}},
            {"clock": {"name": "rains", "secs": RAINS}}]},
        # the nest's hunters sleep: the party's game (a scripted nest)...
        {"id": "asleep", "when": {"all": [{"time": 0.25}, NO_NEST]}, "do": [
            {"sleep": {"tag": "nest_guard", "name": "nest", "within": 6, "by": "party"}},
            {"spare": {"tag": "nest_mother", "on": True}}]},
        # ...or a person's nest: every hunter of it, and every new one while it sleeps (the workers keep working)
        {"id": "asleep_p", "when": {"all": [{"time": 0.25}, NEST]}, "do": [
            {"sleep": {"team": "nest", "name": "nest", "within": 6, "by": "party", "keep": True, "except_kinds": AWAKE_KINDS}},
            {"objective": {"id": "n_mother", "set": "active"}}, {"objective": {"id": "n_sleep", "set": "active"}}]},
        # the patrols walk their rounds on the top (the party's game)
        {"id": "patrols", "when": {"all": [{"time": 1}, NO_NEST]}, "do": [
            {"order": {"tag": "patrol_w", "do": "route", "route": ["pw_a", "pw_b"], "loop": True, "attack": True, "name": "pw"}},
            {"order": {"tag": "patrol_e", "do": "route", "route": ["pe_a", "pe_b"], "loop": True, "attack": True, "name": "pe"}},
            {"order": {"tag": "red_pack", "do": "route", "route": ["rf_a", "rf_b"], "loop": True, "attack": True, "name": "red"}}]},
        {"id": "red_prowl", "when": {"all": [{"time": 1}, NEST]}, "do": [
            {"order": {"tag": "red_pack", "do": "route", "route": ["rf_a", "rf_b"], "loop": True, "attack": True, "name": "red"}}]},
        # ---- the party's start (a person leads it)
        {"id": "intro", "when": {"all": [{"time": 1}, PARTY]}, "do": [
            {"say": ["v_1", "b_1", "tip_1"]}, {"ping": {"area": "stair_foot"}}, {"ping": {"area": "split_foot"}}]},
        {"id": "guide_1", "when": {"all": [{"time": 2}, GUIDE1, PARTY]}, "do": [
            {"say": ["g_stair"]}, {"reveal": {"area": "path_w", "side": "party", "secs": 900}}, {"ping": {"area": "stair_top"}}]},
        {"id": "guide_2", "when": {"all": [{"time": 2}, GUIDE2, PARTY]}, "delay": 8, "do": [
            {"say": ["g_split"]}, {"reveal": {"area": "path_e", "side": "party", "secs": 900}}, {"ping": {"area": "split_top"}}]},
        {"id": "no_guides", "when": {"all": [{"time": 2}, past("saved", "few"), PARTY]}, "do": [{"say": ["v_noguide"]}]},
        {"id": "teles_men", "when": {"all": [{"time": 3}, TOLD, PARTY]}, "delay": 14, "do": [{"say": ["v_teles"]}]},
        {"id": "pieter", "when": {"all": [{"time": 3}, PARTY]}, "delay": 22, "do": [
            {"say": ["v_drawings"]}]},
        {"id": "pieter_alive", "when": {"all": [{"fired": "pieter"}, PIETER]}, "do": [{"say": ["v_pieter"]}]},
        {"id": "pieter_lost", "when": {"all": [{"fired": "pieter"}, {"not": PIETER}]}, "do": [{"say": ["v_pieter_lost"]}]},
        {"id": "red_seen", "when": {"all": [RIVAL, {"seen": {"tag": "red_pack", "by": "party"}}]}, "do": [{"say": ["b_red"]}]},
        {"id": "cache_tip", "when": {"all": [{"time": 40}, PARTY]}, "do": [{"say": ["tip_cache"]}]},
        # ---- the nest's start (a person leads it: no creature speaks)
        {"id": "intro_n", "when": {"all": [{"time": 1}, NEST]}, "do": [
            {"ping": {"area": "stair_foot"}}, {"sound": {"name": "campaign/linnea_call", "area": "kin", "vol": -6}}]},
        # ================================================================ PART 1: THE CLIMB
        {"id": "on_top", "when": {"any": [{"count": {"tag": "valadares", "area": a, "at_least": 1}} for a in ["top", "stair_top", "split_top", "split_in"]]}, "do": [
            {"objective": {"id": "climb", "set": "done"}}, {"objective": {"id": "survey", "set": "active"}},
            {"objective": {"id": "softly", "set": "active"}}, {"say": ["v_top", "tip_marks"]},
            {"ping": {"area": "cairn"}}, {"ping": {"area": "source"}}, {"ping": {"area": "rim"}}, {"ping": {"area": "lookout"}}]},
        # ================================================================ PART 2: THE SURVEY (any order)
        mark("cairn", "v_cairn"),
        mark("source", "v_source"),
        mark("rim", "v_rim", [{"reveal": {"area": "hollow", "side": "party", "secs": 60}}, {"ping": {"area": "kin"}},
                              {"sound": {"name": "campaign/linnea_call", "area": "kin", "vol": -8}}]),
        mark("lookout", "v_lookout", [{"reveal": {"area": "path_e", "side": "party", "secs": 900}}]),
        {"id": "rim_linnea", "when": {"fired": "mark_rim"}, "delay": 5, "do": [{"say": ["v_linnea", "b_linnea"]}]},
        {"id": "rim_young", "when": {"all": [{"fired": "mark_rim"}, TAKEN]}, "delay": 12, "do": [{"say": ["v_young"]}]},
        {"id": "rim_turtle", "when": {"all": [{"fired": "mark_rim"}, EARLY]}, "delay": 16, "do": [{"say": ["v_turtle"]}]},
        # ---- the survey done: THE MAP (the choice, on the top, before the descent)
        {"id": "surveyed", "when": {"all": [{"counter": {"name": "marks", "at_least": 4}}, {"not": {"fired": "part3"}}]}, "delay": 3, "do": [
            {"objective": {"id": "survey", "set": "done"}}, {"say": ["v_done"]},
            {"choice": {"id": "map", "side": "party", "default": "drawn", "time": 30, "line": "v_choice",
                        "title": "THE MAP: the way up the cloud mountain.",
                        "options": [
                            {"id": "drawn", "label": "DRAW IT FOR THE CROWN",
                             "about": "A mapmaker's duty: the Crown must know what is here, and the way to it.",
                             "do": [{"say": ["v_drawn"]}]},
                            {"id": "withheld", "label": "WITHHOLD IT",
                             "about": "Only a sealed letter to the Church. No man should come up here for profit.",
                             "do": [{"say": ["v_withheld"]}]}]}}]},
        {"id": "chosen", "when": {"any": [{"flag": {"map": "drawn"}}, {"flag": {"map": "withheld"}}]}, "do": []},
        # ================================================================ PART 3: THE NEST WAKES
        # (the survey done and the map chosen: the Sire comes home; or the party woke the nest before that)
        {"id": "part3", "when": {"any": [{"fired": "chosen"}, {"awake": "nest"}, {"clock_out": "rains"}]}, "delay": 2, "do": [
            {"wake": {"name": "nest"}},
            {"light": {"to": "jungle_dusk", "secs": 30}}, {"mist": {"sight": 0.7}},
            {"objective": {"id": "softly", "set": "hidden"}}]},
        # the Sire comes home up the way NEAREST Valadares (behind them): the party must cross the top to the other way
        {"id": "sire_w", "when": {"all": [{"fired": "part3"}, {"not": {"fired": "sire_e"}}, {"any": [{"count": {"tag": "valadares", "area": "west_half", "at_least": 1}},
                                                                       {"dead": "valadares"}]}]}, "do": [
            {"spawn": {"team": "nest", "kind": "tyrannosaur", "count": 1, "at": "trail_w", "tag": "sire", "name": "The Tyrant Sire"}},
            {"flag": {"sire_way": "stair"}}, {"sound": {"name": "campaign/sire_roar", "area": "stair_foot"}}]},
        {"id": "sire_e", "when": {"all": [{"fired": "part3"}, {"not": {"fired": "sire_w"}}]}, "do": [
            {"spawn": {"team": "nest", "kind": "tyrannosaur", "count": 1, "at": "trail_e", "tag": "sire", "name": "The Tyrant Sire"}},
            {"flag": {"sire_way": "split"}}, {"sound": {"name": "campaign/sire_roar", "area": "split_foot"}}]},
        {"id": "part3_party", "when": {"all": [{"fired": "part3"}, {"not": {"clock_out": "rains"}}]}, "do": [
            {"objective": {"id": "rains", "set": "hidden"}},
            {"objective": {"id": "flee", "set": "active"}}, {"objective": {"id": "canoe", "set": "active"}},
            {"clock": {"name": "canoe", "secs": CANOE}}, {"ping": {"area": "landing"}}]},
        {"id": "run_e", "when": {"all": [{"fired": "part3_party"}, {"flag": {"sire_way": "stair"}}]}, "do": [
            {"say": ["n_roar", "v_run_e"]}, {"ping": {"area": "split_in"}}, {"ping": {"area": "stair_top"}}]},
        {"id": "run_w", "when": {"all": [{"fired": "part3_party"}, {"flag": {"sire_way": "split"}}]}, "do": [
            {"say": ["n_roar_e", "v_run_w"]}, {"ping": {"area": "stair_top"}}, {"ping": {"area": "split_in"}}]},
        {"id": "woke_early", "when": {"all": [{"fired": "part3"}, {"not": {"fired": "surveyed"}}, {"not": {"clock_out": "rains"}}]}, "do": [
            {"say": ["v_woke"]}, {"objective": {"id": "survey", "set": "hidden"}}, {"objective": {"id": "softly", "set": "failed"}},
            {"flag": {"survey": "cut"}},
            {"choice": {"id": "map", "side": "party", "default": "drawn", "time": 30, "line": "v_choice_run",
                        "title": "THE MAP: what Valadares saw before the nest woke.",
                        "options": [
                            {"id": "drawn", "label": "DRAW IT FOR THE CROWN", "about": "A mapmaker's duty: the Crown must know what is here, and the way to it.", "do": []},
                            {"id": "withheld", "label": "WITHHOLD IT", "about": "Only a sealed letter to the Church. No man should come up here for profit.", "do": []}]}}]},
        {"id": "full_survey", "when": {"fired": "surveyed"}, "do": [{"flag": {"survey": "full"}}]},
        {"id": "part3_nest", "when": {"all": [{"fired": "part3"}, NEST]}, "do": [
            {"objective": {"id": "n_sleep", "set": "done"}}, {"objective": {"id": "n_hunt", "set": "active"}},
            {"ping": {"area": "stair_foot"}}, {"ping": {"area": "split_top"}}]},
        # the rains came first: the survey failed (Benedito would not wait)
        {"id": "rained_out", "when": {"all": [{"clock_out": "rains"}, {"not": {"fired": "surveyed"}}, {"not": {"fired": "part3_party"}}]}, "do": [
            {"say": ["b_rains"]}, {"objective": {"id": "survey", "set": "failed"}}, {"objective": {"id": "climb", "set": "failed"}}]},
        # ---- the scripted nest hunts (the party's game): its hunters and the patrols at the party, the Sire up the stair after them
        {"id": "hunt", "when": {"all": [{"fired": "part3"}, NO_NEST, {"not": {"fired": "the_end"}}]}, "every": 3, "do": [
            {"order": {"tag": "patrol_w", "do": "hunt", "prey_team": "party", "within": 30}},
            {"order": {"tag": "patrol_e", "do": "hunt", "prey_team": "party", "within": 30}},
            {"order": {"tag": "prowlers", "do": "hunt", "prey_team": "party", "within": 30}},
            {"order": {"tag": "sire", "do": "hunt", "prey_team": "party", "within": 90}}]},
        # (the nest's hunters are slow to rise: they hunt what they can reach 8 s after it wakes, the Spitters stay by
        # the Mother; a party that keeps away from the hollow on its way down slips past most of them)
        {"id": "stir", "when": {"all": [{"fired": "part3"}, NO_NEST, {"not": {"fired": "the_end"}}]}, "delay": 8, "every": 3, "do": [
            {"order": {"tag": "nest_guard", "kind": "raptor", "do": "hunt", "prey_team": "party", "within": 22}},
            {"order": {"tag": "nest_guard", "kind": "spitter", "do": "hunt", "prey_team": "party", "within": 9}}]},
        {"id": "sire_climbs", "when": {"all": [{"fired": "part3"}, NO_NEST, {"flag": {"sire_way": "stair"}}]}, "do": [
            {"order": {"tag": "sire", "do": "route", "route": ["stair_foot", "stair_top", "cairn"], "attack": True, "name": "sire_up"}}]},
        {"id": "sire_climbs_e", "when": {"all": [{"fired": "part3"}, NO_NEST, {"flag": {"sire_way": "split"}}]}, "do": [
            {"order": {"tag": "sire", "do": "route", "route": ["split_foot", "split_top", "split_in", "lookout"], "attack": True, "name": "sire_up"}}]},
        # the nest's prowlers: while it sleeps, three more Raptors come down from the north rim every 1:40 from 1:30 and hunt the party
        {"id": "prowl", "when": {"all": [{"time": 90}, NO_NEST, {"not": {"fired": "part3"}}, {"count": {"team": "patrol", "below": 9}}]}, "every": 100, "do": [
            {"spawn": {"team": "patrol", "kind": "raptor", "count": 3, "at": "pn", "tag": "prowlers"}},
            {"order": {"tag": "prowlers", "do": "attack", "to": "mid_top"}}, {"sound": {"name": "campaign/forest_answer", "area": "pn", "vol": -6}}]},
        {"id": "prowl_hunt", "when": {"all": [{"fired": "prowl"}, NO_NEST, {"not": {"fired": "the_end"}}]}, "every": 4, "do": [
            {"order": {"tag": "prowlers", "do": "hunt", "prey_team": "party", "within": 25}}]},
        # the canoe: Valadares on the beach goes last, once the rest are down (or the canoe must leave)
        {"id": "the_end", "when": {"all": [{"fired": "part3_party"}, {"stay": {"tag": "valadares", "area": "landing", "secs": 2}},
                                            {"any": [{"count": {"team": "party", "kind": ["musketeer", "labourer"], "below": 1}}, {"clock_out": "canoe"}]}]}, "do": [
            {"counter": {"name": "down", "add": 1}},
            {"tally": {"flag": "party", "counter": "down", "of": "party0", "bands": [[0, "few"], [0.5, "some"], [1, "all"]]}},
            {"say": ["b_push", "v_end"]}, {"objective": {"id": "flee", "set": "done"}},
            {"spare": {"tag": "valadares", "on": True}}, {"pin": {"tag": "valadares", "on": True}}, {"light": {"to": "grey_dawn", "secs": 8}},
            {"flag": {"linnea": "seen"}}]},
        {"id": "won", "when": {"fired": "the_end"}, "delay": 5, "do": [{"win": "party"}]},
        {"id": "canoe_gone", "when": {"all": [{"clock_out": "canoe"}, {"not": {"fired": "the_end"}},
                                               {"not": {"count": {"tag": "valadares", "area": "landing", "at_least": 1}}}]}, "do": [
            {"say": ["b_gone"]}, {"objective": {"id": "flee", "set": "failed"}}]},
        {"id": "hurt_v", "when": {"all": [{"hp": {"tag": "valadares", "below": 0.5}}, PARTY]}, "do": [{"say": ["b_hurt"]}]},
        # ---- the nest's hunt: under half of them left (on the mountain or down) and the nest has them
        {"id": "left_count", "when": {"all": [{"fired": "part3"}, NEST, {"not": {"fired": "the_end"}}]}, "every": 1, "do": [
            {"counter": {"name": "left", "count": {"team": "party", "kind": PEOPLE}}}, {"counter": {"name": "left", "add_counter": "down"}},
            {"tally": {"flag": "left", "counter": "left", "of": "party0", "bands": [[0, "under"], [0.5, "over"]]}}]},
        {"id": "n_broken", "when": {"all": [NEST, {"flag": {"left": "under"}}, {"not": {"fired": "the_end"}}]}, "do": [
            {"objective": {"id": "n_hunt", "set": "done"}}, {"flag": {"plateau": "kept"}}, {"win": "nest"}]},
        {"id": "n_killed", "when": {"all": [NEST, {"dead": "valadares"}]}, "do": [
            {"objective": {"id": "n_hunt", "set": "done"}}, {"flag": {"plateau": "kept"}}, {"win": "nest"}]},
        {"id": "n_escaped", "when": {"all": [NEST, {"fired": "the_end"}]}, "do": [{"objective": {"id": "n_hunt", "set": "failed"}}]},
        # ================================================================ THE SCRIPTED PARTY (a person leads the nest)
        {"id": "p_up", "when": {"all": [{"time": 3}, NO_PARTY]}, "do": [
            {"order": {"tag": "valadares", "do": "route", "route": ["trail_w", "stair_foot", "stair_top", "cairn"], "name": "leg1"}},
            {"order": {"tag": "guides", "do": "follow", "leader": "valadares", "within": 3}},
            {"order": {"tag": "men", "do": "follow", "leader": "valadares", "within": 2}},
            {"order": {"tag": "teles_men", "do": "follow", "leader": "valadares", "within": 3}}]},
        {"id": "p_leg2", "when": {"all": [{"fired": "mark_cairn"}, NO_PARTY, {"not": {"fired": "part3"}}]}, "delay": 1, "do": [
            {"order": {"tag": "valadares", "do": "route", "route": ["source"], "name": "leg2"}}]},
        {"id": "p_leg3", "when": {"all": [{"fired": "mark_source"}, NO_PARTY, {"not": {"fired": "part3"}}]}, "delay": 1, "do": [
            {"order": {"tag": "valadares", "do": "route", "route": ["rim"], "name": "leg3"}}]},
        {"id": "p_leg4", "when": {"all": [{"fired": "mark_rim"}, NO_PARTY, {"not": {"fired": "part3"}}]}, "delay": 1, "do": [
            {"order": {"tag": "valadares", "do": "route", "route": ["lookout"], "name": "leg4"}}]},
        {"id": "p_down", "when": {"all": [{"fired": "part3"}, NO_PARTY, {"flag": {"sire_way": "stair"}}]}, "delay": 1, "do": [
            {"order": {"tag": "valadares", "do": "route", "route": ["mid_top", "split_in", "split_top", "split_foot", "trail_e", "landing"], "name": "down"}},
            {"order": {"tag": "guides", "do": "follow", "leader": "valadares", "within": 2}},
            {"order": {"tag": "men", "do": "follow", "leader": "valadares", "within": 2}},
            {"order": {"tag": "teles_men", "do": "follow", "leader": "valadares", "within": 3}},
            {"order": {"tag": "benedito", "do": "move", "to": "landing"}}]},
        {"id": "p_down_w", "when": {"all": [{"fired": "part3"}, NO_PARTY, {"flag": {"sire_way": "split"}}]}, "delay": 1, "do": [
            {"order": {"tag": "valadares", "do": "route", "route": ["mid_top", "cairn", "stair_top", "stair_foot", "trail_w", "landing"], "name": "down"}},
            {"order": {"tag": "guides", "do": "follow", "leader": "valadares", "within": 2}},
            {"order": {"tag": "men", "do": "follow", "leader": "valadares", "within": 2}},
            {"order": {"tag": "teles_men", "do": "follow", "leader": "valadares", "within": 3}},
            {"order": {"tag": "benedito", "do": "move", "to": "landing"}}]},
        # (the scripted men at the landing step into the canoe; the rest keep following)
        {"id": "p_board", "when": {"all": [{"fired": "part3"}, NO_PARTY, {"count": {"tag": "valadares", "area": "landing", "at_least": 1}}]}, "every": 2, "do": [
            {"order": {"tag": "men", "do": "move", "to": "landing"}}, {"order": {"tag": "teles_men", "do": "move", "to": "landing"}},
            {"order": {"tag": "guides", "do": "move", "to": "landing"}}]},
    ],
    "speakers": {
        "king": {"name": "The King", "side": "party"},
        "valadares": {"name": "Valadares", "side": "party"},
        "benedito": {"name": "Benedito", "side": "party"},
        "guide": {"name": "The guide from Nazaré", "side": "party"},
        "narrator": {"name": "The Mountain", "side": "party"},
    },
    "lines": {
        # the opening: the King with the report; Valadares goes on
        "k_open1": {"who": "king", "text": "His first letter came from the burning station. His report came at Christmas, in a waxed case, with a map."},
        "k_open2": {"who": "king", "text": "The Crown's mapmaker. He wrote as he walked, and he wrote the truth. Let him tell it."},
        "v_open1": {"who": "valadares", "text": "Majesty. I turned my canoe north the morning the station burned, and followed the tracks up the creek."},
        "v_open2": {"who": "valadares", "text": "Three months. Benedito knew the mountain from his father: the old people call it the house of the clouds."},
        "v_open3": {"who": "valadares", "text": "We came to its foot in September, five men and the river trader, to map what no map had."},
        "k_open_n": {"who": "king", "text": "No creature wrote a report. But the mountain was theirs before it was anyone's."},
        "k_open_n2": {"who": "king", "text": "That September strangers came up their cliff in the mist, while the nest slept."},
        # part 1
        "v_1": {"who": "valadares", "to": "party", "text": "Up the cliff, before the mist lifts and before the rains. Keep together."},
        "b_1": {"who": "benedito", "to": "party", "text": "Two ways up, Senhor. The stair by the falls, and a crack in the rock to the east. I wait with the canoe."},
        "tip_1": {"who": "valadares", "to": "party", "text": "We see little in this mist, and nothing sees us far. Musketeers in front."},
        "g_stair": {"who": "guide", "to": "party", "text": "The stair by the falls. My grandfather went up there for feathers."},
        "g_split": {"who": "guide", "to": "party", "text": "And the crack in the rock. Narrow, but a man can climb it with his hands."},
        "v_noguide": {"who": "valadares", "to": "party", "text": "No one from Nazaré would come. We find the way ourselves."},
        "v_teles": {"who": "valadares", "to": "party", "text": "The lieutenant sent six of his men. He knew what came down from here, and he wanted to see it."},
        "v_drawings": {"who": "valadares", "to": "party", "text": "I carried the drawings of the creature from the pen, so I would know her."},
        "v_pieter": {"who": "valadares", "to": "party", "text": "The doctor's boy, Pieter, drew her for me. A good hand."},
        "v_pieter_lost": {"who": "valadares", "to": "party", "text": "The doctor's boy drew her before he was lost. I carried his drawings, God rest him."},
        "b_red": {"who": "benedito", "to": "party", "text": "Red crests in the trees, Senhor. The other pack, the one that fought at the station. It came up here too."},
        "tip_cache": {"who": "valadares", "to": "party", "text": "The powder is in the cache by the canoe. A man who has fired his shots refills there."},
        "v_top": {"who": "valadares", "to": "party", "text": "The top. Rock towers, black water, and the cloud lying on everything."},
        "tip_marks": {"who": "valadares", "to": "party", "text": "Four marks to take: a cairn, the river's source, the rim of the hollow, the lookout on the east edge. I stand at each a while to take my bearings. Keep the men round me."},
        # part 2
        "v_cairn": {"who": "valadares", "to": "party", "text": "A cairn. Men have been here before us, and long ago."},
        "v_source": {"who": "valadares", "to": "party", "text": "The river's source: a black pool, very cold. The flood that brought the egg down came from here."},
        "v_rim": {"who": "valadares", "to": "party", "text": "The rim. Below it a hollow, and in the hollow a swamp that grows, and something huge rooted in it."},
        "v_linnea": {"who": "valadares", "to": "party", "text": "And there, among them. The creature from the pen. Twice the size. She knows her home."},
        "b_linnea": {"who": "benedito", "to": "party", "text": "They sleep, Senhor. Do not wake them. Not one step closer."},
        "v_young": {"who": "valadares", "to": "party", "text": "Young ones, many, still soft. So the pack carried her eggs up here."},
        "v_turtle": {"who": "valadares", "to": "party", "text": "Two mounds that breathe. A swamp that walked, the doctor's people said. It walked here."},
        "v_lookout": {"who": "valadares", "to": "party", "text": "The lookout. The whole forest to the river, and the crack in the rock below: our way down."},
        "v_done": {"who": "valadares", "to": "party", "text": "Four marks. I have the mountain on paper now."},
        "v_choice": {"who": "valadares", "to": "party", "text": "Now the question I asked myself on that rock: who should have this map?"},
        "v_choice_run": {"who": "valadares", "to": "party", "text": "Even running, I knew I would have to decide what to do with what I had seen."},
        "v_drawn": {"who": "valadares", "to": "party", "text": "I drew it for the Crown. A mapmaker who hides a road is no mapmaker."},
        "v_withheld": {"who": "valadares", "to": "party", "text": "I drew it, and sealed it, for the Church alone. No man should come here for profit."},
        # part 3
        "n_roar": {"who": "narrator", "to": "party", "text": "Below the falls something roared, and the whole hollow answered it."},
        "v_run_e": {"who": "valadares", "to": "party", "text": "He is coming up the falls behind us! Across the top, down the crack in the rock! To the canoe!"},
        "n_roar_e": {"who": "narrator", "to": "party", "text": "In the crack in the rock something roared, and the whole hollow answered it."},
        "v_run_w": {"who": "valadares", "to": "party", "text": "He is in the crack in the rock! Back across the top, down by the falls! To the canoe!"},
        "v_woke": {"who": "valadares", "to": "party", "text": "We were too close. They are awake. Leave the survey: down, to the canoe!"},
        "b_hurt": {"who": "benedito", "to": "party", "text": "Senhor, you are bleeding! Let the soldiers stand between you and them!"},
        "b_rains": {"who": "benedito", "to": "party", "text": "The rains, Senhor. The river rises. I cannot wait longer."},
        "b_push": {"who": "benedito", "to": "party", "text": "In! Push off! Paddle!"},
        "v_end": {"who": "valadares", "to": "party", "text": "We pushed off with the cloud closing behind us."},
        "b_gone": {"who": "benedito", "to": "party", "text": "The canoe is going, Senhor! I cannot hold it!"},
        # the ending: the party's
        "v_end1": {"who": "valadares", "text": "We came down to the river with what we had. The mountain kept the rest."},
        "v_end_all": {"who": "valadares", "text": "Every man who went up came down. I thank God for it in this report."},
        "v_end_some": {"who": "valadares", "text": "Not every man came down. Their names are at the end of this report."},
        "v_end_few": {"who": "valadares", "text": "Few of us came down. I write their names first, before the map."},
        "v_end_drawn": {"who": "valadares", "text": "The map is enclosed, Majesty. The way up, the marks, the nest. The Crown should know."},
        "v_end_withheld": {"who": "valadares", "text": "The map is not enclosed. I have sealed it for the Holy See. Forgive me."},
        "v_end_cut": {"who": "valadares", "text": "My survey is unfinished. The nest woke before I could take every mark."},
        "v_end_linnea": {"who": "valadares", "text": "I saw her, Majesty. The doctor's creature, grown, among her own. She was never his."},
        "k_end1": {"who": "king", "text": "He did his duty, and told me plainly what he saw."},
        "k_end_drawn": {"who": "king", "text": "I kept his map. Others bought copies of it from a clerk. That was not his doing."},
        "k_end_withheld": {"who": "king", "text": "The Church kept his map. The doctor found the way up without it, by a longer road."},
        # the ending: the nest's (the King tells what did not happen)
        "k_end_n1": {"who": "king", "text": "That is not how it went. Valadares came down the mountain, and his report came to me."},
        "k_end_n2": {"who": "king", "text": "But it could have gone that way. Then no one would have known what waited in the cloud."},
    },
    "stills": {
        "rome": {"image": STILL % "b01_01", "caption": "Rome, the present. The King with the mapmaker's report."},
        "mountain": {"image": STILL % "a03_01", "caption": "The cloud mountain north of the Rio Negro, September 2767."},
        "climb": {"image": STILL % "a03_02", "caption": "The climb, by the falls, in the mist."},
        "nest": {"image": STILL % "a03_03", "caption": "The nest in the hollow, asleep."},
        "map": {"image": STILL % "a03_04", "caption": "The map."},
        "flight": {"image": STILL % "a03_05", "caption": "Down to the river."},
    },
    "opening": {
        "party": [
            {"still": "rome", "lines": ["k_open1", "k_open2"]},
            {"still": "mountain", "lines": ["v_open1", "v_open2"]},
            {"still": "climb", "lines": ["v_open3"]},
        ],
        "nest": [
            {"still": "rome", "lines": ["k_open_n"]},
            {"still": "nest", "lines": ["k_open_n2"]},
        ],
    },
    "ending": {
        "party": [
            {"still": "flight", "lines": ["v_end1",
                                         {"id": "v_end_all", "if": {"flag": {"party": "all"}}},
                                         {"id": "v_end_some", "if": {"flag": {"party": "some"}}},
                                         {"id": "v_end_few", "if": {"flag": {"party": "few"}}},
                                         {"id": "v_end_cut", "if": {"flag": {"survey": "cut"}}}]},
            {"still": "map", "lines": [{"id": "v_end_drawn", "if": {"flag": {"map": "drawn"}}},
                                      {"id": "v_end_withheld", "if": {"flag": {"map": "withheld"}}}]},
            {"still": "nest", "lines": ["v_end_linnea"]},
            {"still": "rome", "lines": ["k_end1",
                                       {"id": "k_end_drawn", "if": {"flag": {"map": "drawn"}}},
                                       {"id": "k_end_withheld", "if": {"flag": {"map": "withheld"}}}]},
        ],
        "nest": [
            {"still": "nest", "lines": ["k_end_n1"]},
            {"still": "rome", "lines": ["k_end_n2"]},
        ],
    },
    "briefing": {
        "party": {"still": "mountain", "text": [
            "The cloud mountain north of the Rio Negro, September 2767. You are Valadares, the Crown's mapmaker, with Benedito, the boundary commission's men and whoever came from Nazaré.",
            "Climb the cliff in the mist, take the four survey marks, decide what becomes of the map, and come down to the canoe alive.",
            "Valadares must live. Do not wake what sleeps up there."]},
        "nest": {"still": "nest", "text": [
            "The cloud mountain, September 2767. You are the nest: the Mother in her hollow, her grubs and Rootmaws, her hunters asleep. The Sire is away.",
            "Strangers are climbing your cliff. Let them come. When the Sire is home, hunt them: kill the mapmaker, or bring them under half, before they reach the river."]},
    },
    "debrief": {
        "party": {"still": "flight", "title": "Down from the cloud",
                  "text": "Valadares came down from the plateau with his survey, and saw the creature from the pen among her own.",
                  "text_if": [
                      {"if": {"flag": {"map": "drawn"}}, "text": "He drew the map for the Crown."},
                      {"if": {"flag": {"map": "withheld"}}, "text": "He sealed the map for the Church alone."},
                      {"if": {"flag": {"party": "all"}}, "text": "Every man came down: {down} of {party0}."},
                      {"if": {"flag": {"party": "some"}}, "text": "{down} of {party0} came down."},
                      {"if": {"flag": {"party": "few"}}, "text": "Only {down} of {party0} came down."}]},
        "nest": {"still": "nest", "title": "The mountain keeps its own",
                 "text": "The strangers did not come down. The nest sleeps again in the cloud."},
    },
    "next": {"party": "", "nest": ""},
}


# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the line's own team may build / train / research only its step's
# pieces; the NEW card says what this mission brings (tools/campaign/roster_ladder.py)
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import roster_ladder
roster_ladder.apply(M, "a03_plateau", story_deny={"nest": ["tyrannosaur"]})

out = os.path.join(ROOT, "campaign", "missions", "a03_plateau.json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines")
