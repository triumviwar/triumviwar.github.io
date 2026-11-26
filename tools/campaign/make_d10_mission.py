#!/usr/bin/env python3
"""Writes campaign/missions/d10_jungle.json: Act 2's "The Jungle Front" (Óbidos and the lower Amazon, 2780; the
crossing's branch against the swarm, after d09_crossroads; the plan: docs/campaign_act2_plan.md "d10_jungle"; what was
built: docs/campaign_d10_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d10_jungle.txt: every text here
is written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d10_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_obidos_front_map.py (campaign:obidos_front). EVERY LINE IS A PLACEHOLDER for the owner.

THE BROOD IS NOT A PERSON and LINNEA OK, NO REASONS (owner 2026-11-19 / 2026-11-22 / 2026-11-24): the swarm is animals
rooted on a river. People say what they see ("they root where the bank is dry"); no creature gets a name, a reason, a
want or a plan. Valadares tells it from his report (as in a03 and d08); the King frames it.

TWO VERSIONS by d09 `first` (THE CROSSING'S CHOICE: no canon; act2-engine0's "versions"):
  FRESH (the swarm first): the swarm still young below the Barra: two forward Mothers (three with d05 `fields` left);
  GROWN (the city first: d11 fought before): it spread down the rivers while the army was in the south: four (five with
    `fields` left), Challengers, Mist Toads laying FOG over their Mothers, Hatchlings after the balloon; the column comes
    north with the siege train's science (C9 researched) and a Mortar.
  THE JUNGLE COLUMN (Crown, PURPLE, p1): VALADARES (a hero), FATHER INÁCIO LOURENÇO (proposed: THE BALLOONIST,
    docs/campaign_worldwide_plan.md) in his own balloon (a hero), Musketeers and Guardsmen with the C5 / C7 kit,
    Dragoons, two Field Cannons, a Powder Wagon; NEW (THE ROSTER LADDER's C8): THE OBSERVATION BALLOON.
  ÓBIDOS' GARRISON (Crown, BLUE: co-op p2, else scripted holding): the captain, the fort (its keep must stand), two guns.
  THE SWARM (Brood, GREEN): scripted in the solo game; the SOLO PICK; versus p2. Bound to B7 (MIST TOAD, FOG, MIASMA).
  PART 0 (a RECLAIM PART, owner question 6): with d08's seal broken (the swarm took the Barra) or GROWN with d08 `barra`
    burned: the swarm holds Óbidos' upriver battery; retake it (the Barra's survivors join).
  PART 1, THE NARROWS: the forest dark under the canopy (THE UNMAPPED: d04's chart, here the fog on the river); hold
    Óbidos against two raids while the balloon goes up and over the river: Inácio sees, THE FOG LIFTS (a show).
  PART 2, THE NESTS: break every forward Mother before the rains (a countdown); waves come down the levee from every
    Mother still rooted; d08 `lure` used: the lure works ONCE more (a wave drawn under the guns).
  PART 3, THE ISLAND: cross to Lindqvist's old island and break the swarm's oldest ground (the old mound and its
    Rootmaws); THE LAST WAVE comes down the levee (one more with the lure used: they come to the smell of it).
  CARRIES: `jungle` held / thin (every nest broken before the rains), `island` burned / standing, `inacio` joined,
    `reclaim` barra (the battery retaken).
  MIRROR (THE SWARM, solo pick; versus): keep two forward Mothers alive until the dry season, or break Óbidos' fort.
"""
import json
import os
import sys
import glob

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d10_jungle"

TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d10_jungle.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
FRESH = {"version": "fresh"}
GROWN = {"version": "grown"}
FIELDS_BURNED = past("d05_aldeia.fields", "burned")            # the swarm starved on the Tapajós: one forward Mother fewer
FIELDS_LEFT = {"not": FIELDS_BURNED}                           # (the canon: LEFT: one more)
LURE_USED = past("d08_rivers.lure", "used")                   # the lure works ONCE more, then one wave more at the end
BARRA_BURNED = past("d08_rivers.barra", "burned")
SEAL_BROKEN = {"won_by": {"d08_rivers": "swarm"}}             # (d08's mirror won: the Barra lost: THE RECLAIM PART)
RECLAIM = {"any": [SEAL_BROKEN, {"all": [GROWN, BARRA_BURNED]}]}
NO_RECLAIM = {"not": RECLAIM}
DRAWN = notpast("a03_plateau.map", "withheld")               # Valadares knows the swarm's road up the creeks
WITHHELD = past("a03_plateau.map", "withheld")
BN_FEW = past("d06_queen.brood_n", "few")
BN_ALL = past("d06_queen.brood_n", "all")
NOT_BN_FEW = {"not": BN_FEW}
BURNED_CLUTCH = past("b01_specimen.clutch", "burned")          # no Tyrant Sire in the last wave
NOT_BURNED_CLUTCH = {"not": BURNED_CLUTCH}
COLUMN = {"playing": "column"}
NO_COLUMN = {"not": COLUMN}
SWARM = {"playing": "swarm"}
NO_SWARM = {"not": SWARM}
SOLO_C = {"all": [COLUMN, NO_SWARM]}                          # the solo column: the waves are scripted
ENDED = [{"fired": "the_end"}, {"fired": "s_end"}, {"fired": "vs_end"}]
LIVE = {"not": {"any": ENDED}}
P1 = {"not": {"fired": "part2"}}
P2 = {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}]}

# ---------------------------------------------------------------- numbers
RAIDS = [(20, "m1"), (55, "m2")]   # Part 1: raids at Óbidos' west gate (seconds, from which Mother)
LIFT_LATE = 220            # Part 1: the fog lifts anyway this late (a canoe brings word: NO WAITING for a lazy balloon)
WAVE_FIRST, WAVE_EVERY, WAVES_MAX = 35, 55, 10     # Part 2: the waves from the Mothers still rooted
NESTS_FRESH, NESTS_GROWN = 360, 540                # Part 2: the rains come back (NORMAL; EASY x1.25, HARD x0.85)
LW_LATE = 140              # Part 3: the last wave comes this long after Part 3 began if the island still stands
EBB_SECS = 150             # Part 3: the last wave ebbs (not scaled: a longer wait is no easier)
TOAD_EVERY = 14            # GROWN: the scripted Toads lay their fog this often with the column near
SC_GO, SC_REINF, SC_MARCH = 150, 120, 12
SC_FRESH_LATE = 90   # FRESH: three young nests; the column waits longer for its boats before it marches   # the mirror: the scripted column sets out; boats bring four men this often
DRY_SECS = 900             # the mirror / versus: the dry season (scaled)
SWARM_FOOD, SWARM_SPOILS = 500, 60
RIVER_FOOD, RIVER_SPOILS = 60, 4  # ... and every 10 s (the flood's drowned game)
PAY_GOLD, PAY_POWDER, CHEST_GOLD = 30, 10, 250   # the column's pay by Ruggieri's boats (every 20 s; a chest at Part 2)
MOTHER_HP, MOTHER_HP_FRESH = 1600, 2200   # (FRESH: fewer Mothers, each harder to break)
MOTHER_HP_MIRROR = 5000   # (the swarm played: its Mothers are its whole game)
LOOK_SECS = 30            # Part 1: the balloon stays over the river this long while Father Inácio looks and counts

# ================================================================== the areas (x, y, w, h in cells)
SITES = {"m1": (80, 40), "m2": (58, 40), "m3": (57, 10), "m4": (20, 28), "m5": (9, 44)}
areas = dict(
    obidos=[110, 26, 31, 30], obidos_mid=[118, 32, 14, 10], col_start=[113, 44, 7, 6], west_gate=[106, 49, 5, 6],
    guns_o1=[119, 52, 2, 2], guns_o2=[133, 52, 2, 2], keep_go=[120, 40, 8, 6], gar_in=[113, 49, 5, 5],
    killground=[100, 47, 8, 8], lure_spot=[96, 50, 3, 3], battery=[92, 42, 8, 7], battery_top=[93, 43, 5, 4],
    landing=[112, 57, 28, 2], landing_e=[134, 57, 6, 2],
    levee_e=[96, 49, 6, 5], levee_m=[70, 49, 8, 5], levee_w=[36, 49, 8, 5], levee_far=[16, 49, 8, 5], lw_stage=[5, 50, 12, 5],
    island=[44, 62, 52, 17], isl_ruins=[62, 67, 12, 7], isl_w=[46, 67, 8, 6], isl_e=[84, 67, 8, 6],
    ford_w=[50, 56, 6, 10], ford_e=[82, 56, 6, 10], ford_w_n=[49, 52, 8, 4],
    lookout=[54, 58, 28, 20], west_sky=[4, 20, 36, 34],
    known_start=[88, 26, 56, 34], creek_road=[62, 0, 12, 50], seen_river=[0, 46, 112, 40], seen_creeks=[40, 0, 40, 46],
    south_bank=[0, 86, 144, 10],
)
for k, (cx, cy) in SITES.items():
    areas[k] = [cx - 6, cy - 5, 12, 10]
    areas[k + "_spot"] = [cx - 1, cy - 1, 3, 3]

# which sites stand in which game (conditions): m1, m2 always; m3 FRESH with the fields left (or the swarm played: it
# keeps two of three), always GROWN; m4 GROWN; m5 GROWN with the fields left
SITE_IF = {
    "m1": None, "m2": None,
    "m3": {"any": [GROWN, FIELDS_LEFT, SWARM]},
    "m4": GROWN,
    "m5": {"all": [GROWN, FIELDS_LEFT]},
}

# ================================================================== the units
KIT = {"lock": "matchlock", "bayonet": True}
COL = {"team": "column", "at": "col_start", "fixed": True}
units = [
    # ---- the jungle column (the player): Valadares and Father Inácio (heroes), the line, the riders, the guns
    dict(COL, kind="dismounted", **{"as": "valadares", "count": 1, "tag": "valadares", "tags": ["leaders"]}),
    dict(COL, kind="balloon", **{"as": "inacio", "count": 1, "tag": "inacio", "tags": ["balloons"]}),
    dict(COL, kind="musketeer", count=8, tag="line", kit=KIT),
    dict(COL, kind="musketeer", count=4, tag="line", tags=["armoured"], kit=dict(KIT, armour=True)),
    dict(COL, kind="dragoon", count=3, tag="riders"),
    dict(COL, kind="cannon", count=2, tag="guns"),
    dict(COL, kind="powder_wagon", count=1, tag="wagons"),
    # (GROWN: the column comes north after the siege: two more Guardsmen and the siege train's Mortar)
    dict(COL, kind="musketeer", count=2, tag="line", tags=["armoured"], kit=dict(KIT, armour=True), **{"if": GROWN}),
    dict(COL, kind="mortar", count=1, tag="guns", **{"if": GROWN}),
    # ---- Óbidos' garrison (co-op p2): the captain, the gate, the two guns over the narrows
    {"team": "garrison", "kind": "dismounted", "as": "obidos_captain", "count": 1, "at": "keep_go", "tag": "captain", "fixed": True},
    {"team": "garrison", "kind": "musketeer", "count": 8, "at": "gar_in", "tag": "garrison", "fixed": True, "kit": KIT},
    {"team": "garrison", "kind": "cannon", "count": 1, "at": "guns_o1", "tag": "fort_guns", "fixed": True},
    {"team": "garrison", "kind": "cannon", "count": 1, "at": "guns_o2", "tag": "fort_guns", "fixed": True},
    # (GROWN: one of the siege train's guns left at Óbidos' gate)
    {"team": "garrison", "kind": "cannon", "count": 1, "at": "gar_in", "tag": "fort_guns", "fixed": True, "if": GROWN},
    # (the swarm played alone: the column has a few more and Óbidos' whole company)
    {"team": "garrison", "kind": "musketeer", "count": 4, "at": "gar_in", "tag": "garrison", "fixed": True, "kit": KIT, "if": NO_COLUMN},

]
# ---- the swarm: the forward Mothers rooted on their sites, their guards (both games)
for k, c in SITE_IF.items():
    base = {"team": "swarm", "at": k + "_spot"}
    cond = c
    def wif(extra=None):
        cs = [x for x in (cond, extra) if x]
        return {} if not cs else {"if": cs[0] if len(cs) == 1 else {"all": cs}}
    units += [
        dict(base, kind="brood_mother", **{"as": "river_mother", "count": 1, "tag": "fwd_" + k, "tags": ["fwd", "mothers"], "fixed": True}, **wif()),
        dict(base, kind="raptor", count=3, at=k, tag="guard_" + k, tags=["guards", "swarm_all"], **wif()),
        dict(base, kind="spitter", count=2, at=k, tag="guard_" + k, tags=["guards", "swarm_all"], **wif()),
        dict(base, kind="tyrant_challenger", count=1, at=k, tag="guard_" + k, tags=["guards", "swarm_all"], **wif({"all": [GROWN, NO_SWARM]})),
    ]
units += [
    # GROWN: Mist Toads by three of the Mothers (scripted: they lay their fog when the column comes)
    {"team": "swarm", "kind": "mist_toad", "count": 1, "at": "m1", "tag": "toads", "tags": ["swarm_all"], "fixed": True, "if": {"all": [GROWN, NO_SWARM]}},
    {"team": "swarm", "kind": "mist_toad", "count": 1, "at": "m2", "tag": "toads", "tags": ["swarm_all"], "fixed": True, "if": {"all": [GROWN, NO_SWARM]}},
    {"team": "swarm", "kind": "mist_toad", "count": 1, "at": "m4", "tag": "toads", "tags": ["swarm_all"], "fixed": True, "if": {"all": [GROWN, NO_SWARM]}},
    # ---- THE ISLAND: the swarm's oldest ground on the fazenda's ruins: the old mound, its Rootmaws, a guard
    {"team": "swarm", "kind": "mound_turtle", "as": "old_mound", "count": 1, "at": "isl_ruins", "tag": "old_mound", "tags": ["isl_ground"], "fixed": True},
    {"team": "swarm", "kind": "rootmaw", "count": 3, "at": "isl_ruins", "tag": "isl_maws", "tags": ["isl_ground"], "fixed": True},
    {"team": "swarm", "kind": "raptor", "count": 4, "at": "isl_ruins", "tag": "isl_guard", "tags": ["swarm_all"]},
    {"team": "swarm", "kind": "spitter", "count": 2, "at": "isl_ruins", "tag": "isl_guard", "tags": ["swarm_all"], "if": GROWN},
    {"team": "swarm", "kind": "venom_challenger", "count": 1, "at": "isl_ruins", "tag": "isl_guard", "tags": ["swarm_all"], "if": GROWN},
    # ---- THE RECLAIM PART: the swarm on Óbidos' upriver battery (the Barra lost)
    {"team": "swarm", "kind": "raptor", "count": 5, "at": "battery_top", "tag": "bat_swarm", "tags": ["swarm_all"], "if": {"all": [RECLAIM, NO_SWARM]}},
    {"team": "swarm", "kind": "spitter", "count": 2, "at": "battery_top", "tag": "bat_swarm", "tags": ["swarm_all"], "if": {"all": [RECLAIM, NO_SWARM]}},
    {"team": "swarm", "kind": "tyrant_challenger", "count": 1, "at": "battery_top", "tag": "bat_swarm", "tags": ["swarm_all"], "if": {"all": [RECLAIM, NO_SWARM]}},
    # ---- the mirror: the swarm's player's own pieces (the Sires rooted by two Mothers, grubs, raiders, a Toad)
    {"team": "swarm", "kind": "tyrannosaur", "count": 1, "at": "m1", "tag": "sire_t", "tags": ["sires"], "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "dilophosaurus", "count": 1, "at": "m2", "tag": "sire_v", "tags": ["sires"], "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "grub", "count": 4, "at": "m2", "tag": "grubs", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "raptor", "count": 6, "at": "m2", "tag": "raiders", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "spitter", "count": 3, "at": "m2", "tag": "raiders", "fixed": True, "if": SWARM},
    {"team": "swarm", "kind": "mist_toad", "count": 1, "at": "m2", "tag": "s_toads", "fixed": True, "if": SWARM},
]

# ================================================================== the buildings: Óbidos on its bluff
WALLS = [((111, y), y in (51, 52)) for y in range(43, 56)]
buildings = [
    {"team": "garrison", "kind": "town_hall", "at": [121, 41], "tag": "keep", "tags": ["obidos_b"],
     "name": T("The Fort of Óbidos", "O Forte de Óbidos", "El Fuerte de Óbidos")},
    {"team": "garrison", "kind": "church", "at": [114, 30], "tag": "church_o", "tags": ["obidos_b"],
     "name": T("Óbidos' church", "A igreja de Óbidos", "La iglesia de Óbidos")},
    # the column's depot in the fort (the army's own: it trains here, as d09's): the Barracks, the Foundry (guns, wagons and
    # balloons), the horse lines (the guns' teams), and the quarters (its supply)
    {"team": "column", "kind": "barracks", "at": [130, 34], "tag": "depot", "tags": ["barracks"]},
    {"team": "column", "kind": "foundry", "at": [131, 44], "tag": "depot", "tags": ["foundry"]},
    {"team": "column", "kind": "horse_breeder", "at": [134, 38], "tag": "depot", "tags": ["breeder"]},
] + [
    {"team": "column", "kind": "cottage", "at": list(c), "tag": "quarters", "tags": ["obidos_b"],
     "name": T("The column's quarters", "Os quartéis da coluna", "Los cuarteles de la columna")}
    for c in [(117, 36), (126, 30), (137, 30), (114, 40), (127, 49), (137, 49)]
] + [
    {"team": "garrison", "kind": "gate" if g else "wall", "at": list(c), "tag": "palisade", "tags": ["obidos_b"],
     "name": T("Óbidos' palisade", "A paliçada de Óbidos", "La empalizada de Óbidos")} for (c, g) in WALLS
]

# ================================================================== the objectives
objectives = [
    # ---- the column
    {"id": "keep_live", "side": "column", "primary": True, "kind": "protect", "tag": "keep",
     "text": T("The Fort of Óbidos must stand.", "O Forte de Óbidos tem de ficar de pé.", "El Fuerte de Óbidos debe seguir en pie.")},
    {"id": "reclaim", "side": "column", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE UPRIVER BATTERY: when the Barra fell, the swarm came down as far as Óbidos' outwork west of the fort. Retake it: kill every creature on the little rise west of the gate ({bat_left} left).",
               "A BATERIA DE RIO ACIMA: quando a Barra caiu, o enxame desceu até à obra exterior de Óbidos, a oeste do forte. Retome-a: mate todas as criaturas no pequeno alto a oeste da porta ({bat_left} restam).",
               "LA BATERÍA DE RÍO ARRIBA: cuando cayó la Barra, el enjambre bajó hasta la obra exterior de Óbidos, al oeste del fuerte. Recupérala: mata a todas las criaturas del pequeño alto al oeste de la puerta ({bat_left} quedan)."),
     "phone": T("Retake the upriver battery west of the gate: {bat_left} left.", "Retome a bateria a oeste da porta: {bat_left} restam.",
                "Recupera la batería al oeste de la puerta: {bat_left} quedan.")},
    {"id": "balloon", "side": "column", "primary": False, "kind": "manual",
     "text": T("THE FOG ON THE RIVER: under the canopy the forest is dark, and whatever is in it stays hidden. Send Father Inácio's balloon west over the water to the island (select it, right-click there) and keep it there while he looks: from up there he sees where they root.",
               "A NÉVOA NO RIO: debaixo da copa a floresta está escura, e o que lá estiver fica escondido. Mande o balão do Padre Inácio para oeste por cima da água até à ilha (selecione-o, clique com o botão direito lá) e mantenha-o lá enquanto ele olha: lá de cima ele vê onde eles enraízam.",
               "LA NIEBLA EN EL RÍO: bajo la copa la selva está oscura, y lo que haya en ella sigue oculto. Manda el globo del Padre Inácio al oeste por encima del agua hasta la isla (selecciónalo, clic derecho allí) y mantenlo allí mientras mira: desde arriba ve dónde enraízan."),
     "phone": T("Fly Father Inácio's balloon west to the island.", "Leve o balão do Padre Inácio para oeste até à ilha.",
                "Lleva el globo del Padre Inácio al oeste hasta la isla.")},
    {"id": "hold_o", "side": "column", "primary": False, "kind": "manual",
     "text": T("Hold Óbidos meanwhile: creatures come out of the forest at the west gate. The Barracks and the Foundry in the fort are the column's: train there.",
               "Entretanto segure Óbidos: saem criaturas da floresta para a porta oeste. O Quartel e a Fundição do forte são da coluna: treine lá.",
               "Mientras tanto sostén Óbidos: salen criaturas de la selva hacia la puerta oeste. El Cuartel y la Fundición del fuerte son de la columna: entrena allí.")},
    {"id": "fwd", "side": "column", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE NESTS: break every forward Mother rooted on the river ({fwd_killed} of {fwd_n}). While one stands, what she lays comes down the levee to Óbidos. The balloon spots for the guns: they fire as far as it sees.",
               "OS NINHOS: quebre todas as Mães avançadas enraizadas no rio ({fwd_killed} de {fwd_n}). Enquanto uma estiver de pé, o que ela põe desce o dique até Óbidos. O balão aponta para os canhões: atiram tão longe quanto ele vê.",
               "LOS NIDOS: rompe a todas las Madres de avanzada enraizadas en el río ({fwd_killed} de {fwd_n}). Mientras una siga en pie, lo que pone baja por el dique hasta Óbidos. El globo apunta para los cañones: disparan tan lejos como él ve."),
     "phone": T("Break the forward Mothers: {fwd_killed} of {fwd_n}.", "Quebre as Mães avançadas: {fwd_killed} de {fwd_n}.",
                "Rompe a las Madres de avanzada: {fwd_killed} de {fwd_n}.")},
    {"id": "west", "side": "column", "primary": False, "kind": "manual", "hidden": True,
     "text": T("UPRIVER: Father Inácio saw only so far. More of them root up the west creek and on the upriver bank, still under the fog: fly the balloon west to find them.",
               "RIO ACIMA: o Padre Inácio só viu até certo ponto. Mais delas enraízam no igarapé do oeste e na margem rio acima, ainda debaixo da névoa: leve o balão para oeste para as encontrar.",
               "RÍO ARRIBA: el Padre Inácio solo vio hasta cierto punto. Más de ellas enraízan en el arroyo del oeste y en la orilla río arriba, aún bajo la niebla: lleva el globo al oeste para encontrarlas.")},
    {"id": "nests_clock", "side": "column", "primary": False, "kind": "countdown", "clock": "nests", "hidden": True, "fail": True,
     "text": T("The rains come back in {clock:nests}: then the flood carries what the nests lay down to the river towns.",
               "As chuvas voltam em {clock:nests}: depois a cheia leva o que os ninhos põem para as vilas do rio.",
               "Las lluvias vuelven en {clock:nests}: luego la crecida lleva lo que ponen los nidos a los pueblos del río.")},
    {"id": "island", "side": "column", "primary": False, "kind": "manual", "hidden": True,
     "text": T("THE ISLAND: cross the shallows to Lindqvist's old island and break the swarm's oldest ground on the fazenda's ruins: the old mound and its Rootmaws ({isl_left} left).",
               "A ILHA: atravesse os baixios até à velha ilha de Lindqvist e quebre o chão mais antigo do enxame nas ruínas da fazenda: o velho monte e as suas Bocarraízes ({isl_left} restam).",
               "LA ISLA: cruza los bajíos hasta la vieja isla de Lindqvist y rompe el suelo más antiguo del enjambre en las ruinas de la fazenda: el viejo montículo y sus Bocarraíces ({isl_left} quedan)."),
     "phone": T("Break the old ground on the island: {isl_left} left.", "Quebre o chão velho da ilha: {isl_left} restam.",
                "Rompe el suelo viejo de la isla: {isl_left} quedan.")},
    {"id": "last", "side": "column", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE LAST WAVE: it comes down the levee from upriver, to the island and to Óbidos. Break it, or hold until it ebbs.",
               "A ÚLTIMA VAGA: desce o dique de rio acima, para a ilha e para Óbidos. Quebre-a, ou aguente até ela recuar.",
               "LA ÚLTIMA OLEADA: baja por el dique desde río arriba, hacia la isla y hacia Óbidos. Rómpela, o aguanta hasta que se retire.")},
    {"id": "ebb_clock", "side": "column", "primary": False, "kind": "countdown", "clock": "ebb", "hidden": True,
     "text": T("It ebbs in {clock:ebb}.", "Recua em {clock:ebb}.", "Se retira en {clock:ebb}.")},
    {"id": "v_break", "side": "column", "primary": False, "kind": "manual", "hidden": True,
     "text": T("Bring the swarm's forward Mothers down to one before the dry season ({clock:dry}).",
               "Reduza as Mães avançadas do enxame a uma antes da estação seca ({clock:dry}).",
               "Reduce a las Madres de avanzada del enjambre a una antes de la estación seca ({clock:dry}).")},
    # ---- the swarm (the solo pick, versus)
    {"id": "s_hold", "side": "swarm", "primary": False, "kind": "manual",
     "text": T("HOLD THE RIVER: keep at least two of your forward Mothers alive until the dry season ({fwd_left} alive). Lay at them; GROW one and lay a Mist Toad, and cover them with FOG when the guns come.",
               "SEGURE O RIO: mantenha pelo menos duas das suas Mães avançadas vivas até à estação seca ({fwd_left} vivas). Ponha ovos nelas; faça uma CRESCER e ponha um Sapo da Névoa, e cubra-as com NÉVOA quando os canhões vierem.",
               "SOSTÉN EL RÍO: mantén al menos dos de tus Madres de avanzada vivas hasta la estación seca ({fwd_left} vivas). Pon huevos en ellas; haz CRECER a una y pon un Sapo de Niebla, y cúbrelas con NIEBLA cuando vengan los cañones."),
     "phone": T("Keep two forward Mothers alive: {fwd_left} alive.", "Mantenha duas Mães avançadas vivas: {fwd_left} vivas.",
                "Mantén dos Madres de avanzada vivas: {fwd_left} vivas.")},
    {"id": "s_obidos", "side": "swarm", "primary": False, "kind": "manual",
     "text": T("OR BREAK ÓBIDOS: break the fort's keep on the bluff over the narrows. Brutes break palisades.",
               "OU ROMPA ÓBIDOS: derrube a torre do forte no alto sobre o estreito. Os Brutamontes rompem paliçadas.",
               "O ROMPE ÓBIDOS: derriba la torre del fuerte en el alto sobre el estrecho. Los Brutos rompen empalizadas.")},
    {"id": "s_clock", "side": "swarm", "primary": False, "kind": "countdown", "clock": "dry",
     "text": T("The dry season in {clock:dry}: the river falls and the column must go home.",
               "A estação seca em {clock:dry}: o rio baixa e a coluna tem de voltar para casa.",
               "La estación seca en {clock:dry}: el río baja y la columna debe volver a casa.")},
]

M = {
    "id": MID,
    "title": T("The Jungle Front", "A Frente da Selva", "El Frente de la Selva"),
    "summary": T("Óbidos and the lower Amazon, 2780. The army's jungle column breaks the swarm's nests on the river, Valadares leading it, Father Inácio's balloon above.",
                 "Óbidos e o baixo Amazonas, 2780. A coluna da selva do exército quebra os ninhos do enxame no rio, com Valadares à frente e o balão do Padre Inácio por cima.",
                 "Óbidos y el bajo Amazonas, 2780. La columna de la selva del ejército rompe los nidos del enjambre en el río, con Valadares al frente y el globo del Padre Inácio arriba."),
    "map": "campaign:obidos_front",
    "voice": "d10",
    "light": "jungle_day",
    "weather": "rain",
    "floor": [0.76, 0.8, 0.72],
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["a07_council", "d09_crossroads"],
    # THE CROSSING (owner question 9): the front not chosen waits: with the city chosen first, d10 opens once d11 is won
    "needs_if": [{"flag": "d09_crossroads.first", "is": "clockwork", "needs": ["d11_siege"]}],
    "versions": {
        "pick": [{"if": past("d09_crossroads.first", "clockwork"), "id": "grown"}],
        "default": "fresh",
        "labels": {
            "fresh": T("FRESH: the swarm first. Its nests are young below the Barra.", "FRESCO: o enxame primeiro. Os ninhos dele são novos abaixo da Barra.",
                       "FRESCO: el enjambre primero. Sus nidos son jóvenes por debajo de la Barra."),
            "grown": T("GROWN: the city first. A year on, the swarm has spread down the rivers.", "CRESCIDO: a cidade primeiro. Um ano depois, o enxame espalhou-se rios abaixo.",
                       "CRECIDO: la ciudad primero. Un año después, el enjambre se ha extendido ríos abajo."),
        },
    },
    "wade": {"pace": 0.5, "free": ["brood"]},
    "modes": ["solo", "coop", "versus"],
    "solo_sides": ["column", "swarm"],
    "sides": [
        {"id": "column", "name": T("The Jungle Column", "A Coluna da Selva", "La Columna de la Selva"),
         "about": T("Valadares and the army's jungle column at Óbidos: the line, the riders, two guns and Father Inácio's balloon; the fort's garrison.",
                    "Valadares e a coluna da selva do exército em Óbidos: a linha, os cavaleiros, dois canhões e o balão do Padre Inácio; a guarnição do forte.",
                    "Valadares y la columna de la selva del ejército en Óbidos: la línea, los jinetes, dos cañones y el globo del Padre Inácio; la guarnición del fuerte.")},
        {"id": "swarm", "name": T("The Swarm", "O Enxame", "El Enjambre"),
         "about": T("The Brood rooted on the lower Amazon: forward Mothers on the banks and the creeks, and what they lay.",
                    "A Ninhada enraizada no baixo Amazonas: Mães avançadas nas margens e nos igarapés, e o que elas põem.",
                    "La Prole enraizada en el bajo Amazonas: Madres de avanzada en las orillas y los arroyos, y lo que ponen.")},
    ],
    "teams": [
        {"id": "column", "side": "column", "faction": "crown", "colour": 4, "start": "none", "camera": "col_start", "gold": 400, "powder": 220,
         "techs": ["matchlock", "bayonet", "charge", "armour"],
         "control": {"solo": "p1", "coop": "p1", "versus": "p1", "foe": "script"}},
        {"id": "garrison", "side": "column", "faction": "crown", "colour": 0, "start": "none", "camera": "obidos_mid", "gold": 200, "powder": 200,
         "techs": ["matchlock", "bayonet"],
         "roster": {"deny": ["town_hall", "cottage", "farm", "wall", "gate", "barracks", "powder_mill", "horse_breeder", "foundry", "armoury",
                             "church", "missionary", "nitre_beds", "labourer"]},
         "control": {"solo": "script", "coop": "p2", "versus": "script"}},
        {"id": "swarm", "side": "swarm", "faction": "brood", "colour": 2, "start": "none", "camera": "m2", "gold": 0, "powder": 0,
         "control": {"solo": "script", "coop": "script", "versus": "p2"}},
    ],
    "areas": areas,
    "counters": {k: {"start": 0} for k in ["fwd_n", "fwd_killed", "fwd_left", "isl_n", "isl_left", "bat_left", "wave_n", "lw_n"]},
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["valadares", "inacio"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "column", "portrait": "res://campaign/hub/rome_king_face.png"},
        "valadares": {"name": T("Valadares", "Valadares", "Valadares"), "side": "column"},
        "inacio": {"name": T("Father Inácio", "Padre Inácio", "Padre Inácio"), "side": "column", "portrait": "res://campaign/portraits/inacio.png"},
        "ruggieri": {"name": T("General Ruggieri", "General Ruggieri", "General Ruggieri"), "side": "column"},
        "captain": {"name": T("The captain of Óbidos", "O capitão de Óbidos", "El capitán de Óbidos"), "side": "column"},
        "sergeant": {"name": T("The Barra's sergeant", "O sargento da Barra", "El sargento de la Barra"), "side": "column"},
        "narrator": {"name": T("The Amazon", "O Amazonas", "El Amazonas"), "side": "column"},
    },
    "lines": {},
    "stills": {},
    "next": {"column": "", "swarm": ""},
}

L = M["lines"]
UNTIL_P2 = {"i_look", "c_gate", "n_raid", "v_raid", "i_up", "i_high", "n_lesson2", "v_map", "v_sealed", "v_barra_burned", "s_bat", "n_bat_done"}
UNTIL_P3 = {"n_defend", "n_wave", "n_fwd_dead", "v_fwd_dead", "n_toad_fog", "v_fog", "c_gate2", "n_lured", "v_lure", "i_west", "n_west_seen"}


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


CO, SW = "column", "swarm"
# ---- the opening (the King frames; Ruggieri's order; Valadares tells it from his report)
line("k_open1", "king", "The army split at the São Francisco. One column went up the rivers, and Valadares led it.",
     "O exército dividiu-se no São Francisco. Uma coluna subiu os rios, e Valadares comandou-a.",
     "El ejército se dividió en el São Francisco. Una columna subió por los ríos, y Valadares la mandó.")
line("k_fresh", "king", "We went north first. The swarm was young on the lower river then.",
     "Fomos primeiro para norte. O enxame ainda era novo no baixo rio.", "Fuimos primero al norte. El enjambre aún era joven en el bajo río.")
line("k_grown", "king", "We went north last. The swarm had a year on the rivers without us.",
     "Fomos para norte por último. O enxame teve um ano nos rios sem nós.", "Fuimos al norte los últimos. El enjambre tuvo un año en los ríos sin nosotros.")
line("r_order", "ruggieri", "Valadares, you know the rivers. Take the column to Óbidos and break their nests before the rains.",
     "Valadares, conhece os rios. Leve a coluna a Óbidos e quebre os ninhos deles antes das chuvas.",
     "Valadares, conoce los ríos. Lleve la columna a Óbidos y rompa sus nidos antes de las lluvias.")
line("r_inacio", "ruggieri", "And take the priest with the balloon. He swears he can see the whole river from up there.",
     "E leve o padre do balão. Jura que consegue ver o rio inteiro lá de cima.", "Y llévese al cura del globo. Jura que puede ver el río entero desde arriba.")
line("v_open1", "valadares", "Óbidos, on the narrows of the Amazon, 2780. The fog lay on the water every morning.",
     "Óbidos, no estreito do Amazonas, 2780. A névoa pousava na água todas as manhãs.",
     "Óbidos, en el estrecho del Amazonas, 2780. La niebla se posaba en el agua cada mañana.")
line("v_open2", "valadares", "I had walked those banks for ten years. I could not see a thing under that canopy.",
     "Tinha andado por aquelas margens dez anos. Não via nada debaixo daquela copa.",
     "Había andado por aquellas orillas diez años. No veía nada bajo aquella copa.")
line("k_open_s", "king", "Valadares wrote this down as it happened. Here is how it would have gone if the river had been theirs.",
     "Valadares escreveu isto à medida que acontecia. Eis como teria sido se o rio tivesse sido deles.",
     "Valadares lo escribió según ocurría. He aquí cómo habría sido si el río hubiera sido suyo.")
line("n_open_s", "narrator", "The lower Amazon. Forward Mothers rooted on the banks and up the creeks; a column of the Crown at Óbidos.",
     "O baixo Amazonas. Mães avançadas enraizadas nas margens e nos igarapés; uma coluna da Coroa em Óbidos.",
     "El bajo Amazonas. Madres de avanzada enraizadas en las orillas y en los arroyos; una columna de la Corona en Óbidos.")
# ---- part 0 / part 1: the narrows
line("v_1", "valadares", "The forest is dark under the canopy. Whatever roots in it, we will not see it from the ground.",
     "A floresta está escura debaixo da copa. O que lá enraíza, não o veremos do chão.",
     "La selva está oscura bajo la copa. Lo que enraíza en ella, no lo veremos desde el suelo.", CO)
line("i_1", "inacio", "Then let me go up, Senhor Valadares. The sky over a river is the clearest map God ever drew.",
     "Então deixe-me subir, Senhor Valadares. O céu sobre um rio é o mapa mais claro que Deus alguma vez desenhou.",
     "Entonces déjeme subir, señor Valadares. El cielo sobre un río es el mapa más claro que Dios dibujó jamás.", CO)
line("n_lesson", "narrator", "Father Inácio's balloon is yours. Select it and send it west over the water to the island: what it flies over is mapped, and the creatures there can be seen.",
     "O balão do Padre Inácio é seu. Selecione-o e mande-o para oeste por cima da água até à ilha: o que ele sobrevoa fica no mapa, e as criaturas lá podem ser vistas.",
     "El globo del Padre Inácio es tuyo. Selecciónalo y mándalo al oeste por encima del agua hasta la isla: lo que sobrevuela queda en el mapa, y las criaturas de allí se pueden ver.", CO)
line("n_lesson2", "narrator", "Keep the line at the west gate meanwhile. The Barracks and the Foundry in the fort train for the column.",
     "Entretanto mantenha a linha na porta oeste. O Quartel e a Fundição do forte treinam para a coluna.",
     "Mientras tanto mantén la línea en la puerta oeste. El Cuartel y la Fundición del fuerte entrenan para la columna.", CO)
line("v_map", "valadares", "I know their road down from the plateau: the east creek. That much I have drawn already.",
     "Conheço o caminho deles desde o planalto: o igarapé do leste. Isso já o desenhei.",
     "Conozco su camino desde la meseta: el arroyo del este. Eso ya lo he dibujado.", CO)
line("v_sealed", "valadares", "My map of the plateau is under seal in Rome. I know nothing of their road that the priest cannot see.",
     "O meu mapa do planalto está selado em Roma. Não sei nada do caminho deles que o padre não consiga ver.",
     "Mi mapa de la meseta está sellado en Roma. No sé nada de su camino que el cura no pueda ver.", CO)
line("v_barra_burned", "valadares", "The Barra's lower town burned two years ago. We rebuilt it on the bluff. I think of it every time I see a roof.",
     "A cidade baixa da Barra ardeu há dois anos. Reconstruímo-la no alto. Penso nisso sempre que vejo um telhado.",
     "La ciudad baja de la Barra ardió hace dos años. La reconstruimos en el alto. Pienso en ello cada vez que veo un tejado.", CO)
line("c_gate", "captain", "Senhor! Something moving in the trees west of the gate. We cannot see what.",
     "Senhor! Algo se mexe nas árvores a oeste da porta. Não vemos o quê.", "¡Señor! Algo se mueve en los árboles al oeste de la puerta. No vemos qué.", CO)
line("n_raid", "narrator", "Creatures come out of the forest at Óbidos' west gate.", "Criaturas saem da floresta para a porta oeste de Óbidos.",
     "Criaturas salen de la selva hacia la puerta oeste de Óbidos.", CO)
line("v_raid", "valadares", "Line, at the gate. Let them come into the open.", "Linha, à porta. Deixem-nos vir para o descampado.",
     "Línea, a la puerta. Dejadlos salir a campo abierto.", CO)
line("i_up", "inacio", "Up we go! Mind the rope, my sons, it is the only one I have.",
     "Para cima! Cuidado com a corda, meus filhos, é a única que tenho.", "¡Arriba! Cuidado con la cuerda, hijos míos, es la única que tengo.", CO)
line("i_look", "inacio", "Hold her here a little, the wind is kind. I am counting.", "Segure-o aqui um pouco, o vento está bom. Estou a contar.",
     "Sosténgalo aquí un poco, el viento es amable. Estoy contando.", CO)
line("n_defend", "narrator", "The Mother lays as the column comes: young ones out of the swamp round her.", "A Mãe põe ovos quando a coluna chega: crias saem do pântano à volta dela.",
     "La Madre pone huevos cuando llega la columna: crías salen del pantano a su alrededor.", CO)
line("i_high", "inacio", "Higher than the herons now. The fog is under me like milk in a bowl.",
     "Mais alto do que as garças agora. A névoa está debaixo de mim como leite numa tigela.",
     "Más alto que las garzas ahora. La niebla está debajo de mí como leche en un cuenco.", CO)
# the reclaim part
line("s_bat", "sergeant", "Senhor Valadares! Those of us who got out of the Barra. They are on the old battery, west of the gate. They came down after us.",
     "Senhor Valadares! Os que escapámos da Barra. Eles estão na velha bateria, a oeste da porta. Desceram atrás de nós.",
     "¡Señor Valadares! Los que salimos de la Barra. Ellos están en la vieja batería, al oeste de la puerta. Bajaron tras nosotros.", CO)
line("v_bat", "valadares", "Then we take it back before anything else. The guns there cover the levee.",
     "Então retomamo-la antes de mais nada. Os canhões de lá cobrem o dique.", "Entonces la recuperamos antes que nada. Los cañones de allí cubren el dique.", CO)
line("n_bat_done", "narrator", "The upriver battery is the Crown's again. The Barra's survivors come out of the fort to man it.",
     "A bateria de rio acima é da Coroa outra vez. Os sobreviventes da Barra saem do forte para a guarnecer.",
     "La batería de río arriba es de la Corona otra vez. Los supervivientes de la Barra salen del fuerte para guarnecerla.", CO)
# THE FOG LIFTS (a show: Inácio's voice over what he sees)
line("i_see1", "inacio", "There! I see the river from the narrows to the bend. The island in the middle, and a ruin on it.",
     "Ali! Vejo o rio do estreito até à curva. A ilha no meio, e uma ruína nela.",
     "¡Allí! Veo el río desde el estrecho hasta la curva. La isla en medio, y una ruina en ella.")
line("i_see2", "inacio", "On the banks, where the ground is dry, the green has gone bare in rings. Something great lies in each ring.",
     "Nas margens, onde o chão é seco, o verde ficou careca em anéis. Há uma coisa grande deitada em cada anel.",
     "En las orillas, donde el suelo es seco, el verde se ha quedado pelado en anillos. Hay algo grande tumbado en cada anillo.")
line("i_see3", "inacio", "I count them for you, Senhor. Mark them on your map, and God keep the men who go in under those trees.",
     "Conto-as para si, Senhor. Marque-as no seu mapa, e Deus guarde os homens que entrarem debaixo daquelas árvores.",
     "Se las cuento, señor. Márquelas en su mapa, y Dios guarde a los hombres que entren bajo esos árboles.")
line("v_see", "valadares", "Forward Mothers, rooted where the bank is dry. Every one of them is a wave at our gate.",
     "Mães avançadas, enraizadas onde a margem é seca. Cada uma é uma vaga à nossa porta.",
     "Madres de avanzada, enraizadas donde la orilla es seca. Cada una es una oleada en nuestra puerta.")
line("n_lift_late", "narrator", "A canoe comes down from the creeks with word of where they root. The column has it now, if not from above.",
     "Uma canoa desce dos igarapés com notícias de onde eles enraízam. A coluna já sabe, ainda que não de cima.",
     "Una canoa baja de los arroyos con noticias de dónde enraízan. La columna ya lo sabe, aunque no desde arriba.", CO)
# ---- part 2: the nests
line("n_nests", "narrator", "Break each forward Mother. While one stands, what she lays comes down the levee. The rains come back before long.",
     "Quebre cada Mãe avançada. Enquanto uma estiver de pé, o que ela põe desce o dique. As chuvas não tardam a voltar.",
     "Rompe a cada Madre de avanzada. Mientras una siga en pie, lo que pone baja por el dique. Las lluvias no tardan en volver.", CO)
line("v_nests", "valadares", "Riders to the near one on the bank. The guns behind them, under the priest.",
     "Cavaleiros para a mais próxima, na margem. Os canhões atrás deles, debaixo do padre.",
     "Jinetes a la más cercana, en la orilla. Los cañones tras ellos, bajo el cura.", CO)
line("i_west", "inacio", "There is more up the west creek, Senhor, and on the upriver bank. I cannot see through it from here.",
     "Há mais no igarapé do oeste, Senhor, e na margem rio acima. Daqui não consigo ver através.",
     "Hay más en el arroyo del oeste, señor, y en la orilla río arriba. Desde aquí no puedo ver a través.", CO)
line("n_west_seen", "narrator", "From over the west creek the priest sees two more rings on the bank.",
     "Por cima do igarapé do oeste o padre vê mais dois anéis na margem.", "Desde encima del arroyo del oeste el cura ve dos anillos más en la orilla.", CO)
line("n_wave", "narrator", "A wave comes down the levee to the west gate.", "Uma vaga desce o dique até à porta oeste.",
     "Una oleada baja por el dique hasta la puerta oeste.", CO)
line("c_gate2", "captain", "At the gate again, Senhor! Canister!", "Outra vez à porta, Senhor! Metralha!", "¡Otra vez en la puerta, señor! ¡Metralla!", CO)
line("n_fwd_dead", "narrator", "A forward Mother is broken. Her ground stops creeping, and her waves stop.",
     "Uma Mãe avançada está quebrada. O chão dela deixa de rastejar, e as vagas dela param.",
     "Una Madre de avanzada está rota. Su suelo deja de arrastrarse, y sus oleadas paran.", CO)
line("v_fwd_dead", "valadares", "One less. Mark it, Father.", "Menos uma. Marque-a, Padre.", "Una menos. Márquela, Padre.", CO)
line("n_toad_fog", "narrator", "A Mist Toad by the nest lays a fog bank: shots into it miss half the time. Go in with bayonets, or wait for it to thin.",
     "Um Sapo da Névoa junto ao ninho põe um banco de névoa: os tiros para dentro falham metade das vezes. Entre com baionetas, ou espere que se desfaça.",
     "Un Sapo de Niebla junto al nido pone un banco de niebla: los disparos hacia dentro fallan la mitad de las veces. Entra con bayonetas, o espera a que se disipe.", CO)
line("v_fog", "valadares", "Fog out of a toad's throat. I have seen everything now.", "Névoa da garganta de um sapo. Agora já vi tudo.",
     "Niebla de la garganta de un sapo. Ahora ya lo he visto todo.", CO)
line("v_lure", "valadares", "I used the old lure once, at the Barra. God forgive me, I kept the recipe. Once more, under our guns.",
     "Usei o engodo antigo uma vez, na Barra. Deus me perdoe, guardei a receita. Uma vez mais, debaixo dos nossos canhões.",
     "Usé el señuelo antiguo una vez, en la Barra. Dios me perdone, guardé la receta. Una vez más, bajo nuestros cañones.", CO)
line("n_lured", "narrator", "The wave turns off the levee toward the lure post, into the open ground under the guns.",
     "A vaga desvia-se do dique para o poste do engodo, para o descampado debaixo dos canhões.",
     "La oleada se desvía del dique hacia el poste del señuelo, al campo abierto bajo los cañones.", CO)
line("n_broken_all", "narrator", "Every forward Mother on this river is broken.", "Todas as Mães avançadas deste rio estão quebradas.",
     "Todas las Madres de avanzada de este río están rotas.")
line("n_flood", "narrator", "With the rains the nests still rooted send everything they have laid down the levee at once: THE FLOOD comes at Óbidos.",
     "Com as chuvas os ninhos ainda enraizados mandam tudo o que puseram dique abaixo de uma vez: A CHEIA vem sobre Óbidos.",
     "Con las lluvias los nidos aún enraizados mandan todo lo que han puesto dique abajo a la vez: LA CRECIDA viene sobre Óbidos.", CO)
line("n_pay", "narrator", "A boat from Ruggieri's army comes down to Óbidos' landing with the column's pay and powder: train at the Barracks and the Foundry.",
     "Um barco do exército de Ruggieri desce ao cais de Óbidos com o soldo e a pólvora da coluna: treine no Quartel e na Fundição.",
     "Una barca del ejército de Ruggieri baja al embarcadero de Óbidos con la paga y la pólvora de la columna: entrena en el Cuartel y en la Fundición.", CO)
line("n_rains", "narrator", "The rains come back. The nests still rooted will send their young down with the flood.",
     "As chuvas voltam. Os ninhos ainda enraizados vão mandar as crias com a cheia.",
     "Las lluvias vuelven. Los nidos aún enraizados mandarán a sus crías con la crecida.")
# ---- part 3: the island, the last wave
line("v_island", "valadares", "Lindqvist's island. Their oldest ground is on the ruins of his house. Over the shallows, and burn it.",
     "A ilha de Lindqvist. O chão mais antigo deles está nas ruínas da casa dele. Pelos baixios, e queimem-no.",
     "La isla de Lindqvist. Su suelo más antiguo está en las ruinas de su casa. Por los bajíos, y quemadlo.", CO)
line("n_island", "narrator", "Cross either shallows to the island. The old mound and its Rootmaws sit on the fazenda's ruins.",
     "Atravesse qualquer dos baixios até à ilha. O velho monte e as suas Bocarraízes estão nas ruínas da fazenda.",
     "Cruza cualquiera de los bajíos hasta la isla. El viejo montículo y sus Bocarraíces están en las ruinas de la fazenda.", CO)
line("i_ruins", "inacio", "I see the ruin plainly now. The ground round it is the colour of a bruise.",
     "Agora vejo a ruína com clareza. O chão à volta tem a cor de uma nódoa negra.",
     "Ahora veo la ruina con claridad. El suelo a su alrededor tiene el color de un moratón.", CO)
line("n_isl_done", "narrator", "The old mound is broken. The ruins burn, and the ground round them goes grey.",
     "O velho monte está quebrado. As ruínas ardem, e o chão à volta fica cinzento.",
     "El viejo montículo está roto. Las ruinas arden, y el suelo a su alrededor se vuelve gris.", CO)
line("i_last", "inacio", "Senhor! Up the levee, out of the west: more than I can count. Coming down to the island and to the town both.",
     "Senhor! Dique acima, do oeste: mais do que consigo contar. A descer para a ilha e para a vila ao mesmo tempo.",
     "¡Señor! Dique arriba, desde el oeste: más de los que puedo contar. Bajando hacia la isla y hacia el pueblo a la vez.", CO)
line("n_last", "narrator", "The last wave comes down the levee from upriver. Break it, or hold until it ebbs.",
     "A última vaga desce o dique de rio acima. Quebre-a, ou aguente até ela recuar.",
     "La última oleada baja por el dique desde río arriba. Rómpela, o aguanta hasta que se retire.", CO)
line("c_last", "captain", "We hold the gate, Senhor! Mind the island!", "Seguramos a porta, Senhor! Cuidado com a ilha!",
     "¡Sostenemos la puerta, señor! ¡Cuidado con la isla!", CO)
line("n_smell", "narrator", "More come down the levee to the place where the lure was set. They follow the smell of it.",
     "Mais descem o dique até ao sítio onde o engodo foi posto. Seguem o cheiro dele.",
     "Más bajan por el dique hasta el lugar donde se puso el señuelo. Siguen su olor.", CO)
line("n_ebb", "narrator", "The last wave ebbs. What is left of it goes back up the levee into the fog.",
     "A última vaga recua. O que resta dela volta dique acima para a névoa.", "La última oleada se retira. Lo que queda de ella vuelve dique arriba a la niebla.")
line("v_won", "valadares", "Ring the bell in Óbidos. Then count the men.", "Toquem o sino em Óbidos. Depois contem os homens.",
     "Tocad la campana en Óbidos. Luego contad a los hombres.", CO)
line("i_won", "inacio", "From up here the river is quiet. I will say Mass for them all on the island, if you let me land.",
     "Daqui de cima o rio está calmo. Direi missa por todos na ilha, se me deixar aterrar.",
     "Desde aquí arriba el río está en calma. Diré misa por todos en la isla, si me deja aterrizar.", CO)
line("v_hurt", "valadares", "I am hit. It is the arm, it will do. Hold the gate.", "Fui atingido. É o braço, aguenta-se. Segurem o portão.",
     "Me han dado. Es el brazo, aguanta. Sostened la puerta.", CO)
line("i_hurt", "inacio", "They have torn the silk! I am coming down, Senhor, slowly, I hope.",
     "Rasgaram a seda! Estou a descer, Senhor, devagar, espero.", "¡Han rasgado la seda! Estoy bajando, señor, despacio, espero.", CO)
line("n_keep_lost", "narrator", "The Fort of Óbidos is broken. The narrows are the swarm's.", "O Forte de Óbidos está quebrado. O estreito é do enxame.",
     "El Fuerte de Óbidos está roto. El estrecho es del enjambre.")
# ---- the swarm's (the solo pick, versus): narration only, no creature speaks
line("n_s1", "narrator", "Your forward Mothers are rooted on the river's banks and up the creeks. Lay at them; your grubs make Rootmaws on their swamp for food.",
     "As suas Mães avançadas estão enraizadas nas margens do rio e nos igarapés. Ponha ovos nelas; as larvas fazem Bocarraízes no pântano delas para comida.",
     "Tus Madres de avanzada están enraizadas en las orillas del río y en los arroyos. Pon huevos en ellas; tus larvas hacen Bocarraíces en su pantano para comida.", SW)
line("n_s2", "narrator", "The Mother at the creek mouth is grown to her third stage, the Venom Sire rooted by her: she can lay Mist Toads. Research FOG on the Sire's card.",
     "A Mãe da boca do igarapé cresceu ao terceiro estágio, com o Sire do Veneno enraizado ao lado: pode pôr Sapos da Névoa. Pesquise NÉVOA no painel do Sire.",
     "La Madre de la boca del arroyo ha crecido a su tercera etapa, con el Señor del Veneno enraizado a su lado: puede poner Sapos de Niebla. Investiga NIEBLA en el panel del Señor.", SW)
line("n_s_col", "narrator", "The column comes out of Óbidos with its guns, the balloon over it.", "A coluna sai de Óbidos com os canhões, o balão por cima.",
     "La columna sale de Óbidos con sus cañones, el globo encima.", SW)
line("n_s_reinf", "narrator", "Boats come up from downriver: more men for Óbidos.", "Chegam barcos de rio abaixo: mais homens para Óbidos.",
     "Llegan barcas de río abajo: más hombres para Óbidos.", SW)
line("n_s_probe", "narrator", "Riders come out of Óbidos to look at the nearest nest.",
     "Cavaleiros saem de Óbidos para ver o ninho mais próximo.",
     "Jinetes salen de Óbidos para mirar el nido más cercano.", SW)
line("n_s_mother", "narrator", "One of your forward Mothers is broken.", "Uma das suas Mães avançadas está quebrada.", "Una de tus Madres de avanzada está rota.", SW)
line("n_s_won", "narrator", "The dry season comes and the river falls. The column goes home, and the swarm is still rooted on the river.",
     "A estação seca chega e o rio baixa. A coluna volta para casa, e o enxame continua enraizado no rio.",
     "Llega la estación seca y el río baja. La columna vuelve a casa, y el enjambre sigue enraizado en el río.")
line("n_s_keep", "narrator", "The Fort of Óbidos is broken. The narrows are the swarm's.", "O Forte de Óbidos está quebrado. O estreito é do enxame.",
     "El Fuerte de Óbidos está roto. El estrecho es del enjambre.")
line("n_s_lost", "narrator", "Only one forward Mother is left on the river. The column has broken the nests.",
     "Só resta uma Mãe avançada no rio. A coluna quebrou os ninhos.", "Solo queda una Madre de avanzada en el río. La columna ha roto los nidos.")
# ---- the endings
line("v_end1", "valadares", "We broke their ground on the island and burned the ruin over it. Father Inácio said Mass there.",
     "Quebrámos o chão deles na ilha e queimámos a ruína por cima. O Padre Inácio disse missa lá.",
     "Rompimos su suelo en la isla y quemamos la ruina encima. El Padre Inácio dijo misa allí.")
line("v_end1b", "valadares", "We did not reach the island in time. Their old ground is still there, under the ruin.",
     "Não chegámos à ilha a tempo. O chão velho deles ainda lá está, debaixo da ruína.",
     "No llegamos a la isla a tiempo. Su suelo viejo sigue allí, bajo la ruina.")
line("v_end_held", "valadares", "Every nest on the river was broken before the rains. The towns below Óbidos had a quiet year.",
     "Todos os ninhos do rio foram quebrados antes das chuvas. As vilas abaixo de Óbidos tiveram um ano calmo.",
     "Todos los nidos del río se rompieron antes de las lluvias. Los pueblos por debajo de Óbidos tuvieron un año tranquilo.")
line("v_end_thin", "valadares", "Some of the nests outlived the rains. We held Óbidos; the river above it we only watched.",
     "Alguns ninhos sobreviveram às chuvas. Segurámos Óbidos; o rio acima dele só o vigiámos.",
     "Algunos nidos sobrevivieron a las lluvias. Sostuvimos Óbidos; el río por encima solo lo vigilamos.")
line("v_end_inacio", "valadares", "The priest stayed with the army. The men made him their chaplain, and he flew that patched balloon over every camp we made.",
     "O padre ficou com o exército. Os homens fizeram dele o seu capelão, e ele fez subir aquele balão remendado sobre cada acampamento nosso.",
     "El cura se quedó con el ejército. Los hombres lo hicieron su capellán, y él subió aquel globo remendado sobre cada campamento que hicimos.")
line("k_end1", "king", "That was the jungle front. Valadares held the river, and a priest in a basket showed him where.",
     "Essa foi a frente da selva. Valadares segurou o rio, e um padre num cesto mostrou-lhe onde.",
     "Ese fue el frente de la selva. Valadares sostuvo el río, y un cura en un cesto le mostró dónde.")
line("k_end2", "king", "The Queen was never on that map. She was further up, beyond anything we had drawn.",
     "A Rainha nunca esteve naquele mapa. Estava mais acima, para lá de tudo o que tínhamos desenhado.",
     "La Reina nunca estuvo en ese mapa. Estaba más arriba, más allá de todo lo que habíamos dibujado.")
line("k_end_s", "king", "That is not how it went. Valadares broke their nests on the river. But I have kept this page.",
     "Não foi assim que aconteceu. Valadares quebrou os ninhos deles no rio. Mas guardei esta página.",
     "No fue así como ocurrió. Valadares rompió sus nidos en el río. Pero he guardado esta página.")
line("n_end_s", "narrator", "The column went home with the dry season. The swarm stayed rooted on the lower river.",
     "A coluna voltou para casa com a estação seca. O enxame ficou enraizado no baixo rio.",
     "La columna volvió a casa con la estación seca. El enjambre se quedó enraizado en el bajo río.")

# ---- stills
M["stills"] = {
    "rome": {"image": STILL % "b01_01", "caption": T("Rome, the present. The King with the mapmaker's report.", "Roma, o presente. O Rei com o relatório do cartógrafo.",
                                                    "Roma, el presente. El Rey con el informe del cartógrafo.")},
    "obidos": {"image": STILL % "d10_03", "caption": T("Óbidos on the narrows of the Amazon, 2780: the fog on the water.",
                                                      "Óbidos no estreito do Amazonas, 2780: a névoa na água.",
                                                      "Óbidos en el estrecho del Amazonas, 2780: la niebla en el agua.")},
    "balloon": {"image": STILL % "d10_01", "caption": T("Father Inácio's balloon over the canopy.", "O balão do Padre Inácio sobre a copa.",
                                                       "El globo del Padre Inácio sobre la copa.")},
    "nests": {"image": STILL % "d10_02", "caption": T("The nests burn.", "Os ninhos ardem.", "Los nidos arden.")},
    "island": {"image": STILL % "d10_04", "caption": T("Mass on the island, at the fazenda's ruins.", "Missa na ilha, nas ruínas da fazenda.",
                                                      "Misa en la isla, en las ruinas de la fazenda.")},
}
M["opening"] = {
    "column": [{"still": "rome", "lines": ["k_open1", {"id": "k_fresh", "if": FRESH}, {"id": "k_grown", "if": GROWN}]},
               {"still": "obidos", "lines": ["r_order", "r_inacio", "v_open1", "v_open2"]}],
    "swarm": [{"still": "rome", "lines": ["k_open_s"]}, {"still": "obidos", "lines": ["n_open_s"]}],
}
M["ending"] = {
    "column": [
        {"still": "island", "lines": [{"id": "v_end1", "if": {"flag": {"island": "burned"}}}, {"id": "v_end1b", "if": {"flag": {"island": "standing"}}},
                                      {"id": "v_end_held", "if": {"flag": {"jungle": "held"}}}, {"id": "v_end_thin", "if": {"flag": {"jungle": "thin"}}},
                                      "v_end_inacio"]},
        {"still": "rome", "lines": ["k_end1", "k_end2"]},
    ],
    "swarm": [{"still": "nests", "lines": ["n_end_s"]}, {"still": "rome", "lines": ["k_end_s"]}],
}
M["briefing"] = {
    "column": {"still": "obidos", "text": [
        T("Óbidos on the lower Amazon, 2780. You are Valadares and the army's jungle column: the line, the riders, two guns, a Powder Wagon and Father Inácio's balloon. Óbidos' garrison holds the fort.",
          "Óbidos no baixo Amazonas, 2780. Você é Valadares e a coluna da selva do exército: a linha, os cavaleiros, dois canhões, uma Carroça de Pólvora e o balão do Padre Inácio. A guarnição de Óbidos segura o forte.",
          "Óbidos en el bajo Amazonas, 2780. Eres Valadares y la columna de la selva del ejército: la línea, los jinetes, dos cañones, un Carro de Pólvora y el globo del Padre Inácio. La guarnición de Óbidos sostiene el fuerte."),
        T("The forest is dark under the fog: send the balloon over the river to find the swarm's forward Mothers, then break each one before the rains. Last, cross to Lindqvist's old island and burn their oldest ground.",
          "A floresta está escura debaixo da névoa: mande o balão por cima do rio para encontrar as Mães avançadas do enxame, depois quebre cada uma antes das chuvas. Por fim, atravesse até à velha ilha de Lindqvist e queime o chão mais antigo deles.",
          "La selva está oscura bajo la niebla: manda el globo por encima del río para encontrar a las Madres de avanzada del enjambre, luego rompe a cada una antes de las lluvias. Por último, cruza a la vieja isla de Lindqvist y quema su suelo más antiguo."),
        T("The Fort of Óbidos must stand.", "O Forte de Óbidos tem de ficar de pé.", "El Fuerte de Óbidos debe seguir en pie.")]},
    "swarm": {"still": "obidos", "text": [
        T("The lower Amazon, 2780. You are the swarm: forward Mothers rooted on the banks and up the creeks, and what they lay.",
          "O baixo Amazonas, 2780. Você é o enxame: Mães avançadas enraizadas nas margens e nos igarapés, e o que elas põem.",
          "El bajo Amazonas, 2780. Eres el enjambre: Madres de avanzada enraizadas en las orillas y en los arroyos, y lo que ponen."),
        T("A column of the Crown comes out of Óbidos with guns and a balloon. Keep two of your Mothers alive until the dry season, or break the fort's keep.",
          "Uma coluna da Coroa sai de Óbidos com canhões e um balão. Mantenha duas das suas Mães vivas até à estação seca, ou derrube a torre do forte.",
          "Una columna de la Corona sale de Óbidos con cañones y un globo. Mantén vivas a dos de tus Madres hasta la estación seca, o derriba la torre del fuerte.")]},
}
M["debrief"] = {
    "column": {"still": "island", "title": T("The River Holds", "O Rio Aguenta", "El Río Resiste"),
               "text": T("{fwd_killed} of the {fwd_n} forward Mothers broken.", "{fwd_killed} das {fwd_n} Mães avançadas quebradas.",
                         "{fwd_killed} de las {fwd_n} Madres de avanzada rotas."),
               "text_if": [
                   {"if": {"flag": {"jungle": "held"}}, "text": T("Every nest was broken before the rains.", "Todos os ninhos foram quebrados antes das chuvas.",
                                                                  "Todos los nidos se rompieron antes de las lluvias.")},
                   {"if": {"flag": {"jungle": "thin"}}, "text": T("Some nests outlived the rains.", "Alguns ninhos sobreviveram às chuvas.",
                                                                 "Algunos nidos sobrevivieron a las lluvias.")},
                   {"if": {"flag": {"island": "burned"}}, "text": T("The swarm's oldest ground on the island was burned.", "O chão mais antigo do enxame na ilha foi queimado.",
                                                                    "El suelo más antiguo del enjambre en la isla fue quemado.")}]},
    "swarm": {"still": "nests", "title": T("The River Stays Green", "O Rio Fica Verde", "El Río Sigue Verde"),
              "text": T("{fwd_left} forward Mothers still rooted on the river.", "{fwd_left} Mães avançadas ainda enraizadas no rio.",
                        "{fwd_left} Madres de avanzada aún enraizadas en el río.")},
}

# ================================================================== the waves (the solo column)
# every forward Mother still rooted sends its young down the levee to Óbidos' west gate
GATE_ROUTE = ["killground", "west_gate", "obidos_mid"]


def wave_triggers(i, at):
    wid = "wave_%d" % (i + 1)
    acts = [{"counter": {"name": "wave_n", "set": i + 1}},
            {"say": ["n_wave"], "if": {"all": [P2, {"count": {"tag": "fwd", "at_least": 1}}]}}]
    for k in SITE_IF:
        alive = {"count": {"tag": "fwd_" + k, "at_least": 1}}
        tg = "w%d%s" % (i + 1, k)
        sp = {"team": "swarm", "at": k, "tag": tg, "tags": ["waves", "swarm_all", "w%d" % (i + 1)]}
        acts += [
            {"spawn": dict(sp, kind="raptor", count=1, **{"if": alive})},
            {"spawn": dict(sp, kind="raptor", count=1, **{"if": {"all": [alive, NOT_BN_FEW, FRESH]}})},
            {"spawn": dict(sp, kind="raptor", count=1, **{"if": {"all": [alive, BN_ALL]}})},
            {"spawn": dict(sp, kind="spitter", count=1, **{"if": {"all": [alive, GROWN]}})},
            {"spawn": dict(sp, kind="tyrant_challenger", count=1, **{"if": {"all": [alive, GROWN, {"time": 400}]}})},
        ]
    out = [{"id": wid, "when": {"all": [{"fired": "part2"}, SOLO_C, LIVE]}, "delay": at, "do": acts}]
    lure = (i == 1)
    go = []
    for k in SITE_IF:
        tg = "w%d%s" % (i + 1, k)
        r = {"order": {"tag": tg, "do": "route", "route": [k] + GATE_ROUTE, "attack": True, "name": tg}}
        if lure:
            r["order"]["if"] = {"not": LURE_USED}
        go.append(r)
    go.append({"ping": {"area": "killground"}})
    out.append({"id": wid + "_go", "when": {"fired": wid}, "delay": 4, "do": go})
    if lure:
        # d08 `lure` used: THE LURE ONCE MORE: this wave turns to a lure post under Óbidos' guns
        out.append({"id": "lure_set", "when": {"all": [{"fired": wid + "_go"}, LURE_USED]}, "do": [
            {"say": ["v_lure"]},
            {"lure_post": {"tag": "obidos_lure", "at": "lure_spot", "secs": 60,
                           "pull": {"tag": "w2", "within": 90, "then": "killground", "name": "lured_w", "attack": True}}},
            {"ping": {"area": "lure_spot"}}]})
    out.append({"id": wid + "_push", "when": {"all": [{"fired": wid + "_go"}, LIVE]}, "delay": 45, "every": 15, "times": 6, "do": [
        {"order": {"tag": "w%d" % (i + 1), "do": "attack", "to": "obidos_mid", "idle": True}}]})
    return out


# ================================================================== the triggers
TR_ = M["triggers"]
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"counter": {"name": "fwd_n", "count": {"tag": "fwd"}}},
        {"counter": {"name": "fwd_left", "count": {"tag": "fwd"}}},
        {"counter": {"name": "isl_n", "count": {"tag": "isl_ground"}}},
        {"counter": {"name": "isl_left", "count": {"tag": "isl_ground"}}},
        {"counter": {"name": "bat_left", "count": {"tag": "bat_swarm"}}},
        {"root_now": {"tag": "fwd"}}, {"brood_stage": {"tag": "fwd", "stage": 2}},
        {"root_now": {"tag": "isl_ground"}},
        {"max_hp": {"tag": "fwd", "hp": MOTHER_HP, "if": {"all": [GROWN, NO_SWARM]}}},
        {"max_hp": {"tag": "fwd", "hp": MOTHER_HP_FRESH, "if": {"all": [FRESH, NO_SWARM]}}},
        {"max_hp": {"tag": "fwd", "hp": MOTHER_HP_MIRROR, "if": SWARM}},
        {"order": {"tag": "guards", "do": "hold"}}, {"order": {"tag": "isl_guard", "do": "hold"}}, {"order": {"tag": "toads", "do": "hold"}},
        {"order": {"tag": "bat_swarm", "do": "hold"}},
        {"order": {"tag": "garrison", "do": "hold"}}, {"order": {"tag": "fort_guns", "do": "hold"}},
        {"ground": {"name": "isl", "from": "old_mound", "kind": "swamp", "team": "swarm", "r": 5, "step": 1, "every": 12, "max": 9}}]},
] + [
    t for k in SITE_IF for t in [
        {"id": "placed_" + k, "when": {"all": [{"time": 0.7}, {"count": {"tag": "fwd_" + k, "at_least": 1}}]}, "do": [
            {"ground": {"name": "g_" + k, "from": "fwd_" + k, "kind": "swamp", "team": "swarm", "r": 4, "step": 1, "every": 10, "max": 8}}]},
        {"id": "defend_" + k, "when": {"all": [{"fired": "placed_" + k}, SOLO_C, LIVE, {"count": {"tag": "fwd_" + k, "at_least": 1}},
                                              {"near": {"team": "column", "to": "fwd_" + k, "within": 10}}]}, "do": [
            {"spawn": {"team": "swarm", "kind": "raptor", "count": 3, "near": "fwd_" + k, "at": k, "tag": "def_" + k, "tags": ["swarm_all"]}},
            {"spawn": {"team": "swarm", "kind": "spitter", "count": 1, "near": "fwd_" + k, "at": k, "tag": "def_" + k, "tags": ["swarm_all"]}},
            {"spawn": {"team": "swarm", "kind": "raptor", "count": 2, "near": "fwd_" + k, "at": k, "tag": "def_" + k, "tags": ["swarm_all"], "if": FRESH}},
            {"spawn": {"team": "swarm", "kind": "spitter", "count": 1, "near": "fwd_" + k, "at": k, "tag": "def_" + k, "tags": ["swarm_all"], "if": FRESH}},
            {"say": ["n_defend"]}]},
        {"id": "broken_" + k, "when": {"all": [{"fired": "placed_" + k}, {"count": {"tag": "fwd_" + k, "below": 1}}, LIVE]}, "do": [
            {"counter": {"name": "fwd_killed", "add": 1}}, {"counter": {"name": "fwd_left", "count": {"tag": "fwd"}}},
            {"ground": {"name": "g_" + k, "stop": True}}]},
    ]
] + [
    # the column played (solo or versus): THE FOG ON THE RIVER (THE UNMAPPED of d04 on the column's screen)
    {"id": "fog", "when": {"all": [{"time": 0.8}, COLUMN]}, "do": [
        {"chart": {"side": "column", "team": "column", "known": ["known_start", "landing"], "dark": 0.6}}]},
    {"id": "fog_drawn", "when": {"all": [{"fired": "fog"}, DRAWN]}, "do": [{"chart": {"side": "column", "team": "column", "known": ["creek_road"]}}]},
    # the C9 science comes north with the siege train (GROWN: d11 was fought first)
    {"id": "grown_science", "when": {"all": [{"time": 0.8}, GROWN]}, "do": [
        {"unlock": {"team": "column", "kind": ["charges", "quadrant"]}}, {"tech": {"team": "column", "id": ["charges", "quadrant"]}}]},
    # the swarm played: food, the clock, the third stage at the creek mouth, the Sires rooted
    {"id": "setup_swarm", "when": {"all": [{"time": 0.6}, SWARM]}, "do": [
        {"nest_free": {"tag": "sires", "on": True}}, {"root_now": {"tag": "sires"}},
        {"brood_stage": {"tag": "fwd_m2", "stage": 3}},
        {"give": {"team": "swarm", "gold": SWARM_FOOD, "powder": SWARM_SPOILS}},
        {"clock": {"name": "dry", "secs": DRY_SECS}},
        {"objective": {"id": "keep_live", "set": "hidden"}}]},
    {"id": "setup_noswarm_obj", "when": {"all": [{"time": 0.6}, NO_SWARM]}, "do": [
        {"objective": {"id": "s_hold", "set": "hidden"}}, {"objective": {"id": "s_obidos", "set": "hidden"}},
        {"objective": {"id": "s_clock", "set": "hidden"}}]},
    {"id": "setup_nocol_obj", "when": {"all": [{"time": 0.6}, NO_COLUMN]}, "do": [
        {"objective": {"id": "balloon", "set": "hidden"}}, {"objective": {"id": "hold_o", "set": "hidden"}}]},
    {"id": "setup_vs", "when": {"all": [{"time": 0.7}, COLUMN, SWARM]}, "do": [
        {"objective": {"id": "v_break", "set": "active"}}, {"objective": {"id": "keep_live", "set": "active"}}]},
    # ============================================================ THE OPENING LINES
    {"id": "intro", "when": {"all": [{"time": 1.5}, COLUMN]}, "do": [
        {"say": ["v_1", "i_1", "n_lesson"]}, {"ping": {"tag": "inacio"}}, {"ping": {"area": "lookout"}}]},
    {"id": "intro2", "when": {"all": [{"time": 20}, COLUMN, P1]}, "do": [{"say": ["n_lesson2"]}, {"ping": {"area": "west_gate"}}]},
    {"id": "intro_map", "when": {"all": [{"time": 12}, COLUMN, DRAWN, P1]}, "do": [{"say": ["v_map"]}, {"ping": {"area": "creek_road"}}]},
    {"id": "intro_sealed", "when": {"all": [{"time": 12}, COLUMN, WITHHELD, P1]}, "do": [{"say": ["v_sealed"]}]},
    {"id": "intro_barra", "when": {"all": [{"time": 30}, COLUMN, BARRA_BURNED, NO_RECLAIM, P1]}, "do": [{"say": ["v_barra_burned"]}]},
    {"id": "intro_s", "when": {"all": [{"time": 1.5}, SWARM]}, "do": [{"say": ["n_s1", "n_s2"]}, {"ping": {"area": "m2"}}, {"ping": {"area": "obidos"}}]},
    # the balloon goes up (the player sends it away from the fort)
    {"id": "balloon_up", "when": {"all": [COLUMN, P1, {"count": {"tag": "inacio", "area": "col_start", "below": 1}}, {"time": 3}]}, "do": [
        {"say": ["i_up"]}]},
    {"id": "balloon_look", "when": {"all": [COLUMN, P1, {"count": {"tag": "balloons", "area": "lookout", "at_least": 1}}]}, "do": [
        {"say": ["i_look"]}]},
    {"id": "balloon_high", "when": {"all": [COLUMN, P1, {"count": {"tag": "inacio", "area": "known_start", "below": 1}}, {"time": 3}]}, "do": [
        {"say": ["i_high"]}]},
    # ============================================================ PART 0: THE RECLAIM PART (the Barra lost)
    {"id": "reclaim_on", "when": {"all": [{"time": 2}, COLUMN, {"count": {"tag": "bat_swarm", "at_least": 1}}]}, "do": [
        {"objective": {"id": "reclaim", "set": "active"}}, {"say": ["s_bat", "v_bat"]}, {"ping": {"area": "battery"}},
        {"reveal": {"area": "battery", "side": "column"}}]},
    {"id": "bat_count", "when": {"all": [{"fired": "reclaim_on"}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "bat_left", "count": {"tag": "bat_swarm"}}}]},
    {"id": "reclaimed", "when": {"all": [{"fired": "reclaim_on"}, {"count": {"tag": "bat_swarm", "below": 1}}, LIVE]}, "do": [
        {"objective": {"id": "reclaim", "set": "done"}}, {"flag": {"reclaim": "barra"}}, {"say": ["n_bat_done"]},
        {"spawn": {"team": "column", "kind": "musketeer", "as": "barra_sergeant", "count": 1, "at": "col_start", "tag": "survivors", "tags": ["line"], "fixed": True}},
        {"spawn": {"team": "column", "kind": "musketeer", "count": 3, "at": "col_start", "tag": "survivors", "tags": ["line"], "fixed": True, "kit": KIT}},
        {"order": {"tag": "survivors", "do": "move", "to": "battery_top"}}]},
    # THE COLUMN'S PAY: Ruggieri's boats come down to the landing with pay and powder (the column has no farms)
    {"id": "pay", "when": {"all": [COLUMN, {"time": 20}, LIVE]}, "every": 20, "do": [{"give": {"team": "column", "gold": PAY_GOLD, "powder": PAY_POWDER}}]},
    {"id": "pay_chest", "when": {"all": [{"fired": "part2"}, COLUMN]}, "delay": 20, "do": [
        {"give": {"team": "column", "gold": CHEST_GOLD, "powder": 60}}, {"say": ["n_pay"]}, {"ping": {"area": "landing"}}]},
    # ============================================================ PART 1: THE NARROWS (the solo column: two raids)
] + [
    {"id": "raid_%d" % (i + 1), "when": {"all": [{"time": at}, SOLO_C, P1, LIVE]}, "do": [
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 3, "at": k, "tag": "raid%d" % (i + 1), "tags": ["raiders", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "spitter", "count": 1, "at": k, "tag": "raid%d" % (i + 1), "tags": ["raiders", "swarm_all"], "if": {"time": 60}}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 2, "at": k, "tag": "raid%d" % (i + 1), "tags": ["raiders", "swarm_all"], "if": GROWN}},
        {"order": {"tag": "raid%d" % (i + 1), "do": "route", "route": [k] + GATE_ROUTE, "attack": True, "name": "raid%d" % (i + 1)}},
        {"ping": {"area": "killground"}}] + ([{"say": ["c_gate", "n_raid", "v_raid"]}] if i == 0 else [])}
    for i, (at, k) in enumerate(RAIDS)
] + [
    {"id": "raid_push", "when": {"all": [{"fired": "raid_1"}, LIVE]}, "delay": 45, "every": 12, "times": 12, "do": [
        {"order": {"tag": "raiders", "do": "attack", "to": "obidos_mid", "idle": True}}]},
    # GROWN: Hatchlings out of the canopy after the balloon (it must keep over the guns)
    {"id": "sky_raid", "when": {"all": [{"time": 60}, SOLO_C, GROWN, P1, LIVE]}, "do": [
        {"spawn": {"team": "swarm", "kind": "hatchlings", "count": 2, "at": "m2", "tag": "sky", "tags": ["swarm_all"]}},
        {"order": {"tag": "sky", "do": "hunt", "prey": "inacio", "within": 200}}]},
    {"id": "objs_p1", "when": {"all": [{"time": 1}, COLUMN]}, "do": [
        {"objective": {"id": "balloon", "set": "active"}}, {"objective": {"id": "hold_o", "set": "active"}}]},
    # PART 2: THE FOG LIFTS: the balloon over the island (or a canoe's word, late)
    {"id": "lift_late", "when": {"all": [{"time": LIFT_LATE}, COLUMN, P1, LIVE]}, "do": []},
    {"id": "part2", "when": {"all": [COLUMN, P1, LIVE, {"time": 5}, {"any": [
        {"stay": {"tag": "balloons", "area": "lookout", "secs": LOOK_SECS}},
        {"fired": "lift_late"}]}]}, "do": [
        {"objective": {"id": "balloon", "set": "done"}}, {"objective": {"id": "hold_o", "set": "done"}},
        {"chart": {"side": "column", "team": "column", "known": ["seen_river", "seen_creeks", "island"]}},
        {"ping": {"tag": "fwd"}},
        {"objective": {"id": "fwd", "set": "active"}}, {"objective": {"id": "nests_clock", "set": "active"}}]},
    {"id": "p2_show", "when": {"all": [{"fired": "part2"}, {"not": {"fired": "lift_late"}}]}, "do": [
        {"show": {"pages": [
            {"still": "balloon", "lines": ["i_see1", "i_see2", "i_see3"]},
            {"still": "obidos", "lines": ["v_see"]}]}}]},
    {"id": "p2_late", "when": {"all": [{"fired": "part2"}, {"fired": "lift_late"}]}, "do": [{"say": ["n_lift_late", "v_see"]}]},
    {"id": "p2_say", "when": {"fired": "part2"}, "delay": 2, "do": [{"say": ["n_nests", "v_nests"]}, {"ping": {"area": "m1"}}]},
    {"id": "nests_fresh", "when": {"all": [{"fired": "part2"}, FRESH]}, "do": [{"clock": {"name": "nests", "secs": NESTS_FRESH}}]},
    {"id": "nests_grown", "when": {"all": [{"fired": "part2"}, GROWN]}, "do": [{"clock": {"name": "nests", "secs": NESTS_GROWN}}]},
    # GROWN: two more up the west creek and the upriver bank, still under the fog (the balloon must go west)
    {"id": "west_say", "when": {"all": [{"fired": "part2"}, GROWN, SOLO_C]}, "delay": 14, "do": [
        {"say": ["i_west"]}, {"objective": {"id": "west", "set": "active"}}, {"ping": {"area": "west_sky"}}]},
    {"id": "west_seen", "when": {"all": [{"fired": "west_say"}, {"charted": {"area": "m4", "at_least": 0.5}}]}, "do": [
        {"objective": {"id": "west", "set": "done"}}, {"say": ["n_west_seen"]}, {"ping": {"area": "m4"}}]},
    # ============================================================ PART 2: THE NESTS (the solo column)
    # GROWN: the scripted Toads lay their fog over their Mothers when the column comes near
    {"id": "toad_fog", "when": {"all": [{"fired": "part2"}, GROWN, SOLO_C, LIVE]}, "every": TOAD_EVERY, "do": [
        {"cast": {"tag": "toads", "spell": "fog", "near_foe": 9}}]},
    {"id": "toad_say", "when": {"all": [{"fired": "toad_fog"}, GROWN, {"count": {"tag": "toads", "at_least": 1}},
                                        {"near": {"team": "column", "to": "toads", "within": 9}}]}, "do": [
        {"say": ["n_toad_fog", "v_fog"]}]},
    {"id": "gate_say", "when": {"all": [{"fired": "wave_2"}, SOLO_C]}, "delay": 6, "do": [{"say": ["c_gate2"]}]},
    {"id": "lured_say", "when": {"lured": "obidos_lure"}, "delay": 2, "do": [{"say": ["n_lured"]}]},
    {"id": "fwd_dead_say", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "fwd_killed", "at_least": 1}}]}, "do": [
        {"say": ["n_fwd_dead", "v_fwd_dead"]}]},
    # every nest broken (before the rains: `jungle` held), or the rains (thin)
    {"id": "nests_broken", "when": {"all": [{"fired": "setup"}, {"counter": {"name": "fwd_left", "below": 1}}, {"fired": "part2"}, LIVE]}, "do": [
        {"say": ["n_broken_all"]}]},
]
for i in range(WAVES_MAX):
    TR_ += wave_triggers(i, WAVE_FIRST + WAVE_EVERY * i)
TR_ += [
    # ============================================================ PART 3: THE ISLAND (the solo column)
    {"id": "part3", "when": {"all": [{"fired": "part2"}, SOLO_C, LIVE, {"any": [{"fired": "nests_broken"}, {"clock_out": "nests"}]}]}, "delay": 3, "do": [
        {"flag": {"jungle": "held", "if": {"fired": "nests_broken"}}}, {"flag": {"jungle": "thin", "if": {"not": {"fired": "nests_broken"}}}},
        {"objective": {"id": "fwd", "set": "done", "if": {"fired": "nests_broken"}}},
        {"objective": {"id": "fwd", "set": "failed", "if": {"not": {"fired": "nests_broken"}}}},
        {"say": ["n_rains"], "if": {"not": {"fired": "nests_broken"}}},
        {"clock": {"name": "nests", "stop": True}}, {"objective": {"id": "nests_clock", "set": "hidden"}},
        {"objective": {"id": "west", "set": "hidden", "if": {"not": {"fired": "west_seen"}}}},
        {"objective": {"id": "island", "set": "active"}}, {"say": ["v_island", "n_island"]}, {"ping": {"area": "isl_ruins"}},
        {"ping": {"area": "ford_w"}}, {"ping": {"area": "ford_e"}},
        {"light": {"to": "jungle_dusk", "secs": 300}}]},
    {"id": "flood", "when": {"all": [{"fired": "part3"}, {"not": {"fired": "nests_broken"}}, {"count": {"tag": "fwd", "at_least": 1}}, LIVE]}, "delay": 6, "do": [
        {"say": ["n_flood"]}, {"ping": {"area": "killground"}}] + [
        a for k in SITE_IF for a in [
            {"spawn": {"team": "swarm", "kind": "raptor", "count": 4, "at": k, "tag": "flood", "tags": ["swarm_all"], "if": {"count": {"tag": "fwd_" + k, "at_least": 1}}}},
            {"spawn": {"team": "swarm", "kind": "spitter", "count": 1, "at": k, "tag": "flood", "tags": ["swarm_all"], "if": {"count": {"tag": "fwd_" + k, "at_least": 1}}}}]]},
    {"id": "flood_go", "when": {"fired": "flood"}, "delay": 4, "do": [
        {"order": {"tag": "flood", "do": "attack", "to": "obidos_mid"}}]},
    {"id": "flood_push", "when": {"all": [{"fired": "flood_go"}, LIVE]}, "delay": 40, "every": 12, "times": 10, "do": [
        {"order": {"tag": "flood", "do": "attack", "to": "keep_go", "idle": True}}]},
    {"id": "isl_count", "when": {"all": [{"fired": "part3"}, LIVE]}, "every": 2, "do": [
        {"counter": {"name": "isl_left", "count": {"tag": "isl_ground"}}}]},
    {"id": "isl_near", "when": {"all": [{"fired": "part3"}, {"near": {"team": "column", "to": "old_mound", "within": 14}}]}, "do": [{"say": ["i_ruins"]}]},
    {"id": "isl_broken", "when": {"all": [{"fired": "part3"}, {"count": {"tag": "isl_ground", "below": 1}}, LIVE]}, "do": [
        {"objective": {"id": "island", "set": "done"}}, {"flag": {"island": "burned"}}, {"say": ["n_isl_done"]},
        {"ground": {"name": "isl", "stop": True}}]},
    {"id": "lw_late", "when": {"fired": "part3"}, "delay": LW_LATE, "do": []},
    # THE LAST WAVE: down the levee from upriver, half to the island, half to Óbidos
    {"id": "last_wave", "when": {"all": [{"fired": "part3"}, LIVE, {"any": [{"fired": "isl_broken"}, {"fired": "lw_late"}]}]}, "delay": 4, "do": [
        {"objective": {"id": "last", "set": "active"}}, {"objective": {"id": "ebb_clock", "set": "active"}},
        {"clock": {"name": "ebb", "secs": EBB_SECS, "scale": False}},
        {"say": ["i_last", "n_last", "c_last"]}, {"ping": {"area": "lw_stage"}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 6, "at": "lw_stage", "tag": "lw_a", "tags": ["lw", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "spitter", "count": 2, "at": "lw_stage", "tag": "lw_a", "tags": ["lw", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "tyrant_challenger", "count": 1, "at": "lw_stage", "tag": "lw_a", "tags": ["lw", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "brute", "count": 1, "at": "lw_stage", "tag": "lw_a", "tags": ["lw", "swarm_all"], "fixed": True}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 5, "at": "lw_stage", "tag": "lw_b", "tags": ["lw", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "spitter", "count": 2, "at": "lw_stage", "tag": "lw_b", "tags": ["lw", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "tyrannosaur", "count": 1, "at": "lw_stage", "tag": "lw_b", "tags": ["lw", "swarm_all"], "fixed": True,
                   "if": NOT_BURNED_CLUTCH}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 3, "at": "lw_stage", "tag": "lw_b", "tags": ["lw", "swarm_all"], "if": BN_ALL}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 4, "at": "lw_stage", "tag": "lw_a", "tags": ["lw", "swarm_all"], "if": GROWN}},
        {"spawn": {"team": "swarm", "kind": "venom_challenger", "count": 1, "at": "lw_stage", "tag": "lw_b", "tags": ["lw", "swarm_all"], "if": GROWN}},
        {"spawn": {"team": "swarm", "kind": "mist_toad", "count": 1, "at": "lw_stage", "tag": "lw_a", "tags": ["lw", "swarm_all", "toads"], "if": GROWN}},
        {"spawn": {"team": "swarm", "kind": "mist_toad", "count": 1, "at": "lw_stage", "tag": "lw_b", "tags": ["lw", "swarm_all", "toads"], "if": GROWN}}]},
    {"id": "lw_count", "when": {"fired": "last_wave"}, "delay": 0.5, "do": [{"counter": {"name": "lw_n", "count": {"tag": "lw"}}}]},
    {"id": "lw_go", "when": {"fired": "last_wave"}, "delay": 5, "do": [
        {"order": {"tag": "lw_a", "do": "route", "route": ["lw_stage", "levee_w", "ford_w_n", "ford_w", "isl_w", "isl_ruins"], "attack": True, "name": "lw_a"}},
        {"order": {"tag": "lw_b", "do": "route", "route": ["lw_stage", "levee_far", "levee_w", "levee_m", "levee_e"] + GATE_ROUTE, "attack": True, "name": "lw_b"}}]},
    {"id": "lw_toads", "when": {"all": [{"fired": "lw_go"}, GROWN, LIVE]}, "every": TOAD_EVERY, "do": [
        {"cast": {"tag": "toads", "spell": "fog", "near_foe": 9}}]},
    {"id": "lw_push", "when": {"all": [{"fired": "lw_go"}, LIVE]}, "delay": 50, "every": 12, "do": [
        {"order": {"tag": "lw_a", "do": "attack", "to": "isl_ruins", "idle": True}},
        {"order": {"tag": "lw_b", "do": "attack", "to": "obidos_mid", "idle": True}}]},
    # (d08 `lure` used: they come to the smell of it: one wave more)
    {"id": "smell", "when": {"all": [{"fired": "lw_go"}, LURE_USED, LIVE]}, "delay": 40, "do": [
        {"say": ["n_smell"]}, {"ping": {"area": "lure_spot"}},
        {"spawn": {"team": "swarm", "kind": "raptor", "count": 6, "at": "m1", "tag": "lw_c", "tags": ["lw", "swarm_all"]}},
        {"spawn": {"team": "swarm", "kind": "spitter", "count": 2, "at": "m1", "tag": "lw_c", "tags": ["lw", "swarm_all"]}}]},
    {"id": "smell_go", "when": {"fired": "smell"}, "delay": 3, "do": [
        {"order": {"tag": "lw_c", "do": "route", "route": ["m1", "lure_spot"] + GATE_ROUTE, "attack": True, "name": "lw_c"}}]},
    # (the last few of the wave, beaten, go back up the levee: nobody waits for the ebb over a straggler)
    {"id": "lw_ebb", "when": {"all": [{"fired": "lw_go"}, {"count": {"tag": "lw", "below": 4}}, {"not": {"fired": "lw_broken"}}, LIVE,
                                      {"any": [{"not": LURE_USED}, {"fired": "smell_go"}]}]}, "delay": 20, "do": [
        {"order": {"tag": "lw", "do": "move", "to": "lw_stage"}}]},
    {"id": "lw_gone", "when": {"all": [{"fired": "lw_ebb"}, LIVE]}, "delay": 8, "do": [{"remove": {"tag": "lw"}}]},
    {"id": "lw_broken", "when": {"all": [{"fired": "lw_go"}, {"count": {"tag": "lw", "below": 1}}, LIVE,
                                         {"any": [{"not": LURE_USED}, {"fired": "smell_go"}]}]}, "delay": 2, "do": []},
    {"id": "ebb", "when": {"all": [{"fired": "last_wave"}, {"any": [{"fired": "lw_broken"}, {"clock_out": "ebb"}]}, SOLO_C, LIVE]}, "delay": 2, "do": [
        {"objective": {"id": "last", "set": "done"}}, {"objective": {"id": "ebb_clock", "set": "done"}}, {"clock": {"name": "ebb", "stop": True}},
        {"objective": {"id": "island", "set": "failed", "if": {"not": {"fired": "isl_broken"}}}},
        {"flag": {"island": "standing", "if": {"not": {"fired": "isl_broken"}}}},
        {"light": {"to": "grey_dawn", "secs": 8}}, {"say": ["n_ebb", "v_won", "i_won"]},
        {"order": {"tag": "swarm_all", "do": "move", "to": "lw_stage"}}]},
    # ============================================================ THE END (the column)
    {"id": "the_end", "when": {"fired": "ebb"}, "delay": 6, "do": [{"flag": {"inacio": "joined"}}, {"win": "column"}]},
    {"id": "keep_lost", "when": {"dead": "keep"}, "do": [{"say": ["n_keep_lost"]}]},
    # ============================================================ VERSUS: the column breaks the nests down to one
    {"id": "vs_broke", "when": {"all": [COLUMN, SWARM, {"fired": "setup"}, {"counter": {"name": "fwd_left", "below": 2}}, LIVE]}, "do": [
        {"objective": {"id": "v_break", "set": "done"}}, {"say": ["n_s_lost"]},
        {"flag": {"jungle": "held"}}, {"flag": {"island": "standing"}}, {"flag": {"inacio": "joined"}}]},
    {"id": "vs_end", "when": {"fired": "vs_broke"}, "delay": 4, "do": [{"win": "column"}]},
    # ============================================================ THE SWARM (the solo pick, versus)
    {"id": "s_objs", "when": {"all": [{"time": 1}, SWARM]}, "do": [
        {"objective": {"id": "s_hold", "set": "active"}}, {"objective": {"id": "s_obidos", "set": "active"}},
        {"objective": {"id": "s_clock", "set": "active"}}]},
    {"id": "s_left", "when": {"all": [SWARM, {"fired": "setup"}, LIVE]}, "every": 2, "do": [{"counter": {"name": "fwd_left", "count": {"tag": "fwd"}}}]},
    {"id": "s_mother_say", "when": {"all": [SWARM, {"counter": {"name": "fwd_killed", "at_least": 1}}]}, "do": [{"say": ["n_s_mother"]}]},
    # (the river's drowned game feeds the swarm a little at a time: laying never stalls for want of food)
    {"id": "s_food", "when": {"all": [SWARM, {"time": 10}, LIVE]}, "every": 10, "do": [
        {"give": {"team": "swarm", "gold": RIVER_FOOD, "powder": RIVER_SPOILS}}]},
    {"id": "s_lost", "when": {"all": [SWARM, NO_COLUMN, {"fired": "setup"}, {"counter": {"name": "fwd_left", "below": 2}}, LIVE]}, "do": [
        {"say": ["n_s_lost"]}, {"objective": {"id": "s_hold", "set": "failed"}}, {"flag": {"jungle": "held"}}]},
    {"id": "s_lost_end", "when": {"fired": "s_lost"}, "delay": 4, "do": [{"win": "column"}]},
    {"id": "s_dry", "when": {"all": [SWARM, {"clock_out": "dry"}, LIVE, {"counter": {"name": "fwd_left", "at_least": 2}}]}, "do": [
        {"objective": {"id": "s_hold", "set": "done"}}, {"say": ["n_s_won"]}, {"flag": {"jungle": "thin"}}, {"flag": {"island": "standing"}}]},
    {"id": "s_keep", "when": {"all": [SWARM, {"dead": "keep"}, LIVE]}, "do": [
        {"objective": {"id": "s_obidos", "set": "done"}}, {"say": ["n_s_keep"]}, {"flag": {"jungle": "thin"}}, {"flag": {"island": "standing"}}]},
    {"id": "s_end", "when": {"any": [{"fired": "s_dry"}, {"fired": "s_keep"}]}, "delay": 4, "do": [{"win": "swarm"}]},
    # the scripted column (the swarm played alone): out of Óbidos after the nests, the balloon over it; boats bring men
    {"id": "sc_go", "when": {"all": [{"time": SC_GO}, NO_COLUMN, LIVE, {"any": [GROWN, {"time": SC_GO + SC_FRESH_LATE}]}]}, "do": [
        {"say": ["n_s_col"]}, {"ping": {"area": "killground"}}]},
] + [
    # (the column as one body, Mother after Mother, nearest first; the guns, the wagon and the balloon with Valadares)
    {"id": "sc_to_" + k, "when": {"all": [{"fired": "sc_go"}, NO_COLUMN, LIVE, {"count": {"tag": "fwd_" + k, "at_least": 1}},
                                          {"count": {"tag": "line", "at_least": SC_MARCH}}]
                                  + [{"count": {"tag": "fwd_" + p, "below": 1}} for p in list(SITE_IF)[:i]]}, "every": 15, "do": [
        {"order": {"tag": "line", "do": "attack", "to": k}}, {"order": {"tag": "riders", "do": "attack", "to": k}},
        {"order": {"tag": "valadares", "do": "attack", "to": k}},
        {"order": {"tag": "guns", "do": "follow", "leader": "valadares", "within": 4}},
        {"order": {"tag": "wagons", "do": "follow", "leader": "valadares", "within": 4}},
        {"order": {"tag": "inacio", "do": "follow", "leader": "valadares", "within": 3}}]}
    for i, k in enumerate(SITE_IF)
] + [
    # (too few to march: back under the guns to wait for the boats)
    {"id": "sc_regroup", "when": {"all": [{"fired": "sc_go"}, NO_COLUMN, LIVE, {"count": {"tag": "line", "below": SC_MARCH}}]}, "every": 15, "do": [
        {"order": {"tag": "line", "do": "move", "to": "killground"}}, {"order": {"tag": "riders", "do": "move", "to": "killground"}},
        {"order": {"tag": "valadares", "do": "move", "to": "killground"}}]},

    {"id": "sc_reinf", "when": {"all": [{"time": 90}, NO_COLUMN, LIVE]}, "every": SC_REINF, "do": [
        {"spawn": {"team": "column", "kind": "musketeer", "count": 3, "at": "landing_e", "tag": "line", "tags": ["reinf"], "kit": KIT}},
        {"say": ["n_s_reinf"]}]},
    # (before the march the riders probe a nest and ride back: the swarm's player has something to answer early)
    {"id": "sc_probe", "when": {"all": [{"time": 45}, NO_COLUMN, LIVE, {"count": {"tag": "riders", "at_least": 1}}]}, "every": 75, "times": 3, "do": [
        {"order": {"tag": "riders", "do": "attack", "to": "m1"}}, {"say": ["n_s_probe"]}, {"ping": {"area": "m1"}}]},
    {"id": "sc_probe_back", "when": {"all": [{"fired": "sc_probe"}, NO_COLUMN, LIVE]}, "delay": 30, "every": 75, "times": 3, "do": [
        {"order": {"tag": "riders", "do": "move", "to": "killground"}}]},
    # ============================================================ HURTS
    {"id": "v_hurt", "when": {"all": [{"hp": {"tag": "valadares", "below": 0.4}}, COLUMN]}, "every": 60, "times": 2, "do": [
        {"say": ["v_hurt"]}, {"ping": {"tag": "valadares"}}]},
    {"id": "i_hurt", "when": {"all": [{"hp": {"tag": "inacio", "below": 0.4}}, COLUMN]}, "every": 60, "times": 2, "do": [
        {"say": ["i_hurt"]}, {"ping": {"tag": "inacio"}}]},
]
# (an "if" inside an action's dictionary is not read by the engine: split those into triggers of their own)
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

# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the column is bound to C8 (THE OBSERVATION BALLOON), the swarm (the
# solo pick, versus) to B7 (THE MIST TOAD, FOG BANK, MIASMA); the story's deny on top for the column (a column away from
# its halls: it trains at Óbidos' Barracks and Foundry, builds nothing)
sys.path.insert(0, HERE)
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID, story_deny={"column": ["town_hall", "cottage", "farm", "wall", "gate", "labourer", "messenger", "church",
                                                   "missionary", "powder_mill", "barracks", "horse_breeder", "foundry", "armoury"]})
roster_ladder.apply(M, MID, faction="brood")
for k in ("balloon", "mist_toad", "nb_fog", "nb_miasma"):
    T(M["lines"]["new_" + k]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hubs' talks after d10 (campaign/campaign.json, campaign/hubs_grow.json)
HUB = {
    # the King's study: the King, Ruggieri's dispatch; the Naturalist's hub: Valadares (Valadares' quarters at the Barra)
    "king": [
        ({"after": "d10_jungle", "flag": {"d10_jungle.jungle": "held"}},
         ("Valadares broke every nest on the lower river before the rains. A priest in a basket showed him where.",
          "Valadares quebrou todos os ninhos do baixo rio antes das chuvas. Um padre num cesto mostrou-lhe onde.",
          "Valadares rompió todos los nidos del bajo río antes de las lluvias. Un cura en un cesto le mostró dónde.")),
        ({"after": "d10_jungle", "flag": {"d10_jungle.jungle": "thin"}},
         ("Valadares held Óbidos. Some of their nests outlived the rains, and the river above it was theirs that year.",
          "Valadares segurou Óbidos. Alguns ninhos sobreviveram às chuvas, e o rio acima foi deles nesse ano.",
          "Valadares sostuvo Óbidos. Algunos nidos sobrevivieron a las lluvias, y el río por encima fue suyo aquel año.")),
    ],
    "dispatch": [
        ({"after": "d10_jungle"},
         ("Óbidos, the lower Amazon. The column's work is done; the priest's balloon has mapped the river from the narrows to the bend.",
          "Óbidos, o baixo Amazonas. O trabalho da coluna está feito; o balão do padre cartografou o rio do estreito até à curva.",
          "Óbidos, el bajo Amazonas. El trabajo de la columna está hecho; el globo del cura ha cartografiado el río desde el estrecho hasta la curva.")),
    ],
    "valadares": [
        ({"after": "d10_jungle"},
         ("Father Inácio drew the river from above. My maps are better for it. I tell him so, and he laughs.",
          "O Padre Inácio desenhou o rio de cima. Os meus mapas ficaram melhores. Digo-lho, e ele ri-se.",
          "El Padre Inácio dibujó el río desde arriba. Mis mapas son mejores por ello. Se lo digo, y se ríe.")),
        ({"after": "d10_jungle", "flag": {"d10_jungle.island": "burned"}},
         ("We burned the old ground on Lindqvist's island. The ruin is ash. I did not feel what I thought I would.",
          "Queimámos o chão velho na ilha de Lindqvist. A ruína é cinza. Não senti o que pensava que ia sentir.",
          "Quemamos el suelo viejo en la isla de Lindqvist. La ruina es ceniza. No sentí lo que pensaba que sentiría.")),
        ({"after": "d10_jungle", "sides": {"d10_jungle": "swarm"}},
         ("In that telling the river stayed green. In mine we broke the nests, and I was there.",
          "Nesse relato o rio ficou verde. No meu quebrámos os ninhos, e eu estava lá.",
          "En ese relato el río siguió verde. En el mío rompimos los nidos, y yo estaba allí.")),
    ],
}
RUGGIERI_GROW = ("The jungle column came home, Highness. Valadares sends you a map drawn from a balloon. I have hung it in the armoury.",
                 "A coluna da selva voltou, Alteza. Valadares manda-vos um mapa desenhado de um balão. Pendurei-o no arsenal.",
                 "La columna de la selva volvió, Alteza. Valadares os manda un mapa dibujado desde un globo. Lo he colgado en la armería.")
OTHER = [
    ("Father Inácio", "Padre Inácio", "Padre Inácio"),
    ("Father Inácio Lourenço, priest and aeronaut, in his own balloon: he sees over the canopy.",
     "O Padre Inácio Lourenço, padre e aeronauta, no seu próprio balão: vê por cima da copa.",
     "El Padre Inácio Lourenço, cura y aeronauta, en su propio globo: ve por encima de la copa."),
    ("A Brood Mother of the swarm, rooted on the river's bank: what she lays comes down the levee.",
     "Uma Mãe da Ninhada do enxame, enraizada na margem do rio: o que ela põe desce o dique.",
     "Una Madre de la Prole del enjambre, enraizada en la orilla del río: lo que pone baja por el dique."),
    ("The old mound", "O velho monte", "El viejo montículo"),
    ("The swarm's oldest ground, on the ruins of Lindqvist's fazenda: a great Mound Turtle rooted there for years.",
     "O chão mais antigo do enxame, nas ruínas da fazenda de Lindqvist: uma grande Tartaruga-Monte enraizada lá há anos.",
     "El suelo más antiguo del enjambre, en las ruinas de la fazenda de Lindqvist: una gran Tortuga Montículo enraizada allí desde hace años."),
    ("The captain of Óbidos", "O capitão de Óbidos", "El capitán de Óbidos"),
    ("The captain of the fort at Óbidos, on the narrows of the Amazon.", "O capitão do forte de Óbidos, no estreito do Amazonas.",
     "El capitán del fuerte de Óbidos, en el estrecho del Amazonas."),
    RUGGIERI_GROW,
] + [txt for rows in HUB.values() for (_, txt) in rows]
for (en, pt, es) in OTHER:
    T(en, pt, es)


def patch_campaign():
    """campaign/campaign.json: d10 joins the Crown line after d09 (the crossing's branch); the hubs' talks after d10
    (entries appended, so a talk's last entry that holds is the newest). campaign/hubs_grow.json: Ruggieri after d10.
    Idempotent: a second run changes nothing."""
    p = os.path.join(ROOT, "campaign", "campaign.json")
    c = json.load(open(p, encoding="utf-8"))
    for sl in c["storylines"]:
        ms = sl["missions"]
        if sl["id"] == "prologue" and MID not in ms:
            ms.insert(ms.index("d09_crossroads") + 1, MID)
        talks = sl.get("hub", {}).get("talks", {})
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
    p2 = os.path.join(ROOT, "campaign", "hubs_grow.json")
    s = open(p2, encoding="utf-8").read()
    if RUGGIERI_GROW[0] not in s:
        old = '"lines": ["The fort held, Highness. Two sieges in a week and a council in an evening. I chose, and I have not slept well since."]}'
        assert old in s
        s = s.replace(old, old + ',\n   {"after": "d10_jungle", "lines": ["%s"]}' % RUGGIERI_GROW[0], 1)
        open(p2, "w", encoding="utf-8").write(s)


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
rows = ["# Act 2's mission d10_jungle, \"The Jungle Front\" (campaign/missions/d10_jungle.json, written with its texts by",
        "# tools/campaign/make_d10_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what was",
        "# built: docs/campaign_d10_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names: forward Mother = Mãe avançada / Madre",
        "# de avanzada; levee = dique / dique; shallows = baixios / bajíos; balloon = balão / globo; Mist Toad = Sapo da Névoa / Sapo de Niebla.", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
