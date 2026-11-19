# Plan matrix: every Clockwork plan against every faction (0.38.59)

A study job (plan-matrix-clockwork, 2026-11-18; the owner, 10:59: "we can open up the testing to all strategies against
all factions"). No game, AI or balance code changed. Sister jobs plan-matrix-crown and plan-matrix-brood ran the same
design for the other two factions.

Data: `docs/plan_matrix_clockwork/data/<tag>/` (result.json, story.txt), `games.csv` (one line a game), `tables.md`
(every table of the report tool), films in `docs/plan_matrix_clockwork/films/<tag>/`.

## In short

Each Clockwork plan was FORCED on the Hard Clockwork computer and played against each faction's Hard OPTIMAL, to
**20:00**, 8 games a cell (4 maps x 2 seeds, the start spots swapped). "Won or led" = won, or a draw at 20:00 led by 10%
(income earned + 2 x army value). "v OPTIMAL" pairs each game with the Clockwork OPTIMAL's game on the same map, seed and
spots: in how many the plan did better / worse, two-sided sign test.

| Clockwork plan | v Crown | v Brood | v Clockwork | all 24 | v OPTIMAL, all (better / worse, p) |
|---|---|---|---|---|---|
| **OPTIMAL** (the baseline) | **8** (6-2-0) | **7** (6-1-1) | **6** (6-0-2) | **21** | - |
| Balanced | **8** (5-3-0) | 6 (6-1-1) | 5 (3-2-3) | 19 | 3 / 5 (0.73) |
| Economy | **8** (6-2-0) | **8** (7-1-0) | 3 (3-2-3) | 19 | 2 / 4 (0.69) |
| Pendulums | 7 (3-5-0) | **8** (6-2-0) | 4 (3-3-2) | 19 | 2 / 4 (0.69) |
| Timing attack | **8** (7-1-0) | 5 (2-4-2) | 4 (3-1-4) | 17 | 0 / 4 (0.13) |
| Clock Soldier rush | 6 (3-4-1) | 4 (4-1-3) | 5 (5-0-3) | 15 | 2 / 7 (0.18) |
| Heavy Works push | 5 (3-4-1) | 6 (5-1-2) | **0** (0-0-8) | 11 | 1 / 11 (**0.006**) |
| Rush | 3 (1-6-1) | 2 (1-1-6) | 4 (4-1-3) | 9 | 1 / 13 (**0.002**) |
| Springer timing | 4 (2-3-3) | 1 (1-2-5) | **0** (0-0-8) | 5 | 1 / 17 (**<0.001**) |
| Owl raids | 1 (0-3-5) | 1 (0-1-7) | **0** (0-0-8) | **2** | 0 / 19 (**<0.001**) |

(won or led of 8, with W-D-L at 20:00)

1. **OPTIMAL is the best Clockwork plan, or tied for it, against every faction**: 21 of 24. No forced plan beat it
   significantly anywhere; the closest are Balanced, Economy and Pendulums (19 of 24 each), each a little worse paired.
2. **Four plans are clearly worse than OPTIMAL**: the Owl raids (2 of 24, worse in 19 of 19 differing games), the
   Springer timing (5 of 24), the Rush (9 of 24) and the Heavy Works push (11 of 24). All four lose all or nearly all of
   their mirror games. What they share: a written opening that leaves them 2,000-4,000 behind in income by 8:00 (OPTIMAL
   earned 9,764 v the Crown by 8:00; the Owls 5,330, the Springers 6,180, the Clock Soldier rush 6,828, the Heavy Works
   7,124).
3. **v the Crown nearly everything works**: OPTIMAL, Balanced, Economy and Timing are 8 of 8. The Crown OPTIMAL loses
   to every plan that keeps the Clockwork's normal economy.
4. **v the Brood the Economy plan and the Pendulums are perfect (8 of 8)**; OPTIMAL (Balanced, 7 of 8) is a hair behind.
   The Brood OPTIMAL reads OPTIMAL / Balanced / Economy as GREEDY and opens its Raptor rush every time, and the rush fails;
   against the plans that show soldiers early it plays Balanced, Timing or Spitter, then turns to the Brute siege (7 of 8
   against the Rush, 6 of 8 against the Springers), and that breaks them.
5. **The mirror punishes any slow opening**: Heavy Works, Springer and Owls lose 8 of 8 to the Clockwork OPTIMAL
   (Balanced or Economy), all by 16:46. The Clock Soldier rush is the only written opening that holds its own there
   (5 of 8, all 5 wins).
6. **OPTIMAL's picks match the best plans**: it never picks a plan that lost here, except the Springer timing v the
   Crown, and the Springer timing *as OPTIMAL plays it* (picked at 2:15-3:00 after the common opening) won 5 of 5,
   while the forced Springer timing (its written opening from 0:00) won or led only 4 of 8. One proposed change: try
   Economy v the Brood (below).
7. **Noise**: the cell OPTIMAL v the Clockwork OPTIMAL is the same computer on both sides and came out 6 of 8 for the
   subject. A cell of 8 moves by +-2 between runs; only the paired tests with p < 0.05 are called real below.

## How it was measured

- **Runner** `tools/study/plan_matrix_cw.py FACTION run OUT` (new; shared by the three sister jobs, the faction an argument):
  every plan of AI.STRATEGIES for that faction, OPTIMAL included, forced on slot P1 (round 0) or P2 (round 1) through
  `tools/qa_match.gd` (`slots:clockwork/<plan>/0,...`), against each faction's OPTIMAL, both Hard. The seed depends only on
  the map and the round (2100 + 37 x round + 3 x map index), so every plan and every opponent plays the same seeds and the
  same spots as OPTIMAL: a paired design. Two games at a time on a 2-core machine, about 3.2 minutes a game to 20:00.
- **Maps**: the first four of the job's six (Greenhold, Ashford Crossing, Mirewood, Cinder Steps): the full 360 games
  would have taken about 20 hours, so the job's fallback (4 maps, 20:00 kept) was used: **8 games a cell, 240 games**.
  A start on the last two maps (Frostfang, Dune Sea) was cut by a machine restart after 11 Frostfang games; they are kept in
  the data folder but **not counted** (`plan_matrix_report.py --maps 4`), so every cell has the same games.
- **Not in the matrix**: the hidden Turret turtle (`tools/qa_match.gd` cannot force a hidden plan; the owner has ruled it
  is not a build of its own).
- **Tables**: `python3 tools/study/plan_matrix_cw_report.py clockwork DATA --maps 4 --csv games.csv > tables.md` (new).
  Income = earned so far (cumulative); army = army value; halls lost = built halls lost.
- **Films**: `tools/study/plan_matrix_cw_film.sh clockwork TAG` (new; tools/film_coach.gd shots:1 under xvfb-run on the tag's
  map, seed and sides). A film is a new game, not the study game: the match is not deterministic.
- 183 of 240 games were decided by 20:00. No game failed. One game logged a script error (below).

## Against the Crown

| plan (v Crown) | won or led | earned 8:00 | 12:00 | 20:00 | workers 8:00 | army 12:00 | halls lost own / Crown's | first attack |
|---|---|---|---|---|---|---|---|---|
| OPTIMAL | 8 | 9,764 | 21,100 | 42,350 | 44 | 3,960 | 0.00 / 3.00 | 5:37 |
| Balanced | 8 | 10,080 | 20,990 | 41,494 | 45 | 4,735 | 0.00 / 4.00 | 4:50 |
| Economy | 8 | 10,903 | 22,784 | 45,858 | 52 | 4,918 | 0.00 / 3.38 | 5:30 |
| Timing attack | 8 | 9,412 | 20,628 | 42,180 | 49 | 4,565 | 0.00 / 3.00 | 4:35 |
| Owl raids | 1 | 5,330 | 9,060 | 25,355 | 26 | 1,040 | 2.88 / 0.25 | 11:40 |

(medians; the other plans in tables.md)

- **Best: Economy and Timing** (Timing won 7 of 8 outright; Economy has the most income and workers at every minute).
  Nothing beats OPTIMAL here: four plans are 8 of 8. The Crown OPTIMAL opens Timing (4) or Balloon (3) against every plan
  and loses its halls (3-4 a game) to any Clockwork that keeps its economy.
- **Worst: Owl raids** (1 of 8, worse than OPTIMAL in 7 of 7 differing games, p 0.016). It loses 2.9 halls a game to
  the *Crown* while taking 0.25: the only plan the Crown computer beats. Then the Rush (3 of 8; six draws, income
  0.83 of the Crown's at 20:00, 36 workers) and the Springer timing (4 of 8).
- Note for the Crown job: in the Owl film the Crown banked 16,000 gold by 16:00 while 200/200 and still did not finish
  a Clockwork at a third of its income.

## Against the Brood

| plan (v Brood) | won or led | earned 8:00 | 12:00 | 20:00 | army 12:00 | army 20:00 | halls lost | the Brood's opening |
|---|---|---|---|---|---|---|---|---|
| OPTIMAL | 7 | 8,338 | 17,044 | 34,746 | 3,590 | 3,055 | 0.38 | rush 8 |
| Economy | **8** | 9,086 | 17,592 | 39,374 | 3,885 | 7,750 | **0.00** | rush 8 |
| Pendulums | **8** | 7,552 | 17,828 | 38,652 | 3,215 | 6,982 | **0.00** | balanced 3, timing 3, spitter 2 |
| Rush | 2 | 6,444 | 12,877 | 28,349 | 235 | 3,300 | 2.62 | balanced 3, timing 3, spitter 2 |
| Springer timing | 1 | 5,470 | 9,049 | 27,036 | 375 | 4,348 | 2.00 | balanced 3, timing 3, spitter 2 |
| Owl raids | 1 | 5,256 | 7,696 | 22,871 | 1,200 | 4,625 | 2.38 | balanced 3, timing 3, spitter 2 |

- **Best: Economy (8 of 8, 7 wins, no hall lost) and Pendulums (8 of 8, no hall lost).** Why Economy: it shows the
  Brood nothing early, the Brood OPTIMAL reads it GREEDY at ~1:50 and opens its Raptor rush (8 of 8); the Clockwork's
  shared rules see the Raptors (3:29 in the film), build a Light Works and Clock Soldiers, then a Heavy Works and
  Pendulums, and the rush dies at the ramp. The Economy plan is the one that then has the most behind it: 9,086 earned by
  8:00 (OPTIMAL 8,338), 54 workers at 20:00, an army of 7,750 at 20:00 (OPTIMAL 3,055). Why Pendulums: the Brood does not
  rush it (it sees soldiers), so its Pendulums meet the Raptor swarm they are made for and it never loses a hall.
- **Worst: Owl raids, Springer timing (1 of 8 each) and Rush (2 of 8).** The written openings cost the economy (5,256-6,444
  by 8:00), the Brood does not rush them, grows, and its later plan goes Brute siege (Rush 7 of 8, Springer 6 of 8, Owls 5
  of 8): the Brutes break the Ratchet Turrets and the swarm goes through (the Owl story on Greenhold: 14:34 the Brutes
  batter the turret, 14:53 they break through). The Springers' first attack is at a median 16:35: the leap never comes.
- The Springer timing v the Brood was worse than OPTIMAL in 7 of 8 differing games (p 0.07).

## Against the Clockwork (the mirror)

| plan (v Clockwork OPTIMAL) | won or led | W-D-L | earned 8:00 | 12:00 | army 12:00 | halls lost own / foe's |
|---|---|---|---|---|---|---|
| OPTIMAL | 6 | 6-0-2 | 10,656 | 21,870 | 7,290 | 1.12 / 3.88 |
| Balanced | 5 | 3-2-3 | 10,407 | 20,946 | 4,028 | 1.75 / 2.75 |
| Clock Soldier rush | 5 | 5-0-3 | 7,032 | 16,652 | 3,148 | 1.75 / 1.50 |
| Heavy Works push | **0** | 0-0-8 | 7,452 | 13,649 | 330 | 4.12 / 0.00 |
| Springer timing | **0** | 0-0-8 | 5,850 | 9,992 | 125 | 3.12 / 0.00 |
| Owl raids | **0** | 0-0-8 | 6,140 | 9,525 | 75 | 3.00 / 0.00 |

- **Best: OPTIMAL (6 of 8), then Balanced and the Clock Soldier rush (5 of 8).** The Clock Soldier rush is the one
  written opening that works here: its 5 games are all wins, and its income ratio at 8:00 is the best of any plan (1.42:
  the rush hurts the other's economy more than its own). The opposing OPTIMAL answers the rushing plans with Economy (5
  of 8), which is greedy against a rush.
- **Worst: Heavy Works push, Springer timing and Owl raids: 0 of 8 each, 8 losses each, worse than OPTIMAL in 6 of 6
  (p 0.031 each).** The mirror's OPTIMAL (Balanced / Economy) is at 10,000+ by 8:00 and pushes at ~5:30-6:00; these three
  are 3,000-5,000 behind, have no army at 12:00 (75-330) and are beaten at a median 13:00 (11:12-16:46). Economy, so good v the
  Brood, is only 3 of 8 here: its army at 12:00 is 0.13 of the other's.

## The Clockwork OPTIMAL's own picks, and do they match?

| v | OPTIMAL opens (by ~3:00) | later | won or led by its pick | the best forced plans here |
|---|---|---|---|---|
| Crown | Springer 5, Heavy 1, Economy 1, Balanced 1 | to Economy 4 times (GREEDY reads after 5:00) | Springer 5 of 5, the others 1 of 1 each | OPTIMAL, Balanced, Economy, Timing (8 of 8) |
| Brood | Balanced 8 | - | 7 of 8 | Economy, Pendulums (8 of 8) |
| Clockwork | Balanced 8 | - | 6 of 8 | OPTIMAL (6), Balanced, Clock Soldier rush (5) |

- **Mostly yes.** OPTIMAL never picks Owl raids, the Rush or (v the Brood and in the mirror) the Springers or the Heavy
  Works, the plans this study found worst.
- **The Springer v the Crown is not a contradiction**: OPTIMAL plays the shared opening first and turns to the Springer
  build at 2:15-3:00 with the economy already up (9,764 earned by 8:00, first attack at 5:37), and moves to Economy when
  it reads the Crown greedy later. The forced Springer timing writes the opening from 0:00 (4 Springers, High Leap, a
  Swift): 6,180 by 8:00, first attack at 10:17, 4 of 8. The plan is not bad; its *opening* is.
- **v the Brood, Economy did as well or better than Balanced** (8 v 7, better in 1 game, worse in none; income at 20:00
  39,374 v 34,746, army 7,750 v 3,055). Not significant on 8 games.

### Proposed pick table (for the owner; nothing changed)

| Clockwork OPTIMAL v | today | proposed | why |
|---|---|---|---|
| Crown | Springer after the shared opening, Economy on a later GREEDY read | **keep** | 8 of 8; four plans are 8 of 8, none better |
| Brood | Balanced | **Economy** (keep the shared rush defence) | 8 of 8, no hall lost, more income and army at 20:00; the Brood rushes it and the rush fails. Measure it on more maps before keeping it (it is 1 better / 0 worse) |
| Clockwork | Balanced | **keep**; the Clock Soldier rush is the only fair alternative | never Heavy Works, Springer or Owls in the mirror (0 of 8 each) |

## Films and coach's notes

Two films, the best and the worst plan of the study (both new games on the study's seed, so they show a kind of game):

**1. The best: Economy v the Brood, Ashford Crossing** (`films/pm_cw-economy_v_br_ashford_crossing_r0/`): the Clockwork
**won at 11:51**.
- 0:00 Winders non-stop, a second Clocktower fast, no army. The Brood reads GREEDY at 1:51 and picks Rush; 10 Raptors
  attack at 2:54.
- 3:29 the Clockwork spots the Raptors, reads AGGRESSIVE: a Light Works and Clock Soldiers, then (3:31) a Heavy Works and
  Pendulums and a turret. The rush is held at the ramp; at 6:07 the Brood's wave is pulled back with 100 of 250 left.
- 6:00 the Clockwork expands (third Clocktower), 7:55 the push goes out in one block of 26 (21 Clock Soldiers, 6
  Springers, 2 Pendulums: 2,470 against the Brood's 920); `fight_0857.jpg` is the push at the Brood's ramp with the
  Mother behind it. 10:59 "clearly ahead (2,710 against 186)", over at 11:51.
- Coach: this is the Clockwork's ideal game v the Brood: the rush it baits is cheap to hold with the reactive rules, and
  every coin not spent on it is in Winders. The risk is a Brood that does *not* rush: the 8 study games never showed one.

**2. The worst: Owl raids v the Crown, Greenhold** (`films/pm_cw-owls_v_cr_greenhold_r0/`): a draw at 20:00, the Crown
far ahead (earned 45,880 v 26,983; 90 labourers v 49; 7 halls v 5).
- 4:00 the two are level on labourers (18 v 17), but the Clockwork's coins go into two Clock Aviaries; by 6:00 it has 2
  Ticking Owls and 2 Cuckoos, 23 labourers to the Crown's 28, and its second Clocktower comes at ~6:00 (the Crown's at
  4:00). 8:00: 28 labourers v 41, 2 halls v 3. `map_0900.jpg`: a small blue base in the corner, a red one three times
  its size.
- The Owls (3-4 all game) never get a story line of their own: the army stays at home ("defends its base" twelve times,
  the Crown's Balloon raids met by small groups) and its first push is at 15:38. From 12:00 up to 19 Winders are on
  repair, not on gathering.
- Coach: the plan pays for the air before the economy and never cashes it in. The Crown's anti-air (Musketeers in the
  line, canister) is everywhere a raid would go, so the plan's own rule (raid away from anti-air) keeps the Owls home.
  The Owls' sortie lines go to the match log, not the story, so the film cannot count them; the numbers say they did not
  pay.

## Problems found (for the owner)

1. **The Owl raids plan does not work against anyone** (2 of 24; worse than OPTIMAL in 19 of 19 differing games). It is
   a lobby choice for training; a coaching job (or taking it out of the lobby) is proposed. OPTIMAL never picks it.
2. **The written openings cost too much**: forced Springer timing, Heavy Works push, Rush and Owls are all 2,000-4,000
   behind by 8:00. OPTIMAL's version of the Springer works because it starts from the shared opening; the same may hold
   for the others (a proposal: let every Clockwork written build start from the shared opening, as OPTIMAL does).
3. **A script error in the Crown computer** (1 game, `pm_cw-rush_v_cr_cinder_steps_r0/errors.txt`, 4 lines):
   `Trying to assign invalid previously freed instance` at `scripts/ai_expand_wall.gd:458`
   (`var b: Building = s.get("b")` when the slot's building was freed). Typed assignment of a freed object; an untyped
   `var b = s.get("b")` before the `is_instance_valid` check would fix it. Not changed here (study job).
4. More games would sharpen the small differences: the two maps left (Frostfang, Dune Sea) would make 12 a cell;
   `tools/study/plan_matrix_cw.py clockwork run OUT --maps 6` resumes from the games already in the data folder.

## Claude's choices

1. **4 maps, not 6** (the job's own fallback): 240 games to 20:00 took about 12 hours; 6 maps would have been 20.
2. **The 11 Frostfang games from the cut second run are kept but not counted**, so every cell has the same 8 tags.
3. **The two films are the study's best and worst** (Economy v the Brood, Owl raids v the Crown) rather than one best
   and one worst per faction (six films); the per-faction "why" comes from the stories and the numbers.
4. **"Won or led" counts a 10% lead at 20:00**, the win-rate studies' rule, so the numbers read like theirs.
