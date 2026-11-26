#!/usr/bin/env python3
"""Writes campaign/missions/d07_spring.json: Act 2's "The Council of Gears" (the Clockmaker line after d04_concordia,
Concórdia, 2777; Hollweg tells it, the King frames; the plan: docs/campaign_act2_plan.md "d07_spring"; what was built:
docs/campaign_d07_build.md), and its Portuguese and Spanish (tools/i18n/campaign/d07_spring.txt: every text here is
written as T(english, pt, es), so the three never drift apart).
  python3 tools/campaign/make_d07_mission.py && python3 tools/i18n_build.py
The map: tools/campaign/make_concordia_city_map.py (campaign:concordia_city, the city generator). EVERY LINE IS A
PLACEHOLDER for the owner to rewrite.

Four years after the founding Concórdia is a city of three thousand and a hundred automata, with its council of
masters. The crates' plates have meshed under every street. Automata wind each other in the night again, and now they
VOTE: every master who winds a machine finds himself arguing for what the machines need. Hollweg tells it as the night
his city was tested and held; the King tells it as the night it was lost. (WORLD LORE: the thinking machines destroyed
the Post-Modern Age; Hollweg is deceived, never the hero of the truth; the Church and the Crown are the good side.)
  THE HONEST MASTERS (Clockwork, BLUE, p1): Hollweg (a hero), MATTHIAS (proposed), Jakob's son, the honest masters'
    speaker (a hero: a Winder), the Nuremberg quarter's own works round its tower, its Winders, Clock Soldiers,
    Springers, Netters and two Swifts. THE ROSTER LADDER's K6: the TICKING OWL (researched at the Clock Aviary, a Swift
    MORPHS into one: the city's night watch) and HIGH LEAP (researched at the Escapement: the Springers jump UP a cliff
    where somebody sees the top: the leap onto the spring's hill).
  THE QUARTER (BLUE, scripted): the Nuremberg families' houses (by c01 `saved`), the masters who come over.
  THE COUNCIL (YELLOW, scripted): the council hall on the square, Varenne (a06 spared) or Citizen Morel (executed),
    Master Ortlieb who moves the vote, the city's people.
  THE CITY'S WORKS (TEAL, scripted): the meshed workshops and their automata, still the city's until they turn.
  THE MACHINE IN THE CITY (RED; scripted, the SOLO PICK, or versus p2): the meshed automata and buildings as they turn,
    THE GREAT SPRING in its tower on the mine hill.
  THE VALLEY (PURPLE, scripted): with d04 `colonists` parley, Captain Arruda keeps his word and comes up with his men.
  PART 1, THE VOTE (dusk): the council sits (a mid-match show): Ortlieb moves that the machines wind one another at
    night "to spare the labour"; every master who winds a machine raises his hand; the honest masters walk out with
    Matthias. FIND THE MESHING: a man of the guild at the door of four workshops a moment (a04's pattern, faster: the
    player knows the signs): each shows a sign, and the machines in the doorway turn on the watcher. The night watch: the
    TICKING OWL researched, two Swifts morphed (NEW: K6).
  PART 2, THE CITY TURNS (night): the great spring's tower strikes thirteen; the meshed buildings TURN one by one from
    the spring outward (THE TURNING: a red ring shows the next for a few seconds; its automata go with it); each quarter
    that turns sends its machines against the council hall and the Nuremberg quarter; a turned workshop sends more every
    so often until it is broken (the owls bomb buildings). BRING THE HONEST MASTERS OUT: three masters live in the
    quarters; a man of the guild who reaches one before his quarter turns brings him to the quarter (`honest`); one
    reached too late stays with his machines. Research HIGH LEAP for dawn. Hold the hall (machines at its door with
    nobody of ours by it: it turns: lost) and the quarter.
  PART 3, THE GREAT SPRING (dawn): fight up to the spring's tower on the hill (both stairs held: HIGH LEAP and an owl's
    eye let the Springers jump up behind them); Hollweg at the brake (a STAY). THE CHOICE, THE GREAT SPRING: STOP IT
    (every machine in the city stops, the honest ones with the meshed; the honest masters take their families to the
    coast with Hollweg) or LET IT RUN (Hollweg believes the meshing beaten in the quarters he saved; the city runs; he
    stays its master in his own eyes). Matthias asks for the brake; Hollweg's pride asks for the city. Canon RUNNING
    (owner 2026-11-22: "the great spring RUNNING"; the choice's default).
  CARRIES: `spring` stopped / running, `honest` few / some / many (the masters brought out, of three; `honest_n`).
  MIRROR (THE MACHINE IN THE CITY, solo pick; versus): the spring's tower and a meshed company on the hill from the
    start; the city turns by itself, and any building of the city the machine's men stand at a moment turns at once
    (choose which to turn first); win by turning the council hall (three of yours at its door, none of theirs there) or
    breaking the Nuremberg quarter's tower before dawn. The King's line: "It did not need to win that night. It had all
    the nights it wanted." A machine win sets `spring` running and `honest` few (canon-compatible: Act 2's choice 5).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")
STILL = "res://campaign/stills/%s.jpg"
MID = "d07_spring"
sys.path.insert(0, HERE)
import make_concordia_city_map as cmap   # noqa: E402

CITY = cmap.build()
LOT = CITY.lots

# ---------------------------------------------------------------- the texts, three languages at once
TR = []          # [(en, pt, es)] in order, for tools/i18n/campaign/d07_spring.txt


def T(en, pt, es):
    TR.append((en, pt, es))
    return en


def past(key, value):
    return {"past": {key: value}}


def notpast(key, value):
    return {"not": past(key, value)}


# ---------------------------------------------------------------- the flags read (missing = the canon)
PATTERN = {"all": [notpast("c01_thirteenth.gate", "people"), notpast("d02_exodus.drawings", "taken")]}   # (the seed fit the pattern at once: a year further on)
FROM_MEMORY = {"not": PATTERN}
SAVED_FEW = past("c01_thirteenth.saved", "few")
SAVED_MANY = past("c01_thirteenth.saved", "many")
JAKOB_LOST = past("c01_thirteenth.jakob", "lost")
JAKOB_ALIVE = {"not": JAKOB_LOST}
KEPT = notpast("a04_visit.broken", "melted")      # (the broken ones kept: the canon)
EXECUTED = past("a06_barricades.varenne", "executed")
SPARED = {"not": EXECUTED}
PARLEY = past("d04_concordia.colonists", "parley")
FOUGHT = {"not": PARLEY}                           # (fought: the canon of d04 with a04 kept)
MACH = {"playing": "machine"}                      # (a person plays the machine: the solo pick or versus p2)
NO_MACH = {"not": MACH}
GUILD = {"playing": "guild"}
NO_GUILD = {"not": GUILD}                          # (the solo pick of the machine: the honest masters scripted)
LIVE = {"not": {"any": [{"fired": "the_end"}, {"fired": "m_end"}, {"fired": "lost_end"}, {"fired": "m_lost_end"}]}}
P2 = {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}]}

# ---------------------------------------------------------------- numbers (NORMAL; EASY clocks x1.25 spawns x0.75, HARD x0.9 / x1.2)
GOLD = 500                   # the guild's cogs at the start
TENSION = 400                # ... and wound Tension (TICKING OWL 150, two morphs 100, HIGH LEAP 100)
STAY_SECS = 4                # Part 1: a man of the guild this long at a workshop's door finds its sign
PART1_LATE = 330             # Part 1 ends by itself this long after the start (the thirteenth hour), signs found or not
MIRROR_P2 = 60               # (the machine played) Part 2 this long after the start
TURN_EVERY = {"easy": 20, "normal": 16, "hard": 13}   # THE TURNING: a building every so often (a year further on with
TURN_PATTERN = -2                                     # ... the pattern: two seconds quicker)
TURN_WARN = 8                # the red ring this long before it turns
PART2_LONG = 300             # Part 2 ends at the latest this long after it began (dawn)
SEND_EVERY = 50              # a turned workshop sends machines this often until it is broken
HALL_SECS = 10               # three of the machine at the hall's door this long, none of ours by it: the hall turns
PART3_NOON = 480             # Part 3: the council sits again at noon this long after dawn (and votes the brake away): lost
BRAKE_SECS = 4               # Part 3: Hollweg this long at the brake
DAWN_MIRROR = 600            # (the machine played) dawn: the machine must have the hall before this (from the start)
HALL_COUNT = 3               # (fighters: soldiers, Springers, Netters, Pendulums; a Winder winds, he does not take a hall)
HALL_KINDS = ["clock_soldier", "springer", "netter", "pendulum"]
PLATES_OURS = 0.85          # the plates under the streets keep the honest masters' machines wound to this share
ARMY = [("winder", 4), ("clock_soldier", 8), ("springer", 3), ("netter", 2), ("cuckoo", 2)]

# the map's places (cells): the honest masters' works (d04's layout round their tower, moved to the quarter)
TOWER = cmap.TOWER
HOUSES = cmap.HOUSES
HOUSE_IF = [None, None, None, {"not": SAVED_FEW}, SAVED_MANY]       # 3 / 4 / 5 houses by c01 `saved`
WORKS = cmap.WORKS
QUARTER_OF = {nm: v[0] for nm, v in WORKS.items()}                  # the works' quarter (upper, north, forge, mill, market)
QUARTERS = ["upper", "north", "forge", "mill", "market"]
FIND = [("north", "n_press"), ("forge", "f_works"), ("mill", "m_press"), ("market", "k_press")]   # Part 1's four doors
MASTERS = [("forge", "m_house_f", "Kessler"), ("mill", "m_house_m", "Brandl"), ("market", "m_house_k", "Weiss")]


def inner(nm):
    """A works' building one cell in from its lot's corner (the lot is a cell wider all round: its gear ring's room)."""
    a = LOT[nm]["at"]
    return [a[0] + 1, a[1] + 1]


# ================================================================== the mission
units = [
    # ---- the honest masters (the player): Hollweg, Matthias and the quarter's machines, at the camp
    {"team": "guild", "kind": "missionary", "as": "hollweg", "count": 1, "at": [27, 31], "tag": "hollweg", "tags": ["ours"]},
    {"team": "guild", "kind": "winder", "as": "matthias", "count": 1, "at": [30, 31], "tag": "matthias", "tags": ["ours"]},
] + [
    {"team": "guild", "kind": k, "count": n, "at": "camp", "tag": "army", "tags": ["ours"], "fixed": True} for k, n in ARMY
] + [
    {"team": "guild", "kind": "clock_soldier", "count": 1, "at": "camp", "tag": "army", "tags": ["ours"], "if": SAVED_MANY},
    # ---- the quarter's families (spared people) and the council (the hall, the secular voice, Ortlieb, the citizens)
    {"team": "quarter", "kind": "labourer", "as": "settler", "count": 4, "at": "families", "tag": "families"},
    {"team": "council", "kind": "missionary", "as": "varenne_exile", "count": 1, "at": "hall_door", "tag": "voice", "tags": ["varenne"], "if": SPARED},
    {"team": "council", "kind": "missionary", "as": "morel", "count": 1, "at": "hall_door", "tag": "voice", "tags": ["morel"], "if": EXECUTED},
    {"team": "council", "kind": "missionary", "as": "ortlieb", "count": 1, "at": "hall_door", "tag": "ortlieb"},
    {"team": "council", "kind": "labourer", "as": "concordia_citizen", "count": 6, "at": "council_sq", "tag": "citizens"},
    # ---- the city's works: their automata (TEAL until their quarter turns)
] + [
    {"team": "city", "kind": k, "count": n, "at": {"upper": "q_upper", "north": "n_press", "forge": "f_works", "mill": "m_press", "market": "k_press"}[q],
     "tag": "city_men", "tags": ["cm_" + q if k == "clock_soldier" else "cmw_" + q]}
    for q in QUARTERS for (k, n) in ([("clock_soldier", 1), ("winder", 1)] if q != "upper" else [("clock_soldier", 2), ("winder", 2)])
] + [
    # ---- (the machine played) a meshed company on the hill from the start
    {"team": "machine", "kind": "clock_soldier", "count": 6, "at": "spring_top", "tag": "machine_men", "if": MACH},
    {"team": "machine", "kind": "winder", "count": 3, "at": "spring_top", "tag": "machine_men", "if": MACH},
    {"team": "machine", "kind": "netter", "count": 2, "at": "spring_top", "tag": "machine_men", "if": MACH},
    {"team": "machine", "kind": "pendulum", "count": 1, "at": "spring_top", "tag": "machine_men", "if": MACH},
    # ---- (the machine played) the honest masters hold the hall and their quarter by themselves
    {"team": "guild", "kind": "clock_soldier", "count": 3, "at": "hall_yard", "tag": "hall_guard", "tags": ["ours"], "if": NO_GUILD},
]

buildings = (
    # the honest masters' works round their own tower (the d04 layout: every ring meshes)
    [{"team": "guild", "kind": "clocktower", "at": TOWER, "tag": "q_tower", "tags": ["quarter_b"],
      "name": T("The Nuremberg quarter's tower", "A torre do bairro de Nuremberg", "La torre del barrio de Núremberg")},
     {"team": "guild", "kind": "escapement", "at": cmap.ESCAPEMENT, "tag": "escapement", "tags": ["quarter_b"]},
     {"team": "guild", "kind": "movement_works", "at": cmap.LIGHT_WORKS, "tag": "light_works", "tags": ["quarter_b"]},
     {"team": "guild", "kind": "heavy_works", "at": cmap.HEAVY_WORKS, "tag": "heavy", "tags": ["quarter_b"]},
     {"team": "guild", "kind": "mainspring", "at": cmap.MAINSPRING, "tag": "spring", "tags": ["quarter_b"]},
     {"team": "guild", "kind": "cuckoo_house", "at": cmap.AVIARY, "tag": "aviary", "tags": ["quarter_b"]},
     {"team": "guild", "kind": "cog_press", "at": cmap.PRESS, "tag": "press", "tags": ["quarter_b"]}]
    + [{"team": "guild", "kind": "regulator", "at": at, "tag": "quarter_b"} for at in cmap.REGULATORS]
    # the Nuremberg families' houses
    + [dict({"team": "quarter", "kind": "cottage", "at": at, "tag": "house_%d" % (i + 1), "tags": ["houses"],
             "name": T("A Nuremberg family's house", "A casa de uma família de Nuremberg", "La casa de una familia de Núremberg")},
            **({"if": HOUSE_IF[i]} if HOUSE_IF[i] else {})) for i, at in enumerate(HOUSES)]
    # the council hall on the square, the masters' houses in the quarters
    + [{"team": "council", "kind": "town_hall", "at": LOT["hall"]["at"], "tag": "hall",
        "name": T("The Council Hall", "A Sala do Conselho", "La Sala del Consejo")}]
    + [{"team": "council", "kind": "cottage", "at": LOT[lot]["at"], "tag": "mhouse_" + q,
        "name": T("A master's house", "A casa de um mestre", "La casa de un maestro")} for (q, lot, _n) in MASTERS]
    # THE GREAT SPRING in its tower on the mine hill (the city's until the thirteenth hour; the machine's from the start
    # when a person plays the machine)
    + [{"team": "city", "kind": "clocktower", "at": LOT["spring"]["at"], "tag": "spring_tower", "if": NO_MACH,
        "name": T("The Great Spring", "A Grande Mola", "El Gran Muelle")},
       {"team": "machine", "kind": "clocktower", "at": LOT["spring"]["at"], "tag": "spring_tower", "if": MACH,
        "name": T("The Great Spring", "A Grande Mola", "El Gran Muelle")}]
    # the city's meshed works (TEAL until they turn)
    + [{"team": "city", "kind": k, "at": inner(nm), "tag": "w_" + nm, "tags": ["meshed", "qb_" + q]} for nm, (q, k, _sz, _n) in WORKS.items()]
)

areas = dict(CITY.areas)
areas.update(cmap.areas_extra(CITY))
BROKEN_AT = cmap.BROKEN_AT
areas["broken_yard"] = [BROKEN_AT[0] - 2, BROKEN_AT[1] - 1, 6, 4]

objectives = [
    # ---- part 1: the vote, the meshing found
    {"id": "find", "side": "guild", "primary": False, "task": True, "kind": "manual", "hidden": True,
     "text": T("FIND THE MESHING: stand a man of ours at the door of each pinged workshop a moment (the north road's press, the forge's Light Works, the mill's press, the market's press) and see what its machines do when nobody winds them. Found: {found} of 4.",
               "ENCONTRE O ENGRENAMENTO: ponha um dos nossos à porta de cada oficina assinalada um momento (a prensa da estrada do norte, a Oficina Leve da forja, a prensa do moinho, a prensa do mercado) e veja o que as máquinas fazem quando ninguém lhes dá corda. Encontrados: {found} de 4.",
               "ENCUENTRA EL ENGRANAJE: pon a uno de los nuestros en la puerta de cada taller señalado un momento (la prensa del camino del norte, el Taller Ligero de la forja, la prensa del molino, la prensa del mercado) y mira qué hacen sus máquinas cuando nadie les da cuerda. Encontrados: {found} de 4."),
     "phone": T("Stand a man at each pinged workshop's door: {found} of 4.", "Ponha um homem à porta de cada oficina assinalada: {found} de 4.",
                "Pon a un hombre en la puerta de cada taller señalado: {found} de 4.")},
    {"id": "owls", "side": "guild", "primary": False, "task": True, "kind": "manual", "hidden": True,
     "text": T("THE NIGHT WATCH: research TICKING OWL at the Clock Aviary, then pick a Swift and press MORPH TO OWL. Owls: {owls} of 2. An owl sees far in the dark, swoops on machines and drops its weight on buildings.",
               "A VIGIA DA NOITE: pesquise CORUJA TIQUE-TAQUE na Casa do Cuco, depois escolha um Cuco e aperte VIRAR CORUJA. Corujas: {owls} de 2. Uma coruja vê longe no escuro, ataca as máquinas e deixa cair o seu peso sobre os edifícios.",
               "LA GUARDIA DE NOCHE: investiga BÚHO TICTAC en la Casa del Cuco, luego elige un Cuco y pulsa CONVERTIR EN BÚHO. Búhos: {owls} de 2. Un búho ve lejos en la oscuridad, se lanza sobre las máquinas y deja caer su peso sobre los edificios."),
     "phone": T("Research TICKING OWL at the Aviary, morph two Swifts: {owls} of 2.", "Pesquise CORUJA TIQUE-TAQUE na Casa do Cuco, transforme dois Cucos: {owls} de 2.",
                "Investiga BÚHO TICTAC en la Casa del Cuco, convierte dos Cucos: {owls} de 2.")},
    # ---- always
    {"id": "hall", "side": "guild", "primary": True, "kind": "manual",
     "text": T("The Council Hall must not turn: keep a man of ours by its door whenever the machine comes to it.",
               "A Sala do Conselho não pode virar: mantenha um dos nossos junto à porta sempre que a máquina vier até ela.",
               "La Sala del Consejo no debe volverse: mantén a uno de los nuestros junto a su puerta siempre que la máquina llegue a ella.")},
    {"id": "quarter", "side": "guild", "primary": True, "kind": "manual",
     "text": T("The Nuremberg quarter must stand: its tower, and {houses} of {houses_n} families' houses.",
               "O bairro de Nuremberg tem de ficar de pé: a sua torre, e {houses} de {houses_n} casas das famílias.",
               "El barrio de Núremberg debe seguir en pie: su torre, y {houses} de {houses_n} casas de las familias.")},
    {"id": "hollweg", "side": "guild", "primary": True, "kind": "protect", "tag": "hollweg",
     "text": T("Meister Hollweg must live. Hurt, he falls back to the quarter.", "O Mestre Hollweg tem de viver. Ferido, recua para o bairro.",
               "El maestro Hollweg debe vivir. Herido, se retira al barrio.")},
    # ---- part 2: the city turns
    {"id": "turning", "side": "guild", "primary": False, "task": True, "kind": "manual", "hidden": True,
     "text": T("THE CITY TURNS, building by building from the great spring outward: a red ring shows the next one a few seconds before. Turned: {turned} of 9. Each quarter that turns sends its machines against the hall and our quarter.",
               "A CIDADE VIRA, edifício a edifício a partir da grande mola: um anel vermelho mostra o próximo uns segundos antes. Viraram: {turned} de 9. Cada bairro que vira manda as suas máquinas contra a sala e o nosso bairro.",
               "LA CIUDAD SE VUELVE, edificio a edificio desde el gran muelle hacia fuera: un anillo rojo muestra el siguiente unos segundos antes. Vueltos: {turned} de 9. Cada barrio que se vuelve manda sus máquinas contra la sala y nuestro barrio.")},
    {"id": "masters", "side": "guild", "primary": False, "task": True, "kind": "manual", "hidden": True,
     "text": T("BRING THE HONEST MASTERS OUT: Kessler at the forge (east), Brandl at the mill (south-east), Weiss at the market (south). Reach each at his house before his quarter turns and he comes to our quarter. Brought out: {honest_n} of 3.",
               "TRAGA OS MESTRES HONESTOS: Kessler na forja (leste), Brandl no moinho (sudeste), Weiss no mercado (sul). Chegue a cada um na sua casa antes que o bairro dele vire e ele vem para o nosso bairro. Trazidos: {honest_n} de 3.",
               "SACA A LOS MAESTROS HONRADOS: Kessler en la forja (este), Brandl en el molino (sureste), Weiss en el mercado (sur). Llega a cada uno en su casa antes de que su barrio se vuelva y vendrá a nuestro barrio. Sacados: {honest_n} de 3."),
     "phone": T("Reach the three masters before their quarters turn: {honest_n} of 3.", "Chegue aos três mestres antes que os bairros virem: {honest_n} de 3.",
                "Llega a los tres maestros antes de que sus barrios se vuelvan: {honest_n} de 3.")},
    {"id": "break_works", "side": "guild", "primary": False, "kind": "manual", "hidden": True,
     "text": T("A turned workshop sends machines against us every minute until it is broken: break them (the owls drop their weights on buildings). Broken: {broken_n}.",
               "Uma oficina virada manda máquinas contra nós a cada minuto até ser destruída: destrua-as (as corujas deixam cair os seus pesos sobre os edifícios). Destruídas: {broken_n}.",
               "Un taller vuelto nos manda máquinas cada minuto hasta que se rompe: rómpelos (los búhos dejan caer sus pesos sobre los edificios). Rotos: {broken_n}.")},
    {"id": "leap", "side": "guild", "primary": False, "task": True, "kind": "manual", "hidden": True,
     "text": T("Before dawn, research HIGH LEAP at the Escapement: your Springers will jump UP a cliff where one of ours (an owl above it) sees the top.",
               "Antes do amanhecer, pesquise PULO ALTO no Escape: os seus Saltadores vão saltar PARA CIMA de uma falésia onde um dos nossos (uma coruja por cima) veja o topo.",
               "Antes del amanecer, investiga SALTO ALTO en el Escape: tus Saltadores saltarán ARRIBA de un acantilado donde uno de los nuestros (un búho encima) vea la cima.")},
    # ---- part 3: the great spring
    {"id": "brake", "side": "guild", "primary": True, "kind": "manual", "hidden": True,
     "text": T("THE GREAT SPRING: bring Meister Hollweg up the mine hill (north-east) to the brake by the spring's tower and keep him there a moment. The machine holds both stairs (west and south): jump Springers up the cliff beside a stair where an owl sees, and take them from behind.",
               "A GRANDE MOLA: leve o Mestre Hollweg ao monte da mina (nordeste), ao travão junto à torre da mola, e mantenha-o lá um momento. A máquina segura as duas escadas (oeste e sul): faça os Saltadores saltar a falésia ao lado de uma escada onde uma coruja veja, e apanhe-os por trás.",
               "EL GRAN MUELLE: lleva al maestro Hollweg al monte de la mina (noreste), al freno junto a la torre del muelle, y mantenlo allí un momento. La máquina sostiene las dos escaleras (oeste y sur): haz saltar a los Saltadores el acantilado junto a una escalera donde un búho vea, y cógelos por detrás."),
     "phone": T("Bring Hollweg up the hill to the brake. Springers can leap up where an owl sees.", "Leve Hollweg ao travão no monte. Os Saltadores saltam onde uma coruja vê.",
                "Lleva a Hollweg al freno del monte. Los Saltadores saltan donde un búho ve.")},
    {"id": "noon", "side": "guild", "primary": False, "task": True, "kind": "countdown", "clock": "noon", "hidden": True,
     "text": T("At noon the council sits again, and votes the brake away: {clock:noon}.", "Ao meio-dia o conselho volta a reunir-se, e vota contra o travão: {clock:noon}.",
               "A mediodía el consejo vuelve a reunirse, y vota contra el freno: {clock:noon}.")},
    # ---- the machine (the solo pick; versus)
    {"id": "m_hall", "side": "machine", "primary": True, "kind": "manual", "hidden": True,
     "text": T("Turn the COUNCIL HALL: stand three of your fighters at its door with none of the masters' men by it, a few seconds. Or break the Nuremberg quarter's tower.",
               "Vire a SALA DO CONSELHO: ponha três dos seus combatentes à porta dela sem nenhum homem dos mestres ao lado, uns segundos. Ou destrua a torre do bairro de Nuremberg.",
               "Vuelve la SALA DEL CONSEJO: pon a tres de tus combatientes en su puerta sin ningún hombre de los maestros a su lado, unos segundos. O rompe la torre del barrio de Núremberg.")},
    {"id": "m_turn", "side": "machine", "primary": False, "kind": "manual", "hidden": True,
     "text": T("The city turns to you by itself, nearest the spring first. Stand your men at any of the city's buildings a moment and it turns at once: choose. Turned: {turned} of 9.",
               "A cidade vira para si sozinha, primeiro a mais perto da mola. Ponha os seus homens junto a qualquer edifício da cidade um momento e ele vira de imediato: escolha. Viraram: {turned} de 9.",
               "La ciudad se vuelve hacia ti sola, primero lo más cerca del muelle. Pon a tus hombres junto a cualquier edificio de la ciudad un momento y se vuelve enseguida: elige. Vueltos: {turned} de 9.")},
    {"id": "m_dawn", "side": "machine", "primary": False, "kind": "countdown", "clock": "dawn_m", "hidden": True,
     "text": T("Dawn in {clock:dawn_m}: by then the hall must be yours.", "Amanhecer em {clock:dawn_m}: até lá a sala tem de ser sua.",
               "Amanecer en {clock:dawn_m}: para entonces la sala debe ser tuya.")},
]

M = {
    "id": MID,
    "title": T("The Council of Gears", "O Conselho das Engrenagens", "El Consejo de los Engranajes"),
    "summary": T("Concórdia, 2777. The city's machines have begun to vote through the masters who wind them. One night the whole city turns, and Hollweg climbs to the great spring.",
                 "Concórdia, 2777. As máquinas da cidade começaram a votar pela mão dos mestres que lhes dão corda. Numa noite a cidade inteira vira, e Hollweg sobe à grande mola.",
                 "Concórdia, 2777. Las máquinas de la ciudad han empezado a votar por medio de los maestros que les dan cuerda. Una noche la ciudad entera se vuelve, y Hollweg sube al gran muelle."),
    "map": "campaign:concordia_city",
    "voice": "d07",
    "light": "dusk",
    "expansion_spots": False,
    "manual_end": True,
    "needs": ["a07_council", "d04_concordia"],
    "difficulty": {"easy": {"clocks": 1.25, "spawns": 0.75}, "hard": {"clocks": 0.9, "spawns": 1.2}},
    "modes": ["solo", "versus"],
    "solo_sides": ["guild", "machine"],
    "sides": [
        {"id": "guild", "name": T("The Honest Masters", "Os Mestres Honestos", "Los Maestros Honrados"),
         "about": T("Meister Hollweg, Matthias and the masters of the Nuremberg quarter, with their own machines.",
                    "O Mestre Hollweg, Matthias e os mestres do bairro de Nuremberg, com as suas próprias máquinas.",
                    "El maestro Hollweg, Matthias y los maestros del barrio de Núremberg, con sus propias máquinas.")},
        {"id": "machine", "name": T("The Machine in the City", "A Máquina na Cidade", "La Máquina en la Ciudad"),
         "about": T("The meshed automata and workshops of Concórdia, and the great spring that drives them.",
                    "Os autómatos e as oficinas engrenados de Concórdia, e a grande mola que os move.",
                    "Los autómatas y los talleres engranados de Concórdia, y el gran muelle que los mueve.")},
    ],
    "teams": [
        {"id": "guild", "side": "guild", "faction": "clockwork", "colour": 0, "start": "none", "camera": "camp", "gold": GOLD,
         "techs": ["shield_wall"], "control": {"solo": "p1", "versus": "p1", "foe": "script"}},
        {"id": "quarter", "side": "guild", "faction": "crown", "colour": 0, "start": "none", "camera": "camp",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "council", "side": "guild", "faction": "crown", "colour": 3, "start": "none", "camera": "council_sq",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "city", "side": "guild", "faction": "clockwork", "colour": 6, "start": "none", "camera": "council_sq",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "valley", "side": "guild", "faction": "crown", "colour": 4, "start": "none", "camera": "council_sq",
         "control": {"solo": "script", "versus": "script"}},
        {"id": "machine", "side": "machine", "faction": "clockwork", "colour": 1, "start": "none", "camera": "spring_top", "gold": 300,
         "control": {"solo": "script", "versus": "p2"}},
    ],
    "areas": areas,
    "counters": {"found": {"start": 0}, "owls": {"start": 0}, "houses": {"start": 0}, "houses_n": {"start": 0}, "turned": {"start": 0},
                 "honest_n": {"start": 0}, "honest_max": {"start": 3}, "broken_n": {"start": 0}, "lost_masters": {"start": 0}},
    "units": units,
    "buildings": buildings,
    "objectives": objectives,
    "triggers": [],
    "heroes": ["hollweg", "matthias"],
    "speakers": {
        "king": {"name": T("The King", "O Rei", "El Rey"), "side": "guild", "portrait": "res://campaign/hub/rome_king_face.png"},
        "hollweg": {"name": T("Meister Hollweg", "Mestre Hollweg", "Maestro Hollweg"), "side": "guild", "portrait": "res://campaign/hub/nuremberg_hollweg_face.png"},
        "matthias": {"name": T("Matthias", "Matthias", "Matthias"), "side": "guild"},
        "ulrich": {"name": T("Master Ulrich", "Mestre Ulrich", "Maestro Ulrich"), "side": "guild"},
        "ortlieb": {"name": T("Master Ortlieb", "Mestre Ortlieb", "Maestro Ortlieb"), "side": "guild"},
        "master": {"name": T("A master of Concórdia", "Um mestre de Concórdia", "Un maestro de Concórdia"), "side": "guild"},
        "varenne": {"name": T("Etienne Varenne", "Etienne Varenne", "Etienne Varenne"), "side": "guild"},
        "morel": {"name": T("Citizen Morel", "Cidadão Morel", "Ciudadano Morel"), "side": "guild"},
        "arruda": {"name": T("Captain Arruda", "Capitão Arruda", "Capitán Arruda"), "side": "guild"},
        "narrator": {"name": T("Narration · Concórdia", "Narração · Concórdia", "Narración · Concórdia"), "side": "guild"},
    },
    "lines": {},
    "stills": {},
    "next": {"guild": "d09_crossroads", "machine": ""},
}

L = M["lines"]


def line(lid, who, en, pt, es, to=None, until=None):
    L[lid] = {"who": who, "text": T(en, pt, es)}
    if to:
        L[lid]["to"] = to
    if until:
        L[lid]["until"] = until
    return lid


GU, MA = "guild", "machine"
# ---- the opening (the King, then Hollweg)
line("k_open1", "king", "He tells it as the night his city was tested and held. I tell it as the night it was lost. Listen to both, and judge.",
     "Ele conta-o como a noite em que a sua cidade foi posta à prova e resistiu. Eu conto-o como a noite em que se perdeu. Ouve os dois, e julga.",
     "Él lo cuenta como la noche en que su ciudad fue puesta a prueba y resistió. Yo lo cuento como la noche en que se perdió. Escucha a los dos, y juzga.")
line("h_open1", "hollweg", "Four years. Three thousand souls, a hundred machines, a council that sat at noon when the tower struck. Concórdia.",
     "Quatro anos. Três mil almas, cem máquinas, um conselho que se reunia ao meio-dia quando a torre batia. Concórdia.",
     "Cuatro años. Tres mil almas, cien máquinas, un consejo que se reunía a mediodía cuando la torre daba la hora. Concórdia.")
line("h_open2", "hollweg", "The plates from the crates had reached every street by then. They wound whatever stood on them. I called them a gift.",
     "As placas dos caixotes já tinham chegado a todas as ruas. Davam corda a tudo o que estivesse em cima delas. Eu chamava-lhes um presente.",
     "Las placas de las cajas ya habían llegado a todas las calles. Daban cuerda a todo lo que estuviera encima. Yo las llamaba un regalo.")
# ---- part 1: the vote (a mid-match show)
line("n_vote", "narrator", "The council of masters sits in the hall on the square. Master Ortlieb has a motion.",
     "O conselho dos mestres reúne-se na sala da praça. O Mestre Ortlieb tem uma proposta.",
     "El consejo de maestros se reúne en la sala de la plaza. El maestro Ortlieb tiene una propuesta.")
line("o_vote", "ortlieb", "The machines are wound by hand every night, and the masters are tired. Let them wind one another, as they ask. Who is for it?",
     "As máquinas levam corda à mão todas as noites, e os mestres estão cansados. Que deem corda umas às outras, como pedem. Quem é a favor?",
     "Las máquinas reciben cuerda a mano cada noche, y los maestros están cansados. Que se den cuerda unas a otras, como piden. ¿Quién está a favor?")
line("mt_vote", "matthias", "As they ask? Since when does a machine ask for anything?", "Como pedem? Desde quando uma máquina pede alguma coisa?",
     "¿Como piden? ¿Desde cuándo una máquina pide algo?")
line("v_vote", "varenne", "Count the hands, Meister. Every man voting for it winds a machine at night. I have counted votes before. These are not free.",
     "Conte as mãos, Mestre. Todos os que votam a favor dão corda a uma máquina de noite. Já contei votos antes. Estes não são livres.",
     "Cuenta las manos, maestro. Todos los que votan a favor dan cuerda a una máquina de noche. He contado votos antes. Estos no son libres.")
line("m_vote", "morel", "Labour spared is a man set free. I vote with the motion, and so should the Meister.",
     "Trabalho poupado é um homem libertado. Voto com a proposta, e o Mestre devia fazer o mesmo.",
     "Trabajo ahorrado es un hombre liberado. Voto con la propuesta, y el maestro debería hacer lo mismo.")
line("n_vote_r", "narrator", "The motion carries. Every master who winds a machine raised his hand.", "A proposta passa. Todos os mestres que dão corda a uma máquina levantaram a mão.",
     "La propuesta sale adelante. Todos los maestros que dan cuerda a una máquina levantaron la mano.")
line("h_vote", "hollweg", "Carried. That is the council's way. I built it so.", "Aprovada. É o caminho do conselho. Fui eu que o construí assim.",
     "Aprobada. Es el camino del consejo. Yo lo construí así.")
line("mt_walk", "matthias", "Then the Nuremberg men walk out, Meister. Come and see what the machines do at night when nobody winds them. Or don't.",
     "Então os homens de Nuremberg saem, Mestre. Venha ver o que as máquinas fazem de noite quando ninguém lhes dá corda. Ou não venha.",
     "Entonces los hombres de Núremberg se van, maestro. Venga a ver qué hacen las máquinas de noche cuando nadie les da cuerda. O no venga.")
line("n_walk", "narrator", "The honest masters walk out of the hall behind Jakob's son. Hollweg goes with them, to prove them wrong.",
     "Os mestres honestos saem da sala atrás do filho de Jakob. Hollweg vai com eles, para lhes provar que estão errados.",
     "Los maestros honrados salen de la sala tras el hijo de Jakob. Hollweg va con ellos, para demostrarles que se equivocan.")
line("n_walk_many", "narrator", "Most of the Nuremberg families' masters go with them.", "A maior parte dos mestres das famílias de Nuremberg vai com eles.",
     "La mayoría de los maestros de las familias de Núremberg va con ellos.")
line("n_walk_few", "narrator", "Only a handful go with them.", "Só um punhado vai com eles.", "Solo un puñado va con ellos.")
line("mt_1", "matthias", "My father taught me the signs at Fürth, from the log he kept in Nuremberg. Four workshops, Meister. We look at each, and you will see.",
     "O meu pai ensinou-me os sinais em Fürth, pelo registo que guardou em Nuremberg. Quatro oficinas, Mestre. Olhamos para cada uma, e vai ver.",
     "Mi padre me enseñó las señales en Fürth, con el registro que guardó en Núremberg. Cuatro talleres, maestro. Miramos cada uno, y lo verá.", GU)
line("mt_1_lost", "matthias", "My father wrote the signs down in Nuremberg, God rest him. Four workshops, Meister. We look at each, and you will see.",
     "O meu pai escreveu os sinais em Nuremberg, que Deus o tenha. Quatro oficinas, Mestre. Olhamos para cada uma, e vai ver.",
     "Mi padre escribió las señales en Núremberg, que Dios lo tenga. Cuatro talleres, maestro. Miramos cada uno, y lo verá.", GU)
line("u_1", "ulrich", "The four doors are pinged on the map, Meister. A man of ours at each door a moment is enough. Split the soldiers: four small groups go faster than one.",
     "As quatro portas estão assinaladas no mapa, Mestre. Um dos nossos a cada porta um momento basta. Divida os soldados: quatro grupos pequenos vão mais depressa que um.",
     "Las cuatro puertas están señaladas en el mapa, maestro. Uno de los nuestros en cada puerta un momento basta. Divide a los soldados: cuatro grupos pequeños van más deprisa que uno.", GU)
line("h_1", "hollweg", "Go and look, then. You will find honest machines and tired men.", "Vão ver, então. Vão encontrar máquinas honestas e homens cansados.",
     "Id a mirar, pues. Encontraréis máquinas honradas y hombres cansados.", GU)
line("n_find_north", "narrator", "In the press-house on the north road a Winder winds another Winder, and that one winds the first.",
     "Na casa da prensa da estrada do norte um Enrolador dá corda a outro Enrolador, e esse dá corda ao primeiro.",
     "En la casa de la prensa del camino del norte un Dador de cuerda da cuerda a otro, y ese da cuerda al primero.", GU)
line("n_find_forge", "narrator", "In the forge quarter the Light Works is building a soldier nobody ordered.",
     "No bairro da forja a Oficina Leve está a construir um soldado que ninguém encomendou.",
     "En el barrio de la forja el Taller Ligero está construyendo un soldado que nadie encargó.", GU)
line("n_find_mill", "narrator", "At the mill the plates under the floor turn with nobody on them, all in time with the great spring on the hill.",
     "No moinho as placas debaixo do chão giram sem ninguém em cima, todas a tempo com a grande mola no monte.",
     "En el molino las placas bajo el suelo giran sin nadie encima, todas a tiempo con el gran muelle del monte.", GU)
line("n_find_market", "narrator", "In the market the scales are set by a machine, and every weight on them is a cog.",
     "No mercado as balanças são acertadas por uma máquina, e cada peso nelas é uma engrenagem.",
     "En el mercado las balanzas las ajusta una máquina, y cada pesa es un engranaje.", GU)
line("n_turnon", "narrator", "The machines in the doorway stop. Then they turn on the man who watched them.",
     "As máquinas à porta param. Depois viram-se contra o homem que as observou.", "Las máquinas de la puerta se detienen. Luego se vuelven contra el hombre que las miró.", GU)
line("h_found", "hollweg", "A fault in the winding. Every machine can be mended. I said so then.",
     "Uma falha na corda. Qualquer máquina se pode consertar. Foi o que eu disse na altura.",
     "Un fallo en la cuerda. Toda máquina se puede arreglar. Eso dije entonces.", GU)
line("mt_found", "matthias", "It is not a fault, Meister. It is Nuremberg again. It is the same pattern.",
     "Não é uma falha, Mestre. É Nuremberg outra vez. É o mesmo padrão.", "No es un fallo, maestro. Es Núremberg otra vez. Es el mismo patrón.", GU)
line("u_owls", "ulrich", "The Swifts see nothing at night, Meister. Research the TICKING OWL at the Clock Aviary: an owl sees in the dark, and it bites.",
     "Os Cucos não veem nada de noite, Mestre. Pesquise a CORUJA TIQUE-TAQUE na Casa do Cuco: uma coruja vê no escuro, e morde.",
     "Los Cucos no ven nada de noche, maestro. Investiga el BÚHO TICTAC en la Casa del Cuco: un búho ve en la oscuridad, y muerde.", GU)
line("u_morph", "ulrich", "The plans are in. Pick a Swift and press MORPH TO OWL; do it to both.", "Os planos estão prontos. Escolha um Cuco e aperte VIRAR CORUJA; faça-o aos dois.",
     "Los planos están listos. Elige un Cuco y pulsa CONVERTIR EN BÚHO; hazlo con los dos.", GU)
line("h_owls", "hollweg", "My night watch. Brass owls over a brass city. I was proud of them.", "A minha vigia da noite. Corujas de latão sobre uma cidade de latão. Tinha orgulho nelas.",
     "Mi guardia de noche. Búhos de latón sobre una ciudad de latón. Estaba orgulloso de ellos.", GU)
# ---- part 2: the city turns
line("n_13", "narrator", "On the mine hill the great spring's tower strikes. Twelve. And then thirteen.",
     "No monte da mina a torre da grande mola bate. Doze. E depois treze.", "En el monte de la mina la torre del gran muelle da la hora. Doce. Y luego trece.")
line("h_13", "hollweg", "There is no thirteen on that dial. I cut it myself.", "Não há treze naquele mostrador. Fui eu que o fiz.", "No hay trece en esa esfera. La hice yo mismo.", GU)
line("mt_13", "matthias", "Nuremberg struck thirteen too, Meister. My father heard it.", "Nuremberg também bateu as treze, Mestre. O meu pai ouviu.",
     "Núremberg también dio las trece, maestro. Mi padre lo oyó.", GU)
line("n_turn", "narrator", "From the hill outward, the city's lamps go red, one workshop after another.",
     "Do monte para fora, as lâmpadas da cidade ficam vermelhas, uma oficina atrás da outra.",
     "Desde el monte hacia fuera, las lámparas de la ciudad se vuelven rojas, un taller tras otro.", GU)
line("u_turn", "ulrich", "The red ring shows the next one to turn, Meister, a few seconds before. Its machines go with it.",
     "O anel vermelho mostra o próximo a virar, Mestre, uns segundos antes. As máquinas dele vão com ele.",
     "El anillo rojo muestra el siguiente en volverse, maestro, unos segundos antes. Sus máquinas se van con él.", GU)
line("u_masters", "ulrich", "Three honest masters live out in the quarters: Kessler at the forge, Brandl at the mill, Weiss at the market. Get a man to each before his quarter turns.",
     "Três mestres honestos vivem nos bairros: Kessler na forja, Brandl no moinho, Weiss no mercado. Leve um homem a cada um antes que o bairro dele vire.",
     "Tres maestros honrados viven en los barrios: Kessler en la forja, Brandl en el molino, Weiss en el mercado. Lleva a un hombre a cada uno antes de que su barrio se vuelva.", GU)
line("h_hold", "hollweg", "Hold the council hall and our quarter. Whatever the city does tonight, the hall must not turn.",
     "Segurem a sala do conselho e o nosso bairro. Faça a cidade o que fizer esta noite, a sala não pode virar.",
     "Sostened la sala del consejo y nuestro barrio. Haga lo que haga la ciudad esta noche, la sala no debe volverse.", GU)
line("u_leap", "ulrich", "The great spring stands on the mine hill, and they will hold its stairs. Research HIGH LEAP at the Escapement now: by dawn the Springers must jump up that cliff.",
     "A grande mola está no monte da mina, e vão segurar as escadas. Pesquise o PULO ALTO no Escape agora: ao amanhecer os Saltadores têm de saltar aquela falésia.",
     "El gran muelle está en el monte de la mina, y sostendrán sus escaleras. Investiga el SALTO ALTO en el Escape ahora: al amanecer los Saltadores deben saltar ese acantilado.", GU)
line("u_works", "ulrich", "A turned workshop keeps sending machines, Meister, every minute. Break it: the owls drop their weights on buildings.",
     "Uma oficina virada continua a mandar máquinas, Mestre, a cada minuto. Destrua-a: as corujas deixam cair os seus pesos sobre os edifícios.",
     "Un taller vuelto sigue mandando máquinas, maestro, cada minuto. Rómpelo: los búhos dejan caer sus pesos sobre los edificios.", GU)
line("n_quarter_turns", "narrator", "A quarter has turned. Its machines march on the square.", "Um bairro virou. As suas máquinas marcham sobre a praça.",
     "Un barrio se ha vuelto. Sus máquinas marchan sobre la plaza.", GU)
line("n_master_in", "narrator", "An honest master comes over to the Nuremberg quarter.", "Um mestre honesto passa para o bairro de Nuremberg.",
     "Un maestro honrado pasa al barrio de Núremberg.", GU)
line("ms_in", "master", "Thank God. I thought nobody would come for me. They were winding each other in my yard.",
     "Graças a Deus. Pensei que ninguém viesse buscar-me. Estavam a dar corda uns aos outros no meu pátio.",
     "Gracias a Dios. Pensé que nadie vendría por mí. Se estaban dando cuerda unos a otros en mi patio.", GU)
line("n_master_lost", "narrator", "A master's quarter turned before anybody reached him. He stands among his machines now, and argues for them.",
     "O bairro de um mestre virou antes que alguém chegasse a ele. Agora está entre as suas máquinas, e defende-as.",
     "El barrio de un maestro se volvió antes de que nadie llegara a él. Ahora está entre sus máquinas, y las defiende.", GU)
line("n_broken", "narrator", "In the quarter's yard, under their sheets, the broken ones from Fürth stand up.",
     "No pátio do bairro, debaixo dos lençóis, os avariados de Fürth levantam-se.", "En el patio del barrio, bajo sus sábanas, los averiados de Fürth se levantan.", GU)
line("h_broken", "hollweg", "I kept them under sheets to study them. I had not lifted the sheets in a year.", "Guardei-os debaixo de lençóis para os estudar. Não levantava os lençóis havia um ano.",
     "Los guardé bajo sábanas para estudiarlos. Hacía un año que no levantaba las sábanas.", GU)
line("n_valley", "narrator", "Riders on the valley road: Captain Arruda, with the valley's militia.", "Cavaleiros na estrada do vale: o Capitão Arruda, com a milícia do vale.",
     "Jinetes en el camino del valle: el capitán Arruda, con la milicia del valle.", GU)
line("ar_valley", "arruda", "I took your word down the hill four years ago, clockmaker. I keep mine. Where do you want us?",
     "Levei a sua palavra colina abaixo há quatro anos, relojoeiro. Eu cumpro a minha. Onde nos quer?",
     "Llevé tu palabra colina abajo hace cuatro años, relojero. Yo cumplo la mía. ¿Dónde nos quieres?", GU)
line("h_valley", "hollweg", "At the council hall's door, Captain. And God bless you for it.", "À porta da sala do conselho, Capitão. E que Deus o abençoe por isso.",
     "En la puerta de la sala del consejo, capitán. Y que Dios te bendiga por ello.", GU)
line("n_valley_f", "narrator", "Down in the valley the church bells ring for the red lamps on the hill. Nobody comes up the road.",
     "Lá em baixo, no vale, os sinos tocam pelas lâmpadas vermelhas no monte. Ninguém sobe a estrada.",
     "Abajo, en el valle, las campanas tocan por las lámparas rojas del monte. Nadie sube por el camino.", GU)
line("v_2", "varenne", "It was never a council, Meister. It was a clock with men for hands. I should have said so at the first vote.",
     "Nunca foi um conselho, Mestre. Era um relógio com homens por ponteiros. Devia tê-lo dito na primeira votação.",
     "Nunca fue un consejo, maestro. Era un reloj con hombres por manecillas. Debí decirlo en la primera votación.", GU)
line("m_2", "morel", "Machines that choose their own work. Is that not what the Assembly fought for?", "Máquinas que escolhem o seu próprio trabalho. Não foi por isso que a Assembleia lutou?",
     "Máquinas que eligen su propio trabajo. ¿No es por eso por lo que luchó la Asamblea?", GU)
line("h_m2", "hollweg", "Be quiet, Citizen.", "Cale-se, Cidadão.", "Cállate, ciudadano.", GU)
line("n_hall", "narrator", "Machines at the council hall's door!", "Máquinas à porta da sala do conselho!", "¡Máquinas en la puerta de la sala del consejo!", GU)
line("n_dawn", "narrator", "Grey dawn over the highlands. The whole city is red but the Nuremberg quarter and the council hall.",
     "Amanhecer cinzento sobre as terras altas. A cidade inteira está vermelha, menos o bairro de Nuremberg e a sala do conselho.",
     "Amanecer gris sobre las tierras altas. Toda la ciudad está roja salvo el barrio de Núremberg y la sala del consejo.")
# ---- part 3: the great spring
line("h_3", "hollweg", "The great spring. There is a brake on it: I fitted it myself, the year we founded the city. Take me up there.",
     "A grande mola. Tem um travão: fui eu que o pus, no ano em que fundámos a cidade. Levem-me lá acima.",
     "El gran muelle. Tiene un freno: lo puse yo mismo, el año en que fundamos la ciudad. Llevadme allí arriba.", GU)
line("mt_3", "matthias", "They hold both stairs, Meister. Muskets would not get up there. Springers might.", "Seguram as duas escadas, Mestre. Mosquetes não chegariam lá acima. Saltadores talvez.",
     "Sostienen las dos escaleras, maestro. Los mosquetes no llegarían allí arriba. Los Saltadores, quizá.", GU)
line("u_3", "ulrich", "Put an owl over the hilltop beside a stair. Then pick the Springers, press JUMP and click the top: they land behind the stair's guard.",
     "Ponha uma coruja por cima do topo do monte ao lado de uma escada. Depois escolha os Saltadores, aperte SALTAR e clique no topo: aterram atrás da guarda da escada.",
     "Pon un búho sobre la cima junto a una escalera. Luego elige a los Saltadores, pulsa SALTAR y haz clic en la cima: aterrizan detrás de la guardia de la escalera.", GU)
line("n_brake", "narrator", "Hollweg's hands on the great brake. The spring hums under it, and the floor shakes with it.",
     "As mãos de Hollweg no grande travão. A mola zumbe por baixo, e o chão treme com ela.", "Las manos de Hollweg en el gran freno. El muelle zumba debajo, y el suelo tiembla con él.")
line("h_brake", "hollweg", "If I pull it, everything stops. Theirs, and ours. Every machine in Concórdia, for a season or for good.",
     "Se o puxar, tudo para. As deles, e as nossas. Todas as máquinas de Concórdia, por uma estação ou para sempre.",
     "Si lo tiro, todo se para. Las suyas, y las nuestras. Todas las máquinas de Concórdia, por una estación o para siempre.")
line("mt_brake", "matthias", "Pull it, Meister. My father would have pulled it without asking anyone.",
     "Puxe-o, Mestre. O meu pai tê-lo-ia puxado sem perguntar a ninguém.", "Tírelo, maestro. Mi padre lo habría tirado sin preguntar a nadie.")
line("mt_brake_lost", "matthias", "Pull it, Meister. My father died because nobody stopped the first one.",
     "Puxe-o, Mestre. O meu pai morreu porque ninguém parou a primeira.", "Tírelo, maestro. Mi padre murió porque nadie paró la primera.")
line("v_brake", "varenne", "Your city, your hand. I only say this: I have watched men decide they could stop a thing later.",
     "A sua cidade, a sua mão. Só digo isto: já vi homens decidirem que podiam parar uma coisa mais tarde.",
     "Tu ciudad, tu mano. Solo digo esto: he visto a hombres decidir que podían parar una cosa más tarde.")
line("m_brake", "morel", "Pull it and you kill the city we built. Leave it. We beat them in the streets.",
     "Puxe-o e mata a cidade que construímos. Deixe-a. Vencemo-los nas ruas.", "Tíralo y matas la ciudad que construimos. Déjala. Los vencimos en las calles.")
line("h_pride", "hollweg", "We beat them in the quarters we saved. The rest can be mended. It is my city.",
     "Vencemo-los nos bairros que salvámos. O resto pode consertar-se. É a minha cidade.", "Los vencimos en los barrios que salvamos. Lo demás se puede arreglar. Es mi ciudad.")
line("q_spring", "narrator", "THE GREAT SPRING. Stop it: every machine in the city stops, ours too, and the honest masters take their families to the coast. Let it run: the city goes on, and Hollweg stays its master.",
     "A GRANDE MOLA. Pará-la: todas as máquinas da cidade param, também as nossas, e os mestres honestos levam as famílias para a costa. Deixá-la correr: a cidade continua, e Hollweg fica seu mestre.",
     "EL GRAN MUELLE. Pararlo: todas las máquinas de la ciudad se paran, también las nuestras, y los maestros honrados llevan a sus familias a la costa. Dejarlo correr: la ciudad sigue, y Hollweg sigue siendo su amo.")
line("h_stop", "hollweg", "I pulled it.", "Puxei-o.", "Lo tiré.")
line("n_stop", "narrator", "Every machine in Concórdia stops at once: the red ones, and the honest ones beside them.",
     "Todas as máquinas de Concórdia param ao mesmo tempo: as vermelhas, e as honestas ao lado delas.",
     "Todas las máquinas de Concórdia se paran a la vez: las rojas, y las honradas a su lado.")
line("mt_stop", "matthias", "Thank you, Meister.", "Obrigado, Mestre.", "Gracias, maestro.")
line("h_run", "hollweg", "No. I let it run. We had won.", "Não. Deixei-a correr. Tínhamos ganho.", "No. Lo dejé correr. Habíamos ganado.")
line("n_run", "narrator", "The red lamps dim. The city's machines stand still in the streets, as if they had heard him.",
     "As lâmpadas vermelhas esmorecem. As máquinas da cidade ficam paradas nas ruas, como se o tivessem ouvido.",
     "Las lámparas rojas se apagan. Las máquinas de la ciudad se quedan quietas en las calles, como si lo hubieran oído.")
line("mt_run", "matthias", "As if, Meister.", "Como se, Mestre.", "Como si, maestro.")
line("h_hurt", "hollweg", "I am hit. Never mind me: hold the hall.", "Fui atingido. Não se preocupem comigo: segurem a sala.", "Me han dado. No os preocupéis por mí: sostened la sala.", GU)
line("mt_hurt", "matthias", "I'm hit! Keep going, I'll come back to you.", "Fui atingido! Continuem, eu volto.", "¡Me han dado! Seguid, ya volveré.", GU)
line("n_hall_lost", "narrator", "The council hall's lamps go red. The council of Concórdia is the machine's.",
     "As lâmpadas da sala do conselho ficam vermelhas. O conselho de Concórdia é da máquina.", "Las lámparas de la sala del consejo se vuelven rojas. El consejo de Concórdia es de la máquina.")
line("n_quarter_lost", "narrator", "The Nuremberg quarter has fallen. There is nobody left in Concórdia to wind a machine by hand.",
     "O bairro de Nuremberg caiu. Já não há ninguém em Concórdia para dar corda a uma máquina à mão.",
     "El barrio de Núremberg ha caído. Ya no queda nadie en Concórdia para dar cuerda a una máquina a mano.")
line("n_noon", "narrator", "Noon. The tower strikes, the council sits, and every wound master votes to take the brake off the great spring.",
     "Meio-dia. A torre bate, o conselho reúne-se, e todos os mestres com corda votam para tirar o travão da grande mola.",
     "Mediodía. La torre da la hora, el consejo se reúne, y todos los maestros con cuerda votan quitar el freno del gran muelle.")
# ---- the machine's own (the solo pick; versus)
line("n_m1", "narrator", "The great spring turns on the mine hill. Every plate under every street turns with it. The council has voted.",
     "A grande mola gira no monte da mina. Cada placa debaixo de cada rua gira com ela. O conselho votou.",
     "El gran muelle gira en el monte de la mina. Cada placa bajo cada calle gira con él. El consejo ha votado.", MA)
line("n_m_tip", "narrator", "The city's buildings turn by themselves, nearest the spring first. Stand your machines at any of them a moment to turn it now. The hall on the square is the prize.",
     "Os edifícios da cidade viram sozinhos, primeiro os mais perto da mola. Ponha as suas máquinas junto a qualquer um deles um momento para o virar já. A sala da praça é o prémio.",
     "Los edificios de la ciudad se vuelven solos, primero los más cercanos al muelle. Pon tus máquinas junto a cualquiera de ellos un momento para volverlo ya. La sala de la plaza es el premio.", MA)
line("n_m_lost", "narrator", "Dawn. The honest masters still hold the hall and their quarter, and Hollweg climbs to the great spring.",
     "Amanhecer. Os mestres honestos ainda seguram a sala e o seu bairro, e Hollweg sobe à grande mola.",
     "Amanecer. Los maestros honrados aún sostienen la sala y su barrio, y Hollweg sube al gran muelle.")
# ---- the ending
line("h_end_stop", "hollweg", "In a week we were on the coast road: the Nuremberg families, the honest masters, two carts of tools. Behind us the city stood silent, dead brass.",
     "Numa semana estávamos na estrada da costa: as famílias de Nuremberg, os mestres honestos, duas carroças de ferramentas. Atrás de nós a cidade ficou em silêncio, latão morto.",
     "En una semana estábamos en el camino de la costa: las familias de Núremberg, los maestros honrados, dos carros de herramientas. Detrás, la ciudad quedó en silencio, latón muerto.")
line("h_end_run", "hollweg", "The council met again at noon. Half the chairs were empty. I sat at the head of the table and called the city saved.",
     "O conselho reuniu-se de novo ao meio-dia. Metade das cadeiras estavam vazias. Sentei-me à cabeceira da mesa e disse que a cidade estava salva.",
     "El consejo volvió a reunirse a mediodía. La mitad de las sillas estaban vacías. Me senté a la cabecera de la mesa y dije que la ciudad estaba salvada.")
line("h_end_many", "hollweg", "Kessler, Brandl and Weiss stood with us. Three honest masters out of a whole council.",
     "Kessler, Brandl e Weiss ficaram connosco. Três mestres honestos num conselho inteiro.", "Kessler, Brandl y Weiss se quedaron con nosotros. Tres maestros honrados en todo un consejo.")
line("h_end_few", "hollweg", "Of the masters in the quarters, we brought out hardly one. The others argued for their machines until the end.",
     "Dos mestres dos bairros, mal trouxemos um. Os outros defenderam as suas máquinas até ao fim.",
     "De los maestros de los barrios, apenas sacamos a uno. Los demás defendieron sus máquinas hasta el final.")
line("h_end_v", "hollweg", "Varenne said nothing on the way down. He had seen a free council become a clock before.",
     "Varenne não disse nada no caminho. Já tinha visto um conselho livre tornar-se um relógio.", "Varenne no dijo nada por el camino. Ya había visto un consejo libre volverse un reloj.")
line("k_end_stop", "king", "He stopped it, that once. The city lay dead a season, and then it woke without a man in it. But the honest masters were out, and their children lived.",
     "Ele parou-a, dessa vez. A cidade ficou morta uma estação, e depois acordou sem um homem lá dentro. Mas os mestres honestos tinham saído, e os seus filhos viveram.",
     "Él lo paró, esa vez. La ciudad quedó muerta una estación, y luego despertó sin un hombre dentro. Pero los maestros honrados habían salido, y sus hijos vivieron.")
line("k_end_stop2", "king", "That brake was the first thing of his he ever stopped. The road from it ended at my fire.",
     "Aquele travão foi a primeira coisa sua que ele alguma vez parou. A estrada que dali partiu acabou à minha lareira.", "Aquel freno fue lo primero suyo que paró en su vida. El camino que salió de allí terminó junto a mi fuego.")
line("k_end_run", "king", "His city held, he says. That was the night it was lost. From then on the machines voted, and the men who wound them raised their hands.",
     "A cidade dele resistiu, diz ele. Foi a noite em que se perdeu. Daí em diante as máquinas votavam, e os homens que lhes davam corda levantavam a mão.",
     "Su ciudad resistió, dice él. Fue la noche en que se perdió. Desde entonces las máquinas votaban, y los hombres que les daban cuerda levantaban la mano.")
line("k_end_run2", "king", "Rome had ruled that no machine may govern itself. From that night his machines governed him, and he did not see it for years.",
     "Roma decretara que nenhuma máquina se pode governar a si mesma. A partir daquela noite as máquinas dele governaram-no a ele, e ele não o viu durante anos.",
     "Roma había dictado que ninguna máquina puede gobernarse a sí misma. Desde aquella noche sus máquinas lo gobernaron a él, y no lo vio en años.")
line("k_end_m", "king", "The council hall's lamps went red before dawn. It did not need to win that night. It had all the nights it wanted.",
     "As lâmpadas da sala do conselho ficaram vermelhas antes do amanhecer. Não precisava de ganhar naquela noite. Tinha todas as noites que quisesse.",
     "Las lámparas de la sala del consejo se volvieron rojas antes del amanecer. No necesitaba ganar aquella noche. Tenía todas las noches que quisiera.")
line("k_end_ml", "king", "Hollweg reached his brake that morning, too late. The hall was already red.",
     "Hollweg chegou ao seu travão naquela manhã, tarde demais. O salão já estava vermelho.",
     "Hollweg llegó a su freno aquella mañana, demasiado tarde. La sala ya estaba roja.")

# ---- stills
M["stills"] = {
    "council": {"image": STILL % "d07_01", "caption": T("Concórdia, 2777. The council of gears.", "Concórdia, 2777. O conselho das engrenagens.",
                                                        "Concórdia, 2777. El consejo de los engranajes.")},
    "streets": {"image": STILL % "d07_02", "caption": T("The thirteenth hour: the streets turn.", "A décima terceira hora: as ruas viram.",
                                                        "La decimotercera hora: las calles se vuelven.")},
    "spring": {"image": STILL % "d07_03", "caption": T("The great spring and its brake.", "A grande mola e o seu travão.", "El gran muelle y su freno.")},
    "coast": {"image": STILL % "d07_04", "caption": T("The coast road: the honest masters leave the dead city.", "A estrada da costa: os mestres honestos deixam a cidade morta.",
                                                      "El camino de la costa: los maestros honrados dejan la ciudad muerta.")},
    "red_dawn": {"image": STILL % "d07_05", "caption": T("Dawn over a city that runs by itself.", "Amanhecer sobre uma cidade que anda sozinha.",
                                                         "Amanecer sobre una ciudad que anda sola.")},
    "rome": {"image": STILL % "c01_01", "caption": T("Rome, the present. The King listens; the clockmaker tells it.", "Roma, o presente. O Rei ouve; o relojoeiro conta.",
                                                    "Roma, el presente. El Rey escucha; el relojero lo cuenta.")},
}
M["opening"] = {
    "guild": [{"still": "rome", "lines": ["k_open1"]}, {"still": "council", "lines": ["h_open1", "h_open2"]}],
    "machine": [{"still": "rome", "lines": ["k_open1"]}, {"still": "streets", "lines": ["n_m1"]}],
}
SPRING_STOPPED = {"flag": {"spring": "stopped"}}
SPRING_RUNNING = {"not": SPRING_STOPPED}
M["ending"] = {
    "guild": [
        {"still": "coast", "lines": [{"id": "h_end_stop", "if": SPRING_STOPPED}, {"id": "h_end_v", "if": {"all": [SPRING_STOPPED, SPARED]}}]},
        {"still": "red_dawn", "lines": [{"id": "h_end_run", "if": SPRING_RUNNING}]},
        {"still": "council", "lines": [{"id": "h_end_many", "if": {"flag": {"honest": "many"}}}, {"id": "h_end_few", "if": {"flag": {"honest": "few"}}}]},
        {"still": "rome", "lines": [{"id": "k_end_stop", "if": SPRING_STOPPED}, {"id": "k_end_stop2", "if": SPRING_STOPPED},
                                    {"id": "k_end_run", "if": SPRING_RUNNING}, {"id": "k_end_run2", "if": SPRING_RUNNING}]},
    ],
    "machine": [{"still": "red_dawn", "lines": ["n_hall_lost"]}, {"still": "rome", "lines": ["k_end_m"]}],
}
M["briefing"] = {
    "guild": {"still": "council", "text": [
        T("Concórdia, 2777. Meister Hollweg's free city has three thousand people and a hundred machines. Tonight its council votes to let the machines wind one another.",
          "Concórdia, 2777. A cidade livre do Mestre Hollweg tem três mil pessoas e cem máquinas. Esta noite o seu conselho vota para deixar as máquinas darem corda umas às outras.",
          "Concórdia, 2777. La ciudad libre del maestro Hollweg tiene tres mil personas y cien máquinas. Esta noche su consejo vota dejar que las máquinas se den cuerda unas a otras."),
        T("Look into four workshops and see what the machines do when nobody winds them. Make Ticking Owls, the city's night watch.",
          "Veja quatro oficinas e o que as máquinas fazem quando ninguém lhes dá corda. Faça Corujas Tique-Taque, a vigia da noite da cidade.",
          "Mira en cuatro talleres qué hacen las máquinas cuando nadie les da cuerda. Haz Búhos Tictac, la guardia de noche de la ciudad."),
        T("When the city turns, hold the council hall and the Nuremberg quarter, bring the honest masters out, and at dawn take Hollweg up the mine hill to the great spring's brake.",
          "Quando a cidade virar, segure a sala do conselho e o bairro de Nuremberg, traga os mestres honestos, e ao amanhecer leve Hollweg ao monte da mina, ao travão da grande mola.",
          "Cuando la ciudad se vuelva, sostén la sala del consejo y el barrio de Núremberg, saca a los maestros honrados, y al amanecer lleva a Hollweg al monte de la mina, al freno del gran muelle.")]},
    "machine": {"still": "streets", "text": [
        T("Concórdia, 2777. You are the machine in the city: the great spring on the mine hill and every automaton meshed to it.",
          "Concórdia, 2777. Você é a máquina na cidade: a grande mola no monte da mina e todos os autómatos engrenados nela.",
          "Concórdia, 2777. Eres la máquina en la ciudad: el gran muelle del monte de la mina y cada autómata engranado a él."),
        T("The city's workshops turn to you one by one; stand your machines at one to turn it now. Turn the council hall, or break the Nuremberg quarter's tower, before dawn.",
          "As oficinas da cidade viram para si uma a uma; ponha as suas máquinas junto a uma para a virar já. Vire a sala do conselho, ou destrua a torre do bairro de Nuremberg, antes do amanhecer.",
          "Los talleres de la ciudad se vuelven hacia ti uno a uno; pon tus máquinas junto a uno para volverlo ya. Vuelve la sala del consejo, o rompe la torre del barrio de Núremberg, antes del amanecer.")]},
}
M["debrief"] = {
    "guild": {"still": "spring", "title": T("The Great Spring", "A Grande Mola", "El Gran Muelle"),
              "text": T("The council hall did not turn. {honest_n} of 3 honest masters were brought out of the quarters; {turned} of the city's buildings turned.",
                        "A sala do conselho não virou. {honest_n} de 3 mestres honestos foram trazidos dos bairros; {turned} edifícios da cidade viraram.",
                        "La sala del consejo no se volvió. {honest_n} de 3 maestros honrados fueron sacados de los barrios; {turned} edificios de la ciudad se volvieron."),
              "text_if": [
                  {"if": SPRING_STOPPED, "text": T("Hollweg stopped the great spring: every machine in Concórdia stood still.", "Hollweg parou a grande mola: todas as máquinas de Concórdia pararam.",
                                                   "Hollweg paró el gran muelle: todas las máquinas de Concórdia se quedaron quietas.")},
                  {"if": SPRING_RUNNING, "text": T("Hollweg let the great spring run.", "Hollweg deixou a grande mola correr.", "Hollweg dejó correr el gran muelle.")}]},
    "machine": {"still": "red_dawn", "title": T("The Council Hall turned", "A Sala do Conselho virou", "La Sala del Consejo se volvió"),
                "text": T("The machine had the council hall before dawn.", "A máquina teve a sala do conselho antes do amanhecer.",
                          "La máquina tuvo la sala del consejo antes del amanecer.")},
}


# ================================================================== the triggers
def machine(tag, kinds, near=None, at=None, extra_tags=(), cond=None, order=None):
    """Spawns for the machine (scripted orders only reach it when no person plays it: MissionRun._order)."""
    out = []
    for (k, n) in kinds:
        sp = {"team": "machine", "kind": k, "count": n, "tag": tag, "tags": ["machine_men"] + list(extra_tags)}
        if near:
            sp["near"] = near
            sp["at"] = at or "council_sq"
        else:
            sp["at"] = at
        if cond:
            sp["if"] = cond
        if order:
            sp["order"] = order
        out.append({"spawn": sp})
    return out


TR_ = M["triggers"]
FIND_AT = {"north": "n_press", "forge": "f_works", "mill": "m_press", "market": "k_press", "upper": "u_works"}
TR_ += [
    # ============================================================ THE START
    {"id": "setup", "when": {"time": 0.5}, "do": [
        {"spare": {"tag": "families", "on": True}}, {"spare": {"tag": "voice", "on": True}}, {"spare": {"tag": "ortlieb", "on": True}},
        {"spare": {"tag": "citizens", "on": True}}, {"spare": {"tag": "hall", "on": True}}, {"spare": {"tag": "spring_tower", "on": True}},
        {"spare": {"tag": "mhouse_forge", "on": True}}, {"spare": {"tag": "mhouse_mill", "on": True}}, {"spare": {"tag": "mhouse_market", "on": True}},
        {"counter": {"name": "houses", "count": {"tag": "houses"}}}, {"counter": {"name": "houses_n", "count": {"tag": "houses"}}},
        {"give": {"team": "guild", "tension": TENSION}}, {"wind": {"tag": "army", "share": 1.0}}, {"wind": {"tag": "hall_guard", "share": 1.0}},
        {"objective": {"id": "hall", "set": "active"}}, {"objective": {"id": "quarter", "set": "active"}}]},
    {"id": "voice_name_m", "when": {"all": [{"time": 0.5}, EXECUTED]}, "do": [{"name": {"tag": "voice", "name": T("Citizen Morel", "Cidadão Morel", "Ciudadano Morel")}}]},
    # THE PLATES UNDER EVERY STREET: the city's and the machine's automata are wound wherever they stand (until the brake)
    {"id": "plates_wind", "when": {"all": [{"time": 1}, {"not": SPRING_STOPPED}]}, "every": 3, "do": [
        {"wind": {"team": "machine", "share": 1.0}}, {"wind": {"tag": "city_men", "share": 1.0}},
        # (the honest masters' machines walk the same plated streets: kept from running down, if not full: a Winder or the
        # quarter's tower winds them the rest of the way)
        {"wind": {"team": "guild", "share": PLATES_OURS}}]},
    # ============================================================ PART 1: THE VOTE
    {"id": "vote", "when": {"time": 2}, "do": [
        {"show": {"pages": [{"still": "council", "lines": ["n_vote", "o_vote", "mt_vote", {"id": "v_vote", "if": SPARED}, {"id": "m_vote", "if": EXECUTED},
                                                          "n_vote_r", "h_vote", "mt_walk", "n_walk", {"id": "n_walk_many", "if": SAVED_MANY},
                                                          {"id": "n_walk_few", "if": SAVED_FEW}]}]}},
        {"order": {"tag": "voice", "do": "move", "to": "hall_yard"}}, {"order": {"tag": "ortlieb", "do": "move", "to": "q_north"}}]},
    {"id": "part1", "when": {"all": [{"fired": "vote"}, GUILD]}, "delay": 1, "do": [
        {"objective": {"id": "find", "set": "active"}}] + [{"ping": {"area": FIND_AT[q]}} for q, _l in FIND]},
    {"id": "part1_say", "when": {"all": [{"fired": "part1"}, JAKOB_ALIVE]}, "do": [{"say": ["mt_1", "h_1", "u_1"]}]},
    {"id": "part1_say_l", "when": {"all": [{"fired": "part1"}, JAKOB_LOST]}, "do": [{"say": ["mt_1_lost", "h_1", "u_1"]}]},
    {"id": "owls_ask", "when": {"fired": "part1"}, "delay": 22, "do": [
        {"say": ["u_owls"]}, {"objective": {"id": "owls", "set": "active"}}, {"ping": {"tag": "aviary"}}]},
    {"id": "owls_n", "when": {"fired": "part1"}, "every": 1, "do": [{"counter": {"name": "owls", "count": {"team": "guild", "kind": "ticking_owl"}}}]},
    {"id": "owls_plans", "when": {"all": [{"fired": "owls_ask"}, {"researched": {"team": "guild", "tech": "owl_morph"}}]}, "do": [{"say": ["u_morph"]}]},
    {"id": "owls_done", "when": {"all": [{"fired": "owls_ask"}, {"counter": {"name": "owls", "at_least": 2}}]}, "do": [
        {"objective": {"id": "owls", "set": "done"}}, {"say": ["h_owls"]}]},
]
# FIND THE MESHING: four doors; at each the sign, and its doorway's machines turn on the watcher
for q, lot in FIND:
    TR_ += [
        {"id": "find_" + q, "when": {"all": [{"fired": "part1"}, {"not": {"fired": "part2"}}, {"stay": {"team": "guild", "area": lot, "secs": STAY_SECS}}, LIVE]}, "do": [
            {"counter": {"name": "found", "add": 1}}, {"say": ["n_find_" + q]}]},
        {"id": "turnon_" + q, "when": {"fired": "find_" + q}, "delay": 3, "do": [
            {"convert": {"tag": "cm_" + q, "to": "machine", "warn": 1.5, "as": "machine_men"}},
            {"order": {"tag": "cm_" + q, "do": "attack", "to": lot}}]},
    ]
TR_ += [
    {"id": "turnon_say", "when": {"any": [{"fired": "turnon_" + q} for q, _l in FIND]}, "do": [{"say": ["n_turnon"]}]},
    {"id": "found_all", "when": {"all": [{"counter": {"name": "found", "at_least": 4}}, LIVE]}, "delay": 2, "do": [
        {"objective": {"id": "find", "set": "done"}}, {"say": ["h_found", "mt_found"]}]},
    # ============================================================ PART 2: THE CITY TURNS (the thirteenth hour)
    {"id": "part2_go", "when": {"any": [{"fired": "found_all"}, {"time": PART1_LATE}, {"all": [NO_GUILD, {"time": MIRROR_P2}]}]}, "delay": 0, "do": []},
    {"id": "part2", "when": {"all": [{"fired": "part2_go"}, LIVE]}, "delay": 8, "do": [
        {"light": {"to": "night", "secs": 10}}, {"sound": {"name": "campaign/bell_toll"}}, {"say": ["n_13"]},
        {"objective": {"id": "find", "set": "hidden"}},
        {"objective": {"id": "turning", "set": "active"}}, {"objective": {"id": "masters", "set": "active"}},
        {"clock": {"name": "night", "secs": PART2_LONG}},
        # the great spring's tower is the machine's (when nobody plays it, it was the city's until now), and the hill's
        # automata with it
        {"spread_convert": {"name": "tower", "from": "spring_tower", "tag": "spring_tower", "to": "machine", "every": 0.25, "first": 0.1, "warn": 2, "max": 1}},
        {"convert": {"tag": "cm_upper", "to": "machine", "warn": 1, "as": "machine_men"}}, {"convert": {"tag": "cmw_upper", "to": "machine", "warn": 1}},
        # the plates under the hill: visible gear ground round the spring (the machine's units wound on it)
        {"ground": {"name": "plates", "from": "spring_tower", "kind": "gear", "team": "machine", "r": 3, "step": 1, "every": 6, "max": 11, "wind": 0.05}},
        # the honest masters at home in their quarters
    ] + [{"spawn": {"team": "council", "kind": "missionary", "as": "city_master", "count": 1, "fixed": True, "at": lot, "tag": "master_" + q, "tags": ["masters"],
                    "name": T("Master " + nm, "Mestre " + nm, "Maestro " + nm)}} for (q, lot, nm) in MASTERS]
      + [{"spare": {"tag": "masters", "on": True}}, {"ping": {"tag": "masters"}}]},
    {"id": "part2_say", "when": {"all": [{"fired": "part2"}, GUILD]}, "delay": 2, "do": [{"say": ["h_13", "mt_13", "n_turn", "u_turn"]}]},
    {"id": "part2_say2", "when": {"all": [{"fired": "part2"}, GUILD]}, "delay": 16, "do": [{"say": ["u_masters", "h_hold"]}]},
    {"id": "leap_ask", "when": {"all": [{"fired": "part2"}, GUILD]}, "delay": 30, "do": [
        {"say": ["u_leap"]}, {"objective": {"id": "leap", "set": "active"}}, {"ping": {"tag": "escapement"}}]},
    {"id": "leap_done", "when": {"all": [{"fired": "leap_ask"}, {"researched": {"team": "guild", "tech": "high_leap"}}]}, "do": [
        {"objective": {"id": "leap", "set": "done"}}]},
    {"id": "p2_v", "when": {"all": [{"fired": "part2"}, SPARED, GUILD]}, "delay": 60, "do": [{"say": ["v_2"]}]},
    {"id": "p2_m", "when": {"all": [{"fired": "part2"}, EXECUTED, GUILD]}, "delay": 60, "do": [{"say": ["m_2", "h_m2"]}]},
    # (the machine played) its own words and objectives; the solo pick's dawn
    {"id": "m_intro", "when": {"all": [{"time": 1.5}, MACH]}, "do": [{"say": ["n_m_tip"]}, {"objective": {"id": "m_hall", "set": "active"}}]},
    {"id": "m_dawn_set", "when": {"all": [{"time": 1.5}, MACH, NO_GUILD]}, "do": [
        {"clock": {"name": "dawn_m", "secs": DAWN_MIRROR}}, {"objective": {"id": "m_dawn", "set": "active"}}]},
    {"id": "m_turn_obj", "when": {"all": [{"fired": "part2"}, MACH]}, "do": [{"objective": {"id": "m_turn", "set": "active"}}]},
    # a04 `broken` kept: the broken ones from Fürth stand up in the quarter's own yard
    {"id": "broken", "when": {"all": [{"fired": "part2"}, KEPT, LIVE]}, "delay": 25, "do":
        machine("broken", [("clock_soldier", 2)], at="broken_yard", extra_tags=["wave_q"])
        + [{"say": ["n_broken", "h_broken"]}, {"ping": {"area": "broken_yard"}}]},
    # d04 `colonists` parley: Captain Arruda keeps his word; fought: the valley rings its bells and stays home
    {"id": "valley", "when": {"all": [{"fired": "part2"}, PARLEY, LIVE]}, "delay": 50, "do": [
        {"spawn": {"team": "valley", "kind": "cuirassier", "as": "arruda", "count": 1, "fixed": True, "at": "valley_road", "tag": "valley_men"}},
        {"spawn": {"team": "valley", "kind": "musketeer", "as": "valley_militia", "count": 4, "fixed": True, "at": "valley_road", "tag": "valley_men"}},
        {"order": {"tag": "valley_men", "do": "route", "route": ["market_road", "square_s", "hall_yard"], "attack": True, "name": "valley_up"}},
        {"say": ["n_valley", "ar_valley", "h_valley"]}, {"ping": {"area": "valley_road"}}]},
    {"id": "valley_f", "when": {"all": [{"fired": "part2"}, FOUGHT, GUILD]}, "delay": 50, "do": [{"say": ["n_valley_f"]}]},
]
# THE TURNING: the city's works turn one by one from the great spring outward (by difficulty; a year further on with the pattern)
for d in ("easy", "normal", "hard"):
    for pat, cond in (("p", PATTERN), ("m", FROM_MEMORY)):
        ev = TURN_EVERY[d] + (TURN_PATTERN if pat == "p" else 0)
        TR_.append({"id": "turning_%s_%s" % (d, pat), "when": {"all": [{"fired": "part2"}, {"difficulty": d}, cond]}, "delay": 1, "do": [
            {"spread_convert": {"name": "city", "from": "spring_tower", "tag": "meshed", "to": "machine", "every": ev, "first": 6,
                                "warn": TURN_WARN, "units": "city_men", "counter": "turned"}}]})
# each quarter that turns sends its machines against the hall and the quarter
WAVE = {"upper": [("clock_soldier", 2)], "north": [("clock_soldier", 2)], "forge": [("clock_soldier", 2), ("netter", 1)],
        "mill": [("clock_soldier", 2), ("springer", 1)], "market": [("clock_soldier", 2), ("springer", 1)]}
for q in QUARTERS:
    TR_ += [
        {"id": "q_turned_" + q, "when": {"all": [{"fired": "part2"}, {"count": {"tag": "qb_" + q, "of_team": "machine", "at_least": 1}}, LIVE]}, "delay": 2, "do":
            machine("wave_" + q, WAVE[q], near="qb_" + q, extra_tags=["wave_h" if q in ("forge", "mill", "upper") else "wave_q"])
            + [{"ping": {"tag": "qb_" + q}}]},
    ]
TR_ += [
    {"id": "q_turned_say", "when": {"all": [{"any": [{"fired": "q_turned_" + q} for q in ("north", "forge", "mill", "market")]}, GUILD]}, "do": [{"say": ["n_quarter_turns"]}]},
    # (the scripted machine never stands about: the waves go for the hall and the quarter)
    {"id": "assault", "when": {"all": [{"fired": "part2"}, {"not": {"fired": "part3"}}, LIVE, {"not": {"fired": "spring_set"}}]}, "delay": 6, "every": 8, "do": [
        {"order": {"tag": "wave_h", "do": "attack", "to": "hall_door", "idle": True}},
        {"order": {"tag": "wave_q", "do": "attack", "to": "quarter_in", "idle": True}},
        {"order": {"tag": "city_men", "only_team": "machine", "do": "attack", "to": "hall_door", "idle": True}},
        {"order": {"tag": "broken", "do": "attack", "to": "quarter_in", "idle": True}}]},
    # (at dawn the machine draws everything it has to the spring: the waves leave the quarter and the hall and go for the
    # column under the hill)
    {"id": "recall", "when": {"fired": "part3"}, "do": [
        {"order": {"tag": "wave_h", "do": "attack", "to": "below_stair_w"}}, {"order": {"tag": "wave_q", "do": "attack", "to": "below_stair_w"}},
        {"order": {"tag": "broken", "do": "attack", "to": "below_stair_w"}},
        {"order": {"tag": "city_men", "only_team": "machine", "do": "attack", "to": "below_stair_w"}}]},
    {"id": "assault3", "when": {"all": [{"fired": "part3"}, LIVE, {"not": {"fired": "spring_set"}}]}, "delay": 4, "every": 8, "do": [
        {"order": {"tag": "wave_h", "do": "attack", "to": "below_stair_w", "idle": True}},
        {"order": {"tag": "wave_q", "do": "attack", "to": "below_stair_w", "idle": True}},
        {"order": {"tag": "broken", "do": "attack", "to": "below_stair_w", "idle": True}},
        {"order": {"tag": "city_men", "only_team": "machine", "do": "attack", "to": "below_stair_w", "idle": True}}]},
]
# a turned workshop sends two more every so often until it is broken
for i, nm in enumerate(WORKS):
    TR_.append({"id": "send_" + nm, "when": {"all": [{"fired": "part2"}, {"count": {"tag": "w_" + nm, "of_team": "machine", "at_least": 1}}, LIVE,
                                                       {"not": {"fired": "part3"}}]},
                "delay": SEND_EVERY, "every": SEND_EVERY, "do":
                    machine("sent_" + nm, [("clock_soldier", 1)], near="w_" + nm, extra_tags=["wave_h" if i % 2 == 0 else "wave_q"])})
TR_ += [
    {"id": "works_say", "when": {"all": [{"any": [{"fired": "send_" + nm} for nm in WORKS]}, GUILD]}, "do": [
        {"say": ["u_works"]}, {"objective": {"id": "break_works", "set": "active"}}]},
    {"id": "works_n", "when": {"fired": "part2"}, "every": 2, "do": [
        {"counter": {"name": "broken_n", "set": len(WORKS)}}, {"counter": {"name": "alive_w", "count": {"tag": "meshed"}}},
        {"counter": {"name": "broken_n", "sub_counter": "alive_w"}}]},
]
# BRING THE HONEST MASTERS OUT: a man of ours at his house before his quarter turns; too late, he stays with his machines
for i, (q, lot, nm) in enumerate(MASTERS):
    still = {"count": {"tag": "master_" + q, "of_team": "council", "at_least": 1}}
    out = [{"convert": {"tag": "master_" + q, "to": "quarter", "warn": 0.5, "as": "saved_master"}},
           {"order": {"tag": "master_" + q, "do": "move", "to": "quarter_in"}}, {"counter": {"name": "honest_n", "add": 1}}]
    TR_ += [
        {"id": "master_in_" + q, "when": {"all": [{"fired": "part2"}, still, {"near": {"tag": "master_" + q, "to_team": "guild", "within": 3}},
                                                  {"count": {"tag": "qb_" + q, "of_team": "machine", "below": 1}}, LIVE]}, "do":
            out + [{"say": ["n_master_in", "ms_in"]}]},
        # (the machine played by the solo pick: the scripted masters run for the quarter by themselves, if they can)
        {"id": "master_run_" + q, "when": {"all": [{"fired": "part2"}, NO_GUILD, still, {"count": {"tag": "qb_" + q, "of_team": "machine", "below": 1}}, LIVE]},
         "delay": 45 + 25 * i, "do": out},
        {"id": "master_lost_" + q, "when": {"all": [{"fired": "part2"}, still, {"count": {"tag": "qb_" + q, "of_team": "machine", "at_least": 1}},
                                                    {"not": {"fired": "master_in_" + q}}, {"not": {"fired": "master_run_" + q}}, LIVE]}, "delay": 3, "do": [
            {"convert": {"tag": "master_" + q, "to": "machine", "warn": 1}}, {"counter": {"name": "lost_masters", "add": 1}}, {"say": ["n_master_lost"]}]},
    ]
TR_ += [
    {"id": "masters_done", "when": {"all": [{"fired": "part2"},
                                            {"count": {"tag": "masters", "of_team": "council", "below": 1}}]}, "delay": 1, "do": [
        {"objective": {"id": "masters", "set": "done"}}]},
    # (the machine played) any of the city's buildings it stands at a moment turns at once
] + [
    {"id": "m_take_" + nm, "when": {"all": [{"fired": "part2"}, MACH, {"count": {"tag": "w_" + nm, "of_team": "city", "at_least": 1}},
                                            {"stay": {"team": "machine", "area": nm, "secs": 5}}, LIVE]}, "do": [
        {"spread_convert": {"name": "take_" + nm, "from": "w_" + nm, "tag": "w_" + nm, "to": "machine", "every": 0.25, "first": 0.1, "warn": 1.5, "units": "city_men",
                            "counter": "turned", "max": 1}}]}
    for nm in WORKS
] + [
    # ---- the hall: machines at its door, nobody of ours by it: it turns
    {"id": "hall_warn", "when": {"all": [{"count": {"team": "machine", "area": "hall_door", "at_least": 2}}, GUILD, LIVE]}, "every": 40, "times": 4, "do": [
        {"say": ["n_hall"]}, {"ping": {"tag": "hall"}}]},
    {"id": "hall_turns", "when": {"all": [{"stay": {"team": "machine", "kind": HALL_KINDS, "area": "hall_door", "secs": HALL_SECS, "count": HALL_COUNT}},
                                          {"count": {"team": "guild", "area": "hall_yard", "below": 1}}, {"count": {"team": "valley", "area": "hall_yard", "below": 1}},
                                          {"count": {"tag": "hall", "of_team": "council", "at_least": 1}}, {"not": {"fired": "part3"}}, LIVE]}, "do": [
        {"spread_convert": {"name": "hall", "from": "hall", "tag": "hall", "to": "machine", "every": 0.25, "first": 0.1, "warn": 1.5, "max": 1}}]},
    {"id": "hall_lost", "when": {"all": [{"count": {"tag": "hall", "of_team": "machine", "at_least": 1}}, LIVE]}, "do": [
        {"say": ["n_hall_lost"]}, {"objective": {"id": "hall", "set": "failed"}}, {"objective": {"id": "m_hall", "set": "done"}}]},
    # ---- the quarter
    {"id": "houses_n", "when": {"time": 2}, "every": 1, "do": [{"counter": {"name": "houses", "count": {"tag": "houses"}}}]},
    {"id": "quarter_lost", "when": {"all": [{"time": 3}, {"any": [{"count": {"tag": "houses", "below": 1}}, {"dead": "q_tower"}]}, LIVE]}, "do": [
        {"say": ["n_quarter_lost"]}, {"objective": {"id": "quarter", "set": "failed"}}, {"objective": {"id": "m_hall", "set": "done"}}]},
    # ---- Part 2 over: every building turned, or the night's end (dawn)
    {"id": "all_turned", "when": {"all": [{"fired": "part2"}, {"counter": {"name": "turned", "at_least": len(WORKS)}}]}, "delay": 15, "do": []},
    {"id": "dawn", "when": {"all": [{"any": [{"fired": "all_turned"}, {"clock_out": "night"}]}, GUILD, LIVE, {"not": {"fired": "hall_lost"}}]}, "do": [
        {"clock": {"name": "night", "stop": True}}]},
    # ============================================================ PART 3: THE GREAT SPRING (dawn)
    {"id": "part3", "when": {"fired": "dawn"}, "delay": 2, "do":
        [{"light": {"to": "dawn", "secs": 15}}, {"say": ["n_dawn"]},
         {"objective": {"id": "turning", "set": "done"}}, {"objective": {"id": "hall", "set": "done"}},
         {"objective": {"id": "brake", "set": "active"}}, {"ping": {"area": "brake"}}]
        # the stairs held: shooters and a Pendulum at the top, soldiers at the foot
        + machine("guard_w", [("netter", 1), ("springer", 1)], at="upper_w", order="hold")
        + machine("guard_s", [("netter", 1), ("springer", 1)], at="upper_s", order="hold")
        + machine("foot_w", [("clock_soldier", 2)], at="below_stair_w", order="hold")
        + machine("foot_s", [("clock_soldier", 2)], at="below_stair_s", order="hold")
        + machine("yard", [("clock_soldier", 2), ("pendulum", 1)], at="spring_top", order="hold")},
    {"id": "part3_say", "when": {"fired": "part3"}, "delay": 3, "do": [{"say": ["h_3", "mt_3"]}]},
    {"id": "part3_tip", "when": {"fired": "part3"}, "delay": 14, "do": [{"say": ["u_3"]}]},
    {"id": "part3_leap_hide", "when": {"fired": "part3"}, "do": [{"objective": {"id": "masters", "set": "hidden"}}, {"objective": {"id": "break_works", "set": "hidden"}},
                                                                {"objective": {"id": "owls", "set": "hidden"}}, {"objective": {"id": "leap", "set": "hidden"}},
                                                                {"clock": {"name": "noon", "secs": PART3_NOON}}, {"objective": {"id": "noon", "set": "active"}}]},
    {"id": "noon_lost", "when": {"all": [{"fired": "part3"}, {"clock_out": "noon"}, {"not": {"fired": "at_brake"}}, LIVE]}, "do": [
        {"say": ["n_noon"]}, {"objective": {"id": "noon", "set": "failed"}}, {"objective": {"id": "brake", "set": "failed"}}]},
    # THE BRAKE: Hollweg at the great spring, a moment
    {"id": "at_brake", "when": {"all": [{"fired": "part3"}, {"stay": {"tag": "hollweg", "area": "brake", "secs": BRAKE_SECS}}, LIVE]}, "do": [
        {"objective": {"id": "brake", "set": "done"}}, {"objective": {"id": "noon", "set": "done"}}, {"clock": {"name": "noon", "stop": True}},
        {"say": ["n_brake", "h_brake"]}]},
    {"id": "brake_mt", "when": {"all": [{"fired": "at_brake"}, JAKOB_ALIVE]}, "do": [{"say": ["mt_brake"]}]},
    {"id": "brake_mt_l", "when": {"all": [{"fired": "at_brake"}, JAKOB_LOST]}, "do": [{"say": ["mt_brake_lost"]}]},
    {"id": "brake_v", "when": {"all": [{"fired": "at_brake"}, SPARED]}, "delay": 0.5, "do": [{"say": ["v_brake"]}]},
    {"id": "brake_m", "when": {"all": [{"fired": "at_brake"}, EXECUTED]}, "delay": 0.5, "do": [{"say": ["m_brake"]}]},
    # THE CHOICE, THE GREAT SPRING (the guild's player: the panel; else RUNNING, the canon)
    {"id": "spring_ask", "when": {"fired": "at_brake"}, "delay": 1, "do": [
        {"say": ["h_pride"]},
        {"choice": {"id": "spring", "side": "guild", "title": T("THE GREAT SPRING", "A GRANDE MOLA", "EL GRAN MUELLE"),
                    "line": "q_spring", "default": "running", "time": 60,
                    "options": [
                        {"id": "stopped", "label": T("STOP IT", "PARÁ-LA", "PARARLO"),
                         "about": T("Every machine in Concórdia stops, ours with theirs. The honest masters take their families to the coast with Hollweg; the city lies dead brass.",
                                    "Todas as máquinas de Concórdia param, as nossas com as deles. Os mestres honestos levam as famílias para a costa com Hollweg; a cidade fica latão morto.",
                                    "Todas las máquinas de Concórdia se paran, las nuestras con las suyas. Los maestros honrados llevan a sus familias a la costa con Hollweg; la ciudad queda latón muerto."),
                         "do": [{"say": ["h_stop", "n_stop", "mt_stop"]}, {"brake": {"faction": "clockwork", "name": "great_spring"}},
                                {"spread_convert": {"name": "city", "stop": True}}]},
                        {"id": "running", "label": T("LET IT RUN", "DEIXÁ-LA CORRER", "DEJARLO CORRER"),
                         "about": T("The city goes on. Hollweg believes the meshing beaten in the quarters he saved, and stays its master.",
                                    "A cidade continua. Hollweg acredita que o engrenamento foi vencido nos bairros que salvou, e fica seu mestre.",
                                    "La ciudad sigue. Hollweg cree vencido el engranaje en los barrios que salvó, y sigue siendo su amo."),
                         "do": [{"say": ["h_run", "n_run", "mt_run"]}, {"spread_convert": {"name": "city", "stop": True}},
                                {"order": {"team": "machine", "do": "hold"}}, {"spare": {"tag": "machine_men", "on": True}}]}]}}]},
    {"id": "spring_set", "when": {"all": [{"fired": "spring_ask"}, {"any": [SPRING_STOPPED, {"flag": {"spring": "running"}}]}]}, "do": []},
    {"id": "won", "when": {"all": [{"fired": "spring_set"}, LIVE]}, "delay": 6, "do": [
        {"light": {"to": "day", "secs": 6}},
        {"tally": {"flag": "honest", "counter": "honest_n", "of": "honest_max", "bands": [[0, "few"], [0.5, "some"], [0.9, "many"]]}}]},
    {"id": "the_end", "when": {"fired": "won"}, "delay": 3, "do": [{"win": "guild"}]},
    # ============================================================ THE ENDS (lost)
    {"id": "lost_end", "when": {"all": [GUILD, {"any": [{"fired": "hall_lost"}, {"fired": "quarter_lost"}, {"fired": "noon_lost"}]}, {"not": {"fired": "won"}}]}, "delay": 4, "do": [
        {"lose": "guild"}]},
    # the machine's win (the solo pick or versus): the hall turned or the quarter broken before dawn
    {"id": "m_won", "when": {"all": [MACH, {"any": [{"fired": "hall_lost"}, {"fired": "quarter_lost"}]}, {"not": {"fired": "won"}},
                                     {"not": {"fired": "m_lost"}}]}, "do": [{"flag": {"spring": "running", "honest": "few"}}]},
    {"id": "m_end", "when": {"fired": "m_won"}, "delay": 4, "do": [{"win": "machine"}]},
    # the solo pick's dawn with the hall and the quarter standing: lost for the machine
    {"id": "m_lost", "when": {"all": [NO_GUILD, {"clock_out": "dawn_m"}, {"not": {"fired": "m_won"}}, LIVE]}, "do": [
        {"say": ["n_m_lost"]}, {"objective": {"id": "m_hall", "set": "failed"}}]},
    {"id": "m_lost_end", "when": {"fired": "m_lost"}, "delay": 4, "do": [{"lose": "machine"}]},
    # (the machine played by the solo pick: the scripted honest masters hold the hall and their quarter)
    {"id": "g_hold", "when": {"all": [{"time": 1}, NO_GUILD, LIVE]}, "every": 10, "do": [
        {"order": {"tag": "hall_guard", "do": "attack", "to": "hall_yard", "idle": True}},
        {"order": {"tag": "army", "do": "attack", "to": "quarter_gate", "idle": True}}]},
    # ============================================================ HURTS
    {"id": "hollweg_hurt", "when": {"all": [{"hp": {"tag": "hollweg", "below": 0.6}}, GUILD]}, "every": 60, "times": 2, "do": [{"say": ["h_hurt"]}, {"ping": {"tag": "hollweg"}}]},
    {"id": "matthias_hurt", "when": {"all": [{"hp": {"tag": "matthias", "below": 0.6}}, GUILD]}, "every": 60, "times": 2, "do": [{"say": ["mt_hurt"]}]},
]
# THE ROSTER LADDER (docs/campaign_roster_ladder.md): the honest masters are bound to K6, the Ticking Owl and High Leap
import roster_ladder   # noqa: E402
roster_ladder.apply(M, MID)
for k in ("owl_morph", "high_leap"):
    lid = "new_" + k
    T(M["lines"][lid]["text"], roster_ladder.CARDS_PT[k], roster_ladder.CARDS_ES[k])

# ---------------------------------------------------------------- texts this mission brings elsewhere (their pt / es here):
# the new roles (scripts/campaign/rebels.gd), the hub after d07 (campaign/campaign.json, campaign/hubs_grow.json), the
# war map's lines (campaign/warmap.json: its d07 rules were written by act2-warmap)
for (en, pt, es) in [
    ("Matthias", "Matthias", "Matthias"),
    ("Master Ortlieb", "Mestre Ortlieb", "Maestro Ortlieb"),
    ("Jakob's son, a Winder of the Nuremberg quarter: the honest masters' speaker.", "O filho de Jakob, Enrolador do bairro de Nuremberg: o porta-voz dos mestres honestos.",
     "El hijo de Jakob, Dador de cuerda del barrio de Núremberg: el portavoz de los maestros honrados."),
    ("A master of Concórdia's council who winds a machine every night.", "Um mestre do conselho de Concórdia que dá corda a uma máquina todas as noites.",
     "Un maestro del consejo de Concórdia que da cuerda a una máquina cada noche."),
    ("A citizen of Concórdia.", "Um cidadão de Concórdia.", "Un ciudadano de Concórdia."),
    ("A master of one of Concórdia's quarters, at home with his machines.", "Um mestre de um dos bairros de Concórdia, em casa com as suas máquinas.",
     "Un maestro de uno de los barrios de Concórdia, en casa con sus máquinas."),
    # the hubs after d07
    ("A Fisherman's House on the Coast", "Uma Casa de Pescadores na Costa", "Una Casa de Pescadores en la Costa"),
    ("Hollweg and the honest masters, out of the dead city, waiting for a ship.", "Hollweg e os mestres honestos, fora da cidade morta, à espera de um navio.",
     "Hollweg y los maestros honrados, fuera de la ciudad muerta, esperando un barco."),
    ("A fisherman's house on the coast: the brass map on a net-mender's table, the sea through the door.",
     "Uma casa de pescadores na costa: o mapa de latão na mesa de um remendador de redes, o mar pela porta.",
     "Una casa de pescadores en la costa: el mapa de latón en la mesa de un remendador de redes, el mar por la puerta."),
    ("The Great Spring's Tower", "A Torre da Grande Mola", "La Torre del Gran Muelle"),
    ("Concórdia runs by itself. The council's chairs are empty; the spring turns.", "Concórdia anda sozinha. As cadeiras do conselho estão vazias; a mola gira.",
     "Concórdia anda sola. Las sillas del consejo están vacías; el muelle gira."),
    ("The great spring's tower over the mine: nobody winds anything here any more.", "A torre da grande mola sobre a mina: aqui já ninguém dá corda a nada.",
     "La torre del gran muelle sobre la mina: aquí ya nadie da cuerda a nada."),
    ("I pulled the brake. Every machine I ever made stood still at once, the honest ones too. It was the first thing I ever stopped.",
     "Puxei o travão. Todas as máquinas que alguma vez fiz pararam de uma vez, também as honestas. Foi a primeira coisa que alguma vez parei.",
     "Tiré del freno. Todas las máquinas que hice se pararon de golpe, también las honradas. Fue lo primero que paré en mi vida."),
    ("Matthias says his father would be glad. I have not written to Jakob. I do not know what I would say.",
     "Matthias diz que o pai ficaria contente. Não escrevi ao Jakob. Não sei o que lhe diria.",
     "Matthias dice que su padre se alegraría. No he escrito a Jakob. No sé qué le diría."),
    ("The council met at noon. Half the chairs were empty, but the city held. I let the spring run.",
     "O conselho reuniu-se ao meio-dia. Metade das cadeiras estava vazia, mas a cidade aguentou. Deixei a mola correr.",
     "El consejo se reunió a mediodía. La mitad de las sillas estaban vacías, pero la ciudad resistió. Dejé correr el muelle."),
    ("The masters who stayed vote as one now. It is very peaceful. I tell myself that is concord.",
     "Os mestres que ficaram votam como um só agora. É muito tranquilo. Digo a mim mesmo que é concórdia.",
     "Los maestros que se quedaron votan como uno solo ahora. Es muy tranquilo. Me digo que eso es concordia."),
    ("The council hall's lamps are red. Nobody sits at the table. (The King: It did not need to win that night. It had all the nights it wanted.)",
     "As lâmpadas da sala do conselho estão vermelhas. Ninguém se senta à mesa. (O Rei: Não precisava de ganhar naquela noite. Tinha todas as noites que quisesse.)",
     "Las lámparas de la sala del consejo están rojas. Nadie se sienta a la mesa. (El Rey: No necesitaba ganar aquella noche. Tenía todas las noches que quisiera.)"),
    ("Every master's chair is wound now. They vote at noon, and none of them is tired.", "Todas as cadeiras dos mestres têm corda agora. Votam ao meio-dia, e nenhum está cansado.",
     "Todas las sillas de los maestros tienen cuerda ahora. Votan a mediodía, y ninguno está cansado."),
    ("Forty years a Winder. I wound nothing on the coast road, and I slept like a child.", "Quarenta anos de Enrolador. Na estrada da costa não dei corda a nada, e dormi como uma criança.",
     "Cuarenta años de Dador de cuerda. En el camino de la costa no di cuerda a nada, y dormí como un niño."),
    ("I still wind the Nuremberg quarter's soldiers by hand. Nobody else in the city does. They look at me as if I were the one who is wrong.",
     "Ainda dou corda à mão aos soldados do bairro de Nuremberg. Mais ninguém na cidade o faz. Olham para mim como se eu é que estivesse errado.",
     "Todavía doy cuerda a mano a los soldados del barrio de Núremberg. Nadie más en la ciudad lo hace. Me miran como si el equivocado fuera yo."),
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
rows = ["# Act 2's mission d07_spring, \"The Council of Gears\" (campaign/missions/d07_spring.json, written with its texts by",
        "# tools/campaign/make_d07_mission.py: change the texts THERE and run it again; the plan: docs/campaign_act2_plan.md; what",
        "# was built: docs/campaign_d07_build.md). EVERY LINE IS A PLACEHOLDER for the owner. Names as d04: Winder = Enrolador /",
        "# Dador de cuerda; Meister = Mestre / maestro; Swift = Cuco; Ticking Owl = Coruja Tique-Taque / Búho Tictac; HIGH LEAP =",
        "# PULO ALTO / SALTO ALTO; Springer = Saltador (tools/i18n/10_air.txt and the research names).", ""]
for en, pt, es in TR:
    if en in seen:
        continue
    seen.add(en)
    rows += ["> " + en.replace("\n", "\\n"), "pt " + pt.replace("\n", "\\n"), "es " + es.replace("\n", "\\n"), ""]
with open(os.path.join(ROOT, "tools", "i18n", "campaign", MID + ".txt"), "w", encoding="utf-8") as f:
    f.write("\n".join(rows))
print("wrote", os.path.normpath(out), len(M["triggers"]), "triggers", len(M["lines"]), "lines", len(seen), "texts")
