# The Crown computer's economy in games, coached (job crown-coach-economy, 2026-11-15)

The owner (2026-11-15 00:28, about his Hollowfen game, Hard OPTIMAL v Hard OPTIMAL, 0.38.1, seed 4287366311): "Terrible
game from crown ... the ai is very bad. You need to do multiple coaching jobs on crown." This job is the ECONOMY one of
five Crown coaching jobs running side by side (the others: balloon harass, defence, army size, v Brood). It changed only
how the Crown computer runs its economy: no unit, building, price, yield or rule number, and no army production rule.
Design rules followed (docs/design_principles.md): 2 (exposed income that pays) and 4 (every choice has an opportunity
cost: a Farm hand repays his 50 gold in 42 s; a Mill hand grinds a quarter of what a Farm hand grows).

## In short

1. **The "efficiency" line in the match log is not the Crown's income.** It is the average of each Farm's and Mill's
   crew against its posts (Building.efficiency: staffing x the soil or saltpetre left). A Crown base offers 22 posts (two
   Farms of 8 and a Mill of 6), a Clockwork base few, so a Crown with fewer labourers than posts reads low whatever it
   earns: 13% at 2:00 is two Farms (16 posts) with two of its ten labourers at work while the rest walked, built and
   scouted. A Crown Farm grows as fast per hand when thin as when full (Defs.FARM_BASE 0): what counts is how many hands
   are on Farms. The number is a fair warning of empty posts, but it cannot be read against the Clockwork's.
2. **What did cost the Crown its gold in the owner's game** (measured second by second, tools/crown_econ_trace.gd, same
   map, seed and plans; the replay earned exactly the owner's 380 / 760 / 1,140 / 1,900 / 2,660 / 3,420 at minutes 1-6):
   - the halls stood idle 30-90 s a minute from 4:00, **every time for want of a labourer's 50 gold**: a harvest's 380
     came in lumps and the soldiers, the build steps and the buildings of the other think stages spent it first;
   - **six of 18-20 labourers ground powder while 4-7 Farm posts stood empty** (3:40-5:40), the powder bank rising
     30 -> 160 with nothing training from it;
   - **an enemy Winder scouting the base counted as a "threat"**, which switched the "free Farm posts first" rule off
     (1:15-2:00 and 4:15-5:15);
   - **the second hall waited behind the plan's steps**: the Balloon harass's "hall at 15 labourers" (met at ~3:05) stood
     behind the Foundry and the first balloon and was laid at 4:41 with 21 labourers (the bench's at 4:00);
   - the new hall stood without a Farm while the opening ran (the Timing attack's 60-90 s, the Balloon harass's to 6:00).
   Not the computer's fault, and not changed: the plan's own spending (the Barracks at 0:45, the Foundry, the balloons,
   the soldiers), the harvests' lumps, and from 6:00 the Clockwork's attack (labourers fleeing, buildings lost).
3. **Fixed** (all in scripts/ai_crown.gd, each with a switch, all off with `-- crowneco:off`): the Mills' hands to free
   Farm posts while the powder piles up; an unarmed scout is no threat to the economy; the labourers two deep at each hall
   while Farm posts stand free (their gold kept from the steps and the soldiers, the plan's labourer counts and its
   riders-first steps still ruling, and the army's survival checks over it); the second hall on time; a new hall's first
   Farm at once in every plan; and no Church bought for a wall slot in the opening (scripts/ai_expand_wall.gd).
4. **Results** (Hard OPTIMAL v Hard OPTIMAL, six maps, both sides, to 10:00; 12 games a matchup before and after):
   against the Clockwork the Crown earned +10% by 5:00, +9% by 8:00, +12% by 10:00 (0.61 -> 0.69 of its bench at 10:00)
   with 4-5 more labourers and the same army (1,005 -> 1,057 at 8:00); against the Brood, where most of the fixes stay
   off (their batches cost army and gained nothing), +4% by 10:00 and the same army; in the mirror +4% by 8:00 and 13%
   more army. **The owner's game replayed**: 3,420 -> 3,800 gold by 6:00 (+11%), 4,180 -> 4,560 by 7:00, army 795 ->
   1,095 at 7:00. No change in the results (all draws at 10:00, one Crown loss to the Brood in 12, section 4).
5. **For the owner** (section 6): the efficiency line's meaning, and the gap that is left, which is the plans (what
   OPTIMAL picks and what each spends) and the fights after 6:00, not the economy's running.

## 1. How it was measured

- **The trace** (new: tools/crown_econ_trace.gd, qa_match with a line a second for every Crown computer): gold, powder,
  the halls' queues, labourers on Farms / Mills / building / scouting / other, the Farm and Mill posts, supply, the
  opening's step and the gold it keeps, and what holds the labourers (free posts first, soldiers first, defending, a
  threat, raided, the army due, the hall's gold kept).
- **The owner's game**: Hollowfen, seed 4287366311, Hard OPTIMAL v Hard OPTIMAL. The replay's own dice picked the Timing
  attack at 1:33 where the owner's picked the Balloon harass; a study switch makes a Crown's NORMAL read pick a plan
  (`-- optnormal:balloon`, scripts/ai_optimal.gd), and with it the replay is the owner's game to 6:00 (the same gold to
  the coin, the same steps a few seconds apart).
- **The batch**: Hard OPTIMAL v Hard OPTIMAL to 10:00 on Hollowfen, Greenhold, Dune Sea, Frostfang, Cinder Steps and
  Ashford Crossing, the Crown on either side (seeds 1001, 1002), against the Clockwork and against the Brood: 24 games.
  BEFORE = this branch with `-- crowneco:off` (main's behaviour), AFTER = the branch. The bench (tools/econ_bench.gd,
  the Crown's design with no army): 4,180 / 9,500 / 13,180 gold at 5 / 8 / 10 minutes, the same on Hollowfen as on
  Greenhold.

## 2. What was wrong, in plain words

The owner's game replayed (`-- optnormal:balloon`, main's behaviour with `-- crowneco:off`), a line a minute of the trace:
how long the hall stood idle (and of that, with 50+ gold in the bank), the labourers, where they were.

| minute | hall idle s (with gold) | labourers | on Farms / Farm posts | on the Mill | building | other (walking, fled) |
|---|---|---|---|---|---|---|
| 0-1 | 9 (0) | 5.8 | 3.3 / 8 | 0 | 0.9 | 0.6 |
| 1-2 | 32 (0) | 8.5 | 5.8 / 12.8 | 0 | 1.4 | 0.7 |
| 2-3 | 4 (0) | 11.3 | 8.7 / 16 | 0.7 | 0.8 | 1.2 |
| 3-4 | 4 (0) | 15.9 | 9.9 / 16 | 2.7 | 1.1 | 2.1 |
| 4-5 | 50 (2) | 19.7 | 10.4 / 16 | 6.0 | 1.9 | 0.8 |
| 5-6 | 82 (2) | 20.5 | 10.6 / 16 | 4.5 | 3.6 | 1.2 |
| 6-7 | 71 (6) | 23.2 | 17.2 / 24 | 2.0 | 1.1 | 3.0 |

- **It is the gold, every time**: of the 248 s the hall stood idle in the first 7 minutes, 10 s had 50 gold in the bank.
  The Crown's income comes in harvests of 380 (a Farm ripens every 40 s with 8 hands, slower with fewer), and the think
  stages that saw the harvest first spent it: the build steps (the Barracks at 0:45 and the second Farm, the Mill, the
  Foundry, the balloons, the Cottages), the soldiers, the hall's 400. The labourers took one 50 a look; the hall trained
  for 12 s and stood until the next harvest.
- **The Mill was manned from Farm posts**: from 4:00 to 6:00, 4.5-6 hands on the Mill while 5-6 of the 16 Farm posts
  stood empty; the powder bank went 26 -> 120 -> 160 (the plan's crew: 5 hands from 13 labourers, 6 from 16). A Mill
  hand grinds 20 powder a minute, a Farm hand grows 71 gold.
- **A scout was a threat**: the rule that keeps a labourer's gold while Farm posts are free (econ-coach-crown) stepped
  aside for any enemy at our buildings, so the Clockwork's Winder scout at the Farms turned it off for 45 s at a time.
- **The second hall**: the Balloon harass's hall waits behind the Foundry and the first balloon; in the owner's game it
  was laid at 4:41 with 21 labourers (its trigger, 15 labourers, was met at ~3:05); the bench lays its hall at 4:00. In
  the replays it went at 4:14 (the dice), so this fix moved little there; it matters in the plans where the steps before
  the hall wait on a building (the Balloon harass, the Dragoon raids' Breeder, the Siege push).
- **The new hall without a Farm**: the opening's own rules lay no Farm; the Timing attack's second hall stood farmless
  until its attack ended the opening (60-90 s), the Balloon harass's to ~6:00.
- **Not the computer's own fault, not changed**: the plan's spending (an army plan buys a Barracks, a Foundry, balloons
  and soldiers that the bench does not: about 8 labourers' worth by 3:00), the harvests' lumps, the scout's labourer
  (OPTIMAL's read), the builders (1-3 at a time), and from 6:00 the Clockwork's attack: labourers fleeing, Farms and the
  Mill lost (the defence and army jobs').

Filmed (docs/shots/crown-coach-economy/, the main at 4:02 and 6:00): before, the Farms 4/8 and 8/8 and the Mill 6/6 at
4:02, 5/8 and 6/8 with the Mill 3/6 at 6:00; after, 6/8 and 8/8 with the Mill 5/6 at 4:02, 8/8 and 6/8 with the Mill 6/6
(the powder now spent: more Musketeers) at 6:00. The coach's lines every 15 s are beside them.

## 3. What changed

| fix (switch) | what it does |
|---|---|
| **The Farms' posts before the powder** (_mill_farm_cap, `millfarm:off`) | the Brood's rule (crown-v-brood-coach) opened to the Clockwork and the mirror: while there are fewer labourers (not counting the builders and the scout) than the Farms' posts and the Mills' crews, and the powder bank is over what the Barracks and the Foundry want (30 + 15 a building), the Mills keep one hand per 6 labourers; with twice that, one a Mill. Counted by the labourers beyond the posts, not by where hands stand, so it does not swing. Not while a rush is defended. |
| **An unarmed scout is no threat** (_posts_threat, `postsscout:off`) | the free-Farm-posts rules step aside for an ARMED enemy at our buildings, not for a worker scout. |
| **The labourers two deep** (_bo_lab_keep, _lab_slots, `bolabs:off`) | in the opening, while 2+ Farm posts are free: the gold for two labourers in each hall's queue (no more than the free posts) is kept from the build steps and the soldiers; after the opening the same depth joins "free Farm posts first" (_econ_keep). Never past the plan's labourer count (the Timing's 19), never in the rush (its riders first), never while a rush is defended, enemies are at our buildings or labourers, or the army is far behind (army_lags); not against the Brood (two batches: 20-30% less army at 5:00 or 8:00 and no more income, even under the Brood's survival checks). |
| **The second hall on time** (_bo_hall_on_time, `hallontime:off`) | once a later hall step's trigger has held 20 s it comes next, ahead of build, balloon and army steps; never past an attack step (the Timing and the rush keep their order) or the pick, never while a rush is feared; not against the Brood (moved, the hall's 400 cost a third of the army at 5:00 and some income: Hollowfen 1002, 575 -> 345 of army). |
| **The new hall's Farm** (_hall_farm_open, `hallfarm:off`) | the owner's plans' "a Farm at the new hall at once" for every plan's opening, once the Farms we have are nearly manned (3 free posts at most). |
| **No Church for a wall slot in the opening** (AIExpandWall._fill_slot) | with the hall on time, its walled-natural plan came during the Timing's opening and bought a Church (900 hp, a 3x3 wall slot) before the army (test_ai_optimal section 7). The tech comes with the plan's milestones. |

## 4. Results

Bench (the design, no army): 4,180 / 9,500 / 13,180 gold at 5 / 8 / 10 minutes. Gold earned (the games' statistic),
labourers, army value, all averages of 12 games; the halls' "hall 2" is when the second hall stood.

| matchup | gold 5:00 | gold 8:00 | gold 10:00 | of bench at 10:00 | labourers 8:00 / 10:00 | army 5:00 / 8:00 / 10:00 | hall 2 | buildings lost by 10:00 |
|---|---|---|---|---|---|---|---|---|
| v Clockwork, before | 2,501 | 5,573 | 8,075 | 0.61 | 28.2 / 34.2 | 364 / 1,005 / 1,387 | 5:12 | 3.2 |
| v Clockwork, after | 2,755 | 6,048 | 9,056 | 0.69 | 33.0 / 37.8 | 298 / 1,057 / 1,347 | 5:05 | 2.8 |
| v Brood, before | 2,881 | 5,573 | 7,980 | 0.61 | 27.6 / 25.8 | 591 / 763 / 1,138 | 5:04 | 10.2 |
| v Brood, after | 2,850 | 5,605 | 8,325 | 0.63 | 27.7 / 31.8 | 572 / 848 / 1,016 | 5:02 | 4.9 |
| mirror (both sides), before | 2,565 | 5,256 | 7,600 | 0.58 | 24.7 / 30.0 | - / 999 / - | | |
| mirror (both sides), after | 2,596 | 5,478 | 7,790 | 0.59 | 27.2 / 31.4 | - / 1,127 / - | | |

- The Clockwork earned the same in both (4,235 / 10,300 / 15,947 before, 4,248 / 10,350 / 15,970 after): the Crown's gap
  to it is 0.51 -> 0.57 at 10:00.
- **Results**: all 24 Clockwork games and all 6 mirror games were draws at 10:00 before and after (the study's 10-minute
  cut); against the Brood 0-12-0 before, 0-11-1 after (Frostfang 1002: the rush's army took another shape at 3:00, the
  Brood's Raptors took both halls at 8:59-9:24; before, the same game had lost its whole army by 10:00, 80 of army left with
  23 labourers, and lived to the cut).
- The army at 5:00 against the Clockwork is 66 less (a Musketeer): the labourers' gold kept in the opening; by 8:00 it
  is ahead. The units lost by 10:00 against the Clockwork went 20.6 -> 17.9, the Clockwork's 29.5 -> 35.2.
- Single games are noisy (the same tag differs by a plan pick or a fight); the totals are what to read.
- Batches: an earlier round (after1, before the last gates) had against the Clockwork 2,755 / 5,795 / 8,075 and against
  the Brood 2,976 / 5,953 / 8,676 with the army at 5:00 428 (-28%): the reason for the Brood gates.

## 5. The AI tests

(TODO)

## 6. Claude's choices, for the owner

1. **The efficiency line**: it stays as it is (a staffing number, a fair warning of empty posts). Proposed, NOT done:
   show the Crown's income per labourer beside it, or count only the posts its labourers could fill, so the line can be
   read against the Clockwork's. Your call.
2. **Labourers before soldiers in the opening** while Farm posts stand free (the gold for two in each hall's queue). It
   costs about one Musketeer at 5:00 against the Clockwork and pays it back by 8:00. Kept out of the Horseman rush (its
   riders first are its identity) and out of the Brood matchup (two batches cost army there and gained no income).
3. **The second hall ahead of the plan's later steps** once its own trigger has held 20 s: it changes the order of
   the Balloon harass's opening (the hall before the first balloon when the labourers are there first), the Dragoon raids'
   and the Siege push's. Kept out of attack steps and of the Brood matchup. If a plan's order is part of its identity for
   you, say so and it goes back (`hallontime:off`).
4. **The Mills' hands to the Farms** while the powder piles up, in every matchup (the Brood had it already): the plans'
   own Mill crews ("mill" in PLANS) still rule while powder is short.
5. **No Church bought for a walled natural's 3x3 wall slot during the opening** (AIExpandWall): with the hall on time,
   the Timing's wall plan bought one before its army. A Cottage or the plan's own Barracks still fill slots.
6. **What is left, and why the Crown still earns 0.57 of the Clockwork computer by 10:00**: the plans OPTIMAL picks and
   what each spends (against the Clockwork the Balloon harass and the Timing attack, each built to trade economy for an
   army: the bench, with no army at all, earns 13,180 by 10:00 where the Clockwork computer earns ~16,000 with one), the
   harvests' lumps (gold in 380s, the hall waiting between them), and from 6:00 the fights at home. The economy's own
   running is now close to what the plan allows; more income needs a plan choice (the Economy race against the Clockwork,
   `-- greedyclock:economy`, econ-coach-crown section 6) or the defence and army jobs' work.
7. **Study switch** `-- optnormal:<plan>` (scripts/ai_optimal.gd): a Crown's NORMAL read picks that plan, to replay a
   game whose dice picked it. Off unless given.

## How to run it

- The trace: `godot --headless --fixed-fps 30 --script res://tools/crown_econ_trace.gd -- map:hollowfen
  seed:4287366311 end:480 out:/abs/dir slots:crown/optimal/0,clockwork/optimal/1 [optnormal:balloon] [crowneco:off]`
  (about a minute a game); trace.json has a row a second for each Crown.
- The owner's game filmed: `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --fixed-fps 30 --script
  res://tools/shot_ai_match.gd -- a:crown b:clockwork map:hollowfen seed:4287366311 pa:optimal pb:optimal coach:1 end:420
  out:/abs/dir optnormal:balloon [crowneco:off]`.
