# The championship simulation

Job `tournament`, branch `tournament`. The owner asked on 2026-11-24: "make a championship simulation so we see."

Sixteen computer players played a full double-elimination championship, best of 3, games to 20:00, on the six
parity maps with map bans. It was run three times with different dice. This page has the brackets, the
champions, and what the games say about the factions, the plans, the matchups, the game lengths and the maps.

## How it was run

The championship is the in-game tournament tool's ALL COMPUTER mode, driven by a script so it can run
without a screen:

- The bracket is the game's own `Tournament` (`tools/tournament_cli.gd` keeps it, makes the computers' map
  bans and picks, and takes the results).
- Every game is a real headless match (`tools/qa_match.gd`), to 20:00, all computers at Hard.
- `tools/study/championship_sim.py` plays two games at a time and tells the bracket each result.
- `tools/study/championship_sim_report.py` makes the tables below.
- The data is in `docs/championship_sim/data/<run>/` (the bracket as `tournament.json`, each game's
  `result.json`, `story.txt` and `game.json`).
- The game code was frozen at commit 462417b06 for all runs (a copy made with `tools/study/freeze_copy.sh`).

| Rule | Setting |
|---|---|
| Format | Double elimination, 16 players, with a bracket reset if the lower bracket's winner wins the grand final |
| Series | Best of 3, the grand final too |
| Maps | Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps |
| Map rule | Each player bans one map (the higher seed first), then game 1 is random from the rest; the loser of each game picks the next map (a computer picks at random) |
| Factions | Locked for the whole tournament (each computer plays its own faction) |
| Seeding | Random, by the run's dice |
| Start spots | The two players swap start spots game to game |
| Time limit | 20:00 |

**Undecided at the bell.** A game still going at 20:00 is decided by the tournament's own lead rule: each
side's score is the income it earned plus twice its army's value. A side at least 10% above the other wins.
If neither is that far ahead, the game is played again on the same map with new dice. After two replays the
higher score wins. This is the same rule the in-game tool uses for a time limit (docs/tournament.md).

## The field

Sixteen entrants, all Hard. Each faction brings its OPTIMAL computer (the one that scouts and picks from all
its builds), Balanced (the default plan), Economy, a rush, and its own signature build. The Clockwork has the
most builds (10, against the Crown's 8 and the Brood's 9), so it brings a second signature build. That makes
5 Crown, 6 Clockwork and 5 Brood players.

| Faction | Entrants |
|---|---|
| Crown | Optimal, Balanced, Economy, Timing attack, Siege push |
| Clockwork | Optimal, Balanced, Economy, Rush, Owl raids, Heavy Works push |
| Brood | Optimal, Balanced, Economy, Rush, Spitter timing |

Names in the tables are short: "Crown Siege" is the Crown's Siege push, "Clockwork Owls" the Owl raids,
"Clockwork Heavy" the Heavy Works push, "Brood Spitter" the Spitter timing, "Crown Timing" the Timing attack.

## The answer in short

- **Three runs, three different champions, one from each faction.** Run 1: Crown Optimal. Run 2: Brood
  Balanced. Run 3: Clockwork Economy (after winning the grand final from the lower bracket and the bracket
  reset).
- **The factions are close overall**: in games between two different factions the Crown won 45%, the
  Clockwork 52%, the Brood 53%.
- **But each matchup is lopsided, in a circle.** The Crown beats the Clockwork (41-19, 68%). The Clockwork
  beats the Brood (36-10, 78%). The Brood beats the Crown (32-1, 97%). Who wins a championship depends a
  lot on who it meets on the way. Run 1's Crown Optimal never met a Brood player after the first round.
  Run 2's grand final was Brood against Crown, and the Brood won it 2-0.
- **The best entrants over three runs**: Crown Optimal (72% of its games, places 1, 2, 7), Brood Balanced
  (68%, places 5, 1, 5), Clockwork Economy (66%, places 3, 9, 1) and Clockwork Balanced (64%, places 2, 5,
  4). The weakest: Clockwork Rush (20%), Crown Economy (25%), Crown Balanced (26%).
- **OPTIMAL is not always the best plan.** Crown Optimal was the best Crown by far, but Brood Balanced
  beat Brood Optimal, and Clockwork Balanced and Economy beat Clockwork Optimal.
- **Many games reach the bell.** 61% of games ended with a side beaten before 20:00 (at 15:20 at the median),
  39% were decided at 20:00 by the lead rule, and 16 games (of 219 started) had no clear leader at the bell
  and were played again.
- **The Crown wins slowly.** Of its 54 wins, 38 came at the bell: it gets ahead but seldom finishes. The
  Clockwork (56 of 83 outright) and the Brood (51 of 66 outright) finish their games.
- **Series**: 70 of 91 series ended 2-0, 21 went to a third game. One of the three grand finals needed the
  bracket reset.
- **Maps**: no map stood out for a faction beyond what a few games can show. Hollowfen was the Crown's
  worst (4 of 18) and the Brood's and Clockwork's good map; Dune Sea was the Brood's best (10 of 14).

These are the computers' results. They say how the Hard computers play each other, not how the factions
play for people.

## The champions

| Run | Seed | Champion | Runner-up | 3rd | 4th | Grand final |
|---|---|---|---|---|---|---|
| 1 | 101 | Crown Optimal | Clockwork Balanced | Clockwork Economy | Clockwork Heavy | 2-0 (both games at the bell), no reset |
| 2 | 202 | Brood Balanced | Crown Optimal | Crown Timing | Clockwork Optimal | 2-0 for Brood Balanced, the upper bracket's winner, so no reset |
| 3 | 303 | Clockwork Economy | Brood Optimal | Crown Timing | Clockwork Balanced | 2-0 for the lower bracket's Clockwork Economy, then the reset 2-1 |

Brood Balanced won run 2 from seed 15 of 16: the seeding was random, so a seed says nothing about strength.

## Over all three runs

Champions: r1 Crown Optimal, r2 Brood Balanced, r3 Clockwork Economy

Games between two factions (mirrors left out, 64 of them):

| Faction | Won | Played | Win rate |
|---|---|---|---|
| Crown | 42 | 93 | 45% |
| Clockwork | 55 | 106 | 52% |
| Brood | 42 | 79 | 53% |

Matchups (the row's faction's wins against the column's):

| | Crown | Clockwork | Brood |
|---|---|---|---|
| Crown | (12 mirror) | 41-19 (68%) | 1-32 (3%) |
| Clockwork | 19-41 (32%) | (28 mirror) | 36-10 (78%) |
| Brood | 32-1 (97%) | 10-36 (22%) | (24 mirror) |

Each entrant (faction and plan), over every run:

| Entrant | Games won | Played | Win rate | Places |
|---|---|---|---|---|
| Crown Optimal | 23 | 32 | 72% | 1, 2, 7 |
| Brood Balanced | 21 | 31 | 68% | 5, 1, 5 |
| Clockwork Economy | 23 | 35 | 66% | 3, 9, 1 |
| Clockwork Balanced | 25 | 39 | 64% | 2, 5, 4 |
| Brood Optimal | 16 | 30 | 53% | 7, 9, 2 |
| Clockwork Optimal | 16 | 30 | 53% | 9, 4, 7 |
| Crown Timing | 16 | 31 | 52% | 13, 3, 3 |
| Brood Spitter | 11 | 24 | 46% | 7, 5, 13 |
| Brood Economy | 9 | 21 | 43% | 5, 13, 9 |
| Brood Rush | 9 | 21 | 43% | 9, 13, 5 |
| Clockwork Heavy | 10 | 24 | 42% | 4, 7, 13 |
| Clockwork Owls | 6 | 19 | 32% | 13, 7, 9 |
| Crown Siege | 6 | 19 | 32% | 9, 13, 9 |
| Crown Balanced | 5 | 19 | 26% | 9, 9, 13 |
| Crown Economy | 4 | 16 | 25% | 13, 9, 13 |
| Clockwork Rush | 3 | 15 | 20% | 13, 13, 9 |

How games ended: 123 of 203 (61%) by a side beaten before 20:00, 80 (39%) at the bell by the lead rule; 16 games were played again because nobody was clearly ahead at the bell.

Games won outright lasted 15:20 at the median (the quickest 9:19, the slowest 19:45).

| Faction that won | Won outright | Median length | Won at the bell |
|---|---|---|---|
| Crown | 16 | 16:11 | 38 |
| Clockwork | 56 | 14:30 | 27 |
| Brood | 51 | 15:31 | 15 |

Maps (games, and each faction's wins there in games between two factions):

| Map | Games | Crown | Clockwork | Brood | At the bell |
|---|---|---|---|---|---|
| Greenhold | 35 | 7 of 13 | 8 of 17 | 6 of 12 | 15 |
| Dune Sea | 36 | 9 of 19 | 6 of 17 | 10 of 14 | 15 |
| Frostfang | 32 | 5 of 12 | 9 of 15 | 6 of 13 | 10 |
| Ashford Crossing | 32 | 9 of 15 | 9 of 18 | 4 of 11 | 14 |
| Hollowfen | 34 | 4 of 18 | 10 of 15 | 11 of 17 | 12 |
| Cinder Steps | 34 | 8 of 16 | 13 of 24 | 5 of 12 | 14 |

A game took 9:47 of real time at the median on this machine (2 at a time on 2 cores).


## The grand finals, filmed

Each grand final's last game was played again on screen with `tools/shot_ai_match.gd coach:1` (same map,
plans, start spots and dice). A filmed game is a new game: the computers do not play exactly the same
moves, so the result can differ from the bracket's. A few pictures of each are in
`docs/shots/championship_sim/<run>/`.

| Run | Game filmed | In the bracket | On film |
|---|---|---|---|
| 1 | Crown Optimal v Clockwork Balanced, Dune Sea, game 2 | The Crown won at the bell (score 56,890 to 45,031) | The Crown won at the bell: at 20:00 it had 7 halls, a full 200 supply and an army of 4,185 standing 8 tiles from a Clockwork base; the Clockwork had no army left and its income had stopped at 17:51. It did not finish the game. |
| 2 | Brood Balanced v Crown Optimal, Greenhold, game 2 | The Brood won at 16:22 | The Brood won at 19:44 with 127 Raptors |
| 3 | Clockwork Economy v Brood Optimal, Greenhold, the reset's game 3 | The Clockwork won at 12:10 | The Clockwork won at 12:06 |

Pictures: `r1/fight_0619_588_1023.jpg`, `r1/fight_1137_1041_1088.jpg`, `r1/army_1432.jpg`,
`r1/base_0_1802.jpg`, `r1/base_1_1802.jpg`; `r2/fight_0757_2988_1770.jpg`, `r2/fight_1306_2527_1656.jpg`,
`r2/fight_1516_3059_1760.jpg` (the Raptors through the Crown's walls), `r2/base_1_1802.jpg`;
`r3/fight_0941_2795_1673.jpg`, `r3/fight_1123_2542_2052.jpg`, `r3/base_1_1202.jpg`.

## What the owner may want to look at

These are observations only. Nothing in the game was changed for them.

1. **The circle of matchups is strong.** 97% Brood over Crown and 78% Clockwork over Brood are far from even.
   The earlier studies (docs/crown_brood_fix.md, docs/ai_opponent_review.md) saw the same direction.
2. **The Crown does not finish.** 38 of its 54 wins came at the bell. Run 1's grand final on film shows a
   Crown at the supply cap with a large army beside a Clockwork base that had nothing left, not attacking.
3. **The Clockwork's Rush and Owl raids and the Crown's Economy and Balanced plans lose most of their
   games** against this field.
4. **Bracket luck.** With matchups this one-sided, a double-elimination bracket of computers mostly
   rewards whoever avoids its bad matchup. More runs would show each entrant's spread better.

## Claude's choices

1. **The field.** OPTIMAL, Balanced, Economy, a rush and a signature build for each faction, and a second
   Clockwork signature build because it has the most builds. Crown: Timing attack as its rush and the Siege
   push as its signature. Clockwork: Rush, Owl raids, Heavy Works push. Brood: Rush, Spitter timing.
2. **The bell.** The tournament's own lead rule (income earned + 2 x army, 10% ahead), else the game is
   played again with new dice on the same map, at most twice, then the higher score.
3. **Maps.** One ban each, then game 1 random, then the loser picks (at random, as a computer).
4. **Seeding at random**, so seeds mean nothing.
5. **Start spots swapped game to game** inside a series.
6. **Three runs.** Each took 5 to 7 hours on this machine's two cores (a game to 20:00 takes about 10
   minutes of real time). Runs 2 and 3 ran side by side.
7. **The game code was frozen** at the start (commit 462417b06) so the later page work could not change the
   games. The tournament pages added afterwards change no rule a game uses.

## Every run's bracket


### Run r1 (seed 101)

Champion: **Crown Optimal**. 64 games in 30 matches, 6 games played again at the bell.

| Place | Player | Seed |
|---|---|---|
| 1 | Crown Optimal | 6 |
| 2 | Clockwork Balanced | 13 |
| 3 | Clockwork Economy | 9 |
| 4 | Clockwork Heavy | 10 |
| 5 | Brood Balanced | 1 |
| 5 | Brood Economy | 14 |
| 7 | Brood Spitter | 5 |
| 7 | Brood Optimal | 12 |
| 9 | Clockwork Optimal | 3 |
| 9 | Crown Balanced | 15 |
| 9 | Crown Siege | 2 |
| 9 | Brood Rush | 16 |
| 13 | Clockwork Rush | 8 |
| 13 | Crown Economy | 4 |
| 13 | Clockwork Owls | 7 |
| 13 | Crown Timing | 11 |

The bracket, match by match:

| Match | Players | Score | Maps (winner) |
|---|---|---|---|
| Upper round 1 | A Brood Balanced v B Brood Rush | 0-2 | Hollowfen (B), Ashford Crossing (B) |
| Upper round 1 | A Clockwork Rush v B Clockwork Economy | 0-2 | Cinder Steps (B), Hollowfen (B) |
| Upper round 1 | A Crown Economy v B Clockwork Balanced | 0-2 | Hollowfen (B, bell), Dune Sea (B, bell) |
| Upper round 1 | A Brood Spitter v B Brood Optimal | 1-2 | Frostfang (B), Greenhold (A), Cinder Steps (B) |
| Upper round 1 | A Crown Siege v B Crown Balanced | 1-2 | Cinder Steps (A, bell), Greenhold (B, bell), Hollowfen (B, bell) |
| Upper round 1 | A Clockwork Owls v B Clockwork Heavy | 0-2 | Dune Sea (B, bell), Greenhold (B, bell) |
| Upper round 1 | A Clockwork Optimal v B Brood Economy | 2-1 | Ashford Crossing (A, bell), Hollowfen (B), Greenhold (A) |
| Upper round 1 | A Crown Optimal v B Crown Timing | 2-0 | Greenhold (A), Ashford Crossing (A) |
| Upper round 2 | A Brood Rush v B Clockwork Economy | 0-2 | Dune Sea (B), Hollowfen (B) |
| Upper round 2 | A Clockwork Balanced v B Brood Optimal | 2-0 | Dune Sea (A), Cinder Steps (A) |
| Upper round 2 | A Crown Balanced v B Clockwork Heavy | 1-2 | Frostfang (A), Cinder Steps (B, bell), Ashford Crossing (B, bell) |
| Upper round 2 | A Clockwork Optimal v B Crown Optimal | 0-2 | Hollowfen (B, bell), Ashford Crossing (B, bell) |
| Upper round 3 | A Clockwork Economy v B Clockwork Balanced | 2-0 | Ashford Crossing (A), Dune Sea (A) |
| Upper round 3 | A Clockwork Heavy v B Crown Optimal | 0-2 | Greenhold (B, bell), Ashford Crossing (B) |
| Upper final | A Clockwork Economy v B Crown Optimal | 0-2 | Greenhold (B, bell), Frostfang (B, bell) |
| Lower round 1 | A Brood Balanced v B Clockwork Rush | 2-0 | Greenhold (A), Frostfang (A) |
| Lower round 1 | A Crown Economy v B Brood Spitter | 0-2 | Dune Sea (B), Hollowfen (B) |
| Lower round 1 | A Crown Siege v B Clockwork Owls | 2-0 | Dune Sea (A, bell), Cinder Steps (A, bell) |
| Lower round 1 | A Brood Economy v B Crown Timing | 2-0 | Greenhold (A), Ashford Crossing (A) |
| Lower round 2 | A Brood Balanced v B Clockwork Optimal | 2-0 | Cinder Steps (A), Ashford Crossing (A, bell) |
| Lower round 2 | A Brood Spitter v B Crown Balanced | 2-0 | Ashford Crossing (A), Dune Sea (A) |
| Lower round 2 | A Crown Siege v B Brood Optimal | 0-2 | Frostfang (B), Hollowfen (B) |
| Lower round 2 | A Brood Economy v B Brood Rush | 2-0 | Ashford Crossing (A), Frostfang (A) |
| Lower round 3 | A Brood Balanced v B Brood Spitter | 2-0 | Cinder Steps (A, bell), Hollowfen (A) |
| Lower round 3 | A Brood Optimal v B Brood Economy | 0-2 | Greenhold (B), Dune Sea (B) |
| Lower round 4 | A Brood Balanced v B Clockwork Balanced | 0-2 | Greenhold (B), Frostfang (B) |
| Lower round 4 | A Brood Economy v B Clockwork Heavy | 0-2 | Cinder Steps (B, bell), Frostfang (B) |
| Lower round 5 | A Clockwork Balanced v B Clockwork Heavy | 2-0 | Hollowfen (A), Frostfang (A) |
| Lower final | A Clockwork Balanced v B Clockwork Economy | 2-0 | Dune Sea (A), Greenhold (A) |
| Grand final | A Crown Optimal v B Clockwork Balanced | 2-0 | Ashford Crossing (A, bell), Dune Sea (A, bell) |

### Run r2 (seed 202)

Champion: **Brood Balanced**. 69 games in 30 matches, 4 games played again at the bell.

| Place | Player | Seed |
|---|---|---|
| 1 | Brood Balanced | 15 |
| 2 | Crown Optimal | 8 |
| 3 | Crown Timing | 10 |
| 4 | Clockwork Optimal | 12 |
| 5 | Clockwork Balanced | 4 |
| 5 | Brood Spitter | 6 |
| 7 | Clockwork Owls | 9 |
| 7 | Clockwork Heavy | 1 |
| 9 | Brood Optimal | 3 |
| 9 | Clockwork Economy | 5 |
| 9 | Crown Balanced | 2 |
| 9 | Crown Economy | 11 |
| 13 | Brood Economy | 16 |
| 13 | Brood Rush | 13 |
| 13 | Crown Siege | 7 |
| 13 | Clockwork Rush | 14 |

The bracket, match by match:

| Match | Players | Score | Maps (winner) |
|---|---|---|---|
| Upper round 1 | A Clockwork Heavy v B Brood Economy | 2-0 | Greenhold (A, bell), Frostfang (A) |
| Upper round 1 | A Crown Optimal v B Clockwork Owls | 2-0 | Cinder Steps (A), Ashford Crossing (A, bell) |
| Upper round 1 | A Clockwork Balanced v B Brood Rush | 2-0 | Frostfang (A), Cinder Steps (A) |
| Upper round 1 | A Clockwork Economy v B Clockwork Optimal | 0-2 | Frostfang (B), Hollowfen (B) |
| Upper round 1 | A Crown Balanced v B Brood Balanced | 0-2 | Frostfang (B), Hollowfen (B) |
| Upper round 1 | A Crown Siege v B Crown Timing | 0-2 | Frostfang (B, bell), Dune Sea (B, bell) |
| Upper round 1 | A Brood Optimal v B Clockwork Rush | 2-0 | Cinder Steps (A), Greenhold (A) |
| Upper round 1 | A Brood Spitter v B Crown Economy | 2-0 | Cinder Steps (A, bell), Frostfang (A) |
| Upper round 2 | A Clockwork Heavy v B Crown Optimal | 0-2 | Frostfang (B, bell), Cinder Steps (B, bell) |
| Upper round 2 | A Clockwork Balanced v B Clockwork Optimal | 2-1 | Ashford Crossing (A), Dune Sea (B, bell), Greenhold (A) |
| Upper round 2 | A Brood Balanced v B Crown Timing | 2-0 | Hollowfen (A), Dune Sea (A) |
| Upper round 2 | A Brood Optimal v B Brood Spitter | 1-2 | Cinder Steps (B), Dune Sea (A), Hollowfen (B) |
| Upper round 3 | A Crown Optimal v B Clockwork Balanced | 2-1 | Cinder Steps (B, bell), Hollowfen (A, bell), Dune Sea (A, bell) |
| Upper round 3 | A Brood Balanced v B Brood Spitter | 2-1 | Hollowfen (B, bell), Ashford Crossing (A), Frostfang (A) |
| Upper final | A Crown Optimal v B Brood Balanced | 0-2 | Dune Sea (B), Hollowfen (B, bell) |
| Lower round 1 | A Brood Economy v B Clockwork Owls | 0-2 | Ashford Crossing (B), Frostfang (B, bell) |
| Lower round 1 | A Brood Rush v B Clockwork Economy | 0-2 | Hollowfen (B, bell), Ashford Crossing (B) |
| Lower round 1 | A Crown Balanced v B Crown Siege | 2-1 | Hollowfen (A), Greenhold (B, bell), Dune Sea (A, bell) |
| Lower round 1 | A Clockwork Rush v B Crown Economy | 0-2 | Dune Sea (B), Greenhold (B) |
| Lower round 2 | A Clockwork Owls v B Brood Optimal | 2-0 | Greenhold (A), Hollowfen (A) |
| Lower round 2 | A Clockwork Economy v B Crown Timing | 1-2 | Hollowfen (A, bell), Greenhold (B, bell), Ashford Crossing (B, bell) |
| Lower round 2 | A Crown Balanced v B Clockwork Optimal | 0-2 | Cinder Steps (B, bell), Ashford Crossing (B, bell) |
| Lower round 2 | A Crown Economy v B Clockwork Heavy | 1-2 | Dune Sea (A, bell), Hollowfen (B, bell), Greenhold (B, bell) |
| Lower round 3 | A Clockwork Owls v B Crown Timing | 0-2 | Cinder Steps (B), Greenhold (B) |
| Lower round 3 | A Clockwork Optimal v B Clockwork Heavy | 2-0 | Cinder Steps (A), Dune Sea (A) |
| Lower round 4 | A Crown Timing v B Clockwork Balanced | 2-1 | Cinder Steps (B, bell), Greenhold (A, bell), Dune Sea (A, bell) |
| Lower round 4 | A Clockwork Optimal v B Brood Spitter | 2-0 | Ashford Crossing (A), Frostfang (A) |
| Lower round 5 | A Crown Timing v B Clockwork Optimal | 2-1 | Ashford Crossing (B), Cinder Steps (A), Frostfang (A, bell) |
| Lower final | A Crown Timing v B Crown Optimal | 0-2 | Frostfang (B, bell), Ashford Crossing (B) |
| Grand final | A Brood Balanced v B Crown Optimal | 2-0 | Dune Sea (A), Greenhold (A) |

### Run r3 (seed 303)

Champion: **Clockwork Economy**. 70 games in 31 matches, 6 games played again at the bell.

| Place | Player | Seed |
|---|---|---|
| 1 | Clockwork Economy | 2 |
| 2 | Brood Optimal | 1 |
| 3 | Crown Timing | 14 |
| 4 | Clockwork Balanced | 5 |
| 5 | Brood Balanced | 13 |
| 5 | Brood Rush | 10 |
| 7 | Clockwork Optimal | 9 |
| 7 | Crown Optimal | 8 |
| 9 | Clockwork Owls | 11 |
| 9 | Brood Economy | 7 |
| 9 | Crown Siege | 12 |
| 9 | Clockwork Rush | 6 |
| 13 | Crown Economy | 16 |
| 13 | Brood Spitter | 4 |
| 13 | Crown Balanced | 15 |
| 13 | Clockwork Heavy | 3 |

The bracket, match by match:

| Match | Players | Score | Maps (winner) |
|---|---|---|---|
| Upper round 1 | A Brood Optimal v B Crown Economy | 2-0 | Hollowfen (A), Greenhold (A, bell) |
| Upper round 1 | A Crown Optimal v B Clockwork Optimal | 2-0 | Dune Sea (A, bell), Cinder Steps (A) |
| Upper round 1 | A Brood Spitter v B Brood Balanced | 1-2 | Ashford Crossing (B, bell), Greenhold (A, bell), Cinder Steps (B) |
| Upper round 1 | A Clockwork Balanced v B Crown Siege | 1-2 | Frostfang (B, bell), Greenhold (A, bell), Dune Sea (B, bell) |
| Upper round 1 | A Clockwork Economy v B Crown Balanced | 2-0 | Hollowfen (A), Dune Sea (A) |
| Upper round 1 | A Brood Economy v B Brood Rush | 2-0 | Greenhold (A, bell), Frostfang (A) |
| Upper round 1 | A Clockwork Heavy v B Crown Timing | 0-2 | Ashford Crossing (B, bell), Cinder Steps (B, bell) |
| Upper round 1 | A Clockwork Rush v B Clockwork Owls | 1-2 | Dune Sea (A), Ashford Crossing (B, bell), Frostfang (B) |
| Upper round 2 | A Brood Optimal v B Crown Optimal | 2-1 | Ashford Crossing (B, bell), Hollowfen (A), Dune Sea (A, bell) |
| Upper round 2 | A Brood Balanced v B Crown Siege | 2-0 | Dune Sea (A), Hollowfen (A) |
| Upper round 2 | A Clockwork Economy v B Brood Economy | 2-0 | Hollowfen (A), Ashford Crossing (A) |
| Upper round 2 | A Crown Timing v B Clockwork Owls | 2-0 | Ashford Crossing (A, bell), Dune Sea (A) |
| Upper round 3 | A Brood Optimal v B Brood Balanced | 2-0 | Dune Sea (A), Greenhold (A, bell) |
| Upper round 3 | A Clockwork Economy v B Crown Timing | 0-2 | Ashford Crossing (B, bell), Greenhold (B, bell) |
| Upper final | A Brood Optimal v B Crown Timing | 2-0 | Frostfang (A), Greenhold (A) |
| Lower round 1 | A Crown Economy v B Clockwork Optimal | 1-2 | Hollowfen (A), Cinder Steps (B), Frostfang (B, bell) |
| Lower round 1 | A Brood Spitter v B Clockwork Balanced | 0-2 | Hollowfen (B, bell), Ashford Crossing (B) |
| Lower round 1 | A Crown Balanced v B Brood Rush | 0-2 | Ashford Crossing (B), Dune Sea (B, bell) |
| Lower round 1 | A Clockwork Heavy v B Clockwork Rush | 0-2 | Greenhold (B), Cinder Steps (B, bell) |
| Lower round 2 | A Clockwork Optimal v B Clockwork Owls | 2-0 | Frostfang (A), Greenhold (A) |
| Lower round 2 | A Clockwork Balanced v B Brood Economy | 2-0 | Dune Sea (A), Cinder Steps (A) |
| Lower round 2 | A Brood Rush v B Crown Siege | 2-0 | Frostfang (A, bell), Hollowfen (A, bell) |
| Lower round 2 | A Clockwork Rush v B Crown Optimal | 0-2 | Cinder Steps (B, bell), Hollowfen (B) |
| Lower round 3 | A Clockwork Optimal v B Clockwork Balanced | 0-2 | Frostfang (B), Greenhold (B) |
| Lower round 3 | A Brood Rush v B Crown Optimal | 2-0 | Hollowfen (A), Cinder Steps (A) |
| Lower round 4 | A Clockwork Balanced v B Brood Balanced | 2-1 | Frostfang (A), Dune Sea (B), Cinder Steps (A) |
| Lower round 4 | A Brood Rush v B Clockwork Economy | 1-2 | Cinder Steps (A), Dune Sea (B), Greenhold (B) |
| Lower round 5 | A Clockwork Balanced v B Clockwork Economy | 0-2 | Frostfang (B), Ashford Crossing (B) |
| Lower final | A Clockwork Economy v B Crown Timing | 2-0 | Cinder Steps (A, bell), Frostfang (A, bell) |
| Grand final | A Brood Optimal v B Clockwork Economy | 0-2 | Hollowfen (B, bell), Cinder Steps (B) |
| Grand final (reset) | A Clockwork Economy v B Brood Optimal | 2-1 | Cinder Steps (A), Dune Sea (B, bell), Greenhold (A) |


