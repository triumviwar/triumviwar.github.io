# Tournaments

Job `tournament`, branch `tournament`. The owner asked on 2026-11-24:
"SC2 and other RTS have to use Challonge and other outside tools, let's have an in-game tool."

This page says what the tool does, how to use it, how it works inside, how it is tested,
and the choices Claude made that the owner may want to change.

TYPES (2v2, 3v3, 4v4 teams, fixed or drawn) and the organised MAP POOL picker came later: `docs/tournament_formats.md`.

## In one paragraph

The main menu has a new button, TOURNAMENTS. From there you make a tournament, join one with a code,
or open one you made before. A tournament has a bracket that the game draws. Players play their matches
from the bracket. The games report their own results. The bracket moves on by itself.
At the end the champion gets a trophy. It works online, offline, or with computer players only.

## What it can do

| Part | What you get |
|---|---|
| Formats | Single elimination. Double elimination (the lower bracket's winner must beat the upper one twice: a bracket reset). Round robin. Swiss. Groups, then single-elimination playoffs. |
| Size | 2 to 64 players. Byes go to the top seeds. |
| Series | Best of 1, 3, 5 or 7. The final can have its own length. |
| Maps | A pool of maps you tick. Three map rules: random from the pool; each player bans one, then random; each player bans one and the higher seed picks game 1. Then either the loser of a game picks the next map, or random. A map already played in the series is not picked again while others are left. |
| Factions | Free (pick before every game). Locked for a series. Locked for the whole tournament (picked when you join). Each faction once in a series. |
| Seeding | Random, or by hand (move players up and down the list). |
| Check-in | Optional. Players who did not check in are left out when the organiser starts. |
| Time limit | None, 15, 20 or 30 minutes. At the bell the side clearly ahead wins (see below). |
| Results | Reported by the games themselves online. By hand offline. Disputes go to the organiser. |
| Organiser tools | Set a result. Give a walkover. Accept a lone report. Drop a player. |
| Replays | Every tournament game's replay is kept (never pruned) and linked from its match. |
| Spectators | WATCH on a match joins its room as a spectator, even when the match is under way. |
| Screens | A drawn bracket you can drag and zoom (wheel, pinch, or + and -). Standings. Schedule. Players. Rules. The champion's trophy. Desktop and phone. |
| Languages | English, Portuguese and Spanish. |

## The three kinds of tournament

**Online.** Players join with the tournament's code. There is no new server. The organiser's game is the
tournament's "desk". It opens a room on the same relay the friendly rooms use. Its code is "T" and the
tournament's five letters. A player's game calls at the desk for a moment, says what it has to say, gets the
whole bracket back, and hangs up. Calls are: join, check in, leave, ban a map, pick a map, choose a faction,
report a game, or just look. The relay seats only 7 guests in a room at once. Because each call is short, 64
players can share it. A call that finds the room full waits two seconds and calls again.

A player's place is kept by a secret key the desk gave it when it joined. The key is saved on the player's
device. So the desk knows the player again from another connection. The bracket that goes to the players
never carries anyone's key.

Each match is played in a normal friendly room. PLAY YOUR MATCH makes it. The higher seed hosts. The room's
code comes from the bracket, so the other player's PLAY YOUR MATCH finds it. The room already has the
bracket's map and factions. Nobody can change them there. Anyone can press WATCH on that match to join as a
spectator.

When the game ends, both players' games send the result to the desk.

| What the desk hears | What happens |
|---|---|
| The loser says it lost | Taken at once. |
| The winner says it won, the loser agrees | Taken. |
| The winner says it won, the loser says nothing | It waits. The organiser can ACCEPT THE REPORT. |
| Both say they won | A dispute. The match shows it in red. The organiser sets the result. |

A player can also press I WON THIS GAME or I LOST THIS GAME on the match card, in case the game's own report
was lost.

The organiser can play in their own tournament too: ADD MYSELF on the PLAYERS tab.

**Offline / LAN.** Nobody joins over the internet. The organiser types the players' names and enters each
game's winner on the match card. The players play on their own devices, in a skirmish or a friendly room.

**All computer.** The organiser adds computer players by faction, plan and level, or presses FILL WITH A FIELD
OF 16 (the championship simulation's field). Each game can be watched (WATCH THIS GAME) or played quickly
(PLAY IT QUICKLY: the picture is covered and the game runs four times as fast). PLAY EVERY GAME QUICKLY plays
every game, one after another, until there is a champion. STOP AFTER THIS GAME stops it.

## How to run one

1. Main menu, TOURNAMENTS, MAKE A TOURNAMENT.
2. Give it a name. Choose the kind, the format, the series, the maps and the rules. Press MAKE IT.
3. On the PLAYERS tab, add players (offline, all computer) or tell your friends the code (online).
   For online, keep the game open while they join: your game is the desk.
4. Press START THE TOURNAMENT. The bracket is drawn.
5. Tap a match on the bracket to open its card. It says whose turn it is to ban or pick, and who has to
   choose a faction. Then PLAY YOUR MATCH (online), the winner's button (offline), or WATCH THIS GAME
   (all computer).
6. When the last match is over, the champion's screen comes up.

To join: TOURNAMENTS, type the code and your name, choose a faction, press JOIN. Or press WATCH to follow it
without playing. Your joined tournaments are listed on the TOURNAMENTS page.

## Keeping it safe

The tournament is saved on the organiser's device after every change. The RULES tab has its file code
("TOUR1:..."). Paste it on the TOURNAMENTS page to open it on another device. That device becomes the
organiser. This is how a tournament survives the organiser's game closing, or a new organiser taking over.

## The time limit's rule

When a time limit is set, at the bell each side gets a score: the income it has earned plus twice its army's
value. A side whose score is at least 10% above the other's wins the game. If neither is that far ahead, the
game is played again on the same map with new dice. After two replays, the higher score wins. The match card
says "at the time limit" for a game decided this way.

## Inside

| File | What it is |
|---|---|
| `scripts/tournament/tournament.gd` | `Tournament`: the bracket. Formats, byes, series, maps, factions, reports, walkovers, standings, tie-breaks, places. All of it is one dictionary that can be saved, sent and exported. No screen, no network. |
| `scripts/tournament/tournament_net.gd` | `TournamentNet`: the desk (organiser) and a player's calls. Uses `NetLink` and the relay. |
| `scripts/tournament/tournament_page.gd` | `TournamentPage`: every page, the match card, the champion, and the games started from the bracket (`TourWatch` keeps the time limit and the quick speed). |
| `scripts/tournament/bracket_view.gd` | `BracketView`: the bracket drawn, with drag, zoom and pinch. |
| `scripts/main.gd` | The menu button, `tour_game` (the tournament game being played), `tour_desk` (the organiser's desk), `_tour_back`, the end of a game going back to the tournament. |
| `scripts/net/net_lobby.gd` | `tour` and `tour_lock`: a room made from the bracket keeps its map and factions. |
| `tools/tournament_cli.gd` | The bracket from the command line (used by the championship simulation). |
| `tools/i18n/83_tournament.txt` | The Portuguese and Spanish texts. |

Tie-breaks in a table (round robin, Swiss, groups): match wins, then (Swiss only) Buchholz (the match wins
of everyone you played), then game difference, then games won, then head to head, then the seed.

Swiss pairings: round 1 is the top half against the bottom half. After that, players are paired down the
standings with the next player they have not met. If that is impossible, one rematch is allowed. With an odd
number of players, the lowest-placed player who has not had a bye gets one. Rounds: as many as it takes to
halve the field down to one (4 rounds for 16 players), unless set.

Double elimination: the losers of each upper round drop into the lower bracket. Every other drop-in round is
reversed so two players do not meet again at once. 16 players make 15 upper matches, 14 lower matches, a
grand final and its reset.

## Tests

| Test | How to run | What it checks |
|---|---|---|
| `tools/test_tournament.gd` | `godot --headless --script res://tools/test_tournament.gd` | 483 checks of the bracket logic: every format with odd and even fields up to 64, byes, the reset, random results to the end, Swiss without rematches or double byes, tie-breaks, groups into playoffs, bans and picks, faction rules, reports, disputes, walkovers, a changed result, the time rule, a dropped player, check-in, the export code. |
| `tools/test_tournament_online.gd` | `tools/test_online.sh tournament` | A local relay, the desk and ten players in one process: ten join at once (the room holds 7), a name twice and a wrong key refused, check-in, a player leaving, bans, factions, both reports, the loser's report alone, a dispute, someone else's match refused, a spectator's look, a game's own report reaching the desk, and a match's room with the bracket's map and factions that nobody can change, plus a spectator joining it. 29 checks. |
| `tools/test_tournament_play.gd` | `godot --headless --script res://tools/test_tournament_play.gd` | An all-computer tournament run from its page with PLAY EVERY GAME QUICKLY: real games, the time limit, results and replays on the bracket, back on the page at the end. |
| `tools/shot_tournament.gd` | `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_tournament.gd -- <dir> [pc\|mobile] [pt\|es]` | Walks through the pages pressing their buttons and takes the pictures in `docs/shots/tournament/`. |
| `tools/test_menu_grid.gd` | as before | The menu's slot order now has TOURNAMENTS in row 3, column 3. |

## Pictures

`docs/shots/tournament/`: the menu, the list, MAKE A TOURNAMENT, a double elimination half played (whole
and zoomed), a match card, the tabs, the champion, groups, Swiss, an online tournament at sign-up and started.
The same with `_phone` for a phone held sideways.

## Claude's choices (for the owner to confirm or change)

1. **The menu button.** TOURNAMENTS sits in row 3, column 3 of the main menu, beside WORLD WAR. The task said
   "main menu or ONLINE menu". The main menu was chosen because offline and all-computer tournaments are not
   online.
2. **No new server.** The organiser's game is the desk, on the existing relay. The cost: the organiser's game
   must be open while players join, report and look. If it closes, players wait. The file code lets someone
   else take over.
3. **Short calls instead of staying connected.** A player's game calls the desk and hangs up. Its page asks for
   news every 10 seconds. This is because a relay room holds only 7 guests. Changing the relay to hold more
   would mean redeploying it, which only the owner can do.
4. **Who hosts a match.** The higher seed (the first name in the match) always hosts its room. Online, the
   start spots are not swapped game to game; the parity maps are mirrors.
5. **Reports.** The loser's word is enough. The winner's word alone waits for the loser or the organiser.
   Two different words make a dispute. Leaving a game before its end records nothing; the players or the
   organiser then report by hand.
6. **The time limit's rule.** Income earned plus twice the army, 10% ahead wins; otherwise replay, at most
   twice, then the higher score. This is the score the AI studies use for "won or led". The game had no lead
   rule of its own.
7. **Computers ban and pick maps at random**, by the tournament's own dice. A computer has no favourite map.
8. **Computer players only in all-computer tournaments.** In online and offline tournaments a person plays
   every match. A person against a computer would need one device to play the computer's side; that was left
   out.
9. **Quick play is four times as fast with the picture covered**, the most the sandbox already uses. True
   headless play inside the game is not possible; the championship simulation uses separate headless
   processes instead.
10. **Replays stay on the device that played them.** The bracket stores the replay's name. On another device it
    says "replay on a player's device". Sending replays to the organiser was left out (they can be large).
11. **Byes go to the top seeds** in elimination brackets, by the standard seeding order (1 v 16, 8 v 9...).
12. **Swiss tie-breaks put Buchholz before game difference.** Round robin and groups skip Buchholz.
13. **Groups use snake seeding** (1 2 3 4 / 8 7 6 5 ...). Playoffs cross the groups, so two group winners can
    only meet in the final when there are two groups.
14. **A finished result can be changed** only while no match after it has been played.
15. **The tournament's log lines** ("X bans Y", "X 2-1 Y") stay in English in the RULES tab's WHAT HAPPENED.
    The rest of the pages are translated.
16. **The trophy is drawn in code** (a gold cup with the champion's faction colour on the plinth). A painted
    trophy from ChatGPT could replace it. Added to the list of code-drawn art below.

## Code-drawn art

The champion's trophy (`TournamentPage.Trophy`) and the bracket's boxes are drawn in code. The trophy is a
candidate for a painted picture later (the owner's ChatGPT art), as with the other code-drawn pieces in
`docs/art_style_inconsistency.md`.
