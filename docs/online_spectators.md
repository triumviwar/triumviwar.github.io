# Online spectators (0.38.21)

The owner's request (2026-11-15 20:30): "Online, make sure we can join an online game and become a spectator to the
game; also the spectator gets the replay as well. Maybe in faction we can choose SPECTATOR and then we are moved down to
a different group so we don't clutter the players up there in the lobby."

Job online-spectators, branch `online-spectators`. Friendly rooms (room codes through the relay) only; ranked is below
under "What is left".

## What a player sees

**The room (MULTIPLAYER page, `scripts/ui/multiplayer_menu.gd`)**

- A guest's own FACTION list ends with **SPECTATOR (WATCH)**. Picking it frees the guest's seat (it shows "waiting..."
  again) and moves the guest down to a group of its own under the players: **SPECTATORS (n)**, one row each:
  "SPECTATOR 2" (yours reads "YOU (SPECTATOR)"), its ping to the host, and "watching: every side, no orders".
- A spectator takes a seat back with **TAKE A SEAT** (a faction list on its own row, shown while a player's seat is
  free).
- **WATCH** beside JOIN on the ONLINE page joins as a spectator straight away, even with a seat free. A plain JOIN into a
  room whose seats are all taken also seats the friend as a spectator (it used to say "The room is full").
- Spectators don't count against the map's player count and don't stop START: the host starts as soon as the players'
  seats are filled, as before.
- The host's map column has **SPECTATORS TALK TO PLAYERS: OFF** (its choice; see chat below).
- Joining a match already under way: WATCH (or JOIN) with the room's code while the match runs puts the friend straight
  into it as a spectator (the room has no seat to give any more).

**In the match**

- The spectator's game is a puppet like a guest's that plays nobody (`game.net_watch`, `game.demo`, so
  `game.spectating()`): the watching tools of a computers' match: **VIEW** (free, all vision, a player's vision,
  follow a player), **PRODUCTION**, **ARMY & STRUCTURES**. No **AI STORY** (the computers think on the host; the panel
  is left out, not shown empty), no command card, no PAUSE / RESUME / SURRENDER in the menu, no 3-2-1.
- It sees every side: the host sends it pictures with no fog filter (`NetView.spectator`).
- Anything it orders is refused by the host ("You are watching: spectators give no orders.").
- It leaving changes nothing: no "your friend left", no computer takes a seat, no pause.
- The end shows it the battle report (as a watched match: "watched", no victory or defeat).
- After the end the host's whole replay comes to it as to the players, and replaces its own record.

## How it works (code)

| Part | Where |
|---|---|
| The room: `specs` ([{peer, n}] on the host, [{n, ping}] on a guest), `SPEC_MAX` 4, `spectating`, `my_spec`, `want_spec` (WATCH), `spec_talk`, `is_spec`, `_add_spec`, `_drop_spec`, `spec_peers`, `spec_no`, `set_spec_talk`; "hi" seats a spectator when no seat is free or it asked; "set" `{"spec": true}` frees the seat, a faction from a spectator takes a free seat; "lobby" carries `specs`, `spec` (your number), `talk`; a spectator leaving the room is dropped from the group | `scripts/net/net_lobby.gd` |
| The start: the spectators get `_guest_cfg(cfg, -1)` (every human "remote", no "you": so `human` -1, `demo`), with `"team": -1, "spec": n`; the same start is kept (`late_cfg`) for one who knocks later (`_late_hi`) | `net_lobby.gd` `begin`, `_start_spec`, `_late_hi` |
| The host's session: `spec_peers` (relay id -> n), `add_spectator` / `drop_spectator`, one `spec_view` for all spectators appended to `side_views()` (sides empty, `spectator` true: `view_eyes()` is [] = sees all; its `peers` are the spectators' relay ids only); a new spectator resets it, so its first picture is whole (every row of a view that has been sent nothing goes out in full); `"cmd"` from a spectator is refused ("spectator"); `"ready"` from a late one gets GO and the pause state; `"chat"` from one is passed on by `chat_out`; `send_replay` counts spectators; the relay's "leave" for one only drops it; `spec_bytes` / `player_bytes` count the upload | `scripts/net/net_session.gd`, `scripts/net/net_view.gd` |
| The spectator's session: `watch_only(n)`: `watching`, `my_team` -1, `game.net_watch`, `game.net_spec_no` | `net_session.gd` |
| Chat: `Chat.post(team, text, from, spec_n)` (team -1, "SPECTATOR n" / "YOU (SPECTATOR)"), `player_say` on a spectator posts as one; the HUD shows and takes chat for an online spectator, their lines in grey-blue | `scripts/chat.gd`, `scripts/ui/hud.gd` |
| The panels without an AI STORY | `scripts/ui/spec_panels.gd` `_layout`, `hud.gd` "spec story" |
| The spectator's own record: a guest's (its own ids for anything unnumbered) but of every side (`ReplayRecorder.all_sides`, header `"online": "spectator"`, `view_only` false); the host's whole replay replaces it when it comes | `scripts/replay/replay_recorder.gd`, `scripts/main.gd` |

The players' pictures are untouched: each player's side still gets its own fog-filtered `NetView`, and the spectators'
view is never in a player's `peers` (`tools/test_net_fog.gd` checks both; the broadcast to relay id 0 is only used when
one view goes to everyone there: one side's guests alone, or the spectators alone).

Side fix: a guest's start now carries the host's TURNING GEARS rule (`gear_turn`); a guest used to take its own setting.

## Choices for the owner (Claude's, say if any is wrong)

1. **The host always plays.** Its device runs the match, so in a friendly room it keeps its seat (a match nobody plays
   on the hosting device is what the ranked match server is: a dedicated host). A room still needs a player guest to
   start (`problem()`): a "the host plays the computer, friends only watch" room is not possible yet; say if wanted.
2. **At most 4 spectators** (`NetLobby.SPEC_MAX`): each costs the host's upload as much as a player (below).
3. **Chat: spectators talk among themselves by default.** A player never sees a spectator's line (the host doesn't
   either: it is a player). The host can turn **SPECTATORS TALK TO PLAYERS** on; then their lines go to everyone.
   Players' and computers' lines always reach the spectators. A spectator's line only to the spectators is not kept in
   the players' replay.
4. **No delay for spectators.** They see the match as the players do (about the same lag as a guest). A friend could
   still tell a player what it sees by another channel (a call); tournaments add a delay of a minute or two. Proposal
   if wanted: a room option SPECTATOR DELAY (0 / 30 / 120 s), the host holding the spectators' pictures that long.
5. **A spectator sees each side's resources and battle report** (the spectators' view is never "strict"), as when
   watching computers.
6. **No AI STORY** for an online spectator (the computers' thinking happens on the host; sending their story lines is
   possible later: they already go into the host's replay).
7. **No spectators in a CAMPAIGN room** (the mission's story and choices are for its two players); a full campaign room
   still says "The room is full".
8. **Joining a match under way** is in: the late spectator gets the start, then a whole first picture (all spectators
   get one whole picture again at that moment, a few KB once).
9. A spectator's PAUSE / RESUME are not offered (only the players pause; a spectator sees the pause banner).

## Bandwidth (the host's upload, loopback test)

`tools/test_online.sh spectators` with the host's computers playing both sides (`HOST_ARGS=ai`), host + 1 guest player
+ 2 spectators (one joining the match under way), hollowfen, measured on the host while both spectators watched:

| Moment | To the player | To each spectator | Host upload, all |
|---|---|---|---|
| 79-143 s of play, 27 units on the field | 9.5 KB/s | 11.3 KB/s | 32.4 KB/s |
| (the plain test, no computers, 4 units a side, 2 spectators) | 6.0 KB/s | 6.5 KB/s | 19.2 KB/s |

A big battle, from `tools/bench_net_snapshot.gd -- at:180 window:10 spawn:100` (two Hard computers plus 100 Musketeers
and 100 Raptors, half of them marching across the map: 239 units, its pictures are built with no fog filter, which is
exactly a spectator's picture): **4.3 KB a picture on average (6.9 KB at most), about 40 KB/s per spectator** at the
host's adaptive rate (`NetSession.SNAP_BYTES` 40 KB/s per view caps it: past that the pictures come less often). A
player's own picture in the same fight is smaller (only what its side sees).

A spectator's picture is every side's: it costs about as much as a player's in the opening and up to the two players'
pictures together once both armies are out (it holds both). Each spectator gets the same picture (one is built for all of
them; the relay can't fan one message out to a list, so the host sends it once per spectator). With 2 spectators the
host's upload roughly triples against a 1 v 1 alone; a phone host on a mobile uplink is where this would bite first
(`NetSession.UPLINK_MAX`: the next picture waits while 48 KB are still on their way out, for everyone).

## Tests

- `tools/test_online.sh spectators` (new, `tools/test_online_spectators.gd`): host, a guest who plays, spectator 1
  (joins, takes the seat, picks SPECTATOR: moved to the group, the seat free again), the guest takes the seat, START;
  spectator 2 WATCHes the match under way (whole first picture, every unit), chats, leaves. Checks: the room lists the
  spectator apart and START is allowed; the spectators see both halls at the start while the player's picture hides
  the enemy's (and the host's `fog_audit` of every player picture finds no leak); a forged spectator order is refused
  with its reason; the spectators hear the player, the player and the host never hear the spectators; a spectator
  leaving changes nothing (no computer takes a seat, no player lost, the match goes on); the end; the host's whole
  replay reaches the guest and both spectators (in REPLAYS, "watched") and plays to the end with both sides' units.
  `HOST_ARGS=ai GUEST_ARGS=match:300 SPEC2_AFTER=220 SPEC2_ARGS=stay:60` makes it a real fight (the bandwidth above).
  `SHOTS=<dir>` (xvfb-run) takes the pictures in `docs/shots/online_spectators/`.
- `tools/test_net_fog.gd`: now with a spectator (relay id 13) on the same host: the players' pictures still never
  hold an enemy they can't see; the spectator's picture goes to it alone, has both sides' units, and its puppet holds
  every unit after each keyframe.
- Unchanged and passing: `tools/test_online.sh` (the coop case: see the run notes), `tools/test_ranked.sh`.

Run notes (2026-11-15, on the branch merged with main 0.38.20):

- `tools/test_online.sh spectators`: 27 checks, all OK (twice; and once with `HOST_ARGS=ai` for 300 s, and once with
  three spectators in the room by accident of an overlapping run: also all OK, "SPECTATOR 3" heard).
- `tools/test_online.sh`: all OK. Its `guest_ground_attack_hits_body` is flaky: it failed in 2 of 4 runs here (1v1
  and coop, "body health 47 of 70"), passed in the others; the job's note says the coop case fails on main too.
- `tools/test_online.sh coop`: all OK but that same flaky check.
- `tools/test_ranked.sh`: RANKED ALL OK (unchanged behaviour: ranked rooms never seat a spectator).
- `tools/test_net_fog.gd` (300 s): FOG ALL OK with the spectator. The process aborts while quitting, after the report;
  it does so on main too (exit 134).
- `tools/test_spectator.gd` (watching computers): ALL OK; its SCRIPT ERRORs in `Main._menu_button` while it goes back
  to the menu headless come from the menu, not from this job. `tools/test_i18n.gd`: PASS.
- `tools/bench_net_snapshot.gd` stops with a SCRIPT ERROR in `NetSession.minute_line` (its sessions have no link) after
  its first checkpoint, before and after this job.

## Pictures

`docs/shots/online_spectators/`: `host_lobby.png` (the host's room: the player seats, then SPECTATORS (1) with SPECTATOR 1 and its ping, START
allowed, SPECTATORS TALK TO PLAYERS: OFF), `spec1_lobby.png` (the same room on the spectator's screen: YOU
(SPECTATOR), the hint), `spec1_match.png` and `spec1_match_later.png` (the spectator in the match: both players'
resources at the top left, VIEW: Free · all vision, PRODUCTION for P1 and P2, no AI STORY, no command card; the
computers play both sides in this run).

## What is left

1. **Ranked spectating** (not built). The match server (`tools/server/match_server.gd`) seats only ticket holders; it
   would need: a WATCH ticket from the ladder (anyone may ask, or friends of a player), the server seating it as a
   spectator (`NetLobby._ranked_hi` -> `add_spectator`; the session part already works for a dedicated host), a
   SPECTATOR DELAY (choice 4) so no one can coach a ranked player, a cap per match by the server's upload, the
   LEADERBOARD / a "live matches" list to find one, and the server keeps the replay already.
2. **A real two-device test on the owner's devices** (below).
3. A spectator delay option (choice 4), if wanted.
4. Story lines of the host's computers for the spectators' AI STORY (choice 6), if wanted.

### Steps for the two-device (three-device) test

1. Build or open the web version (or the APK) of 0.38.21 or later on three devices; the relay address is the default.
2. Device A: ONLINE > HOST A GAME; note the code. Device B: type the code, JOIN: it sits in the player seat.
3. Device C: type the code, WATCH: it shows under SPECTATORS with its ping; the host's START is still allowed.
   (Or: C JOINs first and picks SPECTATOR (WATCH) in its FACTION list, then B joins.)
4. START. On C: no fog, VIEW / PRODUCTION / ARMY & STRUCTURES work, no command card; tap a unit and try to order it:
   nothing happens (a forged order would be refused). Type in the chat on C: A and B must not see it.
5. Midway, C quits to the menu and joins again with WATCH: it lands in the running match.
6. Let A or B surrender. C sees the battle report; in REPLAYS on C the match is listed as "watched" and plays from the
   start with both sides.
7. Paste the match logs of A and C (the minute lines show the host's upload).
