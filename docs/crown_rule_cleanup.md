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
