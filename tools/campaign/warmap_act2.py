#!/usr/bin/env python3
"""THE WAR MAP'S ACT 2 (job act2-warmap, docs/war_map_act2.md): writes Act 2's part of campaign/warmap.json.

The BRAZIL view, Act 2's regions (Minas, Bahia, the sertao, the lower Amazon, the Tapajos, the Barra, the southern
highlands, Concordia, the valley, Sao Paulo, Luanda, Goa), marks, the pins of d01-d13 (planned ones with working titles)
and their rules, the act's title, the skins' titles and the chart's and the brass map's notes. Every item it writes
carries "act2": true, so it can run again: it first takes its own items out, then puts them back (the pins and rules of
d02 and d03, written by their own builds, are left as they are; their rules keep running first).
    python3 tools/campaign/warmap_act2.py
Places are [lon, lat]; the projection is the file's (x = lon, y = -lat * 1.3). EVERY TEXT IS A PLACEHOLDER.
"""
import json, os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PATH = os.path.join(ROOT, "campaign/warmap.json")
MOUNT = os.path.join(ROOT, "campaign/warmap_mountains.json")

# the places (lon, lat)
VILA_RICA = [-43.5, -20.39]
SALVADOR = [-38.9, -12.9]       # (a step inland: the 1:50m coast)
FORT = [-43.14, -11.09]          # Fort Constantine (proposed): the crossroads of the Sao Francisco and the Rio Grande
CONCORDIA = [-51.6, -27.3]       # the southern highlands above the Rio Uruguai (proposed)
VALLEY = [-52.9, -27.6]
SAO_RAFAEL = [-55.7, -4.6]       # a week's paddle up the Tapajos (proposed)
OBIDOS = [-55.52, -1.9]
ISLAND = [-55.5, -1.95]          # d03's pin: Lindqvist's island below Obidos
BARRA = [-60.0, -3.1]
LUANDA = [13.23, -8.84]
GOA = [74.0, 15.4]
COAST = [-49.0, -26.4]          # Sao Francisco do Sul: the guild's landing, the honest masters' coast
QUEEN = [-57.4, 0.6]             # "beyond the map": the forest north of the river where nobody has been

VIEW = {"id": "brazil", "label": "BRAZIL", "rect": [-74.0, -34.0, -33.0, 6.0]}

REGIONS = [
    {"id": "lower_amazon", "name": "The lower Amazon", "label_at": [-55.2, -0.6],
     "poly": [-58.6, -0.6, -55.5, -0.2, -52.8, -0.4, -51.6, -1.2, -52.0, -3.0, -54.0, -3.15, -57.0, -3.0, -58.7, -2.4]},
    {"id": "island", "name": "Lindqvist's island", "label": False, "circle": [-55.35, -2.0, 0.32]},
    {"id": "tapajos", "name": "The Tapajós", "label_at": [-55.8, -5.6],
     "poly": [-57.6, -3.25, -54.0, -3.25, -53.6, -5.5, -54.5, -7.6, -57.0, -7.3, -58.1, -5.0]},
    {"id": "barra_rio_negro", "name": "The Barra", "label_at": [-60.7, -4.4],
     "poly": [-62.6, -1.6, -60.6, -1.8, -58.8, -2.5, -58.9, -3.9, -60.8, -4.1, -62.8, -3.2]},
    {"id": "minas", "name": "Minas Gerais", "label_at": [-45.0, -18.2],
     "poly": [-48.2, -15.6, -44.0, -15.2, -41.0, -16.0, -40.6, -18.2, -41.6, -21.4, -44.6, -22.6, -47.6, -21.6, -49.2, -18.6]},
    {"id": "bahia", "name": "Bahia", "label_at": [-40.0, -13.6],
     "poly": [-40.4, -10.2, -37.2, -10.6, -37.7, -12.6, -38.9, -15.9, -41.0, -15.4, -41.8, -13.4]},
    {"id": "sertao", "name": "The sertão", "label_at": [-44.2, -9.6],
     "poly": [-46.8, -8.4, -41.2, -8.5, -40.4, -10.2, -41.8, -13.4, -45.6, -14.0, -47.2, -11.2]},
    {"id": "sao_paulo", "name": "São Paulo", "label_at": [-48.6, -22.6],
     "poly": [-50.6, -20.6, -47.6, -21.6, -44.6, -22.6, -46.2, -24.2, -48.3, -25.3, -51.2, -24.0, -52.6, -22.2]},
    {"id": "highlands", "name": "The southern highlands", "label_at": [-50.6, -25.6],
     "poly": [-52.3, -25.9, -49.6, -25.9, -49.0, -27.0, -49.4, -28.4, -50.6, -28.9, -52.3, -28.5]},
    {"id": "valley", "name": "The valley", "label_at": [-53.1, -26.4],
     "poly": [-54.0, -26.7, -52.3, -26.8, -52.3, -28.5, -53.9, -28.4]},
    {"id": "concordia", "name": "Concórdia", "label": False, "circle": CONCORDIA + [0.42]},
    {"id": "luanda", "name": "Luanda", "label_at": [14.6, -9.6], "circle": [13.9, -9.0, 0.9]},
    {"id": "goa", "name": "Goa", "label_at": [74.9, 14.6], "circle": [74.1, 15.3, 0.7]},
]

MARKS = [
    {"id": "exodus_route", "kind": "route", "point": [9.99, 53.55], "label": "",
     "points": [[9.99, 53.55], [7.0, 54.3], [3.0, 52.6], [-1.5, 50.3], [-7.0, 48.2], [-14.0, 40.0], [-22.0, 18.0],
                [-29.0, 2.0], [-33.0, -10.0], [-41.0, -22.5], [-48.2, -26.2]]},
    {"id": "hamburg", "kind": "town", "point": [9.99, 53.55], "label": "Hamburg"},
    {"id": "varenne_route", "kind": "route", "point": [-14.0, 33.0], "label": "",
     "points": [[-14.0, 33.0], [-24.0, 12.0], [-31.0, -6.0], [-38.0, -20.0], [-47.6, -26.6], [-51.3, -27.2]]},
    {"id": "ramos_road", "kind": "route", "point": VILA_RICA, "label": "",
     "points": [VILA_RICA, [-46.0, -22.6], [-49.0, -25.0], [-51.3, -27.1]]},
    {"id": "concordia_city", "kind": "gear", "point": CONCORDIA, "label": "Concórdia"},
    {"id": "crates_mine", "kind": "dot", "point": [-51.15, -27.0], "label": "The old mine: the crates of 2767"},
    {"id": "honest_coast", "kind": "village", "point": COAST, "label": "The honest masters, at the coast"},
    {"id": "sao_rafael", "kind": "church", "point": SAO_RAFAEL, "label": "São Rafael"},
    {"id": "sao_rafael_burnt", "kind": "church_burnt", "point": SAO_RAFAEL, "label": "São Rafael, its fields burned"},
    {"id": "fazenda_burnt", "kind": "burnt", "point": ISLAND, "label": "The fazenda, fallen"},
    {"id": "queen", "kind": "queen", "point": QUEEN, "label": "The Queen: where nobody has been"},
    {"id": "fort", "kind": "fort", "point": FORT, "label": "Fort Constantine"},
    {"id": "salvador", "kind": "town", "point": SALVADOR, "label": "Salvador"},
    {"id": "siege_ring", "kind": "siege", "point": CONCORDIA, "label": "The siege lines"},
]

P = "planned"
PINS = [
    {"mission": "d01_minas", "line": "crown", "place": "Vila Rica", "date": "2772", "point": VILA_RICA,
     "title": "The Gold of Vila Rica", "after": ["a07_council"],
     "about": "Tomasz, a missionary in Brazil now, and the garrison stop the Free Assembly's rising in the gold town."},
    {"mission": "d04_concordia", "line": "clockmaker", "place": "The southern highlands", "date": "2773", "point": CONCORDIA,
     "nudge": [-18, -12], "title": "The City of Gears", "after": ["d02_exodus"],
     "about": "The guild founds a free city over an old mine; the valley below fears it from the first day."},
    {"mission": "d05_aldeia", "line": "crown", "place": "São Rafael, on the Tapajós", "date": "Wet season 2776",
     "point": SAO_RAFAEL, "title": "The Mission of São Rafael", "after": ["d01_minas"],
     "about": "The swarm comes out of the flooded forest at Tomasz's mission: bring the people to the river fort."},
    {"mission": "d06_queen", "line": "naturalist", "place": "The island", "date": "Wet season 2775", "point": ISLAND,
     "nudge": [-16, 14], "title": "The Queen", "after": ["d03_fazenda"],
     "about": "The flood comes to Lindqvist's island; in the pens the strongest Mother grows into a Queen."},
    {"mission": "d07_spring", "line": "clockmaker", "place": "Concórdia", "date": "2777", "point": CONCORDIA,
     "nudge": [18, -12], "title": "The Council of Gears", "after": ["d04_concordia"],
     "about": "The city's machines begin to vote through the masters who wind them. Hollweg at the great spring."},
    {"mission": "d08_rivers", "line": "naturalist", "place": "The Barra do Rio Negro", "date": "2778", "point": BARRA,
     "nudge": [0, 0], "title": "Down the Rivers", "after": ["d06_queen"],
     "about": "Valadares holds the Barra against the swarm in the floods and brings the people of Nazaré out."},
    {"mission": "d09_crossroads", "line": "all", "place": "The São Francisco", "date": "Dry season 2780", "point": FORT,
     "title": "Between Two Fires", "after": ["d05_aldeia", "d07_spring", "d08_rivers"],
     "about": "The army of Brazil marches to the fort at the crossroads; both fires find it. The Crown chooses which first."},
    {"mission": "d10_jungle", "line": "all", "place": "Óbidos", "date": "2780", "point": OBIDOS, "nudge": [14, -16],
     "title": "The Jungle Front", "after": ["d09_crossroads"],
     "about": "The army's jungle column breaks the swarm's nests on the river, Valadares leading it."},
    {"mission": "d11_siege", "line": "all", "place": "Concórdia's outer works", "date": "2780", "point": CONCORDIA,
     "nudge": [0, 16], "title": "The Siege of Concórdia", "after": ["d09_crossroads"],
     "about": "The army's southern column lays siege to the city of gears, Father Ferrer as Rome's witness."},
    {"mission": "d12_luanda", "line": "naturalist", "place": "Luanda", "date": "2777", "point": LUANDA,
     "title": "The Hold", "after": ["d06_queen"],
     "about": "Optional. Eggs found in a Brazilian ship's hold at Luanda: hunt what hatched before the tide takes it."},
    {"mission": "d13_goa", "line": "clockmaker", "place": "Goa", "date": "2779", "point": GOA,
     "title": "The Mining Machines", "after": ["d04_concordia"],
     "about": "Optional. Concórdia's mining machines wake in the Viceroy's arsenal at Goa, Father Ferrer arriving."},
]

PC = ["parchment", "chart"]     # the King's parchment and the Naturalist's chart know when the city turned; the brass map never shows it


def R(cond, **k):
    r = {"if": cond}
    r.update(k)
    return r


RULES = [
    # Act 2 begins: Brazil unrolled (Salvador, the colony's capital, on the map)
    R({"done": "a07_council"}, mark="salvador", show=True),
    # d02 (built): the guild's ships, Hamburg to the south (the line on the sea)
    R({"won_by": {"d02_exodus": "exodus"}}, marks=["exodus_route", "hamburg"], show=True),
    # d01 THE GOLD OF VILA RICA (planned: the plan's flags minas, gold, conspirator)
    R({"done": "d01_minas"}, region="minas", to="crown", ledger="The rising of the mines was broken at Vila Rica on the day of the tax."),
    R({"flag": {"d01_minas.minas": "quiet"}}, ledger="The clergy went house to house before the signal: Vila Rica is quiet."),
    R({"flag": {"d01_minas.minas": "restless"}}, region="minas", to="contested", ledger="Vila Rica is quiet only under the bayonet: the mines are restless."),
    R({"flag": {"d01_minas.gold": "all"}}, ledger="All of the Foundry House's gold reached the coast."),
    R({"flag": {"d01_minas.gold": "some"}}, ledger="Some of the Foundry House's gold reached the coast; the gorge took the rest."),
    R({"flag": {"d01_minas.gold": "few"}}, ledger="Little of the Foundry House's gold reached the coast."),
    R({"flag": {"d01_minas.conspirator": "taken"}}, ledger="The conspirators' leader was taken alive."),
    R({"flag": {"d01_minas.conspirator": "fled"}}, mark="ramos_road", show=True, ledger="The conspirators' leader escaped south, to the city of gears."),
    R({"won_by": {"d01_minas": "conspiracy"}}, region="minas", to="unrest", pin="d01_minas", seal="broken",
      ledger="The conspiracy took the Foundry House: not how it went."),
    # d04 THE CITY OF GEARS (planned: colonists parley / fought, crates opened)
    R({"won_by": {"d04_concordia": "guild"}}, region="concordia", to="guild", marks=["concordia_city", "crates_mine"], show=True,
      ledger="Hollweg founded Concórdia on the southern highlands: a city that governs itself."),
    R({"done": "d04_concordia", "flag": {"a06_barricades.varenne": "spared"}}, mark="varenne_route", show=True,
      ledger="Varenne's ship of exile ended at Concórdia: he speaks for the city now."),
    R({"flag": {"d04_concordia.colonists": "parley"}}, ledger="The valley's captain parleyed with Hollweg on the road."),
    R({"flag": {"d04_concordia.colonists": "fought"}}, region="valley", to="contested", ledger="The valley fought the city from its first day."),
    R({"flag": {"d04_concordia.crates": "opened"}}, ledger="In the mine Hollweg opened the two crates of 2767."),
    R({"won_by": {"d04_concordia": "valley"}}, pin="d04_concordia", seal="broken",
      ledger="The valley burned the city's first quarter: not how it went."),
    # d05 THE MISSION OF SAO RAFAEL (planned: fields burned / left, aldeia few / some / many)
    R({"done": "d05_aldeia"}, mark="sao_rafael", show=True),
    R({"flag": {"d05_aldeia.fields": "left"}}, region="tapajos", to="brood",
      ledger="Tomasz left the fields standing for the people's return: the swarm fed on them."),
    R({"flag": {"d05_aldeia.fields": "burned"}}, region="tapajos", to="contested", marks=["sao_rafael_burnt"], show=True,
      ledger="The fields and the granary of São Rafael were burned: the swarm found nothing to eat."),
    R({"flag": {"d05_aldeia.fields": "burned"}}, mark="sao_rafael", show=False),
    R({"flag": {"d05_aldeia.aldeia": "many"}}, ledger="Most of São Rafael's people reached the river fort."),
    R({"flag": {"d05_aldeia.aldeia": "some"}}, ledger="Some of São Rafael's people reached the river fort."),
    R({"flag": {"d05_aldeia.aldeia": "few"}}, ledger="Few of São Rafael's people reached the river fort."),
    R({"won_by": {"d05_aldeia": "swarm"}}, region="tapajos", to="brood", pin="d05_aldeia", seal="broken",
      ledger="The swarm broke the church of São Rafael before the people reached the fort."),
    # d06 THE QUEEN (planned: brood_n few / some / all, pieter alive / lost)
    R({"done": "d06_queen"}, region="island", to="brood", marks=["fazenda_burnt", "queen"], show=True,
      ledger="The fazenda fell in a night of flood. In its pens the strongest Mother grew into a Queen, and every bred creature turned to it."),
    R({"done": "d06_queen"}, region="lower_amazon", to="contested"),
    R({"done": "d06_queen"}, mark="fazenda", show=False),
    R({"flag": {"d06_queen.brood_n": "all"}}, ledger="Nearly all of the bred creatures went to the Queen."),
    R({"flag": {"d06_queen.brood_n": "some"}}, ledger="Some of the bred creatures went to the Queen."),
    R({"flag": {"d06_queen.brood_n": "few"}}, ledger="Few of the bred creatures went to the Queen: Lindqvist burned the rest."),
    R({"flag": {"d06_queen.pieter": "lost"}}, ledger="Pieter did not reach the canoes."),
    # d07 THE COUNCIL OF GEARS (built, d07-spring: spring stopped / running, honest few / some / many; a machine win canon-compatible: a count, no broken seal)
    R({"flag": {"d07_spring.spring": "running"}}, ledger="The great spring was left running: the city ran on, and Hollweg called it saved."),
    R({"flag": {"d07_spring.spring": "stopped"}}, region="concordia", to="machine", skins=PC, marks=["honest_coast"], show=True,
      ledger="Hollweg stopped the great spring: the city is dead brass; the honest masters went to the coast."),
    R({"flag": {"d07_spring.honest": "many"}}, ledger="Most of the honest masters stood with Hollweg."),
    R({"flag": {"d07_spring.honest": "some"}}, ledger="Some of the honest masters stood with Hollweg."),
    R({"flag": {"d07_spring.honest": "few"}}, ledger="Few of the honest masters stood with Hollweg."),
    R({"won_by": {"d07_spring": "machine"}}, ledger="The machine meshed the council hall before dawn."),
    # d08 DOWN THE RIVERS (built: docs/campaign_d08_build.md; lure burned / used, barra held / burned, nazare few / some / all)
    R({"done": "d08_rivers"}, region="upper_rio_negro", to="brood", ledger="The swarm came down the rivers in the floods; the towns above the Barra are empty."),
    R({"flag": {"d08_rivers.barra": "held"}}, region="barra_rio_negro", to="crown", ledger="Valadares held the Barra, every quarter standing."),
    R({"flag": {"d08_rivers.barra": "burned"}}, region="barra_rio_negro", to="contested", ledger="Valadares held the bluff, but the Barra's lower town burned."),
    R({"flag": {"d08_rivers.lure": "burned"}}, ledger="The lure book was burned, as Rome ordered."),
    R({"flag": {"d08_rivers.lure": "used"}}, ledger="The lure book was used once, to draw the great wave into the flooded forest."),
    R({"flag": {"d08_rivers.nazare": "all"}}, ledger="All of Nazaré was brought down the river."),
    R({"flag": {"d08_rivers.nazare": "some"}}, ledger="Some of Nazaré was brought down the river."),
    R({"flag": {"d08_rivers.nazare": "few"}}, ledger="Few of Nazaré's people were brought down the river."),
    R({"done": "d08_rivers"}, mark="nazare", show=False),
    R({"won_by": {"d08_rivers": "swarm"}}, region="barra_rio_negro", to="brood", pin="d08_rivers", seal="broken",
      ledger="The swarm took the Barra's bluff and its guns: not how it went."),
    # d09 BETWEEN TWO FIRES (built: docs/campaign_d09_build.md; first brood / clockwork (no canon: the player chooses), sertao
    # few / some / many, fort held; a versus friend's win (the magazine blown): not how it went, the seal broken)
    R({"done": "d09_crossroads"}, region="sertao", to="crown", mark="fort", show=True,
      ledger="The army of Brazil relieved the fort at the crossroads of the São Francisco."),
    R({"flag": {"d09_crossroads.first": "brood"}}, ledger="Ruggieri chose the swarm first: the army went up the rivers."),
    R({"flag": {"d09_crossroads.first": "clockwork"}}, ledger="Ruggieri chose the city first: the army went south to the highlands."),
    R({"flag": {"d09_crossroads.sertao": "many"}}, ledger="Most of the road's villages came into the fort."),
    R({"flag": {"d09_crossroads.sertao": "some"}}, ledger="Some of the road's villages came into the fort."),
    R({"flag": {"d09_crossroads.sertao": "few"}}, ledger="Few of the road's villages came into the fort."),
    R({"done": "d09_crossroads", "flag": {"d07_spring.spring": "running"}}, region="concordia", to="machine", skins=PC,
      ledger="The army's scouts saw it from the road: Concórdia is the machine's."),
    R({"won_by": {"d09_crossroads": "creatures"}}, pin="d09_crossroads", seal="broken",
      ledger="The swarm blew the fort's magazine at the crossroads: not how it went."),
    R({"won_by": {"d09_crossroads": "automata"}}, pin="d09_crossroads", seal="broken",
      ledger="The machines blew the fort's magazine at the crossroads: not how it went."),
    # the diamond's "first" clock: the front not chosen waits, and grows
    R({"flag": {"d09_crossroads.first": "brood"}, "not_done": "d11_siege"}, pin="d11_siege",
      clock="Not yet: the army is in the north, and the city is building."),
    R({"flag": {"d09_crossroads.first": "clockwork"}, "not_done": "d10_jungle"}, pin="d10_jungle",
      clock="Not yet: the army is in the south, and the swarm is spreading."),
    # d10 THE JUNGLE FRONT (built: docs/campaign_d10_build.md; jungle held / thin, island burned / standing, reclaim barra
    # (the RECLAIM PART won: d08's broken seal mends); a swarm's win (the solo pick or versus): not how it went, a broken seal)
    R({"flag": {"d10_jungle.jungle": "held"}}, region="lower_amazon", to="contested", ledger="The swarm's nests on the river were broken in time: the river towns hold."),
    R({"flag": {"d10_jungle.jungle": "thin"}}, region="lower_amazon", to="brood", ledger="The nests were broken too late: the lower river is the swarm's."),
    R({"flag": {"d10_jungle.island": "burned"}}, ledger="The swarm's oldest ground on Lindqvist's island was burned with the fazenda's ruins."),
    R({"flag": {"d10_jungle.reclaim": "barra"}}, pin="d08_rivers", seal="seal", region="barra_rio_negro", to="contested",
      ledger="Óbidos' upriver battery was taken back from the swarm: the Barra's survivors hold it."),
    R({"won_by": {"d10_jungle": "swarm"}}, region="lower_amazon", to="brood", pin="d10_jungle", seal="broken",
      ledger="The swarm held the river till the dry season: not how it went."),
    # d11 THE SIEGE OF CONCORDIA (planned: siege close / held_off, jakob alive / lost)
    R({"flag": {"d11_siege.siege": "close"}}, region="concordia", to="machine", skins=PC, mark="siege_ring", show=True,
      ledger="The great spring's tower was blown from the old mine: the city is crippled and besieged."),
    R({"flag": {"d11_siege.siege": "held_off"}}, region="concordia", to="machine", skins=PC,
      ledger="The army holds the road, but the city stands whole behind its walls."),
    R({"flag": {"d11_siege.siege": "held_off"}}, region="valley", to="contested"),
    R({"flag": {"d11_siege.jakob": "lost"}}, ledger="Jakob fell before the walls of Concórdia."),
    R({"won_by": {"d11_siege": "city"}}, region="concordia", to="machine", skins=PC, pin="d11_siege", seal="broken",
      ledger="The city broke the siege's batteries: not how it went."),      # (d11-siege: a city's win is not the King's story)
    # d12 THE HOLD (planned, optional: luanda clean / escaped)
    R({"flag": {"d12_luanda.luanda": "clean"}}, region="luanda", to="crown", ledger="Every egg in the hold at Luanda was found and burned."),
    R({"flag": {"d12_luanda.luanda": "escaped"}}, region="luanda", to="contested",
      ledger="Some of the eggs at Luanda were carried off by the tide: the first of the Brood in Africa."),
    # d13 THE MINING MACHINES (planned, optional: goa_seed smashed / shipped)
    R({"flag": {"d13_goa.goa_seed": "smashed"}}, region="goa", to="crown", ledger="The mining machines at Goa were smashed in the Viceroy's arsenal."),
    R({"flag": {"d13_goa.goa_seed": "shipped"}}, region="goa", to="contested",
      ledger="Some of the mining machines were shipped on from Goa: the first seed in Asia."),
]

NOTES = [
    # THE SPECIMEN CHART (the Naturalist's: Lindqvist's, then Valadares'): notes in the margins, in ink and pencil
    {"skins": ["chart"], "if": {}, "point": [-38.5, -2.0], "text": "Specimen notes: where the floods go, the creatures go."},
    {"skins": ["chart"], "if": {"done": "b01_specimen"}, "point": [-64.3, -0.1], "text": "The station. Burnt, Saint John's Eve 2767."},
    {"skins": ["chart"], "if": {"flag": {"a03_plateau.map": "drawn"}}, "point": [-65.7, 2.3], "text": "The nest, drawn by Valadares."},
    {"skins": ["chart"], "if": {"done": "d03_fazenda"}, "point": [-54.4, -1.3], "text": "The pens, kept against Rome's verdict."},
    {"skins": ["chart"], "if": {"done": "d06_queen"}, "point": [-57.2, 1.4], "text": "Something roots here. No one has gone to look."},
    {"skins": ["chart"], "if": {"done": "d08_rivers"}, "point": [-61.2, -4.6], "text": "Their ground creeps in the flood: a mile a week (V.)."},
    # THE BRASS MAP (the Clockmaker's, Hollweg's): words engraved on the plate
    {"skins": ["brass"], "if": {"done": "c01_thirteenth"}, "point": [11.6, 50.0], "text": "Nuremberg, Advent 2767."},
    {"skins": ["brass"], "if": {"won_by": {"d02_exodus": "exodus"}}, "point": [-47.4, -25.0], "text": "Landed, 2771."},
    {"skins": ["brass"], "if": {"done": "d04_concordia"}, "point": [-50.4, -27.9], "text": "CONCORDIA. Founded 2773."},
]

MOUNTAINS = [
    {"name": "Serra do Mar", "line": [[-49.0, -25.6], [-47.6, -24.6], [-46.0, -23.8], [-44.6, -23.0], [-43.2, -22.5]]},
    {"name": "Serra da Mantiqueira", "line": [[-46.4, -22.9], [-44.8, -22.2], [-43.6, -21.4]]},
    {"name": "Espinhaço", "line": [[-43.7, -20.6], [-43.6, -19.0], [-43.3, -17.4], [-42.8, -15.6], [-42.2, -13.6], [-41.6, -11.8]]},
    {"name": "Serra Geral", "line": [[-49.8, -28.6], [-50.4, -27.6], [-50.8, -26.4], [-51.2, -25.6]]},
    {"name": "Guiana highlands", "line": [[-64.0, 4.2], [-61.6, 4.6], [-59.4, 3.2], [-57.0, 2.4], [-55.0, 2.2]]},
]


def tag(items):
    for x in items:
        x["act2"] = True
    return items


def main():
    d = json.load(open(PATH, encoding="utf-8"))
    for key in ("regions", "marks", "pins", "rules", "notes"):
        d[key] = [x for x in d.get(key, []) if not x.get("act2")]
    d["views"] = [v for v in d["views"] if v["id"] != "brazil"]
    d["views"].insert(1, VIEW)
    d["holders"]["guild"] = "The free city (the guild's)"
    d["acts"] = [{"if": {"done": "a07_council"}, "act": 2, "act_title": "Act 2: 2771-2780", "view": "brazil"}]
    d["skins"] = {"parchment": {"title": "THE WAR MAP"}, "brass": {"title": "THE BRASS MAP"}, "chart": {"title": "THE SPECIMEN CHART"}}
    d["about"] = d["about"].replace("the Clockmaker's brass map and the Naturalist's specimen chart later read the same",
                                    "the Clockmaker's brass map and the Naturalist's specimen chart read the same (docs/war_map_act2.md)")
    d["regions"] += tag(json.loads(json.dumps(REGIONS)))
    d["marks"] += tag(json.loads(json.dumps(MARKS)))
    d["pins"] += tag(json.loads(json.dumps(PINS)))
    d["rules"] += tag(json.loads(json.dumps(RULES)))
    d["notes"] = tag(json.loads(json.dumps(NOTES)))
    # (keep "paintings" last, as the fit tool writes it)
    pt = d.pop("paintings", None)
    if pt is not None:
        d["paintings"] = pt
    with open(PATH, "w", encoding="utf-8") as f:
        json.dump(d, f, indent="\t", ensure_ascii=False)
        f.write("\n")
    m = json.load(open(MOUNT, encoding="utf-8"))
    names = {r["name"] for r in MOUNTAINS}
    m["ranges"] = [r for r in m["ranges"] if r["name"] not in names] + MOUNTAINS
    with open(MOUNT, "w", encoding="utf-8") as f:      # (one range a line, as the file was written by hand)
        f.write('{\n\t"about": %s,\n\t"ranges": [\n' % json.dumps(m["about"], ensure_ascii=False))
        f.write(",\n".join("\t\t" + json.dumps(r, ensure_ascii=False) for r in m["ranges"]))
        f.write("\n\t]\n}\n")
    print("warmap.json: %d regions, %d marks, %d pins, %d rules, %d notes" % (len(d["regions"]), len(d["marks"]), len(d["pins"]),
          len(d["rules"]), len(d["notes"])))


if __name__ == "__main__":
    main()
