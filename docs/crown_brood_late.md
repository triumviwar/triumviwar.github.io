# The Crown against the Brood, the late game (crown-brood-late)

The owner, 2026-11-24, after two filmed games: Crown OPTIMAL against Brood OPTIMAL, Hard, Greenhold, seed 11, to 20:00.

- Game A (as the game is today): the Brood out-earned the Crown by 11:00. At 10:05 the Crown attacked into the swamp
  with its two Field Cannons still limbered behind the line. It lost half its army. The counter killed it at about 13:00.
- Game B (with `farmaw:2.0`): the economies were even and the Crown won every fight to 12:00. But it stayed at about 134
  supply while the Brood filled its 200. At 16:00 the Crown marched its whole army to the Brood's nest. The Raptors walked
  into its empty home. Every labourer was dead at 17:07.

He asked for three things in the Crown computer, against the Brood: (1) the guns set before the attack, (2) fill the
supply cap, (3) no empty home. Each behind its own switch, measured, and kept only if it helps.

## Summary

1. **All three parts were built**, in the Crown computer only, against the Brood only. No unit, price or rule number
   changed. Each has its own switch.
2. **None is on by default.** None moved the result beyond the noise. Two of them made it worse.
3. **The guns part works as a behaviour.** Away from home, the guns standing set when a fight began went from 6% to 68%.
   The fights away from home traded better: 1.25 killed for each one lost, against 1.01. But the games ended the same:
   the score was the same (mean g -0.65 against -0.60 over 30 games), and the Crown was beaten as often or a bit more.
4. **The home guard and the early call home made the Crown worse.** Beaten 6 times in 10 games, against 5 in 20 today.
   Holding a third of the army back weakens every push, and the Brood grows in the time bought.
5. **The supply cap: the cause is gold and powder, not Cottages.** From 10:00 to 16:00 the bank is under 300 in 116 of 139
   looks (one a minute), so the Crown spends what it earns. In 4 of 20 games the powder ran dry at 13:00-15:00 while 1,000 to 5,000 gold
   piled up, and the army was not rebuilt. In the games the Crown led, 85 to 97 labourers filled the supply. The fix
   (the Mill crew against the Brood, and a ceiling of 60 labourers from 11:00) stopped the dry powder (0 games of 50),
   but cost income and made the result worse (beaten 5 of 10).
6. **`farmaw:2.0` is still the lever that matters.** All three parts with x2.0: the Crown won or led 11 of 20, beaten 5.
   Without x2.0: won or led 3 of 20, beaten 8.

**Recommended:** leave all three off. If the owner wants to see guns set before a fight, `cblguns:on` costs nothing in
results: it is the one to turn on. The game's balance is the Brood's late income (`farmaw`), as crown-brood-fix found.

## What was built

All in `scripts/ai_crown_brood_late.gd` (AICrownBroodLate). A Crown computer, Normal and up, facing a Brood. Switches:
`-- cbl<name>:on` plays a part, `-- cbl:off` none. Today none is on.

### Part 1: the guns set before the attack (`cblguns`)

Why game A went wrong: the siege push marches with its guns limbered on its trail, 150 px behind the line. It sets up only
at contact. A Brood soldier is first seen at a musket's sight (256 px). A Raptor runs that in under 3 seconds. A gun takes
2.5 seconds to unlimber, and it rolled to its spot first. So the fight began with the guns limbered. In today's games,
away from home, 9 guns of 139 near a fight were set at its first contact: 6%. And in a trial game the press (the whole
army goes for the Brood Mother at 8:00-11:00) went at 8:33 with no gun at all.

What it does now:

- **The press waits for its guns**: 2 guns at home, one a Field Cannon. It waits 50 seconds at most, then goes as before.
- **The eyes**: the push's first rider rides 330 px ahead of the line, and back to the guns when the Brood is near him.
- **The bounds**: when the Brood is near (a Brood soldier seen in the last 25 seconds, a Rootmaw known, or the march's
  goal within 950 px), the push goes forward the way guns and foot go together. The guns stand set. The line walks on,
  but no man goes more than 230 px ahead of the set guns. When the line reaches that edge, the rearmost gun limbers, rolls
  up to 100 px behind the line and sets again. One gun at a time.
- **The brace**: a Brood force seen near the line while guns are limbered: the line halts on HOLD, the guns come up and
  set, and only then does the push set up against that force.

A first version had only the eyes and the brace (blocks l01, l02, lf01). It did not help: the guns set at contact away from
home stayed at 3-7%. The bounds were added.

### Part 2: fill the supply cap (`cblcap`)

The cause first (today's 20 games):

| what we looked at | what the games showed |
|---|---|
| Cottages | not the cause: below 200 the cap stood a median 28 ahead of the supply used (10:00-16:00) |
| gold banked | not in most games: the bank is under 300 in 116 of 139 looks from 10:00 to 16:00 (one a minute) |
| powder | in 4 of 20 games the powder was 0 from 13:00-15:00 while 1,000 to 5,000 gold piled up; 8 hands on 4 Mills on average with thousands of saltpetre left |
| labourers | they grow with the halls (the halls' saturation): 85 to 97 labourers at 16:00-18:00 in the games the Crown led, so the supply was full of labourers, not soldiers |
| the supply metric | at 16:00 the Crown's army was worth 2,305, the Brood's 2,485: close. The Brood's supply also counts its rooted Rootmaws and Turtles. The two supply numbers are not like for like |

What it does:

- From 10:00 the **Mill crew** (AICrownMillCrew, on by default against the Clockwork only) works against the Brood too:
  when the army wants powder, every Mill is crewed toward its full 6.
- From 11:00 the **labourers stop at 60**.

### Part 3: no empty home (`cblhome`)

- From 9:00 a push or a wave leaves a **home guard**: the Musketeers nearest our front (and one gun when there are three),
  worth the Brood army seen lately or half the clock's reckoning, at most 35% of the army.
- The siege push **comes home** when a Brood force heads for our buildings that the army at home **without the push**
  cannot beat (the push's own rule counted the push itself as "home").

## The numbers

All games: Hard OPTIMAL against Hard OPTIMAL, to 20:00. The same 10 games every block: the six parity maps, the same seeds
and sides as wr1000 and crown-brood-fix (tools/study/crown_brood_late.py). Today's game is main 0.38.199, played twice.

The result at 20:00, from the Crown's side:

| arm | games | won | led | even | behind | lost | Crown won or led | mean g | g at 14:00 |
|---|---|---|---|---|---|---|---|---|---|
| (a) today | 20 | 0 | 8 | 1 | 6 | 5 | 8 | -0.60 | +0.09 |
| (b) all three parts | 20 | 1 | 2 | 1 | 8 | 8 | 3 | -0.89 | -0.08 |
| (c) all three parts and farmaw:2.0 | 20 | 1 | 10 | 0 | 4 | 5 | 11 | -0.30 | +0.16 |
| the guns alone | 30 | 0 | 10 | 1 | 9 | 10 | 10 | -0.65 | +0.01 |
| the home guard alone | 10 | 0 | 0 | 0 | 4 | 6 | 0 | -1.56 | -0.13 |
| the supply cap alone | 10 | 0 | 2 | 2 | 1 | 5 | 2 | -1.14 | -0.10 |
| first version, all three (eyes and brace, no bounds) | 12 | 0 | 3 | 0 | 4 | 5 | 3 | -1.00 | -0.06 |

g is the Crown's score against the Brood's, as a log. 0 is even. -0.7 is the Brood twice the Crown. The score is income
earned plus twice the army, a beaten side counted a quarter.

Against today, game by game (each game's two runs averaged; d is the mean difference of g, t its t value):

| arm | d g (t) | games better / worse | d g at 14:00 (t) |
|---|---|---|---|
| all three parts | -0.29 (-0.7) | 1 / 8 | -0.17 (-2.1) |
| all three and farmaw:2.0 | +0.29 (1.0) | 6 / 4 | +0.07 (0.8) |
| the guns alone | -0.05 (-0.2) | 3 / 6 | -0.08 (-1.1) |
| the home guard alone | -0.97 (-2.8) | 1 / 9 | -0.22 (-1.5) |
| the supply cap alone | -0.55 (-2.5) | 1 / 7 | -0.19 (-1.6) |

The noise: today's two runs of the same 10 games differed by 0.64 in mean g (-0.28 and -0.92). The guns alone, three runs:
-0.40, -1.51 and -0.04. Only the home guard and the supply cap are clearly worse.

### Income, supply and armies

The means over the games still on at that minute. Supply is used / cap.

| minute | arm | Crown income | Crown supply | Crown bank | Crown labourers | Crown army | Brood income | Brood supply | Brood army |
|---|---|---|---|---|---|---|---|---|---|
| 8:00 | today | 6,460 | 73 / 89 | 211 | 36 | 1,334 | 4,722 | 66 / 91 | 590 |
| 8:00 | all three | 6,555 | 74 / 88 | 194 | 37 | 1,350 | 4,877 | 67 / 92 | 595 |
| 8:00 | all three, x2.0 | 6,479 | 71 / 89 | 234 | 37 | 1,321 | 4,281 | 62 / 83 | 624 |
| 8:00 | guns alone | 6,523 | 73 / 87 | 215 | 36 | 1,307 | 4,520 | 64 / 86 | 590 |
| 12:00 | today | 13,353 | 116 / 141 | 166 | 50 | 2,221 | 12,224 | 120 / 144 | 1,821 |
| 12:00 | all three | 13,485 | 129 / 147 | 123 | 58 | 2,783 | 13,501 | 138 / 172 | 1,899 |
| 12:00 | all three, x2.0 | 13,303 | 129 / 151 | 188 | 54 | 2,864 | 11,103 | 120 / 145 | 1,686 |
| 12:00 | guns alone | 13,095 | 121 / 145 | 126 | 51 | 2,778 | 11,938 | 124 / 149 | 1,801 |
| 16:00 | today | 20,498 | 116 / 161 | 1,007 | 52 | 2,305 | 20,350 | 155 / 187 | 2,485 |
| 16:00 | all three | 19,778 | 100 / 151 | 512 | 46 | 1,987 | 22,850 | 163 / 192 | 2,666 |
| 16:00 | all three, x2.0 | 20,566 | 129 / 162 | 612 | 57 | 2,814 | 18,616 | 151 / 177 | 2,597 |
| 16:00 | guns alone | 19,993 | 112 / 156 | 470 | 49 | 2,513 | 20,196 | 153 / 187 | 2,514 |

Income is gold earned since the start. Read: with the parts the Crown's army at 12:00 is a quarter bigger (2,780 against
2,220), and its supply 121-129 against 116. But the Brood earns more by 12:00 too (13,500 against 12,200 with all three),
and by 16:00 the Crown's army is no bigger than today's.

### Halls, labourers and the fights

| arm | labourers lost a game | from 12:00 | Crown halls lost from 12:00 | guns set at a fight's contact | away from home | killed for each lost, away / at home |
|---|---|---|---|---|---|---|
| today | 52.1 | 48.4 | 2.6 | 25% | 6% | 1.01 / 1.23 |
| all three | 52.0 | 47.5 | 2.2 | 45% | 56% | 1.27 / 1.57 |
| all three, x2.0 | 37.8 | 34.0 | 2.0 | 60% | 73% | 1.37 / 1.31 |
| guns alone | 44.8 | 38.2 | 2.3 | 54% | 68% | 1.25 / 1.24 |
| home guard alone | 68.8 | 62.6 | 3.9 | 32% | 26% | 0.99 / 0.85 |
| supply cap alone | 55.8 | 46.0 | 2.7 | 22% | 23% | 1.09 / 1.07 |

A fight begins when an armed enemy comes within 260 px of a Crown soldier on foot (AICrownGuns' count). "Guns set" are the
Crown's guns within 1,000 px of it standing unlimbered at that moment.

### The supply cap, what changed

| arm | games | powder dry with 1,000+ gold banked (12:00-18:00) | at the 200 cap | labourers at 14:00-16:00 | hands on the Mills |
|---|---|---|---|---|---|
| today | 20 | 4 | 5 | 52 | 8.2 |
| the supply cap alone | 10 | 0 | 2 | 49 | 9.9 |
| all three | 20 | 0 | 4 | 53 | 12.1 |
| all three, x2.0 | 20 | 0 | 8 | 56 | 10.2 |
| guns alone | 30 | 4 | 8 | 51 | 8.4 |

The Mill crew stopped the dry powder. But its hands come off the Farms, and the gold fell with them. The labourer ceiling
acted for only 2 to 4 minutes a game: by 11:00-16:00 most Crowns had fewer than 60 labourers left (the Raptors kill 40 to 50
a game after 12:00).

What the gold went on from 10:00 to 16:00 (all three parts, a game): army 4,705 (47%), labourers 1,545 (16%), halls, Farms
and Mills 1,180 (12%), Barracks, Foundries and tech 942 (9%), walls 825 (8%), Cottages 555 (6%), research 202 (2%). Half
the late gold goes on rebuilding an economy the Raptors keep breaking.

## What was kept

Nothing is on by default (`AICrownBroodLate.KEPT` is empty). The rule was: keep a part only if it helps beyond the noise.

- **The guns**: no help to the result (d -0.05, t -0.2, 30 games). Left off. It is the one to turn on if wanted:
  `cblguns:on`. The owner will see the guns set before a fight, and the trades away from home are better.
- **The home guard**: worse (d -0.97, t -2.8). Off. This is the third time a home guard was measured against the Brood
  (crown-1000-brood "guard", wr1000 "home"); none helped.
- **The supply cap**: worse (d -0.55, t -2.5). Off.

Opening it to the other matchups: no. Nothing here helped against the Brood.

## The films

Two films with tools/shot_ai_match.gd coach:1, Hard OPTIMAL both, the guns part on (`cblguns:on`). Pictures, the
Crown's push and fight lines and the coach's lines in docs/shots/crown_brood_late/.

**Film A: Greenhold, seed 11, with `farmaw:2.0`** (the owner's game B). The Crown was beaten at 17:52.

| time | what happened |
|---|---|
| 10:01-10:23 | the press waits for its second gun |
| 10:51 | the press goes: 43 supply, 1 gun |
| 11:03 | "goes on in bounds": a Raptor seen near our own halls starts the bounds at once, so the push crawls from home |
| 12:39-14:33 | four braces: the line halts and the guns set when the Brood comes |
| 13:54 | a fight away from home: 2 guns near, 2 set at contact; killed 1,490, lost 1,590 |
| 14:39 | the push falls back with 1,590 of the 3,535 that went out |
| 14:57 | the fight that decided the game, AT HOME: 2 guns near, 0 set; killed 1,185, lost 7,380 |

Pictures: a_1132_bounds_near_home.jpg (the push in bounds by its own Farm at 11:32), a_1421_brace.jpg, a_1118_fight.jpg.

**Film B: Dune Sea, seed 4114.** The Crown was beaten at 19:56.

| time | what happened |
|---|---|
| 8:30-9:14 | the press waits for its second gun, then goes at 9:21 with 1 (the 50 seconds ran out) |
| 9:48 | in bounds |
| 10:34 | a fight away from home: 2 guns near, **2 set at contact, both fired in the first 10 s; killed 1,200, lost 0** |
| 11:16 | the next fight away: 3 guns near, 2 set; killed 3,775, lost 1,865 |
| 13:17 | the push falls back: killed 7,600, lost 4,465, broke a Rootmaw and a Mound Turtle |
| 12:55 | AT HOME meanwhile: 1 gun near, 0 set; killed 4,500, lost 4,735 |

Pictures: b_1035_guns_set_at_contact.jpg (the gun firing behind the line as the Raptors come), b_1300_home_fight.jpg.

What the films show: away from home the guns are now set when the Brood comes, and those fights go well. The games
are lost at home, where the guns are still limbered at contact, and in the time the slower push gives the Brood.

## The AI tests

All 23 `tools/test_ai_*.gd` (tools/study/run_ai_tests.sh) on a frozen copy of this branch with nothing on by default
(docs/crown_brood_late/ai_tests_after.txt): 20 pass. test_ai_rush_followup and test_ai_wall_vs_rush fail, as on main
(CLAUDE.md lists both). test_ai_brood failed its stage-3 timing once (629 s against 620) and passed on a rerun (CLAUDE.md:
flaky). tools/test_crown_v_brood.gd: 0 failures. With nothing on by default the game plays as before: the only change
that always runs is the gold-spent count (Game.spent_by).

## Claude's choices

1. **Nothing kept on.** The owner's rule: keep only what helps beyond the noise. The guns part is a better behaviour that
   did not change the result; it is left off with its switch, not on.
2. **The guns part is the siege push's**, the press's and every push against the Brood. The wave's own line already has
   the crown-guns-coach rules (set in time, the held line). The siege push did not use them.
3. **The bounds go one gun at a time**, and the line never leaves the cover of the set guns. Slower on the march; tried
   because the brace alone did not set the guns before contact.
4. **The press waits 50 seconds at most for its guns.** A trial game waited from 8:52 to 11:00 for one gun (the horses).
5. **The supply cap's cause was looked for first** (gold, powder, labourers, Cottages, the supply metric), then the two
   fixes it pointed to were built (the Mill crew against the Brood, the labourer ceiling).
6. **The home guard is sized to the Brood army seen** (or half the clock's reckoning), at most 35% of the army.
7. **A first version was measured and replaced** (eyes and brace only; blocks l01, l02, lf01). Its data stays in the folder.
8. **A gold-spent measure was added to the game** (`Game.spent_by`, read by qa_match as "sb" each minute). It only counts;
   it changes nothing.
9. **The single-part arms are 10 games** (30 for the guns), not 20: the time went on the bounds and on the third guns block.

## Proposals

1. **farmaw x2.0** (crown-brood-fix's recommendation) is still the one change that moves this matchup: with it the Crown
   won or led 11 of 20 here. The owner decides.
2. **The guns at home.** Most of the Crown's big losses are at home: in today's games 71 fights at home, 25% of the guns
   near set at contact; both films were decided by a fight at home with the guns limbered (7,380 lost for 1,185). The
   home posts' guns (AICrownGuns gpost/gdef) need the same "set before the Brood arrives" rule as the bounds.
3. **The bounds only beyond our side of the map.** In film A a Raptor near our own halls put the push in bounds at once,
   and it crawled out of its own base. Counting only the Brood seen on the far side of the line's march would keep the
   push quick until it is near the nest.
4. **Labourers in the halls** (crown-brood-fix's proposal 1): 40 to 50 labourers a game die after 12:00, a sixth of the late
   gold goes on replacing them. Only a design change (sheltering in the hall) saves a slow worker from a fast raider.
5. **The Mill crew earlier and smaller against the Brood**: it cured the dry powder but cost the Farms. A crew sized to the
   army's need (not toward 6 a Mill) might keep both.
6. **The bounds faster**: two guns moving at a time when there are four or more.

## Files

- `scripts/ai_crown_brood_late.gd` (AICrownBroodLate: the three parts, their switches and counters).
- Hooks: `scripts/ai_crown_siege.gd` (the brace, the eyes and the bounds in _march and _siege_set; the guard in _go; the
  call home in _lost), `scripts/ai_crown_brood_fix.gd` (the press waits for its guns), `scripts/ai_crown.gd` (the
  labourer ceiling in _lab_want and owner_lab_cap; the wave's guard via _late_ready), `scripts/ai.gd` (_late_ready),
  `scripts/ai_crown_mill_crew.gd` (on against the Brood with `cblcap`), `scripts/game.gd` (Game.spent_by, a measure),
  `tools/qa_match.gd` (the counters in result.json "crown_ai", "sb" in each minute).
- Films: docs/shots/crown_brood_late/ (pictures, push logs, coach lines). AI tests: docs/crown_brood_late/ai_tests_after.txt.
- `tools/study/crown_brood_late.py` (the blocks: `run BLOCK --extra a,b [--root DIR]`, `results`, `report --base`),
  `tools/study/crown_brood_late_report.py` (income, supply, labourers, fights, gold spent).
- Blocks in `docs/crown_brood_late/data/`: b01-b02 (today), m01-m02 (all three), mf01-mf02 (all three, farmaw:2.0),
  sg01-sg03 (the guns alone), sh01 (the home guard alone), sc01 (the supply cap alone), l01-l02 and lf01 (the first
  version). Each has extra.txt (its switches) and a folder a game (result.json, story.txt, planlog.txt).
