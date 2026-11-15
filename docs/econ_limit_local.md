# The economy limit counted by hall (econ-limit-local, 0.38.16)

**The owner, 2026-11-15 18:06**, after a playtest in which he built 3 Cog Presses round one Clocktower: *"it should be
2 per Town Hall, 2 per Clocktower"*.

Until 0.38.15 the limit was **empire-wide**: `Game.econ_limit(t, kind)` was `Defs.econ_per_hall(faction, kind)` times the
number of built halls, and `Game.econ_count` counted all the side's buildings of that kind wherever they stood. Each Farm /
Cog Press drew from its NEAREST hall's soil / brass (`Game.soil_hall` / `lode_hall` = `nearest_hall`), so with two halls a
player could put 3 or 4 Farms (Presses) round the main, drain the main twice as fast and leave the expansion's pool unused.

## What changed

**Every economy building belongs to the hall it draws from, and each hall allows `Defs.econ_per_hall` of each kind.**

- The economy kinds are `Defs.econ_of(faction)`: the Crown's **Farm (2)** and **Powder Mill (1)**, the Clockwork's **Cog
  Press (2)** and **Mainspring (1)** (and, with the shelved Line, its Boilers / Ore Crushers / Ore Drills). All of them are
  counted locally: the Mill grinds its nearest hall's saltpetre and the Mainspring winds its nearest Clocktower's spring
  life exactly as a Farm draws its nearest hall's soil, so the same rule fits them. (If the owner wants the Mainspring kept
  empire-wide, see "Claude's choices", 1.)
- **Its hall** = its nearest *built* hall, `Game.nearest_hall` (edge distance from the hall to the building's middle), the
  very hall it draws from. Placing: the hall nearest the footprint's middle.
- **The refusal** (`Game.placement_problem` -> `Game.econ_full_at`), shown on the PLACE button and the red ghost while placing,
  and as a toast when you click:
  - "This Town Hall already has its Farms (2/2). Build near another Town Hall."
  - "This Town Hall already has its Powder Mill (1/1). Build near another Town Hall."
  - "This Clocktower already has its Cog Presses (2/2). Build near another Clocktower."
  - "This Clocktower already has its Mainspring (1/1). Build near another Clocktower."

  (en/pt/es: `tools/i18n/73_econ_limit_local.txt`). The old "Each Town Hall allows 2 Farms. Expand for more." stays for
  when *every* hall is full.
- **The card**: a Town Hall's card ends with `FARMS 1/2 · POWDER MILL 0/1`, a Clocktower's with `COG PRESSES 2/2 ·
  MAINSPRING 1/1` (was "allows 2 Farms and 1 Powder Mill nearby"; `HUD._econ_counts`). The build menu keeps the side's
  total (`FARM 3/4`, now "of what your halls allow") and its tooltip adds "2 per Town Hall (each counts the ones nearest it)".
- **`Game.econ_limit`** now returns the sum over the built halls of `max(per hall, what that hall has)`, so the old test
  every caller makes, `econ_count >= econ_limit`, still means exactly "no hall has room". No caller had to change for that.
  New helpers: `Game.econ_by_hall(t, kind)` ({hall: n}), `econ_at(hall, kind)`, `econ_full_at(t, kind, point)`,
  `econ_spot_begin/end` (a spot search looks the counts up once: `find_spot`, `find_start_spot`, `GearEcon.room_spot_n`).
- Texts: the Town Hall's and the Clocktower's descriptions, the short card tips and the Crown help page say "round it: each
  counts for its nearest Town Hall / Clocktower" (en/pt/es).

No circles, no districts: only the count by nearest hall. The Brood is unchanged (its Rootmaw count, 3 on the Mother's
swamp and 2 on a turtle's, is per swamp since 0.38.15).

## The choices (Claude's, written down for the owner)

1. **The Powder Mill and the Mainspring are local too** (1 a hall). They draw from their nearest hall like a Farm does, and
   "2 per Town Hall, 2 per Clocktower" read as one rule for the economy buildings. A consequence for the Clockwork: a second
   Mainspring (for the Clock Aviary or the Heavy Works) can no longer stand by the main once the main has one; it goes by
   the second Clocktower. The tech itself is not held back by this: since 0.25.0 a Mainspring anywhere in the gear network
   feeds the Escapement, Aviary and Heavy Works. Making the Mainspring empire-wide again is a two-line change
   (`Game.econ_full_at` skipping it).
2. **A hall going up does not count.** Its limit starts when it stands (as before: an economy building had to stand near a
   *built* hall). Its card shows `FARMS 0/2` meanwhile.
3. **A fallen hall**: its buildings go to the next nearest built hall and keep working there (they now draw from it, as they
   always did). That hall may be **over its count** (e.g. `FARMS 4/2`): nothing is pulled down, but no new one goes there
   until it is under its count. The side's limit counts what stands (`max(per, n)`), so the rest of its halls keep their
   own room.
4. **A tie** (a spot exactly as near two halls): the **older hall** (`nearest_hall` keeps the first it meets, and halls are
   met in the order they were built). Each side's own older hall: mirror-fair.
5. **Old saves and replays** load unchanged. A save with 3 Farms by one hall keeps all 3 working (over its count, as in 3).
   A MIXED replay recorded before 0.38.16 that placed a 3rd Farm by one hall has that order refused when it is re-run; the
   next keyframe (every 10 s) puts the real game back. FULL replays (pictures) are untouched.
6. **The computers.** They already laid Farms and Presses per hall (`AICrownLayout`, `AICrown._hall_farm`, `AICwMacro`),
   counting by `nearest_hall` / `lode_hall`. Changes: the shared `AI._econ_spot` skips a hall that is full (its spots would
   all be refused; `find_spot` would have tried every cell round it for nothing); `AICwMacro` checks `Game.econ_at` as well
   as its own working-press count (a spent press still holds its place); the recycling of spent Mills / Presses
   (`AI._recycle_spent`) and Farms (`AICrown._recycle_spent`) pulls down a spent building **of the hall that needs the
   place** (one by another hall would free nothing there). A refused spot is never retried in a loop: every spot finder
   tests `placement_problem`, and the shared rule gives a kind with no room a 20 s rest (`_no_room`).

## The bench and the computers alone

Three maps (Greenhold, Dune Sea, Hollowfen), 12 minutes, the means of the three; primary earned, cumulative (gold, cogs),
the secondary (powder, Tension) in brackets. BEFORE = main at 0.38.15, AFTER = this branch. Data in
`docs/econ_limit_local/` (JSON rows; `by_hall` in the computers' rows = each hall's buildings); tables:
`python3 tools/study/econ_limit_local_report.py docs/econ_limit_local`.

BENCH_TABLES

## Tests

TEST_TABLE
