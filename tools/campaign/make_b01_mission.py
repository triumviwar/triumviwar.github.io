#!/usr/bin/env python3
"""Writes campaign/missions/b01_specimen.json: the Brood prologue, "Specimen One" (the outline and the owner's answers:
docs/campaign_brood_prologue.md; what was built: docs/campaign_b01_build.md).
  python3 tools/campaign/make_b01_mission.py
EVERY LINE IS A PLACEHOLDER for the owner to rewrite. After changing a text: add its Portuguese and Spanish to
tools/i18n/campaign/b01_specimen.txt and run python3 tools/i18n_build.py (tools/test_campaign_b01.gd checks every text
has both).

The mission in three parts, on one clock (the parts follow each other by triggers):
  PART 1, SPECIMEN ONE (afternoon): build Linnea's pen (the hands build the marked stakes); Valadares comes down the river;
    Pieter's tracks at the creek's ford; dusk: Linnea CALLS, something answers, two hunters come for the goats; the
    first CHOICE: tell Lieutenant Teles, or keep it quiet.
  PART 2, THE EVE OF SAINT JOHN (dusk to night, rain): Lindqvist explains his scent-lure, then Pieter sets the three
    jars at the forest's edge (the lure works on the first two waves, then they walk past the jars to her pen); the
    village (told: already at the fort, the garrison on the causeway, the gun at the station's landing; quiet: bring
    the village in under attack, Teles late); the Mound Turtle walks out of the igapó and roots at the creek's mouth,
    Spitters out of its swamp. Ends when the forest goes quiet.
  PART 3, THE TYRANT (deep night): the Tyrant Sire; the plain truth on screen ("The station cannot be held. Save who
    you can and get to the jetty.") and the countdown (Benedito's canoes); he roots by her pen (rooted he cannot bite),
    calls with her, she lays a clutch in her straw; hurt to a third he gets up (he cannot die tonight); the station
    burns; he takes her into the forest; the second CHOICE in the burning specimen house: burn the eggs or save the
    research; the people walk to the jetty and are counted. At the canoes' time the story's loss ends the mission:
    THE STATION IS LOST.
"""
import json
import os

STILL = "res://campaign/stills/%s.jpg"
CAP3 = 12                                  # (in Part 3, while the Sire calls: the station's retreat stays fair)
CAP = 22                                   # the pack's living creatures the waves spawn up to (never an endless grind)
TOLD = [{"flag": {"teles": "told"}}]
QUIET = [{"flag": {"teles": "quiet"}}]

DENY = ["horse_breeder", "foundry", "armoury"]

# ---------------------------------------------------------------- the waves


def wave(tid, trail, jar, after, every, delay, raptors, spitters=0):
    """A pack wave out of a trail head, as its call is answered: to its trail's lure jar while the lure still works (the
    first two waves, that jar set), then to Linnea's pen. Never more than CAP creatures alive."""
    lure = {"all": [{"counter": {"name": "waves", "below": 2}}, {"counter": {"name": jar + "_set", "at_least": 1}}]}
    do = [{"spawn": {"team": "pack", "kind": "raptor", "count": raptors, "at": trail, "tag": tid}}]
    if spitters:
        do.append({"spawn": {"team": "pack", "kind": "spitter", "count": spitters, "at": trail, "tag": tid}})
    do += [{"order": {"tag": tid, "do": "attack", "to": "pen", "to_if": [{"if": lure, "to": jar}]}},
           {"counter": {"name": "waves", "add": 1}}, {"sound": {"name": "campaign/forest_answer", "area": trail}},
           {"ping": {"area": trail}}]
    return [{"id": tid, "when": {"all": [{"fired": after}, {"not": {"fired": "turn"}}, {"count": {"team": "pack", "below": CAP}}]},
             "every": every, "delay": delay, "do": do}]


def jar(n, area):
    """Pieter at one of the three marks: a jar of the lure set there."""
    return {"id": "jar_" + n, "when": {"all": [{"fired": "eve"}, {"count": {"tag": "pieter", "area": area, "at_least": 1}}]}, "do": [
        {"counter": {"name": area + "_set", "set": 1}}, {"counter": {"name": "jars", "add": 1}}, {"ping": {"area": area}}]}


M = {
    "id": "b01_specimen",
    "title": "Specimen One",
    "summary": "The Rio Negro, June 2767. Dr. Lindqvist of the Academy keeps a creature no one has seen in a crate at his river station. On Saint John's Eve her kin come for her.",
    "map": "campaign:rio_negro_station",
    "voice": "b01",
    "light": "jungle_day",
    "floor": [0.62, 0.66, 0.6],
    "expansion_spots": False,
    "manual_end": True,
    "modes": ["solo", "coop", "versus"],
    "sides": [
        {"id": "station", "name": "The Station", "about": "The Academy's station on the Rio Negro, the Crown's fort at São Gabriel and the mission village."},
        {"id": "pack", "name": "The Pack", "about": "Her kin, out of the flooded forest."},
    ],
    "teams": [
        {"id": "station", "side": "station", "faction": "crown", "colour": 3, "start": "none", "camera": "yard", "gold": 300, "powder": 400,
         "roster": {"deny": DENY}, "control": {"solo": "p1", "coop": "p1", "versus": "p1"}},
        {"id": "garrison", "side": "station", "faction": "crown", "colour": 4, "start": "none", "camera": "fort", "powder": 300,
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "pen", "side": "station", "faction": "brood", "colour": 3, "start": "none", "camera": "pen",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "pack", "side": "pack", "faction": "brood", "colour": 2, "start": "none", "camera": "jar_c",
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": {
        "yard": [49, 53, 28, 15], "house": [51, 54, 5, 4], "spec": [62, 52, 6, 6], "garden": [50, 61, 6, 6],
        "pen": [66, 59, 4, 4], "pen_in": [67, 60, 2, 2], "nest": [70, 55, 5, 5], "nest_wide": [62, 50, 18, 16], "goats": [71, 62, 5, 5],
        "jetty": [57, 70, 11, 6], "gun_spot": [69, 70, 3, 3],
        "village": [3, 54, 27, 21], "bonfires": [12, 63, 11, 8], "causeway_w": [30, 67, 16, 6], "causeway_e": [86, 67, 16, 6],
        "fort": [105, 56, 18, 15], "fort_steps": [107, 72, 12, 4],
        "ford": [78, 43, 8, 7], "mouth": [84, 58, 7, 8], "igapo_e": [94, 47, 6, 4],
        "trail_nw": [20, 2, 6, 5], "trail_c": [74, 2, 6, 5], "trail_ne": [108, 2, 6, 5],
        "jar_w": [27, 42, 6, 5], "jar_c": [72, 41, 6, 5], "jar_e": [97, 42, 6, 5],
        "out_n": [74, 0, 7, 4],
    },
    "counters": {"jars": {"start": 0, "of": 3}, "jar_w_set": {"start": 0}, "jar_c_set": {"start": 0}, "jar_e_set": {"start": 0},
                 "waves": {"start": 0}, "people": {"start": 0}, "saved": {"start": 0}, "folk_in": {"start": 0}, "drove": {"start": 0}},
    "exits": [
        {"area": "jetty", "team": "station", "except": ["lindqvist", "valadares"], "counter": "saved", "after": "canoes_here"},
        {"area": "jetty", "tag": "folk", "counter": "saved", "after": "canoes_here"},
        {"area": "fort_steps", "tag": "folk", "counter": "saved", "after": "canoes_here"},
        {"area": "out_n", "tag": "taken", "after": "taken"},
        {"area": "out_n", "tag": "sire", "after": "taken"},
        {"area": "out_n", "team": "pack", "after": "taken"},
    ],
    "units": [
        {"team": "station", "kind": "musketeer", "as": "lindqvist", "count": 1, "at": [61, 58], "tag": "lindqvist"},
        {"team": "station", "kind": "labourer", "as": "pieter", "count": 1, "at": [63, 58], "tag": "pieter"},
        {"team": "station", "kind": "labourer", "count": 6, "at": [57, 59], "tag": "hands"},
        {"team": "station", "kind": "musketeer", "count": 4, "at": [58, 63], "tag": "guards"},
        {"team": "pen", "kind": "brood_mother", "as": "linnea", "count": 1, "at": "pen_in", "tag": "linnea"},
        # the garrison at the fort, the friar and the village, the trader at his canoes
        {"team": "garrison", "kind": "dismounted", "as": "teles", "count": 1, "at": [114, 63], "tag": "teles", "order": "hold"},
        {"team": "garrison", "kind": "musketeer", "count": 5, "at": [110, 62], "tag": "garrison_a", "order": "hold"},
        {"team": "garrison", "kind": "musketeer", "count": 5, "at": [117, 62], "tag": "garrison_b", "order": "hold"},
        {"team": "garrison", "kind": "missionary", "as": "joaquim", "count": 1, "at": [16, 61], "tag": "joaquim", "order": "hold"},
        {"team": "garrison", "kind": "labourer", "as": "villager", "count": 14, "at": "bonfires", "tag": "folk", "order": "hold"},
        {"team": "garrison", "kind": "labourer", "as": "benedito", "count": 1, "at": [62, 73], "tag": "benedito", "order": "hold"},
    ],
    "buildings": [
        {"team": "station", "kind": "town_hall", "at": [51, 54], "tag": "station_house"},
        {"team": "station", "kind": "cottage", "at": [64, 54], "tag": "specimen_house"},
        {"team": "station", "kind": "farm", "at": [50, 61], "tag": "garden"},
        {"team": "garrison", "kind": "barracks", "at": [110, 58], "tag": "fort_house"},
        # her pen: stakes and a gate round her crate, paid for, for the hands to build
        *[{"team": "station", "kind": "wall", "at": [x, y], "tag": "pen", "site": True}
          for (x, y) in [(66, 59), (67, 59), (68, 59), (69, 59), (66, 60), (69, 60), (69, 61), (66, 62), (67, 62), (68, 62), (69, 62)]],
        {"team": "station", "kind": "gate", "at": [66, 61], "tag": "pen", "site": True},
    ],
    "wiped_out": {"station": 0},
    "objectives": [
        # part 1
        {"id": "pen", "side": "station", "primary": True, "kind": "build", "tag": "pen",
         "text": "Build Linnea's pen: send the hands to the marked stakes beside the specimen house."},
        {"id": "lindqvist", "side": "station", "primary": True, "kind": "protect", "tag": "lindqvist", "text": "Dr. Lindqvist must live."},
        {"id": "valadares", "side": "station", "primary": True, "kind": "protect", "hidden": True, "tag": "valadares", "text": "Valadares must live."},
        {"id": "meet", "side": "station", "primary": False, "kind": "reach", "hidden": True, "area": "jetty", "tag": "lindqvist",
         "text": "Meet Valadares at the jetty with Dr. Lindqvist."},
        {"id": "tracks", "side": "station", "primary": False, "kind": "reach", "hidden": True, "area": "ford", "tag": "pieter",
         "text": "Go with Pieter to the creek's ford."},
        {"id": "goats", "side": "station", "primary": True, "kind": "destroy", "hidden": True, "tag": "goat_raptors",
         "text": "Drive the creatures away from the goats."},
        # part 2
        {"id": "lure", "side": "station", "primary": True, "kind": "manual", "hidden": True,
         "text": "Set the lure: Pieter carries a jar to each mark at the forest's edge ({jars} of 3)."},
        {"id": "village", "side": "station", "primary": False, "kind": "manual", "hidden": True,
         "text": "Bring the village in: walk Frei Joaquim and the villagers to the station ({folk_in} in)."},
        {"id": "hold", "side": "station", "primary": True, "kind": "manual", "hidden": True,
         "text": "Hold the pens until the forest goes quiet."},
        {"id": "turtle", "side": "station", "primary": False, "kind": "destroy", "hidden": True, "tag": "turtle",
         "text": "Kill the island that walked, at the creek's mouth."},
        # part 3
        {"id": "fall", "side": "station", "primary": True, "kind": "countdown", "hidden": True, "clock": "canoes",
         "text": "The station cannot be held. Save who you can and get to the jetty. Benedito's canoes leave in {clock:canoes}."},
        {"id": "out", "side": "station", "primary": True, "kind": "manual", "hidden": True,
         "text": "Dr. Lindqvist and Valadares must be at the jetty when the canoes leave."},
        {"id": "people", "side": "station", "primary": False, "kind": "manual", "hidden": True,
         "text": "Get the people into the canoes: {saved} saved of {people}."},
        {"id": "research", "side": "station", "primary": False, "kind": "manual", "hidden": True,
         "text": "Reach the burning specimen house with Dr. Lindqvist."},
        {"id": "pieter", "side": "station", "primary": False, "kind": "protect", "hidden": True, "tag": "pieter", "text": "Pieter must live."},
        {"id": "gun", "side": "station", "primary": False, "kind": "protect", "hidden": True, "tag": "gun", "text": "Keep the fort's gun."},
        # versus: the pack's player
        {"id": "p_kill", "side": "pack", "primary": True, "kind": "manual", "text": "Kill Dr. Lindqvist or Valadares before the canoes leave."},
    ],
    "triggers": [
        # ================================================================ PART 1: SPECIMEN ONE
        {"id": "start", "when": {"time": 0}, "do": [
            {"cage": {"tag": "linnea", "on": True}}, {"spare": {"tag": "linnea", "on": True}},
            {"spare": {"tag": "benedito", "on": True}}, {"cage": {"tag": "benedito", "on": True}}]},
        {"id": "intro", "when": {"time": 1}, "do": [{"say": ["l_1", "p_1", "tip_1"]}, {"ping": {"area": "pen"}}]},
        {"id": "intro_p", "when": {"time": 1}, "modes": ["versus"], "do": [{"say": ["f_intro"]}]},
        {"id": "call_1", "when": {"time": 70}, "do": [{"sound": {"name": "campaign/linnea_call", "area": "pen"}}, {"say": ["l_weigh"]}]},
        {"id": "pen_done", "when": {"done": "pen"}, "do": [{"say": ["l_pen", "p_pen"]}]},
        # Valadares comes down the river from the boundary survey
        {"id": "valadares", "when": {"time": 140}, "do": [
            {"spawn": {"team": "station", "kind": "dismounted", "as": "valadares", "count": 1, "at": "jetty", "tag": "valadares"}},
            {"spawn": {"team": "station", "kind": "musketeer", "count": 2, "at": "jetty", "tag": "commission"}},
            {"objective": {"id": "valadares", "set": "active"}}, {"objective": {"id": "meet", "set": "active"}},
            {"say": ["n_canoe", "tip_meet"]}, {"ping": {"area": "jetty"}}]},
        {"id": "meet_done", "when": {"done": "meet"}, "do": [{"say": ["v_1", "l_v1", "v_2"]}]},
        # the tracks: Pieter at the creek
        {"id": "tracks", "when": {"any": [{"all": [{"fired": "meet_done"}, {"done": "pen"}]}, {"time": 420}]}, "delay": 6, "do": [
            {"say": ["p_tracks"]}, {"objective": {"id": "tracks", "set": "active"}}, {"ping": {"area": "ford"}}]},
        {"id": "tracks_found", "when": {"any": [{"done": "tracks"}, {"all": [{"fired": "tracks"}, {"time": 560}]}]}, "do": [
            {"objective": {"id": "tracks", "set": "done"}},
            {"reveal": {"area": "ford", "side": "station", "secs": 30}}, {"reveal": {"area": "mouth", "side": "station", "secs": 30}},
            {"say": ["p_tracks2", "v_tracks", "l_tracks"]}]},
        # dusk: she CALLS, something answers, the hunters come for the goats
        {"id": "goats_come", "when": {"fired": "tracks_found"}, "delay": 14, "do": [
            {"light": {"to": "jungle_dusk", "secs": 30}},
            {"sound": {"name": "campaign/linnea_call", "area": "pen"}}, {"ping": {"area": "pen"}},
            {"say": ["n_call", "l_call"]}]},
        {"id": "goats_attack", "when": {"fired": "goats_come"}, "delay": 5, "do": [
            {"sound": {"name": "campaign/forest_answer", "area": "trail_c"}},
            {"spawn": {"team": "pack", "kind": "raptor", "count": 2, "at": "jar_c", "tag": "goat_raptors", "order": {"do": "attack", "to": "goats"}}},
            {"objective": {"id": "goats", "set": "active"}}, {"ping": {"area": "goats"}}, {"say": ["v_goats"]}]},
        {"id": "goats_done", "when": {"done": "goats"}, "do": [{"say": ["l_kin"]}]},
        # THE FIRST CHOICE: tell Lieutenant Teles
        {"id": "teles_choice", "when": {"any": [{"fired": "goats_done"}, {"all": [{"fired": "goats_attack"}, {"time": 900}]}]}, "delay": 4, "do": [
            {"objective": {"id": "goats", "set": "done"}},
            {"say": ["v_tell", "l_quiet"]},
            {"choice": {"id": "teles", "side": "station", "default": "quiet", "time": 60,
                        "title": "Something in the forest answers her. Send to the fort?",
                        "options": [
                            {"id": "told", "label": "TELL THE LIEUTENANT",
                             "about": "Valadares' way. The village crosses to the fort before dark and the garrison holds the causeway, its gun at the station's landing. The Crown will know what the station keeps.",
                             "do": [{"say": ["v_told"]}, {"flag": {"teles": "told"}}]},
                            {"id": "quiet", "label": "KEEP IT QUIET",
                             "about": "Lindqvist's way. The station stands alone at nightfall, the village must be brought in under attack, and Teles comes late. The Crown does not learn what the station keeps.",
                             "do": [{"say": ["l_one_night"]}, {"flag": {"teles": "quiet"}}]}]}}]},
        # ================================================================ PART 2: THE EVE OF SAINT JOHN
        {"id": "eve", "when": {"any": [{"flag": {"teles": "told"}}, {"flag": {"teles": "quiet"}}]}, "delay": 4, "do": [
            {"light": {"to": "jungle_night", "secs": 50}}, {"weather": "rain"},
            {"objective": {"id": "meet", "set": "hidden"}}, {"objective": {"id": "tracks", "set": "hidden"}},
            # first LEARN the lure, then set it (the owner, 2026-11-17 10:22)
            {"say": ["n_eve", "l_lure1", "l_lure2", "l_lure3", "v_lure", "l_stallion", "tip_lure"]},
            {"name": {"tag": "pieter", "name": "Pieter (the jars)"}}, {"give": {"team": "station", "powder": 250}},
            {"objective": {"id": "lure", "set": "active"}},
            {"ping": {"area": "jar_w"}}, {"ping": {"area": "jar_c"}}, {"ping": {"area": "jar_e"}},
            {"reveal": {"area": "jar_w", "side": "station", "secs": 20}}, {"reveal": {"area": "jar_c", "side": "station", "secs": 20}},
            {"reveal": {"area": "jar_e", "side": "station", "secs": 20}},
            {"clock": {"name": "p2_end", "secs": 480}}, {"clock": {"name": "p2_cap", "secs": 660}}]},
        jar("w", "jar_w"), jar("c", "jar_c"), jar("e", "jar_e"),
        {"id": "lure_set", "when": {"counter": {"name": "jars", "at_least": 3}}, "do": [
            {"objective": {"id": "lure", "set": "done"}}, {"name": {"tag": "pieter", "name": "Pieter"}}, {"say": ["p_set", "l_set"]}]},
        # the village: told, it crossed to the fort at dusk; quiet, it must be brought in under attack
        {"id": "eve_told", "when": {"all": [{"fired": "eve"}] + TOLD}, "do": [
            {"say": ["t_told"]}, {"objective": {"id": "hold", "set": "active"}},
            {"order": {"tag": "folk", "do": "move", "to": "fort"}}, {"order": {"tag": "joaquim", "do": "move", "to": "fort"}},
            {"order": {"tag": "garrison_a", "do": "attack", "to": "causeway_w"}}, {"order": {"tag": "garrison_b", "do": "attack", "to": "causeway_e"}},
            {"spawn": {"team": "garrison", "kind": "cannon", "count": 1, "at": "gun_spot", "tag": "gun"}},
            {"objective": {"id": "gun", "set": "active"}}]},
        {"id": "eve_quiet", "when": {"all": [{"fired": "eve"}] + QUIET}, "do": [
            {"objective": {"id": "village", "set": "active"}}, {"ping": {"area": "village"}},
            {"spawn": {"team": "garrison", "kind": "cannon", "count": 1, "at": [118, 66], "tag": "gun"}}]},
        {"id": "gun_pin", "when": {"any": [{"fired": "eve_told"}, {"fired": "eve_quiet"}]}, "do": [{"pin": {"tag": "gun", "on": True}}]},
        {"id": "bonfire_raid", "when": {"all": [{"fired": "eve"}] + QUIET}, "delay": 50, "do": [
            {"say": ["j_raid"]}, {"sound": {"name": "campaign/forest_answer", "area": "village"}},
            {"spawn": {"team": "pack", "kind": "raptor", "count": 4, "at": "causeway_w", "tag": "raiders", "order": {"do": "attack", "to": "bonfires"}}},
            {"ping": {"area": "bonfires"}}]},
        {"id": "folk_go", "when": {"all": [{"fired": "eve"}] + QUIET + [{"count": {"team": "station", "area": "village", "at_least": 2}}]}, "do": [
            {"say": ["j_come"]}, {"order": {"tag": "folk", "do": "move", "to": "yard"}}, {"order": {"tag": "joaquim", "do": "move", "to": "yard"}}]},
        {"id": "folk_count", "when": {"fired": "folk_go"}, "every": 2, "do": [
            {"counter": {"name": "folk_in", "count": {"tag": "folk", "area": "yard"}}}]},
        {"id": "village_in", "when": {"all": [{"fired": "folk_go"}, {"count": {"tag": "folk", "area": "village", "below": 1}},
                                              {"count": {"tag": "folk", "area": "yard", "at_least": 1}}]}, "do": [
            {"objective": {"id": "village", "set": "done"}}, {"say": ["j_in"]}]},
        {"id": "village_lost", "when": {"all": [{"fired": "eve"}, {"not": {"fired": "turn"}}] + QUIET + [{"dead": "folk"}]}, "do": [{"objective": {"id": "village", "set": "failed"}}]},
        {"id": "teles_late", "when": {"all": [{"fired": "eve"}] + QUIET}, "delay": 170, "do": [
            {"say": ["t_late"]}, {"order": {"tag": "garrison_a", "do": "attack", "to": "causeway_e"}}]},
        # the waves: the lure works on the first two, then they walk past the jars to her pen
        *wave("wave_c", "trail_c", "jar_c", "eve", 150, 60, 3),
        *wave("wave_w", "trail_nw", "jar_w", "eve", 150, 110, 3),
        *wave("wave_e", "trail_ne", "jar_e", "eve", 150, 160, 3, spitters=1),
        {"id": "walked_past", "when": {"all": [{"counter": {"name": "waves", "at_least": 3}}, {"counter": {"name": "jars", "at_least": 1}}]}, "do": [
            {"say": ["p_past", "v_past"]}]},
        # THE ISLAND THAT WALKED
        {"id": "turtle_comes", "when": {"fired": "eve"}, "delay": 220, "do": [
            {"spawn": {"team": "pack", "kind": "mound_turtle", "count": 1, "at": "igapo_e", "tag": "turtle"}},
            {"order": {"tag": "turtle", "do": "root", "to": "mouth"}},
            {"objective": {"id": "turtle", "set": "active"}}, {"ping": {"area": "mouth"}}, {"reveal": {"area": "mouth", "side": "station", "secs": 40}},
            {"say": ["p_island", "v_island"]}]},
        {"id": "turtle_spit", "when": {"all": [{"rooted": {"tag": "turtle"}}, {"not": {"fired": "turn"}}, {"count": {"team": "pack", "below": CAP}}]}, "every": 55, "do": [
            {"spawn": {"team": "pack", "kind": "spitter", "count": 2, "at": "mouth", "tag": "spit", "order": {"do": "attack", "to": "pen"}}}]},
        {"id": "turtle_dead", "when": {"dead": "turtle"}, "do": [{"say": ["v_turtle"]}]},
        {"id": "turtle_early", "when": {"all": [{"dead": "turtle"}, {"not": {"fired": "turn"}}]}, "do": [{"flag": {"turtle": "early"}}]},
        # the forest goes quiet: the part's time up, the turtle dead and the village settled (or the cap)
        {"id": "quiet_falls", "when": {"any": [
            {"all": [{"clock_out": "p2_end"}, {"any": [{"dead": "turtle"}, {"clock_out": "p2_cap"}]},
                     {"any": [{"fired": "eve_told"}, {"done": "village"}, {"failed": "village"}, {"clock_out": "p2_cap"}]}]},
            {"clock_out": "p2_cap"}]}, "do": [
            {"objective": {"id": "hold", "set": "done"}}, {"say": ["n_quiet", "l_quiet2"]}, {"clock": {"name": "p3", "secs": 10}}]},
        # ================================================================ PART 3: THE TYRANT
        {"id": "turn", "when": {"clock_out": "p3"}, "do": [
            {"light": {"to": "fire_night", "secs": 20}},
            {"sound": {"name": "campaign/sire_roar"}},
            {"spawn": {"team": "pack", "kind": "tyrannosaur", "count": 1, "at": "jar_c", "tag": "sire"}},
            {"spawn": {"team": "pack", "kind": "raptor", "count": 4, "at": "jar_c", "tag": "sire_pack"}},
            {"spawn": {"team": "pack", "kind": "spitter", "count": 1, "at": "mouth", "tag": "sire_pack"}},
            {"floor": {"tag": "sire", "share": 0.33}}, {"spare": {"tag": "specimen_house", "on": True}},
            # (he walks through the station to her pen as if it were reeds: he bites nobody on the way)
            {"carry": {"tag": "sire", "on": True, "pace": 1.0}},
            {"order": {"tag": "sire", "do": "move", "to": "nest"}}, {"order": {"tag": "sire_pack", "do": "attack", "to": "pen"}},
            {"say": ["n_ground", "p_sire", "l_lost", "v_lost", "tip_3"]},
            {"objective": {"id": "pen", "set": "hidden"}}, {"objective": {"id": "goats", "set": "hidden"}},
            {"objective": {"id": "lure", "set": "hidden"}}, {"objective": {"id": "village", "set": "hidden"}},
            {"objective": {"id": "hold", "set": "hidden"}}, {"objective": {"id": "turtle", "set": "hidden"}},
            {"objective": {"id": "fall", "set": "active"}}, {"objective": {"id": "out", "set": "active"}},
            {"objective": {"id": "people", "set": "active"}}, {"objective": {"id": "pieter", "set": "active"}},
            {"clock": {"name": "canoes", "secs": 520}}, {"clock": {"name": "take", "secs": 330}},
            {"counter": {"name": "people", "count": {"team": "station"}}}, {"counter": {"name": "people", "add": -2}},
            {"counter": {"name": "people", "count": {"tag": "folk"}, "plus": True}},
            {"ping": {"area": "jetty"}}, {"reveal": {"area": "jetty", "side": "station", "secs": 900}},
            {"reveal": {"area": "nest_wide", "side": "station", "secs": 30}}]},
        # Benedito's canoes come round from the rapids: the jetty takes people from then on (until then, hold them)
        {"id": "canoes_here", "when": {"fired": "turn"}, "delay": 100, "do": [{"say": ["b_here"]}, {"ping": {"area": "jetty"}}]},
        {"id": "turn_folk_told", "when": {"all": [{"fired": "turn"}] + TOLD}, "do": [
            {"order": {"tag": "folk", "do": "move", "to": "fort_steps"}}, {"order": {"tag": "joaquim", "do": "move", "to": "fort_steps"}},
            {"say": ["t_steps"]}]},
        {"id": "turn_folk_quiet", "when": {"all": [{"fired": "turn"}] + QUIET}, "do": [
            {"order": {"tag": "folk", "do": "move", "to": "jetty"}}, {"order": {"tag": "joaquim", "do": "move", "to": "jetty"}}]},
        {"id": "turtle_late", "when": {"all": [{"fired": "turn"}, {"not": {"flag": {"turtle": "early"}}}]}, "do": [{"flag": {"turtle": "late"}}]},
        {"id": "turtle_bonus", "when": {"all": [{"fired": "turn"}, {"flag": {"turtle": "early"}}]}, "do": [
            {"clock": {"name": "canoes", "add": 90}}, {"say": ["b_bonus"]}]},
        {"id": "gun_obj", "when": {"all": [{"fired": "turn"}] + TOLD}, "do": [{"objective": {"id": "gun", "set": "active"}}]},
        {"id": "gun_off", "when": {"all": [{"fired": "turn"}] + QUIET}, "do": [{"objective": {"id": "gun", "set": "hidden"}}]},
        # the Sire walks through the palisade and lies down beside her pen
        {"id": "sire_at_pen", "when": {"count": {"tag": "sire", "area": "nest_wide", "at_least": 1}}, "do": [
            {"order": {"tag": "sire", "do": "root", "to": "nest"}}]},
        {"id": "sire_rooted", "when": {"rooted": {"tag": "sire"}}, "do": [{"carry": {"tag": "sire", "on": False}},
            {"say": ["l_groom", "tip_rooted"]}, {"sound": {"name": "campaign/linnea_call", "area": "pen"}}]},
        {"id": "eggs", "when": {"all": [{"rooted": {"tag": "sire"}}, {"not": {"fired": "taken"}}]}, "every": 25, "times": 5, "delay": 8, "do": [
            {"spawn": {"team": "pen", "kind": "brood_egg", "count": 1, "at": "pen_in", "tag": "eggs"}},
            {"cage": {"tag": "eggs", "on": True}}, {"spare": {"tag": "eggs", "on": True}}]},
        {"id": "eggs_seen", "when": {"fired": "eggs"}, "do": [{"say": ["p_eggs", "l_young"]}]},
        {"id": "sire_call", "when": {"all": [{"rooted": {"tag": "sire"}}, {"not": {"fired": "taken"}}, {"count": {"team": "pack", "below": CAP3}}]}, "every": 30, "delay": 12, "do": [
            {"sound": {"name": "campaign/linnea_call", "area": "pen"}},
            {"spawn": {"team": "pack", "kind": "raptor", "count": 2, "at": "jar_c", "tag": "called", "order": {"do": "attack", "to": "pen"}}},
            {"spawn": {"team": "pack", "kind": "raptor", "count": 1, "at": "jar_w", "tag": "called", "order": {"do": "attack", "to": "pen"}}}]},
        # hurt to a third he gets up: the pack closes round him, then he lies down again
        {"id": "sire_up", "when": {"all": [{"rooted": {"tag": "sire"}}, {"hp": {"tag": "sire", "below": 0.36}}, {"not": {"fired": "taken"}}]}, "every": 3, "do": [
            {"order": {"tag": "sire", "do": "uproot"}}, {"counter": {"name": "drove", "add": 1}},
            {"spawn": {"team": "pack", "kind": "raptor", "count": 2, "at": "jar_c", "tag": "guard", "order": {"do": "attack", "to": "nest"}}},
            {"say": ["n_nothing"]}, {"sound": {"name": "campaign/sire_roar"}}]},
        {"id": "sire_down", "when": {"all": [{"fired": "sire_up"}, {"not": {"rooted": {"tag": "sire"}}}, {"not": {"fired": "taken"}}]}, "every": 30, "delay": 28, "do": [
            {"heal": {"tag": "sire", "share": 0.7}}, {"order": {"tag": "sire", "do": "root", "to": "nest"}}]},
        # THE FIRE: Spitter acid finds the lamp oil; the station house falls last
        {"id": "fire_1", "when": {"fired": "turn"}, "delay": 40, "do": [{"burn": {"tag": "garden", "secs": 220}}, {"say": ["p_fire"]}]},
        {"id": "fire_2", "when": {"fired": "turn"}, "delay": 150, "do": [{"burn": {"tag": "specimen_house", "secs": 360}}]},
        {"id": "fire_3", "when": {"fired": "turn"}, "delay": 160, "do": [{"burn": {"tag": "station_house", "secs": 420}}]},
        # HE TAKES HER (5:30 into Part 3: about two thirds of the countdown; never after the specimen house has burned)
        {"id": "taken", "when": {"clock_out": "take"}, "do": [
            {"hurt": {"tag": "pen", "amount": 99999}}, {"floor": {"tag": "sire", "share": 0.0}},
            {"cage": {"tag": "linnea", "on": False}},
            {"convert": {"tag": "linnea", "to": "pack", "warn": 1, "as": "taken", "sound": "campaign/linnea_call"}},
            {"say": ["n_taken", "l_taken", "v_taken"]}, {"sound": {"name": "campaign/sire_roar"}},
            {"objective": {"id": "research", "set": "active"}}, {"ping": {"area": "spec"}}]},
        {"id": "taken_go", "when": {"fired": "taken"}, "delay": 2, "do": [
            {"order": {"tag": "sire", "do": "uproot"}}, {"spare": {"tag": "sire", "on": True}}]},
        {"id": "taken_walk", "when": {"fired": "taken_go"}, "delay": 2, "every": 6, "do": [
            {"order": {"tag": "sire", "do": "move", "to": "out_n"}}, {"order": {"tag": "taken", "do": "move", "to": "out_n"}}]},
        # the pack goes with them, but for a few stragglers at the burning station
        {"id": "pack_goes", "when": {"fired": "taken"}, "delay": 6, "do": [{"say": ["p_pack_goes"]}]},
        {"id": "pack_follows", "when": {"fired": "taken"}, "delay": 6, "every": 8, "do": [
            {"order": {"team": "pack", "do": "move", "to": "out_n"}}]},
        # THE SECOND CHOICE, in the burning specimen house
        {"id": "research_choice", "when": {"all": [{"fired": "taken"}, {"count": {"tag": "lindqvist", "area": "spec", "at_least": 1}},
                                                   {"not": {"dead": "specimen_house"}}, {"not": {"dead": "eggs"}}, {"not": {"fired": "fire_took"}}]}, "do": [
            {"objective": {"id": "research", "set": "done"}}, {"spare": {"tag": "specimen_house", "on": False}},
            {"say": ["n_room", "v_burn", "l_save"]},
            {"choice": {"id": "clutch", "side": "station", "default": "saved", "time": 35,
                        "title": "The roof is alight. Her eggs in the straw, his notes on the bench.",
                        "options": [
                            {"id": "burned", "label": "BURN THE EGGS",
                             "about": "Valadares' way. The lamp goes into the straw and the notes with it. Lindqvist walks to the jetty free and armed, with nothing but his word.",
                             "do": [{"say": ["v_lamp"]}, {"spare": {"tag": "eggs", "on": False}}, {"hurt": {"tag": "eggs", "amount": 99999}},
                                    {"burn": {"tag": "specimen_house", "secs": 20}}]},
                            {"id": "saved", "label": "SAVE THE RESEARCH",
                             "about": "Lindqvist's way. He carries a crate with the eggs and the notes himself: slower, and he cannot shoot until he is aboard.",
                             "do": [{"say": ["l_crate"]}, {"spare": {"tag": "eggs", "on": False}}, {"hurt": {"tag": "eggs", "amount": 99999}},
                                    {"carry": {"tag": "lindqvist", "on": True, "pace": 0.6}},
                                    {"name": {"tag": "lindqvist", "name": "Dr. Lindqvist (the crate)"}}]}]}}]},
        {"id": "fire_took", "when": {"all": [{"fired": "taken"}, {"not": {"fired": "research_choice"}},
                                             {"any": [{"dead": "specimen_house"}, {"clock_left": {"name": "canoes", "below": 40}}]}]}, "do": [
            {"objective": {"id": "research", "set": "failed"}}, {"spare": {"tag": "eggs", "on": False}}, {"hurt": {"tag": "eggs", "amount": 99999}},
            {"flag": {"clutch": "burned", "fire": "yes"}}, {"say": ["p_fire_took"]}]},
        # the last minutes
        {"id": "hunt", "when": {"all": [{"fired": "turn"}, {"not": {"fired": "taken"}}]}, "every": 6, "do": [
            {"order": {"team": "pack", "do": "hunt", "prey": "folk", "within": 10, "spare": "jetty"}}]},
        {"id": "pieter_lost", "when": {"all": [{"fired": "turn"}, {"dead": "pieter"}]}, "do": [{"say": ["l_pieter"]}]},
        {"id": "warn_2", "when": {"clock_left": {"name": "canoes", "below": 120}}, "do": [{"say": ["b_warn"]}, {"ping": {"area": "jetty"}}]},
        {"id": "hurt_l", "when": {"all": [{"fired": "turn"}, {"hp": {"tag": "lindqvist", "below": 0.5}}]}, "every": 45, "times": 2, "do": [
            {"say": ["v_hurt"]}, {"ping": {"area": "jetty"}}]},
        # THE CANOES LEAVE: Lindqvist and Valadares aboard, or left behind (the only real defeat besides their deaths)
        {"id": "leave", "when": {"all": [{"clock_out": "canoes"}, {"count": {"tag": "lindqvist", "area": "jetty", "at_least": 1}},
                                         {"count": {"tag": "valadares", "area": "jetty", "at_least": 1}}]}, "do": [
            {"objective": {"id": "lindqvist", "set": "done"}}, {"objective": {"id": "valadares", "set": "done"}},
            {"say": ["n_leave", "b_leave"]}, {"light": {"to": "grey_dawn", "secs": 8}}, {"weather": ""},
            {"tally": {"flag": "saved", "counter": "saved", "bands": [[0, "few"], [10, "some"], [20, "many"]]}},
            {"flag": {"pieter": "alive"}}]},
        {"id": "leave_pieter", "when": {"all": [{"fired": "leave"}, {"dead": "pieter"}]}, "do": [{"flag": {"pieter": "lost"}}]},
        {"id": "leave_gun", "when": {"all": [{"fired": "leave"}] + TOLD}, "do": [{"flag": {"gun": "kept"}}]},
        {"id": "leave_gun_lost", "when": {"all": [{"fired": "leave_gun"}, {"dead": "gun"}]}, "do": [{"flag": {"gun": "lost"}}]},
        {"id": "leave_people", "when": {"all": [{"fired": "leave"}, {"counter": {"name": "saved", "at_least": 1}}]}, "do": [{"objective": {"id": "people", "set": "done"}}]},
        {"id": "leave_clutch", "when": {"all": [{"fired": "leave"}, {"not": {"flag": {"clutch": "saved"}}}, {"not": {"flag": {"clutch": "burned"}}}]}, "do": [
            {"flag": {"clutch": "burned", "fire": "yes"}}]},
        {"id": "the_end", "when": {"fired": "leave"}, "delay": 12, "do": [{"objective": {"id": "out", "set": "done"}}, {"win": "station"}]},
        {"id": "left_behind", "when": {"all": [{"clock_out": "canoes"}, {"not": {"fired": "leave"}}]}, "delay": 0.5, "do": [
            {"say": ["n_behind"]}, {"objective": {"id": "out", "set": "failed"}}]},
        # versus: the pack's player wins by a hero's death
        {"id": "p_won", "when": {"any": [{"dead": "lindqvist"}, {"dead": "valadares"}]}, "do": [{"objective": {"id": "p_kill", "set": "done"}}]},
    ],
    "speakers": {
        "king": {"name": "The King", "side": "station", "portrait": "res://campaign/hub/rome_king_face.png"},
        "lindqvist": {"name": "Dr. Lindqvist", "side": "station", "portrait": "res://campaign/hub/station_lindqvist_face.png"},
        "valadares": {"name": "Valadares", "side": "station"},
        "pieter": {"name": "Pieter", "side": "station"},
        "teles": {"name": "Lieutenant Teles", "side": "station"},
        "joaquim": {"name": "Frei Joaquim", "side": "station"},
        "benedito": {"name": "Benedito", "side": "station"},
        "narrator": {"name": "The Rio Negro", "side": "station"},
        "forest": {"name": "The Forest", "side": "pack"},
    },
    "lines": {
        # the opening: the King in Rome, the naturalist brought before him in chains; then Lindqvist tells it
        "k_open1": {"who": "king", "text": "Two letters came that year. The first came from the Amazon, from the Crown's mapmaker."},
        "k_open2": {"who": "king", "text": "The naturalist they brought me in chains. He knows these creatures better than any man alive. Let him tell it."},
        "l_open1": {"who": "lindqvist", "text": "I was the happiest man in the world that summer, Majesty. Write that down, whoever writes."},
        "l_open2": {"who": "lindqvist", "text": "The Academy's station at the rapids of São Gabriel. The river high, the forest standing in the water."},
        "l_open3": {"who": "lindqvist", "text": "She came from an egg a trader found after the flood. In forty days she had trebled."},
        "l_open4": {"who": "lindqvist", "text": "I meant to give the Crown a beast of war no army had. I meant to give her a mate first."},
        # part 1
        "l_1": {"who": "lindqvist", "text": "She has outgrown her crate. A proper pen today, beside the specimen house."},
        "p_1": {"who": "pieter", "text": "The stakes are cut and marked, Doctor."},
        "tip_1": {"who": "pieter", "to": "station", "text": "Select the hands and right-click a marked stake. They go on to the next by themselves."},
        "l_weigh": {"who": "lindqvist", "text": "Hear her? She calls when she is hungry. Eleven pounds heavier than Monday."},
        "l_pen": {"who": "lindqvist", "text": "There. Room to grow."},
        "p_pen": {"who": "pieter", "text": "She will need a bigger one by August."},
        "n_canoe": {"who": "narrator", "text": "A canoe comes down from the boundary survey: the Crown's mapmaker, Duarte Valadares."},
        "tip_meet": {"who": "pieter", "to": "station", "text": "Walk Dr. Lindqvist down to the jetty to greet him."},
        "v_1": {"who": "valadares", "text": "Doctor. They say at the fort you keep a lizard the size of a dog."},
        "l_v1": {"who": "lindqvist", "text": "Not a lizard. Something no man has named. The Crown will have a cavalry that needs no hay."},
        "v_2": {"who": "valadares", "text": "You mean to sell this to the army, Doctor? Then why do you whisper when you speak of her?"},
        "p_tracks": {"who": "pieter", "text": "Doctor, come and see. At the creek. These are not hers."},
        "p_tracks2": {"who": "pieter", "text": "Three toes, deep in the mud. Too many to count."},
        "v_tracks": {"who": "valadares", "text": "These came down from the north. From where your trader found the egg."},
        "l_tracks": {"who": "lindqvist", "text": "Then she has a family. Splendid."},
        "n_call": {"who": "narrator", "text": "At dusk she called. Something in the forest answered."},
        "l_call": {"who": "lindqvist", "text": "Listen. Listen to that."},
        "v_goats": {"who": "valadares", "text": "At the goats! Guns, quickly!", "still": "eyes"},
        "l_kin": {"who": "lindqvist", "text": "She has kin. Do you see what that means? Not one beast. A breed."},
        "v_tell": {"who": "valadares", "text": "Send to Teles, Doctor. Tell him what we saw at the creek, and bring the village in before dark."},
        "l_quiet": {"who": "lindqvist", "text": "If Teles sees those tracks he will shoot everything in this forest, beginning with her. One night."},
        "v_told": {"who": "valadares", "text": "My man is already on the path to the fort."},
        "l_one_night": {"who": "lindqvist", "text": "One night, Valadares. The Crown will have its beasts tame or not at all."},
        # part 2
        "n_eve": {"who": "narrator", "text": "The Eve of Saint John. Rain on the river, and the bonfires lit at Nazaré."},
        "l_lure1": {"who": "lindqvist", "text": "Now my lure. I made it from the shell of her egg and her own musk."},
        "l_lure2": {"who": "lindqvist", "text": "Any of her kind that smells it follows the scent to the jar, and stands there sniffing like a dog."},
        "l_lure3": {"who": "lindqvist", "text": "Three jars at the forest's edge. Whatever comes will come to them, and we will be waiting with the guns."},
        "v_lure": {"who": "valadares", "text": "You are calling something you have never seen, Doctor, to a house full of people."},
        "l_stallion": {"who": "lindqvist", "text": "I am calling a stallion for my mare. By morning the Academy will have a pair."},
        "tip_lure": {"who": "pieter", "to": "station", "text": "Walk Pieter to the three marks at the forest's edge. Set the guns where the jars are."},
        "p_set": {"who": "pieter", "text": "All three jars are open, Doctor. I can smell it from here."},
        "l_set": {"who": "lindqvist", "text": "Good. Now we wait by the jars."},
        "t_told": {"who": "teles", "text": "The village is at the fort. My men hold the causeway, and the gun is at your landing. One night, Doctor."},
        "j_raid": {"who": "joaquim", "text": "Doctor! They are at the bonfires! In the name of God, send us your guns!"},
        "j_come": {"who": "joaquim", "text": "Come, all of you. Up to the station, quickly."},
        "j_in": {"who": "joaquim", "text": "We are all inside the palisade. God keep us till morning."},
        "t_late": {"who": "teles", "text": "Shots at the station! Half of you with me, along the causeway."},
        "p_past": {"who": "pieter", "text": "Doctor, they walked past the jars."},
        "v_past": {"who": "valadares", "text": "They are not after your scent. They are going to her."},
        "p_island": {"who": "pieter", "text": "The island at the creek's mouth. It is walking."},
        "v_island": {"who": "valadares", "text": "Kill it before it settles. The ground goes to mud round it."},
        "v_turtle": {"who": "valadares", "text": "The island is dead. The mud is drying already."},
        "n_quiet": {"who": "narrator", "text": "Near midnight the forest went quiet."},
        "l_quiet2": {"who": "lindqvist", "text": "You see? They have had enough. By morning she will have her mate."},
        # part 3
        "n_ground": {"who": "narrator", "text": "Then the ground shook."},
        "p_sire": {"who": "pieter", "text": "Down the creek trail. Doctor, it is as big as the house."},
        "l_lost": {"who": "lindqvist", "text": "He has come for her. My lure brought him."},
        "v_lost": {"who": "valadares", "text": "We cannot hold this place. Benedito is bringing his canoes round from the rapids. Get the people to the jetty, and hold them there."},
        "tip_3": {"who": "valadares", "to": "station", "text": "Walk everyone you can into the canoes at the jetty. Dr. Lindqvist and I must be there when they leave."},
        "b_bonus": {"who": "benedito", "text": "The island is dead, so the mud is gone from the landing. I can wait a little longer."},
        "t_steps": {"who": "teles", "text": "The village goes down the fort's steps to the boats. Hold them off us!"},
        "l_groom": {"who": "lindqvist", "text": "He did not want to eat her. He lay down beside her like a groom."},
        "tip_rooted": {"who": "valadares", "to": "station", "text": "Lying down he cannot bite. Hurt him now and he gets up, and the calling stops a while."},
        "p_eggs": {"who": "pieter", "text": "Doctor, there are eggs in her straw."},
        "l_young": {"who": "lindqvist", "text": "She is too young. She is far too young."},
        "n_nothing": {"who": "narrator", "text": "He rose roaring, and the pack closed round him. Nothing they had would kill him."},
        "p_fire": {"who": "pieter", "text": "Their spit is in the lamp oil! The garden is burning!"},
        "n_taken": {"who": "narrator", "text": "He broke the pen like kindling, and she followed him."},
        "l_taken": {"who": "lindqvist", "text": "No. No! She is mine! Shoot him, not her!"},
        "v_taken": {"who": "valadares", "text": "Let her go, Doctor. Your notes, your people. Now."},
        "n_room": {"who": "narrator", "text": "The specimen house was alight. The eggs lay in the trampled straw."},
        "v_burn": {"who": "valadares", "text": "Burn them, Doctor. Whatever she was, do not carry her children down this river."},
        "l_save": {"who": "lindqvist", "text": "Ten years of work. The Crown's beasts are in that straw. I will not leave them to the fire."},
        "v_lamp": {"who": "valadares", "text": "Give me the lamp."},
        "l_crate": {"who": "lindqvist", "text": "The crate, Pieter. The notes on top. I carry it myself."},
        "b_here": {"who": "benedito", "text": "The canoes are at the jetty! In, all of you, quickly!"},
        "p_pack_goes": {"who": "pieter", "text": "They are going with him. All of them, up the creek. Doctor, the eggs!"},
        "p_fire_took": {"who": "pieter", "text": "The roof is down on the straw. The eggs are gone, Doctor."},
        "l_pieter": {"who": "lindqvist", "text": "Pieter. Pieter went back for the book."},
        "b_warn": {"who": "benedito", "text": "Two minutes, Doctor! Then I push off, with you or without you."},
        "v_hurt": {"who": "valadares", "text": "Doctor, you are hurt. Keep back from them. To the jetty."},
        "n_leave": {"who": "narrator", "text": "The last canoe pushed off in the grey before dawn."},
        "b_leave": {"who": "benedito", "text": "Paddle! Do not look back."},
        "n_behind": {"who": "narrator", "text": "The canoes left without them."},
        "f_intro": {"who": "forest", "to": "pack", "text": "She calls. Answer her. Take her home, and leave nobody to follow."},
        # the ending
        "l_end1": {"who": "lindqvist", "text": "We went down the river at first light with the station burning behind us. She was gone. He took her from me as a thief takes a horse."},
        "l_end_saved": {"who": "lindqvist", "text": "I had the research. I told the Academy I had saved my notes. That was the first lie."},
        "l_end_burned": {"who": "lindqvist", "text": "Valadares threw the lamp. I had nothing left but my word, and no one wanted it."},
        "l_end_fire": {"who": "lindqvist", "text": "The fire took her eggs before I reached them. I had nothing left but my word, and no one wanted it."},
        "l_end_pieter": {"who": "lindqvist", "text": "Pieter sat in the canoe with the specimen book on his knees and did not speak all day."},
        "l_end_nopieter": {"who": "lindqvist", "text": "Pieter went back for the specimen book. I have it still. He does not."},
        "l_end_north": {"who": "lindqvist", "text": "Valadares turned his canoe round at the first island. He went north after her, up the creek, to the mountain in the cloud."},
        "l_end2": {"who": "lindqvist", "text": "I meant to give the Crown its beasts, Majesty. I still think I was right."},
        "k_end1": {"who": "king", "text": "He wrote that his lure called them. It did not. She called them, and they came for her."},
        "k_end2": {"who": "king", "text": "She was never stolen. She went home."},
        "k_end_saved": {"who": "king", "text": "And what he carried out of the fire was not research. It was her children."},
    },
    "stills": {
        "letter": {"image": STILL % "b01_01", "caption": "Rome, the present. The King with the mapmaker's letter."},
        "station": {"image": STILL % "b01_02", "caption": "The Academy's station at the rapids of São Gabriel, June 2767."},
        "specimen": {"image": STILL % "b01_03", "caption": "Specimen One."},
        "eyes": {"image": STILL % "b01_04", "caption": "Eyes at the forest's edge."},
        "tyrant": {"image": STILL % "b01_05", "caption": "The Tyrant at the pen."},
        "burns": {"image": STILL % "b01_06", "caption": "The station burns."},
        "north": {"image": STILL % "b01_07", "caption": "Valadares goes north."},
        "teller": {"image": STILL % "b01_08", "caption": "Rome, the present. The naturalist in chains before the King."},
    },
    "opening": [
        {"still": "letter", "lines": ["k_open1", "k_open2"]},
        {"still": "teller", "lines": ["l_open1"]},
        {"still": "station", "lines": ["l_open2"]},
        {"still": "specimen", "lines": ["l_open3", "l_open4"]},
    ],
    "ending": {"station": [
        {"still": "burns", "lines": ["l_end1",
                                     {"id": "l_end_saved", "if": {"flag": {"clutch": "saved"}}},
                                     {"id": "l_end_burned", "if": {"all": [{"flag": {"clutch": "burned"}}, {"not": {"flag": {"fire": "yes"}}}]}},
                                     {"id": "l_end_fire", "if": {"flag": {"fire": "yes"}}},
                                     {"id": "l_end_pieter", "if": {"flag": {"pieter": "alive"}}},
                                     {"id": "l_end_nopieter", "if": {"flag": {"pieter": "lost"}}}]},
        {"still": "north", "lines": ["l_end_north"]},
        {"still": "teller", "lines": ["l_end2"]},
        {"still": "letter", "lines": ["k_end1", "k_end2", {"id": "k_end_saved", "if": {"flag": {"clutch": "saved"}}}]},
    ]},
    "briefing": {
        "station": {"still": "station", "text": [
            "The Rio Negro, June 2767, the Eve of Saint John. Dr. Viktor Lindqvist keeps the Academy's station at the rapids of São Gabriel.",
            "In a crate in his specimen house he keeps the only one of her kind any man has seen. He calls her Linnea.",
            "Dr. Lindqvist must live."]},
        "pack": {"still": "eyes", "text": [
            "The Rio Negro, June 2767. One of your own is kept in a crate at the men's station by the river.",
            "Answer her call. Take her back to the forest, and kill the naturalist or the mapmaker before the canoes leave."]},
    },
    "debrief": {
        "station": {"still": "burns", "banner": "THE STATION IS LOST", "title": "Specimen One",
                    "text": "Dr. Lindqvist and Valadares got away in Benedito's canoes. The station burned, and Linnea went into the forest with the Tyrant Sire.",
                    "text_if": [
                        {"if": {"flag": {"saved": "many"}}, "text": "Most of the people got into the canoes: {saved} of {people}."},
                        {"if": {"flag": {"saved": "some"}}, "text": "Some of the people got into the canoes: {saved} of {people}."},
                        {"if": {"flag": {"saved": "few"}}, "text": "Few of the people got into the canoes: {saved} of {people}."},
                        {"if": {"flag": {"teles": "told"}}, "text": "Lieutenant Teles was told. The Crown knows what the station kept."},
                        {"if": {"flag": {"teles": "quiet"}}, "text": "Lieutenant Teles was not told. The Crown does not know what the station kept."},
                        {"if": {"flag": {"clutch": "saved"}}, "text": "Lindqvist carried a crate out of the fire: her eggs, and his notes on top."},
                        {"if": {"all": [{"flag": {"clutch": "burned"}}, {"not": {"flag": {"fire": "yes"}}}]}, "text": "The eggs were burned in the specimen house, and the notes with them."},
                        {"if": {"flag": {"fire": "yes"}}, "text": "The fire took the eggs before Lindqvist reached them."},
                        {"if": {"flag": {"pieter": "lost"}}, "text": "Pieter did not come out."},
                        {"if": {"flag": {"turtle": "early"}}, "text": "The island that walked was killed before midnight."},
                        {"if": {"flag": {"gun": "kept"}}, "text": "The fort's gun was saved."},
                        {"if": {"flag": {"gun": "lost"}}, "text": "The fort's gun was lost."}]},
        "pack": {"still": "tyrant", "title": "The station's people are dead",
                 "text": "The naturalist or the mapmaker never reached the canoes. Try again: they must live to tell it."},
    },
    "next": {"station": "", "pack": ""},
}

out = os.path.join(os.path.dirname(__file__), "..", "..", "campaign", "missions", "b01_specimen.json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines")
