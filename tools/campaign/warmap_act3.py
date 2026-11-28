#!/usr/bin/env python3
"""THE WAR MAP'S ACT 3 (job act3-warmap, docs/war_map_act3.md): writes Act 3's part of campaign/warmap.json.

Step 2 of docs/campaign_act3_plan.md's build order: the WORLD view (the whole globe) and the four THEATRE views (THE
AMERICAS, AFRICA, THE INDIES, THE SOUTHERN SEAS) with a wider EUROPE for the night and the finale; Act 3's regions (the
colonies on the clock, the allies, the places never on the clock), marks (the theatres' names, the allies' crowns, the
sea roads that carried the dangers, the refugees' roads, the ruin, the Cold Forge), the pins e01-e20 (all planned: the
plan's working titles and an `about` line each), their rules by the plan's flags, the acts (Act 3, the night, the
present), THE CLOCK (its numbers and theatres) and the brass map's and the chart's notes. Every item it writes carries
"act3": true, so it can run again: it first takes its own items out, then puts them back.
    python3 tools/campaign/warmap_act3.py
Then the land must cover the new bounds (Asia, Australia, the edge of Antarctica):
    python3 tools/campaign/make_warmap_land.py ne_50m_land.geojson ne_50m_lakes.geojson ne_50m_rivers_lake_centerlines.geojson
Places are [lon, lat]; the projection is the file's (x = lon, y = -lat * 1.3). EVERY TEXT IS A PLACEHOLDER.
"""
import json, os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PATH = os.path.join(ROOT, "campaign/warmap.json")
MOUNT = os.path.join(ROOT, "campaign/warmap_mountains.json")

BOUNDS = [-170, -72, 180, 76]          # (was [-170, -48, 110, 76]: Act 3 reaches Japan, Australia and the ice)

# ---------------------------------------------------------------- places (lon, lat)
COAST_BR = [-41.0, -14.8]       # e01: Brazil's coast below Salvador, where the column comes out (proposed)
POTOSI = [-65.75, -19.58]
VIRGINIA = [-77.9, 37.9]
QUEBEC = [-71.2, 46.8]
VERACRUZ = [-96.1, 19.2]
SALVADOR = [-38.9, -12.9]
SAO_SALVADOR = [14.25, -6.27]   # Mbanza Kongo
CONGO_RIVER = [18.2, -2.2]
FOREST_STATION = [21.8, -0.6]   # e06: a new pen in the forest by an old ruin (proposed)
GONDAR = [37.47, 12.6]
LUANDA = [13.23, -8.84]
GOA = [74.0, 15.4]
NAGASAKI = [129.87, 32.75]
MANILA = [120.98, 14.6]
TERNATE = [127.6, 0.9]          # (Ternate itself is too small for the 1:50m land: the Halmahera shore opposite)
SYDNEY = [151.2, -33.86]
BATHURST = [149.58, -33.42]     # the gold fields inland (proposed: by Bathurst, over the mountains)
NORTH_SHORE = [143.6, -14.6]
FORGE = [110.6, -66.6]          # the Cold Forge: an ice station on the edge of the continent (proposed: south of Australia)
LISBON = [-9.0, 38.8]           # (a step inland: the 1:50m coast)
ROME = [12.48, 41.9]
MILVIAN = [12.467, 41.935]
BARRA = [-60.0, -3.1]
CONCORDIA = [-51.6, -27.3]

VIEWS = [
    {"id": "globe", "label": "THE WORLD", "rect": [-170, -60, 180, 72], "acts": [3, 4]},
    {"id": "americas", "label": "THE AMERICAS", "rect": [-122, -40, -30, 54], "acts": [3, 4]},
    {"id": "africa", "label": "AFRICA", "rect": [-20, -37, 55, 20], "acts": [3, 4]},
    {"id": "indies", "label": "THE INDIES", "rect": [66, -12, 140, 40], "acts": [3, 4]},
    {"id": "seas", "label": "THE SOUTHERN SEAS", "rect": [104, -70, 180, -6], "acts": [3, 4]},
    {"id": "europe3", "label": "EUROPE", "rect": [-13, 35, 20, 52], "acts": [3, 4]},
]
OLD_VIEWS_ACTS = {"world": [1, 2], "brazil": [2], "virginia": [1, 2], "europe": [1, 2], "amazon": [1, 2]}

# ---------------------------------------------------------------- regions: the colonies (on the clock), the allies and the rest
REGIONS = [
    # THE AMERICAS
    {"id": "caribbean", "name": "The Caribbean", "label_at": [-77.0, 19.6],
     "poly": [-85.2, 23.4, -80.0, 23.6, -74.0, 20.6, -68.0, 19.9, -64.6, 18.6, -65.4, 17.6, -70.0, 17.4, -74.6, 17.6, -78.6, 17.6, -82.6, 21.2]},
    {"id": "brazil_interior", "name": "Brazil's interior", "label_at": [-54.0, -12.6],
     "poly": [-60.8, -8.6, -52.6, -8.0, -48.6, -9.6, -47.6, -14.6, -49.6, -17.8, -55.0, -18.4, -59.8, -16.0, -61.6, -12.0]},
    {"id": "potosi", "name": "Potosí", "label_at": [-65.9, -20.6],
     "poly": [-68.6, -17.6, -64.6, -17.4, -63.4, -19.6, -64.0, -22.0, -66.6, -22.6, -68.8, -20.6]},
    {"id": "quebec", "name": "Quebec", "label_at": [-71.6, 47.8],
     "poly": [-76.6, 45.2, -71.6, 45.0, -66.6, 47.4, -64.6, 49.6, -69.0, 50.6, -75.6, 48.6]},
    {"id": "new_spain", "name": "New Spain", "label_at": [-100.6, 21.4],
     "poly": [-105.6, 22.6, -101.0, 25.2, -97.6, 24.0, -96.4, 19.6, -94.6, 18.2, -97.6, 16.4, -102.6, 18.0, -105.4, 20.0]},
    # AFRICA
    {"id": "kongo", "name": "The Kingdom of Kongo", "label_at": [15.4, -5.2],
     "poly": [12.4, -4.6, 15.6, -4.2, 17.6, -5.2, 17.4, -7.4, 14.6, -7.6, 12.6, -6.8]},
    {"id": "luanda_hinterland", "name": "Luanda's hinterland", "label_at": [16.8, -10.8],
     "poly": [13.4, -8.2, 17.0, -7.8, 19.6, -9.4, 19.4, -12.8, 15.6, -13.4, 13.0, -11.6]},
    {"id": "mozambique", "name": "Mozambique", "label_at": [37.0, -15.8],
     "poly": [34.2, -11.6, 40.6, -10.6, 40.8, -14.6, 39.0, -17.6, 35.6, -21.0, 33.6, -19.0, 34.6, -15.6]},
    {"id": "cape", "name": "The Cape", "label_at": [21.4, -33.0],
     "poly": [17.6, -31.0, 21.0, -30.6, 25.6, -32.4, 26.6, -34.0, 22.0, -34.8, 18.0, -34.8]},
    {"id": "ethiopia", "name": "Ethiopia", "label_at": [38.6, 10.0],
     "poly": [35.6, 13.8, 39.6, 14.4, 41.6, 12.0, 41.4, 8.4, 38.6, 6.6, 35.4, 7.6, 34.8, 10.6]},
    # THE INDIES
    {"id": "malacca", "name": "Malacca", "label_at": [102.6, 3.0],
     "poly": [100.6, 4.6, 103.4, 4.4, 104.2, 1.4, 102.6, 1.2, 101.0, 2.6]},
    {"id": "manila_lake", "name": "Manila and the lake", "label_at": [121.4, 15.4],
     "poly": [119.8, 16.0, 122.4, 16.0, 122.6, 13.6, 120.4, 13.6]},
    {"id": "moluccas", "name": "The Moluccas", "label_at": [128.4, -1.8],
     "poly": [125.6, 2.4, 129.6, 2.4, 131.0, -1.0, 129.6, -4.4, 126.0, -4.0, 125.2, -0.6]},
    {"id": "nagasaki", "name": "Nagasaki", "label_at": [130.4, 33.6], "circle": [130.0, 32.8, 0.9]},
    # THE SOUTHERN SEAS
    {"id": "sydney", "name": "Sydney Cove", "label_at": [152.4, -34.6], "circle": [150.9, -33.9, 0.8]},
    {"id": "gold_fields", "name": "The gold fields", "label_at": [148.6, -32.2],
     "poly": [147.2, -31.6, 150.0, -31.8, 150.2, -33.0, 149.8, -34.6, 147.4, -34.6, 146.8, -33.0]},
    {"id": "northern_shore", "name": "The northern shore", "label_at": [143.6, -16.0],
     "poly": [141.4, -11.0, 143.4, -10.8, 144.6, -13.6, 146.6, -16.6, 146.4, -19.0, 142.6, -18.4, 141.4, -15.0]},
]
# Act 3's regions are drawn (and named) only once Act 3 has opened: their first holder is the faint empire
for r in REGIONS:
    r["act"] = 3

# THE CLOCK's theatres: core missions in order, optional ones, the colonies in their fall order (the climate's), and
# where the theatre's name stands on the map. The numbers were tuned with tools/sim_war_clock.gd (docs/war_map_act3.md).
CLOCK = {
    "about": "THE CLOCK (docs/war_map_act3.md): the year turns after every per_year wins of Act 3's theatre missions (an "
             "optional one counts optional_weight); at each turn the unsettled theatre left alone longest, for at least "
             "grace years, loses its next colony (ties: the one whose next colony goes to the creatures, then `tie`). A "
             "theatre whose core missions are all won is SETTLED. `head`: years of neglect a theatre starts with (the "
             "sparks of Act 2 that got away). `reclaim`: a colony that fell comes back (and is safe) when the mission at "
             "its place is won so. The clock stops when the night begins.",
    "start": {"done": ["d10_jungle", "d11_siege"]},
    "stop": {"any": [{"done": "e16_lisbon"}, {"done": "e17_goa"}, {"done": "e18_port"}]},
    "first_year": 2781, "per_year": 2, "optional_weight": 0.5, "grace": 2, "pass_on": True, "max_turns": 8,
    "tie": ["africa", "americas", "indies", "seas"],
    "attention": {"e15_forge": ["africa", "indies"]},
    "theatres": [
        {"id": "americas", "name": "THE AMERICAS", "core": ["e01_brazil", "e03_virginia"], "optional": ["e02_potosi"],
         "colonies": [
             {"region": "caribbean", "to": "brood"},
             {"region": "brazil_interior", "to": "brood", "to_if": [{"if": {"flag": {"d09_crossroads.first": "brood"}}, "to": "machine"}]},
             {"region": "potosi", "to": "machine", "reclaim": {"flag": {"e02_potosi.potosi": "held"}}},
             {"region": "virginia_interior", "to": "brood"}]},
        {"id": "africa", "name": "AFRICA", "core": ["e04_kongo", "e05_river", "e06_taken"], "optional": ["e07_highlands"],
         "head": [{"if": {"any": [{"not_done": "d12_luanda"}, {"flag": {"d12_luanda.luanda": "escaped"}}]}, "years": 1}],
         "colonies": [
             {"region": "luanda_hinterland", "to": "brood"},
             {"region": "mozambique", "to": "brood"},
             {"region": "cape", "to": "brood"}]},
        {"id": "indies", "name": "THE INDIES", "core": ["e08_arsenal", "e09_nagasaki", "e11_spice"], "optional": ["e10_manila"],
         "head": [{"if": {"any": [{"not_done": "d13_goa"}, {"flag": {"d13_goa.goa_seed": "shipped"}}]}, "years": 1}],
         "colonies": [
             {"region": "moluccas", "to": "machine", "reclaim": {"flag": {"e11_spice.spice": "cleared"}}},
             {"region": "malacca", "to": "machine"},
             {"region": "manila_lake", "to": "machine", "reclaim": {"flag": {"e10_manila.manila": "held"}}}]},
        {"id": "seas", "name": "THE SOUTHERN SEAS", "core": ["e12_exiles", "e13_gold"], "optional": ["e14_shore"],
         "colonies": [
             {"region": "gold_fields", "to": "machine", "reclaim": {"flag": {"e13_gold.goldfields": "held"}}},
             {"region": "northern_shore", "to": "brood", "reclaim": {"flag": {"e14_shore.shore": "burned"}}}]},
    ],
    # the ledger's words (a %s for the year, a %s for the colony's name)
    "fell": {"brood": "%s: %s fell to the creatures.", "machine": "%s: %s fell to the machines."},
    "back": "%s: %s was taken back.",
    "year": "The year %s",
}

MARKS = [
    # the theatres' names (drawn large on THE WORLD; the clock's state beside them)
    {"id": "theatre_americas", "kind": "theatre", "point": [-86.0, 4.0], "label": "THE AMERICAS", "theatre": "americas"},
    {"id": "theatre_africa", "kind": "theatre", "point": [22.0, 3.0], "label": "AFRICA", "theatre": "africa"},
    {"id": "theatre_indies", "kind": "theatre", "point": [96.0, 22.0], "label": "THE INDIES", "theatre": "indies"},
    {"id": "theatre_seas", "kind": "theatre", "point": [134.0, -27.0], "label": "THE SOUTHERN SEAS", "theatre": "seas"},
    # the allies' crowns
    {"id": "crown_kongo", "kind": "crown", "point": SAO_SALVADOR, "label": "The King of Kongo"},
    {"id": "crown_ethiopia", "kind": "crown", "point": GONDAR, "label": "The Emperor of Ethiopia"},
    {"id": "crown_goa", "kind": "crown", "point": [74.3, 15.0], "label": "The Viceroy of Goa"},
    {"id": "crown_manila", "kind": "crown", "point": [121.2, 14.4], "label": "Manila"},
    {"id": "crown_new_spain", "kind": "crown", "point": [-99.1, 19.4], "label": "New Spain"},
    {"id": "kongo_fallen", "kind": "burnt", "point": SAO_SALVADOR, "label": "São Salvador, fallen"},
    # the sea roads: the ships that carried the dangers
    {"id": "road_eggs", "kind": "route", "point": BARRA, "label": "",
     "points": [BARRA, [-50.0, -0.5], [-35.0, -4.0], [-15.0, -6.0], [0.0, -8.0], [12.6, -8.8]]},
    {"id": "road_machines", "kind": "route", "point": CONCORDIA, "label": "",
     "points": [[-48.6, -26.2], [-30.0, -30.0], [0.0, -38.0], [20.0, -38.5], [45.0, -28.0], [60.0, -5.0], [73.6, 15.4]]},
    {"id": "road_spice_eggs", "kind": "route", "point": BARRA, "label": "",
     "points": [[-34.0, -8.0], [0.0, -38.0], [20.0, -38.5], [60.0, -32.0], [100.0, -12.0], [120.0, -6.0], [127.0, 0.2]]},
    {"id": "road_manila", "kind": "route", "point": MANILA, "label": "",
     "points": [[120.6, 14.2], [125.0, 6.0], [132.0, -6.0], [150.0, -20.0], [151.6, -33.6]]},
    {"id": "road_hulk", "kind": "route", "point": LUANDA, "label": "",
     "points": [[12.6, -9.2], [10.0, -25.0], [20.0, -39.0], [60.0, -38.0], [100.0, -30.0], [125.0, -16.0], [140.0, -11.4], [142.8, -13.4]]},
    # the refugees' roads
    {"id": "refugees_virginia", "kind": "route", "point": VIRGINIA, "label": "",
     "points": [VIRGINIA, [-76.0, 41.0], [-74.0, 44.0], [-71.6, 46.6]]},
    {"id": "refugees_brazil", "kind": "route", "point": [-53.0, -12.0], "label": "",
     "points": [[-53.0, -12.0], [-47.0, -13.0], [-42.0, -14.4]]},
    {"id": "ruin_sealed", "kind": "ruin", "point": [22.3, -0.3], "label": "The ruin, sealed"},
    {"id": "ruin_open", "kind": "ruin_open", "point": [22.3, -0.3], "label": "The ruin: its records opened"},
    {"id": "forge_question", "kind": "question", "point": [110.6, -63.5], "label": "Beyond the map"},
    {"id": "forge_broken", "kind": "burnt", "point": FORGE, "label": "The Cold Forge, broken"},
    {"id": "lisbon_town", "kind": "town", "point": LISBON, "label": "Lisbon"},
    {"id": "lisbon_burning", "kind": "burnt", "point": [-9.0, 38.9], "label": "Lisbon, burning"},
    {"id": "goa_fallen", "kind": "burnt", "point": [73.8, 15.7], "label": "Goa, lost on the night"},
    {"id": "siege_rome", "kind": "siege", "point": ROME, "label": "The siege of Rome"},
    {"id": "fleet_rome", "kind": "ship", "point": [10.6, 40.6], "label": "The fleet off the Tiber's mouth"},
]
for m in MARKS:
    m["act"] = 3

P = "planned"
AFTER_ACT = ["d10_jungle", "d11_siege"]
CORE = ["e01_brazil", "e03_virginia", "e04_kongo", "e05_river", "e06_taken", "e08_arsenal", "e09_nagasaki", "e11_spice",
        "e12_exiles", "e13_gold"]
NIGHT = ["e16_lisbon", "e17_goa", "e18_port"]
PINS = [
    {"mission": "e01_brazil", "line": "crown", "theatre": "americas", "place": "Brazil, the road to the coast", "date": "2781",
     "point": COAST_BR, "title": "Brazil After the Fires", "after": AFTER_ACT,
     "about": "Ruggieri brings the colonists of the burnt interior down to the coast, the grown danger at their backs."},
    {"mission": "e02_potosi", "line": "crown", "theatre": "americas", "optional": True, "place": "Potosí, the Andes",
     "date": "2784", "point": POTOSI, "title": "The Silver Mountain", "after": ["e01_brazil"],
     "about": "Optional. Something works the deep galleries of the silver mountain at night: drive the machines out of the mine."},
    {"mission": "e03_virginia", "line": "crown", "theatre": "americas", "place": "Virginia", "date": "2787", "point": VIRGINIA,
     "nudge": [16, -14], "title": "The Last Ride of the Governor", "after": ["e01_brazil"],
     "about": "Old Fairleigh brings Virginia's people over the river to the north, the swarm at the farms. A choice: ride out, or ride with them."},
    {"mission": "e04_kongo", "line": "crown", "theatre": "africa", "place": "São Salvador do Congo", "date": "2781",
     "point": SAO_SALVADOR, "title": "The King of Kongo", "after": AFTER_ACT,
     "about": "Tomasz and the Catholic King of Kongo hold his city when the swarm comes out of the hinterland."},
    {"mission": "e05_river", "line": "naturalist", "theatre": "africa", "place": "The Congo", "date": "2782",
     "point": CONGO_RIVER, "title": "Up the Great River", "after": ["e04_kongo"],
     "about": "Father Inácio's balloon finds the nests; Valadares takes the river column up after them."},
    {"mission": "e06_taken", "line": "naturalist", "theatre": "africa", "place": "A station in the forest", "date": "2783",
     "point": FOREST_STATION, "title": "The Naturalist Taken", "after": ["e05_river"],
     "about": "Valadares finds Lindqvist at a new pen beside an old ruin of the labs. A choice: seal the ruin, or open its records."},
    {"mission": "e07_highlands", "line": "crown", "theatre": "africa", "optional": True, "place": "The Ethiopian highlands",
     "date": "2784", "point": GONDAR, "nudge": [0, 16], "title": "The Highland Wall", "after": ["e06_taken"],
     "about": "Optional. Ethiopia's highlands hold the swarm at their foot, where the nights are cold: hold the passes with the Emperor's men."},
    {"mission": "e08_arsenal", "line": "clockmaker", "theatre": "indies", "place": "Goa", "date": "2783", "point": GOA,
     "nudge": [-16, -12], "title": "The Arsenal of Goa", "after": AFTER_ACT,
     "about": "The guild's last hands and Father Ferrer burn the Machine's seed out of the Viceroy's arsenal in the monsoon."},
    {"mission": "e09_nagasaki", "line": "clockmaker", "theatre": "indies", "place": "Nagasaki", "date": "2785", "point": NAGASAKI,
     "title": "The Praying Clockmakers", "after": ["e08_arsenal"],
     "about": "The Christian clockmakers of Nagasaki teach Hollweg how to stop it. A choice: ring the stop-work now, or keep it."},
    {"mission": "e10_manila", "line": "crown", "theatre": "indies", "optional": True, "place": "Manila and the lake",
     "date": "2786", "point": MANILA, "title": "The Foundries of Manila", "after": ["e09_nagasaki"],
     "about": "Optional. The lake's foundries cast for the Machine: Tomasz and Manila's militia take them back."},
    {"mission": "e11_spice", "line": "naturalist", "theatre": "indies", "place": "The Moluccas", "date": "2787", "point": TERNATE,
     "title": "The Spice Islands", "after": ["e09_nagasaki"],
     "about": "The machines and the swarm meet on the spice islands for the first time outside Brazil, and the Crown between them."},
    {"mission": "e12_exiles", "line": "crown", "theatre": "seas", "place": "Sydney Cove", "date": "2788", "point": SYDNEY,
     "nudge": [16, 8], "title": "The Exiles' Rising", "after": AFTER_ACT,
     "about": "The Free Assembly's exiles rise at Sydney Cove. A choice: the swift answer, canister, or the King's pardon."},
    {"mission": "e13_gold", "line": "clockmaker", "theatre": "seas", "place": "The gold fields", "date": "2788", "point": BATHURST,
     "nudge": [-16, -10], "title": "The Gold Fields", "after": ["e12_exiles"],
     "about": "Machines came on a Manila ship to dig the gold fields: Hollweg and the guild's last hands hunt them in the hills."},
    {"mission": "e14_shore", "line": "naturalist", "theatre": "seas", "optional": True, "place": "The northern shore",
     "date": "2789", "point": NORTH_SHORE, "title": "The Northern Shore", "after": ["e13_gold"],
     "about": "Optional. A drifting hulk comes ashore in the mangroves: played as the creatures it carried, told from Valadares' chart."},
    {"mission": "e15_forge", "line": "clockmaker", "place": "The edge of Antarctica", "date": "2789", "optional": True,
     "point": FORGE, "title": "The Cold Forge", "after": ["e06_taken", "e09_nagasaki"],
     "about": "Optional. Hollweg and Valadares go south of every map to the forge the Machine keeps in the ice."},
    {"mission": "e16_lisbon", "line": "all", "night": True, "place": "Lisbon", "date": "Pentecost eve 2790", "point": LISBON,
     "title": "Lisbon (the night)", "after": CORE,
     "about": "The night the world caught fire: Tomasz, Captain Amaral and Father Inácio at Lisbon's port and old city."},
    {"mission": "e17_goa", "line": "all", "night": True, "place": "Goa", "date": "Pentecost eve 2790", "point": GOA,
     "nudge": [16, 12], "title": "Goa (the night)", "after": CORE,
     "about": "The same night at Goa: Hollweg and Father Ferrer at the old city and the arsenal. Ferrer's last night."},
    {"mission": "e18_port", "line": "all", "night": True, "place": "The Atlantic port", "date": "Pentecost eve 2790",
     "point": SALVADOR, "title": "The Atlantic Port (the night)", "after": CORE,
     "about": "The same night on the Atlantic: Luanda, Veracruz or Salvador, as the ledger leaves them."},
    {"mission": "e19_tiber", "line": "all", "place": "The Tiber", "date": "2795", "point": MILVIAN, "nudge": [-16, -14],
     "title": "The Tiber", "after": NIGHT,
     "about": "The present. The heir takes his first command at the Milvian Bridge against the Machine's vanguard."},
    {"mission": "e20_rome", "line": "all", "place": "Rome", "date": "2795", "point": ROME, "nudge": [16, 14],
     "title": "Rome", "after": ["e19_tiber"],
     "about": "The siege of Rome, the Machine from the north and the creatures from the marshes. The final choice."},
]
for pn in PINS:
    pn["act"] = 3
    pn.setdefault("nudge", [0, 0])

PC = ["parchment", "chart"]


def R(cond, **k):
    r = {"if": cond}
    r.update(k)
    return r


START = {"done": AFTER_ACT}
COLONIES = [c["region"] for t in CLOCK["theatres"] for c in t["colonies"]]
NIGHT_STARTED = CLOCK["stop"]
RULES = [
    # Act 3 opens: the world unrolled, every colony and ally the Crown's (the clock takes them from here)
    R(START, regions=COLONIES + ["kongo", "ethiopia", "quebec", "new_spain", "nagasaki", "sydney"], to="crown",
      marks=["theatre_americas", "theatre_africa", "theatre_indies", "theatre_seas", "crown_kongo", "crown_ethiopia",
             "crown_goa", "crown_manila", "crown_new_spain", "forge_question", "lisbon_town"], show=True,
      ledger="2781: the dangers left Brazil by the Crown's own sea roads. Four theatres burn; the year turns as you fight."),
    R({"done": AFTER_ACT, "any": [{"not_done": "d12_luanda"}, {"flag": {"d12_luanda.luanda": "escaped"}}]}, mark="road_eggs",
      show=True, region="luanda", to="contested", ledger="The eggs that got away at Luanda hatched inland: Africa starts a year behind."),
    R({"done": AFTER_ACT, "any": [{"not_done": "d13_goa"}, {"flag": {"d13_goa.goa_seed": "shipped"}}]}, mark="road_machines",
      show=True, region="goa", to="contested", ledger="The machines shipped on from Goa woke in the east: the Indies start a year behind."),
    # e01 BRAZIL AFTER THE FIRES (colonists few / some / many)
    R({"done": "e01_brazil"}, mark="refugees_brazil", show=True, ledger="Ruggieri brought the interior's colonists down to the coast."),
    R({"flag": {"e01_brazil.colonists": "many"}}, ledger="Most of the colonists came aboard the ships."),
    R({"flag": {"e01_brazil.colonists": "some"}}, ledger="Some of the colonists came aboard the ships."),
    R({"flag": {"e01_brazil.colonists": "few"}}, ledger="Few of the colonists came aboard the ships."),
    # e02 THE SILVER MOUNTAIN (potosi held / lost)
    R({"flag": {"e02_potosi.potosi": "held"}}, ledger="The silver mountain was cleared of its machines."),
    R({"flag": {"e02_potosi.potosi": "lost"}}, region="potosi", to="machine", ledger="The silver mountain is the machines' now."),
    # e03 THE LAST RIDE (fairleigh rode_out / rode_with, virginia few / some / many)
    R({"done": "e03_virginia"}, mark="refugees_virginia", show=True, region="virginia", to="contested",
      ledger="Virginia's people crossed the river to the north, to Quebec."),
    R({"flag": {"e03_virginia.fairleigh": "rode_out"}}, ledger="Fairleigh rode out with the old troopers to buy the column its hour."),
    R({"flag": {"e03_virginia.fairleigh": "rode_with"}}, ledger="Fairleigh rode with his people to the river and over it."),
    R({"flag": {"e03_virginia.virginia": "many"}}, ledger="Most of Virginia came over the river."),
    R({"flag": {"e03_virginia.virginia": "some"}}, ledger="Some of Virginia came over the river."),
    R({"flag": {"e03_virginia.virginia": "few"}}, ledger="Few of Virginia came over the river."),
    # e04 THE KING OF KONGO (kongo stood / fell)
    R({"flag": {"e04_kongo.kongo": "stood"}}, ledger="The King of Kongo stood in his city with the Crown."),
    R({"flag": {"e04_kongo.kongo": "fell"}}, region="kongo", to="brood", mark="crown_kongo", show=False,
      ledger="São Salvador fell; the King of Kongo went down the river with his people."),
    R({"flag": {"e04_kongo.kongo": "fell"}}, mark="kongo_fallen", show=True),
    # e05 UP THE GREAT RIVER (nests found / blind)
    R({"flag": {"e05_river.nests": "found"}}, ledger="From the balloon Father Inácio found the swarm's nests on the river."),
    R({"flag": {"e05_river.nests": "blind"}}, ledger="The column went up the river blind: the nests were found by their bite."),
    # e06 THE NATURALIST TAKEN (lindqvist taken, ruin sealed / opened)
    R({"done": "e06_taken"}, ledger="Lindqvist was taken at his new pen in the forest, and sent to the King."),
    R({"flag": {"e06_taken.ruin": "sealed"}}, mark="ruin_sealed", show=True, ledger="The old ruin of the labs was sealed, as the Church asked."),
    R({"flag": {"e06_taken.ruin": "opened"}}, mark="ruin_open", show=True,
      ledger="The ruin's records were opened: the Brood was made, not born. Lindqvist read it himself."),
    # e07 THE HIGHLAND WALL (ethiopia held / lost)
    R({"flag": {"e07_highlands.ethiopia": "held"}}, ledger="Ethiopia held its highland passes against the swarm."),
    R({"flag": {"e07_highlands.ethiopia": "lost"}}, region="ethiopia", to="contested", ledger="The swarm came up into Ethiopia's valleys."),
    # e08 THE ARSENAL OF GOA (arsenal burned, matthias alive)
    R({"done": "e08_arsenal"}, ledger="The arsenal of Goa was burned with the Machine's seed in it."),
    R({"flag": {"e08_arsenal.matthias": "alive"}}, ledger="Matthias came out of the arsenal alive."),
    # e09 THE PRAYING CLOCKMAKERS (stopwork rung / kept, nagasaki few / some / many)
    R({"flag": {"e09_nagasaki.stopwork": "rung"}}, ledger="The stop-work was rung at Nagasaki: the city was saved, and its secret spent."),
    R({"flag": {"e09_nagasaki.stopwork": "kept"}}, region="nagasaki", to="contested",
      ledger="The stop-work was kept secret for the night it is needed most. Nagasaki paid for it."),
    R({"flag": {"e09_nagasaki.nagasaki": "many"}}, ledger="Most of Nagasaki's Christians came through."),
    R({"flag": {"e09_nagasaki.nagasaki": "some"}}, ledger="Some of Nagasaki's Christians came through."),
    R({"flag": {"e09_nagasaki.nagasaki": "few"}}, ledger="Few of Nagasaki's Christians came through."),
    # e10 THE FOUNDRIES OF MANILA (manila held / lost)
    R({"flag": {"e10_manila.manila": "held"}}, ledger="Manila's militia took the lake's foundries back.", mark="road_manila", show=True),
    R({"flag": {"e10_manila.manila": "lost"}}, region="manila_lake", to="machine", ledger="The lake's foundries cast for the machines."),
    # e11 THE SPICE ISLANDS (spice cleared / burning)
    R({"done": "e11_spice"}, mark="road_spice_eggs", show=True),
    R({"flag": {"e11_spice.spice": "cleared"}}, ledger="The spice islands were cleared of both dangers."),
    R({"flag": {"e11_spice.spice": "burning"}}, region="moluccas", to="contested", ledger="The spice islands burn: machines on one, the swarm on the next."),
    # e12 THE EXILES' RISING (exiles canister / pardon)
    R({"flag": {"e12_exiles.exiles": "canister"}}, region="sydney", to="contested", ledger="The exiles' rising was ended with canister. Sydney is quiet and uneasy."),
    R({"flag": {"e12_exiles.exiles": "pardon"}}, ledger="The exiles were pardoned in the King's name, and took up the Crown's muskets."),
    # e13 THE GOLD FIELDS (goldfields held / lost)
    R({"flag": {"e13_gold.goldfields": "held"}}, ledger="The gold fields were cleared of the Manila ship's machines."),
    R({"flag": {"e13_gold.goldfields": "lost"}}, region="gold_fields", to="machine", ledger="The machines dig the gold fields still."),
    # e14 THE NORTHERN SHORE (shore green / burned: the creatures' win and the rangers')
    R({"done": "e14_shore"}, mark="road_hulk", show=True, ledger="A drifting hulk came ashore in the north: the ship that left Luanda years ago."),
    R({"flag": {"e14_shore.shore": "green"}}, region="northern_shore", to="brood", ledger="The creatures took the mangroves of the northern shore."),
    R({"flag": {"e14_shore.shore": "burned"}}, ledger="The rangers burned the nests on the northern shore."),
    # e15 THE COLD FORGE (forge broken / standing)
    R({"flag": {"e15_forge.forge": "broken"}}, mark="forge_broken", show=True, ledger="The Cold Forge was broken in the ice."),
    R({"flag": {"e15_forge.forge": "broken"}}, mark="forge_question", show=False),
    R({"flag": {"e15_forge.forge": "standing"}}, ledger="The Cold Forge still works in the long night."),
    # THE NIGHT (e16-e18): the clock has run out; three ports burn at once
    R(NIGHT_STARTED, ledger="2790, the vigil of Pentecost: the night the world caught fire. The clock has stopped."),
    R({"flag": {"e16_lisbon.lisbon": "held"}}, ledger="Lisbon held through the night; the fleet sailed for the Tiber."),
    R({"flag": {"e16_lisbon.lisbon": "burning"}}, marks=["lisbon_burning"], show=True, ledger="Lisbon burned through the night."),
    R({"flag": {"e17_goa.goa_night": "held"}}, ledger="Goa held through the night. Father Ferrer died there, beside the man he warned in 2767."),
    R({"flag": {"e17_goa.goa_night": "lost"}}, region="goa", to="machine", mark="goa_fallen", show=True,
      ledger="Goa was lost on the night. Father Ferrer died there, beside the man he warned in 2767."),
    R({"flag": {"e18_port.atlantic": "held"}}, ledger="The Atlantic port held: its men are on the sea to Rome."),
    R({"flag": {"e18_port.atlantic": "lost"}}, ledger="The Atlantic port was lost on the night."),
    # THE FINALE
    R({"done": "e19_tiber"}, marks=["siege_rome", "fleet_rome"], show=True, ledger="2795: the heir took his first command at the Tiber."),
    R({"flag": {"e19_tiber.deserters": "spared"}}, ledger="The heir spared the deserters who asked to fight for Rome."),
    R({"flag": {"e19_tiber.deserters": "hanged"}}, ledger="The heir hanged the deserters at the bridge."),
    R({"flag": {"e20_rome.ending": "holds"}}, ledger="Rome holds."),
    R({"flag": {"e20_rome.ending": "falls"}}, region="papal_states", to="contested", ledger="Rome falls. The faith carries on, at sea."),
    # the brass map never shows the Southern Seas' gold fields as the machines' before e13 (Hollweg's plate shows what he knows)
]
# the night's clock on its three pins (the night's order: the first fresh, the last grown)
for mid in NIGHT:
    RULES.append(R({"done": CORE}, pin=mid, clock="The night: three ports burn at once. The first you fight is the freshest; the last has grown."))

NOTES = [
    {"skins": ["brass"], "if": {"done": "e08_arsenal"}, "point": [68.0, 18.5], "text": "Goa. The guild's last brass map, 2783."},
    {"skins": ["brass"], "if": {"done": "e09_nagasaki"}, "point": [124.0, 36.0], "text": "Nagasaki. Where it can be stopped."},
    {"skins": ["brass"], "if": {"done": "e13_gold"}, "point": [140.0, -31.0], "text": "The gold fields: machines off a Manila ship."},
    {"skins": ["brass"], "if": START, "point": [100.0, -60.0], "text": "South of every map: the forge in the ice."},
    {"skins": ["chart"], "if": START, "point": [16.0, -2.0], "text": "Up the great river: the swarm's roads (V.)."},
    {"skins": ["chart"], "if": {"done": "e05_river"}, "point": [19.0, 1.5], "text": "Nests on every bend above the falls, marked from the balloon."},
    {"skins": ["chart"], "if": {"done": "e06_taken"}, "point": [24.0, -4.0], "red": True,
     "text": "L.: they were made. I was wrong about the one thing that mattered."},
    {"skins": ["chart"], "if": {"done": "e06_taken"}, "point": [27.0, -12.0], "red": True,
     "text": "L.: the heat hurries them; the cold nights stop them."},
    {"skins": ["chart"], "if": {"done": "e11_spice"}, "point": [122.0, -6.0], "text": "Eggs from the Barra, by a Brazilian ship (V.)."},
    {"skins": ["chart"], "if": {"done": "e14_shore"}, "point": [137.0, -10.0], "text": "The Luanda hulk, ashore at last."},
]
for n in NOTES:
    n["act"] = 3

MOUNTAINS = [
    {"name": "Great Dividing Range", "line": [[145.4, -16.0], [146.4, -19.6], [148.0, -23.0], [150.6, -28.0], [151.6, -31.0],
                                              [150.2, -34.0], [148.8, -36.4], [146.4, -37.4]]},
    {"name": "Himalaya (east)", "line": [[78.0, 32.5], [81.0, 30.2], [84.0, 28.6], [88.0, 27.8], [92.0, 27.6], [95.0, 28.4]]},
    {"name": "Western Ghats", "line": [[73.4, 20.2], [73.8, 17.0], [74.4, 14.4], [75.4, 11.8], [76.8, 9.0]]},
    {"name": "Andes (south)", "line": [[-76.5, 5.0], [-78.0, 0.0], [-77.0, -6.0], [-74.0, -12.0], [-69.6, -17.0],
                                       [-68.0, -22.0], [-69.6, -28.0], [-70.4, -34.0], [-71.6, -40.0]]},
]


def tag(items):
    for x in items:
        x["act3"] = True
    return items


def main():
    d = json.load(open(PATH, encoding="utf-8"))
    for key in ("regions", "marks", "pins", "rules", "notes"):
        d[key] = [x for x in d.get(key, []) if not x.get("act3")]
    d["bounds"] = BOUNDS
    d["views"] = [v for v in d["views"] if not v.get("act3")]
    for v in d["views"]:
        if v["id"] in OLD_VIEWS_ACTS:
            v["acts"] = OLD_VIEWS_ACTS[v["id"]]
    d["views"] += tag(json.loads(json.dumps(VIEWS)))
    d["acts"] = [a for a in d.get("acts", []) if not a.get("act3")] + tag([
        {"if": START, "act": 3, "act_title": "Act 3: 2781-2790", "view": "globe"},
        {"if": {"done": NIGHT}, "act": 4, "act_title": "The present: 2795", "view": "europe3"},
    ])
    d["regions"] += tag(json.loads(json.dumps(REGIONS)))
    d["marks"] += tag(json.loads(json.dumps(MARKS)))
    d["pins"] += tag(json.loads(json.dumps(PINS)))
    d["rules"] += tag(json.loads(json.dumps(RULES)))
    d["notes"] += tag(json.loads(json.dumps(NOTES)))
    d["clock"] = CLOCK
    d["about"] = d["about"].replace("(docs/war_map_act2.md))", "(docs/war_map_act2.md); Act 3's world and THE CLOCK: docs/war_map_act3.md)")
    pt = d.pop("paintings", None)
    if pt is not None:
        d["paintings"] = pt
    with open(PATH, "w", encoding="utf-8") as f:
        json.dump(d, f, indent="\t", ensure_ascii=False)
        f.write("\n")
    m = json.load(open(MOUNT, encoding="utf-8"))
    names = {r["name"] for r in MOUNTAINS}
    m["ranges"] = [r for r in m["ranges"] if r["name"] not in names] + MOUNTAINS
    with open(MOUNT, "w", encoding="utf-8") as f:
        f.write('{\n\t"about": %s,\n\t"ranges": [\n' % json.dumps(m["about"], ensure_ascii=False))
        f.write(",\n".join("\t\t" + json.dumps(r, ensure_ascii=False) for r in m["ranges"]))
        f.write("\n\t]\n}\n")
    print("warmap.json: %d regions, %d marks, %d pins, %d rules, %d notes, %d views" % (len(d["regions"]), len(d["marks"]),
          len(d["pins"]), len(d["rules"]), len(d["notes"]), len(d["views"])))


if __name__ == "__main__":
    main()
