# Act 2's Brazilian ground: VÁRZEA, HIGHLANDS, SERTÃO (job act2-terrain-art)

Act 2 build step 5 (docs/campaign_act2_plan.md, "build order" item 5 and the engine needs table: "VÁRZEA" and "THE SERTÃO
biome and the highlands"). Three new biomes for the Brazil missions and the map editor, with STAND-IN art drawn in code,
a demo map of each, and an importer that puts the owner's ChatGPT pictures in their place.

| biome id | shown as | what it is | missions (plan) |
| --- | --- | --- | --- |
| `varzea` | VÁRZEA | the flooded forest by the rivers: brown flood water between the trees, mud banks, floating grass, buriti palms | d05, d06, d08, d10 |
| `highlands` | HIGHLANDS (pt PLANALTO, es ALTIPLANO) | the southern highlands: araucaria pines, cold grass, terra roxa, grey rock, light mist | d04, d07, d11 |
| `sertao` | SERTÃO (es SERTÓN) | the dry backlands: cracked red-brown earth, thorn scrub (caatinga), mandacaru cactus, pale dust | d09 |

This job is the LOOK only. The rules the plan gives the várzea (slow for men, no buildings, boats' landings) are a
mission rule for the d05 build: today the várzea's water is plain water (impassable, fords pass) and its mud is plain
ground.

## What was built

- **scripts/mapgen.gd** `BIOMES`: the three biomes (ground sets, cliffs, water and ford, trees and bushes, the small
  things strewn over open ground, decoration groups, ambience sound, colour tint). New decoration groups (`KITS`):
  `riverbank` (a boat, a drowned log, aninga, floating grass, a wooden cross, a drying rack), `pinheiral` (an araucaria
  grove with a mist bank) and `vaqueiro` (a cattle drovers' camp: fire, cart, an ox skull, mandacaru). New helpers for
  decorations from both atlases: `MapGen.has_prop / prop_info / prop_cells / prop_kind / prop_names` (every place that
  read `PropData.PROPS` directly now goes through them). `MapGen.EXAMPLES` lists the demo maps.
- **scripts/terrain_act2.gd** `TerrainAct2` (written by the tools, never by hand): the ground sets' variant counts,
  the variants that tile best, average colours (minimap, lobby), and the new decorations' sizes, feet and palette
  groups. game.gd (`_good`, `_is_macro`), main.gd (the lobby's colour) and the map editor read it beside TerrainData
  and TerrainData2.
- **Pictures** (assets/terrain, assets/props): 9 ground sets of 6 variants (64 x 64, laid over 2 x 2 cells like the
  second atlas), 3 cliff faces and tops (32 x 32, two each), 16 decorations. All stand-ins: see
  docs/art_style_inconsistency.md.

  | biome | low ground | bare ground by the halls | plateau | cliff | water / ford | trees / bushes |
  | --- | --- | --- | --- | --- | --- | --- |
  | várzea | varzea (wet grass with puddles), varzea_mud | varzea_mud | varzea | varzea_face | varzea_water / reeds | varzea_tree, buriti / aninga |
  | highlands | highland (cold grass), highland_earth (terra roxa) | highland_earth | highland_rock | highland_face | water / shingle | araucaria, araucaria_young / cold_tussock |
  | sertão | sertao (cracked earth), sertao_dust | sertao_dust | sertao_rock | sertao_face | water / shingle | caatinga_tree, mandacaru / caatinga_bush, xique_xique |

- **tools/make_act2_terrain.py**: draws every stand-in and writes scripts/terrain_act2.gd (`--sheet out.png` a contact
  sheet, `--data` only the data file). Seeded: running it again gives the same pictures.
- **tools/import_act2_terrain.py**: the owner's pictures in, the stand-ins out (see "Putting the owner's pictures in").
- **Demo maps** (map editor format, campaign/maps/demo_varzea.json, demo_highlands.json, demo_sertao.json, written by
  tools/make_act2_demo_maps.py): 1v1, 96 x 96, turned through the middle (TURN 180), each main on high ground with
  one ramp, two hall spots a side. Várzea: the river corner to corner with three fords and flooded forest all along
  it, pools, a riverbank camp. Highlands: a second grey-rock plateau each side (two ramps), a cold stream from the
  north edge to the middle with fords, araucaria groves, outcrops, banks of mist. Sertão: a mesa in the middle, a thin
  dry river with a wide sandy ford, sparse caatinga and cactus, rocks, a drovers' camp. All three pass the map
  editor's CHECK.
- **The map editor**: LAND lists VÁRZEA, HIGHLANDS and SERTÃO with a tile of each (names with their accents,
  `MapEditor.BIOME_TITLES`); PROPS has the 16 new decorations in their groups (trees, rocks, plants); LOAD shows an
  EXAMPLES list under your maps that opens a copy of each demo map (SAVE keeps it among your maps as
  "Varzea example" and so on).
- **Lobby**: the biome names in the map's line (`main.gd BIOME_WORDS`, "Várzea", "Sertão"; pt/es in
  tools/i18n/01_menus.txt) and the palette colours that would blend into each ground (`Defs.BIOME_AVOID`).
- **Tests** tools/test_act2_terrain.gd (all pass): every set the three biomes name has its pictures at the right size,
  every variant ranked, no name clash with the older atlases; every tree, bush, strewn thing and group decoration
  exists; the editor lists the biomes; each demo map loads, builds on its own biome, keeps its decorations, has water,
  paints its ground and passes the editor's CHECK.
- **Pictures** docs/shots/act2_terrain/: `<map>_base / _middle / _cliff / _close / _overview.png` (a real match on
  each demo map, the computers stopped, Crown, Clockwork and Brood soldiers stood about for scale;
  tools/shot_act2_terrain.gd), `editor_land.png`, `editor_load.png`, `editor_sertao.png` (tools/shot_act2_editor.gd).

## The pictures are in (2026-11-23)

Claude made the pictures in ChatGPT from the prompts below, one request a picture, and put them in with
`tools/import_act2_terrain.py`: 27 of 31. All nine grounds, the three cliff strips and 15 decorations
(araucaria, young araucaria, mandacaru, the várzea tree, buriti, caatinga tree and bush, highland boulder,
aninga, floating grass, várzea snag, cold tussock, xique-xique, ox skull, sertão stones) are painted now.
The three cliff tops are cut from their cliff strips (no picture of their own). The only stand-in left is
the mist wisp (it needs a see-through picture ChatGPT would not give). Pictures from the game: docs/shots/act2_terrain/painted/.

## How to use it

- **A campaign map**: in the map editor pick LAND: VÁRZEA / HIGHLANDS / SERTÃO (or MIX one with another biome, e.g.
  `"biome": "highlands+sertao"`), paint, SAVE, and copy the file from your maps folder into campaign/maps/ like the
  other campaign maps; or start from a demo map (LOAD > EXAMPLES). A mission names its map `"campaign:<name>"`.
- **The demo maps themselves** can be played: `"map": "campaign:demo_varzea"` in a match config, or open them in the
  editor and press PLAY.
- **More mist on the highlands**: the mission's `"weather": "mist"` (MissionRun.set_weather) lays the screen-wide mist;
  the biome's own `mist_wisp` banks are only small low drifts on the ground.
- **Generated maps** (the classic `MAPS` table and `MapData.NAMED`) can name the biomes too: a line in MapData with
  `"biome": "sertao"` is all it takes (none was added: no skirmish map was asked for).

## Putting the owner's pictures in

1. Make each picture with its prompt below (one request a picture) and save it as
   `art/redraws/act2_terrain/<name>.png` (the name each prompt gives; .jpg and .webp are read too).
2. `python3 tools/import_act2_terrain.py --check` lists which pictures are there.
3. `python3 tools/import_act2_terrain.py --sheet /tmp/sheet.png` imports what is there (the rest keep their
   stand-ins), rewrites scripts/terrain_act2.gd and draws a contact sheet to look at.
4. `godot --headless --import`, then `godot --headless --script res://tools/test_act2_terrain.gd` and new pictures
   with tools/shot_act2_terrain.gd.

What the importer does: a ground picture is cut square, shrunk to 128 x 128, its slow light gradient evened out, and
cut into the set's six variants (the four quarters and two cuts across the middle; the picture wraps, so a cut across
its edge is as seamless as the picture). A face strip is shrunk to 64 x 32 and cut in two. A top that isn't given is
made from the ground picture. A decoration loses its background (a transparent one is kept; a plain backdrop is flooded
out from the border), is trimmed and shrunk to its stand-in's height (the game's scale: a Musketeer is about 36 px),
its edge made crisp like the painted props (the mist keeps its soft edge).

## ChatGPT prompts (one request a picture, at most 3 reference pictures each)

The references are in docs/redraw_refs/act2_terrain/: `ref_ground_style.png` (four of the game's painted ground
tiles: jungle fern, roots, clay, mossy rock), `ref_cliff_style.png` (three of its cliff faces), `ref_props_style.png`
(six of its painted decorations), `ref_standins.png` (every stand-in of this job: which picture goes where). For the
scale next to units add a picture from docs/shots/act2_terrain/.

Every ground prompt ends with the same words (written once here, paste them on): **"Seamless tileable texture: the
left edge continues the right edge and the top continues the bottom, no border, no frame, no vignette, no light
falling from one side, even light from straight above. Painted pixel-art style like the reference tiles: soft painted
shapes, a limited palette, small crisp details, seen from straight above. No text. Square, 1024 x 1024."**

Every decoration prompt ends with: **"One object alone, seen from a high three-quarter angle like the reference
decorations (a top-down strategy game), painted pixel-art style with a thin dark outline, lit from the upper left,
on a plain flat light-grey background (or transparent), nothing else in the picture, no shadow on the ground, no
text."**

### Ground

1. `varzea.png` (refs: ref_ground_style.png, ref_standins.png, demo_varzea_middle.png): "The floor of a flooded
   Amazon forest in the wet season: dark green wet grass and fallen leaves, small brown puddles of river water with
   little mats of floating grass in them, a few roots. Mostly green, about a fifth puddles." + ground words.
2. `varzea_mud.png` (refs: ref_ground_style.png, ref_standins.png): "A riverbank of wet dark-brown mud: shining wet
   patches, thin roots crossing it, a few green sprouts, footprints of water. Darker than the forest floor." + ground
   words.
3. `varzea_water.png` (refs: ref_ground_style.png, ref_standins.png, demo_varzea_middle.png): "Shallow brown flood
   water of an Amazon river, the colour of milky coffee, calm, with soft light ripples, and a few mats of floating
   grass and water hyacinth (green, with a few pale lilac flowers) drifting on it. It must read clearly as WATER, not
   as mud: glossy, lighter than the mud bank." + ground words.
4. `highland.png` (refs: ref_ground_style.png, ref_standins.png, demo_highlands_middle.png): "Cold grassland of the
   southern Brazilian highlands: short muted green-gold grass with bleached tufts, a few small grey stones, here and
   there a small bare spot of dark red earth. Cool light, a little frost-faded." + ground words.
5. `highland_earth.png` (refs: ref_ground_style.png, ref_standins.png): "Trodden terra roxa, the dark purplish-red
   earth of the Brazilian highlands, with a few tufts of cold grass and small pebbles. Not bright red: a deep, earthy
   red-brown." + ground words.
6. `highland_rock.png` (refs: ref_ground_style.png, ref_standins.png): "Flat grey basalt rock of a highland plateau
   in broad slabs with dark joints between them, yellow-green lichen spots, a little grass in the cracks." + ground
   words.
7. `sertao.png` (refs: ref_ground_style.png, ref_standins.png, demo_sertao_middle.png): "The dry ground of the
   Brazilian sertão in the dry season: red-brown earth cracked into large plates in some places and smooth in
   others, a few small pale stones. The cracks thin and not too dark: calm enough for soldiers to stand on it and
   still be seen." + ground words.
8. `sertao_dust.png` (refs: ref_ground_style.png, ref_standins.png): "Pale dusty sand of a sertão road: light beige
   dust, small pebbles, a few dry twigs and thorns." + ground words.
9. `sertao_rock.png` (refs: ref_ground_style.png, ref_standins.png): "The flat top of a red sandstone hill in the
   sertão: layered red and orange rock in soft bands, a few small dark pits." + ground words.

### Cliffs (one strip each; the importer cuts it in two)

10. `varzea_face.png` (refs: ref_cliff_style.png, ref_standins.png): "A wide strip, twice as wide as it is tall,
    1024 x 512: the steep side of a muddy riverbank seen from the front, dark-brown wet earth with roots hanging down
    it, a fringe of green grass along its top edge, darker toward the bottom. Seamless left to right. Painted
    pixel-art style like the reference cliff faces, no text."
11. `highland_face.png` (refs: ref_cliff_style.png, ref_standins.png): "A wide strip, 1024 x 512: the cliff face of a
    grey basalt plateau seen from the front, upright columns of grey rock with dark joints, a thin edge of cold grass
    along the top, darker toward the bottom. Seamless left to right. Painted pixel-art style like the reference cliff
    faces, no text."
12. `sertao_face.png` (refs: ref_cliff_style.png, ref_standins.png): "A wide strip, 1024 x 512: the side of a red
    sandstone mesa seen from the front, layered bands of red, orange and brown rock, darker toward the bottom.
    Seamless left to right. Painted pixel-art style like the reference cliff faces, no text."

(Plateau tops `<biome>_top.png` are optional: without them the importer makes them from the ground pictures.)

### Decorations

13. `varzea_tree.png` (refs: ref_props_style.png, ref_standins.png, demo_varzea_close.png): "A tree of the flooded
    Amazon forest standing in shallow brown water on wide spreading buttress roots, a broad dark-green leafy crown,
    a light line of the water round its foot. Tall, about two-thirds as wide as tall." + decoration words.
14. `buriti.png` (refs: ref_props_style.png, ref_standins.png): "A buriti palm (Mauritia flexuosa): a tall straight
    grey trunk with ring marks and a round crown of big fan-shaped green leaves, a few dry hanging leaves under it."
    + decoration words.
15. `aninga.png` (refs: ref_props_style.png, ref_standins.png): "A small clump of aninga, tall stalks with big
    arrow-shaped green leaves on top, growing out of shallow water." + decoration words.
16. `floating_grass.png` (refs: ref_props_style.png, ref_standins.png): "A small floating mat of river grass and water
    hyacinth with a few pale lilac flowers, flat, wider than tall (about three to one)." + decoration words.
17. `varzea_snag.png` (refs: ref_props_style.png, ref_standins.png): "A drowned grey-brown log lying half in the
    water, one broken branch sticking up, flat, wider than tall." + decoration words.
18. `araucaria.png` (refs: ref_props_style.png, ref_standins.png, demo_highlands_close.png): "A Paraná pine
    (araucaria angustifolia) as it looks on the southern Brazilian highlands: a straight bare reddish-brown trunk and
    a flat-topped candelabra crown of upturned branches ending in dark-green tufts. Tall, a little narrower than it is
    tall." + decoration words.
19. `araucaria_young.png` (refs: ref_props_style.png, ref_standins.png): "A young araucaria pine, smaller and
    more conical than a grown one: a thin trunk and a few tiers of upturned branches with dark-green tufts." +
    decoration words.
20. `highland_boulder.png` (refs: ref_props_style.png, ref_standins.png): "A grey basalt boulder of the highlands,
    rounded, with yellow-green lichen and a little cold grass at its foot." + decoration words.
21. `cold_tussock.png` (refs: ref_props_style.png, ref_standins.png): "A small clump of pale gold-green highland
    grass (a tussock), thin blades spreading upward." + decoration words.
22. `mist_wisp.png` (refs: ref_standins.png, demo_highlands_overview.png): "A low bank of white morning mist,
    see-through and soft-edged, about three times as wide as tall, on a TRANSPARENT background, no outline, nothing
    else." (keeps its soft edge)
23. `mandacaru.png` (refs: ref_props_style.png, ref_standins.png, demo_sertao_close.png): "A mandacaru cactus of the
    Brazilian sertão: a tall ribbed blue-green column with two arms turning up like a candelabra, pale spines, one
    white flower bud on top." + decoration words.
24. `caatinga_tree.png` (refs: ref_props_style.png, ref_standins.png): "A twisted tree of the caatinga, the dry
    thorn forest: pale grey bark, crooked branches, a thin crown of small olive-green leaves." + decoration words.
25. `caatinga_bush.png` (refs: ref_props_style.png, ref_standins.png): "A thorny caatinga shrub in the dry season:
    pale grey-white bare twigs spreading from the ground, a few small olive leaves." + decoration words.
26. `xique_xique.png` (refs: ref_props_style.png, ref_standins.png): "A low sprawling xique-xique cactus: several
    ribbed blue-green stems lying and curving up from the dry ground, pale spines." + decoration words.
27. `ox_skull.png` (refs: ref_props_style.png, ref_standins.png): "A bleached ox skull with its horns, lying on the
    ground, small." + decoration words.
28. `sertao_stones.png` (refs: ref_props_style.png, ref_standins.png): "A few flat red-brown stones lying together,
    small, wider than tall." + decoration words.

## Claude's choices (for the owner to confirm or change)

1. **The biome ids** are `varzea`, `highlands` and `sertao` (plain letters, so file names and map files never trip on
   accents); the names the player sees keep their accents (VÁRZEA, SERTÃO). In Portuguese HIGHLANDS is PLANALTO, in
   Spanish ALTIPLANO and SERTÃO SERTÓN.
2. **The várzea's rules are not in this job**: it is a look. Its water is ordinary water (only the fords cross) and
   its mud ordinary ground. The plan's "slow for men, no buildings, boats' landings" is left for the d05 mission
   build (a mission terrain kind), so skirmish maps on it play like any other.
3. **The várzea's water is light café-au-lait brown**, lighter and glossier than its dark mud, with sky-coloured
   ripples, so water and mud never read the same (the first try had them the same brown: docs/shots showed it).
4. **The highlands' mist is small see-through banks on the ground** (`mist_wisp`, strewn like grass), not a
   screen-wide haze: a haze over the whole map would make units harder to read in skirmish. A mission that wants real
   mist uses its weather "mist".
5. **The sertão's cracks are thin and only in patches** (the first try cracked every plate with dark lines and looked
   like a grid behind the units).
6. **Borrowed older pieces**: the ramps (moss, grass and desert ramps), the fords (reeds; shingle) and the highlands'
   and sertão's blue water are the older sets. New ramp and ford art can come with the owner's pictures if wanted.
7. **Three new decoration groups** (`riverbank`, `pinheiral`, `vaqueiro`), made of the new pieces and a few older ones
   (boat, cart, campfire, a wooden cross by the river).
8. **The demo maps are 96 x 96 1v1 maps turned through the middle**, each main on high ground with one ramp, kept in
   campaign/maps so missions and the editor can both use them; the editor opens a COPY (an example is never changed in
   place).
9. **Ground pictures at the second atlas's scale** (64 x 64 over 2 x 2 cells), six variants each, so the owner's single
   picture per set fills all six by cutting.
10. **The new decorations live in their own data file** (TerrainAct2.PROPS), not in PropData, which
    tools/import_props.py rewrites from the first atlas.

## Notes

- The boot check (`godot --headless --path . --quit-after 120`) shows no SCRIPT ERROR or Parse Error. It aborts at
  quit with no message on this machine, on main as well (not this job's).
- tools/check_maps.gd with `campaign:` ids lays 8 players' start spots on any campaign map (MapGen.max_players
  answers 8 for every campaign map: the mission places its own teams), so it reports overlapping starts for
  every campaign map; tools/test_act2_terrain.gd checks the demo maps with 2 players instead.
- Existing tests run after the change: test_terrain_same (0 failures), check_maps (18 of 18 named maps),
  test_map_editor_buttons (0 fails), test_qa_editor_play (all OK).
