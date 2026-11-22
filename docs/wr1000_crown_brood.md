# Win rate 1000 over 10s: the Crown v the Brood (wr1000-crown-brood)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games across six parallel jobs, in
blocks of 10 games, changing ONE thing in the computer's play each block. This job is the Crown v the Brood: Hard OPTIMAL
v Hard OPTIMAL, games to 20:00, on the six parity maps of ai-opponent-review, the same 10 map + seed games every block.
No balance number was changed: every change is in the computers' play, against the Brood only, behind a switch.

## Summary

**The fresh baseline (main 0.38.124, 20 games: blocks 1 and 3):**

| Crown v Brood at 20:00, Hard OPTIMAL v Hard OPTIMAL | games | share |
|---|---|---|
| Crown won (the Brood beaten) | 0 | 0% |
| Crown led (10% or more ahead on income + 2 x army) | 2 | 10% |
| even (within 10%) | 2 | 10% |
| Crown behind | 9 | 45% |
| Crown lost (beaten) | 7 | 35% |
| Brood won or led | 16 | 80% |

| baseline numbers (Crown / Brood) | block 1 | block 3 (the same code again) | both |
|---|---|---|---|
| mean g (ln of the score ratio, a beaten side a quarter) | -0.90 | -1.02 | -0.96 |
| g at 14:00 | -0.06 | -0.07 | -0.07 |
| income at 8:00 / 12:00 | 1.43 / 1.04 | 1.41 / 1.06 | 1.42 / 1.05 |
| army at 8:00 / 12:00 | 3.02 / 1.24 | 3.02 / 1.94 | 3.02 / 1.59 |
| Crown halls at 12:00 | 3.7 | 3.7 | 3.7 |
| defeats (minute) | 17.7, 17.8, 18.9 | 17.4, 17.8, 18.1, 18.3 | median 17:56 |

The story of nearly every game: the Crown's Horseman rush and its army lead it to 8:00 (3 times the Brood's army, 1.4
times its income earned), the Brood out-earns it from 9:00-10:00 in most games (in both of minutes 10-12 in 12 of 20:
2,000-3,000 food a minute against the Crown's 1,100-1,900 gold), reaches its 200 supply at 13:00-15:00, and its capped waves take the Crown's outlying halls one by one
at 14:00-19:00 (the Crown's labourers die in their hundreds there: 1,098 in 20 games, 1,000 of them after 12:00).

**Every block** (each against the pooled baseline b01+b03, game by game; d = the paired mean difference of g, t its t value;
better/worse = games whose g moved more than 0.05):

| block | the change (switches on) | won / led / even / behind / lost | mean g | g14 | v baseline: d g (t) · d g14 (t) · better/worse | kept? |
|---|---|---|---|---|---|---|
| b01 | the baseline, main 0.38.124 | 0 / 0 / 2 / 5 / 3 | -0.90 | -0.06 | | the baseline |
| b02 | **arm**: the Armoury and its research go once the army is 1.5 times the Brood army SEEN (not the clock's reckoning) | 0 / 0 / 0 / 4 / 6 | -1.55 | -0.19 | -0.59 (-1.9) · -0.12 (-1.5) · 2/7 | no: the research came (11:00-16:00) and the army paid for it |
| b03 | the baseline again: the noise | 0 / 2 / 0 / 4 / 4 | -1.02 | -0.07 | -0.12 (-0.3) v b01 | the pool b01+b03 |
| b04 | **cap**: the Siege push goes only with 110 supply at home (or the supply full) | 1 / 0 / 4 / 1 / 4 | -0.82 | -0.08 | +0.14 (0.2) · -0.01 (-0.1) · 5/5 | no (not clear; see b14, b16) |
| b05 | **counter**: within 45 s of a Brood wave beaten at our buildings, with 2 times the Brood army seen and 40 supply, the push goes at once | 0 / 4 / 1 / 2 / 3 | -0.64 | +0.02 | +0.32 (0.7) · +0.09 (0.6) · 5/5 | run again (b08) |
| b06 | c1kbmaws (crown-1000-brood's off switch): the push marches on the far Rootmaws | 0 / 0 / 0 / 4 / 6 | -1.46 | -0.14 | -0.50 (-1.0) · -0.08 (-0.8) · 4/6 | no |
| b07 | **home**: the push comes home when the Brood at our buildings outweighs what is at home WITHOUT the push | 0 / 1 / 2 / 4 / 3 | -0.82 | -0.01 | +0.14 (0.3) · +0.06 (0.5) · 6/4 | no (not clear) |
| b08 | **counter** again | 1 / 1 / 1 / 3 / 4 | -0.75 | -0.03 | +0.20 (0.3) · +0.04 (0.2) · 6/4 | no: the pool b05+b08 +0.26 (0.5) · +0.06 (0.4) · 4/4 |
| b09 | **counterw**: counter wider (90 s, 1.5 times, 30 supply) | 0 / 3 / 0 / 3 / 4 | -0.72 | +0.14 | +0.24 (0.5) · +0.20 (1.4) · 6/4 | run again (b11) |
| b10 | c1kbpester (crown-1000-brood's off switch): the riders raid the grubs again after the rush | 0 / 3 / 0 / 2 / 5 | -1.02 | -0.11 | -0.06 (-0.1) · -0.04 (-0.3) · 4/6 | no |
| b11 | **counterw** again | 0 / 3 / 1 / 2 / 4 | -0.91 | -0.05 | +0.04 (0.1) · +0.01 (0.1) · 5/5 | no: the pool b09+b11 +0.14 (0.3) · +0.11 (0.8) |
| b12 | **labs**: the labourers are not held for the army (army_grows, army_behind) while the army is 2 times the Brood army seen | 0 / 1 / 3 / 3 / 3 | -0.91 | -0.06 | +0.05 (0.1) · +0.01 (0.1) · 5/5 | no: the labourers' count hardly moved |
| b13 | counterw + home | 0 / 2 / 1 / 2 / 5 | -1.00 | +0.02 | -0.04 (-0.1) · +0.09 (0.6) · 5/3 | no |
| b14 | cap + counterw + home | 1 / 2 / 1 / 4 / 2 | -0.22 | +0.09 | +0.74 (1.3) · +0.16 (1.0) · 6/4 | run again (b16): the best block, but it is cap at work (counterw and home acted 1 time each) |
| b15 | **evac**: the labourers walk away from a hall the Brood comes to, back when it is gone | 0 / 0 / 1 / 4 / 5 | -1.31 | -0.21 | -0.36 (-0.8) · -0.14 (-1.2) · 4/6 | no: 1,250 labourers sent walking, 650 lost (540-558 in a baseline block) |
| b16 | cap + counterw + home again | 0 / 0 / 1 / 5 / 4 | -1.19 | -0.24 | -0.24 (-0.7) · -0.17 (-2.1) · 5/5 | **no**: b14 was noise (the pool b14+b16 +0.25 (0.7) · -0.01 (-0.1)); no siege push and no wave in any of its 10 games |
| b17 | **capmid**: the push goes at 80 supply (110 in cap) | 0 / 1 / 2 / 4 / 3 | -0.84 | +0.07 | +0.11 (0.3) · +0.14 (1.4) · 4/5 | no (not clear; still no attack at all in 6 games of 10) |

**Nothing was kept**: 17 blocks, 170 games, 8 changes of this job and 2 older switches measured again; no change beat the
baseline clearly in two blocks, so `AIWr1000CrownBrood.KEPT` is empty and the game plays exactly as main 0.38.124. Every
change stays behind its switch. The nearest were the push held for a big army (`cap`: four blocks with it, +0.14, +0.74,
-0.24 and, as `capmid`, +0.11: the army at 12:00 2.8 times the Brood's against 1.6, but the Crown then attacks in only half
the games and loses the same way) and the counter-attack after a beaten wave (`counter`, `counterw`: four blocks, +0.32,
+0.20, +0.24, +0.04; it fired 0-2 times a game). With 10 games a block one game won or lost moves the mean g by 0.2-0.4,
and two runs of the same code (b01, b03; b14, b16) differed by 0.1 and 0.9.

| pooled (20-30 games each) | games | won / led / even / behind / lost | mean g | g14 | v baseline d g (t) |
|---|---|---|---|---|---|
| the baseline b01+b03 | 20 | 0 / 2 / 2 / 9 / 7 | -0.96 | -0.07 | |
| counter b05+b08 | 20 | 1 / 5 / 2 / 5 / 7 | -0.70 | -0.01 | +0.26 (0.5) |
| counterw b09+b11 | 20 | 0 / 6 / 1 / 5 / 8 | -0.82 | +0.04 | +0.14 (0.3) |
| cap (b04, b14, b16) | 30 | 2 / 2 / 6 / 10 / 10 | -0.75 | -0.07 | +0.22 (0.6) |

## How it is measured

- **The 10 games**: the six parity maps (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps), round 0
  on all six and round 1 (the start spots swapped) on the first four: 5 games on each start spot. Seeds 4100 + 97 r + 11 map
  + 3 (fresh, not the matrix's). Hard OPTIMAL v Hard OPTIMAL to 20:00. The same 10 every block:
  `python3 tools/study/wr1000_crown_brood.py run <block> --extra <switches>`; each block played on a frozen copy of the
  code at its commit (tools/study/freeze_copy.sh), two games at a time on the 2-core machine, 45-55 minutes a block.
- **A game's score**: g = ln((income earned + 2 x army) of the Crown / of the Brood) at 20:00 or the defeat, the beaten side
  counted a quarter (crown-1000-brood's rule). Won = the Brood beaten; led = 10% or more ahead at 20:00; even = within 10%;
  behind; lost = the Crown beaten. g14 = the score ratio at 14:00 (the last minute of a side beaten sooner), steadier.
- **The noise**: block 3 reran block 1's code: mean g -1.02 against -0.90 (the per-game swings are far larger: a game is
  won or lost by a single fight, g moves by 2 when it is). So every block is weighed game by game against the pooled
  baseline b01+b03 (each game's numbers the mean of its two runs), and a change is kept only with a mean g up 0.3 or more
  AND g14 up clearly (t 1.5 or more) or more games better than worse, confirmed by a second block, and not worse to watch.
- **Switches**: every change is `-- wcb<name>:on` (scripts/ai_wr1000_crown_brood.gd, AIWr1000CrownBrood); the kept ones are
  on by default (KEPT); `-- wcb:off` plays as before the job. Every change acts only for a Crown computer facing a Brood.
- `python3 tools/study/wr1000_crown_brood.py results b01+b03 b14 ...` prints the won/led/even/behind/lost table,
  `... report --base b01+b03 b14 --games` the paired comparison and each game.
- Data: `docs/wr1000_crown_brood/data/<block>/` (result.json, story.txt, planlog.txt = the Crown's plan lines, extra.txt = the
  block's switches).

## What the games showed

1. **The clock's reckoning of the Brood still holds the Crown back while it is far ahead.** AICrown.foe_estimate weighs
   the Brood by BROOD_TABLE (3,800 at 10:00) whatever was seen: "milestone Armoury waits: the army comes first (1800 against
   the 2842 of Brood it estimates)" with the Crown's army 3 times the Brood's (Cinder Steps r0, block 1, 8:53); the Armoury
   came at 13:00 or never, and in 5 of the 10 games of block 1 the Crown researched nothing but the Cavalry Charge. Freeing
   the Armoury and its research (`arm`) or the labourers (`labs`) from it did not pay: the research came at 11:00-16:00 and
   cost the army, and the labourers' count hardly moved (the Farm posts were nearly full: 2 Farms a hall is the limit).
2. **The Siege push goes out small and is beaten on the rooted ground.** BIG_GO (50 supply) lets a push of 32-53 supply go
   at 9:30-11:30; it sets up against Rootmaws and Mound Turtles, loses 1,100-5,300 of army for 400-4,000 killed, and the
   Brood's next wave (60-100 supply) reaches the Crown's halls while it is out (Hollowfen r0 block 5: the push out at 10:13,
   the Brood's 82 supply at the Crown's base at 10:54, the natural lost at 11:46, the push fell back at 11:51). Holding it
   to a big army (`cap`) kept the army: army at 12:00 2.96 and 3.70 of the Brood's (1.59 in the baseline).
3. **The siege push's "base attacked" rule counts the push itself as home** (AICrownHold.home_value has no idea of the
   push's men): `home` fixed it for the Brood; it fired 1-2 times a game, 6 games better and 4 worse.
4. **The Brood out-earns the Crown from 9:00-10:00 in most games**, at even halls (3.7 to 4 grounds): the Crown's 2 Farms
   a hall pay ~1,140 a minute a hall at most and it works ~30 of its 45-65 labourers on Farms; the Brood's grubs and Rootmaws
   pay more. Its capped army (200 supply, 3,300-4,000 of value with 60-130 Raptors) then decides.
5. **The Crown loses ~50 labourers a game, most after 12:00**, to the capped waves at its outlying halls. Walking them away
   early (`evac`) cost more than it saved: they left the Farms for a minute at every wave and still died at the next hall.

## Claude's choices for the owner

1. **The games**: the six parity maps with fresh seeds, 10 games a block (6 maps round 0 + 4 maps round 1) rather than 12,
   so a block takes under an hour; 5 games on each start spot.
2. **Two crown-1000-brood switches were measured again** on today's main (`c1kbmaws`, `c1kbpester`, blocks 6 and 10): the
   code changed a lot since 0.38.82 (the rule cleanup, the mill crew, the AI review). Both stayed worse or even.
3. **`cap` is not kept although its blocks were the best**: its four blocks were +0.14, +0.74, -0.24 and +0.11 (capmid), within the noise,
   and with it the Crown sends no attack at all in about half the games (none in block 16): the turtling the owner
   does not want. It stays behind `wcbcap:on` / `wcbcapmid:on`.
4. `counter`, `counterw`, `home` and `cap` share the push's code: with `cap` on, a counter-attack also needs the big army
   (cap's wait comes first), so in b14/b16 the counter fired 0-1 times.
5. Every change acts only for a Crown computer facing a Brood (the sister jobs change the same files): the hooks in the
   shared files are one line each (scripts/ai_crown.gd 4, scripts/ai_crown_siege.gd 3, scripts/ai.gd 1, tools/qa_match.gd 1).
6. No film was made: the stories, plan lines, counters and the deaths list stand in for them (a film costs hours of this
   machine; the blocks took the time).

## Proposals (not done: balance numbers, the owner's call)

1. **The Crown's economy against the Brood's from 9:00** (finding 4): the Brood out-earns it in most games at even bases.
   Either the Crown's Farm (380 a harvest, 2 a hall) or the Brood's Rootmaw income could be looked at; the earlier jobs
   (crown-1000-brood, crown-rule-cleanup) came to the same place: balance more than AI.
2. **BROOD_TABLE** (the clock's reckoning of an unseen Brood army) holds back the Crown's tech and labourers in most games
   even with the Brood army seen at a third of the Crown's. A softer table (or a shorter memory for it once the Brood army
   has been seen) is an AI number, not balance, but freeing it piecemeal (`arm`, `labs`) did not pay; it wants a study of its
   own.
3. **The Siege push's BIG_GO (50 supply) against the Brood**: the small pushes trade at a loss on the rooted ground.
   `capmid` (80) is the gentler form to try further if the owner wants the push held.

## What is still wrong

- The Crown computer still loses this matchup: 0 wins in the 20 baseline games and the Brood ahead in 16 of 20 at 20:00.
  Nothing tried here moved that beyond the noise in two blocks.
- With the push held (`cap`) the Crown attacks in only half the games: passive to watch.
- The Crown's 50 labourers lost a game to the late waves (the outlying halls fall while the army stands at another).
- The Crown computer's research comes late or never against the Brood (the reckoning, finding 1).

## The tests

All 23 `tools/test_ai_*.gd` were run (tools/study/run_ai_tests.sh) on frozen copies of main 0.38.124 (before) and of this
branch (after, every change off by default as kept): `docs/wr1000_crown_brood/ai_tests_before.txt`, `ai_tests_after.txt`.
**Before**: 22 pass, `test_ai_wall_vs_rush` fails (Barracks and Powder Mill by 75 s: 58 s, 100 s; it failed on main before
this job too, ai-opponent-review). **After**: the same failure, and two more in the first run that pass on a rerun:
`test_ai_harass` ([raid], failed twice, then passed; it also passes twice on the before copy) and `test_ai_worker_safety`
(passed on the rerun); both are listed as flaky in CLAUDE.md. `test_ai_rush_followup`, which failed in ai-opponent-review's
runs, passed both times here. With every change off the job's hooks return at their first line (the switch), so no test can
see them.

## Files

- `scripts/ai_wr1000_crown_brood.gd` (AIWr1000CrownBrood: the switches, KEPT, every change and its counters); the hooks:
  `scripts/ai_crown.gd` (arm: _mid_ok_lagging and _research; labs: army_grows and army_behind),
  `scripts/ai_crown_siege.gd` (cap, counter, counterw, capmid: _maybe_go; home: _lost), `scripts/ai.gd` (evac: after
  _worker_safety), `tools/qa_match.gd` (the counters in result.json "crown_ai": wcb_*).
- `tools/study/wr1000_crown_brood.py` (run / report / results / csv).
- Data: `docs/wr1000_crown_brood/data/<block>/` (170 games).
