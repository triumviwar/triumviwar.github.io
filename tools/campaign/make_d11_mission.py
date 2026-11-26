#!/usr/bin/env python3
"""Writes campaign/missions/d11_siege.json: Act 2's "The Siege of Concórdia" (the southern highlands, 2780; the crossing's
branch against the machines: FRESH when d09 `first` = clockwork (the city fought first), GROWN when the swarm was fought
first; Father Ferrer tells it in his report to Rome, the King frames it; the plan: docs/campaign_act2_plan.md "d11_siege";
what was built: docs/campaign_d11_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d11_siege.txt: every text
here is written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d11_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_concordia_siege_map.py (campaign:concordia_siege: d07's city with its wall, and the plateau's
edge where the Crown camps). EVERY LINE IS A PLACEHOLDER for the owner to rewrite.

WORLD LORE: Hollweg is DECEIVED, not wicked; the machines are not people (nobody gives them a will: the city "runs"); the
Crown and the Church are the good side, Ferrer a priest who writes only what he saw. LOCAL PEOPLE ARE MINOR: Captain Arruda
and the valley's militia have a line or two; Matthias (Jakob's son) one.
  THE SOUTHERN COLUMN (Crown, PURPLE, p1): FATHER FERRER (Rome's witness, a hero), JAKOB (alive by the earlier missions:
    he hears the city's ticking; NOT protected: he can fall here), GENERAL RUGGIERI (a hero) and his siege train (Field
    Cannons, Mortars, a powder wagon), Musketeers and Guardsmen, Cuirassiers, the PIONEERS (Labourers who dig); the
    camp's depot (Barracks, Armoury, Foundry, Horse Breeder) and THE SIEGE PARK's magazine (it must stand). NEW (C9):
    PREPARED CHARGES and the GUNNER'S QUADRANT at the camp's Armoury. With d07 `spring` stopped HOLLWEG comes with the
    column, a prisoner who asked to come (a hero); with running he stands on his wall (seen, not met).
  THE VALLEY (Crown, BLUE: co-op p2, else scripted at the south battery): Captain Arruda and the valley's militia (d04
    `colonists` fought: they march gladly, many; parley: a few).
  THE HONEST MASTERS (Clockwork, BLUE, scripted; only with d07 `spring` stopped): Matthias and a few machines; the
    POSTERN by their old quarter is theirs (it opens for the Crown, not for the city).
  THE CITY (Clockwork, RED: solo pick and versus p2, else scripted sorties): its wall (timber on rock; its gates, its
    unfinished stretches), the arsenal in the old Nuremberg quarter, THE GREAT SPRING in its tower on the mine hill; NEW on
    its side (K7, bound): the SPRING BALLISTA and LONG CHAIN.
  PART 1, THE LINES: the pioneers dig the earthworks of three batteries, one before each gate (palisade sites); Jakob marks
    the weak gates (a04 `stopworks` found + Jakob alive: two at the start; else Ferrer reads the log: one, in Part 2);
    small sorties at the diggers; GROWN: owls over the camp.
  PART 2, THE SORTIES: night, then dawn: three sorties at the batteries (owls and chains, Clock Soldiers, the heaviest);
    prepared charges against the plates; a gate may be knocked down.
  PART 3, FRESH: THE MINE: the pioneers go down the old galleries under the wall and blow the great spring's tower from
    beneath (SAPPING); hold the mine's mouth meanwhile. The city crippled, not taken: `siege` close.
  PART 3, GROWN: THE GREAT SORTIE: the galleries are the city's; its diggers come up in the camp; hold the camp and the
    park until dusk: `siege` held_off.
  CARRIES: `siege` close / held_off, `jakob` alive / lost.
  MIRROR (THE CITY, solo pick) / VERSUS (p2): break the siege: blow the siege park's magazine or bring down Father Ferrer.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d11_siege"

sys.path.insert(0, HERE)
import make_concordia_siege_map as smap   # noqa: E402

CITY = smap.build()
LOT = CITY.lots

TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d11_siege.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


# ---------------------------------------------------------------- the flags read (missing = the canon)
JAKOB_LOST = {"any": [past("c01_thirteenth.jakob", "lost"), past("a02_furth.jakob", "lost"), past("a04_visit.jakob", "lost")]}
JAKOB_ALIVE = {"not": JAKOB_LOST}
LOGGED = past("a04_visit.stopworks", "logged")              # a04: the stop-works only in Jakob's old log
FOUND = {"all": [{"not": LOGGED}, JAKOB_ALIVE]}             # a04 canon (found) and Jakob alive: he knows two weak gates
READ_LOG = {"not": FOUND}                                   # else Ferrer reads the log: one gate, in Part 2
SPRING_STOPPED = past("d07_spring.spring", "stopped")       # d07: the honest masters came out; the city smaller
SPRING_RUNNING = {"not": SPRING_STOPPED}                    # d07 canon: Hollweg stays on his wall
HONEST_MANY = past("d07_spring.honest", "many")
FOUGHT = past("d04_concordia.colonists", "fought")          # d04: the valley fought the city: it marches gladly
PARLEY = {"not": FOUGHT}                                    # d04 canon: the parley: a few come
JUNGLE_HELD = past("d10_jungle.jungle", "held")
JUNGLE_THIN = past("d10_jungle.jungle", "thin")
FRESH = {"version": "fresh"}                                # d09 `first` = clockwork: the city fought first
GROWN = {"version": "grown"}                                # d09 `first` = brood: the city grew a year
CROWN = {"playing": "crown"}
CITY_P = {"playing": "city"}
NO_CROWN = {"not": CROWN}
NO_CITY = {"not": CITY_P}
NORMAL_UP = {"difficulty": ["normal", "hard"]}
HARD = {"difficulty": ["hard"]}
EASY = {"difficulty": ["easy"]}
ENDED = [{"fired": "the_end"}, {"fired": "lost_park"}, {"fired": "c_won"}]
LIVE = {"not": {"any": ENDED}}
P1 = {"not": {"fired": "part2"}}
P2 = {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}]}
P3 = {"fired": "part3"}

# ---------------------------------------------------------------- numbers (NORMAL; EASY / HARD: the mission's "difficulty",
# clocks x1.25 / x0.85, the sorties x0.7 / x1.3)
GOLD, POWDER = 500, 300
DUSK_SECS = 240           # Part 1: the city comes out at nightfall (the lines dug or not)
SORTIE_GAP = 50           # Part 2: a sortie this often (three)
DAWN_SECS = 200           # Part 2: after this long the sorties end anyway (NO WAITING)
SAP_SECS = {"easy": 36, "normal": 45, "hard": 54}     # FRESH Part 3: the pioneers under the ground
RELIEF_SECS = 180         # GROWN Part 3: the great sortie until dusk
DIG_SECS = 40             # GROWN Part 3: the city's diggers come up in the camp after this long
GATE_HP = {"fresh": 900, "grown": 2000}               # a gate piece's health (d07 spring stopped: x0.75)
BREACH_HP = {"fresh": 140, "grown": 1500}             # the unfinished stretches: scaffolding (FRESH) / finished wall (GROWN)
WEAK = 0.35               # a weak gate (its stop-work taken out) keeps this share
SPRING_HP = 6000          # the great spring's tower: the mine's work, not the guns'
CITY_EVERY = 10           # the city's player: cogs this often
PAY_EVERY, PAY = 30, 60   # the column's pay convoy (gold) up the valley road

# the map's places
G = smap.GATES
GATE_TAG = {"north_gate": "g_north", "west_gate": "g_west", "south_gate": "g_south"}
OUT_OF = {"north_gate": "north_out", "west_gate": "west_out", "south_gate": "south_out"}
IN_OF = {"north_gate": "north_in", "west_gate": "west_in", "south_gate": "south_in"}
BAT_OF = {"north_gate": "bat_n", "west_gate": "bat_w", "south_gate": "bat_s"}
EARTH_X = 44              # the earthworks' column (each battery: four palisade pieces before its guns)


def inner(nm):
    """A works' building one cell in from its lot's corner (d07's rule)."""
    a = LOT[nm]["at"]
    return [a[0] + 1, a[1] + 1]


# ================================================================== the units
COL = {"team": "column", "at": "camp_mid", "fixed": True}
KIT = {"lock": "matchlock", "bayonet": True}
units = [
    # ---- the southern column (the player)
    dict(COL, kind="missionary", **{"as": "ferrer_siege", "count": 1, "tag": "ferrer", "tags": ["leaders"]}),
    dict(COL, kind="dismounted", **{"as": "ruggieri_general", "count": 1, "tag": "ruggieri", "tags": ["leaders"]}),
    dict(COL, kind="labourer", **{"as": "jakob_siege", "count": 1, "tag": "jakob", "tags": ["pioneers"], "if": JAKOB_ALIVE}),
    dict(COL, kind="missionary", **{"as": "hollweg_prisoner", "count": 1, "tag": "hollweg", "if": SPRING_STOPPED}),
    dict(COL, kind="labourer", **{"as": "pioneer", "count": 5, "tag": "pioneers"}),
    dict(COL, kind="musketeer", count=8, tag="line", kit=KIT),
    dict(COL, kind="musketeer", count=4, tag="line", tags=["armoured"], kit=dict(KIT, armour=True)),
    dict(COL, kind="cuirassier", count=3, tag="riders", tags=["armoured"], kit={"armour": True}),
    dict(COL, kind="cannon", count=3, tag="guns"),
    dict(COL, kind="mortar", count=2, tag="guns"),
    dict(COL, kind="powder_wagon", count=1, tag="wagons"),
    # ---- the valley (co-op p2): Captain Arruda and the militia (d04: fought = many, parley = a few)
    {"team": "valley", "kind": "cuirassier", "as": "arruda", "count": 1, "at": "valley_camp", "tag": "arruda", "fixed": True},
    {"team": "valley", "kind": "musketeer", "as": "valley_militia", "count": 7, "at": "valley_camp", "tag": "militia", "fixed": True, "if": FOUGHT},
    {"team": "valley", "kind": "cuirassier", "as": "rancher", "count": 2, "at": "valley_camp", "tag": "militia", "fixed": True, "if": FOUGHT},
    {"team": "valley", "kind": "musketeer", "as": "valley_militia", "count": 3, "at": "valley_camp", "tag": "militia", "fixed": True, "if": PARLEY},
    # ---- the honest masters (d07 `spring` stopped): Matthias and a few machines, by the postern
    {"team": "masters", "kind": "winder", "as": "matthias", "count": 1, "at": "masters_camp", "tag": "matthias", "if": SPRING_STOPPED},
    {"team": "masters", "kind": "clock_soldier", "count": 2, "at": "masters_camp", "tag": "masters", "fixed": True, "if": SPRING_STOPPED},
    {"team": "masters", "kind": "clock_soldier", "count": 2, "at": "masters_camp", "tag": "masters", "fixed": True,
     "if": {"all": [SPRING_STOPPED, HONEST_MANY]}},
    # ---- the city: its garrison in the arsenal (GROWN: more, Pendulums, the bolt-throwers on the wall, owls)
    {"team": "city", "kind": "winder", "count": 3, "at": "arsenal_mid", "tag": "city_winders"},
    {"team": "city", "kind": "clock_soldier", "count": 6, "at": "arsenal_mid", "tag": "garrison", "if": FRESH},
    {"team": "city", "kind": "clock_soldier", "count": 10, "at": "arsenal_mid", "tag": "garrison", "if": GROWN},
    {"team": "city", "kind": "springer", "count": 2, "at": "arsenal_mid", "tag": "garrison", "if": FRESH},
    {"team": "city", "kind": "springer", "count": 3, "at": "arsenal_mid", "tag": "garrison", "if": GROWN},
    {"team": "city", "kind": "netter", "count": 2, "at": "arsenal_mid", "tag": "garrison"},
    {"team": "city", "kind": "pendulum", "count": 2, "at": "arsenal_mid", "tag": "garrison", "if": GROWN},
    {"team": "city", "kind": "ticking_owl", "count": 2, "at": "spring_top", "tag": "city_owls", "if": GROWN},
    # (GROWN: the Spring Ballistas on the wall walk, one by each gate)
] + [
    {"team": "city", "kind": "ballista", "count": 1, "at": IN_OF[g], "tag": "wall_guns", "tags": ["garrison"], "if": GROWN}
    for g in ("north_gate", "west_gate", "south_gate")
] + [
    # ---- Hollweg on his wall (d07 `spring` running): seen, not met (spared: nobody aims at him)
    {"team": "city", "kind": "missionary", "as": "hollweg_walls", "count": 1, "at": "hollweg_post", "tag": "hollweg_w", "fixed": True,
     "if": SPRING_RUNNING},
]

# ================================================================== the buildings
EARTH = {"bat_n": G["north_gate"], "bat_w": G["west_gate"], "bat_s": G["south_gate"]}
earthworks = []
for bat, gy in EARTH.items():
    for dy in (-2, -1, 1, 2):
        cell = [EARTH_X, gy + dy]
        # (the Crown's player digs them: building sites; the city's player meets them dug)
        earthworks.append({"team": "column", "kind": "wall", "at": cell, "tag": "earthworks", "tags": ["ew_" + bat], "site": True, "if": CROWN,
                           "name": T("The earthworks", "As trincheiras", "Las trincheras")})
        earthworks.append({"team": "column", "kind": "wall", "at": cell, "tag": "earthworks", "tags": ["ew_" + bat], "if": NO_CROWN,
                           "name": "The earthworks"})

WALLS = smap.wall_cells()
city_walls = []
for gname, gtag in GATE_TAG.items():
    for c in WALLS[gname]:
        city_walls.append({"team": "city", "kind": "gate", "at": c, "tag": "gates", "tags": [gtag],
                           "name": T("A gate of Concórdia", "Um portão de Concórdia", "Una puerta de Concórdia")})
for bname in smap.BREACHES:
    for c in WALLS[bname]:
        city_walls.append({"team": "city", "kind": "wall", "at": c, "tag": "breaches", "tags": [bname], "if": FRESH,
                           "name": T("The wall's scaffolding (unfinished)", "Os andaimes da muralha (por acabar)", "Los andamios de la muralla (sin acabar)")})
        city_walls.append({"team": "city", "kind": "wall", "at": c, "tag": "breaches", "tags": [bname], "if": GROWN,
                           "name": T("Concórdia's wall", "A muralha de Concórdia", "La muralla de Concórdia")})
for c in WALLS["postern"]:
    # (the postern by the old Nuremberg quarter: the honest masters' (d07 `spring` stopped: it opens for the Crown), else the city's)
    city_walls.append({"team": "masters", "kind": "gate", "at": c, "tag": "postern", "if": SPRING_STOPPED,
                       "name": T("The postern of the old quarter", "A poterna do bairro velho", "La poterna del barrio viejo")})
    city_walls.append({"team": "city", "kind": "gate", "at": c, "tag": "postern", "tags": ["gates"], "if": SPRING_RUNNING,
                       "name": "The postern of the old quarter"})

buildings = (
    # ---- the camp: the column's depot and THE SIEGE PARK's magazine
    [{"team": "column", "kind": "powder_mill", "at": [10, 54], "tag": "park",
      "name": T("The siege park's magazine", "O paiol do parque de cerco", "El polvorín del parque de asedio")},
     {"team": "column", "kind": "barracks", "at": [12, 40], "tag": "depot", "tags": ["c_barracks"],
      "name": T("The camp's barracks", "O quartel do acampamento", "El cuartel del campamento")},
     {"team": "column", "kind": "armoury", "at": [20, 20], "tag": "depot", "tags": ["c_armoury", "camp_n"],
      "name": T("The camp's armoury", "O arsenal do acampamento", "La armería del campamento")},
     {"team": "column", "kind": "foundry", "at": [20, 64], "tag": "depot", "tags": ["c_foundry"],
      "name": T("The siege train's foundry", "A fundição do trem de cerco", "La fundición del tren de asedio")},
     {"team": "column", "kind": "horse_breeder", "at": [4, 28], "tag": "depot", "tags": ["c_breeder"],
      "name": T("The camp's horse lines", "As cavalariças do acampamento", "Las caballerizas del campamento")}]
    + [{"team": "column", "kind": "cottage", "at": c, "tag": "depot", "tags": ["tents"],
        "name": T("The column's tents", "As tendas da coluna", "Las tiendas de la columna")} for c in [[28, 44], [28, 48], [4, 44], [4, 48], [28, 40], [28, 56], [32, 44], [32, 48]]]
    + earthworks
    # ---- the city: the wall's gates, its stretches, the postern
    + city_walls
    # ---- THE GREAT SPRING on the mine hill
    + [{"team": "city", "kind": "clocktower", "at": LOT["spring"]["at"], "tag": "spring",
        "name": T("The Great Spring", "A Grande Mola", "El Gran Muelle")}]
    # ---- the arsenal in the old Nuremberg quarter (d07's meshed layout round its tower: every ring meshes)
    + [{"team": "city", "kind": "clocktower", "at": smap.TOWER, "tag": "arsenal", "tags": ["works"],
        "name": T("The arsenal's tower", "A torre do arsenal", "La torre del arsenal")},
       {"team": "city", "kind": "escapement", "at": smap.ESCAPEMENT, "tag": "escapement", "tags": ["works"]},
       {"team": "city", "kind": "movement_works", "at": smap.LIGHT_WORKS, "tag": "light_works", "tags": ["works"]},
       {"team": "city", "kind": "heavy_works", "at": smap.HEAVY_WORKS, "tag": "heavy_works", "tags": ["works"]},
       {"team": "city", "kind": "mainspring", "at": smap.MAINSPRING, "tag": "mainspring", "tags": ["works"]},
       {"team": "city", "kind": "cuckoo_house", "at": smap.AVIARY, "tag": "aviary", "tags": ["works"]},
       {"team": "city", "kind": "cog_press", "at": smap.PRESS, "tag": "works"}]
    + [{"team": "city", "kind": "regulator", "at": at, "tag": "works"} for at in smap.REGULATORS]
    # ---- the city's works in its quarters (d07's lots)
    + [{"team": "city", "kind": k, "at": inner(nm), "tag": "city_works", "tags": ["w_" + nm]} for nm, (q, k, _sz, _n) in smap.WORKS.items()]
)

areas = dict(CITY.areas)
areas.update(smap.areas_extra(CITY))
areas.update({
    "valley_camp": [8, 70, 10, 8], "park_near": [16, 50, 5, 5], "masters_camp": [44, 36, 6, 8], "outside": [0, 0, smap.WALL_X, 96],
    "earth_n": [EARTH_X - 1, G["north_gate"] - 3, 3, 7], "earth_w": [EARTH_X - 1, G["west_gate"] - 3, 3, 7],
    "earth_s": [EARTH_X - 1, G["south_gate"] - 3, 3, 7],
})

# ================================================================== the objectives
objectives = [
    # ---- the column (the Crown)
    {"id": "park", "side": "crown", "primary": True, "kind": "protect", "tag": "park",
     "text": T("The siege park's magazine (in the camp) must stand.", "O paiol do parque de cerco (no acampamento) tem de ficar de pé.",
               "El polvorín del parque de asedio (en el campamento) debe seguir en pie.")},
    {"id": "lines", "side": "crown", "primary": False, "kind": "build", "tag": "earthworks",
     "text": T("THE LINES: your pioneers (the Labourers) dig the earthworks marked before the three gates. Select them and right-click a marked palisade. Then set the guns behind the earthworks.",
               "AS LINHAS: os seus sapadores (os Trabalhadores) cavam as trincheiras marcadas diante dos três portões. Selecione-os e clique com o botão direito numa paliçada marcada. Depois ponha os canhões atrás das trincheiras.",
               "LAS LÍNEAS: tus zapadores (los Trabajadores) cavan las trincheras marcadas ante las tres puertas. Selecciónalos y haz clic derecho en una empalizada marcada. Luego pon los cañones detrás de las trincheras."),
     "phone": T("Dig the marked earthworks with the pioneers; guns behind them.", "Cave as trincheiras marcadas com os sapadores; canhões atrás delas.",
                "Cava las trincheras marcadas con los zapadores; cañones detrás.")},
    {"id": "dusk", "side": "crown", "primary": False, "kind": "countdown", "clock": "dusk",
     "text": T("The city comes out at nightfall: {clock:dusk}.", "A cidade sai ao anoitecer: {clock:dusk}.", "La ciudad sale al anochecer: {clock:dusk}.")},
    {"id": "charges", "side": "crown", "primary": False, "kind": "manual",
     "text": T("At the camp's Armoury (north of the camp) research PREPARED CHARGES, then the GUNNER'S QUADRANT: your guns reload faster and reach farther.",
               "No Arsenal do acampamento (a norte do acampamento) pesquise as CARGAS PREPARADAS, depois o QUADRANTE DO ARTILHEIRO: os seus canhões recarregam mais depressa e alcançam mais longe.",
               "En la Armería del campamento (al norte del campamento) investiga las CARGAS PREPARADAS, luego el CUADRANTE DEL ARTILLERO: tus cañones recargan más rápido y alcanzan más lejos."),
     "phone": T("Armoury: research PREPARED CHARGES, then the QUADRANT.", "Arsenal: pesquise CARGAS PREPARADAS, depois o QUADRANTE.",
                "Armería: investiga CARGAS PREPARADAS, luego el CUADRANTE.")},
    {"id": "jakob", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Keep Jakob alive: he hears the city's ticking. Nothing will bring him back if he falls.",
               "Mantenha o Jakob vivo: ele ouve o tiquetaque da cidade. Nada o trará de volta se cair.",
               "Mantén a Jakob con vida: oye el tictac de la ciudad. Nada lo traerá de vuelta si cae.")},
    {"id": "breach", "side": "crown", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Knock down a gate with the guns. The weak ones are marked (their stop-works were taken out).",
               "Derrube um portão com os canhões. Os fracos estão marcados (tiraram-lhes os travões).",
               "Derriba una puerta con los cañones. Las débiles están marcadas (les quitaron los frenos).")},
    {"id": "sorties", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE SORTIES: the city comes out of its gates at the batteries. Beat each sortie back and keep the guns. Sortie {sortie_n} of 3.",
               "AS SURTIDAS: a cidade sai pelos portões contra as baterias. Repila cada surtida e guarde os canhões. Surtida {sortie_n} de 3.",
               "LAS SALIDAS: la ciudad sale por sus puertas contra las baterías. Rechaza cada salida y conserva los cañones. Salida {sortie_n} de 3."),
     "phone": T("Beat back the sorties at the batteries ({sortie_n} of 3).", "Repila as surtidas nas baterias ({sortie_n} de 3).",
                "Rechaza las salidas en las baterías ({sortie_n} de 3).")},
    {"id": "dawn_clock", "side": "crown", "primary": False, "kind": "countdown", "clock": "dawn", "hidden": True,
     "text": T("Full day in {clock:dawn}.", "Dia pleno em {clock:dawn}.", "Pleno día en {clock:dawn}.")},
    # FRESH: THE MINE
    {"id": "mine", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE MINE: bring at least two pioneers (Labourers) to the old mine's mouth in the north of the camp (pinged). They go down the galleries under the wall to the great spring's tower.",
               "A MINA: leve pelo menos dois sapadores (Trabalhadores) à boca da mina velha, no norte do acampamento (assinalada). Descem pelas galerias por baixo da muralha até à torre da grande mola.",
               "LA MINA: lleva al menos dos zapadores (Trabajadores) a la boca de la mina vieja, al norte del campamento (señalada). Bajan por las galerías bajo la muralla hasta la torre del gran muelle."),
     "phone": T("Two pioneers to the old mine's mouth (north of the camp).", "Dois sapadores à boca da mina velha (norte do acampamento).",
                "Dos zapadores a la boca de la mina vieja (norte del campamento).")},
    {"id": "mine_clock", "side": "crown", "primary": False, "kind": "countdown", "clock": "mine", "hidden": True,
     "text": T("The pioneers are under the ground. Hold the mine's mouth: they reach the spring in {clock:mine}.",
               "Os sapadores estão debaixo da terra. Guarde a boca da mina: chegam à mola em {clock:mine}.",
               "Los zapadores están bajo tierra. Guarda la boca de la mina: llegan al muelle en {clock:mine}.")},
    # GROWN: THE GREAT SORTIE
    {"id": "hold", "side": "crown", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE GREAT SORTIE: the city comes out with everything. Hold the camp and the siege park until dusk.",
               "A GRANDE SURTIDA: a cidade sai com tudo. Aguente o acampamento e o parque de cerco até ao anoitecer.",
               "LA GRAN SALIDA: la ciudad sale con todo. Resiste en el campamento y el parque de asedio hasta el anochecer."),
     "phone": T("Hold the camp and the park until dusk.", "Aguente o acampamento e o parque até ao anoitecer.", "Resiste en el campamento y el parque hasta el anochecer.")},
    {"id": "relief", "side": "crown", "primary": False, "kind": "countdown", "clock": "relief", "hidden": True,
     "text": T("Dusk in {clock:relief}.", "Anoitece em {clock:relief}.", "Anochece en {clock:relief}.")},
    {"id": "diggers", "side": "crown", "primary": False, "kind": "countdown", "clock": "diggers", "hidden": True,
     "text": T("The city's diggers come up by the siege park in {clock:diggers}, with a mine: have men there.",
               "Os escavadores da cidade saem junto ao parque de cerco em {clock:diggers}, com uma mina: tenha homens lá.",
               "Los excavadores de la ciudad salen junto al parque de asedio en {clock:diggers}, con una mina: ten hombres allí.")},
    # ---- the city (the solo pick, or versus)
    {"id": "c_break", "side": "city", "primary": True, "kind": "manual", "hidden": True,
     "text": T("BREAK THE SIEGE: blow the siege park's magazine (in the Crown's camp, west), or bring down Father Ferrer, the old priest. Before the Crown's work is done.",
               "QUEBRAR O CERCO: faça explodir o paiol do parque de cerco (no acampamento da Coroa, a oeste), ou derrube o Padre Ferrer, o velho padre. Antes que a Coroa acabe o seu trabalho.",
               "ROMPER EL ASEDIO: vuela el polvorín del parque de asedio (en el campamento de la Corona, al oeste), o derriba al Padre Ferrer, el viejo sacerdote. Antes de que la Corona acabe su trabajo."),
     "phone": T("Blow the siege park's magazine or bring down Father Ferrer.", "Exploda o paiol do parque de cerco ou derrube o Padre Ferrer.",
                "Vuela el polvorín del parque de asedio o derriba al Padre Ferrer.")},
]

M = {
    "id": MID,
    "title": T("The Siege of Concórdia", "O Cerco de Concórdia", "El Asedio de Concórdia"),
    "summary": T("The southern highlands, 2780. The army's southern column lays siege to the city of gears. Father Ferrer comes with it as Rome's witness.",
                 "O planalto do sul, 2780. A coluna do sul do exército põe cerco à cidade das engrenagens. O Padre Ferrer vem com ela como testemunha de Roma.",
                 "El altiplano del sur, 2780. La columna del sur del ejército pone sitio a la ciudad de engranajes. El Padre Ferrer viene con ella como testigo de Roma."),
    "map": "campaign:concordia_siege",
    "voice": "d11",
    "light": "day",
    "expansion_spots": False,
    "manual_end": True,
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.7}, "hard": {"clocks": 0.85, "spawns": 1.3}},
    # THE DIAMOND (owner question 9: the second front is locked until the first is won): after d09; with the swarm chosen
    # first, after d10 too
    "needs": ["a07_council", "d09_crossroads", {"id": "d10_jungle", "if": past("d09_crossroads.first", "brood")}],
    # TWO VERSIONS (act2-engine0): FRESH when the city was chosen first, GROWN when it waited a year
    "versions": {"pick": [{"if": past("d09_crossroads.first", "clockwork"), "id": "fresh"}], "default": "grown",
                 "labels": {"fresh": T("FRESH: the city fought first. Its wall is not finished and its army is out on the roads: a true siege.",
                                       "FRESCO: a cidade combatida primeiro. A muralha não está acabada e o exército dela anda pelas estradas: um cerco a sério.",
                                       "FRESCO: la ciudad combatida primero. Su muralla no está acabada y su ejército anda por los caminos: un asedio de verdad."),
                            "grown": T("GROWN: the city waited a year. Its wall is finished, the bolt-throwers stand on it, owls fly over the camp.",
                                       "CRESCIDA: a cidade esperou um ano. A muralha está acabada, as balestras estão nela, corujas voam sobre o acampamento.",
                                       "CRECIDA: la ciudad esperó un año. Su muralla está acabada, las ballestas están en ella, búhos vuelan sobre el campamento.")}},
    "modes": ["solo", "coop", "versus"],
    "solo_sides": ["crown", "city"],
    "sides": [
        {"id": "crown", "name": T("The Southern Column", "A Coluna do Sul", "La Columna del Sur"),
         "about": T("Father Ferrer, Jakob, General Ruggieri's siege train and the army's southern column on the plateau before Concórdia; the valley's militia.",
                    "O Padre Ferrer, o Jakob, o trem de cerco do General Ruggieri e a coluna do sul do exército no planalto diante de Concórdia; a milícia do vale.",
                    "El Padre Ferrer, Jakob, el tren de asedio del General Ruggieri y la columna del sur del ejército en el altiplano ante Concórdia; la milicia del valle.")},
        {"id": "city", "name": T("The City", "A Cidade", "La Ciudad"),
         "about": T("Concórdia: its wall, its works, its machines, and the great spring that drives them.",
                    "Concórdia: a sua muralha, as suas oficinas, as suas máquinas, e a grande mola que as move.",
                    "Concórdia: su muralla, sus talleres, sus máquinas, y el gran muelle que las mueve.")},
    ],
    "teams": [
        {"id": "column", "side": "crown", "faction": "crown", "colour": 4, "start": "none", "camera": "camp_mid", "gold": GOLD,
         "powder": POWDER, "techs": ["matchlock", "bayonet", "charge", "armour"],
         "control": {"solo": "p1", "coop": "p1", "versus": "p1", "foe": "script"}},
        {"id": "valley", "side": "crown", "faction": "crown", "colour": 0, "start": "none", "camera": "valley_camp", "gold": 100, "powder": 100,
         "techs": ["matchlock"],
         "roster": {"deny": ["town_hall", "cottage", "farm", "wall", "gate", "barracks", "powder_mill", "horse_breeder", "foundry", "armoury",
                             "church", "labourer", "missionary"]},
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "masters", "side": "crown", "faction": "clockwork", "colour": 0, "start": "none", "camera": "masters_camp",
         "control": {"solo": "script", "coop": "script", "versus": "script"}},
        {"id": "city", "side": "city", "faction": "clockwork", "colour": 1, "start": "none", "camera": "arsenal_mid", "gold": 250, "powder": 200,
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": areas,
    "counters": {k: {"start": 0} for k in ["sortie_n", "out_n", "dug_n"]},
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["ferrer", "ruggieri", "hollweg", "matthias", "arruda"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "crown", "portrait": "res://campaign/hub/rome_king_face.png"},
        "ferrer": {"name": T("Father Ferrer", "Padre Ferrer", "Padre Ferrer"), "side": "crown"},
        "jakob": {"name": T("Jakob", "Jakob", "Jakob"), "side": "crown"},
        "ruggieri": {"name": T("General Ruggieri", "General Ruggieri", "General Ruggieri"), "side": "crown"},
        "hollweg": {"name": T("Meister Hollweg", "Mestre Hollweg", "Maestro Hollweg"), "side": "crown"},
        "matthias": {"name": T("Matthias", "Matthias", "Matthias"), "side": "crown"},
        "arruda": {"name": T("Captain Arruda", "Capitão Arruda", "Capitán Arruda"), "side": "crown"},
        "narrator": {"name": T("The Siege Lines", "As Linhas de Cerco", "Las Líneas de Asedio"), "side": "crown"},
        "cityn": {"name": T("The City", "A Cidade", "La Ciudad"), "side": "city"},
    },
    "lines": {},
    "stills": {},
    "next": {"crown": "", "city": ""},
    "debrief": {},
}

L = M["lines"]


def line(lid, who, en, pt, es, to=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    return lid


CR, CI = "crown", "city"
# ---- the opening (the King frames; Ferrer tells it, in his report to Rome)
line("k_open1", "king", "Father Ferrer was old by then. Rome sent him to the highlands anyway, to see the city of gears with his own eyes.",
     "O Padre Ferrer já era velho. Roma mandou-o ao planalto mesmo assim, para ver a cidade das engrenagens com os seus próprios olhos.",
     "El Padre Ferrer ya era viejo. Roma lo mandó al altiplano de todos modos, a ver la ciudad de engranajes con sus propios ojos.")
line("k_open2", "king", "His report is on my desk still. He wrote it as a priest writes: what he saw, and nothing he did not.",
     "O relatório dele ainda está na minha mesa. Escreveu-o como escreve um padre: o que viu, e nada do que não viu.",
     "Su informe sigue en mi mesa. Lo escribió como escribe un sacerdote: lo que vio, y nada de lo que no vio.")
line("f_open1", "ferrer", "Concórdia, 2780. The army's southern column came up onto the plateau in the dry winter. General Ruggieri had the guns. I had Rome's letter.",
     "Concórdia, 2780. A coluna do sul do exército subiu ao planalto no inverno seco. O General Ruggieri tinha os canhões. Eu tinha a carta de Roma.",
     "Concórdia, 2780. La columna del sur del ejército subió al altiplano en el invierno seco. El General Ruggieri tenía los cañones. Yo tenía la carta de Roma.")
line("f_open_fresh", "ferrer", "We had come early. The city had not finished its wall, and its machines were out on the southern roads.",
     "Tínhamos chegado cedo. A cidade não tinha acabado a muralha, e as suas máquinas andavam pelas estradas do sul.",
     "Habíamos llegado pronto. La ciudad no había acabado su muralla, y sus máquinas andaban por los caminos del sur.")
line("f_open_grown", "ferrer", "We came a year late. The wall was finished, brass on timber, and the great bolt-throwers stood on it.",
     "Chegámos com um ano de atraso. A muralha estava acabada, latão sobre madeira, e as grandes balestras estavam nela.",
     "Llegamos con un año de retraso. La muralla estaba acabada, latón sobre madera, y las grandes ballestas estaban en ella.")
line("f_open_jakob", "ferrer", "Jakob had come with me from Fürth, an old man now. He said he could hear the city ticking from the road.",
     "O Jakob tinha vindo comigo de Fürth, já velho. Dizia que ouvia a cidade a fazer tiquetaque desde a estrada.",
     "Jakob había venido conmigo desde Fürth, ya viejo. Decía que oía el tictac de la ciudad desde el camino.")
line("f_open_nojakob", "ferrer", "Jakob was not with me. I had his log of Nuremberg, and I read it every night by the lantern.",
     "O Jakob não estava comigo. Eu tinha o diário dele de Nuremberga, e lia-o todas as noites à luz da lanterna.",
     "Jakob no estaba conmigo. Tenía su diario de Núremberg, y lo leía cada noche a la luz del farol.")
line("f_open_held", "ferrer", "The jungle front had held. The army came south with the river towns safe behind it.",
     "A frente da selva tinha aguentado. O exército veio para sul com as vilas do rio a salvo atrás de si.",
     "El frente de la selva había resistido. El ejército vino al sur con las villas del río a salvo tras él.")
line("f_open_thin", "ferrer", "The jungle front was thin when the army left it. Nobody spoke of it on the road south.",
     "A frente da selva estava fraca quando o exército a deixou. Ninguém falou disso na estrada para sul.",
     "El frente de la selva estaba débil cuando el ejército lo dejó. Nadie habló de ello en el camino al sur.")
line("k_open_c", "king", "Ferrer tells it from the lines. Here it is from inside the wall, where nobody wrote anything down.",
     "Ferrer conta-o das linhas. Aqui está visto de dentro da muralha, onde ninguém escreveu nada.",
     "Ferrer lo cuenta desde las líneas. Aquí está visto desde dentro de la muralla, donde nadie escribió nada.")
line("cn_open", "cityn", "The plateau is full of the Crown's tents. The city's works turn day and night. Nobody in the council says who gives the orders.",
     "O planalto está cheio das tendas da Coroa. As oficinas da cidade giram dia e noite. Ninguém no conselho diz quem dá as ordens.",
     "El altiplano está lleno de las tiendas de la Corona. Los talleres de la ciudad giran día y noche. Nadie en el consejo dice quién da las órdenes.")
# ---- part 1: the lines
line("r_lines", "ruggieri", "Dig in, Father. Three batteries, one before each gate. Nobody walks up to that wall in daylight.",
     "Entrincheirem-se, Padre. Três baterias, uma diante de cada portão. Ninguém sobe àquela muralha de dia.",
     "Atrincheraos, Padre. Tres baterías, una ante cada puerta. Nadie se acerca a esa muralla de día.", CR)
line("n_lines", "narrator", "THE LINES: your pioneers (the Labourers) dig the marked earthworks before the three gates. Select them and right-click a marked palisade. Then bring the guns up behind the earthworks.",
     "AS LINHAS: os seus sapadores (os Trabalhadores) cavam as trincheiras marcadas diante dos três portões. Selecione-os e clique com o botão direito numa paliçada marcada. Depois traga os canhões para trás das trincheiras.",
     "LAS LÍNEAS: tus zapadores (los Trabajadores) cavan las trincheras marcadas ante las tres puertas. Selecciónalos y haz clic derecho en una empalizada marcada. Luego trae los cañones detrás de las trincheras.", CR)
line("n_dusk", "narrator", "The city's machines come out at nightfall. Get the lines dug before then.",
     "As máquinas da cidade saem ao anoitecer. Tenha as linhas cavadas antes disso.", "Las máquinas de la ciudad salen al anochecer. Ten las líneas cavadas antes.", CR)
line("j_weak", "jakob", "The north gate and the south gate, Father. Their stop-works are gone. I hear them run on, a beat too fast. They will break first.",
     "O portão norte e o portão sul, Padre. Os travões deles desapareceram. Ouço-os correr, uma batida depressa demais. Vão ceder primeiro.",
     "La puerta norte y la puerta sur, Padre. Sus frenos han desaparecido. Los oigo correr, un golpe demasiado rápido. Cederán primero.", CR)
line("n_weak", "narrator", "Jakob marked the two weak gates (pinged). Your guns knock them down sooner than the others.",
     "O Jakob marcou os dois portões fracos (assinalados). Os seus canhões derrubam-nos mais depressa do que os outros.",
     "Jakob marcó las dos puertas débiles (señaladas). Tus cañones las derriban antes que las otras.", CR)
line("f_hollweg", "ferrer", "On the wall by the great spring stood an old man in a master's coat. He was watching our guns.",
     "Na muralha junto à grande mola estava um velho de casaco de mestre. Observava os nossos canhões.",
     "En la muralla junto al gran muelle había un viejo con abrigo de maestro. Miraba nuestros cañones.", CR)
line("j_hollweg", "jakob", "It is the Meister. He does not see us, Father. He is listening to the city.",
     "É o Mestre. Não nos vê, Padre. Está a ouvir a cidade.", "Es el Maestro. No nos ve, Padre. Está escuchando a la ciudad.", CR)
line("h_prisoner", "hollweg", "I asked to come, Father. I know the city's ways in. Let me show them, and then do with me what Rome asks.",
     "Pedi para vir, Padre. Conheço os caminhos para dentro da cidade. Deixe-me mostrá-los, e depois faça de mim o que Roma pedir.",
     "Pedí venir, Padre. Conozco los caminos para entrar en la ciudad. Déjeme mostrarlos, y luego haga conmigo lo que Roma pida.", CR)
line("f_prisoner", "ferrer", "Stand by me and say what you see. That is all Rome asks of you today.",
     "Fique ao meu lado e diga o que vê. É tudo o que Roma lhe pede hoje.", "Quédese a mi lado y diga lo que ve. Es todo lo que Roma le pide hoy.", CR)
line("a_hello", "arruda", "The valley is here, Father. We fought that city the day it was founded. We will fight it now.",
     "O vale está aqui, Padre. Combatemos aquela cidade no dia em que foi fundada. Vamos combatê-la agora.",
     "El valle está aquí, Padre. Combatimos esa ciudad el día que la fundaron. La combatiremos ahora.", CR)
line("a_hello_few", "arruda", "A few of the valley came, Father. The rest gave their word to the city once, and keep it.",
     "Vieram alguns do vale, Padre. Os outros deram uma vez a sua palavra à cidade, e mantêm-na.",
     "Vinieron unos pocos del valle, Padre. Los demás dieron una vez su palabra a la ciudad, y la cumplen.", CR)
line("n_probe", "narrator", "A few machines come out of the north gate at the diggers.", "Algumas máquinas saem do portão norte contra os que cavam.",
     "Unas pocas máquinas salen de la puerta norte contra los que cavan.", CR)
line("r_probe", "ruggieri", "Muskets forward! Cover the diggers!", "Mosquetes à frente! Cubram os que cavam!", "¡Mosquetes adelante! ¡Cubrid a los que cavan!", CR)
line("n_probe2", "narrator", "Machines out of the south gate.", "Máquinas a sair do portão sul.", "Máquinas saliendo de la puerta sur.", CR)
line("n_probe3", "narrator", "Machines out of the west gate at the diggers.", "Máquinas a sair do portão oeste contra os que cavam.",
     "Máquinas saliendo de la puerta oeste contra los que cavan.", CR)
line("n_owls_camp", "narrator", "Brass owls over the camp: the city sees everything you do. Muskets at them.",
     "Corujas de latão sobre o acampamento: a cidade vê tudo o que faz. Mosquetes contra elas.",
     "Búhos de latón sobre el campamento: la ciudad ve todo lo que haces. Mosquetes contra ellos.", CR)
line("r_charges", "ruggieri", "Father, the Armoury. Prepared charges, the powder bagged ready, and the gunner's quadrant. My guns will fire faster and farther.",
     "Padre, o Arsenal. Cargas preparadas, a pólvora já ensacada, e o quadrante do artilheiro. Os meus canhões vão disparar mais depressa e mais longe.",
     "Padre, la Armería. Cargas preparadas, la pólvora ya en saquitos, y el cuadrante del artillero. Mis cañones dispararán más rápido y más lejos.", CR)
line("n_lines_done", "narrator", "The lines are dug. Set the guns behind the earthworks: at nightfall the city comes out.",
     "As linhas estão cavadas. Ponha os canhões atrás das trincheiras: ao anoitecer a cidade sai.",
     "Las líneas están cavadas. Pon los cañones detrás de las trincheras: al anochecer la ciudad sale.", CR)
line("n_pay", "narrator", "A convoy comes up the valley road with the army's pay: gold every half minute. The camp's Barracks trains Musketeers, its Foundry guns.",
     "Um comboio sobe a estrada do vale com o soldo do exército: ouro a cada meio minuto. O Quartel do acampamento treina Mosqueteiros, a sua Fundição canhões.",
     "Un convoy sube por el camino del valle con la paga del ejército: oro cada medio minuto. El Cuartel del campamento entrena Mosqueteros, su Fundición cañones.", CR)
line("n_charges_done", "narrator", "The guns have their prepared charges.", "Os canhões têm as suas cargas preparadas.", "Los cañones tienen sus cargas preparadas.", CR)
# ---- part 2: the sorties
line("n_night", "narrator", "Night. The city comes out of its gates. THE SORTIES: beat each one back at the batteries.",
     "Noite. A cidade sai pelos portões. AS SURTIDAS: repila cada uma nas baterias.", "Noche. La ciudad sale por sus puertas. LAS SALIDAS: rechaza cada una en las baterías.")
line("f_night", "ferrer", "We heard them before we saw them: the ticking under the wall, then the gates.",
     "Ouvimo-las antes de as vermos: o tiquetaque debaixo da muralha, depois os portões.",
     "Las oímos antes de verlas: el tictac bajo la muralla, luego las puertas.", CR)
line("n_s1", "narrator", "Brass owls out of the dark, and machines with chains at the west gate.",
     "Corujas de latão a sair do escuro, e máquinas com correntes no portão oeste.", "Búhos de latón saliendo de la oscuridad, y máquinas con cadenas en la puerta oeste.", CR)
line("n_s2", "narrator", "Dawn. Clock Soldiers out of the north and the south gates.", "Amanhecer. Soldados de Corda a sair dos portões norte e sul.",
     "Amanecer. Soldados de Cuerda saliendo de las puertas norte y sur.", CR)
line("n_s3", "narrator", "The last sortie, the heaviest, out of the west gate: a Pendulum among them.",
     "A última surtida, a mais pesada, pelo portão oeste: um Pêndulo entre elas.", "La última salida, la más pesada, por la puerta oeste: un Péndulo entre ellas.", CR)
line("n_s3_grown", "narrator", "Behind them, a bolt-thrower on its cog wheels. Its screw goes through one man into the next.",
     "Atrás delas, uma balestra sobre as suas rodas dentadas. O seu parafuso atravessa um homem e entra no seguinte.",
     "Tras ellas, una ballesta sobre sus ruedas dentadas. Su tornillo atraviesa a un hombre y entra en el siguiente.", CR)
line("f_log", "ferrer", "I read the log again by the lantern. The west gate: its stop-work was taken out, as at Nuremberg. I marked it for the guns.",
     "Li o diário outra vez à luz da lanterna. O portão oeste: tiraram-lhe o travão, como em Nuremberga. Marquei-o para os canhões.",
     "Leí el diario otra vez a la luz del farol. La puerta oeste: le quitaron el freno, como en Núremberg. La marqué para los cañones.", CR)
line("m_postern", "matthias", "The postern by our old quarter is still ours, Father. It opens for you, and not for them.",
     "A poterna junto ao nosso bairro velho ainda é nossa, Padre. Abre-se para vós, e não para eles.",
     "La poterna junto a nuestro barrio viejo sigue siendo nuestra, Padre. Se abre para vosotros, y no para ellos.", CR)
line("n_breach", "narrator", "A gate is down. The way into the city is open.", "Um portão caiu. O caminho para dentro da cidade está aberto.",
     "Una puerta ha caído. El camino a la ciudad está abierto.", CR)
line("j_hurt", "jakob", "I'm hit, Father. It is nothing. I'll walk back.", "Fui atingido, Padre. Não é nada. Volto a pé.", "Me han dado, Padre. No es nada. Volveré a pie.", CR)
line("n_jakob_down", "narrator", "Jakob has fallen.", "O Jakob caiu.", "Jakob ha caído.", CR)
line("f_jakob_down", "ferrer", "Jakob had followed me from Fürth across an ocean. I buried him on the plateau, facing the city.",
     "O Jakob seguira-me desde Fürth através de um oceano. Enterrei-o no planalto, de frente para a cidade.",
     "Jakob me había seguido desde Fürth a través de un océano. Lo enterré en el altiplano, frente a la ciudad.", CR)
line("n_sorties_done", "narrator", "The sorties are beaten back. The city shuts its gates.", "As surtidas foram repelidas. A cidade fecha os portões.",
     "Las salidas han sido rechazadas. La ciudad cierra sus puertas.")
line("n_charge", "narrator", "The machines outside the wall stop waiting. They come at the camp: beat them back and the night is over.",
     "As máquinas fora da muralha deixam de esperar. Vêm contra o acampamento: repele-as e a noite acaba.",
     "Las máquinas fuera de la muralla dejan de esperar. Vienen contra el campamento: recházalas y la noche termina.")
line("n_full_day", "narrator", "Full day. The city calls its machines back behind the wall.", "Dia pleno. A cidade chama as máquinas para trás da muralha.",
     "Pleno día. La ciudad llama a sus máquinas tras la muralla.")
# ---- part 3, FRESH: the mine
line("n_mine", "narrator", "THE MINE: bring at least two pioneers to the old mine's mouth in the north of the camp. They go down the old galleries, under the wall, to the great spring's tower.",
     "A MINA: leve pelo menos dois sapadores à boca da mina velha, no norte do acampamento. Descem pelas galerias velhas, por baixo da muralha, até à torre da grande mola.",
     "LA MINA: lleva al menos dos zapadores a la boca de la mina vieja, al norte del campamento. Bajan por las galerías viejas, bajo la muralla, hasta la torre del gran muelle.", CR)
line("j_mine", "jakob", "The old adits, Father. I hear the spring down there, louder than up here. The galleries go right under its tower.",
     "As galerias velhas, Padre. Ouço a mola lá em baixo, mais alto do que aqui em cima. As galerias passam mesmo por baixo da torre dela.",
     "Las galerías viejas, Padre. Oigo el muelle allí abajo, más fuerte que aquí arriba. Las galerías pasan justo bajo su torre.", CR)
line("h_mine", "hollweg", "I set the spring over the old shaft myself. The galleries run under it. Send your men down.",
     "Fui eu que pus a mola sobre o poço velho. As galerias passam por baixo dela. Mande os seus homens descer.",
     "Yo mismo puse el muelle sobre el pozo viejo. Las galerías pasan por debajo. Mande bajar a sus hombres.", CR)
line("f_mine", "ferrer", "Jakob's log had the mine's plan, copied at Fürth from the guild's own papers. The galleries ran under the spring.",
     "O diário do Jakob tinha a planta da mina, copiada em Fürth dos papéis da própria guilda. As galerias passavam por baixo da mola.",
     "El diario de Jakob tenía el plano de la mina, copiado en Fürth de los papeles del propio gremio. Las galerías pasaban bajo el muelle.", CR)
line("n_reserve", "narrator", "Your pioneers have all fallen. Three more come up from the baggage at the camp.",
     "Todos os seus sapadores caíram. Vêm mais três da bagagem no acampamento.", "Todos tus zapadores han caído. Llegan tres más del bagaje en el campamento.", CR)
line("n_wait", "narrator", "The city will not wait for you: its machines come out at the camp. Send the pioneers down the old mine.",
     "A cidade não espera por si: as suas máquinas saem contra o acampamento. Mande os sapadores descer pela mina velha.",
     "La ciudad no te espera: sus máquinas salen contra el campamento. Manda a los zapadores bajar por la mina vieja.", CR)
line("n_under", "narrator", "The pioneers are under the ground. Hold the mine's mouth until they reach the spring.",
     "Os sapadores estão debaixo da terra. Guarde a boca da mina até chegarem à mola.", "Los zapadores están bajo tierra. Guarda la boca de la mina hasta que lleguen al muelle.", CR)
line("r_under", "ruggieri", "The city knows. Here they come. Hold the mouth!", "A cidade sabe. Aí vêm eles. Guardem a boca!", "La ciudad lo sabe. Ahí vienen. ¡Guardad la boca!", CR)
line("n_spring_down", "narrator", "The great spring's tower falls into the old shaft. Every machine in Concórdia runs down where it stands.",
     "A torre da grande mola cai no poço velho. Todas as máquinas de Concórdia param onde estão.",
     "La torre del gran muelle cae en el pozo viejo. Todas las máquinas de Concórdia se paran donde están.")
line("f_spring1", "ferrer", "The ticking stopped. For the first time in seven years the city was quiet.",
     "O tiquetaque parou. Pela primeira vez em sete anos a cidade ficou em silêncio.", "El tictac se detuvo. Por primera vez en siete años la ciudad quedó en silencio.", CR)
line("f_spring2", "ferrer", "We did not go in. Rome's letter said to stop the city, and the city had stopped.",
     "Não entrámos. A carta de Roma mandava parar a cidade, e a cidade tinha parado.", "No entramos. La carta de Roma mandaba parar la ciudad, y la ciudad se había parado.", CR)
line("n_back", "narrator", "The pioneers come back up the gallery.", "Os sapadores voltam pela galeria.", "Los zapadores vuelven por la galería.", CR)
# ---- part 3, GROWN: the great sortie
line("n_hold", "narrator", "THE GREAT SORTIE: the city comes out with everything. Hold the camp and the siege park until dusk.",
     "A GRANDE SURTIDA: a cidade sai com tudo. Aguente o acampamento e o parque de cerco até ao anoitecer.",
     "LA GRAN SALIDA: la ciudad sale con todo. Resiste en el campamento y el parque de asedio hasta el anochecer.")
line("j_dig", "jakob", "Father, under us. Picks, and a spring. They are in the old galleries, coming to the camp.",
     "Padre, debaixo de nós. Picaretas, e uma mola. Estão nas galerias velhas, a vir para o acampamento.",
     "Padre, debajo de nosotros. Picos, y un muelle. Están en las galerías viejas, viniendo al campamento.", CR)
line("f_dig", "ferrer", "In the night the sentries heard digging under the camp. The galleries were the city's now.",
     "De noite as sentinelas ouviram cavar debaixo do acampamento. As galerias eram agora da cidade.",
     "De noche los centinelas oyeron cavar bajo el campamento. Las galerías eran ahora de la ciudad.", CR)
line("n_diggers", "narrator", "The city's machines are digging from the old galleries toward the siege park (pinged). They come up beside it with a mine: have men there when they come up.",
     "As máquinas da cidade estão a cavar das galerias velhas em direção ao parque de cerco (assinalado). Saem ao lado dele com uma mina: tenha homens lá quando saírem.",
     "Las máquinas de la ciudad cavan desde las galerías viejas hacia el parque de asedio (señalado). Salen a su lado con una mina: ten hombres allí cuando salgan.", CR)
line("n_up", "narrator", "They come up beside the siege park!", "Saem ao lado do parque de cerco!", "¡Salen junto al parque de asedio!", CR)
line("n_wave", "narrator", "Another wave out of the gates.", "Outra vaga a sair dos portões.", "Otra oleada saliendo de las puertas.", CR)
line("n_wave_big", "narrator", "Out of every gate at once, with the bolt-throwers.", "De todos os portões ao mesmo tempo, com as balestras.",
     "De todas las puertas a la vez, con las ballestas.", CR)
line("n_dusk_end", "narrator", "Dusk. The city's machines go back behind the wall. The siege holds the road, and nothing more.",
     "Anoitece. As máquinas da cidade voltam para trás da muralha. O cerco guarda a estrada, e nada mais.",
     "Anochece. Las máquinas de la ciudad vuelven tras la muralla. El asedio guarda el camino, y nada más.")
line("f_grown_end", "ferrer", "We held the road and they held the wall, and for a year nobody moved.",
     "Nós guardámos a estrada e eles a muralha, e durante um ano ninguém se mexeu.",
     "Nosotros guardamos el camino y ellos la muralla, y durante un año nadie se movió.", CR)
# ---- the lost endings
line("n_park_down", "narrator", "The siege park's magazine goes up. The column goes back down off the plateau.",
     "O paiol do parque de cerco explode. A coluna desce outra vez do planalto.", "El polvorín del parque de asedio estalla. La columna vuelve a bajar del altiplano.")
line("f_hurt", "ferrer", "A scratch. I have been hurt by worse things than a machine.", "Um arranhão. Já fui ferido por coisas piores do que uma máquina.",
     "Un rasguño. Me han herido cosas peores que una máquina.", CR)
# ---- the city's side (no machine speaks: the city's narrator)
line("cn_1", "cityn", "You are the city: its works, its gates, its machines on the wall. The Crown digs its lines on the plateau. Break the siege: blow the siege park's magazine in the camp, or bring down the old priest, Father Ferrer.",
     "Você é a cidade: as suas oficinas, os seus portões, as suas máquinas na muralha. A Coroa cava as suas linhas no planalto. Quebre o cerco: exploda o paiol do parque de cerco no acampamento, ou derrube o velho padre, o Padre Ferrer.",
     "Eres la ciudad: sus talleres, sus puertas, sus máquinas en la muralla. La Corona cava sus líneas en el altiplano. Rompe el asedio: vuela el polvorín del parque de asedio en el campamento, o derriba al viejo sacerdote, el Padre Ferrer.", CI)
line("cn_k7", "cityn", "The arsenal's Heavy Works makes Spring Ballistas; its Escapement teaches the Netters the Long Chain. The plates under the streets keep everything wound.",
     "A Oficina Pesada do arsenal faz Balestras de Mola; o seu Escape ensina aos Lança-Redes a Corrente Longa. As placas debaixo das ruas mantêm tudo com corda.",
     "El Taller Pesado del arsenal hace Ballestas de Muelle; su Escape enseña a los Lanzarredes la Cadena Larga. Las placas bajo las calles lo mantienen todo con cuerda.", CI)
line("cn_more", "cityn", "More machines come out of the works: they are yours.", "Mais máquinas saem das oficinas: são suas.", "Más máquinas salen de los talleres: son tuyas.", CI)
line("cn_mine", "cityn", "Something moves in the old galleries under the wall, toward the great spring.",
     "Algo se mexe nas galerias velhas debaixo da muralha, em direção à grande mola.", "Algo se mueve en las galerías viejas bajo la muralla, hacia el gran muelle.", CI)
line("cn_won", "cityn", "The siege park's magazine goes up. The Crown's column goes back down off the plateau.",
     "O paiol do parque de cerco explode. A coluna da Coroa desce outra vez do planalto.", "El polvorín del parque de asedio estalla. La columna de la Corona vuelve a bajar del altiplano.")
line("cn_ferrer", "cityn", "The old priest falls before the wall.", "O velho padre cai diante da muralha.", "El viejo sacerdote cae ante la muralla.")
line("cn_lost_spring", "cityn", "The great spring falls into the shaft. The city runs down.", "A grande mola cai no poço. A cidade para.", "El gran muelle cae en el pozo. La ciudad se para.")
line("cn_lost_dusk", "cityn", "Dusk. The siege still holds the road.", "Anoitece. O cerco ainda guarda a estrada.", "Anochece. El asedio todavía guarda el camino.")
# ---- the endings
line("f_end_close", "ferrer", "I wrote to Rome that the city was crippled, not taken. Its works still turned, slowly, without their great spring.",
     "Escrevi a Roma que a cidade estava aleijada, não tomada. As oficinas ainda giravam, devagar, sem a grande mola.",
     "Escribí a Roma que la ciudad estaba tullida, no tomada. Sus talleres aún giraban, despacio, sin su gran muelle.")
line("f_end_held", "ferrer", "I wrote to Rome that the city stood whole behind its wall, and the Crown held only the road.",
     "Escrevi a Roma que a cidade estava inteira atrás da muralha, e a Coroa guardava só a estrada.",
     "Escribí a Roma que la ciudad seguía entera tras su muralla, y la Corona guardaba solo el camino.")
line("f_end_jakob", "ferrer", "Jakob walked the lines with me every night after. He said the city ticked like a sick man's heart.",
     "O Jakob percorreu as linhas comigo todas as noites depois disso. Dizia que a cidade batia como o coração de um doente.",
     "Jakob recorrió las líneas conmigo cada noche después. Decía que la ciudad latía como el corazón de un enfermo.")
line("f_end_nojakob", "ferrer", "I have Jakob's log on my desk. I have written his name at the end of it.",
     "Tenho o diário do Jakob na minha mesa. Escrevi o nome dele no fim.", "Tengo el diario de Jakob en mi mesa. He escrito su nombre al final.")
line("f_end_walls", "ferrer", "Hollweg stood on his wall to the end. He never looked away from his city.",
     "O Hollweg ficou na sua muralha até ao fim. Nunca desviou os olhos da sua cidade.", "Hollweg siguió en su muralla hasta el final. Nunca apartó los ojos de su ciudad.")
line("f_end_prisoner", "ferrer", "Hollweg asked to see the lines at the end. He stood there a long time, and then asked me to hear his confession.",
     "No fim o Hollweg pediu para ver as linhas. Ficou lá muito tempo, e depois pediu-me que o ouvisse em confissão.",
     "Al final Hollweg pidió ver las líneas. Se quedó allí mucho tiempo, y luego me pidió que lo oyera en confesión.")
line("k_end1", "king", "Ferrer's report came to Rome in the spring. I read it twice.", "O relatório de Ferrer chegou a Roma na primavera. Li-o duas vezes.",
     "El informe de Ferrer llegó a Roma en la primavera. Lo leí dos veces.")
line("k_end_close", "king", "The city of gears was crippled that year. When the next report came it was still turning, a little slower.",
     "A cidade das engrenagens ficou aleijada nesse ano. Quando chegou o relatório seguinte ainda girava, um pouco mais devagar.",
     "La ciudad de engranajes quedó tullida ese año. Cuando llegó el informe siguiente aún giraba, un poco más despacio.")
line("k_end_held", "king", "The city of gears stood whole behind its wall. We had let it have a year, and its works had not stopped turning once.",
     "A cidade das engrenagens ficou inteira atrás da muralha. Tínhamos-lhe deixado um ano, e as suas oficinas não pararam de girar uma única vez.",
     "La ciudad de engranajes siguió entera tras su muralla. Le habíamos dejado un año, y sus talleres no dejaron de girar ni una vez.")
line("k_end_fresh", "king", "And all that year the swarm came down the rivers, while the army was in the south.",
     "E durante todo esse ano o enxame desceu os rios, enquanto o exército estava no sul.",
     "Y durante todo ese año el enjambre bajó por los ríos, mientras el ejército estaba en el sur.")
line("k_end_grown", "king", "The army went to both fires that year, the swarm first and then the city, and put out neither.", "O exército foi aos dois fogos nesse ano, primeiro o enxame e depois a cidade, e não apagou nenhum.",
     "El ejército fue a los dos fuegos aquel año, primero el enjambre y después la ciudad, y no apagó ninguno.")
line("k_end_c", "king", "That is not how it went. The siege held. Hear it again from Ferrer.", "Não foi assim que aconteceu. O cerco aguentou. Ouve outra vez da boca de Ferrer.",
     "No fue así como pasó. El asedio resistió. Óyelo otra vez de boca de Ferrer.")

# (a quick player is past the part a chatty line belongs to: those lines are dropped unseen once the next part begins)
for lid in ["n_pay", "n_dusk", "j_weak", "n_weak", "f_hollweg", "j_hollweg", "h_prisoner", "f_prisoner", "a_hello", "a_hello_few", "n_probe", "r_probe",
            "n_probe2", "n_probe3", "n_owls_camp", "r_charges", "n_lines_done"]:
    L[lid]["until"] = "part2"
for lid in ["f_night", "n_s1", "n_s2", "n_s3", "n_s3_grown", "f_log", "m_postern", "n_breach"]:
    L[lid]["until"] = "part3"

# ---- stills
M["stills"] = {
    "rome": {"image": STILL % "p01_01", "caption": T("Rome, the present. The King tells it.", "Roma, o presente. O Rei conta.", "Roma, el presente. El Rey lo cuenta.")},
    "lines": {"image": STILL % "d11_01", "caption": T("The siege lines before Concórdia, 2780.", "As linhas de cerco diante de Concórdia, 2780.",
                                                      "Las líneas de asedio ante Concórdia, 2780.")},
    "sortie": {"image": STILL % "d11_02", "caption": T("The sortie at dawn.", "A surtida ao amanhecer.", "La salida al amanecer.")},
    "walls": {"image": STILL % "d11_03", "caption": T("On the walls of Concórdia.", "Nas muralhas de Concórdia.", "En las murallas de Concórdia.")},
}
M["opening"] = {
    "crown": [{"still": "rome", "lines": ["k_open1", "k_open2"]},
              {"still": "lines", "lines": ["f_open1", {"id": "f_open_fresh", "if": FRESH}, {"id": "f_open_grown", "if": GROWN},
                                           {"id": "f_open_held", "if": {"all": [GROWN, JUNGLE_HELD]}}, {"id": "f_open_thin", "if": {"all": [GROWN, JUNGLE_THIN]}},
                                           {"id": "f_open_jakob", "if": JAKOB_ALIVE}, {"id": "f_open_nojakob", "if": JAKOB_LOST}]}],
    "city": [{"still": "rome", "lines": ["k_open_c"]}, {"still": "walls", "lines": ["cn_open"]}],
}
M["ending"] = {
    "crown": [
        {"still": "lines", "lines": [{"id": "f_end_close", "if": {"flag": {"siege": "close"}}}, {"id": "f_end_held", "if": {"flag": {"siege": "held_off"}}},
                                     {"id": "f_end_jakob", "if": {"flag": {"jakob": "alive"}}}, {"id": "f_end_nojakob", "if": {"flag": {"jakob": "lost"}}},
                                     {"id": "f_end_walls", "if": SPRING_RUNNING}, {"id": "f_end_prisoner", "if": SPRING_STOPPED}]},
        {"still": "rome", "lines": ["k_end1", {"id": "k_end_close", "if": {"flag": {"siege": "close"}}}, {"id": "k_end_held", "if": {"flag": {"siege": "held_off"}}},
                                    {"id": "k_end_fresh", "if": FRESH}, {"id": "k_end_grown", "if": GROWN}]},
    ],
    "city": [{"still": "walls", "lines": ["cn_won"]}, {"still": "rome", "lines": ["k_end_c"]}],
}
M["briefing"] = {
    "crown": {"still": "lines", "text": [
        T("The southern highlands, 2780. You are the army's southern column before Concórdia: Father Ferrer, Jakob, General Ruggieri's siege train, Musketeers and Guardsmen, Cuirassiers and the pioneers who dig.",
          "O planalto do sul, 2780. Você é a coluna do sul do exército diante de Concórdia: o Padre Ferrer, o Jakob, o trem de cerco do General Ruggieri, Mosqueteiros e Guardas, Couraceiros e os sapadores que cavam.",
          "El altiplano del sur, 2780. Eres la columna del sur del ejército ante Concórdia: el Padre Ferrer, Jakob, el tren de asedio del General Ruggieri, Mosqueteros y Guardias, Coraceros y los zapadores que cavan."),
        T("Dig the siege lines before the three gates, beat back the city's sorties, and keep the siege park's magazine standing.",
          "Cave as linhas de cerco diante dos três portões, repila as surtidas da cidade, e mantenha de pé o paiol do parque de cerco.",
          "Cava las líneas de asedio ante las tres puertas, rechaza las salidas de la ciudad, y mantén en pie el polvorín del parque de asedio."),
        T("If the city was fought first, its wall is unfinished: the old mine runs under it. If it waited a year, hold the road against everything it has.",
          "Se a cidade foi combatida primeiro, a muralha não está acabada: a mina velha passa por baixo dela. Se esperou um ano, aguente a estrada contra tudo o que ela tem.",
          "Si la ciudad fue combatida primero, su muralla está sin acabar: la mina vieja pasa por debajo. Si esperó un año, resiste en el camino contra todo lo que tiene.")]},
    "city": {"still": "walls", "text": [
        T("The southern highlands, 2780. You are Concórdia: its wall, its arsenal in the old Nuremberg quarter, its machines and the great spring on the mine hill.",
          "O planalto do sul, 2780. Você é Concórdia: a sua muralha, o seu arsenal no velho bairro de Nuremberga, as suas máquinas e a grande mola no monte da mina.",
          "El altiplano del sur, 2780. Eres Concórdia: su muralla, su arsenal en el viejo barrio de Núremberg, sus máquinas y el gran muelle en el monte de la mina."),
        T("Break the siege: blow the siege park's magazine in the Crown's camp, or bring down Father Ferrer, before the Crown's work is done.",
          "Quebre o cerco: exploda o paiol do parque de cerco no acampamento da Coroa, ou derrube o Padre Ferrer, antes que a Coroa acabe o seu trabalho.",
          "Rompe el asedio: vuela el polvorín del parque de asedio en el campamento de la Corona, o derriba al Padre Ferrer, antes de que la Corona acabe su trabajo.")]},
}
M["debrief"] = {
    "crown": {"still": "lines", "title": T("Concórdia", "Concórdia", "Concórdia"),
              "text": T("The siege of Concórdia, 2780.", "O cerco de Concórdia, 2780.", "El asedio de Concórdia, 2780."),
              "text_if": [
                  {"if": {"flag": {"siege": "close"}}, "text": T("The great spring's tower was blown from the old mine: the city is crippled and besieged.",
                                                                 "A torre da grande mola foi rebentada a partir da mina velha: a cidade está aleijada e cercada.",
                                                                 "La torre del gran muelle fue volada desde la mina vieja: la ciudad está tullida y sitiada.")},
                  {"if": {"flag": {"siege": "held_off"}}, "text": T("The army holds the road, but the city stands whole behind its wall.",
                                                                    "O exército guarda a estrada, mas a cidade está inteira atrás da muralha.",
                                                                    "El ejército guarda el camino, pero la ciudad sigue entera tras su muralla.")},
                  {"if": {"flag": {"jakob": "lost"}}, "text": T("Jakob is not with Father Ferrer.", "O Jakob não está com o Padre Ferrer.", "Jakob no está con el Padre Ferrer.")}]},
    "city": {"still": "walls", "title": T("The City", "A Cidade", "La Ciudad"),
             "text": T("The siege of Concórdia was broken.", "O cerco de Concórdia foi quebrado.", "El asedio de Concórdia fue roto.")},
}


# ================================================================== the triggers
def sortie(sid, when, gates, base, extra=(), delay=None, line_ids=None, to=None, every=None):
    """A sortie of the city (its team: the city's player's when he plays it) out of `gates`: `base` Clock Soldiers a gate
    (scaled by the difficulty), one fewer with d07 `spring` stopped (the city smaller: never under one); the `extra` spawns
    ([kind, count, condition]) at the first gate; ordered at the gate's battery (or `to`), wound from the plates."""
    sp = []
    for g in gates:
        tgt = to or BAT_OF[g]
        sp.append({"spawn": {"team": "city", "kind": "clock_soldier", "count": base, "at": IN_OF[g], "tag": "sortie", "tags": [sid, "c_all"],
                             "order": {"do": "attack", "to": tgt}, "if": SPRING_RUNNING}})
        sp.append({"spawn": {"team": "city", "kind": "clock_soldier", "count": max(1, base - 1), "at": IN_OF[g], "tag": "sortie", "tags": [sid, "c_all"],
                             "order": {"do": "attack", "to": tgt}, "if": SPRING_STOPPED}})
    for (k, n, c) in extra:
        g = gates[0]
        e = {"team": "city", "kind": k, "count": n, "at": IN_OF[g] if k != "ticking_owl" else "spring_top", "tag": "sortie", "tags": [sid, "c_all"],
             "order": {"do": "attack", "to": to or BAT_OF[g]}}
        if c is not None:
            e["if"] = c
        sp.append({"spawn": e})
    t = {"id": sid, "when": when, "do": sp + [{"wind": {"team": "city", "share": 1.0}}] + [{"ping": {"area": OUT_OF[g]}} for g in gates]
         + ([{"say": line_ids}] if line_ids else [])}
    if delay is not None:
        t["delay"] = delay
    if every is not None:
        t["every"] = every
    return t


def gate_hp(version, stopped):
    k = 0.75 if stopped else 1.0
    return int(GATE_HP[version] * k), int(BREACH_HP[version] * k)


TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"clock": {"name": "dusk", "secs": DUSK_SECS}},
        {"wind": {"team": "city", "share": 1.0}}, {"wind": {"team": "masters", "share": 1.0}},
        {"max_hp": {"tag": "spring", "hp": SPRING_HP}},
        {"spare": {"tag": "hollweg_w"}},
        {"order": {"tag": "garrison", "do": "hold"}}, {"order": {"tag": "city_winders", "do": "hold"}},
        {"objective": {"id": "jakob", "set": "active", "if": JAKOB_ALIVE}},
        {"counter": {"name": "dug_n", "count": {"tag": "earthworks"}}}]},
] + [
    # the wall's health by the version and d07 `spring` (the city smaller when stopped)
    {"id": "walls_%s_%s" % (v, "stopped" if st else "running"), "when": {"all": [{"fired": "setup"}, {"version": v},
                                                                                SPRING_STOPPED if st else SPRING_RUNNING]}, "do": [
        {"max_hp": {"tag": "gates", "hp": gate_hp(v, st)[0]}}, {"max_hp": {"tag": "breaches", "hp": gate_hp(v, st)[1]}}]}
    for v in ("fresh", "grown") for st in (False, True)
] + [
    # the weak gates: Jakob knows two (a04 `stopworks` found and Jakob alive), marked at the start
    {"id": "weak_found", "when": {"all": [{"fired": "setup"}, FOUND]}, "delay": 1, "do": [
        {"max_hp": {"tag": "g_north", "hp": int(GATE_HP["fresh"] * WEAK)}}, {"max_hp": {"tag": "g_south", "hp": int(GATE_HP["fresh"] * WEAK)}}]},
    {"id": "weak_found_g", "when": {"all": [{"fired": "weak_found"}, GROWN]}, "do": [
        {"max_hp": {"tag": "g_north", "hp": int(GATE_HP["grown"] * WEAK)}}, {"max_hp": {"tag": "g_south", "hp": int(GATE_HP["grown"] * WEAK)}}]},
    {"id": "weak_say", "when": {"all": [{"time": 14}, FOUND, CROWN, P1]}, "do": [
        {"say": ["j_weak", "n_weak"]}, {"ping": {"area": "north_out"}}, {"ping": {"area": "south_out"}}, {"objective": {"id": "breach", "set": "active"}}]},
    # the city's plates keep it wound (its player's too: the plates run under every street)
    {"id": "wind_city", "when": {"time": 4}, "every": 4, "do": [{"wind": {"team": "city", "share": 1.0}}, {"wind": {"team": "masters", "share": 1.0}}]},
    # the city's player: his objective, his lines, his cogs
    {"id": "setup_c", "when": {"all": [{"time": 0.6}, CITY_P]}, "do": [
        {"objective": {"id": "c_break", "set": "active"}}, {"say": ["cn_1", "cn_k7"]}, {"ping": {"area": "park"}}]},
    # the column's pay: a convoy up the valley road every half minute (the siege lasts; there is no farm on the plateau)
    {"id": "pay", "when": {"all": [{"time": PAY_EVERY}, LIVE]}, "every": PAY_EVERY, "do": [{"give": {"team": "column", "gold": PAY, "powder": 20}}]},
    {"id": "pay_say", "when": {"fired": "pay"}, "do": [{"say": ["n_pay"], "if": CROWN}]},
    {"id": "city_cogs", "when": {"all": [{"time": CITY_EVERY}, CITY_P, LIVE]}, "every": CITY_EVERY, "do": [{"give": {"team": "city", "gold": 20}}]},
    # ============================================================ PART 1: THE LINES
    {"id": "lines", "when": {"time": 2.0}, "do": [{"say": ["r_lines", "n_lines", "n_dusk"]}, {"ping": {"area": "earth_n"}}, {"ping": {"area": "earth_w"}},
                                                 {"ping": {"area": "earth_s"}}, {"reveal": {"area": "lines", "side": "crown"}}]},
    {"id": "valley_hi", "when": {"all": [{"time": 24}, CROWN, P1]}, "do": [{"say": ["a_hello"], "if": FOUGHT}, {"say": ["a_hello_few"], "if": PARLEY}]},
    {"id": "hollweg_seen", "when": {"all": [{"time": 34}, SPRING_RUNNING, CROWN, P1]}, "do": [
        {"say": ["f_hollweg"]}, {"say": ["j_hollweg"], "if": JAKOB_ALIVE}, {"ping": {"area": "hollweg_post"}}, {"reveal": {"area": "hollweg_post", "side": "crown", "secs": 20}}]},
    {"id": "hollweg_here", "when": {"all": [{"time": 34}, SPRING_STOPPED, CROWN, P1]}, "do": [{"say": ["h_prisoner", "f_prisoner"]}]},
    {"id": "charges_say", "when": {"all": [{"time": 52}, CROWN, P1]}, "do": [{"say": ["r_charges"]}, {"ping": {"tag": "c_armoury"}}]},
    {"id": "charges_done", "when": {"researched": {"team": "column", "tech": "charges"}}, "do": [
        {"objective": {"id": "charges", "set": "done"}}, {"say": ["n_charges_done"]}]},
    # the scripted column (the city played): its pioneers keep to the camp, its army holds the lines
    {"id": "col_hold", "when": {"all": [{"time": 1.0}, NO_CROWN]}, "do": [
        {"order": {"tag": "line", "do": "move", "to": "bat_w"}}, {"order": {"tag": "riders", "do": "move", "to": "camp_mid"}},
        {"order": {"tag": "guns", "do": "move", "to": "bat_w"}}, {"order": {"tag": "pioneers", "do": "move", "to": "camp_mid"}}]},
    {"id": "valley_hold", "when": {"time": 1.0}, "do": [{"order": {"tag": "militia", "do": "move", "to": "bat_s"}}, {"order": {"tag": "arruda", "do": "move", "to": "bat_s"}}]},
    # PROBES: a few machines at the diggers (the north battery, then the south)
    sortie("probe1", {"all": [{"time": 42}, P1, LIVE]}, ["north_gate"], 3, extra=[("springer", 1, HARD)], line_ids=["n_probe", "r_probe"]),
    sortie("probe2", {"all": [{"time": 90}, P1, LIVE]}, ["south_gate"], 3, extra=[("netter", 1, NORMAL_UP)], line_ids=["n_probe2"]),
    sortie("probe3", {"all": [{"time": 140}, P1, LIVE]}, ["west_gate"], 3, extra=[("springer", 1, None)], line_ids=["n_probe3"]),
    sortie("probe4", {"all": [{"time": 190}, P1, LIVE]}, ["north_gate"], 2, line_ids=["n_probe"]),
    # GROWN: the owls over the camp (the city sees everything)
    {"id": "owls_camp", "when": {"all": [{"time": 75}, GROWN, P1, LIVE]}, "do": [
        {"spawn": {"team": "city", "kind": "ticking_owl", "count": 2, "at": "spring_top", "tag": "sortie", "tags": ["owls_camp", "c_all"],
                   "order": {"do": "attack", "to": "camp_mid"}}},
        {"wind": {"team": "city", "share": 1.0}}, {"say": ["n_owls_camp"]}, {"ping": {"area": "camp_mid"}}]},
    {"id": "dug_count", "when": {"all": [{"fired": "setup"}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "dug_n", "count": {"tag": "earthworks"}}}]},
    {"id": "lines_done", "when": {"all": [{"done": "lines"}, P1]}, "do": [{"say": ["n_lines_done"]}, {"ping": {"tag": "guns"}}]},
    # ============================================================ PART 2: THE SORTIES (at nightfall; the lines dug or the clock out)
    {"id": "part2", "when": {"all": [{"any": [{"all": [{"fired": "lines_done"}, {"time": 60}]}, {"clock_out": "dusk"}]}, LIVE]}, "delay": 4, "do": [
        {"clock": {"name": "dusk", "stop": True}}, {"objective": {"id": "dusk", "set": "hidden"}},
        {"objective": {"id": "sorties", "set": "active"}}, {"objective": {"id": "dawn_clock", "set": "active"}},
        {"clock": {"name": "dawn", "secs": DAWN_SECS}},
        {"light": {"to": "night", "secs": 8}}, {"say": ["n_night"]}, {"say": ["f_night"], "if": CROWN}]},
    {"id": "lines_late", "when": {"all": [{"fired": "part2"}, {"not": {"done": "lines"}}]}, "do": [{"objective": {"id": "lines", "set": "hidden"}}]},
    {"id": "breach_on", "when": {"fired": "part2"}, "do": [{"objective": {"id": "breach", "set": "active"}}]},
    # (the logged stop-works, or Jakob lost: Ferrer reads the log by the lantern: the west gate)
    {"id": "read_log", "when": {"all": [{"fired": "part2"}, READ_LOG]}, "delay": 18, "do": [
        {"max_hp": {"tag": "g_west", "hp": int(GATE_HP["fresh"] * WEAK)}}, {"say": ["f_log"], "if": CROWN}, {"ping": {"area": "west_out"}}]},
    {"id": "read_log_g", "when": {"all": [{"fired": "read_log"}, GROWN]}, "do": [{"max_hp": {"tag": "g_west", "hp": int(GATE_HP["grown"] * WEAK)}}]},
    # (d07 `spring` stopped: the honest masters' postern opens for the Crown)
    {"id": "postern_say", "when": {"all": [{"fired": "part2"}, SPRING_STOPPED, CROWN]}, "delay": 30, "do": [
        {"say": ["m_postern"]}, {"ping": {"area": "postern_out"}}]},
    # THE THREE SORTIES
    sortie("s1", {"fired": "part2"}, ["west_gate"], 2, delay=8, line_ids=["n_s1"],
           extra=[("netter", 2, None), ("ticking_owl", 2, FRESH), ("ticking_owl", 4, GROWN)]),
    {"id": "s1_n", "when": {"fired": "s1"}, "do": [{"counter": {"name": "sortie_n", "set": 1}}]},
    sortie("s2", {"fired": "part2"}, ["north_gate", "south_gate"], 3, delay=8 + SORTIE_GAP, line_ids=["n_s2"],
           extra=[("springer", 2, None), ("springer", 1, GROWN)]),
    {"id": "s2_dawn", "when": {"fired": "s2"}, "do": [{"light": {"to": "dawn", "secs": 10}}, {"counter": {"name": "sortie_n", "set": 2}}]},
    sortie("s3", {"fired": "part2"}, ["west_gate"], 5, delay=8 + 2 * SORTIE_GAP, line_ids=["n_s3"],
           extra=[("pendulum", 1, NORMAL_UP), ("netter", 2, None), ("springer", 2, GROWN), ("ballista", 1, GROWN)]),
    {"id": "s3_n", "when": {"fired": "s3"}, "do": [{"counter": {"name": "sortie_n", "set": 3}}, {"say": ["n_s3_grown"], "if": GROWN}]},
    {"id": "more_c", "when": {"all": [{"any": [{"fired": "s1"}, {"fired": "s2"}, {"fired": "s3"}]}, CITY_P]}, "do": [{"say": ["cn_more"]}]},
    # the scripted sorties press their battery (the city's player leads his own)
    {"id": "sortie_press", "when": {"all": [{"fired": "setup"}, NO_CITY, LIVE]}, "every": 6, "do": [
        {"order": {"tag": "sortie", "do": "hunt", "prey_team": "column", "within": 12}}]},
    {"id": "sortie_owls", "when": {"all": [{"fired": "setup"}, NO_CITY, LIVE]}, "every": 5, "do": [
        {"order": {"tag": "sortie", "kind": "ticking_owl", "do": "hunt", "prey": "guns", "within": 60}}]},
    # NO WAITING: the third sortie out, the ones still outside come at the camp after 25 s (a player who keeps back)
    {"id": "s_charge", "when": {"all": [{"fired": "s3"}, {"not": {"fired": "sorties_done"}}, P2, NO_CITY, LIVE]}, "delay": 25, "times": 1, "do": [
        {"say": ["n_charge"]}, {"ping": {"area": "camp_mid"}}]},
    {"id": "s_charge_go", "when": {"all": [{"fired": "s_charge"}, {"not": {"fired": "sorties_done"}}, P2, NO_CITY, LIVE]}, "every": 8, "do": [
        {"order": {"tag": "sortie", "do": "attack", "to": "camp_mid", "idle": True}}]},
    # (the city's machines outside the wall, counted)
    {"id": "out_count", "when": {"all": [{"fired": "setup"}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "out_n", "count": {"team": "city", "area": "outside"}}}]},
    # a gate down: the way in is open (the breach objective)
    {"id": "breached", "when": {"all": [{"any": [{"dead": "g_north"}, {"dead": "g_west"}, {"dead": "g_south"}]}, LIVE]}, "do": [
        {"objective": {"id": "breach", "set": "done"}}, {"say": ["n_breach"]}]},
    # THE SORTIES BEATEN (the third in, fewer than three of the city's men outside) or full day: Part 3
    {"id": "sorties_done", "when": {"all": [{"fired": "s3"}, {"counter": {"name": "out_n", "below": 3}}, P2, LIVE]}, "delay": 3, "do": [
        {"objective": {"id": "sorties", "set": "done"}}, {"say": ["n_sorties_done"]}]},
    {"id": "full_day", "when": {"all": [{"clock_out": "dawn"}, {"not": {"fired": "sorties_done"}}, P2, LIVE]}, "do": [
        {"say": ["n_full_day"]}, {"objective": {"id": "sorties", "set": "done"}}, {"order": {"tag": "sortie", "do": "move", "to": "arsenal_mid"}}]},
    # JAKOB (NOT protected: he can fall here)
    {"id": "jakob_hurt", "when": {"all": [{"hp": {"tag": "jakob", "below": 0.5}}, CROWN]}, "times": 1, "do": [{"say": ["j_hurt"]}, {"ping": {"tag": "jakob"}}]},
    {"id": "jakob_down", "when": {"all": [{"fired": "setup"}, JAKOB_ALIVE, {"dead": "jakob"}, LIVE]}, "do": [
        {"say": ["n_jakob_down"]}, {"say": ["f_jakob_down"], "if": CROWN}, {"objective": {"id": "jakob", "set": "failed"}}]},
    {"id": "hurt_f", "when": {"all": [{"hp": {"tag": "ferrer", "below": 0.5}}, CROWN]}, "every": 60, "times": 2, "do": [{"say": ["f_hurt"]}, {"ping": {"tag": "ferrer"}}]},
    # ============================================================ PART 3
    {"id": "part3", "when": {"all": [{"any": [{"fired": "sorties_done"}, {"fired": "full_day"}]}, LIVE]}, "delay": 4, "do": [
        {"clock": {"name": "dawn", "stop": True}}, {"objective": {"id": "dawn_clock", "set": "hidden"}}, {"objective": {"id": "sorties", "set": "hidden"}},
        {"light": {"to": "day", "secs": 8}}]},
    # ---- FRESH: THE MINE
    {"id": "mine_on", "when": {"all": [{"fired": "part3"}, FRESH]}, "do": [
        {"objective": {"id": "mine", "set": "active"}}, {"say": ["n_mine"]}, {"ping": {"area": "mine_mouth"}}, {"reveal": {"area": "mine_near", "side": "crown"}},
        {"say": ["j_mine"], "if": JAKOB_ALIVE}, {"say": ["h_mine"], "if": {"all": [JAKOB_LOST, SPRING_STOPPED]}},
        {"say": ["f_mine"], "if": {"all": [JAKOB_LOST, SPRING_RUNNING]}}, {"say": ["cn_mine"], "if": CITY_P}]},
    # (no pioneer left: three more from the baggage)
    {"id": "reserve", "when": {"all": [{"fired": "mine_on"}, {"count": {"tag": "pioneers", "below": 2}}, {"not": {"fired": "sap_go"}}, LIVE]}, "do": [
        {"spawn": {"team": "column", "kind": "labourer", "as": "pioneer", "count": 3, "at": "camp_mid", "tag": "pioneers", "fixed": True}},
        {"say": ["n_reserve"], "if": CROWN}]},
    # (the scripted column, the city played: its pioneers go to the mouth by themselves)
    {"id": "mine_go_s", "when": {"all": [{"fired": "mine_on"}, NO_CROWN]}, "delay": 3, "every": 6, "do": [
        {"order": {"tag": "pioneers", "do": "move", "to": "mine_mouth"}}]},
    # two at the mouth for 3 s: down they go, all the pioneers (the old galleries: SAPPING), under the wall to the spring
] + [
    {"id": "sap_go" if d == "normal" else "sap_go_" + d, "when": {"all": [{"fired": "mine_on"}, {"difficulty": d},
                                                                            {"stay": {"tag": "pioneers", "area": "mine_mouth", "count": 2, "secs": 3}}, LIVE]
                                                                    + ([{"not": {"fired": "sap_go"}}] if d != "normal" else [])}, "do": [
        {"sap": {"tag": "pioneers", "to": "spring_foot", "secs": SAP_SECS[d], "name": "mine",
                 "blast": {"tag": "spring", "amount": 99999, "within": 6}}},
        {"clock": {"name": "mine", "secs": SAP_SECS[d], "scale": False}}]}
    for d in ("normal", "easy", "hard")
] + [
    {"id": "sap_said", "when": {"any": [{"fired": "sap_go"}, {"fired": "sap_go_easy"}, {"fired": "sap_go_hard"}]}, "do": [
        {"objective": {"id": "mine", "set": "done"}}, {"objective": {"id": "mine_clock", "set": "active"}}, {"say": ["n_under", "r_under"]}]},
    # (nobody sent down: the city does not wait either; it comes out at the camp until the pioneers go down: NO WAITING)
    sortie("m_wait", {"all": [{"fired": "mine_on"}, {"not": {"fired": "sap_said"}}, LIVE]}, ["north_gate", "west_gate"], 2, delay=40, every=40,
           to="camp_mid", extra=[("springer", 1, None)], line_ids=["n_wait"]),
    # THE GREAT SORTIE at the mouth while they are under the ground
    sortie("m1", {"fired": "sap_said"}, ["north_gate"], 4, delay=4, to="mine_near", extra=[("springer", 2, None), ("netter", 1, NORMAL_UP)],
           line_ids=None),
    sortie("m2", {"fired": "sap_said"}, ["west_gate", "north_gate"], 3, delay=24, to="mine_near", extra=[("pendulum", 1, HARD), ("springer", 1, None)]),
    {"id": "m_press", "when": {"all": [{"fired": "sap_said"}, NO_CITY, LIVE, {"not": {"fired": "spring_down"}}]}, "every": 5, "do": [
        {"order": {"tag": "sortie", "do": "attack", "to": "mine_near", "idle": True}}]},
    # THE SPRING FALLS (the mine's blast, or the guns: either way)
    {"id": "spring_down", "when": {"all": [{"dead": "spring"}, LIVE]}, "do": [
        {"brake": {"team": "city", "name": "spring"}}, {"say": ["n_spring_down"]}, {"say": ["f_spring1", "f_spring2"], "if": CROWN},
        {"say": ["cn_lost_spring"], "if": CITY_P}, {"clock": {"name": "mine", "stop": True}}, {"objective": {"id": "mine_clock", "set": "hidden"}}]},
    {"id": "come_back", "when": {"sapped": "mine"}, "delay": 2, "do": [
        {"sap": {"tag": "pioneers", "to": "mine_mouth", "secs": 10, "name": "back"}}]},
    {"id": "back_say", "when": {"sapped": "back"}, "do": [{"say": ["n_back"]}]},
    {"id": "close", "when": {"all": [{"fired": "spring_down"}, {"any": [{"sapped": "back"}, {"not": {"any": [{"fired": "sap_go"}, {"fired": "sap_go_easy"},
                                                                                                            {"fired": "sap_go_hard"}]}}]}, LIVE]},
     "delay": 4, "do": [{"flag": {"siege": "close"}}]},
    # ---- GROWN: THE GREAT SORTIE (the galleries are the city's)
    {"id": "hold_on", "when": {"all": [{"fired": "part3"}, GROWN]}, "do": [
        {"objective": {"id": "hold", "set": "active"}}, {"objective": {"id": "relief", "set": "active"}}, {"objective": {"id": "diggers", "set": "active"}},
        {"clock": {"name": "relief", "secs": RELIEF_SECS}}, {"clock": {"name": "diggers", "secs": DIG_SECS}},
        {"say": ["n_hold"]}, {"say": ["j_dig"], "if": JAKOB_ALIVE}, {"say": ["f_dig"], "if": JAKOB_LOST}, {"say": ["n_diggers"], "if": CROWN},
        {"ping": {"area": "park_near"}}, {"reveal": {"area": "mine_near", "side": "crown"}},
        # the city's diggers go down from the spring yard (under the wall, to the camp)
        {"spawn": {"team": "city", "kind": "clock_soldier", "count": 3, "at": "spring_foot", "tag": "diggers", "tags": ["c_all"]}},
        {"spawn": {"team": "city", "kind": "springer", "count": 2, "at": "spring_foot", "tag": "diggers", "tags": ["c_all"]}}]},
    {"id": "dig_go", "when": {"fired": "hold_on"}, "delay": 1, "do": [
        {"sap": {"tag": "diggers", "to": "park_near", "secs": DIG_SECS - 1, "name": "diggers", "blast": {"tag": "park", "amount": 220, "within": 6}}}]},
    {"id": "dig_up", "when": {"sapped": "diggers"}, "do": [
        {"say": ["n_up"]}, {"ping": {"area": "park_near"}}, {"objective": {"id": "diggers", "set": "hidden"}}, {"clock": {"name": "diggers", "stop": True}},
        {"wind": {"team": "city", "share": 1.0}}, {"retag": {"tag": "diggers", "as": "sortie"}}]},
    sortie("g1", {"fired": "hold_on"}, ["north_gate", "west_gate"], 3, delay=8, to="camp_mid", extra=[("springer", 1, None)]),
    sortie("g2", {"fired": "hold_on"}, ["south_gate"], 4, delay=55, to="camp_mid", extra=[("netter", 1, None), ("pendulum", 1, NORMAL_UP)], line_ids=["n_wave"]),
    sortie("g3", {"fired": "hold_on"}, ["north_gate", "west_gate", "south_gate"], 2, delay=100, to="camp_mid",
           extra=[("ballista", 1, None), ("pendulum", 1, NORMAL_UP), ("springer", 1, None)], line_ids=["n_wave_big"]),
    sortie("g4", {"fired": "hold_on"}, ["west_gate"], 2, delay=140, to="park", extra=[("ticking_owl", 2, None), ("netter", 1, NORMAL_UP)], line_ids=["n_wave"]),
    {"id": "g_press", "when": {"all": [{"fired": "hold_on"}, NO_CITY, LIVE]}, "every": 6, "do": [
        {"order": {"tag": "sortie", "do": "attack", "to": "park", "idle": True}}]},
    {"id": "held_off", "when": {"all": [{"clock_out": "relief"}, {"fired": "hold_on"}, LIVE]}, "do": [
        {"say": ["n_dusk_end"]}, {"say": ["f_grown_end"], "if": CROWN}, {"say": ["cn_lost_dusk"], "if": CITY_P},
        {"light": {"to": "dusk", "secs": 6}}, {"order": {"tag": "sortie", "do": "move", "to": "arsenal_mid"}}, {"flag": {"siege": "held_off"}},
        {"objective": {"id": "hold", "set": "done"}}]},
    # ============================================================ THE END
    # the Crown's work done (the spring blown, or dusk held): WON for the Crown, LOST for the city's player
    {"id": "jakob_flag", "when": {"all": [{"any": [{"fired": "close"}, {"fired": "held_off"}]}, {"count": {"tag": "jakob", "at_least": 1}}]}, "do": [
        {"flag": {"jakob": "alive"}}, {"objective": {"id": "jakob", "set": "done"}}]},
    {"id": "jakob_flag_l", "when": {"all": [{"any": [{"fired": "close"}, {"fired": "held_off"}]}, {"count": {"tag": "jakob", "below": 1}}]}, "do": [{"flag": {"jakob": "lost"}}]},
    {"id": "the_end", "when": {"any": [{"fired": "close"}, {"fired": "held_off"}]}, "delay": 4, "do": [
        {"objective": {"id": "c_break", "set": "failed"}},
        {"win": "crown"}]},
    # THE SIEGE PARK'S MAGAZINE GOES UP, or Father Ferrer brought down by the city's player: lost (the city's win)
    {"id": "lost_park", "when": {"all": [{"dead": "park"}, NO_CITY, {"not": {"fired": "the_end"}}]}, "do": [
        {"say": ["n_park_down"]}, {"objective": {"id": "park", "set": "failed"}}, {"lose": "crown"}]},
    {"id": "c_won", "when": {"all": [{"any": [{"dead": "park"}, {"dead": "ferrer"}]}, CITY_P, {"not": {"fired": "the_end"}}]}, "do": [
        {"objective": {"id": "c_break", "set": "done"}}, {"objective": {"id": "park", "set": "failed"}}]},
    {"id": "c_won_ferrer", "when": {"all": [{"fired": "c_won"}, {"dead": "ferrer"}]}, "do": [{"say": ["cn_ferrer"]}]},
    {"id": "c_won_park", "when": {"all": [{"fired": "c_won"}, {"dead": "park"}]}, "do": [{"say": ["cn_won"]}]},
    {"id": "c_won_end", "when": {"fired": "c_won"}, "delay": 2, "do": [{"win": "city"}]},
]

# (an "if" inside an action's dictionary is not read by the engine: split those into triggers of their own)
fixed = []
for t in TR_:
    plain, cond_acts = [], []
    for a in t["do"]:
        if isinstance(a, dict) and "if" in a and "spawn" not in a:
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

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the column is bound to C9 (PREPARED CHARGES and the GUNNER'S
# QUADRANT); the story's refusals on top (a siege camp: no halls, no farms, no new magazine; the balloon is the jungle
# front's rung, C8, never given here whichever front comes first); the city (the solo pick, versus) is bound to K7 (the
# SPRING BALLISTA and LONG CHAIN), with no new tower or presses of its own (its plates keep it wound)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID, story_deny={"column": ["town_hall", "farm", "church", "missionary", "balloon", "labourer", "messenger", "powder_mill"]})
roster_ladder.apply(M, MID, story_deny={"city": ["clocktower", "cog_press", "mainspring"]}, faction="clockwork")
for k in ("charges", "quadrant", "ballista", "long_chain"):
    T(M["lines"]["new_" + k]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hub talks after d11 (campaign/campaign.json), the war map's line
OTHER = [
    ("Father Ferrer", "Padre Ferrer", "Padre Ferrer"),
    ("Jakob", "Jakob", "Jakob"),
    ("Meister Hollweg", "Mestre Hollweg", "Maestro Hollweg"),
    ("Father Ferrer, old now, sent by Rome to the siege of Concórdia as its witness.", "O Padre Ferrer, já velho, mandado por Roma ao cerco de Concórdia como sua testemunha.",
     "El Padre Ferrer, ya viejo, enviado por Roma al asedio de Concórdia como su testigo."),
    ("Jakob, Hollweg's old journeyman: he hears the city's ticking.", "O Jakob, o velho aprendiz de Hollweg: ouve o tiquetaque da cidade.",
     "Jakob, el viejo oficial de Hollweg: oye el tictac de la ciudad."),
    ("A pioneer of the siege train: he digs the earthworks and the mines.", "Um sapador do trem de cerco: cava as trincheiras e as minas.",
     "Un zapador del tren de asedio: cava las trincheras y las minas."),
    ("Meister Hollweg, with the Crown's column: a prisoner who asked to come.", "O Mestre Hollweg, com a coluna da Coroa: um prisioneiro que pediu para vir.",
     "El Maestro Hollweg, con la columna de la Corona: un prisionero que pidió venir."),
    ("Meister Hollweg on the wall of his city, by the great spring.", "O Mestre Hollweg na muralha da sua cidade, junto à grande mola.",
     "El Maestro Hollweg en la muralla de su ciudad, junto al gran muelle."),
    # the King's study after d11 (campaign.json)
    ("Ferrer blew the great spring from under its own hill. The city limps now. It does not stop.",
     "Ferrer rebentou a grande mola por baixo do seu próprio monte. A cidade coxeia agora. Não para.",
     "Ferrer voló el gran muelle desde debajo de su propio monte. La ciudad cojea ahora. No se para."),
    ("Ferrer held the road a whole year before that wall. The city stood whole behind it, and grew.",
     "Ferrer guardou a estrada um ano inteiro diante daquela muralha. A cidade ficou inteira atrás dela, e cresceu.",
     "Ferrer guardó el camino un año entero ante aquella muralla. La ciudad siguió entera tras ella, y creció."),
    ("Concórdia, the siege. The great spring's tower blown from the old mine. The city crippled, not taken.",
     "Concórdia, o cerco. A torre da grande mola rebentada a partir da mina velha. A cidade aleijada, não tomada.",
     "Concórdia, el asedio. La torre del gran muelle volada desde la mina vieja. La ciudad tullida, no tomada."),
    ("Concórdia, the siege. The great sortie held. The road is ours, the city still its own.",
     "Concórdia, o cerco. A grande surtida foi contida. A estrada é nossa, a cidade ainda é dela.",
     "Concórdia, el asedio. La gran salida fue contenida. El camino es nuestro, la ciudad aún es suya."),
    # the Clockmaker's hub after d11 (Hollweg)
    ("They brought the Crown's guns up the plateau. I stood on the wall by the spring and listened. The city did not tick any faster. It was not afraid.",
     "Trouxeram os canhões da Coroa para o planalto. Fiquei na muralha junto à mola e escutei. A cidade não acelerou o tiquetaque. Não tinha medo.",
     "Subieron los cañones de la Corona al altiplano. Me quedé en la muralla junto al muelle y escuché. La ciudad no aceleró su tictac. No tenía miedo."),
    ("I went up with Father Ferrer to the siege of my own city. I showed them the old shaft. Then I asked him to hear my confession.",
     "Subi com o Padre Ferrer ao cerco da minha própria cidade. Mostrei-lhes o poço velho. Depois pedi-lhe que me ouvisse em confissão.",
     "Subí con el Padre Ferrer al asedio de mi propia ciudad. Les mostré el pozo viejo. Luego le pedí que me oyera en confesión."),
    # the war map
    ("The city broke the siege's batteries: not how it went.", "A cidade quebrou as baterias do cerco: não foi assim que aconteceu.",
     "La ciudad rompió las baterías del asedio: no fue así como pasó."),
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
rows = ["# Act 2's d11_siege, \"The Siege of Concórdia\" (campaign/missions/d11_siege.json, written with its texts by",
        "# tools/campaign/make_d11_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what was",
        "# built: docs/campaign_d11_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: siege park = parque de cerco /",
        "# parque de asedio; earthworks = trincheiras / trincheras; pioneer = sapador / zapador; great spring = grande mola / gran",
        "# muelle; postern = poterna.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
