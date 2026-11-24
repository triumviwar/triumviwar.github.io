# Act 2, "The Jungle Front": what was built (job d10-jungle)

Act 2's crossing branch (docs/campaign_act2_plan.md "d10_jungle"): after d09's council the army splits, and a column
of it goes up the Amazon under Valadares to Óbidos, on the narrows of the river, to break the swarm's forward nests
before the rains. Valadares tells it (he wrote it down as it happened); the King frames it. With it comes THE
BALLOONIST (the worldwide plan's "THE BALLOONIST"): Father Inácio Lourenço, a Brazilian priest-aeronaut (invented,
inspired by Gusmão), in the OBSERVATION BALLOON (THE ROSTER LADDER's C8): he lifts the fog off the river. EVERY LINE OF
TEXT IS A PLACEHOLDER for the owner.

Two versions by d09's choice (act2-engine0's `versions`):

- FRESH (d09 `first` = brood: the swarm first): the swarm is young below the Barra: three forward Mothers (two with
  d05 `fields` burned), no Mist Toads, fewer in each wave. Opens as soon as d09 is won.
- GROWN (`first` = clockwork: the city first): a year on the rivers without the army: five Mothers (four with the
  fields burned), three MIST TOADS laying fog over their Mothers, a Tyrant Challenger by each, Spitters and later
  Challengers in every wave, Hatchlings after the balloon, two Mothers out west still under the fog. The column comes
  north after the siege: two more Guardsmen, the Mortar, and the siege train's science (C9's PREPARED CHARGES and
  GUNNER'S QUADRANT). Opens only once d11 (the siege, fought first) is won too (`needs_if`).

The rules it keeps: THE BROOD IS NOT A PERSON (no creature has a name, a reason, a want or a plan; the Mothers are
"rooted where the bank is dry", the waves "come down the levee", the last ones "go back up the levee"; the King: "The
Queen was never on that map. She was further up"). No "Linnea" in d10 (nobody there would say it). LOCAL PEOPLE ARE
MINOR: the captain of Óbidos and the Barra's sergeant have a few lines each. NO BROOD HUB OR WAR MAP: the swarm's side
is a mirror told by the King ("Here is how it would have gone if the river had been theirs"); a swarm win breaks the
war map's seal (not how it went). The Crown and the Church are the good side: the balloonist is a priest who says Mass
on the island when it is over.

## Files

| what | where |
| --- | --- |
| the map | `campaign/maps/obidos_front.json`, written by `tools/campaign/make_obidos_front_map.py` (`--ascii` prints it) |
| the mission | `campaign/missions/d10_jungle.json`, written by `tools/campaign/make_d10_mission.py` (edit the script, run it: it also patches campaign.json and hubs_grow.json, idempotently) |
| the stills (stand-ins) | `campaign/stills/d10_01.jpg` .. `d10_04.jpg` and Father Inácio's portrait `campaign/portraits/inacio.png`, drawn by `tools/campaign/make_d10_stills.py`; the King's pages reuse b01_01 |
| texts pt / es | `tools/i18n/campaign/d10_jungle.txt` (written by the mission script; then `python3 tools/i18n_build.py`); three war map lines in `tools/i18n/campaign/warmap_act2.txt` |
| the storylines | `campaign/campaign.json`: d10 is on the Crown line after d09 (only there: no Brood hub) |
| the hubs | the King's study: the King after d10 by `jungle`, Ruggieri's dispatch from Óbidos; `campaign/hubs_grow.json`: Ruggieri's armoury line after d10; the Naturalist's hub: Valadares after d10 (the balloon's map; the island burned; a swarm win "not how it went") |
| the war map | `tools/campaign/warmap_act2.py` (run it: it writes `campaign/warmap.json`): `jungle` held / thin (planned) kept; added: the island burned (ledger), the reclaim (d08's broken seal mended, the Barra's region contested), a swarm win breaks d10's seal |
| the roster ladder | `tools/campaign/roster_ladder.py`: C8 = d10 (the OBSERVATION BALLOON, bound team `column`), and a SECOND ladder in the same mission: B7 = d10 (the MIST TOAD, FOG, MIASMA, bound team `swarm`, cards as `new_brood`); docs/campaign_roster_ladder.md; tools/test_roster_ladder.gd reads each row's own speaker |
| the roles | `scripts/campaign/rebels.gd`: inacio, river_mother, old_mound, obidos_captain (new keys) |
| the engine | `scripts/campaign/mission_act2.gd`: condition `won_by`, actions `cast` and `tech`; `scripts/campaign/campaign.gd`: `needs_if`, the checks; docs/campaign_engine.md "Added by Act 2's d10_jungle" |
| tests | `tools/test_campaign_d10.gd` (`godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_d10.gd [-- only=data,flags,part1,part2,part3,reclaim,defeat,mirror,versus,save,ironman,hubs]`) |
| the balance sim | `tools/sim_campaign_d10.gd` (`-- [active] [side=column/swarm] [diff=easy/hard] [first=brood/clockwork] [fields=burned] [lure=used] [barra=burned] [seal=broken] [map=withheld] [brood_n=few/all] [clutch=burned] [noballoon] [until=s] [save_at=s] [shots=dir]`) |
| voices | docs/chatterbox_todo.md "d10_jungle" (50 spoken lines with their feeling); tools/voice_clone/emotions.json `d10__<id>` (9 presets) |
| pictures | docs/shots/d10_jungle/ (CHECK THE FEEL, below) |
| patch note | scripts/patch_notes.gd and tools/i18n/patch/notes.txt under 0.38.999 |

## The map: Óbidos and the lower Amazon (144 x 96, the VÁRZEA biome, a rainy jungle day, dusk in Part 3)

- THE MAIN CHANNEL across the south (deep water), narrowing to THE NARROWS under Óbidos (east). In its middle THE
  ISLAND of d03 (Lindqvist's fazenda): the ruins at its heart are the swarm's oldest ground (a great Mound Turtle, three
  Rootmaws, a guard). Two SHALLOWS (wade) cross the north arm to it: the west ford and the east ford.
- ÓBIDOS on a BLUFF (east): the fort's keep (a Town Hall: the one thing that must stand), its church, the column's
  depot (Barracks, Foundry, Horse Breeder, six quarters), a palisade with the WEST GATE on the levee and a ramp down to
  THE LANDING where the boats come.
- THE LEVEE: the dry trail along the north bank from Óbidos to the west edge (the men's road and the waves'), the
  UPRIVER BATTERY on a little rise west of Óbidos (THE RECLAIM PART), the killing ground before the west gate.
- THE VÁRZEA north of the levee: flooded forest (men wade at half pace, nothing is built in it, the creatures go at
  their own pace: d05's `wade` rule), two CREEKS north with dry trails, and five clearings where the forward Mothers
  root: m1 the near bank (by Óbidos), m2 the creek mouth, m3 the north creek, m4 the west creek, m5 the upriver bank.
- THE FOG: the whole map is dark on the column's screen (THE UNMAPPED of d04) except Óbidos and the landing (and, with
  a03 `map` drawn, the east creek's road: Valadares' map).

## How it plays: THE JUNGLE COLUMN (solo; co-op p1; versus p1)

The player has Valadares and Father Inácio in his balloon (heroes: wounded, not killed), 8 Musketeers and 4 Guardsmen
(the C5 kit, the C7 armour), 3 Dragoons (the Cavalry Charge drilled), 2 Field Cannons, a Powder Wagon (GROWN: 2 more
Guardsmen and a Mortar), 400 gold and 220 powder, and the depot in Óbidos to train from. The column has no farms: the
boats bring pay (30 gold, 10 powder every 20 s) and a chest at Part 2 (250 gold). NEW (C8): THE OBSERVATION BALLOON,
explained by its NEW card at 8 s.

- THE RECLAIM PART (d08 won by the swarm, or GROWN with d08 `barra` burned): the Barra's survivors ran to Óbidos and the
  swarm came after them onto the upriver battery. Take it back first (its objective); the sergeant and three men join.
- PART 1, THE NARROWS: hold Óbidos (two raids at the west gate, 0:20 and 0:55; GROWN: Hatchlings out of the canopy at
  1:00 after the balloon) and send the balloon over the island: 30 s over the LOOKOUT (Father Inácio counts) and THE FOG
  LIFTS: a show (the river from above, the rings of the rooted Mothers), the river, the creeks and the island mapped,
  every Mother pinged. Never sent: at 3:40 a canoe brings the word (NO WAITING), and Part 2 begins anyway.
- PART 2, THE NESTS: a clock (the rains: FRESH 6:00, GROWN 9:00). Break the forward Mothers; going near one brings her
  defenders out of the trees. Every 55 s each Mother still rooted sends a wave down the levee to the west gate. d08
  `lure` used: the second wave is drawn under Óbidos' guns by the old lure once more (THE LURE POST). GROWN: the Mist
  Toads lay fog over their Mothers when the column comes near (fog blinds the guns: send riders or the balloon), and
  two more Mothers lie up west under the fog until the balloon has seen them (the WEST objective).
- PART 3, THE ISLAND: every nest broken = `jungle` held; the rains first = `jungle` thin and a flood of the rest at
  Óbidos. Cross the shallows and burn the old ground on the island (`island` burned); then (or 2:20 after Part 3 began,
  NO WAITING) THE LAST WAVE comes down the levee from upriver, half to the island, half to Óbidos (a Brute, and the
  Tyrant Sire unless b01's clutch was burned; with d06 `brood_n` all three Raptors more; GROWN more and two Toads; d08
  `lure` used: one wave more "to the smell of it"). Break it, or hold till THE EBB (2:30): WON. The flags: `jungle`,
  `island` burned / standing, `inacio` joined (the priest stays with the army: the Act 3 balloonist), `reclaim` barra.
- LOST: the fort's keep falls (the primary objective).

## Co-op, the mirror and versus

- CO-OP: p2 leads Óbidos' garrison (the captain, 8 Musketeers, the two fort guns: three in GROWN), not bound by the
  ladder; the scripted raids and waves come as in solo.
- THE MIRROR (the solo pick: the swarm; the King: "Here is how it would have gone if the river had been theirs"): the
  forward Mothers (tougher: 5000), the Tyrant and Venom Sires rooted by m1 and m2 (they fertilise), 4 grubs, 6 Raptors
  and 3 Spitters, a Mist Toad, the creek mouth's Mother GROWN to stage 3, 500 food and 60 spoils and the river's game (60
  food every 10 s). NEW (B7): the MIST TOAD, FOG and MIASMA, by their NEW cards. Keep TWO forward Mothers alive until the
  dry season (15:00), or break Óbidos' keep. The scripted column: its riders probe the nearest nest at 0:45 (and twice
  more), the column marches at 2:30 (FRESH 4:00), Mother after Mother, nearest first, with at least twelve men in the
  line (fewer: it goes back under the guns and waits for the boats: three men every 2:00). Down to one Mother: lost.
- VERSUS: p2 leads the swarm as in the mirror; the column's player as in solo but without the scripted raids, waves and
  last wave: he wins by breaking the nests down to one, the swarm by holding two until the dry season or breaking the
  keep.

## The flags read and set

| flag | value | d10 |
| --- | --- | --- |
| d09 `first` | brood / clockwork | FRESH / GROWN (the version); clockwork also needs d11 won (`needs_if`) |
| d05 `fields` | left (canon) / burned | one forward Mother more / fewer (m3 FRESH, m5 GROWN) |
| d08 won_by swarm | (the broken seal) | THE RECLAIM PART |
| d08 `barra` | burned | GROWN: THE RECLAIM PART; FRESH: Valadares remembers the lower town (a line) |
| d08 `lure` | used | THE LURE POST on wave 2, and one wave more at the end |
| a03 `map` | drawn (canon) / withheld | the east creek's road known under the fog / Valadares' map is sealed in Rome (a line) |
| d06 `brood_n` | few / some / all | waves one Raptor smaller (FRESH) / as written / one bigger, the last wave three bigger |
| b01 `clutch` | burned | no Tyrant Sire in the last wave |
| sets `jungle` | held / thin | every nest broken before the rains / not |
| sets `island` | burned / standing | the island's old ground burned |
| sets `inacio` | joined | the column won: Father Inácio stays with the army (Act 3) |
| sets `reclaim` | barra | the battery taken back (d08's seal mended on the war map) |

## Balance (tools/sim_campaign_d10.gd; the last runs, after the Mothers' clearings were widened)

The bot column: the balloon to the lookout, then Mother after Mother nearest first with the line, guns and riders,
training Musketeers all along, then the island. The bot swarm: lays at every rooted Mother, the army on any Mother the
column nears, and (after 9:00 with 24 creatures) at the keep. "Idle" is the longest stretch with nothing new for the
player (THE THREE RULES: under ~45 s).

| run | result | time | longest idle |
| --- | --- | --- | --- |
| column, FRESH, EASY | won, held, island burned | 5:44 | 19 s |
| column, FRESH, NORMAL | won, held, island burned | 6:01 | 23 s |
| column, FRESH, HARD | won, held, island burned | 5:42 | 24 s |
| column, GROWN, EASY | won, held, island burned | 7:11 | 19 s |
| column, GROWN, NORMAL | won, held, island burned (7 men left of 24 at the end) | 7:24 | 14 s |
| column, GROWN, HARD | won, held, island burned (7 left) | 8:28 | 14 s |
| column, FRESH, d08 seal broken + lure used (THE RECLAIM PART, the lure post, the smell) | won, reclaim barra, held, island burned | 5:38 | 25 s |
| column, GROWN, the flags mixed (fields burned, brood_n all, clutch burned, Barra burned: the reclaim, map withheld) | won, reclaim barra, held, island burned | 6:08 | 14 s |
| column, passive (never moves), FRESH / GROWN | survives: thin, island standing | 14:46 / 17:46 | 178 s / 135 s |
| swarm, FRESH, EASY (active) | won, no Mother lost | 18:50 | 112 s |
| swarm, FRESH, NORMAL (active) | won (two Mothers at the dry season) | 15:05 | 112 s |
| swarm, FRESH, HARD | lost (down to one) | 6:45 | 112 s |
| swarm, FRESH, passive | lost | 6:39 | 43 s |
| swarm, GROWN, NORMAL | won, no Mother lost | 15:05 | 86 s |
| column, GROWN, NORMAL, saved at 3:20 and loaded | "SIM LOAD SAME yes"; won, held, island burned | 7:14 | |

Read: FRESH is short and kind, GROWN longer and closer (the story: the city first cost the river a year). A column that
never leaves Óbidos still holds (the garrison, the guns and the gate), but `jungle` thin and the island standing: the
cost is in the flags and on the war map (Claude's choice 6). The mirror's long idles are the swarm at its supply cap
with the column under its guns: the swarm's player is free to go for the keep (its second objective).

## Pictures (docs/shots/d10_jungle/, CHECK THE FEEL)

From `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/sim_campaign_d10.gd --
active shots=docs/shots/d10_jungle` (and `first=clockwork`, `side=swarm`): the start in the fog, the first raid at the
gate, the balloon going up, over the lookout, the fog lifted, the column at a Mother, a wave on the levee, GROWN's Toad
fog, the island, the last wave, the ebb; the swarm's start and its attack. What was looked at is in "Looked at" below.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as Act 1: an oil painting in the manner of an 18th-century history painting, visible brushwork, 3:2
landscape (cut to 1280 x 853), no text. Save each as `art/campaign/stills/d10_0N.png` and cut it into
`campaign/stills/d10_0N.jpg`.

- d10_01 THE BALLOON OVER THE CANOPY. "Oil painting, 18th-century history painting style. At dawn a purple observation
  balloon with a wicker basket hangs on a long rope over an endless green rainforest canopy beside a very wide brown
  river; morning mist lies on the water and in the trees; in the basket a cheerful Brazilian priest of about forty in a
  black cassock and a broad hat looks down through a brass telescope and points; far below, in the forest along the
  bank, several round bare patches of grey swamp. 3:2 landscape, no text." (References: campaign/stills/d05_01.jpg,
  campaign/stills/d08_01.jpg.)
- d10_02 THE NESTS. "Oil painting, 18th-century history painting style. Soldiers in purple coats and tricornes wade
  knee-deep through a flooded forest with muskets and torches toward a clearing where a huge reptilian creature lies
  rooted in a grey swamp among smashed trees; a thick green-grey fog rolls between the trunks; a grey-haired explorer in
  a long brown coat with a compass leads them. The creature is an animal: no expression, no gesture. 3:2 landscape, no
  text." (References: campaign/stills/d08_02.jpg, campaign/hub/barra_valadares.png.)
- d10_03 ÓBIDOS. "Oil painting, 18th-century history painting style. A small whitewashed Portuguese river fort with a
  church tower on a green bluff over the narrows of an immense brown river at morning; fog on the water; river boats
  and canoes at a landing under the bluff; a purple flag on the fort. 3:2 landscape, no text." (References:
  campaign/stills/d08_03.jpg.)
- d10_04 MASS ON THE ISLAND. "Oil painting, 18th-century history painting style. On a river island, among the
  blackened ruins of a burnt plantation house, a priest in green vestments says Mass at a makeshift altar of crates
  with a cross; soldiers in purple coats kneel bareheaded in the ash; a purple balloon is tethered behind them; grey
  dawn over the wide river. 3:2 landscape, no text." (References: campaign/stills/d06_04.jpg, campaign/stills/a07_07.jpg.)
- FATHER INÁCIO'S PORTRAIT (campaign/portraits/inacio.png, 256 x 256, made with the other portraits as a 2x2 sheet if
  the owner likes). "Oil painting portrait, 18th-century style, head and shoulders: a cheerful Brazilian priest of about
  forty, sun-browned, short dark hair, clean-shaven, laughing eyes, a black cassock and a white collar band, a pair of
  brass flying goggles pushed up on his forehead, a small brass telescope on a cord; plain dark background. No text."
  (References: campaign/portraits/tomasz.png for the style.)

## The voice lines

docs/chatterbox_todo.md "d10_jungle": 50 spoken lines (Valadares, Father Inácio, the King, Ruggieri, the captain of
Óbidos, the Barra's sergeant) with the feeling of each; the 33 narrator lines ("The Amazon") and the four NEW cards can
stay as text. Nine lines have a preset in tools/voice_clone/emotions.json (`d10__<id>`). New voices to design: Father
Inácio (bright, quick, a man delighted by the sky) and the captain of Óbidos (or Sobral's voice reused).

## What is placeholder

Every line of text (en, pt, es). The four stills and the portrait (drawn in code). The people's art: Valadares is a
dismounted officer in his role art, Father Inácio the Crown's balloon, the captain a plain Officer; the forward Mothers
are Brood Mothers in the b_linnea art (scaled down), the old mound a Mound Turtle.

## Claude's choices for the owner

1. THE MOTHERS' COUNT: the plan's "FRESH 2, GROWN 4; one fewer with d05 `fields` burned, one more with left" read as:
   burned = the base (FRESH 2, GROWN 4), left (the canon) = one more (3 / 5). So the canon game has 3 and 5.
2. THE RECLAIM PART is ÓBIDOS' UPRIVER BATTERY, not the Barra's bluff (the plan's "retake the Barra's bluff"): the
   Barra is far up the Rio Negro, off this map; the Barra's survivors fled to Óbidos and the swarm followed them onto
   its battery. It comes with d08 won by the swarm (a broken seal: the act's reclaim rule) or GROWN with d08 `barra`
   burned (the plan). Taken back, it mends d08's seal on the war map and the Barra's region turns contested.
3. THE GARRISON is Óbidos' (BLUE, co-op p2), not the Barra's (the plan): the mission is at Óbidos.
4. THE FOG ON THE RIVER is THE UNMAPPED (d04): the balloon is the flyer that maps it; the lift is a STAY (30 s over the
   lookout, over the island) so the player sees him count; a canoe's word at 3:40 if he never goes (NO WAITING).
5. THE BALLOONIST JOINS: Father Inácio Lourenço (proposed name, the worldwide plan's), a hero (wounded, not killed: his
   silk is torn and he comes down slowly). `inacio` joined is set on the column's win, for Act 3. His portrait is a
   stand-in.
6. A PASSIVE COLUMN SURVIVES (Óbidos, its garrison and guns hold the gate), but with `jungle` thin and the island
   standing, and the war map gives the lower river to the swarm. A defeat comes only with the keep.
7. THE COLUMN'S PAY: no farms on a jungle march, so Ruggieri's boats bring 30 gold and 10 powder every 20 s and a chest
   at Part 2; the depot in Óbidos trains (Barracks, Foundry, Horse Breeder, six quarters for supply: the story's deny
   on new buildings).
8. GROWN brings C9's science (PREPARED CHARGES, GUNNER'S QUADRANT) researched: the column came north after the siege
   of Concórdia (d11 fought first), and it has the siege train's Mortar.
9. MIST TOADS: scripted in GROWN (they lay their fog when the column is within 9 tiles of them, every 14 s), and the
   mirror's own Toad in both versions so the B7 step is always met (the plan's choice 9).
10. THE FLOOD: when the rains come with Mothers still rooted, each sends four Raptors and a Spitter at Óbidos before
    Part 3's island (the nests' cost, at once).
11. THE LAST WAVE comes whether the island is burned or not (2:20 after Part 3 begins), so nobody waits for it; its
    stragglers (under four) go back up the levee after 20 s and are taken off the map.
12. THE QUEEN IS NOT HERE: the King's last line says she was further up the river, beyond any map (the plan: Act 3).
13. THE MIRROR'S RULE is the plan's (two Mothers until the dry season, or break Óbidos); the column's versus rule is its
    mirror (break them down to one). The mirror's column waits 4:00 in FRESH (2:30 in GROWN) and probes with riders in
    between, so a FRESH swarm with three young Mothers has time to lay.
14. d10 IS ON THE CROWN LINE ONLY (after d09) and the war map; no Brood hub. Valadares' line goes to the Naturalist's hub
    (his own quarters at the Barra), as d08's.
15. THE MOTHERS' CLEARINGS are wide enough for a stage-2 Mother's root (ten cells by five): the first map had her foot
    on the trees and she never rooted (found by the save test; fixed in the map).
16. THE LURE POST on the second wave pulls it under the guns for 60 s (d08's engine), then it attacks the killing
    ground: the lure works once more and costs a wave at the end ("to the smell of it").
17. `needs_if` (new): GROWN opens only once d11 is won; FRESH right after d09 (the plan's owner question 9 answered by
    the diamond: the front fought first is open first).

## Looked at (CHECK THE FEEL)

The pictures in docs/shots/d10_jungle/ (FRESH, and the swarm's 1-4) and docs/shots/d10_jungle/grown/ (GROWN), looked at
one by one:

- The start (1, 2): the column at Óbidos' landing, the balloon (purple silk) beside the guns, rain on the várzea; the
  fog is plain on the minimap (only Óbidos and the landing light) and the narrator's lesson tells the player to send the
  balloon west to the island. The scale is right: the balloon over the soldiers, the guns between them.
- The lift (5): over the island the ruins and the old mound show under the balloon, both first objectives ticked; the
  NEW card for the balloon came at 0:58 (it waits behind the opening's lines): readable, and its text explains the
  balloon's sight and the dark land.
- The nest (6): a forward Mother ROOTED in her swamp, big against the men (a Brood Mother scaled for a forward nest),
  Valadares' line and the balloon over them: it reads as "a thing rooted in a clearing". (The first runs showed four of
  five Mothers never rooted: their foot was on trees; the clearings were widened: Claude's choice 15.)
- GROWN's Toad fog (grown 6): a green cloud over the Toad and its Mother, "Your forces are under attack!" from inside
  it: the fog hides what is in it, as wanted. The UPRIVER objective explains itself in one line.
- The last wave and the ebb (9, 10): Part 3's dusk is darker, the objective list shows THE LAST WAVE and the ebb's
  clock; at the ebb the narrator says the rest goes back up the levee into the fog.
- The swarm's start (swarm 1) and later (swarm 4): the swarm's HUD (food and spoils), the two objectives and the dry
  season's clock; the minimap shows the rooted Mothers' swamps as green circles.
- Small things left: the objectives column grows tall in GROWN's Part 2 (five lines) and covers part of the minimap
  for a moment; the narrator's card shows initials (TA: no portrait for a place, as everywhere).

## What is left

- The owner's texts, stills, portrait and voices; Father Inácio's and the captain's voices to design.
- Act 3 reads `inacio` joined (his own scouting mission) and `jungle` / `island`.

## Tests run

- tools/test_campaign_d10.gd: 0 failures (data, flags, every part, reclaim, defeat, the mirror both ways, versus, save,
  ironman, hubs, no script error).
