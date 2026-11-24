#!/usr/bin/env python3
"""Writes campaign/missions/d01_minas.json: Act 2's "The Gold of Vila Rica" (the Crown line after a07, Minas Gerais,
2772; the plan: docs/campaign_act2_plan.md "d01_minas"; what was built: docs/campaign_d01_build.md), and its Portuguese
and Spanish (tools/i18n/campaign/d01_minas.txt: every text here is written as T(english, pt, es), so the three never
drift apart).
  python3 tools/campaign/make_d01_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_vila_rica_map.py (THE CITY GENERATOR in hills, THE HIGHLANDS biome). EVERY LINE IS A
PLACEHOLDER for the owner to rewrite.

Two years after Rome, Father Tomasz is a missionary in Brazil. In Vila Rica, the gold town of Minas Gerais, the Crown
reads the DERRAMA (the hated collection of the gold tax owed) on the square, and the Free Assembly's Brazilian cell means
to use that day: seize the Royal Foundry House and its gold, and proclaim a free republic of the mines.
  THE GARRISON (PURPLE, p1): Captain Luís de Meneses' Musketeers and dragoons, a Field Cannon, the barracks, the Horse
    Breeder and THE ROSTER LADDER's C5: the ARMOURY with the MATCHLOCK and the SOCKET BAYONET. Father Tomasz (a hero:
    wounded, not killed).
  THE TOWN (YELLOW, scripted): the townsfolk, the four churches (the Pilar, the Carmo, the Rosário, Santa Efigênia), the
    houses; THE TREASURY (PURPLE, scripted): the Royal Foundry House and, in Part 3, its gold carts.
  THE CONSPIRACY (the Free Assembly, ORANGE; scripted, or versus p2): Lieutenant Inácio Ramos, militia with muskets
    bought with a southern guild's gold, miners turned mob, two hidden armouries among the town's houses.
  PART 1, THE DERRAMA: THE TOWN'S TEMPER rises (every quarter nobody has spoken to, every agitator who reaches a
    churchyard or the square); Tomasz goes to each quarter's churchyard (a STAY) and calms it; find the two hidden
    armouries (DISGUISED houses, a01's) and close them before the signal.
  PART 2, THE NIGHT OF THE SIGNAL: a bell from the wrong church; the rising comes up the stairs from the Rosário and the
    diggings at once, and along the ridge from the Pilar; hold the Royal Foundry House (the bayonet on the stairs);
    Tomasz may call the miners home from the Rosário; the second armoury holds the conspiracy's ledger (the d04 hint).
  PART 3, THE GOLD ROAD: four gold carts from the Foundry House to the coast, through the gorge where the last band
    waits on the ledges; TAKE A CART (d02's) for the conspirators; catch Ramos alive, or he flees south.
  NO CHOICE. CARRIES: `minas` quiet / restless (the temper at the signal), `gold` few / some / all (carts arrived),
    `conspirator` taken / fled, and `ledger` found (the ledger read: d04's guild gold).
  VERSUS: the friend is THE CONSPIRACY: raise the town, burn the Foundry House, take the gold, or (a person hunting
    him) bring Father Tomasz down.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
sys.path.insert(0, HERE)
import make_vila_rica_map   # noqa: E402

CITY = make_vila_rica_map.build()
STILL = "res://campaign/stills/%s.jpg"
MID = "d01_minas"

# ---------------------------------------------------------------- the texts, three languages at once
TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d01_minas.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
P01_SAVED = past("p01_leaf.families", "save")
P01_LEFT = {"not": P01_SAVED}                       # (left, or p01 not known: Tomasz carries it, as a01 reads it)
LYON_RISEN = past("a01_presses.lyon", "risen")      # (the Assembly won a01: a RECLAIM note, Lyon in unrest)
LYON_SULLEN = past("a01_presses.lyon", "sullen")
LYON_CALM = {"all": [{"not": LYON_RISEN}, {"not": LYON_SULLEN}]}
PRINTER = {"not": LYON_RISEN}                       # (a01 is won only with the printer taken: the canon; risen = not taken)
EXECUTED = past("a06_barricades.varenne", "executed")
SPARED = {"not": EXECUTED}
ROME_FEW = past("a07_council.rome", "few")
D04_CRATES = past("d04_concordia.crates", "opened")
VAL = {"playing": "conspiracy"}                     # (versus: a person leads the conspiracy)
NO_VAL = {"not": VAL}
LIVE = {"not": {"any": [{"fired": "the_end"}, {"fired": "v_end"}, {"fired": "lost_end"}]}}

# ---------------------------------------------------------------- numbers (NORMAL; EASY clocks x1.25 spawns x0.75, HARD x0.9 / x1.15)
GOLD, POWDER = 400, 400       # the garrison's purse at the start (the Armoury's research and refits, Musketeers)
PAY_EVERY = 60                # the Crown pays its garrison 40 gold and 15 powder a minute
TEMPER_START = 3              # THE TOWN'S TEMPER at the reading (+3 with a07 `rome` few, +2 with a06 Varenne executed)
TEMPER_TOP = {"easy": 24, "normal": 20, "hard": 16}   # at the top, Vila Rica rises (lost)
QUIET_UNDER = 10              # the temper at the signal under this: `minas` quiet, else restless
TAX_FIRST, TAX_EVERY = 45, 60  # a quarter nobody has spoken to: +1 every TAX_EVERY s (from TAX_FIRST)
CALM_SECS = 4                 # Father Tomasz this long in a quarter's churchyard calms it (the temper -3)
SEARCH = 3                    # a Crown man this long at a house's door (2 tiles) sees what it is
RUNNER = {"easy": 85, "normal": 65, "hard": 50}       # seconds between one armoury's agitators
HINT = {"easy": 150, "normal": 180, "hard": 220}       # the town's people give an armoury away (the first still hidden)
SIGNAL_SECS = 360             # Part 1: the signal is expected this long after the reading (a countdown: scaled)
SIGNAL_SOON = 40              # ... or this soon once both armouries are closed
BAND_GAP = 55                 # Part 2: the Pilar's band (and the captured gun) comes along the ridge this long after the first two
LAST_GAP = 95                 # ... and Ramos's last push up the Rua Direita this long after them
NIGHT_SECS = 300              # ... the rising breaks at the latest this long after the signal
BREAK_AT = 3                  # ... or when fewer than this are left of it (all of it come)
MINERS_SECS = 4               # Tomasz this long in the Rosário's churchyard at night calls the miners home
CARTS_WAIT = 40               # Part 3: the carts leave the Foundry House this long after the dawn
CARTS_N = 4
CART_PACE = 0.8               # the gold carts on the road (58 x 0.8: the escort on foot keeps up with ease)
RAMOS_RUN = 45                # Ramos, running for the hollow, is gone at the latest this long after he runs

QUARTERS = ["pilar", "carmo", "rosario", "efigenia"]
CANDS = ["cand_%d" % i for i in range(1, 9)]
LAYOUTS = {               # where the conspiracy hides its two armouries (candidate numbers): the first holds the ledger
    "hills": [2, 4],
    "low": [5, 8],
    "west": [1, 7],
    "east": [3, 6],
}
LAYOUT_LABEL = {"hills": T("ON THE TWO HILLS", "NAS DUAS COLINAS", "EN LAS DOS COLINAS"),
                "low": T("IN THE LOW QUARTERS", "NOS BAIRROS BAIXOS", "EN LOS BARRIOS BAJOS"),
                "west": T("THE PILAR AND THE DIGGINGS", "O PILAR E AS LAVRAS", "EL PILAR Y LAS MINAS"),
                "east": T("THE CARMO AND THE ROSÁRIO", "O CARMO E O ROSÁRIO", "EL CARMO Y EL ROSARIO")}
LAYOUT_ABOUT = {"hills": T("One on the Pilar's slope, one on the Carmo's.", "Um na encosta do Pilar, outro na do Carmo.", "Uno en la ladera del Pilar, otro en la del Carmo."),
                "low": T("One in the Rosário, one in the diggings north of the square.", "Um no Rosário, outro nas lavras a norte da praça.",
                         "Uno en el Rosario, otro en las minas al norte de la plaza."),
                "west": T("One low on the Pilar, one in the diggings.", "Um em baixo no Pilar, outro nas lavras.", "Uno abajo en el Pilar, otro en las minas."),
                "east": T("One low on the Carmo, one in the Rosário.", "Um em baixo no Carmo, outro no Rosário.", "Uno abajo en el Carmo, otro en el Rosario.")}
QUARTER_OF_CAND = {1: "pilar", 2: "pilar", 3: "carmo", 4: "carmo", 5: "rosario", 6: "rosario", 7: "efigenia", 8: "efigenia"}

# the garrison's quarter (the lower town under the square): its buildings (top-left cells)
BARRACKS, ARMOURY, BREEDER = [51, 49], [56, 49], [68, 49]
QUARTERS_COTTAGES = [[51, 55], [54, 55], [57, 55], [68, 55], [71, 55]]
# the gold road: the carts' waypoints from the Foundry House to the coast
GOLD_ROUTE = ["foundry_door", "sq_s", "road_turn", "road_mid", "gorge_w", "gorge_mid", "gorge_e", "coast"]
# the rising's ways to the square
RISE_R = ["rise_rosario", "road_w", "below_sq_s", "sq_s", "praca"]
RISE_E = ["rise_efigenia", "below_sq_n", "sq_n", "praca"]
RISE_P = ["rise_pilar", "ridge_w", "praca"]


def area_list():
    a = dict(CITY.areas)
    a.update(make_vila_rica_map.areas_extra(CITY))
    return a


AREAS = area_list()


def layout_cond(lid):
    return {"flag": {"layout": lid}}


def place_armouries(lid):
    """The option's actions: the two armouries (the conspiracy's cottages, disguised as the town's) and the town's own
    houses on the other candidates."""
    out = []
    picks = LAYOUTS[lid]
    for k in range(1, 9):
        at = CITY.lots["cand_%d" % k]["at"]
        if k in picks:
            i = picks.index(k) + 1
            out.append({"build": {"team": "conspiracy", "kind": "cottage", "at": at, "tag": "armouries", "tags": ["armoury_%d" % i],
                                  "name": T("Hidden armoury", "Arsenal escondido", "Arsenal escondido"),
                                  "disguise": {"as": "town", "within": 2, "by": "crown", "secs": SEARCH}}})
        else:
            out.append({"build": {"team": "town", "kind": "cottage", "at": at, "tag": "town_b"}})
    return out


def runner_to(order):
    """Where an agitator goes: the first churchyard in his order whose quarter nobody has calmed; all calmed: the square."""
    return [{"if": {"not": {"fired": "calm_" + q}}, "to": "adro_" + q} for q in order]


RUN_ORDER = {1: ["rosario", "pilar", "efigenia", "carmo"], 2: ["carmo", "efigenia", "pilar", "rosario"]}


def runner_triggers():
    tr = []
    for i in (1, 2):
        for d, per in RUNNER.items():
            tr.append({"id": "run_%d_%s" % (i, d),
                       "when": {"all": [{"fired": "layout"}, {"difficulty": d}, {"time": 30 + (i - 1) * per / 2.0},
                                        {"not": {"dead": "armoury_%d" % i}}, {"not": {"fired": "signal"}}, LIVE]},
                       "every": per,
                       "do": [{"spawn": {"team": "conspiracy", "kind": "labourer", "as": "agitator", "count": 1, "fixed": True,
                                         "near": "armoury_%d" % i, "at": "rise_rosario", "tag": "runner_%d" % i, "tags": ["runner"]}},
                              {"order": {"tag": "runner_%d" % i, "do": "move", "to": "praca", "to_if": runner_to(RUN_ORDER[i]), "idle": True}}]})
    return tr


def armoury_triggers():
    tr = []
    for i in (1, 2):
        tr.append({"id": "found_%d" % i, "when": {"unmasked": "armoury_%d" % i}, "do": [
            {"hurt": {"tag": "armoury_%d" % i, "amount": 120}},          # (its door broken in as it is found)
            {"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "conspirator", "count": 2, "near": "armoury_%d" % i,
                       "at": "rise_rosario", "tag": "armoury_men", "order": "hold"}}]})
        tr.append({"id": "closed_%d" % i, "when": {"all": [{"fired": "layout"}, {"dead": "armoury_%d" % i}]}, "do": [
            {"counter": {"name": "closed", "add": 1}}, {"counter": {"name": "temper", "add": -2, "min": 0}},
            {"give": {"team": "garrison", "gold": 60}}, {"say": ["n_closed"]}]})
        # the town's people give the first armoury still hidden away (EASY sooner, HARD later)
        for d, t0 in HINT.items():
            tr.append({"id": "hint_%d_%s" % (i, d),
                       "when": {"all": [{"fired": "layout"}, {"difficulty": d}, {"time": t0 + (i - 1) * 90},
                                        {"disguised": "armouries"}, {"not": {"fired": "signal"}}, LIVE]},
                       "do": [{"unmask": {"tag": "armouries", "first": True}}, {"say": ["w_hint"]}]})
    return tr


# ================================================================== the mission
units = [
    # ---- the garrison (the player): the captain, the priest, the Musketeers, the dragoons, the gun
    {"team": "garrison", "kind": "cuirassier", "as": "meneses", "count": 1, "at": "camp", "tag": "meneses"},
    {"team": "garrison", "kind": "missionary", "as": "tomasz_minas", "count": 1, "at": [62, 56], "tag": "tomasz"},
    {"team": "garrison", "kind": "musketeer", "count": 14, "at": "camp", "tag": "garrison_men", "fixed": True},
    {"team": "garrison", "kind": "cuirassier", "count": 4, "at": "camp", "tag": "riders", "fixed": True},
    {"team": "garrison", "kind": "cannon", "count": 1, "at": "camp", "tag": "gun", "fixed": True},
    # ---- the town: a crowd on the square for the reading, a few at each churchyard
    {"team": "town", "kind": "labourer", "as": "townsman", "count": 8, "at": "praca", "tag": "townsfolk", "order": "hold", "fixed": True},
] + [
    {"team": "town", "kind": "labourer", "as": "townsman", "count": 2, "at": "adro_" + q, "tag": "townsfolk", "order": "hold", "fixed": True}
    for q in QUARTERS
] + [
    # ---- the conspiracy (versus: the friend's men from the start, in the Rosário)
    {"team": "conspiracy", "kind": "dismounted", "as": "ramos", "count": 1, "at": "rise_rosario", "tag": "ramos", "if": VAL},
    {"team": "conspiracy", "kind": "musketeer", "as": "conspirator", "count": 4, "at": "rise_rosario", "tag": "v_men", "if": VAL},
]

buildings = (
    [{"team": "garrison", "kind": "barracks", "at": BARRACKS, "tag": "barracks"},
     {"team": "garrison", "kind": "armoury", "at": ARMOURY, "tag": "armoury"},
     {"team": "garrison", "kind": "horse_breeder", "at": BREEDER, "tag": "breeder"}]
    + [{"team": "garrison", "kind": "cottage", "at": c, "tag": "quarters"} for c in QUARTERS_COTTAGES]
    + [{"team": "treasury", "kind": "town_hall", "at": CITY.lots["foundry"]["at"], "tag": "foundry",
        "name": T("The Royal Foundry House", "A Casa Real de Fundição", "La Real Casa de Fundición")}]
    + [{"team": "town", "kind": "church", "at": CITY.lots["church_" + q]["at"], "tag": "church_" + q, "tags": ["churches"],
        "name": nm} for q, nm in [("pilar", T("The Pilar", "O Pilar", "El Pilar")), ("carmo", T("The Carmo", "O Carmo", "El Carmo")),
                                  ("rosario", T("The Rosário", "O Rosário", "El Rosario")),
                                  ("efigenia", T("Santa Efigênia", "Santa Efigênia", "Santa Efigenia"))]]
    + [{"team": "town", "kind": "cottage", "at": CITY.lots["home_%d" % i]["at"], "tag": "town_b"} for i in range(1, 13)]
)

TAKE = [
    # TAKE A CART (d02's): conspirators round a gold cart with no soldier of the Crown by it for 5 s take it, gold and all
    {"tag": "carts", "by": "conspiracy", "to": "seized", "secs": 5, "counter": "carts_taken", "as": "taken",
     "label": T("TAKING THE GOLD", "A LEVAR O OURO", "LLEVÁNDOSE EL ORO"), "word": T("GOLD TAKEN!", "OURO LEVADO!", "¡ORO ROBADO!")},
    # ... and the Crown's men round a taken cart take it back
    {"tag": "taken", "by": "crown", "to": "treasury", "secs": 4, "counter": "retaken", "as": "retaken",
     "label": T("TAKING IT BACK", "A RETOMAR", "RECUPERÁNDOLO"), "word": T("TAKEN BACK!", "RETOMADA!", "¡RECUPERADO!")},
]

objectives = [
    # ---- part 1: the derrama
    {"id": "temper", "side": "crown", "primary": True, "kind": "manual",
     "text": T("THE TOWN'S TEMPER: {temper} of {temper_top}. It rises in every quarter nobody has spoken to, and for every agitator who reaches a churchyard or the square. At the top, Vila Rica rises.",
               "O ÂNIMO DA VILA: {temper} de {temper_top}. Sobe em cada bairro com quem ninguém falou, e por cada agitador que chega a um adro ou à praça. No topo, Vila Rica levanta-se.",
               "EL ÁNIMO DEL PUEBLO: {temper} de {temper_top}. Sube en cada barrio con el que nadie ha hablado, y por cada agitador que llega a un atrio o a la plaza. En lo alto, Vila Rica se alza."),
     "phone": T("The town's temper: {temper} of {temper_top}. At the top, Vila Rica rises.", "O ânimo da vila: {temper} de {temper_top}. No topo, Vila Rica levanta-se.",
                "El ánimo del pueblo: {temper} de {temper_top}. En lo alto, Vila Rica se alza.")},
    {"id": "calm", "side": "crown", "primary": False, "task": True, "kind": "manual",
     "text": T("Father Tomasz goes to the people: bring him to each quarter's churchyard (the cross before its church) and keep him there a moment. The Pilar (west hill), the Carmo (east hill), the Rosário (south-west), Santa Efigênia (the diggings, north). Calmed: {calmed} of 4.",
               "O Padre Tomasz vai ao povo: leve-o ao adro de cada bairro (o cruzeiro diante da igreja) e mantenha-o lá um momento. O Pilar (colina oeste), o Carmo (colina leste), o Rosário (sudoeste), Santa Efigênia (as lavras, norte). Acalmados: {calmed} de 4.",
               "El padre Tomasz va al pueblo: llévalo al atrio de cada barrio (la cruz ante su iglesia) y mantenlo allí un momento. El Pilar (colina oeste), el Carmo (colina este), el Rosario (suroeste), Santa Efigenia (las minas, norte). Calmados: {calmed} de 4."),
     "phone": T("Bring Father Tomasz to each churchyard a moment: {calmed} of 4.", "Leve o Padre Tomasz a cada adro um momento: {calmed} de 4.",
                "Lleva al padre Tomasz a cada atrio un momento: {calmed} de 4.")},
    {"id": "armouries", "side": "crown", "primary": False, "task": True, "kind": "manual",
     "text": T("Find the conspiracy's two hidden armouries and close them before the signal: {closed} of 2. They look like any house until one of your men stands at its door a moment. The agitators come out of them: your horsemen can ride them down.",
               "Encontre os dois arsenais escondidos da conspiração e feche-os antes do sinal: {closed} de 2. Parecem uma casa qualquer até um dos seus homens ficar à porta um momento. Os agitadores saem deles: os seus cavaleiros podem alcançá-los.",
               "Encuentra los dos arsenales escondidos de la conspiración y ciérralos antes de la señal: {closed} de 2. Parecen una casa cualquiera hasta que uno de tus hombres se queda a la puerta un momento. Los agitadores salen de ellos: tus jinetes pueden alcanzarlos."),
     "phone": T("Find and close the two hidden armouries: {closed} of 2. A man at a door a moment.", "Encontre e feche os dois arsenais: {closed} de 2. Um homem à porta um momento.",
                "Encuentra y cierra los dos arsenales: {closed} de 2. Un hombre a la puerta un momento.")},
    {"id": "signal_clock", "side": "crown", "primary": False, "task": True, "kind": "countdown", "clock": "signal",
     "text": T("The conspirators' signal is expected tonight: {clock:signal}.", "O sinal dos conspiradores é esperado esta noite: {clock:signal}.",
               "La señal de los conspiradores se espera esta noche: {clock:signal}.")},
    {"id": "research", "side": "crown", "primary": False, "task": True, "kind": "manual", "hidden": True,
     "text": T("At the Armoury (the lower town, beside the barracks), research the MATCHLOCK and the SOCKET BAYONET before night, then turn on AUTO REFIT there so your Musketeers are fitted.",
               "No Arsenal (a cidade baixa, ao lado do quartel), pesquise a MECHA e a BAIONETA DE ENCAIXE antes da noite, e depois ligue AUTO-REEQUIPAR ali para que os seus Mosqueteiros sejam equipados.",
               "En la Armería (la ciudad baja, junto al cuartel), investiga la MECHA y la BAYONETA DE CUBO antes de la noche, y luego activa AUTOEQUIPAR allí para que tus Mosqueteros se equipen."),
     "phone": T("Armoury: research MATCHLOCK and SOCKET BAYONET, then AUTO REFIT.", "Arsenal: pesquise MECHA e BAIONETA DE ENCAIXE, depois AUTO-REEQUIPAR.",
                "Armería: investiga MECHA y BAYONETA DE CUBO, luego AUTOEQUIPAR.")},
    # ---- always
    {"id": "tomasz", "side": "crown", "primary": True, "kind": "protect", "tag": "tomasz",
     "text": T("Father Tomasz must live. Hurt, he falls back to the barracks.", "O Padre Tomasz tem de viver. Ferido, recua para o quartel.",
               "El padre Tomasz debe vivir. Herido, se retira al cuartel.")},
    # ---- part 2: the night of the signal
    {"id": "foundry", "side": "crown", "primary": True, "kind": "protect", "tag": "foundry", "hidden": True,
     "text": T("Hold the Royal Foundry House on the square: the gold is in it.", "Segure a Casa Real de Fundição na praça: o ouro está lá dentro.",
               "Defiende la Real Casa de Fundición en la plaza: el oro está dentro.")},
    {"id": "rising", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("The rising comes up the stairs to the square, from the Rosário (the Rua Direita), the diggings (the north stair) and the Pilar (the ridge). Hold the stairs with the bayonet: {rising_left} of the rising left.",
               "A revolta sobe as escadas para a praça, do Rosário (a Rua Direita), das lavras (a escada norte) e do Pilar (o espigão). Segure as escadas à baioneta: restam {rising_left} da revolta.",
               "La revuelta sube las escaleras hacia la plaza, desde el Rosario (la Rua Direita), las minas (la escalera norte) y el Pilar (la cresta). Defiende las escaleras a la bayoneta: quedan {rising_left} de la revuelta."),
     "phone": T("Hold the square's stairs: {rising_left} of the rising left.", "Segure as escadas da praça: restam {rising_left} da revolta.",
                "Defiende las escaleras de la plaza: quedan {rising_left} de la revuelta.")},
    {"id": "miners", "side": "crown", "primary": False, "task": True, "kind": "manual", "hidden": True,
     "text": T("The miners with picks are no soldiers. Bring Father Tomasz to the Rosário's churchyard (south-west) a moment: the brotherhood's priest may call them home.",
               "Os mineiros de picareta não são soldados. Leve o Padre Tomasz ao adro do Rosário (sudoeste) um momento: o padre da irmandade pode chamá-los para casa.",
               "Los mineros con picos no son soldados. Lleva al padre Tomasz al atrio del Rosario (suroeste) un momento: el cura de la hermandad puede llamarlos a casa.")},
    {"id": "ledger", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
     "text": T("The second armoury still stands: the conspiracy's papers are kept in it. Close it.", "O segundo arsenal ainda está de pé: os papéis da conspiração estão lá. Feche-o.",
               "El segundo arsenal sigue en pie: los papeles de la conspiración están dentro. Ciérralo.")},
    # ---- part 3: the gold road
    {"id": "gold", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("Bring the gold to the coast: {gold_out} of {carts_n} carts arrived. The carts take the road east through the gorge. Keep soldiers by every cart: conspirators who stand round a cart with none of yours by it TAKE it.",
               "Leve o ouro à costa: {gold_out} de {carts_n} carroças chegaram. As carroças vão pela estrada para leste, pela garganta. Mantenha soldados junto a cada carroça: conspiradores à volta de uma carroça sem nenhum dos seus ao lado LEVAM-NA.",
               "Lleva el oro a la costa: {gold_out} de {carts_n} carros llegaron. Los carros van por el camino al este, por la garganta. Mantén soldados junto a cada carro: los conspiradores que rodean un carro sin ninguno de los tuyos al lado se lo LLEVAN."),
     "phone": T("Gold to the coast: {gold_out} of {carts_n}. Soldiers by every cart.", "Ouro à costa: {gold_out} de {carts_n}. Soldados junto a cada carroça.",
                "Oro a la costa: {gold_out} de {carts_n}. Soldados junto a cada carro.")},
    {"id": "carts_clock", "side": "crown", "primary": False, "task": True, "kind": "countdown", "clock": "carts", "hidden": True,
     "text": T("The carts leave the Foundry House in {clock:carts}: put an escort with them.", "As carroças saem da Casa de Fundição em {clock:carts}: ponha uma escolta com elas.",
               "Los carros salen de la Casa de Fundición en {clock:carts}: pon una escolta con ellos.")},
    {"id": "ledges", "side": "crown", "primary": False, "task": True, "kind": "manual", "hidden": True,
     "text": T("Men wait on the two rock ledges over the gorge. Send soldiers up the ledges' stairs (from the road, and from the scrub south of it) and clear them before the carts pass: {ledge_left} up there.",
               "Há homens à espera nas duas saliências de rocha sobre a garganta. Mande soldados pelas escadas das saliências (da estrada, e do mato a sul dela) e limpe-as antes de as carroças passarem: {ledge_left} lá em cima.",
               "Hay hombres esperando en las dos repisas de roca sobre la garganta. Manda soldados por las escaleras de las repisas (desde el camino, y desde el matorral al sur) y límpialas antes de que pasen los carros: {ledge_left} allí arriba.")},
    {"id": "ramos", "side": "crown", "primary": False, "kind": "capture", "tag": "ramos", "hidden": True,
     "text": T("Take Lieutenant Ramos ALIVE: wear him down, then a man of yours beside him.", "Capture o Tenente Ramos VIVO: desgaste-o, depois um dos seus homens ao lado dele.",
               "Captura al teniente Ramos VIVO: desgástalo, luego uno de tus hombres a su lado.")},
    # ---- the conspiracy (versus)
    {"id": "v_town", "side": "conspiracy", "primary": False, "kind": "manual",
     "text": T("Raise Vila Rica: walk your agitators to the churchyards and the square. The town's temper: {temper} of {temper_top}.",
               "Levante Vila Rica: leve os seus agitadores aos adros e à praça. O ânimo da vila: {temper} de {temper_top}.",
               "Alza Vila Rica: lleva a tus agitadores a los atrios y a la plaza. El ánimo del pueblo: {temper} de {temper_top}.")},
    {"id": "v_gold", "side": "conspiracy", "primary": False, "kind": "manual",
     "text": T("Or burn the Royal Foundry House at night, or take its gold on the road.", "Ou queime a Casa Real de Fundição de noite, ou leve o seu ouro na estrada.",
               "O quema la Real Casa de Fundición de noche, o llévate su oro en el camino.")},
]

M = {
    "id": MID,
    "title": T("The Gold of Vila Rica", "O Ouro de Vila Rica", "El Oro de Vila Rica"),
    "summary": T("Minas Gerais, 2772. On the day of the gold tax the Free Assembly's cell means to seize Vila Rica's Royal Foundry House. Father Tomasz, a missionary in Brazil now, and the garrison stand in its way.",
                 "Minas Gerais, 2772. No dia da derrama a célula da Assembleia Livre quer tomar a Casa Real de Fundição de Vila Rica. O Padre Tomasz, agora missionário no Brasil, e a guarnição estão no seu caminho.",
                 "Minas Gerais, 2772. El día del impuesto del oro la célula de la Asamblea Libre quiere tomar la Real Casa de Fundición de Vila Rica. El padre Tomasz, ahora misionero en Brasil, y la guarnición se lo impiden."),
    "map": "campaign:vila_rica",
    "voice": "d01",
    "light": "day",
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["a07_council"],
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {"clocks": 0.9, "spawns": 1.15}},
    "modes": ["solo", "versus"],
    "factions": {"free_assembly": {"name": T("The Free Assembly", "A Assembleia Livre", "La Asamblea Libre"), "stand_in": "crown", "campaign_only": True}},
    "sides": [
        {"id": "crown", "name": T("The Crown", "A Coroa", "La Corona"),
         "about": T("Captain Meneses' garrison and Father Tomasz, in the gold town of Vila Rica.",
                    "A guarnição do Capitão Meneses e o Padre Tomasz, na vila do ouro de Vila Rica.",
                    "La guarnición del capitán Meneses y el padre Tomasz, en el pueblo del oro de Vila Rica.")},
        {"id": "conspiracy", "name": T("The Conspiracy", "A Conspiração", "La Conspiración"),
         "about": T("The Free Assembly's cell in the mines: Lieutenant Ramos, his militia and the miners he stirs up.",
                    "A célula da Assembleia Livre nas minas: o Tenente Ramos, a sua milícia e os mineiros que ele agita.",
                    "La célula de la Asamblea Libre en las minas: el teniente Ramos, su milicia y los mineros que agita.")},
    ],
    "teams": [
        {"id": "garrison", "side": "crown", "faction": "crown", "colour": 4, "start": "none", "camera": "camp", "gold": GOLD, "powder": POWDER,
         "control": {"solo": "p1", "versus": "p1"}},
        {"id": "treasury", "side": "crown", "faction": "crown", "colour": 4, "start": "none", "camera": "praca",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "town", "side": "crown", "faction": "crown", "colour": 3, "start": "none", "camera": "praca",
         "control": {"solo": "script", "versus": "script"}},
        # (the miners called home: a team on the Crown's side so nobody fights them)
        {"id": "calmed", "side": "crown", "faction": "crown", "colour": 3, "start": "none", "camera": "adro_rosario",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "conspiracy", "side": "conspiracy", "faction": "free_assembly", "colour": 5, "start": "none", "camera": "rise_rosario", "gold": 0,
         "roster": {"deny": ["town_hall", "cottage", "farm", "foundry", "horse_breeder", "armoury", "church", "powder_mill",
                             "barracks", "wall", "gate", "musketeer", "labourer", "cuirassier", "cannon", "missionary"]},
         "control": {"solo": "script", "versus": "p2"}},
        # (the carts the conspirators took: they drive for the hollow by themselves)
        {"id": "seized", "side": "conspiracy", "faction": "free_assembly", "colour": 5, "start": "none", "camera": "hollow",
         "control": {"solo": "script", "versus": "script"}},
    ],
    "areas": AREAS,
    "counters": {"temper": {"start": TEMPER_START}, "temper_top": {"start": TEMPER_TOP["normal"]}, "calmed": {"start": 0}, "closed": {"start": 0},
                 "rising_left": {"start": 0}, "miners_home": {"start": 0}, "gold_out": {"start": 0}, "gold_lost": {"start": 0},
                 "carts_n": {"start": CARTS_N}, "carts_taken": {"start": 0}, "retaken": {"start": 0}, "ledge_left": {"start": 0},
                 "ramos_gone": {"start": 0}},
    "take_carts": TAKE,
    "exits": (
        # an agitator who reaches a churchyard or the square stirs it: the temper +1
        [{"area": "adro_" + q, "tag": "runner", "counter": "temper"} for q in QUARTERS]
        + [{"area": "praca", "tag": "runner", "counter": "temper"},
           # the miners called home walk off by the west road
           {"area": "home_town", "tag": "gone_home", "counter": "miners_home", "after": "part2"},
           # Part 3: the gold leaves by the coast road; taken gold by the hollow beyond the east ford
           {"area": "coast", "tag": "carts", "cargo": True, "cargo_counter": "gold_out", "after": "part3"},
           {"area": "hollow", "tag": "taken", "cargo": True, "cargo_counter": "gold_lost", "after": "part3"},
           {"area": "hollow", "tag": "ramos", "counter": "ramos_gone", "after": "ramos_run"}]
    ),
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["tomasz", "meneses"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "crown", "portrait": "res://campaign/hub/rome_king_face.png"},
        "cardinal": {"name": T("Cardinal Tomasz", "Cardeal Tomasz", "Cardenal Tomasz"), "side": "crown", "portrait": "res://campaign/hub/rome_tomasz_face.png"},
        "tomasz": {"name": T("Father Tomasz", "Padre Tomasz", "Padre Tomasz"), "side": "crown"},
        "meneses": {"name": T("Captain Meneses", "Capitão Meneses", "Capitán Meneses"), "side": "crown"},
        "ramos": {"name": T("Lieutenant Ramos", "Tenente Ramos", "Teniente Ramos"), "side": "conspiracy"},
        "townsman": {"name": T("A townsman", "Um morador", "Un vecino"), "side": "crown"},
        "narrator": {"name": T("Vila Rica", "Vila Rica", "Vila Rica"), "side": "crown"},
    },
    "lines": {},
    "stills": {},
    "next": {"crown": "", "conspiracy": ""},
}

L = M["lines"]


def line(lid, who, en, pt, es, to=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    return lid


CR, CO = "crown", "conspiracy"
# ---- the opening (the King, then Tomasz; the old Cardinal one line)
line("k_open1", "king", "After Rome I sent Tomasz to Brazil. He asked to go. He said the fire would come there next, and he wanted to be standing in it.",
     "Depois de Roma mandei o Tomasz para o Brasil. Ele pediu para ir. Disse que o fogo chegaria lá a seguir, e queria estar no meio dele.",
     "Después de Roma envié a Tomasz a Brasil. Él pidió ir. Dijo que el fuego llegaría allí después, y quería estar en medio.")
line("k_open2", "king", "The gold of the mines paid for my armies. In Vila Rica, the men who dug it had been told that it paid only for my chains.",
     "O ouro das minas pagava os meus exércitos. Em Vila Rica, aos homens que o cavavam tinham dito que pagava só as minhas correntes.",
     "El oro de las minas pagaba mis ejércitos. En Vila Rica, a los hombres que lo cavaban les habían dicho que pagaba solo mis cadenas.")
line("c_open", "cardinal", "I was thirty, and I thought I had learnt everything in Lyon. Minas taught me the rest.",
     "Eu tinha trinta anos, e julgava ter aprendido tudo em Lyon. Minas ensinou-me o resto.",
     "Tenía treinta años, y creía haberlo aprendido todo en Lyon. Minas me enseñó el resto.")
line("t_open1", "tomasz", "Vila Rica sits on two hills and a ridge, with a church on every height and gold in every stream. The day I came, the derrama was to be read on the square.",
     "Vila Rica assenta em duas colinas e num espigão, com uma igreja em cada alto e ouro em cada ribeiro. No dia em que cheguei, a derrama ia ser lida na praça.",
     "Vila Rica se asienta en dos colinas y una cresta, con una iglesia en cada altura y oro en cada arroyo. El día que llegué, la derrama iba a leerse en la plaza.")
line("t_open2", "tomasz", "The derrama: the gold the town still owed the Crown, collected house by house in one day. Nobody in the mines had a kind word for it, and some had a plan.",
     "A derrama: o ouro que a vila ainda devia à Coroa, cobrado casa a casa num só dia. Ninguém nas minas tinha uma palavra boa para ela, e alguns tinham um plano.",
     "La derrama: el oro que el pueblo aún debía a la Corona, cobrado casa por casa en un solo día. Nadie en las minas tenía una palabra buena para ella, y algunos tenían un plan.")
line("t_open_saved", "tomasz", "I had seen what Virginia's families became when someone stood by them. I meant to stand by these.",
     "Eu vira o que as famílias da Virgínia se tornaram quando alguém ficou ao lado delas. Queria ficar ao lado destas.",
     "Había visto en qué se convirtieron las familias de Virginia cuando alguien se quedó a su lado. Quería quedarme al lado de estas.")
line("t_open_left", "tomasz", "I never stopped praying for the road we left them on, in Virginia. I did not mean to leave anyone on a road again.",
     "Nunca deixei de rezar pela estrada onde os deixámos, na Virgínia. Não queria deixar mais ninguém numa estrada.",
     "Nunca dejé de rezar por el camino donde los dejamos, en Virginia. No quería dejar a nadie más en un camino.")
line("t_open_risen", "tomasz", "I carried a letter from Lyon in my breviary. Lyon had risen behind us. The Assembly's ink had crossed the sea before I did.",
     "Levava uma carta de Lyon no breviário. Lyon levantara-se atrás de nós. A tinta da Assembleia atravessara o mar antes de mim.",
     "Llevaba una carta de Lyon en el breviario. Lyon se había alzado tras nosotros. La tinta de la Asamblea había cruzado el mar antes que yo.")
# ---- part 1: the derrama
line("n_derrama", "narrator", "On the square the Crown's officer reads the decree of the derrama from the steps of the Foundry House. The crowd listens in silence.",
     "Na praça o oficial da Coroa lê o decreto da derrama dos degraus da Casa de Fundição. A multidão ouve em silêncio.",
     "En la plaza el oficial de la Corona lee el decreto de la derrama desde los escalones de la Casa de Fundición. La multitud escucha en silencio.")
line("m_1", "meneses", "Father, I have fourteen muskets and four horses for a town of thirty thousand. If they rise, I hold the Foundry House and nothing else.",
     "Padre, tenho catorze mosquetes e quatro cavalos para uma vila de trinta mil. Se se levantarem, seguro a Casa de Fundição e mais nada.",
     "Padre, tengo catorce mosquetes y cuatro caballos para un pueblo de treinta mil. Si se alzan, defiendo la Casa de Fundición y nada más.", CR)
line("t_1", "tomasz", "Then let us see that they do not rise, Captain. I will go to the churches. Every quarter has one, and every church has its people.",
     "Então vejamos que não se levantem, Capitão. Eu vou às igrejas. Cada bairro tem uma, e cada igreja tem o seu povo.",
     "Entonces veamos que no se alcen, capitán. Iré a las iglesias. Cada barrio tiene una, y cada iglesia tiene su gente.", CR)
line("m_tip1", "meneses", "And the Assembly's men are somewhere in those houses, with powder. My men will knock on doors. Stand a man at a door and we will know what is behind it.",
     "E os homens da Assembleia estão algures naquelas casas, com pólvora. Os meus homens vão bater às portas. Ponha um homem a uma porta e saberemos o que há por trás dela.",
     "Y los hombres de la Asamblea están en algún lugar de esas casas, con pólvora. Mis hombres llamarán a las puertas. Pon a un hombre a una puerta y sabremos qué hay detrás.", CR)
line("m_tip2", "meneses", "Their runners carry the pamphlets from house to house. Ride them down before they reach the churchyards: every one that gets there makes the town angrier.",
     "Os mensageiros deles levam os panfletos de casa em casa. Alcance-os antes de chegarem aos adros: cada um que lá chega deixa a vila mais zangada.",
     "Sus correos llevan los panfletos de casa en casa. Alcánzalos antes de que lleguen a los atrios: cada uno que llega enfada más al pueblo.", CR)
line("m_armoury", "meneses", "One more thing, Father. The Crown sent us an Armoury this year, and it has not been used. If there is fighting on those stairs tonight, I want better locks and bayonets that can stay fixed.",
     "Mais uma coisa, Padre. A Coroa mandou-nos um Arsenal este ano, e ainda não foi usado. Se houver luta naquelas escadas esta noite, quero mechas melhores e baionetas que fiquem caladas.",
     "Una cosa más, padre. La Corona nos envió una Armería este año, y no se ha usado. Si hay lucha en esas escaleras esta noche, quiero mejores llaves y bayonetas que se queden caladas.", CR)
line("m_researched", "meneses", "Matchlocks and socket bayonets. Now the men must go to the Armoury to be fitted: turn on AUTO REFIT and send them by.",
     "Mechas e baionetas de encaixe. Agora os homens têm de ir ao Arsenal para serem equipados: ligue AUTO-REEQUIPAR e mande-os passar por lá.",
     "Mechas y bayonetas de cubo. Ahora los hombres deben ir a la Armería a equiparse: activa AUTOEQUIPAR y mándalos pasar por allí.", CR)
line("t_pamphlet_calm", "tomasz", "The pamphlets were printed on the Lyon type. The last of it, the printer swore. The ink was still wet.",
     "Os panfletos estavam impressos com o tipo de Lyon. O último, jurou o impressor. A tinta ainda estava fresca.",
     "Los panfletos estaban impresos con los tipos de Lyon. Los últimos, juró el impresor. La tinta aún estaba fresca.", CR)
line("t_pamphlet_sullen", "tomasz", "The pamphlets were printed on the Lyon type. Lyon still prints.", "Os panfletos estavam impressos com o tipo de Lyon. Lyon ainda imprime.",
     "Los panfletos estaban impresos con los tipos de Lyon. Lyon todavía imprime.", CR)
line("t_pamphlet_rome", "tomasz", "ROME BURNED AND THE CHURCH DID NOT FALL, said the pamphlet. THE NEXT FIRE WILL BE OURS. Half the town had read it.",
     "ROMA ARDEU E A IGREJA NÃO CAIU, dizia o panfleto. O PRÓXIMO FOGO SERÁ NOSSO. Metade da vila tinha-o lido.",
     "ROMA ARDIÓ Y LA IGLESIA NO CAYÓ, decía el panfleto. EL PRÓXIMO FUEGO SERÁ NUESTRO. Medio pueblo lo había leído.", CR)
line("t_martyrs", "tomasz", "Varenne's face was on every pamphlet, drawn as a saint. I had asked for his life in Paris. They had made his death into a banner.",
     "O rosto do Varenne estava em cada panfleto, desenhado como um santo. Eu pedira a vida dele em Paris. Tinham feito da sua morte uma bandeira.",
     "El rostro de Varenne estaba en cada panfleto, dibujado como un santo. Yo había pedido su vida en París. Habían hecho de su muerte una bandera.", CR)
line("t_printer", "tomasz", "The printer's mark from Lyon was on the pamphlets, and Captain Meneses' men knew it. One house printed nothing but it had the same ink on its step.",
     "A marca do impressor de Lyon estava nos panfletos, e os homens do Capitão Meneses conheciam-na. Uma casa não imprimia nada, mas tinha a mesma tinta no degrau.",
     "La marca del impresor de Lyon estaba en los panfletos, y los hombres del capitán Meneses la conocían. Una casa no imprimía nada, pero tenía la misma tinta en el escalón.", CR)
for q, (en, pt, es) in {
    "pilar": ("The Pilar's people are shopkeepers and clerks. I told them that a tax can be argued, and a rising cannot be taken back. They went home to argue.",
              "O povo do Pilar são lojistas e escrivães. Disse-lhes que um imposto se pode discutir, e uma revolta não se pode desfazer. Foram para casa discutir.",
              "La gente del Pilar son tenderos y escribanos. Les dije que un impuesto se puede discutir, y una revuelta no se puede deshacer. Se fueron a casa a discutir."),
    "carmo": ("At the Carmo the masters of the mines asked me whose side the Church was on. I said: on the side of the souls in this square, all of them.",
              "No Carmo os senhores das lavras perguntaram-me de que lado estava a Igreja. Respondi: do lado das almas desta praça, todas elas.",
              "En el Carmo los amos de las minas me preguntaron de qué lado estaba la Iglesia. Respondí: del lado de las almas de esta plaza, todas ellas."),
    "rosario": ("The Rosário is the miners' own church, built with their own gold dust. They knew the tax better than any officer. I listened before I spoke.",
                "O Rosário é a igreja dos próprios mineiros, construída com o seu próprio ouro em pó. Conheciam o imposto melhor do que qualquer oficial. Ouvi antes de falar.",
                "El Rosario es la iglesia de los propios mineros, construida con su propio polvo de oro. Conocían el impuesto mejor que cualquier oficial. Escuché antes de hablar."),
    "efigenia": ("In the diggings they had pamphlets under every stone. I read one aloud to them, slowly, and asked who would pay for it when the soldiers came. Nobody answered.",
                 "Nas lavras tinham panfletos debaixo de cada pedra. Li um em voz alta, devagar, e perguntei quem o pagaria quando os soldados viessem. Ninguém respondeu.",
                 "En las minas tenían panfletos bajo cada piedra. Leí uno en voz alta, despacio, y pregunté quién lo pagaría cuando vinieran los soldados. Nadie respondió."),
}.items():
    line("t_calm_" + q, "tomasz", en, pt, es, CR)
line("n_calmed", "narrator", "The quarter is calm. Its temper falls.", "O bairro está calmo. O seu ânimo baixa.", "El barrio está en calma. Su ánimo baja.", CR)
line("t_calm_all", "tomasz", "Four churches, four sermons, and my voice nearly gone. The town was quiet. Quiet is not the same as at peace.",
     "Quatro igrejas, quatro sermões, e a voz quase perdida. A vila estava calma. Calma não é o mesmo que em paz.",
     "Cuatro iglesias, cuatro sermones, y la voz casi perdida. El pueblo estaba tranquilo. Tranquilo no es lo mismo que en paz.", CR)
line("t_calm_hint", "tomasz", "A woman of the Rosário came to me after the rosary. Strangers carry powder into a house with its shutters always closed. I sent word to the Captain.",
     "Uma mulher do Rosário veio ter comigo depois do terço. Uns estranhos levam pólvora para uma casa de janelas sempre fechadas. Mandei recado ao Capitão.",
     "Una mujer del Rosario vino a verme después del rosario. Unos extraños llevan pólvora a una casa de contraventanas siempre cerradas. Mandé aviso al capitán.", CR)
line("w_runner", "meneses", "There, a runner with a bundle of pamphlets! He is making for a churchyard. Ride him down.",
     "Ali, um mensageiro com um maço de panfletos! Vai para um adro. Alcance-o.", "¡Ahí, un correo con un fajo de panfletos! Va hacia un atrio. Alcánzalo.", CR)
line("n_found", "narrator", "Behind the door: barrels of powder, muskets in straw, and men who reach for them.",
     "Atrás da porta: barris de pólvora, mosquetes na palha, e homens que lhes deitam a mão.", "Tras la puerta: barriles de pólvora, mosquetes en la paja, y hombres que echan mano de ellos.", CR)
line("m_found", "meneses", "An armoury! Break it open and burn what is in it.", "Um arsenal! Arrombem-no e queimem o que lá está.", "¡Un arsenal! Forzadlo y quemad lo que haya dentro.", CR)
line("n_closed", "narrator", "An armoury is closed. The muskets in it will not be fired tonight.", "Um arsenal foi fechado. Os mosquetes que lá estavam não vão disparar esta noite.",
     "Un arsenal ha sido cerrado. Los mosquetes que había dentro no dispararán esta noche.", CR)
line("w_hint", "townsman", "Father! The house with the shutters always closed: men go in at night and nobody comes out. I have marked it for you.",
     "Padre! A casa das janelas sempre fechadas: entram homens de noite e ninguém sai. Marquei-a para si.",
     "¡Padre! La casa de las contraventanas siempre cerradas: entran hombres de noche y nadie sale. Se la he marcado.", CR)
line("n_temper10", "narrator", "Shutters close along the Rua Direita. Men gather at the fountains and stop talking when soldiers pass.",
     "Fecham-se janelas ao longo da Rua Direita. Juntam-se homens nos chafarizes e calam-se quando passam soldados.",
     "Se cierran contraventanas a lo largo de la Rua Direita. Los hombres se juntan en las fuentes y callan cuando pasan los soldados.", CR)
line("n_temper15", "narrator", "Stones fly at the tax collectors in the lower town. Vila Rica is close to rising.",
     "Voam pedras contra os cobradores na cidade baixa. Vila Rica está perto de se levantar.", "Vuelan piedras contra los recaudadores en la ciudad baja. Vila Rica está a punto de alzarse.", CR)
line("m_temper15", "meneses", "Father, they are close to the edge. Stop the runners, or speak to them, or we lose the town.",
     "Padre, estão à beira. Pare os mensageiros, ou fale com eles, ou perdemos a vila.", "Padre, están al borde. Detén a los correos, o háblales, o perdemos el pueblo.", CR)
line("n_risen", "narrator", "Vila Rica rises. The Assembly's flag goes up over the Rosário and the garrison is driven down to the barracks.",
     "Vila Rica levanta-se. A bandeira da Assembleia sobe sobre o Rosário e a guarnição é empurrada para o quartel.",
     "Vila Rica se alza. La bandera de la Asamblea sube sobre el Rosario y la guarnición es empujada hasta el cuartel.")
line("m_soon", "meneses", "Both of their armouries closed! They know they are found. They will give the signal now, tonight. Get the men in hand.",
     "Os dois arsenais deles fechados! Sabem que foram descobertos. Vão dar o sinal agora, esta noite. Reúna os homens.",
     "¡Sus dos arsenales cerrados! Saben que los han descubierto. Darán la señal ahora, esta noche. Reúne a los hombres.", CR)
line("t_ledger", "tomasz", "In the second armoury we found a ledger. The muskets had been paid for in coin from the south, from the agents of a guild of clockmakers. Machines paying for a revolution.",
     "No segundo arsenal encontrámos um livro de contas. Os mosquetes tinham sido pagos em moeda do sul, pelos agentes de uma guilda de relojoeiros. Máquinas a pagar uma revolução.",
     "En el segundo arsenal encontramos un libro de cuentas. Los mosquetes se habían pagado con moneda del sur, por los agentes de un gremio de relojeros. Máquinas pagando una revolución.", CR)
line("t_ledger_d04", "tomasz", "Concórdia, the ledger said. The city of gears on the southern highlands. The guild wanted the Crown's metal, and the Assembly wanted money. They had found each other.",
     "Concórdia, dizia o livro. A cidade das engrenagens nas terras altas do sul. A guilda queria o metal da Coroa, e a Assembleia queria dinheiro. Tinham-se encontrado.",
     "Concórdia, decía el libro. La ciudad de los engranajes en las tierras altas del sur. El gremio quería el metal de la Corona, y la Asamblea quería dinero. Se habían encontrado.", CR)
# ---- part 2: the night of the signal
line("n_signal", "narrator", "Night. A bell rings from the wrong church at the wrong hour: the signal.", "Noite. Um sino toca da igreja errada à hora errada: o sinal.",
     "Noche. Una campana suena desde la iglesia equivocada a la hora equivocada: la señal.")
line("r_signal", "ramos", "Vila Rica! The gold is yours, not Lisbon's, not Rome's! Up, and take the Foundry House!",
     "Vila Rica! O ouro é vosso, não de Lisboa, não de Roma! De pé, e tomem a Casa de Fundição!",
     "¡Vila Rica! ¡El oro es vuestro, no de Lisboa, no de Roma! ¡En pie, y tomad la Casa de Fundición!")
line("m_signal", "meneses", "There it is. They will come up the stairs to the square from below and along the ridge. Hold the stairs, bayonets fixed. Not one of them on the square.",
     "Aí está. Vão subir as escadas para a praça por baixo e pelo espigão. Segurem as escadas, baionetas caladas. Nem um deles na praça.",
     "Ahí está. Subirán las escaleras hacia la plaza desde abajo y por la cresta. Defended las escaleras, bayonetas caladas. Ni uno de ellos en la plaza.", CR)
line("t_signal", "tomasz", "The miners with them have picks, not muskets. They are not soldiers, Captain. Some of them sang at the Rosário this morning.",
     "Os mineiros com eles têm picaretas, não mosquetes. Não são soldados, Capitão. Alguns cantaram no Rosário esta manhã.",
     "Los mineros que van con ellos llevan picos, no mosquetes. No son soldados, capitán. Algunos cantaron en el Rosario esta mañana.", CR)
line("m_signal_t", "meneses", "Then go and get them back, Father, if you can. My men will hold the stairs either way.",
     "Então vá buscá-los, Padre, se conseguir. Os meus homens seguram as escadas de qualquer maneira.",
     "Entonces vaya a recuperarlos, padre, si puede. Mis hombres defenderán las escaleras de todos modos.", CR)
line("n_ridge", "narrator", "More of them along the ridge street, from the Pilar.", "Mais deles pela rua do espigão, vindos do Pilar.", "Más de ellos por la calle de la cresta, desde el Pilar.", CR)
line("t_miners", "tomasz", "I stood in the Rosário's churchyard and rang its own bell, the right bell, and called the brotherhood by name. They came. Not all of them, but they came.",
     "Fiquei no adro do Rosário e toquei o seu próprio sino, o sino certo, e chamei a irmandade pelo nome. Vieram. Nem todos, mas vieram.",
     "Me quedé en el atrio del Rosario y toqué su propia campana, la campana correcta, y llamé a la hermandad por su nombre. Vinieron. No todos, pero vinieron.", CR)
line("n_miners", "narrator", "The miners lower their picks and go home behind the brotherhood's banner.", "Os mineiros baixam as picaretas e vão para casa atrás do estandarte da irmandade.",
     "Los mineros bajan los picos y se van a casa tras el estandarte de la hermandad.", CR)
line("m_gun", "meneses", "They have a gun up there! They took it from the militia's store. Get the dragoons onto the ridge before it fires on the square.",
     "Eles têm um canhão lá em cima! Tiraram-no do depósito da milícia. Mande os dragões para o espigão antes que dispare sobre a praça.",
     "¡Tienen un cañón ahí arriba! Lo sacaron del almacén de la milicia. Manda a los dragones a la cresta antes de que dispare sobre la plaza.", CR)
line("r_last", "ramos", "Once more, up the Rua Direita! Every man who can still stand!", "Mais uma vez, Rua Direita acima! Todo o homem que ainda se aguente de pé!",
     "¡Una vez más, Rua Direita arriba! ¡Todo hombre que aún se tenga en pie!")
line("m_last", "meneses", "Here comes Ramos himself, from the Rosário, up the broad stair. Everyone to the south stair!",
     "Aí vem o próprio Ramos, do Rosário, pela escada larga. Todos para a escada sul!",
     "¡Ahí viene el propio Ramos, desde el Rosario, por la escalera ancha! ¡Todos a la escalera sur!", CR)
line("m_raiders", "meneses", "Riders behind us, out of the hollow over the east ford! They are after the carts. Keep men by them!",
     "Cavaleiros atrás de nós, saídos da depressão pelo vau do leste! Vêm às carroças. Mantenham homens junto delas!",
     "¡Jinetes detrás de nosotros, desde la hondonada por el vado del este! Van a por los carros. ¡Mantened hombres junto a ellos!", CR)
line("m_bayonet", "meneses", "Bayonets! Hold the top of the stairs, and let them climb to you.", "Baionetas! Segurem o alto das escadas, e deixem-nos subir até vocês.",
     "¡Bayonetas! Defended lo alto de las escaleras, y dejad que suban hasta vosotros.", CR)
line("r_fall", "ramos", "Enough! Back, back to the gorge! The gold still has to leave this town, and there is only one road.",
     "Basta! Para trás, para a garganta! O ouro ainda tem de sair desta vila, e só há uma estrada.",
     "¡Basta! ¡Atrás, a la garganta! El oro todavía tiene que salir de este pueblo, y solo hay un camino.")
line("n_broken", "narrator", "The rising breaks on the stairs. What is left of it runs into the dark.", "A revolta quebra-se nas escadas. O que resta dela foge para o escuro.",
     "La revuelta se rompe en las escaleras. Lo que queda de ella huye a la oscuridad.")
line("n_foundry_lost", "narrator", "The Royal Foundry House burns, and the gold with it.", "A Casa Real de Fundição arde, e o ouro com ela.", "La Real Casa de Fundición arde, y el oro con ella.")
line("t_hurt", "tomasz", "I am hit. Do not stop for me, Captain.", "Fui atingido. Não pare por mim, Capitão.", "Me han dado. No se detenga por mí, capitán.", CR)
# ---- part 3: the gold road
line("n_dawn", "narrator", "Dawn over the hills. Smoke over the Rosário, and the gold still in the Foundry House.", "Amanhecer sobre as colinas. Fumo sobre o Rosário, e o ouro ainda na Casa de Fundição.",
     "Amanecer sobre las colinas. Humo sobre el Rosario, y el oro todavía en la Casa de Fundición.")
line("m_gold", "meneses", "The Governor's order: the gold goes to the coast today, before they try again. Four carts, one road, through the gorge.",
     "A ordem do Governador: o ouro vai para a costa hoje, antes que tentem outra vez. Quatro carroças, uma estrada, pela garganta.",
     "La orden del Gobernador: el oro va a la costa hoy, antes de que lo intenten otra vez. Cuatro carros, un camino, por la garganta.", CR)
line("m_gorge", "meneses", "If I were Ramos, I would wait on the rocks above the gorge. Send men up the ledges' stairs before the carts go in, and keep a few by every cart.",
     "Se eu fosse o Ramos, esperava nas rochas por cima da garganta. Mande homens pelas escadas das saliências antes de as carroças entrarem, e mantenha alguns junto a cada carroça.",
     "Si yo fuera Ramos, esperaría en las rocas sobre la garganta. Manda hombres por las escaleras de las repisas antes de que entren los carros, y mantén algunos junto a cada carro.", CR)
line("t_gold", "tomasz", "I asked to ride with the gold. The Captain thought I meant to guard it. I meant to bury whoever died on that road.",
     "Pedi para ir com o ouro. O Capitão pensou que eu queria guardá-lo. Eu queria enterrar quem morresse naquela estrada.",
     "Pedí ir con el oro. El capitán pensó que quería guardarlo. Yo quería enterrar a quien muriera en ese camino.", CR)
line("n_carts_go", "narrator", "The gold carts roll down the Rua Direita and take the road east.", "As carroças do ouro descem a Rua Direita e seguem a estrada para leste.",
     "Los carros del oro bajan por la Rua Direita y toman el camino al este.", CR)
line("r_ambush", "ramos", "Now! Off the rocks! Take the carts, never mind the soldiers!", "Agora! Das rochas! Levem as carroças, não liguem aos soldados!",
     "¡Ahora! ¡Desde las rocas! ¡Llevaos los carros, no hagáis caso a los soldados!")
line("m_ambush", "meneses", "There he is, Ramos himself, on the road ahead! Take him alive if you can: the Governor will want his names.",
     "Ali está ele, o próprio Ramos, na estrada à frente! Capture-o vivo se puder: o Governador vai querer os nomes dele.",
     "¡Ahí está, el propio Ramos, en el camino delante! Captúralo vivo si puedes: el Gobernador querrá sus nombres.", CR)
line("n_taken", "narrator", "A gold cart is taken. The conspirators drive it back for the east ford.", "Uma carroça de ouro foi levada. Os conspiradores conduzem-na de volta para o vau do leste.",
     "Un carro de oro ha sido robado. Los conspiradores lo llevan de vuelta hacia el vado del este.", CR)
line("m_retake", "meneses", "After it! Get round that cart before it crosses the ford and it is ours again.", "Atrás dela! Cerquem aquela carroça antes de atravessar o vau e é nossa outra vez.",
     "¡Tras él! Rodead ese carro antes de que cruce el vado y será nuestro otra vez.", CR)
line("n_retaken", "narrator", "The cart is the Crown's again and turns back for the coast.", "A carroça é da Coroa outra vez e volta para a costa.", "El carro es de la Corona otra vez y vuelve hacia la costa.", CR)
line("n_cart_out", "narrator", "A gold cart is through the gorge, on the road to the coast.", "Uma carroça de ouro passou a garganta, a caminho da costa.", "Un carro de oro ha pasado la garganta, camino de la costa.", CR)
line("r_run", "ramos", "It is lost here. South, to the free city! They will want a man who knows the mines.",
     "Aqui está perdido. Para sul, para a cidade livre! Vão querer um homem que conhece as minas.",
     "Aquí está perdido. ¡Al sur, a la ciudad libre! Querrán a un hombre que conoce las minas.")
line("m_run", "meneses", "He is running for the hollow beyond the east ford! Catch him before he is across!", "Está a fugir para a depressão além do vau do leste! Apanhem-no antes de atravessar!",
     "¡Huye hacia la hondonada más allá del vado del este! ¡Atrapadlo antes de que cruce!", CR)
line("r_taken", "ramos", "Do it quickly, then. The mines will remember me.", "Façam-no depressa, então. As minas vão lembrar-se de mim.", "Hacedlo rápido, entonces. Las minas me recordarán.")
line("t_taken", "tomasz", "He asked me to hear his confession before they took him to the Governor. I did. What he said is between him and God. What he did is between him and the King.",
     "Pediu-me que ouvisse a sua confissão antes de o levarem ao Governador. Ouvi. O que ele disse fica entre ele e Deus. O que ele fez fica entre ele e o Rei.",
     "Me pidió que oyera su confesión antes de llevarlo ante el Gobernador. Lo hice. Lo que dijo queda entre él y Dios. Lo que hizo, entre él y el Rey.", CR)
line("n_fled", "narrator", "Ramos is across the ford and gone into the scrub, south.", "O Ramos atravessou o vau e desapareceu no mato, para sul.", "Ramos ha cruzado el vado y se ha perdido en el matorral, al sur.", CR)
line("m_done", "meneses", "The gold is on the coast road. Vila Rica is the King's.", "O ouro está na estrada da costa. Vila Rica é do Rei.", "El oro está en el camino de la costa. Vila Rica es del Rey.", CR)
line("n_gold_lost", "narrator", "Not one cart reached the coast. The gold of Vila Rica will buy muskets for the next rising.",
     "Nem uma carroça chegou à costa. O ouro de Vila Rica vai comprar mosquetes para a próxima revolta.",
     "Ni un carro llegó a la costa. El oro de Vila Rica comprará mosquetes para la próxima revuelta.")
# ---- the conspiracy (versus)
line("r_v1", "ramos", "Today they read their derrama on our square. Tonight we ring the bell. Walk the pamphlets to the churchyards; let the town hear it.",
     "Hoje leem a derrama deles na nossa praça. Esta noite tocamos o sino. Levem os panfletos aos adros; que a vila os ouça.",
     "Hoy leen su derrama en nuestra plaza. Esta noche tocamos la campana. Llevad los panfletos a los atrios; que el pueblo los oiga.", CO)
line("r_v_tip", "ramos", "Our armouries hide among the houses until a soldier knocks. Keep them hidden: the agitators come out of them.",
     "Os nossos arsenais escondem-se entre as casas até um soldado bater à porta. Mantenham-nos escondidos: os agitadores saem deles.",
     "Nuestros arsenales se esconden entre las casas hasta que un soldado llama. Mantenedlos ocultos: los agitadores salen de ellos.", CO)
# ---- the ending
line("t_end1", "tomasz", "The gold went down to the coast and across the sea, and Vila Rica paid its derrama. I stayed a year among the miners.",
     "O ouro desceu à costa e atravessou o mar, e Vila Rica pagou a sua derrama. Fiquei um ano entre os mineiros.",
     "El oro bajó a la costa y cruzó el mar, y Vila Rica pagó su derrama. Me quedé un año entre los mineros.")
line("t_end_quiet", "tomasz", "The town was quiet after. Not because of the bayonets. Because someone had come to their churches before the bell rang.",
     "A vila ficou calma depois. Não por causa das baionetas. Porque alguém fora às suas igrejas antes de o sino tocar.",
     "El pueblo quedó tranquilo después. No por las bayonetas. Porque alguien había ido a sus iglesias antes de que sonara la campana.")
line("t_end_restless", "tomasz", "The town was quiet after, under the bayonet. I learnt that a quiet bought that way has to be bought again every year.",
     "A vila ficou calma depois, sob a baioneta. Aprendi que uma calma comprada assim tem de ser comprada outra vez todos os anos.",
     "El pueblo quedó tranquilo después, bajo la bayoneta. Aprendí que una calma comprada así hay que comprarla otra vez cada año.")
line("t_end_taken", "tomasz", "Ramos was tried at Vila Rica. I wrote to the King for his life, as I had for Varenne's.",
     "O Ramos foi julgado em Vila Rica. Escrevi ao Rei pela vida dele, como escrevera pela do Varenne.",
     "Ramos fue juzgado en Vila Rica. Escribí al Rey por su vida, como lo había hecho por la de Varenne.")
line("t_end_fled", "tomasz", "Ramos was never found. Years later I heard his name again, from the south, from the city of gears.",
     "O Ramos nunca foi encontrado. Anos depois ouvi o nome dele outra vez, do sul, da cidade das engrenagens.",
     "A Ramos nunca lo encontraron. Años después oí su nombre otra vez, desde el sur, desde la ciudad de los engranajes.")
line("t_end2", "tomasz", "In Lyon I had learnt to speak to a crowd. In Minas I learnt to stay with it afterwards.",
     "Em Lyon aprendera a falar a uma multidão. Em Minas aprendi a ficar com ela depois.",
     "En Lyon había aprendido a hablar a una multitud. En Minas aprendí a quedarme con ella después.")
line("k_end1", "king", "I signed Ramos' sentence and Tomasz' letter lay beside it. I commuted it to exile. You may judge whether I learnt from Paris.",
     "Assinei a sentença do Ramos e a carta do Tomasz estava ao lado. Comutei-a em exílio. Julga tu se aprendi com Paris.",
     "Firmé la sentencia de Ramos y la carta de Tomasz estaba al lado. La conmuté en destierro. Juzga tú si aprendí de París.")
line("k_end_fled", "king", "The gold reached Lisbon. The man who wanted it reached the city of gears. Both kept their appointments with me, later.",
     "O ouro chegou a Lisboa. O homem que o queria chegou à cidade das engrenagens. Os dois cumpriram os seus encontros comigo, mais tarde.",
     "El oro llegó a Lisboa. El hombre que lo quería llegó a la ciudad de los engranajes. Los dos acudieron a sus citas conmigo, más tarde.")
line("k_end2", "king", "The mines stayed mine. I did not lower the tax. Perhaps I should have. Tomasz never said so; he only sent me the names of the dead.",
     "As minas ficaram minhas. Não baixei o imposto. Talvez devesse. O Tomasz nunca o disse; mandou-me apenas os nomes dos mortos.",
     "Las minas siguieron siendo mías. No bajé el impuesto. Quizá debí hacerlo. Tomasz nunca lo dijo; solo me envió los nombres de los muertos.")
line("c_end", "cardinal", "Three hundred names. I still have the list.", "Trezentos nomes. Ainda tenho a lista.", "Trescientos nombres. Todavía tengo la lista.")
line("k_end_v", "king", "The Assembly took the Foundry House and proclaimed its republic of the mines. That is not how it went. The gold reached the coast.",
     "A Assembleia tomou a Casa de Fundição e proclamou a sua república das minas. Não foi assim que aconteceu. O ouro chegou à costa.",
     "La Asamblea tomó la Casa de Fundición y proclamó su república de las minas. No fue así como ocurrió. El oro llegó a la costa.")
line("r_end_v", "ramos", "For one night Vila Rica belonged to the men who dug it. They will not forget it, whatever comes.",
     "Por uma noite Vila Rica pertenceu aos homens que a cavaram. Não o vão esquecer, venha o que vier.",
     "Por una noche Vila Rica perteneció a los hombres que la cavaron. No lo olvidarán, venga lo que venga.")

# ---- stills
M["stills"] = {
    "rome": {"image": STILL % "p01_01", "caption": T("Rome, the present. The King tells it; the Cardinal remembers.", "Roma, o presente. O Rei conta; o Cardeal lembra-se.",
                                                    "Roma, el presente. El Rey lo cuenta; el Cardenal lo recuerda.")},
    "town": {"image": STILL % "d01_01", "caption": T("Vila Rica, Minas Gerais, 2772: the gold town on its hills.", "Vila Rica, Minas Gerais, 2772: a vila do ouro nas suas colinas.",
                                                    "Vila Rica, Minas Gerais, 2772: el pueblo del oro en sus colinas.")},
    "derrama": {"image": STILL % "d01_02", "caption": T("The derrama read on the square.", "A derrama lida na praça.", "La derrama leída en la plaza.")},
    "stairs": {"image": STILL % "d01_03", "caption": T("The night of the signal: the stairs.", "A noite do sinal: as escadas.", "La noche de la señal: las escaleras.")},
    "road": {"image": STILL % "d01_04", "caption": T("The gold road through the gorge.", "A estrada do ouro pela garganta.", "El camino del oro por la garganta.")},
}
M["opening"] = {
    "crown": [{"still": "rome", "lines": ["k_open1", "k_open2", "c_open"]},
              {"still": "town", "lines": ["t_open1", {"id": "t_open_saved", "if": P01_SAVED}, {"id": "t_open_left", "if": P01_LEFT},
                                          {"id": "t_open_risen", "if": LYON_RISEN}]},
              {"still": "derrama", "lines": ["t_open2"]}],
    "conspiracy": [{"still": "rome", "lines": ["k_open2"]}, {"still": "derrama", "lines": ["r_v1"]}],
}
M["ending"] = {
    "crown": [
        {"still": "road", "lines": ["t_end1", {"id": "t_end_quiet", "if": {"flag": {"minas": "quiet"}}},
                                    {"id": "t_end_restless", "if": {"flag": {"minas": "restless"}}},
                                    {"id": "t_end_taken", "if": {"flag": {"conspirator": "taken"}}},
                                    {"id": "t_end_fled", "if": {"flag": {"conspirator": "fled"}}}, "t_end2"]},
        {"still": "rome", "lines": [{"id": "k_end1", "if": {"flag": {"conspirator": "taken"}}}, {"id": "k_end_fled", "if": {"flag": {"conspirator": "fled"}}},
                                    "k_end2", "c_end"]},
    ],
    "conspiracy": [{"still": "stairs", "lines": ["r_end_v"]}, {"still": "rome", "lines": ["k_end_v"]}],
}
M["briefing"] = {
    "crown": {"still": "derrama", "text": [
        T("Minas Gerais, 2772. In Vila Rica, the gold town, the Crown reads the derrama today: the gold tax owed, collected in one day. The Free Assembly's cell means to use it.",
          "Minas Gerais, 2772. Em Vila Rica, a vila do ouro, a Coroa lê hoje a derrama: o imposto do ouro em dívida, cobrado num só dia. A célula da Assembleia Livre quer aproveitá-la.",
          "Minas Gerais, 2772. En Vila Rica, el pueblo del oro, la Corona lee hoy la derrama: el impuesto del oro debido, cobrado en un solo día. La célula de la Asamblea Libre quiere aprovecharla."),
        T("Keep the town's temper down: Father Tomasz goes to each quarter's church, your horsemen ride down the agitators, your men find the two hidden armouries.",
          "Mantenha baixo o ânimo da vila: o Padre Tomasz vai à igreja de cada bairro, os seus cavaleiros alcançam os agitadores, os seus homens encontram os dois arsenais escondidos.",
          "Mantén bajo el ánimo del pueblo: el padre Tomasz va a la iglesia de cada barrio, tus jinetes alcanzan a los agitadores, tus hombres encuentran los dos arsenales escondidos."),
        T("At night hold the Royal Foundry House on the square. At dawn take its gold to the coast through the gorge.",
          "De noite segure a Casa Real de Fundição na praça. Ao amanhecer leve o seu ouro à costa pela garganta.",
          "De noche defiende la Real Casa de Fundición en la plaza. Al amanecer lleva su oro a la costa por la garganta.")]},
    "conspiracy": {"still": "derrama", "text": [
        T("Minas Gerais, 2772. You lead the Free Assembly's cell in Vila Rica under Lieutenant Ramos. Today the Crown reads its derrama on the square.",
          "Minas Gerais, 2772. Você comanda a célula da Assembleia Livre em Vila Rica sob o Tenente Ramos. Hoje a Coroa lê a sua derrama na praça.",
          "Minas Gerais, 2772. Diriges la célula de la Asamblea Libre en Vila Rica a las órdenes del teniente Ramos. Hoy la Corona lee su derrama en la plaza."),
        T("Raise the town with your agitators, burn the Royal Foundry House on the night of the signal, or take its gold on the road to the coast.",
          "Levante a vila com os seus agitadores, queime a Casa Real de Fundição na noite do sinal, ou leve o seu ouro na estrada da costa.",
          "Alza el pueblo con tus agitadores, quema la Real Casa de Fundición la noche de la señal, o llévate su oro en el camino de la costa.")]},
}
M["debrief"] = {
    "crown": {"still": "road", "title": T("The gold of Vila Rica", "O ouro de Vila Rica", "El oro de Vila Rica"),
              "text": T("Vila Rica held. {gold_out} of {carts_n} gold carts reached the coast; {calmed} of 4 quarters were calmed before the signal.",
                        "Vila Rica aguentou. {gold_out} de {carts_n} carroças de ouro chegaram à costa; {calmed} de 4 bairros foram acalmados antes do sinal.",
                        "Vila Rica resistió. {gold_out} de {carts_n} carros de oro llegaron a la costa; {calmed} de 4 barrios se calmaron antes de la señal."),
              "text_if": [
                  {"if": {"flag": {"minas": "quiet"}}, "text": T("The mines are quiet.", "As minas estão calmas.", "Las minas están en calma.")},
                  {"if": {"flag": {"minas": "restless"}}, "text": T("The mines are quiet only under the bayonet.", "As minas só estão calmas sob a baioneta.",
                                                                     "Las minas solo están en calma bajo la bayoneta.")},
                  {"if": {"flag": {"conspirator": "taken"}}, "text": T("Lieutenant Ramos was taken alive.", "O Tenente Ramos foi capturado vivo.", "El teniente Ramos fue capturado vivo.")},
                  {"if": {"flag": {"conspirator": "fled"}}, "text": T("Lieutenant Ramos escaped south.", "O Tenente Ramos fugiu para sul.", "El teniente Ramos huyó al sur.")},
                  {"if": {"flag": {"ledger": "found"}}, "text": T("The conspiracy's ledger was read: its muskets were paid with a southern guild's gold.",
                                                                 "O livro de contas da conspiração foi lido: os seus mosquetes foram pagos com o ouro de uma guilda do sul.",
                                                                 "El libro de cuentas de la conspiración fue leído: sus mosquetes se pagaron con el oro de un gremio del sur.")}]},
    "conspiracy": {"still": "stairs", "title": T("The republic of the mines", "A república das minas", "La república de las minas"),
                   "text": T("The conspiracy took Vila Rica for a night.", "A conspiração tomou Vila Rica por uma noite.", "La conspiración tomó Vila Rica por una noche.")},
}


# ================================================================== the triggers
def band(tag, at, n_cons, n_miners, route, name, cond_extra=None, martyrs=0):
    """A band of the rising: conspirators with muskets (more with an armoury standing, more with Varenne's martyrs) and
    miners with picks; marching for the square (scripted only when no person leads the conspiracy)."""
    out = [{"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "conspirator", "count": n_cons, "at": at, "tag": tag, "tags": ["rising"]}},
           {"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "martyr", "count": max(martyrs, 1), "at": at, "tag": tag, "tags": ["rising"], "if": EXECUTED}}]
    if not martyrs:
        out = out[:1]
    if cond_extra:
        out.append({"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "conspirator", "count": 3, "at": at, "tag": tag, "tags": ["rising"], "if": cond_extra}})
    if n_miners:
        out.append({"spawn": {"team": "conspiracy", "kind": "pikeman", "as": "miner", "count": n_miners, "at": at, "tag": tag, "tags": ["rising", "miners"]}})
    return out


# Part 1's chatter is dropped unseen if the signal has rung while it waited (MissionUi: a line's "until")
for _lid in ["m_tip1", "m_tip2", "t_pamphlet_calm", "t_pamphlet_sullen", "t_pamphlet_rome", "t_martyrs", "m_researched", "w_runner",
             "n_found", "m_found", "n_temper10", "n_temper15", "m_temper15", "t_calm_all", "t_calm_hint", "n_calmed", "n_closed",
             "w_hint"] + ["t_calm_" + _q for _q in QUARTERS]:
    L[_lid]["until"] = "signal"

TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "layout", "when": {"time": 0.5}, "do": [
        {"choice": {"id": "layout", "side": "conspiracy", "title": T("WHERE THE ARMOURIES HIDE", "ONDE SE ESCONDEM OS ARSENAIS", "DÓNDE SE ESCONDEN LOS ARSENALES"),
                    "default": "random", "time": 30,
                    "options": [{"id": lid, "label": LAYOUT_LABEL[lid], "about": LAYOUT_ABOUT[lid], "do": place_armouries(lid)} for lid in LAYOUTS]}}]},
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"spare": {"tag": "townsfolk", "on": True}}, {"spare": {"tag": "churches", "on": True}}, {"spare": {"tag": "town_b", "on": True}},
        {"spare": {"tag": "foundry", "on": True}},
        {"clock": {"name": "signal", "secs": SIGNAL_SECS}},
        {"ping": {"area": "adro_pilar"}}, {"ping": {"area": "adro_carmo"}}, {"ping": {"area": "adro_rosario"}}, {"ping": {"area": "adro_efigenia"}}]},
    {"id": "setup_tempers", "when": {"time": 0.6}, "do": [{"counter": {"name": "temper_top", "set": TEMPER_TOP["normal"]}}]},
    {"id": "setup_easy", "when": {"all": [{"time": 0.6}, {"difficulty": "easy"}]}, "do": [{"counter": {"name": "temper_top", "set": TEMPER_TOP["easy"]}}]},
    {"id": "setup_hard", "when": {"all": [{"time": 0.6}, {"difficulty": "hard"}]}, "do": [{"counter": {"name": "temper_top", "set": TEMPER_TOP["hard"]}}]},
    {"id": "setup_rome", "when": {"all": [{"time": 0.6}, ROME_FEW]}, "do": [{"counter": {"name": "temper", "add": 3}}]},
    {"id": "setup_martyrs", "when": {"all": [{"time": 0.6}, EXECUTED]}, "do": [{"counter": {"name": "temper", "add": 2}}]},
    {"id": "intro", "when": {"all": [{"time": 1.5}, NO_VAL]}, "do": [{"say": ["n_derrama", "m_1", "t_1"]}]},
    {"id": "intro_v", "when": {"all": [{"time": 1.5}, VAL]}, "do": [{"say": ["n_derrama", "r_v1", "r_v_tip"]}]},
    {"id": "intro_tips", "when": {"fired": "intro"}, "delay": 14, "do": [{"say": ["m_tip1", "m_tip2"]}]},
    {"id": "intro_calm", "when": {"time": 1.5}, "do": [{"ping": {"tag": "tomasz"}}]},
    {"id": "flavour_calm", "when": {"all": [{"time": 38}, LYON_CALM, {"talked": True}, {"not": {"fired": "signal"}}]}, "do": [{"say": ["t_pamphlet_calm"]}]},
    {"id": "flavour_sullen", "when": {"all": [{"time": 38}, LYON_SULLEN, {"talked": True}, {"not": {"fired": "signal"}}]}, "do": [{"say": ["t_pamphlet_sullen"]}]},
    {"id": "flavour_rome", "when": {"all": [{"time": 52}, ROME_FEW, {"talked": True}, {"not": {"fired": "signal"}}]}, "do": [{"say": ["t_pamphlet_rome"]}]},
    {"id": "flavour_martyrs", "when": {"all": [{"time": 66}, EXECUTED, {"talked": True}, {"not": {"fired": "signal"}}]}, "do": [{"say": ["t_martyrs"]}]},
    # a01's printer taken (the canon): the printer's mark gives one armoury away at once
    {"id": "printer_shown", "when": {"all": [{"fired": "layout"}, {"time": 24}, PRINTER, {"disguised": "armouries"}]}, "do": [
        {"unmask": {"tag": "armouries", "first": True}}, {"say": ["t_printer"]}]},
    # THE ROSTER LADDER's C5: the Armoury's lesson
    {"id": "armoury_tip", "when": {"time": 30}, "do": [{"say": ["m_armoury"]}, {"objective": {"id": "research", "set": "active"}}, {"ping": {"tag": "armoury"}}]},
    {"id": "researched", "when": {"researched": {"team": "garrison", "tech": ["matchlock", "bayonet"]}}, "do": [
        {"objective": {"id": "research", "set": "done"}}, {"say": ["m_researched"]}]},
    # the Crown pays its garrison
    {"id": "pay", "when": {"all": [{"time": PAY_EVERY}, LIVE]}, "every": PAY_EVERY, "do": [{"give": {"team": "garrison", "gold": 40, "powder": 15}}]},
    # ============================================================ PART 1: THE DERRAMA
    {"id": "first_runner", "when": {"all": [{"count": {"tag": "runner", "at_least": 1}}, NO_VAL]}, "delay": 3, "do": [{"say": ["w_runner"]}, {"ping": {"tag": "runner"}}]},
    {"id": "first_found", "when": {"unmasked": "armouries"}, "do": [{"say": ["n_found", "m_found"]}]},
    {"id": "temper_10", "when": {"all": [{"counter": {"name": "temper", "at_least": 10}}, {"not": {"fired": "signal"}}]}, "do": [{"say": ["n_temper10"]}]},
    {"id": "temper_15", "when": {"all": [{"counter": {"name": "temper", "at_least": 15}}, {"not": {"fired": "signal"}}]}, "do": [{"say": ["n_temper15", "m_temper15"]}]},
    {"id": "calm_all", "when": {"counter": {"name": "calmed", "at_least": 4}}, "do": [{"objective": {"id": "calm", "set": "done"}}, {"say": ["t_calm_all"]}]},
    # (a calm town talks: the quarters Tomasz spoke to tell him where the strangers carry their powder)
    {"id": "calm_hint", "when": {"all": [{"fired": "calm_all"}, {"disguised": "armouries"}, {"not": {"fired": "signal"}}, {"talked": True}, LIVE]}, "delay": 8, "do": [
        {"unmask": {"tag": "armouries", "first": True}}, {"say": ["t_calm_hint"]}]},
    # the first churchyard calmed: the narrator says what it did (once; Tomasz speaks for the others)
    {"id": "calmed_first", "when": {"counter": {"name": "calmed", "at_least": 1}}, "do": [{"say": ["n_calmed"]}]},
    {"id": "closed_all", "when": {"counter": {"name": "closed", "at_least": 2}}, "do": [{"objective": {"id": "armouries", "set": "done"}}]},
    {"id": "signal_soon", "when": {"all": [{"fired": "closed_all"}, {"not": {"fired": "signal"}}, {"not": {"clock_left": {"name": "signal", "below": SIGNAL_SOON}}}, LIVE]}, "do": [
        {"clock": {"name": "signal", "secs": SIGNAL_SOON, "scale": False}}, {"say": ["m_soon"]}]},
    {"id": "ledger", "when": {"all": [{"fired": "layout"}, {"dead": "armoury_2"}]}, "do": [{"say": ["t_ledger"]}, {"flag": {"ledger": "found"}},
                                                                                       {"objective": {"id": "ledger", "set": "done"}}]},
    {"id": "ledger_d04", "when": {"all": [{"fired": "ledger"}, D04_CRATES]}, "delay": 1, "do": [{"say": ["t_ledger_d04"]}]},
] + [
    # a quarter nobody has spoken to raises the temper; Father Tomasz in its churchyard calms it
    {"id": "tax_" + q, "when": {"all": [{"time": TAX_FIRST + 12 * i}, {"not": {"fired": "calm_" + q}}, {"not": {"fired": "signal"}}, LIVE]},
     "every": TAX_EVERY, "do": [{"counter": {"name": "temper", "add": 1}}]} for i, q in enumerate(QUARTERS)
] + [
    {"id": "calm_" + q, "when": {"all": [{"stay": {"tag": "tomasz", "area": "adro_" + q, "secs": CALM_SECS}}, {"not": {"fired": "signal"}}, LIVE]}, "do": [
        {"counter": {"name": "temper", "add": -3, "min": 0}}, {"counter": {"name": "calmed", "add": 1}}, {"say": ["t_calm_" + q]}]}
    for q in QUARTERS
] + [
    # THE TOWN'S TEMPER at its top: Vila Rica rises (lost; versus: the conspiracy's win)
    {"id": "risen", "when": {"all": [{"not": {"fired": "signal"}}, LIVE,
                                     {"any": [{"all": [{"difficulty": d}, {"counter": {"name": "temper", "at_least": TEMPER_TOP[d]}}]} for d in TEMPER_TOP]}]},
     "do": [{"say": ["n_risen"]}, {"objective": {"id": "temper", "set": "failed"}}]},
    # ============================================================ PART 2: THE NIGHT OF THE SIGNAL
    {"id": "signal", "when": {"all": [{"clock_out": "signal"}, {"not": {"fired": "risen"}}, LIVE]}, "do": [
        {"light": {"to": "dusk", "secs": 8}}, {"sound": {"name": "campaign/bell_toll", "area": "adro_efigenia", "vol": 0.9}},
        {"tally": {"flag": "minas", "counter": "temper", "bands": [[0, "quiet"], [QUIET_UNDER, "restless"]]}},
        {"objective": {"id": "temper", "set": "done"}}, {"objective": {"id": "signal_clock", "set": "hidden"}},
        {"objective": {"id": "calm", "set": "hidden"}}, {"objective": {"id": "armouries", "set": "hidden"}},
        {"say": ["n_signal", "r_signal"]},
        # (the armouries still hidden open their doors: the signal is their call too)
        {"unmask": {"tag": "armouries"}}]},
    {"id": "part2", "when": {"all": [{"fired": "signal"}, LIVE]}, "delay": 10, "do": [
        {"light": {"to": "night", "secs": 12}}, {"say": ["m_signal", "t_signal", "m_signal_t"]},
        {"spare": {"tag": "foundry", "on": False}},
        {"objective": {"id": "foundry", "set": "active"}}, {"objective": {"id": "rising", "set": "active"}}, {"objective": {"id": "miners", "set": "active"}},
        {"clock": {"name": "night", "secs": NIGHT_SECS, "scale": False}},
        {"ping": {"area": "below_sq_s"}}, {"ping": {"area": "below_sq_n"}}, {"ping": {"area": "adro_rosario"}}]},
    {"id": "part2_ledger", "when": {"all": [{"fired": "part2"}, {"not": {"dead": "armoury_2"}}, {"count": {"tag": "armoury_2", "at_least": 1, "buildings": True}}]}, "do": [
        {"objective": {"id": "ledger", "set": "active"}}, {"ping": {"tag": "armoury_2"}}]},
    {"id": "band_r", "when": {"fired": "part2"}, "delay": 6, "do":
        band("band_r", "rise_rosario", 4, 3, RISE_R, "band_r", cond_extra={"count": {"tag": "armoury_1", "at_least": 1, "buildings": True}}, martyrs=1)},
    {"id": "band_e", "when": {"fired": "part2"}, "delay": 9, "do":
        band("band_e", "rise_efigenia", 4, 3, RISE_E, "band_e", cond_extra={"count": {"tag": "armoury_2", "at_least": 1, "buildings": True}}, martyrs=1)},
    {"id": "band_p", "when": {"fired": "part2"}, "delay": 6 + BAND_GAP, "do":
        band("band_p", "rise_pilar", 5, 0, RISE_P, "band_p")
        + [{"spawn": {"team": "conspiracy", "kind": "cannon", "as": "captured_gun", "count": 1, "fixed": True, "at": "rise_pilar", "tag": "band_p", "tags": ["rising"]}},
           {"say": ["n_ridge", "m_gun"]}, {"ping": {"area": "ridge_w"}}]},
    {"id": "band_e2", "when": {"fired": "part2"}, "delay": 6 + BAND_GAP + 4, "do": band("band_e2", "rise_efigenia", 3, 0, RISE_E, "band_e2")},
    # Ramos's last push up the Rua Direita (the brotherhood's miners with him, unless Tomasz called them home)
    {"id": "band_last", "when": {"all": [{"fired": "part2"}, {"not": {"fired": "rising_broken"}}]}, "delay": 6 + LAST_GAP, "do":
        band("band_last", "rise_rosario", 6, 0, RISE_R, "band_last", martyrs=1)
        + [{"spawn": {"team": "conspiracy", "kind": "pikeman", "as": "miner", "count": 3, "at": "rise_rosario", "tag": "band_last", "tags": ["rising", "miners"],
                      "if": {"not": {"fired": "miners_home"}}}},
           {"say": ["r_last", "m_last"]}, {"ping": {"area": "below_sq_s"}}]},
    {"id": "band_r_go", "when": {"all": [{"fired": "band_r"}, NO_VAL]}, "do": [{"order": {"tag": "band_r", "do": "route", "route": RISE_R, "attack": True, "name": "band_r"}}]},
    {"id": "band_e_go", "when": {"all": [{"fired": "band_e"}, NO_VAL]}, "do": [{"order": {"tag": "band_e", "do": "route", "route": RISE_E, "attack": True, "name": "band_e"}}]},
    {"id": "band_p_go", "when": {"all": [{"fired": "band_p"}, NO_VAL]}, "do": [{"order": {"tag": "band_p", "do": "route", "route": RISE_P, "attack": True, "name": "band_p"}}]},
    {"id": "band_e2_go", "when": {"all": [{"fired": "band_e2"}, NO_VAL]}, "do": [{"order": {"tag": "band_e2", "do": "route", "route": RISE_E, "attack": True, "name": "band_e2"}}]},
    {"id": "band_last_go", "when": {"all": [{"fired": "band_last"}, NO_VAL]}, "do": [{"order": {"tag": "band_last", "do": "route", "route": RISE_R, "attack": True, "name": "band_last"}}]},
    {"id": "bayonet_say", "when": {"fired": "band_r"}, "delay": 20, "do": [{"say": ["m_bayonet"]}]},
    {"id": "rising_n", "when": {"all": [{"fired": "band_r"}, LIVE]}, "every": 1, "do": [{"counter": {"name": "rising_left", "count": {"tag": "rising"}}}]},
    # (the scripted rising never stands about: every so often whatever is left of it goes for the square)
    {"id": "assault", "when": {"all": [{"fired": "band_r"}, NO_VAL, {"not": {"fired": "rising_broken"}}, LIVE]}, "delay": 50, "every": 15, "do": [
        {"order": {"tag": "rising", "only_team": "conspiracy", "do": "attack", "to": "praca", "idle": True}}]},
    # FATHER TOMASZ calls the miners home from the Rosário's churchyard
    {"id": "miners_home", "when": {"all": [{"fired": "band_e"}, {"stay": {"tag": "tomasz", "area": "adro_rosario", "secs": MINERS_SECS}},
                                           {"count": {"tag": "miners", "at_least": 1}}, {"not": {"fired": "rising_broken"}}, LIVE]}, "do": [
        {"sound": {"name": "campaign/bell_toll", "area": "adro_rosario", "vol": 0.7}},
        {"convert": {"tag": "miners", "to": "calmed", "as": "gone_home", "warn": 1, "untorch": True}},
        {"say": ["t_miners", "n_miners"]}, {"objective": {"id": "miners", "set": "done"}}]},
    {"id": "gone_home_go", "when": {"all": [{"fired": "miners_home"}, LIVE]}, "delay": 1.5, "every": 3, "do": [
        {"order": {"tag": "gone_home", "only_team": "calmed", "do": "move", "to": "home_town"}}]},
    {"id": "rising_spent", "when": {"fired": "band_last"}, "delay": 3, "do": []},
    {"id": "rising_broken", "when": {"all": [{"any": [{"all": [{"fired": "rising_spent"}, {"counter": {"name": "rising_left", "below": BREAK_AT}}]},
                                                      {"clock_out": "night"}]}, {"fired": "part2"}, LIVE]}, "do": [
        {"say": ["r_fall", "n_broken"]}, {"objective": {"id": "rising", "set": "done"}}, {"objective": {"id": "miners", "set": "hidden"}},
        {"order": {"tag": "rising", "only_team": "conspiracy", "do": "move", "to": "home_town"}}, {"clock": {"name": "night", "stop": True}}]},
    {"id": "rising_gone", "when": {"fired": "rising_broken"}, "delay": 14, "do": [{"remove": {"tag": "rising"}}, {"remove": {"tag": "armoury_men"}}, {"remove": {"tag": "runner"}}]},
    {"id": "foundry_lost", "when": {"all": [{"fired": "part2"}, {"dead": "foundry"}, LIVE]}, "do": [
        {"say": ["n_foundry_lost"]}, {"objective": {"id": "foundry", "set": "failed"}}]},
    # ============================================================ PART 3: THE GOLD ROAD
    {"id": "part3", "when": {"all": [{"fired": "rising_broken"}, LIVE]}, "delay": 15, "do": [
        {"light": {"to": "dawn", "secs": 15}}, {"objective": {"id": "foundry", "set": "hidden"}}, {"objective": {"id": "ledger", "set": "hidden"}},
        {"spawn": {"team": "treasury", "kind": "powder_wagon", "as": "gold_cart", "count": CARTS_N, "at": "foundry_door", "tag": "carts", "tags": ["convoy"], "fixed": True}},
        {"load": {"cart": "carts", "cargo": "gold", "amount": 1, "lost": "gold_lost"}},
        {"spare": {"tag": "carts", "on": True}}, {"pace": {"tag": "carts", "pace": CART_PACE}},
        {"objective": {"id": "gold", "set": "active"}}, {"objective": {"id": "carts_clock", "set": "active"}}, {"objective": {"id": "ledges", "set": "active"}},
        {"objective": {"id": "ramos", "set": "active"}},
        {"clock": {"name": "carts", "secs": CARTS_WAIT, "scale": False}},
        # the last band waits on the two ledges over the gorge, Ramos and his takers on the road past it
        {"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "conspirator", "count": 5, "at": "ledge_n", "tag": "ambush", "tags": ["ledge_men"], "order": "hold"}},
        {"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "conspirator", "count": 4, "at": "ledge_s", "tag": "ambush", "tags": ["ledge_men"], "order": "hold"}},
        {"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "martyr", "count": 2, "at": "ledge_n", "tag": "ambush", "tags": ["ledge_men"], "order": "hold", "if": EXECUTED}},
        {"spawn": {"team": "conspiracy", "kind": "dismounted", "as": "ramos", "count": 1, "at": "gorge_e", "tag": "ramos", "order": "hold", "if": NO_VAL}},
        {"spawn": {"team": "conspiracy", "kind": "musketeer", "as": "conspirator", "count": 4, "at": "gorge_e", "tag": "takers", "tags": ["ambush"], "order": "hold"}},
        {"ping": {"area": "ledge_n"}}, {"ping": {"area": "ledge_s"}}]},
    {"id": "part3_say", "when": {"fired": "part3"}, "do": [{"say": ["n_dawn", "m_gold", "m_gorge"]}]},
    {"id": "part3_t", "when": {"fired": "part3"}, "delay": 18, "do": [{"say": ["t_gold"]}]},
    {"id": "ledge_n_count", "when": {"all": [{"fired": "part3"}, LIVE]}, "every": 1, "do": [{"counter": {"name": "ledge_left", "count": {"tag": "ledge_men"}}}]},
    {"id": "ledges_clear", "when": {"all": [{"fired": "part3"}, {"time": 1}, {"count": {"tag": "ledge_men", "below": 1}}]}, "delay": 1, "do": [
        {"objective": {"id": "ledges", "set": "done"}}]},
    {"id": "cart_go", "when": {"all": [{"fired": "part3"}, {"clock_out": "carts"}, LIVE]}, "do": [
        {"objective": {"id": "carts_clock", "set": "hidden"}},
        {"order": {"tag": "carts", "only_team": "treasury", "do": "route", "route": GOLD_ROUTE, "name": "gold_road"}}, {"say": ["n_carts_go"]}]},
    # the ambush: when the first cart comes near the gorge, the takers come down the road for the carts
    {"id": "ambush", "when": {"all": [{"fired": "cart_go"}, {"any": [{"count": {"tag": "carts", "area": "gorge_w", "at_least": 1}},
                                                                    {"count": {"tag": "carts", "area": "road_mid", "at_least": 1}}]}, LIVE]}, "do": [
        {"say": ["r_ambush", "m_ambush"]}, {"ping": {"tag": "ramos"}}, {"clock": {"name": "ramos_clock", "secs": 150, "scale": False}}]},
    # the mule-train riders out of the hollow, over the east ford, for the carts from behind
    {"id": "raiders", "when": {"fired": "ambush"}, "delay": 8, "do": [
        {"spawn": {"team": "conspiracy", "kind": "cuirassier", "as": "mule_rider", "count": 3, "at": "hollow", "tag": "takers", "tags": ["ambush", "raiders"]}},
        {"say": ["m_raiders"]}, {"ping": {"area": "ford_e"}}]},
    {"id": "takers_go", "when": {"all": [{"fired": "ambush"}, NO_VAL, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "takers", "only_team": "conspiracy", "do": "take", "carts": "carts", "within": 40, "else": "gorge_mid"}},
        {"order": {"tag": "ramos", "do": "take", "carts": "carts", "within": 12, "else": "gorge_e"}}]},
    # (the ledges' men come down the stairs to the road for the carts once the ambush is sprung)
    {"id": "ledges_down", "when": {"all": [{"fired": "ambush"}, NO_VAL, LIVE]}, "delay": 4, "do": [
        {"order": {"tag": "ledge_men", "do": "take", "carts": "carts", "within": 30, "else": "gorge_mid"}}]},
    # taken carts drive for the hollow beyond the east ford; taken back, they turn for the coast
    {"id": "taken_go", "when": {"all": [{"taken": "carts"}, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "taken", "only_team": "seized", "do": "move", "to": "hollow"}},
        {"order": {"tag": "taken", "only_team": "treasury", "do": "move", "to": "coast"}}]},
    {"id": "taken_say", "when": {"taken": "carts"}, "do": [{"say": ["n_taken", "m_retake"]}, {"ping": {"tag": "taken"}}]},
    {"id": "retaken_say", "when": {"counter": {"name": "retaken", "at_least": 1}}, "do": [{"say": ["n_retaken"]}]},
    {"id": "cart_out_say", "when": {"counter": {"name": "gold_out", "at_least": 1}}, "do": [{"say": ["n_cart_out"]}]},
    {"id": "carts_n", "when": {"all": [{"fired": "part3"}, LIVE]}, "every": 1, "do": [{"counter": {"name": "carts_left", "count": {"tag": "carts"}}},
                                                                                  {"counter": {"name": "taken_left", "count": {"tag": "taken"}}}]},
    # RAMOS: taken alive (the capture), or he runs for the hollow when his ambush is spent
    {"id": "ramos_taken", "when": {"captured": "ramos"}, "do": [{"say": ["r_taken"]}, {"flag": {"conspirator": "taken"}}]},
    {"id": "ramos_run", "when": {"all": [{"fired": "ambush"}, {"not": {"captured": "ramos"}}, {"count": {"tag": "ramos", "at_least": 1}}, NO_VAL, LIVE,
                                         {"any": [{"count": {"tag": "takers", "below": 1}}, {"clock_out": "ramos_clock"},
                                                  {"all": [{"fired": "cart_go"}, {"counter": {"name": "carts_left", "below": 1}}, {"counter": {"name": "taken_left", "below": 1}}]}]}]},
     "do": [{"say": ["r_run", "m_run"]}, {"order": {"tag": "ramos", "do": "move", "to": "hollow"}}, {"pace": {"tag": "ramos", "pace": 0.85}},
            {"clock": {"name": "ramos_away", "secs": RAMOS_RUN, "scale": False}}, {"ping": {"area": "hollow"}}]},
    {"id": "ramos_on", "when": {"all": [{"fired": "ramos_run"}, {"not": {"captured": "ramos"}}, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "ramos", "do": "move", "to": "hollow"}}]},
    {"id": "ramos_late", "when": {"all": [{"fired": "ramos_run"}, {"clock_out": "ramos_away"}, {"not": {"captured": "ramos"}}]}, "do": [
        {"remove": {"tag": "ramos"}}, {"counter": {"name": "ramos_gone", "add": 1}}]},
    {"id": "ramos_fled", "when": {"all": [{"fired": "ramos_run"}, {"counter": {"name": "ramos_gone", "at_least": 1}}, {"not": {"captured": "ramos"}}]}, "do": [
        {"say": ["n_fled"]}, {"flag": {"conspirator": "fled"}}, {"objective": {"id": "ramos", "set": "failed"}}]},
    # the road done: no cart left on it (arrived, or taken off over the ford)
    {"id": "road_done", "when": {"all": [{"fired": "cart_go"}, {"time": 1}, {"counter": {"name": "carts_left", "below": 1}}, {"counter": {"name": "taken_left", "below": 1}}, LIVE]},
     "delay": 1, "do": [{"tally": {"flag": "gold", "counter": "gold_out", "of": "carts_n", "bands": [[0, "few"], [0.5, "some"], [1, "all"]]}}]},
    {"id": "gold_zero", "when": {"all": [{"fired": "road_done"}, {"counter": {"name": "gold_out", "below": 1}}, LIVE]}, "do": [
        {"say": ["n_gold_lost"]}, {"objective": {"id": "gold", "set": "failed"}}]},
    {"id": "won", "when": {"all": [{"fired": "road_done"}, {"counter": {"name": "gold_out", "at_least": 1}},
                                   {"any": [{"captured": "ramos"}, {"fired": "ramos_fled"}, VAL]}, LIVE]}, "delay": 2, "do": [
        {"say": ["m_done"]}, {"objective": {"id": "gold", "set": "done"}}, {"light": {"to": "day", "secs": 6}}]},
    {"id": "won_ramos_v", "when": {"all": [{"fired": "won"}, VAL, {"not": {"captured": "ramos"}}]}, "do": [{"flag": {"conspirator": "fled"}}]},
    {"id": "the_end", "when": {"fired": "won"}, "delay": 4, "do": [{"win": "crown"}]},
    # ============================================================ THE DEFEATS / THE CONSPIRACY'S WIN
    {"id": "v_won", "when": {"all": [VAL, {"any": [{"fired": "risen"}, {"fired": "foundry_lost"}, {"fired": "gold_zero"}, {"dead": "tomasz"},
                                                   {"counter": {"name": "gold_lost", "at_least": 3}}]}, LIVE]}, "delay": 3, "do": []},
    {"id": "v_end", "when": {"fired": "v_won"}, "delay": 1, "do": [{"win": "conspiracy"}]},
    {"id": "lost_end", "when": {"all": [NO_VAL, {"any": [{"fired": "risen"}, {"fired": "foundry_lost"}, {"fired": "gold_zero"}]}]}, "delay": 4, "do": [{"lose": "crown"}]},
    # ============================================================ HURTS
    {"id": "tomasz_hurt", "when": {"hp": {"tag": "tomasz", "below": 0.6}}, "every": 60, "times": 2, "do": [{"say": ["t_hurt"]}, {"ping": {"tag": "tomasz"}}]},
] + runner_triggers() + armoury_triggers()

M["counters"]["carts_left"] = {"start": 0}
M["counters"]["taken_left"] = {"start": 0}

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the garrison is bound to C5, the Armoury with the Matchlock and the
# Socket Bayonet; the story's refusals on top (no hall, no workers, no Foundry: a garrison in a town, not a colony)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID, story_deny={"garrison": ["town_hall", "cottage", "farm", "wall", "gate", "labourer", "messenger", "foundry",
                                                     "mortar", "church", "missionary", "powder_mill"]})
for k in ("armoury", "matchlock", "bayonet"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hub after d01 (campaign/campaign.json), the engine's words
for (en, pt, es) in [
    ("Father Tomasz", "Padre Tomasz", "Padre Tomasz"),
    ("Captain Meneses", "Capitão Meneses", "Capitán Meneses"),
    ("Lieutenant Ramos", "Tenente Ramos", "Teniente Ramos"),
    ("A missionary in Brazil since the Council of Rome, sent to the gold country.", "Missionário no Brasil desde o Concílio de Roma, enviado à terra do ouro.",
     "Misionero en Brasil desde el Concilio de Roma, enviado a la tierra del oro."),
    ("Captain Luís de Meneses, of the Governor's dragoons, commanding Vila Rica's garrison.", "Capitão Luís de Meneses, dos dragões do Governador, comandante da guarnição de Vila Rica.",
     "Capitán Luís de Meneses, de los dragones del Gobernador, al mando de la guarnición de Vila Rica."),
    ("Lieutenant Inácio Ramos, the Free Assembly's man in the mines: an orator with a pistol.", "Tenente Inácio Ramos, o homem da Assembleia Livre nas minas: um orador com uma pistola.",
     "Teniente Inácio Ramos, el hombre de la Asamblea Libre en las minas: un orador con una pistola."),
    ("A conspirator of the Free Assembly's cell, with a musket paid for in southern gold.", "Um conspirador da célula da Assembleia Livre, com um mosquete pago em ouro do sul.",
     "Un conspirador de la célula de la Asamblea Libre, con un mosquete pagado con oro del sur."),
    ("One of Varenne's martyrs: he carries the dead orator's face on his sleeve.", "Um dos mártires do Varenne: traz o rosto do orador morto na manga.",
     "Uno de los mártires de Varenne: lleva el rostro del orador muerto en la manga."),
    ("A miner of Vila Rica with a pick, angry at the tax.", "Um mineiro de Vila Rica com uma picareta, zangado com o imposto.", "Un minero de Vila Rica con un pico, enfadado con el impuesto."),
    ("An agitator of the Assembly with a bundle of pamphlets.", "Um agitador da Assembleia com um maço de panfletos.", "Un agitador de la Asamblea con un fajo de panfletos."),
    ("A townsman of Vila Rica.", "Um morador de Vila Rica.", "Un vecino de Vila Rica."),
    ("The militia's field gun, taken by the conspirators from its store.", "O canhão de campanha da milícia, tirado do depósito pelos conspiradores.",
     "El cañón de campaña de la milicia, sacado del almacén por los conspiradores."),
    ("A rider of the mule trains of the mines, gone over to the conspiracy.", "Um cavaleiro das tropas de mulas das minas, passado para a conspiração.",
     "Un jinete de las recuas de mulas de las minas, pasado a la conspiración."),
    # the hub after d01 (the King's study)
    ("Tomasz wrote from Minas: the gold went down to the coast, and he stayed behind with the miners.", "O Tomasz escreveu de Minas: o ouro desceu à costa, e ele ficou com os mineiros.",
     "Tomasz escribió desde Minas: el oro bajó a la costa, y él se quedó con los mineros."),
    ("He sent me the names of the dead of both sides, and asked me to pray for all of them. I did.", "Mandou-me os nomes dos mortos dos dois lados, e pediu-me que rezasse por todos. Rezei.",
     "Me envió los nombres de los muertos de ambos bandos, y me pidió que rezara por todos. Lo hice."),
    ("The lieutenant who led them went south. Remember the city of gears; we will come back to it.", "O tenente que os comandava foi para sul. Lembra-te da cidade das engrenagens; voltaremos a ela.",
     "El teniente que los mandaba se fue al sur. Recuerda la ciudad de los engranajes; volveremos a ella."),
    ("In Minas I learnt that a sermon is the easy part. Staying afterwards is the work.", "Em Minas aprendi que o sermão é a parte fácil. Ficar depois é que é o trabalho.",
     "En Minas aprendí que el sermón es la parte fácil. Quedarse después es el trabajo."),
    ("I still have the list of the dead from that night. I read it every year on the feast of the Rosary.", "Ainda tenho a lista dos mortos daquela noite. Leio-a todos os anos na festa do Rosário.",
     "Todavía tengo la lista de los muertos de aquella noche. La leo cada año en la fiesta del Rosario."),
    # the engine's words (TAKE A CART here)
    ("TAKING THE GOLD", "A LEVAR O OURO", "LLEVÁNDOSE EL ORO"),
    ("GOLD TAKEN!", "OURO LEVADO!", "¡ORO ROBADO!"),
    ("TAKING IT BACK", "A RETOMAR", "RECUPERÁNDOLO"),
    ("TAKEN BACK!", "RETOMADA!", "¡RECUPERADO!"),
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
rows = ["# Act 2's mission d01_minas, \"The Gold of Vila Rica\" (campaign/missions/d01_minas.json, written with its texts by",
        "# tools/campaign/make_d01_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what",
        "# was built: docs/campaign_d01_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: derrama (pt and es keep the",
        "# word); the Armoury = Arsenal / Armería; Matchlock = Mecha; Socket Bayonet = Baioneta de Encaixe / Bayoneta de Cubo;",
        "# AUTO REFIT = AUTO-REEQUIPAR / AUTOEQUIPAR (the game's own words, tools/i18n/02_hud_game.txt, 03_defs.txt).", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
