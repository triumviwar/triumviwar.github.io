#!/usr/bin/env python3
"""Writes campaign/missions/d03_fazenda.json: Act 2's "The Island" (the Naturalist line after the Council of Rome, the
lower Amazon, the dry season 2772; the plan: docs/campaign_act2_plan.md "d03_fazenda"; what was built:
docs/campaign_d03_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d03_fazenda.txt: every text here is
written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d03_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_obidos_island_map.py (campaign:obidos_island). EVERY LINE IS A PLACEHOLDER for the owner to
rewrite.

Two years after Rome. Lindqvist walked out of the Council with the specimens it ordered destroyed and went home to the
river: on a fazenda on an island below Óbidos (proposed) he breeds them in secret, sugar fields for show and pens in the
forest behind, sure that his LURES make them his. The Crown's commission comes up the river with Rome's order: Duarte
Valadares, who drew the cloud mountain for the Crown, and a magistrate, Desembargador Fonseca (proposed).
  THE STOCK (Brood, GREEN, p1): the young Mother (Linnea's daughter by b01 `clutch` saved; else a Mother netted on the
    plateau), the young from a05's cages (3 / 5 / 7 by `cages`; THE YOUNG SIRE among them with all), two Raptors more by
    b01 `eggs` taken, and Lindqvist's own people on the same team: Lindqvist, Pieter (by the flags) and the keepers, who
    carry the LURES. The new STORM SIRE hatches in Part 1 and fathers HATCHLINGS (THE ROSTER LADDER's B4).
  THE LEASH (the act's Brood lesson): the stock obeys only within 8 tiles of a lure (Lindqvist, Pieter, a keeper, a
    lure post); out of every lure's reach a creature is LOOSE and wanders where it likes.
  HIDDEN: the commission does not see the stock until it FINDS it: a creature that keeps STILL for 3 s lies low and is
    seen only from 3 tiles (4 with a03 `map` drawn: Valadares knows what to look for); one moving is seen as far as a
    searcher can see. Found is for good. While the commission is on the island the stock is quiet (no creature bites:
    Lindqvist's order), and the commission's men do not shoot the fazenda's people.
  THE COMMISSION (Crown, PURPLE; scripted solo, the SOLO PICK, versus p2): Valadares (who reads TRACKS), Fonseca, three
    search parties of musketeers and the riders, Benedito at the canoes.
  PART 1, THE BOAT ON THE RIVER: walk the stock from the old pens by the house into the deep forest north of the creek
    (under a lure), root the young Mother in the nest clearing; the Storm Sire hatches: root him beside her and lay
    Hatchlings (the stock's eyes over the canopy). The canoes land when the clock runs out (sooner when all is hidden).
  PART 2, THE SEARCH: the parties walk the island on routes and then on hunches; Valadares follows fresh tracks. Keep the
    stock still; move a pen away from a party (moving is seen); THE DINNER (Lindqvist at the big house's door keeps the
    magistrate and his party there a while); DECOYS (a keeper at the west point or the burnt chapel sets a lure post:
    the nearest party goes to it). Too much found (three quarters): Rome's order is carried out: lost.
  PART 3, THE LAST NIGHT: the commission camps at the landing; one young creature gets up and goes for the camp's goats:
    put a lure right under its nose (3 tiles) and walk it back into the deep forest before it gets there (a fight at the
    camp gives everything away: lost). Dawn: the commission leaves.
  NO CHOICE. CARRIES: `hidden` few / some / all (the share never found; `hidden_n`), `storm` hatched, `mother` linnea /
    plateau, `pieter` alive / lost, `dinner` given.
  MIRROR (THE COMMISSION, solo pick; versus): find and destroy half the stock before dawn without losing Valadares (the
    stock asleep in its pens: it wakes and fights when a searcher comes within 3 tiles). Canon-compatible (Valadares found
    some): a count, not a broken seal (the plan's Claude's choice 5).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d03_fazenda"

# ---------------------------------------------------------------- the texts, three languages at once
TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d03_fazenda.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
SAVED = notpast("b01_specimen.clutch", "burned")         # Linnea's own young among the stock (the canon)
BURNED = past("b01_specimen.clutch", "burned")
EGGS = past("b01_specimen.eggs", "taken")
FEW = past("a05_specimens.cages", "few")
ALL = past("a05_specimens.cages", "all")
NOT_FEW = {"not": FEW}
PIETER = {"all": [notpast("b01_specimen.pieter", "lost"), notpast("a05_specimens.pieter", "lost")]}
NO_PIETER = {"not": PIETER}
DRAWN = notpast("a03_plateau.map", "withheld")           # Valadares knows what to look for (the canon)
WITHHELD = past("a03_plateau.map", "withheld")
EXECUTED = past("a06_barricades.varenne", "executed")    # the keepers are Assembly men
STOCK = {"playing": "stock"}
NO_STOCK = {"not": STOCK}                  # the stock scripted: the commission is the solo pick
COM = {"playing": "commission"}
NO_COM = {"not": COM}
LIVE = {"not": {"any": [{"fired": "the_end"}, {"fired": "c_end"}, {"fired": "lost_found"}, {"fired": "lost_fight"}]}}

# ---------------------------------------------------------------- numbers
BOAT_SECS = 210              # Part 1: the canoes land (NORMAL; EASY x1.25, HARD x0.85: the countdown objective scales it)
STORM_AT = 45                # the Storm Sire's egg hatches
DUSK = {"drawn": 270, "withheld": 330}     # Part 2: the search (not scaled: a longer search is no kindness)
DAWN_SECS = 120              # Part 3: the last night
FIND = {"drawn": 2, "withheld": 2}         # tiles at which a still creature is found (lying low in the undergrowth)
SHADE = 0.6                  # the commission's sight in the island's forest shade (a share of its sight)
STILL_SECS = 3               # a creature still this long lies low
LOST_SHARE = 0.75            # found this share of the stock: Rome's order carried out (lost)
DINNER_SECS = 5              # Lindqvist at the house's door this long: the magistrate dines
DINNER_HOLD = 90             # ... and his party stays at the house this long
DECOY_SECS = 4               # a keeper at a decoy spot this long sets a lure post
RESTLESS_PACE = 0.38         # the restless young one's pace to the goats (time to get a lure to it)
RESTLESS_SLIP = 8            # ... it slips away from its keeper first: no lure holds it this long
PARTY = 4                    # musketeers a search party (scaled: EASY 3, HARD 5)
RESTLESS_KINDS = ["raptor", "spitter", "tyrant_challenger", "venom_challenger", "tyrannosaur"]

# the young from a05's cages: (kind, role, the condition) in the old pens; the young Mother and the Storm Sire apart
YOUNG = [
    ("raptor", None, None), ("raptor", None, None), ("spitter", None, None),                       # few
    ("tyrant_challenger", None, NOT_FEW), ("spitter", None, NOT_FEW),                              # some (canon)
    ("tyrannosaur", "young_sire", ALL), ("venom_challenger", None, ALL),                            # all
    ("raptor", None, EGGS), ("raptor", None, EGGS),                                                 # b01's eggs taken
]
# the scripted stock (the commission's mirror): each young one asleep in a deep pen
MIRROR_PEN = ["pen_1", "pen_2", "pen_3", "pen_4", "pen_5", "pen_1", "pen_3", "pen_2", "pen_5"]
# the island: the pens (deep: 1-6 north of the creek; near: 7-8), the decoy spots, the parties' roads
PENS = {"pen_1": [18, 10, 12, 8], "pen_2": [44, 7, 12, 7], "pen_3": [74, 8, 12, 8], "pen_4": [93, 22, 11, 8],
        "pen_5": [30, 26, 12, 8], "pen_6": [59, 23, 14, 10], "pen_7": [12, 51, 9, 7], "pen_8": [96, 47, 9, 7]}
# (the commission does not know where anything is: each party sweeps a part of the island; the nest clearing in the
# middle of the forest is found only on a hunch, by Valadares' tracking or a party's)
ROUTE_A = ["mill", "pen_7", "ford_w", "pen_5", "pen_1", "ford_w", "fields_w", "old_pens"]           # the west party
ROUTE_B = ["house", "old_pens", "ford_m", "pen_2", "pen_5", "ford_w", "fields_w", "house"]        # the magistrate's party
ROUTE_C = ["fields_e", "pen_8", "chapel", "ford_e", "pen_4", "pen_3", "ford_e", "fields_e"]        # the east party
ROUTE_R = ["fields_w", "old_pens", "house", "fields_e", "chapel", "fields_e", "old_pens"]         # the riders (south)
ROUTE_RN = ["fields_w", "ford_w", "pen_5", "pen_1", "ford_w", "fields_w"]                        # the riders, later (north-west)
ROUTE_H = ["ford_m", "pen_5", "pen_2", "pen_3", "ford_e", "fields_e"]                              # Valadares' hunch: the middle
ROUTE_V = ["house", "ford_m", "pen_3", "ford_e", "fields_e", "house", "ford_m", "pen_5", "ford_w"]  # Valadares, on tracks


def T3(en, pt, es):
    return T(en, pt, es)


# ================================================================== the mission
units = [
    # ---- the stock (the player): the young Mother, the young, Lindqvist's people with the lures
    {"team": "stock", "kind": "brood_mother", "as": "young_mother", "count": 1, "at": "old_pens", "tag": "mother",
     "tags": ["young", "leashed"], "fixed": True, "if": STOCK},
    {"team": "stock", "kind": "brood_mother", "as": "young_mother", "count": 1, "at": "pen_6", "tag": "mother",
     "tags": ["young", "sleep_6"], "fixed": True, "if": NO_STOCK},
] + [
    dict({"team": "stock", "kind": k, "count": 1, "at": "old_pens", "tag": "young_%d" % (i + 1),
          "tags": ["young", "leashed"], "fixed": True,
          "if": {"all": [STOCK] + ([c] if c else [])}}, **({"as": r} if r else {}))
    for i, (k, r, c) in enumerate(YOUNG)
] + [
    dict({"team": "stock", "kind": k, "count": 1, "at": MIRROR_PEN[i], "tag": "young_%d" % (i + 1),
          "tags": ["young", "sleep_" + MIRROR_PEN[i][-1]], "fixed": True, "if": {"all": [NO_STOCK] + ([c] if c else [])}}, **({"as": r} if r else {}))
    for i, (k, r, c) in enumerate(YOUNG)
] + [
    # (the mirror: the Storm Sire already hatched, asleep by her; two young ones loose in the forest leave tracks)
    {"team": "stock", "kind": "pterodactyl", "count": 1, "at": "pen_6", "tag": "storm_sire", "tags": ["sleep_6", "flyers"], "fixed": True, "if": NO_STOCK},
    {"team": "stock", "kind": "raptor", "count": 2, "at": "pen_5", "tag": "wanderer", "tags": ["young"], "fixed": True, "if": NO_STOCK},
    # Lindqvist's people: the lures
    {"team": "stock", "kind": "musketeer", "as": "lindqvist", "count": 1, "at": "old_pens", "tag": "lindqvist", "tags": ["lure", "people"]},
    {"team": "stock", "kind": "labourer", "as": "pieter", "count": 1, "at": "old_pens", "tag": "pieter", "tags": ["lure", "people", "keepers"], "if": PIETER},
    {"team": "stock", "kind": "musketeer", "as": "keeper", "count": 2, "at": "old_pens", "tag": "keeper", "tags": ["lure", "people", "keepers"], "fixed": True},
    {"team": "stock", "kind": "musketeer", "as": "assembly_keeper", "count": 2, "at": "house", "tag": "guards", "tags": ["people"], "fixed": True, "if": EXECUTED},
    # ---- the fazenda's people (scripted: the field hands, the house servants)
    {"team": "fazenda", "kind": "labourer", "as": "villager", "count": 3, "at": "fields_w", "tag": "hands", "fixed": True},
    {"team": "fazenda", "kind": "labourer", "as": "villager", "count": 3, "at": "fields_e", "tag": "hands", "fixed": True},
]

buildings = [
    {"team": "fazenda", "kind": "town_hall", "at": [58, 54], "tag": "big_house", "name": T("The big house", "A casa-grande", "La casa grande")},
    {"team": "fazenda", "kind": "farm", "at": [74, 60], "tag": "fazenda_b", "name": T("The cane field", "O canavial", "El cañaveral")},
    {"team": "fazenda", "kind": "farm", "at": [30, 58], "tag": "fazenda_b", "name": T("The cane field", "O canavial", "El cañaveral")},
    {"team": "fazenda", "kind": "cottage", "at": [48, 64], "tag": "fazenda_b"},
    {"team": "fazenda", "kind": "cottage", "at": [70, 52], "tag": "fazenda_b"},
]

areas = dict(
    {k: v for k, v in PENS.items()},
    old_pens=[37, 52, 12, 9], house=[54, 52, 12, 7], house_door=[55, 59, 10, 4], mill=[44, 50, 8, 6],
    fields_w=[26, 56, 14, 10], fields_e=[72, 56, 16, 10], landing=[48, 64, 24, 10], camp=[52, 64, 16, 5],
    canoes=[52, 70, 16, 3], goats=[70, 63, 4, 4],
    ford_w=[21, 39, 7, 7], ford_m=[57, 39, 7, 7], ford_e=[91, 36, 7, 7],
    deep=[6, 0, 108, 38], west_point=[7, 45, 8, 8], chapel=[99, 43, 12, 11], nest=[61, 24, 10, 8],
    south=[6, 46, 108, 30],
)
# (the approaches round each pen: a party here is near enough to warn of)
for k, (x, y, w, h) in PENS.items():
    areas["near_" + k] = [x - 6, y - 6, w + 12, h + 12]

objectives = [
    # ---- part 1
    {"id": "hide_stock", "side": "stock", "primary": False, "kind": "manual",
     "text": T("Move the stock into the deep forest, north of the creek: {deep} of {young_n} there. A creature follows orders only within reach of a lure (the green rings round Lindqvist, Pieter and the keepers): walk a keeper ahead and the creatures with him.",
               "Leve o plantel para a floresta funda, ao norte do igarapé: {deep} de {young_n} lá. Uma criatura só obedece dentro do alcance de um engodo (os anéis verdes à volta de Lindqvist, Pieter e os tratadores): leve um tratador à frente e as criaturas com ele.",
               "Lleva la cría al bosque hondo, al norte del arroyo: {deep} de {young_n} allí. Una criatura solo obedece al alcance de un señuelo (los anillos verdes alrededor de Lindqvist, Pieter y los cuidadores): lleva a un cuidador delante y a las criaturas con él."),
     "phone": T("Stock into the deep forest: {deep} of {young_n}. Keep them inside a lure's green ring.",
                "Plantel para a floresta funda: {deep} de {young_n}. Mantenha-os dentro do anel verde de um engodo.",
                "Cría al bosque hondo: {deep} de {young_n}. Mantenlos dentro del anillo verde de un señuelo.")},
    {"id": "root_mother", "side": "stock", "primary": False, "kind": "manual",
     "text": T("Root the young Mother in the nest clearing (marked, in the middle of the deep forest): select her and press ROOT there.",
               "Enraíze a jovem Mãe na clareira do ninho (marcada, no meio da floresta funda): selecione-a e aperte ENRAIZAR lá.",
               "Enraíza a la joven Madre en el claro del nido (marcado, en medio del bosque hondo): selecciónala y pulsa ENRAIZAR allí.")},
    {"id": "boat_clock", "side": "stock", "primary": False, "kind": "countdown", "clock": "boat",
     "text": T("The commission's canoes land in {clock:boat}.", "As canoas da comissão desembarcam em {clock:boat}.", "Las canoas de la comisión desembarcan en {clock:boat}.")},
    {"id": "storm", "side": "stock", "primary": False, "kind": "manual", "hidden": True,
     "text": T("The Storm Sire has hatched. Root him beside the young Mother (within a few steps of her), then pick HATCHLINGS on her card: a clutch of little flyers to watch the commission from above.",
               "O Sire da Tempestade chocou. Enraíze-o ao lado da jovem Mãe (a poucos passos dela), depois escolha FILHOTES no painel dela: uma ninhada de pequenos voadores para vigiar a comissão do alto.",
               "El Señor de la Tormenta ha eclosionado. Enraízalo junto a la joven Madre (a pocos pasos de ella), luego elige CRÍAS en su panel: una nidada de pequeños voladores para vigilar a la comisión desde arriba.")},
    # ---- part 2
    {"id": "search", "side": "stock", "primary": True, "kind": "manual", "hidden": True,
     "text": T("Keep the stock hidden until dusk ({clock:dusk}): {found} of {young_n} found. A creature that keeps STILL is seen only up close; one that moves is seen as far as a soldier can see. Three quarters found and Rome's order is carried out.",
               "Mantenha o plantel escondido até o anoitecer ({clock:dusk}): {found} de {young_n} encontrados. Uma criatura PARADA só é vista de perto; uma que se mexe é vista tão longe quanto um soldado vê. Três quartos encontrados e a ordem de Roma é cumprida.",
               "Mantén la cría escondida hasta el anochecer ({clock:dusk}): {found} de {young_n} encontrados. Una criatura QUIETA solo se ve de cerca; una que se mueve se ve tan lejos como ve un soldado. Tres cuartos encontrados y la orden de Roma se cumple."),
     "phone": T("Hide the stock till dusk ({clock:dusk}): {found} of {young_n} found. Still = seen only up close.",
                "Esconda o plantel até o anoitecer ({clock:dusk}): {found} de {young_n} encontrados. Parado = visto só de perto.",
                "Esconde la cría hasta el anochecer ({clock:dusk}): {found} de {young_n} encontrados. Quieta = vista solo de cerca.")},
    {"id": "dinner", "side": "stock", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE DINNER: walk Lindqvist to the big house's door and keep him there a moment. The magistrate and his party will dine with him for a while instead of searching.",
               "O JANTAR: leve Lindqvist à porta da casa-grande e mantenha-o lá um momento. O magistrado e o seu grupo vão jantar com ele por um tempo em vez de procurar.",
               "LA CENA: lleva a Lindqvist a la puerta de la casa grande y mantenlo allí un momento. El magistrado y su grupo cenarán con él un rato en vez de buscar.")},
    {"id": "decoy", "side": "stock", "primary": False, "kind": "manual", "hidden": True,
     "text": T("A DECOY: stand a keeper (or Pieter) at the west point or the burnt chapel for a moment. He sets a lure post there, and the nearest search party goes to see what it is.",
               "UM ENGANO: ponha um tratador (ou Pieter) na ponta oeste ou na capela queimada por um momento. Ele finca ali um poste-engodo, e o grupo de busca mais próximo vai ver o que é.",
               "UN SEÑUELO FALSO: pon a un cuidador (o a Pieter) en la punta oeste o en la capilla quemada un momento. Clava allí un poste-señuelo, y el grupo de búsqueda más cercano va a ver qué es.")},
    {"id": "lindqvist", "side": "stock", "primary": True, "kind": "protect", "tag": "lindqvist",
     "text": T("Dr. Lindqvist must live.", "O Dr. Lindqvist tem de viver.", "El Dr. Lindqvist debe vivir.")},
    # ---- part 3
    {"id": "night", "side": "stock", "primary": True, "kind": "manual", "hidden": True,
     "text": T("Keep the stock hidden through the night until the commission leaves at dawn ({clock:dawn}): {found} of {young_n} found.",
               "Mantenha o plantel escondido durante a noite até a comissão partir de madrugada ({clock:dawn}): {found} de {young_n} encontrados.",
               "Mantén la cría escondida durante la noche hasta que la comisión parta al alba ({clock:dawn}): {found} de {young_n} encontrados.")},
    {"id": "restless", "side": "stock", "primary": False, "kind": "manual", "hidden": True,
     "text": T("A young one is up and going for the goats by the commission's camp. Get a lure RIGHT BESIDE it (3 steps: a keeper or Lindqvist) before it reaches them, then walk it back into the deep forest.",
               "Um jovem levantou-se e vai atrás das cabras junto ao acampamento da comissão. Ponha um engodo MESMO AO LADO dele (3 passos: um tratador ou Lindqvist) antes que chegue a elas, depois leve-o de volta à floresta funda.",
               "Un joven se ha levantado y va a por las cabras junto al campamento de la comisión. Pon un señuelo JUSTO A SU LADO (3 pasos: un cuidador o Lindqvist) antes de que llegue a ellas, luego llévalo de vuelta al bosque hondo.")},
    # ---- the commission (the solo pick, versus)
    {"id": "c_find", "side": "commission", "primary": True, "kind": "manual",
     "text": T("Find the specimens and destroy them by Rome's order: {destroyed} destroyed, {half} needed ({found} found). Walk your parties through the forest: a sleeping creature is seen only from 3 steps, and it wakes and fights. Pale claw marks on the ground are fresh tracks.",
               "Encontre os espécimes e destrua-os por ordem de Roma: {destroyed} destruídos, {half} necessários ({found} encontrados). Leve os seus grupos pela floresta: uma criatura adormecida só é vista a 3 passos, e acorda e luta. Marcas de garras claras no chão são rastos frescos.",
               "Encuentra los especímenes y destrúyelos por orden de Roma: {destroyed} destruidos, {half} necesarios ({found} encontrados). Lleva a tus grupos por el bosque: una criatura dormida solo se ve a 3 pasos, y despierta y lucha. Las marcas de garras claras en el suelo son rastros frescos.")},
    {"id": "c_valadares", "side": "commission", "primary": True, "kind": "protect", "tag": "valadares",
     "text": T("Duarte Valadares must live.", "Duarte Valadares tem de viver.", "Duarte Valadares debe vivir.")},
    {"id": "c_dawn", "side": "commission", "primary": False, "kind": "countdown", "clock": "c_dawn", "hidden": True,
     "text": T("The canoes leave at dawn: {clock:c_dawn}.", "As canoas partem de madrugada: {clock:c_dawn}.", "Las canoas parten al alba: {clock:c_dawn}.")},
]

M = {
    "id": MID,
    "title": T("The Island", "A Ilha", "La Isla"),
    "summary": T("The lower Amazon, the dry season 2772. On a river island below Óbidos Lindqvist breeds the creatures Rome ordered destroyed. The Crown's commission comes up the river to search it.",
                 "O baixo Amazonas, a estação seca de 2772. Numa ilha do rio abaixo de Óbidos, Lindqvist cria as criaturas que Roma mandou destruir. A comissão da Coroa sobe o rio para a revistar.",
                 "El bajo Amazonas, la estación seca de 2772. En una isla del río por debajo de Óbidos, Lindqvist cría a las criaturas que Roma ordenó destruir. La comisión de la Corona sube el río para registrarla."),
    "map": "campaign:obidos_island",
    "voice": "d03",
    "light": "jungle_day",
    "floor": [0.74, 0.76, 0.66],
    "expansion_spots": False,
    # (the forest's shade: the commission sees less far on the island; no grey veil)
    "mist": {"sight": SHADE, "side": "commission", "weather": False},
    "manual_end": True,
    "needs": ["a07_council"],
    "modes": ["solo", "versus"],
    "solo_sides": ["stock", "commission"],
    "sides": [
        {"id": "stock", "name": T("The Stock", "O Plantel", "La Cría"),
         "about": T("Lindqvist's breeding stock on the island, and the people who keep it with the lures.",
                    "O plantel de criação de Lindqvist na ilha, e as pessoas que o guardam com os engodos.",
                    "La cría de Lindqvist en la isla, y la gente que la guarda con los señuelos.")},
        {"id": "commission", "name": T("The Commission", "A Comissão", "La Comisión"),
         "about": T("The Crown's commission with Rome's order: Duarte Valadares, Desembargador Fonseca and their musketeers.",
                    "A comissão da Coroa com a ordem de Roma: Duarte Valadares, o Desembargador Fonseca e os seus mosqueteiros.",
                    "La comisión de la Corona con la orden de Roma: Duarte Valadares, el Desembargador Fonseca y sus mosqueteros.")},
    ],
    "teams": [
        {"id": "stock", "side": "stock", "faction": "brood", "colour": 2, "start": "none", "camera": "old_pens", "gold": 300, "powder": 60,
         "control": {"solo": "p1", "versus": "p1", "foe": "script"}},
        {"id": "fazenda", "side": "stock", "faction": "crown", "colour": 3, "start": "none", "camera": "house",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "commission", "side": "commission", "faction": "crown", "colour": 4, "start": "none", "camera": "landing", "gold": 0, "powder": 300,
         "control": {"solo": "script", "versus": "p2"}},
    ],
    "areas": areas,
    "counters": {"young_n": {"start": 0}, "deep": {"start": 0}, "found": {"start": 0}, "destroyed": {"start": 0},
                 "half": {"start": 0}, "lost_at": {"start": 0}, "unfound": {"start": 0}, "alive": {"start": 0}, "warned": {"start": 0}, "left": {"start": 0}},
    "exits": [
        {"area": "canoes", "team": "commission", "counter": "left", "after": "dawn_go", "except": ["valadares", "fonseca", "benedito"]},
    ],
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["lindqvist"],
    "auto_tags": [{"team": "stock", "kind": "hatchlings", "tag": "hatchling"}],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "stock", "portrait": "res://campaign/hub/rome_king_face.png"},
        "lindqvist": {"name": T("Dr. Lindqvist", "Dr. Lindqvist", "Dr. Lindqvist"), "side": "stock", "portrait": "res://campaign/hub/station_lindqvist_face.png"},
        "pieter": {"name": T("Pieter", "Pieter", "Pieter"), "side": "stock"},
        "valadares": {"name": T("Duarte Valadares", "Duarte Valadares", "Duarte Valadares"), "side": "commission"},
        "fonseca": {"name": T("Desembargador Fonseca", "Desembargador Fonseca", "Desembargador Fonseca"), "side": "commission"},
        "benedito": {"name": T("Benedito", "Benedito", "Benedito"), "side": "commission"},
        "narrator": {"name": T("The Island", "A Ilha", "La Isla"), "side": "stock"},
    },
    "lines": {},
    "stills": {},
    "next": {"stock": "", "commission": ""},
}

L = M["lines"]


def line(lid, who, en, pt, es, to=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    return lid


ST, CO = "stock", "commission"
# ---- the opening (the King, then Lindqvist; the commission's: the King, then Valadares)
line("k_open1", "king", "Lindqvist walked out of Rome with the animals the Council had ordered destroyed. He went home to his river.",
     "Lindqvist saiu de Roma com os animais que o Concílio mandara destruir. Voltou para o seu rio.",
     "Lindqvist salió de Roma con los animales que el Concilio había ordenado destruir. Volvió a su río.")
line("k_open2", "king", "Two years later I sent Valadares up that river with Rome's order in his satchel.",
     "Dois anos depois mandei Valadares subir esse rio com a ordem de Roma na sacola.",
     "Dos años después mandé a Valadares subir ese río con la orden de Roma en la cartera.")
line("l_open1", "lindqvist", "An island below Óbidos. Sugar for the tax man, and behind the cane, the forest, and in the forest, my pens.",
     "Uma ilha abaixo de Óbidos. Açúcar para o cobrador, e atrás da cana, a floresta, e na floresta, os meus currais.",
     "Una isla por debajo de Óbidos. Azúcar para el recaudador, y detrás de la caña, el bosque, y en el bosque, mis corrales.")
line("l_open2", "lindqvist", "They were not monsters. They were a new kind of animal, and every animal can be bred. I had the lures. They came to the lures.",
     "Não eram monstros. Eram um novo tipo de animal, e todo animal pode ser criado. Eu tinha os engodos. Eles vinham aos engodos.",
     "No eran monstruos. Eran una nueva clase de animal, y todo animal se puede criar. Yo tenía los señuelos. Venían a los señuelos.")
line("l_open_linnea", "lindqvist", "And among them her daughter. Out of the clutch we carried from the station. Growing.",
     "E entre eles a filha dela. Da ninhada que trouxemos da estação. Crescendo.",
     "Y entre ellos su hija. De la nidada que sacamos de la estación. Creciendo.")
line("l_open_plateau", "lindqvist", "And a young Mother we netted on the mountain. My breeding stock.",
     "E uma jovem Mãe que apanhámos na montanha. O meu plantel de criação.",
     "Y una joven Madre que atrapamos en la montaña. Mi cría.")
line("k_open_c", "king", "Valadares wrote me a report from that island. It is the only honest account of it I have.",
     "Valadares escreveu-me um relatório daquela ilha. É o único relato honesto dela que tenho.",
     "Valadares me escribió un informe de aquella isla. Es el único relato honesto de ella que tengo.")
line("v_open_c", "valadares", "We came up the river at first light. Sugar on the banks, a white house, a doctor at the landing with his hat in his hand.",
     "Subimos o rio ao primeiro clarão. Açúcar nas margens, uma casa branca, um doutor no desembarque de chapéu na mão.",
     "Subimos el río con la primera luz. Azúcar en las orillas, una casa blanca, un doctor en el embarcadero con el sombrero en la mano.")
# ---- part 1
line("l_1", "lindqvist", "Pieter! A boat on the river, below the point. The Crown's flag. Get them out of the old pens. All of them. Into the forest, now.",
     "Pieter! Um barco no rio, abaixo da ponta. A bandeira da Coroa. Tirem-nos dos currais velhos. Todos. Para a floresta, já.",
     "¡Pieter! Un barco en el río, por debajo de la punta. La bandera de la Corona. Sacadlos de los corrales viejos. A todos. Al bosque, ya.", ST)
line("p_tip1", "pieter", "They follow the lures, Doctor, nothing else. The keepers go first, and the animals stay inside the ring. Out of it they wander.",
     "Eles seguem os engodos, Doutor, nada mais. Os tratadores vão à frente, e os animais ficam dentro do anel. Fora dele, vagueiam.",
     "Siguen a los señuelos, doctor, nada más. Los cuidadores van delante, y los animales se quedan dentro del anillo. Fuera de él, vagan.", ST)
line("p_tip2", "pieter", "Over the creek by a ford, then up the paths to the clearings. The young Mother roots best in the nest clearing, in the middle.",
     "Pelo igarapé num vau, depois pelos trilhos até as clareiras. A jovem Mãe enraíza melhor na clareira do ninho, no meio.",
     "Por el arroyo por un vado, luego por las sendas hasta los claros. La joven Madre enraíza mejor en el claro del nido, en el medio.", ST)
line("n_loose", "narrator", "A creature out of every lure's reach goes its own way. Bring a keeper to it.",
     "Uma criatura fora do alcance de todo engodo segue o seu próprio caminho. Leve-lhe um tratador.",
     "Una criatura fuera del alcance de todo señuelo va a su aire. Llévale un cuidador.", ST)
line("n_rooted", "narrator", "The young Mother settles in the nest clearing.", "A jovem Mãe assenta na clareira do ninho.", "La joven Madre se asienta en el claro del nido.", ST)
line("l_storm", "lindqvist", "The big egg. It is cracking. Pieter, the book. Write the hour.",
     "O ovo grande. Está a rachar. Pieter, o livro. Escreve a hora.", "El huevo grande. Se está rompiendo. Pieter, el libro. Escribe la hora.", ST)
line("l_storm2", "lindqvist", "Wings. A Storm Sire. The first one ever bred by a man. Root him by her, and she will lay for him.",
     "Asas. Um Sire da Tempestade. O primeiro alguma vez criado por um homem. Enraíza-o junto a ela, e ela porá para ele.",
     "Alas. Un Señor de la Tormenta. El primero jamás criado por un hombre. Enraízalo junto a ella, y pondrá para él.", ST)
line("l_hatch", "lindqvist", "Hatchlings. They will sit in the canopy and watch the river for me. Nobody looks up at a bird.",
     "Filhotes. Vão pousar na copa e vigiar o rio por mim. Ninguém olha para cima para um pássaro.",
     "Crías. Se posarán en la copa y vigilarán el río por mí. Nadie mira arriba a un pájaro.", ST)
line("p_ready", "pieter", "They are all in the forest, Doctor. Quiet. I can hear the oars.",
     "Estão todos na floresta, Doutor. Quietos. Já ouço os remos.", "Están todos en el bosque, doctor. Quietos. Ya oigo los remos.", ST)
line("p_warn", "pieter", "The canoes are rounding the point, Doctor. Not long now.", "As canoas estão a dobrar a ponta, Doutor. Falta pouco.",
     "Las canoas están doblando la punta, doctor. Queda poco.", ST)
# ---- part 2
line("n_land", "narrator", "The commission lands: musketeers in purple, a magistrate in black, and a man with a map case who looks at the ground before he looks at the house.",
     "A comissão desembarca: mosqueteiros de roxo, um magistrado de preto, e um homem com um estojo de mapas que olha para o chão antes de olhar para a casa.",
     "La comisión desembarca: mosqueteros de púrpura, un magistrado de negro, y un hombre con un estuche de mapas que mira al suelo antes de mirar la casa.")
line("f_land", "fonseca", "Doctor Lindqvist. I carry an order of the Holy See and of His Majesty. You know its contents.",
     "Doutor Lindqvist. Trago uma ordem da Santa Sé e de Sua Majestade. Conhece o seu conteúdo.",
     "Doctor Lindqvist. Traigo una orden de la Santa Sede y de Su Majestad. Conoce su contenido.")
line("l_land", "lindqvist", "Sugar, Desembargador. Sugar and a few goats. Search what you like.", "Açúcar, Desembargador. Açúcar e umas cabras. Procure o que quiser.",
     "Azúcar, Desembargador. Azúcar y unas cabras. Registre lo que quiera.", ST)
line("v_land", "valadares", "I have seen what you keep, Doctor. On the mountain. I will know its prints.",
     "Eu vi o que o senhor guarda, Doutor. Na montanha. Vou reconhecer as pegadas.", "He visto lo que usted guarda, doctor. En la montaña. Conoceré sus huellas.")
line("v_land_w", "valadares", "I do not know what I am looking for, Doctor. So I will look at everything.",
     "Não sei o que procuro, Doutor. Por isso vou olhar para tudo.", "No sé lo que busco, doctor. Así que lo miraré todo.")
line("p_still", "pieter", "Keep them still, Doctor. A still animal in the forest is a shadow. A moving one is an animal.",
     "Mantenha-os quietos, Doutor. Um animal parado na floresta é uma sombra. Um que se mexe é um animal.",
     "Manténgalos quietos, doctor. Un animal quieto en el bosque es una sombra. Uno que se mueve es un animal.", ST)
line("l_quiet", "lindqvist", "And no one bites. No one. I told the keepers: not a shot fired on this island while the Crown is here.",
     "E ninguém morde. Ninguém. Disse aos tratadores: nem um tiro nesta ilha enquanto a Coroa estiver cá.",
     "Y nadie muerde. Nadie. Dije a los cuidadores: ni un tiro en esta isla mientras la Corona esté aquí.", ST)
line("l_dinner", "lindqvist", "The Desembargador has come a long way. He will be hungry. I will ask him to dine.",
     "O Desembargador veio de longe. Terá fome. Vou convidá-lo para jantar.", "El Desembargador ha venido de lejos. Tendrá hambre. Lo invitaré a cenar.", ST)
line("f_dinner", "fonseca", "Dinner? Well. The search can spare its magistrate for an hour. Sergeant, your men with me.",
     "Jantar? Bem. A busca pode dispensar o seu magistrado por uma hora. Sargento, os seus homens comigo.",
     "¿Cena? Bien. La búsqueda puede prescindir de su magistrado una hora. Sargento, sus hombres conmigo.")
line("v_dinner", "valadares", "Go and eat, Desembargador. I am not hungry.", "Vá comer, Desembargador. Eu não tenho fome.", "Vaya a comer, Desembargador. Yo no tengo hambre.")
line("f_dinner_end", "fonseca", "A fine table, Doctor. Now. Back to work, men.", "Uma bela mesa, Doutor. Agora, ao trabalho, homens.", "Una buena mesa, doctor. Ahora, a trabajar, hombres.")
line("p_decoy", "pieter", "A lure post at the west point, or at the old chapel, and they will go and look at it. Men always go and look.",
     "Um poste-engodo na ponta oeste, ou na capela velha, e eles vão lá olhar. Os homens vão sempre olhar.",
     "Un poste-señuelo en la punta oeste, o en la capilla vieja, y irán a mirarlo. Los hombres siempre van a mirar.", ST)
line("n_decoy", "narrator", "A lure post set. A search party turns off its road to see what it is.",
     "Um poste-engodo fincado. Um grupo de busca sai do seu caminho para ver o que é.", "Un poste-señuelo clavado. Un grupo de búsqueda deja su camino para ver qué es.", ST)
line("n_party", "narrator", "A search party is coming near a pen. Keep them still, or move them away under a lure.",
     "Um grupo de busca aproxima-se de um curral. Mantenha-os quietos, ou afaste-os sob um engodo.",
     "Un grupo de búsqueda se acerca a un corral. Mantenlos quietos, o apártalos bajo un señuelo.", ST)
line("n_found", "narrator", "Found. They have seen one of the stock. Get it away under a lure before they shoot it.",
     "Encontrado. Viram um do plantel. Afaste-o sob um engodo antes que o abatam.", "Encontrado. Han visto a uno de la cría. Apártalo bajo un señuelo antes de que lo maten.", ST)
line("p_riders", "pieter", "The riders have crossed the creek at the west ford, Doctor. They are going up the paths now.",
     "Os cavaleiros atravessaram o igarapé no vau oeste, Doutor. Estão a subir os trilhos agora.",
     "Los jinetes han cruzado el arroyo por el vado del oeste, doctor. Ahora suben por las sendas.", ST)
line("v_hunch", "valadares", "Everything on this island walks from the middle out. We look in the middle.",
     "Tudo nesta ilha anda do meio para fora. Vamos procurar no meio.", "Todo en esta isla camina del medio hacia fuera. Buscaremos en el medio.")
line("v_tracks", "valadares", "Fresh prints. Three toes, a dragged claw. This way.", "Pegadas frescas. Três dedos, uma garra arrastada. Por aqui.",
     "Huellas frescas. Tres dedos, una garra arrastrada. Por aquí.")
line("v_found", "valadares", "There. You see it? Sugar and goats, the Doctor said.", "Ali. Está a ver? Açúcar e cabras, disse o Doutor.", "Allí. ¿Lo ve? Azúcar y cabras, dijo el doctor.")
line("l_found", "lindqvist", "No. Not that one. Pieter, move them. Move the others.", "Não. Esse não. Pieter, mexe-os. Mexe os outros.", "No. Ese no. Pieter, muévelos. Mueve a los otros.", ST)
line("p_half", "pieter", "They have found half of them, Doctor. If they find many more, they will burn the pens and the house with them.",
     "Encontraram metade, Doutor. Se encontrarem muitos mais, queimam os currais e a casa com eles.",
     "Han encontrado la mitad, doctor. Si encuentran muchos más, quemarán los corrales y la casa con ellos.", ST)
line("p_dusk", "pieter", "The light is going. They will not search the forest in the dark.", "A luz está a ir-se. Não vão procurar na floresta às escuras.",
     "La luz se va. No buscarán en el bosque a oscuras.", ST)
# ---- part 3
line("n_night", "narrator", "Night. The commission camps at the landing to leave at dawn. Fires, a guard, the goats penned by the boats.",
     "Noite. A comissão acampa no desembarque para partir de madrugada. Fogueiras, uma guarda, as cabras presas junto aos barcos.",
     "Noche. La comisión acampa en el embarcadero para partir al alba. Hogueras, una guardia, las cabras encerradas junto a las barcas.")
line("p_restless", "pieter", "Doctor! One of the young is up. It smells the goats. It is going for the camp!",
     "Doutor! Um dos jovens levantou-se. Sente o cheiro das cabras. Vai para o acampamento!",
     "¡Doctor! Uno de los jóvenes se ha levantado. Huele las cabras. ¡Va hacia el campamento!", ST)
line("l_restless", "lindqvist", "A lure under its nose, right under it, or it will not turn. If it reaches those goats they will see everything.",
     "Um engodo debaixo do nariz, mesmo debaixo, ou não se vira. Se chegar àquelas cabras, eles vão ver tudo.",
     "Un señuelo bajo su hocico, justo debajo, o no se volverá. Si llega a esas cabras lo verán todo.", ST)
line("l_held", "lindqvist", "Got it. Easy now. Back to the forest, slowly.", "Apanhei-o. Calma. De volta à floresta, devagar.", "Lo tengo. Tranquilo. De vuelta al bosque, despacio.", ST)
line("p_back", "pieter", "It is back in the forest, Doctor. It is lying down.", "Está de volta à floresta, Doutor. Está a deitar-se.", "Está de vuelta en el bosque, doctor. Se está echando.", ST)
line("n_fight", "narrator", "The young one is among the goats. A sentry fires; the camp is up with torches; the forest is full of eyes.",
     "O jovem está entre as cabras. Uma sentinela dispara; o acampamento levanta-se com tochas; a floresta está cheia de olhos.",
     "El joven está entre las cabras. Un centinela dispara; el campamento se levanta con antorchas; el bosque está lleno de ojos.")
line("v_fight", "valadares", "Torches! Into the forest, all of you! Now we know where they are.", "Tochas! Para a floresta, todos! Agora sabemos onde estão.",
     "¡Antorchas! ¡Al bosque, todos! Ahora sabemos dónde están.")
line("p_lost", "pieter", "They have found nearly all of them, Doctor. They are bringing the pitch for the pens.",
     "Encontraram quase todos, Doutor. Estão a trazer o breu para os currais.", "Han encontrado casi a todos, doctor. Traen la brea para los corrales.", ST)
line("n_dawn", "narrator", "Dawn. The commission walks down to its canoes.", "Madrugada. A comissão desce para as suas canoas.", "El alba. La comisión baja a sus canoas.")
line("f_dawn", "fonseca", "We found what we found, Doctor. It will all be in my report, and in Rome.",
     "Encontrámos o que encontrámos, Doutor. Tudo estará no meu relatório, e em Roma.",
     "Encontramos lo que encontramos, doctor. Todo estará en mi informe, y en Roma.")
line("v_dawn", "valadares", "You did not breed them, Doctor. Nobody breeds a thing like that. Somebody made it, long ago, and it is still being made.",
     "O senhor não os criou, Doutor. Ninguém cria uma coisa destas. Alguém a fez, há muito tempo, e ela continua a ser feita.",
     "Usted no los crió, doctor. Nadie cría una cosa así. Alguien la hizo, hace mucho, y se sigue haciendo.")
line("l_dawn", "lindqvist", "Superstition. They evolved. Everything evolves.", "Superstição. Eles evoluíram. Tudo evolui.", "Superstición. Evolucionaron. Todo evoluciona.", ST)
# ---- the commission's (the solo pick) lines in the parts
line("v_c1", "valadares", "Three parties, Desembargador: the west paths, the middle and the east. The riders take the fields. I follow the prints.",
     "Três grupos, Desembargador: os trilhos a oeste, o meio e o leste. Os cavaleiros ficam com os campos. Eu sigo as pegadas.",
     "Tres grupos, Desembargador: las sendas del oeste, el medio y el este. Los jinetes, los campos. Yo sigo las huellas.", CO)
line("v_c_tip", "valadares", "They sleep in the clearings in the day. Walk close, and have your muskets ready: a sleeping one sees you at three steps.",
     "Dormem nas clareiras de dia. Andem perto, e tenham os mosquetes prontos: um adormecido vê-vos a três passos.",
     "Duermen en los claros de día. Caminad cerca, y tened los mosquetes listos: uno dormido os ve a tres pasos.", CO)
line("v_c_tracks", "valadares", "Pale claw marks on the ground are fresh prints. They lead to the ones that walk.",
     "Marcas de garras claras no chão são pegadas frescas. Levam aos que andam.", "Las marcas de garras claras en el suelo son huellas frescas. Llevan a los que caminan.", CO)
line("f_c_dinner", "fonseca", "The Doctor asks me to dine. I will go, Valadares. Somebody must watch the man himself.",
     "O Doutor convida-me para jantar. Irei, Valadares. Alguém tem de vigiar o próprio homem.",
     "El doctor me invita a cenar. Iré, Valadares. Alguien debe vigilar al hombre mismo.", CO)
line("v_c_night", "valadares", "Night. They will move in the dark: watch the camp and the goats.",
     "Noite. Vão mexer-se no escuro: vigiem o acampamento e as cabras.", "Noche. Se moverán en la oscuridad: vigilad el campamento y las cabras.", CO)
line("v_c_won", "valadares", "Enough. Burn the pens. Write it down, Desembargador: we found them.",
     "Basta. Queimem os currais. Escreva, Desembargador: encontrámo-los.", "Basta. Quemad los corrales. Escríbalo, Desembargador: los encontramos.", CO)
line("v_c_lost", "valadares", "Dawn, and the canoes. We found too little. He will say we found nothing.",
     "Madrugada, e as canoas. Encontrámos pouco demais. Ele vai dizer que não encontrámos nada.",
     "El alba, y las canoas. Encontramos demasiado poco. Él dirá que no encontramos nada.", CO)
line("n_c_found", "narrator", "A specimen found. It wakes.", "Um espécime encontrado. Acorda.", "Un espécimen encontrado. Despierta.", CO)
# ---- the endings
line("l_end1", "lindqvist", "They left at dawn. The Desembargador wrote his report. Valadares wrote another.",
     "Partiram de madrugada. O Desembargador escreveu o seu relatório. Valadares escreveu outro.",
     "Partieron al alba. El Desembargador escribió su informe. Valadares escribió otro.")
line("l_end_all", "lindqvist", "They found nothing. Nothing. I stood at the landing and waved my hat.",
     "Não encontraram nada. Nada. Fiquei no desembarque a acenar o chapéu.", "No encontraron nada. Nada. Me quedé en el embarcadero agitando el sombrero.")
line("l_end_some", "lindqvist", "They found some, and burned what they found. The rest lay in the forest and did not move.",
     "Encontraram alguns, e queimaram o que encontraram. O resto ficou na floresta e não se mexeu.",
     "Encontraron algunos, y quemaron lo que encontraron. El resto se quedó en el bosque y no se movió.")
line("l_end_few", "lindqvist", "They found most of them. I watched the pens burn from the house. I kept what was left.",
     "Encontraram a maioria. Vi os currais arder da casa. Guardei o que sobrou.", "Encontraron a la mayoría. Vi arder los corrales desde la casa. Guardé lo que quedó.")
line("l_end_storm", "lindqvist", "And the Storm Sire flew over the canopy every evening after, and came back to the lure.",
     "E o Sire da Tempestade voava sobre a copa todas as tardes depois, e voltava ao engodo.",
     "Y el Señor de la Tormenta volaba sobre la copa cada tarde después, y volvía al señuelo.")
line("k_end1", "king", "He tells it as if he won. Valadares found more than he thinks. Valadares found enough to know what was on that island.",
     "Ele conta como se tivesse ganhado. Valadares encontrou mais do que ele pensa. Valadares encontrou o bastante para saber o que havia naquela ilha.",
     "Él lo cuenta como si hubiera ganado. Valadares encontró más de lo que él cree. Valadares encontró lo bastante para saber qué había en aquella isla.")
line("k_end2", "king", "And Lindqvist still believes the thing evolved. The Church told him what it was. He did not listen then either.",
     "E Lindqvist ainda acredita que a coisa evoluiu. A Igreja disse-lhe o que era. Também não ouviu nessa altura.",
     "Y Lindqvist todavía cree que la cosa evolucionó. La Iglesia le dijo lo que era. Tampoco escuchó entonces.")
line("v_end_c", "valadares", "We burned the pens we found. The Doctor stood at the landing with his hat in his hand, and did not look at the smoke.",
     "Queimámos os currais que encontrámos. O Doutor ficou no desembarque de chapéu na mão, e não olhou para o fumo.",
     "Quemamos los corrales que encontramos. El doctor se quedó en el embarcadero con el sombrero en la mano, y no miró el humo.")
line("k_end_c", "king", "He told me Valadares found nothing. Valadares found enough.", "Ele disse-me que Valadares não encontrou nada. Valadares encontrou o bastante.",
     "Él me dijo que Valadares no encontró nada. Valadares encontró lo bastante.")
line("v_end_c_lost", "valadares", "We left at dawn with half a report. I knew they were there. I could smell them.",
     "Partimos de madrugada com meio relatório. Eu sabia que estavam lá. Sentia-lhes o cheiro.",
     "Partimos al alba con medio informe. Sabía que estaban allí. Los olía.")
line("n_lost", "narrator", "The commission has found the stock. By Rome's order the pens are burned.",
     "A comissão encontrou o plantel. Por ordem de Roma os currais são queimados.", "La comisión ha encontrado la cría. Por orden de Roma los corrales se queman.")
line("h_hurt", "lindqvist", "My leg. Pieter, the lures. Keep them together.", "A minha perna. Pieter, os engodos. Mantém-nos juntos.", "Mi pierna. Pieter, los señuelos. Mantenlos juntos.", ST)
line("n_guards", "narrator", "Lindqvist's guards are Assembly men now, paid in sugar and silence.", "Os guardas de Lindqvist são agora homens da Assembleia, pagos em açúcar e silêncio.",
     "Los guardias de Lindqvist son ahora hombres de la Asamblea, pagados en azúcar y silencio.", ST)
line("n_no_pieter", "narrator", "Pieter did not come back from the mountain. Two keepers carry the lures.",
     "Pieter não voltou da montanha. Dois tratadores levam os engodos.", "Pieter no volvió de la montaña. Dos cuidadores llevan los señuelos.", ST)

# ---- stills
M["stills"] = {
    "island": {"image": STILL % "d03_01", "caption": T("An island below Óbidos, the dry season 2772: the fazenda.", "Uma ilha abaixo de Óbidos, a estação seca de 2772: a fazenda.",
                                                    "Una isla por debajo de Óbidos, la estación seca de 2772: la fazenda.")},
    "pens": {"image": STILL % "d03_02", "caption": T("The pens in the forest, and the lure.", "Os currais na floresta, e o engodo.", "Los corrales en el bosque, y el señuelo.")},
    "commission": {"image": STILL % "d03_03", "caption": T("The Crown's commission lands.", "A comissão da Coroa desembarca.", "La comisión de la Corona desembarca.")},
    "storm": {"image": STILL % "d03_04", "caption": T("The Storm Sire over the canopy.", "O Sire da Tempestade sobre a copa.", "El Señor de la Tormenta sobre la copa.")},
    "rome": {"image": STILL % "b01_08", "caption": T("Rome, the present. The King and his prisoner, the doctor.", "Roma, o presente. O Rei e o seu prisioneiro, o doutor.",
                                                    "Roma, el presente. El Rey y su prisionero, el doctor.")},
}
M["opening"] = {
    "stock": [{"still": "rome", "lines": ["k_open1", "k_open2"]},
              {"still": "island", "lines": ["l_open1", "l_open2", {"id": "l_open_linnea", "if": SAVED}, {"id": "l_open_plateau", "if": BURNED}]}],
    "commission": [{"still": "rome", "lines": ["k_open_c"]}, {"still": "commission", "lines": ["v_open_c"]}],
}
M["ending"] = {
    "stock": [
        {"still": "storm", "lines": ["l_end1", {"id": "l_end_all", "if": {"flag": {"hidden": "all"}}}, {"id": "l_end_some", "if": {"flag": {"hidden": "some"}}},
                                     {"id": "l_end_few", "if": {"flag": {"hidden": "few"}}}, "l_end_storm"]},
        {"still": "rome", "lines": ["k_end1", "k_end2"]},
    ],
    "commission": [{"still": "commission", "lines": ["v_end_c"]}, {"still": "rome", "lines": ["k_end_c"]}],
}
M["briefing"] = {
    "stock": {"still": "pens", "text": [
        T("The lower Amazon, the dry season 2772. You are Lindqvist's breeding stock on his island, and the people who keep it with the lures.",
          "O baixo Amazonas, a estação seca de 2772. Você é o plantel de criação de Lindqvist na sua ilha, e as pessoas que o guardam com os engodos.",
          "El bajo Amazonas, la estación seca de 2772. Eres la cría de Lindqvist en su isla, y la gente que la guarda con los señuelos."),
        T("The creatures obey only near a lure. Walk them from the old pens into the deep forest before the Crown's commission lands, then keep them still and hidden until it leaves at dawn.",
          "As criaturas só obedecem perto de um engodo. Leve-as dos currais velhos para a floresta funda antes que a comissão da Coroa desembarque, depois mantenha-as quietas e escondidas até ela partir de madrugada.",
          "Las criaturas solo obedecen cerca de un señuelo. Llévalas de los corrales viejos al bosque hondo antes de que desembarque la comisión de la Corona, y luego mantenlas quietas y escondidas hasta que se vaya al alba."),
        T("Nothing bites while the commission is on the island. If it finds three quarters of the stock, Rome's order is carried out.",
          "Nada morde enquanto a comissão estiver na ilha. Se encontrar três quartos do plantel, a ordem de Roma é cumprida.",
          "Nada muerde mientras la comisión esté en la isla. Si encuentra tres cuartos de la cría, la orden de Roma se cumple.")]},
    "commission": {"still": "commission", "text": [
        T("The lower Amazon, the dry season 2772. You are the Crown's commission: Duarte Valadares, Desembargador Fonseca and their musketeers, with Rome's order.",
          "O baixo Amazonas, a estação seca de 2772. Você é a comissão da Coroa: Duarte Valadares, o Desembargador Fonseca e os seus mosqueteiros, com a ordem de Roma.",
          "El bajo Amazonas, la estación seca de 2772. Eres la comisión de la Corona: Duarte Valadares, el Desembargador Fonseca y sus mosqueteros, con la orden de Roma."),
        T("Search the island. Find the specimens Lindqvist hides in the forest and destroy half of them before your canoes leave at dawn. Valadares must live.",
          "Reviste a ilha. Encontre os espécimes que Lindqvist esconde na floresta e destrua metade deles antes que as suas canoas partam de madrugada. Valadares tem de viver.",
          "Registra la isla. Encuentra los especímenes que Lindqvist esconde en el bosque y destruye la mitad antes de que tus canoas partan al alba. Valadares debe vivir.")]},
}
M["debrief"] = {
    "stock": {"still": "storm", "title": T("The Island", "A Ilha", "La Isla"),
              "text": T("The commission left at dawn. It found {found} of the {young_n} young; {unfound} were never found.",
                        "A comissão partiu de madrugada. Encontrou {found} dos {young_n} jovens; {unfound} nunca foram encontrados.",
                        "La comisión partió al alba. Encontró {found} de los {young_n} jóvenes; {unfound} nunca fueron encontrados."),
              "text_if": [
                  {"if": {"flag": {"storm": "hatched"}}, "text": T("The Storm Sire hatched on the island.", "O Sire da Tempestade chocou na ilha.", "El Señor de la Tormenta eclosionó en la isla.")},
                  {"if": {"flag": {"dinner": "given"}}, "text": T("The magistrate dined at the big house.", "O magistrado jantou na casa-grande.", "El magistrado cenó en la casa grande.")}]},
    "commission": {"still": "commission", "title": T("Found", "Encontrados", "Encontrados"),
                   "text": T("The commission found {found} specimens and destroyed {destroyed} by Rome's order.",
                             "A comissão encontrou {found} espécimes e destruiu {destroyed} por ordem de Roma.",
                             "La comisión encontró {found} especímenes y destruyó {destroyed} por orden de Roma.")},
}


# ================================================================== the triggers
def party(tag, route, at, n=PARTY, extra=None, name=None):
    """A scripted search party (the commission's player is not playing): spawned at the canoes, sent round its road."""
    sp = [{"spawn": {"team": "commission", "kind": "musketeer", "count": n, "at": at, "tag": tag, "tags": ["searchers", "com_men"], "if": NO_COM}}]
    return sp + (extra or []) + [{"order": {"tag": tag, "do": "route", "route": route, "loop": True, "name": name or tag, "if": NO_COM}}]


TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"spare": {"tag": "hands", "on": True}}, {"spare": {"tag": "big_house", "on": True}}, {"spare": {"tag": "fazenda_b", "on": True}},
        {"counter": {"name": "young_n", "count": {"tag": "young"}}},
        {"brood_stage": {"tag": "mother", "stage": 2}},
        {"deny": {"team": "stock", "kind": ["grub", "rootmaw", "mound_turtle", "raptor", "spitter", "tyrannosaur", "dilophosaurus"],
                  "why": T("Not on the island: Lindqvist breeds only from his stock.", "Não na ilha: Lindqvist só cria a partir do seu plantel.",
                           "No en la isla: Lindqvist solo cría a partir de su cría.")}}]},
    # the stock played: the leash, the hiding, the tracks
    {"id": "setup_stock", "when": {"all": [{"time": 0.6}, STOCK]}, "do": [
        {"leash": {"tag": "leashed", "lure": "lure", "within": 8, "loose": "wander", "name": "stock"}},
        {"ground": {"name": "pens_swamp", "from": "mother", "kind": "swamp", "team": "stock", "r": 3, "max": 3, "every": 30}}]},
    # the stock scripted (the commission is the solo pick): asleep in the deep pens, waking when a searcher is close
    {"id": "setup_mirror", "when": {"all": [{"time": 0.6}, NO_STOCK]}, "do":
        [{"sleep": {"tag": "sleep_%d" % i, "name": "pen_%d" % i, "within": 3, "by": "commission", "hurt": True,
                    "then": {"do": "hunt", "prey": "com_men", "within": 14}}} for i in range(1, 7)]
        + [{"leash": {"tag": "wanderer", "lure": "no_lure", "within": 1, "loose": "wander", "name": "wanderers"}},
           {"order": {"tag": "people", "do": "move", "to": "house"}}]},
    {"id": "boat_clock_go", "when": {"all": [{"time": 1}, STOCK]}, "do": [{"clock": {"name": "boat", "secs": BOAT_SECS}}]},
    {"id": "boat_clock_c", "when": {"all": [{"time": 1}, NO_STOCK]}, "do": [{"clock": {"name": "boat", "secs": 20, "scale": False}},
                                                                            {"objective": {"id": "boat_clock", "set": "hidden"}},
                                                                            {"objective": {"id": "hide_stock", "set": "hidden"}},
                                                                            {"objective": {"id": "root_mother", "set": "hidden"}}]},
    {"id": "intro", "when": {"all": [{"time": 1.5}, STOCK]}, "do": [{"say": ["l_1", "p_tip1"]}, {"ping": {"area": "deep"}}, {"ping": {"area": "ford_m"}}]},
    {"id": "intro2", "when": {"fired": "intro"}, "delay": 16, "do": [{"say": ["p_tip2"]}, {"ping": {"area": "nest"}}]},
    {"id": "no_pieter", "when": {"all": [{"fired": "intro"}, NO_PIETER]}, "delay": 30, "do": [{"say": ["n_no_pieter"]}]},
    {"id": "guards", "when": {"all": [{"fired": "intro"}, EXECUTED]}, "delay": 34, "do": [{"say": ["n_guards"]}]},
    {"id": "intro_c", "when": {"all": [{"time": 1.5}, COM]}, "do": [{"say": ["v_c1"]}]},
    # ============================================================ PART 1: THE BOAT ON THE RIVER
    {"id": "deep_count", "when": {"all": [{"time": 2}, {"not": {"fired": "part2"}}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "deep", "count": {"tag": "young", "area": "deep"}}}]},
    {"id": "loose_say", "when": {"all": [{"loose": {"name": "stock"}}, STOCK, {"not": {"fired": "part2"}}]}, "do": [{"say": ["n_loose"]}]},
    {"id": "mother_rooted", "when": {"all": [{"rooted": {"tag": "mother"}}, {"count": {"tag": "mother", "area": "deep"}}, STOCK]}, "do": [
        {"objective": {"id": "root_mother", "set": "done"}}, {"say": ["n_rooted"]}]},
    {"id": "storm_hatch", "when": {"all": [{"time": STORM_AT}, STOCK]}, "do": [
        {"spawn": {"team": "stock", "kind": "pterodactyl", "count": 1, "near": "mother", "at": "old_pens", "tag": "storm_sire", "tags": ["leashed", "flyers"], "fixed": True}},
        {"say": ["l_storm", "l_storm2"]}, {"ping": {"tag": "storm_sire"}},
        {"objective": {"id": "storm", "set": "active"}}, {"flag": {"storm": "hatched"}},
        {"give": {"team": "stock", "gold": 200, "powder": 40}}]},
    {"id": "storm_rooted", "when": {"all": [{"rooted": {"tag": "storm_sire"}}, STOCK]}, "do": [{"say": ["l_hatch"]}]},
    {"id": "hatched", "when": {"all": [{"count": {"team": "stock", "kind": "hatchlings", "at_least": 1}}, STOCK]}, "do": [
        {"objective": {"id": "storm", "set": "done"}}, {"spare": {"tag": "hatchling", "on": True}}]},
    # (the Hatchlings are the stock's eyes: the commission takes them for birds and never shoots at them)
    {"id": "hatch_spare", "when": {"all": [{"fired": "hatched"}, LIVE]}, "every": 3, "do": [{"spare": {"tag": "hatchling", "on": True}}]},
    # (the Storm Sire too: over the canopy the commission takes him for a great bird; he dives on nobody while it is here)
    {"id": "storm_spare", "when": {"all": [{"fired": "part2"}, LIVE]}, "every": 3, "do": [
        {"spare": {"tag": "flyers", "on": True}}, {"carry": {"tag": "flyers", "on": True, "pace": 1.0, "if": STOCK}}]},
    {"id": "p_warn", "when": {"all": [{"clock_left": {"name": "boat", "below": 45}}, {"not": {"fired": "part2"}}, STOCK]}, "do": [{"say": ["p_warn"]}]},
    # NO WAITING: everything hidden early and the Mother rooted: the canoes come round the point at once
    {"id": "ready", "when": {"all": [{"time": 20}, STOCK, {"done": "root_mother"}, {"not": {"fired": "part2"}},
                                     {"any": [{"done": "storm"}, {"time": STORM_AT + 60}]},
                                     {"count": {"tag": "young", "area": "south", "below": 1}}, LIVE]}, "do": [
        {"say": ["p_ready"]}, {"clock": {"name": "boat", "add": -600}}]},
    # ============================================================ PART 2: THE SEARCH
    {"id": "part2", "when": {"all": [{"clock_out": "boat"}, LIVE]}, "do": [
        {"clock": {"name": "boat", "stop": True}}, {"objective": {"id": "boat_clock", "set": "hidden"}},
        {"objective": {"id": "hide_stock", "set": "hidden"}}, {"objective": {"id": "root_mother", "set": "hidden"}},
        {"objective": {"id": "search", "set": "active"}},
        {"hide": {"tag": "young", "from": "commission", "within": FIND["drawn"], "still": STILL_SECS, "name": "pens", "counter": "found", "if": DRAWN}},
        {"hide": {"tag": "young", "from": "commission", "within": FIND["withheld"], "still": STILL_SECS, "name": "pens", "counter": "found", "if": WITHHELD}},
        {"tracks": {"tag": "young", "for": "commission", "secs": 60}},
        {"spare": {"tag": "people", "on": True}},
        {"counter": {"name": "lost_at", "count": {"tag": "young"}}},
        {"clock": {"name": "dusk", "secs": DUSK["drawn"], "scale": False, "if": DRAWN}},
        {"clock": {"name": "dusk", "secs": DUSK["withheld"], "scale": False, "if": WITHHELD}},
        # the commission lands: Valadares, the magistrate, Benedito with the canoes
        {"spawn": {"team": "commission", "kind": "dismounted", "as": "valadares", "count": 1, "at": "canoes", "tag": "valadares", "tags": ["com_men", "searchers"], "fixed": True}},
        {"spawn": {"team": "commission", "kind": "dismounted", "as": "fonseca", "count": 1, "at": "canoes", "tag": "fonseca", "fixed": True}},
        {"spawn": {"team": "commission", "kind": "labourer", "as": "benedito", "count": 1, "at": "canoes", "tag": "benedito", "fixed": True}},
        {"spare": {"tag": "benedito", "on": True}}, {"spare": {"tag": "fonseca", "on": True}}, {"spare": {"tag": "valadares", "on": True, "if": STOCK}},
        {"ping": {"area": "landing"}}]},
    # (a person leads the commission: all its men are his, at the canoes)
    {"id": "part2_c", "when": {"all": [{"fired": "part2"}, COM]}, "do": [
        {"spawn": {"team": "commission", "kind": "musketeer", "count": 12, "at": "landing", "tag": "searchers", "tags": ["com_men"], "fixed": True}},
        {"spawn": {"team": "commission", "kind": "cuirassier", "count": 4, "at": "landing", "tag": "riders", "tags": ["com_men"], "fixed": True}},
        {"camera": {"area": "landing", "side": "commission"}}, {"objective": {"id": "c_dawn", "set": "active"}},
        {"clock": {"name": "c_dawn", "secs": DUSK["drawn"] + DAWN_SECS, "scale": False, "if": DRAWN}},
        {"clock": {"name": "c_dawn", "secs": DUSK["withheld"] + DAWN_SECS, "scale": False, "if": WITHHELD}},
        {"say": ["v_c_tip", "v_c_tracks"]}, {"ping": {"area": "deep"}}]},
    # the scripted search parties
    {"id": "parties", "when": {"all": [{"fired": "part2"}, NO_COM]}, "delay": 3, "do":
        party("party_a", ROUTE_A, "landing") + party("party_b", ROUTE_B, "landing", extra=[{"order": {"tag": "fonseca", "do": "follow", "leader": "party_b", "within": 2}}])
        + party("party_c", ROUTE_C, "landing")
        + [{"spawn": {"team": "commission", "kind": "cuirassier", "count": 4, "at": "landing", "tag": "riders", "tags": ["searchers", "com_men"], "if": NO_COM}},
           {"order": {"tag": "riders", "do": "route", "route": ROUTE_R, "loop": True, "name": "riders"}},
           {"spawn": {"team": "commission", "kind": "musketeer", "count": 2, "at": "landing", "tag": "v_guard", "tags": ["searchers", "com_men"], "fixed": True, "if": NO_COM}},
           {"order": {"tag": "valadares", "do": "route", "route": ROUTE_V, "loop": True, "name": "valadares_road"}},
           {"order": {"tag": "v_guard", "do": "follow", "leader": "valadares", "within": 2}}]},
    {"id": "part2_say", "when": {"fired": "part2"}, "delay": 1, "do": [{"say": ["n_land", "f_land"]}]},
    {"id": "part2_say_s", "when": {"all": [{"fired": "part2_say"}, STOCK]}, "delay": 1, "do": [{"say": ["l_land"]}]},
    {"id": "part2_v", "when": {"all": [{"fired": "part2_say"}, DRAWN]}, "delay": 8, "do": [{"say": ["v_land"]}]},
    {"id": "part2_v_w", "when": {"all": [{"fired": "part2_say"}, WITHHELD]}, "delay": 8, "do": [{"say": ["v_land_w"]}]},
    {"id": "quiet", "when": {"all": [{"fired": "part2"}, STOCK]}, "delay": 14, "do": [
        {"say": ["p_still", "l_quiet"]}, {"carry": {"tag": "young", "on": True, "pace": 1.0}}, {"carry": {"tag": "people", "on": True, "pace": 1.0}}]},
    # (the quiet rule from the landing on: nobody of the stock bites, its people fire no shot)
    {"id": "quiet_now", "when": {"all": [{"fired": "part2"}, STOCK]}, "do": [
        {"carry": {"tag": "young", "on": True, "pace": 1.0}}, {"carry": {"tag": "people", "on": True, "pace": 1.0}}]},
    # Valadares on hunches: he follows the freshest prints near him
    {"id": "v_track", "when": {"all": [{"fired": "parties"}, NO_COM, {"not": {"fired": "part3"}}, LIVE]}, "delay": 20, "every": 9, "do": [
        {"order": {"tag": "valadares", "do": "track", "within": 14}}]},
    {"id": "parties_track", "when": {"all": [{"fired": "parties"}, NO_COM, {"not": {"fired": "part3"}}, LIVE]}, "delay": 90, "every": 25, "do": [
        {"order": {"tag": "party_a", "do": "track", "within": 12}}, {"order": {"tag": "party_c", "do": "track", "within": 12}}]},
    # the search tightens (something new every minute or two: NO WAITING)
    {"id": "riders_north", "when": {"all": [{"fired": "parties"}, NO_COM, {"not": {"fired": "part3"}}, LIVE]}, "delay": 140, "do": [
        {"order": {"tag": "riders", "do": "route", "route": ROUTE_RN, "loop": True, "name": "riders"}}, {"ping": {"area": "ford_w"}}]},
    {"id": "riders_north_say", "when": {"all": [{"fired": "riders_north"}, STOCK]}, "do": [{"say": ["p_riders"]}]},
    {"id": "v_hunch", "when": {"all": [{"fired": "parties"}, NO_COM, {"not": {"fired": "part3"}}, LIVE]}, "delay": 215, "do": [
        {"order": {"tag": "valadares", "do": "route", "route": ROUTE_H, "loop": True, "name": "valadares_road"}}, {"ping": {"area": "ford_m"}}]},
    {"id": "v_hunch_say", "when": {"fired": "v_hunch"}, "do": [{"say": ["v_hunch"]}]},
    {"id": "v_tracks_say", "when": {"all": [{"fired": "v_track"}, STOCK]}, "delay": 30, "do": [{"say": ["v_tracks"]}]},
    # the dinner and the decoys (the player's tools)
    {"id": "dinner_obj", "when": {"all": [{"fired": "part2"}, STOCK]}, "delay": 24, "do": [
        {"objective": {"id": "dinner", "set": "active"}}, {"say": ["l_dinner"]}, {"ping": {"area": "house_door"}}]},
    {"id": "dinner", "when": {"all": [{"fired": "dinner_obj"}, {"stay": {"tag": "lindqvist", "area": "house_door", "secs": DINNER_SECS}},
                                      {"not": {"fired": "part3"}}, LIVE]}, "do": [
        {"objective": {"id": "dinner", "set": "done"}}, {"flag": {"dinner": "given"}}, {"say": ["f_dinner", "v_dinner"]},
        {"order": {"tag": "party_b", "do": "move", "to": "house"}}, {"order": {"tag": "fonseca", "do": "move", "to": "house"}}]},
    {"id": "dinner_hold", "when": {"fired": "dinner"}, "delay": 15, "do": [{"order": {"tag": "party_b", "do": "hold"}}]},
    {"id": "dinner_end", "when": {"all": [{"fired": "dinner"}, {"not": {"fired": "part3"}}, LIVE]}, "delay": DINNER_HOLD, "do": [
        {"say": ["f_dinner_end"]}, {"order": {"tag": "party_b", "do": "route", "route": ROUTE_B, "loop": True, "name": "party_b"}},
        {"order": {"tag": "fonseca", "do": "follow", "leader": "party_b", "within": 2}}]},
    # (the commission's player: the magistrate is asked to dine all the same, and goes)
    {"id": "dinner_c", "when": {"all": [{"fired": "part2"}, COM]}, "delay": 60, "do": [{"say": ["f_c_dinner"]}, {"order": {"tag": "fonseca", "do": "move", "to": "house"}}]},
    {"id": "decoy_obj", "when": {"all": [{"fired": "part2"}, STOCK]}, "delay": 45, "do": [
        {"objective": {"id": "decoy", "set": "active"}}, {"say": ["p_decoy"]}, {"ping": {"area": "west_point"}}, {"ping": {"area": "chapel"}}]},
] + [
    t for (nm, spot, near) in [("west", "west_point", "party_a"), ("chapel", "chapel", "party_c")] for t in [
        {"id": "decoy_" + nm, "when": {"all": [{"fired": "decoy_obj"}, {"stay": {"tag": "keepers", "area": spot, "secs": DECOY_SECS}}, {"not": {"fired": "part3"}}, LIVE]}, "do": [
            {"lure_post": {"tag": "decoy_" + nm, "at": spot, "secs": 90, "pull": {"tag": "searchers", "within": 40, "then": spot, "name": "decoyed_" + nm}}},
            {"objective": {"id": "decoy", "set": "done"}}, {"say": ["n_decoy"]}, {"ping": {"area": spot}}]},
        # (the pulled party looks round the post a while, then goes back to its road)
        {"id": "decoy_%s_back" % nm, "when": {"all": [{"fired": "decoy_" + nm}, {"not": {"fired": "part3"}}, LIVE]}, "delay": 45, "do": [
            {"order": {"tag": "party_a", "do": "route", "route": ROUTE_A, "loop": True, "name": "party_a"}},
            {"order": {"tag": "party_c", "do": "route", "route": ROUTE_C, "loop": True, "name": "party_c"}},
            {"order": {"tag": "riders", "do": "route", "route": ROUTE_R, "loop": True, "name": "riders"}}]},
    ]
] + [
    # warnings: a party near a pen with the stock in it (repeating while it holds)
    {"id": "warn_" + p, "when": {"all": [{"fired": "part2"}, STOCK, {"not": {"fired": "part3"}}, {"count": {"tag": "searchers", "area": "near_" + p, "at_least": 1}},
                                       {"count": {"tag": "young", "area": p, "at_least": 1}}, LIVE]}, "every": 30, "do": [
        {"ping": {"area": p}}, {"counter": {"name": "warned", "add": 1}}] + ([{"say": ["n_party"]}] if p == "pen_6" else [])}
    for p in PENS
] + [
    {"id": "party_say", "when": {"all": [{"counter": {"name": "warned", "at_least": 1}}, STOCK]}, "do": [{"say": ["n_party"]}]},
    # found: a line, the share watched
    {"id": "found_1", "when": {"all": [{"found": {"name": "pens", "at_least": 1}}, STOCK]}, "do": [{"say": ["n_found", "v_found", "l_found"]}]},
    {"id": "found_c", "when": {"all": [{"found": {"name": "pens", "at_least": 1}}, COM]}, "do": [{"say": ["n_c_found"]}]},
    {"id": "found_tick", "when": {"all": [{"fired": "part2"}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "alive", "count": {"tag": "young"}}},
        {"counter": {"name": "destroyed", "set": 0}}, {"counter": {"name": "destroyed", "add_counter": "lost_at"}},
        {"counter": {"name": "destroyed", "sub_counter": "alive"}}]},
    {"id": "dusk_warn", "when": {"all": [{"clock_left": {"name": "dusk", "below": 40}}, STOCK, {"not": {"fired": "part3"}}]}, "do": [{"say": ["p_dusk"]}]},
]
# found too much: the half (a warning) and three quarters (the loss); the half the commission's player must destroy
TR_ += [
    {"id": "half_set", "when": {"fired": "part2"}, "delay": 0.5, "do": [
        {"counter": {"name": "half", "share_of": "young_n", "share": 0.5}}]},
]
# (the shares are worked out by the tally of found against the stock: below, "lost_check")
TR_ += [
    {"id": "lost_check", "when": {"all": [{"fired": "part2"}, LIVE]}, "every": 2, "do": [
        {"tally": {"flag": "found_share", "counter": "found", "of": "young_n", "bands": [[0, "low"], [0.5, "half"], [LOST_SHARE, "most"]]}}]},
    {"id": "half_found", "when": {"all": [{"flag": {"found_share": "half"}}, STOCK]}, "do": [{"say": ["p_half"]}]},
    {"id": "lost_found", "when": {"all": [{"flag": {"found_share": "most"}}, LIVE, NO_COM]}, "do": [{"say": ["p_lost", "n_lost"]}]},
    {"id": "lost_found2", "when": {"all": [{"fired": "lost_found"}, {"not": {"fired": "part3"}}]}, "do": [{"objective": {"id": "search", "set": "failed"}}]},
    {"id": "lost_found3", "when": {"all": [{"fired": "lost_found"}, {"fired": "part3"}]}, "do": [{"objective": {"id": "night", "set": "failed"}}]},
    # ============================================================ PART 3: THE LAST NIGHT
    {"id": "part3", "when": {"all": [{"clock_out": "dusk"}, LIVE]}, "do": [
        {"objective": {"id": "search", "set": "done"}}, {"light": {"to": "jungle_night", "secs": 20}},
        {"objective": {"id": "night", "set": "active", "if": STOCK}},
        {"clock": {"name": "dawn", "secs": DAWN_SECS, "scale": False}},
        {"say": ["n_night"]},
        {"order": {"tag": "searchers", "do": "move", "to": "camp"}}, {"order": {"tag": "valadares", "do": "move", "to": "camp"}},
        {"order": {"tag": "fonseca", "do": "move", "to": "camp"}}]},
    {"id": "part3_c", "when": {"all": [{"fired": "part3"}, COM]}, "do": [{"say": ["v_c_night"]}]},
    {"id": "camp_hold", "when": {"all": [{"fired": "part3"}, NO_COM]}, "delay": 20, "do": [{"order": {"tag": "searchers", "do": "hold"}}]},
    # the restless young one: up and away for the goats (its own short leash: only a lure right beside it holds it)
    {"id": "restless_pick", "when": {"all": [{"fired": "part3"}, LIVE]}, "delay": 11, "do": [
        {"retag": {"tag": "leashed", "as": "restless", "kind": RESTLESS_KINDS, "first": True, "far_from": "lure", "within": 4, "if": STOCK}},
        {"retag": {"tag": "wanderer", "as": "restless", "first": True, "if": NO_STOCK}}]},
    {"id": "restless", "when": {"all": [{"fired": "restless_pick"}, LIVE]}, "delay": 1, "do": [
        # (it slips away first: for a few seconds no lure holds it, then only one right beside it)
        {"leash": {"tag": "restless", "lure": "no_lure", "within": 3, "loose": "to", "to": "goats", "name": "restless"}},
        {"pace": {"tag": "restless", "pace": RESTLESS_PACE}},
        {"ping": {"tag": "restless"}}]},
    {"id": "restless_lure", "when": {"fired": "restless"}, "delay": RESTLESS_SLIP, "do": [
        {"leash": {"tag": "restless", "lure": "lure", "within": 3, "loose": "to", "to": "goats", "name": "restless"}}]},
    {"id": "restless_say", "when": {"all": [{"fired": "restless"}, STOCK]}, "do": [
        {"objective": {"id": "restless", "set": "active"}}, {"say": ["p_restless", "l_restless"]}]},
    {"id": "restless_went", "when": {"all": [{"fired": "restless"}, {"loose": {"name": "restless"}}]}, "do": []},
    {"id": "restless_held", "when": {"all": [{"fired": "restless_went"}, {"fired": "restless_lure"}, {"not": {"loose": {"name": "restless"}}}, STOCK, LIVE]}, "do": [
        {"say": ["l_held"]}, {"pace": {"tag": "restless", "pace": 1.0}}]},
    {"id": "restless_back", "when": {"all": [{"fired": "restless_held"}, {"count": {"tag": "restless", "area": "deep", "at_least": 1}},
                                             {"count": {"tag": "restless", "area": "south", "below": 1}}, LIVE]}, "do": [
        {"objective": {"id": "restless", "set": "done"}}, {"say": ["p_back"]},
        {"leash": {"tag": "restless", "lure": "lure", "within": 8, "loose": "wander", "name": "restless"}},
        # NO WAITING: the one danger of the night is over: dawn comes quickly
        {"clock": {"name": "dawn", "add": -80}}]},
    # (the restless one dead, nothing to bring back)
    {"id": "restless_gone", "when": {"all": [{"fired": "restless"}, {"dead": "restless"}, LIVE]}, "do": [
        {"objective": {"id": "restless", "set": "failed"}}, {"clock": {"name": "dawn", "add": -80}}]},
    # (none of the young left awake to go: the night passes quietly, and quickly)
    {"id": "restless_none", "when": {"all": [{"fired": "restless"}, {"count": {"tag": "restless", "below": 1}}, LIVE]}, "delay": 2, "do": [
        {"clock": {"name": "dawn", "add": -80}}]},
    # it reaches the goats: the camp is up, everything is found
    {"id": "lost_fight", "when": {"all": [{"fired": "restless"}, {"count": {"tag": "restless", "area": "goats", "at_least": 1}}, LIVE, NO_COM]}, "do": [
        {"say": ["n_fight", "v_fight"]}, {"hide": {"tag": "young", "on": False}}, {"objective": {"id": "restless", "set": "failed"}},
        {"objective": {"id": "night", "set": "failed"}}]},
    # ============================================================ DAWN
    {"id": "dawn_go", "when": {"all": [{"clock_out": "dawn"}, LIVE]}, "do": [
        {"say": ["n_dawn", "f_dawn"]}, {"order": {"tag": "com_men", "do": "move", "to": "canoes"}},
        {"order": {"tag": "fonseca", "do": "move", "to": "canoes"}}, {"light": {"to": "jungle_day", "secs": 20}}]},
    {"id": "dawn_say", "when": {"all": [{"fired": "dawn_go"}, STOCK]}, "delay": 3, "do": [{"say": ["v_dawn", "l_dawn"]}]},
    {"id": "flags", "when": {"all": [{"fired": "dawn_go"}, LIVE]}, "delay": 10, "do": [
        {"counter": {"name": "unfound", "set": 0}}, {"counter": {"name": "unfound", "add_counter": "young_n"}},
        {"counter": {"name": "unfound", "sub_counter": "found", "min": 0}},
        {"tally": {"flag": "hidden", "counter": "unfound", "of": "young_n", "bands": [[0, "few"], [0.5, "some"], [1, "all"]]}},
        {"flag": {"storm": "hatched"}}]},
    {"id": "flags_mother", "when": {"fired": "flags"}, "do": [{"flag": {"mother": "linnea", "if": SAVED}}, {"flag": {"mother": "plateau", "if": BURNED}},
                                                              {"flag": {"pieter": "alive", "if": PIETER}}, {"flag": {"pieter": "lost", "if": NO_PIETER}}]},
    {"id": "night_done", "when": {"all": [{"fired": "flags"}, STOCK]}, "do": [{"objective": {"id": "night", "set": "done"}}]},
    {"id": "the_end", "when": {"all": [{"fired": "flags"}, NO_COM]}, "delay": 6, "do": [{"win": "stock"}]},
    # the commission's player: half destroyed (the win), or dawn (the loss)
    {"id": "c_won", "when": {"all": [{"fired": "part2"}, COM, {"counter": {"name": "destroyed", "at_least": 1}}, LIVE,
                                     {"flag": {"c_half": "met"}}]}, "do": [
        {"say": ["v_c_won"]}, {"objective": {"id": "c_find", "set": "done"}},
        {"counter": {"name": "unfound", "set": 0}}, {"counter": {"name": "unfound", "add_counter": "young_n"}},
        {"counter": {"name": "unfound", "sub_counter": "found", "min": 0}},
        {"tally": {"flag": "hidden", "counter": "unfound", "of": "young_n", "bands": [[0, "few"], [0.5, "some"], [1, "all"]]}},
        {"flag": {"storm": "hatched"}}]},
    {"id": "c_half_tick", "when": {"all": [{"fired": "part2"}, COM, LIVE]}, "every": 2, "do": [
        {"tally": {"flag": "c_half", "counter": "destroyed", "of": "young_n", "bands": [[0, "no"], [0.5, "met"]]}}]},
    {"id": "c_end", "when": {"fired": "c_won"}, "delay": 4, "do": [{"win": "commission"}]},
    {"id": "c_lost", "when": {"all": [{"fired": "flags"}, COM, LIVE]}, "delay": 4, "do": [
        {"say": ["v_c_lost"]}, {"objective": {"id": "c_find", "set": "failed"}}]},
    # ============================================================ HURTS
    {"id": "l_hurt", "when": {"all": [{"hp": {"tag": "lindqvist", "below": 0.6}}, STOCK]}, "every": 60, "times": 2, "do": [{"say": ["h_hurt"]}, {"ping": {"tag": "lindqvist"}}]},
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
        fixed.append({"id": "%s__%d" % (t["id"], j), "when": {"all": [{"fired": t["id"]}, c]}, "do": [a]})
M["triggers"] = [t for t in fixed if not any("spare_kind" in a for a in t["do"])]

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the stock is bound to B4, the Storm Sire and his Hatchlings
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID)
for k in ("pterodactyl", "hatchlings"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hubs after d03 (campaign/campaign.json, campaign/hubs_grow.json), the
# war map (campaign/warmap.json)
OTHER = [
    ("The young Mother", "A jovem Mãe", "La joven Madre"),
    ("A young Brood Mother of Lindqvist's stock, not yet grown: his breeding animal.", "Uma jovem Mãe da Ninhada do plantel de Lindqvist, ainda não crescida: o seu animal de criação.",
     "Una joven Madre de la Prole de la cría de Lindqvist, aún no crecida: su animal de cría."),
    ("Keeper", "Tratador", "Cuidador"),
    ("One of Lindqvist's keepers, a musket on his back and a brass lure on a chain.", "Um dos tratadores de Lindqvist, um mosquete às costas e um engodo de latão numa corrente.",
     "Uno de los cuidadores de Lindqvist, un mosquete a la espalda y un señuelo de latón en una cadena."),
    ("Assembly guard", "Guarda da Assembleia", "Guardia de la Asamblea"),
    ("A Free Assembly man hired to guard the fazenda after Paris: he asks no questions.", "Um homem da Assembleia Livre contratado para guardar a fazenda depois de Paris: não faz perguntas.",
     "Un hombre de la Asamblea Libre contratado para guardar la fazenda después de París: no hace preguntas."),
    ("Desembargador Fonseca", "Desembargador Fonseca", "Desembargador Fonseca"),
    ("The commission's magistrate, a judge of the Relação, with Rome's order.", "O magistrado da comissão, um juiz da Relação, com a ordem de Roma.",
     "El magistrado de la comisión, un juez de la Relação, con la orden de Roma."),
    ("Lindqvist's fazenda", "A fazenda de Lindqvist", "La fazenda de Lindqvist"),
    ("The island", "A ilha", "La isla"),
    ("Dry season 2772", "Estação seca de 2772", "Estación seca de 2772"),
    ("Lindqvist breeds the specimens on an island below Óbidos, against Rome's verdict.", "Lindqvist cria os espécimes numa ilha abaixo de Óbidos, contra o veredito de Roma.",
     "Lindqvist cría los especímenes en una isla por debajo de Óbidos, contra el veredicto de Roma."),
    ("The commission searched the island and found nothing of what Lindqvist keeps.", "A comissão revistou a ilha e não encontrou nada do que Lindqvist guarda.",
     "La comisión registró la isla y no encontró nada de lo que Lindqvist guarda."),
    ("The commission found some of Lindqvist's stock and burned it; the rest was never found.", "A comissão encontrou parte do plantel de Lindqvist e queimou-a; o resto nunca foi encontrado.",
     "La comisión encontró parte de la cría de Lindqvist y la quemó; el resto nunca se encontró."),
    ("The commission found most of Lindqvist's stock and burned the pens.", "A comissão encontrou a maior parte do plantel de Lindqvist e queimou os currais.",
     "La comisión encontró la mayor parte de la cría de Lindqvist y quemó los corrales."),
    ("Young never found on the island: %s.", "Jovens nunca encontrados na ilha: %s.", "Jóvenes nunca encontrados en la isla: %s."),
    ("A Storm Sire hatched on the island: the first bred by a man.", "Um Sire da Tempestade chocou na ilha: o primeiro criado por um homem.",
     "Un Señor de la Tormenta eclosionó en la isla: el primero criado por un hombre."),
    ("Valadares' commission destroyed half of Lindqvist's stock.", "A comissão de Valadares destruiu metade do plantel de Lindqvist.",
     "La comisión de Valadares destruyó la mitad de la cría de Lindqvist."),
    ("The Fazenda's Study", "O Escritório da Fazenda", "El Estudio de la Fazenda"),
    ("Lindqvist's study in the big house on the island: jars, the stud book, a window on the forest where the pens are.",
     "O escritório de Lindqvist na casa-grande da ilha: frascos, o livro de criação, uma janela para a floresta onde estão os currais.",
     "El estudio de Lindqvist en la casa grande de la isla: frascos, el libro de cría, una ventana al bosque donde están los corrales."),
    ("The fazenda's study on the island below Óbidos: the stud book open on the desk, the forest dark in the window.",
     "O escritório da fazenda na ilha abaixo de Óbidos: o livro de criação aberto na secretária, a floresta escura na janela.",
     "El estudio de la fazenda en la isla por debajo de Óbidos: el libro de cría abierto en el escritorio, el bosque oscuro en la ventana."),
    ("The commission has gone down the river. I wrote the Storm Sire's hatching hour in the book myself.",
     "A comissão desceu o rio. Escrevi eu mesmo no livro a hora em que o Sire da Tempestade chocou.",
     "La comisión ha bajado el río. Escribí yo mismo en el libro la hora en que eclosionó el Señor de la Tormenta."),
    ("Rome calls it a monster. I call it a breed, the first of its line. Every breed needs patience and a good fence.",
     "Roma chama-lhe monstro. Eu chamo-lhe uma raça, a primeira da sua linhagem. Toda raça precisa de paciência e de uma boa cerca.",
     "Roma lo llama monstruo. Yo lo llamo una raza, la primera de su línea. Toda raza necesita paciencia y una buena cerca."),
    ("Valadares said it was made, not born. A Crown man's superstition. Everything that lives was born.",
     "Valadares disse que foi feito, não nascido. Superstição de um homem da Coroa. Tudo o que vive nasceu.",
     "Valadares dijo que fue hecho, no nacido. Superstición de un hombre de la Corona. Todo lo que vive nació."),
    ("They burned the pens they found. I count the ones that are left every morning. The stud book is thinner.",
     "Queimaram os currais que encontraram. Conto os que restam todas as manhãs. O livro de criação está mais fino.",
     "Quemaron los corrales que encontraron. Cuento los que quedan cada mañana. El libro de cría está más delgado."),
    ("Valadares found half of them and burned them. He wrote that he could smell the rest.",
     "Valadares encontrou metade e queimou-os. Escreveu que sentia o cheiro do resto.",
     "Valadares encontró la mitad y los quemó. Escribió que olía al resto."),
    ("The Storm Sire's hour is in the stud book in my hand. The Doctor checks it twice.", "A hora do Sire da Tempestade está no livro de criação, pela minha mão. O Doutor confere-a duas vezes.",
     "La hora del Señor de la Tormenta está en el libro de cría, de mi mano. El doctor la comprueba dos veces."),
    ("I paddled the commission down to Óbidos. The judge slept. Senhor Valadares did not.", "Levei a comissão até Óbidos. O juiz dormiu. O senhor Valadares não.",
     "Llevé a la comisión hasta Óbidos. El juez durmió. El señor Valadares no."),
    ("The cages stand empty in the store. The animals are on the island now, in the forest.", "As jaulas estão vazias no armazém. Os animais estão agora na ilha, na floresta.",
     "Las jaulas están vacías en el almacén. Los animales están ahora en la isla, en el bosque."),
    ("I searched his island for the Crown. I found enough to know, and not enough to end it.", "Revistei a ilha dele pela Coroa. Encontrei o bastante para saber, e não o bastante para acabar com isto.",
     "Registré su isla por la Corona. Encontré lo bastante para saber, y no lo bastante para acabar con esto."),
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
rows = ["# Act 2's mission d03_fazenda, \"The Island\" (campaign/missions/d03_fazenda.json, written with its texts by",
        "# tools/campaign/make_d03_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what was",
        "# built: docs/campaign_d03_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: lure = engodo / señuelo; stock = plantel /",
        "# cría; keeper = tratador / cuidador; the Storm Sire = o Sire da Tempestade / el Señor de la Tormenta.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
