# Act 2, "The Queen": what was built (job d06-queen)

Act 2 step (docs/campaign_act2_plan.md "d06_queen", with the OWNER box at its top): the Naturalist line's second mission
of Act 2, after d03_fazenda. The wet season of 2775, three years after the commission: the river is higher than anyone
on it can remember, and the flood comes onto Lindqvist's island below Óbidos (proposed). THE BROOD IS NOT A PERSON (owner
2026-11-19 / 2026-11-22): nobody in this mission has a name, a will, a plan or a feeling. The island holds several Brood
Mothers; in the flood they FIGHT EACH OTHER; the strongest roots in the biggest pen and GROWS into the Queen; every bred
creature turns to the strongest call, and the leash breaks. Played as THE BROOD by default (the Naturalist line's second
Brood play); the solo pick and versus play LINDQVIST'S PEOPLE (THE FAZENDA). EVERY LINE OF TEXT IS A PLACEHOLDER for the
owner. "Linnea" is not used: the player's Mother is "your Mother", the others "the east pen's Mother" and "a wild Mother".

## Files

| what | where |
| --- | --- |
| the map | `campaign/maps/obidos_flood.json`, written by `tools/campaign/make_obidos_flood_map.py` (it builds d03's island in memory from `make_obidos_island_map.py` and floods it; `--ascii` prints it) |
| the mission | `campaign/missions/d06_queen.json`, written by `tools/campaign/make_d06_mission.py` (edit the script, run it) |
| the stills (stand-ins) | `campaign/stills/d06_01.jpg` .. `d06_04.jpg`, drawn by `tools/campaign/make_d06_stills.py`; the King's pages reuse b01_08 |
| texts pt / es | `tools/i18n/campaign/d06_queen.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storyline, the hubs | `campaign/campaign.json`: d06 joins the Naturalist line after d03 (d03's `next` is d06 for both sides); a new hub after d06, THE BOAT HOUSE AT ÓBIDOS (the station painting tinted blue-grey); Lindqvist's talks after d06 by side and `pieter` |
| the war map | `campaign/warmap.json` already had d06's pin and rules (act2-warmap): the island to the Brood, the fazenda burnt, the Queen's mark, the lower Amazon contested, a ledger line by `brood_n` and `pieter`. Checked against the flags set here: they match |
| the roster ladder | `tools/campaign/roster_ladder.py`: B5 and B6 swapped as the plan said: B5 = d06 (GROW TO STAGE 3 + THE BRUTE), bound team `stock`, NEW cards at 8 s, side `brood`, the cards in pt / es; docs/campaign_roster_ladder.md |
| the roles | `scripts/campaign/rebels.gd`: grown_mother (the player's, 2000 hp, 0.5), pen_mother (800 hp, 0.44), wild_mother (1000 hp, 0.48) |
| the engine | `scripts/campaign/mission_act2.gd` (leash breaks `"to": "near"` and `loose_only`, `brood_stage` condition, `root_now`), `mission_run.gd` (count `not_area` / `of_team`, hunt passes its own team, `max_hp` kept in a save), `campaign.gd`, `scripts/brood_new.gd` (a deny's why on the eggs), `scripts/entity.gd` (acid and a floor), `mission_heroes.gd` (a hero taken off by an exit); docs/campaign_engine.md "Added by Act 2's d06_queen" |
| tests | `tools/test_campaign_d06.gd` (`godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_d06.gd [-- only=data,flags,part1,part2,part3,defeat,mirror,save,ironman,hubs]`); d06 added to `tools/test_campaign_save.gd` and `.sh` |
| the balance sim | `tools/sim_campaign_d06.gd` (`-- active [diff=easy/hard] [side=fazenda] [lazy] [hidden=few/all] [clutch=burned] [rival=driven] [pieter=lost] [varenne=executed] [cages=all] [until=s] [save_at=s] [shots=dir]`) |
| voices | docs/chatterbox_todo.md "d06_queen" (38 lines with their feeling); tools/voice_clone/emotions.json `d06__<id>` |
| pictures | docs/shots/d06_queen/ (CHECK THE FEEL, below) |

## The map: the island below Óbidos in the flood (120 x 84, jungle, rain, dusk)

d03's island three years on, in the wet season (the map script starts from d03's and changes it):

- THE RIVER IS HIGH: the sandbanks are gone and the island's rim is under water all round.
- THE CREEK is twice as wide; its three fords are still the only ways over, and wider.
- THE SUGAR FIELDS west and east of the big house, the mill and THE OLD PENS stand in shallow water (wading ground).
- THE LOW PENS by the creek, pen 5 (west) and pen 4 (east), are flooded: the young of the stock stand in the water there.
- THE BIG PEN (d03's nest clearing, in the middle of the deep forest) is the island's highest, driest clearing, made wider:
  the player's Mother is rooted in it with the Tyrant Sire and the Storm Sire, and two Mound Turtles rooted at its rim.
- THE NORTH-EAST PEN (pen 3): the east pen's Mother, fenced in with her young.
- THE NORTH-WEST SHORE: a new mud bank where the flood drives the wild Mother onto the island.
- THE BIG HOUSE on its rise stays dry; the mission rings it with a palisade (four gates) and two swivel guns (Field
  Cannons). THE LANDING keeps a strip of beach for the canoes.

## How it plays: THE BROOD (solo; versus p1)

The player has the Mother (stage 2, rooted in the big pen), the Tyrant Sire and the Storm Sire rooted by her, two Mound
Turtles (her supply), and the young of the stock: 4 / 6 / 8 by d03 `hidden` few / some / all, standing in the flooded low
pens. Lindqvist's people are on another team in a TRUCE until Part 3 (spared, not attackable, not attacking).

- PART 1, THE FLOOD (2:30 on NORMAL; EASY x1.25, HARD x0.85; usually much shorter): the two keepers walk from the low pens up
  the paths to the big pen with their lures. THE LEASH (d03's lesson): the young obey only inside a keeper's green ring
  (8 tiles); out of it one is LOOSE and wanders. The player walks them up with the keepers. At 0:35 a deep call comes over
  the water from the north-west shore (not when all are already in): a loose one walks toward it. All in the big pen ends
  the part at once; else the water reaches the paths at 2:30 and the stragglers are left.
- PART 2, THE MOTHERS FIGHT: the flood drives a WILD MOTHER and her pack onto the north-west shore (a bigger pack while b01
  `rival` is standing: "a pack off the Rio Negro, perhaps"); the keepers drop the lures and run for the house. Now each
  creature follows only ITS OWN MOTHER'S CALL: a ring of 13 tiles round her. Inside it they obey. Out of it, within 5 tiles
  of another Mother, one goes over to her (THE LEASH BREAKS: `"to": "near"`, `loose_only`: a creature in its own Mother's
  ring never changes side, so fighting beside her is safe). The wild pack attacks the big pen at once; at 1:15 the east
  pen's Mother breaks her fence and comes too; both packs fight each other as well as the player. The Mother can UPROOT,
  walk to the fight and fight (she is big: 2000 hp), and root again. Kill both other Mothers: each one's pack, loose,
  turns toward the strongest call left, and those that come within 9 tiles of the player's Mother join her.
- PART 3, THE QUEEN AND THE FALL: one Mother left. Root her in the big pen and press GROW (stage 3: 500 food and 75
  spoils, given for it; a minute, rooted). While she grows her eggs are held back (a deny with a reason on the card: all
  she has goes into growing). Lindqvist sends the keepers out to shoot her before it is done (a sally, then back). She
  becomes THE QUEEN: a mid-match show (three stills: the flood, the pens, the Queen; Lindqvist's line), every leash ends,
  every creature of the fallen Mothers still alive turns to her, and the eggs come back. Lindqvist and Pieter run for the
  canoes (the lure book left upstairs). THE FALL: lay BRUTES on the Queen's card (the Tyrant Sire rooted beside her; food
  for two given, and a trickle of food every 8 s from the drowned cane), break the palisade, then the big house (3000 hp,
  shown on the map): WON.
- LOST: the Mother killed before she is the Queen.

## How it plays: THE FAZENDA (the solo pick, or versus p2)

Lindqvist's people: Lindqvist (a hero: wounded, not killed), Pieter (by the flags), the keepers, four hands, two swivel
guns. The stock is asleep in the pens (the big pen and the north and east ones); the Mothers floor at 35% so the stock
never dies of the torches alone. From Part 2, BURN THREE PENS (a man stands 4 s in each: the big pen, the north pen, the
east pen) and get Lindqvist to the canoes before the Queen grows: solo the Queen is a clock (7:00 on NORMAL, scaled; the
big pen burned puts it 1:00 later); in versus it is the Brood player's GROW. A fazenda win is canon-compatible: `brood_n`
few, `book` taken (the King: "He told me he burned them. He did not burn enough.").

## The flags read and set

Read (every one has the canon as its default when missing):

| flag | effect |
| --- | --- |
| d03 `hidden` few / some (canon) / all | the young: 4 / 6 / 8; with all, a Tyrant Challenger more in the east pen |
| b01 `clutch` saved (canon) / burned | Lindqvist's opening line: the player's Mother came from the station's clutch, or was netted on the mountain |
| b01 `rival` standing (canon) / driven | standing: the wild pack is bigger (a Raptor more) and the narrator names it |
| b01 / a05 / d03 `pieter` alive (canon) / lost | Pieter on the island with the stud book, or not (two keepers carry the lures on each side; a narrator line says so) |
| a05 `cages` all | the Tyrant Sire is the young Sire of the plateau's cages, grown (a narrator line) |
| a06 `varenne` executed | the keepers are Assembly men (militiamen), a narrator line |

Set:

| flag | values |
| --- | --- |
| `queen` | grown (the Brood's GROW, or the fazenda's clock running out) |
| `brood_n` (+ `brood_n_n`) | the bred creatures on the Queen's side when she grows, as a share of all the bred creatures on the island: few under 25%, some, all from 55%; the fazenda's win: few |
| `pieter` | alive / lost (alive if he reached the canoes or still stands) |
| `lindqvist` | fled (always) |
| `book` | left (the Brood's win: the lure book stays in the house, for d08) / taken (the fazenda's) |
| `burned_big`, `burned_north`, `burned_east` | yes, for each pen the fazenda burned |

## Balance (tools/sim_campaign_d06.gd; the last runs)

SIM_TABLE

## Pictures (docs/shots/d06_queen/, CHECK THE FEEL)

The sim's `shots=` under xvfb-run at 1280x720, NORMAL: the Brood's run (start, the young in the pen, the wild Mother, the
walk, a creature lost, a Mother down, the joined, the fight, the east pen, Part 3, the Queen, the run, the fall, the
breach, the house) and the fazenda's. What they showed and what was done:

- The dialogue ran up to 30 s behind Part 2's events when the sim walked the young in fast (all in at 0:30): Pieter's tip
  (the narrator's lesson says the same) was cut, and the call over the water is skipped when all are in already. A
  person takes longer in Part 1 and meets the lines in time; NEXT skips. Left as it is otherwise.
- THE QUEEN objective showed as "(optional)": it is primary now (it is the way to the end, and a checkpoint).
- At THE FALL the big house stood in the dark (the stock had never been south of the creek): the house and its palisade
  are revealed to the Brood when the fall begins, with the ping.
- The Mothers at 0.5 / 0.44 / 0.48 fill the big pen with the Sires and turtles; the fight reads (each Mother in her
  team's colour). The keepers' rings and the Mother's ring show as thin green circles.
- The NEW cards (GROW to stage 3, the Brute) come at 8 s, long before they are used (the ladder's rule in every mission,
  and its test). Left as it is.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

- d06_01 THE FLOOD. "Oil painting, 18th-century history painting style. A wide brown tropical river in flood at dusk under
  heavy rain; on a forested island the water stands in the sugar cane and among the posts of wooden animal pens; a white
  plantation house with a red tile roof on a low rise, lamps lit in its windows. 3:2 landscape, no text." (References:
  d03_01 when painted, else b01_02.jpg, a05_04.jpg.)
- d06_02 THE PENS. "Oil painting, 18th-century history painting style. Night, rain, a muddy jungle clearing with broken
  wooden fences: two huge green reptilian beasts, each like a crested lizard as large as a house, rear and clash among
  smaller sleek spined creatures; lantern light from a distance, the scene animal and terrible, no rider, no person
  near. 3:2 landscape, no text." (References: b01_06.jpg, a03_03.jpg.)
- d06_03 THE QUEEN. "Oil painting, 18th-century history painting style. Dawn after rain in a jungle clearing: an enormous
  green reptilian beast, grown far larger than the creatures round it, lies rooted among the roots and mud, crested,
  armoured, eggs glowing faintly at its side; dozens of smaller spined creatures stand all turned toward it. Mist,
  shafts of light. An animal, not a monarch: no crown, no throne. 3:2 landscape, no text." (References: b01_05.jpg,
  a03_03.jpg.)
- d06_04 THE CANOES. "Oil painting, 18th-century history painting style. Night on a flooded river: an elderly
  Scandinavian naturalist in a wet linen coat and a young man paddle a canoe away; behind them on the island a white
  plantation house burns behind a broken palisade, and on the bank many green reptilian shapes stand against the fire.
  3:2 landscape, no text." (References: station_lindqvist.png, b01_07.jpg.)

## The voice lines

docs/chatterbox_todo.md "d06_queen": 38 lines (Lindqvist 24, Pieter 8, the King 6) with the feeling of each; the 28
narrator lines ("The Island") and the two NEW cards can stay as text. Pieter is the grown Pieter of d03 (a voice still to
design, as there). Twelve lines have a preset in tools/voice_clone/emotions.json (`d06__<id>`).

## What is placeholder

Every line of text (en, pt, es). The four stills. The keepers have no portraits (initials). The call over the water
reuses b01's `campaign/linnea_call` sound and the Queen's moment `campaign/forest_answer` (only as sounds: no line names
anything).

## Claude's choices for the owner

1. The OWNER box over the plan's old text: the Queen is not Linnea and nobody comes for anything. Three Mothers on the
   island, each on a team of its own (the player's GREEN, the east pen's ORANGE, the wild one RED): Lindqvist's player
   Mother (from b01's clutch or the plateau, as in d03's opening), one more he bred in the east pen, and one the flood
   carries in. Which wins is played, not written.
2. "Linnea" appears nowhere in d06 (the plan's own rule); the player's Mother is "your Mother".
3. Lindqvist's people are on THEIR OWN team (yellow, scripted) in a truce until Part 3, unlike d03 where they were on the
   stock's team: the keepers are the leash in Part 1 and the enemy in Part 3. The truce is `spare` + `carry` on both.
4. THE STRONGEST CALL is built from d03's LEASH: in Part 2 the lure is the Mother herself (the tag `call`) with a ring of
   13 tiles; a loose creature within 5 tiles of another Mother goes to her team (`"to": "near"`), and one inside its own
   ring never does (`loose_only`). Fallen Mothers' packs come to the player's within 9 tiles.
5. Two Mound Turtles rooted at the big pen's rim are given (16 + 24 supply = 40): without them there is no room for the
   Brutes. No grubs, no Rootmaws on the flooded island (denied): the food comes as gifts at Part 3 and the fall and a
   trickle after the Queen (30 food, 4 spoils every 8 s), so the fall never stalls.
6. While she grows her eggs are held back (a deny with its reason on the card), so the food given for GROW is never
   spent on Raptors first.
7. Lindqvist sends the keepers out to shoot her while she grows (NO WAITING: the minute of growing has a fight in it).
8. The big house has 3000 hp (a Town Hall at a mission's max_hp), ringed with a palisade of four gates and two swivel
   guns; two more hands come out at Part 3.
9. `brood_n` is counted when the Queen grows (the bred creatures on her side then, out of all the bred ones the island
   started with): few under 25%, all from 55% (the NORMAL sims end "some" most often). Counting at the end would count
   the Brutes' deaths at the palisade.
10. B5 and B6 swapped as the plan said: d06 is B5 (GROW to stage 3 + the Brute). Hatchlings and the Storm Sire stay from
    d03 (B4).
11. The mirror burns three pens (the big pen, the north pen, the east pen: 4 s a man in each) and needs Lindqvist at the
    canoes before the Queen's clock (7:00 NORMAL; the big pen burned: +1:00). The Mothers floor at 35% there so the
    torches don't decide the Brood's fate by a stray shot.
12. Versus: the Brood player's GROW ends the fazenda's chances; the fazenda player could burn the big pen while the
    Mother is still in it (the truce ends at Part 2 for that side). No co-op (one Brood, one fazenda).
13. The hub after d06 is a new room, THE BOAT HOUSE AT ÓBIDOS (the station painting tinted), not a Brood hub (NO BROOD HUB,
    EVER): Lindqvist's refuge, his three talks by side and `pieter`.
14. The rival pack of b01 (`rival` standing) is not a fourth side: it makes the wild Mother's pack bigger, and the
    narrator wonders if it is the pack off the Rio Negro.
15. The call over the water (Part 1) reuses b01's call sound; the Queen's moment reuses `forest_answer`. Both only sounds.
16. The mid-match show's captions are three words each ("The flood." "The pens." "The Queen.") and Lindqvist's line: no
    creature speaks or is named.
17. The King's closing line keeps Lindqvist's error in view (owner 2026-11-22 23:37): "He bred nothing. He kept animals
    that were made long ago to become exactly that." / "The Church told him what they were. He still says they evolved."
18. Lindqvist is a hero (wounded, not killed) on the fazenda's side; Pieter is not (he can be lost: the flag).
19. The rival Mothers walk at 1.8x a Mother's pace (NO WAITING: they come to the fight rather than the player waiting for
    them).

## What is left

- The owner's texts, stills and voices.
- d08_rivers reads `book` left / taken and `brood_n`.
- The young in Part 1 are easy to walk in (the sim does it in 30 s); if the owner wants Part 1 longer, the keepers could
  start lower down or the call come sooner.

## Tests run

TESTS_RUN
