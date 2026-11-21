# Playtest 2026-11-21: the tutorial, the map editor and replays

Job playtest-tutorial-editor, branch playtest-tutorial-editor, on version 0.38.106 (the branch bumps nothing: the merge
does). The owner asked for players simulated with real buttons pressed, looking for bugs and bad parts. This report
is written to be listened to: every finding has a number, a severity, where it is, how to see it again, a picture,
and what was done.

Severities: CRASH (the game stops), BUG (something wrong happens), UX (it works but confuses or annoys a player),
DESIGN (a question of how the game should be), ART (something looks wrong).

## What was played

Everything was driven from the main menu with real input events: mouse clicks, drags, the wheel and keys on a
computer, finger taps, drags and pinches on a phone. The drivers find the real buttons on screen and press them
where they are drawn; nothing was done by calling the game's own functions, except speeding time up (the matches
run at 2 to 4 times speed) and reading the state to check it. The drivers are in tools/playtest/tutorial_editor/ (how
to run them is at the end).

- Screens: a computer at 1280 by 720, and a phone held sideways at 844 by 390 (the phone setting: touch only).
- Languages: English, Portuguese and Spanish.
- Players: a careful new player who does what the teacher says; a player who does things in the wrong order,
  idles a minute, presses Esc, quits a lesson and starts it again, and loses all his men; a sloppy player who
  presses random command card buttons and clicks empty ground before every step; a player who tries to break the
  map editor (no start spots, a walled-in start, a map full of water, odd names, spamming dialogs).
- Runs: about 45. The Basics lesson 9 times (computer English, Portuguese, wrong-order; phone English, Spanish);
  the Crown, Clockwork and Brood lessons 8 times (computer and phone, English and Portuguese, careful and sloppy);
  the practice games 4 times; the map editor 12 times (painting every tool, sizes 32 by 32 to 256 by 256, making
  and playing 2-player and 4-player maps, breaking it, mirrors and biomes, computer and phone, English, Portuguese
  and Spanish); replays 3 times (FULL on a computer in English, MIXED on a phone in Spanish, LIGHT on a computer in
  Portuguese), with broken replay files.
- About 400 screenshots were looked at; a selection is kept in docs/shots/playtest_2026_11_21/tutorial_editor/.
- The old tests were run before and after: tools/test_tutorial.gd (326 checks, 0 failures before and after),
  test_map_editor_buttons (updated for the new BACK), test_qa_editor_play, test_replay (ALL OK after),
  test_replay_names_local, test_worker_labels, test_selection_panel, test_bars_audit (all pass after).

## Fixed on the branch

1. Lesson lines fall behind the tasks (UX). Commit "Lessons: a done step's waiting lines are dropped".
2. The Basics lesson can never end when all recruits die (BUG). Commit "The Basics lesson is lost (TRY AGAIN)".
3. Map editor: work thrown away with no question (BUG): BACK, NEW, LOAD with unsaved changes, one tap on the
   delete cross, SAVE over another map's name. Commit "Map editor: ask before losing work".
4. Map editor: names the Windows build cannot save (BUG). Same commit.
5. Map editor on a phone: a pinch paints (BUG). Same commit.
6. Phone: no slider moves under a finger (BUG): the replay timeline, the volumes, the opacities, the music bar.
   Commit "Phone: every slider moves under a finger".
7. The replay's PLAY button is a speck (ART). Same commit.
8. MAP EDITOR's PLAY turns a 2v2 map into a 1v1 lobby (BUG). Same commit.
9. GEAR VIEW key does nothing on Spanish and Brazilian keyboards (BUG). Commit "GEAR VIEW: the key under Esc".
10. Map editor HELP gives the wrong sizes (BUG, text). Commit "Map editor HELP: the sizes it really offers".
11. The editor's status box is sized for English words (BUG, text in Portuguese and Spanish). In commit 3.
12. Watching: the players' resource lines half English in Portuguese and Spanish (BUG). Commit "Watching: the
    players' resource lines translated whole".
13. A map with every start on one team reads "2" (UX). Commit "Map editor: a map with every start on one team".
14. A building just north of a Town Hall cannot be clicked (BUG). Commit "A click on a building just north of a
    Town Hall picks it".
15. A slow player's Brood lesson gets stuck when the home Rootmaw runs dry (BUG). Commit "Lessons: a worked-out
    Rootmaw, Farm or Press counts as crewed".

Checked again after the fixes, with the same drivers: the teacher's line now matches the task at every step (T1);
a Powder Mill north of the Town Hall is picked by a tap and takes its worker (T3, pt_phone_crew); a pinch in the
editor paints nothing and DRAG: PAN pans (E5); a 4-player map goes from PLAY to a 4-player lobby and plays with 4
sides (E8); on a phone the replay's timeline drags to 80 % and a tap at 10 % jumps there (R1); every Settings
slider follows a finger (R1).

## Findings, one by one

### The tutorial

**T1. UX, FIXED. The teacher falls behind a quick player.** Every line stayed up its full time (about 6 to 8
seconds) even after its step was done, so a player who did each step in two seconds read "Good. Now roll the mouse
wheel to zoom" while the task said "Defeat the bandits": four steps behind. Now the waiting lines of a step already
done are dropped, and a line of a done step on show gives way after one and a half seconds. Seen with
tools/playtest/tutorial_editor/pt_tut_basics.gd. scripts/campaign/mission_ui.gd.

**T2. BUG, FIXED. The Basics lesson gets stuck when the recruits die.** With all five Musketeers dead (walked into
the bandits early, for instance) the lesson went on for ever: its select and move steps could never be done, and
only quitting got out. Now it is lost with "Your Musketeers are all gone, recruit. Start the lesson again." and
PLAY AGAIN. campaign/missions/t01_basics.json (a trigger), Portuguese and Spanish added. The faction lessons have
the same weakness in theory (losing every worker), but there the player can always train more.

**T3. BUG, FIXED. A building north of the Town Hall cannot be clicked or tapped.** The Town Hall's floating
HAULERS label lies over the middle of whatever stands just north of it, and a click there picked the Town Hall. In
the Crown lesson the computer's own spot finder and a player alike often put the Foundry or the Powder Mill right
there; the pointer's gold ring sat on the Foundry, the player clicked it and got the Town Hall, and "Train a Field
Cannon" could not be done (only the MAKE button, F3, found the Foundry). The same happened on a phone with
"put 2 Labourers in the Powder Mill". The label now gives way to another building's own ground; a Farm's fields
still give the click to the label, as test_worker_labels wants. Picture: crown/pc_en_13_t10_crown_cannon.jpg (the
ring on the Foundry, the tooltip says Town Hall). scripts/game.gd entity_at.

**T3b. BUG, FIXED. The Brood lesson can get stuck for a slow player.** "Put 2 grubs on each Rootmaw" counted every
Rootmaw. In a phone run that took long, the Mother's home Rootmaw had drunk its swamp dry by 19:28 ("spent"): a spent
Rootmaw takes no grubs, so the step could never be done unless the player rooted a third one, which the teacher
never says. A worked-out Rootmaw (and a spent Farm or Cog Press in the other lessons' crew steps) now counts as done.
Picture: brood_phone_pt/phone_pt_08_t30_brood_end.jpg (the selected Rootmaw reads "esgotado", spent).
scripts/campaign/mission_run.gd.

**T4. BUG, FIXED. GEAR VIEW key on Spanish and Brazilian keyboards.** The Clockwork lesson says "Press the ` key,
under Esc". On those keyboards the key under Esc prints º or an apostrophe and ` is a dead key elsewhere, so
nothing happened. The physical key under Esc now opens the view on every layout. scripts/controls.gd.

**T5. UX. The LESSON panel's title reads "LESSON -".** The minus is the fold button (plus when folded), but it reads
as a stray dash. Proposal: a small arrow or a drawn chevron instead.

**T6. UX. The expansion spot labels show in every lesson.** "OPTIMAL EXPANSION SPOT" (in Portuguese "PONTO DE
EXPANSÃO IDEAL") gold boxes sit on the map in the Basics lesson, where nobody builds. They distract a new player.
Proposal: hide them in the Basics lesson, or in all lessons until a lesson talks about expanding. Picture:
basics/pc_en_04_step_camera.jpg.

**T7. UX. A tooltip opens the moment a lesson starts.** The mouse rests where START LESSON was, which in the match
is over group 8 of the hotkey bar, so its long tooltip covers the right half of the screen during the welcome line.
Proposal: no tooltips in the first two seconds of a match, or until the mouse moves. Picture:
basics/pc_en_04_step_camera.jpg.

**T8. UX. LESSON DONE comes thirteen seconds after the last task.** The lesson waits for its two closing lines to
time out. NEXT speeds it up, but a new player does not know that and sits waiting. Proposal: shorter closing lines,
or the end panel as soon as the last line is up.

**T9. UX. Esc in a match only clears the selection; no key opens the match menu.** Many players press Esc to pause
or leave. The menu is only the MENU button. Proposal: Esc with nothing selected and no mode on opens the match menu
(or F10, as in the classic games).

**T10. UX. The card says "POWDER 0/1", the teacher says "Powder Mill".** The build card shortens long names with
the count (POWDER 0/1, COG 1/2, MAINSPRING 0/1); a new player told to build a Powder Mill looks for those words.
Also the Brood lesson says "lay a RAPTOR egg" while the button reads RAPTORS. Proposal: the lesson lines use the
button's words, or the card keeps the whole name and moves the count to a corner.

**T11. UX. Steps with no pointer.** "Build a Powder Mill", "Build a Barracks", "Build a Foundry", "Build a
Mainspring", "Build a Light Works", "Put 2 Winders on each Cog Press" and "Put 2 grubs on each Rootmaw" have no gold
pointer; the steps around them do. Proposal: point at a worker (or at the BUILD button once a worker is selected).

**T12. UX. Clicking a grub beside the Brood Mother often picks the Mother.** Her body is large and the grubs work
at her side; the driver's first clicks on a grub got the Mother's card. Not fixed (her body is meant to be picked
anywhere, by the owner's wish); proposal: a unit under the click wins over a rooted creature's body, as it already
does over a building.

**T13. UX. The practice games are hard on a beginner.** In "Practice: the Crown" an idle player lost everything to
the Easy Clockwork at 7:16; in "Practice: the Clockwork" (phone, Spanish) a slow player still on the second hint
lost at 8:50 and again at 8:46 to the Easy Brood; in "Practice: the Brood" a slow player lost the Mother to the
Easy Crown at 6:57. The losing words for the Brood also say "defend your ramp", which a Brood player has no
wall for. DESIGN proposal: the practice computer waits (no attack before 10:00, or until the player
has an army), since the practice is a lesson. Picture: practice_crown/pc_en_04_t19_crown_practice_end.jpg.

**T14. UX. On a phone the lesson leaves little map.** The LESSON panel (top left), the teacher's box (top right)
and the HUD (bottom) leave a band of about a quarter of the screen height for the map; the pointer's arrow often
points at something hidden under a panel. Taps on the panels are taken by them. Proposal: on a phone, fold the
teacher's box to one line after the line is read, and fold the LESSON panel by default. Picture:
crown_phone/phone_en_05_t10_crown_cottage.jpg.

**T15. UX. Text on a phone is tiny.** On the lesson list the "YOU WILL LEARN" lines, the hotbar's key letters and
much of the HUD are about 7 pixels high on a 390-pixel-high phone screen: unreadable on a real phone. Pictures:
basics/phone_en_02_lesson_list.jpg, basics/phone_en_09_step_card.jpg.

**T15b. UX (phone). With a worker selected, a tap on another worker at a Farm sends yours to that Farm.** To
select a second Labourer the phone player taps it; if it is working a Farm (or stands on a Mill's yard), the game
reads the tap as "go and work there" (controls.gd: a tap on a crewed building's men is that building) and the
selected Labourer walks off to the Farm instead. So "put 2 Labourers in the Powder Mill, one after the other"
fails on a phone: the driver tapped a second farmer three times and each time the first Labourer, already in the
Mill, was sent to the Farm (tools/playtest/tutorial_editor/pt_phone_crew.gd). The only ways round are the
double tap (every Labourer on screen) or the DRAG: BOX switch. Proposal: a tap that lands on a worker selects it;
only a tap on the fields or the yard themselves gives the order. Left for the owner (it is a deliberate rule).

**T16. ART. The phone shows keyboard keys.** The hotbar shows F1 to F10 above its buttons on a phone, where there
are no F keys.

**T17. ART. Portuguese hotbar words fill their buttons.** ÓCIOSOS, EXÉRCITO, PRODUZIR touch the edges and run into
the F1, F2, F3 key letters. Picture: basics/pc_pt_09_step_card.jpg.

**T18. UX. The lesson list hides the last lessons.** At 1280 by 720 the list shows the Brood group cut at the
bottom; "Practice: the Brood" needs scrolling, and nothing says the list goes on. Picture:
basics/pc_en_02_lesson_list.jpg.

**T19. Robust: things a lesson survived.** Doing later steps first (selecting, moving to the ring, using the
minimap, setting group 1 before being asked) is counted when the step comes. Idling a minute is fine. Quitting
mid-lesson by MENU, QUIT TO MENU and starting again from the list works. The sloppy player who pressed random card
buttons (GEAR VIEW, REPAIR, BUILD, ATTACK, WORK, STOP) and clicked empty ground before every step still finished
the Clockwork lesson. The lessons finished by the careful player: Basics (about 55 seconds), the Crown (about 7
minutes of game time), the Clockwork (about 4), the Brood (about 3.5).

**What the lessons do not teach (a list for the owner).** Basics: attack-move is only mentioned, Shift to queue
orders, PATROL, rally points, the supply number on the top bar, the match MENU (pause, settings, leaving) and the
HOW TO PLAY pages. The Crown: putting Labourers on the Farm (they are told the Farm makes gold, never shown how to
crew it), supply running out, the Horse Breeder, ARM WITH POWDER and reloading, a second Town Hall when the soil
runs out, research. The Clockwork: winding and repairing in a fight (only told at the end), the Spring Tower, WIND
UP, gear sizes beyond one sentence, research. The Brood: fighting with Raptors, UPROOT and GROW (only told at the
end), the Mother's other eggs. All three: an attack of your own (the Crown lesson only defends; the Clockwork and
Brood lessons never fight).

### The map editor

**E1. BUG, FIXED. One tap deleted a map for good.** The × beside a map in LOAD deleted it at once, no question.
Now the first press turns it into SURE? and says so; the second deletes.

**E2. BUG, FIXED. BACK, NEW and LOAD threw unsaved work away.** Now each asks for a second press ("Not saved. Press
BACK again to leave without saving."). Painting, placing and undoing count as changes; saving or loading clears
them.

**E3. BUG, FIXED. SAVE replaced another map with the same name, silently.** A new map named like an old one
overwrote it. Now the first press says "There is already a map called ... Press again to replace it." (PLAY, which
saves, asks the same).

**E4. BUG, FIXED. Names the Windows build cannot save.** The name box took < > * ? | and quotes, and names such as
CON; Windows refuses such file names, so SAVE said only "Couldn't save the map." Those characters now become a
dash, reserved names get an underscore, a name of dots counts as no name.

**E5. BUG, FIXED. A pinch painted on a phone.** In paint mode the first finger of a pinch or a two-finger pan
already painted a dab (and its mirror twin), or put a start spot or a decoration. Now a second finger within half a
second takes that back. Picture of the bug: editor_paint/phone_en_05_painted_high.jpg (two small squares of high
ground in the middle that nobody painted).

**E6. BUG, FIXED. HELP gave the wrong sizes.** It said presets from 48 by 48 to 192 by 192; the presets are 64 by 64
to 256 by 256 and your own size goes down to 32. Fixed in all three languages.

**E7. BUG, FIXED. The status line's box was sized for English.** In Portuguese and Spanish the words ran out of
the box.

**E8. BUG, FIXED. PLAY on a 2v2 map went to a 1v1 lobby.** A map with four start spots, two a team, came to Skirmish
with two players. Now PLAY picks the map as the lobby's own list does: four players, two a side.

**E9. UX, FIXED. A map with every start on one team read "2".** The size line said "2  84x84" and TEAM said "The map
is 2." Now the mode is blank and TEAM says every start is on one team.

**E10. UX. Painting a 256 by 256 map stalls.** A long stroke took about 2.6 seconds and a fill 1.5 seconds before
the screen answered (measured on this machine's software renderer; the work is the whole map's ground being
rebuilt after every stroke, so a phone will feel it too). Proposal: rebuild only the painted area.

**E11. UX. The editor does not grow on a phone.** Its buttons and words keep their computer size, so at 844 by 390
they are tiny (UNDO is even clipped). Picture: editor_paint/phone_en_09_props_palette.jpg.

**E12. UX. The name box stops at 24 letters without a word.** Typing on just cuts off.

**E13. UX. One PROPS click put down ten pieces.** The palette starts on the FARM group; a new user expecting one
decoration gets a whole farm (mirrored). Proposal: start on a single decoration.

**E14. Robust: things the editor survived.** PLAY with no start spots, with a start walled in by water, and on a
map flooded with water all refuse with a clear line. A 32 by 32 map can be made, saved and played (a skirmish
starts and runs). Spamming NEW, LOAD and HELP leaves one dialog. Names in Japanese, empty names, names of spaces and
a 40-letter name are handled. UNDO and REDO by buttons and Ctrl+Z / Ctrl+Y work, FILL works, mirrors place twins,
TEAM and REMOVE work, CHECK lists problems and outlines them. A 2-player map made in the editor was played to 4
minutes (the computers built and fought); a 4-player one too.

### Replays

**R1. BUG, FIXED. No slider moves under a finger on a phone.** The project turns no touches into mouse events (on
purpose: the game reads touches itself), and a Godot slider reads only the mouse. So on a phone the replay's
timeline could not be dragged or tapped, and in Settings the volume, minimap and overlay opacity and narrator
sliders, and the music player's bar, never moved. Each slider now takes a finger (UiStyle.touch_slider). Measured
before and after with tools/playtest/tutorial_editor/pt_phone_sliders.gd: before, every slider stayed where it was; after, a drag
to the right reaches the top and a tap at 30 % sets 30 %.

**R2. ART, FIXED. The replay's PLAY button was a speck.** The font's ▶ came out a few pixels wide. PLAY and PAUSE
are drawn icons now. Picture of the bug: replays/pc_en_12_replay_end.jpg (bottom left).

**R3. BUG, FIXED. Watching in Portuguese and Spanish, the resource lines were half English.** "P1 Clockwork 319
engrenagens · 0 de tensão · 4/10 supply". Picture of the bug: replays_light_pt/pc_pt_11_replay_view_menu.jpg.

**R4. UX. On a phone the replay bar sits over the watching panels.** The bar is placed above the HUD, which on a
phone is the middle of the screen, over the PRODUCTION and ARMY panels' second rows. Picture:
replays_phone/phone_es_05_replay_start.jpg.

**R5. UX. Empty replays fill the list.** Every lesson restarted or quit at once leaves a 0:00 "UNFINISHED" replay.
Proposal: don't keep replays shorter than a few seconds.

**R6. UX. The list is ordered by file time, not by the match's date.** An imported or copied file goes to the top
whatever its date, so the dates in the list are out of order.

**R7. UX. "The end: no winner." for a match left early.** The replay of a match quit at 1:43 ends with "no winner";
"left at 1:43" would say what happened.

**R8. Robust.** Pause, the speeds ½x to 8x (they keep time exactly), dragging and clicking the timeline, Space,
the + and Home keys, FOG and CAMERA cycling, the VIEW menu, playing to the end, QUIT, KEEP, DELETE with SURE? all
work in FULL, MIXED and LIGHT. A file of garbage and an empty file are left out of the list without an error; a
file cut in half plays to where it was cut.

### Everywhere

**G1. BUG, not fixed. The game crashes when it closes.** Every run, the game itself (godot --path . --quit) and
every test tool end in a segmentation fault after quitting (exit code 134): a texture is freed after the renderer
has already shut down ("Parameter RenderingServer::get_singleton() is null" in ~CompressedTexture2D, after "Texture
with GL ID of 23: leaked"). It is not the mouse cursor and not the static caches of PanelArt, Game, UnitStats,
CardTips, CwArt, LineArt, UiStyle, VetLook or Building (each was cleared before quitting: it still crashed); the
main menu alone is enough to cause it. The EXIT button removes the crash marker first, so the next start shows no
false crash page; but on Android a crash on closing may show "the app has stopped". Proposal: a job to find which
script keeps the texture (likely a preloaded constant or a static variable in a script loaded at the menu).

**G2. Note. Text-to-speech warns on this Linux machine** ("synth is null", no speech-dispatcher) when a replay
opens; harmless, it is the machine.

## Proposals for the owner (nothing here was changed)

- T6 hide the expansion spot labels in lessons; T9 Esc opens the match menu; T13 the practice computer holds its
  attack; T10 lesson words match the card's words; T11 pointers on the building steps; T14 and T15 a phone layout
  for lessons and bigger phone text; E10 faster painting on huge maps; R5 drop empty replays.
- The list of what the lessons don't teach, above.

## How to run the drivers again

Each is a script for Godot run under a virtual screen (xvfb):

    tools/playtest/tutorial_editor/run.sh <driver> <width> <height> [phone] [lang:pt|es] [other args]

- pt_tut_basics: the Basics lesson; player:careful or player:wrong.
- pt_tut_faction: lesson:t10_crown, t20_clockwork, t30_brood or a practice game (t19, t29, t39); player:careful or
  player:sloppy; speed:<n> game speed, cap:<seconds> of game time.
- pt_editor: part:paint, sizes, play (add "four" for a 4-player map), break, tools.
- pt_replays: rec:full, mixed or light.
- pt_phone_sliders, pt_phone_pick, pt_phone_crew, pt_phone_grub: small phone checks (sliders, picking a Labourer,
  crewing a Mill, crewing a Rootmaw).
- They live in their own folder because the other playtest jobs also have a pt_base.gd in tools/playtest/.

The log lines start with PT: PT STEP (what was pressed), PT NOTE (what was seen), PT CHECK, PT FIND (something
wrong), PT ERROR (an engine error caught while it ran). Screenshots go to docs/shots/playtest_2026_11_21/ (out:<dir>
to change).
