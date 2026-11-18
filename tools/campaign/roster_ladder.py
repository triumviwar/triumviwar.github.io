#!/usr/bin/env python3
"""THE ROSTER LADDER (docs/campaign_roster_ladder.md): what each faction line's player may build, train, research
(and, the Brood, grow to) in each campaign mission, and what is NEW there.

The owner's decision (2026-11-18 07:26-07:27): like StarCraft's campaign, each mission brings one or two new pieces;
the tutorial teaches the controls, the campaign teaches what each piece is FOR. Three ladders, one per faction line
(the Crown line teaches the Crown, the Clockmaker line the Clockwork, the Naturalist line the Brood), each standing
alone. The opposing / scripted / versus side is not bound (it gets what the story needs).

Used two ways:
- the mission generators (tools/campaign/make_*_mission.py) call apply(M, mission_id) before writing the JSON;
- `python3 tools/campaign/roster_ladder.py <mission id>` patches campaign/missions/<id>.json in place (p01_leaf: its
  generator, make_m1_mission.py, is older than the JSON, which was edited later by hand: eco-revert-prologue).

The doc's CHECKED TABLE and tools/test_roster_ladder.gd read the same lists: change them here, regenerate the missions,
then copy `python3 tools/campaign/roster_ladder.py --table` into the doc.

ALL TEXT PLACEHOLDER (the NEW cards' words).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "..")

# ---------------------------------------------------------------- the three ladders, step by step
# Each step: (slot, mission id or "" for a slot not written yet, [NEW pieces], [pieces that come with them]).
# A step's allow-list = the faction's KIT + every earlier step's pieces + its own.

KIT = {
    "crown": ["town_hall", "labourer", "farm", "cottage", "wall", "gate", "barracks", "powder_mill"],
    "clockwork": ["clocktower", "cog_press", "mainspring", "regulator", "movement_works"],
    "brood": ["brood_mother", "grub", "rootmaw", "mound_turtle"],
}

LADDER = {
    "crown": [
        ("C1", "p01_leaf", ["musketeer", "cannon"], []),
        ("C2", "a01_presses", ["horse_breeder", "cuirassier"], ["horse", "dismounted", "messenger"]),
        ("C3", "a06_barricades", ["foundry", "mortar"], []),
        ("C4", "a07_council", ["church", "missionary"], []),
        ("C5", "", ["armoury", "matchlock", "bayonet"], []),
        ("C6", "", ["dragoon", "charge"], []),
        ("C7", "", ["armour", "powder_wagon"], []),
        ("C8", "", ["balloon"], []),
        ("C9", "", ["charges", "quadrant"], []),
        ("C10", "", ["band"], []),
        ("C11", "", ["band_fifer", "band_piper"], []),
        ("C12", "", ["flintlock", "caplock", "pouch"], ["mounted_missionary"]),
    ],
    "clockwork": [
        ("K1", "c01_thirteenth", ["winder", "clock_soldier"], []),
        ("K2", "a02_furth", ["springer", "netter"], ["escapement"]),
        ("K3", "a04_visit", ["heavy_works", "pendulum"], []),
        ("K4", "", ["ratchet_turret", "shield_wall"], []),
        ("K5", "", ["cuckoo_house", "cuckoo"], []),
        ("K6", "", ["owl_morph", "high_leap"], ["ticking_owl"]),
        ("K7", "", ["ballista", "long_chain"], []),
        ("K8", "", ["great_winder"], []),
        ("K9", "", ["brass_serpent"], ["serpent_gear_s", "serpent_gear_b"]),
    ],
    "brood": [
        ("B1", "b01_specimen", ["tyrannosaur", "raptor"], []),
        ("B2", "a03_plateau", ["dilophosaurus", "spitter"], []),
        ("B3", "a05_specimens", ["stage2", "tyrant_challenger", "venom_challenger"], []),
        ("B4", "", ["pterodactyl", "hatchlings"], []),
        ("B5", "", ["nb_clutch_raptor", "nb_pack_hunt", "nb_quick_roots"], []),
        ("B6", "", ["stage3", "brute"], []),
        ("B7", "", ["mist_toad", "nb_fog", "nb_miasma"], []),
        ("B8", "", ["storm_challenger", "nb_updraft", "nb_clutch_hatchlings"], []),
        ("B9", "", ["nb_clutch_spitter", "nb_slither", "nb_long_spit", "nb_battering_horns", "nb_swamp_mending"], []),
    ],
}

# The mission's team(s) the ladder binds (the line's own faction, the side its player leads), and its line's faction.
BOUND = {
    "p01_leaf": ("crown", ["governor", "guns"]),
    "c01_thirteenth": ("clockwork", ["guild"]),
    "b01_specimen": ("brood", ["sire"]),
    "a02_furth": ("clockwork", ["guild"]),
    "a03_plateau": ("brood", ["nest"]),      # (the solo mirror / versus side: Claude's choice 1 in the doc)
    "a01_presses": ("crown", ["garrison", "watch"]),        # (applied at a01-presses' merge, 0.38.58)
    "a04_visit": ("clockwork", ["guild"]),
    "a05_specimens": ("brood", ["creatures"]),
    "a06_barricades": ("crown", ["army", "guns"]),
    "a07_council": ("crown", ["guard", "garrison"]),
}

# The NEW card: one line per new piece, said a few seconds in (to the ladder side only: never the other player's).
# ALL TEXT PLACEHOLDER.
CARDS = {
    "musketeer": "NEW: THE MUSKETEER. The Barracks trains him. One man is nothing; a line of them firing together holds the plantation. Keep them in a line, not a crowd.",
    "cannon": "NEW: THE FIELD CANNON. Captain Ruggieri's two guns: round shot reaches farther than it sees. Keep them behind the line, and at the fort's gate load CANISTER.",
    "horse_breeder": "NEW: THE HORSE BREEDER. It raises the horses: a mounted man is the fastest thing in a city.",
    "cuirassier": "NEW: THE HORSEMAN. Fast and hard-hitting: ride down the runners before they reach the squares.",
    "foundry": "NEW: THE FOUNDRY. Cast your own Field Cannons now, and the Mortar.",
    "mortar": "NEW: THE MORTAR. It lobs its shell over walls: the barricades are its work, not the line's.",
    "church": "NEW: THE CHURCH. Rome's churches train Missionaries.",
    "missionary": "NEW: THE MISSIONARY. He brings the fallen back and leads the people where a soldier can't.",
    "winder": "NEW: THE WINDER. The guild's hands: it builds, works the presses, and winds the machines; a machine run down stands still.",
    "clock_soldier": "NEW: THE CLOCK SOLDIER. The Light Works makes it: a shielded soldier that never tires while it is wound. Keep the Winders behind them.",
    "springer": "NEW: THE SPRINGER. Built at the Light Works once an Escapement ticks: it leaps over the line onto what stands behind it.",
    "netter": "NEW: THE NETTER. Also from the Light Works with an Escapement: its chain and net hold a man fast while the others strike.",
    "heavy_works": "NEW: THE HEAVY WORKS. Beside a Mainspring it builds the great machines.",
    "pendulum": "NEW: THE PENDULUM. A slow giant whose swing cuts everything round it, flyers too.",
    "tyrannosaur": "NEW: THE TYRANT SIRE. A grub becomes him. Rooted by the Mother, he fathers her warrior eggs; up, he fights; his ROAR calls the pack.",
    "raptor": "NEW: THE RAPTORS. Pick them on the Mother's card: an egg of quick biters that hatches in the Sire's nest. Many and fast; weak alone.",
    "dilophosaurus": "NEW: THE VENOM SIRE. A grub becomes him. Rooted by the Mother he fathers Spitters; up, he spits acid from afar.",
    "spitter": "NEW: THE SPITTERS. Two to an egg, fathered by the Venom Sire: acid from behind the Raptors, at ground and air.",
    "stage2": "NEW: GROW. Rooted, the Mother grows to her second stage: more eggs, and the young may MATURE.",
    "tyrant_challenger": "NEW: MATURE. A grown Raptor moults into a Tyrant Challenger; a grown Spitter into a Venom Challenger.",
}
# (pieces that share a card: the Venom Challenger is told with the Tyrant Challenger)
SHARED_CARD = {"venom_challenger": "tyrant_challenger"}

# pt / es of the cards (tools/i18n/campaign/<mission>.txt get the blocks: write_i18n()). Brood "clutch": Ninhada / Nidada.
CARDS_PT = {
    "musketeer": "NOVO: O MOSQUETEIRO. O Quartel o treina. Um homem não é nada; uma linha deles atirando juntos defende a fazenda. Mantenha-os em linha, não em bando.",
    "cannon": "NOVO: O CANHÃO DE CAMPANHA. Os dois canhões do Capitão Ruggieri: a bala rasa alcança mais longe do que eles veem. Mantenha-os atrás da linha e, no portão do forte, carregue METRALHA.",
    "winder": "NOVO: O ENROLADOR. As mãos da guilda: constrói, trabalha as prensas e dá corda às máquinas; uma máquina sem corda fica parada.",
    "clock_soldier": "NOVO: O SOLDADO-RELÓGIO. A Oficina Leve o faz: um soldado de escudo que não cansa enquanto tem corda. Mantenha os Enroladores atrás deles.",
    "springer": "NOVO: O SALTADOR. Feito na Oficina Leve quando um Escape trabalha: salta por cima da linha sobre o que está atrás dela.",
    "netter": "NOVO: O LANÇA-REDES. Também da Oficina Leve com um Escape: sua corrente e sua rede prendem um homem enquanto os outros golpeiam.",
    "tyrannosaur": "NOVO: O SIRE TIRANO. Uma larva se torna ele. Enraizado junto à Mãe, ele fecunda os ovos guerreiros dela; de pé, luta; seu RUGIDO chama a matilha.",
    "raptor": "NOVO: OS RAPTORES. Escolha-os no painel da Mãe: uma ninhada de mordedores rápidos que choca no ninho do Sire. Muitos e rápidos; fracos sozinhos.",
    "dilophosaurus": "NOVO: O SIRE DO VENENO. Uma larva se torna ele. Enraizado junto à Mãe, fecunda Cuspidores; de pé, cospe ácido de longe.",
    "horse_breeder": "NOVO: O CRIADOR DE CAVALOS. Ele cria os cavalos: um homem montado é a coisa mais rápida numa cidade.",
    "cuirassier": "NOVO: O CAVALEIRO. Rápido e de golpe duro: alcance os mensageiros antes que cheguem às praças.",
    "foundry": "NOVO: A FUNDIÇÃO. Funda agora os seus próprios Canhões de Campanha, e o Morteiro.",
    "mortar": "NOVO: O MORTEIRO. Lança a sua granada por cima dos muros: as barricadas são trabalho dele, não da linha.",
    "heavy_works": "NOVO: A OFICINA PESADA. Junto a uma Mola Real, ela constrói as grandes máquinas.",
    "pendulum": "NOVO: O PÊNDULO. Um gigante lento cujo balanço corta tudo à sua volta, voadores também.",
    "stage2": "NOVO: CRESCER. Enraizada, a Mãe cresce ao seu segundo estágio: mais ovos, e os jovens podem AMADURECER.",
    "tyrant_challenger": "NOVO: AMADURECER. Um Raptor crescido muda de pele e vira um Desafiante Tirano; um Cuspidor crescido, um Desafiante Venenoso.",
    "church": "NOVO: A IGREJA. As igrejas de Roma treinam Missionários.",
    "missionary": "NOVO: O MISSIONÁRIO. Traz de volta os caídos e guia o povo onde um soldado não consegue.",
    "spitter": "NOVO: OS CUSPIDORES. Dois por ovo, fecundados pelo Sire do Veneno: ácido por trás dos Raptores, contra terra e ar.",
}
CARDS_ES = {
    "musketeer": "NUEVO: EL MOSQUETERO. El Cuartel lo entrena. Un hombre no es nada; una línea de ellos disparando juntos defiende la plantación. Mantenlos en línea, no en montón.",
    "cannon": "NUEVO: EL CAÑÓN DE CAMPAÑA. Los dos cañones del Capitán Ruggieri: la bala rasa llega más lejos de lo que ven. Mantenlos tras la línea y, en la puerta del fuerte, carga METRALLA.",
    "winder": "NUEVO: EL DADOR DE CUERDA. Las manos del gremio: construye, trabaja las prensas y da cuerda a las máquinas; una máquina sin cuerda se queda quieta.",
    "clock_soldier": "NUEVO: EL SOLDADO RELOJ. El Taller Ligero lo hace: un soldado de escudo que no se cansa mientras tiene cuerda. Mantén a los Dadores de cuerda tras ellos.",
    "springer": "NUEVO: EL SALTADOR. Hecho en el Taller Ligero cuando un Escape trabaja: salta por encima de la línea sobre lo que hay detrás.",
    "netter": "NUEVO: EL LANZARREDES. También del Taller Ligero con un Escape: su cadena y su red sujetan a un hombre mientras los otros golpean.",
    "tyrannosaur": "NUEVO: EL SEÑOR TIRANO. Una larva se convierte en él. Enraizado junto a la Madre, fecunda sus huevos guerreros; en pie, lucha; su RUGIDO llama a la manada.",
    "raptor": "NUEVO: LOS RAPTORES. Elígelos en el panel de la Madre: una nidada de mordedores rápidos que eclosiona en el nido del Señor. Muchos y rápidos; débiles solos.",
    "dilophosaurus": "NUEVO: EL SEÑOR DEL VENENO. Una larva se convierte en él. Enraizado junto a la Madre, fecunda Escupidores; en pie, escupe ácido desde lejos.",
    "horse_breeder": "NUEVO: EL CRIADERO DE CABALLOS. Cría los caballos: un hombre montado es lo más rápido en una ciudad.",
    "cuirassier": "NUEVO: EL JINETE. Rápido y de golpe duro: alcanza a los correos antes de que lleguen a las plazas.",
    "foundry": "NUEVO: LA FUNDICIÓN. Funde ahora tus propios Cañones de Campaña, y el Mortero.",
    "mortar": "NUEVO: EL MORTERO. Lanza su granada por encima de los muros: las barricadas son trabajo suyo, no de la línea.",
    "heavy_works": "NUEVO: EL TALLER PESADO. Junto a un Muelle Real, construye las grandes máquinas.",
    "pendulum": "NUEVO: EL PÉNDULO. Un gigante lento cuyo vaivén corta todo a su alrededor, voladores también.",
    "stage2": "NUEVO: CRECER. Enraizada, la Madre crece a su segunda etapa: más huevos, y los jóvenes pueden MADURAR.",
    "tyrant_challenger": "NUEVO: MADURAR. Un Raptor crecido muda la piel y se vuelve un Retador Tirano; un Escupidor crecido, un Retador Venenoso.",
    "church": "NUEVO: LA IGLESIA. Las iglesias de Roma entrenan Misioneros.",
    "missionary": "NUEVO: EL MISIONERO. Trae de vuelta a los caídos y guía al pueblo donde un soldado no puede.",
    "spitter": "NUEVO: LOS ESCUPIDORES. Dos por huevo, fecundados por el Señor del Veneno: ácido desde detrás de los Raptores, contra tierra y aire.",
}

# When the card is said (seconds into the match) and to which side, per mission.
CARD_AT = {"p01_leaf": 5, "c01_thirteenth": 5, "b01_specimen": 5, "a02_furth": 5, "a03_plateau": 5, "a01_presses": 5, "a06_barricades": 5, "a04_visit": 8, "a05_specimens": 8, "a07_council": 8}
SIDE = {"p01_leaf": "crown", "c01_thirteenth": "guild", "b01_specimen": "sire", "a02_furth": "guild", "a03_plateau": "nest", "a01_presses": "crown", "a06_barricades": "crown", "a04_visit": "visit", "a05_specimens": "creatures", "a07_council": "crown"}


def step_of(mission_id):
    for fac, steps in LADDER.items():
        for i, st in enumerate(steps):
            if st[1] == mission_id:
                return fac, i
    raise KeyError(mission_id)


def allow_of(faction, upto):
    """The allow-list at step index `upto` (inclusive): the kit, then every step's pieces in order."""
    out = list(KIT[faction])
    for st in LADDER[faction][: upto + 1]:
        for k in st[2] + st[3]:
            if k not in out:
                out.append(k)
    return out


def roster_of(mission_id):
    fac, i = step_of(mission_id)
    return {"allow": allow_of(fac, i), "new": list(LADDER[fac][i][2])}


def apply(M, mission_id, story_deny=None, at=None):
    """Sets the bound teams' roster (the ladder's allow-list, its NEW pieces, the story's own deny on top) and adds the
    NEW card: a speaker "new", a line per new piece, a trigger "ladder_new" that says them, to the ladder side only."""
    fac, i = step_of(mission_id)
    r = roster_of(mission_id)
    teams = BOUND[mission_id][1]
    for tm in M["teams"]:
        if tm["id"] in teams:
            ros = {"allow": list(r["allow"]), "new": list(r["new"])}
            deny = (story_deny or {}).get(tm["id"], [])
            if deny:
                ros["deny"] = list(deny)
            tm["roster"] = ros
    side = SIDE[mission_id]
    ids = []
    for k in r["new"]:
        card = SHARED_CARD.get(k, k)
        lid = "new_" + card
        if lid in ids:
            continue
        M["lines"][lid] = {"who": "new", "to": side, "text": CARDS[card]}
        ids.append(lid)
    M["speakers"]["new"] = {"name": "NEW", "side": side}
    M["triggers"] = [t for t in M["triggers"] if t["id"] != "ladder_new"]
    M["triggers"].append({"id": "ladder_new", "when": {"time": at if at is not None else CARD_AT.get(mission_id, 5)},
                          "do": [{"say": ids}]})
    return M


def table():
    """The CHECKED TABLE (docs/campaign_roster_ladder.md): one row per step, the code ids."""
    rows = ["| step | mission | teams | new | comes with | allow-list (code ids) |", "| --- | --- | --- | --- | --- | --- |"]
    for fac, steps in LADDER.items():
        for i, st in enumerate(steps):
            teams = " ".join(BOUND[st[1]][1]) if st[1] in BOUND else "-"
            rows.append("| %s | %s | %s | %s | %s | %s |" % (st[0], st[1] or "(slot)", teams, " ".join(st[2]),
                                                          " ".join(st[3]) or "-", " ".join(allow_of(fac, i))))
    return "\n".join(rows)


def patch(mission_id):
    path = os.path.join(ROOT, "campaign", "missions", mission_id + ".json")
    M = json.load(open(path))
    apply(M, mission_id)
    with open(path, "w") as f:
        json.dump(M, f, indent="\t", ensure_ascii=False)
    print("patched", os.path.normpath(path))


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--table":
        print(table())
    else:
        for mid in sys.argv[1:]:
            patch(mid)
