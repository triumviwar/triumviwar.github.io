# Tournament types and the map pool picker

Job `tournament-formats`, branch `tournament-formats`. The owner's report (2026-11-28): TOURNAMENTS only offered
1v1 maps. He asked for (1) a TYPE of tournament (1v1, 2v2 with fixed or drawn teams, and whatever else the game's
matches support), working in every format, online, offline and all computer; (2) any map in the pool, also a bigger
map for a smaller type; (3) an organised map pool picker instead of one long list of tick boxes.

This page adds to `docs/tournament.md` (the tournament system of 0.38.208).

## What was enabled, and what was not

| Type | Enabled | Why |
|---|---|---|
| 1v1 | yes | as before |
| 2v2 | yes | the skirmish takes up to 8 players; the classic maps (four corners) and the named 2v2 maps hold 4 |
| 3v3 | yes | the named 3v3 and 4v4 maps hold 6; the computers play team games in the skirmish already |
| 4v4 | yes | the named 4v4 maps hold 8 (`Main.MAX_SLOTS` 8). Online a 4v4 room is the host and 7 guests, exactly what a relay room seats, so a 4v4 match room has no place left for spectators |
| Free-for-all (3 or 4) | **no** | The game plays free-for-all fine, but the tournament does not fit it: every format is built on two-sided matches (a match has sides "a" and "b"; elimination brackets send one winner and one loser on; Swiss pairs two; the series, the map bans and picks, the reports, disputes, head to head and the time limit's lead rule all compare two sides). A free-for-all tournament needs another shape (heats with points per place, then a final heat). Left out rather than forced into a bracket. |

Mixed sizes (2v1) are not offered: a tournament is fair only when both sides have the same number of players.

## How a team works

A team is one entry of the bracket. The bracket itself does not change at all: a side of a match is still one entry,
so every format (single and double elimination, round robin, Swiss, groups then playoffs), byes, the reset, the
standings, tie-breaks, walkovers, drops and the export code work for teams as they did for players.

Inside, the entry has `members`: `[{"name", "faction", "who", "plan", "key", "pid"}]`, one game slot each. Its
`faction` is the members' joined ("crown,brood"), shown as "Crown + Brood".

| | Fixed teams | Drawn teams |
|---|---|---|
| Online | A player types its name, its faction and its TEAM's name on JOIN. The first one with a name makes the team; the next ones join it. A full team refuses more. | Everyone signs up alone. |
| Offline | The organiser types a team's name and each player's name and faction (ADD THE TEAM). | The organiser adds the players one by one. |
| All computer | ADD A COMPUTER TEAM (every member the chosen faction, plan and level) or FILL WITH A FIELD OF 8 TEAMS (the championship field's plans dealt round, so the teams mix factions). | as fixed |
| At the start | Every team must be full. | The tournament's dice shuffle everyone and deal teams of 2, 3 or 4, named Team 1, Team 2... The number of players must divide by the team size. The same seed draws the same teams. |

A person is known by its own secret key, not by the entry's id (a drawn team's members get a new entry at the start;
the desk finds them by the key: `Tournament.member_by_key`). The desk tells a player's game its team's id and its
place in the team (`mi`), saved on the device with the key.

Check-in: a team is checked in when every person in it is. Leaving before the start takes the player out of its team
(an empty team goes); leaving after the start drops the whole team (its matches are walkovers).

### Factions

In a team tournament every player keeps the faction it joined with, whatever the FACTIONS rule says (the rule is set
to "Locked for the whole tournament" at the start). A player who joined with Random gets one by the match's dice, the
same each time it is asked. The per-game choosing of the 1v1 rules (free, series, once) was not carried over to teams:
it would need every member to choose before every game, from its own device, through the desk.

### The game

`Tournament.game_slots(match, swap)` gives the game's slots: side a's members, then side b's (b's first when the
start spots are swapped in a series), each with its faction, plan, level, its own colour, and the team as the game's
side (0 or 1), so allies sit together.

At the time limit a team's score is its players' scores added (income earned + twice the army), and the 10% lead rule
compares the two teams.

### Online

The match room: side a's first player hosts it from the bracket (`NetLobby.tour_setup`: the slots, the map and the
factions, locked). Everyone else presses PLAY YOUR MATCH and joins with the seat the bracket gives it
(`NetLobby.tour_seat`, sent in its "hi"); the host seats it there, in whatever order they come. Online the start spots
are not swapped between games (the host is always slot 0), as for 1v1.

Results: as for 1v1, but any member speaks for its team: a losing team's member saying it lost is enough; a winning
team's member alone waits for the other team or the organiser; two teams both saying they won is a dispute.

Your own editor maps cannot be used online (the other players don't have the file; the friendly room refuses them
too). The picker greys them out in an online tournament.

## Maps: any map that holds the type

A map can go in the pool when it holds both sides (`Tournament.map_holds`: its players >= 2 x the team size). A bigger
map is fine: only as many start spots as the type needs are used, the rest are free expansions.

Which spots are used, by kind of map:

| Map | How the spots are chosen | Fair because |
|---|---|---|
| Named (built-in) maps | The map's own pairing: each map is a point mirror, every main has a twin. Team a takes mains on one side, team b their twins in the same order (`MapGen.spot_order`, unchanged). A 1v1 on a 4v4 map: a main and its exact mirror. | mirror twins |
| Classic maps | 2 players: the two opposite corners; 3-4 players: the four corners, allies on one side (unchanged). | the classic maps are folded mirrors |
| Your own maps | The map's own teams: allies in one of its start groups, as in the skirmish. NEW (`MapGen.fair_spot_order`): when the map has more start groups than the match has sides (a 1v1 on a free-for-all map of 4), the sides take the groups that lie farthest apart (the choice whose two closest groups are farthest, by the groups' middles), not the first ones in the file. When the map has just enough groups, its own pairing is used. | as fair as the map you drew |

`fair_spot_order` is used by the skirmish too (the lobby's picture and the match), so a 1v1 on your own free-for-all
map now puts the two players in opposite corners there as well.

## The map pool picker

MAKE A TOURNAMENT's MAP POOL is no longer one bundled list of tick boxes:

* **Players:** ALL / 2 PLAYERS / 4 PLAYERS / 6-8 PLAYERS, and the cards are grouped under 2-PLAYER MAPS, 4-PLAYER
  MAPS, MAPS FOR 6-8 PLAYERS.
* **Where from:** ALL / BUILT-IN (the named maps) / CLASSIC (the generated ones) / YOUR MAPS (the map editor's).
* **Search:** a box (FIND, or Enter) that matches the map's name.
* **Cards:** each map a card with its picture and the start spots this type would use (numbered by side), its name,
  players, size, and where it comes from. A tap puts it in the pool (green edge) or takes it out. A map that can't
  hold the type is greyed ("holds 2 players"); so is your own map in an online tournament.
* ADD ALL SHOWN puts every map the filters show (that fits) in the pool; CLEAR THE POOL empties it. The line above
  says how many maps are in and what the type needs.
* Changing the TYPE redraws the cards (pictures with the new spots, the maps that no longer fit greyed). Maps that
  don't fit are left out when the tournament is made; if none is left, the first six that fit are used.
* A tournament made in code without a pool of its own (`Tournament.make`) takes the default pool's maps that hold its
  type, else the built-in ones that do.

### The picture on the card: MapPreview

The job `map-previews` (a shared MapPreview widget showing a map's real minimap) was not on `origin/main` and had no
branch on origin when this job ran. So the card's picture goes through ONE function, `TournamentPage.map_picture(id,
team_size)`, which today returns the skirmish lobby's own picture (`Main.make_map_preview`: the painted preview of a
named map from `assets/maps`, the editor's saved picture of your map, a sketch of a classic one) with the start spots.
When MapPreview is merged, only `map_picture` changes.

## Screens

MAKE A TOURNAMENT has TYPE (1v1, 2v2, 3v3, 4v4) and, for teams, TEAMS (fixed / drawn). The page's line under the title
starts with the type. The PLAYERS tab of a team tournament is TEAMS: each team with its members (faction, person or
computer, checked in) under it; the organiser's REMOVE / DROP act on the whole team. JOIN has a TEAM field (used only by
team tournaments). A match card lists each team's members and factions; standings and places show a team's factions
("Crown + Brood"); THE FACTIONS' GAMES counts each member's faction. RULES shows the type and how teams are made.

## Tests

| Test | How | What it checks for this job |
|---|---|---|
| `tools/test_tournament.gd` | `godot --headless --script res://tools/test_tournament.gd` | 694 checks now (all the old ones pass). New: 2v2, 3v3 and 4v4 fixed teams in all five formats played to a team champion; join_team by name (any case), a full team, a short team can't start, a team's factions, a member known by its key, no member keys sent, leaving a team, an empty team going, a map too small refused; drawn teams (8 into 4 teams of 2, everyone in one team, known again by key, the organiser who plays follows into its team, 5 can't split, 3v3 of 12, the same seed draws the same teams); the game slots (sides, colours, factions rolled for Random, plans and levels, the swap); a 1v1 on a 4v4 map using a main and its mirror; a team member's report waiting, the other team's agreeing, a wrong key; the time rule by team score; a 1v1 on a free-for-all custom map taking opposite corners, a 1v1 on a 2v2 map one start of each team, a 2v2 unchanged. |
| `tools/test_tournament_play.gd` | `godot --headless --script res://tools/test_tournament_play.gd [-- only:2]` | The 1v1 run as before, then a 2v2 all-computer double elimination run from its page with PLAY EVERY GAME QUICKLY: each game a real 4-player match (two sides of two), to a team champion, every game with its replay and the team's factions. 28 checks, all pass. (Godot aborts at `quit()` with exit code 134 after printing; it does the same on main without this job.) |
| `tools/test_tournament_online.gd` | `tools/test_online.sh tournament` | The 1v1 part as before, then a 2v2 online tournament on the local relay: four players join two teams by name, a fifth is refused by a full team and without a team's name, the start, the match's room set by the host from the bracket with each of the three guests (arriving out of order) in its own seat, two sides of two, each member's faction, a faction change refused, four slots to start; a team-mate's report waits, the other team's member agreeing makes the champion. 48 checks, all pass. |
| `tools/shot_tournament_formats.gd` | `xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 --script res://tools/shot_tournament_formats.gd -- docs/shots/tournament_formats [pc\|mobile]` | the pictures below |
| Boot | `godot --headless --path . --quit-after 120` | no SCRIPT ERROR / Parse Error |

## Pictures

`docs/shots/tournament_formats/` (desktop, and `_phone` for a phone held sideways): MAKE A TOURNAMENT with TYPE (01),
the map pool's cards (02 all, 03 the 4-player maps, 04 for 6-8 players, 05 a search, 06 a 2v2's greyed 2-player maps),
a 2v2 all-computer double elimination half played (07 bracket, 08 a match card with the teams' members, 09 teams, 10
standings), a 2v2 online tournament at sign-up (11), drawn teams before and after the draw (12, 13), a 3v3 round robin's
standings (14).

## Claude's choices (for the owner to confirm or change)

1. **No free-for-all.** The engine plays it, but every tournament format here is two-sided (see the first table).
   A free-for-all tournament (heats with points) would be its own job.
2. **Teams keep their factions.** In a team tournament the FACTIONS rule is set to "locked for the whole tournament";
   each player plays the faction it joined with (Random rolled by the match's dice). Choosing before every game for
   every member was left out.
3. **Team names.** Fixed teams are joined by typing the same team name (any case); the first player makes the team.
   There is no captain: any member can ban, pick and report for the team.
4. **Drawn teams are named Team 1, Team 2...** by the draw; the draw happens when the organiser presses START (with
   the tournament's own dice, so it can't be redrawn by pressing again). A "draw now, look, redraw" button was left out.
5. **Who hosts a team's match room:** side a's first player (the first to join its team, or the first drawn).
6. **Computer teams** (ADD A COMPUTER TEAM) are one faction, plan and level for every member; FILL WITH A FIELD OF 8
   TEAMS deals the championship field's plans round so teams mix factions. A mixed team can be made in code
   (`add_team`), not yet from one row of buttons.
7. **The time limit by team:** the players' scores added, the same 10% lead rule.
8. **A bigger map is allowed for a smaller type** (a 1v1 on a 4v4 map); the unused mains are free expansions. The
   owner may prefer to forbid maps much bigger than the type; nothing stops it today.
9. **Your own maps** are offered in offline and all-computer tournaments only.
10. **Custom maps with more start groups than sides** now use the groups farthest apart, in the skirmish too.
11. **The map picture** is the lobby's own until the map-previews job's MapPreview is merged (one function to swap).
12. **The relay's 7 guests:** a 4v4 match room is full with its players; spectators can't join it. Raising the relay's
    limit is the owner's redeploy.
