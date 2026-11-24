#!/usr/bin/env python3
"""Writes campaign/missions/d09_crossroads.json: Act 2's SECOND CROSSING, "Between Two Fires" (Bahia to the São Francisco,
the dry season 2780; the army of Brazil under General Ruggieri; Father Tomasz tells it, the King frames it and, at the
choice, stops to ask the listener; the plan: docs/campaign_act2_plan.md "d09_crossroads"; what was built:
docs/campaign_d09_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d09_crossroads.txt: every text here is
written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d09_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_sao_francisco_map.py (campaign:sao_francisco: the sertão). EVERY LINE IS A PLACEHOLDER for
the owner to rewrite.

THE BROOD IS NOT A PERSON (owner 2026-11-19 / 2026-11-22 / 2026-11-24): the creatures hunt and feed; no line gives one a
name, a reason, a want or a plan. The machines are not people either: nobody here knows who sent them (Varenne least).
  THE ARMY OF BRAZIL (Crown, PURPLE, p1): GENERAL RUGGIERI (a hero), FATHER TOMASZ (the frontier's vicar general, a hero),
    Musketeers with THE ROSTER LADDER's C5 kit (Matchlock, Socket Bayonet), Dragoons and the Cavalry Charge (C6), two
    Field Cannons and a Mortar; NEW (C7): ARMOUR (Guardsmen and Cuirassiers) and the POWDER WAGON (a march with no base:
    the wagons refill the line). The VIRGINIA VOLUNTEERS with Sergeant Hollins by p01 `families` save (the canon).
  THE FORT'S GARRISON (Crown, BLUE: co-op p2, else scripted at the gates): Major Teixeira (proposed) and his men; the
    fort's chapel and MAGAZINE. The army's own depot in the fort: Barracks, Foundry, Armoury, Horse Breeder, quarters.
  THE PEOPLE OF THE ROAD (YELLOW, scripted): the sertanejos of two villages, Riacho Seco and Lagoa Branca (proposed):
    they join the column when the army reaches them and follow Father Tomasz to the fort.
  THE CREATURES (Brood, GREEN) from the north-west and THE AUTOMATA (Clockwork, RED) from the south-west: scripted, or ONE
    of them the versus friend's pick (a07's VERSUS PICK). They fight each other where they meet (two sides, both hostile).
  PART 1, THE ROAD: the march west with no base (the wagons); two skies over the road (Hatchlings and Swifts, fighting
    each other); the villages' people into the column; Raptors at Riacho Seco, a column of machines at Lagoa Branca, owls
    on the wagons, Raptors between the army and the fort. The fort holds out on a countdown.
  PART 2, THE FORT: both besiege it at once, the creatures at the north gate, the machines at the south gate, three
    waves each; at the ford under the west wall they meet and tear at each other. Relieve it.
  PART 3, THE COUNCIL OF WAR: a mid-match show (solo pauses): the frontier's rider (by d05 `fields`, d08 `barra` /
    `lure`), the city's envoy (VARENNE under a white flag by a06 `varenne` spared; executed: a letter nailed to the
    ford's post), Tomasz's counsel, Ruggieri. THE FRAME AT THE CHOICE: the King stops and asks the listener. THE CHOICE,
    WHICH FIRE FIRST (no canon: the player chooses, owner 2026-11-22). Then the night: the fire NOT chosen strikes the
    fort first; hold it to dawn.
  CARRIES: `first` brood / clockwork (FRESH or GROWN for d10_jungle / d11_siege), `fort` held, `sertao` few / some / many
    (the road's people in the fort, as a share of all).
  VERSUS (the friend picks the creatures or the automata): its side's forces and waves are the friend's; it wins by
    breaking the fort's magazine before dawn. Not how it went: the war map's seal broken.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d09_crossroads"

TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d09_crossroads.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


# ---------------------------------------------------------------- the flags read (missing = the canon)
VOL = {"not": past("p01_leaf.families", "leave")}         # p01: the families saved: the Virginia volunteers march
PARIS = past("a06_barricades.paris", "stood")             # a06: the colours blessed at Notre-Dame (a line)
SPARED = {"not": past("a06_barricades.varenne", "executed")}   # a06: Varenne the city's envoy under a white flag
EXECUTED = past("a06_barricades.varenne", "executed")     # a06: a letter nailed to the ford's post
MANY = past("a07_council.people", "many")                 # a07: the road's villages trust the priest (a line)
FIELDS_BURNED = past("d05_aldeia.fields", "burned")       # d05: the swarm starved on the Tapajós (the rider; waves no bigger)
FIELDS_LEFT = {"not": FIELDS_BURNED}                      # d05 canon: the swarm fed (one Raptor more in the siege's waves)
SPRING_STOPPED = past("d07_spring.spring", "stopped")     # d07: the city stopped: dead brass (the machines' waves smaller)
SPRING_RUNNING = {"not": SPRING_STOPPED}
HONEST_MANY = past("d07_spring.honest", "many")           # d07: the honest masters stood with Hollweg (a line)
BARRA_BURNED = past("d08_rivers.barra", "burned")         # d08: the Barra's lower town burned (the rider)
BARRA_HELD = {"not": BARRA_BURNED}
LURE_USED = past("d08_rivers.lure", "used")               # d08: the lure used once (the rider)
B_FEW = past("d06_queen.brood_n", "few")                  # d06: the swarm smaller
B_ALL = past("d06_queen.brood_n", "all")                  # d06: the swarm bigger
NOT_FEW = {"not": B_FEW}
CROWN = {"playing": "crown"}
CRE_P = {"playing": "creatures"}           # the versus friend leads the creatures
AUT_P = {"playing": "automata"}            # ... or the automata
NO_CRE = {"not": CRE_P}
NO_AUT = {"not": AUT_P}
FIRST_BROOD = {"flag": {"first": "brood"}}        # the swarm chosen first: the machines strike the fort tonight
FIRST_CLOCK = {"flag": {"first": "clockwork"}}    # the city chosen first: the swarm strikes the fort tonight
NAMED = {"heir": "named"}                         # THE FRAME's listener named (campaign.json "heir"; the owner: unseen)
ENDED = [{"fired": "the_end"}, {"fired": "lost_mag"}, {"fired": "f_won"}]
LIVE = {"not": {"any": ENDED}}
P1 = {"not": {"fired": "part2"}}
P2 = {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}]}
P3 = {"fired": "part3"}

# ---------------------------------------------------------------- numbers (NORMAL; EASY / HARD: the mission's "difficulty",
# clocks x1.25 / x0.85, the raids x0.7 / x1.4)
FORT_SECS = 330           # Part 1: the fort holds out this long before the siege begins without the army
SIEGE_SECS = 240          # Part 2: at dusk what is left of both draws back anyway
NIGHT_SECS = 125          # Part 3: the night to hold (the same on every difficulty: a longer night is no easier)
JOIN = 6                  # tiles: one of the army this near a village's people: they join the column
PEOPLE_PACE = 0.75        # the people walk carrying water and children (a Labourer's pace times this): a little under a Musketeer's
GOLD, POWDER = 300, 160
PAY_CHEST = 300           # at the fort: the army's pay chest (reinforcements before the night)
FRIEND_EVERY = 10         # versus: the friend's side's supplies (food / cogs) this often

# ================================================================== the units
ARMY = {"team": "army", "at": "road_start", "fixed": True}
units = [
    # ---- the army of Brazil (the player)
    dict(ARMY, kind="dismounted", **{"as": "ruggieri_general", "count": 1, "tag": "ruggieri", "tags": ["leaders"]}),
    dict(ARMY, kind="missionary", **{"as": "tomasz_vicar", "count": 1, "tag": "tomasz", "tags": ["leaders"]}),
    dict(ARMY, kind="musketeer", count=6, tag="line", kit={"lock": "matchlock", "bayonet": True}),
    # NEW (C7): ARMOUR: Guardsmen (Musketeers in breastplates) and Cuirassiers (Horsemen in cuirasses)
    dict(ARMY, kind="musketeer", count=4, tag="line", tags=["armoured"], kit={"armour": True, "lock": "matchlock", "bayonet": True}),
    dict(ARMY, kind="dragoon", count=3, tag="riders"),
    dict(ARMY, kind="cuirassier", count=3, tag="riders", tags=["armoured"], kit={"armour": True}),
    dict(ARMY, kind="cannon", count=2, tag="guns"),
    dict(ARMY, kind="mortar", count=1, tag="guns"),
    # NEW (C7): THE POWDER WAGON: the march has no Mill
    dict(ARMY, kind="powder_wagon", count=2, tag="wagons"),
    # the Virginia volunteers (p01 `families` save, the canon)
    dict(ARMY, kind="musketeer", **{"as": "hollins_sergeant", "count": 1, "tag": "hollins", "tags": ["line", "volunteers"], "if": VOL,
                                    "kit": {"lock": "matchlock", "bayonet": True}}),
    dict(ARMY, kind="musketeer", **{"as": "volunteer", "count": 4, "tag": "volunteers", "tags": ["line"], "if": VOL,
                                    "kit": {"lock": "matchlock", "bayonet": True}}),
    # ---- the fort's garrison (co-op p2): at the gates
    {"team": "fort", "kind": "dismounted", "as": "fort_commander", "count": 1, "at": "fort_mid", "tag": "commander", "fixed": True},
    {"team": "fort", "kind": "musketeer", "count": 4, "at": "north_in", "tag": "garrison", "tags": ["garrison_n"], "fixed": True, "order": "hold"},
    {"team": "fort", "kind": "musketeer", "count": 4, "at": "south_in", "tag": "garrison", "tags": ["garrison_s"], "fixed": True, "order": "hold"},
    {"team": "fort", "kind": "cannon", "count": 1, "at": "fort_mid", "tag": "garrison", "tags": ["fort_gun"], "fixed": True},
    # ---- the people of the road (YELLOW): two villages
    {"team": "sertao", "kind": "labourer", "as": "sertanejo", "count": 8, "at": "riacho_in", "tag": "folk_v1", "tags": ["people"], "fixed": True},
    {"team": "sertao", "kind": "labourer", "as": "sertanejo", "count": 8, "at": "lagoa_in", "tag": "folk_v2", "tags": ["people"], "fixed": True},
]

# the fort's palisade (cells): north and south walls with a gate gap each, the east wall with the road's gap, the west
# wall whole (the river under it)
FX0, FY0, FX1, FY1 = 26, 38, 48, 58
WALL = [(x, FY0) for x in range(FX0, FX1 + 1) if not 35 <= x <= 38] + [(x, FY1) for x in range(FX0, FX1 + 1) if not 35 <= x <= 38] \
    + [(FX0, y) for y in range(FY0 + 1, FY1)] + [(FX1, y) for y in range(FY0 + 1, FY1) if not 46 <= y <= 50]

QUARTERS = T("The army's quarters", "Os quartéis do exército", "Los cuarteles del ejército")
buildings = [
    # the fort's own: its MAGAZINE (the fort stands or falls with it) and its chapel
    {"team": "fort", "kind": "powder_mill", "at": [37, 47], "tag": "magazine",
     "name": T("The fort's magazine", "O paiol do forte", "El polvorín del fuerte")},
    {"team": "fort", "kind": "church", "at": [28, 46], "tag": "chapel",
     "name": T("The fort's chapel", "A capela do forte", "La capilla del fuerte")},
    # the army's depot in the fort (Ruggieri's: built the year before for this march)
    {"team": "army", "kind": "barracks", "at": [28, 40], "tag": "depot", "tags": ["f_barracks"],
     "name": T("The fort's barracks", "O quartel do forte", "El cuartel del fuerte")},
    {"team": "army", "kind": "armoury", "at": [42, 40], "tag": "depot", "tags": ["f_armoury"],
     "name": T("The fort's armoury", "O arsenal do forte", "La armería del fuerte")},
    {"team": "army", "kind": "foundry", "at": [28, 53], "tag": "depot", "tags": ["f_foundry"],
     "name": T("The fort's foundry", "A fundição do forte", "La fundición del fuerte")},
    {"team": "army", "kind": "horse_breeder", "at": [43, 53], "tag": "depot", "tags": ["f_breeder"],
     "name": T("The fort's horse lines", "As cavalariças do forte", "Las caballerizas del fuerte")},
] + [
    {"team": "army", "kind": "cottage", "at": list(c), "tag": "depot", "tags": ["quarters"], "name": QUARTERS}
    for c in [(32, 40), (39, 40), (32, 56), (39, 56), (44, 44), (44, 50)]
] + [
    {"team": "fort", "kind": "wall", "at": list(c), "tag": "palisade",
     "name": T("Fort Constantine's palisade", "A paliçada do Forte Constantino", "La empalizada del Fuerte Constantino")} for c in WALL
]

E = 24       # (the map draws everything east of the fort's ground 24 cells farther east: make_sao_francisco_map.py's `ex`)
areas = dict(
    # the road
    road_start=[124, 42, 10, 12], riacho=[96, 33, 16, 12], riacho_in=[101, 37, 6, 4], lagoa=[64, 55, 16, 12], lagoa_in=[69, 59, 6, 4],
    road_mid=[84, 46, 8, 8], road_west=[56, 45, 8, 8], fort_approach=[40, 40, 16, 16],
    # the fort
    fort=[FX0, FY0, FX1 - FX0 + 1, FY1 - FY0 + 1], fort_in=[29, 43, 15, 10], fort_mid=[33, 46, 8, 4], fort_wide=[20, 28, 36, 42],
    north_in=[34, 39, 6, 3], south_in=[34, 55, 6, 3], north_gate=[33, 34, 8, 4], south_gate=[33, 59, 8, 4],
    north_out=[30, 26, 14, 7], south_out=[30, 63, 14, 7], east_gate=[47, 45, 4, 7],
    # the river: the fords and the ford's post
    ford=[12, 44, 9, 8], ford_east=[21, 44, 5, 8], ford_post=[23, 50, 3, 3], north_ford=[13, 11, 9, 6], south_ford=[13, 79, 9, 6],
    # beyond the river: the two raiding bands' banks, the trails
    nw_camp=[2, 3, 11, 10], sw_camp=[2, 83, 11, 10], nw_trail=[4, 22, 8, 8], sw_trail=[4, 66, 8, 8],
    # where the raids come out on the road
    north_scrub=[88, 8, 14, 10], south_scrub=[62, 76, 16, 10], west_scrub=[50, 26, 12, 8],
    sky_nw=[66, 1, 16, 6], sky_sw=[78, 88, 16, 6], sky_meet=[106, 38, 10, 10],
)
areas = {k: ([v[0] + E] + v[1:] if v[0] >= 50 else v) for k, v in areas.items()}
areas["fort_approach"] = [48, 40, 18, 16]      # (the ground before the east gate)
areas["dry_stretch"] = [58, 44, 16, 10]       # (the long dry stretch between Lagoa Branca and the fort)
areas["south_dry"] = [60, 66, 12, 8]          # (a dry wash south of it: the machines' second raid)

# ================================================================== the objectives
objectives = [
    # ---- the army (the Crown)
    {"id": "magazine", "side": "crown", "primary": True, "kind": "protect", "tag": "magazine",
     "text": T("Fort Constantine's magazine must stand.", "O paiol do Forte Constantino tem de ficar de pé.", "El polvorín del Fuerte Constantino debe seguir en pie.")},
    {"id": "march", "side": "crown", "primary": True, "kind": "manual",
     "text": T("THE ROAD: march the army west along the road to Fort Constantine on the São Francisco. There is no Mill on the road: your powder is in the two wagons.",
               "A ESTRADA: leve o exército para oeste pela estrada até ao Forte Constantino, no São Francisco. Não há Moinho na estrada: a sua pólvora vai nas duas carroças.",
               "EL CAMINO: lleva al ejército hacia el oeste por el camino hasta el Fuerte Constantino, en el São Francisco. No hay Molino en el camino: tu pólvora va en los dos carros."),
     "phone": T("March west to Fort Constantine. Your powder is in the wagons.", "Marche para oeste até ao Forte Constantino. A pólvora vai nas carroças.",
                "Marcha al oeste hasta el Fuerte Constantino. La pólvora va en los carros.")},
    {"id": "fort_clock", "side": "crown", "primary": False, "kind": "countdown", "clock": "fort",
     "text": T("The fort holds out for {clock:fort}.", "O forte aguenta {clock:fort}.", "El fuerte aguanta {clock:fort}.")},
    {"id": "people", "side": "crown", "primary": False, "kind": "manual",
     "text": T("THE PEOPLE OF THE ROAD: the two villages' people join the column when your men reach them, and follow Father Tomasz. Keep him with the army. In the fort {in_fort} of {people_n}.",
               "O POVO DA ESTRADA: o povo das duas aldeias junta-se à coluna quando os seus homens lá chegam, e segue o Padre Tomasz. Mantenha-o com o exército. No forte {in_fort} de {people_n}.",
               "EL PUEBLO DEL CAMINO: la gente de las dos aldeas se une a la columna cuando llegan tus hombres, y sigue al Padre Tomasz. Mantenlo con el ejército. En el fuerte {in_fort} de {people_n}."),
     "phone": T("The villagers follow Father Tomasz: in the fort {in_fort} of {people_n}.", "Os aldeões seguem o Padre Tomasz: no forte {in_fort} de {people_n}.",
                "Los aldeanos siguen al Padre Tomasz: en el fuerte {in_fort} de {people_n}.")},
    {"id": "owls", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Shoot down the brass owls before they reach the powder wagons.", "Abata as corujas de latão antes que cheguem às carroças de pólvora.",
               "Derriba a los búhos de latón antes de que lleguen a los carros de pólvora.")},
    {"id": "siege", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE FORT: drive both off: the creatures at the north gate, the machines at the south gate. Split your guns. Round the fort: {siege_left}.",
               "O FORTE: afaste os dois: as criaturas no portão norte, as máquinas no portão sul. Divida os canhões. À volta do forte: {siege_left}.",
               "EL FUERTE: echa a los dos: las criaturas en la puerta norte, las máquinas en la puerta sur. Divide los cañones. Alrededor del fuerte: {siege_left}."),
     "phone": T("Drive both off the fort: north gate the creatures, south gate the machines ({siege_left} left).",
                "Afaste os dois do forte: portão norte as criaturas, portão sul as máquinas ({siege_left} restam).",
                "Echa a los dos del fuerte: puerta norte las criaturas, puerta sur las máquinas ({siege_left} quedan).")},
    {"id": "siege_clock", "side": "crown", "primary": False, "kind": "countdown", "clock": "siege", "hidden": True,
     "text": T("Dusk in {clock:siege}.", "Anoitece em {clock:siege}.", "Anochece en {clock:siege}.")},
    {"id": "night", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE NIGHT: the fire you did not choose strikes the fort first. Hold it until dawn. The fort's Barracks and Foundry are yours: train what the pay chest allows.",
               "A NOITE: o fogo que não escolheu ataca o forte primeiro. Aguente até ao amanhecer. O Quartel e a Fundição do forte são seus: treine o que o cofre do soldo permitir.",
               "LA NOCHE: el fuego que no elegiste ataca primero el fuerte. Resiste hasta el alba. El Cuartel y la Fundición del fuerte son tuyos: entrena lo que permita el cofre de la paga."),
     "phone": T("Hold the fort until dawn.", "Aguente o forte até ao amanhecer.", "Resiste en el fuerte hasta el alba.")},
    {"id": "dawn", "side": "crown", "primary": False, "kind": "countdown", "clock": "dawn", "hidden": True,
     "text": T("Dawn in {clock:dawn}.", "Amanhece em {clock:dawn}.", "Amanece en {clock:dawn}.")},
    # ---- the versus friend (the creatures or the automata)
    {"id": "c_raid", "side": "creatures", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE RAID: break Fort Constantine's magazine (in the fort's middle) before dawn. More of the swarm comes over the north ford as the day goes.",
               "O ASSALTO: derrube o paiol do Forte Constantino (no meio do forte) antes do amanhecer. Mais do enxame vem pelo vau do norte ao longo do dia.",
               "EL ASALTO: derriba el polvorín del Fuerte Constantino (en el centro del fuerte) antes del alba. Más del enjambre viene por el vado del norte a lo largo del día."),
     "phone": T("Break the fort's magazine before dawn.", "Derrube o paiol do forte antes do amanhecer.", "Derriba el polvorín del fuerte antes del alba.")},
    {"id": "m_raid", "side": "automata", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE RAID: break Fort Constantine's magazine (in the fort's middle) before dawn. More machines come over the south ford as the day goes; they are wound for the road.",
               "O ASSALTO: derrube o paiol do Forte Constantino (no meio do forte) antes do amanhecer. Mais máquinas vêm pelo vau do sul ao longo do dia; vêm com corda para a estrada.",
               "EL ASALTO: derriba el polvorín del Fuerte Constantino (en el centro del fuerte) antes del alba. Más máquinas vienen por el vado del sur a lo largo del día; vienen con cuerda para el camino."),
     "phone": T("Break the fort's magazine before dawn.", "Derrube o paiol do forte antes do amanhecer.", "Derriba el polvorín del fuerte antes del alba.")},
]

M = {
    "id": MID,
    "title": T("Between Two Fires", "Entre Dois Fogos", "Entre Dos Fuegos"),
    "summary": T("The sertão, the dry season 2780. The army of Brazil marches to the fort at the crossroads of the São Francisco, and both fires find it. The Crown chooses which to fight first.",
                 "O sertão, a estação seca de 2780. O exército do Brasil marcha para o forte na encruzilhada do São Francisco, e os dois fogos encontram-no. A Coroa escolhe qual combater primeiro.",
                 "El sertón, la estación seca de 2780. El ejército de Brasil marcha al fuerte en la encrucijada del São Francisco, y los dos fuegos lo encuentran. La Corona elige cuál combatir primero."),
    "map": "campaign:sao_francisco",
    "voice": "d09",
    "light": "day",
    "floor": [1.0, 0.96, 0.9],
    "expansion_spots": False,
    "manual_end": True,
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.7}, "hard": {"clocks": 0.85, "spawns": 1.4}},
    # THE SECOND CROSSING: locked until each line's last mission before it is won (the plan's gating)
    "needs": ["a07_council", "d05_aldeia", "d07_spring", "d08_rivers"],
    "modes": ["solo", "coop", "versus"],
    "solo_sides": ["crown"],
    "versus_pick": ["creatures", "automata"],
    "sides": [
        {"id": "crown", "name": T("The Army of Brazil", "O Exército do Brasil", "El Ejército de Brasil"),
         "about": T("General Ruggieri, Father Tomasz and the Crown's army of Brazil on the road to the São Francisco; the fort's garrison.",
                    "O General Ruggieri, o Padre Tomasz e o exército da Coroa no Brasil na estrada para o São Francisco; a guarnição do forte.",
                    "El General Ruggieri, el Padre Tomasz y el ejército de la Corona en Brasil en el camino al São Francisco; la guarnición del fuerte.")},
        {"id": "creatures", "name": T("The Swarm", "O Enxame", "El Enjambre"),
         "about": T("The creatures out of the north-west, far from their rivers: Raptors, Spitters, flyers.",
                    "As criaturas vindas do noroeste, longe dos seus rios: Raptores, Cuspidores, voadores.",
                    "Las criaturas venidas del noroeste, lejos de sus ríos: Raptores, Escupidores, voladores.")},
        {"id": "automata", "name": T("The Machines", "As Máquinas", "Las Máquinas"),
         "about": T("The city's machines on the highlands' road from the south-west: Clock Soldiers, Springers, brass birds.",
                    "As máquinas da cidade na estrada do planalto, vindas do sudoeste: Soldados de Corda, Saltadores, pássaros de latão.",
                    "Las máquinas de la ciudad en el camino del altiplano, venidas del suroeste: Soldados de Cuerda, Saltadores, pájaros de latón.")},
    ],
    "teams": [
        {"id": "army", "side": "crown", "faction": "crown", "colour": 4, "start": "none", "camera": "road_start", "gold": GOLD,
         "powder": POWDER, "techs": ["matchlock", "bayonet", "charge", "armour"],
         "control": {"solo": "p1", "coop": "p1", "versus": "p1"}},
        {"id": "fort", "side": "crown", "faction": "crown", "colour": 0, "start": "none", "camera": "fort_mid", "gold": 150, "powder": 200,
         "techs": ["matchlock", "bayonet"],
         "roster": {"deny": ["town_hall", "cottage", "farm", "wall", "gate", "barracks", "powder_mill", "horse_breeder", "foundry", "armoury",
                             "church", "labourer", "missionary"]},
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "sertao", "side": "crown", "faction": "crown", "colour": 3, "start": "none", "camera": "riacho",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "creatures", "side": "creatures", "faction": "brood", "colour": 2, "start": "none", "camera": "nw_camp", "gold": 200, "powder": 0,
         "roster": {"deny": ["grub", "rootmaw", "mound_turtle", "stage3", "brute", "mist_toad", "dilophosaurus", "pterodactyl"]},
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
        {"id": "automata", "side": "automata", "faction": "clockwork", "colour": 1, "start": "none", "camera": "sw_camp", "gold": 200, "powder": 0,
         "roster": {"deny": ["clocktower", "cog_press", "mainspring", "regulator", "movement_works", "winder", "heavy_works"]},
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": areas,
    "counters": {k: {"start": 0} for k in ["people_n", "in_fort", "joined", "siege_left", "siege_c", "night_n"]},
    "exits": [{"area": "fort_in", "tag": "people", "counter": "in_fort"}],
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["ruggieri", "tomasz", "commander"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "crown", "portrait": "res://campaign/hub/rome_king_face.png"},
        "tomasz": {"name": T("Father Tomasz", "Padre Tomasz", "Padre Tomasz"), "side": "crown"},
        "ruggieri": {"name": T("General Ruggieri", "General Ruggieri", "General Ruggieri"), "side": "crown"},
        "commander": {"name": T("Major Teixeira", "Major Teixeira", "Mayor Teixeira"), "side": "crown"},
        "hollins": {"name": T("Sergeant Hollins", "Sargento Hollins", "Sargento Hollins"), "side": "crown"},
        "rider": {"name": T("The frontier's rider", "O cavaleiro da fronteira", "El jinete de la frontera"), "side": "crown"},
        "varenne": {"name": T("Etienne Varenne", "Etienne Varenne", "Etienne Varenne"), "side": "crown"},
        "prince": {"name": T("The Prince", "O Príncipe", "El Príncipe"), "side": "crown"},
        "narrator": {"name": T("The Sertão", "O Sertão", "El Sertón"), "side": "crown"},
        "fortn": {"name": T("The Fort", "O Forte", "El Fuerte"), "side": "crown"},
        "scrub": {"name": T("The Scrub", "O Mato", "El Matorral"), "side": "creatures"},
        "road": {"name": T("The Highlands' Road", "A Estrada do Planalto", "El Camino del Altiplano"), "side": "automata"},
    },
    "lines": {},
    "stills": {},
    "next": {"crown": "", "creatures": "", "automata": ""},
    "debrief": {},
}

L = M["lines"]


def line(lid, who, en, pt, es, to=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    return lid


CR, CS, AU = "crown", "creatures", "automata"
# ---- the opening (the King frames; Tomasz tells it)
line("k_open1", "king", "Ten years after Rome, Brazil had two fires in it, and one army.",
     "Dez anos depois de Roma, o Brasil tinha dois fogos dentro dele, e um exército.",
     "Diez años después de Roma, Brasil tenía dos fuegos dentro, y un ejército.")
line("k_open2", "king", "Tomasz was the frontier's vicar general by then. He walked beside the guns, as he always had.",
     "Tomasz era por então vigário-geral da fronteira. Caminhava ao lado dos canhões, como sempre fizera.",
     "Tomasz era para entonces vicario general de la frontera. Caminaba junto a los cañones, como siempre había hecho.")
line("t_open1", "tomasz", "The dry season of 2780. We marched out of Salvador into the sertão, where nothing is green until it rains.",
     "A estação seca de 2780. Saímos de Salvador para o sertão, onde nada é verde até chover.",
     "La estación seca de 2780. Salimos de Salvador hacia el sertón, donde nada es verde hasta que llueve.")
line("t_open2", "tomasz", "General Ruggieri had every gun in Brazil behind him, and no town, no mill, no farm between us and the river.",
     "O General Ruggieri trazia atrás de si todos os canhões do Brasil, e nem vila, nem moinho, nem fazenda entre nós e o rio.",
     "El General Ruggieri llevaba tras de sí todos los cañones de Brasil, y ni villa, ni molino, ni hacienda entre nosotros y el río.")
line("t_open_vol", "tomasz", "The Virginia volunteers marched with us. Hollins was a sergeant now. He had been a boy at his father's farm the night the Governor came.",
     "Os voluntários da Virgínia marchavam connosco. Hollins era agora sargento. Era um rapaz na quinta do pai na noite em que o Governador chegou.",
     "Los voluntarios de Virginia marchaban con nosotros. Hollins era ahora sargento. Era un muchacho en la granja de su padre la noche en que llegó el Gobernador.")
line("t_open_paris", "tomasz", "Our colours had been blessed at Notre-Dame. The men touched them before we left.",
     "As nossas bandeiras tinham sido bentas em Notre-Dame. Os homens tocaram-lhes antes de partirmos.",
     "Nuestras banderas habían sido bendecidas en Notre-Dame. Los hombres las tocaron antes de partir.")
line("t_open_many", "tomasz", "Word of Rome still ran ahead of me. The villages on the road came out to meet the priest.",
     "A notícia de Roma ainda corria à minha frente. As aldeias da estrada saíam ao encontro do padre.",
     "La noticia de Roma aún corría delante de mí. Las aldeas del camino salían al encuentro del sacerdote.")
line("t_open3", "tomasz", "At the crossroads of the São Francisco stood the fort. From there the army could strike either way.",
     "Na encruzilhada do São Francisco estava o forte. Dali o exército podia atacar para um lado ou para o outro.",
     "En la encrucijada del São Francisco estaba el fuerte. Desde allí el ejército podía atacar hacia un lado o hacia el otro.")
line("k_open_c", "king", "Tomasz tells it from the road. Here it is from the scrub north of the river, where nobody kept count.",
     "Tomasz conta-o da estrada. Aqui está visto do mato a norte do rio, onde ninguém contava.",
     "Tomasz lo cuenta desde el camino. Aquí está visto desde el matorral al norte del río, donde nadie llevaba la cuenta.")
line("sc_open", "scrub", "The dry season. The swarm has come far from the rivers, after the herds. The road smells of horses and powder.",
     "A estação seca. O enxame veio para longe dos rios, atrás dos rebanhos. A estrada cheira a cavalos e a pólvora.",
     "La estación seca. El enjambre ha venido lejos de los ríos, detrás de los rebaños. El camino huele a caballos y a pólvora.")
line("k_open_m", "king", "Tomasz tells it from the road. Here it is from the highlands' road, where the machines walk at night.",
     "Tomasz conta-o da estrada. Aqui está visto da estrada do planalto, onde as máquinas andam de noite.",
     "Tomasz lo cuenta desde el camino. Aquí está visto desde el camino del altiplano, donde las máquinas andan de noche.")
line("hr_open", "road", "The dry season. The city's machines have come north along the highlands' road. Nobody in the city will say who sent them.",
     "A estação seca. As máquinas da cidade subiram para norte pela estrada do planalto. Ninguém na cidade diz quem as mandou.",
     "La estación seca. Las máquinas de la ciudad han subido al norte por el camino del altiplano. Nadie en la ciudad dice quién las mandó.")
# ---- part 1: the road
line("r_march", "ruggieri", "Column of march. Guns in the middle, the wagons behind the guns. We reach the fort before it falls.",
     "Coluna de marcha. Os canhões no meio, as carroças atrás dos canhões. Chegamos ao forte antes que caia.",
     "Columna de marcha. Los cañones en medio, los carros detrás de los cañones. Llegamos al fuerte antes de que caiga.", CR)
line("n_road", "narrator", "March the army west along the road to Fort Constantine on the São Francisco. Your men's powder is in the two wagons: there is no Mill on the road.",
     "Leve o exército para oeste pela estrada até ao Forte Constantino, no São Francisco. A pólvora dos seus homens vai nas duas carroças: não há Moinho na estrada.",
     "Lleva al ejército hacia el oeste por el camino hasta el Fuerte Constantino, en el São Francisco. La pólvora de tus hombres va en los dos carros: no hay Molino en el camino.", CR)
line("n_wagon", "narrator", "Musketeers and guns refill their shot from a powder wagon within 3 tiles. Keep the wagons just behind the line, and guard them: a wagon blows up when it is destroyed.",
     "Mosqueteiros e canhões recarregam de uma carroça de pólvora a 3 casas. Mantenha as carroças logo atrás da linha, e guarde-as: uma carroça explode quando é destruída.",
     "Mosqueteros y cañones recargan de un carro de pólvora a 3 casillas. Mantén los carros justo detrás de la línea, y guárdalos: un carro estalla cuando lo destruyen.", CR)
line("n_skies", "narrator", "Over the road, two kinds of flyers: brass birds from the south-west, small green flyers from the north-west. They go for each other, not for your men.",
     "Sobre a estrada, dois tipos de voadores: pássaros de latão do sudoeste, pequenos voadores verdes do noroeste. Atacam-se uns aos outros, não aos seus homens.",
     "Sobre el camino, dos clases de voladores: pájaros de latón del suroeste, pequeños voladores verdes del noroeste. Se atacan entre sí, no a tus hombres.")
line("t_skies", "tomasz", "I had seen each of them before. Never both in one sky.", "Já tinha visto cada um deles antes. Nunca os dois no mesmo céu.",
     "Había visto a cada uno de ellos antes. Nunca a los dos en el mismo cielo.", CR)
line("r_skies", "ruggieri", "Let them fight. Keep marching.", "Deixem-nos lutar. Continuem a marchar.", "Que peleen. Seguid marchando.", CR)
line("n_v1", "narrator", "Riacho Seco, the first village. Its people come with you when your men reach them: they follow Father Tomasz.",
     "Riacho Seco, a primeira aldeia. O seu povo vem consigo quando os seus homens lá chegam: segue o Padre Tomasz.",
     "Riacho Seco, la primera aldea. Su gente viene contigo cuando llegan tus hombres: sigue al Padre Tomasz.", CR)
line("t_join", "tomasz", "Come with us, all of you. Bring water, leave the rest. The fort is a day's walk.",
     "Venham connosco, todos. Tragam água, deixem o resto. O forte fica a um dia de caminho.",
     "Venid con nosotros, todos. Traed agua, dejad lo demás. El fuerte está a un día de camino.", CR)
line("n_r1", "narrator", "Out of the scrub to the north: Raptors, going for the village.", "Do mato a norte: Raptores, a caminho da aldeia.",
     "Del matorral al norte: Raptores, camino de la aldea.", CR)
line("n_v2", "narrator", "Lagoa Branca, the second village. Its people join the column too.", "Lagoa Branca, a segunda aldeia. O seu povo junta-se também à coluna.",
     "Lagoa Branca, la segunda aldea. Su gente se une también a la columna.", CR)
line("n_m1", "narrator", "From the south, a column of machines out of the thorns: Clock Soldiers and Springers.",
     "Do sul, uma coluna de máquinas a sair dos espinhos: Soldados de Corda e Saltadores.",
     "Del sur, una columna de máquinas saliendo de los espinos: Soldados de Cuerda y Saltadores.", CR)
line("h_m1", "hollins", "Machines, Father? This far north?", "Máquinas, Padre? Tão a norte?", "¿Máquinas, Padre? ¿Tan al norte?", CR)
line("t_m1", "tomasz", "This far from anywhere, Sergeant.", "Tão longe de tudo, Sargento.", "Tan lejos de todo, Sargento.", CR)
line("n_owls", "narrator", "Two brass owls drop out of the sky on the powder wagons. Shoot them down before they reach them.",
     "Duas corujas de latão caem do céu sobre as carroças de pólvora. Abata-as antes que lá cheguem.",
     "Dos búhos de latón caen del cielo sobre los carros de pólvora. Derríbalos antes de que lleguen.", CR)
line("r_owls", "ruggieri", "The wagons! Muskets up, at the owls!", "As carroças! Mosquetes para cima, às corujas!", "¡Los carros! ¡Mosquetes arriba, a los búhos!", CR)
line("n_owls_down", "narrator", "The owls are down.", "As corujas caíram.", "Los búhos han caído.", CR)
line("n_r2", "narrator", "Raptors again, between you and the fort, with a big one among them.", "Raptores outra vez, entre si e o forte, com um grande entre eles.",
     "Raptores otra vez, entre tú y el fuerte, con uno grande entre ellos.", CR)
line("n_m2", "narrator", "The machines again, out of a dry wash to the south. Netters among them: their chains hold a man fast while the others strike.",
     "As máquinas outra vez, a sair de um leito seco a sul. Redeiros entre elas: as suas correntes prendem um homem enquanto as outras atacam.",
     "Las máquinas otra vez, saliendo de un cauce seco al sur. Rederos entre ellas: sus cadenas sujetan a un hombre mientras las otras atacan.", CR)
line("n_wagon_lost", "narrator", "A powder wagon is lost. Keep the other one close.", "Perdeu-se uma carroça de pólvora. Mantenha a outra perto.",
     "Se ha perdido un carro de pólvora. Mantén el otro cerca.", CR)
line("n_fort_late", "fortn", "The fort's guns are firing. The siege has begun without you.", "Os canhões do forte estão a disparar. O cerco começou sem si.",
     "Los cañones del fuerte están disparando. El asedio ha empezado sin ti.", CR)
line("n_in_first", "fortn", "The first of the road's people are inside the fort.", "Os primeiros do povo da estrada estão dentro do forte.",
     "Los primeros del pueblo del camino están dentro del fuerte.", CR)
# ---- part 2: the fort
line("n_arrive", "fortn", "Fort Constantine. Both of them are at it: the swarm at the north gate, the machines at the south gate.",
     "O Forte Constantino. Estão lá os dois: o enxame no portão norte, as máquinas no portão sul.",
     "El Fuerte Constantino. Están los dos: el enjambre en la puerta norte, las máquinas en la puerta sur.")
line("c_arrive", "commander", "General! Thank God. They came the same week, from both sides. We have not slept.",
     "General! Graças a Deus. Vieram na mesma semana, dos dois lados. Não dormimos.",
     "¡General! Gracias a Dios. Vinieron la misma semana, por los dos lados. No hemos dormido.", CR)
line("r_arrive", "ruggieri", "Two sieges at one fort. The north gate is the beasts', the south gate the machines'. Split the guns.",
     "Dois cercos a um só forte. O portão norte é das feras, o portão sul das máquinas. Dividam os canhões.",
     "Dos asedios a un solo fuerte. La puerta norte es de las bestias, la puerta sur de las máquinas. Dividid los cañones.", CR)
line("n_siege", "fortn", "Drive both off the fort. The fort's magazine, in its middle, must stand: if it goes up, the fort goes with it.",
     "Afaste os dois do forte. O paiol do forte, no meio dele, tem de ficar de pé: se explodir, o forte vai com ele.",
     "Echa a los dos del fuerte. El polvorín del fuerte, en su centro, debe seguir en pie: si estalla, el fuerte se va con él.", CR)
line("n_ford", "fortn", "At the ford under the west wall the creatures and the machines meet, and tear at each other.",
     "No vau sob a muralha oeste as criaturas e as máquinas encontram-se, e despedaçam-se umas às outras.",
     "En el vado bajo el muro oeste las criaturas y las máquinas se encuentran, y se despedazan entre sí.")
line("t_ford", "tomasz", "God forgive me, I was glad to see them fight.", "Deus me perdoe, fiquei contente por os ver lutar.",
     "Dios me perdone, me alegré de verlos pelear.", CR)
line("n_wave2", "fortn", "More come over the fords, at both gates.", "Mais vêm pelos vaus, aos dois portões.", "Más vienen por los vados, a las dos puertas.", CR)
line("n_relieved", "fortn", "The fort is relieved. What is left of both draws back over the river.", "O forte está socorrido. O que resta dos dois recua para lá do rio.",
     "El fuerte está socorrido. Lo que queda de los dos se retira al otro lado del río.")
line("c_relieved", "commander", "The fort is yours, General. Its barracks, its foundry, its powder.", "O forte é vosso, General. O quartel, a fundição, a pólvora.",
     "El fuerte es vuestro, General. Su cuartel, su fundición, su pólvora.", CR)
line("n_draw_back", "fortn", "At dusk both draw back over the river. They will be back.", "Ao anoitecer os dois recuam para lá do rio. Hão de voltar.",
     "Al anochecer los dos se retiran al otro lado del río. Volverán.")
line("n_fort_yours", "fortn", "In the fort your wagons fill again at the Barracks. The Barracks trains armoured men, the Foundry guns and wagons: the army's pay chest came with you.",
     "No forte as suas carroças enchem-se outra vez no Quartel. O Quartel treina homens com armadura, a Fundição canhões e carroças: o cofre do soldo veio consigo.",
     "En el fuerte tus carros se llenan otra vez en el Cuartel. El Cuartel entrena hombres con armadura, la Fundición cañones y carros: el cofre de la paga vino contigo.", CR)
# ---- part 3: the council of war (the show)
line("n_council", "fortn", "That evening, in the commander's room: General Ruggieri, Father Tomasz, a map of Brazil on the table. Two riders come in within the hour.",
     "Nessa noite, no quarto do comandante: o General Ruggieri, o Padre Tomasz, um mapa do Brasil na mesa. Chegam dois cavaleiros na mesma hora.",
     "Esa noche, en el cuarto del comandante: el General Ruggieri, el Padre Tomasz, un mapa de Brasil en la mesa. Llegan dos jinetes en la misma hora.")
line("ms_1", "rider", "From the Amazon frontier, General. The swarm is on the rivers.", "Da fronteira do Amazonas, General. O enxame está nos rios.",
     "De la frontera del Amazonas, General. El enjambre está en los ríos.")
line("ms_left", "rider", "It fed all season on the Tapajós. It is bigger than last year.", "Comeu a estação toda no Tapajós. Está maior do que no ano passado.",
     "Comió toda la estación en el Tapajós. Es mayor que el año pasado.")
line("ms_burned", "rider", "On the Tapajós it starved where the fields were burned. Everywhere else it fed.", "No Tapajós passou fome onde os campos foram queimados. Em todo o resto comeu.",
     "En el Tapajós pasó hambre donde los campos fueron quemados. En todo lo demás comió.")
line("ms_barra_held", "rider", "Valadares holds the Barra. He asks for guns before the floods.", "Valadares segura a Barra. Pede canhões antes das cheias.",
     "Valadares resiste en la Barra. Pide cañones antes de las crecidas.")
line("ms_barra_burned", "rider", "Valadares holds the bluff at the Barra. The lower town is ash.", "Valadares segura o barranco da Barra. A cidade baixa é cinza.",
     "Valadares resiste en el barranco de la Barra. La ciudad baja es ceniza.")
line("ms_lure", "rider", "He says the lure worked once. Now the swarm comes to the smell of it.", "Diz que o engodo resultou uma vez. Agora o enxame vem ao cheiro dele.",
     "Dice que el señuelo funcionó una vez. Ahora el enjambre viene al olor de él.")
line("v_1", "varenne", "Etienne Varenne, for the free city of Concórdia. I come under a white flag.", "Etienne Varenne, pela cidade livre de Concórdia. Venho sob bandeira branca.",
     "Etienne Varenne, por la ciudad libre de Concórdia. Vengo bajo bandera blanca.")
line("v_2", "varenne", "The city asks one thing: to be left to govern itself, as it has these seven years.",
     "A cidade pede uma coisa: que a deixem governar-se a si mesma, como fez nestes sete anos.",
     "La ciudad pide una cosa: que la dejen gobernarse a sí misma, como lo ha hecho estos siete años.")
line("r_v", "ruggieri", "Its machines are on my road and at my south gate.", "As máquinas dela estão na minha estrada e no meu portão sul.",
     "Sus máquinas están en mi camino y en mi puerta sur.")
line("v_3", "varenne", "Those are not the city's. The city has not sent anyone. I... do not know whose they are.",
     "Essas não são da cidade. A cidade não mandou ninguém. Eu... não sei de quem são.",
     "Esas no son de la ciudad. La ciudad no ha mandado a nadie. Yo... no sé de quién son.")
line("v_stopped", "varenne", "Since Hollweg stopped the great spring, the city runs without him. It runs very well.",
     "Desde que Hollweg parou a grande mola, a cidade anda sem ele. Anda muito bem.",
     "Desde que Hollweg paró el gran resorte, la ciudad funciona sin él. Funciona muy bien.")
line("n_letter", "fortn", "Nobody comes from the south. At the ford's post a letter is nailed, unsigned: the free city asks to be left to govern itself.",
     "Ninguém vem do sul. No poste do vau está pregada uma carta, sem assinatura: a cidade livre pede que a deixem governar-se a si mesma.",
     "Nadie viene del sur. En el poste del vado hay una carta clavada, sin firma: la ciudad libre pide que la dejen gobernarse a sí misma.")
line("t_honest", "tomasz", "Most of the honest masters stood with Hollweg that night in Concórdia. The ones who stayed are the city's now.",
     "A maior parte dos mestres honestos ficou com Hollweg naquela noite em Concórdia. Os que ficaram são agora da cidade.",
     "La mayoría de los maestros honrados se quedó con Hollweg aquella noche en Concórdia. Los que se quedaron son ahora de la ciudad.")
line("t_counsel1", "tomasz", "General, the people under the swarm cannot wait. The city can.", "General, o povo debaixo do enxame não pode esperar. A cidade pode.",
     "General, el pueblo bajo el enjambre no puede esperar. La ciudad sí.")
line("t_counsel2", "tomasz", "But the city grows while it waits, and it never sleeps. I do not know which is worse.",
     "Mas a cidade cresce enquanto espera, e nunca dorme. Não sei qual é pior.", "Pero la ciudad crece mientras espera, y nunca duerme. No sé cuál es peor.")
line("r_think", "ruggieri", "One army. Two fires. I can go north up the rivers, or south to the highlands. Not both.",
     "Um exército. Dois fogos. Posso ir para norte pelos rios acima, ou para sul, para o planalto. Não os dois.",
     "Un ejército. Dos fuegos. Puedo ir al norte río arriba, o al sur, al altiplano. No a los dos.")
line("k_frame", "king", "Here I stop. I will tell you what we chose. First, tell me what you would choose.",
     "Aqui paro. Vou dizer-te o que escolhemos. Primeiro, diz-me o que escolherias tu.",
     "Aquí me detengo. Te diré lo que elegimos. Primero, dime qué elegirías tú.")
line("q_first", "king", "Which fire first? The one you leave strikes the fort tonight, and grows while it waits.",
     "Que fogo primeiro? O que deixares ataca o forte esta noite, e cresce enquanto espera.",
     "¿Qué fuego primero? El que dejes ataca el fuerte esta noche, y crece mientras espera.")
line("p_brood", "prince", "The swarm. The people first.", "O enxame. O povo primeiro.", "El enjambre. El pueblo primero.")
line("p_clock", "prince", "The city. Before it grows.", "A cidade. Antes que cresça.", "La ciudad. Antes de que crezca.")
line("k_brood", "king", "The swarm first. So Ruggieri chose, before dawn, and so it was.", "O enxame primeiro. Assim escolheu Ruggieri, antes do amanhecer, e assim foi.",
     "El enjambre primero. Así eligió Ruggieri, antes del alba, y así fue.")
line("k_clock", "king", "The city first. So Ruggieri chose, before dawn, and so it was.", "A cidade primeiro. Assim escolheu Ruggieri, antes do amanhecer, e assim foi.",
     "La ciudad primero. Así eligió Ruggieri, antes del alba, y así fue.")
line("r_brood", "ruggieri", "North, then. Up the rivers. Send word to Valadares.", "Para norte, então. Rio acima. Mandem aviso a Valadares.",
     "Al norte, entonces. Río arriba. Mandad aviso a Valadares.")
line("r_clock", "ruggieri", "South, then. To the highlands. Send word to Father Ferrer.", "Para sul, então. Para o planalto. Mandem aviso ao Padre Ferrer.",
     "Al sur, entonces. Al altiplano. Mandad aviso al Padre Ferrer.")
line("n_night_m", "fortn", "The machines did not wait for morning. They come at the south gate in the dark. Hold the fort until dawn.",
     "As máquinas não esperaram pela manhã. Vêm ao portão sul no escuro. Aguente o forte até ao amanhecer.",
     "Las máquinas no esperaron a la mañana. Vienen a la puerta sur en la oscuridad. Resiste en el fuerte hasta el alba.")
line("n_night_c", "fortn", "The swarm did not wait for morning. It comes at the north gate in the dark. Hold the fort until dawn.",
     "O enxame não esperou pela manhã. Vem ao portão norte no escuro. Aguente o forte até ao amanhecer.",
     "El enjambre no esperó a la mañana. Viene a la puerta norte en la oscuridad. Resiste en el fuerte hasta el alba.")
line("t_night", "tomasz", "Get the people into the chapel. All of them.", "Levem o povo para a capela. Todos.", "Llevad al pueblo a la capilla. A todos.", CR)
line("n_night_w", "fortn", "Another wave at the gate.", "Outra vaga no portão.", "Otra oleada en la puerta.", CR)
line("n_night_big", "fortn", "The last of them, and the biggest, before the light.", "Os últimos, e os maiores, antes da luz.", "Los últimos, y los mayores, antes de la luz.", CR)
line("n_dawn", "fortn", "Dawn over the São Francisco. The fort stands.", "Amanhece sobre o São Francisco. O forte está de pé.", "Amanece sobre el São Francisco. El fuerte sigue en pie.")
line("r_dawn", "ruggieri", "Strike the tents. We march at noon.", "Levantem as tendas. Marchamos ao meio-dia.", "Levantad las tiendas. Marchamos a mediodía.", CR)
line("n_mag_down", "fortn", "The magazine goes up. Fort Constantine burns.", "O paiol explode. O Forte Constantino arde.", "El polvorín estalla. El Fuerte Constantino arde.")
line("t_hurt", "tomasz", "I am hit. Keep them walking, Sergeant.", "Fui atingido. Mantenha-os a andar, Sargento.", "Me han dado. Que sigan andando, Sargento.", CR)
line("r_hurt", "ruggieri", "A scratch. Mind the guns, not me.", "Um arranhão. Cuidem dos canhões, não de mim.", "Un rasguño. Cuidad de los cañones, no de mí.", CR)
# ---- the versus friend's side (no creature and no machine speaks: the land's narrator)
line("sc_1", "scrub", "You lead the swarm on the north bank: Raptors, Spitters, a Tyrant Challenger and Hatchlings. More come over the north ford as the day goes. Break the fort's magazine before dawn.",
     "Você conduz o enxame na margem norte: Raptores, Cuspidores, um Desafiante Tirano e Crias. Mais vêm pelo vau do norte ao longo do dia. Derrube o paiol do forte antes do amanhecer.",
     "Diriges el enjambre en la orilla norte: Raptores, Escupidores, un Retador Tirano y Crías. Más vienen por el vado del norte a lo largo del día. Derriba el polvorín del fuerte antes del alba.", CS)
line("hr_1", "road", "You lead the machines on the south bank: Clock Soldiers, Springers, a Netter and Swifts, wound for the road. More come over the south ford. Break the fort's magazine before dawn.",
     "Você conduz as máquinas na margem sul: Soldados de Corda, Saltadores, um Redeiro e Andorinhas, com corda para a estrada. Mais vêm pelo vau do sul. Derrube o paiol do forte antes do amanhecer.",
     "Diriges las máquinas en la orilla sur: Soldados de Cuerda, Saltadores, un Redero y Vencejos, con cuerda para el camino. Más vienen por el vado del sur. Derriba el polvorín del fuerte antes del alba.", AU)
line("sc_more", "scrub", "More of the swarm comes over the north ford: they are yours.", "Mais do enxame vem pelo vau do norte: são seus.", "Más del enjambre viene por el vado del norte: son tuyos.", CS)
line("hr_more", "road", "More machines come over the south ford: they are yours.", "Mais máquinas vêm pelo vau do sul: são suas.", "Más máquinas vienen por el vado del sur: son tuyas.", AU)
line("sc_other", "scrub", "The city's machines are on this land too. They go for anything that is not theirs.",
     "As máquinas também andam por esta terra. Atacam tudo o que não é delas.", "Las máquinas también andan por esta tierra. Atacan todo lo que no es suyo.", CS)
line("hr_other", "road", "The swarm is on this land too. It goes for anything that moves.", "O enxame também anda por esta terra. Ataca tudo o que se mexe.",
     "El enjambre también anda por esta tierra. Ataca todo lo que se mueve.", AU)
line("f_won", "fortn", "The magazine goes up. Nobody counts what is left.", "O paiol explode. Ninguém conta o que resta.", "El polvorín estalla. Nadie cuenta lo que queda.")
line("f_lost", "fortn", "Dawn. The fort still stands.", "Amanhece. O forte continua de pé.", "Amanece. El fuerte sigue en pie.")
# ---- the endings
line("t_end1", "tomasz", "We left the fort at noon, with the road's people behind its walls.", "Deixámos o forte ao meio-dia, com o povo da estrada atrás das suas muralhas.",
     "Dejamos el fuerte a mediodía, con el pueblo del camino tras sus muros.")
line("t_end_many", "tomasz", "Most of them had come in. I counted twice to be sure.", "A maior parte tinha entrado. Contei duas vezes para ter a certeza.",
     "La mayoría había entrado. Conté dos veces para estar seguro.")
line("t_end_some", "tomasz", "Some of them had come in. I said the others' names at Mass.", "Alguns tinham entrado. Disse os nomes dos outros na Missa.",
     "Algunos habían entrado. Dije los nombres de los otros en la Misa.")
line("t_end_few", "tomasz", "Few of them had come in. I have their villages' names still.", "Poucos tinham entrado. Ainda tenho os nomes das aldeias deles.",
     "Pocos habían entrado. Todavía tengo los nombres de sus aldeas.")
line("t_end_brood", "tomasz", "We went north, up the rivers, to the swarm.", "Fomos para norte, rio acima, ao encontro do enxame.", "Fuimos al norte, río arriba, al encuentro del enjambre.")
line("t_end_clock", "tomasz", "We went south, to the highlands, to the city.", "Fomos para sul, para o planalto, ao encontro da cidade.", "Fuimos al sur, al altiplano, al encuentro de la ciudad.")
line("k_end1", "king", "One army, two fires. You chose, and the army went.", "Um exército, dois fogos. Escolheste, e o exército foi.", "Un ejército, dos fuegos. Elegiste, y el ejército fue.")
line("k_end_brood", "king", "Up the rivers it went. The city waited in the highlands, and grew.", "Foi rio acima. A cidade esperou no planalto, e cresceu.",
     "Fue río arriba. La ciudad esperó en el altiplano, y creció.")
line("k_end_clock", "king", "South it went. The swarm waited on the rivers, and spread.", "Foi para sul. O enxame esperou nos rios, e espalhou-se.",
     "Fue al sur. El enjambre esperó en los ríos, y se extendió.")
line("k_end2", "king", "That is what a crown is, in the end: choosing which fire burns longer.", "É isso uma coroa, no fim: escolher que fogo arde mais tempo.",
     "Eso es una corona, al final: elegir qué fuego arde más tiempo.")
line("k_end_s", "king", "That is not how it went. The fort stood. Hear it again from Tomasz.", "Não foi assim que aconteceu. O forte ficou de pé. Ouve outra vez da boca de Tomasz.",
     "No fue así como pasó. El fuerte siguió en pie. Óyelo otra vez de boca de Tomasz.")

# (a quick player is past the part a chatty line belongs to: those lines are dropped unseen once the next part begins)
for lid in ["n_wagon", "t_skies", "r_skies", "n_v1", "t_join", "n_r1", "n_v2", "n_m1", "h_m1", "t_m1", "n_owls", "r_owls", "n_owls_down", "n_r2", "n_m2", "n_wagon_lost",
            "n_in_first"]:
    L[lid]["until"] = "part2"
for lid in ["n_ford", "t_ford", "n_wave2", "c_relieved", "n_fort_yours"]:
    L[lid]["until"] = "part3"

# ---- stills
M["stills"] = {
    "rome": {"image": STILL % "p01_01", "caption": T("Rome, the present. The King tells it.", "Roma, o presente. O Rei conta.", "Roma, el presente. El Rey lo cuenta.")},
    "army": {"image": STILL % "d09_01", "caption": T("The army of Brazil in the sertão, the dry season 2780.", "O exército do Brasil no sertão, a estação seca de 2780.",
                                                     "El ejército de Brasil en el sertón, la estación seca de 2780.")},
    "skies": {"image": STILL % "d09_02", "caption": T("Two skies over the road.", "Dois céus sobre a estrada.", "Dos cielos sobre el camino.")},
    "council": {"image": STILL % "d09_03", "caption": T("The council of war at Fort Constantine.", "O conselho de guerra no Forte Constantino.",
                                                        "El consejo de guerra en el Fuerte Constantino.")},
}
M["opening"] = {
    "crown": [{"still": "rome", "lines": ["k_open1", "k_open2"]},
              {"still": "army", "lines": ["t_open1", "t_open2", {"id": "t_open_vol", "if": VOL}, {"id": "t_open_paris", "if": PARIS},
                                          {"id": "t_open_many", "if": MANY}, "t_open3"]}],
    "creatures": [{"still": "rome", "lines": ["k_open_c"]}, {"still": "skies", "lines": ["sc_open"]}],
    "automata": [{"still": "rome", "lines": ["k_open_m"]}, {"still": "skies", "lines": ["hr_open"]}],
}
M["ending"] = {
    "crown": [
        {"still": "army", "lines": ["t_end1", {"id": "t_end_many", "if": {"flag": {"sertao": "many"}}}, {"id": "t_end_some", "if": {"flag": {"sertao": "some"}}},
                                    {"id": "t_end_few", "if": {"flag": {"sertao": "few"}}},
                                    {"id": "t_end_brood", "if": FIRST_BROOD}, {"id": "t_end_clock", "if": FIRST_CLOCK}]},
        {"still": "rome", "lines": ["k_end1", {"id": "k_end_brood", "if": FIRST_BROOD}, {"id": "k_end_clock", "if": FIRST_CLOCK}, "k_end2"]},
    ],
    "creatures": [{"still": "skies", "lines": ["f_won"]}, {"still": "rome", "lines": ["k_end_s"]}],
    "automata": [{"still": "skies", "lines": ["f_won"]}, {"still": "rome", "lines": ["k_end_s"]}],
}
M["briefing"] = {
    "crown": {"still": "army", "text": [
        T("The sertão, the dry season 2780. You are the army of Brazil: General Ruggieri, Father Tomasz, Musketeers and Guardsmen, Dragoons and Cuirassiers, two Field Cannons, a Mortar and two powder wagons.",
          "O sertão, a estação seca de 2780. Você é o exército do Brasil: o General Ruggieri, o Padre Tomasz, Mosqueteiros e Guardas, Dragões e Couraceiros, dois Canhões de Campanha, um Morteiro e duas carroças de pólvora.",
          "El sertón, la estación seca de 2780. Eres el ejército de Brasil: el General Ruggieri, el Padre Tomasz, Mosqueteros y Guardias, Dragones y Coraceros, dos Cañones de Campaña, un Mortero y dos carros de pólvora."),
        T("March west to Fort Constantine on the São Francisco, bringing the road's villagers with you. There is no Mill on the road: keep the wagons with the line. At the fort both the swarm and the city's machines are waiting.",
          "Marche para oeste até ao Forte Constantino, no São Francisco, levando consigo os aldeões da estrada. Não há Moinho na estrada: mantenha as carroças com a linha. No forte esperam o enxame e as máquinas da cidade.",
          "Marcha al oeste hasta el Fuerte Constantino, en el São Francisco, llevando contigo a los aldeanos del camino. No hay Molino en el camino: mantén los carros con la línea. En el fuerte esperan el enjambre y las máquinas de la ciudad."),
        T("Then the council of war: one army, two fires. You choose which the army fights first; the other waits, and grows.",
          "Depois o conselho de guerra: um exército, dois fogos. Você escolhe qual o exército combate primeiro; o outro espera, e cresce.",
          "Luego el consejo de guerra: un ejército, dos fuegos. Tú eliges cuál combate primero el ejército; el otro espera, y crece.")]},
    "creatures": {"still": "skies", "text": [
        T("The sertão, the dry season 2780. You are the swarm on the north bank of the São Francisco, far from its rivers.",
          "O sertão, a estação seca de 2780. Você é o enxame na margem norte do São Francisco, longe dos seus rios.",
          "El sertón, la estación seca de 2780. Eres el enjambre en la orilla norte del São Francisco, lejos de sus ríos."),
        T("Break the fort's magazine before dawn. The Crown's army is on the road; the city's machines come from the south and go for you too.",
          "Derrube o paiol do forte antes do amanhecer. O exército da Coroa vem pela estrada; as máquinas da cidade vêm do sul e atacam-no também.",
          "Derriba el polvorín del fuerte antes del alba. El ejército de la Corona viene por el camino; las máquinas de la ciudad vienen del sur y te atacan también.")]},
    "automata": {"still": "skies", "text": [
        T("The sertão, the dry season 2780. You are the city's machines on the south bank of the São Francisco, wound for the road.",
          "O sertão, a estação seca de 2780. Você é as máquinas da cidade na margem sul do São Francisco, com corda para a estrada.",
          "El sertón, la estación seca de 2780. Eres las máquinas de la ciudad en la orilla sur del São Francisco, con cuerda para el camino."),
        T("Break the fort's magazine before dawn. The Crown's army is on the road; the swarm comes from the north and goes for you too.",
          "Derrube o paiol do forte antes do amanhecer. O exército da Coroa vem pela estrada; o enxame vem do norte e ataca-o também.",
          "Derriba el polvorín del fuerte antes del alba. El ejército de la Corona viene por el camino; el enjambre viene del norte y te ataca también.")]},
}
M["debrief"] = {
    "crown": {"still": "council", "title": T("Fort Constantine", "O Forte Constantino", "El Fuerte Constantino"),
              "text": T("{in_fort} of the {people_n} people of the road reached the fort.", "{in_fort} das {people_n} pessoas da estrada chegaram ao forte.",
                        "{in_fort} de las {people_n} personas del camino llegaron al fuerte."),
              "text_if": [
                  {"if": FIRST_BROOD, "text": T("The army went north first, up the rivers to the swarm. The city waits, and grows: its siege will be harder.",
                                                "O exército foi primeiro para norte, rio acima, contra o enxame. A cidade espera, e cresce: o seu cerco será mais duro.",
                                                "El ejército fue primero al norte, río arriba, contra el enjambre. La ciudad espera, y crece: su asedio será más duro.")},
                  {"if": FIRST_CLOCK, "text": T("The army went south first, to the city of gears. The swarm waits, and spreads: the jungle front will be harder.",
                                                "O exército foi primeiro para sul, contra a cidade das engrenagens. O enxame espera, e espalha-se: a frente da selva será mais dura.",
                                                "El ejército fue primero al sur, contra la ciudad de engranajes. El enjambre espera, y se extiende: el frente de la selva será más duro.")}]},
    "creatures": {"still": "skies", "title": T("The Scrub", "O Mato", "El Matorral"),
                  "text": T("Fort Constantine's magazine went up before dawn.", "O paiol do Forte Constantino explodiu antes do amanhecer.",
                            "El polvorín del Fuerte Constantino estalló antes del alba.")},
    "automata": {"still": "skies", "title": T("The Highlands' Road", "A Estrada do Planalto", "El Camino del Altiplano"),
                 "text": T("Fort Constantine's magazine went up before dawn.", "O paiol do Forte Constantino explodiu antes do amanhecer.",
                           "El polvorín del Fuerte Constantino estalló antes del alba.")},
}


# ================================================================== the triggers
def c_wave(wid, when, at, to, base, delay=None, every=None, extra=(), line_ids=None, fed=True):
    """A wave of the creatures (on their team: the versus friend's if he leads them) out of `at`: `base` Raptors (scaled
    by the difficulty), one fewer with d06 `brood_n` few (never under one), one more with all, one more while the swarm fed
    on the Tapajós (d05 `fields` left, the canon) when `fed`; the `extra` spawns with their own conditions; ordered on to
    `to` (the scripted ones then hunt the people / press the gate)."""
    sp = [{"spawn": {"team": "creatures", "kind": "raptor", "count": base, "at": at, "tag": "c_wave", "tags": [wid, "c_all"],
                     "order": {"do": "attack", "to": to}, "if": NOT_FEW}},
          {"spawn": {"team": "creatures", "kind": "raptor", "count": max(1, base - 1), "at": at, "tag": "c_wave", "tags": [wid, "c_all"],
                     "order": {"do": "attack", "to": to}, "if": B_FEW}},
          {"spawn": {"team": "creatures", "kind": "raptor", "count": 1, "at": at, "tag": "c_wave", "tags": [wid, "c_all"], "fixed": True,
                     "order": {"do": "attack", "to": to}, "if": B_ALL}}]
    if fed:
        sp.append({"spawn": {"team": "creatures", "kind": "raptor", "count": 1, "at": at, "tag": "c_wave", "tags": [wid, "c_all"], "fixed": True,
                             "order": {"do": "attack", "to": to}, "if": FIELDS_LEFT}})
    for (k, n, c) in extra:
        e = {"team": "creatures", "kind": k, "count": n, "at": at, "tag": "c_wave", "tags": [wid, "c_all"], "order": {"do": "attack", "to": to}}
        if c is not None:
            e["if"] = c
        sp.append({"spawn": e})
    t = {"id": wid, "when": when, "do": sp + [{"ping": {"area": at}}] + ([{"say": line_ids}] if line_ids else [])}
    if delay is not None:
        t["delay"] = delay
    if every is not None:
        t["every"] = every
    return t


def m_wave(wid, when, at, to, base, delay=None, every=None, extra=(), line_ids=None):
    """A wave of the machines (on their team: the versus friend's if he leads them): `base` Clock Soldiers (scaled by the
    difficulty), one fewer with d07 `spring` stopped (the city dead brass: fewer and later, never under one); the `extra`
    spawns; wound full (they come from the city's plates: the scripted team is kept wound, below)."""
    sp = [{"spawn": {"team": "automata", "kind": "clock_soldier", "count": base, "at": at, "tag": "m_wave", "tags": [wid, "m_all"],
                     "order": {"do": "attack", "to": to}, "if": SPRING_RUNNING}},
          {"spawn": {"team": "automata", "kind": "clock_soldier", "count": max(1, base - 1), "at": at, "tag": "m_wave", "tags": [wid, "m_all"],
                     "order": {"do": "attack", "to": to}, "if": SPRING_STOPPED}}]
    for (k, n, c) in extra:
        e = {"team": "automata", "kind": k, "count": n, "at": at, "tag": "m_wave", "tags": [wid, "m_all"], "order": {"do": "attack", "to": to}}
        if c is not None:
            e["if"] = c
        sp.append({"spawn": e})
    t = {"id": wid, "when": when, "do": sp + [{"wind": {"team": "automata", "share": 1.0}}, {"ping": {"area": at}}]
         + ([{"say": line_ids}] if line_ids else [])}
    if delay is not None:
        t["delay"] = delay
    if every is not None:
        t["every"] = every
    return t


NORMAL_UP = {"difficulty": ["normal", "hard"]}
HARD = {"difficulty": ["hard"]}

TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"counter": {"name": "people_n", "count": {"tag": "people"}}},
        {"pace": {"tag": "people", "pace": PEOPLE_PACE}},
        # (the people of the road keep to their villages until the army comes; nothing of theirs is the raids' to burn)
        {"order": {"tag": "people", "do": "hold"}},
        {"clock": {"name": "fort", "secs": FORT_SECS}},
        {"wind": {"team": "automata", "share": 1.0}}]},
    # the versus friend's side: its objective, its first lines (none when nobody plays it)
    {"id": "setup_c", "when": {"all": [{"time": 0.6}, CRE_P]}, "do": [
        {"objective": {"id": "c_raid", "set": "active"}}, {"say": ["sc_1", "sc_other"]}, {"ping": {"area": "fort"}}]
     + [{"spawn": {"team": "creatures", "kind": k, "count": n, "at": "nw_camp", "tag": "c_band", "tags": ["c_all"], "fixed": True}}
        for (k, n) in [("raptor", 8), ("spitter", 2), ("tyrant_challenger", 1), ("hatchlings", 4)]]},
    {"id": "setup_m", "when": {"all": [{"time": 0.6}, AUT_P]}, "do": [
        {"objective": {"id": "m_raid", "set": "active"}}, {"say": ["hr_1", "hr_other"]}, {"ping": {"area": "fort"}}]
     + [{"spawn": {"team": "automata", "kind": k, "count": n, "at": "sw_camp", "tag": "m_band", "tags": ["m_all"], "fixed": True}}
        for (k, n) in [("clock_soldier", 6), ("springer", 2), ("netter", 1), ("cuckoo", 2)]] + [{"wind": {"team": "automata", "share": 1.0}}]},
    # the machines are wound from the city's plates (scripted: kept wound; the friend's too: he has no Winders here)
    {"id": "wind_m", "when": {"time": 4}, "every": 4, "do": [{"wind": {"team": "automata", "share": 1.0}}]},
    # the friend's side's supplies (versus: the swarm's food, the machines' cogs): to lay or make nothing much, but to spend
    {"id": "friend_food", "when": {"all": [{"time": FRIEND_EVERY}, {"any": [CRE_P, AUT_P]}, LIVE]}, "every": FRIEND_EVERY, "do": [
        {"give": {"team": "creatures", "gold": 15}}, {"give": {"team": "automata", "gold": 15}}]},
    # the garrison at its gates (scripted: solo and versus; the co-op friend's own)
    {"id": "garrison_hold", "when": {"time": 1.0}, "do": [{"order": {"tag": "garrison_n", "do": "hold"}}, {"order": {"tag": "garrison_s", "do": "hold"}}]},
    # ============================================================ PART 1: THE ROAD
    {"id": "march", "when": {"time": 2.0}, "do": [{"say": ["r_march", "n_road"]}, {"ping": {"area": "fort"}}, {"reveal": {"area": "fort", "side": "crown"}},
                                                 {"ping": {"area": "riacho"}}]},
    {"id": "wagon_say", "when": {"all": [{"time": 32}, P1]}, "do": [{"say": ["n_wagon"]}, {"ping": {"tag": "wagons"}}]},
    # two skies: the swarm's Hatchlings and the city's Swifts over the road (flyers that bite only flyers: they fight each other)
    {"id": "skies", "when": {"all": [{"time": 14}, P1, LIVE]}, "do": [
        {"spawn": {"team": "creatures", "kind": "hatchlings", "count": 6, "at": "sky_nw", "tag": "sky_c", "tags": ["c_all"],
                   "order": {"do": "patrol", "to": "sky_meet"}}},
        {"spawn": {"team": "automata", "kind": "cuckoo", "count": 4, "at": "sky_sw", "tag": "sky_m", "tags": ["m_all"],
                   "order": {"do": "patrol", "to": "sky_meet"}}},
        {"wind": {"team": "automata", "share": 1.0}}]},
    {"id": "skies_say", "when": {"fired": "skies"}, "delay": 6, "do": [{"say": ["n_skies", "t_skies", "r_skies"]}, {"ping": {"area": "sky_meet"}}]},
    # the villages: one of the army near their people: they join the column (they follow Father Tomasz)
] + [
    t for (fv, area, said) in [("folk_v1", "riacho", ["n_v1", "t_join"]), ("folk_v2", "lagoa", ["n_v2"])] for t in [
        {"id": "join_" + fv, "when": {"all": [{"near": {"team": "army", "to": fv, "within": JOIN}}, LIVE]}, "do": [
            {"order": {"tag": fv, "do": "follow", "leader": "tomasz", "within": 3}}, {"retag": {"tag": fv, "as": "column"}},
            {"counter": {"name": "joined", "count": {"tag": "column"}}}, {"say": said}, {"ping": {"area": area}}]},
    ]
] + [
    {"id": "village_ping2", "when": {"all": [{"fired": "join_folk_v1"}, {"not": {"fired": "join_folk_v2"}}, P1]}, "delay": 8, "do": [{"ping": {"area": "lagoa"}}]},
    # (the people who are not with the column hold in their village; those with it walk with Tomasz)
    # RAID 1: Raptors out of the scrub north of Riacho Seco, soon after the army reaches it (or at 1:00)
    c_wave("r1", {"all": [{"any": [{"fired": "join_folk_v1"}, {"time": 60}]}, P1, LIVE]}, "north_scrub", "riacho", 5, delay=6, line_ids=["n_r1"], fed=False),
    # RAID 2: a column of machines at Lagoa Branca (as the army reaches it, or at 1:50)
    m_wave("m1", {"all": [{"any": [{"near": {"team": "army", "to": "folk_v2", "within": 14}}, {"time": 110}]}, P1, LIVE]}, "south_scrub", "lagoa", 4,
           line_ids=["n_m1"], extra=[("springer", 2, None)]),
    {"id": "m1_vol", "when": {"all": [{"fired": "m1"}, VOL]}, "delay": 3, "do": [{"say": ["h_m1", "t_m1"]}]},
    # OWLS on the wagons, a little after the machines
    {"id": "owls", "when": {"all": [{"fired": "m1"}, P1, LIVE, {"count": {"tag": "wagons", "at_least": 1}}]}, "delay": 16, "do": [
        {"spawn": {"team": "automata", "kind": "ticking_owl", "count": 2, "at": "sky_sw", "tag": "owls", "tags": ["m_wave", "m_all"], "fixed": True}},
        {"wind": {"team": "automata", "share": 1.0}},
        {"say": ["n_owls", "r_owls"]}, {"objective": {"id": "owls", "set": "active"}}, {"ping": {"tag": "wagons"}}]},
    {"id": "owls_go", "when": {"all": [{"fired": "owls"}, NO_AUT, {"count": {"tag": "owls", "at_least": 1}}, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "owls", "do": "hunt", "prey": "wagons", "within": 60}}]},
    {"id": "owls_down", "when": {"all": [{"fired": "owls"}, {"dead": "owls"}]}, "do": [{"objective": {"id": "owls", "set": "done"}}, {"say": ["n_owls_down"]}]},
    {"id": "wagon_lost", "when": {"all": [{"fired": "setup"}, {"count": {"tag": "wagons", "below": 2}}, P1]}, "do": [{"say": ["n_wagon_lost"]}]},
    # RAID 3: Raptors and a Tyrant Challenger between the army and the fort (as it passes the dry pond, or at 3:10)
    c_wave("r2", {"all": [{"any": [{"count": {"team": "army", "area": "road_west", "at_least": 2}}, {"time": 190}]}, P1, LIVE]}, "west_scrub", "road_west", 5,
           line_ids=["n_r2"], extra=[("tyrant_challenger", 1, NORMAL_UP)], fed=False),
    # RAID 4: the machines again in the dry stretch, Netters among them (as the army crosses it, or at 4:20)
    m_wave("m2", {"all": [{"any": [{"count": {"team": "army", "area": "dry_stretch", "at_least": 2}}, {"time": 260}]}, P1, LIVE]}, "south_dry", "dry_stretch", 3,
           line_ids=["n_m2"], extra=[("netter", 2, None), ("springer", 1, NORMAL_UP)]),
    # the scripted raids: the Raptors go for the people; the machines press on to their mark
    {"id": "c_hunt", "when": {"all": [{"fired": "setup"}, NO_CRE, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "c_wave", "do": "hunt", "prey": "people", "within": 14}}]},
    {"id": "c_hunt_army", "when": {"all": [{"fired": "setup"}, NO_CRE, LIVE]}, "every": 5, "do": [
        {"order": {"tag": "c_wave", "do": "hunt", "prey_team": "army", "within": 10}}]},
    {"id": "m_press", "when": {"all": [{"fired": "setup"}, NO_AUT, LIVE]}, "every": 5, "do": [
        {"order": {"tag": "m_wave", "do": "hunt", "prey_team": "army", "within": 12}}]},
    {"id": "skies_circle", "when": {"all": [{"fired": "skies"}, LIVE]}, "every": 10, "do": [
        {"order": {"tag": "sky_c", "do": "patrol", "to": "sky_meet"}}, {"order": {"tag": "sky_m", "do": "patrol", "to": "sky_meet"}}]},
    # the people in the fort, counted (the exit takes them in)
    {"id": "in_first", "when": {"counter": {"name": "in_fort", "at_least": 1}}, "do": [{"say": ["n_in_first"]}]},
    # ============================================================ PART 2: THE FORT
    {"id": "fort_late", "when": {"all": [{"clock_out": "fort"}, P1, LIVE]}, "do": [{"say": ["n_fort_late"]}]},
    {"id": "part2", "when": {"all": [{"any": [{"count": {"team": "army", "area": "fort_approach", "at_least": 10}}, {"clock_out": "fort"}]}, LIVE]}, "do": [
        {"clock": {"name": "fort", "stop": True}}, {"objective": {"id": "fort_clock", "set": "hidden"}},
        {"objective": {"id": "owls", "set": "hidden"}},
        {"objective": {"id": "siege", "set": "active"}}, {"objective": {"id": "siege_clock", "set": "active"}},
        {"clock": {"name": "siege", "secs": SIEGE_SECS}},
        {"light": {"to": "dusk", "secs": 240}},
        {"give": {"team": "army", "gold": PAY_CHEST}},
        {"reveal": {"area": "fort_wide", "side": "crown"}},
        {"ping": {"area": "north_gate"}}, {"ping": {"area": "south_gate"}}]},
    # (the march done only if the army got there; the siege begun without it leaves the march undone, not failed)
    {"id": "arrived", "when": {"all": [{"count": {"team": "army", "area": "fort_approach", "at_least": 10}}, LIVE]}, "do": [
        {"objective": {"id": "march", "set": "done"}}]},
    {"id": "march_late", "when": {"all": [{"fired": "part2"}, {"not": {"fired": "arrived"}}]}, "do": [{"objective": {"id": "march", "set": "hidden"}}]},
    {"id": "p2_say", "when": {"fired": "part2"}, "delay": 1, "do": [{"say": ["n_arrive", "c_arrive", "r_arrive", "n_siege"]}]},
    {"id": "p2_say_y", "when": {"all": [{"fired": "part2"}, CROWN]}, "delay": 22, "do": [{"say": ["n_fort_yours"]}, {"ping": {"tag": "f_barracks"}}]},
    # THE SIEGE: three waves each, the creatures at the north gate, the machines at the south gate
    c_wave("siege_c1", {"fired": "part2"}, "north_out", "north_gate", 6, extra=[("spitter", 2, None), ("tyrant_challenger", 1, NORMAL_UP)]),
    m_wave("siege_m1", {"fired": "part2"}, "south_out", "south_gate", 5, extra=[("netter", 2, None)]),
    c_wave("siege_c2", {"fired": "part2"}, "north_ford", "north_gate", 6, delay=45, line_ids=["n_wave2"], extra=[("spitter", 1, NORMAL_UP)]),
    m_wave("siege_m2", {"fired": "part2"}, "south_ford", "south_gate", 4, delay=45, extra=[("springer", 2, None)]),
    c_wave("siege_c3", {"fired": "part2"}, "north_ford", "north_gate", 5, delay=90, extra=[("tyrant_challenger", 1, None)]),
    m_wave("siege_m3", {"fired": "part2"}, "south_ford", "south_gate", 4, delay=90, extra=[("pendulum", 1, NORMAL_UP)]),
    # the friend's side: he is told his waves came
    {"id": "more_c", "when": {"all": [{"fired": "siege_c2"}, CRE_P]}, "do": [{"say": ["sc_more"]}]},
    {"id": "more_m", "when": {"all": [{"fired": "siege_m2"}, AUT_P]}, "do": [{"say": ["hr_more"]}]},
    # THE FORD: a band of each comes over the river at the fort's ford, and they meet there
    {"id": "ford_meet", "when": {"fired": "part2"}, "delay": 20, "do": [
        {"spawn": {"team": "creatures", "kind": "raptor", "count": 4, "at": "ford", "tag": "c_ford", "tags": ["c_all"], "order": {"do": "attack", "to": "ford_east"}}},
        {"spawn": {"team": "automata", "kind": "clock_soldier", "count": 4, "at": "south_ford", "tag": "m_ford", "tags": ["m_all"], "order": {"do": "attack", "to": "ford_east"}}},
        {"wind": {"team": "automata", "share": 1.0}}]},
    {"id": "ford_fight", "when": {"all": [{"fired": "ford_meet"}, {"near": {"side": "creatures", "to_side": "automata", "within": 6}}, LIVE]}, "do": [
        {"say": ["n_ford", "t_ford"]}, {"ping": {"area": "ford_east"}}, {"reveal": {"area": "ford", "side": "crown", "secs": 30}}]},
    {"id": "siege_count", "when": {"all": [{"fired": "part2"}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "siege_left", "count": {"team": "creatures", "area": "fort_wide"}}},
        {"counter": {"name": "siege_left", "count": {"team": "automata", "area": "fort_wide"}, "plus": True}}]},
    # the scripted siege presses its gate (the friend's are his own)
    {"id": "siege_press_c", "when": {"all": [{"fired": "part2"}, NO_CRE, LIVE]}, "every": 7, "do": [
        {"order": {"tag": "c_wave", "do": "attack", "to": "north_gate", "idle": True}}]},
    {"id": "siege_press_m", "when": {"all": [{"fired": "part2"}, NO_AUT, LIVE]}, "every": 7, "do": [
        {"order": {"tag": "m_wave", "do": "attack", "to": "south_gate", "idle": True}}]},
    # RELIEVED: the last waves in, and fewer than three of either round the fort
    {"id": "relieved", "when": {"all": [{"fired": "siege_c3"}, {"fired": "siege_m3"}, {"counter": {"name": "siege_left", "below": 3}}, P2, LIVE]}, "delay": 3, "do": [
        {"objective": {"id": "siege", "set": "done"}}, {"say": ["n_relieved", "c_relieved"]}]},
    {"id": "draw_back", "when": {"all": [{"clock_out": "siege"}, {"not": {"fired": "relieved"}}, P2, LIVE]}, "do": [
        {"say": ["n_draw_back"]}, {"objective": {"id": "siege", "set": "done"}},
        {"order": {"tag": "c_wave", "do": "move", "to": "nw_trail"}}, {"order": {"tag": "m_wave", "do": "move", "to": "sw_trail"}}]},
    # ============================================================ PART 3: THE COUNCIL OF WAR
    {"id": "part3", "when": {"all": [{"any": [{"fired": "relieved"}, {"fired": "draw_back"}]}, LIVE]}, "delay": 5, "do": [
        {"clock": {"name": "siege", "stop": True}}, {"objective": {"id": "siege_clock", "set": "hidden"}},
        {"objective": {"id": "siege", "set": "hidden"}},
        # (what is left of the siege goes back over the river: the night's attack comes fresh)
        {"remove": {"tag": "c_wave"}}, {"remove": {"tag": "m_wave"}}, {"remove": {"tag": "c_ford"}}, {"remove": {"tag": "m_ford"}},
        {"remove": {"tag": "sky_c"}}, {"remove": {"tag": "sky_m"}},
        {"light": {"to": "dusk", "secs": 4}},
        # THE COUNCIL as a mid-match show (solo pauses): the frontier's rider, the city's envoy, the counsel, the King's frame
        {"show": {"pages": [
            {"still": "council", "lines": ["n_council", "ms_1", {"id": "ms_left", "if": FIELDS_LEFT}, {"id": "ms_burned", "if": FIELDS_BURNED},
                                           {"id": "ms_barra_held", "if": BARRA_HELD}, {"id": "ms_barra_burned", "if": BARRA_BURNED},
                                           {"id": "ms_lure", "if": LURE_USED}]},
            {"still": "council", "lines": [{"id": "v_1", "if": SPARED}, {"id": "v_2", "if": SPARED}, {"id": "r_v", "if": SPARED},
                                           {"id": "v_3", "if": SPARED}, {"id": "v_stopped", "if": {"all": [SPARED, SPRING_STOPPED]}},
                                           {"id": "n_letter", "if": EXECUTED}, {"id": "t_honest", "if": HONEST_MANY}]},
            {"still": "council", "lines": ["t_counsel1", "t_counsel2", "r_think"]},
            {"still": "rome", "lines": ["k_frame"]},
        ]}}]},
    # THE CHOICE, WHICH FIRE FIRST: the Crown's player answers the King (no canon: the player chooses; unanswered after two
    # minutes the match's seed picks, the same on every machine)
    {"id": "first_ask", "when": {"fired": "part3"}, "delay": 1, "do": [
        {"choice": {"id": "first", "side": "crown", "title": T("WHICH FIRE FIRST", "QUE FOGO PRIMEIRO", "QUÉ FUEGO PRIMERO"),
                    "line": "q_first", "default": "random", "time": 120,
                    "options": [
                        {"id": "brood", "label": T("THE SWARM FIRST", "O ENXAME PRIMEIRO", "EL ENJAMBRE PRIMERO"),
                         "about": T("The army goes north, up the rivers: the jungle front is fought first, while the swarm is fresh. The city waits and grows: its siege comes second, harder. Tonight the machines strike the fort.",
                                    "O exército vai para norte, rio acima: a frente da selva combate-se primeiro, com o enxame ainda fresco. A cidade espera e cresce: o seu cerco vem depois, mais duro. Esta noite as máquinas atacam o forte.",
                                    "El ejército va al norte, río arriba: el frente de la selva se combate primero, con el enjambre aún fresco. La ciudad espera y crece: su asedio viene después, más duro. Esta noche las máquinas atacan el fuerte."),
                         "do": [{"say": ["k_brood", "r_brood", "n_night_m", "t_night"]}]},
                        {"id": "clockwork", "label": T("THE CITY FIRST", "A CIDADE PRIMEIRO", "LA CIUDAD PRIMERO"),
                         "about": T("The army goes south, to the highlands: the siege of Concórdia is fought first, while the city is fresh. The swarm waits and spreads: the jungle front comes second, harder. Tonight the swarm strikes the fort.",
                                    "O exército vai para sul, para o planalto: o cerco de Concórdia combate-se primeiro, com a cidade ainda fresca. O enxame espera e espalha-se: a frente da selva vem depois, mais dura. Esta noite o enxame ataca o forte.",
                                    "El ejército va al sur, al altiplano: el asedio de Concórdia se combate primero, con la ciudad aún fresca. El enjambre espera y se extiende: el frente de la selva viene después, más duro. Esta noche el enjambre ataca el fuerte."),
                         "do": [{"say": ["k_clock", "r_clock", "n_night_c", "t_night"]}]}]}}]},
    # (THE FRAME: the listener named (the prince: campaign.json "heir" named) gives the answer in his own voice too)
    {"id": "prince_b", "when": {"all": [FIRST_BROOD, NAMED]}, "do": [{"say": ["p_brood"]}]},
    {"id": "prince_c", "when": {"all": [FIRST_CLOCK, NAMED]}, "do": [{"say": ["p_clock"]}]},
    # THE NIGHT: the fire not chosen strikes the fort first
    {"id": "night", "when": {"all": [{"any": [FIRST_BROOD, FIRST_CLOCK]}, P3, LIVE]}, "delay": 2, "do": [
        {"light": {"to": "night", "secs": 8}},
        {"objective": {"id": "night", "set": "active"}}, {"objective": {"id": "dawn", "set": "active"}},
        {"clock": {"name": "dawn", "secs": NIGHT_SECS, "scale": False}}]},
    {"id": "night_ping_c", "when": {"all": [{"fired": "night"}, FIRST_CLOCK]}, "do": [{"ping": {"area": "north_gate"}}]},
    {"id": "night_ping_m", "when": {"all": [{"fired": "night"}, FIRST_BROOD]}, "do": [{"ping": {"area": "south_gate"}}]},
] + [
    # the night's waves: the swarm at the north gate (the city chosen first) or the machines at the south gate (the swarm first)
    c_wave("n_c%d" % i, {"all": [{"fired": "night"}, FIRST_CLOCK, LIVE]}, at, "north_gate", base, delay=d,
           extra=ex, line_ids=lid)
    for i, (at, base, d, ex, lid) in enumerate([
        ("north_out", 7, 6, [("spitter", 2, None)], None),
        ("north_ford", 7, 34, [("tyrant_challenger", 1, None)], ["n_night_w"]),
        ("north_out", 7, 62, [("spitter", 2, None), ("tyrant_challenger", 1, HARD)], ["n_night_w"]),
        ("north_ford", 6, 90, [("brute", 1, NORMAL_UP), ("tyrant_challenger", 1, None), ("spitter", 1, None)], ["n_night_big"]),
    ])
] + [
    m_wave("n_m%d" % i, {"all": [{"fired": "night"}, FIRST_BROOD, LIVE]}, at, "south_gate", base, delay=d,
           extra=ex, line_ids=lid)
    for i, (at, base, d, ex, lid) in enumerate([
        ("south_out", 6, 6, [("springer", 2, None)], None),
        ("south_ford", 5, 34, [("netter", 2, None), ("ticking_owl", 2, NORMAL_UP)], ["n_night_w"]),
        ("south_out", 6, 62, [("springer", 2, None), ("pendulum", 1, HARD)], ["n_night_w"]),
        ("south_ford", 6, 90, [("pendulum", 1, NORMAL_UP), ("ballista", 1, None), ("springer", 1, None)], ["n_night_big"]),
    ])
] + [
    {"id": "night_press_c", "when": {"all": [{"fired": "night"}, NO_CRE, LIVE]}, "every": 6, "do": [
        {"order": {"tag": "c_wave", "do": "attack", "to": "fort_mid", "idle": True}}]},
    {"id": "night_press_m", "when": {"all": [{"fired": "night"}, NO_AUT, LIVE]}, "every": 6, "do": [
        {"order": {"tag": "m_wave", "do": "attack", "to": "fort_mid", "idle": True}}]},
    {"id": "night_owls", "when": {"all": [{"fired": "night"}, NO_AUT, LIVE]}, "every": 4, "do": [
        {"order": {"tag": "m_wave", "kind": "ticking_owl", "do": "attack", "to": "fort_mid", "idle": True}}]},
    {"id": "hurt_t", "when": {"all": [{"hp": {"tag": "tomasz", "below": 0.5}}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["t_hurt"]}, {"ping": {"tag": "tomasz"}}]},
    {"id": "hurt_r", "when": {"all": [{"hp": {"tag": "ruggieri", "below": 0.5}}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["r_hurt"]}, {"ping": {"tag": "ruggieri"}}]},
    # ============================================================ THE END
    # DAWN: the fort stands: won (the flags)
    {"id": "dawn", "when": {"all": [{"clock_out": "dawn"}, {"fired": "night"}, LIVE]}, "do": [
        {"clock": {"name": "dawn", "stop": True}}, {"light": {"to": "dawn", "secs": 6}}, {"say": ["n_dawn", "r_dawn"]},
        {"tally": {"flag": "sertao", "counter": "in_fort", "of": "people_n", "bands": [[0, "few"], [0.4, "some"], [0.7, "many"]]}},
        {"flag": {"fort": "held"}}]},
    {"id": "the_end", "when": {"fired": "dawn"}, "delay": 3, "do": [
        {"objective": {"id": "night", "set": "done"}}, {"objective": {"id": "c_raid", "set": "failed"}}, {"objective": {"id": "m_raid", "set": "failed"}},
        {"say": ["f_lost"]}, {"win": "crown"}]},
    # THE MAGAZINE GOES UP: lost (the friend's win in versus)
    {"id": "lost_mag", "when": {"all": [{"dead": "magazine"}, {"not": {"fired": "the_end"}}, {"not": {"fired": "f_won"}}, {"not": {"any": [CRE_P, AUT_P]}}]}, "do": [
        {"say": ["n_mag_down"]}, {"objective": {"id": "magazine", "set": "failed"}}, {"lose": "crown"}]},
    {"id": "f_won", "when": {"all": [{"dead": "magazine"}, {"any": [CRE_P, AUT_P]}, {"not": {"fired": "the_end"}}]}, "do": [
        {"say": ["f_won"]}, {"objective": {"id": "magazine", "set": "failed"}}, {"flag": {"fort": "fallen"}}]},
    {"id": "f_won_c", "when": {"all": [{"fired": "f_won"}, CRE_P]}, "do": [{"objective": {"id": "c_raid", "set": "done"}}, {"win": "creatures"}]},
    {"id": "f_won_m", "when": {"all": [{"fired": "f_won"}, AUT_P]}, "do": [{"objective": {"id": "m_raid", "set": "done"}}, {"win": "automata"}]},
]

# (an "if" inside an action's dictionary is not read by the engine: split those into triggers of their own)
fixed = []
for t in TR_:
    plain, cond_acts = [], []
    for a in t["do"]:
        (k, v), = a.items() if isinstance(a, dict) and len(a) == 1 else ((None, None),)
        if isinstance(v, dict) and "if" in v and k not in ("spawn",):
            cond_acts.append((v.pop("if"), a))
        else:
            plain.append(a)
    t["do"] = plain
    fixed.append(t)
    for j, (c, a) in enumerate(cond_acts):
        # (named "if_<id>__n": a sub-trigger of a "part..." trigger must not count as a part of its own: checkpoints)
        fixed.append({"id": "if_%s__%d" % (t["id"], j), "when": {"all": [{"fired": t["id"]}, c]}, "do": [a]})
M["triggers"] = fixed

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the army is bound to C7, ARMOUR and THE POWDER WAGON; the story's
# refusals on top (a march and a fort: nothing new is built, no workers; the fort's Barracks and Foundry train)
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID, story_deny={"army": ["town_hall", "cottage", "farm", "wall", "gate", "labourer", "messenger", "church", "missionary",
                                                 "powder_mill", "barracks", "horse_breeder", "foundry", "armoury"]})
for k in ("armour", "powder_wagon"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hub talks after d09 (campaign/campaign.json, campaign/hubs_grow.json)
OTHER = [
    ("General Ruggieri", "General Ruggieri", "General Ruggieri"),
    ("Father Tomasz", "Padre Tomasz", "Padre Tomasz"),
    ("Sergeant Hollins", "Sargento Hollins", "Sargento Hollins"),
    ("Major Teixeira", "Major Teixeira", "Mayor Teixeira"),
    ("Matteo Ruggieri, General of the army of Brazil, the guns' man since Virginia.", "Matteo Ruggieri, General do exército do Brasil, homem dos canhões desde a Virgínia.",
     "Matteo Ruggieri, General del ejército de Brasil, hombre de los cañones desde Virginia."),
    ("Father Tomasz, the frontier's vicar general, with the army of Brazil.", "O Padre Tomasz, vigário-geral da fronteira, com o exército do Brasil.",
     "El Padre Tomasz, vicario general de la frontera, con el ejército de Brasil."),
    ("Will Hollins of the Virginia volunteers, a sergeant now.", "Will Hollins, dos voluntários da Virgínia, agora sargento.",
     "Will Hollins, de los voluntarios de Virginia, ahora sargento."),
    ("Major Teixeira, commanding Fort Constantine on the São Francisco.", "Major Teixeira, comandante do Forte Constantino no São Francisco.",
     "Mayor Teixeira, al mando del Fuerte Constantino en el São Francisco."),
    ("A villager of the sertão, from a village on the road.", "Um aldeão do sertão, de uma aldeia da estrada.", "Un aldeano del sertón, de una aldea del camino."),
    # the King's study after d09 (campaign.json) and Ruggieri's dispatch
    ("You chose the swarm first, as Ruggieri did. Valadares had his guns before the floods.",
     "Escolheste o enxame primeiro, como Ruggieri. Valadares teve os seus canhões antes das cheias.",
     "Elegiste el enjambre primero, como Ruggieri. Valadares tuvo sus cañones antes de las crecidas."),
    ("And the city of gears had a year it should not have had.", "E a cidade das engrenagens teve um ano que não devia ter tido.",
     "Y la ciudad de engranajes tuvo un año que no debía haber tenido."),
    ("You chose the city first, as Ruggieri did. Father Ferrer had his siege lines by the spring.",
     "Escolheste a cidade primeiro, como Ruggieri. O Padre Ferrer teve as suas linhas de cerco na primavera.",
     "Elegiste la ciudad primero, como Ruggieri. El Padre Ferrer tuvo sus líneas de asedio en la primavera."),
    ("And the swarm came down the rivers the whole year we were away.", "E o enxame desceu os rios o ano inteiro em que estivemos fora.",
     "Y el enjambre bajó por los ríos todo el año que estuvimos fuera."),
    ("At the São Francisco a general asked me what to do, and I told him I did not know. He chose anyway. That is a general.",
     "No São Francisco um general perguntou-me o que fazer, e eu disse-lhe que não sabia. Ele escolheu na mesma. Isso é um general.",
     "En el São Francisco un general me preguntó qué hacer, y le dije que no lo sabía. Él eligió de todos modos. Eso es un general."),
    ("RUGGIERI'S DISPATCH", "O DESPACHO DE RUGGIERI", "EL DESPACHO DE RUGGIERI"),
    ("Ruggieri's dispatch", "O despacho de Ruggieri", "El despacho de Ruggieri"),
    ("Fort Constantine, at the crossroads of the São Francisco. Relieved. Both enemies seen at its gates in the same week.",
     "Forte Constantino, na encruzilhada do São Francisco. Socorrido. Os dois inimigos vistos aos seus portões na mesma semana.",
     "Fuerte Constantino, en la encrucijada del São Francisco. Socorrido. Los dos enemigos vistos a sus puertas en la misma semana."),
    ("The army marches north at noon, up the rivers. The southern road is watched, not held.",
     "O exército marcha para norte ao meio-dia, rio acima. A estrada do sul fica vigiada, não guardada.",
     "El ejército marcha al norte a mediodía, río arriba. El camino del sur queda vigilado, no guardado."),
    ("The army marches south at noon, to the highlands. The rivers are watched, not held.",
     "O exército marcha para sul ao meio-dia, para o planalto. Os rios ficam vigiados, não guardados.",
     "El ejército marcha al sur a mediodía, al altiplano. Los ríos quedan vigilados, no guardados."),
    ("The fort held, Highness. Two sieges in a week and a council in an evening. I chose, and I have not slept well since.",
     "O forte aguentou, Alteza. Dois cercos numa semana e um conselho numa noite. Escolhi, e não durmo bem desde então.",
     "El fuerte resistió, Alteza. Dos asedios en una semana y un consejo en una noche. Elegí, y no duermo bien desde entonces."),
    # the Clockmaker's and the Naturalist's hubs after d09
    ("Varenne went to the São Francisco under a white flag, for the city. He came back and did not speak at the council for a week.",
     "Varenne foi ao São Francisco sob bandeira branca, pela cidade. Voltou e não falou no conselho durante uma semana.",
     "Varenne fue al São Francisco bajo bandera blanca, por la ciudad. Volvió y no habló en el consejo durante una semana."),
    ("The Crown's army is at the crossroads. The masters say it will come here. I tell them the city has done nothing. They agree, all of them, at once.",
     "O exército da Coroa está na encruzilhada. Os mestres dizem que virá aqui. Digo-lhes que a cidade não fez nada. Concordam, todos, ao mesmo tempo.",
     "El ejército de la Corona está en la encrucijada. Los maestros dicen que vendrá aquí. Les digo que la ciudad no ha hecho nada. Están de acuerdo, todos, a la vez."),
    ("Ruggieri's rider came up the rivers with the word: the army is coming north. I have kept the Barra for this.",
     "O cavaleiro de Ruggieri subiu os rios com a notícia: o exército vem para norte. Guardei a Barra para isto.",
     "El jinete de Ruggieri subió por los ríos con la noticia: el ejército viene al norte. He guardado la Barra para esto."),
    ("Ruggieri's rider came up the rivers with the word: the army has gone south first. I am to hold the Barra a year more, with what I have.",
     "O cavaleiro de Ruggieri subiu os rios com a notícia: o exército foi primeiro para sul. Tenho de segurar a Barra mais um ano, com o que tenho.",
     "El jinete de Ruggieri subió por los ríos con la noticia: el ejército fue primero al sur. Debo resistir en la Barra un año más, con lo que tengo."),
]
for (en, pt, es) in OTHER:
    T(en, pt, es)

out = os.path.join(ROOT, "campaign", "missions", MID + ".json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)

# ---------------------------------------------------------------- the translations
seen = set()
import glob   # noqa: E402
for path in glob.glob(os.path.join(ROOT, "tools", "i18n", "*.txt")) + glob.glob(os.path.join(ROOT, "tools", "i18n", "campaign", "*.txt")):
    if os.path.basename(path) == MID + ".txt":
        continue
    for ln in open(path, encoding="utf-8").read().split("\n"):
        if ln.startswith("> "):
            seen.add(ln[2:].replace("\\n", "\n"))
rows = ["# Act 2's SECOND CROSSING d09_crossroads, \"Between Two Fires\" (campaign/missions/d09_crossroads.json, written with its texts",
        "# by tools/campaign/make_d09_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what",
        "# was built: docs/campaign_d09_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: sertão = sertão / sertón; swarm =",
        "# enxame / enjambre; powder wagon = carroça de pólvora / carro de pólvora; magazine = paiol / polvorín; Fort Constantine =",
        "# Forte Constantino / Fuerte Constantino.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
