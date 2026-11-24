#!/usr/bin/env python3
"""Writes campaign/missions/d08_rivers.json: Act 2's "Down the Rivers" (the Naturalist line after d06_queen, the Rio
Negro in the floods of 2778; the plan: docs/campaign_act2_plan.md "d08_rivers"; what was built:
docs/campaign_d08_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d08_rivers.txt: every text here is
written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d08_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_barra_rivers_map.py (campaign:barra_rivers). EVERY LINE IS A PLACEHOLDER for the owner.

THE BROOD IS NOT A PERSON (owner 2026-11-19 / 2026-11-22 / 2026-11-24): the swarm is animals coming down the rivers in
the floods. People (Valadares, Benedito, the sergeant) may name what they see; no creature gets a reason, a want or a
plan. Valadares narrates from his report (as in a03); the King frames it.
  THE BARRA (Crown, PURPLE, p1): Valadares (a hero: wounded, not killed), the column (Musketeers and two Dragoons), the
    garrison, two Field Cannons on the bluff, five Labourers, the Town Hall, the church, a Barracks, two Farms, a Powder
    Mill and the lower town's quarters (cottages); Benedito and NAZARÉ'S PEOPLE (YELLOW, scripted: 6 / 10 / 14 by b01
    `saved` few / some / many).
  THE SWARM (Brood, GREEN): scripted in the solo game (the waves); the SOLO PICK; versus p2. Bound to THE ROSTER LADDER's
    B6 (BIGGER CLUTCH, PACK HUNT, QUICK ROOTS).
  PART 1, NAZARÉ: the column goes up the bank trail; a man walked up to each group (the chapel, the houses, the fields)
    sends it to Benedito's canoes on the beach; raiders come over the rapids for the people; a countdown: the forward
    Mother across the river ROOTS, and a big raid comes. The canoes cast off when every group is away (or 30 s after).
  PART 2, THE BLUFF: the column hurries home; five waves over the shallows (the Barra shallows into the lower town, the
    middle shallows down the bank trail); two more forward Mothers walk down the far bank to root, each rooted one is
    more creatures in every wave (cross the shallows and kill one while she walks); their ground creeps (the swamp
    spreading from each one rooted).
  PART 3, THE LURE BOOK: dusk; Benedito brings the book found in the fazenda's ruins (d06 `book`); THE CHOICE: BURN IT
    (Rome's order: the whole great wave on the Barra) or USE IT ONCE (a lure post on the far point: half the great wave
    turns into the flooded forest and drowns its own road). Night, the great wave; break it, or hold till first light.
  CARRIES: `lure` burned / used (the choice; canon BURNED), `barra` held / burned (the lower town's quarters standing),
    `nazare` few / some / all (the people brought out).
  MIRROR (THE SWARM, solo pick; versus): two forward Mothers (one rooted opposite Nazaré, one on the far bank's middle),
    the Sires, raiders; catch Nazaré's people, root a Mother opposite the Barra, BREAK THE BARRA (the bluff's two guns and
    the church) before the floods fall. A swarm win: the Barra lost (a broken seal on the war map; a RECLAIM PART in d10).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d08_rivers"

TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d08_rivers.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
S_FEW = past("b01_specimen.saved", "few")                  # Nazaré's people: 6 / 10 / 14
S_MANY = past("b01_specimen.saved", "many")
NOT_S_FEW = {"not": S_FEW}
DRAWN = notpast("a03_plateau.map", "withheld")              # Valadares knows the swarm's road (the canon: drawn)
WITHHELD = past("a03_plateau.map", "withheld")
PARTY_FEW = past("a03_plateau.party", "few")
LINNEA_SEEN = notpast("a03_plateau.linnea", "unseen")       # (a03 always sets it "seen")
BURNED_CLUTCH = past("b01_specimen.clutch", "burned")       # the swarm one smaller
NOT_BURNED_CLUTCH = {"not": BURNED_CLUTCH}
BN_FEW = past("d06_queen.brood_n", "few")                   # the Queen's swarm: smaller / bigger waves
BN_ALL = past("d06_queen.brood_n", "all")
NOT_BN_FEW = {"not": BN_FEW}
BOOK_TAKEN = past("d06_queen.book", "taken")               # the fazenda's win: Lindqvist carried the book away
BOOK_LEFT = {"not": BOOK_TAKEN}
BARRA = {"playing": "barra"}
NO_BARRA = {"not": BARRA}
SWARM = {"playing": "swarm"}
NO_SWARM = {"not": SWARM}
SOLO_B = {"all": [BARRA, NO_SWARM]}                          # the solo Barra: the waves and the choice are scripted
ENDED = [{"fired": "the_end"}, {"fired": "s_end"}]
LIVE = {"not": {"any": ENDED}}
P1 = {"not": {"fired": "part2"}}

# ---------------------------------------------------------------- numbers
NAZARE_SECS = 150          # Part 1: the forward Mother across the river roots (NORMAL; EASY x1.25, HARD x0.85)
CANOE_WAIT = 30            # ... the canoes wait this long after that
RAIDS = [30, 75, 130]     # Part 1: raiders over the rapids for the people
CALL_SECS = 3              # a man of the Barra standing this long by a group sends it to the canoes
VILL_PACE = 0.7            # the people walk slowly with their bundles
MOTHER_PACE = 0.8          # a forward Mother walking down the far bank (slow: time to catch her)
WAVE_AT = [45, 105, 165, 225, 285]     # Part 2: the waves, seconds after its start
FWD_M_AT, FWD_S_AT = 5, 70             # the forward Mothers set off down the far bank
GREAT_GO = 20              # Part 3: the great wave goes this long after it gathers
DAWN_SECS = 180            # Part 3: first light (scaled)
FLOODS_SECS = 1200         # the mirror / versus: the floods fall (scaled)
LURE_R = 25
HELD_SHARE = 0.75          # the lower town's quarters standing: held
NAZ_SOME, NAZ_ALL = 0.5, 0.9
SWARM_FOOD, SWARM_SPOILS = 300, 60     # the mirror: the swarm's food to start
FLOOD_FOOD, FLOOD_SPOILS = 40, 4       # ... and every 10 s while the floods are up (the drowned game on the far bank)
CHURCH_HP = 2400           # the church in the mirror (stone)
GUN_HP = 900               # the bluff's guns (Field Cannons) in the mirror: a little harder than a field gun

# ================================================================== the areas (x, y, w, h in cells)
areas = dict(
    # the far bank (the swarm's side)
    fb_n=[6, 3, 12, 9], fb_n_spot=[11, 6, 3, 3], fb_m=[8, 36, 12, 9], fb_m_spot=[13, 39, 3, 3], fb_s=[14, 56, 13, 9],
    fb_s_spot=[19, 59, 3, 3], far_stage=[7, 48, 11, 9], far_point=[30, 55, 4, 4], drowned=[1, 69, 10, 8],
    road_n=[5, 0, 8, 3], sire_spot=[7, 8, 2, 2], venom_spot=[15, 8, 2, 2], turtle_spot=[9, 2, 2, 2],
    # the shallows (fords) and their banks
    rapids=[23, 1, 16, 4], rapids_w=[17, 1, 6, 5], rapids_e=[39, 1, 5, 5],
    ford_mid=[32, 40, 16, 4], mid_w=[24, 39, 7, 6], landing_mid=[47, 38, 8, 9],
    ford_s=[36, 61, 17, 5], s_w=[27, 59, 8, 7],
    # Nazaré
    nazare=[40, 3, 28, 20], g_chapel=[46, 6, 5, 4], g_houses=[53, 15, 6, 5], g_fields=[59, 4, 8, 6], canoes_n=[40, 12, 3, 9],
    beach=[40, 14, 3, 4],
    # the bank trail
    trail_n=[42, 22, 6, 5], trail_mid=[44, 30, 6, 6], trail_s=[52, 46, 8, 4], north_gate=[72, 45, 10, 4],
    col_start=[73, 51, 8, 4],
    # the Barra
    bluff=[62, 50, 33, 27], bluff_mid=[70, 57, 16, 10], hall_area=[76, 61, 8, 7], west_gate=[62, 61, 4, 8],
    north_in=[73, 51, 7, 3], east_gate=[90, 58, 5, 8], guns_n=[64, 55, 2, 2], guns_s=[64, 70, 2, 2],
    church_go=[66, 52, 6, 6], lower_town=[50, 52, 11, 25], s_e=[51, 60, 7, 7], landing_s=[50, 72, 10, 5], fields=[96, 52, 20, 24],
    downriver=[104, 73, 12, 4],
)

# ================================================================== the units
VILL = {   # Nazaré's people: (group, how many, condition)
    "g_chapel": [(2, None), (1, NOT_S_FEW), (1, S_MANY)],
    "g_houses": [(2, None), (1, NOT_S_FEW), (1, S_MANY)],
    "g_fields": [(2, None), (2, NOT_S_FEW), (2, S_MANY)],
}
units = [
    # ---- the Barra: Valadares and the column (at the north gate, inside), the garrison, the guns, the hands
    {"team": "barra", "kind": "dismounted", "as": "valadares", "count": 1, "at": "col_start", "tag": "valadares",
     "tags": ["column", "barra_men"], "fixed": True},
    {"team": "barra", "kind": "musketeer", "count": 6, "at": "col_start", "tag": "column", "tags": ["barra_men"], "fixed": True},
    {"team": "barra", "kind": "dragoon", "count": 2, "at": "col_start", "tag": "column", "tags": ["barra_men", "riders"], "fixed": True},
    {"team": "barra", "kind": "musketeer", "as": "barra_sergeant", "count": 1, "at": "bluff_mid", "tag": "sergeant",
     "tags": ["garrison", "barra_men"], "fixed": True},
    {"team": "barra", "kind": "musketeer", "count": 5, "at": "bluff_mid", "tag": "garrison", "tags": ["barra_men"], "fixed": True},
    {"team": "barra", "kind": "cannon", "count": 1, "at": "guns_n", "tag": "guns", "tags": ["barra_men"], "fixed": True},
    {"team": "barra", "kind": "cannon", "count": 1, "at": "guns_s", "tag": "guns", "tags": ["barra_men"], "fixed": True},
    {"team": "barra", "kind": "labourer", "count": 5, "at": "hall_area", "tag": "labs", "fixed": True},
    # (the swarm played alone: the Barra's garrison is the whole company, not the half Valadares left on the bluff)
    {"team": "barra", "kind": "musketeer", "count": 3, "at": "bluff_mid", "tag": "garrison", "tags": ["barra_men"], "fixed": True, "if": NO_BARRA},
    {"team": "barra", "kind": "musketeer", "count": 3, "at": "bluff_mid", "tag": "garrison", "tags": ["barra_men"], "fixed": True,
     "if": {"all": [NO_BARRA, {"difficulty": ["normal", "hard"]}]}},
    {"team": "barra", "kind": "musketeer", "count": 4, "at": "bluff_mid", "tag": "garrison", "tags": ["barra_men"], "fixed": True,
     "if": {"all": [NO_BARRA, {"difficulty": "hard"}]}},
    {"team": "barra", "kind": "cannon", "count": 1, "at": "west_gate", "tag": "guns_in", "tags": ["barra_men"], "fixed": True,
     "if": {"all": [NO_BARRA, {"difficulty": "hard"}]}},
    # ---- Nazaré: Benedito at the canoes, the people in three groups
    {"team": "nazare", "kind": "labourer", "as": "benedito", "count": 1, "at": "beach", "tag": "benedito", "fixed": True},
] + [
    {"team": "nazare", "kind": "labourer", "as": "villager", "count": n, "at": g, "tag": g, "tags": ["villagers"], "fixed": True,
     **({"if": c} if c else {})}
    for g, rows in VILL.items() for (n, c) in rows
] + [
    # ---- the swarm: the forward Mother across from Nazaré (both games), her guard; the mirror's own pieces
    {"team": "swarm", "kind": "brood_mother", "as": "bank_mother", "count": 1, "at": "fb_n_spot", "tag": "fwd_n",
     "tags": ["fwd", "mothers"], "fixed": True},
    {"team": "swarm", "kind": "raptor", "count": 3, "at": "fb_n", "tag": "fwd_guard", "tags": ["swarm_all"], "if": NO_SWARM},
    # (the mirror: the player's swarm: the second Mother on the far bank's middle, the Sires, a turtle, grubs, raiders)
    {"team": "swarm", "kind": "brood_mother", "as": "bank_mother", "count": 1, "at": "fb_m_spot", "tag": "fwd_m",
     "tags": ["fwd", "mothers"], "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "tyrannosaur", "count": 1, "at": "sire_spot", "tag": "sires", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "dilophosaurus", "count": 1, "at": "venom_spot", "tag": "sires", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "mound_turtle", "count": 1, "at": "turtle_spot", "tag": "turtles", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "grub", "count": 4, "at": "fb_n", "tag": "grubs", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "raptor", "count": 4, "at": "fb_n", "tag": "raiders", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "spitter", "count": 2, "at": "fb_n", "tag": "raiders", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "raptor", "count": 2, "at": "fb_m", "tag": "raiders", "fixed": True, "if": SWARM},
]

# ================================================================== the buildings: the Barra on its bluff
WALLS = []
for x in range(73, 80):                          # the north gate (the ramp from the bank trail)
    WALLS.append(((x, 50), x in (76, 77)))
for y in range(62, 69):                          # the west gate (down to the lower town)
    WALLS.append(((62, y), y in (65, 66)))
for y in range(59, 66):                          # the east gate (the fields)
    WALLS.append(((94, y), y == 62))
QUARTERS = [(51, 52), (55, 53), (51, 56), (57, 57), (52, 69), (56, 71)]

buildings = [
    {"team": "barra", "kind": "town_hall", "at": [77, 62], "tag": "hall", "tags": ["barra_b"],
     "name": T("The Barra's Town Hall", "A Câmara da Barra", "El Cabildo de la Barra")},
    {"team": "barra", "kind": "church", "at": [68, 54], "tag": "church", "tags": ["barra_b"],
     "name": T("Our Lady of the Conception", "Nossa Senhora da Conceição", "Nuestra Señora de la Concepción")},
    {"team": "barra", "kind": "barracks", "at": [70, 70], "tag": "barracks", "tags": ["barra_b"]},
    {"team": "barra", "kind": "farm", "at": [84, 54], "tag": "farms", "tags": ["barra_b"]},
    {"team": "barra", "kind": "farm", "at": [84, 68], "tag": "farms", "tags": ["barra_b"]},
    {"team": "barra", "kind": "powder_mill", "at": [89, 62], "tag": "mill", "tags": ["barra_b"]},
    {"team": "barra", "kind": "cottage", "at": [68, 62], "tag": "bluff_houses", "tags": ["barra_b"]},
    {"team": "barra", "kind": "cottage", "at": [90, 52], "tag": "bluff_houses", "tags": ["barra_b"]},
] + [
    {"team": "barra", "kind": "cottage", "at": list(q), "tag": "quarters", "tags": ["barra_b"],
     "name": T("The lower town", "A cidade baixa", "La ciudad baja")} for q in QUARTERS
] + [
    {"team": "barra", "kind": "gate" if g else "wall", "at": list(c), "tag": "palisade", "tags": ["barra_b"],
     "name": T("The Barra's palisade", "A paliçada da Barra", "La empalizada de la Barra")} for (c, g) in WALLS
]

# ================================================================== the objectives
objectives = [
    # ---- the Barra
    {"id": "church_live", "side": "barra", "primary": True, "kind": "protect", "tag": "church",
     "text": T("The church on the bluff must stand.", "A igreja no alto tem de ficar de pé.", "La iglesia del alto debe seguir en pie.")},
    {"id": "hall_live", "side": "barra", "primary": True, "kind": "protect", "tag": "hall",
     "text": T("The Barra's Town Hall must stand.", "A Câmara da Barra tem de ficar de pé.", "El Cabildo de la Barra debe seguir en pie.")},
    {"id": "nazare", "side": "barra", "primary": False, "kind": "manual",
     "text": T("NAZARÉ: take the column north up the bank trail to the village. Walk a man up to each group of its people (the chapel, the houses, the fields): they then go to Benedito's canoes on the beach by themselves. {out_n} of {vill_n} away.",
               "NAZARÉ: leve a coluna para norte pelo trilho da margem até à aldeia. Leve um homem até cada grupo da sua gente (a capela, as casas, os campos): depois vão sozinhos para as canoas de Benedito na praia. {out_n} de {vill_n} a salvo.",
               "NAZARÉ: lleva la columna al norte por la senda de la orilla hasta la aldea. Lleva a un hombre hasta cada grupo de su gente (la capilla, las casas, los campos): luego van solos a las canoas de Benedito en la playa. {out_n} de {vill_n} a salvo."),
     "phone": T("Nazaré: a man to each group; they go to the canoes. {out_n} of {vill_n} away.",
                "Nazaré: um homem a cada grupo; vão às canoas. {out_n} de {vill_n} a salvo.",
                "Nazaré: un hombre a cada grupo; van a las canoas. {out_n} de {vill_n} a salvo.")},
    {"id": "nazare_clock", "side": "barra", "primary": False, "kind": "countdown", "clock": "nazare",
     "text": T("The forward Mother across the river roots in {clock:nazare}: then the creatures come over the rapids in numbers.",
               "A Mãe avançada do outro lado do rio enraíza-se em {clock:nazare}: depois as criaturas atravessam os rápidos em grande número.",
               "La Madre de avanzada al otro lado del río enraíza en {clock:nazare}: luego las criaturas cruzan los rápidos en masa.")},
    {"id": "bluff", "side": "barra", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE BLUFF: bring the column home down the bank trail. The creatures come over the shallows in waves: hold the lower town by the river and the three gates of the bluff. Train Musketeers at the Barracks; your Labourers mend the palisade.",
               "O ALTO: traga a coluna para casa pelo trilho da margem. As criaturas atravessam os baixios em vagas: defenda a cidade baixa junto ao rio e as três portas do alto. Treine Mosqueteiros no Quartel; os seus Trabalhadores consertam a paliçada.",
               "EL ALTO: trae la columna a casa por la senda de la orilla. Las criaturas cruzan los bajíos en oleadas: defiende la ciudad baja junto al río y las tres puertas del alto. Entrena Mosqueteros en el Cuartel; tus Peones reparan la empalizada."),
     "phone": T("The bluff: hold the lower town and the three gates. Wave {wave_n} of 5.",
                "O alto: defenda a cidade baixa e as três portas. Vaga {wave_n} de 5.",
                "El alto: defiende la ciudad baja y las tres puertas. Oleada {wave_n} de 5.")},
    {"id": "fwd", "side": "barra", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE FORWARD MOTHERS: two more walk down the far bank to root on it; every one rooted puts more creatures in every wave. Cross a shallows with the Dragoons and kill one while she walks ({fwd_killed} killed, {fwd_rooted} rooted).",
               "AS MÃES AVANÇADAS: mais duas descem a outra margem para lá enraizar; cada uma enraizada põe mais criaturas em cada vaga. Atravesse um baixio com os Dragões e mate uma enquanto anda ({fwd_killed} mortas, {fwd_rooted} enraizadas).",
               "LAS MADRES DE AVANZADA: dos más bajan por la otra orilla para enraizar en ella; cada una enraizada pone más criaturas en cada oleada. Cruza un bajío con los Dragones y mata a una mientras camina ({fwd_killed} muertas, {fwd_rooted} enraizadas)."),
     "phone": T("Kill a forward Mother before she roots: {fwd_killed} killed, {fwd_rooted} rooted.",
                "Mate uma Mãe avançada antes que enraíze: {fwd_killed} mortas, {fwd_rooted} enraizadas.",
                "Mata a una Madre de avanzada antes de que enraíce: {fwd_killed} muertas, {fwd_rooted} enraizadas.")},
    {"id": "night", "side": "barra", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE GREAT WAVE: it comes over the Barra shallows in the dark. Break it, or hold the bluff until first light.",
               "A GRANDE VAGA: atravessa os baixios da Barra no escuro. Quebre-a, ou segure o alto até ao primeiro clarão.",
               "LA GRAN OLEADA: cruza los bajíos de la Barra en la oscuridad. Rómpela, o aguanta el alto hasta la primera luz.")},
    {"id": "dawn_clock", "side": "barra", "primary": False, "kind": "countdown", "clock": "dawn", "hidden": True,
     "text": T("First light in {clock:dawn}.", "O primeiro clarão em {clock:dawn}.", "La primera luz en {clock:dawn}.")},
    {"id": "v_hold", "side": "barra", "primary": False, "kind": "countdown", "clock": "floods", "hidden": True,
     "text": T("Hold the church and the Town Hall until the floods fall: {clock:floods}.",
               "Segure a igreja e a Câmara até a cheia baixar: {clock:floods}.",
               "Aguanta la iglesia y el Cabildo hasta que baje la crecida: {clock:floods}.")},
    # ---- the swarm (the solo pick, versus)
    {"id": "s_mothers", "side": "swarm", "primary": True, "kind": "protect", "tag": "fwd",
     "text": T("At least one of your forward Mothers must live.", "Pelo menos uma das suas Mães avançadas tem de viver.",
               "Al menos una de tus Madres de avanzada debe vivir.")},
    {"id": "s_nazare", "side": "swarm", "primary": False, "kind": "manual",
     "text": T("NAZARÉ: the village across the rapids is emptying into Benedito's canoes. Cross the rapids with your Raptors and catch its people before they are away.",
               "NAZARÉ: a aldeia do outro lado dos rápidos está a esvaziar-se nas canoas de Benedito. Atravesse os rápidos com os seus Raptores e apanhe a sua gente antes que fujam.",
               "NAZARÉ: la aldea al otro lado de los rápidos se vacía en las canoas de Benedito. Cruza los rápidos con tus Raptores y atrapa a su gente antes de que se vayan.")},
    {"id": "s_root", "side": "swarm", "primary": False, "kind": "manual",
     "text": T("THE FAR BANK: walk your second Mother down the far bank and ROOT her in the clearing opposite the Barra (south-west of it, across the Barra shallows). Her swamp then reaches the river.",
               "A OUTRA MARGEM: leve a sua segunda Mãe pela outra margem abaixo e ENRAÍZE-A na clareira em frente da Barra (a sudoeste, do outro lado dos baixios da Barra). O pântano dela chega então ao rio.",
               "LA OTRA ORILLA: lleva a tu segunda Madre por la otra orilla y ENRAÍZALA en el claro frente a la Barra (al suroeste, al otro lado de los bajíos de la Barra). Su pantano llega entonces al río.")},
    {"id": "s_barra", "side": "swarm", "primary": True, "kind": "manual",
     "text": T("BREAK THE BARRA: kill the two guns on the bluff's river edge and break the church ({guns_left} guns left). Brutes break palisades; GROW a Mother to stage 3 for them.",
               "ROMPA A BARRA: mate os dois canhões na beira do alto sobre o rio e derrube a igreja ({guns_left} canhões restam). Os Brutamontes rompem paliçadas; faça uma Mãe CRESCER ao terceiro estágio para os ter.",
               "ROMPE LA BARRA: mata los dos cañones del borde del alto sobre el río y derriba la iglesia ({guns_left} cañones quedan). Los Brutos rompen empalizadas; haz CRECER a una Madre a la tercera etapa para tenerlos."),
     "phone": T("Kill the two guns ({guns_left} left) and break the church.", "Mate os dois canhões ({guns_left} restam) e derrube a igreja.",
                "Mata los dos cañones ({guns_left} quedan) y derriba la iglesia.")},
    {"id": "s_clock", "side": "swarm", "primary": False, "kind": "countdown", "clock": "floods",
     "text": T("The floods fall in {clock:floods}: then the far bank dries and the Barra holds.",
               "A cheia baixa em {clock:floods}: depois a outra margem seca e a Barra aguenta.",
               "La crecida baja en {clock:floods}: luego la otra orilla se seca y la Barra aguanta.")},
]

M = {
    "id": MID,
    "title": T("Down the Rivers", "Rios Abaixo", "Ríos Abajo"),
    "summary": T("The Rio Negro in the floods of 2778. The swarm comes down the rivers; Valadares brings Nazaré's people out and holds the Barra on its bluff.",
                 "O Rio Negro na cheia de 2778. O enxame desce os rios; Valadares tira a gente de Nazaré e defende a Barra no seu alto.",
                 "El Río Negro en la crecida de 2778. El enjambre baja por los ríos; Valadares saca a la gente de Nazaré y defiende la Barra en su alto."),
    "map": "campaign:barra_rivers",
    "voice": "d08",
    "light": "jungle_day",
    "weather": "rain",
    "floor": [0.76, 0.78, 0.72],
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["a07_council", "d06_queen"],
    "modes": ["solo", "versus"],
    "solo_sides": ["barra", "swarm"],
    "sides": [
        {"id": "barra", "name": T("The Barra", "A Barra", "La Barra"),
         "about": T("Valadares and the Barra do Rio Negro: the column, the garrison on the bluff, two guns, the church; Nazaré's people upriver.",
                    "Valadares e a Barra do Rio Negro: a coluna, a guarnição no alto, dois canhões, a igreja; a gente de Nazaré rio acima.",
                    "Valadares y la Barra del Río Negro: la columna, la guarnición del alto, dos cañones, la iglesia; la gente de Nazaré río arriba.")},
        {"id": "swarm", "name": T("The Swarm", "O Enxame", "El Enjambre"),
         "about": T("The Brood coming down the rivers in the floods: forward Mothers rooting on the far bank, and what they lay.",
                    "A Ninhada a descer os rios na cheia: Mães avançadas a enraizar na outra margem, e o que elas põem.",
                    "La Prole bajando por los ríos en la crecida: Madres de avanzada enraizando en la otra orilla, y lo que ponen.")},
    ],
    "teams": [
        {"id": "barra", "side": "barra", "faction": "crown", "colour": 4, "start": "none", "camera": "col_start", "gold": 500, "powder": 200,
         "control": {"solo": "p1", "versus": "p1", "foe": "script"},
         "roster": {"deny": ["town_hall", "foundry", "mortar", "horse_breeder", "armoury", "church", "nitre_beds", "balloon",
                             "missionary", "cuirassier"]}},
        {"id": "nazare", "side": "barra", "faction": "crown", "colour": 3, "start": "none", "camera": "nazare",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "swarm", "side": "swarm", "faction": "brood", "colour": 2, "start": "none", "camera": "fb_n", "gold": 0, "powder": 0,
         "control": {"solo": "script", "versus": "p2"}},
    ],
    "areas": areas,
    "counters": {k: {"start": 0} for k in ["vill_n", "out_n", "called", "wave_n", "fwd_killed", "fwd_rooted", "q_n", "q_left",
                                             "guns_left", "great_n"]},
    "exits": [
        {"area": "canoes_n", "tag": "villagers", "counter": "out_n"},
    ],
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["valadares"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "barra", "portrait": "res://campaign/hub/rome_king_face.png"},
        "valadares": {"name": T("Valadares", "Valadares", "Valadares"), "side": "barra"},
        "benedito": {"name": T("Benedito", "Benedito", "Benedito"), "side": "barra"},
        "sergeant": {"name": T("The Barra's sergeant", "O sargento da Barra", "El sargento de la Barra"), "side": "barra"},
        "narrator": {"name": T("The Rio Negro", "O Rio Negro", "El Río Negro"), "side": "barra"},
    },
    "lines": {},
    "stills": {},
    "next": {"barra": "", "swarm": ""},
}

L = M["lines"]
UNTIL_P2 = {"n_base", "v_map", "v_sealed", "b_party_few", "g_chapel", "g_houses", "g_fields", "b_first", "n_raid", "n_s_canoes"}
UNTIL_P3 = {"n_wave", "s_quarter", "v_mend", "n_fwd2", "n_fwd_root", "n_fwd_dead", "v_fwd_dead", "n_waves"}


def line(lid, who, en, pt, es, to=None, until=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    if until:
        L[lid]["until"] = until
    elif lid in UNTIL_P2:
        L[lid]["until"] = "part2"       # (Part 1's chatter is dropped unseen once the canoes are gone: never read out late)
    elif lid in UNTIL_P3:
        L[lid]["until"] = "part3"
    return lid


BA, SW = "barra", "swarm"
# ---- the opening (the King frames; Valadares tells it from his report)
line("k_open1", "king", "Three years after the island, the floods came higher than the last. The swarm came down with them.",
     "Três anos depois da ilha, a cheia veio mais alta do que a anterior. O enxame desceu com ela.",
     "Tres años después de la isla, la crecida vino más alta que la anterior. El enjambre bajó con ella.")
line("k_open2", "king", "Valadares held the Barra that season. This is his report, as he wrote it.",
     "Valadares segurou a Barra nessa estação. Este é o relatório dele, tal como o escreveu.",
     "Valadares sostuvo la Barra aquella estación. Este es su informe, tal como lo escribió.")
line("k_linnea", "king", "He told me later he had seen the first of them on the plateau, years before. He knew them at once.",
     "Disse-me mais tarde que tinha visto as primeiras no planalto, anos antes. Reconheceu-as logo.",
     "Me dijo después que había visto a las primeras en la meseta, años antes. Las reconoció enseguida.")
line("v_open1", "valadares", "The Rio Negro, the floods of 2778. Every town above the Barra was empty by Lent.",
     "O Rio Negro, a cheia de 2778. Todas as vilas acima da Barra estavam vazias pela Quaresma.",
     "El Río Negro, la crecida de 2778. Todos los pueblos por encima de la Barra estaban vacíos para Cuaresma.")
line("v_open2", "valadares", "Nazaré was the last. Its people had nowhere to go but our canoes.",
     "Nazaré era a última. A sua gente não tinha para onde ir senão as nossas canoas.",
     "Nazaré era la última. Su gente no tenía adónde ir sino a nuestras canoas.")
line("k_open_s", "king", "Valadares wrote this down as it happened. Here is how it would have gone if the bluff had fallen.",
     "Valadares escreveu isto à medida que acontecia. Eis como teria sido se o alto tivesse caído.",
     "Valadares lo escribió según ocurría. He aquí cómo habría sido si el alto hubiera caído.")
line("n_open_s", "narrator", "The floods. Forward Mothers root on the far bank, and the ground creeps out from them toward the river.",
     "A cheia. Mães avançadas enraízam na outra margem, e o chão rasteja delas para o rio.",
     "La crecida. Madres de avanzada enraízan en la otra orilla, y el suelo se arrastra de ellas hacia el río.")
# ---- part 1: Nazaré
line("v_1", "valadares", "Column, with me. Up the bank trail to Nazaré, and quickly. Benedito has the canoes at the beach.",
     "Coluna, comigo. Pelo trilho da margem até Nazaré, e depressa. Benedito tem as canoas na praia.",
     "Columna, conmigo. Por la senda de la orilla hasta Nazaré, y deprisa. Benedito tiene las canoas en la playa.", BA)
line("n_lesson", "narrator", "Nazaré is north, up the bank trail. Its people are in three groups: by the chapel, in the houses, in the fields. Walk any of your men up to a group and it goes to the canoes by itself.",
     "Nazaré fica a norte, pelo trilho da margem. A sua gente está em três grupos: junto à capela, nas casas, nos campos. Leve qualquer um dos seus homens até um grupo e ele vai sozinho para as canoas.",
     "Nazaré está al norte, por la senda de la orilla. Su gente está en tres grupos: junto a la capilla, en las casas, en los campos. Lleva a cualquiera de tus hombres hasta un grupo y irá solo a las canoas.", BA)
line("n_base", "narrator", "The Barra is yours as well: Labourers on the Farms, Musketeers from the Barracks. The waves will come here when Nazaré is out.",
     "A Barra também é sua: Trabalhadores nas Quintas, Mosqueteiros do Quartel. As vagas virão para aqui quando Nazaré estiver a salvo.",
     "La Barra también es tuya: Peones en las Granjas, Mosqueteros del Cuartel. Las oleadas vendrán aquí cuando Nazaré esté a salvo.", BA)
line("v_map", "valadares", "I drew their road down from the plateau myself. They will cross where the river is shallow: the rapids, the middle, the Barra.",
     "Fui eu que desenhei o caminho deles desde o planalto. Vão atravessar onde o rio é baixo: os rápidos, o meio, a Barra.",
     "Yo mismo dibujé su camino desde la meseta. Cruzarán donde el río es bajo: los rápidos, el medio, la Barra.", BA)
line("v_sealed", "valadares", "My map of the plateau is under seal in Rome. I will learn their road the hard way, as they come.",
     "O meu mapa do planalto está selado em Roma. Vou aprender o caminho deles à minha custa, à medida que vêm.",
     "Mi mapa de la meseta está sellado en Roma. Aprenderé su camino a la fuerza, según vengan.", BA)
line("b_party_few", "benedito", "Senhor, I am the last of the plateau's party still on the river. Let us not lose anyone else.",
     "Senhor, sou o último do grupo do planalto ainda no rio. Não percamos mais ninguém.",
     "Señor, soy el último de la partida de la meseta que queda en el río. No perdamos a nadie más.", BA)
line("g_chapel", "narrator", "The people by the chapel take up their bundles and go down to the beach.",
     "A gente junto à capela pega nas trouxas e desce à praia.", "La gente junto a la capilla coge sus fardos y baja a la playa.")
line("g_houses", "narrator", "The families in the houses come out and go down to the beach.",
     "As famílias das casas saem e descem à praia.", "Las familias de las casas salen y bajan a la playa.")
line("g_fields", "narrator", "The people in the manioc fields leave their baskets and run for the beach.",
     "A gente nos campos de mandioca deixa os cestos e corre para a praia.", "La gente de los campos de mandioca deja los cestos y corre a la playa.")
line("b_first", "benedito", "The first are in the canoes, Senhor. I can take them all, if they get here.",
     "Os primeiros já estão nas canoas, Senhor. Posso levá-los todos, se chegarem cá.",
     "Los primeros ya están en las canoas, señor. Puedo llevarlos a todos, si llegan.", BA)
line("n_raid", "narrator", "Creatures come over the rapids from the far bank, after the people. Keep your men between them and the villagers.",
     "Criaturas atravessam os rápidos vindas da outra margem, atrás da gente. Mantenha os seus homens entre elas e os aldeões.",
     "Criaturas cruzan los rápidos desde la otra orilla, tras la gente. Mantén a tus hombres entre ellas y los aldeanos.", BA)
line("n_rooted", "narrator", "Across the river the forward Mother roots. Her ground creeps toward the water, and more come over the rapids.",
     "Do outro lado do rio a Mãe avançada enraíza. O chão dela rasteja para a água, e mais atravessam os rápidos.",
     "Al otro lado del río la Madre de avanzada enraíza. Su suelo se arrastra hacia el agua, y más cruzan los rápidos.")
line("b_wait", "benedito", "I cannot wait much longer, Senhor! Whoever is not on the beach stays.",
     "Não posso esperar muito mais, Senhor! Quem não estiver na praia fica.", "¡No puedo esperar mucho más, señor! Quien no esté en la playa se queda.", BA)
line("b_away", "benedito", "We are away! Down to the Barra, Senhor. Do not stay up here.",
     "Estamos a caminho! Para a Barra, Senhor. Não fique aqui em cima.", "¡Nos vamos! A la Barra, señor. No se quede aquí arriba.", BA)
line("n_left", "narrator", "Some of Nazaré's people did not reach the beach. They went into the forest, and nobody saw them again.",
     "Parte da gente de Nazaré não chegou à praia. Foi para a floresta, e ninguém mais a viu.",
     "Parte de la gente de Nazaré no llegó a la playa. Se fue al bosque, y nadie la volvió a ver.")
# ---- part 2: the bluff
line("v_2", "valadares", "Back to the Barra, all of you. Down the trail. They will be at the shallows before us.",
     "De volta à Barra, todos. Pelo trilho abaixo. Vão estar nos baixios antes de nós.",
     "De vuelta a la Barra, todos. Por la senda abajo. Estarán en los bajíos antes que nosotros.", BA)
line("s_2", "sergeant", "Senhor Valadares! Creatures on the far bank, opposite the lower town. The guns are loaded.",
     "Senhor Valadares! Criaturas na outra margem, em frente da cidade baixa. Os canhões estão carregados.",
     "¡Señor Valadares! Criaturas en la otra orilla, frente a la ciudad baja. Los cañones están cargados.", BA)
line("n_waves", "narrator", "They come in waves, over the Barra shallows into the lower town and over the middle shallows down the bank trail. The guns on the bluff reach the shallows.",
     "Vêm em vagas, pelos baixios da Barra para a cidade baixa e pelos baixios do meio pelo trilho abaixo. Os canhões no alto alcançam os baixios.",
     "Vienen en oleadas, por los bajíos de la Barra a la ciudad baja y por los bajíos del medio senda abajo. Los cañones del alto alcanzan los bajíos.", BA)
line("n_fwd", "narrator", "A forward Mother walks down the far bank to root. Rooted, her ground creeps, and every wave grows by what she lays. Cross a shallows with the Dragoons and kill her on the way.",
     "Uma Mãe avançada desce a outra margem para enraizar. Enraizada, o chão dela rasteja, e cada vaga cresce com o que ela põe. Atravesse um baixio com os Dragões e mate-a pelo caminho.",
     "Una Madre de avanzada baja por la otra orilla para enraizar. Enraizada, su suelo se arrastra, y cada oleada crece con lo que pone. Cruza un bajío con los Dragones y mátala por el camino.", BA)
line("n_fwd2", "narrator", "Another forward Mother sets off down the far bank, toward the clearing opposite the Barra.",
     "Outra Mãe avançada desce a outra margem, rumo à clareira em frente da Barra.",
     "Otra Madre de avanzada baja por la otra orilla, hacia el claro frente a la Barra.", BA)
line("n_fwd_root", "narrator", "A forward Mother has rooted on the far bank. More will come in every wave now.",
     "Uma Mãe avançada enraizou na outra margem. Agora virão mais em cada vaga.",
     "Una Madre de avanzada ha enraizado en la otra orilla. Ahora vendrán más en cada oleada.", BA)
line("n_fwd_dead", "narrator", "A forward Mother is dead before she could root. The waves stay smaller.",
     "Uma Mãe avançada está morta antes de conseguir enraizar. As vagas ficam mais pequenas.",
     "Una Madre de avanzada ha muerto antes de poder enraizar. Las oleadas siguen siendo más pequeñas.", BA)
line("v_fwd_dead", "valadares", "Good. Back over the water before the next wave.", "Bom. De volta pela água antes da próxima vaga.",
     "Bien. De vuelta por el agua antes de la próxima oleada.", BA)
line("n_wave", "narrator", "A wave is coming over the shallows.", "Uma vaga atravessa os baixios.", "Una oleada cruza los bajíos.", BA)
line("s_quarter", "sergeant", "A house in the lower town is burning, Senhor!", "Está a arder uma casa na cidade baixa, Senhor!",
     "¡Arde una casa en la ciudad baja, señor!", BA)
line("v_mend", "valadares", "Labourers to the palisade. Mend what they break.", "Trabalhadores para a paliçada. Consertem o que eles partem.",
     "Peones a la empalizada. Reparad lo que rompan.", BA)
# ---- part 3: the lure book, the night
line("n_dusk", "narrator", "Dusk. On the far bank they are gathering, more than in any wave before.",
     "Anoitece. Na outra margem estão a juntar-se, mais do que em qualquer vaga antes.",
     "Anochece. En la otra orilla se están reuniendo, más que en ninguna oleada antes.")
line("b_book", "benedito", "Senhor. Your men brought this from the fazenda's ruins. The Doctor's lure book.",
     "Senhor. Os seus homens trouxeram isto das ruínas da fazenda. O livro dos engodos do Doutor.",
     "Señor. Sus hombres trajeron esto de las ruinas de la fazenda. El libro de los señuelos del doctor.", BA)
line("b_book_taken", "benedito", "Senhor. The Doctor left this at the Barra's warehouse for his passage downriver. His lure book.",
     "Senhor. O Doutor deixou isto no armazém da Barra para pagar a passagem rio abaixo. O livro dos engodos dele.",
     "Señor. El doctor dejó esto en el almacén de la Barra para pagar su pasaje río abajo. Su libro de los señuelos.", BA)
line("b_lure", "benedito", "I know the old lure. A post on the far point, a jar on it, and they turn off their road into the flooded forest.",
     "Conheço o engodo antigo. Um poste na ponta da outra margem, um frasco nele, e eles desviam-se do caminho para a floresta alagada.",
     "Conozco el señuelo antiguo. Un poste en la punta de la otra orilla, un frasco en él, y se desvían de su camino al bosque inundado.", BA)
line("v_rome", "valadares", "Rome ordered every one of these books burned.", "Roma mandou queimar todos estes livros.",
     "Roma ordenó quemar todos estos libros.", BA)
line("v_burn", "valadares", "No man should call them. Not even once. Into the fire with it.",
     "Nenhum homem os deve chamar. Nem uma vez. Para o fogo com ele.", "Ningún hombre debe llamarlos. Ni una sola vez. Al fuego con él.", BA)
line("n_burn", "narrator", "The book burns. The whole wave will come over the Barra shallows: hold the lower town and the west gate.",
     "O livro arde. A vaga inteira vai atravessar os baixios da Barra: segure a cidade baixa e a porta oeste.",
     "El libro arde. La oleada entera cruzará los bajíos de la Barra: aguanta la ciudad baja y la puerta oeste.", BA)
line("v_use", "valadares", "Once, for the town. Then it goes in the fire. Benedito, take two men and the canoe.",
     "Uma vez, pela vila. Depois vai para o fogo. Benedito, leva dois homens e a canoa.",
     "Una vez, por el pueblo. Luego va al fuego. Benedito, llévate a dos hombres y la canoa.", BA)
line("n_use", "narrator", "Benedito sets the lure post on the far point. Part of the wave will turn off its road into the flooded forest.",
     "Benedito põe o poste do engodo na ponta da outra margem. Parte da vaga vai desviar-se do caminho para a floresta alagada.",
     "Benedito planta el poste del señuelo en la punta de la otra orilla. Parte de la oleada se desviará de su camino al bosque inundado.", BA)
line("v_vs_burn", "valadares", "Rome ordered the books burned. This one too. We hold the Barra with what we have.",
     "Roma mandou queimar os livros. Este também. Seguramos a Barra com o que temos.",
     "Roma ordenó quemar los libros. Este también. Sostenemos la Barra con lo que tenemos.", BA)
line("n_night", "narrator", "Night. The great wave comes down to the far bank.", "Noite. A grande vaga desce para a outra margem.",
     "Noche. La gran oleada baja a la otra orilla.")
line("n_go", "narrator", "The great wave goes into the water at the Barra shallows.", "A grande vaga entra na água nos baixios da Barra.",
     "La gran oleada entra en el agua en los bajíos de la Barra.", BA)
line("n_lured", "narrator", "Half the wave turns toward the far point, past it, into the flooded forest.",
     "Metade da vaga vira-se para a ponta, passa por ela, e entra na floresta alagada.",
     "La mitad de la oleada se vuelve hacia la punta, la pasa, y entra en el bosque inundado.", BA)
line("n_drowned", "narrator", "The water closes over their road. They do not come out of the flooded forest tonight.",
     "A água fecha-se sobre o caminho deles. Não saem da floresta alagada esta noite.",
     "El agua se cierra sobre su camino. No salen del bosque inundado esta noche.", BA)
line("s_great", "sergeant", "Here they come! Canister, at the shallows!", "Aí vêm eles! Metralha, nos baixios!", "¡Ahí vienen! ¡Metralla, en los bajíos!", BA)
line("n_broken", "narrator", "The great wave is broken. What is left of it goes back into the dark.",
     "A grande vaga está quebrada. O que resta dela volta para o escuro.", "La gran oleada está rota. Lo que queda de ella vuelve a la oscuridad.")
line("n_dawn", "narrator", "First light. The far bank is quiet; the swarm has gone back into the flooded forest.",
     "Primeiro clarão. A outra margem está calma; o enxame voltou para a floresta alagada.",
     "Primera luz. La otra orilla está en calma; el enjambre ha vuelto al bosque inundado.")
line("v_won", "valadares", "The Barra stands. Ring the bell, sergeant. Then count the houses.",
     "A Barra aguenta. Toque o sino, sargento. Depois conte as casas.", "La Barra resiste. Toque la campana, sargento. Luego cuente las casas.", BA)
line("v_hurt", "valadares", "I am hit. Keep the line, keep the line.", "Fui atingido. Mantenham a linha, mantenham a linha.",
     "Me han dado. Mantened la línea, mantened la línea.", BA)
line("n_hall_lost", "narrator", "The bluff is broken. The Barra is lost.", "O alto está quebrado. A Barra está perdida.", "El alto está roto. La Barra está perdida.")
# ---- the swarm's (the solo pick) lines: narration only, no creature speaks
line("n_s1", "narrator", "Your forward Mother is rooted across the rapids from Nazaré, your Sires by her. Lay eggs on her card; the grubs make Rootmaws on her swamp for food.",
     "A sua Mãe avançada está enraizada do outro lado dos rápidos, em frente de Nazaré, com os seus Sires. Ponha ovos no painel dela; as larvas fazem Bocarraízes no pântano dela para comida.",
     "Tu Madre de avanzada está enraizada al otro lado de los rápidos, frente a Nazaré, con tus Señores. Pon huevos en su panel; las larvas hacen Bocarraíces en su pantano para comida.", SW)
line("n_s2", "narrator", "Your second Mother waits on the far bank's middle. Walk her south and root her opposite the Barra.",
     "A sua segunda Mãe espera no meio da outra margem. Leve-a para sul e enraíze-a em frente da Barra.",
     "Tu segunda Madre espera en el medio de la otra orilla. Llévala al sur y enraízala frente a la Barra.", SW)
line("n_s_canoes", "narrator", "Nazaré's people reach the canoes and are gone down the river.", "A gente de Nazaré chega às canoas e desce o rio.",
     "La gente de Nazaré llega a las canoas y baja por el río.", SW)
line("n_s_root", "narrator", "A Mother roots opposite the Barra. Her swamp reaches the water.", "Uma Mãe enraíza em frente da Barra. O pântano dela chega à água.",
     "Una Madre enraíza frente a la Barra. Su pantano llega al agua.", SW)
line("n_s_reinf", "narrator", "Canoes come up from downriver: more men for the Barra.", "Chegam canoas de rio abaixo: mais homens para a Barra.",
     "Llegan canoas de río abajo: más hombres para la Barra.", SW)
line("n_s_gun", "narrator", "A gun on the bluff is silent.", "Um canhão no alto calou-se.", "Un cañón del alto ha callado.", SW)
line("n_s_won", "narrator", "The guns are silent and the church is down. The bluff is the swarm's.", "Os canhões calaram-se e a igreja caiu. O alto é do enxame.",
     "Los cañones han callado y la iglesia ha caído. El alto es del enjambre.")
line("n_s_lost", "narrator", "The floods fall. The far bank dries, and the Barra still stands.", "A cheia baixa. A outra margem seca, e a Barra continua de pé.",
     "La crecida baja. La otra orilla se seca, y la Barra sigue en pie.")
# ---- the endings
line("v_end1", "valadares", "We held the bluff. Nazaré's people slept in the church, the canoes on the bank below.",
     "Segurámos o alto. A gente de Nazaré dormiu na igreja, as canoas na margem lá em baixo.",
     "Sostuvimos el alto. La gente de Nazaré durmió en la iglesia, las canoas en la orilla de abajo.")
line("v_end_held", "valadares", "The lower town stood. Every roof.", "A cidade baixa ficou de pé. Todos os telhados.", "La ciudad baja quedó en pie. Todos los tejados.")
line("v_end_burned", "valadares", "The lower town burned. We held only what stood on the bluff.", "A cidade baixa ardeu. Só segurámos o que estava no alto.",
     "La ciudad baja ardió. Solo sostuvimos lo que estaba en el alto.")
line("v_end_burnt_book", "valadares", "I burned the book with my own hand, as Rome ordered.", "Queimei o livro com a minha mão, como Roma mandou.",
     "Quemé el libro con mi propia mano, como Roma ordenó.")
line("v_end_used_book", "valadares", "I used the book once. Then I burned it. I have confessed it.", "Usei o livro uma vez. Depois queimei-o. Já me confessei disso.",
     "Usé el libro una vez. Luego lo quemé. Ya me he confesado de ello.")
line("k_end1", "king", "He held the river for me that year. He did it with muskets, and once, with a dead man's book.",
     "Ele segurou o rio para mim nesse ano. Fê-lo com mosquetes, e uma vez com o livro de um homem perdido.",
     "Él me sostuvo el río aquel año. Lo hizo con mosquetes, y una vez con el libro de un hombre perdido.")
line("k_end1b", "king", "He held the river for me that year. With muskets, and without the book. That was harder.",
     "Ele segurou o rio para mim nesse ano. Com mosquetes, e sem o livro. Isso foi mais difícil.",
     "Él me sostuvo el río aquel año. Con mosquetes, y sin el libro. Eso fue más difícil.")
line("k_end2", "king", "The swarm did not go back up the rivers. It waited in the flooded forest for the next floods.",
     "O enxame não voltou a subir os rios. Esperou na floresta alagada pela cheia seguinte.",
     "El enjambre no volvió a subir los ríos. Esperó en el bosque inundado a la siguiente crecida.")
line("k_end_s", "king", "That is not how it went. Valadares held the bluff. But I have kept this page.",
     "Não foi assim que aconteceu. Valadares segurou o alto. Mas guardei esta página.",
     "No fue así como ocurrió. Valadares sostuvo el alto. Pero he guardado esta página.")
line("n_end_s", "narrator", "The church burned on the bluff. The swarm's ground crept over the Barra by the dry season.",
     "A igreja ardeu no alto. O chão do enxame rastejou sobre a Barra antes da estação seca.",
     "La iglesia ardió en el alto. El suelo del enjambre se arrastró sobre la Barra antes de la estación seca.")

# ---- stills
M["stills"] = {
    "rome": {"image": STILL % "b01_01", "caption": T("Rome, the present. The King with the mapmaker's report.", "Roma, o presente. O Rei com o relatório do cartógrafo.",
                                                    "Roma, el presente. El Rey con el informe del cartógrafo.")},
    "waters": {"image": STILL % "d08_01", "caption": T("The Barra do Rio Negro, where the black river meets the brown, the floods of 2778.",
                                                      "A Barra do Rio Negro, onde o rio negro encontra o pardo, a cheia de 2778.",
                                                      "La Barra del Río Negro, donde el río negro se junta con el pardo, la crecida de 2778.")},
    "nazare": {"image": STILL % "d08_02", "caption": T("Nazaré, the canoes.", "Nazaré, as canoas.", "Nazaré, las canoas.")},
    "book": {"image": STILL % "d08_03", "caption": T("The lure book, by the fire.", "O livro dos engodos, junto ao fogo.", "El libro de los señuelos, junto al fuego.")},
    "dawn": {"image": STILL % "d08_04", "caption": T("The bluff at first light.", "O alto ao primeiro clarão.", "El alto a la primera luz.")},
}
M["opening"] = {
    "barra": [{"still": "rome", "lines": ["k_open1", "k_open2", {"id": "k_linnea", "if": LINNEA_SEEN}]},
              {"still": "waters", "lines": ["v_open1", "v_open2"]}],
    "swarm": [{"still": "rome", "lines": ["k_open_s"]}, {"still": "waters", "lines": ["n_open_s"]}],
}
M["ending"] = {
    "barra": [
        {"still": "dawn", "lines": ["v_end1", {"id": "v_end_held", "if": {"flag": {"barra": "held"}}}, {"id": "v_end_burned", "if": {"flag": {"barra": "burned"}}},
                                    {"id": "v_end_burnt_book", "if": {"flag": {"lure": "burned"}}}, {"id": "v_end_used_book", "if": {"flag": {"lure": "used"}}}]},
        {"still": "rome", "lines": [{"id": "k_end1", "if": {"flag": {"lure": "used"}}}, {"id": "k_end1b", "if": {"not": {"flag": {"lure": "used"}}}}, "k_end2"]},
    ],
    "swarm": [{"still": "waters", "lines": ["n_end_s"]}, {"still": "rome", "lines": ["k_end_s"]}],
}
M["briefing"] = {
    "barra": {"still": "waters", "text": [
        T("The Rio Negro, the floods of 2778. You are Valadares and the Barra do Rio Negro: a column at the north gate, the garrison on the bluff, two guns and the town.",
          "O Rio Negro, a cheia de 2778. Você é Valadares e a Barra do Rio Negro: uma coluna na porta norte, a guarnição no alto, dois canhões e a vila.",
          "El Río Negro, la crecida de 2778. Eres Valadares y la Barra del Río Negro: una columna en la puerta norte, la guarnición del alto, dos cañones y el pueblo."),
        T("First take the column up the bank trail to Nazaré and send its people to Benedito's canoes. Then come home: the swarm crosses the shallows in waves.",
          "Primeiro leve a coluna pelo trilho da margem até Nazaré e mande a sua gente para as canoas de Benedito. Depois volte: o enxame atravessa os baixios em vagas.",
          "Primero lleva la columna por la senda de la orilla hasta Nazaré y manda a su gente a las canoas de Benedito. Luego vuelve: el enjambre cruza los bajíos en oleadas."),
        T("At dusk you will decide what to do with Lindqvist's lure book. The church and the Town Hall must stand.",
          "Ao anoitecer vai decidir o que fazer com o livro dos engodos de Lindqvist. A igreja e a Câmara têm de ficar de pé.",
          "Al anochecer decidirás qué hacer con el libro de los señuelos de Lindqvist. La iglesia y el Cabildo deben seguir en pie.")]},
    "swarm": {"still": "waters", "text": [
        T("The Rio Negro, the floods of 2778. You are the swarm: two forward Mothers on the far bank, their Sires, and what they lay.",
          "O Rio Negro, a cheia de 2778. Você é o enxame: duas Mães avançadas na outra margem, os seus Sires, e o que elas põem.",
          "El Río Negro, la crecida de 2778. Eres el enjambre: dos Madres de avanzada en la otra orilla, sus Señores, y lo que ponen."),
        T("Catch Nazaré's people before the canoes take them, root a Mother opposite the Barra, and break the Barra: its two guns and its church, before the floods fall.",
          "Apanhe a gente de Nazaré antes que as canoas a levem, enraíze uma Mãe em frente da Barra, e rompa a Barra: os seus dois canhões e a igreja, antes que a cheia baixe.",
          "Atrapa a la gente de Nazaré antes de que se la lleven las canoas, enraíza a una Madre frente a la Barra, y rompe la Barra: sus dos cañones y su iglesia, antes de que baje la crecida.")]},
}
M["debrief"] = {
    "barra": {"still": "dawn", "title": T("The Barra Holds", "A Barra Aguenta", "La Barra Resiste"),
              "text": T("Of Nazaré's {vill_n} people, {out_n} came down the river. {q_left} of the lower town's {q_n} houses stand.",
                        "Das {vill_n} pessoas de Nazaré, {out_n} desceram o rio. {q_left} das {q_n} casas da cidade baixa estão de pé.",
                        "De las {vill_n} personas de Nazaré, {out_n} bajaron por el río. {q_left} de las {q_n} casas de la ciudad baja siguen en pie."),
              "text_if": [
                  {"if": {"flag": {"lure": "used"}}, "text": T("The lure book was used once, then burned.", "O livro dos engodos foi usado uma vez, depois queimado.",
                                                               "El libro de los señuelos se usó una vez, luego se quemó.")},
                  {"if": {"flag": {"lure": "burned"}}, "text": T("The lure book was burned, as Rome ordered.", "O livro dos engodos foi queimado, como Roma mandou.",
                                                                 "El libro de los señuelos se quemó, como Roma ordenó.")}]},
    "swarm": {"still": "waters", "title": T("The Bluff Falls", "O Alto Cai", "El Alto Cae"),
              "text": T("The guns are silent and the church is down. Of Nazaré's {vill_n} people, {out_n} got away.",
                        "Os canhões calaram-se e a igreja caiu. Das {vill_n} pessoas de Nazaré, {out_n} escaparam.",
                        "Los cañones han callado y la iglesia ha caído. De las {vill_n} personas de Nazaré, {out_n} escaparon.")},
}

# ================================================================== the waves (the solo Barra)
# each: (seconds after Part 2's start, [(kind, n, ford, cond)]); ford "s" = the Barra shallows into the lower town,
# "m" = the middle shallows and down the bank trail to the north gate
ROUTE = {
    "s": ["s_w", "ford_s", "s_e", "west_gate", "bluff_mid"],
    "m": ["mid_w", "ford_mid", "landing_mid", "trail_s", "north_gate", "bluff_mid"],
}
STAGE = {"s": "fb_s", "m": "fb_m"}
WAVES = [
    [("raptor", 3, "s", None), ("raptor", 1, "s", NOT_BN_FEW), ("spitter", 1, "s", None)],
    [("raptor", 3, "m", None), ("raptor", 2, "s", None), ("spitter", 2, "s", NOT_BURNED_CLUTCH)],
    [("raptor", 4, "s", None), ("raptor", 1, "s", NOT_BN_FEW), ("spitter", 2, "s", None), ("tyrant_challenger", 1, "s", None)],
    [("raptor", 4, "m", None), ("venom_challenger", 1, "m", None), ("raptor", 3, "s", NOT_BURNED_CLUTCH), ("spitter", 2, "s", None)],
    [("raptor", 5, "s", None), ("raptor", 1, "s", NOT_BN_FEW), ("spitter", 3, "s", None), ("tyrant_challenger", 1, "s", None),
     ("raptor", 3, "m", None)],
]


def wave_triggers(i, at, rows):
    wid = "wave_%d" % (i + 1)
    acts = [{"counter": {"name": "wave_n", "set": i + 1}}, {"say": ["n_wave"]}]
    for j, (k, n, f, c) in enumerate(rows):
        sp = {"team": "swarm", "kind": k, "count": n, "at": STAGE[f], "tag": "w%d%s" % (i + 1, f), "tags": ["waves", "swarm_all"]}
        if c:
            sp["if"] = c
        acts.append({"spawn": sp})
    # every forward Mother rooted: two Raptors more (laid by her, from her clearing), the d06 all: two more
    for m, f in (("fwd_m", "m"), ("fwd_s", "s")):
        acts.append({"spawn": {"team": "swarm", "kind": "raptor", "count": 2, "near": m, "at": STAGE[f], "tag": "w%d%s" % (i + 1, f),
                               "tags": ["waves", "swarm_all"], "if": {"all": [{"fired": m + "_root"}, {"not": {"dead": m}}]}}})
    acts.append({"spawn": {"team": "swarm", "kind": "raptor", "count": 2, "at": "fb_s", "tag": "w%ds" % (i + 1), "tags": ["waves", "swarm_all"],
                           "if": BN_ALL}})
    out = [{"id": wid, "when": {"all": [{"fired": "part2"}, SOLO_B, LIVE]}, "delay": at, "do": acts}]
    # (they gather on the far bank for a moment, then cross: the paths shown as they come, a03 `map` withheld)
    go = []
    for f in ("s", "m"):
        go.append({"order": {"tag": "w%d%s" % (i + 1, f), "do": "route", "route": ROUTE[f], "attack": True, "name": "w%d%s" % (i + 1, f)}})
    go.append({"ping": {"area": "ford_s"}})
    if any(r[2] == "m" for r in rows):
        go.append({"ping": {"area": "ford_mid"}})
    out.append({"id": wid + "_go", "when": {"fired": wid}, "delay": 6, "do": go})
    # (stragglers that stand about: pushed on to the bluff)
    out.append({"id": wid + "_push", "when": {"all": [{"fired": wid + "_go"}, LIVE]}, "delay": 40, "every": 15, "times": 6, "do": [
        {"order": {"tag": "w%ds" % (i + 1), "do": "attack", "to": "bluff_mid", "idle": True}},
        {"order": {"tag": "w%dm" % (i + 1), "do": "attack", "to": "bluff_mid", "idle": True}}]})
    return out


# ================================================================== the triggers
TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"counter": {"name": "vill_n", "count": {"tag": "villagers"}}},
        {"counter": {"name": "q_n", "count": {"tag": "quarters", "buildings": True}}},
        {"counter": {"name": "guns_left", "count": {"tag": "guns"}}},
        {"brood_stage": {"tag": "mothers", "stage": 2}},
        {"spare": {"tag": "benedito", "on": True}},
        {"order": {"tag": "villagers", "do": "hold"}}, {"order": {"tag": "benedito", "do": "hold"}},
        {"order": {"tag": "guns", "do": "hold"}}]},
    # the solo Barra (and versus): the forward Mother across the river stands, not yet rooted; her guard by her
    {"id": "setup_barra", "when": {"all": [{"time": 0.6}, BARRA]}, "do": [
        {"clock": {"name": "nazare", "secs": NAZARE_SECS}},
        {"objective": {"id": "s_nazare", "set": "hidden"}}]},
    {"id": "setup_guard", "when": {"all": [{"time": 0.6}, NO_SWARM]}, "do": [
        {"spare": {"tag": "fwd_n", "on": True}}, {"order": {"tag": "fwd_guard", "do": "hold"}}]},
    # the swarm played: her rooted (the scene as it stands), the Sires by her, food to start
    {"id": "setup_swarm", "when": {"all": [{"time": 0.6}, SWARM]}, "do": [
        {"root_now": {"tag": "fwd_n"}}, {"nest_free": {"tag": "sires", "on": True}}, {"root_now": {"tag": "sires"}},
        {"root_now": {"tag": "turtles"}},
        {"give": {"team": "swarm", "gold": SWARM_FOOD, "powder": SWARM_SPOILS}},
        {"ground": {"name": "fwd_n", "from": "fwd_n", "kind": "swamp", "team": "swarm", "r": 4, "step": 1, "every": 8, "max": 11}},
        {"clock": {"name": "floods", "secs": FLOODS_SECS}},
        {"max_hp": {"tag": "guns", "hp": GUN_HP}}]},
    # (the Barra scripted: it falls only by its guns and its church, the swarm's objective; its church built in stone)
    {"id": "setup_sb", "when": {"all": [{"time": 0.6}, NO_BARRA]}, "do": [
        {"objective": {"id": "church_live", "set": "hidden"}}, {"objective": {"id": "hall_live", "set": "hidden"}},
        {"max_hp": {"tag": "church", "hp": CHURCH_HP}}, {"order": {"tag": "garrison", "do": "hold"}}, {"order": {"tag": "guns_in", "do": "hold"}}]},
    {"id": "setup_noswarm_obj", "when": {"all": [{"time": 0.6}, NO_SWARM]}, "do": [
        {"objective": {"id": "s_nazare", "set": "hidden"}}, {"objective": {"id": "s_root", "set": "hidden"}},
        {"objective": {"id": "s_barra", "set": "hidden"}}, {"objective": {"id": "s_clock", "set": "hidden"}}]},
    {"id": "setup_vs", "when": {"all": [{"time": 0.7}, BARRA, SWARM]}, "do": [
        {"objective": {"id": "v_hold", "set": "active"}}]},
    {"id": "intro", "when": {"all": [{"time": 1.5}, BARRA]}, "do": [
        {"say": ["v_1", "n_lesson"]}, {"ping": {"area": "trail_mid"}}, {"ping": {"area": "nazare"}}]},
    {"id": "intro_base", "when": {"all": [{"time": 22}, BARRA, P1]}, "do": [{"say": ["n_base"]}]},
    {"id": "intro_map", "when": {"all": [{"time": 12}, BARRA, DRAWN]}, "do": [
        {"say": ["v_map"]}, {"ping": {"area": "rapids"}}, {"ping": {"area": "ford_mid"}}, {"ping": {"area": "ford_s"}},
        {"reveal": {"area": "ford_s", "side": "barra"}}, {"reveal": {"area": "ford_mid", "side": "barra"}}, {"reveal": {"area": "rapids", "side": "barra"}}]},
    {"id": "intro_sealed", "when": {"all": [{"time": 12}, BARRA, WITHHELD]}, "do": [{"say": ["v_sealed"]}]},
    {"id": "intro_party", "when": {"all": [{"time": 34}, BARRA, PARTY_FEW, P1]}, "do": [{"say": ["b_party_few"]}]},
    {"id": "intro_s", "when": {"all": [{"time": 1.5}, SWARM]}, "do": [{"say": ["n_s1", "n_s2"]}, {"ping": {"area": "fb_s"}}, {"ping": {"area": "nazare"}}]},
    # ============================================================ PART 1: NAZARÉ
] + [
    t for g in ("g_chapel", "g_houses", "g_fields") for t in [
        # a man of the Barra walked up to the group: it goes to the canoes by itself
        {"id": "call_" + g, "when": {"all": [{"stay": {"team": "barra", "area": g, "secs": CALL_SECS}}, BARRA, P1, LIVE]}, "do": [
            {"order": {"tag": g, "do": "move", "to": "canoes_n"}}, {"pace": {"tag": g, "pace": VILL_PACE}},
            {"counter": {"name": "called", "add": 1}}, {"say": [g]}]},
        # (the swarm played, no person on the Barra: they go by themselves after a little)
        {"id": "self_" + g, "when": {"all": [{"time": {"g_chapel": 20, "g_houses": 28, "g_fields": 36}[g]}, NO_BARRA, P1]}, "do": [
            {"order": {"tag": g, "do": "move", "to": "canoes_n"}}, {"pace": {"tag": g, "pace": VILL_PACE}}, {"counter": {"name": "called", "add": 1}}]},
    ]
] + [
    {"id": "first_out", "when": {"all": [{"counter": {"name": "out_n", "at_least": 1}}, BARRA, P1]}, "do": [{"say": ["b_first"]}]},
    {"id": "out_say_s", "when": {"all": [{"counter": {"name": "out_n", "at_least": 1}}, SWARM, P1]}, "do": [{"say": ["n_s_canoes"]}]},
    # the raiders over the rapids (the solo Barra): after the people
] + [
    {"id": "raid_%d" % (i + 1), "when": {"all": [{"time": at}, SOLO_B, P1, LIVE]}, "do": [
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 2 + (1 if i else 0), "at": "rapids_w", "tag": "raiders", "tags": ["swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "spitter", "count": 1, "at": "rapids_w", "tag": "raiders", "tags": ["swarm_all"], "if": {"time": 90}}},
        {"order": {"tag": "raiders", "do": "hunt", "prey": "villagers", "within": 60}},
        {"ping": {"area": "rapids"}}] + ([{"say": ["n_raid"]}] if i == 0 else [])}
    for i, at in enumerate(RAIDS)
] + [
    # (the raiders with no villager in reach go for the column)
    {"id": "raid_press", "when": {"all": [{"fired": "raid_1"}, P1, LIVE]}, "delay": 20, "every": 10, "do": [
        {"order": {"tag": "raiders", "do": "attack", "to": "nazare", "idle": True}}]},
    # the countdown runs out: the forward Mother roots, a big raid, Benedito waits a little
    {"id": "rooted_n", "when": {"all": [{"clock_out": "nazare"}, BARRA, P1, LIVE]}, "do": [
        {"spare": {"tag": "fwd_n", "on": False}}, {"root_now": {"tag": "fwd_n"}},
        {"ground": {"name": "fwd_n", "from": "fwd_n", "kind": "swamp", "team": "swarm", "r": 4, "step": 1, "every": 8, "max": 11}},
        {"say": ["n_rooted", "b_wait"]}, {"ping": {"area": "fb_n"}},
        {"clock": {"name": "canoes", "secs": CANOE_WAIT, "scale": False}},
        {"order": {"tag": "villagers", "do": "move", "to": "canoes_n"}}]},
    {"id": "rooted_raid", "when": {"all": [{"fired": "rooted_n"}, SOLO_B]}, "do": [
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 4, "at": "rapids_w", "tag": "raiders", "tags": ["swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "tyrant_challenger", "count": 1, "at": "rapids_w", "tag": "raiders", "tags": ["swarm_all"]}},
        {"order": {"tag": "raiders", "do": "hunt", "prey": "villagers", "within": 60}}]},
    {"id": "objs_p1", "when": {"all": [{"time": 1}, BARRA]}, "do": [{"objective": {"id": "nazare", "set": "active"}}]},
    # PART 2: the canoes cast off (every group away, or Benedito's wait is over; the swarm played: the people away or 2:30)
    {"id": "part2", "when": {"all": [{"time": 10}, LIVE, {"any": [
        {"all": [{"counter": {"name": "called", "at_least": 3}}, {"count": {"tag": "villagers", "below": 1}}]},
        {"clock_out": "canoes"},
        {"all": [SWARM, {"time": 150}]}]}]}, "do": [
        {"tally": {"flag": "nazare", "counter": "out_n", "of": "vill_n", "bands": [[0, "few"], [NAZ_SOME, "some"], [NAZ_ALL, "all"]]}},
        {"remove": {"tag": "villagers"}}, {"remove": {"tag": "benedito"}},
        {"clock": {"name": "nazare", "stop": True}}, {"clock": {"name": "canoes", "stop": True}},
        {"objective": {"id": "nazare_clock", "set": "hidden"}},
        {"spawn": {"team": "nazare", "kind": "labourer", "as": "benedito", "count": 1, "at": "landing_s", "tag": "benedito", "fixed": True}}]},
    {"id": "p2_nazare_done", "when": {"all": [{"fired": "part2"}, {"flag": {"nazare": "all"}}]}, "do": [{"objective": {"id": "nazare", "set": "done"}}]},
    {"id": "p2_nazare_some", "when": {"all": [{"fired": "part2"}, {"not": {"flag": {"nazare": "all"}}}]}, "do": [
        {"objective": {"id": "nazare", "set": "failed"}}, {"say": ["n_left"]}]},
    {"id": "p2_barra", "when": {"all": [{"fired": "part2"}, BARRA]}, "delay": 1, "do": [
        {"say": ["b_away", "v_2"]}, {"spare": {"tag": "benedito", "on": True}}, {"order": {"tag": "benedito", "do": "hold"}},
        {"objective": {"id": "bluff", "set": "active"}}, {"ping": {"area": "bluff_mid"}}, {"light": {"to": "jungle_dusk", "secs": 400}}]},
    {"id": "p2_say", "when": {"all": [{"fired": "part2"}, SOLO_B]}, "delay": 14, "do": [{"say": ["s_2", "n_waves"]}, {"ping": {"area": "ford_s"}}]},
    # (the raiders still about in Nazaré go home over the rapids)
    {"id": "p2_raiders", "when": {"all": [{"fired": "part2"}, NO_SWARM]}, "do": [{"order": {"tag": "raiders", "do": "attack", "to": "trail_mid", "idle": True}}]},
    # ============================================================ PART 2: THE FORWARD MOTHERS (the solo Barra)
    {"id": "fwd_m_go", "when": {"all": [{"fired": "part2"}, SOLO_B, LIVE]}, "delay": FWD_M_AT, "do": [
        {"spawn": {"team": "swarm", "kind": "brood_mother", "as": "bank_mother", "count": 1, "at": "road_n", "tag": "fwd_m", "tags": ["fwd", "mothers"], "fixed": True}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 2, "at": "road_n", "tag": "fwd_m_guard", "tags": ["swarm_all"]}},
        {"objective": {"id": "fwd", "set": "active"}}]},
    {"id": "fwd_m_walk", "when": {"fired": "fwd_m_go"}, "delay": 0.5, "do": [
        {"brood_stage": {"tag": "fwd_m", "stage": 2}},
        {"order": {"tag": "fwd_m", "do": "route", "route": ["road_n", "fb_n", "fb_m_spot"], "name": "fwd_m"}}, {"pace": {"tag": "fwd_m", "pace": MOTHER_PACE}},
        {"order": {"tag": "fwd_m_guard", "do": "follow", "leader": "fwd_m", "within": 3}},
        {"say": ["n_fwd"]}, {"ping": {"tag": "fwd_m"}}]},
    {"id": "fwd_s_go", "when": {"all": [{"fired": "part2"}, SOLO_B, LIVE]}, "delay": FWD_S_AT, "do": [
        {"spawn": {"team": "swarm", "kind": "brood_mother", "as": "bank_mother", "count": 1, "at": "fb_m", "tag": "fwd_s", "tags": ["fwd", "mothers"], "fixed": True}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 2, "at": "fb_m", "tag": "fwd_s_guard", "tags": ["swarm_all"]}}]},
    {"id": "fwd_s_walk", "when": {"fired": "fwd_s_go"}, "delay": 0.5, "do": [
        {"brood_stage": {"tag": "fwd_s", "stage": 2}},
        {"order": {"tag": "fwd_s", "do": "route", "route": ["fb_m", "far_stage", "fb_s_spot"], "name": "fwd_s"}}, {"pace": {"tag": "fwd_s", "pace": MOTHER_PACE}},
        {"order": {"tag": "fwd_s_guard", "do": "follow", "leader": "fwd_s", "within": 3}},
        {"say": ["n_fwd2"]}, {"ping": {"tag": "fwd_s"}}]},
] + [
    t for m in ("fwd_m", "fwd_s") for t in [
        {"id": m + "_root", "when": {"all": [{"route_done": m}, {"not": {"dead": m}}, SOLO_B, LIVE]}, "do": [
            {"root_now": {"tag": m}}, {"counter": {"name": "fwd_rooted", "add": 1}}, {"say": ["n_fwd_root"]}, {"ping": {"tag": m}},
            {"ground": {"name": m, "from": m, "kind": "swamp", "team": "swarm", "r": 4, "step": 1, "every": 6, "max": 12}}]},
        {"id": m + "_dead", "when": {"all": [{"dead": m}, {"not": {"fired": m + "_root"}}, SOLO_B, LIVE]}, "do": [
            {"counter": {"name": "fwd_killed", "add": 1}}, {"say": ["n_fwd_dead", "v_fwd_dead"]}]},
    ]
] + [
    {"id": "fwd_done", "when": {"all": [{"counter": {"name": "fwd_killed", "at_least": 1}}, SOLO_B]}, "do": [{"objective": {"id": "fwd", "set": "done"}}]},
    {"id": "fwd_failed", "when": {"all": [{"counter": {"name": "fwd_rooted", "at_least": 2}}, SOLO_B]}, "do": [{"objective": {"id": "fwd", "set": "failed"}}]},
    # the lower town hit; the palisade hit
    {"id": "quarter_hit", "when": {"all": [{"fired": "part2"}, {"hurt": "quarters"}, BARRA]}, "do": [{"say": ["s_quarter"]}, {"ping": {"area": "lower_town"}}]},
    {"id": "palisade_hit", "when": {"all": [{"fired": "part2"}, {"hurt": "palisade"}, BARRA]}, "do": [{"say": ["v_mend"]}]},
]
for i, at in enumerate(WAVE_AT):
    TR_ += wave_triggers(i, at, WAVES[i])
TR_ += [
    # ============================================================ PART 3: THE LURE BOOK (the solo Barra)
    {"id": "wave_5_late", "when": {"fired": "wave_5"}, "delay": 75, "do": []},
    {"id": "part3", "when": {"all": [{"fired": "wave_5_go"}, SOLO_B, LIVE, {"any": [
        {"count": {"tag": "waves", "below": 3}}, {"fired": "wave_5_late"}]}]}, "delay": 8, "do": [
        {"objective": {"id": "bluff", "set": "done"}}, {"say": ["n_dusk"]}, {"light": {"to": "jungle_night", "secs": 20}},
        {"order": {"tag": "waves", "do": "attack", "to": "bluff_mid", "idle": True}}]},
    {"id": "book_left", "when": {"all": [{"fired": "part3"}, BOOK_LEFT]}, "delay": 3, "do": [{"say": ["b_book"]}]},
    {"id": "book_taken", "when": {"all": [{"fired": "part3"}, BOOK_TAKEN]}, "delay": 3, "do": [{"say": ["b_book_taken"]}]},
    {"id": "the_choice", "when": {"fired": "part3"}, "delay": 5, "do": [
        {"say": ["b_lure"]},
        {"choice": {"id": "lure", "side": "barra", "default": "burned", "time": 75,
                    "title": T("THE LURE BOOK", "O LIVRO DOS ENGODOS", "EL LIBRO DE LOS SEÑUELOS"),
                    "line": "v_rome",
                    "options": [
                        {"id": "burned", "label": T("BURN IT", "QUEIMÁ-LO", "QUEMARLO"),
                         "about": T("Rome's order. The whole great wave comes over the Barra shallows tonight: the Barra holds by arms.",
                                    "A ordem de Roma. A grande vaga inteira atravessa os baixios da Barra esta noite: a Barra aguenta pelas armas.",
                                    "La orden de Roma. La gran oleada entera cruza los bajíos de la Barra esta noche: la Barra resiste por las armas."),
                         "do": [{"say": ["v_burn", "n_burn"]}]},
                        {"id": "used", "label": T("USE IT ONCE", "USÁ-LO UMA VEZ", "USARLO UNA VEZ"),
                         "about": T("Benedito sets the old lure on the far point: half the great wave turns into the flooded forest. Then the book burns.",
                                    "Benedito põe o engodo antigo na ponta da outra margem: metade da grande vaga desvia-se para a floresta alagada. Depois o livro arde.",
                                    "Benedito planta el señuelo antiguo en la punta de la otra orilla: la mitad de la gran oleada se desvía al bosque inundado. Luego el libro arde."),
                         "do": [{"say": ["v_use", "n_use"]}]}]}}]},
    # the great wave gathers on the far bank once the choice is made
    {"id": "great", "when": {"all": [{"fired": "the_choice"}, {"any": [{"flag": {"lure": "burned"}}, {"flag": {"lure": "used"}}]}, LIVE]}, "delay": 4, "do": [
        {"objective": {"id": "night", "set": "active"}}, {"objective": {"id": "dawn_clock", "set": "active"}},
        {"clock": {"name": "dawn", "secs": DAWN_SECS}}, {"say": ["n_night"]}, {"ping": {"area": "far_stage"}},
        # (half that the lure can turn, half that comes whatever)
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 5, "at": "far_stage", "tag": "great_a", "tags": ["great", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "spitter", "count": 2, "at": "far_stage", "tag": "great_a", "tags": ["great", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "tyrant_challenger", "count": 1, "at": "far_stage", "tag": "great_a", "tags": ["great", "swarm_all"], "fixed": True}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 2, "at": "far_stage", "tag": "great_a", "tags": ["great", "swarm_all"], "if": NOT_BN_FEW}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 5, "at": "fb_s", "tag": "great_b", "tags": ["great", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "spitter", "count": 2, "at": "fb_s", "tag": "great_b", "tags": ["great", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "brute", "count": 1, "at": "fb_s", "tag": "great_b", "tags": ["great", "swarm_all"], "fixed": True}},
        {"spawn": {"team": "swarm", "kind": "tyrannosaur", "count": 1, "at": "fb_s", "tag": "great_b", "tags": ["great", "swarm_all"], "fixed": True,
                   "if": NOT_BURNED_CLUTCH}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 3, "at": "fb_s", "tag": "great_b", "tags": ["great", "swarm_all"], "if": BN_ALL}}]},
    {"id": "great_count", "when": {"fired": "great"}, "delay": 0.5, "do": [{"counter": {"name": "great_n", "count": {"tag": "great"}}}]},
    {"id": "lure_set", "when": {"all": [{"fired": "great"}, {"flag": {"lure": "used"}}]}, "delay": 1, "do": [
        {"lure_post": {"tag": "far_lure", "at": "far_point", "pull": {"tag": "great_a", "within": LURE_R, "then": "drowned", "name": "drowned"}}},
        {"ping": {"area": "far_point"}}]},
    {"id": "lured_say", "when": {"lured": "far_lure"}, "delay": 2, "do": [{"say": ["n_lured"]}]},
    {"id": "drowned", "when": {"all": [{"route_done": "drowned"}, LIVE]}, "delay": 3, "do": [
        {"say": ["n_drowned"]}, {"remove": {"tag": "great_a"}}, {"ping": {"area": "drowned"}}]},
    {"id": "great_go", "when": {"all": [{"fired": "great"}, LIVE]}, "delay": GREAT_GO, "do": [
        {"say": ["n_go", "s_great"]}, {"ping": {"area": "ford_s"}},
        {"order": {"tag": "great_b", "do": "route", "route": ROUTE["s"], "attack": True, "name": "great_b"}}]},
    {"id": "great_go_a", "when": {"all": [{"fired": "great"}, {"flag": {"lure": "burned"}}, LIVE]}, "delay": GREAT_GO + 4, "do": [
        {"order": {"tag": "great_a", "do": "route", "route": ROUTE["s"], "attack": True, "name": "great_a"}}]},
    {"id": "great_push", "when": {"all": [{"fired": "great_go"}, LIVE]}, "delay": 45, "every": 12, "do": [
        {"order": {"tag": "great_b", "do": "attack", "to": "bluff_mid", "idle": True}},
        {"order": {"tag": "great_a", "do": "attack", "to": "bluff_mid", "idle": True, "if": {"flag": {"lure": "burned"}}}}]},
    # (the last few of the great wave, beaten, go back into the dark: nobody waits for dawn over a straggler)
    {"id": "great_ebb", "when": {"all": [{"fired": "great_go"}, {"count": {"tag": "great", "below": 4}}, {"not": {"fired": "broken"}}, LIVE]},
     "delay": 20, "do": [{"order": {"tag": "great", "do": "move", "to": "drowned"}}]},
    {"id": "great_gone", "when": {"all": [{"fired": "great_ebb"}, LIVE]}, "delay": 8, "do": [{"remove": {"tag": "great"}}]},
    # broken, or first light: won
    {"id": "broken", "when": {"all": [{"fired": "great_go"}, {"count": {"tag": "great", "below": 1}}, LIVE]}, "delay": 2, "do": [{"say": ["n_broken"]}]},
    {"id": "dawn", "when": {"all": [{"fired": "great"}, {"any": [{"fired": "broken"}, {"clock_out": "dawn"}]}, BARRA, LIVE]}, "delay": 2, "do": [
        {"objective": {"id": "night", "set": "done"}}, {"objective": {"id": "dawn_clock", "set": "done"}}, {"clock": {"name": "dawn", "stop": True}},
        {"light": {"to": "grey_dawn", "secs": 8}}, {"say": ["n_dawn", "v_won"]},
        {"order": {"tag": "swarm_all", "do": "move", "to": "drowned"}}]},
    # ============================================================ VERSUS: the Barra holds till the floods fall
    {"id": "vs_book", "when": {"all": [{"fired": "part2"}, BARRA, SWARM]}, "delay": 120, "do": [{"say": ["v_vs_burn"]}, {"flag": {"lure": "burned"}}]},
    {"id": "vs_floods", "when": {"all": [{"clock_out": "floods"}, BARRA, SWARM, LIVE]}, "do": [{"say": ["n_s_lost"]}, {"objective": {"id": "v_hold", "set": "done"}}]},
    # ============================================================ THE END (the Barra)
    {"id": "count_end", "when": {"any": [{"fired": "dawn"}, {"fired": "vs_floods"}, {"all": [{"clock_out": "floods"}, NO_BARRA]}]}, "do": [
        {"counter": {"name": "q_left", "count": {"tag": "quarters", "buildings": True}}},
        {"tally": {"flag": "barra", "counter": "q_left", "of": "q_n", "bands": [[0, "burned"], [HELD_SHARE, "held"]]}},
        {"flag": {"lure": "burned", "if": {"not": {"flag": {"lure": "used"}}}}}]},
    {"id": "the_end", "when": {"all": [{"fired": "count_end"}, {"any": [{"fired": "dawn"}, {"fired": "vs_floods"}, {"all": [{"clock_out": "floods"}, NO_BARRA]}]}]},
     "delay": 5, "do": [{"win": "barra"}]},
    {"id": "hall_lost", "when": {"any": [{"dead": "hall"}, {"dead": "church"}]}, "do": [{"say": ["n_hall_lost"]}]},
    # ============================================================ THE SWARM (the solo pick, versus)
    {"id": "s_objs", "when": {"all": [{"time": 1}, SWARM]}, "do": [
        {"objective": {"id": "s_nazare", "set": "active"}}, {"objective": {"id": "s_root", "set": "active"}},
        {"objective": {"id": "s_barra", "set": "active"}}, {"objective": {"id": "s_clock", "set": "active"}}]},
    {"id": "s_nazare_end", "when": {"all": [{"fired": "part2"}, SWARM]}, "do": [
        {"objective": {"id": "s_nazare", "set": "done", "if": {"not": {"flag": {"nazare": "all"}}}}},
        {"objective": {"id": "s_nazare", "set": "failed", "if": {"flag": {"nazare": "all"}}}}]},
    {"id": "s_rooted", "when": {"all": [SWARM, {"count": {"tag": "fwd", "area": "fb_s", "rooted": True, "at_least": 1}}]},
     "do": [{"objective": {"id": "s_root", "set": "done"}}, {"say": ["n_s_root"]}]},
    # (the floods' drowned game feeds the swarm a little at a time: laying never stalls for want of food)
    {"id": "s_food", "when": {"all": [SWARM, {"time": 10}, LIVE]}, "every": 10, "do": [
        {"give": {"team": "swarm", "gold": FLOOD_FOOD, "powder": FLOOD_SPOILS}}]},
    {"id": "s_guns", "when": {"all": [SWARM, {"fired": "setup"}, LIVE]}, "every": 2, "do": [{"counter": {"name": "guns_left", "count": {"tag": "guns"}}}]},
    {"id": "s_gun_say", "when": {"all": [SWARM, {"counter": {"name": "guns_left", "below": 2}}]}, "do": [{"say": ["n_s_gun"]}]},
    {"id": "s_broke", "when": {"all": [SWARM, {"dead": "guns"}, {"dead": "church"}, LIVE]}, "do": [
        {"objective": {"id": "s_barra", "set": "done"}}, {"say": ["n_s_won"]},
        {"flag": {"barra": "burned"}}, {"flag": {"lure": "burned"}}]},
    {"id": "s_end", "when": {"fired": "s_broke"}, "delay": 4, "do": [{"win": "swarm"}]},
    {"id": "vs_broke", "when": {"all": [BARRA, SWARM, {"any": [{"dead": "church"}, {"dead": "hall"}]}]}, "do": [
        {"flag": {"barra": "burned"}}, {"flag": {"lure": "burned"}}]},
    {"id": "s_floods", "when": {"all": [SWARM, NO_BARRA, {"clock_out": "floods"}, LIVE]}, "do": [
        {"say": ["n_s_lost"]}, {"objective": {"id": "s_clock", "set": "done"}}]},
    # the scripted Barra (the swarm played alone): the column goes up to Nazaré and back; canoes bring men up the river
    {"id": "sb_column", "when": {"all": [{"time": 6}, NO_BARRA]}, "do": [
        {"order": {"tag": "column", "do": "route", "route": ["north_gate", "trail_mid", "trail_n", "g_houses"], "attack": True, "name": "column_up"}},
        {"order": {"tag": "garrison", "do": "hold"}}]},
    {"id": "sb_home", "when": {"all": [{"fired": "part2"}, NO_BARRA]}, "delay": 4, "do": [
        {"order": {"tag": "column", "do": "route", "route": ["trail_n", "trail_mid", "north_gate", "bluff_mid"], "attack": True, "name": "column_home"}}]},
    {"id": "sb_hold", "when": {"route_done": "column_home"}, "do": [{"order": {"tag": "column", "do": "hold"}}]},
    {"id": "sb_reinf", "when": {"all": [{"time": 90}, NO_BARRA, LIVE]}, "every": 90, "do": [
        {"spawn": {"team": "barra", "kind": "musketeer", "count": 3, "at": "downriver", "tag": "reinf", "tags": ["barra_men"]}},
        {"order": {"tag": "reinf", "do": "attack", "to": "bluff_mid"}}, {"say": ["n_s_reinf"]}]},
    {"id": "sb_reinf_hold", "when": {"all": [{"fired": "sb_reinf"}, NO_BARRA, LIVE]}, "delay": 40, "every": 20, "do": [
        {"order": {"tag": "reinf", "do": "hold", "idle": True}}]},
    # ============================================================ HURTS
    {"id": "v_hurt", "when": {"all": [{"hp": {"tag": "valadares", "below": 0.4}}, BARRA]}, "every": 60, "times": 2, "do": [{"say": ["v_hurt"]}, {"ping": {"tag": "valadares"}}]},
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

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the swarm is bound to B6 (BIGGER CLUTCH, PACK HUNT, QUICK ROOTS)
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID)
for k in ("nb_clutch_raptor", "nb_pack_hunt", "nb_quick_roots"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hub after d08 (campaign/campaign.json)
OTHER = [
    ("A forward Mother", "Uma Mãe avançada", "Una Madre de avanzada"),
    ("A Brood Mother of the swarm, walking down the far bank to root on it.", "Uma Mãe da Ninhada do enxame, a descer a outra margem para lá enraizar.",
     "Una Madre de la Prole del enjambre, bajando por la otra orilla para enraizar en ella."),
    ("The Barra's sergeant", "O sargento da Barra", "El sargento de la Barra"),
    ("The sergeant of the Barra's garrison, twenty years on the Rio Negro.", "O sargento da guarnição da Barra, vinte anos no Rio Negro.",
     "El sargento de la guarnición de la Barra, veinte años en el Río Negro."),
    ("Valadares' Quarters at the Barra", "Os Aposentos de Valadares na Barra", "Los Aposentos de Valadares en la Barra"),
    ("After the floods the Naturalist's chart is in a Crown hand: Valadares' quarters in the fort at the Barra, the swarm's spread inked in green.",
     "Depois da cheia a carta do Naturalista está numa mão da Coroa: os aposentos de Valadares no forte da Barra, a expansão do enxame desenhada a verde.",
     "Tras la crecida la carta del Naturalista está en una mano de la Corona: los aposentos de Valadares en el fuerte de la Barra, la expansión del enjambre trazada en verde."),
    ("Valadares' quarters in the fort at the Barra: the chart on the table, the river through the window.",
     "Os aposentos de Valadares no forte da Barra: a carta na mesa, o rio pela janela.",
     "Los aposentos de Valadares en el fuerte de la Barra: la carta en la mesa, el río por la ventana."),
    ("VALADARES", "VALADARES", "VALADARES"),
    ("The floods are going down. Their ground does not.", "A cheia está a baixar. O chão deles não.", "La crecida está bajando. Su suelo no."),
    ("Every forward Mother roots a little nearer each season. A mile a week, in the floods.",
     "Cada Mãe avançada enraíza um pouco mais perto a cada estação. Uma milha por semana, na cheia.",
     "Cada Madre de avanzada enraíza un poco más cerca cada estación. Una milla por semana, en la crecida."),
    ("I burned the book. I would burn it again. I do not sleep well.", "Queimei o livro. Voltaria a queimá-lo. Não durmo bem.",
     "Quemé el libro. Volvería a quemarlo. No duermo bien."),
    ("I used the book once. The confessor gave me a penance, and I have done it.", "Usei o livro uma vez. O confessor deu-me uma penitência, e já a cumpri.",
     "Usé el libro una vez. El confesor me dio una penitencia, y ya la he cumplido."),
    ("Nazaré's people are in the church. All of them. The vicar counts them at every Mass.",
     "A gente de Nazaré está na igreja. Toda. O padre conta-a em cada missa.",
     "La gente de Nazaré está en la iglesia. Toda. El padre la cuenta en cada misa."),
    ("Some of Nazaré never reached the beach. I write their names in the report, one by one.",
     "Parte de Nazaré nunca chegou à praia. Escrevo os nomes deles no relatório, um a um.",
     "Parte de Nazaré nunca llegó a la playa. Escribo sus nombres en el informe, uno a uno."),
    ("The lower town burned. We are rebuilding it on the bluff, inside the palisade.", "A cidade baixa ardeu. Estamos a reconstruí-la no alto, dentro da paliçada.",
     "La ciudad baja ardió. La estamos reconstruyendo en el alto, dentro de la empalizada."),
    ("Lindqvist is somewhere downriver. Rome wants him. So do I.", "Lindqvist anda algures rio abaixo. Roma quer-no. Eu também.",
     "Lindqvist anda en algún lugar río abajo. Roma lo quiere. Yo también."),
    ("The bluff fell in that telling. In mine it stood, and I was on it.", "Naquele relato o alto caiu. No meu ficou de pé, e eu estava lá.",
     "En ese relato el alto cayó. En el mío resistió, y yo estaba allí."),
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
rows = ["# Act 2's mission d08_rivers, \"Down the Rivers\" (campaign/missions/d08_rivers.json, written with its texts by",
        "# tools/campaign/make_d08_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what was",
        "# built: docs/campaign_d08_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: shallows = baixios / bajíos; swarm =",
        "# enxame / enjambre; forward Mother = Mãe avançada / Madre de avanzada; lure = engodo / señuelo; bluff = alto / alto.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
