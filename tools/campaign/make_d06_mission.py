#!/usr/bin/env python3
"""Writes campaign/missions/d06_queen.json: Act 2's "The Queen" (the Naturalist line after d03_fazenda, the island below
Óbidos, the wet season 2775; the plan: docs/campaign_act2_plan.md "d06_queen" and the OWNER box at its top; what was
built: docs/campaign_d06_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d06_queen.txt: every text here is
written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d06_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_obidos_flood_map.py (campaign:obidos_flood: d03's island in the flood). EVERY LINE IS A
PLACEHOLDER for the owner to rewrite.

THE BROOD IS NOT A PERSON (owner 2026-11-19 / 2026-11-22): no creature here has a name, a will, a plan or feelings.
Three years after the commission the island holds SEVERAL Brood Mothers: the player's (the one d03 rooted in the nest
clearing), a second one Lindqvist bred in the east pen, and a wild one the flood drives onto the island. In the wet
season they FIGHT EACH OTHER; the strongest roots in the biggest pen and GROWS into the Queen, and every bred creature on
the island turns to the strongest call: the leash breaks. Nobody "comes for her young"; nobody "wants" anything.
  THE BROOD (GREEN, p1): the player's Mother (stage 2), the Tyrant Sire and the Storm Sire rooted by her, the young of the
    stock (4 / 6 / 8 by d03 `hidden` few / some / all) standing in the two flooded low pens.
  LINDQVIST'S PEOPLE (YELLOW: scripted solo; the SOLO PICK; versus p2): Lindqvist, Pieter (by the flags), four keepers
    with the LURES (Assembly guards by a06 `varenne` executed), two swivel guns (Field Cannons), the big house in a
    palisade ring, the canoes.
  THE EAST PEN'S MOTHER (ORANGE, scripted) and THE WILD MOTHER (RED, scripted; a bigger pack with b01 `rival` standing).
  PART 1, THE FLOOD: the low pens are under water; the keepers walk up to the big pen with their lures: the young obey
    only inside a keeper's ring (THE LEASH, d03's lesson), so the player walks them up with the keepers. At 0:35 a deep
    call comes over the water (not when all are in already): a creature out of every ring walks toward it.
  PART 2, THE MOTHERS FIGHT: the wild Mother lands on the north-west shore; the keepers drop the lures and run for the
    house. Now the creatures follow only their own MOTHER'S CALL (a ring of 13 steps round her): inside it they obey; out
    of it, near another Mother, they go to that Mother (THE LEASH BREAKS: "to": "near"). The east pen's Mother breaks out;
    both packs come for the big pen and fight each other too. Kill both other Mothers; their creatures, loose, come to
    the strongest call and join.
  PART 3, THE QUEEN AND THE FALL: root the Mother in the big pen and GROW her to stage 3 (THE ROSTER LADDER's B5, was B6:
    GROW to stage 3 + the BRUTE); a mid-match show; every bred creature still loose turns to her. Lindqvist and Pieter run
    for the canoes (an exit counted for them); the keepers hold the palisade with the guns: lay BRUTES and break it, then
    the big house: WON.
  NO CHOICE. CARRIES: `brood_n` few / some / all (the bred creatures that ended on the Queen's side), `pieter` alive /
    lost, `lindqvist` fled (always), `book` left (the lure book, d08), `queen` grown.
  MIRROR (THE FAZENDA, solo pick; versus): burn three pens (the big pen, the north pen, the east pen: a man stands 4 s in
    each) and get Lindqvist to the canoes before the Queen grows (solo: a clock; versus: the Brood player's GROW). A
    mirror win is canon-compatible: `brood_n` few, `book` taken (the plan's Claude's choice 5).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d06_queen"

TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d06_queen.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
H_ALL = past("d03_fazenda.hidden", "all")                 # d03: none found: the whole stock
H_FEW = past("d03_fazenda.hidden", "few")                 # d03: most found and burned (or the commission's win)
NOT_FEW = {"not": H_FEW}
SAVED = notpast("b01_specimen.clutch", "burned")          # the player's Mother from the station's clutch (the canon)
BURNED = past("b01_specimen.clutch", "burned")
RIVAL = notpast("b01_specimen.rival", "driven")           # the rival pack of the Rio Negro still out there (the canon)
PIETER = {"all": [notpast("b01_specimen.pieter", "lost"), notpast("a05_specimens.pieter", "lost"), notpast("d03_fazenda.pieter", "lost")]}
NO_PIETER = {"not": PIETER}
EXECUTED = past("a06_barricades.varenne", "executed")     # the keepers are Assembly men
SPARED = {"not": EXECUTED}
SIRE_ALL = past("a05_specimens.cages", "all")             # the young Sire of a05 is the Tyrant Sire, grown
BROOD = {"playing": "brood"}
NO_BROOD = {"not": BROOD}                  # the Brood scripted: the fazenda is the solo pick
FAZ = {"playing": "fazenda"}
NO_FAZ = {"not": FAZ}
ENDED = [{"fired": "the_end"}, {"fired": "f_end"}, {"fired": "lost_mother"}, {"fired": "f_lost"}]
LIVE = {"not": {"any": ENDED}}

# ---------------------------------------------------------------- numbers
FLOOD_SECS = 150             # Part 1: the water reaches the paths (NORMAL; EASY x1.25, HARD x0.85)
CALL_AT = 35                 # the call over the water
CALL_R = 13                  # tiles: a Mother's call holds her creatures (her ring)
BREAK_R = 5                  # tiles: a loose creature this near another Mother goes to her
JOIN_R = 9                   # tiles: a loose creature of a fallen Mother this near the Queen joins her
LURE_R = 8                   # tiles: a keeper's lure (Part 1)
WILD_GO = 4                  # Part 2: the wild pack moves on the big pen
EAST_GO = 75                 # ... the east pen's Mother breaks out
MOTHER_PACE = 1.8            # the rival Mothers walk faster than a Mother would (NO WAITING: they come to the fight)
QUEEN_SECS = 420             # the mirror: the Queen grows when this runs out (scaled)
BURN_SECS = 4                # the mirror: a man in a pen this long burns it
BURN_DELAY = 60              # ... the big pen burned before the Queen: her clock this much longer
GROW_DENY = ["raptor", "hatchlings", "spitter", "tyrant_challenger", "venom_challenger", "storm_challenger"]
QUEEN_FOOD, QUEEN_SPOILS = 45, 6     # every 8 s after the Queen (a Brute about every 30 s)
HOUSE_HP = 3000            # the big house
BAND_SOME, BAND_ALL = 0.25, 0.55
GROW_FOOD, GROW_SPOILS = 520, 80           # given at Part 3: her growth (500 / 75) and a little over
BRUTE_FOOD, BRUTE_SPOILS = 480, 65         # given at the Queen: three Brutes (150 / 20 each) and a little over

# the stock's young: (kind, condition) in the two flooded low pens (west: even, east: odd)
YOUNG = [
    ("raptor", None), ("raptor", None), ("spitter", None), ("tyrant_challenger", None),               # few
    ("spitter", NOT_FEW), ("venom_challenger", NOT_FEW),                                               # some (canon)
    ("raptor", H_ALL), ("tyrant_challenger", H_ALL),                                                   # all
]
# the mirror: the stock asleep in the pens the fazenda must burn
MIRROR_AT = ["big_pen_w", "big_pen_e", "pen_2", "big_pen_w", "pen_2", "big_pen_e", "pen_2", "big_pen_w"]


# ================================================================== the units
units = [
    # ---- the Brood (the player): the Mother, the two Sires by her, the young in the flooded pens
    {"team": "stock", "kind": "brood_mother", "as": "grown_mother", "count": 1, "at": "mother_spot", "tag": "mother",
     "tags": ["call", "mothers", "bred_m"], "fixed": True},
    {"team": "stock", "kind": "tyrannosaur", "count": 1, "at": "sire_spot", "tag": "tyrant_sire", "tags": ["bred", "sires"], "fixed": True},
    {"team": "stock", "kind": "pterodactyl", "count": 1, "at": "storm_spot", "tag": "storm_sire", "tags": ["bred", "sires"], "fixed": True},
    # (two Mound Turtles rooted at the big pen's rim: the stock's room to grow, its supply)
    {"team": "stock", "kind": "mound_turtle", "count": 1, "at": "turtle_w", "tag": "turtles", "fixed": True},
    {"team": "stock", "kind": "mound_turtle", "count": 1, "at": "turtle_e", "tag": "turtles", "fixed": True},
] + [
    {"team": "stock", "kind": k, "count": 1, "at": "pen_5" if i % 2 == 0 else "pen_4", "tag": "young_%d" % (i + 1),
     "tags": ["young", "bred", "young_w" if i % 2 == 0 else "young_e"], "fixed": True, "if": {"all": [BROOD] + ([c] if c else [])}}
    for i, (k, c) in enumerate(YOUNG)
] + [
    {"team": "stock", "kind": k, "count": 1, "at": MIRROR_AT[i], "tag": "young_%d" % (i + 1),
     "tags": ["young", "bred", "sleep_" + MIRROR_AT[i]], "fixed": True, "if": {"all": [NO_BROOD] + ([c] if c else [])}}
    for i, (k, c) in enumerate(YOUNG)
] + [
    # ---- the east pen's Mother (ORANGE): one more of Lindqvist's breeding Mothers, fenced in the north-east pen
    {"team": "pens", "kind": "brood_mother", "as": "pen_mother", "count": 1, "at": "pen_3", "tag": "pen_mother",
     "tags": ["rival_mother", "mothers", "bred_m"], "fixed": True},
    {"team": "pens", "kind": "raptor", "count": 2, "at": "pen_3", "tag": "pen_pack", "tags": ["bred", "rivals"]},
    {"team": "pens", "kind": "spitter", "count": 1, "at": "pen_3", "tag": "pen_pack", "tags": ["bred", "rivals"]},
    {"team": "pens", "kind": "tyrant_challenger", "count": 1, "at": "pen_3", "tag": "pen_pack", "tags": ["bred", "rivals"], "if": H_ALL},
    # ---- Lindqvist's people (YELLOW): the lures in Part 1; the house, the palisade and the guns after
    {"team": "fazenda", "kind": "musketeer", "as": "lindqvist", "count": 1, "at": "house_in", "tag": "lindqvist",
     "tags": ["lure", "people", "runners", "faz_all"], "fixed": True},
    {"team": "fazenda", "kind": "labourer", "as": "pieter", "count": 1, "at": "house_in", "tag": "pieter",
     "tags": ["lure", "people", "runners", "faz_all"], "fixed": True, "if": PIETER},
    {"team": "fazenda", "kind": "musketeer", "as": "keeper", "count": 2, "at": "pen_5", "tag": "keeper_w",
     "tags": ["lure", "people", "keepers", "faz_all"], "fixed": True, "if": SPARED},
    {"team": "fazenda", "kind": "musketeer", "as": "keeper", "count": 2, "at": "pen_4", "tag": "keeper_e",
     "tags": ["lure", "people", "keepers", "faz_all"], "fixed": True, "if": SPARED},
    {"team": "fazenda", "kind": "musketeer", "as": "assembly_keeper", "count": 2, "at": "pen_5", "tag": "keeper_w",
     "tags": ["lure", "people", "keepers", "faz_all"], "fixed": True, "if": EXECUTED},
    {"team": "fazenda", "kind": "musketeer", "as": "assembly_keeper", "count": 2, "at": "pen_4", "tag": "keeper_e",
     "tags": ["lure", "people", "keepers", "faz_all"], "fixed": True, "if": EXECUTED},
    # (the mirror: more hands with muskets for the fazenda's player)
    {"team": "fazenda", "kind": "musketeer", "as": "keeper", "count": 4, "at": "house_in", "tag": "hands",
     "tags": ["people", "keepers", "faz_all"], "fixed": True, "if": FAZ},
    {"team": "fazenda", "kind": "cannon", "count": 2, "at": "guns_spot", "tag": "guns", "tags": ["faz_all"], "fixed": True},
]

# the palisade ring round the big house's rise (gates west, east and south: the fazenda's own pass)
RING = []
for x in range(50, 70):
    RING += [(x, 51), (x, 61)]
for y in range(52, 61):
    RING += [(50, y), (69, y)]
GATES = {(50, 56), (69, 56), (59, 61), (60, 61)}

buildings = [
    {"team": "fazenda", "kind": "town_hall", "at": [59, 55], "tag": "big_house", "tags": ["fazenda_b"],
     "name": T("The big house", "A casa-grande", "La casa grande")},
] + [
    {"team": "fazenda", "kind": "gate" if c in GATES else "wall", "at": list(c), "tag": "palisade", "tags": ["fazenda_b"],
     "name": T("The fazenda's palisade", "A paliçada da fazenda", "La empalizada de la fazenda")} for c in RING
]

areas = dict(
    big_pen=[58, 21, 17, 13], turtle_w=[56, 30, 2, 2], turtle_e=[74, 22, 2, 2], mother_spot=[65, 27, 2, 2], sire_spot=[61, 27, 2, 2], storm_spot=[69, 30, 2, 2],
    big_pen_s=[62, 31, 8, 3], big_pen_w=[58, 23, 5, 8], big_pen_e=[70, 23, 5, 8],
    pen_5=[30, 26, 12, 8], pen_4=[93, 22, 11, 8], pen_5_dry=[43, 28, 4, 4], pen_4_dry=[86, 26, 4, 4],
    pen_1=[17, 9, 15, 10], pen_2=[43, 6, 14, 8], pen_3=[74, 7, 14, 9],
    nw_shore=[13, 17, 12, 8], way_w=[46, 28, 6, 4], way_e=[80, 26, 6, 4], way_n=[70, 16, 6, 5],
    house=[52, 52, 16, 8], house_in=[53, 57, 14, 2], guns_spot=[55, 53, 3, 3], gate_s=[57, 61, 6, 2],
    landing=[50, 63, 20, 7], canoes=[52, 70, 16, 3],
    deep=[6, 0, 108, 38], south=[6, 46, 108, 30], ford_w=[21, 40, 7, 5], ford_m=[57, 40, 7, 5], ford_e=[91, 37, 7, 5],
    burn_big=[60, 23, 13, 9],
)

# ================================================================== the objectives
objectives = [
    # ---- the Brood
    {"id": "mother_live", "side": "brood", "primary": True, "kind": "protect", "tag": "mother",
     "text": T("Your Mother must live.", "A sua Mãe tem de viver.", "Tu Madre debe vivir.")},
    {"id": "flood", "side": "brood", "primary": False, "kind": "manual",
     "text": T("THE FLOOD: bring the young out of the two flooded pens up to the big pen: {in_pen} of {young_n} there. They obey only inside a keeper's green ring, so move them along with the keepers.",
               "A CHEIA: tire os jovens dos dois currais alagados e leve-os ao curral grande: {in_pen} de {young_n} lá. Só obedecem dentro do anel verde de um tratador, por isso leve-os junto com os tratadores.",
               "LA CRECIDA: saca a los jóvenes de los dos corrales inundados y llévalos al corral grande: {in_pen} de {young_n} allí. Solo obedecen dentro del anillo verde de un cuidador, así que llévalos junto a los cuidadores."),
     "phone": T("Young to the big pen: {in_pen} of {young_n}. Keep them in a keeper's green ring.",
                "Jovens ao curral grande: {in_pen} de {young_n}. Dentro do anel verde de um tratador.",
                "Jóvenes al corral grande: {in_pen} de {young_n}. Dentro del anillo verde de un cuidador.")},
    {"id": "flood_clock", "side": "brood", "primary": False, "kind": "countdown", "clock": "flood",
     "text": T("The water covers the paths in {clock:flood}.", "A água cobre os trilhos em {clock:flood}.", "El agua cubre las sendas en {clock:flood}.")},
    {"id": "mothers", "side": "brood", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE MOTHERS FIGHT: kill the other two Mothers ({mothers_down} of 2 down). Your creatures obey only inside your Mother's ring: out of it, near another Mother, they go over to her. Take your Mother to the fight.",
               "AS MÃES LUTAM: mate as outras duas Mães ({mothers_down} de 2 abatidas). As suas criaturas só obedecem dentro do anel da sua Mãe: fora dele, perto de outra Mãe, passam para ela. Leve a sua Mãe para a luta.",
               "LAS MADRES LUCHAN: mata a las otras dos Madres ({mothers_down} de 2 abatidas). Tus criaturas solo obedecen dentro del anillo de tu Madre: fuera de él, cerca de otra Madre, se pasan a ella. Lleva a tu Madre a la lucha."),
     "phone": T("Kill the other Mothers: {mothers_down} of 2. Fight inside your Mother's ring.",
                "Mate as outras Mães: {mothers_down} de 2. Lute dentro do anel da sua Mãe.",
                "Mata a las otras Madres: {mothers_down} de 2. Lucha dentro del anillo de tu Madre.")},
    {"id": "queen", "side": "brood", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE QUEEN: root your Mother in the big pen (ROOT on her card) and press GROW. She grows for a minute; lay eggs meanwhile.",
               "A RAINHA: enraíze a sua Mãe no curral grande (ENRAIZAR no painel dela) e aperte CRESCER. Ela cresce durante um minuto; ponha ovos entretanto.",
               "LA REINA: enraíza a tu Madre en el corral grande (ENRAIZAR en su panel) y pulsa CRECER. Crece durante un minuto; pon huevos mientras tanto.")},
    {"id": "fall", "side": "brood", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE FALL: lay BRUTES on the Queen's card (the Tyrant Sire rooted beside her) and break the palisade, then the big house.",
               "A QUEDA: ponha BRUTAMONTES no painel da Rainha (o Sire Tirano enraizado ao lado dela) e rompa a paliçada, depois a casa-grande.",
               "LA CAÍDA: pon BRUTOS en el panel de la Reina (el Señor Tirano enraizado a su lado) y rompe la empalizada, luego la casa grande.")},
    # ---- the fazenda (the solo pick, versus)
    {"id": "f_flood", "side": "fazenda", "primary": False, "kind": "manual",
     "text": T("THE FLOOD: walk your keepers up to the big pen: the animals follow only inside a lure's ring ({in_pen} of {young_n} there).",
               "A CHEIA: leve os seus tratadores ao curral grande: os animais só seguem dentro do anel de um engodo ({in_pen} de {young_n} lá).",
               "LA CRECIDA: lleva a tus cuidadores al corral grande: los animales solo siguen dentro del anillo de un señuelo ({in_pen} de {young_n} allí).")},
    {"id": "f_burn", "side": "fazenda", "primary": True, "kind": "manual", "hidden": True,
     "text": T("BURN THE PENS before the Queen grows: a keeper or Lindqvist stands 4 seconds in each of the big pen, the north pen and the east pen ({burned} of 3). Sleeping creatures wake 3 steps away: clear them with the guns first.",
               "QUEIME OS CURRAIS antes que a Rainha cresça: um tratador ou Lindqvist fica 4 segundos em cada um, o curral grande, o curral do norte e o curral do leste ({burned} de 3). As criaturas a dormir acordam a 3 passos: limpe-as primeiro com os canhões.",
               "QUEMA LOS CORRALES antes de que crezca la Reina: un cuidador o Lindqvist se queda 4 segundos en cada uno, el corral grande, el corral del norte y el corral del este ({burned} de 3). Las criaturas dormidas despiertan a 3 pasos: límpialas antes con los cañones."),
     "phone": T("Burn the pens: {burned} of 3. A man stands 4 s in each.", "Queime os currais: {burned} de 3. Um homem fica 4 s em cada.",
                "Quema los corrales: {burned} de 3. Un hombre se queda 4 s en cada uno.")},
    {"id": "f_canoes", "side": "fazenda", "primary": True, "kind": "manual", "hidden": True,
     "text": T("Then get Lindqvist to the canoes at the landing (Pieter too, with the stud book, if you can).",
               "Depois leve Lindqvist às canoas no desembarque (e Pieter, com o livro de criação, se puder).",
               "Luego lleva a Lindqvist a las canoas del embarcadero (y a Pieter, con el libro de cría, si puedes).")},
    {"id": "f_queen", "side": "fazenda", "primary": False, "kind": "countdown", "clock": "queen", "hidden": True,
     "text": T("The strongest Mother grows into a Queen in {clock:queen}. The Mothers are too big for muskets.",
               "A Mãe mais forte cresce até ser Rainha em {clock:queen}. As Mães são grandes demais para mosquetes.",
               "La Madre más fuerte se convierte en Reina en {clock:queen}. Las Madres son demasiado grandes para los mosquetes.")},
]

M = {
    "id": MID,
    "title": T("The Queen", "A Rainha", "La Reina"),
    "summary": T("The lower Amazon, the wet season 2775. The flood comes to Lindqvist's island; in the pens the Mothers fight, and the strongest grows into a Queen.",
                 "O baixo Amazonas, a estação das chuvas de 2775. A cheia chega à ilha de Lindqvist; nos currais as Mães lutam, e a mais forte cresce até ser Rainha.",
                 "El bajo Amazonas, la estación de lluvias de 2775. La crecida llega a la isla de Lindqvist; en los corrales las Madres luchan, y la más fuerte se convierte en Reina."),
    "map": "campaign:obidos_flood",
    "voice": "d06",
    "light": "jungle_dusk",
    "weather": "rain",
    "floor": [0.72, 0.74, 0.66],
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["a07_council", "d03_fazenda"],     # (Act 2: after Rome, like every mission after it; and after d03)
    "modes": ["solo", "versus"],
    "solo_sides": ["brood", "fazenda"],
    "sides": [
        {"id": "brood", "name": T("The Brood", "A Ninhada", "La Prole"),
         "about": T("The creatures on Lindqvist's island: one Mother, her Sires and the young of the stock.",
                    "As criaturas na ilha de Lindqvist: uma Mãe, os seus Sires e os jovens do plantel.",
                    "Las criaturas de la isla de Lindqvist: una Madre, sus Señores y los jóvenes de la cría.")},
        {"id": "fazenda", "name": T("The Fazenda", "A Fazenda", "La Fazenda"),
         "about": T("Lindqvist, Pieter and the keepers, with the lures, two swivel guns and the big house.",
                    "Lindqvist, Pieter e os tratadores, com os engodos, dois pedreiros e a casa-grande.",
                    "Lindqvist, Pieter y los cuidadores, con los señuelos, dos pedreros y la casa grande.")},
        {"id": "wild", "name": T("The Wild Mother", "A Mãe Selvagem", "La Madre Salvaje"),
         "about": T("A wild Brood Mother and her pack, carried onto the island by the flood.",
                    "Uma Mãe da Ninhada selvagem e a sua matilha, trazidas para a ilha pela cheia.",
                    "Una Madre de la Prole salvaje y su manada, traídas a la isla por la crecida.")},
        {"id": "pens", "name": T("The East Pen", "O Curral do Leste", "El Corral del Este"),
         "about": T("Another of Lindqvist's breeding Mothers, fenced in the north-east pen, and the young round her.",
                    "Outra das Mães de criação de Lindqvist, cercada no curral do nordeste, e os jovens à volta dela.",
                    "Otra de las Madres de cría de Lindqvist, cercada en el corral del noreste, y los jóvenes a su alrededor.")},
    ],
    "teams": [
        {"id": "stock", "side": "brood", "faction": "brood", "colour": 2, "start": "none", "camera": "big_pen", "gold": 400, "powder": 30,
         "control": {"solo": "p1", "versus": "p1", "foe": "script"}},
        {"id": "fazenda", "side": "fazenda", "faction": "crown", "colour": 3, "start": "none", "camera": "house", "gold": 0, "powder": 300,
         "control": {"solo": "script", "versus": "p2"}},
        {"id": "wild", "side": "wild", "faction": "brood", "colour": 1, "start": "none", "camera": "nw_shore",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "pens", "side": "pens", "faction": "brood", "colour": 5, "start": "none", "camera": "pen_3",
         "control": {"solo": "script", "versus": "script"}},
    ],
    "areas": areas,
    "counters": {k: {"start": 0} for k in ["young_n", "in_pen", "bred_n", "went", "lost_n", "joined", "mothers_down", "burned",
                                             "fled_l", "fled_p"]},
    "exits": [
        {"area": "canoes", "tag": "lindqvist", "counter": "fled_l", "after": "run_go"},
        {"area": "canoes", "tag": "pieter", "counter": "fled_p", "after": "run_go"},
        # (the fazenda's player: the canoes take them once the three pens burn)
        {"area": "canoes", "tag": "lindqvist", "counter": "fled_l", "after": "f_burned_all"},
        {"area": "canoes", "tag": "pieter", "counter": "fled_p", "after": "f_burned_all"},
    ],
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["lindqvist"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "brood", "portrait": "res://campaign/hub/rome_king_face.png"},
        "lindqvist": {"name": T("Dr. Lindqvist", "Dr. Lindqvist", "Dr. Lindqvist"), "side": "fazenda", "portrait": "res://campaign/hub/station_lindqvist_face.png"},
        "pieter": {"name": T("Pieter", "Pieter", "Pieter"), "side": "fazenda"},
        "narrator": {"name": T("The Island", "A Ilha", "La Isla"), "side": "brood"},
    },
    "lines": {},
    "stills": {},
    "next": {"brood": "", "fazenda": ""},
}

L = M["lines"]


def line(lid, who, en, pt, es, to=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    return lid


BR, FZ = "brood", "fazenda"
# ---- the opening (the King frames; Lindqvist tells it, and is wrong about what he kept)
line("k_open1", "king", "Three years after the commission the river rose higher than anyone on it could remember.",
     "Três anos depois da comissão o rio subiu mais alto do que alguém ali se lembrava.",
     "Tres años después de la comisión el río subió más alto de lo que nadie allí recordaba.")
line("k_open2", "king", "Lindqvist still tells that night as a breeding season that went wrong.",
     "Lindqvist ainda conta aquela noite como uma época de criação que correu mal.",
     "Lindqvist todavía cuenta aquella noche como una temporada de cría que salió mal.")
line("l_open1", "lindqvist", "The wet season of 2775. The water came up into the cane, then into the low pens.",
     "A estação das chuvas de 2775. A água subiu para o canavial, depois para os currais baixos.",
     "La estación de lluvias de 2775. El agua subió al cañaveral, luego a los corrales bajos.")
line("l_open2", "lindqvist", "I had two breeding Mothers on the island by then. I thought I was a rich man.",
     "Por essa altura eu tinha duas Mães de criação na ilha. Julguei que era um homem rico.",
     "Para entonces tenía dos Madres de cría en la isla. Creí que era un hombre rico.")
line("l_open_saved", "lindqvist", "The first from the clutch we carried out of the station. The second bred from her.",
     "A primeira da ninhada que trouxemos da estação. A segunda criada a partir dela.",
     "La primera de la nidada que sacamos de la estación. La segunda criada a partir de ella.")
line("l_open_burned", "lindqvist", "The first netted on the mountain. The second bred from her.",
     "A primeira apanhada na montanha. A segunda criada a partir dela.", "La primera atrapada en la montaña. La segunda criada a partir de ella.")
line("k_open_f", "king", "Lindqvist says he burned the pens that night. Listen to how much he burned.",
     "Lindqvist diz que queimou os currais naquela noite. Ouve quanto queimou.", "Lindqvist dice que quemó los corrales aquella noche. Escucha cuánto quemó.")
line("l_open_f", "lindqvist", "The water was in the cane. Something was calling from the north shore. I sent for the torches.",
     "A água estava no canavial. Algo chamava da margem norte. Mandei buscar as tochas.",
     "El agua estaba en el cañaveral. Algo llamaba desde la orilla norte. Mandé traer las antorchas.")
# ---- part 1: the flood
line("l_1", "lindqvist", "The low pens are under water. Pieter, the keepers. Bring the stock up to the big pen. All of it.",
     "Os currais baixos estão debaixo de água. Pieter, os tratadores. Tragam o plantel para o curral grande. Todo.",
     "Los corrales bajos están bajo el agua. Pieter, los cuidadores. Subid la cría al corral grande. Toda.", BR)
line("n_lesson", "narrator", "Your creatures obey only inside a keeper's green ring. Select them and move them with the keepers, a little at a time.",
     "As suas criaturas só obedecem dentro do anel verde de um tratador. Selecione-as e leve-as com os tratadores, aos poucos.",
     "Tus criaturas solo obedecen dentro del anillo verde de un cuidador. Selecciónalas y llévalas con los cuidadores, poco a poco.", BR)
line("n_call", "narrator", "A deep sound comes over the water from the north-west shore. Every head in the pens turns toward it.",
     "Um som fundo chega pela água da margem noroeste. Todas as cabeças nos currais se viram para ele.",
     "Un sonido hondo llega por el agua desde la orilla noroeste. Todas las cabezas de los corrales se vuelven hacia él.")
line("p_call", "pieter", "Doctor, the ones outside the rings are walking toward it.", "Doutor, os que estão fora dos anéis vão na direção dele.",
     "Doctor, los que están fuera de los anillos caminan hacia él.", BR)
line("n_loose", "narrator", "A creature out of every ring walks toward the sound. Bring a keeper's ring back over it.",
     "Uma criatura fora de todos os anéis caminha para o som. Volte a pôr-lhe por cima o anel de um tratador.",
     "Una criatura fuera de todos los anillos camina hacia el sonido. Vuelve a ponerle encima el anillo de un cuidador.", BR)
line("p_in", "pieter", "They are all up in the big pen, Doctor. Wet, but all there.", "Estão todos no curral grande, Doutor. Molhados, mas todos.",
     "Están todos en el corral grande, doctor. Mojados, pero todos.", BR)
line("p_late", "pieter", "The water is on the paths, Doctor. We cannot wait for the rest.", "A água está nos trilhos, Doutor. Não podemos esperar pelos outros.",
     "El agua está en las sendas, doctor. No podemos esperar a los demás.", BR)
# ---- part 2: the Mothers fight
line("n_wild", "narrator", "The flood has carried a wild Mother onto the north-west shore, and a pack with her.",
     "A cheia trouxe uma Mãe selvagem para a margem noroeste, e uma matilha com ela.",
     "La crecida ha traído a una Madre salvaje a la orilla noroeste, y una manada con ella.")
line("n_wild_rival", "narrator", "A big pack for a wild Mother. A pack off the Rio Negro, perhaps.",
     "Uma matilha grande para uma Mãe selvagem. Uma matilha do Rio Negro, talvez.",
     "Una manada grande para una Madre salvaje. Una manada del Río Negro, quizá.")
line("l_drop", "lindqvist", "Leave the lures. Everyone to the house. Shut the gate.", "Larguem os engodos. Todos para a casa. Fechem o portão.",
     "Dejad los señuelos. Todos a la casa. Cerrad el portón.")
line("n_mring", "narrator", "The keepers are gone. Now your creatures follow only their own Mother: they obey inside her ring. Out of it, near another Mother, they go over to her.",
     "Os tratadores foram-se. Agora as suas criaturas só seguem a sua própria Mãe: obedecem dentro do anel dela. Fora dele, perto de outra Mãe, passam para ela.",
     "Los cuidadores se han ido. Ahora tus criaturas solo siguen a su propia Madre: obedecen dentro de su anillo. Fuera de él, cerca de otra Madre, se pasan a ella.", BR)
line("n_uproot", "narrator", "Your Mother can fight. UPROOT her on her card and walk her to the fight; rooted, she only waits.",
     "A sua Mãe pode lutar. DESENRAÍZE-A no painel dela e leve-a para a luta; enraizada, só espera.",
     "Tu Madre puede luchar. DESENRAÍZALA en su panel y llévala a la lucha; enraizada, solo espera.", BR)
line("n_east", "narrator", "In the north-east pen the other bred Mother breaks her fence. The young round her go with her.",
     "No curral do nordeste a outra Mãe de criação rompe a cerca. Os jovens à volta dela vão com ela.",
     "En el corral del noreste la otra Madre de cría rompe su cerca. Los jóvenes de su alrededor van con ella.")
line("p_fight", "pieter", "They are fighting each other, Doctor. Mother against Mother.", "Estão a lutar umas contra as outras, Doutor. Mãe contra Mãe.",
     "Están luchando entre ellas, doctor. Madre contra Madre.")
line("l_fight", "lindqvist", "Write it down, Pieter. Every hour of it. Nobody has ever seen this.", "Escreve, Pieter. Cada hora. Ninguém nunca viu isto.",
     "Escríbelo, Pieter. Cada hora. Nadie ha visto nunca esto.")
line("n_lost", "narrator", "One of yours strayed out of your Mother's ring and has gone over to another Mother.",
     "Um dos seus saiu do anel da sua Mãe e passou para outra Mãe.", "Uno de los tuyos salió del anillo de tu Madre y se ha pasado a otra Madre.", BR)
line("n_wild_down", "narrator", "The wild Mother is down. Her pack wanders, and turns toward the strongest call left.",
     "A Mãe selvagem caiu. A matilha dela vagueia, e vira-se para o chamado mais forte que resta.",
     "La Madre salvaje ha caído. Su manada vaga, y se vuelve hacia la llamada más fuerte que queda.")
line("n_east_down", "narrator", "The east pen's Mother is down. Her young wander, and turn toward the strongest call left.",
     "A Mãe do curral do leste caiu. Os jovens dela vagueiam, e viram-se para o chamado mais forte que resta.",
     "La Madre del corral del este ha caído. Sus jóvenes vagan, y se vuelven hacia la llamada más fuerte que queda.")
line("n_joined", "narrator", "Loose creatures of the fallen Mothers come into your Mother's ring and stay.",
     "Criaturas soltas das Mães caídas entram no anel da sua Mãe e ficam.", "Criaturas sueltas de las Madres caídas entran en el anillo de tu Madre y se quedan.", BR)
# ---- part 3: the Queen, the fall
line("n_part3", "narrator", "One Mother is left on the island. Root her in the big pen and press GROW on her card.",
     "Resta uma Mãe na ilha. Enraíze-a no curral grande e aperte CRESCER no painel dela.",
     "Queda una Madre en la isla. Enraízala en el corral grande y pulsa CRECER en su panel.", BR)
line("l_house", "lindqvist", "Close the shutters. Load the swivel guns. Pieter, bring the stud book down.",
     "Fechem as portadas. Carreguem os pedreiros. Pieter, traz o livro de criação cá para baixo.",
     "Cerrad los postigos. Cargad los pedreros. Pieter, baja el libro de cría.")
line("p_changing", "pieter", "Doctor, the big one in the middle is changing. She is getting bigger.",
     "Doutor, a grande do meio está a mudar. Está a ficar maior.", "Doctor, la grande del medio está cambiando. Se está haciendo más grande.")
line("l_shoot", "lindqvist", "Keepers! To the big pen. Shoot her. Shoot her now, before it is done.",
     "Tratadores! Ao curral grande. Disparem sobre ela. Disparem já, antes que acabe.",
     "¡Cuidadores! Al corral grande. Disparadle. Disparadle ya, antes de que termine.")
line("n_growing", "narrator", "She is growing. Lay eggs meanwhile, with the Sires rooted beside her.",
     "Ela está a crescer. Ponha ovos entretanto, com os Sires enraizados ao lado dela.",
     "Está creciendo. Pon huevos mientras tanto, con los Señores enraizados a su lado.", BR)
line("s_1", "narrator", "The flood.", "A cheia.", "La crecida.")
line("s_2", "narrator", "The pens.", "Os currais.", "Los corrales.")
line("s_3", "narrator", "The Queen.", "A Rainha.", "La Reina.")
line("l_show", "lindqvist", "Every animal on the island turned toward the big pen. I had no lure for that.",
     "Todos os animais da ilha se viraram para o curral grande. Eu não tinha engodo para aquilo.",
     "Todos los animales de la isla se volvieron hacia el corral grande. Yo no tenía señuelo para aquello.")
line("n_fall", "narrator", "Every bred creature on the island turns to the Queen. Lay BRUTES on her card and break the palisade, then the big house.",
     "Todas as criaturas criadas na ilha se viram para a Rainha. Ponha BRUTAMONTES no painel dela e rompa a paliçada, depois a casa-grande.",
     "Todas las criaturas criadas en la isla se vuelven hacia la Reina. Pon BRUTOS en su panel y rompe la empalizada, luego la casa grande.", BR)
line("l_run", "lindqvist", "Pieter! The canoes. Leave everything.", "Pieter! As canoas. Deixa tudo.", "¡Pieter! Las canoas. Déjalo todo.")
line("p_book", "pieter", "The book, Doctor! The lure book is upstairs!", "O livro, Doutor! O livro dos engodos está lá em cima!", "¡El libro, doctor! ¡El libro de los señuelos está arriba!")
line("l_book", "lindqvist", "Leave it!", "Deixa-o!", "¡Déjalo!")
line("n_breach", "narrator", "The palisade is open.", "A paliçada está aberta.", "La empalizada está abierta.", BR)
line("n_canoe", "narrator", "A canoe goes down the river in the dark with two men in it.", "Uma canoa desce o rio no escuro com dois homens.",
     "Una canoa baja por el río en la oscuridad con dos hombres.")
line("n_canoe1", "narrator", "A canoe goes down the river in the dark with one man in it.", "Uma canoa desce o rio no escuro com um homem.",
     "Una canoa baja por el río en la oscuridad con un hombre.")
line("n_pieter_lost", "narrator", "Pieter did not reach the canoes.", "Pieter não chegou às canoas.", "Pieter no llegó a las canoas.")
line("n_house", "narrator", "The big house falls. The island belongs to the Queen.", "A casa-grande cai. A ilha é da Rainha.",
     "La casa grande cae. La isla es de la Reina.")
line("n_mother_dead", "narrator", "Your Mother is dead. Another will root in the big pen.", "A sua Mãe morreu. Outra vai enraizar no curral grande.",
     "Tu Madre ha muerto. Otra enraizará en el corral grande.", BR)
# ---- the fazenda's (the solo pick) lines
line("l_f1", "lindqvist", "Torches. We burn the pens before they settle it among themselves. Then the canoes.",
     "Tochas. Queimamos os currais antes que elas o resolvam entre si. Depois as canoas.",
     "Antorchas. Quemamos los corrales antes de que lo resuelvan entre ellas. Luego las canoas.", FZ)
line("p_f1", "pieter", "The guns first, Doctor. They are asleep in the straw, and they wake when you walk up to them.",
     "Os canhões primeiro, Doutor. Estão a dormir na palha, e acordam quando se chega perto.",
     "Los cañones primero, doctor. Están dormidos en la paja, y despiertan cuando uno se acerca.", FZ)
line("n_f_burn", "narrator", "A pen burns: straw, fences, the troughs.", "Um curral arde: palha, cercas, os cochos.", "Un corral arde: paja, cercas, los comederos.", FZ)
line("l_f_big", "lindqvist", "The big pen is burning. They will have to settle it somewhere else, and that takes time.",
     "O curral grande está a arder. Vão ter de o resolver noutro lado, e isso leva tempo.",
     "El corral grande arde. Tendrán que resolverlo en otro sitio, y eso lleva tiempo.", FZ)
line("l_f_go", "lindqvist", "Enough. To the canoes, all of you.", "Basta. Para as canoas, todos.", "Basta. A las canoas, todos.", FZ)
line("p_f_warn", "pieter", "Doctor, the big one in the middle is changing. It is getting bigger.", "Doutor, a grande do meio está a mudar. Está a ficar maior.",
     "Doctor, la grande del medio está cambiando. Se está haciendo más grande.", FZ)
line("l_f_won", "lindqvist", "Push off, Pieter. Do not look back.", "Empurra, Pieter. Não olhes para trás.", "Empuja, Pieter. No mires atrás.", FZ)
line("l_f_lost", "lindqvist", "Too late. It is growing. Everything on the island is turning to it.", "Tarde demais. Está a crescer. Tudo na ilha se vira para ela.",
     "Demasiado tarde. Está creciendo. Todo en la isla se vuelve hacia ella.")
# ---- the endings
line("l_end1", "lindqvist", "I stood up in the canoe and looked back. The whole island was moving.", "Pus-me de pé na canoa e olhei para trás. A ilha inteira mexia-se.",
     "Me puse de pie en la canoa y miré atrás. La isla entera se movía.")
line("l_end_all", "lindqvist", "Every animal I had bred was on that bank. Not one came to the lure.", "Todos os animais que eu criara estavam naquela margem. Nem um veio ao engodo.",
     "Todos los animales que había criado estaban en aquella orilla. Ni uno vino al señuelo.")
line("l_end_some", "lindqvist", "Half my stock was on that bank. The rest lay dead in the pens.", "Metade do meu plantel estava naquela margem. O resto jazia morto nos currais.",
     "La mitad de mi cría estaba en aquella orilla. El resto yacía muerto en los corrales.")
line("l_end_few", "lindqvist", "Few of mine were on that bank. The pens had killed most of them.", "Poucos dos meus estavam naquela margem. Os currais tinham matado a maioria.",
     "Pocos de los míos estaban en aquella orilla. Los corrales habían matado a la mayoría.")
line("k_end1", "king", "He says the flood did it. He bred nothing. He kept animals that were made long ago to become exactly that.",
     "Ele diz que foi a cheia. Ele não criou nada. Guardou animais que foram feitos há muito tempo para se tornarem exatamente aquilo.",
     "Él dice que fue la crecida. No crió nada. Guardó animales que fueron hechos hace mucho para convertirse exactamente en eso.")
line("k_end2", "king", "The Church told him what they were. He still says they evolved.", "A Igreja disse-lhe o que eram. Ele ainda diz que evoluíram.",
     "La Iglesia le dijo lo que eran. Él todavía dice que evolucionaron.")
line("l_end_f", "lindqvist", "We burned three pens and went down the river at first light. I have the stud book. I burned the rest.",
     "Queimámos três currais e descemos o rio ao primeiro clarão. Tenho o livro de criação. Queimei o resto.",
     "Quemamos tres corrales y bajamos el río con la primera luz. Tengo el libro de cría. Quemé el resto.")
line("k_end_f", "king", "He told me he burned them. He did not burn enough.", "Ele disse-me que os queimou. Não queimou o bastante.",
     "Él me dijo que los quemó. No quemó lo bastante.")
line("h_hurt", "lindqvist", "My arm. Pieter, the torch.", "O meu braço. Pieter, a tocha.", "Mi brazo. Pieter, la antorcha.", FZ)
line("n_guards", "narrator", "The keepers are Assembly men now, paid in sugar and silence.", "Os tratadores são agora homens da Assembleia, pagos em açúcar e silêncio.",
     "Los cuidadores son ahora hombres de la Asamblea, pagados en azúcar y silencio.")
line("n_no_pieter", "narrator", "Pieter is not on the island any more. Two keepers carry the lures on each side.",
     "Pieter já não está na ilha. Dois tratadores levam os engodos de cada lado.", "Pieter ya no está en la isla. Dos cuidadores llevan los señuelos a cada lado.")
line("n_sire_all", "narrator", "The Tyrant Sire beside her is the young Sire of the plateau's cages, grown.",
     "O Sire Tirano ao lado dela é o jovem Sire das jaulas do planalto, crescido.", "El Señor Tirano a su lado es el joven Señor de las jaulas de la meseta, crecido.", BR)

# ---- stills
M["stills"] = {
    "flood": {"image": STILL % "d06_01", "caption": T("The island below Óbidos, the wet season 2775: the flood.", "A ilha abaixo de Óbidos, a estação das chuvas de 2775: a cheia.",
                                                    "La isla por debajo de Óbidos, la estación de lluvias de 2775: la crecida.")},
    "fight": {"image": STILL % "d06_02", "caption": T("The Mothers in the pens.", "As Mães nos currais.", "Las Madres en los corrales.")},
    "queen": {"image": STILL % "d06_03", "caption": T("The Queen in the big pen.", "A Rainha no curral grande.", "La Reina en el corral grande.")},
    "canoes": {"image": STILL % "d06_04", "caption": T("The canoes from the burning house.", "As canoas da casa a arder.", "Las canoas desde la casa en llamas.")},
    "rome": {"image": STILL % "b01_08", "caption": T("Rome, the present. The King and his prisoner, the doctor.", "Roma, o presente. O Rei e o seu prisioneiro, o doutor.",
                                                    "Roma, el presente. El Rey y su prisionero, el doctor.")},
}
M["opening"] = {
    "brood": [{"still": "rome", "lines": ["k_open1", "k_open2"]},
              {"still": "flood", "lines": ["l_open1", "l_open2", {"id": "l_open_saved", "if": SAVED}, {"id": "l_open_burned", "if": BURNED}]}],
    "fazenda": [{"still": "rome", "lines": ["k_open_f"]}, {"still": "flood", "lines": ["l_open1", "l_open_f"]}],
}
M["ending"] = {
    "brood": [
        {"still": "canoes", "lines": ["l_end1", {"id": "l_end_all", "if": {"flag": {"brood_n": "all"}}}, {"id": "l_end_some", "if": {"flag": {"brood_n": "some"}}},
                                      {"id": "l_end_few", "if": {"flag": {"brood_n": "few"}}}]},
        {"still": "rome", "lines": ["k_end1", "k_end2"]},
    ],
    "fazenda": [{"still": "canoes", "lines": ["l_end_f"]}, {"still": "rome", "lines": ["k_end_f"]}],
}
M["briefing"] = {
    "brood": {"still": "fight", "text": [
        T("The lower Amazon, the wet season 2775. You are the creatures on Lindqvist's island: one Brood Mother, her two Sires and the young of the stock.",
          "O baixo Amazonas, a estação das chuvas de 2775. Você é as criaturas na ilha de Lindqvist: uma Mãe da Ninhada, os seus dois Sires e os jovens do plantel.",
          "El bajo Amazonas, la estación de lluvias de 2775. Eres las criaturas de la isla de Lindqvist: una Madre de la Prole, sus dos Señores y los jóvenes de la cría."),
        T("First the flood: walk the young up to the big pen inside the keepers' rings. Then the other Mothers come: kill them, keeping your creatures inside your own Mother's ring.",
          "Primeiro a cheia: leve os jovens ao curral grande dentro dos anéis dos tratadores. Depois vêm as outras Mães: mate-as, com as suas criaturas dentro do anel da sua Mãe.",
          "Primero la crecida: lleva a los jóvenes al corral grande dentro de los anillos de los cuidadores. Luego vienen las otras Madres: mátalas, con tus criaturas dentro del anillo de tu Madre."),
        T("Then root her in the big pen and GROW her into the Queen, and break the fazenda.",
          "Depois enraíze-a no curral grande, faça-a CRESCER até Rainha, e rompa a fazenda.",
          "Luego enraízala en el corral grande, hazla CRECER hasta Reina, y rompe la fazenda.")]},
    "fazenda": {"still": "flood", "text": [
        T("The lower Amazon, the wet season 2775. You are Lindqvist's people on the island: Lindqvist, Pieter, the keepers and two swivel guns.",
          "O baixo Amazonas, a estação das chuvas de 2775. Você é a gente de Lindqvist na ilha: Lindqvist, Pieter, os tratadores e dois pedreiros.",
          "El bajo Amazonas, la estación de lluvias de 2775. Eres la gente de Lindqvist en la isla: Lindqvist, Pieter, los cuidadores y dos pedreros."),
        T("The Mothers in the pens are fighting. Burn three pens before the strongest grows into a Queen, then get Lindqvist to the canoes.",
          "As Mães nos currais estão a lutar. Queime três currais antes que a mais forte cresça até ser Rainha, depois leve Lindqvist às canoas.",
          "Las Madres de los corrales están luchando. Quema tres corrales antes de que la más fuerte se convierta en Reina, luego lleva a Lindqvist a las canoas.")]},
}
M["debrief"] = {
    "brood": {"still": "queen", "title": T("The Queen", "A Rainha", "La Reina"),
              "text": T("The fazenda fell in a night. Of the {bred_n} bred creatures on the island, {went} ended with the Queen.",
                        "A fazenda caiu numa noite. Das {bred_n} criaturas criadas na ilha, {went} acabaram com a Rainha.",
                        "La fazenda cayó en una noche. De las {bred_n} criaturas criadas en la isla, {went} acabaron con la Reina."),
              "text_if": [
                  {"if": {"flag": {"pieter": "lost"}}, "text": T("Pieter did not reach the canoes.", "Pieter não chegou às canoas.", "Pieter no llegó a las canoas.")},
                  {"if": {"flag": {"book": "left"}}, "text": T("The lure book was left in the house.", "O livro dos engodos ficou na casa.", "El libro de los señuelos se quedó en la casa.")}]},
    "fazenda": {"still": "canoes", "title": T("The Canoes", "As Canoas", "Las Canoas"),
                "text": T("Lindqvist burned {burned} pens and went down the river.", "Lindqvist queimou {burned} currais e desceu o rio.",
                          "Lindqvist quemó {burned} corrales y bajó el río.")},
}


# ================================================================== the triggers
TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"counter": {"name": "young_n", "count": {"tag": "young"}}},
        {"brood_stage": {"tag": "mothers", "stage": 2}},
        {"nest_free": {"tag": "sires", "on": True}},
        # (the scene as it stands: she and the two Sires rooted in the big pen, the player's from the start)
        {"root_now": {"tag": "mother"}}, {"root_now": {"tag": "sires"}}, {"root_now": {"tag": "turtles"}},
        # (the night's truce: until the Mothers' fight is settled nobody of the fazenda is a target, and they fire at nothing)
        {"spare": {"tag": "faz_all", "on": True}}, {"spare": {"tag": "fazenda_b", "on": True}},
        {"carry": {"tag": "faz_all", "on": True, "pace": 1.0}},
        # (the big house is stone below and timber above: harder to break than a town hall)
        {"max_hp": {"tag": "big_house", "hp": HOUSE_HP}},
        # (the east pen's Mother and her young are fenced in: kept in place until Part 2)
        {"cage": {"tag": "pen_mother", "on": True}}, {"sleep": {"team": "pens", "name": "east_pen", "within": 0}},
        {"spare": {"tag": "pen_mother", "on": True}}, {"spare": {"tag": "pen_pack", "on": True}},
        {"deny": {"team": "stock", "kind": ["grub", "rootmaw", "mound_turtle", "dilophosaurus"],
                  "why": T("Not on the island: the flood has drowned the ground.", "Não na ilha: a cheia afogou o chão.",
                           "No en la isla: la crecida ha ahogado el suelo.")}}]},
    # the Brood played: the keepers' leash; THE FLOOD
    {"id": "setup_brood", "when": {"all": [{"time": 0.6}, BROOD]}, "do": [
        {"leash": {"tag": "young", "lure": "lure", "within": LURE_R, "loose": "wander", "name": "stock"}},
        {"clock": {"name": "flood", "secs": FLOOD_SECS}}]},
    # the Brood scripted (the fazenda is the solo pick): asleep in the pens to be burned; no flood to walk
    {"id": "setup_mirror", "when": {"all": [{"time": 0.6}, NO_BROOD]}, "do":
        [{"sleep": {"tag": "sleep_" + a, "name": a, "within": 3, "by": "fazenda", "hurt": True,
                    "then": {"do": "hunt", "prey": "people", "within": 12}}} for a in ["big_pen_w", "big_pen_e", "pen_2"]]
        + [{"floor": {"tag": "mothers", "share": 0.35}},
           {"objective": {"id": "flood", "set": "hidden"}}, {"objective": {"id": "flood_clock", "set": "hidden"}},
           {"objective": {"id": "f_flood", "set": "hidden"}},
           # (SAY IT PLAINLY: the fazenda's player sees the job from the first second, not after the flood's 15 s)
           {"objective": {"id": "f_burn", "set": "active"}}, {"objective": {"id": "f_canoes", "set": "active"}},
           {"order": {"tag": "keeper_w", "do": "move", "to": "house_in"}}, {"order": {"tag": "keeper_e", "do": "move", "to": "house_in"}},
           {"clock": {"name": "flood", "secs": 15, "scale": False}}]},
    {"id": "no_pieter", "when": {"all": [{"time": 20}, NO_PIETER]}, "do": [{"say": ["n_no_pieter"]}]},
    {"id": "guards", "when": {"all": [{"time": 26}, EXECUTED]}, "do": [{"say": ["n_guards"]}]},
    {"id": "intro", "when": {"all": [{"time": 1.5}, BROOD]}, "do": [{"say": ["l_1", "n_lesson"]}, {"ping": {"area": "pen_5"}},
                                                                    {"ping": {"area": "pen_4"}}, {"ping": {"area": "big_pen"}}]},
    {"id": "intro_sire", "when": {"all": [{"time": 30}, BROOD, SIRE_ALL]}, "do": [{"say": ["n_sire_all"]}]},
    {"id": "intro_f", "when": {"all": [{"time": 1.5}, FAZ]}, "do": [{"say": ["l_f1", "p_f1"]}]},
    # ============================================================ PART 1: THE FLOOD (the keepers walk up; the young with them)
    {"id": "keepers_go", "when": {"all": [{"time": 9}, NO_FAZ, BROOD]}, "do": [
        {"order": {"tag": "keeper_w", "do": "route", "route": ["pen_5", "way_w", "big_pen_w"], "name": "keeper_w"}},
        {"order": {"tag": "keeper_e", "do": "route", "route": ["pen_4", "way_e", "big_pen_e"], "name": "keeper_e"}},
        {"pace": {"tag": "keepers", "pace": 0.65}}]},
    {"id": "in_count", "when": {"all": [{"time": 2}, {"not": {"fired": "part2"}}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "in_pen", "count": {"tag": "young", "area": "big_pen"}}}]},
    {"id": "call", "when": {"all": [{"time": CALL_AT}, {"not": {"fired": "part2"}}, {"not": {"fired": "all_in"}}, BROOD]}, "do": [
        {"sound": {"name": "campaign/linnea_call", "area": "nw_shore", "vol": -4}}, {"ping": {"area": "nw_shore"}},
        {"say": ["n_call", "p_call"]},
        {"leash": {"tag": "young", "lure": "lure", "within": LURE_R, "loose": "to", "to": "nw_shore", "name": "stock"}}]},
    {"id": "loose_say", "when": {"all": [{"fired": "call"}, {"loose": {"name": "stock"}}, BROOD, {"not": {"fired": "part2"}}]}, "do": [{"say": ["n_loose"]}]},
    {"id": "all_in", "when": {"all": [{"time": 12}, BROOD, {"not": {"fired": "part2"}}, {"counter": {"name": "in_pen", "at_least": 1}},
                                      {"count": {"tag": "young", "area": "big_pen", "at_least": 1}},
                                      {"count": {"tag": "young", "not_area": "big_pen", "below": 1}}, LIVE]}, "do": [
        {"objective": {"id": "flood", "set": "done"}}, {"objective": {"id": "f_flood", "set": "done"}}, {"say": ["p_in"]},
        {"clock": {"name": "flood", "add": -900}}]},
    {"id": "flood_late", "when": {"all": [{"clock_out": "flood"}, BROOD, {"not": {"fired": "all_in"}}, LIVE]}, "do": [
        {"say": ["p_late"]}, {"objective": {"id": "flood", "set": "failed"}}]},
    # ============================================================ PART 2: THE MOTHERS FIGHT
    {"id": "part2", "when": {"all": [{"clock_out": "flood"}, LIVE]}, "do": [
        {"clock": {"name": "flood", "stop": True}}, {"objective": {"id": "flood_clock", "set": "hidden"}},
        {"objective": {"id": "flood", "set": "hidden"}}, {"objective": {"id": "f_flood", "set": "hidden"}},
        # the wild Mother lands on the north-west shore with her pack
        {"spawn": {"team": "wild", "kind": "brood_mother", "as": "wild_mother", "count": 1, "at": "nw_shore", "tag": "wild_mother",
                   "tags": ["rival_mother", "mothers", "bred_m"], "fixed": True}},
        {"spawn": {"team": "wild", "kind": "raptor", "count": 2, "at": "nw_shore", "tag": "wild_pack", "tags": ["bred", "rivals"]}},
        {"spawn": {"team": "wild", "kind": "tyrant_challenger", "count": 1, "at": "nw_shore", "tag": "wild_pack", "tags": ["bred", "rivals"], "fixed": True}},
        {"spawn": {"team": "wild", "kind": "raptor", "count": 1, "at": "nw_shore", "tag": "wild_pack", "tags": ["bred", "rivals"], "if": RIVAL}},
        {"ping": {"area": "nw_shore"}}, {"sound": {"name": "campaign/sire_roar", "area": "nw_shore", "vol": -6}},
        {"sound": {"name": "campaign/linnea_call", "area": "nw_shore", "vol": -4}},
        # the keepers drop the lures and run for the house; the creatures follow only their Mothers now
        {"order": {"tag": "people", "do": "move", "to": "house_in"}},
        {"leash": {"team": "stock", "lure": "call", "within": CALL_R, "loose": "wander", "name": "stock",
                   "breaks": {"near": "rival_mother", "within": BREAK_R, "to": "near", "loose_only": True, "counter": "lost_n", "warn": 2, "as": "rivals"},
                   "if": BROOD}},
        {"leash": {"team": "wild", "lure": "wild_mother", "within": 90, "loose": "to", "to": "big_pen", "name": "wild"}},
        {"leash": {"team": "pens", "lure": "pen_mother", "within": 90, "loose": "to", "to": "big_pen", "name": "pens"}},
        {"objective": {"id": "mothers", "set": "active"}}]},
    {"id": "bred_count", "when": {"fired": "part2"}, "delay": 0.5, "do": [{"counter": {"name": "bred_n", "count": {"tag": "bred"}}}]},
    {"id": "p2_say", "when": {"fired": "part2"}, "delay": 1, "do": [{"say": ["n_wild", "l_drop"]}]},
    {"id": "p2_rival", "when": {"all": [{"fired": "part2"}, RIVAL]}, "delay": 6, "do": [{"say": ["n_wild_rival"]}]},
    {"id": "p2_ring", "when": {"all": [{"fired": "part2"}, BROOD]}, "delay": 3, "do": [{"say": ["n_mring", "n_uproot"]}, {"ping": {"tag": "mother"}}]},
    {"id": "p2_f", "when": {"all": [{"fired": "part2"}, FAZ]}, "delay": 1, "do": [
        {"spare": {"tag": "faz_all", "on": False}}, {"spare": {"tag": "fazenda_b", "on": False}}, {"carry": {"tag": "faz_all", "on": False}},
        {"objective": {"id": "f_burn", "set": "active"}}, {"objective": {"id": "f_canoes", "set": "active"}}]},
    {"id": "p2_fq", "when": {"all": [{"fired": "part2"}, FAZ, NO_BROOD]}, "delay": 1, "do": [
        {"objective": {"id": "f_queen", "set": "active"}}, {"clock": {"name": "queen", "secs": QUEEN_SECS}}]},
    # the wild pack comes for the big pen at once; the east pen's Mother breaks out a little later
    {"id": "wild_go", "when": {"fired": "part2"}, "delay": WILD_GO, "do": [
        {"pace": {"tag": "wild_mother", "pace": MOTHER_PACE}},
        {"order": {"team": "wild", "do": "attack", "to": "way_w"}}]},
    {"id": "wild_go2", "when": {"all": [{"fired": "wild_go"}, {"not": {"fired": "part3"}}, LIVE]}, "delay": 25, "do": [
        {"order": {"team": "wild", "do": "attack", "to": "big_pen", "idle": True}}]},
    {"id": "east_go", "when": {"all": [{"fired": "part2"}, LIVE]}, "delay": EAST_GO, "do": [
        {"cage": {"tag": "pen_mother", "on": False}}, {"wake": {"name": "east_pen"}},
        {"spare": {"tag": "pen_mother", "on": False}}, {"spare": {"tag": "pen_pack", "on": False}},
        {"pace": {"tag": "pen_mother", "pace": MOTHER_PACE}},
        {"order": {"team": "pens", "do": "attack", "to": "way_n"}},
        {"ping": {"area": "pen_3"}}, {"say": ["n_east"]}]},
    # (a pack that reached the big pen and stands: it presses on to the nearest Mother of another side)
    {"id": "east_go2", "when": {"all": [{"fired": "east_go"}, {"not": {"fired": "part3"}}, LIVE]}, "delay": 14, "do": [
        {"order": {"team": "pens", "do": "attack", "to": "big_pen", "idle": True}}]},
    {"id": "rivals_press", "when": {"all": [{"fired": "wild_go"}, {"not": {"fired": "part3"}}, LIVE]}, "delay": 30, "every": 6, "do": [
        {"order": {"tag": "rivals", "do": "hunt", "prey": "mothers", "within": 22, "idle": True}},
        {"order": {"tag": "rival_mother", "do": "hunt", "prey": "mothers", "within": 22, "idle": True}}]},
    {"id": "fight_say", "when": {"all": [{"fired": "east_go"}, {"any": [{"near": {"tag": "wild_pack", "to": "pen_pack", "within": 6}},
                                                                     {"near": {"tag": "rivals", "to_team": "stock", "within": 6}}]}]}, "do": [{"say": ["p_fight", "l_fight"]}]},
    {"id": "lost_say", "when": {"all": [{"broke": {"name": "stock", "at_least": 1}}, BROOD]}, "do": [{"say": ["n_lost"]}]},
    # a rival Mother down: her creatures wander toward the big pen and go to the strongest call left (the player's Mother)
    {"id": "wild_down", "when": {"all": [{"fired": "part2"}, {"dead": "wild_mother"}, LIVE]}, "do": [
        {"counter": {"name": "mothers_down", "add": 1}}, {"say": ["n_wild_down"]},
        {"leash": {"team": "wild", "lure": "call", "within": 1, "loose": "to", "to": "big_pen", "name": "wild",
                   "breaks": {"near": "call", "within": JOIN_R, "to": "stock", "counter": "joined", "warn": 2}}}]},
    {"id": "east_down", "when": {"all": [{"fired": "part2"}, {"dead": "pen_mother"}, LIVE]}, "do": [
        {"counter": {"name": "mothers_down", "add": 1}}, {"say": ["n_east_down"]},
        {"leash": {"team": "pens", "lure": "call", "within": 1, "loose": "to", "to": "big_pen", "name": "pens",
                   "breaks": {"near": "call", "within": JOIN_R, "to": "stock", "counter": "joined", "warn": 2}}}]},
    {"id": "joined_say", "when": {"all": [{"counter": {"name": "joined", "at_least": 1}}, BROOD]}, "do": [{"say": ["n_joined"]}]},
    # ============================================================ PART 3: THE QUEEN
    {"id": "part3", "when": {"all": [{"fired": "wild_down"}, {"fired": "east_down"}, {"not": {"dead": "mother"}}, LIVE]}, "delay": 2, "do": [
        {"objective": {"id": "mothers", "set": "done"}}, {"objective": {"id": "queen", "set": "active", "if": BROOD}},
        {"give": {"team": "stock", "gold": GROW_FOOD, "powder": GROW_SPOILS}},
        # (all she has goes into growing: no eggs and no moults until she is the Queen, so the food for it is never spent)
        {"deny": {"team": "stock", "kind": GROW_DENY, "why": T("Not now: everything she has goes into growing. GROW her first.",
                                                              "Agora não: tudo o que ela tem vai para crescer. Faça-a CRESCER primeiro.",
                                                              "Ahora no: todo lo que tiene se va en crecer. Hazla CRECER primero.")}},
        {"say": ["n_part3", "l_house"]}, {"ping": {"area": "mother_spot"}}]},
    # (the fazenda wakes: the truce is over; the keepers and the guns hold the palisade)
    {"id": "faz_wake", "when": {"all": [{"fired": "part3"}, NO_FAZ]}, "do": [
        {"spare": {"tag": "faz_all", "on": False}}, {"spare": {"tag": "fazenda_b", "on": False}}, {"carry": {"tag": "faz_all", "on": False}},
        {"spare": {"tag": "lindqvist", "on": True}},
        {"order": {"tag": "keepers", "do": "move", "to": "house_in"}}, {"order": {"tag": "guns", "do": "hold"}}]},
    {"id": "faz_hold", "when": {"fired": "faz_wake"}, "delay": 12, "do": [{"order": {"tag": "keepers", "do": "hold"}}]},
    {"id": "faz_hands", "when": {"all": [{"fired": "part3"}, NO_FAZ, {"difficulty": ["normal", "hard"]}]}, "do": [
        {"spawn": {"team": "fazenda", "kind": "musketeer", "as": "keeper", "count": 2, "at": "house_in", "tag": "hands", "tags": ["people", "faz_all"]}},
        {"order": {"tag": "hands", "do": "hold"}}]},
    # NO WAITING while she grows: Lindqvist sends the keepers out to shoot her before it is done
    {"id": "sally", "when": {"all": [{"fired": "part3"}, NO_FAZ, BROOD, {"rooted": {"tag": "mother"}}, {"count": {"tag": "mother", "area": "big_pen"}},
                                     {"not": {"fired": "queen"}}, LIVE]}, "delay": 12, "do": [
        {"say": ["p_changing", "l_shoot"]}, {"order": {"tag": "keepers", "do": "attack", "to": "big_pen"}}, {"ping": {"area": "way_w"}}]},
    {"id": "sally_back", "when": {"all": [{"fired": "sally"}, LIVE]}, "delay": 70, "do": [{"order": {"tag": "keepers", "do": "move", "to": "house_in"}}]},
    {"id": "grow_hint", "when": {"all": [{"fired": "part3"}, BROOD, {"rooted": {"tag": "mother"}}, {"count": {"tag": "mother", "area": "big_pen"}}]},
     "delay": 4, "do": [{"say": ["n_growing"]}]},
    # the Queen: she has grown to stage 3 (the player's GROW, or the mirror's clock)
    {"id": "queen", "when": {"all": [{"fired": "part2"}, {"brood_stage": {"tag": "mother", "at_least": 3}}, LIVE]}, "do": [
        {"objective": {"id": "queen", "set": "done"}}, {"flag": {"queen": "grown"}},
        {"name": {"tag": "mother", "name": T("The Queen", "A Rainha", "La Reina")}},
        {"sound": {"name": "campaign/forest_answer", "area": "big_pen", "vol": -2}},
        {"show": {"pages": [{"still": "flood", "lines": ["s_1"]}, {"still": "fight", "lines": ["s_2"]},
                            {"still": "queen", "lines": ["s_3", "l_show"]}]}},
        # every bred creature still loose on the island turns to her; no leash holds anything any more (her call is the
        # whole island's: the Brood's creatures are free to go where the player sends them)
        {"leash": {"name": "stock", "on": False}}, {"leash": {"name": "wild", "on": False}}, {"leash": {"name": "pens", "on": False}},
        {"unlock": {"team": "stock", "kind": GROW_DENY}},
        {"convert": {"tag": "rivals", "to": "stock", "warn": 2}},
        {"convert": {"tag": "rival_mother", "to": "stock", "warn": 2}}]},
    {"id": "fall", "when": {"all": [{"fired": "queen"}, BROOD, LIVE]}, "delay": 3, "do": [
        {"objective": {"id": "fall", "set": "active"}}, {"say": ["n_fall"]},
        # (the bred creatures that reached the Queen: hers when she grew, the turned ones counted in)
        {"counter": {"name": "went", "count": {"tag": "bred", "of_team": "stock"}}},
        {"give": {"team": "stock", "gold": BRUTE_FOOD, "powder": BRUTE_SPOILS}},
        # (SAY IT PLAINLY: the house and its palisade shown, not left in the dark for the player to look for)
        {"reveal": {"area": "house", "side": "brood"}},
        {"ping": {"tag": "big_house"}}]},
    # (no grubs on the flooded island: the drowned cane and the carrion feed the Queen's swamp a little at a time, so the
    # fall never stalls for want of food)
    {"id": "queen_food", "when": {"all": [{"fired": "queen"}, BROOD, LIVE]}, "delay": 8, "every": 8, "do": [
        {"give": {"team": "stock", "gold": QUEEN_FOOD, "powder": QUEEN_SPOILS}}]},
    # Lindqvist and Pieter run for the canoes (the exit opens), the lure book left upstairs
    {"id": "run_go", "when": {"all": [{"fired": "queen"}, NO_FAZ, LIVE]}, "delay": 6, "do": [
        {"say": ["l_run", "p_book", "l_book"]}, {"flag": {"book": "left"}},
        {"order": {"tag": "runners", "do": "move", "to": "canoes"}}, {"pace": {"tag": "runners", "pace": 1.3}}]},
    {"id": "run_again", "when": {"all": [{"fired": "run_go"}, LIVE]}, "delay": 8, "every": 8, "do": [
        {"order": {"tag": "runners", "do": "move", "to": "canoes"}}]},
    {"id": "breach", "when": {"all": [{"fired": "fall"}, {"hurt": "palisade"}, {"count": {"tag": "palisade", "buildings": True, "below": len(RING)}}]}, "do": [
        {"say": ["n_breach"]}]},
    {"id": "canoe_2", "when": {"all": [{"counter": {"name": "fled_l", "at_least": 1}}, {"counter": {"name": "fled_p", "at_least": 1}}]}, "do": [{"say": ["n_canoe"]}]},
    {"id": "canoe_1", "when": {"all": [{"counter": {"name": "fled_l", "at_least": 1}}, {"dead": "pieter"}, {"counter": {"name": "fled_p", "below": 1}}]}, "do": [{"say": ["n_canoe1"]}]},
    {"id": "pieter_lost", "when": {"all": [{"fired": "part2"}, {"dead": "pieter"}, {"counter": {"name": "fled_p", "below": 1}}, LIVE]}, "do": [{"say": ["n_pieter_lost"]}]},
    # ============================================================ THE END (the Brood): the big house broken
    {"id": "house_down", "when": {"all": [{"fired": "queen"}, {"dead": "big_house"}, LIVE]}, "do": [
        {"say": ["n_house"]}, {"objective": {"id": "fall", "set": "done"}},
        {"tally": {"flag": "brood_n", "counter": "went", "of": "bred_n", "bands": [[0, "few"], [BAND_SOME, "some"], [BAND_ALL, "all"]]}},
        {"flag": {"lindqvist": "fled"}}, {"flag": {"book": "left"}}]},
    {"id": "house_pieter", "when": {"fired": "house_down"}, "do": [
        {"flag": {"pieter": "alive", "if": {"any": [{"counter": {"name": "fled_p", "at_least": 1}}, {"count": {"tag": "pieter", "at_least": 1}}]}}},
        {"flag": {"pieter": "lost", "if": {"all": [{"counter": {"name": "fled_p", "below": 1}}, {"count": {"tag": "pieter", "below": 1}}]}}}]},
    {"id": "the_end", "when": {"all": [{"fired": "house_down"}, BROOD]}, "delay": 6, "do": [{"win": "brood"}]},
    # the Mother dead: lost (as the Brood)
    {"id": "lost_mother", "when": {"all": [{"dead": "mother"}, BROOD, {"not": {"fired": "queen"}}]}, "do": [{"say": ["n_mother_dead"]}]},
    # ============================================================ THE FAZENDA (the solo pick, versus): burn three pens, then the canoes
] + [
    t for (pen, area) in [("big", "burn_big"), ("north", "pen_2"), ("east", "pen_3")] for t in [
        {"id": "burn_" + pen, "when": {"all": [{"any": [{"fired": "p2_f"}, {"all": [{"fired": "setup_mirror"}, FAZ]}]}, {"stay": {"tag": "people", "area": area, "secs": BURN_SECS}},
                                               {"not": {"fired": "queen"}}, LIVE]}, "do": [
            {"counter": {"name": "burned", "add": 1}}, {"say": ["n_f_burn"]}, {"ping": {"area": area}},
            {"flag": {"burned_" + pen: "yes"}}]},
    ]
] + [
    {"id": "burn_big_delay", "when": {"all": [{"fired": "burn_big"}, NO_BROOD]}, "do": [{"say": ["l_f_big"]}, {"clock": {"name": "queen", "add": BURN_DELAY}}]},
    {"id": "f_burned_all", "when": {"all": [{"counter": {"name": "burned", "at_least": 3}}, FAZ, LIVE]}, "do": [
        {"objective": {"id": "f_burn", "set": "done"}}, {"say": ["l_f_go"]}]},
    {"id": "f_warn", "when": {"all": [{"clock_left": {"name": "queen", "below": 60}}, FAZ, NO_BROOD, LIVE]}, "do": [{"say": ["p_f_warn"]}]},
    # (the mirror's Queen: the strongest Mother grows when the clock runs out)
    {"id": "f_queen_grows", "when": {"all": [{"clock_out": "queen"}, NO_BROOD, LIVE]}, "do": [
        {"brood_stage": {"tag": "mother", "stage": 3}}, {"objective": {"id": "f_queen", "set": "failed"}}]},
    {"id": "f_lost", "when": {"all": [{"fired": "queen"}, FAZ, {"not": {"fired": "f_won"}}]}, "do": [
        {"say": ["l_f_lost"]}, {"objective": {"id": "f_burn", "set": "failed"}}]},
    {"id": "f_won", "when": {"all": [{"fired": "f_burned_all"}, {"counter": {"name": "fled_l", "at_least": 1}}, FAZ, {"not": {"fired": "queen"}}]}, "do": [
        {"say": ["l_f_won"]}, {"objective": {"id": "f_canoes", "set": "done"}},
        {"flag": {"brood_n": "few"}}, {"flag": {"lindqvist": "fled"}}, {"flag": {"book": "taken"}},
        {"flag": {"pieter": "alive", "if": {"any": [{"counter": {"name": "fled_p", "at_least": 1}}, {"count": {"tag": "pieter", "at_least": 1}}]}}},
        {"flag": {"pieter": "lost", "if": {"all": [{"counter": {"name": "fled_p", "below": 1}}, {"count": {"tag": "pieter", "below": 1}}]}}}]},
    {"id": "f_end", "when": {"fired": "f_won"}, "delay": 4, "do": [{"win": "fazenda"}]},
    # ============================================================ HURTS
    {"id": "l_hurt", "when": {"all": [{"hp": {"tag": "lindqvist", "below": 0.6}}, FAZ]}, "every": 60, "times": 2, "do": [{"say": ["h_hurt"]}, {"ping": {"tag": "lindqvist"}}]},
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

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the Brood is bound to B5 (was B6): GROW to stage 3 and the BRUTE
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID)
for k in ("stage3", "brute"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hub after d06 (campaign/campaign.json, campaign/hubs_grow.json)
OTHER = [
    ("The Mother", "A Mãe", "La Madre"),
    ("A Brood Mother of Lindqvist's stock, three years grown, rooted in the big pen.", "Uma Mãe da Ninhada do plantel de Lindqvist, crescida há três anos, enraizada no curral grande.",
     "Una Madre de la Prole de la cría de Lindqvist, crecida desde hace tres años, enraizada en el corral grande."),
    ("The east pen's Mother", "A Mãe do curral do leste", "La Madre del corral del este"),
    ("Another of Lindqvist's breeding Mothers, younger, fenced in the north-east pen.", "Outra das Mães de criação de Lindqvist, mais nova, cercada no curral do nordeste.",
     "Otra de las Madres de cría de Lindqvist, más joven, cercada en el corral del noreste."),
    ("The wild Mother", "A Mãe selvagem", "La Madre salvaje"),
    ("A wild Brood Mother carried onto the island by the flood.", "Uma Mãe da Ninhada selvagem trazida para a ilha pela cheia.",
     "Una Madre de la Prole salvaje traída a la isla por la crecida."),
    ("The Boat House at Óbidos", "O Barracão de Óbidos", "El Cobertizo de Óbidos"),
    ("Lindqvist's refuge after the island: a boat house on the river at Óbidos, a few crates saved, the stud book if Pieter kept it.",
     "O refúgio de Lindqvist depois da ilha: um barracão no rio em Óbidos, umas poucas caixas salvas, o livro de criação se Pieter o guardou.",
     "El refugio de Lindqvist después de la isla: un cobertizo en el río en Óbidos, unas pocas cajas salvadas, el libro de cría si Pieter lo guardó."),
    ("A boat house on the river at Óbidos: wet crates, a lamp, the island's smoke far up the river.",
     "Um barracão no rio em Óbidos: caixas molhadas, um candeeiro, o fumo da ilha lá longe rio acima.",
     "Un cobertizo en el río en Óbidos: cajas mojadas, un candil, el humo de la isla lejos río arriba."),
    ("The flood did it. Something in the water, something from the north shore. I bred them well.",
     "Foi a cheia. Alguma coisa na água, alguma coisa da margem norte. Eu criei-os bem.",
     "Fue la crecida. Algo en el agua, algo de la orilla norte. Yo los crié bien."),
    ("They fought in my pens, Mother against Mother. The one that won grew in a minute what should take a year.",
     "Lutaram nos meus currais, Mãe contra Mãe. A que ganhou cresceu num minuto o que devia levar um ano.",
     "Lucharon en mis corrales, Madre contra Madre. La que ganó creció en un minuto lo que debería llevar un año."),
    ("The lure book is still in the house. Whoever finds it can call them.", "O livro dos engodos ainda está na casa. Quem o encontrar pode chamá-los.",
     "El libro de los señuelos sigue en la casa. Quien lo encuentre puede llamarlos."),
    ("I burned three pens and the book went with me. Rome will say I burned too little.", "Queimei três currais e o livro veio comigo. Roma vai dizer que queimei pouco.",
     "Quemé tres corrales y el libro vino conmigo. Roma dirá que quemé poco."),
    ("I am alone now. Pieter stayed on the island.", "Estou sozinho agora. Pieter ficou na ilha.", "Ahora estoy solo. Pieter se quedó en la isla."),
    ("The stud book is wet through. I dried it page by page by the lamp.", "O livro de criação ficou encharcado. Sequei-o página a página junto ao candeeiro.",
     "El libro de cría se empapó. Lo sequé página a página junto al candil."),
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
rows = ["# Act 2's mission d06_queen, \"The Queen\" (campaign/missions/d06_queen.json, written with its texts by",
        "# tools/campaign/make_d06_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what was",
        "# built: docs/campaign_d06_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: lure = engodo / señuelo; stock = plantel /",
        "# cría; keeper = tratador / cuidador; Brood Mother = Mãe da Ninhada / Madre de la Prole; swivel gun = pedreiro / pedrero.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
