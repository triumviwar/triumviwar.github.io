# AI fixes A: a gentler Normal Brood, and the Clockwork's answer to small raids

Job ai-fixes-a (the owner, 2026-11-28: yes to two proposals of docs/ai_opponent_review.md). The computers' PLAY only: no
unit, building or balance number changed. Each fix has its own switch; on by default only where it was measured to work.
Measured on 0.38.230 (branch ai-fixes-a), 220 games: 90 benchmark games to 15:00 and 80 Hard games to 20:00 (plus the
set-piece test). Tables: `docs/ai_fixes_a/bench.md`, `docs/ai_fixes_a/raid.md`; data `docs/ai_fixes_a/data/`.

## In short

- **The Normal Brood**: on today's code it is no longer a level stronger than the other Normal computers. The review's
  benchmark players do about as badly against the Normal Brood as against the Normal Clockwork; the Normal Crown is the
  soft one. A slower Normal pace (as Easy has) was built and measured twice and changed nothing beyond the noise: at
  Normal the Brood is held by its food, not by how often it thinks. **Left OFF** (switch `normalpace:on`).
- **The Clockwork and small raids**: against the Crown, a raid worth less than 30% of the army at home (and under 500) is
  now met by a group worth twice the raid; the rest stays where it was and the next push may still go out. Answers with
  the whole army at more than five times the raid fell from 56 to 10 in 20 games, the results the same. **ON against the
  Crown**, off against the Brood (there it leaned the wrong way) and in the mirror (not measured).

## 1. The Normal Brood

### What was wrong

The opponent review (0.38.107) measured the computers with a human-like benchmark player (scripts/ai_bench_human.gd:
NOVICE, AVERAGE, GOOD strengths) and found the Brood computer a level stronger than the Crown and the Clockwork at every
level; against the Normal Brood the benchmark players won or led 1 game of 9. Easy got two fixes then (a worker cap and
EASY PACE: a warrior egg on every other think); Normal kept its full pace.

### What was built

NORMAL PACE (scripts/ai_brood_new.gd, beside EASY PACE): the Normal Brood skips one warrior-laying think in n (not while a
big attack is at its Mother), skirmish and the tutorial only, as the Easy fix. Switch `normalpace:on` (one in three),
`normalpace:<n>` (one in n), default off.

### What was measured

The review's own benchmark games against the Normal computer, the same tags, maps, seeds and sides (two rounds: every
benchmark faction x strength = 18 games a computer), to 15:00. Read from the benchmark player's side; the mean score is
won 2, led 1, even 0, trailed -1, lost -2, so a LOWER number means a HARDER computer.

| Normal computer | benchmark won or led (of 18) | benchmark lost outright | mean score | computer's army at 8:00 |
|---|---|---|---|---|
| Brood, as it is | 6 | 9 | -0.78 | 1,583 |
| Brood, a warrior on two thinks in three | 5 | 8 | -0.67 | 1,385 |
| Brood, a warrior on every other think | 3 | 9 | -1.11 | 1,616 |
| Crown | 5 | 3 | -0.50 | 1,236 |
| Clockwork | 5 | 8 | -0.72 | 2,229 |

In plain words: the benchmark players now do about as badly against the Normal Brood (-0.78) as against the Normal
Clockwork (-0.72). The gap the review saw has closed since 0.38.107 (its Normal worker cap, the rider squad and the many
AI jobs on all three factions since). The Crown is the gentlest Normal computer: it seldom beats the benchmark outright
(3 of 18) though it leads most games at 15:00.

The pace did not do what was meant. With one think in three skipped the army at 8:00 fell 12% and the score moved 0.11
the benchmark's way; with every other think skipped the army was BIGGER and the score moved 0.33 the other way. Both
are well inside the noise (one game in 18 is worth 0.1-0.2 of the mean; the same game on the same seed flips from a win
to a loss between arms several times). The reason, counted in a traced game: the Normal Brood reaches the warrior egg
37 times in its first seven minutes, about once every 11 s, because it waits for food; a skipped think lays the same egg
one second later. Skipping thinks cannot slow a computer that is waiting on its food. (At Easy the review measured it
working together with the grub cap, which cuts the food.)

So NORMAL PACE stays off. If the owner wants the Normal Brood gentler still (for instance as gentle as the Normal Crown),
the lever is its food: the Normal grub cap (38, `levelgrubs`), not its pace (Claude's choice 2).

## 2. The Clockwork's answer to small raids

### What was wrong

The Clockwork's army at home (scripts/ai_cw_army.gd, `_defend`) has two answers to armed enemies in its base: a TOKEN
raid (worth under 12% of the army, kept between 150 and 300) gets a group, anything bigger the WHOLE army. So 2-3 riders
worth 150-300 turned round an army of 1,500 or more: "the whole army defends the base (18 units, 1,530, with its
Winders) against a raid worth 300". In the 20 Clockwork v Crown games below, 56 of the 191 whole-army answers were to a
raid worth less than a fifth of the army. While the whole army defends, no push goes out (`_army_gate`). Out with the
push, a second rule (ai_cw_push, `_brood_raid_home`, against the Brood) turns the WHOLE push home for any raid of 300 or
more that the units at home do not match.

### What changed

1. **A SMALL RAID GETS A DEFENCE ITS SIZE** (`cwraidsize`): a raid (all its spots together) worth less than SIZED_SHARE
   30% of the army at home and under SIZED_MAX 500 is answered like a token raid: the nearest units worth SIZED_K twice
   the raid (at least GROUP_MIN 3) go to it, the rest stays on its gears. A raid the whole army has already gone to stays
   the whole army's for its last 15 s, as before; 500 or more is a real attack and brings the whole army (the
   clockwork-home rule, test_clockwork_home's 600). The group meeting it is no reason to hold the next push: the push
   goes without it (`_army_gate`, `ai_cw_push._home_army`). Groups are now sized at twice the raid, token raids too
   (they were 1.5 times).
2. **A PART OF THE PUSH GOES HOME** (`cwraidpart`): instead of the whole push, a raid worth under 30% of the push sends
   home only the push's units nearest the raid worth twice it less the guard at home; the rest pushes on.

### What was measured

Hard Clockwork OPTIMAL v the Hard Crown and v the Hard Brood OPTIMAL, 20 games each, to 20:00, on the six parity maps
(qa_matches base rounds 0-3, the same tags and seeds in both arms); off = both rules off, on = both on in every matchup.

| | v Crown off | v Crown on | v Brood off | v Brood on |
|---|---|---|---|---|
| Clockwork won-drawn-lost | 0-12-8 | 0-11-9 | 9-6-5 | 4-13-3 |
| won or led / lost or trailed / even | 0 / 18 / 2 | 2 / 16 / 2 | 11 / 9 / 0 | 7 / 11 / 2 |
| whole-army answers (of them to a raid under a fifth of the army) | 191 (56) | 146 (10) | 105 (15) | 109 (7) |
| group answers | 135 | 172 | 6 | 37 |
| the whole push sent home / a part of it | 0 / 0 | 0 / 0 | 1 / 0 | 3 / 3 |
| paired on the same seeds: better / worse / same | | 6 / 6 / 8 (+0.15, t 0.6) | | 6 / 8 / 6 (-0.45, t -1.0) |

In plain words:
- **Against the Crown** it does what was asked. The whole army now turns round for a handful of riders 10 times in 20
  games instead of 56; the groups go instead. The results are the same within the noise (it still loses this matchup on
  its army, as clockwork-micro found; 2 games led instead of 0, one more lost). ON.
- **Against the Brood** the visible answer changed the same way (7 small-raid whole-army answers instead of 15), but the
  Clockwork won 4 games instead of 9 and led 7 instead of 11 (it was also beaten less: 3 instead of 5). Within the noise
  (t -1.0), but the wrong way, and there is a reason it could be real: the Brood's raids are Raptor streams that grow
  while the group walks, which is exactly why clockwork-home made the whole army answer them (65 Raptors met by groups of
  4, 13, 7 and 6). And the whole push came home MORE often (3 against 1), the part sent home first not being enough.
  So both rules are OFF against the Brood.
- **The mirror** was not measured: off there by the same rule.

The set-piece test `tools/test_cw_raid_size.gd` (a Hard Clockwork, its push held back, the Crown's computer off; five
Horsemen worth 300 ride into its base by a Cog Press and stay there 25 s): with the rule, a group worth 700 of the army's
1,155 (61%) goes and the whole army never does; with `cwraidsize:off`, the whole army defends all 25 s. It passes
with the rule, fails without it.

## The switches

- `normalpace:on` / `normalpace:<n>`: the Normal Brood skips one warrior think in three / in n. Default OFF.
- `cwraidsize:off`: the old answers everywhere (token or whole army). `cwraidsize:on`: the raid-sized defence against
  every faction. Default: against the Crown only.
- `cwraidpart:on`: a part of the push goes home for a small Brood raid. Default OFF.

## The AI tests

Every tools/test_ai_*.gd, test_cw*.gd, test_brood*.gd, test_clockwork_home.gd and test_clockwork_army.gd on the branch
(71): 52 pass, 9 more pass but print "FAILS: 0", which the harness first read as a failure (test_cw_carrier, _lab,
_plate, _rifleman, _scrapper, _siding, _storm, _tesla, _work_car). The 10 real failures are all known: test_ai_wall_vs_rush (Barracks and Mill by 75 s: 100 s),
test_brood_new_defence (rooted muskets), test_cw_militia and test_cw_tier3 (listed as failing on main in CLAUDE.md);
test_cw_heavy, test_brood_fix3, test_brood_spend [supply], test_cw_air and test_cw_couple (save checks), which I ran on
origin/main the same day and which fail there exactly as on the branch. test_brood_v_riders is
flaky: on the branch it passed once and failed once in a row, on main it passed. After the last change (the
raid-sized defence against the Crown only) test_cw_raid_size, test_clockwork_home, test_cw_raid_leash,
test_clockwork_army and test_cw_ai pass.

One SCRIPT ERROR line shows in 10 of the 170 study games, in both arms: "Trying to assign invalid previously freed
instance" at scripts/ai_expand_wall.gd:458 (the Crown's wall), not from this job.

## Claude's choices

1. **What "as well as against the Normal Crown and Clockwork" means**: the mean benchmark score over all three strengths
   and the two rounds, the review's own games. The average player alone (6 games a computer) is too few to read.
2. **NORMAL PACE left off** because it did not work, not because the Brood is fine: the Normal Brood is still the one
   that most often beats the benchmark outright together with the Clockwork (9 and 8 of 18), and the Crown is gentler
   than both. Making Normal mean the same for all three is now mostly about the Crown being soft at Normal, or the
   Brood and the Clockwork both being hard; that is the owner's call (the review's "re-tune Normal" question). The
   lever for the Brood, if wanted, is its Normal grub cap.
3. **The raid size**: under 30% of the army at home and under 500. 500 keeps everything clockwork-home and its test
   call a real attack (600) for the whole army; 30% keeps two groups' worth at home.
4. **The group is twice the raid** (it was 1.5 times for token raids): a group that only just matches riders loses
   units to them; twice ends it.
5. **Against the Crown only.** The Brood result is inside the noise; I kept the rule off there because the earlier
   coaching (clockwork-home) found the whole-army answer right against Raptor streams, and these 20 games lean the same
   way. A longer run (40+ games) would settle it.
6. **The push leaves without the group** (only with the raid-sized defence): before, any defenders out blocked the next
   push. The group stays at its raid (not taken by the push) until it is over and walks back.
7. **The part-of-the-push rule** is kept as an off switch: it fired 3 times in 20 Brood games; too rare to measure alone.
8. **The study kept to the Hard Clockwork OPTIMAL** (the matchups asked for). The Normal Clockwork's benchmark games
   (section 1) were played with the raid-sized defence on against every faction (as in the "on" arm here), so its 12
   games against the Brood and Clockwork benchmark players are a little off today's default; it seldom matters at Normal.

## The tools

- `tools/study/ai_fixes_a.py list|run PART OUT --data DATA [--extra switches]`: `bench:<level>:<faction>` (the review's
  benchmark games against one computer) and `raid:<crown|brood>[:n]` (Hard Clockwork v that faction, 20 games).
- `tools/study/ai_fixes_a_report.py bench DATA...` / `raid OFF ON`: the tables (bench.md, raid.md).
- `tools/test_cw_raid_size.gd`: the set-piece (`cwraidsize:off` shows the old answer).
