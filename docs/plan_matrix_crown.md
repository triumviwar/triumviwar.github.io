# Plan matrix: every Crown plan against every faction (plan-matrix-crown, 0.38.59)

A study job: no game, AI or balance code changed. The owner, 2026-11-18 10:59: "I think in the past I prioritized balloon
over Horseman rush against Clockwork. I think we can open up the testing to all strategies against all factions because
we are in new territory now." Sister jobs plan-matrix-clockwork and plan-matrix-brood ran the same design for their
factions.

Data: `docs/plan_matrix_crown/data/<tag>/` (result.json, story.txt), `games.csv` (one row a game), `tables.md` (every
table of the report tool); films in `docs/plan_matrix_crown/films/<tag>/`.

## In short

1. **Played to 20:00, the Crown computer loses almost everything to the Brood and the Clockwork, whatever its plan.**
   v the Brood the Crown side is beaten in **82 of 96** games (1 of them by 12:00), v the Clockwork in **60 of 96** (5 by
   12:00). The 2026-11-17 study's "the Crown no longer collapses" was the 12:00 bell: the collapse comes between 13:00 and
   18:00. Won or led of all 192 cross games: 5 (2.6%).
2. **The plan still matters a lot, in how long the Crown lasts and how close it gets** (score = income earned + 2 x army,
   subject / opponent; "survived" = not beaten by 20:00):

   | | best | worst | OPTIMAL |
   |---|---|---|---|
   | v Brood | **Rush** (the plan's own build): survived 4 of 12, 1 win, beaten at a median 17:40, score x1.97 of OPTIMAL's | **Timing**: survived 0, beaten at 15:29, x0.62 (t -2.2); **Balanced** 0 survived, beaten at 14:22 | survived 1, beaten at 15:34 |
   | v Clockwork | **Siege** (7 survived, x1.38) and **Timing** (2 wins, x1.47) | **Rush** (11 of 12 beaten, median 13:34, x0.53) and **Dragoon** (10 beaten, x0.53) | 6 survived, 0 won or led |
   | v Crown (mirror) | **Balanced** (8 of 12 won or led, 0 lost; 7 better / 0 worse than OPTIMAL, p 0.016) and **Balloon** (4 wins, 0 lost; 8 / 1, p 0.039) | **Dragoon** (8 beaten, x0.28, t -2.7) and **Timing** (6 beaten) | 2 of 12 won or led |

3. **The owner's question, Balloon v Horseman rush against the Clockwork: Balloon is clearly the better of the two, but
   neither is good.** Rush: 11 of 12 games lost (median 13:34), its army at 8:00 is **0.18** of the Clockwork's, 0.7 halls
   at 12:00. Balloon: 7 of 12 lost (median 15:30), army 0.58 at 8:00, 2.0 halls at 12:00, score 1.74x the Rush's on the same
   games. The Rush fails the same way every time: the Clockwork reads the early Horse Breeder at ~1:20 as AGGRESSIVE, puts up
   a Light Works and Clock Soldiers, the 3 Horsemen ride in at ~3:45 and are called off within 25 s ("the defenders are
   worth more than the riders"), and the Clockwork pushes from 4:24 into a Crown that spent its opening on riders. Balloon
   is not a winner either: no better than OPTIMAL (x0.92) and behind Siege and Timing. **Keep the Rush off against the
   Clockwork** (OPTIMAL never picks it there: right), and Balloon is not the answer the owner hoped for.
4. **OPTIMAL's picks are half right.** v the Brood it picks the Rush in 11 of 12 (right plan) but plays its own weaker
   version (the common opening first, then the punish: army at 8:00 0.91 of the Brood's against the forced Rush's 1.56);
   v the Clockwork it picks Timing 8, Balloon 3, Economy 1 (Timing right; Balloon mid); in the mirror it picks Economy 6,
   Siege 3, Timing 2, Balanced 1, while the forced Balanced and Balloon both clearly beat OPTIMAL there.
5. No game failed, stalled or logged a script error (288 of 288 ran, no errors.txt).

## How it was measured

- **Design**: every Crown plan of AI.STRATEGIES (Balanced, Rush, Economy, Timing attack, Dragoon raids, Siege push,
  Balloon harass) FORCED on the Crown computer (slot `crown/<plan>`), plus OPTIMAL as the reference row, against Hard
  OPTIMAL of the Brood, the Clockwork and the Crown (the mirror: the forced plan v a Crown OPTIMAL). Six maps (Greenhold,
  Ashford Crossing, Mirewood, Frostfang, Cinder Steps, Dune Sea) x 2 rounds with the start spots swapped = **12 games a
  cell**, 8 x 3 cells = **288 games, all to 20:00** (or the end). The seed is the same for every plan of a cell's map and
  round, so each plan's game is paired with OPTIMAL's on the same map, seed and spots.
- **Runner**: `tools/study/plan_matrix.py run OUT --faction crown --jobs 2` (shared with the sister jobs: the faction is an
  argument; map by map, both rounds, every cell, so a cut run stays balanced). Two games at a time on the 2-core machine,
  about 2.6 minutes a game: 288 games in 13 hours. All six maps were kept.
- **Tables**: `tools/study/plan_matrix_report.py DATA --faction crown --csv games.csv > tables.md`. "Won or led" = won,
  or a draw at 20:00 led by income earned + 2 x army value by 10% (the old studies' rule). "v OPTIMAL": better / worse
  games on the same map and round (sign test), and the score ratio relative to OPTIMAL's game with a paired t (a beaten
  side's score counts a quarter). Income and army ratios are sums over a cell's games (a beaten side's last row carried).
  Brood "halls lost" is not counted by qa_match.gd (its bases are creatures), so the opponent's halls lost is 0 v the Brood.
- **Noise**: 12 games a cell. Only p < 0.05 or |t| > 2 is called real below; the rest is a lean. With so few Crown wins, the
  survival count and the score ratio are the useful measures, not "won or led".
- **Films**: `tools/study/plan_matrix_film.sh crown TAG` (tools/film_coach.gd shots:1 under xvfb-run, the tag's map, seed
  and sides, to 20:00). A film is a new game (the match is not deterministic): it shows a kind of game.

## The matrix

Won or led / 12 (W-D-L), and against OPTIMAL's row: better / worse games (p), score x relative to OPTIMAL (paired t).

| plan | v Brood | v Clockwork | v Crown (mirror) | all |
|---|---|---|---|---|
| Balanced | 0 (0-0-12) · 0/1 · x0.81 | 0 (0-6-6) · 0/0 · x1.03 | **8 (1-11-0) · 7/0 p 0.016 · x2.32 t 2.3** | 8/36 |
| Rush | 1 (1-3-8) · 1/1 · x1.97 t 1.4 | 1 (1-0-11) · 1/0 · x0.53 t -1.2 | 4 (3-8-1) · 5/2 · x2.00 | 6/36 |
| Economy | 0 (0-1-11) · 0/1 · x1.06 | 0 (0-5-7) · x0.91 | 4 (1-8-3) · 4/1 · x0.93 | 4/36 |
| Timing attack | 0 (0-0-12) · 0/1 · **x0.62 t -2.2** | 2 (2-2-8) · 2/0 · x1.47 | 3 (1-5-6) · 3/2 · x0.41 | 5/36 |
| Dragoon raids | 0 (0-3-9) · 1/1 · x1.30 | 0 (0-2-10) · x0.53 t -1.9 | 1 (0-4-8) · 1/2 · **x0.28 t -2.7** | 1/36 |
| Siege push | 0 (0-3-9) · 0/1 · x1.29 | 0 (0-7-5) · x1.38 | 3 (0-9-3) · 5/2 · x0.91 | 3/36 |
| Balloon harass | 0 (0-2-10) · 0/1 · x0.89 | 1 (0-5-7) · 1/0 · x0.92 | **5 (4-8-0) · 8/1 p 0.039 · x2.81** | 6/36 |
| OPTIMAL | 1 (0-1-11) | 0 (0-6-6) | 2 (1-10-1) | 3/36 |

Survived to 20:00 (not beaten), of 12, and the median minute of the defeats:

| plan | v Brood | v Clockwork | v Crown |
|---|---|---|---|
| Balanced | 0 (14:22) | 6 (15:21) | 12 |
| Rush | **4 (17:40)** | 1 (13:34) | 11 |
| Economy | 1 (17:17) | 5 (14:59) | 9 |
| Timing attack | 0 (15:29) | 4 (17:33) | 6 |
| Dragoon raids | 3 (14:22) | 2 (13:33) | 4 |
| Siege push | 3 (16:28) | **7 (16:29)** | 9 |
| Balloon harass | 2 (14:33) | 5 (15:30) | 12 |
| OPTIMAL | 1 (15:34) | 6 (16:42) | 11 |

## Crown v Brood: why every plan loses, and why the Rush lasts longest

| Crown / Brood | income 5:00 | 8:00 | 12:00 | 16:00 | army 8:00 | 12:00 | labourers / grubs 8:00 | Crown halls 12:00 |
|---|---|---|---|---|---|---|---|---|
| Rush | **1.22** | **1.04** | 0.92 | 0.71 | **1.56** | **1.20** | 0.81 | 2.8 |
| Siege | 0.92 | 0.90 | 0.74 | 0.59 | 0.99 | 0.67 | 0.78 | 2.9 |
| Dragoon | 0.90 | 0.85 | 0.68 | 0.56 | 1.06 | 0.45 | 0.72 | 2.2 |
| OPTIMAL | 1.01 | 0.82 | 0.69 | 0.54 | 0.91 | 0.61 | 0.67 | 2.3 |
| Balanced | 0.98 | 0.78 | 0.64 | 0.52 | 0.60 | 0.08 | 0.76 | 1.7 |
| Timing | 0.91 | 0.69 | 0.51 | 0.39 | 1.08 | 0.37 | **0.43** | 1.7 |

- **How the Crown dies** (the film below and the stories): the Brood keeps 4 Mound Turtle grounds from ~8:00 to the Crown's
  2-3 halls, out-earns it from 8:00 (its income per minute 1.4-1.5x the Crown's by 10:00-12:00), reaches its 200 supply cap
  at a median **13:00**, researches Battering Horns, and comes with a wave of 75-107 supply. The Crown's line behind its
  palisade (1,500-2,500 army) holds the first wave, sometimes the second, then the Brutes break the wall, the army is gone
  in under a minute ("the force at its buildings (3,567) is more than its army (98)") and every hall falls within 2 minutes.
  The game ends at a median 15:30 with OPTIMAL.
- **Why the plain Rush plan is the best of them**: it is the only plan with the Brood behind at 8:00 (income 1.04, army
  1.56): the Horse Breeder first and the riders before the Brood's army keep its grubs under the warriors ("guards its grubs
  with 16-61 warriors, no chase"), then the Crown's army is the bigger one into 12:00 (1.20). It still loses 8 of 12: by
  16:00 the Brood has caught up (income 0.71) and its capped army comes. OPTIMAL picks the Rush too, but plays it from its
  common opening (the ramp Cottage, the Gate, the Barracks, the second Farm, then the Breeder on a GREEDY read at ~1:30):
  its riders arrive at ~4:00 into a Brood that has read them (the film: "the riders before its army" at 4:03, "rush has
  failed: no headway in 146 s" at 6:29, then hands over to Economy). Its army at 8:00 is 0.91 of the Brood's, not 1.56.
- **Why Timing and Balanced are the worst**: Timing builds its army and holds (no attack before 4:30, then only when ahead)
  with the fewest labourers of any plan (0.43 of the Brood's grubs at 8:00); Balanced makes no early army (0.60 at 8:00) and
  attacks at ~8:15 into a Brood already bigger. Neither presses the Brood's economy, which is what decides this matchup.
- The Brood's own picks did not matter much (Spitter, Balanced, Brute, Economy, Timing all win).

## Crown v Clockwork: Siege and Timing last, the riders' plans die early

| Crown / Clockwork | income 5:00 | 8:00 | 12:00 | 20:00 | army 8:00 | 12:00 | labourers 8:00 | halls 12:00 (Crown / Clockwork) |
|---|---|---|---|---|---|---|---|---|
| Siege | 0.68 | 0.72 | 0.59 | 0.54 | 0.61 | 0.37 | 0.78 | 3.0 / 4.2 |
| Timing | 0.67 | 0.65 | 0.58 | 0.55 | **0.69** | **0.41** | 0.70 | 3.1 / 4.1 |
| Balanced | **0.80** | **0.78** | 0.65 | 0.47 | 0.60 | 0.23 | 0.88 | 2.4 / 4.2 |
| Balloon | 0.68 | 0.64 | 0.51 | 0.43 | 0.58 | 0.29 | 0.76 | 2.0 / 4.2 |
| OPTIMAL | 0.70 | 0.63 | 0.54 | 0.46 | 0.54 | 0.28 | 0.72 | 2.9 / 4.0 |
| Dragoon | 0.72 | 0.68 | 0.50 | 0.41 | 0.50 | 0.14 | 0.72 | 1.8 / 4.1 |
| Rush | 0.70 | 0.71 | 0.47 | 0.44 | **0.18** | 0.07 | 0.92 | 0.7 / 4.0 |

- **The Clockwork computer is simply richer**: every Crown plan earns 0.63-0.80 of its income at 8:00, and it has its 4th
  Clocktower before the Crown's 3rd. What separates the Crown's plans is whether its army keeps up.
- **Siege and Timing** keep the army closest (0.61-0.69 at 8:00) and the most halls (3 at 12:00), lose least (Siege 5 of 12
  beaten, Timing 8 but 2 of the Crown's 3 wins v the Clockwork: Mirewood r0 and Cinder Steps r1 at ~15:10).
- **Rush and Dragoon** lose fastest (median 13:34 / 13:33): the riders cost the army that should stand at home when the
  Clockwork's push comes at ~4:30-6:00, and the raids kill 2-3 workers and 2-3 soldiers in their first 90 s (Siege's and
  Balloon's first arrivals kill 5).
- The Clockwork's picks: Springer, Heavy Works, Economy, Balanced against most plans; **Balanced 12 of 12 against the
  Rush** (it reads the Horse Breeder as AGGRESSIVE and defends first).

### The owner's question: Balloon harass v Horseman rush against the Clockwork

| v Clockwork, 12 games each | beaten | median defeat | army 8:00 | halls 12:00 | score v OPTIMAL | first arrival kills (workers / soldiers) |
|---|---|---|---|---|---|---|
| Rush | **11** | 13:34 | 0.18 | 0.7 | x0.53 | 2.4 / 3.4 at 5:35 |
| Balloon | 7 | 15:30 | 0.58 | 2.0 | x0.92 | 5.2 / 8.9 at 7:20 |

Paired on the same 12 games, Balloon's score is 1.74x the Rush's. So the owner's old priority was right: **Balloon over
the Horseman rush against the Clockwork**. But Balloon is only OPTIMAL's level here, and Siege (x1.38) and Timing (x1.47)
do better than both; against the Crown (mirror) Balloon is one of the two best plans.

## The Crown mirror: Balanced and Balloon beat OPTIMAL

| forced / OPTIMAL | income 8:00 | 12:00 | 20:00 | army 12:00 | 16:00 | halls at 20:00 (forced / OPTIMAL) | halls lost (forced / OPTIMAL) |
|---|---|---|---|---|---|---|---|
| Balanced | 1.01 | 1.01 | **1.25** | 1.15 | 1.12 | **5.1 / 2.8** | 0.17 / 2.25 |
| Balloon | 0.82 | 0.89 | 1.03 | **1.41** | **1.39** | 4.5 / 3.8 | 1.42 / 1.00 |
| Rush | 1.05 | 1.11 | 0.92 | 1.11 | 0.79 | 2.8 / 3.8 | 1.33 / 1.00 |
| Dragoon | 0.92 | 0.83 | 0.65 | 0.73 | 0.40 | 1.8 / 5.8 | 3.00 / 0.17 |
| Timing | 0.83 | 0.70 | 0.56 | 0.46 | 0.37 | 2.2 / 4.5 | 2.33 / 1.17 |

- To 20:00 the mirror does break: 33 of 96 games decided (11 wins, 22 losses for the forced side).
- **Balanced** never loses a game and leads 8: it keeps the economy even, its army a little bigger from 12:00, and takes
  2.25 of OPTIMAL's halls a game. OPTIMAL against it picks Siege 6 / Timing 3, which lose their army in the attack.
- **Balloon** wins 4 (median 17:56), the most of any plan: the balloons kill 12 workers in their first arrival (the
  highest of any cell), and its army is 1.4x OPTIMAL's from 12:00.
- **Dragoon and Timing** are the worst: both throw their army at a walled Crown and lose it (Dragoon's halls at 20:00
  1.8 to OPTIMAL's 5.8).

## Does OPTIMAL pick the best plans?

| v | OPTIMAL picks (12 games) | best plans by the data | match? |
|---|---|---|---|
| Brood | Rush 11 (9 on a GREEDY read at ~1:30, 2 on its lean at 0:00), Economy 1 | Rush (its own build), then Siege, Dragoon | the right plan, the wrong version: its Rush after the common opening reaches 0.91 of the Brood's army at 8:00, the plain Rush 1.56 |
| Clockwork | Timing 8, Balloon 3, Economy 1 (read NORMAL in 12) | Timing, Siege | mostly; Balloon is only average; never Rush or Dragoon (right) |
| Crown | Economy 6, Siege 3, Timing 2, Balanced 1 (read UNKNOWN in 12) | Balanced, Balloon | no: Timing is one of the worst; Economy and Siege only average |

### Proposed pick table (OPTIMAL's choice by matchup; none applied, the owner's call)

| v | first choice | second | never |
|---|---|---|---|
| Brood | **Rush, from 0:00, its own build** (not the common opening first) | Siege | Timing, Balanced |
| Clockwork | **Timing** | Siege | Rush, Dragoon |
| Crown | **Balanced** | Balloon | Dragoon, Timing |

All three are leans on 12 games a cell (only the mirror's Balanced and Balloon and the Brood's Timing pass p < 0.05 or
|t| > 2); and against the Brood and the Clockwork the best plan still loses most games, so a pick table alone will not make
the Crown computer win. What it needs most (from the films and the stories): against the Brood, something that stops the
Brood reaching 4 grounds and 200 supply by 13:00 (the Rush slows it; nothing stops it); against the Clockwork, the
economy (0.63-0.80 of the Clockwork's income at 8:00 with any plan).

## The films and the coach's notes

Two films to 20:00 (docs/plan_matrix_crown/films/<tag>/: story.txt, coach.txt every 15 s, result_short.json, maps every 3
minutes, the fights, each army every 2 minutes, the halls at 4:00 and 8:00; jpg).

**Rush v Clockwork, Greenhold r0 (seed 9106)** (study game: beaten at 13:34; film: beaten at 14:29, 9,120 income to
21,660, Clockwork army 6,865). The whole matchup in one film. 0:00 "opens with a Horse Breeder"; 1:21 the Clockwork "reads
the enemy as AGGRESSIVE (a production building very early)... a Light Works and Clock Soldiers first"; 3:46 the rush rides
with 11 supply, 3 of them Horsemen; 4:09 "the rush has failed (the defenders are worth more than the riders)"; 4:24 the
Clockwork's push is already out. From 5:46 "sees a push coming (560 against 240 of its army at home)", the line goes to
the ramp top and the cliff edge, and at 8:00 the Clockwork's push is "clearly ahead (2,160 against 420): it presses on to
finish the game". Halls fall from 9:11; the Crown "gathers its army out of reach" four times between 10:01 and 11:32
(1,910 v 673, 1,502 v 490...). *What the Crown does wrong*: it tells the Clockwork its plan at 1:21 with a Horse Breeder,
then sends three riders into a defence that was built for them, and its army never catches up (0.18 of the Clockwork's at
8:00 in the study). *The Clockwork*: nothing special; Balanced with a rush defence is enough.

**OPTIMAL v Brood, Greenhold r0 (seed 9103)** (study game: beaten at 14:48; film: beaten at 14:52, 10,260 to 24,405, the
Brood at 199 supply). 1:32 reads GREEDY and "picks Rush: punish the greed"; 4:03 three Horsemen ride; the Brood "finds 2
riders in its land at 4:08: Raptors now, its grubs kept beside them" and guards them with 4-61 warriors from then on; 6:29
"the rush has failed (no headway in 146 s)", OPTIMAL hands over to Economy. The Brood's waves at 6:19 (23 supply) and
9:22 (75 supply) are held at the palisade ("pulls its wave back: only 200 of 755 is left"); the Crown's army is 2,090 at
9:41. But the Brood grows its Mother to stage 3 at 8:09, keeps four grounds, researches Battering Horns at 11:05 and at
13:00 107 soldiers (2,800) come: by 13:12 the Crown's army is 30, halls fall from 12:26 to 13:38. *What the Crown does
wrong*: the riders come two and a half minutes too late to hurt (the plain Rush plan rides at 3:40 with the Breeder first
and keeps the Brood behind to 12:00); after the rush it sits behind its palisade with 2-3 halls while the Brood takes the
map, so the wall meets a capped army with siege. *The Brood*: plays Timing and never has to change it.

### The coach's notes, in one list

1. **The 12:00 bell hid the Crown's defeats**: 82 of 96 games v the Brood and 60 of 96 v the Clockwork are lost by 20:00,
   only 1 and 5 by 12:00. Future Crown studies should run to 20:00.
2. **v the Brood the Crown loses the map, not the fights**: it holds the first waves behind its palisade, then meets a
   200-supply Brood with Battering Horns at ~13:00 with 2-3 halls to 4 grounds. The only plan that slows this is the Rush
   played from the first minute.
3. **v the Clockwork the riders' plans tell the enemy and cost the army**: Rush and Dragoon lose fastest. Timing and Siege,
   the gun plans, last longest.
4. **In the mirror OPTIMAL's picks attack walls**: Timing, Siege and Dragoon lose their armies on a walled Crown; Balanced
   and Balloon, which don't, beat it.

## Proposals (none applied; the owner's call)

1. **OPTIMAL's pick table** as above: v the Brood the Rush from its lean at 0:00 (the plan's own build, not the punish
   after the common opening), v the Clockwork Timing (Siege second), v the Crown Balanced (Balloon second); never Rush or
   Dragoon v the Clockwork, never Timing v the Brood or in the mirror. Measure it the same way (the OPTIMAL row of this
   runner, 12 games a matchup) before and after.
2. **Crown v Brood after the rush**: the Rush buys an even army and income to ~12:00 and then the Brood out-expands it.
   Look at what the Crown does with its 1.2x army at 12:00 (the 2026-11-17 study: it holds its wave while bigger, the
   false reckoning): a push on a Mound Turtle ground before the Brood reaches its cap.
3. **Crown v Clockwork economy**: still the gap (0.63-0.80 at 8:00 with any plan); the plan cannot close it.
4. **Study length**: run the next Crown studies to 20:00 (this machine did 288 games in 13 hours, two at a time).
