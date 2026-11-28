# Colour-blind help, text size and the phone's bigger buttons (job ui-access-phone)

Owner, 2026-11-28, on docs/qa_ui_review.md sections 3 and 19: "do it all". Three things, all on the branch
`ui-access-phone`; patch note under 0.38.999 (no version bump on the branch).

Pictures: `docs/shots/ui_access_phone/` (`pc_*` a computer at 1600 x 900, `mobile_*` a phone held sideways, a
2400 x 1080 6.5" phone drawn at 1600 x 720; `_before` = main before this job, `_cb0` / `_cb1` / `_cb2` = colour-blind
help OFF / RED-GREEN / BLUE-YELLOW, `_text150*` = TEXT SIZE 150%, `pc_*_text150_1152` at the smallest size the game
keeps, 1152 x 648). Made by `tools/shot_ui_access_phone.gd` (its head says how to run it).

Test: `tools/test_ui_access_phone.gd` (xvfb, `--resolution 1600x720`); `tools/test_qa_settings_persist.gd` now also
checks the two new settings are changed by their rows and kept in the file.

## 1. COLOUR-BLIND HELP (Settings > DISPLAY)

A choice: **OFF** (the default: the game's own colours, untouched, so the owner's "fits the map" colours stay as they
are), **RED-GREEN** (protanopia and deuteranopia, about 1 man in 12), **BLUE-YELLOW** (tritanopia, rare).

What changes when it is on (`scripts/ui/colour_access.gd`, `ColourAccess`):

- **The 8 team colours** are shown as another set. A player's colour keeps its slot (index into `Defs.PALETTE`), so
  saves, replays, online rooms, the computers and the match log are untouched; only what is drawn changes. Everything
  that draws a team colour goes through `Game.team_colour` / `Defs.colour_of`, so the units' and buildings' team-colour
  key (the shader), the minimap's dots, the HUD's coloured marks, the chat, the spectator panels, the end report, the
  lobby's colour buttons (with the new names), the campaign's speaker colours and the map editor follow at once.
  Changed during a match (the match MENU's SETTINGS), the units are recoloured at once (`Main._access_recolour`).

  | slot | game | RED-GREEN | BLUE-YELLOW |
  |---|---|---|---|
  | 1 | Blue | Blue `#2a64ff` | Blue `#3a86ff` |
  | 2 | Red | Orange `#ff9a1a` | Red `#e02828` |
  | 3 | Green | White `#f0f0f0` | White `#f2f2f2` |
  | 4 | Yellow | Brown `#6b4a1c` | Amber `#ffb000` |
  | 5 | Purple | Pink `#e060c0` | Black `#383848` |
  | 6 | Orange | Yellow `#fff04a` | Brown `#8a5a2a` |
  | 7 | Teal | Sky `#7fd8ff` | Cyan `#3ae0e0` |
  | 8 | Pink | Black `#383848` | Magenta `#d040b0` |

  Measured by `tools/ui_access/cb_check.py` (Machado 2009 simulation, the smallest Lab distance between two team
  colours; over ~20 two colours are told apart at a glance, under ~10 they look alike):

  | | deuteranopia, first 4 | deuteranopia, all 8 | protanopia, all 8 | tritanopia, all 8 |
  |---|---|---|---|---|
  | the game's own | **13.1** (Red / Green) | **3.8** (Teal / Pink) | 8.0 | 12.9 |
  | RED-GREEN | 57.5 | 18.6 | 24.7 | 14.9 |
  | BLUE-YELLOW | 36.9 | 19.4 | 2.0 | **30.7** |

- **The factions on the maps** (THE WORLD WAR's territory and armies, the war map's territory, stripes, flags and
  legend): RED-GREEN shows the machine orange and the Brood sky blue (the Crown stays purple); the shades (lighter,
  darker, see-through) are kept. Deuteranopia, the three factions: 8.9 -> 25.5. BLUE-YELLOW keeps the game's own
  (purple, red, green are already told apart there: 47).
- **The health bars** (over units and buildings, the selection panel's portraits, the balloon's passengers): blue /
  yellow / orange-red instead of green / yellow / red (deuteranopia 17.6 -> 23.1, protanopia 7.8 -> 36.9), **and** a
  second cue that needs no colour: a bar at a quarter or less is **striped** (dark slanted stripes over its fill).

Left as they were: the Crown purple / Clockwork red / Brood green faction ACCENTS of the menus (only decoration: the
faction's name is always written beside them), the walls' small damage bar, the end screen's green / red numbers
(they also carry + and -).

## 2. TEXT SIZE (Settings > DISPLAY)

A slider 90% to 150% (steps of 10, `Settings.text_size`, `scripts/ui/text_scale.gd`, `TextScale`).

- **Menus, the campaign's pages, the lobby, the tournaments, the world war's pages, the settings**: every Label,
  Button, text box and rich text that enters the tree has its font size multiplied once (its own size kept in a meta,
  so a change scales again from it). Containers grow with the text, so the pages keep their shape; the long ones
  scroll as before. Checked at 150% at 1152 x 648 and on the phone (`*_text150*` pictures).
- **The HUD's words** (drawn by hand in fixed boxes): `Hud._text` grows them by 60% of the setting (150% -> 130%).
  The lines that fit themselves to their room (the selection panel's info line, the command card's labels) count the
  text size when they fit (`Hud._text_px`), so they shrink or cut as before instead of running over.
- The HUD's own IN-GAME INTERFACE SIZE still grows the whole HUD.

## 3. THE PHONE (any game played as MOBILE)

At 2400 x 1080 on a 6.5" phone the command buttons were ~6 mm and the portraits ~4 mm; the usual thumb target is 7-9 mm.

- **The command card**: buttons at least **9 mm**. The millimetre is the screen's real density when the system gives
  one (Android), else a phone's short side taken as 68 mm (a browser on a phone). Two rows of four show at a time
  (4 x 2 at ~73 HUD units on that phone, the card ~150 tall: no taller than the old 3-row card) and the rest is on more
  **pages**: a numbered tab per page down the card's right edge (tap it; the shown page lit). A drag on the buttons
  still scrolls a row at a time, every key still works.
- **The selection portraits**: 64 (were 34) in one row; more rows by a drag or the bar, as before. The type icons
  ("16 ×") lead as before, so one row usually shows every kind.
- **Keyboard words**: the camera tabs read V1-V6 on a phone (were F4-F9) and their tooltip "View 1"; the card's
  letter keys, Ctrl+A and the F1-F3 marks were already only on a computer; the map editor's hint already had a phone
  line.
- A computer's HUD is exactly as it was (4 x 3 card of 60, portraits 34 in two rows).

## Claude's choices

1. **Two colour-blind sets, not one.** A single "safe for all" set of 8 is weak for everyone; red-green and blue-yellow
   need different things (BLUE-YELLOW keeps red, which red-green players can't use). The two cover the three common
   kinds; deuteranopia and protanopia share RED-GREEN.
2. **The slots keep their names' meaning only on screen.** The lobby says ORANGE for slot 2 under RED-GREEN; the match
   log, saves and online rooms still say "Red" (the index), so two players with different settings see their own
   colours of the same slots.
3. **White and black are team colours** in both sets: the brightest and darkest cloth are the clearest cue for every
   kind of colour blindness. Black is a dark slate (`#383848`), not pure black, so the minimap dot still shows.
4. **The faction colours change only on the maps** (territory, armies, flags), where they are the information; the
   menus' faction accents stay as decoration.
5. **Stripes for a low health bar**, not a shape change of the whole bar: the bar's length is already a cue; the
   stripes mark "about to die" without colour and only with the help on (OFF is pixel for pixel the old game).
6. **The HUD's words grow by 60% of TEXT SIZE**: the HUD's boxes are fixed; at full strength 150% ran the hall's info
   line under the card. INTERFACE SIZE remains the way to grow the whole HUD.
7. **Text size scales every text Control as it enters the tree** instead of editing ~330 places: one rule, nothing
   missed, a Control that must not grow can say so (meta `no_text_scale`). A Control that sets its own size again
   later (rare) keeps the new size until the setting changes.
8. **Two pages of 4 x 2 instead of 3 x 4** on the phone: 3 x 4 at 9 mm took more than half the screen's height; 4 x 2
   is no taller than the old card and keeps the most used commands on page 1 (the rarer ones are already sorted last).
9. **A phone's millimetre without a real density** (a phone's browser) assumes a 68 mm short side: phones are 65-72 mm
   wide; a tablet held sideways is 150+ mm, where the buttons stop at 84 HUD units.
10. **The page tabs sit inside the card's width** (the card grows 30 units), so the minimap, the panel and the bar
    keep their places.

## Left for later

- Tooltips' bodies still say "Ctrl+click" / "right-click" on a phone (the help "?" texts); they are translated
  strings, so each needs its own phone line.
- A shape per team on the minimap (the review's idea) is not built: the colour sets measured well enough for 2-4
  players; with 8 players two colours stay close in each set (the table).
- The spectator panels and the world war's side panels draw their own text without the HUD's share of TEXT SIZE.
