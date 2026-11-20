# Crown rule cleanup (crown-rule-cleanup)

The owner, 2026-11-19 23:30 ("Yes"): the Crown computer had become a STACK of coaching rules, added one job at a time, each
measured alone and switched by matchup; some fight each other, some never act because another fires first. Clean it up:
an inventory with counts of how often each rule acts, a clean base with the coaching off, the rule groups added back one
at a time and kept only when they help on top of what is kept, the cleaned set against today's stack, and a plain answer
to the Brood question. No balance number was changed.

**NOTE (2026-11-20 12:40): this is the FIRST run of the job, pushed to the side branch `crown-rule-cleanup-first`.** A
restarted run (from 08:50, on the branch `crown-rule-cleanup`) reverted this run's deletion of the 25 not-kept changes on the
owner's word of 2026-11-20 07:20 ("some rules are very case specific": a situational rule is not deleted for firing 0
times). This branch still has that deletion (section 5): do not merge it as is; take its measurements (sections 2 to 4,
the data) and the cleaned set (AICrownRules.DROP) into the restarted run, which keeps the situational rules.

## In short

**The cleaned set is the new default** (0.38.87): against the Brood the Crown computer keeps only its PLAN rules (the
Horseman rush opening and the Siege push after it); against the Clockwork its PLAN and ECONOMY rules and the `dry` rule
(Field Cannons and bayonet Musketeers when the powder runs out). The army floor, the fighting rules (guns, line, screen,
cavalry micro, defence) and the home posts are left out in those two matchups. The mirror keeps the whole stack (see
choice 3). `-- crclean:off` plays today's whole stack everywhere; every old switch still works on its own.

| the same 10 games, Hard OPTIMAL v Hard OPTIMAL to 20:00 | today's stack | **cleaned set** | clean base (no coaching) |
|---|---|---|---|
| **v the Brood** (30 games each, 10 for the base) | | | |
| survived to 20:00 | 17 of 30 | **21 of 30** | 7 of 10 |
| won or led at 20:00 | 9 of 30 (1 won) | 6 of 30 (1 won) | 1 of 10 |
| mean g (ln score ratio; a beaten side counted a quarter) | -0.87 | **-0.69** | -1.11 |
| g14 (the score ratio at 14:00) | +0.01 | **+0.13** | -0.33 |
| median minute of the defeats | 18:01 | **19:05** | 16:59 |
| **v the Clockwork** (30 games each, 10 for the base; the cleaned set = pe1, pe2 and cs3, `dry` only in cs3) | | | |
| survived to 20:00 | 26 of 30 | **27 of 30** (cs3: 10 of 10) | 5 of 10 |
| won or led at 20:00 | 10 of 30 (5 won) | **22 of 30** (6 won; cs3: 10 of 10) | 1 of 10 |
| mean g | -0.23 | **+0.44** (cs3: +1.20) | -1.73 |
| g14 | -0.35 | **+0.02** (cs3: +0.35) | -0.92 |
| median minute of the defeats | 16:23 | **17:45** | 16:08 |
| income at 8:00, of the Clockwork's | 0.78 | **0.94** | 0.62 |
| income earned by 19:00 (median of the games still going) | 30,660 v 37,821 | **46,320 v 31,995** | |

Against the Brood the cleaned set is AS GOOD (a little better in g, g14, survival and the minute of the defeats, a little
worse in games led; all within the noise of three blocks). Against the Clockwork it is BETTER, clearly: the econ rules
alone are worth +1.3 in g over the clean base, while the fighting and home rules took about half of that back.

**The noise**: two blocks of the same code on the same 10 games differ by 0.3 to 0.9 in mean g (the games do not replay
exactly). The block `pa1` (plan + army) looked like the best set at +0.6 over plan alone; its rerun `pa2` was -0.6 under it.
Every decision below was made on at least two blocks or on g14 (steadier, about 0.2), never one block alone.

**Deleted**: the 25 changes of the two Crown 1000 jobs that were measured and not kept (13 against the Brood, 12 against
the Clockwork, including `trade` and `spend`): off by default, they never acted; their code and switches are gone (git
history before 0.38.87 has them).

**The Brood question**: yes, the Crown still collapses to the Brood's capped army between 15:00 and 19:00, with the
cleaned set and with the whole stack alike, and no rule group changes that. The numbers (below) look more like BALANCE
(the Brood's late economy) than like this AI's rules.

## 1. The inventory

Every coaching rule of the Crown computer, its switch, where it plays, and how often it ACTED in today's stack (block
`full1`, 10 games each to 20:00; counters in result.json `crown_ai`, the new ones under `rules`: AICrownRules.fire, a read
only count at each rule's action point). "Thinks" = think ticks the rule was in force (several a second).

| group | module | rule | switch | matchups | default | acted, v Brood (10 games) | acted, v Clockwork (10 games) |
|---|---|---|---|---|---|---|---|
| plan | ai_optimal.gd | lean to the Horseman rush before the scout | `optlean:off` | Brood | on | 10 games | never (Brood only) |
| plan | ai_crown_1k_brood.gd | `lean`: the rush's own build from 0:00 | `c1kblean:off` | Brood | on | 10 of 10 | |
| plan | ai_crown_1k_brood.gd | `siege`: the Siege push after the rush, no late re-pick | `c1kbsiege:off` | Brood | on | 16 pushes, 21 re-picks held | |
| plan | ai_crown_v_clock.gd | `pick`: Timing or Siege | `cvcpick:off` | Clockwork | on | | every game |
| plan | ai_crown_mirror.gd + ai_optimal.gd | the mirror's coached play and picks | `mirror:off` | mirror | on | | |
| econ | ai_crown_coach.gd | LABOURERS FIRST | `labsfirst:off` | all (v Brood after the first push held or 9:00) | on | 195 labourers | 477 labourers |
| econ | ai_crown_coach.gd | HALLS ON TIME (the hall wanted) | `hallsontime:off` | all (same) | on | 437 thinks short, 6 games | 91 thinks, 3 games |
| econ | ai_crown_coach.gd | HALLS ON TIME (the main full: the hall step first) | (same) | all | on | **never** | **never** |
| econ | ai_crown_coach.gd | FARM FIRST | `farmfirst:off` | all but the Rush plan | on | never (the lean is the Rush) | 10 of 10 |
| econ | ai_crown_v_clock.gd | `hall2`, `tech3` | `cvchall2:off`, `cvctech3:off` | Clockwork | on | | 10 of 10 / in force |
| econ | ai_crown_v_brood.gd | the economy after the hold (part 7) | `cbaecon:off` | Brood | on | (opens the coach's two rules) | |
| army | ai_crown_army.gd | THE ARMY CLOCK | `crownarmy:off` | Clockwork, mirror | on | | 16,571 thinks behind |
| army | ai_crown_coach.gd | THE ARMY FLOOR (labourers wait while the army is short) | `armyfloor:off` | all | on | 7,246 thinks | 8,518 thinks |
| army | ai_crown_v_brood.gd | the home line (part 1), the army floor tied to the Brood (5), hold the first push (6) | `cvb:off`, `cba:off` | Brood | on | 195 soldiers trained, 6 Barracks, the push held once | |
| army | ai_crown_coach.gd | THE SCREEN FIRST | `screenfirst:off` | all | on | 22 riders | 46 riders |
| army | ai_crown_v_clock.gd | `dry` | `cvcdry:off` | Clockwork | on | | 7,185 bayonet thinks, 22 guns |
| fight | ai_crown_guns.gd | the guns coached (9 parts) | `gunscoach:off` (and `gkeep`...) | all | on | sets 2, posts 223, kept 42 | sets 99, posts 184, kept 2,864 |
| fight | ai_crown_coach.gd | GUNS SET BEFORE CONTACT | `gunsfirst:off` | all | on | 36, in 2 games | 211 |
| fight | ai_crown_line.gd | THE LINE | `line:off` | all | on | **4 lines formed** (59 defence lines) | 33 formed, 63 defence lines |
| fight | ai_crown_screen.gd | THE RIDER SCREEN | `screen:off` | all | on | 13 riders sent | 155 sent, 440 flank hits |
| fight | ai_cav_micro.gd | THE CAVALRY MICRO | `cavmicro:off` | all | on | 762 blows | 1,207 blows |
| fight | ai_crown_defence.gd | the alert, the walk, the muster | `defence:off` | all | on | 22 musters; the wave held by the alert: never | 6 musters; wave held: once |
| home | ai_crown_hold.gd | THE RAMP / GATE / WALL / EDGE POSTS, the rider scouts | `hold:off` | all | on | gate post in force every game | in force |
| home | ai_crown_mirror.gd | the mirror's press, target, guns | `cmc:off` | mirror | on | | |

Never or almost never acting in today's stack: the coach's "main full: the hall step first" (0 in 20 games: another rule
moves the hall first), the defence's held wave (1 in 20), THE LINE against the Brood (4 lines in 10 games: the Brood is
first seen at contact, the guns' "set in time" 2), the Brood hold's wait (1). Rules that fight each other: THE ARMY FLOOR
holds the gold LABOURERS FIRST wants (against the Clockwork without the army group LABOURERS FIRST trained 867 labourers
in 10 games, with it 477), and the old halls on time rule in ai_crown.gd (`hallontime`) and the coach's two halls rules and
the Clockwork's `hall2` all move the same hall step. Contradictions in the measure: the fight and home groups, each
measured alone in its own job as "trades better, results unchanged", cost the score in 20-minute games (below).

The older rules inside ai_crown.gd itself (crown-eco, cinder, crcw, wall first, Mill feed and the rest, about 30 switches)
were counted as the core AI here, not as a group (choice 4).

## 2. The clean base and the add-back

tools/study/crown_rule_cleanup.py runs the 10 games of tools/study/crown_1000_brood.py (5 maps x 2 rounds, the starts
swapped, Hard OPTIMAL v Hard OPTIMAL to 20:00) with the switches of every group NOT kept passed off. Groups in order: plan,
econ, army, fight, home (the switches of each: `crown_rule_cleanup.py groups`). Data: docs/crown_rule_cleanup/data/<opp>/
<block>/ (result.json, story.txt; extra.txt the switches, groups.txt the groups on).

**Against the Brood** (the score: mean g, then g14; won or led of 10)

| block | groups on | g | g14 | survived | won or led | decision |
|---|---|---|---|---|---|---|
| clean1 | none | -1.11 | -0.33 | 7 | 1 | the base |
| plan1, plan2 | plan | -0.48, -0.80 | +0.33, +0.02 | 6, 8 | 4, 1 | **plan kept** (+0.5 over the base in g14 both times) |
| pe1 | plan, econ | -1.11 | -0.06 | 6 | 1 | econ not kept (g14 -0.2 under plan) |
| pa1, pa2 | plan, army | -0.24, -1.11 | +0.16, +0.09 | 10, 6 | 2, 0 | army not kept (the same as plan, pooled -0.67 v -0.64) |
| paf1 | plan, army, fight | -1.51 | -0.09 | 4 | 0 | fight not kept |
| pafB1 | plan, army, cavalry micro and defence only | -1.37 | -0.05 | 3 | 1 | (the fight group's cavalry and defence half alone: no better) |
| pah1 | plan, army, home | -0.99 | 0.00 | 6 | 2 | home not kept |
| full1, full2, full3 | all | -1.54, -0.51, -0.57 | -0.08, +0.08, +0.01 | 3, 6, 8 | 1, 5, 3 | today's stack |
| cs3 | the cleaned set's own code, no switch | -0.80 | +0.03 | 7 | 1 | matches plan1/plan2 |

**Against the Clockwork**

| block | groups on | g | g14 | survived | won or led | decision |
|---|---|---|---|---|---|---|
| clean1 | none | -1.73 | -0.92 | 5 | 1 | the base |
| plan1 | plan | -1.45 | -0.85 | 6 | 0 | plan kept with econ (the pick and `hall2` were measured together by the 1000 job) |
| pe1, pe2 | plan, econ | +0.23, -0.11 | -0.15, -0.13 | 9, 8 | 6, 6 | **econ kept** (+1.6 over plan in g, +0.7 in g14, twice) |
| pea1 | plan, econ, army | +0.10 | 0.00 | 8 | 6 | army not kept (the same as plan + econ); its `dry` rule kept on the 1000 job's evidence (choice 2) |
| pef1 | plan, econ, fight | -0.60 | -0.20 | 7 | 3 | fight not kept |
| pefB1 | plan, econ, cavalry micro and defence only | -0.83 | -0.30 | 6 | 2 | (no better) |
| peh1 | plan, econ, home | -0.38 | -0.25 | 8 | 4 | home not kept |
| full1, full2, full3 | all | -0.45, -0.30, +0.06 | -0.41, -0.34, -0.30 | 9, 8, 9 | 2, 4, 4 | today's stack |
| cs3 | the cleaned set's own code (plan, econ, `dry`) | **+1.20** | **+0.35** | **10** | **10** | |

## 3. The comparison

The tables in the summary pool the blocks: v the Brood today's stack full1-3 (30 games) against plan1, plan2 and cs3 (30);
v the Clockwork full1-3 (30) against pe1, pe2 and cs3 (30). Paired game by game the Brood's cleaned set is +0.18 in g (t 0.5,
5 better / 3 worse) and +0.12 in g14; the Clockwork's +0.67 (t 3.6, 9 better / 1 worse), plan + econ alone (pe1+pe2) +0.29
(t 1.0), with `dry` (cs3) +1.43 (t 4.7, 10 better / 0 worse).

What the dropped groups did, from the counters and the curves: against the Clockwork the army clock and the army floor
held LABOURERS FIRST back (477 v 867 labourers trained in 10 games) and the Crown's income at 8:00 was 0.78 of the
Clockwork's against 0.94 without them; by 19:00 the cleaned Crown had earned 46,320 to the Clockwork's 31,995 (today's
stack 30,660 to 37,821) and stood at 200 supply from 16:00. The fighting and home rules hold the army back (a wave waits
for its screen, forms a line, stands on its posts, musters) and the measured cost in 20-minute games was 0.2-0.8 in g in
both matchups, though each, measured alone in its own job, traded better in the fights it counted. Choice 1 says what is
lost.

## 4. The Brood question

With the best set, does the Crown still collapse to the Brood's capped army at 13-19 minutes? **Yes**, in the cleaned set
and in today's stack alike (the median of the games still going; tools/study/crown_rule_cleanup_curve.py):

| v the Brood, cleaned set (30 games) | 8:00 | 12:00 | 13:00 | 14:00 | 15:00 | 16:00 | 17:00 | 18:00 |
|---|---|---|---|---|---|---|---|---|
| army, Crown / Brood | 1,012 / 500 | 2,415 / 1,350 | 2,555 / 1,880 | 2,320 / 1,755 | 2,155 / 2,150 | 1,457 / 2,227 | 1,032 / 2,592 | 720 / 2,850 |
| supply | 67 / 58 | 108 / 112 | 108 / 137 | 107 / 141 | 92 / 148 | 74 / 147 | 58 / 171 | 61 / 188 |
| income a minute (the 2 minutes before) | 1,140 / 903 | 1,520 / 2,148 | | 1,650 / 1,943 | | 1,140 / 2,199 | | 950 / 2,403 |
| workers | 34 / 33 | 45 / 55 | | 45 / 56 | | 37 / 56 | | 28 / 56 |

Today's stack draws the same curve two minutes later (its army 2,720 / 2,625 at 14:00, 220 / 3,172 at 18:00). The Crown
LEADS the army to 13:00-14:00 and trades units well (from 12:00 to 18:00 it loses about 90 units and kills about 270), but
the Brood earns 2,000-2,400 a minute from 10:00 on with 55-56 grubs and stays at or near its 200 supply cap from 17:00,
remaking what it loses in a minute or two, while the Crown's income falls from 1,650 to 950 a minute as its labourers die
(45 -> 28) and its soil runs low. No rule group in either direction moved that: the econ rules cost the Crown army before
the collapse, the army, fight and home rules only moved it two minutes, and the 1000 job's 13 push changes did not either.
**So the remaining Crown v Brood gap looks like BALANCE, the Brood's late economy, more than this AI**: a Brood that keeps
56 grubs at 2,200 a minute against a Crown capped by its Farm posts. Two AI parts may still matter (proposals, not done):
the Crown's labourers at the outlying halls are lost from 14:00 (keep them, or move them in, when the Brood's capped
waves come), and the Crown does not take a 5th/6th hall against the Brood when its soil runs low (it does against the
Clockwork: 7 halls at 16:00). A balance look to pair with it: the Brood's income a grub and a Rootmaw after 10:00, and the
Crown's Farm posts a hall.

## 5. What changed in the code (0.38.87)

- scripts/ai_crown_rules.gd (AICrownRules, new): `fire(ai, name)` / `t(ai, name, v)` count a rule's acts (result.json
  `crown_ai` `rules`); `DROP` = the cleaned set by the enemy's faction (the study switches each group was measured with);
  `dropped(ai, sw)` = the switch given or left out of the cleaned set against `ai`'s enemy; `crclean:off` and
  `AICrownRules.whole = true` (tests) play the whole stack.
- Each dropped rule now asks AICrownRules.dropped when it is used: the coach's labsfirst, hallsontime, farmfirst,
  screenfirst, armyfloor and gunsfirst; AICrownArmy; AICrownVBrood's cvb, cba and cbaecon; AICrownVClock's dry; AICrownGuns,
  AICrownLine, AICrownScreen, AICavMicro and AICrownDefence when they are made; AICrownHold's `on`.
- Deleted: crown-1000-brood's eco, press, tech, halls, farms, queen, pester, edge, guns, maws, mortars, guard, spare and
  crown-1000-clockwork's share, hall3, hold, labs, guns, powder, foundry2, stand, spend, trade, richlabs, timingonly.
- tools/qa_match.gd: `crown_ai` gets `rules`, the mirror's press count, the defence's musters and the riders' blows.
- tools/study/crown_rule_cleanup.py (groups, run, report, fired), tools/study/crown_rule_cleanup_curve.py.

## 6. Claude's choices for the owner

1. **The fighting and home rules are left out against the Brood and the Clockwork.** They are the owner's own requests
   (setting guns before the engagement, screening with Horsemen, the line, the ramp post, the cavalry hit and run) and
   each made its fights look better when filmed; in 20-minute games they cost score in both matchups (fight -0.2 to -1.3,
   home -0.4 to -0.8 in g). A human watching the computer will see it fight as a blob again, without the screen or the
   line. If the owner wants the look back, `crclean:off` or a single rule's way back is one line in AICrownRules.DROP;
   the next coaching of those rules should measure to 20:00, not only the fights.
2. **`dry` kept against the Clockwork** though it sits in the army group, which was not kept (pea1 was no better than
   pe1/pe2): crown-1000-clockwork's biggest single find, and the cleaned set's own block with it (cs3) was the best block of
   the job (10 of 10 led or won).
3. **The mirror keeps the whole stack.** A rule cannot be measured in the mirror by switching it: both Crowns get it. One
   block of today's stack in the mirror (below) counts its rules; a per-side switch (like `buildstack:on0`) would be the
   way to measure them.
4. **The older rules inside ai_crown.gd** (crown-eco, cinder, crcw, the Mills, the walls, about 30 switches) are the core
   here: measuring them as more groups did not fit (each step costs 30-40 minutes a matchup).
5. **The other default-off switches still in the code** (cvbtarget, cvbcounter, cbacounter, broodhonest, broodecon,
   buildstack, hallkeep, hallgun, wallkeep, rushsat, blind, leanfree, truegreed, cvbkeep:wide) never act unless switched on;
   they were left (documented in their own jobs), the 25 newest ones deleted.
6. Counters count "acted" at each rule's action point where one was cheap to add; several older ones count thinks in
   force rather than acts (the table says which).
7. 27 blocks of 10 games (270 games): 14 against the Brood, 12 against the Clockwork, 1 in the mirror, about 30-40 minutes
   a block on this 2-core machine (two games at a time); not more reruns per step.

(The mirror block was stopped unfinished: see the note at the top.)

## 7. The tests (0.38.87, the cleaned set on)

The 43 AI tests (tools/test_ai_*.gd, tools/test_crown_*.gd; tools/study/crown1000_tests.sh one at a time) on the
cleaned set: **37 pass as they were**. Three tested a rule the cleaned set now leaves out against their test's enemy and
failed for that reason (test_crown_defence v the Clockwork, test_crown_hold and test_crown_owner_eco's [wall] v the Brood):
they now set `AICrownRules.whole = true` (the rule itself under test) and pass. Three fail on 0.38.86's code too, run there
the same day: test_ai_rush_followup (15-16 checks), test_crown_dragoon_raid ([plan], as CLAUDE.md notes) and test_ai_rush
(flaky: "workers before the Brood Mother" failed in 2 of 3 runs on the cleaned set, once with "the rush killed grubs", and in 1
of 2 on 0.38.86). Every Godot run on
this machine ends with "Aborted" at exit (exit code 134) after its result lines, the old code's too: the results are read
from the lines.
