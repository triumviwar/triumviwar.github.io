# Brood Rootmaw spots (job brood-rootmaw-spots, 0.38.14)

The owner's decisions (2026-11-15), after the other two sides went back to their original economy in 0.38.12 (2 Farms /
2 Cog Presses a hall): the Brood keeps the only economy with a radius (Rootmaws drinking from a circle of swamp), made
fair and easy:

1. a COUNT like the other factions: 3 Rootmaws on the Brood Mother's swamp, 2 on a Mound Turtle's;
2. the circle made small enough that the standard 3 (main) and 2 (turtle) always fit, picked by MEASURING every map,
   each Rootmaw keeping a fixed food amount (9,000 at the main, 6,000 at a turtle);
3. the BEST ROOTMAW SPOTS shown in the style of the expansion spots, Brood only, only on the side's own swamp, no
   snapping; the Brood computer uses the same spots;
4. texts in en/pt/es, help, the tutorial;
5. the economy bench and a batch of computer games on the original economy: the Brood's income per minute against
   the Crown and the Clockwork at 5/8/10/12 min (a recommendation only, no other balance change);
6. tests and pictures.

## In short

- **The count.** `Defs.NB "maws_queen": 3, "maws_turtle": 2`. Every Rootmaw belongs to the swamp it roots on
  (`RootmawSpots.assign`: where swamps overlap, to the one with the most room left, then the nearest); rooting one on a
  full swamp, or sending a grub to turn into one there, is refused with
  *"Full: the Brood Mother's swamp holds 3 Rootmaws (3/3). Root a Mound Turtle for more."* (or the turtle's line). A grub
  on its way to turn into a Rootmaw, a Rootmaw walking to root, a cocoon and a Rootmaw the computer got up to fight
  (it keeps its spot) all count; one on its way up does not. The Mother's card and a rooted turtle's card show
  **ROOTMAWS 2/3**; while a Rootmaw is being placed each swamp's count stands over its Mother or turtle (red when full).
- **The circle stays at 8 tiles** (`Defs.PIT_CLAIM`, unchanged since 0.24.7): measured on every map, 3 fit round every
  start and 2 round every turtle site already at 8 (section 2), so nothing had to shrink. **Food unchanged**: each
  Rootmaw's ground is still `PIT_GROUND` 3,000 (9,000 round the Mother, 6,000 round a turtle), its drinking rate
  (`maw_fill` 4/s x the distance pay) and the trip pay as before.
- **The marks** (`scripts/rootmaw_spots.gd`, `RootmawSpots`, a node beside `ExpansionSpots`): for every swamp with
  room, the free spots where ALL its missing Rootmaws fit together, gold footprints on the ground (the first of each
  swamp brighter), a ROOTMAW SPOT label when zoomed in, small gold squares on the minimap. Brighter while placing a
  Rootmaw, with each one's 8-tile circle drawn. Shown to a Brood player only, only on his own swamp; not when watching
  or in the editor. **No snapping**: a Rootmaw roots where it is put (the test checks it). Settings > DISPLAY:
  **SHOW ROOTMAW SPOTS** (on by default).
- **The computer** roots its Rootmaws on the marked spots first (`AIBroodNew._nb_marked_spot`, scored as its old ring
  search: near the Mother, the eco plans' far edge, away from the enemy); its old ring search only when no mark will do.
  Measuring switch `mawspots:off`. The count holds it too (it goes through `BroodRoot.place_problem`), so with the main
  full it makes room with a turtle, as it already did when its rings found none.
- **One rule changed with it**: a Rootmaw is on the swamp when either cell of its footprint's middle column is
  (`BroodNew.maw_on_swamp`), not its feet's cell. The feet hang below a footprint's middle on screen, so on a mirrored
  start the same spot fell on or off the swamp differently; measured from the footprints the two sides' marks now
  mirror exactly on every built-in map (the test fails if they don't).

## 1. What changed, file by file

| file | what |
|---|---|
| `scripts/rootmaw_spots.gd` (new) | `RootmawSpots`: the count (`sources`, `assign`, `count_at`, `label`, `room_problem`), the spots (`candidates`, `pick`, `fit`, `spots_for`, a per-swamp cache `_fit_kept`), the marks node (draw, labels, minimap) |
| `scripts/brood_root.gd` | `place_problem`: the Rootmaw rule asks `RootmawSpots.room_problem` (the count) and `BroodNew.maw_on_swamp`; the circle rule reads `RootmawSpots.circle_r()` (= `Defs.PIT_CLAIM`; a measuring tool may try others); `_bt_n` numbers each search batch |
| `scripts/brood_new.gd` | `maw_on_swamp`, `maw_mid_cells`; a rooted Rootmaw goes dry by the same rule |
| `scripts/defs.gd` | `NB "maws_queen": 3, "maws_turtle": 2`; the Rootmaw's card text names the count |
| `scripts/ai_brood_new.gd` | `_nb_marked_spot` (the marks first, `mawspots:off`); its swamp checks by `maw_on_swamp` |
| `scripts/game.gd`, `scripts/ui/hud.gd` | the node (`Game.maw_spots`), its labels on the overlay, its minimap marks; ROOTMAWS n/3 on the Mother's and a turtle's card; the ROOT and Brood economy tips name the count |
| `scripts/settings.gd`, `scripts/main.gd` | `Settings.rootmaw_spots`, SHOW ROOTMAW SPOTS |
| `tools/i18n/72_rootmaw_spots.txt`, `25_sync_0_17.txt`, `34_fog_sound_ui.txt`, `26_brood_replace.txt`, `21_brood_new.txt`, `campaign/tutorial.txt` | the texts in pt/es (the help's Rootmaw circle said 10 tiles: now 8, and the count) |
| `campaign/missions/t30_brood.json` | the Brood lesson's Rootmaw step: "Each swamp holds a few Rootmaws: 3 on hers, 2 on a turtle's. Gold marks show where they fit best." |
| `tools/test_rootmaw_spots.gd`, `tools/measure_rootmaw_fit.gd`, `tools/shot_rootmaw_spots.gd` | test, measurement, pictures |
| `tools/study/qa_matches.py` | `--only brood`: the parity games with a Brood side against another faction |

### How a spot is picked (`RootmawSpots.fit`)

Every cell under the swamp's FULL reach (`BroodNew.swamp_full`: 12 / 13.5 / 15 tiles for the Mother's stages, 10 for a
turtle; the swamp's own squashed circle) is tried as a Rootmaw's feet, looked for in the side's first-start frame and
snapped back (`Game.sym_*`, as the computer's spot finders). Kept if a player's ROOT would take it (`place_problem`:
footprint, level ground, no ramp, no other Rootmaw's circle or plan, the count) and its footprint is not within 2 cells of
a ramp. Each is scored, from its footprint (not its feet): open walkable ground on its level in a 2-cell ring round it
(grubs come and go at its flanks), a little less the farther from the Mother's or turtle's footprint (0.35 a tile), less
on another level (-12) or region (-25). Then the best SET: as many of the missing Rootmaws as can fit 16 tiles apart (and
16 from every Rootmaw there), highest total score (a small exhaustive search). The lanes rule the computer keeps
(`BroodLayout`: never shut ground off) is asked of the spots picked; one that fails it is struck off and the set picked
again. A swamp's answer is kept until something near it changes (its source, its count, a Rootmaw or plan near it) or
15 s pass; in a grown base most swamps are full and cost nothing. About 25-40 ms for one swamp on this machine.

## 2. The measurements (radius)

`tools/measure_rootmaw_fit.gd` (data in `docs/brood_rootmaw_spots/`): every built-in map (27), with 2 players and with
as many as it holds, all-Brood; for each side: the Mother's swamp at stage 1 (12 tiles) from empty (3 wanted), the same
with her start Rootmaw where the game puts it (2 more wanted), and a turtle rooted on EVERY rated turtle site of the side
(`ExpansionSpots.nb_rate`, 2 wanted), with the computer's placing rules; the circle radius tried at 8, 7.5, 7, 6.5, 6.

| radius | fewest at a main from empty | fewest at a main with its start Rootmaw | fewest at a turtle site | sides / turtle sites measured | short |
|---|---|---|---|---|---|
| 8 (today) | 3 | 3 | 2 | 130 / 578 | 0 |
| 7.5, 7, 6.5, 6 | 3 | 3 | 2 | 130 / 578 | 0 |

Where the marks fall at 8 (`quality`): on every one of the 130 starts all three Rootmaws are on the Mother's level and in
her region; her start Rootmaw 7.6-8.8 tiles from her, the two marks 8.5-11.7 (her swamp reaches 12 across, 10.4 up and
down). This is the band near the swamp's edge the owner's geometry predicted for 8 (2.8 tiles): it is there on every
map. Per map:

| map | players | main from empty | main + start Rootmaw | fewest at a turtle site (sites) | all 3 on her level | start Rootmaw / marks, tiles from her |
|---|---|---|---|---|---|---|
| greenhold | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| greenhold | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| highmoor | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| highmoor | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| dune_sea | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| dune_sea | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| frostfang | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| frostfang | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| twin_fords | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| twin_fords | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| ashfall | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| ashfall | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| mirewood | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| mirewood | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| border_march | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| border_march | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| red_coast | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.0-11.1 |
| red_coast | 4 | 3 | 3 | 2 (8) | yes | 7.8-8.3 / 9.0-11.1 |
| ashford_crossing | 2 | 3 | 3 | 2 (10) | yes | 8.1-8.8 / 9.0-11.2 |
| kestrel_rise | 2 | 3 | 3 | 2 (8) | yes | 8.1-8.8 / 8.5-11.2 |
| thornwood_maze | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.6-10.5 |
| redrock_canyon | 2 | 3 | 3 | 2 (10) | yes | 8.1-8.8 / 9.0-11.2 |
| saltmarsh_isles | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.1-11.5 |
| glimmerdeep | 2 | 3 | 3 | 2 (10) | yes | 8.1-8.8 / 8.5-11.2 |
| frostmere | 2 | 3 | 3 | 2 (10) | yes | 8.1-8.8 / 9.0-11.2 |
| cinder_steps | 2 | 3 | 3 | 2 (8) | yes | 8.1-8.8 / 9.0-11.2 |
| hollowfen | 2 | 3 | 3 | 2 (10) | yes | 7.8-8.3 / 9.1-11.5 |
| amberfall_vale | 2 | 3 | 3 | 2 (10) | yes | 8.1-8.8 / 9.0-11.2 |
| twin_crowns | 2 | 3 | 3 | 2 (18) | yes | 7.8-8.3 / 9.1-11.5 |
| twin_crowns | 4 | 3 | 3 | 2 (16) | yes | 7.8-8.3 / 8.8-11.5 |
| jade_wilds | 2 | 3 | 3 | 2 (18) | yes | 8.1-8.8 / 9.0-11.2 |
| jade_wilds | 4 | 3 | 3 | 2 (16) | yes | 7.8-8.8 / 9.0-11.2 |
| shattered_coast | 2 | 3 | 3 | 2 (18) | yes | 7.8-8.3 / 9.1-11.5 |
| shattered_coast | 4 | 3 | 3 | 2 (16) | yes | 7.8-8.4 / 8.7-11.7 |
| ember_reach | 2 | 3 | 3 | 2 (18) | yes | 8.1-8.8 / 9.0-11.2 |
| ember_reach | 4 | 3 | 3 | 2 (16) | yes | 7.8-8.8 / 9.0-11.2 |
| whitecap_pass | 2 | 3 | 3 | 2 (18) | yes | 7.8-8.3 / 9.1-11.5 |
| whitecap_pass | 4 | 3 | 3 | 2 (16) | yes | 7.8-8.4 / 8.7-11.7 |
| kingsfield | 2 | 3 | 3 | 2 (24) | yes | 7.8-8.3 / 9.1-11.5 |
| kingsfield | 6 | 3 | 3 | 2 (20) | yes | 7.8-8.4 / 8.7-11.7 |
| pinewall_marches | 2 | 3 | 3 | 2 (26) | yes | 8.1-8.8 / 9.0-11.2 |
| pinewall_marches | 6 | 3 | 3 | 2 (22) | yes | 7.6-8.8 / 9.0-11.2 |
| sundered_realm | 2 | 3 | 3 | 2 (32) | yes | 8.1-8.8 / 9.0-11.2 |
| sundered_realm | 8 | 3 | 3 | 2 (26) | yes | 7.8-8.8 / 8.7-11.7 |

**Choice: keep 8.** A smaller circle would only pack the three closer to her (shorter trips, which pay less) and let more
Rootmaws crowd a turtle's ground the count already limits; nothing on any map needs it. If the owner wants a smaller one
anyway, `Defs.PIT_CLAIM` is the one number (the marks, the rule, the test and the computer follow it).

## 3. The bench and the computers alone

Three maps (Greenhold, Dune Sea, Hollowfen), 12 minutes, the means of the three; primary resource earned, cumulative
(food, gold, cogs). Data in `docs/brood_rootmaw_spots/bench/`. BEFORE = main at 0.38.13 (the Brood only: nothing of the
Crown's or the Clockwork's changed).

**The bench** (`tools/econ_bench.gd`, the scripted ideal build, no army; expansions at 4:00 and 8:00):

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| Brood, this branch | 3,059 | 8,292 | 11,828 | 16,179 |
| Brood, before | 2,725 | 7,111 | 10,121 | 14,513 |
| Crown (gold; with powder) | 4,180 (4,364) | 9,500 (10,031) | 13,180 (14,077) | 17,360 (18,729) |
| Clockwork (cogs; with Tension) | 4,354 (4,634) | 9,791 (10,449) | 13,828 (14,822) | 18,379 (19,771) |
| **Brood / Crown** (gold only) | 0.73 | 0.87 | 0.90 | 0.93 |
| **Brood / Clockwork** (cogs only) | 0.70 | 0.85 | 0.86 | 0.88 |
| Brood a minute (the 2 minutes before) | 852 | 1,816 | 1,768 | 2,176 |
| Crown a minute | 1,140 | 2,090 | 1,840 | 2,090 |
| Clockwork a minute | 1,032 | 2,122 | 2,018 | 2,276 |

The Brood's bench rose 11-17% (+1,666 at 12:00): the bench lays its Rootmaws with the computer's spot finder, which now
roots on the marks, and the marks find room for the full 3 round her where the old rings often found 2 (by 5:00 it has 5
Rootmaws, was 4). The count never held the bench back (its 7 Rootmaws by 10:00 stand 3 at home and 2 on each turtle).
By design the Brood still earns less than the others early (its eggs come one at a time) and 0.88-0.93 of them at 12:00.

**The computers alone** (Hard OPTIMAL, the other side an idle dummy: `econ_ai_alone_brood.gd`, `econ_ai_alone.gd foe=brood`,
`econ_alone_cw.gd`):

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| Brood, this branch | 2,796 | 8,468 | 12,808 | 17,293 |
| Brood, before | 2,772 | 8,938 | 13,319 | 18,000 |
| Crown | 2,913 | 7,600 | 11,780 | 16,513 |
| Clockwork | 3,753 | 8,656 | 13,999 | 19,592 |
| **Brood / Crown** | 0.96 | 1.11 | 1.09 | 1.05 |
| **Brood / Clockwork** | 0.75 | 0.98 | 0.91 | 0.88 |
| Brood a minute (the 2 minutes before) | 825 | 2,061 | 2,170 | 2,242 |
| Crown a minute | 887 | 1,837 | 2,090 | 2,367 |
| Clockwork a minute | 898 | 1,852 | 2,672 | 2,796 |

The Brood computer alone earns 4% less than before at 12:00 (Greenhold -7%, Dune Sea -9%, Hollowfen +5%; one run each,
so within what one seed swings). Both have 7 Rootmaws at 8:00 and the plan's 50 grubs from about 7:00; by 12:00 it has
6-7 Rootmaws (before 5-8) and 3-9 turtles on new ground (before 9-10), and banks less (about 4,900, before 4,700-6,600).
The difference is where its 4th and later Rootmaws go: before, its rings could put more than 3 round her and on the home
turtles' swamp; now home holds 3 + 2 a turtle and the rest must go to new ground.

## 4. The computer games

GAMES

## 5. Tests

- `tools/test_rootmaw_spots.gd` (new): ALL OK. [count] 1 of 3 at the start, a grub on its way counts, 3 of 3 then no
  legal spot left on her swamp ("Full"), ROOTMAWS 3/3 on the card, a turtle 0 of 2 then 2 of 2 then "Full"; [snap] a legal
  spot off the marks roots where it was put; [show] a Brood player sees 2 marks, only on his own swamp; none for a Crown
  player, when watching, or with SHOW ROOTMAW SPOTS off; [fit] on all 27 maps both sides get the Mother's 2 marks and 2
  round each of their 2 best turtle sites, every mark legal for a player and for the computer, a circle's width apart and
  from the start Rootmaw, and the two sides' marks mirror each other exactly.
- Pass: test_brood_new, test_brood_ai_defend, test_brood_builds, test_brood_controls, test_brood_far, test_brood_fix3,
  test_brood_fixes, test_brood_layout (rule), test_brood_mirror, test_brood_paths, test_brood_production,
  test_brood_regen_calm, test_brood_rush_riders, test_brood_sounds, test_brood_spend, test_brood_voices,
  test_settings_tabs and test_qa_settings_persist (both now list SHOW ROOTMAW SPOTS).
- test_expansion_spots: every Brood check passes; one CLOCKWORK check failed once in the full run (Red Coast, 4 players:
  only 5 of a Clocktower ring's 8 buildings laid at p3's spot) and passed when Red Coast ran alone. The spots it marks there
  differ from run to run (main's own full run, which passed, marked other cells, and so did the run alone), so the ring
  check is flaky there; nothing of this job touches the Clockwork.
- test_ai_brood (balanced, Greenhold): its stage-3 milestone failed once ("never" by 620 s) and passed on the rerun (at
  453 s); CLAUDE.md lists that check as flaky. Everything else passes.
- Fail on main too (pre-existing, the same lines): test_brood_new_defence's [rooted] muskets case (the Mother dies),
  test_brood_v_riders' "most grubs survive the raid" (6 of 13 lost). test_brood_production and test_brood_regen_calm
  print two SCRIPT ERRORs from `main.gd _menu_button` (a menu slot with no button) on main too; both pass.
- Most of these tools end with the engine aborting at quit (exit code 134) after printing their result, on main as on
  this branch; read their PASS/FAIL lines, not the exit code.

## 6. Claude's choices for the owner to confirm

1. **The circle stays at 8 tiles** (section 2): every map fits 3 + 2 at 8.
2. **Overlapping swamps**: a Rootmaw belongs to the swamp under it with the most room left (then the nearest middle). So
   a turtle at home whose swamp overlaps hers adds 2 to the home count wherever the Rootmaws stand in the overlap.
3. **What counts**: rooted, rooting, in a cocoon, walking to root, a grub on its way to turn into one, one the computer
   got up to fight that keeps its spot; one getting up (uprooting) already does not, so a spent Rootmaw can be replaced
   at once. A Rootmaw left on a swamp whose source walked away counts nowhere until it is on a swamp again.
4. **A Rootmaw is on the swamp by its footprint's middle**, not its feet (section "In short"): a small rule change made
   for mirror fairness. The swamp rule is a little more forgiving at the swamp's lower edge and a little stricter at its
   upper edge than before.
5. **The marks show the full count's spots only** (all 3 together, or all 2), as asked: a swamp with room for one more
   shows one mark. A full swamp shows none. The first mark of each swamp is the brighter one.
6. **The marks are for the player's own swamp only**, also against another Brood (an enemy Brood's swamp is never
   marked), and never while watching a replay or a computer game (the expansion spots do show there).
7. **ROOTMAWS n/3 on the card**, not over the creature in the world (the bar stack over the Mother is full: eggs, growth,
   rooting); while placing a Rootmaw the counts do stand over each Mother and turtle.
8. **The computer**: the marks first, scored as before (so its plans keep their character: the eco plans still prefer the
   far edge), the old ring search as a fallback. `mawspots:off` measures without them.
9. **The tutorial** got one new line in the Rootmaw step; the step itself (2 Rootmaws) is unchanged.

## 7. What is left

- The marks are worked out for the swamp's FULL reach at the Mother's present stage: when she grows (13.5, 15 tiles) the
  marks move out with her swamp. Rootmaws already rooted stay where they are.
- The labels and marks follow the expansion spots' look; no art of their own (`docs/art_style_inconsistency.md` lists the
  code-drawn marks).
- Not measured: online play (the marks are the player's own, worked out on his machine; the count is checked by
  `place_problem` on the host like every rule).
- The balance recommendation in section 4 waits for the owner.

## How to run it

- Test: `godot --headless --fixed-fps 30 --script res://tools/test_rootmaw_spots.gd [-- maps:a,b]` (about 10-15 minutes for
  every map).
- Measure: `godot --headless --fixed-fps 30 --script res://tools/measure_rootmaw_fit.gd -- [r:8,7,6] [maps:a,b]
  [turtles:all] [quality]`.
- Pictures: `xvfb-run -a godot --rendering-driver opengl3 --resolution 1600x900 --fixed-fps 30 --script
  res://tools/shot_rootmaw_spots.gd -- out:/abs/dir [maps:a,b]`.
- Bench: `tools/econ_bench.gd -- <faction> minutes=12 exp=240,480 map=<map>`; the computers alone:
  `tools/econ_ai_alone_brood.gd -- brood minutes=12 map=<map>`, `tools/econ_ai_alone.gd -- crown minutes=12 map=<map>
  foe=brood`, `tools/econ_alone_cw.gd -- minutes=12 map=<map>`.
- Games: `python3 tools/study/qa_matches.py run OUT --data DATA --only brood --end 720`.
