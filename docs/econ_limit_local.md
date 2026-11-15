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
  total (`FARM 3/4`: laid, of what all its halls allow) and its tooltip adds "2 per Town Hall (each counts the ones nearest it)".
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
   feeds the Escapement, Aviary and Heavy Works. Making the Mainspring empire-wide again is a small change
   (`Game.econ_full_at` and `econ_limit` treating it the old way).
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

Every computer run was played twice on each side (`.r2`): the computers never play a game the same way twice, and the same
build on the same map swung by up to 10% between two runs (Crown on Greenhold before: 16,980 and 15,460).

**The bench, Crown** (dune_sea, greenhold, hollowfen; 3 / 3 runs before / after)

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| before | 4,180 (184) | 9,500 (532) | 13,180 (897) | 17,360 (1,370) |
| after | 4,180 (184) | 9,500 (532) | 13,180 (897) | 17,360 (1,369) |
| change | +0.0% | +0.0% | +0.0% | +0.0% |

- dune_sea at 12:00: 17,360 -> 17,360 (+0.0%; runs 17,360 -> 17,360)
- greenhold at 12:00: 17,360 -> 17,360 (+0.0%; runs 17,360 -> 17,360)
- hollowfen at 12:00: 17,360 -> 17,360 (+0.0%; runs 17,360 -> 17,360)

**The bench, Clockwork** (dune_sea, greenhold, hollowfen; 3 / 3 runs before / after)

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| before | 4,354 (281) | 9,791 (659) | 13,830 (995) | 18,382 (1,392) |
| after | 4,353 (281) | 9,790 (659) | 13,828 (995) | 18,382 (1,393) |
| change | -0.0% | -0.0% | -0.0% | +0.0% |

- dune_sea at 12:00: 18,411 -> 18,418 (+0.0%; runs 18,411 -> 18,418)
- greenhold at 12:00: 18,434 -> 18,430 (-0.0%; runs 18,434 -> 18,430)
- hollowfen at 12:00: 18,301 -> 18,299 (-0.0%; runs 18,301 -> 18,299)

**The computer alone, Crown** (dune_sea, greenhold, hollowfen; 6 / 6 runs before / after)

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| before | 2,977 (118) | 7,853 (316) | 11,653 (625) | 16,410 (989) |
| after | 2,977 (118) | 7,790 (334) | 11,907 (619) | 16,410 (989) |
| change | +0.0% | -0.8% | +2.2% | +0.0% |

- dune_sea at 12:00: 16,600 -> 17,170 (+3.4%; runs 16,220 / 16,980 -> 16,980 / 17,360)
- greenhold at 12:00: 16,220 -> 16,030 (-1.2%; runs 16,980 / 15,460 -> 15,080 / 16,980)
- hollowfen at 12:00: 16,410 -> 16,030 (-2.3%; runs 16,600 / 16,220 -> 16,220 / 15,840)

**The computer alone, Clockwork** (dune_sea, greenhold, hollowfen; 6 / 6 runs before / after)

| | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| before | 3,748 (93) | 8,526 (361) | 13,661 (594) | 19,195 (899) |
| after | 3,743 (92) | 8,674 (426) | 14,004 (662) | 19,580 (971) |
| change | -0.2% | +1.7% | +2.5% | +2.0% |

- dune_sea at 12:00: 18,868 -> 18,958 (+0.5%; runs 19,021 / 18,716 -> 19,043 / 18,873)
- greenhold at 12:00: 18,942 -> 18,670 (-1.4%; runs 19,033 / 18,852 -> 18,575 / 18,766)
- hollowfen at 12:00: 19,774 -> 21,111 (+6.8%; runs 19,691 / 19,858 -> 21,131 / 21,091)

**Reading it.**
- **The bench does not move** (to the cog): the scripted ideal build already laid 2 Farms + a Mill / 2 Presses + a
  Mainspring by each hall, counting by nearest hall itself (`econ_bench._of_hall`). The design's income is unchanged.
- **The computers alone: no change beyond noise.** Crown 16,410 -> 16,410 at 12:00 (0.0%; each map within its own two
  runs' spread), Clockwork 19,195 -> 19,580 (+2.0%, mostly Hollowfen, where both "after" runs laid their third Clocktower about a
  minute earlier). Their Tension rose 8% (899 -> 971): with the Mainspring counted by Clocktower, a second Mainspring
  winds a second Clocktower's fresh spring life instead of sharing the main's. The `by_hall` rows show why so little
  changed: both computers already kept 2 Farms + 1 Mill / 2 Presses + at most 1 Mainspring round each hall before (in the
  6 runs before that counted by hall (`.r2`), a hall held more than its share once: a third Cog Press by the Clockwork's
  third Clocktower at 12:00 on Dune Sea, laid after a spent press by the main came down); the stacking the owner did in
  his game was a player's move, which the rule now refuses.
- So the change is a rule for the player (and a guarantee for the computers), not an economy change: the income
  comparisons in docs/brood_rootmaw_spots.md and docs/economy_parity.md still hold.

## Tests

Run on this branch (`godot --headless --fixed-fps 30 --script res://tools/<test>.gd`): all of `test_ai_*`, `test_crown_*`,
`test_cw_*`, `test_settings_*`, plus `test_exhaust`, `test_campaign_m1`, `test_horses`, `test_gear_press`, `test_i18n`,
`test_clockwork_eco`, `test_clock_hall_spot`, `test_clockwork_home`, `test_content_all` and the new one (76 tests).
Every test whose run printed a FAIL or a script error was run again on main (0.38.15).

- **New: `tools/test_econ_limit_local.gd`: PASS** (35 checks): [crown] 2 Farms by one Town Hall, a 3rd by it refused with
  2 halls standing (the side's limit 4), the reason word for word and translated, `find_spot` round the full hall finds
  none of its spots, near the other hall allowed and counted there, the cards (`FARMS 2/2 · POWDER MILL 0/1`, `FARMS 1/2`),
  the Powder Mill 1/1; [ai] the Crown computer's Farm spot (`AI._econ_spot`) lands by the hall with room; [going] a tie goes
  to the older hall, a hall going up adds nothing (`FARMS 0/2`); [fallen] a fallen hall's Farms go to the main (`FARMS 4/2`),
  keep drawing from it, and nothing new goes there; [clock] the same for Cog Presses (2/2, `COG PRESSES 2/2` / `1/2`), the
  computer's ring spot (`GearEcon.room_spot`) by the full Clocktower finds none, the Mainspring 1/1 by one Clocktower and
  allowed by the other.
- **Pass**: all the others, among them `test_exhaust` (the 1-Mainspring limit), `test_horses` (2 Farms / 1 Mill a Town
  Hall), `test_gear_press`, `test_campaign_m1` (the Prologue's 4 drying barns, "the Farm limit is reached (4 of 4)", 0
  failures), `test_content_all` (0 FAIL checks), `test_i18n` (0 untranslated), `test_clockwork_eco`, `test_clock_hall_spot`,
  `test_ai_expand_wall`, `test_crown_farms`, `test_crown_lost_hall`, `test_crown_owner_eco`, `test_settings_tabs`.
- **Flaky, passed when run again on this branch**: `test_ai_expand` [clockwork] "still earning in the last 60 s" (0 once,
  then 432; known flaky, CLAUDE.md), `test_clockwork_home` (an attack's share at the fight once, then PASS), `test_cw_tier3_ai`
  (the Netter's target once, then ALL PASS).
- **Fail on main too (pre-existing, the same checks)**: `test_ai_rush` ("workers before the Brood Mother"),
  `test_ai_rush_followup` (14-15 checks), `test_crown_dragoon_raid` ([plan]), `test_crown_stall` ([foundry] 343-344 s
  for 330), `test_cw_heavy` and `test_cw_militia` (the shelved Line's checks), `test_cw_tier3` (3 online checks), and
  `test_campaign_m1`'s script errors in `Main._menu_button` when it goes back to the menu (14-16 on both; its checks pass).
- Godot prints an abort when a headless tool quits (exit code 134 after its last line) on main as on this branch: the
  result lines are what count.
