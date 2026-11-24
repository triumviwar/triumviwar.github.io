# Act 2, "Down the Rivers": what was built (job d08-rivers)

Act 2 step 11 (docs/campaign_act2_plan.md "d08_rivers"): the Naturalist line's third mission of Act 2, after d06_queen.
The floods of 2778, three years after the Queen: the swarm comes down the Amazon's rivers, forward Mothers root on every
bank and the towns empty. Valadares, the Crown's officer of the river frontier now, brings the people of Nazaré out and
holds the Barra do Rio Negro on its bluff. At dusk he has Lindqvist's lure book in his hands: THE CHOICE. Valadares
tells it from his report (as in a03); the King frames it. THE BROOD IS NOT A PERSON and LINNEA OK, NO REASONS (owner
2026-11-19, 11-22, 11-24): the swarm is animals coming with the water. Nobody gives a creature a want, a reason or a plan;
the people only say what they see ("they will cross where the river is shallow"). The default side is THE BARRA (the
Crown); the solo pick and versus play THE SWARM. EVERY LINE OF TEXT IS A PLACEHOLDER for the owner.

## Files

| what | where |
| --- | --- |
| the map | `campaign/maps/barra_rivers.json`, written by `tools/campaign/make_barra_rivers_map.py` (`--ascii` prints it, `--areas` the shallows' rows) |
| the mission | `campaign/missions/d08_rivers.json`, written by `tools/campaign/make_d08_mission.py` (edit the script, run it) |
| the stills (stand-ins) | `campaign/stills/d08_01.jpg` .. `d08_04.jpg`, drawn by `tools/campaign/make_d08_stills.py`; the King's pages reuse b01_01 (the King with the mapmaker's report, as a03) |
| texts pt / es | `tools/i18n/campaign/d08_rivers.txt` (written by the mission script; then `python3 tools/i18n_build.py`) |
| the storyline, the hub | `campaign/campaign.json`: d08 joins the Naturalist line after d06 (d06's `next` is d08 for both sides, in `make_d06_mission.py`); a hub after d08, VALADARES' QUARTERS AT THE BARRA (the station painting tinted, Lindqvist's layer hidden), Valadares' talks by side and flags (Lindqvist's hotspot until d08) |
| the war map | `campaign/warmap.json` already had d08's pin and rules (act2-warmap, `tools/campaign/warmap_act2.py`): the upper Rio Negro the Brood's, the Barra Crown / contested by `barra`, ledger lines by `lure` and `nazare`, a swarm's win a broken seal. Checked against the flags set here: they match (the script's comment now says "built") |
| the roster ladder | `tools/campaign/roster_ladder.py`: B6 = d08 (BIGGER CLUTCH, PACK HUNT, QUICK ROOTS), bound team `swarm`, NEW cards at 8 s to the swarm's player only, in pt / es; docs/campaign_roster_ladder.md (its row and the CHECKED TABLE) |
| the roles | `scripts/campaign/rebels.gd`: bank_mother (600 hp, 0.46), barra_sergeant |
| the engine | `scripts/campaign/mission_run.gd`: a count's `"rooted": true` (one line); docs/campaign_engine.md "Added by Act 2's d08_rivers" |
| tests | `tools/test_campaign_d08.gd` (`godot --headless --fixed-fps 30 --path . --script res://tools/test_campaign_d08.gd [-- only=data,flags,part1,part2,part3,defeat,mirror,versus,save,ironman,hubs]`); d08 added to `tools/test_campaign_save.gd` and `.sh` |
| the balance sim | `tools/sim_campaign_d08.gd` (`-- active [side=swarm] [diff=easy/hard] [lure=used] [saved=few/many] [map=withheld] [brood_n=few/all] [clutch=burned] [book=taken] [nohunt] [until=s] [save_at=s] [shots=dir]`) |
| voices | docs/chatterbox_todo.md "d08_rivers" (37 lines with their feeling); tools/voice_clone/emotions.json `d08__<id>` |
| pictures | docs/shots/d08_rivers/ (CHECK THE FEEL, below) |

## The map: the Rio Negro in the floods (128 x 88, jungle, rain)

- THE RIO NEGRO comes down from the north, west of the middle, and bends a little east to meet THE BROWN RIVER that runs
  along the whole bottom: the meeting of the waters.
- WEST of it, THE FAR BANK: várzea (trees standing in pools, mud paths). The plateau's road comes in at its north-west
  corner; three clearings where forward Mothers root (north, opposite Nazaré; the middle; south, opposite the Barra); a
  staging ground for the great wave; THE FAR POINT by the south shallows (the lure post's place); THE FLOODED FOREST in the
  south-west corner.
- THREE SHALLOWS cross the Rio Negro: THE RAPIDS at the very top (into Nazaré), THE MIDDLE SHALLOWS (to the halfway
  landing) and THE BARRA SHALLOWS (into the Barra's lower town).
- EAST, north: NAZARÉ (b01's mission village): the chapel, the houses, the manioc fields, the beach with Benedito's
  canoes.
- EAST, the middle: THE BANK TRAIL down the east bank to the Barra's north gate, the halfway landing; deep forest east.
- EAST, south: THE BARRA DO RIO NEGRO: THE BLUFF (high ground, three ramps: north to the trail, west down to the lower
  town, east to the fields) with the church, the Town Hall, the Barracks, two Farms, a Powder Mill, two cottages and the
  fort's two guns on its west edge; palisades and gates across the three ramp tops; THE LOWER TOWN between the bluff and
  the river (six houses: the quarters, and the landing); THE FIELDS east and THE DOWNRIVER LANDING on the brown river.

## How it plays: THE BARRA (solo; versus p1)

The player has Valadares (a hero: wounded, not killed) and the column at the north gate (6 Musketeers, 2 Dragoons), the
garrison on the bluff (the sergeant and 5 Musketeers), the two guns, 5 Labourers, 500 gold and 200 powder, and the town:
it can train Musketeers at the Barracks and mend the palisade (no Foundry, Armoury, Horse Breeder or new Town Hall here:
the story's deny). The two objectives that lose the mission: THE CHURCH and THE TOWN HALL must stand.

- PART 1, NAZARÉ (the countdown 2:30 on NORMAL; EASY x1.25, HARD x0.85): take the column north up the bank trail. Nazaré's
  people are in three groups (the chapel, the houses, the fields): a man of the Barra standing by a group for 3 seconds
  sends it to Benedito's canoes on the beach by itself (they walk slowly, with their bundles). Raiders come over the
  rapids for the people (at 0:30, 1:15, 2:10). When the countdown runs out the forward Mother across the river ROOTS (her
  swamp creeps toward the water) and a big raid comes; Benedito waits 30 seconds more. The canoes cast off at once when
  every group is away.
- PART 2, THE BLUFF: the column hurries home; five waves come over the shallows a minute apart (the first 45 s after the
  canoes leave, so the column is home first): most over the Barra shallows into the lower town and up the west ramp, some
  over the middle shallows and down the bank trail to the north gate. The guns on the bluff reach the shallows. Two more
  FORWARD MOTHERS walk down the far bank (the first from the plateau's road to the middle clearing, the second from
  there to the clearing opposite the Barra), slowly; each one that roots puts two Raptors more in every wave and spreads
  her swamp. Cross a shallows and kill one on the way (optional; her guard is two Raptors).
- PART 3, THE LURE BOOK: when the last wave is broken (or 75 s after it came), dusk: Benedito brings the book (found in
  the fazenda's ruins; or, d06 `book` taken, left by Lindqvist at the Barra's warehouse for his passage downriver).
  THE CHOICE (75 s, default BURNED):
  - BURN IT (Rome's order): the whole great wave comes over the Barra shallows tonight.
  - USE IT ONCE: Benedito sets a LURE POST on the far point: half the great wave (the half nearer it) turns off its road
    to the post, then into the flooded forest, and is gone; the other half still comes. Then the book is burned.
  Night: the great wave (about 19 creatures on NORMAL, a Brute and the Tyrant Sire among them) gathers on the far bank and
  crosses 20 s later. BREAK IT, or hold until first light (3:00): WON. A wave beaten down to three goes back into the dark
  after 20 s (nobody waits for dawn over a straggler).
- LOST: the church or the Town Hall broken.

## How it plays: THE SWARM (the solo pick, or versus p2)

Two forward Mothers at stage 2: one rooted across the rapids from Nazaré with the Tyrant Sire, the Venom Sire and a Mound
Turtle; the second on the far bank's middle. Grubs, a few Raptors and Spitters, 300 food and 60 spoils, and a trickle of
food (40 every 10 s: the floods' drowned game). Bound to B6: BIGGER CLUTCH, PACK HUNT and QUICK ROOTS are researched on
the Sire's and the Mother's cards (their NEW cards at 8 s).

- NAZARÉ (optional): the scripted Barra's column marches up the trail and the people walk to the canoes by themselves:
  cross the rapids and catch them.
- THE FAR BANK (optional): walk the second Mother down and ROOT her in the clearing opposite the Barra.
- BREAK THE BARRA (the win): kill the two guns on the bluff's west edge and break the church, before the floods fall
  (20:00 on NORMAL, scaled). The scripted Barra holds its bluff (the whole company: 3 / 6 / 10 more Musketeers by
  difficulty, a third gun on HARD), the church is stone here (2,400 health), and three Musketeers come up the river by
  canoe every 1:30.
- LOST: both forward Mothers dead, or the floods fall first.

A swarm's win is not how it went: the King says so, the war map's seal breaks, and d10 is to open with a RECLAIM PART
(the plan's owner question 6).

## The flags read and set

Read (every one has the canon as its default when missing):

| flag | effect |
| --- | --- |
| b01 `saved` few / some (canon) / many | Nazaré's people: 6 / 10 / 14 (in three groups) |
| a03 `map` drawn (canon) / withheld | drawn: Valadares knows the swarm's road (a line, the three shallows pinged and shown at 0:12); withheld: his map is sealed in Rome (a line), the shallows show only as the waves come |
| a03 `party` few | Benedito's line: the last of the plateau's party still on the river |
| a03 `linnea` seen (always) | the King's line in the opening: Valadares had seen the first of them on the plateau |
| b01 `clutch` burned | the swarm one smaller: a few Spitters and Raptors fewer in waves 2 and 4, no Tyrant Sire in the great wave |
| d06 `brood_n` few / some (canon) / all | few: one Raptor fewer in waves 1, 3, 5 and two fewer in the great wave; all: two Raptors more in every wave, three more in the great wave |
| d06 `book` left (canon) / taken | where the lure book comes from (the fazenda's ruins / Lindqvist's passage money) |

Set:

| flag | values |
| --- | --- |
| `nazare` (+ `nazare_n`) | the people brought out as a share of all: few under 50%, some, all from 90% (set when the canoes leave) |
| `lure` | burned (the choice's default and canon; always on a swarm's win and in versus) / used |
| `barra` (+ `barra_n`) | the lower town's six houses standing at the end: held from 75% (five of six), else burned (always burned on a swarm's win) |

## Balance (tools/sim_campaign_d08.gd; the last runs)

The Barra's sim player (`active`): the Dragoons to the fields, the column to the chapel and the houses; home after the
canoes; two thirds of the men at the west gate inside the palisade and one third in the lower town; Musketeers from the
Barracks while the gold lasts; two Labourers mending the palisade and the houses; the column (not Valadares) over the
water after a walking forward Mother. The swarm's sim player: Raptors and Spitters laid at both Mothers, the raiders over
the rapids for the people first, the second Mother walked down and rooted opposite the Barra, then everything at the
guns and the church from 16 creatures. Times are game seconds; "idle" is the longest stretch with nothing to do (the
THREE RULES' 45 s).

| Run (all to the end) | Side, level | Result | Time | Flags | Longest idle |
|---|---|---|---|---|---|
| `active` | Barra, NORMAL | WON | 7:48 | nazare all (10), lure burned, barra burned (4 of 6) | 14 s |
| `active lure=used` | Barra, NORMAL | WON | 7:49 | nazare all, lure used, barra burned (4) | 14 s |
| `active diff=easy` | Barra, EASY | WON | 7:29 | nazare all, barra burned (4) | 14 s |
| `active diff=hard` | Barra, HARD | WON | 8:12 | nazare all, barra burned (3) | 14 s |
| `active diff=hard save_at=200` | Barra, HARD, saved and loaded at 3:20 | WON | 8:08 | the same as without the save | 14 s |
| `active nohunt` (never crosses for a forward Mother) | Barra, NORMAL | WON | 8:08 | both Mothers rooted, bigger waves, barra burned (4) | 14 s |
| `active lure=used saved=many map=withheld brood_n=all clutch=burned book=taken` | Barra, NORMAL | WON | 7:11 | nazare all (14), barra held (5) | 14 s |
| `active saved=few brood_n=few` | Barra, NORMAL | WON | 7:29 | nazare all (6), barra held (5) | 14 s |
| `active low=2` (half the men in the lower town) | Barra, NORMAL | WON | 7:56 | barra burned (4) | 14 s |
| `active low=2 lure=used` | Barra, NORMAL | WON | 7:23 | barra held (5) | 14 s |
| `passive` (does nothing) | Barra, NORMAL | LOST | 7:02 | nazare few (0), the church falls | 113 s (as it should: nobody plays) |
| `active side=swarm` | Swarm, NORMAL | WON | 7:58 | nazare some (7), barra burned | 7 s |
| `active side=swarm diff=easy` | Swarm, EASY | WON | 6:29 | nazare all (10), barra burned | 5 s |
| `active side=swarm diff=hard` | Swarm, HARD | WON | 7:21 | nazare some (8), barra burned | 6 s |
| `side=swarm` (does nothing) | Swarm, NORMAL | LOST at the floods | 20:06 | barra held (6) | 84 s (as it should) |

Every active run is under the THREE RULES' 45 s of nothing to do. The Barra's runs all end at dawn (Part 3's 3:00 clock
after the great wave), so they cluster at 7:10-8:10; the swarm's sim won a little sooner at HARD than at NORMAL (one run each:
noise).

What the sims taught:

- PART 1 was over in under a minute at first (a man NEAR a group sent it at once, and the villagers ran): now a man must
  STAND by a group for 3 seconds and the people walk slowly with their bundles, the raiders come sooner (0:30), and the
  countdown is 2:30. The sim's player still does it in about a minute; a person who goes to the far fields last meets
  the raiders there.
- THE FORWARD MOTHERS first walked a few tiles and rooted at once (the second started next to her clearing): now each
  walks from far up the bank at 0.8 of a Mother's pace (about 70 and 55 seconds): time to cross and catch her. Two
  Dragoons alone die to a Mother and her guard (900 health then): she is 600 health now, and the sim sends the column.
- THE GREAT WAVE left two or three stragglers on the far bank (a path round the várzea), and the player waited for dawn:
  now a wave beaten down to three goes back into the dark after 20 s.
- THE SWARM'S MIRROR was won in under four minutes by a bot that only attack-moves: the scripted Barra now keeps its
  whole company on the bluff, a stone church, canoe reinforcements every 1:30, and the swarm starts with less food and
  fewer raiders; HARD adds four Musketeers and a third gun.
- The dialogue ran up to 30 s behind Part 1's events (the canoes' line after the canoes had gone): Part 1's chatter is
  dropped once Part 2 starts (a line's `until`), Part 2's once Part 3 starts.

## Pictures (docs/shots/d08_rivers/, CHECK THE FEEL)

The sim's `shots=` under xvfb-run at 1280x720, NORMAL, lure used: the start at the north gate, the trail, Nazaré, the
raid, the canoes, Part 2, a forward Mother walking, waves 1 and 3, the night, the dawn. What they showed and what was
done: the Barra's 14 pictures read well at desktop size: the Rio Negro's black water against the jungle, the bluff and the
palisade, the canoes at the landing, the forward Mother walking down the far bank, the waves crossing the shallows and
the great wave drowning in the lured water. Two fixes came from them: Part 1's chatter trailed the events (fixed with
`until`, above) and the swarm's objectives read "(optional) NAZARÉ (optional):" twice (the panel already writes
"(optional)": the word is gone from the three texts). Left as it is: a line can trail an instant choice by a few seconds,
and the supply number drops as houses burn (houses are the Barra's supply). The swarm's 5 pictures (1-5_swarm_*) show
its start between the Mothers, the trail, the far-bank Mother rooted opposite the Barra, Part 2 and the attack on the
guns at night under rain: the creatures are small at 1280x720 against the dark forest floor (the same as d06; the
night tint is light enough to see the rooted Mothers and the guns).

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

- d08_01 THE MEETING OF THE WATERS. "Oil painting, 18th-century history painting style. Where a black river meets a
  brown one, a colonial river town on a bluff with a small fort and a white church; flooded forest on the far bank;
  heavy clouds. 3:2 landscape, no text." (References: b01_02.jpg, a05_04.jpg.)
- d08_02 NAZARÉ. "Oil painting, 18th-century history painting style. Villagers carry children and bundles into long
  canoes on a jungle river; an explorer with a musket holds the bank; in the trees, green shapes. 3:2 landscape, no
  text." (References: a03_04.jpg, b01_07.jpg.)
- d08_03 THE LURE BOOK. "Oil painting, 18th-century history painting style. By a campfire on a riverbank at night a
  weathered explorer holds an old leather book with drawings of creatures; an old boatman beside him; the explorer's
  other hand near the fire. 3:2 landscape, no text." (References: a03_04.jpg, b01_07.jpg.)
- d08_04 THE BLUFF AT FIRST LIGHT. "Oil painting, 18th-century history painting style. Grey dawn after a night battle
  over a colonial river town on a bluff: the fort's flag still flying, smoke rising from burnt houses on the river bank
  below, the dark flooded forest across the black water quiet and empty. 3:2 landscape, no text." (References:
  d08_01 when painted, else b01_02.jpg.)

## The voice lines

docs/chatterbox_todo.md "d08_rivers": 37 lines (Valadares 19, the King 8, Benedito 7, the Barra's sergeant 3) with the
feeling of each; the 34 narrator lines (the Rio Negro) and the three NEW cards can stay as text. Eleven lines have a
preset in tools/voice_clone/emotions.json (`d08__<id>`). The sergeant is a new small part (an old Portuguese-Brazilian
soldier); Valadares and Benedito still need designing (docs/chatterbox_todo.md section 3).

## What is placeholder

Every line of text (en, pt, es). The four stills. The Barra's sergeant has a portrait only by its speaker key (sergeant).
The lure post is act2-engine0's stand-in (a pole and a jar). No new sounds: the forward Mothers and the waves use the
creatures' own.

## Claude's choices for the owner

1. The default side is THE BARRA (the plan's "THE BARRA (Crown, PURPLE, p1)"): the Naturalist's line is told by
   Valadares here, and the player holds the town. The swarm is the solo pick and versus p2, as in d03 / d06.
2. The Barra is a real base (the plan): a Town Hall, two Farms, a Powder Mill, a Barracks, cottages; the player trains
   Musketeers only (the story's deny: no Foundry, Armoury, Horse Breeder, Church, Missionary, Horseman, new hall). The
   Naturalist's line's ladder binds the Brood, not the Crown, so the Barra's list is the story's own.
3. The two lose conditions are the CHURCH and the TOWN HALL (both must stand): the swarm's own target in the mirror is the
   church and the bluff's guns (the plan's "its church and the bluff's guns").
4. Nazaré's people are on a team of their own (yellow, scripted, on the Barra's side): the player never has to steer
   villagers; a man STANDING 3 s by a group sends it to the canoes. Benedito is spared (he is the canoes).
5. Part 1 ends at once when every group is away; else 30 s after the countdown (Benedito "cannot wait longer"); the people
   still ashore are lost (taken off the map: "went into the forest, and nobody saw them again").
6. `nazare` all from 90% (9 of 10, 13 of 14; 6 of 6), some from 50%, few under it.
7. The forward Mothers are an optional objective with a real effect: each rooted adds two Raptors to every wave and
   spreads her swamp. One killed is the objective done; both rooted is failed. They are 600 health (a walking Mother a
   column can kill), with a guard of two Raptors.
8. The waves come at fixed times (a minute apart), not when the last is dead: the player always knows the next is coming
   (NO WAITING both ways).
9. Part 3 starts when the last wave is down to two, or 75 s after it came.
10. THE LURE BOOK: the half of the great wave the lure turns is the half that gathers nearer the far point (`great_a`);
    the lured half is taken off the map once it reaches the flooded forest ("they do not come out of the flooded forest
    tonight"), not killed. With the book burned both halves come.
11. The win is the great wave BROKEN or FIRST LIGHT (3:00), whichever first; a beaten wave's last three go back into the
    dark after 20 s.
12. `barra` held from five of the six lower-town houses standing (the war map's ledger says "every quarter standing";
    one lost house was too harsh for a whole night of waves).
13. In versus there is no choice and no scripted wave: the swarm's player makes the waves; Valadares burns the book (a
    line, the canon) two minutes into Part 2, and the Barra wins if its church and Town Hall stand when the floods fall
    (20:00). A church or hall broken in versus leaves the swarm's flags.
14. The mirror's scripted Barra: the column goes up the trail and back, the people walk to the canoes by themselves (0:20,
    0:28, 0:36), the garrison holds the bluff, canoes bring three Musketeers every 1:30; its church is stone (2,400) and
    its guns 900. The swarm's food: 300 to start and 40 every 10 s (the floods' drowned game), so laying never stalls.
15. The hub after d08 is VALADARES' QUARTERS AT THE BARRA (the plan: "the line's teller changes hands"): the station
    painting tinted, Lindqvist's layer hidden and his hotspot gone; Valadares' talks by `lure`, `barra` and `nazare`
    (twelve entries, one per combination, because a talk says its last entry that holds). Not a Brood hub (never).
16. The vicar of the Barra is not named (d04's Padre Anselmo is the valley's priest in the south).
17. The swarm's mirror is told by the narrator only (no creature speaks or is named); the King's opening says the page is
    "how it would have gone if the bluff had fallen".
18. The forward Mother's role name "A forward Mother" is what Valadares' men call them; no creature here is called
    Linnea (only the King's opening line: Valadares "had seen the first of them on the plateau").

## What is left

- The owner's texts, stills and voices.
- d10_jungle reads `lure` (the lure works once more, then the swarm comes to the smell of it), `barra` (burned: the
  Barra's lower town in ruins; a swarm's win: the RECLAIM PART) and `nazare`.
- The Barra's sim player loses one or two lower-town houses in most runs (`barra` burned): a person who keeps a third of
  his men down in the lower town holds it. If the owner wants "held" commoner, the lower town could get a palisade.

## Tests run

Each in its own data folder (`XDG_DATA_HOME`), headless (exit code 134 is Godot's known abort on quitting; the count
is what matters):

- tools/test_campaign_d08.gd: 0 failures (data, flags, the three parts, the defeat, the mirror, versus, save and load,
  ironman, the hubs).
- tools/test_campaign.gd, _a01, _a02, _a03, _a04, _a05, _a06, _b01, _c01, _d01, _d02, _d03, _d04, _d06, _heroes,
  _ironman, _save (with d08 added): 0 failures.
- tools/test_war_map.gd: 0 failures. tools/test_i18n.gd: no failure printed.
- tools/test_roster_ladder.gd: 0 failures, after one change: its check "her research Quick Roots refused (off every
  Act 1 list)" assumed no Brood mission ever allows Quick Roots; d08's B6 does, so the check now asks for a refusal
  only when Quick Roots is off the mission's list.
- Two failures NOT from this job (main has them too, nothing of d08's touches them): tools/test_campaign_a07.gd "the
  clockmaker line reaches Rome (Act 2 after it)" (d04_concordia needs only d02_exodus, not a07_council by name) and
  tools/test_campaign_m1.gd "no recording yet for Tomasz: the voice hook stays silent" (a recording for him now exists).
- python3 tools/i18n_patch_build.py printed [].
