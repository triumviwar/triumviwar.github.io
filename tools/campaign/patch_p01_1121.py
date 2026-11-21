#!/usr/bin/env python3
"""campaign-fixes-1121 (the owner, 2026-11-21 15:43; docs/campaign_fixes_1121.md) on the Prologue's
campaign/missions/p01_leaf.json (make_m1_mission.py is older than the JSON, so it is patched in place, like
tools/campaign/roster_ladder.py does; running this again changes nothing):
  1. SAVE THE FAMILIES had about ten seconds: the raiders were spawned at the farm. Now THE RAIDERS MARCH: a band comes
     down the north road from the east woods in three stages, pinged each time (and on the minimap), on a countdown the
     player sees ("The raiders reach Hollins Farm in 1:40": EASY longer, HARD shorter); at its end they go for the farm.
     The choice has a minute; MARCH ON leaves the farm to them when the band arrives.
  2. Lord Fairleigh and Father Tomasz are the mission's heroes (scripts/campaign/mission_heroes.gd): wounded, not killed.
  python3 tools/campaign/patch_p01_1121.py
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PATH = os.path.join(ROOT, "campaign", "missions", "p01_leaf.json")
RAID = 100                 # seconds from the smoke to the raiders at the farm (NORMAL; the countdown takes EASY x1.25 / HARD x0.85)

m = json.load(open(PATH))

m["heroes"] = ["fairleigh", "tomasz"]
# the difficulty's clocks (EASY a longer, HARD a shorter march): the mission had spawns only
d = m.setdefault("difficulty", {})
d.setdefault("easy", {})["clocks"] = 1.25
d.setdefault("hard", {})["clocks"] = 0.85

# the band's way: out of the east woods, down the clearing, west toward the farm
m["areas"].update({"raid_0": [105, 10, 6, 4], "raid_1": [104, 20, 6, 4], "raid_2": [94, 13, 5, 4], "raid_3": [88, 12, 4, 3]})

objs = {o["id"]: o for o in m["objectives"]}
objs["families"]["text"] = "Save the families at Hollins Farm. The raiders reach it in {clock:raid}."

tr = {t["id"]: t for t in m["triggers"]}
c1 = tr["camp1_down"]
for a in c1["do"]:
    sp = a.get("spawn")
    if sp and sp.get("tag") == "raiders":
        sp["at"] = "raid_0"
    if "choice" in a:
        a["choice"]["time"] = 60
if not any("clock" in a for a in c1["do"]):
    c1["do"].insert(3, {"clock": {"name": "raid", "secs": RAID, "scale": True}})
    c1["do"].insert(4, {"ping": {"tag": "raiders"}})
for a in c1["do"]:
    if "say" in a and a["say"] == ["t_smoke", "f_choice"]:
        a["say"] = ["t_smoke", "t_band", "f_choice"]

# the march: stage by stage on the clock, each one pinged (the band shows on the minimap with the ping)
new = [
    {"id": "raiders_go", "when": {"fired": "camp1_down"}, "delay": 4, "do": [
        {"order": {"tag": "raiders", "do": "move", "to": "raid_1"}}]},
    {"id": "raid_leg2", "when": {"all": [{"fired": "camp1_down"}, {"clock_left": {"name": "raid", "below": 62}}]}, "do": [
        {"order": {"tag": "raiders", "do": "move", "to": "raid_2"}}, {"ping": {"tag": "raiders"}}]},
    {"id": "raid_leg3", "when": {"all": [{"fired": "camp1_down"}, {"clock_left": {"name": "raid", "below": 30}}]}, "do": [
        {"order": {"tag": "raiders", "do": "move", "to": "raid_3"}}, {"ping": {"tag": "raiders"}}, {"say": ["t_band_near"]}]},
    {"id": "raid_ping", "when": {"all": [{"fired": "camp1_down"}, {"not": {"clock_out": "raid"}}, {"not": {"dead": "raiders"}}]},
     "every": 15, "delay": 15, "do": [{"ping": {"tag": "raiders"}}]},
    {"id": "raid_arrive", "when": {"all": [{"fired": "camp1_down"}, {"clock_out": "raid"}]}, "do": [
        {"order": {"tag": "raiders", "do": "attack", "to": "hollins"}}, {"ping": {"area": "hollins"}}]},
    {"id": "left", "when": {"all": [{"flag": {"families": "leave"}}, {"fired": "raid_arrive"}]}, "delay": 20, "do": [
        {"hurt": {"tag": "hollins_farm", "amount": 2000}}, {"hurt": {"tag": "families", "amount": 500}}, {"say": ["t_left"]}]},
]
out = []
for t in m["triggers"]:
    if t["id"] in [n["id"] for n in new]:
        continue
    out.append(t)
    if t["id"] == "camp1_down":
        out += new
m["triggers"] = out
# the countdown stops when the families are saved or lost
tr = {t["id"]: t for t in m["triggers"]}
for tid in ("saved", "families_lost"):
    if not any("clock" in a for a in tr[tid]["do"]):
        tr[tid]["do"].append({"clock": {"name": "raid", "stop": True}})

m["lines"]["t_band"] = {"who": "tomasz", "text": "Riders saw a band on the north road, my lord: militia and a torch. They will be at the farm within the hour."}
m["lines"]["t_band_near"] = {"who": "tomasz", "text": "The band is past the woods. They are almost at the farm!"}

with open(PATH, "w") as f:
    json.dump(m, f, indent="\t", ensure_ascii=False)
print("p01_leaf patched")
