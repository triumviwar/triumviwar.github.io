# The match HUD pass (job ui-hud-pass, 28 November 2026)

From the design review `docs/qa_ui_review.md` and the owner's answers of 2026-11-28. Built on branch `ui-hud-pass`
(patch note under "0.38.999", no version bump). Pictures: `docs/shots/ui_hud_pass/` (`pc_...` computer 1600 x 900,
`mobile_...` a phone held sideways, 2400 x 1080 shrunk to 1600 wide), made by `tools/shot_ui_hud_pass.gd`. The
"before" pictures are the review's own, `docs/shots/qa_ui_review/` (e.g. `pc_crown_army_selected.jpg`,
`pc_crown_make.jpg`, `pc_crown_card_barracks.jpg`, `mobile_crown_army_selected.jpg`).

Test: `godot --headless --fixed-fps 30 --script res://tools/test_hud_pass.gd` (29 checks). Also run and passing:
`test_hotkeys`, `test_card_keys` (278 cards), `test_group_keys`, `test_hud_frames`, `test_settings_tabs` (now with
SHOW APM), `test_campaign`, `test_campaign_a01`, `test_replay`.

## What changed

1. **Hotkey priority.** The command keys still follow the names (no switch to grid keys, as the owner asked). When
   a selection holds units AND your own finished buildings (a Barracks and its Musketeers, a control group with
   both), the card shows the **units' commands first** with their usual letters, then the buildings' **training and
   research** buttons (as on the building's own card; RALLY, CANCEL, DEMOLISH stay on the building's own card). A
   building's button keeps its own letter only when no unit command has it, shown or kept for later (ATTACK A, STOP
   S, HOLD H, BUILD B, REPAIR R, CANCEL X always count as the units'); otherwise its button shows no letter and is
   clicked. These buttons carry a thin **blue band** down their left edge, act on those buildings only (the
   selection stays as it was) and their tooltip is the building's, with a line saying the key rule. The building
   alone (or several buildings) keeps every key as before. The same for every faction (the Brood has no buildings:
   its rooted creatures are units, unchanged). With GRID keys the buildings' buttons simply follow the units' by
   place. Code: `Hud._secondary_items`, `_secondary_keys`, `_as_buildings` (scripts/ui/hud.gd, called from
   `_refresh_card`).
2. **Income a minute and supply block.** Each resource pill's tooltip now starts with "+N a minute in · M a minute
   spent (the last minute)" (sampled every 5 s over a minute in `HudAlerts.rates`; spent = what came in less what the
   bank grew by, so it also counts powder fired). The old "Income: about ..." line moved up into that first line.
   The supply tooltip starts with "Workers · Army · In production". On a phone a **tap on any pill** shows its
   tooltip (it was the supply pill only). **SUPPLY BLOCKED:** when a training is refused for supply (a click, a key
   or an automatic training; a Brood egg too), the supply pill flashes red with a red frame for as long as the supply
   stays full (8 s after the last refusal), and once a block the HUD says "SUPPLY BLOCKED: production is waiting.
   Need more supply: build a Cottage." with the faction announcer's "no supply" line; it is said again only after
   the supply had room. Hooks: `Game.train` and `BroodNew.lay` call `hud.note_refused`.
3. **Glows and jump.** IDLE glows (gold) while a worker is idle; ARMY glows (red) while some of your army was hit,
   fired or has an enemy target within 9 tiles in the last 3 s; MAKE glows (blue) while every production building is
   idle (nothing training or researching; the Brood: the Mother with eggs ready and no research), from 0:20 on.
   **JUMP TO LAST ALERT: the Home key** (Space was taken: it centres on the selection) **or the small ALERT button**
   just above the minimap's right end (below it when the minimap is at the top). It moves the view to the newest
   alert and shows its line ("Alert 1/3: Your base is under attack! (12 s ago)"); pressed again within 4 s it goes to
   the one before, round. Alerts kept: the last 10 (under attack, a building finished, a research done); an alert of
   the same kind within 10 tiles and 12 s of a newer one only moves it to the top. The button pulses red for 10 s
   after a new alert. Hooks: `Game.under_attack`, `on_building_complete`, `research_done` call `hud.note_alert`.
   Code: `scripts/ui/hud_alerts.gd` (HudAlerts), `Hud.jump_alert`, `alert_btn_rect`, `HotkeyBar.key` (KEY_HOME).
4. **APM.** Settings > GAMEPLAY > SHOW APM (ON by default): OFF hides the counter beside the clock
   (`Settings.show_apm`, saved as `ui/show_apm`). The end screen and the match log keep it.
5. **Production shown.** The selected building's card already had its queue's icons with a bar under the first
   (click one to cancel), and the building in the world already had a faint bar (OVERLAY OPACITY). Added: the
   seconds left on the first icon, and in the panel's empty middle a line "Making Musketeer · 13 s (+1 waiting)"
   (or "Researching ...") over a long bar.
6. **Tooltips, short first.** Every tooltip (card buttons, units and buildings in the world, resources, stats, the
   quick buttons) is drawn in one layout (`Hud._draw_tip`, `Hud.tip_parts`): the title with its key, and on the
   same line, right, the first piece of its stats when it is a number (the cost, or the health); then the summary
   (a given "sum" line, else the body's first sentence); then the rest of the stats and what is missing (red); a thin
   rule; then the rest of the body and the hint. Nothing is cut: the test checks every word of the Musketeer's old
   tooltip is still in the new one.

Quick wins from the review done too: the **page tab** on a long card ("1/2 Tab" over its top right; "▾" on a phone),
the **SACRIFICE confirm** (on a group of two or more the first press asks: "Press SACRIFICE again to offer up all N
(they can't come back)", 2.5 s, like DEMOLISH), **objective pings** (a new objective of your side with a place, a
reach's area or a destroy / protect / capture / build tag, pings the minimap there; never a disguised building),
**replay titles** (campaign replays are listed by their mission's title; replays recorded before this keep their
cached map name), the **camera tabs on the phone** say 1-6 instead of F4-F9 (and so do their toasts and tooltip).

## Keys

| key | what |
|---|---|
| Home | jump to the last alert (again within 4 s: the one before) |
| Space | (unchanged) centre on the selection |
| F1 / F2 / F3 | (unchanged) IDLE / ARMY / MAKE, now glowing |
| letters | units' commands first; a selected building's training only on letters no unit command uses |
| Tab | (unchanged) the next page of a long card, now labelled 1/2 |

## New texts

All in `tools/i18n/85_ui_hud_pass.txt` (en / pt / es), the patch note in `tools/i18n/patch/notes.txt`.

## Claude's choices

1. **Home** for JUMP TO LAST ALERT: Space centres on the selection, Backspace deselects, F1-F10 are taken, letters
   belong to the card. Home is free in a match (the replay bar's Home only works in replays, where the jump is off).
2. The mixed card lists the buildings' **training and research only**; their RALLY, CANCEL, DEMOLISH, ARM WITH
   POWDER stay on the building's own card, so a unit command and a building command never share a card spot.
3. A building button's letter is dropped when **any** unit command of that kind of selection has it, even one not
   shown now (a research kept for later, a toggle's twin): the letters never change while you play, as before.
4. The blue band marks the buildings' buttons on a mixed card (the cost chip covers the top edge, so the band is on
   the left).
5. Supply block shows for 8 s after the last refusal and only while the supply is still full; it is said again only
   after the supply had room for 2 more (so a player at the cap is told once, not every auto-train try).
6. "Spent a minute" is income minus bank growth (it includes losses such as powder fired, refits, repairs): simple
   and always right about where the money went.
7. ARMY glows on being hit, firing, or an enemy target within 9 tiles in the last 3 s; horses and workers don't
   count. MAKE glows only after 0:20 (the opening has every building idle by design).
8. Alerts kept: 10, merged within 10 tiles and 12 s; under attack, building finished and research done. Not "unit
   ready" (it would bury the attacks).
9. Tooltips: the first piece of the stats goes on the title line only when it starts with a number and is short
   (the cost or the health). The summary is the body's first sentence (the whole body when it is short; a colon
   counts only 40+ letters in, so "[Light] Light line infantry:" is not a summary).
10. On the phone a tap (not a long press) on a resource pill shows its tooltip, as the supply pill already did and as
    the "?" help does; a long press there does nothing else, so a tap is the quicker gesture.
11. Objective pings skip anything disguised (a01's presses are what you are looking for).

## Not done

- The stale command card seen once in the review (7.6) was passed to qa-click-sweep, not looked at here.
- The tutorial's progressive disclosure, the floating labels and the "+5%" marks (review 5.4, 5.5, 14) are other
  jobs; the phone's tap targets and colours are ui-access-phone's.
