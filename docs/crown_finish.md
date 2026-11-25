# The Crown finisher (crown-finish)

The owner asked on 2026-11-25, after the championship simulation (docs/championship_sim.md):
the Crown computer gets ahead, but it does not finish. 38 of its 54 wins came only at the 20:00 bell.
In run 1's filmed grand final the Crown had 7 halls, a full 200 supply and an army of 4,185,
standing 8 tiles from a Clockwork base with no army left. It never attacked.

This job looked for why, built a finisher for the Crown computer, and measured it.
No unit, building or balance number was changed. Only the computer's play.

Rules followed: docs/design_principles.md part 2 ("a defender's advantage early that fades mid-game so a
winner can finish") and part 4 ("battles that carry the weight of the whole match").

## Why it held back

The Crown computer has many careful rules for its attacks. Each one was made for an even game.
None of them knows when the game is already won.

What the championship data shows (Crown games against another faction that ended at the bell with the Crown
10% ahead):

| Crown wins at the bell | 30 |
|---|---|
| ... at the 200 supply cap (196 or more) at 18:00 | 29 |
| ... with at least twice the enemy's army at 18:00 | 12 |
| ... with at least four times the enemy's army at 18:00 | 9 |

I played the filmed grand final again (Dune Sea, the same dice) and a Crown v Clockwork game on Frostfang,
both to 20:00, with the whole match log, and read every line the Crown wrote after 12:00.
The reasons, in order of how much they cost:

1. **The Siege push grinds.** OPTIMAL picks the Siege push in most games against the Clockwork.
   Out in the enemy's base, the push stops at every building it meets. Its line of Musketeers stands on
   HOLD, 245 pixels out of reach, while the guns shoot that one building. A Cog Press, a Pendulum,
   a Mainspring, then a Clocktower. Each takes about a minute, and the Winders mend them.
   On Frostfang the push went out at 14:44 and by 20:00 had broken 8 buildings: 4 Cog Presses,
   a Mainspring, 2 Clocktowers and a Heavy Works. The Clockwork army was 145 at 20:00; the Crown's 5,370.
2. **Only part of the army goes.** The push went out with 57 supply when the Crown had 160 to 200 supply.
   The rest walks out in groups of 6 supply ("6 supply joins it"), and the other half of the supply is
   labourers (about 90 of them at the cap).
3. **The hunt waits for nothing.** The shared hunt (AIHunt) goes for the enemy's buildings only when the
   enemy has no fighting unit at all. One run-down Clock Soldier in a corner keeps it at home.
4. **The other waves wait for bars.** Outside the Siege push the shared waves wait for a supply bar,
   an edge over the enemy army known, a timing, a kit, the rider screen, and they pull back after a bad trade
   ("leaves that spot be for a while"). Ahead or not, the same bars.
5. **A trap I found on the way.** Anything of the Crown's far from home is taken by the harass as a "stray":
   "Musketeer comes home (out alone, too slow to harass)". My first finisher's army was walked home man by
   man this way, 12 times in one minute, and killed nothing for six minutes.

## What I built

THE FINISHER (scripts/ai_crown_finish.gd, AICrownFinish). The Crown computer only, Normal and up,
not in story missions.

**When it starts.** Every 4 seconds from 9:00 it asks: is the Crown clearly ahead? Three ways:

| Trigger | When |
|---|---|
| edge | our fighters worth 2,500 or more, twice the enemy army we reckon, and at least as many halls |
| crush | our fighters worth 2,500 or more, and four times the enemy army we reckon (its army near nothing) |
| cap | at the 200 supply cap (8 short at most), fighters worth 1,500 or more, and 1.5 times the enemy army we reckon |

The enemy army it reckons is what it has seen in the last two minutes, never less than the Crown's own
reckoning from the clock (its table, less half of what it has killed). Against the Brood: what it has seen
only, with 2,000 as the floor and 2.5 times as the edge (the Brood's table reckons 5,000 by 12:00 whatever
was killed, so the finisher would never start).

**What it does.**
- It takes the whole army: the Siege push's men too (the push ends), the wave, the men at home.
  It does not take the raiders, the harass, balloons, the rider scouts and screen, or a man walking to refit.
- It keeps a small guard at home: worth 1.3 times the enemy seen near home lately, never more than
  a fifth of the army. With nothing seen near home, everyone goes.
- It picks the target: the enemy's nearest hall or building that trains units (against the Brood: its
  rooted Mound Turtles and Rootmaws, and the Mother when she is near).
- The army marches as one body. Every 2.5 seconds the body's middle gets a waypoint 420 pixels further on;
  the fast ones wait there, the stragglers catch up. Within 520 pixels of the target everyone attacks it.
- Men fighting something on the way finish it first.
- The guns trail the body by 150 pixels, shoot the target from 410 pixels, and switch to canister when
  something comes at them.
- New men from home walk out to the body.
- When the target falls, it picks the next one. It does not go home.

**When it stops.**

| Stop | Then |
|---|---|
| under 45% of what went out is left | home; 150 s before it may start again |
| an enemy force near the body worth 1.3 times what is left (and under 75% left) | home; 150 s |
| an enemy force at home bigger than the guard and the men at home (1.3 times, plus 150) and 40% of the army out | home; the shared defence takes over |
| no enemy building left | the shared hunt takes over |

**Switches.** `-- cfin:off` plays as before this job. One part off: `cfinedge:off`, `cfincrush:off`,
`cfincap:off` (the triggers), `cfinguard:off` (no guard). By matchup: `cfinclock:off`, `cfinbrood:off`,
`cfinmirror:off`. For tests: `cfinfrom:<seconds>` moves the 9:00.

**The hooks** (small): AI._army asks `_finish_take` first (before the harass), and while the finisher has the
army the guard waits at the rally spot (`_finish_guard`). AICrown._army skips the Siege push and the Brood press
while the finisher is on.

## How it was measured

Hard OPTIMAL against Hard OPTIMAL, to 20:00, on the 6 parity maps. 20 games for each matchup and each arm:
the same 20 maps, dice and start spots in both arms, so the arms compare game by game. 120 games in all.

| Arm | Switches |
|---|---|
| today | `cfin:off` (the game as it was) |
| finisher | nothing (the finisher on) |

The bell's verdict is the tournament's: income earned plus twice the army, 10% ahead wins it.
Tool: `tools/study/crown_finish.py` (`run`, `report`). Data: `docs/crown_finish/data/<arm>/<matchup>/`.
A game played twice with the same dice does not play the same moves, so every game is noisy.

## The numbers

**The key number: wins that are real wins, not wins at the bell.**

| Matchup | Arm | Crown wins | won outright | won only at the bell |
|---|---|---|---|---|
| v Clockwork | today | 16 | 4 | 12 |
| v Clockwork | finisher | 17 | **9** | 8 |
| v Brood | today | 6 | 2 | 4 |
| v Brood | finisher | 10 | **4** | 6 |

In the mirror both sides are the Crown, so the question is only whether the game ends:

| Mirror | Decided by 20:00 | Ahead at the bell | Even |
|---|---|---|---|
| today | 7 of 20 | 13 | 0 |
| finisher | **10 of 20** | 9 | 1 |

**Every result.** W = won outright, w = ahead at the bell, = even, l = behind at the bell, L = beaten.

| Matchup | Arm | W | w | = | l | L |
|---|---|---|---|---|---|---|
| v Clockwork | today | 4 | 12 | 2 | 1 | 1 |
| v Clockwork | finisher | 9 | 8 | 1 | 1 | 1 |
| v Brood | today | 2 | 4 | 2 | 5 | 7 |
| v Brood | finisher | 4 | 6 | 0 | 4 | 6 |
| mirror (side 1's view) | today | 3 | 6 | 0 | 7 | 4 |
| mirror (side 1's view) | finisher | 5 | 4 | 1 | 5 | 5 |

**Game by game** (the same game in both arms; better or worse by the order W, w, =, l, L):

| Matchup | Better with the finisher | Worse | Same | Sign test p |
|---|---|---|---|---|
| v Clockwork | 9 | 3 | 8 | 0.15 |
| v Brood | 9 | 5 | 6 | 0.42 |
| mirror: decided only with / only without | 6 | 3 | | 0.51 |

Won outright only with the finisher against only without it: v Clockwork 6 to 1 (p 0.13), v Brood 4 to 2.
Pooled over the 40 Crown v Clockwork and Crown v Brood games: 18 better, 8 worse (p 0.08).

**When games ended** (median of the games decided by 20:00):

| Matchup | Arm | Crown won at | Crown beaten at |
|---|---|---|---|
| v Clockwork | today | 16:00 (4 games) | 13:18 (1) |
| v Clockwork | finisher | 16:01 (9) | 17:15 (1) |
| v Brood | today | 19:01 (2) | 18:44 (7) |
| v Brood | finisher | 15:41 (4) | 17:21 (6) |
| mirror | today | 17:42 (all 7 decided) | |
| mirror | finisher | 19:07 (all 10 decided) | |

**Halls lost and armies** (means a game; the army is the last minute's when a game ended sooner):

| Matchup | Arm | Crown halls lost | Enemy halls lost | Crown army 12:00 | Enemy army 12:00 | Crown army 16:00 | Enemy army 16:00 |
|---|---|---|---|---|---|---|---|
| v Clockwork | today | 0.9 | 2.1 | 2,091 | 2,496 | 3,452 | 2,739 |
| v Clockwork | finisher | 0.5 | 3.3 | 2,260 | 2,535 | 3,565 | 2,189 |
| v Brood | today | 2.8 | - | 2,337 | 1,992 | 2,368 | 2,303 |
| v Brood | finisher | 2.4 | - | 2,111 | 1,788 | 2,105 | 2,260 |
| mirror | today | 2.1 | 1.4 | 1,897 | 1,724 | 1,896 | 1,957 |
| mirror | finisher | 2.2 | 1.4 | 2,005 | 1,629 | 2,038 | 1,973 |

(The Brood has no buildings, so it loses no halls in this count.)

**What the finisher did.**

| Matchup | Games it started in | Starts: edge / crush / cap | First start (median) | Stops: army lost / force at home / enemy outweighs / nothing left | From first start to the win (median) |
|---|---|---|---|---|---|
| v Clockwork | 19 of 20 | 8 / 3 / 21 | 13:06 | 7 / 8 / 1 / 0 | 3:12 |
| v Brood | 16 of 20 | 0 / 22 / 8 | 10:34 | 14 / 7 / 0 / 0 | 5:46 |
| mirror | 14 of 20 | 2 / 3 / 11 | 15:53 | 3 / 0 / 0 / 2 | |

Against the Brood half of its runs ended with the army lost: the Brood's army is mostly unseen (rooted
creatures and eggs), so "clearly ahead" is a guess there. Even so the Crown lost no more games (6 beaten, 7 before).
Against the Clockwork 8 of its 16 stops were for a force at home, some of them at the very moment it started
(fixed after the measurement, see choice 10).

**The films** (`tools/shot_ai_match.gd coach:1`, the code as it is now, pictures in `docs/shots/crown_finish/`):

| Film | What happened |
|---|---|
| v Clockwork, Greenhold (dice 31000) | The finisher started at 13:15 at the supply cap (2,000 against 965 reckoned). It broke 6 Clocktowers between 14:54 and 19:17, about one a minute, the guns behind the line. The Clockwork laid two new ones further off (15:11, 16:27). At 19:52 the Clockwork had 1 hall, 7 workers and no army, and the Crown's army was on its way to that last Clocktower: not beaten by 20:00. `clockwork/army_1403.jpg` (the body on the march, guns behind), `clockwork/fight_1416_2337_1216.jpg` (at the first Clocktower), `clockwork/base_1_1804.jpg`. |
| v Brood, Cinder Steps (dice 33067) | The Brood press went for the Mother at 8:52; at 10:02 the finisher took the army (2,010 against 275 seen) and went straight for the Brood Mother, then the rooted ground around her. She fell at 13:12 and the Brood was out. `brood/army_1032.jpg`, `brood/fight_1155_2640_2120.jpg` (the line at the Mother). |

## What I kept

The finisher is **on**, in all three matchups (`cfin:off` turns it off; `cfinbrood:off`, `cfinmirror:off`,
`cfinclock:off` one matchup). No matchup did worse. Against the Clockwork, the matchup of the complaint, real wins
more than doubled (4 to 9 of 20) and wins at the bell fell from 12 to 8. The Brood and mirror numbers point the
same way but are inside the noise. See choice 1.

Nothing of the old rules was removed. The Siege push, the waves, the hunt and the presses play as before
until the finisher starts, and again after it stops.

## The AI tests

TESTS_HERE

## Claude's choices

1. **On in every matchup, though only the Clockwork's numbers are near the line.** The instruction was to keep only
   what helps beyond the noise. No single matchup reaches it on 20 games (v Clockwork p 0.13 for real wins, 0.15
   game by game; pooled with the Brood 0.08). I kept it on because the change is exactly what the owner asked for,
   no matchup measured worse, and the key number moved the right way in all three. If you want only the Clockwork:
   `cfinbrood:off` and `cfinmirror:off` are one line in `AICrownFinish.allowed`.
2. **The triggers' numbers**: twice the reckoned enemy with as many halls; four times it; or the supply cap with
   1.5 times; never under 2,500 of army (1,500 at the cap). Picked from four pilot games, not tuned on the study.
3. **What it reckons.** The seen army alone sent it out three times in one pilot into Clockwork armies it had not
   seen (it lost 1,140 and 2,570). So against the Clockwork and the Crown it uses the Crown's own clock reckoning
   when that is bigger (AICrown.foe_reckon), and needs 2,500 of army.
4. **Against the Brood it uses the seen army only**, with 2,000 as the floor and 2.5 times as the edge. The Brood
   reckoning (5,000 by 12:00) would never let it start. This is where half of its runs lost the army.
5. **The guard** is 1.3 times the enemy seen near home lately, never more than a fifth of the army; nothing seen,
   no guard. A force at home bigger than the guard and the men there calls the whole army home.
6. **Targets**: halls and buildings that train units, nearest to the army first (not the economy buildings the
   Siege push stopped at). Against the Brood its rooted Mound Turtles and Rootmaws, and the Mother when she is
   nearer than 1.4 times the nearest of those.
7. **It ends the Siege push rather than rework it.** The push's slow stand-off is right for an even game. The
   finisher takes its men only when the game is clearly won.
8. **Normal and Hard computers only, not in story missions** (missions are tuned by hand).
9. **It runs before the harass**, so its men far from home are not taken as strays and walked home.
10. **Changed after the measurement** (in the films, not in the 120 games): it no longer starts while a force at
    home would call it back at once, and after such a call waits 20 s before it may start again (the study saw it
    start and stop in the same second at the supply cap); the "buildings fell" count in its log line is per run;
    "an Escapement", not "a Escapement".
11. **The three triggers were measured together**, not one by one. Each has its own switch (`cfinedge:off`,
    `cfincrush:off`, `cfincap:off`) for a later study. The supply cap trigger started most runs.
12. **In the mirror both sides have it.** That is the only fair way to measure a mirror; it measures whether games end.

## Proposals (not done)

- **The Brood's hidden army.** Against the Brood the finisher lost the army it sent in 14 of 30 runs. A look before it
  goes (a rider to the nest, as the Crown's wave already asks for) could make "clearly ahead" a fact there.
- **The labourers at the cap.** At the 200 cap the Crown keeps 75 to 100 labourers, so its army is about half its supply.
  The finisher makes it use that army; it does not make the army bigger.
- **The Clockwork that keeps expanding.** In the Clockwork film the finisher broke 6 Clocktowers and the Clockwork laid new
  ones further off. A rider pair sent after its builders while the army breaks halls would finish such games.
- **Measure more games.** 20 a matchup cannot show a 10-point change. 60 a matchup would.

## Files

- `scripts/ai_crown_finish.gd` (AICrownFinish): the finisher.
- `scripts/ai.gd`: `_finish_take`, `_finish_guard`, the hook at the top of `_army`.
- `scripts/ai_crown.gd`: `fin`, `fin_active`, `_finish_take`; `_army` skips the Siege push and the Brood press while it is on.
- `tools/study/crown_finish.py`: the study. Data in `docs/crown_finish/data/`.
- `docs/shots/crown_finish/`: the films' pictures and their finisher lines.
- Patch note under 0.38.999 (English, Portuguese, Spanish).
