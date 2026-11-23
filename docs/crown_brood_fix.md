# The Crown against the Brood, made more even (crown-brood-fix)

The owner, 2026-11-22 21:27-21:29: the Crown loses to the Brood far too often; "we can't just let it be so lopsided, it
has to be at least a bit more equal". He said "Do it" to a plan of five parts: (1) the Crown computer spends its lead,
(2) the Brood's late income trimmed through the far-Rootmaw pay, as a switch, (3) both measured, alone and together,
with side checks in the other Brood matchups, (4) his Raptor idea as a fight test, (5) a look at the outlying halls.

## Summary

All games: Hard OPTIMAL against Hard OPTIMAL, to 20:00, the same 10 games as the wr1000 crown-brood study (the six
parity maps, the same seeds and sides), each arm played three times: 30 games an arm.

| Crown v Brood, 30 games an arm | won | led | even | behind | lost | Crown won or led | Brood won or led | mean g | g at 14:00 |
|---|---|---|---|---|---|---|---|---|---|
| today's game (main 0.38.177) | 0 | 3 | 0 | 12 | 15 | 3 | 27 | -1.32 | -0.18 |
| the press (the Crown spends its lead) | 1 | 6 | 2 | 9 | 12 | 7 | 21 | -0.80 | +0.07 |
| the far Rootmaw pays x1.8 (not x2.2) | 1 | 16 | 1 | 6 | 6 | 17 | 12 | -0.03 | +0.35 |
| the press and x1.8 together | 4 | 15 | 2 | 5 | 4 | 19 | 9 | +0.39 | +0.51 |
| the press and x2.0 | PF2_ROW |

(g is the Crown's score against the Brood's, as a log: 0 is even, +0.7 is the Crown twice the Brood, -0.7 the Brood
twice the Crown; the score is income earned plus twice the army, a beaten side counted a quarter.)

In plain words:

1. **Today the Crown computer loses this matchup badly**: in 30 fresh games it won none, led in 3 and was beaten in 15.
   The story is the one wr1000 found: the Crown leads at 8:00 (two and a half times the Brood's army, 1.4 times its
   income), the Brood out-earns it from about 10:00, fills its supply and its capped waves take the Crown's outlying
   halls from 12:00 on; the Crown loses about 56 labourers a game after 12:00.
2. **The press is kept** (an AI change, on by default, against the Brood only): between 8:00 and 11:00, once the Crown's
   army is twice the Brood army it has seen, the whole army goes for the Brood Mother at once instead of waiting. It
   fired in every game, once, at about 9:05. Alone it makes the game a bit more even: beaten 15 -> 12, won or led 3 ->
   7, and the score at 14:00 moved from the Brood's side to even (+0.25, t 3.0). It does not win the game by itself.
3. **The far-Rootmaw pay is the bigger lever** (a balance number: **the owner decides**; the default is unchanged).
   x1.8 instead of x2.2 alone turns the matchup: the Crown won or led 17 of 30, the Brood 12, beaten 6 times. With the
   press on top (which is how the game now plays), the Crown won or led 19 and was beaten 4 times: that leans to the Crown,
   so x2.0 was measured too (PF2_SHORT).
4. **The Raptors do not get round the guns**: in set-piece fights at equal cost the Crown's line, guns and riders beat
   the Raptor and mixed Brood forces in 70 of 72 fights, killing 2 to 9 times what they lost. Raptors reach the guns when they
   come from the side of a march or in big numbers, and take a gun or two, but they lose the fight. The Crown's trouble
   is the economy and where the fights happen, not the Raptors at the guns.
5. **The outlying halls**: 75% of the labourers lost after 12:00 die walking or running away, 83% of them to Raptors (a
   Raptor is faster than a labourer). The halls lost after 12:00 fell from 3.1 to 1.9 a game with x1.8; nothing in the
   AI alone saves the labourers. Proposals below.

**Recommended:** keep the press (done). For the balance, the owner's call: OWNER_RECO

## The changes

### 1. The press: the Crown spends its lead (`cbfpress`, KEPT, on by default)

`scripts/ai_crown_brood_fix.gd` (AICrownBroodFix), a Crown computer of Normal and up facing a Brood only:

- From 8:00 to 11:00, when the army at home is worth 1,000 or more AND twice the Brood army it has seen in the last two
  minutes (never counted under 400), with 30 supply, no Brood force at its buildings and the Brood Mother alive: the
  whole army goes at once for the Brood Mother.
- It goes as a siege push in its "queen" march (the push's own code: the line in front, the guns limbered behind, the
  riders by the guns), guns or not; it sets up only against the Brood army on its line, what blocks its way (35% of the
  usual reach) and the Mother. The push's usual retreat rules stand (it comes back under 45% of what went out).
- Outside the siege plan (a Rush or Balanced game that never handed over to the Siege push) the press goes as a siege
  push of its own (AICrown.cbf_push); its men are on an errand for the rest of the computer.
- With no Brood soldier seen lately it asks the scout for a look first. At most two presses a game.
- `-- cbfpress:off` (or `cbf:off`) plays as before.

What it did in the 30 games: it fired once in every game (28 times as the Siege push, twice as a push of its own), at
8:00-9:59 (median 9:05), killed on average 2,300 of Brood for 2,000 of its own, broke 21 Mound Turtles, 17 Rootmaws and a
Tyrant Sire over the 30 games, and came back after losing over half of what went out in 25 of 28. It never reached the
Mother alone; with x1.8 it killed her once. What it buys is time: the Brood's army and turtles are knocked down just
when its income would take off (the Crown's income share at 12:00 0.99 -> 1.17).

Tried and dropped while tuning (one trial game each): the line not waiting for its guns (no better: the guns are what
breaks the rooted ground), and a press as the ordinary wave outside the siege plan (the Rush plan's wave never went: its
own gates held it).

### 2. The far-Rootmaw pay (`farmaw:X`, a match switch, default unchanged)

`Game.food_bonus` (scripts/game.gd) reads `farmaw:X` from the game's command line: a Rootmaw far from the Mother pays X
times a near one (today 2.2: 1 + FOOD_BONUS 1.2). Nothing changes without it. `farmaw:1.8` = a bonus of 0.8.
To make it the default the owner would set `Defs.FOOD_BONUS` (0.8 for x1.8, 1.0 for x2.0).

### 3. The canister switch (`canlight:X`, a measuring switch, default unchanged)

`Game.canister_light`: canister's bonus on light units (Raptors, Spitters, Musketeers...) is Defs.CANISTER "vs_light" 1.5
unless `canlight:X` sets it. Used only in the fight test.

## Every block (Crown v Brood)

The ten games (Greenhold, Dune Sea, Frostfang, Ashford Crossing on both start spots; Hollowfen, Cinder Steps once), seeds
4100 + 97 r + 11 map + 3: the wr1000 crown-brood games. Each block played on a frozen copy of the code (main 0.38.177 for
the baseline, the branch with every change behind its switch for the rest), two games at a time.

BLOCKS_TABLE

Against the baseline, game by game (each game's numbers the mean of its three runs; d = the paired mean difference of g,
t its t value; better/worse = games whose g moved more than 0.05):

PAIRED_TABLE

Read: income 8 / 12 and army 8 / 12 are the Crown's over the Brood's at 8:00 and 12:00. The far-Rootmaw change already
shows at 8:00 (the Crown's income share 1.36 -> 1.66): the Brood's far Rootmaws pay from the first one, so the change
is not only a late one. The noise: one game won or lost moves a block's mean g by 0.2-0.4 (the three baseline blocks
were -1.70, -1.10 and -1.15), so only the 30-game pools are read.

## The side checks (10 games each)

SIDE_TABLE

## The fight test: do the Raptors go round the guns? (`tools/bench_raptor_flank.gd`)

A Crown force of 12 Musketeers, 3 Field Cannons and 2 Horsemen (the Crown computer's own line, guns, screen and rider
micro on) against a Brood force of the same value, three runs each, on Greenhold; "x3" = three times both forces (36
Musketeers, 9 guns, 6 riders against 162 Raptors). home: the Crown's line stands on its side of the map, the guns
unlimbered behind it, and the Brood comes at the hall behind it; field: the Crown marches as a wave and the Brood comes
at it head on; side: as field, but the Brood comes from the side of the march, at the guns' end. Raptor = all Raptors;
mixed = half Raptors, a quarter Spitters, a quarter Tyrant Challengers by value.

BENCH_TABLE

- **The Crown won 70 of the 72 fights** (the Brood wiped out, or a handful left when the 75 seconds ran out with the
  Crown far ahead); the two it lost were mixed Brood forces, both in the canister x2.0 runs (noise: x2.0 can only help
  the Crown). It lost a third to a ninth of what it killed. At equal cost a formed Crown force beats Raptors.
- **The Raptors reached the guns** mostly through or past the line's front (they slip between the men), seldom round
  its ends: of 534 creatures that reached a gun in the runs without the canister switch, 43 had come round a flank (31 of them in one kind of
  fight: a big wave met on the march). They reached the guns at once when they came from the side of a march: the guns
  were then the nearest thing. They took 2 to 7 guns in the big fights.
- **Canister x2.0 on light units** (from 1.5) helps against Raptors in the small fights (killed per lost 4.4 -> 9.0 at
  home, 4.6 -> 7.5 from the side) and little in the big ones or against a mixed force. Not needed: the Crown already wins
  these fights. Left as a switch, not recommended.
- **Riders on the line's flanks** (the candidate AI fix) is already what the Crown computer does: its screen pulls back
  to the line's flanks at contact (AICrownScreen, "pulls back to the line's flanks"). Nothing to add.

So the owner's suspicion is half right: the Raptors do get to the guns, but not round the flanks, and it does not lose
the Crown the fight. The Crown loses the game to the Brood's late income and to waves at halls where it has no army.

## The outlying halls (from the games' death lists, `tools/study/crown_brood_fix_labs.py`)

| 30 games | labourers lost a game | of them after 12:00 | killed by Raptors (after 12:00) | walking or running away | at work | Crown halls lost after 12:00 |
|---|---|---|---|---|---|---|
| today's game | 63.7 | 55.9 | 83% | 75% | 9% | 3.1 |
| the press | 51.7 | 46.7 | 79% | 78% | 7% | 2.7 |
| x1.8 | 39.5 | 35.1 | 85% | 78% | 6% | 1.8 |
| the press and x1.8 | 38.9 | 35.8 | 85% | 76% | 11% | 1.9 |

The labourers die running: a Labourer walks at 74, a Raptor at 92 (114 with Pack Hunt). AI._worker_safety sends them
away from a force they can't fight; against a faster enemy that only spreads them out to be caught. wr1000's `evac`
(walking them away earlier) lost more. What would help most, in order:

1. **Shelter in the hall** (a design change, the owner's call): labourers go inside their Town Hall when the bell rings
   (like Age of Empires' town bell), safe until it falls; the hall's 1,600 health buys the army the time to come. This
   is the only way a slow worker survives a fast raider.
2. **A Field Cannon and a few Musketeers posted at each outlying hall** from 12:00 (an AI change): canister kills Raptors
   best of anything the Crown has (the fight test: 4 to 9 times what it lost). Not measured here (time).
3. **Walls round every hall** (the computer walls only its natural today): Raptors are melee; a palisade with a gate
   turns them to the guns. Slow to build and costly for the Crown computer; not measured.
4. **Against faster enemies, labourers stand by the nearest soldiers instead of running** (AI): today they stand only
   when they would win.

## The AI tests

All 23 `tools/test_ai_*.gd` (tools/study/run_ai_tests.sh) on frozen copies of main 0.38.177 (before) and of this branch
with the press kept (after): `docs/crown_brood_fix/ai_tests_before.txt`, `ai_tests_after.txt`, reruns in
`ai_tests_reruns.txt`. **Before**: 20 pass; test_ai_rush, test_ai_rush_followup and test_ai_wall_vs_rush fail (all known,
CLAUDE.md). **After**: the same three, plus test_ai_cw_horse_raid (a Crown v Clockwork test the press cannot touch; on a
rerun it failed a different check, then passed: flaky, as CLAUDE.md lists it). test_ai_rush passed twice on a rerun on
both copies.

## Claude's choices for the owner

1. **The press is on by default** (KEPT): it passed the wr1000 rule (mean g up 0.3 or more and the score at 14:00 up
   clearly, t 3.0) over 30 games against 30. It is an AI change, not a number. `cbfpress:off` takes it back.
2. **The press goes once the army is twice the Brood army SEEN**, not the clock's reckoning (BROOD_TABLE), which held
   the Crown back while it was far ahead (wr1000 finding 1). It goes for the Mother, as the owner asked, through the
   siege push's own code (guns, line, riders) rather than a new attack.
3. **No balance default was changed.** x1.8 and x2.0 are switches only.
4. **The 2.0 blocks were played with the press on** (the press being kept, that is the game the owner would get).
5. **x1.8 was checked in the other Brood matchups** with 10 games each against 10 without; the Crown v Clockwork check
   is a check that nothing moved (neither change can act in it: the press needs a Brood foe, the Rootmaw pay a Brood).
6. **No AI fix for the Raptors at the guns**: the fight test found the Crown already wins those fights and already
   posts its riders on the line's flanks; the canister switch stays a measuring switch.
7. **The outlying halls were not changed** (proposals above): the AI changes tried by wr1000 there (`evac`) lost more,
   and the one that would work best is a design change.

## Files

- `scripts/ai_crown_brood_fix.gd` (AICrownBroodFix: the switch, KEPT, the press and its counters); hooks:
  `scripts/ai_crown_siege.gd` (_maybe_go, _go's press, the march's reach), `scripts/ai_crown.gd` (_army: the press outside
  the siege plan; _on_errand), `scripts/game.gd` (`farmaw:X` -> Game.food_bonus, `canlight:X` -> Game.canister_light),
  `tools/qa_match.gd` (the counters in result.json "crown_ai": cbf_presses, cbf_press_waves, cbf_press_looks).
- `tools/study/crown_brood_fix.py` (wr1000_crown_brood.py with its own data folder and `--me` / `--opp` for the side
  checks): `run BLOCK --extra a,b [--me brood --opp clockwork] [--root DIR]`, `results`, `report --base`.
- `tools/study/crown_brood_fix_labs.py` (the labourers and halls lost), `tools/bench_raptor_flank.gd` (the fight test).
- Data: `docs/crown_brood_fix/data/<block>/` (result.json, story.txt, planlog.txt with every "Crown's" line, extra.txt),
  `docs/crown_brood_fix/bench/*.json`.
