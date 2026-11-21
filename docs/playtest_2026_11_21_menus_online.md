# Playtest, 21 November 2026: everything outside a match, and online (job playtest-menus-online)

One of the eight playtest jobs the owner started on 21 November ("make multiple simulations of players, buttons pressed,
and actually play the game... look for bad aspects of the game or bugs; it's very deep work"). This one covered
everything a player does outside a match: the main menu and every page it opens, Settings, the music player, saving and
CONTINUE, online rooms with two and three copies of the game, spectators, the campaign's CO-OP and VERSUS rooms, RANKED
with the test sign-in, and the web version. Tested on 0.38.107 (main), fixes on the branch `playtest-menus-online`.
Pictures: `docs/shots/playtest_2026_11_21/menus_online/` ("before_..." shows a problem as found, "after_..." the fix).

## How it was played

Every test is a small program that plays the game the way a person does: it starts the real game at the main menu,
finds the button it wants on the screen and clicks it (or taps it with a finger on the phone runs), types into text boxes
key by key, presses Esc, scrolls with the wheel. Game functions are only read, to check what happened. Each run takes
pictures, and every picture was looked at. Each run also listens to the engine's own error messages: any script error
during a run is a finding. The programs are kept in `tools/playtest/` so they can be run again:

- `pt_menus.gd`, the menus, three kinds of player:
  - **the careful player** opens every page of the main menu in turn (tutorial, campaign, skirmish, how to play with
    all seven sections, replays and match logs, the editor page, patch notes from the version line), then every
    Settings tab: every switch pressed and pressed back, every stepping choice stepped all the way round, every slider
    dragged and dragged back, the relay address typed over with odd characters (accents, an emoji, 200 letters) and put
    back, each change checked in the settings file; then RESET (armed, then done), the animation viewer, the
    interface layout page, the music player (a piece played, PAUSE, PLAY, the four match-music modes), the device page,
    and the three language flags;
  - **the fast player** double-clicks the menu buttons, presses up to seven buttons of each page as fast as the frames
    allow, Esc twice, hammers the Settings tabs and the language flags;
  - **the confused player** taps random places on every page, presses Esc in the middle of things.
- `pt_settings_file.gd`: settings changed by clicks, EXIT, the game started again and every setting checked; and seven
  broken settings files (garbage, empty, wrong types, an old file, impossible values, a file cut in half, a broken
  sound section).
- `pt_saves.gd`: a skirmish started by clicks, played for a while, MENU > QUIT TO MENU, CONTINUE, played on, left
  again, EXIT, then the game started again and CONTINUE; and nine broken or old save files.
- `pt_online.gd` with `online.sh`: two or three copies of the game on one computer through the local relay: host a room,
  join by typing the code (in small letters: the box makes them capitals), pick factions in the dropdowns, CO-OP and
  back, the map stepped, START, a minute of play on both sides with clicks and keys, chat with Enter (accents included),
  the ping read out. Scenarios: a spectator (WATCH), a third player JOINing a full room, a wrong code and a too-short
  code, the host leaving the match, the guest's program killed mid-match then a new copy joining again, and the
  campaign's first mission in a CO-OP room and a VERSUS room, played by two copies.
- `pt_ranked.gd` with `ranked.sh`: the ladder service with the test sign-in and its match server; two players type
  the ladder address, pick a faction, FIND A MATCH (one CANCELs first), play on the server, one SURRENDERs, both read
  the battle report with the rating change, then the LEADERBOARD.
- `web_settings.cjs`, and the existing `tools/web/qa_smoke.cjs`: the web build made as CI makes it, served locally and
  played in headless Chromium, at a computer's size and a phone's.

Sizes and languages: the menus at 1280x720 as a computer, 1600x720 and 844x390 as a phone; in English, Portuguese and
Spanish. Online and ranked at 1280x720 and 960x540, and one online match with the host in Spanish on a computer and the
guest in Portuguese on a phone (taps; 1600x720). In all, about 45 runs of the game and 600 pictures.

What could not be done here: a finger drag to scroll a list (the virtual screen has no touch screen, so the engine
ignores the drag; the mouse wheel stood in for it on the phone runs), resizing the window while a page is open (the
virtual screen has no window manager; other sizes were separate runs instead), and the real Cloudflare relay and Steam.

## What was found

Severity: CRASH (the game stops), BUG (something is wrong), UX (it works but confuses or hides something), DESIGN (a
choice for the owner), ART (how it looks). "Fixed" gives the commit on the branch.

### Fixed on the branch

1. **BUG: a damaged settings file stopped the game's start with a script error.** A settings file with a number where
   a word belongs (or the other way round) stopped the settings loading half way with "Trying to assign value of type
   int to a variable of type String"; the rest of the settings were never read. An unknown device or language was kept
   as it was, and an interface size of 999% would have drawn the match's interface ten times too big. The same in the
   sound section: a broken value stopped the music player's start. Every value is now checked: a wrong one falls back
   to the default. Reproduce: put `device=5` under `[input]` in settings.cfg. Fixed, commit "Settings, music and layout
   read a damaged settings.cfg safely".
2. **BUG: a damaged save file stopped the main menu with a script error.** A save without its set-up, players or clock
   (a file cut short in the right place, or edited) made the CONTINUE button fail while the menu was being built; any
   unreadable save also printed an engine error every time the menu was shown. The save is now checked before CONTINUE
   is offered. Fixed, commit "The save is checked before CONTINUE is offered".
3. **BUG: COPY in an online room stopped with a script error.** Pressing COPY put the room code on the clipboard and
   then failed before the button could say COPIED (the button's own code captured an empty variable). Both the
   skirmish room and the campaign room. Fixed, commit "Online room: COPY no longer stops with a SCRIPT ERROR".
4. **BUG: a wrong room code said "Could not reach the relay. Check its address in SETTINGS."** The relay had answered
   "No room with that code.", but that answer and the closing of the connection arrive together and the engine drops
   the answer. A player would go and change a relay address that was right. The game now reads the reason the relay
   gives when it closes (the Cloudflare relay already sends it there; the local test relay now does too), and a relay
   that answered and closed is "refused", never "unreachable". The relay's answers ("No room with that code.", "The room
   is full.", "That room code is already in use.") are translated. Pictures: `before_online_wrong_code.jpg`,
   `after_online_wrong_code.jpg`. Fixed, commit "Online: say why a join failed...".
5. **BUG: joining a match after a player had dropped out waited for ever.** When the guest's program died mid-match
   and a new copy joined the same room, the relay gave the newcomer the dropped player's number; the host took it for
   the player who had left and ignored it without a word. The newcomer sat at "Waiting for the host..." for ever. It is
   now told plainly: "The match is under way: a player who left can't come back into it (a computer plays that side
   now)." Pictures: `before_online_rejoin_waits_forever.jpg`, `after_online_rejoin_refused.jpg`. Getting back into a
   match is a design question (number 27).
6. **BUG: when the host left, the guest was left at "Waiting for the host..." for ever.** The host's QUIT TO MENU asks
   "Leave the match? It ends for your friend too.", but for the friend nothing ended: the match froze behind a red
   "Waiting for the host..." banner, with no word that the host had gone. The banner now says "The host left the game.
   MENU > QUIT TO MENU to leave." (and "The connection to the other player was lost." when the line simply broke).
   Pictures: `before_online_host_left_waiting.jpg`, `after_online_host_left_banner.jpg`. Ending the match properly is
   number 28.
7. **BUG: the RANKED result covered the battle report's VICTORY / DEFEAT.** The panel with the rating change was put
   at the top of the screen with its left edge in the middle, over half of the headline. It now sits under the
   headline. Pictures: `before_ranked_report_overlap.jpg`, `after_ranked_report.jpg`. Commit "RANKED: the rating
   change sits under the battle report's headline".
8. **UX: sliders showed only their filled part.** The track of every slider (volumes, minimap, overlay opacity, the
   narrator's volume, the music player's seek bar) was a dark line that vanished on the dark panels. At the start of a
   piece the music player's bar looked a few pixels long, and a low volume looked like no bar at all. Sliders now have
   a groove with a rim. Pictures: `before_music_player_bar_and_cut_titles.jpg`, `after_music_player_bar.jpg`,
   `after_sound_sliders_pt.jpg`. Commit "Sliders show their whole track".
9. **UX: RESET SETTINGS' second press was cut in Portuguese and Spanish.** "TOQUE DE NOVO PARA REDEFINIR" and "PULSA
   OTRA VEZ PARA RESTABLECER" did not fit the button; now "TOQUE PARA CONFIRMAR" / "PULSA PARA CONFIRMAR".
   Picture: `before_reset_armed_cut_pt.jpg`.

### Not changed: proposals for the owner

Menus and Settings:

10. **UX: EXIT closes the game at once, with no question.** The confused player closed the game twice by one stray tap
    on EXIT (the match is autosaved, so nothing is lost, but the game is gone). Proposal: a second press, as RESET
    SETTINGS has ("PRESS AGAIN TO EXIT").
11. **UX: small or faint main menu labels.** Already noted by the November QA and still so: at 1280x720 in Portuguese
    CONFIGURAÇÕES is drawn in a tiny font, and the green SKIRMISH / ESCARAMUÇA button uses the thin title font in a pale
    colour that reads poorly on the green (`menu_pt_pc_small_labels.jpg`). The same thin font on the green WAR TABLE
    and START buttons. Proposal: buttons a little wider (120 pixels), and the bold font on the green buttons.
12. **UX: the Settings panel jumps up and down between tabs.** The panel is centred, and each tab is a different
    height, so the row of tabs moves under the mouse or finger every time a tab is chosen (DISPLAY's tabs sit about 100
    pixels higher than SOUND's: `settings_display_tab_top.jpg`, `settings_sound_tab_lower.jpg`). Proposal: pin the
    panel to the top.
13. **UX: stepping a choice all the way round loses "automatic".** REPLAY RECORDING and POWDER SMOKE start as
    "automatic" (the device decides); stepping round to the same word saves it as a fixed choice, and only RESET brings
    "automatic" back. Small; an "AUTO" step in the list would solve it.
14. **UX: in the music player's ONLY THE TICKED PIECES mode the tick boxes make the rows narrower and long titles are
    cut** ("Anvil Chorus of a Thousand Hands", "Night over the Drowned Wood").
15. **UX: on a small phone (844x390) the HOW TO PLAY text is very small** (about 9 pixels high:
    `phone_es_844_help_small_text.jpg`). Bigger phones (1600x720 and up) are fine.
16. **UX: the interface layout page on a phone says "(Enter: chat)"**, a keyboard hint
    (`phone_es_844_layout_enter_chat.jpg`).
17. **ART: in the main menu's bottom corner the credit line "...with the help of AI" runs into the studio's logo** by
    a few pixels at 1280x720.
18. **UX: an open dropdown list stays open when its page is redrawn, and Esc does not close it.** In an online room the
    host's map list stayed open over the room when the friend joined (`online_dropdown_left_open_over_room.jpg`); in the
    skirmish set-up and the rooms Esc leaves the list open. Proposal: close any open list when the page redraws, and on
    Esc.

Saves:

19. **UX: after an update the saved match silently disappears.** A save from an older version is simply not offered:
    CONTINUE is gone and nothing says why. Proposal: a line under the menu like the one for old Brood saves ("Your
    saved match is from version X and can't be continued.").
20. **BUG (rare): a save that reads as a save but is broken inside starts a broken match.** A save whose unit list was
    damaged (made by hand for the test) passed the menu's check, then stopped part way through putting the match back
    (a script error in SaveGame.restore), and the half-restored match ended at once in a VICTORY
    (`saves_broken_inside_instant_victory.jpg`). A file cut short by a crash is refused before this (it is not valid
    text), so it is unlikely; proposal: if putting a match back fails, go back to the menu with a note instead.
21. Note: the game keeps one save (the autosave of the match being played, every 15 s and when leaving); there is no
    list of saves to load, delete or overwrite. CONTINUE and the save across a restart worked every time
    (`saves_menu_with_continue.jpg`): the match came back at the same second with the same units.

Online:

22. **UX: a failed join still shows a room.** With a wrong code the page turns into "ROOM ZQZQ" with a COPY button, an
    empty player list and "One of 19 maps that hold 0 players", as if a room existed (`after_online_wrong_code.jpg`:
    the reason is right now, the page around it is not). Proposal: back to the ONLINE page with the reason in red.
23. **UX: JOIN (or WATCH) with no code, or a code of one or two letters, did nothing at all**, not even a message.
    FIXED: a red line "Type the room code your friend gave you." (`after_online_short_code_hint.jpg`), commit
    "ONLINE: JOIN or WATCH with no code says what is missing".
24. **UX: a player who presses JOIN in a full room becomes a spectator without being told the room was full**
    (`online_full_room_seated_as_spectator.jpg`). The hint below explains spectators, but a line "The room is full: you
    are watching." would be clearer.
25. **UX: the host whose friend dropped out only gets a short message.** The friend's side is played by the computer
    from then on, but after the message fades nothing on screen says so (`online_host_after_guest_dropped.jpg`).
26. **UX: in a ranked match the Crown player was drawn blue and the Brood purple** (the faction colours are the other
    way round: the Crown is purple), and the battle report says "Easy AI · 2 players" for a match between two people.
27. **DESIGN: getting back into an online match after a dropped connection is not possible.** The host's computer takes
    over the side for good. If wanted: a rejoin ticket given to each player at the start, so a returning player takes
    back their side; and the relays should never give a newcomer a number someone used before in the same room (both
    relays reuse the lowest free number; that is what made number 5 happen).
28. **DESIGN: when the host leaves, the friend's match should end.** Today the friend's match freezes (now with a clear
    banner, number 6). Proposal: end it with no winner, show the battle report and the host's replay (the host sends
    the replay as it leaves).
29. Online worked well apart from these: hosting, joining by code (typed in small letters, made capitals), factions and
    colours in the dropdowns, CO-OP and 1v1, the map steps, START, play on both sides, chat with accents both ways (the
    spectator reads the players' chat and its own; the players do not see the spectator's, as set), the ping in the
    room and in the match (about 40-140 ms on this crowded test computer), WATCH as a spectator with every side shown,
    the host's QUIT TO MENU asking first, the campaign's first mission in CO-OP and in VERSUS played by two copies
    (`online_campaign_coop_room.jpg`, `online_campaign_coop_guest_playing.jpg`).

RANKED (with the test sign-in):

30. Sign-in by typing the ladder address and Enter, the faction and region buttons, FIND A MATCH, the clock while
    searching, CANCEL (back to FIND A MATCH), a match found and played on the ladder's match server, SURRENDER, the
    rating change (+162 / -162, placement 4 matches left), the LEADERBOARD: all worked. Two small things: the line with
    the player's name and season sits straight on the painting and is hard to read (`ranked_signed_in.jpg`), and the
    report offers PLAY AGAIN, which for a ranked match only goes back to the menu (FIND ANOTHER MATCH would say what it
    does).

The web version:

31. Built as CI builds it; on a computer and a phone's size in headless Chromium: the engine up in 8 s (locally), the
    menu, a skirmish, the match menu, a reload with no crash page and CONTINUE offered; the language chosen by the flag
    still Portuguese after a reload (read back from the browser's storage), a music piece downloaded only when the
    music player played it (`web_menu_pt.jpg`, `web_music_player.jpg`, `web_after_reload_still_pt.jpg`). No script
    error, no failed download.
32. **UX: the web art pack is now 234 MB** (it was 97.5 MB at the November QA), plus 10 MB for the engine and 21 MB of
    code: about 265 MB before the first match on a first visit, much of it on a phone's data. The browser keeps it
    across updates, but the first visit is long. Proposal: look at what grew (docs/web_load.md), perhaps a lighter
    phone pack.
33. **UX: the match MENU on a phone-sized browser (915x412) is a tight fit:** the rows touch and each slider runs
    through its label ("MUSIC 50%" crossed by its bar: `web_phone_match_menu.jpg`).

Found in passing, for other jobs:

34. **ART (campaign): the war map's cartouche shows "THE WAR MA"**, its title cut at the edge
    (`war_map_cartouche_cut.jpg`), and the place name "THE UPPER RIO NEGRO" sits under the seals.
35. **ART (the match's bottom bar): in Spanish and Portuguese the IDLE / ARMY / MAKE buttons are too narrow for their
    words**: "EJÉRCITO" and "PRODUCIR" run into the small F2 / F3 key labels in their corners.

No crash of the game was seen in any run. The only script errors were numbers 1, 2, 3 and 20.

## The existing tests

Run after the fixes (results below, filled in at the end of the job):

| test | result |
|---|---|
| `tools/test_online.sh` (host + guest, versus) | ALL OK (ping 16-17 ms, the guest's frames 16.7 ms on average) |
| `tools/test_online.sh coop` | one check fails, `guest_ground_attack_hits_body` (body health 47 of 70): already failing on main (noted in CLAUDE.md) |
| `tools/test_online.sh spectators` | ALL OK (both spectators and the guest) |
| `tools/test_ranked.sh` | RANKED ALL OK |
| `tools/test_qa_settings_persist.gd` | 0 failures |
| `tools/test_qa_save_continue.gd` | ALL OK |
| `tools/test_menu_grid.gd` | 0 fails |
| `tools/test_settings_tabs.gd`, `tools/test_match_settings.gd`, `tools/test_update_check.gd` | ALL PASS / ALL OK |
| `tools/test_i18n.gd` | fails on three texts of the Nitre Beds (crown-powder-study's study building) with no Portuguese or Spanish: not from this job, already so on main |
| `tools/web/qa_smoke.cjs` (computer and phone) | no error, no failed download, the match started, no crash page after a reload |

## Claude's choices for the owner

- The fixes keep every decision as it was: a wrong settings value falls back to the default the game would have used;
  a broken save is simply not offered (as an unreadable one already was).
- The new words (relay refusals, the refusal for a dropped player's number, "MENU > QUIT TO MENU to leave.", the
  shorter RESET confirmation) were translated in `tools/i18n/77_playtest_menus.txt` and `41_settings_tabs.txt`.
- The local test relay now closes with a reason, as the Cloudflare relay already does; nothing changes for the
  deployed relay.
- The version was not changed on the branch (the merge does that).
