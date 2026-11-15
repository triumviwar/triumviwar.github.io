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
4. **Results, 24 games before and after** (Hard OPTIMAL v Hard OPTIMAL, six maps, both sides, to 10:00): against the
   Clockwork the Crown earned +10% by 5:00, +9% by 8:00, +12% by 10:00 (0.61 -> 0.69 of its bench at 10:00) with 4-5 more
   labourers and the same army; against the Brood (section 4) TODO. The owner's game replayed: TODO.
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

(TODO tables)

## 3. What changed

| fix (switch) | what it does |
|---|---|
| **The Farms' posts before the powder** (_mill_farm_cap, `millfarm:off`) | the Brood's rule (crown-v-brood-coach) opened to the Clockwork and the mirror: while there are fewer labourers (not counting the builders and the scout) than the Farms' posts and the Mills' crews, and the powder bank is over what the Barracks and the Foundry want (30 + 15 a building), the Mills keep one hand per 6 labourers; with twice that, one a Mill. Counted by the labourers beyond the posts, not by where hands stand, so it does not swing. Not while a rush is defended. |
| **An unarmed scout is no threat** (_posts_threat, `postsscout:off`) | the free-Farm-posts rules step aside for an ARMED enemy at our buildings, not for a worker scout. |
| **The labourers two deep** (_bo_lab_keep, _lab_slots, `bolabs:off`) | in the opening, while 2+ Farm posts are free: the gold for two labourers in each hall's queue (no more than the free posts) is kept from the build steps and the soldiers; after the opening the same depth joins "free Farm posts first" (_econ_keep). Never past the plan's labourer count (the Timing's 19), never in the rush (its riders first), never while a rush is defended, enemies are at our buildings or labourers, the army is far behind (army_lags), or against the Brood while its survival checks say the army is behind or not growing (army_behind, army_grows). |
| **The second hall on time** (_bo_hall_on_time, `hallontime:off`) | once a later hall step's trigger has held 20 s it comes next, ahead of build, balloon and army steps; never past an attack step (the Timing and the rush keep their order) or the pick, never while a rush is feared. |
| **The new hall's Farm** (_hall_farm_open, `hallfarm:off`) | the owner's plans' "a Farm at the new hall at once" for every plan's opening, once the Farms we have are nearly manned (3 free posts at most). |
| **No Church for a wall slot in the opening** (AIExpandWall._fill_slot) | with the hall on time, its walled-natural plan came during the Timing's opening and bought a Church (900 hp, a 3x3 wall slot) before the army (test_ai_optimal section 7). The tech comes with the plan's milestones. |

## 4. Results

(TODO)

## 5. The AI tests

(TODO)

## 6. Claude's choices, for the owner

(TODO)

## How to run it

- The trace: `godot --headless --fixed-fps 30 --script res://tools/crown_econ_trace.gd -- map:hollowfen
  seed:4287366311 end:480 out:/abs/dir slots:crown/optimal/0,clockwork/optimal/1 [optnormal:balloon] [crowneco:off]`
  (about a minute a game); trace.json has a row a second for each Crown.
- The owner's game filmed: `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --fixed-fps 30 --script
  res://tools/shot_ai_match.gd -- a:crown b:clockwork map:hollowfen seed:4287366311 pa:optimal pb:optimal coach:1 end:420
  out:/abs/dir optnormal:balloon [crowneco:off]`.
