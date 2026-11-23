# Act 2, "The City of Gears": what was built (job d04-concordia)

Act 2 step 6 (docs/campaign_act2_plan.md "d04_concordia"): the Clockmaker line's second Act 2 mission, after the Exodus.
The southern highlands of Brazil, 2773: the guild has bought a dead mine with the last of its money and founds a city on
it that answers to nobody, CONCÓRDIA. The colonists of the valley below see the old world's ghost come up their road.
Hollweg tells it as a founding; the King frames it ("He named it for concord. The valley named it otherwise."). In the
mine Hollweg opens the two crates of 2767. It is also THE ROSTER LADDER's K5: the guild's new pieces are the CLOCK
AVIARY and the SWIFT (the machines take to the air to map the highlands).

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/d04_concordia.json`, written by `tools/campaign/make_d04_mission.py` (edit the script, run it) |
| the map | `campaign/maps/concordia.json` (`campaign:concordia`, the HIGHLANDS biome), written by `tools/campaign/make_concordia_map.py`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/d04_01.jpg` .. `d04_05.jpg`, drawn by `tools/campaign/make_d04_stills.py` |
| texts pt / es | `tools/i18n/campaign/d04_concordia.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storyline, the hubs | `campaign/campaign.json`: d04 joins the Clockmaker line after d02 (d02's `next` for the guild is d04); the hub after d04 is CONCÓRDIA'S COUNCIL HALL (the guild's side only: the Fürth barn painting re-tinted until its own painting comes); Hollweg's, the clock's and the automaton's talks after d04 (by side). `campaign/hubs_grow.json`: Ulrich's line about the plates |
| the war map | `campaign/warmap.json` already had d04's pin and rules (act2-warmap): won by `guild` / `valley`, `colonists` parley / fought, `crates` opened; they read this mission's ids as they are |
| the roster ladder | `tools/campaign/roster_ladder.py`: K5 = d04 (CLOCK AVIARY + SWIFT), bound team `guild`, NEW cards at 8 s, side `guild`, the cards in pt / es (Casa do Cuco / Casa del Cuco, Cuco: the owner's names); docs/campaign_roster_ladder.md's table rewritten |
| roles | `scripts/campaign/rebels.gd`: `settler`, `varenne_exile`, `morel`, `arruda` (Captain Bento Arruda, a Cuirassier), `valley_militia`, `rancher`, `colonist`, `colonist_torch`, `anselmo` (Padre Anselmo), `crate_soldier` ("Pattern of 2767") |
| the engine | `scripts/campaign/mission_act2.gd` (THE UNMAPPED: `chart` / `charted`; TAKE's `label` / `word` / `untorch`), `mission_run.gd` (torch_fire `counter`, convert `untorch`), `campaign.gd` (their checks); docs/campaign_engine.md "Added by Act 2's d04_concordia" |
| tests | `tools/test_campaign_d04.gd` (`godot --headless --path . --script res://tools/test_campaign_d04.gd`) |
| balance | `tools/sim_campaign_d04.gd` (`-- active [diff=easy|normal|hard] [broken=melted] [varenne=executed] [gate=people] [drawings=taken] [exodus=few|some|many] [saved=few|some|many] [careless] [noparley] [none] [until=s] [save_at=s] [shots=dir] [debug]`) |
| pictures | `docs/shots/d04_concordia/` (the sim's `shots=`, run under xvfb-run) |

## The map: Concórdia and the valley (120 x 96, the highlands)

- THE PLATEAU (north-east, high ground): the old mine and its spoil heaps, the guild's tents, the shaft where the
  Clocktower rises. The Escapement, the Light Works and two Regulators stand at the start (the guild came with them on
  the carts); the sites of the Mainspring, the Cog Press and the Clock Aviary open one after the other. Five plots for
  the first quarter's houses west of the tower (3 by the canon, 2-5 by d02 `exodus` and c01 `saved`).
- THREE WAYS UP: THE CART ROAD (west ramp; the town's road), THE PINE PATH (north-west, out of the araucaria woods) and
  THE RANCH TRACK (south-east ramp, from the cattle ranches). They are what the Swifts must map.
- THE GALLERY: the mine's deepest gallery behind the spoil heaps (far north-east), where the crates lie.
- THE VALLEY (south-west, low ground): the town with its white church, the militia's Barracks and cottages, the river
  with its fords, the ranches and their Horse Breeder (south-east).

## How it plays: THE CITY OF GEARS (the guild; solo, or versus against the valley)

THE GUILD (Clockwork, BLUE): Hollweg (the hero: wounded, not killed), 4 Winders, 6 Clock Soldiers, 2 Springers, 2
Netters, a Pendulum, 600 cogs, SHIELD WALL known (K4). With them the council's secular voice: VARENNE (a06 `varenne`
spared, the canon) or CITIZEN MOREL (executed), a speaker, not a fighter. The families (the settlers in the tents) on
their own team.

1. PART 1, THE FOUNDING. Raise the Clocktower over the shaft (its site is ready; four Winders raise it quickly). The
   Mainspring's site opens, then the Clock Aviary's; the Cog Press is an optional side task (more cogs for soldiers).
   THE UNMAPPED: everything off the plateau is dark to the guild, and anyone walking there is hidden even inside the
   soldiers' sight. Make two Swifts and fly them over the three ways: each way mapped is told; all three bring the
   captain up sooner (Part 1 does not drag). The captain comes up the cart road 3:20 after the tower stands:
   - a04 `broken` MELTED: he waits below the west ramp to PARLEY (1:30): walk Hollweg down to him (the council's voice
     goes with him) and keep them there 3 s. Hollweg promises that no machine will strike a man of the valley; Varenne
     (or Morel, colder) speaks; the captain rides home without a blow (flag `colonists` parley). Missed: the raid.
   - KEPT (the canon): THE FIRST RAID: militia Musketeers up the road and riders down the pine path; on an unmapped way
     Ulrich says he hears horses he cannot see.
   - A guild that never raises its tower: at 5:00 the valley comes anyway (Ulrich says so), and losing the tower site
     loses the mission.
2. PART 2, THE VALLEY'S FEAR (night). Three crowds of townsfolk come up the cart road with torches, 40 s apart (3, 4,
   4 torch-bearers; one more each with a04 kept). They are SPARED: nobody may kill them. TURN THEM BACK: fighters round
   a torch-bearer (no militia by him) for 2 s and he lowers his torch and walks home (the TURNING BACK bar, TURNED
   BACK!). A torch that reaches a house sets it alight; a man of the guild beside a fire puts it out in 6 s, else the
   house burns down in 50 s. THE VALLEY'S TEMPER: every fire adds one, a house burnt down at night two more; at its top
   (EASY 10 / NORMAL 8 / HARD 6) the bells ring in the town and the militia rides at once (Part 3 early, without the
   priest). Hollweg forbids any blow (h_fear); Varenne counsels patience, Morel wants a lesson and Hollweg refuses.
   25 s after the last crowd PADRE ANSELMO comes up the road alone with a lantern and calls his people home: every
   torch goes down. Hollweg writes down what the priest did with one word.
3. PART 3, THE CRATES (dawn). Hollweg goes to the deepest gallery and stays 8 s: the crates of 2767 open: two Clock
   Soldiers "of a pattern I do not remember drawing" (the Pattern of 2767), a Winder, and the PLATES: gear ground that
   creeps out across the floor by itself from the gallery mouth (every 8 s, to 12 tiles: the c01 `gate` pattern; from
   memory every 14 s, to 9) and winds whatever stands on it. Nobody remarks on it but Ulrich, once. 40 s after dawn (or
   soon after the crates) THE DAWN ATTACK: the militia up the cart road, the ranchers up the ranch track, and 20 s later
   more out of the pines (not after a parley: half the valley stayed home). The attack breaks when fewer than 4 are
   left; the city stands. Hollweg closes: "Concord."

Lost: the Clocktower falls, or every house of the first quarter burns. Hollweg hurt falls back to the tower and heals.

## How it plays: THE VALLEY (versus only)

The friend leads Captain Arruda's militia: 4 Musketeers in the town, 3 ranchers, the Barracks and the Horse Breeder,
400 gold and 300 powder. The crowds still go up the road by night whatever he does. He wins by burning the first
quarter, bringing down the tower, or killing Hollweg. The King's ending for the valley: "That is not how it went."
No solo mirror (Claude's choice 3).

## The flags read and set

| flag | effect here |
| --- | --- |
| c01 `gate` pattern (canon) and d02 `drawings` carried | THE PATTERN: the Heavy Works stands at the start; the plates spread fast (every 8 s, to 12 tiles) |
| c01 `gate` people, or d02 `drawings` taken | FROM MEMORY: no Heavy Works and no Pendulum until Part 2, then its site; plates slower (14 s, 9 tiles); the King's ending line "He had left the pattern in Nuremberg. He had already sent it ahead." |
| c01 `saved` many / d02 `exodus` few / many | the first quarter's houses: few 2, canon 3, many 4, +1 with c01 many |
| a04 `broken` melted | the captain PARLEYS; crowds one torch-bearer smaller; the dawn attack smaller, no pine-path party |
| a04 `broken` kept (canon) | the first raid; every crowd one bigger; the full dawn attack |
| a05 `crates` seen | Hollweg's line at the mine (h_crates_seen) is always said here: the plan gives it to "seen"; d04 says it either way (choice 9) |
| a06 `varenne` spared (canon) / executed | Varenne or Citizen Morel as the council's voice: their lines, the opening's ship still for Varenne, the ending |
| SETS `colonists` | parley (the parley done and the city stood) / fought (a raid, a boil-over, or the city lost) |
| SETS `crates` | opened (always, by winning: the crates are opened before the attack is beaten) |

Missing flags take the canon (pattern, some, kept, spared).

## How Hollweg grows in this mission (the owner asked for the existing cast made deeper)

- He arrives a builder again, proud and in a hurry, the Rome verdict worn as a badge ("Rome had said those very words
  were a sin. I said them louder.").
- The Swifts give him THE FLAW in its most attractive form: the whole country under one eye ("From above, every road is
  only a gear's tooth"). The player feels the pleasure of it with him.
- Rome changed him in one real way: he forbids his machines to strike a man of the valley, and means it, against Morel's
  "one lesson tonight" ("I have seen the end of that lesson.").
- The priest does with one word what his shields could not, and he writes it down without understanding it (the King:
  "It took him twenty years to read it."): the first seed of his turning in Act 3.
- The crates: wonder where there should be fear. He calls the Perpetual's plates "my best work" and the plates' creeping
  "a gift". The player sees the gear ground spread; Hollweg does not.
- His last line: "I had learned to hold my machines back from the valley. I had not learned to hold them back from
  themselves." Jakob's absence is felt once ("Jakob would have counted the teeth on those plates.").
- Varenne is the mirror: the old revolutionary is the only one afraid of the free city ("Paris burned keeping time.").

## Balance (tools/sim_campaign_d04.gd; the last runs)

The bot (the guild): Winders build every site (the press too) and put fires out; the Aviary makes two Swifts that fly
the three ways; the Light Works makes Clock Soldiers while there are cogs; Hollweg goes to the parley and the gallery;
the fighters hold the west field inside the tower's gear ring (raid, night, attack), two of them round each
torch-bearer at night; shields up for the attack.

BALANCE_TABLE

The longest idle at NORMAL is about 35 s (NO WAITING: under 45 s). The passive player's idle is long, as it should be.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

- d04_01 THE MINE ON THE HIGHLANDS. "Oil painting, 18th-century history painting style. A high grassy plateau with tall
  umbrella-shaped araucaria pines and red earth; an old mine's spoil heaps; a brass clocktower half raised by tall
  clockwork machines; families in blue coats set up tents. Wide sky, clear light. 3:2 landscape, no text."
  (References: a02_02.jpg, a04_01.jpg.)
- d04_02 THE VALLEY'S FEAR. "Oil painting, 18th-century history painting style. Night on a cart road up a hill; a crowd
  of colonists with torches and farm tools stops before a line of brass automata with shields; a country priest in a
  black cassock stands between them with raised hands. 3:2 landscape, no text." (References: a07_06.jpg, a04_04.jpg.)
- d04_03 THE CRATES. "Oil painting, 18th-century history painting style. In a dark mine gallery lit by a lantern an old
  clockmaker kneels by two opened wooden crates stamped with a gear seal; inside, brass parts gleam; from the crate a
  thin line of gear plates has crept across the rock floor. 3:2 landscape, no text." (References: nuremberg_hollweg.png,
  a05_04.jpg, c01_03.jpg.)
- d04_04 CONCORD. "Oil painting, 18th-century history painting style. A new town of timber and brass on a highland
  plateau at sunset; a clocktower over it; an old clockmaker and a lean man in a sober black coat with a revolutionary's
  cockade (the exile) stand together looking at it. 3:2 landscape, no text." (References: nuremberg_hollweg.png,
  a06_05.jpg for Varenne.)
- d04_05 THE EXILE'S SHIP (new, the opening with Varenne). "Oil painting, 18th-century history painting style. A small
  sailing ship at anchor in a grey southern river mouth; a lean middle-aged man in a sober black coat with a faded
  revolutionary cockade steps down into a rowing boat, a single trunk beside him; on the shore a few men in blue coats
  wait with a cart. Cold light, low hills. 3:2 landscape, no text." (References: a06_05.jpg for Varenne, d02_04.jpg.)

The valley's opening reuses d04_02 and d04_01; its ending d04_02 and a07's Rome still (choice 12).

## The voice lines

The table is in docs/chatterbox_todo.md ("d04_concordia"), with each dramatic line's feeling (74 lines; the narrator's
15 and the two NEW cards can stay as text). New voices to design: Captain Bento Arruda, Padre Anselmo, Citizen Morel.
Ulrich is already on the list from d02.

## Pictures (docs/shots/d04_concordia/, CHECK THE FEEL)

PICTURES_NOTE

## What is placeholder

Every line of text (en, pt, es). The five stills. Arruda, Anselmo, Morel and the crate soldiers wear stand-in art
(a Cuirassier, Frei Joaquim's, a runner's, a Clock Soldier's); no portraits for Ulrich, Arruda, Anselmo or Morel yet
(their initials show). The hub painting (the barn re-tinted). No new sounds.

## Claude's choices for the owner

1. THE TOWNSFOLK ARE SPARED, NOT KILLED: the plan asks to hold the works "without killing the townsfolk (a kill raises
   the anger)". The engine's `spare` makes them unkillable instead, and the anger comes from FIRES: what the valley sees
   from below is the plateau burning. Holding them off is TURN THEM BACK (fighters round a man with a torch), so the
   night is about where you stand, not whom you hit.
2. THE TEMPER'S TOP BY DIFFICULTY: EASY 10, NORMAL 8, HARD 6 fires (a burnt house counts three). Boiled over, the
   militia rides at once and the priest never comes.
3. VERSUS ONLY, no solo mirror: the plan gives the valley to the friend in versus; a solo valley would be a short
   burning-raid with nothing to decide.
4. THE COG PRESS AS A SIDE TASK, its site given: the plan lists presses; one site keeps Part 1 short (NO WAITING).
   Regulators stand at the start (supply for the Swifts), and the Mainspring's and the Aviary's sites are placed so
   they mesh (a Swift costs Tension, so the Aviary must sit in the Mainspring's network).
5. THE UNMAPPED HIDES PEOPLE TOO: on unmapped land even a unit inside the soldiers' sight is hidden. Without it the
   Swifts' lesson would be only a darker picture. The trees and the land under the dark are still drawn (dimmed).
6. MAPPING HURRIES THE CAPTAIN: all three ways mapped bring him in 20 s, so a quick player is not left waiting 3:20.
7. THE PARLEY TAKES BOTH: Hollweg and the council's voice (Varenne or Morel) stand by the captain 3 s. The voice follows
   Hollweg there by himself; it is the player's walk that counts.
8. AN IDLE GUILD: at 5:00 with no tower the valley comes anyway, and the tower site can be lost (so a passive player
   loses, as the THREE RULES ask).
9. a05 `crates` "seen": Hollweg's line about the crates' quay is said whatever a05 did: the King's frame needs the
   reader to hear where the crates were; with a05 unplayed it is still true in the canon.
10. THE PLATES spread from the gallery mouth as gear ground (`ground` gear "plates"), the c01 seeds' ground without a
   seed. They wind the guild's machines that stand on them. Nobody but Ulrich remarks on them.
11. PADRE ANSELMO and a04's BROTHER ANSELM share a root: the plan's proposed name was kept, but the owner may want to
   rename one of them.
12. THE VALLEY'S PICTURES reuse d04_02 / d04_01 and Rome's still for its ending; the guild's opening uses the new
   d04_05 (Varenne's ship) only with Varenne.
13. NO KING'S CORRECTION in the guild's win: the King's closing lines correct the reader instead (the plates were the
   Perpetual's, not Hollweg's best work).
14. d02's COMMISSARY branch leads nowhere yet (`next` ""): a guild that lost d02 has no d04; the campaign's reclaim rule
   decides later.
15. THE SWIFT is "Cuco" in pt / es (the owner's name for it, tools/i18n/10_air.txt), the Aviary "Casa do Cuco" / "Casa
   del Cuco".

## What is left

- The owner's text, the stills, voices and portraits.
- The hub painting of Concórdia's council hall (the plan's prompt is in docs/campaign_act2_plan.md).
- d07 reads `colonists` and the plates' city (not built yet).

## Tests run

TESTS_RUN
