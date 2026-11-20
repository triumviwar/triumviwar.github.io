# The Crown's rule cleanup (crown-rule-cleanup)

The owner, 2026-11-19 23:30 ("Yes"): the Crown computer is a stack of coaching rules added one job at a time, each measured
alone and switched by matchup. Some fight each other (the army floor holds gold the halls-on-time rule wants), some never act
because another fires first. This job takes an inventory of the rules and how often each acts, plays a CLEAN BASE with the
coaching groups off, adds the groups back one at a time, and compares the cleaned set with today's full stack.

The owner, 2026-11-20 07:20 ("some rules are very case specific"): the first run's deletion of the 25 not-kept experiments
(commit 05f171a39) is reverted; only the plain threshold variants that measured worse are deleted again, and a SITUATIONAL rule
is never deleted because it fired 0 times or showed no gain in 10-game blocks.

(This job was restarted on 2026-11-20 08:50 after the first run went silent; the doc is written as the blocks come in.)

## The 25 experiments of the two 1000 jobs (step 0)

Reverted (commit "revert 05f171a39"), then deleted again only where a plain number or timing variant of a rule that already
exists measured worse:

| job | deleted again (plain threshold variants that measured worse) | kept, off by default (switch to turn it on) |
|---|---|---|
| crown-1000-clockwork | share (army clock 0.4: x1.27 then x0.80), hall3 (third hall at 28 labourers: x0.92), hold (no wave under 1.3x: x0.90, x0.68), labs (labourers before the army clock: x0.64), guns (a cannon for 3 Musketeers: x0.43, t -1.8), powder (read the wrong number), stand (go down at 0.9x, muster at 0.85x: x0.55, t -1.7), timingonly (a study pick) | trade (`cvc:trade`, never acted: no fair test), spend (`cvc:spend`, never acted), foundry2 (`cvc:foundry2`, within the noise), richlabs (`cvc:richlabs`, a big bank, within the noise) |
| crown-1000-brood | eco (economy rules from 5:00: -0.72, t -2.7), press (go at 2x the army seen: -0.41), tech (tech on the army seen: -0.73, t -2.1), halls (halls on time from the start: -0.59), edge (push at 2.5x: -0.17), guns (cannon ratio: -0.27), mortars (mortar ratio: -0.11), spare (push home at 0.7: -0.73, t -2.3) | queen (`c1kbqueen:on`, a push on the Mother), pester (`c1kbpester:on`, riders at the grubs after the rush), maws (`c1kbmaws:on`, the push on the far Rootmaws), guard (`c1kbguard:on`, a home guard while the push is out), farms (`c1kbfarms:on`, every hall's second Farm, within the noise) |

## The inventory (step 1)

Every Crown coaching module, its switch, where it plays and how often it ACTED in the full-stack blocks (full1, 10 games each;
"thinks" = the computer's decisions where the rule changed what it did; the counters are in each game's result.json
"crown_ai"). The mirror column comes with the mirror's block.

| group | module (file) | switch (off) | plays against | acted v Brood (full1) | acted v Clockwork (full1) |
|---|---|---|---|---|---|
| plan | OPTIMAL leans to the Horseman rush (ai_optimal.gd) | `optlean:off` | Brood (the lean chance) | 10 of 10 games | never (not the Brood) |
| plan | crown-1000-brood `lean`, `siege` (ai_crown_1k_brood.gd, ai_crown.gd, ai_optimal.gd) | `c1kblean:off`, `c1kbsiege:off` | Brood | the Siege handover in 10 of 10, 13 pushes, the pick kept 21 times | never |
| plan | crown-1000-clockwork `pick` (ai_crown_v_clock.gd) | `cvcpick:off` | Clockwork | never | every game (Timing or Siege) |
| plan | the mirror's picks and play (ai_crown_mirror.gd, ai_optimal.gd) | `mirror:off` | mirror | never | never |
| econ | FARM FIRST (ai_crown_coach.gd) | `farmfirst:off` | all, every plan but the Rush | never (lean makes every game the Rush plan) | 10 of 10 |
| econ | LABOURERS FIRST (ai_crown_coach.gd) | `labsfirst:off` | all; against the Brood only after the first push is held or 9:00 | 259 labourers trained, 146 s of gold held | 477 labourers, 334 s held |
| econ | HALLS ON TIME (ai_crown_coach.gd) | `hallsontime:off` | as LABOURERS FIRST | short of a hall in 3 games (141 thinks) | short in 2 games (11 thinks) |
| econ | crown-1000-clockwork `hall2`, `tech3` | `cvchall2:off`, `cvctech3:off` | Clockwork | never | hall2 in 10 of 10 |
| econ | the Brood army job's economy after the held push (ai_crown_v_brood.gd part 7) | `cbaecon:off` | Brood | (opens the two rules above) | never |
| army | THE ARMY CLOCK (ai_crown_army.gd) | `crownarmy:off` | all | (inside the army floor) | behind in 16,657 thinks |
| army | THE ARMY FLOOR (ai_crown_coach.gd) | `armyfloor:off` | all | 7,807 thinks, every game | 8,901 thinks, every game |
| army | the army floor tied to the Brood, hold the first push (ai_crown_v_brood.gd parts 5-6) | `cba:off` | Brood | 186 soldiers trained, 9 Barracks, 612 s of gold held | never |
| army | the Crown against the Brood, parts 1-4 (ai_crown_v_brood.gd) | `cvb:off` | Brood | the home line short 5,392 s | never |
| army | THE SCREEN FIRST (ai_crown_coach.gd) | `screenfirst:off` | all | 17 riders | 37 riders |
| army | crown-1000-clockwork `dry` | `cvcdry:off` | Clockwork | never | 7,888 bayonet Musketeers' thinks in 9 games, 21 guns |
| fight | THE GUNS COACHED (ai_crown_guns.gd) | `gunscoach:off` | all | 169 post sets, 149 kept, 40 fights | (counted, see data) |
| fight | GUNS FIRST (ai_crown_coach.gd) | `gunsfirst:off` | all | 26 thinks in 4 games | 136 in 5 games |
| fight | THE LINE (ai_crown_line.gd) | `line:off` | all | formed 5 times, 43 home lines | formed 22 times, 26 home lines, 19 deploys |
| fight | THE RIDER SCREEN (ai_crown_screen.gd) | `screen:off` | all | 19 riders sent, 26 flank hits | 77 sent, 293 flank hits |
| fight | CAVALRY MICRO (ai_cav_micro.gd) | `cavmicro:off` | all | 694 blows, 248 charged | 1,009 blows, 229 charged |
| fight | THE DEFENCE (alert, no walk past, muster) (ai_crown_defence.gd) | `defence:off` | all | soldiers first 4,420 thinks, 19 alerts, 6 musters | soldiers first 25,208 thinks, 28 alerts, 9 musters |
| home | THE HOLD (main, ramp, gate post, menders, rider scouts) (ai_crown_hold.gd) | `hold:off` | all | the gate post live 12,609 thinks in 9 games, 20 mends | the gate post never live, 60 mends |
| home | the mirror coach (press, outlying halls, guns for a walled hall) (ai_crown_mirror.gd) | `cmc:off` | mirror | never | never |

Not in the groups (left on in every block, not measured here): the Balloon harass's own fixes (`blfix:off`, its plan only),
the build stack (`buildstack:off`), the Crown's economy coach (`crowneco:off`), the owner's doctrine (`owner:off`), the cinder
fixes (`cinder:off`), the scout denial (`scoutdeny:off`, every faction), the ammunition rules (crown-ammo).

**What overrides what** (read from the code and the counters):
1. **The defence's alert switches the economy rules off**: HALLS ON TIME and LABOURERS FIRST return nothing while the defence
   wants soldiers (AICrownDefence.wants_soldiers). Against the Clockwork that is 25,208 thinks, so the halls rule wanted a hall
   in only 2 of 10 games: it is mostly silenced by the defence, not by its own clock.
2. **The army floor yields to nothing but feeds on the army clock**: against the Clockwork AICrownCoach.army_short is
   AICrownArmy.behind (16,657 thinks), so `armyfloor` and `crownarmy` are one rule there; against the Brood the floor is the
   Brood army job's home line (cvb's line_short) first.
3. **OPTIMAL's lean against the Brood makes FARM FIRST dead there**: every game is the Rush plan, and FARM FIRST skips the Rush.
4. **The coach's economy rules against the Brood wait for the Brood army job** (`cbaecon`: after the first push is held or 9:00),
   so they act late or never there.
5. **`siege` keeps OPTIMAL's pick** (21 times): the late re-pick to the Economy race cannot happen against the Brood.
6. **`dry` overrides the ammunition rule** against the Clockwork (Musketeers trained with no powder, 9 of 10 games).

## How it is measured

- The games: crown-1000-brood's 10 (5 maps: Greenhold, Ashford Crossing, Mirewood, Frostfang, Cinder Steps, x 2 rounds with
  the start spots swapped), Crown Hard OPTIMAL v Hard OPTIMAL to 20:00. Against the Brood and in the mirror its seeds; against
  the Clockwork crown-1000-clockwork's seeds, so its kept-set blocks 19 and 22 (copied here as `old_b19`, `old_b22`) pair game
  by game with this job's. The Brood job's kept-code blocks 9, 10 and 14 are `old_b09`, `old_b10`, `old_b14`.
- The score of a game: g = ln((income + 2 x army) of the Crown / of the enemy) at 20:00 or the defeat, a beaten side counted
  a quarter; g14 the same ratio at 14:00. Survived = not beaten by 20:00; won or led = won, or 10% ahead at 20:00.
- The noise: two blocks of the same code differ by about 0.6 in mean g and 0.2 in g14, so decisions are made on pooled blocks
  and paired game by game (d = the paired mean difference, t its t value).
- The groups (tools/study/crown_rule_cleanup.py GROUPS; each group's switches turn it OFF):
  - plan: `optlean:off c1kblean:off c1kbsiege:off cvcpick:off mirror:off`
  - econ: `labsfirst:off hallsontime:off farmfirst:off cvchall2:off cvctech3:off cbaecon:off`
  - army: `crownarmy:off armyfloor:off cba:off cvb:off screenfirst:off cvcdry:off`
  - fight: `gunscoach:off gunsfirst:off line:off screen:off cavmicro:off defence:off`
  - home: `hold:off cmc:off`
- Run: `python3 tools/study/crown_rule_cleanup.py run OPP BLOCK [--on g1,g2] [--full]`; report:
  `python3 tools/study/crown_rule_cleanup.py report OPP --base B1+B2 BLOCK ...`; the rules' counters: `... fired OPP BLOCK`.
  Data: `docs/crown_rule_cleanup/data/<OPP>/<BLOCK>/`.

## The log

One line a block, written as each one ends.

| time | matchup | block | groups on | what it showed |
|---|---|---|---|---|
| 09:40 | Brood | full1 | the full stack (today's default) | g -0.52, g14 +0.08, survived 6, won/led 4, defeats median 15:53, income 8/12 1.50/1.25, army 2.96/2.94; v the Brood job's kept-code pool (old b09+b10+b14, same code but the gated Clockwork changes) +0.21 (t 0.4), 5/5: the same code within the noise. Counters: the army floor acted in every game (7,807 thinks), the defence's soldiers-first 4,420, the gate post live 12,609, lean 10 of 10, 13 siege pushes; halls on time wanted a hall in 3 games only, the line formed 5 times, the screen sent riders in 4 games. |
| 10:09 | Clockwork | full1 | the full stack | g -0.59, g14 -0.29, survived 6, won/led 4, defeats median 17:38, income 8/12 0.81/0.85, army 1.09/3.53; v the Clockwork job's kept-set pool (old b19+b22, 18 of 20 survived) -0.47 (t -1.2), 3/6: an unlucky block or the merge (the Brood job's changes cannot act here); to be pooled. Counters: the army clock behind 16,657 thinks, the army floor 8,901, the defence's soldiers-first 25,208, dry Musketeers 7,888 (9 games), hall2 10 of 10, farm first 10 of 10; the gate post never live (no walled natural against the Clockwork), halls on time short in 2 games; the line formed 22 times, the screen 77 riders sent, 293 flank hits. |
| 10:35 | Brood | base | none (every group off) | g -0.56, g14 -0.12, survived 7, won/led 2, defeats median 14:14, income 8/12 1.31/0.85, army 8/12 1.37/1.42; v full1 -0.04 (t 0.0), g14 -0.20 (t -0.6), 4/6. The clean base scores about like the full stack in g (one block each), but its army at 8:00 and 12:00 is half the full stack's and its defeats come 1:40 sooner; it is still far above the Brood job's pre-1000 baseline at 12:00 (old b01+b05). |
| 11:02 | Clockwork | base | none | g -1.19, g14 -0.80, survived 7, won/led 1, defeats median 13:42, income 8/12 0.69/0.61, army 8/12 0.54/0.44; v the full-stack pool (full1 + old b19 + old b22, 30 games) -0.91 (t -1.3), g14 -0.53 (t -2.0), 3/7. Against the Clockwork the stack clearly helps: without it the army at 12:00 is a quarter of the stack's and the defeats come 3 minutes sooner. |
| 11:30 | Brood | p1 | plan | g -1.37, g14 -0.17, survived 5, won/led 0, defeats median 17:42, income 8/12 1.41/1.07, army 1.33/1.33; v base -0.81 (t -1.4), g14 -0.05 (t -0.2), 4/4. Mixed: the defeats come 3:30 later but more of them; the base gets a second block (base2) before deciding. |
| 11:57 | Clockwork | p1 | plan | g -1.25, g14 -0.55, survived 6, won/led 1, defeats median 17:56, income 8/12 0.69/0.69, army 0.78/0.67; v base -0.06 (t -0.1), g14 +0.25 (t 1.3), 7/3. A lean up (later defeats, a bigger army, 7 games better); with crown-1000-clockwork's own 20 games for `pick` (x1.71, t 1.9) the plan group stays on. |
| 12:26 | Brood | base2 | none (base again) | g -1.17, g14 -0.29, survived 5, won/led 1, defeats median 16:55; the base pool (base + base2, 20 games): g -0.87, g14 -0.21, survived 12, army 12:00 1.55. Against the pool: p1 (plan) -0.51 (t -1.1), g14 +0.03; full1 +0.35 (t 0.5), g14 +0.28 (t 1.1), 6/4. |
| 12:55 | Clockwork | base2 | none (base again) | g -1.67, g14 -0.81, survived 5, won/led 0; the base pool (20 games): g -1.43, g14 -0.81, survived 12, won/led 1, army 12:00 0.37. Against it: p1 (plan) +0.18 (t 0.3), g14 +0.26 (t 1.3), 6/3: **plan kept**; the full stack (30 games) +1.15 (t 1.7), g14 +0.54 (t 2.1), 7/3. |
| 13:26 | Brood | p1b | plan (again) | g -1.51, survived 4, won/led 0, defeats median 17:49; the plan pool (p1 + p1b, 20 games) v the base pool: -0.58 (t -1.1), g14 +0.06 (t 0.3), 5/5, survived 9 of 20 (base 12), won/led 0 (base 3), the defeats 1:45 later. **Plan not kept at this step**: the Horseman rush and the Siege push alone, without the army floor and the fighting rules, do not help (crown-1000-brood measured them on top of the whole stack). It is tried again last, on top of the kept groups. |
