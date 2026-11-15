# Crown coaching: the army's size and timing (crown-coach-army)

The owner's complaint (2026-11-15 00:28, his watched game on Hollowfen, seed 4287366311, Hard OPTIMAL v Hard OPTIMAL,
v0.38.1; the log is on branch playtest-logs, docs/playtests/2026-11-15_0021_crown_v_clockwork_hollowfen.txt): "Terrible game
from crown ... that is why it can never win, the ai is very bad." This job covers the **army's size and timing** only: in
his game the Crown had 3 Musketeers (180) to the Clockwork's 4 Clock Soldiers at 4:00, 5 to 8 at 5:00, 3 to 11 at 6:00,
while 160 powder lay unused. Four other Crown coaching jobs worked at the same time on the balloon harass, the defence, the
economy and the Brood matchup; all four were merged into main while this ran (0.38.4 defence, 0.38.7 balloons, 0.38.8
economy, 0.38.9 cavalry, 0.38.11 Brood) and this branch has them all (0.38.12). AI only: no unit, building or economy number
was changed. The switch `-- crownarmy:off` plays as before.

**In short.** The Crown's army is now ready for the Clockwork's first push: on today's code (0.38.11, with the economy
coaching) it has 94 of army at 4:00 instead of 60, 244 at 5:00 instead of 141, 453 at 6:00 instead of 364, and meets the
first push at its base with 594 instead of 525; it loses fewer men for each Clockwork one, and holds more army and halls at
12:00. The price is income: the soldiers come before some labourers until 6:30, about 10% less gold earned by 8:00. Results
by 15:00 stay within the noise (0 wins either way; 8 losses in 16 against 7, and the same build with the clock off lost 7
and 9 in two batches). Against the Brood nothing changes (its own reckoning, the Brood coaching job). The Crown still
cannot win against the Clockwork's economy (1.6-1.9 times its gold by 8:00).

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
5. **On today's build (the economy coaching, 0.38.8 on) the army is later still.** OPTIMAL now often picks the Economy plan,
   whose Powder Mill comes after the second hall (laid 3:50, grinding 4:20), and the natural's palisade and the labourers
   take the harvests first: the Crown had 60 of army at 4:00 and 141 at 5:00 (16 games), the Barracks idle 219 s of the
   first six minutes, 70 s of it waiting for powder; in one game 0 army at 5:27 against the Clockwork's 460.

## What changed (scripts/ai_crown_army.gd, AICrownArmy; small hooks in ai_crown.gd, ai_crown_ammo.gd and ai_expand_wall.gd)

1. **The army clock.** From 2:30 to 6:30, with 10+ labourers, the Crown's army (with what its Barracks and Foundries train;
   balloons, wagons and horses do not count) is kept at 60% of the army a Hard computer of the enemy's faction usually has
   45 s from now (AICrownArmy.TABLE, measured above: Clockwork 150 at 4:00, 400 at 5:00, 700 at 6:00, 1,100 at 7:00), or
   60% of what it saw lately if that is more, less half what it has killed. The 45 s look ahead is a Musketeer's training and
   his walk to his post. While it is behind ("the army on time: ... soldiers before more labourers", an AI STORY line in
   en/pt/es), and a Barracks stands empty that can train a Musketeer now:
   - in the opening a labourer waits for the soldier (AICrown._soldiers_first), the opening's army cap does not hold, and
     the soldiers start at once if the plan's "army" step has not come yet;
   - the opening's next step leaves a Musketeer's price for each such Barracks out of the gold it holds;
   - the natural's palisade does not take the gold first (AICrown.wall_first), and no Church is bought for a wall slot.
   A Barracks waiting for powder does not hold the labourers (on 0.38.10, with the economy's rule sending the Mill's hands to
   the Farms, it held both the labourers and the soldiers: 123 s of the first 6 minutes waiting for powder, half the army at
   8:00 and 11 games lost in 16).
2. **Powder for the first Musketeers.** In every matchup a Barracks idle with a Musketeer's gold but not his powder counts as
   using the powder, so the Mill's crew grows (AICrown._mill_feedback: it kept one hand while nothing could train). While
   behind the clock: the plan's own Powder Mill step comes now (the Economy plan's came at 3:50 and its army was 0 at 5:27
   against 460), the Mill takes three hands while a Barracks waits for powder, and a Musketeer may come out with his bayonet
   while the Mill starts, to fill up when it grinds (the owner's ammunition rule; AICrownAmmo.musket_ok).
3. **Gated by matchup**: the clock plays against the Clockwork and the Crown mirror only. Against the Brood the Crown already
   reckons the Brood's army (army_behind; the Brood coaching job's vb_line_short), and a Crown that kept 60% of the Brood's
   usual army (1,350 at 5:00) would never train another labourer.

Switches: `-- crownarmy:off` (all of it); for studies `crownarmy:share=0.75` (the share), `crownarmy:until=420` (the end),
`crownarmy:room=2` (a second queued soldier before a labourer), `crownlead:off` (no look ahead), `crownarmy:lags` (army_lags
too), `crownarmy:nodry` (no bayonet Musketeers), `crownarmy:noclock` (the clock off, the powder fix kept).

## The owner's game again (Hollowfen, filmed: tools/shot_ai_match.gd, pictures in docs/shots/crown_coach_army/)

The headless game with the owner's seed picks the Timing attack; seed 1 (the Crown in slot A, both OPTIMAL) picks the
Balloon harass and plays the owner's game: the Clockwork's 8 Clock Soldiers leave at 4:30-4:39.

| build | 4:00 | 5:00 | 6:00 | 7:00 | kills / losses by 7:00 |
|---|---|---|---|---|---|
| 0.38.5 before (`crownarmy:off`) | 2 Musketeers v 4 Clock Soldiers | 4 v 10 | 5 v 14 | 5 (and a Missionary) v 14 + 2 Springers, a Netter | 1 / 6 |
| 0.38.5 after (75%, till 7:00) | 4 v 4 | 8 v 10 | 12 v 12 + a Netter, 2 Springers | 12 (and a rider, a wagon) v 12 + 2 Netters, 3 Springers | 6 / 3 |
| 0.38.12 before (with the defence, balloon and economy coaching) | 2 v 4 | 4 v 9 | 7 v 12 + a Springer | 11 v 8 + 4 Springers, 2 Netters | 6 / 7 |
| 0.38.12 after (the defaults) | 3 v 4 | 5 v 10 | 8 v 12 + a Netter | 12 v 11 + a Netter, 4 Springers, a Ballista | 4 / 5 |

The pictures are of the 0.38.5 pair. Before, the powder piled up to 200 unused by 7:00 and the Clockwork was at the natural at 6:17-6:32, a building burning
(before_0617_push_at_natural.jpg, before_army_0632.jpg). After, a line of 8-12 Musketeers holds the ramp from 5:00
(after_army_0602.jpg, after_army_0632.jpg) and at 7:13 fires down from the main's edge on the Clockwork at the natural's hall
(after_0713_line_over_natural.jpg, the same spot as before_0617). The Clockwork still out-earns it (7,700 to 4,900 by 7:00). On
0.38.12 the other jobs' fixes already keep more men at home (the balloon waits for its Musketeers, the defence), and the clock
adds a Musketeer a minute in this game; the gold earned is the same by 7:00 (4,940 both). In both the line fires down from
the main's edge on the push at the natural's hall (v0_38_12_before_0643.jpg, v0_38_12_after_0635.jpg).

## The batches (tools/study/crown_army.py with tools/measure_crown_army.gd; Hard OPTIMAL v Hard Clockwork OPTIMAL, 8 maps
(Greenhold, Dune Sea, Hollowfen, Kestrel Rise, Ashford Crossing, Red Coast, Frostmere, Border March), the Crown in slot A on
odd seeds, slot B on even ones, 16 games a line, to 15:00)

Army values are the means at the minute (the Crown's / the Clockwork's). "At base": the Clockwork's force and ours when it
first reached our base with 300+. "Lost": units lost (the Crown's v the Clockwork's). Each "before" is the same build with
`crownarmy:off`. **Mind the noise**: the same build with the clock off lost 7 and 9 games of 16 in two batches (p_off and the
noclock line below, which differ only by the powder fix); a difference of two or three losses is not a result.

| build, version | W-D-L | army 4:00 | 5:00 | 6:00 | 7:00 | 8:00 | 10:00 | at base | Barracks idle 0-6 min (powder) | lost | earned 8:00 | halls / army 12:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0.38.1 before | 0-11-5 | 169/162 | 393/402 | 569/728 | 737/1127 | 1183/1799 | 1506/3098 | 813 v 779 | 192 s (40) | 65 v 104 | 5,652 | 2.12 / 1,178 |
| 0.38.1 first clock (75%, all game, army_lags) | 0-13-3 | 139/166 | 418/391 | 643/683 | 872/1035 | 1306/1581 | 1582/3004 | 694 v 665 | 164 s (36) | 58 v 107 | 5,676 | 2.12 / 1,379 |
| 0.38.5 before | 0-10-6 | 176/162 | 405/398 | 581/709 | 884/1155 | 1304/1764 | 1256/3169 | 732 v 822 | 185 s (39) | 79 v 81 | 5,558 | 1.62 / 743 |
| 0.38.5 the same first clock | 0-9-7 | 158/162 | 417/398 | 636/693 | 885/1102 | 1270/1680 | 1642/2816 | 590 v 695 | 171 s (36) | 74 v 96 | 5,676 | 2.25 / 1,141 |
| 0.38.10 before | 0-10-6 | 64/162 | 144/382 | 362/747 | 648/1292 | 1119/1870 | 1432/3123 | 748 v 723 | 223 s (68) | 81 v 92 | 6,769 | 1.81 / 831 |
| 0.38.10 the clock of 0.38.5 (a Barracks waiting for powder held the labourers) | 0-5-11 | 101/166 | 173/387 | 333/725 | 507/1207 | 593/2099 | 847/4151 | 1087 v 372 | 214 s (123) | 62 v 48 | 5,082 | 0.94 / 382 |
| 0.38.11 before | 0-9-7 | 60/158 | 141/384 | 364/760 | 689/1262 | 1152/1904 | 1475/3141 | 717 v 525 | 219 s (70) | 91 v 86 | 6,650 | 1.38 / 940 |
| 0.38.11 the powder fix only (`noclock`) | 0-7-9 | 60/158 | 125/391 | 370/721 | 698/1141 | 1110/1816 | 1330/3019 | 724 v 502 | 218 s (67) | 91 v 79 | 6,531 | 1.56 / 674 |
| 0.38.11 75%, two queued, till 7:00 | 0-8-8 | 116/153 | 266/382 | 521/712 | 782/1177 | 1063/1907 | 1300/3330 | 722 v 660 | 163 s (43) | 75 v 81 | 5,748 | 1.12 / 671 |
| 0.38.11 50%, till 6:30 | 0-6-10 | 98/153 | 260/391 | 486/752 | 734/1155 | 1010/1758 | 1385/3342 | 832 v 670 | 182 s (40) | 84 v 76 | 5,914 | 1.50 / 658 |
| **0.38.11 after (60%, an empty Barracks, till 6:30: the defaults)** | **0-8-8** | **94/158** | **244/376** | **453/712** | **691/1088** | **1000/1808** | **1347/3583** | **853 v 594** | **183 s (43)** | **76 v 77** | **6,009** | **1.44 / 1,072** |

The second session's batches (0.38.5, the same maps and seeds; its "after" is the 0.38.5 clock with the look ahead and the
7:00 end, army_lags left alone):

| version | W-D-L | army 4:00 | 5:00 | 6:00 | 7:00 | 8:00 | 10:00 | Barracks idle 0-6 min | lost | Crown income 8:00 / 10:00 | labourers at the end | buildings lost |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| before (`crownarmy:off`) | 0-11-5 | 183 v 161 | 382 v 402 | 554 v 732 | 846 v 1,175 | 1,307 v 1,867 | 1,830 v 2,857 | 191 s | 77 v 96 | 5,629 / 8,146 | 19.8 | 19.1 |
| the look ahead, no end, army_lags from one hall | 0-5-11 | 233 v 157 | 425 v 393 | 690 v 731 | 887 v 1,224 | 1,197 v 1,681 | 1,471 v 2,900 | 138 s | 81 v 74 | 5,296 / 7,410 | 6.8 | |
| + the clock ends at 7:00 | 0-11-5 | 236 v 157 | 428 v 406 | 727 v 690 | 996 v 1,134 | 1,326 v 1,644 | 1,393 v 2,779 | 127 s | 69 v 91 | 5,344 / 7,339 | 15.4 | |
| + army_lags left as it was | 0-12-4 | 225 v 161 | 432 v 398 | 684 v 684 | 885 v 1,158 | 1,286 v 1,768 | 1,626 v 3,186 | 139 s | 64 v 89 | 5,391 / 7,624 | 18.0 | 16.9 |

A second sample on 0.38.5 (seeds 3 and 4, 9 games both ways, the second session's "after"): the army at 5:00 456 against 374, at 6:00 697 against 549,
even from 8:00; 2 games lost against 1.

In plain words: on every build the clock brings the army forward through the first push (on today's build 50-75% more at
4:00-5:00, a quarter more at 6:00) and the Crown trades better; on the builds before the economy coaching it cost nothing
measurable, but on today's build every coin a soldier takes is a labourer the economy coaching would have trained, so the
gold earned by 8:00 falls about 10% (14% on the variant with two soldiers queued). Holding the labourers longer
(all game, or with army_lags) lost the late game on both builds. The defaults are the mildest version that still has the
army on time (60%, an empty Barracks only, till 6:30): at 12:00 it has more army (1,072 v 940) and halls (1.44 v 1.38) than
before; the results by 15:00 are within the noise. It still wins none: from 7:00 the Clockwork's army grows faster than the
Crown's income (the Clockwork earns 1.6-1.9 times as much by 8:00).

## Tests

The 42 Crown and AI tests (test_ai_*, test_crown_*, test_cinder_crown) on the final code (0.38.13, the same code as the merged 0.38.14), against the same tests on
0.38.1 before any change:

- Pass both: abandoned_site, air_defence, army_response, crown_bank, expand, expand_wall, gg_rule, optimal, placement,
  r5_hold_spots, round6, round6_stall, scout, scout_defence, scout_threat, wall_vs_rush, worker_safety, crown_ammo,
  crown_balloon, crown_build_order, crown_farms, crown_gate, crown_ghosts, crown_hold, crown_line, crown_lost_hall,
  crown_mirror, crown_owner_eco, crown_rider_screen, crown_siege, crown_v_brood; and the new ones of the other jobs
  (crown_defence, crown_balloon_coach) pass.
- Fail both, the same checks (known, CLAUDE.md): test_ai_cw_horse_raid (2), test_ai_rush (1), test_ai_rush_followup (14),
  test_crown_dragoon_raid ([plan]).
- Failed on 0.38.1, pass now: test_ai_harass [raid], test_ai_scout_sentry (both listed as flaky); test_ai_brood timed out on
  0.38.1, passes now (one stage-3 timing failure in an earlier run: flaky, CLAUDE.md).
- Failed once on the final code, pass on a rerun, and fail the same way with `-- crownarmy:off` on the same build:
  test_cinder_crown ([labs] 21 labourers at 450 s, wants 23; off: [hall] laid at 349 s, wants 330) and test_crown_stall
  ([foundry] stands at 343 s, wants 330; off: 346 s). test_crown_mirror's "a Musketeer is queued for the raider" (12.0 s)
  did the same on 0.38.5. Timing checks on the edge, not this change.

## Claude's choices for the owner

1. **Keep the clock on, at 60%, till 6:30** (the defaults). It does what was asked (the army is there for the first push)
   at about 10% of the income by 8:00 on today's build; the results by 15:00 are within the noise. If the owner prefers the
   economy, `crownarmy:off` (or a lower `crownarmy:share=`) gives it back; the powder fix alone is `crownarmy:noclock`.
2. **The table is the Hard OPTIMAL Clockwork's median army** (0.38.1); against a human who pushes earlier the "what it saw"
   part (60%) takes over only once it is seen. It should be measured again if the Clockwork computer changes much.
3. **From 2:30** (FROM), never before 10 labourers: the opening's first minutes stay the economy's, and OPTIMAL's common
   opening still has no Mill and no soldiers before the scout's read (the owner's rule); the Mill is brought forward only
   after the pick, while behind.
4. **A Musketeer with his bayonet** while the Mill starts (only while behind): allowed by the owner's ammunition rule; he
   walks to fill up at the Mill or the Barracks when the powder comes (AICrownAmmo's refill errands).
5. **Not against the Brood** (its own reckoning and job). The Brood's usual army is in the table at the top if the owner wants
   a Brood row.
6. **The natural's palisade waits** for an empty Barracks's soldier while behind (it took the gold with no army at 5:00 on the
   Economy plan); the Church in a wall slot waits too; other wall-slot buildings are as before.
7. **army_lags is not forced by the clock**, and the clock ends at 6:30: a longer clock lost the late game on both builds.
8. Not changed (other jobs' areas or numbers): the balloon parties, the defence, the Crown's lower income (the Clockwork
   earns 1.6-1.9 times as much by 8:00), the Foundry idle for want of the Horse Breeder's horses (the Foundry-first rule).
9. Two sessions ran this job on the same branch (a scheduled second firing); they merged each other's work, and the second
   stopped once the first took the tests, the second sample, the films and the notes (its note is kept below the tests in
   git history only).
