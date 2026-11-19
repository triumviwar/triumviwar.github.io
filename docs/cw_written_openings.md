# The Clockwork's written openings (job cw-written-openings, 0.38.82)

The owner, 2026-11-19 07:26: "The Clockwork's OPTIMAL is already at or near the top everywhere. Owl raids and the Springer
timing are bad in every matchup. Maybe the owl and Springer are currently bad because they forget economy like horseman rush
did in the past?"

**Short answer: yes, mostly.** The four weak plans (Owl raids, Springer timing, Heavy Works push, Rush) all had one
Clocktower at 3:00 and two Cog Presses at 5:00 where OPTIMAL and Balanced had two and four, and were 2,000-4,000 cogs behind by
8:00. Started from the common opening (as OPTIMAL's own picks are), the Owls went from **2 to 11** games won or led of 24
(better than before in 9 paired games, worse in none, p 0.004), the Springers from **5 to 12** (7 / 1, p 0.07), the Heavy
Works push from **11 to 18** (8 / 1, p 0.04). The Rush, which is not a written opening, only moved **9 to 10**. They are
still not OPTIMAL's equal in the mirror (the Owls 1 of 8, the Springers 2, the Heavy Works 3) and the Springers and the Rush are still weak against the Brood.

Only the computer's play changed: no unit or building number. Data: `docs/cw_written_openings/data/` (the after games,
result.json, story.txt and the Clockwork's match-log lines, cwlog.txt), every table in `docs/cw_written_openings/tables.md`
(`python3 tools/study/cw_written_openings_report.py > tables.md`), films in `docs/cw_written_openings/films/`.

## 1. Where they starved (the plan-matrix games, 0.38.59, medians of all 24 games each)

| plan | 3:00 Winders / presses / Clocktowers / cogs earned | 5:00 | 8:00 | army at 5:00 |
|---|---|---|---|---|
| OPTIMAL | 17 / 2 / 2 / 1,915 | 26 / 4 / 2 / 4,021 | 43 / 6 / 3 / 9,650 | 385 |
| Balanced | 17 / 2 / 2 / 1,920 | 28 / 4 / 2 / 4,054 | 42 / 6 / 3 / 9,860 | 560 |
| Heavy Works push | 15 / 2 / **1** / 1,829 | 22 / **2** / 2 / 3,552 | 34 / 4 / 2-3 / 7,299 | 815 |
| Rush | **12** / 2 / **1** / 1,945 | 21 / **2** / 2 / 3,901 | 29 / 4 / 2 / 7,467 | 1,043 |
| Springer timing | 14 / 2 / **1** / 1,604 | 20 / **2** / **1** / 3,245 | 29 / 3 / 2 / 5,850 | 755 |
| Owl raids | 15 / 2 / **1** / 1,614 | 19 / **2** / **1** / 3,241 | 26 / 3 / 2 / 5,566 | 365 |

(presses = Cog Presses standing or spent; the second Clocktower in the minute snapshots: OPTIMAL and Balanced by 3:00,
the Heavy Works push and the Rush by 5:00, the Springers by 7:00, the Owls by 6:00)

What each one did instead of the economy:

- **Owl raids and Springer timing**: their written steps from 0:00 put a big Mainspring with 6 Winders on it, the Escapement,
  the Clock Aviary (two for the Owls) and the research (TICKING OWL, HIGH LEAP) before the second Clocktower, which was
  their **last** step; the Winders stopped at the plan's goal (14, then 18) for minutes. 3-4 fewer Winders at 3:00,
  6-7 fewer at 5:00, half the presses, and the second Clocktower 3-4 minutes late.
- **Heavy Works push**: the same shape (Mainspring, Escapement, Heavy Works, Ballistas, then the Clocktower): a little
  less starved (its tech is cheaper in Tension), the second Clocktower at ~4-5:00.
- **Rush**: it is not a written build; it is the shared computer on the Rush numbers: a quarter fewer Winders, the second
  Clocktower 2.5 times later, two halls, tech late. Its army (1,043 at 5:00, the most) should pay for that, but the
  Clockwork's attacks are the ONE ARMY push, which goes only when stronger than the enemy army it reckons: its first
  attack came at a median 5:40-7:15, later than OPTIMAL's (5:20-5:55). So the starved economy bought nothing.

## 2. What changed (scripts/ai_clockwork.gd; the computer's play only)

1. **The Owl raids, Springer timing and Heavy Works push start from the common opening** (`COMMON_FIRST`): Balanced's
   written opening, as OPTIMAL plays it (Winders non-stop, the second Clocktower at ~1:50, the scout and its rush
   reaction), then their own build from where the game stands, once the second Clocktower is laid and 2:15 has passed
   (3:00 at the latest). The switch is OPTIMAL's own (`opt_switch`): the steps already done are passed by, the raid, the
   flock and the push are made new. Their own units scout from then, as before. `-- cwcommon:off` plays them from 0:00.
2. **Against the Brood the Owls and the Springers wait for the new presses** (`BROOD_LATE`): the Brood computer reads the
   common opening as GREEDY and sends its Raptor rush at ~2:50-3:30 (as it does against OPTIMAL and Balanced); begun at
   2:15 these two builds met it half-way through their Mainspring, Aviary and research and lost their Winders (0 of 4
   each in the first games). Now they begin once the common opening has laid the second Clocktower's two presses (where
   Balanced itself hands over to the shared rules against the Brood), or at 4:30. The Heavy Works push begins at 2:15
   there too (it held). `-- cwbroodlate:off` as at first.
3. **Tension, not cogs** (`_tension_spring`): a build begun from the common opening has more cogs and its Mainspring later;
   when its next step has waited only for Tension for 20 s with the cogs free, a Clocktower without a Mainspring gets one
   (the Owls on Greenhold waited on Tension from 3:30 with 1,000 cogs in the bank, and the "stuck" rule ended the build
   at 5:55 with one Owl and no raid).
4. **The bank works against every faction** for these builds (`_cc_bank`, until now against the Crown only): cogs no step
   is waiting for (350+ for 15 s) become Clock Soldiers from the idle Light Works (the Owls v the Clockwork had 1,467 cogs
   in the bank at 6:00 and one Clock Soldier to meet a push of 867). `-- cwbankall:off` keeps it to the Crown.
5. **The Rush turns to the economy** (`_rush_turned`): it opens on the Rush numbers (an army first) and turns to
   Balanced's Winders, expansions, halls and tech once its first push is out or at 4:00 (its waves stay the Rush's).
   `-- cwrushturn:off` as before.
6. The switch to the written build comes before the opening's hand-over rules (dry land, stuck, the Brood hand-over), so
   the common opening cannot end without its build beginning.

OPTIMAL is untouched by construction: every rule above is for a plan forced from the lobby (OPTIMAL's picks already start
from the common opening and never pick the Rush).

## 3. Measured: each plan v each faction's Hard OPTIMAL to 20:00, before (0.38.59) and after (this build)

The plan-matrix design: 4 maps (Greenhold, Ashford Crossing, Mirewood, Cinder Steps) x 2 seeds with the spots swapped,
8 games a cell, the same tags (map, seed, spots) as the study, so every after game pairs with its before game.
"Won or led" = won, or a draw at 20:00 led by 10% (income earned + 2 x army value).

| plan | v Crown before | after | v Brood before | after | v Clockwork before | after | all 24 before | after | paired better / worse (p) |
|---|---|---|---|---|---|---|---|---|---|
| Owl raids | 1 (0-3-5) | **6** (4-4-0) | 1 (0-1-7) | **4** (3-4-1) | 0 (0-0-8) | 1 (1-0-7) | 2 | **11** | 9 / 0 (**0.004**) |
| Springer timing | 4 (2-3-3) | **8** (3-5-0) | 1 (1-2-5) | 2 (2-1-5) | 0 (0-0-8) | 2 (1-1-6) | 5 | **12** | 7 / 1 (0.07) |
| Heavy Works push | 5 (3-4-1) | **8** (3-5-0) | 6 (5-1-2) | 7 (7-0-1) | 0 (0-0-8) | 3 (3-1-4) | 11 | **18** | 8 / 1 (**0.04**) |
| Rush | 3 (1-6-1) | 6 (2-6-0) | 2 (1-1-6) | **0** (0-0-8) | 4 (4-1-3) | 4 (4-0-4) | 9 | 10 | 5 / 4 (1.0) |
| OPTIMAL (the study) | 8 (6-2-0) | | 7 (6-1-1) | | 6 (6-0-2) | | 21 | | |

(W-D-L in brackets. One Heavy Works mirror game ran past the study's 50-minute limit and was played again with a longer
one: a win.)

By opponent, better / worse paired (v Crown, v Brood, mirror): the Owls 5/0, 3/0, 1/0; the Springers 4/0, 1/1, 2/0; the
Heavy Works push 3/0, 2/1, 3/0; the Rush 4/1, **0/2**, 1/1.

### The economy after (medians of all 24 games: Winders / presses / Clocktowers / cogs earned)

| plan | 3:00 before | after | 5:00 before | after | 8:00 before | after | earned 20:00 before | after |
|---|---|---|---|---|---|---|---|---|
| Owl raids | 15 / 2 / 1 / 1,614 | 17 / 2 / 2 / 1,924 | 19 / 2 / 1 / 3,241 | 25 / 4 / 2 / 3,966 | 26 / 3 / 2 / 5,566 | **39 / 4 / 3 / 8,498** | 24,113 | 22,358 |
| Springer timing | 14 / 2 / 1 / 1,604 | 17 / 2 / 2 / 1,920 | 20 / 2 / 1 / 3,246 | 25 / 4 / 2 / 3,946 | 29 / 3 / 2 / 5,850 | **40 / 4 / 3 / 8,585** | 31,841 | 37,168 |
| Heavy Works push | 15 / 2 / 1 / 1,829 | 18 / 2 / 2 / 1,930 | 22 / 2 / 2 / 3,552 | 24 / 4 / 2 / 4,038 | 34 / 4 / 2 / 7,300 | **37 / 4 / 3 / 8,790** | 36,410 | 39,348 |
| Rush | 12 / 2 / 1 / 1,946 | 12 / 2 / 1 / 1,958 | 21 / 2 / 2 / 3,902 | 21 / 2 / 2 / 3,906 | 29 / 4 / 2 / 7,468 | **40 / 4 / 3 / 8,163** | 31,033 | 36,225 |
| OPTIMAL (the study) | 17 / 2 / 2 / 1,915 | | 26 / 4 / 2 / 4,022 | | 43 / 6 / 3 / 9,650 | | 41,445 | |

(the 20:00 medians are of the games still going at 20:00, few for the Owls)

The three written builds now earn 8,500-8,800 by 8:00 (OPTIMAL 9,650; before 5,600-7,300); the gap to OPTIMAL is what
their tech costs, not a missing Clocktower. The Rush gains less (+700 by 8:00): its first four minutes are still the Rush.

### Their identity (after; from the Clockwork's match-log lines, medians, with in how many of 8 games)

| plan | v | own build began | the plan's own move | pushes out (first) |
|---|---|---|---|---|
| Owl raids | Crown | 2:15 | first Owl 6:08 (8), first sortie 7:36 (7), 2.5 sorties and 2.6 strikes a game | 8:33 (7) |
| Owl raids | Brood | 3:29 | first Owl 7:07 (8), a sortie in 3 of 8 (10:18) | 9:55 (4) |
| Owl raids | Clockwork | 2:15 | first Owl 6:32 (5), a sortie in 3 of 8 | 7:00 (1) |
| Springer timing | Crown | 2:15 | the raid out 5:22 (8), first leap 6:34 (8), 8 leaps a game | 8:17 (8) |
| Springer timing | Brood | 3:23 | the raid out 6:03 (6), a leap in 2 of 8 | 10:07 (2) |
| Springer timing | Clockwork | 2:15 | the raid out 5:24 (7), a leap in 4 of 8 | 9:20 (2) |
| Heavy Works push | Crown | 2:15 | - | 6:41 (8), 2.4 pushes a game |
| Heavy Works push | Brood | 2:15 | - | 8:41 (7) |
| Heavy Works push | Clockwork | 2:15 | - | 6:18 (7) |
| Rush | all | (turns to the economy at 4:00 in all 24) | - | 7:03 / 8:56 (3) / 7:34 |

The Owls still raid (later: the first Owl ~6:10 where the build from 0:00 had it ~4:50-5:30), the Springers still leap on
a timing (the raid ready ~5:20, it was ~4:20), the Heavy Works still push (6:40 v the Crown, was 5:47). Before, the
Springers' first attack v the Brood came at a median 16:35 and the Owls' at 11:40-18:25.

### OPTIMAL not hurt

OPTIMAL runs none of the new rules (they are only for a plan forced in the lobby), so its games can only differ by the
match's own noise. As a check its 12 games on the first two maps (Greenhold, Ashford Crossing) were played again on this
build: won or led **10 of 12 before, 10 of 12 after** (v Crown 4 -> 4, v Brood 3 -> 4, mirror 3 -> 2), better in 1, worse
in 1 (p 1.0); cogs earned by 8:00 a median 9,838 -> 9,032, by 20:00 38,096 -> 40,138 (the same games' noise).

## Films (new games on the study's map, seed and sides; `tools/study/plan_matrix_cw_film.sh`, FILM_KEEP)

**1. Owl raids v the Crown, Greenhold** (`films/pm_cw-owls_v_cr_greenhold_r0/`, the study's worst film, now): a draw at
20:00 **led far by the Clockwork** (earned 31,223 v 27,360; army 7,830 v 620; 54 Winders v 11 Labourers; 6 halls v 2).
The study's film of the same tag (before) was its worst game: earned 26,983 v 45,880, 5 halls v 7.
- 0:00-2:15 the common opening; 2:15 "now plays the Owl raids from where it stands". 4:47 the build waits on Tension with
  cogs free: a second Mainspring; 4:46-6:20 the bank works trains a Clock Soldier from the idle Light Works every 15 s.
- 6:09 the first Ticking Owl; 6:35 the flock is ready; 8:10 the first sortie (to the Crown's workers), 11:49 a Powder
  Mill, 16:40 and 19:08 strikes.
- 9:04 the first push (15 units); 13:50 the second (22) is "clearly ahead (2,035 against 455)" and presses on to the
  Crown's halls; by 20:00 the Crown has 11 Labourers.
- Coach: the Owls are the side show they should be: the game is won by the economy and the pushes behind them. The
  Crown's anti-air still keeps the flock to 4 sorties in 20 minutes.

**2. Springer timing v the Brood, Greenhold** (`films/pm_cw-springer_v_br_greenhold_r0/`): a draw at 20:00, the
Clockwork's army 7,505 v 4,060, income 30,469 v 32,912 (even by the 10% rule).
- 2:15 the build switches (this film is the first version of the rule; the study's games v the Brood wait for the new
  presses, ~3:25); 2:45 Raptors seen, 3:23 the rush reaction (a Light Works, Clock Soldiers, then a Heavy Works and
  Pendulums against the swarm).
- 4:11 HIGH LEAP, 6:04 the Springer raid goes out (4 Springers, a Swift, 2 Winders, 4 Clock Soldiers), 7:08 four
  Springers leap into the Brood's base, out after 12 s with 325 killed, in again at 7:31 (500 killed), out when the
  defence comes.
- 10:22 the first push (18 units); the Brood turns to its Brute siege and the game stays even to the bell.
- Coach: the leap is there and pays (500 for 4 Springers), but against the Brood the plan's later army is thin
  (median 300 at 12:00 in the study games): the Brood's swarm and Brutes are what the Springers are worst at.

## What is left (for the owner)

1. **The mirror is still mostly lost**: Owls 1 of 8, Springers 2, Heavy Works push 3. The Clockwork OPTIMAL (Balanced or
   Economy) pushes at ~5:30-6:00 with Clock Soldiers; any build spending on tech then (Aviaries, research, a Heavy Works)
   meets it with half the army. The economy is no longer the reason (40 Winders at 8:00 v 48). A mirror answer would be
   OPTIMAL's: Balanced or the Clock Soldier rush.
2. **The Springers and the Rush against the Brood**: 2 of 8 and 0 of 8. The Brood reads the economy as GREEDY, rushes,
   holds, then turns to the Brute siege; the Springers' and the Rush's armies are the wrong kind there (no Pendulums).
3. **The Rush is the one plan the change did not fix** (9 -> 10): its economy until 4:00 is still the Rush's, and the ONE
   ARMY push means it never attacks early (first push 7:03 v the Crown). Either the Clockwork's Rush gets a real early
   attack (a push allowed at its own wave of 6, whatever the reckoning) or it is the Clock Soldier rush under another
   name; the owner's call.
4. **The Owls' raids are few against the Crown and the Clockwork** (2.5 and 0.6 sorties a game): anti-air guards every
   target (Musketeers, canister, Netters). Not an economy question.

## Claude's choices

1. **Balanced's opening is the common opening** (OPTIMAL's), not Economy's: it is the one OPTIMAL's Springer v the Crown
   won 5 of 5 from.
2. **The switch at 2:15 once the second Clocktower is laid** (3:00 at the latest): OPTIMAL switches at 2:15-3:00 after its
   read; a fixed point keeps the plan's identity the same every game.
3. **The Clock Soldier rush and the Pendulums keep their opening from 0:00**: the rush is an early attack (its 2:00
   would not survive a common opening) and the Pendulums were already 19 of 24; the owner named the four above.
4. **Against the Brood only the Owls and the Springers wait for the new presses**; the Heavy Works push held there
   (3 of 4 in the first games) and its push needs its machines early.
5. **The Rush's turn keeps its waves** (Rush numbers for "wave" and "step") and only takes Balanced's economy numbers.
6. **Kept although the Rush is no better v the Brood** (2 -> 0): over all 24 it is 10 v 9 with more income at every
   minute; switch `cwrushturn:off`.
7. **The second Mainspring for Tension** only for the builds from the common opening; OPTIMAL's builds are not touched.
8. **The OPTIMAL check was played on two maps** (12 games), not four: OPTIMAL's code paths are unchanged, so the check is
   for noise only, and the time went to the 96 plan games.
9. **The tests' times were moved** (test_clockwork_owls: the first Owl by 6:30, the raid ready by 7:00; 
   test_clockwork_springer_timing: the leap by 7:00), since the builds now begin at 2:15.

## Tests

- New: `tools/test_cw_written_openings.gd` (the three builds begin at 2:15-3:00 and play their plan, the second
  Clocktower by 3:00, 18+ Winders at 4:00, 3+ presses at 5:00; the Rush turns by 4:00): PASS.
- Run on this build (43 Clockwork AI tests: tools/test_cw_*.gd, test_clockwork_*.gd and the test_ai_*.gd that play the
  Clockwork), bare runs:
  - **pass**: test_cw_written_openings, test_clockwork_owls and test_clockwork_springer_timing (with the moved times),
    test_clockwork_army, _builds_a, _eco, _home, _sounds, test_ai_cw_horse_raid, test_ai_expand, test_ai_optimal,
    test_ai_placement, test_ai_r5_hold_spots, test_ai_round6, test_ai_round6_stall, test_ai_scout_defence,
    test_ai_abandoned_site, test_cw_ai, _air, _air_ai, _builders_share, _carrier, _couple, _crate_build, _lab, _plate,
    _raid_leash, _rifleman, _scout_workers, _scrapper, _siding, _storm, _tesla, _tier2, _tier3_ai, _work_car
    (test_cw_gun_rush prints its measure, no verdict);
  - **passed on a rerun**: test_clockwork_builds_b (the first run: the Pendulums' push not out by 9:00; the Pendulums are
    not changed here, and it passed twice after, once with this job's switches off), test_cw_army (3 checks the first
    run, unit mechanics; passed twice after), test_ai_scout_sentry (known flaky);
  - **fail**: test_cw_heavy (1), test_cw_militia (1), test_cw_tier3 (3 online checks): listed in CLAUDE.md as failing
    before; test_ai_harass's [raid] check fails in a bare run every time (2,997 -> 2,955 px) but passes with any
    command-line argument, this job's switches on or off: a Crown v Brood case, no Clockwork in it, so not this change.
