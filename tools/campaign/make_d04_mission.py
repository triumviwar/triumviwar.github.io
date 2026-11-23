#!/usr/bin/env python3
"""Writes campaign/missions/d04_concordia.json: Act 2's "The City of Gears" (the Clockmaker line after d02, the southern
highlands of Brazil, 2773; the plan: docs/campaign_act2_plan.md "d04_concordia"; what was built:
docs/campaign_d04_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d04_concordia.txt: every text here is
written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d04_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_concordia_map.py (THE HIGHLANDS biome). EVERY LINE IS A PLACEHOLDER for the owner to rewrite.

Two years after the exodus the guild has bought an exhausted mine on the southern highlands with the last of its money.
Hollweg founds a free city there, CONCÓRDIA: a council of masters, no lord and no bishop, "a city that governs itself"
(the words Rome condemned). The colonists of the valley below hate it on sight: the ghost in the machine has crossed
the sea. In the mine's deepest gallery Hollweg opens the two crates he sent "for the mines in Brazil" in 2767.
  THE GUILD (BLUE, p1): Hollweg, the masters' Winders, Clock Soldiers (SHIELD WALL drilled), Springers, Netters, a
    Pendulum; the Escapement and the Light Works carried in pieces from Fürth and set up; the Heavy Works standing too
    with c01 `gate` pattern (and d02's drawings not taken). THE ROSTER LADDER's K5: the CLOCK AVIARY and the SWIFT, the
    machines in the air: THE FOG OF THE UNMAPPED (the land off the plateau is dark, and nothing on it is seen, until a
    Swift has flown over it).
  THE FAMILIES (BLUE, scripted): the first quarter's houses (by d02 `exodus` and c01 `saved`), and the council's
    secular voice: VARENNE (a06 spared: he came from exile on a ship from Lisbon) or CITIZEN MOREL (a06 executed).
  THE VALLEY (PURPLE militia; YELLOW town): Captain Bento Arruda's militia and the ranchers on horseback (scripted, or
    versus p2); the townsfolk who come up the road at night with torches (scripted); Padre Anselmo, the parish priest,
    who calls them home.
  PART 1, THE FOUNDING: raise the Clocktower over the old shaft, the Mainspring, the CLOCK AVIARY (K5), two Swifts;
    map the three ways up (the cart road, the pine path, the ranch track). The valley's captain comes up the road: with
    a04 `broken` melted he waits to PARLEY (Hollweg and the council's voice must go down to him: a STAY), with kept
    (the canon) he raids.
  PART 2, THE VALLEY'S FEAR (night): the townsfolk come up the road with torches, three crowds. The guild's machines
    are ordered to strike no man of the valley (the townsfolk can't be hurt): TURN THEM BACK (fighters round one and no
    militia by him, 3 s) and put out the fires (any man of the guild by a burning building). Every fire raises THE
    VALLEY'S TEMPER (a burnt house twice); at its top the militia rides at once (Part 3 early, harder). Padre Anselmo
    comes up the road and calls his people home.
  PART 3, THE CRATES (dawn): Hollweg opens the two crates in the deepest gallery (a STAY): two Clock Soldiers of a
    pattern nobody remembers building, a Winder, and gear plates that creep across the floor by themselves (a spreading
    gear ground: the meshing's first sign, unremarked); the militia's attack at dawn up all three ways; hold until it
    breaks, and the city stands.
  NO CHOICE. CARRIES: `colonists` parley / fought (the valley's temper: d07's crowd), `crates` opened (always on a win).
  VERSUS: the friend is THE VALLEY (the militia, with the town's Barracks and the ranches' Horse Breeder): burn the
    first quarter, bring the Clocktower down, or bring Hollweg down.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d04_concordia"

# ---------------------------------------------------------------- the texts, three languages at once
TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d04_concordia.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
PATTERN = {"all": [notpast("c01_thirteenth.gate", "people"), notpast("d02_exodus.drawings", "taken")]}
FROM_MEMORY = {"not": PATTERN}                     # (c01 `gate` people, or d02's drawings taken by the Crown)
PEOPLE = past("c01_thirteenth.gate", "people")
DRAW_TAKEN = {"all": [{"not": PEOPLE}, past("d02_exodus.drawings", "taken")]}
MELTED = past("a04_visit.broken", "melted")
KEPT = {"not": MELTED}
EXECUTED = past("a06_barricades.varenne", "executed")
SPARED = {"not": EXECUTED}
EX_FEW = past("d02_exodus.exodus", "few")
EX_MANY = past("d02_exodus.exodus", "many")
C01_MANY = past("c01_thirteenth.saved", "many")
VAL = {"playing": "valley"}                        # (versus: a person leads the valley's militia)
NO_VAL = {"not": VAL}
LIVE = {"not": {"any": [{"fired": "the_end"}, {"fired": "v_end"}, {"fired": "lost_end"}]}}

# ---------------------------------------------------------------- numbers (NORMAL; EASY clocks x1.25 spawns x0.75, HARD x0.9 / x1.15)
GOLD = 600                   # the guild's cogs at the start (the sites are paid for: two Swifts 150, the rest for soldiers or presses)
TENSION = 100                # ... and wound Tension (the Aviary 50, a Swift 15)
CAPTAIN_SECS = 200           # Part 1: the valley's captain comes up the road this long after the Clocktower stands
CAPTAIN_MAPPED = 20          # ... or this soon once the three ways are mapped
PARLEY_WAIT = 90             # (a04 melted) the captain waits this long on the road for Hollweg
PARLEY_SECS = 3              # Hollweg and the council's voice this long by the captain: the parley
NIGHT_GAP = 20               # Part 1 over (the raid beaten or the parley done): the night falls after this
MOB_EVERY = 40               # Part 2: a crowd every so often up the road (three)
MOB = (3, 4, 4)              # ... its torch-bearers (+1 each with a04 `broken` kept: the canon)
ANSELMO_AFTER = 25           # Padre Anselmo comes up the road this long after the third crowd
TURN_SECS = 2                # TURN THEM BACK: fighters round a torch-bearer, no militia by him, this long
HOUSE_HP = 900               # the first quarter's houses: timber on stone footings (a cottage's 400 burns in one raid)
FIRE_SECS = 50               # a house set alight burns down in this long (unless put out)
TEMPER_TOP = {"easy": 10, "normal": 8, "hard": 6}     # THE VALLEY'S TEMPER: at this the militia rides at once
CRATE_SECS = 8               # Part 3: Hollweg this long in the deepest gallery opens the crates
ATTACK_AFTER = 40            # Part 3: the dawn attack this long after the dawn (or soon after the crates are opened)
BREAK_AT = 4                 # the attack breaks when fewer than this many of it are left
DAWN_SECS = 240              # the attack withdraws at the latest this long after it came (the city stood)
GUILD = {"winder": 4, "clock_soldier": 6, "springer": 2, "netter": 2, "pendulum": 1}

# the first quarter: the families' houses (BLUE, scripted). 3 with d02 `exodus` some (the canon), 2 few, 4 many; +1
# with c01 `saved` many.
HOUSES = [[68, 17], [68, 21], [71, 25], [73, 29], [65, 19]]
HOUSE_IF = [None, None, {"not": EX_FEW}, EX_MANY, C01_MANY]
# the city's buildings (the guild's, carried from Fürth or raised here): T = the Clocktower over the old shaft; two
# Regulators at [71, 15] and [71, 22] (the supply: Swifts need it), their rings the field's west edge by the quarter
TOWER = [80, 18]
# (each ring meshing with the tower's or its neighbour's: GearNet.ring_spot round a tower at TOWER; the city's gear field,
# where the machines stay wound, is the rings: x 72-98, y 12-29)
ESCAPEMENT, LIGHT_WORKS, HEAVY_WORKS = [88, 17], [73, 18], [77, 25]
SPRING_AT, AVIARY_AT, PRESS_AT = [90, 21], [95, 23], [81, 12]
# the three ways up and their routes (cells; areas below)
ROAD = ["road_low", "road_mid", "road_top", "ramp_road", "quarter"]
PATH = ["path_w", "path_e", "ramp_path", "tower_area"]
TRACK = ["track_low", "ramp_track", "tower_area"]


# ================================================================== the mission
units = [
    # ---- the guild (the player): Hollweg and the masters' machines, at the camp
    {"team": "guild", "kind": "missionary", "as": "hollweg", "count": 1, "at": [78, 30], "tag": "hollweg"},
] + [
    {"team": "guild", "kind": k, "count": n, "at": "camp", "tag": "army", "fixed": True} for k, n in GUILD.items()
] + [
    # ---- the families and the council's secular voice
    {"team": "families", "kind": "labourer", "as": "settler", "count": 4, "at": "camp", "tag": "settlers"},
    {"team": "families", "kind": "missionary", "as": "varenne_exile", "count": 1, "at": [76, 31], "tag": "voice", "tags": ["varenne"], "if": SPARED},
    {"team": "families", "kind": "missionary", "as": "morel", "count": 1, "at": [76, 31], "tag": "voice", "tags": ["morel"], "if": EXECUTED},
    # ---- the valley: the militia waits in the town (versus: the friend's army from the start)
    {"team": "militia", "kind": "cuirassier", "as": "arruda", "count": 1, "at": "town_sq", "tag": "arruda", "if": VAL},
    {"team": "militia", "kind": "musketeer", "as": "valley_militia", "count": 4, "at": "town_sq", "tag": "militia_men", "if": VAL},
    {"team": "militia", "kind": "cuirassier", "as": "rancher", "count": 3, "at": "ranch", "tag": "militia_men", "if": VAL},
    {"team": "town", "kind": "labourer", "as": "colonist", "count": 5, "at": "town_sq", "tag": "townsfolk"},
]

buildings = (
    # the guild's: the Escapement and the Light Works carried in pieces from Fürth and set up; the Heavy Works by the
    # pattern (c01 gate; d02's drawings not taken)
    [{"team": "guild", "kind": "escapement", "at": ESCAPEMENT, "tag": "city"},
     {"team": "guild", "kind": "movement_works", "at": LIGHT_WORKS, "tag": "city"},
     {"team": "guild", "kind": "regulator", "at": [71, 15], "tag": "city"},
     {"team": "guild", "kind": "regulator", "at": [71, 22], "tag": "city"},
     {"team": "guild", "kind": "heavy_works", "at": HEAVY_WORKS, "tag": "city", "tags": ["heavy"], "if": PATTERN}]
    # the first quarter
    + [dict({"team": "families", "kind": "cottage", "at": at, "tag": "house_%d" % (i + 1), "tags": ["houses", "city"],
             "name": T("A family's house", "A casa de uma família", "La casa de una familia")}, **({"if": HOUSE_IF[i]} if HOUSE_IF[i] else {}))
       for i, at in enumerate(HOUSES)]
    # the valley: the white church and the cottages of the town (yellow), the militia's Barracks and the ranches'
    # Horse Breeder (purple: the versus friend trains there)
    + [{"team": "town", "kind": "church", "at": [18, 68], "tag": "church", "name": T("The valley's church", "A igreja do vale", "La iglesia del valle")},
       {"team": "town", "kind": "cottage", "at": [8, 66], "tag": "town_b"},
       {"team": "town", "kind": "cottage", "at": [10, 76], "tag": "town_b"},
       {"team": "town", "kind": "cottage", "at": [22, 84], "tag": "town_b"},
       {"team": "militia", "kind": "barracks", "at": [24, 72], "tag": "valley_b"},
       {"team": "militia", "kind": "horse_breeder", "at": [100, 82], "tag": "valley_b"}]
)

areas = {
    # the plateau and the city
    "plateau": [54, 0, 66, 52], "camp": [70, 27, 6, 5], "tower_area": [76, 14, 14, 12], "quarter": [64, 15, 12, 17],
    "west_field": [77, 18, 3, 3], "mine": [102, 8, 6, 6], "gallery": [110, 2, 5, 4], "spring_spot": [90, 21, 3, 3], "aviary_spot": [95, 23, 2, 2],
    # the three ways up (the ramps) and what lies below each (the land the Swifts must map)
    "ramp_road": [46, 32, 4, 4], "ramp_path": [50, 9, 4, 4], "ramp_track": [92, 51, 4, 4],
    "way_road": [30, 36, 16, 22], "way_path": [6, 6, 42, 14], "way_track": [92, 56, 12, 22],
    # the cart road down to the town, the pine path in the woods, the ranch track
    "road_top": [39, 32, 6, 6], "road_mid": [35, 40, 4, 4], "road_low": [30, 52, 4, 4], "parley": [38, 33, 6, 5],
    "path_w": [5, 20, 5, 5], "path_e": [40, 9, 5, 4], "track_low": [95, 64, 4, 4], "ranch": [94, 78, 12, 8],
    # the valley
    "town": [0, 60, 30, 34], "town_sq": [12, 70, 6, 6], "home_exit": [12, 64, 8, 8], "valley_view": [0, 56, 40, 38],
}

TAKE = [
    # TURN THEM BACK: the townsfolk with torches can't be hurt; fighters of the guild round one with no militia by him for
    # 3 s send him home (his torch out)
    {"tag": "mob", "by": "guild", "to": "calmed", "secs": TURN_SECS, "within": 2, "guard": 0, "counter": "turned_back", "as": "turned",
     "label": T("TURNING BACK", "A FAZER VOLTAR", "HACIÉNDOLO VOLVER"), "word": T("TURNED BACK!", "VOLTOU PARA TRÁS!", "¡SE VUELVE!"), "untorch": True},
]

objectives = [
    # ---- part 1: the founding
    {"id": "tower", "side": "guild", "primary": True, "kind": "build", "tag": "tower",
     "text": T("Raise the Clocktower over the mine's old shaft: send your Winders to its site. Everything in the city runs from it.",
               "Erga a Torre do Relógio sobre o velho poço da mina: mande os seus Enroladores ao local. Tudo na cidade funciona a partir dela.",
               "Alza la Torre del Reloj sobre el viejo pozo de la mina: envía a tus Dadores de cuerda al solar. Todo en la ciudad funciona desde ella."),
     "phone": T("Raise the Clocktower: Winders to its site.", "Erga a Torre do Relógio: Enroladores ao local.", "Alza la Torre del Reloj: Dadores de cuerda al solar.")},
    {"id": "spring", "side": "guild", "primary": False, "kind": "build", "tag": "spring", "hidden": True,
     "text": T("Build the Mainspring at its site beside the Escapement. It winds the Tension the Clock Aviary and its Swifts are made with.",
               "Construa a Mola Real no seu local ao lado do Escape. Ela dá a Tensão com que se fazem a Casa do Cuco e os seus Cucos.",
               "Construye el Muelle Real en su solar junto al Escape. Da la Tensión con la que se hacen la Casa del Cuco y sus Cucos.")},
    {"id": "press", "side": "guild", "primary": False, "kind": "build", "tag": "press", "hidden": True,
     "text": T("Build the Cog Press at its site north of the tower: it brings the cogs that pay for soldiers at the Light Works.",
               "Construa a Prensa de Engrenagens no seu local a norte da torre: traz as engrenagens que pagam os soldados da Oficina Leve.",
               "Construye la Prensa de Engranajes en su solar al norte de la torre: trae los engranajes que pagan los soldados del Taller Ligero.")},
    {"id": "aviary", "side": "guild", "primary": False, "kind": "build", "tag": "aviary", "hidden": True,
     "text": T("Build the CLOCK AVIARY at its site: the machines' birds fly from it.", "Construa a CASA DO CUCO no seu local: os pássaros das máquinas voam dela.",
               "Construye la CASA DEL CUCO en su solar: los pájaros de las máquinas vuelan desde él.")},
    {"id": "swifts", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Make two Swifts at the Clock Aviary: {swifts} of 2. Pick the Aviary and press SWIFT.",
               "Faça dois Cucos na Casa do Cuco: {swifts} de 2. Escolha a Casa do Cuco e aperte CUCO.",
               "Haz dos Cucos en la Casa del Cuco: {swifts} de 2. Elige la Casa del Cuco y pulsa CUCO.")},
    {"id": "map", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Map the three ways up to the plateau: {mapped} of 3. Fly a Swift over the cart road (west), the pine path (north-west) and the ranch track (south). The land stays dark, and whoever walks on it unseen, until a Swift has flown over it.",
               "Mapeie os três caminhos para o planalto: {mapped} de 3. Voe um Cuco sobre a estrada dos carros (oeste), o trilho dos pinheiros (noroeste) e o trilho das fazendas (sul). A terra fica escura, e quem anda nela sem ser visto, até um Cuco voar sobre ela.",
               "Cartografía los tres caminos al altiplano: {mapped} de 3. Vuela un Cuco sobre el camino de los carros (oeste), la senda de los pinos (noroeste) y la senda de los ranchos (sur). La tierra sigue oscura, y quien camina por ella sin ser visto, hasta que un Cuco vuela sobre ella."),
     "phone": T("Map the three ways up: {mapped} of 3. Fly a Swift over each.", "Mapeie os três caminhos: {mapped} de 3. Um Cuco sobre cada um.",
                "Cartografía los tres caminos: {mapped} de 3. Un Cuco sobre cada uno.")},
    {"id": "captain_clock", "side": "guild", "primary": False, "kind": "countdown", "clock": "captain", "hidden": True,
     "text": T("The valley's captain rides up the cart road in {clock:captain}.", "O capitão do vale sobe a estrada dos carros em {clock:captain}.",
               "El capitán del valle sube por el camino de los carros en {clock:captain}.")},
    {"id": "parley", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
     "text": T("The valley's captain waits on the cart road below the west ramp to talk. Walk Meister Hollweg down to him and keep him there a moment: the council's speaker goes with him.",
               "O capitão do vale espera na estrada dos carros abaixo da rampa oeste para conversar. Leve o Mestre Hollweg até ele e mantenha-o lá um momento: o porta-voz do conselho vai com ele.",
               "El capitán del valle espera en el camino de los carros bajo la rampa oeste para hablar. Lleva al maestro Hollweg hasta él y mantenlo allí un momento: el portavoz del consejo va con él.")},
    {"id": "raid", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
     "text": T("The valley's men are on the plateau: drive them off. {raid_left} left.", "Os homens do vale estão no planalto: expulse-os. Restam {raid_left}.",
               "Los hombres del valle están en el altiplano: échalos. Quedan {raid_left}.")},
    # ---- always
    {"id": "quarter", "side": "guild", "primary": True, "kind": "manual",
     "text": T("The first quarter must stand: {houses} of {houses_n} houses.", "O primeiro bairro tem de ficar de pé: {houses} de {houses_n} casas.",
               "El primer barrio debe seguir en pie: {houses} de {houses_n} casas.")},
    {"id": "hollweg", "side": "guild", "primary": True, "kind": "protect", "tag": "hollweg",
     "text": T("Meister Hollweg must live. Hurt, he falls back to the tower.", "O Mestre Hollweg tem de viver. Ferido, recua para a torre.",
               "El maestro Hollweg debe vivir. Herido, se retira a la torre.")},
    # ---- part 2: the valley's fear
    {"id": "fear", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
     "text": T("The valley's people come up the road with torches. Your machines will strike no man of the valley: TURN THEM BACK (stand fighters round one, none of the militia by him, a moment) and PUT OUT the fires (any of your men by a burning building). Turned back: {turned_back}.",
               "O povo do vale sobe a estrada com tochas. As suas máquinas não vão ferir nenhum homem do vale: FAÇA-OS VOLTAR (ponha combatentes à volta de um, sem ninguém da milícia ao lado dele, um momento) e APAGUE os incêndios (qualquer um dos seus homens junto a um edifício a arder). Mandados de volta: {turned_back}.",
               "La gente del valle sube por el camino con antorchas. Tus máquinas no herirán a ningún hombre del valle: HAZLOS VOLVER (pon combatientes alrededor de uno, sin nadie de la milicia a su lado, un momento) y APAGA los fuegos (cualquiera de tus hombres junto a un edificio en llamas). Devueltos: {turned_back}."),
     "phone": T("Turn the torch-bearers back (fighters round one) and put out fires. Turned back: {turned_back}.",
                "Faça voltar os portadores de tochas (combatentes à volta de um) e apague os incêndios. De volta: {turned_back}.",
                "Haz volver a los portadores de antorchas (combatientes alrededor de uno) y apaga los fuegos. Devueltos: {turned_back}.")},
    {"id": "temper", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
     "text": T("The valley's temper: {temper} of {temper_top}. Every fire raises it, a burnt house twice; at the top the militia rides at once.",
               "O ânimo do vale: {temper} de {temper_top}. Cada incêndio o aumenta, uma casa queimada duas vezes; no topo a milícia cavalga de imediato.",
               "El ánimo del valle: {temper} de {temper_top}. Cada fuego lo sube, una casa quemada dos veces; en lo alto la milicia cabalga enseguida.")},
    # ---- part 3: the crates
    {"id": "crates", "side": "guild", "primary": True, "kind": "manual", "hidden": True,
     "text": T("The crates of 2767 lie in the mine's deepest gallery (north-east, behind the spoil heaps). Bring Meister Hollweg there and keep him there a while: only he knows the seal.",
               "Os caixotes de 2767 estão na galeria mais funda da mina (nordeste, atrás dos montes de entulho). Leve o Mestre Hollweg até lá e mantenha-o lá um pouco: só ele conhece o selo.",
               "Las cajas de 2767 están en la galería más honda de la mina (noreste, tras los montones de escombro). Lleva al maestro Hollweg allí y mantenlo un rato: solo él conoce el sello.")},
    {"id": "attack", "side": "guild", "primary": True, "kind": "manual", "hidden": True,
     "text": T("The valley's militia attacks at dawn, up all three ways. Hold the city until the attack breaks: {attack_left} of the attackers left.",
               "A milícia do vale ataca ao amanhecer, pelos três caminhos. Segure a cidade até o ataque quebrar: restam {attack_left} dos atacantes.",
               "La milicia del valle ataca al amanecer, por los tres caminos. Resiste en la ciudad hasta que el ataque se rompa: quedan {attack_left} de los atacantes."),
     "phone": T("Hold the city until the attack breaks: {attack_left} left.", "Segure a cidade até o ataque quebrar: restam {attack_left}.",
                "Resiste en la ciudad hasta que el ataque se rompa: quedan {attack_left}.")},
    {"id": "city_tower", "side": "guild", "primary": True, "kind": "protect", "tag": "tower", "hidden": True,
     "text": T("The Clocktower must stand.", "A Torre do Relógio tem de ficar de pé.", "La Torre del Reloj debe seguir en pie.")},
    # ---- the valley (versus)
    {"id": "v_burn", "side": "valley", "primary": False, "kind": "manual",
     "text": T("Burn the city's first quarter before it takes root: {houses} houses stand. Torches set them alight; muskets do the rest.",
               "Queime o primeiro bairro da cidade antes que crie raízes: {houses} casas de pé. As tochas as incendeiam; os mosquetes fazem o resto.",
               "Quema el primer barrio de la ciudad antes de que eche raíces: {houses} casas en pie. Las antorchas las prenden; los mosquetes hacen el resto.")},
    {"id": "v_tower", "side": "valley", "primary": False, "kind": "manual",
     "text": T("Or bring down the Clocktower, or Meister Hollweg himself.", "Ou derrube a Torre do Relógio, ou o próprio Mestre Hollweg.",
               "O derriba la Torre del Reloj, o al propio maestro Hollweg.")},
]

M = {
    "id": MID,
    "title": T("The City of Gears", "A Cidade das Engrenagens", "La Ciudad de los Engranajes"),
    "summary": T("The southern highlands of Brazil, 2773. Over an old mine Meister Hollweg founds Concórdia, a city that governs itself. The valley below fears it from the first day.",
                 "As terras altas do sul do Brasil, 2773. Sobre uma velha mina o Mestre Hollweg funda Concórdia, uma cidade que se governa a si mesma. O vale lá em baixo teme-a desde o primeiro dia.",
                 "Las tierras altas del sur de Brasil, 2773. Sobre una vieja mina el maestro Hollweg funda Concórdia, una ciudad que se gobierna a sí misma. El valle de abajo la teme desde el primer día."),
    "map": "campaign:concordia",
    "voice": "d04",
    "light": "day",
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["d02_exodus"],
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {"clocks": 0.9, "spawns": 1.15}},
    "modes": ["solo", "versus"],
    "sides": [
        {"id": "guild", "name": T("The Guild", "A Guilda", "El Gremio"),
         "about": T("Meister Hollweg's guild and its families, founding a city on the southern highlands.",
                    "A guilda do Mestre Hollweg e as suas famílias, fundando uma cidade nas terras altas do sul.",
                    "El gremio del maestro Hollweg y sus familias, fundando una ciudad en las tierras altas del sur.")},
        {"id": "valley", "name": T("The Valley", "O Vale", "El Valle"),
         "about": T("The colonists of the valley below: Captain Arruda's militia, the ranchers, the town and its priest.",
                    "Os colonos do vale lá em baixo: a milícia do Capitão Arruda, os fazendeiros, a vila e o seu padre.",
                    "Los colonos del valle de abajo: la milicia del capitán Arruda, los rancheros, el pueblo y su cura.")},
    ],
    "teams": [
        {"id": "guild", "side": "guild", "faction": "clockwork", "colour": 0, "start": "none", "camera": "camp", "gold": GOLD,
         "techs": ["shield_wall"], "control": {"solo": "p1", "versus": "p1"}},
        {"id": "families", "side": "guild", "faction": "crown", "colour": 0, "start": "none", "camera": "camp",
         "control": {"solo": "script", "versus": "script"}},
        # (the valley's people turned back: they put out their torches and walk home; a team on the guild's side so no
        # rule takes them again and nobody fights them)
        {"id": "calmed", "side": "guild", "faction": "crown", "colour": 3, "start": "none", "camera": "home_exit",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "militia", "side": "valley", "faction": "crown", "colour": 4, "start": "none", "camera": "town_sq", "gold": 400, "powder": 300,
         "control": {"solo": "script", "versus": "p2"}},
        {"id": "town", "side": "valley", "faction": "crown", "colour": 3, "start": "none", "camera": "town_sq",
         "control": {"solo": "script", "versus": "script"}},
    ],
    "areas": areas,
    "counters": {"swifts": {"start": 0}, "mapped": {"start": 0}, "houses": {"start": 0}, "houses_n": {"start": 0},
                 "raid_left": {"start": 0}, "turned_back": {"start": 0}, "temper": {"start": 0}, "temper_top": {"start": TEMPER_TOP["normal"]},
                 "home_n": {"start": 0}, "mob_n": {"start": 0}, "attack_left": {"start": 0}, "attack_n": {"start": 0}},
    "take_carts": TAKE,
    "torch_fire": {"tag": "city", "secs": FIRE_SECS, "douse_side": "guild", "douse_secs": 6, "counter": "temper"},
    "exits": [
        {"area": "home_exit", "tag": "turned", "counter": "home_n", "after": "part2"},
        {"area": "home_exit", "tag": "gone_home", "after": "part2"},
    ],
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["hollweg"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "guild", "portrait": "res://campaign/hub/rome_king_face.png"},
        "hollweg": {"name": T("Meister Hollweg", "Mestre Hollweg", "Maestro Hollweg"), "side": "guild", "portrait": "res://campaign/hub/nuremberg_hollweg_face.png"},
        "ulrich": {"name": T("Master Ulrich", "Mestre Ulrich", "Maestro Ulrich"), "side": "guild"},
        "varenne": {"name": T("Etienne Varenne", "Etienne Varenne", "Etienne Varenne"), "side": "guild"},
        "morel": {"name": T("Citizen Morel", "Cidadão Morel", "Ciudadano Morel"), "side": "guild"},
        "arruda": {"name": T("Captain Arruda", "Capitão Arruda", "Capitán Arruda"), "side": "valley"},
        "anselmo": {"name": T("Padre Anselmo", "Padre Anselmo", "Padre Anselmo"), "side": "valley"},
        "narrator": {"name": T("Concórdia", "Concórdia", "Concórdia"), "side": "guild"},
    },
    "lines": {},
    "stills": {},
    "next": {"guild": "", "valley": ""},
}

L = M["lines"]


def line(lid, who, en, pt, es, to=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    return lid


GU, VA = "guild", "valley"
# ---- the opening (the King, then Hollweg; Varenne's ship by the flag)
line("k_open1", "king", "He named it for concord. The valley named it otherwise.",
     "Ele chamou-lhe concórdia. O vale chamou-lhe outra coisa.", "Él la llamó concordia. El valle la llamó de otra manera.")
line("k_open2", "king", "Two years after he left my Crown, Hollweg bought a dead mine at the bottom of the world, and built a city on it that answered to nobody.",
     "Dois anos depois de deixar a minha Coroa, Hollweg comprou uma mina morta no fim do mundo, e construiu sobre ela uma cidade que não respondia a ninguém.",
     "Dos años después de dejar mi Corona, Hollweg compró una mina muerta en el fin del mundo, y construyó sobre ella una ciudad que no respondía a nadie.")
line("h_open1", "hollweg", "A city that governs itself. A council of masters, every voice a wheel, and the wheels in time. That was the plan.",
     "Uma cidade que se governa a si mesma. Um conselho de mestres, cada voz uma roda, e as rodas a tempo. Esse era o plano.",
     "Una ciudad que se gobierna a sí misma. Un consejo de maestros, cada voz una rueda, y las ruedas a tiempo. Ese era el plan.")
line("h_open2", "hollweg", "Rome had said those very words were a sin. I said them louder.",
     "Roma tinha dito que essas mesmas palavras eram pecado. Eu disse-as mais alto.", "Roma había dicho que esas mismas palabras eran pecado. Yo las dije más alto.")
line("h_open_v", "hollweg", "A ship from Lisbon brought us a man I never thought I would need: Etienne Varenne, the Assembly's orator, whom the King had spared and sent away.",
     "Um navio de Lisboa trouxe-nos um homem de quem eu nunca pensei precisar: Etienne Varenne, o orador da Assembleia, que o Rei poupara e mandara embora.",
     "Un barco de Lisboa nos trajo a un hombre que nunca pensé necesitar: Etienne Varenne, el orador de la Asamblea, a quien el Rey había perdonado y desterrado.")
line("h_open_m", "hollweg", "A ship from Lisbon brought us one of the Assembly's men, Citizen Morel. Varenne was dead. Morel had not forgiven anyone for it.",
     "Um navio de Lisboa trouxe-nos um dos homens da Assembleia, o Cidadão Morel. Varenne estava morto. Morel não perdoara ninguém por isso.",
     "Un barco de Lisboa nos trajo a uno de los hombres de la Asamblea, el ciudadano Morel. Varenne estaba muerto. Morel no había perdonado a nadie por ello.")
# ---- part 1: the founding
line("h_1", "hollweg", "The tower first. Over the old shaft, where the ground is sound. Everything else turns round it.",
     "A torre primeiro. Sobre o velho poço, onde o chão é firme. Todo o resto gira à volta dela.",
     "La torre primero. Sobre el viejo pozo, donde el suelo es firme. Todo lo demás gira a su alrededor.", GU)
line("u_tip1", "ulrich", "The tower's site is marked by the shaft, Meister. Send the Winders; four hands raise it quickly.",
     "O local da torre está marcado junto ao poço, Mestre. Mande os Enroladores; quatro mãos erguem-na depressa.",
     "El solar de la torre está marcado junto al pozo, maestro. Envía a los Dadores de cuerda; cuatro manos la alzan deprisa.", GU)
line("u_dark", "ulrich", "And look how little we know of this place. Everything off the plateau is dark to us: anyone could walk up those roads and we would not see him.",
     "E veja como pouco conhecemos deste lugar. Tudo fora do planalto está escuro para nós: qualquer um podia subir aquelas estradas e não o veríamos.",
     "Y mira qué poco conocemos de este lugar. Todo lo que está fuera del altiplano está oscuro para nosotros: cualquiera podría subir por esos caminos y no lo veríamos.", GU)
line("h_tower", "hollweg", "The tower stands. Now the spring, then the birds. I want this country mapped from the air, every road, before the first winter.",
     "A torre está de pé. Agora a mola, depois os pássaros. Quero esta terra mapeada do ar, cada estrada, antes do primeiro inverno.",
     "La torre está en pie. Ahora el muelle, luego los pájaros. Quiero esta tierra cartografiada desde el aire, cada camino, antes del primer invierno.", GU)
line("u_field", "ulrich", "The tower's gears are turning, Meister. Keep the soldiers on the gear rings round our buildings: there they stay wound. Off the gears they run down in a minute or so.",
     "As engrenagens da torre estão a girar, Mestre. Mantenha os soldados nos anéis de engrenagens à volta dos nossos edifícios: aí ficam com corda. Fora das engrenagens perdem a corda num minuto ou pouco mais.",
     "Los engranajes de la torre giran, maestro. Mantén a los soldados sobre los anillos de engranajes alrededor de nuestros edificios: allí siguen con cuerda. Fuera de los engranajes se paran en un minuto o poco más.", GU)
line("u_spring", "ulrich", "The Aviary runs on Tension, Meister, and Tension comes from the Mainspring. Its site is by the Escapement.",
     "A Casa do Cuco funciona com Tensão, Mestre, e a Tensão vem da Mola Real. O local dela é junto ao Escape.",
     "La Casa del Cuco funciona con Tensión, maestro, y la Tensión viene del Muelle Real. Su solar está junto al Escape.", GU)
line("u_presses", "ulrich", "While the Aviary rises: the city has cogs for now, not for ever. The press north of the tower brings more, and the Light Works turns them into soldiers.",
     "Enquanto a Casa do Cuco sobe: a cidade tem engrenagens por agora, não para sempre. A prensa a norte da torre traz mais, e a Oficina Leve transforma-as em soldados.",
     "Mientras se alza la Casa del Cuco: la ciudad tiene engranajes por ahora, no para siempre. La prensa al norte de la torre trae más, y el Taller Ligero los convierte en soldados.", GU)
line("u_aviary", "ulrich", "The spring is wound. Now the Aviary: its site is east of the tower. A Winder or two will raise it.",
     "A mola tem corda. Agora a Casa do Cuco: o local dela é a leste da torre. Um ou dois Enroladores erguem-na.",
     "El muelle tiene cuerda. Ahora la Casa del Cuco: su solar está al este de la torre. Uno o dos Dadores de cuerda la alzan.", GU)
line("u_swifts", "ulrich", "The Aviary is up. Pick it and make Swifts. Little brass birds: they fight only other birds, but they see a long way.",
     "A Casa do Cuco está de pé. Escolha-a e faça Cucos. Pequenos pássaros de latão: só lutam contra outros pássaros, mas veem muito longe.",
     "La Casa del Cuco está en pie. Elígela y haz Cucos. Pajaritos de latón: solo luchan contra otros pájaros, pero ven muy lejos.", GU)
line("h_map", "hollweg", "Fly them down the three ways: the cart road west, the pine path north-west, the ranch track south. What a bird has seen, the guild knows.",
     "Voem-nos pelos três caminhos: a estrada dos carros a oeste, o trilho dos pinheiros a noroeste, o trilho das fazendas a sul. O que um pássaro viu, a guilda sabe.",
     "Volad por los tres caminos: el camino de los carros al oeste, la senda de los pinos al noroeste, la senda de los ranchos al sur. Lo que un pájaro ha visto, el gremio lo sabe.", GU)
line("n_mapped", "narrator", "A way up is mapped.", "Um caminho foi mapeado.", "Un camino está cartografiado.", GU)
line("h_mapped_all", "hollweg", "There. The whole country under one eye. From above, every road is only a gear's tooth.",
     "Pronto. Toda a terra sob um só olho. Lá de cima, cada estrada é só o dente de uma engrenagem.",
     "Ya está. Toda la tierra bajo un solo ojo. Desde arriba, cada camino es solo el diente de un engranaje.", GU)
line("v_1", "varenne", "A city without a lord, Meister. I have heard this sermon before. I preached it, in Virginia and in Paris.",
     "Uma cidade sem senhor, Mestre. Já ouvi este sermão antes. Preguei-o, na Virgínia e em Paris.",
     "Una ciudad sin señor, maestro. Ya he oído este sermón. Lo prediqué, en Virginia y en París.", GU)
line("h_v1", "hollweg", "Yours was made of men, Varenne. Mine is made of wheels. Wheels keep time.",
     "O seu era feito de homens, Varenne. O meu é feito de rodas. As rodas marcam o tempo.",
     "El tuyo estaba hecho de hombres, Varenne. El mío está hecho de ruedas. Las ruedas llevan el tiempo.", GU)
line("v_2", "varenne", "Paris burned keeping time. I watched it from a boat.",
     "Paris ardeu a marcar o tempo. Eu vi-o de um barco.", "París ardió llevando el tiempo. Lo vi desde un barco.", GU)
line("m_1", "morel", "No lord and no bishop. Good. Then let the valley learn it too, Meister, and quickly.",
     "Nem senhor nem bispo. Bem. Então que o vale o aprenda também, Mestre, e depressa.",
     "Ni señor ni obispo. Bien. Entonces que el valle lo aprenda también, maestro, y pronto.", GU)
line("h_m1", "hollweg", "The valley can learn what it likes. We did not come here to teach.",
     "O vale pode aprender o que quiser. Não viemos aqui para ensinar.", "El valle puede aprender lo que quiera. No vinimos aquí a enseñar.", GU)
line("h_crates_seen", "hollweg", "Somewhere under us lie the two crates I sent from Nuremberg. They had lain on a quay in the jungle once, I learned later.",
     "Algures debaixo de nós estão os dois caixotes que enviei de Nuremberg. Tinham estado num cais na selva, soube mais tarde.",
     "En algún lugar bajo nosotros están las dos cajas que envié desde Núremberg. Habían estado en un muelle en la selva, supe más tarde.", GU)
line("h_memory", "hollweg", "No Heavy Works yet. I build it from memory, and memory is slow. The drawings are in Nuremberg, or in the Crown's hands.",
     "Ainda não há Oficina Pesada. Construo-a de memória, e a memória é lenta. Os desenhos estão em Nuremberg, ou nas mãos da Coroa.",
     "Todavía no hay Taller Pesado. Lo construyo de memoria, y la memoria es lenta. Los planos están en Núremberg, o en manos de la Corona.", GU)
line("u_captain", "ulrich", "A rider from the valley, Meister. Their captain, coming up the cart road.",
     "Um cavaleiro do vale, Mestre. O capitão deles, a subir a estrada dos carros.", "Un jinete del valle, maestro. Su capitán, subiendo por el camino de los carros.", GU)
line("a_wait", "arruda", "I am Bento Arruda, captain of the valley's militia. I will talk with the master of this place. Here, on the road. Not up there among those things.",
     "Sou Bento Arruda, capitão da milícia do vale. Falo com o senhor deste lugar. Aqui, na estrada. Não lá em cima entre aquelas coisas.",
     "Soy Bento Arruda, capitán de la milicia del valle. Hablaré con el amo de este lugar. Aquí, en el camino. No allí arriba entre esas cosas.")
line("u_parley", "ulrich", "He wants to talk, Meister. Walk down to him: the council's speaker will go with you. We will keep the machines back.",
     "Ele quer conversar, Mestre. Desça até ele: o porta-voz do conselho vai consigo. Nós mantemos as máquinas atrás.",
     "Quiere hablar, maestro. Baja hasta él: el portavoz del consejo irá contigo. Nosotros mantendremos las máquinas atrás.", GU)
line("a_parley1", "arruda", "My people say you raise the devil's own works up here. Clocks that walk. They say it was such things that ended the old world.",
     "O meu povo diz que você ergue aqui as obras do próprio diabo. Relógios que andam. Dizem que foram coisas assim que acabaram com o mundo antigo.",
     "Mi gente dice que levantas aquí las obras del mismo diablo. Relojes que andan. Dicen que fueron cosas así las que acabaron con el mundo antiguo.")
line("h_parley", "hollweg", "They are tools, Captain. I have ordered them never to raise a hand against a man of your valley. Not one.",
     "São ferramentas, Capitão. Ordenei-lhes que nunca levantem a mão contra um homem do seu vale. Nem um.",
     "Son herramientas, capitán. Les he ordenado que nunca levanten la mano contra un hombre de vuestro valle. Ni uno.")
line("v_parley", "varenne", "Captain, I have stood where you stand, at the head of frightened men. Go home. Nobody here wants your land.",
     "Capitão, já estive onde está, à frente de homens com medo. Vá para casa. Ninguém aqui quer a sua terra.",
     "Capitán, he estado donde estás, al frente de hombres asustados. Vuelve a casa. Nadie aquí quiere tu tierra.")
line("m_parley", "morel", "Your priests have told you to fear us. Ask yourself who profits by your fear, Captain.",
     "Os seus padres disseram-lhe para nos temer. Pergunte-se a quem aproveita o seu medo, Capitão.",
     "Vuestros curas os han dicho que nos temáis. Pregúntate a quién aprovecha tu miedo, capitán.")
line("a_parley2", "arruda", "I will take your word down the hill. I cannot promise they will believe it.",
     "Levo a sua palavra colina abaixo. Não posso prometer que acreditem nela.", "Llevaré tu palabra colina abajo. No puedo prometer que la crean.")
line("n_parley", "narrator", "The captain rides home without a blow struck.", "O capitão volta para casa sem um golpe desferido.", "El capitán vuelve a casa sin haber dado un golpe.")
line("a_nobody", "arruda", "Nobody comes down to talk. So be it.", "Ninguém desce para conversar. Que assim seja.", "Nadie baja a hablar. Así sea.")
line("u_raid", "ulrich", "Riders on the cart road, Meister, and muskets! The valley does not mean to talk.",
     "Cavaleiros na estrada dos carros, Mestre, e mosquetes! O vale não quer conversar.",
     "¡Jinetes en el camino de los carros, maestro, y mosquetes! El valle no quiere hablar.", GU)
line("u_raid_dark", "ulrich", "I hear horses on the dark roads, Meister, and I cannot see them. The Swifts!",
     "Ouço cavalos nas estradas escuras, Mestre, e não os vejo. Os Cucos!",
     "Oigo caballos en los caminos oscuros, maestro, y no los veo. ¡Los Cucos!", GU)
line("h_raid_over", "hollweg", "They have gone back down. Let them. Mend what they broke.",
     "Voltaram a descer. Deixem-nos. Consertem o que partiram.", "Han vuelto a bajar. Dejadlos. Arreglad lo que rompieron.", GU)
line("u_dusk", "ulrich", "The sun is going down over the valley, Meister. There are lights on the road. Many lights.",
     "O sol está a pôr-se sobre o vale, Mestre. Há luzes na estrada. Muitas luzes.",
     "El sol se pone sobre el valle, maestro. Hay luces en el camino. Muchas luces.", GU)
# ---- part 2: the valley's fear
line("n_fear", "narrator", "Night. The people of the valley come up the cart road with torches and scythes. No soldiers: farmers, drovers, their wives.",
     "Noite. O povo do vale sobe a estrada dos carros com tochas e foices. Nenhum soldado: lavradores, vaqueiros, as suas mulheres.",
     "Noche. La gente del valle sube por el camino de los carros con antorchas y guadañas. Ningún soldado: labradores, vaqueros, sus mujeres.")
line("h_fear", "hollweg", "Nobody strikes them. Do you hear me? Not one blow. I saw Rome burn. It will not start again here, and not by my machines.",
     "Ninguém lhes bate. Ouviram? Nem um golpe. Eu vi Roma arder. Não vai recomeçar aqui, e não pelas minhas máquinas.",
     "Nadie los golpea. ¿Me oís? Ni un golpe. Vi arder Roma. No volverá a empezar aquí, y no por mis máquinas.", GU)
line("u_fear", "ulrich", "Then we stand in their way, Meister. Put fighters round a man with a torch and he will think better of it. Shields up: they throw stones.",
     "Então ficamos no caminho deles, Mestre. Ponha combatentes à volta de um homem com uma tocha e ele vai pensar melhor. Escudos ao alto: eles atiram pedras.",
     "Entonces nos ponemos en su camino, maestro. Pon combatientes alrededor de un hombre con antorcha y lo pensará mejor. Escudos arriba: tiran piedras.", GU)
line("u_fire", "ulrich", "A house is burning! Anyone, to the fire: a man of ours beside it puts it out.",
     "Uma casa está a arder! Qualquer um, ao fogo: um dos nossos ao lado dela apaga-o.",
     "¡Una casa arde! Cualquiera, al fuego: uno de los nuestros a su lado lo apaga.", GU)
line("n_crowd2", "narrator", "More torches on the road.", "Mais tochas na estrada.", "Más antorchas en el camino.", GU)
line("n_crowd3", "narrator", "The last of them, and the angriest.", "Os últimos deles, e os mais zangados.", "Los últimos, y los más enfadados.", GU)
line("m_fear", "morel", "Let the machines teach them, Meister. One lesson tonight saves a hundred later.",
     "Deixe as máquinas ensiná-los, Mestre. Uma lição esta noite poupa cem depois.",
     "Deja que las máquinas les enseñen, maestro. Una lección esta noche ahorra cien después.", GU)
line("h_m_fear", "hollweg", "No, Citizen. I have seen the end of that lesson.", "Não, Cidadão. Já vi o fim dessa lição.", "No, ciudadano. Ya he visto el final de esa lección.", GU)
line("v_fear", "varenne", "Hold, Meister. Hold. A crowd that is not struck goes home in the end. A crowd that is struck never does.",
     "Aguente, Mestre. Aguente. Uma multidão em que não se bate acaba por ir para casa. Uma multidão em que se bate nunca vai.",
     "Resiste, maestro. Resiste. Una multitud a la que no se golpea acaba volviendo a casa. Una a la que se golpea, nunca.", GU)
line("u_temper", "ulrich", "The fires are seen from the valley, Meister. Every one makes them angrier.",
     "Os incêndios veem-se do vale, Mestre. Cada um deixa-os mais zangados.", "Los fuegos se ven desde el valle, maestro. Cada uno los enfada más.", GU)
line("n_anselmo", "narrator", "A priest comes up the road alone, in a black cassock, with a lantern.",
     "Um padre sobe a estrada sozinho, de batina preta, com uma lanterna.", "Un cura sube por el camino solo, con sotana negra y un farol.")
line("p_1", "anselmo", "Enough! Is this how a Christian keeps the Sabbath, with a torch in his hand on a stranger's hill?",
     "Basta! É assim que um cristão guarda o domingo, com uma tocha na mão no monte de um estranho?",
     "¡Basta! ¿Así guarda un cristiano el domingo, con una antorcha en la mano en el monte de un extraño?")
line("p_2", "anselmo", "Home, all of you. If these men are wrong, God and the Church will judge them, not your torches.",
     "Para casa, todos. Se estes homens estão errados, Deus e a Igreja os julgarão, não as vossas tochas.",
     "A casa, todos. Si estos hombres están equivocados, Dios y la Iglesia los juzgarán, no vuestras antorchas.")
line("n_home", "narrator", "The people of the valley lower their torches and go down the road behind their priest.",
     "O povo do vale baixa as tochas e desce a estrada atrás do seu padre.", "La gente del valle baja las antorchas y desciende por el camino tras su cura.")
line("h_anselmo", "hollweg", "He did with one word what all my shields could not do. I wrote that down. I did not understand it until much later.",
     "Ele fez com uma palavra o que todos os meus escudos não conseguiram. Escrevi isso. Só o compreendi muito mais tarde.",
     "Hizo con una palabra lo que todos mis escudos no pudieron. Lo escribí. No lo entendí hasta mucho después.")
line("n_boil", "narrator", "The valley sees the plateau burning. The bells ring in the town, and the militia saddles at once.",
     "O vale vê o planalto a arder. Os sinos tocam na vila, e a milícia sela os cavalos de imediato.",
     "El valle ve el altiplano ardiendo. Las campanas suenan en el pueblo, y la milicia ensilla enseguida.")
line("h_boil", "hollweg", "They are coming with muskets now. Into the tower's field, all of you. We hold.",
     "Agora vêm com mosquetes. Para o campo da torre, todos. Aguentamos.", "Ahora vienen con mosquetes. Al campo de la torre, todos. Resistimos.", GU)
line("n_house_lost", "narrator", "A house of the first quarter has burned down.", "Uma casa do primeiro bairro ardeu por completo.", "Una casa del primer barrio ha ardido entera.", GU)
# ---- part 3: the crates
line("n_dawn", "narrator", "Dawn over the highlands, grey and cold. The valley is quiet. Too quiet.",
     "Amanhecer sobre as terras altas, cinzento e frio. O vale está calmo. Calmo demais.",
     "Amanecer sobre las tierras altas, gris y frío. El valle está en calma. Demasiado.")
line("h_crates1", "hollweg", "The crates. Before anything else today, I want to see the crates. Ulrich, the lantern.",
     "Os caixotes. Antes de tudo hoje, quero ver os caixotes. Ulrich, a lanterna.", "Las cajas. Antes que nada hoy, quiero ver las cajas. Ulrich, el farol.", GU)
line("u_crates", "ulrich", "The deepest gallery is behind the spoil heaps, Meister, north-east. The seal will know your hand.",
     "A galeria mais funda fica atrás dos montes de entulho, Mestre, a nordeste. O selo vai reconhecer a sua mão.",
     "La galería más honda está tras los montones de escombro, maestro, al noreste. El sello reconocerá tu mano.", GU)
line("n_opened", "narrator", "The crates of 2767 are opened. Inside, the guild's best work of Nuremberg, packed in straw, perfect.",
     "Os caixotes de 2767 são abertos. Lá dentro, o melhor trabalho da guilda de Nuremberg, embalado em palha, perfeito.",
     "Las cajas de 2767 se abren. Dentro, el mejor trabajo del gremio de Núremberg, embalado en paja, perfecto.", GU)
line("h_opened", "hollweg", "Two soldiers of a pattern I do not remember drawing. A Winder. And plates, so many plates. My best work. It must have been.",
     "Dois soldados de um modelo que não me lembro de desenhar. Um Enrolador. E placas, tantas placas. O meu melhor trabalho. Devia ser.",
     "Dos soldados de un modelo que no recuerdo haber dibujado. Un Dador de cuerda. Y placas, tantas placas. Mi mejor trabajo. Debía de serlo.", GU)
line("u_plates", "ulrich", "The plates are lying across the gallery floor, Meister. I did not see anyone lay them.",
     "As placas estão estendidas pelo chão da galeria, Mestre. Não vi ninguém pô-las lá.",
     "Las placas están extendidas por el suelo de la galería, maestro. No vi a nadie ponerlas.", GU)
line("h_plates", "hollweg", "They slid out of the straw. Leave them. They wind whatever stands on them: a gift.",
     "Escorregaram da palha. Deixem-nas. Dão corda a tudo o que estiver em cima delas: um presente.",
     "Se escurrieron de la paja. Dejadlas. Dan cuerda a todo lo que esté encima: un regalo.", GU)
line("h_jakob", "hollweg", "Jakob would have counted the teeth on those plates. Jakob was in Fürth.",
     "Jakob teria contado os dentes daquelas placas. Jakob estava em Fürth.", "Jakob habría contado los dientes de esas placas. Jakob estaba en Fürth.", GU)
line("u_attack", "ulrich", "Meister! The militia, up all three roads at once! Riders on the ranch track!",
     "Mestre! A milícia, pelas três estradas ao mesmo tempo! Cavaleiros no trilho das fazendas!",
     "¡Maestro! ¡La milicia, por los tres caminos a la vez! ¡Jinetes en la senda de los ranchos!", GU)
line("a_attack", "arruda", "For the valley, and for God! Burn the tower!", "Pelo vale, e por Deus! Queimem a torre!", "¡Por el valle, y por Dios! ¡Quemad la torre!")
line("a_attack_p", "arruda", "I gave them your word, clockmaker. The night gave them theirs. Forgive me.",
     "Dei-lhes a sua palavra, relojoeiro. A noite deu-lhes a deles. Perdoe-me.", "Les di tu palabra, relojero. La noche les dio la suya. Perdóname.")
line("h_attack", "hollweg", "These are soldiers. Defend the city. Shields to the front, the Winders behind.",
     "Estes são soldados. Defendam a cidade. Escudos à frente, os Enroladores atrás.", "Estos son soldados. Defended la ciudad. Escudos al frente, los Dadores de cuerda detrás.", GU)
line("n_path", "narrator", "More of them out of the pines, by the north-west path.", "Mais deles saem dos pinheiros, pelo trilho do noroeste.", "Más salen de los pinos, por la senda del noroeste.", GU)
line("a_break", "arruda", "Back! Back down the hill! Enough have died for one morning.",
     "Para trás! Desçam a colina! Já morreram homens que chegue para uma manhã.", "¡Atrás! ¡Colina abajo! Ya han muerto bastantes por una mañana.")
line("n_break", "narrator", "The militia breaks and goes down the hill. The city stands.", "A milícia quebra e desce a colina. A cidade está de pé.",
     "La milicia se rompe y baja la colina. La ciudad sigue en pie.")
line("h_concord", "hollweg", "Concord.", "Concórdia.", "Concordia.", GU)
line("h_hurt", "hollweg", "I am hit. Keep them off the tower, never mind me.", "Fui atingido. Afastem-nos da torre, não se preocupem comigo.",
     "Me han dado. Apartadlos de la torre, no os preocupéis por mí.", GU)
line("n_tower_lost", "narrator", "The Clocktower has fallen. Without it the city is a camp of tents again.",
     "A Torre do Relógio caiu. Sem ela a cidade volta a ser um acampamento de tendas.", "La Torre del Reloj ha caído. Sin ella la ciudad vuelve a ser un campamento de tiendas.")
line("n_quarter_lost", "narrator", "Every house of the first quarter is ash. The families sleep in the tents, and some take the road to the coast.",
     "Todas as casas do primeiro bairro são cinza. As famílias dormem nas tendas, e algumas tomam a estrada para a costa.",
     "Todas las casas del primer barrio son ceniza. Las familias duermen en las tiendas, y algunas toman el camino de la costa.")
# ---- the valley's own (versus)
line("a_v1", "arruda", "There it is, on our hill: the thing the old world died of. Burn their houses before they take root, or bring the tower down.",
     "Ali está, no nosso monte: a coisa de que o mundo antigo morreu. Queimem as casas deles antes que criem raízes, ou derrubem a torre.",
     "Ahí está, en nuestro monte: la cosa de la que murió el mundo antiguo. Quemad sus casas antes de que echen raíces, o derribad la torre.", VA)
line("a_v_tip", "arruda", "The Barracks in the town and the Horse Breeder at the ranches are ours. The people will go up the road tonight whatever we do.",
     "O Quartel na vila e o Criador de Cavalos nas fazendas são nossos. O povo vai subir a estrada esta noite, façamos o que fizermos.",
     "El Cuartel del pueblo y el Criadero de Caballos de los ranchos son nuestros. La gente subirá el camino esta noche hagamos lo que hagamos.", VA)
# ---- the ending
line("h_end1", "hollweg", "By the first winter the city had a wall of timber, a council and a name. I sat at the head of the council table and called it concord.",
     "No primeiro inverno a cidade tinha um muro de madeira, um conselho e um nome. Sentei-me à cabeceira da mesa do conselho e chamei-lhe concórdia.",
     "Para el primer invierno la ciudad tenía un muro de madera, un consejo y un nombre. Me senté a la cabecera de la mesa del consejo y lo llamé concordia.")
line("h_end_parley", "hollweg", "The valley's captain had taken my word down the hill. That word was the best thing I built that year.",
     "O capitão do vale levara a minha palavra colina abaixo. Essa palavra foi a melhor coisa que construí naquele ano.",
     "El capitán del valle había llevado mi palabra colina abajo. Esa palabra fue lo mejor que construí aquel año.")
line("h_end_fought", "hollweg", "The valley never forgave us that dawn. Its people crossed themselves when our birds flew over.",
     "O vale nunca nos perdoou aquele amanhecer. O seu povo benzia-se quando os nossos pássaros passavam por cima.",
     "El valle nunca nos perdonó aquel amanecer. Su gente se santiguaba cuando nuestros pájaros pasaban por encima.")
line("h_end_v", "hollweg", "Varenne spoke for the city's people in the council. He was the only one of us who was afraid of it. I thought it was the habit of exile.",
     "Varenne falava pelo povo da cidade no conselho. Era o único de nós que tinha medo dela. Eu pensava que era o hábito do exílio.",
     "Varenne hablaba por la gente de la ciudad en el consejo. Era el único de nosotros que le tenía miedo. Yo creía que era la costumbre del destierro.")
line("h_end_m", "hollweg", "Morel spoke for the city's people in the council, and wanted the valley taught. I would not have it. That much I had learned in Rome.",
     "Morel falava pelo povo da cidade no conselho, e queria que o vale fosse ensinado. Eu não o permiti. Isso eu aprendera em Roma.",
     "Morel hablaba por la gente de la ciudad en el consejo, y quería que el valle aprendiera la lección. No lo permití. Eso lo había aprendido en Roma.")
line("h_end2", "hollweg", "I had learned to hold my machines back from the valley. I had not learned to hold them back from themselves.",
     "Aprendera a conter as minhas máquinas diante do vale. Não aprendera a contê-las diante de si mesmas.",
     "Había aprendido a contener mis máquinas ante el valle. No había aprendido a contenerlas ante sí mismas.")
line("k_end1", "king", "The plates in that gallery were not his best work. They were the Perpetual's. He had sent them ahead himself, six years before.",
     "As placas daquela galeria não eram o seu melhor trabalho. Eram do Perpétuo. Ele próprio as mandara à frente, seis anos antes.",
     "Las placas de aquella galería no eran su mejor trabajo. Eran del Perpetuo. Él mismo las había enviado por delante, seis años antes.")
line("k_end_people", "king", "He had left the pattern in Nuremberg. He had already sent it ahead.",
     "Ele deixara o padrão em Nuremberg. Já o tinha mandado à frente.", "Había dejado el patrón en Núremberg. Ya lo había enviado por delante.")
line("k_end2", "king", "A priest of the valley stopped a crowd that night with two sentences. Hollweg wrote it down. It took him twenty years to read it.",
     "Um padre do vale parou uma multidão naquela noite com duas frases. Hollweg escreveu-o. Levou vinte anos a lê-lo.",
     "Un cura del valle detuvo a una multitud aquella noche con dos frases. Hollweg lo escribió. Tardó veinte años en leerlo.")
line("k_end_v", "king", "The valley burned the city's first houses on its first night. That is not how it went. It stood, and grew.",
     "O vale queimou as primeiras casas da cidade na sua primeira noite. Não foi assim que aconteceu. Ela ficou de pé, e cresceu.",
     "El valle quemó las primeras casas de la ciudad en su primera noche. No fue así como ocurrió. Siguió en pie, y creció.")
line("a_end_v", "arruda", "We burned it before it took root. The bishop wrote to thank us. I did not sleep well, all the same.",
     "Queimámo-la antes que criasse raízes. O bispo escreveu a agradecer. Mesmo assim, não dormi bem.",
     "La quemamos antes de que echara raíces. El obispo escribió para agradecérnoslo. Aun así, no dormí bien.")

# ---- stills
M["stills"] = {
    "mine": {"image": STILL % "d04_01", "caption": T("The southern highlands, 2773. The old mine where the guild raises its tower.",
                                                     "As terras altas do sul, 2773. A velha mina onde a guilda ergue a sua torre.",
                                                     "Las tierras altas del sur, 2773. La vieja mina donde el gremio alza su torre.")},
    "fear": {"image": STILL % "d04_02", "caption": T("The valley's fear: the road at night.", "O medo do vale: a estrada de noite.", "El miedo del valle: el camino de noche.")},
    "crates": {"image": STILL % "d04_03", "caption": T("The crates of 2767.", "Os caixotes de 2767.", "Las cajas de 2767.")},
    "concord": {"image": STILL % "d04_04", "caption": T("Concórdia.", "Concórdia.", "Concórdia.")},
    "exile": {"image": STILL % "d04_05", "caption": T("A ship from Lisbon, and a man the King had spared.", "Um navio de Lisboa, e um homem que o Rei poupara.",
                                                      "Un barco de Lisboa, y un hombre al que el Rey había perdonado.")},
    "rome": {"image": STILL % "c01_01", "caption": T("Rome, the present. The King listens; the clockmaker tells it.", "Roma, o presente. O Rei ouve; o relojoeiro conta.",
                                                    "Roma, el presente. El Rey escucha; el relojero lo cuenta.")},
}
M["opening"] = {
    "guild": [{"still": "rome", "lines": ["k_open1", "k_open2"]}, {"still": "mine", "lines": ["h_open1", "h_open2"]},
              {"still": "exile", "lines": [{"id": "h_open_v", "if": SPARED}]},
              {"still": "mine", "lines": [{"id": "h_open_m", "if": EXECUTED}]}],
    "valley": [{"still": "rome", "lines": ["k_open1"]}, {"still": "fear", "lines": ["a_v1"]}],
}
M["ending"] = {
    "guild": [
        {"still": "concord", "lines": ["h_end1", {"id": "h_end_parley", "if": {"flag": {"colonists": "parley"}}},
                                       {"id": "h_end_fought", "if": {"flag": {"colonists": "fought"}}},
                                       {"id": "h_end_v", "if": SPARED}, {"id": "h_end_m", "if": EXECUTED}, "h_end2"]},
        {"still": "rome", "lines": ["k_end1", {"id": "k_end_people", "if": FROM_MEMORY}, "k_end2"]},
    ],
    "valley": [{"still": "fear", "lines": ["a_end_v"]}, {"still": "rome", "lines": ["k_end_v"]}],
}
M["briefing"] = {
    "guild": {"still": "mine", "text": [
        T("The southern highlands of Brazil, 2773. Meister Hollweg's guild has bought an old mine and means to build a city over it: Concórdia, governed by its own council.",
          "As terras altas do sul do Brasil, 2773. A guilda do Mestre Hollweg comprou uma velha mina e quer construir uma cidade sobre ela: Concórdia, governada pelo seu próprio conselho.",
          "Las tierras altas del sur de Brasil, 2773. El gremio del maestro Hollweg ha comprado una vieja mina y quiere construir una ciudad sobre ella: Concórdia, gobernada por su propio consejo."),
        T("Raise the Clocktower, build the CLOCK AVIARY and fly its Swifts over the three ways up: off the plateau the land is dark until a bird has seen it.",
          "Erga a Torre do Relógio, construa a CASA DO CUCO e voe os seus Cucos sobre os três caminhos: fora do planalto a terra é escura até um pássaro a ver.",
          "Alza la Torre del Reloj, construye la CASA DEL CUCO y vuela sus Cucos sobre los tres caminos: fuera del altiplano la tierra está oscura hasta que un pájaro la ve."),
        T("The valley below fears the machines. Its people will come at night: turn them back without a blow. Then open the crates of 2767, and hold the city at dawn.",
          "O vale lá em baixo teme as máquinas. O seu povo virá de noite: faça-o voltar sem um golpe. Depois abra os caixotes de 2767, e segure a cidade ao amanhecer.",
          "El valle de abajo teme a las máquinas. Su gente vendrá de noche: hazla volver sin un golpe. Luego abre las cajas de 2767, y resiste en la ciudad al amanecer.")]},
    "valley": {"still": "fear", "text": [
        T("The southern highlands, 2773. You lead the valley's militia under Captain Arruda. Strangers with walking machines have taken the old mine on the hill.",
          "As terras altas do sul, 2773. Você comanda a milícia do vale sob o Capitão Arruda. Estrangeiros com máquinas que andam tomaram a velha mina no monte.",
          "Las tierras altas del sur, 2773. Diriges la milicia del valle a las órdenes del capitán Arruda. Extranjeros con máquinas que andan han tomado la vieja mina del monte."),
        T("Burn their first houses, bring down their tower, or bring down their master, before the city takes root.",
          "Queime as suas primeiras casas, derrube a sua torre, ou derrube o seu mestre, antes que a cidade crie raízes.",
          "Quema sus primeras casas, derriba su torre, o derriba a su maestro, antes de que la ciudad eche raíces.")]},
}
M["debrief"] = {
    "guild": {"still": "concord", "title": T("Concórdia", "Concórdia", "Concórdia"),
              "text": T("The city stands. {houses} of {houses_n} houses of the first quarter stand; {turned_back} of the valley's people were turned back without a blow.",
                        "A cidade está de pé. {houses} de {houses_n} casas do primeiro bairro estão de pé; {turned_back} pessoas do vale foram mandadas de volta sem um golpe.",
                        "La ciudad sigue en pie. {houses} de {houses_n} casas del primer barrio siguen en pie; {turned_back} personas del valle fueron devueltas sin un golpe."),
              "text_if": [
                  {"if": {"flag": {"colonists": "parley"}}, "text": T("The valley's captain parleyed with Hollweg on the road.", "O capitão do vale conversou com Hollweg na estrada.",
                                                                      "El capitán del valle parlamentó con Hollweg en el camino.")},
                  {"if": {"flag": {"colonists": "fought"}}, "text": T("The valley fought the city from its first day.", "O vale lutou contra a cidade desde o primeiro dia.",
                                                                      "El valle luchó contra la ciudad desde el primer día.")},
                  {"if": {"flag": {"crates": "opened"}}, "text": T("The crates of 2767 were opened in the mine.", "Os caixotes de 2767 foram abertos na mina.",
                                                                   "Las cajas de 2767 se abrieron en la mina.")}]},
    "valley": {"still": "fear", "title": T("Burned before it took root", "Queimada antes de criar raízes", "Quemada antes de echar raíces"),
               "text": T("The valley's militia drove the guild's city off the hill.", "A milícia do vale expulsou a cidade da guilda do monte.",
                         "La milicia del valle echó del monte a la ciudad del gremio.")},
}


# ================================================================== the triggers
def militia(tag, kinds, at, cond=None, route=None, name=None, extra_tags=()):
    """Spawns for the valley's militia (scripted orders only when no person leads it: versus p2 takes them as his own)."""
    out = []
    for (k, role, n) in kinds:
        sp = {"team": "militia", "kind": k, "count": n, "at": at, "tag": tag, "tags": ["militia_men"] + list(extra_tags)}
        if role:
            sp["as"] = role
        if cond:
            sp["if"] = cond
        out.append({"spawn": sp})
    if route:
        out.append({"order": {"tag": tag, "do": "route", "route": route, "attack": True, "name": name or tag}})
    return out


TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"spare": {"tag": "settlers", "on": True}}, {"spare": {"tag": "voice", "on": True}}, {"spare": {"tag": "townsfolk", "on": True}},
        {"spare": {"tag": "church", "on": True}}, {"spare": {"tag": "town_b", "on": True}}, {"spare": {"tag": "valley_b", "on": True}},
        {"counter": {"name": "houses", "count": {"tag": "houses"}}}, {"counter": {"name": "houses_n", "count": {"tag": "houses"}}},
        {"build": {"team": "guild", "kind": "clocktower", "at": TOWER, "tag": "tower", "tags": ["city"], "site": True,
                   "name": T("Concórdia's tower", "A torre de Concórdia", "La torre de Concórdia")}},
        {"give": {"team": "guild", "tension": TENSION}}, {"wind": {"tag": "army", "share": 1.0}},
        {"max_hp": {"tag": "houses", "hp": HOUSE_HP}},
        # THE FOG OF THE UNMAPPED: off the plateau the land is dark to the guild until a Swift flies over it
        {"chart": {"side": "guild", "team": "guild", "known": ["plateau", "road_top"]}},
        {"objective": {"id": "tower", "set": "active"}}, {"ping": {"tag": "tower"}}]},
    {"id": "setup_tempers", "when": {"time": 0.6}, "do": [{"counter": {"name": "temper_top", "set": TEMPER_TOP["normal"]}}]},
    {"id": "setup_easy", "when": {"all": [{"time": 0.6}, {"difficulty": "easy"}]}, "do": [{"counter": {"name": "temper_top", "set": TEMPER_TOP["easy"]}}]},
    {"id": "setup_hard", "when": {"all": [{"time": 0.6}, {"difficulty": "hard"}]}, "do": [{"counter": {"name": "temper_top", "set": TEMPER_TOP["hard"]}}]},
    {"id": "voice_name_m", "when": {"all": [{"time": 0.5}, EXECUTED]}, "do": [{"name": {"tag": "voice", "name": T("Citizen Morel", "Cidadão Morel", "Ciudadano Morel")}}]},
    # with c01 `gate` people (or the drawings taken in d02): Hollweg builds from memory: no Heavy Works until the night
    {"id": "memory", "when": {"all": [{"time": 0.5}, FROM_MEMORY]}, "do": [
        {"deny": {"team": "guild", "kind": ["heavy_works", "pendulum"],
                  "why": T("Hollweg is drawing the Heavy Works again from memory: not yet.", "Hollweg está a desenhar outra vez a Oficina Pesada de memória: ainda não.",
                           "Hollweg está dibujando otra vez el Taller Pesado de memoria: todavía no.")}}]},
    {"id": "memory_say", "when": {"all": [{"time": 40}, FROM_MEMORY]}, "do": [{"say": ["h_memory"]}]},
    {"id": "intro", "when": {"time": 1.5}, "do": [{"say": ["h_1", "u_tip1"]}]},
    {"id": "intro_dark", "when": {"fired": "intro"}, "delay": 14, "do": [{"say": ["u_dark"]}]},
    {"id": "intro_v", "when": {"all": [{"fired": "intro"}, SPARED]}, "delay": 26, "do": [{"say": ["v_1", "h_v1", "v_2"]}]},
    {"id": "intro_m", "when": {"all": [{"fired": "intro"}, EXECUTED]}, "delay": 26, "do": [{"say": ["m_1", "h_m1"]}]},
    {"id": "intro_valley", "when": {"all": [{"time": 1.5}, VAL]}, "do": [{"say": ["a_v1", "a_v_tip"]}, {"objective": {"id": "v_burn", "set": "active"}},
                                                                       {"objective": {"id": "v_tower", "set": "active"}}]},
    # ============================================================ PART 1: THE FOUNDING
    {"id": "tower_built", "when": {"all": [{"done": "tower"}, LIVE]}, "do": [
        {"say": ["h_tower", "u_field", "u_spring"]},
        {"build": {"team": "guild", "kind": "mainspring", "at": SPRING_AT, "tag": "spring", "tags": ["city"], "site": True}},
        {"objective": {"id": "spring", "set": "active"}}, {"ping": {"tag": "spring"}},
        {"build": {"team": "guild", "kind": "cog_press", "at": PRESS_AT, "tag": "press", "tags": ["city"], "site": True}},
        {"objective": {"id": "press", "set": "active"}},
        {"objective": {"id": "city_tower", "set": "active"}},
        {"clock": {"name": "captain", "secs": CAPTAIN_SECS}}, {"objective": {"id": "captain_clock", "set": "active"}}]},
    {"id": "spring_built", "when": {"all": [{"done": "spring"}, LIVE]}, "do": [
        {"say": ["u_aviary"]},
        {"build": {"team": "guild", "kind": "cuckoo_house", "at": AVIARY_AT, "tag": "aviary", "tags": ["city"], "site": True}},
        {"objective": {"id": "aviary", "set": "active"}}, {"ping": {"tag": "aviary"}}]},
    {"id": "aviary_built", "when": {"all": [{"done": "aviary"}, LIVE]}, "do": [
        {"say": ["u_swifts"]}, {"objective": {"id": "swifts", "set": "active"}}]},
    {"id": "swifts_n", "when": {"all": [{"fired": "aviary_built"}, LIVE]}, "every": 1, "do": [
        {"counter": {"name": "swifts", "count": {"team": "guild", "kind": "cuckoo"}}}]},
    {"id": "swifts_done", "when": {"all": [{"counter": {"name": "swifts", "at_least": 2}}]}, "do": [
        {"objective": {"id": "swifts", "set": "done"}}, {"objective": {"id": "map", "set": "active"}}, {"say": ["h_map"]},
        {"ping": {"area": "way_road"}}, {"ping": {"area": "way_path"}}, {"ping": {"area": "way_track"}}]},
    # (the ways can be mapped as soon as anything flies: the objective counts them whenever)
    {"id": "map_road", "when": {"charted": {"area": "way_road", "at_least": 0.5}}, "do": [{"counter": {"name": "mapped", "add": 1}}, {"say": ["n_mapped"]}]},
    {"id": "map_path", "when": {"charted": {"area": "way_path", "at_least": 0.5}}, "do": [{"counter": {"name": "mapped", "add": 1}}, {"say": ["n_mapped"]}]},
    {"id": "map_track", "when": {"charted": {"area": "way_track", "at_least": 0.5}}, "do": [{"counter": {"name": "mapped", "add": 1}}, {"say": ["n_mapped"]}]},
    {"id": "map_all", "when": {"counter": {"name": "mapped", "at_least": 3}}, "do": [
        {"objective": {"id": "map", "set": "done"}}, {"say": ["h_mapped_all"]}]},
    {"id": "captain_soon", "when": {"all": [{"fired": "map_all"}, {"fired": "tower_built"}, {"not": {"fired": "captain"}},
                                           {"not": {"clock_left": {"name": "captain", "below": CAPTAIN_MAPPED}}}]}, "do": [
        {"clock": {"name": "captain", "secs": CAPTAIN_MAPPED}}]},
    {"id": "crates_hint", "when": {"fired": "spring_built"}, "delay": 22, "do": [{"say": ["h_crates_seen"]}]},
    {"id": "presses_tip", "when": {"fired": "spring_built"}, "delay": 8, "do": [{"say": ["u_presses"]}]},
    # the valley's captain comes up the road
    {"id": "captain", "when": {"all": [{"clock_out": "captain"}, LIVE]}, "do": [{"objective": {"id": "captain_clock", "set": "hidden"}}]},
    # ---- a04 `broken` melted: he waits on the road to PARLEY (solo, a person leading the guild)
    {"id": "parley_go", "when": {"all": [{"fired": "captain"}, MELTED, NO_VAL]}, "do":
        militia("arruda", [("cuirassier", "arruda", 1)], "road_top")
        + militia("escort", [("cuirassier", "rancher", 2)], "road_top")
        + [{"order": {"tag": "arruda", "do": "hold"}}, {"order": {"tag": "escort", "do": "hold"}},
           {"spare": {"tag": "arruda", "on": True}}, {"spare": {"tag": "escort", "on": True}},
           {"say": ["u_captain", "a_wait", "u_parley"]}, {"objective": {"id": "parley", "set": "active"}}, {"ping": {"area": "parley"}},
           {"order": {"tag": "voice", "do": "follow", "leader": "hollweg", "within": 2}},
           {"clock": {"name": "parley", "secs": PARLEY_WAIT}}]},
    {"id": "parley", "when": {"all": [{"fired": "parley_go"}, {"stay": {"tag": "hollweg", "area": "parley", "secs": PARLEY_SECS}},
                                      {"stay": {"tag": "voice", "area": "parley", "secs": PARLEY_SECS}}, {"not": {"fired": "parley_fail"}}, LIVE]}, "do": [
        {"say": ["a_parley1", "h_parley"]}, {"objective": {"id": "parley", "set": "done"}}, {"clock": {"name": "parley", "stop": True}}]},
    {"id": "parley_v", "when": {"all": [{"fired": "parley"}, SPARED]}, "do": [{"say": ["v_parley", "a_parley2", "n_parley"]}]},
    {"id": "parley_m", "when": {"all": [{"fired": "parley"}, EXECUTED]}, "do": [{"say": ["m_parley", "a_parley2", "n_parley"]}]},
    {"id": "parley_home", "when": {"fired": "parley"}, "delay": 4, "do": [
        {"order": {"tag": "voice", "do": "move", "to": "tower_area"}},
        {"order": {"tag": "arruda", "do": "move", "to": "home_exit"}}, {"order": {"tag": "escort", "do": "move", "to": "home_exit"}}]},
    {"id": "parley_gone", "when": {"fired": "parley_home"}, "delay": 25, "do": [{"remove": {"tag": "arruda"}}, {"remove": {"tag": "escort"}}]},
    {"id": "parley_fail", "when": {"all": [{"fired": "parley_go"}, {"clock_out": "parley"}, {"not": {"fired": "parley"}}, LIVE]}, "do": [
        {"say": ["a_nobody"]}, {"objective": {"id": "parley", "set": "failed"}}, {"order": {"tag": "voice", "do": "move", "to": "tower_area"}},
        {"spare": {"tag": "arruda", "on": False}}, {"spare": {"tag": "escort", "on": False}},
        {"order": {"tag": "arruda", "do": "route", "route": ROAD[3:] + ["tower_area"], "attack": True, "name": "arruda_raid"}},
        {"order": {"tag": "escort", "do": "route", "route": ROAD[3:] + ["tower_area"], "attack": True, "name": "escort_raid"}}]},
    # ---- a04 `broken` kept (the canon), or the parley missed: THE FIRST RAID (up the road, riders by the pine path)
    {"id": "raid", "when": {"all": [{"any": [{"all": [{"fired": "captain"}, KEPT]}, {"fired": "parley_fail"}]}, NO_VAL, LIVE]}, "do":
        militia("raid", [("musketeer", "valley_militia", 3), ("cuirassier", "rancher", 2)], "road_low", route=ROAD[:4] + ["west_field", "tower_area"], name="raid_road")
        + militia("raid", [("cuirassier", "rancher", 2)], "path_w", route=PATH, name="raid_path")
        + [{"objective": {"id": "raid", "set": "active"}}, {"objective": {"id": "parley", "set": "hidden"}}]},
    {"id": "raid_say", "when": {"all": [{"fired": "raid"}, {"charted": {"area": "way_road", "at_least": 0.5}}]}, "delay": 2, "do": [{"say": ["u_raid"]}, {"ping": {"area": "road_mid"}}]},
    {"id": "raid_say_dark", "when": {"all": [{"fired": "raid"}, {"not": {"charted": {"area": "way_road", "at_least": 0.5}}}]}, "delay": 2, "do": [{"say": ["u_raid_dark"]}]},
    {"id": "raid_left_n", "when": {"all": [{"fired": "raid"}, LIVE]}, "every": 1, "do": [{"counter": {"name": "raid_left", "count": {"tag": "raid"}}}]},
    {"id": "raid_over", "when": {"all": [{"fired": "raid"}, {"time": 1}, {"count": {"tag": "raid", "below": 1}}, {"count": {"tag": "arruda", "below": 1}}, LIVE]}, "delay": 2, "do": [
        {"objective": {"id": "raid", "set": "done"}}, {"say": ["h_raid_over"]}]},
    # Part 1 over: the raid beaten or the parley done (or nothing at all for a long while: the night falls anyway)
    {"id": "part1_over", "when": {"all": [{"any": [{"fired": "raid_over"}, {"fired": "parley_gone"}, {"all": [{"fired": "captain"}, VAL]}]}, LIVE]}, "do": []},
    {"id": "part1_late", "when": {"all": [{"fired": "captain"}, LIVE]}, "delay": 200, "do": []},
    {"id": "dusk", "when": {"all": [{"any": [{"fired": "part1_over"}, {"fired": "part1_late"}]}, LIVE]}, "delay": NIGHT_GAP, "do": [
        {"light": {"to": "dusk", "secs": 12}}, {"say": ["u_dusk"]}, {"objective": {"id": "spring", "set": "hidden"}}, {"objective": {"id": "press", "set": "hidden"}},
        {"objective": {"id": "aviary", "set": "hidden"}}, {"objective": {"id": "swifts", "set": "hidden"}}, {"objective": {"id": "map", "set": "hidden"}},
        {"objective": {"id": "raid", "set": "hidden"}}]},
    # ============================================================ PART 2: THE VALLEY'S FEAR
    {"id": "part2", "when": {"fired": "dusk"}, "delay": 12, "do": [
        {"light": {"to": "night", "secs": 15}}, {"say": ["n_fear"]},
        {"objective": {"id": "fear", "set": "active"}}, {"objective": {"id": "temper", "set": "active"}},
        {"unlock": {"team": "guild", "kind": ["heavy_works", "pendulum"]}}]},
    {"id": "part2_say", "when": {"fired": "part2"}, "delay": 3, "do": [{"say": ["h_fear", "u_fear"]}]},
    {"id": "part2_v", "when": {"all": [{"fired": "part2"}, SPARED]}, "delay": 30, "do": [{"say": ["v_fear"]}]},
    {"id": "part2_m", "when": {"all": [{"fired": "part2"}, EXECUTED]}, "delay": 30, "do": [{"say": ["m_fear", "h_m_fear"]}]},
    {"id": "memory_done", "when": {"all": [{"fired": "part2"}, FROM_MEMORY]}, "do": [
        {"build": {"team": "guild", "kind": "heavy_works", "at": HEAVY_WORKS, "tag": "heavy", "tags": ["city"], "site": True}}]},
    # (the guild's turned-back people walk home; at the town they are gone)
    {"id": "turned_go", "when": {"all": [{"fired": "part2"}, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "turned", "only_team": "calmed", "do": "move", "to": "home_exit"}}]},
]
# three crowds up the road, MOB_EVERY s apart (a04 `broken` kept: one more in each: the canon)
for i, n in enumerate(MOB):
    TR_ += [{"id": "mob_%d" % (i + 1), "when": {"all": [{"fired": "part2"}, {"not": {"fired": "boil"}}, {"time": 1}] if i else {"fired": "part2"}},
             "delay": 8 + i * MOB_EVERY, "do": [
        {"spawn": {"team": "town", "kind": "labourer", "as": "colonist_torch", "count": n, "at": "road_low", "tag": "mob"}},
        {"spawn": {"team": "town", "kind": "labourer", "as": "colonist_torch", "count": 1, "at": "road_low", "tag": "mob", "if": KEPT}},
        {"spare": {"tag": "mob", "on": True}},
        {"order": {"tag": "mob", "only_team": "town", "do": "route", "route": ROAD[1:], "name": "mob_road_%d" % (i + 1)}},
        {"ping": {"area": "road_mid"}}] + ([{"say": ["n_crowd2" if i == 1 else "n_crowd3"]}] if i > 0 else [])}]
TR_ += [
    # fires (torch_fire counts them into the temper); a burnt house twice
    {"id": "fire_say", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "temper", "at_least": 1}}]}, "do": [{"say": ["u_fire"]}]},
    {"id": "temper_say", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "temper", "at_least": 3}}]}, "do": [{"say": ["u_temper"]}]},
] + [
    {"id": "house_lost_%d" % (i + 1), "when": {"all": [{"time": 2}, {"dead": "house_%d" % (i + 1)}] + ([HOUSE_IF[i]] if HOUSE_IF[i] else [])}, "do": [
        {"say": ["n_house_lost"]}]} for i in range(len(HOUSES))
] + [
    # (THE VALLEY'S TEMPER is the night's: a house burnt at night counts twice)
    {"id": "house_temper_%d" % (i + 1), "when": {"all": [{"fired": "house_lost_%d" % (i + 1)}, {"fired": "part2"}, {"not": {"fired": "part3"}}]}, "do": [
        {"counter": {"name": "temper", "add": 2}}]} for i in range(len(HOUSES))
] + [
    {"id": "houses_n", "when": {"time": 2}, "every": 1, "do": [{"counter": {"name": "houses", "count": {"tag": "houses"}}}]},
    # PADRE ANSELMO comes up the road and calls his people home
    {"id": "anselmo", "when": {"fired": "mob_3"}, "delay": ANSELMO_AFTER, "do": [
        {"spawn": {"team": "town", "kind": "missionary", "as": "anselmo", "count": 1, "at": "road_low", "tag": "anselmo"}},
        {"spare": {"tag": "anselmo", "on": True}}, {"say": ["n_anselmo"]}, {"ping": {"area": "road_low"}},
        {"order": {"tag": "anselmo", "do": "route", "route": ["road_mid", "road_top"], "name": "anselmo_up"}}]},
    {"id": "anselmo_calls", "when": {"all": [{"fired": "anselmo"}, {"any": [{"route_done": "anselmo_up"}, {"fired": "anselmo_late"}]}]}, "delay": 1, "do": [
        {"say": ["p_1", "p_2", "n_home"]},
        {"convert": {"tag": "mob", "to": "calmed", "as": "gone_home", "warn": 1, "untorch": True}},
        {"order": {"tag": "anselmo", "do": "move", "to": "home_exit"}}]},
    {"id": "anselmo_late", "when": {"fired": "anselmo"}, "delay": 40, "do": []},
    {"id": "anselmo_hollweg", "when": {"fired": "anselmo_calls"}, "delay": 6, "do": [{"say": ["h_anselmo"]}]},
    {"id": "gone_home_go", "when": {"all": [{"fired": "anselmo_calls"}, LIVE]}, "delay": 1.5, "every": 3, "do": [
        {"order": {"tag": "gone_home", "only_team": "calmed", "do": "move", "to": "home_exit"}}, {"order": {"tag": "anselmo", "do": "move", "to": "home_exit"}}]},
    {"id": "anselmo_gone", "when": {"fired": "anselmo_calls"}, "delay": 30, "do": [{"remove": {"tag": "anselmo"}}]},
    # THE VALLEY'S TEMPER at its top: the militia rides at once (Part 3 early, harder)
    {"id": "boil", "when": {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}, {"any": [{"all": [{"difficulty": d}, {"counter": {"name": "temper", "at_least": TEMPER_TOP[d]}}]} for d in ("easy", "normal", "hard")]}, LIVE]}, "do": [
        {"say": ["n_boil", "h_boil"]}, {"flag": {"colonists": "fought"}}]},
    {"id": "boil_home", "when": {"all": [{"fired": "boil"}, {"not": {"fired": "anselmo_calls"}}]}, "do": [
        {"convert": {"tag": "mob", "to": "calmed", "as": "gone_home", "warn": 1, "untorch": True}}]},
    # Part 2 over: the people gone home (Anselmo's word, or the bells: the militia comes)
    {"id": "part2_over", "when": {"all": [{"any": [{"fired": "anselmo_calls"}, {"fired": "boil"}]}, LIVE]}, "delay": 18, "do": []},
    {"id": "part2_boil", "when": {"fired": "boil"}, "delay": 3, "do": []},
    # ============================================================ PART 3: THE CRATES
    {"id": "part3", "when": {"all": [{"any": [{"fired": "part2_over"}, {"fired": "part2_boil"}]}, LIVE]}, "do": [
        {"light": {"to": "dawn", "secs": 20}}, {"objective": {"id": "fear", "set": "done"}}, {"objective": {"id": "temper", "set": "hidden"}},
        {"objective": {"id": "crates", "set": "active"}}, {"ping": {"area": "gallery"}}]},
    {"id": "part3_say", "when": {"all": [{"fired": "part3"}, {"not": {"fired": "boil"}}]}, "do": [{"say": ["n_dawn", "h_crates1", "u_crates"]}]},
    {"id": "part3_say_b", "when": {"all": [{"fired": "part3"}, {"fired": "boil"}]}, "do": [{"say": ["h_crates1", "u_crates"]}]},
    {"id": "crates_open", "when": {"all": [{"fired": "part3"}, {"stay": {"tag": "hollweg", "area": "gallery", "secs": CRATE_SECS}}, LIVE]}, "do": [
        {"spawn": {"team": "guild", "kind": "clock_soldier", "as": "crate_soldier", "count": 2, "at": "gallery", "tag": "army", "tags": ["crate_men"]}},
        {"spawn": {"team": "guild", "kind": "winder", "count": 1, "at": "gallery", "tag": "army", "tags": ["crate_men"]}},
        {"show": {"pages": [{"still": "crates", "lines": ["n_opened", "h_opened"]}]}},
        {"flag": {"crates": "opened"}}, {"objective": {"id": "crates", "set": "done"}}]},
    # the plates creep across the floor by themselves (faster from the pattern: the seed fits it at once)
    {"id": "plates", "when": {"all": [{"fired": "crates_open"}, PATTERN]}, "do": [
        {"ground": {"name": "plates", "at": "gallery", "kind": "gear", "team": "guild", "r": 2, "step": 1, "every": 8, "max": 12, "wind": 0.05}}]},
    {"id": "plates_slow", "when": {"all": [{"fired": "crates_open"}, FROM_MEMORY]}, "do": [
        {"ground": {"name": "plates", "at": "gallery", "kind": "gear", "team": "guild", "r": 2, "step": 1, "every": 14, "max": 9, "wind": 0.05}}]},
    {"id": "plates_say", "when": {"fired": "crates_open"}, "delay": 14, "do": [{"say": ["u_plates", "h_plates"]}]},
    {"id": "jakob_say", "when": {"fired": "plates_say"}, "delay": 10, "do": [{"say": ["h_jakob"]}]},
    # THE DAWN ATTACK, up all three ways (bigger with the temper boiled; with the parley, half the valley stayed home)
    {"id": "attack_time", "when": {"fired": "part3"}, "delay": ATTACK_AFTER, "do": []},
    {"id": "attack_soon", "when": {"fired": "crates_open"}, "delay": 12, "do": []},
    {"id": "attack", "when": {"all": [{"any": [{"fired": "attack_time"}, {"fired": "attack_soon"}, {"fired": "boil"}]}, {"fired": "part3"}, LIVE]}, "delay": 2, "do":
        militia("attack", [("cuirassier", "arruda", 1)], "road_low", extra_tags=["arruda", "road_men"])
        + militia("attack", [("musketeer", "valley_militia", 4), ("cuirassier", "rancher", 1)], "road_low", cond={"not": {"fired": "parley"}}, extra_tags=["road_men"])
        + militia("attack", [("musketeer", "valley_militia", 3), ("cuirassier", "rancher", 1)], "road_low", cond={"fired": "parley"}, extra_tags=["road_men"])
        + militia("attack", [("musketeer", "valley_militia", 2)], "road_low", cond={"fired": "boil"}, extra_tags=["road_men"])
        + militia("attack", [("cuirassier", "rancher", 3)], "track_low", cond={"not": {"fired": "parley"}}, extra_tags=["track_men"])
        + militia("attack", [("cuirassier", "rancher", 2)], "track_low", cond={"fired": "parley"}, extra_tags=["track_men"])
        + militia("attack", [("cuirassier", "rancher", 1)], "track_low", cond={"fired": "boil"}, extra_tags=["track_men"])
        + [{"objective": {"id": "attack", "set": "active"}}, {"clock": {"name": "dawn", "secs": DAWN_SECS}}, {"ping": {"area": "road_mid"}}, {"ping": {"area": "track_low"}}]},
    {"id": "attack_go", "when": {"all": [{"fired": "attack"}, NO_VAL]}, "do": [
        {"order": {"tag": "track_men", "do": "route", "route": TRACK, "attack": True, "name": "attack_track"}},
        {"order": {"tag": "road_men", "do": "route", "route": ROAD[1:] + ["tower_area"], "attack": True, "name": "attack_road"}}]},
    {"id": "attack_say", "when": {"fired": "attack"}, "do": [{"say": ["u_attack", "a_attack", "h_attack"]}]},
    {"id": "attack_say_p", "when": {"all": [{"fired": "attack"}, {"fired": "parley"}]}, "delay": 4, "do": [{"say": ["a_attack_p"]}]},
    {"id": "attack_path", "when": {"all": [{"fired": "attack"}, {"not": {"fired": "parley"}}, LIVE]}, "delay": 20, "do":
        militia("attack", [("musketeer", "valley_militia", 2), ("cuirassier", "rancher", 1)], "path_w", extra_tags=["path_men"])
        + [{"say": ["n_path"]}]},
    {"id": "attack_path_go", "when": {"all": [{"fired": "attack_path"}, NO_VAL]}, "do": [
        {"order": {"tag": "path_men", "do": "route", "route": PATH, "attack": True, "name": "attack_path"}}]},
    {"id": "attack_n", "when": {"all": [{"fired": "attack"}, LIVE]}, "every": 1, "do": [{"counter": {"name": "attack_left", "count": {"tag": "attack"}}}]},
    # (the scripted militia never stands about: every so often whatever is left of it goes for the tower)
    {"id": "assault", "when": {"all": [{"fired": "attack"}, NO_VAL, LIVE]}, "delay": 45, "every": 15, "do": [
        {"order": {"tag": "attack", "do": "attack", "to": "tower_area", "idle": True}}]},
    {"id": "attack_spent", "when": {"all": [{"fired": "attack"}, {"any": [{"fired": "attack_path"}, {"fired": "parley"}, {"fired": "boil"}]}]}, "delay": 3, "do": []},
    {"id": "break", "when": {"all": [{"fired": "attack_spent"}, {"any": [{"counter": {"name": "attack_left", "below": BREAK_AT}}, {"clock_out": "dawn"}]}, LIVE]}, "do": [
        {"say": ["a_break", "n_break"]}, {"objective": {"id": "attack", "set": "done"}},
        {"order": {"tag": "attack", "do": "move", "to": "home_exit"}}, {"clock": {"name": "dawn", "stop": True}}]},
    # ============================================================ THE ENDS
    {"id": "won", "when": {"all": [{"fired": "break"}, {"done": "crates"}, LIVE]}, "delay": 3, "do": [
        {"say": ["h_concord"]}, {"light": {"to": "day", "secs": 6}}, {"flag": {"crates": "opened"}}]},
    {"id": "flags_parley", "when": {"all": [{"fired": "won"}, {"fired": "parley"}, {"not": {"fired": "boil"}}]}, "do": [{"flag": {"colonists": "parley"}}]},
    {"id": "flags_fought", "when": {"all": [{"fired": "won"}, {"any": [{"not": {"fired": "parley"}}, {"fired": "boil"}]}]}, "do": [{"flag": {"colonists": "fought"}}]},
    {"id": "the_end", "when": {"fired": "won"}, "delay": 4, "do": [{"win": "guild"}]},
    # the city lost: the Clocktower down (once it stood), every house of the first quarter burnt, or (versus) Hollweg
    {"id": "tower_lost", "when": {"all": [{"fired": "tower_built"}, {"count": {"tag": "tower", "below": 1}}, LIVE]}, "do": [
        {"say": ["n_tower_lost"]}, {"objective": {"id": "city_tower", "set": "failed"}}]},
    {"id": "quarter_lost", "when": {"all": [{"time": 3}, {"count": {"tag": "houses", "below": 1}}, LIVE]}, "do": [
        {"say": ["n_quarter_lost"]}, {"objective": {"id": "quarter", "set": "failed"}}]},
    {"id": "lost_flags", "when": {"any": [{"fired": "tower_lost"}, {"fired": "quarter_lost"}]}, "do": [{"flag": {"colonists": "fought"}}]},
    {"id": "v_won", "when": {"all": [VAL, {"any": [{"fired": "tower_lost"}, {"fired": "quarter_lost"}, {"dead": "hollweg"}]}, LIVE]}, "delay": 3, "do": []},
    {"id": "v_end", "when": {"fired": "v_won"}, "delay": 1, "do": [{"win": "valley"}]},
    {"id": "lost_end", "when": {"all": [NO_VAL, {"any": [{"fired": "tower_lost"}, {"fired": "quarter_lost"}]}]}, "delay": 4, "do": [{"lose": "guild"}]},
    # ============================================================ HURTS
    {"id": "hollweg_hurt", "when": {"hp": {"tag": "hollweg", "below": 0.6}}, "every": 60, "times": 2, "do": [{"say": ["h_hurt"]}, {"ping": {"tag": "hollweg"}}]},
]
# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the guild is bound to K5, the Clock Aviary and the Swift
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID)
for k in ("cuckoo_house", "cuckoo"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hub after d04 (campaign/campaign.json, campaign/hubs_grow.json), the war
# map (campaign/warmap.json: its d04 rules were written by act2-warmap), the engine's words
for (en, pt, es) in [
    ("Varenne", "Varenne", "Varenne"),
    ("A settler of the guild: one of the families who came from Fürth.", "Um colono da guilda: uma das famílias que vieram de Fürth.",
     "Un colono del gremio: una de las familias que vinieron de Fürth."),
    ("The Free Assembly's orator, spared at Paris and sent into exile: he came to Concórdia on a ship from Lisbon.",
     "O orador da Assembleia Livre, poupado em Paris e mandado para o exílio: veio para Concórdia num navio de Lisboa.",
     "El orador de la Asamblea Libre, perdonado en París y desterrado: llegó a Concórdia en un barco de Lisboa."),
    ("A man of the Free Assembly who came to Concórdia after Varenne's death: he wants the valley taught.",
     "Um homem da Assembleia Livre que veio para Concórdia depois da morte de Varenne: quer que o vale seja ensinado.",
     "Un hombre de la Asamblea Libre que llegó a Concórdia tras la muerte de Varenne: quiere que el valle aprenda la lección."),
    ("Captain of the valley's militia, a cattleman of the highlands.", "Capitão da milícia do vale, um criador de gado das terras altas.",
     "Capitán de la milicia del valle, un ganadero de las tierras altas."),
    ("A militiaman of the valley: a farmer with his musket.", "Um miliciano do vale: um lavrador com o seu mosquete.", "Un miliciano del valle: un labrador con su mosquete."),
    ("A rancher of the valley on his working horse.", "Um fazendeiro do vale no seu cavalo de trabalho.", "Un ranchero del valle en su caballo de faena."),
    ("A colonist of the valley: a farmer or a drover of the highlands.", "Um colono do vale: um lavrador ou um vaqueiro das terras altas.",
     "Un colono del valle: un labrador o un vaquero de las tierras altas."),
    ("A colonist of the valley with a torch and a fear of machines.", "Um colono do vale com uma tocha e medo das máquinas.",
     "Un colono del valle con una antorcha y miedo a las máquinas."),
    ("The valley's parish priest.", "O pároco do vale.", "El párroco del valle."),
    ("A Clock Soldier from the crates of 2767, of a pattern nobody remembers building.", "Um Soldado-Relógio dos caixotes de 2767, de um modelo que ninguém se lembra de ter construído.",
     "Un Soldado Reloj de las cajas de 2767, de un modelo que nadie recuerda haber construido."),
    ("Pattern of 2767", "Modelo de 2767", "Modelo de 2767"),
    ("Captain Arruda", "Capitão Arruda", "Capitán Arruda"),
    ("Padre Anselmo", "Padre Anselmo", "Padre Anselmo"),
    ("Etienne Varenne", "Etienne Varenne", "Etienne Varenne"),
    # the hub after d04
    ("Concórdia's Council Hall", "A Sala do Conselho de Concórdia", "La Sala del Consejo de Concórdia"),
    ("The guild's free city on the southern highlands of Brazil. Hollweg sits at the head of its council.",
     "A cidade livre da guilda nas terras altas do sul do Brasil. Hollweg senta-se à cabeceira do seu conselho.",
     "La ciudad libre del gremio en las tierras altas del sur de Brasil. Hollweg se sienta a la cabecera de su consejo."),
    ("Concórdia's council hall: the brass map on the council table, the guild's clock on the wall, the highlands through the windows.",
     "A sala do conselho de Concórdia: o mapa de latão na mesa do conselho, o relógio da guilda na parede, as terras altas pelas janelas.",
     "La sala del consejo de Concórdia: el mapa de latón en la mesa del consejo, el reloj del gremio en la pared, las tierras altas por las ventanas."),
    ("The council meets at noon, when the tower strikes. Every master has a voice, and every voice a wheel.",
     "O conselho reúne-se ao meio-dia, quando a torre bate. Cada mestre tem uma voz, e cada voz uma roda.",
     "El consejo se reúne a mediodía, cuando la torre da la hora. Cada maestro tiene una voz, y cada voz una rueda."),
    ("The plates in the gallery have reached the shaft. They wind the soldiers on them better than any Winder. A gift.",
     "As placas da galeria chegaram ao poço. Dão corda aos soldados em cima delas melhor do que qualquer Enrolador. Um presente.",
     "Las placas de la galería han llegado al pozo. Dan cuerda a los soldados encima mejor que cualquier Dador de cuerda. Un regalo."),
    ("The valley burned the first quarter. We sleep in tents again, and the families talk of the coast.",
     "O vale queimou o primeiro bairro. Dormimos outra vez em tendas, e as famílias falam da costa.",
     "El valle quemó el primer barrio. Dormimos otra vez en tiendas, y las familias hablan de la costa."),
    ("(The King: That is not how it went. The city stood, and grew.)", "(O Rei: Não foi assim que aconteceu. A cidade ficou de pé, e cresceu.)",
     "(El Rey: No fue así como ocurrió. La ciudad siguió en pie, y creció.)"),
    ("The travelling clock stands in the council hall now. It keeps the highlands' time; nobody remembers setting it.",
     "O relógio de viagem está agora na sala do conselho. Marca a hora das terras altas; ninguém se lembra de o ter acertado.",
     "El reloj de viaje está ahora en la sala del consejo. Marca la hora de las tierras altas; nadie recuerda haberlo puesto en hora."),
    ("A plate from the gallery's floor lies on the trestle. Its teeth fit nothing in the guild's books.",
     "Uma placa do chão da galeria está no cavalete. Os seus dentes não encaixam em nada dos livros da guilda.",
     "Una placa del suelo de la galería está sobre el caballete. Sus dientes no encajan con nada de los libros del gremio."),
    ("Forty years a Winder, and I have never seen plates lay themselves. The Meister says a gift. I wind the soldiers by hand all the same.",
     "Quarenta anos de Enrolador, e nunca vi placas a assentarem-se sozinhas. O Mestre diz que é um presente. Mesmo assim, dou corda aos soldados à mão.",
     "Cuarenta años de Dador de cuerda, y nunca he visto placas colocarse solas. El maestro dice que es un regalo. Aun así doy cuerda a los soldados a mano."),
    ("The Aviary's birds are out every morning. The valley crosses itself when they pass.", "Os pássaros da Casa do Cuco saem todas as manhãs. O vale benze-se quando passam.",
     "Los pájaros de la Casa del Cuco salen cada mañana. El valle se santigua cuando pasan."),
    # the engine's words (THE UNMAPPED, TURN THEM BACK)
    ("TURNING BACK", "A FAZER VOLTAR", "HACIÉNDOLO VOLVER"),
    ("TURNED BACK!", "VOLTOU PARA TRÁS!", "¡SE VUELVE!"),
]:
    T(en, pt, es)

out = os.path.join(ROOT, "campaign", "missions", MID + ".json")
with open(out, "w") as f:
    json.dump(M, f, indent="\t", ensure_ascii=False)

# ---------------------------------------------------------------- the translations
seen = set()
# (texts another file already has are not repeated: the build refuses a key twice with different words)
import glob   # noqa: E402
for path in glob.glob(os.path.join(ROOT, "tools", "i18n", "*.txt")) + glob.glob(os.path.join(ROOT, "tools", "i18n", "campaign", "*.txt")):
    if os.path.basename(path) == MID + ".txt":
        continue
    for ln in open(path, encoding="utf-8").read().split("\n"):
        if ln.startswith("> "):
            seen.add(ln[2:].replace("\\n", "\n"))
rows = ["# Act 2's mission d04_concordia, \"The City of Gears\" (campaign/missions/d04_concordia.json, written with its texts by",
        "# tools/campaign/make_d04_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what",
        "# was built: docs/campaign_d04_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names as a02 / a04 / d02: Winder =",
        "# Enrolador / Dador de cuerda; Meister = Mestre / maestro; Swift = Cuco (pt and es, the owner's names: tools/i18n/10_air.txt); Clock Aviary = Casa do Cuco /",
        "# Casa del Cuco.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
