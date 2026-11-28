# Act 3, "Brazil After the Fires": what was built (job e01-brazil)

Act 3 build step 4 (docs/campaign_act3_plan.md "e01_brazil", THE AMERICAS theatre's opening; the owner's answers to the
plan's 15 questions all as recommended). Brazil, 2781. At the São Francisco the player chose which fire to fight first
(d09 `first`, the crossing's choice: no canon). The front fought SECOND has grown past holding. General Ruggieri cannot
win the colony back this year; he can bring its people out to the ships. He tells it in his dispatch to Rome; the King
frames it ("It left Brazil in our own ships... But first Brazil itself.").

The mission comes in TWO VERSIONS, each on its own map (the new engine piece, `version_data`, below):

- THE SOUTHERN ROAD (d09 `first` = brood: the swarm was fought first, so the city had a year). Concórdia's machines come
  down the highlands; the valley's people go down the Serra to the sea at Santos. The DEFAULT when the flag is missing
  (as d10's FRESH: a player who never played d09 gets this one). Map `campaign:brazil_south`.
- THE RIVER ROAD (d09 `first` = clockwork: the city was fought first, so the swarm had a year). The swarm comes down the
  levee from upriver; the river towns' people go down the Amazon. Map `campaign:brazil_river`, the jungle day light.

EVERY LINE OF TEXT IS A PLACEHOLDER for the owner to rewrite.

The rules it keeps. THE BROOD IS NOT A PERSON: the swarm "comes down the rivers with the flood", "comes after the
families", "there are more of them in the pass": no want, no plan, nobody names a creature (the plan's "they got ahead
of you and hold the pass" was rewritten so it gives the swarm no plan). WORLD LORE: nobody gives the machines a will
either: the city's works "never stopped", its machines "come out of the gates". THE CROWN AND THE CHURCH ARE THE GOOD
SIDE: the army goes backwards to save people, Ruggieri counts them aboard "for the King, not a guess", the guns are
spiked on the bluff and the army goes down to the boats last; São Rafael's people "still sing at Vespers". LOCAL PEOPLE
ARE MINOR: Arruda 3 lines, Hollins 2, the Barra's sergeant 1, Teixeira 1. NO BROOD HUB OR WAR MAP: the mirror is "The
Road" (a narrator), never the swarm's voice. THE THREE MISSION RULES: below ("How it plays", "No waiting", "Looked at").

## Files

| what | where |
| --- | --- |
| the maps | `campaign/maps/brazil_river.json`, `campaign/maps/brazil_south.json`, written by `tools/campaign/make_brazil_retreat_map.py` (`--ascii river` / `--ascii south` prints them) |
| the mission | `campaign/missions/e01_brazil.json`, written by `tools/campaign/make_e01_mission.py` (every number at its top) |
| the texts in pt/es | `tools/i18n/campaign/e01_brazil.txt` (written by the generator), built into `scripts/lang/` by `python3 tools/i18n_build.py` |
| the ladder rung | `tools/campaign/roster_ladder.py` (C10 THE DRUMMER: its card in en/pt/es, BOUND e01 -> crown `column`, the card at 0:08) |
| the engine piece | `scripts/campaign/campaign.gd` `version_data` (+ make_cfg, problems), `scripts/campaign/mission_run.gd` setup, `scripts/campaign/campaign_menu.gd` the briefing's map |
| the stills (stand-ins) | `campaign/stills/e01_01..04.jpg`, drawn by `tools/campaign/make_e01_stills.py` |
| the map pictures | `assets/maps/campaign_brazil_river.png`, `campaign_brazil_south.png` (`tools/make_map_previews.gd -- campaign:brazil_river campaign:brazil_south`) |
| the test | `tools/test_campaign_e01.gd` (data, versions, flags, the three parts, defeat, the fire, save/load both versions, ironman, hubs) |
| the sim | `tools/sim_campaign_e01.gd` (`careful` / `late` / `passive`, `side=fire`, `diff=`, the flags `first= jungle= siege= fields= barra= families= colonists=`, `save_at=`, `shots=`) |
| the pictures | `docs/shots/e01_brazil/` (south) and `docs/shots/e01_brazil/river/` |
| campaign.json | e01 added to the prologue storyline's missions after d11_siege, and four hub talks (the King after it: many / some / few; Ruggieri's dispatch) |

## The engine piece: a version's own map (`version_data`)

Act 2's versions (MissionAct2) changed numbers and units on one map. e01's two roads are two different countries, so a
version now carries its own data: `"version_data": {"river": {"map": "campaign:brazil_river", "areas": {...}, "teams":
{"fire": {"faction": "brood", "colour": 2}}, "light": "jungle_day"}}`. Campaign.version_data(m, ver) lays it over the
mission (the map and any top-level key replaced, the named areas replaced, the team merged), and the match
(Campaign.make_cfg), the run (MissionRun.setup) and the briefing's picture all read the laid mission. Every area name is
the same on both maps, so every trigger is written once. Campaign.problems checks it. docs/campaign_engine.md has the
row.

## The maps (192 x 96 each)

- `brazil_river`: d10's Óbidos front (144 x 96, VÁRZEA) and 48 columns more to the east: the levee road under Óbidos
  runs on east to a PORT ON A NECK of high ground (a bluff, two ramps up, the quay on its seaward side, water north,
  south and east). The ford is d10's creek crossing; the outposts (op, op2) are west of it; Óbidos town is the middle
  group's start, a hamlet the third's; the pass is a cut in the levee forest east of Óbidos.
- `brazil_south`: d11's siege of Concórdia (the city kept on the plateau, moved 80 columns east) and 80 columns of
  highland west of it: the stream before the city is the ford, the road runs west through the SERRA PASS (rocks and
  trees narrow it) down to the port on its bluff by the sea (the quay west of it). The batteries of d11 are the outposts.

One area name, two rects (make_brazil_retreat_map.AREAS): edge, op, op2, ford, ford_far, ford_hold, muster, col_start,
hamlet, town, pass_at, pass_wait, r1-r6 (the road), flank_a-c (the raids' woods), bluff, bluff_front, bluff_mid,
guns_1/2, fort_at, barracks_at, quay, quay_in, port, sea.

## How it plays: THE ARMY OF BRAZIL (solo; co-op p1; versus p1)

The army: Ruggieri (a story hero: wounded, not killed), THE DRUMMER (NEW, C10), 8 Musketeers and 4 Guardsmen, 3 Dragoons,
2 Field Cannons, the Powder Wagon; the Virginia Volunteers (Hollins + 3, p01 `families` not left); Fort Constantine's
men (Teixeira + 3, d09 `fort` held). Matchlock, bayonet, the charge, armour, prepared charges and the quadrant known. No
base: no Town Hall, Farm or Labourer (the ladder's story deny); 250 gold and powder; the Wagon is the magazine.

PART 1, THE FRONT BREAKS (a 3:20 countdown, not scaled). Hold the ford with the line and the guns. At 0:18 the
outposts fall back over it with their families (they are YELLOW people on their own team, walking on their own; cover
them: OUTPOSTS n of 7 across). Four waves come at the ford (0:35, 1:20, 2:05, 2:45; the later two bigger).

PART 2, THE COLUMN. "The front breaks. Everybody walks." The people set out in three groups (the outposts', the town's,
the hamlet's). ALONE A GROUP ONLY WALKS (35% of a Labourer's pace); with THE DRUMMER within six tiles it keeps the army's
pace (62%). He is one man; the player walks him from group to group (C10's lesson: "Keep the drum where the children
are"). Raids come out of the woods at the people (4, at 0:22, 1:08, 1:54, 2:40 of the part), the pursuit comes down the
road behind (3 waves, from 0:30, every 0:45: THE REARGUARD), and there are more of them in THE PASS on the road ahead:
the groups stop before it and wait until it is clear (or 1:50 at most: NO WAITING, then they go into it).

PART 3, THE SHIPS (3:00, not scaled). The first group into the port starts it (or 5:00 after Part 2). Hold the bluff
before the quay (three assaults); the port's Barracks is the army's (the treasury, 400 gold and 150 powder, "will not
sail with us"); every group must be on the quay. Once every group still walking is aboard, the last boats wait 0:45
for the army. The harbour fort (3,000 health) must stand.

WON: at least two in five of the people aboard and the fort standing. LOST: fewer, or the fort broken.

## Co-op and versus

CO-OP: p2 is THE MILITIA (BLUE): the outposts' men, then the Barra's garrison (river, d08 `barra` held: the sergeant +
4; burned: 2) or the valley's militia (south: Captain Arruda + 2, + 3 militia and 2 ranchers if d04 `colonists` fought).
Without a second player they are scripted (they fall back with the outposts and hold the ford).

THE MIRROR (solo pick, "The Fire Fought Second") and VERSUS p2: THE FIRE (the swarm, GREEN, on the river; the machines,
RED, on the southern road), told by "The Road". Its start army comes out at the edge, more of its own every 0:40; the
army of Brazil is scripted when nobody plays it (it holds, walks the road, its riders cover the flanks, the line holds
the bluff). CATCH THEM ON THE ROAD: keep more than half of the people from the ships, or break the harbour fort. The King:
"That is not how it went. Ruggieri brought them to the ships. But I have kept this page."

## The flags read and set

| read | effect |
| --- | --- |
| d09_crossroads.first | clockwork = THE RIVER ROAD; brood or missing = THE SOUTHERN ROAD |
| d09_crossroads.fort | not fallen: Fort Constantine's men march with the army (Teixeira + 3) |
| d09_crossroads.sertao | many: 2 more people (the sertão's people saved at the fort) |
| d10_jungle.jungle | thin: the swarm's waves one bigger (river) |
| d10_jungle.island | standing: a Venom Challenger more in the river's assaults |
| d11_siege.siege | held_off: the machines' waves bigger and a Ballista with the hard waves (south); close: no Ballistas |
| d05_aldeia.fields | not burned: São Rafael's people walk with the river column (3 more); burned: Ruggieri says so |
| d08_rivers.barra | held: the Barra's sergeant + 4; burned: 2 |
| d08_rivers.nazare | all / some: Nazaré's people in the river town's group (+2 / +1) |
| d04_concordia.colonists | fought: the valley's militia march gladly (+3, + 2 ranchers); parley: a few (Arruda says so) |
| d07_spring.honest | many: the honest masters' families on the southern road (+2) |
| p01_leaf.families | not leave: the Virginia Volunteers (Hollins + 3) |

| set | values |
| --- | --- |
| `colonists` | few / some / many (aboard under 50% / 50% / 80% of the people), and `colonists_n` (the number) |
| `ruggieri` | alive (he is a story hero: wounded, never killed) |
| `version` | south / river (the version played) |
| (inside) `share` lost / saved, `f_share` fire / column | the win and the mirror's win |

## Balance (tools/sim_campaign_e01.gd; the last runs)

Each run plays the whole mission (`tools/sim_campaign_e01.gd`, one sim a cell, its own user folder). "careful" holds
the ford, walks the Drummer to the slowest group, sends two thirds of the line at the pass, trains at the port's
Barracks; "late" does the same but slower to react; "passive" gives no order at all. Aboard = people aboard of all.

| run | road | difficulty | result | aboard | time | the fort at the end |
| --- | --- | --- | --- | --- | --- | --- |
| careful | south | NORMAL | WON, many | 18 of 19 | 5:40 | 3,000 |
| careful | river | NORMAL | WON, many | 19 of 22 | 5:59 | 3,000 |
| careful | south | EASY | WON, many | 18 of 19 | 5:41 | 3,000 |
| careful | south | HARD | WON, many | 17 of 19 | 5:45 | 2,868 |
| careful | river | HARD | WON, some | 12 of 22 | 6:02 | 3,000 |
| careful | river | BRUTAL | WON, some | 11 of 22 | 5:54 | 2,905 |
| late | south | NORMAL | WON, many | 16 of 19 | 7:09 | 2,971 |
| late | river | NORMAL | WON, some | 15 of 22 | 7:12 | 2,986 |
| passive | south | NORMAL | LOST | 5 of 19 | 7:26 | 2,719 |
| passive | river | NORMAL | LOST | 7 of 22 | 6:52 | 2,972 |
| careful, jungle thin, Barra and fields burned | river | NORMAL | WON, some | 14 of 19 | 5:58 | 3,000 |
| careful, families left, the valley fought | south | NORMAL | WON, many | 19 of 20 | 5:40 | 3,000 |
| THE FIRE (a bot that waits out of the guns' reach, then goes for the people) | south | NORMAL | WON for the fire | 5 of 19 | 5:42 | 3,000 |
| THE FIRE (the same, families left) | south | NORMAL | WON for the fire | 9 of 20 | 5:33 | 3,000 |
| THE FIRE (the same) | river | NORMAL | WON for the fire | 7 of 22 | 5:47 | 2,931 |
| THE FIRE (a bot that throws itself at the ford) | south | NORMAL | LOST for the fire | 14 of 19 | 5:31 | 3,000 |
| careful, saved at 2:30 and loaded (SIM LOAD SAME yes) | south | NORMAL | WON, many | 18 of 19 | 5:41 | 3,000 |
| careful, saved at 4:20 and loaded (SIM LOAD SAME yes) | river | NORMAL | WON, many | 18 of 22 | 5:55 | 3,000 |

(The rows with the flags, EASY, HARD south, BRUTAL and the save runs were run before the port's quarters were added: the
quarters only let the army train at the port in Part 3, so those rows can only be better now.)

The river road is the harder one at HARD (the swarm's Raptors run the column down on the road; the machines are slow):
a careful player brings "some" there, about half. Earlier runs found the army unable to train at the port (no supply on the road: five Cottages, the army's quarters, now stand on each port's bluff), the harbour fort falling to one assault (1,600 health: now
3,000), the passive player winning with a third aboard (the line now two in five), and the southern HARD army dying
at the pass (its ambush made one Clock Soldier smaller, the HARD Pendulum gone).

The longest idle stretch in any run: 42 s (the passive run waiting for the ships with nobody walking; every playing run 19-28 s; the fire's 37 s) (NO WAITING: under 45 s).

## Pictures (docs/shots/e01_brazil/, CHECK THE FEEL)

`tools/sim_campaign_e01.gd -- careful shots=docs/shots/e01_brazil` (under xvfb, 1280 x 720; `first=clockwork
shots=docs/shots/e01_brazil/river` for the river road): 1_start (the army at the ford, the NEW card), 2_fall (the
outposts fall back), 3_ford and 4_ford2 (the waves at the ford, canister), 5_drum / 6_break (the front breaks, the
groups set out with the Drummer), 7_raid (a raid out of the woods on the column), 8_road / 9_road (the road, the
pass), 9_port / 8_port (the port, its quarters, the Barracks training), 10_assault (the bluff), 11_quay (the people
counted aboard), 12_sail (the ships sail: WON).

## Stills: the prompts for the owner (ChatGPT, one request each, at most 3 reference images; each prompt stands alone)

House style as Act 1: an oil painting in the manner of an 18th-century history painting, visible brushwork, 3:2
landscape (cut to 1280 x 853), no text. Save each as `art/campaign/stills/e01_0N.png` and cut it into
`campaign/stills/e01_0N.jpg`. The stand-ins in the game now are drawn in code.

- e01_01 THE COLUMN. "Oil painting, 18th-century history painting style. A long column on a red dirt road through green
  tropical hills toward a distant sea with two sailing ships: soldiers in purple coats, a mounted general with a grey
  moustache, carts, a limbered cannon, and colonial families walking with bundles, children and a drummer boy beside
  them. Dusty afternoon light. 3:2 landscape, no text." (References: campaign/stills/p01_03.jpg, campaign/stills/d09_01.jpg.)
- e01_02 THE BLUFF. "Oil painting, 18th-century history painting style. At sunset a line of soldiers in purple coats and
  two cannons hold a grassy bluff above a harbour; below, rowing boats full of colonists pull out to three tall sailing
  ships at anchor; smoke drifts over the bluff. 3:2 landscape, no text." (References: campaign/stills/a06_02.jpg,
  campaign/stills/p01_05.jpg.)
- e01_03 THE FORD. "Oil painting, 18th-century history painting style. Misty morning at a wide shallow river ford in
  tropical country; on the near bank a line of soldiers in purple coats with a cannon; colonial families wade across
  toward them, holding children up out of the water; on the far bank dark shapes move in the trees. 3:2 landscape, no
  text." (References: campaign/stills/d08_02.jpg, campaign/stills/d10_01.jpg.)
- e01_04 THE COUNT. "Oil painting, 18th-century history painting style. On a crowded stone quay a grey-haired general in
  a purple coat writes in a small book while colonists, women and children with bundles, climb down into boats toward
  two sailing ships; a priest blesses them. Cold bright light over the sea. 3:2 landscape, no text." (References:
  campaign/stills/d09_03.jpg, campaign/hub/rome_tomasz.png.)

(The opening also shows p01_01, the King at the war map, as every Act's frame.)

## The voice lines

docs/chatterbox_todo.md "e01_brazil": 38 spoken lines (General Ruggieri 23, the King 8, Captain Arruda 3, Sergeant
Hollins 2, the Barra's sergeant 1, Major Teixeira 1) with the feeling of each; the 31 narrator lines ("Brazil", and
"The Road" for the fire's player) and the NEW card can stay as text. Voices to design: Hollins grown (p01's family's son)
and Teixeira (d09's fort commander). The three end lines carry the number ({aboard} of {people_n}). No emotions.json
presets were added (the narrator and the King's strongest lines are plain; add `e01__<id>` presets when recording).

## What is placeholder

Every line of text (en, pt, es). The four stills (drawn in code). The people are the Villager (river) and Colonist
(south) art; Hollins is the Virginia sergeant's art, Teixeira the fort commander's; the port's fort is a Town Hall at
3,000 health, its Barracks the Crown's; the ships are the map's boat props on the water; the boats at the quay are
not drawn (the people walk onto the quay and are counted aboard).

## Claude's choices for the owner

1. A VERSION'S OWN MAP (`version_data`, the engine piece above) rather than one map with both roads on it: the two
   roads are a thousand leagues apart, and one area name a road keeps the triggers written once. Any later mission can
   use it (e03's Virginia, the night's ports).
2. THE MAPS ARE d10's AND d11's GROWN: the river road starts at d10's ford under Óbidos; the southern road starts at
   d11's siege lines before Concórdia. The player retreats over ground he fought for the year before. The ports are new
   land added at the east (river) and west (south).
3. THE DEFAULT IS THE SOUTHERN ROAD (d09 `first` missing): as d10's FRESH, the brood-first branch is the default.
4. THE PEOPLE ARE ON THEIR OWN TEAM (YELLOW, scripted) and walk by themselves in three groups on set roads; the player
   cannot order them. What the player moves is the army, and the Drummer.
5. THE DRUMMER'S LESSON IS THE PACE OF THE PEOPLE, by the mission: a group with the Drummer within six tiles walks at the
   army's pace (62%), alone at 35%. His ring's real buff (+5% to soldiers, SOLO) stays as in skirmish; the people are
   not soldiers, so the mission sets their pace (triggers drum_on / drum_off for each group).
6. THE PASS AMBUSH: the people stop before it and wait until it is clear (the plan's "the swarm got ahead"). They wait
   1:50 at most (NO WAITING), then go into it. The ambush hunts the people once they go through.
7. THE PORT'S TREASURY: 400 gold and 150 powder and a Barracks of the army's own at the port in Part 3, so the player
   rebuilds a line for the bluff (no Town Hall, no economy: "it will not sail with us").
8. THE LAST BOATS: once every group still walking is aboard, the ships wait only 0:45 more for the army (NO WAITING).
9. THE HARBOUR FORT has 3,000 health (a Town Hall's 1,600 fell to one assault in the first runs): it is a stone fort.
10. THE WIN LINE IS TWO IN FIVE ABOARD (LOSE_SHARE 0.4): a player who does nothing brings about a third to the ships
    by the people's own walking and loses; few / some / many at 40% / 50% / 80%.
11. RUGGIERI IS A STORY HERO (wounded, never killed: "Help me onto the gun carriage and keep walking"). `ruggieri` is
    always alive; the flag is set for the later missions.
12. THE COUNTDOWNS ARE NOT SCALED by difficulty (a longer hold is no easier); difficulty changes the waves (NORMAL +,
    HARD ++), BRUTAL as Campaign.level.
13. THE RIVER'S FIRE IS THE BROOD, the south's the Clockwork, set by `version_data`'s team; the mirror's side is named
    "The Fire Fought Second" so one solo pick serves both.
14. THE ARMY'S TECH: matchlock, bayonet, the charge, armour, prepared charges and the quadrant are known (C5-C9 earned;
    the army of 2781 has them).
15. FORT CONSTANTINE'S MEN and THE VIRGINIA VOLUNTEERS march only if their flags allow; Fort Constantine's commander is
    named TEIXEIRA here (the d09 build left him unnamed; proposed).
16. THE PORT'S QUARTERS: five Cottages of the army's stand on each port's bluff from the start (40 supply + the fort's
    10), so the army's 39 fit and the port's Barracks can train. Without them the HUD showed 39/10 in red all mission.
17. THE MIRROR'S STRENGTH: the fire's own waves every 0:40 (8 Raptors and 3 Spitters on the river; 8 Clock Soldiers,
    4 Springers and a Winder on the road south; from 3:20 a Tyrant Challenger or a Pendulum), its start army as the
    plan's. A fire player who waits out of the guns' reach and goes for the people wins; one who throws itself at the
    ford loses.
18. THE PLAN'S `colonists` names stay: few / some / many and `colonists_n`; THE FINALE'S LEDGER can read `colonists`
    many as a mark.

## Looked at (CHECK THE FEEL)

Every picture above. The scale is right (the people walk among the soldiers at their own size; the Cottages and the fort
on the bluff read as a port's buildings); the swarm's Raptors and the Clock Soldiers come at the ford as one body. Found
and fixed while looking: the supply read 39/10 in red all mission (the port's quarters added); the harbour fort's
objective stayed unticked at the win (now done with the ships). Left as it is: in Part 2 the objective list grows long
on a 1280 x 720 screen (seven lines; it folds as each is done, as in every mission); the river port's sea east of the
quay is three columns wide, so the camera at the quay shows the map's edge; the Part 1 "fall" picture looks at the far
bank where the outposts were, after they had come over. Dramatic lines for emotion (marked in the voice table): r_open1,
r_end_few, r_end2, k_end1. Orders stick: the people keep their roads after a load (the save runs: SIM LOAD SAME yes).

## What is left

- The owner's text (every line), the stills, the voices.
- A boat-loading look at the quay (people now walk onto it and are counted).
- The war map's Act 3 pin for e01 is the act3-warmap job's (this job did not touch the war map files).

## Tests run

- `tools/test_campaign_e01.gd`: 93 checks, all pass (data, both versions' maps and areas, every flag above, the three
  parts, the defeats, THE FIRE solo and versus, SAVE/LOAD in both versions on their own maps, ironman, the hubs).
- `tools/test_campaign.gd`, `tools/test_roster_ladder.gd`, `tools/test_act3_engine0.gd`, `tools/test_map_previews.gd`,
  `tools/test_i18n.gd` (pt and es: 0 of 428 untranslated): pass.
- `tools/test_campaign_d10.gd`, `tools/test_campaign_d11.gd`: pass but one check, "the war map's data has no problem:
  mission e01_brazil has no pin on the war map". The war map's files belong to the act3-warmap job (this job must not
  touch them); its branch already has the e01 pins, so the check passes once both are merged.
- Boot check (`godot --headless --path . --quit-after 120`): no SCRIPT ERROR, no Parse Error.
- The sims in "Balance" above (16 runs at the end, more on the way).
