# balance-raptor-horseman: the Raptor and the Horseman, retuned (2026-11-15)

The owner's decisions (2026-11-15 00:38-00:53, set against StarCraft II's Zergling and Hellion), applied on the branch
`balance-raptor-horseman` (version 0.38.3). No AI code was changed (the Crown coaching jobs run at the same time).

## What changed

| | before | after |
|---|---|---|
| Raptor health | 36 | **38** |
| Raptor speed | 96 | **92** |
| PACK HUNT (Tyrant Sire), the Raptor's bonus | +18 (114) | **+22 (114)**; the Tyrant Challenger (+14) and the Tyrant Sire (+11) unchanged |
| Horseman (`cuirassier`) health | 140 | **100** |
| Horseman cost | 115 (+40 for his horse when no spare one stands ready) | **100** (+40 the same) |
| Cuirassier (armoured Horseman, +30) | 170 | **130** |
| KEEN SABRES (new, at the HORSE BREEDER) | | **75 gold, 30 s**: +6 sabre damage against LIGHT units for Horsemen and Cuirassiers (18 -> 24) |

- Only with Pack Hunt does a Raptor outrun horses now (92 < a Horseman's 112 < 114).
- KEEN SABRES (`Defs.RESEARCH["keen_sabres"]`, a drill: every rider has it at once, like the Cavalry Charge). The +6
  is added in the saddle only (the `_:` blow in `Unit._strike`), before the charge, the Pikeman-style kind bonuses and
  veterancy multiply it (veterancy and the band's pipes scale it too). Light = the "light" tag: Raptors, Spitters, Grubs,
  Musketeers, Officers, Horsemen, Clock Soldiers, Winders and the rest; armoured units (Brutes, Guardsmen, Cuirassiers,
  machines) and buildings take nothing more. The Officer's sabre on foot and the pistol shot are unchanged. Price and
  time are Claude's (the Cavalry Charge is 60 gold, 25 s). Icon: a stand-in (the Charge's icon mirrored and tinted
  steel blue, `assets/icons/research_keen_sabres.png`; noted in docs/art_style_inconsistency.md).
- The Cavalry Charge stays at the Armoury (undecided).
- Health across the saddle: mounting and dismounting keep the health SHARE (`Unit.morph`), so nothing is created or
  lost: a full Officer (80) rides as a full Horseman (100), a half-health Horseman gets off as a half-health Officer
  (40 of 80); the Armoured Officer 110 <-> the Cuirassier 130. The Dragoon (90) and the Musketeer (70) are untouched
  (tools/test_keen_sabres.gd checks all of it).
- Texts: the Horseman's and the Horse Breeder's "about" and tooltip, the Raptor's tooltip, Pack Hunt's text (92 to
  114), the Help page (the Horse Breeder researches KEEN SABRES), the new research's texts, all in en/pt/es
  (tools/i18n/71_balance_raptor_horseman.txt and the edited entries). No card line, help page or tutorial text stated
  140, 115, 36 or 96, so nothing else needed a number changed. Two code comments (defs.gd) now say 38.
- Side effects of the health numbers: a Horseman's body is smaller (100 + his horse's 60 = 160, was 200): it rots a
  little sooner and the Brood's grubs harvest it in 1.81 s (was 2.03) for fewer spoils; a Raptor's body (38) a little
  longer.
- Tests updated for the numbers: test_horses (the prices), test_ground_attack (bodies and harvest times),
  test_brood_new (the speeds), test_brood_rush_riders (its "of N" health). New: tools/test_keen_sabres.gd,
  tools/test_unit_duel.gd (any N v M stand-up fight, `set:` numbers and `tech0:/tech1:` research). Measuring only:
  `Game.death_log` (null in a normal game) and tools/qa_match.gd's riders' trades (`riders_seen`, `deaths`).


## The answers in plain words

1. **Without KEEN SABRES the Raptor now wins the early fight against Horsemen**, at equal cost and even a little under
   it, in every set-up: 2 Horsemen against 10 Raptors went from riders 6 of 6 (stand-up, standing, kiting) to 1, 0
   and 1 of 6. That is the owner's StarCraft picture: Zerglings beat Hellions until Blue Flame.
2. **With KEEN SABRES the riders get most of it back**: 2 v 10 riders win 6 of 6 riding about and kiting again (they
   lose about as much health as before, 127-139, but now of 200), but standing still in the pack they lose (0 of 6; was 6 of 6,
   3 Raptors left). One Horseman with it beats 5 Raptors 6 of 6 even standing. So the research decides the matchup,
   as intended; standing in a pack of Raptors is no longer free.
3. **Pack Hunt** changes little in the stand-up fight (riders 3 of 6 riding about, 0 kiting): the speed matters for
   catching riders and running from them on the map, not in a melee.
4. **The Horseman is weaker against everything else** (100 health): against Musketeers (who beat him before too) he
   now dies faster; against Officers (light, pistol and sabre) 2 Horsemen went from winning 4 of 6 against 3 to 1 of 6.
   Against Clock Soldiers he still wins (2 v 4: 6 of 6, with less health left; with Keen Sabres +20).
5. **In computer games nothing broke.** Results moved inside the noise of 8 games a matchup (a won-or-led count moves
   +-3 between two runs of the same games), except the Brood mirror, which was decided far more often (5-2-1 against
   2-6-0). The riders killed a third fewer creatures against the Brood (218 v 338) and fewer workers against the
   Clockwork (38 v 59). The Crown computer still wins nothing against the Brood or the Clockwork, as before.

## The stand-up fight (tools/test_raptor_rider_fight.gd, 6 trials each, Greenhold's flat patch)

Riders won / average rider health lost (of 280 before, 200 after) / Raptors left. "Before" ran on main (0.38.2).
Costs: 2 Horsemen with their horses 310 gold before, 280 after; 10 Raptors 250 food (5 eggs), 11 Raptors 275.

| set-up | standup (ride-by) | stand (no ride-by) | kite (hit and run) |
|---|---|---|---|
| 2 v 10, before | 6/6, 136, 0 | 6/6, 193, 0 | 6/6, 128, 0 |
| 2 v 10, after | **1/6**, 193, 4.2 | **0/6**, 200, 7.3 | **1/6**, 198, 3.2 |
| 2 v 10, after, Keen Sabres | 6/6, 127, 0 | 0/6, 200, 3.0 | 6/6, 139, 0 |
| 2 v 10, before, Pack Hunt | 6/6, 132, 0 | 6/6, 185, 0 | 6/6, 142, 0 |
| 2 v 10, after, Pack Hunt | 3/6, 177, 2.3 | 0/6, 200, 7.2 | 0/6, 200, 4.0 |
| 2 v 10, after, Pack Hunt and Keen Sabres | 6/6, 137, 0 | 1/6, 194, 2.5 | 6/6, 134, 0 |
| 2 v 12, before (equal cost then) | 6/6, 206, 0 | 2/6, 276, 2.3 | 6/6, 182, 0 |
| 2 v 11, after (equal cost now) | 0/6, 200, 6.7 | 0/6, 200, 8.3 | 0/6, 200, 6.7 |
| 2 v 11, after, Keen Sabres | 3/6, 192, 2.0 | 0/6, 200, 5.5 | 4/6, 175, 0.7 |
| 3 v 15, before | 6/6, 194, 0 | 6/6, 288, 0 | 6/6, 187, 0 |
| 3 v 15, after | 0/6, 300, 7.3 | 0/6, 300, 11.3 | 0/6, 300, 6.3 |
| 3 v 15, after, Keen Sabres | 5/6, 204, 0.5 | 1/6, 299, 4.2 | 6/6, 228, 0 |
| 1 v 5, before | 6/6, 62, 0 | 6/6, 101, 0 | 6/6, 62, 0 |
| 1 v 5, after | 2/6, 98, 2.2 | 0/6, 100, 3.2 | 0/6, 100, 3.5 |
| 1 v 5, after, Keen Sabres | 6/6, 68, 0 | 6/6, 93, 0 | 6/6, 78, 0 |

The Raptors at a wall against a perfect scripted hit and run (tools/test_brood_rush_riders.gd, 2 Horsemen, 4 trials):
the riders still kill all 10 Raptors every trial, losing 72-141 of 200 (before 20-60 of 280; one rider died in one
trial), and the wave takes 268-312 palisade health a trial (before 148-196). tools/test_brood_v_riders.gd (the Hard
Brood computer against a scripted 3-rider raid on its grubs): the same result before and after (6 of 13 grubs lost:
its "at most 40%" check fails on main too); the riders died 1 and left 2 (before: 0 dead, 3 left).

## Other units (tools/test_unit_duel.gd, both sides attack-move, 6 trials; "before" = set:cuirassier.hp=140 on this branch)

| fight | before | after | after, Keen Sabres |
|---|---|---|---|
| 2 Horsemen v 5 Musketeers (280-310 v 300) | Musketeers 6/6, 3.5 left, 8 s | Musketeers 6/6, 4.0 left, 6 s | Musketeers 6/6, 3.3 left |
| 4 Horsemen v 8 Musketeers | Horsemen 1/6 | Horsemen 0/6, 5.3 Musketeers left | Horsemen 2/6, 3.2 left |
| 2 Horsemen v 4 Clock Soldiers (280 v 280) | Horsemen 6/6, 193 hp left | Horsemen 6/6, 126 hp left | Horsemen 6/6, 147 hp left |
| 2 Horsemen v 3 Officers | Horsemen 4/6 | Horsemen 1/6 | Horsemen 1/6 |

(The Musketeers' first volley decides those fights in 6-8 s: Horsemen never were a Musketeer answer.)

## Computer games, before v after

Hard OPTIMAL v Hard OPTIMAL (tools/qa_match.gd), to 15:00, maps Greenhold, Mirewood, Hollowfen and Dune Sea, 2 seeds
each with the sides swapped: 8 games a matchup a build, 80 games. "Before" = main at 0.38.2 (the measuring additions
only), "after" = this branch. A draw's leader as in docs/winrate_2026_11_12.md (income earned + 2 x army, 10% ahead).
Noise: about +-3 in a won-or-led count of 8.

| matchup (first side's view) | before: W-D-L | won or led first/second/even | decided, mean length | after: W-D-L | won or led | decided, mean length |
|---|---|---|---|---|---|---|
| Crown v Brood | 0-0-8 | 0/8/0 | 8, 12:11 | 0-2-6 | 0/8/0 | 6, 11:08 |
| Crown v Clockwork | 0-7-1 | 0/8/0 | 1, 11:28 | 0-5-3 | 0/8/0 | 3, 12:31 |
| Brood v Clockwork | 1-5-2 | 3/4/1 | 3, 11:48 | 2-4-2 | 3/5/0 | 4, 12:32 |
| Crown v Crown | 0-8-0 | 4/2/2 | 0 | 0-8-0 | 2/3/3 | 0 |
| Brood v Brood (P1's view) | 2-6-0 | 8/0/0 | 2, 12:55 | 5-2-1 | 6/1/1 | 6, 12:12 |

The riders' trades (every death in those games, `Game.death_log`): Horsemen and Cuirassiers ever in the saddle, riders
killed, kills by riders (Raptors among them, workers among them), and the Raptors' own trades.

| matchup | build | riders made | riders lost | kills by riders | of them Raptors | workers | Raptors lost | kills by Raptors |
|---|---|---|---|---|---|---|---|---|
| Crown v Brood | before | 64 | 63 | 338 | 265 | 42 | 744 | 416 |
| Crown v Brood | after | 65 | 66 | 218 | 169 | 39 | 1135 | 423 |
| Crown v Clockwork | before | 60 | 32 | 98 | | 59 | | |
| Crown v Clockwork | after | 57 | 40 | 70 | | 38 | | |
| Crown v Crown | before | 157 | 49 | 179 | | 104 | | |
| Crown v Crown | after | 171 | 39 | 215 | | 153 | | |
| Brood v Clockwork | before | | | | | | 1328 | 520 |
| Brood v Clockwork | after | | | | | | 1151 | 466 |
| Brood v Brood | before | | | | | | 5481 | 4734 |
| Brood v Brood | after | | | | | | 4063 | 3443 |

Income earned (Crown v Brood, OPTIMAL): Brood by 6:00 4,600 -> 4,690, by 8:00 8,075 -> 8,332; Crown 3,610 -> 3,800 and
5,368 -> 5,368.

**KEEN SABRES in the computers' hands**: no AI was changed, but the Crown computer's generic research loop
(`AI._research`, `RESEARCH_AT`) buys any research it has no rule for once it has the gold, so its 32 Crown computers (24
games) researched Keen Sabres 31 times, between 6:02 and 7:33, whether or not it had riders left. (Before, the Cavalry
Charge came at 7:39-14:58; after, 9:53-14:13.)

### The Horseman rush against the Brood

The Crown computer on RUSH against the Hard Brood OPTIMAL, the same 4 maps x 2 seeds, 15:00:

| | Crown W-D-L | won or led Crown/Brood/even | riders made | riders lost | kills by riders (Raptors, workers) | Brood earned by 6:00 | Crown by 6:00 |
|---|---|---|---|---|---|---|---|
| before | 0-4-4 | 0/7/1 | 83 | 70 | 213 (138, 56) | 3,454 | 3,800 |
| after | 0-5-3 | 0/7/1 | 84 | 82 | 226 (149, 60) | 3,551 | 3,848 |

The rush still holds the Brood's income well under its OPTIMAL games (3,500 against 4,600 by 6:00), before and after:
the cheaper Horseman (more riders for the gold) and Keen Sabres from about 6:00 make up for his lost health in these
computer games. The rush never researches Keen Sabres before its raid (the generic loop waits for spare gold), so the
raid itself is weaker against Raptors than before; it hits grubs (light, unarmoured) about as hard as before.

## Tests

Pass on the branch: test_keen_sabres (new), test_unit_stats, test_card_text, test_i18n (0 untranslated), test_content_all
(0 FAIL, 16 WARN as on main), test_horses, test_ground_attack, test_brood_new, test_ai_brood, test_brood_ai_defend,
test_brood_builds, test_brood_controls, test_brood_far, test_brood_fix3, test_brood_fixes, test_brood_layout,
test_brood_mirror, test_brood_paths, test_brood_spend, test_crown_ammo, test_crown_build_order, test_crown_hold,
test_crown_line, test_crown_rider_screen, test_crown_v_brood, test_crown_siege, test_crown_gate, test_crown_mirror,
test_dragoon_remount, test_horse_care, test_loose_horses, test_ride_by, test_ride_by_raid, test_cliff_horse,
test_haulers, test_cinder_crown, test_crown_balloon, test_crown_farms, test_crown_stall, test_crown_lost_hall,
test_brood_rush_riders. Fail the same way on main (0.38.2): test_brood_new_defence (the rooted-muskets case),
test_crown_dragoon_raid ([plan]), test_brood_v_riders (grubs lost), test_brood_production / test_brood_regen_calm /
test_card_keys (a SCRIPT ERROR in Main._menu_button, scripts/main.gd:536, when a test returns to the menu: the menu after
0.38.2's Lab removal; their own checks pass), test_ai_cw_horse_raid (flaky: one check before, two after, different
checks each run).

## Anything that looks broken

- Nothing crashed or stalled in 96 games. No rule broke.
- **Horsemen without Keen Sabres are now a poor answer to Raptors**: 2 v 10 lose in every set-up, 1 v 5 too. This is
  the intended Hellion-before-Blue-Flame shape, but a Horseman rush that meets Raptors before its research arrives
  loses its riders; the owner's own opening (Horse Breeder first) should research it at once.
- **Officers beat Horsemen now** (3 Officers, 225 gold, beat 2 Horsemen, 280 with horses, 5 of 6): the Officer still
  has 80 health and costs 75, and an Officer + a horse (115) is now much cheaper than a Horseman + his horse (140), for
  the same rider once he mounts (the share keeps his health full). It was already cheaper before (115 v 155).
- The Brood mirror decided 6 of 8 games (was 2 of 8). Too few games to call; worth a look in the next win-rate study.

## Claude's proposals (nothing applied)

1. **The Crown computer and Keen Sabres** (for a crown-coach job, AI only): research it only with riders on the field
   (`RESEARCH_AT` "keen_sabres": ["horse", 2], as the Cavalry Charge), and at once in rider plans (the Horseman rush,
   the Dragoon raids' Horsemen, the rider screen) and whenever the scout has seen Raptors; today it buys it at 6-7
   minutes whatever it has.
2. **The Officer's price**: 75 -> 60 keeps the old rule "the Horseman's price less his horse's" (100 - 40), or the
   Officer's 75 stays and the rule's comment changes. Today training an Officer and mounting him is the cheaper
   Horseman (115 v 140).
3. **Keen Sabres' price and time** (75 gold, 30 s) look right: it is cheap enough to come with the first riders. If the
   owner wants the early riders to hold against Raptors only after a real choice, 100 gold and 40 s (the Cavalry Charge
   is 60, 25 s).
4. Re-run the win-rate study's Crown v Brood and Brood mirror rows on the merged build (38 games each) before more
   balance changes.
