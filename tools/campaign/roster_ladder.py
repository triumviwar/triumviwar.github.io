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
        ("C5", "d01_minas", ["armoury", "matchlock", "bayonet"], []),
        ("C6", "d05_aldeia", ["dragoon", "charge"], []),
        ("C7", "d09_crossroads", ["armour", "powder_wagon"], []),
        ("C8", "d10_jungle", ["balloon"], []),
        ("C9", "d11_siege", ["charges", "quadrant"], []),
        ("C10", "e01_brazil", ["band"], []),
        ("C11", "e03_virginia", ["band_fifer", "band_piper"], []),
        ("C12", "e12_exiles", ["flintlock", "caplock", "pouch"], ["mounted_missionary"]),
    ],
    "clockwork": [
        ("K1", "c01_thirteenth", ["winder", "clock_soldier"], []),
        ("K2", "a02_furth", ["springer", "netter"], ["escapement"]),
        ("K3", "a04_visit", ["heavy_works", "pendulum"], []),
        ("K4", "d02_exodus", ["ratchet_turret", "shield_wall"], []),
        ("K5", "d04_concordia", ["cuckoo_house", "cuckoo"], []),
        ("K6", "d07_spring", ["owl_morph", "high_leap"], ["ticking_owl"]),
        ("K7", "d11_siege", ["ballista", "long_chain"], []),
        ("K8", "e08_arsenal", ["great_winder"], []),
        ("K9", "e13_gold", ["brass_serpent"], ["serpent_gear_s", "serpent_gear_b"]),
    ],
    "brood": [
        ("B1", "b01_specimen", ["tyrannosaur", "raptor"], []),
        ("B2", "a03_plateau", ["dilophosaurus", "spitter"], []),
        ("B3", "a05_specimens", ["stage2", "tyrant_challenger", "venom_challenger"], []),
        ("B4", "d03_fazenda", ["pterodactyl", "hatchlings"], []),
        # (B5 and B6 SWAPPED by Act 2's plan, Claude's choice 13: the Queen IS stage 3, so d06 gives it)
        ("B5", "d06_queen", ["stage3", "brute"], []),
        ("B6", "d08_rivers", ["nb_clutch_raptor", "nb_pack_hunt", "nb_quick_roots"], []),
        ("B7", "d10_jungle", ["mist_toad", "nb_fog", "nb_miasma"], []),
        ("B8", "e05_river", ["storm_challenger", "nb_updraft", "nb_clutch_hatchlings"], []),
        ("B9", "e11_spice", ["nb_clutch_spitter", "nb_slither", "nb_long_spit", "nb_battering_horns", "nb_swamp_mending"], []),
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
    "d02_exodus": ("clockwork", ["guild"]),           # (Act 2's K4: the solo pick's commissary is not bound: the other side)
    "d03_fazenda": ("brood", ["stock"]),              # (Act 2's B4: the commission's solo pick is not bound: the other side)
    "d04_concordia": ("clockwork", ["guild"]),        # (Act 2's K5: the valley (versus) is not bound: the other side)
    "d01_minas": ("crown", ["garrison"]),             # (Act 2's C5: the conspiracy (versus) is not bound: the other side)
    "d06_queen": ("brood", ["stock"]),                # (Act 2's B5, was B6: the fazenda (solo pick, versus) is not bound)
    "d05_aldeia": ("crown", ["mission"]),             # (Act 2's C6: the swarm (solo pick, versus) is not bound beyond its deny)
    "d08_rivers": ("brood", ["swarm"]),               # (Act 2's B6, was B5: the swarm, the solo pick and versus; the Barra is not bound)
    "d07_spring": ("clockwork", ["guild"]),           # (Act 2's K6: the machine (solo pick, versus) is not bound: the other side)
    "d09_crossroads": ("crown", ["army"]),            # (Act 2's C7: the army; the fort's garrison (co-op) and the versus pick are not bound)
    "d10_jungle": ("crown", ["column"]),              # (Act 2's C8: the jungle column; Óbidos' garrison (co-op) is not bound)
    "d11_siege": ("crown", ["column"]),               # (Act 2's C9: the southern column; the valley (co-op) is not bound)
}
# A mission on TWO ladders (d10: the column's C8 and the swarm's B7 in the mirror and versus): the second ladder's teams and
# its side. Its NEW cards have a speaker and a trigger of their own ("new_<faction>", "ladder_new_<faction>").
EXTRA_BOUND = {
    "d10_jungle": {"brood": ["swarm"]},               # (Act 2's B7: the swarm, the solo pick and versus)
    "d11_siege": {"clockwork": ["city"]},             # (Act 2's K7: the city, the solo pick and versus)
}
EXTRA_SIDE = {"d10_jungle": {"brood": "swarm"}, "d11_siege": {"clockwork": "city"}}

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
    "ratchet_turret": "NEW: THE RATCHET TURRET. A gun of screws that stands still and fires at ground and air. It must stand linked to a gear field: at the landing a Winder builds one by the travelling clock, the rearguard's last stand.",
    "shield_wall": "NEW: SHIELD WALL. Your Clock Soldiers are drilled to it: press SHIELD FORWARD on their card and they walk slower but take half from shots in front. Raise it facing the muskets.",
    "tyrannosaur": "NEW: THE TYRANT SIRE. A grub becomes him. Rooted by the Mother, he fathers her warrior eggs; up, he fights; his ROAR calls the pack.",
    "raptor": "NEW: THE RAPTORS. Pick them on the Mother's card: an egg of quick biters that hatches in the Sire's nest. Many and fast; weak alone.",
    "dilophosaurus": "NEW: THE VENOM SIRE. A grub becomes him. Rooted by the Mother he fathers Spitters; up, he spits acid from afar.",
    "spitter": "NEW: THE SPITTERS. Two to an egg, fathered by the Venom Sire: acid from behind the Raptors, at ground and air.",
    "stage2": "NEW: GROW. Rooted, the Mother grows to her second stage: more eggs, and the young may MATURE.",
    "stage3": "NEW: GROW TO THE THIRD STAGE. Rooted, the Mother grows once more: more eggs, faster laying, and the Brute's eggs. It takes a minute and she must stay rooted.",
    "brute": "NEW: THE BRUTE. Laid by the Mother at her third stage with the Tyrant Sire rooted beside her: a huge horned beast that batters down palisades and gates.",
    "tyrant_challenger": "NEW: MATURE. A grown Raptor moults into a Tyrant Challenger; a grown Spitter into a Venom Challenger.",
    "pterodactyl": "NEW: THE STORM SIRE. A flying father: up, he flies and dives to bite; ROOTED beside the Mother he lands, and she lays the eggs of his line.",
    "hatchlings": "NEW: THE HATCHLINGS. Pick them on the Mother's card while the Storm Sire is rooted by her: little flyers, two to an egg. They bite only flyers, but they see far over the forest.",
    "cuckoo_house": "NEW: THE CLOCK AVIARY. A tall clock with little doors: the machines' birds fly from it. It needs a working Escapement, and runs on Tension: a Mainspring in its gear field.",
    "cuckoo": "NEW: THE SWIFT. A fast brass bird made at the Clock Aviary. It fights only other flyers, but it sees far: here the land off the plateau stays dark until a Swift has flown over it.",
    "owl_morph": "NEW: THE TICKING OWL. Research it at the Clock Aviary, then pick a Swift and press MORPH TO OWL: a heavy brass owl that sees far in the dark, swoops on machines and drops its weight on buildings. It cannot hit flyers.",
    "high_leap": "NEW: HIGH LEAP. Research it at the Escapement: your Springers can JUMP UP onto high ground too, a cliff included, wherever one of yours (an owl above it) sees the top.",
    "armoury": "NEW: THE ARMOURY. The garrison's own, in the lower town: it researches better muskets and bayonets for the Musketeers. Pick it to see what it teaches.",
    "matchlock": "NEW: THE MATCHLOCK. Research it at the Armoury: the Musketeers reload faster. Men already in the ranks get it by a REFIT: turn on AUTO REFIT on the Armoury and idle men near it go to be fitted.",
    "dragoon": "NEW: THE DRAGOON. A Musketeer on a horse: he rides fast down the trails and fires on foot. The relief brings four; the river fort's Barracks trains more beside its Horse Breeder.",
    "charge": "NEW: THE CAVALRY CHARGE. Drill it at a Horse Breeder: a Horseman's first blow after a gallop hits more than twice as hard on light creatures, and throws them back.",
    "nb_clutch_raptor": "NEW: BIGGER CLUTCH. Research it on the Tyrant Sire's card: Raptors hatch three to an egg instead of two (the egg costs more, each Raptor the same). More teeth at the shallows.",
    "nb_pack_hunt": "NEW: PACK HUNT. Research it on the Tyrant Sire's card: Raptors, Tyrant Challengers and the Sire run faster; a Raptor then outruns a horse. Catch the people before the canoes.",
    "nb_quick_roots": "NEW: QUICK ROOTS. Research it on a Mother's card: every creature roots and uproots in half the time. A forward Mother walks down the bank and is rooted again before the guns find her.",
    "bayonet": "NEW: THE SOCKET BAYONET. Research it at the Armoury: the bayonet hits harder and quicker, and the musket can still fire with it fixed. On the town's stairs, where the fighting is close, it decides the night.",
    "armour": "NEW: ARMOUR. The army of Brazil wears it: your Guardsmen are Musketeers in breastplates, your Cuirassiers Horsemen in cuirasses. They take more before they fall and walk a little slower. The fort's Barracks trains them armoured; its Armoury refits a plain man.",
    "balloon": "NEW: THE OBSERVATION BALLOON. Father Inácio's: it flies over the forest and sees 14 tiles round it, so your Field Cannons can fire as far as they reach at what it sees. Here the land under the canopy stays dark until a balloon has flown over it. The Foundry at Óbidos builds more; it can also carry four men over the flood.",
    "mist_toad": "NEW: THE MIST TOAD. Laid by a Mother grown to her third stage with the Venom Sire rooted beside her: a slow swamp caster. Its TONGUE drags one enemy to its feet; its spells need research.",
    "nb_fog": "NEW: FOG BANK. Research it on the Venom Sire's card: a Mist Toad lays a fog bank where shots fired from or into it miss half the time. Lay it over your Mothers when the guns come.",
    "nb_miasma": "NEW: MIASMA. Research it on the Venom Sire's card: a Mist Toad lays a green cloud in which the Brood heal. Lay it where your creatures fight.",
    "charges": "NEW: PREPARED CHARGES. Research it at the camp's Armoury (it needs the Foundry): the powder comes in ready-made bags, and every Field Cannon and Mortar reloads a fifth faster. Against plates that must be hit again and again, it is the guns' science.",
    "quadrant": "NEW: THE GUNNER'S QUADRANT. Research it at the Armoury after Prepared Charges: the guns are laid by the quadrant, and every Field Cannon and Mortar reaches a tile farther, from behind the earthworks to the gates.",
    "ballista": "NEW: THE SPRING BALLISTA. Made at the arsenal's Heavy Works: a bolt thrower on cog wheels whose screw goes through its target into the men behind. Hard on guns and earthworks; it cannot shoot what is close or in the air.",
    "long_chain": "NEW: LONG CHAIN. Research it at the arsenal's Escapement: every Netter throws its net much farther, from behind the Clock Soldiers onto the gunners.",
    "powder_wagon": "NEW: THE POWDER WAGON. There is no Mill on the road: the wagons carry the army's powder. Musketeers and guns within 3 tiles of one refill from it, so keep it just behind the line, and guard it: it blows up when it is destroyed. It fills again at a Barracks; the fort's Foundry builds more.",
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
    "ratchet_turret": "NOVO: A TORRETA DE CATRACA. Um canhão de parafusos que fica parado e atira contra terra e ar. Tem de estar ligado a um campo de engrenagens: no cais um Enrolador constrói uma junto ao relógio de viagem, a última defesa da retaguarda.",
    "shield_wall": "NOVO: MURALHA DE ESCUDOS. Os seus Soldados-Relógio foram treinados nela: aperte ESCUDO À FRENTE no painel deles e eles andam mais devagar mas sofrem metade dos tiros pela frente. Erga-a de frente para os mosquetes.",
    "stage2": "NOVO: CRESCER. Enraizada, a Mãe cresce ao seu segundo estágio: mais ovos, e os jovens podem AMADURECER.",
    "stage3": "NOVO: CRESCER AO TERCEIRO ESTÁGIO. Enraizada, a Mãe cresce mais uma vez: mais ovos, postura mais rápida, e os ovos do Brutamontes. Leva um minuto e ela tem de ficar enraizada.",
    "brute": "NOVO: O BRUTAMONTES. Posto pela Mãe no seu terceiro estágio com o Sire Tirano enraizado ao lado: uma enorme besta com chifres que derruba paliçadas e portões.",
    "tyrant_challenger": "NOVO: AMADURECER. Um Raptor crescido muda de pele e vira um Desafiante Tirano; um Cuspidor crescido, um Desafiante Venenoso.",
    "church": "NOVO: A IGREJA. As igrejas de Roma treinam Missionários.",
    "missionary": "NOVO: O MISSIONÁRIO. Traz de volta os caídos e guia o povo onde um soldado não consegue.",
    "spitter": "NOVO: OS CUSPIDORES. Dois por ovo, fecundados pelo Sire do Veneno: ácido por trás dos Raptores, contra terra e ar.",
    "pterodactyl": "NOVO: O SIRE DA TEMPESTADE. Um pai que voa: de pé, voa e mergulha para morder; ENRAIZADO junto à Mãe, pousa, e ela põe os ovos da linhagem dele.",
    "hatchlings": "NOVO: OS FILHOTES. Escolha-os no painel da Mãe enquanto o Sire da Tempestade estiver enraizado junto a ela: pequenos voadores, dois por ovo. Só mordem voadores, mas veem longe por cima da floresta.",
    "cuckoo_house": "NOVO: A CASA DO CUCO. Um relógio alto com portinhas: os pássaros das máquinas voam dele. Precisa de um Escape a trabalhar, e funciona com Tensão: uma Mola Real no seu campo de engrenagens.",
    "cuckoo": "NOVO: O CUCO. Um pássaro de latão rápido feito na Casa do Cuco. Só luta contra outros voadores, mas vê longe: aqui a terra fora do planalto fica escura até um Cuco voar sobre ela.",
    "owl_morph": "NOVO: A CORUJA TIQUE-TAQUE. Pesquise-a na Casa do Cuco, depois escolha um Cuco e aperte VIRAR CORUJA: uma coruja pesada de latão que vê longe no escuro, ataca as máquinas e deixa cair o seu peso sobre os edifícios. Não acerta em voadores.",
    "high_leap": "NOVO: PULO ALTO. Pesquise-o no Escape: os seus Saltadores podem SALTAR PARA CIMA para terreno alto também, uma falésia incluída, onde quer que um dos seus (uma coruja por cima) veja o topo.",
    "armoury": "NOVO: O ARSENAL. O da guarnição, na cidade baixa: pesquisa mosquetes e baionetas melhores para os Mosqueteiros. Escolha-o para ver o que ensina.",
    "matchlock": "NOVO: A MECHA. Pesquise-a no Arsenal: os Mosqueteiros recarregam mais depressa. Os homens que já estão nas fileiras recebem-na ao serem reequipados: ligue AUTO-REEQUIPAR no Arsenal e os homens parados perto dele vão ser equipados.",
    "dragoon": "NOVO: O DRAGÃO. Um Mosqueteiro a cavalo: corre depressa pelos trilhos e dispara a pé. O socorro traz quatro; o Quartel do forte do rio treina mais junto ao seu Criador de Cavalos.",
    "charge": "NOVO: A CARGA DE CAVALARIA. Treine-a num Criador de Cavalos: o primeiro golpe de um Cavaleiro depois de um galope fere mais do dobro nas criaturas leves, e atira-as para trás.",
    "nb_clutch_raptor": "NOVO: NINHADA MAIOR. Pesquise-a no painel do Sire Tirano: os Raptores nascem três por ovo em vez de dois (o ovo custa mais, cada Raptor o mesmo). Mais dentes nos baixios.",
    "nb_pack_hunt": "NOVO: CAÇA EM BANDO. Pesquise-a no painel do Sire Tirano: os Raptores, os Desafiantes Tiranos e o Sire correm mais depressa; um Raptor passa então um cavalo. Apanhe a gente antes das canoas.",
    "nb_quick_roots": "NOVO: RAÍZES RÁPIDAS. Pesquise-as no painel de uma Mãe: todas as criaturas enraízam e desenraízam na metade do tempo. Uma Mãe avançada desce a margem e já está enraizada de novo antes que os canhões a encontrem.",
    "bayonet": "NOVO: A BAIONETA DE ENCAIXE. Pesquise-a no Arsenal: a baioneta fere mais forte e mais depressa, e o mosquete ainda dispara com ela calada. Nas escadas da vila, onde a luta é de perto, ela decide a noite.",
    "armour": "NOVO: A ARMADURA. O exército do Brasil usa-a: os seus Guardas são Mosqueteiros de couraça, os seus Couraceiros Cavaleiros de couraça. Aguentam mais antes de cair e andam um pouco mais devagar. O Quartel do forte treina-os com armadura; o seu Arsenal equipa um homem simples.",
    "balloon": "NOVO: O BALÃO DE OBSERVAÇÃO. O do Padre Inácio: voa sobre a floresta e vê 14 casas à sua volta, por isso os seus Canhões de Campanha podem atirar tão longe quanto alcançam ao que ele vê. Aqui a terra debaixo da copa fica escura até um balão voar sobre ela. A Fundição de Óbidos faz mais; também pode levar quatro homens por cima da cheia.",
    "mist_toad": "NOVO: O SAPO DA NÉVOA. Posto por uma Mãe crescida ao terceiro estágio com o Sire do Veneno enraizado ao lado: um lançador lento do pântano. A sua LÍNGUA arrasta um inimigo até aos seus pés; os seus feitiços precisam de pesquisa.",
    "nb_fog": "NOVO: BANCO DE NÉVOA. Pesquise-o no painel do Sire do Veneno: um Sapo da Névoa põe um banco de névoa onde os tiros disparados de dentro ou para dentro falham metade das vezes. Ponha-o sobre as suas Mães quando os canhões vierem.",
    "nb_miasma": "NOVO: MIASMA. Pesquise-o no painel do Sire do Veneno: um Sapo da Névoa põe uma nuvem verde onde a Ninhada se cura. Ponha-a onde as suas criaturas lutam.",
    "charges": "NOVO: CARGAS PREPARADAS. Pesquise-as no Arsenal do acampamento (precisa da Fundição): a pólvora vem em sacos já feitos, e cada Canhão de Campanha e Morteiro recarrega um quinto mais depressa. Contra placas que têm de ser atingidas uma e outra vez, é a ciência dos canhões.",
    "quadrant": "NOVO: O QUADRANTE DO ARTILHEIRO. Pesquise-o no Arsenal depois das Cargas Preparadas: os canhões são apontados pelo quadrante, e cada Canhão de Campanha e Morteiro alcança uma casa mais longe, de trás das trincheiras até aos portões.",
    "ballista": "NOVO: A BALESTRA DE MOLA. Feita na Oficina Pesada do arsenal: um lança-virotes sobre rodas dentadas cujo parafuso atravessa o alvo e entra nos homens atrás. Duro contra canhões e trincheiras; não atira ao que está perto nem no ar.",
    "long_chain": "NOVO: CORRENTE LONGA. Pesquise-a no Escape do arsenal: cada Lança-Redes atira a rede muito mais longe, de trás dos Soldados-Relógio para cima dos artilheiros.",
    "powder_wagon": "NOVO: A CARROÇA DE PÓLVORA. Não há Moinho na estrada: as carroças levam a pólvora do exército. Mosqueteiros e canhões a 3 casas de uma recarregam dela, por isso mantenha-a logo atrás da linha, e guarde-a: explode quando é destruída. Enche-se outra vez num Quartel; a Fundição do forte faz mais.",
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
    "ratchet_turret": "NUEVO: LA TORRETA DE TRINQUETE. Un cañón de tornillos que se queda quieto y dispara contra tierra y aire. Debe estar unido a un campo de engranajes: en el embarcadero un Dador de cuerda construye una junto al reloj de viaje, la última defensa de la retaguardia.",
    "shield_wall": "NUEVO: MURO DE ESCUDOS. Tus Soldados Reloj están entrenados en él: pulsa ESCUDO AL FRENTE en su panel y caminan más despacio pero reciben la mitad de los disparos de frente. Álzalo de cara a los mosquetes.",
    "stage2": "NUEVO: CRECER. Enraizada, la Madre crece a su segunda etapa: más huevos, y los jóvenes pueden MADURAR.",
    "stage3": "NUEVO: CRECER A LA TERCERA ETAPA. Enraizada, la Madre crece una vez más: más huevos, puesta más rápida, y los huevos del Bruto. Lleva un minuto y debe seguir enraizada.",
    "brute": "NUEVO: EL BRUTO. Lo pone la Madre en su tercera etapa con el Señor Tirano enraizado a su lado: una enorme bestia con cuernos que derriba empalizadas y portones.",
    "tyrant_challenger": "NUEVO: MADURAR. Un Raptor crecido muda la piel y se vuelve un Retador Tirano; un Escupidor crecido, un Retador Venenoso.",
    "church": "NUEVO: LA IGLESIA. Las iglesias de Roma entrenan Misioneros.",
    "missionary": "NUEVO: EL MISIONERO. Trae de vuelta a los caídos y guía al pueblo donde un soldado no puede.",
    "spitter": "NUEVO: LOS ESCUPIDORES. Dos por huevo, fecundados por el Señor del Veneno: ácido desde detrás de los Raptores, contra tierra y aire.",
    "pterodactyl": "NUEVO: EL SEÑOR DE LA TORMENTA. Un padre que vuela: en pie, vuela y se lanza a morder; ENRAIZADO junto a la Madre, se posa, y ella pone los huevos de su línea.",
    "hatchlings": "NUEVO: LAS CRÍAS. Elígelas en el panel de la Madre mientras el Señor de la Tormenta esté enraizado junto a ella: pequeños voladores, dos por huevo. Solo muerden voladores, pero ven lejos por encima del bosque.",
    "cuckoo_house": "NUEVO: LA CASA DEL CUCO. Un reloj alto con puertecitas: los pájaros de las máquinas vuelan desde él. Necesita un Escape en marcha, y funciona con Tensión: un Muelle Real en su campo de engranajes.",
    "cuckoo": "NUEVO: EL CUCO. Un pájaro de latón rápido hecho en la Casa del Cuco. Solo lucha contra otros voladores, pero ve lejos: aquí la tierra fuera del altiplano sigue oscura hasta que un Cuco vuela sobre ella.",
    "owl_morph": "NUEVO: EL BÚHO TICTAC. Investígalo en la Casa del Cuco, luego elige un Cuco y pulsa CONVERTIR EN BÚHO: un pesado búho de latón que ve lejos en la oscuridad, se lanza sobre las máquinas y deja caer su peso sobre los edificios. No alcanza a los voladores.",
    "high_leap": "NUEVO: SALTO ALTO. Investígalo en el Escape: tus Saltadores pueden SALTAR ARRIBA al terreno alto también, un acantilado incluido, dondequiera que uno de los tuyos (un búho encima) vea la cima.",
    "armoury": "NUEVO: LA ARMERÍA. La de la guarnición, en la ciudad baja: investiga mosquetes y bayonetas mejores para los Mosqueteros. Elígela para ver lo que enseña.",
    "matchlock": "NUEVO: LA MECHA. Investígala en la Armería: los Mosqueteros recargan más deprisa. Los hombres que ya están en las filas la reciben al reequiparse: activa AUTOEQUIPAR en la Armería y los hombres ociosos cerca de ella van a equiparse.",
    "dragoon": "NUEVO: EL DRAGÓN. Un Mosquetero a caballo: corre deprisa por las sendas y dispara a pie. El socorro trae cuatro; el Cuartel del fuerte del río entrena más junto a su Criadero de Caballos.",
    "charge": "NUEVO: LA CARGA DE CABALLERÍA. Entrénala en un Criadero de Caballos: el primer golpe de un Jinete tras un galope hiere más del doble a las criaturas ligeras, y las echa atrás.",
    "nb_clutch_raptor": "NUEVO: NIDADA MAYOR. Investígala en el panel del Señor Tirano: los Raptores nacen tres por huevo en vez de dos (el huevo cuesta más, cada Raptor lo mismo). Más dientes en los bajíos.",
    "nb_pack_hunt": "NUEVO: CAZA EN MANADA. Investígala en el panel del Señor Tirano: los Raptores, los Retadores Tiranos y el Señor corren más deprisa; un Raptor entonces deja atrás a un caballo. Atrapa a la gente antes de las canoas.",
    "nb_quick_roots": "NUEVO: RAÍCES RÁPIDAS. Investígalas en el panel de una Madre: todas las criaturas enraízan y desenraízan en la mitad de tiempo. Una Madre de avanzada baja por la orilla y vuelve a estar enraizada antes de que los cañones la encuentren.",
    "bayonet": "NUEVO: LA BAYONETA DE CUBO. Investígala en la Armería: la bayoneta hiere más fuerte y más deprisa, y el mosquete aún dispara con ella calada. En las escaleras del pueblo, donde se lucha de cerca, decide la noche.",
    "armour": "NUEVO: LA ARMADURA. El ejército de Brasil la lleva: tus Guardias son Mosqueteros con coraza, tus Coraceros Jinetes con coraza. Aguantan más antes de caer y andan un poco más despacio. El Cuartel del fuerte los entrena con armadura; su Armería equipa a un hombre sencillo.",
    "balloon": "NUEVO: EL GLOBO DE OBSERVACIÓN. El del Padre Inácio: vuela sobre la selva y ve 14 casillas a su alrededor, así que tus Cañones de Campaña pueden disparar tan lejos como alcanzan a lo que él ve. Aquí la tierra bajo la copa sigue oscura hasta que un globo vuela sobre ella. La Fundición de Óbidos hace más; también puede llevar a cuatro hombres por encima de la crecida.",
    "mist_toad": "NUEVO: EL SAPO DE NIEBLA. Lo pone una Madre crecida a su tercera etapa con el Señor del Veneno enraizado a su lado: un lanzador lento del pantano. Su LENGUA arrastra a un enemigo hasta sus pies; sus hechizos necesitan investigación.",
    "nb_fog": "NUEVO: BANCO DE NIEBLA. Investígalo en el panel del Señor del Veneno: un Sapo de Niebla pone un banco de niebla donde los disparos hechos desde dentro o hacia dentro fallan la mitad de las veces. Ponlo sobre tus Madres cuando vengan los cañones.",
    "nb_miasma": "NUEVO: MIASMA. Investígalo en el panel del Señor del Veneno: un Sapo de Niebla pone una nube verde donde la Prole se cura. Ponla donde luchan tus criaturas.",
    "charges": "NUEVO: CARGAS PREPARADAS. Investígalas en la Armería del campamento (necesita la Fundición): la pólvora viene en saquitos ya hechos, y cada Cañón de Campaña y Mortero recarga una quinta parte más rápido. Contra placas que hay que golpear una y otra vez, es la ciencia de los cañones.",
    "quadrant": "NUEVO: EL CUADRANTE DEL ARTILLERO. Investígalo en la Armería después de las Cargas Preparadas: los cañones se apuntan con el cuadrante, y cada Cañón de Campaña y Mortero alcanza una casilla más lejos, desde detrás de las trincheras hasta las puertas.",
    "ballista": "NUEVO: LA BALLESTA DE MUELLE. Hecha en el Taller Pesado del arsenal: un lanzavirotes sobre ruedas dentadas cuyo tornillo atraviesa el blanco y entra en los hombres de detrás. Duro contra cañones y trincheras; no dispara a lo que está cerca ni en el aire.",
    "long_chain": "NUEVO: CADENA LARGA. Investígala en el Escape del arsenal: cada Lanzarredes lanza su red mucho más lejos, desde detrás de los Soldados Reloj sobre los artilleros.",
    "powder_wagon": "NUEVO: EL CARRO DE PÓLVORA. No hay Molino en el camino: los carros llevan la pólvora del ejército. Mosqueteros y cañones a 3 casillas de uno recargan de él, así que mantenlo justo detrás de la línea, y guárdalo: estalla cuando lo destruyen. Se llena otra vez en un Cuartel; la Fundición del fuerte hace más.",
}

# When the card is said (seconds into the match) and to which side, per mission.
CARD_AT = {"p01_leaf": 5, "c01_thirteenth": 5, "b01_specimen": 5, "a02_furth": 5, "a03_plateau": 5, "a01_presses": 5, "a06_barricades": 5, "a04_visit": 8, "a05_specimens": 8, "a07_council": 8, "d02_exodus": 8, "d03_fazenda": 8, "d04_concordia": 8, "d01_minas": 8, "d06_queen": 8, "d05_aldeia": 8, "d08_rivers": 8, "d07_spring": 8, "d09_crossroads": 8, "d10_jungle": 8, "d11_siege": 8}
SIDE = {"p01_leaf": "crown", "c01_thirteenth": "guild", "b01_specimen": "sire", "a02_furth": "guild", "a03_plateau": "nest", "a01_presses": "crown", "a06_barricades": "crown", "a04_visit": "visit", "a05_specimens": "creatures", "a07_council": "crown", "d02_exodus": "exodus", "d03_fazenda": "stock", "d04_concordia": "guild", "d01_minas": "crown", "d06_queen": "brood", "d05_aldeia": "crown", "d08_rivers": "swarm", "d07_spring": "guild", "d09_crossroads": "crown", "d10_jungle": "column", "d11_siege": "crown"}


def step_of(mission_id, faction=None):
    for fac, steps in LADDER.items():
        if faction and fac != faction:
            continue
        for i, st in enumerate(steps):
            if st[1] == mission_id:
                return fac, i
    raise KeyError(mission_id)


# THE LADDER IN ANY ORDER (act3-engine0; docs/campaign_act3_plan.md, Claude's choice 6): Act 3's theatres are free, so a
# line's Act 3 rungs come in any order. From this step on (its index in the line), a mission's allow-list is the line's
# whole Act 2 kit + its OWN rung; every other Act 3 rung of the line rides on the roster as "if_won": {mission: pieces}
# and joins the kit in the game once that mission is won (Campaign.roster_denied).
ANY_ORDER = {"crown": "C10", "clockwork": "K8", "brood": "B8"}


def any_from(faction):
    """The index of the line's first any-order step (len(steps) when none)."""
    steps = LADDER[faction]
    for i, st in enumerate(steps):
        if st[0] == ANY_ORDER.get(faction):
            return i
    return len(steps)


def allow_of(faction, upto):
    """The allow-list at step index `upto` (inclusive): the kit, then every step's pieces in order (an any-order step:
    the kit, every step before the first any-order one, then its own)."""
    out = list(KIT[faction])
    a = any_from(faction)
    steps = LADDER[faction][: upto + 1] if upto < a else LADDER[faction][:a] + [LADDER[faction][upto]]
    for st in steps:
        for k in st[2] + st[3]:
            if k not in out:
                out.append(k)
    return out


def if_won_of(faction, upto):
    """An any-order step's other Act 3 rungs: {mission: [pieces]} ({} before the any-order steps)."""
    a = any_from(faction)
    if upto < a:
        return {}
    out = {}
    for i, st in enumerate(LADDER[faction][a:], a):
        if i != upto and st[1]:
            out[st[1]] = list(st[2] + st[3])
    return out


NEW_NAME = "NEW IN YOUR ARMY"
_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ICON = {c: "res://assets/icons/%s.png" % c for c in CARDS
        if os.path.exists(os.path.join(_ROOT, "assets", "icons", c + ".png"))}


def roster_of(mission_id, faction=None):
    fac, i = step_of(mission_id, faction)
    r = {"allow": allow_of(fac, i), "new": list(LADDER[fac][i][2])}
    iw = if_won_of(fac, i)
    if iw:
        r["if_won"] = iw
    return r


def apply(M, mission_id, story_deny=None, at=None, faction=None):
    """Sets the bound teams' roster (the ladder's allow-list, its NEW pieces, the story's own deny on top) and adds the
    NEW card: a speaker "new", a line per new piece, a trigger "ladder_new" that says them, to the ladder side only.
    `faction`: a mission's SECOND ladder (EXTRA_BOUND: d10's swarm): its own speaker "new_<faction>" and trigger."""
    fac, i = step_of(mission_id, faction)
    r = roster_of(mission_id, faction)
    extra = faction is not None and faction != BOUND[mission_id][0]
    teams = EXTRA_BOUND[mission_id][faction] if extra else BOUND[mission_id][1]
    for tm in M["teams"]:
        if tm["id"] in teams:
            ros = {"allow": list(r["allow"]), "new": list(r["new"])}
            if r.get("if_won"):
                ros["if_won"] = {k: list(v) for k, v in r["if_won"].items()}
            deny = (story_deny or {}).get(tm["id"], [])
            if deny:
                ros["deny"] = list(deny)
            tm["roster"] = ros
    side = EXTRA_SIDE[mission_id][faction] if extra else SIDE[mission_id]
    who = "new_" + faction if extra else "new"
    trig = "ladder_new_" + faction if extra else "ladder_new"
    ids = []
    for k in r["new"]:
        card = SHARED_CARD.get(k, k)
        lid = "new_" + card
        if lid in ids:
            continue
        M["lines"][lid] = {"who": who, "to": side, "text": CARDS[card]}
        if card in ICON:      # the dialogue box's face: the new piece's own icon (0.38.162, the owner: "what is this NEW?")
            M["lines"][lid]["portrait"] = ICON[card]
        ids.append(lid)
    M["speakers"][who] = {"name": NEW_NAME, "side": side}
    M["triggers"] = [t for t in M["triggers"] if t["id"] != trig]
    M["triggers"].append({"id": trig, "when": {"time": at if at is not None else CARD_AT.get(mission_id, 5)},
                          "do": [{"say": ids}]})
    return M


def table():
    """The CHECKED TABLE (docs/campaign_roster_ladder.md): one row per step, the code ids."""
    rows = ["| step | mission | teams | new | comes with | allow-list (code ids) |", "| --- | --- | --- | --- | --- | --- |"]
    for fac, steps in LADDER.items():
        for i, st in enumerate(steps):
            teams = " ".join(BOUND[st[1]][1]) if st[1] in BOUND and BOUND[st[1]][0] == fac else \
                (" ".join(EXTRA_BOUND[st[1]][fac]) if fac in EXTRA_BOUND.get(st[1], {}) else "-")
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
