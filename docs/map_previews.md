# Map pictures (job map-previews)

The owner's report (2026-11-28): the map picker showed some maps as a plain coloured box with the start circles on
it (FROSTFANG: a light blue-white box with spots 1 and 2), not the map. Wanted: a small drawing of the real map, like
the in-game minimap, everywhere a map is picked.

## What was wrong

`Main.MapPreview` (inside scripts/main.gd) drew three kinds of map three ways:

- the 18 named maps: a picture in `assets/maps/<id>.png` made by `tools/make_map_previews.gd` (good);
- the 9 classic maps (Greenhold, Frostfang, Twin Fords...): **a flat biome colour, a circle for a hill and a line
  for a river**: the FROSTFANG box;
- your own maps: the picture the editor saved, or a cell sketch; campaign maps: nothing (a "?").

## What it is now

Two new scripts, one widget for every screen:

- **`scripts/ui/map_thumb.gd` (`MapThumb`)**: makes a map's picture from its data *without a match*. It creates a
  `Game` object that is never put in the tree, lets `MapGen.generate` lay the map out (pure data: no nodes), and
  paints the in-game minimap's colours exactly as `Game._render_ground` does (each cell's ground set and shade, the
  tiles' own mean colours, woods darker, rocks grey), then the lobby's marks the old pictures had: high ground
  lighter, cliffs dark, ramps light, plus **every hall spot ringed in gold** (the map has no resource fields: each
  hall's land holds its reserves, so the hall spots *are* the resources). Twice the cells' size. `Game.W` /
  `Game.H` (static: the running match's size) are put back after.
- **`scripts/ui/map_preview.gd` (`MapPreview`)**: the widget. The picture fitted to its box, the start spots
  numbered by side on top (in each player's colour when given the lobby's `slots`, all of them in grey otherwise),
  a random pool as four of its maps under a "?". Options: `show_starts`, `frame`.
- `scripts/ui/map_thumb_worker.gd`: makes queued pictures one a frame, then frees itself.

### Where a picture comes from (fastest first)

1. memory (this session);
2. **bundled** `assets/maps/<id>.png` for every built-in map (named and classic; a classic map also
   `<id>_4p.png`, its four-corner layout) and every campaign map (`campaign_<name>.png`): 61 pictures, made by
   `tools/make_map_previews.gd`;
3. your map: the picture the map editor saved beside it (if not older than the map);
4. the disk cache `user://map_previews/<id>__<version>.png`;
5. otherwise it is **queued** and `picture()` returns null: `MapPreview` shows "drawing the map..." and redraws
   until it comes (one map a frame: no threads, so the web build is the same).

Versions: built-in and campaign maps belong to the game's version (`application/config/version`); a map of your own
to its file's time, so editing a map makes a new picture. The editor also calls `MapThumb.forget` on SAVE.

### The classic maps

They are laid out anew every match from the match's seed, so their picture is one fixed layout
(`MapThumb.PREVIEW_SEED`), and with 3-4 players their four-corner layout. The ground, biome and layout kind are
true; the exact clumps of woods and lakes change each match. The replay list leaves them out for that reason.

## Where it shows

| Place | What |
|---|---|
| Skirmish lobby | the big map box (was the flat box for classic maps) |
| Online room | the same (`Main.make_map_preview`) |
| Tournaments: ban / pick buttons (`TournamentPage._map_buttons`) | a picture over each map's button |
| Map editor LOAD list | a thumbnail before each of your maps and each example |
| Replays list | a thumbnail at the row's left (not classic maps) |
| Campaign briefing | the mission's map under "You lead" (no start spots: the mission places its sides) |

Not done, on purpose:

- **The tournament's map-pool editor** (the check boxes in the new-tournament form): the job tournament-formats
  is changing that pool at the same time. To add pictures there: `var pv := MapPreview.new(); pv.map_id = id;
  pv.custom_minimum_size = Vector2(160, 96)` next to each check box.
- **World war battles**: the map is chosen only when FIGHT IT is pressed (`WWBattle.map_for` from a seed drawn
  then), so there is no map to show before. It could be shown on the battle banner if the seed were drawn earlier.
- The skirmish's map **dropdown** list is still text; the big picture beside it changes as you step with < >.

## Numbers

Making the bundled pictures (headless, this machine): classic maps 0.15-0.37 s each, named 1v1 0.15-0.35 s,
2v2 0.6-0.9 s, Kingsfield 1.4 s, Pinewall Marches 1.5 s, the Sundered Realm 2.4 s (laying the map out is most of
it); campaign maps 0.04-0.12 s. In the game every built-in and campaign picture is a loaded texture: all 52 maps'
pictures in 48 ms, nothing made. A map of your own without its saved picture is made once (custom maps are quick:
no generator, under 0.15 s for 256-wide ones) and kept in the cache.

## Checks

- `tools/test_map_previews.gd` (headless): every built-in and campaign map has its bundled picture (fails when a
  new map is added without rerunning the tool), classic 2/4-player pictures, pools, a custom map with no picture is
  made by the queue and cached with `Game.W` put back, 110 widgets drawn.
- `tools/shot_map_previews.gd`: contact sheets of every map (classic 2 and 4 players, named, campaign, pools) and
  the skirmish lobby with Frostfang, Twin Crowns and a random pool, desktop (`pc`) and phone (`mobile`):
  `docs/shots/map_previews/`.

```
godot --headless --script res://tools/make_map_previews.gd      # after changing a map or the generator
godot --headless --path . --import                              # new pictures get their .import files
godot --headless --path . --script res://tools/test_map_previews.gd
xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x1000 --script res://tools/shot_map_previews.gd -- res://docs/shots/map_previews pc
```

## Claude's choices

1. Hall spots drawn as gold rings stand for "resources" (the maps have no resource fields of their own).
2. The classic maps show one fixed layout (seed 7), not a schematic: closer to what you get than the old circle.
3. The bundled pictures include the campaign maps, so a briefing never waits.
4. The replay list shows no picture for classic maps (the replay's own layout differs from the preview's).
5. Start numbers are the side's number (as before), not the player's.
