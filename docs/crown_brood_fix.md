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
| the press and x2.0 | 1 | 10 | 3 | 9 | 7 | 11 | 16 | -0.42 | +0.09 |

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
   so x2.0 was measured too, with the press: the Crown won or led 11 of 30, the Brood 16, the Crown beaten 7 times, and the
   score at 14:00 even (+0.09). That is "a bit more equal": the Brood still has the better of it, but no longer by far.
4. **The Raptors do not get round the guns**: in set-piece fights at equal cost the Crown's line, guns and riders beat
   the Raptor and mixed Brood forces in 70 of 72 fights, killing 2 to 9 times what they lost. Raptors reach the guns when they
   come from the side of a march or in big numbers, and take a gun or two, but they lose the fight. The Crown's trouble
   is the economy and where the fights happen, not the Raptors at the guns.
5. **The outlying halls**: 75% of the labourers lost after 12:00 die walking or running away, 83% of them to Raptors (a
   Raptor is faster than a labourer). The halls lost after 12:00 fell from 3.1 to 2.7 a game with the press and to 1.8-2.1 with the far-Rootmaw change; nothing in the
   AI alone saves the labourers. Proposals below.

**Recommended:** keep the press (done). For the balance, the owner's call: **x2.0** (`Defs.FOOD_BONUS` 1.2 -> 1.0, a far Rootmaw paying twice a near one
instead of 2.2 times). With the press it makes the Crown v Brood game close (Crown won or led 11 of 30, the Brood 16,
even at 14:00) and it costs the Brood little against the Clockwork (beaten 10 of 20 against 8 of 20 today: within the
noise). x1.8 goes further than asked: the Crown leads the matchup (19 against 9) and the Brood then loses more to the
Clockwork too (beaten 13 of 20 against 8). Or leave the number as it is and keep only the press (the Brood still won or
led 21 of 30).

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

| block | switches | games | won | led | even | behind | lost | mean g | g14 | inc 8 / 12 | army 8 / 12 | halls 12 | defeats (min) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b01 | (none) | 10 | 0 | 0 | 0 | 3 | 7 | -1.70 | -0.25 | 1.32 / 0.99 | 2.45 / 3.16 | 3.9 | 14.3, 14.9, 17.5, 17.6, 19.1, 19.5, 19.7 |
| b02 | (none) | 10 | 0 | 2 | 0 | 4 | 4 | -1.10 | -0.22 | 1.41 / 0.97 | 2.75 / 2.53 | 3.7 | 15.4, 16.5, 17.3, 17.7 |
| b03 | (none) | 10 | 0 | 1 | 0 | 5 | 4 | -1.15 | -0.07 | 1.36 / 1.00 | 2.36 / 2.34 | 3.6 | 14.1, 18.3, 19.0, 19.8 |
| p01 | cbfpress:on | 10 | 0 | 4 | 0 | 2 | 4 | -0.68 | +0.14 | 1.38 / 1.28 | 2.86 / 3.47 | 3.8 | 16.3, 16.6, 19.3, 19.9 |
| p02 | cbfpress:on | 10 | 0 | 1 | 0 | 5 | 4 | -1.17 | -0.06 | 1.40 / 1.05 | 2.31 / 1.36 | 3.9 | 17.1, 18.4, 18.4, 19.8 |
| p03 | cbfpress:on | 10 | 1 | 1 | 2 | 2 | 4 | -0.57 | +0.14 | 1.33 / 1.18 | 2.44 / 2.03 | 3.9 | 15.0, 18.6, 18.9, 20.0 |
| f01 | farmaw:1.8 | 10 | 0 | 5 | 0 | 2 | 3 | -0.43 | +0.29 | 1.66 / 1.36 | 2.66 / 1.97 | 4.1 | 16.4, 18.6, 18.9 |
| f02 | farmaw:1.8 | 10 | 0 | 6 | 1 | 1 | 2 | +0.09 | +0.41 | 1.69 / 1.41 | 2.60 / 4.64 | 3.8 | 18.6, 19.7 |
| f03 | farmaw:1.8 | 10 | 1 | 5 | 0 | 3 | 1 | +0.25 | +0.37 | 1.61 / 1.43 | 2.43 / 2.44 | 3.9 | 16.1 |
| pf01 | cbfpress:on farmaw:1.8 | 10 | 1 | 4 | 1 | 3 | 1 | +0.13 | +0.37 | 1.68 / 1.42 | 2.61 / 3.38 | 4.2 | 19.1 |
| pf02 | cbfpress:on farmaw:1.8 | 10 | 1 | 7 | 0 | 0 | 2 | +0.51 | +0.65 | 1.78 / 1.68 | 2.49 / 3.53 | 4.2 | 18.4, 19.9 |
| pf03 | cbfpress:on farmaw:1.8 | 10 | 2 | 4 | 1 | 2 | 1 | +0.53 | +0.50 | 1.62 / 1.61 | 2.68 / 7.34 | 3.9 | 16.7 |
| pf2a | cbfpress:on farmaw:2.0 | 10 | 0 | 4 | 0 | 4 | 2 | -0.48 | +0.07 | 1.50 / 1.16 | 3.05 / 1.98 | 3.8 | 15.3, 19.3 |
| pf2b | cbfpress:on farmaw:2.0 | 10 | 0 | 4 | 1 | 3 | 2 | -0.39 | +0.15 | 1.58 / 1.21 | 2.81 / 4.06 | 3.6 | 14.3, 17.2 |
| pf2c | cbfpress:on farmaw:2.0 | 10 | 1 | 2 | 2 | 2 | 3 | -0.40 | +0.05 | 1.48 / 1.27 | 2.91 / 2.94 | 3.6 | 14.6, 18.4, 19.1 |
| b01+b02+b03 | (none) | 30 | 0 | 3 | 0 | 12 | 15 | -1.32 | -0.18 | 1.36 / 0.99 | 2.52 / 2.68 | 3.7 | 14.1, 14.3, 14.9, 15.4, 16.5, 17.3, 17.5, 17.6, 17.7, 18.3, 19.0, 19.1, 19.5, 19.7, 19.8 |
| p01+p02+p03 | cbfpress:on | 30 | 1 | 6 | 2 | 9 | 12 | -0.80 | +0.07 | 1.37 / 1.17 | 2.54 / 2.29 | 3.9 | 15.0, 16.3, 16.6, 17.1, 18.4, 18.4, 18.6, 18.9, 19.3, 19.8, 19.9, 20.0 |
| f01+f02+f03 | farmaw:1.8 | 30 | 1 | 16 | 1 | 6 | 6 | -0.03 | +0.35 | 1.66 / 1.40 | 2.56 / 3.04 | 3.9 | 16.1, 16.4, 18.6, 18.6, 18.9, 19.7 |
| pf01+pf02+pf03 | cbfpress:on farmaw:1.8 | 30 | 4 | 15 | 2 | 5 | 4 | +0.39 | +0.51 | 1.70 / 1.57 | 2.59 / 4.66 | 4.1 | 16.7, 18.4, 19.1, 19.9 |
| pf2a+pf2b+pf2c | cbfpress:on farmaw:2.0 | 30 | 1 | 10 | 3 | 9 | 7 | -0.42 | +0.09 | 1.52 / 1.21 | 2.92 / 2.99 | 3.7 | 14.3, 14.6, 15.3, 17.2, 18.4, 19.1, 19.3 |

Against the baseline, game by game (each game's numbers the mean of its three runs; d = the paired mean difference of g,
t its t value; better/worse = games whose g moved more than 0.05):

| arm (30 games) against | d g (t) | games better / worse | d g at 14:00 (t) |
|---|---|---|---|
| the press v today | +0.51 (1.4) | 5 / 4 | +0.25 (3.0) |
| x1.8 v today | +1.28 (3.4) | 8 / 1 | +0.54 (5.0) |
| the press and x1.8 v today | +1.71 (4.7) | 9 / 1 | +0.69 (6.9) |
| the press and x2.0 v today | +0.89 (2.5) | 7 / 2 | +0.27 (2.4) |
| the press and x1.8 v the press alone | +1.19 (3.7) | 8 / 2 | +0.44 (4.4) |
| the press and x2.0 v the press alone | +0.38 (1.3) | 7 / 2 | +0.02 (0.2) |
| the press and x1.8 v x1.8 alone | +0.42 (1.6) | 8 / 2 | +0.15 (1.6) |

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

Each cell: creatures that reached a gun / of them, round the line's flank / guns lost · value killed for each lost.

| fight (3 runs each) | today, x1 | today, x3 | canister x2.0, x1 | canister x2.0, x3 |
|---|---|---|---|---|
| home, Raptors | 2 / 1 / 0 · 4.4 | 108 / 5 / 2 · 2.9 | 0 / 0 / 0 · 9.0 | 97 / 9 / 1 · 3.4 |
| home, mixed | 0 / 0 / 0 · 2.4 | 13 / 0 / 1 · 3.3 | 0 / 0 / 0 · 2.6 | 13 / 0 / 1 · 2.8 |
| field, Raptors | 0 / 0 / 0 · 7.5 | 59 / 31 / 3 · 2.0 | 2 / 0 / 0 · 9.6 | 13 / 1 / 0 · 2.1 |
| field, mixed | 0 / 0 / 0 · 2.5 | 0 / 0 / 0 · 3.0 | 5 / 1 / 3 · 2.2 | 1 / 0 / 0 · 2.3 |
| side, Raptors | 64 / 6 / 0 · 4.6 | 171 / 0 / 7 · 2.0 | 53 / 5 / 0 · 7.5 | 157 / 0 / 6 · 2.5 |
| side, mixed | 54 / 0 / 1 · 4.8 | 63 / 0 / 6 · 2.6 | 51 / 0 / 3 · 2.3 | 24 / 0 / 5 · 3.3 |

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
| the press and x2.0 | 45.0 | 39.6 | 79% | 79% | 6% | 2.1 |

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
