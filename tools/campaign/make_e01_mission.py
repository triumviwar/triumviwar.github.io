#!/usr/bin/env python3
"""Writes campaign/missions/e01_brazil.json: Act 3's first mission, "Brazil After the Fires" (Brazil, 2781; THE AMERICAS
theatre's opening; the plan: docs/campaign_act3_plan.md "e01_brazil"; what was built: docs/campaign_e01_build.md), and
its Portuguese and Spanish (tools/i18n/campaign/e01_brazil.txt: every text here is written as T(english, pt, es)).
  python3 tools/campaign/make_brazil_retreat_map.py && python3 tools/campaign/make_e01_mission.py && python3 tools/i18n_build.py
The maps: tools/campaign/make_brazil_retreat_map.py (campaign:brazil_river from d10's Óbidos, campaign:brazil_south from
d11's siege of Concórdia; one area name, two maps: its AREAS). EVERY LINE IS A PLACEHOLDER for the owner.

The front the Crown fought SECOND at the crossing (d09 `first`) has grown past holding. The army of Brazil cannot win it
back this year; it can bring the colonists out to the coast. RUGGIERI tells it (his dispatch to Rome); the King frames.
TWO VERSIONS by d09 `first` (THE CROSSING'S CHOICE: no canon), each on its own map (Campaign.version_data):
  THE SOUTHERN ROAD (`first` brood: the city was fought second): Concórdia's machines come out of the city; the valley's
    people go down to the sea at Santos. (The default when the flag is missing, as d10's FRESH.)
  THE RIVER ROAD (`first` clockwork: the swarm was fought second): the swarm comes down the levee from upriver; the
    river towns' people go down the Amazon to Belém.
  THE ARMY OF BRAZIL (Crown, PURPLE, p1): RUGGIERI (a hero), the line, the riders, two guns, the Powder Wagon, the Virginia
    Volunteers (p01 `families` save), Fort Constantine's men (d09 `fort` held); NEW (THE ROSTER LADDER's C10): THE DRUMMER.
  THE MILITIA (Crown, BLUE: co-op p2, else scripted): the outposts' men; the Barra's garrison (river, d08 `barra` held) or
    the valley's militia (south, by d04 `colonists`).
  BRAZIL'S PEOPLE (Crown, YELLOW, scripted): three groups.
  THE FIRE FOUGHT SECOND (GREEN creatures on the river road, RED machines on the southern road: scripted solo; the SOLO
    PICK; versus p2).
  PART 1, THE FRONT BREAKS: hold the ford while the outposts fall back across it (a countdown; no base; the wagon).
  PART 2, THE COLUMN: the people walk to the coast in three groups; a group with the DRUMMER beside it keeps the army's
    pace (C10's lesson), without him it falls to a walk; raids on the column, the pursuit down the road.
  PART 3, THE SHIPS: hold the port's last bluff until the ships sail (3:00): every group on the quay before then.
  CARRIES: `colonists` few / some / many (the people aboard: `colonists_n`), `ruggieri` alive.
  MIRROR (THE FIRE, solo pick; versus): catch them on the road: keep more than half of the people from the ships, or
    break the harbour fort.
"""
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "e01_brazil"
sys.path.insert(0, HERE)
import make_brazil_retreat_map as MAPS      # noqa: E402

TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/e01_brazil.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
RIVER = {"version": "river"}
SOUTH = {"version": "south"}
JUNGLE_THIN = past("d10_jungle.jungle", "thin")                # the river road: the swarm one wave bigger
ISLAND_STANDING = past("d10_jungle.island", "standing")        # (and its oldest ground sends a Challenger more at the end)
SIEGE_HELD_OFF = past("d11_siege.siege", "held_off")           # the southern road: the city's machines one wave bigger
SIEGE_CLOSE = {"not": SIEGE_HELD_OFF}                          # (close: the great spring blown: no Ballistas)
FIELDS_LEFT = notpast("d05_aldeia.fields", "burned")          # São Rafael's people in the river column (the canon)
FIELDS_BURNED = past("d05_aldeia.fields", "burned")
BARRA_HELD = notpast("d08_rivers.barra", "burned")            # the Barra's garrison marches with the river column
BARRA_BURNED = past("d08_rivers.barra", "burned")
NAZ_ALL = past("d08_rivers.nazare", "all")                     # Nazaré's people in the river column
NAZ_SOME = past("d08_rivers.nazare", "some")
FOUGHT = past("d04_concordia.colonists", "fought")             # the valley's militia march gladly (fought) or a few (parley)
PARLEY = {"not": FOUGHT}
FORT_HELD = notpast("d09_crossroads.fort", "fallen")          # Fort Constantine's men in the column
SERTAO_MANY = past("d09_crossroads.sertao", "many")            # the sertão's people saved at the fort walk with them
HONEST_MANY = past("d07_spring.honest", "many")                # the honest masters' families on the southern road
FAMILIES = notpast("p01_leaf.families", "leave")              # the Virginia Volunteers (the saved families' sons)
COLUMN = {"playing": "column"}
NO_COLUMN = {"not": COLUMN}
FIRE = {"playing": "fire"}
NO_FIRE = {"not": FIRE}
SOLO_C = {"all": [COLUMN, NO_FIRE]}                            # the solo column: the danger is scripted
ENDED = [{"fired": "the_end"}, {"fired": "f_end"}, {"fired": "lost_end"}]
LIVE = {"not": {"any": ENDED}}
P1 = {"not": {"fired": "part2"}}
P2 = {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}]}
NORMAL_UP = {"difficulty": ["normal", "hard"]}
HARD = {"difficulty": "hard"}

# ---------------------------------------------------------------- numbers
FRONT_SECS = 200           # Part 1: the front breaks (not scaled: a longer hold is no easier)
FORD_WAVES = [35, 80, 125, 165]   # Part 1: the waves at the ford (seconds)
CHASE_AT = 18              # Part 1: the danger comes after the outposts' people
SLOW, DRUM = 0.35, 0.62    # Part 2: the people's pace alone / with the Drummer beside them (a Labourer 74 px/s: 26 / 46; the line 62)
DRUM_TILES = 6             # (the Drummer's ring is five tiles; a group's people stand round him)
PURSUE_FIRST, PURSUE_EVERY, PURSUE_N = 30, 45, 3   # Part 2: the pursuit down the road behind the column
RAIDS = [(22, "flank_c"), (68, "flank_b"), (114, "flank_a"), (160, "flank_b")]   # Part 2: raids on the column out of the forest
PASS_LATE = 110            # Part 2: the people waiting before the pass go through it anyway this long after (NO WAITING)
PART3_LATE = 300           # Part 3 begins anyway this long after Part 2 (NO WAITING)
SHIPS_SECS = 180           # Part 3: the ships sail (not scaled)
ASSAULTS = [20, 75, 130]      # Part 3: the assaults on the bluff
LAST_BOATS = 45            # every group aboard: the last boats for the army leave this long after (NO WAITING)
FORT_HP = 3000             # the harbour fort (the stone fort over the quay: a Town Hall's 1,600 is a farmhouse's)
LOSE_SHARE, SOME, MANY = 0.25, 0.5, 0.8   # aboard as a share of the people: lost / few / some / many
FIRE_WIN = 0.5             # the mirror: under this share aboard when the ships sail, the fire wins
CHEST_GOLD, CHEST_POWDER = 400, 150       # Part 3: the port's treasury (its Barracks trains for the army)
F_REINF_EVERY = 55         # the mirror: the fire player's own waves come down this often

# ================================================================== the areas: the southern road's are the mission's own,
# the river road's ride on its version (Campaign.version_data: one area name, two maps)
areas = dict(MAPS.AREAS["south"])
ROAD = MAPS.ROAD
FALL1 = ["op", "op_way", "ford_far", "ford", "ford_hold", "muster"]
FALL2 = ["op2", "ford_far", "ford", "ford_hold", "muster"]
FORD_ROUTE = ["edge", "ford_far", "ford", "ford_hold", "muster"]
GROUP_ROUTE = {   # the groups' roads to the pass (they wait there for it to be clear), by version (the towns stand apart)
    "river": {"g1": ["muster", "r1", "pass_wait"], "g3": ["hamlet", "r1", "pass_wait"], "g2": ["town", "r4"] + ROAD[4:]},
    "south": {"g1": ["muster", "r1", "pass_wait"], "g3": ["hamlet", "pass_wait"], "g2": ["town", "pass_wait"]},
}
AFTER_PASS = ["pass_at", "r3", "r4", "r5", "r6", "bluff_mid", "quay_in"]      # (and on through it to the quay)
WAITS = {"river": ["g1", "g3"], "south": ["g1", "g2", "g3"]}

# ================================================================== the units
KIT = {"lock": "matchlock", "bayonet": True}
COL = {"team": "column", "at": "col_start", "fixed": True}
units = [
    # ---- the army of Brazil (the player): Ruggieri (a hero), the Drummer (NEW: C10), the line, the riders, the guns
    dict(COL, kind="dismounted", **{"as": "ruggieri_general", "count": 1, "tag": "ruggieri", "tags": ["leaders"]}),
    dict(COL, kind="band", count=1, tag="drummer"),
    dict(COL, kind="musketeer", count=8, tag="line", kit=KIT),
    dict(COL, kind="musketeer", count=4, tag="line", tags=["armoured"], kit=dict(KIT, armour=True)),
    dict(COL, kind="dragoon", count=3, tag="riders"),
    dict(COL, kind="cannon", count=2, tag="guns"),
    dict(COL, kind="powder_wagon", count=1, tag="wagons"),
    # (p01 `families` save: the Virginia Volunteers, the saved families' sons, under Sergeant Hollins)
    dict(COL, kind="musketeer", **{"as": "hollins_sergeant", "count": 1, "tag": "line", "tags": ["volunteers"], "if": FAMILIES}),
    dict(COL, kind="musketeer", count=3, tag="line", tags=["volunteers"], kit=KIT, **{"if": FAMILIES}),
    # (d09 `fort` held: Major Teixeira and Fort Constantine's men)
    dict(COL, kind="dismounted", **{"as": "fort_commander", "count": 1, "tag": "line", "tags": ["fort_men"], "if": FORT_HELD}),
    dict(COL, kind="musketeer", count=3, tag="line", tags=["fort_men"], kit=KIT, **{"if": FORT_HELD}),
    # (the fire played alone: the column has its whole strength)
    dict(COL, kind="musketeer", count=4, tag="line", kit=KIT, **{"if": NO_COLUMN}),
]
# ---- the militia (co-op p2): the outposts' men; the Barra's garrison (river) or the valley's militia (south)
for (n, at, tag, cond) in [(3, "op", "op_men", None), (2, "op2", "op2_men", None)]:
    units += [
        {"team": "militia", "kind": "musketeer", "count": n, "at": at, "tag": tag, "tags": ["militia"], "fixed": True, "kit": KIT, "if": RIVER},
        {"team": "militia", "kind": "musketeer", "as": "valley_militia", "count": n, "at": at, "tag": tag, "tags": ["militia"], "fixed": True, "if": SOUTH},
    ]
units += [
    {"team": "militia", "kind": "musketeer", "as": "barra_sergeant", "count": 1, "at": "town", "tag": "home_men", "tags": ["militia"], "fixed": True,
     "if": {"all": [RIVER, BARRA_HELD]}},
    {"team": "militia", "kind": "musketeer", "count": 4, "at": "town", "tag": "home_men", "tags": ["militia"], "fixed": True, "kit": KIT,
     "if": {"all": [RIVER, BARRA_HELD]}},
    {"team": "militia", "kind": "musketeer", "count": 2, "at": "town", "tag": "home_men", "tags": ["militia"], "fixed": True, "kit": KIT,
     "if": {"all": [RIVER, BARRA_BURNED]}},
    {"team": "militia", "kind": "cuirassier", "as": "arruda", "count": 1, "at": "town", "tag": "home_men", "tags": ["militia"], "fixed": True, "if": SOUTH},
    {"team": "militia", "kind": "musketeer", "as": "valley_militia", "count": 2, "at": "town", "tag": "home_men", "tags": ["militia"], "fixed": True, "if": SOUTH},
    {"team": "militia", "kind": "musketeer", "as": "valley_militia", "count": 3, "at": "town", "tag": "home_men", "tags": ["militia"], "fixed": True,
     "if": {"all": [SOUTH, FOUGHT]}},
    {"team": "militia", "kind": "cuirassier", "as": "rancher", "count": 2, "at": "town", "tag": "home_men", "tags": ["militia"], "fixed": True,
     "if": {"all": [SOUTH, FOUGHT]}},
]
# ---- Brazil's people: three groups (the outposts' families fall back across the ford; the town; the hamlet)
PEOPLE = {   # group: [(area, how many, condition)]
    "g1": [("op", 4, None), ("op2", 3, None)],
    "g2": [("town", 6, None), ("town", 2, {"all": [RIVER, NAZ_ALL]}), ("town", 1, {"all": [RIVER, NAZ_SOME]}),
           ("town", 2, {"all": [SOUTH, FOUGHT]}), ("town", 1, {"all": [SOUTH, PARLEY]}), ("town", 2, SERTAO_MANY)],
    "g3": [("hamlet", 5, None), ("hamlet", 3, {"all": [RIVER, FIELDS_LEFT]}), ("hamlet", 2, {"all": [SOUTH, HONEST_MANY]})],
}
for g, rows in PEOPLE.items():
    for (at, n, c) in rows:
        for (vc, role) in [(RIVER, "villager"), (SOUTH, "colonist")]:
            cond = vc if c is None else {"all": [vc, c]}
            units.append({"team": "people", "kind": "labourer", "as": role, "count": n, "at": at, "tag": g, "tags": ["people"], "fixed": True, "if": cond})
# ---- the fire played (the solo pick, versus): its first strength at the edge
units += [
    {"team": "fire", "kind": "raptor", "count": 8, "at": "edge", "tag": "f_army", "fixed": True, "if": {"all": [FIRE, RIVER]}},
    {"team": "fire", "kind": "spitter", "count": 3, "at": "edge", "tag": "f_army", "fixed": True, "if": {"all": [FIRE, RIVER]}},
    {"team": "fire", "kind": "tyrant_challenger", "count": 1, "at": "edge", "tag": "f_army", "fixed": True, "if": {"all": [FIRE, RIVER]}},
    {"team": "fire", "kind": "clock_soldier", "count": 6, "at": "edge", "tag": "f_army", "fixed": True, "if": {"all": [FIRE, SOUTH]}},
    {"team": "fire", "kind": "springer", "count": 2, "at": "edge", "tag": "f_army", "fixed": True, "if": {"all": [FIRE, SOUTH]}},
    {"team": "fire", "kind": "netter", "count": 1, "at": "edge", "tag": "f_army", "fixed": True, "if": {"all": [FIRE, SOUTH]}},
    {"team": "fire", "kind": "winder", "count": 2, "at": "edge", "tag": "f_army", "fixed": True, "if": {"all": [FIRE, SOUTH]}},
]

# ================================================================== the buildings: the port (the harbour fort, its Barracks)
def at_of(name):
    a = areas[name]
    return [a[0], a[1]]


buildings = [
    {"team": "column", "kind": "town_hall", "at": at_of("fort_at"), "tag": "harbour_fort", "tags": ["port_b"],
     "name": T("The harbour fort", "O forte do porto", "El fuerte del puerto")},
    {"team": "column", "kind": "barracks", "at": at_of("barracks_at"), "tag": "port_barracks", "tags": ["port_b"],
     "name": T("The harbour's Barracks", "O Quartel do porto", "El Cuartel del puerto")},
]
# (the river road's port stands elsewhere: its buildings ride on the version too, as conditional twins)
RA = MAPS.AREAS["river"]
for b in list(buildings):
    b["if"] = SOUTH
    r = dict(b)
    r["at"] = [RA["fort_at" if b["kind"] == "town_hall" else "barracks_at"][0], RA["fort_at" if b["kind"] == "town_hall" else "barracks_at"][1]]
    r["if"] = RIVER
    buildings.append(r)

# ================================================================== the objectives
objectives = [
    # ---- the army of Brazil
    {"id": "people_live", "side": "column", "primary": True, "kind": "manual",
     "text": T("BRAZIL'S PEOPLE: bring them to the ships ({aboard} of {people_n} aboard). If fewer than a quarter are aboard when the ships sail, the army has failed them.",
               "A GENTE DO BRASIL: leve-a aos navios ({aboard} de {people_n} a bordo). Se menos de um quarto estiver a bordo quando os navios zarparem, o exército falhou-lhe.",
               "LA GENTE DEL BRASIL: llévala a los barcos ({aboard} de {people_n} a bordo). Si menos de un cuarto está a bordo cuando zarpen los barcos, el ejército le ha fallado."),
     "phone": T("People aboard: {aboard} of {people_n}.", "A bordo: {aboard} de {people_n}.", "A bordo: {aboard} de {people_n}.")},
    {"id": "fort_live", "side": "column", "primary": True, "kind": "protect", "tag": "harbour_fort",
     "text": T("The harbour fort at the port must stand: the ships load under its guns.",
               "O forte do porto tem de ficar de pé: os navios carregam debaixo dos seus canhões.",
               "El fuerte del puerto debe seguir en pie: los barcos cargan bajo sus cañones.")},
    {"id": "ford", "side": "column", "primary": False, "kind": "manual",
     "text": T("THE FORD: hold the ford with the line and the guns. The outposts on the far side are falling back across it. The front breaks in {clock:front}.",
               "O VAU: segure o vau com a linha e os canhões. Os postos avançados do outro lado estão a recuar por ele. A frente quebra em {clock:front}.",
               "EL VADO: sostén el vado con la línea y los cañones. Los puestos avanzados del otro lado se repliegan por él. El frente se rompe en {clock:front}."),
     "phone": T("Hold the ford: the front breaks in {clock:front}.", "Segure o vau: a frente quebra em {clock:front}.", "Sostén el vado: el frente se rompe en {clock:front}.")},
    {"id": "outposts", "side": "column", "primary": False, "kind": "manual",
     "text": T("Cover the outposts' families as they come over the ford: {g1_in} of {g1_n} across.",
               "Cubra as famílias dos postos avançados enquanto atravessam o vau: {g1_in} de {g1_n} do lado de cá.",
               "Cubre a las familias de los puestos avanzados mientras cruzan el vado: {g1_in} de {g1_n} a este lado.")},
    {"id": "column", "side": "column", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE COLUMN: the people walk to the coast by themselves, in three groups. Alone a group only walks; with your DRUMMER beside it (six tiles) it keeps the army's pace. Move him from group to group, and keep the line between them and the forest.",
               "A COLUNA: a gente caminha para a costa sozinha, em três grupos. Sozinho um grupo só caminha; com o seu TAMBOR ao lado (seis casas) acompanha o passo do exército. Leve-o de grupo em grupo, e mantenha a linha entre eles e a floresta.",
               "LA COLUMNA: la gente camina hacia la costa sola, en tres grupos. Solo, un grupo apenas camina; con tu TAMBOR al lado (seis casillas) lleva el paso del ejército. Llévalo de grupo en grupo, y mantén la línea entre ellos y el bosque."),
     "phone": T("Walk the Drummer beside a group: it keeps the army's pace.", "Leve o Tambor ao lado de um grupo: acompanha o passo do exército.",
                "Lleva al Tambor junto a un grupo: lleva el paso del ejército.")},
    {"id": "rear", "side": "column", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE REARGUARD: they come down the road behind the column. Leave a few men and a gun at the back.",
               "A RETAGUARDA: descem a estrada atrás da coluna. Deixe alguns homens e um canhão na traseira.",
               "LA RETAGUARDIA: bajan por el camino tras la columna. Deja a unos hombres y un cañón atrás.")},
    {"id": "pass", "side": "column", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE PASS: they got ahead of you and hold the pass on the road ahead ({amb_left} left). The people stop before it: clear it and they go on. They will not wait for ever.",
               "O DESFILADEIRO: passaram-lhe à frente e seguram o desfiladeiro na estrada adiante ({amb_left} restam). A gente para diante dele: limpe-o e seguem. Não esperam para sempre.",
               "EL PASO: se te adelantaron y sostienen el paso en el camino de delante ({amb_left} quedan). La gente se detiene ante él: límpialo y siguen. No esperarán para siempre."),
     "phone": T("Clear the pass ahead: {amb_left} left.", "Limpe o desfiladeiro adiante: {amb_left} restam.", "Limpia el paso de delante: {amb_left} quedan.")},
    {"id": "ships", "side": "column", "primary": False, "kind": "countdown", "clock": "ships", "hidden": True,
     "text": T("THE SHIPS sail in {clock:ships}. Hold the bluff before the quay; every group must be on the quay before then. The harbour's Barracks trains for you.",
               "OS NAVIOS zarpam em {clock:ships}. Segure o alto diante do cais; todos os grupos têm de estar no cais antes disso. O Quartel do porto treina para si.",
               "LOS BARCOS zarpan en {clock:ships}. Sostén el alto ante el muelle; todos los grupos deben estar en el muelle antes. El Cuartel del puerto entrena para ti.")},
    # ---- the fire (the solo pick, versus)
    {"id": "f_catch", "side": "fire", "primary": False, "kind": "manual",
     "text": T("CATCH THEM ON THE ROAD: keep more than half of the people from the ships ({aboard} of {people_n} aboard so far), or break the harbour fort. More of yours come out every minute at the edge.",
               "APANHE-OS NA ESTRADA: impeça mais de metade da gente de chegar aos navios ({aboard} de {people_n} a bordo até agora), ou derrube o forte do porto. Mais dos seus saem a cada minuto na borda.",
               "ATRÁPALOS EN EL CAMINO: impide que más de la mitad de la gente llegue a los barcos ({aboard} de {people_n} a bordo por ahora), o derriba el fuerte del puerto. Más de los tuyos salen cada minuto en el borde."),
     "phone": T("Keep half of them from the ships: {aboard} of {people_n} aboard.", "Impeça metade de chegar aos navios: {aboard} de {people_n} a bordo.",
                "Impide que la mitad llegue a los barcos: {aboard} de {people_n} a bordo.")},
    {"id": "f_ships", "side": "fire", "primary": False, "kind": "countdown", "clock": "ships", "hidden": True,
     "text": T("The ships sail in {clock:ships}.", "Os navios zarpam em {clock:ships}.", "Los barcos zarpan en {clock:ships}.")},
]

M = {
    "id": MID,
    "title": T("Brazil After the Fires", "O Brasil Depois dos Fogos", "Brasil Después de los Fuegos"),
    "summary": T("Brazil, 2781. The front fought second has grown past holding. General Ruggieri brings the colonists out to the ships.",
                 "Brasil, 2781. A frente combatida em segundo lugar cresceu para lá do que se podia segurar. O General Ruggieri leva os colonos aos navios.",
                 "Brasil, 2781. El frente combatido en segundo lugar ha crecido más allá de lo que se podía sostener. El General Ruggieri lleva a los colonos a los barcos."),
    "map": "campaign:brazil_south",
    "voice": "e01",
    "light": "day",
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["d10_jungle", "d11_siege"],
    "versions": {
        "pick": [{"if": past("d09_crossroads.first", "clockwork"), "id": "river"}],
        "default": "south",
        "labels": {
            "south": T("THE SOUTHERN ROAD: at the crossing the swarm was fought first, so the city had a year. Its machines come down the highlands.",
                       "A ESTRADA DO SUL: na encruzilhada o enxame foi combatido primeiro, por isso a cidade teve um ano. As suas máquinas descem o planalto.",
                       "EL CAMINO DEL SUR: en la encrucijada se combatió primero al enjambre, así que la ciudad tuvo un año. Sus máquinas bajan de la meseta."),
            "river": T("THE RIVER ROAD: at the crossing the city was fought first, so the swarm had a year. It comes down the rivers.",
                       "A ESTRADA DO RIO: na encruzilhada a cidade foi combatida primeiro, por isso o enxame teve um ano. Desce pelos rios.",
                       "EL CAMINO DEL RÍO: en la encrucijada se combatió primero a la ciudad, así que el enjambre tuvo un año. Baja por los ríos."),
        },
    },
    "version_data": {
        "river": {"map": "campaign:brazil_river", "areas": dict(MAPS.AREAS["river"]), "light": "jungle_day",
                  "teams": {"fire": {"faction": "brood", "colour": 2}}},
    },
    "modes": ["solo", "coop", "versus"],
    "solo_sides": ["column", "fire"],
    "sides": [
        {"id": "column", "name": T("The Army of Brazil", "O Exército do Brasil", "El Ejército del Brasil"),
         "about": T("General Ruggieri and the army of Brazil: the line, the riders, two guns, the Powder Wagon and a Drummer; the militia; three groups of Brazil's people.",
                    "O General Ruggieri e o exército do Brasil: a linha, os cavaleiros, dois canhões, a Carroça de Pólvora e um Tambor; a milícia; três grupos da gente do Brasil.",
                    "El General Ruggieri y el ejército del Brasil: la línea, los jinetes, dos cañones, el Carro de Pólvora y un Tambor; la milicia; tres grupos de la gente del Brasil.")},
        {"id": "fire", "name": T("The Fire Fought Second", "O Fogo Combatido em Segundo", "El Fuego Combatido en Segundo"),
         "about": T("What the army fought second at the crossing: the swarm on the river road, or the city's machines on the southern road.",
                    "O que o exército combateu em segundo lugar na encruzilhada: o enxame na estrada do rio, ou as máquinas da cidade na estrada do sul.",
                    "Lo que el ejército combatió en segundo lugar en la encrucijada: el enjambre en el camino del río, o las máquinas de la ciudad en el camino del sur.")},
    ],
    "teams": [
        {"id": "column", "side": "column", "faction": "crown", "colour": 4, "start": "none", "camera": "col_start", "gold": 250, "powder": 250,
         "techs": ["matchlock", "bayonet", "charge", "armour", "charges", "quadrant"],
         "control": {"solo": "p1", "coop": "p1", "versus": "p1", "foe": "script"}},
        {"id": "militia", "side": "column", "faction": "crown", "colour": 0, "start": "none", "camera": "town", "gold": 0, "powder": 120,
         "techs": ["matchlock", "bayonet"],
         "roster": {"deny": ["town_hall", "cottage", "farm", "wall", "gate", "barracks", "powder_mill", "horse_breeder", "foundry", "armoury",
                             "church", "missionary", "nitre_beds", "labourer"]},
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "people", "side": "column", "faction": "crown", "colour": 3, "start": "none", "camera": "town",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "fire", "side": "fire", "faction": "clockwork", "colour": 1, "start": "none", "camera": "edge", "gold": 0, "powder": 0,
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": areas,
    "counters": {k: {"start": 0} for k in ["people_n", "aboard", "g1_n", "g1_in", "wave_n", "amb_left"]},
    "exits": [{"area": "quay", "tag": "people", "counter": "aboard"}],
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["ruggieri"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "column", "portrait": "res://campaign/hub/rome_king_face.png"},
        "ruggieri": {"name": T("General Ruggieri", "General Ruggieri", "General Ruggieri"), "side": "column"},
        "hollins": {"name": T("Sergeant Hollins", "Sargento Hollins", "Sargento Hollins"), "side": "column"},
        "sergeant": {"name": T("The Barra's sergeant", "O sargento da Barra", "El sargento de la Barra"), "side": "column"},
        "arruda": {"name": T("Captain Arruda", "Capitão Arruda", "Capitán Arruda"), "side": "column"},
        "teixeira": {"name": T("Major Teixeira", "Major Teixeira", "Mayor Teixeira"), "side": "column", "portrait": "res://campaign/portraits/commander.png"},
        "narrator": {"name": T("Brazil", "O Brasil", "El Brasil"), "side": "column"},
        "firen": {"name": T("The Road", "A Estrada", "El Camino"), "side": "fire"},
    },
    "lines": {},
    "stills": {},
    "next": {"column": "", "fire": ""},
}

L = M["lines"]
UNTIL_P2 = {"n_lesson", "n_fall", "n_chase", "h_cover", "n_wave", "r_wave", "op_in", "s_op", "a_op"}
UNTIL_P3 = {"n_raid", "r_raid", "n_pursue", "n_drum_on", "n_slow", "r_drum", "n_group_in", "n_ambush", "r_ambush", "n_pass_clear", "n_pass_late"}


def line(lid, who, en, pt, es, to=None, until=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    if until:
        L[lid]["until"] = until
    elif lid in UNTIL_P2:
        L[lid]["until"] = "part2"
    elif lid in UNTIL_P3:
        L[lid]["until"] = "part3"
    return lid


CO, FI = "column", "fire"
# ---- the opening (the King frames; Ruggieri tells it from his dispatch)
line("k_open1", "king", "Act three. It left Brazil in our own ships, in crates with our seal on them. But first Brazil itself.",
     "Terceiro acto. Saiu do Brasil nos nossos próprios navios, em caixotes com o nosso selo. Mas primeiro o próprio Brasil.",
     "Tercer acto. Salió del Brasil en nuestros propios barcos, en cajas con nuestro sello. Pero primero el propio Brasil.")
line("k_open2", "king", "At the São Francisco you chose which fire to fight first. The other one did not wait for us.",
     "No São Francisco escolheu que fogo combater primeiro. O outro não esperou por nós.",
     "En el São Francisco elegiste qué fuego combatir primero. El otro no nos esperó.")
line("k_open_s", "king", "The city had a year behind its walls. Ruggieri wrote to me from the southern road.",
     "A cidade teve um ano atrás das suas muralhas. Ruggieri escreveu-me da estrada do sul.",
     "La ciudad tuvo un año tras sus murallas. Ruggieri me escribió desde el camino del sur.")
line("k_open_r", "king", "The swarm had a year on the rivers. Ruggieri wrote to me from the river road.",
     "O enxame teve um ano nos rios. Ruggieri escreveu-me da estrada do rio.",
     "El enjambre tuvo un año en los ríos. Ruggieri me escribió desde el camino del río.")
line("r_open1", "ruggieri", "Brazil, 2781. I have commanded this army for eleven years. This was the first order I gave to go backwards.",
     "Brasil, 2781. Comando este exército há onze anos. Esta foi a primeira ordem que dei para recuar.",
     "Brasil, 2781. Mando este ejército desde hace once años. Esta fue la primera orden que di de retroceder.")
line("r_open_s", "ruggieri", "The machines came out of Concórdia in the spring. The valley's people had one road, down the highlands to Santos.",
     "As máquinas saíram de Concórdia na primavera. A gente do vale tinha uma estrada, pelo planalto abaixo até Santos.",
     "Las máquinas salieron de Concórdia en primavera. La gente del valle tenía un camino, meseta abajo hasta Santos.")
line("r_open_r", "ruggieri", "The swarm came down the rivers with the flood. The river towns' people had one road, down the Amazon to Belém.",
     "O enxame desceu os rios com a cheia. A gente das vilas do rio tinha uma estrada, Amazonas abaixo até Belém.",
     "El enjambre bajó por los ríos con la crecida. La gente de los pueblos del río tenía un camino, Amazonas abajo hasta Belém.")
line("k_open_f", "king", "Ruggieri wrote this down as it happened. Here is how it would have gone if the road had been theirs.",
     "Ruggieri escreveu isto à medida que acontecia. Eis como teria sido se a estrada tivesse sido deles.",
     "Ruggieri lo escribió según ocurría. He aquí cómo habría sido si el camino hubiera sido suyo.")
line("n_open_f", "firen", "Brazil, 2781. A column of the Crown on the one road to the sea, with the people of a whole country walking in it.",
     "Brasil, 2781. Uma coluna da Coroa na única estrada para o mar, com a gente de um país inteiro a caminhar nela.",
     "Brasil, 2781. Una columna de la Corona en el único camino al mar, con la gente de un país entero caminando en ella.")
# ---- part 1: the front breaks
line("r_1", "ruggieri", "We are a year too late for this country. We can still get its people to the ships.",
     "Chegámos um ano tarde demais para este país. Ainda podemos levar a sua gente aos navios.",
     "Llegamos un año tarde para este país. Todavía podemos llevar a su gente a los barcos.", CO)
line("n_lesson", "narrator", "Hold the ford with the line and the guns. The outposts on the far side are falling back across it with their families. There is no base here: the Powder Wagon refills the muskets.",
     "Segure o vau com a linha e os canhões. Os postos avançados do outro lado estão a recuar por ele com as suas famílias. Não há base aqui: a Carroça de Pólvora reabastece os mosquetes.",
     "Sostén el vado con la línea y los cañones. Los puestos avanzados del otro lado se repliegan por él con sus familias. Aquí no hay base: el Carro de Pólvora recarga los mosquetes.", CO)
line("n_fall", "narrator", "The outposts fall back toward the ford. Their families walk ahead of the soldiers.",
     "Os postos avançados recuam para o vau. As famílias caminham à frente dos soldados.",
     "Los puestos avanzados se repliegan hacia el vado. Las familias caminan delante de los soldados.", CO)
line("s_op", "sergeant", "General! The creek post is coming in. They are right behind us.",
     "General! O posto do igarapé está a chegar. Eles vêm mesmo atrás de nós.",
     "¡General! El puesto del arroyo está llegando. Vienen justo detrás de nosotros.", CO)
line("a_op", "arruda", "General! The batteries are coming in. The machines are out of the gates behind them.",
     "General! As baterias estão a chegar. As máquinas saíram das portas atrás delas.",
     "¡General! Las baterías están llegando. Las máquinas han salido de las puertas tras ellas.", CO)
line("n_chase", "narrator", "They come after the outposts' families. Send riders over the ford to cover them.",
     "Vêm atrás das famílias dos postos avançados. Mande cavaleiros por cima do vau para as cobrir.",
     "Vienen tras las familias de los puestos avanzados. Manda jinetes por el vado para cubrirlas.", CO)
line("h_cover", "hollins", "Volunteers, at the water. Let the women and the little ones through first.",
     "Voluntários, à água. Deixem passar primeiro as mulheres e os pequenos.",
     "Voluntarios, al agua. Dejad pasar primero a las mujeres y a los pequeños.", CO)
line("op_in", "narrator", "The outposts' families are over the ford.", "As famílias dos postos avançados atravessaram o vau.",
     "Las familias de los puestos avanzados han cruzado el vado.", CO)
line("n_wave", "narrator", "They come at the ford.", "Vêm ao vau.", "Vienen al vado.", CO)
line("r_wave", "ruggieri", "Canister. Let them come to the water.", "Metralha. Deixem-nos vir até à água.", "Metralla. Dejadlos venir hasta el agua.", CO)
line("t_fort", "teixeira", "Fort Constantine's men are with you, General. We held one fort; we can walk one road.",
     "Os homens do Forte Constantino estão consigo, General. Segurámos um forte; podemos andar uma estrada.",
     "Los hombres del Fuerte Constantino están con usted, General. Sostuvimos un fuerte; podemos andar un camino.", CO)
line("h_vol", "hollins", "The Virginia Volunteers, General. My father's farm was saved by your guns. We owe you a road.",
     "Os Voluntários da Virgínia, General. A quinta do meu pai foi salva pelos seus canhões. Devemos-lhe uma estrada.",
     "Los Voluntarios de Virginia, General. La granja de mi padre se salvó con sus cañones. Le debemos un camino.", CO)
line("r_drum1", "ruggieri", "Boy, keep the drum going. They walk to it better than they walk to me.",
     "Rapaz, não pares o tambor. Eles caminham melhor ao som dele do que ao meu.",
     "Chico, no pares el tambor. Caminan mejor a su son que al mío.", CO)
# flags spoken
line("r_fields", "ruggieri", "Father Tomasz left São Rafael's fields standing. Its people walk with us now, and they still sing at Vespers.",
     "O Padre Tomasz deixou os campos de São Rafael de pé. A sua gente caminha connosco agora, e ainda canta às Vésperas.",
     "El Padre Tomasz dejó en pie los campos de São Rafael. Su gente camina con nosotros ahora, y aún canta en Vísperas.", CO)
line("r_burned", "ruggieri", "São Rafael's fields were burned in '76. There is nobody from there left to walk with us.",
     "Os campos de São Rafael foram queimados em setenta e seis. Não sobra ninguém de lá para caminhar connosco.",
     "Los campos de São Rafael se quemaron en el setenta y seis. No queda nadie de allí que camine con nosotros.", CO)
line("r_thin", "ruggieri", "Some of their nests outlived the rains at Óbidos. Everything they laid since is on this river with us.",
     "Alguns ninhos deles sobreviveram às chuvas em Óbidos. Tudo o que puseram desde então está neste rio connosco.",
     "Algunos de sus nidos sobrevivieron a las lluvias en Óbidos. Todo lo que pusieron desde entonces está en este río con nosotros.", CO)
line("r_held_off", "ruggieri", "We only held Concórdia off last year. Its works never stopped. There are more of them than I left at its gates.",
     "No ano passado só travámos Concórdia. As suas oficinas nunca pararam. Há mais deles do que os que deixei às suas portas.",
     "El año pasado solo contuvimos a Concórdia. Sus talleres nunca pararon. Hay más de los que dejé a sus puertas.", CO)
line("r_close", "ruggieri", "We blew its great spring last year. Whatever comes out of Concórdia now comes without its great engines.",
     "No ano passado rebentámos a grande mola. O que sai de Concórdia agora sai sem os seus grandes engenhos.",
     "El año pasado volamos su gran resorte. Lo que sale ahora de Concórdia sale sin sus grandes ingenios.", CO)
line("r_barra", "ruggieri", "The Barra's lower town burned in '78. What garrison is left came down with Nazaré's people.",
     "A cidade baixa da Barra ardeu em setenta e oito. A guarnição que resta desceu com a gente de Nazaré.",
     "La ciudad baja de la Barra ardió en el setenta y ocho. La guarnición que queda bajó con la gente de Nazaré.", CO)
line("a_fought", "arruda", "The valley stood with you once against the machines, General. It walks with you now.",
     "O vale esteve consigo uma vez contra as máquinas, General. Agora caminha consigo.",
     "El valle estuvo con usted una vez contra las máquinas, General. Ahora camina con usted.", CO)
line("a_parley", "arruda", "Most of the valley stayed in their houses. They did not believe the machines would come down. A few of us came.",
     "A maior parte do vale ficou em casa. Não acreditaram que as máquinas descessem. Viemos uns poucos.",
     "La mayor parte del valle se quedó en casa. No creyeron que las máquinas bajarían. Vinimos unos pocos.", CO)
# ---- part 2: the column
line("n_break", "narrator", "The front breaks. Leave the ford: the people set out for the coast in three groups.",
     "A frente quebra. Deixe o vau: a gente parte para a costa em três grupos.",
     "El frente se rompe. Deja el vado: la gente parte hacia la costa en tres grupos.")
line("r_break", "ruggieri", "That is enough. Guns limber up. Everybody walks.", "Chega. Canhões atrelados. Todos a caminhar.",
     "Basta. Cañones enganchados. Todos a caminar.", CO)
line("n_lesson2", "narrator", "Alone a group of people only walks. Walk your Drummer beside a group and it keeps the army's pace. Move him from group to group.",
     "Sozinho um grupo de gente só caminha. Leve o seu Tambor ao lado de um grupo e ele acompanha o passo do exército. Leve-o de grupo em grupo.",
     "Solo, un grupo de gente apenas camina. Lleva a tu Tambor junto a un grupo y lleva el paso del ejército. Llévalo de grupo en grupo.", CO)
line("n_drum_on", "narrator", "The drum sets the pace: the group beside it walks with the army.", "O tambor marca o passo: o grupo ao lado caminha com o exército.",
     "El tambor marca el paso: el grupo a su lado camina con el ejército.", CO)
line("n_slow", "narrator", "Without the drum the group falls back to a walk.", "Sem o tambor o grupo volta a só caminhar.", "Sin el tambor el grupo vuelve a caminar despacio.", CO)
line("r_drum", "ruggieri", "Keep the drum where the children are.", "Mantenham o tambor onde estão as crianças.", "Mantened el tambor donde están los niños.", CO)
line("n_raid", "narrator", "A raid out of the forest on the column. They go for the people.", "Um ataque da floresta sobre a coluna. Vão à gente.",
     "Un ataque desde el bosque sobre la columna. Van a por la gente.", CO)
line("r_raid", "ruggieri", "Riders to the flank! Do not chase them into the trees.", "Cavaleiros ao flanco! Não os persigam para dentro das árvores.",
     "¡Jinetes al flanco! No los persigáis entre los árboles.", CO)
line("n_pursue", "narrator", "More come down the road behind the column.", "Mais descem a estrada atrás da coluna.", "Más bajan por el camino tras la columna.", CO)
line("n_group_in", "narrator", "A group reaches the port and goes down to the quay.", "Um grupo chega ao porto e desce ao cais.",
     "Un grupo llega al puerto y baja al muelle.", CO)
line("n_lost_group", "narrator", "One of the groups is gone. Nobody of it reached the ships.", "Um dos grupos desapareceu. Ninguém dele chegou aos navios.",
     "Uno de los grupos ha desaparecido. Nadie de él llegó a los barcos.", CO)
line("n_ambush", "narrator", "They got ahead of the column: they hold the pass on the road ahead. The people stop before it and wait until it is clear.",
     "Passaram à frente da coluna: seguram o desfiladeiro na estrada adiante. A gente para diante dele e espera até estar livre.",
     "Se adelantaron a la columna: sostienen el paso en el camino de delante. La gente se detiene ante él y espera a que esté libre.", CO)
line("r_ambush", "ruggieri", "Line, forward through the people. Clear the pass, or they walk into it.",
     "Linha, em frente por entre a gente. Limpem o desfiladeiro, ou eles entram nele.",
     "Línea, adelante entre la gente. Limpiad el paso, o caminarán hacia él.", CO)
line("n_pass_clear", "narrator", "The pass is clear. The people go on through it.", "O desfiladeiro está livre. A gente segue por ele.",
     "El paso está libre. La gente sigue por él.", CO)
line("n_pass_late", "narrator", "The people will not wait any longer with the pursuit behind them. They go into the pass.",
     "A gente não espera mais com a perseguição atrás. Entram no desfiladeiro.",
     "La gente no espera más con la persecución detrás. Entran en el paso.", CO)
# ---- part 3: the ships
line("n_port", "narrator", "The port. The ships lie off the quay. Hold the bluff before it until they sail; every group must be down on the quay by then.",
     "O porto. Os navios estão ao largo do cais. Segure o alto diante dele até eles zarparem; todos os grupos têm de estar no cais até lá.",
     "El puerto. Los barcos están frente al muelle. Sostén el alto ante él hasta que zarpen; todos los grupos deben estar en el muelle para entonces.", CO)
line("r_port", "ruggieri", "Guns on the bluff. The harbour's Barracks is ours: spend the treasury on men, it will not sail with us.",
     "Canhões no alto. O Quartel do porto é nosso: gastem o tesouro em homens, não vai zarpar connosco.",
     "Cañones en el alto. El Cuartel del puerto es nuestro: gastad el tesoro en hombres, no zarpará con nosotros.", CO)
line("n_assault", "narrator", "They come at the bluff.", "Vêm ao alto.", "Vienen al alto.", CO)
line("r_count", "ruggieri", "Count them aboard. All of them. I want the number for the King, not a guess.",
     "Contem-nos a bordo. A todos. Quero o número para o Rei, não um palpite.",
     "Contadlos a bordo. A todos. Quiero el número para el Rey, no una suposición.", CO)
line("n_all_aboard", "narrator", "Every group still walking is aboard. The last boats wait for the army: hold the bluff a little longer.",
     "Todos os grupos que ainda caminhavam estão a bordo. Os últimos botes esperam pelo exército: segure o alto mais um pouco.",
     "Todos los grupos que aún caminaban están a bordo. Los últimos botes esperan al ejército: sostén el alto un poco más.")
line("n_sail", "narrator", "The ships sail. The army goes down to the boats last, the guns spiked on the bluff.",
     "Os navios zarpam. O exército desce aos botes por último, os canhões encravados no alto.",
     "Los barcos zarpan. El ejército baja a los botes el último, los cañones clavados en el alto.")
line("n_fort_lost", "narrator", "The harbour fort is broken. No ship can load under the fire on the quay.",
     "O forte do porto está quebrado. Nenhum navio consegue carregar debaixo do fogo no cais.",
     "El fuerte del puerto está roto. Ningún barco puede cargar bajo el fuego en el muelle.")
line("n_too_few", "narrator", "The ships sail with too few aboard. Most of Brazil's people are still on the road.",
     "Os navios zarpam com muito poucos a bordo. A maior parte da gente do Brasil ainda está na estrada.",
     "Los barcos zarpan con muy pocos a bordo. La mayor parte de la gente del Brasil sigue en el camino.")
line("r_hurt", "ruggieri", "It is nothing. Help me onto the gun carriage and keep walking.", "Não é nada. Ponham-me no reparo do canhão e continuem a andar.",
     "No es nada. Subidme a la cureña y seguid andando.", CO)
# ---- the fire's (the solo pick, versus): narration only, no creature and no machine speaks
line("n_f1", "firen", "Yours come out at the edge. The army holds the ford; its outposts are falling back across it with their families.",
     "Os seus saem na borda. O exército segura o vau; os postos avançados recuam por ele com as famílias.",
     "Los tuyos salen en el borde. El ejército sostiene el vado; sus puestos avanzados se repliegan por él con sus familias.", FI)
line("n_f2", "firen", "When the front breaks the people walk to the ships in three groups. Catch them on the road.",
     "Quando a frente quebrar a gente caminha para os navios em três grupos. Apanhe-a na estrada.",
     "Cuando se rompa el frente la gente camina hacia los barcos en tres grupos. Atrápala en el camino.", FI)
line("n_f_reinf", "firen", "More of yours come out at the edge.", "Mais dos seus saem na borda.", "Más de los tuyos salen en el borde.", FI)
line("n_f_break", "firen", "The front breaks. The column leaves the ford for the coast.", "A frente quebra. A coluna deixa o vau rumo à costa.",
     "El frente se rompe. La columna deja el vado hacia la costa.", FI)
line("n_f_port", "firen", "The first of them reach the port. The ships sail before long.", "Os primeiros chegam ao porto. Os navios não tardam a zarpar.",
     "Los primeros llegan al puerto. Los barcos no tardan en zarpar.", FI)
line("n_f_won", "firen", "The ships sail half empty. The people are still on the road.", "Os navios zarpam meio vazios. A gente ainda está na estrada.",
     "Los barcos zarpan medio vacíos. La gente sigue en el camino.")
line("n_f_lost", "firen", "The ships sail full. The road to the sea is empty.", "Os navios zarpam cheios. A estrada para o mar está vazia.",
     "Los barcos zarpan llenos. El camino al mar está vacío.")
# ---- the endings
line("r_end_many", "ruggieri", "We brought most of them out. I have the number in my hand: {aboard} of {people_n}.",
     "Trouxemos a maior parte. Tenho o número na mão: {aboard} de {people_n}.", "Sacamos a la mayoría. Tengo el número en la mano: {aboard} de {people_n}.")
line("r_end_some", "ruggieri", "We brought some of them out. The rest are on that road still. I wrote the number down: {aboard} of {people_n}.",
     "Trouxemos alguns. Os outros ainda estão naquela estrada. Escrevi o número: {aboard} de {people_n}.",
     "Sacamos a algunos. Los demás siguen en ese camino. Escribí el número: {aboard} de {people_n}.")
line("r_end_few", "ruggieri", "We brought too few of them out. I will carry that number to my grave: {aboard} of {people_n}.",
     "Trouxemos muito poucos. Levarei esse número para a cova: {aboard} de {people_n}.",
     "Sacamos a muy pocos. Llevaré ese número a la tumba: {aboard} de {people_n}.")
line("r_end2", "ruggieri", "From the deck the coast looked as it always had. Green to the water. You would not have known.",
     "Do convés a costa parecia a de sempre. Verde até à água. Ninguém diria.",
     "Desde la cubierta la costa parecía la de siempre. Verde hasta el agua. Nadie lo habría dicho.")
line("k_end1", "king", "That was Brazil. We had held it for three hundred years, and we left it in a season.",
     "Isso foi o Brasil. Tínhamo-lo segurado trezentos anos, e deixámo-lo numa estação.",
     "Eso fue el Brasil. Lo habíamos sostenido trescientos años, y lo dejamos en una estación.")
line("k_end2", "king", "And by then it was already in the ships' holds, on its way to the rest of the world.",
     "E nessa altura já estava nos porões dos navios, a caminho do resto do mundo.",
     "Y para entonces ya estaba en las bodegas de los barcos, camino del resto del mundo.")
line("k_end_f", "king", "That is not how it went. Ruggieri brought them to the ships. But I have kept this page.",
     "Não foi assim que aconteceu. Ruggieri levou-os aos navios. Mas guardei esta página.",
     "No fue así como ocurrió. Ruggieri los llevó a los barcos. Pero he guardado esta página.")
line("n_end_f", "firen", "The ships sailed half empty, and the road to the sea stayed full.", "Os navios zarparam meio vazios, e a estrada para o mar ficou cheia.",
     "Los barcos zarparon medio vacíos, y el camino al mar siguió lleno.")

# ---- stills (stand-ins drawn by tools/campaign/make_e01_stills.py; the owner's paintings replace them)
M["stills"] = {
    "rome": {"image": STILL % "p01_01", "caption": T("Rome, the present. The King at the war map.", "Roma, o presente. O Rei diante do mapa de guerra.",
                                                    "Roma, el presente. El Rey ante el mapa de guerra.")},
    "column": {"image": STILL % "e01_01", "caption": T("The column to the coast, 2781.", "A coluna para a costa, 2781.", "La columna hacia la costa, 2781.")},
    "ford": {"image": STILL % "e01_03", "caption": T("The ford, the front breaking.", "O vau, a frente a quebrar.", "El vado, el frente rompiéndose.")},
    "bluff": {"image": STILL % "e01_02", "caption": T("The last bluff over the harbour.", "O último alto sobre o porto.", "El último alto sobre el puerto.")},
    "ships": {"image": STILL % "e01_04", "caption": T("The ships at the quay.", "Os navios no cais.", "Los barcos en el muelle.")},
}
M["opening"] = {
    "column": [{"still": "rome", "lines": ["k_open1", "k_open2", {"id": "k_open_s", "if": SOUTH}, {"id": "k_open_r", "if": RIVER}]},
               {"still": "column", "lines": ["r_open1", {"id": "r_open_s", "if": SOUTH}, {"id": "r_open_r", "if": RIVER}]}],
    "fire": [{"still": "rome", "lines": ["k_open_f"]}, {"still": "column", "lines": ["n_open_f"]}],
}
M["ending"] = {
    "column": [
        {"still": "ships", "lines": [{"id": "r_end_many", "if": {"flag": {"colonists": "many"}}}, {"id": "r_end_some", "if": {"flag": {"colonists": "some"}}},
                                     {"id": "r_end_few", "if": {"flag": {"colonists": "few"}}}, "r_end2"]},
        {"still": "rome", "lines": ["k_end1", "k_end2"]},
    ],
    "fire": [{"still": "bluff", "lines": ["n_end_f"]}, {"still": "rome", "lines": ["k_end_f"]}],
}
M["briefing"] = {
    "column": {"still": "column", "text": [
        T("Brazil, 2781. You are General Ruggieri and the army of Brazil: the line, the riders, two guns, a Powder Wagon and a Drummer. The front fought second at the crossing has grown past holding: bring the people out to the ships.",
          "Brasil, 2781. Você é o General Ruggieri e o exército do Brasil: a linha, os cavaleiros, dois canhões, uma Carroça de Pólvora e um Tambor. A frente combatida em segundo lugar na encruzilhada cresceu para lá do que se podia segurar: leve a gente aos navios.",
          "Brasil, 2781. Eres el General Ruggieri y el ejército del Brasil: la línea, los jinetes, dos cañones, un Carro de Pólvora y un Tambor. El frente combatido en segundo lugar en la encrucijada ha crecido más allá de lo que se podía sostener: lleva a la gente a los barcos."),
        T("First hold the ford while the outposts fall back. Then walk the people down the road to the port in three groups: a group keeps the army's pace with the Drummer beside it. Last, hold the bluff before the quay until the ships sail.",
          "Primeiro segure o vau enquanto os postos avançados recuam. Depois leve a gente pela estrada até ao porto em três grupos: um grupo acompanha o passo do exército com o Tambor ao lado. Por fim, segure o alto diante do cais até os navios zarparem.",
          "Primero sostén el vado mientras los puestos avanzados se repliegan. Luego lleva a la gente por el camino hasta el puerto en tres grupos: un grupo lleva el paso del ejército con el Tambor al lado. Por último, sostén el alto ante el muelle hasta que zarpen los barcos."),
        T("At least a quarter of the people must be aboard, and the harbour fort must stand.", "Pelo menos um quarto da gente tem de estar a bordo, e o forte do porto tem de ficar de pé.",
          "Al menos un cuarto de la gente debe estar a bordo, y el fuerte del puerto debe seguir en pie.")]},
    "fire": {"still": "column", "text": [
        T("Brazil, 2781. You are what the army fought second at the crossing: the swarm on the river road, or the city's machines on the southern road.",
          "Brasil, 2781. Você é o que o exército combateu em segundo lugar na encruzilhada: o enxame na estrada do rio, ou as máquinas da cidade na estrada do sul.",
          "Brasil, 2781. Eres lo que el ejército combatió en segundo lugar en la encrucijada: el enjambre en el camino del río, o las máquinas de la ciudad en el camino del sur."),
        T("A column of the Crown walks the people of a whole country to the ships. Keep more than half of them from the ships, or break the harbour fort.",
          "Uma coluna da Coroa leva a gente de um país inteiro aos navios. Impeça mais de metade de chegar aos navios, ou derrube o forte do porto.",
          "Una columna de la Corona lleva a la gente de un país entero a los barcos. Impide que más de la mitad llegue a los barcos, o derriba el fuerte del puerto.")]},
}
M["debrief"] = {
    "column": {"still": "ships", "title": T("The Ships Sail", "Os Navios Zarpam", "Los Barcos Zarpan"),
               "text": T("{aboard} of Brazil's {people_n} people aboard.", "{aboard} das {people_n} pessoas do Brasil a bordo.",
                         "{aboard} de las {people_n} personas del Brasil a bordo."),
               "text_if": [
                   {"if": {"flag": {"colonists": "many"}}, "text": T("Most of them came out.", "A maior parte saiu.", "La mayoría salió.")},
                   {"if": {"flag": {"colonists": "some"}}, "text": T("Some of them came out.", "Alguns saíram.", "Algunos salieron.")},
                   {"if": {"flag": {"colonists": "few"}}, "text": T("Too few came out.", "Saíram muito poucos.", "Salieron muy pocos.")}]},
    "fire": {"still": "bluff", "title": T("The Road Stays Full", "A Estrada Fica Cheia", "El Camino Sigue Lleno"),
             "text": T("Only {aboard} of {people_n} reached the ships.", "Só {aboard} de {people_n} chegaram aos navios.",
                       "Solo {aboard} de {people_n} llegaron a los barcos.")},
}


# ================================================================== spawns of the fire by version
def fire_spawn(at, tag, rows, tags=None, extra_if=None):
    """rows: [(version cond or None, kind, count, cond or None)]: one spawn each (the danger of that road)."""
    out = []
    for (vc, kind, n, c) in rows:
        cs = [x for x in (vc, c, extra_if) if x]
        sp = {"team": "fire", "kind": kind, "count": n, "at": at, "tag": tag, "tags": ["fire_all"] + (tags or [])}
        if cs:
            sp["if"] = cs[0] if len(cs) == 1 else {"all": cs}
        out.append({"spawn": sp})
    return out


WAVE = {   # the danger's waves by road: [(kind, count, condition)]
    "river": [("raptor", 6, None), ("spitter", 2, None), ("raptor", 2, NORMAL_UP), ("raptor", 3, HARD), ("spitter", 1, HARD),
              ("raptor", 3, JUNGLE_THIN)],
    "south": [("clock_soldier", 4, None), ("springer", 2, None), ("clock_soldier", 1, NORMAL_UP), ("clock_soldier", 3, HARD),
              ("springer", 1, HARD), ("clock_soldier", 2, SIEGE_HELD_OFF)],
}
WAVE_BIG = {   # the later waves add these
    "river": [("spitter", 2, None), ("tyrant_challenger", 1, NORMAL_UP), ("brute", 1, HARD)],
    "south": [("netter", 1, None), ("pendulum", 1, NORMAL_UP), ("ballista", 1, {"all": [HARD, SIEGE_HELD_OFF]})],
}
AMBUSH = {   # Part 2: on the road ahead, at the pass
    "river": [("raptor", 6, None), ("spitter", 3, None), ("tyrant_challenger", 1, None), ("raptor", 2, NORMAL_UP), ("venom_challenger", 1, HARD)],
    "south": [("clock_soldier", 5, None), ("springer", 2, None), ("netter", 1, None), ("winder", 1, None), ("clock_soldier", 2, NORMAL_UP),
              ("pendulum", 1, HARD)],
}
RAID = {
    "river": [("raptor", 3, None), ("raptor", 1, NORMAL_UP), ("hatchlings", 1, HARD)],
    "south": [("springer", 2, None), ("springer", 1, NORMAL_UP), ("netter", 1, HARD)],
}
ASSAULT = {
    "river": [("raptor", 7, None), ("spitter", 2, None), ("tyrant_challenger", 1, None), ("raptor", 2, NORMAL_UP), ("brute", 1, HARD),
              ("raptor", 3, HARD), ("venom_challenger", 1, ISLAND_STANDING), ("raptor", 3, JUNGLE_THIN)],
    "south": [("clock_soldier", 6, None), ("springer", 2, None), ("winder", 1, None), ("clock_soldier", 2, NORMAL_UP), ("pendulum", 1, HARD),
              ("clock_soldier", 3, HARD), ("ballista", 1, SIEGE_HELD_OFF), ("clock_soldier", 2, SIEGE_HELD_OFF)],
}
REINF = {   # the fire played: its own waves (the player leads them)
    "river": [("raptor", 5, None), ("spitter", 2, None), ("tyrant_challenger", 1, {"time": 240})],
    "south": [("clock_soldier", 4, None), ("springer", 1, None), ("winder", 1, None), ("pendulum", 1, {"time": 240})],
}


def by_road(table, big=None):
    rows = []
    for v, vc in (("river", RIVER), ("south", SOUTH)):
        for (k, n, c) in table[v] + ((big or {}).get(v, [])):
            rows.append((vc, k, n, c))
    return rows


# ================================================================== the triggers
TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"counter": {"name": "people_n", "count": {"tag": "people"}}},
        {"counter": {"name": "g1_n", "count": {"tag": "g1"}}},
        {"order": {"tag": "home_men", "do": "hold"}}, {"max_hp": {"tag": "harbour_fort", "hp": FORT_HP}},
        {"pace": {"tag": "people", "pace": SLOW}}]},
    {"id": "setup_obj", "when": {"all": [{"time": 0.6}, NO_FIRE]}, "do": [
        {"objective": {"id": "f_catch", "set": "hidden"}}]},
    {"id": "setup_nocol", "when": {"all": [{"time": 0.6}, NO_COLUMN]}, "do": [
        {"objective": {"id": "ford", "set": "hidden"}}, {"objective": {"id": "outposts", "set": "hidden"}}]},
    # (the machines came down wound from the city: on the road they keep enough wind to march: d11's machines on their plates)
    {"id": "wind_south", "when": {"all": [SOUTH, {"time": 1}, LIVE]}, "every": 10, "do": [{"wind": {"team": "fire", "share": 0.7}}]},
    {"id": "front_clock", "when": {"time": 1}, "do": [{"clock": {"name": "front", "secs": FRONT_SECS, "scale": False}}]},
    # ============================================================ THE OPENING LINES
    {"id": "intro", "when": {"all": [{"time": 1.5}, COLUMN]}, "do": [{"say": ["r_1", "n_lesson"]}, {"ping": {"area": "ford"}}, {"ping": {"area": "op"}}]},
    {"id": "intro_vol", "when": {"all": [{"time": 22}, COLUMN, FAMILIES, P1]}, "do": [{"say": ["h_vol"]}]},
    {"id": "intro_fort", "when": {"all": [{"time": 30}, COLUMN, FORT_HELD, P1]}, "do": [{"say": ["t_fort"]}]},
    {"id": "intro_thin", "when": {"all": [{"time": 40}, COLUMN, RIVER, JUNGLE_THIN, P1]}, "do": [{"say": ["r_thin"]}]},
    {"id": "intro_heldoff", "when": {"all": [{"time": 40}, COLUMN, SOUTH, SIEGE_HELD_OFF, P1]}, "do": [{"say": ["r_held_off"]}]},
    {"id": "intro_close", "when": {"all": [{"time": 40}, COLUMN, SOUTH, SIEGE_CLOSE, P1]}, "do": [{"say": ["r_close"]}]},
    {"id": "intro_barra", "when": {"all": [{"time": 52}, COLUMN, RIVER, BARRA_BURNED, P1]}, "do": [{"say": ["r_barra"]}]},
    {"id": "intro_fought", "when": {"all": [{"time": 52}, COLUMN, SOUTH, FOUGHT, P1]}, "do": [{"say": ["a_fought"]}]},
    {"id": "intro_parley", "when": {"all": [{"time": 52}, COLUMN, SOUTH, PARLEY, P1]}, "do": [{"say": ["a_parley"]}]},
    {"id": "intro_f", "when": {"all": [{"time": 1.5}, FIRE]}, "do": [{"say": ["n_f1", "n_f2"]}, {"ping": {"area": "ford"}}]},
    # ============================================================ PART 1: THE FRONT BREAKS
    {"id": "fall_1", "when": {"time": 5}, "do": [
        {"order": {"tag": "g1", "do": "route", "route": FALL1, "name": "fall_g1"}},
        {"order": {"tag": "op_men", "do": "route", "route": FALL1, "name": "fall_op"}},
        {"say": ["n_fall"], "if": COLUMN}]},
    {"id": "fall_1v", "when": {"all": [{"fired": "fall_1"}, COLUMN]}, "delay": 3, "do": [
        {"say": ["s_op"], "if": RIVER}, {"say": ["a_op"], "if": SOUTH}]},
    {"id": "fall_2", "when": {"time": 12}, "do": [
        {"order": {"tag": "op2_men", "do": "route", "route": FALL2, "name": "fall_op2"}}]},
    # (op2's families: the g1 people that stand at op2 (the route takes the whole tag: they start apart and meet at the ford)
    {"id": "chase", "when": {"all": [{"time": CHASE_AT}, SOLO_C, P1, LIVE]}, "do": [
        *fire_spawn("edge", "chasers", [(RIVER, "raptor", 3, None), (SOUTH, "springer", 2, None), (SOUTH, "clock_soldier", 1, None)]),
        {"say": ["n_chase"]}, {"ping": {"area": "ford_far"}}]},
    {"id": "chase_go", "when": {"fired": "chase"}, "delay": 1, "do": [
        {"order": {"tag": "chasers", "do": "hunt", "prey": "g1", "within": 60}}]},
    {"id": "cover_say", "when": {"all": [{"fired": "chase"}, FAMILIES]}, "delay": 6, "do": [{"say": ["h_cover"]}]},
    {"id": "g1_count", "when": {"all": [{"fired": "setup"}, P1, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "g1_in", "count": {"tag": "g1", "area": "muster"}}}]},
    {"id": "g1_in", "when": {"all": [P1, {"counter": {"name": "g1_in", "at_least": 1}}, {"count": {"tag": "g1", "area": "ford_far", "below": 1}},
                                     {"count": {"tag": "g1", "area": "op", "below": 1}}, {"time": 40}]}, "delay": 8, "do": [
        {"objective": {"id": "outposts", "set": "done"}}, {"say": ["op_in"]}]},
]
for i, at in enumerate(FORD_WAVES):
    wid = "fwave_%d" % (i + 1)
    TR_ += [
        {"id": wid, "when": {"all": [{"time": at}, SOLO_C, P1, LIVE]}, "do":
            fire_spawn("edge", wid, by_road(WAVE, WAVE_BIG if i else None), tags=["fwaves"])
            + [{"counter": {"name": "wave_n", "add": 1}}, {"ping": {"area": "ford_far"}}]
            + ([{"say": ["n_wave", "r_wave"]}] if i == 0 else [])},
        {"id": wid + "_go", "when": {"fired": wid}, "delay": 2, "do": [
            {"order": {"tag": wid, "do": "route", "route": FORD_ROUTE, "attack": True, "name": wid}}]},
    ]
TR_ += [
    {"id": "fwave_push", "when": {"all": [{"fired": "fwave_1"}, P1, LIVE]}, "delay": 40, "every": 14, "do": [
        {"order": {"tag": "fwaves", "do": "attack", "to": "ford_hold", "idle": True}}]},
    # ============================================================ PART 2: THE COLUMN
    {"id": "part2", "when": {"all": [{"clock_out": "front"}, LIVE]}, "do": [
        {"objective": {"id": "ford", "set": "done"}},
        {"objective": {"id": "outposts", "set": "failed", "if": {"not": {"fired": "g1_in"}}}},
        {"objective": {"id": "column", "set": "active", "if": COLUMN}}, {"objective": {"id": "rear", "set": "active", "if": COLUMN}},
        {"say": ["n_break"]}, {"ping": {"area": "muster"}}, {"ping": {"area": "town"}}, {"ping": {"area": "hamlet"}}]},
    {"id": "p2_say", "when": {"all": [{"fired": "part2"}, COLUMN]}, "delay": 2, "do": [{"say": ["r_break", "n_lesson2", "r_drum1"]}, {"ping": {"tag": "drummer"}}]},
    {"id": "p2_say_f", "when": {"all": [{"fired": "part2"}, FIRE]}, "do": [{"say": ["n_f_break"]}]},
    {"id": "p2_fields", "when": {"all": [{"fired": "part2"}, COLUMN, RIVER]}, "delay": 30, "do": [
        {"say": ["r_fields"], "if": FIELDS_LEFT}, {"say": ["r_burned"], "if": FIELDS_BURNED}]},
    # what is left at the ford follows the column down the road
    {"id": "p2_ford_go", "when": {"all": [{"fired": "part2"}, NO_FIRE]}, "delay": 3, "do": [
        {"order": {"tag": "fwaves", "do": "route", "route": ["muster"] + ROAD, "attack": True, "name": "fwaves_road"}},
        {"order": {"tag": "chasers", "do": "hunt", "prey": "people", "within": 80}}]},
    # the militia escort the groups (co-op: the friend leads them after this)
    {"id": "p2_militia", "when": {"fired": "part2"}, "delay": 1, "do": [
        {"order": {"tag": "op_men", "do": "follow", "leader": "g1", "within": 4}},
        {"order": {"tag": "op2_men", "do": "follow", "leader": "g3", "within": 4}},
        {"order": {"tag": "home_men", "do": "follow", "leader": "g2", "within": 4}}]},
]
# the three groups set out (each on its own road, by version), and THE DRUMMER's pace
for g in ("g1", "g2", "g3"):
    TR_ += [
        {"id": "go_" + g, "when": {"fired": "part2"}, "delay": {"g1": 2, "g2": 4, "g3": 6}[g], "do": [
            {"order": {"tag": g, "do": "route", "route": GROUP_ROUTE["river"][g], "name": "road_" + g, "if": RIVER}},
            {"order": {"tag": g, "do": "route", "route": GROUP_ROUTE["south"][g], "name": "road_" + g, "if": SOUTH}}]},
        {"id": "drum_on_" + g, "when": {"all": [{"fired": "go_" + g}, LIVE, {"near": {"tag": "drummer", "to": g, "within": DRUM_TILES}}]},
         "every": 2, "do": [{"pace": {"tag": g, "pace": DRUM}}]},
        {"id": "drum_off_" + g, "when": {"all": [{"fired": "go_" + g}, LIVE, {"not": {"near": {"tag": "drummer", "to": g, "within": DRUM_TILES}}}]},
         "every": 2, "do": [{"pace": {"tag": g, "pace": SLOW}}]},
        {"id": "port_" + g, "when": {"all": [{"fired": "go_" + g}, {"count": {"tag": g, "area": "port", "at_least": 1}}, LIVE]}, "do": [
            {"say": ["n_group_in"]}]},
        {"id": "gone_" + g, "when": {"all": [{"fired": "go_" + g}, {"count": {"tag": g, "below": 1}}, {"not": {"fired": "port_" + g}}, LIVE]}, "do": [
            {"say": ["n_lost_group"]}]},
    ]
TR_ += [
    # THE PASS: they got ahead of the column; the people stop before it until it is clear
    {"id": "ambush", "when": {"all": [{"fired": "part2"}, SOLO_C, LIVE]}, "delay": 1, "do":
        fire_spawn("pass_at", "ambush", by_road(AMBUSH), tags=["ambushers"])
        + [{"objective": {"id": "pass", "set": "active"}}, {"ping": {"area": "pass_at"}}, {"reveal": {"area": "pass_at", "side": "column"}}]},
    {"id": "ambush_hold", "when": {"fired": "ambush"}, "delay": 0.5, "do": [
        {"order": {"tag": "ambush", "do": "hold"}}, {"counter": {"name": "amb_left", "count": {"tag": "ambush"}}}]},
    {"id": "ambush_say", "when": {"fired": "ambush"}, "delay": 14, "do": [{"say": ["n_ambush", "r_ambush"]}, {"ping": {"area": "pass_at"}}]},
    {"id": "ambush_count", "when": {"all": [{"fired": "ambush_hold"}, LIVE, {"not": {"fired": "pass_clear"}}]}, "every": 2, "do": [
        {"counter": {"name": "amb_left", "count": {"tag": "ambush"}}}]},
    {"id": "ambush_wake", "when": {"all": [{"fired": "ambush_hold"}, LIVE, {"near": {"team": "column", "to": "ambush", "within": 9}}]}, "every": 6, "do": [
        {"order": {"tag": "ambush", "do": "attack", "to": "pass_wait"}}]},
    {"id": "pass_clear", "when": {"all": [{"fired": "ambush_hold"}, {"count": {"tag": "ambush", "below": 1}}, LIVE]}, "do": [
        {"objective": {"id": "pass", "set": "done"}}, {"say": ["n_pass_clear"]}]},
    {"id": "pass_late", "when": {"all": [{"fired": "part2"}, LIVE, {"not": {"fired": "pass_clear"}}]}, "delay": PASS_LATE, "do": [
        {"objective": {"id": "pass", "set": "failed", "if": {"fired": "ambush"}}}, {"say": ["n_pass_late"], "if": COLUMN}]},
    {"id": "pass_free", "when": {"all": [{"fired": "part2"}, {"not": SOLO_C}]}, "delay": 25, "do": []},
    {"id": "through", "when": {"all": [{"fired": "part2"}, LIVE, {"any": [{"fired": "pass_clear"}, {"fired": "pass_late"}, {"fired": "pass_free"}]}]},
     "delay": 2, "do": [
        {"order": {"tag": gr, "do": "route", "route": ["pass_wait"] + AFTER_PASS, "name": "on_" + gr, "if": vc}}
        for v, vc in (("river", RIVER), ("south", SOUTH)) for gr in WAITS[v]]},
    {"id": "drum_say", "when": {"all": [{"fired": "part2"}, COLUMN, {"any": [{"fired": "drum_on_g1"}, {"fired": "drum_on_g2"}, {"fired": "drum_on_g3"}]}]}, "delay": 1,
     "do": [{"say": ["n_drum_on"]}]},
    {"id": "slow_say", "when": {"all": [{"fired": "drum_say"}, COLUMN, P2]}, "delay": 35, "do": [{"say": ["n_slow", "r_drum"]}]},
    # the raids on the column out of the forest (the solo column)
] + [
    t for i, (at, fl) in enumerate(RAIDS) for t in [
        {"id": "raid_%d" % (i + 1), "when": {"all": [{"fired": "part2"}, SOLO_C, LIVE, {"not": {"fired": "part3"}}]}, "delay": at, "do":
            fire_spawn(fl, "raid%d" % (i + 1), by_road(RAID), tags=["raiders"]) + [{"ping": {"area": fl}}]
            + ([{"say": ["n_raid", "r_raid"]}] if i == 0 else [])},
        {"id": "raid_%d_go" % (i + 1), "when": {"fired": "raid_%d" % (i + 1)}, "delay": 1, "do": [
            {"order": {"tag": "raid%d" % (i + 1), "do": "hunt", "prey": "people", "within": 70}}]},
    ]
] + [
    {"id": "raid_push", "when": {"all": [{"fired": "raid_1"}, LIVE]}, "delay": 30, "every": 12, "do": [
        {"order": {"tag": "raiders", "do": "hunt", "prey": "people", "within": 90}}]},
] + [
    t for i in range(PURSUE_N) for t in [
        {"id": "pursue_%d" % (i + 1), "when": {"all": [{"fired": "part2"}, SOLO_C, LIVE, {"not": {"fired": "part3"}}]},
         "delay": PURSUE_FIRST + PURSUE_EVERY * i, "do":
            fire_spawn("edge", "pursue%d" % (i + 1), by_road(WAVE, WAVE_BIG if i >= 2 else None), tags=["pursuers"])
            + ([{"say": ["n_pursue"]}] if i == 0 else [])},
        {"id": "pursue_%d_go" % (i + 1), "when": {"fired": "pursue_%d" % (i + 1)}, "delay": 1, "do": [
            {"order": {"tag": "pursue%d" % (i + 1), "do": "route", "route": FORD_ROUTE + ROAD, "attack": True, "name": "pursue%d" % (i + 1)}}]},
    ]
] + [
    # ============================================================ PART 3: THE SHIPS
    {"id": "p3_late", "when": {"fired": "part2"}, "delay": PART3_LATE, "do": []},
    {"id": "part3", "when": {"all": [{"fired": "part2"}, LIVE, {"any": [{"count": {"tag": "people", "area": "port", "at_least": 1}},
                                                                     {"counter": {"name": "aboard", "at_least": 1}}, {"fired": "p3_late"}]}]}, "do": [
        {"clock": {"name": "ships", "secs": SHIPS_SECS, "scale": False}},
        {"objective": {"id": "column", "set": "done"}}, {"objective": {"id": "rear", "set": "done"}},
        {"objective": {"id": "ships", "set": "active", "if": COLUMN}}, {"objective": {"id": "f_ships", "set": "active", "if": FIRE}},
        {"give": {"team": "column", "gold": CHEST_GOLD, "powder": CHEST_POWDER}},
        {"ping": {"area": "bluff"}}, {"ping": {"area": "quay"}},
        {"light": {"to": "dusk", "secs": 200}}]},
    {"id": "p3_say", "when": {"all": [{"fired": "part3"}, COLUMN]}, "delay": 1, "do": [{"say": ["n_port", "r_port"]}]},
    {"id": "p3_say_f", "when": {"all": [{"fired": "part3"}, FIRE]}, "do": [{"say": ["n_f_port"]}]},
    {"id": "count_say", "when": {"all": [{"fired": "part3"}, COLUMN, {"counter": {"name": "aboard", "at_least": 3}}]}, "delay": 4, "do": [{"say": ["r_count"]}]},
] + [
    t for i, at in enumerate(ASSAULTS) for t in [
        {"id": "assault_%d" % (i + 1), "when": {"all": [{"fired": "part3"}, SOLO_C, LIVE]}, "delay": at, "do":
            fire_spawn("r3", "assault%d" % (i + 1), by_road(ASSAULT), tags=["assaults"]) + [{"ping": {"area": "bluff_front"}}]
            + ([{"say": ["n_assault"]}] if i == 0 else [])},
        {"id": "assault_%d_go" % (i + 1), "when": {"fired": "assault_%d" % (i + 1)}, "delay": 1, "do": [
            {"order": {"tag": "assault%d" % (i + 1), "do": "route", "route": ["r3", "r4", "r5", "r6", "bluff_front", "bluff_mid"], "attack": True,
                       "name": "assault%d" % (i + 1)}}]},
    ]
] + [
    {"id": "assault_push", "when": {"all": [{"fired": "assault_1"}, LIVE]}, "delay": 40, "every": 12, "do": [
        {"order": {"tag": "assaults", "do": "attack", "to": "bluff_mid", "idle": True}}]},
    # every group that still walks is aboard: the ships sail a little after (NO WAITING)
    {"id": "all_aboard", "when": {"all": [{"fired": "part3"}, {"count": {"tag": "people", "below": 1}}, LIVE]}, "do": [
        {"say": ["n_all_aboard"]}, {"clock": {"name": "ships", "secs": LAST_BOATS, "scale": False}}]},
    {"id": "sail", "when": {"all": [{"fired": "part3"}, LIVE, {"clock_out": "ships"}]}, "delay": 1, "do": [
        {"clock": {"name": "ships", "stop": True}}, {"objective": {"id": "ships", "set": "done"}},
        {"tally": {"flag": "colonists", "counter": "aboard", "of": "people_n", "bands": [[0, "few"], [SOME, "some"], [MANY, "many"]]}},
        {"tally": {"flag": "share", "counter": "aboard", "of": "people_n", "bands": [[0, "lost"], [LOSE_SHARE, "saved"]]}},
        {"tally": {"flag": "f_share", "counter": "aboard", "of": "people_n", "bands": [[0, "fire"], [FIRE_WIN, "column"]]}},
        {"flag": {"ruggieri": "alive"}}, {"light": {"to": "night", "secs": 6}}]},
    {"id": "remove_rest", "when": {"fired": "sail"}, "delay": 1, "do": [{"remove": {"tag": "people"}}]},
    # ============================================================ THE END
    # the column: a quarter aboard at least (and the fort standing) = won; fewer = lost (the fire played: half)
    {"id": "sail_won", "when": {"all": [{"fired": "sail"}, NO_FIRE, {"flag": {"share": "saved"}}]}, "do": [
        {"say": ["n_sail"]}, {"objective": {"id": "people_live", "set": "done"}}]},
    {"id": "sail_lost", "when": {"all": [{"fired": "sail"}, NO_FIRE, {"not": {"flag": {"share": "saved"}}}]}, "do": [
        {"say": ["n_too_few"]}, {"objective": {"id": "people_live", "set": "failed"}}]},
    {"id": "the_end", "when": {"any": [{"fired": "sail_won"}, {"fired": "f_sail_lost"}]}, "delay": 6, "do": [{"win": "column"}]},
    {"id": "lost_end", "when": {"any": [{"fired": "sail_lost"}, {"fired": "fort_lost"}]}, "delay": 6, "do": [{"lose": "column"}]},
    {"id": "fort_lost", "when": {"all": [{"dead": "harbour_fort"}, NO_FIRE, LIVE]}, "do": [{"say": ["n_fort_lost"]}]},
    # ============================================================ THE FIRE (the solo pick, versus)
    {"id": "f_objs", "when": {"all": [{"time": 1}, FIRE]}, "do": [{"objective": {"id": "f_catch", "set": "active"}}]},
    {"id": "f_reinf", "when": {"all": [FIRE, {"time": F_REINF_EVERY}, LIVE, {"not": {"fired": "sail"}}]}, "every": F_REINF_EVERY, "do":
        fire_spawn("edge", "f_army", by_road(REINF)) + [{"say": ["n_f_reinf"]}, {"ping": {"area": "edge"}}]},
    {"id": "f_sail_won", "when": {"all": [{"fired": "sail"}, FIRE, {"not": {"flag": {"f_share": "column"}}}]}, "do": [
        {"say": ["n_f_won"]}, {"objective": {"id": "f_catch", "set": "done"}}]},
    {"id": "f_sail_lost", "when": {"all": [{"fired": "sail"}, FIRE, {"flag": {"f_share": "column"}}]}, "do": [
        {"say": ["n_f_lost"]}, {"objective": {"id": "f_catch", "set": "failed"}}]},
    {"id": "f_fort", "when": {"all": [{"dead": "harbour_fort"}, FIRE, LIVE]}, "do": [
        {"say": ["n_fort_lost"]}, {"objective": {"id": "f_catch", "set": "done"}}, {"flag": {"colonists": "few"}}]},
    {"id": "f_end", "when": {"any": [{"fired": "f_sail_won"}, {"fired": "f_fort"}]}, "delay": 5, "do": [{"win": "fire"}]},
    # the scripted column (the fire played alone): the line holds the ford, then walks the road with the people, then the bluff
    {"id": "sc_hold", "when": {"all": [{"time": 1}, NO_COLUMN]}, "do": [
        {"order": {"tag": "line", "do": "move", "to": "ford_hold"}}, {"order": {"tag": "guns", "do": "move", "to": "ford_hold"}},
        {"order": {"tag": "riders", "do": "move", "to": "ford_hold"}}]},
    {"id": "sc_road", "when": {"all": [{"fired": "part2"}, NO_COLUMN]}, "delay": 3, "do": [
        {"order": {"tag": "line", "do": "route", "route": ["muster"] + ROAD[:-2], "attack": True, "name": "sc_line"}},
        {"order": {"tag": "ruggieri", "do": "route", "route": ["muster"] + ROAD[:-2], "name": "sc_rug"}},
        {"order": {"tag": "guns", "do": "follow", "leader": "ruggieri", "within": 4}},
        {"order": {"tag": "wagons", "do": "follow", "leader": "ruggieri", "within": 4}},
        {"order": {"tag": "drummer", "do": "follow", "leader": "g1", "within": 2}},
        {"order": {"tag": "riders", "do": "follow", "leader": "g2", "within": 5}}]},
    {"id": "sc_riders", "when": {"all": [{"fired": "sc_road"}, NO_COLUMN, LIVE]}, "delay": 20, "every": 20, "do": [
        {"order": {"tag": "riders", "do": "attack", "to": "r2"}}]},
    {"id": "sc_bluff", "when": {"all": [{"fired": "part3"}, NO_COLUMN]}, "every": 20, "do": [
        {"order": {"tag": "line", "do": "attack", "to": "bluff_mid", "idle": True}}, {"order": {"tag": "riders", "do": "attack", "to": "bluff_front", "idle": True}}]},
    # ============================================================ HURTS
    {"id": "r_hurt", "when": {"all": [{"hp": {"tag": "ruggieri", "below": 0.4}}, COLUMN]}, "every": 60, "times": 2, "do": [
        {"say": ["r_hurt"]}, {"ping": {"tag": "ruggieri"}}]},
]
# (an "if" inside an action's dictionary is not read by the engine: split those into triggers of their own, as d10's)
fixed = []
for t in TR_:
    plain, cond_acts = [], []
    for a in t["do"]:
        if isinstance(a, dict) and "if" in a and len(a) == 2:        # {"say": [...], "if": cond}
            c = a.pop("if")
            cond_acts.append((c, a))
            continue
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

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the army of Brazil is bound to C10 (THE DRUMMER), the first of the
# Crown line's Act 3 rungs (in any order: the others ride on "if_won"); the story's deny on top (a column on the road:
# it trains only at the harbour's Barracks, builds nothing)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID, story_deny={"column": ["town_hall", "cottage", "farm", "wall", "gate", "labourer", "messenger", "church",
                                                   "missionary", "powder_mill", "barracks", "horse_breeder", "foundry", "armoury"]})
for k in ("band",):
    T(M["lines"]["new_" + k]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the hubs' talks after e01 (campaign/campaign.json)
HUB = {
    "king": [
        ({"after": MID, "flag": {MID + ".colonists": "many"}},
         ("Ruggieri brought most of Brazil's people to the ships. He sent me the number, not a guess.",
          "Ruggieri levou a maior parte da gente do Brasil aos navios. Mandou-me o número, não um palpite.",
          "Ruggieri llevó a la mayor parte de la gente del Brasil a los barcos. Me mandó el número, no una suposición.")),
        ({"after": MID, "flag": {MID + ".colonists": "some"}},
         ("Ruggieri brought some of Brazil's people out. The rest are on that road still.",
          "Ruggieri trouxe parte da gente do Brasil. Os outros ainda estão naquela estrada.",
          "Ruggieri sacó a parte de la gente del Brasil. Los demás siguen en ese camino.")),
        ({"after": MID, "flag": {MID + ".colonists": "few"}},
         ("Ruggieri brought too few of Brazil's people out. He has not forgiven himself, and I have not asked him to.",
          "Ruggieri trouxe muito poucos da gente do Brasil. Não se perdoou, e eu não lho pedi.",
          "Ruggieri sacó a muy pocos de la gente del Brasil. No se ha perdonado, y yo no se lo he pedido.")),
    ],
    "dispatch": [
        ({"after": MID},
         ("Aboard, off the coast of Brazil. The army is at sea with the people it could carry. The guns are spiked on the bluff.",
          "A bordo, ao largo da costa do Brasil. O exército está no mar com a gente que pôde levar. Os canhões ficaram encravados no alto.",
          "A bordo, frente a la costa del Brasil. El ejército está en el mar con la gente que pudo llevar. Los cañones quedaron clavados en el alto.")),
    ],
}
for rows in HUB.values():
    for (_, txt) in rows:
        T(*txt)


def patch_campaign():
    """campaign/campaign.json: e01 joins the Crown line after d11 (Act 3 opens with both of the crossing's fronts won);
    the King's and the dispatch's talks after e01 (entries appended). Idempotent: a second run changes nothing. Nothing
    else in the file is touched (the war map's Act 3 is another job's)."""
    p = os.path.join(ROOT, "campaign", "campaign.json")
    c = json.load(open(p, encoding="utf-8"))
    for sl in c["storylines"]:
        ms = sl["missions"]
        if sl["id"] == "prologue" and MID not in ms:
            ms.insert(ms.index("d11_siege") + 1, MID)
        talks = sl.get("hub", {}).get("talks", {})
        if sl["id"] != "prologue":
            continue
        for who, rows in HUB.items():
            if who not in talks:
                continue
            ents = talks[who]["entries"]
            for (head, txt) in rows:
                e = dict(head)
                e["lines"] = [txt[0]]
                if not any(x.get("lines") == e["lines"] for x in ents):
                    ents.append(e)
    with open(p, "w", encoding="utf-8") as f:
        json.dump(c, f, indent="\t", ensure_ascii=False)
        f.write("\n")


out = os.path.join(ROOT, "campaign", "missions", MID + ".json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)
patch_campaign()

# ---------------------------------------------------------------- the translations
seen = set()
for path in glob.glob(os.path.join(ROOT, "tools", "i18n", "*.txt")) + glob.glob(os.path.join(ROOT, "tools", "i18n", "campaign", "*.txt")):
    if os.path.basename(path) == MID + ".txt":
        continue
    for ln in open(path, encoding="utf-8").read().split("\n"):
        if ln.startswith("> "):
            seen.add(ln[2:].replace("\\n", "\n"))
rows = ["# Act 3's mission e01_brazil, \"Brazil After the Fires\" (campaign/missions/e01_brazil.json, written with its texts by",
        "# tools/campaign/make_e01_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act3_plan.md; what was",
        "# built: docs/campaign_e01_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: the ford = o vau / el vado; the bluff =",
        "# o alto / el alto; the quay = o cais / el muelle; the Drummer = o Tambor / el Tambor; the fire fought second = o fogo combatido em",
        "# segundo / el fuego combatido en segundo.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
