# The computer opponent, reviewed (ai-opponent-review, 2026-11-21)

Written to be listened to. Tables are in `docs/ai_opponent_review/tables.md`; the games in `docs/ai_opponent_review/data/`;
pictures in `docs/shots/ai_opponent_review/`.

Why: the game was graded B minus, and the COMPUTER OPPONENT got a C ("it works, but it's weak and uneven, and it's the thing
most players will meet first"). Balance could not be graded at all, because almost everything was measured computer against
computer. This job does three things: a fresh win-rate matrix on today's main, a yardstick that plays like an ordinary
person (to say where each computer level sits), and a hunt for the computer's visible blunders, fixing the clear ones.

No balance number was changed. Every change is in how the computer plays, and each one has an off switch.

## In short

{SHORT}

## 1. The matrix: the Hard OPTIMAL computer against itself, all nine matchups, to 20:00

{MATRIX}

## 2. Where each computer level sits: the human-like benchmark player

### What the benchmark player is

A new measuring tool (`scripts/ai_bench_human.gd`, class BenchHuman), used only by the study tool, never in a real match.
It plays each faction's Balanced plan, a standard build, with the Hard computer's knowledge of how to build. What makes it
"human" is a person's limits:

- It looks at the game only every so often: about every 1.5 seconds for the NOVICE, 1 second for the AVERAGE player and
  0.6 seconds for the GOOD player, with some jitter. The Hard computer thinks every 0.4 to 0.7 seconds.
- Each look it manages ONE place: either its economy and production at home, or its army. It looks at its army about a
  quarter to a third of the time, and always once it has NOTICED an attack on its base. Noticing takes 6 seconds for the
  novice, 3 for the average player and about 1 for the good one.
- It forgets: on some looks at home it makes no workers (novice 35% of the time, average 15%, good 5%) or no soldiers
  (the same shares). Its workers stop at 24 (novice), 36 (average) or 48 (good).
- No perfect micro: none of the Hard computer's focus fire, kiting or pulling back hurt units, and no rider hit and run.
  The novice uses no special abilities; only the good player hunts an enemy scout in its base.
- It attacks when its plan says it has a decent army.

What it is not: a person. It shares the computer's own build logic, so it shares its blind spots, and it never baits the
computer or learns its habits. A real person who does those things will do better than these numbers. Treat it as a
ruler, not as the owner.

Does the ruler work? Played against each other (9 games, faction against faction), the stronger benchmark player won or
led 6 of 9 and lost or trailed 2. In the tables below the stronger players do better against every level, and every
player does worse as the level goes up. So the ruler orders things the right way.

### How it was measured

Each benchmark faction, at each strength, played each computer faction at Easy, Normal and Hard (the computer on its
OPTIMAL plan): 81 games, one per cell, to 15:00, on six maps of all kinds (Greenhold, Dune Sea, Frostfang, Ashford
Crossing, Hollowfen, Cinder Steps), sides alternating. A game not ended by 15:00 is "led" by the side 10% ahead on
income earned plus twice its army's value (the earlier studies' rule).

Three games per computer faction, level and strength is few. Read the totals (nine games a cell) as the real result
and the faction rows as hints.

### The results (before the fixes in section 3)

{BENCH}

### Against the owner's targets

{TARGETS}

## 3. The computer's blunders

### How they were found

Three ways: the match tool's own detectors over all the study games (an army standing still while the enemy is in its
base, a bank left unspent, no units made, units stuck on a move, a first attack that traded badly, no attack by 12:00,
one hall at 10:00); the match logs of every game (the computer explains each decision there, and the AI STORY the player
reads is made from them); and filmed games (pictures every 15 seconds, the armies every minute, every fight).

{BLUNDERS}

### What was fixed (each behind an off switch, each measured)

{FIXES}

### Not fixed: proposals

{PROPOSALS}

## 4. What would most improve the computer opponent next

{NEXT}

## 5. Balance observations (proposals only, nothing changed)

{BALANCE}

## The tools

- `scripts/ai_bench_human.gd`: the benchmark player. A qa_match slot `faction/plan/side/who` with who = novice, average or
  good runs it (who may also be easy, normal, hard or brutal for a computer of that level).
- `tools/study/ai_opponent_review.py`: the study's queue (sanity, bench, the matrix, the fix measurements), run from a
  frozen copy of the game (`tools/study/freeze_copy.sh`: scripts and tools copied, the art symlinked) so code edited
  meanwhile cannot leak into running games.
- `tools/study/ai_opponent_review_report.py DATA > tables.md`: every table above.
- `tools/study/ai_opponent_review_fix.py FIXDATA BASEDATA`: a fix's games beside the study's on the same tags.
- `tools/study/ai_opponent_review_film.sh TAG [END]`: films a study game (pictures for this document).
- `tools/study/run_ai_tests.sh [ROOT]`: every tools/test_ai_*.gd, a line each.
