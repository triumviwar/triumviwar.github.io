# Act 2, "The Island": what was built (job d03-fazenda)

Act 2 step 3 (docs/campaign_act2_plan.md "d03_fazenda"): the Naturalist line's first Act 2 mission, after Rome. The dry
season of 2772, two years after the Council: Lindqvist walked out of Rome with the creatures it ordered destroyed and
breeds them in secret on a fazenda on a river island below Óbidos (proposed). The Crown's commission comes up the river
with Rome's order: Valadares and a magistrate, Desembargador Fonseca (proposed). A hide and seek, played as THE STOCK (the
Brood) by default; the solo pick and versus play the commission. EVERY LINE OF TEXT IS A PLACEHOLDER for the owner.

## Files

| what | where |
| --- | --- |
| the map | `campaign/maps/obidos_island.json`, written by `tools/campaign/make_obidos_island_map.py` (`--ascii` prints it) |
| the mission | `campaign/missions/d03_fazenda.json`, written by `tools/campaign/make_d03_mission.py` (edit the script, run it) |
| the stills (stand-ins) | `campaign/stills/d03_01.jpg` .. `d03_04.jpg`, drawn by `tools/campaign/make_d03_stills.py` |
| texts pt / es | `tools/i18n/campaign/d03_fazenda.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storyline, the hubs | `campaign/campaign.json`: d03 joins the Naturalist line after a05 (it needs a07: Rome); a new hub after d03 for the stock, THE FAZENDA'S STUDY (the station painting tinted); Lindqvist's talks after d03 (by side and `hidden`). `campaign/hubs_grow.json`: Pieter (the stud book), Benedito (he paddled the commission), Valadares and the cages after d03 |
| the war map | `campaign/warmap.json`: d03's pin ("The island", the dry season 2772, after a07), a fazenda mark on the Amazon, the rules (below) |
| the roster ladder | `tools/campaign/roster_ladder.py`: B4 = d03 (THE STORM SIRE + HATCHLINGS), bound team `stock`, NEW cards at 8 s, side `stock`, the cards in pt / es |
| the roles | `scripts/campaign/rebels.gd`: young_mother (a Brood Mother at 0.42, Linnea's art), keeper (a hired gun), assembly_keeper (a militiaman), fonseca (a dismounted man in black) |
| the engine | `scripts/campaign/mission_act2.gd` (hide `still`, lies_low, brood_stage, retag, the newest leash rules, tracks' first look, hidden seen under the mist, a renamed leash keeps its loose ones), `mission_run.gd` (counter `sub_counter` / `share_of`), `campaign.gd`; docs/campaign_engine.md "Added by Act 2's d03_fazenda" |
| tests | `tools/test_campaign_d03.gd` (`godot --headless --path . --script res://tools/test_campaign_d03.gd [-- only=part2,part3]`); d03 added to `tools/test_campaign_save.gd` and `.sh` |
| the balance sim | `tools/sim_campaign_d03.gd` (`-- active [diff=] [side=commission] [clutch=burned] [eggs=taken] [cages=few/all] [pieter=lost] [map=withheld] [varenne=executed] [lazy] [shots=dir]`) |
| voices | docs/chatterbox_todo.md "d03_fazenda" (60 lines with their feeling); tools/voice_clone/emotions.json `d03__<id>` |

## The map: the island below Óbidos (120 x 84, jungle, the dry season)

An egg-shaped island in a low brown river, sandbanks out in the stream (ford art nobody can reach). South: THE LANDING (a
sand beach, the commission's canoes), the big house on a low rise with the sugar fields round it (open ground), the mill
and THE OLD PENS by it (where the stock starts: too near the house to hide). Across the middle THE CREEK cuts the island in
two from the west bank to the east, with three fords. North of it THE DEEP FOREST with six clearings (pens 1-5 and the
NEST clearing in the middle) on narrow paths. South-west and south-east two more clearings in lighter forest, and east
THE BURNT CHAPEL of the old Jesuit mission (proposed); THE WEST POINT and the chapel are the two decoy spots.

## How it plays: THE STOCK (the Brood; solo)

Lindqvist's people are ON THE STOCK'S TEAM (Claude's choice 1): Lindqvist, Pieter (by the flags), two keepers. They carry
the LURES. THE LEASH: the creatures obey only within 8 tiles of a lure; out of every lure's reach one is LOOSE and wanders.

- PART 1, THE BOAT ON THE RIVER (3:30 on NORMAL; EASY x1.25, HARD x0.85): walk the stock out of the old pens, over the
  creek and up into the deep forest, each group under a keeper; root the young Mother in the nest clearing. At 0:45 the
  big egg hatches: THE STORM SIRE (B4). Root him beside her and lay HATCHLINGS on her card: little flyers that watch the
  river (they are birds to the commission: spared). Pieter's tips say where to go. Everything hidden and the Mother
  rooted: the canoes land at once (NO WAITING).
- PART 2, THE SEARCH (4:30, 5:30 with a03 `map` withheld): the commission lands: three search parties of musketeers on
  routes, the riders, Valadares with two guards. THE QUIET RULE: the stock bites nobody, the fazenda's people fire no shot
  and are not shot. HIDDEN: a creature still for 3 s LIES LOW and is found only from 2 tiles; a moving one is seen as far
  as a searcher sees (the island's forest shade: 0.6 of his sight). Found is for good, and a found creature is shot.
  Valadares follows fresh TRACKS; the parties follow tracks from 1:30; the riders cross the west ford at 2:00; at 3:35
  Valadares has a hunch and walks the middle. THE DINNER (from 0:24): Lindqvist at the big house's door 5 s sends the
  magistrate and his party to dine for 1:30. A DECOY (from 0:45): a keeper at the west point or the chapel 4 s sets a
  lure post; the nearest party goes to look at it. A party near a pen with the stock in it: pinged and said. Three
  quarters found: Rome's order is carried out: LOST.
- PART 3, THE LAST NIGHT (2:00): the commission camps at the landing, the goats penned by the boats. At 0:12 one young
  creature (the first raptor-like one with no lure within 4 tiles) gets up and goes for the goats. For 8 s no lure holds
  it (it slips its keeper), then only a lure within 3 tiles. Held, walk it back into the deep forest: the night is over
  and dawn comes 1:20 sooner. If it reaches the goats, or a sentry shoots it on its way: the camp is up with torches and
  everything is found: LOST. Dawn: the commission walks to its canoes: WON.

Lindqvist is a hero (protect): wounded, not killed (MissionHeroes); his capture is not in this mission.

## How it plays: THE COMMISSION (the solo mirror, or versus)

The stock is scripted: each young one ASLEEP in a deep pen (it wakes and fights when a searcher comes within 3 tiles),
the Storm Sire and two wanderers loose. The commission (three parties, the riders, Valadares, Fonseca) has until dawn
(the search + the night) to FIND AND DESTROY HALF the stock without losing Valadares. Fonseca dines all the same at 1:00.
A win sets `hidden` by the share never found (few, or some at exactly half: Valadares found some, canon-compatible, the plan's choice 5); at dawn without it the flags are set as on the stock's side (some or all).

## The flags read and set

Read (missing = the canon):

| flag | effect here |
| --- | --- |
| b01 `clutch` saved / burned | the young Mother is Linnea's daughter / one netted on the plateau (flag `mother` linnea / plateau; Lindqvist's opening line) |
| b01 `eggs` taken | two Raptors more in the old pens |
| a05 `cages` few / some / all | 3 / 5 / 7 young (all: THE YOUNG SIRE, a tyrannosaur, and a Venom Challenger) |
| b01 / a05 `pieter` lost | no Pieter: two keepers carry the lures (a narrator line); flag `pieter` lost |
| a03 `map` drawn / withheld | Valadares knows the prints (his line) / he searches blind: Part 2 a minute longer, his own line |
| a06 `varenne` executed | the keepers are Assembly men (assembly_keeper, a narrator line) |
| a07 `lindqvist` defied | the opening assumes it (he always defied in a07) |

Set: `hidden` few / some / all (the share of the young never found: all = none found, some = at least half, few = less),
`hidden_n` (the count), `storm` hatched, `mother` linnea / plateau, `pieter` alive / lost, `dinner` given. Internal flags
the mission keeps for itself: `found_share`, `found_share_n`, `c_half`.

THE WAR MAP (rules after d03): a fazenda mark and the ledger "Lindqvist breeds the specimens on an island below Óbidos,
against Rome's verdict" when the stock won; a ledger line per `hidden` (all / some / few), "Young never found on the
island: %s", "A Storm Sire hatched on the island", and on a commission win "Valadares burned the pens he found". Not a
broken seal: either way is canon-compatible.

THE HUBS: after d03 the stock's player is in THE FAZENDA'S STUDY (the station painting tinted). Lindqvist talks of the
Storm Sire and "made, not born" (his error, the lore's mirror of Hollweg's); with `hidden` few, of what was burned; on the
commission's side, "Valadares found half". Pieter keeps the stud book, Benedito paddled the commission, Valadares and the
cages get a line each (hubs_grow.json).

## The engine (docs/campaign_engine.md "Added by Act 2's d03_fazenda")

HIDE's `still` (lying low), `lies_low`, the hidden seen under the mission's mist, `brood_stage`, `retag`, counters
`sub_counter` / `share_of`, the newest leash rules a unit on two, a leash given again keeps its loose ones loose, and the
tracks' first look prints nothing (before, every unit left a "track" at its start: Valadares walked straight to the old
pens).

## Balance (tools/sim_campaign_d03.gd; the last runs)

| run (NORMAL unless named; canon flags unless named) | winner | young | found | `hidden` | the end | longest idle |
| --- | --- | --- | --- | --- | --- | --- |
| active | the stock | 6 | 2 | some | 6:49 | 28 s |
| active EASY | the stock | 6 | 1 | some | 6:47 | 28 s |
| active HARD | the stock | 6 | 2 | some | 6:48 | 28 s |
| active, a03 `map` withheld (a longer search) | the stock | 6 | 2 | some | 7:48 | 29 s |
| active, a05 `cages` few | the stock | 4 | 2 | some | 6:48 | 28 s |
| active, a05 `cages` all (the young Sire) | the stock | 8 | 3 | some | 7:11 | 36 s |
| active, b01 `eggs` taken | the stock | 8 | 3 | some | 7:11 | 33 s |
| active, b01 `clutch` burned (`mother` plateau) | the stock | 6 | 2 | some | 6:49 | 28 s |
| active, `pieter` lost | the stock | 6 | 1 | some | 6:46 | 37 s |
| active, a06 `varenne` executed | the stock | 6 | 2 | some | 7:11 | 34 s |
| lazy (leaves the restless one be) | the commission (the night lost) | 6 | 2 | - | 7:11 | 63 s |
| passive (does nothing) | the commission (found in the old pens) | 6 | 6 | - | 3:46 | 113 s |
| the commission, active | the commission | 6 | 5 (5 destroyed) | few | 1:04 | 12 s |
| the commission, passive | the stock | 6 | 0 | all | 7:05 | 196 s |

No SCRIPT ERROR in any run. Each run had a user folder of its own (two sims sharing one overwrite each other's
campaign progress: the first batch's flag runs were wrong for that reason).

The bot plays the stock as a careful person would: each keeper leads its share of the young to a pen, Lindqvist takes the
Mother (and then the Storm Sire) to the nest, roots them, lays Hatchlings, gives the dinner, sends Pieter to the chapel,
and fetches the restless one. `lazy` does all that but leaves the restless one alone: it is shot on its way to the goats
and the night is lost. A passive player is found in the old pens soon after the landing (lost at ~3:46). The commission
bot knows where the pens are, so it wins in about a minute; a person playing the commission will take much longer.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

- d03_01 THE ISLAND. "Oil painting, 18th-century history painting style. A wide brown tropical river at the dry season,
  sandbanks showing; on a forested island a white plantation house with a red tile roof and sugar fields, and behind it
  dark forest. Late afternoon light, heat haze. 3:2 landscape, no text." (References: b01_02.jpg, a05_04.jpg.)
- d03_02 THE PENS. "Oil painting, 18th-century history painting style. In a jungle clearing at dusk an elderly
  Scandinavian naturalist in a linen coat holds up a brass lure like a censer; around him young green reptilian
  creatures, sleek and spined, lie in wooden pens; a young assistant writes in a ledger. 3:2 landscape, no text."
  (References: station_lindqvist.png, b01_03.jpg, a05_02.jpg.)
- d03_03 THE COMMISSION. "Oil painting, 18th-century history painting style. Canoes land soldiers in purple coats on a
  sandy river beach; a weathered Portuguese-Brazilian explorer with a map case and a judge in black robes step ashore;
  the plantation house up the slope. Bright morning. 3:2 landscape, no text." (References: a03_04.jpg, b01_02.jpg.)
- d03_04 THE STORM SIRE. "Oil painting, 18th-century history painting style. Over a jungle canopy at dawn a great green
  winged reptile with a crested head flies, small winged hatchlings round it, watching canoes on the river below.
  Mist in the trees. 3:2 landscape, no text." (References: b01_05.jpg, a03_03.jpg.)

The King's pages reuse b01_08 (the King and his prisoner). The commission's opening and ending use d03_03.

## The voice lines

The table is in docs/chatterbox_todo.md ("d03_fazenda"), each line with its feeling; the strongest have a preset in
tools/voice_clone/emotions.json. New voices to design: Desembargador Fonseca (a Portuguese-Brazilian judge, fifties,
pompous and comfortable) and Pieter grown (about thirty). Lindqvist (v2) and the King are designed; Valadares is still
on the list.

## Pictures (docs/shots/d03_fazenda/, CHECK THE FEEL)

SHOTS_NOTE

## What is placeholder

Every line of text (en, pt, es). The four stills. Fonseca and the keepers have no portraits (initials show; Fonseca is a
dismounted man in black, the keepers hired guns). No new sounds.

## Claude's choices for the owner

1. LINDQVIST'S PEOPLE ARE ON THE STOCK'S TEAM (not a yellow scripted ally): the player moves the lures himself; that is
   the whole of the leash lesson. The fazenda's hands and buildings are a scripted yellow team.
2. ALWAYS A YOUNG MOTHER: with b01 `clutch` burned she is a Mother netted on the plateau (flag `mother` plateau), so the
   Storm Sire has someone to root beside in every story.
3. THE STORM SIRE AND HATCHLINGS ARE "BIRDS" to the commission: spared and quiet, never counted as found. Otherwise the
   B4 flyers (the stock's eyes) gave the whole stock away the moment they lifted off.
4. THE QUIET RULE: from the landing the stock bites nobody and Lindqvist's people fire no shot (and are not shot). A
   found creature is still shot by the commission.
5. LYING LOW: still for 3 s = found only within 2 tiles; moving = seen in a searcher's sight, cut to 0.6 by the island's
   shade (the plan said 3 tiles asleep; 2 felt right with the parties walking the paths through the clearings).
6. THREE QUARTERS FOUND = LOST (Rome's order carried out), not "all": with all, the search had no teeth.
7. THE RESTLESS ONE is the first raptor-like young one with no lure within 4 tiles (not the young Mother or the young Sire:
   they root and do not wander); it slips any keeper for 8 s, then only a lure within 3 tiles holds it. Shot on its way =
   the same loss as reaching the goats.
8. NO CO-OP: the stock is one team with one set of lures.
9. VALADARES' HUNTERS COMPANY does not come (the plan's "a dog" is the riders' route instead); the commission is three
   parties of 4 musketeers (EASY 3, HARD 5), 4 riders, Valadares and 2 guards, Fonseca.
10. THE ROUTES AVOID THE NEST clearing and the paths into it: the commission walks the island, Valadares walks to the
    middle only on his hunch (3:35).
11. NO WAITING: Part 1 ends as soon as everything is hidden and the Mother rooted; the riders cross the creek at 2:00, the
    hunch at 3:35, and a held restless one brings dawn 1:20 sooner.
12. THE COMMISSION'S WIN IS CANON-COMPATIBLE (the plan's choice 5): `hidden` few (or some), a war map ledger line, no broken seal.
13. THE DINNER and the DECOYS are side objectives (not needed to win); each is offered once, with a line and a ping.
14. HARD is a bigger search (5 to a party) and a shorter Part 1; the search itself is not scaled (a longer search is no
    kindness).
15. `found_share` / `found_share_n` / `c_half` are flags the mission keeps for itself (saved with the mission; the
    campaign's progress file carries them too).
16. `next` is EMPTY until d06_queen is built; d03 NEEDS a07 (Rome), like d02.
17. The commission's pages: the King (b01_08) then THE COMMISSION (d03_03) to open; d03_03 then the King to close.
18. THE KEEPERS are hired guns (b01's hired_gun art); with a06 `varenne` executed they are Assembly militia (the plan).

## What is left

- The owner's texts, stills and voices.
- d06_queen: then d03's `next` and the stock's flags (`hidden_n`, `mother`, `storm`) used there.
- The commission's bot is crude (it knows the pens); a person playing the commission will take longer.
- The Hatchlings have no job of their own beyond the eyes over the canopy (no alerts when a party comes).

## Tests run

TESTS_RUN
