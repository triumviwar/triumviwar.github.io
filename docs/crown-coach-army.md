# Crown coaching: the army's size and timing (crown-coach-army)

The owner's complaint (2026-11-15 00:28, his watched game on Hollowfen, seed 4287366311, Hard OPTIMAL v Hard OPTIMAL,
v0.38.1; the log is on branch playtest-logs, docs/playtests/2026-11-15_0021_crown_v_clockwork_hollowfen.txt): "Terrible game
from crown ... that is why it can never win, the ai is very bad." This job covers the **army's size and timing** only: in
his game the Crown had 3 Musketeers (180) to the Clockwork's 4 Clock Soldiers at 4:00, 5 to 8 at 5:00, 3 to 11 at 6:00,
while 160 powder lay unused. Four other Crown coaching jobs work on the balloon harass, the defence (crown-coach-defence,
merged as 0.38.4 while this ran; every "before" and "after" number below from 0.38.5 has it in both), the economy and the
Brood matchup. AI only: no unit, building or economy number was changed. The switch `-- crownarmy:off` plays as before.

## When the enemy pushes (measured, 0.38.1, Hard OPTIMAL against the Crown's Hard OPTIMAL, 8 maps x 2 seeds)

| | first push leaves | it brings | at our base (300+ value) | its army 4:00 / 5:00 / 6:00 / 7:00 / 8:00 / 10:00 |
|---|---|---|---|---|
| Clockwork | 4:42-4:52 (its slot B), 5:23-5:43 (slot A); 7:01 and 8:23 twice | 8 Clock Soldiers, 560 (B); 4 + 2 Springers, 515-585 (A) | 16 of 16 games, 6:23 on average, 491 of value against our 606 | 157 / 395 / 707 / 1,155 / 1,786 / 2,622 |
| Brood | 6:30-7:38 (one at 8:30) | 22-31 supply, mostly Raptors (once 51 and 88) | 15 of 16 games, 7:18, 660 against our 774 | 907 / 1,356 / 1,784 / 2,410 / 2,914 / 4,306 |

The Crown against them (the same games): v the Clockwork 176 / 360 / 515 / 759 / 1,143 / 1,403; v the Brood 407 / 643 / 667
/ 740 / 854 / 650. No supply block in any of the 32 games (the Cottages ahead work).

## What was wrong, in plain words

1. **The Barracks stood idle two thirds of the time.** From its first Musketeer (about 1:30) to 6:00 the Barracks was idle
   185-199 s of the 270 v the Clockwork (146 s v the Brood). The gold went first: the labourers are trained in the first
   stage of every think (AICrown._bo_labs), then the Cottages and the next step of the opening (whose price is held from the
   soldiers: the Town Hall step's 400 held the Barracks idle a minute at 4:00 with 190 gold in the bank), and the soldiers
   got what was left. The opening's army caps (8 supply on the Balloon harass until the Foundry and its balloon) held them
   too, while the enemy's army doubled.
2. **"The army first" came too late.** AICrown.army_lags (ai-followups: the labourers and the tech wait for the soldiers
   while the army is under 60% of the enemy's it reckons) only counted from the SECOND hall and 22 labourers on: about 5:10,
   after the Clockwork's first push had left home. Nothing held the labourers for the soldiers before it.
3. **The Mill kept one hand while nothing could train.** The Powder Mill's crew grows only while a Barracks or Foundry is
   training (AICrown._mill_feedback: "powder is wanted only while something trains with it"); with the bank under a
   Musketeer's 10 powder nothing could train, so the crew stayed at one: a deadlock. The first Musketeer came at 3:03-3:30
   (the Clockwork's first Clock Soldier at 3:00-3:18).
4. **A Church before the first push.** The natural's wall plan (AIExpandWall) fills its wall slots with buildings and bought
   a Church (150) for one at ~5:20: two and a half Musketeers, just before the Clockwork's push.

## What changed (scripts/ai_crown_army.gd, AICrownArmy; small hooks in ai_crown.gd and ai_expand_wall.gd)

1. **The army clock.** From 2:30, with 10+ labourers, the Crown's army (with what its Barracks and Foundries train; balloons,
   wagons and horses do not count) is kept at 75% of the army a Hard computer of the enemy's faction usually has at that
   minute (AICrownArmy.TABLE, measured above: Clockwork 150 at 4:00, 400 at 5:00, 700 at 6:00, 1,100 at 7:00, 1,600 at
   8:00, 2,400 at 10:00), or 60% of what it saw lately if that is more, less half what it has killed. While it is behind
   ("the army on time: ... soldiers before more labourers"):
   - in the opening a labourer is trained only while every Barracks is busy (AICrown._soldiers_first), the opening's army
     cap does not hold, and the soldiers start at once if the plan's "army" step has not come yet (a Barracks standing);
   - the opening's next step leaves a Musketeer's price for each idle Barracks out of the gold it holds;
   - after the opening, army_lags ("the army first") counts from one hall on;
   - the natural's wall plan buys no Church for a slot.
2. **Powder for the first Musketeers.** A Barracks idle with a Musketeer's gold but not his powder counts as using the powder,
   so the Mill takes its second and third hands (AICrown._mill_feedback).
3. **Gated by matchup**: the Clockwork and the Crown mirror only. Against the Brood the Crown already reckons the Brood's army
   (army_behind, brood_spend_army: crown-v-brood-coach), and the Brood coaching job works there now; a Crown that kept 75%
   of the Brood's usual army (1,350 at 5:00) would never train another labourer.

Switches: `-- crownarmy:off` (all of it), `-- crownarmy:share=0.9` (the share, for studies).

## The owner's game again (Hollowfen, filmed: tools/shot_ai_match.gd, pictures in docs/shots/crown_coach_army/)

The headless game with the owner's seed picks the Timing attack; seed 1 (the Crown in slot A, both OPTIMAL) picks the
Balloon harass and plays the owner's game: the Clockwork's 8 Clock Soldiers leave at 4:30-4:39.

| 0.38.5 | 4:00 | 5:00 | 6:00 | 7:00 | kills / losses by 7:00 |
|---|---|---|---|---|---|
| before (`crownarmy:off`) | 2 Musketeers v 4 Clock Soldiers | 4 v 10 | 5 v 14 | 5 (and a Missionary) v 14 + 2 Springers, a Netter | 1 / 6 |
| after | 2 v 4 | 6 v 10 | 8 v 9 + a Netter | 11 v 8 + 3 Springers, a Netter, a Brass Serpent | 10 / 3 |

Before, the powder piled up to 200 unused by 7:00 and the Clockwork was at the natural at 6:17-6:32, a building burning
(before_0617_push_at_natural.jpg, before_army_0632.jpg). After, the line holds the ramp and the natural with Clockwork wrecks
in front of it (after_army_0632.jpg), the balloon's basket fires down on the push at home (after_0523_balloon_over_push.jpg,
after_0549_push_beaten.jpg).

## The batches (tools/study/crown_army.py with tools/measure_crown_army.gd; Hard OPTIMAL v Hard Clockwork OPTIMAL, 8 maps
(Greenhold, Dune Sea, Hollowfen, Kestrel Rise, Ashford Crossing, Red Coast, Frostmere, Border March), the Crown in slot A on
odd seeds (it picks the Balloon harass), slot B on even ones (the Timing attack), to 15:00)

__BATCHES__

## Tests

__TESTS__

## Claude's choices for the owner

1. **75% of the enemy's usual army** (SHARE). Higher keeps more soldiers early and fewer labourers; the switch
   `crownarmy:share=` lets a study try 0.9 or 1.0. The table is the Hard OPTIMAL computer's median; against a human who pushes
   earlier the "what it saw" part (60%) takes over only once it is seen.
2. **From 2:30** (FROM), never before 10 labourers: the opening's first minutes stay the economy's, as the owner's openings
   want (no soldiers before the scout's read in OPTIMAL's common opening).
3. **Not against the Brood** (see above). The Brood's usual army is in the table above if the owner wants it on there too.
4. **The step's gold**: only a Musketeer per idle Barracks leaves the opening's next step while behind; the step (a hall, the
   Foundry) is late by seconds, not skipped.
5. **The Church in a wall slot waits** while behind; other wall-slot buildings (Cottages, Barracks) are as before.
6. Not changed (other jobs' areas or numbers): the balloon parties taking Musketeers from home (balloon harass job), the
   Crown's lower income (the Clockwork earns 1.6-1.9 times as much by 8:00: the economy job), the Foundry idle for want of the
   Horse Breeder's horses before ~5:30 (the Foundry-first rule), the powder bank against the Brood.
