#!/usr/bin/env python3
"""Writes campaign/missions/a05_specimens.json: Act 1's "The Specimens" (the Naturalist line after a03_plateau, the dry
season 2769; the plan: docs/campaign_act1_plan.md "a05_specimens" and its OWNER ANSWERS of 2026-11-17 22:04; what was
built: docs/campaign_a05_build.md).
  python3 tools/campaign/make_a05_mission.py
EVERY LINE IS A PLACEHOLDER for the owner to rewrite. After changing a text: add its Portuguese and Spanish to
tools/i18n/campaign/a05_specimens.txt and run python3 tools/i18n_build.py (tools/test_campaign_a05.gd checks every text
has both).

Lindqvist's second chance. The Academy pays for an expedition to the cloud mountain to take a breeding stock: a young
Sire for the eggs he saved at the station (b01 `clutch` saved), or eggs to begin again (`clutch` burned). Lindqvist
tells it as a prisoner before the King (2795), to him his finest expedition; the King frames and corrects it.
Played by default as THE EXPEDITION (YELLOW): Lindqvist (320 health), Pieter if he lived, the hired guns and porters;
the CAGE CARTS are the convoy (scripted, on the expedition's side); Benedito waits with the canoes at the river.
  PART 1, THE TAKING (night, the nest ASLEEP): net the sleeping young in the ferns (the men stand by one 4 s: a cart
    comes and cages it); Lindqvist takes the eggs from the swamp's edge in the hollow (8 s: then he carries them, slow
    and unarmed). Come within 6 tiles of the sleeping hunters (or hurt one) and the nest wakes: Part 2 at once. The nest
    wakes at dawn anyway (a countdown): a player who takes nothing by then has lost.
  PART 2, THE TRAIL: the carts roll down by a ROUTE (the short way if a03's map was drawn, the long way through the
    forest if it was withheld); the player escorts them, the porters mend them; the pack comes for the cages every 1:50
    (Raptors, then the grown ones: Tyrant and Venom Challengers). A cart broken frees its creature, which turns on them.
  PART 3, THE LANDING: the first cart at the river: the canoes leave in 3:00; the carts that reach the quay are loaded
    (an exit counting the CAGES, as many as the canoes hold: Nazaré's paddlers by b01's `saved`); the Tyrant Sire comes
    down for the last cart. Lindqvist goes last.
  NO CHOICE: the counts carry: `cages` few / some / all (`cages_n`), `eggs` taken / left, `pieter` alive / lost.
  Defeats: Lindqvist killed; nothing caged by dawn; every cage broken; the canoes gone without him.
THE MIRROR (solo side pick, or versus): THE CREATURES (GREEN), the nest asleep in its hollow (the Mother, a Rootmaw and
  grubs awake and working; the hunters, the grown ones and every new one asleep until the strangers come near or the
  carts leave). The roster ladder's B3 (GROW to stage 2, MATURE) is theirs: grow the Mother while the nest sleeps and
  mature the young. From Part 2 hunt the convoy: free half the cages, or kill the doctor, before the canoes leave. The
  expedition is then scripted (the eggs, the young in turn, down with the carts). No creature speaks.
THE FLAGS READ (a missing flag is the canon): b01 `clutch` (saved: three carts, a young Sire among the young, more men;
  burned: two carts, fewer guns and porters), `saved` (the paddlers: room for 2 / 3 / 4 cages), `pieter` (alive: he
  keeps the specimen book), `eggs` (taken: the pack carried the station's clutch north: more young in the nest, a line);
  a03 `map` (drawn: the short way, two more guns; withheld: the long way through the forest), `party` (a line).
The act's ONE CRATE HINT: two Lisbon crates on the quay "for the mines in the south", stamped with a gear (c01's).
"""
import json
import os
import sys

STILL = "res://campaign/stills/%s.jpg"
HERE = os.path.dirname(__file__)
ROOT = os.path.join(HERE, "..", "..")

EXP = {"playing": "expedition"}
CRE = {"playing": "creatures"}
NO_EXP = {"not": {"playing": "expedition"}}     # the expedition is scripted (the solo player leads the creatures)
NO_CRE = {"not": {"playing": "creatures"}}      # the creatures are scripted (the expedition's story)


def past(mission, flag, value):
    return {"past": {mission + "." + flag: value}}


def notpast(mission, flag, value):
    return {"not": past(mission, flag, value)}


SAVED_CLUTCH = notpast("b01_specimen", "clutch", "burned")    # (saved, or not known: b01's canon "saved")
BURNED = past("b01_specimen", "clutch", "burned")
FEW = past("b01_specimen", "saved", "few")
MANY = past("b01_specimen", "saved", "many")
SOME = {"all": [{"not": FEW}, {"not": MANY}]}                 # (some, or not known)
PIETER = past("b01_specimen", "pieter", "alive")
TAKEN = past("b01_specimen", "eggs", "taken")
DRAWN = notpast("a03_plateau", "map", "withheld")              # (drawn, or not known: a03's canon "drawn")
WITHHELD = past("a03_plateau", "map", "withheld")

AWAKE_KINDS = ["brood_mother", "rootmaw", "mound_turtle", "dilophosaurus", "pterodactyl", "tyrannosaur", "grub",
               "brood_egg", "food_pile"]
DAWN = 600                  # Part 1: the nest wakes at dawn (10:00)
CANOES = 180                # Part 3: the canoes leave 3:00 after the first cart reaches the river
RAIDS = [35, 110, 185, 260, 335, 410]     # Part 2: the pack comes for the cages every 1:15 (seconds after the carts set off)
SHORT = ["s1", "s2", "s3", "s4", "s5", "s6", "quay"]
LONG = ["top_w", "top_ww", "long_top", "l1", "l2", "l3", "l4", "l5", "l6", "l7", "quay"]
YOUNG = [("w", "raptor", None), ("m", "tyrannosaur", "young_sire"), ("e", "spitter", None)]
CART_FREE = {"caged": "caged", "freed": "freed", "freed_tag": "freed"}

# where the pack waits along each way (short / long): a raid's spawn spot
RAID_AT = {"short": ["rs_a", "rs_b", "rs_c", "rs_d", "rs_d", "rs_d"], "long": ["rl_a", "rl_b", "rl_c", "rl_d", "rl_d", "rl_d"]}
RAID_KIT = [
    [("raptor", 8)],
    [("raptor", 6), ("tyrant_challenger", 2)],
    [("raptor", 8), ("tyrant_challenger", 2), ("spitter", 2)],
    [("raptor", 6), ("tyrant_challenger", 3), ("venom_challenger", 1)],
    [("raptor", 8), ("tyrant_challenger", 3), ("spitter", 2)],
    [("raptor", 8), ("tyrant_challenger", 4), ("venom_challenger", 2)],
]
BURNED_RAIDS = 0.6          # the raids with b01's clutch burned (a smaller expedition)
CART_PACE = 0.4             # the carts' pace (an ox's: 15 px a second)


def raid(i):
    t0 = RAIDS[i]
    do = []
    for way, cond in (("short", DRAWN), ("long", WITHHELD)):
        for kind, n in RAID_KIT[i]:
            # (a fresh start, b01's clutch burned: a smaller expedition and two carts, so smaller raids: 0.6 of each)
            do.append({"spawn": {"team": "pack", "kind": kind, "count": n, "at": RAID_AT[way][i], "tag": "raiders", "if": {"all": [cond, SAVED_CLUTCH]}}})
            do.append({"spawn": {"team": "pack", "kind": kind, "count": max(1, round(n * BURNED_RAIDS)), "at": RAID_AT[way][i], "tag": "raiders",
                                 "if": {"all": [cond, BURNED]}}})
    do += [{"order": {"tag": "raiders", "do": "hunt", "prey": "carts", "within": 45}},
           {"sound": {"name": "campaign/forest_answer", "vol": -6}}]
    if i == 0:
        do.append({"say": ["l_raid1"]})
    if i == 1:
        do.append({"say": ["l_grown"]})
    return {"id": "raid%d" % (i + 1), "when": {"all": [{"fired": "part2_go"}, NO_CRE, {"not": {"fired": "part3"}}]},
            "delay": t0, "do": do}


def young_triggers(w):
    """Netting the young in bed `w` (the men stand by it 4 s): its cart comes and cages it."""
    return [
        {"id": "net_" + w, "when": {"all": [{"stay": {"side": "expedition", "area": "young_" + w, "secs": 4}},
                                            {"count": {"tag": "young_" + w, "at_least": 1}}, {"not": {"fired": "part2"}}]}, "do": [
            {"say": ["l_net_" + w]}, {"order": {"tag": "cart_" + w, "do": "move", "to": "young_" + w}}]},
        {"id": "load_" + w, "when": {"all": [{"fired": "net_" + w}, {"near": {"tag": "cart_" + w, "to": "young_" + w, "within": 2}}]}, "do": [
            {"cart": dict({"tag": "young_" + w, "cart": "cart_" + w}, **CART_FREE)},
            {"order": {"tag": "cart_" + w, "do": "move", "to": "cartpark"}}, {"say": ["l_caged"]}]},
    ]


M = {
    "id": "a05_specimens",
    "title": "The Specimens",
    "summary": "The foot of the cloud mountain, the dry season 2769. Lindqvist comes back for the creatures with the Academy's money: cage the young while the nest sleeps and bring the carts down to the river.",
    "map": "campaign:plateau_descent",
    "voice": "a05",
    "light": "jungle_night",
    "floor": [0.7, 0.74, 0.68],
    "mist": {"sight": 0.75, "weather": False},
    "expansion_spots": False,
    "manual_end": True,
    "mend_allies": True,
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {"clocks": 0.9, "spawns": 1.2}},
    "modes": ["solo", "versus"],
    "solo_sides": ["expedition", "creatures"],
    "sides": [
        {"id": "expedition", "name": "The Academy's Expedition", "about": "Dr. Lindqvist with the Academy's hired guns, porters and cage carts, and Benedito's canoes at the river."},
        {"id": "creatures", "name": "The Creatures", "about": "The nest on the cloud mountain: the Mother in her hollow, her hunters and her grown young."},
    ],
    "teams": [
        {"id": "expedition", "side": "expedition", "faction": "crown", "colour": 3, "start": "none", "camera": "camp", "powder": 60,
         "gold": 150, "roster": {"deny": ["town_hall", "cottage", "wall", "gate", "barracks", "armoury", "foundry", "farm", "powder_mill", "horse_breeder", "church"]},
         "control": {"solo": "p1", "versus": "p1", "foe": "script"}},
        {"id": "convoy", "side": "expedition", "faction": "crown", "colour": 3, "start": "none", "camera": "camp",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "creatures", "side": "creatures", "faction": "brood", "colour": 2, "start": "standard", "hall": [64, 16],
         "hall_tag": "mother", "camera": "hollow", "gold": 500, "powder": 40,
         "control": {"solo": "script", "versus": "p2"}},
        {"id": "pack", "side": "creatures", "faction": "brood", "colour": 2, "start": "none", "camera": "hollow",
         "control": {"solo": "script", "versus": "script"}},
    ],
    "areas": {
        # the top: the camp, the ferns where the young sleep, the hollow
        "camp": [55, 41, 18, 8], "cartpark": [58, 44, 12, 4],
        "young_w": [30, 36, 5, 4], "young_m": [62, 36, 5, 4], "young_e": [94, 36, 5, 4],
        "hollow": [44, 8, 42, 23], "nest_core": [56, 11, 18, 10], "egg_bed": [45, 19, 4, 5], "hollow_w": [47, 27, 6, 4],
        # the short way (the commission's path) and the long way (Benedito's memory)
        "s1": [61, 55, 6, 4], "s2": [56, 72, 6, 5], "s3": [62, 86, 6, 5], "s4": [66, 100, 6, 5], "s5": [60, 112, 6, 5], "s6": [62, 124, 6, 5],
        "top_w": [40, 46, 6, 4], "top_ww": [22, 46, 6, 4], "long_top": [12, 46, 6, 4],
        "l1": [11, 56, 6, 4], "l2": [9, 74, 6, 5], "l3": [20, 88, 6, 5], "l4": [28, 98, 6, 5], "l5": [18, 110, 6, 5],
        "l6": [30, 120, 6, 5], "l7": [44, 128, 6, 5],
        # where the pack waits along each way
        "rs_a": [84, 66, 5, 5], "rs_b": [36, 80, 5, 5], "rs_c": [90, 100, 5, 5], "rs_d": [38, 116, 5, 5],
        "rl_a": [30, 62, 5, 5], "rl_b": [30, 84, 5, 5], "rl_c": [46, 104, 5, 5], "rl_d": [6, 120, 5, 5],
        "rim_n": [100, 20, 5, 4],
        # the river
        "landing_near": [50, 128, 28, 9], "quay": [56, 137, 18, 5], "crates": [68, 138, 6, 3], "sire_lair": [100, 128, 5, 5],
    },
    "counters": {"young0": {"start": 0}, "caged": {"start": 0}, "cages0": {"start": 0}, "freed": {"start": 0},
                 "cages": {"start": 0}, "room": {"start": 3}},
    "exits": [
        # Part 3: the carts that reach the quay are loaded, cage and all, as many as the canoes hold
        {"area": "quay", "tag": "carts", "cargo": True, "max": "room", "counter": "cages", "after": "part3"},
    ],
    "units": [
        # ---- the expedition's camp on the plateau's south edge
        {"team": "expedition", "kind": "musketeer", "as": "lindqvist", "count": 1, "at": [64, 44], "tag": "lindqvist"},
        {"team": "expedition", "kind": "labourer", "as": "pieter", "count": 1, "at": [66, 45], "tag": "pieter", "if": PIETER},
        {"team": "expedition", "kind": "musketeer", "as": "hired_gun", "count": 6, "at": "camp", "tag": "guns", "if": SAVED_CLUTCH},
        {"team": "expedition", "kind": "musketeer", "as": "hired_gun", "count": 4, "at": "camp", "tag": "guns", "if": BURNED},
        {"team": "expedition", "kind": "musketeer", "as": "hired_gun", "count": 2, "at": "camp", "tag": "guns", "if": DRAWN},
        # (campaign-fixes-1121: THE MIRROR HARDER: led by a person the creatures won in under four minutes; the scripted
        # expedition hires more guns, by the campaign's difficulty)
        {"team": "expedition", "kind": "musketeer", "as": "hired_gun", "count": 4, "at": "camp", "tag": "guns", "fixed": True, "if": {"all": [CRE, {"difficulty": "normal"}]}},
        {"team": "expedition", "kind": "musketeer", "as": "hired_gun", "count": 8, "at": "camp", "tag": "guns", "fixed": True, "if": {"all": [CRE, {"difficulty": "hard"}]}},
        {"team": "expedition", "kind": "labourer", "as": "porter", "count": 4, "at": "camp", "tag": "porters", "if": SAVED_CLUTCH, "fixed": True},
        {"team": "expedition", "kind": "labourer", "as": "porter", "count": 2, "at": "camp", "tag": "porters", "if": BURNED, "fixed": True},
        # ---- the convoy: a cage cart for each bed of young (the middle one, the young Sire's, only with a breeding stock)
        {"team": "convoy", "kind": "powder_wagon", "as": "cage_cart", "count": 1, "at": [60, 46], "tags": ["carts", "cart_w"], "fixed": True},
        {"team": "convoy", "kind": "powder_wagon", "as": "cage_cart", "count": 1, "at": [64, 47], "tags": ["carts", "cart_m"], "fixed": True, "if": SAVED_CLUTCH},
        {"team": "convoy", "kind": "powder_wagon", "as": "cage_cart", "count": 1, "at": [68, 46], "tags": ["carts", "cart_e"], "fixed": True},
        # ---- Benedito with the canoes at the river
        {"team": "expedition", "kind": "labourer", "as": "benedito", "count": 1, "at": [64, 139], "tag": "benedito"},
        # ---- the nest (its Mother, a Rootmaw and grubs are the standard start in the hollow): its hunters and grown ones asleep
        {"team": "creatures", "kind": "raptor", "count": 6, "at": "nest_core", "tag": "nest_guard"},
        {"team": "creatures", "kind": "raptor", "count": 4, "at": "nest_core", "tag": "nest_guard", "name": "Young", "if": TAKEN},
        {"team": "creatures", "kind": "spitter", "count": 2, "at": "nest_core", "tag": "nest_guard"},
        {"team": "creatures", "kind": "tyrant_challenger", "count": 2, "at": "nest_core", "tag": "nest_guard"},
        {"team": "creatures", "kind": "venom_challenger", "count": 1, "at": "nest_core", "tag": "nest_guard"},
        {"team": "creatures", "kind": "mound_turtle", "count": 1, "at": [80, 22], "tag": "turtles"},
        # the clutch at the swamp's edge (eggs, kept as eggs)
        {"team": "creatures", "kind": "brood_egg", "count": 5, "at": "egg_bed", "tag": "egg_bed", "fixed": True},
        # the young asleep in the ferns, apart from the nest
        {"team": "creatures", "kind": "raptor", "count": 1, "at": "young_w", "tags": ["young", "young_w"], "name": "Young", "fixed": True},
        {"team": "creatures", "kind": "tyrannosaur", "as": "young_sire", "count": 1, "at": "young_m", "tags": ["young", "young_m"], "fixed": True, "if": SAVED_CLUTCH},
        {"team": "creatures", "kind": "spitter", "count": 1, "at": "young_e", "tags": ["young", "young_e"], "name": "Young", "fixed": True},
    ],
    "buildings": [],
    "objectives": [
        # ---- the expedition
        {"id": "lindqvist", "side": "expedition", "primary": True, "kind": "protect", "tag": "lindqvist", "text": "Dr. Lindqvist must live."},
        {"id": "dawn", "side": "expedition", "primary": True, "kind": "countdown", "clock": "dawn",
         "text": "Dawn in {clock:dawn}: the nest wakes with the sun."},
        {"id": "take", "side": "expedition", "primary": True, "kind": "manual",
         "text": "THE TAKING: stand by each sleeping young one to net it; its cart comes for it ({caged} of {young0} caged)."},
        {"id": "eggs", "side": "expedition", "primary": False, "kind": "manual",
         "text": "The eggs: Lindqvist stands 8 seconds at the swamp's edge in the hollow, then carries them."},
        {"id": "softly", "side": "expedition", "primary": False, "kind": "manual",
         "text": "Walk softly: keep away from the sleeping nest."},
        {"id": "trail", "side": "expedition", "primary": True, "kind": "manual", "hidden": True,
         "text": "THE TRAIL: guard the cage carts down to the river ({freed} broken). Porters mend a hurt cart."},
        {"id": "landing", "side": "expedition", "primary": True, "kind": "manual", "hidden": True,
         "text": "THE LANDING: bring the carts onto the quay ({cages} loaded, room for {room}). Lindqvist goes last."},
        {"id": "canoes", "side": "expedition", "primary": True, "kind": "countdown", "clock": "canoes", "hidden": True,
         "text": "The canoes leave in {clock:canoes}."},
        # ---- the creatures (solo side pick or versus)
        {"id": "c_mother", "side": "creatures", "primary": True, "kind": "protect", "tag": "mother", "hidden": True, "text": "The Mother must live."},
        {"id": "c_sleep", "side": "creatures", "primary": True, "kind": "manual", "hidden": True,
         "text": "THE NEST SLEEPS: strangers are in the ferns. Your hunters sleep until they come close. Root the Mother and GROW her; MATURE your young ones."},
        {"id": "c_free", "side": "creatures", "primary": True, "kind": "manual", "hidden": True,
         "text": "FREE THE YOUNG: break the cage carts ({freed} of {cages0} freed: half will do), or kill the doctor, before the canoes leave."},
    ],
    "triggers": [
        # ================================================================ THE START (both sides)
        {"id": "start", "when": {"time": 0}, "do": [
            {"cage": {"tag": "egg_bed", "on": True}}, {"spare": {"tag": "egg_bed", "on": True}},
            {"spare": {"tag": "young", "on": True}},
            {"pin": {"tag": "benedito", "on": True}}, {"spare": {"tag": "benedito", "on": True}},
            {"name": {"tag": "mother", "name": "The Mother"}},
            {"counter": {"name": "young0", "count": {"tag": "young"}}},
            {"clock": {"name": "dawn", "secs": DAWN}}]},
        # the canoes' room: Nazaré's paddlers (b01's saved: few / some / many)
        {"id": "room_few", "when": {"all": [{"time": 0}, FEW]}, "do": [{"counter": {"name": "room", "set": 2}}]},
        {"id": "room_many", "when": {"all": [{"time": 0}, MANY]}, "do": [{"counter": {"name": "room", "set": 4}}]},
        # the nest sleeps: the expedition's game (a scripted nest)...
        {"id": "asleep", "when": {"all": [{"time": 0.25}, NO_CRE]}, "do": [
            {"sleep": {"tag": "nest_guard", "name": "nest", "within": 6, "by": "expedition"}},
            {"sleep": {"tag": "young", "name": "young", "within": 0, "hurt": False}},
            {"spare": {"tag": "mother", "on": True}}]},
        # ...or a person's nest: every hunter of it, and every new one while it sleeps (the workers keep working)
        {"id": "asleep_p", "when": {"all": [{"time": 0.25}, CRE]}, "do": [
            {"sleep": {"tag": "young", "name": "young", "within": 0, "hurt": False}},
            {"sleep": {"team": "creatures", "name": "nest", "within": 6, "by": "expedition", "keep": True, "except_kinds": AWAKE_KINDS, "except_tags": ["young"]}},
            {"objective": {"id": "c_mother", "set": "active"}}, {"objective": {"id": "c_sleep", "set": "active"}}]},
        # ---- the expedition's start (a person leads it)
        {"id": "intro", "when": {"all": [{"time": 1}, EXP]}, "do": [
            {"say": ["l_1", "l_2", "tip_1"]}, {"ping": {"area": "young_w"}}, {"ping": {"area": "young_e"}},
            {"ping": {"area": "egg_bed"}}]},
        {"id": "intro_sire", "when": {"all": [{"time": 2}, EXP, SAVED_CLUTCH]}, "delay": 10, "do": [
            {"say": ["l_sire"]}, {"ping": {"area": "young_m"}}]},
        {"id": "intro_fresh", "when": {"all": [{"time": 2}, EXP, BURNED]}, "delay": 10, "do": [{"say": ["l_fresh"]}]},
        {"id": "way_short", "when": {"all": [{"time": 3}, EXP, DRAWN]}, "delay": 18, "do": [{"say": ["l_short"]}]},
        {"id": "way_long", "when": {"all": [{"time": 3}, EXP, WITHHELD]}, "delay": 18, "do": [{"say": ["l_long"]}]},
        {"id": "pieter_book", "when": {"all": [{"time": 3}, EXP, PIETER]}, "delay": 26, "do": [{"say": ["p_book"]}]},
        {"id": "pieter_lost", "when": {"all": [{"time": 3}, EXP, {"not": PIETER}]}, "delay": 26, "do": [{"say": ["l_pieter"]}]},
        {"id": "taken_eggs", "when": {"all": [{"time": 3}, EXP, TAKEN]}, "delay": 34, "do": [{"say": ["l_taken"]}]},
        {"id": "porter_tip", "when": {"all": [{"time": 60}, EXP]}, "do": [{"say": ["tip_porters"]}]},
        # ---- the creatures' start (a person leads them: no creature speaks)
        {"id": "intro_c", "when": {"all": [{"time": 1}, CRE]}, "do": [
            {"ping": {"area": "camp"}}, {"sound": {"name": "campaign/linnea_call", "area": "hollow", "vol": -8}}]},
        # ================================================================ PART 1: THE TAKING
        *young_triggers("w"), *young_triggers("m"), *young_triggers("e"),
        {"id": "pieter_count", "when": {"all": [{"fired": "load_w"}, PIETER, EXP]}, "delay": 4, "do": [{"say": ["p_count"]}]},
        # the eggs: Lindqvist at the swamp's edge, 8 s; then he carries them (slow, unarmed: b01's crate)
        {"id": "eggs_taken", "when": {"all": [{"stay": {"tag": "lindqvist", "area": "egg_bed", "secs": 8}}, {"not": {"fired": "part2"}}]}, "do": [
            {"remove": {"tag": "egg_bed"}}, {"carry": {"tag": "lindqvist", "on": True, "pace": 0.75}},
            {"name": {"tag": "lindqvist", "name": "Dr. Lindqvist (the eggs)"}}, {"flag": {"eggs": "taken"}},
            {"objective": {"id": "eggs", "set": "done"}}, {"say": ["l_eggs"]}]},
        # ================================================================ PART 2: THE TRAIL
        # every young one caged, or the nest woken, or dawn: the carts set off
        {"id": "part2", "when": {"any": [{"fired": "caged_all"}, {"awake": "nest"}, {"clock_out": "dawn"}]}, "delay": 2, "do": [
            {"wake": {"name": "young"}}, {"spare": {"tag": "young", "on": False}},
            {"counter": {"name": "cages0", "set": 0}}, {"counter": {"name": "cages0", "add_counter": "caged"}},
            {"clock": {"name": "dawn", "stop": True}}, {"objective": {"id": "dawn", "set": "hidden"}},
            {"mist": {"sight": 1.0, "weather": False}},
            {"light": {"to": "grey_dawn", "secs": 20}}]},
        {"id": "caged_all", "when": {"all": [{"fired": "start"}, {"time": 1}, {"not": {"fired": "part2"}}, {"any": [
            {"all": [SAVED_CLUTCH, {"counter": {"name": "caged", "at_least": 3}}]},
            {"all": [BURNED, {"counter": {"name": "caged", "at_least": 2}}]}]}]}, "do": [{"say": ["l_all"]}]},
        {"id": "woke_early", "when": {"all": [{"awake": "nest"}, {"not": {"fired": "caged_all"}}, {"not": {"fired": "part2"}}]}, "do": [
            {"say": ["l_woke"]}, {"objective": {"id": "softly", "set": "failed"}}]},
        # the nest wakes with the carts' going (the expedition's game); a person's nest a little later, when the sun reaches
        # the hollow and the carts are off the top (unless the strangers woke it first): the convoy's head start
        {"id": "nest_wakes", "when": {"all": [{"fired": "part2"}, NO_CRE]}, "do": [{"wake": {"name": "nest"}}]},
        {"id": "nest_wakes_c", "when": {"all": [{"fired": "part2"}, CRE]}, "delay": 45, "do": [
            {"wake": {"name": "nest"}}, {"sound": {"name": "campaign/linnea_call", "area": "hollow", "vol": -4}}]},
        {"id": "softly_kept", "when": {"all": [{"fired": "part2"}, {"not": {"fired": "woke_early"}}]}, "do": [
            {"objective": {"id": "softly", "set": "done"}}]},
        {"id": "eggs_missed", "when": {"all": [{"fired": "part2"}, {"not": {"fired": "eggs_taken"}}]}, "do": [
            {"objective": {"id": "eggs", "set": "failed"}}, {"flag": {"eggs": "left"}}]},
        # nothing caged when the carts must go: the expedition has failed
        {"id": "empty", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "caged", "below": 1}}]}, "do": [
            {"say": ["l_empty"]}, {"objective": {"id": "take", "set": "failed"}}]},
        {"id": "part2_go", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "caged", "at_least": 1}}]}, "delay": 1, "do": [
            {"objective": {"id": "take", "set": "done"}}, {"objective": {"id": "trail", "set": "active"}},
            {"remove": {"tag": "carts", "empty": True}}, {"carry": {"tag": "carts", "on": True, "pace": CART_PACE}},
            {"light": {"to": "jungle_day", "secs": 60}}]},
        {"id": "go_short", "when": {"all": [{"fired": "part2_go"}, DRAWN]}, "do": [
            {"order": {"tag": "carts", "do": "route", "route": SHORT, "name": "trail"}}, {"flag": {"way": "short"}},
            {"ping": {"area": "s1"}}]},
        {"id": "go_long", "when": {"all": [{"fired": "part2_go"}, WITHHELD]}, "do": [
            {"order": {"tag": "carts", "do": "route", "route": LONG, "name": "trail"}}, {"flag": {"way": "long"}},
            {"ping": {"area": "long_top"}}]},
        {"id": "trail_lines", "when": {"all": [{"fired": "part2_go"}, EXP]}, "delay": 2, "do": [{"say": ["l_trail", "tip_trail"]}]},
        {"id": "trail_c", "when": {"all": [{"fired": "part2_go"}, CRE]}, "do": [
            {"objective": {"id": "c_sleep", "set": "done"}}, {"objective": {"id": "c_free", "set": "active"}},
            {"ping": {"area": "cartpark"}}, {"sound": {"name": "campaign/linnea_call", "area": "hollow", "vol": -4}}]},
        # the pack comes for the cages (the expedition's game)
        *[raid(i) for i in range(len(RAIDS))],
        {"id": "raid_hunt", "when": {"all": [{"fired": "raid1"}, NO_CRE, {"not": {"fired": "the_end"}}]}, "every": 3, "do": [
            {"order": {"tag": "raiders", "do": "hunt", "prey": "carts", "within": 45}}]},
        {"id": "raid_left", "when": {"all": [{"fired": "raid1"}, NO_CRE, {"cargo": {"tag": "carts", "below": 1}}, {"not": {"fired": "the_end"}}]}, "every": 3, "do": [
            {"order": {"tag": "raiders", "do": "hunt", "prey_team": "expedition", "within": 40}}]},
        # the freed turn on the men who caged them (the expedition's game); the nest's guards keep near home
        {"id": "freed_hunt", "when": {"all": [{"counter": {"name": "freed", "at_least": 1}}, NO_CRE, {"not": {"fired": "the_end"}}]}, "every": 3, "do": [
            {"order": {"tag": "freed", "do": "hunt", "prey_team": "expedition", "within": 20}}]},
        {"id": "guard_hunt", "when": {"all": [{"fired": "part2"}, NO_CRE, {"not": {"fired": "the_end"}}]}, "every": 4, "do": [
            {"order": {"tag": "nest_guard", "do": "hunt", "prey_team": "expedition", "within": 14}}]},
        {"id": "first_freed", "when": {"all": [{"counter": {"name": "freed", "at_least": 1}}, EXP]}, "do": [{"say": ["l_freed"]}]},
        # every cage broken before the river: the expedition has failed
        {"id": "all_lost", "when": {"all": [{"fired": "part2_go"}, {"cargo": {"tag": "carts", "below": 1}}, {"counter": {"name": "cages", "below": 1}},
                                             {"not": {"fired": "the_end"}}]}, "delay": 1, "do": [
            {"say": ["l_lost"]}, {"objective": {"id": "trail", "set": "failed"}}]},
        # ================================================================ PART 3: THE LANDING
        {"id": "part3", "when": {"all": [{"fired": "part2_go"}, {"count": {"tag": "carts", "area": "landing_near", "at_least": 1}}]}, "do": [
            {"objective": {"id": "trail", "set": "done"}}, {"objective": {"id": "landing", "set": "active"}},
            {"objective": {"id": "canoes", "set": "active"}}, {"clock": {"name": "canoes", "secs": CANOES}},
            {"ping": {"area": "quay"}}, {"ping": {"area": "crates"}}]},
        {"id": "landing_lines", "when": {"all": [{"fired": "part3"}, EXP]}, "do": [{"say": ["b_1", "l_crates", "b_crates"]}]},
        {"id": "room_line", "when": {"all": [{"fired": "part3"}, EXP, FEW]}, "delay": 12, "do": [{"say": ["b_room_few"]}]},
        {"id": "room_line_many", "when": {"all": [{"fired": "part3"}, EXP, MANY]}, "delay": 12, "do": [{"say": ["b_room_many"]}]},
        # the Tyrant Sire comes down for the last cart (the creatures' own: in the mirror he is the player's)
        {"id": "sire", "when": {"fired": "part3"}, "delay": 20, "do": [
            {"spawn": {"team": "creatures", "kind": "tyrannosaur", "count": 1, "at": "sire_lair", "tag": "sire", "name": "The Tyrant Sire"}},
            {"sound": {"name": "campaign/sire_roar", "area": "sire_lair"}}, {"ping": {"area": "sire_lair"}}]},
        {"id": "sire_line", "when": {"all": [{"fired": "sire"}, EXP]}, "do": [{"say": ["n_roar", "l_sire_comes"]}]},
        {"id": "sire_hunt", "when": {"all": [{"fired": "sire"}, NO_CRE, {"not": {"fired": "the_end"}}]}, "every": 3, "do": [
            {"order": {"tag": "sire", "do": "hunt", "prey": "carts", "within": 60}}]},
        {"id": "sire_left", "when": {"all": [{"fired": "sire"}, NO_CRE, {"cargo": {"tag": "carts", "below": 1}}, {"not": {"fired": "the_end"}}]}, "every": 3, "do": [
            {"order": {"tag": "sire", "do": "hunt", "prey_team": "expedition", "within": 60}}]},
        {"id": "loaded_line", "when": {"all": [{"counter": {"name": "cages", "at_least": 1}}, EXP]}, "do": [{"say": ["b_load"]}]},
        {"id": "full", "when": {"all": [{"fired": "part3"}, {"counter": {"name": "cages", "at_least": 1}}, {"cargo": {"tag": "carts", "at_least": 1}},
                                         {"not": {"fired": "the_end"}}, {"count": {"tag": "carts", "area": "quay", "at_least": 1}}]}, "delay": 3, "do": [
            {"say": ["b_full"]}]},
        # the end: Lindqvist on the quay once every cage is loaded or lost, the canoes full, or their time come
        {"id": "the_end", "when": {"all": [{"fired": "part3"}, {"stay": {"tag": "lindqvist", "area": "quay", "secs": 2}},
                                            {"counter": {"name": "cages", "at_least": 1}},
                                            {"any": [{"cargo": {"tag": "carts", "below": 1}}, {"clock_out": "canoes"},
                                                     {"all": [{"counter": {"name": "cages", "at_least": 1}}, {"fired": "room_full"}]}]}]}, "do": [
            {"tally": {"flag": "cages", "counter": "cages", "of": "cages0", "bands": [[0, "few"], [0.5, "some"], [1, "all"]]}},
            {"say": ["b_push", "l_end"]}, {"objective": {"id": "landing", "set": "done"}},
            {"spare": {"tag": "lindqvist", "on": True}}, {"pin": {"tag": "lindqvist", "on": True}},
            {"light": {"to": "jungle_dusk", "secs": 8}}, {"flag": {"crates": "seen"}}]},
        {"id": "room_full", "when": {"all": [{"fired": "part3"}, {"counter": {"name": "cages", "at_least": 1}}, {"any": [
            {"all": [FEW, {"counter": {"name": "cages", "at_least": 2}}]},
            {"all": [SOME, {"counter": {"name": "cages", "at_least": 3}}]},
            {"all": [MANY, {"counter": {"name": "cages", "at_least": 4}}]}]}]}, "do": []},
        {"id": "pieter_alive", "when": {"all": [{"fired": "the_end"}, {"count": {"tag": "pieter", "at_least": 1}}]}, "do": [{"flag": {"pieter": "alive"}}]},
        {"id": "pieter_gone", "when": {"all": [{"fired": "the_end"}, {"count": {"tag": "pieter", "below": 1}}]}, "do": [{"flag": {"pieter": "lost"}}]},
        {"id": "won", "when": {"fired": "the_end"}, "delay": 5, "do": [{"win": "expedition"}]},
        {"id": "canoes_gone", "when": {"all": [{"clock_out": "canoes"}, {"not": {"fired": "the_end"}},
                                                {"not": {"count": {"tag": "lindqvist", "area": "quay", "at_least": 1}}}]}, "do": [
            {"say": ["b_gone"]}, {"objective": {"id": "landing", "set": "failed"}}]},
        {"id": "hurt_l", "when": {"all": [{"hp": {"tag": "lindqvist", "below": 0.5}}, EXP]}, "do": [{"say": ["l_hurt"]}]},
        # ---- the creatures' win: half the cages freed, or the doctor dead
        {"id": "c_count", "when": {"all": [{"fired": "part2_go"}, CRE, {"not": {"fired": "the_end"}}]}, "every": 1, "do": [
            {"tally": {"flag": "share", "counter": "freed", "of": "cages0", "bands": [[0, "under"], [0.5, "half"]]}}]},
        {"id": "c_freed", "when": {"all": [CRE, {"flag": {"share": "half"}}, {"not": {"fired": "the_end"}}]}, "do": [
            {"objective": {"id": "c_free", "set": "done"}}, {"flag": {"specimens": "freed", "cages": "none", "cages_n": 0}}, {"win": "creatures"}]},
        {"id": "c_killed", "when": {"all": [CRE, {"dead": "lindqvist"}]}, "do": [
            {"objective": {"id": "c_free", "set": "done"}}, {"flag": {"specimens": "freed", "cages": "none", "cages_n": 0}}, {"win": "creatures"}]},
        {"id": "c_escaped", "when": {"all": [CRE, {"fired": "the_end"}]}, "do": [{"objective": {"id": "c_free", "set": "failed"}}]},
        # ================================================================ THE SCRIPTED EXPEDITION (a person leads the creatures)
        {"id": "x_eggs", "when": {"all": [{"time": 3}, NO_EXP]}, "do": [
            {"order": {"tag": "lindqvist", "do": "route", "route": ["hollow_w", "egg_bed"], "name": "x1"}},
            {"order": {"tag": "guns", "do": "follow", "leader": "lindqvist", "within": 3}},
            {"order": {"tag": "porters", "do": "follow", "leader": "lindqvist", "within": 3}},
            {"order": {"tag": "pieter", "do": "follow", "leader": "lindqvist", "within": 2}}]},
        {"id": "x_w", "when": {"all": [{"fired": "eggs_taken"}, NO_EXP]}, "delay": 1, "do": [
            {"order": {"tag": "lindqvist", "do": "route", "route": ["hollow_w", "young_w"], "name": "x2"}}]},
        {"id": "x_m", "when": {"all": [{"fired": "load_w"}, NO_EXP, SAVED_CLUTCH, {"not": {"fired": "part2"}}]}, "delay": 1, "do": [
            {"order": {"tag": "lindqvist", "do": "route", "route": ["young_m"], "name": "x3"}}]},
        {"id": "x_e", "when": {"all": [NO_EXP, {"not": {"fired": "part2"}}, {"any": [{"all": [{"fired": "load_m"}, SAVED_CLUTCH]},
                                                                               {"all": [{"fired": "load_w"}, BURNED]}]}]}, "delay": 1, "do": [
            {"order": {"tag": "lindqvist", "do": "route", "route": ["young_e"], "name": "x4"}}]},
        {"id": "x_down", "when": {"all": [{"fired": "part2_go"}, NO_EXP]}, "delay": 2, "do": [
            {"order": {"tag": "lindqvist", "do": "follow", "leader": "carts", "within": 3}},
            {"order": {"tag": "guns", "do": "follow", "leader": "carts", "within": 4}},
            {"order": {"tag": "porters", "do": "follow", "leader": "carts", "within": 3}},
            {"order": {"tag": "pieter", "do": "follow", "leader": "lindqvist", "within": 2}}]},
        # (the scripted guns fight what comes at the doctor in the night too, then follow him on)
        {"id": "x_fight1", "when": {"all": [{"fired": "x_eggs"}, NO_EXP, {"not": {"fired": "part2_go"}}]}, "every": 2, "do": [
            {"order": {"tag": "guns", "do": "follow", "leader": "lindqvist", "within": 3}},
            {"order": {"tag": "guns", "do": "hunt", "prey_team": "creatures", "within": 5}}]},
        # (the scripted escort fights what comes at the carts)
        {"id": "x_fight", "when": {"all": [{"fired": "part2_go"}, NO_EXP, {"not": {"fired": "the_end"}}]}, "every": 2, "do": [
            {"order": {"tag": "guns", "do": "follow", "leader": "carts", "within": 4}},
            {"order": {"tag": "guns", "do": "hunt", "prey_team": "creatures", "within": 7}}]},
        {"id": "x_quay", "when": {"all": [{"fired": "part3"}, NO_EXP]}, "every": 4, "do": [
            {"order": {"tag": "lindqvist", "do": "move", "to": "quay"}}]},
    ],
    "speakers": {
        "king": {"name": "The King", "side": "expedition"},
        "lindqvist": {"name": "Dr. Lindqvist", "side": "expedition"},
        "pieter": {"name": "Pieter", "side": "expedition"},
        "benedito": {"name": "Benedito", "side": "expedition"},
        "narrator": {"name": "The Mountain", "side": "expedition"},
    },
    "lines": {
        # the opening: the King and his prisoner; Lindqvist goes on
        "k_open1": {"who": "king", "text": "The doctor came before me in chains, an old man. He asked to tell it himself."},
        "k_open2": {"who": "king", "text": "I let him. He tells it as his finest hour. I will say where it was not."},
        "l_open1": {"who": "lindqvist", "text": "Majesty. Two years after the station burned, the Academy gave me money again."},
        "l_open_saved": {"who": "lindqvist", "text": "The eggs I carried out of the fire had hatched. I needed a father for them."},
        "l_open_burned": {"who": "lindqvist", "text": "I had nothing left but my notes. I needed eggs, and young ones."},
        "l_open2": {"who": "lindqvist", "text": "In the dry season we went up the mountain, with guns, porters and carts."},
        "k_open_c": {"who": "king", "text": "No creature told me this. But the nest was theirs, and the young were theirs."},
        "k_open_c2": {"who": "king", "text": "That dry season men came with cages while the nest slept."},
        # part 1
        "l_1": {"who": "lindqvist", "to": "expedition", "text": "Quietly. The young sleep apart from the nest, in the ferns."},
        "l_2": {"who": "lindqvist", "to": "expedition", "text": "Stand by each one a moment and net it. The carts will come for them."},
        "tip_1": {"who": "lindqvist", "to": "expedition", "text": "The eggs lie at the swamp's edge in the hollow. I will fetch those myself."},
        "l_sire": {"who": "lindqvist", "to": "expedition", "text": "And the young Sire in the middle. A father for my line."},
        "l_fresh": {"who": "lindqvist", "to": "expedition", "text": "Two young and a clutch of eggs. Enough to begin again."},
        "l_short": {"who": "lindqvist", "to": "expedition", "text": "We have the mapmaker's road. The carts go straight down the commission's path."},
        "l_long": {"who": "lindqvist", "to": "expedition", "text": "No map. Benedito remembers an old way down on the west side. A long road through the forest."},
        "p_book": {"who": "pieter", "to": "expedition", "text": "I have the specimen book, Doctor. I will count every cage."},
        "l_pieter": {"who": "lindqvist", "to": "expedition", "text": "I keep the book myself now. Pieter used to."},
        "l_taken": {"who": "lindqvist", "to": "expedition", "text": "So many young. The pack carried my clutch up here after all."},
        "tip_porters": {"who": "lindqvist", "to": "expedition", "text": "The porters can mend a cart. Keep them close to the cages."},
        "l_net_w": {"who": "lindqvist", "to": "expedition", "text": "The net is on it. Bring the cart."},
        "l_net_m": {"who": "lindqvist", "to": "expedition", "text": "Gently. He weighs more than three men already. The cart!"},
        "l_net_e": {"who": "lindqvist", "to": "expedition", "text": "Mind its mouth, it spits even asleep. The cart."},
        "l_caged": {"who": "lindqvist", "to": "expedition", "text": "Caged."},
        "p_count": {"who": "pieter", "to": "expedition", "text": "One in the book."},
        "l_eggs": {"who": "lindqvist", "to": "expedition", "text": "The eggs. Warm. I carry them myself."},
        "l_all": {"who": "lindqvist", "to": "expedition", "text": "All of them. Now down, before the sun."},
        "l_woke": {"who": "lindqvist", "to": "expedition", "text": "They are awake! The carts, now! Down the mountain!"},
        "l_empty": {"who": "lindqvist", "to": "expedition", "text": "Nothing. We go down with empty cages."},
        # part 2
        "l_trail": {"who": "lindqvist", "to": "expedition", "text": "The carts are rolling. Keep the guns round them."},
        "tip_trail": {"who": "lindqvist", "to": "expedition", "text": "The carts carry our powder too. A man who has fired his shots refills beside one."},
        "l_raid1": {"who": "lindqvist", "to": "expedition", "text": "In the trees! They want the cages!"},
        "l_grown": {"who": "lindqvist", "to": "expedition", "text": "Those are not hatchlings. Last year's young, grown. Look at them."},
        "l_freed": {"who": "lindqvist", "to": "expedition", "text": "A cage is broken! It is loose!"},
        "l_lost": {"who": "lindqvist", "to": "expedition", "text": "Every cage broken. Two years for nothing."},
        # part 3
        "b_1": {"who": "benedito", "to": "expedition", "text": "Here, Doctor! The canoes are ready. Load the cages."},
        "l_crates": {"who": "lindqvist", "to": "expedition", "text": "Whose crates are those on the quay?"},
        "b_crates": {"who": "benedito", "to": "expedition", "text": "From Lisbon, for the mines in the south. Heavy. A gear stamped on the wood."},
        "b_room_few": {"who": "benedito", "to": "expedition", "text": "Few paddlers came from Nazaré, Doctor. Two cages, no more."},
        "b_room_many": {"who": "benedito", "to": "expedition", "text": "All of Nazaré came to paddle. There is room for every cage."},
        "n_roar": {"who": "narrator", "to": "expedition", "text": "Up the river bank something roared, and the forest went quiet."},
        "l_sire_comes": {"who": "lindqvist", "to": "expedition", "text": "The Sire. He has come for the last cart. Hold him off!"},
        "b_load": {"who": "benedito", "to": "expedition", "text": "One aboard! Bring the next!"},
        "b_full": {"who": "benedito", "to": "expedition", "text": "No more room, Doctor! The canoes are full!"},
        "b_push": {"who": "benedito", "to": "expedition", "text": "Push off! Paddle!"},
        "l_end": {"who": "lindqvist", "to": "expedition", "text": "We went down the river with the cages rattling."},
        "b_gone": {"who": "benedito", "to": "expedition", "text": "The canoes are going, Doctor! We cannot wait!"},
        "l_hurt": {"who": "lindqvist", "to": "expedition", "text": "I am hurt. Keep them off me!"},
        # the ending: the expedition's
        "l_end_all": {"who": "lindqvist", "text": "Every cage came down to the river. The finest expedition of my life."},
        "l_end_some": {"who": "lindqvist", "text": "Not every cage came down, but enough."},
        "l_end_few": {"who": "lindqvist", "text": "Only a few cages came down. It was enough for me."},
        "l_end_saved": {"who": "lindqvist", "text": "The young Sire was for the eggs I saved. In a year I had a breeding stock."},
        "l_end_burned": {"who": "lindqvist", "text": "The eggs I took that night were my new beginning."},
        "l_end_eggs": {"who": "lindqvist", "text": "I carried the eggs down myself, all the way to the river."},
        "l_end_pieter": {"who": "lindqvist", "text": "Pieter wrote every cage in the book."},
        "k_end1": {"who": "king", "text": "His finest hour, he calls it. He took a mother's young in the night."},
        "k_end2": {"who": "king", "text": "And the crates on that quay went south to the mines. Nobody opened them."},
        # the ending: the creatures' (the King tells what did not happen)
        "k_end_c1": {"who": "king", "text": "That is not how it went. The carts came down to the river."},
        "k_end_c2": {"who": "king", "text": "But it could have gone that way. Then the doctor would have come home with empty cages."},
    },
    "stills": {
        "rome": {"image": STILL % "b01_08", "caption": "Rome, the present. The King and his prisoner, the doctor."},
        "camp": {"image": STILL % "a05_01", "caption": "The cloud mountain, the dry season 2769. The Academy's camp by night."},
        "taking": {"image": STILL % "a05_02", "caption": "The taking: the young netted in the ferns."},
        "trail": {"image": STILL % "a05_03", "caption": "The cage carts on the trail down."},
        "landing": {"image": STILL % "a05_04", "caption": "The river landing, the canoes and the Lisbon crates."},
        "sire": {"image": STILL % "a05_05", "caption": "The Sire comes for the last cart."},
    },
    "opening": {
        "expedition": [
            {"still": "rome", "lines": ["k_open1", "k_open2"]},
            {"still": "camp", "lines": ["l_open1", {"id": "l_open_saved", "if": SAVED_CLUTCH}, {"id": "l_open_burned", "if": BURNED}]},
            {"still": "taking", "lines": ["l_open2"]},
        ],
        "creatures": [
            {"still": "rome", "lines": ["k_open_c"]},
            {"still": "taking", "lines": ["k_open_c2"]},
        ],
    },
    "ending": {
        "expedition": [
            {"still": "landing", "lines": [{"id": "l_end_all", "if": {"flag": {"cages": "all"}}},
                                          {"id": "l_end_some", "if": {"flag": {"cages": "some"}}},
                                          {"id": "l_end_few", "if": {"flag": {"cages": "few"}}},
                                          {"id": "l_end_eggs", "if": {"flag": {"eggs": "taken"}}},
                                          {"id": "l_end_pieter", "if": {"flag": {"pieter": "alive"}}}]},
            {"still": "trail", "lines": [{"id": "l_end_saved", "if": SAVED_CLUTCH}, {"id": "l_end_burned", "if": BURNED}]},
            {"still": "rome", "lines": ["k_end1", "k_end2"]},
        ],
        "creatures": [
            {"still": "sire", "lines": ["k_end_c1"]},
            {"still": "rome", "lines": ["k_end_c2"]},
        ],
    },
    "briefing": {
        "expedition": {"still": "camp", "text": [
            "The cloud mountain, the dry season 2769. You are Dr. Lindqvist, with the Academy's hired guns, porters and cage carts.",
            "By night, net the sleeping young and take the eggs. By day, bring the cages down to Benedito's canoes.",
            "Lindqvist must live. Do not wake the nest."]},
        "creatures": {"still": "taking", "text": [
            "The cloud mountain, the dry season 2769. You are the nest: the Mother in her hollow, her hunters asleep.",
            "Men with cages are in the ferns. Grow the Mother and the young while you sleep; when they take to the trail, free the cages."]},
    },
    "debrief": {
        "expedition": {"still": "landing", "title": "Down to the river",
                       "text": "Lindqvist brought the cages down to Benedito's canoes.",
                       "text_if": [
                           {"if": {"flag": {"cages": "all"}}, "text": "Every cage came down: {cages} of {cages0}."},
                           {"if": {"flag": {"cages": "some"}}, "text": "{cages} of {cages0} cages came down."},
                           {"if": {"flag": {"cages": "few"}}, "text": "Only {cages} of {cages0} cages came down."},
                           {"if": {"flag": {"eggs": "taken"}}, "text": "He carried the eggs himself."}]},
        "creatures": {"still": "sire", "title": "The cages are broken",
                      "text": "The young went back to the mountain. The doctor's carts came down empty."},
    },
    "next": {"expedition": "a07_council", "creatures": ""},
}

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the creatures (the mirror, Claude's choice 1 there) are bound to B3:
# GROW to stage 2 and MATURE; the Tyrant Sire is away (he comes down in Part 3: the story's deny, as a03's)
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import roster_ladder
roster_ladder.apply(M, "a05_specimens", story_deny={"creatures": ["tyrannosaur"]})

out = os.path.join(ROOT, "campaign", "missions", "a05_specimens.json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines")
