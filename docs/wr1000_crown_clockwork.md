# Win rate 1000, Crown v Clockwork (wr1000-crown-clockwork)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games across six parallel jobs, in blocks
of 10 games, changing ONE thing in a computer's play each block. This job is the Crown v Clockwork pairing: the Crown
computer (Hard OPTIMAL) against the Clockwork computer (Hard OPTIMAL), to 20:00, on the six parity maps of
ai-opponent-review. No number of the game was changed: only how the computers play, and every change has a switch.

## In short

**The fresh win rate (main 0.38.124, 30 baseline games: blocks 1, 6 and 17, the same 10 games three times)**:

| Crown v Clockwork, Hard OPTIMAL v Hard OPTIMAL, at 20:00 | games of 30 |
|---|---|
| the Crown won | 2 |
| the Crown led by 10% or more | 16 |
| even (within 10%) | 5 |
| the Clockwork led by 10% or more | 4 |
| the Clockwork won | 3 |
| **the Crown won or led** | **18 (60%)** |
| **the Clockwork won or led** | **7 (23%)** |
| decided by 20:00 | 5 (17:13, 18:08, 18:27, 18:41, 19:01) |

| the same 30 games, Crown / Clockwork | 8:00 | 12:00 | 14:00 | 20:00 |
|---|---|---|---|---|
| income earned so far (median ratio) | 0.95 | 0.94 | | |
| army value (median ratio) | 1.05 | 0.74 | | |
| score, income + 2 x army (mean ratio) | | | x0.94 | x1.09 |
| halls (mean) | 3.0 / 3.0 | 4.6 / 4.0 | 5.2 / 4.8 | 7.0 / 5.3 |
| workers (mean) | 49 / 42 | 79 / 52 | 85 / 50 | 90 / 40 |
| supply used (mean) | 86 / 75 | 144 / 120 | 168 / 133 | 200 / 109 |
| gold banked (median) | 44 / 125 | 72 / 520 | 36 / 572 | 9,977 / 253 |

Read aloud:

1. **The pairing is close.** The two computers are about even until 14:00 (the score x0.94, the Clockwork a little
   ahead); after that the Crown leads more games than it trails (18 to 7 at 20:00), but the score at 20:00 is only x1.09
   on average, because the games the Clockwork wins it wins big. The Crown won 2 and the Clockwork 3; 25 of 30 ran to the
   bell. On the 2026-11-21 matrix (ai-opponent-review, 11 games) the Crown won or led 7 of 11: the same picture.
2. **The luck between two runs of the same games is large.** The same code on the same 10 games scored +0.19, +0.46 and
   -0.40 (mean g) in its three blocks: the block mean moves by about 0.4 on luck alone, because one game more or less
   ending (a defeat counts the loser's score a quarter) swings that game by +-2.3. Paired game by game, two runs of the
   same game differ by about 1.1 in g and 0.37 in g14. **A block of 10 games can only see a change worth about 0.7 in g
   (or 0.25 in g14)**; nothing tried here was that big.
3. **The late game is the Crown's.** It reaches its 200 supply at 14:00-16:00 with 80-110 labourers (the Clockwork 40-50
   Winders) and banks 5,000-21,000 gold it cannot spend by 20:00; the Clockwork's Winders peak at ~52 at 10:00 and fall to
   ~40 as its presses run dry and the next Clocktower comes late. Its income a minute falls from ~2,300 (12:00-14:00) to
   ~2,000 (18:00-20:00) while the Crown's rises from ~2,800 to ~3,400.
4. **The Clockwork loses about 75-80 Winders a game**: ~19 cut down by the Crown's Horsemen while the Winders group up to
   fight them, ~30-35 mending or walking with the army in the Crown's musket and gun fire. Its pushes into the Crown's line
   and guns lose about two for one (block 1: lost 71,980, killed 39,015 in 42 pushes); the Crown's Siege pushes kill 1.4
   for one and break a Clocktower in most games (15 in 20), then fall back.

**The blocks: 17 blocks, 169 games** (one game of block 8 hung and was cut; ~40 minutes a block, two games at a time on
the 2-core machine). Eleven changes were tried, two of them twice; the baseline was run three times. **None was kept**:
every change stays OFF behind its switch (`-- wcc<name>:on`), and the computers play exactly as on main. Against the
30-game baseline (b01+b06+b17), paired game by game (d = the mean change of g, + is better for the Crown; t; the games
better / worse for the Crown):

| block | the change (switch `wcc<name>:on`) | for | W-w-=-l-L | mean g | g14 | v the baseline: d g (t) · d g14 (t) · Crown better/worse | kept? |
|---|---|---|---|---|---|---|---|
| b01 | the baseline: main 0.38.124, nothing on | - | 1-5-3-0-1 | +0.19 | -0.06 |  | the baseline |
| b02 | **finish**, first version (Crown): it acted in 2 games only (it weighed the army at home, the Siege push's men left out) | Crown | 1-5-2-2-0 | +0.27 | -0.14 | +0.19 (0.7) · -0.08 (-0.8) · 6/2 | the same change, see block 4 |
| b03 | **reckon** (Clockwork): its reckoning of the Crown's army grows past 12:00 as today's Crown does, only recent kills come off it | Clockwork | 0-7-0-3-0 | +0.24 | +0.03 | +0.16 (0.5) · +0.09 (0.9) · 6/4 | no |
| b04 | **finish** (Crown): the Crown hunts the Clockwork's halls while the Clockwork's fighting units are worth under a fifth of its army | Crown | 0-3-4-3-0 | -0.01 | -0.15 | -0.09 (-0.3) · -0.08 (-0.8) · 5/4 | no |
| b05 | **trade** (Clockwork): a push pulls back once it has lost 30% while killing under 0.6 of what it lost | Clockwork | 1-7-1-1-0 | +0.45 | +0.01 | +0.37 (0.9) · +0.08 (0.7) · 5/4 | no |
| b06 | the baseline again (block 1's code): the noise | - | 1-6-1-2-0 | +0.46 | +0.05 |  | the noise |
| b07 | **labs** (Crown): no labourer past 70 | Crown | 1-4-2-3-0 | +0.33 | -0.08 | +0.25 (0.9) · -0.01 (-0.2) · 4/5 | no |
| b08 | **fresh** (Clockwork): a Clocktower counts as fresh only with 40% of its brass left, up to 4 fresh halls (9 games: one hung) | Clockwork | 1-5-2-1-0 | +0.44 | +0.02 | +0.34 (0.7) · +0.10 (0.8) · 3/5 | no |
| b09 | **turret** (Clockwork): a Ratchet Turret by each Clocktower's presses once the Crown's riders are seen | Clockwork | 0-8-2-0-0 | +0.25 | -0.03 | +0.17 (0.6) · +0.04 (0.3) · 5/4 | no |
| b10 | **flee** (Clockwork): the Winders do not group up to fight the riders; they flee | Clockwork | 1-7-2-0-0 | +0.65 | +0.20 | +0.57 (1.4) · +0.27 (1.9) · 5/3 | no (worse) |
| b11 | **mend** (Clockwork): the army's escort Winders mend nothing in reach of a Crown shooter | Clockwork | 0-9-0-0-1 | +0.06 | -0.10 | -0.02 (-0.1) · -0.03 (-0.4) · 6/2 | no (b11+b14: -0.02) |
| b12 | **decoy** (Clockwork): the Springer raid's diversion is not filled again once it went back | Clockwork | 1-7-1-1-0 | +0.54 | +0.08 | +0.45 (1.8) · +0.15 (1.4) · 8/1 | no |
| b13 | **cwpick** (Clockwork): OPTIMAL plays Balanced or Economy against the Crown (no Springer timing), Economy on a late GREEDY read | Clockwork | 0-6-1-3-0 | +0.03 | -0.14 | -0.05 (-0.2) · -0.07 (-0.7) · 3/4 | no (b13+b16: +0.12) |
| b14 | **mend** again | Clockwork | 1-5-1-2-1 | +0.07 | -0.04 | -0.01 (-0.0) · +0.03 (0.3) · 6/3 | no |
| b15 | **escort** (Clockwork): one escort Winder for every 8 constructs, at most 6 (5 and 10) | Clockwork | 2-6-1-1-0 | +0.70 | +0.07 | +0.61 (1.4) · +0.14 (1.4) · 4/3 | no (worse) |
| b16 | **cwpick** again | Clockwork | 0-8-1-1-0 | +0.38 | -0.03 | +0.30 (1.3) · +0.03 (0.5) · 7/3 | no |
| b17 | the baseline a third time | - | 0-5-1-2-2 | -0.40 | -0.19 |  | the pool b01+b06+b17 |

What each one did (how often it acted, and what moved):

- **finish** (Crown, `wccfinish:on`): AIHunt hunts only an enemy with no fighting unit left; here the Crown hunts the
  Clockwork's halls when the Clockwork's army is under a fifth of its own. It acted in 2 games of 10 (65 looks): the
  Clockwork is seldom that far down, and the 20:00 bell came first. No extra win.
- **reckon** (Clockwork, `wccreckon:on`): its reckoning of the Crown's army grew from ~1,000 to ~1,750 for the pushes after
  11:00, but the pushes still went out (they were worth ~4,300) and traded the same (0.57 killed a lost).
- **trade** (Clockwork, `wcctrade:on`): the pushes lost less (49,440 against ~70,000 a block) but killed less too; the
  trade stayed at 0.61.
- **labs** (Crown, `wcclabs:on`): its labourers held at ~70 (88-90 at 16:00 before), its bank at 20:00 halved, its army at
  16:00 no bigger (3,484 against 3,231-3,982).
- **fresh** (Clockwork, `wccfresh:on`): more Clocktowers (5.6 at 16:00, 5.0-5.3 before) and a little more income at 20:00
  (39,170 against ~37,000), but fewer Winders (40 against 44-49): the new halls' presses wait for Winders that die.
- **turret** (Clockwork, `wccturret:on`): ~5 turrets a game by the presses; the Winders lost went from ~80 to 76.
- **flee** (Clockwork, `wccflee:on`): the Winders no longer fight the riders, and die running instead (88 a game, more
  than before): the round-5 rule that groups them up is the better one.
- **mend** (Clockwork, `wccmend:on`): the Winders lost mending fell (12 against 15-23 a game), the pushes traded better
  (0.67 and 0.84 killed a lost, 0.54-0.58 before), but the score did not move once the third baseline run came in.
- **decoy** (Clockwork, `wccdecoy:on`): a real bug, fixed behind the switch: the Springer raid's diversion "goes back to the
  army" 39-410 times a game (four Clock Soldiers walking to and fro between the army and the enemy's ramp) when the raid
  never leapt; with the fix it goes back once. It acted in 3 games; the score was no better.
- **cwpick** (Clockwork, `wcccwpick:on`): OPTIMAL played Balanced or Economy in every game (the Springer timing in 3-5 games of
  10 before); first block -0.05, second +0.30.
- **escort** (Clockwork, `wccescort:on`): fewer escort Winders left the pushes unmended: they traded worse (0.46).

## Claude's choices (for the owner)

1. **Nothing kept.** The rule was "clearly better than the baseline, beyond the noise". The third baseline run (block 17,
   -0.40 with the same code that scored +0.19 and +0.46) showed the noise is bigger than any change measured, so every
   change stays off. `mend` and `cwpick` leaned the Clockwork's way in their first block and did not in their second.
2. **Which side to coach**: the Crown led the baseline, so 9 of the 11 changes were the Clockwork's (the side that played
   the more visible mistakes: walking Winders into the Crown's fire, pushes into its guns, the diversion loop). The Crown's
   two (`finish`, `labs`) went after its unspent bank and its unfinished games.
3. **The same 10 games every block** (the six parity maps; the first four twice, the spots swapped), as crown-1000 did, so
   blocks compare game by game. The seeds 9400 + 97 k are this job's own: plan_matrix's seeds use other maps.
4. **Block 2 counts as a baseline run for 8 of its games** (its first `finish` acted in 2): it is in the table but not in
   the pool.
5. **The `decoy` bug fix is left off too** (the rule is the rule). It is a plain bug (a loop that steals and returns four
   Clock Soldiers every think): the owner may want it on whatever the score: `AIWccr.KEPT["decoy"] = true`.
6. **The hung game** (block 8, Dune Sea round 1, with `fresh`): it ran 40 minutes of CPU (a game usually takes 9-18) and
   was cut; not looked into (it may be the change or a long late game).
7. 170 games, as asked ("about 17 blocks"). Block 7 was started over twice: the first two versions of `labs` capped the
   labourers only on some plans and in some of the Crown's training paths (its games were thrown away).

## Proposals

- **Measure with more games, or the steadier g14.** For this pairing a 10-game block can only see changes worth ~0.7 in g.
  To judge a change worth 0.3 needs about 50 games a side; or judge on g14 (the score at 14:00), whose block noise is ~0.12.
- **The Clockwork's Winders** are its weakness here (75-80 lost a game). The trial of running away was worse; what may
  work is soldiers at the presses BEFORE the riders come (the round-5 guards come after), or Netters posted with the
  Winders (a Netter "caught" a Horseman in many games). Not tried.
- **The Crown's bank at the supply cap** (5,000-21,000 by 20:00): its labourers are half its supply. A labourer cap made no
  difference; a real sink (the owner said NO cog/gold sink, 2026-11-13) is not proposed, but the Crown computer could
  trade its army harder at the cap (its Siege push falls back at 45% of what went out even when it is far ahead).
- **Balance (a number, the owner's call):** the Crown researches its 9 upgrades by about 15:00 (armour, three muskets, bayonet,
  pouch, charges, quadrant, the charge); the Clockwork has 4 to research, none that makes its soldiers hit harder or last
  longer. That may be why the late game is the Crown's. No number was changed.

## What is still wrong

- Few games end: 5 of 30 baseline games by 20:00. The leader at the bell is usually not able to finish.
- The Crown's AI STORY says "is at the supply cap or far ahead: it attacks again" up to seven times in six seconds on the
  Siege plan, where the shared waves never go (AI._army's push line fires but the Siege plan holds its waves): a wrong line.
- The Clockwork's pushes into the Crown's line and guns lose two for one, and its Winders die in the Crown's fire.
- Cinder Steps round 0 is lost by the Crown in 2 of 3 baseline runs (the natural falls), as crown-1000-clockwork found.

## The AI tests (the branch, every change off: the computers play as on main)

`tools/study/run_ai_tests.sh` (23 tests, `docs/wr1000_crown_clockwork/ai_tests_branch.txt`) and tools/test_crown_v_clock.gd
(ALL PASS). 17 pass. Six failed once; each was run again on main and on the branch
(`docs/wr1000_crown_clockwork/ai_tests_reruns.txt`):

| test | branch (first run) | main (rerun) | branch (rerun) |
|---|---|---|---|
| test_ai_brood | FAIL (stage 3 by 620 s: never) | FAIL | FAIL |
| test_ai_rush_followup | FAIL (known, CLAUDE.md) | FAIL | FAIL |
| test_ai_wall_vs_rush | FAIL (known: Barracks and Mill by 75 s: 58, 100 s) | FAIL | FAIL |
| test_ai_rush | FAIL (the rush killed grubs) | PASS | PASS |
| test_ai_scout_sentry | FAIL (0 flees) | PASS | PASS |
| test_ai_worker_safety | FAIL (two brutes) | PASS | PASS |

The same three fail on main and on the branch; the other three are flaky (CLAUDE.md lists test_ai_rush, test_ai_scout_sentry
and test_ai_worker_safety as such) and passed on the rerun. None is Crown v Clockwork, where alone this job's changes could
act (every one is gated to that pairing: `AIWccr.vs`).

## How it is measured


- **The 10 games**: the six parity maps (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps), game k
  on map k mod 6, the first four maps twice; the start spots swapped every other game and on a map's second game, so each
  side plays both spots. The seeds are 9400 + 97 k. The same 10 games every block, so blocks compare game by game:
  `python3 tools/study/wr1000_crown_clockwork.py run BLOCK --extra SWITCHES` (two games at a time on the 2-core machine,
  about 40 minutes a block; `tools/study/wr1000_crown_clockwork_queue.sh` runs a queue of blocks, each on a frozen copy of
  the committed code).
- **A game's score** (the Crown's view): g = ln(the Crown's (income earned + 2 x army) / the Clockwork's) at 20:00 or at the
  defeat, the beaten side's score counted a quarter (plan_matrix_report's rule). Positive: the Crown ahead; +0.10 = 10% ahead.
- **Results**: W = the Crown won, w = it led by 10% or more at 20:00, = within 10%, l = the Clockwork led, L = the Clockwork won.
- **g14**: the same score ratio at 14:00, before most of the late swings: a steadier second measure.
- **The noise**: blocks 6 and 17 reran block 1's code: mean g +0.19, +0.46, -0.40; g14 -0.06, +0.05, -0.19 (a match is not
  deterministic: the same seed plays another game). Every block is weighed against the pool of the three (each game the
  mean of its three runs, "b01+b06+b17"), paired game by game: d = the mean difference of g (its t), and the games better /
  worse by more than 0.05. While the blocks ran, the pool was b01+b06 and a change would have been KEPT with d of 0.35 or
  more in its side's favour, t of 1.5 or more and g14 the same way, then a second block; none came near once the third
  baseline run was in.
- **Which side a change helps**: a change of the Crown's play is good when g goes UP; a change of the Clockwork's play is
  good when g goes DOWN.
- Data: `docs/wr1000_crown_clockwork/data/<block>/<game>/` (result.json, story.txt, planlog.txt = the Crown's plan lines,
  cwlog.txt = the Clockwork's own log lines; base.txt = the block it was weighed against); `blocks.csv` one row a block.
  Readers: `tools/study/wr1000_cw_pushes.py` (the Clockwork's pushes: lost and killed), `tools/study/wr1000_winders.py`
  (the Winders lost and to what). The whole match logs were kept outside the repo (they are big).

## Files

- `scripts/ai_wr1000_crown_clockwork.gd` (AIWccr: every change, its switch, `KEPT` empty, `vs` the pairing gate, the
  counters in result.json "wcc"), with one-line hooks in `scripts/ai.gd` (fresh, turret, mend, escort), `scripts/ai_crown.gd`
  (finish, labs), `scripts/ai_crown_coach.gd` (labs), `scripts/ai_cw_army.gd` (reckon), `scripts/ai_cw_push.gd` (trade),
  `scripts/ai_round5.gd` (flee), `scripts/ai_springer_raid.gd` (decoy), `scripts/ai_optimal.gd` (cwpick).
- `tools/qa_match.gd`: result.json "wcc" (how often each change acted, a side each).
- `tools/study/wr1000_crown_clockwork.py` (list / run / report / csv), `wr1000_crown_clockwork_queue.sh`,
  `wr1000_cw_pushes.py`, `wr1000_winders.py`.
- Data: `docs/wr1000_crown_clockwork/data/` (17 blocks, 169 games), `blocks.csv`, the AI test results.
