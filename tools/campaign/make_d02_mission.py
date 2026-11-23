#!/usr/bin/env python3
"""Writes campaign/missions/d02_exodus.json: Act 2's "The Exodus" (the Clockmaker line after the Council of Rome,
Fürth to the Main, February 2771; the plan: docs/campaign_act2_plan.md "d02_exodus"; what was built:
docs/campaign_d02_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d02_exodus.txt: every text here is
written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d02_mission.py && python3 tools/i18n_build.py
The map is a04's Fürth grown again, in the snow (tools/campaign/make_furth_exodus_map.py). EVERY LINE IS A PLACEHOLDER
for the owner to rewrite.

Ten months after Rome. The Crown's commissary rides for Fürth with the Council's verdict: seize the guild's works, stop
every automaton that winds itself. Hollweg will not wait for him. The guild LEAVES THE CROWN: by night, with its families,
its carts and (c01 `gate` pattern) the Perpetual's drawings, down the frozen valley to the barges on the Main.
  THE GUILD (BLUE, p1): Hollweg, Winders, Clock Soldiers (drilled to SHIELD WALL: THE ROSTER LADDER's K4), Springers,
    Netters, a Pendulum. No Clocktower to build: the works are being left. HOLLWEG'S SPRING CART winds every machine on
    the brass plates round it (the portable wind: a gear ground that follows the cart).
  THE FAMILIES (BLUE, scripted): the family carts (3 / 5 / 7 by c01 `saved`), the drawings cart (c01 `gate` pattern),
    the spring cart. They go down the road by themselves once Part 2 begins: the player guards them.
  THE COMMISSARY (PURPLE: solo it is scripted, or the SOLO PICK; versus p2): Commissary Brandt, Colonel von Rauch, his
    musketeers, riders and guns (a02 `furth` strong / thin), Father Ferrer as Rome's witness. Their order is to TAKE,
    not to kill: the carts can't be harmed (Claude's choice), only TAKEN (TAKE A CART: riders round a cart, no guild
    fighter by it, 5 s). Taken carts go to the seized team and drive for the commissary's camp; surrounded by the guild
    for 4 s on the way they are taken back.
  THE MACHINE (RED, scripted): it sees Fürth emptying and sends a sortie into the works, then down the road behind the
    carts; it fights everyone (bigger by a04 `lost_to_machine` 2 or more).
  PART 1, THE NIGHT BELL: load each family cart (a man of the guild STAYS a moment at its barn: the family climbs in),
    Hollweg loads the drawings at his barn, says goodbye to JAKOB (alive: he will not go; he walks to the Crown's camp),
    before the commissary's riders come (a countdown; they come at once when all is done). a02 `furth` fallen: a RECLAIM
    PART first: the machine holds the works; burn its seed before the road can be taken.
  PART 2, THE ROAD: the carts down the valley; the riders come down the Würzburg track to take them; the commissary's
    column and the machine's sortie follow from the works and meet each other on the road. c01 `bells` rung: von Rauch's
    minute (the Crown's men stand for one minute: "Let them go, God help them").
  PART 3, THE BRIDGE: the barges take the carts as they come; the Travelling Clock is set up by the brook (its field
    winds the rearguard) and a Winder builds the RATCHET TURRET at the bridge's foot (K4: the last stand); hold the brook
    bridge until the last barge is loaded, then Hollweg aboard.
  NO CHOICE. CARRIES: `exodus` few / some / many (the families' share; `exodus_n`), `drawings` carried / taken (pattern
    only), `jakob` stayed / lost; a commissary's win: `hollweg` taken (not the King's story: the seal broken).
  MIRROR (THE COMMISSARY, solo pick; versus): take Hollweg alive before the last barge (the carts taken are counted).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d02_exodus"

# ---------------------------------------------------------------- the texts, three languages at once
TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d02_exodus.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
RUNG = past("c01_thirteenth.bells", "rung")
QUIET = {"not": RUNG}
FEW = past("c01_thirteenth.saved", "few")
MANY = past("c01_thirteenth.saved", "many")
PATTERN = notpast("c01_thirteenth.gate", "people")
PEOPLE = past("c01_thirteenth.gate", "people")
THIN = past("a02_furth.furth", "thin")
FALLEN = past("a02_furth.furth", "fallen")
STANDING = {"not": FALLEN}
STRONG = {"all": [{"not": THIN}, STANDING]}
JAKOB = {"all": [notpast("c01_thirteenth.jakob", "lost"), notpast("a02_furth.jakob", "lost"), notpast("a04_visit.jakob", "lost")]}
NO_JAKOB = {"not": JAKOB}
MELTED = past("a04_visit.broken", "melted")
KEPT = {"not": MELTED}
LOST2 = {"any": [past("a04_visit.lost_to_machine", n) for n in range(2, 31)]}
EXO = {"playing": "exodus"}
NO_EXO = {"not": EXO}                      # the guild scripted: the commissary is the solo pick
COM = {"playing": "commissary"}
NO_COM = {"not": COM}
LIVE = {"not": {"any": [{"fired": "the_end"}, {"fired": "c_end"}]}}
IN_MINUTE = {"counter": {"name": "minute", "at_least": 1}}
NOT_MINUTE = {"not": IN_MINUTE}

# ---------------------------------------------------------------- numbers
RIDERS_SECS = 300            # Part 1: the commissary's riders come (NORMAL; EASY x1.25, HARD x0.85)
FALLEN_MORE = 90             # ... more with the reclaim part
LOAD_SECS = 3                # a man at a barn this long loads its cart
DRAW_SECS = 4                # Hollweg at his barn: the drawings
BARGE_SECS = 180             # Part 3: the last barge loaded
CAST_OFF = 60                # ... then it waits this long for Hollweg
MINUTE = 60                  # von Rauch's minute
CART_PACE = 0.6              # the carts on the snow (a share of their walk; 58 x 0.6 = 35: every escort keeps up)
# the commissary's men by a02 `furth`: (musketeers, first riders, second riders, guns)
CROWN = {"strong": (4, 3, 2, 1), "thin": (3, 2, 2, 1)}
SORTIE = (6, 2)              # the machine's sortie: Clock Soldiers, Springers (+3 Clock Soldiers with a04's lost 2+)
GUILD = {"winder": 4, "clock_soldier": 8, "springer": 2, "netter": 2, "pendulum": 1}
GUILD_M = {"winder": 3, "clock_soldier": 5, "springer": 1, "netter": 2, "pendulum": 1}     # (the commissary's mirror: the guild scripted)

# the barns, where each family waits with its things (the 1st is Hollweg's own: the drawings are loaded there too)
BARNS = [[31, 14, 4, 6], [35, 8, 4, 3], [45, 8, 4, 3], [55, 12, 3, 4], [44, 41, 4, 3], [50, 44, 4, 3], [48, 30, 4, 4]]
# the cart of barn i exists: 1-3 always, 4-5 unless few were saved at Nuremberg, 6-7 only with many
CART_IF = [None, None, None, {"not": FEW}, {"not": FEW}, MANY, MANY]
ROAD = ["yard_w", "bridge_w", "v1", "s1", "s2", "s3", "s4", "s5", "s6", "brook_n", "brook_s", "barges"]
CHASE = ["yard", "yard_w", "bridge_w", "v1", "s1", "s2", "s3", "s4", "s5", "s6", "brook_n", "brook_s"]

# the empty works (a04's workshops) and the Honest One: the guild's, or the machine's when Fürth fell (a02 lost)
WORKS = [("movement_works", [35, 11]), ("escapement", [51, 11]), ("cog_press", [35, 19]), ("mainspring", [51, 22]),
         ("cog_press", [40, 24]), ("heavy_works", [45, 24])]


# ================================================================== the mission
units = [
    # ---- the guild (the player): Hollweg and every machine that can walk
    {"team": "guild", "kind": "missionary", "as": "hollweg", "count": 1, "at": [41, 20], "tag": "hollweg", "tags": ["guild_men"]},
] + [
    {"team": "guild", "kind": k, "count": n, "at": "muster", "tag": "army", "tags": ["guild_men"], "fixed": True, "if": EXO}
    for k, n in GUILD.items()
] + [
    {"team": "guild", "kind": k, "count": n, "at": "muster", "tag": "army", "tags": ["guild_men"], "fixed": True, "if": NO_EXO}
    for k, n in GUILD_M.items()
] + [
    # (the mirror's difficulty is the guild's size: +2 Clock Soldiers at NORMAL, +4 at HARD)
    {"team": "guild", "kind": "clock_soldier", "count": 2, "at": "muster", "tag": "army", "tags": ["guild_men"], "fixed": True,
     "if": {"all": [NO_EXO, {"difficulty": ["normal", "hard"]}]}},
    {"team": "guild", "kind": "clock_soldier", "count": 2, "at": "muster", "tag": "army", "tags": ["guild_men"], "fixed": True,
     "if": {"all": [NO_EXO, {"difficulty": "hard"}]}},
] + [
    {"team": "families", "kind": "labourer", "as": "jakob", "count": 1, "at": "jakob_at", "tag": "jakob", "if": JAKOB},
    # ---- the families: the carts at the barns, the drawings cart and the spring cart at Hollweg's
] + [
    dict({"team": "families", "kind": "powder_wagon", "as": "family_cart", "count": 1, "at": "barn_%d" % (i + 1), "tag": "cart_%d" % (i + 1),
          "tags": ["fcarts", "carts", "convoy"], "fixed": True}, **({"if": CART_IF[i]} if CART_IF[i] else {}))
    for i in range(7)
] + [
    {"team": "families", "kind": "powder_wagon", "as": "drawings_cart", "count": 1, "at": [32, 21], "tag": "drawings_cart",
     "tags": ["carts", "convoy"], "fixed": True, "if": PATTERN},
    {"team": "families", "kind": "powder_wagon", "as": "spring_cart", "count": 1, "at": [36, 16], "tag": "spring_cart", "tags": ["convoy"], "fixed": True},
    # ---- (the commissary's own column, when a person leads it, rides in at Part 2: trigger "column_c")
] + [
    # ---- the machine, when Fürth fell (a02 lost): it holds the works (the reclaim part)
    {"team": "machine", "kind": "clock_soldier", "count": 4, "at": "yard", "tag": "m_works_guard", "order": "hold", "if": FALLEN},
    {"team": "machine", "kind": "springer", "count": 1, "at": "yard", "tag": "m_works_guard", "order": "hold", "if": FALLEN},
]

buildings = (
    [{"team": "works", "kind": "clocktower", "at": [44, 16], "tag": "honest", "name": T("The Honest One", "O Honesto", "El Honrado"), "if": STANDING}]
    + [{"team": "works", "kind": k, "at": at, "tag": "works", "if": STANDING} for (k, at) in WORKS]
    + [{"team": "machine", "kind": "clocktower", "at": [44, 16], "tag": "seed_works", "name": T("The machine's seed", "A semente da máquina", "La semilla de la máquina"), "if": FALLEN}]
    + [{"team": "machine", "kind": "regulator", "at": [38, 24], "tag": "m_links", "if": FALLEN}]
    # the machine's ground across the meadows and by Nuremberg's gates (as a04 left it)
    + [{"team": "machine", "kind": "clocktower", "at": "north_gate", "tag": "seed_n"},
       {"team": "machine", "kind": "clocktower", "at": "south_gate", "tag": "seed_s"},
       {"team": "machine", "kind": "clocktower", "at": [78, 43], "tag": "seed_meadow"},
       {"team": "machine", "kind": "regulator", "at": [70, 46], "tag": "m_links"}]
)

areas = dict(
    {"barn_%d" % (i + 1): b for i, b in enumerate(BARNS)},
    town=[36, 2, 14, 6], muster=[37, 14, 6, 5], yard=[32, 11, 23, 17], yard_w=[30, 15, 4, 5], jakob_at=[39, 13, 3, 3], camp=[52, 2, 10, 5],
    column_in=[56, 1, 8, 5], north_gate=[102, 14, 11, 9], south_gate=[102, 44, 11, 9],
    bridge_e=[30, 17, 3, 5], bridge_w=[19, 16, 4, 6], track_n=[13, 0, 4, 3], track_s=[13, 11, 4, 4],
    v1=[10, 17, 4, 4], s1=[18, 23, 3, 3], s2=[8, 29, 3, 3], s3=[18, 35, 3, 3], s4=[8, 41, 3, 3], s5=[18, 46, 3, 3], s6=[18, 51, 3, 2],
    v3=[12, 34, 4, 4], brook_n=[12, 51, 4, 3], brook=[11, 53, 6, 4],
    brook_s=[12, 56, 4, 3], landing=[3, 56, 18, 18], barges=[3, 60, 4, 8], clock_spot=[16, 61, 5, 4], turret_spot=[13, 56, 2, 2],
    valley=[7, 15, 15, 40], road_w=[7, 15, 17, 9], west=[0, 0, 31, 80], bank=[3, 46, 19, 28],
)

TAKE = [
    {"tag": "carts", "by": "commissary", "to": "seized", "secs": 5, "counter": "carts_taken", "as": "taken"},
    {"tag": "taken", "by": "exodus", "to": "families", "secs": 4, "counter": "retaken", "as": "retaken"},
]

objectives = [
    # ---- the guild: part 0 (Fürth fell: the reclaim)
    {"id": "reclaim", "side": "exodus", "primary": True, "kind": "destroy", "tag": "seed_works", "hidden": True,
     "text": T("Fürth fell to the machine: its seed stands in the guild's own works. Burn it before the families can leave.",
               "Fürth caiu para a máquina: a sua semente está nas próprias oficinas da guilda. Queime-a antes que as famílias possam partir.",
               "Fürth cayó ante la máquina: su semilla está en los propios talleres del gremio. Quémala antes de que las familias puedan partir.")},
    # ---- part 1
    {"id": "load", "side": "exodus", "primary": True, "kind": "manual",
     "text": T("Load the family carts: {loaded} of {carts_n}. Move any of your men to a cart at its barn and keep him there a moment: the family climbs in.",
               "Carregue as carroças das famílias: {loaded} de {carts_n}. Leve qualquer um dos seus homens a uma carroça no seu celeiro e mantenha-o lá um momento: a família sobe.",
               "Carga los carros de las familias: {loaded} de {carts_n}. Lleva a cualquiera de tus hombres a un carro en su granero y mantenlo allí un momento: la familia sube."),
     "phone": T("Load the family carts: {loaded} of {carts_n}. A man at each cart's barn a moment.",
                "Carregue as carroças: {loaded} de {carts_n}. Um homem no celeiro de cada uma, um momento.",
                "Carga los carros: {loaded} de {carts_n}. Un hombre en el granero de cada uno, un momento.")},
    {"id": "drawings", "side": "exodus", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Load the drawings: bring Meister Hollweg to his own barn, west of the yard. Only he knows which chests.",
               "Carregue os desenhos: leve o Mestre Hollweg ao seu próprio celeiro, a oeste do pátio. Só ele sabe quais baús.",
               "Carga los planos: lleva al maestro Hollweg a su propio granero, al oeste del patio. Solo él sabe qué baúles.")},
    {"id": "jakob_bye", "side": "exodus", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Jakob is waiting by the yard. Bring Meister Hollweg to him: he has something to say.",
               "Jakob espera junto ao pátio. Leve o Mestre Hollweg até ele: ele tem algo a dizer.",
               "Jakob espera junto al patio. Lleva al maestro Hollweg hasta él: tiene algo que decir.")},
    {"id": "riders_clock", "side": "exodus", "primary": False, "kind": "countdown", "clock": "riders",
     "text": T("The commissary's riders come in {clock:riders}. Whatever is not loaded by then stays behind.",
               "Os cavaleiros do comissário chegam em {clock:riders}. O que não estiver carregado até lá fica para trás.",
               "Los jinetes del comisario llegan en {clock:riders}. Lo que no esté cargado para entonces se queda atrás.")},
    # ---- part 2
    {"id": "road", "side": "exodus", "primary": True, "kind": "manual", "hidden": True,
     "text": T("Get the carts down the valley to the barges on the Main: {families_out} of {carts_n} families out. Keep fighters by every cart: riders who stand round a cart with none of yours by it TAKE it.",
               "Leve as carroças pelo vale até as barcaças no Meno: {families_out} de {carts_n} famílias fora. Mantenha combatentes junto a cada carroça: cavaleiros em volta de uma carroça sem nenhum dos seus ao lado a TOMAM.",
               "Lleva los carros por el valle hasta las barcazas en el Meno: {families_out} de {carts_n} familias fuera. Mantén combatientes junto a cada carro: los jinetes que rodean un carro sin ninguno de los tuyos al lado lo TOMAN."),
     "phone": T("Carts to the barges: {families_out} of {carts_n} out. Keep fighters by every cart.",
                "Carroças às barcaças: {families_out} de {carts_n} fora. Combatentes junto a cada carroça.",
                "Carros a las barcazas: {families_out} de {carts_n} fuera. Combatientes junto a cada carro.")},
    {"id": "hollweg", "side": "exodus", "primary": True, "kind": "protect", "tag": "hollweg",
     "text": T("Meister Hollweg must live. Hurt, he falls back to the carts.", "O Mestre Hollweg tem de viver. Ferido, ele recua para as carroças.",
               "El maestro Hollweg debe vivir. Herido, se retira a los carros.")},
    # ---- part 3
    {"id": "bridge", "side": "exodus", "primary": False, "kind": "countdown", "clock": "last_barge", "hidden": True,
     "text": T("Hold the brook bridge until the last barge is loaded: {clock:last_barge}.", "Segure a ponte do riacho até a última barcaça estar carregada: {clock:last_barge}.",
               "Resiste en el puente del arroyo hasta que la última barcaza esté cargada: {clock:last_barge}.")},
    {"id": "turret", "side": "exodus", "primary": False, "kind": "build", "tag": "turret", "hidden": True,
     "text": T("Build the Ratchet Turret at the bridge's foot: send a Winder to its site.", "Construa a Torreta de Catraca ao pé da ponte: mande um Enrolador ao local.",
               "Construye la Torreta de Trinquete al pie del puente: envía un Dador de cuerda al solar.")},
    {"id": "aboard", "side": "exodus", "primary": True, "kind": "reach", "area": "barges", "tag": "hollweg", "secs": 2, "hidden": True,
     "text": T("The last barge is loaded. Get Meister Hollweg aboard: walk him onto the jetty.", "A última barcaça está carregada. Embarque o Mestre Hollweg: leve-o até o cais.",
               "La última barcaza está cargada. Sube al maestro Hollweg a bordo: llévalo al embarcadero.")},
    {"id": "cast_off", "side": "exodus", "primary": False, "kind": "countdown", "clock": "cast_off", "hidden": True, "fail": True,
     "text": T("The bargemen cast off in {clock:cast_off}.", "Os barqueiros soltam as amarras em {clock:cast_off}.", "Los barqueros sueltan amarras en {clock:cast_off}.")},
    # ---- the commissary (the solo pick, versus)
    {"id": "c_ride", "side": "commissary", "primary": False, "kind": "reach", "area": "valley", "side_units": "commissary", "count": 3, "hidden": True,
     "text": T("After them: over the Rednitz bridge and down the valley. The guild's only road to the Main runs through it.",
               "Atrás deles: sobre a ponte do Rednitz e pelo vale abaixo. A única estrada da guilda para o Meno passa por ele.",
               "Tras ellos: por el puente del Rednitz y valle abajo. El único camino del gremio al Meno pasa por él.")},
    {"id": "c_take", "side": "commissary", "primary": False, "kind": "manual",
     "text": T("Take the carts: {carts_taken} taken. Stand men round a cart with none of the guild's fighters by it. Rome's order is to take, not to kill.",
               "Tome as carroças: {carts_taken} tomadas. Ponha homens em volta de uma carroça sem nenhum combatente da guilda ao lado. A ordem de Roma é tomar, não matar.",
               "Toma los carros: {carts_taken} tomados. Pon hombres alrededor de un carro sin ningún combatiente del gremio al lado. La orden de Roma es tomar, no matar.")},
    {"id": "c_hollweg", "side": "commissary", "primary": True, "kind": "capture", "tag": "hollweg", "by": "commissary", "share": 0.25, "within": 3, "hidden": True,
     "text": T("Take Meister Hollweg alive before the last barge: bring him down and stand a man by him.",
               "Capture o Mestre Hollweg vivo antes da última barcaça: derrube-o e ponha um homem ao lado dele.",
               "Apresa al maestro Hollweg vivo antes de la última barcaza: derríbalo y pon a un hombre a su lado.")},
]

M = {
    "id": MID,
    "title": T("The Exodus", "O Êxodo", "El Éxodo"),
    "summary": T("Fürth, February 2771. The Crown's commissary rides with Rome's verdict. Meister Hollweg does not wait for him: by night the guild leaves the Crown, with its families, down the frozen road to the Main.",
                 "Fürth, fevereiro de 2771. O comissário da Coroa cavalga com o veredito de Roma. O Mestre Hollweg não o espera: de noite a guilda deixa a Coroa, com as suas famílias, pela estrada gelada até o Meno.",
                 "Fürth, febrero de 2771. El comisario de la Corona cabalga con el veredicto de Roma. El maestro Hollweg no lo espera: de noche el gremio deja la Corona, con sus familias, por el camino helado hasta el Meno."),
    "map": "campaign:furth_exodus",
    "voice": "d02",
    "light": "winter_night",
    "weather": "snow",
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["a07_council"],
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {"clocks": 0.9, "spawns": 1.1}},
    "modes": ["solo", "versus"],
    "solo_sides": ["exodus", "commissary"],
    "sides": [
        {"id": "exodus", "name": T("The Exodus", "O Êxodo", "El Éxodo"),
         "about": T("Meister Hollweg's guild and its families, leaving Fürth by night.", "A guilda do Mestre Hollweg e as suas famílias, deixando Fürth de noite.",
                    "El gremio del maestro Hollweg y sus familias, dejando Fürth de noche.")},
        {"id": "commissary", "name": T("The Commissary", "O Comissário", "El Comisario"),
         "about": T("The Crown's commissary with Rome's verdict, Colonel von Rauch's riders and guns, and Father Ferrer as Rome's witness.",
                    "O comissário da Coroa com o veredito de Roma, os cavaleiros e canhões do Coronel von Rauch e o Padre Ferrer como testemunha de Roma.",
                    "El comisario de la Corona con el veredicto de Roma, los jinetes y cañones del coronel von Rauch y el Padre Ferrer como testigo de Roma.")},
        {"id": "machine", "name": T("The Machine", "A Máquina", "La Máquina"),
         "about": T("Nuremberg's masters. Fürth is emptying.", "Os senhores de Nuremberg. Fürth está a esvaziar-se.", "Los amos de Núremberg. Fürth se está vaciando.")},
    ],
    "teams": [
        {"id": "guild", "side": "exodus", "faction": "clockwork", "colour": 0, "start": "none", "camera": "yard_w", "gold": 0,
         "techs": ["shield_wall"], "control": {"solo": "p1", "versus": "p1", "foe": "script"}},
        {"id": "families", "side": "exodus", "faction": "crown", "colour": 0, "start": "none", "camera": "yard_w",
         "control": {"solo": "script", "versus": "script"}},
        # (the works left behind: the guild's buildings, no longer worked: a team of their own, so no Winder goes back to a press)
        {"id": "works", "side": "exodus", "faction": "clockwork", "colour": 0, "start": "none", "camera": "yard",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "crown", "side": "commissary", "faction": "crown", "colour": 4, "start": "none", "camera": "column_in", "gold": 0, "powder": 400,
         "control": {"solo": "script", "versus": "p2"}},
        {"id": "seized", "side": "commissary", "faction": "crown", "colour": 4, "start": "none", "camera": "camp",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "machine", "side": "machine", "faction": "clockwork", "colour": 1, "start": "none", "camera": "north_gate", "gold": 0,
         "control": {"solo": "script", "versus": "script"}},
    ],
    "areas": areas,
    "counters": {"loaded": {"start": 0}, "carts_n": {"start": 0}, "to_load": {"start": 0}, "families_out": {"start": 0},
                 "families_left": {"start": 0}, "drawings_out": {"start": 0}, "carts_taken": {"start": 0}, "retaken": {"start": 0},
                 "carts_gone": {"start": 0}, "minute": {"start": 0}, "automata_out": {"start": 0}},
    "take_carts": TAKE,
    "exits": [
        {"area": "barges", "tag": "fcarts", "cargo": True, "cargo_counter": "families_out", "after": "part3"},
        {"area": "barges", "tag": "drawings_cart", "cargo": True, "cargo_counter": "drawings_out", "after": "part3"},
        {"area": "camp", "tag": "taken", "counter": "carts_gone", "after": "part2"},
    ],
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["hollweg"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "exodus", "portrait": "res://campaign/hub/rome_king_face.png"},
        "hollweg": {"name": T("Meister Hollweg", "Mestre Hollweg", "Maestro Hollweg"), "side": "exodus", "portrait": "res://campaign/hub/nuremberg_hollweg_face.png"},
        "jakob": {"name": T("Jakob", "Jakob", "Jakob"), "side": "exodus"},
        "ulrich": {"name": T("Master Ulrich", "Mestre Ulrich", "Maestro Ulrich"), "side": "exodus"},
        "brandt": {"name": T("Commissary Brandt", "Comissário Brandt", "Comisario Brandt"), "side": "commissary",
                   "portrait": "res://campaign/portraits/commissary.png"},     # (a02's commissary: the same man)
        "rauch": {"name": T("Colonel von Rauch", "Coronel von Rauch", "Coronel von Rauch"), "side": "commissary",
                  "portrait": "res://campaign/portraits/colonel.png"},
        "ferrer": {"name": T("Father Ferrer", "Padre Ferrer", "Padre Ferrer"), "side": "commissary"},
        "narrator": {"name": T("Fürth to the Main", "De Fürth ao Meno", "De Fürth al Meno"), "side": "exodus"},
        "machine": {"name": T("The Machine", "A Máquina", "La Máquina"), "side": "machine"},
    },
    "lines": {},
    "stills": {},
    "next": {"exodus": "", "commissary": ""},
}

L = M["lines"]


def line(lid, who, en, pt, es, to=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    return lid


EX, CO = "exodus", "commissary"
# ---- the opening (the King, then Hollweg; the commissary's: the King, then Ferrer)
line("k_open1", "king", "Ten months after Rome I signed the commissary's orders myself. Seize the works at Fürth. Stop every machine that winds itself.",
     "Dez meses depois de Roma, eu mesmo assinei as ordens do comissário. Tomar as oficinas de Fürth. Parar toda máquina que dá corda a si mesma.",
     "Diez meses después de Roma, yo mismo firmé las órdenes del comisario. Tomar los talleres de Fürth. Parar toda máquina que se dé cuerda a sí misma.")
line("k_open2", "king", "Hollweg was told the commissary was coming. He did not wait for him.",
     "Disseram a Hollweg que o comissário vinha. Ele não o esperou.", "A Hollweg le dijeron que el comisario venía. No lo esperó.")
line("h_open1", "hollweg", "I called it a rescue. The families had nowhere else. The machines had nowhere at all.",
     "Eu chamei aquilo de resgate. As famílias não tinham outro lugar. As máquinas não tinham lugar nenhum.",
     "Yo lo llamé un rescate. Las familias no tenían otro sitio. Las máquinas no tenían ningún sitio.")
line("h_open2", "hollweg", "We rang the night bell at the barn. By morning Fürth was empty.",
     "Tocamos o sino da noite no celeiro. De manhã Fürth estava vazia.", "Tocamos la campana de noche en el granero. Por la mañana Fürth estaba vacía.")
line("k_open_c", "king", "Father Ferrer rode with the commissary as Rome's witness. He wrote down what he saw. He always did.",
     "O Padre Ferrer cavalgou com o comissário como testemunha de Roma. Escreveu o que viu. Sempre escrevia.",
     "El Padre Ferrer cabalgó con el comisario como testigo de Roma. Escribió lo que vio. Siempre lo hacía.")
line("f_open_c", "ferrer", "We were a day's ride off when the dogs found their scent. The guild was already on the road.",
     "Estávamos a um dia de viagem quando os cães encontraram o rasto. A guilda já estava na estrada.",
     "Estábamos a un día de camino cuando los perros encontraron el rastro. El gremio ya estaba en el camino.")
# ---- part 1
line("h_1", "hollweg", "Every family to its cart. Every machine that can walk, wind it. We leave tonight.",
     "Cada família à sua carroça. Toda máquina que possa andar, dê-lhe corda. Partimos esta noite.",
     "Cada familia a su carro. Toda máquina que pueda andar, dadle cuerda. Partimos esta noche.", EX)
line("u_tip1", "ulrich", "The carts wait at the barns, Meister. Send one of ours to each and the family climbs in. The marked ones on the map.",
     "As carroças esperam nos celeiros, Mestre. Mande um dos nossos a cada uma e a família sobe. As marcadas no mapa.",
     "Los carros esperan en los graneros, maestro. Manda a uno de los nuestros a cada uno y la familia sube. Los marcados en el mapa.", EX)
line("u_tip2", "ulrich", "Your spring cart winds anything that stands on the brass plates round it. Keep the soldiers near it on the road and they never run down.",
     "A sua carroça de mola dá corda a tudo o que estiver nas placas de latão à volta dela. Mantenha os soldados perto dela na estrada e eles nunca param.",
     "Tu carro de muelle da cuerda a todo lo que pise las placas de latón a su alrededor. Mantén a los soldados cerca en el camino y nunca se paran.", EX)
line("u_tip_new", "ulrich", "The Clock Soldiers know the shield wall now, Meister. Raise their shields with SHIELD FORWARD on their card when the muskets face them.",
     "Os Soldados-Relógio já conhecem a parede de escudos, Mestre. Erga os escudos com ESCUDO À FRENTE no painel deles quando os mosquetes os encararem.",
     "Los Soldados Reloj ya conocen el muro de escudos, maestro. Alza sus escudos con ESCUDO AL FRENTE en su panel cuando los mosquetes los encaren.", EX)
line("n_loaded", "narrator", "A family climbs into its cart.", "Uma família sobe na sua carroça.", "Una familia sube a su carro.", EX)
line("h_draw0", "hollweg", "And the drawings. Every sheet of the Perpetual. Nobody touches those chests but me.",
     "E os desenhos. Cada folha do Perpétuo. Ninguém toca nesses baús além de mim.", "Y los planos. Cada hoja del Perpetuo. Nadie toca esos baúles sino yo.", EX)
line("h_draw", "hollweg", "The drawings are aboard. If they take that cart, they take everything I ever made.",
     "Os desenhos estão a bordo. Se tomarem essa carroça, tomam tudo o que eu já fiz.", "Los planos están a bordo. Si toman ese carro, toman todo lo que he hecho.", EX)
line("h_people", "hollweg", "No drawings this time. I left them in Nuremberg for the people. I carry the Perpetual in my head.",
     "Sem desenhos desta vez. Deixei-os em Nuremberg pelo povo. Levo o Perpétuo na cabeça.", "Sin planos esta vez. Los dejé en Núremberg por la gente. Llevo el Perpetuo en la cabeza.", EX)
line("j_wait", "jakob", "Meister. Before you go. Come here, please.", "Mestre. Antes de partir. Venha aqui, por favor.", "Maestro. Antes de que te vayas. Ven aquí, por favor.", EX)
line("j_stay1", "jakob", "I am not coming, Meister. I told Father Ferrer what I found, and I will tell the commissary.",
     "Eu não vou, Mestre. Contei ao Padre Ferrer o que encontrei, e vou contar ao comissário.",
     "No voy, maestro. Le conté al Padre Ferrer lo que encontré, y se lo contaré al comisario.", EX)
line("h_stay", "hollweg", "They will melt everything, Jakob. Everything we built.", "Eles vão derreter tudo, Jakob. Tudo o que construímos.",
     "Lo fundirán todo, Jakob. Todo lo que construimos.", EX)
line("j_stay2", "jakob", "Then let them. I would rather melt a wheel than see it take out its own stop-work again. God keep you, Meister.",
     "Então que derretam. Prefiro derreter uma roda a vê-la tirar a sua própria trava outra vez. Deus o guarde, Mestre.",
     "Pues que lo fundan. Prefiero fundir una rueda a verla quitarse su propio tope otra vez. Dios te guarde, maestro.", EX)
line("n_jakob_goes", "narrator", "Jakob walks up the street to the Crown's camp, and does not look back.",
     "Jakob sobe a rua até o acampamento da Coroa, e não olha para trás.", "Jakob sube la calle hacia el campamento de la Corona, y no mira atrás.", EX)
line("h_nojakob", "hollweg", "Jakob would have known which wheels to leave. Jakob is not here.",
     "Jakob saberia que rodas deixar. Jakob não está aqui.", "Jakob habría sabido qué ruedas dejar. Jakob no está aquí.", EX)
line("u_warn", "ulrich", "Riders on the Bamberg road, Meister. Not long now.", "Cavaleiros na estrada de Bamberg, Mestre. Falta pouco.",
     "Jinetes en el camino de Bamberg, maestro. Queda poco.", EX)
line("n_left", "narrator", "The carts nobody loaded stay at their barns. Those families stay in Fürth.",
     "As carroças que ninguém carregou ficam nos celeiros. Essas famílias ficam em Fürth.",
     "Los carros que nadie cargó se quedan en sus graneros. Esas familias se quedan en Fürth.", EX)
# the reclaim (Fürth fell)
line("h_fallen", "hollweg", "The machine sits in my own works. My own tower. Burn its seed, or no cart leaves this yard.",
     "A máquina está nas minhas próprias oficinas. Na minha própria torre. Queimem a sua semente, ou nenhuma carroça sai deste pátio.",
     "La máquina está en mis propios talleres. En mi propia torre. Quemad su semilla, o ningún carro sale de este patio.", EX)
line("h_reclaimed", "hollweg", "It is down. Now the families. Quickly.", "Caiu. Agora as famílias. Depressa.", "Ha caído. Ahora las familias. Deprisa.", EX)
# ---- part 2
line("u_dogs", "ulrich", "Dogs, Meister! They are early! The carts must go now!", "Cães, Mestre! Chegaram cedo! As carroças têm de partir agora!",
     "¡Perros, maestro! ¡Llegan pronto! ¡Los carros tienen que salir ya!", EX)
line("h_road", "hollweg", "West over the Rednitz, then down the valley to the Main. Keep a fighter by every cart.",
     "Para oeste sobre o Rednitz, depois pelo vale até o Meno. Mantenham um combatente junto a cada carroça.",
     "Al oeste sobre el Rednitz, luego por el valle hasta el Meno. Mantened un combatiente junto a cada carro.", EX)
line("u_take", "ulrich", "They will not shoot the carts, Meister. They will stand round one until it is theirs. Drive them off it and the bar empties.",
     "Eles não vão atirar nas carroças, Mestre. Vão ficar à volta de uma até ela ser deles. Afaste-os e a barra esvazia.",
     "No dispararán a los carros, maestro. Rodearán uno hasta que sea suyo. Échalos y la barra se vacía.", EX)
line("u_riders", "ulrich", "Riders in the valley! They came round by the Würzburg track, from the north!",
     "Cavaleiros no vale! Vieram pelo caminho de Würzburg, do norte!", "¡Jinetes en el valle! ¡Vinieron por la senda de Wurzburgo, desde el norte!", EX)
line("u_dogs2", "ulrich", "Dogs on the slope, Meister, and riders behind them! They have our scent!", "Cães na encosta, Mestre, e cavaleiros atrás deles! Têm o nosso rasto!",
     "¡Perros en la ladera, maestro, y jinetes detrás! ¡Tienen nuestro rastro!", EX)
line("u_riders2", "ulrich", "More riders on the track!", "Mais cavaleiros no caminho!", "¡Más jinetes en la senda!", EX)
line("u_column", "ulrich", "The commissary's column is in the yard behind us. Musketeers, and guns.",
     "A coluna do comissário está no pátio atrás de nós. Mosqueteiros, e canhões.", "La columna del comisario está en el patio detrás de nosotros. Mosqueteros, y cañones.", EX)
line("u_column_m", "ulrich", "The commissary's column is in the yard behind us. Musketeers, and more nets than guns.",
     "A coluna do comissário está no pátio atrás de nós. Mosqueteiros, e mais redes que canhões.", "La columna del comisario está en el patio detrás de nosotros. Mosqueteros, y más redes que cañones.", EX)
line("n_sortie", "narrator", "In the empty works, red lights. The machine has come out of Nuremberg for what we left.",
     "Nas oficinas vazias, luzes vermelhas. A máquina saiu de Nuremberg pelo que deixámos.",
     "En los talleres vacíos, luces rojas. La máquina ha salido de Núremberg por lo que dejamos.")
line("h_sortie", "hollweg", "Let it have the walls. It will meet the commissary before it meets us.",
     "Que fique com as paredes. Vai encontrar o comissário antes de nos encontrar.", "Que se quede con las paredes. Se encontrará con el comisario antes que con nosotros.", EX)
line("n_taken", "narrator", "A cart is taken. Its family goes back to Fürth under the Crown's guard.",
     "Uma carroça foi tomada. A sua família volta para Fürth sob guarda da Coroa.", "Un carro ha sido tomado. Su familia vuelve a Fürth bajo guardia de la Corona.")
line("u_retake", "ulrich", "Get round that cart before it reaches their camp and it is ours again!",
     "Cerquem aquela carroça antes que chegue ao acampamento deles e ela volta a ser nossa!", "¡Rodead ese carro antes de que llegue a su campamento y vuelve a ser nuestro!", EX)
line("n_retaken", "narrator", "The cart is the guild's again, and turns back for the Main.",
     "A carroça é da guilda outra vez, e volta-se para o Meno.", "El carro vuelve a ser del gremio, y regresa hacia el Meno.")
line("h_draw_taken", "hollweg", "The drawings! They have the drawings!", "Os desenhos! Eles têm os desenhos!", "¡Los planos! ¡Tienen los planos!", EX)
# von Rauch's minute (c01 `bells` rung)
line("r_minute", "rauch", "Halt. All of you. Let them go, God help them. One minute.",
     "Alto. Todos. Deixem-nos ir, Deus os ajude. Um minuto.", "Alto. Todos. Dejadlos ir, que Dios los ayude. Un minuto.")
line("b_minute", "brandt", "Colonel! You have the Crown's orders!", "Coronel! Tem as ordens da Coroa!", "¡Coronel! ¡Tiene las órdenes de la Corona!")
line("h_minute", "hollweg", "Von Rauch remembered the bells of Nuremberg. Go, now, while he looks away!",
     "Von Rauch lembrou-se dos sinos de Nuremberg. Vão, agora, enquanto ele olha para o outro lado!",
     "Von Rauch recordó las campanas de Núremberg. ¡Id, ahora, mientras mira hacia otro lado!", EX)
line("r_minute_end", "rauch", "The minute is up. After them.", "O minuto acabou. Atrás deles.", "Se acabó el minuto. Tras ellos.")
# ---- part 3
line("n_landing", "narrator", "The Main at last: the barges at the jetty, the bargemen stamping their feet in the snow.",
     "O Meno, enfim: as barcaças no cais, os barqueiros batendo os pés na neve.", "El Meno, por fin: las barcazas en el embarcadero, los barqueros pateando la nieve.")
line("u_clock", "ulrich", "We set up the travelling clock by the brook, Meister. Its field winds anything near it. Five of the journeymen came over on the first barge: they are yours. There is a turret in the crates.",
     "Montámos o relógio de viagem junto ao riacho, Mestre. O seu campo dá corda a tudo o que estiver perto. Cinco dos oficiais vieram na primeira barcaça: são seus. Há uma torreta nos caixotes.",
     "Montamos el reloj de viaje junto al arroyo, maestro. Su campo da cuerda a todo lo que esté cerca. Cinco de los oficiales vinieron en la primera barcaza: son suyos. Hay una torreta en las cajas.", EX)
line("h_bridge", "hollweg", "Hold the bridge until the last barge is loaded. The shields in front, the turret behind them.",
     "Segurem a ponte até a última barcaça estar carregada. Os escudos à frente, a torreta atrás deles.",
     "Resistid en el puente hasta que la última barcaza esté cargada. Los escudos delante, la torreta detrás.", EX)
line("u_turret", "ulrich", "Send a Winder to the turret's site at the bridge's foot. It builds it with the guild's last coins.",
     "Mande um Enrolador ao local da torreta ao pé da ponte. Ele a constrói com as últimas moedas da guilda.",
     "Envía un Dador de cuerda al solar de la torreta al pie del puente. La construye con las últimas monedas del gremio.", EX)
line("n_barge", "narrator", "A barge pushes off down the Main.", "Uma barcaça afasta-se pelo Meno abaixo.", "Una barcaza se aleja Meno abajo.")
line("u_broken", "ulrich", "The rearguard is gone, Meister! They are on the landing: get to the barges before they lay hands on you!",
     "A retaguarda caiu, Mestre! Estão no cais: vá para as barcaças antes que lhe ponham as mãos!", "¡La retaguardia ha caído, maestro! ¡Están en el embarcadero: ve a las barcazas antes de que te echen mano!", EX)
line("n_quiet", "narrator", "The bank is quiet. The bargemen hurry the last crates aboard.", "A margem está calma. Os barqueiros apressam os últimos caixotes a bordo.",
     "La orilla está tranquila. Los barqueros apresuran las últimas cajas a bordo.")
line("u_last", "ulrich", "The last barge is loaded, Meister! Come aboard, now!", "A última barcaça está carregada, Mestre! Embarque, agora!",
     "¡La última barcaza está cargada, maestro! ¡Sube a bordo, ya!", EX)
line("h_aboard", "hollweg", "Cast off. Do not look back. There is nothing behind us now but the Crown.",
     "Soltem as amarras. Não olhem para trás. Já não há nada atrás de nós senão a Coroa.",
     "Soltad amarras. No miréis atrás. Ya no hay nada detrás de nosotros sino la Corona.", EX)
line("n_cast_off", "narrator", "The bargemen could wait no longer. The last barge left without the Meister.",
     "Os barqueiros não podiam esperar mais. A última barcaça partiu sem o Mestre.", "Los barqueros no podían esperar más. La última barcaza partió sin el maestro.")
line("n_all_taken", "narrator", "Every cart was taken on the road. There was nothing left to save.",
     "Todas as carroças foram tomadas na estrada. Não sobrou nada para salvar.", "Todos los carros fueron tomados en el camino. No quedó nada que salvar.")
line("h_hurt", "hollweg", "I am hit. Keep them off me, they want me alive.", "Fui atingido. Afastem-nos de mim, querem-me vivo.", "Me han dado. Apartadlos de mí, me quieren vivo.", EX)
line("n_captured", "narrator", "The commissary's men close round Meister Hollweg. He is taken alive.",
     "Os homens do comissário cercam o Mestre Hollweg. Ele é capturado vivo.", "Los hombres del comisario rodean al maestro Hollweg. Lo apresan vivo.")
# ---- the commissary's own (solo pick / versus)
line("b_c1", "brandt", "By the Council of Rome and the King's seal: the works at Fürth are the Crown's. Ride.",
     "Pelo Concílio de Roma e pelo selo do Rei: as oficinas de Fürth são da Coroa. Cavalguem.",
     "Por el Concilio de Roma y el sello del Rey: los talleres de Fürth son de la Corona. Cabalgad.", CO)
line("f_c1", "ferrer", "Take the carts, Commissary. Do not harm the families. And I want Hollweg alive, to answer.",
     "Tome as carroças, Comissário. Não faça mal às famílias. E quero Hollweg vivo, para responder.",
     "Tome los carros, comisario. No dañe a las familias. Y quiero a Hollweg vivo, para responder.", CO)
line("r_c_tip", "rauch", "My riders take a cart by standing round it with none of theirs by it. Bring Hollweg down and stand a man by him: he is taken.",
     "Os meus cavaleiros tomam uma carroça ficando à volta dela sem nenhum dos deles ao lado. Derrubem Hollweg e ponham um homem ao lado dele: está capturado.",
     "Mis jinetes toman un carro rodeándolo sin ninguno de los suyos al lado. Derribad a Hollweg y poned a un hombre a su lado: queda apresado.", CO)
line("f_c_road", "ferrer", "They are on the road west. The barges on the Main will not wait for us.",
     "Estão na estrada para oeste. As barcaças no Meno não vão esperar por nós.", "Están en el camino del oeste. Las barcazas del Meno no nos esperarán.", CO)
line("r_c_sortie", "rauch", "The machine is in the works behind us. Watch the rear.", "A máquina está nas oficinas atrás de nós. Cuidado com a retaguarda.",
     "La máquina está en los talleres detrás de nosotros. Cuidado con la retaguardia.", CO)
line("r_c_push", "rauch", "The reserve is on the track, Commissary. Three more muskets and a rider.", "A reserva está no caminho, Comissário. Mais três mosquetes e um cavaleiro.",
     "La reserva está en la senda, comisario. Tres mosquetes más y un jinete.", CO)
line("f_c_won", "ferrer", "He is taken. God forgive us both, Meister.", "Está capturado. Que Deus nos perdoe a ambos, Mestre.", "Está apresado. Que Dios nos perdone a los dos, maestro.", CO)
line("f_c_lost", "ferrer", "The last barge is gone down the Main. He is beyond the Crown now.",
     "A última barcaça desceu o Meno. Ele está fora do alcance da Coroa agora.", "La última barcaza bajó por el Meno. Ya está fuera del alcance de la Corona.", CO)
# ---- the machine (no voice)
line("m_1", "machine", "Tick. Tock. The works are empty.", "Tique. Taque. As oficinas estão vazias.", "Tic. Tac. Los talleres están vacíos.", "machine")
# ---- the ending
line("h_end1", "hollweg", "We went down the Main to the sea, and at Hamburg we took ship. Nobody there asked what was in the crates.",
     "Descemos o Meno até o mar, e em Hamburgo embarcámos. Lá ninguém perguntou o que havia nos caixotes.",
     "Bajamos el Meno hasta el mar, y en Hamburgo embarcamos. Allí nadie preguntó qué había en las cajas.")
line("h_end_many", "hollweg", "Nearly every family came with us. I counted them on the deck, every morning.",
     "Quase todas as famílias vieram connosco. Eu contava-as no convés, todas as manhãs.", "Casi todas las familias vinieron con nosotros. Las contaba en la cubierta, cada mañana.")
line("h_end_some", "hollweg", "Some of the families came. The others went back to Fürth in the Crown's carts.",
     "Algumas famílias vieram. As outras voltaram a Fürth nas carroças da Coroa.", "Algunas familias vinieron. Las otras volvieron a Fürth en los carros de la Corona.")
line("h_end_few", "hollweg", "Few of the families came. The deck was very quiet.", "Poucas famílias vieram. O convés estava muito silencioso.",
     "Pocas familias vinieron. La cubierta estaba muy callada.")
line("h_end_draw", "hollweg", "And the drawings came with me. Every sheet.", "E os desenhos vieram comigo. Cada folha.", "Y los planos vinieron conmigo. Cada hoja.")
line("h_end_drawlost", "hollweg", "The drawings stayed with the Crown. I drew them again from memory, on the ship.",
     "Os desenhos ficaram com a Coroa. Desenhei-os outra vez de memória, no navio.", "Los planos se quedaron con la Corona. Los dibujé otra vez de memoria, en el barco.")
line("h_end_jakob", "hollweg", "Jakob stayed. I wrote to him from Hamburg. He never answered.",
     "Jakob ficou. Escrevi-lhe de Hamburgo. Ele nunca respondeu.", "Jakob se quedó. Le escribí desde Hamburgo. Nunca contestó.")
line("h_end_manifest", "hollweg", "The ship's manifest said: machinery, for a mine in the southern highlands of Brazil. That was true. It was my mine.",
     "O manifesto do navio dizia: maquinaria, para uma mina nas terras altas do sul do Brasil. Era verdade. Era a minha mina.",
     "El manifiesto del barco decía: maquinaria, para una mina en las tierras altas del sur de Brasil. Era verdad. Era mi mina.")
line("k_end1", "king", "He calls it a rescue. I call it what it was. The guild left the Crown that night, and took its families with it.",
     "Ele chama-lhe resgate. Eu chamo-lhe o que foi. A guilda deixou a Coroa naquela noite, e levou as suas famílias consigo.",
     "Él lo llama un rescate. Yo lo llamo lo que fue. El gremio dejó la Corona aquella noche, y se llevó a sus familias.")
line("k_end2", "king", "I do not blame the families. I blame the man who told them the Crown would melt their children's bread.",
     "Não culpo as famílias. Culpo o homem que lhes disse que a Coroa derreteria o pão dos filhos delas.",
     "No culpo a las familias. Culpo al hombre que les dijo que la Corona fundiría el pan de sus hijos.")
line("k_end_c", "king", "Hollweg in the Crown's custody, twenty-four years before he came to my fire. That is not how it went.",
     "Hollweg sob custódia da Coroa, vinte e quatro anos antes de vir para a minha lareira. Não foi assim que aconteceu.",
     "Hollweg bajo custodia de la Corona, veinticuatro años antes de venir a mi fuego. No fue así como ocurrió.")
line("f_end_c", "ferrer", "We brought him to Rome in irons, and the carts back to Fürth. The commissary called it a success.",
     "Levámo-lo para Roma acorrentado, e as carroças de volta a Fürth. O comissário chamou-lhe um sucesso.",
     "Lo llevamos a Roma con grilletes, y los carros de vuelta a Fürth. El comisario lo llamó un éxito.")

# ---- stills
M["stills"] = {
    "night_bell": {"image": STILL % "d02_01", "caption": T("Fürth, February 2771. The night bell: the guild loads its carts.", "Fürth, fevereiro de 2771. O sino da noite: a guilda carrega as suas carroças.",
                                                           "Fürth, febrero de 2771. La campana de noche: el gremio carga sus carros.")},
    "jakob": {"image": STILL % "d02_02", "caption": T("Jakob stays.", "Jakob fica.", "Jakob se queda.")},
    "road": {"image": STILL % "d02_03", "caption": T("The road down the frozen valley.", "A estrada pelo vale gelado.", "El camino por el valle helado.")},
    "ships": {"image": STILL % "d02_04", "caption": T("Hamburg: the ships to Brazil.", "Hamburgo: os navios para o Brasil.", "Hamburgo: los barcos a Brasil.")},
    "rome": {"image": STILL % "c01_01", "caption": T("Rome, the present. The King listens; the clockmaker tells it.", "Roma, o presente. O Rei ouve; o relojoeiro conta.",
                                                    "Roma, el presente. El Rey escucha; el relojero lo cuenta.")},
}
M["opening"] = {
    "exodus": [{"still": "rome", "lines": ["k_open1", "k_open2"]}, {"still": "night_bell", "lines": ["h_open1", "h_open2"]}],
    "commissary": [{"still": "rome", "lines": ["k_open_c"]}, {"still": "road", "lines": ["f_open_c"]}],
}
M["ending"] = {
    "exodus": [
        {"still": "ships", "lines": ["h_end1", {"id": "h_end_many", "if": {"flag": {"exodus": "many"}}}, {"id": "h_end_some", "if": {"flag": {"exodus": "some"}}},
                                     {"id": "h_end_few", "if": {"flag": {"exodus": "few"}}}, {"id": "h_end_draw", "if": {"flag": {"drawings": "carried"}}},
                                     {"id": "h_end_drawlost", "if": {"flag": {"drawings": "taken"}}}, {"id": "h_end_jakob", "if": {"flag": {"jakob": "stayed"}}},
                                     "h_end_manifest"]},
        {"still": "rome", "lines": ["k_end1", "k_end2"]},
    ],
    "commissary": [{"still": "road", "lines": ["f_end_c"]}, {"still": "rome", "lines": ["k_end_c"]}],
}
M["briefing"] = {
    "exodus": {"still": "night_bell", "text": [
        T("Fürth, February 2771, night. The Crown's commissary is coming with Rome's verdict: seize the works, stop the machines. Meister Hollweg leaves first.",
          "Fürth, fevereiro de 2771, noite. O comissário da Coroa vem com o veredito de Roma: tomar as oficinas, parar as máquinas. O Mestre Hollweg parte primeiro.",
          "Fürth, febrero de 2771, de noche. El comisario de la Corona viene con el veredicto de Roma: tomar los talleres, parar las máquinas. El maestro Hollweg se va antes."),
        T("Load the family carts at their barns, then guard them down the valley to the barges on the Main. Riders take any cart with none of your fighters by it.",
          "Carregue as carroças das famílias nos celeiros e escolte-as pelo vale até as barcaças no Meno. Os cavaleiros tomam qualquer carroça sem nenhum dos seus combatentes ao lado.",
          "Carga los carros de las familias en sus graneros y escóltalos por el valle hasta las barcazas del Meno. Los jinetes toman cualquier carro sin ninguno de tus combatientes al lado."),
        T("Meister Hollweg must reach the last barge. The commissary wants him alive.",
          "O Mestre Hollweg tem de chegar à última barcaça. O comissário o quer vivo.", "El maestro Hollweg debe llegar a la última barcaza. El comisario lo quiere vivo.")]},
    "commissary": {"still": "road", "text": [
        T("Fürth, February 2771. You are the Crown's commissary, with Colonel von Rauch's men and Father Ferrer as Rome's witness.",
          "Fürth, fevereiro de 2771. Você é o comissário da Coroa, com os homens do Coronel von Rauch e o Padre Ferrer como testemunha de Roma.",
          "Fürth, febrero de 2771. Eres el comisario de la Corona, con los hombres del coronel von Rauch y el Padre Ferrer como testigo de Roma."),
        T("The guild is fleeing for the Main. Take its carts, and take Meister Hollweg alive before the last barge leaves. The machine is behind you.",
          "A guilda foge para o Meno. Tome as suas carroças, e capture o Mestre Hollweg vivo antes que a última barcaça parta. A máquina está atrás de você.",
          "El gremio huye hacia el Meno. Toma sus carros, y apresa al maestro Hollweg vivo antes de que parta la última barcaza. La máquina está detrás de ti.")]},
}
M["debrief"] = {
    "exodus": {"still": "ships", "title": T("The Exodus", "O Êxodo", "El Éxodo"),
               "text": T("The guild left Fürth. {families_out} of {carts_n} families reached the barges; {carts_taken} carts were taken on the road.",
                         "A guilda deixou Fürth. {families_out} de {carts_n} famílias chegaram às barcaças; {carts_taken} carroças foram tomadas na estrada.",
                         "El gremio dejó Fürth. {families_out} de {carts_n} familias llegaron a las barcazas; {carts_taken} carros fueron tomados en el camino."),
               "text_if": [
                   {"if": {"flag": {"drawings": "carried"}}, "text": T("The drawings went with Hollweg.", "Os desenhos foram com Hollweg.", "Los planos se fueron con Hollweg.")},
                   {"if": {"flag": {"drawings": "taken"}}, "text": T("The drawings were taken by the Crown.", "Os desenhos foram tomados pela Coroa.", "Los planos fueron tomados por la Corona.")},
                   {"if": {"flag": {"jakob": "stayed"}}, "text": T("Jakob stayed with the Crown.", "Jakob ficou com a Coroa.", "Jakob se quedó con la Corona.")},
                   {"if": {"counter": {"name": "families_left", "at_least": 1}}, "text": T("{families_left} families were never loaded.", "{families_left} famílias nunca foram carregadas.", "{families_left} familias nunca fueron cargadas.")}]},
    "commissary": {"still": "road", "title": T("Taken alive", "Capturado vivo", "Apresado vivo"),
                   "text": T("Meister Hollweg is in the Crown's custody. {carts_taken} carts were taken on the road.",
                             "O Mestre Hollweg está sob custódia da Coroa. {carts_taken} carroças foram tomadas na estrada.",
                             "El maestro Hollweg está bajo custodia de la Corona. {carts_taken} carros fueron tomados en el camino.")},
}

# ================================================================== the triggers
def crown_wave(tag, kinds, at, extra_if=None, scale=True):
    """The commissary's men (scripted: the player plays the guild) by a02's `furth`: one spawn per strength."""
    out = []
    for s in ("strong", "thin"):
        cond = [NO_COM, STRONG if s == "strong" else THIN] + ([extra_if] if extra_if else [])
        for (k, n) in kinds(s):
            if n > 0:
                out.append({"spawn": {"team": "crown", "kind": k, "count": n, "at": at, "tag": tag, "tags": ["crown_men"] + (["riders"] if k == "cuirassier" else []),
                                      "if": {"all": cond}}})
    return out


TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"spare": {"tag": "carts", "on": True}}, {"spare": {"tag": "spring_cart", "on": True}}, {"spare": {"tag": "jakob", "on": True}},
        {"spare": {"tag": "ferrer", "on": True}}, {"spare": {"tag": "seed_n", "on": True}}, {"spare": {"tag": "seed_s", "on": True}},
        {"spare": {"tag": "seed_meadow", "on": True}},
        {"counter": {"name": "carts_n", "count": {"tag": "fcarts"}}}, {"counter": {"name": "to_load", "count": {"tag": "carts"}}},
        {"pace": {"tag": "convoy", "pace": CART_PACE}},
        {"ground": {"name": "spring", "from": "spring_cart", "kind": "gear", "team": "guild", "r": 4, "max": 4, "wind": 0.06}},
        {"wind": {"tag": "army", "share": 0.7}},
        {"deny": {"team": "guild", "kind": ["clocktower", "cog_press", "mainspring", "movement_works", "escapement", "heavy_works",
                                             "winder", "clock_soldier", "springer", "netter", "pendulum"],
                  "why": T("The works are being left: nothing more is built or made in Fürth.", "As oficinas estão a ser deixadas: nada mais se constrói nem se faz em Fürth.",
                           "Los talleres se están abandonando: nada más se construye ni se fabrica en Fürth.")}}]},
    {"id": "riders_clock_go", "when": {"all": [{"time": 1}, STANDING]}, "do": [{"clock": {"name": "riders", "secs": RIDERS_SECS}}]},
    {"id": "riders_clock_fallen", "when": {"all": [{"time": 1}, FALLEN]}, "do": [{"clock": {"name": "riders", "secs": RIDERS_SECS + FALLEN_MORE}}]},
    {"id": "intro", "when": {"all": [{"time": 1.5}, EXO]}, "do": [{"say": ["h_1", "u_tip1"]}] + [{"ping": {"area": "barn_%d" % (i + 1)}} for i in range(3)]},
    {"id": "intro_spring", "when": {"fired": "intro"}, "delay": 18, "do": [{"say": ["u_tip2"]}, {"ping": {"tag": "spring_cart"}}]},
    {"id": "intro_shield", "when": {"fired": "intro"}, "delay": 40, "do": [{"say": ["u_tip_new"]}]},
    {"id": "intro_c", "when": {"all": [{"time": 1.5}, COM]}, "do": [{"say": ["b_c1", "f_c1", "r_c_tip"]}, {"ping": {"area": "yard"}}]},
    # (Hollweg can be TAKEN only by a person leading the commissary: the scripted Crown has no man for it)
    {"id": "capture_on", "when": {"all": [{"fired": "part2"}, COM]}, "do": [{"objective": {"id": "c_hollweg", "set": "active"}}]},
    {"id": "machine_1", "when": {"time": 4}, "do": [{"say": ["m_1"]}]},
    # the reclaim part (Fürth fell to the machine at a02)
    {"id": "reclaim_go", "when": {"all": [{"time": 1}, FALLEN]}, "do": [
        {"objective": {"id": "reclaim", "set": "active"}}, {"ping": {"tag": "seed_works"}}]},
    {"id": "reclaim_say", "when": {"all": [{"time": 2}, FALLEN, EXO]}, "do": [{"say": ["h_fallen"]}]},
    {"id": "reclaimed", "when": {"all": [{"done": "reclaim"}, EXO]}, "do": [{"say": ["h_reclaimed"]}]},
    {"id": "reclaim_c", "when": {"all": [{"time": 60}, FALLEN, NO_EXO, {"not": {"done": "reclaim"}}]}, "do": [
        {"hurt": {"tag": "seed_works", "amount": 99999}}]},
    # ============================================================ PART 1: THE NIGHT BELL
]
for i in range(7):
    n = i + 1
    TR_ += [
        {"id": "load_%d" % n, "when": {"all": [{"stay": {"team": "guild", "area": "barn_%d" % n, "secs": LOAD_SECS}},
                                               {"count": {"tag": "cart_%d" % n, "at_least": 1}}, {"not": {"fired": "part2"}}, LIVE]}, "do": [
            {"load": {"cart": "cart_%d" % n, "cargo": "families", "amount": 1}},
            {"counter": {"name": "loaded", "add": 1}}, {"counter": {"name": "to_load", "add": -1}}, {"say": ["n_loaded"]}]},
        # (the guild scripted: the commissary is the solo pick; the families load themselves, one every few seconds)
        {"id": "autoload_%d" % n, "when": {"all": [{"time": 4 + 3 * n}, NO_EXO, {"count": {"tag": "cart_%d" % n, "at_least": 1}}, {"not": {"fired": "load_%d" % n}}]}, "do": [
            {"load": {"cart": "cart_%d" % n, "cargo": "families", "amount": 1}},
            {"counter": {"name": "loaded", "add": 1}}, {"counter": {"name": "to_load", "add": -1}}]},
        # not loaded when the riders came: that family stays
        {"id": "left_%d" % n, "when": {"all": [{"fired": "part2"}, {"not": {"fired": "load_%d" % n}}, {"not": {"fired": "autoload_%d" % n}},
                                               {"count": {"tag": "cart_%d" % n, "at_least": 1}}]}, "do": [
            {"remove": {"tag": "cart_%d" % n}}, {"counter": {"name": "families_left", "add": 1}}, {"counter": {"name": "carts_n", "add": -1}}]},
    ]
TR_ += [
    {"id": "load_done", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "loaded", "at_least": 1}}]}, "delay": 1, "do": [{"objective": {"id": "load", "set": "done"}}]},
    {"id": "load_none", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "loaded", "below": 1}}]}, "delay": 1, "do": [
        {"say": ["n_all_taken"]}, {"objective": {"id": "load", "set": "failed"}}]},
    # the drawings (c01 `gate` pattern): Hollweg at his own barn
    {"id": "draw_obj", "when": {"all": [{"time": 2}, PATTERN, EXO, {"not": {"fired": "draw_load"}}]}, "delay": 20, "do": [
        {"objective": {"id": "drawings", "set": "active"}}, {"say": ["h_draw0"]}, {"ping": {"area": "barn_1"}}]},
    {"id": "people_line", "when": {"all": [{"time": 2}, PEOPLE, EXO]}, "delay": 25, "do": [{"say": ["h_people"]}]},
    {"id": "draw_load", "when": {"all": [PATTERN, {"stay": {"tag": "hollweg", "area": "barn_1", "secs": DRAW_SECS}}, {"not": {"fired": "part2"}}, LIVE]}, "do": [
        {"load": {"cart": "drawings_cart", "cargo": "drawings", "amount": 1}}, {"counter": {"name": "to_load", "add": -1}},
        {"objective": {"id": "drawings", "set": "done"}}, {"say": ["h_draw"]}]},
    {"id": "draw_auto", "when": {"all": [{"time": 25}, PATTERN, NO_EXO, {"not": {"fired": "draw_load"}}]}, "do": [
        {"load": {"cart": "drawings_cart", "cargo": "drawings", "amount": 1}}, {"counter": {"name": "to_load", "add": -1}}]},
    {"id": "draw_left", "when": {"all": [{"fired": "part2"}, PATTERN, {"not": {"fired": "draw_load"}}, {"not": {"fired": "draw_auto"}}]}, "do": [
        {"remove": {"tag": "drawings_cart"}}, {"objective": {"id": "drawings", "set": "failed"}}, {"flag": {"drawings": "taken"}}]},
    # JAKOB (alive): he will not go
    {"id": "jakob_obj", "when": {"all": [{"time": 2}, JAKOB, EXO]}, "delay": 50, "do": [
        {"objective": {"id": "jakob_bye", "set": "active"}}, {"say": ["j_wait"]}, {"ping": {"tag": "jakob"}}]},
    {"id": "jakob_talk", "when": {"all": [JAKOB, {"any": [{"all": [{"fired": "jakob_obj"}, {"near": {"tag": "hollweg", "to": "jakob", "within": 2}}]},
                                                       {"all": [NO_EXO, {"time": 30}]}]}, LIVE]}, "do": [
        {"say": ["j_stay1", "h_stay", "j_stay2", "n_jakob_goes"]}, {"objective": {"id": "jakob_bye", "set": "done"}},
        {"order": {"tag": "jakob", "do": "route", "route": ["town", "camp"], "name": "jakob_walk"}}, {"flag": {"jakob": "stayed"}}]},
    {"id": "jakob_gone", "when": {"route_done": "jakob_walk"}, "do": [{"remove": {"tag": "jakob"}}]},
    {"id": "jakob_late", "when": {"all": [{"fired": "part2"}, JAKOB, {"not": {"fired": "jakob_talk"}}]}, "do": [
        {"order": {"tag": "jakob", "do": "route", "route": ["town", "camp"], "name": "jakob_walk"}}, {"flag": {"jakob": "stayed"}}]},
    {"id": "nojakob", "when": {"all": [{"time": 2}, NO_JAKOB, EXO]}, "delay": 50, "do": [{"say": ["h_nojakob"]}, {"flag": {"jakob": "lost"}}]},
    {"id": "nojakob_flag", "when": {"all": [{"time": 2}, NO_JAKOB]}, "do": [{"flag": {"jakob": "lost"}}]},
    {"id": "riders_warn", "when": {"all": [{"clock_left": {"name": "riders", "below": 60}}, {"not": {"fired": "part2"}}, EXO]}, "do": [{"say": ["u_warn"]}]},
    # Part 2 begins: everything loaded (and Jakob's word said), or the riders' time is up. Fürth fallen: the seed first.
    {"id": "ready", "when": {"all": [{"time": 5}, {"counter": {"name": "to_load", "below": 1}}, {"any": [NO_JAKOB, {"fired": "jakob_talk"}]},
                                     {"any": [STANDING, {"done": "reclaim"}]}, {"not": {"fired": "part2"}}, LIVE]}, "do": []},
    {"id": "part2", "when": {"all": [{"any": [{"fired": "ready"}, {"clock_out": "riders"},
                                              {"all": [COM, {"time": 30}]}]},
                                     {"any": [STANDING, {"done": "reclaim"}, {"clock_out": "riders"}]}, LIVE]}, "delay": 3, "do": [
        {"clock": {"name": "riders", "stop": True}}, {"objective": {"id": "riders_clock", "set": "hidden"}},
        {"objective": {"id": "reclaim", "set": "hidden"}},
        {"objective": {"id": "road", "set": "active"}}, {"objective": {"id": "drawings", "set": "hidden"}}, {"objective": {"id": "jakob_bye", "set": "hidden"}}, {"light": {"to": "dawn", "secs": 90}},
        {"order": {"tag": "convoy", "do": "route", "route": ROAD, "name": "road"}}, {"ping": {"area": "bridge_w"}}]},
    {"id": "part2_say", "when": {"all": [{"fired": "part2"}, EXO]}, "do": [{"say": ["u_dogs", "h_road", "u_take"]}]},
    {"id": "part2_left", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "families_left", "at_least": 1}}, EXO]}, "delay": 2, "do": [{"say": ["n_left"]}]},
    {"id": "part2_c", "when": {"all": [{"fired": "part2"}, COM]}, "do": [{"say": ["f_c_road"]}, {"ping": {"area": "bridge_w"}},
        {"objective": {"id": "c_ride", "set": "active"}}]},
    # (the guild scripted: its men keep with the carts and fight what comes near them; Hollweg with the spring cart)
    {"id": "g_escort", "when": {"all": [{"fired": "part2"}, NO_EXO]}, "do": [
        {"order": {"tag": "army", "do": "follow", "leader": "fcarts", "within": 3, "fight": 6}},
        {"order": {"tag": "hollweg", "do": "follow", "leader": "spring_cart", "within": 2}}]},
    # ============================================================ PART 2: THE ROAD
    # the commissary's column (scripted) from its camp into the empty works, then down the road after the carts
    {"id": "column", "when": {"all": [{"fired": "part2"}, NO_COM]}, "delay": 12, "do":
        [{"spawn": {"team": "crown", "kind": "dismounted", "as": "brandt", "count": 1, "at": "camp", "tag": "brandt", "tags": ["column", "crown_men"]}},
         {"spawn": {"team": "crown", "kind": "cuirassier", "as": "rauch", "count": 1, "at": "camp", "tag": "rauch", "tags": ["column", "crown_men"]}},
         {"spawn": {"team": "crown", "kind": "missionary", "as": "ferrer", "count": 1, "at": "camp", "tag": "ferrer"}},
         {"spare": {"tag": "ferrer", "on": True}}]
        + crown_wave("column", lambda s: [("musketeer", CROWN[s][0])], "camp")
        + crown_wave("column", lambda s: [("cannon", CROWN[s][3])], "camp", KEPT)
        + [{"order": {"tag": "column", "do": "route", "route": ["yard"], "attack": True, "name": "column_yard"}},
           {"order": {"tag": "ferrer", "do": "follow", "leader": "brandt", "within": 3}}]},
    # (the commissary seizes the works first, as his orders say: the machine's sortie finds him there)
    {"id": "column_on", "when": {"all": [{"fired": "column"}, {"any": [{"route_done": "column_yard"}, {"dead": "column"}]}, NOT_MINUTE, LIVE]}, "delay": 25, "do": [
        {"order": {"tag": "column", "only_team": "crown", "do": "route", "route": CHASE[1:], "attack": True, "name": "column_road"}}]},
    # the commissary's column when a person leads it (the solo pick, versus p2): in at the camp as the carts set out
    {"id": "column_c", "when": {"all": [{"fired": "part2"}, COM]}, "do":
        [{"spawn": {"team": "crown", "kind": "dismounted", "as": "brandt", "count": 1, "at": "camp", "tag": "brandt", "tags": ["column"]}},
         {"spawn": {"team": "crown", "kind": "cuirassier", "as": "rauch", "count": 1, "at": "camp", "tag": "rauch", "tags": ["column"]}},
         {"spawn": {"team": "crown", "kind": "missionary", "as": "ferrer", "count": 1, "at": "camp", "tag": "ferrer"}},
         {"spare": {"tag": "ferrer", "on": True}}, {"camera": {"area": "camp", "side": "commissary"}}]
        + [{"spawn": {"team": "crown", "kind": k, "count": CROWN[s_][j], "at": "camp", "tag": "column", "tags": ["c_start"] + (["riders"] if k == "cuirassier" else []),
                      "fixed": True, "if": STRONG if s_ == "strong" else THIN}}
           for s_ in ("strong", "thin") for j, k in ((0, "musketeer"), (1, "cuirassier"), (3, "cannon"))]},
    {"id": "column_say", "when": {"all": [{"fired": "column"}, EXO, KEPT]}, "delay": 20, "do": [{"say": ["u_column"]}, {"ping": {"area": "yard"}}]},
    {"id": "column_say_m", "when": {"all": [{"fired": "column"}, EXO, MELTED]}, "delay": 20, "do": [{"say": ["u_column_m"]}, {"ping": {"area": "yard"}}]},
    # the riders down the Würzburg track (melted at a04: fewer guns, more nets: two riders more)
    {"id": "riders1", "when": {"all": [{"fired": "part2"}, NO_COM]}, "delay": 10, "do":
        crown_wave("riders", lambda s: [("cuirassier", CROWN[s][1])], "track_n")
        + [{"spawn": {"team": "crown", "kind": "cuirassier", "count": 2, "at": "track_n", "tag": "riders", "tags": ["crown_men"], "if": {"all": [NO_COM, MELTED]}}}]},
    {"id": "riders1_say", "when": {"all": [{"fired": "riders1"}, EXO]}, "do": [{"say": ["u_riders"]}, {"ping": {"area": "track_s"}}]},
    {"id": "riders2", "when": {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}, {"any": [{"count": {"tag": "convoy", "area": "s2", "at_least": 1}},
                                                                                         {"fired": "riders2_late"}]}]}, "do":
        crown_wave("riders", lambda s: [("cuirassier", CROWN[s][2])], "track_n")
        + [{"spawn": {"team": "crown", "kind": "cuirassier", "count": 2, "at": "track_n", "tag": "riders", "tags": ["crown_men"], "if": COM}}]},
    {"id": "riders2_late", "when": {"fired": "part2"}, "delay": 70, "do": []},
    {"id": "riders2_say", "when": {"all": [{"fired": "riders2"}, EXO]}, "do": [{"say": ["u_riders2"]}, {"ping": {"area": "track_s"}}]},
    # THE DOGS: the last riders, set on the carts' scent where the road turns for the brook
    {"id": "riders3_late", "when": {"fired": "part2"}, "delay": 120, "do": []},
    {"id": "riders3", "when": {"all": [{"fired": "part2"}, NO_COM, {"not": {"fired": "part3"}}, {"any": [{"count": {"tag": "convoy", "area": "s4", "at_least": 1}},
                                                                                                  {"fired": "riders3_late"}]}]}, "do":
        crown_wave("riders", lambda s: [("cuirassier", 2)], "track_n")},
    {"id": "riders3_say", "when": {"all": [{"fired": "riders3"}, EXO]}, "do": [{"say": ["u_dogs2"]}, {"ping": {"area": "s4"}}]},
    # the scripted riders ride for the nearest cart and stand round it (TAKE A CART does the rest)
    {"id": "riders_take", "when": {"all": [{"fired": "riders1"}, NO_COM, NOT_MINUTE, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "riders", "only_team": "crown", "do": "take", "carts": "carts", "within": 70, "else": "brook_n"}}]},
    # taken carts drive for the commissary's camp; taken back by the guild, they turn for the Main
    {"id": "taken_go", "when": {"all": [{"taken": "carts"}, LIVE]}, "every": 3, "do": [
        {"order": {"tag": "taken", "only_team": "seized", "do": "move", "to": "camp"}},
        {"order": {"tag": "taken", "only_team": "families", "do": "move", "to": "barges"}}]},
    {"id": "taken_say", "when": {"all": [{"taken": "carts"}, EXO]}, "do": [{"say": ["n_taken", "u_retake"]}]},
    {"id": "retaken_say", "when": {"all": [{"counter": {"name": "retaken", "at_least": 1}}, EXO]}, "do": [{"say": ["n_retaken"]}]},
    {"id": "draw_taken", "when": {"all": [PATTERN, {"taken": "drawings_cart"}]}, "do": [{"say": ["h_draw_taken"]}, {"ping": {"tag": "drawings_cart"}}]},
    # the machine's sortie into the empty works, then down the road (it fights everyone it meets)
    {"id": "sortie", "when": {"fired": "part2"}, "delay": 5, "do": [
        {"spawn": {"team": "machine", "kind": "clock_soldier", "count": SORTIE[0], "at": "north_gate", "tag": "sortie"}},
        {"spawn": {"team": "machine", "kind": "springer", "count": SORTIE[1], "at": "north_gate", "tag": "sortie"}},
        {"spawn": {"team": "machine", "kind": "clock_soldier", "count": 3, "at": "north_gate", "tag": "sortie", "if": LOST2}},
        {"order": {"tag": "sortie", "do": "route", "route": CHASE, "attack": True, "name": "sortie_road"}},
        {"say": ["n_sortie"]}, {"ping": {"area": "yard"}}]},
    {"id": "sortie_say", "when": {"all": [{"fired": "sortie"}, EXO]}, "delay": 4, "do": [{"say": ["h_sortie"]}]},
    {"id": "sortie_c", "when": {"all": [{"fired": "sortie"}, COM]}, "delay": 4, "do": [{"say": ["r_c_sortie"]}]},
    # (the machine's men keep wound while they march: its ground is far behind them)
    {"id": "sortie_wound", "when": {"all": [{"fired": "sortie"}, LIVE]}, "every": 5, "do": [{"wind": {"tag": "sortie", "share": 1.0}}, {"wind": {"tag": "m_works_guard", "share": 1.0}}]},
    # VON RAUCH'S MINUTE (c01 `bells` rung: the Crown trusted the guild once)
    {"id": "minute", "when": {"all": [{"fired": "column"}, RUNG, NO_COM, LIVE]}, "delay": 30, "do": [
        {"counter": {"name": "minute", "set": 1}}, {"clock": {"name": "minute", "secs": MINUTE}},
        {"order": {"team": "crown", "do": "hold"}}, {"say": ["r_minute", "b_minute"]}]},
    {"id": "minute_say", "when": {"all": [{"fired": "minute"}, EXO]}, "delay": 1, "do": [{"say": ["h_minute"]}]},
    {"id": "minute_end", "when": {"all": [{"fired": "minute"}, {"clock_out": "minute"}]}, "do": [
        {"counter": {"name": "minute", "set": 0}}, {"say": ["r_minute_end"]},
        {"order": {"tag": "column", "only_team": "crown", "do": "route", "route": CHASE[1:], "attack": True, "name": "column_road"}}]},
    # every cart taken (or none left on the road) before one reached the barges: the exodus failed
    {"id": "all_taken", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "loaded", "at_least": 1}}, {"loaded": {"tag": "fcarts", "cargo": "families", "below": 1}},
                                         {"counter": {"name": "families_out", "below": 1}}, LIVE]}, "delay": 2, "do": []},
    # ============================================================ PART 3: THE BRIDGE
    {"id": "part3", "when": {"all": [{"fired": "part2"}, {"any": [{"count": {"tag": "convoy", "area": "landing", "at_least": 1}}, {"route_done": "road"}]}, LIVE]}, "do": [
        {"build": {"team": "guild", "kind": "clocktower", "at": [16, 61], "tag": "travelling_clock",
                   "name": T("The travelling clock", "O relógio de viagem", "El reloj de viaje")}},
        # (Ulrich's journeymen, gone ahead with the first barge, hold the landing: the player's rearguard is never only
        # what survived the valley)
        {"spawn": {"team": "guild", "kind": "clock_soldier", "count": 4, "at": "clock_spot", "tag": "army", "if": EXO}},
        {"spawn": {"team": "guild", "kind": "netter", "count": 1, "at": "clock_spot", "tag": "army", "if": EXO}},
        {"objective": {"id": "bridge", "set": "active"}}, {"clock": {"name": "last_barge", "secs": BARGE_SECS}},
        {"light": {"to": "winter_day", "secs": 40}}, {"ping": {"area": "brook"}}]},
    {"id": "part3_say", "when": {"all": [{"fired": "part3"}, EXO]}, "do": [{"say": ["n_landing", "u_clock", "h_bridge"]}]},
    # the turret: a site the player's Winders build (K4), or put up by the guild's script
    {"id": "turret_site", "when": {"all": [{"fired": "part3"}, EXO]}, "do": [
        {"build": {"team": "guild", "kind": "ratchet_turret", "at": [13, 57], "tag": "turret", "site": True}},
        {"give": {"team": "guild", "gold": 200}}, {"objective": {"id": "turret", "set": "active"}}]},
    {"id": "turret_say", "when": {"fired": "turret_site"}, "delay": 12, "do": [{"say": ["u_turret"]}, {"ping": {"tag": "turret"}}]},
    {"id": "turret_auto", "when": {"all": [{"fired": "part3"}, NO_EXO]}, "do": [
        {"build": {"team": "guild", "kind": "ratchet_turret", "at": [13, 57], "tag": "turret"}},
        {"order": {"tag": "army", "do": "attack", "to": "brook_s"}}]},
    {"id": "barge_away", "when": {"all": [{"fired": "part3"}, {"counter": {"name": "families_out", "at_least": 1}}, EXO]}, "do": [{"say": ["n_barge"]}]},
    # the commissary's last push at the brook (scripted)
    {"id": "push", "when": {"all": [{"fired": "part3"}, NO_COM]}, "delay": 30, "do":
        crown_wave("push", lambda s: [("musketeer", 2), ("cuirassier", 1)], "track_s")
        + [{"order": {"tag": "push", "do": "route", "route": ["s4", "s5", "s6", "brook_n", "brook_s"], "attack": True, "name": "push"}}]},
    {"id": "push_riders", "when": {"all": [{"fired": "part3"}, NO_COM, NOT_MINUTE, LIVE]}, "every": 4, "do": [
        {"order": {"tag": "column", "only_team": "crown", "kind": ["cuirassier"], "do": "take", "carts": "carts", "within": 40}}]},
    # the last barge loaded: Hollweg aboard (the guild scripted: he walks there himself)
    # (the scripted Crown never stands about on the far bank: every so often whatever is left of it goes for the bridge)
    {"id": "assault", "when": {"all": [{"fired": "part3"}, NO_COM, NOT_MINUTE, LIVE]}, "delay": 20, "every": 12, "do": [
        {"order": {"team": "crown", "kind": ["musketeer", "cuirassier", "cannon", "dismounted"], "do": "attack", "to": "barges", "idle": True}}]},
    {"id": "assault_m", "when": {"all": [{"fired": "part3"}, LIVE]}, "delay": 30, "every": 12, "do": [
        {"order": {"tag": "sortie", "do": "attack", "to": "barges", "idle": True}}]},
    # (the commissary's player: his reserve comes down the track to the brook when the barges start loading)
    {"id": "push_c", "when": {"all": [{"fired": "part3"}, COM]}, "delay": 20, "do": [
        {"spawn": {"team": "crown", "kind": "musketeer", "count": 3, "at": "track_s", "tag": "column"}},
        {"spawn": {"team": "crown", "kind": "cuirassier", "count": 1, "at": "track_s", "tag": "column", "tags": ["riders"]}},
        {"say": ["r_c_push"]}, {"ping": {"area": "track_s"}}]},
    # (NO WAITING: the bank quiet, every enemy beaten or gone, the bargemen load the last barge quickly)
    {"id": "quiet", "when": {"all": [{"fired": "part3"}, {"any": [{"fired": "push"}, {"fired": "push_c"}]}, {"not": {"fired": "last_call"}},
        {"count": {"team": "crown", "area": "bank", "kind": ["musketeer", "cuirassier", "cannon", "dismounted"], "below": 1}},
        {"count": {"side": "machine", "area": "bank", "below": 1}}, LIVE]}, "every": 3, "do": [{"clock": {"name": "last_barge", "add": -12}}]},
    {"id": "quiet_say", "when": {"all": [{"fired": "quiet"}, EXO]}, "do": [{"say": ["n_quiet"]}]},
    # THE REARGUARD BROKEN: the guild has no fighter left at the landing and the commissary's men are on it: they will
    # take Hollweg alive (solo with the guild; the commissary's player may take him any time)
    {"id": "rearguard_gone", "when": {"all": [{"fired": "part3"}, NO_COM,
        {"count": {"team": "guild", "area": "landing", "kind": ["clock_soldier", "springer", "netter", "pendulum"], "below": 1}},
        {"stay": {"side": "commissary", "area": "landing", "secs": 8, "count": 3}}, LIVE]}, "do": [
        {"objective": {"id": "c_hollweg", "set": "active"}}, {"say": ["u_broken"]}, {"ping": {"tag": "hollweg"}}]},
    {"id": "last_call", "when": {"all": [{"fired": "part3"}, {"clock_out": "last_barge"}, LIVE]}, "do": [
        {"objective": {"id": "bridge", "set": "done"}}, {"objective": {"id": "aboard", "set": "active"}},
        {"objective": {"id": "cast_off", "set": "active"}}, {"clock": {"name": "cast_off", "secs": CAST_OFF}}, {"ping": {"area": "barges"}}]},
    {"id": "last_say", "when": {"all": [{"fired": "last_call"}, EXO]}, "do": [{"say": ["u_last"]}]},
    {"id": "last_g", "when": {"all": [{"fired": "last_call"}, NO_EXO]}, "do": [{"order": {"tag": "hollweg", "do": "move", "to": "barges"}}]},
    # ============================================================ THE ENDS
    {"id": "aboard_won", "when": {"all": [{"done": "aboard"}, LIVE, {"not": {"captured": "hollweg"}}]}, "do": [
        {"say": ["h_aboard"]}, {"objective": {"id": "road", "set": "done"}}, {"objective": {"id": "cast_off", "set": "hidden"}}, {"counter": {"name": "automata_out", "count": {"team": "guild", "area": "landing"}}}]},
    {"id": "aboard_c", "when": {"all": [{"fired": "aboard_won"}, COM]}, "do": [{"say": ["f_c_lost"]}]},
    {"id": "flags_exodus", "when": {"fired": "aboard_won"}, "do": [
        {"tally": {"flag": "exodus", "counter": "families_out", "of": "carts_n", "bands": [[0, "few"], [0.4, "some"], [0.75, "many"]]}}]},
    {"id": "flags_draw", "when": {"all": [{"fired": "aboard_won"}, PATTERN, {"counter": {"name": "drawings_out", "at_least": 1}}]}, "do": [{"flag": {"drawings": "carried"}}]},
    {"id": "flags_draw2", "when": {"all": [{"fired": "aboard_won"}, PATTERN, {"counter": {"name": "drawings_out", "below": 1}}]}, "do": [{"flag": {"drawings": "taken"}}]},
    {"id": "won", "when": {"fired": "flags_exodus"}, "delay": 4, "do": [{"light": {"to": "winter_day", "secs": 5}}]},
    {"id": "the_end", "when": {"fired": "won"}, "delay": 1, "do": [{"win": "exodus"}]},
    # the commissary takes Hollweg alive (the solo pick's win; solo with the guild it is the guild's defeat)
    {"id": "hollweg_taken", "when": {"all": [{"captured": "hollweg"}, LIVE]}, "do": [
        {"say": ["n_captured"]}, {"flag": {"hollweg": "taken"}},
        {"tally": {"flag": "exodus", "counter": "families_out", "of": "carts_n", "bands": [[0, "few"], [0.4, "some"], [0.75, "many"]]}}]},
    {"id": "hollweg_taken_c", "when": {"all": [{"fired": "hollweg_taken"}, COM]}, "do": [{"say": ["f_c_won"]}]},
    {"id": "c_end", "when": {"fired": "hollweg_taken"}, "delay": 4, "do": [{"win": "commissary"}]},
    # the bargemen cast off without him, or every cart taken: the exodus failed
    {"id": "cast_off_lost", "when": {"all": [{"clock_out": "cast_off"}, {"not": {"done": "aboard"}}, LIVE]}, "do": [
        {"say": ["n_cast_off"]}, {"objective": {"id": "aboard", "set": "failed"}}]},
    {"id": "all_taken_lost", "when": {"all": [{"fired": "all_taken"}, LIVE]}, "do": [
        {"say": ["n_all_taken"]}, {"objective": {"id": "road", "set": "failed"}}]},
    # the commissary's objectives tick
    {"id": "c_take_done", "when": {"all": [{"counter": {"name": "carts_taken", "at_least": 2}}]}, "do": [{"objective": {"id": "c_take", "set": "done"}}]},
    # ============================================================ HURTS
    {"id": "hollweg_hurt", "when": {"all": [{"hp": {"tag": "hollweg", "below": 0.6}}, EXO]}, "every": 60, "times": 2, "do": [{"say": ["h_hurt"]}, {"ping": {"tag": "hollweg"}}]},
]
# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the guild is bound to K4, the Ratchet Turret and the Shield Wall
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID)
for k in ("ratchet_turret", "shield_wall"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hubs after d02 (campaign/campaign.json, campaign/hubs_grow.json), the
# war map (campaign/warmap.json)
for (en, pt, es) in [
    ("The spring cart", "A carroça de mola", "El carro de muelle"),
    ("The drawings cart", "A carroça dos desenhos", "El carro de los planos"),
    ("Hollweg's travelling spring on a cart: every machine of the guild on the brass plates round it is wound.",
     "A mola de viagem de Hollweg numa carroça: toda máquina da guilda nas placas de latão à volta dela ganha corda.",
     "El muelle de viaje de Hollweg en un carro: toda máquina del gremio sobre las placas de latón a su alrededor recibe cuerda."),
    ("Iron-bound chests: Hollweg's drawings of the Perpetual, every sheet.", "Baús com ferragens: os desenhos do Perpétuo de Hollweg, cada folha.",
     "Baúles con herrajes: los planos del Perpetuo de Hollweg, cada hoja."),
    ("The Crown's commissary from the chancery, with Rome's verdict in his satchel.", "O comissário da Coroa, da chancelaria, com o veredito de Roma na sacola.",
     "El comisario de la Corona, de la cancillería, con el veredicto de Roma en la cartera."),
    ("Colonel of the Crown's Franconian army, who held the Fürth line beside the guild.", "Coronel do exército franconiano da Coroa, que segurou a linha de Fürth ao lado da guilda.",
     "Coronel del ejército franconio de la Corona, que sostuvo la línea de Fürth junto al gremio."),
    ("We are on the river. The bargemen sing at night, and the families sleep among the crates.",
     "Estamos no rio. Os barqueiros cantam à noite, e as famílias dormem entre os caixotes.", "Estamos en el río. Los barqueros cantan de noche, y las familias duermen entre las cajas."),
    ("At Hamburg we take ship. Nobody there will ask what a clock is for.", "Em Hamburgo embarcamos. Lá ninguém vai perguntar para que serve um relógio.",
     "En Hamburgo embarcamos. Allí nadie preguntará para qué sirve un reloj."),
    ("The commissary has me. He reads Rome's verdict to me every morning, as if I had not heard it.",
     "O comissário tem-me. Lê-me o veredito de Roma todas as manhãs, como se eu não o tivesse ouvido.",
     "El comisario me tiene. Me lee el veredicto de Roma cada mañana, como si no lo hubiera oído."),
    ("(The King: That is not how it went. Hollweg went down the Main, and I let him.)", "(O Rei: Não foi assim que aconteceu. Hollweg desceu o Meno, e eu deixei.)",
     "(El Rey: No fue así como ocurrió. Hollweg bajó por el Meno, y yo lo dejé.)"),
    ("The travelling clock rides in a barge's hold, wrapped in sacking. It still keeps Nuremberg's time.",
     "O relógio de viagem vai no porão de uma barcaça, embrulhado em serapilheira. Ainda marca a hora de Nuremberg.",
     "El reloj de viaje va en la bodega de una barcaza, envuelto en arpillera. Todavía marca la hora de Núremberg."),
    ("The trestle stayed in Fürth. The commissary's men will have found it by now.", "O cavalete ficou em Fürth. Os homens do comissário já o devem ter encontrado.",
     "El caballete se quedó en Fürth. Los hombres del comisario ya lo habrán encontrado."),
    ("Forty years a Winder in Franconia, and now a barge on the Main. My lads wind the soldiers in the hold, in turns, all night.",
     "Quarenta anos Enrolador na Francónia, e agora uma barcaça no Meno. Os meus rapazes dão corda aos soldados no porão, por turnos, a noite toda.",
     "Cuarenta años Dador de cuerda en Franconia, y ahora una barcaza en el Meno. Mis muchachos dan cuerda a los soldados en la bodega, por turnos, toda la noche."),
    ("Spend the marks on the bench while we sail. Whatever we fit now comes with us.", "Gaste as marcas na bancada enquanto navegamos. O que montarmos agora vem connosco.",
     "Gasta las marcas en el banco mientras navegamos. Lo que montemos ahora viene con nosotros."),
    ("The Main", "O Meno", "El Meno"),
    ("February 2771", "Fevereiro de 2771", "Febrero de 2771"),
    ("The guild's ships, to Brazil", "Os navios da guilda, para o Brasil", "Los barcos del gremio, a Brasil"),
    ("The guild left Fürth by night and went down the Main to the sea: it has left the Crown.",
     "A guilda deixou Fürth de noite e desceu o Meno até o mar: deixou a Coroa.", "El gremio dejó Fürth de noche y bajó por el Meno hasta el mar: ha dejado la Corona."),
    ("Families who left Fürth with the guild: %s.", "Famílias que deixaram Fürth com a guilda: %s.", "Familias que dejaron Fürth con el gremio: %s."),
    ("Hollweg carried the Perpetual's drawings away.", "Hollweg levou consigo os desenhos do Perpétuo.", "Hollweg se llevó los planos del Perpetuo."),
    ("The Perpetual's drawings are in the Crown's hands.", "Os desenhos do Perpétuo estão nas mãos da Coroa.", "Los planos del Perpetuo están en manos de la Corona."),
    ("Jakob stayed at Fürth with the Crown.", "Jakob ficou em Fürth com a Coroa.", "Jakob se quedó en Fürth con la Corona."),
    ("Hollweg taken alive on the road to the Main: not how it went.", "Hollweg capturado vivo na estrada para o Meno: não foi assim que aconteceu.",
     "Hollweg apresado vivo en el camino al Meno: no fue así como ocurrió."),
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
rows = ["# Act 2's mission d02_exodus, \"The Exodus\" (campaign/missions/d02_exodus.json, written with its texts by",
        "# tools/campaign/make_d02_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what was",
        "# built: docs/campaign_d02_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names as a02 / a04: Winder = Enrolador / Dador de",
        "# cuerda; Meister = Mestre / maestro; the Perpetual = o Perpétuo / el Perpetuo; the Main = o Meno / el Meno.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
