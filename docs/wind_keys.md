# The Clockwork army's wind-up keys (job wind-keys)

The owner, 2026-11-15 20:15: most of the Clockwork army should carry a wind-up KEY on its back like the Winder has.
Chosen: ONE PAINTED KEY fixed on each unit's back in code, which TURNS while the unit has charge (its `wind`), slower
as it runs down, and STOPS when it is run down: the wind readable at a glance.

## The units

| unit (kind) | key size (bow, game px) | where | views |
| --- | --- | --- | --- |
| Clock Soldier (`clock_soldier`) | 13 | middle of the back, at the shoulder blades | all 8 (its own W / SW / NW strips measured on their own) |
| Springer (`springer`) | 14 | back of the red ball body | 5 (W mirrored) |
| Netter (`netter`) | 12 | the rear end-cap of its barrel body (a wind-up toy tank) | 5 |
| Pendulum (`pendulum`) | 16 | back of the clock case, upper half | 5 |
| Swift (`cuckoo`) | 9 | standing UP out of its back, between the wings | 5 |
| Ticking Owl (`ticking_owl`) | 11 | standing UP out of its back, between the wings | 5 |

Left out (as the owner said): the Winder and the Great Winder (their own painted key), the Spring Ballista (its crank
does the job), the shelved Line units. The Brass Serpent: **no key for now** (Claude's choice 1): its wind never runs
down while it has gears (`BrassSerpent.tick` holds it at 1.0), so its key would only ever turn at full speed and tell
nothing, and its body is drawn on its own art node (`BrassSerpent.redraw_art`), not the unit sprite the key rides on.
If the owner wants it anyway as decoration, the natural place is the head (the `u` key standing up, like the flyers').

Sizes: the Winder's bow is about 12-13 px wide on a body about 33 px tall. The keys keep roughly that look: the Clock
Soldier and the Springer about the Winder's, the Pendulum's bigger (its clock case is the biggest back), the flyers'
smaller (a 9 px bow on the Swift; a full-size one swamped the little bird).

## The art (tools/clockwork/import_wind_key.py)

Source: `art/redraws/wind_key/wind_key_chatgpt.png` (the owner's ChatGPT sheet, 5 rows x 8 frames, flat magenta).
ChatGPT did not turn the key between frames (row 3's last frame is even a stray face-on bow), so one still is used:
row 1 frame 1 (the figure-eight bow face-on, its stem under it). The magenta is keyed out with a despill (the
anti-aliased rim's alpha from how much magenta is left in it, red and blue pulled back to brass): no pink fringe.

The turning is made at import, one full turn in 16 frames, per view:

- **n** (the unit seen from behind; the shaft points at us): the bow face-on, turned in the picture's plane about its
  middle (the owner's rule), a short foreshortened stem behind it into the back. In front of the body.
- **s** (seen from the front): the same from the other side (mirrored, a touch darker: its far face), behind the body:
  only the bow peeking over the shoulders / head shows.
- **e** (side; W mirrored): the shaft sticks out of the back, the bow at its end; the bow's plane holds the shaft and
  turns about it, so its loops shrink toward the shaft with |cos(angle)| (face-on, edge-on, then its other face,
  mirrored: the shading flips between the halves). Seen edge-on it keeps the plate's thickness. Behind the body.
- **se / ne** (three-quarters): the same 3D turn seen from three-quarters (the shaft going away into the picture or
  out of it toward us): a mix of the two. SE behind the body, NE in front.
- **u** (new, for the flyers): the shaft standing straight up out of a bird's back, the bow turning about it like a
  carousel: the same from every direction.

The camera is orthographic from above with sin(elevation) 0.45 (the game's ground squash), so an edge-on bow is not at
90 degrees on screen: the thickness floor is on screen. Each frame is drawn big from the sheet's pixels, then shrunk
with premultiplied alpha and a hard alpha edge (`make_packs.shrink`), the brass lifted to the tones of the Winder's
painted key (the sheet's brass shrinks darker), the rim darkened and a 1 px dark outline added outside: brass on a
brass back (the Clock Soldier) still reads. Every colour the team shader swaps is nudged out of its reach.

Output: `assets/units/_shared/wind_key_<size>.png` (rows s, se, e, ne, n, u; 16 columns; the attachment point at the
middle of the square cell) for sizes 9, 11, 12, 13, 14, 16. (The brief suggested one strip per view: one sheet per size
with a row per view is the same frames with fewer files.)

## The anchors (scripts/wind_key_data.gd, written by the importer)

Per unit, per drawn direction, a hand-placed attachment point on the idle strip's first frame (game px from the feet)
and whether the key is in front of the body; then a patch of the body around that point is followed through every
frame of every strip drawn in that direction (`make_packs.track`, the battery packs' tracker), so the key stays on the
back through the walk bob, the attack lean, the Springer's leap (search reach 30 px), the flyers' flapping and the
Pendulum's high swing. Death strips carry no key. `WindKeyData.KEYS[kind]["keys"][strip]` = per frame
`[view row, in front, x, y]`.

To move a key: edit `UNITS` in the importer (the point per direction) and rerun
`python3 tools/clockwork/import_wind_key.py` (`--preview DIR --anims idle,walk --no-write --only <kind>` for contact
sheets without writing anything).

## In the game (scripts/wind_key.gd)

A `Sprite2D` child of the unit's body sprite, made with the battery pack in `Unit._draw_unit` (Clockwork, not workers,
kinds in `WindKeyData.KEYS`): it flips, bobs, leaps, hovers and goes cold with the body and shares its material.

- **Where**: `Unit._animate` steps it right after the body's frame is set (`_wkey.step(delta)`): the entry of the
  strip and frame on show; a west strip drawn unflipped (the Clock Soldier's own) shows the key mirrored (`flip_h`),
  and one with no spots of its own takes its east twin's mirrored.
- **The spin rule**: `turns += delta * wind / SPIN_T`, SPIN_T 1.2 s: a full turn every 1.2 s fully wound, slower as
  `wind` runs down, still at 0 (a run-down construct's key stands where it stopped). Each unit starts at its own angle
  so a squad's keys are not in step.
- **Hidden**: when the unit is dead (the death strip; the construct falls apart), on strips with no entry, and with the
  unit itself (fog, garrisoned, inside a building: the parent is hidden).
- **Perf**: no `_process` of its own; it moves only when `_animate` runs: 15 times a second, 10 in a big battle on
  screen (`anim_crowd`), never off screen. The strip's lookup is cached until the strip changes; setters only when the
  value changes. A run-down (powered down) unit steps it once as it slumps.
- **Measuring switch**: `windkeys:off` on the command line: no keys.

## Pictures and checks

- `docs/shots/wind_keys/<kind>_{idle,walk}_2x.png`: two rows of eight (S SE E NE N NW W SW), the top row fully wound,
  the bottom run down (the tool also writes 4x close-ups, `_4x_l` / `_4x_r`, left out of the repo for size); `docs/shots/wind_keys/<kind>.gif`: the top row walking, S SE E NE fully wound, N NW
  W SW at 35% (turning slower). Made by `tools/shot_wind_keys.gd` (Clockwork Lab) and `tools/wind_keys_gif.py`.
- Swarm perf (tools/stress_swarm.gd `pair a:clockwork b:clockwork n:200 secs:20`, headless, this cloud machine; see
  "Perf numbers" below).

## Claude's choices (for the owner)

1. The Brass Serpent has no key (see above).
2. The flyers' keys stand UP out of the back (a bird's back is its top), turning like a carousel, rather than sticking
   out behind.
3. The Netter's key is in the rear end-cap of its barrel (a wind-up toy tank), not on top (its gun turret is there).
4. In the front views the key is behind the body and mostly hidden (as the Winder's): on the Springer and the Pendulum
   the point is set high so the bow shows over the head / roof.
5. The S view's key is the bow's far face, a touch darker; the N view the near face.
6. The keys are a little brighter than the sheet (lifted to the Winder's key's brass) and outlined in dark brown.
7. Not every key of a squad turns in step (each starts at its own angle).
8. One sheet per size with all views (rather than a file per view).

## Perf numbers

`tools/stress_swarm.gd pair a:clockwork b:clockwork n:200` (200 Clockwork a side, nearly all of them keyed, the whole
battle in view: the worst case), this cloud machine (2 cores), keys on v `windkeys:off`:

| run | keys on | keys off |
| --- | --- | --- |
| headless 20 s, run 1 (key with its own `_process`, first version) | 10.97 ms a frame | 10.69 |
| headless 20 s, run 2 (stepped by `_animate`) | 11.47 | 11.10 |
| headless 20 s, run 3 | 11.03 | 10.68 |
| headless 20 s, the key's `step` a no-op (the bare node) | 11.18 / 11.15 | |
| rendered (xvfb, llvmpipe software GL) 15 s | 170.5 ms, 1691 draw calls | 157.7 ms, 1470 draw calls |

So about +0.35 ms a frame (+3%) with 400 keyed units in view, and that is nearly all the extra node itself (a child
sprite moving with each body), not the key's own work; drawn, one extra draw call per key on screen (a key's texture
breaks the batch between two bodies, as the battery packs do). Kept small by: no `_process`, steps only when the body
steps (15 Hz, 10 Hz in a big battle, none off screen), setters only on change, hidden zoomed out past 0.75 (the camera
goes to 0.55). If phones need more: hide the keys while `anim_crowd` (a big battle on screen) too: one line in
`WindKey.step`.

## Tests

- `tools/test_wind_keys.gd`: the table (a spot for every frame of every strip but death, within the cell, the sheets'
  sizes), which units carry one, the spot on the body's frame, the spin rule (a quarter turn in 0.3 s fully wound,
  half as fast at half wind, still at 0), the own-west mirror, the flipped east strip, hidden zoomed out and dead: all pass.
- Clockwork tests run with the keys on: test_clockwork_army, test_cw_army, test_cw_air, test_cw_tier2,
  test_pendulum_v2, test_pendulum_air, test_springer_arms, test_springer_compat, test_exhaust, test_brass_serpent,
  test_online_anim, test_cw_lab, test_clockwork_owls pass. test_clock_soldier_shield fails only its "online: the
  guest has the soldier" check, the same with `windkeys:off` (this machine's online loopback); test_cw_tier3's 3 online
  checks fail as on main (CLAUDE.md).
