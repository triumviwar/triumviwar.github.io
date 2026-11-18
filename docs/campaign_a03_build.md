# Act 1, "The Lost Plateau": what was built (job a03-plateau, 0.38.55)

Act 1's mission a03_plateau (docs/campaign_act1_plan.md, "a03_plateau", as changed by its OWNER ANSWERS of 2026-11-17
22:04): since the Naturalist's prologue b01_specimen became the first Brood play, a03 is played by default as
VALADARES' CROWN PARTY: no base, the mist, the climb, four survey marks, the sleeping nest, the flight down to the
canoe on a countdown, and the choice THE MAP. Valadares tells it from his report to the Crown; the King frames it (he
holds that report). THE NEST is still a playable side, by the SOLO SIDE PICK or in versus. It is the Naturalist line's
second mission, open once Specimen One is won.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite (kept short and plain on purpose). The stills are stand-ins.

## Files

| what | where |
| --- | --- |
| the mission | `campaign/missions/a03_plateau.json`, written by `tools/campaign/make_a03_mission.py` (edit the script, run it) |
| the map | `campaign/maps/cloud_plateau.json` (`campaign:cloud_plateau`), written by `tools/campaign/make_cloud_plateau_map.py`; opens in the MAP EDITOR |
| the stills (stand-ins) | `campaign/stills/a03_01.jpg` .. `a03_05.jpg`, drawn by `tools/campaign/make_a03_stills.py`; the King's pages reuse `b01_01` |
| texts pt / es | `tools/i18n/campaign/a03_plateau.txt` (then `python3 tools/i18n_build.py`); the Brood a Ninhada / la Nidada, the nest o ninho / el nido |
| the storyline, the hub | `campaign/campaign.json` ("naturalist": missions b01, a03; Lindqvist's lines after a03, by the side and the map) |
| b01's way on | `tools/campaign/make_b01_mission.py`: `"next": {"sire": "a03_plateau"}` |
| the engine | `scripts/campaign/mission_run.gd` (sleep `keep` / `except_kinds`, counter `add_counter`, tally `of`, order `kind`), `scripts/campaign/rebels.gd` (roles `linnea_grown`, `guide`) |
| test | `tools/test_campaign_a03.gd` (`godot --headless --fixed-fps 30 --script res://tools/test_campaign_a03.gd`) |
| balance | `tools/sim_campaign_a03.gd` (`-- [active] [side=party|nest] [route=stair|split] [map=drawn|withheld] [saved=..] [eggs=..] [turtle=..] [rival=..] [teles=..] [diff=..] [none]`) |

## The map: the cloud mountain (128 x 112, the jungle biome)

- SOUTH: a river along the bottom and BENEDITO'S LANDING, a sand beach with his canoes (Part 3's exit); the party's camp
  above it with the SUPPLY CACHE (a Powder Wagon, pinned: the musketeers refill there).
- THE FOREST AT THE FOOT: dense trees, trails from the landing to the two ways up, and along the foot.
- THE CLIFF: the plateau is the high ground, a cliff all round, climbed by two ramps: THE WATERFALL STAIR (south-west,
  beside the falls of the river's source) and THE SPLIT IN THE ROCK (south-east, at the end of a narrow cleft between
  two sandstone walls).
- THE TOP: sandstone towers (high rock), black pools, low scrub; the RIVER'S SOURCE in the north-west, its stream
  running south and over the cliff beside the stair.
- THE NEST: a HOLLOW in the north-middle (low ground inside the high), two ramps down into it from the south; the
  Mother is rooted there and her swamp spreads over its floor.
- FOUR SURVEY MARKS (areas): the CAIRN above the stair, the RIVER'S SOURCE, the NEST'S RIM (the high ground south of the
  hollow, looking down into it, about 10 tiles from the sleepers) and the LOOKOUT on the east edge.

## How it plays: THE PARTY (the default side; solo, or versus against the nest)

Opening (the King with the report, then Valadares): he turned north the morning the station burned; three months; the
house of the clouds; five men and the river trader.

- THE SIDES. The party (YELLOW, yours): VALADARES (320 health, pistol and machete), BENEDITO (stays at the landing with
  the canoe), FOUR of the commission's Musketeers, the guides from Nazaré (by b01's `saved`), Teles' six Musketeers
  only if b01's `teles` was told (never, since the flip); 200 powder and the cache. The nest (GREEN, scripted): the
  Mother rooted in the hollow (spared: she is not the party's business), a Rootmaw and grubs (the standard start), SIX
  RAPTORS and TWO SPITTERS ASLEEP round her, a Mound Turtle, LINNEA (grown, at half the Mother's size, spared and
  still: on a team of her own). Two PATROLS of three Raptors walk the top, and from 1:30 three more PROWLERS come down
  from the north rim every 1:40 (at most 9 out) and hunt the party. THE RED PACK (RED, a third side hostile to both: b01's
  rival still standing): three Raptors prowling the forest at the foot.
- THE MIST: everyone's sight halved (0.7 from Part 3).
- "The rains come in 14:00: Benedito will not wait longer" (the raced countdown). "Valadares must live."
- PART 1, THE CLIMB: up by the stair or the split. The guides light the paths (one guide the stair, two the split too;
  none: "we find the way ourselves").
- PART 2, THE SURVEY (on the top): "Valadares stays 40 seconds at each survey mark (n of 4)", any order. At the rim the
  hollow is shown for a minute: the swamp that grows, the huge rooted shape, and LINNEA ("The creature from the pen.
  Twice the size. She knows her home."). WALK SOFTLY (optional): a unit within 6 tiles of a sleeper, or a sleeper hurt,
  WAKES THE NEST: Part 3 at once, the survey cut short (flag `survey` cut), the map's choice still offered.
- THE CHOICE, THE MAP (the survey done, 30 s, default DRAWN): DRAW IT FOR THE CROWN ("a mapmaker who hides a road is no
  mapmaker") or WITHHOLD IT (sealed for the Church: "no man should come here for profit"). Flag `map`.
- PART 3, THE NEST WAKES: the TYRANT SIRE comes home up the way NEAREST Valadares (from the forest trail below it): the
  party must CROSS THE TOP and go down the other way. "Benedito's canoe leaves in 4:30." The nest's Raptors stir 8 s
  later and hunt what is within 22 tiles (the Spitters keep by the Mother, 9 tiles); the patrols and prowlers hunt; the
  Sire climbs and hunts the nearest of the party. "Down to Benedito's landing with Valadares and everyone you can bring":
  everyone who reaches the landing gets into the canoe (an exit, counted); Valadares goes last.
- THE WIN: Valadares at the landing (2 s) once the rest are down or dead, or when the canoe must go: he is safe, the
  canoe pushes off, 5 s later the win. Flag `party` few / some / all (the share of those who went up who came down:
  under half, half or more, all).
- THE DEFEATS (retry): Valadares killed; the rains before the survey is done (the passive player); the canoe gone
  without him.

## How it plays: THE NEST (the solo side pick, YOU PLAY: THE NEST; or the friend in versus)

No creature speaks (b01): the King's two lines in the opening and the ending, objectives and sounds only.

- You are the nest in the hollow: the Mother, a Rootmaw, five grubs (a standard start), 300 food, the six Raptors and
  two Spitters, the Mound Turtle. The Sire is away (no Tyrannosaur of your own: he comes home). No patrols or prowlers
  (they are the party's game); the red pack still prowls the forest.
- THE NEST SLEEPS: your hunters sleep, and every new one with them, until the strangers come within 6 tiles or Part 3;
  the Mother, the grubs, the Rootmaws, the turtles and any father stay awake and work ("Grow the nest").
- The party is scripted: up the stair, the cairn, the source, the rim, the lookout (40 s at each), the map DRAWN at
  once; then the Sire comes home (yours) up the way nearest it, and the party crosses the top and goes down the other
  way to the canoe, the men following Valadares.
- THE HUNT (Part 3): "kill the mapmaker, or bring the strangers under half, before they reach the river": you win when
  Valadares dies or fewer than half of the party are left (on the mountain or down); you lose when he gets down.
- "The Mother must live." A nest win counts for its player (side `nest`, flag `plateau` kept); its ending is the King's:
  "That is not how it went. Valadares came down the mountain."

## The prologue's flags (b01_specimen as rebuilt in 0.38.49) and what they change

A missing flag reads as b01's canon (teles quiet, saved some, eggs left, turtle late, rival standing, Pieter lost).

| b01 flag | value | a03 |
| --- | --- | --- |
| `teles` | told | six of Teles' Musketeers with the party ("he knew what came down from here"); since the flip always quiet, kept for old saves |
| | quiet | only the commission's men and Benedito |
| `saved` | few / some / many | 0 / 1 / 2 guides from Nazaré: one lights the waterfall stair, two the split too; none: Valadares finds the way himself |
| `eggs` | taken | four more young Raptors asleep in the nest (named Young); at the rim: "So the pack carried her eggs up here" |
| `turtle` | early | a second Mound Turtle; at the rim: "A swamp that walked, the doctor's people said. It walked here." |
| `rival` | standing | the red pack prowls the forest at the foot (a third side); Benedito sees the red crests |
| | driven | no red pack |
| `pieter` | alive / lost | a line: Pieter drew her for Valadares / drew her before he was lost, God rest him |
| `clutch` | | not read here (a05's) |

Flags it SETS (kept when won): `map` drawn / withheld, `party` few / some / all (`party_n` the number down), `survey`
full / cut, `linnea` seen, `sire_way` stair / split (which way he came); the nest's win: `plateau` kept, `left` under.
For a05: `map` decides the short way or the long way, `party` the plan's note.

## The engine (small; docs/campaign_engine.md "Added by Act 1's a03_plateau")

- SLEEP `except_kinds` and `keep` (a person's nest: the hunters and every new one asleep, the workers awake).
- counter `add_counter`, tally `of` (shares of another counter: the party's flags hold whatever its size).
- order `kind` (the nest's Raptors hunt, its Spitters stay).
- roles `linnea_grown` (0.5 scale, 1,400 health) and `guide`.
- Everything else was there: `solo_sides` and `foe`, SLEEP / WAKE, MIST, ROUTE / FOLLOW, STAY, SEEN, `if` units,
  `difficulty`, exits and counters, countdowns, choices, `spare` / `cage` / `pin`, the jungle lights.

## The hub

After a03 the Naturalist's hub stays the warehouse at the Barra; LINDQVIST reads the report ("He saw her, grown, among
her own... I must have that mountain"); with the map withheld: "Sealed, for the Holy See. Very well: I have Benedito,
and Benedito remembers"; for a nest winner: "Valadares never came down from the cloud mountain."

## Balance (tools/sim_campaign_a03.gd, NORMAL)

The party's bot walks Valadares by the waypoints (the stair and the marks in turn, or the split first), the musketeers
round him fighting anything within 6 tiles, the guides at his heels, Benedito waiting at the landing; it answers the map;
in Part 3 it crosses the top (by a waypoint south of the pools, away from the hollow) and goes down the way the Sire did
not come. The nest's bot does nothing while asleep, then sends every hunter and the Sire at the nearest of the party
(Valadares when none is near).

| side, run (NORMAL, b01's canon unless said) | result | time |
| --- | --- | --- |
| party, active, by the stair | WON, `party` some (4 of 7) | 5:54 |
| party, active, by the split | WON, all | 5:44 |
| party, active, few saved (no guide) | WON, few (2 of 6) | 5:42 |
| party, active, eggs taken + turtle early | WON, few (3 of 7) | 5:42 |
| party, active, HARD | WON, all | 5:46 |
| party, active, EASY | WON, all | 5:43 |
| party, passive | LOST at the rains | 14:00 |
| party, earlier tunings | the Sire up the stair behind a party already going down the split, the bot won at 3:15 (too cheap); the hunters attacking the rim at once, the party crossing by the hollow: lost in Part 3 | |
| nest, active | WON (the party under half) | 4:43 |
| nest, active, eggs taken | WON | 4:42 |
| nest, passive | LOST: the party came down whole | 5:40 |

Reading: the bot knows the way; a human in the mist explores, so a party player probably takes 10-15 minutes, inside
the 14:00 rains. The survey is quiet but for the patrols and prowlers; Part 3 is the fight: a party that crosses the
top fast and away from the hollow loses a man or three to the prowlers, the stirring Raptors and the Sire; one that
stops to fight loses most of its men. The nest's side is short: the waiting, then a two-minute hunt that a player who
sends everything wins. Speed: the sim runs about 2.5x real time headless.

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as the prologues: an oil painting in the manner of an 18th-century history painting, visible brushwork, 3:2
landscape (cut to 1280 x 853), no text or lettering anywhere. The Crown's soldiers in PURPLE coats; Valadares tall,
weathered, Portuguese-Brazilian, a wide hat, a brass compass on his chest, a machete; the creatures REPTILIAN, olive-brown
scales with VENOM-GREEN frills and spines, never insect-like. Save each as `art/campaign/stills/a03_0N.png` and cut it to
1280 x 853 into `campaign/stills/a03_0N.jpg` (nothing else changes).

- a03_01 THE CLOUD MOUNTAIN. "Oil painting, 18th-century history painting style. Morning on a narrow jungle river in the
  Amazon: a dugout canoe drawn up on a small sand beach; a tall weathered explorer in a wide hat with a brass compass on
  his chest steps ashore, four soldiers in purple coats with muskets and a river trader behind him. Above the forest
  rises a sheer flat-topped sandstone mountain, its top wrapped in cloud, a long waterfall falling from the cloud down
  its cliff. Humid golden light, mist low on the trees. 3:2 landscape, no text." (References: campaign/stills/b01_07.jpg
  (the canoe and the mountain), campaign/stills/p01_05.jpg (the style).)
- a03_02 THE CLIMB. "Oil painting, 18th-century history painting style. A file of men climbs a steep rock stair cut by
  water beside a roaring waterfall on a sandstone cliff, in thick grey mist: soldiers in purple coats with muskets slung,
  a local guide in plain clothes leading, a tall explorer in a wide hat in the middle looking up. Ferns and mosses on
  the wet rock, the forest canopy far below vanishing in cloud. Cool grey light. 3:2 landscape, no text." (Reference:
  campaign/stills/p01_05.jpg.)
- a03_03 THE NEST. "Oil painting, 18th-century history painting style. Seen from a rocky rim in the mist, looking down
  into a wide hollow on a mountain top: a swamp of green water and roots, and rooted in it a huge old reptilian brood
  mother, crocodile- and monitor-like, olive-brown scales, venom-green frills, asleep; lean two-legged reptilian hunters
  asleep curled round her; among them a smaller young brood mother with a green frill, her head raised. In the
  foreground, on the rim, a tall explorer in a wide hat lies flat with a spyglass. Hushed, uncanny, grey-green light.
  3:2 landscape, no text." (References: art/redraws/brood_mother_concept2_chatgpt.png, art/redraws/raptor_walk_se_chatgpt.png,
  campaign/stills/p01_05.jpg.)
- a03_04 THE MAP. "Oil painting, 18th-century history painting style. Dusk on a cloud-wrapped mountain top above the sea of
  cloud: a tall weathered explorer kneels at a flat rock, drawing a map on parchment with a pencil, a compass and a
  spyglass beside it; behind him three soldiers in purple coats keep watch toward a misty hollow; the last sun turns the
  cloud below orange and violet. Thoughtful, grave. 3:2 landscape, no text." (Reference: campaign/stills/p01_05.jpg.)
- a03_05 THE FLIGHT. "Oil painting, 18th-century history painting style. Dusk in a narrow cleft between two sandstone
  walls on a mountain: soldiers in purple coats and a tall explorer in a wide hat scramble down the cleft, one soldier
  turned back to fire; at the top of the cleft, against a red sky and the mist, the head of a colossal tyrannosaur-like
  reptile with green-tipped spines looks down, and lean reptilian hunters pour over the rim. Musket smoke, flying
  stones. 3:2 landscape, no text." (References: art/redraws/tyrannosaur_concept_chatgpt.png, campaign/stills/p01_05.jpg.)

## The voice lines (for the owner's Chatterbox recordings)

Recorded lines go in `campaign/voice/a03/<line id>.ogg` (or .wav / .mp3); the game plays them when present. The King's
in the King's voice (tools/voice_clone, refs king_ref.wav). VALADARES and BENEDITO as designed for b01 (still to
design); THE GUIDE FROM NAZARÉ needs a designed voice; "The Mountain" (the narrator) can stay text. No creature speaks.

| file (campaign/voice/a03/) | voice | when | line |
| --- | --- | --- | --- |
| k_open1.ogg | The King | opening (party) | His first letter came from the burning station. His report came at Christmas, in a waxed case, with a map. |
| k_open2.ogg | The King | opening (party) | The Crown's mapmaker. He wrote as he walked, and he wrote the truth. Let him tell it. |
| v_open1.ogg | Valadares | opening (party) | Majesty. I turned my canoe north the morning the station burned, and followed the tracks up the creek. |
| v_open2.ogg | Valadares | opening (party) | Three months. Benedito knew the mountain from his father: the old people call it the house of the clouds. |
| v_open3.ogg | Valadares | opening (party) | We came to its foot in September, five men and the river trader, to map what no map had. |
| k_open_n.ogg | The King | opening (nest) | No creature wrote a report. But the mountain was theirs before it was anyone's. |
| k_open_n2.ogg | The King | opening (nest) | That September strangers came up their cliff in the mist, while the nest slept. |
| v_1.ogg | Valadares | intro | Up the cliff, before the mist lifts and before the rains. Keep together. |
| b_1.ogg | Benedito | intro | Two ways up, Senhor. The stair by the falls, and a crack in the rock to the east. I wait with the canoe. |
| tip_1.ogg | Valadares | intro | We see little in this mist, and nothing sees us far. Musketeers in front. |
| g_stair.ogg | The guide from Nazaré | guide_1 | The stair by the falls. My grandfather went up there for feathers. |
| g_split.ogg | The guide from Nazaré | guide_2 | And the crack in the rock. Narrow, but a man can climb it with his hands. |
| v_noguide.ogg | Valadares | no_guides | No one from Nazaré would come. We find the way ourselves. |
| v_teles.ogg | Valadares | teles_men | The lieutenant sent six of his men. He knew what came down from here, and he wanted to see it. |
| v_drawings.ogg | Valadares | pieter | I carried the drawings of the creature from the pen, so I would know her. |
| v_pieter.ogg | Valadares | pieter_alive | The doctor's boy, Pieter, drew her for me. A good hand. |
| v_pieter_lost.ogg | Valadares | pieter_lost | The doctor's boy drew her before he was lost. I carried his drawings, God rest him. |
| b_red.ogg | Benedito | red_seen | Red crests in the trees, Senhor. The other pack, the one that fought at the station. It came up here too. |
| tip_cache.ogg | Valadares | cache_tip | The powder is in the cache by the canoe. A man who has fired his shots refills there. |
| v_top.ogg | Valadares | on_top | The top. Rock towers, black water, and the cloud lying on everything. |
| tip_marks.ogg | Valadares | on_top | Four marks to take: a cairn, the river's source, the rim of the hollow, the lookout on the east edge. I stand at each a while to take my bearings. Keep the men round me. |
| v_cairn.ogg | Valadares | mark_cairn | A cairn. Men have been here before us, and long ago. |
| v_source.ogg | Valadares | mark_source | The river's source: a black pool, very cold. The flood that brought the egg down came from here. |
| v_rim.ogg | Valadares | mark_rim | The rim. Below it a hollow, and in the hollow a swamp that grows, and something huge rooted in it. |
| v_linnea.ogg | Valadares | rim_linnea | And there, among them. The creature from the pen. Twice the size. She knows her home. |
| b_linnea.ogg | Benedito | rim_linnea | They sleep, Senhor. Do not wake them. Not one step closer. |
| v_young.ogg | Valadares | rim_young | Young ones, many, still soft. So the pack carried her eggs up here. |
| v_turtle.ogg | Valadares | rim_turtle | Two mounds that breathe. A swamp that walked, the doctor's people said. It walked here. |
| v_lookout.ogg | Valadares | mark_lookout | The lookout. The whole forest to the river, and the crack in the rock below: our way down. |
| v_done.ogg | Valadares | surveyed | Four marks. I have the mountain on paper now. |
| v_choice.ogg | Valadares | surveyed | Now the question I asked myself on that rock: who should have this map? |
| v_choice_run.ogg | Valadares | woke_early | Even running, I knew I would have to decide what to do with what I had seen. |
| v_drawn.ogg | Valadares | surveyed (drawn) | I drew it for the Crown. A mapmaker who hides a road is no mapmaker. |
| v_withheld.ogg | Valadares | surveyed (withheld) | I drew it, and sealed it, for the Church alone. No man should come here for profit. |
| n_roar.ogg | The Mountain | run_e | Below the falls something roared, and the whole hollow answered it. |
| v_run_e.ogg | Valadares | run_e | He is coming up the falls behind us! Across the top, down the crack in the rock! To the canoe! |
| n_roar_e.ogg | The Mountain | run_w | In the crack in the rock something roared, and the whole hollow answered it. |
| v_run_w.ogg | Valadares | run_w | He is in the crack in the rock! Back across the top, down by the falls! To the canoe! |
| v_woke.ogg | Valadares | woke_early | We were too close. They are awake. Leave the survey: down, to the canoe! |
| b_hurt.ogg | Benedito | hurt_v | Senhor, you are bleeding! Let the soldiers stand between you and them! |
| b_rains.ogg | Benedito | rained_out | The rains, Senhor. The river rises. I cannot wait longer. |
| b_push.ogg | Benedito | the_end | In! Push off! Paddle! |
| v_end.ogg | Valadares | the_end | We pushed off with the cloud closing behind us. |
| b_gone.ogg | Benedito | canoe_gone | The canoe is going, Senhor! I cannot hold it! |
| v_end1.ogg | Valadares | ending (party) | We came down to the river with what we had. The mountain kept the rest. |
| v_end_all.ogg | Valadares | ending (party) | Every man who went up came down. I thank God for it in this report. |
| v_end_some.ogg | Valadares | ending (party) | Not every man came down. Their names are at the end of this report. |
| v_end_few.ogg | Valadares | ending (party) | Few of us came down. I write their names first, before the map. |
| v_end_drawn.ogg | Valadares | ending (party) | The map is enclosed, Majesty. The way up, the marks, the nest. The Crown should know. |
| v_end_withheld.ogg | Valadares | ending (party) | The map is not enclosed. I have sealed it for the Holy See. Forgive me. |
| v_end_cut.ogg | Valadares | ending (party) | My survey is unfinished. The nest woke before I could take every mark. |
| v_end_linnea.ogg | Valadares | ending (party) | I saw her, Majesty. The doctor's creature, grown, among her own. She was never his. |
| k_end1.ogg | The King | ending (party) | He did his duty, and told me plainly what he saw. |
| k_end_drawn.ogg | The King | ending (party) | I kept his map. Others bought copies of it from a clerk. That was not his doing. |
| k_end_withheld.ogg | The King | ending (party) | The Church kept his map. The doctor found the way up without it, by a longer road. |
| k_end_n1.ogg | The King | ending (nest) | That is not how it went. Valadares came down the mountain, and his report came to me. |
| k_end_n2.ogg | The King | ending (nest) | But it could have gone that way. Then no one would have known what waited in the cloud. |

## What is placeholder

- Every line, every objective's words, the briefings and the debriefs.
- The stills (simple drawings). Valadares is an Officer, Benedito and the guides Labourers, Linnea a Brood Mother at
  half size (the campaign roles' stand-ins, as in b01). The survey marks are props (a stone cross for the cairn, a watch
  frame for the lookout).
- The voice folder a03 is empty (silent).

## Claude's choices for the owner

1. THE NEST IS SCRIPTED in the party's game, not the Brood computer held back: a scripted sleep, wake and hunt is the
   same every time and never wanders off to build; the computer would plan for a whole map.
2. THE MOTHER IS SPARED in the party's game (the mapmaker has no business killing her, and a dead Mother would end a
   Brood side); in the nest's game she is the nest's to lose ("The Mother must live").
3. BENEDITO WAITS AT THE LANDING ("I wait with the canoe") instead of climbing; he is counted with the party.
4. THE SURVEY is a 40-second STAY at each mark (his bearings), any order; the rim shows the hollow for a minute.
5. WALK SOFTLY is optional: waking the nest early starts Part 3 at once (survey `cut`), it is not a loss; the map's
   choice still comes.
6. THE SIRE COMES HOME UP THE WAY NEAREST VALADARES, from the forest trail below it ("behind them"), so the party must
   cross the top to the other way: the plan's "down the other way". In early tunings he came up the stair behind a party
   already by the split and Part 3 was a walk.
7. THE NEST WAKES SLOWLY: its Raptors hunt 8 s after it wakes, only within 22 tiles; its Spitters stay by the Mother;
   the patrols, the prowlers and the Sire hunt the party. A party that keeps away from the hollow on its way down
   slips past most of them.
8. PROWLERS: three Raptors from the north rim every 1:40 from 1:30 while the nest sleeps (at most 9 out), so the long
   stays at the marks are not safe. The party's game only.
9. THE RAINS (14:00) are the passive player's loss: the survey not done when Benedito will wait no longer.
10. THE PARTY'S FLAG is a SHARE of those who went up (under half few, half or more some, all), so it holds with or
    without guides and Teles' men; the nest's "under half" counts the living on the mountain plus those down.
11. VALADARES GOES LAST: at the landing he stays (the others step into the canoe); once the rest are down or dead, or
    the canoe must go, he is safe (spared and still) and the win comes 5 s later.
12. THE RED PACK is a third side (RED, hostile to both) only in the forest at the foot: a reminder of b01, not a fight
    on the top.
13. LINNEA is untouchable and still (caged, spared, her own team) in both games: the plan has her among them, spared.
14. MODES: solo (either side) and versus (the friend is the nest). No co-op: the party is small, one team.
15. THE NEST'S PLAYER NEVER HAS A SECOND SIRE (no Tyrannosaur on the roster): he comes home in Part 3. Until then only
    grubs, Rootmaws, turtles and a Dilophosaurus' Spitters (if the Mother grows) can be made, and its hunters sleep:
    the waiting is the design (the plan's ambush), the hunt is short.
16. CAMPAIGN DIFFICULTY: EASY / HARD scale the nest's and the patrols' numbers (0.75 / 1.2) for the party's player and
    the party's men for the nest's, and the rains' and the canoe's countdowns (x1.25 / x0.9).

## Tests run

- tools/test_campaign_a03.gd: 195 checks, 0 failures (the data and translations, the line and the way in from b01, the seats
  for each side and versus, the map and the stills; b01's canon and no flags at all, saved few / many, eggs taken, turtle
  early, rival driven, Teles told, Pieter alive / lost; the party played through twice (the map drawn by default and
  withheld; the four marks' 40 s STAY each, the rim's lines, the choice, Part 3: the nest awake, the Sire up the way
  nearest Valadares, the canoe's 4:30, the exit counted, Valadares last, `party` all and few, the win, the ending's
  lines, the progress); the nest woken early; the defeats (Valadares killed, the rains, the canoe gone); the nest played
  (the hunters and a new one asleep, a new grub awake, the scripted party's route and its way down, the Sire yours, the
  win by the party under half and by Valadares killed, the loss when he gets down whole); EASY and HARD (the nest's
  numbers, the rains' and the canoe's countdowns, the player's side never scaled); Lindqvist's lines after it).
- tools/test_campaign.gd: 122 checks, 0 failures. tools/test_campaign_b01.gd: 176, 0 (its storyline check now reads b01
  as the Naturalist's FIRST mission, a03 after it). tools/test_campaign_a02.gd: 139, 0. tools/test_campaign_c01.gd: 243,
  0. tools/test_campaign_m1.gd: 103, 0.
- Boot: Godot Engine v4.7.stable.official.5b4e0cb0f - https://godotengine.org

[session] v0.38.55 menu, no SCRIPT ERROR.
- tools/sim_campaign_a03.gd: the runs in "Balance".
- As before on this cloud machine every headless Godot run ends with "Aborted" (exit 134) AFTER its last line: the
  engine's shutdown here, not a test.
- Not run: the faction and AI tests (no unit, price or skirmish rule changed: the four engine additions act only inside
  a mission that asks for them). Not played on two devices (versus).
