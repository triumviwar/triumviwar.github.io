# Sprite hallucination audit (job sprite-hallucination-audit, 2026-11-21)

The owner asked on 2026-11-21 for every sprite strip to be checked for frames ChatGPT drew wrong, like the Brood Mother's
laying strip with two tails (fixed in 0.38.105). This is an audit and a list only: nothing in the game was changed. The
owner checks the list; the redraws are done later, one strip at a time, in ChatGPT.

## Summary

- 244 contact sheets were made and looked at, covering about 2,600 strips and pictures: every unit strip in
  assets/units (87 folders, every animation and facing, every Brood stage), the buildings, the effects, the props, the
  icons, the interface pictures, the world pieces, the main menu painting, the campaign stills, portraits, hub rooms and
  war map art, and the rebel units. The ground tiles in assets/terrain and assets/tiles were not checked (no figures in them).
- 211 findings: 11 HIGH, 83 MEDIUM and 117 LOW.
- The stage 1 Brood Mother laying strip is fine now: one tail in every frame. The laying strips at stages 2 and 3 also
  have one tail.
- Most problems are not extra limbs. The biggest family is WRONG OR DRIFTING FACINGS, above all on the riders: a north or
  north-east strip that is really a south-east view, a strip copied from another facing, or a gallop whose angle turns
  during the loop. The second family is a body that CHANGES DESIGN between animations: the Raptor's old idle next to its
  redrawn run, the Springer's claw arm when it shoots up, the grub carrying a cocoon. True extra parts are fewer but
  glaring: a second pike on the rebel pikeman, a Guardsman standing on one leg, two sabres on the Cuirassier, a doubled
  Skywing.
- The pixel scans found no magenta specks in the Brood strips, the icons or the props. Magenta is left in a few campaign pictures: the war map ships'
  rigging and the King's pipe smoke in the Rome hub. Navy patches are trapped in two Brood flyers (the Pterodactyl and
  the Storm Challenger, south-east fly loop).
- Tone: the campaign stills and portraits fit the game's Catholic and monarchist tone; no pagan figures, no naked putti,
  no gibberish lettering. One icon is out of tone: the Brood RALLY icon is a skull totem with a feather headdress
  (finding list, MEDIUM), which gives the Brood a tribal culture it should not have.
- Eleven ready ChatGPT redraw requests are written below, one for each HIGH finding, with their reference pictures in
  docs/redraw_refs/sa01 to sa11.

## How it was done, and the limits

- `tools/audit/contact_sheets.py` cuts every strip into its frames (frame sizes from the game's own tables:
  scripts/art_data.gd, cw_art.gd, rebel_art.gd, band_art.gd, gun_crew_art.gd; other strips by guessing the cell) and
  lays them out on plain grey, numbered from 0, with a red line at the feet for units. Run
  `python3 tools/audit/contact_sheets.py /tmp/sheets` to make them again (a few seconds), or `--only raptor` for one unit.
- Seven reviewers (Claude helpers), one per area, looked at every sheet and zoomed into the original files where a sheet
  was too small. I, the lead, then looked at the picture of every HIGH finding and a sample of the MEDIUM ones myself.
  The HIGH ones are all confirmed. Two ratings were changed: the Springer's claw arm went from HIGH to MEDIUM (it shows
  only when it shoots at a flyer), and the Dragoon's south gallop went from MEDIUM to HIGH (a common unit on a common
  walk).
- Each finding says how sure the reviewer was. A finding marked "likely" or "unsure" should be looked at in the game
  before a redraw is ordered.
- The guessing of the frame size cut some effect, wall and map pieces wrongly (for example ballista_bolt, fire,
  zap_strike, the wind keys, rome_desk, the mountain pieces, a few Brass Serpent and Tesla Cart rows). Those rows were
  not checked frame by frame and are not counted as findings.
- The "source sheet" given for each finding is the best guess by file name among the pictures in art/ (art/redraws/
  first). It is a pointer, not a proof: check the importer named in the file's history before redrawing.
- The full data is in `docs/sprite_audit/findings.json` (one entry a finding: file, frames, problem, severity, kind,
  confidence, picture, source). Each finding has a picture in `docs/shots/sprite_audit/`: the whole strip, the frames
  that are wrong framed in red. The lists below are made from the data by `python3 tools/audit/list_findings.py HIGH`
  (or MEDIUM, LOW).

## The HIGH findings (obvious in play)

### Brood

- **1. Raptor, idle south-east**, frame 0: The idle frames idle_s, idle_se and idle_n are an older, bulkier Raptor design, about 1.3x the size of the redrawn slim walk frames (thicker body, different crest, more frontal stance). Each time a Raptor stops walking it pops to a bigger, differently drawn creature. idle_se is also drawn facing straight south (front-on), not south-east, so a Raptor walking SE turns to face the camera when it stops. idle_e matches the walk_e design and is fine.
  File `assets/units/raptor/idle_se.png`. Picture `docs/shots/sprite_audit/001_units_raptor_idle_se.png`. Source sheet (best guess by name): `art/redraws/raptor_walk_n_chatgpt.png`, `art/redraws/raptor_walk_ne_chatgpt.png`.
- **2. Tyrant Challenger, death north**, frames 0, 1, 2, 3 and 4: The north death never falls: all 5 frames are a standing back view and match the walk_n frames almost exactly (best match a walk frame in every case). A Challenger killed while facing north just walks in place and then vanishes.
  File `assets/units/tyrant_challenger/death_n.png`. Picture `docs/shots/sprite_audit/002_units_tyrant_challenger_death_n.png`. Source sheet (best guess by name): `art/redraws/tyrant_challenger_portrait_chatgpt.png`, `art/redraws/young_tyrant_concept_chatgpt.png`.

### Campaign art and rebels

- **3. Rebel Pikeman, walk south**, frame 2: A SECOND pike appears: the man still carries his pike over the shoulder and holds another pike raised in his front hand; frames 0-1 have one pike. Flickers every walk cycle.
  File `assets/units/rebel_pikeman/walk_s.png`. Picture `docs/shots/sprite_audit/003_units_rebel_pikeman_walk_s.png`. Source sheet (best guess by name): `art/campaign/rebels/pikeman_chatgpt.png`.
- **4. Rebel Pikeman, walk south-east**, frame 2: Same as walk_s: a second pike in the raised hand on top of the shouldered one (two pikes).
  File `assets/units/rebel_pikeman/walk_se.png`. Picture `docs/shots/sprite_audit/004_units_rebel_pikeman_walk_se.png`. Source sheet (best guess by name): `art/campaign/rebels/pikeman_chatgpt.png`.

### Crown on foot

- **5. Armoured Musketeer (Guardsman), idle south**, frame 1: Frame 1 stands on ONE leg: only a single boot/leg under the cuirass (frame 0 has two). The idle flickers between two legs and one leg.
  File `assets/units/musketeer_armoured/idle_s.png`. Picture `docs/shots/sprite_audit/005_units_musketeer_armoured_idle_s.png`. Source sheet (best guess by name): `art/redraws/musketeer_armoured_aim_ne_chatgpt.png`, `art/redraws/musketeer_armoured_aim_s_chatgpt.png`.

### Crown riders and wagons

- **6. Cuirassier, attack north**, frames 0, 1, 2 and 3: Wrong facing: the N sabre attack shows the horse and rider coming toward the camera at a SE three-quarter angle (rider's face and breastplate front visible), not from behind. A Cuirassier attacking northward turns to face the viewer.
  File `assets/units/cuirassier/attack_n.png`. Picture `docs/shots/sprite_audit/006_units_cuirassier_attack_n.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **7. Cuirassier, attack north-east**, frames 0, 1, 2 and 3: Wrong facing: the NE attack is also a front/SE three-quarter view (horse head lower right, rider facing the camera), essentially another SE strip.
  File `assets/units/cuirassier/attack_ne.png`. Picture `docs/shots/sprite_audit/007_units_cuirassier_attack_ne.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **8. Dragoon, walk south**, frames 0, 1, 2, 3, 4, 5, 6, 7, 8 and 9: The S gallop is a SE three-quarter view (horse heading to the viewer's right), not toward the camera; frame 9 jumps to a different angle. walk_se in turn is close to a side profile. Raised to HIGH by the lead reviewer: the Dragoon is common and walking south is common. An older prompt for it exists (21_dragoon_walk_south in docs/animation_redraw_prompts_2.md) but was never imported.
  File `assets/units/dragoon/walk_s.png`. Picture `docs/shots/sprite_audit/008_units_dragoon_walk_s.png`. Source sheet (best guess by name): `art/crown/dragoons.png`, `art/crown/mount/dragoon_armoured_mount.png`.
- **9. Armoured Dragoon, walk north-east**, the whole strip: walk_ne is an exact copy of walk_e, and walk_e itself is a SE-like three-quarter view with the rider's face toward the camera, so riding NE (and E) he appears to ride toward the viewer. idle_ne == idle_e and death_ne == death_e too.
  File `assets/units/dragoon_armoured/walk_ne.png`. Picture `docs/shots/sprite_audit/009_units_dragoon_armoured_walk_ne.png`. Source sheet (best guess by name): `art/crown/mount/dragoon_armoured_mount.png`, `art/crown/mount/dragoon_armoured_mount_n.png`.
- **10. Horseman, walk north-east**, frames 0, 1, 2, 3, 4, 5 and 6: Facing drifts across the gallop: frame 0 is a true NE rear view, frames 1-2 in between, frames 3-6 nearly an E side profile. The rider turns ~45 degrees during one loop; the red saddle cloth also jumps from a large blob (1-2) to a small patch (3-4).
  File `assets/units/horseman/walk_ne.png`. Picture `docs/shots/sprite_audit/010_units_horseman_walk_ne.png`. Source sheet (best guess by name): `art/crown/horseman.png`, `art/crown/horseman_attack_death.png`.
- **11. Powder Wagon, walk north**, frames 0, 1, 2, 3, 4 and 5: Seen from the back (barrels toward the viewer) but the horse is drawn BELOW/in front of the wagon's tailboard, i.e. the horse is behind the wagon pushing it; driving north the horse should be ahead (above) and mostly hidden by the wagon. Same composition in idle_n and the unload_n/death_n frames. (likely)
  File `assets/units/powder_wagon/walk_n.png`. Picture `docs/shots/sprite_audit/011_units_powder_wagon_walk_n.png`. Source sheet (best guess by name): `art/crown/powder_wagon.png`, `art/crown/mill_base/powder_mill_built.png`.

## Done (2026-11-21, 0.38.114-0.38.116)

The owner said "Redraw all". The eleven requests below were made one at a time in ChatGPT and imported:
R1 Raptor idle S/SE/N (tools/import_raptor_idle_sa.py), R2 Tyrant Challenger death N (tools/import_tyrant_death_n_sa.py),
R3/R4 rebel pikeman walk S/SE, R5 Guardsman idle S, R6/R7 Cuirassier attack N/NE, R8 Armoured Dragoon walk NE (now 6
frames), R9 Horseman walk NE (now 8 frames; the request's "white coat, tricorne" was wrong, the answer was redone with
the grey horse and plumed hat of the other views), R10 Powder Wagon walk N (+ idle_n from its first frame), R11 Dragoon
walk S (now 6 frames): all with tools/import_sa_strip.py (one row of figures, scaled to a reference strip's height, or
width with SA_BY=width, feet on its feet). Finding 89, the Brood RALLY icon: now three claw scratches in mossy ground
with a scent mist and the yellow arrow (art/ui/icons3/brood_rally_2.png, tools/import_brood_rally_2.py). MEDIUM findings done (0.38.116): M70, M71 (Cuirassier attack E/SE),
M73, M74, M75 (Cuirassier walk NE/S/SE). Their requests come from tools/audit/medium_batch.py (JOBS: refs in
docs/redraw_refs/sm<NN>_*/, prompts as JSON); next in its list: M79, M80, M82 (Horseman), M76, M77 (Armoured Dragoon),
M63-M65 (Musketeer), M67, M68 (Guardsman); then the other MEDIUM findings need JOBS entries. Still to do: the rest of
the MEDIUM findings; the Brood rally CURSOR (a flag on a pole) may want the same change.

## Done (2026-11-22, 0.38.125-0.38.129)

MEDIUM findings: M79, M80, M82 (Horseman attack N/NE, walk S), M76, M77 (Armoured Dragoon idle E, walk N), M63-M65
(Musketeer idle S, melee N, reload N), M67, M68 (Guardsman melee N, walk S, now 6 frames). The Brood (0.38.129):
21 Raptor death E redrawn (falls once, stays down); 13 Brute attack E redrawn (a horned head-butt, the old strip spat
acid it never uses); 24 Tyrant Sire death SE redrawn (the crouched Sire from the first frame); 25 Tyrant Challenger
death SE: frame 3 (the limb out of the back) replaced by frame 4 (its redraw came out brighter green and side-on, so the
old strip was kept); 16 Hatchlings and 23 Storm Challenger fly SE: the truncated code-patched frame 2 replaced by frame 3;
20 and 23 the navy patch between wing and neck made see-through (tools/clear_navy_patches.py); 22 Storm Challenger
north: the fly loop and the swoop's frames 0, 4, 5 flipped top to bottom so the beak points away in every north frame
(tools/flip_storm_n.py). A reptilian Hatchlings design (a small wyvern) came out of the SE request and is kept as an
idea for finding 92 (the chicken-like Hatchlings) in art/redraws/ideas/hatchlings_wyvern_se_chatgpt.png: changing
it means every view and the portrait, an owner's call. 0.38.130: 15 Grub harvest S, frames 3-4 (the side view) replaced
by frames 2 and 1 (front on); 17 and 18 the Sire lures' arrival: the pit of the last frame laid behind frames 6-11, so
the ground no longer blinks (tools/lure_pit_steady.py). 19 Mist Toad fog E: no white blotches left in the current
strip (checked); its size still steps down between frames 3 and 4. 0.38.131: the Missionary's north walk and idle redrawn from behind
(they showed his face; requests M90, M91), and his north-east idle shows its upright frame twice (the hunched first frame
switched pose). 0.38.132: the loose chunk beside the Musketeer's and Guardsman's east death, and the rein scraps and
stray hoofs beside the mounting riders of the Barracks drills (Cuirassier, Horseman, Dragoon, Armoured Dragoon), removed
(tools/drop_loose_bits.py: pieces smaller than a share of the frame's biggest). Left: the carbine on the Horseman's back
in mount_e/se frames 3-6 (two pixels wide at game size). 0.38.133: the Officer on foot (dismounted) aims and fires in every facing: S, SE, NE and N
redrawn (requests M92-M95, one sheet a facing: the aim frame and two fire frames, cut into aim_<dir> and fire_<dir>);
0.38.134: his sabre slash too, in S, SE, NE and N (M96-M99). His death is still the east picture in every facing.
0.38.135: 43 the Netter's south view redrawn end-on (walk_s 8 frames, attack_s 6, death_s 5; idle_s from the new walk;
requests M100-M102): the barrel points at you, as the north view shows its back.
0.38.136: 53 the Ticking Owl's north-east fly loop starts from behind (frame 0 was the owl turned east; now the north view's
wings-up frame, laid on the body); 61 the Mortar's shot is the small bronze mortar with the flash and smoke at its mouth
(frame 0 was a bigger black barrel); 165 its wreck lifted onto the ground line; 39 the Spring Ballista's wreck: a
drawing that reached over the cell's top made just small enough to fit (tools/import_ballista.py); 139 the Clock
Soldier's loose heel speck in guard_walk_e removed; 146 the Pendulum's north and north-east walk on one ground line.
0.38.137: the Officer on foot dies where he faces (death S, SE, NE, N redrawn, M103-M106); 83 the Missionary's death SE and
E redrawn in order and at one size (M107, M108; E is now 4 frames).
0.38.138: 86 the mounted Missionary's east walk keeps its cross in every frame (M109); 87 his south walk comes toward
you, the horse head-on (M110).
0.38.139: 47 the Springer's attack_up keeps its drill arm (the claw arm replaced by the idle frame's drill arm, every
facing); 48 its death: the two standing frames get the drill arms too (the tumbling wreck keeps the old drawing);
44 the Pendulum's high swing S and N: the resting hand gets its blade (copied from the other strip's rest pose).
0.38.140: 36, 127 the torch-bearer's loose specks while setting fire removed; 114 the Powder Mill horse's navy specks painted
over; 130 the King's pink pipe smoke made grey and the pink fleck in his hair (hub figure and portrait) removed; 137 the
pink fringe under the war map's mountains removed; 151 the musicians' death on the feet line.
0.38.141: 54 the Field Cannon's east, south-east and north-east deploy keep the gun side-on while the horse goes (frames 2-3
flipped to a head-on gun with its barrel up: now frame 1's gun and crew with those frames' horse); 55 the south deploy's
side-view frame 2 replaced by frame 1. Left: the dithered fading horse.
0.38.142: 60 the Mortar's deploy redrawn for E, SE and S (requests M111-M113: the grey horse unhitched and led aside, the
mortar lifted off the cart and set down; SE came out nearly side-on); `SA_GAP=<px>` in tools/import_sa_strip.py cuts an
answer's frames at gaps wider than px (a frame made of separate pieces). 0.38.147: NE too (M114). N is still the old
collage (its answer drew the horse facing the viewer in the first frames).
0.38.148: 186 the Missionary's north bandage shows his back (the kneeling priest from missionary_bandage_c laid over
the old patient); 35, 125 the rebel Pikeman's brace and thrust S and SE redrawn with the pike level (M116, M117: one
answer of 4 frames each, cut into brace (frame 1) and attack (frames 2-4)); 124 his north thrust at one slant (M118).
0.38.149: 33 the Crown campaign Pikeman's north-east walk frame 1 (two pike shafts) replaced by frame 3; 188 the Powder
Wagon's south-east walk frames 0-1 (more front-on) replaced by frames 4-5; 102 the Spitter's east spit frame 3 gets frame 2's
full tail.
0.38.150: 103 the Tyrant Challenger's south death redrawn facing you all the way down (M119); 104 the Venom
Challenger's south death the same (M120). Its NE and N deaths (M121, M122) still wait: ChatGPT drew NE as a side
profile again, and that account's attachment limit was reached.
0.38.151 (tools/audit_low_fixes.py, no redraw): 168 the Musketeer's and Guardsman's north idle frame 2 (a different
coat) replaced by frame 0; 181 the Horseman's south attack frame 2 (the horse twisting) by frame 1; 161 the Labourer's
keg idle frame 0 (keg on the chest) by frame 1; 141 the Swift's (cuckoo) north-east fly frame 0 (turned east) by frame 2;
156, 169 specks by the Armoured Officer's south death and the Guardsman's fire-up removed; 145 the Pendulum's pink pixels
at the blade; 200 the Tension icon's corner specks; 201 the loose piece by the mossy boulder; 207 the loose specks
round the snowy rocks (c, d).

## Redraw requests for the HIGH findings

One request a strip (the Raptor's is three one-frame idles in one row). Every request stands alone, in the same style as
the older sets (docs/animation_redraw_prompts_2.md): attach the reference pictures named, in that order, then paste the
text in the box. The reference pictures are the CURRENT game strips enlarged with hard pixels on the answer sheet's navy,
each frame labelled; they are made by `python3 tools/audit/make_refs.py`. Save ChatGPT's answer under the name given,
look at it (one row, the right number of frames, all the same size, nothing touching), then import it.

### R1. Raptor standing (idle), south, south-east and north

Prompt id: `sa01_raptor_idle`. Fixes finding 1. Save the answer as `art/redraws/raptor_idle_sa_chatgpt.png`.

**Attach (2 images, in this order), from `docs/redraw_refs/sa01_raptor_idle/`:**

1. `1_current_raptor_idle.png`: The Raptor's CURRENT idle in four views: the south, south-east and north ones are an OLD, bulkier design and too big; the east one (two frames) is right. This is what gets replaced.
2. `2_raptor_walk_model.png`: The Raptor's walk in four views: THE MODEL for the design, size, crest, colours and proportions.

**Prompt:**

```
Make ONE row only. Draw the Raptor standing still in three views, the same lean, slim small raptor as the walk of reference 2: same head and crest, same red spines along the back (pure bright red), same olive scales, same long tail held out level, same size as the walk frames (NOT bigger). South: facing the viewer, the head toward us, the tail behind. South-east: turned three-quarter to the lower right, like the walk_se row. North: seen from behind, the tail toward us, like the walk_n row. Weight on both legs, the arms tucked, the head up and alert. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the walk's design and size in reference 2; the east idle of reference 1. AVOID: the bulky old body of reference 1, a front view in the south-east slot, a bigger figure than the walk, two tails, a crest of a different shape. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a gunpowder-age RTS whose monsters are reptiles and dinosaurs (reptilian first, never insect-like), three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 4 by 4 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (three views of ONE standing pose: first facing the viewer (south), then turned three-quarter toward the lower right (south-east), then seen from behind (north)), 3 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 232 px wide and 120 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_raptor_walk_sn.py has the Raptor's scale and anchor: add an idle step (the three frames to idle_s, idle_se, idle_n, 1 frame each) or a small new importer on tools/redraw_lib.py. Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R2. Tyrant Challenger death, seen from behind (north)

Prompt id: `sa02_tyrant_challenger_death_n`. Fixes finding 2. Save the answer as `art/redraws/tyrant_challenger_death_n_chatgpt.png`.

**Attach (3 images, in this order), from `docs/redraw_refs/sa02_tyrant_challenger_death_n/`:**

1. `1_current_death_n.png`: The CURRENT north death: five standing back views that never fall. This is what gets replaced.
2. `2_death_se_e_model.png`: The south-east and east deaths: THE MODEL for how he falls (stagger, sag, collapse on his side, still).
3. `3_walk_n_back_view.png`: The north walk: the creature seen from behind, its design, spines and colours to keep.

**Prompt:**

```
Make ONE row only. Draw the young Tyrant Challenger (a two-legged predator dinosaur, reptilian, red spines down the back) DYING, seen from behind (the tail toward us, the head away from us), 5 frames: 1 hit, rearing back with the head thrown up; 2 staggering, one leg buckling; 3 falling to its side, the tail swinging; 4 lying on its side on the ground, seen from behind; 5 lying still, flat. The same figure and size as reference 3, the same fall as reference 2 but from behind. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the creature of reference 3 (design, spines, colour, size); the timing of reference 2. AVOID: a standing pose in every frame, a front view, the head toward the viewer, extra legs or a second head, blood pools. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a gunpowder-age RTS whose monsters are reptiles and dinosaurs (reptilian first, never insect-like), three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 3 by 3 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the north view only: seen from behind, the tail toward the viewer), 5 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 283 px wide and 205 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_brood_mature.py (the young Brood's importer): write only death_n, 5 frames, cell 88 x 64. Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R3. Rebel Pikeman walking toward the viewer (south)

Prompt id: `sa03_rebel_pikeman_walk_s`. Fixes finding 3. Save the answer as `art/redraws/rebel_pikeman_walk_s_chatgpt.png`.

**Attach (2 images, in this order), from `docs/redraw_refs/sa03_rebel_pikeman_walk_s/`:**

1. `1_current_walk_s.png`: The CURRENT south walk: frame 2 shows a SECOND pike raised in his hand on top of the one on his shoulder. This is what gets replaced.
2. `2_walk_e_ne_model.png`: His east and north-east walk: THE MODEL for the man, his clothes and how he shoulders ONE pike.

**Prompt:**

```
Make ONE row only. Draw the Free Assembly's rebel pikeman (a commoner in a dark coat and hat, a long wooden pike with an iron head over his shoulder) walking toward the viewer, 3 frames, a seamless loop: left foot forward, passing, right foot forward. He carries ONE pike, always on the same shoulder at the same slant, both hands on the shaft or one hand on it and the other arm swinging. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the man, coat, hat and colours of reference 2; the pike's length and the slant of reference 1's frames 0 and 1. AVOID: a second pike, the pike changing shoulder or angle between frames, the pike cut by the figure's box. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 4 by 4 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the south view only: walking toward the viewer), 3 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 408 px wide and 248 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_rebels.py (the rebel pikeman; only walk_s, 3 frames, cell 102 x 62). Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R4. Rebel Pikeman walking toward the lower right (south-east)

Prompt id: `sa04_rebel_pikeman_walk_se`. Fixes finding 4. Save the answer as `art/redraws/rebel_pikeman_walk_se_chatgpt.png`.

**Attach (2 images, in this order), from `docs/redraw_refs/sa04_rebel_pikeman_walk_se/`:**

1. `1_current_walk_se.png`: The CURRENT south-east walk: frame 2 shows a SECOND pike raised in his hand. This is what gets replaced.
2. `2_walk_e_ne_model.png`: His east and north-east walk: THE MODEL for the man and his ONE pike.

**Prompt:**

```
Make ONE row only. Draw the Free Assembly's rebel pikeman (a commoner in a dark coat and hat, a long wooden pike with an iron head over his shoulder) walking three-quarter toward the lower right, 3 frames, a seamless loop: left foot forward, passing, right foot forward. He carries ONE pike, always on the same shoulder at the same slant. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the man, coat, hat and colours of reference 2; the pike's length and slant of reference 1's frames 0 and 1. AVOID: a second pike, the pike changing shoulder or angle between frames, the pike cut by the figure's box. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 4 by 4 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the south-east view only: walking three-quarter toward the lower right), 3 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 408 px wide and 248 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_rebels.py (the rebel pikeman; only walk_se, 3 frames, cell 102 x 62). Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R5. Guardsman (Armoured Musketeer) standing, facing the viewer

Prompt id: `sa05_guardsman_idle_s`. Fixes finding 5. Save the answer as `art/redraws/guardsman_idle_s_chatgpt.png`.

**Attach (2 images, in this order), from `docs/redraw_refs/sa05_guardsman_idle_s/`:**

1. `1_current_idle_s.png`: The CURRENT idle facing the viewer: frame 1 stands on ONE leg. This is what gets replaced.
2. `2_guardsman_idle_other_views.png`: The Guardsman standing in the other views and aiming south: the man, armour, helmet and musket to keep.

**Prompt:**

```
Make ONE row only. Draw the Guardsman (a musketeer in a steel morion helmet and breastplate over a red coat, a long musket held upright at his side, butt on the ground) standing still facing the viewer, 2 frames of a quiet breathing idle: frame 2 differs from frame 1 only by a slight rise of the shoulders and chest. BOTH legs and both boots visible in both frames, feet a little apart. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the man, armour, colours and musket of reference 2; the size of reference 1's frame 0. AVOID: one leg, the musket moving or vanishing between frames, a different helmet, a bigger second frame. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 4 by 4 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the south view only: facing the viewer), 2 frames left to right, on an image of 1536 by 512 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 360 px wide and 144 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_musket_aim_dirs.py / tools/import_vet_trim.py --only musketeer_armoured (idle_s, 2 frames, cell 90 x 36). Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R6. Cuirassier sabre attack, seen from behind (north)

Prompt id: `sa06_cuirassier_attack_n`. Fixes finding 6. Save the answer as `art/redraws/cuirassier_attack_n_chatgpt.png`.

**Attach (3 images, in this order), from `docs/redraw_refs/sa06_cuirassier_attack_n/`:**

1. `1_current_attack_n.png`: The CURRENT north attack: it shows horse and rider coming TOWARD the viewer. This is what gets replaced.
2. `2_attack_e_se_model.png`: The east and south-east attack: THE MODEL for the blow (raise the sabre, cut, follow through, recover).
3. `3_walk_n_back_view.png`: The north gallop: horse and rider seen from behind, to keep.

**Prompt:**

```
Make ONE row only. Draw the Cuirassier (a heavy cavalryman in a steel helmet and breastplate on a dark horse) striking with his sabre while riding AWAY from the viewer, seen from behind (the horse's rump and tail toward us, its head away from us), 4 frames: 1 sabre raised over his right shoulder; 2 the cut coming down to the right of the horse's neck; 3 the follow-through low at the horse's right side; 4 recovering upright. ONE sabre, always in his right hand. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the horse, rider and colours of reference 3; the blow's timing of reference 2. AVOID: the rider's face or breastplate front visible, the horse's head toward the viewer, two sabres in one frame, a different horse coat. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 4 by 4 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the north view only: horse and rider seen from behind, riding away from the viewer), 4 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 359 px wide and 256 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_redraw_mounted.py (only attack_n, 4 frames, art 'cuirassier', cell 98 x 70). Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R7. Cuirassier sabre attack, toward the upper right (north-east)

Prompt id: `sa07_cuirassier_attack_ne`. Fixes finding 7. Save the answer as `art/redraws/cuirassier_attack_ne_chatgpt.png`.

**Attach (3 images, in this order), from `docs/redraw_refs/sa07_cuirassier_attack_ne/`:**

1. `1_current_attack_ne.png`: The CURRENT north-east attack: another front view. This is what gets replaced.
2. `2_attack_e_se_model.png`: The east and south-east attack: THE MODEL for the blow.
3. `3_walk_n_ne_back_views.png`: The north and north-east gallop: the back three-quarter angle and the horse and rider to keep.

**Prompt:**

```
Make ONE row only. Draw the Cuirassier (a heavy cavalryman in a steel helmet and breastplate on a dark horse) striking with his sabre while riding away toward the upper right, seen three-quarter from behind (the horse's rump toward the lower left, its head toward the upper right), 4 frames: 1 sabre raised over his right shoulder; 2 the cut coming down past the horse's right shoulder; 3 the follow-through low; 4 recovering upright. ONE sabre, always in his right hand. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the horse, rider and colours of reference 3; the blow's timing of reference 2. AVOID: the rider's face toward the viewer, the horse heading to the lower right, two sabres in one frame, a different horse coat. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 4 by 4 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the north-east view only: horse and rider seen three-quarter from behind, riding away toward the upper right), 4 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 359 px wide and 256 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_redraw_mounted.py (only attack_ne, 4 frames, art 'cuirassier', cell 98 x 70). Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R8. Armoured Dragoon gallop toward the upper right (north-east)

Prompt id: `sa08_armoured_dragoon_walk_ne`. Fixes finding 9. Save the answer as `art/redraws/armoured_dragoon_walk_ne_chatgpt.png`.

**Attach (3 images, in this order), from `docs/redraw_refs/sa08_armoured_dragoon_walk_ne/`:**

1. `1_current_walk_ne_e.png`: The CURRENT north-east and east gallops: they are the SAME strip, both riding toward the viewer. This is what gets replaced (north-east only).
2. `2_walk_n_back_view.png`: The Armoured Dragoon's north gallop from behind: the rider, armour and horse to keep.
3. `3_dragoon_walk_ne_model.png`: The plain Dragoon's north-east gallop: THE MODEL for the angle and the gait.

**Prompt:**

```
Make ONE row only. Draw the Armoured Dragoon (a mounted musketeer in a steel helmet and breastplate, carbine slung across his back, on a dark horse) galloping away toward the upper right, seen three-quarter from behind, 6 frames, a seamless gallop loop. The angle of reference 3, the man and horse of reference 2. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the rider and horse of reference 2; the angle and gait of reference 3. AVOID: the rider's face toward the viewer, a side profile, the angle drifting between frames, extra legs, a different horse coat. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 2 by 2 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the north-east view only: seen three-quarter from behind, galloping toward the upper right), 6 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 232 px wide and 165 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_redraw_mounted.py (only walk_ne, 6 frames, art 'dragoon_armoured', cell 98 x 70); also copy idle_ne / death_ne from the new frames only if the owner wants (today they are the east ones). Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R9. Horseman gallop toward the upper right (north-east)

Prompt id: `sa09_horseman_walk_ne`. Fixes finding 10. Save the answer as `art/redraws/horseman_walk_ne_chatgpt.png`.

**Attach (2 images, in this order), from `docs/redraw_refs/sa09_horseman_walk_ne/`:**

1. `1_current_walk_ne.png`: The CURRENT north-east gallop: frame 0 is right, then the horse turns to a side view by frame 3. This is what gets replaced.
2. `2_walk_n_e_model.png`: The north and east gallops: the horse, rider, saddle cloth and gait to keep.

**Prompt:**

```
Make ONE row only. Draw the Horseman (an officer on horseback, white coat, tricorne hat, sabre at his side, a pure red saddle cloth) galloping away toward the upper right, seen three-quarter from behind (the horse's rump toward the lower left), 8 frames, a seamless gallop loop, the SAME angle in every frame: the angle of frame 0 of reference 1. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the angle of reference 1's frame 0; the horse, rider and gait of reference 2. AVOID: the angle drifting toward a side view, the saddle cloth changing size between frames, extra legs, a sabre drawn. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 2 by 2 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the north-east view only: seen three-quarter from behind, galloping toward the upper right), 8 frames left to right, on an image of 1536 by 512 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 169 px wide and 121 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_redraw_mounted.py (only walk_ne, 8 frames, art 'horseman', cell 98 x 70). Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R10. Powder Wagon driving away from the viewer (north)

Prompt id: `sa10_powder_wagon_walk_n`. Fixes finding 11. Save the answer as `art/redraws/powder_wagon_walk_n_chatgpt.png`.

**Attach (2 images, in this order), from `docs/redraw_refs/sa10_powder_wagon_walk_n/`:**

1. `1_current_walk_n.png`: The CURRENT north drive: the horse is drawn BELOW the tailboard, behind the wagon, as if pushing it. This is what gets replaced.
2. `2_walk_s_se_e_model.png`: The south, south-east and east drives: the wagon, its canvas cover, kegs, lanterns, flag, driver and horse to keep.

**Prompt:**

```
Make ONE row only. Draw the Powder Wagon (a two-wheeled covered cart with powder kegs, a pure red pennant on a pole, lanterns, a driver in a red coat on the box) pulled by ONE dark horse, driving AWAY from the viewer: we see the back of the wagon (the tailboard and kegs) at the bottom of the figure, and the horse AHEAD of it at the top, mostly hidden by the canvas cover, only its head and ears showing above. 6 frames, a seamless loop: the wheels turning, the wagon rocking a little. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the wagon, colours and size of reference 2. AVOID: the horse below or behind the wagon, the driver facing the viewer, a different wagon. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 4 by 4 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the north view only: the wagon seen from behind, driving away from the viewer), 6 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 232 px wide and 309 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_round11.py is the last importer that wrote the Powder Wagon; a small importer on tools/redraw_lib.py will do (only walk_n, 6 frames, cell 60 x 80). idle_n, unload_n and death_n share the mistake: redraw them the same way later, or take frame 1 of this sheet for idle_n. Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

### R11. Dragoon gallop toward the viewer (south)

Prompt id: `sa11_dragoon_walk_s`. Fixes finding 8. Save the answer as `art/redraws/dragoon_walk_south.png`.

**Attach (3 images, in this order), from `docs/redraw_refs/sa11_dragoon_walk_s/`:**

1. `1_current_walk_s.png`: The CURRENT south gallop: it is a south-east three-quarter view, and frame 9 jumps to another angle. This is what gets replaced.
2. `2_walk_se_e_model.png`: The south-east and east gallops: horse, rider and gait to keep.
3. `3_dragoon_idle.png`: The Dragoon standing: the rider, uniform and horse coat.

**Prompt:**

```
Make ONE row only. Draw the Dragoon (a mounted musketeer in a red coat and tricorne hat, carbine across his back, on a dark horse) galloping straight toward the viewer, 6 frames, a seamless loop: the horse's chest and head toward us, forelegs reaching, hind legs pushing, the rider hunched, the mane flying. Every frame the same size, the hoof line steady. Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. WHAT MUST NOT CHANGE: the rider and horse of reference 3; the size and colours of reference 2. AVOID: a three-quarter angle, a bigger first frame, a front view cut by the box's top, a different horse coat, extra legs. extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use the reference images only to understand the pose, the figure and the style: do not copy their enlargement, their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer.

Pixel art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same weight (one game pixel) around every figure; the same pixel scale and palette as the references (each game pixel drawn as a clean square block of about 2 by 2 sheet pixels).

Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no frame borders. Layout: ONE single row (the south view only: galloping straight toward the viewer), 6 frames left to right, on an image of 1536 by 640 pixels. Each figure (with its weapon and everything it holds) must fit in a box of about 232 px wide and 165 px high of the sheet; every figure the same size, standing on the same invisible ground line, at least 20 px of empty navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.
```

**Import:** tools/import_redraw_mounted.py (only walk_s, 6 frames, art 'dragoon'). This replaces the older prompt 21_dragoon_walk_south of docs/animation_redraw_prompts_2.md, which was never imported. Then contact-sheet it with `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at every frame, bump the version and add a patch note (CLAUDE.md).

## The MEDIUM findings (visible if you look, or on a rarer animation or facing)

### Brood

- **12. Brood Mother stage 2, walk south**, frames 0, 1, 2, 3, 4 and 5: The stage-2 south walk and idle_s are drawn as a south-east three-quarter view (head lower right, tail up left), unlike attack_s (front-on) and stage 1 and 3's frontal south. Walking south she looks like she is going SE, and she turns when she attacks. This is already known in docs/art_style_inconsistency.md.
  File `assets/units/brood_mother_2/walk_s.png`. Picture `docs/shots/sprite_audit/012_units_brood_mother_2_walk_s.png`. Source sheet (best guess by name): `art/redraws/brood_mother_e_walk_a_chatgpt.png`, `art/redraws/brood_mother_e_walk_b_chatgpt.png`.
- **13. Brute, attack east**, frame 4: Frame 4 is a different drawing: the Brute is rearing, with a large pale tan belly patch and a different shell and frill. It doesn't match frames 0-3 or the walk. idle_e frame 2 also has a shorter, curled tail than frames 0-1. (likely)
  File `assets/units/brute/attack_e.png`. Picture `docs/shots/sprite_audit/013_units_brute_attack_e.png`. Source sheet (best guess by name): `art/brood/brute.png`, `art/figures/brood_brute.png`.
- **14. Grub (carrying/wrapping cocoon), carry_cocoon / idle_cocoon / wrap / death_cocoon all**, the whole strip: Every cocoon strip (carry_cocoon, idle_cocoon, wrap and death_cocoon, all facings) draws the grub differently from its walk, harvest and idle: lighter olive, standing taller on thinner legs, a smaller head; it reads as a different animal while it carries a cocoon. Also carry_cocoon_s and wrap_s are side or south-east views, not south (wrap_s, wrap_se and wrap_e are nearly the same picture).
  File `assets/units/grub/carry_cocoon_s.png`. Picture `docs/shots/sprite_audit/014_units_grub_carry_cocoon_s.png`. Source sheet (best guess by name): `art/redraws/grub_cocoon_se_chatgpt.png`, `art/redraws/grub_harvest_chatgpt.png`.
- **15. Grub, harvest south**, frames 3 and 4: The facing changes inside the strip: frames 0-2 are front-on (south), and frames 3-4 turn to a side SE/E view to drop the food. A grub harvesting facing south swivels mid-loop. harvest_n frame 4 also half-turns, which is milder.
  File `assets/units/grub/harvest_s.png`. Picture `docs/shots/sprite_audit/015_units_grub_harvest_s.png`. Source sheet (best guess by name): `art/redraws/grub_harvest_chatgpt.png`, `art/redraws/grub_harvest_ne_chatgpt.png`.
- **16. Hatchlings, walk (fly) / idle south-east**, frame 2: Frame 2 (the frame where a third wing was erased in code, 0.26.10) now shows a truncated body: one big downstroke wing, no tail or hind legs, and the far wing gone. It blinks in the fly loop, which is also the idle. This is known as weak in docs/third_wing.md; redraw wanted.
  File `assets/units/hatchlings/walk_se.png`. Picture `docs/shots/sprite_audit/016_units_hatchlings_walk_se.png`.
- **17. Venom Sire (Dilophosaurus) lure arrival, arrive south-east**, frames 2, 6, 7, 8 and 9: The same pit blinking as the Tyrant lure: frames 6, 7 and 9 have no ground, while 8, 10 and 11 have the pit with him hovering over it in 8-9. Frame 2 he floats in mid-air. Frame 7 is drawn differently (head up, crest and head spines missing, pale yellow chest) and frame 6's head is lost in a green blob, so the design wobbles. (likely)
  File `assets/units/lure_dilophosaurus/arrive_se.png`. Picture `docs/shots/sprite_audit/017_units_lure_dilophosaurus_arrive_se.png`. Source sheet (best guess by name): `art/redraws/dilophosaurus_lure_arrive_se_chatgpt.png`, `art/redraws/pterodactyl_lure_arrive_se_chatgpt.png`.
- **18. Tyrant Sire lure arrival, arrive south-east**, frames 6, 7, 8, 9 and 10: The pit/ground under the Sire blinks: frames 6, 8, 10 and 11 have the dug pit under his feet, while frames 7 and 9 have none, so he floats with no ground and the pit pops in and out. In frame 6 he hangs well above the pit.
  File `assets/units/lure_tyrannosaur/arrive_se.png`. Picture `docs/shots/sprite_audit/018_units_lure_tyrannosaur_arrive_se.png`. Source sheet (best guess by name): `art/redraws/dilophosaurus_lure_arrive_se_chatgpt.png`, `art/redraws/pterodactyl_lure_arrive_se_chatgpt.png`.
- **19. Mist Toad, fog east**, frames 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 and 13: In every fog frame the toad is covered in white blotches (the mist cut out with the background, leaving white patches stuck on its skin), so it looks piebald rather than breathing fog. The body also jumps left and right and changes size between frames (e.g. 3->4, 8->9). (likely)
  File `assets/units/mist_toad/fog_e.png`. Picture `docs/shots/sprite_audit/019_units_mist_toad_fog_e.png`. Source sheet (best guess by name): `art/figures/brood_mist_toad_fog.png`, `art/redraws/mist_toad_hop_e_chatgpt.png`.
- **20. Pterodactyl (Storm Sire), walk (fly) / idle south-east**, frames 1 and 3: A flat dark navy patch (RGB about 16,32,48; ~260 px) sits between the far wing's root and the neck/crest in frames 1 and 3, which is likely ChatGPT's background left in. The same strip is the idle. (likely)
  File `assets/units/pterodactyl/walk_se.png`. Picture `docs/shots/sprite_audit/020_units_pterodactyl_walk_se.png`. Source sheet (best guess by name): `art/redraws/pterodactyl_concept_chatgpt.png`, `art/redraws/pterodactyl_dive_e_chatgpt.png`.
- **21. Raptor, death east**, frames 1, 2, 3 and 4: The death poses don't connect: frame 1 is lying on its belly, frame 2 on its back with legs up and the head end in red at the right, frame 3 on its belly again stretched out, and frame 4 curled short. The body flips over and back between frames, so the death reads as a jumble. The Raptor is the commonest Brood unit. (likely)
  File `assets/units/raptor/death_e.png`. Picture `docs/shots/sprite_audit/021_units_raptor_death_e.png`. Source sheet (best guess by name): `art/redraws/raptor_walk_n_chatgpt.png`, `art/redraws/raptor_walk_ne_chatgpt.png`.
- **22. Storm Challenger, attack north**, frames 0, 1, 2, 3, 4 and 5: The head flips 180 degrees inside the loop: frames 0, 4 and 5 (and every N fly/idle frame) have the beak at the BOTTOM, as if facing south, while the swoop frames 1-3, flipped in code, point it up. This is known in the docs as a weak spot.
  File `assets/units/storm_challenger/attack_n.png`. Picture `docs/shots/sprite_audit/022_units_storm_challenger_attack_n.png`. Source sheet (best guess by name): `art/redraws/storm_challenger_e_chatgpt.png`, `art/redraws/storm_challenger_n_chatgpt.png`.
- **23. Storm Challenger, walk (fly) / idle south-east**, frames 1, 2 and 3: Frame 2 is the code-patched frame (third wing erased): a truncated body with one wing and a dark cut line along the wing top. Frames 1 and 3 have a dark navy patch between the far wing root and the head crest, which looks like ChatGPT's background trapped there. (likely)
  File `assets/units/storm_challenger/walk_se.png`. Picture `docs/shots/sprite_audit/023_units_storm_challenger_walk_se.png`. Source sheet (best guess by name): `art/redraws/storm_challenger_e_chatgpt.png`, `art/redraws/storm_challenger_n_chatgpt.png`.
- **24. Tyrant Sire (Tyrannosaur), death south-east**, frames 0 and 1: The death starts with a different, upright drawing (standing tall like a kaiju, thin and smaller, short tail hanging down) that doesn't match his crouched walk/idle SE. He pops to a new figure the moment he dies, then crumples in frames 2-5. Frame 3 shows no head. (likely)
  File `assets/units/tyrannosaur/death_se.png`. Picture `docs/shots/sprite_audit/024_units_tyrannosaur_death_se.png`. Source sheet (best guess by name): `art/redraws/tyrannosaur_se_breath_death_chatgpt.png`, `art/redraws/tyrannosaur_concept_chatgpt.png`.
- **25. Tyrant Challenger, death south-east**, frame 3: Frame 3: a long clawed limb sticks straight up out of the back near the hips, reading as a second neck and head (the real head is lying at the right). It is absent in frames 2 and 4. (likely)
  File `assets/units/tyrant_challenger/death_se.png`. Picture `docs/shots/sprite_audit/025_units_tyrant_challenger_death_se.png`. Source sheet (best guess by name): `art/redraws/tyrant_challenger_portrait_chatgpt.png`, `art/redraws/young_tyrant_concept_chatgpt.png`.

### Buildings, effects, menu

- **26. Boiler**, frame 0: States disagree in design: built is a horizontal drum with ONE chimney; construction an upright drum; damaged an upright body with TWO chimneys and a different pipe layout
  File `assets/buildings/boiler_damaged.png`. Picture `docs/shots/sprite_audit/026_buildings_boiler_damaged.png`.
- **27. Cuirassier (Barracks drill, horse cut out), mount east**, frames 0, 1, 2, 3, 4, 5 and 6: Leftovers of the removed horse float beside the rider: a bridle/rein scrap hangs in the air to his right in every frame, and in frame 1 a detached boot/hoof sits well below the figure; the saddle cloth floats with no body
  File `assets/buildings/drill_cuirassier/mount_e.png`. Picture `docs/shots/sprite_audit/027_buildings_drill_cuirassier_mount_e.png`. Source sheet (best guess by name): `art/campaign/warmap_mountains_chatgpt.png`, `art/crown/mount/dragoon_mount_e.png`.
- **28. Horseman (Barracks drill, horse cut out), mount east**, frames 0, 1, 2, 3, 4, 5 and 6: Same as the Cuirassier: detached rein/bridle scraps float to the right of the rider in every frame and a stray hoof/boot below him in frame 1
  File `assets/buildings/drill_horseman/mount_e.png`. Picture `docs/shots/sprite_audit/028_buildings_drill_horseman_mount_e.png`. Source sheet (best guess by name): `art/campaign/warmap_mountains_chatgpt.png`, `art/crown/mount/dragoon_mount_e.png`.
- **29. Paddock horse, graze e,n,ne,s,se**, frames 0, 1 and 2: The graze strips do not match their facings: graze_e is not a side profile (a compact front/three-quarter view unlike idle_e/walk_e) and graze_s, graze_se and graze_n are nearly the same silhouette; the horse also looks smaller than in walk/idle (likely)
  File `assets/buildings/paddock_horse/graze_e.png`. Picture `docs/shots/sprite_audit/029_buildings_paddock_horse_graze_e.png`.
- **30. Palisade N-S run**, frame 0: wall_ns_construction / wall_ns_damaged / wall_ns_destroyed are front-on E-W palisade art squeezed to 32 px, while wall_ns_built is a narrow side-on column of stakes; a N-S line changes from a column to a wide front-on fence when damaged or being built
  File `assets/buildings/wall_ns_construction.png`. Picture `docs/shots/sprite_audit/030_buildings_wall_ns_construction.png`.
- **31. Main menu battle painting**, frame 0: Clockwork Jack in the right-middle (twin drill launchers, about x 1100-1230, y 430-560 of 1672x941): its body runs into a long purple coil spring that ends in a second robot torso below (the sword-bearer), so two automata are merged by a spring 'neck/arm' - a hallucinated anatomy (likely)
  File `assets/menu/battle.jpg`. Picture `docs/shots/sprite_audit/031_menu_battle.png`. Source sheet (best guess by name): `art/redraws/main_menu_battle_chatgpt.png`, `art/redraws/main_menu_battle_wide_chatgpt.png`.
- **32. Main menu battle painting**, frame 0: A Brood creature in the lower middle (left of the stone bridge, about x 870-1000, y 690-760) has RED spines/crest; the owner wants the Brood green (the other creatures were repainted green in 0.33.32, this one was missed)
  File `assets/menu/battle.jpg`. Picture `docs/shots/sprite_audit/032_menu_battle.png`. Source sheet (best guess by name): `art/redraws/main_menu_battle_chatgpt.png`, `art/redraws/main_menu_battle_wide_chatgpt.png`.

### Campaign art and rebels

- **33. Pikeman (Crown campaign), walk north-east**, frame 1: Two pike shafts drawn (a doubled line) in frame 1; the others have one (already in docs/animation_audit_units.md, still not fixed).
  File `assets/units/pikeman/walk_ne.png`. Picture `docs/shots/sprite_audit/033_units_pikeman_walk_ne.png`. Source sheet (best guess by name): `art/campaign/rebels/pikeman_chatgpt.png`, `art/campaign/rebels/pikeman_thrust_chatgpt.png`.
- **34. Pikeman (Crown campaign), walk south**, frames 0 and 1: Only 2 frames for the walk in s and se (4 in e/ne/n), and the s/se walk is the side view facing east carrying the pike back: the legs barely move, the walk skates.
  File `assets/units/pikeman/walk_s.png`. Picture `docs/shots/sprite_audit/034_units_pikeman_walk_s.png`. Source sheet (best guess by name): `art/campaign/rebels/pikeman_chatgpt.png`, `art/campaign/rebels/pikeman_thrust_chatgpt.png`.
- **35. Rebel Pikeman, brace south**, frame 0: The levelled pike toward the viewer is drawn as a short stub pointing straight DOWN, its head hanging below the soles / ground line; reads as a man holding a stick at the floor, not a braced pike. attack_s (all 3 frames) the same, with the tip poking under the feet. (likely)
  File `assets/units/rebel_pikeman/brace_s.png`. Picture `docs/shots/sprite_audit/035_units_rebel_pikeman_brace_s.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **36. Rebel Torch-bearer, mine (setting fire) north-east**, frames 1, 2 and 4: Frames 1-2 have detached sparks/specks floating behind the head and below the hand (stray pixels, one far below); frame 4 the torch is drawn bent like a rope/hook ending on the ground. (likely)
  File `assets/units/rebel_torch/mine_ne.png`. Picture `docs/shots/sprite_audit/036_units_rebel_torch_mine_ne.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **37. War map ship (big)**, frame 0: Magenta/pink halo left along all the rigging lines and sail edges (background removal on a magenta key): the ropes read hot pink on the parchment. ship_small.png has the same pink rigging. (likely)
  File `campaign/warmap_art/ship_big.png`. Picture `docs/shots/sprite_audit/037_campaign_warmap_art_ship_big.png`.

### Clockwork

- **38. Spring Ballista, death s, se, e, ne, n**, frames 0, 1, 2 and 3: All five death strips are the same SE-angle picture, so a ballista facing N, S or E snaps to the SE view when it dies.
  File `assets/units/ballista/death_n.png`. Picture `docs/shots/sprite_audit/038_units_ballista_death_n.png`. Source sheet (best guess by name): `art/redraws/ballista_wreck_chatgpt.png`, `art/redraws/ballista_dirs.png`.
- **39. Spring Ballista, death all**, frames 0, 1 and 2: Frames 1 and 2 touch the top of the cell (the flying spring coil and the smoke are cut flat at the top edge); frame 0 touches the bottom (bolt cut). Frame 1 also looks larger than frames 0/2.
  File `assets/units/ballista/death_s.png`. Picture `docs/shots/sprite_audit/039_units_ballista_death_s.png`. Source sheet (best guess by name): `art/redraws/ballista_wreck_chatgpt.png`, `art/redraws/ballista_dirs.png`.
- **40. Bulwark (old/experimental), attack/brace/braced_hit/death/idle/walk s, se, ne, n**, the whole strip: Most facings are the same side view facing right (S, SE, E, NE identical; attack_n, brace_n, braced_hit_n, death_n too), only idle_n and walk_n show the back. Attack frame 2 the spear passes through the shield.
  File `assets/units/bulwark/attack_n.png`. Picture `docs/shots/sprite_audit/040_units_bulwark_attack_n.png`. Source sheet (best guess by name): `art/clockwork/bulwark.png`.
- **41. Clock Soldier, idle/walk vs attack/guard/death east**, frame 0: East view changes design between strips: idle_e and walk_e show the CLOCK FACE on the chest facing east with the shield at the back (idle) or a shield edge at the front (walk), while attack_e, guard_e and death_e show a plain body with NO clock face and the shield held behind/at the side. The shield also jumps from behind the body (idle_e, attack_e) to in front (walk_e frame 0-5) when the soldier starts walking. Known in docs/clock_soldier_west.md ("shield on its back"). (likely)
  File `assets/units/clock_soldier/idle_e.png`. Picture `docs/shots/sprite_audit/041_units_clock_soldier_idle_e.png`. Source sheet (best guess by name): `art/redraws/clock_soldier_idle_west_chatgpt.png`, `art/redraws/clock_soldier_idle.png`.
- **42. Great Winder, idle/walk/sweep/wind/death north-east**, the whole strip: The NE view is drawn as a second SE view: the clock face and the front rollers face the camera at the lower right, while the N view shows the hopper/back plate and the wind arm in wind_ne points NE. Turning between SE and NE barely changes; between NE and N the machine flips round. (likely)
  File `assets/units/great_winder/idle_ne.png`. Picture `docs/shots/sprite_audit/042_units_great_winder_idle_ne.png`. Source sheet (best guess by name): `art/redraws/great_winder_dirs_v2_chatgpt.png`, `art/redraws/great_winder_key_rollers_chatgpt.png`.
- **43. Netter, walk/idle/attack/death south**, the whole strip: The S view is turned 90 degrees: the barrel body lies crosswise (long side to the camera) exactly like the E view, while the N view shows the barrel end-on and SE/NE show it along the facing. So a Netter walking south looks like it is side-stepping east; turning S<->SE/SW snaps the body round. Affects idle_s, walk_s, attack_s, death_s. (likely)
  File `assets/units/netter/walk_s.png`. Picture `docs/shots/sprite_audit/043_units_netter_walk_s.png`. Source sheet (best guess by name): `art/redraws/netter_walk.png`, `art/redraws/netter_death_chatgpt.png`.
- **44. Pendulum, attack_hi_l / attack_hi_r s, n**, frames 0, 1, 2, 3, 4 and 5: HIGH SWING S and N views: only the swinging arm carries a blade; the other hand is a bare brass weight with NO blade in every frame. In idle, walk, the normal attack_l/attack_r and in the high swing SE/NE views both hands carry blades, so one blade vanishes when the Pendulum swings at a flyer facing S or N (also attack_hi_r_s / attack_hi_l_n / attack_hi_r_n).
  File `assets/units/pendulum/attack_hi_l_s.png`. Picture `docs/shots/sprite_audit/044_units_pendulum_attack_hi_l_s.png`. Source sheet (best guess by name): `art/redraws/pendulum_death_chatgpt_1.png`, `art/redraws/pendulum_death_chatgpt_2.png`.
- **45. Skywing (old/experimental), idle south**, frame 1: Frame 1 is only a small wing fragment: the body is missing; frames 0 and 2 show the creature off-centre with one wing.
  File `assets/units/skywing/idle_s.png`. Picture `docs/shots/sprite_audit/045_units_skywing_idle_s.png`. Source sheet (best guess by name): `art/redraws/skywing_pterosaur_concept_chatgpt.png`, `art/brood/skywing.png`.
- **46. Skywing (old/experimental), walk north-east**, frame 1: Frame 1 contains two overlapping copies of the creature (two tails, two pairs of wings); walk_ne has only 2 frames where the other views have 3.
  File `assets/units/skywing/walk_ne.png`. Picture `docs/shots/sprite_audit/046_units_skywing_walk_ne.png`. Source sheet (best guess by name): `art/redraws/skywing_pterosaur_concept_chatgpt.png`, `art/brood/skywing.png`.
- **47. Springer, attack_up all**, frames 0, 1, 2, 3, 4 and 5: Body design changes between strips: in idle, walk, jump and attack_l/attack_r BOTH arms end in steel drill/blade tips, but in attack_up (all 5 facings) and in death (all 5 facings) one arm is a big brass CLAW/pincer instead of a drill. The arm switches shape the moment it shoots at a flyer or dies. Lowered from HIGH by the lead reviewer: it shows only when a Springer shoots at a flyer.
  File `assets/units/springer/attack_up_s.png`. Picture `docs/shots/sprite_audit/047_units_springer_attack_up_s.png`. Source sheet (best guess by name): `art/figures/src_clockwork_springers_chatgpt.png`, `art/figures/clockwork_springer_crouch_left.png`.
- **48. Springer, death all**, frames 0, 1, 2, 3, 4, 5 and 6: Same as attack_up: the death strips (s, se, e, ne, n) draw one arm as a claw/pincer, the idle/walk/attack strips show two drill arms. The claw arm appears on the frame the unit dies.
  File `assets/units/springer/death_s.png`. Picture `docs/shots/sprite_audit/048_units_springer_death_s.png`. Source sheet (best guess by name): `art/figures/src_clockwork_springers_chatgpt.png`, `art/figures/clockwork_springer_crouch_left.png`.
- **49. Steam Walker (old/experimental), walk, attack east**, frames 0, 1, 2, 3, 4 and 5: The body jumps sideways inside the cell from frame to frame (attack_e frame 1 ~60 px right of frames 0/2; walk_e drifts left and right), and the walker changes size between attack frames; walk frame 5 loses its steam plume.
  File `assets/units/steam_walker/walk_e.png`. Picture `docs/shots/sprite_audit/049_units_steam_walker_walk_e.png`. Source sheet (best guess by name): `art/clockwork/steam_walker.png`.
- **50. Stormcaller (old/experimental), cast, attack, walk all**, frame 0: cast frame 0 is the side-view attack pose, frames 1-3 a front view; attack_* are the same side view in every facing and walk_n is a side view, not a back view.
  File `assets/units/stormcaller/cast_s.png`. Picture `docs/shots/sprite_audit/050_units_stormcaller_cast_s.png`. Source sheet (best guess by name): `art/clockwork/stormcaller.png`.
- **51. Tesla Cart (old/experimental), deploy vs deployed/attack all**, the whole strip: deploy ends on a TALL coil tower (frame 4), but deployed and attack show a short coil: the tower shrinks the moment deploy ends. attack_e/attack_ne frame 0 is drawn larger than frames 1-2.
  File `assets/units/tesla_cart/deployed_s.png`. Picture `docs/shots/sprite_audit/051_units_tesla_cart_deployed_s.png`. Source sheet (best guess by name): `art/clockwork/tesla_cart.png`, `art/clockwork/tesla_spider.png`.
- **52. Thresher (old/experimental), walk, idle south**, frame 0: The saw blades vanish: walk_s frame 0 and all three idle_s frames have bare arms, the other walk_s frames and every SE/E/NE strip carry two big saws. (likely)
  File `assets/units/thresher/walk_s.png`. Picture `docs/shots/sprite_audit/052_units_thresher_walk_s.png`. Source sheet (best guess by name): `art/clockwork/thresher.png`.
- **53. Ticking Owl, walk/idle (fly loop) north-east**, frame 0: Frame 0 of the NE fly loop shows the owl turned to the east (face, eye and clock face visible) while frames 1-3 show its back: the body spins every loop. Same in idle_ne frame 0.
  File `assets/units/ticking_owl/walk_ne.png`. Picture `docs/shots/sprite_audit/053_units_ticking_owl_walk_ne.png`. Source sheet (best guess by name): `art/redraws/ticking_owl_fly.png`.

### Crown on foot

- **54. Field Cannon, deploy se, e, ne**, frames 2 and 3: Mid-deploy the gun jumps from a side view (frames 0-1, 4) to a head-on view with the barrel pointing straight up (frames 2-3), then back; se, e and ne share the same east frames 0-3. The horse leaving is a dithered checkerboard. Looks code-assembled from other facings.
  File `assets/units/cannon/deploy_e.png`. Picture `docs/shots/sprite_audit/054_units_cannon_deploy_e.png`. Source sheet (best guess by name): `art/crown/cannon.png`, `art/crown/cannon2_angles.png`.
- **55. Field Cannon, deploy south**, frame 2: Frame 2 of the south deploy shows the gun in an east side view with the crew bent over it, between head-on frames; the horse also hangs below the ground line in frames 0-2.
  File `assets/units/cannon/deploy_s.png`. Picture `docs/shots/sprite_audit/055_units_cannon_deploy_s.png`. Source sheet (best guess by name): `art/crown/cannon.png`, `art/crown/cannon2_angles.png`.
- **56. Dismounted Officer, aim/fire/death s, se, ne, n**, the whole strip: All five facings of aim, fire and death are the same east-profile pose (pistol pointing screen-right). Facing south or north he still aims sideways; no real s/se/ne/n views.
  File `assets/units/dismounted/aim_s.png`. Picture `docs/shots/sprite_audit/056_units_dismounted_aim_s.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **57. Dismounted Officer, death all**, frames 2 and 3: Frame 2 crouches low, frame 3 stands taller again, then frame 4 lies down: he falls, gets back up, falls. Frame 2 also loses the red plume (different design). Same in every facing. (likely)
  File `assets/units/dismounted/death_s.png`. Picture `docs/shots/sprite_audit/057_units_dismounted_death_s.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_n_chatgpt.png`.
- **58. Dismounted Officer, fire north-east**, frame 1: A second pistol/arm sticks out to the LEFT while the shot flashes on the right: an extra hand-gun appears for one frame. (likely)
  File `assets/units/dismounted/fire_ne.png`. Picture `docs/shots/sprite_audit/058_units_dismounted_fire_ne.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **59. Dismounted Officer, melee all**, frames 0, 1, 2 and 3: All five facings are one slash drawn to the right; frame 0 shows him from the front, frames 1-3 from behind (body turns round mid-swing). The melee body also differs from idle/walk (no red plume on the hat, cleaner white shirt, different proportions). (likely)
  File `assets/units/dismounted/melee_n.png`. Picture `docs/shots/sprite_audit/059_units_dismounted_melee_n.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_n_chatgpt.png`.
- **60. Mortar, deploy all**, frames 0, 1, 2, 3, 4 and 5: The deploy is a disjointed collage: frame 1 a rearing horse, the cart changes size and shape, the crew count goes 2-1-2, frames 3-4 are the same east view in every facing, frame 5 jumps to the set-up mortar. A brown horse here, while walk uses a GREY horse (colour changes between animations).
  File `assets/units/mortar/deploy_s.png`. Picture `docs/shots/sprite_audit/060_units_mortar_deploy_s.png`. Source sheet (best guess by name): `art/crown/mortar_a.png`, `art/crown/mortar_b.png`.
- **61. Mortar, fire all**, frames 0 and 1: Frame 0's mortar is a much bigger black barrel with the two crew farther apart (54-59 px wide v 39-42 in idle, feet 2-3 px lower); frame 1 snaps back to the small bronze mortar. Every shot pops in size. All five facings are the same picture.
  File `assets/units/mortar/fire_s.png`. Picture `docs/shots/sprite_audit/061_units_mortar_fire_s.png`. Source sheet (best guess by name): `art/crown/mortar_a.png`, `art/crown/mortar_b.png`.
- **62. Musketeer, death east**, frame 2: A separate small red-and-brown chunk lies on the ground to the right of the body, detached (looks like a tiny second figure or a severed piece). (likely)
  File `assets/units/musketeer/death_e.png`. Picture `docs/shots/sprite_audit/062_units_musketeer_death_e.png`. Source sheet (best guess by name): `art/redraws/musketeer_aim_ne_chatgpt.png`, `art/redraws/musketeer_aim_s_chatgpt.png`.
- **63. Musketeer, idle south**, frame 1: The musket held down his side in frame 0 almost vanishes in frame 1 (only the muzzle tip shows over the hat); the barrel also touches the top of the canvas (flat cut). (likely)
  File `assets/units/musketeer/idle_s.png`. Picture `docs/shots/sprite_audit/063_units_musketeer_idle_s.png`. Source sheet (best guess by name): `art/redraws/musketeer_aim_ne_chatgpt.png`, `art/redraws/musketeer_aim_s_chatgpt.png`.
- **64. Musketeer, melee north**, frames 0, 1 and 2: No musket or bayonet visible at all in the north bayonet thrust (only a stub at the hip): he jabs with nothing. melee_s also shows almost no weapon. (likely)
  File `assets/units/musketeer/melee_n.png`. Picture `docs/shots/sprite_audit/064_units_musketeer_melee_n.png`. Source sheet (best guess by name): `art/redraws/musketeer_aim_ne_chatgpt.png`, `art/redraws/musketeer_aim_s_chatgpt.png`.
- **65. Musketeer, reload north**, frames 0, 1 and 2: Reloading with no musket visible (back view, the gun is entirely gone); reload_s frame 0 likewise shows no musket. (likely)
  File `assets/units/musketeer/reload_n.png`. Picture `docs/shots/sprite_audit/065_units_musketeer_reload_n.png`. Source sheet (best guess by name): `art/redraws/musketeer_aim_ne_chatgpt.png`, `art/redraws/musketeer_aim_s_chatgpt.png`.
- **66. Armoured Musketeer, death east**, frame 2: Same detached red chunk with a stick lying apart to the right of the body as the Musketeer's death_e (recolour of the same frame). Frame 1's crumpled body is also cut by a straight vertical edge on the right. (likely)
  File `assets/units/musketeer_armoured/death_e.png`. Picture `docs/shots/sprite_audit/066_units_musketeer_armoured_death_e.png`. Source sheet (best guess by name): `art/redraws/musketeer_armoured_aim_ne_chatgpt.png`, `art/redraws/musketeer_armoured_aim_s_chatgpt.png`.
- **67. Armoured Musketeer, melee north**, frames 0, 1 and 2: Same as the Musketeer: no musket/bayonet visible in the north thrust. (likely)
  File `assets/units/musketeer_armoured/melee_n.png`. Picture `docs/shots/sprite_audit/067_units_musketeer_armoured_melee_n.png`. Source sheet (best guess by name): `art/redraws/musketeer_armoured_aim_ne_chatgpt.png`, `art/redraws/musketeer_armoured_aim_s_chatgpt.png`.
- **68. Armoured Musketeer, walk south**, frames 0, 1 and 2: Only 3 frames (e has 6, ne 5, se 4); the pasted labourer legs read as one central leg in frames 0 and 2, and the musket is cut at the top edge. The walk counts per facing differ (3/4/6/5/7). (likely)
  File `assets/units/musketeer_armoured/walk_s.png`. Picture `docs/shots/sprite_audit/068_units_musketeer_armoured_walk_s.png`. Source sheet (best guess by name): `art/redraws/gait_src/crown_musketeer_armoured_walk_e.png`, `art/redraws/gait_src/crown_musketeer_armoured_walk_n.png`.

### Crown riders and wagons

- **69. Balloon gunner, gunner_up/gunner_down south**, frame 0: The musket is missing in frame 0 of gunner_up_s and gunner_down_s (present in frames 1-2). In every facing the gunner fires out to the viewer's right, even facing N/S. (likely)
  File `assets/units/balloon/gunner_up_s.png`. Picture `docs/shots/sprite_audit/069_units_balloon_gunner_up_s.png`. Source sheet (best guess by name): `art/crown/balloon_basket_pilot.png`, `art/crown/balloon_rope_barrel.png`.
- **70. Cuirassier, attack east**, frames 1 and 2: Doubled parts: frame 2 shows a sabre raised over the head AND a straight blade thrust out to the right at the same time (two swords); frame 1 has a doubled/ghosted helmet (two helmet shapes side by side over the rider). The E attack is also a SE three-quarter view rather than a profile. (likely)
  File `assets/units/cuirassier/attack_e.png`. Picture `docs/shots/sprite_audit/070_units_cuirassier_attack_e.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **71. Cuirassier, attack south-east**, frame 1: Two blades: a sabre raised overhead plus a second blade angled down past the horse's neck in the same frame. (likely)
  File `assets/units/cuirassier/attack_se.png`. Picture `docs/shots/sprite_audit/071_units_cuirassier_attack_se.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **72. Cuirassier, pistol all**, frames 0, 1, 2 and 3: Helmet design changes between animations: in the pistol strips (all facings) his morion carries a tall red plume, while walk, idle, attack and mount show a plain morion with no plume.
  File `assets/units/cuirassier/pistol_s.png`. Picture `docs/shots/sprite_audit/072_units_cuirassier_pistol_s.png`. Source sheet (best guess by name): `art/crown/cuirassier_pistol.png`, `art/redraws/cuirassier_dismounted_e_chatgpt.png`.
- **73. Cuirassier, walk north-east**, the whole strip: walk_ne is a byte-for-byte copy of walk_n: a NE gallop plays the straight rear view.
  File `assets/units/cuirassier/walk_ne.png`. Picture `docs/shots/sprite_audit/073_units_cuirassier_walk_ne.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **74. Cuirassier, walk south**, frames 1, 2 and 3: Facing drifts inside the loop: frames 1-3 show the horse turned three-quarter to the viewer's left, frames 0 and 4-7 straight at the camera, so the gallop wobbles side to side.
  File `assets/units/cuirassier/walk_s.png`. Picture `docs/shots/sprite_audit/074_units_cuirassier_walk_s.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **75. Cuirassier, walk south-east**, frames 4, 5, 6 and 7: Facing drifts: frames 0-3 are a three-quarter SE view, frames 4-7 almost straight front (S); in the loop the horse swings between two angles.
  File `assets/units/cuirassier/walk_se.png`. Picture `docs/shots/sprite_audit/075_units_cuirassier_walk_se.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **76. Armoured Dragoon, idle east**, frames 0 and 1: The 2-frame idle switches angle: frame 0 horse heading right (three-quarter), frame 1 horse facing straight at the camera; feet also move 3 px off the line (bottom 64 vs 67). Same in idle_ne (copy) and idle_se's feet.
  File `assets/units/dragoon_armoured/idle_e.png`. Picture `docs/shots/sprite_audit/076_units_dragoon_armoured_idle_e.png`. Source sheet (best guess by name): `art/crown/mount/dragoon_armoured_mount.png`, `art/crown/mount/dragoon_armoured_mount_n.png`.
- **77. Armoured Dragoon, walk north**, frame 0: Frame 0 is a straight rear view; frames 1-9 the horse is turned three-quarter to the right with a different saddlebag layout, so the loop snaps once per cycle.
  File `assets/units/dragoon_armoured/walk_n.png`. Picture `docs/shots/sprite_audit/077_units_dragoon_armoured_walk_n.png`. Source sheet (best guess by name): `art/crown/mount/dragoon_armoured_mount.png`, `art/crown/mount/dragoon_armoured_mount_n.png`.
- **78. Horse, graze s/se/ne/n**, the whole strip: Grazing shows the same body angle (head down to the lower right) in every facing: graze_s is an exact copy of graze_se, and graze_ne / graze_n are nearly the same pose instead of rear views.
  File `assets/units/horse/graze_s.png`. Picture `docs/shots/sprite_audit/078_units_horse_graze_s.png`. Source sheet (best guess by name): `art/crown/barracks_props/horse_prop.png`, `art/crown/buildings_v2/horse_breeder.png`.
- **79. Horseman, attack north**, frame 0: Sabre is pure team red (blade recoloured as team colour, so it will be purple in game), and it is raised in the rider's LEFT hand (viewer's left from behind) while frames 1-2 cut with the right hand. (likely)
  File `assets/units/horseman/attack_n.png`. Picture `docs/shots/sprite_audit/079_units_horseman_attack_n.png`. Source sheet (best guess by name): `art/crown/horseman_attack_death.png`, `art/crown/horseman.png`.
- **80. Horseman, attack north-east**, frames 2 and 3: Frame 2 the horse suddenly turns to a side profile facing left/west with its legs mostly missing (only rump and head), while frames 0,1,3 are rear views; frame 3 the raised sabre is red (team colour) and held in the left hand as in attack_n frame 0. (likely)
  File `assets/units/horseman/attack_ne.png`. Picture `docs/shots/sprite_audit/080_units_horseman_attack_ne.png`. Source sheet (best guess by name): `art/crown/horseman_attack_death.png`, `art/crown/horseman.png`.
- **81. Horseman, mount se/e**, frames 3, 4, 5 and 6: A long brown musket/carbine appears on the rider's back once he is in the saddle (mount_se and mount_e frames 3-6) that the Horseman never carries in idle, walk or attack. In mount_e frames 0-1 the saddle cloth is still white (not recoloured to team red) and turns red from frame 2. (likely)
  File `assets/units/horseman/mount_se.png`. Picture `docs/shots/sprite_audit/081_units_horseman_mount_se.png`. Source sheet (best guess by name): `art/crown/horseman_dismounted.png`, `art/crown/mount/horseman_mount.png`.
- **82. Horseman, walk south**, frames 0 and 1: Facing drifts: frames 0-1 are straight front, frames 2-9 turned three-quarter to the viewer's left (tail showing on the left), so the loop snaps between angles.
  File `assets/units/horseman/walk_s.png`. Picture `docs/shots/sprite_audit/082_units_horseman_walk_s.png`. Source sheet (best guess by name): `art/crown/horseman.png`, `art/crown/horseman_attack_death.png`.
- **83. Missionary, death se/e**, frames 1, 2 and 3: Death strips are disjointed: death_se frames 1-2 are tangled shapes of different sizes (frame 2 small and upright again) between the fall and the lying body; death_e starts with him already lying full length (frame 0) then curls smaller (1-2): order/size wrong. No death_n file. (likely)
  File `assets/units/missionary/death_se.png`. Picture `docs/shots/sprite_audit/083_units_missionary_death_se.png`. Source sheet (best guess by name): `art/crown/missionary.png`, `art/crown/missionary_mounted.png`.
- **84. Missionary, idle north**, frames 0 and 1: The N idle shows his FRONT (face, collar, stole down the chest) instead of his back; frame 0 has the bag in front, frame 1 no bag and a white collar, so the two frames also differ in design. (likely)
  File `assets/units/missionary/idle_n.png`. Picture `docs/shots/sprite_audit/084_units_missionary_idle_n.png`. Source sheet (best guess by name): `art/crown/missionary.png`, `art/crown/missionary_mounted.png`.
- **85. Missionary, idle north-east**, frames 0 and 1: The 2-frame idle switches pose: frame 0 hunched and turned with the bag swung out left, frame 1 upright with the bag at his side; visible as a jerk every idle cycle.
  File `assets/units/missionary/idle_ne.png`. Picture `docs/shots/sprite_audit/085_units_missionary_idle_ne.png`. Source sheet (best guess by name): `art/crown/missionary.png`, `art/crown/missionary_mounted.png`.
- **86. Mounted Missionary, walk east**, frames 2, 3, 4, 5 and 6: The processional cross he carries vanishes in frames 2-4 and is half there in 6; frames 5-6 have a dark detached fragment at the right edge of the cell (a piece of a neighbouring drawing / cut-off part). (likely)
  File `assets/units/missionary_mounted/walk_e.png`. Picture `docs/shots/sprite_audit/086_units_missionary_mounted_walk_e.png`. Source sheet (best guess by name): `art/crown/missionary_mounted.png`, `art/crown/missionary.png`.
- **87. Mounted Missionary, walk south**, frames 0, 1, 2, 3, 4, 5, 6, 7 and 8: The S walk is a three-quarter/side view with the horse running to the viewer's right (same angle as walk_se), not toward the camera; frames 0 and 8 differ in angle from 1-7.
  File `assets/units/missionary_mounted/walk_s.png`. Picture `docs/shots/sprite_audit/087_units_missionary_mounted_walk_s.png`. Source sheet (best guess by name): `art/crown/missionary_mounted.png`, `art/crown/missionary.png`.
- **88. Powder Wagon, walk north-east**, the whole strip: walk_ne, idle_ne, unload_ne and death_ne are exact copies of the _e strips, and the E strips are a SE three-quarter view (horse at lower right): heading NE or E the wagon appears to head down-right.
  File `assets/units/powder_wagon/walk_ne.png`. Picture `docs/shots/sprite_audit/088_units_powder_wagon_walk_ne.png`. Source sheet (best guess by name): `art/crown/powder_wagon.png`, `art/crown/mill_base/powder_mill_built.png`.

### Icons, UI, props

- **89. Brood RALLY**, frame 0: Shows a skull on a stake with a feather/spine headdress: a tribal totem or fetish. It is pagan in look, and it suggests the creatures have a culture (owner: the Brood is not a person). An egg, a pheromone mark or a claw scratch would fit better. (likely)
  File `assets/icons/brood/rally.png`. Picture `docs/shots/sprite_audit/089_icons_brood_rally.png`.
- **90. Brass Serpent LINK / UNLINK / COLLECT / GROW**, frame 0: Flat code-drawn glyphs in the painted frame. LINK in particular shows two beige blocks with red dots, like dice, plus three cogs, and does not read as serpent heads joining. COLLECT, GROW and UNLINK are flat cogs with a tray, a plus and two arrows.
  File `assets/icons/clockwork/ab_serpent_link.png`. Picture `docs/shots/sprite_audit/090_icons_clockwork_ab_serpent_link.png`.
- **91. Clockwork building portraits with no frame**, frame 0: cog_press, cuckoo_house, escapement, heavy_works, mainspring, movement_works, regulator, ratchet_turret, tension and research_ticking_owl are crops on a TRANSPARENT background with no icon frame. Most are cut flat at the 64 px border: the cuckoo house is cut at left and bottom, the cog press at the right, the owl's wings at both sides, the regulator at the sides and bottom. Every other portrait sits in a dark framed square.
  File `assets/icons/cog_press.png`. Picture `docs/shots/sprite_audit/091_icons_cog_press.png`. Source sheet (best guess by name): `art/redraws/cog_press_chatgpt.png`, `art/clockwork/gear/cog_press_built.png`.
- **92. Hatchlings (Brood unit portrait)**, frame 0: Drawn as a green bird chick: big hooked beak, round bird eye, a red chicken comb. Reads as a chicken, not a reptile hatchling (art direction: the Brood is reptilian first). The same beaked chicks also burst from the egg in nbr_clutch_hatchlings.png. (likely)
  File `assets/icons/hatchlings.png`. Picture `docs/shots/sprite_audit/092_icons_hatchlings.png`.
- **93. Dead trunk prop**, frame 0: Does not read as a trunk: a lumpy brown heap with a grey pointed shape (a figure or helmet?) on top and branches out to the sides. Unclear what it is. (likely)
  File `assets/props/dead_trunk.png`. Picture `docs/shots/sprite_audit/093_props_dead_trunk.png`.
- **94. Windmill prop**, frame 0: The four sails are fixed to a bare tree trunk with roots, not a mill building or post. The sails do not match: one is red cloth, one checkered/torn, two brown lattice. A stray orange speck floats at the left. It reads as a hallucinated object.
  File `assets/props/windmill.png`. Picture `docs/shots/sprite_audit/094_props_windmill.png`. Source sheet (best guess by name): `art/crown/farm_windmill.png`.

## The LOW findings (seen only frozen or zoomed)

### Brood

- **95. Brood Mother stage 1, lay south-east**, frames 0, 1, 2, 3, 4 and 5: Rechecked after the 0.38.105 fix: one tail in every frame (it runs along the top and curls round the front of the nest into the body). There are no two tails now and it looks fine; listed only to confirm.
  File `assets/units/brood_mother/lay_se.png`. Picture `docs/shots/sprite_audit/095_units_brood_mother_lay_se.png`. Source sheet (best guess by name): `art/redraws/brood_mother_rooted_lay_se_chatgpt.png`, `art/redraws/brood_mother_se_walk_lay_death_chatgpt.png`.
- **96. Brood Mother stage 1, walk south**, frames 0 and 2: Frames 0 and 2 swing the whole body and head hard left and right (the tail tip jumps from upper right to upper left) between the two symmetric frames 1 and 3. At game size the front-on walk wobbles side to side. (unsure)
  File `assets/units/brood_mother/walk_s.png`. Picture `docs/shots/sprite_audit/096_units_brood_mother_walk_s.png`. Source sheet (best guess by name): `art/redraws/brood_mother_e_walk_a_chatgpt.png`, `art/redraws/brood_mother_e_walk_b_chatgpt.png`.
- **97. Brood Mother stage 2 (and stage 3), lay south-east**, frames 0, 1, 2, 3 and 4: Checked for the two-tails fault: stage 2 and stage 3 lay_se have the same single coiled body as the fixed stage 1 (the tail tip upper left, the coil round the front leading to the neck). No extra tail found. In stage 3 (brood_mother_3/lay_se, frames 2-4) the egg drops from under her jaw/neck on a string of goo, so it reads as laid from the mouth. (unsure)
  File `assets/units/brood_mother_2/lay_se.png`. Picture `docs/shots/sprite_audit/097_units_brood_mother_2_lay_se.png`. Source sheet (best guess by name): `art/redraws/brood_mother_rooted_lay_se_chatgpt.png`, `art/redraws/brood_mother_se_walk_lay_death_chatgpt.png`.
- **98. Brute, idle south-east**, frame 0: idle_se is the same front-on view as idle_s, not a south-east three-quarter view. (likely)
  File `assets/units/brute/idle_se.png`. Picture `docs/shots/sprite_audit/098_units_brute_idle_se.png`. Source sheet (best guess by name): `art/brood/brute.png`, `art/figures/brood_brute.png`.
- **99. Grub, morph east**, frames 3 and 4: morph_e ends as a mound/building (frames 3-4), the old Brood's grub-into-building morph. It looks out of place next to the new Brood; it may be unused (it is still listed in art_data.gd). (unsure)
  File `assets/units/grub/morph_e.png`. Picture `docs/shots/sprite_audit/099_units_grub_morph_e.png`. Source sheet (best guess by name): `art/redraws/grub_cocoon_se_chatgpt.png`, `art/redraws/grub_harvest_chatgpt.png`.
- **100. Moults (Storm, Tyrant, Venom), shell / split / open south-east**, the whole strip: Code-assembled moult shells (the cocoon case recoloured, one shell for all three lines; the shed skins come from Gemini). Their size jitters between shell frames 0-3, and the shell reads as flat next to the painted units. This is known and listed in docs/art_style_inconsistency.md.
  File `assets/units/moult_tyrant/shell_se.png`. Picture `docs/shots/sprite_audit/100_units_moult_tyrant_shell_se.png`. Source sheet (best guess by name): `art/redraws/moult_tyrant_se_gemini.jpg`, `art/redraws/moult_storm_se_gemini.jpg`.
- **101. Rootmaw, walk / idle east**, the whole strip: walk_e and idle_e are the same three-quarter SE picture as walk_se/idle_se (only slightly redrawn), not a side-on east view, so east and south-east look identical. (likely)
  File `assets/units/rootmaw/walk_e.png`. Picture `docs/shots/sprite_audit/101_units_rootmaw_walk_e.png`. Source sheet (best guess by name): `art/redraws/rootmaw_lizard_e_walk_chatgpt.png`, `art/redraws/rootmaw_lizard_n_walk_chatgpt.png`.
- **102. Spitter, attack east**, frame 3: Frame 3: the tail is about a third shorter and the body slides right, so the tail visibly shrinks and grows back during the spit. (likely)
  File `assets/units/spitter/attack_e.png`. Picture `docs/shots/sprite_audit/102_units_spitter_attack_e.png`. Source sheet (best guess by name): `art/redraws/spitter_baby_concept_chatgpt.png`, `art/redraws/spitter_e_chatgpt.png`.
- **103. Tyrant Challenger, death south**, frames 0, 1 and 2: The south death starts as a side-on (SE/E) figure, not a front view, so the unit visibly turns as it dies. (likely)
  File `assets/units/tyrant_challenger/death_s.png`. Picture `docs/shots/sprite_audit/103_units_tyrant_challenger_death_s.png`. Source sheet (best guess by name): `art/redraws/tyrant_challenger_portrait_chatgpt.png`, `art/redraws/young_tyrant_concept_chatgpt.png`.
- **104. Venom Challenger, death s, ne, n**, frames 0 and 1: Every death facing starts from a side-on figure (death_n frame 0 is a side/NE view, death_s frame 0 faces right), so the unit turns as it dies in S, NE and N. This is milder than the Tyrant Challenger's N. (likely)
  File `assets/units/venom_challenger/death_n.png`. Picture `docs/shots/sprite_audit/104_units_venom_challenger_death_n.png`. Source sheet (best guess by name): `art/redraws/venom_challenger_concept_chatgpt.png`, `art/redraws/venom_challenger_e_chatgpt.png`.

### Buildings, effects, menu

- **105. Armoury inventor (Bayonet experiment)**, frames 3 and 4: The pumpkin target bursts in frame 3 but is whole again in frame 4 (with a second splash) before flying off in 5; looks like a repeated hit or wrong order (unsure)
  File `assets/buildings/armoury_anim_bayonet.png`. Picture `docs/shots/sprite_audit/105_buildings_armoury_anim_bayonet.png`. Source sheet (best guess by name): `art/crown/armoury.png`, `art/crown/buildings_v2/armoury.png`.
- **106. Armoury inventor (Cavalry Charge experiment)**, frames 0, 2, 4 and 5: The test horse/mount changes shape between frames (a bench-like saddle in 0-1, a brown bear-like lump in 4-5); hard to read as the same object (unsure)
  File `assets/buildings/armoury_anim_charge.png`. Picture `docs/shots/sprite_audit/106_buildings_armoury_anim_charge.png`. Source sheet (best guess by name): `art/crown/armoury.png`, `art/crown/buildings_v2/armoury.png`.
- **107. Assembly Works**, frame 0: Damaged state adds a large cog wheel at the front-left and rearranged front banners/towers not in the built art; construction frame is a different-shaped open hall (likely)
  File `assets/buildings/assembly_works_damaged.png`. Picture `docs/shots/sprite_audit/107_buildings_assembly_works_damaged.png`.
- **108. Cuckoo House**, frame 0: A debris fragment is cut flat at the right edge of the image (likely)
  File `assets/buildings/cuckoo_house_damaged.png`. Picture `docs/shots/sprite_audit/108_buildings_cuckoo_house_damaged.png`. Source sheet (best guess by name): `art/clockwork/gear/cuckoo_house_built.png`, `art/clockwork/gear/cuckoo_house_construct.png`.
- **109. Cuirassier / Horseman seated drill, idle/attack east**, frames 0 and 1: With the horse masked out, idle_e and attack_e show a split-legged rider with fragmented red saddle-cloth pieces hanging off; reads as broken anatomy unless the wooden prop hides it exactly (code-assembled) (unsure)
  File `assets/buildings/drill_cuirassier/idle_e.png`. Picture `docs/shots/sprite_audit/109_buildings_drill_cuirassier_idle_e.png`. Source sheet (best guess by name): `art/campaign/rebels/varenne_idles_chatgpt.png`, `art/redraws/clock_soldier_idle_west_chatgpt.png`.
- **110. Dragoon (Barracks drill, horse cut out), mount east**, frames 0, 1, 2, 3, 4 and 5: Detached rein scraps float to the right of the man; frame 1 has a stray boot/hoof under him (likely)
  File `assets/buildings/drill_dragoon/mount_e.png`. Picture `docs/shots/sprite_audit/110_buildings_drill_dragoon_mount_e.png`. Source sheet (best guess by name): `art/campaign/warmap_mountains_chatgpt.png`, `art/crown/mount/dragoon_mount_e.png`.
- **111. Armoured Dragoon (Barracks drill), mount east**, frames 0, 1 and 2: Floating rein scraps right of the man in every frame; frames 0-1 a detached boot/hoof well below the figure (likely)
  File `assets/buildings/drill_dragoon_armoured/mount_e.png`. Picture `docs/shots/sprite_audit/111_buildings_drill_dragoon_armoured_mount_e.png`. Source sheet (best guess by name): `art/campaign/warmap_mountains_chatgpt.png`, `art/crown/mount/dragoon_mount_e.png`.
- **112. Musketeer (Barracks drill), reload east**, frames 2 and 7: At 26 px the musket is hard to find in frames 5-7 (frame 7 seems to have none) and frame 2 is lower/smaller than its neighbours (unsure)
  File `assets/buildings/drill_musketeer/reload_e.png`. Picture `docs/shots/sprite_audit/112_buildings_drill_musketeer_reload_e.png`. Source sheet (best guess by name): `art/crown/reload_cannon_a.png`, `art/crown/reload_cannon_b.png`.
- **113. Gate in a N-S line**, frame 0: gate_v_construction and gate_v_destroyed look cut-and-rotated (planks at odd angles, a cross-shaped heap) and do not match the side-on built/damaged/open gate tower (unsure)
  File `assets/buildings/gate_v_construction.png`. Picture `docs/shots/sprite_audit/113_buildings_gate_v_construction.png`. Source sheet (best guess by name): `art/crown/palisade_gate_v.png`.
- **114. Powder Mill horse, walk east**, frames 2 and 4: Body length jumps between frames (frame 4 noticeably shorter and smaller than 0/1/5); navy-blue background specks on the legs and belly in several frames of walk_e and walk_se. Leg counts are 4 in every frame (likely)
  File `assets/buildings/mill_horse/walk_e.png`. Picture `docs/shots/sprite_audit/114_buildings_mill_horse_walk_e.png`. Source sheet (best guess by name): `art/redraws/clock_soldier_walk_e_chatgpt.png`, `art/redraws/dilophosaurus_walk_e_chatgpt.png`.
- **115. Powder Mill runner stone**, frame 0: Flat grey disc with a plain arm, looks code-drawn/out of style next to the painted mill (unsure)
  File `assets/buildings/mill_runner.png`. Picture `docs/shots/sprite_audit/115_buildings_mill_runner.png`. Source sheet (best guess by name): `art/crown/mill_runner_top.png`, `art/crown/farm_windmill.png`.
- **116. Nitre Beds (study switch only)**, frame 0: Stand-in drawn with PIL (flat boxes, plain stripes) and clearly out of style next to the painted buildings; documented, only with powder:nitre
  File `assets/buildings/nitre_beds_built.png`. Picture `docs/shots/sprite_audit/116_buildings_nitre_beds_built.png`.
- **117. Diagonal palisade**, frame 0: Diagonal walls (all wall_diag_*) are recomposed in code from straight stakes with uniform steel bands; they look flatter/more regular than the painted E-W palisade (already listed in docs/art_style_inconsistency.md)
  File `assets/buildings/wall_diag_se_built.png`. Picture `docs/shots/sprite_audit/117_buildings_wall_diag_se_built.png`.
- **118. effects**, the whole strip: tool split, not checked (ballista_bolt is 1 frame; also fire.png, screw_impact, screw_muzzle, storm_in, zap_strike cell guesses)
  File `assets/effects/ballista_bolt.png`. Picture `docs/shots/sprite_audit/118_effects_ballista_bolt.png`. Source sheet (best guess by name): `art/redraws/ballista_wreck_chatgpt.png`, `art/redraws/ballista_dirs.png`.
- **119. Brood realm painting (menu fallback)**, frame 0: Brood mounds and creatures carry bright RED spines/crystals throughout, against the green Brood rule; only used when battle.jpg is missing (main.gd fallback), so rarely seen
  File `assets/menu/brood.png`. Picture `docs/shots/sprite_audit/119_menu_brood.png`. Source sheet (best guess by name): `art/redraws/brood_egg_chatgpt.png`, `art/redraws/brood_mother_concept1_chatgpt.png`.

### Campaign art and rebels

- **120. Pikeman (Crown campaign), attack**, frames 0 and 1: All attack strips are 2 near-identical frames equal to the brace pose (a 1-2 px shift); the thrust is barely visible. Old retired-Pikeman strips, clearly older/blockier style than the rebel ChatGPT sprites beside them. (likely)
  File `assets/units/pikeman/attack_s.png`. Picture `docs/shots/sprite_audit/120_units_pikeman_attack_s.png`. Source sheet (best guess by name): `art/campaign/rebels/pikeman_chatgpt.png`, `art/campaign/rebels/pikeman_thrust_chatgpt.png`.
- **121. Pikeman (Crown campaign), attack south-east**, frame 1: Frame 1 is a different pose: the pike is held at shoulder like a musket and the body is drawn smaller/differently from frame 0 and from the other facings. (unsure)
  File `assets/units/pikeman/attack_se.png`. Picture `docs/shots/sprite_audit/121_units_pikeman_attack_se.png`. Source sheet (best guess by name): `art/campaign/rebels/pikeman_chatgpt.png`, `art/campaign/rebels/pikeman_thrust_chatgpt.png`.
- **122. Rebel Militiaman, melee**, frames 0, 1, 2 and 3: Bayonet thrust is the aim frame pushed forward in code (no drawn thrust), so he 'slides' while aiming; aimup/fireup are exact copies of aim/fire (stand-ins per docs/rebel_art.md).
  File `assets/units/rebel_militia/melee_e.png`. Picture `docs/shots/sprite_audit/122_units_rebel_militia_melee_e.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **123. Rebel Militiaman, walk south**, frame 1: Frame 1 the musket suddenly hangs low across the body to the bottom-left while frames 0 and 2 carry it on the shoulder; the gun jumps position each cycle. (unsure)
  File `assets/units/rebel_militia/walk_s.png`. Picture `docs/shots/sprite_audit/123_units_rebel_militia_walk_s.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **124. Rebel Pikeman, attack north**, frames 0, 1 and 2: Frame 1 the pike stands straight up over the head while frames 0 and 2 slant it right; the pike jumps between angles (docs/rebel_art.md calls part of the n thrust moved, not redrawn). (likely)
  File `assets/units/rebel_pikeman/attack_n.png`. Picture `docs/shots/sprite_audit/124_units_rebel_pikeman_attack_n.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **125. Rebel Pikeman, attack south-east**, frames 0, 1 and 2: The pike is held low and points down-right to the ground below the feet (also brace_se); the thrust does not read as a thrust toward the target. (likely)
  File `assets/units/rebel_pikeman/attack_se.png`. Picture `docs/shots/sprite_audit/125_units_rebel_pikeman_attack_se.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **126. Rebel Torch-bearer, build**, frames 0 and 1: The torch vanishes in the build strips (e, n, se, s; ne has it only in frame 2): a crouch with a flask. Stand-in, rebels never build, so low impact.
  File `assets/units/rebel_torch/build_e.png`. Picture `docs/shots/sprite_audit/126_units_rebel_torch_build_e.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **127. Rebel Torch-bearer, mine (setting fire) south-east**, frames 2 and 3: Detached orange specks float in front of/below the torch (frame 2) and a brown smear sits behind the hat (frame 3); se is the stand-in built from row 3 + row 4 (docs/rebel_art.md). (likely)
  File `assets/units/rebel_torch/mine_se.png`. Picture `docs/shots/sprite_audit/127_units_rebel_torch_mine_se.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **128. Rebel Torch-bearer, walk north**, frames 0, 1, 2 and 3: The n group (separate redraw) is a broader, larger man than the e/ne/s/se groups (shoulders and body visibly bigger, white shirt front); size and design change when he turns north. idle_n and death_n too. (likely)
  File `assets/units/rebel_torch/walk_n.png`. Picture `docs/shots/sprite_audit/128_units_rebel_torch_walk_n.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **129. Etienne Varenne, melee south**, frame 2: Frame 2 the sabre blade is a thin grey arc above the crouched man's head, apparently not connected to his hand. (unsure)
  File `assets/units/rebel_varenne/melee_s.png`. Picture `docs/shots/sprite_audit/129_units_rebel_varenne_melee_s.png`. Source sheet (best guess by name): `art/campaign/stills/p01_04_rebels_come.png`.
- **130. The King (Rome hub figure)**, frame 0: The pipe smoke above the match was keyed to MAGENTA/pink, and a magenta fleck sits in the hair left of the crown (cut-out artifact). The king.png portrait, cropped from this, shows the same pink fleck by the crown.
  File `campaign/hub/rome_king.png`. Picture `docs/shots/sprite_audit/130_campaign_hub_rome_king.png`. Source sheet (best guess by name): `art/campaign/hub/rome_king_chatgpt.png`, `art/campaign/hub/rome_room_chatgpt.png`.
- **131. Tomasz (Rome hub)**, frame 0: The hub Tomasz is an old grey-haired cardinal in full scarlet, while portraits/tomasz.png (used in dialogue) and all stills show the young black-cassock priest. Fine if the hub is decades later, but the two faces do not read as the same man. (unsure)
  File `campaign/hub/rome_tomasz.png`. Picture `docs/shots/sprite_audit/131_campaign_hub_rome_tomasz.png`. Source sheet (best guess by name): `art/campaign/hub/rome_tomasz_chatgpt.png`, `art/campaign/hub/rome_king_chatgpt.png`.
- **132. Portraits hollweg / king / lindqvist**, frame 0: These three portraits are tight crops of the hub figures (blurrier, oblique, background of the room) unlike the other 33 frontal bust portraits on a plain dark ground; style inconsistent in the dialogue box.
  File `campaign/portraits/hollweg.png`. Picture `docs/shots/sprite_audit/132_campaign_portraits_hollweg.png`. Source sheet (best guess by name): `art/campaign/hub/nuremberg_hollweg_chatgpt.png`.
- **133. The Fürth line firing**, frame 0: Foreground kneeling musketeer: the musket's butt floats beside the shoulder with no hand at the stock (only the forward hand holds it). (unsure)
  File `campaign/stills/a02_03.jpg`. Picture `docs/shots/sprite_audit/133_campaign_stills_a02_03.png`. Source sheet (best guess by name): `art/campaign/stills/a02_01.png`, `art/campaign/stills/a02_02.png`.
- **134. The convoy raided**, frame 0: The ox team is muddled: three ox heads but the bodies merge into one mass, one head has no body of its own. (likely)
  File `campaign/stills/a05_05.jpg`. Picture `docs/shots/sprite_audit/134_campaign_stills_a05_05.png`. Source sheet (best guess by name): `art/campaign/stills/a05_01.png`, `art/campaign/stills/a05_02.png`.
- **135. Rome burning**, frame 0: The automata in the night of fire are brass/gold, not the Clockwork's red; minor colour-code slip. Tone otherwise fine. (unsure)
  File `campaign/stills/a07_06.jpg`. Picture `docs/shots/sprite_audit/135_campaign_stills_a07_06.png`. Source sheet (best guess by name): `art/campaign/stills/a07_01.png`, `art/campaign/stills/a07_02.png`.
- **136. Rebels burning the plantation**, frame 0: The shouting leader's long gun has an impossible length: its barrel continues as a pike-long shaft up to the burning roof (a musket merged with a pike). (likely)
  File `campaign/stills/p01_04.jpg`. Picture `docs/shots/sprite_audit/136_campaign_stills_p01_04.png`. Source sheet (best guess by name): `art/campaign/stills/p01_05_musket_fix_chatgpt.png`, `art/campaign/stills/p01_01_king_pipe.png`.
- **137. War map mountains**, the whole strip: Thin purple/magenta specks along the base edge of several mountains (mountain_0..7). Their multi-cell rows on the sheet are a tool split, not checked. (likely)
  File `campaign/warmap_art/mountain_2.png`. Picture `docs/shots/sprite_audit/137_campaign_warmap_art_mountain_2.png`. Source sheet (best guess by name): `art/campaign/warmap_mountains_chatgpt.png`.
- **138. War map sea serpent**, frame 0: Pinkish fringe pixels round the outline and in the waves (same keying halo as the ships). Motif itself fine (classic map sea serpent). (unsure)
  File `campaign/warmap_art/serpent.png`. Picture `docs/shots/sprite_audit/138_campaign_warmap_art_serpent.png`. Source sheet (best guess by name): `art/redraws/hooded_serpent_concept2_chatgpt.png`, `art/redraws/hooded_serpent_concept_chatgpt.png`.

### Clockwork

- **139. Clock Soldier, guard_walk east**, frames 0, 1 and 2: A detached orange speck (loose heel) floats behind the rear foot. (likely)
  File `assets/units/clock_soldier/guard_walk_e.png`. Picture `docs/shots/sprite_audit/139_units_clock_soldier_guard_walk_e.png`. Source sheet (best guess by name): `art/redraws/clock_soldier_attack_chatgpt.png`, `art/redraws/clock_soldier_idle_west_chatgpt.png`.
- **140. Clock Soldier, guard_walk south-west**, frames 0, 1, 2, 3, 4 and 5: The left arm sticks out to the viewer right as a stub ending in a flat cut-off pipe while the shield is held in front of the chest: looks like an extra/floating shoulder piece with no hand. (Sword correctly in the right hand, shield on the left.) (unsure)
  File `assets/units/clock_soldier/guard_walk_sw.png`. Picture `docs/shots/sprite_audit/140_units_clock_soldier_guard_walk_sw.png`. Source sheet (best guess by name): `art/redraws/clock_soldier_attack_chatgpt.png`, `art/redraws/clock_soldier_idle_west_chatgpt.png`.
- **141. Swift (cuckoo), walk/idle (fly loop) north-east**, frame 0: Same as the owl, milder: NE frame 0 is turned toward east (head and tail in profile), frames 1-3 seen from behind. (likely)
  File `assets/units/cuckoo/walk_ne.png`. Picture `docs/shots/sprite_audit/141_units_cuckoo_walk_ne.png`. Source sheet (best guess by name): `art/redraws/cuckoo_peck_chatgpt_try.png`, `art/redraws/cuckoo_peck_chatgpt_try2.png`.
- **142. Great Winder, death all**, frames 0, 1, 2, 3 and 4: Death is made in code from the standing frame (per tools/cw_art notes): the legs slide away as rigid rotated chunks and the body just sinks; it looks pasted next to the painted strips.
  File `assets/units/great_winder/death_s.png`. Picture `docs/shots/sprite_audit/142_units_great_winder_death_s.png`. Source sheet (best guess by name): `art/redraws/great_winder_dirs_v2_chatgpt.png`, `art/redraws/great_winder_key_rollers_chatgpt.png`.
- **143. Ore Locomotive (unused), run e, n, s**, the whole strip: Not referenced by any script. Its run strips are 4 frames side by side with no cell size known to the game; run_n shows the engine at an angle rather than from behind. (unsure)
  File `assets/units/ore_locomotive/run_e.png`. Picture `docs/shots/sprite_audit/143_units_ore_locomotive_run_e.png`.
- **144. Pendulum, attack_hi_l / attack_hi_r east**, frames 0, 1, 2, 3, 4 and 5: attack_hi_l_e and attack_hi_r_e are the same drawing (the same near arm swings in both), so the "alternate arms" high swing does not alternate in the E/W views. (likely)
  File `assets/units/pendulum/attack_hi_l_e.png`. Picture `docs/shots/sprite_audit/144_units_pendulum_attack_hi_l_e.png`. Source sheet (best guess by name): `art/redraws/pendulum_death_chatgpt_1.png`, `art/redraws/pendulum_death_chatgpt_2.png`.
- **145. Pendulum, attack_hi_l north**, frame 4: A few pink/magenta pixels at the blade where the arm crosses over the head (also a small red streak above the body in attack_hi_r_ne frame 2, probably a swing trail). (unsure)
  File `assets/units/pendulum/attack_hi_l_n.png`. Picture `docs/shots/sprite_audit/145_units_pendulum_attack_hi_l_n.png`. Source sheet (best guess by name): `art/redraws/pendulum_death_chatgpt_1.png`, `art/redraws/pendulum_death_chatgpt_2.png`.
- **146. Pendulum, walk n, ne**, frames 1, 4 and 5: Feet bob 1-2 px above/below the ground line between walk frames (bottom row 83-86 vs anchor 84); other facings sit exactly on it.
  File `assets/units/pendulum/walk_n.png`. Picture `docs/shots/sprite_audit/146_units_pendulum_walk_n.png`. Source sheet (best guess by name): `art/redraws/pendulum_v2_walk_e_chatgpt.png`, `art/redraws/pendulum_v2_walk_s_chatgpt.png`.
- **147. Skywing (old/experimental), gattack/land se, n, ne**, frame 1: Frames touch the cell edge: gattack_se f1 and gattack_n f2 cut at the bottom, land_se f3 at the left, land_ne f0 at the top.
  File `assets/units/skywing/gattack_se.png`. Picture `docs/shots/sprite_audit/147_units_skywing_gattack_se.png`. Source sheet (best guess by name): `art/redraws/skywing_pterosaur_concept_chatgpt.png`, `art/brood/skywing.png`.
- **148. Ticking Owl, attack south-east**, frame 3: Right wing tip ends in a straight vertical edge (looks cut). (unsure)
  File `assets/units/ticking_owl/attack_se.png`. Picture `docs/shots/sprite_audit/148_units_ticking_owl_attack_se.png`. Source sheet (best guess by name): `art/redraws/ticking_owl_fly.png`.
- **149. Windup Soldier (old/experimental), walk all**, frames 4 and 5: Walk legs are drawn in code (docs/art_style_inconsistency.md); in walk_ne the rifle appears only in frames 4-5. Tiny low-res figure, every facing the same side pose. (likely)
  File `assets/units/windup_soldier/walk_ne.png`. Picture `docs/shots/sprite_audit/149_units_windup_soldier_walk_ne.png`. Source sheet (best guess by name): `art/clockwork/windup_soldier.png`.

### Crown on foot

- **150. Clockwork wind-up key**, the whole strip: Tool split, not checked (a 16 x 6 grid of keys, split into 4 cells by the sheet tool). Keys are code-turned from one painted still (known). (unsure)
  File `assets/units/_shared/wind_key_11.png`. Picture `docs/shots/sprite_audit/150_units_shared_wind_key_11.png`.
- **151. Drummer / Fifer / Piper, death south-east**, frames 0, 1 and 2: Code-made death (the walk frame tipped 35/70/90 degrees, known): rigid rotation; the tipped figure runs to the canvas bottom (46, below the feet line at 44). Idle is the same strip as walk; SE only.
  File `assets/units/band/death_se.png`. Picture `docs/shots/sprite_audit/151_units_band_death_se.png`. Source sheet (best guess by name): `art/redraws/band_drummer_walk_se_chatgpt.png`, `art/redraws/band_fifer_walk_se_b_chatgpt.png`.
- **152. Field Cannon, death all**, frame 1: Smoke dissolves as a hard checkerboard dither pattern (also the leaving horse in deploy and the smoke in fire frame 3): reads as a checkerboard at game zoom. Code effect.
  File `assets/units/cannon/death_s.png`. Picture `docs/shots/sprite_audit/152_units_cannon_death_s.png`. Source sheet (best guess by name): `art/crown/cannon.png`, `art/crown/cannon2_angles.png`.
- **153. Field Cannon, reload north**, frames 0, 1, 2, 3, 4, 5, 6, 7, 8 and 9: The rammer crouches on top of the vertical barrel's muzzle and reads as floating in mid-air above the gun. (unsure)
  File `assets/units/cannon/reload_n.png`. Picture `docs/shots/sprite_audit/153_units_cannon_reload_n.png`. Source sheet (best guess by name): `art/crown/reload_cannon_a.png`, `art/crown/reload_cannon_b.png`.
- **154. Field Cannon, walk se, ne**, the whole strip: walk_se and walk_ne are the same east side view as walk_e (limber pulled flat to the right); no diagonal views.
  File `assets/units/cannon/walk_se.png`. Picture `docs/shots/sprite_audit/154_units_cannon_walk_se.png`. Source sheet (best guess by name): `art/crown/cannon.png`, `art/crown/cannon2_angles.png`.
- **155. Dismounted Officer, walk e, se, ne**, frames 2, 3, 5, 6 and 7: The hat crown touches the top row of the 36 px canvas in many walk frames; may be trimmed by 1-2 px. (unsure)
  File `assets/units/dismounted/walk_e.png`. Picture `docs/shots/sprite_audit/155_units_dismounted_walk_e.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`.
- **156. Dismounted Cuirassier, death all**, frames 2, 3 and 4: Small orange/brown specks lie just below the ground line under the body. (likely)
  File `assets/units/dismounted_armoured/death_s.png`. Picture `docs/shots/sprite_audit/156_units_dismounted_armoured_death_s.png`. Source sheet (best guess by name): `art/redraws/cuirassier_dismounted_melee_death_e_chatgpt.png`, `art/redraws/cuirassier_dismounted_melee_death_n_chatgpt.png`.
- **157. Gun Crewman, death s, ne**, frame 1: The flying helmet is cut flat at the top edge of the canvas. Frame 2's body lying down shows no head. (Death is the Labourer stand-in, known.) (likely)
  File `assets/units/gun_crew/death_s.png`. Picture `docs/shots/sprite_audit/157_units_gun_crew_death_s.png`. Source sheet (best guess by name): `art/redraws/gun_crew_death_e_chatgpt.png`, `art/redraws/gun_crew_death_n_chatgpt.png`.
- **158. Gun Crewman, idle se, e, ne**, frames 0 and 1: Idle frames are mid-stride walk poses (one leg forward), so he seems frozen mid-step when standing. (likely)
  File `assets/units/gun_crew/idle_e.png`. Picture `docs/shots/sprite_audit/158_units_gun_crew_idle_e.png`. Source sheet (best guess by name): `art/redraws/gun_crew_death_e_chatgpt.png`, `art/redraws/gun_crew_death_n_chatgpt.png`.
- **159. Labourer, bury north**, frames 1, 2, 3 and 5: Frames 1-3 are a standing back view with no shovel while a soil pile grows beside him (code repair, known); frame 5 turns to a front view. Frame 4 in every facing replaces him with a dirt mound (he vanishes into it, then reappears).
  File `assets/units/labourer/bury_n.png`. Picture `docs/shots/sprite_audit/159_units_labourer_bury_n.png`. Source sheet (best guess by name): `art/redraws/labourer_bury.png`, `art/crown/labourer.png`.
- **160. Labourer, death north**, frame 0: All five death facings are the same side-on fall; the north one is not a back view. (likely)
  File `assets/units/labourer/death_n.png`. Picture `docs/shots/sprite_audit/160_units_labourer_death_n.png`. Source sheet (best guess by name): `art/redraws/labourer_death.png`, `art/redraws/labourer_death_keg.png`.
- **161. Labourer, idle_keg south**, frame 0: The keg sits in the middle of the chest in frame 0 and jumps to his right side in frames 1-3. (likely)
  File `assets/units/labourer/idle_keg_s.png`. Picture `docs/shots/sprite_audit/161_units_labourer_idle_keg_s.png`. Source sheet (best guess by name): `art/crown/labourer.png`, `art/crown/labourer_keg.png`.
- **162. Labourer, shovel / mine all**, the whole strip: Code-drawn tools on painted bodies (hoe, shovel and loads, known in art_style_inconsistency.md).
  File `assets/units/labourer/shovel_s.png`. Picture `docs/shots/sprite_audit/162_units_labourer_shovel_s.png`. Source sheet (best guess by name): `art/crown/labourer.png`, `art/crown/labourer_keg.png`.
- **163. Labourer, walk north**, frame 2: Frame 2's torso is wider/blockier and the head sits 1-2 px higher than its neighbours: a small hitch in the loop. (unsure)
  File `assets/units/labourer/walk_n.png`. Picture `docs/shots/sprite_audit/163_units_labourer_walk_n.png`. Source sheet (best guess by name): `art/redraws/gait_src/labourer_walk_s_prestride.png`, `art/redraws/gait_src/labourer_walk_se_prestride.png`.
- **164. Labourer, walk_shovel all**, the whole strip: Code composite (known): the shovel strip's upper body on the walk legs; the loaded shovel is stiff and flatter in style than the painted body. walk_shovel_e/_n also touch the top edge of the canvas (hat crown).
  File `assets/units/labourer/walk_shovel_e.png`. Picture `docs/shots/sprite_audit/164_units_labourer_walk_shovel_e.png`. Source sheet (best guess by name): `art/crown/labourer.png`, `art/crown/labourer_keg.png`.
- **165. Mortar, death all**, frames 0, 1, 2 and 3: The wreck sits 4-9 px below the feet line (bottoms at 82-87 v 78 for idle), so the dead crew sinks into the ground. (likely)
  File `assets/units/mortar/death_s.png`. Picture `docs/shots/sprite_audit/165_units_mortar_death_s.png`. Source sheet (best guess by name): `art/crown/mortar_a.png`, `art/crown/mortar_b.png`.
- **166. Musketeer, death north**, frames 0, 1 and 2: North death shows him from the front (face visible), not his back. (likely)
  File `assets/units/musketeer/death_n.png`. Picture `docs/shots/sprite_audit/166_units_musketeer_death_n.png`. Source sheet (best guess by name): `art/redraws/musketeer_aim_ne_chatgpt.png`, `art/redraws/musketeer_aim_s_chatgpt.png`.
- **167. Musketeer, idle east**, frames 0 and 1: The musket butt pokes below the feet line. (likely)
  File `assets/units/musketeer/idle_e.png`. Picture `docs/shots/sprite_audit/167_units_musketeer_idle_e.png`. Source sheet (best guess by name): `art/redraws/musketeer_aim_ne_chatgpt.png`, `art/redraws/musketeer_aim_s_chatgpt.png`.
- **168. Musketeer, idle north**, frame 2: Frame 2 is narrower with a different gold patch on the coat (design change vs frames 0-1). Same in the Armoured Musketeer's idle_n. (unsure)
  File `assets/units/musketeer/idle_n.png`. Picture `docs/shots/sprite_audit/168_units_musketeer_idle_n.png`. Source sheet (best guess by name): `art/redraws/musketeer_aim_ne_chatgpt.png`, `art/redraws/musketeer_aim_s_chatgpt.png`.
- **169. Armoured Musketeer, fireup south**, frames 0 and 1: Two stray grey pixels float to the right of the figure at knee height (leftover background specks).
  File `assets/units/musketeer_armoured/fireup_s.png`. Picture `docs/shots/sprite_audit/169_units_musketeer_armoured_fireup_s.png`. Source sheet (best guess by name): `art/redraws/musketeer_armoured_aim_ne_chatgpt.png`, `art/redraws/musketeer_armoured_aim_s_chatgpt.png`.
- **170. Armoured Musketeer, idle south**, frames 0 and 1: The musket barrel is cut flat at the top edge of the canvas in both frames.
  File `assets/units/musketeer_armoured/idle_s.png`. Picture `docs/shots/sprite_audit/170_units_musketeer_armoured_idle_s.png`. Source sheet (best guess by name): `art/redraws/musketeer_armoured_aim_ne_chatgpt.png`, `art/redraws/musketeer_armoured_aim_s_chatgpt.png`.
- **171. Armoured Musketeer, walk south-east**, frame 3: Frame 3's body changes design: brown stock across the chest, more red, legs a different grey than frames 0-2. (unsure)
  File `assets/units/musketeer_armoured/walk_se.png`. Picture `docs/shots/sprite_audit/171_units_musketeer_armoured_walk_se.png`. Source sheet (best guess by name): `art/redraws/gait_src/crown_musketeer_armoured_walk_e.png`, `art/redraws/gait_src/crown_musketeer_armoured_walk_n.png`.

### Crown riders and wagons

- **172. Balloon, death all**, frame 4: The crash frame's smoke columns reach the top of the cell and are cut flat; the gunner_down/up last frames' smoke also touches the cell edge.
  File `assets/units/balloon/death_e.png`. Picture `docs/shots/sprite_audit/172_units_balloon_death_e.png`. Source sheet (best guess by name): `art/crown/balloon_basket_pilot.png`, `art/crown/balloon_rope_barrel.png`.
- **173. Balloon, idle/drift all**, the whole strip: The envelope's stripes and ragged brown patch marks change shape from frame to frame (idle_e frame 1 noticeably different), so the canopy shimmers; edges are jagged. (likely)
  File `assets/units/balloon/idle_e.png`. Picture `docs/shots/sprite_audit/173_units_balloon_idle_e.png`. Source sheet (best guess by name): `art/crown/balloon_basket_pilot.png`, `art/crown/balloon_rope_barrel.png`.
- **174. Balloon pilot, pilot all**, frame 3: Frame 3 of every pilot strip is empty (basket_* frame 3 instead shows a crewman): probably by design (pilot hidden/moved), unsure. (unsure)
  File `assets/units/balloon/pilot_s.png`. Picture `docs/shots/sprite_audit/174_units_balloon_pilot_s.png`. Source sheet (best guess by name): `art/crown/balloon_basket_pilot.png`, `art/crown/balloon_rope_barrel.png`.
- **175. Dragoon, idle north-east**, the whole strip: idle_ne is an exact copy of idle_e (a SE-ish view with the rider's front); death_ne == death_e, and all death facings play the same SE-ish fall.
  File `assets/units/dragoon/idle_ne.png`. Picture `docs/shots/sprite_audit/175_units_dragoon_idle_ne.png`. Source sheet (best guess by name): `art/crown/dragoons.png`, `art/crown/mount/dragoon_armoured_mount.png`.
- **176. Dragoon, walk se/s/ne**, the whole strip: The musket on his back vanishes between facings: slung musket visible in walk_s and walk_ne (bayonet tip), absent in walk_se and walk_e. (likely)
  File `assets/units/dragoon/walk_se.png`. Picture `docs/shots/sprite_audit/176_units_dragoon_walk_se.png`. Source sheet (best guess by name): `art/crown/dragoons.png`, `art/crown/mount/dragoon_armoured_mount.png`.
- **177. Horse, death north-east**, frame 1: Frame 1 is a jumbled sitting/tangled shape that doesn't follow frames 0 and 2; across the death strips the head flips sides between frames (e.g. death_n 0 head left, 2 head right). (likely)
  File `assets/units/horse/death_ne.png`. Picture `docs/shots/sprite_audit/177_units_horse_death_ne.png`. Source sheet (best guess by name): `art/crown/horseman_attack_death.png`, `art/crown/barracks_props/horse_prop.png`.
- **178. Horse, walk/idle all**, the whole strip: Scattered single white pixels on the dark coat and legs in most frames (look like halo/background specks rather than highlights). (unsure)
  File `assets/units/horse/walk_e.png`. Picture `docs/shots/sprite_audit/178_units_horse_walk_e.png`. Source sheet (best guess by name): `art/crown/barracks_props/horse_prop.png`, `art/crown/buildings_v2/horse_breeder.png`.
- **179. Horse, walk south**, frames 4 and 5: Frames 4-5 turn the horse to a three-quarter view (head swinging to the viewer's left) while 0-3 face straight at the camera; walk_se frame 0 similarly is more frontal than 1-4.
  File `assets/units/horse/walk_s.png`. Picture `docs/shots/sprite_audit/179_units_horse_walk_s.png`. Source sheet (best guess by name): `art/crown/barracks_props/horse_prop.png`, `art/crown/buildings_v2/horse_breeder.png`.
- **180. Horse team (gun/wagon horse), walk se/e**, frames 1 and 2: Pale blue-grey fragments between the legs (far legs washed to background colour or background left in), most visible in walk_se frames 1-2; leg count hard to read in walk_e frame 4. (unsure)
  File `assets/units/horse_team/walk_se.png`. Picture `docs/shots/sprite_audit/180_units_horse_team_walk_se.png`. Source sheet (best guess by name): `art/crown/horse_team.png`, `art/crown/barracks_props/horse_prop.png`.
- **181. Horseman, attack south**, frame 2: Frame 2 the horse twists to a three-quarter view (tail/rump swinging out to the left) while frames 0,1,3 are straight front; same frame-2 body swing in attack_se, attack_e and attack_n. (likely)
  File `assets/units/horseman/attack_s.png`. Picture `docs/shots/sprite_audit/181_units_horseman_attack_s.png`. Source sheet (best guess by name): `art/crown/horseman_attack_death.png`, `art/crown/horseman.png`.
- **182. Horseman, death north**, frame 1: While the rider is still upright in the saddle, a horizontal leg/arm with a brown boot sticks out to the right of him: looks like an extra limb from the thrown-rider pose. (unsure)
  File `assets/units/horseman/death_n.png`. Picture `docs/shots/sprite_audit/182_units_horseman_death_n.png`. Source sheet (best guess by name): `art/crown/horseman_attack_death.png`, `art/crown/horseman.png`.
- **183. Horseman, death south**, frames 0 and 1: The rearing horse is drawn in side profile (head to the right), not facing south; all five death strips use the same side-on fall, so frames 2-3 are identical across facings.
  File `assets/units/horseman/death_s.png`. Picture `docs/shots/sprite_audit/183_units_horseman_death_s.png`. Source sheet (best guess by name): `art/crown/horseman_attack_death.png`, `art/crown/horseman.png`.
- **184. Horseman/Cuirassier, pistol n/s**, frames 1 and 2: In the N and S pistol strips (both Horseman and Cuirassier) the pistol is fired out sideways to the viewer's right, not along the facing (away from / toward the camera).
  File `assets/units/horseman/pistol_n.png`. Picture `docs/shots/sprite_audit/184_units_horseman_pistol_n.png`. Source sheet (best guess by name): `art/crown/horseman_pistol.png`, `art/crown/horseman.png`.
- **185. Missionary, walk all**, the whole strip: Walk legs are code-built (documented in art_style_inconsistency.md, import_gait_missionary.py): wide black trousers under the robe hem, stiff next to the painted idle.
  File `assets/units/missionary/walk_s.png`. Picture `docs/shots/sprite_audit/185_units_missionary_walk_s.png`. Source sheet (best guess by name): `art/crown/missionary.png`, `art/crown/missionary_mounted.png`.
- **186. Missionary (bandaging a musketeer), bandage north**, frames 0, 1 and 2: The N view shows the missionary from the FRONT (red stole down his chest) like the SE view, while missionary_bandage_c/bandage_n correctly shows him from behind. (likely)
  File `assets/units/missionary_bandage_h/bandage_n.png`. Picture `docs/shots/sprite_audit/186_units_missionary_bandage_h_bandage_n.png`. Source sheet (best guess by name): `art/crown/mount/missionary_bandage_a.png`, `art/crown/mount/missionary_bandage_b.png`.
- **187. Mounted Missionary, mount all**, frame 5: The processional cross appears from nowhere in the last frame of every mount strip (frames 0-4 he carries only the bag).
  File `assets/units/missionary_mounted/mount_s.png`. Picture `docs/shots/sprite_audit/187_units_missionary_mounted_mount_s.png`. Source sheet (best guess by name): `art/crown/missionary_mounted.png`, `art/crown/mount/missionary_mount.png`.
- **188. Powder Wagon, walk south-east**, frames 0 and 1: Frames 0-1 are narrower and more front-on than 2-5 (angle drift inside the loop).
  File `assets/units/powder_wagon/walk_se.png`. Picture `docs/shots/sprite_audit/188_units_powder_wagon_walk_se.png`. Source sheet (best guess by name): `art/crown/powder_wagon.png`, `art/crown/mill_base/powder_mill_built.png`.

### Icons, UI, props

- **189. ARM WITH POWDER (and ab_mortar_deploy)**, frame 0: Composited in code from pasted painted pieces (keg + pistol; mortar + arrow). These are the known placeholders. They read fine but sit visibly pasted together.
  File `assets/icons/ab_arm_powder.png`. Picture `docs/shots/sprite_audit/189_icons_ab_arm_powder.png`.
- **190. BUY POWDER**, frame 0: A flat code-drawn keg and coin with no frame, unlike the painted buttons (a stand-in for the powder study's switch).
  File `assets/icons/ab_buy_powder.png`. Picture `docs/shots/sprite_audit/190_icons_ab_buy_powder.png`.
- **191. Command icon frames**, frame 0: The top-level command buttons mix two frame styles: a gold/brown riveted frame (ab_brace, ab_deploy, ab_harvest, ab_overload, ab_reload, ab_sacrifice, ab_storm, ab_windup, ab_land, ab_courier) and a grey bevelled frame (ab_supply, ab_limber, ab_round_shot, attack, move...). Some Crown buttons (ab_reload) use the Clockwork-like brass frame. The style is not consistent within one faction's card.
  File `assets/icons/ab_deploy.png`. Picture `docs/shots/sprite_audit/191_icons_ab_deploy.png`.
- **192. Crown-folder JUMP / MORPH OWL / HIGH LEAP buttons**, frame 0: ab_jump, ab_morph_owl and research_high_leap at the top level are bare unit sprites on transparency (no frame, no dark backdrop), unlike the other command buttons. The framed Clockwork copies exist in icons/clockwork/. Check that the frameless ones are still used.
  File `assets/icons/ab_jump.png`. Picture `docs/shots/sprite_audit/192_icons_ab_jump.png`.
- **193. TONGUE (top-level copy)**, frame 0: A low-detail toad crop on a plain grey square with no frame. The tongue is cut flat at the right border. icons/brood/ab_tongue.png is the proper framed version.
  File `assets/icons/ab_tongue.png`. Picture `docs/shots/sprite_audit/193_icons_ab_tongue.png`.
- **194. Brood TAKE OFF**, frame 0: Unsure: the flyer's body has a head with a beak on the right, plus a second beak/crest-like shape on the left above the wing, which might read as two heads. At 64 px it is ambiguous. (unsure)
  File `assets/icons/brood/ab_take_off.png`. Picture `docs/shots/sprite_audit/194_icons_brood_ab_take_off.png`.
- **195. Brood BUILD**, frame 0: The middle shows a carved green face in a shrine of bones and red spines. It looks like an idol or tribal mask, and it does not say BUILD. Unsure what was meant. (unsure)
  File `assets/icons/brood/build.png`. Picture `docs/shots/sprite_audit/195_icons_brood_build.png`. Source sheet (best guess by name): `art/redraws/cog_rings_building_flat.png`, `art/redraws/labourer_build_hammer.png`.
- **196. Clockwork SCATTER (Great Winder sweep)**, frame 0: Composited in code: a tiny shrunk Great Winder sprite and small cogs on a dotted arc. Most of the frame is empty and it is hard to read at card size (known, docs/cog_scatter.md).
  File `assets/icons/clockwork/ab_scatter.png`. Picture `docs/shots/sprite_audit/196_icons_clockwork_ab_scatter.png`.
- **197. Clutch: Raptor research icon**, frame 0: Three raptor heads grow out of ONE egg side by side, so it reads as a three-headed creature. nbr_clutch_spitter.png is almost the same picture (same egg, same three heads, only the mouths drool green), so the two buttons are hard to tell apart. (likely)
  File `assets/icons/nbr_clutch_raptor.png`. Picture `docs/shots/sprite_audit/197_icons_nbr_clutch_raptor.png`.
- **198. Nitre Beds portrait**, frame 0: A tiny flat code-drawn box on a transparent background, a stand-in. It is far below the other portraits.
  File `assets/icons/nitre_beds.png`. Picture `docs/shots/sprite_audit/198_icons_nitre_beds.png`.
- **199. Storm Challenger / Pterodactyl portraits**, frame 0: storm_challenger.png is the pterodactyl.png head cropped smaller: same crest, beak and colours. Two different units share one face. tyrannosaur / tyrant_challenger / venom_challenger are near copies of each other too, and dilophosaurus.png looks like brood_mother.png (same frilled red-spined face). brood_mother_2/_3 are only tighter crops of stage 1, so the stages are told apart by zoom alone.
  File `assets/icons/storm_challenger.png`. Picture `docs/shots/sprite_audit/199_icons_storm_challenger.png`. Source sheet (best guess by name): `art/redraws/storm_challenger_e_chatgpt.png`, `art/redraws/storm_challenger_n_chatgpt.png`.
- **200. Tension**, frame 0: Small orange-brown specks sit in the bottom-left and bottom-right corners, apart from the spring (leftovers of the source sheet). The blue swirls are cut flat at the left and right borders. (likely)
  File `assets/icons/tension.png`. Picture `docs/shots/sprite_audit/200_icons_tension.png`.
- **201. Mossy boulder**, frame 0: A detached piece of something brown floats below-right of the boulder, apart from it (a leftover fragment from the sheet). (likely)
  File `assets/props/boulder_moss.png`. Picture `docs/shots/sprite_audit/201_props_boulder_moss.png`.
- **202. Campfire prop**, frame 0: A dark navy/grey triangle stands behind the flames like a tent shape: probably the source sheet's dark backdrop or a smoke halo left in. It shows as a dark wedge on light ground. (likely)
  File `assets/props/campfire.png`. Picture `docs/shots/sprite_audit/202_props_campfire.png`.
- **203. Flag prop**, frame 0: Besides the pole, a second short stick hangs off the flag's fly end, with no reason to be there. (unsure)
  File `assets/props/flag.png`. Picture `docs/shots/sprite_audit/203_props_flag.png`.
- **204. Mushroom / forge / thorns props**, frame 0: mushroom.png is a few unreadable bluish pixels, not a mushroom (mushroom_red is fine). forge.png is a grey muddle (an anvil and a stack?) that does not read as a forge. thorns.png is noise. (likely)
  File `assets/props/mushroom.png`. Picture `docs/shots/sprite_audit/204_props_mushroom.png`.
- **205. Ruin tower (also ruin_pillar)**, frame 0: Semi-transparent bluish-grey ghost pixels hang around the left side (a halo of the old backdrop). A bare branch with a red rag sticks out of the top at an odd angle. ruin_pillar has the same blue ghost speckle on its left and top. (likely)
  File `assets/props/ruin_tower.png`. Picture `docs/shots/sprite_audit/205_props_ruin_tower.png`.
- **206. Shrine prop**, frame 0: A mossy rubble blob with no visible cross, statue, niche or roof, so nothing says shrine. Also a tone point: a wayside shrine should read as Catholic (a cross or a Marian niche). (likely)
  File `assets/props/shrine.png`. Picture `docs/shots/sprite_audit/206_props_shrine.png`.
- **207. Snow rocks (a-d)**, frame 0: Loose single specks and flakes float around the heap, detached from it. This is most visible on c and d. (likely)
  File `assets/props/snow_rocks_c.png`. Picture `docs/shots/sprite_audit/207_props_snow_rocks_c.png`.
- **208. Long table / small stall**, frame 0: The table's top surface is cut flat along the top of the image (54 opaque px on the top row). stall_small's awning is also cut flat at the top. (likely)
  File `assets/props/table_long.png`. Picture `docs/shots/sprite_audit/208_props_table_long.png`.
- **209. Tripod prop**, frame 0: The rope from the top runs off and is cut flat at the right edge. (likely)
  File `assets/props/tripod.png`. Picture `docs/shots/sprite_audit/209_props_tripod.png`.
- **210. Salgarellius Catholic Games logo**, frame 0: The angel's sword ends in an ANCHOR instead of a hilt or blade tip: a sword and an anchor fused into one object (a typical AI merge). The cross, rosary, keys shield and Chi-Rho are fine and the lettering is correct. (likely)
  File `assets/ui/logo_salgarellius.png`. Picture `docs/shots/sprite_audit/210_ui_logo_salgarellius.png`. Source sheet (best guess by name): `art/brand/salgarellius_catholic_games_logo.png`.
- **211. Brood card / panel border**, frame 0: The border's spines are bright RED. UI panels are not team-recoloured, and the Brood's colour is venom green (the owner asked for the menu Brood's red spines to go green). Unsure if intended. Panel sheets also show tool splits (brood_panel 7, clockwork_card 4, crown_card 4): single images, tool split, not checked. (unsure)
  File `assets/ui/panels/brood_card.png`. Picture `docs/shots/sprite_audit/211_ui_panels_brood_card.png`. Source sheet (best guess by name): `art/redraws/brood_egg_chatgpt.png`, `art/redraws/brood_mother_concept1_chatgpt.png`.

## Strips still assembled in code that would gain most from a painted redraw

These are not hallucinations: they are parts built or patched in code (most are listed in
docs/art_style_inconsistency.md). Ranked by how often a player sees them, the most seen first.

1. **The Labourer carrying gold and powder kegs** (carry and carry_keg, east, south-east and north-east): the walk's legs
   are pasted under the carry bodies. Labourers carry all game long. Older prompts 08 and 09 in
   docs/animation_redraw_prompts_2.md already cover it.
2. **The Guardsman's walk** (musketeer_armoured walk, all views): the Labourer's legs recoloured and pasted on; the south
   walk has only 3 frames and its legs read as one leg in the middle (MEDIUM finding). Older prompt 16 covers it.
3. **The Labourer at the Powder Mill** (shovel and walk_shovel, all views): a code-drawn shovel and loads on painted bodies,
   and the loaded-shovel walk is the shovel strip's upper body on the walk's legs. Seen whenever the Crown makes powder.
4. **The Labourer's farm hoe** (mine, all views): a code-drawn hoe. The owner liked it, and a ChatGPT candidate
   (art/redraws/labourer_hoe_v2.png) exists but was never installed. Seen at every Farm.
5. **The Field Cannon and Mortar deploy and death** (cannon and mortar deploy, cannon death): code collages, the gun jumping
   between a side view and a head-on view, a checkerboard-dithered horse and smoke, the mortar's crew count changing
   (MEDIUM findings). Seen every time a gun sets up.
6. **The Missionary's walk** (all views): code legs, wide black trousers under the robe.
7. **The Barracks cavalry drills** (drill_cuirassier, drill_horseman and the dragoon drills): the horse was masked out in
   code and scraps of reins float beside the rider (MEDIUM findings). Seen while a Barracks trains.
8. **The north-south palisade and the diagonal walls** (wall_ns construction, damaged and destroyed; every wall_diag
   picture; gate_v construction and destroyed): the east-west fence squeezed narrow or rebuilt from stakes in code.
   Seen in every walled Crown base.
9. **The Great Winder's death and the Marching Band's death**: the standing frame tipped over in code.
10. **Small icons made in code**: the Brass Serpent LINK and UNLINK, SCATTER COGS, LONG CHAIN, ARM WITH POWDER, BUY
    POWDER, the NITRE BEDS portrait, the WIND UP stand-in; and the Clockwork building portraits that have no frame and are
    cut at the 64 px edge (cog_press, cuckoo_house, escapement, heavy_works, mainspring, movement_works, regulator,
    ratchet_turret, tension). Seen on cards.
11. **Stand-ins of the newest work**: the gun crewman's death (the Labourer's), the Nitre Beds (only with the powder:nitre
    switch), the cage cart's bars and the war map's parchment (campaign), the moult shells.
12. **The old tin-mode Clockwork units** (Windup Soldier walk legs and the other prototype units): only if they come back
    into the game.

## What came out clean

- The Brood Mother at all three stages: one tail, one head, the right legs in every laying, walking and rooting frame.
- The Clock Soldier's shield is on the correct arm in every facing, including its own west views. The Pendulum has two arms
  everywhere. The Great Winder keeps its four legs. The Winder's own key is there in every frame.
- No horse in the game has an extra or a missing leg in a normal frame; horses keep the same coat and size across facings.
- The Crown buildings and the Clockwork machines agree across built, construction, damaged and destroyed (except the
  Boiler, a MEDIUM finding).
- The cursors and the stat and resource icons. The Brood DEMOLISH icon no longer looks like BUILD.
- All 59 campaign stills are paintings, none a code stand-in, and the tone fits.

## How to use this list

1. Listen to the summary and the HIGH list; open the picture of any finding to see it (the wrong frames are framed in red).
2. Tick or strike findings in this file (or say which numbers are wrong), and say which MEDIUM ones are worth a redraw.
3. For each HIGH finding, attach the named reference pictures to ChatGPT, paste the prompt, save the answer under the given
   name, and ask Claude to import it (each request names its importer).
4. After any import, run `python3 tools/audit/contact_sheets.py /tmp/check --only <unit>` and look at the new sheet.

