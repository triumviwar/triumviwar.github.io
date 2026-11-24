#!/usr/bin/env python3
"""Writes campaign/missions/d05_aldeia.json: Act 2's "The Mission of São Rafael" (the Crown line after d01_minas, the
Tapajós, the wet season 2776; Father Tomasz tells it, the King frames; the plan: docs/campaign_act2_plan.md "d05_aldeia";
what was built: docs/campaign_d05_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d05_aldeia.txt: every
text here is written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d05_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_sao_rafael_map.py (campaign:sao_rafael: the várzea). EVERY LINE IS A PLACEHOLDER for the
owner to rewrite.

The first time the Crown meets THE BROOD as a swarm. THE BROOD IS NOT A PERSON (owner 2026-11-19 / 2026-11-22): the
creatures hunt, feed and follow the strongest call; no line gives one a name of its own, a will, a plan or a feeling.
People may call a creature something (the dragoons' slang for the big Sire), nothing more.
  THE MISSION (Crown, PURPLE, p1): Father Tomasz (a hero), Brother Tiago (the village's catechist, a hero), the mission's
    militia (Musketeers with THE ROSTER LADDER's C5 kit drilled: the Matchlock and the Socket Bayonet; two more by a07
    `people` many), the church, the granary, the houses, the Barracks; the river fort's Barracks and Horse Breeder down
    the trail. NEW (C6): THE DRAGOON and THE CAVALRY CHARGE, with the relief from the river fort (Part 2).
  THE PEOPLE (YELLOW, scripted): about thirty: the old ones at the church, the families in the three fields, the hamlet
    of Santa Luzia (proposed) on the causeway.
  THE SWARM (Brood, GREEN; scripted waves out of the flood, or the SOLO PICK / versus p2): Raptors, Hatchlings over the
    village, in Part 3 a forward Mother rooted on the mud bank with a Tyrant Sire (the young Sire of a05's cages by
    `cages` all: the dragoons' "Lindqvist Sire"). Its size follows d06 `brood_n` (few: smaller waves, all: bigger).
  THE VÁRZEA (the mission's `wade`): men and horses wade the flooded forest at half pace; the creatures go through it
    at their own pace; nothing is built in it. The dry trails are the men's roads.
  PART 1, THE FIRST NIGHT: the bell; the people in the three fields can't hear it in the rain: a soldier or Tomasz
    reaching a field sends its people running to the church; Raptors come out of the flood at the fields, then at the
    bluff. Dawn when everyone is in (NO WAITING), else at the night's end.
  PART 2, THE RELIEF: dragoons and horsemen up the trail from the river fort (NEW: C6); the hamlet of Santa Luzia: ride
    out on the causeway, drive the pack off, its people follow your men back; the CAVALRY CHARGE drilled at the fort's
    Horse Breeder; Hatchlings circle the village: where they circle, the pack follows (shoot them down).
  PART 3, THE ROAD TO THE FORT: the forward Mother roots in the north flood (while she lives the waves grow); the people
    follow Tomasz: walk him down the trail to the river fort with the column covered, on a countdown. Before the last
    of them leave: THE CHOICE, THE FIELDS: BURN the fields and the granary (the swarm finds nothing to eat; the people
    come home to ashes) or LEAVE them (the people's bread; the swarm feeds: its waves a little bigger). Canon LEFT
    (owner 2026-11-22: "the fields LEFT").
  CARRIES: `fields` burned / left, `aldeia` few / some / many (the people who reached the fort, as a share of all),
    `forward` killed / rooted (the forward Mother, for later missions).
  MIRROR (THE SWARM, solo pick; versus): the forward Mother, her Sires and a pack from the start; the village scripted
    on a timetable; win by breaking the church or catching more than half the people before the fort. A swarm win is
    not how it went: the war map's seal broken (warmap: won_by swarm).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d05_aldeia"

TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d05_aldeia.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
MANY = past("a07_council.people", "many")                 # a07: Tomasz's name reached the frontier: two more militia
SIRE_ALL = past("a05_specimens.cages", "all")             # a05: the young Sire of the cages is the swarm's father
B_FEW = past("d06_queen.brood_n", "few")                  # d06: the swarm smaller
B_ALL = past("d06_queen.brood_n", "all")                  # d06: the swarm bigger
NOT_FEW = {"not": B_FEW}
RESTLESS = past("d01_minas.minas", "restless")            # d01: Minas left uneasy (a line)
GOLD_FEW = past("d01_minas.gold", "few")                  # d01: little gold reached the coast: the relief smaller
NOT_GOLD_FEW = {"not": GOLD_FEW}
FLED = past("d01_minas.conspirator", "fled")              # d01: Ramos fled south (a line)
CROWN = {"playing": "crown"}
NO_CROWN = {"not": CROWN}                  # the village scripted (the swarm is the solo pick)
SWARM = {"playing": "swarm"}
NO_SWARM = {"not": SWARM}                  # the swarm scripted: its waves come
ENDED = [{"fired": "the_end"}, {"fired": "lost_all"}, {"fired": "lost_church"}, {"fired": "s_won"}, {"fired": "s_lost"}, {"fired": "road_done"}]
LIVE = {"not": {"any": ENDED}}
P1 = {"not": {"fired": "part2"}}
P2 = {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}]}
P3 = {"fired": "part3"}

# ---------------------------------------------------------------- numbers (NORMAL; EASY / HARD: the mission's "difficulty",
# clocks x1.25 / x0.85, the swarm's waves x0.7 / x1.6)
NIGHT_SECS = 240          # Part 1: dawn comes anyway
HAMLET_SECS = 240         # Part 2: the hamlet holds out this long
COLUMN_SECS = 300         # Part 3: the fort shuts its gate at dusk
WADE = 0.5                # men and horses in the flooded forest
FIELD_CALL = 5            # tiles: a soldier or Tomasz this near a field's people sends them to the church
PEOPLE_RUN = 0.8          # the people running in from the fields (a Labourer's pace times this)
PEOPLE_PACE = 0.4         # the column in Part 3: the people walk carrying their things, the old ones in the middle
WAVE_EVERY = 22           # Part 3: a wave out of the flood this often
GRANARY_GOLD, GRANARY_EVERY = 20, 10
GOLD, POWDER = 300, 300
RELIEF_GOLD = 200         # the relief brings the fort's pay chest (the Charge's drill and a few more men)
SWARM_FOOD = 30           # the swarm's player: food every 10 s besides the granary (no grubs in the flood)
MIRROR_P2, MIRROR_P3 = 150, 300     # the mirror: the village's timetable (the relief, the road)

# where the Part 3 waves come out of the flood (each beside a stretch of the trail), in turn
WAVE_AT = ["flood_tw2", "flood_te3", "flood_tw4", "flood_te5", "flood_tw6", "flood_te7"]
TRAIL = ["trail_1", "trail_2", "trail_3", "trail_4", "trail_5", "trail_6", "trail_7", "fort_gate", "fort_in"]

# ================================================================== the units
units = [
    # ---- the mission (the player): Tomasz, Tiago, the militia on the bluff
    {"team": "mission", "kind": "missionary", "as": "tomasz_rafael", "count": 1, "at": "church_door", "tag": "tomasz",
     "tags": ["leader"], "fixed": True},
    {"team": "mission", "kind": "missionary", "as": "tiago", "count": 1, "at": "church_door", "tag": "tiago", "fixed": True},
    {"team": "mission", "kind": "musketeer", "as": "mission_militia", "count": 8, "at": "bluff_s", "tag": "militia", "fixed": True},
    {"team": "mission", "kind": "musketeer", "as": "mission_militia", "count": 2, "at": "bluff_s", "tag": "militia", "fixed": True, "if": MANY},
    # ---- the people (YELLOW): the old ones at the church, the families in the fields, the hamlet's in its chapel
    {"team": "people", "kind": "labourer", "as": "rafael_villager", "count": 6, "at": "church_yard", "tag": "village_folk",
     "tags": ["people"], "fixed": True},
    {"team": "people", "kind": "labourer", "as": "rafael_villager", "count": 6, "at": "field_w", "tag": "folk_w",
     "tags": ["people", "field_folk"], "fixed": True},
    {"team": "people", "kind": "labourer", "as": "rafael_villager", "count": 6, "at": "field_n", "tag": "folk_n",
     "tags": ["people", "field_folk"], "fixed": True},
    {"team": "people", "kind": "labourer", "as": "rafael_villager", "count": 6, "at": "field_r", "tag": "folk_r",
     "tags": ["people", "field_folk"], "fixed": True},
    {"team": "people", "kind": "labourer", "as": "rafael_villager", "count": 6, "at": "hamlet_in", "tag": "hamlet_folk",
     "tags": ["people"], "fixed": True},
    # ---- THE SWARM played (the solo pick, versus p2): the forward Mother on the mud bank from the start, her Sires, a pack
    {"team": "swarm", "kind": "brood_mother", "as": "forward_mother", "count": 1, "at": "mother_spot", "tag": "fwd_mother",
     "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "tyrannosaur", "count": 1, "at": "sire_spot", "tag": "fwd_sire", "tags": ["sires"], "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "pterodactyl", "count": 1, "at": "storm_spot", "tag": "storm_sire", "tags": ["sires"], "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "raptor", "count": 8, "at": "mud_bank", "tag": "pack", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "raptor", "count": 2, "at": "mud_bank", "tag": "pack", "fixed": True, "if": {"all": [SWARM, B_ALL]}},
    # (the village played by the computer in the mirror: four more militia, so the night is a fight for the swarm too)
    {"team": "mission", "kind": "musketeer", "as": "mission_militia", "count": 4, "at": "bluff_s", "tag": "militia", "fixed": True,
     "if": NO_CROWN},
]

# the fort's palisade: a wall along the rise's north edge with the gate open where the trail comes in
FORT_WALL = [(x, 109) for x in range(52, 59)] + [(x, 109) for x in range(66, 73)] + [(52, y) for y in range(110, 116)] \
    + [(72, y) for y in range(110, 116)]

buildings = [
    {"team": "mission", "kind": "church", "at": [57, 23], "tag": "church", "tags": ["village_b"],
     "name": T("The church of São Rafael", "A igreja de São Rafael", "La iglesia de San Rafael")},
    {"team": "mission", "kind": "cottage", "at": [65, 31], "tag": "granary", "tags": ["village_b", "fields_b"],
     "name": T("The granary", "O celeiro", "El granero")},
    {"team": "mission", "kind": "barracks", "at": [48, 31], "tag": "v_barracks", "tags": ["village_b"]},
    {"team": "mission", "kind": "cottage", "at": [51, 25], "tag": "houses", "tags": ["village_b"],
     "name": T("A house of the mission", "Uma casa da missão", "Una casa de la misión")},
    {"team": "mission", "kind": "cottage", "at": [53, 35], "tag": "houses", "tags": ["village_b"],
     "name": T("A house of the mission", "Uma casa da missão", "Una casa de la misión")},
    {"team": "mission", "kind": "cottage", "at": [62, 36], "tag": "houses", "tags": ["village_b"],
     "name": T("A house of the mission", "Uma casa da missão", "Una casa de la misión")},
    {"team": "mission", "kind": "cottage", "at": [67, 26], "tag": "houses", "tags": ["village_b"],
     "name": T("A house of the mission", "Uma casa da missão", "Una casa de la misión")},
    # the fields: the mission's bread (the people's: no crew label over them)
    {"team": "people", "kind": "farm", "at": [28, 28], "tag": "fields", "tags": ["fields_b"],
     "name": T("The mission's fields", "Os campos da missão", "Los campos de la misión")},
    {"team": "people", "kind": "farm", "at": [55, 9], "tag": "fields", "tags": ["fields_b"],
     "name": T("The mission's fields", "Os campos da missão", "Los campos de la misión")},
    {"team": "people", "kind": "farm", "at": [80, 41], "tag": "fields", "tags": ["fields_b"],
     "name": T("The mission's fields", "Os campos da missão", "Los campos de la misión")},
    # the hamlet of Santa Luzia: two houses and its little chapel
    {"team": "people", "kind": "cottage", "at": [9, 52], "tag": "hamlet_b",
     "name": T("A house of Santa Luzia", "Uma casa de Santa Luzia", "Una casa de Santa Lucía")},
    {"team": "people", "kind": "cottage", "at": [16, 59], "tag": "hamlet_b",
     "name": T("A house of Santa Luzia", "Uma casa de Santa Luzia", "Una casa de Santa Lucía")},
    {"team": "people", "kind": "church", "at": [12, 55], "tag": "chapel",
     "name": T("The chapel of Santa Luzia", "A capela de Santa Luzia", "La capilla de Santa Lucía")},
    # the river fort: its Barracks and Horse Breeder (the dragoons' horses), its palisade
    {"team": "mission", "kind": "barracks", "at": [55, 114], "tag": "f_barracks", "tags": ["fort_b"],
     "name": T("The river fort's barracks", "O quartel do forte do rio", "El cuartel del fuerte del río")},
    {"team": "mission", "kind": "horse_breeder", "at": [64, 114], "tag": "breeder", "tags": ["fort_b"],
     "name": T("The river fort's horse breeder", "O criador de cavalos do forte do rio", "El criadero de caballos del fuerte del río")},
] + [
    {"team": "mission", "kind": "wall", "at": list(c), "tag": "fort_wall", "tags": ["fort_b"],
     "name": T("The river fort's palisade", "A paliçada do forte do rio", "La empalizada del fuerte del río")} for c in FORT_WALL
]

areas = dict(
    village=[44, 20, 30, 21], village_wide=[38, 15, 42, 32], church_yard=[52, 26, 12, 6], church_door=[56, 27, 4, 2],
    bluff_s=[53, 34, 10, 4], bluff_w=[45, 28, 5, 5], granary=[63, 30, 5, 4],
    field_w=[25, 27, 13, 9], field_n=[50, 9, 17, 6], field_r=[78, 40, 11, 9],
    landing=[84, 26, 8, 11], ramp_w=[41, 28, 4, 5], ramp_s=[55, 38, 7, 4],
    causeway=[24, 39, 8, 6], hamlet=[5, 49, 17, 15], hamlet_in=[11, 58, 5, 3],
    trail_1=[56, 43, 5, 5], trail_2=[48, 54, 5, 5], trail_3=[40, 64, 5, 5], trail_4=[38, 74, 5, 5], trail_5=[46, 84, 5, 5],
    trail_6=[60, 92, 5, 5], trail_7=[66, 100, 5, 5], fort_gate=[59, 106, 7, 4], fort_in=[56, 118, 13, 5], fort=[46, 106, 32, 20],
    relief_in=[54, 44, 9, 5],
    mud_bank=[28, 6, 13, 7], mother_spot=[33, 8, 3, 2], sire_spot=[29, 7, 3, 2], storm_spot=[37, 10, 3, 2],
    # where the swarm comes out of the flood
    flood_w=[2, 22, 7, 10], flood_n=[50, 1, 16, 4], flood_nw=[10, 3, 12, 6], flood_e=[84, 56, 8, 8],
    flood_cw=[18, 30, 6, 6], flood_cs=[30, 48, 6, 6], flood_hw=[3, 58, 4, 8],
    flood_tw2=[34, 50, 6, 6], flood_te3=[56, 62, 6, 6], flood_tw4=[26, 74, 6, 6], flood_te5=[60, 80, 6, 6],
    flood_tw6=[40, 94, 6, 6], flood_te7=[78, 96, 6, 6],
)

# ================================================================== the objectives
objectives = [
    # ---- the mission (the Crown)
    {"id": "church_live", "side": "crown", "primary": True, "kind": "manual",
     "text": T("The church of São Rafael must stand until the people leave it.", "A igreja de São Rafael tem de ficar de pé até o povo a deixar.",
               "La iglesia de San Rafael debe seguir en pie hasta que el pueblo la deje.")},
    {"id": "fields_in", "side": "crown", "primary": False, "kind": "manual",
     "text": T("THE FIRST NIGHT: the people in the three fields can't hear the bell. Send a soldier or Father Tomasz to each field: its people run for the church when one of yours reaches them. In the churchyard: {sheltered} of {field_n}.",
               "A PRIMEIRA NOITE: o povo dos três campos não ouve o sino. Mande um soldado ou o Padre Tomasz a cada campo: o povo de lá corre para a igreja quando um dos seus lá chega. No adro: {sheltered} de {field_n}.",
               "LA PRIMERA NOCHE: la gente de los tres campos no oye la campana. Manda a un soldado o al Padre Tomasz a cada campo: su gente corre a la iglesia cuando llega uno de los tuyos. En el atrio: {sheltered} de {field_n}."),
     "phone": T("Fetch the people from the three fields: {sheltered} of {field_n} at the church.",
                "Traga o povo dos três campos: {sheltered} de {field_n} na igreja.", "Trae a la gente de los tres campos: {sheltered} de {field_n} en la iglesia.")},
    {"id": "night", "side": "crown", "primary": False, "kind": "countdown", "clock": "night",
     "text": T("Dawn in {clock:night}.", "Amanhece em {clock:night}.", "Amanece en {clock:night}.")},
    {"id": "hamlet", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE HAMLET: ride out along the causeway (west) to Santa Luzia. Drive the Raptors off: its people come out of the chapel and follow your men back to the church ({hamlet_in} of {hamlet_n}).",
               "A ALDEOLA: siga pela calçada (oeste) até Santa Luzia. Afaste os Raptores: o povo sai da capela e segue os seus homens até à igreja ({hamlet_in} de {hamlet_n}).",
               "LA ALDEHUELA: cabalga por la calzada (oeste) hasta Santa Lucía. Echa a los Raptores: su gente sale de la capilla y sigue a tus hombres hasta la iglesia ({hamlet_in} de {hamlet_n})."),
     "phone": T("Santa Luzia (west, the causeway): drive the pack off, bring its people back ({hamlet_in} of {hamlet_n}).",
                "Santa Luzia (oeste, a calçada): afaste a matilha, traga o povo ({hamlet_in} de {hamlet_n}).",
                "Santa Lucía (oeste, la calzada): echa a la manada, trae a su gente ({hamlet_in} de {hamlet_n}).")},
    {"id": "hamlet_clock", "side": "crown", "primary": False, "kind": "countdown", "clock": "hamlet", "hidden": True,
     "text": T("The chapel at Santa Luzia holds for {clock:hamlet}.", "A capela de Santa Luzia aguenta {clock:hamlet}.", "La capilla de Santa Lucía aguanta {clock:hamlet}.")},
    {"id": "charge", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Drill the CAVALRY CHARGE at the river fort's Horse Breeder (far down the trail: select it on the map). A Horseman's first blow after a gallop then hits more than twice as hard on light creatures.",
               "Treine a CARGA DE CAVALARIA no Criador de Cavalos do forte do rio (lá em baixo no trilho: escolha-o no mapa). O primeiro golpe de um Cavaleiro depois de um galope fere então mais do dobro nas criaturas leves.",
               "Entrena la CARGA DE CABALLERÍA en el Criadero de Caballos del fuerte del río (abajo en la senda: elígelo en el mapa). El primer golpe de un Jinete tras un galope hiere entonces más del doble a las criaturas ligeras.")},
    {"id": "hatch", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Shoot down the flyers over the village: where they circle, the pack follows ({hatch_left} left).",
               "Abata os voadores sobre a aldeia: onde eles rodam, a matilha segue ({hatch_left} restam).",
               "Derriba a los voladores sobre la aldea: donde ellos giran, la manada sigue ({hatch_left} quedan).")},
    {"id": "road", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE ROAD TO THE FORT: the people follow Father Tomasz. Walk him down the trail to the river fort and keep the column covered: at the fort {at_fort} of {people_n}. The flood on both sides is the creatures' road, not yours.",
               "A ESTRADA PARA O FORTE: o povo segue o Padre Tomasz. Leve-o pelo trilho até ao forte do rio e cubra a coluna: no forte {at_fort} de {people_n}. A cheia dos dois lados é o caminho das criaturas, não o seu.",
               "EL CAMINO AL FUERTE: el pueblo sigue al Padre Tomasz. Llévalo por la senda hasta el fuerte del río y cubre la columna: en el fuerte {at_fort} de {people_n}. La crecida a ambos lados es el camino de las criaturas, no el tuyo."),
     "phone": T("The people follow Tomasz: walk him to the river fort. At the fort {at_fort} of {people_n}.",
                "O povo segue Tomasz: leve-o ao forte do rio. No forte {at_fort} de {people_n}.",
                "El pueblo sigue a Tomasz: llévalo al fuerte del río. En el fuerte {at_fort} de {people_n}.")},
    {"id": "column", "side": "crown", "primary": False, "kind": "countdown", "clock": "column", "hidden": True,
     "text": T("The fort shuts its gate at dusk: {clock:column}.", "O forte fecha o portão ao anoitecer: {clock:column}.", "El fuerte cierra su portón al anochecer: {clock:column}.")},
    {"id": "fwd", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
     "text": T("A forward Mother has rooted on the mud bank in the north flood. While she lives every wave is bigger. Kill her if you can spare the men.",
               "Uma Mãe avançada enraizou no banco de lama da cheia do norte. Enquanto viver, cada vaga é maior. Mate-a se puder dispensar os homens.",
               "Una Madre adelantada ha enraizado en el banco de barro de la crecida del norte. Mientras viva, cada oleada es mayor. Mátala si puedes prescindir de los hombres.")},
    # ---- the swarm (the solo pick, versus)
    {"id": "s_mother", "side": "swarm", "primary": True, "kind": "protect", "tag": "fwd_mother", "hidden": True,
     "text": T("Your Mother must live.", "A sua Mãe tem de viver.", "Tu Madre debe vivir.")},
    {"id": "s_hunt", "side": "swarm", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE RAID: break the church of São Rafael, or catch more than half of the people before they reach the river fort: caught {dead_p} of {people_n} (more than {half} wins). Lay eggs on your Mother's card; the granary feeds whoever holds it.",
               "O ASSALTO: derrube a igreja de São Rafael, ou apanhe mais de metade do povo antes que chegue ao forte do rio: apanhados {dead_p} de {people_n} (mais de {half} ganha). Ponha ovos no painel da sua Mãe; o celeiro alimenta quem o tem.",
               "EL ASALTO: derriba la iglesia de San Rafael, o atrapa a más de la mitad del pueblo antes de que llegue al fuerte del río: atrapados {dead_p} de {people_n} (más de {half} gana). Pon huevos en el panel de tu Madre; el granero alimenta a quien lo tiene."),
     "phone": T("Break the church, or catch more than {half} of {people_n} people ({dead_p} now).",
                "Derrube a igreja, ou apanhe mais de {half} de {people_n} pessoas ({dead_p} agora).",
                "Derriba la iglesia, o atrapa a más de {half} de {people_n} personas ({dead_p} ahora).")},
]

M = {
    "id": MID,
    "title": T("The Mission of São Rafael", "A Missão de São Rafael", "La Misión de San Rafael"),
    "summary": T("The Tapajós, the wet season 2776. The swarm comes out of the flooded forest at Father Tomasz's mission village. Bring the people to the river fort.",
                 "O Tapajós, a estação das chuvas de 2776. O enxame sai da floresta alagada na aldeia de missão do Padre Tomasz. Leve o povo ao forte do rio.",
                 "El Tapajós, la estación de lluvias de 2776. El enjambre sale del bosque inundado en la aldea de misión del Padre Tomasz. Lleva al pueblo al fuerte del río."),
    "map": "campaign:sao_rafael",
    "voice": "d05",
    "light": "jungle_night",
    "weather": "rain",
    "floor": [0.82, 0.84, 0.78],
    "expansion_spots": False,
    "manual_end": True,
    # (the swarm's waves a good deal bigger on HARD: the sims' careful player lost no more there with the default x1.25)
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.7}, "hard": {"clocks": 0.85, "spawns": 1.6}},
    "needs": ["a07_council", "d01_minas"],
    "modes": ["solo", "versus"],
    "solo_sides": ["crown", "swarm"],
    "wade": {"pace": WADE, "free": ["brood"]},
    "granaries": [{"tag": "granary", "gold": GRANARY_GOLD, "every": GRANARY_EVERY, "hold_within": 4, "counter": "fed"}],
    "sides": [
        {"id": "crown", "name": T("The Mission", "A Missão", "La Misión"),
         "about": T("Father Tomasz, Brother Tiago and the mission's militia at São Rafael; the river fort down the trail.",
                    "O Padre Tomasz, o Irmão Tiago e a milícia da missão em São Rafael; o forte do rio lá em baixo no trilho.",
                    "El Padre Tomasz, el Hermano Tiago y la milicia de la misión en San Rafael; el fuerte del río abajo en la senda.")},
        {"id": "swarm", "name": T("The Swarm", "O Enxame", "El Enjambre"),
         "about": T("The creatures out of the flooded forest: a forward Mother, her Sires, Raptors and flyers.",
                    "As criaturas da floresta alagada: uma Mãe avançada, os seus Sires, Raptores e voadores.",
                    "Las criaturas del bosque inundado: una Madre adelantada, sus Señores, Raptores y voladores.")},
    ],
    "teams": [
        {"id": "mission", "side": "crown", "faction": "crown", "colour": 4, "start": "none", "camera": "church_yard", "gold": GOLD,
         "powder": POWDER, "techs": ["matchlock", "bayonet"],
         "control": {"solo": "p1", "versus": "p1", "foe": "script"}},
        {"id": "people", "side": "crown", "faction": "crown", "colour": 3, "start": "none", "camera": "church_yard",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "swarm", "side": "swarm", "faction": "brood", "colour": 2, "start": "none", "camera": "mud_bank", "gold": 300, "powder": 40,
         "roster": {"deny": ["grub", "rootmaw", "mound_turtle", "dilophosaurus", "stage3", "brute", "spitter", "mist_toad"]},
         "control": {"solo": "script", "versus": "p2"}},
    ],
    "areas": areas,
    "counters": {k: {"start": 0} for k in ["people_n", "field_n", "sheltered", "hamlet_n", "hamlet_in", "at_fort", "dead_p", "half",
                                             "margin", "alive_p", "wave_n", "fed", "hatch_left"]},
    "exits": [{"area": "fort_in", "tag": "people", "counter": "at_fort", "after": "part3"}],
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["tomasz", "tiago"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "crown", "portrait": "res://campaign/hub/rome_king_face.png"},
        "tomasz": {"name": T("Father Tomasz", "Padre Tomasz", "Padre Tomasz"), "side": "crown"},
        "tiago": {"name": T("Brother Tiago", "Irmão Tiago", "Hermano Tiago"), "side": "crown"},
        "sobral": {"name": T("Captain Sobral", "Capitão Sobral", "Capitán Sobral"), "side": "crown"},
        "narrator": {"name": T("São Rafael", "São Rafael", "San Rafael"), "side": "crown"},
        "flood": {"name": T("The Flood", "A Cheia", "La Crecida"), "side": "swarm"},
    },
    "lines": {},
    "stills": {},
    "next": {"crown": "d09_crossroads", "swarm": ""},
    "debrief": {},
}

L = M["lines"]


UNTIL = {}         # line id -> a trigger: still waiting in the dialogue box when it fires, the line is dropped (d01's `until`)


def line(lid, who, en, pt, es, to=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    return lid


CR, SW = "crown", "swarm"
# ---- the opening (the King frames; Tomasz tells it)
line("k_open1", "king", "After Minas, Tomasz asked for the hardest place in Brazil. They sent him up the Tapajós.",
     "Depois de Minas, Tomasz pediu o lugar mais difícil do Brasil. Mandaram-no subir o Tapajós.",
     "Después de Minas, Tomasz pidió el lugar más difícil de Brasil. Lo mandaron a remontar el Tapajós.")
line("k_open2", "king", "In the wet season of 2776 he met the swarm. You will hear how it was born. He met it first.",
     "Na estação das chuvas de 2776 ele encontrou o enxame. Hás de ouvir como nasceu. Ele encontrou-o primeiro.",
     "En la estación de lluvias de 2776 se encontró con el enjambre. Oirás cómo nació. Él lo encontró primero.")
line("t_open1", "tomasz", "São Rafael. Thirty families, a church of timber, fields on the dry ground above the flood.",
     "São Rafael. Trinta famílias, uma igreja de madeira, campos no chão seco acima da cheia.",
     "San Rafael. Treinta familias, una iglesia de madera, campos en el suelo seco sobre la crecida.")
line("t_open2", "tomasz", "Brother Tiago taught the catechism in his own tongue. I taught it badly in mine.",
     "O Irmão Tiago ensinava o catecismo na sua língua. Eu ensinava-o mal na minha.",
     "El Hermano Tiago enseñaba el catecismo en su lengua. Yo lo enseñaba mal en la mía.")
line("t_open_many", "tomasz", "Word of Rome had come up the river before me. They trusted me before I had earned it.",
     "A notícia de Roma tinha subido o rio antes de mim. Confiaram em mim antes de eu o merecer.",
     "La noticia de Roma había remontado el río antes que yo. Confiaron en mí antes de que lo mereciera.")
line("t_open_minas", "tomasz", "I had left Minas uneasy. I thought the frontier would be quieter.",
     "Eu tinha deixado Minas inquieta. Pensei que a fronteira seria mais calma.",
     "Había dejado Minas inquieta. Pensé que la frontera sería más tranquila.")
line("t_open_fled", "tomasz", "Ramos was somewhere in the south by then. I prayed for him on the boat.",
     "Por essa altura Ramos estava algures no sul. Rezei por ele no barco.", "Para entonces Ramos estaba en algún lugar del sur. Recé por él en el barco.")
line("t_open3", "tomasz", "That year the river came up into the forest and did not go down.",
     "Nesse ano o rio subiu para dentro da floresta e não desceu.", "Aquel año el río subió dentro del bosque y no bajó.")
line("k_open_s", "king", "Tomasz tells that night as a priest. Here it is from the flooded forest, where nobody was keeping count.",
     "Tomasz conta essa noite como padre. Aqui está ela vista da floresta alagada, onde ninguém contava.",
     "Tomasz cuenta esa noche como sacerdote. Aquí está vista desde el bosque inundado, donde nadie llevaba la cuenta.")
line("f_open", "flood", "The wet season. The forest stands in the river. The pack is hungry, and the village smells of grain and smoke.",
     "A estação das chuvas. A floresta está dentro do rio. A matilha tem fome, e a aldeia cheira a grão e a fumo.",
     "La estación de lluvias. El bosque está dentro del río. La manada tiene hambre, y la aldea huele a grano y a humo.")
# ---- part 1: the first night
line("t_bell", "tomasz", "Tiago, the bell! Ring it!", "Tiago, o sino! Toca-o!", "¡Tiago, la campana! ¡Tócala!", CR)
line("ti_bell", "tiago", "They are out in the fields, Father. In this rain they will not hear it.",
     "Estão lá fora nos campos, Padre. Com esta chuva não o vão ouvir.", "Están en los campos, Padre. Con esta lluvia no la oirán.", CR)
line("n_lesson", "narrator", "The people in the three fields can't hear the bell. Send a soldier or Father Tomasz to each field: its people run for the church when one of yours reaches them.",
     "O povo dos três campos não ouve o sino. Mande um soldado ou o Padre Tomasz a cada campo: o povo de lá corre para a igreja quando um dos seus lá chega.",
     "La gente de los tres campos no oye la campana. Manda a un soldado o al Padre Tomasz a cada campo: su gente corre a la iglesia cuando llega uno de los tuyos.", CR)
line("n_varzea", "narrator", "Your men wade the flooded forest at half pace. The creatures go through it as fast as on dry ground. Keep to the dry paths.",
     "Os seus homens atravessam a floresta alagada a meio passo. As criaturas passam por ela tão depressa como em terra seca. Fique nos caminhos secos.",
     "Tus hombres vadean el bosque inundado a medio paso. Las criaturas lo cruzan tan rápido como en tierra seca. Quédate en los caminos secos.", CR)
line("t_field", "tomasz", "To the church! All of you! Leave the baskets!", "Para a igreja! Todos! Deixem os cestos!", "¡A la iglesia! ¡Todos! ¡Dejad las cestas!", CR)
line("n_w1", "narrator", "Something comes out of the flood at the west field. Raptors.", "Alguma coisa sai da cheia no campo do oeste. Raptores.",
     "Algo sale de la crecida en el campo del oeste. Raptores.", CR)
line("ti_w1", "tiago", "Those are not jaguars, Father.", "Aquilo não são onças, Padre.", "Eso no son jaguares, Padre.", CR)
line("n_w2", "narrator", "More come out of the flood at the north field.", "Mais saem da cheia no campo do norte.", "Más salen de la crecida en el campo del norte.", CR)
line("n_w3", "narrator", "And at the river field, by the landing.", "E no campo do rio, junto ao desembarque.", "Y en el campo del río, junto al embarcadero.", CR)
line("ti_in", "tiago", "Everyone from the fields is in the churchyard, Father. The children too.",
     "Todos os dos campos estão no adro, Padre. As crianças também.", "Todos los de los campos están en el atrio, Padre. Los niños también.", CR)
line("n_push", "narrator", "They come up the bluff for the churchyard. Hold the line on the bluff.",
     "Sobem o barranco para o adro. Segure a linha no barranco.", "Suben el barranco hacia el atrio. Mantén la línea en el barranco.", CR)
line("t_pray", "tomasz", "Kneel, all of you, and stay down. Let the men shoot over you.",
     "Ajoelhem-se, todos, e fiquem em baixo. Deixem os homens atirar por cima.", "Arrodillaos, todos, y quedaos abajo. Dejad que los hombres disparen por encima.", CR)
line("t_dawn", "tomasz", "Dawn. I have never been so glad of a grey sky.", "Amanhecer. Nunca fiquei tão contente com um céu cinzento.",
     "El alba. Nunca me alegré tanto de un cielo gris.")
line("n_dawn_late", "narrator", "Dawn. Whoever was still out in the fields runs in now, if they can.",
     "Amanhecer. Quem ainda estava nos campos corre agora para dentro, se puder.", "El alba. Quien seguía en los campos corre ahora adentro, si puede.", CR)
# ---- part 2: the relief, the hamlet
line("n_relief", "narrator", "Horses on the trail from the south: the relief from the river fort.", "Cavalos no trilho do sul: o socorro do forte do rio.",
     "Caballos en la senda del sur: el socorro del fuerte del río.")
line("c_arrive", "sobral", "Captain Sobral, of the river fort. Your canoe reached us yesterday. We rode all night.",
     "Capitão Sobral, do forte do rio. A sua canoa chegou ontem. Cavalgámos a noite toda.",
     "Capitán Sobral, del fuerte del río. Su canoa nos llegó ayer. Cabalgamos toda la noche.")
line("c_small", "sobral", "The Governor's purse is thin since Minas. I could bring only a few.",
     "A bolsa do Governador está magra desde Minas. Só pude trazer poucos.", "La bolsa del Gobernador anda flaca desde Minas. Solo pude traer a unos pocos.", CR)
line("t_hamlet", "tomasz", "Santa Luzia. The hamlet on the causeway. Nobody came in from there.",
     "Santa Luzia. A aldeola na calçada. Ninguém veio de lá.", "Santa Lucía. La aldehuela de la calzada. Nadie vino de allí.", CR)
line("ti_hamlet", "tiago", "My sister's family is there. They will have gone into the chapel.",
     "A família da minha irmã está lá. Devem ter ido para a capela.", "La familia de mi hermana está allí. Se habrán metido en la capilla.", CR)
line("n_hamlet", "narrator", "Ride out along the causeway (west) to Santa Luzia. Drive the Raptors off, and its people come out and follow your men back.",
     "Siga pela calçada (oeste) até Santa Luzia. Afaste os Raptores, e o povo sai e segue os seus homens de volta.",
     "Cabalga por la calzada (oeste) hasta Santa Lucía. Echa a los Raptores, y su gente sale y sigue a tus hombres de vuelta.", CR)
line("c_charge", "sobral", "My horsemen are drilled for the charge, if the fort gives them the time. A charge breaks the small ones like reeds.",
     "Os meus cavaleiros estão treinados para a carga, se o forte lhes der tempo. Uma carga parte os pequenos como canas.",
     "Mis jinetes están entrenados para la carga, si el fuerte les da tiempo. Una carga rompe a los pequeños como cañas.", CR)
line("n_charge", "narrator", "Select the river fort's Horse Breeder (down the trail) and press CHARGE: the drill needs nobody there.",
     "Escolha o Criador de Cavalos do forte do rio (lá em baixo no trilho) e aperte CARGA: o treino não precisa de ninguém lá.",
     "Elige el Criadero de Caballos del fuerte del río (abajo en la senda) y pulsa CARGA: el entrenamiento no necesita a nadie allí.", CR)
line("n_charged", "narrator", "The Charge is drilled. Gallop your Horsemen into the light ones.", "A Carga está treinada. Lance os seus Cavaleiros a galope contra os leves.",
     "La Carga está entrenada. Lanza a tus Jinetes al galope contra los ligeros.", CR)
line("n_hatch", "narrator", "Small flyers circle over the village. Where they circle, the pack follows.",
     "Pequenos voadores rodam sobre a aldeia. Onde eles rodam, a matilha segue.", "Pequeños voladores giran sobre la aldea. Donde ellos giran, la manada sigue.")
line("c_hatch", "sobral", "Shoot those birds down! They are not birds.", "Abatam esses pássaros! Não são pássaros.", "¡Derribad esos pájaros! No son pájaros.", CR)
line("n_hatch_down", "narrator", "The flyers are down. The pack comes on blind.", "Os voadores caíram. A matilha vem às cegas.", "Los voladores han caído. La manada viene a ciegas.", CR)
line("n_free", "narrator", "The people of Santa Luzia come out of the chapel. They follow your men back along the causeway.",
     "O povo de Santa Luzia sai da capela. Segue os seus homens de volta pela calçada.", "La gente de Santa Lucía sale de la capilla. Sigue a tus hombres de vuelta por la calzada.")
line("ti_found", "tiago", "They hid in the chapel all night. They prayed the whole time, my sister says.",
     "Esconderam-se na capela a noite toda. Rezaram o tempo todo, diz a minha irmã.", "Se escondieron en la capilla toda la noche. Rezaron todo el tiempo, dice mi hermana.", CR)
line("n_flank", "narrator", "The flyers still circle over you: more of the pack comes at the causeway out of the flood.",
     "Os voadores ainda rodam sobre vós: mais da matilha vem à calçada saída da cheia.", "Los voladores aún giran sobre vosotros: más de la manada viene a la calzada desde la crecida.", CR)
line("n_probe", "narrator", "A few come up at the village while your riders are away.", "Alguns sobem à aldeia enquanto os seus cavaleiros estão fora.",
     "Algunos suben a la aldea mientras tus jinetes están fuera.", CR)
line("n_hamlet_late", "narrator", "The chapel at Santa Luzia is broken. Nobody comes out.", "A capela de Santa Luzia foi derrubada. Ninguém sai.",
     "La capilla de Santa Lucía ha caído. Nadie sale.", CR)
line("ti_back", "tiago", "They are in, Father. All we could find.", "Estão dentro, Padre. Todos os que encontrámos.", "Están dentro, Padre. Todos los que encontramos.", CR)
# ---- part 3: the road
line("n_mother", "narrator", "In the north flood a big one has rooted on the mud bank: a forward Mother. While she lives, every wave is bigger than the last.",
     "Na cheia do norte uma grande enraizou no banco de lama: uma Mãe avançada. Enquanto viver, cada vaga é maior do que a anterior.",
     "En la crecida del norte una grande ha enraizado en el banco de barro: una Madre adelantada. Mientras viva, cada oleada es mayor que la anterior.", CR)
line("c_sire", "sobral", "And that Sire beside her. My men call him the Lindqvist Sire. They say he came out of the doctor's cages.",
     "E aquele Sire ao lado dela. Os meus homens chamam-lhe o Sire do Lindqvist. Dizem que saiu das jaulas do doutor.",
     "Y ese Señor a su lado. Mis hombres lo llaman el Señor de Lindqvist. Dicen que salió de las jaulas del doctor.")
line("c_cannot", "sobral", "We cannot hold this, Father. Not with these men. The fort can.", "Não podemos segurar isto, Padre. Não com estes homens. O forte pode.",
     "No podemos sostener esto, Padre. No con estos hombres. El fuerte sí.")
line("t_go", "tomasz", "Then we go. Everyone. The old ones in the middle.", "Então vamos. Todos. Os velhos no meio.", "Entonces nos vamos. Todos. Los viejos en el medio.")
line("n_road", "narrator", "The people follow Father Tomasz. Walk him down the trail to the river fort, and keep the column covered.",
     "O povo segue o Padre Tomasz. Leve-o pelo trilho até ao forte do rio, e cubra a coluna.",
     "El pueblo sigue al Padre Tomasz. Llévalo por la senda hasta el fuerte del río, y cubre la columna.", CR)
line("c_burn", "sobral", "Burn the fields and the granary, Father. Leave them nothing to eat.", "Queime os campos e o celeiro, Padre. Não lhes deixe nada para comer.",
     "Queme los campos y el granero, Padre. No les deje nada que comer.", CR)
line("t_bread", "tomasz", "That is the people's bread for the winter.", "Isso é o pão do povo para o inverno.", "Ese es el pan del pueblo para el invierno.", CR)
line("ti_choose", "tiago", "They ask you to choose, Father. They will do what you say.", "Pedem-lhe que escolha, Padre. Farão o que disser.",
     "Le piden que elija, Padre. Harán lo que usted diga.", CR)
line("q_fields", "narrator", "Captain Sobral would burn the fields and the granary so the swarm finds nothing to eat. They are the people's bread for the winter.",
     "O Capitão Sobral queimaria os campos e o celeiro para o enxame não achar nada para comer. São o pão do povo para o inverno.",
     "El Capitán Sobral quemaría los campos y el granero para que el enjambre no encuentre nada que comer. Son el pan del pueblo para el invierno.", CR)
line("t_burned", "tomasz", "God forgive me. Burn them.", "Deus me perdoe. Queimem-nos.", "Dios me perdone. Quemadlos.")
line("t_left", "tomasz", "No. It is their bread. We will pay for it with powder, not with their hunger.",
     "Não. É o pão deles. Pagamos isto com pólvora, não com a fome deles.", "No. Es su pan. Lo pagaremos con pólvora, no con su hambre.")
line("n_burned", "narrator", "The fields and the granary burn behind the column.", "Os campos e o celeiro ardem atrás da coluna.",
     "Los campos y el granero arden detrás de la columna.", CR)
line("n_fed", "narrator", "Behind the column the swarm comes up into the fields and feeds. Its waves come bigger.",
     "Atrás da coluna o enxame sobe aos campos e come. As suas vagas vêm maiores.", "Detrás de la columna el enjambre sube a los campos y come. Sus oleadas vienen mayores.", CR)
line("n_wave", "narrator", "They come out of the flood at the column.", "Saem da cheia sobre a coluna.", "Salen de la crecida sobre la columna.", CR)
line("c_mother_dead", "sobral", "The big one in the flood is down! They come slower now.", "A grande na cheia caiu! Agora vêm mais devagar.",
     "¡La grande de la crecida ha caído! Ahora vienen más despacio.", CR)
line("n_fort", "narrator", "The first of the people reach the river fort.", "Os primeiros do povo chegam ao forte do rio.", "Los primeros del pueblo llegan al fuerte del río.")
line("t_hurt", "tomasz", "I am hit. Keep them walking, Tiago.", "Fui atingido. Mantém-nos a andar, Tiago.", "Me han dado. Que sigan andando, Tiago.", CR)
line("t_lead", "tomasz", "Stay close to me. Do not look into the water.", "Fiquem perto de mim. Não olhem para a água.", "Quedaos cerca de mí. No miréis al agua.", CR)
line("n_gate", "narrator", "Dusk. The river fort shuts its gate. Whoever is still on the trail is left to the flood.",
     "Anoitece. O forte do rio fecha o portão. Quem ainda está no trilho fica entregue à cheia.",
     "Anochece. El fuerte del río cierra su portón. Quien sigue en la senda queda a merced de la crecida.")
line("n_church_down", "narrator", "The church of São Rafael falls with the people in its yard.", "A igreja de São Rafael cai com o povo no adro.",
     "La iglesia de San Rafael cae con el pueblo en su atrio.")
line("n_all_lost", "narrator", "Nobody of São Rafael is left alive.", "Não resta ninguém vivo de São Rafael.", "No queda nadie vivo de San Rafael.")
# ---- the swarm's (the solo pick) lines: no creature speaks; the flood's narrator and the village's voices
line("f_1", "flood", "Your Mother is rooted on the mud bank. Lay eggs on her card: Raptors by the Tyrant Sire, flyers by the Storm Sire.",
     "A sua Mãe está enraizada no banco de lama. Ponha ovos no painel dela: Raptores pelo Sire Tirano, voadores pelo Sire da Tempestade.",
     "Tu Madre está enraizada en el banco de barro. Pon huevos en su panel: Raptores por el Señor Tirano, voladores por el Señor de la Tormenta.", SW)
line("f_2", "flood", "The flood is your road: your creatures cross it at full pace, the men wade it slowly. The granary feeds whoever stands round it.",
     "A cheia é o seu caminho: as suas criaturas atravessam-na a toda a velocidade, os homens vadeiam-na devagar. O celeiro alimenta quem está à volta dele.",
     "La crecida es tu camino: tus criaturas la cruzan a toda velocidad, los hombres la vadean despacio. El granero alimenta a quien está a su alrededor.", SW)
line("f_relief", "flood", "Horses on the trail from the south: the men from the river fort.", "Cavalos no trilho do sul: os homens do forte do rio.",
     "Caballos en la senda del sur: los hombres del fuerte del río.", SW)
line("f_road", "flood", "The people leave the bluff and go down the trail in a long line.", "O povo deixa o barranco e desce o trilho numa longa fila.",
     "El pueblo deja el barranco y baja por la senda en una larga fila.", SW)
line("f_won", "flood", "The column breaks in the flood. Nobody counts what is left.", "A coluna desfaz-se na cheia. Ninguém conta o que resta.",
     "La columna se deshace en la crecida. Nadie cuenta lo que queda.", SW)
line("f_lost", "flood", "The fort's gate shuts on the last of them.", "O portão do forte fecha-se sobre os últimos.", "El portón del fuerte se cierra tras los últimos.", SW)
line("f_mother_dead", "flood", "The Mother is dead. The pack scatters into the flood.", "A Mãe morreu. A matilha espalha-se pela cheia.", "La Madre ha muerto. La manada se dispersa por la crecida.", SW)
# ---- the endings
line("t_end1", "tomasz", "We came through the fort's gate at dusk, and I counted them.", "Entrámos pelo portão do forte ao anoitecer, e contei-os.",
     "Entramos por el portón del fuerte al anochecer, y los conté.")
line("t_end_many", "tomasz", "Most of them were there. I counted twice to be sure.", "A maior parte estava lá. Contei duas vezes para ter a certeza.",
     "La mayoría estaba allí. Conté dos veces para estar seguro.")
line("t_end_some", "tomasz", "Some of them were there. I named the others that night, on my knees.", "Alguns estavam lá. Os outros nomeei-os nessa noite, de joelhos.",
     "Algunos estaban allí. A los otros los nombré esa noche, de rodillas.")
line("t_end_few", "tomasz", "Few of them were there. I have their names still.", "Poucos estavam lá. Ainda tenho os nomes deles.", "Pocos estaban allí. Todavía tengo sus nombres.")
line("t_end_burned", "tomasz", "Behind us the smoke of the fields stood over the forest all night.", "Atrás de nós o fumo dos campos ficou sobre a floresta a noite toda.",
     "Detrás de nosotros el humo de los campos se quedó sobre el bosque toda la noche.")
line("t_end_left", "tomasz", "Behind us the fields stood green in the rain. The swarm fed on them all season.", "Atrás de nós os campos ficaram verdes na chuva. O enxame comeu deles a estação toda.",
     "Detrás de nosotros los campos quedaron verdes bajo la lluvia. El enjambre comió de ellos toda la estación.")
line("k_end1", "king", "A priest, a catechist and a handful of dragoons brought a village through the flood.", "Um padre, um catequista e um punhado de dragões levaram uma aldeia através da cheia.",
     "Un sacerdote, un catequista y un puñado de dragones llevaron una aldea a través de la crecida.")
line("k_end_left", "king", "He would not burn the poor's bread. My soldiers paid for that bread on the Tapajós for years. I would have done the same.",
     "Ele não quis queimar o pão dos pobres. Os meus soldados pagaram esse pão no Tapajós durante anos. Eu teria feito o mesmo.",
     "No quiso quemar el pan de los pobres. Mis soldados pagaron ese pan en el Tapajós durante años. Yo habría hecho lo mismo.")
line("k_end_burned", "king", "He burned the poor's bread to starve the swarm. He has confessed it every year since. It was a hard thing, and he chose it.",
     "Ele queimou o pão dos pobres para matar o enxame à fome. Confessou-o todos os anos desde então. Foi uma coisa dura, e ele escolheu-a.",
     "Quemó el pan de los pobres para matar de hambre al enjambre. Lo ha confesado cada año desde entonces. Fue algo duro, y él lo eligió.")
line("k_end_s", "king", "That is not how it went. Tomasz brought them to the fort. Hear it again from him.",
     "Não foi assim que aconteceu. Tomasz levou-os ao forte. Ouve outra vez da boca dele.", "No fue así como pasó. Tomasz los llevó al fuerte. Óyelo otra vez de su boca.")

# (a quick player is past the part a chatty line belongs to: those lines are dropped unseen once the next part begins)
for lid in ["ti_bell", "n_varzea", "ti_w1", "n_w2", "n_w3", "ti_in", "t_pray"]:
    L[lid]["until"] = "part2"
for lid in ["c_small", "t_hamlet", "ti_hamlet", "n_hamlet", "c_charge", "n_charge", "n_charged", "n_hatch", "c_hatch", "n_hatch_down",
            "n_probe", "ti_found", "n_flank"]:
    L[lid]["until"] = "part3"
for lid in ["t_lead", "c_burn", "t_bread", "ti_choose", "n_fed", "n_wave", "c_sire", "n_mother"]:
    L[lid]["until"] = "road_done"

# ---- stills
M["stills"] = {
    "rome": {"image": STILL % "p01_01", "caption": T("Rome, the present. The King tells it.", "Roma, o presente. O Rei conta.", "Roma, el presente. El Rey lo cuenta.")},
    "village": {"image": STILL % "d05_01", "caption": T("São Rafael, on the Tapajós, the wet season 2776.", "São Rafael, no Tapajós, a estação das chuvas de 2776.",
                                                        "San Rafael, en el Tapajós, la estación de lluvias de 2776.")},
    "bell": {"image": STILL % "d05_02", "caption": T("The bell in the night.", "O sino na noite.", "La campana en la noche.")},
    "dragoons": {"image": STILL % "d05_03", "caption": T("The relief from the river fort.", "O socorro do forte do rio.", "El socorro del fuerte del río.")},
    "fields": {"image": STILL % "d05_04", "caption": T("The fields at dusk.", "Os campos ao entardecer.", "Los campos al atardecer.")},
}
M["opening"] = {
    "crown": [{"still": "rome", "lines": ["k_open1", "k_open2"]},
              {"still": "village", "lines": ["t_open1", "t_open2", {"id": "t_open_many", "if": MANY}, {"id": "t_open_minas", "if": RESTLESS},
                                             {"id": "t_open_fled", "if": FLED}, "t_open3"]}],
    "swarm": [{"still": "rome", "lines": ["k_open_s"]}, {"still": "bell", "lines": ["f_open"]}],
}
M["ending"] = {
    "crown": [
        {"still": "fields", "lines": ["t_end1", {"id": "t_end_many", "if": {"flag": {"aldeia": "many"}}}, {"id": "t_end_some", "if": {"flag": {"aldeia": "some"}}},
                                      {"id": "t_end_few", "if": {"flag": {"aldeia": "few"}}},
                                      {"id": "t_end_burned", "if": {"flag": {"fields": "burned"}}}, {"id": "t_end_left", "if": {"flag": {"fields": "left"}}}]},
        {"still": "rome", "lines": ["k_end1", {"id": "k_end_left", "if": {"flag": {"fields": "left"}}}, {"id": "k_end_burned", "if": {"flag": {"fields": "burned"}}}]},
    ],
    "swarm": [{"still": "bell", "lines": ["f_won"]}, {"still": "rome", "lines": ["k_end_s"]}],
}
M["briefing"] = {
    "crown": {"still": "village", "text": [
        T("The Tapajós, the wet season 2776. You are Tomasz's mission village of São Rafael: Father Tomasz, Brother Tiago and the mission's militia.",
          "O Tapajós, a estação das chuvas de 2776. Você é a aldeia de missão de Tomasz, São Rafael: o Padre Tomasz, o Irmão Tiago e a milícia da missão.",
          "El Tapajós, la estación de lluvias de 2776. Eres la aldea de misión de Tomasz, San Rafael: el Padre Tomasz, el Hermano Tiago y la milicia de la misión."),
        T("Something hunts in the flooded forest round the village. First bring the people in from the fields to the church; then the relief rides up from the river fort, and the hamlet of Santa Luzia must be fetched.",
          "Alguma coisa caça na floresta alagada à volta da aldeia. Primeiro traga o povo dos campos para a igreja; depois o socorro sobe do forte do rio, e é preciso ir buscar a aldeola de Santa Luzia.",
          "Algo caza en el bosque inundado alrededor de la aldea. Primero trae a la gente de los campos a la iglesia; luego el socorro sube del fuerte del río, y hay que ir a buscar la aldehuela de Santa Lucía."),
        T("Then lead everyone down the trail to the river fort. Men wade the flood slowly; the creatures do not.",
          "Depois leve todos pelo trilho até ao forte do rio. Os homens vadeiam a cheia devagar; as criaturas não.",
          "Luego lleva a todos por la senda hasta el fuerte del río. Los hombres vadean la crecida despacio; las criaturas no.")]},
    "swarm": {"still": "bell", "text": [
        T("The Tapajós, the wet season 2776. You are the swarm in the flooded forest: a forward Mother rooted on a mud bank, her two Sires and a pack.",
          "O Tapajós, a estação das chuvas de 2776. Você é o enxame na floresta alagada: uma Mãe avançada enraizada num banco de lama, os seus dois Sires e uma matilha.",
          "El Tapajós, la estación de lluvias de 2776. Eres el enjambre en el bosque inundado: una Madre adelantada enraizada en un banco de barro, sus dos Señores y una manada."),
        T("The village on the bluff has grain and people. Break its church, or catch more than half of its people before they reach the river fort down the trail.",
          "A aldeia no barranco tem grão e gente. Derrube a igreja, ou apanhe mais de metade do povo antes que chegue ao forte do rio no fundo do trilho.",
          "La aldea del barranco tiene grano y gente. Derriba su iglesia, o atrapa a más de la mitad de su gente antes de que llegue al fuerte del río al final de la senda.")]},
}
M["debrief"] = {
    "crown": {"still": "fields", "title": T("The River Fort", "O Forte do Rio", "El Fuerte del Río"),
              "text": T("{at_fort} of the {people_n} people of São Rafael reached the river fort.", "{at_fort} das {people_n} pessoas de São Rafael chegaram ao forte do rio.",
                        "{at_fort} de las {people_n} personas de San Rafael llegaron al fuerte del río."),
              "text_if": [
                  {"if": {"flag": {"fields": "burned"}}, "text": T("The fields and the granary were burned behind them.", "Os campos e o celeiro foram queimados atrás deles.",
                                                                   "Los campos y el granero fueron quemados detrás de ellos.")},
                  {"if": {"flag": {"fields": "left"}}, "text": T("The fields were left standing for their return. The swarm fed on them.", "Os campos ficaram de pé para o regresso deles. O enxame comeu deles.",
                                                                 "Los campos quedaron en pie para su regreso. El enjambre comió de ellos.")},
                  {"if": {"flag": {"forward": "killed"}}, "text": T("The forward Mother on the mud bank was killed.", "A Mãe avançada do banco de lama foi morta.",
                                                                    "La Madre adelantada del banco de barro fue muerta.")}]},
    "swarm": {"still": "bell", "title": T("The Flood", "A Cheia", "La Crecida"),
              "text": T("Of the {people_n} people of São Rafael, {dead_p} never reached the fort.", "Das {people_n} pessoas de São Rafael, {dead_p} nunca chegaram ao forte.",
                        "De las {people_n} personas de San Rafael, {dead_p} nunca llegaron al fuerte.")},
}


# ================================================================== the triggers
def wave(wid, when, at, to, base, delay=None, every=None, extra=(), line_ids=None, hunt=16):
    """A wave of the scripted swarm out of the flood at `at`: `base` Raptors (scaled by the difficulty), one more with d06
    `brood_n` all, one fewer with few (never under one), the `extra` spawns (with their own conditions); they go for the
    people within `hunt` tiles, else on to `to`."""
    sp = [{"spawn": {"team": "swarm", "kind": "raptor", "count": base, "at": at, "tag": "wave", "tags": [wid],
                     "order": {"do": "attack", "to": to}, "if": NOT_FEW}},
          {"spawn": {"team": "swarm", "kind": "raptor", "count": max(1, base - 1), "at": at, "tag": "wave", "tags": [wid],
                     "order": {"do": "attack", "to": to}, "if": B_FEW}},
          {"spawn": {"team": "swarm", "kind": "raptor", "count": 1, "at": at, "tag": "wave", "tags": [wid], "fixed": True,
                     "order": {"do": "attack", "to": to}, "if": B_ALL}}]
    for (k, n, c) in extra:
        e = {"team": "swarm", "kind": k, "count": n, "at": at, "tag": "wave", "tags": [wid], "fixed": True, "order": {"do": "attack", "to": to}}
        if c is not None:
            e["if"] = c
        sp.append({"spawn": e})
    t = {"id": wid, "when": when, "do": sp + [{"ping": {"area": at}}] + ([{"say": line_ids}] if line_ids else [])}
    if delay is not None:
        t["delay"] = delay
    if every is not None:
        t["every"] = every
    return t


def road_extra(i):
    """The column's wave i: a Raptor more from the third wave while the forward Mother lives, another from the fifth; one
    more while the fields feed them (LEFT); a Tyrant Challenger from the fourth (NORMAL, HARD)."""
    alive = {"not": {"dead": "fwd_mother"}}
    ex = [("raptor", 1, {"flag": {"fields": "left"}})]
    if i >= 2:
        ex.append(("raptor", 1, alive))
    if i >= 4:
        ex.append(("raptor", 1, alive))
    if i >= 2:
        ex.append(("tyrant_challenger", 1, {"difficulty": ["normal", "hard"]}))
    return ex


TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"counter": {"name": "people_n", "count": {"tag": "people"}}},
        {"counter": {"name": "field_n", "count": {"tag": "field_folk"}}},
        {"counter": {"name": "hamlet_n", "count": {"tag": "hamlet_folk"}}},
        {"counter": {"name": "half", "share_of": "people_n", "share": 0.5}},
        # (the hamlet's people are shut in their chapel: nothing reaches them until your men come)
        {"spare": {"tag": "hamlet_folk", "on": True}}, {"spare": {"tag": "chapel", "on": True}},
        # (the people carry their things: they walk slower than a soldier)
        {"pace": {"tag": "people", "pace": PEOPLE_RUN}},
        # (the old ones by the church kneel in the yard)
        {"order": {"tag": "village_folk", "do": "hold"}},
        # (the fields and the granary are spared by the creatures' teeth: only THE CHOICE's fire takes them)
        {"spare": {"tag": "fields_b", "on": True}}]},
    {"id": "setup_crown", "when": {"all": [{"time": 0.6}, NO_SWARM]}, "do": [
        {"clock": {"name": "night", "secs": NIGHT_SECS}}]},
    # the swarm played (the solo pick, versus p2): the forward Mother rooted on the mud bank with her Sires, from the start
    {"id": "setup_swarm", "when": {"all": [{"time": 0.6}, SWARM]}, "do": [
        {"brood_stage": {"tag": "fwd_mother", "stage": 2}},
        {"nest_free": {"tag": "sires", "on": True}},
        {"root_now": {"tag": "fwd_mother"}}, {"root_now": {"tag": "sires"}},
        # (the swarm's objectives only when it is played: in the Crown's game its forward Mother may die without ending it)
        {"objective": {"id": "s_mother", "set": "active"}}, {"objective": {"id": "s_hunt", "set": "active"}},
        {"objective": {"id": "night", "set": "hidden"}}]},
    {"id": "swarm_food", "when": {"all": [{"time": 10}, SWARM, LIVE]}, "every": 10, "do": [{"give": {"team": "swarm", "gold": SWARM_FOOD}}]},
    {"id": "intro_s", "when": {"all": [{"time": 1.5}, SWARM]}, "do": [{"say": ["f_1", "f_2"]}, {"ping": {"area": "village"}}]},
    # ============================================================ PART 1: THE FIRST NIGHT
    {"id": "bell", "when": {"time": 2.0}, "do": [
        {"say": ["t_bell", "ti_bell", "n_lesson"]}, {"sound": {"name": "campaign/bell_toll", "area": "church_yard", "vol": -4}},
        {"ping": {"area": "field_w"}}, {"ping": {"area": "field_n"}}, {"ping": {"area": "field_r"}}]},
    {"id": "varzea_say", "when": {"all": [{"time": 24}, CROWN]}, "do": [{"say": ["n_varzea"]}]},
] + [
    # a soldier or Tomasz reaches a field: its people run for the church (again every few seconds while any is out)
    t for (tg, fa) in [("folk_w", "field_w"), ("folk_n", "field_n"), ("folk_r", "field_r")] for t in [
        {"id": "call_" + fa, "when": {"all": [{"fired": "bell"}, {"near": {"team": "mission", "to": tg, "within": FIELD_CALL}}, LIVE]},
         "do": [{"order": {"tag": tg, "do": "move", "to": "church_yard"}}, {"say": ["t_field"]}, {"ping": {"area": fa}}]},
        {"id": "run_" + fa, "when": {"all": [{"fired": "call_" + fa}, {"count": {"tag": tg, "not_area": "church_yard", "at_least": 1}}, P1, LIVE]},
         "delay": 4, "every": 4, "do": [{"order": {"tag": tg, "do": "move", "to": "church_yard"}}]},
    ]
] + [
    # the mirror's village: the bell is heard (the people come in by themselves); the militia hold the bluff
    {"id": "m_bell", "when": {"all": [{"time": 12}, NO_CROWN]}, "do": [
        {"order": {"tag": "field_folk", "do": "move", "to": "church_yard"}}, {"order": {"tag": "militia", "do": "attack", "to": "bluff_s"}}]},
    {"id": "m_bell2", "when": {"all": [{"fired": "m_bell"}, {"count": {"tag": "field_folk", "not_area": "church_yard", "at_least": 1}}, {"not": {"fired": "part3"}}, LIVE]},
     "delay": 5, "every": 5, "do": [{"order": {"tag": "field_folk", "do": "move", "to": "church_yard"}}]},
    {"id": "count_in", "when": {"all": [{"time": 1}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "sheltered", "count": {"tag": "field_folk", "area": "church_yard"}}},
        {"counter": {"name": "hamlet_in", "count": {"tag": "hamlet_folk", "area": "church_yard"}}},
        # (the swarm's tally: the people caught = all, less the living, less those at the fort)
        {"counter": {"name": "alive_p", "count": {"tag": "people"}}},
        {"counter": {"name": "dead_p", "share_of": "people_n", "share": 1.0}},
        {"counter": {"name": "dead_p", "sub_counter": "alive_p", "min": 0}},
        {"counter": {"name": "dead_p", "sub_counter": "at_fort", "min": 0}},
        {"counter": {"name": "margin", "share_of": "dead_p", "share": 1.0}},
        {"counter": {"name": "margin", "sub_counter": "half", "min": 0}},
        {"counter": {"name": "hatch_left", "count": {"tag": "hatch"}}}]},
    # the night's waves (the swarm scripted): the west field, the north field, the river field, then the bluff
    wave("w1", {"all": [{"time": 20}, NO_SWARM, P1, LIVE]}, "flood_w", "field_w", 3, line_ids=["n_w1", "ti_w1"]),
    wave("w2", {"all": [{"time": 45}, NO_SWARM, P1, LIVE]}, "flood_n", "field_n", 3, line_ids=["n_w2"]),
    wave("w3", {"all": [{"time": 70}, NO_SWARM, P1, LIVE]}, "flood_e", "field_r", 3, line_ids=["n_w3"],
         extra=[("tyrant_challenger", 1, {"difficulty": ["normal", "hard"]})]),
    {"id": "all_in", "when": {"all": [{"time": 6}, P1, {"count": {"tag": "field_folk", "not_area": "church_yard", "below": 1}}, LIVE]}, "do": [
        {"objective": {"id": "fields_in", "set": "done"}}, {"say": ["ti_in"]}]},
    # the push on the bluff: at 1:40, or soon after everyone is in (NO WAITING)
    wave("w_push", {"all": [NO_SWARM, P1, LIVE, {"any": [{"time": 100}, {"all": [{"fired": "all_in"}, {"fired": "w2"}]}]}]}, "flood_n", "church_yard", 5,
         delay=6, line_ids=["n_push", "t_pray"], extra=[("raptor", 2, None)]),
    {"id": "swarm_hunt", "when": {"all": [{"time": 21}, NO_SWARM, P1, LIVE]}, "every": 3, "do": [
        {"order": {"team": "swarm", "do": "hunt", "prey": "people", "within": 14, "idle": True}}]},
    {"id": "swarm_press", "when": {"all": [{"time": 30}, NO_SWARM, P1, LIVE]}, "every": 9, "do": [
        {"order": {"tag": "wave", "do": "attack", "to": "church_yard", "idle": True}}]},
    # DAWN: everyone in and the bluff clear after the push, or the night's clock out
    {"id": "dawn_clear", "when": {"all": [{"fired": "w_push"}, {"fired": "all_in"}, {"count": {"tag": "wave", "below": 1}}, P1, NO_SWARM, LIVE]},
     "delay": 3, "do": [{"clock": {"name": "night", "add": -9000}}]},
    {"id": "dawn_late", "when": {"all": [{"clock_out": "night"}, {"not": {"fired": "all_in"}}, P1, NO_SWARM, LIVE]}, "do": [
        {"say": ["n_dawn_late"]}, {"objective": {"id": "fields_in", "set": "failed"}},
        {"order": {"tag": "field_folk", "do": "move", "to": "church_yard"}}]},
    # ============================================================ PART 2: THE RELIEF
    {"id": "part2", "when": {"all": [{"any": [{"all": [{"clock_out": "night"}, NO_SWARM]}, {"all": [{"time": MIRROR_P2}, SWARM]}]}, LIVE]}, "do": [
        {"clock": {"name": "night", "stop": True}}, {"objective": {"id": "night", "set": "hidden"}},
        {"objective": {"id": "fields_in", "set": "hidden"}},
        {"light": {"to": "grey_dawn", "secs": 6}},
        # the relief rides in up the trail: on the player's team (THE ROSTER LADDER's C6: the Dragoon, the Horsemen for the Charge)
        {"spawn": {"team": "mission", "kind": "cuirassier", "as": "sobral", "count": 1, "at": "relief_in", "tag": "sobral", "tags": ["relief_men"], "fixed": True, "if": CROWN}},
        {"spawn": {"team": "mission", "kind": "dragoon", "count": 4, "at": "relief_in", "tag": "relief_men", "fixed": True, "if": {"all": [CROWN, NOT_GOLD_FEW]}}},
        {"spawn": {"team": "mission", "kind": "dragoon", "count": 2, "at": "relief_in", "tag": "relief_men", "fixed": True, "if": {"all": [CROWN, GOLD_FEW]}}},
        {"spawn": {"team": "mission", "kind": "cuirassier", "count": 3, "at": "relief_in", "tag": "relief_men", "fixed": True, "if": CROWN}},
        # (the mirror's or versus' village scripted: the relief is the computer's too)
        {"spawn": {"team": "mission", "kind": "cuirassier", "as": "sobral", "count": 1, "at": "relief_in", "tag": "sobral", "tags": ["relief_men"], "fixed": True, "if": NO_CROWN}},
        {"spawn": {"team": "mission", "kind": "dragoon", "count": 4, "at": "relief_in", "tag": "relief_men", "fixed": True, "if": NO_CROWN}},
        {"spawn": {"team": "mission", "kind": "cuirassier", "count": 3, "at": "relief_in", "tag": "relief_men", "fixed": True, "if": NO_CROWN}},
        {"give": {"team": "mission", "gold": RELIEF_GOLD}},
        {"ping": {"area": "relief_in"}},
        # the hamlet: a pack round the chapel at Santa Luzia
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 7, "at": "hamlet", "tag": "hamlet_pack", "tags": ["wave"],
                   "order": {"do": "attack", "to": "hamlet_in"}, "if": NO_SWARM}},
        {"spawn": {"team": "swarm", "kind": "tyrant_challenger", "count": 1, "at": "hamlet", "tag": "hamlet_pack", "tags": ["wave"], "fixed": True,
                   "order": {"do": "attack", "to": "hamlet_in"}, "if": {"all": [NO_SWARM, NOT_FEW]}}},
        {"objective": {"id": "hamlet", "set": "active"}}, {"objective": {"id": "hamlet_clock", "set": "active"}},
        {"clock": {"name": "hamlet", "secs": HAMLET_SECS}}, {"ping": {"area": "hamlet"}}]},
    {"id": "p2_light", "when": {"fired": "part2"}, "delay": 30, "do": [{"light": {"to": "jungle_day", "secs": 20}}]},
    {"id": "p2_say", "when": {"fired": "part2"}, "delay": 1, "do": [{"say": ["t_dawn", "n_relief", "c_arrive"]}]},
    {"id": "p2_small", "when": {"all": [{"fired": "part2"}, GOLD_FEW]}, "delay": 8, "do": [{"say": ["c_small"]}]},
    {"id": "p2_hamlet", "when": {"all": [{"fired": "part2"}, CROWN]}, "delay": 9, "do": [{"say": ["t_hamlet", "ti_hamlet", "n_hamlet"]}]},
    {"id": "p2_charge", "when": {"all": [{"fired": "part2"}, CROWN]}, "delay": 24, "do": [
        {"say": ["c_charge", "n_charge"]}, {"objective": {"id": "charge", "set": "active"}}, {"ping": {"tag": "breeder"}}]},
    {"id": "charged", "when": {"all": [{"fired": "part2"}, {"researched": {"team": "mission", "tech": "charge"}}, CROWN]}, "do": [
        {"objective": {"id": "charge", "set": "done"}}, {"say": ["n_charged"]}]},
    {"id": "s_relief", "when": {"all": [{"fired": "part2"}, SWARM]}, "delay": 1, "do": [{"say": ["f_relief"]}]},
    # the mirror: the relief rides to the hamlet by itself
    {"id": "m_relief", "when": {"all": [{"fired": "part2"}, NO_CROWN]}, "delay": 4, "every": 10, "times": 12, "do": [
        {"order": {"tag": "relief_men", "do": "attack", "to": "hamlet", "idle": True}}]},
    # the flyers over the village (the swarm scripted): where they circle, the pack follows
    {"id": "hatch", "when": {"all": [{"fired": "part2"}, NO_SWARM, LIVE]}, "delay": 30, "do": [
        {"spawn": {"team": "swarm", "kind": "hatchlings", "count": 6, "at": "flood_nw", "tag": "hatch", "order": {"do": "patrol", "to": "village"}}},
        {"say": ["n_hatch", "c_hatch"]}, {"objective": {"id": "hatch", "set": "active", "if": CROWN}}, {"ping": {"area": "village"}}]},
    {"id": "hatch_circle", "when": {"all": [{"fired": "hatch"}, {"count": {"tag": "hatch", "at_least": 1}}, LIVE]}, "delay": 8, "every": 12, "do": [
        {"order": {"tag": "hatch", "do": "move", "to": "village", "idle": True}}]},
    {"id": "hatch_down", "when": {"all": [{"fired": "hatch"}, {"dead": "hatch"}, LIVE]}, "do": [
        {"objective": {"id": "hatch", "set": "done"}}, {"say": ["n_hatch_down"]}]},
    # a few come up at the village while the riders are away (NO WAITING for the men left on the bluff)
    wave("w_probe", {"all": [{"fired": "part2"}, NO_SWARM, P2, LIVE]}, "flood_n", "church_yard", 3, delay=55, line_ids=["n_probe"]),
    # the hamlet freed: one of yours there and none of the pack in it: its people come out and follow back
    {"id": "hamlet_free", "when": {"all": [{"fired": "part2"}, {"near": {"team": "mission", "to": "hamlet_folk", "within": 7}},
                                           {"count": {"team": "swarm", "area": "hamlet", "below": 1}}, LIVE]}, "do": [
        {"spare": {"tag": "hamlet_folk", "on": False}}, {"spare": {"tag": "chapel", "on": False}},
        {"order": {"tag": "hamlet_folk", "do": "move", "to": "church_yard"}}, {"say": ["n_free", "ti_found"]},
        {"clock": {"name": "hamlet", "stop": True}}, {"objective": {"id": "hamlet_clock", "set": "hidden"}}]},
    {"id": "hamlet_run", "when": {"all": [{"fired": "hamlet_free"}, {"count": {"tag": "hamlet_folk", "not_area": "church_yard", "at_least": 1}}, P2, LIVE]},
     "delay": 4, "every": 4, "do": [{"order": {"tag": "hamlet_folk", "do": "move", "to": "church_yard"}}]},
    # on the way back the pack comes at the causeway out of the flood; more of them while the flyers still circle
    wave("w_flank", {"all": [{"fired": "hamlet_free"}, NO_SWARM, P2, LIVE]}, "flood_cw", "causeway", 3, delay=8,
         extra=[("raptor", 3, {"count": {"tag": "hatch", "at_least": 1}})]),
    {"id": "flank_say", "when": {"all": [{"fired": "w_flank"}, {"count": {"tag": "hatch", "at_least": 1}}]}, "do": [{"say": ["n_flank"]}]},
    # the chapel's clock out: the pack breaks in; nobody comes out
    {"id": "hamlet_late", "when": {"all": [{"clock_out": "hamlet"}, {"not": {"fired": "hamlet_free"}}, LIVE]}, "do": [
        {"say": ["n_hamlet_late"]}, {"spare": {"tag": "hamlet_folk", "on": False}}, {"spare": {"tag": "chapel", "on": False}},
        {"hurt": {"tag": "hamlet_folk", "amount": 9999}}, {"objective": {"id": "hamlet", "set": "failed"}}]},
    {"id": "hamlet_back", "when": {"all": [{"fired": "hamlet_free"}, {"count": {"tag": "hamlet_folk", "not_area": "church_yard", "below": 1}}, P2, LIVE]}, "do": [
        {"objective": {"id": "hamlet", "set": "done"}}, {"say": ["ti_back"]}]},
    # ============================================================ PART 3: THE ROAD TO THE FORT
    {"id": "part3", "when": {"all": [{"fired": "part2"}, {"any": [{"fired": "hamlet_back"}, {"fired": "hamlet_late"},
                                                                 {"all": [{"time": MIRROR_P3}, NO_CROWN]}]}, LIVE]}, "delay": 3, "do": [
        {"objective": {"id": "hamlet", "set": "hidden"}}, {"objective": {"id": "hamlet_clock", "set": "hidden"}},
        {"objective": {"id": "charge", "set": "hidden"}}, {"objective": {"id": "hatch", "set": "hidden"}},
        {"objective": {"id": "church_live", "set": "done"}},
        {"objective": {"id": "road", "set": "active"}}, {"objective": {"id": "column", "set": "active"}},
        {"clock": {"name": "column", "secs": COLUMN_SECS}},
        # every one of the people follows Tomasz (the player walks him down the trail)
        {"order": {"tag": "people", "do": "follow", "leader": "tomasz", "within": 3}},
        {"pace": {"tag": "people", "pace": PEOPLE_PACE}},
        {"say": ["c_cannot", "t_go", "n_road"]}, {"ping": {"area": "trail_1"}}, {"ping": {"area": "fort_in"}},
        {"reveal": {"area": "fort", "side": "crown"}}]},
    # the forward Mother roots on the mud bank (the swarm scripted): while she lives the waves grow
    {"id": "fwd_root", "when": {"all": [{"fired": "part3"}, NO_SWARM]}, "do": [
        {"spawn": {"team": "swarm", "kind": "brood_mother", "as": "forward_mother", "count": 1, "at": "mother_spot", "tag": "fwd_mother", "fixed": True}},
        {"spawn": {"team": "swarm", "kind": "tyrannosaur", "count": 1, "at": "sire_spot", "tag": "fwd_sire", "tags": ["sires"], "fixed": True}},
        {"ping": {"area": "mud_bank"}}]},
    {"id": "fwd_root2", "when": {"fired": "fwd_root"}, "delay": 0.5, "do": [
        {"brood_stage": {"tag": "fwd_mother", "stage": 2}}, {"nest_free": {"tag": "sires", "on": True}},
        {"root_now": {"tag": "fwd_mother"}}, {"root_now": {"tag": "fwd_sire"}}]},
    {"id": "fwd_say", "when": {"all": [{"fired": "fwd_root"}, CROWN]}, "delay": 14, "do": [
        {"say": ["n_mother"]}, {"objective": {"id": "fwd", "set": "active"}}, {"ping": {"area": "mud_bank"}},
        {"reveal": {"area": "mud_bank", "side": "crown", "secs": 40}}]},
    {"id": "fwd_sire_say", "when": {"all": [{"fired": "fwd_say"}, SIRE_ALL]}, "delay": 8, "do": [{"say": ["c_sire"]}]},
    {"id": "lead_say", "when": {"all": [{"fired": "part3"}, CROWN]}, "delay": 8, "do": [{"say": ["t_lead"]}]},
    # the mirror: the scripted village walks the trail by itself (Tomasz first, the soldiers alongside)
    {"id": "m_road", "when": {"all": [{"fired": "part3"}, NO_CROWN]}, "delay": 2, "do": [
        {"order": {"tag": "tomasz", "do": "route", "route": TRAIL, "name": "m_tomasz"}},
        {"order": {"tag": "militia", "do": "follow", "leader": "tomasz", "within": 4, "fight": 6}},
        {"order": {"tag": "relief_men", "do": "follow", "leader": "tomasz", "within": 5, "fight": 8}},
        {"order": {"tag": "tiago", "do": "follow", "leader": "tomasz", "within": 3}},
        {"say": ["f_road"]}]},
    # THE CHOICE, THE FIELDS (the Crown's player: the panel; else LEFT, the canon)
    {"id": "fields_ask", "when": {"fired": "part3"}, "delay": 16, "do": [
        {"say": ["c_burn", "t_bread", "ti_choose"]},
        {"choice": {"id": "fields", "side": "crown", "title": T("THE FIELDS", "OS CAMPOS", "LOS CAMPOS"),
                    "line": "q_fields",
                    "default": "left", "time": 60,
                    "options": [
                        {"id": "burned", "label": T("BURN THEM", "QUEIMÁ-LOS", "QUEMARLOS"),
                         "about": T("The swarm finds nothing to eat here: its waves come no bigger. The people come home to ashes.",
                                    "O enxame não acha aqui nada para comer: as suas vagas não crescem. O povo volta a casa para cinzas.",
                                    "El enjambre no encuentra aquí nada que comer: sus oleadas no crecen. El pueblo vuelve a casa a las cenizas."),
                         "do": [{"say": ["t_burned", "n_burned"]}, {"burn": {"tag": "fields_b", "secs": 25, "douse_side": "swarm", "douse_secs": 99999}}]},
                        {"id": "left", "label": T("LEAVE THEM", "DEIXÁ-LOS", "DEJARLOS"),
                         "about": T("The people's bread for their return. The swarm will feed on it: its waves come bigger.",
                                    "O pão do povo para o regresso. O enxame vai comer dele: as suas vagas vêm maiores.",
                                    "El pan del pueblo para su regreso. El enjambre comerá de él: sus oleadas vienen mayores."),
                         "do": [{"say": ["t_left"]}]}]}}]},
    {"id": "fed_say", "when": {"all": [{"flag": {"fields": "left"}}, CROWN, P3]}, "delay": 30, "do": [{"say": ["n_fed"]}]},
    # the waves on the column: out of the flood beside the trail, every WAVE_EVERY s; bigger while the forward Mother lives
    # (one more from the third wave, another from the fifth; a Tyrant Challenger from the third) and while the fields feed them (left)
] + [
    wave("w_road_%d" % i, {"all": [{"fired": "part3"}, NO_SWARM, LIVE]}, WAVE_AT[i % len(WAVE_AT)], TRAIL[min(1 + i, 6)], 4,
         delay=12 + i * WAVE_EVERY, every=(WAVE_EVERY * len(WAVE_AT) if i < len(WAVE_AT) else None),
         extra=road_extra(i))
    for i in range(len(WAVE_AT))
] + [
    {"id": "w_road_say", "when": {"fired": "w_road_0"}, "do": [{"say": ["n_wave"]}]},
    {"id": "road_hunt", "when": {"all": [{"fired": "part3"}, NO_SWARM, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "wave", "do": "hunt", "prey": "people", "within": 22}}]},
    {"id": "fwd_dead", "when": {"all": [{"fired": "fwd_root"}, {"dead": "fwd_mother"}, LIVE]}, "do": [
        {"objective": {"id": "fwd", "set": "done"}}, {"say": ["c_mother_dead"]}, {"flag": {"forward": "killed"}}]},
    {"id": "fort_first", "when": {"counter": {"name": "at_fort", "at_least": 1}}, "do": [{"say": ["n_fort"]}]},
    {"id": "tomasz_hurt", "when": {"all": [{"hp": {"tag": "tomasz", "below": 0.6}}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["t_hurt"]}, {"ping": {"tag": "tomasz"}}]},
    # ============================================================ THE END (the Crown)
    # everyone at the fort (or fallen on the way), or the gate shut at dusk
    {"id": "road_done", "when": {"all": [P3, {"any": [{"count": {"tag": "people", "below": 1}}, {"clock_out": "column"}]}, LIVE]}, "do": [
        {"say": ["n_gate"]}, {"clock": {"name": "column", "stop": True}},
        {"tally": {"flag": "aldeia", "counter": "at_fort", "of": "people_n", "bands": [[0, "few"], [0.4, "some"], [0.7, "many"]]}},
        {"flag": {"fields": "left", "if": {"not": {"flag": {"fields": "burned"}}}}},
        {"flag": {"forward": "rooted", "if": {"not": {"flag": {"forward": "killed"}}}}}]},
    {"id": "the_end", "when": {"all": [{"fired": "road_done"}, {"counter": {"name": "at_fort", "at_least": 1}}, {"not": {"fired": "s_won"}}]}, "delay": 3, "do": [
        {"objective": {"id": "road", "set": "done"}}, {"win": "crown"}]},
    # the gate shut at dusk with nobody inside: lost
    {"id": "lost_road", "when": {"all": [{"fired": "road_done"}, {"counter": {"name": "at_fort", "below": 1}}, {"not": {"fired": "s_won"}}]}, "delay": 3, "do": [
        {"objective": {"id": "road", "set": "failed"}}]},
    {"id": "lost_all", "when": {"all": [{"fired": "setup"}, {"count": {"tag": "people", "below": 1}}, {"counter": {"name": "at_fort", "below": 1}},
                                        {"not": {"fired": "s_won"}}, {"not": {"fired": "the_end"}}]}, "delay": 1, "do": [
        {"say": ["n_all_lost"]}, {"objective": {"id": "road", "set": "failed"}}, {"lose": "crown"}]},
    {"id": "lost_church", "when": {"all": [{"dead": "church"}, {"not": {"fired": "part3"}}, NO_SWARM, {"not": {"fired": "s_won"}}]}, "do": [
        {"say": ["n_church_down"]}, {"objective": {"id": "church_live", "set": "failed"}}]},
    # ============================================================ THE SWARM (the solo pick, versus)
    {"id": "s_won", "when": {"all": [SWARM, {"any": [{"dead": "church"}, {"counter": {"name": "margin", "at_least": 1}}]},
                                     {"not": {"fired": "the_end"}}, {"not": {"fired": "s_lost"}}]}, "do": [
        {"say": ["f_won"]}, {"objective": {"id": "s_hunt", "set": "done"}}, {"flag": {"aldeia": "few"}}, {"flag": {"fields": "left"}},
        {"win": "swarm"}]},
    {"id": "s_lost", "when": {"all": [SWARM, {"fired": "road_done"}, {"not": {"fired": "s_won"}}]}, "do": [
        {"say": ["f_lost"]}, {"objective": {"id": "s_hunt", "set": "failed"}}]},
    {"id": "s_mother", "when": {"all": [SWARM, {"dead": "fwd_mother"}, {"fired": "setup_swarm"}]}, "do": [{"say": ["f_mother_dead"]}]},
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

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the mission is bound to C6, THE DRAGOON and THE CAVALRY CHARGE; the
# story's refusals on top (a mission village and a river fort: nothing new is built, no workers, no guns)
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID, story_deny={"mission": ["town_hall", "cottage", "farm", "wall", "gate", "labourer", "messenger", "foundry",
                                                    "mortar", "church", "powder_mill", "barracks", "horse_breeder", "armoury", "cannon"]})
for k in ("dragoon", "charge"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hub talks after d05 (campaign/campaign.json), the engine's refusal
OTHER = [
    ("Father Tomasz", "Padre Tomasz", "Padre Tomasz"),
    ("Brother Tiago", "Irmão Tiago", "Hermano Tiago"),
    ("Captain Sobral", "Capitão Sobral", "Capitán Sobral"),
    ("The forward Mother", "A Mãe avançada", "La Madre adelantada"),
    ("Father Tomasz at his mission of São Rafael on the Tapajós.", "O Padre Tomasz na sua missão de São Rafael, no Tapajós.",
     "El Padre Tomasz en su misión de San Rafael, en el Tapajós."),
    ("The catechist of São Rafael, a son of the village: he teaches in his own tongue.", "O catequista de São Rafael, um filho da aldeia: ensina na sua própria língua.",
     "El catequista de San Rafael, un hijo de la aldea: enseña en su propia lengua."),
    ("A militiaman of the mission, armed by the Crown in 2773.", "Um miliciano da missão, armado pela Coroa em 2773.", "Un miliciano de la misión, armado por la Corona en 2773."),
    ("A villager of São Rafael.", "Um aldeão de São Rafael.", "Un aldeano de San Rafael."),
    ("Captain Duarte Sobral, commanding the river fort on the Tapajós.", "Capitão Duarte Sobral, comandante do forte do rio no Tapajós.",
     "Capitán Duarte Sobral, al mando del fuerte del río en el Tapajós."),
    ("A Brood Mother rooted on a mud bank in the flooded forest.", "Uma Mãe da Ninhada enraizada num banco de lama na floresta alagada.",
     "Una Madre de la Prole enraizada en un banco de barro en el bosque inundado."),
    ("Not in the flooded forest: nothing stands in the várzea's water.", "Não na floresta alagada: nada fica de pé na água da várzea.",
     "No en el bosque inundado: nada se sostiene en el agua de la várzea."),
    # the King's study after d05
    ("Tomasz wrote from the river fort. He brought them out of São Rafael, and asked me for nothing but a priest for the fort.",
     "Tomasz escreveu do forte do rio. Tirou-os de São Rafael, e só me pediu um padre para o forte.",
     "Tomasz escribió desde el fuerte del río. Los sacó de San Rafael, y solo me pidió un sacerdote para el fuerte."),
    ("He left the fields standing. My soldiers paid for that bread for years. I would have done the same.",
     "Deixou os campos de pé. Os meus soldados pagaram esse pão durante anos. Eu teria feito o mesmo.",
     "Dejó los campos en pie. Mis soldados pagaron ese pan durante años. Yo habría hecho lo mismo."),
    ("He burned the fields behind them. He confesses it every year. It was hard, and it was his to choose.",
     "Queimou os campos atrás deles. Confessa-o todos os anos. Foi duro, e a escolha era dele.",
     "Quemó los campos detrás de ellos. Lo confiesa cada año. Fue duro, y la elección era suya."),
    ("On the Tapajós I learnt that the swarm does not hate anyone. It eats. That is worse.",
     "No Tapajós aprendi que o enxame não odeia ninguém. Come. Isso é pior.", "En el Tapajós aprendí que el enjambre no odia a nadie. Come. Eso es peor."),
    ("Tiago still writes to me from the fort. He says the children have stopped looking into the water.",
     "O Tiago ainda me escreve do forte. Diz que as crianças deixaram de olhar para a água.", "Tiago todavía me escribe desde el fuerte. Dice que los niños han dejado de mirar al agua."),
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
rows = ["# Act 2's mission d05_aldeia, \"The Mission of São Rafael\" (campaign/missions/d05_aldeia.json, written with its texts by",
        "# tools/campaign/make_d05_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what was",
        "# built: docs/campaign_d05_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: swarm = enxame / enjambre; várzea =",
        "# várzea / várzea (the flooded forest: floresta alagada / bosque inundado); hamlet = aldeola / aldehuela; river fort = forte do rio /",
        "# fuerte del río; Brood Mother = Mãe da Ninhada / Madre de la Prole.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
