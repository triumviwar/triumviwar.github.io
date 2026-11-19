# Late-game lag against the Brood (perf-late-brood, 0.38.70)

The owner's game of 2026-11-18 (docs/owner_logs/2026-11-18_highmoor_crown_v_brood.txt, v0.38.67, Highmoor, he plays the
Crown against a HARD ECONOMY Brood computer, seed 2631178009) fell to 23 fps at minute 10 and 10 fps at minute 11, with
about 245 units and 99 buildings on the map.

## The short answer

- The Brood computer's long frames are gone. Before, it stopped the game for 120 to 160 ms every 15 seconds in a grown
  base, and for 50 to 120 ms many other times. Now its worst frame in the same game is 58 ms, and none is over 80 ms.
- The units' own work in the late game is about 9% less, and the game's whole tick about 8% less. That is real but
  small: the units are still most of the time.
- The game plays out exactly the same. Two runs of the same 11-minute match, before and after, write the same file of
  every unit, building and resource every 5 seconds (with the one measuring switch below set as before).
- So the owner's late game will be smoother (no AI freezes, a little faster), but a 250-unit game on his computer will
  still run well under 30 fps. The 30 fps target was not reached. What is left is below.

## How it was measured

- The owner played the Crown by hand. The bench (tools/perf_bench.gd) plays both sides with Hard computers. With the
  Crown on OPTIMAL, the Crown hurt the Brood too much and the game never grew past 150 units. So both sides play ECONOMY
  (`highmoor crown brood hard strat:economy strat0:economy seed:2631178009`). That game reaches 273 units at 11:00,
  most of them the Brood's: 16 Mound Turtles, 10 Rootmaws, 66 grubs, Sires, Raptors. That is the owner's late game.
- New: perf_bench `resume:FILE` starts from a save written by `savestate:FILE`. The 11:00 save of that game is the late
  game in one minute of play (11:00 to 12:00, 289 units), so a change can be measured in three minutes.
- Headless, at a fixed 60 frames a second: the game's own work, no drawing. A cloud computer (2 cores). It runs the
  game's code about twice as fast as the owner's computer: his log shows 64 microseconds a unit a tick all game, this
  machine 30 to 40.
- Every number below is from the same machine. The cloud machine changed during the job; the before and after runs of
  each table were made on the same one, one after the other.

## The numbers

### The late game, 11:00 to 12:00 (the save; two runs each, alternating, averaged)

| | before | after |
|---|---|---|
| units, ms a frame | 5.69 | 5.17 (-9%) |
| computers (both), ms a frame | 1.97 | 1.84 |
| the game's tick, ms (average) | 18.4 | 16.9 (-8%) |
| the tick, 95th percentile, ms | 31.0 | 29.4 |
| the slowest tick, ms | 148 | 102 |
| processor time for the minute | 42.4 s | 39.4 s |

### The whole game, 0:00 to 11:00 (from the start)

| | before | after |
|---|---|---|
| frames over 50 ms with the Brood computer in them | 38 | 17 |
| ... where the Brood computer took over 50 ms | 23 | 7 |
| ... where it took over 80 ms | 11 | 0 |
| the Brood computer's longest think | 126 ms | 58 ms |
| the slowest tick | 151 ms | 94 ms |

The Brood computer's think by its parts, in its worst moments before and after:

| part | before | after |
|---|---|---|
| ai/brood/rootmaws (every 15 s in a grown base) | 120-160 ms | 15-50 ms, spread out |
| ai/brood/morphs | 50-115 ms | 45-50 ms |
| ai/brood/father (a Sire looking for his nest, every think) | 15-40 ms | 5-15 ms |

On the owner's computer (about twice as slow) that is 250-320 ms before and about 100 ms after at worst.

## What was slow, and what was changed

All of these give the same answers as before (same spots, same moves, same picks); only the measuring switch
`mawstagger:off` is needed for the before/after file to match, because of the first item.

1. **The Rootmaw spots every 15 seconds (ai/brood/rootmaws, 120-250 ms in the owner's log).** The best Rootmaw spots of
   each swamp (RootmawSpots, the gold marks) are kept for 15 seconds, and all of them ran out on the same tick: with 17
   swamps, 17 searches at once. Now:
   - each swamp's 15 seconds start at its own moment (from its feet, the same on both starts of a mirrored map), so one
     or two are looked at a time. This changes WHEN a swamp is looked at again, so the computer's choices can come a
     few seconds earlier or later: switch `mawstagger:off` puts it back;
   - the search is three times faster: the spots inside another Rootmaw's circle are struck off first (the dearest
     check said no for them anyway), the swamp's reach is worked out once, and one look over all the swamps asks each
     spot once (a memo round).
2. **A Sire's nest (ai/brood/father, 20-40 ms every think).** In a crowded base a Sire looked for his nest on every
   think, checking all 24 spots of a ring with the dear check. Now the ring's spots are put in order of distance and
   checked until the first good one, inside a search batch: the same spot.
3. **The Rootmaw and turtle searches (ai/brood/morphs).** The spot's score is worked out first and the dear checks are
   made only for a spot that would beat the best so far. The supply turtle's search (up to 1,900 spots, 33 ms) puts the
   spots in score order and checks until the first good one: the same spot.
4. **Every moving unit's step (11% of the units' time).** Game.resolve_terrain answers the usual case in one look: away
   from the ramp rails, all five probe points on open ground, no wall corner: the step stands as it is.
5. **Rooted creatures.** Their measuring point (BroodRoot.anchor: the footprint mirrored into the first start's frame
   and back) was worked out several times a tick for every rooted creature: its swamp, a Rootmaw's draw, a Sire's
   reach. It is now kept on the creature while its footprint is the same (Unit.anchor_fp).
6. **Grubs going to a Rootmaw.** The spot at its flank was worked out every tick for every grub (10 us); it depends only
   on the Rootmaw's footprint and where the Mother is, so it is kept per Rootmaw.
7. **Looking for a target with no enemy unit near (60 us).** An idle unit, a rooted turtle, looked at every enemy
   building three times a second, each through two calls. The distance to a building is now worked out in the loop:
   40 us to about 10.
8. **Wave paths (game/path smoothing, 38 of 48 ms in one of the owner's frames).** The walkers of a wave share their
   path's cells, so the same straight lines between the same waypoints were tested again for every walker. The answers
   are kept for one run of the path queue (the ground doesn't change during it).
9. **The replay at 0:10 (replay/write 362 ms).** The replay's records are now written on a worker thread, in order;
   anything that reads a replay waits for them first. The web build has no threads: as before.
10. **Pictures coming in (the 0.8-1.2 s frames at 0:14-0:18 were "the rest").** On the Compatibility renderer a picture
    loaded in the background goes to the graphics card on the main thread, in the frame it comes in. ArtWarm now asks
    for one new picture a frame, so they come in a few at a time. (Not measurable here: no graphics card.)
11. **Better slow-frame lines.** "the rest" of a slow frame now says how long the drawing took on the processor and on
    the graphics card, and how many pictures came in that frame; the log says when the game's window lost focus and got
    it back, or was put in the background.

## What is left

- **The units are still most of the time.** About 30-40 us a unit a tick here (65 on the owner's computer), spread
  over hundreds of small checks: moving and pushing neighbours apart (35%), the workers' gathering (12%), the animation
  of the units on screen (10%), finding targets, the rooted creatures' own tick. At 250 units on his computer that is
  about 16 ms of every tick on its own, so 30 fps there needs the units' tick about halved. That is a rewrite of the
  unit tick (a much lighter tick for units that only stand, work or are rooted), not a tuning, and it was not done here.
- **The drawing.** In the owner's log about 15 ms a frame was not the game's own work. The new slow-frame lines will
  say how much of it was drawing.
- **The 8.4-second frame at 4:05** had no part of the game in it at all (units 28 ms over its 8 catch-up ticks, the
  rest 8,320 ms), right after his second Town Hall finished. Nothing in the game takes that long; the window being
  moved or put away stops a game on Windows, and the next log will show that if it happens again (the new focus lines).
- **The 540 ms "unit draw" at 2:41** (the first Horseman) was not reproduced headless. It is likely a picture or a
  horse coat mask loaded the first time it was drawn.
- **The Crown computer** (not in the owner's game: he played the Crown) still has its own 50-70 ms thinks
  (ai/workers/xwall, ai/build).
- ai/brood/morphs still reaches 45-50 ms here at times (about 100 ms on the owner's computer): the new-ground reckoning
  (_maw_need_room) and the turtle searches on a busy think.

## The same game

- tools/perf_bench.gd `trace:FILE` (every unit, building and resource every 5 s), the 11-minute game above from the
  start, before (0.38.69) and after with `mawstagger:off`: identical (834,304 bytes). The late-game minute from the
  11:00 save: identical too.

## Tests

All 42 of tools/test_ai_*.gd, test_brood_*.gd and test_rootmaw_spots.gd were run. 37 pass. Five fail, and fail the
same way on 0.38.69 (run there too): test_ai_rush_followup (15 checks), test_ai_scout_defence (the scout not hurt),
test_ai_wall_vs_rush (Barracks and Powder Mill by 75 s), test_brood_new (the Venom Sire's lure price on the BUILD card),
test_brood_new_defence (the rooted Mother against muskets: known on main). Every test ends with a crash on quit
(exit 134) on this machine, before and after: the result is read from the test's own lines.

## How to run it

    godot --headless --fixed-fps 60 --script res://tools/perf_bench.gd -- highmoor crown brood hard strat:economy \
        strat0:economy seed:2631178009 minutes:11 savestate:/abs/late.json
    godot --headless --fixed-fps 60 --script res://tools/perf_bench.gd -- resume:/abs/late.json minutes:12 [trace:FILE]

The raw numbers are in docs/perf/late_brood/ (rbb = before, rbf = after for the late-game minute; basefin and fin the
whole game).
