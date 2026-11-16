# Brood Rootmaw coach: new ground sooner (job brood-rootmaw-coach)

The owner's decision (2026-11-15 21:34, "yes", on docs/brood_rootmaw_spots.md section 4): coach the Brood COMPUTER to lay
its 4th, 5th and later Rootmaws on NEW GROUND sooner. **Only the computer's play changed** (scripts/ai_brood_new.gd):
no unit, price, yield, count or rule number was touched, nor the Crown's or the Clockwork's computers. Design rules
followed (docs/design_principles.md): 2 (the economy forces expansion and is depletable: take fresh ground as the old
runs dry), 4 (mastery of the economy: every choice an opportunity cost; a change kept only if the income rises without
the plan's character or its defence falling apart).

Measuring switch: **`maweco:off`** plays the old way (every change below is behind it).

## In short

- **What it does now** (from 5:00, the opening stays the plan's own): every 2 s it reckons the Rootmaws it will want a
  turtle's walk from now (its plan's curve, plus every Rootmaw walking for a spot or about to run dry) against the fresh
  room its swamps have and the room on its way; when short it roots a Mound Turtle on new ground at once: its turtle
  sites first, its own side first, then any fresh ground 18-40 tiles out where a Rootmaw fits. Not under the alarm, nor
  with an enemy at the Mother, a rush on, her growth due, or riders about (then 30 tiles out at most). A supply turtle the
  layout refuses at home no longer ends its think; while rich with posts to spare it lays up to 10 grubs over its plan's.
- **Alone** (9 runs, 12 min): the same until 5:00, +1% at 8:00, +6% at 10:00, **+9% at 12:00** (every run higher from
  9:00); 9.8 Rootmaws rooted at 12:00, was 6.3; its bank before the supply cap halves (701 at 9:00, was 1,438).
- **In games** (24 a side, Hard OPTIMAL): more Rootmaws in both pairings (8.3 at 12:00, was 6.9 v Crown and 5.3 v
  Clockwork); **against the Clockwork +8% at 8:00 and +14% at 12:00** (1.05 of its income at 12:00, was 0.94); against
  the Crown about even until 10:00 and +4% at 12:00 (it out-earns the Crown 1.3-1.4 either way). It loses more on the new
  ground (grubs, turtles; choice 7). W-D-L v Crown 3-9-0 both; v Clockwork 4-8-0 -> 1-10-1, within these games' spread
  (section 4).
- 9 Claude's choices (section 6); the switch `maweco:off` plays the old way.
- **Measured on 0.38.20** (main then, before and after alike). Main moved on to 0.38.34 meanwhile and is merged into the
  branch (0.38.35): no Brood computer file changed there, but the Crown's riders did (the Cavalry Charge package, Pack
  Hunt Raptors 124, Horseman 60 + horse 40, 0.38.31-0.38.33), so the games against the Crown are worth a rerun after the
  merge.

## 1. Where it lost (before)

Measured with the computer alone (tools/econ_ai_alone_brood.gd: the bench's setup, an idle dummy on the other side;
Greenhold, Dune Sea, Hollowfen; OPTIMAL, Balanced and Economy; 12 minutes; BEFORE = main at 0.38.20). Followed look
by look on Greenhold (OPTIMAL, which picks the Spitter timing alone):

1. **The turtle that makes room came last.** In `_nb_morphs` the "no room for a Rootmaw: a turtle on new ground" rule
   ran only when nothing else was chosen (no supply turtle, no Sire, no Rootmaw), not within 45 s of the last turtle
   sent out, and never past 6 turtles out there (spent ones counted). From 8:00 the plan wanted 8 Rootmaws and had 7.
2. **A refused supply turtle ended the think.** With 500 food or more the supply rule keeps 12 more supply ahead, so a
   supply turtle was asked for on most thinks; when the whole-map layout check refused its spot at home ("It would shut
   59 of its own in") the think ended there, and from 8:00 to 9:30 neither a turtle nor a Rootmaw came.
3. **The turtle sites run out.** A side has its own handful of turtle sites (the base sites rated for a hall,
   ExpansionSpots.nb_rate; Greenhold: 5 for a side). By 7:00 its 3 own were taken and the other 2 lay past the enemy's
   natural (61-64 tiles out), so nothing was left inside the 40-tile reach.
4. **Far Rootmaws run dry in about six minutes** (a far Rootmaw drinks x2.2 faster: Game.food_mult), so the ones laid
   at the natural and the third at 4:00-5:30 were spent by 10:00-11:00 and walked about with no room anywhere: 6 rooted
   and 2 walking from 10:15 to 12:00, while 6,000 food piled up.
5. **The grubs stood at the plan's cap** (50-58) from 7:00 while the posts grew (68 for 50 grubs at 8:00); with the
   Rootmaws its income is drink-bound, with more Rootmaws it becomes grub-bound. Its bank (1,000-2,000 from 8:00, then
   5,000-8,000 at the 200 supply cap) had nothing to go into.

## 2. What changed

| change | what | why |
|---|---|---|
| **new ground when due** (`_maw_expand_due`, `_maw_need_room`) | every 2 s: the Rootmaws that will want a spot within a turtle's walk (EXP_LEAD 50 s ahead on the plan's own Rootmaw curve, and every Rootmaw walking for a spot or about to run dry, under MAW_DRY 900 food left; one up to fight keeps its spot and does not count) against the room on FRESH ground the swamps have now (RootmawSpots' marks, `_nb_spot_ok`) and the room the turtles on their way to new ground bring (2 each). Short = a turtle on new ground now, as a morph of its own, after the first Sire, the supply turtle and the later Sires, before Rootmaws | 1 |
| **a refused home turtle goes out** | a supply turtle the layout refuses at home goes to the new-ground spot instead of ending the think | 2 |
| **no cap of 6 out there** | the old "no room: a turtle on new ground" rule no longer stops at 6 turtles out (spent ground counted); the need above decides | 1, 4 |
| **fresh ground off the sites** (`_nb_fresh_turtle_spot`, `_fresh_room`) | once the side's turtle sites are taken or spent, any spot a turtle may root on 18-40 tiles from the Mother (the distance pay peaks at 24), on its own side of the map (`_toward_foe`), with fresh ground, where at least one Rootmaw circle fits on its level clear of every circle of the side's (rooted, planned or spent ground); looked for at most every 5 s | 3, 4 |
| **safety** | no new ground while the alarm is on (an enemy army seen out of its main in the last 75 s), an enemy is at the Mother, a rush it is short against is on, it rebuilds after a rush, or it is under-armed with under 30 army supply; a site with an enemy building seen within 16 tiles is skipped (`_site_unsafe`); its own side's sites before those nearer the enemy's start; the reach drops from 40 to 30 tiles while its scout read a rush, riders are read or riders were seen in the last 90 s (`_exp_reach`); the old checks stay (no visible enemy within 12 tiles, a site a grub died going to is left 3 minutes) | the owner's "not into the enemy's army" |
| **the banked food into grubs** (`_extra_grubs`) | while rich (500 food over her growth's savings), with posts for 4 more grubs than the plan's cap, supply to spare and no danger (under-armed, the alarm, an enemy at the Mother), the plan's grub cap rises a grub every 3 s, up to EXTRA_GRUBS 10 more; kept once raised; never in the Rush or Extreme rush | 5 |
| **the plan's own timing kept** | not before 5:00 (EXP_FROM: the opening is the plan's own, section 5), not while her growth is due (`_nb_growth_keep`), not within a minute of the plan's own next expansion (EXP_PLAN_NEAR 60 s: that one, not one more); the Rush and Extreme rush never before their wave | measured (sections 3 and 5) |

Not changed: the plan's own Rootmaw curve (`maws`), its expansions list (`far`), the rush plans' grub holds before their
wave, the under-armed rule, the rider defence, which plan OPTIMAL picks.

## 3. The computer alone (before / after)

`tools/econ_ai_alone_brood.gd`, 12 minutes, Greenhold, Dune Sea and Hollowfen, three plans (OPTIMAL, which alone picks
the Spitter timing, Balanced and Economy): 9 runs a side. BEFORE = main 0.38.20; AFTER = this branch. Food earned,
cumulative, the mean of the 9 (the alone games are deterministic: one run a map and plan). Data:
docs/brood_rootmaw_coach/alone/.

| | 5:00 | 8:00 | 9:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|
| earned, before | 3,086 | 9,167 | 11,536 | 13,850 | 18,675 |
| earned, after | 3,086 | 9,299 | 11,841 | 14,694 | **20,397** |
| change | 0.0% | +1.4% | +2.6% | +6.1% | **+9.2%** |
| Rootmaws rooted, before / after | 4.8 / 4.8 | 7.1 / 7.3 | 7.2 / 8.2 | 7.0 / 9.1 | 6.3 / **9.8** |
| turtles on new ground, before / after | 1.4 / 1.4 | 2.7 / 5.0 | 3.8 / 7.1 | 6.8 / 9.0 | 7.7 / 9.2 |
| grubs, before / after | 32 / 32 | 53 / 55 | 54 / 59 | 54 / 61 | 54 / 61 |
| food banked, before / after | 70 / 70 | 875 / 570 | 1,438 / 701 | 2,260 / 2,334 | 7,038 / 7,901 |

Per run (earned at 5:00 / 8:00 / 10:00 / 12:00, before -> after; Rootmaws rooted at 12:00):

| plan, map | 5:00 | 8:00 | 10:00 | 12:00 | Rootmaws 12:00 |
|---|---|---|---|---|---|
| OPTIMAL, Greenhold | 2,622 -> 2,622 | 8,437 -> 8,527 | 13,102 -> 14,124 | 17,379 -> 19,593 | 6 -> 10 |
| OPTIMAL, Dune Sea | 2,641 -> 2,641 | 8,076 -> 8,363 | 12,377 -> 13,395 | 17,105 -> 19,159 | 6 -> 10 |
| OPTIMAL, Hollowfen | 3,124 -> 3,124 | 8,958 -> 9,033 | 12,995 -> 13,472 | 17,285 -> 18,056 | 7 -> 10 |
| Balanced, Greenhold | 3,282 -> 3,282 | 9,507 -> 9,633 | 14,478 -> 15,509 | 19,310 -> 21,404 | 6 -> 10 |
| Balanced, Dune Sea | 3,260 -> 3,260 | 9,399 -> 9,401 | 13,910 -> 14,592 | 18,808 -> 19,845 | 7 -> 10 |
| Balanced, Hollowfen | 3,977 -> 3,977 | 9,774 -> 10,098 | 14,118 -> 14,855 | 18,508 -> 20,335 | 6 -> 9 |
| Economy, Greenhold | 2,760 -> 2,760 | 9,311 -> 9,439 | 14,500 -> 15,805 | 19,663 -> 22,081 | 7 -> 10 |
| Economy, Dune Sea | 2,659 -> 2,659 | 9,176 -> 9,122 | 14,496 -> 14,980 | 20,060 -> 21,219 | 6 -> 9 |
| Economy, Hollowfen | 3,452 -> 3,452 | 9,863 -> 10,075 | 14,676 -> 15,515 | 19,955 -> 21,884 | 6 -> 10 |

- **Until 5:00 it plays exactly as before** (the same food to the unit in all 9 runs): the opening is the plan's own.
- **From 9:00 on it earns more in every run**, +4% to +13% at 12:00 (17 of 18 runs higher at 8:00 and 10:00 together):
  at 12:00 it has 9-10 Rootmaws rooted where it had 6-7 (one or two of them walking about with no room) and 61 grubs
  where it had 54.
- **A minute at 12:00** (the 2 minutes before): OPTIMAL 2,636 (was 2,216), Balanced 2,771 (was 2,353), Economy 3,147
  (was 2,668). The Clockwork computer alone made 2,796 cogs a minute and the Crown 2,367 gold in the same setup
  (docs/brood_rootmaw_spots.md section 3). The Brood's bench (its design, the scripted build) is 2,176 a minute at 12:00:
  the computer earns more than the bench, as it did before the count (the bench stops at 7 Rootmaws and banks).
- **The bank before the supply cap halves** (9:00: 701, was 1,438). From about 10:00 the computer alone stands at the 200
  supply cap (an idle dummy never kills its army) and whatever it earns piles up: alone, the bank at 12:00 is the cap's,
  not the room's.
- **What the rule did at 3:15-3:45 when it ran from 0:30** (measured, then gated to 5:00): OPTIMAL +6% at 8:00 alone (its
  second new ground 65 s sooner), the Economy plan -5% at 5:00 and its first research 40 s late (test_ai_brood), and in
  the games the opening's grubs short (section 4): choice 2.
- **`maweco:off` plays the old way**: Greenhold and Dune Sea OPTIMAL alone give main's numbers to the food until 8:00
  and within 0.4% at 12:00 (the measuring tool's own look at the room the computer counts).
- Its thinking costs about what it did (the runs' wall time within 0-6%, with more creatures on the map).

## 4. The computer games (before / after)

Hard OPTIMAL against Hard OPTIMAL to 12:00, `qa_matches.py --only brood` as docs/brood_rootmaw_spots.md section 4 (Greenhold,
Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps; Brood v Crown and Brood v Clockwork; round 0 and round 1
swap the sides): 24 games on main 0.38.20 (BEFORE) and the same 24 on this branch (AFTER). No game crashed or printed a
script error. Data: docs/brood_rootmaw_coach/games/; tables: `tools/study/brood_coach_report.py` (paired: at each minute
only the games still on in both runs) and `tools/study/brood_spots_report.py` (as the spots job reported).

#### Brood v Crown: 12 games paired; Brood W-D-L before 3-9-0, after 3-9-0

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| games still on in both | 12 | 12 | 11 | 9 |
| Brood earned, before | 2791 | 6826 | 10345 | 13725 |
| Brood earned, after | 2802 | 6817 | 10431 | 14327 |
| change | +0.4% | -0.1% | +0.8% | +4.4% |
| games where it earned more | 7 of 12 | 7 of 12 | 7 of 11 | 6 of 9 |
| Crown earned, before | 2913 | 5510 | 8152 | 10373 |
| Crown earned, after | 2881 | 5288 | 8118 | 11246 |
| Brood / Crown, before | 0.96 | 1.24 | 1.27 | 1.32 |
| **Brood / Crown, after** | 0.97 | 1.29 | 1.28 | 1.27 |
| Brood Rootmaws, before | 4.2 | 5.9 | 6.6 | 6.9 |
| Brood Rootmaws, after | 4.2 | 6.5 | 8.2 | 8.3 |
| Brood grubs, before | 23 | 46 | 49 | 50 |
| Brood grubs, after | 24 | 47 | 50 | 57 |
| Brood bank, before | 58 | 244 | 546 | 610 |
| Brood bank, after | 32 | 155 | 231 | 964 |
| Brood army, before | 500 | 1098 | 2118 | 2950 |
| Brood army, after | 483 | 1024 | 2230 | 2504 |

Games (before -> after: result, end):
- base_ashford_crossing_crbr_r0: D 12:00 -> D 12:00
- base_ashford_crossing_crbr_r1: D 12:00 -> D 12:00
- base_cinder_steps_crbr_r0: D 12:00 -> D 12:00
- base_cinder_steps_crbr_r1: D 12:00 -> D 12:00
- base_dune_sea_crbr_r0: W 11:55 -> W 10:07
- base_dune_sea_crbr_r1: D 12:00 -> D 12:00
- base_frostfang_crbr_r0: D 12:00 -> D 12:00
- base_frostfang_crbr_r1: D 12:00 -> D 12:00
- base_greenhold_crbr_r0: D 12:00 -> D 12:00
- base_greenhold_crbr_r1: D 12:00 -> D 12:00
- base_hollowfen_crbr_r0: W 11:54 -> W 11:37
- base_hollowfen_crbr_r1: W 10:21 -> W 9:54

#### Brood v Clockwork: 12 games paired; Brood W-D-L before 4-8-0, after 1-10-1

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| games still on in both | 12 | 9 | 9 | 7 |
| Brood earned, before | 2354 | 5364 | 8908 | 11872 |
| Brood earned, after | 2313 | 5807 | 8852 | 13552 |
| change | -1.7% | +8.3% | -0.6% | +14.2% |
| games where it earned more | 4 of 12 | 6 of 9 | 4 of 9 | 5 of 7 |
| Clockwork earned, before | 3441 | 7348 | 10188 | 13578 |
| Clockwork earned, after | 3616 | 7349 | 10082 | 12066 |
| Brood / Clockwork, before | 0.68 | 0.73 | 0.87 | 0.87 |
| **Brood / Clockwork, after** | 0.64 | 0.79 | 0.88 | 1.12 |
| Brood Rootmaws, before | 3.3 | 4.6 | 5.4 | 5.3 |
| Brood Rootmaws, after | 3.2 | 5.0 | 5.8 | 8.3 |
| Brood grubs, before | 19 | 34 | 46 | 49 |
| Brood grubs, after | 20 | 37 | 46 | 49 |
| Brood bank, before | 31 | 170 | 637 | 656 |
| Brood bank, after | 47 | 318 | 506 | 664 |
| Brood army, before | 510 | 894 | 1012 | 1902 |
| Brood army, after | 435 | 880 | 1186 | 2249 |

Games (before -> after: result, end):
- base_ashford_crossing_brcw_r0: D 12:00 -> D 12:00
- base_ashford_crossing_brcw_r1: W 11:24 -> D 12:00
- base_cinder_steps_brcw_r0: D 12:00 -> D 12:00
- base_cinder_steps_brcw_r1: D 12:00 -> D 12:00
- base_dune_sea_brcw_r0: D 12:00 -> D 12:00
- base_dune_sea_brcw_r1: D 12:00 -> L 10:54
- base_frostfang_brcw_r0: D 12:00 -> D 12:00
- base_frostfang_brcw_r1: W 7:13 -> D 12:00
- base_greenhold_brcw_r0: W 6:39 -> D 12:00
- base_greenhold_brcw_r1: D 12:00 -> D 12:00
- base_hollowfen_brcw_r0: W 7:12 -> W 11:49
- base_hollowfen_brcw_r1: D 12:00 -> D 12:00

As the spots job counted (every game, a game over before a minute counted at its last minute):

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| Brood / Crown, before | 0.96 | 1.24 | 1.31 | 1.42 |
| **Brood / Crown, after** | 0.97 | 1.29 | 1.34 | 1.40 |
| Brood / Clockwork, before | 0.68 | 0.82 | 0.93 | 0.94 |
| **Brood / Clockwork, after** | 0.64 | 0.82 | 0.92 | **1.05** |
| Brood a minute v Crown, before / after | 845 / 849 | 1,479 / 1,427 | 1,831 / 1,829 | 1,553 / 1,686 |
| Brood a minute v Clockwork, before / after | 669 / 649 | 891 / 1,335 | 1,328 / 1,579 | 1,076 / 1,676 |
| Brood Rootmaws v Crown, before / after | 4.2 / 4.2 | 5.9 / 6.5 | 6.7 / 8.2 | 6.9 / 8.3 |
| Brood Rootmaws v Clockwork, before / after | 3.3 / 3.2 | 4.5 / 5.2 | 5.2 / 6.2 | 5.2 / 7.8 |

**What it shows.**
- **More Rootmaws in both pairings from 8:00** (v Crown 6.6 -> 8.2 at 10:00, v Clockwork 5.3 -> 8.3 at 12:00, the
  games still on in both), on new ground: the rule works in games as alone.
- **Against the Clockwork the income follows**: +8% at 8:00 (6 of 9 games higher), +14% at 12:00 (5 of 7); a minute,
  1,676 food at 12:00 against 1,076 before, and 1.05 of the Clockwork's income at 12:00 (was 0.94). Its army at 10:00
  and 12:00 is a little bigger (1,186 and 2,249, was 1,012 and 1,902).
- **Against the Crown it is about even** until 10:00 (+0.4% / -0.1% / +0.8%) and +4% at 12:00 (6 of 9 higher). There the
  Brood already out-earned the Crown 1.24-1.42 before; its income is held by the riders' raids (the grubs pulled back,
  the warriors guarding them) more than by room, and its army at 8:00 is about the same (1,024, was 1,098).
- **At 5:00 nothing of the rule acts** (EXP_FROM): the -1.7% against the Clockwork at 5:00 (4 of 12 higher) is the games'
  own spread: these games are not repeatable to the frame (the qa study: the same map and seed agree about 2 times in
  3). The same spread shows in the results: the Brood's three wins by 7:15 against the Clockwork before (its rush
  through a thin guard) were draws after, its rush pulled back at 3:46-4:10 after, with the stories the same up to the attack (2:48-2:57)
  and differing by a second from it. The Brood's W-D-L: v Crown 3-9-0 both; v Clockwork 4-8-0 -> 1-10-1 (one loss,
  Dune Sea round 1, at 10:54). With 12 games a pairing a win or two either way is within that spread; nothing in the
  rule acts before 5:00.

**The steps that were measured and dropped on the way** (the same 24 games, run while the rule was being shaped):
- the rule from 0:30 with the supply turtles sent out to new ground as well (10 + 10 games): v Clockwork +14% at 8:00,
  but **v Crown -5% at 8:00 and its army 732 at 8:00, was 1,029**: a supply turtle walking 25-40 tiles out gives its
  supply a minute late, and the warriors waited for it. The supply turtles stay at home now (only the one the layout
  refuses at home goes out);
- the rule from 5:00 with the supply turtles still sent out (9 + 8 games): v Crown -1% at 8:00, v Clockwork +10%.

## 5. Tests

__TESTS__

## 6. Claude's choices for the owner to confirm

1. **The trigger** (section 2): the Rootmaws wanted a turtle's walk ahead (50 s on the plan's own Rootmaw curve, the
   walking ones, the ones under 900 food left) against the fresh room now and the room on its way (2 for each turtle on
   its way, though in a grown base about one fits round a new turtle: the circles of its neighbours crowd it; counting 2
   keeps it from over-sending).
2. **Not before 5:00** (EXP_FROM): the opening stays the plan's own. From 0:30 the rule gave OPTIMAL alone +6% at 8:00
   (its second new ground at 3:45, was 4:50) but cost the Economy plan 5% at 5:00 and its first research 40 s, and the
   games' openings grubs. A different gate is one number.
3. **Fresh ground off the sites**: once its own turtle sites are taken, any spot 18-40 tiles out on its own side where one
   Rootmaw circle fits clear of all the side's circles (not two: a turtle for one far Rootmaw still pays, 3,000 food at up
   to x2.2 for 100 + 75). Without it the computer had nowhere to go on Greenhold from 7:00 (5 sites a side, 2 of them past
   the enemy's natural).
4. **More grubs than the plan's cap** (EXTRA_GRUBS 10) while rich with posts to spare: "grubs" was one of a plan's
   numbers; the Rush and Extreme rush keep theirs. test_ai_brood's grub check now allows the raise. In the games it seldom
   triggers (500 food over her growth with no alarm and not under-armed): 57 grubs at 12:00 against the Crown, was 50.
5. **The supply turtles stay at home**: sending them out as well (the same turtle for supply and room) cost the army a
   quarter at 8:00 against the Crown (its supply a minute late); only one the layout refuses at home goes out now.
6. **Safety**: no new ground while the alarm is on, an enemy is at the Mother, a rush it is short against is on, it
   rebuilds after a rush or it is under-armed with no army; sites by enemy buildings it has seen skipped; its own side of
   the map first (and only, for the fresh-ground spots); 30 tiles out at most while a rush is read or riders were seen in
   the last 90 s, 40 otherwise (the old no-room rule's reach). The safety order and filter also apply to the plan's own
   expansions (the natural, the third) from the start: the one change before 5:00, and none of the 9 alone runs changed
   by it.
7. **No escort for a new turtle**: the owner's brief named "guards for an exposed turtle per its plan". Not built: the
   army's posts are unchanged, and its defence already answers enemies at every rooted creature of its own within its
   home reach (`_nb_home_foes`: the Mother and each rooted turtle and Rootmaw, a squad sized to them; a Rootmaw attacked
   uproots and fights or backs off, `_nb_maw_guard`); the gates above keep new ground away from where the enemy is
   known. **The price shows in the games** (24 a side, losses after 5:00, a game-minute being one minute of one game):
   grubs lost 0.39 -> 0.65 a game-minute against the Crown and 0.32 -> 0.87 against the Clockwork (the before games
   against the Clockwork were shorter: three ended in Brood wins by 7:15), Mound Turtles 0 -> 5 and 5 -> 10, Rootmaws 1 ->
   2 and 9 -> 14. Against the Clockwork that is about 300 food of grubs a game for about +1,700 food earned by 12:00.
   A next job: post the plan's home guard (2-4 Raptors) by the newest new-ground turtle, or root the next turtle
   between the last and home.
8. **The old "never past 6 turtles out" cap is gone** (it counted turtles on spent ground): the need decides.
9. **Measuring switch `maweco:off`**: every change above (also the safety order of the plan's own expansions and the
   grub raise) is behind it.

## 7. What is left

- **Turtles on spent ground** stay rooted (supply only): at 12:00 alone about 9 turtles stand out on new ground, several
  with their Rootmaws gone dry. Getting one up and walking it to fresh ground (as the other computers recycle a spent
  Farm or Cog Press) would save 100 food and a grub a time and lose 12 supply for its walk; not done.
- **12-minute games** see the first payback only: a far Rootmaw drinks its 3,000 in about six minutes, so new ground laid
  at 6:00-9:00 pays most after 12:00.
- **Against the Crown** the Brood's income is held by the riders' raids more than by room (it out-earns the Crown 1.3-1.4
  either way).
- **For the owner (balance, no number changed)**: the Brood computer alone now earns about what the Clockwork computer
  alone does a minute at 12:00 (2,636-3,147 against 2,796) and in the games 1.05 of the Clockwork's income at 12:00 (was
  0.94) and 1.40 of the Crown's. Its design (the bench) is still 0.87-0.93 of the others from 8:00; as the economy-parity
  study found, the computers, not the design, set these ratios.

## How to run it

- The computer alone: `godot --headless --fixed-fps 30 --script res://tools/econ_ai_alone_brood.gd -- brood plan=<plan>
  map=<map> minutes=12 out=<file.json> [maweco:off]`; each look now also has `maw_need` [Rootmaws needing a spot soon,
  fresh room, room coming] and `exp_sent`; `dbgmaw=<seconds>` prints, every 30 s from then, the Rootmaws not rooted, every
  turtle site of the side and why it is or isn't free, each swamp's count and fit, and the fresh-ground search's answer.
- The games: `python3 tools/study/qa_matches.py run OUT --data DATA --only brood --end 720 [--root DIR]` (before: a
  worktree of main as `--root`); the tables: `python3 tools/study/brood_coach_report.py BEFORE_DATA AFTER_DATA` (paired)
  and `python3 tools/study/brood_spots_report.py DATA`.

