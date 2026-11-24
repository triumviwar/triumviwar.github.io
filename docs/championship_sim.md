# The championship simulation

Job `tournament`, branch `tournament`. The owner asked on 2026-11-24: "make a championship simulation so we see."

Sixteen computer players played a full double-elimination championship, best of 3, games to 20:00, on the six
parity maps with map bans. It was run RUNS_DONE times with different dice. This page has the brackets, the
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

RESULTS
