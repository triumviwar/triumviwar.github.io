# The main menu in groups (job menu-groups, branch `menu-groups`)

The owner, 2026-11-28: the main menu's buttons hid the cross in the painting, and there were too many of them (TUTORIAL,
CAMPAIGN, SKIRMISH, ONLINE, REPLAYS, EDITOR, SETTINGS, EXIT, WORLD WAR, TOURNAMENTS, CONTINUE). No version bump on the
branch; the patch note is under 0.38.999 (en in `scripts/patch_notes.gd`, pt/es in `tools/i18n/patch/notes.txt`).

## What moved where

| Level | Buttons (in reading order) |
|---|---|
| Top level | **OFFLINE** (primary) · **ONLINE** · REPLAYS · EDITOR · SETTINGS · EXIT (not on the web) · CONTINUE (with a save of this version) |
| OFFLINE | TUTORIAL · CAMPAIGN · **SKIRMISH** (primary) · WORLD WAR · BACK |
| ONLINE | PLAY ONLINE (the online rooms page, was the top-level ONLINE) · TOURNAMENTS · BACK |

- **BACK**, **Esc**, the **phone's back** and the **browser's back** go up one level (the group's BACK is the page's
  `_set_back` button, so `menu_back` handles all four). On the top level Esc does nothing and the phone's back asks to
  quit, as before.
- A page opened from a group comes back to that group: `Main.menu_group` remembers it and every page's BACK calls
  `show_menu()`. A match (`Main.start`) puts it back to the top level, so the menu after a match is the top level.
- **Keyboard**: the buttons keep their focus mode. Opening a group with Enter / Space (or leaving one with Esc) gives
  the next level's first button the focus (or, going back, the group's own button), so the arrows and Enter go on
  working. A click or a tap does not (no focus ring for mouse and touch players). `Main._last_kbd` is set in `_input`.
- Changing the language with the flags rebuilds the same level.

## Where the cross is and how the grid avoids it

The cross is the gold processional cross carried on the left of the painting (`assets/menu/battle.jpg`, 1672 x 941):
measured from the top of the cross to the bearer's hand, with its glow, **x 150-290, y 305-545** in the picture's pixels
(`Main.MENU_CROSS`). The painting covers the screen centred (`MenuBackdrop._draw`), so `Main.menu_keepout(vs)` maps that
box to the screen of size `vs` the same way and adds a 6 px margin. Measured on screen (the game's units; the viewport
is 1280 x 720 stretched):

| Screen | Game units | Cross box on screen (x, y, right, bottom) |
|---|---|---|
| Desktop 1920 x 1080 and 1152 x 648 (16:9) | 1280 x 720 | 109, 227, 228, 423 |
| Phone 2400 x 1080 (20:9) | 1600 x 720 | 138, 196, 284, 437 |
| Wide 21:9 | 1707 x 720 | 147, 185, 302, 442 |
| Tablet 4:3 | 1280 x 960 | -66, 305, 89, 562 |

(The owner's figure of "x 250 / y 300-430 at 843 x 429" is the same cross on his phone-shaped screenshot: the picture
there is cut at the top and bottom.)

The grid keeps the owner's fractions (4 a row, `MENU_BTN`, `MENU_ORIGIN`, `MENU_GAP`, the mobile minimum 135 x 62).
`Main.menu_cells` fills the cells in reading order and **skips any cell that touches the cross box**; a button that
isn't there this time (EXIT on the web, CONTINUE without a save) takes no cell. On 16:9 and 4:3 the two rows sit above
the cross and nothing is skipped; on a wide phone the second row starts right of the cross and the third cell row
holds the 7th button (CONTINUE), so the buttons flow round the cross in an L. The old-Brood save note under the grid
moves right of the cross too when it would lie over it.

## Claude's choices (for the owner to confirm)

1. **TUTORIAL under OFFLINE**, first in the group (the owner's suggestion): one level down is a little less obvious
   for a first-time player, but OFFLINE is the green primary button on the top level and TUTORIAL is its first button.
2. **REPLAYS and EDITOR stay separate** on the top level rather than one "EXTRAS" group: they are single pages, an
   extra tap for each read worse than one more button, and 7 buttons fit the sky without covering the cross.
3. **OFFLINE is the primary (green) button** on the top level, SKIRMISH stays the primary inside OFFLINE.
4. **"PLAY ONLINE"** for the rooms page inside ONLINE (pt JOGAR ONLINE, es JUGAR EN LÍNEA); the group button keeps the
   word ONLINE (as it was, untranslated). OFFLINE is OFFLINE in pt and SIN CONEXIÓN in es (as the tournament pages say).
5. **RANKED is not added** to the ONLINE group: it is reached from the online page only (and only when a Steam or DEV
   identity is available, `Identity.available()`), not from the main menu, so it stays there.
6. **Flowing round the cross** (skipping cells) instead of a different grid per screen shape: one rule for every size,
   and on 16:9 / 4:3 the grid is the same two tidy rows as before. On wide phones the second row is indented.
7. **A match returns to the top level**, a page returns to its group.
8. The cross box runs down to the bearer's hand (not to his feet): the cross itself is what must not be covered.

## Code

- `scripts/main.gd`: `MENU_GROUPS` (replaces `MENU_SLOTS`), `menu_group`, `MENU_PAINT` / `MENU_CROSS`,
  `menu_keepout`, `menu_cells`, `_menu_enter`, the new slots `g_offline`, `g_online`, `back` in `_menu_button`,
  `_layout_menu` placing by cells.
- For tests and drivers: `Main.menu_open(id)` (opens the button's group, returns the button), `Main.menu_reveal(what)`
  (by node name `Menu_<id>` or label, English or shown: opens the group holding it while the menu is up),
  `Main.on_menu()` (the menu is on screen, any level).
- Translations: `tools/i18n/84_menu_groups.txt` (built into `scripts/lang/`).

## Tests and tools changed

- `tools/test_menu_grid.gd` rewritten for the groups: the levels' buttons, Esc / BACK / the phone's back, a page's
  BACK back to its group, `menu_open` / `menu_reveal`, Enter's focus, and **no cell over the cross** for 7 buttons at
  1280x720, 1600x720, 1707x720, 1280x960, 1280x800 and 1440x720, computer and phone sizes. 0 fails.
- `tools/test_tutorial.gd`, `tools/test_world_war.gd`, `tools/shot_tournament.gd`, `tools/qa_ui_press_all.gd` (pages
  `menu_offline`, `menu_online` added) open the group first.
- Playtest drivers: `main.menu_buttons[...]` became `main.menu_open(...)`, "is the menu up" checks became
  `main.on_menu()`; every driver library's button lookup calls `tools/playtest/menu_reveal.gd` first, so drivers that
  press CAMPAIGN / SKIRMISH / TUTORIAL / Menu_editor by name or label still find them (pt_base_crowncamp, brood_pt_lib,
  pt_base_crown, cw_input, pt_base, pt_lib, pt_lib_clock, tutorial_editor/pt_base). pt_hub checked end to end.
- New `tools/shot_menu_groups.gd` (each level as a picture, png: converted to jpg here; `cross` outlines the keep-out box in red).
- Run: the boot check (`godot --headless --path . --quit-after 120`: no SCRIPT ERROR / Parse Error), test_menu_grid
  0 fails, test_tutorial (its menu check and every lesson it reached in 10 minutes: no FAIL; cut by the run's
  time limit, not finished), test_world_war 0 failures, test_i18n PASS; every edited tool script parses (`--check-only`).

## Pictures (`docs/shots/menu_groups/`)

- Before: `before_desktop_1920_menu.jpg`, `before_desktop_1152_menu.jpg`, `before_phone_2400_menu.jpg` (WORLD WAR and
  TOURNAMENTS over the cross's head on the phone; the third row reaching it on the desktop).
- After, each level (`top`, `top_continue`, `offline`, `online`): `after_desktop_1920_*`, `after_desktop_1152_*`
  (also `after_desktop_1152_es_*` in Spanish), `after_phone_2400_*` (also `after_phone_2400_pt_*`), `after_phone_1920_*`
  (a 16:9 phone).
