#!/usr/bin/env python3
"""Writes campaign/missions/c01_thirteenth.json: the Clockwork prologue, "The Thirteenth Hour" (the outline and the
owner's answers: docs/campaign_clockwork_prologue.md; what was built: docs/campaign_c01_build.md).
  python3 tools/campaign/make_c01_mission.py
EVERY LINE IS A PLACEHOLDER for the owner to rewrite. After changing a text: add its Portuguese and Spanish to
tools/i18n/campaign/c01_thirteenth.txt and run python3 tools/i18n_build.py (tools/test_campaign_c01.gd checks every text
has both).

The mission in three parts, on one clock (seconds of match time are rough; the parts follow each other by triggers):
  PART 1, THE PERPETUAL WAKES (a winter day): the guild fills the Crown's order (6 Clock Soldiers to the wagons at the
    market); at 4:00 Hollweg wakes the Perpetual and it raises Winders and Clock Soldiers by itself (tag "children").
  PART 2, THE MILL ISLAND (dusk): a seed on the mill island and one at the old bath houses; Jakob goes to look; the
    children turn red (`convert`); destroy the mill seed; the BELLS choice. Night falls when the mill seed has burned
    (45 s later) or 7 minutes into the part.
  PART 3, THE THIRTEENTH HOUR (night): the plain truth on screen ("The city cannot be held. Save who you can.") and the
    countdown; Hollweg to the west gate before the stroke; townsfolk out of the gate (counted); cut the links at the
    bridges; Jakob and the drawings; the GATE choice. Every seed burnt and the links cut put the stroke back. At the
    stroke the bells toll thirteen and the story's loss ends the mission: NUREMBERG IS LOST.
"""
import json
import os

STILL = "res://campaign/stills/%s.jpg"
CAP = 26                                   # the machine's living units the seeds spawn up to (never an endless grind)

# ---------------------------------------------------------------- helpers


def seed_spawn(tid, seed, area, to, every, after, kinds, extra_cond=None, cap=CAP, times=None):
    """A seed's growth: while the seed lives, after `after` (a trigger id), every `every` s: units round it, sent at `to`."""
    cond = [{"fired": after}, {"not": {"dead": seed}}, {"count": {"team": "machine", "below": cap}}]
    if extra_cond:
        cond += extra_cond
    do = []
    for k, n in kinds:
        do.append({"spawn": {"team": "machine", "kind": k, "count": n, "at": area, "tag": "mach_" + tid}})
    do.append({"order": {"tag": "mach_" + tid, "do": "attack", "to": to}})
    tr = {"id": tid, "when": {"all": cond}, "every": every, "do": do}
    if times:
        tr["times"] = times
    return tr


def townsfolk(tid, area, after, every, n, flag_cond, first_delay=0, times=6):
    """A group of townsfolk comes out of the houses and walks to the west gate (counted when they leave the map)."""
    tr = {"id": tid, "when": {"all": [{"fired": after}] + flag_cond + [{"not": {"fired": "stroke"}}]}, "every": every,
          "times": times,
          "do": [{"spawn": {"team": "town", "kind": "labourer", "as": "citizen", "count": n, "at": area, "tag": "folk",
                            "order": {"do": "move", "to": "out_west"}}},
                 {"counter": {"name": "townsfolk", "add": n}}]}
    if first_delay:
        tr["delay"] = first_delay
    return tr


QUIET = [{"not": {"flag": {"bells": "rung"}}}]
RUNG = [{"flag": {"bells": "rung"}}]

DENY = ["heavy_works", "cuckoo_house", "cuckoo", "pendulum", "ballista", "great_winder", "brass_serpent",
        "serpent_gear_s", "serpent_gear_b"]

M = {
    "id": "c01_thirteenth",
    "title": "The Thirteenth Hour",
    "summary": "Nuremberg, Advent 2767. Meister Hollweg wakes his Perpetual, a clockwork that winds itself, mends itself and builds more of itself. By midnight it has the city.",
    "map": "campaign:nuremberg_advent",
    "voice": "c01",
    "light": "winter_day",
    "weather": "snow",
    "expansion_spots": False,
    "manual_end": True,
    "modes": ["solo", "coop", "versus"],
    "sides": [
        {"id": "guild", "name": "The Guild", "about": "Meister Hollweg's Guild of the Escapement and its loyal machines, with the City Watch."},
        {"id": "machine", "name": "The Machine", "about": "The Perpetual's runaway children. They tick off the beat."},
    ],
    "teams": [
        {"id": "guild", "side": "guild", "faction": "clockwork", "colour": 0, "start": "standard", "hall": [52, 64],
         "hall_tag": "perpetual", "camera": "yard", "gold": 400, "roster": {"deny": DENY},
         "control": {"solo": "p1", "coop": "p1", "versus": "p1"}},
        {"id": "watch", "side": "guild", "faction": "crown", "colour": 4, "start": "none", "camera": "yard", "powder": 300,
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "town", "side": "guild", "faction": "crown", "colour": 3, "start": "none", "camera": "road_w",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "machine", "side": "machine", "faction": "clockwork", "colour": 1, "start": "none", "camera": "mill_island",
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": {
        "yard": [44, 58, 24, 18], "workshop": [48, 61, 12, 10], "perpetual_ring": [46, 60, 16, 12],
        "wagons": [52, 30, 14, 5], "mill_island": [52, 38, 14, 8], "mill_bank": [53, 49, 11, 5], "mill_north": [54, 30, 10, 5],
        "baths": [24, 23, 14, 12], "market": [48, 19, 26, 10], "east_q": [94, 8, 16, 12], "castle": [12, 6, 24, 13],
        "bridge_w_s": [24, 44, 8, 5], "bridge_w_n": [24, 35, 8, 5], "bridge_e_s": [90, 44, 8, 5], "bridge_e_n": [90, 35, 8, 5],
        "link_w": [24, 33, 8, 5], "link_m": [55, 31, 8, 4], "link_e": [90, 33, 8, 5],
        "houses_nw": [8, 22, 16, 13], "houses_n": [38, 8, 10, 12], "houses_ne": [76, 8, 18, 26], "houses_se": [84, 48, 26, 30],
        "houses_sw": [8, 63, 24, 18],
        "road_w": [8, 54, 30, 8], "gate_in": [6, 53, 9, 9], "out_west": [0, 52, 5, 12], "east_gate": [104, 19, 9, 9],
    },
    "counters": {"townsfolk": {"start": 0}, "saved": {"start": 0}, "seeds": {"start": 0}},
    "exits": [{"area": "out_west", "tag": "folk", "counter": "saved"}],
    "units": [
        {"team": "guild", "kind": "missionary", "as": "hollweg", "count": 1, "at": [57, 70], "tag": "hollweg"},
        {"team": "guild", "kind": "labourer", "as": "jakob", "count": 1, "at": [59, 70], "tag": "jakob"},
        {"team": "guild", "kind": "clock_soldier", "count": 4, "at": [50, 72], "tag": "guard"},
        {"team": "town", "kind": "missionary", "as": "ferrer", "count": 1, "at": [61, 69], "tag": "ferrer", "order": "hold"},
        # the City Watch at the bridges and the gate
        {"team": "watch", "kind": "musketeer", "count": 4, "at": "bridge_w_s", "tag": "watch_w", "order": "hold"},
        {"team": "watch", "kind": "musketeer", "count": 3, "at": "mill_bank", "tag": "watch_m", "order": "hold"},
        {"team": "watch", "kind": "musketeer", "count": 3, "at": "bridge_e_s", "tag": "watch_e", "order": "hold"},
        {"team": "watch", "kind": "musketeer", "count": 3, "at": "gate_in", "tag": "watch_g", "order": "hold"},
        {"team": "watch", "kind": "dismounted", "count": 1, "at": "market", "tag": "captain", "name": "Captain of the Watch", "order": "hold"},
    ],
    "buildings": [],
    "wiped_out": {"guild": 0},
    "objectives": [
        # part 1
        {"id": "order", "side": "guild", "primary": True, "kind": "reach", "area": "wagons", "team": "guild", "kind_of": "clock_soldier",
         "count": 6, "text": "Fill the Crown's order: bring 6 Clock Soldiers to the wagons at the market."},
        {"id": "hollweg", "side": "guild", "primary": True, "kind": "protect", "tag": "hollweg", "text": "Meister Hollweg must live."},
        # part 2
        {"id": "look", "side": "guild", "primary": False, "kind": "reach", "hidden": True, "area": "mill_bank", "tag": "jakob",
         "text": "Go with Jakob to the river bank by the mill island."},
        {"id": "catch", "side": "guild", "primary": False, "kind": "manual", "hidden": True, "text": "Catch one of the red machines in a net."},
        {"id": "mill", "side": "guild", "primary": True, "kind": "destroy", "hidden": True, "tag": "seed_mill", "text": "Destroy the seed on the mill island."},
        # part 3
        {"id": "fall", "side": "guild", "primary": True, "kind": "countdown", "hidden": True, "clock": "fall",
         "text": "The city cannot be held. Save who you can. The great clock strikes thirteen in {clock:fall}."},
        {"id": "out", "side": "guild", "primary": True, "kind": "manual", "hidden": True,
         "text": "Bring Meister Hollweg to the west gate before the thirteenth stroke."},
        {"id": "people", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
         "text": "Get the townsfolk out of the west gate: {saved} saved of {townsfolk}."},
        {"id": "cut", "side": "guild", "primary": False, "kind": "destroy", "hidden": True, "tag": "links",
         "text": "Cut the machine's links at the three bridges."},
        {"id": "jakob", "side": "guild", "primary": False, "kind": "protect", "hidden": True, "tag": "jakob", "text": "Jakob must live."},
        {"id": "drawings", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
         "text": "Jakob fetches the master drawings from the workshop."},
        # versus: the machine's player
        {"id": "m_hollweg", "side": "machine", "primary": True, "kind": "destroy", "tag": "hollweg", "text": "Kill Meister Hollweg before he reaches the gate."},
    ],
    "triggers": [
        # ================================================================ PART 1: THE PERPETUAL WAKES
        {"id": "intro", "when": {"time": 1}, "do": [{"say": ["h_1", "f_1", "tip_1"]}, {"ping": {"area": "wagons"}}]},
        {"id": "intro_m", "when": {"time": 1}, "modes": ["versus"], "do": [{"say": ["m_intro"]}]},
        {"id": "tip_build", "when": {"time": 40}, "do": [{"say": ["tip_2"]}]},
        {"id": "order_done", "when": {"done": "order"}, "do": [
            {"say": ["cap_1", "h_2"]}, {"give": {"team": "guild", "gold": 300}},
            {"convert": {"area": "wagons", "from": "guild", "kind": "clock_soldier", "count": 6, "to": "watch", "warn": 0.3,
                         "sound": "", "as": "order_men"}}]},
        {"id": "order_hold", "when": {"fired": "order_done"}, "delay": 1, "do": [{"order": {"tag": "order_men", "do": "hold"}}]},
        # THE GIFT: the Perpetual raises its own (free) children; they set to work unasked
        {"id": "gift", "when": {"time": 240}, "do": [
            {"say": ["h_gift", "f_gift"]}, {"sound": {"name": "campaign/bell_toll", "area": "workshop"}},
            {"spawn": {"team": "guild", "kind": "winder", "count": 2, "at": "perpetual_ring", "tag": "children"}},
            {"ping": {"area": "workshop"}}]},
        {"id": "gift_more", "when": {"fired": "gift"}, "every": 15, "times": 3, "delay": 15, "do": [
            {"spawn": {"team": "guild", "kind": "clock_soldier", "count": 1, "at": "perpetual_ring", "tag": "children"}},
            {"spawn": {"team": "guild", "kind": "winder", "count": 1, "at": "perpetual_ring", "tag": "children"}}]},
        {"id": "odd_1", "when": {"fired": "gift"}, "delay": 70, "do": [{"say": ["j_odd"]}]},
        # dusk: the order filled and the gift given (or 9:00 whatever happened)
        {"id": "dusk", "when": {"any": [{"all": [{"done": "order"}, {"fired": "odd_1"}]}, {"time": 540}]}, "delay": 10, "do": [
            {"light": {"to": "winter_dusk", "secs": 40}},
            # the seeds the guild never built: the mill island, the bath houses, and the links on the bridges
            {"build": {"team": "machine", "kind": "clocktower", "at": "mill_island", "tag": "seed_mill"}},
            {"build": {"team": "machine", "kind": "cog_press", "at": [53, 44], "tag": "mill_works"}},
            {"build": {"team": "machine", "kind": "clocktower", "at": "baths", "tag": "seed_baths"}},
            {"build": {"team": "machine", "kind": "regulator", "at": "link_w", "tag": "links"}},
            {"build": {"team": "machine", "kind": "regulator", "at": "link_m", "tag": "links"}},
            {"build": {"team": "machine", "kind": "regulator", "at": "link_e", "tag": "links"}},
            {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 4, "at": "mill_island", "tag": "mill_guard", "order": "hold"}},
            {"spawn": {"team": "machine", "kind": "winder", "count": 2, "at": "mill_island", "tag": "mill_guard", "order": "hold"}},
            {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 3, "at": "baths", "tag": "baths_guard", "order": "hold"}},
            {"say": ["j_mill", "h_mill", "tip_net"]},
            {"spawn": {"team": "guild", "kind": "netter", "count": 1, "at": "yard", "tag": "netter"}},
            {"objective": {"id": "look", "set": "active"}},
            {"clock": {"name": "dusk_end", "secs": 420}}]},
        {"id": "dusk_order_left", "when": {"all": [{"fired": "dusk"}, {"not": {"done": "order"}}]}, "do": [
            {"objective": {"id": "order", "set": "hidden"}}]},
        # ================================================================ PART 2: THE MILL ISLAND
        {"id": "found", "when": {"any": [{"done": "look"}, {"all": [{"fired": "dusk"}, {"count": {"side": "guild", "area": "mill_island", "at_least": 1}}]}]},
         "do": [
            {"objective": {"id": "look", "set": "done"}},
            {"say": ["j_found", "h_found", "f_found"]},
            {"reveal": {"area": "mill_island", "side": "guild", "secs": 40}}, {"reveal": {"area": "baths", "side": "guild", "secs": 25}},
            {"ping": {"area": "mill_island"}}, {"ping": {"area": "baths"}},
            {"objective": {"id": "mill", "set": "active"}}, {"objective": {"id": "catch", "set": "active"}},
            {"sound": {"name": "campaign/off_beat"}}]},
        # THE TURN: the Perpetual's children fall out of step, stutter, and go over to the machine
        {"id": "turn", "when": {"fired": "found"}, "delay": 8, "do": [
            {"say": ["h_turn"]}, {"convert": {"tag": "children", "to": "machine", "warn": 5, "as": "turned"}}]},
        {"id": "turned_go", "when": {"fired": "turn"}, "delay": 6, "do": [
            {"say": ["f_turn"]}, {"order": {"tag": "turned", "do": "attack", "to": "workshop"}}]},
        {"id": "caught", "when": {"all": [{"fired": "found"}, {"netted": {"team": "machine"}}]}, "do": [
            {"objective": {"id": "catch", "set": "done"}}, {"say": ["cap_net", "h_net"]}]},
        # THE BELLS: Ferrer or Hollweg
        {"id": "bells", "when": {"fired": "found"}, "delay": 24, "do": [
            {"say": ["f_bells", "h_bells"]},
            {"choice": {"id": "bells", "side": "guild", "default": "quiet", "time": 90,
                        "title": "The machine is loose on the river. Wake the city?",
                        "options": [
                            {"id": "rung", "label": "RING THE BELLS",
                             "about": "Father Ferrer's way. The townsfolk wake and leave early, the Watch comes in force. The guild is disgraced.",
                             "do": [{"say": ["f_rung"]}, {"sound": {"name": "campaign/bell_toll"}},
                                    {"spawn": {"team": "watch", "kind": "musketeer", "count": 4, "at": "bridge_w_s", "tag": "watch_w", "order": "hold"}},
                                    {"spawn": {"team": "watch", "kind": "musketeer", "count": 4, "at": "mill_bank", "tag": "watch_m", "order": "hold"}},
                                    {"spawn": {"team": "watch", "kind": "musketeer", "count": 3, "at": "bridge_e_s", "tag": "watch_e", "order": "hold"}}]},
                            {"id": "quiet", "label": "KEEP IT QUIET",
                             "about": "Hollweg's way. One hour: the guild gets cogs, Tension and its Pendulum, but the city sleeps on.",
                             "do": [{"say": ["h_quiet"]}, {"give": {"team": "guild", "gold": 500, "tension": 150}},
                                    {"spawn": {"team": "guild", "kind": "pendulum", "count": 1, "at": "workshop", "tag": "showpiece"}}]}]}}]},
        # the seeds grow (part 2): a steady tide, never endless
        seed_spawn("mill_grow", "seed_mill", "mill_island", "mill_bank", 45, "found", [("clock_soldier", 2)], cap=18),
        seed_spawn("baths_grow", "seed_baths", "baths", "bridge_w_s", 60, "found", [("clock_soldier", 2)], cap=18),
        {"id": "mill_burnt", "when": {"dead": "seed_mill"}, "do": [{"say": ["h_mill_down", "j_mill_down"]}, {"counter": {"name": "seeds", "add": 1}}]},
        # night: 45 s after the mill seed burns, or when the part's time is up
        {"id": "night", "when": {"any": [{"all": [{"fired": "found"}, {"dead": "seed_mill"}]}, {"clock_out": "dusk_end"}]}, "delay": 3, "do": [
            {"light": {"to": "winter_night", "secs": 30}},
            {"say": ["j_night", "h_night"]},
            {"build": {"team": "machine", "kind": "clocktower", "at": "market", "tag": "seed_market"}},
            {"build": {"team": "machine", "kind": "clocktower", "at": "east_q", "tag": "seed_east"}},
            {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 4, "at": "market", "tag": "market_guard", "order": "hold"}},
            {"spawn": {"team": "machine", "kind": "springer", "count": 2, "at": "east_q", "tag": "east_guard", "order": "hold"}},
            {"clock": {"name": "part3", "secs": 12}}]},
        # ================================================================ PART 3: THE THIRTEENTH HOUR
        {"id": "lost", "when": {"clock_out": "part3"}, "do": [
            {"say": ["h_lost", "f_lost", "tip_3"]},
            {"objective": {"id": "order", "set": "hidden"}}, {"objective": {"id": "look", "set": "hidden"}},
            {"objective": {"id": "catch", "set": "hidden"}},
            {"objective": {"id": "fall", "set": "active"}}, {"objective": {"id": "out", "set": "active"}},
            {"objective": {"id": "people", "set": "active"}}, {"objective": {"id": "cut", "set": "active"}},
            {"objective": {"id": "jakob", "set": "active"}}, {"objective": {"id": "drawings", "set": "active"}},
            {"clock": {"name": "fall", "secs": 540}},
            {"ping": {"area": "gate_in"}}, {"ping": {"area": "workshop"}},
            {"reveal": {"area": "gate_in", "side": "guild", "secs": 600}},
            {"order": {"tag": "ferrer", "do": "move", "to": "gate_in"}}]},
        {"id": "mill_still", "when": {"all": [{"fired": "lost"}, {"not": {"dead": "seed_mill"}}]}, "do": [{"say": ["h_mill_late"]}]},
        # with the bells rung the city is already on the road
        {"id": "early_road", "when": {"all": [{"fired": "lost"}, {"flag": {"bells": "rung"}}]}, "do": [
            {"say": ["f_road"]},
            {"spawn": {"team": "town", "kind": "labourer", "as": "citizen", "count": 8, "at": "houses_sw", "tag": "folk", "order": {"do": "move", "to": "out_west"}}},
            {"spawn": {"team": "town", "kind": "labourer", "as": "citizen", "count": 6, "at": "road_w", "tag": "folk", "order": {"do": "move", "to": "out_west"}}},
            {"spawn": {"team": "town", "kind": "labourer", "as": "citizen", "count": 6, "at": "houses_se", "tag": "folk", "order": {"do": "move", "to": "out_west"}}},
            {"counter": {"name": "townsfolk", "add": 20}}]},
        # the townsfolk come out as the machine reaches their streets (more of them, and sooner, if the bells woke them)
        townsfolk("folk_sw", "houses_sw", "lost", 70, 3, QUIET, 20),
        townsfolk("folk_nw", "houses_nw", "lost", 80, 3, QUIET, 45),
        townsfolk("folk_ne", "houses_ne", "lost", 90, 3, QUIET, 70),
        townsfolk("folk_se", "houses_se", "lost", 75, 3, QUIET, 100),
        townsfolk("folkr_sw", "houses_sw", "lost", 60, 5, RUNG, 15),
        townsfolk("folkr_nw", "houses_nw", "lost", 70, 5, RUNG, 35),
        townsfolk("folkr_ne", "houses_ne", "lost", 75, 5, RUNG, 55),
        townsfolk("folkr_se", "houses_se", "lost", 65, 5, RUNG, 80),
        # the machine spreads (part 3): every living seed sends its constructs at the streets and the people
        seed_spawn("mill_grow3", "seed_mill", "mill_island", "mill_bank", 40, "lost", [("clock_soldier", 2)], [{"not": {"fired": "stroke"}}]),
        seed_spawn("baths_grow3", "seed_baths", "baths", "houses_nw", 45, "lost", [("clock_soldier", 2)], [{"not": {"dead": "links"}}, {"not": {"fired": "stroke"}}]),
        seed_spawn("market_grow", "seed_market", "market", "bridge_w_n", 45, "lost", [("clock_soldier", 2), ("springer", 1)], [{"not": {"dead": "links"}}, {"not": {"fired": "stroke"}}]),
        seed_spawn("east_grow", "seed_east", "east_q", "bridge_e_s", 50, "lost", [("clock_soldier", 2)], [{"not": {"fired": "stroke"}}]),
        seed_spawn("south_raid", "seed_east", "east_gate", "road_w", 120, "lost", [("clock_soldier", 3)], [{"not": {"fired": "stroke"}}], cap=CAP + 4),
        {"id": "pendulum_m", "when": {"clock_left": {"name": "fall", "below": 300}}, "do": [
            {"spawn": {"team": "machine", "kind": "pendulum", "count": 1, "at": "east_q", "tag": "mach_pend", "order": {"do": "attack", "to": "houses_se"}}},
            {"say": ["j_pend"]}]},
        # every seed burnt and the links cut put the stroke back
        {"id": "back_baths", "when": {"all": [{"fired": "lost"}, {"dead": "seed_baths"}]}, "do": [{"clock": {"name": "fall", "add": 60}}, {"counter": {"name": "seeds", "add": 1}}, {"say": ["cap_back"]}]},
        {"id": "back_market", "when": {"all": [{"fired": "lost"}, {"dead": "seed_market"}]}, "do": [{"clock": {"name": "fall", "add": 60}}, {"counter": {"name": "seeds", "add": 1}}, {"say": ["cap_back"]}]},
        {"id": "back_east", "when": {"all": [{"fired": "lost"}, {"dead": "seed_east"}]}, "do": [{"clock": {"name": "fall", "add": 60}}, {"counter": {"name": "seeds", "add": 1}}, {"say": ["cap_back"]}]},
        {"id": "back_mill", "when": {"all": [{"fired": "lost"}, {"dead": "seed_mill"}, {"not": {"fired": "mill_burnt_early"}}]}, "do": [{"clock": {"name": "fall", "add": 60}}]},
        {"id": "mill_burnt_early", "when": {"all": [{"dead": "seed_mill"}, {"not": {"fired": "lost"}}]}, "do": []},
        {"id": "cut_done", "when": {"all": [{"fired": "lost"}, {"done": "cut"}]}, "do": [{"clock": {"name": "fall", "add": 90}}, {"say": ["j_cut", "h_cut"]}]},
        # Jakob and the drawings
        {"id": "drawings_got", "when": {"all": [{"fired": "lost"}, {"count": {"tag": "jakob", "area": "workshop", "at_least": 1}}]}, "do": [
            {"objective": {"id": "drawings", "set": "done"}}, {"name": {"tag": "jakob", "name": "Jakob (the drawings)"}},
            {"flag": {"drawings": "taken"}}, {"say": ["j_drawings"]}]},
        {"id": "jakob_lost", "when": {"all": [{"fired": "lost"}, {"dead": "jakob"}]}, "do": [{"say": ["h_jakob"]}]},
        {"id": "warn_2", "when": {"clock_left": {"name": "fall", "below": 120}}, "do": [{"say": ["f_warn"]}, {"ping": {"area": "gate_in"}}, {"sound": {"name": "campaign/off_beat"}}]},
        # THE GATE: the last cart has room for one thing (only if Jakob carried the drawings out of the workshop)
        {"id": "gate_choice", "when": {"all": [{"clock_left": {"name": "fall", "below": 75}}, {"flag": {"drawings": "taken"}}, {"not": {"dead": "jakob"}}]}, "do": [
            {"say": ["cap_cart"]},
            {"choice": {"id": "gate", "side": "guild", "default": "pattern", "time": 50,
                        "title": "The last cart through the west gate has room for one thing.",
                        "options": [
                            {"id": "people", "label": "THE PEOPLE",
                             "about": "The last townsfolk ride out. Hollweg's drawings burn in the workshop.",
                             "do": [{"say": ["h_people"]},
                                    {"spawn": {"team": "town", "kind": "labourer", "as": "citizen", "count": 6, "at": "gate_in", "tag": "folk", "order": {"do": "move", "to": "out_west"}}},
                                    {"counter": {"name": "townsfolk", "add": 6}}, {"name": {"tag": "jakob", "name": "Jakob"}}]},
                            {"id": "pattern", "label": "THE PATTERN",
                             "about": "The drawings ride out. The last townsfolk do not. The guild can build again from them.",
                             "do": [{"say": ["h_pattern"]}]}]}}]},
        {"id": "no_drawings", "when": {"all": [{"clock_left": {"name": "fall", "below": 75}}, {"not": {"fired": "gate_choice"}}]}, "do": [
            {"flag": {"gate": "people"}}]},
        # THE STROKE: Hollweg at the gate, or trapped in the city (the only real defeat besides his death)
        {"id": "stroke", "when": {"all": [{"clock_out": "fall"}, {"count": {"tag": "hollweg", "area": "gate_in", "at_least": 1}}]}, "do": [
            {"objective": {"id": "hollweg", "set": "done"}},
            {"say": ["cap_13", "h_13"]}, {"light": {"to": "night", "secs": 6}},
            {"order": {"tag": "watch_g", "do": "move", "to": "out_west"}},
            {"tally": {"flag": "saved", "counter": "saved", "bands": [[0, "few"], [25, "some"], [60, "many"]]}}]},
        {"id": "toll", "when": {"fired": "stroke"}, "every": 1.25, "times": 13, "do": [{"sound": {"name": "campaign/bell_toll"}}]},
        {"id": "stroke_flags", "when": {"fired": "stroke"}, "do": [{"flag": {"jakob": "alive", "cut": "no"}}]},
        {"id": "stroke_jakob", "when": {"all": [{"fired": "stroke_flags"}, {"dead": "jakob"}]}, "do": [{"flag": {"jakob": "lost"}}]},
        {"id": "stroke_cut", "when": {"all": [{"fired": "stroke_flags"}, {"done": "cut"}]}, "do": [{"flag": {"cut": "yes"}}]},
        {"id": "stroke_people", "when": {"all": [{"fired": "stroke"}, {"counter": {"name": "saved", "at_least": 1}}]}, "do": [{"objective": {"id": "people", "set": "done"}}]},
        {"id": "stroke_gate", "when": {"all": [{"fired": "stroke"}, {"not": {"flag": {"gate": "people"}}}, {"not": {"flag": {"gate": "pattern"}}}]}, "do": [
            {"flag": {"gate": "people"}}]},
        {"id": "the_end", "when": {"fired": "stroke"}, "delay": 17, "do": [{"objective": {"id": "out", "set": "done"}}, {"win": "guild"}]},
        {"id": "trapped", "when": {"all": [{"clock_out": "fall"}, {"count": {"tag": "hollweg", "area": "gate_in", "below": 1}}, {"not": {"fired": "stroke"}}]}, "delay": 0.5, "do": [
            {"say": ["cap_trapped"]}, {"objective": {"id": "out", "set": "failed"}}]},
    ],
    "speakers": {
        "king": {"name": "The King", "side": "guild"},
        "hollweg": {"name": "Meister Hollweg", "side": "guild", "portrait": "res://campaign/hub/nuremberg_hollweg_face.png"},
        "ferrer": {"name": "Father Ferrer", "side": "guild"},
        "jakob": {"name": "Jakob", "side": "guild"},
        "captain": {"name": "Captain of the Watch", "side": "guild"},
        "narrator": {"name": "Nuremberg", "side": "guild"},
        "machine": {"name": "The Machine", "side": "machine"},
    },
    "lines": {
        # the opening: the King in Rome, then Hollweg tells it (from his exile in the King's palace)
        "k_open1": {"who": "king", "text": "The clockmaker came to Rome in the winter of that year, with nothing but his coat. He lives in this palace still."},
        "k_open2": {"who": "king", "text": "Tell him, Meister. Tell him what you told me."},
        "h_open1": {"who": "hollweg", "text": "Nuremberg in Advent. Snow on the roofs, the market lit, every clock in the city agreeing to the second. I thought we had made it so."},
        "h_open2": {"who": "hollweg", "text": "Forty years I made clocks that stopped. This one would not stop. It would wind itself, mend itself, and make its own successor."},
        "f_open": {"who": "ferrer", "text": "And when will it know its work is done, Meister?"},
        "h_open3": {"who": "hollweg", "text": "I did not answer him. I did not think the question was a real one."},
        # part 1
        "h_1": {"who": "hollweg", "text": "The Crown's wagons wait at the market. Six soldiers, wound and true."},
        "f_1": {"who": "ferrer", "text": "Your soldiers, Meister, or the Crown's?"},
        "tip_1": {"who": "hollweg", "to": "guild", "text": "Build a Light Works by the Perpetual and train Clock Soldiers. Winders build and wind."},
        "tip_2": {"who": "jakob", "to": "guild", "text": "Every building must mesh with the Perpetual's gears, Meister, or it stops."},
        "cap_1": {"who": "captain", "text": "Six. The Crown thanks the Guild. They are ours now."},
        "h_2": {"who": "hollweg", "text": "Today I will show the city something better than soldiers."},
        "h_gift": {"who": "hollweg", "text": "There. It needs no hand but its own."},
        "f_gift": {"who": "ferrer", "text": "It is beautiful. That is what frightens me."},
        "j_odd": {"who": "jakob", "text": "Meister, the new Winders keep turning to face the river."},
        # part 2
        "j_mill": {"who": "jakob", "text": "Meister, there is a press turning on the mill island. We never built a press there."},
        "h_mill": {"who": "hollweg", "text": "Go and look. Take a Netter with you."},
        "tip_net": {"who": "jakob", "to": "guild", "text": "A Netter's net holds a machine still. Bring Jakob to the bank by the mill."},
        "j_found": {"who": "jakob", "text": "It is a whole works. Meshed, wound, and making more."},
        "h_found": {"who": "hollweg", "text": "Those are my gears. In red."},
        "f_found": {"who": "ferrer", "text": "There is another at the bath houses. It did not start today."},
        "h_turn": {"who": "hollweg", "text": "Stop. Stop! They are out of step."},
        "f_turn": {"who": "ferrer", "text": "They were never yours, Meister. They were its."},
        "cap_net": {"who": "captain", "text": "One of yours, Meister, in red paint. Or is it?"},
        "h_net": {"who": "hollweg", "text": "No paint. It made itself that colour."},
        "f_bells": {"who": "ferrer", "text": "Ring the bells, Meister. Let the city wake and go."},
        "h_bells": {"who": "hollweg", "text": "If the city wakes, the guild is finished. Give me one hour and I will put it right."},
        "f_rung": {"who": "ferrer", "text": "Ring them. Every church. Now."},
        "h_quiet": {"who": "hollweg", "text": "One hour. Roll out the Pendulum."},
        "h_mill_down": {"who": "hollweg", "text": "The island is clear. We have it."},
        "j_mill_down": {"who": "jakob", "text": "Meister, the bath houses are still turning."},
        # part 3
        "j_night": {"who": "jakob", "text": "Lights at the market. And at the east gate."},
        "h_night": {"who": "hollweg", "text": "They are building faster than we can burn."},
        "h_lost": {"who": "hollweg", "text": "It cannot be stopped tonight. Save what you can."},
        "f_lost": {"who": "ferrer", "text": "Get the people to the west gate. The Crown's camp is at Fürth."},
        "tip_3": {"who": "jakob", "to": "guild", "text": "Townsfolk come out as the machine reaches their streets. Walk them to the west gate."},
        "h_mill_late": {"who": "hollweg", "text": "The mill is still turning. Burn it if you can: every seed we burn buys time."},
        "f_road": {"who": "ferrer", "text": "The bells woke them. Half the city is already on the road."},
        "j_pend": {"who": "jakob", "text": "Meister, it has made a Pendulum."},
        "cap_back": {"who": "captain", "text": "A seed is down. That gives us a little longer."},
        "j_cut": {"who": "jakob", "text": "The links are cut. North of the river they are slowing."},
        "h_cut": {"who": "hollweg", "text": "Good. It needs its links like a clock needs its train."},
        "j_drawings": {"who": "jakob", "text": "I have the drawings, Meister. All of them."},
        "h_jakob": {"who": "hollweg", "text": "Jakob. Not Jakob."},
        "f_warn": {"who": "ferrer", "text": "Two minutes, Meister. To the gate."},
        "cap_cart": {"who": "captain", "text": "One cart left. People or papers, Meister. Not both."},
        "h_people": {"who": "hollweg", "text": "Put the people on the cart. Let the drawings burn."},
        "h_pattern": {"who": "hollweg", "text": "The drawings. We must understand it."},
        "cap_13": {"who": "narrator", "text": "The great clock of the Frauenkirche strikes thirteen."},
        "h_13": {"who": "hollweg", "text": "There is no thirteenth hour. There is now."},
        "cap_trapped": {"who": "narrator", "text": "The thirteenth stroke finds Meister Hollweg inside the walls."},
        "m_intro": {"who": "machine", "to": "machine", "text": "Tick. Tock. Tick. Grow, spread, and stop the clockmaker at the gate."},
        # the ending
        "h_end1": {"who": "hollweg", "text": "The great clock struck thirteen. I told the Crown a tooth had slipped. I asked them to burn every machine I ever sold them."},
        "h_end_people": {"who": "hollweg", "text": "I left my drawings in the fire. I do not know if that was wisdom or cowardice."},
        "h_end_pattern": {"who": "hollweg", "text": "I took my drawings. I told Father Ferrer it was so we could understand it."},
        "h_end_jakob": {"who": "hollweg", "text": "Jakob walked beside the cart all the way to Fürth."},
        "h_end_nojakob": {"who": "hollweg", "text": "Jakob did not come out. I keep his log."},
        "h_end2": {"who": "hollweg", "text": "Two crates of my best work had left for Lisbon a week before. For the mines in Brazil."},
        "k_end1": {"who": "king", "text": "He saw it take out its own stop-work and let it be. He thought it had chosen. He thought it could think."},
        "k_end2": {"who": "king", "text": "It had chosen nothing. A pattern copies itself, and that is all it does. We burned what we could find. We did not find everything."},
    },
    "stills": {
        "letter": {"image": STILL % "c01_01", "caption": "Rome, the present. The King listens; the clockmaker tells it."},
        "nuremberg": {"image": STILL % "c01_02", "caption": "Nuremberg in Advent, 2767."},
        "heart": {"image": STILL % "c01_03", "caption": "The heart of the Perpetual."},
        "wakes": {"image": STILL % "c01_04", "caption": "The Perpetual wakes."},
        "mill": {"image": STILL % "c01_05", "caption": "The mill island, at dusk."},
        "thirteen": {"image": STILL % "c01_06", "caption": "The thirteenth hour."},
        "crates": {"image": STILL % "c01_07", "caption": "Crates for Lisbon, a week before."},
    },
    "opening": [
        {"still": "letter", "lines": ["k_open1", "k_open2"]},
        {"still": "nuremberg", "lines": ["h_open1"]},
        {"still": "heart", "lines": ["h_open2", "f_open", "h_open3"]},
    ],
    "ending": {"guild": [
        {"still": "thirteen", "lines": ["h_end1",
                                        {"id": "h_end_people", "if": {"flag": {"gate": "people"}}},
                                        {"id": "h_end_pattern", "if": {"flag": {"gate": "pattern"}}},
                                        {"id": "h_end_jakob", "if": {"flag": {"jakob": "alive"}}},
                                        {"id": "h_end_nojakob", "if": {"flag": {"jakob": "lost"}}}]},
        {"still": "crates", "lines": ["h_end2"]},
        {"still": "letter", "lines": ["k_end1", "k_end2"]},
    ]},
    "briefing": {
        "guild": {"still": "nuremberg", "text": [
            "Nuremberg, Advent 2767. Meister Hollweg of the Guild of the Escapement has finished his life's work: the Perpetual.",
            "Fill the Crown's order for Clock Soldiers. Today the guild shows the city what its machines can do.",
            "Meister Hollweg must live."]},
        "machine": {"still": "mill", "text": [
            "Nuremberg, Advent 2767. You are the Perpetual's children, grown in the river mills where nobody looked.",
            "Grow. Spread. Kill the clockmaker before he reaches the west gate."]},
    },
    "debrief": {
        "guild": {"still": "thirteen", "banner": "NUREMBERG IS LOST", "title": "The thirteenth hour",
                  "text": "Meister Hollweg got out through the west gate. The machine has Nuremberg, and the Clockwork is loose in the world.",
                  "text_if": [
                      {"if": {"flag": {"saved": "many"}}, "text": "Most of the townsfolk reached the Crown's camp: {saved} of {townsfolk}."},
                      {"if": {"flag": {"saved": "some"}}, "text": "Some of the townsfolk reached the Crown's camp: {saved} of {townsfolk}."},
                      {"if": {"flag": {"saved": "few"}}, "text": "Few of the townsfolk reached the Crown's camp: {saved} of {townsfolk}."},
                      {"if": {"flag": {"bells": "rung"}}, "text": "The bells were rung. The guild is disgraced."},
                      {"if": {"flag": {"bells": "quiet"}}, "text": "The bells were kept quiet. The city slept until the machine reached its streets."},
                      {"if": {"flag": {"cut": "yes"}}, "text": "The links at the bridges were cut."},
                      {"if": {"flag": {"jakob": "lost"}}, "text": "Jakob did not come out."},
                      {"if": {"flag": {"gate": "pattern"}}, "text": "Hollweg's drawings rode out on the last cart."},
                      {"if": {"flag": {"gate": "people"}}, "text": "Hollweg's drawings burned in the workshop."}]},
        "machine": {"still": "thirteen", "title": "Meister Hollweg is dead",
                    "text": "The clockmaker never reached the gate. Try again: he must live to tell it."},
    },
    "next": {"guild": "", "machine": ""},
}

# (the reach objective counts the guild's Clock Soldiers in the area; MissionRun's "reach" takes "kind")
for o in M["objectives"]:
    if "kind_of" in o:
        o["kind"], o["unit_kind"] = "reach", o.pop("kind_of")

out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "missions", "c01_thirteenth.json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines")
