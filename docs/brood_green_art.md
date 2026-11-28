# The Brood is green in the paintings (job brood-green-art)

The owner (2026-11-28): the Brood's colour is GREEN (decided 2026-11-04: Crown purple, Clockwork red and brass, Brood
venom green), but many paintings still showed Brood creatures with RED spines, crests, frills and markings. This job turns
those red parts green in the PAINTINGS only. Sprites, icons and everything under `assets/units` are untouched: there pure
red is the team-colour key the game repaints in the player's colour.

## How

- `tools/art/brood_green.py` + masks `tools/art/brood_green_masks.json`. Per picture a list of regions, each drawn by hand
  round ONE creature's red parts: a polygon (`poly`), or a thick stroke along a ridge of spines (`line` + `width`), with
  optional `exclude` polygons (an eye left as painted). Inside a region (feathered) only pixels whose hue is near red and
  that are saturated enough change: hue turned to green (`hue` 72, the Brood's yellow-green family, sampled against the
  green-spined Brood Mother and creatures already in the menu painting), saturation scaled, brightness kept from the
  original's luma, so brush strokes and shading stay. Never a global red -> green swap: per picture and per region the red
  hue centre, window and saturation floor are tuned so mud, skin, nets, fire and sky inside a region stay as they were.
- It reads every ORIGINAL from git (`source_rev` 533fc5d3), so running it again gives the same pictures:
  `python3 tools/art/brood_green.py [--only PATH] [--shots]`. `--shots` writes the before/after crops.
- **The menu painting**: `assets/menu/battle.jpg` is written by `tools/menu_fix_composite.py`. If that composite is run
  again, run `python3 tools/art/brood_green.py --only assets/menu/battle.jpg --from-file` after it (the file as it is,
  not the old original), or the crawler's spines go red again.
- Before/after crops of every region: `docs/shots/brood_green_art/<picture>_<region>.jpg` (before left, after right).
- The originals are only in git history (before this branch).

## What was looked at

Every painting the player sees: the main menu painting and the three realm pictures (`assets/menu/`), all 103 campaign
stills, the hub rooms and their people, the six Crown hub rooms, the war map's painted sheets, seals, ships and serpent
(`campaign/warmap_art/`), the 56 dialogue portraits, the HUD frames (`assets/ui/panels/`). The loading screens are the
menu painting. Red that belongs to the Clockwork (red automata, clock faces, banners), the Crown, fire, blood and sunsets
was left alone. Pictures where a Brood creature had no red: not listed.

## The list

| File | Region (creature) | State |
|---|---|---|
| assets/menu/battle.jpg | the crawling creature by the bridge, next to the Crown gunner (x 876-995, y 697-748) | done (the only red-spined creature in it; every other creature there was already green) |
| campaign/stills/a03_03.jpg | the Mother's great crest, six young asleep in the hollow, one frill beside her, a young's tail | done |
| campaign/stills/a03_05.jpg | the wyvern over the canoe (x 560-880, y 10-170) | LEFT: its spines are dark red shapes cut out against a red-orange sunset; a hue window cannot tell spine from sky, and a darker-than-sky limit turned only a few specks green. Repaint prompt below. |
| campaign/stills/a05_02.jpg | the netted young's crest | done |
| campaign/stills/a05_03.jpg | the caged young (front, its back, the second cage), the stalkers in the trees (four) | done; the front cage's crest keeps a few orange tips (past the red window, they read as light) |
| campaign/stills/a05_04.jpg | the caged young's crest | done (a few orange tips left, as above) |
| campaign/stills/a05_05.jpg | the Mother's crest and neck spikes, the caged young's crest | done; the caged young's lower back spines keep some red behind the bars |
| campaign/stills/a07_03.jpg | the drawn specimen on the parchment (a drawing of a Brood creature) | done |
| campaign/stills/a07_07.jpg | the dead creature's spines in the square | done; its blood is left red |
| campaign/stills/b01_03.jpg | the hatchling's frill and back spines, the creature drawn on the wall chart | done |
| campaign/stills/b01_04.jpg | the pack in the rain: four crests | done (the right one's eye excluded) |
| campaign/stills/b01_05.jpg | the Tyrant Sire's crest (with its firelit edge), Linnea's frill and back spines | done; the last spines toward her tail keep some red |
| campaign/stills/d03_02.jpg | six young in the pen: their crests and back ridges | done; the lower right one's small head crest is orange-pink (no red to turn) |
| campaign/stills/d03_04.jpg | four flyers' crests (the big one's eye excluded) | done |
| campaign/stills/d05_03.jpg | the Raptors in the flood: eight crests and back ridges | done |
| campaign/stills/d06_02.jpg | the two Mothers fighting, six Raptors round them | done |
| campaign/stills/d06_03.jpg | the Queen on her mound and the whole brood round her (one region over the creatures, a tight hue window: the mud and the sunrise do not change) | done |
| campaign/stills/d06_04.jpg | the Queen and the brood at the burning fazenda (x 1000-1200, y 220-330) | LEFT: the creatures are silhouettes painted INTO the fire; their spines are fire-lit orange-red and the fire behind is the same hue; a recolour made green specks in the fire. Repaint prompt below. |
| campaign/stills/d08_02.jpg | the Raptor in the tree and the one on the branch | done |
| campaign/stills/d09_02.jpg | the flock of flyers v the Ticking Owls: crests, back spines, leg tufts (the Owls are brass, untouched) | done |
| campaign/stills/d10_02.jpg | the sleeping Mother's crest in the mist | done (two passes: the orange-red top and the maroon lower spines) |
| campaign/portraits/creatures.png | the creatures' portrait: the crest (the open mouth stays red) | done |
| campaign/portraits/teacher_the_old_hunger.png | the same picture (a copy), the same crest | done |

21 pictures recoloured, 2 left with prompts. Not paintings, so not touched: the Hatchlings' sprites (0.38.230: "a row of
red spines": those are unit sprites, where red is the team key) and the old brood references in `art/menu_fix/`
(working files, not shown in the game).

## Repaint prompts (crop repaints, as in art/menu_fix/ and tools/menu_fix_composite.py)

**a03_05 (the wyvern at sunset)**: crop `campaign/stills/a03_05.jpg` x 520-920, y 0-220 and send it with:
> Repaint only the creature in this crop: keep everything exactly as it is (the composition, the sunset sky, the light, the
> brush style of a classical oil painting, the size and pose of the winged reptile), but make the spines along its neck and
> back a deep venom green (dark olive-green with yellow-green highlights) instead of red. The sky stays orange-red. Same
> size as the input, no border.

**d06_04 (the Queen in the fire)**: crop `campaign/stills/d06_04.jpg` x 960-1240, y 190-350 and send it with:
> Repaint only the large reptile and its brood in this crop: keep the burning house, the flames and their light exactly as
> they are, in the same classical oil-painting style, but make the spines and crest on the big reptile's back a dark venom
> green (olive-green, catching a little orange rim light from the fire) instead of red. Same pose and size, same crop size,
> no border.

Lay each answer back with a box in `art/menu_fix/boxes.json`-style feathered blend (tools/menu_fix_composite.py does this
for the menu painting; for a still, the same blend on that still).

## Checks

`godot --headless --path . --import`: every changed picture reimported, no errors (the `.import` files did not change).
`godot --headless --path . --quit-after 120`: in this cloud container the boot aborts (exit 134) while loading the menu's
fonts, AFTER the menu painting and the realm pictures load; it does the same with the original pictures restored, so it is
the container, not this change.

## Claude's choices (for the owner to confirm)

1. The green: hue 72 (a yellow-green), saturation a little under the red's, brightness kept: it matches the green-spined
   Brood in the menu painting and still reads against the olive skin. A deeper emerald was tried and looked painted on.
2. The creatures' portrait's open mouth and the bloody ground stay red (mouths and blood are not markings).
3. The parchment drawings of creatures (a07_03, b01_03's wall chart) are recoloured too: they show Brood creatures.
4. Fire-lit and sunset-lit spines are left rather than smeared (a03_05, d06_04): a bad recolour is worse than red.
5. Small leftovers (a few orange tips, the last red spines toward a tail, an orange-pink head crest) are left as they are:
   at the size the stills are shown they read as light on green spines.
