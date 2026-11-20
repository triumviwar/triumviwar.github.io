# THE WAR MAP v1 (job war-map-v1, 0.38.56)

Step 4 of docs/campaign_act1_plan.md's build order: the King's study's PARCHMENT only, drawn in code as a stand-in for
the owner's painting, with all of Act 1's regions, pins and rules. The war table's LIST stays. ALL TEXT PLACEHOLDER.

## What the player sees

- In THE KING'S STUDY the WAR TABLE hotspot (the map on the desk) now opens THE WAR MAP. Every storyline's war table (the
  list) has a WAR MAP button too, so the Clockmaker's and the Naturalist's hubs can read it (they still show the King's
  parchment until their own skins are painted: step 10 of the build order).
- The map: the world as the Crown knows it, Natural Earth's coasts on parchment, the empire's land washed faint purple,
  a 10-degree grid, a compass rose. It opens on THE WORLD (Act 1's lands: Virginia, Europe, the Amazon); the buttons
  THE WORLD / VIRGINIA / EUROPE / THE AMAZON glide to each; drag to pan, the wheel / a pinch / + and - to zoom.
- REGIONS in washes by who holds them: the Crown (purple), held but uneasy (purple hatched red), the machine's (red,
  hatched), the creatures' (green), unrest: the Free Assembly (green hatched black), unknown land (blank paper, a dashed
  edge). The wash is cut to the coasts. A legend (bottom left) lists the ones on the map now.
- PINS: one WAX SEAL per mission on its place, with its place and date under it where there is room:
  - planned (no mission file yet): an empty dashed ring with the line's sign;
  - locked (written, not open yet): a grey seal with a small padlock;
  - open: the line's colour (the Crown purple, the Clockmaker brass, the Naturalist green, Rome gold), a breathing gold
    halo;
  - done: the line's colour with a gold rim, or a BROKEN seal (a crack) where the place was lost.
  The sign in the wax: a crown, a gear, a leaf, a star (all three lines).
- A tap on a seal opens its CARD: the title (or the working title of a planned mission), the line, place and date, its
  state (Not written yet / (locked) Opens after: ... / Open: ready to play / (won by ...)), the summary when it can be
  played, WHAT CAME OF IT (the ledger's lines of that mission), and BRIEFING (solo, straight to the mission's briefing)
  and CO-OP / VERSUS (the war table with that mission picked). The map glides so the pin stays beside the card. A tap on
  nothing closes it. Desktop: the card on the right; phone: across the bottom, bigger text and buttons.
- LEDGER folds out on the left: every line of what came of the act so far ("Townsfolk who reached Fürth from Nuremberg:
  34."). LIST is the old war table. BACK goes to the hub the map was opened from; the briefing's and the war table's
  BACK come back to the map (where it was looking, the pin still picked).

Pictures: docs/shots/war_map/ (pc 1280x720 and a phone's 20:9, by `tools/shot_war_map.gd`):
pc_1_new (a new campaign), pc_2_prologues (after the three prologues), pc_3_europe_furth_thin_card (a02 held thin,
its card), pc_4_amazon_plateau_drawn, pc_5_amazon_plateau_withheld, pc_6_europe_ledger_harsh_act (a harsh act with the
planned missions' flags faked: Fürth fallen, Lyon sullen, Varenne executed, the red spreading; the ledger open),
pc_7_virginia_families_left; mobile_1/3/4/6 the same on a phone.

## The data file: campaign/warmap.json

One file for every skin. Points are `[lon, lat]`, outlines flat `[lon, lat, lon, lat, ...]`.

- `bounds` `[lon0, lat0, lon1, lat1]`: the whole sheet (the camera never shows past it; the land is cut to it).
- `projection`: `{"kind": "equirect", "y_scale": 1.3}`: x = lon, y = -lat x 1.3 (a plain map stretched north-south
  a little so mid-latitude lands keep their shape). A painted base covers `bounds` in this projection.
- `land`: the coasts' file, campaign/warmap_land.json (written by `tools/campaign/make_warmap_land.py` from Natural
  Earth's 1:50m land, lakes and a few rivers: public domain, naturalearthdata.com; the command is in its header).
- `views`: `{id, label, rect}`; the first is where the map opens.
- `lines`: the pins' lines (crown, clockmaker, naturalist, all) and their names.
- `holders`: the legend's words for each holder (empire, crown, contested, machine, brood, unrest, unknown).
- `regions`: `{id, name, holder (at the act's start), poly or circle [lon, lat, radius], label_at, label: false}`.
- `marks`: small things that are not missions: `{id, kind (dot, village, town, burnt, question, ship), point, label,
  shown}`.
- `pins`: `{mission, line, place, date, point, nudge [px, px], title (planned missions only), after [missions]}`.
  `nudge` moves the seal on screen (pixels) so pins on one town stand side by side (Nuremberg, Fürth, Fürth again);
  a thin line goes back to the true point. `after` is what a planned mission waits for (its card says so).
- `rules`, run in order, a later one wins: `{"if": condition, "region" / "regions": ..., "to": holder, "mark" /
  "marks": ..., "show": true/false, "pin": mission, "seal": "seal"/"broken", "ledger": "text with %s", "args":
  ["mission.flag", ...]}`. A condition is a dictionary whose keys all must hold: `done` (a mission or a list),
  `not_done`, `won_by` `{mission: side}`, `flag` `{"mission.flag": value or [values]}`, `flag_at_least` `{"mission.flag":
  n}`, `any` `[conditions]`. A rule's ledger line shows on the card of the first mission its condition names.

Code: `scripts/campaign/war_map_data.gd` (WarMapData: the data, the projection, `state(progress)` = who holds each
region, which marks show, each pin's state and seal, the ledger; `problems()` = the checks), `scripts/campaign/war_map.gd`
(WarMap: one skin's drawing and the camera; its SKINS table has the parchment's colours and a `base` picture slot),
`scripts/campaign/campaign_menu.gd` (`war_map()`: the page; `_pin_card()`).

## How a mission adds itself

1. Its pin is already there for every Act 1 mission (a planned one has a `title`). When the mission is built and listed
   in campaign.json, its pin turns from planned to locked / open by itself (no edit), and its `title` in the pin may go
   (the mission's own title is used).
2. A new mission (Act 2 on): add a pin `{mission, line, place, date, point}`; the test fails while a mission in
   campaign.json has no pin.
3. Its effects: add rules naming its flags. The check (`WarMapData.problems`, run by tools/test_war_map.gd) reads the
   mission's own JSON once it exists and fails on a flag it never sets or a value it never gives (the planned missions'
   rules are written to the plan's flags: a01 `lyon` calm / sullen, a04 `broken` melted / kept and `lost_to_machine`,
   a05 `cages` / `cages_n`, a06 `varenne` spared / executed, a07 `rome`; when the mission is built with other names the
   test says so).
4. New texts go in tools/i18n/campaign/warmap.txt.

## Each pin's states (Act 1)

| pin | place, date | line | states and what changes the map |
| --- | --- | --- | --- |
| p01_leaf | Virginia, Summer 2767 | Crown | open from the start. Won: Virginia purple; `families` save = the Hollins farm (a loyal village); leave = the interior UNREST; won by the rebels (versus) = all Virginia unrest, the seal broken |
| b01_specimen | the Rio Negro, June 2767 | Naturalist | locked until p01. Done: the seal BROKEN (the station burned), the burnt station, a question mark on the mountain north, the Barra; `saved` few/some/many = Nazaré and the count; `clutch` saved/burned and `teles` quiet in the ledger |
| a03_plateau | the cloud mountain, September 2767 | Naturalist | open after b01. `map` drawn = the plateau drawn in (the creatures', green), the question mark gone; withheld = blank, the question stays; won by the nest = blank, the seal broken; `party` few/all in the ledger |
| a05_specimens | the plateau's foot, dry season 2769 | Naturalist | planned (after a03). `cages` in the ledger with `cages_n` |
| c01_thirteenth | Nuremberg, Advent 2767 | Clockmaker | locked until p01. Done: the seal BROKEN, FRANCONIA RED, Fürth purple (the guild's exile); `saved` some/many = the loyal quarter (a purple dot in the red), the count in the ledger; `bells`, `gate`, `jakob` lost in the ledger |
| a02_furth | Fürth, March 2768 | Clockmaker | open after c01. `furth` strong = Fürth purple; thin = uneasy (hatched); won by the machine (`fallen`) = Fürth red, the seal broken |
| a04_visit | Fürth, autumn 2769 | Clockmaker | planned (after a02). `broken` melted/kept in the ledger; `lost_to_machine` 4 or more = the red spreads east (the Upper Palatinate) |
| a01_presses | Lyon, spring 2768 | Crown | planned (after p01). `lyon` calm = Lyon purple; sullen = uneasy |
| a06_barricades | Paris, July 2769 | Crown | BUILT (0.38.59): locked until a01, then open. Won by the Crown = Paris purple; `varenne` spared = his ship into exile; executed = Paris uneasy and two risings (Brittany, Provence); won by the Assembly (versus) = Paris in unrest, the seal broken |
| a07_council | Rome, Lent 2770 | all three | planned (after a04, a05, a06). Done = Rome purple; `rome` few = Rome uneasy |

tools/test_war_map.gd checks each of these and runs every flag combination of the built missions (432 maps) for a sound
state (every holder and pin state known, Franconia red, the quarter and the plateau by their flags, no "%" left in a
ledger line).

## Painted seals and compass rose (0.38.91)

Claude made prompt 2 (the seals) and the rose of prompt 3 in the owner's ChatGPT: art/campaign/warmap_seals_chatgpt.png
(4 x 2: crown, clockmaker, naturalist, all; whole, then cracked; the Naturalist's leaf replaced by the emblem's
reptile eye, owner 2026-11-20: art/campaign/warmap_seal_eye_chatgpt.png) and art/campaign/warmap_rose_chatgpt.png, keyed off
magenta by tools/campaign/import_warmap_art.py into campaign/warmap_art/ (seal_<line>[_broken].png 128 px, rose.png 256).
WarMap._draw_pin draws the painted seal for open, done, locked (greyed, with the padlock) and broken pins (planned pins
keep the drawn dashed ring); _draw_rose draws the painted rose. Without the files the code draws its own as before. The
parchment base (prompt 1) is NOT made: ChatGPT can't keep real coastlines in place, and the code's Natural Earth coasts
are exact. The cartouche is not used by the game, so it was not made.

## The parchment painting (prompts for the owner's ChatGPT)

The code draws a stand-in. When the owner's painting comes it goes in `WarMap.SKINS["parchment"]["base"]` (a
picture covering `bounds` exactly, in the projection above) and the code stops drawing the land (the washes, pins and
labels stay drawn over it). One request each.

1. THE PARCHMENT (the base; reference images: (a) a picture of the stand-in, docs/shots/war_map/pc_1_new.png, for the
   coasts' places; (b) p01_02, the King's world map still, for the style; (c) the King's study painting, for the ink and
   the light):
   "An antique hand-drawn world map on aged parchment, ink and watercolour, the style of a 1760s royal cartographer.
   Exactly the same coastlines, in the same places, as the first reference image (a plain equirectangular map from
   170 degrees west to 110 degrees east and from 48 degrees south to 76 degrees north, stretched north-south 1.3 times):
   do not move, add or remove any land. Sea in pale green-grey wash with fine wave hatching along the coasts; land in
   warm tan with a very faint purple wash; mountains drawn as small inked hills; rivers in thin blue ink; a faint
   10-degree grid. No text, no labels, no compass, no cartouche, no seals, no borders between countries, no ships.
   Even, soft daylight, no shadows across the sheet. Wide format, 2240 x 1240 pixels." (labels, seals, regions and the
   rose are drawn by the game over it, translated)
2. THE SEALS (one sheet; reference: (a) the stand-in's pc_3 picture for the sizes, (b) a photo of a red wax seal):
   "A sprite sheet of eight wax seals seen from above on flat magenta (#FF00FF), each 128 x 128 pixels in a row:
   purple wax with a small crown pressed in it; brass-yellow wax with a gear; dark green wax with a leaf; gold wax with
   a star; the same four again but cracked across, a chip missing. Soft light from the top left, no shadow on the
   background."
3. THE COMPASS ROSE AND THE CARTOUCHE (reference: the parchment's answer):
   "An ornate compass rose and an empty decorative cartouche (a scroll frame with laurel and a small crown) in the same
   ink and watercolour as the reference map, on flat magenta (#FF00FF), no text inside the cartouche."

## Claude's choices (for the owner)

1. THE STAND-IN IS DRAWN IN CODE from Natural Earth's real coasts (public domain), not an image: it stays sharp at
   every zoom and the painting can follow it exactly. The base painting slot is ready (`base`).
2. THE SHEET IS THE WORLD from 170 W to 110 E (the Americas, Europe, Africa, most of Asia); it opens on Act 1's lands.
   Later acts can open on other views without changing the projection.
3. THE EMPIRE IS A FAINT PURPLE over all land, and the regions of Act 1 are washed stronger. Regions not touched yet
   (Lyon, Paris, Rome) show only their names.
4. FÜRTH IS A SMALL CIRCLE inside Franconia (it is a town beside Nuremberg), held purple after c01 and changed by a02.
5. "UNEASY" (contested) for a02 `thin`, a01 `sullen`, a06 executed (Paris "purple but marked") and a07 `rome` few:
   purple hatched with red.
6. THE BURNT STATION'S SEAL IS BROKEN (a place lost), though b01 is a Brood win for the player: on the King's map it is
   the Crown's loss. The same for Nuremberg (c01's story loss).
7. b01's `teles` is only ever "quiet" since the prologue was flipped (the station is scripted): the ledger says so; the
   plan's "told" rule was left out (the check caught it).
8. PLANNED MISSIONS SHOW THEIR WORKING TITLES and dates (the plan's), not "(locked)", and a planned pin can't be played.
   Their rules are written to the plan's flag names now; a07's `rome` values are guessed (few / some / most quarters
   standing): the a07 build fixes them.
9. NAZARÉ SHOWS after b01 whatever the count (the plan: "the village of Nazaré on the Rio Negro"), with the count in the
   ledger; the BARRA shows after b01 (Lindqvist's warehouse).
10. THE OTHER HUBS read the King's parchment from their war table's WAR MAP button (cheap, as asked); their own skins
   (brass, specimen chart) come with their paintings.
11. LEGEND swatches are plain colours (no hatching drawn in them).
12. Pins on the same town are NUDGED on screen (a few pixels with a line back to the true point), not clustered.

## Tests run (on 0.38.56)

- `godot --headless --quit-after 300`: no SCRIPT ERROR (the class cache rebuilt with `godot --headless --editor --quit`).
- `tools/test_war_map.gd`: 62 checks, 0 failures (data checks, translations, the states above, 432 flag combinations,
  the page from the hub and the war tables, the card, BRIEFING from a pin, BACK, starting a02 from its pin).
- `tools/test_campaign.gd` 0 failures, `test_campaign_a02.gd` 0, `test_campaign_a03.gd` 0, `test_campaign_b01.gd` 0,
  `test_campaign_c01.gd` 0, `test_campaign_m1.gd` 0, `test_tutorial.gd` 0. (They share user://campaign.json: run them one
  after another, not at once.)
- As before on this cloud machine every headless Godot run ends with "Aborted" (exit 134) AFTER its last line.
- `python3 tools/i18n_build.py` (no errors), `python3 tools/i18n_patch_build.py` reports [].
