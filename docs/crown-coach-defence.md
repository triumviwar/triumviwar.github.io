# Crown coaching: defending against a push (crown-coach-defence, 0.38.2)

The owner's complaint (2026-11-15 00:28, his watched game on Hollowfen, seed 4287366311, Hard OPTIMAL v Hard OPTIMAL,
v0.38.1; the log is on branch playtest-logs, docs/playtests/2026-11-15_0021_crown_v_clockwork_hollowfen.txt): "Crown made a
balloon but didn't load musketeers on it ... scouted an attack from clockwork, sent musketeers on move command to die to the
attack." This job covers the **defence** part only (four other Crown coaching jobs work on the balloon harass, the army
size, the economy and the Brood matchup at the same time). AI only: no unit, building or economy number was changed.

## What was wrong, in plain words

1. **Men sent past the enemy on a plain MOVE.** In the owner's game the Clockwork's push (8 Clock Soldiers, later 11) left its
   base at 4:27 and reached the Crown's natural at 5:29. The Crown did the right thing with its army at home: it held the
   top of its ramp ("the force below (560) is more than its army at home (180) can beat"). But the three Musketeers of
   balloon party 1 (formed at 4:57) had been walking to the balloon's boarding spot by the main hall for 40 s, the party
   timed out at 5:37 ("too few aboard") and they were stopped wherever they stood, then sent to their posts with a plain
   move. A unit on a move order does not fight; they walked past the Clock Soldiers and died: 4 lost for 0 kills.
   Two holes made this possible:
   - a man walking to board a balloon is on an *errand*: the army's logic, the ramp post and the defence leave him be,
     whatever comes at him;
   - the ramp post, the gate post and the cliff edge (AICrownHold.place / _post) send every man to his spot with a plain
     `cmd_move`, and re-send it every think, with no look at what stands on the way.
2. **Sent in one by one.** When a force came at its buildings that the army at home could not beat (and the ramp post did
   not apply: the enemy was on the main, or at a hall the post does not cover), the shared defence (AI._defend) sent
   *everyone it had*, each from where he stood, on an attack-move: the men arrived one after another and died one after
   another. Red Coast 6203 (before): 51 Crown soldiers died at home, 50 of them where the enemy near them was worth more
   than 1.3 times the Crown's men there.
3. **Surprised at home.** The Crown kept training labourers, the balloon parties kept forming and its waves kept marching
   out while a push came at it; in Red Coast 5103 its wave of 1,450 marched on while 3,185 of Clockwork came at its halls.
   The Crown usually sees a push only when it is 2-4 tiles from its buildings (there was no early look: the Clockwork's
   push in the owner's game was in sight of the Crown's scout once, at 5:22, near the Clockwork's side of the map).

## What changed (scripts/ai_crown_defence.gd, AICrownDefence)

Three parts, each with its own switch; `-- defence:off` turns them all off (that is how every "before" number below was
measured, on the same build).

1. **The alert** (`dfwarn:off`). Every 2 s the Crown weighs the enemy soldiers it has seen in the last 30 s (the ramp post's
   list, AICrownHold._seen): those within 24 tiles of one of its buildings, or within 60 tiles and closing on them (3 tiles
   nearer than when first seen) or on its half of the map. Worth 200 and 60% of its army at home: **the alert** ("sees a
   push coming ... it gets ready"). While it lasts (30 s after the push is last seen coming):
   - soldiers before labourers (AICrown._army_due);
   - no balloon party forms and a party still boarding is called off (its men come under the defence);
   - no wave goes out while the push coming is worth 1.5 times the army at home (AICrown._wave_worth);
   - **the wave comes home**: a wave out and not in a fight, farther from home than the push, while the push is worth 1.5
     times the army at home and half the wave: the wave is called back to meet it at home ("calls its wave home").
   Also, without an alert: a balloon party whose boarding men have an armed enemy within 300 px is called off, and no party
   forms for 30 s ("the enemy is at the men walking to board"). This is the owner's exact case.
2. **No walk past the enemy** (`dfpath:off`). Whenever the ramp post, the gate post, the cliff edge or the muster sends a man
   to his spot (AICrownHold._post calls AICrown.dfn_move), and the straight way passes within an armed enemy's reach plus
   60 px: in reach of an enemy he **fights** (a shooter takes the weakest enemy he can hit: focus fire), else he **steps
   round** them (the step of 220 px, of 12, that keeps out of every enemy's reach and gains the most on the way), boxed in
   he fights his way on. A man fighting far from his post (160 px+) against enemies worth 2.5 times his friends near him,
   with the nearest still 70 px beyond its reach, **gets out** the same way instead of fighting to the death (Hollowfen
   5101: six Musketeers alone at the natural's Barracks died one by one against 1,945 of Clock Soldiers). Guns go where
   they are sent (limbered they cannot fight).
3. **The muster** (`dfmuster:off`). A force of 150+ at its buildings that the army at home cannot beat by 1.2 (and the ramp
   post did not take it: AI._army calls AI._def_hold after AICrownHold.hold_top, before AI._defend): the army gathers at a
   point out of the enemy's reach (the far side of the hall nearest the enemy, of another hall, or where most of the army
   stands, the first with no armed enemy within 420 px, nearest the men; none: the one farthest from them), on HOLD, firing
   at what comes in reach. It **fights as one** (attack together, focus on the weakest enemy in reach) when the enemy
   comes within 330 px of the point or of a gathered man's shot, or once 60% of the army has gathered and is worth as much
   as the force. Men on their way there steer round the enemy (part 2). The other computers keep AI._defend.

The AI STORY tells all of it (scripts/ai_story_lines.gd, texts in en/pt/es in tools/i18n/71_crown_defence.txt).

## The numbers

Measured with a new bench, `tools/crown_defence_bench.gd` (+ `.sh`: a list of games, two at a time, `PROJ=dir` runs them in
a copy of the project), Hard OPTIMAL Crown v Hard OPTIMAL Clockwork, 12:00 games, 16 games (8 maps: Hollowfen with the
owner's seed and two others, Greenhold, Red Coast, Kestrel Rise, Dune Sea, Cinder Steps, Ashford Crossing, Highmoor; the
Crown on both starts). "Home" = within 700 px of a Crown building. "Outmatched" = a Crown soldier who died where the enemy
within 350 px was worth 1.3 times the Crown's men there. "Walking" = died on a plain move order.

| 16 games, totals              | before (`defence:off`) | after   |
|-------------------------------|-----------------------:|--------:|
| Crown soldiers lost at home   | 305                    | 194     |
| ... of them outmatched        | 266 (87%)              | 131 (68%) |
| ... of them walking (a move)  | 44                     | 9       |
| value lost at home            | 22,770                 | 14,000  |
| value killed at home          | 37,610                 | 38,715  |
| home kills per loss           | 1.65                   | 2.77    |
| all kills per loss (value)    | 1.13 (67,430 / 59,620) | 1.51 (73,075 / 48,505) |
| Crown buildings lost          | 126                    | 88      |
| Crown army at 12:00           | 15,710                 | 24,190  |
| Crown income by 12:00         | 174,320                | 162,780 (-6.6%) |
| Clockwork army at 12:00       | 74,085                 | 70,075  |
| W-D-L (Crown)                 | 0-16-0                 | 0-16-0  |

The two halves of the 16 (two seed sets) agree on the direction: home kills per loss 2.27 -> 3.31 and 1.31 -> 2.44, all
kills per loss 1.47 -> 1.69 and 0.90 -> 1.34. Single games swing a lot (one game's big fight at home or not); by start the
Crown on side 2 gained the most (buildings lost 89 -> 35, side 1 37 -> 53).

**What did the work.** A third run, identical except that soldiers came before labourers only while the push coming was
worth more than the army at home (`-- dfsoldiers:behind`), earned 3% less instead of 7% less but lost most of the gain:
269 lost at home (211 outmatched, 14 walking), home kills per loss 1.67, all 1.02, 155 buildings lost, 13,495 of army at
12:00. So the walk and the muster fixes stop the silly deaths (walking deaths 44 -> 9-14 in both runs), but the trade at
home turns because the Crown **has more soldiers when the push lands**. The alerts last 2-7 minutes of a 12-minute game
(the Clockwork's push often stands short of the Crown's main for minutes). The default keeps the whole-alert rule.

**Still wrong.** The first visit of a push is mostly seen 0-12 s before it lands (2-4 tiles from a building): the Crown
has no early look at the road unless it has Horsemen for the rider screen's picket (crown-rider-screen). The results by
12:00 are all draws (the Clockwork earns twice the Crown's income in these games: the economy job's area); the Crown
still loses its natural to a big push (the ramp post holds the top, as the owner's doctrine says).

## Pictures (docs/shots/crown_coach_defence/)

`tools/shot_ai_match.gd`, Hollowfen seed 4287366311 with the Crown on the Balloon harass (the owner's plan): the line on
HOLD at the top of its ramp while the push stands at the natural (after_hollowfen_0632_ramp_top.jpg); at 8:45 the
natural's hall falls to 1,195 of Clockwork while the line shoots from the cliff edge above and the balloon is home
(after_hollowfen_0845_cliff_edge.jpg); before_hollowfen_0632.jpg is the same moment of the game before the change.
Looked at: the line stays on the high ground, no column walks down into the push.

## Tests

- `tools/test_crown_defence.gd` (new): [alert] a push 30 tiles out is seen and the alert is on within 12 s (2.7 s), soldiers
  first and no balloon party; [walk] four Musketeers below the main sent up past eight Clock Soldiers fight or step round
  them and none dies on a move (with the change all four lived and killed seven; with `defence:off` they walk on); [muster]
  12 Clock Soldiers at a Farm on the main: the army musters at the hall, nobody goes to the Farm alone, and they fight
  there. ALL PASS (with `-- defence:off` 6 checks fail, as they should).
- The Crown's AI tests (test_ai_*, test_crown_*, test_cinder_crown*: 40), run with the change: all pass except
  test_ai_rush_followup (14 failed checks; the same 14 fail with `defence:off`: the known Crown v Brood rush tests in
  CLAUDE.md), test_crown_dragoon_raid's [plan] check (fails with `defence:off` too, known) and test_ai_brood's stage-3 timing
  once (passed on its rerun with the change; known to be flaky).

## How to run

    godot --headless --fixed-fps 30 --script res://tools/test_crown_defence.gd
    GODOT=godot PROJ=/copy/of/project tools/crown_defence_bench.sh /abs/out "" < games.list            # after
    GODOT=godot PROJ=/copy/of/project tools/crown_defence_bench.sh /abs/out "defence:off" < games.list # before
    # games.list lines: map seed foe crown_side end, e.g. "hollowfen 4287366311 clockwork 0 720"

Switches: `defence:off` (all), `dfwarn:off` (the alert and its parts), `dfpath:off` (the walk), `dfmuster:off` (the muster),
`dfsoldiers:behind` (soldiers first only while behind), `dfdebug` (prints the muster each think).

## Claude's choices for the owner

1. **Soldiers before labourers for the whole alert** (7% less income by 12:00 for half again the army and a third fewer
   buildings lost). The army-size and economy jobs may want a say; `dfsoldiers:behind` is the cheaper variant.
2. **The muster point** is out of reach on the far side of a hall or where the army stands, not the ramp post: the ramp
   post (AICrownHold) still takes every push below the main first. Should the muster prefer the ramp top when the main
   has one?
3. **A wave comes home** only before a push worth 1.5 times the army at home and half the wave, and only when it is not in
   a fight and farther out than the push. It happened 4 times in 16 games. A Crown that trades bases instead (its wave
   hits the enemy's hall while the push hits ours) is not tried.
4. **Getting out** when hopeless (enemies 2.5 times the friends near him) only applies to a man away from his post; men at
   their post fight it out, as before.
5. **No early look was added.** The alert waits for what the Crown sees. A cheap sentry on the road (a labourer or the
   empty balloon floating over the approach) would give 10-30 s more warning; the balloon is the balloon job's, the riders
   the screen's. Worth a job of its own?
6. **Focus fire** is "the weakest enemy in reach"; pulling back to reload (the job asked for it) was not built: the Musketeer
   reloads for 2.8 s and a Clock Soldier (68) is faster than him (62), so a step back mostly hands it free hits. A test with
   a reload walk-back could prove me wrong.
7. **No cannon** is ordered by the alert (only Musketeers come first): the Foundry plans of the other jobs decide the guns.
