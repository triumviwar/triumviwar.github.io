# No Farm/Press limit, every side and every matchup (job econ-nocap-all, 2026-11-15; game version 0.37.11)

The owner's ask (2026-11-14 19:45): "make an economic study with the free amount of resources". Confirmed as: the
**NO FARM/PRESS LIMIT** switch, with the **GROUND SYSTEM** on, studied for **all three sides and every matchup**, to judge
whether it is fair. This is a study only. No balance or computer change was made; the switch stays OFF by default.

## In short

1. **It is a Clockwork rule.** With the limit dropped, the Clockwork computer earns **15% more by 8:00, 20% more by 12:00
   and 26% more by 15:00**. The Crown computer earns **the same** (0.98-1.04). The Brood earns **the same or a little
   less** (0.95-0.98): it has no limit to drop, and it now faces a richer Clockwork.
2. **It widens the gap between the sides.** In real games the Clockwork already earns 1.85 times the Crown by 12:00. With
   the limit dropped it earns **2.26 times**. Against the Brood, 1.22 times becomes 1.53 times.
3. **It does not cause turtling.** Every side keeps its army out of its bases as much as before. The Clockwork takes
   **more** halls, not fewer (4.9 most held, was 4.3). A district ringed with Presses runs dry sooner and pushes its
   owner out.
4. **It does not add a clear snowball.** The side ahead at 8:00 won 85% of decided games with the limit and 88% without.
   Its share of later income went from 64% to 67%: a small rise, within the noise.
5. **Results barely move, and results are noisy.** The Brood mirror, where nothing changes, flipped the result of 8 of
   its 16 games between the two runs. So 16 games a matchup can only show big changes. The one matchup that moved more
   than the noise suggests is **Brood v Clockwork**: the Brood won 7, now 4; the Clockwork won 6, now 9.
6. **Recommendation: keep the limit.** Dropping it is fine for anti-snowball and for base building, but it breaks the
   economy parity the owner asked for. If the owner wants "the ground is the only limit" one day, drop it **together
   with** a Clockwork brake and a Brood counterpart, and only after the Crown computer reaches its economy in games.
   Details at the end.

Design rules checked (docs/design_principles.md): section 1, fairness; section 2, anti-snowball and expansion pressure;
section 3, meaningful base building. All three are discussed in "Against the design principles" below.

## What was run

All with **the ground system ON**. The two arms: **kept** (`ground:1`, the local limit of 2 Farms or 2 Cog Presses a
hall) and **dropped** (`ground:1 groundcap:off`). The Powder Mill and the Mainspring stay at 1 a hall in both arms.

| part | what | size |
|---|---|---|
| Scripted bench | tools/econ_bench.gd, one side alone, the ideal build, 20 minutes. Crown and Clockwork with 2 (kept), 3 and 4 Farms or Presses a hall; the Brood kept and dropped | 4 maps x 3 sides: 32 runs |
| Computer alone | tools/econ_ai_alone.gd (Crown, Clockwork) and tools/econ_ai_alone_brood.gd (Brood), Hard OPTIMAL, nobody in its way, 20 minutes | 4 maps x 3 sides x 2 arms: 24 runs |
| Games | tools/qa_match.gd, Hard OPTIMAL v Hard OPTIMAL, 15:00 cap, all 6 pairings (the 9 matchups: the sides swap between the two rounds) | 8 maps x 2 rounds x 6 pairings = **96 games an arm, 192 in all** |
| Films | tools/shot_ai_match.gd, the limit dropped, coach notes | 6 games (2 a matchup that changed) |
| Two extra bench arms | the Clockwork computer alone with a softer rule: 1 extra Press a district instead of 2, and 7,000 brass a district instead of 9,000 | 4 maps each |

Maps: the benches on Greenhold, Hollowfen, Dune Sea and Highmoor (a classic map, the 4-player kind, played 1 on 1 here).
The games on Greenhold, Hollowfen, Dune Sea, Frostfang, Cinder Steps, Ashford Crossing, Highmoor and Red Coast.

**Time was short, so seeds were cut, not matchups**: 8 maps x 2 rounds (the minimum asked), not 19 maps. One game took
about 4 minutes of a 2-core machine; the 192 games took about 10 hours. Games started on a 9th map (Twin Fords) were
stopped and left out, so every map in the tables is complete.

**How noisy is this?** The games are not exactly repeatable. One game run twice with the same seed differed by 1-4% in
income. The Brood scripted bench run three times differed by up to 5% at 15:00. And the Brood mirror, where the rule
changes nothing, flipped 8 of its 16 results. So: **income medians over many sides are reliable; win-loss counts of 16
games are not**, unless the change is large.

## 1. Each side alone

### The scripted bench (the design, not the computer)

Income earned (value, cumulative) by each minute. "Kept" is in money; the other rows are shares of kept.

| side, map | arm | 5:00 | 8:00 | 10:00 | 12:00 | 15:00 | 20:00 | districts dry at |
|---|---|---|---|---|---|---|---|---|
| Crown, Greenhold | kept | 4,359 | 9,620 | 14,154 | 19,269 | 24,381 | 28,538 | 10:21, 14:30, 18:25 |
| | 3 a hall | 1.13 | 1.08 | 1.11 | 1.05 | 1.06 | 1.00 | 9:13, 13:53, 17:05 |
| | 4 a hall | 1.05 | 1.21 | 1.17 | 1.12 | 1.12 | 0.99 | 7:21, 12:58, 13:47 |
| Crown, Hollowfen | kept | 4,360 | 9,572 | 14,106 | 18,789 | 24,787 | 29,026 | 10:20, 18:38 |
| | 4 a hall | 1.05 | 1.19 | 1.19 | 1.21 | 1.12 | 0.99 | 7:56, 13:23 |
| Clockwork, Greenhold | kept | 4,630 | 10,453 | 15,261 | 20,938 | 26,818 | 28,137 | 11:11 |
| | 3 or 4 a hall | 0.95 | 1.01 | 1.03 | 1.05 | 1.00 | 1.01 | 12:04 |
| Clockwork, Dune Sea | kept | 4,630 | 10,453 | 15,289 | 20,940 | 25,537 | 29,015 | 11:10 |
| | 3 a hall | 0.95 | 1.01 | 1.03 | 1.09 | 1.10 | 0.99 | 12:04 |
| Brood, Greenhold | kept | 2,523 | 7,033 | 10,233 | 14,599 | 20,526 | 27,946 | |
| | dropped | 1.00 | 1.00 | 1.00 | 1.01 | 1.03 | 1.02 | |
| Brood, Highmoor | kept | 2,523 | 7,010 | 10,215 | 15,000 | 21,776 | 30,139 | |
| | dropped | 1.00 | 1.00 | 1.00 | 0.98 | 0.95 | 0.96 | |

(All 4 maps in docs/econ_nocap_all_data/bench_report.md. Dune Sea and Highmoor give the same numbers as Greenhold for the
Crown, to within 1%.)

What it shows:

- **The ground is a real limit.** More Farms a hall do not make more money in total: the same by 20:00 on every map.
  They make it **sooner** (up to +21% in the middle game) and the district **runs dry 1 to 3 minutes earlier**.
- **The scripted Clockwork gains little**, because the script seldom finds room for a 3rd Press in the ring of gears by
  the Clocktower. The Clockwork computer does find room (next part), so this row understates the Clockwork's real gain.
- **The Brood is unchanged**, as it should be. Its rows move by up to 5%, but the Brood bench is not repeatable: the same
  kept run done three times gave 21,776, 21,854 and 20,582 by 15:00. That is noise, not the rule.

### The computer alone (Hard OPTIMAL, nobody in its way)

Income earned by each minute, dropped as a share of kept (kept in money in docs/econ_nocap_all_data/bench_report.md).

| side, map | 5:00 | 8:00 | 10:00 | 12:00 | 15:00 | 20:00 | Farms/Presses at 20:00, kept / dropped |
|---|---|---|---|---|---|---|---|
| Crown, Greenhold | 1.00 | 0.99 | 1.04 | 1.04 | 1.06 | 1.05 | 9 / 9 |
| Crown, Hollowfen | 1.00 | 1.06 | 1.03 | 1.07 | 1.07 | 1.10 | 10 / 11 |
| Crown, Dune Sea | 1.00 | 0.95 | 0.97 | 0.93 | 0.99 | 1.00 | 7 / 8 |
| Crown, Highmoor | 1.00 | 1.05 | 0.99 | 1.06 | 1.15 | 1.16 | 11 / 7 |
| Clockwork, Greenhold | 1.01 | 1.05 | 1.12 | 1.13 | 1.13 | 1.12 | 10 / 9 |
| Clockwork, Hollowfen | 0.99 | 1.06 | 1.08 | 1.07 | 1.09 | 1.14 | 6 / 10 |
| Clockwork, Dune Sea | 1.00 | 1.06 | 1.13 | 1.16 | 1.17 | 1.17 | 6 / 12 |
| Clockwork, Highmoor | 1.01 | 1.07 | 1.15 | 1.17 | 1.16 | 1.14 | 9 / 9 |
| Brood, Greenhold | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.01 | |
| Brood, Hollowfen | 1.00 | 1.00 | 0.98 | 0.99 | 0.97 | 0.97 | |
| Brood, Dune Sea | 1.00 | 1.00 | 1.00 | 0.99 | 1.01 | 1.01 | |
| Brood, Highmoor | 1.00 | 1.00 | 1.01 | 1.00 | 0.99 | 0.99 | |

- **The Clockwork computer gains 7-17% from 10:00 on**, every map. Alone it expands at the same times; with the limit
  dropped it lays its 5th and 6th Clocktowers 1 to 2 minutes sooner (for example Dune Sea 11:42 and 14:05, was 13:25 and
  16:07), because a district fed by 3 or 4 Presses runs dry sooner.
- **The Crown computer gains little and late** (-7% to +16%, mostly 0-7%), as in the last study.
- **The Brood is unchanged** (within 3%, the noise).

## 2. Real games: results

96 games an arm, paired (the same map, seed and sides). From the first-named side's view; a mirror from the first
slot's view. W = win, D = draw at 15:00, L = loss.

| matchup | kept W-D-L | dropped W-D-L | games that changed result | decided, kept / dropped |
|---|---|---|---|---|
| Crown mirror | 0-14-2 | 0-16-0 | 2 of 16 | 2 / 0 |
| Clockwork mirror | 4-6-6 | 2-10-4 | 11 of 16 | 10 / 6 |
| Brood mirror (nothing changes: the noise check) | 6-7-3 | 5-10-1 | 8 of 16 | 9 / 6 |
| Crown v Clockwork | 0-10-6 | 0-10-6 | 9 of 16 | 6 / 6 |
| Crown v Brood | 0-4-12 | 0-7-9 | 5 of 16 | 12 / 9 |
| Brood v Clockwork | 7-3-6 | **4-3-9** | 9 of 16 | 13 / 13 |

Read with care. The Brood mirror shows how much 16 games swing with no real change: 8 results flipped and the decided
games fell from 9 to 6. So:

- **Crown v Clockwork: no change** in the score (0-10-6 both ways). The Crown computer was already losing or drawing.
  Decided games end sooner (12:25 against 14:10).
- **Brood v Clockwork: the one real shift**. The Brood's wins fall from 7 to 4 and its losses rise from 6 to 9. This is
  backed by the income (next part): the Brood's income in this matchup falls 17% by 12:00 and the Clockwork's rises 30%.
- **Crown v Brood: the Crown loses a little less** (9 losses, was 12). Its income there is +8% by 12:00; this may be
  noise.
- **The mirrors draw more often**, all three of them. For the Brood mirror this can only be noise, so the Crown and
  Clockwork mirrors' extra draws mean nothing on their own either.

## 3. Real games: income, army and bases

### Each side, every game it played (medians; "mean" where it says so)

| | Crown kept | Crown dropped | Clockwork kept | Clockwork dropped | Brood kept | Brood dropped |
|---|---|---|---|---|---|---|
| income earned by 5:00 | 2,660 | 2,660 (1.00) | 4,216 | 4,319 (1.02) | 3,227 | 3,238 (1.00) |
| by 8:00 | 5,700 | 5,700 (1.00) | 9,924 | 11,453 (**1.15**) | 8,122 | 7,892 (0.97) |
| by 10:00 | 8,023 | 7,974 (0.99) | 14,840 | 16,544 (**1.11**) | 12,134 | 11,476 (0.95) |
| by 12:00 | 10,199 | 10,000 (0.98) | 18,818 | 22,616 (**1.20**) | 15,450 | 14,756 (0.96) |
| by 15:00 | 11,536 | 11,984 (1.04) | 22,002 | 27,696 (**1.26**) | 18,009 | 17,622 (0.98) |
| income in the 8th minute | 1,140 | 1,140 | 2,198 | 2,702 (1.23) | 1,884 | 1,872 |
| income in the 12th minute | 760 | 760 | 2,238 | 3,086 (**1.38**) | 1,724 | 1,762 |
| spent by 12:00 | 10,564 | 10,248 (0.97) | 17,872 | 19,798 (1.11) | 14,955 | 14,208 (0.95) |
| army value at 8:00 | 985 | 908 | 1,480 | 1,510 | 1,290 | 1,368 |
| army value at 12:00 | 1,012 | 1,202 | 3,635 | 3,980 (1.09) | 2,780 | 2,355 (0.85) |
| halls at 10:00 (mean) | 2.20 | 2.14 | 3.30 | 3.61 | 3.48 | 3.41 |
| halls at 15:00 (mean) | 2.12 | 1.95 | 3.31 | **4.22** | 3.53 | 3.42 |
| most halls held (mean) | 3.03 | 2.89 | 4.25 | **4.94** | 3.80 | 3.75 |
| halls lost (mean) | 1.45 | 1.30 | 1.39 | 1.17 | | |
| Farms or Presses live a hall at 8:00 (mean) | 1.82 | 1.94 | 1.86 | **2.48** | | |
| most in one district (mean, spent ones too) | 2.11 | 2.47 | 2.16 | **4.22** | | |
| sides that ever had 3 or more in one district | 6% | 38% | 11% | **100%** | | |
| army near its own halls from 5:00 (the turtle measure) | 0.72 | 0.70 | 0.62 | 0.59 | 0.57 | 0.59 |

(The Brood's "halls" are its Mound Turtles and capital; the tool does not count Brood halls lost.)

**The same game, both arms** (each side's income by 12:00, dropped over kept; a single game's 0.95-1.05 is noise):

| side | sides | median | earned 5% or more MORE | earned 5% or more LESS |
|---|---|---|---|---|
| Crown | 64 | 0.99 | 24 | 23 |
| Clockwork | 64 | **1.20** | **52** | 5 |
| Brood | 64 | 0.96 | 12 | **27** |

This is the clearest table in the study: the Clockwork gains in 52 games of 64; the Crown is a coin toss; the Brood
loses more often than it gains.

### Each matchup (median income by 12:00, kept, and dropped as a share of kept)

| matchup | side | kept by 12:00 | dropped / kept at 8:00 | at 12:00 | Presses or Farms a hall at 8:00, kept / dropped |
|---|---|---|---|---|---|
| Crown mirror | Crown | 10,967 | 0.97 | 1.01 | 1.83 / 2.05 |
| Clockwork mirror | Clockwork | 19,824 | 1.17 | **1.21** | 1.92 / 2.54 |
| Brood mirror | Brood | 16,520 | 1.00 | 1.00 | |
| Crown v Clockwork | Crown | 9,254 | 1.00 | 0.92 | 1.78 / 1.66 |
| | Clockwork | 20,614 | 1.16 | **1.17** | 1.78 / 2.44 |
| Crown v Brood | Crown | 9,316 | 0.99 | 1.08 | 1.81 / 2.00 |
| | Brood | 13,907 | 0.92 | 1.04 | |
| Brood v Clockwork | Brood | 13,258 | 0.89 | **0.83** | |
| | Clockwork | 13,144 | 1.06 | **1.30** | 1.81 / 2.42 |

### Are the economies still about equal? (median income, as a share of the Crown's)

| | kept 8:00 | dropped 8:00 | kept 12:00 | dropped 12:00 |
|---|---|---|---|---|
| Clockwork | 1.74 | **2.01** | 1.85 | **2.26** |
| Brood | 1.43 | 1.38 | 1.51 | 1.48 |
| Clockwork over the Brood | 1.22 | **1.45** | 1.22 | **1.53** |

In games the three economies were already far apart, mostly because the Crown computer is weak (docs/economy_parity.md:
it reaches about 55% of its own bench). Dropping the limit pulls the Clockwork further away from **both** other sides.

By design (the scripted bench), the picture is gentler but points the same way for the Brood: the Clockwork stays at
0.90-1.10 of the Crown, but the **Brood falls from 0.73-0.78 of the Crown at 8:00 to 0.60-0.68**, because the other two
can stack drinkers and it cannot.

### The snowball check (all games)

| | the 8:00 leader's share of income by 8:00 | its share of income in the 10th to 12th minutes | decided games the 8:00 leader won |
|---|---|---|---|
| kept | 0.56 | 0.64 | 44 of 52 (85%) |
| dropped | 0.57 | 0.67 | 35 of 40 (88%) |

A lead grows about as much as before. The 3-point rise in later income share is within the noise of these games.

## 4. The films (limit dropped)

Coach and story lines in docs/econ_nocap_all_data/films/; pictures in docs/shots/econ_nocap_all/.

| film | result | what the coach saw |
|---|---|---|
| Crown v Clockwork, Dune Sea (seed 1107) | Clockwork won at 12:52 | At 6:05 the Clockwork main has **3 Presses** (Winders 4/5, 3/5, 5/5) and a Mainspring, and it has just expanded (6:02). It expanded again at 7:17 and 10:07, each "while its base is still rich". The Crown expanded at 4:44; at 8:05 its main has one Farm left at 15% and builds **no 3rd Farm** there (the ground would not pay). The Crown lost its bases from 11:28. |
| Brood v Clockwork, Greenhold (1102) | draw at 15:00, Clockwork far ahead | The Brood rushed early and was level until about 10:00 (11,839 earned against 11,567). The Clockwork had only 2 halls at 8:00 with **2 Presses a district** and one spent Press already pulled down; it expanded at 7:02, 9:19 and 11:47. From 12:00 it pulled away: 27,291 against 16,073 earned by 14:54, army 7,100 against 625. |
| Clockwork mirror, Dune Sea (1111) | first slot won at 14:39 | Both expanded at 4:45-4:46. At 8:04 the first slot's main has 2 Presses (5/5 each) and a 2nd Clocktower beside it. The game turned on one won push at 8:30; the winner then took 5 halls, the loser stayed on 2. Nobody sat at home. |
| Crown v Clockwork, Hollowfen (1152) | Clockwork won at 14:23 | At 6:02 the Clockwork main has **3 Presses**, all 5/5, and its 2nd Clocktower already stands next to it with 2 more. By 8:09: 10,542 earned against the Crown's 5,700, army 2,235 against 1,280. The Crown expanded at 4:39 and lost bases from 10:11. |
| Brood v Clockwork, Dune Sea (1108) | draw at 15:00, Clockwork far ahead | The Brood rushed at 1:41 and timed an attack at 4:32; the Clockwork defended and expanded at 6:37, 9:12, 12:03 and 13:43. At 8:07: 8,439 against 4,848; at 14:53: 29,459 against 16,482, army 4,515 against 1,380. |
| Clockwork mirror, Hollowfen (1156) | draw at 15:00 | Both expanded at 4:51-4:52 and again at 6:53-6:58, then 10:07-10:15. Even all game (24,787 and 24,562 earned by 12:09), 5-6 halls each, armies trading pushes. |

What the films show, in short: **nobody turtled and nobody stacked instead of expanding.** In two films the Clockwork
had 3 Presses round its main by 6:00, and it still expanded "while its base is still rich" at the usual times. It
simply had more money at every step. The Crown never built a 3rd Farm where it would not pay.

## 5. Against the design principles

- **Section 1, fairness: fails.** Dropping the limit gives the Clockwork +20% income by 12:00 and gives the Crown and the
  Brood nothing. In games the Clockwork goes from 1.85 to 2.26 times the Crown's income, and from 1.22 to 1.53 times the
  Brood's. The owner asked (2026-11-12) for "all economies about the same level of resources per minute". This moves the
  wrong way, and the Brood vs Clockwork results move with it.
- **Section 2, anti-snowball: passes.** Bases run dry 1 to 3 minutes sooner, so expansion comes sooner, not later. The
  Clockwork holds more halls, and those halls are exposed. The army stays home the same share of the time. A lead at
  8:00 grows and wins about as often as before.
- **Section 3, meaningful base building: a plus.** Each extra Farm or Press is a real choice: more income now and an
  earlier move, or fewer and a longer-lived base. The placing view already shows each extra one's falling value.

## 6. Recommendation (for the owner; nothing applied)

**Keep the limit (the local limit of 2 a hall), as now.** The rule is good for base building and does no harm to the
anti-snowball rules, but it is a one-side buff. It helps the Clockwork a lot, the Crown not at all in games, and the
Brood never.

If one day the owner wants "the ground is the only limit" (it is simpler to explain), drop it **only with all three** of
these, then run this study again (`python3 tools/study/econ_nocap_all.py run OUT DATA`):

1. **A Clockwork brake.** Measured here on the Clockwork computer alone, with the limit dropped:

   | change (limit dropped) | gain over kept by 10:00 | by 12:00 | by 15:00 | by 20:00 |
   |---|---|---|---|---|
   | nothing (as studied) | +8 to +15% | +7 to +17% | +9 to +17% | +12 to +17% |
   | the computer takes 1 extra Press a district, not 2 (`land.nocap_max=1`) | +5 to +11% | +5 to +12% | +6 to +12% | +9 to +15% |
   | 7,000 brass a district, not 9,000 (`land.brass=7000`) | -1 to +12% | +1 to +12% | +4 to +13% | +5 to +10% |

   A softer cap only trims the gain by about a third. Less brass a district roughly **halves** it (median about +6% from
   10:00 on), because stacked Presses then drain a district within minutes and the gain becomes timing, not income.
   Note: 7,000 brass would also cut the Clockwork when the limit is kept, so it would need its own parity check
   (docs/economy_parity.md's branch already proposes brass 9,000 -> 8,000 with the limit kept). These are the computer
   alone, not games.
2. **A Brood counterpart**, so the Brood also gets the "stack now, move sooner" choice: for example, let Rootmaw
   circles overlap and share their ground (today PIT_CLAIM forbids overlap). Not measured.
3. **The Crown computer first.** In games the Crown computer is held back by its labourer count, not by the Farm limit
   (it seldom fills even 2 Farms; 38% of its sides ever built a 3rd in a district). Until it reaches its bench in games,
   any rule that pays per filled post will favour the Clockwork. Re-run this study after that work.

Not done, on purpose: no computer fix. The Crown computer does use the switch where the ground pays for it (alone it
builds a 3rd Farm and gains 5-16% late); its weakness in games is its economy in general, not this switch.

Proposals NOT applied: all of the above. The switch stays OFF by default; the default game is unchanged.

## How to run it again

- Games: `python3 tools/study/econ_nocap_all.py run OUT DATA --jobs 2 [--maps a,b] [--rounds 0,1]` (both arms, map by map,
  resumable), then `python3 tools/study/econ_nocap_all.py report DATA` (and `json DATA` for the numbers).
- Benches: `python3 tools/study/econ_nocap_all_bench.py run DIR [--maps ...]`, then `... report DIR`.
  tools/econ_ai_alone_brood.gd now takes `groundcap=off` too.
- Films: `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --fixed-fps 30 --script
  res://tools/shot_ai_match.gd -- a:crown b:clockwork pa:optimal pb:optimal map:dune_sea seed:1107 out:/abs/dir coach:1
  every:30 end:900 ground:1 groundcap:off`.
- Data: docs/econ_nocap_all_data/: games.tar.gz (every game's result.json and story, both arms), games_report.md and
  games_summary.json (the tables above), bench/ (every bench run's JSON), bench_report.md, films/ (coach and story
  lines). The earlier, smaller study: docs/ground_nocap_study.md.
- Ground tests: tools/test_ground_system.gd and tools/test_ground_nocap.gd pass on this branch.
